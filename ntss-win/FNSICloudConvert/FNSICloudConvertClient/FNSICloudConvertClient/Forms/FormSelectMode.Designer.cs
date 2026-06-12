namespace FNSICloudConvertClient.Forms
{
    partial class FormSelectMode
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
            this.lblTitle    = new System.Windows.Forms.Label();
            this.pnlSepTop   = new System.Windows.Forms.Panel();
            this.lblInstruct = new System.Windows.Forms.Label();
            this.btnSettings = new System.Windows.Forms.Button();
            this.btnExport   = new System.Windows.Forms.Button();
            this.btnImport   = new System.Windows.Forms.Button();
            this.pnlSepFooter = new System.Windows.Forms.Panel();
            this.pnlFooter   = new System.Windows.Forms.Panel();
            this.btnLogout   = new System.Windows.Forms.Button();
            this.pnlFooter.SuspendLayout();
            this.SuspendLayout();

            // --------------------------------------------------
            // lblTitle
            // --------------------------------------------------
            this.lblTitle.AutoSize  = false;
            this.lblTitle.Font      = new System.Drawing.Font("MS UI Gothic", 11F, System.Drawing.FontStyle.Bold);
            this.lblTitle.ForeColor = System.Drawing.Color.FromArgb(30, 30, 30);
            this.lblTitle.Location  = new System.Drawing.Point(0, 22);
            this.lblTitle.Size      = new System.Drawing.Size(500, 36);
            this.lblTitle.Text      = "FutureNetWeb\u207ASi\u30aa\u30f3\u30d7\u30ec\u2192\u30af\u30e9\u30a6\u30c9\u30b3\u30f3\u30d0\u30fc\u30c8";
            this.lblTitle.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;

            // --------------------------------------------------
            // pnlSepTop（タイトル下の区切り線）
            // --------------------------------------------------
            this.pnlSepTop.Location  = new System.Drawing.Point(0, 66);
            this.pnlSepTop.Size      = new System.Drawing.Size(500, 1);
            this.pnlSepTop.BackColor = System.Drawing.Color.FromArgb(210, 213, 218);

            // --------------------------------------------------
            // lblInstruct
            // --------------------------------------------------
            this.lblInstruct.AutoSize  = false;
            this.lblInstruct.Font      = new System.Drawing.Font("MS UI Gothic", 10F);
            this.lblInstruct.ForeColor = System.Drawing.Color.FromArgb(70, 70, 70);
            this.lblInstruct.Location  = new System.Drawing.Point(0, 78);
            this.lblInstruct.Size      = new System.Drawing.Size(408, 28);
            this.lblInstruct.Text      = "\u64cd\u4f5c\u30e2\u30fc\u30c9\u3092\u9078\u629e\u3057\u3066\u304f\u3060\u3055\u3044";
            this.lblInstruct.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;

            // --------------------------------------------------
            // btnSettings（設定ボタン / lblInstruct 行の右端）
            // --------------------------------------------------
            this.btnSettings.Location  = new System.Drawing.Point(416, 79);
            this.btnSettings.Size      = new System.Drawing.Size(76, 26);
            this.btnSettings.Text      = "\u8a2d\u5b9a";
            this.btnSettings.Font      = new System.Drawing.Font("MS UI Gothic", 9F);
            this.btnSettings.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnSettings.BackColor = System.Drawing.Color.FromArgb(220, 222, 226);
            this.btnSettings.ForeColor = System.Drawing.Color.FromArgb(60, 60, 60);
            this.btnSettings.FlatAppearance.BorderSize = 0;
            this.btnSettings.Cursor    = System.Windows.Forms.Cursors.Hand;
            this.btnSettings.TabIndex  = 3;
            this.btnSettings.Click    += new System.EventHandler(this.btnSettings_Click);

            // --------------------------------------------------
            // btnExport（データ導出ボタン）
            // --------------------------------------------------
            this.btnExport.Location  = new System.Drawing.Point(8, 124);
            this.btnExport.Size      = new System.Drawing.Size(238, 120);
            this.btnExport.Text      = "\u30aa\u30f3\u30d7\u30ec\u2192\u30af\u30e9\u30a6\u30c9";
            this.btnExport.Font      = new System.Drawing.Font("MS UI Gothic", 12F, System.Drawing.FontStyle.Bold);
            this.btnExport.BackColor = System.Drawing.Color.FromArgb(70, 130, 180);
            this.btnExport.ForeColor = System.Drawing.Color.White;
            this.btnExport.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnExport.FlatAppearance.BorderSize = 0;
            this.btnExport.TabIndex  = 0;
            this.btnExport.Click    += new System.EventHandler(this.btnExport_Click);

            // --------------------------------------------------
            // btnImport（データ導入ボタン）
            // --------------------------------------------------
            this.btnImport.Location  = new System.Drawing.Point(254, 124);
            this.btnImport.Size      = new System.Drawing.Size(238, 120);
            this.btnImport.Text      = "\u30af\u30e9\u30a6\u30c9\u2192\u30aa\u30f3\u30d7\u30ec";
            this.btnImport.Font      = new System.Drawing.Font("MS UI Gothic", 12F, System.Drawing.FontStyle.Bold);
            this.btnImport.BackColor = System.Drawing.Color.FromArgb(46, 139, 87);
            this.btnImport.ForeColor = System.Drawing.Color.White;
            this.btnImport.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnImport.FlatAppearance.BorderSize = 0;
            this.btnImport.TabIndex  = 1;
            this.btnImport.Click    += new System.EventHandler(this.btnImport_Click);

            // --------------------------------------------------
            // pnlSepFooter（フッター上の区切り線）
            // --------------------------------------------------
            this.pnlSepFooter.Location  = new System.Drawing.Point(0, 266);
            this.pnlSepFooter.Size      = new System.Drawing.Size(500, 1);
            this.pnlSepFooter.BackColor = System.Drawing.Color.FromArgb(210, 213, 218);

            // --------------------------------------------------
            // pnlFooter（ボタンエリア）
            // --------------------------------------------------
            this.pnlFooter.Location  = new System.Drawing.Point(0, 267);
            this.pnlFooter.Size      = new System.Drawing.Size(500, 56);
            this.pnlFooter.BackColor = System.Drawing.Color.FromArgb(248, 249, 250);
            this.pnlFooter.Controls.Add(this.btnLogout);

            // ログアウトボタン（左下）
            this.btnLogout.Location  = new System.Drawing.Point(16, 10);
            this.btnLogout.Size      = new System.Drawing.Size(110, 36);
            this.btnLogout.Text      = "\u30ed\u30b0\u30a2\u30a6\u30c8";
            this.btnLogout.Font      = new System.Drawing.Font("MS UI Gothic", 10F);
            this.btnLogout.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnLogout.BackColor = System.Drawing.Color.FromArgb(220, 222, 226);
            this.btnLogout.ForeColor = System.Drawing.Color.FromArgb(60, 60, 60);
            this.btnLogout.FlatAppearance.BorderSize = 0;
            this.btnLogout.TabIndex  = 2;
            this.btnLogout.Click    += new System.EventHandler(this.btnLogout_Click);

            // --------------------------------------------------
            // FormSelectMode
            // --------------------------------------------------
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode       = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor           = System.Drawing.Color.FromArgb(242, 244, 247);
            this.ClientSize          = new System.Drawing.Size(500, 323);
            this.Controls.Add(this.lblTitle);
            this.Controls.Add(this.pnlSepTop);
            this.Controls.Add(this.lblInstruct);
            this.Controls.Add(this.btnSettings);
            this.Controls.Add(this.btnExport);
            this.Controls.Add(this.btnImport);
            this.Controls.Add(this.pnlSepFooter);
            this.Controls.Add(this.pnlFooter);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.MaximizeBox     = false;
            this.Name            = "FormSelectMode";
            this.StartPosition   = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text            = "\u64cd\u4f5c\u30e2\u30fc\u30c9\u9078\u629e";
            this.FormClosed     += new System.Windows.Forms.FormClosedEventHandler(this.FormSelectMode_FormClosed);
            this.pnlFooter.ResumeLayout(false);
            this.ResumeLayout(false);
        }

        private System.Windows.Forms.Label  lblTitle;
        private System.Windows.Forms.Panel  pnlSepTop;
        private System.Windows.Forms.Label  lblInstruct;
        private System.Windows.Forms.Button btnSettings;
        private System.Windows.Forms.Button btnExport;
        private System.Windows.Forms.Button btnImport;
        private System.Windows.Forms.Panel  pnlSepFooter;
        private System.Windows.Forms.Panel  pnlFooter;
        private System.Windows.Forms.Button btnLogout;
    }
}
