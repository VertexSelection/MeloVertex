using Ryujinx.Audio.Backends.Common;
using Ryujinx.Audio.Common;
using System.Collections.Generic;
using System.Threading;

namespace Ryujinx.Audio.Backends.DelayLayer
{
    internal class DelayLayerHardwareDeviceSession : HardwareDeviceSessionOutputBase
    {
        private readonly HardwareDeviceSessionOutputBase _realSession;
        private readonly ManualResetEvent _updateRequiredEvent;

        private readonly ulong _delayTarget;

        private object _sampleCountLock = new();

        private List<AudioBuffer> _buffers = new();

        public DelayLayerHardwareDeviceSession(DelayLayerHardwareDeviceDriver driver, HardwareDeviceSessionOutputBase realSession, SampleFormat userSampleFormat, uint userChannelCount) : base(realSession.MemoryManager, realSession.RequestedSampleFormat, realSession.RequestedSampleRate, userChannelCount)
        {
            _realSession = realSession;
            _delayTarget = driver.SampleDelay48k;

            _updateRequiredEvent = driver.GetUpdateRequiredEvent();
        }

        public override void Dispose()
        {
            _realSession.Dispose();
        }

        public override ulong GetPlayedSampleCount()
        {
            lock (_sampleCountLock)
            {
                // Update the played samples count.
                WasBufferFullyConsumed(null);

                return _playedSamplesCount;
            }
        }

        public override float GetVolume()
        {
            return _realSession.GetVolume();
        }

        public override void PrepareToClose()
        {
            _realSession.PrepareToClose();
        }

        public override void QueueBuffer(AudioBuffer buffer)
        {
            _realSession.QueueBuffer(buffer);

            ulong samples = GetSampleCount(buffer);

            lock (_sampleCountLock)
            {
                _buffers.Add(buffer);
            }

            _updateRequiredEvent.Set();
        }

        public override ulong GetSampleCount(int dataSize)
        {
            return _realSession.GetSampleCount(dataSize);
        }

        public override void SetVolume(float volume)
        {
            _realSession.SetVolume(volume);
        }

        public override void Start()
        {
            _realSession.Start();
        }

        public override void Stop()
        {
            _realSession.Stop();
        }

        private ulong _playedSamplesCount = 0;
        private int _frontIndex = -1;

        public override bool WasBufferFullyConsumed(AudioBuffer buffer)
        {
            ulong delaySamples = 0;
            bool isConsumed = true;
            // True if it's in the _delayedSamples range.
            lock (_sampleCountLock)
            {
                for (int i = 0; i < _buffers.Count; i++)
                {
                    AudioBuffer elem = _buffers[i];
                    isConsumed = isConsumed && _realSession.WasBufferFullyConsumed(elem);
                    ulong samples = GetSampleCount(elem);

                    bool afterFront = i > _frontIndex;

                    if (isConsumed)
                    {
                        if (_frontIndex > -1)
                        {
                            _frontIndex--;
                        }

                        _buffers.RemoveAt(i--);

                        if (afterFront)
                        {
                            _playedSamplesCount += samples;
                        }

                        if (buffer == elem)
                        {
                            return true;
                        }
                    }
                    else
                    {
                        if (afterFront && delaySamples < _delayTarget)
                        {
                            _playedSamplesCount += samples;
                            _frontIndex = i;
                        }

                        if (buffer == elem)
                        {
                            return i <= _frontIndex;
                        }

                        delaySamples += samples;
                    }
                }

                // Buffer was not queued.
                return true;
            }
        }

        public override bool RegisterBuffer(AudioBuffer buffer, byte[] samples)
        {
            return _realSession.RegisterBuffer(buffer, samples);
        }
    }
}
