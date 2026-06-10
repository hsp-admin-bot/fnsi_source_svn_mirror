namespace LayoutDesigner
{
    partial class frmMainMenu
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
            this.tabControl = new System.Windows.Forms.TabControl();
            this.tbpAddNew = new System.Windows.Forms.TabPage();
            this.tbpEdit = new System.Windows.Forms.TabPage();
            this.winCloseBox = new LayoutDesignerUtilityLib.Controls.WindowCloseBox();
            this.winMaximizeBox = new LayoutDesignerUtilityLib.Controls.WindowMaximizeBox();
            this.winMinimizeBox = new LayoutDesignerUtilityLib.Controls.WindowMinimizeBox();
            this.tabControl.SuspendLayout();
            this.SuspendLayout();
            // 
            // btnStop
            // 
            this.btnStop.Location = new System.Drawing.Point(4, 580);
            // 
            // btnTop
            // 
            this.btnTop.Location = new System.Drawing.Point(4, 5);
            // 
            // btnFocusControl
            // 
            this.btnFocusControl.Location = new System.Drawing.Point(4, 26);
            // 
            // winlblTitle
            // 
            this.winlblTitle.Size = new System.Drawing.Size(831, 25);
            this.winlblTitle.Text = "メインメニュー";
            this.winlblTitle.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // tabControl
            // 
            this.tabControl.Controls.Add(this.tbpAddNew);
            this.tabControl.Controls.Add(this.tbpEdit);
            this.tabControl.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tabControl.Font = new System.Drawing.Font("Yu Gothic UI", 11.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.tabControl.HotTrack = true;
            this.tabControl.ItemSize = new System.Drawing.Size(414, 25);
            this.tabControl.Location = new System.Drawing.Point(2, 27);
            this.tabControl.Name = "tabControl";
            this.tabControl.SelectedIndex = 0;
            this.tabControl.Size = new System.Drawing.Size(831, 571);
            this.tabControl.SizeMode = System.Windows.Forms.TabSizeMode.Fixed;
            this.tabControl.TabIndex = 4;
            // 
            // tbpAddNew
            // 
            this.tbpAddNew.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.tbpAddNew.Location = new System.Drawing.Point(4, 29);
            this.tbpAddNew.Name = "tbpAddNew";
            this.tbpAddNew.Size = new System.Drawing.Size(823, 538);
            this.tbpAddNew.TabIndex = 0;
            this.tbpAddNew.Text = "新規作成";
            // 
            // tbpEdit
            // 
            this.tbpEdit.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.tbpEdit.Location = new System.Drawing.Point(4, 29);
            this.tbpEdit.Name = "tbpEdit";
            this.tbpEdit.Size = new System.Drawing.Size(823, 538);
            this.tbpEdit.TabIndex = 1;
            this.tbpEdit.Text = "帳票マスタ";
            // 
            // winCloseBox
            // 
            this.winCloseBox.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.winCloseBox.FlatAppearance.BorderSize = 0;
            this.winCloseBox.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.winCloseBox.Font = new System.Drawing.Font("Segoe MDL2 Assets", 9F);
            this.winCloseBox.Location = new System.Drawing.Point(806, 3);
            this.winCloseBox.Name = "winCloseBox";
            this.winCloseBox.Size = new System.Drawing.Size(27, 24);
            this.winCloseBox.TabIndex = 5;
            this.winCloseBox.Text = "閉じる";
            this.winCloseBox.UseVisualStyleBackColor = false;
            // 
            // winMaximizeBox
            // 
            this.winMaximizeBox.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.winMaximizeBox.FlatAppearance.BorderSize = 0;
            this.winMaximizeBox.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.winMaximizeBox.Font = new System.Drawing.Font("Segoe MDL2 Assets", 9F);
            this.winMaximizeBox.Location = new System.Drawing.Point(774, 3);
            this.winMaximizeBox.Name = "winMaximizeBox";
            this.winMaximizeBox.Size = new System.Drawing.Size(27, 24);
            this.winMaximizeBox.TabIndex = 6;
            this.winMaximizeBox.Text = "最大化";
            this.winMaximizeBox.UseVisualStyleBackColor = false;
            // 
            // winMinimizeBox
            // 
            this.winMinimizeBox.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.winMinimizeBox.FlatAppearance.BorderSize = 0;
            this.winMinimizeBox.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.winMinimizeBox.Font = new System.Drawing.Font("Segoe MDL2 Assets", 9F);
            this.winMinimizeBox.Location = new System.Drawing.Point(743, 3);
            this.winMinimizeBox.Name = "winMinimizeBox";
            this.winMinimizeBox.Size = new System.Drawing.Size(27, 24);
            this.winMinimizeBox.TabIndex = 7;
            this.winMinimizeBox.Text = "最小化";
            this.winMinimizeBox.UseVisualStyleBackColor = false;
            // 
            // frmMainMenu
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(835, 600);
            this.CloseEscapeKey = false;
            this.Controls.Add(this.winMinimizeBox);
            this.Controls.Add(this.winMaximizeBox);
            this.Controls.Add(this.winCloseBox);
            this.Controls.Add(this.tabControl);
            this.Margin = new System.Windows.Forms.Padding(3, 5, 3, 5);
            this.MinimumSize = new System.Drawing.Size(835, 600);
            this.Name = "frmMainMenu";
            this.ShowInTaskbar = true;
            this.Text = "frmMainMenu2";
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.frmMainMenu_FormClosed);
            this.Load += new System.EventHandler(this.frmMainMenu_Load);
            this.Controls.SetChildIndex(this.winlblTitle, 0);
            this.Controls.SetChildIndex(this.tabControl, 0);
            this.Controls.SetChildIndex(this.winCloseBox, 0);
            this.Controls.SetChildIndex(this.winMaximizeBox, 0);
            this.Controls.SetChildIndex(this.winMinimizeBox, 0);
            this.Controls.SetChildIndex(this.btnFocusControl, 0);
            this.Controls.SetChildIndex(this.btnStop, 0);
            this.Controls.SetChildIndex(this.btnTop, 0);
            this.tabControl.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.TabControl tabControl;
        private System.Windows.Forms.TabPage tbpAddNew;
        private System.Windows.Forms.TabPage tbpEdit;
        private LayoutDesignerUtilityLib.Controls.WindowCloseBox winCloseBox;
        private LayoutDesignerUtilityLib.Controls.WindowMaximizeBox winMaximizeBox;
        private LayoutDesignerUtilityLib.Controls.WindowMinimizeBox winMinimizeBox;
    }
}