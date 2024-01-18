using Ryujinx.Common;
using Ryujinx.Memory;
using Ryujinx.Memory.Tracking;
using System;
using System.Collections.Generic;
using System.Diagnostics;

namespace Ryujinx.Cpu.Jit
{
    class AddressSpacePartitioned : IDisposable
    {
        public static readonly bool Use4KBProtection = false;

        private const int PartitionBits = 25;
        private const ulong PartitionSize = 1UL << PartitionBits;

        private readonly MemoryBlock _backingMemory;
        private readonly List<AddressSpacePartition> _partitions;
        private readonly AddressSpacePartitionAllocator _asAllocator;
        private readonly Action<ulong, IntPtr, ulong> _updatePtCallback;

        public AddressSpacePartitioned(MemoryTracking tracking, MemoryBlock backingMemory, Action<ulong, IntPtr, ulong> updatePtCallback)
        {
            _backingMemory = backingMemory;
            _partitions = new();
            _asAllocator = new(tracking, _partitions);
            _updatePtCallback = updatePtCallback;
        }

        public void Map(ulong va, ulong pa, ulong size)
        {
            ulong endVa = va + size;

            lock (_partitions)
            {
                EnsurePartitionsLocked(va, size);

                while (va < endVa)
                {
                    int partitionIndex = FindPartitionIndexLocked(va);
                    AddressSpacePartition partition = _partitions[partitionIndex];

                    (ulong clampedVa, ulong clampedEndVa) = ClampRange(partition, va, endVa);

                    partition.Map(clampedVa, pa, clampedEndVa - clampedVa);

                    ulong currentSize = clampedEndVa - clampedVa;

                    va += currentSize;
                    pa += currentSize;

                    InsertBridgeIfNeeded(partitionIndex);
                }
            }
        }

        public void Unmap(ulong va, ulong size)
        {
            ulong endVa = va + size;

            while (va < endVa)
            {
                AddressSpacePartition partition;

                lock (_partitions)
                {
                    int partitionIndex = FindPartitionIndexLocked(va);
                    if (partitionIndex < 0)
                    {
                        va += PartitionSize - (va & (PartitionSize - 1));

                        continue;
                    }

                    partition = _partitions[partitionIndex];

                    (ulong clampedVa, ulong clampedEndVa) = ClampRange(partition, va, endVa);

                    partition.Unmap(clampedVa, clampedEndVa - clampedVa);

                    va += clampedEndVa - clampedVa;

                    RemoveBridgeIfNeeded(partitionIndex);

                    if (partition.IsEmpty())
                    {
                        _partitions.Remove(partition);
                        partition.Dispose();
                    }
                }
            }
        }

        public void Reprotect(ulong va, ulong size, MemoryPermission protection)
        {
            ulong endVa = va + size;

            if (Use4KBProtection)
            {
                lock (_partitions)
                {
                    while (va < endVa)
                    {
                        AddressSpacePartition partition = FindPartition(va);

                        if (partition == null)
                        {
                            va += PartitionSize - (va & (PartitionSize - 1));

                            continue;
                        }

                        (ulong clampedVa, ulong clampedEndVa) = ClampRange(partition, va, endVa);

                        partition.Reprotect(clampedVa, clampedEndVa - clampedVa, protection, _asAllocator, this, _updatePtCallback);

                        va += clampedEndVa - clampedVa;
                    }
                }
            }
            else
            {
                while (va < endVa)
                {
                    AddressSpacePartition partition = FindPartition(va);

                    if (partition == null)
                    {
                        va += PartitionSize - (va & (PartitionSize - 1));

                        continue;
                    }

                    (ulong clampedVa, ulong clampedEndVa) = ClampRange(partition, va, endVa);

                    partition.ReprotectAligned(clampedVa, clampedEndVa - clampedVa, protection);

                    va += clampedEndVa - clampedVa;
                }
            }
        }

        public PrivateRange GetPrivateAllocation(ulong va)
        {
            AddressSpacePartition partition = FindPartition(va);

            if (partition == null)
            {
                return PrivateRange.Empty;
            }

            return partition.GetPrivateAllocation(va);
        }

        public PrivateRange GetFirstPrivateAllocation(ulong va, ulong size, out ulong nextVa)
        {
            AddressSpacePartition partition = FindPartition(va);

            if (partition == null)
            {
                nextVa = (va & ~(PartitionSize - 1)) + PartitionSize;

                return PrivateRange.Empty;
            }

            return partition.GetFirstPrivateAllocation(va, size, out nextVa);
        }

        public bool HasAnyPrivateAllocation(ulong va, ulong size, out PrivateRange range)
        {
            range = PrivateRange.Empty;

            ulong startVa = va;
            ulong endVa = va + size;

            while (va < endVa)
            {
                AddressSpacePartition partition = FindPartition(va);

                if (partition == null)
                {
                    va += PartitionSize - (va & (PartitionSize - 1));

                    continue;
                }

                (ulong clampedVa, ulong clampedEndVa) = ClampRange(partition, va, endVa);

                if (partition.HasPrivateAllocation(clampedVa, clampedEndVa - clampedVa, startVa, size, ref range))
                {
                    return true;
                }

                va += clampedEndVa - clampedVa;
            }

            return false;
        }

