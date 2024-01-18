using ARMeilleure.Memory;
using Ryujinx.Memory;
using Ryujinx.Memory.Range;
using Ryujinx.Memory.Tracking;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;
using System.Threading;

namespace Ryujinx.Cpu.Jit
{
    /// <summary>
    /// Represents a CPU memory manager which maps guest virtual memory directly onto a host virtual region.
    /// </summary>
    public sealed class MemoryManagerHostTracked : MemoryManagerBase, IWritableBlock, IMemoryManager, IVirtualMemoryManagerTracked
    {
        public const int PageBits = 12;
        public const int PageSize = 1 << PageBits;
        public const int PageMask = PageSize - 1;

        public const int PageToPteShift = 5; // 32 pages (2 bits each) in one ulong page table entry.
        public const ulong BlockMappedMask = 0x5555555555555555; // First bit of each table entry set.

        private enum HostMappedPtBits : ulong
        {
            Unmapped = 0,
            Mapped,
            WriteTracked,
            ReadWriteTracked,

            MappedReplicated = 0x5555555555555555,
            WriteTrackedReplicated = 0xaaaaaaaaaaaaaaaa,
            ReadWriteTrackedReplicated = ulong.MaxValue
        }

        private readonly InvalidAccessHandler _invalidAccessHandler;

        private readonly MemoryBlock _backingMemory;
        private readonly PageTable<ulong> _pageTable;

        private readonly ulong[] _pageBitmap;

        public int AddressSpaceBits { get; }

        public MemoryTracking Tracking { get; private set; }

        private const int PteSize = 8;

        private readonly AddressSpacePartitioned _addressSpace;

        public ulong AddressSpaceSize { get; }

        private readonly MemoryBlock _flatPageTable;

        /// <inheritdoc/>
        public bool Supports4KBPages => false;

        public IntPtr PageTablePointer => _flatPageTable.Pointer;

        public MemoryManagerType Type => MemoryManagerType.HostTracked;

        public event Action<ulong, ulong> UnmapEvent;

        /// <summary>
        /// Creates a new instance of the host mapped memory manager.
        /// </summary>
        /// <param name="backingMemory">Physical backing memory where virtual memory will be mapped to</param>
        /// <param name="addressSpaceSize">Size of the address space</param>
        /// <param name="invalidAccessHandler">Optional function to handle invalid memory accesses</param>
        public MemoryManagerHostTracked(MemoryBlock backingMemory, ulong addressSpaceSize, InvalidAccessHandler invalidAccessHandler)
        {
            Tracking = new MemoryTracking(this, AddressSpacePartitioned.Use4KBProtection ? PageSize : (int)MemoryBlock.GetPageSize(), invalidAccessHandler);

            _backingMemory = backingMemory;
            _pageTable = new PageTable<ulong>();
            _invalidAccessHandler = invalidAccessHandler;
            _addressSpace = new(Tracking, backingMemory, UpdatePt);
            AddressSpaceSize = addressSpaceSize;

            ulong asSize = PageSize;
            int asBits = PageBits;

            while (asSize < AddressSpaceSize)
            {
                asSize <<= 1;
                asBits++;
            }

            AddressSpaceBits = asBits;

            _pageBitmap = new ulong[1 << (AddressSpaceBits - (PageBits + PageToPteShift))];
            _flatPageTable = new MemoryBlock((asSize / PageSize) * PteSize);
        }

        /// <inheritdoc/>
        public void Map(ulong va, ulong pa, ulong size, MemoryMapFlags flags)
        {
            AssertValidAddressAndSize(va, size);

            if (flags.HasFlag(MemoryMapFlags.Private))
            {
                _addressSpace.Map(va, pa, size);
            }

            AddMapping(va, size);
            PtMap(va, pa, size, flags.HasFlag(MemoryMapFlags.Private));

            Tracking.Map(va, size);
        }

        private void PtMap(ulong va, ulong pa, ulong size, bool privateMap)
        {
            while (size != 0)
            {
                _pageTable.Map(va, pa);

                if (privateMap)
                {
                    _flatPageTable.Write((va / PageSize) * PteSize, (ulong)_addressSpace.GetPointer(va, PageSize) - va);
                }
                else
                {
                    _flatPageTable.Write((va / PageSize) * PteSize, (ulong)_backingMemory.GetPointer(pa, PageSize) - va);
                }

                va += PageSize;
                pa += PageSize;
                size -= PageSize;
            }
        }

