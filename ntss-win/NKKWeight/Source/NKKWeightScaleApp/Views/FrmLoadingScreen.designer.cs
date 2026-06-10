namespace NKKWeightScaleApp.Views
{
    partial class FrmLoadingScreen
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
            this.txtInputID = new System.Windows.Forms.TextBox();
            this.grbLoadingScreen = new System.Windows.Forms.GroupBox();
            this.label2 = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.btnSearch = new System.Windows.Forms.Button();
            this.grbLoadingScreen.SuspendLayout();
            this.SuspendLayout();
            // 
            // txtInputID
            // 
            this.txtInputID.Font = new System.Drawing.Font("Microsoft Sans Serif", 48F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.txtInputID.Location = new System.Drawing.Point(6, 200);
            this.txtInputID.MaxLength = 12;
            this.txtInputID.Name = "txtInputID";
            this.txtInputID.Size = new System.Drawing.Size(613, 80);
            this.txtInputID.TabIndex = 0;
            this.txtInputID.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            this.txtInputID.TextChanged += new System.EventHandler(this.txtInputID_TextChanged);
            this.txtInputID.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.txtInputID_KeyPress);
            // 
            // grbLoadingScreen
            // 
            this.grbLoadingScreen.Controls.Add(this.label2);
            this.grbLoadingScreen.Controls.Add(this.label1);
            this.grbLoadingScreen.Controls.Add(this.btnSearch);
            this.grbLoadingScreen.Controls.Add(this.txtInputID);
            this.grbLoadingScreen.Location = new System.Drawing.Point(12, 12);
            this.grbLoadingScreen.Name = "grbLoadingScreen";
            this.grbLoadingScreen.Size = new System.Drawing.Size(807, 340);
            this.grbLoadingScreen.TabIndex = 1;
            this.grbLoadingScreen.TabStop = false;
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Font = new System.Drawing.Font("Microsoft Sans Serif", 20F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.label2.Location = new System.Drawing.Point(153, 85);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(507, 31);
            this.label2.TabIndex = 2;
            this.label2.Text = "患者を選択するか患者カードを置いてください。";
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 35F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.label1.ForeColor = System.Drawing.Color.Red;
            this.label1.Location = new System.Drawing.Point(76, 16);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(655, 54);
            this.label1.TabIndex = 2;
            this.label1.Text = "障害発生時用体重測定システム";
            // 
            // btnSearch
            // 
            this.btnSearch.BackColor = System.Drawing.Color.Orange;
            this.btnSearch.Font = new System.Drawing.Font("Microsoft Sans Serif", 30F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.btnSearch.ForeColor = System.Drawing.SystemColors.Control;
            this.btnSearch.Location = new System.Drawing.Point(625, 199);
            this.btnSearch.Name = "btnSearch";
            this.btnSearch.Size = new System.Drawing.Size(176, 81);
            this.btnSearch.TabIndex = 1;
            this.btnSearch.Text = "検索";
            this.btnSearch.UseVisualStyleBackColor = false;
            this.btnSearch.Click += new System.EventHandler(this.btnSearch_Click);
            // 
            // FrmLoadingScreen
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(839, 367);
            this.Controls.Add(this.grbLoadingScreen);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.KeyPreview = true;
            this.MaximizeBox = false;
            this.Name = "FrmLoadingScreen";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "読み取り画面";
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.FrmLoadingScreen_FormClosed);
            this.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.FrmLoadingScreen_KeyPress);
            this.grbLoadingScreen.ResumeLayout(false);
            this.grbLoadingScreen.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.TextBox txtInputID;
        private System.Windows.Forms.GroupBox grbLoadingScreen;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Button btnSearch;
        private System.Windows.Forms.Label label2;
    }
}