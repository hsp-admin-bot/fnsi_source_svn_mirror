namespace LayoutDesigner
{
    partial class frmDesignChildLayoutParam
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
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle9 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle10 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle11 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle12 = new System.Windows.Forms.DataGridViewCellStyle();
            this.splParameter = new System.Windows.Forms.SplitContainer();
            this.dgvParamList = new System.Windows.Forms.DataGridView();
            this.dgvParamDetail = new System.Windows.Forms.DataGridView();
            this.btnReCalc = new System.Windows.Forms.Button();
            this.btnPreviewExcel = new System.Windows.Forms.Button();
            this.btnPreviewHtml = new System.Windows.Forms.Button();
            ((System.ComponentModel.ISupportInitialize)(this.splParameter)).BeginInit();
            this.splParameter.Panel1.SuspendLayout();
            this.splParameter.Panel2.SuspendLayout();
            this.splParameter.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgvParamList)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.dgvParamDetail)).BeginInit();
            this.SuspendLayout();
            // 
            // btnStop
            // 
            this.btnStop.Location = new System.Drawing.Point(199, 505);
            // 
            // btnTop
            // 
            this.btnTop.Location = new System.Drawing.Point(81, 0);
            this.btnTop.TabIndex = 0;
            // 
            // btnFocusControl
            // 
            this.btnFocusControl.Location = new System.Drawing.Point(162, 0);
            this.btnFocusControl.TabIndex = 1;
            // 
            // winlblTitle
            // 
            this.winlblTitle.Size = new System.Drawing.Size(274, 0);
            // 
            // splParameter
            // 
            this.splParameter.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
            | System.Windows.Forms.AnchorStyles.Left)
            | System.Windows.Forms.AnchorStyles.Right)));
            this.splParameter.BackColor = System.Drawing.SystemColors.ControlDarkDark;
            this.splParameter.Location = new System.Drawing.Point(0, 26);
            this.splParameter.Name = "splParameter";
            this.splParameter.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // splParameter.Panel1
            // 
            this.splParameter.Panel1.Controls.Add(this.dgvParamList);
            // 
            // splParameter.Panel2
            // 
            this.splParameter.Panel2.Controls.Add(this.dgvParamDetail);
            this.splParameter.Size = new System.Drawing.Size(274, 494);
            this.splParameter.SplitterDistance = 247;
            this.splParameter.TabIndex = 5;
            // 
            // dgvParamList
            // 
            this.dgvParamList.AllowUserToAddRows = false;
            this.dgvParamList.AllowUserToDeleteRows = false;
            this.dgvParamList.AllowUserToOrderColumns = true;
            this.dgvParamList.AllowUserToResizeRows = false;
            this.dgvParamList.BackgroundColor = System.Drawing.Color.FromArgb(((int)(((byte)(50)))), ((int)(((byte)(50)))), ((int)(((byte)(50)))));
            this.dgvParamList.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.dgvParamList.ColumnHeadersBorderStyle = System.Windows.Forms.DataGridViewHeaderBorderStyle.Single;
            dataGridViewCellStyle9.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(50)))), ((int)(((byte)(50)))), ((int)(((byte)(50)))));
            dataGridViewCellStyle9.Font = new System.Drawing.Font("Yu Gothic UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle9.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.dgvParamList.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle9;
            this.dgvParamList.ColumnHeadersHeight = 32;
            this.dgvParamList.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.DisableResizing;
            dataGridViewCellStyle10.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle10.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(40)))), ((int)(((byte)(40)))), ((int)(((byte)(40)))));
            dataGridViewCellStyle10.Font = new System.Drawing.Font("Yu Gothic UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle10.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle10.SelectionBackColor = System.Drawing.Color.SlateGray;
            dataGridViewCellStyle10.SelectionForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle10.WrapMode = System.Windows.Forms.DataGridViewTriState.False;
            this.dgvParamList.DefaultCellStyle = dataGridViewCellStyle10;
            this.dgvParamList.Dock = System.Windows.Forms.DockStyle.Fill;
            this.dgvParamList.EnableHeadersVisualStyles = false;
            this.dgvParamList.GridColor = System.Drawing.Color.FromArgb(((int)(((byte)(70)))), ((int)(((byte)(70)))), ((int)(((byte)(70)))));
            this.dgvParamList.Location = new System.Drawing.Point(0, 0);
            this.dgvParamList.MultiSelect = false;
            this.dgvParamList.Name = "dgvParamList";
            this.dgvParamList.RowHeadersVisible = false;
            this.dgvParamList.RowTemplate.Height = 21;
            this.dgvParamList.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.CellSelect;
            this.dgvParamList.Size = new System.Drawing.Size(274, 247);
            this.dgvParamList.TabIndex = 0;
            this.dgvParamList.CurrentCellDirtyStateChanged += new System.EventHandler(this.dgvParamList_CurrentCellDirtyStateChanged);
            this.dgvParamList.RowEnter += new System.Windows.Forms.DataGridViewCellEventHandler(this.dgvParamList_RowEnter);
            // 
            // dgvParamDetail
            // 
            this.dgvParamDetail.AllowUserToAddRows = false;
            this.dgvParamDetail.AllowUserToDeleteRows = false;
            this.dgvParamDetail.AllowUserToResizeRows = false;
            this.dgvParamDetail.BackgroundColor = System.Drawing.Color.FromArgb(((int)(((byte)(50)))), ((int)(((byte)(50)))), ((int)(((byte)(50)))));
            this.dgvParamDetail.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.dgvParamDetail.ColumnHeadersBorderStyle = System.Windows.Forms.DataGridViewHeaderBorderStyle.Single;
            dataGridViewCellStyle11.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(50)))), ((int)(((byte)(50)))), ((int)(((byte)(50)))));
            dataGridViewCellStyle11.Font = new System.Drawing.Font("Yu Gothic UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle11.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.dgvParamDetail.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle11;
            this.dgvParamDetail.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.DisableResizing;
            dataGridViewCellStyle12.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle12.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(40)))), ((int)(((byte)(40)))), ((int)(((byte)(40)))));
            dataGridViewCellStyle12.Font = new System.Drawing.Font("Yu Gothic UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle12.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle12.SelectionBackColor = System.Drawing.Color.SlateGray;
            dataGridViewCellStyle12.SelectionForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle12.WrapMode = System.Windows.Forms.DataGridViewTriState.False;
            this.dgvParamDetail.DefaultCellStyle = dataGridViewCellStyle12;
            this.dgvParamDetail.Dock = System.Windows.Forms.DockStyle.Fill;
            this.dgvParamDetail.EnableHeadersVisualStyles = false;
            this.dgvParamDetail.GridColor = System.Drawing.Color.FromArgb(((int)(((byte)(70)))), ((int)(((byte)(70)))), ((int)(((byte)(70)))));
            this.dgvParamDetail.Location = new System.Drawing.Point(0, 0);
            this.dgvParamDetail.MultiSelect = false;
            this.dgvParamDetail.Name = "dgvParamDetail";
            this.dgvParamDetail.RowHeadersVisible = false;
            this.dgvParamDetail.RowHeadersWidth = 95;
            this.dgvParamDetail.RowTemplate.Height = 21;
            this.dgvParamDetail.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.dgvParamDetail.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.CellSelect;
            this.dgvParamDetail.Size = new System.Drawing.Size(274, 243);
            this.dgvParamDetail.TabIndex = 0;
            this.dgvParamDetail.CellClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.dgvParamDetail_CellClick);
            this.dgvParamDetail.CellEndEdit += new System.Windows.Forms.DataGridViewCellEventHandler(this.dgvParamDetail_CellEndEdit);
            this.dgvParamDetail.CurrentCellDirtyStateChanged += new System.EventHandler(this.dgvParamDetail_CurrentCellDirtyStateChanged);
            // 
            // btnReCalc
            // 
            this.btnReCalc.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnReCalc.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnReCalc.Location = new System.Drawing.Point(1, 1);
            this.btnReCalc.Name = "btnReCalc";
            this.btnReCalc.Size = new System.Drawing.Size(100, 24);
            this.btnReCalc.TabIndex = 2;
            this.btnReCalc.TabStop = false;
            this.btnReCalc.Text = "文字数再計算";
            this.btnReCalc.Click += new System.EventHandler(this.btnReCalc_Click);
            // 
            // btnPreviewExcel
            // 
            this.btnPreviewExcel.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnPreviewExcel.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnPreviewExcel.Location = new System.Drawing.Point(107, 1);
            this.btnPreviewExcel.Name = "btnPreviewExcel";
            this.btnPreviewExcel.Size = new System.Drawing.Size(100, 24);
            this.btnPreviewExcel.TabIndex = 3;
            this.btnPreviewExcel.TabStop = false;
            this.btnPreviewExcel.Text = "プレビュー(Excel)";
            this.btnPreviewExcel.Click += new System.EventHandler(this.btnPreviewExcel_Click);
            // 
            // btnPreviewHtml
            // 
            this.btnPreviewHtml.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnPreviewHtml.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnPreviewHtml.Font = new System.Drawing.Font("Yu Gothic UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.btnPreviewHtml.Location = new System.Drawing.Point(213, 1);
            this.btnPreviewHtml.Name = "btnPreviewHtml";
            this.btnPreviewHtml.Size = new System.Drawing.Size(100, 24);
            this.btnPreviewHtml.TabIndex = 4;
            this.btnPreviewHtml.TabStop = false;
            this.btnPreviewHtml.Text = "プレビュー(ブラウザ)";
            this.btnPreviewHtml.Click += new System.EventHandler(this.btnPreviewHtml_Click);
            // 
            // frmDesignChildLayoutParam
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(274, 520);
            this.CloseBox = false;
            this.CloseEscapeKey = false;
            this.Controls.Add(this.btnPreviewHtml);
            this.Controls.Add(this.btnPreviewExcel);
            this.Controls.Add(this.btnReCalc);
            this.Controls.Add(this.splParameter);
            this.Margin = new System.Windows.Forms.Padding(3, 6, 3, 6);
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "frmDesignChildLayoutParam";
            this.ShowInTaskbar = false;
            this.Controls.SetChildIndex(this.splParameter, 0);
            this.Controls.SetChildIndex(this.btnReCalc, 0);
            this.Controls.SetChildIndex(this.btnPreviewExcel, 0);
            this.Controls.SetChildIndex(this.btnPreviewHtml, 0);
            this.Controls.SetChildIndex(this.winlblTitle, 0);
            this.Controls.SetChildIndex(this.btnTop, 0);
            this.Controls.SetChildIndex(this.btnFocusControl, 0);
            this.Controls.SetChildIndex(this.btnStop, 0);
            this.splParameter.Panel1.ResumeLayout(false);
            this.splParameter.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splParameter)).EndInit();
            this.splParameter.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.dgvParamList)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.dgvParamDetail)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.SplitContainer splParameter;
        private System.Windows.Forms.DataGridView dgvParamDetail;
        private System.Windows.Forms.DataGridView dgvParamList;
        private System.Windows.Forms.Button btnReCalc;
        private System.Windows.Forms.Button btnPreviewExcel;
        private System.Windows.Forms.Button btnPreviewHtml;
    }
}