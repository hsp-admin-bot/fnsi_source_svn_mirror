namespace LayoutDesigner
{
    partial class FrmFormatCondition
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
            this.btnOK = new System.Windows.Forms.Button();
            this.btnCancel = new System.Windows.Forms.Button();
            this.cboComparisonOperator = new System.Windows.Forms.ComboBox();
            this.txtValue = new System.Windows.Forms.TextBox();
            this.label1 = new System.Windows.Forms.Label();
            this.lblExample = new System.Windows.Forms.Label();
            this.btnFont = new System.Windows.Forms.Button();
            this.label3 = new System.Windows.Forms.Label();
            this.fontDialog1 = new System.Windows.Forms.FontDialog();
            this.BtnBackColor = new System.Windows.Forms.Button();
            this.colorDialog1 = new System.Windows.Forms.ColorDialog();
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
            this.winlblTitle.Size = new System.Drawing.Size(416, 18);
            this.winlblTitle.Text = "　条件付き書式";
            // 
            // btnOK
            // 
            this.btnOK.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnOK.DialogResult = System.Windows.Forms.DialogResult.OK;
            this.btnOK.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnOK.FlatAppearance.BorderSize = 2;
            this.btnOK.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnOK.ForeColor = System.Drawing.Color.White;
            this.btnOK.Location = new System.Drawing.Point(321, 242);
            this.btnOK.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.btnOK.Name = "btnOK";
            this.btnOK.Size = new System.Drawing.Size(87, 29);
            this.btnOK.TabIndex = 7;
            this.btnOK.Text = "OK";
            this.btnOK.Click += new System.EventHandler(this.btnOK_Click);
            // 
            // btnCancel
            // 
            this.btnCancel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.btnCancel.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnCancel.FlatAppearance.BorderSize = 2;
            this.btnCancel.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnCancel.ForeColor = System.Drawing.Color.White;
            this.btnCancel.Location = new System.Drawing.Point(227, 242);
            this.btnCancel.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(87, 29);
            this.btnCancel.TabIndex = 6;
            this.btnCancel.Text = "キャンセル";
            this.btnCancel.Click += new System.EventHandler(this.btnCancel_Click);
            // 
            // cboComparisonOperator
            // 
            this.cboComparisonOperator.FormattingEnabled = true;
            this.cboComparisonOperator.Items.AddRange(new object[] {
            "次の値に等しい",
            "次の値に等しくない",
            "次の値より大きい",
            "次の値より小さい",
            "次の値以上",
            "次の値以下"});
            this.cboComparisonOperator.Location = new System.Drawing.Point(13, 89);
            this.cboComparisonOperator.Name = "cboComparisonOperator";
            this.cboComparisonOperator.Size = new System.Drawing.Size(121, 23);
            this.cboComparisonOperator.TabIndex = 9;
            // 
            // txtValue
            // 
            this.txtValue.Location = new System.Drawing.Point(158, 89);
            this.txtValue.MaxLength = 20;
            this.txtValue.Name = "txtValue";
            this.txtValue.Size = new System.Drawing.Size(210, 23);
            this.txtValue.TabIndex = 10;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(14, 149);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(52, 15);
            this.label1.TabIndex = 11;
            this.label1.Text = "プレビュー:";
            // 
            // lblExample
            // 
            this.lblExample.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.lblExample.Location = new System.Drawing.Point(72, 141);
            this.lblExample.Name = "lblExample";
            this.lblExample.Size = new System.Drawing.Size(133, 30);
            this.lblExample.TabIndex = 12;
            this.lblExample.Text = "Aaあぁアァ亜宇";
            this.lblExample.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // btnFont
            // 
            this.btnFont.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnFont.FlatAppearance.BorderSize = 2;
            this.btnFont.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnFont.ForeColor = System.Drawing.Color.White;
            this.btnFont.Location = new System.Drawing.Point(227, 142);
            this.btnFont.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.btnFont.Name = "btnFont";
            this.btnFont.Size = new System.Drawing.Size(87, 29);
            this.btnFont.TabIndex = 13;
            this.btnFont.Text = "書式";
            this.btnFont.Click += new System.EventHandler(this.BtnFont_Click);
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(14, 40);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(153, 15);
            this.label3.TabIndex = 14;
            this.label3.Text = "ルールの内容を編集してください";
            // 
            // BtnBackColor
            // 
            this.BtnBackColor.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.BtnBackColor.FlatAppearance.BorderSize = 2;
            this.BtnBackColor.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.BtnBackColor.ForeColor = System.Drawing.Color.White;
            this.BtnBackColor.Location = new System.Drawing.Point(321, 142);
            this.BtnBackColor.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.BtnBackColor.Name = "BtnBackColor";
            this.BtnBackColor.Size = new System.Drawing.Size(87, 29);
            this.BtnBackColor.TabIndex = 15;
            this.BtnBackColor.Text = "背景色";
            this.BtnBackColor.Click += new System.EventHandler(this.BtnBackColor_Click);
            // 
            // FrmFormatCondition
            // 
            this.AcceptButton = this.btnOK;
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.CancelButton = this.btnCancel;
            this.ClientSize = new System.Drawing.Size(420, 284);
            this.Controls.Add(this.BtnBackColor);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.btnFont);
            this.Controls.Add(this.lblExample);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.txtValue);
            this.Controls.Add(this.cboComparisonOperator);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.btnOK);
            this.Margin = new System.Windows.Forms.Padding(3, 5, 3, 5);
            this.MinimumSize = new System.Drawing.Size(284, 284);
            this.Name = "FrmFormatCondition";
            this.Controls.SetChildIndex(this.btnOK, 0);
            this.Controls.SetChildIndex(this.btnCancel, 0);
            this.Controls.SetChildIndex(this.cboComparisonOperator, 0);
            this.Controls.SetChildIndex(this.txtValue, 0);
            this.Controls.SetChildIndex(this.label1, 0);
            this.Controls.SetChildIndex(this.lblExample, 0);
            this.Controls.SetChildIndex(this.btnFont, 0);
            this.Controls.SetChildIndex(this.winlblTitle, 0);
            this.Controls.SetChildIndex(this.btnFocusControl, 0);
            this.Controls.SetChildIndex(this.btnTop, 0);
            this.Controls.SetChildIndex(this.btnStop, 0);
            this.Controls.SetChildIndex(this.label3, 0);
            this.Controls.SetChildIndex(this.BtnBackColor, 0);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion
        private System.Windows.Forms.Button btnOK;
        private System.Windows.Forms.Button btnCancel;
        private System.Windows.Forms.ComboBox cboComparisonOperator;
        private System.Windows.Forms.TextBox txtValue;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label lblExample;
        private System.Windows.Forms.Button btnFont;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.FontDialog fontDialog1;
        private System.Windows.Forms.Button BtnBackColor;
        private System.Windows.Forms.ColorDialog colorDialog1;
    }
}