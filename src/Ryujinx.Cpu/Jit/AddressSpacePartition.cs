using Ryujinx.Common;
using Ryujinx.Common.Collections;
using Ryujinx.Memory;
using System;
using System.Diagnostics;
using System.Threading;

namespace Ryujinx.Cpu.Jit
{
    readonly struct PrivateRange
    {
        public readonly MemoryBlock Memory;
        public readonly ulong Offset;
        public readonly ulong Size;

        public static PrivateRange Empty => new(null, 0, 0);

        public PrivateRange(MemoryBlock memory, ulong offset, ulong size)
        {
            Memory = memory;
            Offset = offset;
            Size = size;
        }
    }

    class AddressSpacePartition : IDisposable
    {
        private const ulong GuestPageSize = 0x1000;

        private const int DefaultBlockAlignment = 1 << 20;

        private enum MappingType : byte
        {
            None,
            Private,
        }

        private class Mapping : IntrusiveRedBlackTreeNode<Mapping>, IComparable<Mapping>
        {
            public ulong Address { get; private set; }
            public ulong Size { get; private set; }
            public ulong EndAddress => Address + Size;
            public MappingType Type { get; private set; }

            public Mapping(ulong address, ulong size, MappingType type)
            {
                Address = address;
                Size = size;
                Type = type;
            }

            public Mapping Split(ulong splitAddress)
            {
                ulong leftSize = splitAddress - Address;
                ulong rightSize = EndAddress - splitAddress;

                Mapping left = new(Address, leftSize, Type);

                Address = splitAddress;
                Size = rightSize;

                return left;
            }

            public void UpdateState(MappingType newType)
            {
                Type = newType;
            }

            public void Extend(ulong sizeDelta)
            {
                Size += sizeDelta;
            }

            public int CompareTo(Mapping other)
            {
                if (Address < other.Address)
                {
                    return -1;
                }
                else if (Address <= other.EndAddress - 1UL)
                {
                    return 0;
                }
                else
                {
                    return 1;
                }
            }
        }

        private class PrivateMapping : IntrusiveRedBlackTreeNode<PrivateMapping>, IComparable<PrivateMapping>
        {
            public ulong Address { get; private set; }
            public ulong Size { get; private set; }
            public ulong EndAddress => Address + Size;
            public PrivateMemoryAllocation PrivateAllocation { get; private set; }

            public PrivateMapping(ulong address, ulong size, PrivateMemoryAllocation privateAllocation)
            {
                Address = address;
                Size = size;
                PrivateAllocation = privateAllocation;
            }

            public PrivateMapping Split(ulong splitAddress)
            {
                ulong leftSize = splitAddress - Address;
                ulong rightSize = EndAddress - splitAddress;

                Debug.Assert(leftSize > 0);
                Debug.Assert(rightSize > 0);

                (var leftAllocation, PrivateAllocation) = PrivateAllocation.Split(leftSize);

                PrivateMapping left = new(Address, leftSize, leftAllocation);

                Address = splitAddress;
                Size = rightSize;

                return left;
            }

            public void Map(AddressSpacePartitionAllocation baseBlock, ulong baseAddress, PrivateMemoryAllocation newAllocation)
            {
                baseBlock.MapView(newAllocation.Memory, newAllocation.Offset, Address - baseAddress, Size);
                PrivateAllocation = newAllocation;
            }

            public void Unmap(AddressSpacePartitionAllocation baseBlock, ulong baseAddress)
            {
                if (PrivateAllocation.IsValid)
                {
                    baseBlock.UnmapView(PrivateAllocation.Memory, Address - baseAddress, Size);
                    PrivateAllocation.Dispose();
                }

                PrivateAllocation = default;
            }

            public void Extend(ulong sizeDelta)
            {
                Size += sizeDelta;
            }

            public int CompareTo(PrivateMapping other)
            {
                if (Address < other.Address)
                {
                    return -1;
                }
                else if (Address <= other.EndAddress - 1UL)
                {
                    return 0;
                }
                else
                {
                    return 1;
                }
            }
        }

