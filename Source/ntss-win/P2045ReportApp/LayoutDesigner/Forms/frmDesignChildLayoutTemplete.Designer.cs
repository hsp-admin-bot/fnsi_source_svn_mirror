namespace LayoutDesigner
{
    partial class frmDesignChildLayoutTemplete
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
            this.splTemplete = new System.Windows.Forms.SplitContainer();
            this.pnlTmplDrop = new System.Windows.Forms.Panel();
            this.lblTmplDescription = new System.Windows.Forms.Label();
            this.picTmpl = new System.Windows.Forms.PictureBox();
            this.pnlTmplHeader = new System.Windows.Forms.Panel();
            this.btnTmplClear = new System.Windows.Forms.Button();
            this.btnTmplUpdate = new System.Windows.Forms.Button();
            this.btnTmplSelect = new System.Windows.Forms.Button();
            this.dgvTmplDetail = new System.Windows.Forms.DataGridView();
            this.pnlBottom = new System.Windows.Forms.Panel();
            this.btnTmplMakeData = new System.Windows.Forms.Button();
            ((System.ComponentModel.ISupportInitialize)(this.splTemplete)).BeginInit();
            this.splTemplete.Panel1.SuspendLayout();
            this.splTemplete.Panel2.SuspendLayout();
            this.splTemplete.SuspendLayout();
            this.pnlTmplDrop.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.picTmpl)).BeginInit();
            this.pnlTmplHeader.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgvTmplDetail)).BeginInit();
            this.pnlBottom.SuspendLayout();
            this.SuspendLayout();
            // 
            // btnStop
            // 
            this.btnStop.Location = new System.Drawing.Point(227, 700);
            this.btnStop.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.btnStop.TabIndex = 4;
            // 
            // btnTop
            // 
            this.btnTop.Location = new System.Drawing.Point(3, 0);
            this.btnTop.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            // 
            // btnFocusControl
            // 
            this.btnFocusControl.Location = new System.Drawing.Point(96, 0);
            this.btnFocusControl.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            // 
            // winlblTitle
            // 
            this.winlblTitle.Size = new System.Drawing.Size(313, 0);
            // 
            // splTemplete
            // 
            this.splTemplete.BackColor = System.Drawing.Color.LightSlateGray;
            this.splTemplete.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splTemplete.Location = new System.Drawing.Point(0, 0);
            this.splTemplete.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.splTemplete.Name = "splTemplete";
            this.splTemplete.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // splTemplete.Panel1
            // 
            this.splTemplete.Panel1.Controls.Add(this.pnlTmplDrop);
            this.splTemplete.Panel1.Controls.Add(this.pnlTmplHeader);
            // 
            // splTemplete.Panel2
            // 
            this.splTemplete.Panel2.Controls.Add(this.dgvTmplDetail);
            this.splTemplete.Panel2.Controls.Add(this.pnlBottom);
            this.splTemplete.Size = new System.Drawing.Size(313, 720);
            this.splTemplete.SplitterDistance = 360;
            this.splTemplete.SplitterWidth = 5;
            this.splTemplete.TabIndex = 3;
            // 
            // pnlTmplDrop
            // 
            this.pnlTmplDrop.AllowDrop = true;
            this.pnlTmplDrop.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.pnlTmplDrop.Controls.Add(this.lblTmplDescription);
            this.pnlTmplDrop.Controls.Add(this.picTmpl);
            this.pnlTmplDrop.Dock = System.Windows.Forms.DockStyle.Fill;
            this.pnlTmplDrop.Location = new System.Drawing.Point(0, 37);
            this.pnlTmplDrop.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.pnlTmplDrop.Name = "pnlTmplDrop";
            this.pnlTmplDrop.Size = new System.Drawing.Size(313, 323);
            this.pnlTmplDrop.TabIndex = 2;
            this.pnlTmplDrop.DragDrop += new System.Windows.Forms.DragEventHandler(this.pnlTmplDrop_DragDrop);
            this.pnlTmplDrop.DragEnter += new System.Windows.Forms.DragEventHandler(this.pnlTmplDrop_DragEnter);
            // 
            // lblTmplDescription
            // 
            this.lblTmplDescription.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lblTmplDescription.Location = new System.Drawing.Point(7, 121);
            this.lblTmplDescription.Name = "lblTmplDescription";
            this.lblTmplDescription.Size = new System.Drawing.Size(301, 79);
            this.lblTmplDescription.TabIndex = 0;
            this.lblTmplDescription.Text = "テンプレートとして指定するセルをドロップ";
            this.lblTmplDescription.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // picTmpl
            // 
            this.picTmpl.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.picTmpl.Dock = System.Windows.Forms.DockStyle.Fill;
            this.picTmpl.Location = new System.Drawing.Point(0, 0);
            this.picTmpl.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.picTmpl.Name = "picTmpl";
            this.picTmpl.Size = new System.Drawing.Size(313, 323);
            this.picTmpl.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.picTmpl.TabIndex = 0;
            this.picTmpl.TabStop = false;
            this.picTmpl.Click += new System.EventHandler(this.picTmpl_Click);
            // 
            // pnlTmplHeader
            // 
            this.pnlTmplHeader.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.pnlTmplHeader.Controls.Add(this.btnTmplClear);
            this.pnlTmplHeader.Controls.Add(this.btnTmplUpdate);
            this.pnlTmplHeader.Controls.Add(this.btnTmplSelect);
            this.pnlTmplHeader.Dock = System.Windows.Forms.DockStyle.Top;
            this.pnlTmplHeader.Location = new System.Drawing.Point(0, 0);
            this.pnlTmplHeader.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.pnlTmplHeader.Name = "pnlTmplHeader";
            this.pnlTmplHeader.Size = new System.Drawing.Size(313, 37);
            this.pnlTmplHeader.TabIndex = 0;
            // 
            // btnTmplClear
            // 
            this.btnTmplClear.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnTmplClear.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnTmplClear.ForeColor = System.Drawing.Color.LightCoral;
            this.btnTmplClear.Location = new System.Drawing.Point(145, 1);
            this.btnTmplClear.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.btnTmplClear.Name = "btnTmplClear";
            this.btnTmplClear.Size = new System.Drawing.Size(69, 32);
            this.btnTmplClear.TabIndex = 1;
            this.btnTmplClear.Text = "初期化";
            this.btnTmplClear.Click += new System.EventHandler(this.btnTmplClear_Click);
            // 
            // btnTmplUpdate
            // 
            this.btnTmplUpdate.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnTmplUpdate.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnTmplUpdate.Font = new System.Drawing.Font("Yu Gothic UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.btnTmplUpdate.Location = new System.Drawing.Point(220, 1);
            this.btnTmplUpdate.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.btnTmplUpdate.Name = "btnTmplUpdate";
            this.btnTmplUpdate.Size = new System.Drawing.Size(102, 32);
            this.btnTmplUpdate.TabIndex = 0;
            this.btnTmplUpdate.Text = "選択範囲更新";
            this.btnTmplUpdate.Click += new System.EventHandler(this.btnTmplUpdate_Click);
            // 
            // btnTmplSelect
            // 
            this.btnTmplSelect.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnTmplSelect.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnTmplSelect.Font = new System.Drawing.Font("Yu Gothic UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.btnTmplSelect.Location = new System.Drawing.Point(1, 1);
            this.btnTmplSelect.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.btnTmplSelect.Name = "btnTmplSelect";
            this.btnTmplSelect.Size = new System.Drawing.Size(137, 32);
            this.btnTmplSelect.TabIndex = 0;
            this.btnTmplSelect.Text = "選択セルを範囲に設定";
            this.btnTmplSelect.Click += new System.EventHandler(this.btnTmplSelect_Click);
            // 
            // dgvTmplDetail
            // 
            this.dgvTmplDetail.AllowUserToAddRows = false;
            this.dgvTmplDetail.AllowUserToDeleteRows = false;
            this.dgvTmplDetail.AllowUserToResizeRows = false;
            this.dgvTmplDetail.BackgroundColor = System.Drawing.Color.FromArgb(((int)(((byte)(50)))), ((int)(((byte)(50)))), ((int)(((byte)(50)))));
            this.dgvTmplDetail.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.dgvTmplDetail.ColumnHeadersBorderStyle = System.Windows.Forms.DataGridViewHeaderBorderStyle.Single;
            dataGridViewCellStyle1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(50)))), ((int)(((byte)(50)))), ((int)(((byte)(50)))));
            dataGridViewCellStyle1.Font = new System.Drawing.Font("Yu Gothic UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle1.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.dgvTmplDetail.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle1;
            this.dgvTmplDetail.ColumnHeadersHeight = 29;
            this.dgvTmplDetail.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.DisableResizing;
            dataGridViewCellStyle2.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle2.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(40)))), ((int)(((byte)(40)))), ((int)(((byte)(40)))));
            dataGridViewCellStyle2.Font = new System.Drawing.Font("Yu Gothic UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle2.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle2.SelectionBackColor = System.Drawing.Color.SlateGray;
            dataGridViewCellStyle2.SelectionForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle2.WrapMode = System.Windows.Forms.DataGridViewTriState.False;
            this.dgvTmplDetail.DefaultCellStyle = dataGridViewCellStyle2;
            this.dgvTmplDetail.Dock = System.Windows.Forms.DockStyle.Fill;
            this.dgvTmplDetail.EnableHeadersVisualStyles = false;
            this.dgvTmplDetail.GridColor = System.Drawing.Color.FromArgb(((int)(((byte)(70)))), ((int)(((byte)(70)))), ((int)(((byte)(70)))));
            this.dgvTmplDetail.Location = new System.Drawing.Point(0, 0);
            this.dgvTmplDetail.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.dgvTmplDetail.MultiSelect = false;
            this.dgvTmplDetail.Name = "dgvTmplDetail";
            this.dgvTmplDetail.RowHeadersVisible = false;
            this.dgvTmplDetail.RowHeadersWidth = 51;
            this.dgvTmplDetail.RowTemplate.Height = 21;
            this.dgvTmplDetail.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.dgvTmplDetail.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.CellSelect;
            this.dgvTmplDetail.Size = new System.Drawing.Size(313, 315);
            this.dgvTmplDetail.TabIndex = 0;
            this.dgvTmplDetail.CellClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.dgvTmplDetail_CellClick);
            this.dgvTmplDetail.CellLeave += new System.Windows.Forms.DataGridViewCellEventHandler(this.dgvTmplDetail_CellEndEdit);
            this.dgvTmplDetail.CurrentCellDirtyStateChanged += new System.EventHandler(this.dgvTmplDetail_CurrentCellDirtyStateChanged);
            this.dgvTmplDetail.DataError += new System.Windows.Forms.DataGridViewDataErrorEventHandler(this.dgvTmplDetail_DataError);
            // 
            // pnlBottom
            // 
            this.pnlBottom.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.pnlBottom.Controls.Add(this.btnTmplMakeData);
            this.pnlBottom.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.pnlBottom.Location = new System.Drawing.Point(0, 315);
            this.pnlBottom.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.pnlBottom.Name = "pnlBottom";
            this.pnlBottom.Size = new System.Drawing.Size(313, 40);
            this.pnlBottom.TabIndex = 1;
            // 
            // btnTmplMakeData
            // 
            this.btnTmplMakeData.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnTmplMakeData.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnTmplMakeData.Location = new System.Drawing.Point(82, 4);
            this.btnTmplMakeData.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.btnTmplMakeData.Name = "btnTmplMakeData";
            this.btnTmplMakeData.Size = new System.Drawing.Size(149, 32);
            this.btnTmplMakeData.TabIndex = 0;
            this.btnTmplMakeData.Text = "テスト用データ作成";
            // 
            // frmDesignChildLayoutTemplete
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 20F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(313, 720);
            this.CloseBox = false;
            this.Controls.Add(this.splTemplete);
            this.Margin = new System.Windows.Forms.Padding(3, 8, 3, 8);
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "frmDesignChildLayoutTemplete";
            this.ShowInTaskbar = false;
            this.Controls.SetChildIndex(this.winlblTitle, 0);
            this.Controls.SetChildIndex(this.splTemplete, 0);
            this.Controls.SetChildIndex(this.btnFocusControl, 0);
            this.Controls.SetChildIndex(this.btnStop, 0);
            this.Controls.SetChildIndex(this.btnTop, 0);
            this.splTemplete.Panel1.ResumeLayout(false);
            this.splTemplete.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splTemplete)).EndInit();
            this.splTemplete.ResumeLayout(false);
            this.pnlTmplDrop.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.picTmpl)).EndInit();
            this.pnlTmplHeader.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.dgvTmplDetail)).EndInit();
            this.pnlBottom.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.SplitContainer splTemplete;
        private System.Windows.Forms.Panel pnlTmplDrop;
        private System.Windows.Forms.Label lblTmplDescription;
        private System.Windows.Forms.PictureBox picTmpl;
        private System.Windows.Forms.Panel pnlTmplHeader;
        private System.Windows.Forms.Button btnTmplClear;
        private System.Windows.Forms.Button btnTmplSelect;
        private System.Windows.Forms.DataGridView dgvTmplDetail;
        private System.Windows.Forms.Panel pnlBottom;
        private System.Windows.Forms.Button btnTmplMakeData;
        private System.Windows.Forms.Button btnTmplUpdate;
    }
}