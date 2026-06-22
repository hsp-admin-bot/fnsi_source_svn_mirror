namespace LayoutDesigner
{
    partial class frmSelectTotalUnit
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
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle1 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle2 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle3 = new System.Windows.Forms.DataGridViewCellStyle();
            this.dgvTotalUnitList = new System.Windows.Forms.DataGridView();
            this.btnOK = new System.Windows.Forms.Button();
            this.btnCancel = new System.Windows.Forms.Button();
            this.lblDataPathAddr = new System.Windows.Forms.Label();
            this.btnClear = new System.Windows.Forms.Button();
            this.CellAddress = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.DataName = new System.Windows.Forms.DataGridViewTextBoxColumn();
            ((System.ComponentModel.ISupportInitialize)(this.dgvTotalUnitList)).BeginInit();
            this.SuspendLayout();
            // 
            // btnStop
            // 
            this.btnStop.Enabled = false;
            this.btnStop.Location = new System.Drawing.Point(225, 360);
            this.btnStop.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.btnStop.TabIndex = 7;
            // 
            // btnTop
            // 
            this.btnTop.Location = new System.Drawing.Point(14, 9);
            this.btnTop.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            // 
            // btnFocusControl
            // 
            this.btnFocusControl.Location = new System.Drawing.Point(295, 415);
            this.btnFocusControl.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.btnFocusControl.TabIndex = 4;
            // 
            // winlblTitle
            // 
            this.winlblTitle.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(66)))), ((int)(((byte)(66)))), ((int)(((byte)(66)))));
            this.winlblTitle.Font = new System.Drawing.Font("Yu Gothic UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.winlblTitle.Location = new System.Drawing.Point(2, 3);
            this.winlblTitle.Size = new System.Drawing.Size(392, 24);
            this.winlblTitle.Text = "の単位選択画面";
            // 
            // dgvTotalUnitList
            // 
            this.dgvTotalUnitList.AllowUserToAddRows = false;
            this.dgvTotalUnitList.AllowUserToDeleteRows = false;
            this.dgvTotalUnitList.AllowUserToResizeRows = false;
            this.dgvTotalUnitList.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.dgvTotalUnitList.BackgroundColor = System.Drawing.Color.FromArgb(((int)(((byte)(50)))), ((int)(((byte)(50)))), ((int)(((byte)(50)))));
            this.dgvTotalUnitList.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.dgvTotalUnitList.ColumnHeadersBorderStyle = System.Windows.Forms.DataGridViewHeaderBorderStyle.Single;
            dataGridViewCellStyle1.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(50)))), ((int)(((byte)(50)))), ((int)(((byte)(50)))));
            dataGridViewCellStyle1.Font = new System.Drawing.Font("Yu Gothic UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle1.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle1.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle1.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            dataGridViewCellStyle1.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.dgvTotalUnitList.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle1;
            this.dgvTotalUnitList.ColumnHeadersHeight = 29;
            this.dgvTotalUnitList.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.DisableResizing;
            this.dgvTotalUnitList.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.CellAddress,
            this.DataName});
            dataGridViewCellStyle2.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle2.BackColor = System.Drawing.SystemColors.Window;
            dataGridViewCellStyle2.Font = new System.Drawing.Font("Yu Gothic UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle2.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle2.SelectionBackColor = System.Drawing.Color.SlateGray;
            dataGridViewCellStyle2.SelectionForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle2.WrapMode = System.Windows.Forms.DataGridViewTriState.False;
            this.dgvTotalUnitList.DefaultCellStyle = dataGridViewCellStyle2;
            this.dgvTotalUnitList.EnableHeadersVisualStyles = false;
            this.dgvTotalUnitList.GridColor = System.Drawing.Color.FromArgb(((int)(((byte)(70)))), ((int)(((byte)(70)))), ((int)(((byte)(70)))));
            this.dgvTotalUnitList.Location = new System.Drawing.Point(14, 33);
            this.dgvTotalUnitList.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.dgvTotalUnitList.Name = "dgvTotalUnitList";
            this.dgvTotalUnitList.RowHeadersVisible = false;
            this.dgvTotalUnitList.RowHeadersWidth = 51;
            dataGridViewCellStyle3.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(40)))), ((int)(((byte)(40)))), ((int)(((byte)(40)))));
            dataGridViewCellStyle3.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle3.SelectionBackColor = System.Drawing.Color.SlateGray;
            dataGridViewCellStyle3.SelectionForeColor = System.Drawing.Color.White;
            this.dgvTotalUnitList.RowsDefaultCellStyle = dataGridViewCellStyle3;
            this.dgvTotalUnitList.RowTemplate.Height = 21;
            this.dgvTotalUnitList.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dgvTotalUnitList.Size = new System.Drawing.Size(368, 372);
            this.dgvTotalUnitList.TabIndex = 3;
            // 
            // btnOK
            // 
            this.btnOK.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnOK.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnOK.FlatAppearance.BorderSize = 2;
            this.btnOK.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnOK.ForeColor = System.Drawing.Color.White;
            this.btnOK.Location = new System.Drawing.Point(282, 415);
            this.btnOK.Margin = new System.Windows.Forms.Padding(3, 5, 3, 5);
            this.btnOK.Name = "btnOK";
            this.btnOK.Size = new System.Drawing.Size(99, 39);
            this.btnOK.TabIndex = 6;
            this.btnOK.Text = "OK";
            // 
            // btnCancel
            // 
            this.btnCancel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.btnCancel.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnCancel.FlatAppearance.BorderSize = 2;
            this.btnCancel.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnCancel.ForeColor = System.Drawing.Color.White;
            this.btnCancel.Location = new System.Drawing.Point(175, 415);
            this.btnCancel.Margin = new System.Windows.Forms.Padding(3, 5, 3, 5);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(99, 39);
            this.btnCancel.TabIndex = 5;
            this.btnCancel.Text = "キャンセル";
            // 
            // lblDataPathAddr
            // 
            this.lblDataPathAddr.AutoSize = true;
            this.lblDataPathAddr.Location = new System.Drawing.Point(11, 33);
            this.lblDataPathAddr.Name = "lblDataPathAddr";
            this.lblDataPathAddr.Size = new System.Drawing.Size(13, 20);
            this.lblDataPathAddr.TabIndex = 2;
            this.lblDataPathAddr.Text = " ";
            // 
            // btnClear
            // 
            this.btnClear.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnClear.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnClear.FlatAppearance.BorderSize = 2;
            this.btnClear.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnClear.ForeColor = System.Drawing.Color.White;
            this.btnClear.Location = new System.Drawing.Point(70, 414);
            this.btnClear.Margin = new System.Windows.Forms.Padding(3, 5, 3, 5);
            this.btnClear.Name = "btnClear";
            this.btnClear.Size = new System.Drawing.Size(99, 39);
            this.btnClear.TabIndex = 5;
            this.btnClear.Text = "初期化";
            // 
            // CellAddress
            // 
            this.CellAddress.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.AllCells;
            this.CellAddress.DataPropertyName = "CellAddress";
            this.CellAddress.HeaderText = "場所";
            this.CellAddress.MinimumWidth = 80;
            this.CellAddress.Name = "CellAddress";
            this.CellAddress.ReadOnly = true;
            this.CellAddress.Width = 80;
            // 
            // DataName
            // 
            this.DataName.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.Fill;
            this.DataName.DataPropertyName = "DataName";
            this.DataName.HeaderText = "データ名";
            this.DataName.MinimumWidth = 6;
            this.DataName.Name = "DataName";
            this.DataName.ReadOnly = true;
            // 
            // frmSelectTotalUnit
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 20F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.CancelButton = this.btnCancel;
            this.ClientSize = new System.Drawing.Size(396, 462);
            this.Controls.Add(this.lblDataPathAddr);
            this.Controls.Add(this.btnClear);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.btnOK);
            this.Controls.Add(this.dgvTotalUnitList);
            this.Margin = new System.Windows.Forms.Padding(3, 7, 3, 7);
            this.MinimumSize = new System.Drawing.Size(325, 379);
            this.Name = "frmSelectTotalUnit";
            this.Padding = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.Controls.SetChildIndex(this.btnStop, 0);
            this.Controls.SetChildIndex(this.dgvTotalUnitList, 0);
            this.Controls.SetChildIndex(this.btnOK, 0);
            this.Controls.SetChildIndex(this.btnCancel, 0);
            this.Controls.SetChildIndex(this.btnClear, 0);
            this.Controls.SetChildIndex(this.winlblTitle, 0);
            this.Controls.SetChildIndex(this.btnFocusControl, 0);
            this.Controls.SetChildIndex(this.btnTop, 0);
            this.Controls.SetChildIndex(this.lblDataPathAddr, 0);
            ((System.ComponentModel.ISupportInitialize)(this.dgvTotalUnitList)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.DataGridView dgvTotalUnitList;
        private System.Windows.Forms.Button btnOK;
        private System.Windows.Forms.Button btnCancel;
        private System.Windows.Forms.Label lblDataPathAddr;
        private System.Windows.Forms.Button btnClear;
        private System.Windows.Forms.DataGridViewTextBoxColumn CellAddress;
        private System.Windows.Forms.DataGridViewTextBoxColumn DataName;
    }
}