        private readonly MemoryBlock _backingMemory;
        private readonly AddressSpacePartitionAllocation _baseMemory;
        private readonly PrivateMemoryAllocator _privateMemoryAllocator;
        private readonly IntrusiveRedBlackTree<Mapping> _mappingTree;
        private readonly IntrusiveRedBlackTree<PrivateMapping> _privateTree;
        private readonly AddressSpacePageProtections _pageProtections;

        private readonly ReaderWriterLockSlim _treeLock;

        private readonly ulong _hostPageSize;

        private ulong? _firstPagePa;
        private ulong? _lastPagePa;
        private ulong _cachedFirstPagePa;
        private ulong _cachedLastPagePa;
        private bool _hasBridgeAtEnd;
        private MemoryPermission _lastPageProtection;

        public ulong Address { get; }
        public ulong Size { get; }
        public ulong EndAddress => Address + Size;

        public AddressSpacePartition(AddressSpacePartitionAllocation baseMemory, MemoryBlock backingMemory, ulong address, ulong size)
        {
            _privateMemoryAllocator = new PrivateMemoryAllocator(DefaultBlockAlignment, MemoryAllocationFlags.Mirrorable);
            _mappingTree = new IntrusiveRedBlackTree<Mapping>();
            _privateTree = new IntrusiveRedBlackTree<PrivateMapping>();
            _pageProtections = new AddressSpacePageProtections();
            _treeLock = new ReaderWriterLockSlim();

            _mappingTree.Add(new Mapping(address, size, MappingType.None));
            _privateTree.Add(new PrivateMapping(address, size, default));

            _hostPageSize = MemoryBlock.GetPageSize();

            _backingMemory = backingMemory;
            _baseMemory = baseMemory;

            _cachedFirstPagePa = ulong.MaxValue;
            _cachedLastPagePa = ulong.MaxValue;
            _lastPageProtection = MemoryPermission.ReadAndWrite;

            Address = address;
            Size = size;
        }

        public bool IsEmpty()
        {
            _treeLock.EnterReadLock();

            try
            {
                Mapping map = _mappingTree.GetNode(new Mapping(Address, Size, MappingType.None));

                return map != null && map.Address == Address && map.Size == Size && map.Type == MappingType.None;
            }
            finally
            {
                _treeLock.ExitReadLock();
            }
        }

        public void Map(ulong va, ulong pa, ulong size)
        {
            Debug.Assert(va >= Address);
            Debug.Assert(va + size <= EndAddress);

            if (va == Address)
            {
                _firstPagePa = pa;
            }

            if (va <= EndAddress - GuestPageSize && va + size > EndAddress - GuestPageSize)
            {
                _lastPagePa = pa + ((EndAddress - GuestPageSize) - va);
            }

            Update(va, pa, size, MappingType.Private);

            _pageProtections.UpdateMappings(this, va, size);
        }

        public void Unmap(ulong va, ulong size)
        {
            Debug.Assert(va >= Address);
            Debug.Assert(va + size <= EndAddress);

            if (va == Address)
            {
                _firstPagePa = null;
            }

            if (va <= EndAddress - GuestPageSize && va + size > EndAddress - GuestPageSize)
            {
                _lastPagePa = null;
            }

            Update(va, 0UL, size, MappingType.None);

            _pageProtections.Remove(va, size);
        }

        public void ReprotectAligned(ulong va, ulong size, MemoryPermission protection)
        {
            Debug.Assert(va >= Address);
            Debug.Assert(va + size <= EndAddress);

            _baseMemory.Reprotect(va - Address, size, protection, false);

            if (va == EndAddress - _hostPageSize)
            {
                // Protections at the last page also applies to the bridge, if we have one.
                // (This is because last page access is always done on the bridge, not on our base mapping,
                // for the cases where access crosses a page boundary and reaches the non-contiguous next mapping).

                if (_hasBridgeAtEnd)
                {
                    _baseMemory.Reprotect(Size, size, protection, false);
                }

                _lastPageProtection = protection;
            }
        }

        public void Reprotect(
            ulong va,
            ulong size,
            MemoryPermission protection,
            AddressSpacePartitionAllocator asAllocator,
            AddressSpacePartitioned addressSpace,
            Action<ulong, IntPtr, ulong> updatePtCallback)
        {
            ulong endVa = va + size;

            _pageProtections.Reprotect(asAllocator, addressSpace, this, va, endVa, protection, updatePtCallback);
        }

