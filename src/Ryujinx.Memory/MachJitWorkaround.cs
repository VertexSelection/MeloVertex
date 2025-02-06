using System;
using System.Runtime.InteropServices;
using System.Runtime.Versioning;

namespace Ryujinx.Memory
{
    [SupportedOSPlatform("ios")]
    static unsafe partial class MachJitWorkaround
    {
        [LibraryImport("libc")]
        public static partial int mach_task_self();

        [LibraryImport("libc")]
        public static partial int mach_make_memory_entry_64(IntPtr target_task, IntPtr* size, IntPtr offset, int permission, IntPtr* object_handle, IntPtr parent_entry);

        [LibraryImport("libc")]
        public static partial int mach_memory_entry_ownership(IntPtr mem_entry, IntPtr owner, int ledger_tag, int ledger_flags);

        [LibraryImport("libc")]
        public static partial int vm_map(IntPtr target_task, IntPtr* address, IntPtr size, IntPtr mask, int flags, IntPtr obj, IntPtr offset, int copy, int cur_protection, int max_protection, int inheritance);

        [LibraryImport("libc")]
        public static partial int vm_allocate(IntPtr target_task, IntPtr* address, IntPtr size, int flags);

        [LibraryImport("libc")]
        public static partial int vm_deallocate(IntPtr target_task, IntPtr address, IntPtr size);

        [LibraryImport("libc")]
        public static partial int vm_remap(IntPtr target_task, IntPtr* target_address, IntPtr size, IntPtr mask, int flags, IntPtr src_task, IntPtr src_address, int copy, int* cur_protection, int* max_protection, int inheritance);

        private static class Flags
        {
            public const int MAP_MEM_LEDGER_TAGGED = 0x002000;
            public const int MAP_MEM_NAMED_CREATE = 0x020000;
            public const int VM_PROT_READ = 0x01;
            public const int VM_PROT_WRITE = 0x02;
            public const int VM_PROT_EXECUTE = 0x04;
            public const int VM_LEDGER_TAG_DEFAULT = 0x00000001;
            public const int VM_LEDGER_FLAG_NO_FOOTPRINT = 0x00000001;
            public const int VM_INHERIT_COPY = 1;
            public const int VM_INHERIT_DEFAULT = VM_INHERIT_COPY;
            public const int VM_FLAGS_FIXED = 0x0000;
            public const int VM_FLAGS_ANYWHERE = 0x0001;
            public const int VM_FLAGS_OVERWRITE = 0x4000;
        }

        private const IntPtr TASK_NULL = 0;
        private static readonly IntPtr _selfTask;
        private static readonly int DEFAULT_CHUNK_SIZE = 1024 * 1024; 

        static MachJitWorkaround()
        {
            _selfTask = mach_task_self();
        }

        private static int CalculateOptimalChunkSize(int totalSize)
        {
            // Dynamically calculate chunk size based on total allocation size
            // For smaller allocations, use smaller chunks to avoid waste
            if (totalSize <= DEFAULT_CHUNK_SIZE)
            {
                return totalSize;
            }

            chunkSize /= 2;
            
            int chunkCount = Math.Max(4, totalSize / DEFAULT_CHUNK_SIZE);
            return (totalSize + chunkCount - 1) / chunkCount;
        }

        private static void HandleMachError(int error, string operation)
        {
            if (error != 0)
            {
                throw new InvalidOperationException($"Mach operation '{operation}' failed with error: {error}");
            }
        }

