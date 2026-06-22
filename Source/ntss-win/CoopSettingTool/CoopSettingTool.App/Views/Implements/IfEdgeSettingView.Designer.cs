// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 05-25-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-25-2021
// ***********************************************************************
// <copyright file="IfEdgeSettingView.Designer.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************

namespace CoopSettingTool.App.Views
{
    /// <summary>
    /// Class IfEdgeSettingView.
    /// Implements the <see cref="CoopSettingTool.App.Views.BaseView" />
    /// Implements the <see cref="CoopSettingTool.App.Views.IIfEdgeSettingView" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Views.BaseView" />
    /// <seealso cref="CoopSettingTool.App.Views.IIfEdgeSettingView" />
    partial class IfEdgeSettingView
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
            this.dgvIfEdgeSetting = new System.Windows.Forms.DataGridView();
            this.btnAdd = new MaterialSkin.Controls.MaterialRaisedButton();
            this.btnRemove = new MaterialSkin.Controls.MaterialRaisedButton();
            this.lbFacName = new System.Windows.Forms.Label();
            ((System.ComponentModel.ISupportInitialize)(this.dgvIfEdgeSetting)).BeginInit();
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
            this.btnCancel.TabIndex = 28;
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
            this.btnSave.TabIndex = 27;
            this.btnSave.Text = "保存";
            this.btnSave.UseVisualStyleBackColor = true;
            // 
            // dgvIfEdgeSetting
            // 
            this.dgvIfEdgeSetting.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.dgvIfEdgeSetting.ClipboardCopyMode = System.Windows.Forms.DataGridViewClipboardCopyMode.Disable;
            this.dgvIfEdgeSetting.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvIfEdgeSetting.Location = new System.Drawing.Point(12, 72);
            this.dgvIfEdgeSetting.Name = "dgvIfEdgeSetting";
            this.dgvIfEdgeSetting.RowTemplate.Height = 21;
            this.dgvIfEdgeSetting.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dgvIfEdgeSetting.Size = new System.Drawing.Size(876, 487);
            this.dgvIfEdgeSetting.TabIndex = 26;
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
            this.btnAdd.TabIndex = 37;
            this.btnAdd.Text = "+";
            this.btnAdd.UseVisualStyleBackColor = true;
            // 
            // btnRemove
            // 
            this.btnRemove.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.btnRemove.Depth = 0;
            this.btnRemove.Location = new System.Drawing.Point(41, 565);
            this.btnRemove.MouseState = MaterialSkin.MouseState.HOVER;
            this.btnRemove.Name = "btnRemove";
            this.btnRemove.Primary = true;
            this.btnRemove.Size = new System.Drawing.Size(23, 23);
            this.btnRemove.TabIndex = 36;
            this.btnRemove.Text = "-";
            this.btnRemove.UseVisualStyleBackColor = true;
            this.btnRemove.Visible = false;
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
            this.lbFacName.TabIndex = 38;
            this.lbFacName.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // IfEdgeSettingView
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(900, 600);
            this.Controls.Add(this.lbFacName);
            this.Controls.Add(this.btnAdd);
            this.Controls.Add(this.btnRemove);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.btnSave);
            this.Controls.Add(this.dgvIfEdgeSetting);
            this.Name = "IfEdgeSettingView";
            this.Sizable = true;
            this.Text = "IFエッジ設定";
            ((System.ComponentModel.ISupportInitialize)(this.dgvIfEdgeSetting)).EndInit();
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
        /// <summary>
        /// The DGV if edge setting
        /// </summary>
        private System.Windows.Forms.DataGridView dgvIfEdgeSetting;
        private MaterialSkin.Controls.MaterialRaisedButton btnAdd;
        private MaterialSkin.Controls.MaterialRaisedButton btnRemove;
        private System.Windows.Forms.Label lbFacName;
    }
}