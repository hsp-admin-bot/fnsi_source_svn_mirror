namespace Fnw.StatisticsTool.FrmDispCode
{
    partial class FrmDispCodeMatch
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
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle2 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle1 = new System.Windows.Forms.DataGridViewCellStyle();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FrmDispCodeMatch));
            this.grdDispCodeList = new System.Windows.Forms.DataGridView();
            this.COL_FNW_NAME = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.COL_FNW_CODE = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.COL_STATUS = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.COL_SELECT = new System.Windows.Forms.DataGridViewButtonColumn();
            this.COL_MATCH_CODE = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.COL_MATCH_NAME = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.label1 = new System.Windows.Forms.Label();
            this.btnCancel = new System.Windows.Forms.Button();
            this.btnOK = new System.Windows.Forms.Button();
            ((System.ComponentModel.ISupportInitialize)(this.grdDispCodeList)).BeginInit();
            this.SuspendLayout();
            // 
            // grdDispCodeList
            // 
            this.grdDispCodeList.AllowUserToAddRows = false;
            this.grdDispCodeList.AllowUserToDeleteRows = false;
            this.grdDispCodeList.AllowUserToResizeRows = false;
            this.grdDispCodeList.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.grdDispCodeList.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.grdDispCodeList.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.COL_FNW_NAME,
            this.COL_FNW_CODE,
            this.COL_STATUS,
            this.COL_SELECT,
            this.COL_MATCH_CODE,
            this.COL_MATCH_NAME});
            this.grdDispCodeList.Location = new System.Drawing.Point(12, 24);
            this.grdDispCodeList.MultiSelect = false;
            this.grdDispCodeList.Name = "grdDispCodeList";
            this.grdDispCodeList.ReadOnly = true;
            this.grdDispCodeList.RowHeadersVisible = false;
            dataGridViewCellStyle2.Font = new System.Drawing.Font("ＭＳ ゴシック", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.grdDispCodeList.RowsDefaultCellStyle = dataGridViewCellStyle2;
            this.grdDispCodeList.RowTemplate.Height = 21;
            this.grdDispCodeList.Size = new System.Drawing.Size(716, 339);
            this.grdDispCodeList.TabIndex = 0;
            this.grdDispCodeList.CellClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.grdDiseaseList_CellClick);
            this.grdDispCodeList.CellDoubleClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.grdDiseaseList_CellDoubleClick);
            this.grdDispCodeList.DataBindingComplete += new System.Windows.Forms.DataGridViewBindingCompleteEventHandler(this.grdDiseaseList_DataBindingComplete);
            // 
            // COL_FNW_NAME
            // 
            this.COL_FNW_NAME.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.AllCells;
            this.COL_FNW_NAME.DataPropertyName = "COL_FNW_NAME";
            dataGridViewCellStyle1.BackColor = System.Drawing.Color.Silver;
            this.COL_FNW_NAME.DefaultCellStyle = dataGridViewCellStyle1;
            this.COL_FNW_NAME.HeaderText = "名称";
            this.COL_FNW_NAME.Name = "COL_FNW_NAME";
            this.COL_FNW_NAME.ReadOnly = true;
            this.COL_FNW_NAME.Width = 54;
            // 
            // COL_FNW_CODE
            // 
            this.COL_FNW_CODE.DataPropertyName = "COL_FNW_CODE";
            this.COL_FNW_CODE.HeaderText = "コード";
            this.COL_FNW_CODE.Name = "COL_FNW_CODE";
            this.COL_FNW_CODE.ReadOnly = true;
            this.COL_FNW_CODE.Visible = false;
            // 
            // COL_STATUS
            // 
            this.COL_STATUS.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.AllCells;
            this.COL_STATUS.DataPropertyName = "COL_STATUS";
            this.COL_STATUS.HeaderText = "状態";
            this.COL_STATUS.Name = "COL_STATUS";
            this.COL_STATUS.ReadOnly = true;
            this.COL_STATUS.Resizable = System.Windows.Forms.DataGridViewTriState.True;
            this.COL_STATUS.Width = 54;
            // 
            // COL_SELECT
            // 
            this.COL_SELECT.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.None;
            this.COL_SELECT.HeaderText = "変更";
            this.COL_SELECT.Name = "COL_SELECT";
            this.COL_SELECT.ReadOnly = true;
            this.COL_SELECT.Resizable = System.Windows.Forms.DataGridViewTriState.True;
            this.COL_SELECT.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.Automatic;
            this.COL_SELECT.Width = 60;
            // 
            // COL_MATCH_CODE
            // 
            this.COL_MATCH_CODE.DataPropertyName = "COL_MATCH_CODE";
            this.COL_MATCH_CODE.HeaderText = "選択コード";
            this.COL_MATCH_CODE.Name = "COL_MATCH_CODE";
            this.COL_MATCH_CODE.ReadOnly = true;
            this.COL_MATCH_CODE.Visible = false;
            // 
            // COL_MATCH_NAME
            // 
            this.COL_MATCH_NAME.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.Fill;
            this.COL_MATCH_NAME.DataPropertyName = "COL_MATCH_NAME";
            this.COL_MATCH_NAME.HeaderText = "学会コード";
            this.COL_MATCH_NAME.Name = "COL_MATCH_NAME";
            this.COL_MATCH_NAME.ReadOnly = true;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(12, 9);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(278, 12);
            this.label1.TabIndex = 1;
            this.label1.Text = "FNWSiで使用している候補を学会コードと紐付けてください";
            // 
            // btnCancel
            // 
            this.btnCancel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.btnCancel.Location = new System.Drawing.Point(653, 369);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(75, 23);
            this.btnCancel.TabIndex = 2;
            this.btnCancel.Text = "キャンセル";
            this.btnCancel.UseVisualStyleBackColor = true;
            // 
            // btnOK
            // 
            this.btnOK.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnOK.Location = new System.Drawing.Point(572, 369);
            this.btnOK.Name = "btnOK";
            this.btnOK.Size = new System.Drawing.Size(75, 23);
            this.btnOK.TabIndex = 2;
            this.btnOK.Text = "OK";
            this.btnOK.UseVisualStyleBackColor = true;
            this.btnOK.Click += new System.EventHandler(this.btnOK_Click);
            // 
            // FrmDispCodeMatch
            // 
            this.AcceptButton = this.btnOK;
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.CancelButton = this.btnCancel;
            this.ClientSize = new System.Drawing.Size(740, 404);
            this.Controls.Add(this.btnOK);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.grdDispCodeList);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "FrmDispCodeMatch";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "設定";
            this.Load += new System.EventHandler(this.FrmMstDiseaseMatch_Load);
            ((System.ComponentModel.ISupportInitialize)(this.grdDispCodeList)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.DataGridView grdDispCodeList;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Button btnCancel;
        private System.Windows.Forms.Button btnOK;
        private System.Windows.Forms.DataGridViewTextBoxColumn COL_FNW_NAME;
        private System.Windows.Forms.DataGridViewTextBoxColumn COL_FNW_CODE;
        private System.Windows.Forms.DataGridViewTextBoxColumn COL_STATUS;
        private System.Windows.Forms.DataGridViewButtonColumn COL_SELECT;
        private System.Windows.Forms.DataGridViewTextBoxColumn COL_MATCH_CODE;
        private System.Windows.Forms.DataGridViewTextBoxColumn COL_MATCH_NAME;
    }
}