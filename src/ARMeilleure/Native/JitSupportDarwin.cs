using System;
using System.Runtime.InteropServices;
using System.Runtime.Versioning;

namespace ARMeilleure.Native
{
    [SupportedOSPlatform("macos")]
    [SupportedOSPlatform("ios")]
    static partial class JitSupportDarwin
    {
        [LibraryImport("libarmeilleure-jitsupport", EntryPoint = "armeilleure_jit_memcpy")]
        public static partial void Copy(IntPtr dst, IntPtr src, ulong n);
    }

    [SupportedOSPlatform("ios")]
    internal static partial class JitSupportDarwinAot
    {
        [LibraryImport("pthread", EntryPoint = "pthread_jit_write_protect_np")]
        private static partial void pthread_jit_write_protect_np(int enabled);

        [LibraryImport("libc", EntryPoint = "sys_icache_invalidate")]
        private static partial void sys_icache_invalidate(IntPtr start, IntPtr length);

        public static unsafe void Copy(IntPtr dst, IntPtr src, ulong n) {
            // When NativeAOT is in use, we can toggle per-thread write protection without worrying about breaking .NET code.

            //pthread_jit_write_protect_np(0);
            
            var srcSpan = new Span<byte>(src.ToPointer(), (int)n);
            var dstSpan = new Span<byte>(dst.ToPointer(), (int)n);
            srcSpan.CopyTo(dstSpan);

            //pthread_jit_write_protect_np(1);

            // Ensure that the instruction cache for this range is invalidated.
            sys_icache_invalidate(dst, (IntPtr)n);
        }

        public static unsafe void Invalidate(IntPtr dst, ulong n)
        {
            // Ensure that the instruction cache for this range is invalidated.
            sys_icache_invalidate(dst, (IntPtr)n);
        }
    }
}
