
namespace CoopExtractXMLMaker
{
    partial class FormCommonConversion
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
            this.dgvNameView = new System.Windows.Forms.DataGridView();
            this.btnClose = new System.Windows.Forms.Button();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.rdoTypePartialmatch = new System.Windows.Forms.RadioButton();
            this.rdoTypeExactmatch = new System.Windows.Forms.RadioButton();
            this.dgvValueView = new System.Windows.Forms.DataGridView();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            ((System.ComponentModel.ISupportInitialize)(this.dgvNameView)).BeginInit();
            this.groupBox1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgvValueView)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).BeginInit();
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
            this.SuspendLayout();
            // 
            // dgvNameView
            // 
            this.dgvNameView.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvNameView.Dock = System.Windows.Forms.DockStyle.Fill;
            this.dgvNameView.Location = new System.Drawing.Point(0, 0);
            this.dgvNameView.Margin = new System.Windows.Forms.Padding(2);
            this.dgvNameView.Name = "dgvNameView";
            this.dgvNameView.RowHeadersWidth = 62;
            this.dgvNameView.RowTemplate.Height = 27;
            this.dgvNameView.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dgvNameView.Size = new System.Drawing.Size(328, 259);
            this.dgvNameView.TabIndex = 0;
            this.dgvNameView.CellContentClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.dgvNameView_CellContentClick);
            this.dgvNameView.CellEndEdit += new System.Windows.Forms.DataGridViewCellEventHandler(this.dgvNameView_CellEndEdit);
            this.dgvNameView.RowsRemoved += new System.Windows.Forms.DataGridViewRowsRemovedEventHandler(this.dgvNameView_RowsRemoved);
            this.dgvNameView.SelectionChanged += new System.EventHandler(this.dgvNameView_SelectionChanged);
            this.dgvNameView.UserDeletingRow += new System.Windows.Forms.DataGridViewRowCancelEventHandler(this.dgvNameView_UserDeletingRow);
            this.dgvNameView.Validating += new System.ComponentModel.CancelEventHandler(this.dgvNameView_Validating);
            // 
            // btnClose
            // 
            this.btnClose.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnClose.Location = new System.Drawing.Point(505, 274);
            this.btnClose.Margin = new System.Windows.Forms.Padding(2);
            this.btnClose.Name = "btnClose";
            this.btnClose.Size = new System.Drawing.Size(120, 27);
            this.btnClose.TabIndex = 5;
            this.btnClose.Text = "閉じる";
            this.btnClose.UseVisualStyleBackColor = true;
            this.btnClose.Click += new System.EventHandler(this.btnClose_Click);
            // 
            // groupBox1
            // 
            this.groupBox1.BackColor = System.Drawing.SystemColors.Control;
            this.groupBox1.Controls.Add(this.rdoTypePartialmatch);
            this.groupBox1.Controls.Add(this.rdoTypeExactmatch);
            this.groupBox1.Controls.Add(this.dgvValueView);
            this.groupBox1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.groupBox1.Location = new System.Drawing.Point(0, 0);
            this.groupBox1.Margin = new System.Windows.Forms.Padding(2);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Padding = new System.Windows.Forms.Padding(2);
            this.groupBox1.Size = new System.Drawing.Size(285, 259);
            this.groupBox1.TabIndex = 1;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "値変換設定";
            // 
            // rdoTypePartialmatch
            // 
            this.rdoTypePartialmatch.AutoSize = true;
            this.rdoTypePartialmatch.Location = new System.Drawing.Point(89, 22);
            this.rdoTypePartialmatch.Margin = new System.Windows.Forms.Padding(2);
            this.rdoTypePartialmatch.Name = "rdoTypePartialmatch";
            this.rdoTypePartialmatch.Size = new System.Drawing.Size(73, 19);
            this.rdoTypePartialmatch.TabIndex = 3;
            this.rdoTypePartialmatch.TabStop = true;
            this.rdoTypePartialmatch.Text = "部分一致";
            this.rdoTypePartialmatch.UseVisualStyleBackColor = true;
            this.rdoTypePartialmatch.Validating += new System.ComponentModel.CancelEventHandler(this.rdoType_Validating);
            // 
            // rdoTypeExactmatch
            // 
            this.rdoTypeExactmatch.AutoSize = true;
            this.rdoTypeExactmatch.Location = new System.Drawing.Point(12, 22);
            this.rdoTypeExactmatch.Margin = new System.Windows.Forms.Padding(2);
            this.rdoTypeExactmatch.Name = "rdoTypeExactmatch";
            this.rdoTypeExactmatch.Size = new System.Drawing.Size(73, 19);
            this.rdoTypeExactmatch.TabIndex = 2;
            this.rdoTypeExactmatch.TabStop = true;
            this.rdoTypeExactmatch.Text = "完全一致";
            this.rdoTypeExactmatch.UseVisualStyleBackColor = true;
            this.rdoTypeExactmatch.Validating += new System.ComponentModel.CancelEventHandler(this.rdoType_Validating);
            // 
            // dgvValueView
            // 
            this.dgvValueView.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.dgvValueView.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvValueView.Location = new System.Drawing.Point(8, 46);
            this.dgvValueView.Margin = new System.Windows.Forms.Padding(2);
            this.dgvValueView.Name = "dgvValueView";
            this.dgvValueView.RowHeadersWidth = 62;
            this.dgvValueView.RowTemplate.Height = 27;
            this.dgvValueView.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dgvValueView.Size = new System.Drawing.Size(272, 208);
            this.dgvValueView.TabIndex = 4;
            this.dgvValueView.CellContentClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.dgvValueView_CellContentClick);
            this.dgvValueView.CellEndEdit += new System.Windows.Forms.DataGridViewCellEventHandler(this.dgvValueView_CellEndEdit);
            this.dgvValueView.DefaultValuesNeeded += new System.Windows.Forms.DataGridViewRowEventHandler(this.dgvValueView_DefaultValuesNeeded);
            this.dgvValueView.RowsRemoved += new System.Windows.Forms.DataGridViewRowsRemovedEventHandler(this.dgvValueView_RowsRemoved);
            this.dgvValueView.Validating += new System.ComponentModel.CancelEventHandler(this.dgvValueView_Validating);
            // 
            // splitContainer1
            // 
            this.splitContainer1.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.splitContainer1.Location = new System.Drawing.Point(8, 10);
            this.splitContainer1.Name = "splitContainer1";
            // 
            // splitContainer1.Panel1
            // 
            this.splitContainer1.Panel1.Controls.Add(this.dgvNameView);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.groupBox1);
            this.splitContainer1.Size = new System.Drawing.Size(617, 259);
            this.splitContainer1.SplitterDistance = 328;
            this.splitContainer1.TabIndex = 6;
            // 
            // FormCommonConversion
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(634, 311);
            this.Controls.Add(this.splitContainer1);
            this.Controls.Add(this.btnClose);
            this.Font = new System.Drawing.Font("Meiryo UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.Margin = new System.Windows.Forms.Padding(2);
            this.MinimumSize = new System.Drawing.Size(400, 250);
            this.Name = "FormCommonConversion";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "共通値変換設定登録";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.FormCommonConversion_FormClosing);
            this.Load += new System.EventHandler(this.FormCommonConversion_Load);
            ((System.ComponentModel.ISupportInitialize)(this.dgvNameView)).EndInit();
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgvValueView)).EndInit();
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
            this.splitContainer1.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.DataGridView dgvNameView;
        private System.Windows.Forms.Button btnClose;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.RadioButton rdoTypePartialmatch;
        private System.Windows.Forms.RadioButton rdoTypeExactmatch;
        private System.Windows.Forms.DataGridView dgvValueView;
        private System.Windows.Forms.SplitContainer splitContainer1;
    }
}