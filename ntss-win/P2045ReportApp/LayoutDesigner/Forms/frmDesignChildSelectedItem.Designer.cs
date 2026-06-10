namespace LayoutDesigner
{
    partial class frmDesignChildSelectedItem
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
            this.dgvParamList = new System.Windows.Forms.DataGridView();
            this.pnlTop = new System.Windows.Forms.Panel();
            this.winMinimizeBoxAll = new LayoutDesignerUtilityLib.Controls.WindowMinimizeBox();
            this.winCloseBoxAll = new LayoutDesignerUtilityLib.Controls.WindowCloseBoxAll();
            ((System.ComponentModel.ISupportInitialize)(this.dgvParamList)).BeginInit();
            this.pnlTop.SuspendLayout();
            this.SuspendLayout();
            // 
            // btnStop
            // 
            this.btnStop.Location = new System.Drawing.Point(209, 64);
            // 
            // btnTop
            // 
            this.btnTop.Location = new System.Drawing.Point(3, 12);
            // 
            // btnFocusControl
            // 
            this.btnFocusControl.Location = new System.Drawing.Point(723, 12);
            // 
            // winlblTitle
            // 
            this.winlblTitle.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(66)))), ((int)(((byte)(66)))), ((int)(((byte)(66)))));
            this.winlblTitle.Dock = System.Windows.Forms.DockStyle.Fill;
            this.winlblTitle.Location = new System.Drawing.Point(0, 0);
            this.winlblTitle.Size = new System.Drawing.Size(742, 18);
            this.winlblTitle.Text = "　選択アイテムウィンドウ";
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
            dataGridViewCellStyle1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(50)))), ((int)(((byte)(50)))), ((int)(((byte)(50)))));
            dataGridViewCellStyle1.Font = new System.Drawing.Font("Yu Gothic UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle1.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.dgvParamList.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle1;
            this.dgvParamList.ColumnHeadersHeight = 32;
            this.dgvParamList.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.DisableResizing;
            dataGridViewCellStyle2.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle2.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(40)))), ((int)(((byte)(40)))), ((int)(((byte)(40)))));
            dataGridViewCellStyle2.Font = new System.Drawing.Font("Yu Gothic UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle2.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle2.SelectionBackColor = System.Drawing.Color.SlateGray;
            dataGridViewCellStyle2.SelectionForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle2.WrapMode = System.Windows.Forms.DataGridViewTriState.False;
            this.dgvParamList.DefaultCellStyle = dataGridViewCellStyle2;
            this.dgvParamList.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.dgvParamList.EnableHeadersVisualStyles = false;
            this.dgvParamList.GridColor = System.Drawing.Color.FromArgb(((int)(((byte)(70)))), ((int)(((byte)(70)))), ((int)(((byte)(70)))));
            this.dgvParamList.Location = new System.Drawing.Point(2, 25);
            this.dgvParamList.MultiSelect = false;
            this.dgvParamList.Name = "dgvParamList";
            this.dgvParamList.RowHeadersVisible = false;
            this.dgvParamList.RowHeadersWidth = 51;
            this.dgvParamList.RowTemplate.Height = 21;
            this.dgvParamList.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.CellSelect;
            this.dgvParamList.Size = new System.Drawing.Size(796, 52);
            this.dgvParamList.TabIndex = 5;
            this.dgvParamList.CurrentCellDirtyStateChanged += new System.EventHandler(this.dgvParamList_CurrentCellDirtyStateChanged);
            // 
            // pnlTop
            // 
            this.pnlTop.Controls.Add(this.winlblTitle);
            this.pnlTop.Controls.Add(this.winMinimizeBoxAll);
            this.pnlTop.Controls.Add(this.winCloseBoxAll);
            this.pnlTop.Dock = System.Windows.Forms.DockStyle.Top;
            this.pnlTop.Location = new System.Drawing.Point(2, 3);
            this.pnlTop.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.pnlTop.Name = "pnlTop";
            this.pnlTop.Size = new System.Drawing.Size(796, 18);
            this.pnlTop.TabIndex = 6;
            this.pnlTop.Controls.SetChildIndex(this.winCloseBoxAll, 0);
            this.pnlTop.Controls.SetChildIndex(this.winMinimizeBoxAll, 0);
            this.pnlTop.Controls.SetChildIndex(this.winlblTitle, 0);
            // 
            // winMinimizeBoxAll
            // 
            this.winMinimizeBoxAll.Dock = System.Windows.Forms.DockStyle.Right;
            this.winMinimizeBoxAll.FlatAppearance.BorderSize = 0;
            this.winMinimizeBoxAll.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.winMinimizeBoxAll.Font = new System.Drawing.Font("Segoe MDL2 Assets", 9F);
            this.winMinimizeBoxAll.Location = new System.Drawing.Point(742, 0);
            this.winMinimizeBoxAll.Name = "winMinimizeBoxAll";
            this.winMinimizeBoxAll.Size = new System.Drawing.Size(27, 18);
            this.winMinimizeBoxAll.TabIndex = 9;
            this.winMinimizeBoxAll.Text = "最小化";
            this.winMinimizeBoxAll.UseVisualStyleBackColor = false;
            this.winMinimizeBoxAll.Click += new System.EventHandler(this.winMinimizeBoxAll_Click);
            // 
            // winCloseBoxAll
            // 
            this.winCloseBoxAll.Dock = System.Windows.Forms.DockStyle.Right;
            this.winCloseBoxAll.FlatAppearance.BorderSize = 0;
            this.winCloseBoxAll.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.winCloseBoxAll.Font = new System.Drawing.Font("Segoe MDL2 Assets", 9F);
            this.winCloseBoxAll.Location = new System.Drawing.Point(769, 0);
            this.winCloseBoxAll.Name = "winCloseBoxAll";
            this.winCloseBoxAll.Size = new System.Drawing.Size(27, 18);
            this.winCloseBoxAll.TabIndex = 8;
            this.winCloseBoxAll.Text = "閉じる";
            this.winCloseBoxAll.UseVisualStyleBackColor = false;
            this.winCloseBoxAll.Click += new System.EventHandler(this.winCloseBoxAll_Click);
            // 
            // frmDesignChildSelectedItem
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.ClientSize = new System.Drawing.Size(800, 80);
            this.Controls.Add(this.pnlTop);
            this.Controls.Add(this.dgvParamList);
            this.Margin = new System.Windows.Forms.Padding(3, 7, 3, 7);
            this.MaximizeBox = false;
            this.MinimumSize = new System.Drawing.Size(800, 80);
            this.Name = "frmDesignChildSelectedItem";
            this.Padding = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.Activated += new System.EventHandler(this.frmDesignChildSelectedItem_Activated);
            this.Deactivate += new System.EventHandler(this.frmDesignChildSelectedItem_Deactivate);
            this.Controls.SetChildIndex(this.dgvParamList, 0);
            this.Controls.SetChildIndex(this.btnFocusControl, 0);
            this.Controls.SetChildIndex(this.btnTop, 0);
            this.Controls.SetChildIndex(this.btnStop, 0);
            this.Controls.SetChildIndex(this.pnlTop, 0);
            ((System.ComponentModel.ISupportInitialize)(this.dgvParamList)).EndInit();
            this.pnlTop.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion
        private System.Windows.Forms.DataGridView dgvParamList;
        private System.Windows.Forms.Panel pnlTop;
        private LayoutDesignerUtilityLib.Controls.WindowCloseBoxAll winCloseBoxAll;
        private LayoutDesignerUtilityLib.Controls.WindowMinimizeBox winMinimizeBoxAll;
    }
}