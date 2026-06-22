namespace NKK.BloodPurify
{
    partial class FrmDeviceSelector
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

        //#region Windows フォーム デザイナで生成されたコード

        /// <summary>
        /// デザイナ サポートに必要なメソッドです。このメソッドの内容を
        /// コード エディタで変更しないでください。
        /// </summary>
        private void InitializeComponent()
        {
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle1 = new System.Windows.Forms.DataGridViewCellStyle();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FrmDeviceSelector));
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle2 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle3 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle4 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle5 = new System.Windows.Forms.DataGridViewCellStyle();
            this.DataGridView = new System.Windows.Forms.DataGridView();
            this.DeviceModel = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.IdName = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.IpAddr = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.PortNo = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.BtnStart = new NKK.BloodPurify.ExBtnNoFocus();
            this.BtnEnd = new NKK.BloodPurify.ExBtnNoFocus();
            this.BtnUpload = new NKK.BloodPurify.ExBtnNoFocus();
            this.LblOnOff = new System.Windows.Forms.Label();
            ((System.ComponentModel.ISupportInitialize)(this.DataGridView)).BeginInit();
            this.SuspendLayout();
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
            dataGridViewCellStyle2.Font = new System.Drawing.Font("Yu Gothic UI", 14.25F);
            dataGridViewCellStyle2.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle2.SelectionForeColor = System.Drawing.Color.White;
            this.DataGridView.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle2;
            this.DataGridView.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.DisableResizing;
            this.DataGridView.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.DeviceModel,
            this.IdName,
            this.IpAddr,
            this.PortNo});
            dataGridViewCellStyle3.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle3.BackColor = System.Drawing.SystemColors.Window;
            dataGridViewCellStyle3.Font = new System.Drawing.Font("Yu Gothic UI", 14.25F);
            dataGridViewCellStyle3.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle3.SelectionBackColor = System.Drawing.Color.SlateGray;
            dataGridViewCellStyle3.SelectionForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle3.WrapMode = System.Windows.Forms.DataGridViewTriState.False;
            this.DataGridView.DefaultCellStyle = dataGridViewCellStyle3;
            this.DataGridView.EnableHeadersVisualStyles = false;
            this.DataGridView.GridColor = System.Drawing.SystemColors.ButtonShadow;
            this.DataGridView.MultiSelect = false;
            this.DataGridView.Name = "DataGridView";
            this.DataGridView.ReadOnly = true;
            this.DataGridView.RowHeadersBorderStyle = System.Windows.Forms.DataGridViewHeaderBorderStyle.Single;
            dataGridViewCellStyle4.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle4.BackColor = System.Drawing.Color.Black;
            dataGridViewCellStyle4.Font = new System.Drawing.Font("Yu Gothic UI", 14.25F);
            dataGridViewCellStyle4.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle4.SelectionBackColor = System.Drawing.Color.SlateGray;
            dataGridViewCellStyle4.SelectionForeColor = System.Drawing.Color.White;
            this.DataGridView.RowHeadersDefaultCellStyle = dataGridViewCellStyle4;
            this.DataGridView.RowHeadersVisible = false;
            this.DataGridView.RowHeadersWidthSizeMode = System.Windows.Forms.DataGridViewRowHeadersWidthSizeMode.DisableResizing;
            dataGridViewCellStyle5.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle5.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(115)))), ((int)(((byte)(115)))), ((int)(((byte)(115)))));
            dataGridViewCellStyle5.Font = new System.Drawing.Font("Yu Gothic UI", 14.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle5.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle5.SelectionBackColor = System.Drawing.Color.SlateGray;
            dataGridViewCellStyle5.SelectionForeColor = System.Drawing.Color.White;
            this.DataGridView.RowsDefaultCellStyle = dataGridViewCellStyle5;
            this.DataGridView.RowTemplate.Height = 40;
            this.DataGridView.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.DataGridView.StandardTab = true;
            this.DataGridView.CellDoubleClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.DataGridView_CellDoubleClick);
            this.DataGridView.KeyDown += new System.Windows.Forms.KeyEventHandler(this.DataGridView_KeyDown);
            // 
            // DeviceModel
            // 
            this.DeviceModel.FillWeight = 150F;
            resources.ApplyResources(this.DeviceModel, "DeviceModel");
            this.DeviceModel.Name = "DeviceModel";
            this.DeviceModel.ReadOnly = true;
            this.DeviceModel.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable;
            // 
            // IdName
            // 
            this.IdName.FillWeight = 350F;
            resources.ApplyResources(this.IdName, "IdName");
            this.IdName.Name = "IdName";
            this.IdName.ReadOnly = true;
            this.IdName.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable;
            // 
            // IpAddr
            // 
            this.IpAddr.FillWeight = 360F;
            resources.ApplyResources(this.IpAddr, "IpAddr");
            this.IpAddr.Name = "IpAddr";
            this.IpAddr.ReadOnly = true;
            this.IpAddr.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable;
            // 
            // PortNo
            // 
            this.PortNo.FillWeight = 140F;
            resources.ApplyResources(this.PortNo, "PortNo");
            this.PortNo.Name = "PortNo";
            this.PortNo.ReadOnly = true;
            this.PortNo.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable;
            // 
            // BtnStart
            // 
            resources.ApplyResources(this.BtnStart, "BtnStart");
            this.BtnStart.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.BtnStart.FlatAppearance.BorderColor = System.Drawing.SystemColors.ButtonShadow;
            this.BtnStart.FlatAppearance.BorderSize = 2;
            this.BtnStart.ForeColor = System.Drawing.Color.White;
            this.BtnStart.Name = "BtnStart";
            this.BtnStart.TabStop = false;
            this.BtnStart.UseVisualStyleBackColor = false;
            this.BtnStart.Click += new System.EventHandler(this.BtnStart_Click);
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
            // BtnUpload
            // 
            resources.ApplyResources(this.BtnUpload, "BtnUpload");
            this.BtnUpload.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.BtnUpload.FlatAppearance.BorderColor = System.Drawing.SystemColors.ButtonShadow;
            this.BtnUpload.FlatAppearance.BorderSize = 2;
            this.BtnUpload.ForeColor = System.Drawing.Color.White;
            this.BtnUpload.Name = "BtnUpload";
            this.BtnUpload.TabStop = false;
            this.BtnUpload.UseVisualStyleBackColor = false;
            this.BtnUpload.Click += new System.EventHandler(this.BtnUpload_Click);
            // 
            // LblOnOff
            // 
            this.LblOnOff.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(102)))), ((int)(((byte)(204)))));
            this.LblOnOff.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            resources.ApplyResources(this.LblOnOff, "LblOnOff");
            this.LblOnOff.ForeColor = System.Drawing.Color.White;
            this.LblOnOff.Name = "LblOnOff";
            // 
            // FrmDeviceSelector
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            resources.ApplyResources(this, "$this");
            this.Controls.Add(this.LblOnOff);
            this.Controls.Add(this.BtnUpload);
            this.Controls.Add(this.BtnEnd);
            this.Controls.Add(this.BtnStart);
            this.Controls.Add(this.DataGridView);
            this.Name = "FrmDeviceSelector";
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.FrmDeviceSelector_FormClosed);
            this.Load += new System.EventHandler(this.FrmDeviceSelector_Load);
            this.Controls.SetChildIndex(this.DataGridView, 0);
            this.Controls.SetChildIndex(this.BtnStart, 0);
            this.Controls.SetChildIndex(this.BtnEnd, 0);
            this.Controls.SetChildIndex(this.BtnUpload, 0);
            this.Controls.SetChildIndex(this.LblOnOff, 0);
            ((System.ComponentModel.ISupportInitialize)(this.DataGridView)).EndInit();
            this.ResumeLayout(false);

        }

        //#endregion
        private System.Windows.Forms.DataGridView DataGridView;
        private ExBtnNoFocus BtnStart;
        private ExBtnNoFocus BtnEnd;
        private ExBtnNoFocus BtnUpload;
        private System.Windows.Forms.Label LblOnOff;
        private System.Windows.Forms.DataGridViewTextBoxColumn DeviceModel;
        private System.Windows.Forms.DataGridViewTextBoxColumn IdName;
        private System.Windows.Forms.DataGridViewTextBoxColumn IpAddr;
        private System.Windows.Forms.DataGridViewTextBoxColumn PortNo;
    }
}