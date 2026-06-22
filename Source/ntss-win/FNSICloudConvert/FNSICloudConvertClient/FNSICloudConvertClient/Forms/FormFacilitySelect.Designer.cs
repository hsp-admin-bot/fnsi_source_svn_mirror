namespace FNSICloudConvertClient.Forms
{
    partial class FormFacilitySelect
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
            this.lblTitle           = new System.Windows.Forms.Label();
            this.pnlSepTop          = new System.Windows.Forms.Panel();
            this.pnlLeft            = new System.Windows.Forms.Panel();
            this.lblSelectedTitle   = new System.Windows.Forms.Label();
            this.btnManualInput     = new System.Windows.Forms.Button();
            this.pnlSepLeft         = new System.Windows.Forms.Panel();
            this.pnlSelectedContent = new System.Windows.Forms.Panel();
            this.pnlRight           = new System.Windows.Forms.Panel();
            this.lblAvailTitle      = new System.Windows.Forms.Label();
            this.btnCloseRight      = new System.Windows.Forms.Button();
            this.pnlSepRight        = new System.Windows.Forms.Panel();
            this.lstAvailable       = new System.Windows.Forms.ListBox();
            this.pnlSepFooter       = new System.Windows.Forms.Panel();
            this.pnlFooter          = new System.Windows.Forms.Panel();
            this.btnCancel          = new System.Windows.Forms.Button();
            this.btnConfirm         = new System.Windows.Forms.Button();
            this.btnSelect          = new System.Windows.Forms.Button();
            this.pnlLeft.SuspendLayout();
            this.pnlRight.SuspendLayout();
            this.pnlFooter.SuspendLayout();
            this.SuspendLayout();

            // --------------------------------------------------
            // lblTitle
            // --------------------------------------------------
            this.lblTitle.AutoSize  = false;
            this.lblTitle.Font      = new System.Drawing.Font("MS UI Gothic", 11F, System.Drawing.FontStyle.Bold);
            this.lblTitle.ForeColor = System.Drawing.Color.FromArgb(30, 30, 30);
            this.lblTitle.Location  = new System.Drawing.Point(0, 22);
            this.lblTitle.Size      = new System.Drawing.Size(672, 36);
            this.lblTitle.Text      = "\u65bd\u8a2d\u9078\u629e";
            this.lblTitle.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.lblTitle.Anchor    = System.Windows.Forms.AnchorStyles.Top
                                    | System.Windows.Forms.AnchorStyles.Left
                                    | System.Windows.Forms.AnchorStyles.Right;

            // --------------------------------------------------
            // pnlSepTop
            // --------------------------------------------------
            this.pnlSepTop.Location  = new System.Drawing.Point(0, 66);
            this.pnlSepTop.Size      = new System.Drawing.Size(672, 1);
            this.pnlSepTop.BackColor = System.Drawing.Color.FromArgb(210, 213, 218);
            this.pnlSepTop.Anchor    = System.Windows.Forms.AnchorStyles.Top
                                     | System.Windows.Forms.AnchorStyles.Left
                                     | System.Windows.Forms.AnchorStyles.Right;

            // --------------------------------------------------
            // pnlLeft（選択済み施設カード）
            // --------------------------------------------------
            this.pnlLeft.Location  = new System.Drawing.Point(8, 76);
            this.pnlLeft.Size      = new System.Drawing.Size(324, 340);
            this.pnlLeft.BackColor = System.Drawing.Color.White;
            this.pnlLeft.Controls.Add(this.lblSelectedTitle);
            this.pnlLeft.Controls.Add(this.btnManualInput);
            this.pnlLeft.Controls.Add(this.pnlSepLeft);
            this.pnlLeft.Controls.Add(this.pnlSelectedContent);

            this.lblSelectedTitle.AutoSize  = false;
            this.lblSelectedTitle.Font      = new System.Drawing.Font("MS UI Gothic", 9F, System.Drawing.FontStyle.Bold);
            this.lblSelectedTitle.ForeColor = System.Drawing.Color.FromArgb(60, 60, 60);
            this.lblSelectedTitle.Location  = new System.Drawing.Point(12, 10);
            this.lblSelectedTitle.Size      = new System.Drawing.Size(200, 20);
            this.lblSelectedTitle.Text      = "\u9078\u629e\u6e08\u307f\u65bd\u8a2d";

            this.btnManualInput.Location  = new System.Drawing.Point(222, 7);
            this.btnManualInput.Size      = new System.Drawing.Size(88, 22);
            this.btnManualInput.Text      = "\u624b\u5165\u529b";
            this.btnManualInput.Font      = new System.Drawing.Font("MS UI Gothic", 8F);
            this.btnManualInput.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnManualInput.BackColor = System.Drawing.Color.FromArgb(240, 180, 40);
            this.btnManualInput.ForeColor = System.Drawing.Color.White;
            this.btnManualInput.FlatAppearance.BorderSize = 0;
            this.btnManualInput.Cursor    = System.Windows.Forms.Cursors.Hand;
            this.btnManualInput.Visible   = false;
            this.btnManualInput.Click    += new System.EventHandler(this.btnManualInput_Click);

            this.pnlSepLeft.Location  = new System.Drawing.Point(0, 36);
            this.pnlSepLeft.Size      = new System.Drawing.Size(324, 1);
            this.pnlSepLeft.BackColor = System.Drawing.Color.FromArgb(232, 234, 237);

            this.pnlSelectedContent.Location   = new System.Drawing.Point(0, 37);
            this.pnlSelectedContent.Size       = new System.Drawing.Size(324, 303);
            this.pnlSelectedContent.BackColor  = System.Drawing.Color.White;
            this.pnlSelectedContent.AutoScroll = true;

            // --------------------------------------------------
            // pnlRight（施設一覧カード / 初期非表示）
            // --------------------------------------------------
            this.pnlRight.Location  = new System.Drawing.Point(340, 76);
            this.pnlRight.Size      = new System.Drawing.Size(324, 340);
            this.pnlRight.BackColor = System.Drawing.Color.White;
            this.pnlRight.Visible   = false;
            this.pnlRight.Controls.Add(this.lblAvailTitle);
            this.pnlRight.Controls.Add(this.btnCloseRight);
            this.pnlRight.Controls.Add(this.pnlSepRight);
            this.pnlRight.Controls.Add(this.lstAvailable);

            this.lblAvailTitle.AutoSize  = false;
            this.lblAvailTitle.Font      = new System.Drawing.Font("MS UI Gothic", 9F, System.Drawing.FontStyle.Bold);
            this.lblAvailTitle.ForeColor = System.Drawing.Color.FromArgb(60, 60, 60);
            this.lblAvailTitle.Location  = new System.Drawing.Point(12, 10);
            this.lblAvailTitle.Size      = new System.Drawing.Size(260, 20);
            this.lblAvailTitle.Text      = "\u65bd\u8a2d\u4e00\u89a7\uff08\u30c0\u30d6\u30eb\u30af\u30ea\u30c3\u30af\u307e\u305f\u306fEnter\u3067\u8ffd\u52a0\uff09";

            this.btnCloseRight.Location  = new System.Drawing.Point(296, 6);
            this.btnCloseRight.Size      = new System.Drawing.Size(24, 24);
            this.btnCloseRight.Text      = "\u00d7";
            this.btnCloseRight.Font      = new System.Drawing.Font("MS UI Gothic", 10F);
            this.btnCloseRight.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnCloseRight.BackColor = System.Drawing.Color.White;
            this.btnCloseRight.ForeColor = System.Drawing.Color.FromArgb(100, 100, 100);
            this.btnCloseRight.FlatAppearance.BorderSize         = 0;
            this.btnCloseRight.FlatAppearance.MouseOverBackColor = System.Drawing.Color.FromArgb(232, 234, 237);
            this.btnCloseRight.TabIndex  = 1;
            this.btnCloseRight.Click    += new System.EventHandler(this.btnCloseRight_Click);

            this.pnlSepRight.Location  = new System.Drawing.Point(0, 36);
            this.pnlSepRight.Size      = new System.Drawing.Size(324, 1);
            this.pnlSepRight.BackColor = System.Drawing.Color.FromArgb(232, 234, 237);

            this.lstAvailable.Location     = new System.Drawing.Point(8, 44);
            this.lstAvailable.Size         = new System.Drawing.Size(308, 288);
            this.lstAvailable.BorderStyle  = System.Windows.Forms.BorderStyle.None;
            this.lstAvailable.Font         = new System.Drawing.Font("MS UI Gothic", 10F);
            this.lstAvailable.TabIndex     = 0;
            this.lstAvailable.DoubleClick += new System.EventHandler(this.lstAvailable_DoubleClick);
            this.lstAvailable.KeyDown     += new System.Windows.Forms.KeyEventHandler(this.lstAvailable_KeyDown);

            // --------------------------------------------------
            // pnlSepFooter
            // --------------------------------------------------
            this.pnlSepFooter.Location  = new System.Drawing.Point(0, 424);
            this.pnlSepFooter.Size      = new System.Drawing.Size(672, 1);
            this.pnlSepFooter.BackColor = System.Drawing.Color.FromArgb(210, 213, 218);
            this.pnlSepFooter.Anchor    = System.Windows.Forms.AnchorStyles.Top
                                        | System.Windows.Forms.AnchorStyles.Left
                                        | System.Windows.Forms.AnchorStyles.Right;

            // --------------------------------------------------
            // pnlFooter
            // --------------------------------------------------
            this.pnlFooter.Location  = new System.Drawing.Point(0, 425);
            this.pnlFooter.Size      = new System.Drawing.Size(672, 58);
            this.pnlFooter.BackColor = System.Drawing.Color.FromArgb(248, 249, 250);
            this.pnlFooter.Anchor    = System.Windows.Forms.AnchorStyles.Top
                                     | System.Windows.Forms.AnchorStyles.Left
                                     | System.Windows.Forms.AnchorStyles.Right;
            this.pnlFooter.Controls.Add(this.btnCancel);
            this.pnlFooter.Controls.Add(this.btnConfirm);
            this.pnlFooter.Controls.Add(this.btnSelect);

            // キャンセルボタン（左下 / 常に表示）
            this.btnCancel.Location  = new System.Drawing.Point(16, 11);
            this.btnCancel.Size      = new System.Drawing.Size(110, 36);
            this.btnCancel.Text      = "\u30ad\u30e3\u30f3\u30bb\u30eb";
            this.btnCancel.Font      = new System.Drawing.Font("MS UI Gothic", 10F);
            this.btnCancel.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnCancel.BackColor = System.Drawing.Color.FromArgb(220, 222, 226);
            this.btnCancel.ForeColor = System.Drawing.Color.FromArgb(60, 60, 60);
            this.btnCancel.FlatAppearance.BorderSize = 0;
            this.btnCancel.Anchor    = System.Windows.Forms.AnchorStyles.Top
                                     | System.Windows.Forms.AnchorStyles.Left;
            this.btnCancel.TabIndex  = 4;
            this.btnCancel.Click    += new System.EventHandler(this.btnCancel_Click);

            // 確定ボタン（右下 / 右パネル非表示時のみ表示 / 未選択時は非活性）
            this.btnConfirm.Location  = new System.Drawing.Point(554, 11);
            this.btnConfirm.Size      = new System.Drawing.Size(110, 36);
            this.btnConfirm.Text      = "\u78ba\u5b9a";
            this.btnConfirm.Font      = new System.Drawing.Font("MS UI Gothic", 10F, System.Drawing.FontStyle.Bold);
            this.btnConfirm.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnConfirm.BackColor = System.Drawing.Color.FromArgb(180, 180, 180);
            this.btnConfirm.ForeColor = System.Drawing.Color.White;
            this.btnConfirm.FlatAppearance.BorderSize = 0;
            this.btnConfirm.Enabled   = false;
            this.btnConfirm.Anchor    = System.Windows.Forms.AnchorStyles.Top
                                      | System.Windows.Forms.AnchorStyles.Right;
            this.btnConfirm.TabIndex  = 3;
            this.btnConfirm.Click    += new System.EventHandler(this.btnConfirm_Click);

            // 選択ボタン（右下 / 右パネル表示時のみ表示 / 確定と同位置・同サイズ）
            this.btnSelect.Location  = new System.Drawing.Point(554, 11);
            this.btnSelect.Size      = new System.Drawing.Size(110, 36);
            this.btnSelect.Text      = "\u9078\u629e";
            this.btnSelect.Font      = new System.Drawing.Font("MS UI Gothic", 10F, System.Drawing.FontStyle.Bold);
            this.btnSelect.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnSelect.BackColor = System.Drawing.Color.FromArgb(24, 119, 242);
            this.btnSelect.ForeColor = System.Drawing.Color.White;
            this.btnSelect.FlatAppearance.BorderSize = 0;
            this.btnSelect.Visible   = false;
            this.btnSelect.Anchor    = System.Windows.Forms.AnchorStyles.Top
                                     | System.Windows.Forms.AnchorStyles.Right;
            this.btnSelect.TabIndex  = 5;
            this.btnSelect.Click    += new System.EventHandler(this.btnSelect_Click);

            // --------------------------------------------------
            // FormFacilitySelect
            // --------------------------------------------------
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode       = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor           = System.Drawing.Color.FromArgb(242, 244, 247);
            this.ClientSize          = new System.Drawing.Size(672, 483);
            this.Controls.Add(this.lblTitle);
            this.Controls.Add(this.pnlSepTop);
            this.Controls.Add(this.pnlLeft);
            this.Controls.Add(this.pnlRight);
            this.Controls.Add(this.pnlSepFooter);
            this.Controls.Add(this.pnlFooter);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.MaximizeBox     = false;
            this.MinimizeBox     = false;
            this.Name            = "FormFacilitySelect";
            this.StartPosition   = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text            = "\u65bd\u8a2d\u9078\u629e";
            this.pnlLeft.ResumeLayout(false);
            this.pnlRight.ResumeLayout(false);
            this.pnlFooter.ResumeLayout(false);
            this.ResumeLayout(false);
        }

        private System.Windows.Forms.Label   lblTitle;
        private System.Windows.Forms.Panel   pnlSepTop;
        private System.Windows.Forms.Panel   pnlLeft;
        private System.Windows.Forms.Label   lblSelectedTitle;
        private System.Windows.Forms.Button  btnManualInput;
        private System.Windows.Forms.Panel   pnlSepLeft;
        private System.Windows.Forms.Panel   pnlSelectedContent;
        private System.Windows.Forms.Panel   pnlRight;
        private System.Windows.Forms.Label   lblAvailTitle;
        private System.Windows.Forms.Button  btnCloseRight;
        private System.Windows.Forms.Panel   pnlSepRight;
        private System.Windows.Forms.ListBox lstAvailable;
        private System.Windows.Forms.Panel   pnlSepFooter;
        private System.Windows.Forms.Panel   pnlFooter;
        private System.Windows.Forms.Button  btnCancel;
        private System.Windows.Forms.Button  btnConfirm;
        private System.Windows.Forms.Button  btnSelect;
    }
}
