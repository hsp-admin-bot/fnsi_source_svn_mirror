// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-19-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-19-2021
// ***********************************************************************
// <copyright file="MainMenuView.Designer.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************

namespace CoopSettingTool.App.Views
{
    /// <summary>
    /// Class MainMenuView.
    /// Implements the <see cref="CoopSettingTool.App.Views.BaseView" />
    /// Implements the <see cref="CoopSettingTool.App.Views.IMainMenuView" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Views.BaseView" />
    /// <seealso cref="CoopSettingTool.App.Views.IMainMenuView" />
    partial class MainMenuView
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
            this.lbFacility = new System.Windows.Forms.Label();
            this.btnChangeFacility = new MaterialSkin.Controls.MaterialRaisedButton();
            this.btnCoopFacility = new MaterialSkin.Controls.MaterialRaisedButton();
            this.btnCoopSetting = new MaterialSkin.Controls.MaterialRaisedButton();
            this.btnIfEdge = new MaterialSkin.Controls.MaterialRaisedButton();
            this.btnOrderNumber = new MaterialSkin.Controls.MaterialRaisedButton();
            this.btnCoopInstall = new MaterialSkin.Controls.MaterialRaisedButton();
            this.btnLogOut = new MaterialSkin.Controls.MaterialRaisedButton();
            this.btnHelp = new MaterialSkin.Controls.MaterialRaisedButton();
            this.lbFacName = new System.Windows.Forms.Label();
            this.btnCoopDistribute = new MaterialSkin.Controls.MaterialRaisedButton();
            this.btnCoopLayout = new MaterialSkin.Controls.MaterialRaisedButton();
            this.btnCoopLayoutDetail = new MaterialSkin.Controls.MaterialRaisedButton();
            this.SuspendLayout();
            // 
            // lbFacility
            // 
            this.lbFacility.AutoSize = true;
            this.lbFacility.Font = new System.Drawing.Font("MS UI Gothic", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lbFacility.Location = new System.Drawing.Point(12, 86);
            this.lbFacility.MaximumSize = new System.Drawing.Size(48, 28);
            this.lbFacility.MinimumSize = new System.Drawing.Size(45, 28);
            this.lbFacility.Name = "lbFacility";
            this.lbFacility.Size = new System.Drawing.Size(48, 28);
            this.lbFacility.TabIndex = 1;
            this.lbFacility.Text = "施設：";
            this.lbFacility.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // btnChangeFacility
            // 
            this.btnChangeFacility.Depth = 0;
            this.btnChangeFacility.Location = new System.Drawing.Point(345, 86);
            this.btnChangeFacility.MouseState = MaterialSkin.MouseState.HOVER;
            this.btnChangeFacility.Name = "btnChangeFacility";
            this.btnChangeFacility.Primary = true;
            this.btnChangeFacility.Size = new System.Drawing.Size(73, 28);
            this.btnChangeFacility.TabIndex = 14;
            this.btnChangeFacility.Text = "変更";
            this.btnChangeFacility.UseVisualStyleBackColor = true;
            // 
            // btnCoopFacility
            // 
            this.btnCoopFacility.Depth = 0;
            this.btnCoopFacility.Location = new System.Drawing.Point(12, 158);
            this.btnCoopFacility.MouseState = MaterialSkin.MouseState.HOVER;
            this.btnCoopFacility.Name = "btnCoopFacility";
            this.btnCoopFacility.Primary = true;
            this.btnCoopFacility.Size = new System.Drawing.Size(406, 28);
            this.btnCoopFacility.TabIndex = 15;
            this.btnCoopFacility.Text = "連携施設マスタ設定";
            this.btnCoopFacility.UseVisualStyleBackColor = true;
            this.btnCoopFacility.Visible = false;
            // 
            // btnCoopSetting
            // 
            this.btnCoopSetting.Depth = 0;
            this.btnCoopSetting.Location = new System.Drawing.Point(12, 297);
            this.btnCoopSetting.MouseState = MaterialSkin.MouseState.HOVER;
            this.btnCoopSetting.Name = "btnCoopSetting";
            this.btnCoopSetting.Primary = true;
            this.btnCoopSetting.Size = new System.Drawing.Size(406, 28);
            this.btnCoopSetting.TabIndex = 16;
            this.btnCoopSetting.Text = "連携設定";
            this.btnCoopSetting.UseVisualStyleBackColor = true;
            this.btnCoopSetting.Visible = false;
            // 
            // btnIfEdge
            // 
            this.btnIfEdge.Depth = 0;
            this.btnIfEdge.Location = new System.Drawing.Point(12, 331);
            this.btnIfEdge.MouseState = MaterialSkin.MouseState.HOVER;
            this.btnIfEdge.Name = "btnIfEdge";
            this.btnIfEdge.Primary = true;
            this.btnIfEdge.Size = new System.Drawing.Size(406, 28);
            this.btnIfEdge.TabIndex = 17;
            this.btnIfEdge.Text = "IFエッジ設定";
            this.btnIfEdge.UseVisualStyleBackColor = true;
            this.btnIfEdge.Visible = false;
            // 
            // btnOrderNumber
            // 
            this.btnOrderNumber.Depth = 0;
            this.btnOrderNumber.Location = new System.Drawing.Point(12, 365);
            this.btnOrderNumber.MouseState = MaterialSkin.MouseState.HOVER;
            this.btnOrderNumber.Name = "btnOrderNumber";
            this.btnOrderNumber.Primary = true;
            this.btnOrderNumber.Size = new System.Drawing.Size(406, 28);
            this.btnOrderNumber.TabIndex = 18;
            this.btnOrderNumber.Text = "オーダ番号設定";
            this.btnOrderNumber.UseVisualStyleBackColor = true;
            this.btnOrderNumber.Visible = false;
            // 
            // btnCoopInstall
            // 
            this.btnCoopInstall.Depth = 0;
            this.btnCoopInstall.Location = new System.Drawing.Point(12, 124);
            this.btnCoopInstall.MouseState = MaterialSkin.MouseState.HOVER;
            this.btnCoopInstall.Name = "btnCoopInstall";
            this.btnCoopInstall.Primary = true;
            this.btnCoopInstall.Size = new System.Drawing.Size(406, 28);
            this.btnCoopInstall.TabIndex = 19;
            this.btnCoopInstall.Text = "連携機能インストール";
            this.btnCoopInstall.UseVisualStyleBackColor = true;
            this.btnCoopInstall.Visible = false;
            // 
            // btnLogOut
            // 
            this.btnLogOut.Depth = 0;
            this.btnLogOut.Location = new System.Drawing.Point(328, 31);
            this.btnLogOut.MouseState = MaterialSkin.MouseState.HOVER;
            this.btnLogOut.Name = "btnLogOut";
            this.btnLogOut.Primary = true;
            this.btnLogOut.Size = new System.Drawing.Size(90, 28);
            this.btnLogOut.TabIndex = 21;
            this.btnLogOut.Text = "サインアウト";
            this.btnLogOut.UseVisualStyleBackColor = true;
            // 
            // btnHelp
            // 
            this.btnHelp.Depth = 0;
            this.btnHelp.Location = new System.Drawing.Point(294, 31);
            this.btnHelp.MouseState = MaterialSkin.MouseState.HOVER;
            this.btnHelp.Name = "btnHelp";
            this.btnHelp.Primary = true;
            this.btnHelp.Size = new System.Drawing.Size(28, 28);
            this.btnHelp.TabIndex = 22;
            this.btnHelp.Text = "?";
            this.btnHelp.UseVisualStyleBackColor = true;
            // 
            // lbFacName
            // 
            this.lbFacName.AutoSize = true;
            this.lbFacName.BackColor = System.Drawing.Color.DarkSlateGray;
            this.lbFacName.Font = new System.Drawing.Font("MS UI Gothic", 12F);
            this.lbFacName.ForeColor = System.Drawing.Color.White;
            this.lbFacName.Location = new System.Drawing.Point(54, 86);
            this.lbFacName.MaximumSize = new System.Drawing.Size(285, 28);
            this.lbFacName.MinimumSize = new System.Drawing.Size(285, 28);
            this.lbFacName.Name = "lbFacName";
            this.lbFacName.Size = new System.Drawing.Size(285, 28);
            this.lbFacName.TabIndex = 23;
            this.lbFacName.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // btnCoopDistribute
            // 
            this.btnCoopDistribute.Depth = 0;
            this.btnCoopDistribute.Location = new System.Drawing.Point(12, 192);
            this.btnCoopDistribute.MouseState = MaterialSkin.MouseState.HOVER;
            this.btnCoopDistribute.Name = "btnCoopDistribute";
            this.btnCoopDistribute.Primary = true;
            this.btnCoopDistribute.Size = new System.Drawing.Size(406, 28);
            this.btnCoopDistribute.TabIndex = 24;
            this.btnCoopDistribute.Text = "連携配信設定マスタ設定";
            this.btnCoopDistribute.UseVisualStyleBackColor = true;
            this.btnCoopDistribute.Visible = false;
            // 
            // btnCoopLayout
            // 
            this.btnCoopLayout.Depth = 0;
            this.btnCoopLayout.Location = new System.Drawing.Point(12, 226);
            this.btnCoopLayout.MouseState = MaterialSkin.MouseState.HOVER;
            this.btnCoopLayout.Name = "btnCoopLayout";
            this.btnCoopLayout.Primary = true;
            this.btnCoopLayout.Size = new System.Drawing.Size(406, 28);
            this.btnCoopLayout.TabIndex = 25;
            this.btnCoopLayout.Text = "連携電文レイアウトマスタ設定";
            this.btnCoopLayout.UseVisualStyleBackColor = true;
            this.btnCoopLayout.Visible = false;
            // 
            // btnCoopLayoutDetail
            // 
            this.btnCoopLayoutDetail.Depth = 0;
            this.btnCoopLayoutDetail.Location = new System.Drawing.Point(12, 260);
            this.btnCoopLayoutDetail.MouseState = MaterialSkin.MouseState.HOVER;
            this.btnCoopLayoutDetail.Name = "btnCoopLayoutDetail";
            this.btnCoopLayoutDetail.Primary = true;
            this.btnCoopLayoutDetail.Size = new System.Drawing.Size(406, 28);
            this.btnCoopLayoutDetail.TabIndex = 26;
            this.btnCoopLayoutDetail.Text = "連携電文レイアウト詳細マスタ設定";
            this.btnCoopLayoutDetail.UseVisualStyleBackColor = true;
            this.btnCoopLayoutDetail.Visible = false;
            // 
            // MainMenuView
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(430, 425);
            this.Controls.Add(this.btnCoopLayoutDetail);
            this.Controls.Add(this.btnCoopLayout);
            this.Controls.Add(this.btnCoopDistribute);
            this.Controls.Add(this.lbFacName);
            this.Controls.Add(this.btnHelp);
            this.Controls.Add(this.btnLogOut);
            this.Controls.Add(this.btnCoopInstall);
            this.Controls.Add(this.btnOrderNumber);
            this.Controls.Add(this.btnIfEdge);
            this.Controls.Add(this.btnCoopSetting);
            this.Controls.Add(this.btnCoopFacility);
            this.Controls.Add(this.btnChangeFacility);
            this.Controls.Add(this.lbFacility);
            this.HelpButton = true;
            this.MaximizeBox = true;
            this.MinimizeBox = true;
            this.Name = "MainMenuView";
            this.Sizable = true;
            this.Text = "メニュー";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        /// <summary>
        /// The lb facility
        /// </summary>
        private System.Windows.Forms.Label lbFacility;
        /// <summary>
        /// The BTN change facility
        /// </summary>
        private MaterialSkin.Controls.MaterialRaisedButton btnChangeFacility;
        /// <summary>
        /// The BTN coop on off
        /// </summary>
        private MaterialSkin.Controls.MaterialRaisedButton btnCoopFacility;
        /// <summary>
        /// The BTN coop setting
        /// </summary>
        private MaterialSkin.Controls.MaterialRaisedButton btnCoopSetting;
        /// <summary>
        /// The BTN if edge
        /// </summary>
        private MaterialSkin.Controls.MaterialRaisedButton btnIfEdge;
        /// <summary>
        /// The BTN order number
        /// </summary>
        private MaterialSkin.Controls.MaterialRaisedButton btnOrderNumber;
        /// <summary>
        /// The BTN coop install
        /// </summary>
        private MaterialSkin.Controls.MaterialRaisedButton btnCoopInstall;
        /// <summary>
        /// The BTN cancel
        /// </summary>
        private MaterialSkin.Controls.MaterialRaisedButton btnLogOut;
        private MaterialSkin.Controls.MaterialRaisedButton btnHelp;
        private System.Windows.Forms.Label lbFacName;
        private MaterialSkin.Controls.MaterialRaisedButton btnCoopDistribute;
        private MaterialSkin.Controls.MaterialRaisedButton btnCoopLayout;
        private MaterialSkin.Controls.MaterialRaisedButton btnCoopLayoutDetail;
    }
}