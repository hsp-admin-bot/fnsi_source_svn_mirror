namespace LayoutDesigner
{
    partial class frmSignIn
    {
        /// <summary>
        /// 必要なデザイナー変数です。
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// 使用中のリソースをすべてクリーンアップします。
        /// </summary>
        /// <param name="disposing">マネージド リソースを破棄する場合は true を指定し、その他の場合は false を指定します。</param>
        protected override void Dispose(bool disposing)
        {
            if( disposing && (components != null) ) {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows フォーム デザイナーで生成されたコード

        /// <summary>
        /// デザイナー サポートに必要なメソッドです。このメソッドの内容を
        /// コード エディターで変更しないでください。
        /// </summary>
        private void InitializeComponent()
        {
            this.btnSignIn = new System.Windows.Forms.Button();
            this.txtLoginID = new LayoutDesignerUtilityLib.Controls.PlaceHolderTextBox();
            this.txtPassword = new LayoutDesignerUtilityLib.Controls.PlaceHolderTextBox();
            this.lblLoginID = new System.Windows.Forms.Label();
            this.lblPassword = new System.Windows.Forms.Label();
            this.lblFacility = new System.Windows.Forms.Label();
            this.txtFacility = new LayoutDesignerUtilityLib.Controls.PlaceHolderTextBox();
            this.pnlBodyTop = new System.Windows.Forms.Panel();
            this.pnlBodyBottom = new System.Windows.Forms.Panel();
            this.pnlBottom = new System.Windows.Forms.Panel();
            this.winCloseBox = new LayoutDesignerUtilityLib.Controls.WindowCloseBox();
            this.winMinimizeBox = new LayoutDesignerUtilityLib.Controls.WindowMinimizeBox();
            this.pnlBodyTop.SuspendLayout();
            this.pnlBodyBottom.SuspendLayout();
            this.pnlBottom.SuspendLayout();
            this.SuspendLayout();
            // 
            // btnStop
            // 
            this.btnStop.Location = new System.Drawing.Point(203, 303);
            this.btnStop.TabIndex = 6;
            // 
            // btnTop
            // 
            this.btnTop.Location = new System.Drawing.Point(4, 19);
            // 
            // btnFocusControl
            // 
            this.btnFocusControl.Location = new System.Drawing.Point(203, 269);
            this.btnFocusControl.TabIndex = 4;
            // 
            // winlblTitle
            // 
            this.winlblTitle.Size = new System.Drawing.Size(278, 25);
            this.winlblTitle.Text = "サインイン";
            this.winlblTitle.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // btnSignIn
            // 
            this.btnSignIn.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnSignIn.FlatAppearance.BorderSize = 2;
            this.btnSignIn.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnSignIn.Location = new System.Drawing.Point(19, 5);
            this.btnSignIn.Name = "btnSignIn";
            this.btnSignIn.Size = new System.Drawing.Size(240, 30);
            this.btnSignIn.TabIndex = 0;
            this.btnSignIn.Text = "サインインする";
            this.btnSignIn.Click += new System.EventHandler(this.btnSignIn_Click);
            // 
            // txtLoginID
            // 
            this.txtLoginID.Location = new System.Drawing.Point(21, 61);
            this.txtLoginID.Name = "txtLoginID";
            this.txtLoginID.Size = new System.Drawing.Size(240, 23);
            this.txtLoginID.TabIndex = 1;
            // 
            // txtPassword
            // 
            this.txtPassword.ImeMode = System.Windows.Forms.ImeMode.Disable;
            this.txtPassword.Location = new System.Drawing.Point(21, 122);
            this.txtPassword.Name = "txtPassword";
            this.txtPassword.Size = new System.Drawing.Size(240, 23);
            this.txtPassword.TabIndex = 3;
            this.txtPassword.UseSystemPasswordChar = true;
            // 
            // lblLoginID
            // 
            this.lblLoginID.AutoSize = true;
            this.lblLoginID.Location = new System.Drawing.Point(18, 43);
            this.lblLoginID.Name = "lblLoginID";
            this.lblLoginID.Size = new System.Drawing.Size(54, 15);
            this.lblLoginID.TabIndex = 0;
            this.lblLoginID.Text = "ログインID";
            // 
            // lblPassword
            // 
            this.lblPassword.AutoSize = true;
            this.lblPassword.Location = new System.Drawing.Point(18, 104);
            this.lblPassword.Name = "lblPassword";
            this.lblPassword.Size = new System.Drawing.Size(51, 15);
            this.lblPassword.TabIndex = 2;
            this.lblPassword.Text = "パスワード";
            // 
            // lblFacility
            // 
            this.lblFacility.AutoSize = true;
            this.lblFacility.Location = new System.Drawing.Point(18, 6);
            this.lblFacility.Name = "lblFacility";
            this.lblFacility.Size = new System.Drawing.Size(55, 15);
            this.lblFacility.TabIndex = 0;
            this.lblFacility.Text = "施設情報";
            // 
            // txtFacility
            // 
            this.txtFacility.Location = new System.Drawing.Point(21, 24);
            this.txtFacility.Name = "txtFacility";
            this.txtFacility.Size = new System.Drawing.Size(240, 23);
            this.txtFacility.TabIndex = 1;
            // 
            // pnlBodyTop
            // 
            this.pnlBodyTop.Controls.Add(this.lblLoginID);
            this.pnlBodyTop.Controls.Add(this.txtLoginID);
            this.pnlBodyTop.Controls.Add(this.txtPassword);
            this.pnlBodyTop.Controls.Add(this.lblPassword);
            this.pnlBodyTop.Dock = System.Windows.Forms.DockStyle.Fill;
            this.pnlBodyTop.Location = new System.Drawing.Point(0, 25);
            this.pnlBodyTop.Name = "pnlBodyTop";
            this.pnlBodyTop.Size = new System.Drawing.Size(278, 173);
            this.pnlBodyTop.TabIndex = 2;
            // 
            // pnlBodyBottom
            // 
            this.pnlBodyBottom.Controls.Add(this.lblFacility);
            this.pnlBodyBottom.Controls.Add(this.txtFacility);
            this.pnlBodyBottom.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.pnlBodyBottom.Location = new System.Drawing.Point(0, 198);
            this.pnlBodyBottom.Name = "pnlBodyBottom";
            this.pnlBodyBottom.Size = new System.Drawing.Size(278, 70);
            this.pnlBodyBottom.TabIndex = 3;
            // 
            // pnlBottom
            // 
            this.pnlBottom.Controls.Add(this.btnSignIn);
            this.pnlBottom.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.pnlBottom.Location = new System.Drawing.Point(0, 268);
            this.pnlBottom.Name = "pnlBottom";
            this.pnlBottom.Size = new System.Drawing.Size(278, 50);
            this.pnlBottom.TabIndex = 5;
            // 
            // winCloseBox
            // 
            this.winCloseBox.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.winCloseBox.FlatAppearance.BorderSize = 0;
            this.winCloseBox.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.winCloseBox.Font = new System.Drawing.Font("Segoe MDL2 Assets", 9F);
            this.winCloseBox.Location = new System.Drawing.Point(248, 0);
            this.winCloseBox.Name = "winCloseBox";
            this.winCloseBox.Size = new System.Drawing.Size(27, 25);
            this.winCloseBox.TabIndex = 7;
            this.winCloseBox.Text = "閉じる";
            this.winCloseBox.UseVisualStyleBackColor = false;
            // 
            // winMinimizeBox
            // 
            this.winMinimizeBox.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.winMinimizeBox.FlatAppearance.BorderSize = 0;
            this.winMinimizeBox.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.winMinimizeBox.Font = new System.Drawing.Font("Segoe MDL2 Assets", 9F);
            this.winMinimizeBox.Location = new System.Drawing.Point(221, 0);
            this.winMinimizeBox.Name = "winMinimizeBox";
            this.winMinimizeBox.Size = new System.Drawing.Size(27, 25);
            this.winMinimizeBox.TabIndex = 8;
            this.winMinimizeBox.Text = "最小化";
            this.winMinimizeBox.UseVisualStyleBackColor = false;
            // 
            // frmSignIn
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(278, 318);
            this.Controls.Add(this.winMinimizeBox);
            this.Controls.Add(this.winCloseBox);
            this.Controls.Add(this.pnlBodyTop);
            this.Controls.Add(this.pnlBodyBottom);
            this.Controls.Add(this.pnlBottom);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.Margin = new System.Windows.Forms.Padding(3, 5, 3, 5);
            this.MaximizeBox = false;
            this.Name = "frmSignIn";
            this.Controls.SetChildIndex(this.winlblTitle, 0);
            this.Controls.SetChildIndex(this.pnlBottom, 0);
            this.Controls.SetChildIndex(this.pnlBodyBottom, 0);
            this.Controls.SetChildIndex(this.pnlBodyTop, 0);
            this.Controls.SetChildIndex(this.btnTop, 0);
            this.Controls.SetChildIndex(this.btnFocusControl, 0);
            this.Controls.SetChildIndex(this.btnStop, 0);
            this.Controls.SetChildIndex(this.winCloseBox, 0);
            this.Controls.SetChildIndex(this.winMinimizeBox, 0);
            this.pnlBodyTop.ResumeLayout(false);
            this.pnlBodyTop.PerformLayout();
            this.pnlBodyBottom.ResumeLayout(false);
            this.pnlBodyBottom.PerformLayout();
            this.pnlBottom.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Button btnSignIn;
        private LayoutDesignerUtilityLib.Controls.PlaceHolderTextBox txtLoginID;
        private LayoutDesignerUtilityLib.Controls.PlaceHolderTextBox txtPassword;
        private System.Windows.Forms.Label lblLoginID;
        private System.Windows.Forms.Label lblPassword;
        private System.Windows.Forms.Label lblFacility;
        private LayoutDesignerUtilityLib.Controls.PlaceHolderTextBox txtFacility;
        private System.Windows.Forms.Panel pnlBodyTop;
        private System.Windows.Forms.Panel pnlBodyBottom;
        private System.Windows.Forms.Panel pnlBottom;
        private LayoutDesignerUtilityLib.Controls.WindowCloseBox winCloseBox;
        private LayoutDesignerUtilityLib.Controls.WindowMinimizeBox winMinimizeBox;
    }
}

