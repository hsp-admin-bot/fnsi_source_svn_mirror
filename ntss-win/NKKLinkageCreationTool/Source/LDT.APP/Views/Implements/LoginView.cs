using LDT.APP.Controllers;
using LDT.APP.Controllers.Interfaces;
using LDT.APP.Models;
using LDT.APP.Properties;
using LDT.APP.Views.implements;
using LDT.SERVICE.Interfaces;
using MaterialSkin;
using System;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace LDT.APP.Views
{
  public partial class LoginView : BaseView, ILoginView
  {
    private ILoginController _loginController;

    public string UserID { get => txtUserID.Text; set { } }
    public string Password { get => txtPassword.Text; set { } }

    public LoginView(ILoginModel model, IUserService userService)
    {
      InitializeComponent();
      var materialSkinManager = MaterialSkinManager.Instance;
      materialSkinManager.AddFormToManage(this);
      materialSkinManager.Theme = MaterialSkinManager.Themes.LIGHT;
      materialSkinManager.ColorScheme = new ColorScheme(Primary.BlueGrey800, Primary.BlueGrey900, Primary.BlueGrey500, Accent.LightBlue200, TextShade.WHITE);
      ILoginController cont = new LoginController(this, model, userService);
      this.SetController(cont);
      this.RegisterEvent();
      txtUserID.Select();
    }

    public void SetController(ILoginController loginController)
    {
      this._loginController = loginController;
    }

    public void RegisterEvent()
    {
      btnLogin.Click += BtnLogin_Click;
      this.KeyDown += new KeyEventHandler(LoginView_KeyDown);
      txtPassword.KeyDown += new KeyEventHandler(LoginView_KeyDown);
      txtUserID.KeyDown += new KeyEventHandler(LoginView_KeyDown);
      this.lblLoading.Visible = false;
    }

    private void LoginView_KeyDown(object sender, KeyEventArgs e)
    {
      if (e.KeyCode == Keys.Enter)
      {
        BtnLogin_Click(null, null);
      }
    }

    private async void BtnLogin_Click(object sender, EventArgs e)
    {
      if (string.IsNullOrEmpty(this.UserID) || string.IsNullOrEmpty(this.Password))
      {
        this.ShowMessage(Resources.ENTER_YOUR_LOGIN_INFORMATION, Resources.ERROR, Enums.MessageTypeEnum.ERROR);
      }
      else
      {
        await _loginController.LoginAsync();
      }
    }

    public void HandleNextView(Form nextView)
    {
      if (nextView != null)
      {
        nextView.VisibleChanged += new EventHandler(NextView_VisibleChanged);
      }
    }

    private void NextView_VisibleChanged(object sender, EventArgs e)
    {
      dynamic nextView = sender as dynamic;
      if (nextView.IsCancel == true)
      {
        this._loginController.ClearCookie();
        this.Show();
      }
    }

    private delegate void SetTextLoadingCallback(string text);

    private void SetTextLoading(string text)
    {
      if (lblLoading.InvokeRequired)
      {
        SetTextLoadingCallback callback = new SetTextLoadingCallback(SetTextLoading);
        this.Invoke(callback, new object[] { text });
      }
      else
      {
        lblLoading.Text = text;
        lblLoading.Refresh();
      }
    }

    public void RunLoading()
    {
      this.lblLoading.Visible = true;
      Task.Run(() =>
      {
        while (true)
        {
          if (this.lblLoading.Visible)
          {
            SetTextLoading(Resources.WAITING_FOR_EXECUTED);
            Task.Delay(1000);
            SetTextLoading($"{Resources.WAITING_FOR_EXECUTED} .");
            Task.Delay(1000);
            SetTextLoading($"{Resources.WAITING_FOR_EXECUTED} . . ");
            Task.Delay(1000);
            SetTextLoading($"{Resources.WAITING_FOR_EXECUTED} . . .");
          }
          else
          {
            return;
          }
        }
      });
    }

    public void StopLoading()
    {
      this.lblLoading.Visible = false;
    }
  }
}
