namespace FNSICloudConvertClient.Forms
{
    partial class FormLogin
    {
        private System.ComponentModel.IContainer components = null;

        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
                components.Dispose();
            base.Dispose(disposing);
        }

        private void InitializeComponent()
        {
            this.lblTitle      = new System.Windows.Forms.Label();
            this.pnlSepTop     = new System.Windows.Forms.Panel();
            this.pnlStep1      = new System.Windows.Forms.Panel();
            this.lblUserId     = new System.Windows.Forms.Label();
            this.txtUserId     = new System.Windows.Forms.TextBox();
            this.lblPassword   = new System.Windows.Forms.Label();
            this.txtPassword   = new System.Windows.Forms.TextBox();
            this.pnlStep2      = new System.Windows.Forms.Panel();
            this.lblAuthCode   = new System.Windows.Forms.Label();
            this.txtAuthCode   = new System.Windows.Forms.TextBox();
            this.pnlSepFooter  = new System.Windows.Forms.Panel();
            this.pnlFooter     = new System.Windows.Forms.Panel();
            this.btnBack       = new System.Windows.Forms.Button();
            this.btnNext       = new System.Windows.Forms.Button();
            this.btnLogin      = new System.Windows.Forms.Button();
            this.pnlStep1.SuspendLayout();
            this.pnlStep2.SuspendLayout();
            this.pnlFooter.SuspendLayout();
            this.SuspendLayout();

            // --------------------------------------------------
            // lblTitle
            // --------------------------------------------------
            this.lblTitle.AutoSize  = false;
            this.lblTitle.Font      = new System.Drawing.Font("MS UI Gothic", 12F, System.Drawing.FontStyle.Bold);
            this.lblTitle.ForeColor = System.Drawing.Color.FromArgb(30, 30, 30);
            this.lblTitle.Location  = new System.Drawing.Point(0, 22);
            this.lblTitle.Size      = new System.Drawing.Size(420, 36);
            this.lblTitle.Text      = "FutureNetWeb\u207ASi\u30aa\u30f3\u30d7\u30ec\u2192\u30af\u30e9\u30a6\u30c9\u30b3\u30f3\u30d0\u30fc\u30c8";
            this.lblTitle.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;

            // --------------------------------------------------
            // pnlSepTop（タイトル下の区切り線）
            // --------------------------------------------------
            this.pnlSepTop.Location  = new System.Drawing.Point(0, 66);
            this.pnlSepTop.Size      = new System.Drawing.Size(420, 1);
            this.pnlSepTop.BackColor = System.Drawing.Color.FromArgb(210, 213, 218);

            // --------------------------------------------------
            // pnlStep1（ユーザーID / パスワード入力）
            // --------------------------------------------------
            this.pnlStep1.Location  = new System.Drawing.Point(40, 80);
            this.pnlStep1.Size      = new System.Drawing.Size(340, 130);
            this.pnlStep1.BackColor = System.Drawing.Color.Transparent;
            this.pnlStep1.Controls.Add(this.lblUserId);
            this.pnlStep1.Controls.Add(this.txtUserId);
            this.pnlStep1.Controls.Add(this.lblPassword);
            this.pnlStep1.Controls.Add(this.txtPassword);

            this.lblUserId.AutoSize  = false;
            this.lblUserId.Size      = new System.Drawing.Size(340, 20);
            this.lblUserId.Location  = new System.Drawing.Point(0, 0);
            this.lblUserId.Text      = "\u30e6\u30fc\u30b6\u30fcID";
            this.lblUserId.Font      = new System.Drawing.Font("MS UI Gothic", 10F);
            this.lblUserId.ForeColor = System.Drawing.Color.FromArgb(70, 70, 70);

            this.txtUserId.Location  = new System.Drawing.Point(0, 22);
            this.txtUserId.Size      = new System.Drawing.Size(340, 26);
            this.txtUserId.Font      = new System.Drawing.Font("MS UI Gothic", 12F);
            this.txtUserId.TabIndex  = 0;

            this.lblPassword.AutoSize  = false;
            this.lblPassword.Size      = new System.Drawing.Size(340, 20);
            this.lblPassword.Location  = new System.Drawing.Point(0, 68);
            this.lblPassword.Text      = "\u30d1\u30b9\u30ef\u30fc\u30c9";
            this.lblPassword.Font      = new System.Drawing.Font("MS UI Gothic", 10F);
            this.lblPassword.ForeColor = System.Drawing.Color.FromArgb(70, 70, 70);

            this.txtPassword.Location     = new System.Drawing.Point(0, 90);
            this.txtPassword.Size         = new System.Drawing.Size(340, 26);
            this.txtPassword.Font         = new System.Drawing.Font("MS UI Gothic", 12F);
            this.txtPassword.PasswordChar = '\u25cf';
            this.txtPassword.TabIndex     = 1;

            // --------------------------------------------------
            // pnlStep2（認証コード入力）
            // --------------------------------------------------
            this.pnlStep2.Location  = new System.Drawing.Point(40, 80);
            this.pnlStep2.Size      = new System.Drawing.Size(340, 80);
            this.pnlStep2.BackColor = System.Drawing.Color.Transparent;
            this.pnlStep2.Visible   = false;
            this.pnlStep2.Controls.Add(this.lblAuthCode);
            this.pnlStep2.Controls.Add(this.txtAuthCode);

            this.lblAuthCode.AutoSize  = false;
            this.lblAuthCode.Size      = new System.Drawing.Size(340, 20);
            this.lblAuthCode.Location  = new System.Drawing.Point(0, 0);
            this.lblAuthCode.Text      = "\u8a8d\u8a3c\u30b3\u30fc\u30c9";
            this.lblAuthCode.Font      = new System.Drawing.Font("MS UI Gothic", 10F);
            this.lblAuthCode.ForeColor = System.Drawing.Color.FromArgb(70, 70, 70);

            this.txtAuthCode.Location = new System.Drawing.Point(0, 22);
            this.txtAuthCode.Size     = new System.Drawing.Size(340, 26);
            this.txtAuthCode.Font     = new System.Drawing.Font("MS UI Gothic", 12F);
            this.txtAuthCode.TabIndex = 0;

            // --------------------------------------------------
            // pnlSepFooter（フッター上の区切り線）
            // --------------------------------------------------
            this.pnlSepFooter.Location  = new System.Drawing.Point(0, 226);
            this.pnlSepFooter.Size      = new System.Drawing.Size(420, 1);
            this.pnlSepFooter.BackColor = System.Drawing.Color.FromArgb(210, 213, 218);

            // --------------------------------------------------
            // pnlFooter（ボタンエリア）
            // --------------------------------------------------
            this.pnlFooter.Location  = new System.Drawing.Point(0, 227);
            this.pnlFooter.Size      = new System.Drawing.Size(420, 60);
            this.pnlFooter.BackColor = System.Drawing.Color.FromArgb(248, 249, 250);
            this.pnlFooter.Controls.Add(this.btnBack);
            this.pnlFooter.Controls.Add(this.btnNext);
            this.pnlFooter.Controls.Add(this.btnLogin);

            // 戻るボタン（左下）
            this.btnBack.Location  = new System.Drawing.Point(16, 12);
            this.btnBack.Size      = new System.Drawing.Size(110, 36);
            this.btnBack.Text      = "< \u623b\u308b";
            this.btnBack.Font      = new System.Drawing.Font("MS UI Gothic", 10F);
            this.btnBack.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnBack.BackColor = System.Drawing.Color.FromArgb(220, 222, 226);
            this.btnBack.ForeColor = System.Drawing.Color.FromArgb(60, 60, 60);
            this.btnBack.FlatAppearance.BorderSize  = 0;
            this.btnBack.FlatAppearance.BorderColor = System.Drawing.Color.FromArgb(190, 192, 196);
            this.btnBack.Visible   = false;
            this.btnBack.TabIndex  = 10;
            this.btnBack.Click    += new System.EventHandler(this.btnBack_Click);

            // ログインボタン（右下 / ステップ1）
            this.btnNext.Location  = new System.Drawing.Point(294, 12);
            this.btnNext.Size      = new System.Drawing.Size(110, 36);
            this.btnNext.Text      = "\u30ed\u30b0\u30a4\u30f3";
            this.btnNext.Font      = new System.Drawing.Font("MS UI Gothic", 10F, System.Drawing.FontStyle.Bold);
            this.btnNext.BackColor = System.Drawing.Color.FromArgb(24, 119, 242);
            this.btnNext.ForeColor = System.Drawing.Color.White;
            this.btnNext.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnNext.FlatAppearance.BorderSize = 0;
            this.btnNext.Visible   = true;
            this.btnNext.TabIndex  = 11;
            this.btnNext.Click    += new System.EventHandler(this.btnNext_Click);

            // 認証ボタン（右下 / ステップ2）
            this.btnLogin.Location  = new System.Drawing.Point(294, 12);
            this.btnLogin.Size      = new System.Drawing.Size(110, 36);
            this.btnLogin.Text      = "\u8a8d\u8a3c";
            this.btnLogin.Font      = new System.Drawing.Font("MS UI Gothic", 10F, System.Drawing.FontStyle.Bold);
            this.btnLogin.BackColor = System.Drawing.Color.FromArgb(24, 119, 242);
            this.btnLogin.ForeColor = System.Drawing.Color.White;
            this.btnLogin.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnLogin.FlatAppearance.BorderSize = 0;
            this.btnLogin.Visible   = false;
            this.btnLogin.TabIndex  = 12;
            this.btnLogin.Click    += new System.EventHandler(this.btnLogin_Click);

            // --------------------------------------------------
            // FormLogin
            // --------------------------------------------------
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode       = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor           = System.Drawing.Color.FromArgb(242, 244, 247);
            this.ClientSize          = new System.Drawing.Size(420, 287);
            this.Controls.Add(this.lblTitle);
            this.Controls.Add(this.pnlSepTop);
            this.Controls.Add(this.pnlStep1);
            this.Controls.Add(this.pnlStep2);
            this.Controls.Add(this.pnlSepFooter);
            this.Controls.Add(this.pnlFooter);
            this.AcceptButton    = this.btnNext;
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.MaximizeBox     = false;
            this.MinimizeBox     = true;
            this.Name            = "FormLogin";
            this.StartPosition   = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text            = "\u30ed\u30b0\u30a4\u30f3 - FutureNetWeb\u207ASi\u30aa\u30f3\u30d7\u30ec\u2192\u30af\u30e9\u30a6\u30c9\u30b3\u30f3\u30d0\u30fc\u30c8";
            this.FormClosed     += new System.Windows.Forms.FormClosedEventHandler(this.FormLogin_FormClosed);
            this.pnlStep1.ResumeLayout(false);
            this.pnlStep1.PerformLayout();
            this.pnlStep2.ResumeLayout(false);
            this.pnlStep2.PerformLayout();
            this.pnlFooter.ResumeLayout(false);
            this.ResumeLayout(false);
        }

        private System.Windows.Forms.Label   lblTitle;
        private System.Windows.Forms.Panel   pnlSepTop;
        private System.Windows.Forms.Panel   pnlStep1;
        private System.Windows.Forms.Label   lblUserId;
        private System.Windows.Forms.TextBox txtUserId;
        private System.Windows.Forms.Label   lblPassword;
        private System.Windows.Forms.TextBox txtPassword;
        private System.Windows.Forms.Panel   pnlStep2;
        private System.Windows.Forms.Label   lblAuthCode;
        private System.Windows.Forms.TextBox txtAuthCode;
        private System.Windows.Forms.Panel   pnlSepFooter;
        private System.Windows.Forms.Panel   pnlFooter;
        private System.Windows.Forms.Button  btnBack;
        private System.Windows.Forms.Button  btnNext;
        private System.Windows.Forms.Button  btnLogin;
    }
}
