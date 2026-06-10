using LDT.APP.Enums;
using LDT.APP.Views.interfaces;
using MaterialSkin;
using MaterialSkin.Controls;
using System.Windows.Forms;

namespace LDT.APP.Views.implements
{
  public class BaseView : MaterialForm, IBaseView
    {
        public BaseView()
        {
            var materialSkinManager = MaterialSkinManager.Instance;
            materialSkinManager.AddFormToManage(this);
            materialSkinManager.Theme = MaterialSkinManager.Themes.LIGHT;
            materialSkinManager.ColorScheme = new ColorScheme(Primary.BlueGrey800, Primary.BlueGrey900, Primary.BlueGrey500, Accent.LightBlue200, TextShade.WHITE);
        }

        private delegate void CloseViewCallBack();

        public virtual void CloseView()
        {
            if (this.InvokeRequired)
            {
                CloseViewCallBack callBack = new CloseViewCallBack(CloseView);
                this.Invoke(callBack);
            }
            else
            {
                this.Visible = false;
                this.Close();
            }
        }

        private delegate void HideViewCallBack();

        public virtual void HideView()
        {
            if (this.InvokeRequired)
            {
                HideViewCallBack callBack = new HideViewCallBack(HideView);
                this.Invoke(callBack);
            }
            else
            {
                this.Visible = false;
                this.Hide();
            }
        }

        public virtual void ShowMessage(string message, string caption, MessageTypeEnum type)
        {
            MessageBoxIcon icon;
            switch (type)
            {
                case MessageTypeEnum.WARNING:
                    icon = MessageBoxIcon.Warning;
                    break;

                case MessageTypeEnum.INFORMATION:
                    icon = MessageBoxIcon.Information;
                    break;

                case MessageTypeEnum.ERROR:
                    icon = MessageBoxIcon.Error;
                    break;

                case MessageTypeEnum.SUCCESS:
                    icon = MessageBoxIcon.Information;
                    break;

                default:
                    icon = MessageBoxIcon.None;
                    break;
            }

            MessageBox.Show(message, caption, MessageBoxButtons.OK, icon);
        }

        private delegate Form ShowViewCallBack();

        public virtual Form ShowView()
        {
            if (this.InvokeRequired)
            {
                ShowViewCallBack callBack = new ShowViewCallBack(ShowView);
                this.Invoke(callBack);
            }
            else
            {
                this.Visible = true;
                this.Show();
            }
            return this;
        }
    }
}
