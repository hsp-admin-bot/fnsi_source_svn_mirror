// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-26-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-18-2021
// ***********************************************************************
// <copyright file="CoopFunctionSettingView.Designer.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************

namespace CoopSettingTool.App.Views
{
    /// <summary>
    /// Class CoopFunctionSettingView.
    /// Implements the <see cref="CoopSettingTool.App.Views.BaseView" />
    /// Implements the <see cref="CoopSettingTool.App.Views.ICoopFunctionSettingView" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Views.BaseView" />
    /// <seealso cref="CoopSettingTool.App.Views.ICoopFunctionSettingView" />
    partial class CoopFunctionSettingView
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
            this.cbIsUse = new System.Windows.Forms.CheckBox();
            this.label1 = new System.Windows.Forms.Label();
            this.btnSave = new MaterialSkin.Controls.MaterialRaisedButton();
            this.btnCancel = new MaterialSkin.Controls.MaterialRaisedButton();
            this.dgvSendProtocol = new System.Windows.Forms.DataGridView();
            this.cbbProtocol = new System.Windows.Forms.ComboBox();
            this.lbFacName = new System.Windows.Forms.Label();
            ((System.ComponentModel.ISupportInitialize)(this.dgvSendProtocol)).BeginInit();
            this.SuspendLayout();
            // 
            // cbIsUse
            // 
            this.cbIsUse.Appearance = System.Windows.Forms.Appearance.Button;
            this.cbIsUse.BackColor = System.Drawing.Color.Gray;
            this.cbIsUse.FlatAppearance.BorderColor = System.Drawing.Color.White;
            this.cbIsUse.FlatAppearance.BorderSize = 0;
            this.cbIsUse.FlatAppearance.CheckedBackColor = System.Drawing.Color.Transparent;
            this.cbIsUse.FlatAppearance.MouseDownBackColor = System.Drawing.Color.Transparent;
            this.cbIsUse.FlatAppearance.MouseOverBackColor = System.Drawing.Color.Transparent;
            this.cbIsUse.Location = new System.Drawing.Point(87, 72);
            this.cbIsUse.Margin = new System.Windows.Forms.Padding(0);
            this.cbIsUse.MaximumSize = new System.Drawing.Size(50, 50);
            this.cbIsUse.MinimumSize = new System.Drawing.Size(50, 30);
            this.cbIsUse.Name = "cbIsUse";
            this.cbIsUse.Size = new System.Drawing.Size(50, 30);
            this.cbIsUse.TabIndex = 1;
            this.cbIsUse.UseVisualStyleBackColor = false;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("MS UI Gothic", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.label1.Location = new System.Drawing.Point(12, 77);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(72, 16);
            this.label1.TabIndex = 2;
            this.label1.Text = "有無状態";
            // 
            // btnSave
            // 
            this.btnSave.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnSave.BackColor = System.Drawing.Color.White;
            this.btnSave.Depth = 0;
            this.btnSave.Enabled = false;
            this.btnSave.Location = new System.Drawing.Point(702, 565);
            this.btnSave.MouseState = MaterialSkin.MouseState.HOVER;
            this.btnSave.Name = "btnSave";
            this.btnSave.Primary = true;
            this.btnSave.Size = new System.Drawing.Size(90, 23);
            this.btnSave.TabIndex = 23;
            this.btnSave.Text = "保存";
            this.btnSave.UseVisualStyleBackColor = false;
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
            this.btnCancel.TabIndex = 24;
            this.btnCancel.Text = "キャンセル";
            this.btnCancel.UseVisualStyleBackColor = true;
            // 
            // dgvSendProtocol
            // 
            this.dgvSendProtocol.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.dgvSendProtocol.ClipboardCopyMode = System.Windows.Forms.DataGridViewClipboardCopyMode.Disable;
            this.dgvSendProtocol.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvSendProtocol.Location = new System.Drawing.Point(12, 131);
            this.dgvSendProtocol.Name = "dgvSendProtocol";
            this.dgvSendProtocol.RowTemplate.Height = 21;
            this.dgvSendProtocol.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dgvSendProtocol.Size = new System.Drawing.Size(876, 428);
            this.dgvSendProtocol.TabIndex = 32;
            // 
            // cbbProtocol
            // 
            this.cbbProtocol.FormattingEnabled = true;
            this.cbbProtocol.Location = new System.Drawing.Point(12, 105);
            this.cbbProtocol.Name = "cbbProtocol";
            this.cbbProtocol.Size = new System.Drawing.Size(202, 20);
            this.cbbProtocol.TabIndex = 33;
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
            this.lbFacName.TabIndex = 34;
            this.lbFacName.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // CoopFunctionSettingView
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(900, 600);
            this.Controls.Add(this.lbFacName);
            this.Controls.Add(this.cbbProtocol);
            this.Controls.Add(this.dgvSendProtocol);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.btnSave);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.cbIsUse);
            this.Cursor = System.Windows.Forms.Cursors.Default;
            this.MinimumSize = new System.Drawing.Size(50, 50);
            this.Name = "CoopFunctionSettingView";
            this.Sizable = true;
            this.Text = "連携機能設定";
            ((System.ComponentModel.ISupportInitialize)(this.dgvSendProtocol)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        /// <summary>
        /// The cb is use
        /// </summary>
        private System.Windows.Forms.CheckBox cbIsUse;
        /// <summary>
        /// The label1
        /// </summary>
        private System.Windows.Forms.Label label1;
        /// <summary>
        /// The BTN save
        /// </summary>
        private MaterialSkin.Controls.MaterialRaisedButton btnSave;
        /// <summary>
        /// The BTN cancel
        /// </summary>
        private MaterialSkin.Controls.MaterialRaisedButton btnCancel;
        /// <summary>
        /// The DGV send protocol
        /// </summary>
        private System.Windows.Forms.DataGridView dgvSendProtocol;
        /// <summary>
        /// The CBB protocol
        /// </summary>
        private System.Windows.Forms.ComboBox cbbProtocol;
        private System.Windows.Forms.Label lbFacName;
    }
}