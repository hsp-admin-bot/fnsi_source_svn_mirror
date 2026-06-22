
namespace FNSiViewSyncTool
{
    partial class ModifyInstallParameterUpdate
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
            this.panel1 = new System.Windows.Forms.Panel();
            this.label8 = new System.Windows.Forms.Label();
            this.label7 = new System.Windows.Forms.Label();
            this.label6 = new System.Windows.Forms.Label();
            this.btnConfirm = new System.Windows.Forms.Button();
            this.label9 = new System.Windows.Forms.Label();
            this.groupBox6 = new System.Windows.Forms.GroupBox();
            this.ViewSettingCloud = new System.Windows.Forms.RadioButton();
            this.ViewSettingOnpre = new System.Windows.Forms.RadioButton();
            this.label1 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.panel1.SuspendLayout();
            this.groupBox6.SuspendLayout();
            this.SuspendLayout();
            // 
            // panel1
            // 
            this.panel1.BackColor = System.Drawing.Color.White;
            this.panel1.Controls.Add(this.label8);
            this.panel1.Controls.Add(this.label7);
            this.panel1.Font = new System.Drawing.Font("MS UI Gothic", 20F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.panel1.Location = new System.Drawing.Point(0, 0);
            this.panel1.Margin = new System.Windows.Forms.Padding(2, 1, 2, 1);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(445, 113);
            this.panel1.TabIndex = 0;
            // 
            // label8
            // 
            this.label8.AutoSize = true;
            this.label8.Location = new System.Drawing.Point(72, 49);
            this.label8.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.label8.Name = "label8";
            this.label8.Size = new System.Drawing.Size(279, 27);
            this.label8.TabIndex = 1;
            this.label8.Text = "構成ファイルを変更します";
            // 
            // label7
            // 
            this.label7.AutoSize = true;
            this.label7.Font = new System.Drawing.Font("MS UI Gothic", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.label7.Location = new System.Drawing.Point(7, 7);
            this.label7.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(137, 12);
            this.label7.TabIndex = 0;
            this.label7.Text = "FNSiViewSyncService";
            // 
            // label6
            // 
            this.label6.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.label6.Location = new System.Drawing.Point(0, 280);
            this.label6.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(445, 1);
            this.label6.TabIndex = 11;
            this.label6.Text = "label6";
            // 
            // btnConfirm
            // 
            this.btnConfirm.FlatAppearance.BorderColor = System.Drawing.Color.Blue;
            this.btnConfirm.FlatAppearance.BorderSize = 3;
            this.btnConfirm.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(192)))), ((int)(((byte)(255)))), ((int)(((byte)(255)))));
            this.btnConfirm.FlatAppearance.MouseOverBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(192)))), ((int)(((byte)(255)))), ((int)(((byte)(255)))));
            this.btnConfirm.Location = new System.Drawing.Point(357, 295);
            this.btnConfirm.Margin = new System.Windows.Forms.Padding(2, 1, 2, 1);
            this.btnConfirm.Name = "btnConfirm";
            this.btnConfirm.Size = new System.Drawing.Size(75, 23);
            this.btnConfirm.TabIndex = 90;
            this.btnConfirm.Text = "確認";
            this.btnConfirm.UseVisualStyleBackColor = true;
            this.btnConfirm.Click += new System.EventHandler(this.btnConfirm_Click);
            // 
            // label9
            // 
            this.label9.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.label9.Location = new System.Drawing.Point(0, 113);
            this.label9.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.label9.Name = "label9";
            this.label9.Size = new System.Drawing.Size(892, 1);
            this.label9.TabIndex = 1;
            this.label9.Text = "label9";
            // 
            // groupBox6
            // 
            this.groupBox6.Controls.Add(this.ViewSettingCloud);
            this.groupBox6.Controls.Add(this.ViewSettingOnpre);
            this.groupBox6.Location = new System.Drawing.Point(12, 203);
            this.groupBox6.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.groupBox6.Name = "groupBox6";
            this.groupBox6.Padding = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.groupBox6.Size = new System.Drawing.Size(422, 48);
            this.groupBox6.TabIndex = 4;
            this.groupBox6.TabStop = false;
            this.groupBox6.Text = "VIEW連携設定";
            // 
            // ViewSettingCloud
            // 
            this.ViewSettingCloud.AutoSize = true;
            this.ViewSettingCloud.Location = new System.Drawing.Point(129, 22);
            this.ViewSettingCloud.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.ViewSettingCloud.Name = "ViewSettingCloud";
            this.ViewSettingCloud.Size = new System.Drawing.Size(69, 16);
            this.ViewSettingCloud.TabIndex = 1;
            this.ViewSettingCloud.Text = "クラウド版";
            this.ViewSettingCloud.UseVisualStyleBackColor = true;
            // 
            // ViewSettingOnpre
            // 
            this.ViewSettingOnpre.AutoSize = true;
            this.ViewSettingOnpre.Checked = true;
            this.ViewSettingOnpre.Location = new System.Drawing.Point(37, 22);
            this.ViewSettingOnpre.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.ViewSettingOnpre.Name = "ViewSettingOnpre";
            this.ViewSettingOnpre.Size = new System.Drawing.Size(71, 16);
            this.ViewSettingOnpre.TabIndex = 0;
            this.ViewSettingOnpre.TabStop = true;
            this.ViewSettingOnpre.Text = "オンプレ版";
            this.ViewSettingOnpre.UseVisualStyleBackColor = true;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(12, 127);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(203, 12);
            this.label1.TabIndex = 2;
            this.label1.Text = "構成ファイルに追加される設定があります。";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(12, 145);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(189, 12);
            this.label2.TabIndex = 101;
            this.label2.Text = "追加項目以外の値は変更されません。";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(12, 173);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(172, 12);
            this.label3.TabIndex = 102;
            this.label3.Text = "VIEW連携設定を選択してください。";
            // 
            // ModifyInstallParameterUpdate
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(445, 333);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.groupBox6);
            this.Controls.Add(this.label9);
            this.Controls.Add(this.btnConfirm);
            this.Controls.Add(this.label6);
            this.Controls.Add(this.panel1);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            this.Margin = new System.Windows.Forms.Padding(2, 1, 2, 1);
            this.Name = "ModifyInstallParameterUpdate";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "FNSIViewSyncServiceser";
            this.TopMost = true;
            this.panel1.ResumeLayout(false);
            this.panel1.PerformLayout();
            this.groupBox6.ResumeLayout(false);
            this.groupBox6.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion
        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.Label label8;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.Button btnConfirm;
        private System.Windows.Forms.Label label9;
        private System.Windows.Forms.GroupBox groupBox6;
        private System.Windows.Forms.RadioButton ViewSettingCloud;
        private System.Windows.Forms.RadioButton ViewSettingOnpre;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label3;
    }
}