        public IntPtr GetPointer(ulong va, ulong size)
        {
            Debug.Assert(va >= Address);
            Debug.Assert(va + size <= EndAddress);

            if (va >= EndAddress - _hostPageSize && _hasBridgeAtEnd)
            {
                return _baseMemory.GetPointer(Size + va - (EndAddress - _hostPageSize), size);
            }

            return _baseMemory.GetPointer(va - Address, size);
        }

        public void InsertBridgeAtEnd(AddressSpacePartition partitionAfter, Action<ulong, IntPtr, ulong> updatePtCallback)
        {
            ulong firstPagePa = partitionAfter._firstPagePa.HasValue ? partitionAfter._firstPagePa.Value : ulong.MaxValue;
            ulong lastPagePa = _lastPagePa.HasValue ? _lastPagePa.Value : ulong.MaxValue;

            if (firstPagePa != _cachedFirstPagePa || lastPagePa != _cachedLastPagePa)
            {
                if (partitionAfter._firstPagePa.HasValue && _lastPagePa.HasValue)
                {
                    (MemoryBlock firstPageMemory, ulong firstPageOffset) = partitionAfter.GetFirstPageMemoryAndOffset();
                    (MemoryBlock lastPageMemory, ulong lastPageOffset) = GetLastPageMemoryAndOffset();

                    _baseMemory.MapView(lastPageMemory, lastPageOffset, Size, _hostPageSize);
                    _baseMemory.MapView(firstPageMemory, firstPageOffset, Size + _hostPageSize, _hostPageSize);

                    _baseMemory.Reprotect(Size, _hostPageSize, _lastPageProtection, false);

                    updatePtCallback(EndAddress - _hostPageSize, _baseMemory.GetPointer(Size, _hostPageSize), _hostPageSize);

                    _hasBridgeAtEnd = true;

                    _pageProtections.UpdateMappings(partitionAfter, EndAddress, GuestPageSize);
                }
                else
                {
                    if (_lastPagePa.HasValue)
                    {
                        (MemoryBlock lastPageMemory, ulong lastPageOffset) = GetLastPageMemoryAndOffset();

                        updatePtCallback(EndAddress - _hostPageSize, lastPageMemory.GetPointer(lastPageOffset, _hostPageSize), _hostPageSize);
                    }

                    _hasBridgeAtEnd = false;

                    _pageProtections.Remove(EndAddress, GuestPageSize);
                }

                _cachedFirstPagePa = firstPagePa;
                _cachedLastPagePa = lastPagePa;
            }
        }

        public void RemoveBridgeFromEnd(Action<ulong, IntPtr, ulong> updatePtCallback)
        {
            if (_lastPagePa.HasValue)
            {
                (MemoryBlock lastPageMemory, ulong lastPageOffset) = GetLastPageMemoryAndOffset();

                updatePtCallback(EndAddress - _hostPageSize, lastPageMemory.GetPointer(lastPageOffset, _hostPageSize), _hostPageSize);
            }

            _cachedFirstPagePa = ulong.MaxValue;
            _cachedLastPagePa = ulong.MaxValue;

            _hasBridgeAtEnd = false;

            _pageProtections.Remove(EndAddress, GuestPageSize);
        }

        private (MemoryBlock, ulong) GetFirstPageMemoryAndOffset()
        {
            _treeLock.EnterReadLock();

            try
            {
                PrivateMapping map = _privateTree.GetNode(new PrivateMapping(Address, 1UL, default));

                if (map != null && map.PrivateAllocation.IsValid)
                {
                    return (map.PrivateAllocation.Memory, map.PrivateAllocation.Offset + (Address - map.Address));
                }
            }
            finally
            {
                _treeLock.ExitReadLock();
            }

            return (_backingMemory, _firstPagePa.Value);
        }