        private void UpdatePt(ulong va, IntPtr ptr, ulong size)
        {
            ulong remainingSize = size;
            while (remainingSize != 0)
            {
                _flatPageTable.Write((va / PageSize) * PteSize, (ulong)ptr - va);

                va += PageSize;
                ptr += PageSize;
                remainingSize -= PageSize;
            }
        }

        /// <inheritdoc/>
        public void MapForeign(ulong va, nuint hostPointer, ulong size)
        {
            throw new NotSupportedException();
        }

        /// <inheritdoc/>
        public void Unmap(ulong va, ulong size)
        {
            AssertValidAddressAndSize(va, size);

            _addressSpace.Unmap(va, size);

            UnmapEvent?.Invoke(va, size);
            Tracking.Unmap(va, size);

            RemoveMapping(va, size);
            PtUnmap(va, size);
        }

        private void PtUnmap(ulong va, ulong size)
        {
            while (size != 0)
            {
                _pageTable.Unmap(va);
                _flatPageTable.Write((va / PageSize) * PteSize, 0UL);

                va += PageSize;
                size -= PageSize;
            }
        }

        /// <summary>
        /// Checks if the virtual address is part of the addressable space.
        /// </summary>
        /// <param name="va">Virtual address</param>
        /// <returns>True if the virtual address is part of the addressable space</returns>
        private bool ValidateAddress(ulong va)
        {
            return va < AddressSpaceSize;
        }

        /// <summary>
        /// Checks if the combination of virtual address and size is part of the addressable space.
        /// </summary>
        /// <param name="va">Virtual address of the range</param>
        /// <param name="size">Size of the range in bytes</param>
        /// <returns>True if the combination of virtual address and size is part of the addressable space</returns>
        private bool ValidateAddressAndSize(ulong va, ulong size)
        {
            ulong endVa = va + size;
            return endVa >= va && endVa >= size && endVa <= AddressSpaceSize;
        }

        /// <summary>
        /// Ensures the combination of virtual address and size is part of the addressable space.
        /// </summary>
        /// <param name="va">Virtual address of the range</param>
        /// <param name="size">Size of the range in bytes</param>
        /// <exception cref="InvalidMemoryRegionException">Throw when the memory region specified outside the addressable space</exception>
        private void AssertValidAddressAndSize(ulong va, ulong size)
        {
            if (!ValidateAddressAndSize(va, size))
            {
                throw new InvalidMemoryRegionException($"va=0x{va:X16}, size=0x{size:X16}");
            }
        }

        public T Read<T>(ulong va) where T : unmanaged
        {
            return MemoryMarshal.Cast<byte, T>(GetSpan(va, Unsafe.SizeOf<T>()))[0];
        }

        public T ReadTracked<T>(ulong va) where T : unmanaged
        {
            try
            {
                SignalMemoryTracking(va, (ulong)Unsafe.SizeOf<T>(), false);

                return Read<T>(va);
            }
            catch (InvalidMemoryRegionException)
            {
                if (_invalidAccessHandler == null || !_invalidAccessHandler(va))
                {
                    throw;
                }

                return default;
            }
        }

        public void Read(ulong va, Span<byte> data)
        {
            ReadImpl(va, data);
        }

        public void Write<T>(ulong va, T value) where T : unmanaged
        {
            Write(va, MemoryMarshal.Cast<T, byte>(MemoryMarshal.CreateSpan(ref value, 1)));
        }

        public void Write(ulong va, ReadOnlySpan<byte> data)
        {
            if (data.Length == 0)
            {
                return;
            }

            SignalMemoryTracking(va, (ulong)data.Length, true);

            WriteImpl(va, data);
        }

        public void WriteUntracked(ulong va, ReadOnlySpan<byte> data)
        {
            if (data.Length == 0)
            {
                return;
            }

            WriteImpl(va, data);
        }

