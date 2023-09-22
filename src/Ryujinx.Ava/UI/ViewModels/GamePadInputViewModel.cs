using Ryujinx.Ava.UI.Models;
using Ryujinx.Ava.UI.Views.Input;
using Ryujinx.Common.Configuration.Hid;
using System;
using ConfigGamepadInputId = Ryujinx.Common.Configuration.Hid.Controller.GamepadInputId;
using ConfigStickInputId = Ryujinx.Common.Configuration.Hid.Controller.StickInputId;

namespace Ryujinx.Ava.UI.ViewModels
{
    public class GamePadInputViewModel : InputViewModel
    {
        private InputConfiguration<ConfigGamepadInputId, ConfigStickInputId> _configuration;
        private Func<System.Threading.Tasks.Task> _showMotionConfigCommand;
        private Func<System.Threading.Tasks.Task> _showRumbleConfigCommand;


        public InputConfiguration<ConfigGamepadInputId, ConfigStickInputId> Configuration
        {
            get => _configuration;
            set
            {
                _configuration = value;

                OnPropertyChanged();
            }
        }

        internal override object Config => _configuration;

        public GamePadInputViewModel(InputConfiguration<ConfigGamepadInputId, ConfigStickInputId> configuration, Func<System.Threading.Tasks.Task> showMotionConfigCommand, Func<System.Threading.Tasks.Task> showRumbleConfigCommand)
        {
            Configuration = configuration;
            _showMotionConfigCommand = showMotionConfigCommand;
            _showRumbleConfigCommand = showRumbleConfigCommand;
        }

        public GamePadInputViewModel()
        {
        }

        public override void NotifyChanges()
        {
            OnPropertyChanged(nameof(Configuration));

            base.NotifyChanges();
        }

        public override InputConfig GetConfig()
        {
            return _configuration.GetConfig();
        }

        public async void ShowMotionConfig()
        {
            await _showMotionConfigCommand();
        }

        public async void ShowRumbleConfig()
        {
           await _showRumbleConfigCommand();
        }
    }
}
