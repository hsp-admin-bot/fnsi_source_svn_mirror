using ConvertCommon;
using NKSConverter.Controls;
using NKSConverter.Properties;

namespace NKSConverter
{
  partial class ConvertForm
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(ConvertForm));
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.lstStatus = new System.Windows.Forms.ListBox();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.elapsedTimeLb = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.FNSi_Status = new System.Windows.Forms.RadioButton();
            this.FNW_Status = new System.Windows.Forms.RadioButton();
            this.groupBox3 = new System.Windows.Forms.GroupBox();
            this.lstLog = new System.Windows.Forms.ListBox();
            this.grpFacilityInfo = new System.Windows.Forms.GroupBox();
            this.panelFacilityCdList = new System.Windows.Forms.Panel();
            this.label1 = new System.Windows.Forms.Label();
            this.cmbSeriesCd = new System.Windows.Forms.ComboBox();
            this.label5 = new System.Windows.Forms.Label();
            this.label6 = new System.Windows.Forms.Label();
            this.txtFacilityCd = new System.Windows.Forms.TextBox();
            this.checkAutomatic = new System.Windows.Forms.CheckBox();
            this.panel1 = new System.Windows.Forms.Panel();
            this.ExtendButton = new NKSConverter.Controls.RoundedButton();
            this.btnUpload = new NKSConverter.Controls.RoundedButton();
            this.btnConvertAllTable = new NKSConverter.Controls.RoundedButton();
            this.btnConvert = new NKSConverter.Controls.RoundedButton();
            this.btnSetting = new NKSConverter.Controls.RoundedButton();
            this.updateProgressBarBtn = new NKSConverter.Controls.RoundedButton();
            this.updateLogBtn = new NKSConverter.Controls.RoundedButton();
            this.convertInfoUpdatebtn = new NKSConverter.Controls.RoundedButton();
            this.groupBox1.SuspendLayout();
            this.groupBox2.SuspendLayout();
            this.groupBox3.SuspendLayout();
            this.grpFacilityInfo.SuspendLayout();
            this.panelFacilityCdList.SuspendLayout();
            this.SuspendLayout();
            // 
            // groupBox1
            // 
            this.groupBox1.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left)));
            this.groupBox1.Controls.Add(this.lstStatus);
            this.groupBox1.Controls.Add(this.convertInfoUpdatebtn);
            this.groupBox1.ForeColor = System.Drawing.Color.White;
            this.groupBox1.Location = new System.Drawing.Point(12, 106);
            this.groupBox1.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Padding = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.groupBox1.Size = new System.Drawing.Size(360, 228);
            this.groupBox1.TabIndex = 4;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "コンバート対象情報";
            // 
            // lstStatus
            // 
            this.lstStatus.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left)));
            this.lstStatus.BackColor = System.Drawing.SystemColors.AppWorkspace;
            this.lstStatus.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.lstStatus.Font = new System.Drawing.Font("Microsoft Sans Serif", 20F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lstStatus.FormattingEnabled = true;
            this.lstStatus.ItemHeight = 31;
            this.lstStatus.Location = new System.Drawing.Point(7, 50);
            this.lstStatus.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.lstStatus.Name = "lstStatus";
            this.lstStatus.Size = new System.Drawing.Size(348, 126);
            this.lstStatus.TabIndex = 0;
            // 
            // groupBox2
            // 
            this.groupBox2.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.groupBox2.Controls.Add(this.panel1);
            this.groupBox2.Controls.Add(this.elapsedTimeLb);
            this.groupBox2.Controls.Add(this.updateProgressBarBtn);
            this.groupBox2.Controls.Add(this.label2);
            this.groupBox2.Controls.Add(this.FNSi_Status);
            this.groupBox2.Controls.Add(this.FNW_Status);
            this.groupBox2.ForeColor = System.Drawing.Color.White;
            this.groupBox2.Location = new System.Drawing.Point(12, 338);
            this.groupBox2.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Padding = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.groupBox2.Size = new System.Drawing.Size(360, 209);
            this.groupBox2.TabIndex = 4;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "進捗状況";
            // 
            // elapsedTimeLb
            // 
            this.elapsedTimeLb.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.elapsedTimeLb.AutoSize = true;
            this.elapsedTimeLb.Location = new System.Drawing.Point(124, 188);
            this.elapsedTimeLb.Name = "elapsedTimeLb";
            this.elapsedTimeLb.Size = new System.Drawing.Size(125, 12);
            this.elapsedTimeLb.TabIndex = 3;
            this.elapsedTimeLb.Text = "yyyy/MM/dd HH:mm:ss";
            // 
            // label2
            // 
            this.label2.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(17, 188);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(83, 12);
            this.label2.TabIndex = 3;
            this.label2.Text = "完了予想日時：";
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
            this.groupBox3.Location = new System.Drawing.Point(390, 106);
            this.groupBox3.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.groupBox3.Name = "groupBox3";
            this.groupBox3.Padding = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.groupBox3.Size = new System.Drawing.Size(688, 438);
            this.groupBox3.TabIndex = 4;
            this.groupBox3.TabStop = false;
            this.groupBox3.Text = "ログ";
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
            this.lstLog.Size = new System.Drawing.Size(667, 374);
            this.lstLog.TabIndex = 0;
            // 
            // grpFacilityInfo
            // 
            this.grpFacilityInfo.Controls.Add(this.panelFacilityCdList);
            this.grpFacilityInfo.Controls.Add(this.cmbSeriesCd);
            this.grpFacilityInfo.Controls.Add(this.label5);
            this.grpFacilityInfo.Controls.Add(this.label6);
            this.grpFacilityInfo.Controls.Add(this.txtFacilityCd);
            this.grpFacilityInfo.ForeColor = System.Drawing.Color.White;
            this.grpFacilityInfo.Location = new System.Drawing.Point(19, 2);
            this.grpFacilityInfo.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.grpFacilityInfo.Name = "grpFacilityInfo";
            this.grpFacilityInfo.Padding = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.grpFacilityInfo.Size = new System.Drawing.Size(912, 98);
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
            this.panelFacilityCdList.Location = new System.Drawing.Point(3, 14);
            this.panelFacilityCdList.Name = "panelFacilityCdList";
            this.panelFacilityCdList.Size = new System.Drawing.Size(883, 82);
            this.panelFacilityCdList.TabIndex = 6;
            // 
            // label1
            // 
            this.label1.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(712, 12);
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
            this.label5.Location = new System.Drawing.Point(9, 42);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(120, 12);
            this.label5.TabIndex = 1;
            this.label5.Text = "データ移行先施設コード";
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Location = new System.Drawing.Point(9, 65);
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
            // 
            // checkAutomatic
            // 
            this.checkAutomatic.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.checkAutomatic.AutoSize = true;
            this.checkAutomatic.ForeColor = System.Drawing.SystemColors.ButtonHighlight;
            this.checkAutomatic.Location = new System.Drawing.Point(848, 559);
            this.checkAutomatic.Name = "checkAutomatic";
            this.checkAutomatic.Size = new System.Drawing.Size(124, 16);
            this.checkAutomatic.TabIndex = 30;
            this.checkAutomatic.Text = "出力後に続けて実行";
            this.checkAutomatic.UseVisualStyleBackColor = true;
            this.checkAutomatic.CheckedChanged += new System.EventHandler(this.checkBox1_CheckedChanged);
            // 
            // panel1
            // 
            this.panel1.AutoScroll = true;
            this.panel1.Location = new System.Drawing.Point(6, 43);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(348, 142);
            this.panel1.TabIndex = 6;
            // 
            // ExtendButton
            // 
            this.ExtendButton.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.ExtendButton.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.ExtendButton.FlatAppearance.BorderSize = 2;
            this.ExtendButton.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.ExtendButton.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.ExtendButton.Location = new System.Drawing.Point(948, 32);
            this.ExtendButton.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.ExtendButton.Name = "ExtendButton";
            this.ExtendButton.Size = new System.Drawing.Size(120, 37);
            this.ExtendButton.TabIndex = 6;
            this.ExtendButton.Text = "コンバータによるスケジュール延長管理";
            this.ExtendButton.UseVisualStyleBackColor = false;
            this.ExtendButton.Click += new System.EventHandler(this.ExtendButton_Click);
            // 
            // btnUpload
            // 
            this.btnUpload.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnUpload.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.btnUpload.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnUpload.FlatAppearance.BorderSize = 2;
            this.btnUpload.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnUpload.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.btnUpload.Location = new System.Drawing.Point(634, 559);
            this.btnUpload.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.btnUpload.Name = "btnUpload";
            this.btnUpload.Size = new System.Drawing.Size(100, 37);
            this.btnUpload.TabIndex = 5;
            this.btnUpload.Text = "Uploadと送信管理画面";
            this.btnUpload.UseVisualStyleBackColor = false;
            // 
            // btnConvertAllTable
            // 
            this.btnConvertAllTable.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnConvertAllTable.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.btnConvertAllTable.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnConvertAllTable.FlatAppearance.BorderSize = 2;
            this.btnConvertAllTable.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnConvertAllTable.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.btnConvertAllTable.Image = global::NKSConverter.Properties.Resources.convert;
            this.btnConvertAllTable.Location = new System.Drawing.Point(831, 559);
            this.btnConvertAllTable.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.btnConvertAllTable.Name = "btnConvertAllTable";
            this.btnConvertAllTable.Size = new System.Drawing.Size(100, 37);
            this.btnConvertAllTable.TabIndex = 5;
            this.btnConvertAllTable.Text = " Convert All Table";
            this.btnConvertAllTable.TextImageRelation = System.Windows.Forms.TextImageRelation.ImageBeforeText;
            this.btnConvertAllTable.UseVisualStyleBackColor = false;
            this.btnConvertAllTable.Visible = false;
            // 
            // btnConvert
            // 
            this.btnConvert.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnConvert.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.btnConvert.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnConvert.FlatAppearance.BorderSize = 2;
            this.btnConvert.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnConvert.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.btnConvert.Image = global::NKSConverter.Properties.Resources.convert;
            this.btnConvert.Location = new System.Drawing.Point(978, 559);
            this.btnConvert.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.btnConvert.Name = "btnConvert";
            this.btnConvert.Size = new System.Drawing.Size(100, 37);
            this.btnConvert.TabIndex = 5;
            this.btnConvert.Text = "  実行";
            this.btnConvert.TextImageRelation = System.Windows.Forms.TextImageRelation.ImageBeforeText;
            this.btnConvert.UseVisualStyleBackColor = false;
            // 
            // btnSetting
            // 
            this.btnSetting.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.btnSetting.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.btnSetting.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnSetting.FlatAppearance.BorderSize = 2;
            this.btnSetting.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnSetting.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.btnSetting.Image = ((System.Drawing.Image)(resources.GetObject("btnSetting.Image")));
            this.btnSetting.Location = new System.Drawing.Point(12, 559);
            this.btnSetting.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.btnSetting.Name = "btnSetting";
            this.btnSetting.Size = new System.Drawing.Size(100, 37);
            this.btnSetting.TabIndex = 5;
            this.btnSetting.Text = "  設定";
            this.btnSetting.TextImageRelation = System.Windows.Forms.TextImageRelation.ImageBeforeText;
            this.btnSetting.UseVisualStyleBackColor = false;
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
            this.updateProgressBarBtn.Location = new System.Drawing.Point(274, 16);
            this.updateProgressBarBtn.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.updateProgressBarBtn.Name = "updateProgressBarBtn";
            this.updateProgressBarBtn.Size = new System.Drawing.Size(80, 28);
            this.updateProgressBarBtn.TabIndex = 5;
            this.updateProgressBarBtn.Text = "  更新";
            this.updateProgressBarBtn.TextImageRelation = System.Windows.Forms.TextImageRelation.ImageBeforeText;
            this.updateProgressBarBtn.UseVisualStyleBackColor = false;
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
            this.updateLogBtn.Location = new System.Drawing.Point(597, 18);
            this.updateLogBtn.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.updateLogBtn.Name = "updateLogBtn";
            this.updateLogBtn.Size = new System.Drawing.Size(80, 28);
            this.updateLogBtn.TabIndex = 7;
            this.updateLogBtn.Text = "  更新";
            this.updateLogBtn.TextImageRelation = System.Windows.Forms.TextImageRelation.ImageBeforeText;
            this.updateLogBtn.UseVisualStyleBackColor = false;
            // 
            // convertInfoUpdatebtn
            // 
            this.convertInfoUpdatebtn.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.convertInfoUpdatebtn.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.convertInfoUpdatebtn.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.convertInfoUpdatebtn.FlatAppearance.BorderSize = 2;
            this.convertInfoUpdatebtn.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.convertInfoUpdatebtn.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.convertInfoUpdatebtn.Image = ((System.Drawing.Image)(resources.GetObject("convertInfoUpdatebtn.Image")));
            this.convertInfoUpdatebtn.Location = new System.Drawing.Point(274, 18);
            this.convertInfoUpdatebtn.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.convertInfoUpdatebtn.Name = "convertInfoUpdatebtn";
            this.convertInfoUpdatebtn.Size = new System.Drawing.Size(80, 28);
            this.convertInfoUpdatebtn.TabIndex = 5;
            this.convertInfoUpdatebtn.Text = "  更新";
            this.convertInfoUpdatebtn.TextImageRelation = System.Windows.Forms.TextImageRelation.ImageBeforeText;
            this.convertInfoUpdatebtn.UseVisualStyleBackColor = false;
            // 
            // ConvertForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.ClientSize = new System.Drawing.Size(1090, 610);
            this.Controls.Add(this.checkAutomatic);
            this.Controls.Add(this.grpFacilityInfo);
            this.Controls.Add(this.ExtendButton);
            this.Controls.Add(this.btnUpload);
            this.Controls.Add(this.btnConvertAllTable);
            this.Controls.Add(this.btnConvert);
            this.Controls.Add(this.btnSetting);
            this.Controls.Add(this.groupBox2);
            this.Controls.Add(this.groupBox3);
            this.Controls.Add(this.groupBox1);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.Name = "ConvertForm";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "FNW ->FNSiコンバータ";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.ConvertForm_FormClosing);
            this.groupBox1.ResumeLayout(false);
            this.groupBox2.ResumeLayout(false);
            this.groupBox2.PerformLayout();
            this.groupBox3.ResumeLayout(false);
            this.grpFacilityInfo.ResumeLayout(false);
            this.grpFacilityInfo.PerformLayout();
            this.panelFacilityCdList.ResumeLayout(false);
            this.panelFacilityCdList.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

    }

    #endregion
    private System.Windows.Forms.GroupBox groupBox1;
    private System.Windows.Forms.ListBox lstStatus;
    private RoundedButton convertInfoUpdatebtn;
    private System.Windows.Forms.GroupBox groupBox2;
    private System.Windows.Forms.Label elapsedTimeLb;
    private RoundedButton updateProgressBarBtn;
    private System.Windows.Forms.Label label2;
    private System.Windows.Forms.RadioButton FNSi_Status;
    private System.Windows.Forms.RadioButton FNW_Status;
    private System.Windows.Forms.GroupBox groupBox3;
    private System.Windows.Forms.ListBox lstLog;
    private RoundedButton btnSetting;
    private RoundedButton btnConvert;
    private RoundedButton btnUpload;
    private RoundedButton btnConvertAllTable;
    private System.Windows.Forms.GroupBox grpFacilityInfo;
    private System.Windows.Forms.ComboBox cmbSeriesCd;
    private System.Windows.Forms.Label label5;
    private System.Windows.Forms.Label label6;
    private System.Windows.Forms.TextBox txtFacilityCd;
        private RoundedButton updateLogBtn;
        private System.Windows.Forms.Panel panelFacilityCdList;
        private RoundedButton ExtendButton;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.CheckBox checkAutomatic;
        private System.Windows.Forms.Panel panel1;
    }
}
