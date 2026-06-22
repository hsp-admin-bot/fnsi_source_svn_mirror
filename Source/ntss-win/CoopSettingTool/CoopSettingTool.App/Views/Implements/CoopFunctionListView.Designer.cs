// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-23-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-10-2021
// ***********************************************************************
// <copyright file="CoopFunctionListView.Designer.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************

namespace CoopSettingTool.App.Views
{
    /// <summary>
    /// Class CoopFunctionListView.
    /// Implements the <see cref="CoopSettingTool.App.Views.BaseView" />
    /// Implements the <see cref="CoopSettingTool.App.Views.ICoopFunctionListView" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Views.BaseView" />
    /// <seealso cref="CoopSettingTool.App.Views.ICoopFunctionListView" />
    partial class CoopFunctionListView
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
            this.dgvCoopFunction = new System.Windows.Forms.DataGridView();
            this.btnFinish = new MaterialSkin.Controls.MaterialRaisedButton();
            this.btnEdit = new MaterialSkin.Controls.MaterialRaisedButton();
            this.lbFacName = new System.Windows.Forms.Label();
            ((System.ComponentModel.ISupportInitialize)(this.dgvCoopFunction)).BeginInit();
            this.SuspendLayout();
            // 
            // dgvCoopFunction
            // 
            this.dgvCoopFunction.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.dgvCoopFunction.ClipboardCopyMode = System.Windows.Forms.DataGridViewClipboardCopyMode.Disable;
            this.dgvCoopFunction.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvCoopFunction.EditMode = System.Windows.Forms.DataGridViewEditMode.EditProgrammatically;
            this.dgvCoopFunction.Location = new System.Drawing.Point(12, 76);
            this.dgvCoopFunction.MultiSelect = false;
            this.dgvCoopFunction.Name = "dgvCoopFunction";
            this.dgvCoopFunction.RowTemplate.Height = 21;
            this.dgvCoopFunction.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dgvCoopFunction.Size = new System.Drawing.Size(876, 483);
            this.dgvCoopFunction.TabIndex = 0;
            // 
            // btnFinish
            // 
            this.btnFinish.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnFinish.Depth = 0;
            this.btnFinish.Location = new System.Drawing.Point(798, 565);
            this.btnFinish.MouseState = MaterialSkin.MouseState.HOVER;
            this.btnFinish.Name = "btnFinish";
            this.btnFinish.Primary = true;
            this.btnFinish.Size = new System.Drawing.Size(90, 23);
            this.btnFinish.TabIndex = 23;
            this.btnFinish.Text = "キャンセル";
            this.btnFinish.UseVisualStyleBackColor = true;
            // 
            // btnEdit
            // 
            this.btnEdit.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnEdit.Depth = 0;
            this.btnEdit.Enabled = false;
            this.btnEdit.Location = new System.Drawing.Point(702, 565);
            this.btnEdit.MouseState = MaterialSkin.MouseState.HOVER;
            this.btnEdit.Name = "btnEdit";
            this.btnEdit.Primary = true;
            this.btnEdit.Size = new System.Drawing.Size(90, 23);
            this.btnEdit.TabIndex = 22;
            this.btnEdit.Text = "変更";
            this.btnEdit.UseVisualStyleBackColor = true;
            // 
            // lbFacName
            // 
            this.lbFacName.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.lbFacName.AutoSize = true;
            this.lbFacName.BackColor = System.Drawing.Color.DarkSlateGray;
            this.lbFacName.Font = new System.Drawing.Font("MS UI Gothic", 12F);
            this.lbFacName.ForeColor = System.Drawing.Color.White;
            this.lbFacName.Location = new System.Drawing.Point(603, 29);
            this.lbFacName.MaximumSize = new System.Drawing.Size(285, 28);
            this.lbFacName.MinimumSize = new System.Drawing.Size(285, 28);
            this.lbFacName.Name = "lbFacName";
            this.lbFacName.Size = new System.Drawing.Size(285, 28);
            this.lbFacName.TabIndex = 24;
            this.lbFacName.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // CoopFunctionListView
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(900, 600);
            this.Controls.Add(this.lbFacName);
            this.Controls.Add(this.btnFinish);
            this.Controls.Add(this.btnEdit);
            this.Controls.Add(this.dgvCoopFunction);
            this.Name = "CoopFunctionListView";
            this.Sizable = true;
            this.Text = "連携機能一覧";
            ((System.ComponentModel.ISupportInitialize)(this.dgvCoopFunction)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        /// <summary>
        /// The DGV coop function
        /// </summary>
        private System.Windows.Forms.DataGridView dgvCoopFunction;
        /// <summary>
        /// The BTN ok
        /// </summary>
        private MaterialSkin.Controls.MaterialRaisedButton btnFinish;
        /// <summary>
        /// The BTN edit
        /// </summary>
        private MaterialSkin.Controls.MaterialRaisedButton btnEdit;
        private System.Windows.Forms.Label lbFacName;
    }
}