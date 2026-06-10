namespace SignInLib
{
    partial class FrmOtpInput
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
            this.btnSendOtp = new System.Windows.Forms.Button();
            this.lblMsg = new System.Windows.Forms.Label();
            this.txtOtp = new System.Windows.Forms.TextBox();
            this.btnCancel = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // btnSendOtp
            // 
            this.btnSendOtp.Enabled = false;
            this.btnSendOtp.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnSendOtp.FlatAppearance.BorderSize = 2;
            this.btnSendOtp.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnSendOtp.Location = new System.Drawing.Point(12, 85);
            this.btnSendOtp.Name = "btnSendOtp";
            this.btnSendOtp.Size = new System.Drawing.Size(70, 30);
            this.btnSendOtp.TabIndex = 2;
            this.btnSendOtp.Text = "送信";
            this.btnSendOtp.Click += new System.EventHandler(this.btnSendOtp_Click);
            // 
            // lblMsg
            // 
            this.lblMsg.Location = new System.Drawing.Point(18, 10);
            this.lblMsg.Name = "lblMsg";
            this.lblMsg.Size = new System.Drawing.Size(180, 15);
            this.lblMsg.TabIndex = 0;
            this.lblMsg.Text = "ワンタイムパスワードを入力してください";
            // 
            // txtOtp
            // 
            this.txtOtp.Location = new System.Drawing.Point(34, 40);
            this.txtOtp.Name = "txtOtp";
            this.txtOtp.Size = new System.Drawing.Size(150, 23);
            this.txtOtp.TabIndex = 1;
            this.txtOtp.TextChanged += new System.EventHandler(this.txtOtp_TextChanged);
            this.txtOtp.KeyDown += new System.Windows.Forms.KeyEventHandler(this.txtOtp_KeyDown);
            // 
            // btnCancel
            // 
            this.btnCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.btnCancel.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnCancel.FlatAppearance.BorderSize = 2;
            this.btnCancel.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnCancel.Location = new System.Drawing.Point(136, 85);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(70, 30);
            this.btnCancel.TabIndex = 3;
            this.btnCancel.Text = "キャンセル";
            this.btnCancel.Click += new System.EventHandler(this.btnCancel_Click);
            // 
            // FrmOtpInput
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.CancelButton = this.btnCancel;
            this.ClientSize = new System.Drawing.Size(218, 118);
            this.ControlBox = false;
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.txtOtp);
            this.Controls.Add(this.lblMsg);
            this.Controls.Add(this.btnSendOtp);
            this.Font = new System.Drawing.Font("Yu Gothic UI", 9F);
            this.ForeColor = System.Drawing.Color.White;
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "FrmOtpInput";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.TopMost = true;
            this.Load += new System.EventHandler(this.FrmOtpInput_Load);
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.FrmOtpInput_FormClosed);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button btnSendOtp;
        private System.Windows.Forms.Label lblMsg;
        private System.Windows.Forms.TextBox txtOtp;
        private System.Windows.Forms.Button btnCancel;
    }
}