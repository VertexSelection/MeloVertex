using Ryujinx.Common.Configuration;
using Ryujinx.Common.Logging;
using Ryujinx.Input;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.Numerics;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;

namespace Ryujinx.Headless.SDL2
{
    class iOSTouchDriver : IGamepadDriver
    {
        private const int CursorHideIdleTime = 5;

        private bool _isDisposed;
        private readonly HideCursorMode _hideCursorMode;
        private bool _isHidden;
        private long _lastCursorMoveTime;

        public bool[] PressedButtons { get; }
        public Vector2 CurrentPosition { get; private set; }
        public Vector2 Scroll { get; private set; }
        public Size ClientSize;

        private static Dictionary<int, Vector2> _activeTouches = new();

        public iOSTouchDriver(HideCursorMode hideCursorMode)
        {
            PressedButtons = new bool[(int)MouseButton.Count];
            _hideCursorMode = hideCursorMode;
        }

        [UnmanagedCallersOnly(EntryPoint = "touch_began")]
        public static void TouchBeganAtPoint(float x, float y, int index)
        {
            Vector2 position = new Vector2(x, y);
            _activeTouches[index] = position;
        }

        [UnmanagedCallersOnly(EntryPoint = "touch_moved")]
        public static void TouchMovedAtPoint(float x, float y, int index)
        {
            if (_activeTouches.ContainsKey(index))
            {
                _activeTouches[index] = new Vector2(x, y);
            }
        }

        [UnmanagedCallersOnly(EntryPoint = "touch_ended")]
        public static void TouchEndedForIndex(int index)
        {
            if (_activeTouches.ContainsKey(index))
            {
                _activeTouches.Remove(index);
            }
        }

        public void UpdatePosition()
        {
            if (_activeTouches.Count > 0)
            {
                var touch = _activeTouches.Values.GetEnumerator();
                touch.MoveNext(); 
                Vector2 position = touch.Current;

                if (CurrentPosition != position)
                {
                    CurrentPosition = position;
                    _lastCursorMoveTime = Stopwatch.GetTimestamp();
                }
            }

            CheckIdle();
        }

        private void CheckIdle()
        {
            if (_hideCursorMode != HideCursorMode.OnIdle)
            {
                return;
            }

            long cursorMoveDelta = Stopwatch.GetTimestamp() - _lastCursorMoveTime;

            if (cursorMoveDelta >= CursorHideIdleTime * Stopwatch.Frequency)
            {
                if (!_isHidden)
                {
                    Logger.Debug?.Print(LogClass.Application, "Hiding cursor due to inactivity.");
                    _isHidden = true;
                }
            }
            else
            {
                if (_isHidden)
                {
                    Logger.Debug?.Print(LogClass.Application, "Showing cursor after activity.");
                    _isHidden = false;
                }
            }
        }


        public void SetClientSize(int width, int height)
        {
            ClientSize = new Size(width, height);
        }

        public bool IsButtonPressed(MouseButton button)
        {
            if (_activeTouches.Count > 0)
            {
                return true;
            }
            return false;
        }

        public Size GetClientSize()
        {
            return ClientSize;
        }

        public string DriverName => "iOSTouchDriver";

        public event Action<string> OnGamepadConnected
        {
            add { }
            remove { }
        }

        public event Action<string> OnGamepadDisconnected
        {
            add { }
            remove { }
        }

        public ReadOnlySpan<string> GamepadsIds => new[] { "0" };

        public IGamepad GetGamepad(string id)
        {
            return new iOSMouse(this);
        }

        public void Dispose()
        {
            if (_isDisposed)
            {
                return;
            }
            _isDisposed = true;
        }
    }
}
