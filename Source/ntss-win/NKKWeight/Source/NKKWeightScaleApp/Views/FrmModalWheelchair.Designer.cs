namespace NKKWeightScaleApp.Views
{
    partial class FrmModalWheelchair
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
            this.btnCancel = new System.Windows.Forms.Button();
            this.btnConfirm = new System.Windows.Forms.Button();
            this.dgvWheelchair = new System.Windows.Forms.DataGridView();
            this.Selected = new System.Windows.Forms.DataGridViewCheckBoxColumn();
            this.WheelchairName = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.WeightDisplay = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.OwnerPatient = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.Weight = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.WheelchairID = new System.Windows.Forms.DataGridViewTextBoxColumn();
            ((System.ComponentModel.ISupportInitialize)(this.dgvWheelchair)).BeginInit();
            this.SuspendLayout();
            // 
            // btnCancel
            // 
            this.btnCancel.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnCancel.Font = new System.Drawing.Font("Microsoft Sans Serif", 24.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnCancel.Location = new System.Drawing.Point(12, 623);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(169, 66);
            this.btnCancel.TabIndex = 30;
            this.btnCancel.Text = "キャンセル";
            this.btnCancel.UseVisualStyleBackColor = true;
            this.btnCancel.Click += new System.EventHandler(this.btnCancel_Click);
            // 
            // btnConfirm
            // 
            this.btnConfirm.BackColor = System.Drawing.Color.Goldenrod;
            this.btnConfirm.Font = new System.Drawing.Font("Microsoft Sans Serif", 24.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnConfirm.ForeColor = System.Drawing.Color.White;
            this.btnConfirm.Location = new System.Drawing.Point(1010, 623);
            this.btnConfirm.Name = "btnConfirm";
            this.btnConfirm.Size = new System.Drawing.Size(169, 66);
            this.btnConfirm.TabIndex = 31;
            this.btnConfirm.Text = "確定";
            this.btnConfirm.UseVisualStyleBackColor = false;
            this.btnConfirm.Click += new System.EventHandler(this.btnConfirm_Click);
            // 
            // dgvWheelchair
            // 
            this.dgvWheelchair.AllowUserToAddRows = false;
            this.dgvWheelchair.AllowUserToDeleteRows = false;
            this.dgvWheelchair.AllowUserToOrderColumns = true;
            dataGridViewCellStyle1.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleCenter;
            dataGridViewCellStyle1.BackColor = System.Drawing.SystemColors.Control;
            dataGridViewCellStyle1.Font = new System.Drawing.Font("Microsoft Sans Serif", 24.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            dataGridViewCellStyle1.ForeColor = System.Drawing.SystemColors.WindowText;
            dataGridViewCellStyle1.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle1.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            dataGridViewCellStyle1.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.dgvWheelchair.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle1;
            this.dgvWheelchair.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvWheelchair.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.Selected,
            this.WheelchairName,
            this.WeightDisplay,
            this.OwnerPatient,
            this.Weight,
            this.WheelchairID});
            dataGridViewCellStyle2.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle2.BackColor = System.Drawing.SystemColors.Window;
            dataGridViewCellStyle2.Font = new System.Drawing.Font("Microsoft Sans Serif", 20.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            dataGridViewCellStyle2.ForeColor = System.Drawing.SystemColors.ControlText;
            dataGridViewCellStyle2.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle2.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            dataGridViewCellStyle2.WrapMode = System.Windows.Forms.DataGridViewTriState.False;
            this.dgvWheelchair.DefaultCellStyle = dataGridViewCellStyle2;
            this.dgvWheelchair.Location = new System.Drawing.Point(12, 12);
            this.dgvWheelchair.MultiSelect = false;
            this.dgvWheelchair.Name = "dgvWheelchair";
            this.dgvWheelchair.ReadOnly = true;
            this.dgvWheelchair.RowHeadersVisible = false;
            this.dgvWheelchair.RowTemplate.Height = 50;
            this.dgvWheelchair.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dgvWheelchair.Size = new System.Drawing.Size(1167, 592);
            this.dgvWheelchair.TabIndex = 29;
            this.dgvWheelchair.CellClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.dgvWheelchair_CellClick);
            this.dgvWheelchair.CellPainting += new System.Windows.Forms.DataGridViewCellPaintingEventHandler(this.dgvWheelchair_CellPainting);
            this.dgvWheelchair.CurrentCellDirtyStateChanged += new System.EventHandler(this.dgvWheelchair_CurrentCellDirtyStateChanged);
            // 
            // Selected
            // 
            this.Selected.DataPropertyName = "Selected";
            this.Selected.HeaderText = "選択";
            this.Selected.Name = "Selected";
            this.Selected.ReadOnly = true;
            // 
            // WheelchairName
            // 
            this.WheelchairName.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.Fill;
            this.WheelchairName.DataPropertyName = "WheelchairName";
            this.WheelchairName.HeaderText = "車いす名称列";
            this.WheelchairName.Name = "WheelchairName";
            this.WheelchairName.ReadOnly = true;
            // 
            // WeightDisplay
            // 
            this.WeightDisplay.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.Fill;
            this.WeightDisplay.DataPropertyName = "WeightDisplay";
            this.WeightDisplay.HeaderText = "重量列";
            this.WeightDisplay.Name = "WeightDisplay";
            this.WeightDisplay.ReadOnly = true;
            // 
            // OwnerPatient
            // 
            this.OwnerPatient.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.Fill;
            this.OwnerPatient.DataPropertyName = "OwnerPatient";
            this.OwnerPatient.HeaderText = "所有患者列";
            this.OwnerPatient.Name = "OwnerPatient";
            this.OwnerPatient.ReadOnly = true;
            // 
            // Weight
            // 
            this.Weight.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.Fill;
            this.Weight.DataPropertyName = "Weight";
            this.Weight.HeaderText = "Weight";
            this.Weight.Name = "Weight";
            this.Weight.ReadOnly = true;
            this.Weight.Visible = false;
            // 
            // WheelchairID
            // 
            this.WheelchairID.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.Fill;
            this.WheelchairID.DataPropertyName = "WheelchairID";
            this.WheelchairID.HeaderText = "WheelchairID";
            this.WheelchairID.Name = "WheelchairID";
            this.WheelchairID.ReadOnly = true;
            this.WheelchairID.Visible = false;
            // 
            // FrmModalWheelchair
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1191, 701);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.btnConfirm);
            this.Controls.Add(this.dgvWheelchair);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.MaximizeBox = false;
            this.Name = "FrmModalWheelchair";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "車いす選択モーダル";
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.FrmModalWheelchair_FormClosed);
            ((System.ComponentModel.ISupportInitialize)(this.dgvWheelchair)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Button btnCancel;
        private System.Windows.Forms.Button btnConfirm;
        private System.Windows.Forms.DataGridView dgvWheelchair;
        private System.Windows.Forms.DataGridViewCheckBoxColumn Selected;
        private System.Windows.Forms.DataGridViewTextBoxColumn WheelchairName;
        private System.Windows.Forms.DataGridViewTextBoxColumn WeightDisplay;
        private System.Windows.Forms.DataGridViewTextBoxColumn OwnerPatient;
        private System.Windows.Forms.DataGridViewTextBoxColumn Weight;
        private System.Windows.Forms.DataGridViewTextBoxColumn WheelchairID;
    }
}