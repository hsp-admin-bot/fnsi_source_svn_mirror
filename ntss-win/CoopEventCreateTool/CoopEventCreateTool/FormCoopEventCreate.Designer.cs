using System;

namespace CoopEventCreateOrStopTool
{
    partial class CoopEventCreatOrStopForm
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
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle1 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle2 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle5 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle6 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle7 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle3 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle4 = new System.Windows.Forms.DataGridViewCellStyle();

            // add #9033 仕様変更　 処理中患者の処理件数/全件と何人目の患者/患者総数を表示する画面 董 start
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle8 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle9 = new System.Windows.Forms.DataGridViewCellStyle();
            // add #9033 仕様変更　 処理中患者の処理件数/全件と何人目の患者/患者総数を表示する画面 董 end

            this.labHotokose = new System.Windows.Forms.Label();
            this.labSyubetu = new System.Windows.Forms.Label();
            this.labKikan = new System.Windows.Forms.Label();
            this.labKansya = new System.Windows.Forms.Label();
            this.labHotokoseShow = new System.Windows.Forms.Label();
            this.dateKikanFrom = new System.Windows.Forms.DateTimePicker();
            this.dateKikanTo = new System.Windows.Forms.DateTimePicker();
            this.lab = new System.Windows.Forms.Label();
            this.labCoopEvent = new System.Windows.Forms.Label();
            this.radioCoopEventCreat = new System.Windows.Forms.RadioButton();
            this.radioCoopEventStop = new System.Windows.Forms.RadioButton();
            this.btnCancel = new System.Windows.Forms.Button();
            this.btnSend = new System.Windows.Forms.Button();
            this.btnStop1 = new System.Windows.Forms.Button();
            this.panel2 = new System.Windows.Forms.Panel();
            this.comboBox1 = new System.Windows.Forms.ComboBox();
            this.comSyubetu = new System.Windows.Forms.ComboBox();
            this.btnSearch = new System.Windows.Forms.Button();
            this.panel3 = new System.Windows.Forms.Panel();
            this.checKBox1 = new System.Windows.Forms.CheckBox();
            this.dataGridKansya = new System.Windows.Forms.DataGridView();
            this.ColCheck = new System.Windows.Forms.DataGridViewCheckBoxColumn();
            this.colHosppatId = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.ColKansya = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.colPatid = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.colOrdno = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.colTreatdate = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.Column1 = new System.Windows.Forms.DataGridViewImageColumn();

            // add #9033 仕様変更　 処理中患者の処理件数/全件と何人目の患者/患者総数を表示する画面 董 start
            this.ColSyoriKensu = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.ColEra = new System.Windows.Forms.DataGridViewTextBoxColumn();
            // add #9033 仕様変更　 処理中患者の処理件数/全件と何人目の患者/患者総数を表示する画面 董 end

