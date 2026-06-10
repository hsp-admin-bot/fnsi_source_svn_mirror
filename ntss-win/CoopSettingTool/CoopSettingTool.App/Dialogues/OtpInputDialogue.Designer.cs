// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-16-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-16-2021
// ***********************************************************************
// <copyright file="OtpInputDialogue.Designer.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************

namespace CoopSettingTool.App.Dialogues
{
    /// <summary>
    /// Class OtpInputDialogue.
    /// Implements the <see cref="MaterialSkin.Controls.MaterialForm" />
    /// </summary>
    /// <seealso cref="MaterialSkin.Controls.MaterialForm" />
    partial class OtpInputDialogue
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.txtOtp = new System.Windows.Forms.TextBox();
            this.btnSendOtp = new MaterialSkin.Controls.MaterialRaisedButton();
            this.btnCancel = new MaterialSkin.Controls.MaterialRaisedButton();
            this.SuspendLayout();
            // 
            // txtOtp
            // 
            this.txtOtp.Location = new System.Drawing.Point(70, 89);
            this.txtOtp.Name = "txtOtp";
            this.txtOtp.Size = new System.Drawing.Size(132, 19);
            this.txtOtp.TabIndex = 14;
            this.txtOtp.TextChanged += new System.EventHandler(this.txtOtp_TextChanged);
            // 
            // btnSendOtp
            // 
            this.btnSendOtp.Depth = 0;
            this.btnSendOtp.Location = new System.Drawing.Point(34, 132);
            this.btnSendOtp.MouseState = MaterialSkin.MouseState.HOVER;
            this.btnSendOtp.Name = "btnSendOtp";
            this.btnSendOtp.Primary = true;
            this.btnSendOtp.Size = new System.Drawing.Size(67, 29);
            this.btnSendOtp.TabIndex = 15;
            this.btnSendOtp.Text = "送信";
            this.btnSendOtp.UseVisualStyleBackColor = true;
            this.btnSendOtp.Click += new System.EventHandler(this.btnSendOtp_Click);
            // 
            // btnCancel
            // 
            this.btnCancel.Depth = 0;
            this.btnCancel.Location = new System.Drawing.Point(169, 132);
            this.btnCancel.MouseState = MaterialSkin.MouseState.HOVER;
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Primary = true;
            this.btnCancel.Size = new System.Drawing.Size(64, 29);
            this.btnCancel.TabIndex = 16;
            this.btnCancel.Text = "キャンセル";
            this.btnCancel.UseVisualStyleBackColor = true;
            this.btnCancel.Click += new System.EventHandler(this.btnCancel_Click);
            // 
            // OtpInputDialogue
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(265, 184);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.btnSendOtp);
            this.Controls.Add(this.txtOtp);
            this.MaximizeBox = true;
            this.Name = "OtpInputDialogue";
            this.Sizable = true;
            this.Text = "ワンタイムパスワード";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion
        /// <summary>
        /// The text otp
        /// </summary>
        private System.Windows.Forms.TextBox txtOtp;
        /// <summary>
        /// The BTN send otp
        /// </summary>
        private MaterialSkin.Controls.MaterialRaisedButton btnSendOtp;
        /// <summary>
        /// The BTN cancel
        /// </summary>
        private MaterialSkin.Controls.MaterialRaisedButton btnCancel;
    }
}