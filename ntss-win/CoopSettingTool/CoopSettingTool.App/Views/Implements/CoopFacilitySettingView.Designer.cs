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
    partial class CoopFacilitySettingView
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
            this.btnCancel = new MaterialSkin.Controls.MaterialRaisedButton();
            this.btnSave = new MaterialSkin.Controls.MaterialRaisedButton();
            this.lbFacName = new System.Windows.Forms.Label();
            this.dgvCoopFacility = new System.Windows.Forms.DataGridView();
            this.btnImport = new MaterialSkin.Controls.MaterialRaisedButton();
            ((System.ComponentModel.ISupportInitialize)(this.dgvCoopFacility)).BeginInit();
            this.SuspendLayout();
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
            // dgvCoopFacility
            // 
            this.dgvCoopFacility.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.dgvCoopFacility.ClipboardCopyMode = System.Windows.Forms.DataGridViewClipboardCopyMode.Disable;
            this.dgvCoopFacility.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvCoopFacility.Location = new System.Drawing.Point(12, 71);
            this.dgvCoopFacility.Name = "dgvCoopFacility";
            this.dgvCoopFacility.RowTemplate.Height = 21;
            this.dgvCoopFacility.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.CellSelect;
            this.dgvCoopFacility.Size = new System.Drawing.Size(876, 488);
            this.dgvCoopFacility.TabIndex = 0;
            // 
            // btnImport
            // 
            this.btnImport.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.btnImport.Depth = 0;
            this.btnImport.Location = new System.Drawing.Point(12, 565);
            this.btnImport.MouseState = MaterialSkin.MouseState.HOVER;
            this.btnImport.Name = "btnImport";
            this.btnImport.Primary = true;
            this.btnImport.Size = new System.Drawing.Size(90, 23);
            this.btnImport.TabIndex = 38;
            this.btnImport.Text = "インポート";
            this.btnImport.UseVisualStyleBackColor = true;
            // 
            // CoopFacilitySettingView
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(900, 600);
            this.Controls.Add(this.btnImport);
            this.Controls.Add(this.lbFacName);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.btnSave);
            this.Controls.Add(this.dgvCoopFacility);
            this.Name = "CoopFacilitySettingView";
            this.Sizable = true;
            this.Text = "連携施設設定";
            ((System.ComponentModel.ISupportInitialize)(this.dgvCoopFacility)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion
        /// <summary>
        /// The BTN cancel
        /// </summary>
        private MaterialSkin.Controls.MaterialRaisedButton btnCancel;
        /// <summary>
        /// The BTN save
        /// </summary>
        private MaterialSkin.Controls.MaterialRaisedButton btnSave;
        private System.Windows.Forms.Label lbFacName;
        private System.Windows.Forms.DataGridView dgvCoopFacility;
        private MaterialSkin.Controls.MaterialRaisedButton btnImport;
    }
}