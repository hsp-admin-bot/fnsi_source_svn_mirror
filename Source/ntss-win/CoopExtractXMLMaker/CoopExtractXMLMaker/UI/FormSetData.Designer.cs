
namespace CoopExtractXMLMaker
{
    partial class FormSetData
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
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.label1 = new System.Windows.Forms.Label();
            this.txtFNWCsvPath = new System.Windows.Forms.TextBox();
            this.btnFNWCsv = new System.Windows.Forms.Button();
            this.btnNext = new System.Windows.Forms.Button();
            this.btnExit = new System.Windows.Forms.Button();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.groupBox3 = new System.Windows.Forms.GroupBox();
            this.txtJson = new System.Windows.Forms.TextBox();
            this.chkJson = new System.Windows.Forms.CheckBox();
            this.label2 = new System.Windows.Forms.Label();
            this.txtFNSiCsvPath = new System.Windows.Forms.TextBox();
            this.btnFNSiCsv = new System.Windows.Forms.Button();
            this.rdoFromDefinition = new System.Windows.Forms.RadioButton();
            this.groupBox4 = new System.Windows.Forms.GroupBox();
            this.rdoXMLReedit = new System.Windows.Forms.RadioButton();
            this.groupBox5 = new System.Windows.Forms.GroupBox();
            this.label3 = new System.Windows.Forms.Label();
            this.txtXMLReeditPath = new System.Windows.Forms.TextBox();
            this.btnXMLReedit = new System.Windows.Forms.Button();
            this.rdoOverwriteDefaultDefinition = new System.Windows.Forms.RadioButton();
            this.groupBox1.SuspendLayout();
            this.groupBox2.SuspendLayout();
            this.groupBox3.SuspendLayout();
            this.groupBox4.SuspendLayout();
            this.groupBox5.SuspendLayout();
            this.SuspendLayout();
            // 
            // groupBox1
            // 
            this.groupBox1.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.groupBox1.Controls.Add(this.label1);
            this.groupBox1.Controls.Add(this.txtFNWCsvPath);
            this.groupBox1.Controls.Add(this.btnFNWCsv);
            this.groupBox1.Location = new System.Drawing.Point(13, 12);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(459, 47);
            this.groupBox1.TabIndex = 0;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "FNW";
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(12, 21);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(125, 23);
            this.label1.TabIndex = 0;
            this.label1.Text = "CSVファイルパス";
            // 
            // txtFNWCsvPath
            // 
            this.txtFNWCsvPath.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.txtFNWCsvPath.Location = new System.Drawing.Point(102, 18);
            this.txtFNWCsvPath.Name = "txtFNWCsvPath";
            this.txtFNWCsvPath.Size = new System.Drawing.Size(255, 30);
            this.txtFNWCsvPath.TabIndex = 1;
            // 
            // btnFNWCsv
            // 
            this.btnFNWCsv.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.btnFNWCsv.Location = new System.Drawing.Point(363, 16);
            this.btnFNWCsv.Name = "btnFNWCsv";
            this.btnFNWCsv.Size = new System.Drawing.Size(90, 27);
            this.btnFNWCsv.TabIndex = 2;
            this.btnFNWCsv.Text = "参照";
            this.btnFNWCsv.UseVisualStyleBackColor = true;
            this.btnFNWCsv.Click += new System.EventHandler(this.btnFNWCsv_Click);
            // 
            // btnNext
            // 
            this.btnNext.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnNext.Location = new System.Drawing.Point(226, 424);
            this.btnNext.Name = "btnNext";
            this.btnNext.Size = new System.Drawing.Size(120, 27);
            this.btnNext.TabIndex = 3;
            this.btnNext.Text = "次へ";
            this.btnNext.UseVisualStyleBackColor = true;
            this.btnNext.Click += new System.EventHandler(this.btnNext_Click);
            // 
            // btnExit
            // 
            this.btnExit.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnExit.Location = new System.Drawing.Point(352, 424);
            this.btnExit.Name = "btnExit";
            this.btnExit.Size = new System.Drawing.Size(120, 27);
            this.btnExit.TabIndex = 4;
            this.btnExit.Text = "終了";
            this.btnExit.UseVisualStyleBackColor = true;
            this.btnExit.Click += new System.EventHandler(this.btnExit_Click);
            // 
            // groupBox2
            // 
            this.groupBox2.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.groupBox2.Controls.Add(this.groupBox3);
            this.groupBox2.Controls.Add(this.label2);
            this.groupBox2.Controls.Add(this.txtFNSiCsvPath);
            this.groupBox2.Controls.Add(this.btnFNSiCsv);
            this.groupBox2.Location = new System.Drawing.Point(13, 65);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Size = new System.Drawing.Size(459, 220);
            this.groupBox2.TabIndex = 1;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "FNSi";
            // 
            // groupBox3
            // 
            this.groupBox3.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.groupBox3.Controls.Add(this.txtJson);
            this.groupBox3.Controls.Add(this.chkJson);
            this.groupBox3.Location = new System.Drawing.Point(6, 46);
            this.groupBox3.Name = "groupBox3";
            this.groupBox3.Size = new System.Drawing.Size(447, 167);
            this.groupBox3.TabIndex = 3;
            this.groupBox3.TabStop = false;
            this.groupBox3.Text = "JSON形式";
            // 
            // txtJson
            // 
            this.txtJson.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.txtJson.Location = new System.Drawing.Point(6, 22);
            this.txtJson.MaxLength = 0;
            this.txtJson.Multiline = true;
            this.txtJson.Name = "txtJson";
            this.txtJson.ScrollBars = System.Windows.Forms.ScrollBars.Both;
            this.txtJson.Size = new System.Drawing.Size(435, 140);
            this.txtJson.TabIndex = 1;
            // 
            // chkJson
            // 
            this.chkJson.AutoSize = true;
            this.chkJson.Location = new System.Drawing.Point(8, 0);
            this.chkJson.Name = "chkJson";
            this.chkJson.Size = new System.Drawing.Size(180, 27);
            this.chkJson.TabIndex = 0;
            this.chkJson.Text = "JSON形式貼り付け";
            this.chkJson.UseVisualStyleBackColor = true;
            this.chkJson.CheckedChanged += new System.EventHandler(this.chkJson_CheckedChanged);
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(12, 21);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(125, 23);
            this.label2.TabIndex = 0;
            this.label2.Text = "CSVファイルパス";
            // 
            // txtFNSiCsvPath
            // 
            this.txtFNSiCsvPath.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.txtFNSiCsvPath.Location = new System.Drawing.Point(102, 18);
            this.txtFNSiCsvPath.Name = "txtFNSiCsvPath";
            this.txtFNSiCsvPath.Size = new System.Drawing.Size(255, 30);
            this.txtFNSiCsvPath.TabIndex = 1;
            // 
            // btnFNSiCsv
            // 
            this.btnFNSiCsv.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.btnFNSiCsv.Location = new System.Drawing.Point(363, 16);
            this.btnFNSiCsv.Name = "btnFNSiCsv";
            this.btnFNSiCsv.Size = new System.Drawing.Size(90, 27);
            this.btnFNSiCsv.TabIndex = 2;
            this.btnFNSiCsv.Text = "参照";
            this.btnFNSiCsv.UseVisualStyleBackColor = true;
            this.btnFNSiCsv.Click += new System.EventHandler(this.btnFNSiCsv_Click);
            // 
            // rdoFromDefinition
            // 
            this.rdoFromDefinition.AutoSize = true;
            this.rdoFromDefinition.Location = new System.Drawing.Point(12, 22);
            this.rdoFromDefinition.Name = "rdoFromDefinition";
            this.rdoFromDefinition.Size = new System.Drawing.Size(339, 27);
            this.rdoFromDefinition.TabIndex = 0;
            this.rdoFromDefinition.Text = "デフォルト定義ファイルからXMLを新規作成";
            this.rdoFromDefinition.UseVisualStyleBackColor = true;
            this.rdoFromDefinition.CheckedChanged += new System.EventHandler(this.ConversionDefinition_CheckedChanged);
            // 
            // groupBox4
            // 
            this.groupBox4.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.groupBox4.Controls.Add(this.rdoXMLReedit);
            this.groupBox4.Controls.Add(this.groupBox5);
            this.groupBox4.Controls.Add(this.rdoOverwriteDefaultDefinition);
            this.groupBox4.Controls.Add(this.rdoFromDefinition);
            this.groupBox4.Location = new System.Drawing.Point(13, 291);
            this.groupBox4.Name = "groupBox4";
            this.groupBox4.Size = new System.Drawing.Size(459, 127);
            this.groupBox4.TabIndex = 2;
            this.groupBox4.TabStop = false;
            this.groupBox4.Text = "変換定義";
            // 
            // rdoXMLReedit
            // 
            this.rdoXMLReedit.AutoSize = true;
            this.rdoXMLReedit.Location = new System.Drawing.Point(12, 47);
            this.rdoXMLReedit.Name = "rdoXMLReedit";
            this.rdoXMLReedit.Size = new System.Drawing.Size(140, 27);
            this.rdoXMLReedit.TabIndex = 1;
            this.rdoXMLReedit.Text = "XMLを再編集";
            this.rdoXMLReedit.UseVisualStyleBackColor = true;
            this.rdoXMLReedit.CheckedChanged += new System.EventHandler(this.ConversionDefinition_CheckedChanged);
            // 
            // groupBox5
            // 
            this.groupBox5.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.groupBox5.Controls.Add(this.label3);
            this.groupBox5.Controls.Add(this.txtXMLReeditPath);
            this.groupBox5.Controls.Add(this.btnXMLReedit);
            this.groupBox5.Location = new System.Drawing.Point(15, 47);
            this.groupBox5.Name = "groupBox5";
            this.groupBox5.Size = new System.Drawing.Size(438, 47);
            this.groupBox5.TabIndex = 2;
            this.groupBox5.TabStop = false;
            this.groupBox5.Text = "XMLを再編集";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(9, 21);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(127, 23);
            this.label3.TabIndex = 0;
            this.label3.Text = "XMLファイルパス";
            // 
            // txtXMLReeditPath
            // 
            this.txtXMLReeditPath.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.txtXMLReeditPath.Location = new System.Drawing.Point(99, 18);
            this.txtXMLReeditPath.Name = "txtXMLReeditPath";
            this.txtXMLReeditPath.Size = new System.Drawing.Size(237, 30);
            this.txtXMLReeditPath.TabIndex = 1;
            // 
            // btnXMLReedit
            // 
            this.btnXMLReedit.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.btnXMLReedit.Location = new System.Drawing.Point(342, 16);
            this.btnXMLReedit.Name = "btnXMLReedit";
            this.btnXMLReedit.Size = new System.Drawing.Size(90, 27);
            this.btnXMLReedit.TabIndex = 2;
            this.btnXMLReedit.Text = "参照";
            this.btnXMLReedit.UseVisualStyleBackColor = true;
            this.btnXMLReedit.Click += new System.EventHandler(this.btnXMLReedit_Click);
            // 
            // rdoOverwriteDefaultDefinition
            // 
            this.rdoOverwriteDefaultDefinition.AutoSize = true;
            this.rdoOverwriteDefaultDefinition.Location = new System.Drawing.Point(12, 99);
            this.rdoOverwriteDefaultDefinition.Name = "rdoOverwriteDefaultDefinition";
            this.rdoOverwriteDefaultDefinition.Size = new System.Drawing.Size(239, 27);
            this.rdoOverwriteDefaultDefinition.TabIndex = 3;
            this.rdoOverwriteDefaultDefinition.Text = "デフォルト定義ファイルを修正";
            this.rdoOverwriteDefaultDefinition.UseVisualStyleBackColor = true;
            this.rdoOverwriteDefaultDefinition.CheckedChanged += new System.EventHandler(this.ConversionDefinition_CheckedChanged);
            // 
            // FormSetData
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(11F, 23F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(484, 461);
            this.Controls.Add(this.groupBox4);
            this.Controls.Add(this.groupBox2);
            this.Controls.Add(this.btnExit);
            this.Controls.Add(this.btnNext);
            this.Controls.Add(this.groupBox1);
            this.Font = new System.Drawing.Font("Meiryo UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.MinimumSize = new System.Drawing.Size(350, 450);
            this.Name = "FormSetData";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "設定値読み込み";
            this.Load += new System.EventHandler(this.FormSetData_Load);
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.groupBox2.ResumeLayout(false);
            this.groupBox2.PerformLayout();
            this.groupBox3.ResumeLayout(false);
            this.groupBox3.PerformLayout();
            this.groupBox4.ResumeLayout(false);
            this.groupBox4.PerformLayout();
            this.groupBox5.ResumeLayout(false);
            this.groupBox5.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.TextBox txtFNWCsvPath;
        private System.Windows.Forms.Button btnFNWCsv;
        private System.Windows.Forms.Button btnNext;
        private System.Windows.Forms.Button btnExit;
        private System.Windows.Forms.GroupBox groupBox2;
        private System.Windows.Forms.GroupBox groupBox3;
        private System.Windows.Forms.TextBox txtJson;
        private System.Windows.Forms.CheckBox chkJson;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.TextBox txtFNSiCsvPath;
        private System.Windows.Forms.Button btnFNSiCsv;
        private System.Windows.Forms.RadioButton rdoFromDefinition;
        private System.Windows.Forms.GroupBox groupBox4;
        private System.Windows.Forms.RadioButton rdoXMLReedit;
        private System.Windows.Forms.GroupBox groupBox5;
        private System.Windows.Forms.RadioButton rdoOverwriteDefaultDefinition;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.TextBox txtXMLReeditPath;
        private System.Windows.Forms.Button btnXMLReedit;
    }
}