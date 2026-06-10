namespace NKSConverter
{
    partial class ConfigSetting
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(ConfigSetting));
            this.Ip = new System.Windows.Forms.TextBox();
            this.Port = new System.Windows.Forms.TextBox();
            this.Passworld = new System.Windows.Forms.TextBox();
            this.UserName = new System.Windows.Forms.TextBox();
            this.label2 = new System.Windows.Forms.Label();
            this.Layout2 = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.label5 = new System.Windows.Forms.Label();
            this.DBTestButton = new System.Windows.Forms.Button();
            this.Skip = new System.Windows.Forms.Button();
            this.OK = new System.Windows.Forms.Button();
            this.BuildCheckBox = new System.Windows.Forms.CheckBox();
            this.label6 = new System.Windows.Forms.Label();
            this.URLText = new System.Windows.Forms.TextBox();
            this.URLTestButton = new System.Windows.Forms.Button();
            this.panel1 = new System.Windows.Forms.Panel();
            this.Balancer = new System.Windows.Forms.NumericUpDown();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.Local = new System.Windows.Forms.RadioButton();
            this.Cloud = new System.Windows.Forms.RadioButton();
            this.label7 = new System.Windows.Forms.Label();
            this.line2 = new System.Windows.Forms.Panel();
            this.Title = new System.Windows.Forms.Panel();
            this.line1 = new System.Windows.Forms.Panel();
            this.TitleName = new System.Windows.Forms.Label();
            this.panel3 = new System.Windows.Forms.Panel();
            this.panel1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.Balancer)).BeginInit();
            this.groupBox1.SuspendLayout();
            this.Title.SuspendLayout();
            this.SuspendLayout();
            // 
            // Ip
            // 
            this.Ip.Location = new System.Drawing.Point(165, 71);
            this.Ip.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.Ip.Name = "Ip";
            this.Ip.Size = new System.Drawing.Size(343, 22);
            this.Ip.TabIndex = 2;
            this.Ip.Text = "127.0.0.1";
            // 
            // Port
            // 
            this.Port.Location = new System.Drawing.Point(165, 104);
            this.Port.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.Port.Name = "Port";
            this.Port.Size = new System.Drawing.Size(53, 22);
            this.Port.TabIndex = 3;
            this.Port.Text = "1521";
            // 
            // Passworld
            // 
            this.Passworld.Location = new System.Drawing.Point(165, 176);
            this.Passworld.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.Passworld.Name = "Passworld";
            this.Passworld.Size = new System.Drawing.Size(148, 22);
            this.Passworld.TabIndex = 5;
            this.Passworld.Text = "nkk";
            this.Passworld.UseSystemPasswordChar = true;
            // 
            // UserName
            // 
            this.UserName.Location = new System.Drawing.Point(165, 140);
            this.UserName.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.UserName.Name = "UserName";
            this.UserName.Size = new System.Drawing.Size(148, 22);
            this.UserName.TabIndex = 4;
            this.UserName.Text = "nkk";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(13, 75);
            this.label2.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(138, 15);
            this.label2.TabIndex = 5;
            this.label2.Text = "FNW(oracle)接続先：";
            // 
            // Layout2
            // 
            this.Layout2.AutoSize = true;
            this.Layout2.Location = new System.Drawing.Point(108, 108);
            this.Layout2.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.Layout2.Name = "Layout2";
            this.Layout2.Size = new System.Drawing.Size(50, 15);
            this.Layout2.TabIndex = 6;
            this.Layout2.Text = "ポート：";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(76, 144);
            this.label4.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(78, 15);
            this.label4.TabIndex = 7;
            this.label4.Text = "ユーザー名：";
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(83, 180);
            this.label5.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(72, 15);
            this.label5.TabIndex = 8;
            this.label5.Text = "パスワード：";
            // 
            // DBTestButton
            // 
            this.DBTestButton.Location = new System.Drawing.Point(509, 172);
            this.DBTestButton.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.DBTestButton.Name = "DBTestButton";
            this.DBTestButton.Size = new System.Drawing.Size(109, 31);
            this.DBTestButton.TabIndex = 6;
            this.DBTestButton.Text = "DB接続テスト";
            this.DBTestButton.UseVisualStyleBackColor = true;
            this.DBTestButton.Click += new System.EventHandler(this.DBTestButton_Click);
            // 
            // Skip
            // 
            this.Skip.Location = new System.Drawing.Point(519, 338);
            this.Skip.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.Skip.Name = "Skip";
            this.Skip.Size = new System.Drawing.Size(100, 29);
            this.Skip.TabIndex = 12;
            this.Skip.Text = "Skip";
            this.Skip.UseVisualStyleBackColor = true;
            this.Skip.Click += new System.EventHandler(this.Skip_Click);
            // 
            // OK
            // 
            this.OK.Location = new System.Drawing.Point(409, 338);
            this.OK.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.OK.Name = "OK";
            this.OK.Size = new System.Drawing.Size(100, 29);
            this.OK.TabIndex = 11;
            this.OK.Text = "OK";
            this.OK.UseVisualStyleBackColor = true;
            this.OK.Click += new System.EventHandler(this.OK_Click);
            // 
            // BuildCheckBox
            // 
            this.BuildCheckBox.AutoSize = true;
            this.BuildCheckBox.Location = new System.Drawing.Point(165, 212);
            this.BuildCheckBox.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.BuildCheckBox.Name = "BuildCheckBox";
            this.BuildCheckBox.Size = new System.Drawing.Size(173, 19);
            this.BuildCheckBox.TabIndex = 7;
            this.BuildCheckBox.Text = "FNW(移行元)環境構築";
            this.BuildCheckBox.UseVisualStyleBackColor = true;
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Location = new System.Drawing.Point(28, 249);
            this.label6.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(124, 15);
            this.label6.TabIndex = 14;
            this.label6.Text = "サーバ接続先URL：";
            // 
            // URLText
            // 
            this.URLText.Location = new System.Drawing.Point(165, 245);
            this.URLText.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.URLText.Name = "URLText";
            this.URLText.Size = new System.Drawing.Size(343, 22);
            this.URLText.TabIndex = 8;
            this.URLText.Text = "http://127.0.0.1:8084";
            // 
            // URLTestButton
            // 
            this.URLTestButton.Location = new System.Drawing.Point(476, 278);
            this.URLTestButton.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.URLTestButton.Name = "URLTestButton";
            this.URLTestButton.Size = new System.Drawing.Size(143, 31);
            this.URLTestButton.TabIndex = 10;
            this.URLTestButton.Text = "サーバー接続テスト";
            this.URLTestButton.UseVisualStyleBackColor = true;
            this.URLTestButton.Click += new System.EventHandler(this.URLTestButton_Click);
            // 
            // panel1
            // 
            this.panel1.Controls.Add(this.Balancer);
            this.panel1.Controls.Add(this.groupBox1);
            this.panel1.Controls.Add(this.label7);
            this.panel1.Controls.Add(this.line2);
            this.panel1.Controls.Add(this.Skip);
            this.panel1.Controls.Add(this.OK);
            this.panel1.Controls.Add(this.label6);
            this.panel1.Controls.Add(this.URLText);
            this.panel1.Controls.Add(this.URLTestButton);
            this.panel1.Controls.Add(this.Ip);
            this.panel1.Controls.Add(this.Layout2);
            this.panel1.Controls.Add(this.Port);
            this.panel1.Controls.Add(this.label2);
            this.panel1.Controls.Add(this.BuildCheckBox);
            this.panel1.Controls.Add(this.DBTestButton);
            this.panel1.Controls.Add(this.UserName);
            this.panel1.Controls.Add(this.label4);
            this.panel1.Controls.Add(this.Passworld);
            this.panel1.Controls.Add(this.label5);
            this.panel1.Location = new System.Drawing.Point(0, 84);
            this.panel1.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(647, 381);
            this.panel1.TabIndex = 17;
            // 
            // Balancer
            // 
            this.Balancer.Location = new System.Drawing.Point(165, 282);
            this.Balancer.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.Balancer.Maximum = new decimal(new int[] {
            99,
            0,
            0,
            0});
            this.Balancer.Minimum = new decimal(new int[] {
            1,
            0,
            0,
            0});
            this.Balancer.Name = "Balancer";
            this.Balancer.Size = new System.Drawing.Size(72, 22);
            this.Balancer.TabIndex = 9;
            this.Balancer.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
            this.Balancer.Value = new decimal(new int[] {
            1,
            0,
            0,
            0});
            this.Balancer.Visible = false;
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.Local);
            this.groupBox1.Controls.Add(this.Cloud);
            this.groupBox1.Font = new System.Drawing.Font("Meiryo UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.groupBox1.Location = new System.Drawing.Point(15, 8);
            this.groupBox1.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Padding = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.groupBox1.Size = new System.Drawing.Size(299, 54);
            this.groupBox1.TabIndex = 19;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "環境：";
            // 
            // Local
            // 
            this.Local.AutoSize = true;
            this.Local.Checked = true;
            this.Local.Location = new System.Drawing.Point(140, 20);
            this.Local.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.Local.Name = "Local";
            this.Local.Size = new System.Drawing.Size(74, 23);
            this.Local.TabIndex = 1;
            this.Local.TabStop = true;
            this.Local.Text = "オンプレ";
            this.Local.UseVisualStyleBackColor = true;
            this.Local.CheckedChanged += new System.EventHandler(this.Local_CheckedChanged);
            // 
            // Cloud
            // 
            this.Cloud.AutoSize = true;
            this.Cloud.Location = new System.Drawing.Point(15, 20);
            this.Cloud.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.Cloud.Name = "Cloud";
            this.Cloud.Size = new System.Drawing.Size(72, 23);
            this.Cloud.TabIndex = 0;
            this.Cloud.Text = "クラウド";
            this.Cloud.UseVisualStyleBackColor = true;
            this.Cloud.CheckedChanged += new System.EventHandler(this.Cloud_CheckedChanged);
            // 
            // label7
            // 
            this.label7.AutoSize = true;
            this.label7.Location = new System.Drawing.Point(60, 286);
            this.label7.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(94, 15);
            this.label7.TabIndex = 17;
            this.label7.Text = "サーバー番号：";
            this.label7.Visible = false;
            // 
            // line2
            // 
            this.line2.BackColor = System.Drawing.SystemColors.ActiveBorder;
            this.line2.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.line2.Location = new System.Drawing.Point(0, 321);
            this.line2.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.line2.Name = "line2";
            this.line2.Size = new System.Drawing.Size(644, 0);
            this.line2.TabIndex = 13;
            // 
            // Title
            // 
            this.Title.BackColor = System.Drawing.SystemColors.ControlLightLight;
            this.Title.Controls.Add(this.line1);
            this.Title.Controls.Add(this.TitleName);
            this.Title.Controls.Add(this.panel3);
            this.Title.Location = new System.Drawing.Point(0, 0);
            this.Title.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.Title.Name = "Title";
            this.Title.Size = new System.Drawing.Size(647, 84);
            this.Title.TabIndex = 12;
            // 
            // line1
            // 
            this.line1.BackColor = System.Drawing.SystemColors.ActiveBorder;
            this.line1.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.line1.Location = new System.Drawing.Point(0, 82);
            this.line1.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.line1.Name = "line1";
            this.line1.Size = new System.Drawing.Size(644, 0);
            this.line1.TabIndex = 12;
            // 
            // TitleName
            // 
            this.TitleName.AutoSize = true;
            this.TitleName.Font = new System.Drawing.Font("MS UI Gothic", 14.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.TitleName.Location = new System.Drawing.Point(17, 28);
            this.TitleName.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.TitleName.Name = "TitleName";
            this.TitleName.Size = new System.Drawing.Size(207, 24);
            this.TitleName.TabIndex = 1;
            this.TitleName.Text = "アプリケーション設定";
            // 
            // panel3
            // 
            this.panel3.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("panel3.BackgroundImage")));
            this.panel3.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.panel3.Location = new System.Drawing.Point(557, 10);
            this.panel3.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.panel3.Name = "panel3";
            this.panel3.Size = new System.Drawing.Size(69, 61);
            this.panel3.TabIndex = 0;
            // 
            // ConfigSetting
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(645, 464);
            this.Controls.Add(this.Title);
            this.Controls.Add(this.panel1);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.MaximizeBox = false;
            this.Name = "ConfigSetting";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "FNWSi Convert Tool";
            this.TopMost = true;
            this.panel1.ResumeLayout(false);
            this.panel1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.Balancer)).EndInit();
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.Title.ResumeLayout(false);
            this.Title.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion
        private System.Windows.Forms.TextBox Ip;
        private System.Windows.Forms.TextBox Port;
        private System.Windows.Forms.TextBox Passworld;
        private System.Windows.Forms.TextBox UserName;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label Layout2;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.Button DBTestButton;
        private System.Windows.Forms.Button Skip;
        private System.Windows.Forms.Button OK;
        private System.Windows.Forms.CheckBox BuildCheckBox;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.TextBox URLText;
        private System.Windows.Forms.Button URLTestButton;
        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.RadioButton Local;
        private System.Windows.Forms.RadioButton Cloud;
        private System.Windows.Forms.Panel Title;
        private System.Windows.Forms.Panel panel3;
        private System.Windows.Forms.Label TitleName;
        private System.Windows.Forms.Panel line1;
        private System.Windows.Forms.Panel line2;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.NumericUpDown Balancer;
    }
}