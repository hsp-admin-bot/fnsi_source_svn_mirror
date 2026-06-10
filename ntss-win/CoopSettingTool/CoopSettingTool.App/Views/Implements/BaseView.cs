// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-16-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-20-2021
// ***********************************************************************
// <copyright file="BaseView.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.App.Dialogues;
using CoopSettingTool.App.Enums;
using MaterialSkin;
using MaterialSkin.Controls;
using System.Drawing;
using System.Windows.Forms;

namespace CoopSettingTool.App.Views
{
    /// <summary>
    /// Class BaseView.
    /// Implements the <see cref="MaterialSkin.Controls.MaterialForm" />
    /// Implements the <see cref="CoopSettingTool.App.Views.IBaseView" />
    /// </summary>
    /// <seealso cref="MaterialSkin.Controls.MaterialForm" />
    /// <seealso cref="CoopSettingTool.App.Views.IBaseView" />
    public class BaseView : MaterialForm, IBaseView
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="BaseView"/> class.
        /// </summary>
        public BaseView()
        {
            var materialSkinManager = MaterialSkinManager.Instance;
            materialSkinManager.AddFormToManage(this);
            materialSkinManager.Theme = MaterialSkinManager.Themes.LIGHT;
            materialSkinManager.ColorScheme = new ColorScheme(Primary.BlueGrey800, Primary.BlueGrey900, Primary.BlueGrey500, Accent.LightBlue200, TextShade.WHITE);
            this.Sizable = true;

            // アイコンの設定
            this.Icon = Properties.Resources.CoopSettingTool;
        }

        /// <summary>
        /// Delegate CloseViewCallBack
        /// </summary>
        private delegate void CloseViewCallBack(DialogResult dialogResult);

        /// <summary>
        /// Closes the view.
        /// </summary>
        public virtual void CloseView(DialogResult dialogResult)
        {
            if (this.InvokeRequired)
            {
                CloseViewCallBack callBack = new CloseViewCallBack(CloseView);
                this.Invoke(callBack, dialogResult);
            }
            else
            {
                this.DialogResult = dialogResult;
                this.Visible = false;
                this.Close();
            }
        }

        /// <summary>
        /// Delegate HideViewCallBack
        /// </summary>
        private delegate void HideViewCallBack();

        /// <summary>
        /// Hides the view.
        /// </summary>
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

        /// <summary>
        /// Shows the loading.
        /// </summary>
        public virtual void ShowLoading()
        {
            LoadingDialog.ShowView(this);
            this.Enabled = false;
        }

        /// <summary>
        /// Hides the loading.
        /// </summary>
        public virtual void HideLoading()
        {
            this.Enabled = true;
            LoadingDialog.CloseView(this);  
        }

        /// <summary>
        /// Shows the message.
        /// </summary>
        /// <param name="message">The message.</param>
        /// <param name="caption">The caption.</param>
        /// <param name="type">The type.</param>
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

        /// <summary>
        /// Shows the ask message.
        /// </summary>
        /// <param name="message">The message.</param>
        /// <param name="caption">The caption.</param>
        /// <param name="type">The type.</param>
        public virtual bool ShowAskMessage(string message, string caption, MessageTypeEnum type)
        {
            bool rs = false;
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

            if(MessageBox.Show(message, caption, MessageBoxButtons.YesNo, icon)== DialogResult.Yes)
            {
                rs = true;
            }

            return rs;
        }

        /// <summary>
        /// Delegate ShowViewCallBack
        /// </summary>
        /// <param name="parent">The parent.</param>
        /// <returns>Form.</returns>
        private delegate Form ShowViewCallBack(IWin32Window parent);

        /// <summary>
        /// Shows the view.
        /// </summary>
        /// <param name="parent">The parent.</param>
        /// <returns>Form.</returns>
        public virtual Form ShowView(IWin32Window parent = null)
        {
            if (this.InvokeRequired)
            {
                ShowViewCallBack callBack = new ShowViewCallBack(ShowView);
                this.Invoke(callBack);
            }
            else
            {
                this.Visible = true;
                if (parent == null)
                {
                    this.Show();
                }
                else
                {
                    this.Show(parent);
                }
            }
            return this;
        }
        /// <summary>
        /// Windowsメッセージを処理します。
        /// </summary>
        /// <param name="m">処理するWindowsメッセージ。</param>
        protected override void WndProc(ref Message m)
        {
            if (m.Msg == 0x20) // WM_SETCURSOR (カーソル設定)
            {
                int hitTest = m.LParam.ToInt32() & 0xFFFF;
                if (hitTest == 12) // HTTOP (上辺境界)
                {
                    Cursor.Current = Cursors.SizeNS;
                    m.Result = (System.IntPtr)1;
                    return;
                }
                else if (hitTest == 13) // HTTOPLEFT (左上境界)
                {
                    Cursor.Current = Cursors.SizeNWSE;
                    m.Result = (System.IntPtr)1;
                    return;
                }
                else if (hitTest == 14) // HTTOPRIGHT (右上境界)
                {
                    Cursor.Current = Cursors.SizeNESW;
                    m.Result = (System.IntPtr)1;
                    return;
                }
            }

            if (m.Msg == 0x84) // WM_NCHITTEST (ヒットテスト)
            {
                base.WndProc(ref m);
                if (this.WindowState == FormWindowState.Normal && this.Sizable)
                {
                    if ((int)m.Result == 0x1 || (int)m.Result == 0x2) // HTCLIENT (クライアント領域) または HTCAPTION (タイトルバー)
                    {
                        // 画面座標を取得
                        // LParamにはパックされた画面座標が入っているため、手動で展開する
                        int x = (short)(m.LParam.ToInt32() & 0xFFFF);
                        int y = (short)((m.LParam.ToInt32() >> 16) & 0xFFFF);
                        Point clientPoint = this.PointToClient(new Point(x, y));

                        // ウィンドウ上端付近 (5px以内)
                        if (clientPoint.Y <= 5)
                        {
                            // 左右の角の判定範囲 (10px)
                            if (clientPoint.X <= 10)
                            {
                                m.Result = (System.IntPtr)13; // HTTOPLEFT
                            }
                            else if (clientPoint.X >= this.ClientSize.Width - 10)
                            {
                                m.Result = (System.IntPtr)14; // HTTOPRIGHT
                            }
                            else
                            {
                                m.Result = (System.IntPtr)12; // HTTOP
                            }
                        }
                    }
                }
                return;
            }
            base.WndProc(ref m);
        }
    }
}
