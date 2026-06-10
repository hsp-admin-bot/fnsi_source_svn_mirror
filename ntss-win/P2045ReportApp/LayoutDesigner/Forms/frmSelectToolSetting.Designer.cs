namespace LayoutDesigner
{
    partial class frmSelectToolSetting
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
            this.btnDialysis = new System.Windows.Forms.Button();
            this.btnExamin = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // btnStop
            // 
            this.btnStop.Location = new System.Drawing.Point(147, 93);
            this.btnStop.TabIndex = 5;
            // 
            // btnTop
            // 
            this.btnTop.Location = new System.Drawing.Point(14, 18);
            // 
            // btnFocusControl
            // 
            this.btnFocusControl.Location = new System.Drawing.Point(147, 18);
            // 
            // winlblTitle
            // 
            this.winlblTitle.Size = new System.Drawing.Size(236, 25);
            this.winlblTitle.Text = "抽出対象日選択";
            // 
            // btnDialysis
            // 
            this.btnDialysis.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
            | System.Windows.Forms.AnchorStyles.Right)));
            this.btnDialysis.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnDialysis.FlatAppearance.BorderSize = 2;
            this.btnDialysis.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnDialysis.Location = new System.Drawing.Point(14, 29);
            this.btnDialysis.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.btnDialysis.Name = "btnDialysis";
            this.btnDialysis.Size = new System.Drawing.Size(208, 29);
            this.btnDialysis.TabIndex = 3;
            this.btnDialysis.Text = "透析日";
            this.btnDialysis.Click += new System.EventHandler(this.btnDialysis_Click);
            // 
            // btnExamin
            // 
            this.btnExamin.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
            | System.Windows.Forms.AnchorStyles.Right)));
            this.btnExamin.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnExamin.FlatAppearance.BorderSize = 2;
            this.btnExamin.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnExamin.Location = new System.Drawing.Point(14, 65);
            this.btnExamin.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.btnExamin.Name = "btnExamin";
            this.btnExamin.Size = new System.Drawing.Size(208, 29);
            this.btnExamin.TabIndex = 4;
            this.btnExamin.Text = "検査日";
            this.btnExamin.Click += new System.EventHandler(this.btnExamin_Click);
            // 
            // frmSelectToolSetting
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(236, 109);
            this.Controls.Add(this.btnExamin);
            this.Controls.Add(this.btnDialysis);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.Margin = new System.Windows.Forms.Padding(3, 5, 3, 5);
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "frmSelectToolSetting";
            this.Controls.SetChildIndex(this.winlblTitle, 0);
            this.Controls.SetChildIndex(this.btnDialysis, 0);
            this.Controls.SetChildIndex(this.btnExamin, 0);
            this.Controls.SetChildIndex(this.btnFocusControl, 0);
            this.Controls.SetChildIndex(this.btnTop, 0);
            this.Controls.SetChildIndex(this.btnStop, 0);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Button btnDialysis;
        private System.Windows.Forms.Button btnExamin;
    }
}