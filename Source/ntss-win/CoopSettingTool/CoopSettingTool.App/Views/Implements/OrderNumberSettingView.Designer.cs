// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 05-24-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-25-2021
// ***********************************************************************
// <copyright file="OrderNumberSettingView.Designer.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************

namespace CoopSettingTool.App.Views
{
    /// <summary>
    /// Class OrderNumberSettingView.
    /// Implements the <see cref="CoopSettingTool.App.Views.BaseView" />
    /// Implements the <see cref="CoopSettingTool.App.Views.IOrderNumberSettingView" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Views.BaseView" />
    /// <seealso cref="CoopSettingTool.App.Views.IOrderNumberSettingView" />
    partial class OrderNumberSettingView
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
            this.dgvOrderSetting = new System.Windows.Forms.DataGridView();
            this.btnCancel = new MaterialSkin.Controls.MaterialRaisedButton();
            this.btnSave = new MaterialSkin.Controls.MaterialRaisedButton();
            this.btnImport = new MaterialSkin.Controls.MaterialRaisedButton();
            this.btnAdd = new MaterialSkin.Controls.MaterialRaisedButton();
            this.lbFacName = new System.Windows.Forms.Label();
            ((System.ComponentModel.ISupportInitialize)(this.dgvOrderSetting)).BeginInit();
            this.SuspendLayout();
            // 
            // dgvOrderSetting
            // 
            this.dgvOrderSetting.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.dgvOrderSetting.ClipboardCopyMode = System.Windows.Forms.DataGridViewClipboardCopyMode.Disable;
            this.dgvOrderSetting.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvOrderSetting.Location = new System.Drawing.Point(12, 71);
            this.dgvOrderSetting.Name = "dgvOrderSetting";
            this.dgvOrderSetting.RowTemplate.Height = 21;
            this.dgvOrderSetting.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dgvOrderSetting.Size = new System.Drawing.Size(876, 488);
            this.dgvOrderSetting.TabIndex = 0;
            // 
            // btnCancel
            // 
            this.btnCancel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnCancel.Depth = 0;
            this.btnCancel.Location = new System.Drawing.Point(798, 565);
            this.btnCancel.MouseState = MaterialSkin.MouseState.HOVER;
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Primary = true;
            this.btnCancel.Size = new System.Drawing.Size(90, 23);
            this.btnCancel.TabIndex = 25;
            this.btnCancel.Text = "キャンセル";
            this.btnCancel.UseVisualStyleBackColor = true;
            // 
            // btnSave
            // 
            this.btnSave.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnSave.Depth = 0;
            this.btnSave.Enabled = false;
            this.btnSave.Location = new System.Drawing.Point(702, 565);
            this.btnSave.MouseState = MaterialSkin.MouseState.HOVER;
            this.btnSave.Name = "btnSave";
            this.btnSave.Primary = true;
            this.btnSave.Size = new System.Drawing.Size(90, 23);
            this.btnSave.TabIndex = 24;
            this.btnSave.Text = "保存";
            this.btnSave.UseVisualStyleBackColor = true;
            // 
            // btnImport
            // 
            this.btnImport.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.btnImport.Depth = 0;
            this.btnImport.Location = new System.Drawing.Point(41, 565);
            this.btnImport.MouseState = MaterialSkin.MouseState.HOVER;
            this.btnImport.Name = "btnImport";
            this.btnImport.Primary = true;
            this.btnImport.Size = new System.Drawing.Size(91, 23);
            this.btnImport.TabIndex = 34;
            this.btnImport.Text = "インポート";
            this.btnImport.UseVisualStyleBackColor = true;
            // 
            // btnAdd
            // 
            this.btnAdd.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.btnAdd.Depth = 0;
            this.btnAdd.Location = new System.Drawing.Point(12, 565);
            this.btnAdd.MouseState = MaterialSkin.MouseState.HOVER;
            this.btnAdd.Name = "btnAdd";
            this.btnAdd.Primary = true;
            this.btnAdd.Size = new System.Drawing.Size(23, 23);
            this.btnAdd.TabIndex = 35;
            this.btnAdd.Text = "+";
            this.btnAdd.UseVisualStyleBackColor = true;
            // 
            // lbFacName
            // 
            this.lbFacName.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lbFacName.AutoSize = true;
            this.lbFacName.BackColor = System.Drawing.Color.DarkSlateGray;
            this.lbFacName.Font = new System.Drawing.Font("MS UI Gothic", 12F);
            this.lbFacName.ForeColor = System.Drawing.Color.White;
            this.lbFacName.Location = new System.Drawing.Point(603, 30);
            this.lbFacName.MaximumSize = new System.Drawing.Size(285, 28);
            this.lbFacName.MinimumSize = new System.Drawing.Size(285, 28);
            this.lbFacName.Name = "lbFacName";
            this.lbFacName.Size = new System.Drawing.Size(285, 28);
            this.lbFacName.TabIndex = 37;
            this.lbFacName.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // OrderNumberSettingView
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(900, 600);
            this.Controls.Add(this.lbFacName);
            this.Controls.Add(this.btnAdd);
            this.Controls.Add(this.btnImport);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.btnSave);
            this.Controls.Add(this.dgvOrderSetting);
            this.Name = "OrderNumberSettingView";
            this.Sizable = true;
            this.Text = "オーダ番号設定";
            ((System.ComponentModel.ISupportInitialize)(this.dgvOrderSetting)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        /// <summary>
        /// The DGV order setting
        /// </summary>
        private System.Windows.Forms.DataGridView dgvOrderSetting;
        /// <summary>
        /// The BTN cancel
        /// </summary>
        private MaterialSkin.Controls.MaterialRaisedButton btnCancel;
        /// <summary>
        /// The BTN save
        /// </summary>
        private MaterialSkin.Controls.MaterialRaisedButton btnSave;
        private MaterialSkin.Controls.MaterialRaisedButton btnImport;
        private MaterialSkin.Controls.MaterialRaisedButton btnAdd;
        private System.Windows.Forms.Label lbFacName;
    }
}