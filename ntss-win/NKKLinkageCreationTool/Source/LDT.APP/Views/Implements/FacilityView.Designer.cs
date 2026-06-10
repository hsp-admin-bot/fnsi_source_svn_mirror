using LDT.APP.Properties;

namespace LDT.APP.Views.Implements
{
  partial class FacilityView
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
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle4 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle5 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle6 = new System.Windows.Forms.DataGridViewCellStyle();
            this.panel1 = new System.Windows.Forms.Panel();
            this.lblCoopLayoutRecord = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.btnCopy = new MaterialSkin.Controls.MaterialRaisedButton();
            this.btnAddNew = new MaterialSkin.Controls.MaterialRaisedButton();
            this.btnCancel = new System.Windows.Forms.Button();
            this.dgvCoopLayout = new System.Windows.Forms.DataGridView();
            this.lblLoading = new System.Windows.Forms.Label();
            this.btnReload = new MaterialSkin.Controls.MaterialRaisedButton();
            this.btnUpdate = new MaterialSkin.Controls.MaterialRaisedButton();
            this.cbbFacility = new System.Windows.Forms.ComboBox();
            this.label2 = new System.Windows.Forms.Label();
            this.panel1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgvCoopLayout)).BeginInit();
            this.SuspendLayout();
            // 
            // panel1
            // 
            this.panel1.Controls.Add(this.lblCoopLayoutRecord);
            this.panel1.Controls.Add(this.label1);
            this.panel1.Controls.Add(this.btnCopy);
            this.panel1.Controls.Add(this.btnAddNew);
            this.panel1.Controls.Add(this.btnCancel);
            this.panel1.Controls.Add(this.dgvCoopLayout);
            this.panel1.Controls.Add(this.lblLoading);
            this.panel1.Controls.Add(this.btnReload);
            this.panel1.Controls.Add(this.btnUpdate);
            this.panel1.Controls.Add(this.cbbFacility);
            this.panel1.Controls.Add(this.label2);
            this.panel1.Location = new System.Drawing.Point(12, 70);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(636, 565);
            this.panel1.TabIndex = 1;
            // 
            // lblCoopLayoutRecord
            // 
            this.lblCoopLayoutRecord.AutoSize = true;
            this.lblCoopLayoutRecord.BackColor = System.Drawing.Color.OrangeRed;
            this.lblCoopLayoutRecord.ForeColor = System.Drawing.Color.White;
            this.lblCoopLayoutRecord.Location = new System.Drawing.Point(581, 93);
            this.lblCoopLayoutRecord.Name = "lblCoopLayoutRecord";
            this.lblCoopLayoutRecord.Size = new System.Drawing.Size(13, 13);
            this.lblCoopLayoutRecord.TabIndex = 20;
            this.lblCoopLayoutRecord.Text = "0";
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(530, 93);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(48, 13);
            this.label1.TabIndex = 19;
            this.label1.Text = "Record: ";
            // 
            // btnCopy
            // 
            this.btnCopy.Depth = 0;
            this.btnCopy.Enabled = false;
            this.btnCopy.Location = new System.Drawing.Point(268, 528);
            this.btnCopy.MouseState = MaterialSkin.MouseState.HOVER;
            this.btnCopy.Name = "btnCopy";
            this.btnCopy.Primary = true;
            this.btnCopy.Size = new System.Drawing.Size(100, 28);
            this.btnCopy.TabIndex = 18;
            this.btnCopy.Text = "コピー";
            this.btnCopy.UseVisualStyleBackColor = true;
            // 
            // btnAddNew
            // 
            this.btnAddNew.Depth = 0;
            this.btnAddNew.ImageAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.btnAddNew.Location = new System.Drawing.Point(394, 528);
            this.btnAddNew.MouseState = MaterialSkin.MouseState.HOVER;
            this.btnAddNew.Name = "btnAddNew";
            this.btnAddNew.Primary = true;
            this.btnAddNew.Size = new System.Drawing.Size(100, 28);
            this.btnAddNew.TabIndex = 17;
            this.btnAddNew.Text = "新規追加";
            this.btnAddNew.UseVisualStyleBackColor = true;
            // 
            // btnCancel
            // 
            this.btnCancel.BackColor = System.Drawing.Color.White;
            this.btnCancel.FlatStyle = System.Windows.Forms.FlatStyle.System;
            this.btnCancel.Location = new System.Drawing.Point(20, 528);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(100, 28);
            this.btnCancel.TabIndex = 16;
            this.btnCancel.Text = "戻る";
            this.btnCancel.UseVisualStyleBackColor = false;
            // 
            // dgvCoopLayout
            // 
            this.dgvCoopLayout.AllowUserToAddRows = false;
            this.dgvCoopLayout.AllowUserToDeleteRows = false;
            dataGridViewCellStyle4.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle4.BackColor = System.Drawing.SystemColors.Control;
            dataGridViewCellStyle4.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle4.ForeColor = System.Drawing.SystemColors.WindowText;
            dataGridViewCellStyle4.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle4.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            dataGridViewCellStyle4.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.dgvCoopLayout.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle4;
            this.dgvCoopLayout.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            dataGridViewCellStyle5.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle5.BackColor = System.Drawing.SystemColors.Window;
            dataGridViewCellStyle5.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle5.ForeColor = System.Drawing.SystemColors.ControlText;
            dataGridViewCellStyle5.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle5.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            dataGridViewCellStyle5.WrapMode = System.Windows.Forms.DataGridViewTriState.False;
            this.dgvCoopLayout.DefaultCellStyle = dataGridViewCellStyle5;
            this.dgvCoopLayout.Location = new System.Drawing.Point(20, 114);
            this.dgvCoopLayout.MultiSelect = false;
            this.dgvCoopLayout.Name = "dgvCoopLayout";
            this.dgvCoopLayout.ReadOnly = true;
            dataGridViewCellStyle6.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle6.BackColor = System.Drawing.SystemColors.Control;
            dataGridViewCellStyle6.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            dataGridViewCellStyle6.ForeColor = System.Drawing.SystemColors.WindowText;
            dataGridViewCellStyle6.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle6.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            dataGridViewCellStyle6.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.dgvCoopLayout.RowHeadersDefaultCellStyle = dataGridViewCellStyle6;
            this.dgvCoopLayout.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dgvCoopLayout.Size = new System.Drawing.Size(596, 408);
            this.dgvCoopLayout.TabIndex = 15;
            // 
            // lblLoading
            // 
            this.lblLoading.AutoSize = true;
            this.lblLoading.BackColor = System.Drawing.Color.White;
            this.lblLoading.Font = new System.Drawing.Font("Microsoft Sans Serif", 11F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.lblLoading.ForeColor = System.Drawing.SystemColors.ControlDarkDark;
            this.lblLoading.Location = new System.Drawing.Point(17, 90);
            this.lblLoading.Name = "lblLoading";
            this.lblLoading.Size = new System.Drawing.Size(215, 18);
            this.lblLoading.TabIndex = 14;
            this.lblLoading.Text = "実行が完了するまで待ってください。";
            // 
            // btnReload
            // 
            this.btnReload.Depth = 0;
            this.btnReload.Location = new System.Drawing.Point(516, 54);
            this.btnReload.MouseState = MaterialSkin.MouseState.HOVER;
            this.btnReload.Name = "btnReload";
            this.btnReload.Primary = true;
            this.btnReload.Size = new System.Drawing.Size(100, 28);
            this.btnReload.TabIndex = 13;
            this.btnReload.Text = "Refresh";
            this.btnReload.UseVisualStyleBackColor = true;
            // 
            // btnUpdate
            // 
            this.btnUpdate.Depth = 0;
            this.btnUpdate.Enabled = false;
            this.btnUpdate.Location = new System.Drawing.Point(516, 528);
            this.btnUpdate.MouseState = MaterialSkin.MouseState.HOVER;
            this.btnUpdate.Name = "btnUpdate";
            this.btnUpdate.Primary = true;
            this.btnUpdate.Size = new System.Drawing.Size(100, 28);
            this.btnUpdate.TabIndex = 13;
            this.btnUpdate.Text = "更新";
            this.btnUpdate.UseVisualStyleBackColor = true;
            // 
            // cbbFacility
            // 
            this.cbbFacility.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cbbFacility.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.cbbFacility.FormattingEnabled = true;
            this.cbbFacility.IntegralHeight = false;
            this.cbbFacility.Location = new System.Drawing.Point(20, 54);
            this.cbbFacility.Name = "cbbFacility";
            this.cbbFacility.Size = new System.Drawing.Size(478, 28);
            this.cbbFacility.TabIndex = 1;
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.label2.Location = new System.Drawing.Point(226, 16);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(73, 20);
            this.label2.TabIndex = 0;
            this.label2.Text = "施設一覧";
            // 
            // FacilityView
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(663, 647);
            this.Controls.Add(this.panel1);
            this.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(128)));
            this.MaximizeBox = false;
            this.Name = "FacilityView";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "施設ビュー";
            this.panel1.ResumeLayout(false);
            this.panel1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgvCoopLayout)).EndInit();
            this.ResumeLayout(false);

    }

    #endregion

    private System.Windows.Forms.Panel panel1;
    private System.Windows.Forms.ComboBox cbbFacility;
    private System.Windows.Forms.Label label2;
    private MaterialSkin.Controls.MaterialRaisedButton btnReload;
    private MaterialSkin.Controls.MaterialRaisedButton btnUpdate;
    private System.Windows.Forms.Label lblLoading;
    private System.Windows.Forms.Button btnCancel;
    private System.Windows.Forms.DataGridView dgvCoopLayout;
    private MaterialSkin.Controls.MaterialRaisedButton btnCopy;
    private MaterialSkin.Controls.MaterialRaisedButton btnAddNew;
    private System.Windows.Forms.Label lblCoopLayoutRecord;
    private System.Windows.Forms.Label label1;
  }
}
