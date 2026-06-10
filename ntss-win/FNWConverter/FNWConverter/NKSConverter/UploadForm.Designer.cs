namespace NKSConverter
{
  partial class UploadForm
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(UploadForm));
            this.openFileDialog1 = new System.Windows.Forms.OpenFileDialog();
            this.btnChooseFile = new System.Windows.Forms.Button();
            this.txtPathBrowse = new System.Windows.Forms.TextBox();
            this.btnUpload = new System.Windows.Forms.Button();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.ltvFiles = new System.Windows.Forms.ListBox();
            this.btnStopJob = new System.Windows.Forms.Button();
            this.btnExecuteJob = new System.Windows.Forms.Button();
            this.label1 = new System.Windows.Forms.Label();
            this.txtMessage = new System.Windows.Forms.TextBox();
            this.btnDeleteConvTable = new System.Windows.Forms.Button();
            this.btnDeleteTable = new System.Windows.Forms.Button();
            this.label2 = new System.Windows.Forms.Label();
            this.comboBoxSeriesCd = new System.Windows.Forms.ComboBox();
            this.groupBox2.SuspendLayout();
            this.SuspendLayout();
            // 
            // openFileDialog1
            // 
            this.openFileDialog1.FileName = "openFileDialog1";
            // 
            // btnChooseFile
            // 
            this.btnChooseFile.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.btnChooseFile.Location = new System.Drawing.Point(646, 172);
            this.btnChooseFile.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.btnChooseFile.Name = "btnChooseFile";
            this.btnChooseFile.Size = new System.Drawing.Size(75, 30);
            this.btnChooseFile.TabIndex = 1;
            this.btnChooseFile.Text = "Browse";
            this.btnChooseFile.UseVisualStyleBackColor = true;
            // 
            // txtPathBrowse
            // 
            this.txtPathBrowse.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.txtPathBrowse.Location = new System.Drawing.Point(180, 178);
            this.txtPathBrowse.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.txtPathBrowse.Name = "txtPathBrowse";
            this.txtPathBrowse.ReadOnly = true;
            this.txtPathBrowse.Size = new System.Drawing.Size(446, 19);
            this.txtPathBrowse.TabIndex = 2;
            // 
            // btnUpload
            // 
            this.btnUpload.Location = new System.Drawing.Point(12, 167);
            this.btnUpload.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.btnUpload.Name = "btnUpload";
            this.btnUpload.Size = new System.Drawing.Size(75, 30);
            this.btnUpload.TabIndex = 1;
            this.btnUpload.Text = "Upload";
            this.btnUpload.UseVisualStyleBackColor = true;
            // 
            // groupBox2
            // 
            this.groupBox2.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.groupBox2.Controls.Add(this.ltvFiles);
            this.groupBox2.Location = new System.Drawing.Point(11, 225);
            this.groupBox2.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Padding = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.groupBox2.Size = new System.Drawing.Size(710, 263);
            this.groupBox2.TabIndex = 4;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "選択ファイル";
            // 
            // ltvFiles
            // 
            this.ltvFiles.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.ltvFiles.FormattingEnabled = true;
            this.ltvFiles.ItemHeight = 12;
            this.ltvFiles.Location = new System.Drawing.Point(7, 30);
            this.ltvFiles.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.ltvFiles.Name = "ltvFiles";
            this.ltvFiles.Size = new System.Drawing.Size(697, 220);
            this.ltvFiles.TabIndex = 0;
            // 
            // btnStopJob
            // 
            this.btnStopJob.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.btnStopJob.BackColor = System.Drawing.Color.Red;
            this.btnStopJob.ForeColor = System.Drawing.Color.White;
            this.btnStopJob.Location = new System.Drawing.Point(601, 47);
            this.btnStopJob.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.btnStopJob.Name = "btnStopJob";
            this.btnStopJob.Size = new System.Drawing.Size(120, 38);
            this.btnStopJob.TabIndex = 10;
            this.btnStopJob.Text = "コンバート停止\r\nリクエスト送信";
            this.btnStopJob.UseVisualStyleBackColor = false;
            // 
            // btnExecuteJob
            // 
            this.btnExecuteJob.Location = new System.Drawing.Point(11, 48);
            this.btnExecuteJob.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.btnExecuteJob.Name = "btnExecuteJob";
            this.btnExecuteJob.Size = new System.Drawing.Size(120, 38);
            this.btnExecuteJob.TabIndex = 9;
            this.btnExecuteJob.Text = "コンバート実行\r\nリクエスト送信";
            this.btnExecuteJob.UseVisualStyleBackColor = true;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(16, 98);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(50, 12);
            this.label1.TabIndex = 13;
            this.label1.Text = "メッセージ";
            // 
            // txtMessage
            // 
            this.txtMessage.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.txtMessage.BackColor = System.Drawing.SystemColors.Info;
            this.txtMessage.Location = new System.Drawing.Point(11, 112);
            this.txtMessage.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.txtMessage.Multiline = true;
            this.txtMessage.Name = "txtMessage";
            this.txtMessage.ReadOnly = true;
            this.txtMessage.Size = new System.Drawing.Size(710, 38);
            this.txtMessage.TabIndex = 12;
            // 
            // btnDeleteConvTable
            // 
            this.btnDeleteConvTable.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.btnDeleteConvTable.DataBindings.Add(new System.Windows.Forms.Binding("Visible", global::NKSConverter.Properties.Settings.Default, "btnDeleteConvTable_Visible", true, System.Windows.Forms.DataSourceUpdateMode.OnPropertyChanged));
            this.btnDeleteConvTable.Location = new System.Drawing.Point(328, 48);
            this.btnDeleteConvTable.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.btnDeleteConvTable.Name = "btnDeleteConvTable";
            this.btnDeleteConvTable.Size = new System.Drawing.Size(125, 37);
            this.btnDeleteConvTable.TabIndex = 14;
            this.btnDeleteConvTable.Text = "コンバートDBデータ削除";
            this.btnDeleteConvTable.UseVisualStyleBackColor = true;
            // 
            // btnDeleteTable
            // 
            this.btnDeleteTable.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.btnDeleteTable.DataBindings.Add(new System.Windows.Forms.Binding("Visible", global::NKSConverter.Properties.Settings.Default, "btnDeleteTable_Visible", true, System.Windows.Forms.DataSourceUpdateMode.OnPropertyChanged));
            this.btnDeleteTable.Location = new System.Drawing.Point(458, 48);
            this.btnDeleteTable.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.btnDeleteTable.Name = "btnDeleteTable";
            this.btnDeleteTable.Size = new System.Drawing.Size(137, 38);
            this.btnDeleteTable.TabIndex = 11;
            this.btnDeleteTable.Text = "コンバートDB・本番DBテーブルデータ削除";
            this.btnDeleteTable.UseVisualStyleBackColor = true;
            this.btnDeleteTable.Visible = global::NKSConverter.Properties.Settings.Default.btnDeleteConvTable_Visible;
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(10, 17);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(120, 12);
            this.label2.TabIndex = 14;
            this.label2.Text = "データ移行先施設コード";
            // 
            // comboBoxSeriesCd
            // 
            this.comboBoxSeriesCd.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.comboBoxSeriesCd.FormattingEnabled = true;
            this.comboBoxSeriesCd.Location = new System.Drawing.Point(136, 14);
            this.comboBoxSeriesCd.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.comboBoxSeriesCd.Name = "comboBoxSeriesCd";
            this.comboBoxSeriesCd.Size = new System.Drawing.Size(160, 20);
            this.comboBoxSeriesCd.TabIndex = 48;
            this.comboBoxSeriesCd.SelectedIndexChanged += new System.EventHandler(this.comboBoxSeriesCd_SelectedIndexChanged);
            // 
            // UploadForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(741, 498);
            this.Controls.Add(this.comboBoxSeriesCd);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.btnDeleteConvTable);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.txtMessage);
            this.Controls.Add(this.btnDeleteTable);
            this.Controls.Add(this.btnStopJob);
            this.Controls.Add(this.btnExecuteJob);
            this.Controls.Add(this.groupBox2);
            this.Controls.Add(this.txtPathBrowse);
            this.Controls.Add(this.btnUpload);
            this.Controls.Add(this.btnChooseFile);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Margin = new System.Windows.Forms.Padding(4, 2, 4, 2);
            this.Name = "UploadForm";
            this.Text = " 送信管理画面";
            this.groupBox2.ResumeLayout(false);
            this.ResumeLayout(false);
            this.PerformLayout();

    }

    #endregion

    private System.Windows.Forms.OpenFileDialog openFileDialog1;
    private System.Windows.Forms.Button btnChooseFile;
    private System.Windows.Forms.TextBox txtPathBrowse;
    private System.Windows.Forms.Button btnUpload;
    private System.Windows.Forms.GroupBox groupBox2;
    private System.Windows.Forms.ListBox ltvFiles;
    private System.Windows.Forms.Button btnDeleteTable;
    private System.Windows.Forms.Button btnStopJob;
    private System.Windows.Forms.Button btnExecuteJob;
    private System.Windows.Forms.Label label1;
    private System.Windows.Forms.TextBox txtMessage;
    private System.Windows.Forms.Button btnDeleteConvTable;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.ComboBox comboBoxSeriesCd;
    }
}