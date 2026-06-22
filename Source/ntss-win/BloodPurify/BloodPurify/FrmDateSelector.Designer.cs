namespace NKK.BloodPurify
{
    partial class FrmDateSelector
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
            if (disposing && (components != null))
            {
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FrmDateSelector));
            this.MonthCalendar = new NKK.BloodPurify.ExMonthCalendar();
            this.BtnCancel = new NKK.BloodPurify.ExBtnNoFocus();
            this.BtnOk = new NKK.BloodPurify.ExBtnNoFocus();
            this.SuspendLayout();
            // 
            // MonthCalendar
            // 
            this.MonthCalendar.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.MonthCalendar.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(115)))), ((int)(((byte)(115)))), ((int)(((byte)(115)))));
            this.MonthCalendar.Font = new System.Drawing.Font("Yu Gothic UI", 14.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.MonthCalendar.ForeColor = System.Drawing.Color.White;
            this.MonthCalendar.Location = new System.Drawing.Point(35, 42);
            this.MonthCalendar.MaxSelectionCount = 1;
            this.MonthCalendar.Name = "MonthCalendar";
            this.MonthCalendar.TabIndex = 1;
            this.MonthCalendar.TitleBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(64)))), ((int)(((byte)(64)))), ((int)(((byte)(64)))));
            this.MonthCalendar.TitleForeColor = System.Drawing.Color.White;
            this.MonthCalendar.TrailingForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(64)))), ((int)(((byte)(64)))), ((int)(((byte)(64)))));
            this.MonthCalendar.MyDoubleClick += new NKK.BloodPurify.ExMonthCalendar.OnMyDoubleClickEventHandler(this.MonthCalendar_MyDoubleClick);
            this.MonthCalendar.KeyDown += new System.Windows.Forms.KeyEventHandler(this.MonthCalendar_KeyDown);
            // 
            // BtnCancel
            // 
            this.BtnCancel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.BtnCancel.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.BtnCancel.FlatAppearance.BorderColor = System.Drawing.SystemColors.ButtonShadow;
            this.BtnCancel.FlatAppearance.BorderSize = 2;
            this.BtnCancel.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.BtnCancel.Font = new System.Drawing.Font("Yu Gothic UI", 18F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.BtnCancel.ForeColor = System.Drawing.Color.White;
            this.BtnCancel.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.BtnCancel.Location = new System.Drawing.Point(218, 333);
            this.BtnCancel.Name = "BtnCancel";
            this.BtnCancel.Size = new System.Drawing.Size(150, 55);
            this.BtnCancel.TabIndex = 0;
            this.BtnCancel.TabStop = false;
            this.BtnCancel.Text = "キャンセル";
            this.BtnCancel.UseVisualStyleBackColor = false;
            this.BtnCancel.Click += new System.EventHandler(this.BtnCancel_Click);
            // 
            // BtnOk
            // 
            this.BtnOk.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.BtnOk.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.BtnOk.FlatAppearance.BorderColor = System.Drawing.SystemColors.ButtonShadow;
            this.BtnOk.FlatAppearance.BorderSize = 2;
            this.BtnOk.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.BtnOk.Font = new System.Drawing.Font("Yu Gothic UI", 18F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.BtnOk.ForeColor = System.Drawing.Color.White;
            this.BtnOk.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.BtnOk.Location = new System.Drawing.Point(12, 333);
            this.BtnOk.Name = "BtnOk";
            this.BtnOk.Size = new System.Drawing.Size(150, 55);
            this.BtnOk.TabIndex = 0;
            this.BtnOk.TabStop = false;
            this.BtnOk.Text = "OK";
            this.BtnOk.UseVisualStyleBackColor = false;
            this.BtnOk.Click += new System.EventHandler(this.BtnOk_Click);
            // 
            // FrmDateSelector
            // 
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.ClientSize = new System.Drawing.Size(380, 400);
            this.Controls.Add(this.BtnCancel);
            this.Controls.Add(this.BtnOk);
            this.Controls.Add(this.MonthCalendar);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.MinimumSize = new System.Drawing.Size(380, 400);
            this.Name = "FrmDateSelector";
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.FrmDateSelector_FormClosed);
            this.Load += new System.EventHandler(this.FrmDateSelector_Load);
            this.Controls.SetChildIndex(this.MonthCalendar, 0);
            this.Controls.SetChildIndex(this.BtnOk, 0);
            this.Controls.SetChildIndex(this.BtnCancel, 0);
            this.ResumeLayout(false);

        }

        #endregion
        private ExBtnNoFocus BtnCancel;
        private ExBtnNoFocus BtnOk;
        public ExMonthCalendar MonthCalendar;
    }
}