        public bool WriteWithRedundancyCheck(ulong va, ReadOnlySpan<byte> data)
        {
            if (data.Length == 0)
            {
                return false;
            }

            SignalMemoryTracking(va, (ulong)data.Length, false);

            if (TryGetVirtualContiguous(va, data.Length, out MemoryBlock memoryBlock, out ulong offset))
            {
                var target = memoryBlock.GetSpan(offset, data.Length);

                bool changed = !data.SequenceEqual(target);

                if (changed)
                {
                    data.CopyTo(target);
                }

                return changed;
            }
            else
            {
                WriteImpl(va, data);

                return true;
            }
        }

        private void WriteImpl(ulong va, ReadOnlySpan<byte> data)
        {
            try
            {
                AssertValidAddressAndSize(va, (ulong)data.Length);

                ulong endVa = va + (ulong)data.Length;
                int offset = 0;

                while (va < endVa)
                {
                    (MemoryBlock memory, ulong rangeOffset, ulong copySize) = GetMemoryOffsetAndSize(va, (ulong)(data.Length - offset));

                    data.Slice(offset, (int)copySize).CopyTo(memory.GetSpan(rangeOffset, (int)copySize));

                    va += copySize;
                    offset += (int)copySize;
                }
            }
            catch (InvalidMemoryRegionException)
            {
                if (_invalidAccessHandler == null || !_invalidAccessHandler(va))
                {
                    throw;
                }
            }
        }

        public ReadOnlySpan<byte> GetSpan(ulong va, int size, bool tracked = false)
        {
            if (size == 0)
            {
                return ReadOnlySpan<byte>.Empty;
            }

            if (tracked)
            {
                SignalMemoryTracking(va, (ulong)size, false);
            }

            if (TryGetVirtualContiguous(va, size, out MemoryBlock memoryBlock, out ulong offset))
            {
                return memoryBlock.GetSpan(offset, size);
            }
            else
            {
                Span<byte> data = new byte[size];

                ReadImpl(va, data);

                return data;
            }
        }

        public WritableRegion GetWritableRegion(ulong va, int size, bool tracked = false)
        {
            if (size == 0)
            {
                return new WritableRegion(null, va, Memory<byte>.Empty);
            }

            if (tracked)
            {
                SignalMemoryTracking(va, (ulong)size, true);
            }

            if (TryGetVirtualContiguous(va, size, out MemoryBlock memoryBlock, out ulong offset))
            {
                return new WritableRegion(null, va, memoryBlock.GetMemory(offset, size));
            }
            else
            {
                Memory<byte> memory = new byte[size];

                ReadImpl(va, memory.Span);

                return new WritableRegion(this, va, memory);
            }
        }

        public ref T GetRef<T>(ulong va) where T : unmanaged
        {
            if (!TryGetVirtualContiguous(va, Unsafe.SizeOf<T>(), out MemoryBlock memory, out ulong offset))
            {
                ThrowMemoryNotContiguous();
            }

            SignalMemoryTracking(va, (ulong)Unsafe.SizeOf<T>(), true);

            return ref memory.GetRef<T>(offset);
        }

        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        public bool IsMapped(ulong va)
        {
            return ValidateAddress(va) && IsMappedImpl(va);
        }

        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        private bool IsMappedImpl(ulong va)
        {
            ulong page = va >> PageBits;

            int bit = (int)((page & 31) << 1);

            int pageIndex = (int)(page >> PageToPteShift);
            ref ulong pageRef = ref _pageBitmap[pageIndex];

            ulong pte = Volatile.Read(ref pageRef);

            return ((pte >> bit) & 3) != 0;
        }

        public bool IsRangeMapped(ulong va, ulong size)
        {
            AssertValidAddressAndSize(va, size);

            return IsRangeMappedImpl(va, size);
        }

        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        private void GetPageBlockRange(ulong pageStart, ulong pageEnd, out ulong startMask, out ulong endMask, out int pageIndex, out int pageEndIndex)
        {
            startMask = ulong.MaxValue << ((int)(pageStart & 31) << 1);
            endMask = ulong.MaxValue >> (64 - ((int)(pageEnd & 31) << 1));

            pageIndex = (int)(pageStart >> PageToPteShift);
            pageEndIndex = (int)((pageEnd - 1) >> PageToPteShift);
        }

