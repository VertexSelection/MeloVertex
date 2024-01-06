using Ryujinx.Audio.Backends.Common;
using Ryujinx.Audio.Common;
using Ryujinx.Audio.Integration;
using Ryujinx.Memory;
using System;
using System.Threading;
using static Ryujinx.Audio.Integration.IHardwareDeviceDriver;

namespace Ryujinx.Audio.Backends.DelayLayer
{
    public class DelayLayerHardwareDeviceDriver : IHardwareDeviceDriver
    {
        private readonly IHardwareDeviceDriver _realDriver;

        public static bool IsSupported => true;

        public ulong SampleDelay48k;

        public DelayLayerHardwareDeviceDriver(IHardwareDeviceDriver realDevice, ulong sampleDelay48k)
        {
            _realDriver = realDevice;
            SampleDelay48k = sampleDelay48k;
        }

        public IHardwareDeviceSession OpenDeviceSession(Direction direction, IVirtualMemoryManager memoryManager, SampleFormat sampleFormat, uint sampleRate, uint channelCount, float volume)
        {
            IHardwareDeviceSession session = _realDriver.OpenDeviceSession(direction, memoryManager, sampleFormat, sampleRate, channelCount, volume);

            if (direction == Direction.Output)
            {
                return new DelayLayerHardwareDeviceSession(this, session as HardwareDeviceSessionOutputBase, sampleFormat, channelCount);
            }

            return session;
        }

        public ManualResetEvent GetUpdateRequiredEvent()
        {
            return _realDriver.GetUpdateRequiredEvent();
        }

        public ManualResetEvent GetPauseEvent()
        {
            return _realDriver.GetPauseEvent();
        }

        public void Dispose()
        {
            GC.SuppressFinalize(this);
            Dispose(true);
        }

        protected virtual void Dispose(bool disposing)
        {
            if (disposing)
            {
                _realDriver.Dispose();
            }
        }

        public bool SupportsSampleRate(uint sampleRate)
        {
            return _realDriver.SupportsSampleRate(sampleRate);
        }

        public bool SupportsSampleFormat(SampleFormat sampleFormat)
        {
            return _realDriver.SupportsSampleFormat(sampleFormat);
        }

        public bool SupportsDirection(Direction direction)
        {
            return _realDriver.SupportsDirection(direction);
        }

        public bool SupportsChannelCount(uint channelCount)
        {
            return _realDriver.SupportsChannelCount(channelCount);
        }

        public IHardwareDeviceDriver GetRealDeviceDriver()
        {
            return _realDriver.GetRealDeviceDriver();
        }
    }
}
