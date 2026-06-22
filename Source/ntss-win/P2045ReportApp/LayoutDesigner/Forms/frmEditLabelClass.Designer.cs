namespace LayoutDesigner
{
    partial class frmEditLabelClass
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
            if( disposing && (components != null) ) {
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
            this.btnOK = new System.Windows.Forms.Button();
            this.btnCancel = new System.Windows.Forms.Button();
            this.label1 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.clsPuncture = new ExcelReportTool.ucLabelClass();
            this.clsEquip = new ExcelReportTool.ucLabelClass();
            this.clsMedicine = new ExcelReportTool.ucLabelClass();
            this.clsFilm2 = new ExcelReportTool.ucLabelClass();
            this.clsFilm1 = new ExcelReportTool.ucLabelClass();
            this.clsReplenishLiquid = new ExcelReportTool.ucLabelClass();
            this.clsDialysisLiquid = new ExcelReportTool.ucLabelClass();
            this.clsAntiCoagulan = new ExcelReportTool.ucLabelClass();
            this.clsAdsorption = new ExcelReportTool.ucLabelClass();
            this.clsDialyser = new ExcelReportTool.ucLabelClass();
            this.clsCircuit = new ExcelReportTool.ucLabelClass();
            this.clsExam = new ExcelReportTool.ucLabelClass();
            this.clsAll = new ExcelReportTool.ucLabelClass();
            this.SuspendLayout();
            // 
            // btnStop
            // 
            this.btnStop.Location = new System.Drawing.Point(5, 128);
            this.btnStop.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            // 
            // btnTop
            // 
            this.btnTop.Location = new System.Drawing.Point(5, 88);
            this.btnTop.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            // 
            // btnFocusControl
            // 
            this.btnFocusControl.Location = new System.Drawing.Point(5, 108);
            this.btnFocusControl.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            // 
            // winlblTitle
            // 
            this.winlblTitle.Location = new System.Drawing.Point(2, 3);
            this.winlblTitle.Size = new System.Drawing.Size(662, 37);
            this.winlblTitle.Text = "分類別情報編集";
            // 
            // btnOK
            // 
            this.btnOK.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnOK.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.btnOK.DialogResult = System.Windows.Forms.DialogResult.OK;
            this.btnOK.Location = new System.Drawing.Point(539, 655);
            this.btnOK.Margin = new System.Windows.Forms.Padding(3, 5, 3, 5);
            this.btnOK.Name = "btnOK";
            this.btnOK.Size = new System.Drawing.Size(99, 39);
            this.btnOK.TabIndex = 1;
            this.btnOK.Text = "OK";
            this.btnOK.UseVisualStyleBackColor = false;
            this.btnOK.Click += new System.EventHandler(this.btnOK_Click);
            // 
            // btnCancel
            // 
            this.btnCancel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnCancel.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.btnCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.btnCancel.Location = new System.Drawing.Point(432, 655);
            this.btnCancel.Margin = new System.Windows.Forms.Padding(3, 5, 3, 5);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(99, 39);
            this.btnCancel.TabIndex = 1;
            this.btnCancel.Text = "キャンセル";
            this.btnCancel.UseVisualStyleBackColor = false;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(104, 15);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(72, 20);
            this.label1.TabIndex = 7;
            this.label1.Text = "表示データ";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(320, 15);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(84, 20);
            this.label2.TabIndex = 8;
            this.label2.Text = "固定文字列";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(104, 57);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(72, 20);
            this.label3.TabIndex = 13;
            this.label3.Text = "表示データ";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(320, 57);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(84, 20);
            this.label4.TabIndex = 14;
            this.label4.Text = "固定文字列";
            // 
            // clsPuncture
            // 
            this.clsPuncture.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.clsPuncture.Location = new System.Drawing.Point(16, 521);
            this.clsPuncture.Margin = new System.Windows.Forms.Padding(3, 5, 3, 5);
            this.clsPuncture.Name = "clsPuncture";
            this.clsPuncture.Size = new System.Drawing.Size(624, 33);
            this.clsPuncture.TabIndex = 12;
            this.clsPuncture.Title = "穿刺針";
            // 
            // clsEquip
            // 
            this.clsEquip.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.clsEquip.Location = new System.Drawing.Point(16, 477);
            this.clsEquip.Margin = new System.Windows.Forms.Padding(3, 5, 3, 5);
            this.clsEquip.Name = "clsEquip";
            this.clsEquip.Size = new System.Drawing.Size(624, 33);
            this.clsEquip.TabIndex = 11;
            this.clsEquip.Title = "医療材料";
            // 
            // clsMedicine
            // 
            this.clsMedicine.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.clsMedicine.Location = new System.Drawing.Point(16, 433);
            this.clsMedicine.Margin = new System.Windows.Forms.Padding(3, 5, 3, 5);
            this.clsMedicine.Name = "clsMedicine";
            this.clsMedicine.Size = new System.Drawing.Size(624, 33);
            this.clsMedicine.TabIndex = 10;
            this.clsMedicine.Title = "投薬";
            // 
            // clsFilm2
            // 
            this.clsFilm2.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.clsFilm2.Location = new System.Drawing.Point(16, 391);
            this.clsFilm2.Margin = new System.Windows.Forms.Padding(3, 5, 3, 5);
            this.clsFilm2.Name = "clsFilm2";
            this.clsFilm2.Size = new System.Drawing.Size(624, 33);
            this.clsFilm2.TabIndex = 9;
            this.clsFilm2.Title = "2次膜";
            // 
            // clsFilm1
            // 
            this.clsFilm1.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.clsFilm1.Location = new System.Drawing.Point(16, 348);
            this.clsFilm1.Margin = new System.Windows.Forms.Padding(3, 5, 3, 5);
            this.clsFilm1.Name = "clsFilm1";
            this.clsFilm1.Size = new System.Drawing.Size(624, 33);
            this.clsFilm1.TabIndex = 8;
            this.clsFilm1.Title = "1次膜";
            // 
            // clsReplenishLiquid
            // 
            this.clsReplenishLiquid.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.clsReplenishLiquid.Location = new System.Drawing.Point(16, 304);
            this.clsReplenishLiquid.Margin = new System.Windows.Forms.Padding(3, 5, 3, 5);
            this.clsReplenishLiquid.Name = "clsReplenishLiquid";
            this.clsReplenishLiquid.Size = new System.Drawing.Size(624, 33);
            this.clsReplenishLiquid.TabIndex = 7;
            this.clsReplenishLiquid.Title = "補液";
            // 
            // clsDialysisLiquid
            // 
            this.clsDialysisLiquid.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.clsDialysisLiquid.Location = new System.Drawing.Point(16, 260);
            this.clsDialysisLiquid.Margin = new System.Windows.Forms.Padding(3, 5, 3, 5);
            this.clsDialysisLiquid.Name = "clsDialysisLiquid";
            this.clsDialysisLiquid.Size = new System.Drawing.Size(624, 33);
            this.clsDialysisLiquid.TabIndex = 6;
            this.clsDialysisLiquid.Title = "透析液";
            // 
            // clsAntiCoagulan
            // 
            this.clsAntiCoagulan.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.clsAntiCoagulan.Location = new System.Drawing.Point(16, 217);
            this.clsAntiCoagulan.Margin = new System.Windows.Forms.Padding(3, 5, 3, 5);
            this.clsAntiCoagulan.Name = "clsAntiCoagulan";
            this.clsAntiCoagulan.Size = new System.Drawing.Size(624, 33);
            this.clsAntiCoagulan.TabIndex = 5;
            this.clsAntiCoagulan.Title = "抗凝固剤";
            // 
            // clsAdsorption
            // 
            this.clsAdsorption.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.clsAdsorption.Location = new System.Drawing.Point(16, 175);
            this.clsAdsorption.Margin = new System.Windows.Forms.Padding(3, 5, 3, 5);
            this.clsAdsorption.Name = "clsAdsorption";
            this.clsAdsorption.Size = new System.Drawing.Size(624, 33);
            this.clsAdsorption.TabIndex = 4;
            this.clsAdsorption.Title = "吸着カラム";
            // 
            // clsDialyser
            // 
            this.clsDialyser.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.clsDialyser.Location = new System.Drawing.Point(16, 131);
            this.clsDialyser.Margin = new System.Windows.Forms.Padding(3, 5, 3, 5);
            this.clsDialyser.Name = "clsDialyser";
            this.clsDialyser.Size = new System.Drawing.Size(624, 33);
            this.clsDialyser.TabIndex = 3;
            this.clsDialyser.Title = "ダイアライザ";
            // 
            // clsCircuit
            // 
            this.clsCircuit.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.clsCircuit.Location = new System.Drawing.Point(16, 564);
            this.clsCircuit.Margin = new System.Windows.Forms.Padding(3, 5, 3, 5);
            this.clsCircuit.Name = "clsCircuit";
            this.clsCircuit.Size = new System.Drawing.Size(624, 33);
            this.clsCircuit.TabIndex = 13;
            this.clsCircuit.Title = "血液回路";
            // 
            // clsExam
            // 
            this.clsExam.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.clsExam.Location = new System.Drawing.Point(16, 604);
            this.clsExam.Margin = new System.Windows.Forms.Padding(3, 5, 3, 5);
            this.clsExam.Name = "clsExam";
            this.clsExam.Size = new System.Drawing.Size(624, 33);
            this.clsExam.TabIndex = 14;
            this.clsExam.Title = "検査";
            // 
            // clsAll
            // 
            this.clsAll.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.clsAll.Location = new System.Drawing.Point(16, 90);
            this.clsAll.Margin = new System.Windows.Forms.Padding(3, 7, 3, 7);
            this.clsAll.Name = "clsAll";
            this.clsAll.Size = new System.Drawing.Size(624, 44);
            this.clsAll.TabIndex = 14;
            this.clsAll.Title = "全分類";
            // 
            // frmEditLabelClass
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 20F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(666, 730);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.clsAll);
            this.Controls.Add(this.clsExam);
            this.Controls.Add(this.clsCircuit);
            this.Controls.Add(this.clsPuncture);
            this.Controls.Add(this.clsEquip);
            this.Controls.Add(this.clsMedicine);
            this.Controls.Add(this.clsFilm2);
            this.Controls.Add(this.clsFilm1);
            this.Controls.Add(this.clsReplenishLiquid);
            this.Controls.Add(this.clsDialysisLiquid);
            this.Controls.Add(this.clsAntiCoagulan);
            this.Controls.Add(this.clsAdsorption);
            this.Controls.Add(this.clsDialyser);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.btnOK);
            this.Margin = new System.Windows.Forms.Padding(3, 7, 3, 7);
            this.MaximumSize = new System.Drawing.Size(2000, 730);
            this.MinimumSize = new System.Drawing.Size(666, 730);
            this.Name = "frmEditLabelClass";
            this.Padding = new System.Windows.Forms.Padding(2, 3, 2, 3);
            this.Text = "分類別情報編集";
            this.Load += new System.EventHandler(this.frmEditLabelClass_Load);
            this.Controls.SetChildIndex(this.btnOK, 0);
            this.Controls.SetChildIndex(this.btnCancel, 0);
            this.Controls.SetChildIndex(this.clsDialyser, 0);
            this.Controls.SetChildIndex(this.clsAdsorption, 0);
            this.Controls.SetChildIndex(this.clsAntiCoagulan, 0);
            this.Controls.SetChildIndex(this.clsDialysisLiquid, 0);
            this.Controls.SetChildIndex(this.clsReplenishLiquid, 0);
            this.Controls.SetChildIndex(this.clsFilm1, 0);
            this.Controls.SetChildIndex(this.clsFilm2, 0);
            this.Controls.SetChildIndex(this.clsMedicine, 0);
            this.Controls.SetChildIndex(this.clsEquip, 0);
            this.Controls.SetChildIndex(this.clsPuncture, 0);
            this.Controls.SetChildIndex(this.clsCircuit, 0);
            this.Controls.SetChildIndex(this.clsExam, 0);
            this.Controls.SetChildIndex(this.clsAll, 0);
            this.Controls.SetChildIndex(this.label1, 0);
            this.Controls.SetChildIndex(this.label2, 0);
            this.Controls.SetChildIndex(this.btnFocusControl, 0);
            this.Controls.SetChildIndex(this.btnTop, 0);
            this.Controls.SetChildIndex(this.btnStop, 0);
            this.Controls.SetChildIndex(this.winlblTitle, 0);
            this.Controls.SetChildIndex(this.label3, 0);
            this.Controls.SetChildIndex(this.label4, 0);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button btnOK;
        private System.Windows.Forms.Button btnCancel;
        private ExcelReportTool.ucLabelClass clsDialyser;
        private ExcelReportTool.ucLabelClass clsAdsorption;
        private ExcelReportTool.ucLabelClass clsAntiCoagulan;
        private ExcelReportTool.ucLabelClass clsDialysisLiquid;
        private ExcelReportTool.ucLabelClass clsReplenishLiquid;
        private ExcelReportTool.ucLabelClass clsFilm1;
        private ExcelReportTool.ucLabelClass clsFilm2;
        private ExcelReportTool.ucLabelClass clsMedicine;
        private ExcelReportTool.ucLabelClass clsEquip;
        private ExcelReportTool.ucLabelClass clsPuncture;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label4;
        private ExcelReportTool.ucLabelClass clsCircuit;
        private ExcelReportTool.ucLabelClass clsExam;
        private ExcelReportTool.ucLabelClass clsAll;
    }
}