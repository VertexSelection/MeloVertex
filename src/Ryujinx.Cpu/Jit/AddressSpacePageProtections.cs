using Ryujinx.Common;
using Ryujinx.Common.Collections;
using Ryujinx.Memory;
using System;
using System.Diagnostics;

namespace Ryujinx.Cpu.Jit
{
    class AddressSpacePageProtections : IDisposable
    {
        private const ulong GuestPageSize = 0x1000;

        class PageProtection : IntrusiveRedBlackTreeNode<PageProtection>, IComparable<PageProtection>
        {
            public readonly AddressSpacePartitionAllocation Memory;
            public readonly ulong Offset;
            public readonly ulong Address;
            public readonly ulong Size;

            private MemoryBlock _viewBlock;

            public bool IsMapped => _viewBlock != null;

            public PageProtection(AddressSpacePartitionAllocation memory, ulong offset, ulong address, ulong size)
            {
                Memory = memory;
                Offset = offset;
                Address = address;
                Size = size;
            }

            public void SetViewBlock(MemoryBlock block)
            {
                _viewBlock = block;
            }

            public void Unmap()
            {
                if (_viewBlock != null)
                {
                    Memory.UnmapView(_viewBlock, Offset, MemoryBlock.GetPageSize());
                    _viewBlock = null;
                }
            }

            public bool OverlapsWith(ulong va, ulong size)
            {
                return Address < va + size && va < Address + Size;
            }

            public int CompareTo(PageProtection other)
            {
                if (OverlapsWith(other.Address, other.Size))
                {
                    return 0;
                }
                else if (Address < other.Address)
                {
                    return -1;
                }
                else
                {
                    return 1;
                }
            }
        }

        private readonly IntrusiveRedBlackTree<PageProtection> _protectionTree;

        public AddressSpacePageProtections()
        {
            _protectionTree = new();
        }

        public void Reprotect(
            AddressSpacePartitionAllocator asAllocator,
            AddressSpacePartitioned addressSpace,
            AddressSpacePartition partition,
            ulong va,
            ulong endVa,
            MemoryPermission protection,
            Action<ulong, IntPtr, ulong> updatePtCallback)
        {
            while (va < endVa)
            {
                ReprotectPage(asAllocator, addressSpace, partition, va, protection, updatePtCallback);

                va += GuestPageSize;
            }
        }

        private void ReprotectPage(
            AddressSpacePartitionAllocator asAllocator,
            AddressSpacePartitioned addressSpace,
            AddressSpacePartition partition,
            ulong va,
            MemoryPermission protection,
            Action<ulong, IntPtr, ulong> updatePtCallback)
        {
            ulong pageSize = MemoryBlock.GetPageSize();

            PageProtection pageProtection = _protectionTree.GetNode(new PageProtection(default, 0, va, 1));

            if (pageProtection == null)
            {
                ulong firstPage = BitUtils.AlignDown(va, pageSize);
                ulong lastPage = BitUtils.AlignUp(va + GuestPageSize, pageSize) - GuestPageSize;

                AddressSpacePartitionAllocation block;
                PageProtection adjPageProtection = null;
                ulong blockOffset = 0;

                if (va == firstPage && va > partition.Address)
                {
                    block = asAllocator.AllocatePage(firstPage - pageSize, pageSize * 2);

                    MapView(addressSpace, partition, block, 0, pageSize, va - GuestPageSize, out MemoryBlock adjMemory);

                    adjPageProtection = new PageProtection(block, 0, va - GuestPageSize, GuestPageSize);
                    adjPageProtection.SetViewBlock(adjMemory);
                    blockOffset = pageSize;
                }
                else if (va == lastPage)
                {
                    block = asAllocator.AllocatePage(firstPage, pageSize * 2);

                    MapView(addressSpace, partition, block, pageSize, pageSize, va + GuestPageSize, out MemoryBlock adjMemory);

                    adjPageProtection = new PageProtection(block, pageSize, va + GuestPageSize, GuestPageSize);
                    adjPageProtection.SetViewBlock(adjMemory);
                }
                else
                {
                    block = asAllocator.AllocatePage(firstPage, pageSize);
                }

                if (!MapView(addressSpace, partition, block, blockOffset, pageSize, va, out MemoryBlock viewMemory))
                {
                    block.Dispose();

                    return;
                }

                pageProtection = new PageProtection(block, blockOffset, va, GuestPageSize);
                pageProtection.SetViewBlock(viewMemory);
                _protectionTree.Add(pageProtection);

                if (adjPageProtection != null)
                {
                    Debug.Assert(_protectionTree.GetNode(adjPageProtection) == null);
                    _protectionTree.Add(adjPageProtection);
                }
            }

            Debug.Assert(pageProtection.IsMapped || partition.GetPrivateAllocation(va).Memory == null);

            pageProtection.Memory.Reprotect(pageProtection.Offset, pageSize, protection, false);

            updatePtCallback(va, pageProtection.Memory.GetPointer(pageProtection.Offset + (va & (pageSize - 1)), GuestPageSize), GuestPageSize);
        }

