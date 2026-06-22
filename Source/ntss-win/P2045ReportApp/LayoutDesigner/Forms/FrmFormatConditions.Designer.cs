namespace LayoutDesigner
{
    partial class FrmFormatConditions
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
            this.btnOK = new System.Windows.Forms.Button();
            this.btnCancel = new System.Windows.Forms.Button();
            this.fontDialog1 = new System.Windows.Forms.FontDialog();
            this.btnRuleAdd = new System.Windows.Forms.Button();
            this.btnRuleEdit = new System.Windows.Forms.Button();
            this.btnRuleDelete = new System.Windows.Forms.Button();
            this.dgvFormatConditions = new System.Windows.Forms.DataGridView();
            this.Code = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.DataName = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.btnUp = new System.Windows.Forms.Button();
            this.btnDown = new System.Windows.Forms.Button();
            ((System.ComponentModel.ISupportInitialize)(this.dgvFormatConditions)).BeginInit();
            this.SuspendLayout();
            // 
            // btnStop
            // 
            this.btnStop.Location = new System.Drawing.Point(16, 264);
            this.btnStop.TabIndex = 8;
            // 
            // btnTop
            // 
            this.btnTop.Location = new System.Drawing.Point(5, 8);
            // 
            // btnFocusControl
            // 
            this.btnFocusControl.Location = new System.Drawing.Point(16, 248);
            this.btnFocusControl.TabIndex = 4;
            // 
            // winlblTitle
            // 
            this.winlblTitle.Font = new System.Drawing.Font("Yu Gothic UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.winlblTitle.Margin = new System.Windows.Forms.Padding(0);
            this.winlblTitle.Size = new System.Drawing.Size(586, 18);
            this.winlblTitle.Text = "　条件付き書式ルールの管理";
            // 
            // btnOK
            // 
            this.btnOK.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnOK.DialogResult = System.Windows.Forms.DialogResult.OK;
            this.btnOK.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnOK.FlatAppearance.BorderSize = 2;
            this.btnOK.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnOK.ForeColor = System.Drawing.Color.White;
            this.btnOK.Location = new System.Drawing.Point(491, 250);
            this.btnOK.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.btnOK.Name = "btnOK";
            this.btnOK.Size = new System.Drawing.Size(87, 29);
            this.btnOK.TabIndex = 7;
            this.btnOK.Text = "OK";
            this.btnOK.Click += new System.EventHandler(this.BtnClose_Click);
            // 
            // btnCancel
            // 
            this.btnCancel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.btnCancel.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnCancel.FlatAppearance.BorderSize = 2;
            this.btnCancel.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnCancel.ForeColor = System.Drawing.Color.White;
            this.btnCancel.Location = new System.Drawing.Point(397, 250);
            this.btnCancel.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(87, 29);
            this.btnCancel.TabIndex = 6;
            this.btnCancel.Text = "キャンセル";
            this.btnCancel.Click += new System.EventHandler(this.BtnClose_Click);
            // 
            // btnRuleAdd
            // 
            this.btnRuleAdd.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnRuleAdd.FlatAppearance.BorderSize = 2;
            this.btnRuleAdd.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnRuleAdd.ForeColor = System.Drawing.Color.White;
            this.btnRuleAdd.Location = new System.Drawing.Point(16, 32);
            this.btnRuleAdd.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.btnRuleAdd.Name = "btnRuleAdd";
            this.btnRuleAdd.Size = new System.Drawing.Size(147, 29);
            this.btnRuleAdd.TabIndex = 15;
            this.btnRuleAdd.Text = "新規ルール";
            this.btnRuleAdd.Click += new System.EventHandler(this.BtnRuleAdd_Click);
            // 
            // btnRuleEdit
            // 
            this.btnRuleEdit.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnRuleEdit.FlatAppearance.BorderSize = 2;
            this.btnRuleEdit.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnRuleEdit.ForeColor = System.Drawing.Color.White;
            this.btnRuleEdit.Location = new System.Drawing.Point(176, 32);
            this.btnRuleEdit.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.btnRuleEdit.Name = "btnRuleEdit";
            this.btnRuleEdit.Size = new System.Drawing.Size(147, 29);
            this.btnRuleEdit.TabIndex = 16;
            this.btnRuleEdit.Text = "ルールの編集";
            this.btnRuleEdit.Click += new System.EventHandler(this.BtnRuleEdit_Click);
            // 
            // btnRuleDelete
            // 
            this.btnRuleDelete.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnRuleDelete.FlatAppearance.BorderSize = 2;
            this.btnRuleDelete.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnRuleDelete.ForeColor = System.Drawing.Color.White;
            this.btnRuleDelete.Location = new System.Drawing.Point(336, 32);
            this.btnRuleDelete.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.btnRuleDelete.Name = "btnRuleDelete";
            this.btnRuleDelete.Size = new System.Drawing.Size(147, 29);
            this.btnRuleDelete.TabIndex = 17;
            this.btnRuleDelete.Text = "ルールの削除";
            this.btnRuleDelete.Click += new System.EventHandler(this.BtnRuleDelete_Click);
            // 
            // dgvFormatConditions
            // 
            this.dgvFormatConditions.AllowUserToAddRows = false;
            this.dgvFormatConditions.AllowUserToDeleteRows = false;
            this.dgvFormatConditions.AllowUserToResizeRows = false;
            this.dgvFormatConditions.BackgroundColor = System.Drawing.Color.FromArgb(((int)(((byte)(50)))), ((int)(((byte)(50)))), ((int)(((byte)(50)))));
            this.dgvFormatConditions.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.dgvFormatConditions.ColumnHeadersBorderStyle = System.Windows.Forms.DataGridViewHeaderBorderStyle.Single;
            dataGridViewCellStyle1.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(50)))), ((int)(((byte)(50)))), ((int)(((byte)(50)))));
            dataGridViewCellStyle1.Font = new System.Drawing.Font("Yu Gothic UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle1.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle1.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle1.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            dataGridViewCellStyle1.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.dgvFormatConditions.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle1;
            this.dgvFormatConditions.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.DisableResizing;
            this.dgvFormatConditions.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.Code,
            this.DataName});
            dataGridViewCellStyle2.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle2.BackColor = System.Drawing.SystemColors.Window;
            dataGridViewCellStyle2.Font = new System.Drawing.Font("Yu Gothic UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle2.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle2.SelectionBackColor = System.Drawing.Color.SlateGray;
            dataGridViewCellStyle2.SelectionForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle2.WrapMode = System.Windows.Forms.DataGridViewTriState.False;
            this.dgvFormatConditions.DefaultCellStyle = dataGridViewCellStyle2;
            this.dgvFormatConditions.EnableHeadersVisualStyles = false;
            this.dgvFormatConditions.GridColor = System.Drawing.Color.FromArgb(((int)(((byte)(70)))), ((int)(((byte)(70)))), ((int)(((byte)(70)))));
            this.dgvFormatConditions.Location = new System.Drawing.Point(16, 64);
            this.dgvFormatConditions.MultiSelect = false;
            this.dgvFormatConditions.Name = "dgvFormatConditions";
            this.dgvFormatConditions.ReadOnly = true;
            this.dgvFormatConditions.RowHeadersVisible = false;
            dataGridViewCellStyle3.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(40)))), ((int)(((byte)(40)))), ((int)(((byte)(40)))));
            dataGridViewCellStyle3.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle3.SelectionBackColor = System.Drawing.Color.SlateGray;
            dataGridViewCellStyle3.SelectionForeColor = System.Drawing.Color.White;
            this.dgvFormatConditions.RowsDefaultCellStyle = dataGridViewCellStyle3;
            this.dgvFormatConditions.RowTemplate.Height = 21;
            this.dgvFormatConditions.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dgvFormatConditions.Size = new System.Drawing.Size(560, 176);
            this.dgvFormatConditions.TabIndex = 18;
            // 
            // Code
            // 
            this.Code.DataPropertyName = "Code";
            this.Code.HeaderText = "ルール（表示順で適用）";
            this.Code.Name = "Code";
            this.Code.ReadOnly = true;
            this.Code.Width = 150;
            // 
            // DataName
            // 
            this.DataName.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.Fill;
            this.DataName.DataPropertyName = "DataName";
            this.DataName.HeaderText = "書式";
            this.DataName.MinimumWidth = 80;
            this.DataName.Name = "DataName";
            this.DataName.ReadOnly = true;
            // 
            // btnUp
            // 
            this.btnUp.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnUp.FlatAppearance.BorderSize = 2;
            this.btnUp.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnUp.ForeColor = System.Drawing.Color.White;
            this.btnUp.Location = new System.Drawing.Point(496, 32);
            this.btnUp.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.btnUp.Name = "btnUp";
            this.btnUp.Size = new System.Drawing.Size(32, 29);
            this.btnUp.TabIndex = 19;
            this.btnUp.Text = "▲";
            this.btnUp.Click += new System.EventHandler(this.BtnUp_Click);
            // 
            // btnDown
            // 
            this.btnDown.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnDown.FlatAppearance.BorderSize = 2;
            this.btnDown.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnDown.ForeColor = System.Drawing.Color.White;
            this.btnDown.Location = new System.Drawing.Point(541, 32);
            this.btnDown.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.btnDown.Name = "btnDown";
            this.btnDown.Size = new System.Drawing.Size(32, 29);
            this.btnDown.TabIndex = 20;
            this.btnDown.Text = "▼";
            this.btnDown.Click += new System.EventHandler(this.BtnDown_Click);
            // 
            // FrmFormatConditions
            // 
            this.AcceptButton = this.btnOK;
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.CancelButton = this.btnCancel;
            this.ClientSize = new System.Drawing.Size(590, 292);
            this.Controls.Add(this.btnDown);
            this.Controls.Add(this.btnUp);
            this.Controls.Add(this.dgvFormatConditions);
            this.Controls.Add(this.btnRuleDelete);
            this.Controls.Add(this.btnRuleEdit);
            this.Controls.Add(this.btnRuleAdd);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.btnOK);
            this.Margin = new System.Windows.Forms.Padding(3, 5, 3, 5);
            this.MinimumSize = new System.Drawing.Size(284, 284);
            this.Name = "FrmFormatConditions";
            this.Controls.SetChildIndex(this.btnOK, 0);
            this.Controls.SetChildIndex(this.btnCancel, 0);
            this.Controls.SetChildIndex(this.winlblTitle, 0);
            this.Controls.SetChildIndex(this.btnFocusControl, 0);
            this.Controls.SetChildIndex(this.btnTop, 0);
            this.Controls.SetChildIndex(this.btnStop, 0);
            this.Controls.SetChildIndex(this.btnRuleAdd, 0);
            this.Controls.SetChildIndex(this.btnRuleEdit, 0);
            this.Controls.SetChildIndex(this.btnRuleDelete, 0);
            this.Controls.SetChildIndex(this.dgvFormatConditions, 0);
            this.Controls.SetChildIndex(this.btnUp, 0);
            this.Controls.SetChildIndex(this.btnDown, 0);
            ((System.ComponentModel.ISupportInitialize)(this.dgvFormatConditions)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion
        private System.Windows.Forms.Button btnOK;
        private System.Windows.Forms.Button btnCancel;
        private System.Windows.Forms.FontDialog fontDialog1;
        private System.Windows.Forms.Button btnRuleAdd;
        private System.Windows.Forms.Button btnRuleEdit;
        private System.Windows.Forms.Button btnRuleDelete;
        private System.Windows.Forms.DataGridView dgvFormatConditions;
        private System.Windows.Forms.DataGridViewTextBoxColumn Code;
        private System.Windows.Forms.DataGridViewTextBoxColumn DataName;
        private System.Windows.Forms.Button btnUp;
        private System.Windows.Forms.Button btnDown;
    }
}