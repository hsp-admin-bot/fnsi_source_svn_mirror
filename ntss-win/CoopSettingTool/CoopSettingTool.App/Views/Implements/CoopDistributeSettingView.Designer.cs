// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : fnw
// Created          : 04-14-2022
//
// Last Modified By : fnw
// Last Modified On : 06-08-2021
// ***********************************************************************
// <copyright file="CoopDistributeSettingView.Designer.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************


namespace CoopSettingTool.App.Views
{

    /// <summary>
    /// Class CoopDistributeSettingView.
    /// Implements the <see cref="CoopSettingTool.App.Views.BaseView" />
    /// Implements the <see cref="CoopSettingTool.App.Views.ICoopLayoutSettingView" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Views.BaseView" />
    /// <seealso cref="CoopSettingTool.App.Views.ICoopLayoutSettingView" />
    partial class CoopDistributeSettingView
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
            this.dgvCoopDistribute = new System.Windows.Forms.DataGridView();
            this.btnFnwMerge = new MaterialSkin.Controls.MaterialRaisedButton();
            ((System.ComponentModel.ISupportInitialize)(this.dgvCoopDistribute)).BeginInit();
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
            // dgvCoopDistribute
            // 
            this.dgvCoopDistribute.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.dgvCoopDistribute.ClipboardCopyMode = System.Windows.Forms.DataGridViewClipboardCopyMode.Disable;
            this.dgvCoopDistribute.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvCoopDistribute.Location = new System.Drawing.Point(12, 71);
            this.dgvCoopDistribute.Name = "dgvCoopDistribute";
            this.dgvCoopDistribute.RowTemplate.Height = 21;
            this.dgvCoopDistribute.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.CellSelect;
            this.dgvCoopDistribute.Size = new System.Drawing.Size(876, 488);
            this.dgvCoopDistribute.TabIndex = 0;
            // 
            // btnFnwMerge
            // 
            this.btnFnwMerge.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.btnFnwMerge.Depth = 0;
            this.btnFnwMerge.Location = new System.Drawing.Point(12, 565);
            this.btnFnwMerge.MouseState = MaterialSkin.MouseState.HOVER;
            this.btnFnwMerge.Name = "btnFnwMerge";
            this.btnFnwMerge.Primary = true;
            this.btnFnwMerge.Size = new System.Drawing.Size(125, 23);
            this.btnFnwMerge.TabIndex = 38;
            this.btnFnwMerge.Text = "インポート";
            this.btnFnwMerge.UseVisualStyleBackColor = true;
            // 
            // CoopDistributeSettingView
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(900, 600);
            this.Controls.Add(this.btnFnwMerge);
            this.Controls.Add(this.lbFacName);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.btnSave);
            this.Controls.Add(this.dgvCoopDistribute);
            this.Name = "CoopDistributeSettingView";
            this.Sizable = true;
            this.Text = "連携配信設定";
            ((System.ComponentModel.ISupportInitialize)(this.dgvCoopDistribute)).EndInit();
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
        /// The lb fac name
        /// </summary>
        private System.Windows.Forms.Label lbFacName;
        /// <summary>
        /// The DGV coop layout
        /// </summary>
        private System.Windows.Forms.DataGridView dgvCoopDistribute;
        private MaterialSkin.Controls.MaterialRaisedButton btnFnwMerge;
    }
}