        private (MemoryBlock, ulong) GetLastPageMemoryAndOffset()
        {
            _treeLock.EnterReadLock();

            try
            {
                ulong pageAddress = EndAddress - _hostPageSize;

                PrivateMapping map = _privateTree.GetNode(new PrivateMapping(pageAddress, 1UL, default));

                if (map != null && map.PrivateAllocation.IsValid)
                {
                    return (map.PrivateAllocation.Memory, map.PrivateAllocation.Offset + (pageAddress - map.Address));
                }
            }
            finally
            {
                _treeLock.ExitReadLock();
            }

            return (_backingMemory, _lastPagePa.Value & ~(_hostPageSize - 1));
        }

        public PrivateRange GetPrivateAllocation(ulong va)
        {
            _treeLock.EnterReadLock();

            try
            {
                PrivateMapping map = _privateTree.GetNode(new PrivateMapping(va, 1UL, default));

                if (map != null && map.PrivateAllocation.IsValid)
                {
                    return new(map.PrivateAllocation.Memory, map.PrivateAllocation.Offset + (va - map.Address), map.Size - (va - map.Address));
                }
            }
            finally
            {
                _treeLock.ExitReadLock();
            }

            return PrivateRange.Empty;
        }

        private void Update(ulong va, ulong pa, ulong size, MappingType type)
        {
            _treeLock.EnterWriteLock();

            try
            {
                Mapping map = _mappingTree.GetNode(new Mapping(va, 1UL, MappingType.None));

                Update(map, va, pa, size, type);
            }
            finally
            {
                _treeLock.ExitWriteLock();
            }
        }

        private Mapping Update(Mapping map, ulong va, ulong pa, ulong size, MappingType type)
        {
            ulong endAddress = va + size;

            for (; map != null; map = map.Successor)
            {
                if (map.Address < va)
                {
                    _mappingTree.Add(map.Split(va));
                }

                if (map.EndAddress > endAddress)
                {
                    Mapping newMap = map.Split(endAddress);
                    _mappingTree.Add(newMap);
                    map = newMap;
                }

                switch (type)
                {
                    case MappingType.None:
                        ulong alignment = MemoryBlock.GetPageSize();

                        bool unmappedBefore = map.Predecessor == null ||
                            (map.Predecessor.Type == MappingType.None && map.Predecessor.Address <= BitUtils.AlignDown(va, alignment));

                        bool unmappedAfter = map.Successor == null ||
                            (map.Successor.Type == MappingType.None && map.Successor.EndAddress >= BitUtils.AlignUp(endAddress, alignment));

                        UnmapPrivate(va, size, unmappedBefore, unmappedAfter);
                        break;
                    case MappingType.Private:
                        MapPrivate(va, size);
                        break;
                }

                map.UpdateState(type);
                map = TryCoalesce(map);

                if (map.EndAddress >= endAddress)
                {
                    break;
                }
            }

            return map;
        }

        private Mapping TryCoalesce(Mapping map)
        {
            Mapping previousMap = map.Predecessor;
            Mapping nextMap = map.Successor;

            if (previousMap != null && CanCoalesce(previousMap, map))
            {
                previousMap.Extend(map.Size);
                _mappingTree.Remove(map);
                map = previousMap;
            }

            if (nextMap != null && CanCoalesce(map, nextMap))
            {
                map.Extend(nextMap.Size);
                _mappingTree.Remove(nextMap);
            }

            return map;
        }

        private static bool CanCoalesce(Mapping left, Mapping right)
        {
            return left.Type == right.Type;
        }

        private void MapPrivate(ulong va, ulong size)
        {
            ulong endAddress = va + size;

            ulong alignment = MemoryBlock.GetPageSize();

            // Expand the range outwards based on page size to ensure that at least the requested region is mapped.
            ulong vaAligned = BitUtils.AlignDown(va, alignment);
            ulong endAddressAligned = BitUtils.AlignUp(endAddress, alignment);

            PrivateMapping map = _privateTree.GetNode(new PrivateMapping(va, 1UL, default));

            for (; map != null; map = map.Successor)
            {
                if (!map.PrivateAllocation.IsValid)
                {
                    if (map.Address < vaAligned)
                    {
                        _privateTree.Add(map.Split(vaAligned));
                    }

                    if (map.EndAddress > endAddressAligned)
                    {
                        PrivateMapping newMap = map.Split(endAddressAligned);
                        _privateTree.Add(newMap);
                        map = newMap;
                    }

                    map.Map(_baseMemory, Address, _privateMemoryAllocator.Allocate(map.Size, MemoryBlock.GetPageSize()));
                }

                if (map.EndAddress >= endAddressAligned)
                {
                    break;
                }
            }
        }

