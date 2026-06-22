namespace FNSICloudConvertClient.Forms
{
    partial class FormSettings
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
            this.lblTitle          = new System.Windows.Forms.Label();
            this.pnlSepTop         = new System.Windows.Forms.Panel();
            this.pnlOnpre          = new System.Windows.Forms.Panel();
            this.lblOnpreTitle     = new System.Windows.Forms.Label();
            this.pnlSepOnpre       = new System.Windows.Forms.Panel();
            this.lblRdbIp          = new System.Windows.Forms.Label();
            this.txtRdbIp          = new System.Windows.Forms.TextBox();
            this.lblMongoIp        = new System.Windows.Forms.Label();
            this.txtMongoIp        = new System.Windows.Forms.TextBox();
            this.lblFnsiFolder     = new System.Windows.Forms.Label();
            this.txtFnsiFolder     = new System.Windows.Forms.TextBox();
            this.btnBrowseFnsi     = new System.Windows.Forms.Button();
            this.lblOnpreTmp       = new System.Windows.Forms.Label();
            this.txtOnpreTmp       = new System.Windows.Forms.TextBox();
            this.btnBrowseOnpreTmp = new System.Windows.Forms.Button();
            this.pnlCloud          = new System.Windows.Forms.Panel();
            this.lblCloudTitle     = new System.Windows.Forms.Label();
            this.pnlSepCloud       = new System.Windows.Forms.Panel();
            this.lblCloudServerCaption = new System.Windows.Forms.Label();
            this.lblCloudServerValue   = new System.Windows.Forms.Label();
            this.lblCloudDbCaption     = new System.Windows.Forms.Label();
            this.lblCloudDbValue       = new System.Windows.Forms.Label();
            this.pnlSepFooter      = new System.Windows.Forms.Panel();
            this.pnlFooter         = new System.Windows.Forms.Panel();
            this.btnCancel         = new System.Windows.Forms.Button();
            this.btnConfirm        = new System.Windows.Forms.Button();
            this.pnlOnpre.SuspendLayout();
            this.pnlCloud.SuspendLayout();
            this.pnlFooter.SuspendLayout();
            this.SuspendLayout();

            // lblTitle
            this.lblTitle.AutoSize  = false;
            this.lblTitle.Font      = new System.Drawing.Font("MS UI Gothic", 11F, System.Drawing.FontStyle.Bold);
            this.lblTitle.ForeColor = System.Drawing.Color.FromArgb(30, 30, 30);
            this.lblTitle.Location  = new System.Drawing.Point(0, 22);
            this.lblTitle.Size      = new System.Drawing.Size(700, 36);
            this.lblTitle.Text      = "\u8a2d\u5b9a";
            this.lblTitle.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.lblTitle.Anchor    = System.Windows.Forms.AnchorStyles.Top
                                    | System.Windows.Forms.AnchorStyles.Left
                                    | System.Windows.Forms.AnchorStyles.Right;

            // pnlSepTop
            this.pnlSepTop.Location  = new System.Drawing.Point(0, 66);
            this.pnlSepTop.Size      = new System.Drawing.Size(700, 1);
            this.pnlSepTop.BackColor = System.Drawing.Color.FromArgb(210, 213, 218);

            // --------------------------------------------------
            // pnlOnpre（オンプレ側設定カード）
            // --------------------------------------------------
            this.pnlOnpre.Location  = new System.Drawing.Point(8, 76);
            this.pnlOnpre.Size      = new System.Drawing.Size(338, 300);
            this.pnlOnpre.BackColor = System.Drawing.Color.FromArgb(242, 244, 247);
            this.pnlOnpre.Controls.Add(this.lblOnpreTitle);
            this.pnlOnpre.Controls.Add(this.pnlSepOnpre);
            this.pnlOnpre.Controls.Add(this.lblRdbIp);
            this.pnlOnpre.Controls.Add(this.txtRdbIp);
            this.pnlOnpre.Controls.Add(this.lblMongoIp);
            this.pnlOnpre.Controls.Add(this.txtMongoIp);
            this.pnlOnpre.Controls.Add(this.lblFnsiFolder);
            this.pnlOnpre.Controls.Add(this.txtFnsiFolder);
            this.pnlOnpre.Controls.Add(this.btnBrowseFnsi);
            this.pnlOnpre.Controls.Add(this.lblOnpreTmp);
            this.pnlOnpre.Controls.Add(this.txtOnpreTmp);
            this.pnlOnpre.Controls.Add(this.btnBrowseOnpreTmp);

            this.lblOnpreTitle.AutoSize  = false;
            this.lblOnpreTitle.Font      = new System.Drawing.Font("MS UI Gothic", 9F, System.Drawing.FontStyle.Bold);
            this.lblOnpreTitle.ForeColor = System.Drawing.Color.FromArgb(60, 60, 60);
            this.lblOnpreTitle.Location  = new System.Drawing.Point(12, 10);
            this.lblOnpreTitle.Size      = new System.Drawing.Size(314, 20);
            this.lblOnpreTitle.Text      = "\u30aa\u30f3\u30d7\u30ec\u5074\u8a2d\u5b9a";

            this.pnlSepOnpre.Location  = new System.Drawing.Point(0, 36);
            this.pnlSepOnpre.Size      = new System.Drawing.Size(338, 1);
            this.pnlSepOnpre.BackColor = System.Drawing.Color.FromArgb(232, 234, 237);

            // RDB IPアドレス
            this.lblRdbIp.AutoSize  = false;
            this.lblRdbIp.Location  = new System.Drawing.Point(12, 50);
            this.lblRdbIp.Size      = new System.Drawing.Size(314, 18);
            this.lblRdbIp.Text      = "RDB\u3000IP\u30a2\u30c9\u30ec\u30b9";
            this.lblRdbIp.Font      = new System.Drawing.Font("MS UI Gothic", 9F);
            this.lblRdbIp.ForeColor = System.Drawing.Color.FromArgb(70, 70, 70);

            this.txtRdbIp.Location  = new System.Drawing.Point(12, 70);
            this.txtRdbIp.Size      = new System.Drawing.Size(314, 26);
            this.txtRdbIp.Font      = new System.Drawing.Font("MS UI Gothic", 10F);
            this.txtRdbIp.TabIndex  = 0;

            // MongoDB IPアドレス
            this.lblMongoIp.AutoSize  = false;
            this.lblMongoIp.Location  = new System.Drawing.Point(12, 112);
            this.lblMongoIp.Size      = new System.Drawing.Size(314, 18);
            this.lblMongoIp.Text      = "MongoDB\u3000IP\u30a2\u30c9\u30ec\u30b9";
            this.lblMongoIp.Font      = new System.Drawing.Font("MS UI Gothic", 9F);
            this.lblMongoIp.ForeColor = System.Drawing.Color.FromArgb(70, 70, 70);

            this.txtMongoIp.Location  = new System.Drawing.Point(12, 130);
            this.txtMongoIp.Size      = new System.Drawing.Size(314, 26);
            this.txtMongoIp.Font      = new System.Drawing.Font("MS UI Gothic", 10F);
            this.txtMongoIp.TabIndex  = 1;

            // FNSi物理ファイルルートフォルダ
            this.lblFnsiFolder.AutoSize  = false;
            this.lblFnsiFolder.Location  = new System.Drawing.Point(12, 172);
            this.lblFnsiFolder.Size      = new System.Drawing.Size(314, 18);
            this.lblFnsiFolder.Text      = "FNSi\u7269\u7406\u30d5\u30a1\u30a4\u30eb\u30eb\u30fc\u30c8\u30d5\u30a9\u30eb\u30c0";
            this.lblFnsiFolder.Font      = new System.Drawing.Font("MS UI Gothic", 9F);
            this.lblFnsiFolder.ForeColor = System.Drawing.Color.FromArgb(70, 70, 70);

            this.txtFnsiFolder.Location  = new System.Drawing.Point(12, 192);
            this.txtFnsiFolder.Size      = new System.Drawing.Size(248, 26);
            this.txtFnsiFolder.Font      = new System.Drawing.Font("MS UI Gothic", 10F);
            this.txtFnsiFolder.TabIndex  = 2;

            this.btnBrowseFnsi.Location  = new System.Drawing.Point(264, 192);
            this.btnBrowseFnsi.Size      = new System.Drawing.Size(62, 26);
            this.btnBrowseFnsi.Text      = "\u53c2\u7167...";
            this.btnBrowseFnsi.Font      = new System.Drawing.Font("MS UI Gothic", 9F);
            this.btnBrowseFnsi.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnBrowseFnsi.BackColor = System.Drawing.Color.FromArgb(220, 222, 226);
            this.btnBrowseFnsi.ForeColor = System.Drawing.Color.FromArgb(60, 60, 60);
            this.btnBrowseFnsi.FlatAppearance.BorderSize = 0;
            this.btnBrowseFnsi.TabIndex  = 3;
            this.btnBrowseFnsi.Click    += new System.EventHandler(this.btnBrowseFnsi_Click);

            // オンプレ臨時フォルダ
            this.lblOnpreTmp.AutoSize  = false;
            this.lblOnpreTmp.Location  = new System.Drawing.Point(12, 234);
            this.lblOnpreTmp.Size      = new System.Drawing.Size(314, 18);
            this.lblOnpreTmp.Text      = "\u81e8\u6642\u30d5\u30a9\u30eb\u30c0";
            this.lblOnpreTmp.Font      = new System.Drawing.Font("MS UI Gothic", 9F);
            this.lblOnpreTmp.ForeColor = System.Drawing.Color.FromArgb(70, 70, 70);

            this.txtOnpreTmp.Location  = new System.Drawing.Point(12, 254);
            this.txtOnpreTmp.Size      = new System.Drawing.Size(248, 26);
            this.txtOnpreTmp.Font      = new System.Drawing.Font("MS UI Gothic", 10F);
            this.txtOnpreTmp.TabIndex  = 4;

            this.btnBrowseOnpreTmp.Location  = new System.Drawing.Point(264, 254);
            this.btnBrowseOnpreTmp.Size      = new System.Drawing.Size(62, 26);
            this.btnBrowseOnpreTmp.Text      = "\u53c2\u7167...";
            this.btnBrowseOnpreTmp.Font      = new System.Drawing.Font("MS UI Gothic", 9F);
            this.btnBrowseOnpreTmp.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnBrowseOnpreTmp.BackColor = System.Drawing.Color.FromArgb(220, 222, 226);
            this.btnBrowseOnpreTmp.ForeColor = System.Drawing.Color.FromArgb(60, 60, 60);
            this.btnBrowseOnpreTmp.FlatAppearance.BorderSize = 0;
            this.btnBrowseOnpreTmp.TabIndex  = 5;
            this.btnBrowseOnpreTmp.Click    += new System.EventHandler(this.btnBrowseOnpreTmp_Click);

            // --------------------------------------------------
            // pnlCloud（クラウド側設定カード）
            // --------------------------------------------------
            this.pnlCloud.Location  = new System.Drawing.Point(354, 76);
            this.pnlCloud.Size      = new System.Drawing.Size(338, 300);
            this.pnlCloud.BackColor = System.Drawing.Color.FromArgb(242, 244, 247);
            this.pnlCloud.Controls.Add(this.lblCloudTitle);
            this.pnlCloud.Controls.Add(this.pnlSepCloud);
            this.pnlCloud.Controls.Add(this.lblCloudServerCaption);
            this.pnlCloud.Controls.Add(this.lblCloudServerValue);
            this.pnlCloud.Controls.Add(this.lblCloudDbCaption);
            this.pnlCloud.Controls.Add(this.lblCloudDbValue);

            this.lblCloudTitle.AutoSize  = false;
            this.lblCloudTitle.Font      = new System.Drawing.Font("MS UI Gothic", 9F, System.Drawing.FontStyle.Bold);
            this.lblCloudTitle.ForeColor = System.Drawing.Color.FromArgb(60, 60, 60);
            this.lblCloudTitle.Location  = new System.Drawing.Point(12, 10);
            this.lblCloudTitle.Size      = new System.Drawing.Size(314, 20);
            this.lblCloudTitle.Text      = "\u30af\u30e9\u30a6\u30c9\u5074\u8a2d\u5b9a";

            this.pnlSepCloud.Location  = new System.Drawing.Point(0, 36);
            this.pnlSepCloud.Size      = new System.Drawing.Size(338, 1);
            this.pnlSepCloud.BackColor = System.Drawing.Color.FromArgb(232, 234, 237);

            this.lblCloudServerCaption.AutoSize  = false;
            this.lblCloudServerCaption.Location  = new System.Drawing.Point(12, 50);
            this.lblCloudServerCaption.Size      = new System.Drawing.Size(314, 18);
            this.lblCloudServerCaption.Text      = "FNSi\u30af\u30e9\u30a6\u30c9\u30b3\u30f3\u30d0\u30fc\u30c8\u30b5\u30fc\u30d0";
            this.lblCloudServerCaption.Font      = new System.Drawing.Font("MS UI Gothic", 9F);
            this.lblCloudServerCaption.ForeColor = System.Drawing.Color.FromArgb(70, 70, 70);

            this.lblCloudServerValue.AutoSize    = false;
            this.lblCloudServerValue.Location    = new System.Drawing.Point(12, 72);
            this.lblCloudServerValue.Size        = new System.Drawing.Size(314, 28);
            this.lblCloudServerValue.Text        = "---";
            this.lblCloudServerValue.Font        = new System.Drawing.Font("MS UI Gothic", 9F);
            this.lblCloudServerValue.ForeColor   = System.Drawing.Color.FromArgb(0, 80, 160);

            this.lblCloudDbCaption.AutoSize  = false;
            this.lblCloudDbCaption.Location  = new System.Drawing.Point(12, 112);
            this.lblCloudDbCaption.Size      = new System.Drawing.Size(314, 18);
            this.lblCloudDbCaption.Text      = "FNSi\u30af\u30e9\u30a6\u30c9\u30b3\u30f3\u30d0\u30fc\u30c8DB";
            this.lblCloudDbCaption.Font      = new System.Drawing.Font("MS UI Gothic", 9F);
            this.lblCloudDbCaption.ForeColor = System.Drawing.Color.FromArgb(70, 70, 70);

            this.lblCloudDbValue.AutoSize    = false;
            this.lblCloudDbValue.Location    = new System.Drawing.Point(12, 134);
            this.lblCloudDbValue.Size        = new System.Drawing.Size(314, 28);
            this.lblCloudDbValue.Text        = "---";
            this.lblCloudDbValue.Font        = new System.Drawing.Font("MS UI Gothic", 9F);
            this.lblCloudDbValue.ForeColor   = System.Drawing.Color.FromArgb(0, 80, 160);

            // pnlSepFooter
            this.pnlSepFooter.Location  = new System.Drawing.Point(0, 384);
            this.pnlSepFooter.Size      = new System.Drawing.Size(700, 1);
            this.pnlSepFooter.BackColor = System.Drawing.Color.FromArgb(210, 213, 218);

            // pnlFooter
            this.pnlFooter.Location  = new System.Drawing.Point(0, 385);
            this.pnlFooter.Size      = new System.Drawing.Size(700, 58);
            this.pnlFooter.BackColor = System.Drawing.Color.FromArgb(248, 249, 250);
            this.pnlFooter.Controls.Add(this.btnCancel);
            this.pnlFooter.Controls.Add(this.btnConfirm);

            this.btnCancel.Location  = new System.Drawing.Point(16, 11);
            this.btnCancel.Size      = new System.Drawing.Size(110, 36);
            this.btnCancel.Text      = "\u30ad\u30e3\u30f3\u30bb\u30eb";
            this.btnCancel.Font      = new System.Drawing.Font("MS UI Gothic", 10F);
            this.btnCancel.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnCancel.BackColor = System.Drawing.Color.FromArgb(220, 222, 226);
            this.btnCancel.ForeColor = System.Drawing.Color.FromArgb(60, 60, 60);
            this.btnCancel.FlatAppearance.BorderSize = 0;
            this.btnCancel.TabIndex  = 8;
            this.btnCancel.Click    += new System.EventHandler(this.btnCancel_Click);

            this.btnConfirm.Location  = new System.Drawing.Point(574, 11);
            this.btnConfirm.Size      = new System.Drawing.Size(110, 36);
            this.btnConfirm.Text      = "\u78ba\u5b9a";
            this.btnConfirm.Font      = new System.Drawing.Font("MS UI Gothic", 10F, System.Drawing.FontStyle.Bold);
            this.btnConfirm.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnConfirm.BackColor = System.Drawing.Color.FromArgb(24, 119, 242);
            this.btnConfirm.ForeColor = System.Drawing.Color.White;
            this.btnConfirm.FlatAppearance.BorderSize = 0;
            this.btnConfirm.Anchor    = System.Windows.Forms.AnchorStyles.Top
                                      | System.Windows.Forms.AnchorStyles.Right;
            this.btnConfirm.TabIndex  = 9;
            this.btnConfirm.Click    += new System.EventHandler(this.btnConfirm_Click);

            // FormSettings
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode       = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor           = System.Drawing.Color.FromArgb(242, 244, 247);
            this.ClientSize          = new System.Drawing.Size(700, 443);
            this.Controls.Add(this.lblTitle);
            this.Controls.Add(this.pnlSepTop);
            this.Controls.Add(this.pnlOnpre);
            this.Controls.Add(this.pnlCloud);
            this.Controls.Add(this.pnlSepFooter);
            this.Controls.Add(this.pnlFooter);
            this.AcceptButton    = this.btnConfirm;
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.MaximizeBox     = false;
            this.MinimizeBox     = false;
            this.Name            = "FormSettings";
            this.StartPosition   = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text            = "\u8a2d\u5b9a";
            this.pnlOnpre.ResumeLayout(false);
            this.pnlCloud.ResumeLayout(false);
            this.pnlFooter.ResumeLayout(false);
            this.ResumeLayout(false);
        }

        private System.Windows.Forms.Label   lblTitle;
        private System.Windows.Forms.Panel   pnlSepTop;
        private System.Windows.Forms.Panel   pnlOnpre;
        private System.Windows.Forms.Label   lblOnpreTitle;
        private System.Windows.Forms.Panel   pnlSepOnpre;
        private System.Windows.Forms.Label   lblRdbIp;
        private System.Windows.Forms.TextBox txtRdbIp;
        private System.Windows.Forms.Label   lblMongoIp;
        private System.Windows.Forms.TextBox txtMongoIp;
        private System.Windows.Forms.Label   lblFnsiFolder;
        private System.Windows.Forms.TextBox txtFnsiFolder;
        private System.Windows.Forms.Button  btnBrowseFnsi;
        private System.Windows.Forms.Label   lblOnpreTmp;
        private System.Windows.Forms.TextBox txtOnpreTmp;
        private System.Windows.Forms.Button  btnBrowseOnpreTmp;
        private System.Windows.Forms.Panel   pnlCloud;
        private System.Windows.Forms.Label   lblCloudTitle;
        private System.Windows.Forms.Panel   pnlSepCloud;
        private System.Windows.Forms.Label   lblCloudServerCaption;
        private System.Windows.Forms.Label   lblCloudServerValue;
        private System.Windows.Forms.Label   lblCloudDbCaption;
        private System.Windows.Forms.Label   lblCloudDbValue;
        private System.Windows.Forms.Panel   pnlSepFooter;
        private System.Windows.Forms.Panel   pnlFooter;
        private System.Windows.Forms.Button  btnCancel;
        private System.Windows.Forms.Button  btnConfirm;
    }
}
