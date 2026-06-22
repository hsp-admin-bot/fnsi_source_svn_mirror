
namespace NKKAccessCardService
{
    partial class ModifyInstallParameter
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
            this.label19 = new System.Windows.Forms.Label();
            this.label17 = new System.Windows.Forms.Label();
            this.label6 = new System.Windows.Forms.Label();
            this.KeepNumberOfDays = new System.Windows.Forms.TextBox();
            this.btnConfirm = new System.Windows.Forms.Button();
            this.btnConcel = new System.Windows.Forms.Button();
            this.label20 = new System.Windows.Forms.Label();
            this.label21 = new System.Windows.Forms.Label();
            this.rbtnNoCer = new System.Windows.Forms.RadioButton();
            this.rbtnUseCer = new System.Windows.Forms.RadioButton();
            this.label12 = new System.Windows.Forms.Label();
            this.dtUpdateTime = new System.Windows.Forms.DateTimePicker();
            this.txtUrl = new System.Windows.Forms.TextBox();
            this.label7 = new System.Windows.Forms.Label();
            this.label5 = new System.Windows.Forms.Label();
            this.panel1.SuspendLayout();
            this.SuspendLayout();
            // 
            // panel1
            // 
            this.panel1.BackColor = System.Drawing.Color.White;
            this.panel1.Controls.Add(this.label19);
            this.panel1.Controls.Add(this.label17);
            this.panel1.Location = new System.Drawing.Point(0, 0);
            this.panel1.Margin = new System.Windows.Forms.Padding(2);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(636, 114);
            this.panel1.TabIndex = 0;
            // 
            // label19
            // 
            this.label19.AutoSize = true;
            this.label19.Font = new System.Drawing.Font("MS UI Gothic", 20F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.label19.Location = new System.Drawing.Point(73, 49);
            this.label19.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.label19.Name = "label19";
            this.label19.Size = new System.Drawing.Size(279, 27);
            this.label19.TabIndex = 1;
            this.label19.Text = "構成ファイルを変更します";
            // 
            // label17
            // 
            this.label17.AutoSize = true;
            this.label17.Font = new System.Drawing.Font("MS UI Gothic", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.label17.Location = new System.Drawing.Point(8, 8);
            this.label17.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.label17.Name = "label17";
            this.label17.Size = new System.Drawing.Size(102, 12);
            this.label17.TabIndex = 0;
            this.label17.Text = "FNWSi Access Card";
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Location = new System.Drawing.Point(11, 271);
            this.label6.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(71, 12);
            this.label6.TabIndex = 6;
            this.label6.Text = "ログ保持日数";
            this.label6.Visible = false;
            // 
            // KeepNumberOfDays
            // 
            this.KeepNumberOfDays.Location = new System.Drawing.Point(86, 268);
            this.KeepNumberOfDays.Margin = new System.Windows.Forms.Padding(2);
            this.KeepNumberOfDays.Name = "KeepNumberOfDays";
            this.KeepNumberOfDays.Size = new System.Drawing.Size(47, 19);
            this.KeepNumberOfDays.TabIndex = 5;
            this.KeepNumberOfDays.Visible = false;
            // 
            // btnConfirm
            // 
            this.btnConfirm.FlatAppearance.BorderColor = System.Drawing.Color.Blue;
            this.btnConfirm.FlatAppearance.BorderSize = 3;
            this.btnConfirm.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(192)))), ((int)(((byte)(255)))), ((int)(((byte)(255)))));
            this.btnConfirm.FlatAppearance.MouseOverBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(192)))), ((int)(((byte)(255)))), ((int)(((byte)(255)))));
            this.btnConfirm.Location = new System.Drawing.Point(444, 271);
            this.btnConfirm.Margin = new System.Windows.Forms.Padding(2);
            this.btnConfirm.Name = "btnConfirm";
            this.btnConfirm.Size = new System.Drawing.Size(75, 22);
            this.btnConfirm.TabIndex = 90;
            this.btnConfirm.Text = "保存";
            this.btnConfirm.UseVisualStyleBackColor = true;
            this.btnConfirm.Click += new System.EventHandler(this.btnConfirm_Click);
            // 
            // btnConcel
            // 
            this.btnConcel.FlatAppearance.BorderColor = System.Drawing.Color.Blue;
            this.btnConcel.FlatAppearance.BorderSize = 3;
            this.btnConcel.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(192)))), ((int)(((byte)(255)))), ((int)(((byte)(255)))));
            this.btnConcel.FlatAppearance.MouseOverBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(192)))), ((int)(((byte)(255)))), ((int)(((byte)(255)))));
            this.btnConcel.Location = new System.Drawing.Point(550, 271);
            this.btnConcel.Margin = new System.Windows.Forms.Padding(2);
            this.btnConcel.Name = "btnConcel";
            this.btnConcel.Size = new System.Drawing.Size(75, 22);
            this.btnConcel.TabIndex = 100;
            this.btnConcel.Text = "変更しない";
            this.btnConcel.UseVisualStyleBackColor = true;
            this.btnConcel.Click += new System.EventHandler(this.btnConcel_Click);
            // 
            // label20
            // 
            this.label20.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.label20.Location = new System.Drawing.Point(0, 247);
            this.label20.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.label20.Name = "label20";
            this.label20.Size = new System.Drawing.Size(636, 2);
            this.label20.TabIndex = 38;
            this.label20.Text = "label20";
            // 
            // label21
            // 
            this.label21.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.label21.Location = new System.Drawing.Point(0, 114);
            this.label21.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.label21.Name = "label21";
            this.label21.Size = new System.Drawing.Size(867, 2);
            this.label21.TabIndex = 39;
            this.label21.Text = "label21";
            // 
            // rbtnNoCer
            // 
            this.rbtnNoCer.AutoSize = true;
            this.rbtnNoCer.Location = new System.Drawing.Point(333, 168);
            this.rbtnNoCer.Name = "rbtnNoCer";
            this.rbtnNoCer.Size = new System.Drawing.Size(76, 16);
            this.rbtnNoCer.TabIndex = 133;
            this.rbtnNoCer.TabStop = true;
            this.rbtnNoCer.Text = "使用しない";
            this.rbtnNoCer.UseVisualStyleBackColor = true;
            // 
            // rbtnUseCer
            // 
            this.rbtnUseCer.AutoSize = true;
            this.rbtnUseCer.Location = new System.Drawing.Point(175, 168);
            this.rbtnUseCer.Name = "rbtnUseCer";
            this.rbtnUseCer.Size = new System.Drawing.Size(66, 16);
            this.rbtnUseCer.TabIndex = 132;
            this.rbtnUseCer.TabStop = true;
            this.rbtnUseCer.Text = "使用する";
            this.rbtnUseCer.UseVisualStyleBackColor = true;
            // 
            // label12
            // 
            this.label12.AutoSize = true;
            this.label12.Location = new System.Drawing.Point(11, 213);
            this.label12.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.label12.Name = "label12";
            this.label12.Size = new System.Drawing.Size(130, 12);
            this.label12.TabIndex = 131;
            this.label12.Text = "自動アップデート実行時刻";
            // 
            // dtUpdateTime
            // 
            this.dtUpdateTime.CustomFormat = "HH:mm";
            this.dtUpdateTime.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtUpdateTime.Location = new System.Drawing.Point(175, 208);
            this.dtUpdateTime.Name = "dtUpdateTime";
            this.dtUpdateTime.ShowUpDown = true;
            this.dtUpdateTime.Size = new System.Drawing.Size(47, 19);
            this.dtUpdateTime.TabIndex = 130;
            this.dtUpdateTime.Value = new System.DateTime(9998, 12, 31, 0, 0, 0, 0);
            // 
            // txtUrl
            // 
            this.txtUrl.Location = new System.Drawing.Point(175, 127);
            this.txtUrl.Margin = new System.Windows.Forms.Padding(2);
            this.txtUrl.Name = "txtUrl";
            this.txtUrl.Size = new System.Drawing.Size(412, 19);
            this.txtUrl.TabIndex = 128;
            // 
            // label7
            // 
            this.label7.AutoSize = true;
            this.label7.Location = new System.Drawing.Point(11, 133);
            this.label7.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(73, 12);
            this.label7.TabIndex = 127;
            this.label7.Text = "サインインURL";
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(11, 173);
            this.label5.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(92, 12);
            this.label5.TabIndex = 126;
            this.label5.Text = "クライアント証明書";
            // 
            // ModifyInstallParameter
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(636, 316);
            this.Controls.Add(this.rbtnNoCer);
            this.Controls.Add(this.rbtnUseCer);
            this.Controls.Add(this.label12);
            this.Controls.Add(this.dtUpdateTime);
            this.Controls.Add(this.txtUrl);
            this.Controls.Add(this.label7);
            this.Controls.Add(this.label5);
            this.Controls.Add(this.label21);
            this.Controls.Add(this.label20);
            this.Controls.Add(this.btnConcel);
            this.Controls.Add(this.btnConfirm);
            this.Controls.Add(this.KeepNumberOfDays);
            this.Controls.Add(this.label6);
            this.Controls.Add(this.panel1);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            this.Margin = new System.Windows.Forms.Padding(2);
            this.Name = "ModifyInstallParameter";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "FNWSi Access Card";
            this.TopMost = true;
            this.panel1.ResumeLayout(false);
            this.panel1.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.TextBox KeepNumberOfDays;
        private System.Windows.Forms.Button btnConfirm;
        private System.Windows.Forms.Button btnConcel;
        private System.Windows.Forms.Label label19;
        private System.Windows.Forms.Label label17;
        private System.Windows.Forms.Label label20;
        private System.Windows.Forms.Label label21;
        private System.Windows.Forms.RadioButton rbtnNoCer;
        private System.Windows.Forms.RadioButton rbtnUseCer;
        private System.Windows.Forms.Label label12;
        private System.Windows.Forms.DateTimePicker dtUpdateTime;
        private System.Windows.Forms.TextBox txtUrl;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.Label label5;
    }
}
