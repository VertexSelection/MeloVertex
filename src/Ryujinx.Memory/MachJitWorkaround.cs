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

        const int MAP_MEM_LEDGER_TAGGED = 0x002000;
        const int MAP_MEM_NAMED_CREATE = 0x020000;

        const int VM_PROT_READ = 0x01;
        const int VM_PROT_WRITE = 0x02;
        const int VM_PROT_EXECUTE = 0x04;

        const int VM_LEDGER_TAG_DEFAULT = 0x00000001;
        const int VM_LEDGER_FLAG_NO_FOOTPRINT = 0x00000001;

        const int VM_INHERIT_COPY = 1;
        const int VM_INHERIT_DEFAULT = VM_INHERIT_COPY;

        const int VM_FLAGS_FIXED = 0x0000;
        const int VM_FLAGS_ANYWHERE = 0x0001;
        const int VM_FLAGS_OVERWRITE = 0x4000;

        const IntPtr TASK_NULL = 0;

        public static void ReallocateBlock(IntPtr address, int size)
        {
            IntPtr selfTask = mach_task_self();
            IntPtr memorySize = (IntPtr)size;
            IntPtr memoryObjectPort = IntPtr.Zero;

            int err = mach_make_memory_entry_64(selfTask, &memorySize, 0, MAP_MEM_NAMED_CREATE | MAP_MEM_LEDGER_TAGGED | VM_PROT_READ | VM_PROT_WRITE | VM_PROT_EXECUTE, &memoryObjectPort, 0);

            if (err != 0)
            {
                throw new InvalidOperationException($"Make memory entry failed: {err}");
            }

            try
            {
                if (memorySize != (IntPtr)size)
                {
                    throw new InvalidOperationException($"Created with size {memorySize} instead of {size}.");
                }

                err = mach_memory_entry_ownership(memoryObjectPort, TASK_NULL, VM_LEDGER_TAG_DEFAULT, VM_LEDGER_FLAG_NO_FOOTPRINT);

                if (err != 0)
                {
                    throw new InvalidOperationException($"Failed to set ownership: {err}");
                }

                IntPtr mapAddress = address;

                err = vm_map(
                    selfTask,
                    &mapAddress,
                    memorySize,
                    /*mask=*/ 0,
                    /*flags=*/ VM_FLAGS_OVERWRITE,
                    memoryObjectPort,
                    /*offset=*/ 0,
                    /*copy=*/ 0,
                    VM_PROT_READ | VM_PROT_WRITE,
                    VM_PROT_READ | VM_PROT_WRITE | VM_PROT_EXECUTE,
                    VM_INHERIT_COPY);

                if (err != 0)
                {
                    throw new InvalidOperationException($"Failed to map: {err}");
                }

                if (address != mapAddress)
                {
                    throw new InvalidOperationException($"Remap changed address");
                }
            }
            finally
            {
                //mach_port_deallocate(selfTask, memoryObjectPort);
            }

            Console.WriteLine($"Reallocated an area... {address:x16}");
        }

        public static void ReallocateAreaWithOwnership(IntPtr address, int size)
        {
            int mapChunkSize = 128 * 1024 * 1024;
            IntPtr endAddress = address + size;
            IntPtr blockAddress = address;
            while (blockAddress < endAddress)
            {
                int blockSize = Math.Min(mapChunkSize, (int)(endAddress - blockAddress));

                ReallocateBlock(blockAddress, blockSize);

                blockAddress += blockSize;
            }
        }

        public static IntPtr AllocateSharedMemory(ulong size, bool reserve)
        {
            IntPtr address = 0;

            int err = vm_allocate(mach_task_self(), &address, (IntPtr)size, VM_FLAGS_ANYWHERE);

            if (err != 0)
            {
                throw new InvalidOperationException($"Failed to allocate shared memory: {err}");
            }

            return address;
        }

        public static void DestroySharedMemory(IntPtr handle, ulong size)
        {
            vm_deallocate(mach_task_self(), handle, (IntPtr)size);
        }

        public static IntPtr MapView(IntPtr sharedMemory, ulong srcOffset, IntPtr location, ulong size)
        {
            IntPtr taskSelf = mach_task_self();
            IntPtr srcAddress = (IntPtr)((ulong)sharedMemory + srcOffset);
            IntPtr dstAddress = location;

            int cur_protection = 0;
            int max_protection = 0;

            int err = vm_remap(taskSelf, &dstAddress, (IntPtr)size, 0, VM_FLAGS_OVERWRITE, taskSelf, srcAddress, 0, &cur_protection, &max_protection, VM_INHERIT_DEFAULT);

            if (err != 0)
            {
                throw new InvalidOperationException($"Failed to allocate remap memory: {err}");
            }

            return dstAddress;
        }

        public static void UnmapView(IntPtr location, ulong size)
        {
            vm_deallocate(mach_task_self(), location, (IntPtr)size);
        }
    }
}