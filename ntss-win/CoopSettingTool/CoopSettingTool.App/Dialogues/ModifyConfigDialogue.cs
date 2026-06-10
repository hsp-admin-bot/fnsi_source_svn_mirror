// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 10-22-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 10-25-2021
// ***********************************************************************
// <copyright file="ModifyConfigDialogue.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using System;
using System.Xml;
using System.Windows.Forms;
using CoopSettingTool.Service.Configuration;

namespace CoopSettingTool.App.Dialogues
{
    /// <summary>
    /// Class ModifyConfigDialogue.
    /// Implements the <see cref="System.Windows.Forms.Form" />
    /// </summary>
    /// <seealso cref="System.Windows.Forms.Form" />
    public partial class ModifyConfigDialogue : Form
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="ModifyConfigDialogue"/> class.
        /// </summary>
        public ModifyConfigDialogue()
        {
            InitializeComponent();
            GetConfig();
        }

        /// <summary>
        /// 元の証明書を使うフラグ
        /// </summary>
        bool orgCer = false;

        /// <summary>
        /// The configuration
        /// </summary>
        ApplicationConfigJSON config;

        /// <summary>
        /// The file path
        /// </summary>
        string filePath;

        /// <summary>
        /// Initializes a new instance of the <see cref="ModifyConfigDialogue"/> class.
        /// </summary>
        /// <param name="filepath">The filepath.</param>
        public ModifyConfigDialogue(string filepath)
        {
            filePath = System.IO.Path.Combine(filepath, CoopSettingTool.Service.Constant.API_CONFIG_FILE_PATH);
            InitializeComponent();
            GetConfig();

            // アイコンの設定
            this.Icon = Properties.Resources.CoopSettingTool;
        }

        /// <summary>
        /// OnShown
        /// </summary>
        /// <param name="e"></param>
        protected override void OnShown(EventArgs e)
        {
            BringToFrontEx();
            base.OnShown(e);
        }

        /// <summary>
        /// 他の画面より前に持つ
        /// </summary>
        public void BringToFrontEx()
        {
            if (InvokeRequired)
            {
                Invoke(new Action(BringToFrontEx));
            }
            else
            {
                this.TopMost = true;
                this.TopMost = false;
            }
        }

        /// <summary>
        /// Gets the configuration.
        /// </summary>
        public void GetConfig()
        {
            try
            {
                config = AppSettingConfig.LoadConfig(filePath);


                string strCer1 = config.API.CLIENT_CERTIFIATE_SEARCH_VALUE_1;
                string strCer2 = config.API.CLIENT_CERTIFIATE_SEARCH_VALUE_2;
                string strHash = config.API.FACILITY_CD;
                string strDomain = config.API.BASE_DOMAIN;

                if (!string.IsNullOrEmpty(strDomain))
                {
                    txtUrl.Text = string.Format(@"{0}/ntss-admin-web/#/?key={1}", strDomain, strHash);
                }

                if (!string.IsNullOrEmpty(strCer1) || !string.IsNullOrEmpty(strCer2))
                {
                    orgCer = true;
                    rbtnUseCer.Checked = true;
                }
                else
                {
                    rbtnNoCer.Checked = true;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("元の構成情報を取得できませんでした" + ex);
                throw;
            }
        }

        /// <summary>
        /// Handles the Click event of the btnConfirm control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void btnConfirm_Click(object sender, EventArgs e)
        {
            try
            {
                string[] seperator = new string[] { "//", "&", "/ntss-admin-web/#/?"};
                string[] splits = txtUrl.Text.Split(seperator, StringSplitOptions.RemoveEmptyEntries);

                // ハッシュコード
                config.API.FACILITY_CD = string.Empty;
                foreach (string split in splits)
                {
                    if(split.Contains("key="))
                    {
                        config.API.FACILITY_CD = split.Remove(0, 4);
                    }
                }

                // ドメイン
                if (splits.Length >= 2)
                {
                    config.API.BASE_DOMAIN = splits[0] + "//" + splits[1];
                }
                else
                {
                    config.API.BASE_DOMAIN = string.Empty;
                }

                // 証明書
                if (rbtnUseCer.Checked)
                {
                    // 元の証明書がない場合だけに設定する
                    if (!orgCer)
                    {
                        config.API.CLIENT_CERTIFIATE_SEARCH_VALUE_1 = "Medical Division";
                        config.API.CLIENT_CERTIFIATE_SEARCH_VALUE_2 = "Nikkiso Co., Ltd.";
                    }
                }
                else
                {
                    config.API.CLIENT_CERTIFIATE_SEARCH_VALUE_1 = string.Empty;
                    config.API.CLIENT_CERTIFIATE_SEARCH_VALUE_2 = string.Empty;
                }

                AppSettingConfig.SaveConfig(config, filePath);
                MessageBox.Show("正常に変更されました");
                this.Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show("編集に失敗する" + ex);
                throw;
            }
        }

        /// <summary>
        /// Handles the Click event of the btnConcel control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void btnConcel_Click(object sender, EventArgs e)
        {
            this.Close();
        }
    }
}
