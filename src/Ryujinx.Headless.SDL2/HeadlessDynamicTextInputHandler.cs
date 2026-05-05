using Ryujinx.HLE.UI;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Ryujinx.Headless.SDL2
{
    /// <summary>
    /// Headless text processing class.
    /// On iOS this bridges inline keyboard requests to the native alert text input.
    /// </summary>
    internal class HeadlessDynamicTextInputHandler : IDynamicTextInputHandler
    {
        private const string IosKeyboardTitle = "MeloVertex Keyboard";

        private bool _canProcessInput;
        private bool _iosPromptPending;
        private int _iosPromptToken;
        private string _text = string.Empty;
        private readonly object _iosPromptLock = new();

        public event DynamicTextChangedHandler TextChangedEvent;
        public event KeyPressedHandler KeyPressedEvent { add { } remove { } }
        public event KeyReleasedHandler KeyReleasedEvent { add { } remove { } }

        public bool TextProcessingEnabled
        {
            get
            {
                return Volatile.Read(ref _canProcessInput);
            }

            set
            {
                bool wasEnabled = Volatile.Read(ref _canProcessInput);
                Volatile.Write(ref _canProcessInput, value);

                if (!value)
                {
                    lock (_iosPromptLock)
                    {
                        _iosPromptPending = false;
                        _iosPromptToken++;
                    }

                    return;
                }

                if (wasEnabled)
                {
                    return;
                }

                if (OperatingSystem.IsIOS())
                {
                    ShowIosKeyboardPrompt();
                }
                else
                {
                    // Keep the old fallback for non-iOS headless environments.
                    Task.Run(() =>
                    {
                        Thread.Sleep(100);

                        if (Volatile.Read(ref _canProcessInput))
                        {
                            TextChangedEvent?.Invoke("MeloNX", 7, 7, false);
                        }
                    });
                }
            }
        }

        public HeadlessDynamicTextInputHandler()
        {
            // Start with input processing turned off so the text box won't accumulate text
            // if the user is playing on the keyboard.
            _canProcessInput = false;
        }

        public void SetText(string text, int cursorBegin)
        {
            lock (_iosPromptLock)
            {
                _text = text ?? string.Empty;
            }
        }

        public void SetText(string text, int cursorBegin, int cursorEnd)
        {
            lock (_iosPromptLock)
            {
                _text = text ?? string.Empty;
            }
        }

        private void ShowIosKeyboardPrompt()
        {
            int promptToken;
            string placeholder;

            lock (_iosPromptLock)
            {
                if (_iosPromptPending)
                {
                    return;
                }

                _iosPromptPending = true;
                promptToken = ++_iosPromptToken;
                placeholder = _text;
            }

            AlertHelper.ShowAlertWithTextInput(IosKeyboardTitle, string.Empty, placeholder, inputText =>
            {
                string text = inputText ?? string.Empty;

                bool shouldPublish;

                lock (_iosPromptLock)
                {
                    shouldPublish = _iosPromptPending && promptToken == _iosPromptToken;
                    _iosPromptPending = false;

                    if (shouldPublish)
                    {
                        _text = text;
                    }
                }

                if (shouldPublish && Volatile.Read(ref _canProcessInput))
                {
                    TextChangedEvent?.Invoke(text, text.Length, text.Length, false);
                }
            });
        }

        public void Dispose() { }
    }
}
