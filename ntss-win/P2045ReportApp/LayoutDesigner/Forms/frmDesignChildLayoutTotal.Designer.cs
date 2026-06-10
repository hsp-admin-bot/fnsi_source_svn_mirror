namespace LayoutDesigner
{
    partial class frmDesignChildLayoutTotal
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
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle1 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle2 = new System.Windows.Forms.DataGridViewCellStyle();
            this.splTemplete = new System.Windows.Forms.SplitContainer();
            this.pnlTmplDrop = new System.Windows.Forms.Panel();
            this.panTotal = new System.Windows.Forms.Panel();
            this.chkEffectDataH = new System.Windows.Forms.CheckBox();
            this.chkEffectDataV = new System.Windows.Forms.CheckBox();
            this.label7 = new System.Windows.Forms.Label();
            this.cobTotalReportType = new System.Windows.Forms.ComboBox();
            this.panel3 = new System.Windows.Forms.Panel();
            this.txtTotalUnitH = new System.Windows.Forms.TextBox();
            this.panUnit = new System.Windows.Forms.Panel();
            this.txtTotalUnitV = new System.Windows.Forms.TextBox();
            this.panel2 = new System.Windows.Forms.Panel();
            this.radTotalCountV = new System.Windows.Forms.RadioButton();
            this.radTotalCountVDisp = new System.Windows.Forms.RadioButton();
            this.panel1 = new System.Windows.Forms.Panel();
            this.radTotalCountH = new System.Windows.Forms.RadioButton();
            this.radTotalCountHDisp = new System.Windows.Forms.RadioButton();
            this.label5 = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.btnTotalUnitH = new System.Windows.Forms.Button();
            this.btnTotalUnitV = new System.Windows.Forms.Button();
            this.btnChange = new System.Windows.Forms.Button();
            this.label3 = new System.Windows.Forms.Label();
            this.cobTotalContents = new System.Windows.Forms.ComboBox();
            this.label2 = new System.Windows.Forms.Label();
            this.cobTotalContentsType = new System.Windows.Forms.ComboBox();
            this.cobTotalUnitDate = new System.Windows.Forms.ComboBox();
            this.lblTmplDescription = new System.Windows.Forms.Label();
            this.picTmpl = new System.Windows.Forms.PictureBox();
            this.pnlTmplHeader = new System.Windows.Forms.Panel();
            this.btnTmplClear = new System.Windows.Forms.Button();
            this.btnTmplSelect = new System.Windows.Forms.Button();
            this.dgvTmplDetail = new System.Windows.Forms.DataGridView();
            this.pnlBottom = new System.Windows.Forms.Panel();
            this.btnTmplMakeData = new System.Windows.Forms.Button();
            ((System.ComponentModel.ISupportInitialize)(this.splTemplete)).BeginInit();
            this.splTemplete.Panel1.SuspendLayout();
            this.splTemplete.Panel2.SuspendLayout();
            this.splTemplete.SuspendLayout();
            this.pnlTmplDrop.SuspendLayout();
            this.panTotal.SuspendLayout();
            this.panel3.SuspendLayout();
            this.panUnit.SuspendLayout();
            this.panel2.SuspendLayout();
            this.panel1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.picTmpl)).BeginInit();
            this.pnlTmplHeader.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgvTmplDetail)).BeginInit();
            this.pnlBottom.SuspendLayout();
            this.SuspendLayout();
            // 
            // btnStop
            // 
            this.btnStop.Location = new System.Drawing.Point(227, 700);
            this.btnStop.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.btnStop.TabIndex = 4;
            // 
            // btnTop
            // 
            this.btnTop.Location = new System.Drawing.Point(3, 0);
            this.btnTop.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            // 
            // btnFocusControl
            // 
            this.btnFocusControl.Location = new System.Drawing.Point(96, 0);
            this.btnFocusControl.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            // 
            // winlblTitle
            // 
            this.winlblTitle.Size = new System.Drawing.Size(334, 0);
            // 
            // splTemplete
            // 
            this.splTemplete.BackColor = System.Drawing.Color.LightSlateGray;
            this.splTemplete.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splTemplete.Location = new System.Drawing.Point(0, 0);
            this.splTemplete.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.splTemplete.Name = "splTemplete";
            this.splTemplete.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // splTemplete.Panel1
            // 
            this.splTemplete.Panel1.Controls.Add(this.pnlTmplDrop);
            this.splTemplete.Panel1.Controls.Add(this.pnlTmplHeader);
            // 
            // splTemplete.Panel2
            // 
            this.splTemplete.Panel2.Controls.Add(this.dgvTmplDetail);
            this.splTemplete.Panel2.Controls.Add(this.pnlBottom);
            this.splTemplete.Size = new System.Drawing.Size(334, 720);
            this.splTemplete.SplitterDistance = 467;
            this.splTemplete.SplitterWidth = 5;
            this.splTemplete.TabIndex = 3;
            // 
            // pnlTmplDrop
            // 
            this.pnlTmplDrop.AllowDrop = true;
            this.pnlTmplDrop.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.pnlTmplDrop.Controls.Add(this.panTotal);
            this.pnlTmplDrop.Controls.Add(this.lblTmplDescription);
            this.pnlTmplDrop.Controls.Add(this.picTmpl);
            this.pnlTmplDrop.Dock = System.Windows.Forms.DockStyle.Fill;
            this.pnlTmplDrop.Location = new System.Drawing.Point(0, 37);
            this.pnlTmplDrop.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.pnlTmplDrop.Name = "pnlTmplDrop";
            this.pnlTmplDrop.Size = new System.Drawing.Size(334, 430);
            this.pnlTmplDrop.TabIndex = 2;
            this.pnlTmplDrop.DragDrop += new System.Windows.Forms.DragEventHandler(this.pnlTmplDrop_DragDrop);
            this.pnlTmplDrop.DragEnter += new System.Windows.Forms.DragEventHandler(this.pnlTmplDrop_DragEnter);
            // 
            // panTotal
            // 
            this.panTotal.Controls.Add(this.chkEffectDataH);
            this.panTotal.Controls.Add(this.chkEffectDataV);
            this.panTotal.Controls.Add(this.label7);
            this.panTotal.Controls.Add(this.cobTotalReportType);
            this.panTotal.Controls.Add(this.panel3);
            this.panTotal.Controls.Add(this.panUnit);
            this.panTotal.Controls.Add(this.panel2);
            this.panTotal.Controls.Add(this.panel1);
            this.panTotal.Controls.Add(this.label5);
            this.panTotal.Controls.Add(this.label4);
            this.panTotal.Controls.Add(this.btnTotalUnitH);
            this.panTotal.Controls.Add(this.btnTotalUnitV);
            this.panTotal.Controls.Add(this.btnChange);
            this.panTotal.Controls.Add(this.label3);
            this.panTotal.Controls.Add(this.cobTotalContents);
            this.panTotal.Controls.Add(this.label2);
            this.panTotal.Controls.Add(this.cobTotalContentsType);
            this.panTotal.Controls.Add(this.cobTotalUnitDate);
            this.panTotal.Location = new System.Drawing.Point(1, 64);
            this.panTotal.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.panTotal.Name = "panTotal";
            this.panTotal.Size = new System.Drawing.Size(325, 387);
            this.panTotal.TabIndex = 15;
            // 
            // chkEffectDataH
            // 
            this.chkEffectDataH.Location = new System.Drawing.Point(86, 120);
            this.chkEffectDataH.Margin = new System.Windows.Forms.Padding(3, 5, 3, 5);
            this.chkEffectDataH.Name = "chkEffectDataH";
            this.chkEffectDataH.Size = new System.Drawing.Size(183, 25);
            this.chkEffectDataH.TabIndex = 21;
            this.chkEffectDataH.Text = "出力値のない行は省略する";
            this.chkEffectDataH.UseVisualStyleBackColor = true;
            this.chkEffectDataH.CheckedChanged += new System.EventHandler(this.chkEffectDataH_CheckedChanged);
            // 
            // chkEffectDataV
            // 
            this.chkEffectDataV.Location = new System.Drawing.Point(86, 47);
            this.chkEffectDataV.Margin = new System.Windows.Forms.Padding(3, 5, 3, 5);
            this.chkEffectDataV.Name = "chkEffectDataV";
            this.chkEffectDataV.Size = new System.Drawing.Size(183, 25);
            this.chkEffectDataV.TabIndex = 20;
            this.chkEffectDataV.Text = "出力値のない列は省略する";
            this.chkEffectDataV.UseVisualStyleBackColor = true;
            this.chkEffectDataV.CheckedChanged += new System.EventHandler(this.chkEffectDataV_CheckedChanged);
            // 
            // label7
            // 
            this.label7.AutoSize = true;
            this.label7.Location = new System.Drawing.Point(6, 205);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(69, 20);
            this.label7.TabIndex = 19;
            this.label7.Text = "帳票区分";
            // 
            // cobTotalReportType
            // 
            this.cobTotalReportType.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cobTotalReportType.FormattingEnabled = true;
            this.cobTotalReportType.Location = new System.Drawing.Point(86, 200);
            this.cobTotalReportType.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.cobTotalReportType.Name = "cobTotalReportType";
            this.cobTotalReportType.Size = new System.Drawing.Size(165, 28);
            this.cobTotalReportType.TabIndex = 18;
            this.cobTotalReportType.SelectedIndexChanged += new System.EventHandler(this.cobTotalReportType_SelectedIndexChanged);
            this.cobTotalReportType.TextUpdate += new System.EventHandler(this.cobTotalReportType_TextUpdate);
            // 
            // panel3
            // 
            this.panel3.Controls.Add(this.txtTotalUnitH);
            this.panel3.Location = new System.Drawing.Point(86, 80);
            this.panel3.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.panel3.Name = "panel3";
            this.panel3.Size = new System.Drawing.Size(171, 39);
            this.panel3.TabIndex = 17;
            // 
            // txtTotalUnitH
            // 
            this.txtTotalUnitH.Location = new System.Drawing.Point(0, 0);
            this.txtTotalUnitH.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.txtTotalUnitH.Name = "txtTotalUnitH";
            this.txtTotalUnitH.ReadOnly = true;
            this.txtTotalUnitH.Size = new System.Drawing.Size(165, 27);
            this.txtTotalUnitH.TabIndex = 0;
            this.txtTotalUnitH.TextChanged += new System.EventHandler(this.txtTotalUnitH_Changed);
            // 
            // panUnit
            // 
            this.panUnit.Controls.Add(this.txtTotalUnitV);
            this.panUnit.Location = new System.Drawing.Point(86, 7);
            this.panUnit.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.panUnit.Name = "panUnit";
            this.panUnit.Size = new System.Drawing.Size(171, 39);
            this.panUnit.TabIndex = 15;
            // 
            // txtTotalUnitV
            // 
            this.txtTotalUnitV.Location = new System.Drawing.Point(0, 0);
            this.txtTotalUnitV.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.txtTotalUnitV.Name = "txtTotalUnitV";
            this.txtTotalUnitV.ReadOnly = true;
            this.txtTotalUnitV.Size = new System.Drawing.Size(165, 27);
            this.txtTotalUnitV.TabIndex = 0;
            this.txtTotalUnitV.TextChanged += new System.EventHandler(this.txtTotalUnitV_Changed);
            // 
            // panel2
            // 
            this.panel2.Controls.Add(this.radTotalCountV);
            this.panel2.Controls.Add(this.radTotalCountVDisp);
            this.panel2.Location = new System.Drawing.Point(73, 333);
            this.panel2.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.panel2.Name = "panel2";
            this.panel2.Size = new System.Drawing.Size(229, 20);
            this.panel2.TabIndex = 14;
            // 
            // radTotalCountV
            // 
            this.radTotalCountV.AutoSize = true;
            this.radTotalCountV.Location = new System.Drawing.Point(104, -3);
            this.radTotalCountV.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.radTotalCountV.Name = "radTotalCountV";
            this.radTotalCountV.Size = new System.Drawing.Size(75, 24);
            this.radTotalCountV.TabIndex = 1;
            this.radTotalCountV.TabStop = true;
            this.radTotalCountV.Text = "非表示";
            this.radTotalCountV.UseVisualStyleBackColor = true;
            this.radTotalCountV.CheckedChanged += new System.EventHandler(this.radTotalCountV_CheckedChanged);
            // 
            // radTotalCountVDisp
            // 
            this.radTotalCountVDisp.AutoSize = true;
            this.radTotalCountVDisp.Location = new System.Drawing.Point(22, -3);
            this.radTotalCountVDisp.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.radTotalCountVDisp.Name = "radTotalCountVDisp";
            this.radTotalCountVDisp.Size = new System.Drawing.Size(60, 24);
            this.radTotalCountVDisp.TabIndex = 0;
            this.radTotalCountVDisp.TabStop = true;
            this.radTotalCountVDisp.Text = "表示";
            this.radTotalCountVDisp.UseVisualStyleBackColor = true;
            this.radTotalCountVDisp.CheckedChanged += new System.EventHandler(this.radTotalCountVDisp_CheckedChanged);
            // 
            // panel1
            // 
            this.panel1.Controls.Add(this.radTotalCountH);
            this.panel1.Controls.Add(this.radTotalCountHDisp);
            this.panel1.Location = new System.Drawing.Point(73, 300);
            this.panel1.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(229, 20);
            this.panel1.TabIndex = 13;
            // 
            // radTotalCountH
            // 
            this.radTotalCountH.AutoSize = true;
            this.radTotalCountH.Location = new System.Drawing.Point(104, -3);
            this.radTotalCountH.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.radTotalCountH.Name = "radTotalCountH";
            this.radTotalCountH.Size = new System.Drawing.Size(75, 24);
            this.radTotalCountH.TabIndex = 1;
            this.radTotalCountH.TabStop = true;
            this.radTotalCountH.Text = "非表示";
            this.radTotalCountH.UseVisualStyleBackColor = true;
            this.radTotalCountH.CheckedChanged += new System.EventHandler(this.radTotalCountH_CheckedChanged);
            // 
            // radTotalCountHDisp
            // 
            this.radTotalCountHDisp.AutoSize = true;
            this.radTotalCountHDisp.Location = new System.Drawing.Point(22, -3);
            this.radTotalCountHDisp.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.radTotalCountHDisp.Name = "radTotalCountHDisp";
            this.radTotalCountHDisp.Size = new System.Drawing.Size(60, 24);
            this.radTotalCountHDisp.TabIndex = 0;
            this.radTotalCountHDisp.TabStop = true;
            this.radTotalCountHDisp.Text = "表示";
            this.radTotalCountHDisp.UseVisualStyleBackColor = true;
            this.radTotalCountHDisp.CheckedChanged += new System.EventHandler(this.radTotalCountHDisp_CheckedChanged);
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(6, 333);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(66, 20);
            this.label5.TabIndex = 10;
            this.label5.Text = "横の合計";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(6, 300);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(66, 20);
            this.label4.TabIndex = 7;
            this.label4.Text = "縦の合計";
            // 
            // btnTotalUnitH
            // 
            this.btnTotalUnitH.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnTotalUnitH.Font = new System.Drawing.Font("Yu Gothic UI", 8.25F);
            this.btnTotalUnitH.Location = new System.Drawing.Point(6, 7);
            this.btnTotalUnitH.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.btnTotalUnitH.Name = "btnTotalUnitH";
            this.btnTotalUnitH.Size = new System.Drawing.Size(72, 31);
            this.btnTotalUnitH.TabIndex = 6;
            this.btnTotalUnitH.Text = "横の単位";
            this.btnTotalUnitH.UseVisualStyleBackColor = true;
            this.btnTotalUnitH.Click += new System.EventHandler(this.btnTotalUnitH_Click);
            // 
            // btnTotalUnitV
            // 
            this.btnTotalUnitV.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnTotalUnitV.Font = new System.Drawing.Font("Yu Gothic UI", 8.25F);
            this.btnTotalUnitV.Location = new System.Drawing.Point(6, 80);
            this.btnTotalUnitV.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.btnTotalUnitV.Name = "btnTotalUnitV";
            this.btnTotalUnitV.Size = new System.Drawing.Size(74, 31);
            this.btnTotalUnitV.TabIndex = 6;
            this.btnTotalUnitV.Text = "縦の単位";
            this.btnTotalUnitV.UseVisualStyleBackColor = true;
            this.btnTotalUnitV.Click += new System.EventHandler(this.btnTotalUnitV_Click);
            // 
            // btnChange
            // 
            this.btnChange.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnChange.Font = new System.Drawing.Font("Yu Gothic UI", 8.25F);
            this.btnChange.Location = new System.Drawing.Point(95, 250);
            this.btnChange.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.btnChange.Name = "btnChange";
            this.btnChange.Size = new System.Drawing.Size(86, 31);
            this.btnChange.TabIndex = 6;
            this.btnChange.Text = "変換ボタン";
            this.btnChange.UseVisualStyleBackColor = true;
            this.btnChange.Click += new System.EventHandler(this.btnChange_Click);
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(6, 255);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(69, 20);
            this.label3.TabIndex = 5;
            this.label3.Text = "表示変換";
            // 
            // cobTotalContents
            // 
            this.cobTotalContents.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cobTotalContents.FormattingEnabled = true;
            this.cobTotalContents.Items.AddRange(new object[] {
            "",
            "項目値",
            "合　計",
            "平均値",
            "最大値",
            "最小値"});
            this.cobTotalContents.Location = new System.Drawing.Point(86, 160);
            this.cobTotalContents.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.cobTotalContents.Name = "cobTotalContents";
            this.cobTotalContents.Size = new System.Drawing.Size(165, 28);
            this.cobTotalContents.TabIndex = 4;
            this.cobTotalContents.SelectedIndexChanged += new System.EventHandler(this.cobTotalContents_SelectIndexChanged);
            this.cobTotalContents.TextUpdate += new System.EventHandler(this.cobTotalContents_TextUpdate);
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(6, 165);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(69, 20);
            this.label2.TabIndex = 3;
            this.label2.Text = "表示内容";
            // 
            // cobTotalContentsType
            // 
            this.cobTotalContentsType.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cobTotalContentsType.FormattingEnabled = true;
            this.cobTotalContentsType.Items.AddRange(new object[] {
            "先頭",
            "後尾",
            "全部"});
            this.cobTotalContentsType.Location = new System.Drawing.Point(263, 160);
            this.cobTotalContentsType.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.cobTotalContentsType.Name = "cobTotalContentsType";
            this.cobTotalContentsType.Size = new System.Drawing.Size(53, 28);
            this.cobTotalContentsType.TabIndex = 1;
            this.cobTotalContentsType.SelectedIndexChanged += new System.EventHandler(this.cobTotalContentsType_SelectIndexChanged);
            this.cobTotalContentsType.TextUpdate += new System.EventHandler(this.cobTotalContentsType_TextUpdate);
            // 
            // cobTotalUnitDate
            // 
            this.cobTotalUnitDate.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cobTotalUnitDate.FormattingEnabled = true;
            this.cobTotalUnitDate.Items.AddRange(new object[] {
            "",
            "年",
            "月",
            "日",
            "曜日"});
            this.cobTotalUnitDate.Location = new System.Drawing.Point(263, 7);
            this.cobTotalUnitDate.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.cobTotalUnitDate.Name = "cobTotalUnitDate";
            this.cobTotalUnitDate.Size = new System.Drawing.Size(53, 28);
            this.cobTotalUnitDate.TabIndex = 1;
            this.cobTotalUnitDate.SelectedIndexChanged += new System.EventHandler(this.cobTotalUnitDate_SelectIndexChanged);
            this.cobTotalUnitDate.TextUpdate += new System.EventHandler(this.cobTotalUnitDate_TextUpdate);
            // 
            // lblTmplDescription
            // 
            this.lblTmplDescription.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lblTmplDescription.Location = new System.Drawing.Point(73, 4);
            this.lblTmplDescription.Name = "lblTmplDescription";
            this.lblTmplDescription.Size = new System.Drawing.Size(191, 135);
            this.lblTmplDescription.TabIndex = 0;
            this.lblTmplDescription.Text = "集計内容として指定するセルをドロップ";
            this.lblTmplDescription.TextAlign = System.Drawing.ContentAlignment.TopCenter;
            // 
            // picTmpl
            // 
            this.picTmpl.Location = new System.Drawing.Point(0, 0);
            this.picTmpl.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.picTmpl.Name = "picTmpl";
            this.picTmpl.Size = new System.Drawing.Size(325, 60);
            this.picTmpl.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.picTmpl.TabIndex = 0;
            this.picTmpl.TabStop = false;
            // 
            // pnlTmplHeader
            // 
            this.pnlTmplHeader.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.pnlTmplHeader.Controls.Add(this.btnTmplClear);
            this.pnlTmplHeader.Controls.Add(this.btnTmplSelect);
            this.pnlTmplHeader.Dock = System.Windows.Forms.DockStyle.Top;
            this.pnlTmplHeader.Location = new System.Drawing.Point(0, 0);
            this.pnlTmplHeader.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.pnlTmplHeader.Name = "pnlTmplHeader";
            this.pnlTmplHeader.Size = new System.Drawing.Size(334, 37);
            this.pnlTmplHeader.TabIndex = 0;
            // 
            // btnTmplClear
            // 
            this.btnTmplClear.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnTmplClear.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnTmplClear.ForeColor = System.Drawing.Color.LightCoral;
            this.btnTmplClear.Location = new System.Drawing.Point(145, 1);
            this.btnTmplClear.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.btnTmplClear.Name = "btnTmplClear";
            this.btnTmplClear.Size = new System.Drawing.Size(135, 32);
            this.btnTmplClear.TabIndex = 1;
            this.btnTmplClear.Text = "集計内容の初期化";
            this.btnTmplClear.Click += new System.EventHandler(this.btnTmplClear_Click);
            // 
            // btnTmplSelect
            // 
            this.btnTmplSelect.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnTmplSelect.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnTmplSelect.Font = new System.Drawing.Font("Yu Gothic UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.btnTmplSelect.Location = new System.Drawing.Point(1, 1);
            this.btnTmplSelect.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.btnTmplSelect.Name = "btnTmplSelect";
            this.btnTmplSelect.Size = new System.Drawing.Size(137, 32);
            this.btnTmplSelect.TabIndex = 0;
            this.btnTmplSelect.Text = "集計内容のセルを指定する";
            this.btnTmplSelect.Click += new System.EventHandler(this.btnTmplSelect_Click);
            // 
            // dgvTmplDetail
            // 
            this.dgvTmplDetail.AllowUserToAddRows = false;
            this.dgvTmplDetail.AllowUserToDeleteRows = false;
            this.dgvTmplDetail.AllowUserToResizeRows = false;
            this.dgvTmplDetail.BackgroundColor = System.Drawing.Color.FromArgb(((int)(((byte)(50)))), ((int)(((byte)(50)))), ((int)(((byte)(50)))));
            this.dgvTmplDetail.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.dgvTmplDetail.ColumnHeadersBorderStyle = System.Windows.Forms.DataGridViewHeaderBorderStyle.Single;
            dataGridViewCellStyle1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(50)))), ((int)(((byte)(50)))), ((int)(((byte)(50)))));
            dataGridViewCellStyle1.Font = new System.Drawing.Font("Yu Gothic UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle1.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.dgvTmplDetail.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle1;
            this.dgvTmplDetail.ColumnHeadersHeight = 29;
            this.dgvTmplDetail.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.DisableResizing;
            dataGridViewCellStyle2.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle2.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(40)))), ((int)(((byte)(40)))), ((int)(((byte)(40)))));
            dataGridViewCellStyle2.Font = new System.Drawing.Font("Yu Gothic UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle2.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle2.SelectionBackColor = System.Drawing.Color.SlateGray;
            dataGridViewCellStyle2.SelectionForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle2.WrapMode = System.Windows.Forms.DataGridViewTriState.False;
            this.dgvTmplDetail.DefaultCellStyle = dataGridViewCellStyle2;
            this.dgvTmplDetail.Dock = System.Windows.Forms.DockStyle.Fill;
            this.dgvTmplDetail.EnableHeadersVisualStyles = false;
            this.dgvTmplDetail.GridColor = System.Drawing.Color.FromArgb(((int)(((byte)(70)))), ((int)(((byte)(70)))), ((int)(((byte)(70)))));
            this.dgvTmplDetail.Location = new System.Drawing.Point(0, 0);
            this.dgvTmplDetail.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.dgvTmplDetail.MultiSelect = false;
            this.dgvTmplDetail.Name = "dgvTmplDetail";
            this.dgvTmplDetail.RowHeadersVisible = false;
            this.dgvTmplDetail.RowHeadersWidth = 51;
            this.dgvTmplDetail.RowTemplate.Height = 21;
            this.dgvTmplDetail.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.dgvTmplDetail.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.CellSelect;
            this.dgvTmplDetail.Size = new System.Drawing.Size(334, 208);
            this.dgvTmplDetail.TabIndex = 0;
            this.dgvTmplDetail.CellClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.dgvTmplDetail_CellClick);
            this.dgvTmplDetail.CellLeave += new System.Windows.Forms.DataGridViewCellEventHandler(this.dgvTmplDetail_CellEndEdit);
            this.dgvTmplDetail.CellValidating += new System.Windows.Forms.DataGridViewCellValidatingEventHandler(this.dgvTmplDetail_CellValidating);
            this.dgvTmplDetail.CurrentCellDirtyStateChanged += new System.EventHandler(this.dgvTmplDetail_CurrentCellDirtyStateChanged);
            // 
            // pnlBottom
            // 
            this.pnlBottom.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.pnlBottom.Controls.Add(this.btnTmplMakeData);
            this.pnlBottom.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.pnlBottom.Location = new System.Drawing.Point(0, 208);
            this.pnlBottom.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.pnlBottom.Name = "pnlBottom";
            this.pnlBottom.Size = new System.Drawing.Size(334, 40);
            this.pnlBottom.TabIndex = 1;
            // 
            // btnTmplMakeData
            // 
            this.btnTmplMakeData.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnTmplMakeData.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnTmplMakeData.Location = new System.Drawing.Point(82, 4);
            this.btnTmplMakeData.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.btnTmplMakeData.Name = "btnTmplMakeData";
            this.btnTmplMakeData.Size = new System.Drawing.Size(149, 32);
            this.btnTmplMakeData.TabIndex = 0;
            this.btnTmplMakeData.Text = "テスト用データ作成";
            // 
            // frmDesignChildLayoutTotal
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 20F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(334, 720);
            this.CloseBox = false;
            this.Controls.Add(this.splTemplete);
            this.Margin = new System.Windows.Forms.Padding(3, 8, 3, 8);
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "frmDesignChildLayoutTotal";
            this.ShowInTaskbar = false;
            this.Controls.SetChildIndex(this.winlblTitle, 0);
            this.Controls.SetChildIndex(this.splTemplete, 0);
            this.Controls.SetChildIndex(this.btnFocusControl, 0);
            this.Controls.SetChildIndex(this.btnStop, 0);
            this.Controls.SetChildIndex(this.btnTop, 0);
            this.splTemplete.Panel1.ResumeLayout(false);
            this.splTemplete.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splTemplete)).EndInit();
            this.splTemplete.ResumeLayout(false);
            this.pnlTmplDrop.ResumeLayout(false);
            this.panTotal.ResumeLayout(false);
            this.panTotal.PerformLayout();
            this.panel3.ResumeLayout(false);
            this.panel3.PerformLayout();
            this.panUnit.ResumeLayout(false);
            this.panUnit.PerformLayout();
            this.panel2.ResumeLayout(false);
            this.panel2.PerformLayout();
            this.panel1.ResumeLayout(false);
            this.panel1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.picTmpl)).EndInit();
            this.pnlTmplHeader.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.dgvTmplDetail)).EndInit();
            this.pnlBottom.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.SplitContainer splTemplete;
        private System.Windows.Forms.Panel pnlTmplDrop;
        private System.Windows.Forms.Label lblTmplDescription;
        private System.Windows.Forms.PictureBox picTmpl;
        private System.Windows.Forms.Panel pnlTmplHeader;
        private System.Windows.Forms.Button btnTmplClear;
        private System.Windows.Forms.Button btnTmplSelect;
        private System.Windows.Forms.DataGridView dgvTmplDetail;
        private System.Windows.Forms.Panel pnlBottom;
        private System.Windows.Forms.Button btnTmplMakeData;
        private System.Windows.Forms.Panel panTotal;
        private System.Windows.Forms.Panel panUnit;
        private System.Windows.Forms.TextBox txtTotalUnitV;
        private System.Windows.Forms.Panel panel2;
        private System.Windows.Forms.RadioButton radTotalCountV;
        private System.Windows.Forms.RadioButton radTotalCountVDisp;
        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.RadioButton radTotalCountH;
        private System.Windows.Forms.RadioButton radTotalCountHDisp;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Button btnChange;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.ComboBox cobTotalContents;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.ComboBox cobTotalUnitDate;
        private System.Windows.Forms.Panel panel3;
        private System.Windows.Forms.TextBox txtTotalUnitH;
        // add 単一集計帳票／複数集計帳票：帳票分類コンボボックスの追加 鄧シン  start
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.ComboBox cobTotalReportType;
        private System.Windows.Forms.Button btnTotalUnitH;
        private System.Windows.Forms.Button btnTotalUnitV;
        private System.Windows.Forms.ComboBox cobTotalContentsType;
        private System.Windows.Forms.CheckBox chkEffectDataV;
        private System.Windows.Forms.CheckBox chkEffectDataH;
        // add 単一集計帳票／複数集計帳票：帳票分類コンボボックスの追加 鄧シン  end
    }
}