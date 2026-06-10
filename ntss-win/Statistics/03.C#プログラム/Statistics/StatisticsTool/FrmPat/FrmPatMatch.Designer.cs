namespace Fnw.StatisticsTool.FrmPat
{
    partial class FrmPatMatch
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
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle1 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle2 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle3 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle4 = new System.Windows.Forms.DataGridViewCellStyle();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FrmPatMatch));
            this.grdPatList = new System.Windows.Forms.DataGridView();
            this.MedicalSequence = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.MedicalName = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.MedicalSex = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.MedicalBirthday = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.SelectPat = new System.Windows.Forms.DataGridViewButtonColumn();
            this.Status = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.DBPatID = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.DBDispPatID = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.DBName = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.DBSex = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.DBBirthday = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.IsPdPat = new System.Windows.Forms.DataGridViewCheckBoxColumn();
            this.lblPatSelect = new System.Windows.Forms.Label();
            this.btnOK = new System.Windows.Forms.Button();
            this.btnCancel = new System.Windows.Forms.Button();
            ((System.ComponentModel.ISupportInitialize)(this.grdPatList)).BeginInit();
            this.SuspendLayout();
            // 
            // grdPatList
            // 
            this.grdPatList.AllowUserToAddRows = false;
            this.grdPatList.AllowUserToDeleteRows = false;
            this.grdPatList.AllowUserToResizeRows = false;
            this.grdPatList.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.grdPatList.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.grdPatList.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.MedicalSequence,
            this.MedicalName,
            this.MedicalSex,
            this.MedicalBirthday,
            this.SelectPat,
            this.Status,
            this.DBPatID,
            this.DBDispPatID,
            this.DBName,
            this.DBSex,
            this.DBBirthday,
            this.IsPdPat});
            this.grdPatList.Location = new System.Drawing.Point(12, 35);
            this.grdPatList.MultiSelect = false;
            this.grdPatList.Name = "grdPatList";
            this.grdPatList.RowHeadersVisible = false;
            this.grdPatList.RowTemplate.Height = 21;
            this.grdPatList.Size = new System.Drawing.Size(924, 359);
            this.grdPatList.TabIndex = 0;
            this.grdPatList.CellClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.grdPatList_CellClick);
            this.grdPatList.CellDoubleClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.grdPatList_CellDoubleClick);
            this.grdPatList.DataBindingComplete += new System.Windows.Forms.DataGridViewBindingCompleteEventHandler(this.grdPatList_DataBindingComplete);
            // 
            // MedicalSequence
            // 
            this.MedicalSequence.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.AllCells;
            this.MedicalSequence.DataPropertyName = "MEDICAL_SEQUENCE";
            dataGridViewCellStyle1.BackColor = System.Drawing.Color.Silver;
            this.MedicalSequence.DefaultCellStyle = dataGridViewCellStyle1;
            this.MedicalSequence.HeaderText = "医学会SQ番号";
            this.MedicalSequence.MinimumWidth = 110;
            this.MedicalSequence.Name = "MedicalSequence";
            this.MedicalSequence.Visible = false;
            // 
            // MedicalName
            // 
            this.MedicalName.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.AllCells;
            this.MedicalName.DataPropertyName = "MEDICAL_NAME";
            dataGridViewCellStyle2.BackColor = System.Drawing.Color.Silver;
            this.MedicalName.DefaultCellStyle = dataGridViewCellStyle2;
            this.MedicalName.HeaderText = "氏名";
            this.MedicalName.MinimumWidth = 54;
            this.MedicalName.Name = "MedicalName";
            this.MedicalName.ToolTipText = "医学会登録済み患者氏名";
            this.MedicalName.Width = 54;
            // 
            // MedicalSex
            // 
            this.MedicalSex.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.AllCells;
            this.MedicalSex.DataPropertyName = "MEDICAL_SEX";
            dataGridViewCellStyle3.BackColor = System.Drawing.Color.Silver;
            this.MedicalSex.DefaultCellStyle = dataGridViewCellStyle3;
            this.MedicalSex.HeaderText = "性別";
            this.MedicalSex.MinimumWidth = 55;
            this.MedicalSex.Name = "MedicalSex";
            this.MedicalSex.ToolTipText = "医学会登録済み患者性別";
            this.MedicalSex.Width = 55;
            // 
            // MedicalBirthday
            // 
            this.MedicalBirthday.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.AllCells;
            this.MedicalBirthday.DataPropertyName = "MEDICAL_BIRTHDAY";
            dataGridViewCellStyle4.BackColor = System.Drawing.Color.Silver;
            this.MedicalBirthday.DefaultCellStyle = dataGridViewCellStyle4;
            this.MedicalBirthday.HeaderText = "生年月日";
            this.MedicalBirthday.MinimumWidth = 80;
            this.MedicalBirthday.Name = "MedicalBirthday";
            this.MedicalBirthday.ToolTipText = "医学会登録済み患者生年月日";
            this.MedicalBirthday.Width = 80;
            // 
            // SelectPat
            // 
            this.SelectPat.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.ColumnHeader;
            this.SelectPat.HeaderText = "変更";
            this.SelectPat.MinimumWidth = 100;
            this.SelectPat.Name = "SelectPat";
            this.SelectPat.Text = "患者変更";
            this.SelectPat.UseColumnTextForButtonValue = true;
            // 
            // Status
            // 
            this.Status.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.AllCells;
            this.Status.DataPropertyName = "STATUS";
            this.Status.HeaderText = "状態";
            this.Status.Name = "Status";
            this.Status.ToolTipText = "割当状態 赤：割当無し 黄色：重複割当 青：自動割当";
            this.Status.Width = 51;
            // 
            // DBPatID
            // 
            this.DBPatID.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.AllCells;
            this.DBPatID.DataPropertyName = "DB_PATID";
            this.DBPatID.HeaderText = "FNWSi内部ID";
            this.DBPatID.Name = "DBPatID";
            this.DBPatID.Visible = false;
            // 
            // DBDispPatID
            // 
            this.DBDispPatID.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.AllCells;
            this.DBDispPatID.DataPropertyName = "DB_DISP_PATID";
            this.DBDispPatID.HeaderText = "FNWSi患者ID";
            this.DBDispPatID.MinimumWidth = 120;
            this.DBDispPatID.Name = "DBDispPatID";
            this.DBDispPatID.ToolTipText = "FNWSi登録患者ID";
            this.DBDispPatID.Width = 120;
            // 
            // DBName
            // 
            this.DBName.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.Fill;
            this.DBName.DataPropertyName = "DB_NAME";
            this.DBName.HeaderText = "氏名";
            this.DBName.Name = "DBName";
            this.DBName.ToolTipText = "FNWSi登録氏名";
            // 
            // DBSex
            // 
            this.DBSex.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.AllCells;
            this.DBSex.DataPropertyName = "DB_SEX";
            this.DBSex.HeaderText = "性別";
            this.DBSex.MinimumWidth = 55;
            this.DBSex.Name = "DBSex";
            this.DBSex.ToolTipText = "FNWSi登録性別";
            this.DBSex.Width = 55;
            // 
            // DBBirthday
            // 
            this.DBBirthday.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.AllCells;
            this.DBBirthday.DataPropertyName = "DB_BIRTHDAY";
            this.DBBirthday.HeaderText = "生年月日";
            this.DBBirthday.MinimumWidth = 80;
            this.DBBirthday.Name = "DBBirthday";
            this.DBBirthday.ToolTipText = "FNWSi登録生年月日";
            this.DBBirthday.Width = 80;
            // 
            // IsPdPat
            // 
            this.IsPdPat.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.AllCells;
            this.IsPdPat.DataPropertyName = "IS_PD_PAT";
            this.IsPdPat.FalseValue = "False";
            this.IsPdPat.HeaderText = "腹膜透析　在宅透析";
            this.IsPdPat.MinimumWidth = 60;
            this.IsPdPat.Name = "IsPdPat";
            this.IsPdPat.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.Automatic;
            this.IsPdPat.ToolTipText = "腹膜透析・在宅透析患者";
            this.IsPdPat.TrueValue = "True";
            this.IsPdPat.Width = 90;
            // 
            // lblPatSelect
            // 
            this.lblPatSelect.AutoSize = true;
            this.lblPatSelect.Location = new System.Drawing.Point(12, 9);
            this.lblPatSelect.Name = "lblPatSelect";
            this.lblPatSelect.Size = new System.Drawing.Size(349, 12);
            this.lblPatSelect.TabIndex = 1;
            this.lblPatSelect.Text = "透析医学会に登録済みの患者さんをFNWSiの患者さんと紐付けて下さい";
            // 
            // btnOK
            // 
            this.btnOK.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnOK.Location = new System.Drawing.Point(780, 400);
            this.btnOK.Name = "btnOK";
            this.btnOK.Size = new System.Drawing.Size(75, 23);
            this.btnOK.TabIndex = 2;
            this.btnOK.Text = "OK";
            this.btnOK.UseVisualStyleBackColor = true;
            this.btnOK.Click += new System.EventHandler(this.btnOK_Click);
            // 
            // btnCancel
            // 
            this.btnCancel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.btnCancel.Location = new System.Drawing.Point(861, 400);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(75, 23);
            this.btnCancel.TabIndex = 3;
            this.btnCancel.Text = "キャンセル";
            this.btnCancel.UseVisualStyleBackColor = true;
            this.btnCancel.Click += new System.EventHandler(this.btnCancel_Click);
            // 
            // FrmPatMatch
            // 
            this.AcceptButton = this.btnOK;
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.CancelButton = this.btnCancel;
            this.ClientSize = new System.Drawing.Size(948, 435);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.btnOK);
            this.Controls.Add(this.lblPatSelect);
            this.Controls.Add(this.grdPatList);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.KeyPreview = true;
            this.Name = "FrmPatMatch";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "患者設定";
            this.Load += new System.EventHandler(this.FrmPatMatch_Load);
            ((System.ComponentModel.ISupportInitialize)(this.grdPatList)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.DataGridView grdPatList;
        private System.Windows.Forms.Label lblPatSelect;
        private System.Windows.Forms.Button btnOK;
        private System.Windows.Forms.Button btnCancel;
        private System.Windows.Forms.DataGridViewTextBoxColumn MedicalSequence;
        private System.Windows.Forms.DataGridViewTextBoxColumn MedicalName;
        private System.Windows.Forms.DataGridViewTextBoxColumn MedicalSex;
        private System.Windows.Forms.DataGridViewTextBoxColumn MedicalBirthday;
        private System.Windows.Forms.DataGridViewButtonColumn SelectPat;
        private System.Windows.Forms.DataGridViewTextBoxColumn Status;
        private System.Windows.Forms.DataGridViewTextBoxColumn DBPatID;
        private System.Windows.Forms.DataGridViewTextBoxColumn DBDispPatID;
        private System.Windows.Forms.DataGridViewTextBoxColumn DBName;
        private System.Windows.Forms.DataGridViewTextBoxColumn DBSex;
        private System.Windows.Forms.DataGridViewTextBoxColumn DBBirthday;
        private System.Windows.Forms.DataGridViewCheckBoxColumn IsPdPat;
    }
}