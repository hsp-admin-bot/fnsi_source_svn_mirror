namespace NKK.BloodPurify
{
    partial class FrmOrdSelector
    {
        /// <summary>
        /// 必要なデザイナ変数です。
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// 使用中のリソースをすべてクリーンアップします。
        /// </summary>
        /// <param name="disposing">マネージ リソースが破棄される場合 true、破棄されない場合は false です。</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows フォーム デザイナで生成されたコード

        /// <summary>
        /// デザイナ サポートに必要なメソッドです。このメソッドの内容を
        /// コード エディタで変更しないでください。
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FrmOrdSelector));
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle1 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle2 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle9 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle10 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle3 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle4 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle5 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle6 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle7 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle8 = new System.Windows.Forms.DataGridViewCellStyle();
            this.LblKur = new System.Windows.Forms.Label();
            this.LblTreatDate = new System.Windows.Forms.Label();
            this.DataGridView = new System.Windows.Forms.DataGridView();
            this.KurName = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.BedName = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.SameName = new System.Windows.Forms.DataGridViewImageColumn();
            this.PatName = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.TreatState = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.InOutClass = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.OrdNo = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.BtnOk = new NKK.BloodPurify.ExBtnNoFocus();
            this.BtnCancel = new NKK.BloodPurify.ExBtnNoFocus();
            this.BtnKur = new NKK.BloodPurify.ExBtnNoFocus();
            this.BtnMonthCalendar = new NKK.BloodPurify.ExBtnNoFocus();
            ((System.ComponentModel.ISupportInitialize)(this.DataGridView)).BeginInit();
            this.SuspendLayout();
            // 
            // LblKur
            // 
            resources.ApplyResources(this.LblKur, "LblKur");
            this.LblKur.Name = "LblKur";
            // 
            // LblTreatDate
            // 
            resources.ApplyResources(this.LblTreatDate, "LblTreatDate");
            this.LblTreatDate.Name = "LblTreatDate";
            // 
            // DataGridView
            // 
            this.DataGridView.AllowUserToAddRows = false;
            this.DataGridView.AllowUserToDeleteRows = false;
            this.DataGridView.AllowUserToResizeRows = false;
            dataGridViewCellStyle1.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(64)))), ((int)(((byte)(64)))), ((int)(((byte)(64)))));
            dataGridViewCellStyle1.Font = new System.Drawing.Font("Yu Gothic UI", 14.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle1.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle1.SelectionBackColor = System.Drawing.Color.SlateGray;
            dataGridViewCellStyle1.SelectionForeColor = System.Drawing.Color.White;
            this.DataGridView.AlternatingRowsDefaultCellStyle = dataGridViewCellStyle1;
            resources.ApplyResources(this.DataGridView, "DataGridView");
            this.DataGridView.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.Fill;
            this.DataGridView.BackgroundColor = System.Drawing.SystemColors.ButtonShadow;
            this.DataGridView.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.DataGridView.ColumnHeadersBorderStyle = System.Windows.Forms.DataGridViewHeaderBorderStyle.Single;
            dataGridViewCellStyle2.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle2.BackColor = System.Drawing.Color.Black;
            dataGridViewCellStyle2.Font = new System.Drawing.Font("Yu Gothic UI", 14.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle2.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle2.SelectionForeColor = System.Drawing.Color.White;
            this.DataGridView.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle2;
            this.DataGridView.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.DisableResizing;
            this.DataGridView.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.KurName,
            this.BedName,
            this.SameName,
            this.PatName,
            this.TreatState,
            this.InOutClass,
            this.OrdNo});
            this.DataGridView.EnableHeadersVisualStyles = false;
            this.DataGridView.GridColor = System.Drawing.SystemColors.ButtonShadow;
            this.DataGridView.MultiSelect = false;
            this.DataGridView.Name = "DataGridView";
            this.DataGridView.ReadOnly = true;
            this.DataGridView.RowHeadersBorderStyle = System.Windows.Forms.DataGridViewHeaderBorderStyle.Single;
            dataGridViewCellStyle9.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle9.BackColor = System.Drawing.Color.Black;
            dataGridViewCellStyle9.Font = new System.Drawing.Font("Yu Gothic UI", 14.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle9.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle9.SelectionBackColor = System.Drawing.Color.SlateGray;
            dataGridViewCellStyle9.SelectionForeColor = System.Drawing.Color.White;
            this.DataGridView.RowHeadersDefaultCellStyle = dataGridViewCellStyle9;
            this.DataGridView.RowHeadersVisible = false;
            this.DataGridView.RowHeadersWidthSizeMode = System.Windows.Forms.DataGridViewRowHeadersWidthSizeMode.DisableResizing;
            dataGridViewCellStyle10.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle10.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(115)))), ((int)(((byte)(115)))), ((int)(((byte)(115)))));
            dataGridViewCellStyle10.Font = new System.Drawing.Font("Yu Gothic UI", 14.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle10.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle10.SelectionBackColor = System.Drawing.Color.SlateGray;
            dataGridViewCellStyle10.SelectionForeColor = System.Drawing.Color.White;
            this.DataGridView.RowsDefaultCellStyle = dataGridViewCellStyle10;
            this.DataGridView.RowTemplate.Height = 40;
            this.DataGridView.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.DataGridView.StandardTab = true;
            this.DataGridView.CellDoubleClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.DataGridView_CellDoubleClick);
            this.DataGridView.KeyDown += new System.Windows.Forms.KeyEventHandler(this.DataGridView_KeyDown);
            // 
            // KurName
            // 
            dataGridViewCellStyle3.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            this.KurName.DefaultCellStyle = dataGridViewCellStyle3;
            this.KurName.FillWeight = 172F;
            resources.ApplyResources(this.KurName, "KurName");
            this.KurName.Name = "KurName";
            this.KurName.ReadOnly = true;
            this.KurName.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable;
            // 
            // BedName
            // 
            dataGridViewCellStyle4.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            this.BedName.DefaultCellStyle = dataGridViewCellStyle4;
            this.BedName.FillWeight = 230F;
            resources.ApplyResources(this.BedName, "BedName");
            this.BedName.Name = "BedName";
            this.BedName.ReadOnly = true;
            this.BedName.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable;
            // 
            // SameName
            // 
            resources.ApplyResources(this.SameName, "SameName");
            this.SameName.ImageLayout = System.Windows.Forms.DataGridViewImageCellLayout.Zoom;
            this.SameName.Name = "SameName";
            this.SameName.ReadOnly = true;
            this.SameName.Resizable = System.Windows.Forms.DataGridViewTriState.True;
            // 
            // PatName
            // 
            dataGridViewCellStyle5.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            this.PatName.DefaultCellStyle = dataGridViewCellStyle5;
            this.PatName.FillWeight = 230F;
            resources.ApplyResources(this.PatName, "PatName");
            this.PatName.Name = "PatName";
            this.PatName.ReadOnly = true;
            this.PatName.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable;
            // 
            // TreatState
            // 
            dataGridViewCellStyle6.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            this.TreatState.DefaultCellStyle = dataGridViewCellStyle6;
            this.TreatState.FillWeight = 170F;
            resources.ApplyResources(this.TreatState, "TreatState");
            this.TreatState.Name = "TreatState";
            this.TreatState.ReadOnly = true;
            this.TreatState.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable;
            // 
            // InOutClass
            // 
            dataGridViewCellStyle7.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            this.InOutClass.DefaultCellStyle = dataGridViewCellStyle7;
            this.InOutClass.FillWeight = 108F;
            resources.ApplyResources(this.InOutClass, "InOutClass");
            this.InOutClass.Name = "InOutClass";
            this.InOutClass.ReadOnly = true;
            this.InOutClass.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable;
            // 
            // OrdNo
            // 
            dataGridViewCellStyle8.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            this.OrdNo.DefaultCellStyle = dataGridViewCellStyle8;
            this.OrdNo.FillWeight = 2F;
            resources.ApplyResources(this.OrdNo, "OrdNo");
            this.OrdNo.Name = "OrdNo";
            this.OrdNo.ReadOnly = true;
            this.OrdNo.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable;
            // 
            // BtnOk
            // 
            resources.ApplyResources(this.BtnOk, "BtnOk");
            this.BtnOk.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.BtnOk.FlatAppearance.BorderColor = System.Drawing.SystemColors.ButtonShadow;
            this.BtnOk.FlatAppearance.BorderSize = 2;
            this.BtnOk.ForeColor = System.Drawing.Color.White;
            this.BtnOk.Name = "BtnOk";
            this.BtnOk.TabStop = false;
            this.BtnOk.UseVisualStyleBackColor = false;
            this.BtnOk.Click += new System.EventHandler(this.BtnOk_Click);
            // 
            // BtnCancel
            // 
            resources.ApplyResources(this.BtnCancel, "BtnCancel");
            this.BtnCancel.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.BtnCancel.FlatAppearance.BorderColor = System.Drawing.SystemColors.ButtonShadow;
            this.BtnCancel.FlatAppearance.BorderSize = 2;
            this.BtnCancel.ForeColor = System.Drawing.Color.White;
            this.BtnCancel.Name = "BtnCancel";
            this.BtnCancel.TabStop = false;
            this.BtnCancel.UseVisualStyleBackColor = false;
            this.BtnCancel.Click += new System.EventHandler(this.BtnCancel_Click);
            // 
            // BtnKur
            // 
            resources.ApplyResources(this.BtnKur, "BtnKur");
            this.BtnKur.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.BtnKur.FlatAppearance.BorderColor = System.Drawing.SystemColors.ButtonShadow;
            this.BtnKur.FlatAppearance.BorderSize = 2;
            this.BtnKur.ForeColor = System.Drawing.Color.White;
            this.BtnKur.Name = "BtnKur";
            this.BtnKur.TabStop = false;
            this.BtnKur.Tag = "999999";
            this.BtnKur.UseVisualStyleBackColor = false;
            this.BtnKur.Click += new System.EventHandler(this.BtnKur_Click);
            // 
            // BtnMonthCalendar
            // 
            resources.ApplyResources(this.BtnMonthCalendar, "BtnMonthCalendar");
            this.BtnMonthCalendar.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.BtnMonthCalendar.FlatAppearance.BorderColor = System.Drawing.SystemColors.ButtonShadow;
            this.BtnMonthCalendar.FlatAppearance.BorderSize = 2;
            this.BtnMonthCalendar.ForeColor = System.Drawing.Color.White;
            this.BtnMonthCalendar.Name = "BtnMonthCalendar";
            this.BtnMonthCalendar.TabStop = false;
            this.BtnMonthCalendar.UseVisualStyleBackColor = false;
            this.BtnMonthCalendar.Click += new System.EventHandler(this.BtnMonthCalendar_Click);
            // 
            // FrmOrdSelector
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            resources.ApplyResources(this, "$this");
            this.Controls.Add(this.BtnMonthCalendar);
            this.Controls.Add(this.BtnKur);
            this.Controls.Add(this.BtnCancel);
            this.Controls.Add(this.BtnOk);
            this.Controls.Add(this.DataGridView);
            this.Controls.Add(this.LblTreatDate);
            this.Controls.Add(this.LblKur);
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "FrmOrdSelector";
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.FrmOrdSelector_FormClosed);
            this.Load += new System.EventHandler(this.FrmOrdSelector_Load);
            this.Controls.SetChildIndex(this.LblKur, 0);
            this.Controls.SetChildIndex(this.LblTreatDate, 0);
            this.Controls.SetChildIndex(this.DataGridView, 0);
            this.Controls.SetChildIndex(this.BtnOk, 0);
            this.Controls.SetChildIndex(this.BtnCancel, 0);
            this.Controls.SetChildIndex(this.BtnKur, 0);
            this.Controls.SetChildIndex(this.BtnMonthCalendar, 0);
            ((System.ComponentModel.ISupportInitialize)(this.DataGridView)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        protected System.Windows.Forms.Label LblKur;
        protected System.Windows.Forms.Label LblTreatDate;
        private System.Windows.Forms.DataGridView DataGridView;
        private ExBtnNoFocus BtnMonthCalendar;
        private ExBtnNoFocus BtnKur;
        private ExBtnNoFocus BtnOk;
        private ExBtnNoFocus BtnCancel;
        private System.Windows.Forms.DataGridViewTextBoxColumn KurName;
        private System.Windows.Forms.DataGridViewTextBoxColumn BedName;
        private System.Windows.Forms.DataGridViewImageColumn SameName;
        private System.Windows.Forms.DataGridViewTextBoxColumn PatName;
        private System.Windows.Forms.DataGridViewTextBoxColumn TreatState;
        private System.Windows.Forms.DataGridViewTextBoxColumn InOutClass;
        private System.Windows.Forms.DataGridViewTextBoxColumn OrdNo;
    }
}