        private bool IsRangeMappedImpl(ulong va, ulong size)
        {
            int pages = GetPagesCount(va, size, out _);

            if (pages == 1)
            {
                return IsMappedImpl(va);
            }

            ulong pageStart = va >> PageBits;
            ulong pageEnd = pageStart + (ulong)pages;

            GetPageBlockRange(pageStart, pageEnd, out ulong startMask, out ulong endMask, out int pageIndex, out int pageEndIndex);

            // Check if either bit in each 2 bit page entry is set.
            // OR the block with itself shifted down by 1, and check the first bit of each entry.

            ulong mask = BlockMappedMask & startMask;

            while (pageIndex <= pageEndIndex)
            {
                if (pageIndex == pageEndIndex)
                {
                    mask &= endMask;
                }

                ref ulong pageRef = ref _pageBitmap[pageIndex++];
                ulong pte = Volatile.Read(ref pageRef);

                pte |= pte >> 1;
                if ((pte & mask) != mask)
                {
                    return false;
                }

                mask = BlockMappedMask;
            }

            return true;
        }

        private static void ThrowMemoryNotContiguous() => throw new MemoryNotContiguousException();

        private bool TryGetVirtualContiguous(ulong va, int size, out MemoryBlock memory, out ulong offset)
        {
            if (_addressSpace.HasAnyPrivateAllocation(va, (ulong)size, out PrivateRange range))
            {
                // If we have a private allocation overlapping the range,
                // this the access is only considered contiguous if it covers the entire range.

                if (range.Memory != null)
                {
                    memory = range.Memory;
                    offset = range.Offset;

                    return true;
                }

                memory = null;
                offset = 0;

                return false;
            }

            memory = _backingMemory;
            offset = GetPhysicalAddressInternal(va);

            return IsPhysicalContiguous(va, size);
        }

        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        private bool IsPhysicalContiguous(ulong va, int size)
        {
            if (!ValidateAddress(va) || !ValidateAddressAndSize(va, (ulong)size))
            {
                return false;
            }

            int pages = GetPagesCount(va, (uint)size, out va);

            for (int page = 0; page < pages - 1; page++)
            {
                if (!ValidateAddress(va + PageSize))
                {
                    return false;
                }

                if (GetPhysicalAddressInternal(va) + PageSize != GetPhysicalAddressInternal(va + PageSize))
                {
                    return false;
                }

                va += PageSize;
            }

            return true;
        }

        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        private ulong GetContiguousSize(ulong va, ulong size)
        {
            ulong contiguousSize = PageSize - (va & PageMask);

            if (!ValidateAddress(va) || !ValidateAddressAndSize(va, size))
            {
                return contiguousSize;
            }

            int pages = GetPagesCount(va, size, out va);

            for (int page = 0; page < pages - 1; page++)
            {
                if (!ValidateAddress(va + PageSize))
                {
                    return contiguousSize;
                }

                if (GetPhysicalAddressInternal(va) + PageSize != GetPhysicalAddressInternal(va + PageSize))
                {
                    return contiguousSize;
                }

                va += PageSize;
                contiguousSize += PageSize;
            }

            return Math.Min(contiguousSize, size);
        }

        private (MemoryBlock, ulong, ulong) GetMemoryOffsetAndSize(ulong va, ulong size)
        {
            ulong endVa = va + size;

            PrivateRange privateRange = _addressSpace.GetFirstPrivateAllocation(va, size, out ulong nextVa);

            if (privateRange.Memory != null)
            {
                return (privateRange.Memory, privateRange.Offset, privateRange.Size);
            }

            ulong physSize = GetContiguousSize(va, Math.Min(size, nextVa - va));

            return new(_backingMemory, GetPhysicalAddressChecked(va), physSize);
        }

        public IEnumerable<HostMemoryRange> GetHostRegions(ulong va, ulong size)
        {
            if (!ValidateAddressAndSize(va, size))
            {
                return null;
            }

            var regions = new List<HostMemoryRange>();
            ulong endVa = va + size;

            try
            {
                while (va < endVa)
                {
                    (MemoryBlock memory, ulong rangeOffset, ulong rangeSize) = GetMemoryOffsetAndSize(va, endVa - va);

                    regions.Add(new((UIntPtr)memory.GetPointer(rangeOffset, rangeSize), rangeSize));

                    va += rangeSize;
                }
            }
            catch (InvalidMemoryRegionException)
            {
                return null;
            }

            return regions;
        }

