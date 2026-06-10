
namespace CoopExtractTool
{
    partial class FormCSVView
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FormCSVView));
            this.btnEnd = new System.Windows.Forms.Button();
            this.btnBeginning = new System.Windows.Forms.Button();
            this.btnCSVFileOut = new System.Windows.Forms.Button();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.dgvCSVView = new System.Windows.Forms.DataGridView();
            this.btnOnOff = new System.Windows.Forms.Button();
            this.groupBox2.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgvCSVView)).BeginInit();
            this.SuspendLayout();
            // 
            // btnEnd
            // 
            this.btnEnd.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnEnd.Location = new System.Drawing.Point(366, 313);
            this.btnEnd.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.btnEnd.Name = "btnEnd";
            this.btnEnd.Size = new System.Drawing.Size(90, 25);
            this.btnEnd.TabIndex = 3;
            this.btnEnd.Text = "終了";
            this.btnEnd.UseVisualStyleBackColor = true;
            this.btnEnd.Click += new System.EventHandler(this.btnEnd_Click);
            // 
            // btnBeginning
            // 
            this.btnBeginning.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnBeginning.Location = new System.Drawing.Point(460, 313);
            this.btnBeginning.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.btnBeginning.Name = "btnBeginning";
            this.btnBeginning.Size = new System.Drawing.Size(90, 25);
            this.btnBeginning.TabIndex = 4;
            this.btnBeginning.Text = "最初から";
            this.btnBeginning.UseVisualStyleBackColor = true;
            this.btnBeginning.Click += new System.EventHandler(this.btnBeginning_Click);
            // 
            // btnCSVFileOut
            // 
            this.btnCSVFileOut.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.btnCSVFileOut.Location = new System.Drawing.Point(113, 313);
            this.btnCSVFileOut.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.btnCSVFileOut.Name = "btnCSVFileOut";
            this.btnCSVFileOut.Size = new System.Drawing.Size(126, 25);
            this.btnCSVFileOut.TabIndex = 2;
            this.btnCSVFileOut.Text = "CSV出力";
            this.btnCSVFileOut.UseVisualStyleBackColor = true;
            this.btnCSVFileOut.Click += new System.EventHandler(this.btnCSVFileOut_Click);
            // 
            // groupBox2
            // 
            this.groupBox2.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.groupBox2.Controls.Add(this.dgvCSVView);
            this.groupBox2.Location = new System.Drawing.Point(7, 8);
            this.groupBox2.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Padding = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.groupBox2.Size = new System.Drawing.Size(542, 301);
            this.groupBox2.TabIndex = 0;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "FNSi連携設定項目一覧";
            // 
            // dgvCSVView
            // 
            this.dgvCSVView.AllowUserToAddRows = false;
            this.dgvCSVView.AllowUserToResizeRows = false;
            this.dgvCSVView.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.dgvCSVView.ClipboardCopyMode = System.Windows.Forms.DataGridViewClipboardCopyMode.Disable;
            this.dgvCSVView.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvCSVView.Location = new System.Drawing.Point(9, 17);
            this.dgvCSVView.Margin = new System.Windows.Forms.Padding(0);
            this.dgvCSVView.Name = "dgvCSVView";
            this.dgvCSVView.ReadOnly = true;
            this.dgvCSVView.RowHeadersWidth = 62;
            this.dgvCSVView.RowTemplate.Height = 21;
            this.dgvCSVView.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dgvCSVView.Size = new System.Drawing.Size(524, 275);
            this.dgvCSVView.TabIndex = 0;
            // 
            // btnOnOff
            // 
            this.btnOnOff.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.btnOnOff.Location = new System.Drawing.Point(7, 313);
            this.btnOnOff.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.btnOnOff.Name = "btnOnOff";
            this.btnOnOff.Size = new System.Drawing.Size(103, 25);
            this.btnOnOff.TabIndex = 1;
            this.btnOnOff.Text = "On/Off";
            this.btnOnOff.UseVisualStyleBackColor = true;
            this.btnOnOff.Click += new System.EventHandler(this.btnOnOff_Click);
            // 
            // FormCSVView
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(557, 346);
            this.Controls.Add(this.btnOnOff);
            this.Controls.Add(this.btnCSVFileOut);
            this.Controls.Add(this.groupBox2);
            this.Controls.Add(this.btnEnd);
            this.Controls.Add(this.btnBeginning);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.MinimumSize = new System.Drawing.Size(459, 313);
            this.Name = "FormCSVView";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "FormCSVView";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.FormCSVView_FormClosing);
            this.Load += new System.EventHandler(this.FormCSVView_Load);
            this.groupBox2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.dgvCSVView)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Button btnEnd;
        private System.Windows.Forms.Button btnBeginning;
        private System.Windows.Forms.Button btnCSVFileOut;
        private System.Windows.Forms.GroupBox groupBox2;
        private System.Windows.Forms.DataGridView dgvCSVView;
        private System.Windows.Forms.Button btnOnOff;
    }
}