using ARMeilleure.Memory;
using Ryujinx.Common;
using Ryujinx.Memory;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;

namespace Ryujinx.Cpu.LightningJit.Cache
{
    class NoWxCache : IDisposable
    {
        private const int CodeAlignment = 4; // Bytes.
        private const int SharedCacheSize = 512 * 1024 * 1024;
        private const int LocalCacheSize = 128 * 1024 * 1024;

        // How many calls to the same function we allow until we pad the shared cache to force the function to become available there
        // and allow the guest to take the fast path.
        private const int MinCallsForPad = 8;

        private class MemoryCache : IDisposable
        {
            private readonly ReservedRegion _region;
            private readonly CacheMemoryAllocator _cacheAllocator;
            public readonly IJitMemoryAllocator Allocator;

            public CacheMemoryAllocator CacheAllocator => _cacheAllocator;
            public IntPtr Pointer => _region.Block.Pointer;

            public MemoryCache(IJitMemoryAllocator allocator, ulong size)
            {
                Allocator = allocator;
                _region = new(allocator, size);
                _cacheAllocator = new((int)size);
            }

            public int Allocate(int codeSize)
            {
                codeSize = AlignCodeSize(codeSize);

                int allocOffset = _cacheAllocator.Allocate(codeSize);

                if (allocOffset < 0)
                {
                    throw new OutOfMemoryException("JIT Cache exhausted.");
                }

                _region.ExpandIfNeeded((ulong)allocOffset + (ulong)codeSize);

                return allocOffset;
            }

            public void Free(int offset, int size)
            {
                _cacheAllocator.Free(offset, size);
            }

            public void ReprotectAsRw(int offset, int size)
            {
                Debug.Assert(offset >= 0 && (offset & (int)(MemoryBlock.GetPageSize() - 1)) == 0);
                Debug.Assert(size > 0 && (size & (int)(MemoryBlock.GetPageSize() - 1)) == 0);

                _region.Block.MapAsRw((ulong)offset, (ulong)size);
            }

            public void ReprotectAsRx(int offset, int size)
            {
                Debug.Assert(offset >= 0 && (offset & (int)(MemoryBlock.GetPageSize() - 1)) == 0);
                Debug.Assert(size > 0 && (size & (int)(MemoryBlock.GetPageSize() - 1)) == 0);

                _region.Block.MapAsRx((ulong)offset, (ulong)size);

                if (OperatingSystem.IsMacOS() || OperatingSystem.IsIOS())
                {
                    JitSupportDarwin.SysIcacheInvalidate(_region.Block.Pointer + offset, size);
                }
                else
                {
                    throw new PlatformNotSupportedException();
                }
            }

            private static int AlignCodeSize(int codeSize)
            {
                return checked(codeSize + (CodeAlignment - 1)) & ~(CodeAlignment - 1);
            }

            protected virtual void Dispose(bool disposing)
            {
                if (disposing)
                {
                    _region.Dispose();
                    _cacheAllocator.Clear();
                }
            }

            public void Dispose()
            {
                // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
                Dispose(disposing: true);
                GC.SuppressFinalize(this);
            }
        }

        private readonly IStackWalker _stackWalker;
        private readonly Translator _translator;
        private readonly List<MemoryCache> _sharedCaches;
        private readonly List<MemoryCache> _localCaches;
        private readonly Dictionary<ulong, PageAlignedRangeList> _pendingMaps;
        private readonly object _lock;

        class ThreadLocalCacheEntry
        {
            public readonly int Offset;
            public readonly int Size;
            public readonly IntPtr FuncPtr;
            public readonly int CacheIndex;
            private int _useCount;

            public ThreadLocalCacheEntry(int offset, int size, IntPtr funcPtr, int cacheIndex)
            {
                Offset = offset;
                Size = size;
                FuncPtr = funcPtr;
                CacheIndex = cacheIndex;
                _useCount = 0;
            }

            public int IncrementUseCount()
            {
                return ++_useCount;
            }
        }

        [ThreadStatic]
        private static Dictionary<ulong, ThreadLocalCacheEntry> _threadLocalCache;

