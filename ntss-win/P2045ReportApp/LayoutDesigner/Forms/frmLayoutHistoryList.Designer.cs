namespace LayoutDesigner
{
    partial class frmLayoutHistoryList
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
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle6 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle7 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle8 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle2 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle3 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle4 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle5 = new System.Windows.Forms.DataGridViewCellStyle();
            this.dgvLayOutHistory = new System.Windows.Forms.DataGridView();
            this.IsSelect = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.CtlNo = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.UpdDate = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.UpdUserName = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.btnOK = new System.Windows.Forms.Button();
            this.btnCancel = new System.Windows.Forms.Button();
            ((System.ComponentModel.ISupportInitialize)(this.dgvLayOutHistory)).BeginInit();
            this.SuspendLayout();
            // 
            // winlblTitle
            // 
            this.winlblTitle.Font = new System.Drawing.Font("Yu Gothic UI", 9F);
            this.winlblTitle.Size = new System.Drawing.Size(359, 21);
            this.winlblTitle.Text = "帳票履歴";
            // 
            // dgvLayOutHistory
            // 
            this.dgvLayOutHistory.AllowUserToAddRows = false;
            this.dgvLayOutHistory.AllowUserToDeleteRows = false;
            this.dgvLayOutHistory.AllowUserToResizeRows = false;
            this.dgvLayOutHistory.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.AllCells;
            this.dgvLayOutHistory.BackgroundColor = System.Drawing.Color.FromArgb(((int)(((byte)(50)))), ((int)(((byte)(50)))), ((int)(((byte)(50)))));
            this.dgvLayOutHistory.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.dgvLayOutHistory.ColumnHeadersBorderStyle = System.Windows.Forms.DataGridViewHeaderBorderStyle.Single;
            dataGridViewCellStyle1.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(50)))), ((int)(((byte)(50)))), ((int)(((byte)(50)))));
            dataGridViewCellStyle1.Font = new System.Drawing.Font("Yu Gothic UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle1.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle1.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle1.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            dataGridViewCellStyle1.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.dgvLayOutHistory.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle1;
            this.dgvLayOutHistory.ColumnHeadersHeight = 30;
            this.dgvLayOutHistory.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.DisableResizing;
            this.dgvLayOutHistory.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.IsSelect,
            this.CtlNo,
            this.UpdDate,
            this.UpdUserName});
            dataGridViewCellStyle6.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle6.BackColor = System.Drawing.SystemColors.Window;
            dataGridViewCellStyle6.Font = new System.Drawing.Font("Yu Gothic UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle6.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle6.SelectionBackColor = System.Drawing.Color.SlateGray;
            dataGridViewCellStyle6.SelectionForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle6.WrapMode = System.Windows.Forms.DataGridViewTriState.False;
            this.dgvLayOutHistory.DefaultCellStyle = dataGridViewCellStyle6;
            this.dgvLayOutHistory.EnableHeadersVisualStyles = false;
            this.dgvLayOutHistory.GridColor = System.Drawing.Color.FromArgb(((int)(((byte)(70)))), ((int)(((byte)(70)))), ((int)(((byte)(70)))));
            this.dgvLayOutHistory.Location = new System.Drawing.Point(4, 25);
            this.dgvLayOutHistory.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.dgvLayOutHistory.MultiSelect = false;
            this.dgvLayOutHistory.Name = "dgvLayOutHistory";
            this.dgvLayOutHistory.ReadOnly = true;
            dataGridViewCellStyle7.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle7.BackColor = System.Drawing.SystemColors.Control;
            dataGridViewCellStyle7.Font = new System.Drawing.Font("Yu Gothic UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle7.ForeColor = System.Drawing.SystemColors.WindowText;
            dataGridViewCellStyle7.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle7.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            this.dgvLayOutHistory.RowHeadersDefaultCellStyle = dataGridViewCellStyle7;
            this.dgvLayOutHistory.RowHeadersVisible = false;
            this.dgvLayOutHistory.RowHeadersWidth = 51;
            dataGridViewCellStyle8.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(40)))), ((int)(((byte)(40)))), ((int)(((byte)(40)))));
            dataGridViewCellStyle8.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle8.SelectionBackColor = System.Drawing.Color.SlateGray;
            dataGridViewCellStyle8.SelectionForeColor = System.Drawing.Color.White;
            this.dgvLayOutHistory.RowsDefaultCellStyle = dataGridViewCellStyle8;
            this.dgvLayOutHistory.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.dgvLayOutHistory.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dgvLayOutHistory.Size = new System.Drawing.Size(354, 240);
            this.dgvLayOutHistory.TabIndex = 4;
            this.dgvLayOutHistory.Tag = "";
            this.dgvLayOutHistory.CellContentClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.dgvLayOutHistory_CellContentClick);
            this.dgvLayOutHistory.CellEnter += new System.Windows.Forms.DataGridViewCellEventHandler(this.dgvLayOutHistory_CellEnter);
            // 
            // IsSelect
            // 
            this.IsSelect.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.None;
            this.IsSelect.DataPropertyName = "IsSelect";
            dataGridViewCellStyle2.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            this.IsSelect.DefaultCellStyle = dataGridViewCellStyle2;
            this.IsSelect.FillWeight = 50F;
            this.IsSelect.HeaderText = "適用";
            this.IsSelect.MinimumWidth = 6;
            this.IsSelect.Name = "IsSelect";
            this.IsSelect.ReadOnly = true;
            this.IsSelect.Resizable = System.Windows.Forms.DataGridViewTriState.False;
            this.IsSelect.Width = 50;
            // 
            // CtlNo
            // 
            this.CtlNo.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.None;
            this.CtlNo.DataPropertyName = "CtlNo";
            dataGridViewCellStyle3.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            this.CtlNo.DefaultCellStyle = dataGridViewCellStyle3;
            this.CtlNo.FillWeight = 50F;
            this.CtlNo.HeaderText = "版数";
            this.CtlNo.MinimumWidth = 6;
            this.CtlNo.Name = "CtlNo";
            this.CtlNo.ReadOnly = true;
            this.CtlNo.Resizable = System.Windows.Forms.DataGridViewTriState.False;
            this.CtlNo.Width = 60;
            // 
            // UpdDate
            // 
            this.UpdDate.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.None;
            this.UpdDate.DataPropertyName = "UpdDate";
            dataGridViewCellStyle4.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            this.UpdDate.DefaultCellStyle = dataGridViewCellStyle4;
            this.UpdDate.HeaderText = "作成日時";
            this.UpdDate.MinimumWidth = 6;
            this.UpdDate.Name = "UpdDate";
            this.UpdDate.ReadOnly = true;
            this.UpdDate.Resizable = System.Windows.Forms.DataGridViewTriState.False;
            this.UpdDate.Width = 125;
            // 
            // UpdUserName
            // 
            this.UpdUserName.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.None;
            this.UpdUserName.DataPropertyName = "UpdUserName";
            dataGridViewCellStyle5.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            this.UpdUserName.DefaultCellStyle = dataGridViewCellStyle5;
            this.UpdUserName.FillWeight = 200F;
            this.UpdUserName.HeaderText = "更新者";
            this.UpdUserName.MinimumWidth = 6;
            this.UpdUserName.Name = "UpdUserName";
            this.UpdUserName.ReadOnly = true;
            this.UpdUserName.Resizable = System.Windows.Forms.DataGridViewTriState.False;
            this.UpdUserName.Width = 200;
            // 
            // btnOK
            // 
            this.btnOK.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnOK.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnOK.FlatAppearance.BorderSize = 2;
            this.btnOK.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnOK.Location = new System.Drawing.Point(274, 268);
            this.btnOK.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.btnOK.Name = "btnOK";
            this.btnOK.Size = new System.Drawing.Size(87, 30);
            this.btnOK.TabIndex = 7;
            this.btnOK.Text = "適用";
            this.btnOK.Click += new System.EventHandler(this.btnOK_Click);
            // 
            // btnCancel
            // 
            this.btnCancel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.btnCancel.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnCancel.FlatAppearance.BorderSize = 2;
            this.btnCancel.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnCancel.Location = new System.Drawing.Point(173, 268);
            this.btnCancel.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(87, 30);
            this.btnCancel.TabIndex = 8;
            this.btnCancel.Text = "キャンセル";
            this.btnCancel.Click += new System.EventHandler(this.btnCancel_Click);
            // 
            // frmLayoutHistoryList
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(363, 303);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.btnOK);
            this.Controls.Add(this.dgvLayOutHistory);
            this.Margin = new System.Windows.Forms.Padding(3, 3, 3, 3);
            this.Name = "frmLayoutHistoryList";
            this.Text = "frmLayoutHistoryList";
            this.Controls.SetChildIndex(this.btnFocusControl, 0);
            this.Controls.SetChildIndex(this.btnTop, 0);
            this.Controls.SetChildIndex(this.btnStop, 0);
            this.Controls.SetChildIndex(this.winlblTitle, 0);
            this.Controls.SetChildIndex(this.dgvLayOutHistory, 0);
            this.Controls.SetChildIndex(this.btnOK, 0);
            this.Controls.SetChildIndex(this.btnCancel, 0);
            ((System.ComponentModel.ISupportInitialize)(this.dgvLayOutHistory)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.DataGridView dgvLayOutHistory;
        private System.Windows.Forms.Button btnOK;
        private System.Windows.Forms.Button btnCancel;
        private System.Windows.Forms.DataGridViewTextBoxColumn IsSelect;
        private System.Windows.Forms.DataGridViewTextBoxColumn CtlNo;
        private System.Windows.Forms.DataGridViewTextBoxColumn UpdDate;
        private System.Windows.Forms.DataGridViewTextBoxColumn UpdUserName;
    }
}