        public IEnumerable<MemoryRange> GetPhysicalRegions(ulong va, ulong size)
        {
            if (size == 0)
            {
                return Enumerable.Empty<MemoryRange>();
            }

            return GetPhysicalRegionsImpl(va, size);
        }

        private List<MemoryRange> GetPhysicalRegionsImpl(ulong va, ulong size)
        {
            if (!ValidateAddress(va) || !ValidateAddressAndSize(va, size))
            {
                return null;
            }

            int pages = GetPagesCount(va, (uint)size, out va);

            var regions = new List<MemoryRange>();

            ulong regionStart = GetPhysicalAddressInternal(va);
            ulong regionSize = PageSize;

            for (int page = 0; page < pages - 1; page++)
            {
                if (!ValidateAddress(va + PageSize))
                {
                    return null;
                }

                ulong newPa = GetPhysicalAddressInternal(va + PageSize);

                if (GetPhysicalAddressInternal(va) + PageSize != newPa)
                {
                    regions.Add(new MemoryRange(regionStart, regionSize));
                    regionStart = newPa;
                    regionSize = 0;
                }

                va += PageSize;
                regionSize += PageSize;
            }

            regions.Add(new MemoryRange(regionStart, regionSize));

            return regions;
        }

        private void ReadImpl(ulong va, Span<byte> data)
        {
            if (data.Length == 0)
            {
                return;
            }

            try
            {
                AssertValidAddressAndSize(va, (ulong)data.Length);

                ulong endVa = va + (ulong)data.Length;
                int offset = 0;

                while (va < endVa)
                {
                    (MemoryBlock memory, ulong rangeOffset, ulong copySize) = GetMemoryOffsetAndSize(va, (ulong)(data.Length - offset));

                    memory.GetSpan(rangeOffset, (int)copySize).CopyTo(data.Slice(offset, (int)copySize));

                    va += copySize;
                    offset += (int)copySize;
                }
            }
            catch (InvalidMemoryRegionException)
            {
                if (_invalidAccessHandler == null || !_invalidAccessHandler(va))
                {
                    throw;
                }
            }
        }

        /// <inheritdoc/>
        /// <remarks>
        /// This function also validates that the given range is both valid and mapped, and will throw if it is not.
        /// </remarks>
        public void SignalMemoryTracking(ulong va, ulong size, bool write, bool precise = false, int? exemptId = null)
        {
            AssertValidAddressAndSize(va, size);

            if (precise)
            {
                Tracking.VirtualMemoryEvent(va, size, write, precise: true, exemptId);
                return;
            }

            // Software table, used for managed memory tracking.

            int pages = GetPagesCount(va, size, out _);
            ulong pageStart = va >> PageBits;

            if (pages == 1)
            {
                ulong tag = (ulong)(write ? HostMappedPtBits.WriteTracked : HostMappedPtBits.ReadWriteTracked);

                int bit = (int)((pageStart & 31) << 1);

                int pageIndex = (int)(pageStart >> PageToPteShift);
                ref ulong pageRef = ref _pageBitmap[pageIndex];

                ulong pte = Volatile.Read(ref pageRef);
                ulong state = ((pte >> bit) & 3);

                if (state >= tag)
                {
                    Tracking.VirtualMemoryEvent(va, size, write, precise: false, exemptId);
                    return;
                }
                else if (state == 0)
                {
                    ThrowInvalidMemoryRegionException($"Not mapped: va=0x{va:X16}, size=0x{size:X16}");
                }
            }
            else
            {
                ulong pageEnd = pageStart + (ulong)pages;

                GetPageBlockRange(pageStart, pageEnd, out ulong startMask, out ulong endMask, out int pageIndex, out int pageEndIndex);

                ulong mask = startMask;

                ulong anyTrackingTag = (ulong)HostMappedPtBits.WriteTrackedReplicated;

                while (pageIndex <= pageEndIndex)
                {
                    if (pageIndex == pageEndIndex)
                    {
                        mask &= endMask;
                    }

                    ref ulong pageRef = ref _pageBitmap[pageIndex++];

                    ulong pte = Volatile.Read(ref pageRef);
                    ulong mappedMask = mask & BlockMappedMask;

                    ulong mappedPte = pte | (pte >> 1);
                    if ((mappedPte & mappedMask) != mappedMask)
                    {
                        ThrowInvalidMemoryRegionException($"Not mapped: va=0x{va:X16}, size=0x{size:X16}");
                    }

                    pte &= mask;
                    if ((pte & anyTrackingTag) != 0) // Search for any tracking.
                    {
                        // Writes trigger any tracking.
                        // Only trigger tracking from reads if both bits are set on any page.
                        if (write || (pte & (pte >> 1) & BlockMappedMask) != 0)
                        {
                            Tracking.VirtualMemoryEvent(va, size, write, precise: false, exemptId);
                            break;
                        }
                    }

                    mask = ulong.MaxValue;
                }
            }
        }

