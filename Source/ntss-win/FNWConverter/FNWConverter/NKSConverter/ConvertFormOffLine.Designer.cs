using ConvertCommon;
using NKSConverter.Controls;
using NKSConverter.Properties;

namespace NKSConverter
{
  partial class ConvertFormOffLine
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(ConvertFormOffLine));
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.elapsedTimeLb = new System.Windows.Forms.Label();
            this.updateProgressBarBtn = new NKSConverter.Controls.RoundedButton();
            this.label2 = new System.Windows.Forms.Label();
            this.progressBar1 = new NKSConverter.Controls.TextProgressBar();
            this.FNSi_Status = new System.Windows.Forms.RadioButton();
            this.FNW_Status = new System.Windows.Forms.RadioButton();
            this.groupBox3 = new System.Windows.Forms.GroupBox();
            this.updateLogBtn = new NKSConverter.Controls.RoundedButton();
            this.lstLog = new System.Windows.Forms.ListBox();
            this.grpFacilityInfo = new System.Windows.Forms.GroupBox();
            this.panelFacilityCdList = new System.Windows.Forms.Panel();
            this.label1 = new System.Windows.Forms.Label();
            this.cmbSeriesCd = new System.Windows.Forms.ComboBox();
            this.label5 = new System.Windows.Forms.Label();
            this.label6 = new System.Windows.Forms.Label();
            this.txtFacilityCd = new System.Windows.Forms.TextBox();
            this.groupBox2.SuspendLayout();
            this.groupBox3.SuspendLayout();
            this.grpFacilityInfo.SuspendLayout();
            this.panelFacilityCdList.SuspendLayout();
            this.SuspendLayout();
            // 
            // groupBox2
            // 
            this.groupBox2.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.groupBox2.Controls.Add(this.elapsedTimeLb);
            this.groupBox2.Controls.Add(this.updateProgressBarBtn);
            this.groupBox2.Controls.Add(this.label2);
            this.groupBox2.Controls.Add(this.progressBar1);
            this.groupBox2.Controls.Add(this.FNSi_Status);
            this.groupBox2.Controls.Add(this.FNW_Status);
            this.groupBox2.ForeColor = System.Drawing.Color.White;
            this.groupBox2.Location = new System.Drawing.Point(12, 483);
            this.groupBox2.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Padding = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.groupBox2.Size = new System.Drawing.Size(1066, 116);
            this.groupBox2.TabIndex = 4;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "進捗状況";
            // 
            // elapsedTimeLb
            // 
            this.elapsedTimeLb.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.elapsedTimeLb.AutoSize = true;
            this.elapsedTimeLb.Location = new System.Drawing.Point(165, 119);
            this.elapsedTimeLb.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.elapsedTimeLb.Name = "elapsedTimeLb";
            this.elapsedTimeLb.Size = new System.Drawing.Size(125, 12);
            this.elapsedTimeLb.TabIndex = 3;
            this.elapsedTimeLb.Text = "yyyy/MM/dd HH:mm:ss";
            // 
            // updateProgressBarBtn
            // 
            this.updateProgressBarBtn.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.updateProgressBarBtn.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.updateProgressBarBtn.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.updateProgressBarBtn.FlatAppearance.BorderSize = 2;
            this.updateProgressBarBtn.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.updateProgressBarBtn.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.updateProgressBarBtn.Image = ((System.Drawing.Image)(resources.GetObject("updateProgressBarBtn.Image")));
            this.updateProgressBarBtn.Location = new System.Drawing.Point(980, 16);
            this.updateProgressBarBtn.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.updateProgressBarBtn.Name = "updateProgressBarBtn";
            this.updateProgressBarBtn.Size = new System.Drawing.Size(80, 28);
            this.updateProgressBarBtn.TabIndex = 5;
            this.updateProgressBarBtn.Text = "  更新";
            this.updateProgressBarBtn.TextImageRelation = System.Windows.Forms.TextImageRelation.ImageBeforeText;
            this.updateProgressBarBtn.UseVisualStyleBackColor = false;
            // 
            // label2
            // 
            this.label2.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(17, 95);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(83, 12);
            this.label2.TabIndex = 3;
            this.label2.Text = "完了予想日時：";
            // 
            // progressBar1
            // 
            this.progressBar1.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.progressBar1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(64)))), ((int)(((byte)(64)))));
            this.progressBar1.CustomText = "";
            this.progressBar1.Location = new System.Drawing.Point(6, 55);
            this.progressBar1.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.progressBar1.Name = "progressBar1";
            this.progressBar1.ProgressColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(64)))), ((int)(((byte)(64)))));
            this.progressBar1.Size = new System.Drawing.Size(1054, 28);
            this.progressBar1.Style = System.Windows.Forms.ProgressBarStyle.Marquee;
            this.progressBar1.TabIndex = 2;
            this.progressBar1.TextColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.progressBar1.TextFont = new System.Drawing.Font("Times New Roman", 11F, ((System.Drawing.FontStyle)((System.Drawing.FontStyle.Bold | System.Drawing.FontStyle.Italic))));
            this.progressBar1.VisualMode = NKSConverter.Controls.ProgressBarDisplayMode.Percentage;
            // 
            // FNSi_Status
            // 
            this.FNSi_Status.AutoSize = true;
            this.FNSi_Status.BackColor = System.Drawing.Color.Red;
            this.FNSi_Status.Enabled = false;
            this.FNSi_Status.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.FNSi_Status.Location = new System.Drawing.Point(148, 22);
            this.FNSi_Status.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.FNSi_Status.Name = "FNSi_Status";
            this.FNSi_Status.Size = new System.Drawing.Size(68, 16);
            this.FNSi_Status.TabIndex = 1;
            this.FNSi_Status.TabStop = true;
            this.FNSi_Status.Text = "FNSi DB";
            this.FNSi_Status.UseVisualStyleBackColor = false;
            // 
            // FNW_Status
            // 
            this.FNW_Status.AutoSize = true;
            this.FNW_Status.BackColor = System.Drawing.Color.Red;
            this.FNW_Status.Enabled = false;
            this.FNW_Status.ForeColor = System.Drawing.SystemColors.GradientInactiveCaption;
            this.FNW_Status.Location = new System.Drawing.Point(7, 22);
            this.FNW_Status.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.FNW_Status.Name = "FNW_Status";
            this.FNW_Status.Size = new System.Drawing.Size(67, 16);
            this.FNW_Status.TabIndex = 0;
            this.FNW_Status.TabStop = true;
            this.FNW_Status.Text = "FNW DB";
            this.FNW_Status.UseVisualStyleBackColor = false;
            // 
            // groupBox3
            // 
            this.groupBox3.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.groupBox3.Controls.Add(this.updateLogBtn);
            this.groupBox3.Controls.Add(this.lstLog);
            this.groupBox3.ForeColor = System.Drawing.Color.White;
            this.groupBox3.Location = new System.Drawing.Point(12, 104);
            this.groupBox3.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.groupBox3.Name = "groupBox3";
            this.groupBox3.Padding = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.groupBox3.Size = new System.Drawing.Size(1066, 375);
            this.groupBox3.TabIndex = 4;
            this.groupBox3.TabStop = false;
            this.groupBox3.Text = "ログ";
            // 
            // updateLogBtn
            // 
            this.updateLogBtn.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.updateLogBtn.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.updateLogBtn.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.updateLogBtn.FlatAppearance.BorderSize = 2;
            this.updateLogBtn.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.updateLogBtn.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.updateLogBtn.Image = ((System.Drawing.Image)(resources.GetObject("updateLogBtn.Image")));
            this.updateLogBtn.Location = new System.Drawing.Point(975, 18);
            this.updateLogBtn.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.updateLogBtn.Name = "updateLogBtn";
            this.updateLogBtn.Size = new System.Drawing.Size(80, 28);
            this.updateLogBtn.TabIndex = 7;
            this.updateLogBtn.Text = "  更新";
            this.updateLogBtn.TextImageRelation = System.Windows.Forms.TextImageRelation.ImageBeforeText;
            this.updateLogBtn.UseVisualStyleBackColor = false;
            // 
            // lstLog
            // 
            this.lstLog.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lstLog.BackColor = System.Drawing.SystemColors.AppWorkspace;
            this.lstLog.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.lstLog.FormattingEnabled = true;
            this.lstLog.ItemHeight = 12;
            this.lstLog.Location = new System.Drawing.Point(11, 50);
            this.lstLog.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.lstLog.Name = "lstLog";
            this.lstLog.Size = new System.Drawing.Size(1045, 302);
            this.lstLog.TabIndex = 0;
            // 
            // grpFacilityInfo
            // 
            this.grpFacilityInfo.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.grpFacilityInfo.Controls.Add(this.panelFacilityCdList);
            this.grpFacilityInfo.Controls.Add(this.cmbSeriesCd);
            this.grpFacilityInfo.Controls.Add(this.label5);
            this.grpFacilityInfo.Controls.Add(this.label6);
            this.grpFacilityInfo.Controls.Add(this.txtFacilityCd);
            this.grpFacilityInfo.ForeColor = System.Drawing.Color.White;
            this.grpFacilityInfo.Location = new System.Drawing.Point(12, 2);
            this.grpFacilityInfo.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.grpFacilityInfo.Name = "grpFacilityInfo";
            this.grpFacilityInfo.Padding = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.grpFacilityInfo.Size = new System.Drawing.Size(1066, 98);
            this.grpFacilityInfo.TabIndex = 29;
            this.grpFacilityInfo.TabStop = false;
            this.grpFacilityInfo.Text = "施設情報";
            // 
            // panelFacilityCdList
            // 
            this.panelFacilityCdList.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.panelFacilityCdList.AutoScroll = true;
            this.panelFacilityCdList.Controls.Add(this.label1);
            this.panelFacilityCdList.Location = new System.Drawing.Point(4, 18);
            this.panelFacilityCdList.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.panelFacilityCdList.Name = "panelFacilityCdList";
            this.panelFacilityCdList.Size = new System.Drawing.Size(1037, 82);
            this.panelFacilityCdList.TabIndex = 6;
            // 
            // label1
            // 
            this.label1.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(949, 15);
            this.label1.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(0, 12);
            this.label1.TabIndex = 7;
            // 
            // cmbSeriesCd
            // 
            this.cmbSeriesCd.DataBindings.Add(new System.Windows.Forms.Binding("Text", global::NKSConverter.Properties.Settings.Default, "cmbSeriesCd", true, System.Windows.Forms.DataSourceUpdateMode.OnPropertyChanged));
            this.cmbSeriesCd.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cmbSeriesCd.FormattingEnabled = true;
            this.cmbSeriesCd.Location = new System.Drawing.Point(157, 62);
            this.cmbSeriesCd.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.cmbSeriesCd.Name = "cmbSeriesCd";
            this.cmbSeriesCd.Size = new System.Drawing.Size(451, 20);
            this.cmbSeriesCd.TabIndex = 1;
            this.cmbSeriesCd.Text = global::NKSConverter.Properties.Settings.Default.cmbSeriesCd;
            this.cmbSeriesCd.Visible = false;
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(12, 52);
            this.label5.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(120, 12);
            this.label5.TabIndex = 1;
            this.label5.Text = "データ移行先施設コード";
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Location = new System.Drawing.Point(12, 81);
            this.label6.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(144, 12);
            this.label6.TabIndex = 25;
            this.label6.Text = "データ移行元系列施設コード";
            this.label6.Visible = false;
            // 
            // txtFacilityCd
            // 
            this.txtFacilityCd.ImeMode = System.Windows.Forms.ImeMode.Off;
            this.txtFacilityCd.Location = new System.Drawing.Point(157, 39);
            this.txtFacilityCd.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.txtFacilityCd.MaxLength = 6;
            this.txtFacilityCd.Name = "txtFacilityCd";
            this.txtFacilityCd.Size = new System.Drawing.Size(451, 19);
            this.txtFacilityCd.TabIndex = 0;
            this.txtFacilityCd.TextChanged += new System.EventHandler(this.ConvertFormOffLine_MenuComplete);
            // 
            // ConvertFormOffLine
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.ClientSize = new System.Drawing.Size(1090, 610);
            this.Controls.Add(this.grpFacilityInfo);
            this.Controls.Add(this.groupBox2);
            this.Controls.Add(this.groupBox3);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.Name = "ConvertFormOffLine";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "FNW ->FNSiコンバータ";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.ConvertFormOffLine_FormClosing);
            this.groupBox2.ResumeLayout(false);
            this.groupBox2.PerformLayout();
            this.groupBox3.ResumeLayout(false);
            this.grpFacilityInfo.ResumeLayout(false);
            this.grpFacilityInfo.PerformLayout();
            this.panelFacilityCdList.ResumeLayout(false);
            this.panelFacilityCdList.PerformLayout();
            this.ResumeLayout(false);

    }

    #endregion
    private System.Windows.Forms.GroupBox groupBox2;
    private System.Windows.Forms.Label elapsedTimeLb;
    private RoundedButton updateProgressBarBtn;
    private System.Windows.Forms.Label label2;
    private TextProgressBar progressBar1;
    private System.Windows.Forms.RadioButton FNSi_Status;
    private System.Windows.Forms.RadioButton FNW_Status;
    private System.Windows.Forms.GroupBox groupBox3;
    private System.Windows.Forms.ListBox lstLog;
    private System.Windows.Forms.GroupBox grpFacilityInfo;
    private System.Windows.Forms.ComboBox cmbSeriesCd;
    private System.Windows.Forms.Label label5;
    private System.Windows.Forms.Label label6;
    private System.Windows.Forms.TextBox txtFacilityCd;
        private RoundedButton updateLogBtn;
        private System.Windows.Forms.Panel panelFacilityCdList;
        private System.Windows.Forms.Label label1;
    }
}