        private static IntPtr ReallocateBlock(IntPtr address, int size)
        {
            IntPtr memorySize = (IntPtr)size;
            IntPtr memoryObjectPort = IntPtr.Zero;

            try
            {
                // Create memory entry
                HandleMachError(
                    mach_make_memory_entry_64(
                        _selfTask,
                        &memorySize,
                        IntPtr.Zero,
                        Flags.MAP_MEM_NAMED_CREATE | Flags.MAP_MEM_LEDGER_TAGGED | 
                        Flags.VM_PROT_READ | Flags.VM_PROT_WRITE | Flags.VM_PROT_EXECUTE,
                        &memoryObjectPort,
                        IntPtr.Zero),
                    "make_memory_entry_64");

                if (memorySize != (IntPtr)size)
                {
                    throw new InvalidOperationException($"Memory allocation size mismatch. Requested: {size}, Allocated: {(long)memorySize}");
                }

                // Set ownership
                HandleMachError(
                    mach_memory_entry_ownership(
                        memoryObjectPort,
                        TASK_NULL,
                        Flags.VM_LEDGER_TAG_DEFAULT,
                        Flags.VM_LEDGER_FLAG_NO_FOOTPRINT),
                    "memory_entry_ownership");

                IntPtr mapAddress = address;

                // Map memory
                HandleMachError(
                    vm_map(
                        _selfTask,
                        &mapAddress,
                        memorySize,
                        IntPtr.Zero,
                        Flags.VM_FLAGS_OVERWRITE,
                        memoryObjectPort,
                        IntPtr.Zero,
                        0,
                        Flags.VM_PROT_READ | Flags.VM_PROT_WRITE,
                        Flags.VM_PROT_READ | Flags.VM_PROT_WRITE | Flags.VM_PROT_EXECUTE,
                        Flags.VM_INHERIT_COPY),
                    "vm_map");

                if (address != mapAddress)
                {
                    throw new InvalidOperationException("Memory mapping address mismatch");
                }

                return mapAddress;
            }
            finally
            {
                // Proper cleanup of memory object port
                if (memoryObjectPort != IntPtr.Zero)
                {
                    // mach_port_deallocate(_selfTask, memoryObjectPort);
                }
            }
        }

        public static void ReallocateAreaWithOwnership(IntPtr address, int size)
        {
            int chunkSize = CalculateOptimalChunkSize(size);
            IntPtr currentAddress = address;
            IntPtr endAddress = address + size;

            while (currentAddress < endAddress)
            {
                int blockSize = Math.Min(chunkSize, (int)(endAddress - currentAddress));
                ReallocateBlock(currentAddress, blockSize);
                currentAddress += blockSize;
            }
        }

        public static IntPtr AllocateSharedMemory(ulong size, bool reserve)
        {
            IntPtr address = IntPtr.Zero;
            HandleMachError(
                vm_allocate(_selfTask, &address, (IntPtr)size, Flags.VM_FLAGS_ANYWHERE),
                "vm_allocate");
            return address;
        }

        public static void DestroySharedMemory(IntPtr handle, ulong size)
        {
            if (handle != IntPtr.Zero && size > 0)
            {
                vm_deallocate(_selfTask, handle, (IntPtr)size);
            }
        }

        public static IntPtr MapView(IntPtr sharedMemory, ulong srcOffset, IntPtr location, ulong size)
        {
            if (size == 0 || sharedMemory == IntPtr.Zero)
            {
                throw new ArgumentException("Invalid mapping parameters");
            }

            IntPtr srcAddress = (IntPtr)((ulong)sharedMemory + srcOffset);
            IntPtr dstAddress = location;
            int curProtection = 0;
            int maxProtection = 0;

            HandleMachError(
                vm_remap(
                    _selfTask,
                    &dstAddress,
                    (IntPtr)size,
                    IntPtr.Zero,
                    Flags.VM_FLAGS_OVERWRITE,
                    _selfTask,
                    srcAddress,
                    0,
                    &curProtection,
                    &maxProtection,
                    Flags.VM_INHERIT_DEFAULT),
                "vm_remap");

            return dstAddress;
        }

        public static void UnmapView(IntPtr location, ulong size)
        {
            if (location != IntPtr.Zero && size > 0)
            {
                vm_deallocate(_selfTask, location, (IntPtr)size);
            }
        }
    }
}