        public NoWxCache(IJitMemoryAllocator allocator, IStackWalker stackWalker, Translator translator)
        {
            _stackWalker = stackWalker;
            _translator = translator;
            _sharedCaches = new List<MemoryCache> { new(allocator, SharedCacheSize) };
            _localCaches = new List<MemoryCache> { new(allocator, LocalCacheSize) };
            _pendingMaps = new Dictionary<ulong, PageAlignedRangeList>();
            _lock = new();
        }

        private PageAlignedRangeList GetPendingMapForCache(int cacheIndex)
        {
            ulong cacheKey = (ulong)cacheIndex;
            if (!_pendingMaps.TryGetValue(cacheKey, out var pendingMap))
            {
                pendingMap = new PageAlignedRangeList(
                    (offset, size) => _sharedCaches[cacheIndex].ReprotectAsRx(offset, size),
                    (address, func) => RegisterFunction(address, func));
                _pendingMaps[cacheKey] = pendingMap;
            }
            return pendingMap;
        }

        private bool HasInAnyPendingMap(ulong guestAddress)
        {
            foreach (var pendingMap in _pendingMaps.Values)
            {
                if (pendingMap.Has(guestAddress))
                {
                    return true;
                }
            }
            return false;
        }

        private int AllocateInSharedCache(int codeLength)
        {
            for (int i = 0; i < _sharedCaches.Count; i++)
            {
                try
                {
                    return (i << 28) | _sharedCaches[i].Allocate(codeLength);
                }
                catch (OutOfMemoryException)
                {
                    // Try next cache
                }
            }

            // All existing caches are full, create a new one
            lock (_lock)
            {
                var allocator = _sharedCaches[0].Allocator;
                _sharedCaches.Add(new(allocator, SharedCacheSize));
                return (_sharedCaches.Count - 1) << 28 | _sharedCaches[_sharedCaches.Count - 1].Allocate(codeLength);
            }
        }

        private int AllocateInLocalCache(int codeLength)
        {
            for (int i = 0; i < _localCaches.Count; i++)
            {
                try
                {
                    return (i << 28) | _localCaches[i].Allocate(codeLength);
                }
                catch (OutOfMemoryException)
                {
                    
                }
            }

            lock (_lock)
            {
                var allocator = _localCaches[0].Allocator;
                _localCaches.Add(new(allocator, LocalCacheSize));
                return (_localCaches.Count - 1) << 28 | _localCaches[_localCaches.Count - 1].Allocate(codeLength);
            }
        }

        private static (int cacheIndex, int offset) SplitCacheOffset(int combinedOffset)
        {
            return (combinedOffset >> 28, combinedOffset & 0xFFFFFFF);
        }

        public unsafe IntPtr Map(IntPtr framePointer, ReadOnlySpan<byte> code, ulong guestAddress, ulong guestSize)
        {
            if (TryGetThreadLocalFunction(guestAddress, out IntPtr funcPtr))
            {
                return funcPtr;
            }

            lock (_lock)
            {
                if (!HasInAnyPendingMap(guestAddress) && !_translator.Functions.ContainsKey(guestAddress))
                {
                    int combinedOffset = AllocateInSharedCache(code.Length);
                    var (cacheIndex, funcOffset) = SplitCacheOffset(combinedOffset);
                    
                    MemoryCache cache = _sharedCaches[cacheIndex];
                    funcPtr = cache.Pointer + funcOffset;
                    code.CopyTo(new Span<byte>((void*)funcPtr, code.Length));

                    TranslatedFunction function = new(funcPtr, guestSize);
                    
                    GetPendingMapForCache(cacheIndex).Add(funcOffset, code.Length, guestAddress, function);
                }

                ClearThreadLocalCache(framePointer);

                return AddThreadLocalFunction(code, guestAddress);
            }
        }

