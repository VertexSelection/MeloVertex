using Avalonia.Svg.Skia;
using Ryujinx.Ava.UI.Models;
using Ryujinx.Common;
using Ryujinx.Common.Configuration.Hid;
using ConfigStickInputId = Ryujinx.Common.Configuration.Hid.Controller.StickInputId;
using Key = Ryujinx.Common.Configuration.Hid.Key;

namespace Ryujinx.Ava.UI.ViewModels
{
    public abstract class InputViewModel : BaseModel
    {
        private string _controllerImage;

        public bool IsRight { get; set; }
        public bool IsLeft { get; set; }

        internal abstract object Config { get; }

        public void NotifyChange(string property)
        {
            OnPropertyChanged(property);
        }

        public string ControllerImage
        {
            get => _controllerImage;
            set
            {
                _controllerImage = value;

                OnPropertyChanged();
                OnPropertyChanged(nameof(Image));
            }
        }

        public SvgImage Image
        {
            get
            {
                SvgImage image = new();

                if (!string.IsNullOrWhiteSpace(_controllerImage))
                {
                    SvgSource source = new();

                    source.Load(EmbeddedResources.GetStream(_controllerImage));

                    image.Source = source;
                }

                return image;
            }
        }

        public virtual void NotifyChanges()
        {
            OnPropertyChanged(nameof(IsRight));
            OnPropertyChanged(nameof(IsLeft));
            OnPropertyChanged(nameof(Image));
        }

        public abstract InputConfig GetConfig();
    }
}
