namespace NKKPrintServerTool
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
            this.btnGoWeightMeasurementScreen = new System.Windows.Forms.Button();
            this.dgvPatientList = new System.Windows.Forms.DataGridView();
            this.Selected = new System.Windows.Forms.DataGridViewCheckBoxColumn();
            this.Patient = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.PatientName = new System.Windows.Forms.DataGridViewTextBoxColumn();
            ((System.ComponentModel.ISupportInitialize)(this.dgvPatientList)).BeginInit();
            this.SuspendLayout();
            // 
            // btnGoWeightMeasurementScreen
            // 
            this.btnGoWeightMeasurementScreen.BackColor = System.Drawing.Color.Transparent;
            this.btnGoWeightMeasurementScreen.DialogResult = System.Windows.Forms.DialogResult.OK;
            this.btnGoWeightMeasurementScreen.FlatAppearance.BorderColor = System.Drawing.Color.White;
            this.btnGoWeightMeasurementScreen.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnGoWeightMeasurementScreen.Font = new System.Drawing.Font("Microsoft Sans Serif", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnGoWeightMeasurementScreen.ForeColor = System.Drawing.Color.Black;
            this.btnGoWeightMeasurementScreen.Location = new System.Drawing.Point(636, 142);
            this.btnGoWeightMeasurementScreen.Name = "btnGoWeightMeasurementScreen";
            this.btnGoWeightMeasurementScreen.Size = new System.Drawing.Size(122, 31);
            this.btnGoWeightMeasurementScreen.TabIndex = 32;
            this.btnGoWeightMeasurementScreen.UseVisualStyleBackColor = false;
            this.btnGoWeightMeasurementScreen.Click += new System.EventHandler(this.btnGoWeightMeasurementScreen_Click);
            // 
            // dgvPatientList
            // 
            this.dgvPatientList.AllowUserToAddRows = false;
            this.dgvPatientList.AllowUserToDeleteRows = false;
            dataGridViewCellStyle1.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle1.BackColor = System.Drawing.SystemColors.Control;
            dataGridViewCellStyle1.Font = new System.Drawing.Font("Microsoft Sans Serif", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            dataGridViewCellStyle1.ForeColor = System.Drawing.SystemColors.WindowText;
            dataGridViewCellStyle1.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle1.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            dataGridViewCellStyle1.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.dgvPatientList.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle1;
            this.dgvPatientList.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvPatientList.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.Selected,
            this.Patient,
            this.PatientName});
            dataGridViewCellStyle2.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle2.BackColor = System.Drawing.SystemColors.Window;
            dataGridViewCellStyle2.Font = new System.Drawing.Font("Microsoft Sans Serif", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            dataGridViewCellStyle2.ForeColor = System.Drawing.SystemColors.ControlText;
            dataGridViewCellStyle2.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle2.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            dataGridViewCellStyle2.WrapMode = System.Windows.Forms.DataGridViewTriState.False;
            this.dgvPatientList.DefaultCellStyle = dataGridViewCellStyle2;
            this.dgvPatientList.Location = new System.Drawing.Point(0, 0);
            this.dgvPatientList.MultiSelect = false;
            this.dgvPatientList.Name = "dgvPatientList";
            this.dgvPatientList.ReadOnly = true;
            this.dgvPatientList.RowHeadersVisible = false;
            this.dgvPatientList.RowTemplate.Height = 25;
            this.dgvPatientList.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dgvPatientList.Size = new System.Drawing.Size(770, 136);
            this.dgvPatientList.TabIndex = 28;
            this.dgvPatientList.CellClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.dgvPatientList_CellClick);
            // 
            // Selected
            // 
            this.Selected.DataPropertyName = "Selected";
            this.Selected.FillWeight = 50F;
            this.Selected.HeaderText = "選択";
            this.Selected.Name = "Selected";
            this.Selected.ReadOnly = true;
            // 
            // Patient
            // 
            this.Patient.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.Fill;
            this.Patient.DataPropertyName = "Patient";
            this.Patient.FillWeight = 50F;
            this.Patient.HeaderText = "プリンター名";
            this.Patient.Name = "Patient";
            this.Patient.ReadOnly = true;
            // 
            // PatientName
            // 
            this.PatientName.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.Fill;
            this.PatientName.DataPropertyName = "PatientName";
            this.PatientName.HeaderText = "表示プリンタ名";
            this.PatientName.Name = "PatientName";
            this.PatientName.ReadOnly = true;
            // 
            // FrmModalBed
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(770, 178);
            this.Controls.Add(this.btnGoWeightMeasurementScreen);
            this.Controls.Add(this.dgvPatientList);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.MaximizeBox = false;
            this.Name = "FrmModalBed";
            this.ShowIcon = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "プリンター一覧";
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.FrmModalBed_FormClosed);
            ((System.ComponentModel.ISupportInitialize)(this.dgvPatientList)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Button btnGoWeightMeasurementScreen;
        private System.Windows.Forms.DataGridView dgvPatientList;
        private System.Windows.Forms.DataGridViewCheckBoxColumn Selected;
        private System.Windows.Forms.DataGridViewTextBoxColumn Patient;
        private System.Windows.Forms.DataGridViewTextBoxColumn PatientName;
    }
}