using ARMeilleure.CodeGen;
using ARMeilleure.CodeGen.Unwinding;
using ARMeilleure.Memory;
using ARMeilleure.Native;
using Ryujinx.Memory;
using Ryujinx.Common.Logging;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Runtime.Versioning;

namespace ARMeilleure.Translation.Cache
{
    static partial class JitCache
    {
        private static readonly int _pageSize = (int)MemoryBlock.GetPageSize();
        private static readonly int _pageMask = _pageSize - 4;

        private const int CodeAlignment = 4; // Bytes.
	    private const int CacheSize = 128 * 1024 * 1024;
        private const int CacheSizeIOS = 128 * 1024 * 1024;

        private static ReservedRegion _jitRegion;
        private static JitCacheInvalidation _jitCacheInvalidator;

        private static CacheMemoryAllocator _cacheAllocator;

        private static readonly List<CacheEntry> _cacheEntries = new();

        private static readonly object _lock = new();
        private static bool _initialized;

        private static readonly List<ReservedRegion> _jitRegions = new();

         private static int _activeRegionIndex = 0;

        [SupportedOSPlatform("windows")]
        [LibraryImport("kernel32.dll", SetLastError = true)]
        public static partial IntPtr FlushInstructionCache(IntPtr hProcess, IntPtr lpAddress, UIntPtr dwSize);

        public static void Initialize(IJitMemoryAllocator allocator)
        {
            if (_initialized)
            {
                return;
            }

            lock (_lock)
            {
                if (_initialized)
                {
                    return;
                }

                var firstRegion = new ReservedRegion(allocator, CacheSize);


                _jitRegions.Add(firstRegion);
                _activeRegionIndex = 0;

                if (!OperatingSystem.IsWindows() && !OperatingSystem.IsMacOS() && !OperatingSystem.IsIOS())
                {
                    _jitCacheInvalidator = new JitCacheInvalidation(allocator);
                }

                _cacheAllocator = new CacheMemoryAllocator(CacheSize);

                if (OperatingSystem.IsWindows())
                {
                    JitUnwindWindows.InstallFunctionTableHandler(
                         firstRegion.Pointer, CacheSize, firstRegion.Pointer + Allocate(_pageSize)
                     );
                }

                _initialized = true;
            }
        }

        static ConcurrentQueue<(int funcOffset, int length)> _deferredRxProtect = new();

        public static void RunDeferredRxProtects()
        {
            while (_deferredRxProtect.TryDequeue(out var result))
            {
                ReservedRegion targetRegion = _jitRegions[_activeRegionIndex];

                ReprotectAsExecutable(targetRegion, result.funcOffset, result.length);
            }
        }  

        public static IntPtr Map(CompiledFunction func, bool deferProtect)
        {
            byte[] code = func.Code;

            lock (_lock)
            {
                Debug.Assert(_initialized);

                int funcOffset = Allocate(code.Length, deferProtect);

                ReservedRegion targetRegion = _jitRegions[_activeRegionIndex];
                IntPtr funcPtr = targetRegion.Pointer + funcOffset;

                if (OperatingSystem.IsIOS())
                {
                    Marshal.Copy(code, 0, funcPtr, code.Length);
                    ReprotectAsExecutable(targetRegion, funcOffset, code.Length);
                    JitSupportDarwinAot.Invalidate(funcPtr, (ulong)code.Length);
                }
                else if (OperatingSystem.IsMacOS()&& RuntimeInformation.ProcessArchitecture == Architecture.Arm64)
                {
                    unsafe
                    {
                        fixed (byte* codePtr = code)
                        {
                            JitSupportDarwin.Copy(funcPtr, (IntPtr)codePtr, (ulong)code.Length);
                        }
                    }
                }
                else
                {
                    ReprotectAsWritable(targetRegion, funcOffset, code.Length);
                    Marshal.Copy(code, 0, funcPtr, code.Length);
                    ReprotectAsExecutable(targetRegion, funcOffset, code.Length);

                    if (OperatingSystem.IsWindows() && RuntimeInformation.ProcessArchitecture == Architecture.Arm64)
                    {
                        FlushInstructionCache(Process.GetCurrentProcess().Handle, funcPtr, (UIntPtr)code.Length);
                    }
                    else
                    {
                        _jitCacheInvalidator?.Invalidate(funcPtr, (ulong)code.Length);
                    }
                }

                Add(funcOffset, code.Length, func.UnwindInfo);

                return funcPtr;
            }
        }

