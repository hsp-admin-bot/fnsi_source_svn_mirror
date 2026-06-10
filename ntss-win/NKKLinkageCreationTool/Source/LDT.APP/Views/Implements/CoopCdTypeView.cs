using LDT.APP.Views.implements;
using LDT.APP.Views.Interfaces;
using LDT.SERVICE.Models;
using System;
using System.Collections.Generic;
using System.Windows.Forms;

namespace LDT.APP.Views.Implements
{
  public partial class CoopCdTypeView : BaseView, ICoopCdTypeView
  {
    private List<CoopCdTypeModel> _coopCdTypeModelList;
    public bool IsClickCloseOnWindow = true;
    private CoopCdTypeModel _selectedItem;
    public CoopCdTypeModel SelectedItem { get => _selectedItem; set => _selectedItem = value; }

    public CoopCdTypeView(List<CoopCdTypeModel> coopCdTypeModelList)
    {
      InitializeComponent();
      RegisterEvent();
      _coopCdTypeModelList = coopCdTypeModelList;
      BindDataSource();
    }

    private delegate void BindDataSourcecallBack();

    private void BindDataSource()
    {
      if (dgvCoopType.InvokeRequired)
      {
        BindDataSourcecallBack callback = new BindDataSourcecallBack(BindDataSource);
        this.Invoke(callback);
      }
      else
      {
        dgvCoopType.DataSource = _coopCdTypeModelList;
      }
    }

    public void RegisterEvent()
    {
      this.dgvCoopType.DataBindingComplete += new System.Windows.Forms.DataGridViewBindingCompleteEventHandler(this.dgvCoopType_DataBindingComplete);
      this.btnCancel.Click += new EventHandler(BtnCancel_Click);
      this.btnOK.Click += new EventHandler(BtnOK_Click);
      this.btnOK.Enabled = false;
      this.dgvCoopType.SelectionChanged += new EventHandler(DgvCoopType_SelectionChanged);
    }

    private void DgvCoopType_SelectionChanged(object sender, EventArgs e)
    {
      DataGridView dataGridView = sender as DataGridView;
      if (dataGridView.SelectedRows != null && dataGridView.SelectedRows.Count == 1)
      {
        this.SelectedItem = dataGridView.SelectedRows[0].DataBoundItem as CoopCdTypeModel;
        this.btnOK.Enabled = true;
      }
      else
      {
        this.btnOK.Enabled = false;
      }
    }

    private void BtnOK_Click(object sender, EventArgs e)
    {
      IsClickCloseOnWindow = false;
      this.Close();
    }

    private void BtnCancel_Click(object sender, EventArgs e)
    {
      this.SelectedItem = null;
      this.Close();
    }

    private void dgvCoopType_DataBindingComplete(object sender, DataGridViewBindingCompleteEventArgs e)
    {
      foreach (DataGridViewRow row in dgvCoopType.Rows)
      {
        dgvCoopType.Rows[row.Index].HeaderCell.Value = $"{row.Index + 1}  ";
      }
      ResizeHeader();
    }

    private delegate void ResizeHeaderCallback();

    private void ResizeHeader()
    {
      if (this.dgvCoopType.InvokeRequired)
      {
        ResizeHeaderCallback callback = new ResizeHeaderCallback(ResizeHeader);
        this.Invoke(callback);
      }
      else
      {
        dgvCoopType.AutoResizeRowHeadersWidth(DataGridViewRowHeadersWidthSizeMode.AutoSizeToAllHeaders);
      }
    }
  }
}
