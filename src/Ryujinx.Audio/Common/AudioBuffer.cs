using Ryujinx.Audio.Integration;
using System.Threading;

namespace Ryujinx.Audio.Common
{
    /// <summary>
    /// Represent an audio buffer that will be used by an <see cref="IHardwareDeviceSession"/>.
    /// </summary>
    public class AudioBuffer
    {
        private static ulong UniqueIdGlobal = 0;

        /// <summary>
        /// Unique tag of this buffer, from the guest.
        /// </summary>
        /// <remarks>Unique per session</remarks>
        public ulong BufferTag;

        /// <summary>
        /// Globally unique ID of the buffer on the host.
        /// </summary>
        public ulong HostTag = Interlocked.Increment(ref UniqueIdGlobal);

        /// <summary>
        /// Pointer to the user samples.
        /// </summary>
        public ulong DataPointer;

        /// <summary>
        /// Size of the user samples region.
        /// </summary>
        public ulong DataSize;

        /// <summary>
        ///  The timestamp at which the buffer was played.
        /// </summary>
        /// <remarks>Not used but useful for debugging</remarks>
        public ulong PlayedTimestamp;

        /// <summary>
        /// The user samples.
        /// </summary>
        public byte[] Data;
    }
}
