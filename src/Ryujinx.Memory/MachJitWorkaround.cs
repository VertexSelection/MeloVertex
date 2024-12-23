using System;
using System.Runtime.InteropServices;
using System.Runtime.Versioning;

namespace Ryujinx.Memory
{
    [SupportedOSPlatform("ios")]
    static unsafe partial class MachJitWorkaround
    {
        // Previous imports remain the same
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
        
        // Updated to iOS 16KB page size
        private const int PAGE_SIZE = 16 * 1024;
        private const ulong PAGE_MASK = ~((ulong)PAGE_SIZE - 1);

        static MachJitWorkaround()
        {
            _selfTask = mach_task_self();
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
            // Ensure size is page-aligned
            int alignedSize = (int)((((ulong)size + PAGE_SIZE - 1) & PAGE_MASK));
            
            // Deallocate existing mapping
            vm_deallocate(_selfTask, address, (IntPtr)alignedSize);

            IntPtr memorySize = (IntPtr)alignedSize;
            IntPtr memoryObjectPort = IntPtr.Zero;

            try
            {
                // Create minimal permission memory entry initially
                HandleMachError(
                    mach_make_memory_entry_64(
                        _selfTask,
                        &memorySize,
                        IntPtr.Zero,
                        Flags.MAP_MEM_NAMED_CREATE | Flags.MAP_MEM_LEDGER_TAGGED | 
                        Flags.VM_PROT_READ | Flags.VM_PROT_WRITE,  // Don't request execute initially
                        &memoryObjectPort,
                        IntPtr.Zero),
                    "make_memory_entry_64");

                // Set no-footprint flag to minimize memory usage
                HandleMachError(
                    mach_memory_entry_ownership(
                        memoryObjectPort,
                        TASK_NULL,
                        Flags.VM_LEDGER_TAG_DEFAULT,
                        Flags.VM_LEDGER_FLAG_NO_FOOTPRINT),
                    "memory_entry_ownership");

                IntPtr mapAddress = address;

                // Map with minimal initial permissions
                int result = vm_map(
                    _selfTask,
                    &mapAddress,
                    memorySize,
                    IntPtr.Zero,
                    Flags.VM_FLAGS_OVERWRITE,
                    memoryObjectPort,
                    IntPtr.Zero,
                    0,
                    Flags.VM_PROT_READ | Flags.VM_PROT_WRITE,
                    Flags.VM_PROT_READ | Flags.VM_PROT_WRITE | Flags.VM_PROT_EXECUTE,  // Allow execute as max protection
                    Flags.VM_INHERIT_COPY);

                HandleMachError(result, "vm_map");

                if (address != mapAddress)
                {
                    throw new InvalidOperationException("Memory mapping address mismatch");
                }

                return mapAddress;
            }
            finally
            {
                if (memoryObjectPort != IntPtr.Zero)
                {
                    // Implement proper cleanup if needed
                    // mach_port_deallocate(_selfTask, memoryObjectPort);
                }
            }
        }

        public static void ReallocateAreaWithOwnership(IntPtr address, int size)
        {
            if (size <= 0)
            {
                throw new ArgumentException("Size must be positive", nameof(size));
            }

            // Align size to 16KB page boundary
            int alignedSize = (int)((((ulong)size + PAGE_SIZE - 1) & PAGE_MASK));
            
            try
            {
                ReallocateBlock(address, alignedSize);
            }
            catch (InvalidOperationException)
            {
                // If first attempt fails, try with explicit deallocation and retry
                vm_deallocate(_selfTask, address, (IntPtr)alignedSize);
                ReallocateBlock(address, alignedSize);
            }
        }

        public static IntPtr AllocateSharedMemory(ulong size, bool reserve)
        {
            if (size == 0)
            {
                throw new ArgumentException("Size must be positive", nameof(size));
            }

            ulong alignedSize = (size + (ulong)PAGE_SIZE - 1) & PAGE_MASK;
            
            IntPtr address = IntPtr.Zero;
            HandleMachError(
                vm_allocate(
                    _selfTask,
                    &address,
                    (IntPtr)alignedSize,
                    Flags.VM_FLAGS_ANYWHERE),
                "vm_allocate");
            
            return address;
        }

        public static void DestroySharedMemory(IntPtr handle, ulong size)
        {
            if (handle != IntPtr.Zero && size > 0)
            {
                ulong alignedSize = (size + (ulong)PAGE_SIZE - 1) & PAGE_MASK;
                vm_deallocate(_selfTask, handle, (IntPtr)alignedSize);
            }
        }

        public static IntPtr MapView(IntPtr sharedMemory, ulong srcOffset, IntPtr location, ulong size)
        {
            if (size == 0 || sharedMemory == IntPtr.Zero)
            {
                throw new ArgumentException("Invalid mapping parameters");
            }

            ulong alignedOffset = srcOffset & PAGE_MASK;
            ulong alignedSize = (size + (ulong)PAGE_SIZE - 1) & PAGE_MASK;

            IntPtr srcAddress = (IntPtr)((ulong)sharedMemory + alignedOffset);
            IntPtr dstAddress = location;
            int curProtection = 0;
            int maxProtection = 0;

            // Deallocate existing mapping
            vm_deallocate(_selfTask, location, (IntPtr)alignedSize);

            HandleMachError(
                vm_remap(
                    _selfTask,
                    &dstAddress,
                    (IntPtr)alignedSize,
                    IntPtr.Zero,
                    Flags.VM_FLAGS_FIXED,
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
                ulong alignedSize = (size + (ulong)PAGE_SIZE - 1) & PAGE_MASK;
                vm_deallocate(_selfTask, location, (IntPtr)alignedSize);
            }
        }
    }
}