namespace NKK.BloodPurify
{
    partial class FrmKM8900
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FrmKM8900));
            this.SuspendLayout();
            // 
            // LblTreatStatus
            // 
            this.LblTreatStatus.Font = new System.Drawing.Font("Yu Gothic UI", 14.25F);
            // 
            // FrmKM8900
            // 
            this.ClientSize = new System.Drawing.Size(1024, 768);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "FrmKM8900";
            this.Text = "SetTitleを呼んでセットします";
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.FrmKM8900_FormClosed);
            this.Load += new System.EventHandler(this.FrmKM8900_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion
    }
}