        private void InsertBridgeIfNeeded(int partitionIndex)
        {
            if (partitionIndex > 0 && _partitions[partitionIndex - 1].EndAddress == _partitions[partitionIndex].Address)
            {
                _partitions[partitionIndex - 1].InsertBridgeAtEnd(_partitions[partitionIndex], _updatePtCallback);
            }

            if (partitionIndex + 1 < _partitions.Count && _partitions[partitionIndex].EndAddress == _partitions[partitionIndex + 1].Address)
            {
                _partitions[partitionIndex].InsertBridgeAtEnd(_partitions[partitionIndex + 1], _updatePtCallback);
            }
        }

        private void RemoveBridgeIfNeeded(int partitionIndex)
        {
            if (partitionIndex > 0 && _partitions[partitionIndex - 1].EndAddress == _partitions[partitionIndex].Address)
            {
                _partitions[partitionIndex - 1].InsertBridgeAtEnd(_partitions[partitionIndex], _updatePtCallback);
            }

            if (partitionIndex + 1 < _partitions.Count && _partitions[partitionIndex].EndAddress == _partitions[partitionIndex + 1].Address)
            {
                _partitions[partitionIndex].InsertBridgeAtEnd(_partitions[partitionIndex + 1], _updatePtCallback);
            }
            else
            {
                _partitions[partitionIndex].RemoveBridgeFromEnd(_updatePtCallback);
            }
        }

        public IntPtr GetPointer(ulong va, ulong size)
        {
            AddressSpacePartition partition = FindPartition(va);

            return partition.GetPointer(va, size);
        }

        private static (ulong, ulong) ClampRange(AddressSpacePartition partition, ulong va, ulong endVa)
        {
            if (va < partition.Address)
            {
                va = partition.Address;
            }

            if (endVa > partition.EndAddress)
            {
                endVa = partition.EndAddress;
            }

            return (va, endVa);
        }

        private AddressSpacePartition FindPartition(ulong va)
        {
            lock (_partitions)
            {
                int index = FindPartitionIndexLocked(va);
                if (index >= 0)
                {
                    return _partitions[index];
                }
            }

            return null;
        }

        private int FindPartitionIndexLocked(ulong va)
        {
            int left = 0;
            int middle;
            int right = _partitions.Count - 1;

            while (left <= right)
            {
                middle = left + ((right - left) >> 1);

                AddressSpacePartition partition = _partitions[middle];

                if (partition.Address <= va && partition.EndAddress > va)
                {
                    return middle;
                }

                if (partition.Address >= va)
                {
                    right = middle - 1;
                }
                else
                {
                    left = middle + 1;
                }
            }

            return -1;
        }

        private void EnsurePartitionsLocked(ulong va, ulong size)
        {
            ulong endVa = BitUtils.AlignUp(va + size, PartitionSize);
            va = BitUtils.AlignDown(va, PartitionSize);

            for (int i = 0; i < _partitions.Count && va < endVa; i++)
            {
                AddressSpacePartition partition = _partitions[i];

                if (partition.Address <= va && partition.EndAddress > va)
                {
                    if (partition.EndAddress >= endVa)
                    {
                        // Fully mapped already.
                        va = endVa;

                        break;
                    }

                    ulong gapSize;

                    if (i + 1 < _partitions.Count)
                    {
                        AddressSpacePartition nextPartition = _partitions[i + 1];

                        if (partition.EndAddress == nextPartition.Address)
                        {
                            va = partition.EndAddress;

                            continue;
                        }

                        gapSize = Math.Min(endVa, nextPartition.Address) - partition.EndAddress;
                    }
                    else
                    {
                        gapSize = endVa - partition.EndAddress;
                    }

                    _partitions.Insert(i + 1, new(CreateAsPartitionAllocation(partition.EndAddress, gapSize), _backingMemory, partition.EndAddress, gapSize));
                    va = partition.EndAddress + gapSize;
                    i++;
                }
                else if (partition.EndAddress > va)
                {
                    Debug.Assert(partition.Address > va);

                    ulong gapSize;

                    if (partition.Address < endVa)
                    {
                        gapSize = partition.Address - va;
                    }
                    else
                    {
                        gapSize = endVa - va;
                    }

                    _partitions.Insert(i, new(CreateAsPartitionAllocation(va, gapSize), _backingMemory, va, gapSize));
                    va = Math.Min(partition.EndAddress, endVa);
                    i++;
                }
            }

            if (va < endVa)
            {
                _partitions.Add(new(CreateAsPartitionAllocation(va, endVa - va), _backingMemory, va, endVa - va));
            }

            for (int i = 1; i < _partitions.Count; i++)
            {
                Debug.Assert(_partitions[i].Address > _partitions[i - 1].Address);
                Debug.Assert(_partitions[i].EndAddress > _partitions[i - 1].EndAddress);
            }
        }

        private AddressSpacePartitionAllocation CreateAsPartitionAllocation(ulong va, ulong size)
        {
            ulong bridgeSize = MemoryBlock.GetPageSize() * 2;

            return _asAllocator.Allocate(va, size, (int)bridgeSize);
        }

        protected virtual void Dispose(bool disposing)
        {
            if (disposing)
            {
                foreach (AddressSpacePartition partition in _partitions)
                {
                    partition.Dispose();
                }

                _partitions.Clear();
                _asAllocator.Dispose();
            }
        }

        public void Dispose()
        {
            Dispose(disposing: true);
            GC.SuppressFinalize(this);
        }
    }
}