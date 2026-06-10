// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-16-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-12-2021
// ***********************************************************************
// <copyright file="OtpInputDialogue.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using MaterialSkin.Controls;
using System;
using System.Windows.Forms;

namespace CoopSettingTool.App.Dialogues
{
    /// <summary>
    /// Class OtpInputDialogue.
    /// Implements the <see cref="MaterialSkin.Controls.MaterialForm" />
    /// </summary>
    /// <seealso cref="MaterialSkin.Controls.MaterialForm" />
    public partial class OtpInputDialogue : MaterialForm
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="OtpInputDialogue"/> class.
        /// </summary>
        public OtpInputDialogue()
        {
            InitializeComponent();
            this.StartPosition = FormStartPosition.CenterParent;
            this.KeyDown += new KeyEventHandler(OtpInputDialogue_KeyDown);
            this.txtOtp.KeyDown += new KeyEventHandler(OtpInputDialogue_KeyDown);

            // アイコンの設定
            this.Icon = Properties.Resources.CoopSettingTool;
        }

        /// <summary>
        /// Handles the KeyDown event of the OtpInputDialogue control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="KeyEventArgs"/> instance containing the event data.</param>
        /// <exception cref="NotImplementedException"></exception>
        private void OtpInputDialogue_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                btnSendOtp_Click(null, null);
            }
        }

        /// <summary>
        /// Handles the Click event of the btnSendOtp control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void btnSendOtp_Click(object sender, EventArgs e)
        {
            DialogResult = DialogResult.OK;
            Tag = txtOtp.Text;
            txtOtp.Text = string.Empty;
            Close();
        }

        /// <summary>
        /// Handles the TextChanged event of the txtOtp control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void txtOtp_TextChanged(object sender, EventArgs e)
        {
            if (1 <= txtOtp.TextLength && false == string.IsNullOrWhiteSpace(txtOtp.Text))
            {
                btnSendOtp.Enabled = true;
            }
            else
            {
                btnSendOtp.Enabled = false;
            }
        }

        /// <summary>
        /// Handles the Click event of the btnCancel control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void btnCancel_Click(object sender, EventArgs e)
        {
            DialogResult = DialogResult.Cancel;
            Close();
        }
    }
}
