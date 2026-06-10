namespace LayoutDesigner
{
    partial class frmSelectWaterSurveyPointFilter
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
            if( disposing && (components != null) ) {
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
            this.lstSurvey = new System.Windows.Forms.ListBox();
            this.btnOK = new System.Windows.Forms.Button();
            this.btnCancel = new System.Windows.Forms.Button();
            this.lblFree = new System.Windows.Forms.Label();
            this.txtFree = new System.Windows.Forms.TextBox();
            this.pnlOnline = new System.Windows.Forms.Panel();
            this.pnlFooter = new System.Windows.Forms.Panel();
            this.chkDevelopment = new System.Windows.Forms.CheckBox();
            this.pnlOffline = new System.Windows.Forms.Panel();
            this.txtSurveyCd = new System.Windows.Forms.TextBox();
            this.lblSurveyCd = new System.Windows.Forms.Label();
            this.pnlHeader = new System.Windows.Forms.Panel();
            this.lblPathAddr = new System.Windows.Forms.Label();
            this.lblMode = new System.Windows.Forms.Label();
            this.pnlOnline.SuspendLayout();
            this.pnlFooter.SuspendLayout();
            this.pnlOffline.SuspendLayout();
            this.pnlHeader.SuspendLayout();
            this.SuspendLayout();
            // 
            // btnStop
            // 
            this.btnStop.Location = new System.Drawing.Point(520, 498);
            this.btnStop.TabIndex = 7;
            // 
            // btnTop
            // 
            this.btnTop.Location = new System.Drawing.Point(4, 5);
            // 
            // btnFocusControl
            // 
            this.btnFocusControl.Location = new System.Drawing.Point(520, 458);
            this.btnFocusControl.TabIndex = 6;
            // 
            // winlblTitle
            // 
            this.winlblTitle.Font = new System.Drawing.Font("Yu Gothic UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.winlblTitle.Size = new System.Drawing.Size(596, 18);
            this.winlblTitle.Text = "水質調査箇所フィルタ設定";
            // 
            // lstSurvey
            // 
            this.lstSurvey.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lstSurvey.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(66)))), ((int)(((byte)(66)))), ((int)(((byte)(66)))));
            this.lstSurvey.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.lstSurvey.ForeColor = System.Drawing.Color.White;
            this.lstSurvey.FormattingEnabled = true;
            this.lstSurvey.ItemHeight = 15;
            this.lstSurvey.Location = new System.Drawing.Point(9, 35);
            this.lstSurvey.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.lstSurvey.Name = "lstSurvey";
            this.lstSurvey.Size = new System.Drawing.Size(235, 287);
            this.lstSurvey.TabIndex = 2;
            // 
            // btnOK
            // 
            this.btnOK.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnOK.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnOK.FlatAppearance.BorderSize = 2;
            this.btnOK.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnOK.Location = new System.Drawing.Point(499, 27);
            this.btnOK.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.btnOK.Name = "btnOK";
            this.btnOK.Size = new System.Drawing.Size(87, 29);
            this.btnOK.TabIndex = 5;
            this.btnOK.Text = "OK";
            this.btnOK.UseVisualStyleBackColor = true;
            // 
            // btnCancel
            // 
            this.btnCancel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.btnCancel.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnCancel.FlatAppearance.BorderSize = 2;
            this.btnCancel.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnCancel.Location = new System.Drawing.Point(404, 27);
            this.btnCancel.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(87, 29);
            this.btnCancel.TabIndex = 4;
            this.btnCancel.Text = "キャンセル";
            this.btnCancel.UseVisualStyleBackColor = true;
            // 
            // lblFree
            // 
            this.lblFree.AutoSize = true;
            this.lblFree.Location = new System.Drawing.Point(7, 10);
            this.lblFree.Name = "lblFree";
            this.lblFree.Size = new System.Drawing.Size(49, 15);
            this.lblFree.TabIndex = 0;
            this.lblFree.Text = "ﾌﾘｰﾜｰﾄﾞ";
            // 
            // txtFree
            // 
            this.txtFree.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.txtFree.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.txtFree.ForeColor = System.Drawing.Color.White;
            this.txtFree.Location = new System.Drawing.Point(72, 6);
            this.txtFree.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.txtFree.Name = "txtFree";
            this.txtFree.Size = new System.Drawing.Size(172, 23);
            this.txtFree.TabIndex = 1;
            // 
            // pnlOnline
            // 
            this.pnlOnline.Controls.Add(this.lstSurvey);
            this.pnlOnline.Controls.Add(this.txtFree);
            this.pnlOnline.Controls.Add(this.lblFree);
            this.pnlOnline.Location = new System.Drawing.Point(2, 47);
            this.pnlOnline.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.pnlOnline.Name = "pnlOnline";
            this.pnlOnline.Size = new System.Drawing.Size(256, 331);
            this.pnlOnline.TabIndex = 3;
            // 
            // pnlFooter
            // 
            this.pnlFooter.Controls.Add(this.chkDevelopment);
            this.pnlFooter.Controls.Add(this.btnOK);
            this.pnlFooter.Controls.Add(this.btnCancel);
            this.pnlFooter.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.pnlFooter.Location = new System.Drawing.Point(2, 381);
            this.pnlFooter.Name = "pnlFooter";
            this.pnlFooter.Size = new System.Drawing.Size(596, 67);
            this.pnlFooter.TabIndex = 5;
            // 
            // chkDevelopment
            // 
            this.chkDevelopment.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.chkDevelopment.AutoSize = true;
            this.chkDevelopment.Location = new System.Drawing.Point(433, 1);
            this.chkDevelopment.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.chkDevelopment.Name = "chkDevelopment";
            this.chkDevelopment.Size = new System.Drawing.Size(153, 19);
            this.chkDevelopment.TabIndex = 3;
            this.chkDevelopment.Text = "同グループの別項目に展開";
            this.chkDevelopment.UseVisualStyleBackColor = true;
            // 
            // pnlOffline
            // 
            this.pnlOffline.Controls.Add(this.txtSurveyCd);
            this.pnlOffline.Controls.Add(this.lblSurveyCd);
            this.pnlOffline.Location = new System.Drawing.Point(262, 47);
            this.pnlOffline.Name = "pnlOffline";
            this.pnlOffline.Size = new System.Drawing.Size(336, 38);
            this.pnlOffline.TabIndex = 4;
            // 
            // txtSurveyCd
            // 
            this.txtSurveyCd.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.txtSurveyCd.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.txtSurveyCd.ForeColor = System.Drawing.Color.White;
            this.txtSurveyCd.ImeMode = System.Windows.Forms.ImeMode.Disable;
            this.txtSurveyCd.Location = new System.Drawing.Point(111, 3);
            this.txtSurveyCd.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.txtSurveyCd.Name = "txtSurveyCd";
            this.txtSurveyCd.Size = new System.Drawing.Size(221, 23);
            this.txtSurveyCd.TabIndex = 1;
            // 
            // lblSurveyCd
            // 
            this.lblSurveyCd.AutoSize = true;
            this.lblSurveyCd.Location = new System.Drawing.Point(3, 6);
            this.lblSurveyCd.Name = "lblSurveyCd";
            this.lblSurveyCd.Size = new System.Drawing.Size(103, 15);
            this.lblSurveyCd.TabIndex = 0;
            this.lblSurveyCd.Text = "水質調査箇所コード";
            // 
            // pnlHeader
            // 
            this.pnlHeader.Controls.Add(this.lblPathAddr);
            this.pnlHeader.Controls.Add(this.lblMode);
            this.pnlHeader.Dock = System.Windows.Forms.DockStyle.Top;
            this.pnlHeader.Location = new System.Drawing.Point(2, 20);
            this.pnlHeader.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.pnlHeader.Name = "pnlHeader";
            this.pnlHeader.Size = new System.Drawing.Size(596, 25);
            this.pnlHeader.TabIndex = 2;
            // 
            // lblPathAddr
            // 
            this.lblPathAddr.AutoSize = true;
            this.lblPathAddr.Location = new System.Drawing.Point(6, 5);
            this.lblPathAddr.Name = "lblPathAddr";
            this.lblPathAddr.Size = new System.Drawing.Size(10, 15);
            this.lblPathAddr.TabIndex = 0;
            this.lblPathAddr.Text = " ";
            // 
            // lblMode
            // 
            this.lblMode.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lblMode.Font = new System.Drawing.Font("MS UI Gothic", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.lblMode.ForeColor = System.Drawing.Color.Red;
            this.lblMode.Location = new System.Drawing.Point(445, 5);
            this.lblMode.Name = "lblMode";
            this.lblMode.Size = new System.Drawing.Size(147, 15);
            this.lblMode.TabIndex = 1;
            this.lblMode.Text = "モード出力";
            this.lblMode.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // frmSelectWaterSurveyPointFilter
            // 
            this.AcceptButton = this.btnOK;
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.CancelButton = this.btnCancel;
            this.ClientSize = new System.Drawing.Size(600, 450);
            this.Controls.Add(this.pnlOnline);
            this.Controls.Add(this.pnlFooter);
            this.Controls.Add(this.pnlOffline);
            this.Controls.Add(this.pnlHeader);
            this.Margin = new System.Windows.Forms.Padding(3, 5, 3, 5);
            this.Name = "frmSelectWaterSurveyPointFilter";
            this.Text = "frmSelectExam";
            this.Controls.SetChildIndex(this.btnFocusControl, 0);
            this.Controls.SetChildIndex(this.btnStop, 0);
            this.Controls.SetChildIndex(this.btnTop, 0);
            this.Controls.SetChildIndex(this.winlblTitle, 0);
            this.Controls.SetChildIndex(this.pnlHeader, 0);
            this.Controls.SetChildIndex(this.pnlOffline, 0);
            this.Controls.SetChildIndex(this.pnlFooter, 0);
            this.Controls.SetChildIndex(this.pnlOnline, 0);
            this.pnlOnline.ResumeLayout(false);
            this.pnlOnline.PerformLayout();
            this.pnlFooter.ResumeLayout(false);
            this.pnlFooter.PerformLayout();
            this.pnlOffline.ResumeLayout(false);
            this.pnlOffline.PerformLayout();
            this.pnlHeader.ResumeLayout(false);
            this.pnlHeader.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.ListBox lstSurvey;
        private System.Windows.Forms.Button btnOK;
        private System.Windows.Forms.Button btnCancel;
        private System.Windows.Forms.Label lblFree;
        private System.Windows.Forms.TextBox txtFree;
        private System.Windows.Forms.Panel pnlOnline;
        private System.Windows.Forms.Panel pnlFooter;
        private System.Windows.Forms.Panel pnlOffline;
        private System.Windows.Forms.TextBox txtSurveyCd;
        private System.Windows.Forms.Label lblSurveyCd;
        private System.Windows.Forms.Panel pnlHeader;
        private System.Windows.Forms.Label lblMode;
        private System.Windows.Forms.Label lblPathAddr;
        private System.Windows.Forms.CheckBox chkDevelopment;
    }
}