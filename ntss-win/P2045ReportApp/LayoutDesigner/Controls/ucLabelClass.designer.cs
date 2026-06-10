namespace ExcelReportTool
{
    partial class ucLabelClass
    {
        /// <summary> 
        /// 必要なデザイナ変数です。
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary> 
        /// 使用中のリソースをすべてクリーンアップします。
        /// </summary>
        /// <param name="disposing">マネージ リソースが破棄される場合 true、破棄されない場合は false です。</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region コンポーネント デザイナで生成されたコード

        /// <summary> 
        /// デザイナ サポートに必要なメソッドです。このメソッドの内容を 
        /// コード エディタで変更しないでください。
        /// </summary>
        private void InitializeComponent()
        {
            this.lblTitle = new System.Windows.Forms.Label();
            this.cmbLabelClass = new System.Windows.Forms.ComboBox();
            this.txtFixString = new System.Windows.Forms.TextBox();
            this.SuspendLayout();
            // 
            // lblTitle
            // 
            this.lblTitle.AutoSize = true;
            this.lblTitle.Location = new System.Drawing.Point(-2, 4);
            this.lblTitle.Name = "lblTitle";
            this.lblTitle.Size = new System.Drawing.Size(40, 12);
            this.lblTitle.TabIndex = 0;
            this.lblTitle.Text = "タイトル";
            // 
            // cmbLabelClass
            // 
            this.cmbLabelClass.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cmbLabelClass.FormattingEnabled = true;
            this.cmbLabelClass.IntegralHeight = false;
            this.cmbLabelClass.Location = new System.Drawing.Point(67, 0);
            this.cmbLabelClass.MaxDropDownItems = 20;
            this.cmbLabelClass.Name = "cmbLabelClass";
            this.cmbLabelClass.Size = new System.Drawing.Size(155, 20);
            this.cmbLabelClass.TabIndex = 1;
            this.cmbLabelClass.SelectedValueChanged += new System.EventHandler(this.cmbLabelClass_SelectedValueChanged);
            // 
            // txtFixString
            // 
            this.txtFixString.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)
                        | System.Windows.Forms.AnchorStyles.Right)));
            this.txtFixString.Location = new System.Drawing.Point(228, 0);
            this.txtFixString.Name = "txtFixString";
            this.txtFixString.Size = new System.Drawing.Size(240, 19);
            this.txtFixString.TabIndex = 2;
            this.txtFixString.TextChanged += new System.EventHandler(this.txtFixString_TextChanged);
            // 
            // ucLabelClass
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.txtFixString);
            this.Controls.Add(this.cmbLabelClass);
            this.Controls.Add(this.lblTitle);
            this.Name = "ucLabelClass";
            this.Size = new System.Drawing.Size(468, 20);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label lblTitle;
        private System.Windows.Forms.ComboBox cmbLabelClass;
        private System.Windows.Forms.TextBox txtFixString;
    }
}
