namespace LayoutDesigner
{
    partial class frmEditRepeat
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
            this.btnListInit = new System.Windows.Forms.Button();
            this.lstCell = new System.Windows.Forms.ListBox();
            this.btnOK = new System.Windows.Forms.Button();
            this.btnCancel = new System.Windows.Forms.Button();
            this.btnSelectedAdd = new System.Windows.Forms.Button();
            this.radDirectionN = new System.Windows.Forms.RadioButton();
            this.radDirectionZ = new System.Windows.Forms.RadioButton();
            this.btnAddOK = new System.Windows.Forms.Button();
            this.chkReverse = new System.Windows.Forms.CheckBox();
            this.lblDataPathAddr = new System.Windows.Forms.Label();
            this.SuspendLayout();
            // 
            // btnStop
            // 
            this.btnStop.Location = new System.Drawing.Point(146, 510);
            this.btnStop.TabIndex = 13;
            // 
            // btnTop
            // 
            this.btnTop.Location = new System.Drawing.Point(5, 7);
            // 
            // btnFocusControl
            // 
            this.btnFocusControl.Location = new System.Drawing.Point(148, 7);
            // 
            // winlblTitle
            // 
            this.winlblTitle.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(66)))), ((int)(((byte)(66)))), ((int)(((byte)(66)))));
            this.winlblTitle.Font = new System.Drawing.Font("Yu Gothic UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.winlblTitle.Size = new System.Drawing.Size(226, 18);
            this.winlblTitle.Text = "繰り返し設定";
            // 
            // btnListInit
            // 
            this.btnListInit.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnListInit.FlatAppearance.BorderSize = 2;
            this.btnListInit.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnListInit.Location = new System.Drawing.Point(6, 50);
            this.btnListInit.Name = "btnListInit";
            this.btnListInit.Size = new System.Drawing.Size(87, 29);
            this.btnListInit.TabIndex = 4;
            this.btnListInit.Text = "初期化";
            // 
            // lstCell
            // 
            this.lstCell.AllowDrop = true;
            this.lstCell.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lstCell.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(60)))), ((int)(((byte)(60)))), ((int)(((byte)(60)))));
            this.lstCell.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.lstCell.Font = new System.Drawing.Font("Yu Gothic UI", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.lstCell.ForeColor = System.Drawing.Color.White;
            this.lstCell.FormattingEnabled = true;
            this.lstCell.ItemHeight = 17;
            this.lstCell.Location = new System.Drawing.Point(5, 136);
            this.lstCell.Name = "lstCell";
            this.lstCell.Size = new System.Drawing.Size(220, 308);
            this.lstCell.TabIndex = 9;
            // 
            // btnOK
            // 
            this.btnOK.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnOK.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnOK.FlatAppearance.BorderSize = 2;
            this.btnOK.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnOK.Location = new System.Drawing.Point(136, 486);
            this.btnOK.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.btnOK.Name = "btnOK";
            this.btnOK.Size = new System.Drawing.Size(87, 29);
            this.btnOK.TabIndex = 12;
            this.btnOK.Text = "OK";
            // 
            // btnCancel
            // 
            this.btnCancel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.btnCancel.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnCancel.FlatAppearance.BorderSize = 2;
            this.btnCancel.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnCancel.Location = new System.Drawing.Point(43, 486);
            this.btnCancel.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(87, 29);
            this.btnCancel.TabIndex = 11;
            this.btnCancel.Text = "キャンセル";
            // 
            // btnSelectedAdd
            // 
            this.btnSelectedAdd.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnSelectedAdd.FlatAppearance.BorderSize = 2;
            this.btnSelectedAdd.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnSelectedAdd.Location = new System.Drawing.Point(99, 50);
            this.btnSelectedAdd.Name = "btnSelectedAdd";
            this.btnSelectedAdd.Size = new System.Drawing.Size(124, 29);
            this.btnSelectedAdd.TabIndex = 5;
            this.btnSelectedAdd.Text = "選択中セルを追加";
            // 
            // radDirectionN
            // 
            this.radDirectionN.AutoSize = true;
            this.radDirectionN.Checked = true;
            this.radDirectionN.Location = new System.Drawing.Point(13, 86);
            this.radDirectionN.Name = "radDirectionN";
            this.radDirectionN.Size = new System.Drawing.Size(46, 19);
            this.radDirectionN.TabIndex = 6;
            this.radDirectionN.TabStop = true;
            this.radDirectionN.Text = "N型";
            // 
            // radDirectionZ
            // 
            this.radDirectionZ.AutoSize = true;
            this.radDirectionZ.Location = new System.Drawing.Point(99, 86);
            this.radDirectionZ.Name = "radDirectionZ";
            this.radDirectionZ.Size = new System.Drawing.Size(44, 19);
            this.radDirectionZ.TabIndex = 7;
            this.radDirectionZ.Text = "Z型";
            // 
            // btnAddOK
            // 
            this.btnAddOK.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnAddOK.FlatAppearance.BorderColor = System.Drawing.Color.DarkGray;
            this.btnAddOK.FlatAppearance.BorderSize = 2;
            this.btnAddOK.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnAddOK.Location = new System.Drawing.Point(43, 449);
            this.btnAddOK.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.btnAddOK.Name = "btnAddOK";
            this.btnAddOK.Size = new System.Drawing.Size(180, 29);
            this.btnAddOK.TabIndex = 10;
            this.btnAddOK.Text = "選択中セルを追加してOK";
            // 
            // chkReverse
            // 
            this.chkReverse.AutoSize = true;
            this.chkReverse.Location = new System.Drawing.Point(13, 110);
            this.chkReverse.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.chkReverse.Name = "chkReverse";
            this.chkReverse.Size = new System.Drawing.Size(110, 19);
            this.chkReverse.TabIndex = 8;
            this.chkReverse.Text = "セル順を逆転する";
            this.chkReverse.UseVisualStyleBackColor = true;
            // 
            // lblDataPathAddr
            // 
            this.lblDataPathAddr.AutoSize = true;
            this.lblDataPathAddr.Location = new System.Drawing.Point(10, 25);
            this.lblDataPathAddr.Name = "lblDataPathAddr";
            this.lblDataPathAddr.Size = new System.Drawing.Size(10, 15);
            this.lblDataPathAddr.TabIndex = 3;
            this.lblDataPathAddr.Text = " ";
            // 
            // frmEditRepeat
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.CancelButton = this.btnCancel;
            this.ClientSize = new System.Drawing.Size(230, 530);
            this.Controls.Add(this.lblDataPathAddr);
            this.Controls.Add(this.chkReverse);
            this.Controls.Add(this.btnAddOK);
            this.Controls.Add(this.radDirectionZ);
            this.Controls.Add(this.radDirectionN);
            this.Controls.Add(this.btnSelectedAdd);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.btnOK);
            this.Controls.Add(this.lstCell);
            this.Controls.Add(this.btnListInit);
            this.Margin = new System.Windows.Forms.Padding(3, 5, 3, 5);
            this.MinimumSize = new System.Drawing.Size(230, 530);
            this.Name = "frmEditRepeat";
            this.Controls.SetChildIndex(this.btnListInit, 0);
            this.Controls.SetChildIndex(this.lstCell, 0);
            this.Controls.SetChildIndex(this.btnOK, 0);
            this.Controls.SetChildIndex(this.btnCancel, 0);
            this.Controls.SetChildIndex(this.btnSelectedAdd, 0);
            this.Controls.SetChildIndex(this.radDirectionN, 0);
            this.Controls.SetChildIndex(this.radDirectionZ, 0);
            this.Controls.SetChildIndex(this.btnAddOK, 0);
            this.Controls.SetChildIndex(this.chkReverse, 0);
            this.Controls.SetChildIndex(this.winlblTitle, 0);
            this.Controls.SetChildIndex(this.btnFocusControl, 0);
            this.Controls.SetChildIndex(this.btnTop, 0);
            this.Controls.SetChildIndex(this.btnStop, 0);
            this.Controls.SetChildIndex(this.lblDataPathAddr, 0);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button btnListInit;
        private System.Windows.Forms.ListBox lstCell;
        private System.Windows.Forms.Button btnOK;
        private System.Windows.Forms.Button btnCancel;
        private System.Windows.Forms.Button btnSelectedAdd;
        private System.Windows.Forms.RadioButton radDirectionN;
        private System.Windows.Forms.RadioButton radDirectionZ;
        private System.Windows.Forms.Button btnAddOK;
        private System.Windows.Forms.CheckBox chkReverse;
        private System.Windows.Forms.Label lblDataPathAddr;
    }
}