        public unsafe IntPtr MapPageAligned(ReadOnlySpan<byte> code)
        {
            lock (_lock)
            {
                int cacheIndex;
                int funcOffset;
                IntPtr mappedFuncPtr = IntPtr.Zero;
                
                for (cacheIndex = 0; cacheIndex < _sharedCaches.Count; cacheIndex++)
                {
                    try
                    {
                        var pendingMap = GetPendingMapForCache(cacheIndex);
                        
                        pendingMap.Pad(_sharedCaches[cacheIndex].CacheAllocator);

                        int sizeAligned = BitUtils.AlignUp(code.Length, (int)MemoryBlock.GetPageSize());
                        funcOffset = _sharedCaches[cacheIndex].Allocate(sizeAligned);
                        
                        Debug.Assert((funcOffset & ((int)MemoryBlock.GetPageSize() - 1)) == 0);

                        IntPtr funcPtr1 = _sharedCaches[cacheIndex].Pointer + funcOffset;
                        code.CopyTo(new Span<byte>((void*)funcPtr1, code.Length));

                        _sharedCaches[cacheIndex].ReprotectAsRx(funcOffset, sizeAligned);

                        return funcPtr1;
                    }
                    catch (OutOfMemoryException)
                    {
                        // Try next cache
                    }
                }

                // All existing caches are full, create a new one
                var allocator = _sharedCaches[0].Allocator;
                var newCache = new MemoryCache(allocator, SharedCacheSize);
                _sharedCaches.Add(newCache);
                cacheIndex = _sharedCaches.Count - 1;
                
                var newPendingMap = GetPendingMapForCache(cacheIndex);
                
                // Ensure we will get an aligned offset from the allocator.
                newPendingMap.Pad(newCache.CacheAllocator);

                int newSizeAligned = BitUtils.AlignUp(code.Length, (int)MemoryBlock.GetPageSize());
                funcOffset = newCache.Allocate(newSizeAligned);
                
                Debug.Assert((funcOffset & ((int)MemoryBlock.GetPageSize() - 1)) == 0);

                IntPtr funcPtr = newCache.Pointer + funcOffset;
                code.CopyTo(new Span<byte>((void*)funcPtr, code.Length));

                newCache.ReprotectAsRx(funcOffset, newSizeAligned);

                return funcPtr;
            }
        }

        private bool TryGetThreadLocalFunction(ulong guestAddress, out IntPtr funcPtr)
        {       
            if ((_threadLocalCache ??= new()).TryGetValue(guestAddress, out var entry))
            {
                if (entry.IncrementUseCount() >= MinCallsForPad)
                {
                    // Function is being called often, let's make it available in the shared cache so that the guest code
                    // can take the fast path and stop calling the emulator to get the function from the thread local cache.
                    // To do that we pad all "pending" function until they complete a page of memory, allowing us to reprotect them as RX.

                    lock (_lock)
                    {
                        foreach (var pendingMap in _pendingMaps.Values)
                        {
                            // Get the cache index from the pendingMap key
                            if (_pendingMaps.FirstOrDefault(x => x.Value == pendingMap).Key is ulong cacheIndex)
                            {
                                // Use the correct shared cache for padding based on the cache index
                                pendingMap.Pad(_sharedCaches[(int)cacheIndex].CacheAllocator);
                            }
                        }
                    }
                }

                funcPtr = entry.FuncPtr;

                return true;
            }

            funcPtr = IntPtr.Zero;

            return false;
        }

