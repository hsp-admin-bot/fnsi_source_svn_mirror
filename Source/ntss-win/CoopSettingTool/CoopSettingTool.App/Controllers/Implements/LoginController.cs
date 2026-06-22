// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-16-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-20-2021
// ***********************************************************************
// <copyright file="LoginController.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.App.Models;
using CoopSettingTool.App.Properties;
using CoopSettingTool.App.Views;
using CoopSettingTool.Service;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace CoopSettingTool.App.Controllers
{
    /// <summary>
    /// Class LoginController.
    /// Implements the <see cref="CoopSettingTool.App.Controllers.BaseController{CoopSettingTool.App.Views.ILoginView, CoopSettingTool.App.Models.ILoginModel}" />
    /// Implements the <see cref="CoopSettingTool.App.Controllers.ILoginController" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Controllers.BaseController{CoopSettingTool.App.Views.ILoginView, CoopSettingTool.App.Models.ILoginModel}" />
    /// <seealso cref="CoopSettingTool.App.Controllers.ILoginController" />
    public class LoginController : BaseController<ILoginView, ILoginModel>, ILoginController
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="LoginController"/> class.
        /// </summary>
        /// <param name="view">The view.</param>
        /// <param name="model">The model.</param>
        public LoginController(ILoginView view, ILoginModel model) : base(view, model)
        {
        }

        /// <summary>
        /// login as an asynchronous operation.
        /// </summary>
        /// <returns>A Task representing the asynchronous operation.</returns>
        public async Task LoginAsync()
        {
            this.View.ShowLoading();

            int rs = await Task.Run(() =>
            {
                int ret = 0;
                string message = string.Empty;

                var result = ServerAccess.GetInstance().SignIn(View.UserID, View.Password, "").Result;
                if (result.StatusCode == System.Net.HttpStatusCode.OK)
                {
                    if (string.IsNullOrEmpty(result.Data.FacilityCode))
                    {
                        int otpFailureCnt = 5;
                        // <2要素認証のOTP確認処理>
                        for (int i = 0; i < otpFailureCnt; i++)
                        {
                            if (DialogResult.OK == this.View.ShowOtpDialogue())
                            {
                                result = ServerAccess.GetInstance().SignIn(View.UserID, View.Password, this.View.Otp).Result;
                                if (result.StatusCode == System.Net.HttpStatusCode.OK)
                                {
                                    ret = 1;
                                    break;
                                }
                                else
                                {
                                    if (i + 1 >= otpFailureCnt)
                                    {
                                        // OTP試行回数上限まで失敗したら固定エラー文言(※WebCLも同じ仕様)に置き換え
                                        message = string.Format(Resources.WARNING_OTP_NOT_MATCH_MAX, otpFailureCnt);
                                    }
                                    else
                                    {
                                        message = result.Error.Message;
                                    }

                                    this.View.ShowMessage(message, Resources.WARNING, Enums.MessageTypeEnum.WARNING);
                                }
                            }
                            else
                            {
                                break;
                            }
                        }
                    }
                    else
                    {
                        ret = 1;
                    }
                }
                else if (result.StatusCode == System.Net.HttpStatusCode.ServiceUnavailable)
                {
                    this.View.ShowMessage(Resources.SERVICE_UNAVAILABLE + message, Resources.ERROR, Enums.MessageTypeEnum.ERROR);
                }
                else if (result.StatusCode == System.Net.HttpStatusCode.Forbidden
                && result.Error != null
                && (result.Error.Message.CompareTo("認証に失敗しました。認証情報を確認して下さい。") == 0
                || result.Error.Message.CompareTo("Bad credentials") == 0))
                {
                    this.View.ShowMessage(Resources.LOGIN_FAILED, Resources.ERROR, Enums.MessageTypeEnum.ERROR);
                }
                else
                {
                    ret = -1;
                    message = string.Empty;
                    if (result.Error != null)
                    {
                        if(result.Error.Message.CompareTo("このユーザーはアカウントロックされています。管理者にお問い合わせください。") == 0)
                        {
                            message = result.Error.Message;
                        }
                    }

                    if(string.IsNullOrEmpty(message))
                    {
                        message = Resources.ERROR_CONNECT_FAILED;
                    }

                    this.View.ShowMessage(message + "\r\n" + "アプリを終了します。", Resources.ERROR, Enums.MessageTypeEnum.ERROR);
                }
                return ret;
            });

            this.View.HideLoading();

            if (rs == 1)
            {
                this.View.ShowMainMenuView();
            }

            if (rs == -1)
            {
                this.View.CloseView(System.Windows.Forms.DialogResult.Abort);
            }
        }

        /// <summary>
        /// Shows the view.
        /// </summary>
        public void ShowView()
        {
            this.View.ShowView();
        }
    }
}
