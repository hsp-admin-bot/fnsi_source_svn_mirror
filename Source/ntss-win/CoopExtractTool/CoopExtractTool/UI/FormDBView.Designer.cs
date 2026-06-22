
namespace CoopExtractTool
{
    partial class FormDBView
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FormDBView));
            this.btnBeginning = new System.Windows.Forms.Button();
            this.btnNext = new System.Windows.Forms.Button();
            this.grpFacility = new System.Windows.Forms.GroupBox();
            this.cmbFacility = new System.Windows.Forms.ComboBox();
            this.dgvDBView = new System.Windows.Forms.DataGridView();
            this.grpDBView = new System.Windows.Forms.GroupBox();
            this.grpMapping = new System.Windows.Forms.GroupBox();
            this.cmbMapping = new System.Windows.Forms.ComboBox();
            this.label1 = new System.Windows.Forms.Label();
            this.grpFacility.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgvDBView)).BeginInit();
            this.grpDBView.SuspendLayout();
            this.grpMapping.SuspendLayout();
            this.SuspendLayout();
            // 
            // btnBeginning
            // 
            this.btnBeginning.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnBeginning.Location = new System.Drawing.Point(460, 313);
            this.btnBeginning.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.btnBeginning.Name = "btnBeginning";
            this.btnBeginning.Size = new System.Drawing.Size(90, 25);
            this.btnBeginning.TabIndex = 5;
            this.btnBeginning.Text = "最初から";
            this.btnBeginning.UseVisualStyleBackColor = true;
            this.btnBeginning.Click += new System.EventHandler(this.btnBeginning_Click);
            // 
            // btnNext
            // 
            this.btnNext.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnNext.Location = new System.Drawing.Point(281, 313);
            this.btnNext.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.btnNext.Name = "btnNext";
            this.btnNext.Size = new System.Drawing.Size(175, 25);
            this.btnNext.TabIndex = 4;
            this.btnNext.Text = "FNSi連携設定項目への変換";
            this.btnNext.UseVisualStyleBackColor = true;
            this.btnNext.Click += new System.EventHandler(this.btnNext_Click);
            // 
            // grpFacility
            // 
            this.grpFacility.Controls.Add(this.cmbFacility);
            this.grpFacility.Location = new System.Drawing.Point(7, 8);
            this.grpFacility.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.grpFacility.Name = "grpFacility";
            this.grpFacility.Padding = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.grpFacility.Size = new System.Drawing.Size(154, 47);
            this.grpFacility.TabIndex = 0;
            this.grpFacility.TabStop = false;
            this.grpFacility.Text = "FNW対象施設";
            // 
            // cmbFacility
            // 
            this.cmbFacility.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.cmbFacility.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cmbFacility.FormattingEnabled = true;
            this.cmbFacility.Location = new System.Drawing.Point(12, 19);
            this.cmbFacility.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.cmbFacility.Name = "cmbFacility";
            this.cmbFacility.Size = new System.Drawing.Size(134, 20);
            this.cmbFacility.TabIndex = 0;
            // 
            // dgvDBView
            // 
            this.dgvDBView.AllowUserToAddRows = false;
            this.dgvDBView.AllowUserToResizeRows = false;
            this.dgvDBView.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.dgvDBView.ClipboardCopyMode = System.Windows.Forms.DataGridViewClipboardCopyMode.Disable;
            this.dgvDBView.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvDBView.Location = new System.Drawing.Point(9, 17);
            this.dgvDBView.Margin = new System.Windows.Forms.Padding(0);
            this.dgvDBView.Name = "dgvDBView";
            this.dgvDBView.ReadOnly = true;
            this.dgvDBView.RowHeadersWidth = 62;
            this.dgvDBView.RowTemplate.Height = 21;
            this.dgvDBView.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dgvDBView.Size = new System.Drawing.Size(524, 223);
            this.dgvDBView.TabIndex = 0;
            // 
            // grpDBView
            // 
            this.grpDBView.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.grpDBView.Controls.Add(this.dgvDBView);
            this.grpDBView.Location = new System.Drawing.Point(7, 59);
            this.grpDBView.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.grpDBView.Name = "grpDBView";
            this.grpDBView.Padding = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.grpDBView.Size = new System.Drawing.Size(542, 250);
            this.grpDBView.TabIndex = 3;
            this.grpDBView.TabStop = false;
            this.grpDBView.Text = "FNW連携設定項目一覧";
            // 
            // grpMapping
            // 
            this.grpMapping.Controls.Add(this.cmbMapping);
            this.grpMapping.Location = new System.Drawing.Point(229, 8);
            this.grpMapping.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.grpMapping.Name = "grpMapping";
            this.grpMapping.Padding = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.grpMapping.Size = new System.Drawing.Size(154, 47);
            this.grpMapping.TabIndex = 2;
            this.grpMapping.TabStop = false;
            this.grpMapping.Text = "FNSiカルテ種別";
            // 
            // cmbMapping
            // 
            this.cmbMapping.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.cmbMapping.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cmbMapping.FormattingEnabled = true;
            this.cmbMapping.Location = new System.Drawing.Point(12, 19);
            this.cmbMapping.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.cmbMapping.Name = "cmbMapping";
            this.cmbMapping.Size = new System.Drawing.Size(134, 20);
            this.cmbMapping.TabIndex = 0;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("MS UI Gothic", 36F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.label1.Location = new System.Drawing.Point(164, 9);
            this.label1.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(68, 48);
            this.label1.TabIndex = 1;
            this.label1.Text = "→";
            // 
            // FormDBView
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(557, 346);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.grpMapping);
            this.Controls.Add(this.grpDBView);
            this.Controls.Add(this.grpFacility);
            this.Controls.Add(this.btnNext);
            this.Controls.Add(this.btnBeginning);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.MinimumSize = new System.Drawing.Size(459, 313);
            this.Name = "FormDBView";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "FormDBView";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.FormDBView_FormClosing);
            this.Load += new System.EventHandler(this.FormDBView_Load);
            this.grpFacility.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.dgvDBView)).EndInit();
            this.grpDBView.ResumeLayout(false);
            this.grpMapping.ResumeLayout(false);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button btnBeginning;
        private System.Windows.Forms.Button btnNext;
        private System.Windows.Forms.GroupBox grpFacility;
        private System.Windows.Forms.ComboBox cmbFacility;
        private System.Windows.Forms.DataGridView dgvDBView;
        private System.Windows.Forms.GroupBox grpDBView;
        private System.Windows.Forms.GroupBox grpMapping;
        private System.Windows.Forms.ComboBox cmbMapping;
        private System.Windows.Forms.Label label1;
    }
}