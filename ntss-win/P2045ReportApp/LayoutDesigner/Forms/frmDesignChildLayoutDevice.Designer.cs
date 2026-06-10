namespace LayoutDesigner
{
    partial class frmDesignChildLayoutDevice
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
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle3 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle4 = new System.Windows.Forms.DataGridViewCellStyle();
            this.splGroup = new System.Windows.Forms.SplitContainer();
            this.dgvDeviceList = new System.Windows.Forms.DataGridView();
            this.dgvGroupDetail = new System.Windows.Forms.DataGridView();
            this.Code = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.ItemValue = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.DisplayValue = new System.Windows.Forms.DataGridViewComboBoxColumn();
            ((System.ComponentModel.ISupportInitialize)(this.splGroup)).BeginInit();
            this.splGroup.Panel1.SuspendLayout();
            this.splGroup.Panel2.SuspendLayout();
            this.splGroup.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgvDeviceList)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.dgvGroupDetail)).BeginInit();
            this.SuspendLayout();
            // 
            // btnStop
            // 
            this.btnStop.Location = new System.Drawing.Point(127, 525);
            // 
            // btnTop
            // 
            this.btnTop.Location = new System.Drawing.Point(0, 0);
            // 
            // btnFocusControl
            // 
            this.btnFocusControl.Location = new System.Drawing.Point(127, 0);
            // 
            // winlblTitle
            // 
            this.winlblTitle.Size = new System.Drawing.Size(274, 0);
            // 
            // splGroup
            // 
            this.splGroup.BackColor = System.Drawing.Color.LightSlateGray;
            this.splGroup.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splGroup.Location = new System.Drawing.Point(0, 0);
            this.splGroup.Name = "splGroup";
            this.splGroup.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // splGroup.Panel1
            // 
            this.splGroup.Panel1.Controls.Add(this.dgvDeviceList);
            // 
            // splGroup.Panel2
            // 
            this.splGroup.Panel2.Controls.Add(this.dgvGroupDetail);
            this.splGroup.Size = new System.Drawing.Size(274, 520);
            this.splGroup.SplitterDistance = 260;
            this.splGroup.TabIndex = 4;
            // 
            // dgvDeviceList
            // 
            this.dgvDeviceList.AllowUserToAddRows = false;
            this.dgvDeviceList.AllowUserToDeleteRows = false;
            this.dgvDeviceList.AllowUserToOrderColumns = true;
            this.dgvDeviceList.AllowUserToResizeRows = false;
            this.dgvDeviceList.BackgroundColor = System.Drawing.Color.FromArgb(((int)(((byte)(50)))), ((int)(((byte)(50)))), ((int)(((byte)(50)))));
            this.dgvDeviceList.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.dgvDeviceList.ColumnHeadersBorderStyle = System.Windows.Forms.DataGridViewHeaderBorderStyle.Single;
            dataGridViewCellStyle1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(50)))), ((int)(((byte)(50)))), ((int)(((byte)(50)))));
            dataGridViewCellStyle1.Font = new System.Drawing.Font("Yu Gothic UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle1.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.dgvDeviceList.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle1;
            this.dgvDeviceList.ColumnHeadersHeight = 32;
            this.dgvDeviceList.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.DisableResizing;
            this.dgvDeviceList.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.Code,
            this.ItemValue,
            this.DisplayValue});
            dataGridViewCellStyle2.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle2.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(40)))), ((int)(((byte)(40)))), ((int)(((byte)(40)))));
            dataGridViewCellStyle2.Font = new System.Drawing.Font("Yu Gothic UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle2.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle2.SelectionBackColor = System.Drawing.Color.SlateGray;
            dataGridViewCellStyle2.SelectionForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle2.WrapMode = System.Windows.Forms.DataGridViewTriState.False;
            this.dgvDeviceList.DefaultCellStyle = dataGridViewCellStyle2;
            this.dgvDeviceList.Dock = System.Windows.Forms.DockStyle.Fill;
            this.dgvDeviceList.EnableHeadersVisualStyles = false;
            this.dgvDeviceList.GridColor = System.Drawing.Color.FromArgb(((int)(((byte)(70)))), ((int)(((byte)(70)))), ((int)(((byte)(70)))));
            this.dgvDeviceList.Location = new System.Drawing.Point(0, 0);
            this.dgvDeviceList.MultiSelect = false;
            this.dgvDeviceList.Name = "dgvDeviceList";
            this.dgvDeviceList.RowHeadersVisible = false;
            this.dgvDeviceList.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.CellSelect;
            this.dgvDeviceList.Size = new System.Drawing.Size(274, 260);
            this.dgvDeviceList.TabIndex = 2;
            // 
            // dgvGroupDetail
            // 
            this.dgvGroupDetail.AllowUserToAddRows = false;
            this.dgvGroupDetail.AllowUserToDeleteRows = false;
            this.dgvGroupDetail.AllowUserToResizeRows = false;
            this.dgvGroupDetail.BackgroundColor = System.Drawing.Color.FromArgb(((int)(((byte)(50)))), ((int)(((byte)(50)))), ((int)(((byte)(50)))));
            this.dgvGroupDetail.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.dgvGroupDetail.ColumnHeadersBorderStyle = System.Windows.Forms.DataGridViewHeaderBorderStyle.Single;
            dataGridViewCellStyle3.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(50)))), ((int)(((byte)(50)))), ((int)(((byte)(50)))));
            dataGridViewCellStyle3.Font = new System.Drawing.Font("Yu Gothic UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle3.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.dgvGroupDetail.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle3;
            this.dgvGroupDetail.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.DisableResizing;
            dataGridViewCellStyle4.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle4.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(40)))), ((int)(((byte)(40)))), ((int)(((byte)(40)))));
            dataGridViewCellStyle4.Font = new System.Drawing.Font("Yu Gothic UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle4.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle4.SelectionBackColor = System.Drawing.Color.SlateGray;
            dataGridViewCellStyle4.SelectionForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle4.WrapMode = System.Windows.Forms.DataGridViewTriState.False;
            this.dgvGroupDetail.DefaultCellStyle = dataGridViewCellStyle4;
            this.dgvGroupDetail.Dock = System.Windows.Forms.DockStyle.Fill;
            this.dgvGroupDetail.EnableHeadersVisualStyles = false;
            this.dgvGroupDetail.GridColor = System.Drawing.Color.FromArgb(((int)(((byte)(70)))), ((int)(((byte)(70)))), ((int)(((byte)(70)))));
            this.dgvGroupDetail.Location = new System.Drawing.Point(0, 0);
            this.dgvGroupDetail.MultiSelect = false;
            this.dgvGroupDetail.Name = "dgvGroupDetail";
            this.dgvGroupDetail.ReadOnly = true;
            this.dgvGroupDetail.RowHeadersVisible = false;
            this.dgvGroupDetail.RowTemplate.Height = 21;
            this.dgvGroupDetail.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.dgvGroupDetail.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.CellSelect;
            this.dgvGroupDetail.Size = new System.Drawing.Size(274, 256);
            this.dgvGroupDetail.TabIndex = 1;
            // 
            // Code
            // 
            this.Code.DataPropertyName = "Code";
            this.Code.HeaderText = "Code";
            this.Code.Name = "Code";
            this.Code.ReadOnly = true;
            this.Code.Visible = false;
            // 
            // ItemValue
            // 
            this.ItemValue.DataPropertyName = "ItemValue";
            this.ItemValue.HeaderText = "データ名";
            this.ItemValue.Name = "ItemValue";
            this.ItemValue.ReadOnly = true;
            this.ItemValue.Resizable = System.Windows.Forms.DataGridViewTriState.False;
            // 
            // DisplayValue
            // 
            this.DisplayValue.DataPropertyName = "DisplayValue";
            this.DisplayValue.DisplayStyleForCurrentCellOnly = true;
            this.DisplayValue.HeaderText = "設定値";
            this.DisplayValue.Name = "DisplayValue";
            this.DisplayValue.ReadOnly = true;
            this.DisplayValue.Resizable = System.Windows.Forms.DataGridViewTriState.False;
            this.DisplayValue.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.Automatic;
            this.DisplayValue.Width = 170;
            // 
            // frmDesignChildLayoutDevice
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(274, 520);
            this.CloseBox = false;
            this.CloseEscapeKey = false;
            this.Controls.Add(this.splGroup);
            this.Margin = new System.Windows.Forms.Padding(3, 6, 3, 6);
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "frmDesignChildLayoutDevice";
            this.ShowInTaskbar = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.Manual;
            this.Controls.SetChildIndex(this.winlblTitle, 0);
            this.Controls.SetChildIndex(this.splGroup, 0);
            this.Controls.SetChildIndex(this.btnStop, 0);
            this.Controls.SetChildIndex(this.btnFocusControl, 0);
            this.Controls.SetChildIndex(this.btnTop, 0);
            this.splGroup.Panel1.ResumeLayout(false);
            this.splGroup.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splGroup)).EndInit();
            this.splGroup.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.dgvDeviceList)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.dgvGroupDetail)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.SplitContainer splGroup;
        private System.Windows.Forms.DataGridView dgvDeviceList;
        private System.Windows.Forms.DataGridView dgvGroupDetail;
        private System.Windows.Forms.DataGridViewTextBoxColumn Code;
        private System.Windows.Forms.DataGridViewTextBoxColumn ItemValue;
        private System.Windows.Forms.DataGridViewComboBoxColumn DisplayValue;
    }
}