        public void UpdateMappings(AddressSpacePartition partition, ulong va, ulong size)
        {
            ulong pageSize = MemoryBlock.GetPageSize();

            PageProtection pageProtection = GetLowestOverlap(va, size);

            while (pageProtection != null)
            {
                if (pageProtection.Address >= va + size)
                {
                    break;
                }

                bool mapped = MapView(
                    partition,
                    pageProtection.Memory,
                    pageProtection.Offset,
                    pageSize,
                    pageProtection.Address,
                    out MemoryBlock memory);

                Debug.Assert(mapped);

                pageProtection.SetViewBlock(memory);
                pageProtection = pageProtection.Successor;
            }
        }

        public void Remove(ulong va, ulong size)
        {
            ulong pageSize = MemoryBlock.GetPageSize();

            PageProtection pageProtection = GetLowestOverlap(va, size);

            while (pageProtection != null)
            {
                if (pageProtection.Address >= va + size)
                {
                    break;
                }

                ulong firstPage = BitUtils.AlignDown(pageProtection.Address, pageSize);
                ulong lastPage = BitUtils.AlignUp(pageProtection.Address + GuestPageSize, pageSize) - GuestPageSize;

                bool canDelete;

                if (pageProtection.Address == firstPage)
                {
                    canDelete = pageProtection.Predecessor == null ||
                        pageProtection.Predecessor.Address + pageProtection.Predecessor.Size != pageProtection.Address ||
                        !pageProtection.Predecessor.IsMapped;
                }
                else if (pageProtection.Address == lastPage)
                {
                    canDelete = pageProtection.Successor == null ||
                        pageProtection.Address + pageProtection.Size != pageProtection.Successor.Address ||
                        !pageProtection.Successor.IsMapped;
                }
                else
                {
                    canDelete = true;
                }

                PageProtection successor = pageProtection.Successor;

                if (canDelete)
                {
                    if (pageProtection.Address == firstPage &&
                        pageProtection.Predecessor != null &&
                        pageProtection.Predecessor.Address + pageProtection.Predecessor.Size == pageProtection.Address)
                    {
                        _protectionTree.Remove(pageProtection.Predecessor);
                    }
                    else if (pageProtection.Address == lastPage &&
                        pageProtection.Successor != null &&
                        pageProtection.Address + pageProtection.Size == pageProtection.Successor.Address)
                    {
                        successor = successor.Successor;
                        _protectionTree.Remove(pageProtection.Successor);
                    }

                    _protectionTree.Remove(pageProtection);
                    pageProtection.Memory.Dispose();
                }
                else
                {
                    pageProtection.Unmap();
                }

                pageProtection = successor;
            }
        }

        private static bool MapView(
            AddressSpacePartitioned addressSpace,
            AddressSpacePartition partition,
            AddressSpacePartitionAllocation dstBlock,
            ulong dstOffset,
            ulong size,
            ulong va,
            out MemoryBlock memory)
        {
            PrivateRange privateRange;

            if (va >= partition.Address && va < partition.EndAddress)
            {
                privateRange = partition.GetPrivateAllocation(va);
            }
            else
            {
                privateRange = addressSpace.GetPrivateAllocation(va);
            }

            memory = privateRange.Memory;

            if (privateRange.Memory == null)
            {
                return false;
            }

            dstBlock.MapView(privateRange.Memory, privateRange.Offset & ~(MemoryBlock.GetPageSize() - 1), dstOffset, size);

            return true;
        }

        private static bool MapView(
            AddressSpacePartition partition,
            AddressSpacePartitionAllocation dstBlock,
            ulong dstOffset,
            ulong size,
            ulong va,
            out MemoryBlock memory)
        {
            Debug.Assert(va >= partition.Address && va < partition.EndAddress);

            PrivateRange privateRange = partition.GetPrivateAllocation(va);

            memory = privateRange.Memory;

            if (privateRange.Memory == null)
            {
                return false;
            }

            dstBlock.MapView(privateRange.Memory, privateRange.Offset & ~(size - 1), dstOffset, size);

            return true;
        }

        private PageProtection GetLowestOverlap(ulong va, ulong size)
        {
            PageProtection pageProtection = _protectionTree.GetNode(new PageProtection(default, 0, va, size));

            if (pageProtection == null)
            {
                return null;
            }

            while (pageProtection.Predecessor != null && pageProtection.Predecessor.OverlapsWith(va, size))
            {
                pageProtection = pageProtection.Predecessor;
            }

            return pageProtection;
        }

        protected virtual void Dispose(bool disposing)
        {
            Remove(0, ulong.MaxValue);
            Debug.Assert(_protectionTree.Count == 0);
        }

        public void Dispose()
        {
            Dispose(disposing: true);
            GC.SuppressFinalize(this);
        }
    }
}