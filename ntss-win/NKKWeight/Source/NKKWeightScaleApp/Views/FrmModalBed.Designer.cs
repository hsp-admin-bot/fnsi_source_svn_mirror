namespace NKKWeightScaleApp.Views
{
    partial class FrmModalBed
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
            this.dgvBed = new System.Windows.Forms.DataGridView();
            this.Selected = new System.Windows.Forms.DataGridViewCheckBoxColumn();
            this.BedName = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.ConnectedDevice = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.BedID = new System.Windows.Forms.DataGridViewTextBoxColumn();
            ((System.ComponentModel.ISupportInitialize)(this.dgvBed)).BeginInit();
            this.SuspendLayout();
            // 
            // btnCancel
            // 
            this.btnCancel.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnCancel.Font = new System.Drawing.Font("Microsoft Sans Serif", 24.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnCancel.Location = new System.Drawing.Point(12, 516);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(161, 66);
            this.btnCancel.TabIndex = 27;
            this.btnCancel.Text = "キャンセル";
            this.btnCancel.UseVisualStyleBackColor = true;
            this.btnCancel.Click += new System.EventHandler(this.btnCancel_Click);
            // 
            // btnConfirm
            // 
            this.btnConfirm.BackColor = System.Drawing.Color.Goldenrod;
            this.btnConfirm.Font = new System.Drawing.Font("Microsoft Sans Serif", 24.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnConfirm.ForeColor = System.Drawing.Color.White;
            this.btnConfirm.Location = new System.Drawing.Point(740, 516);
            this.btnConfirm.Name = "btnConfirm";
            this.btnConfirm.Size = new System.Drawing.Size(161, 66);
            this.btnConfirm.TabIndex = 28;
            this.btnConfirm.Text = "確定";
            this.btnConfirm.UseVisualStyleBackColor = false;
            this.btnConfirm.Click += new System.EventHandler(this.btnConfirm_Click);
            // 
            // dgvBed
            // 
            this.dgvBed.AllowUserToAddRows = false;
            this.dgvBed.AllowUserToDeleteRows = false;
            this.dgvBed.AllowUserToOrderColumns = true;
            dataGridViewCellStyle1.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleCenter;
            dataGridViewCellStyle1.BackColor = System.Drawing.SystemColors.Control;
            dataGridViewCellStyle1.Font = new System.Drawing.Font("Microsoft Sans Serif", 24.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            dataGridViewCellStyle1.ForeColor = System.Drawing.SystemColors.WindowText;
            dataGridViewCellStyle1.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle1.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            dataGridViewCellStyle1.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.dgvBed.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle1;
            this.dgvBed.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvBed.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.Selected,
            this.BedName,
            this.ConnectedDevice,
            this.BedID});
            dataGridViewCellStyle2.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle2.BackColor = System.Drawing.SystemColors.Window;
            dataGridViewCellStyle2.Font = new System.Drawing.Font("Microsoft Sans Serif", 20.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            dataGridViewCellStyle2.ForeColor = System.Drawing.SystemColors.ControlText;
            dataGridViewCellStyle2.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle2.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            dataGridViewCellStyle2.WrapMode = System.Windows.Forms.DataGridViewTriState.False;
            this.dgvBed.DefaultCellStyle = dataGridViewCellStyle2;
            this.dgvBed.Location = new System.Drawing.Point(12, 10);
            this.dgvBed.MultiSelect = false;
            this.dgvBed.Name = "dgvBed";
            this.dgvBed.ReadOnly = true;
            this.dgvBed.RowHeadersVisible = false;
            this.dgvBed.RowTemplate.Height = 50;
            this.dgvBed.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dgvBed.Size = new System.Drawing.Size(889, 500);
            this.dgvBed.TabIndex = 26;
            this.dgvBed.CellClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.dgvBed_CellClick);
            this.dgvBed.CellPainting += new System.Windows.Forms.DataGridViewCellPaintingEventHandler(this.dgvBed_CellPainting);
            this.dgvBed.CurrentCellDirtyStateChanged += new System.EventHandler(this.dgvBed_CurrentCellDirtyStateChanged);
            // 
            // Selected
            // 
            this.Selected.DataPropertyName = "Selected";
            this.Selected.HeaderText = "選択";
            this.Selected.Name = "Selected";
            this.Selected.ReadOnly = true;
            // 
            // BedName
            // 
            this.BedName.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.Fill;
            this.BedName.DataPropertyName = "BedName";
            this.BedName.HeaderText = "ベッド名称";
            this.BedName.Name = "BedName";
            this.BedName.ReadOnly = true;
            // 
            // ConnectedDevice
            // 
            this.ConnectedDevice.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.Fill;
            this.ConnectedDevice.DataPropertyName = "ConnectedDevice";
            this.ConnectedDevice.HeaderText = "接続装置";
            this.ConnectedDevice.Name = "ConnectedDevice";
            this.ConnectedDevice.ReadOnly = true;
            // 
            // BedID
            // 
            this.BedID.DataPropertyName = "BedID";
            this.BedID.HeaderText = "BedID";
            this.BedID.Name = "BedID";
            this.BedID.ReadOnly = true;
            this.BedID.Visible = false;
            // 
            // FrmModalBed
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(913, 587);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.btnConfirm);
            this.Controls.Add(this.dgvBed);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.MaximizeBox = false;
            this.Name = "FrmModalBed";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "ベッド選択モーダル";
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.FrmModalBed_FormClosed);
            ((System.ComponentModel.ISupportInitialize)(this.dgvBed)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Button btnCancel;
        private System.Windows.Forms.Button btnConfirm;
        private System.Windows.Forms.DataGridView dgvBed;
        private System.Windows.Forms.DataGridViewCheckBoxColumn Selected;
        private System.Windows.Forms.DataGridViewTextBoxColumn BedName;
        private System.Windows.Forms.DataGridViewTextBoxColumn ConnectedDevice;
        private System.Windows.Forms.DataGridViewTextBoxColumn BedID;
    }
}