            this.winMinimizeBox = new LayoutDesignerUtilityLib.Controls.WindowMinimizeBox();
            this.winCloseBox = new LayoutDesignerUtilityLib.Controls.WindowCloseBox();
            this.progressBar = new System.Windows.Forms.ProgressBar();
            this.panel2.SuspendLayout();
            this.panel3.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridKansya)).BeginInit();
            this.SuspendLayout();
            // 
            // winlblTitle
            // 
            this.winlblTitle.Font = new System.Drawing.Font("MS UI Gothic", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.winlblTitle.Location = new System.Drawing.Point(1, 1);
            this.winlblTitle.Size = new System.Drawing.Size(548, 34);
            this.winlblTitle.TabIndex = 14;
            this.winlblTitle.Text = "連携イベント作成・中止ツール";
            this.winlblTitle.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // labHotokose
            // 
            this.labHotokose.AutoSize = true;
            this.labHotokose.CausesValidation = false;
            this.labHotokose.Font = new System.Drawing.Font("MS UI Gothic", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.labHotokose.ForeColor = System.Drawing.Color.White;
            this.labHotokose.Location = new System.Drawing.Point(11, 23);
            this.labHotokose.Name = "labHotokose";
            this.labHotokose.Size = new System.Drawing.Size(71, 12);
            this.labHotokose.TabIndex = 1;
            this.labHotokose.Text = "施　　 　　設：";
            // 
            // labSyubetu
            // 
            this.labSyubetu.AutoSize = true;
            this.labSyubetu.CausesValidation = false;
            this.labSyubetu.Font = new System.Drawing.Font("MS UI Gothic", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.labSyubetu.ForeColor = System.Drawing.Color.White;
            this.labSyubetu.Location = new System.Drawing.Point(11, 46);
            this.labSyubetu.Name = "labSyubetu";
            this.labSyubetu.Size = new System.Drawing.Size(71, 12);
            this.labSyubetu.TabIndex = 2;
            this.labSyubetu.Text = "種　　 　　別：";
            // 
            // labKikan
            // 
            this.labKikan.AutoSize = true;
            this.labKikan.CausesValidation = false;
            this.labKikan.Font = new System.Drawing.Font("MS UI Gothic", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.labKikan.ForeColor = System.Drawing.Color.White;
            this.labKikan.Location = new System.Drawing.Point(11, 98);
            this.labKikan.Name = "labKikan";
            this.labKikan.Size = new System.Drawing.Size(71, 12);
            this.labKikan.TabIndex = 3;
            this.labKikan.Text = "期 間 指 定：";
            // 
            // labKansya
            // 
            this.labKansya.AutoSize = true;
            this.labKansya.CausesValidation = false;
            this.labKansya.Font = new System.Drawing.Font("MS UI Gothic", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.labKansya.ForeColor = System.Drawing.Color.White;
            this.labKansya.Location = new System.Drawing.Point(11, 4);
            this.labKansya.Name = "labKansya";
            this.labKansya.Size = new System.Drawing.Size(71, 12);
            this.labKansya.TabIndex = 4;
            this.labKansya.Text = "患 者 指 定：";
            // 
            // labHotokoseShow
            // 
            this.labHotokoseShow.AutoSize = true;
            this.labHotokoseShow.CausesValidation = false;
            this.labHotokoseShow.Font = new System.Drawing.Font("MS UI Gothic", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.labHotokoseShow.ForeColor = System.Drawing.Color.White;
            this.labHotokoseShow.Location = new System.Drawing.Point(128, 64);
            this.labHotokoseShow.Name = "labHotokoseShow";
            this.labHotokoseShow.Size = new System.Drawing.Size(0, 12);
            this.labHotokoseShow.TabIndex = 5;
            // 
            // dateKikanFrom
            // 
            this.dateKikanFrom.CalendarForeColor = System.Drawing.Color.White;
            this.dateKikanFrom.CalendarMonthBackground = System.Drawing.Color.FromArgb(((int)(((byte)(50)))), ((int)(((byte)(50)))), ((int)(((byte)(50)))));
            this.dateKikanFrom.CalendarTitleBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(50)))), ((int)(((byte)(50)))), ((int)(((byte)(50)))));
            this.dateKikanFrom.CalendarTitleForeColor = System.Drawing.Color.White;
            this.dateKikanFrom.CalendarTrailingForeColor = System.Drawing.Color.White;
            this.dateKikanFrom.Font = new System.Drawing.Font("MS UI Gothic", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.dateKikanFrom.Format = System.Windows.Forms.DateTimePickerFormat.Short;
            this.dateKikanFrom.Location = new System.Drawing.Point(85, 94);
            this.dateKikanFrom.Name = "dateKikanFrom";
            this.dateKikanFrom.Size = new System.Drawing.Size(101, 19);
            this.dateKikanFrom.TabIndex = 7;
            this.dateKikanFrom.Value = new System.DateTime(2021, 2, 18, 19, 8, 0, 0);
            // 
            // dateKikanTo
            // 
            this.dateKikanTo.Font = new System.Drawing.Font("MS UI Gothic", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.dateKikanTo.Format = System.Windows.Forms.DateTimePickerFormat.Short;
            this.dateKikanTo.Location = new System.Drawing.Point(211, 94);
            this.dateKikanTo.Name = "dateKikanTo";
            this.dateKikanTo.Size = new System.Drawing.Size(98, 19);
            this.dateKikanTo.TabIndex = 8;
            // 
            // lab
            // 
            this.lab.AutoSize = true;
            this.lab.CausesValidation = false;
            this.lab.Font = new System.Drawing.Font("MS UI Gothic", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.lab.ForeColor = System.Drawing.Color.White;
            this.lab.Location = new System.Drawing.Point(190, 98);
            this.lab.Name = "lab";
            this.lab.Size = new System.Drawing.Size(17, 12);
            this.lab.TabIndex = 9;
            this.lab.Text = "～";
            // 
            // labCoopEvent
            // 
            this.labCoopEvent.AutoSize = true;
            this.labCoopEvent.CausesValidation = false;
            this.labCoopEvent.Font = new System.Drawing.Font("MS UI Gothic", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.labCoopEvent.ForeColor = System.Drawing.Color.White;
            this.labCoopEvent.Location = new System.Drawing.Point(11, 71);
            this.labCoopEvent.Name = "labCoopEvent";
            this.labCoopEvent.Size = new System.Drawing.Size(71, 12);
            this.labCoopEvent.TabIndex = 10;
            this.labCoopEvent.Text = "連携イベント：";
            // 
            // radioCoopEventCreat
            // 
            this.radioCoopEventCreat.AutoSize = true;
            this.radioCoopEventCreat.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.radioCoopEventCreat.Checked = true;
            this.radioCoopEventCreat.Font = new System.Drawing.Font("MS UI Gothic", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.radioCoopEventCreat.ForeColor = System.Drawing.Color.White;
            this.radioCoopEventCreat.Location = new System.Drawing.Point(85, 71);
            this.radioCoopEventCreat.Name = "radioCoopEventCreat";
            this.radioCoopEventCreat.Size = new System.Drawing.Size(47, 16);
            this.radioCoopEventCreat.TabIndex = 12;
            this.radioCoopEventCreat.TabStop = true;
            this.radioCoopEventCreat.Text = "作成";
            this.radioCoopEventCreat.UseVisualStyleBackColor = false;
            // 
            // radioCoopEventStop
            // 
            this.radioCoopEventStop.AutoSize = true;
            this.radioCoopEventStop.Font = new System.Drawing.Font("MS UI Gothic", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.radioCoopEventStop.ForeColor = System.Drawing.Color.White;
            this.radioCoopEventStop.Location = new System.Drawing.Point(190, 73);
            this.radioCoopEventStop.Name = "radioCoopEventStop";
            this.radioCoopEventStop.Size = new System.Drawing.Size(47, 16);
            this.radioCoopEventStop.TabIndex = 13;
            this.radioCoopEventStop.TabStop = true;
            this.radioCoopEventStop.Text = "中止";
            this.radioCoopEventStop.UseVisualStyleBackColor = true;
            // 
            // btnCancel
            // 
            this.btnCancel.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnCancel.Font = new System.Drawing.Font("MS UI Gothic", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.btnCancel.ForeColor = System.Drawing.Color.White;
            this.btnCancel.Location = new System.Drawing.Point(33, 418);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(75, 23);
            this.btnCancel.TabIndex = 0;
            //mod #9434 キャンセルの動きが不正なため不要 donghao start
            this.btnCancel.Text = "初期化";
            //this.btnCancel.Text = "キャンセル";
            //mod #9434 キャンセルの動きが不正なため不要 donghao start
            this.btnCancel.UseVisualStyleBackColor = true;
            this.btnCancel.Click += new System.EventHandler(this.BtnCancel_Click);
            // 
            // btnSend
            // 
            this.btnSend.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnSend.Font = new System.Drawing.Font("MS UI Gothic", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.btnSend.ForeColor = System.Drawing.Color.White;
            this.btnSend.Location = new System.Drawing.Point(450, 418);
            this.btnSend.Name = "btnSend";
            this.btnSend.Size = new System.Drawing.Size(75, 23);
            this.btnSend.TabIndex = 15;
            this.btnSend.Text = "送信";
            this.btnSend.UseVisualStyleBackColor = true;
            this.btnSend.Click += new System.EventHandler(this.BtnSend_Click);
            // 
            // btnStop1
            // 
            this.btnStop1.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnStop1.Font = new System.Drawing.Font("MS UI Gothic", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.btnStop1.ForeColor = System.Drawing.Color.White;
            this.btnStop1.Location = new System.Drawing.Point(450, 418);
            this.btnStop1.Name = "btnStop1";
            this.btnStop1.Size = new System.Drawing.Size(75, 23);
            this.btnStop1.TabIndex = 16;
            this.btnStop1.Text = "中断";
            this.btnStop1.UseVisualStyleBackColor = true;
            this.btnStop1.Click += new System.EventHandler(this.BtnStop_Click);
            // 
            // panel2
            // 
            this.panel2.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.panel2.Controls.Add(this.comboBox1);
            this.panel2.Controls.Add(this.comSyubetu);
            this.panel2.Controls.Add(this.btnSearch);
            this.panel2.Controls.Add(this.labKikan);
            this.panel2.Controls.Add(this.labSyubetu);
            this.panel2.Controls.Add(this.dateKikanFrom);
            this.panel2.Controls.Add(this.dateKikanTo);
            this.panel2.Controls.Add(this.radioCoopEventStop);
            this.panel2.Controls.Add(this.labHotokose);
            this.panel2.Controls.Add(this.lab);
            this.panel2.Controls.Add(this.radioCoopEventCreat);
            this.panel2.Controls.Add(this.labCoopEvent);
            this.panel2.ForeColor = System.Drawing.SystemColors.InactiveCaptionText;
            this.panel2.Location = new System.Drawing.Point(33, 40);
            this.panel2.Name = "panel2";
            this.panel2.Padding = new System.Windows.Forms.Padding(1);
            this.panel2.Size = new System.Drawing.Size(492, 128);
            this.panel2.TabIndex = 17;
            // 
            // comboBox1
            // 
            this.comboBox1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(50)))), ((int)(((byte)(50)))), ((int)(((byte)(50)))));
            this.comboBox1.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.comboBox1.Font = new System.Drawing.Font("MS UI Gothic", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.comboBox1.ForeColor = System.Drawing.Color.White;
            this.comboBox1.FormattingEnabled = true;
            this.comboBox1.Location = new System.Drawing.Point(85, 21);
            this.comboBox1.Name = "comboBox1";
            this.comboBox1.Size = new System.Drawing.Size(224, 20);
            this.comboBox1.TabIndex = 14;
            this.comboBox1.Visible = false;
            this.comboBox1.SelectedIndexChanged += new System.EventHandler(this.comboBox1_SelectedIndexChanged);
            // 
            // comSyubetu
            // 
            this.comSyubetu.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(50)))), ((int)(((byte)(50)))), ((int)(((byte)(50)))));
            this.comSyubetu.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.comSyubetu.Font = new System.Drawing.Font("MS UI Gothic", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.comSyubetu.ForeColor = System.Drawing.Color.White;
            this.comSyubetu.FormattingEnabled = true;
            this.comSyubetu.Location = new System.Drawing.Point(85, 44);
            this.comSyubetu.Name = "comSyubetu";
            this.comSyubetu.Size = new System.Drawing.Size(224, 20);
            this.comSyubetu.TabIndex = 11;
            // 
            // btnSearch
            // 
            this.btnSearch.Cursor = System.Windows.Forms.Cursors.Default;
            this.btnSearch.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnSearch.Font = new System.Drawing.Font("MS UI Gothic", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.btnSearch.ForeColor = System.Drawing.Color.White;
            this.btnSearch.Location = new System.Drawing.Point(412, 89);
            this.btnSearch.Name = "btnSearch";
            this.btnSearch.Size = new System.Drawing.Size(68, 23);
            this.btnSearch.TabIndex = 9;
            this.btnSearch.Text = "検索";
            this.btnSearch.UseVisualStyleBackColor = false;
            this.btnSearch.Click += new System.EventHandler(this.BtnSearch_Click);
            // 
            // panel3
            // 
            this.panel3.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.panel3.Controls.Add(this.checKBox1);
            this.panel3.Controls.Add(this.dataGridKansya);
            this.panel3.Controls.Add(this.labKansya);
            this.panel3.Location = new System.Drawing.Point(33, 174);
            this.panel3.Name = "panel3";
            this.panel3.Padding = new System.Windows.Forms.Padding(1);
            this.panel3.Size = new System.Drawing.Size(492, 239);
            this.panel3.TabIndex = 19;
            // 
            // checKBox1
            // 
            this.checKBox1.AutoSize = true;
            this.checKBox1.Font = new System.Drawing.Font("MS UI Gothic", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.checKBox1.Location = new System.Drawing.Point(104, 11);
            this.checKBox1.Margin = new System.Windows.Forms.Padding(2);
            this.checKBox1.Name = "checKBox1";
            this.checKBox1.Size = new System.Drawing.Size(15, 14);
            this.checKBox1.TabIndex = 11;
            this.checKBox1.UseVisualStyleBackColor = true;
            this.checKBox1.CheckedChanged += new System.EventHandler(this.checKBox1_CheckedChanged);
            // 
            // dataGridKansya
            // 
            this.dataGridKansya.AllowUserToAddRows = false;
            this.dataGridKansya.AllowUserToDeleteRows = false;
            this.dataGridKansya.AllowUserToResizeColumns = false;
            this.dataGridKansya.AllowUserToResizeRows = false;
            dataGridViewCellStyle1.Font = new System.Drawing.Font("MS UI Gothic", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.dataGridKansya.AlternatingRowsDefaultCellStyle = dataGridViewCellStyle1;
            this.dataGridKansya.BackgroundColor = System.Drawing.Color.FromArgb(((int)(((byte)(50)))), ((int)(((byte)(50)))), ((int)(((byte)(50)))));
            this.dataGridKansya.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.dataGridKansya.ColumnHeadersBorderStyle = System.Windows.Forms.DataGridViewHeaderBorderStyle.Single;
            dataGridViewCellStyle2.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleCenter;
            dataGridViewCellStyle2.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(50)))), ((int)(((byte)(50)))), ((int)(((byte)(50)))));
            dataGridViewCellStyle2.Font = new System.Drawing.Font("MS UI Gothic", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle2.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle2.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle2.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            dataGridViewCellStyle2.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.dataGridKansya.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle2;
            this.dataGridKansya.ColumnHeadersHeight = 25;
            this.dataGridKansya.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.DisableResizing;
            this.dataGridKansya.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.ColCheck,
            this.colHosppatId,
            this.ColKansya,
            this.colPatid,
            this.colOrdno,
            this.colTreatdate,
            this.Column1,
            // add #9033 仕様変更　 処理中患者の処理件数/全件と何人目の患者/患者総数を表示する画面 董 start
            this.ColSyoriKensu,
            this.ColEra
            // add #9033 仕様変更　 処理中患者の処理件数/全件と何人目の患者/患者総数を表示する画面 董 end
            });
            this.dataGridKansya.Cursor = System.Windows.Forms.Cursors.Default;
            dataGridViewCellStyle5.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle5.BackColor = System.Drawing.SystemColors.Window;
            dataGridViewCellStyle5.Font = new System.Drawing.Font("MS UI Gothic", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle5.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle5.SelectionBackColor = System.Drawing.Color.SlateGray;
            dataGridViewCellStyle5.SelectionForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle5.WrapMode = System.Windows.Forms.DataGridViewTriState.False;
            this.dataGridKansya.DefaultCellStyle = dataGridViewCellStyle5;
            this.dataGridKansya.EnableHeadersVisualStyles = false;
            this.dataGridKansya.GridColor = System.Drawing.Color.FromArgb(((int)(((byte)(70)))), ((int)(((byte)(70)))), ((int)(((byte)(70)))));
            this.dataGridKansya.Location = new System.Drawing.Point(85, 4);
            this.dataGridKansya.MultiSelect = false;
            this.dataGridKansya.Name = "dataGridKansya";
            dataGridViewCellStyle6.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle6.BackColor = System.Drawing.SystemColors.Control;
            dataGridViewCellStyle6.Font = new System.Drawing.Font("MS UI Gothic", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle6.ForeColor = System.Drawing.SystemColors.WindowText;
            dataGridViewCellStyle6.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle6.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            dataGridViewCellStyle6.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.dataGridKansya.RowHeadersDefaultCellStyle = dataGridViewCellStyle6;
            this.dataGridKansya.RowHeadersVisible = false;
            this.dataGridKansya.RowHeadersWidth = 40;
            dataGridViewCellStyle7.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(40)))), ((int)(((byte)(40)))), ((int)(((byte)(40)))));
            dataGridViewCellStyle7.Font = new System.Drawing.Font("MS UI Gothic", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle7.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle7.SelectionBackColor = System.Drawing.Color.SlateGray;
            dataGridViewCellStyle7.SelectionForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle7.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.dataGridKansya.RowsDefaultCellStyle = dataGridViewCellStyle7;
            this.dataGridKansya.RowTemplate.Height = 21;
            this.dataGridKansya.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dataGridKansya.Size = new System.Drawing.Size(395, 229);
            this.dataGridKansya.TabIndex = 10;
            this.dataGridKansya.CurrentCellDirtyStateChanged += new System.EventHandler(this.DataGridKansya_CurrentCellDirtyStateChanged);
            // 
            // ColCheck
            // 
            this.ColCheck.DataPropertyName = "ColCheck";
            this.ColCheck.FillWeight = 50F;
            this.ColCheck.FlatStyle = System.Windows.Forms.FlatStyle.System;
            this.ColCheck.HeaderText = "";
            this.ColCheck.MinimumWidth = 6;
            this.ColCheck.Name = "ColCheck";
            this.ColCheck.Width = 50;
            // 
            // colHosppatId
            // 
            this.colHosppatId.DataPropertyName = "colHosppatId";
            dataGridViewCellStyle3.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(64)))), ((int)(((byte)(64)))), ((int)(((byte)(64)))));
            this.colHosppatId.DefaultCellStyle = dataGridViewCellStyle3;
            this.colHosppatId.HeaderText = "患者ID";
            this.colHosppatId.MinimumWidth = 6;
            this.colHosppatId.Name = "colHosppatId";
            this.colHosppatId.ReadOnly = true;
            // mod #9033 仕様変更　 処理中患者の処理件数/全件と何人目の患者/患者総数を表示する画面 董 start
            //this.colHosppatId.Width = 125;
            this.colHosppatId.Width = 80;
            // mod #9033 仕様変更　 処理中患者の処理件数/全件と何人目の患者/患者総数を表示する画面 董 end
            // 
            // ColKansya
            // 
            // mod #9033 仕様変更　 処理中患者の処理件数/全件と何人目の患者/患者総数を表示する画面 董 start
            //this.ColKansya.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.Fill;
            this.ColKansya.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.AllCells;
            // mod #9033 仕様変更　 処理中患者の処理件数/全件と何人目の患者/患者総数を表示する画面 董 end
            this.ColKansya.DataPropertyName = "ColKansya";
            this.ColKansya.FillWeight = 200F;
            this.ColKansya.HeaderText = "患者";
            this.ColKansya.MinimumWidth = 6;
            this.ColKansya.Name = "ColKansya";
            this.ColKansya.ReadOnly = true;
            this.ColKansya.Resizable = System.Windows.Forms.DataGridViewTriState.True;
            this.ColKansya.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable;
            // 
            // colPatid
            // 
            this.colPatid.DataPropertyName = "colPatid";
            dataGridViewCellStyle4.ForeColor = System.Drawing.Color.Black;
            dataGridViewCellStyle4.SelectionForeColor = System.Drawing.Color.Black;
            this.colPatid.DefaultCellStyle = dataGridViewCellStyle4;
            this.colPatid.HeaderText = "patid";
            this.colPatid.MinimumWidth = 6;
            this.colPatid.Name = "colPatid";
            this.colPatid.Visible = false;
            // mod #9033 仕様変更　 処理中患者の処理件数/全件と何人目の患者/患者総数を表示する画面 董 start
            //this.colPatid.Width = 125;
            this.colPatid.Width = 50;
            // mod #9033 仕様変更　 処理中患者の処理件数/全件と何人目の患者/患者総数を表示する画面 董 end
            // 
            // colOrdno
            // 
            this.colOrdno.DataPropertyName = "colOrdno";
            this.colOrdno.HeaderText = "ordno";
            this.colOrdno.MinimumWidth = 6;
            this.colOrdno.Name = "colOrdno";
            this.colOrdno.Visible = false;
            // mod #9033 仕様変更　 処理中患者の処理件数/全件と何人目の患者/患者総数を表示する画面 董 start
            //this.colOrdno.Width = 125;
            this.colOrdno.Width = 50;
            // mod #9033 仕様変更　 処理中患者の処理件数/全件と何人目の患者/患者総数を表示する画面 董 end
            // 
            // colTreatdate
            // 
            this.colTreatdate.DataPropertyName = "colTreatdate";
            this.colTreatdate.HeaderText = "treatdate";
            this.colTreatdate.MinimumWidth = 6;
            this.colTreatdate.Name = "colTreatdate";
            this.colTreatdate.Visible = false;
            // mod #9033 仕様変更　 処理中患者の処理件数/全件と何人目の患者/患者総数を表示する画面 董 start
            //this.colTreatdate.Width = 125;
            this.colTreatdate.Width = 80;
            // mod #9033 仕様変更　 処理中患者の処理件数/全件と何人目の患者/患者総数を表示する画面 董 end
            // 
            // Column1
            // 
            this.Column1.HeaderText = "";
            this.Column1.ImageLayout = System.Windows.Forms.DataGridViewImageCellLayout.Zoom;
            this.Column1.MinimumWidth = 6;
            this.Column1.Name = "Column1";
            this.Column1.Width = 50;

            // add #9033 仕様変更　 処理中患者の処理件数/全件と何人目の患者/患者総数を表示する画面 董 start
            // 
            // ColSyoriKensu
            // 

            this.ColSyoriKensu.DataPropertyName = "ColSyoriKensu";
            this.ColSyoriKensu.HeaderText = "処理件数";
            this.ColSyoriKensu.MinimumWidth = 6;
            this.ColSyoriKensu.Name = "ColSyoriKensu";
            this.ColSyoriKensu.ReadOnly = true;
            this.ColSyoriKensu.Width = 70;
            // 
            // ColEra
            // 
            this.ColEra.DataPropertyName = "ColEra";
            this.ColEra.FillWeight = 200F;
            this.ColEra.HeaderText = "エラー";
            this.ColEra.MinimumWidth = 6;
            this.ColEra.Name = "ColEra";
            this.ColEra.ReadOnly = true;
            this.ColEra.Width = 50;
            //add #9033 仕様変更　 処理中患者の処理件数/全件と何人目の患者/患者総数を表示する画面 董 end

            // 
            // winMinimizeBox
            // 
            this.winMinimizeBox.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.winMinimizeBox.FlatAppearance.BorderSize = 0;
            this.winMinimizeBox.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.winMinimizeBox.Font = new System.Drawing.Font("Segoe MDL2 Assets", 9F);
            this.winMinimizeBox.Location = new System.Drawing.Point(476, 5);
            this.winMinimizeBox.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.winMinimizeBox.Name = "winMinimizeBox";
            this.winMinimizeBox.Size = new System.Drawing.Size(31, 31);
            this.winMinimizeBox.TabIndex = 1;
            this.winMinimizeBox.Text = "最小化";
            this.winMinimizeBox.UseVisualStyleBackColor = false;
            // 
            // winCloseBox
            // 
            this.winCloseBox.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.winCloseBox.FlatAppearance.BorderSize = 0;
            this.winCloseBox.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.winCloseBox.Font = new System.Drawing.Font("Segoe MDL2 Assets", 9F);
            this.winCloseBox.Location = new System.Drawing.Point(513, 5);
            this.winCloseBox.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.winCloseBox.Name = "winCloseBox";
            this.winCloseBox.Size = new System.Drawing.Size(31, 31);
            this.winCloseBox.TabIndex = 21;
            this.winCloseBox.Text = "閉じる";
            this.winCloseBox.UseVisualStyleBackColor = false;

            // add #8915 処理中にウインドウズの×を押された時の制御がない 董昊 start
            this.winCloseBox.Click += new EventHandler(winCloseBox_Exit_Click);
            // add #8915 処理中にウインドウズの×を押された時の制御がない 董昊 end

            // 
            // progressBar
            // 
            this.progressBar.Location = new System.Drawing.Point(4, 447);
            this.progressBar.Name = "progressBar";
            this.progressBar.Size = new System.Drawing.Size(467, 10);
            this.progressBar.TabIndex = 22;
            this.progressBar.Visible = false;
            // 
            // CoopEventCreatOrStopForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(77)))), ((int)(((byte)(77)))), ((int)(((byte)(77)))));
            this.ClientSize = new System.Drawing.Size(550, 458);
            this.Controls.Add(this.progressBar);
            this.Controls.Add(this.winCloseBox);
            this.Controls.Add(this.winMinimizeBox);
            this.Controls.Add(this.btnStop1);
            this.Controls.Add(this.btnSend);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.labHotokoseShow);
            this.Controls.Add(this.panel2);
            this.Controls.Add(this.panel3);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            this.Margin = new System.Windows.Forms.Padding(3, 5, 3, 5);
            this.MaximizeBox = false;
            this.Name = "CoopEventCreatOrStopForm";
            this.Padding = new System.Windows.Forms.Padding(1);
            this.Text = "連携イベント作成・中止ツール";
            this.Controls.SetChildIndex(this.winlblTitle, 0);
            this.Controls.SetChildIndex(this.panel3, 0);
            this.Controls.SetChildIndex(this.panel2, 0);
            this.Controls.SetChildIndex(this.labHotokoseShow, 0);
            this.Controls.SetChildIndex(this.btnCancel, 0);
            this.Controls.SetChildIndex(this.btnSend, 0);
            this.Controls.SetChildIndex(this.btnStop1, 0);
            this.Controls.SetChildIndex(this.winMinimizeBox, 0);
            this.Controls.SetChildIndex(this.winCloseBox, 0);
            this.Controls.SetChildIndex(this.progressBar, 0);
            this.Controls.SetChildIndex(this.btnFocusControl, 0);
            this.Controls.SetChildIndex(this.btnTop, 0);
            this.Controls.SetChildIndex(this.btnStop, 0);
            this.panel2.ResumeLayout(false);
            this.panel2.PerformLayout();
            this.panel3.ResumeLayout(false);
            this.panel3.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridKansya)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion
        private System.Windows.Forms.Label labHotokose;
        private System.Windows.Forms.Label labSyubetu;
        private System.Windows.Forms.Label labKikan;
        private System.Windows.Forms.Label labKansya;
        private System.Windows.Forms.Label labHotokoseShow;
        private System.Windows.Forms.DateTimePicker dateKikanFrom;
        private System.Windows.Forms.DateTimePicker dateKikanTo;
        private System.Windows.Forms.Label lab;
        private System.Windows.Forms.Label labCoopEvent;
        private System.Windows.Forms.RadioButton radioCoopEventCreat;
        private System.Windows.Forms.RadioButton radioCoopEventStop;
        private System.Windows.Forms.Button btnCancel;
        private System.Windows.Forms.Button btnSend;
        private System.Windows.Forms.Button btnStop1;
        private System.Windows.Forms.Panel panel2;
        private System.Windows.Forms.Button btnSearch;
        private System.Windows.Forms.Panel panel3;
        private System.Windows.Forms.DataGridView dataGridKansya;
        private LayoutDesignerUtilityLib.Controls.WindowMinimizeBox winMinimizeBox;
        private LayoutDesignerUtilityLib.Controls.WindowCloseBox winCloseBox;
        private System.Windows.Forms.ComboBox comSyubetu;
        private System.Windows.Forms.ProgressBar progressBar;
        private System.Windows.Forms.CheckBox checKBox1;
        private System.Windows.Forms.DataGridViewCheckBoxColumn ColCheck;
        private System.Windows.Forms.DataGridViewTextBoxColumn colHosppatId;
        private System.Windows.Forms.DataGridViewTextBoxColumn ColKansya;
        private System.Windows.Forms.DataGridViewTextBoxColumn colPatid;
        private System.Windows.Forms.DataGridViewTextBoxColumn colOrdno;
        private System.Windows.Forms.DataGridViewTextBoxColumn colTreatdate;
        private System.Windows.Forms.DataGridViewImageColumn Column1;

        //#9033 仕様変更　 処理中患者の処理件数/全件と何人目の患者/患者総数を表示する画面 董 start
        private System.Windows.Forms.DataGridViewTextBoxColumn ColSyoriKensu;
        private System.Windows.Forms.DataGridViewTextBoxColumn ColEra;
        //#9033 仕様変更　 処理中患者の処理件数/全件と何人目の患者/患者総数を表示する画面 董 end

        private System.Windows.Forms.ComboBox comboBox1;
    }
}
