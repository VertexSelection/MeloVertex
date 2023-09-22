using Ryujinx.Ava.UI.Models;
using Ryujinx.Common.Configuration.Hid;
using ConfigStickInputId = Ryujinx.Common.Configuration.Hid.Controller.StickInputId;
using Key = Ryujinx.Common.Configuration.Hid.Key;

namespace Ryujinx.Ava.UI.ViewModels
{
    public class KeyboardInputViewModel : InputViewModel
    {
        private InputConfiguration<Key, ConfigStickInputId> _configuration;


        public InputConfiguration<Key, ConfigStickInputId> Configuration
        {
            get => _configuration;
            set
            {
                _configuration = value;

                OnPropertyChanged();
            }
        }

        internal override object Config => _configuration;

        public KeyboardInputViewModel(InputConfiguration<Key, ConfigStickInputId> configuration)
        {
            Configuration = configuration;
        }

        public KeyboardInputViewModel()
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
    }
}
