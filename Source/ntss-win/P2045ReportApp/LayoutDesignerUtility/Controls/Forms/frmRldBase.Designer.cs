namespace LayoutDesignerUtilityLib.Controls
{
    partial class frmRldBase
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
            this.btnStop = new System.Windows.Forms.Button();
            this.btnTop = new System.Windows.Forms.Button();
            this.btnFocusControl = new System.Windows.Forms.Button();
            this.winlblTitle = new LayoutDesignerUtilityLib.Controls.WindowTitleLabel();
            this.SuspendLayout();
            // 
            // btnStop
            // 
            this.btnStop.Font = new System.Drawing.Font("Yu Gothic UI", 4F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.btnStop.Location = new System.Drawing.Point(4, 66);
            this.btnStop.Name = "btnStop";
            this.btnStop.Size = new System.Drawing.Size(75, 15);
            this.btnStop.TabIndex = 3;
            this.btnStop.Text = "行き止まり";
            this.btnStop.UseVisualStyleBackColor = true;
            this.btnStop.Enter += new System.EventHandler(this.btnStop_Enter);
            // 
            // btnTop
            // 
            this.btnTop.Font = new System.Drawing.Font("Yu Gothic UI", 4F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.btnTop.Location = new System.Drawing.Point(4, 36);
            this.btnTop.Name = "btnTop";
            this.btnTop.Size = new System.Drawing.Size(75, 15);
            this.btnTop.TabIndex = 1;
            this.btnTop.Text = "先頭コントロール";
            this.btnTop.UseVisualStyleBackColor = true;
            this.btnTop.Enter += new System.EventHandler(this.btnTop_Enter);
            // 
            // btnFocusControl
            // 
            this.btnFocusControl.Font = new System.Drawing.Font("Yu Gothic UI", 4F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.btnFocusControl.Location = new System.Drawing.Point(4, 51);
            this.btnFocusControl.Name = "btnFocusControl";
            this.btnFocusControl.Size = new System.Drawing.Size(75, 15);
            this.btnFocusControl.TabIndex = 2;
            this.btnFocusControl.Text = "フォーカスコントロール用";
            this.btnFocusControl.UseVisualStyleBackColor = true;
            this.btnFocusControl.Enter += new System.EventHandler(this.btnFocusControl_Enter);
            // 
            // winlblTitle
            // 
            this.winlblTitle.Dock = System.Windows.Forms.DockStyle.Top;
            this.winlblTitle.Font = new System.Drawing.Font("Yu Gothic UI", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.winlblTitle.Location = new System.Drawing.Point(0, 0);
            this.winlblTitle.Name = "winlblTitle";
            this.winlblTitle.Size = new System.Drawing.Size(284, 28);
            this.winlblTitle.TabIndex = 0;
            this.winlblTitle.Text = "ウィンドウタイトル";
            this.winlblTitle.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // frmRldBase
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.ClientSize = new System.Drawing.Size(284, 284);
            this.ControlBox = false;
            this.Controls.Add(this.winlblTitle);
            this.Controls.Add(this.btnStop);
            this.Controls.Add(this.btnTop);
            this.Controls.Add(this.btnFocusControl);
            this.Font = new System.Drawing.Font("Yu Gothic UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.ForeColor = System.Drawing.Color.White;
            this.KeyPreview = true;
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Name = "frmRldBase";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.ResumeLayout(false);

        }

        #endregion

        protected System.Windows.Forms.Button btnStop;
        protected System.Windows.Forms.Button btnTop;
        protected System.Windows.Forms.Button btnFocusControl;
        protected global::LayoutDesignerUtilityLib.Controls.WindowTitleLabel winlblTitle;
    }
}