namespace NKK.BloodPurify
{
    partial class FrmIQ21
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

        #region Windows フォーム デザイナで生成されたコード

        /// <summary>
        /// デザイナ サポートに必要なメソッドです。このメソッドの内容を
        /// コード エディタで変更しないでください。
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FrmIQ21));
            this.LblMonitor = new System.Windows.Forms.Label();
            this.LstBox = new System.Windows.Forms.ListBox();
            this.SuspendLayout();
            // 
            // LblTreatStatus
            // 
            this.LblTreatStatus.Font = new System.Drawing.Font("Yu Gothic UI", 14.25F);
            // 
            // LblMonitor
            // 
            this.LblMonitor.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.LblMonitor.BackColor = System.Drawing.SystemColors.ButtonShadow;
            this.LblMonitor.Font = new System.Drawing.Font("Yu Gothic UI", 18F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.LblMonitor.Location = new System.Drawing.Point(6, 120);
            this.LblMonitor.Name = "LblMonitor";
            this.LblMonitor.Size = new System.Drawing.Size(1012, 195);
            this.LblMonitor.TabIndex = 0;
            this.LblMonitor.Text = "[モニタデータ]";
            // 
            // LstBox
            // 
            this.LstBox.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.LstBox.BackColor = System.Drawing.SystemColors.ButtonShadow;
            this.LstBox.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.LstBox.Font = new System.Drawing.Font("Yu Gothic UI", 18F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.LstBox.ForeColor = System.Drawing.Color.White;
            this.LstBox.FormattingEnabled = true;
            this.LstBox.ItemHeight = 32;
            this.LstBox.Items.AddRange(new object[] {
            "[その他データ]"});
            this.LstBox.Location = new System.Drawing.Point(6, 349);
            this.LstBox.Name = "LstBox";
            this.LstBox.SelectionMode = System.Windows.Forms.SelectionMode.None;
            this.LstBox.Size = new System.Drawing.Size(1012, 288);
            this.LstBox.TabIndex = 2;
            this.LstBox.KeyDown += new System.Windows.Forms.KeyEventHandler(this.LstBox_KeyDown);
            // 
            // FrmIQ21
            // 
            this.ClientSize = new System.Drawing.Size(1024, 768);
            this.Controls.Add(this.LstBox);
            this.Controls.Add(this.LblMonitor);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "FrmIQ21";
            this.Text = "SetTitleを呼んでセットします";
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.FrmIQ21_FormClosed);
            this.Load += new System.EventHandler(this.FrmIQ21_Load);
            this.Controls.SetChildIndex(this.LblTreatStatus, 0);
            this.Controls.SetChildIndex(this.LblMonitor, 0);
            this.Controls.SetChildIndex(this.LstBox, 0);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label LblMonitor;
        private System.Windows.Forms.ListBox LstBox;

    }
}
