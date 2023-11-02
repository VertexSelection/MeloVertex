using ARMeilleure.CodeGen;
using ARMeilleure.CodeGen.Unwinding;
using ARMeilleure.Memory;
using ARMeilleure.Native;
using Ryujinx.Memory;
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
        private static readonly int _pageMask = _pageSize - 1;

        private const int CodeAlignment = 4; // Bytes.
        private const int CacheSize = 2047 * 1024 * 1024;
        private const int CacheSizeIOS = 512 * 1024 * 1024;

        private static ReservedRegion _jitRegion;
        private static JitCacheInvalidation _jitCacheInvalidator;

        private static CacheMemoryAllocator _cacheAllocator;

        private static readonly List<CacheEntry> _cacheEntries = new();

        private static readonly object _lock = new();
        private static bool _initialized;

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

                _jitRegion = new ReservedRegion(allocator, (ulong)(OperatingSystem.IsIOS() ? CacheSizeIOS : CacheSize));

                if (!OperatingSystem.IsWindows() && !OperatingSystem.IsMacOS() && !OperatingSystem.IsIOS())
                {
                    _jitCacheInvalidator = new JitCacheInvalidation(allocator);
                }

                _cacheAllocator = new CacheMemoryAllocator(CacheSize);

                if (OperatingSystem.IsWindows())
                {
                    JitUnwindWindows.InstallFunctionTableHandler(_jitRegion.Pointer, CacheSize, _jitRegion.Pointer + Allocate(_pageSize));
                }

                _initialized = true;
            }
        }

        static ConcurrentQueue<(int funcOffset, int length)> _deferredRxProtect = new();

        public static void RunDeferredRxProtects()
        {
            while (_deferredRxProtect.TryDequeue(out var result))
            {
                ReprotectAsExecutable(result.funcOffset, result.length);
            }
        }  

        public static IntPtr Map(CompiledFunction func, bool deferProtect)
        {
            byte[] code = func.Code;

            lock (_lock)
            {
                Debug.Assert(_initialized);

                int funcOffset = Allocate(code.Length, deferProtect);

                IntPtr funcPtr = _jitRegion.Pointer + funcOffset;

                if (OperatingSystem.IsIOS())
                {
                    Marshal.Copy(code, 0, funcPtr, code.Length);
                    if (deferProtect)
                    {
                        _deferredRxProtect.Enqueue((funcOffset, code.Length));
                    }
                    else
                    {
                        ReprotectAsExecutable(funcOffset, code.Length);

                        JitSupportDarwinAot.Invalidate(funcPtr, (ulong)code.Length);
                    }
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
                    ReprotectAsWritable(funcOffset, code.Length);
                    Marshal.Copy(code, 0, funcPtr, code.Length);
                    ReprotectAsExecutable(funcOffset, code.Length);

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
                return;
            }

            lock (_lock)
            {
                Debug.Assert(_initialized);

                int funcOffset = (int)(pointer.ToInt64() - _jitRegion.Pointer.ToInt64());

                if (TryFind(funcOffset, out CacheEntry entry, out int entryIndex) && entry.Offset == funcOffset)
                {
                    _cacheAllocator.Free(funcOffset, AlignCodeSize(entry.Size));
                    _cacheEntries.RemoveAt(entryIndex);
                }
            }
        }

        private static void ReprotectAsWritable(int offset, int size)
        {
            int endOffs = offset + size;

            int regionStart = offset & ~_pageMask;
            int regionEnd = (endOffs + _pageMask) & ~_pageMask;

            _jitRegion.Block.MapAsRwx((ulong)regionStart, (ulong)(regionEnd - regionStart));
        }

        private static void ReprotectAsExecutable(int offset, int size)
        {
            int endOffs = offset + size;

            int regionStart = offset & ~_pageMask;
            int regionEnd = (endOffs + _pageMask) & ~_pageMask;

            _jitRegion.Block.MapAsRx((ulong)regionStart, (ulong)(regionEnd - regionStart));
        }

        private static int Allocate(int codeSize, bool deferProtect = false)
        {
            codeSize = AlignCodeSize(codeSize, deferProtect);

            int alignment = CodeAlignment;

            if (OperatingSystem.IsIOS() && !deferProtect)
            {
                alignment = 0x4000;
            }

            int allocOffset = _cacheAllocator.Allocate(ref codeSize, alignment);

            Console.WriteLine($"{allocOffset:x8}: {codeSize:x8} {alignment:x8}");

            if (allocOffset < 0)
            {
                throw new OutOfMemoryException("JIT Cache exhausted.");
            }

            _jitRegion.ExpandIfNeeded((ulong)allocOffset + (ulong)codeSize);

            return allocOffset;
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
