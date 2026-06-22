namespace LayoutDesigner
{
    partial class frmSelectFormat
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
            this.lstFormat = new System.Windows.Forms.ListBox();
            this.btnOK = new System.Windows.Forms.Button();
            this.btnCancel = new System.Windows.Forms.Button();
            this.chkDevelopment = new System.Windows.Forms.CheckBox();
            this.lblDataPathAddr = new System.Windows.Forms.Label();
            this.SuspendLayout();
            // 
            // btnStop
            // 
            this.btnStop.Location = new System.Drawing.Point(197, 269);
            this.btnStop.TabIndex = 8;
            // 
            // btnTop
            // 
            this.btnTop.Location = new System.Drawing.Point(5, 8);
            // 
            // btnFocusControl
            // 
            this.btnFocusControl.Location = new System.Drawing.Point(197, 227);
            this.btnFocusControl.TabIndex = 4;
            // 
            // winlblTitle
            // 
            this.winlblTitle.Font = new System.Drawing.Font("Yu Gothic UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.winlblTitle.Margin = new System.Windows.Forms.Padding(0);
            this.winlblTitle.Size = new System.Drawing.Size(280, 18);
            this.winlblTitle.Text = "　書式選択";
            // 
            // lstFormat
            // 
            this.lstFormat.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lstFormat.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(66)))), ((int)(((byte)(66)))), ((int)(((byte)(66)))));
            this.lstFormat.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.lstFormat.ForeColor = System.Drawing.Color.White;
            this.lstFormat.FormattingEnabled = true;
            this.lstFormat.ItemHeight = 15;
            this.lstFormat.Location = new System.Drawing.Point(5, 43);
            this.lstFormat.Name = "lstFormat";
            this.lstFormat.Size = new System.Drawing.Size(274, 182);
            this.lstFormat.TabIndex = 3;
            // 
            // btnOK
            // 
            this.btnOK.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnOK.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnOK.FlatAppearance.BorderSize = 2;
            this.btnOK.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnOK.ForeColor = System.Drawing.Color.White;
            this.btnOK.Location = new System.Drawing.Point(185, 242);
            this.btnOK.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.btnOK.Name = "btnOK";
            this.btnOK.Size = new System.Drawing.Size(87, 29);
            this.btnOK.TabIndex = 7;
            this.btnOK.Text = "OK";
            // 
            // btnCancel
            // 
            this.btnCancel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.btnCancel.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnCancel.FlatAppearance.BorderSize = 2;
            this.btnCancel.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnCancel.ForeColor = System.Drawing.Color.White;
            this.btnCancel.Location = new System.Drawing.Point(91, 242);
            this.btnCancel.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(87, 29);
            this.btnCancel.TabIndex = 6;
            this.btnCancel.Text = "キャンセル";
            // 
            // chkDevelopment
            // 
            this.chkDevelopment.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.chkDevelopment.AutoSize = true;
            this.chkDevelopment.ForeColor = System.Drawing.Color.White;
            this.chkDevelopment.Location = new System.Drawing.Point(12, 236);
            this.chkDevelopment.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.chkDevelopment.Name = "chkDevelopment";
            this.chkDevelopment.Size = new System.Drawing.Size(74, 34);
            this.chkDevelopment.TabIndex = 5;
            this.chkDevelopment.Text = "同型に\r\n書式展開";
            this.chkDevelopment.UseVisualStyleBackColor = true;
            this.chkDevelopment.Visible = false;
            // 
            // lblDataPathAddr
            // 
            this.lblDataPathAddr.AutoSize = true;
            this.lblDataPathAddr.Location = new System.Drawing.Point(10, 25);
            this.lblDataPathAddr.Name = "lblDataPathAddr";
            this.lblDataPathAddr.Size = new System.Drawing.Size(10, 15);
            this.lblDataPathAddr.TabIndex = 2;
            this.lblDataPathAddr.Text = " ";
            // 
            // frmSelectFormat
            // 
            this.AcceptButton = this.btnOK;
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.CancelButton = this.btnCancel;
            this.ClientSize = new System.Drawing.Size(284, 284);
            this.Controls.Add(this.lblDataPathAddr);
            this.Controls.Add(this.chkDevelopment);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.btnOK);
            this.Controls.Add(this.lstFormat);
            this.Margin = new System.Windows.Forms.Padding(3, 5, 3, 5);
            this.MinimumSize = new System.Drawing.Size(284, 284);
            this.Name = "frmSelectFormat";
            this.Controls.SetChildIndex(this.lstFormat, 0);
            this.Controls.SetChildIndex(this.btnOK, 0);
            this.Controls.SetChildIndex(this.btnCancel, 0);
            this.Controls.SetChildIndex(this.winlblTitle, 0);
            this.Controls.SetChildIndex(this.chkDevelopment, 0);
            this.Controls.SetChildIndex(this.btnFocusControl, 0);
            this.Controls.SetChildIndex(this.btnTop, 0);
            this.Controls.SetChildIndex(this.btnStop, 0);
            this.Controls.SetChildIndex(this.lblDataPathAddr, 0);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.ListBox lstFormat;
        private System.Windows.Forms.Button btnOK;
        private System.Windows.Forms.Button btnCancel;
        internal System.Windows.Forms.CheckBox chkDevelopment;
        private System.Windows.Forms.Label lblDataPathAddr;
    }
}