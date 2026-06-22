namespace Fnw.StatisticsTool.FrmPat
{
    partial class FrmPatSelect
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FrmPatSelect));
            this.btnOK = new System.Windows.Forms.Button();
            this.btnCancel = new System.Windows.Forms.Button();
            this.grdPatList = new System.Windows.Forms.DataGridView();
            this.PatID = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.DispPatID = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.PatName = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.Sex = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.Birthday = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.label2 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.rdoMedical = new System.Windows.Forms.RadioButton();
            this.rdoName = new System.Windows.Forms.RadioButton();
            this.txtName = new System.Windows.Forms.TextBox();
            this.lblSex = new System.Windows.Forms.Label();
            this.lblName = new System.Windows.Forms.Label();
            this.lblBirthday = new System.Windows.Forms.Label();
            this.rdoNoSelect = new System.Windows.Forms.RadioButton();
            this.label1 = new System.Windows.Forms.Label();
            this.label5 = new System.Windows.Forms.Label();
            this.label6 = new System.Windows.Forms.Label();
            ((System.ComponentModel.ISupportInitialize)(this.grdPatList)).BeginInit();
            this.SuspendLayout();
            // 
            // btnOK
            // 
            this.btnOK.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnOK.Location = new System.Drawing.Point(417, 326);
            this.btnOK.Name = "btnOK";
            this.btnOK.Size = new System.Drawing.Size(75, 23);
            this.btnOK.TabIndex = 0;
            this.btnOK.Text = "OK";
            this.btnOK.UseVisualStyleBackColor = true;
            this.btnOK.Click += new System.EventHandler(this.btnOK_Click);
            // 
            // btnCancel
            // 
            this.btnCancel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnCancel.Location = new System.Drawing.Point(498, 326);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(75, 23);
            this.btnCancel.TabIndex = 1;
            this.btnCancel.Text = "キャンセル";
            this.btnCancel.UseVisualStyleBackColor = true;
            this.btnCancel.Click += new System.EventHandler(this.btnCancel_Click);
            // 
            // grdPatList
            // 
            this.grdPatList.AllowUserToAddRows = false;
            this.grdPatList.AllowUserToDeleteRows = false;
            this.grdPatList.AllowUserToOrderColumns = true;
            this.grdPatList.AllowUserToResizeRows = false;
            this.grdPatList.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.grdPatList.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.grdPatList.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.PatID,
            this.DispPatID,
            this.PatName,
            this.Sex,
            this.Birthday});
            this.grdPatList.Location = new System.Drawing.Point(12, 87);
            this.grdPatList.Name = "grdPatList";
            this.grdPatList.ReadOnly = true;
            this.grdPatList.RowHeadersVisible = false;
            this.grdPatList.RowTemplate.Height = 21;
            this.grdPatList.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.grdPatList.Size = new System.Drawing.Size(561, 233);
            this.grdPatList.TabIndex = 2;
            this.grdPatList.CellDoubleClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.grdPatList_CellDoubleClick);
            // 
            // PatID
            // 
            this.PatID.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.AllCells;
            this.PatID.DataPropertyName = "PATID";
            this.PatID.HeaderText = "内部患者ID";
            this.PatID.Name = "PatID";
            this.PatID.ReadOnly = true;
            this.PatID.Visible = false;
            // 
            // DispPatID
            // 
            this.DispPatID.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.AllCells;
            this.DispPatID.DataPropertyName = "DISP_PATID";
            this.DispPatID.HeaderText = "患者ID";
            this.DispPatID.Name = "DispPatID";
            this.DispPatID.ReadOnly = true;
            this.DispPatID.Width = 65;
            // 
            // PatName
            // 
            this.PatName.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.Fill;
            this.PatName.DataPropertyName = "NAME";
            this.PatName.HeaderText = "氏名";
            this.PatName.Name = "PatName";
            this.PatName.ReadOnly = true;
            // 
            // Sex
            // 
            this.Sex.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.AllCells;
            this.Sex.DataPropertyName = "SEX";
            this.Sex.HeaderText = "性別";
            this.Sex.Name = "Sex";
            this.Sex.ReadOnly = true;
            this.Sex.Width = 54;
            // 
            // Birthday
            // 
            this.Birthday.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.AllCells;
            this.Birthday.DataPropertyName = "BIRTHDAY";
            this.Birthday.HeaderText = "生年月日";
            this.Birthday.Name = "Birthday";
            this.Birthday.ReadOnly = true;
            this.Birthday.Width = 78;
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(30, 32);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(29, 12);
            this.label2.TabIndex = 4;
            this.label2.Text = "氏名";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(30, 52);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(29, 12);
            this.label3.TabIndex = 5;
            this.label3.Text = "性別";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(30, 72);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(53, 12);
            this.label4.TabIndex = 6;
            this.label4.Text = "生年月日";
            // 
            // rdoMedical
            // 
            this.rdoMedical.AutoSize = true;
            this.rdoMedical.Checked = true;
            this.rdoMedical.Location = new System.Drawing.Point(13, 13);
            this.rdoMedical.Name = "rdoMedical";
            this.rdoMedical.Size = new System.Drawing.Size(133, 16);
            this.rdoMedical.TabIndex = 7;
            this.rdoMedical.TabStop = true;
            this.rdoMedical.Text = "下記の情報で絞り込む";
            this.rdoMedical.UseVisualStyleBackColor = true;
            this.rdoMedical.CheckedChanged += new System.EventHandler(this.rdoType_CheckedChanged);
            // 
            // rdoName
            // 
            this.rdoName.AutoSize = true;
            this.rdoName.Location = new System.Drawing.Point(243, 13);
            this.rdoName.Name = "rdoName";
            this.rdoName.Size = new System.Drawing.Size(133, 16);
            this.rdoName.TabIndex = 8;
            this.rdoName.Text = "下記の氏名で絞り込む";
            this.rdoName.UseVisualStyleBackColor = true;
            this.rdoName.CheckedChanged += new System.EventHandler(this.rdoType_CheckedChanged);
            // 
            // txtName
            // 
            this.txtName.Location = new System.Drawing.Point(262, 32);
            this.txtName.Name = "txtName";
            this.txtName.Size = new System.Drawing.Size(100, 19);
            this.txtName.TabIndex = 9;
            this.txtName.TextChanged += new System.EventHandler(this.txtName_TextChanged);
            // 
            // lblSex
            // 
            this.lblSex.AutoSize = true;
            this.lblSex.Location = new System.Drawing.Point(102, 52);
            this.lblSex.Name = "lblSex";
            this.lblSex.Size = new System.Drawing.Size(11, 12);
            this.lblSex.TabIndex = 5;
            this.lblSex.Text = "a";
            // 
            // lblName
            // 
            this.lblName.AutoSize = true;
            this.lblName.Location = new System.Drawing.Point(102, 32);
            this.lblName.Name = "lblName";
            this.lblName.Size = new System.Drawing.Size(11, 12);
            this.lblName.TabIndex = 4;
            this.lblName.Text = "a";
            // 
            // lblBirthday
            // 
            this.lblBirthday.AutoSize = true;
            this.lblBirthday.Location = new System.Drawing.Point(102, 72);
            this.lblBirthday.Name = "lblBirthday";
            this.lblBirthday.Size = new System.Drawing.Size(11, 12);
            this.lblBirthday.TabIndex = 6;
            this.lblBirthday.Text = "a";
            // 
            // rdoNoSelect
            // 
            this.rdoNoSelect.AutoSize = true;
            this.rdoNoSelect.Location = new System.Drawing.Point(473, 13);
            this.rdoNoSelect.Name = "rdoNoSelect";
            this.rdoNoSelect.Size = new System.Drawing.Size(87, 16);
            this.rdoNoSelect.TabIndex = 10;
            this.rdoNoSelect.Text = "未選択にする";
            this.rdoNoSelect.UseVisualStyleBackColor = true;
            this.rdoNoSelect.CheckedChanged += new System.EventHandler(this.rdoType_CheckedChanged);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(89, 32);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(7, 12);
            this.label1.TabIndex = 11;
            this.label1.Text = ":";
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(89, 52);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(7, 12);
            this.label5.TabIndex = 12;
            this.label5.Text = ":";
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Location = new System.Drawing.Point(89, 72);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(7, 12);
            this.label6.TabIndex = 13;
            this.label6.Text = ":";
            // 
            // FrmPatSelect
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(585, 361);
            this.Controls.Add(this.label6);
            this.Controls.Add(this.label5);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.rdoNoSelect);
            this.Controls.Add(this.txtName);
            this.Controls.Add(this.rdoName);
            this.Controls.Add(this.rdoMedical);
            this.Controls.Add(this.lblBirthday);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.lblName);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.lblSex);
            this.Controls.Add(this.grdPatList);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.btnOK);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "FrmPatSelect";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "患者選択";
            this.Load += new System.EventHandler(this.FrmPatSelect_Load);
            ((System.ComponentModel.ISupportInitialize)(this.grdPatList)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button btnOK;
        private System.Windows.Forms.Button btnCancel;
        private System.Windows.Forms.DataGridView grdPatList;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.RadioButton rdoMedical;
        private System.Windows.Forms.RadioButton rdoName;
        private System.Windows.Forms.TextBox txtName;
        private System.Windows.Forms.Label lblSex;
        private System.Windows.Forms.Label lblName;
        private System.Windows.Forms.Label lblBirthday;
        private System.Windows.Forms.RadioButton rdoNoSelect;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.DataGridViewTextBoxColumn PatID;
        private System.Windows.Forms.DataGridViewTextBoxColumn DispPatID;
        private System.Windows.Forms.DataGridViewTextBoxColumn PatName;
        private System.Windows.Forms.DataGridViewTextBoxColumn Sex;
        private System.Windows.Forms.DataGridViewTextBoxColumn Birthday;
    }
}