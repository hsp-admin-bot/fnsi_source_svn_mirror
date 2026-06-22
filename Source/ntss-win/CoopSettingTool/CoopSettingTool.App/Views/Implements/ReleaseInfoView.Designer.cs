
namespace CoopSettingTool.App.Views
{
    partial class ReleaseInfoView
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
            this.dgvReleaseInfo = new System.Windows.Forms.DataGridView();
            this.btnClose = new MaterialSkin.Controls.MaterialRaisedButton();
            ((System.ComponentModel.ISupportInitialize)(this.dgvReleaseInfo)).BeginInit();
            this.SuspendLayout();
            // 
            // dgvReleaseInfo
            // 
            this.dgvReleaseInfo.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvReleaseInfo.Enabled = false;
            this.dgvReleaseInfo.Location = new System.Drawing.Point(12, 71);
            this.dgvReleaseInfo.Name = "dgvReleaseInfo";
            this.dgvReleaseInfo.RowTemplate.Height = 21;
            this.dgvReleaseInfo.Size = new System.Drawing.Size(876, 488);
            this.dgvReleaseInfo.TabIndex = 1;
            // 
            // btnClose
            // 
            this.btnClose.Depth = 0;
            this.btnClose.Location = new System.Drawing.Point(798, 565);
            this.btnClose.MouseState = MaterialSkin.MouseState.HOVER;
            this.btnClose.Name = "btnClose";
            this.btnClose.Primary = true;
            this.btnClose.Size = new System.Drawing.Size(90, 23);
            this.btnClose.TabIndex = 26;
            this.btnClose.Text = "閉じる";
            this.btnClose.UseVisualStyleBackColor = true;
            // 
            // ReleaseInfoView
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(900, 600);
            this.Controls.Add(this.btnClose);
            this.Controls.Add(this.dgvReleaseInfo);
            this.MaximizeBox = true;
            this.Name = "ReleaseInfoView";
            this.Sizable = true;
            this.Text = "リリース情報";
            ((System.ComponentModel.ISupportInitialize)(this.dgvReleaseInfo)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.DataGridView dgvReleaseInfo;
        private MaterialSkin.Controls.MaterialRaisedButton btnClose;
    }
}