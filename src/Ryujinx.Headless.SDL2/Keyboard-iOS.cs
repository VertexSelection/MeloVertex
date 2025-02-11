using System;
using System.Runtime.InteropServices;
using Ryujinx.Ui.Common.Helper;
using System.Threading;

namespace Ryujinx.Headless.SDL2
{
    public static class AlertHelper
    {
        [DllImport("RyujinxKeyboard.framework/RyujinxKeyboard", CallingConvention = CallingConvention.Cdecl)]
        public static extern void showKeyboardAlert(string title, string message, string placeholder);

        [DllImport("RyujinxKeyboard.framework/RyujinxKeyboard", CallingConvention = CallingConvention.Cdecl)]
        private static extern IntPtr getKeyboardInput();

        [DllImport("RyujinxKeyboard.framework/RyujinxKeyboard", CallingConvention = CallingConvention.Cdecl)]
        private static extern void clearKeyboardInput();

        public static void ShowAlertWithTextInput(string title, string message, string placeholder, Action<string> onTextEntered)
        {
            showKeyboardAlert(title, message, placeholder);

            ThreadPool.QueueUserWorkItem(_ =>
            {
                string result = null;
                while (result == null)
                {
                    Thread.Sleep(100);

                    IntPtr inputPtr = getKeyboardInput();
                    if (inputPtr != IntPtr.Zero)
                    {
                        result = Marshal.PtrToStringAnsi(inputPtr);
                        clearKeyboardInput(); 

                        onTextEntered?.Invoke(result);
                    }
                }
            });
        }
    }
}