        private void UnmapPrivate(ulong va, ulong size, bool unmappedBefore, bool unmappedAfter)
        {
            ulong endAddress = va + size;

            ulong alignment = MemoryBlock.GetPageSize();

            // If the adjacent mappings are unmapped, expand the range outwards,
            // otherwise shrink it inwards. We must ensure we won't unmap pages that might still be in use.
            ulong vaAligned = unmappedBefore ? BitUtils.AlignDown(va, alignment) : BitUtils.AlignUp(va, alignment);
            ulong endAddressAligned = unmappedAfter ? BitUtils.AlignUp(endAddress, alignment) : BitUtils.AlignDown(endAddress, alignment);

            if (endAddressAligned <= vaAligned)
            {
                return;
            }

            PrivateMapping map = _privateTree.GetNode(new PrivateMapping(vaAligned, 1UL, default));

            for (; map != null; map = map.Successor)
            {
                if (map.PrivateAllocation.IsValid)
                {
                    if (map.Address < vaAligned)
                    {
                        _privateTree.Add(map.Split(vaAligned));
                    }

                    if (map.EndAddress > endAddressAligned)
                    {
                        PrivateMapping newMap = map.Split(endAddressAligned);
                        _privateTree.Add(newMap);
                        map = newMap;
                    }

                    map.Unmap(_baseMemory, Address);
                    map = TryCoalesce(map);
                }

                if (map.EndAddress >= endAddressAligned)
                {
                    break;
                }
            }
        }

        private PrivateMapping TryCoalesce(PrivateMapping map)
        {
            PrivateMapping previousMap = map.Predecessor;
            PrivateMapping nextMap = map.Successor;

            if (previousMap != null && CanCoalesce(previousMap, map))
            {
                previousMap.Extend(map.Size);
                _privateTree.Remove(map);
                map = previousMap;
            }

            if (nextMap != null && CanCoalesce(map, nextMap))
            {
                map.Extend(nextMap.Size);
                _privateTree.Remove(nextMap);
            }

            return map;
        }

        private static bool CanCoalesce(PrivateMapping left, PrivateMapping right)
        {
            return !left.PrivateAllocation.IsValid && !right.PrivateAllocation.IsValid;
        }

        public PrivateRange GetFirstPrivateAllocation(ulong va, ulong size, out ulong nextVa)
        {
            _treeLock.EnterReadLock();

            try
            {
                PrivateMapping map = _privateTree.GetNode(new PrivateMapping(va, 1UL, default));

                nextVa = map.EndAddress;

                if (map != null && map.PrivateAllocation.IsValid)
                {
                    ulong startOffset = va - map.Address;

                    return new(
                        map.PrivateAllocation.Memory,
                        map.PrivateAllocation.Offset + startOffset,
                        Math.Min(map.PrivateAllocation.Size - startOffset, size));
                }
            }
            finally
            {
                _treeLock.ExitReadLock();
            }

            return PrivateRange.Empty;
        }

        public bool HasPrivateAllocation(ulong va, ulong size, ulong startVa, ulong startSize, ref PrivateRange range)
        {
            _treeLock.EnterReadLock();

            try
            {
                PrivateMapping map = _privateTree.GetNode(new PrivateMapping(va, size, default));

                if (map != null && map.PrivateAllocation.IsValid)
                {
                    if (map.Address <= startVa && map.EndAddress >= startVa + startSize)
                    {
                        ulong startOffset = startVa - map.Address;

                        range = new(
                            map.PrivateAllocation.Memory,
                            map.PrivateAllocation.Offset + startOffset,
                            Math.Min(map.PrivateAllocation.Size - startOffset, startSize));
                    }

                    return true;
                }
            }
            finally
            {
                _treeLock.ExitReadLock();
            }

            return false;
        }

        public void Dispose()
        {
            GC.SuppressFinalize(this);

            _privateMemoryAllocator.Dispose();
            _pageProtections.Dispose();
            _baseMemory.Dispose();
        }
    }
}