        public static void Unmap(IntPtr pointer)
        {
            if (OperatingSystem.IsIOS())
            {
                // return;
            }

            lock (_lock)
            {
                foreach (var region in _jitRegions)
                {
                    if (pointer.ToInt64() < region.Pointer.ToInt64() ||
                        pointer.ToInt64() >= (region.Pointer + CacheSize).ToInt64())
                    {
                        continue;
                    }

                    int funcOffset = (int)(pointer.ToInt64() - region.Pointer.ToInt64());

                    if (TryFind(funcOffset, out CacheEntry entry, out int entryIndex) && entry.Offset == funcOffset)
                    {
                        _cacheAllocator.Free(funcOffset, AlignCodeSize(entry.Size));
                        _cacheEntries.RemoveAt(entryIndex);
                    }

                    return;
                }
            }
        }

        private static void ReprotectAsWritable(ReservedRegion region, int offset, int size)
        {
            int endOffs = offset + size;

            int regionStart = offset & ~_pageMask;
            int regionEnd = (endOffs + _pageMask) & ~_pageMask;

            region.Block.MapAsRwx((ulong)regionStart, (ulong)(regionEnd - regionStart));
        }

        private static void ReprotectAsExecutable(ReservedRegion region, int offset, int size)
        {
            int endOffs = offset + size;

            int regionStart = offset & ~_pageMask;
            int regionEnd = (endOffs + _pageMask) & ~_pageMask;

            region.Block.MapAsRx((ulong)regionStart, (ulong)(regionEnd - regionStart));
        }

        private static int Allocate(int codeSize, bool deferProtect = false)
        {
            codeSize = AlignCodeSize(codeSize, deferProtect);

            int alignment = CodeAlignment;

            if (OperatingSystem.IsIOS() && !deferProtect)
            {
                alignment = 0x4000;
            }

            for (int i = _activeRegionIndex; i < _jitRegions.Count; i++)
            {
                int allocOffset = _cacheAllocator.Allocate(ref codeSize, alignment);

                if (allocOffset >= 0)
                {
                    _jitRegions[i].ExpandIfNeeded((ulong)allocOffset + (ulong)codeSize);
                    _activeRegionIndex = i;
                    return allocOffset;
                }
            }

            int exhaustedRegion = _activeRegionIndex;
            var newRegion = new ReservedRegion(_jitRegions[0].Allocator, CacheSize);
            _jitRegions.Add(newRegion);
            _activeRegionIndex = _jitRegions.Count - 1;

            int newRegionNumber = _activeRegionIndex;

            _cacheAllocator = new CacheMemoryAllocator(CacheSize);

            int allocOffsetNew = _cacheAllocator.Allocate(ref codeSize, alignment);
            if (allocOffsetNew < 0)
            {
                throw new OutOfMemoryException("Failed to allocate in new Cache Region!");
            }

            newRegion.ExpandIfNeeded((ulong)allocOffsetNew + (ulong)codeSize);
            return allocOffsetNew;
        }

        private static int AlignCodeSize(int codeSize, bool deferProtect = false)
        {
            int alignment = CodeAlignment;

            if (OperatingSystem.IsIOS() && !deferProtect)
            {
                alignment = 0x4000;
            }

            return checked(codeSize + (alignment - 1)) & ~(alignment - 1);
        }

        private static void Add(int offset, int size, UnwindInfo unwindInfo)
        {
            CacheEntry entry = new(offset, size, unwindInfo);

            int index = _cacheEntries.BinarySearch(entry);

            if (index < 0)
            {
                index = ~index;
            }

            _cacheEntries.Insert(index, entry);
        }

        public static bool TryFind(int offset, out CacheEntry entry, out int entryIndex)
        {
            lock (_lock)
            {
                int index = _cacheEntries.BinarySearch(new CacheEntry(offset, 0, default));

                if (index < 0)
                {
                    index = ~index - 1;
                }

                if (index >= 0)
                {
                    entry = _cacheEntries[index];
                    entryIndex = index;
                    return true;
                }
            }

            entry = default;
            entryIndex = 0;
            return false;
        }
    }
}
