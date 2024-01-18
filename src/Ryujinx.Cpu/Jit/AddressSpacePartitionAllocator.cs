using Ryujinx.Common.Collections;
using Ryujinx.Memory;
using Ryujinx.Memory.Tracking;
using System;

namespace Ryujinx.Cpu.Jit
{
    readonly struct AddressSpacePartitionAllocation : IDisposable
    {
        private readonly AddressSpacePartitionAllocator _owner;
        private readonly PrivateMemoryAllocatorImpl<AddressSpacePartitionAllocator.Block>.Allocation _allocation;

        public IntPtr Pointer => (IntPtr)((ulong)_allocation.Block.Memory.Pointer + _allocation.Offset);

        public AddressSpacePartitionAllocation(
            AddressSpacePartitionAllocator owner,
            PrivateMemoryAllocatorImpl<AddressSpacePartitionAllocator.Block>.Allocation allocation)
        {
            _owner = owner;
            _allocation = allocation;
        }

        public void RegisterMapping(ulong va, ulong endVa, int bridgeSize)
        {
            _allocation.Block.AddMapping(_allocation.Offset, _allocation.Size, va, endVa, bridgeSize);
        }

        public void MapView(MemoryBlock srcBlock, ulong srcOffset, ulong dstOffset, ulong size)
        {
            _allocation.Block.Memory.MapView(srcBlock, srcOffset, _allocation.Offset + dstOffset, size);
        }

        public void UnmapView(MemoryBlock srcBlock, ulong offset, ulong size)
        {
            _allocation.Block.Memory.UnmapView(srcBlock, _allocation.Offset + offset, size);
        }

        public void Reprotect(ulong offset, ulong size, MemoryPermission permission, bool throwOnFail)
        {
            _allocation.Block.Memory.Reprotect(_allocation.Offset + offset, size, permission, throwOnFail);
        }

        public IntPtr GetPointer(ulong offset, ulong size)
        {
            return _allocation.Block.Memory.GetPointer(_allocation.Offset + offset, size);
        }

        public void Dispose()
        {
            _allocation.Block.RemoveMapping(_allocation.Offset, _allocation.Size);
            _owner.Free(_allocation.Block, _allocation.Offset, _allocation.Size);
        }
    }

    class AddressSpacePartitionAllocator : PrivateMemoryAllocatorImpl<AddressSpacePartitionAllocator.Block>
    {
        private const ulong DefaultBlockAlignment = 1UL << 32; // 4GB

        public class Block : PrivateMemoryAllocator.Block
        {
            private readonly MemoryTracking _tracking;
            private readonly MemoryEhMeilleure _memoryEh;

            private class Mapping : IntrusiveRedBlackTreeNode<Mapping>, IComparable<Mapping>
            {
                public ulong Address { get; }
                public ulong Size { get; }
                public ulong EndAddress => Address + Size;
                public ulong Va { get; }
                public ulong EndVa { get; }
                public int BridgeSize { get; }

                public Mapping(ulong address, ulong size, ulong va, ulong endVa, int bridgeSize)
                {
                    Address = address;
                    Size = size;
                    Va = va;
                    EndVa = endVa;
                    BridgeSize = bridgeSize;
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

            private readonly IntrusiveRedBlackTree<Mapping> _mappingTree;
            private readonly object _lock;

            public Block(MemoryTracking tracking, MemoryBlock memory, ulong size, object locker) : base(memory, size)
            {
                _tracking = tracking;
                _memoryEh = new(memory, null, tracking, VirtualMemoryEvent);
                _mappingTree = new();
                _lock = locker;
            }

            public void AddMapping(ulong offset, ulong size, ulong va, ulong endVa, int bridgeSize)
            {
                _mappingTree.Add(new(offset, size, va, endVa, bridgeSize));
            }

            public void RemoveMapping(ulong offset, ulong size)
            {
                _mappingTree.Remove(_mappingTree.GetNode(new Mapping(offset, size, 0, 0, 0)));
            }

            private bool VirtualMemoryEvent(ulong address, ulong size, bool write)
            {
                Mapping map;

                lock (_lock)
                {
                    map = _mappingTree.GetNode(new Mapping(address, size, 0, 0, 0));
                }

                if (map == null)
                {
                    return false;
                }

                address -= map.Address;

                if (address >= (map.EndVa - map.Va))
                {
                    address -= (ulong)(map.BridgeSize / 2);
                }

                return _tracking.VirtualMemoryEvent(map.Va + address, size, write);
            }

            public override void Destroy()
            {
                _memoryEh.Dispose();

                base.Destroy();
            }
        }

        private readonly MemoryTracking _tracking;
        private readonly object _lock;

        public AddressSpacePartitionAllocator(MemoryTracking tracking, object locker) : base(DefaultBlockAlignment, MemoryAllocationFlags.Reserve | MemoryAllocationFlags.ViewCompatible)
        {
            _tracking = tracking;
            _lock = locker;
        }

        public AddressSpacePartitionAllocation Allocate(ulong va, ulong size, int bridgeSize)
        {
            AddressSpacePartitionAllocation allocation = new(this, Allocate(size + (ulong)bridgeSize, MemoryBlock.GetPageSize(), CreateBlock));
            allocation.RegisterMapping(va, va + size, bridgeSize);

            return allocation;
        }

        public AddressSpacePartitionAllocation AllocatePage(ulong va, ulong size)
        {
            AddressSpacePartitionAllocation allocation = new(this, Allocate(size, MemoryBlock.GetPageSize(), CreateBlock));
            allocation.RegisterMapping(va, va + size, 0);

            return allocation;
        }

        private Block CreateBlock(MemoryBlock memory, ulong size)
        {
            return new Block(_tracking, memory, size, _lock);
        }
    }
}