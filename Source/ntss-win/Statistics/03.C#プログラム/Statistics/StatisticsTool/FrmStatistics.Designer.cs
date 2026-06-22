namespace Fnw.StatisticsTool
{
    partial class FrmStatistics
    {
        /// <summary>
        /// 必要なデザイナ変数です。
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// 使用中のリソースをすべてクリーンアップします。
        /// </summary>
        /// <param name="disposing">マネージ リソースが破棄される場合 true、破棄されない場合は false です。</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows フォーム デザイナで生成されたコード

        /// <summary>
        /// デザイナ サポートに必要なメソッドです。このメソッドの内容を
        /// コード エディタで変更しないでください。
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FrmStatistics));
            this.lblFacilityName = new System.Windows.Forms.Label();
            this.txtFacilityCode = new System.Windows.Forms.TextBox();
            this.btnPatMatch = new System.Windows.Forms.Button();
            this.lstLog = new System.Windows.Forms.ListBox();
            this.btnExtract = new System.Windows.Forms.Button();
            this.lblStatusMassage = new System.Windows.Forms.Label();
            this.btnMstDiseaseMatch = new System.Windows.Forms.Button();
            this.btnMstTreatItemMatch = new System.Windows.Forms.Button();
            this.btnMstDieMatch = new System.Windows.Forms.Button();
            this.lblExtractTimestamp = new System.Windows.Forms.Label();
            this.btnMstFacilityMatch = new System.Windows.Forms.Button();
            this.lblExtractStatus = new System.Windows.Forms.Label();
            this.btnMstExamItemMatch = new System.Windows.Forms.Button();
            this.lblCustomizeTimestamp = new System.Windows.Forms.Label();
            this.btnDiabetesSelect = new System.Windows.Forms.Button();
            this.lblCustomizeStatus = new System.Windows.Forms.Label();
            this.lblDiabetesTimestamp = new System.Windows.Forms.Label();
            this.btnExcelImport = new System.Windows.Forms.Button();
            this.lblDiabetesStatus = new System.Windows.Forms.Label();
            this.btnCustomize = new System.Windows.Forms.Button();
            this.lblExamItemTimestamp = new System.Windows.Forms.Label();
            this.lblExcelImportStatus = new System.Windows.Forms.Label();
            this.lblExamItemStatus = new System.Windows.Forms.Label();
            this.lblExcelImportTimestamp = new System.Windows.Forms.Label();
            this.lblFacilityTimestamp = new System.Windows.Forms.Label();
            this.lblPatMatchStatus = new System.Windows.Forms.Label();
            this.lblFacilityStatus = new System.Windows.Forms.Label();
            this.lblPatMatchTimestamp = new System.Windows.Forms.Label();
            this.lblDieTimestamp = new System.Windows.Forms.Label();
            this.lblDiseaseStatus = new System.Windows.Forms.Label();
            this.lblDieStatus = new System.Windows.Forms.Label();
            this.lblDiseaseTimestamp = new System.Windows.Forms.Label();
            this.lblTreatItemTimestamp = new System.Windows.Forms.Label();
            this.lblTreatItemStatus = new System.Windows.Forms.Label();
            this.btnMstInfectionMatch = new System.Windows.Forms.Button();
            this.lblInfectionTimestamp = new System.Windows.Forms.Label();
            this.lblInfectionStatus = new System.Windows.Forms.Label();
            this.dirExportDirectory = new System.Windows.Forms.FolderBrowserDialog();
            this.btnMstVaMatch = new System.Windows.Forms.Button();
            this.lblVaTimestamp = new System.Windows.Forms.Label();
            this.lblVaStatus = new System.Windows.Forms.Label();
            this.SuspendLayout();
            // 
            // lblFacilityName
            // 
            this.lblFacilityName.AutoSize = true;
            this.lblFacilityName.Location = new System.Drawing.Point(149, 15);
            this.lblFacilityName.Name = "lblFacilityName";
            this.lblFacilityName.Size = new System.Drawing.Size(53, 12);
            this.lblFacilityName.TabIndex = 53;
            this.lblFacilityName.Text = "施設名称";
            // 
            // txtFacilityCode
            // 
            this.txtFacilityCode.Enabled = false;
            this.txtFacilityCode.ImeMode = System.Windows.Forms.ImeMode.Disable;
            this.txtFacilityCode.Location = new System.Drawing.Point(12, 12);
            this.txtFacilityCode.MaxLength = 20;
            this.txtFacilityCode.Name = "txtFacilityCode";
            this.txtFacilityCode.ReadOnly = true;
            this.txtFacilityCode.Size = new System.Drawing.Size(131, 19);
            this.txtFacilityCode.TabIndex = 0;
            // 
            // btnPatMatch
            // 
            this.btnPatMatch.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.btnPatMatch.Location = new System.Drawing.Point(10, 76);
            this.btnPatMatch.Name = "btnPatMatch";
            this.btnPatMatch.Size = new System.Drawing.Size(276, 23);
            this.btnPatMatch.TabIndex = 2;
            this.btnPatMatch.Text = "患者設定";
            this.btnPatMatch.UseVisualStyleBackColor = true;
            this.btnPatMatch.Click += new System.EventHandler(this.btnPatMatch_Click);
            // 
            // lstLog
            // 
            this.lstLog.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lstLog.FormattingEnabled = true;
            this.lstLog.ItemHeight = 12;
            this.lstLog.Location = new System.Drawing.Point(9, 415);
            this.lstLog.Name = "lstLog";
            this.lstLog.Size = new System.Drawing.Size(471, 244);
            this.lstLog.TabIndex = 50;
            this.lstLog.TabStop = false;
            // 
            // btnExtract
            // 
            this.btnExtract.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.btnExtract.Location = new System.Drawing.Point(9, 366);
            this.btnExtract.Name = "btnExtract";
            this.btnExtract.Size = new System.Drawing.Size(276, 23);
            this.btnExtract.TabIndex = 14;
            this.btnExtract.Text = "抽出";
            this.btnExtract.UseVisualStyleBackColor = true;
            this.btnExtract.Click += new System.EventHandler(this.btnExtract_Click);
            // 
            // lblStatusMassage
            // 
            this.lblStatusMassage.AutoSize = true;
            this.lblStatusMassage.Location = new System.Drawing.Point(12, 400);
            this.lblStatusMassage.Name = "lblStatusMassage";
            this.lblStatusMassage.Size = new System.Drawing.Size(388, 12);
            this.lblStatusMassage.TabIndex = 49;
            this.lblStatusMassage.Text = "抽出を行うには登録済み患者一覧作成～抽出設定まで完了する必要があります";
            // 
            // btnMstDiseaseMatch
            // 
            this.btnMstDiseaseMatch.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.btnMstDiseaseMatch.Location = new System.Drawing.Point(10, 105);
            this.btnMstDiseaseMatch.Name = "btnMstDiseaseMatch";
            this.btnMstDiseaseMatch.Size = new System.Drawing.Size(276, 23);
            this.btnMstDiseaseMatch.TabIndex = 4;
            this.btnMstDiseaseMatch.Text = "原疾患設定";
            this.btnMstDiseaseMatch.UseVisualStyleBackColor = true;
            this.btnMstDiseaseMatch.Click += new System.EventHandler(this.btnMstDiseaseMatch_Click);
            // 
            // btnMstTreatItemMatch
            // 
            this.btnMstTreatItemMatch.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.btnMstTreatItemMatch.Location = new System.Drawing.Point(10, 134);
            this.btnMstTreatItemMatch.Name = "btnMstTreatItemMatch";
            this.btnMstTreatItemMatch.Size = new System.Drawing.Size(276, 23);
            this.btnMstTreatItemMatch.TabIndex = 5;
            this.btnMstTreatItemMatch.Text = "治療方法設定";
            this.btnMstTreatItemMatch.UseVisualStyleBackColor = true;
            this.btnMstTreatItemMatch.Click += new System.EventHandler(this.btnMstTreatItemMatch_Click);
            // 
            // btnMstDieMatch
            // 
            this.btnMstDieMatch.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.btnMstDieMatch.Location = new System.Drawing.Point(10, 163);
            this.btnMstDieMatch.Name = "btnMstDieMatch";
            this.btnMstDieMatch.Size = new System.Drawing.Size(276, 23);
            this.btnMstDieMatch.TabIndex = 6;
            this.btnMstDieMatch.Text = "死因設定";
            this.btnMstDieMatch.UseVisualStyleBackColor = true;
            this.btnMstDieMatch.Click += new System.EventHandler(this.btnMstDieMatch_Click);
            // 
            // lblExtractTimestamp
            // 
            this.lblExtractTimestamp.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lblExtractTimestamp.AutoSize = true;
            this.lblExtractTimestamp.Location = new System.Drawing.Point(346, 371);
            this.lblExtractTimestamp.Name = "lblExtractTimestamp";
            this.lblExtractTimestamp.Size = new System.Drawing.Size(117, 12);
            this.lblExtractTimestamp.TabIndex = 44;
            this.lblExtractTimestamp.Text = "yyyy.Mm.dd HH:mm:ss";
            // 
            // btnMstFacilityMatch
            // 
            this.btnMstFacilityMatch.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.btnMstFacilityMatch.Location = new System.Drawing.Point(10, 192);
            this.btnMstFacilityMatch.Name = "btnMstFacilityMatch";
            this.btnMstFacilityMatch.Size = new System.Drawing.Size(276, 23);
            this.btnMstFacilityMatch.TabIndex = 7;
            this.btnMstFacilityMatch.Text = "施設設定";
            this.btnMstFacilityMatch.UseVisualStyleBackColor = true;
            this.btnMstFacilityMatch.Click += new System.EventHandler(this.btnMstFacilityMatch_Click);
            // 
            // lblExtractStatus
            // 
            this.lblExtractStatus.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lblExtractStatus.AutoSize = true;
            this.lblExtractStatus.Location = new System.Drawing.Point(299, 371);
            this.lblExtractStatus.Name = "lblExtractStatus";
            this.lblExtractStatus.Size = new System.Drawing.Size(41, 12);
            this.lblExtractStatus.TabIndex = 43;
            this.lblExtractStatus.Text = "未完了";
            // 
            // btnMstExamItemMatch
            // 
            this.btnMstExamItemMatch.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.btnMstExamItemMatch.Location = new System.Drawing.Point(10, 221);
            this.btnMstExamItemMatch.Name = "btnMstExamItemMatch";
            this.btnMstExamItemMatch.Size = new System.Drawing.Size(276, 23);
            this.btnMstExamItemMatch.TabIndex = 8;
            this.btnMstExamItemMatch.Text = "検査項目設定";
            this.btnMstExamItemMatch.UseVisualStyleBackColor = true;
            this.btnMstExamItemMatch.Click += new System.EventHandler(this.btnMstExamItemMatch_Click);
            // 
            // lblCustomizeTimestamp
            // 
            this.lblCustomizeTimestamp.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lblCustomizeTimestamp.AutoSize = true;
            this.lblCustomizeTimestamp.Location = new System.Drawing.Point(346, 342);
            this.lblCustomizeTimestamp.Name = "lblCustomizeTimestamp";
            this.lblCustomizeTimestamp.Size = new System.Drawing.Size(117, 12);
            this.lblCustomizeTimestamp.TabIndex = 38;
            this.lblCustomizeTimestamp.Text = "yyyy.Mm.dd HH:mm:ss";
            // 
            // btnDiabetesSelect
            // 
            this.btnDiabetesSelect.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.btnDiabetesSelect.Location = new System.Drawing.Point(10, 250);
            this.btnDiabetesSelect.Name = "btnDiabetesSelect";
            this.btnDiabetesSelect.Size = new System.Drawing.Size(276, 23);
            this.btnDiabetesSelect.TabIndex = 10;
            this.btnDiabetesSelect.Text = "糖尿病設定";
            this.btnDiabetesSelect.UseVisualStyleBackColor = true;
            this.btnDiabetesSelect.Click += new System.EventHandler(this.btnDiabetesSelect_Click);
            // 
            // lblCustomizeStatus
            // 
            this.lblCustomizeStatus.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lblCustomizeStatus.AutoSize = true;
            this.lblCustomizeStatus.Location = new System.Drawing.Point(299, 342);
            this.lblCustomizeStatus.Name = "lblCustomizeStatus";
            this.lblCustomizeStatus.Size = new System.Drawing.Size(41, 12);
            this.lblCustomizeStatus.TabIndex = 37;
            this.lblCustomizeStatus.Text = "未完了";
            // 
            // lblDiabetesTimestamp
            // 
            this.lblDiabetesTimestamp.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lblDiabetesTimestamp.AutoSize = true;
            this.lblDiabetesTimestamp.Location = new System.Drawing.Point(346, 255);
            this.lblDiabetesTimestamp.Name = "lblDiabetesTimestamp";
            this.lblDiabetesTimestamp.Size = new System.Drawing.Size(117, 12);
            this.lblDiabetesTimestamp.TabIndex = 35;
            this.lblDiabetesTimestamp.Text = "yyyy.Mm.dd HH:mm:ss";
            // 
            // btnExcelImport
            // 
            this.btnExcelImport.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.btnExcelImport.Location = new System.Drawing.Point(10, 47);
            this.btnExcelImport.Name = "btnExcelImport";
            this.btnExcelImport.Size = new System.Drawing.Size(276, 23);
            this.btnExcelImport.TabIndex = 1;
            this.btnExcelImport.Text = "登録済み患者一覧作成";
            this.btnExcelImport.UseVisualStyleBackColor = true;
            this.btnExcelImport.Click += new System.EventHandler(this.btnExcelImport_Click);
            // 
            // lblDiabetesStatus
            // 
            this.lblDiabetesStatus.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lblDiabetesStatus.AutoSize = true;
            this.lblDiabetesStatus.Location = new System.Drawing.Point(299, 255);
            this.lblDiabetesStatus.Name = "lblDiabetesStatus";
            this.lblDiabetesStatus.Size = new System.Drawing.Size(41, 12);
            this.lblDiabetesStatus.TabIndex = 34;
            this.lblDiabetesStatus.Text = "未完了";
            // 
            // btnCustomize
            // 
            this.btnCustomize.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.btnCustomize.Location = new System.Drawing.Point(9, 337);
            this.btnCustomize.Name = "btnCustomize";
            this.btnCustomize.Size = new System.Drawing.Size(276, 23);
            this.btnCustomize.TabIndex = 13;
            this.btnCustomize.Text = "抽出設定";
            this.btnCustomize.UseVisualStyleBackColor = true;
            this.btnCustomize.Click += new System.EventHandler(this.btnCustomize_Click);
            // 
            // lblExamItemTimestamp
            // 
            this.lblExamItemTimestamp.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lblExamItemTimestamp.AutoSize = true;
            this.lblExamItemTimestamp.Location = new System.Drawing.Point(346, 226);
            this.lblExamItemTimestamp.Name = "lblExamItemTimestamp";
            this.lblExamItemTimestamp.Size = new System.Drawing.Size(117, 12);
            this.lblExamItemTimestamp.TabIndex = 23;
            this.lblExamItemTimestamp.Text = "yyyy.Mm.dd HH:mm:ss";
            // 
            // lblExcelImportStatus
            // 
            this.lblExcelImportStatus.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lblExcelImportStatus.AutoSize = true;
            this.lblExcelImportStatus.Location = new System.Drawing.Point(299, 52);
            this.lblExcelImportStatus.Name = "lblExcelImportStatus";
            this.lblExcelImportStatus.Size = new System.Drawing.Size(41, 12);
            this.lblExcelImportStatus.TabIndex = 4;
            this.lblExcelImportStatus.Text = "未完了";
            // 
            // lblExamItemStatus
            // 
            this.lblExamItemStatus.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lblExamItemStatus.AutoSize = true;
            this.lblExamItemStatus.Location = new System.Drawing.Point(299, 226);
            this.lblExamItemStatus.Name = "lblExamItemStatus";
            this.lblExamItemStatus.Size = new System.Drawing.Size(41, 12);
            this.lblExamItemStatus.TabIndex = 22;
            this.lblExamItemStatus.Text = "未完了";
            // 
            // lblExcelImportTimestamp
            // 
            this.lblExcelImportTimestamp.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lblExcelImportTimestamp.AutoSize = true;
            this.lblExcelImportTimestamp.Location = new System.Drawing.Point(346, 52);
            this.lblExcelImportTimestamp.Name = "lblExcelImportTimestamp";
            this.lblExcelImportTimestamp.Size = new System.Drawing.Size(117, 12);
            this.lblExcelImportTimestamp.TabIndex = 5;
            this.lblExcelImportTimestamp.Text = "yyyy.Mm.dd HH:mm:ss";
            // 
            // lblFacilityTimestamp
            // 
            this.lblFacilityTimestamp.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lblFacilityTimestamp.AutoSize = true;
            this.lblFacilityTimestamp.Location = new System.Drawing.Point(346, 197);
            this.lblFacilityTimestamp.Name = "lblFacilityTimestamp";
            this.lblFacilityTimestamp.Size = new System.Drawing.Size(117, 12);
            this.lblFacilityTimestamp.TabIndex = 20;
            this.lblFacilityTimestamp.Text = "yyyy.Mm.dd HH:mm:ss";
            // 
            // lblPatMatchStatus
            // 
            this.lblPatMatchStatus.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lblPatMatchStatus.AutoSize = true;
            this.lblPatMatchStatus.Location = new System.Drawing.Point(299, 81);
            this.lblPatMatchStatus.Name = "lblPatMatchStatus";
            this.lblPatMatchStatus.Size = new System.Drawing.Size(41, 12);
            this.lblPatMatchStatus.TabIndex = 7;
            this.lblPatMatchStatus.Text = "未完了";
            // 
            // lblFacilityStatus
            // 
            this.lblFacilityStatus.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lblFacilityStatus.AutoSize = true;
            this.lblFacilityStatus.Location = new System.Drawing.Point(299, 197);
            this.lblFacilityStatus.Name = "lblFacilityStatus";
            this.lblFacilityStatus.Size = new System.Drawing.Size(41, 12);
            this.lblFacilityStatus.TabIndex = 19;
            this.lblFacilityStatus.Text = "未完了";
            // 
            // lblPatMatchTimestamp
            // 
            this.lblPatMatchTimestamp.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lblPatMatchTimestamp.AutoSize = true;
            this.lblPatMatchTimestamp.Location = new System.Drawing.Point(346, 81);
            this.lblPatMatchTimestamp.Name = "lblPatMatchTimestamp";
            this.lblPatMatchTimestamp.Size = new System.Drawing.Size(117, 12);
            this.lblPatMatchTimestamp.TabIndex = 8;
            this.lblPatMatchTimestamp.Text = "yyyy.Mm.dd HH:mm:ss";
            // 
            // lblDieTimestamp
            // 
            this.lblDieTimestamp.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lblDieTimestamp.AutoSize = true;
            this.lblDieTimestamp.Location = new System.Drawing.Point(346, 168);
            this.lblDieTimestamp.Name = "lblDieTimestamp";
            this.lblDieTimestamp.Size = new System.Drawing.Size(117, 12);
            this.lblDieTimestamp.TabIndex = 17;
            this.lblDieTimestamp.Text = "yyyy.Mm.dd HH:mm:ss";
            // 
            // lblDiseaseStatus
            // 
            this.lblDiseaseStatus.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lblDiseaseStatus.AutoSize = true;
            this.lblDiseaseStatus.Location = new System.Drawing.Point(299, 110);
            this.lblDiseaseStatus.Name = "lblDiseaseStatus";
            this.lblDiseaseStatus.Size = new System.Drawing.Size(41, 12);
            this.lblDiseaseStatus.TabIndex = 10;
            this.lblDiseaseStatus.Text = "未完了";
            // 
            // lblDieStatus
            // 
            this.lblDieStatus.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lblDieStatus.AutoSize = true;
            this.lblDieStatus.Location = new System.Drawing.Point(299, 168);
            this.lblDieStatus.Name = "lblDieStatus";
            this.lblDieStatus.Size = new System.Drawing.Size(41, 12);
            this.lblDieStatus.TabIndex = 16;
            this.lblDieStatus.Text = "未完了";
            // 
            // lblDiseaseTimestamp
            // 
            this.lblDiseaseTimestamp.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lblDiseaseTimestamp.AutoSize = true;
            this.lblDiseaseTimestamp.Location = new System.Drawing.Point(346, 110);
            this.lblDiseaseTimestamp.Name = "lblDiseaseTimestamp";
            this.lblDiseaseTimestamp.Size = new System.Drawing.Size(117, 12);
            this.lblDiseaseTimestamp.TabIndex = 11;
            this.lblDiseaseTimestamp.Text = "yyyy.Mm.dd HH:mm:ss";
            // 
            // lblTreatItemTimestamp
            // 
            this.lblTreatItemTimestamp.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lblTreatItemTimestamp.AutoSize = true;
            this.lblTreatItemTimestamp.Location = new System.Drawing.Point(346, 139);
            this.lblTreatItemTimestamp.Name = "lblTreatItemTimestamp";
            this.lblTreatItemTimestamp.Size = new System.Drawing.Size(117, 12);
            this.lblTreatItemTimestamp.TabIndex = 14;
            this.lblTreatItemTimestamp.Text = "yyyy.Mm.dd HH:mm:ss";
            // 
            // lblTreatItemStatus
            // 
            this.lblTreatItemStatus.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lblTreatItemStatus.AutoSize = true;
            this.lblTreatItemStatus.Location = new System.Drawing.Point(299, 139);
            this.lblTreatItemStatus.Name = "lblTreatItemStatus";
            this.lblTreatItemStatus.Size = new System.Drawing.Size(41, 12);
            this.lblTreatItemStatus.TabIndex = 13;
            this.lblTreatItemStatus.Text = "未完了";
            // 
            // btnMstInfectionMatch
            // 
            this.btnMstInfectionMatch.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.btnMstInfectionMatch.Location = new System.Drawing.Point(10, 279);
            this.btnMstInfectionMatch.Name = "btnMstInfectionMatch";
            this.btnMstInfectionMatch.Size = new System.Drawing.Size(276, 23);
            this.btnMstInfectionMatch.TabIndex = 11;
            this.btnMstInfectionMatch.Text = "感染症設定";
            this.btnMstInfectionMatch.UseVisualStyleBackColor = true;
            this.btnMstInfectionMatch.Click += new System.EventHandler(this.btnMstInfectionMatch_Click);
            // 
            // lblInfectionTimestamp
            // 
            this.lblInfectionTimestamp.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lblInfectionTimestamp.AutoSize = true;
            this.lblInfectionTimestamp.Location = new System.Drawing.Point(346, 284);
            this.lblInfectionTimestamp.Name = "lblInfectionTimestamp";
            this.lblInfectionTimestamp.Size = new System.Drawing.Size(117, 12);
            this.lblInfectionTimestamp.TabIndex = 56;
            this.lblInfectionTimestamp.Text = "yyyy.Mm.dd HH:mm:ss";
            // 
            // lblInfectionStatus
            // 
            this.lblInfectionStatus.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lblInfectionStatus.AutoSize = true;
            this.lblInfectionStatus.Location = new System.Drawing.Point(299, 284);
            this.lblInfectionStatus.Name = "lblInfectionStatus";
            this.lblInfectionStatus.Size = new System.Drawing.Size(41, 12);
            this.lblInfectionStatus.TabIndex = 55;
            this.lblInfectionStatus.Text = "未完了";
            // 
            // btnMstVaMatch
            // 
            this.btnMstVaMatch.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.btnMstVaMatch.Location = new System.Drawing.Point(9, 308);
            this.btnMstVaMatch.Name = "btnMstVaMatch";
            this.btnMstVaMatch.Size = new System.Drawing.Size(276, 23);
            this.btnMstVaMatch.TabIndex = 12;
            this.btnMstVaMatch.Text = "バスキュラーアクセス設定";
            this.btnMstVaMatch.UseVisualStyleBackColor = true;
            this.btnMstVaMatch.Click += new System.EventHandler(this.btnMstVaMatch_Click);
            // 
            // lblVaTimestamp
            // 
            this.lblVaTimestamp.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lblVaTimestamp.AutoSize = true;
            this.lblVaTimestamp.Location = new System.Drawing.Point(346, 313);
            this.lblVaTimestamp.Name = "lblVaTimestamp";
            this.lblVaTimestamp.Size = new System.Drawing.Size(117, 12);
            this.lblVaTimestamp.TabIndex = 59;
            this.lblVaTimestamp.Text = "yyyy.Mm.dd HH:mm:ss";
            // 
            // lblVaStatus
            // 
            this.lblVaStatus.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lblVaStatus.AutoSize = true;
            this.lblVaStatus.Location = new System.Drawing.Point(299, 313);
            this.lblVaStatus.Name = "lblVaStatus";
            this.lblVaStatus.Size = new System.Drawing.Size(41, 12);
            this.lblVaStatus.TabIndex = 58;
            this.lblVaStatus.Text = "未完了";
            // 
            // FrmStatistics
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(492, 671);
            this.Controls.Add(this.btnMstVaMatch);
            this.Controls.Add(this.lblVaTimestamp);
            this.Controls.Add(this.lblVaStatus);
            this.Controls.Add(this.btnMstInfectionMatch);
            this.Controls.Add(this.lblInfectionTimestamp);
            this.Controls.Add(this.lblInfectionStatus);
            this.Controls.Add(this.lblFacilityName);
            this.Controls.Add(this.txtFacilityCode);
            this.Controls.Add(this.btnPatMatch);
            this.Controls.Add(this.lstLog);
            this.Controls.Add(this.btnExtract);
            this.Controls.Add(this.lblStatusMassage);
            this.Controls.Add(this.btnMstDiseaseMatch);
            this.Controls.Add(this.btnMstTreatItemMatch);
            this.Controls.Add(this.btnMstDieMatch);
            this.Controls.Add(this.lblExtractTimestamp);
            this.Controls.Add(this.btnMstFacilityMatch);
            this.Controls.Add(this.lblExtractStatus);
            this.Controls.Add(this.btnMstExamItemMatch);
            this.Controls.Add(this.lblCustomizeTimestamp);
            this.Controls.Add(this.btnDiabetesSelect);
            this.Controls.Add(this.lblCustomizeStatus);
            this.Controls.Add(this.lblDiabetesTimestamp);
            this.Controls.Add(this.btnExcelImport);
            this.Controls.Add(this.lblDiabetesStatus);
            this.Controls.Add(this.btnCustomize);
            this.Controls.Add(this.lblExamItemTimestamp);
            this.Controls.Add(this.lblExcelImportStatus);
            this.Controls.Add(this.lblExamItemStatus);
            this.Controls.Add(this.lblExcelImportTimestamp);
            this.Controls.Add(this.lblFacilityTimestamp);
            this.Controls.Add(this.lblPatMatchStatus);
            this.Controls.Add(this.lblFacilityStatus);
            this.Controls.Add(this.lblPatMatchTimestamp);
            this.Controls.Add(this.lblDieTimestamp);
            this.Controls.Add(this.lblDiseaseStatus);
            this.Controls.Add(this.lblDieStatus);
            this.Controls.Add(this.lblDiseaseTimestamp);
            this.Controls.Add(this.lblTreatItemTimestamp);
            this.Controls.Add(this.lblTreatItemStatus);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.KeyPreview = true;
            this.Name = "FrmStatistics";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "統計調査_2025年度版";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.FrmStatistics_FormClosing);
            this.Load += new System.EventHandler(this.FrmStatistics_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion
        private System.Windows.Forms.Label lblStatusMassage;
        private System.Windows.Forms.Label lblExtractTimestamp;
        private System.Windows.Forms.Label lblExtractStatus;
        private System.Windows.Forms.Label lblCustomizeTimestamp;
        private System.Windows.Forms.Label lblCustomizeStatus;
        private System.Windows.Forms.Label lblDiabetesTimestamp;
        private System.Windows.Forms.Label lblDiabetesStatus;
        private System.Windows.Forms.Label lblExamItemTimestamp;
        private System.Windows.Forms.Label lblExamItemStatus;
        private System.Windows.Forms.Label lblFacilityTimestamp;
        private System.Windows.Forms.Label lblFacilityStatus;
        private System.Windows.Forms.Label lblDieTimestamp;
        private System.Windows.Forms.Label lblDieStatus;
        private System.Windows.Forms.Label lblTreatItemTimestamp;
        private System.Windows.Forms.Label lblTreatItemStatus;
        private System.Windows.Forms.Label lblDiseaseTimestamp;
        private System.Windows.Forms.Label lblDiseaseStatus;
        private System.Windows.Forms.Label lblPatMatchTimestamp;
        private System.Windows.Forms.Label lblPatMatchStatus;
        private System.Windows.Forms.Label lblExcelImportTimestamp;
        private System.Windows.Forms.Label lblExcelImportStatus;
        private System.Windows.Forms.Button btnCustomize;
        private System.Windows.Forms.Button btnExcelImport;
        private System.Windows.Forms.Button btnDiabetesSelect;
        private System.Windows.Forms.Button btnMstExamItemMatch;
        private System.Windows.Forms.Button btnMstFacilityMatch;
        private System.Windows.Forms.Button btnMstDieMatch;
        private System.Windows.Forms.Button btnMstTreatItemMatch;
        private System.Windows.Forms.Button btnMstDiseaseMatch;
        private System.Windows.Forms.Button btnExtract;
        private System.Windows.Forms.Button btnPatMatch;
        private System.Windows.Forms.Label lblFacilityName;
        private System.Windows.Forms.TextBox txtFacilityCode;
        private System.Windows.Forms.ListBox lstLog;
        private System.Windows.Forms.Button btnMstInfectionMatch;
        private System.Windows.Forms.Label lblInfectionTimestamp;
        private System.Windows.Forms.Label lblInfectionStatus;
        private System.Windows.Forms.FolderBrowserDialog dirExportDirectory;
        private System.Windows.Forms.Button btnMstVaMatch;
        private System.Windows.Forms.Label lblVaTimestamp;
        private System.Windows.Forms.Label lblVaStatus;
    }
}

