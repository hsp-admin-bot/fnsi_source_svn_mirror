using LDT.APP.Properties;

namespace LDT.APP.Views.Implements
{
  partial class CoopCdTypeView
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
            this.dgvCoopType = new System.Windows.Forms.DataGridView();
            this.Title = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.Code = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.btnCancel = new MaterialSkin.Controls.MaterialRaisedButton();
            this.btnOK = new MaterialSkin.Controls.MaterialRaisedButton();
            ((System.ComponentModel.ISupportInitialize)(this.dgvCoopType)).BeginInit();
            this.SuspendLayout();
            // 
            // dgvCoopType
            // 
            this.dgvCoopType.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.Title,
            this.Code});
            this.dgvCoopType.Location = new System.Drawing.Point(12, 78);
            this.dgvCoopType.MultiSelect = false;
            this.dgvCoopType.Name = "dgvCoopType";
            this.dgvCoopType.ReadOnly = true;
            this.dgvCoopType.SelectionMode = System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
            this.dgvCoopType.Size = new System.Drawing.Size(799, 456);
            this.dgvCoopType.TabIndex = 0;
            // 
            // Title
            // 
            this.Title.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.Fill;
            this.Title.DataPropertyName = "Title";
            this.Title.HeaderText = "連携";
            this.Title.Name = "Title";
            this.Title.ReadOnly = true;
            // 
            // Code
            // 
            this.Code.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.Fill;
            this.Code.DataPropertyName = "Code";
            this.Code.HeaderText = "電文種別";
            this.Code.Name = "Code";
            this.Code.ReadOnly = true;
            // 
            // btnCancel
            // 
            this.btnCancel.Depth = 0;
            this.btnCancel.Location = new System.Drawing.Point(12, 540);
            this.btnCancel.MouseState = MaterialSkin.MouseState.HOVER;
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Primary = true;
            this.btnCancel.Size = new System.Drawing.Size(115, 29);
            this.btnCancel.TabIndex = 9;
            this.btnCancel.Text = global::LDT.APP.Properties.Resources.BACK;
            this.btnCancel.UseVisualStyleBackColor = true;
            // 
            // btnOK
            // 
            this.btnOK.Depth = 0;
            this.btnOK.Location = new System.Drawing.Point(696, 540);
            this.btnOK.MouseState = MaterialSkin.MouseState.HOVER;
            this.btnOK.Name = "btnOK";
            this.btnOK.Primary = true;
            this.btnOK.Size = new System.Drawing.Size(115, 29);
            this.btnOK.TabIndex = 9;
            this.btnOK.Text = global::LDT.APP.Properties.Resources.CONFIRM;
            this.btnOK.UseVisualStyleBackColor = true;
            // 
            // CoopCdTypeView
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(831, 581);
            this.Controls.Add(this.btnOK);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.dgvCoopType);
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "CoopCdTypeView";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "COOP CDビュー";
            ((System.ComponentModel.ISupportInitialize)(this.dgvCoopType)).EndInit();
            this.ResumeLayout(false);

    }

    #endregion
    private System.Windows.Forms.DataGridView dgvCoopType;
    private System.Windows.Forms.DataGridViewTextBoxColumn Title;
    private System.Windows.Forms.DataGridViewTextBoxColumn Code;
    private MaterialSkin.Controls.MaterialRaisedButton btnCancel;
    private MaterialSkin.Controls.MaterialRaisedButton btnOK;
  }
}
