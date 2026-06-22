namespace LayoutDesigner
{
    partial class frmSelectMainteFilter
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
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmSelectMainteFilter));
            this.chkDevelopment = new LayoutDesignerUtilityLib.Controls.NoFocusCheckBox();
            this.btnCancel = new System.Windows.Forms.Button();
            this.btnOK = new System.Windows.Forms.Button();
            this.imageList = new System.Windows.Forms.ImageList(this.components);
            this.pnlFooter = new System.Windows.Forms.Panel();
            this.pnlOnline = new System.Windows.Forms.Panel();
            this.txtFree = new System.Windows.Forms.TextBox();
            this.lblFree = new System.Windows.Forms.Label();
            this.rldTriStateTreeView = new LayoutDesigner.RldTriStateTreeView();
            this.pnlFooter.SuspendLayout();
            this.pnlOnline.SuspendLayout();
            this.SuspendLayout();
            // 
            // btnStop
            // 
            this.btnStop.Location = new System.Drawing.Point(204, 308);
            this.btnStop.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.btnStop.TabIndex = 7;
            // 
            // btnTop
            // 
            this.btnTop.Location = new System.Drawing.Point(4, 5);
            this.btnTop.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            // 
            // btnFocusControl
            // 
            this.btnFocusControl.Location = new System.Drawing.Point(204, 17);
            this.btnFocusControl.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            // 
            // winlblTitle
            // 
            this.winlblTitle.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(66)))), ((int)(((byte)(66)))), ((int)(((byte)(66)))));
            this.winlblTitle.Font = new System.Drawing.Font("Yu Gothic UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.winlblTitle.Size = new System.Drawing.Size(314, 14);
            this.winlblTitle.Text = "　フィルタ";
            // 
            // chkDevelopment
            // 
            this.chkDevelopment.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.chkDevelopment.AutoSize = true;
            this.chkDevelopment.Location = new System.Drawing.Point(152, 16);
            this.chkDevelopment.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.chkDevelopment.Name = "chkDevelopment";
            this.chkDevelopment.Size = new System.Drawing.Size(152, 19);
            this.chkDevelopment.TabIndex = 4;
            this.chkDevelopment.Text = "同グループの別項目に展開";
            this.chkDevelopment.UseVisualStyleBackColor = true;
            // 
            // btnCancel
            // 
            this.btnCancel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.btnCancel.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnCancel.FlatAppearance.BorderSize = 2;
            this.btnCancel.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnCancel.Location = new System.Drawing.Point(117, 41);
            this.btnCancel.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(87, 29);
            this.btnCancel.TabIndex = 5;
            this.btnCancel.Text = "キャンセル";
            // 
            // btnOK
            // 
            this.btnOK.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnOK.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnOK.FlatAppearance.BorderSize = 2;
            this.btnOK.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnOK.Location = new System.Drawing.Point(217, 41);
            this.btnOK.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.btnOK.Name = "btnOK";
            this.btnOK.Size = new System.Drawing.Size(87, 29);
            this.btnOK.TabIndex = 6;
            this.btnOK.Text = "OK";
            // 
            // imageList
            // 
            this.imageList.ImageStream = ((System.Windows.Forms.ImageListStreamer)(resources.GetObject("imageList.ImageStream")));
            this.imageList.TransparentColor = System.Drawing.Color.Fuchsia;
            this.imageList.Images.SetKeyName(0, "");
            this.imageList.Images.SetKeyName(1, "");
            this.imageList.Images.SetKeyName(2, "");
            this.imageList.Images.SetKeyName(3, "");
            // 
            // pnlFooter
            // 
            this.pnlFooter.Controls.Add(this.btnCancel);
            this.pnlFooter.Controls.Add(this.btnOK);
            this.pnlFooter.Controls.Add(this.chkDevelopment);
            this.pnlFooter.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.pnlFooter.Location = new System.Drawing.Point(2, 453);
            this.pnlFooter.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.pnlFooter.Name = "pnlFooter";
            this.pnlFooter.Size = new System.Drawing.Size(314, 85);
            this.pnlFooter.TabIndex = 8;
            // 
            // pnlOnline
            // 
            this.pnlOnline.Controls.Add(this.txtFree);
            this.pnlOnline.Controls.Add(this.lblFree);
            this.pnlOnline.Controls.Add(this.rldTriStateTreeView);
            this.pnlOnline.Dock = System.Windows.Forms.DockStyle.Fill;
            this.pnlOnline.Location = new System.Drawing.Point(2, 16);
            this.pnlOnline.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.pnlOnline.Name = "pnlOnline";
            this.pnlOnline.Size = new System.Drawing.Size(314, 437);
            this.pnlOnline.TabIndex = 2;
            // 
            // txtFree
            // 
            this.txtFree.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.txtFree.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.txtFree.ForeColor = System.Drawing.Color.White;
            this.txtFree.Location = new System.Drawing.Point(72, 6);
            this.txtFree.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.txtFree.Name = "txtFree";
            this.txtFree.Size = new System.Drawing.Size(152, 23);
            this.txtFree.TabIndex = 1;
            // 
            // lblFree
            // 
            this.lblFree.AutoSize = true;
            this.lblFree.Location = new System.Drawing.Point(7, 10);
            this.lblFree.Name = "lblFree";
            this.lblFree.Size = new System.Drawing.Size(49, 15);
            this.lblFree.TabIndex = 0;
            this.lblFree.Text = "ﾌﾘｰﾜｰﾄﾞ";
            // 
            // rldTriStateTreeView
            // 
            this.rldTriStateTreeView.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.rldTriStateTreeView.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(66)))), ((int)(((byte)(66)))), ((int)(((byte)(66)))));
            this.rldTriStateTreeView.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.rldTriStateTreeView.CheckBoxes = true;
            this.rldTriStateTreeView.CheckedImageIndex = 1;
            this.rldTriStateTreeView.Font = new System.Drawing.Font("Yu Gothic UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.rldTriStateTreeView.ForeColor = System.Drawing.Color.White;
            this.rldTriStateTreeView.ImageIndex = 0;
            this.rldTriStateTreeView.ImageList = this.imageList;
            this.rldTriStateTreeView.IndeterminateImageIndex = 2;
            this.rldTriStateTreeView.ItemHeight = 17;
            this.rldTriStateTreeView.LineColor = System.Drawing.Color.White;
            this.rldTriStateTreeView.Location = new System.Drawing.Point(9, 35);
            this.rldTriStateTreeView.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.rldTriStateTreeView.Name = "rldTriStateTreeView";
            this.rldTriStateTreeView.AutoRefreshScrollRange = true;
            this.rldTriStateTreeView.PreserveSelectionHighlight = true;
            this.rldTriStateTreeView.SelectedImageIndex = 0;
            this.rldTriStateTreeView.Size = new System.Drawing.Size(295, 398);
            this.rldTriStateTreeView.TabIndex = 3;
            this.rldTriStateTreeView.UncheckedImageIndex = 3;
            this.rldTriStateTreeView.UseCustomImages = true;
            // 
            // frmSelectMainteFilter
            // 
            this.AcceptButton = this.btnOK;
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.CancelButton = this.btnCancel;
            this.ClientSize = new System.Drawing.Size(318, 540);
            this.Controls.Add(this.pnlOnline);
            this.Controls.Add(this.pnlFooter);
            this.Margin = new System.Windows.Forms.Padding(3);
            this.MinimumSize = new System.Drawing.Size(284, 326);
            this.Name = "frmSelectMainteFilter";
            this.Controls.SetChildIndex(this.btnFocusControl, 0);
            this.Controls.SetChildIndex(this.btnStop, 0);
            this.Controls.SetChildIndex(this.winlblTitle, 0);
            this.Controls.SetChildIndex(this.btnTop, 0);
            this.Controls.SetChildIndex(this.pnlFooter, 0);
            this.Controls.SetChildIndex(this.pnlOnline, 0);
            this.pnlFooter.ResumeLayout(false);
            this.pnlFooter.PerformLayout();
            this.pnlOnline.ResumeLayout(false);
            this.pnlOnline.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private LayoutDesignerUtilityLib.Controls.NoFocusCheckBox chkDevelopment;
        private System.Windows.Forms.Button btnCancel;
        private System.Windows.Forms.Button btnOK;
        private LayoutDesigner.RldTriStateTreeView rldTriStateTreeView;
        private System.Windows.Forms.ImageList imageList;
        private System.Windows.Forms.Panel pnlFooter;
        private System.Windows.Forms.Panel pnlOnline;
        private System.Windows.Forms.TextBox txtFree;
        private System.Windows.Forms.Label lblFree;
    }
}