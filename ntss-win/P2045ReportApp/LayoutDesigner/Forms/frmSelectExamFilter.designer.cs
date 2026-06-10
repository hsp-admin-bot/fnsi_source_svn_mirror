namespace LayoutDesigner
{
    partial class frmSelectExamFilter
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
            this.lstExam = new System.Windows.Forms.ListBox();
            this.chkBefore = new System.Windows.Forms.CheckBox();
            this.chkAfter = new System.Windows.Forms.CheckBox();
            this.chkOther = new System.Windows.Forms.CheckBox();
            this.btnOK = new System.Windows.Forms.Button();
            this.btnCancel = new System.Windows.Forms.Button();
            this.lblFree = new System.Windows.Forms.Label();
            this.txtFree = new System.Windows.Forms.TextBox();
            this.pnlOnline = new System.Windows.Forms.Panel();
            this.pnlFooter = new System.Windows.Forms.Panel();
            this.chkDevelopment = new System.Windows.Forms.CheckBox();
            this.pnlOffline = new System.Windows.Forms.Panel();
            this.txtExamCd = new System.Windows.Forms.TextBox();
            this.lblExamCd = new System.Windows.Forms.Label();
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
            this.winlblTitle.Size = new System.Drawing.Size(536, 18);
            // 
            // lstExam
            // 
            this.lstExam.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lstExam.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(66)))), ((int)(((byte)(66)))), ((int)(((byte)(66)))));
            this.lstExam.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.lstExam.ForeColor = System.Drawing.Color.White;
            this.lstExam.FormattingEnabled = true;
            this.lstExam.ItemHeight = 15;
            this.lstExam.Location = new System.Drawing.Point(9, 35);
            this.lstExam.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.lstExam.Name = "lstExam";
            this.lstExam.Size = new System.Drawing.Size(235, 257);
            this.lstExam.TabIndex = 2;
            // 
            // chkBefore
            // 
            this.chkBefore.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.chkBefore.AutoSize = true;
            this.chkBefore.Checked = true;
            this.chkBefore.CheckState = System.Windows.Forms.CheckState.Checked;
            this.chkBefore.Location = new System.Drawing.Point(9, 3);
            this.chkBefore.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.chkBefore.Name = "chkBefore";
            this.chkBefore.Size = new System.Drawing.Size(62, 19);
            this.chkBefore.TabIndex = 0;
            this.chkBefore.Text = "透析前";
            this.chkBefore.UseVisualStyleBackColor = true;
            // 
            // chkAfter
            // 
            this.chkAfter.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.chkAfter.AutoSize = true;
            this.chkAfter.Checked = true;
            this.chkAfter.CheckState = System.Windows.Forms.CheckState.Checked;
            this.chkAfter.Location = new System.Drawing.Point(86, 3);
            this.chkAfter.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.chkAfter.Name = "chkAfter";
            this.chkAfter.Size = new System.Drawing.Size(62, 19);
            this.chkAfter.TabIndex = 1;
            this.chkAfter.Text = "透析後";
            this.chkAfter.UseVisualStyleBackColor = true;
            // 
            // chkOther
            // 
            this.chkOther.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.chkOther.AutoSize = true;
            this.chkOther.Checked = true;
            this.chkOther.CheckState = System.Windows.Forms.CheckState.Checked;
            this.chkOther.Location = new System.Drawing.Point(163, 4);
            this.chkOther.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.chkOther.Name = "chkOther";
            this.chkOther.Size = new System.Drawing.Size(57, 19);
            this.chkOther.TabIndex = 2;
            this.chkOther.Text = "その他";
            this.chkOther.UseVisualStyleBackColor = true;
            // 
            // btnOK
            // 
            this.btnOK.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnOK.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnOK.FlatAppearance.BorderSize = 2;
            this.btnOK.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnOK.Location = new System.Drawing.Point(439, 53);
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
            this.btnCancel.Location = new System.Drawing.Point(344, 53);
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
            this.pnlOnline.Controls.Add(this.lstExam);
            this.pnlOnline.Controls.Add(this.txtFree);
            this.pnlOnline.Controls.Add(this.lblFree);
            this.pnlOnline.Location = new System.Drawing.Point(2, 47);
            this.pnlOnline.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.pnlOnline.Name = "pnlOnline";
            this.pnlOnline.Size = new System.Drawing.Size(256, 301);
            this.pnlOnline.TabIndex = 3;
            // 
            // pnlFooter
            // 
            this.pnlFooter.Controls.Add(this.chkDevelopment);
            this.pnlFooter.Controls.Add(this.btnOK);
            this.pnlFooter.Controls.Add(this.btnCancel);
            this.pnlFooter.Controls.Add(this.chkOther);
            this.pnlFooter.Controls.Add(this.chkBefore);
            this.pnlFooter.Controls.Add(this.chkAfter);
            this.pnlFooter.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.pnlFooter.Location = new System.Drawing.Point(2, 355);
            this.pnlFooter.Name = "pnlFooter";
            this.pnlFooter.Size = new System.Drawing.Size(536, 93);
            this.pnlFooter.TabIndex = 5;
            // 
            // chkDevelopment
            // 
            this.chkDevelopment.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.chkDevelopment.AutoSize = true;
            this.chkDevelopment.Location = new System.Drawing.Point(373, 27);
            this.chkDevelopment.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.chkDevelopment.Name = "chkDevelopment";
            this.chkDevelopment.Size = new System.Drawing.Size(153, 19);
            this.chkDevelopment.TabIndex = 3;
            this.chkDevelopment.Text = "同グループの別項目に展開";
            this.chkDevelopment.UseVisualStyleBackColor = true;
            // 
            // pnlOffline
            // 
            this.pnlOffline.Controls.Add(this.txtExamCd);
            this.pnlOffline.Controls.Add(this.lblExamCd);
            this.pnlOffline.Location = new System.Drawing.Point(262, 47);
            this.pnlOffline.Name = "pnlOffline";
            this.pnlOffline.Size = new System.Drawing.Size(276, 38);
            this.pnlOffline.TabIndex = 4;
            // 
            // txtExamCd
            // 
            this.txtExamCd.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.txtExamCd.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.txtExamCd.ForeColor = System.Drawing.Color.White;
            this.txtExamCd.ImeMode = System.Windows.Forms.ImeMode.Disable;
            this.txtExamCd.Location = new System.Drawing.Point(111, 3);
            this.txtExamCd.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.txtExamCd.Name = "txtExamCd";
            this.txtExamCd.Size = new System.Drawing.Size(161, 23);
            this.txtExamCd.TabIndex = 1;
            // 
            // lblExamCd
            // 
            this.lblExamCd.AutoSize = true;
            this.lblExamCd.Location = new System.Drawing.Point(3, 6);
            this.lblExamCd.Name = "lblExamCd";
            this.lblExamCd.Size = new System.Drawing.Size(67, 15);
            this.lblExamCd.TabIndex = 0;
            this.lblExamCd.Text = "コード名出力";
            // 
            // pnlHeader
            // 
            this.pnlHeader.Controls.Add(this.lblPathAddr);
            this.pnlHeader.Controls.Add(this.lblMode);
            this.pnlHeader.Dock = System.Windows.Forms.DockStyle.Top;
            this.pnlHeader.Location = new System.Drawing.Point(2, 20);
            this.pnlHeader.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.pnlHeader.Name = "pnlHeader";
            this.pnlHeader.Size = new System.Drawing.Size(536, 25);
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
            this.lblMode.Location = new System.Drawing.Point(385, 5);
            this.lblMode.Name = "lblMode";
            this.lblMode.Size = new System.Drawing.Size(147, 15);
            this.lblMode.TabIndex = 1;
            this.lblMode.Text = "モード出力";
            this.lblMode.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // frmSelectExamFilter
            // 
            this.AcceptButton = this.btnOK;
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.CancelButton = this.btnCancel;
            this.ClientSize = new System.Drawing.Size(540, 450);
            this.Controls.Add(this.pnlOnline);
            this.Controls.Add(this.pnlFooter);
            this.Controls.Add(this.pnlOffline);
            this.Controls.Add(this.pnlHeader);
            this.Margin = new System.Windows.Forms.Padding(3, 5, 3, 5);
            this.Name = "frmSelectExamFilter";
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

        private System.Windows.Forms.ListBox lstExam;
        private System.Windows.Forms.CheckBox chkBefore;
        private System.Windows.Forms.CheckBox chkAfter;
        private System.Windows.Forms.CheckBox chkOther;
        private System.Windows.Forms.Button btnOK;
        private System.Windows.Forms.Button btnCancel;
        private System.Windows.Forms.Label lblFree;
        private System.Windows.Forms.TextBox txtFree;
        private System.Windows.Forms.Panel pnlOnline;
        private System.Windows.Forms.Panel pnlFooter;
        private System.Windows.Forms.Panel pnlOffline;
        private System.Windows.Forms.TextBox txtExamCd;
        private System.Windows.Forms.Label lblExamCd;
        private System.Windows.Forms.Panel pnlHeader;
        private System.Windows.Forms.Label lblMode;
        private System.Windows.Forms.Label lblPathAddr;
        private System.Windows.Forms.CheckBox chkDevelopment;
    }
}