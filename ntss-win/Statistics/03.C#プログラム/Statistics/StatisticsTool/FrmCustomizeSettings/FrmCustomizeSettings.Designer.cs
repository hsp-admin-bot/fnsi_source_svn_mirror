namespace Fnw.StatisticsTool.FrmCustomize
{
    partial class FrmCustomizeSettings
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FrmCustomizeSettings));
            this.btnOK = new System.Windows.Forms.Button();
            this.btnCancel = new System.Windows.Forms.Button();
            this.rbDialysisTimeInd = new System.Windows.Forms.RadioButton();
            this.rbDialysisTimeRst = new System.Windows.Forms.RadioButton();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.rbHdfInfoRst = new System.Windows.Forms.RadioButton();
            this.rbHdfInfoInd = new System.Windows.Forms.RadioButton();
            this.groupBox3 = new System.Windows.Forms.GroupBox();
            this.rbCorrectionCaNo = new System.Windows.Forms.RadioButton();
            this.rbCorrectionCaYes = new System.Windows.Forms.RadioButton();
            this.groupBox4 = new System.Windows.Forms.GroupBox();
            this.rbCorrectionHbA1cNo = new System.Windows.Forms.RadioButton();
            this.rbCorrectionHbA1cYes = new System.Windows.Forms.RadioButton();
            this.groupBox1.SuspendLayout();
            this.groupBox2.SuspendLayout();
            this.groupBox3.SuspendLayout();
            this.groupBox4.SuspendLayout();
            this.SuspendLayout();
            // 
            // btnOK
            // 
            this.btnOK.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnOK.Location = new System.Drawing.Point(260, 233);
            this.btnOK.Name = "btnOK";
            this.btnOK.Size = new System.Drawing.Size(75, 23);
            this.btnOK.TabIndex = 12;
            this.btnOK.Text = "OK";
            this.btnOK.UseVisualStyleBackColor = true;
            this.btnOK.Click += new System.EventHandler(this.btnOK_Click);
            // 
            // btnCancel
            // 
            this.btnCancel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnCancel.Location = new System.Drawing.Point(341, 233);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(75, 23);
            this.btnCancel.TabIndex = 13;
            this.btnCancel.Text = "キャンセル";
            this.btnCancel.UseVisualStyleBackColor = true;
            this.btnCancel.Click += new System.EventHandler(this.btnCancel_Click);
            // 
            // rbDialysisTimeInd
            // 
            this.rbDialysisTimeInd.AutoSize = true;
            this.rbDialysisTimeInd.Location = new System.Drawing.Point(6, 18);
            this.rbDialysisTimeInd.Name = "rbDialysisTimeInd";
            this.rbDialysisTimeInd.Size = new System.Drawing.Size(397, 16);
            this.rbDialysisTimeInd.TabIndex = 0;
            this.rbDialysisTimeInd.TabStop = true;
            this.rbDialysisTimeInd.Text = "指示透析データを使用する（データが存在しない場合は実績透析データを使用）";
            this.rbDialysisTimeInd.UseVisualStyleBackColor = true;
            // 
            // rbDialysisTimeRst
            // 
            this.rbDialysisTimeRst.AutoSize = true;
            this.rbDialysisTimeRst.Location = new System.Drawing.Point(6, 40);
            this.rbDialysisTimeRst.Name = "rbDialysisTimeRst";
            this.rbDialysisTimeRst.Size = new System.Drawing.Size(151, 16);
            this.rbDialysisTimeRst.TabIndex = 1;
            this.rbDialysisTimeRst.TabStop = true;
            this.rbDialysisTimeRst.Text = "実績透析データを使用する";
            this.rbDialysisTimeRst.UseVisualStyleBackColor = true;
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.rbDialysisTimeRst);
            this.groupBox1.Controls.Add(this.rbDialysisTimeInd);
            this.groupBox1.Location = new System.Drawing.Point(12, 12);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(404, 65);
            this.groupBox1.TabIndex = 2;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "「透析時間」設定";
            // 
            // groupBox2
            // 
            this.groupBox2.Controls.Add(this.rbHdfInfoRst);
            this.groupBox2.Controls.Add(this.rbHdfInfoInd);
            this.groupBox2.Location = new System.Drawing.Point(12, 83);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Size = new System.Drawing.Size(404, 65);
            this.groupBox2.TabIndex = 5;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "「HDF希釈方法、1ｾｯｼｮﾝあたりの置換液量」設定";
            // 
            // rbHdfInfoRst
            // 
            this.rbHdfInfoRst.AutoSize = true;
            this.rbHdfInfoRst.Location = new System.Drawing.Point(6, 40);
            this.rbHdfInfoRst.Name = "rbHdfInfoRst";
            this.rbHdfInfoRst.Size = new System.Drawing.Size(151, 16);
            this.rbHdfInfoRst.TabIndex = 4;
            this.rbHdfInfoRst.TabStop = true;
            this.rbHdfInfoRst.Text = "実績透析データを使用する";
            this.rbHdfInfoRst.UseVisualStyleBackColor = true;
            // 
            // rbHdfInfoInd
            // 
            this.rbHdfInfoInd.AutoSize = true;
            this.rbHdfInfoInd.Location = new System.Drawing.Point(6, 18);
            this.rbHdfInfoInd.Name = "rbHdfInfoInd";
            this.rbHdfInfoInd.Size = new System.Drawing.Size(397, 16);
            this.rbHdfInfoInd.TabIndex = 3;
            this.rbHdfInfoInd.TabStop = true;
            this.rbHdfInfoInd.Text = "指示透析データを使用する（データが存在しない場合は実績透析データを使用）";
            this.rbHdfInfoInd.UseVisualStyleBackColor = true;
            // 
            // groupBox3
            // 
            this.groupBox3.Controls.Add(this.rbCorrectionCaNo);
            this.groupBox3.Controls.Add(this.rbCorrectionCaYes);
            this.groupBox3.Location = new System.Drawing.Point(12, 154);
            this.groupBox3.Name = "groupBox3";
            this.groupBox3.Size = new System.Drawing.Size(404, 65);
            this.groupBox3.TabIndex = 8;
            this.groupBox3.TabStop = false;
            this.groupBox3.Text = "「カルシウム濃度」補正設定";
            // 
            // rbCorrectionCaNo
            // 
            this.rbCorrectionCaNo.AutoSize = true;
            this.rbCorrectionCaNo.Location = new System.Drawing.Point(6, 40);
            this.rbCorrectionCaNo.Name = "rbCorrectionCaNo";
            this.rbCorrectionCaNo.Size = new System.Drawing.Size(125, 16);
            this.rbCorrectionCaNo.TabIndex = 7;
            this.rbCorrectionCaNo.TabStop = true;
            this.rbCorrectionCaNo.Text = "補正しない（そのまま）";
            this.rbCorrectionCaNo.UseVisualStyleBackColor = true;
            // 
            // rbCorrectionCaYes
            // 
            this.rbCorrectionCaYes.AutoSize = true;
            this.rbCorrectionCaYes.Location = new System.Drawing.Point(6, 18);
            this.rbCorrectionCaYes.Name = "rbCorrectionCaYes";
            this.rbCorrectionCaYes.Size = new System.Drawing.Size(266, 16);
            this.rbCorrectionCaYes.TabIndex = 6;
            this.rbCorrectionCaYes.TabStop = true;
            this.rbCorrectionCaYes.Text = "補正する（検査値2倍）　※単位が「mEq/L」の場合";
            this.rbCorrectionCaYes.UseVisualStyleBackColor = true;
            // 
            // groupBox4
            // 
            this.groupBox4.Controls.Add(this.rbCorrectionHbA1cNo);
            this.groupBox4.Controls.Add(this.rbCorrectionHbA1cYes);
            this.groupBox4.Location = new System.Drawing.Point(12, 225);
            this.groupBox4.Name = "groupBox4";
            this.groupBox4.Size = new System.Drawing.Size(404, 65);
            this.groupBox4.TabIndex = 11;
            this.groupBox4.TabStop = false;
            this.groupBox4.Text = "「ヘモグロビンA1c」補正設定";
            this.groupBox4.Visible = false;
            // 
            // rbCorrectionHbA1cNo
            // 
            this.rbCorrectionHbA1cNo.AutoSize = true;
            this.rbCorrectionHbA1cNo.Location = new System.Drawing.Point(6, 40);
            this.rbCorrectionHbA1cNo.Name = "rbCorrectionHbA1cNo";
            this.rbCorrectionHbA1cNo.Size = new System.Drawing.Size(125, 16);
            this.rbCorrectionHbA1cNo.TabIndex = 10;
            this.rbCorrectionHbA1cNo.TabStop = true;
            this.rbCorrectionHbA1cNo.Text = "補正しない（そのまま）";
            this.rbCorrectionHbA1cNo.UseVisualStyleBackColor = true;
            // 
            // rbCorrectionHbA1cYes
            // 
            this.rbCorrectionHbA1cYes.AutoSize = true;
            this.rbCorrectionHbA1cYes.Location = new System.Drawing.Point(6, 18);
            this.rbCorrectionHbA1cYes.Name = "rbCorrectionHbA1cYes";
            this.rbCorrectionHbA1cYes.Size = new System.Drawing.Size(228, 16);
            this.rbCorrectionHbA1cYes.TabIndex = 9;
            this.rbCorrectionHbA1cYes.TabStop = true;
            this.rbCorrectionHbA1cYes.Text = "補正する（検査値+0.4%）　※JDS値の場合";
            this.rbCorrectionHbA1cYes.UseVisualStyleBackColor = true;
            // 
            // FrmCustomizeSettings
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(428, 268);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.btnOK);
            this.Controls.Add(this.groupBox4);
            this.Controls.Add(this.groupBox3);
            this.Controls.Add(this.groupBox2);
            this.Controls.Add(this.groupBox1);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.MaximizeBox = false;
            this.Name = "FrmCustomizeSettings";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "抽出設定";
            this.Load += new System.EventHandler(this.FrmCustomizeSettings_Load);
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.groupBox2.ResumeLayout(false);
            this.groupBox2.PerformLayout();
            this.groupBox3.ResumeLayout(false);
            this.groupBox3.PerformLayout();
            this.groupBox4.ResumeLayout(false);
            this.groupBox4.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Button btnOK;
        private System.Windows.Forms.Button btnCancel;
        private System.Windows.Forms.RadioButton rbDialysisTimeInd;
        private System.Windows.Forms.RadioButton rbDialysisTimeRst;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.GroupBox groupBox2;
        private System.Windows.Forms.RadioButton rbHdfInfoRst;
        private System.Windows.Forms.RadioButton rbHdfInfoInd;
        private System.Windows.Forms.GroupBox groupBox3;
        private System.Windows.Forms.RadioButton rbCorrectionCaNo;
        private System.Windows.Forms.RadioButton rbCorrectionCaYes;
        private System.Windows.Forms.GroupBox groupBox4;
        private System.Windows.Forms.RadioButton rbCorrectionHbA1cNo;
        private System.Windows.Forms.RadioButton rbCorrectionHbA1cYes;
    }
}