        /// <summary>
        /// Computes the number of pages in a virtual address range.
        /// </summary>
        /// <param name="va">Virtual address of the range</param>
        /// <param name="size">Size of the range</param>
        /// <param name="startVa">The virtual address of the beginning of the first page</param>
        /// <remarks>This function does not differentiate between allocated and unallocated pages.</remarks>
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        private int GetPagesCount(ulong va, ulong size, out ulong startVa)
        {
            // WARNING: Always check if ulong does not overflow during the operations.
            startVa = va & ~(ulong)PageMask;
            ulong vaSpan = (va - startVa + size + PageMask) & ~(ulong)PageMask;

            return (int)(vaSpan / PageSize);
        }

        public RegionHandle BeginTracking(ulong address, ulong size, int id)
        {
            return Tracking.BeginTracking(address, size, id);
        }

        public MultiRegionHandle BeginGranularTracking(ulong address, ulong size, IEnumerable<IRegionHandle> handles, ulong granularity, int id)
        {
            return Tracking.BeginGranularTracking(address, size, handles, granularity, id);
        }

        public SmartMultiRegionHandle BeginSmartGranularTracking(ulong address, ulong size, ulong granularity, int id)
        {
            return Tracking.BeginSmartGranularTracking(address, size, granularity, id);
        }

        /// <summary>
        /// Adds the given address mapping to the page table.
        /// </summary>
        /// <param name="va">Virtual memory address</param>
        /// <param name="size">Size to be mapped</param>
        private void AddMapping(ulong va, ulong size)
        {
            int pages = GetPagesCount(va, size, out _);
            ulong pageStart = va >> PageBits;
            ulong pageEnd = pageStart + (ulong)pages;

            GetPageBlockRange(pageStart, pageEnd, out ulong startMask, out ulong endMask, out int pageIndex, out int pageEndIndex);

            ulong mask = startMask;

            while (pageIndex <= pageEndIndex)
            {
                if (pageIndex == pageEndIndex)
                {
                    mask &= endMask;
                }

                ref ulong pageRef = ref _pageBitmap[pageIndex++];

                ulong pte;
                ulong mappedMask;

                // Map all 2-bit entries that are unmapped.
                do
                {
                    pte = Volatile.Read(ref pageRef);

                    mappedMask = pte | (pte >> 1);
                    mappedMask |= (mappedMask & BlockMappedMask) << 1;
                    mappedMask |= ~mask; // Treat everything outside the range as mapped, thus unchanged.
                }
                while (Interlocked.CompareExchange(ref pageRef, (pte & mappedMask) | (BlockMappedMask & (~mappedMask)), pte) != pte);

                mask = ulong.MaxValue;
            }
        }

        /// <summary>
        /// Removes the given address mapping from the page table.
        /// </summary>
        /// <param name="va">Virtual memory address</param>
        /// <param name="size">Size to be unmapped</param>
        private void RemoveMapping(ulong va, ulong size)
        {
            int pages = GetPagesCount(va, size, out _);
            ulong pageStart = va >> PageBits;
            ulong pageEnd = pageStart + (ulong)pages;

            GetPageBlockRange(pageStart, pageEnd, out ulong startMask, out ulong endMask, out int pageIndex, out int pageEndIndex);

            startMask = ~startMask;
            endMask = ~endMask;

            ulong mask = startMask;

            while (pageIndex <= pageEndIndex)
            {
                if (pageIndex == pageEndIndex)
                {
                    mask |= endMask;
                }

                ref ulong pageRef = ref _pageBitmap[pageIndex++];
                ulong pte;

                do
                {
                    pte = Volatile.Read(ref pageRef);
                }
                while (Interlocked.CompareExchange(ref pageRef, pte & mask, pte) != pte);

                mask = 0;
            }
        }

