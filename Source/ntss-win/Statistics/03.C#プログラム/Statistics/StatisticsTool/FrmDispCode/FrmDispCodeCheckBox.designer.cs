namespace Fnw.StatisticsTool.FrmDispCode
{
    partial class FrmDispCodeCheckBox
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FrmDispCodeCheckBox));
            this.grdDispCodeList = new System.Windows.Forms.DataGridView();
            this.COL_SELECT = new System.Windows.Forms.DataGridViewCheckBoxColumn();
            this.COL_FNW_CODE = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.COL_FNW_NAME = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.lblMessage = new System.Windows.Forms.Label();
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
            this.COL_SELECT,
            this.COL_FNW_CODE,
            this.COL_FNW_NAME});
            this.grdDispCodeList.Location = new System.Drawing.Point(12, 24);
            this.grdDispCodeList.MultiSelect = false;
            this.grdDispCodeList.Name = "grdDispCodeList";
            this.grdDispCodeList.RowHeadersVisible = false;
            dataGridViewCellStyle1.Font = new System.Drawing.Font("ＭＳ ゴシック", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.grdDispCodeList.RowsDefaultCellStyle = dataGridViewCellStyle1;
            this.grdDispCodeList.RowTemplate.Height = 21;
            this.grdDispCodeList.Size = new System.Drawing.Size(537, 339);
            this.grdDispCodeList.TabIndex = 0;
            // 
            // COL_SELECT
            // 
            this.COL_SELECT.DataPropertyName = "COL_SELECT";
            this.COL_SELECT.FalseValue = "0";
            this.COL_SELECT.Frozen = true;
            this.COL_SELECT.HeaderText = "選択";
            this.COL_SELECT.IndeterminateValue = "";
            this.COL_SELECT.Name = "COL_SELECT";
            this.COL_SELECT.Resizable = System.Windows.Forms.DataGridViewTriState.False;
            this.COL_SELECT.TrueValue = "1";
            this.COL_SELECT.Width = 50;
            // 
            // COL_FNW_CODE
            // 
            this.COL_FNW_CODE.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.AllCells;
            this.COL_FNW_CODE.DataPropertyName = "COL_FNW_CODE";
            this.COL_FNW_CODE.HeaderText = "コード";
            this.COL_FNW_CODE.Name = "COL_FNW_CODE";
            this.COL_FNW_CODE.ReadOnly = true;
            this.COL_FNW_CODE.Width = 57;
            // 
            // COL_FNW_NAME
            // 
            this.COL_FNW_NAME.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.Fill;
            this.COL_FNW_NAME.DataPropertyName = "COL_FNW_NAME";
            this.COL_FNW_NAME.HeaderText = "名称";
            this.COL_FNW_NAME.Name = "COL_FNW_NAME";
            this.COL_FNW_NAME.ReadOnly = true;
            // 
            // lblMessage
            // 
            this.lblMessage.AutoSize = true;
            this.lblMessage.Location = new System.Drawing.Point(12, 9);
            this.lblMessage.Name = "lblMessage";
            this.lblMessage.Size = new System.Drawing.Size(50, 12);
            this.lblMessage.TabIndex = 1;
            this.lblMessage.Text = "メッセージ";
            // 
            // btnCancel
            // 
            this.btnCancel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.btnCancel.Location = new System.Drawing.Point(474, 369);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(75, 23);
            this.btnCancel.TabIndex = 2;
            this.btnCancel.Text = "キャンセル";
            this.btnCancel.UseVisualStyleBackColor = true;
            // 
            // btnOK
            // 
            this.btnOK.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnOK.Location = new System.Drawing.Point(393, 369);
            this.btnOK.Name = "btnOK";
            this.btnOK.Size = new System.Drawing.Size(75, 23);
            this.btnOK.TabIndex = 1;
            this.btnOK.Text = "OK";
            this.btnOK.UseVisualStyleBackColor = true;
            this.btnOK.Click += new System.EventHandler(this.btnOK_Click);
            // 
            // FrmDispCodeCheckBox
            // 
            this.AcceptButton = this.btnOK;
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.CancelButton = this.btnCancel;
            this.ClientSize = new System.Drawing.Size(561, 404);
            this.Controls.Add(this.btnOK);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.lblMessage);
            this.Controls.Add(this.grdDispCodeList);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "FrmDispCodeCheckBox";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "設定";
            this.Load += new System.EventHandler(this.FrmMstDiseaseMatch_Load);
            ((System.ComponentModel.ISupportInitialize)(this.grdDispCodeList)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.DataGridView grdDispCodeList;
        private System.Windows.Forms.Label lblMessage;
        private System.Windows.Forms.Button btnCancel;
        private System.Windows.Forms.Button btnOK;
        private System.Windows.Forms.DataGridViewTextBoxColumn COL_FNW_CODE;
        private System.Windows.Forms.DataGridViewTextBoxColumn COL_FNW_NAME;
        private System.Windows.Forms.DataGridViewCheckBoxColumn COL_SELECT;
    }
}