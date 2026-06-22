// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-16-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-12-2021
// ***********************************************************************
// <copyright file="LoginView.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.App.Controllers;
using CoopSettingTool.App.DI;
using CoopSettingTool.App.Dialogues;
using CoopSettingTool.App.Models;
using CoopSettingTool.App.Properties;
using System;
using System.Windows.Forms;

namespace CoopSettingTool.App.Views
{
    /// <summary>
    /// Class LoginView.
    /// Implements the <see cref="CoopSettingTool.App.Views.BaseView" />
    /// Implements the <see cref="CoopSettingTool.App.Views.ILoginView" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Views.BaseView" />
    /// <seealso cref="CoopSettingTool.App.Views.ILoginView" />
    public partial class LoginView : BaseView, ILoginView
    {
        /// <summary>
        /// The controller
        /// </summary>
        private ILoginController controller;

        /// <summary>
        /// The otp input dialogue
        /// </summary>
        private OtpInputDialogue otpInputDialogue;

        /// <summary>
        /// The main menu view
        /// </summary>
        private IMainMenuView mainMenuView;

        /// <summary>
        /// パスワード
        /// </summary>
        private string mPassword;

        /// <summary>
        /// Gets the user identifier.
        /// </summary>
        /// <value>The user identifier.</value>
        public string UserID { get => this.txtUserID.Text;  }
        /// <summary>
        /// Gets the password.
        /// </summary>
        /// <value>The password.</value>
        public string Password { get => mPassword;  }
        /// <summary>
        /// Gets the otp.
        /// </summary>
        /// <value>The otp.</value>
        public string Otp { get => this.otpInputDialogue.Tag.ToString();  }

        /// <summary>
        /// Initializes a new instance of the <see cref="LoginView"/> class.
        /// </summary>
        /// <param name="model">The model.</param>
        public LoginView(ILoginModel model)
        {
            InitializeComponent();

            otpInputDialogue = new OtpInputDialogue();

            mainMenuView = CompositionRoot.Resolve<IMainMenuView>();

            ILoginController cont = new LoginController(this, model);
            this.SetController(cont);
            this.RegisterEvent();
            this.txtUserID.Select();
        }

        /// <summary>
        /// Sets the controller.
        /// </summary>
        /// <param name="loginController">The login controller.</param>
        public void SetController(ILoginController loginController)
        {
            this.controller = loginController;
        }

        /// <summary>
        /// Registers the event.
        /// </summary>
        public void RegisterEvent()
        {
            this.btnLogin.Click += BtnLogin_Click;
            this.KeyDown += new KeyEventHandler(LoginView_KeyDown);
            this.txtPassword.KeyDown += new KeyEventHandler(LoginView_KeyDown);
            this.txtUserID.KeyDown += new KeyEventHandler(LoginView_KeyDown);
            this.lblLoading.Visible = false;
        }

        /// <summary>
        /// Handles the KeyDown event of the LoginView control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="KeyEventArgs"/> instance containing the event data.</param>
        private void LoginView_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                BtnLogin_Click(null, null);
            }
        }

        /// <summary>
        /// Handles the Click event of the BtnLogin control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void BtnLogin_Click(object sender, EventArgs e)
        {
            // 画面のパスワードを片付ける
            this.mPassword = this.txtPassword.Text;
            this.txtPassword.Text = string.Empty;

            if (string.IsNullOrEmpty(this.UserID) || string.IsNullOrEmpty(this.Password))
            {
                this.ShowMessage(Resources.ENTER_YOUR_LOGIN_INFORMATION, Resources.ERROR, Enums.MessageTypeEnum.ERROR);
            }
            else
            {
                this.controller.LoginAsync();
            }
        }

        /// <summary>
        /// Delegate ShowMainMenuViewCallback
        /// </summary>
        private delegate void ShowMainMenuViewCallback();
        /// <summary>
        /// Shows the main menu view.
        /// </summary>
        public void ShowMainMenuView()
        {
            if (this.InvokeRequired)
            {
                ShowMainMenuViewCallback calback = new ShowMainMenuViewCallback(ShowMainMenuView);
                this.Invoke(calback);
            }
            else
            {
                this.HideView();
                if (this.mainMenuView.ShowDialog(this) != DialogResult.OK)
                {
                    this.txtUserID.Text = string.Empty;
                    this.txtPassword.Text = string.Empty;
                    if(this.otpInputDialogue != null)
                    {
                        this.otpInputDialogue.Tag = string.Empty;
                    }
                    this.ShowView();
                }
                else
                {
                    this.CloseView(DialogResult.Cancel);
                }
            }

        }

        /// <summary>
        /// Delegate ShowOtpDialogue
        /// </summary>
        private delegate DialogResult ShowOtpDialogueCallback();

        /// <summary>
        /// Shows the otp dialogue.
        /// </summary>
        /// <returns>DialogResult.</returns>
        public DialogResult ShowOtpDialogue()
        {
            if (this.InvokeRequired)
            {
                ShowOtpDialogueCallback calback = new ShowOtpDialogueCallback(ShowOtpDialogue);
                return (DialogResult)this.Invoke(calback);
            }
            else
            {
                return this.otpInputDialogue.ShowDialog(this);
            }
        }
    }
}