        private void ClearThreadLocalCache(IntPtr framePointer)
        {
            // Try to delete functions that are already on the shared cache
            // and no longer being executed.

            if (_threadLocalCache == null)
            {
                return;
            }

            IntPtr[] cachePointers = new IntPtr[_localCaches.Count];
            int[] cacheSizes = new int[_localCaches.Count];

            for (int i = 0; i < _localCaches.Count; i++)
            {
                cachePointers[i] = _localCaches[i].Pointer;
                cacheSizes[i] = LocalCacheSize;
            }

            IntPtr[] sharedPointers = new IntPtr[_sharedCaches.Count];
            int[] sharedSizes = new int[_sharedCaches.Count];

            for (int i = 0; i < _sharedCaches.Count; i++)
            {
                sharedPointers[i] = _sharedCaches[i].Pointer;
                sharedSizes[i] = SharedCacheSize;
            }

            // Iterate over the arrays and pass each element to GetCallStack
            IEnumerable<ulong> callStack = null;
            for (int i = 0; i < _localCaches.Count; i++)
            {
                callStack = _stackWalker.GetCallStack(
                    framePointer,
                    cachePointers[i],   // Passing each individual cachePointer
                    cacheSizes[i],      // Passing each individual cacheSize
                    sharedPointers[i],  // Passing each individual sharedPointer
                    sharedSizes[i]      // Passing each individual sharedSize
                );
            }

            List<(ulong, ThreadLocalCacheEntry)> toDelete = new();

            foreach ((ulong address, ThreadLocalCacheEntry entry) in _threadLocalCache)
            {
                // We only want to delete if the function is already on the shared cache,
                // otherwise we will keep translating the same function over and over again.
                bool canDelete = !HasInAnyPendingMap(address);
                if (!canDelete)
                {
                    continue;
                }

                // We can only delete if the function is not part of the current thread call stack,
                // otherwise we will crash the program when the thread returns to it.
                foreach (ulong funcAddress in callStack)
                {
                    if (funcAddress >= (ulong)entry.FuncPtr && funcAddress < (ulong)entry.FuncPtr + (ulong)entry.Size)
                    {
                        canDelete = false;
                        break;
                    }
                }

                if (canDelete)
                {
                    toDelete.Add((address, entry));
                }
            }

            int pageSize = (int)MemoryBlock.GetPageSize();

            foreach ((ulong address, ThreadLocalCacheEntry entry) in toDelete)
            {
                _threadLocalCache.Remove(address);

                int sizeAligned = BitUtils.AlignUp(entry.Size, pageSize);
                var (cacheIndex, offset) = SplitCacheOffset(entry.Offset);

                _localCaches[cacheIndex].Free(offset, sizeAligned);
                _localCaches[cacheIndex].ReprotectAsRw(offset, sizeAligned);
            }
        }


        public void ClearEntireThreadLocalCache()
        {
            // Thread is exiting, delete everything.

            if (_threadLocalCache == null)
            {
                return;
            }

            int pageSize = (int)MemoryBlock.GetPageSize();

            foreach ((_, ThreadLocalCacheEntry entry) in _threadLocalCache)
            {
                int sizeAligned = BitUtils.AlignUp(entry.Size, pageSize);
                var (cacheIndex, offset) = SplitCacheOffset(entry.Offset);

                _localCaches[cacheIndex].Free(offset, sizeAligned);
                _localCaches[cacheIndex].ReprotectAsRw(offset, sizeAligned);
            }

            _threadLocalCache.Clear();
            _threadLocalCache = null;
        }

        private unsafe IntPtr AddThreadLocalFunction(ReadOnlySpan<byte> code, ulong guestAddress)
        {
            int alignedSize = BitUtils.AlignUp(code.Length, (int)MemoryBlock.GetPageSize());
            int combinedOffset = AllocateInLocalCache(alignedSize);
            var (cacheIndex, funcOffset) = SplitCacheOffset(combinedOffset);

            Debug.Assert((funcOffset & (int)(MemoryBlock.GetPageSize() - 1)) == 0);

            IntPtr funcPtr = _localCaches[cacheIndex].Pointer + funcOffset;
            code.CopyTo(new Span<byte>((void*)funcPtr, code.Length));

            (_threadLocalCache ??= new()).Add(guestAddress, new(funcOffset, code.Length, funcPtr, cacheIndex));

            _localCaches[cacheIndex].ReprotectAsRx(funcOffset, alignedSize);

            return funcPtr;
        }

        private void RegisterFunction(ulong address, TranslatedFunction func)
        {
            TranslatedFunction oldFunc = _translator.Functions.GetOrAdd(address, func.GuestSize, func);

            Debug.Assert(oldFunc == func);

            _translator.RegisterFunction(address, func);
        }

        protected virtual void Dispose(bool disposing)
        {
            if (disposing)
            {
                foreach (var cache in _localCaches)
                {
                    cache.Dispose();
                }
                
                foreach (var cache in _sharedCaches)
                {
                    cache.Dispose();
                }
                
                _localCaches.Clear();
                _sharedCaches.Clear();
            }
        }

        public void Dispose()
        {
            Dispose(disposing: true);
            GC.SuppressFinalize(this);
        }
    }
}