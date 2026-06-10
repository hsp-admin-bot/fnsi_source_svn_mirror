namespace NKK.BloodPurify
{
    partial class FrmMonitoring
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
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FrmMonitoring));
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle1 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle2 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle6 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle7 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle8 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle3 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle4 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle5 = new System.Windows.Forms.DataGridViewCellStyle();
            this.TimerUpload = new System.Windows.Forms.Timer(this.components);
            this.LblOnOff = new System.Windows.Forms.Label();
            this.DataGridView = new System.Windows.Forms.DataGridView();
            this.DataName = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.DataValue = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.DataUnit = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.BtnEnd = new NKK.BloodPurify.ExBtnNoFocus();
            this.LblDevLamp = new System.Windows.Forms.Label();
            this.LblDbLamp = new System.Windows.Forms.Label();
            this.LblDevTitle = new System.Windows.Forms.Label();
            this.LblDevStatus = new System.Windows.Forms.Label();
            this.LblDbTitle = new System.Windows.Forms.Label();
            this.LblDbStatus = new System.Windows.Forms.Label();
            this.LblTreatStatus = new System.Windows.Forms.Label();
            this.lblID = new System.Windows.Forms.Label();
            this.lblKur = new System.Windows.Forms.Label();
            this.LblDbErrorDetail = new System.Windows.Forms.Label();
            ((System.ComponentModel.ISupportInitialize)(this.DataGridView)).BeginInit();
            this.SuspendLayout();
            // 
            // TimerUpload
            // 
            this.TimerUpload.Interval = 60000;
            this.TimerUpload.Tick += new System.EventHandler(this.TimerUpload_Tick);
            // 
            // LblOnOff
            // 
            this.LblOnOff.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(102)))), ((int)(((byte)(204)))));
            this.LblOnOff.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            resources.ApplyResources(this.LblOnOff, "LblOnOff");
            this.LblOnOff.ForeColor = System.Drawing.Color.White;
            this.LblOnOff.Name = "LblOnOff";
            this.LblOnOff.Click += new System.EventHandler(this.LblOnOff_Click);
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
            dataGridViewCellStyle2.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleCenter;
            dataGridViewCellStyle2.BackColor = System.Drawing.Color.Black;
            dataGridViewCellStyle2.Font = new System.Drawing.Font("Yu Gothic UI", 14.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle2.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle2.SelectionForeColor = System.Drawing.Color.White;
            this.DataGridView.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle2;
            this.DataGridView.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.DisableResizing;
            this.DataGridView.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.DataName,
            this.DataValue,
            this.DataUnit});
            dataGridViewCellStyle6.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle6.BackColor = System.Drawing.SystemColors.Window;
            dataGridViewCellStyle6.Font = new System.Drawing.Font("Yu Gothic UI", 14.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle6.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle6.SelectionBackColor = System.Drawing.Color.SlateGray;
            dataGridViewCellStyle6.SelectionForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle6.WrapMode = System.Windows.Forms.DataGridViewTriState.False;
            this.DataGridView.DefaultCellStyle = dataGridViewCellStyle6;
            this.DataGridView.EnableHeadersVisualStyles = false;
            this.DataGridView.GridColor = System.Drawing.SystemColors.ButtonShadow;
            this.DataGridView.MultiSelect = false;
            this.DataGridView.Name = "DataGridView";
            this.DataGridView.ReadOnly = true;
            this.DataGridView.RowHeadersBorderStyle = System.Windows.Forms.DataGridViewHeaderBorderStyle.Single;
            dataGridViewCellStyle7.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle7.BackColor = System.Drawing.Color.Black;
            dataGridViewCellStyle7.Font = new System.Drawing.Font("Yu Gothic UI", 14.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle7.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle7.SelectionBackColor = System.Drawing.Color.SlateGray;
            dataGridViewCellStyle7.SelectionForeColor = System.Drawing.Color.White;
            this.DataGridView.RowHeadersDefaultCellStyle = dataGridViewCellStyle7;
            this.DataGridView.RowHeadersVisible = false;
            this.DataGridView.RowHeadersWidthSizeMode = System.Windows.Forms.DataGridViewRowHeadersWidthSizeMode.DisableResizing;
            dataGridViewCellStyle8.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle8.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(115)))), ((int)(((byte)(115)))), ((int)(((byte)(115)))));
            dataGridViewCellStyle8.Font = new System.Drawing.Font("Yu Gothic UI", 14.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle8.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle8.SelectionBackColor = System.Drawing.Color.SlateGray;
            dataGridViewCellStyle8.SelectionForeColor = System.Drawing.Color.White;
            this.DataGridView.RowsDefaultCellStyle = dataGridViewCellStyle8;
            this.DataGridView.RowTemplate.Height = 40;
            this.DataGridView.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.DataGridView.StandardTab = true;
            this.DataGridView.VirtualMode = true;
            this.DataGridView.CellValueNeeded += new System.Windows.Forms.DataGridViewCellValueEventHandler(this.DataGridView_CellValueNeeded);
            this.DataGridView.KeyDown += new System.Windows.Forms.KeyEventHandler(this.DataGridView_KeyDown);
            // 
            // DataName
            // 
            this.DataName.DataPropertyName = "DataName";
            dataGridViewCellStyle3.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle3.Font = new System.Drawing.Font("Yu Gothic UI", 14.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.DataName.DefaultCellStyle = dataGridViewCellStyle3;
            this.DataName.FillWeight = 400F;
            resources.ApplyResources(this.DataName, "DataName");
            this.DataName.Name = "DataName";
            this.DataName.ReadOnly = true;
            this.DataName.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable;
            // 
            // DataValue
            // 
            this.DataValue.DataPropertyName = "DataValue";
            dataGridViewCellStyle4.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleRight;
            dataGridViewCellStyle4.Font = new System.Drawing.Font("Yu Gothic UI", 14.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.DataValue.DefaultCellStyle = dataGridViewCellStyle4;
            this.DataValue.FillWeight = 212F;
            resources.ApplyResources(this.DataValue, "DataValue");
            this.DataValue.Name = "DataValue";
            this.DataValue.ReadOnly = true;
            this.DataValue.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable;
            // 
            // DataUnit
            // 
            this.DataUnit.DataPropertyName = "DataUnit";
            dataGridViewCellStyle5.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle5.Font = new System.Drawing.Font("Yu Gothic UI", 14.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.DataUnit.DefaultCellStyle = dataGridViewCellStyle5;
            this.DataUnit.FillWeight = 400F;
            resources.ApplyResources(this.DataUnit, "DataUnit");
            this.DataUnit.Name = "DataUnit";
            this.DataUnit.ReadOnly = true;
            this.DataUnit.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable;
            // 
            // BtnEnd
            // 
            resources.ApplyResources(this.BtnEnd, "BtnEnd");
            this.BtnEnd.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.BtnEnd.FlatAppearance.BorderColor = System.Drawing.SystemColors.ButtonShadow;
            this.BtnEnd.FlatAppearance.BorderSize = 2;
            this.BtnEnd.ForeColor = System.Drawing.Color.White;
            this.BtnEnd.Name = "BtnEnd";
            this.BtnEnd.TabStop = false;
            this.BtnEnd.UseVisualStyleBackColor = false;
            this.BtnEnd.Click += new System.EventHandler(this.BtnEnd_Click);
            // 
            // LblDevLamp
            // 
            resources.ApplyResources(this.LblDevLamp, "LblDevLamp");
            this.LblDevLamp.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(102)))), ((int)(((byte)(204)))));
            this.LblDevLamp.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblDevLamp.ForeColor = System.Drawing.Color.White;
            this.LblDevLamp.Name = "LblDevLamp";
            // 
            // LblDbLamp
            // 
            resources.ApplyResources(this.LblDbLamp, "LblDbLamp");
            this.LblDbLamp.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(102)))), ((int)(((byte)(204)))));
            this.LblDbLamp.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblDbLamp.ForeColor = System.Drawing.Color.White;
            this.LblDbLamp.Name = "LblDbLamp";
            // 
            // LblDevTitle
            // 
            resources.ApplyResources(this.LblDevTitle, "LblDevTitle");
            this.LblDevTitle.Name = "LblDevTitle";
            // 
            // LblDevStatus
            // 
            resources.ApplyResources(this.LblDevStatus, "LblDevStatus");
            this.LblDevStatus.Name = "LblDevStatus";
            // 
            // LblDbTitle
            // 
            resources.ApplyResources(this.LblDbTitle, "LblDbTitle");
            this.LblDbTitle.Name = "LblDbTitle";
            // 
            // LblDbStatus
            // 
            resources.ApplyResources(this.LblDbStatus, "LblDbStatus");
            this.LblDbStatus.Name = "LblDbStatus";
            // 
            // LblTreatStatus
            // 
            resources.ApplyResources(this.LblTreatStatus, "LblTreatStatus");
            this.LblTreatStatus.BackColor = System.Drawing.Color.Olive;
            this.LblTreatStatus.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.LblTreatStatus.ForeColor = System.Drawing.Color.White;
            this.LblTreatStatus.Name = "LblTreatStatus";
            // 
            // lblID
            // 
            resources.ApplyResources(this.lblID, "lblID");
            this.lblID.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.lblID.Name = "lblID";
            // 
            // lblKur
            // 
            resources.ApplyResources(this.lblKur, "lblKur");
            this.lblKur.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.lblKur.Name = "lblKur";
            // 
            // LblDbErrorDetail
            // 
            resources.ApplyResources(this.LblDbErrorDetail, "LblDbErrorDetail");
            this.LblDbErrorDetail.AutoEllipsis = true;
            this.LblDbErrorDetail.ForeColor = System.Drawing.Color.Red;
            this.LblDbErrorDetail.Name = "LblDbErrorDetail";
            // 
            // FrmMonitoring
            // 
            resources.ApplyResources(this, "$this");
            this.Controls.Add(this.LblDbErrorDetail);
            this.Controls.Add(this.lblKur);
            this.Controls.Add(this.lblID);
            this.Controls.Add(this.LblTreatStatus);
            this.Controls.Add(this.LblDbStatus);
            this.Controls.Add(this.LblDbTitle);
            this.Controls.Add(this.LblDevStatus);
            this.Controls.Add(this.LblDevTitle);
            this.Controls.Add(this.LblDbLamp);
            this.Controls.Add(this.LblDevLamp);
            this.Controls.Add(this.BtnEnd);
            this.Controls.Add(this.LblOnOff);
            this.Controls.Add(this.DataGridView);
            this.Name = "FrmMonitoring";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.FrmMonitoring_FormClosing);
            this.Load += new System.EventHandler(this.FrmMonitoring_Load);
            this.Controls.SetChildIndex(this.DataGridView, 0);
            this.Controls.SetChildIndex(this.LblOnOff, 0);
            this.Controls.SetChildIndex(this.BtnEnd, 0);
            this.Controls.SetChildIndex(this.LblDevLamp, 0);
            this.Controls.SetChildIndex(this.LblDbLamp, 0);
            this.Controls.SetChildIndex(this.LblDevTitle, 0);
            this.Controls.SetChildIndex(this.LblDevStatus, 0);
            this.Controls.SetChildIndex(this.LblDbTitle, 0);
            this.Controls.SetChildIndex(this.LblDbStatus, 0);
            this.Controls.SetChildIndex(this.LblTreatStatus, 0);
            this.Controls.SetChildIndex(this.lblID, 0);
            this.Controls.SetChildIndex(this.lblKur, 0);
            this.Controls.SetChildIndex(this.LblDbErrorDetail, 0);
            ((System.ComponentModel.ISupportInitialize)(this.DataGridView)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion
        private System.Windows.Forms.Label LblOnOff;
        private System.Windows.Forms.DataGridView DataGridView;
        private ExBtnNoFocus BtnEnd;
        private System.Windows.Forms.Label LblDevLamp;
        private System.Windows.Forms.Label LblDbLamp;
        private System.Windows.Forms.Label LblDevTitle;
        private System.Windows.Forms.Label LblDevStatus;
        private System.Windows.Forms.Label LblDbTitle;
        private System.Windows.Forms.Label LblDbStatus;
        protected System.Windows.Forms.Label LblTreatStatus;
        private System.Windows.Forms.DataGridViewTextBoxColumn DataName;
        private System.Windows.Forms.DataGridViewTextBoxColumn DataValue;
        private System.Windows.Forms.DataGridViewTextBoxColumn DataUnit;
        private System.Windows.Forms.Timer TimerUpload;
        private System.Windows.Forms.Label lblID;
        private System.Windows.Forms.Label lblKur;
        private System.Windows.Forms.Label LblDbErrorDetail;
    }
}