        private ulong GetPhysicalAddressChecked(ulong va)
        {
            if (!IsMapped(va))
            {
                ThrowInvalidMemoryRegionException($"Not mapped: va=0x{va:X16}");
            }

            return GetPhysicalAddressInternal(va);
        }

        private ulong GetPhysicalAddressInternal(ulong va)
        {
            return _pageTable.Read(va) + (va & PageMask);
        }

        private static void ThrowInvalidMemoryRegionException(string message) => throw new InvalidMemoryRegionException(message);

        /// <inheritdoc/>
        public void Reprotect(ulong va, ulong size, MemoryPermission protection)
        {
            // TODO
        }

        /// <inheritdoc/>
        public void TrackingReprotect(ulong va, ulong size, MemoryPermission protection)
        {
            // Protection is inverted on software pages, since the default value is 0.
            protection = (~protection) & MemoryPermission.ReadAndWrite;

            int pages = GetPagesCount(va, size, out va);
            ulong pageStart = va >> PageBits;

            if (pages == 1)
            {
                ulong protTag = protection switch
                {
                    MemoryPermission.None => (ulong)HostMappedPtBits.Mapped,
                    MemoryPermission.Write => (ulong)HostMappedPtBits.WriteTracked,
                    _ => (ulong)HostMappedPtBits.ReadWriteTracked,
                };

                int bit = (int)((pageStart & 31) << 1);

                ulong tagMask = 3UL << bit;
                ulong invTagMask = ~tagMask;

                ulong tag = protTag << bit;

                int pageIndex = (int)(pageStart >> PageToPteShift);
                ref ulong pageRef = ref _pageBitmap[pageIndex];

                ulong pte;

                do
                {
                    pte = Volatile.Read(ref pageRef);
                }
                while ((pte & tagMask) != 0 && Interlocked.CompareExchange(ref pageRef, (pte & invTagMask) | tag, pte) != pte);
            }
            else
            {
                ulong pageEnd = pageStart + (ulong)pages;

                GetPageBlockRange(pageStart, pageEnd, out ulong startMask, out ulong endMask, out int pageIndex, out int pageEndIndex);

                ulong mask = startMask;

                ulong protTag = protection switch
                {
                    MemoryPermission.None => (ulong)HostMappedPtBits.MappedReplicated,
                    MemoryPermission.Write => (ulong)HostMappedPtBits.WriteTrackedReplicated,
                    _ => (ulong)HostMappedPtBits.ReadWriteTrackedReplicated,
                };

                while (pageIndex <= pageEndIndex)
                {
                    if (pageIndex == pageEndIndex)
                    {
                        mask &= endMask;
                    }

                    ref ulong pageRef = ref _pageBitmap[pageIndex++];

                    ulong pte;
                    ulong mappedMask;

                    // Change the protection of all 2 bit entries that are mapped.
                    do
                    {
                        pte = Volatile.Read(ref pageRef);

                        mappedMask = pte | (pte >> 1);
                        mappedMask |= (mappedMask & BlockMappedMask) << 1;
                        mappedMask &= mask; // Only update mapped pages within the given range.
                    }
                    while (Interlocked.CompareExchange(ref pageRef, (pte & (~mappedMask)) | (protTag & mappedMask), pte) != pte);

                    mask = ulong.MaxValue;
                }
            }

            protection = protection switch
            {
                MemoryPermission.None => MemoryPermission.ReadAndWrite,
                MemoryPermission.Write => MemoryPermission.Read,
                _ => MemoryPermission.None,
            };

            _addressSpace.Reprotect(va, size, protection);
        }

        /// <summary>
        /// Disposes of resources used by the memory manager.
        /// </summary>
        protected override void Destroy()
        {
            _addressSpace.Dispose();
        }
    }
}
