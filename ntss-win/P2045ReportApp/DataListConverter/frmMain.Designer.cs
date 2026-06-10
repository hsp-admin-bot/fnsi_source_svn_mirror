namespace DataListConverter
{
    partial class frmMain
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
            this.cmdExec = new System.Windows.Forms.Button();
            this.cmdExit = new System.Windows.Forms.Button();
            this.cmdFileDst = new System.Windows.Forms.Button();
            this.cmdFileSrc = new System.Windows.Forms.Button();
            this.lblFileSrc = new System.Windows.Forms.Label();
            this.lblFileDst = new System.Windows.Forms.Label();
            this.txtFileDst = new System.Windows.Forms.TextBox();
            this.txtFileSrc = new System.Windows.Forms.TextBox();
            this.SuspendLayout();
            // 
            // btnStop
            // 
            this.btnStop.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnStop.Location = new System.Drawing.Point(403, 110);
            this.btnStop.TabIndex = 11;
            // 
            // btnTop
            // 
            this.btnTop.Location = new System.Drawing.Point(4, 8);
            // 
            // btnFocusControl
            // 
            this.btnFocusControl.Location = new System.Drawing.Point(161, 8);
            // 
            // winlblTitle
            // 
            this.winlblTitle.Font = new System.Drawing.Font("Yu Gothic UI", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.winlblTitle.Size = new System.Drawing.Size(476, 18);
            this.winlblTitle.Text = "データリストコンバーター";
            // 
            // cmdExec
            // 
            this.cmdExec.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.cmdExec.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.cmdExec.FlatAppearance.BorderSize = 2;
            this.cmdExec.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.cmdExec.Location = new System.Drawing.Point(401, 93);
            this.cmdExec.Name = "cmdExec";
            this.cmdExec.Size = new System.Drawing.Size(75, 28);
            this.cmdExec.TabIndex = 10;
            this.cmdExec.Text = "実行(&E)";
            this.cmdExec.UseVisualStyleBackColor = true;
            // 
            // cmdExit
            // 
            this.cmdExit.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.cmdExit.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.cmdExit.FlatAppearance.BorderSize = 2;
            this.cmdExit.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.cmdExit.Location = new System.Drawing.Point(320, 93);
            this.cmdExit.Name = "cmdExit";
            this.cmdExit.Size = new System.Drawing.Size(75, 28);
            this.cmdExit.TabIndex = 9;
            this.cmdExit.Text = "閉じる(&X)";
            this.cmdExit.UseVisualStyleBackColor = true;
            // 
            // cmdFileDst
            // 
            this.cmdFileDst.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.cmdFileDst.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.cmdFileDst.FlatAppearance.BorderSize = 2;
            this.cmdFileDst.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.cmdFileDst.Location = new System.Drawing.Point(447, 59);
            this.cmdFileDst.Name = "cmdFileDst";
            this.cmdFileDst.Size = new System.Drawing.Size(28, 28);
            this.cmdFileDst.TabIndex = 8;
            this.cmdFileDst.Text = "...";
            this.cmdFileDst.UseVisualStyleBackColor = true;
            // 
            // cmdFileSrc
            // 
            this.cmdFileSrc.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.cmdFileSrc.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.cmdFileSrc.FlatAppearance.BorderSize = 2;
            this.cmdFileSrc.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.cmdFileSrc.Location = new System.Drawing.Point(447, 25);
            this.cmdFileSrc.Name = "cmdFileSrc";
            this.cmdFileSrc.Size = new System.Drawing.Size(28, 28);
            this.cmdFileSrc.TabIndex = 5;
            this.cmdFileSrc.Text = "...";
            this.cmdFileSrc.UseVisualStyleBackColor = true;
            // 
            // lblFileSrc
            // 
            this.lblFileSrc.AutoSize = true;
            this.lblFileSrc.Location = new System.Drawing.Point(2, 32);
            this.lblFileSrc.Name = "lblFileSrc";
            this.lblFileSrc.Size = new System.Drawing.Size(89, 15);
            this.lblFileSrc.TabIndex = 3;
            this.lblFileSrc.Text = "変換元ファイル：";
            // 
            // lblFileDst
            // 
            this.lblFileDst.AutoSize = true;
            this.lblFileDst.Location = new System.Drawing.Point(2, 66);
            this.lblFileDst.Name = "lblFileDst";
            this.lblFileDst.Size = new System.Drawing.Size(89, 15);
            this.lblFileDst.TabIndex = 6;
            this.lblFileDst.Text = "変換先ファイル：";
            // 
            // txtFileDst
            // 
            this.txtFileDst.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.txtFileDst.Location = new System.Drawing.Point(97, 63);
            this.txtFileDst.Name = "txtFileDst";
            this.txtFileDst.Size = new System.Drawing.Size(344, 23);
            this.txtFileDst.TabIndex = 7;
            // 
            // txtFileSrc
            // 
            this.txtFileSrc.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.txtFileSrc.Location = new System.Drawing.Point(97, 29);
            this.txtFileSrc.Name = "txtFileSrc";
            this.txtFileSrc.Size = new System.Drawing.Size(344, 23);
            this.txtFileSrc.TabIndex = 4;
            // 
            // frmMain
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(480, 130);
            this.Controls.Add(this.txtFileSrc);
            this.Controls.Add(this.txtFileDst);
            this.Controls.Add(this.lblFileDst);
            this.Controls.Add(this.lblFileSrc);
            this.Controls.Add(this.cmdFileSrc);
            this.Controls.Add(this.cmdFileDst);
            this.Controls.Add(this.cmdExit);
            this.Controls.Add(this.cmdExec);
            this.Margin = new System.Windows.Forms.Padding(3, 5, 3, 5);
            this.MaximumSize = new System.Drawing.Size(480, 130);
            this.MinimumSize = new System.Drawing.Size(480, 130);
            this.Name = "frmMain";
            this.Text = "データリストコンバーター";
            this.Controls.SetChildIndex(this.winlblTitle, 0);
            this.Controls.SetChildIndex(this.cmdExec, 0);
            this.Controls.SetChildIndex(this.cmdExit, 0);
            this.Controls.SetChildIndex(this.cmdFileDst, 0);
            this.Controls.SetChildIndex(this.cmdFileSrc, 0);
            this.Controls.SetChildIndex(this.lblFileSrc, 0);
            this.Controls.SetChildIndex(this.lblFileDst, 0);
            this.Controls.SetChildIndex(this.txtFileDst, 0);
            this.Controls.SetChildIndex(this.txtFileSrc, 0);
            this.Controls.SetChildIndex(this.btnFocusControl, 0);
            this.Controls.SetChildIndex(this.btnTop, 0);
            this.Controls.SetChildIndex(this.btnStop, 0);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button cmdExec;
        private System.Windows.Forms.Button cmdExit;
        private System.Windows.Forms.Button cmdFileDst;
        private System.Windows.Forms.Button cmdFileSrc;
        private System.Windows.Forms.Label lblFileSrc;
        private System.Windows.Forms.Label lblFileDst;
        private System.Windows.Forms.TextBox txtFileDst;
        private System.Windows.Forms.TextBox txtFileSrc;
    }
}

