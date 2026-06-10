using LDT.APP.Properties;

namespace LDT.APP.Views.Implements
{
  partial class EditKeyView
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
            this.dgvSubKey = new System.Windows.Forms.DataGridView();
            this.KeyName = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.Value = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.label1 = new System.Windows.Forms.Label();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.btnSettingElementAddNew = new MaterialSkin.Controls.MaterialRaisedButton();
            this.btnSettingElementDelete = new MaterialSkin.Controls.MaterialRaisedButton();
            this.btnCancel = new MaterialSkin.Controls.MaterialRaisedButton();
            this.btnSave = new MaterialSkin.Controls.MaterialRaisedButton();
            this.txtKey = new System.Windows.Forms.TextBox();
            ((System.ComponentModel.ISupportInitialize)(this.dgvSubKey)).BeginInit();
            this.groupBox2.SuspendLayout();
            this.SuspendLayout();
            // 
            // dgvSubKey
            // 
            this.dgvSubKey.AllowUserToAddRows = false;
            this.dgvSubKey.AllowUserToDeleteRows = false;
            this.dgvSubKey.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgvSubKey.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.KeyName,
            this.Value});
            this.dgvSubKey.Location = new System.Drawing.Point(6, 48);
            this.dgvSubKey.MultiSelect = false;
            this.dgvSubKey.Name = "dgvSubKey";
            this.dgvSubKey.RowHeadersWidth = 25;
            this.dgvSubKey.Size = new System.Drawing.Size(492, 253);
            this.dgvSubKey.TabIndex = 4;
            // 
            // KeyName
            // 
            this.KeyName.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.None;
            this.KeyName.DataPropertyName = "KeyName";
            this.KeyName.FillWeight = 101.5228F;
            this.KeyName.HeaderText = "Sub Key";
            this.KeyName.Name = "KeyName";
            this.KeyName.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable;
            this.KeyName.Width = 110;
            // 
            // Value
            // 
            this.Value.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.Fill;
            this.Value.DataPropertyName = "Value";
            this.Value.FillWeight = 98.47716F;
            this.Value.HeaderText = "Value";
            this.Value.Name = "Value";
            this.Value.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(14, 88);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(27, 13);
            this.label1.TabIndex = 16;
            this.label1.Text = "キー";
            // 
            // groupBox2
            // 
            this.groupBox2.Controls.Add(this.btnSettingElementAddNew);
            this.groupBox2.Controls.Add(this.btnSettingElementDelete);
            this.groupBox2.Controls.Add(this.dgvSubKey);
            this.groupBox2.Location = new System.Drawing.Point(12, 140);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Size = new System.Drawing.Size(503, 307);
            this.groupBox2.TabIndex = 19;
            this.groupBox2.TabStop = false;
            // 
            // btnSettingElementAddNew
            // 
            this.btnSettingElementAddNew.Depth = 0;
            this.btnSettingElementAddNew.Location = new System.Drawing.Point(408, 13);
            this.btnSettingElementAddNew.MouseState = MaterialSkin.MouseState.HOVER;
            this.btnSettingElementAddNew.Name = "btnSettingElementAddNew";
            this.btnSettingElementAddNew.Primary = true;
            this.btnSettingElementAddNew.Size = new System.Drawing.Size(90, 29);
            this.btnSettingElementAddNew.TabIndex = 5;
            this.btnSettingElementAddNew.Text = global::LDT.APP.Properties.Resources.ADD_NEW;
            this.btnSettingElementAddNew.UseVisualStyleBackColor = true;
            // 
            // btnSettingElementDelete
            // 
            this.btnSettingElementDelete.Depth = 0;
            this.btnSettingElementDelete.Location = new System.Drawing.Point(309, 13);
            this.btnSettingElementDelete.MouseState = MaterialSkin.MouseState.HOVER;
            this.btnSettingElementDelete.Name = "btnSettingElementDelete";
            this.btnSettingElementDelete.Primary = true;
            this.btnSettingElementDelete.Size = new System.Drawing.Size(90, 29);
            this.btnSettingElementDelete.TabIndex = 5;
            this.btnSettingElementDelete.Text = global::LDT.APP.Properties.Resources.DELETE;
            this.btnSettingElementDelete.UseVisualStyleBackColor = true;
            // 
            // btnCancel
            // 
            this.btnCancel.Depth = 0;
            this.btnCancel.Location = new System.Drawing.Point(17, 453);
            this.btnCancel.MouseState = MaterialSkin.MouseState.HOVER;
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Primary = true;
            this.btnCancel.Size = new System.Drawing.Size(115, 29);
            this.btnCancel.TabIndex = 5;
            this.btnCancel.Text = global::LDT.APP.Properties.Resources.BACK;
            this.btnCancel.UseVisualStyleBackColor = true;
            // 
            // btnSave
            // 
            this.btnSave.Depth = 0;
            this.btnSave.Location = new System.Drawing.Point(395, 453);
            this.btnSave.MouseState = MaterialSkin.MouseState.HOVER;
            this.btnSave.Name = "btnSave";
            this.btnSave.Primary = true;
            this.btnSave.Size = new System.Drawing.Size(115, 29);
            this.btnSave.TabIndex = 5;
            this.btnSave.Text = global::LDT.APP.Properties.Resources.SAVE;
            this.btnSave.UseVisualStyleBackColor = true;
            // 
            // txtKey
            // 
            this.txtKey.Location = new System.Drawing.Point(17, 114);
            this.txtKey.Name = "txtKey";
            this.txtKey.Size = new System.Drawing.Size(493, 20);
            this.txtKey.TabIndex = 20;
            // 
            // EditKeyView
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(530, 498);
            this.Controls.Add(this.txtKey);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.btnSave);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.groupBox2);
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "EditKeyView";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "キービューを編集";
            ((System.ComponentModel.ISupportInitialize)(this.dgvSubKey)).EndInit();
            this.groupBox2.ResumeLayout(false);
            this.ResumeLayout(false);
            this.PerformLayout();

    }

    #endregion
    private System.Windows.Forms.DataGridView dgvSubKey;
    private System.Windows.Forms.Label label1;
    private System.Windows.Forms.GroupBox groupBox2;
    private System.Windows.Forms.DataGridViewTextBoxColumn KeyName;
    private System.Windows.Forms.DataGridViewTextBoxColumn Value;
    private MaterialSkin.Controls.MaterialRaisedButton btnSettingElementAddNew;
    private MaterialSkin.Controls.MaterialRaisedButton btnSettingElementDelete;
    private MaterialSkin.Controls.MaterialRaisedButton btnCancel;
    private MaterialSkin.Controls.MaterialRaisedButton btnSave;
    private System.Windows.Forms.TextBox txtKey;
  }
}
