namespace LayoutDesigner
{
    partial class frmDesignChildLayoutGroup
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
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle4 = new System.Windows.Forms.DataGridViewCellStyle();
            this.splGroup = new System.Windows.Forms.SplitContainer();
            this.dgvGroupList = new System.Windows.Forms.DataGridView();
            this.dgvGroupDetail = new System.Windows.Forms.DataGridView();
            ((System.ComponentModel.ISupportInitialize)(this.splGroup)).BeginInit();
            this.splGroup.Panel1.SuspendLayout();
            this.splGroup.Panel2.SuspendLayout();
            this.splGroup.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgvGroupList)).BeginInit();
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
            this.splGroup.Panel1.Controls.Add(this.dgvGroupList);
            // 
            // splGroup.Panel2
            // 
            this.splGroup.Panel2.Controls.Add(this.dgvGroupDetail);
            this.splGroup.Size = new System.Drawing.Size(274, 520);
            this.splGroup.SplitterDistance = 260;
            this.splGroup.TabIndex = 4;
            // 
            // dgvGroupList
            // 
            this.dgvGroupList.AllowUserToAddRows = false;
            this.dgvGroupList.AllowUserToDeleteRows = false;
            this.dgvGroupList.AllowUserToOrderColumns = true;
            this.dgvGroupList.AllowUserToResizeRows = false;
            this.dgvGroupList.BackgroundColor = System.Drawing.Color.FromArgb(((int)(((byte)(50)))), ((int)(((byte)(50)))), ((int)(((byte)(50)))));
            this.dgvGroupList.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.dgvGroupList.ColumnHeadersBorderStyle = System.Windows.Forms.DataGridViewHeaderBorderStyle.Single;
            dataGridViewCellStyle1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(50)))), ((int)(((byte)(50)))), ((int)(((byte)(50)))));
            dataGridViewCellStyle1.Font = new System.Drawing.Font("Yu Gothic UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle1.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.dgvGroupList.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle1;
            this.dgvGroupList.ColumnHeadersHeight = 32;
            this.dgvGroupList.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.DisableResizing;
            dataGridViewCellStyle2.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle2.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(40)))), ((int)(((byte)(40)))), ((int)(((byte)(40)))));
            dataGridViewCellStyle2.Font = new System.Drawing.Font("Yu Gothic UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle2.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle2.SelectionBackColor = System.Drawing.Color.SlateGray;
            dataGridViewCellStyle2.SelectionForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle2.WrapMode = System.Windows.Forms.DataGridViewTriState.False;
            this.dgvGroupList.DefaultCellStyle = dataGridViewCellStyle2;
            this.dgvGroupList.Dock = System.Windows.Forms.DockStyle.Fill;
            this.dgvGroupList.EnableHeadersVisualStyles = false;
            this.dgvGroupList.GridColor = System.Drawing.Color.FromArgb(((int)(((byte)(70)))), ((int)(((byte)(70)))), ((int)(((byte)(70)))));
            this.dgvGroupList.Location = new System.Drawing.Point(0, 0);
            this.dgvGroupList.MultiSelect = false;
            this.dgvGroupList.Name = "dgvGroupList";
            this.dgvGroupList.RowHeadersVisible = false;
            this.dgvGroupList.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.CellSelect;
            this.dgvGroupList.Size = new System.Drawing.Size(274, 260);
            this.dgvGroupList.TabIndex = 2;
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
            this.dgvGroupDetail.RowHeadersVisible = false;
            this.dgvGroupDetail.RowTemplate.Height = 21;
            this.dgvGroupDetail.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.dgvGroupDetail.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.CellSelect;
            this.dgvGroupDetail.Size = new System.Drawing.Size(274, 256);
            this.dgvGroupDetail.TabIndex = 1;
            // 
            // frmDesignChildLayoutGroup
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
            this.Name = "frmDesignChildLayoutGroup";
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
            ((System.ComponentModel.ISupportInitialize)(this.dgvGroupList)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.dgvGroupDetail)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.SplitContainer splGroup;
        private System.Windows.Forms.DataGridView dgvGroupList;
        private System.Windows.Forms.DataGridView dgvGroupDetail;
    }
}