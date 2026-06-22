using LDT.APP.Properties;
using LDT.APP.Views.implements;
using LDT.APP.Views.Interfaces;
using LDT.SERVICE.Models;
using System;
using System.Collections.Generic;
using System.Windows.Forms;

namespace LDT.APP.Views.Implements
{
  public partial class EditKeyView : BaseView, IEditKeyView
  {
    public bool IsClickCloseOnWindow = true;
    public string KeyNameEdit { get; set; }
    public List<SubKeyModel> SubKeyList { get; set; }
    public bool IsEdit { get; set; }

    private bool isNotClickXButton = false;

    public EditKeyView(List<SubKeyModel> subkeyList, string key = "")
    {
      subkeyList = subkeyList ?? new List<SubKeyModel>();
      InitializeComponent();
      RegisterEvent();
      SubKeyList = subkeyList;
      txtKey.Text = KeyNameEdit = key;
      SetDefault();
      BindDataSource();
    }

    public void SetDefault()
    {
      btnSettingElementAddNew.Enabled = !string.IsNullOrWhiteSpace(txtKey.Text);
      btnSettingElementDelete.Enabled = false;
    }

    public void RegisterEvent()
    {
      this.btnCancel.Click += new EventHandler(BtnCancel_Click);
      this.btnSave.Click += new EventHandler(BtnOK_Click);
      this.btnSettingElementAddNew.Click += new EventHandler(BtnSettingElementAddNew_Click);
      this.btnSettingElementDelete.Click += new EventHandler(BtnSettingElementDelete_Click);
      txtKey.TextChanged += new EventHandler(TxtKey_TextChanged);
      this.dgvSubKey.CellValueChanged += new DataGridViewCellEventHandler(DgvSubKey_CellValueChanged);
      this.dgvSubKey.RowStateChanged += new DataGridViewRowStateChangedEventHandler(DgvSubKey_RowStateChanged);
      this.dgvSubKey.SelectionChanged += new EventHandler(this.DgvSubKey_SelectionChanged);
      this.FormClosing += new FormClosingEventHandler(this.EditKeyView_FormClosing);
    }

    public void BindDataSource()
    {
      var subKeyItem = SubKeyList.Find(x => x.KeyName == KeyNameEdit);
      if (subKeyItem != null)
      {
        foreach (var item in subKeyItem.ValueList)
        {
          dgvSubKey.Rows.Add(item.KeyName, item.Value);
        }
      }
    }

    public void GetValueFromGridview()
    {
      List<KeyValue> keyValueList = new List<KeyValue>();
      for (int i = 0; i < dgvSubKey.RowCount; i++)
      {
        string key = dgvSubKey["KeyName", i].Value == null ? string.Empty : dgvSubKey["KeyName", i].Value.ToString().Trim();
        if (!string.IsNullOrEmpty(key))
        {
          string value = dgvSubKey["Value", i].Value == null ? string.Empty : dgvSubKey["Value", i].Value.ToString().Trim();
          KeyValue keyValue = new KeyValue();
          keyValue.KeyName = key;
          keyValue.Value = value;
          keyValueList.Add(keyValue);
        }
      }
      var item = SubKeyList.Find(x => x.KeyName == KeyNameEdit);
      if (item != null)
        SubKeyList.Remove(item);
      if (!string.IsNullOrEmpty(txtKey.Text.Trim()))
      {
        SubKeyModel subkey = new SubKeyModel();
        subkey.KeyName = txtKey.Text.Trim();
        subkey.ValueList = keyValueList;
        SubKeyList.Add(subkey);
      }
    }

    private void BtnCancel_Click(object sender, EventArgs e)
    {
      if (MessageBox.Show(Resources.CANCEL_OR_RELOAD_CONFIRM, Text, MessageBoxButtons.OKCancel, MessageBoxIcon.Question) == DialogResult.OK)
      {
        isNotClickXButton = true;
        this.Close();
      }
    }

    private void BtnOK_Click(object sender, EventArgs e)
    {
      if (SubKeyList.Find(x => x.KeyName == txtKey.Text.Trim()) != null && txtKey.Text.Trim() != KeyNameEdit)
      {
        MessageBox.Show(Resources.KEY_EXISTS, Text, MessageBoxButtons.OK, MessageBoxIcon.Error);
        txtKey.Focus();
        return;
      }
      GetValueFromGridview();
      IsClickCloseOnWindow = false;
      isNotClickXButton = true;
      string key = string.Empty;
      if (dgvSubKey.RowCount > 0)
        key = dgvSubKey["KeyName", dgvSubKey.RowCount - 1].Value == null ? string.Empty : dgvSubKey["KeyName", dgvSubKey.RowCount - 1].Value.ToString().Trim();
      KeyNameEdit = txtKey.Text.Trim();
      this.Close();
    }

    private void BtnSettingElementAddNew_Click(object sender, EventArgs e)
    {
      string key = string.Empty;
      if (dgvSubKey.RowCount > 0)
        key = dgvSubKey["KeyName", dgvSubKey.RowCount - 1].Value == null ? string.Empty : dgvSubKey["KeyName", dgvSubKey.RowCount - 1].Value.ToString().Trim();
      if ((dgvSubKey.RowCount == 0 || !string.IsNullOrEmpty(key)) && !string.IsNullOrWhiteSpace(txtKey.Text))
      {
        dgvSubKey.Rows.Add();
      }
      if (dgvSubKey.RowCount > 0)
      {
        dgvSubKey.FirstDisplayedScrollingRowIndex = dgvSubKey.RowCount - 1;
        dgvSubKey.CurrentCell = dgvSubKey["KeyName", dgvSubKey.RowCount - 1];
      }
    }

    private void BtnSettingElementDelete_Click(object sender, EventArgs e)
    {
      if (dgvSubKey.Rows.Count > 0 && dgvSubKey.SelectedRows.Count > 0 && MessageBox.Show(Resources.DELETE_CONFIRM, Text, MessageBoxButtons.OKCancel, MessageBoxIcon.Question) == DialogResult.OK)
      {
        dgvSubKey.Rows.RemoveAt(dgvSubKey.CurrentCell.RowIndex);
      }
    }

    private void TxtKey_TextChanged(object sender, EventArgs e)
    {
      btnSettingElementAddNew.Enabled = !string.IsNullOrWhiteSpace(txtKey.Text);
    }

    private void DgvSubKey_CellValueChanged(object sender, DataGridViewCellEventArgs e)
    {
      IsEdit = true;
    }

    private void DgvSubKey_RowStateChanged(object sender, DataGridViewRowStateChangedEventArgs e)
    {
      btnSettingElementDelete.Enabled = (dgvSubKey.RowCount > 0);
    }

    private void DgvSubKey_SelectionChanged(object sender, EventArgs e)
    {
      btnSettingElementDelete.Enabled = (dgvSubKey.SelectedRows.Count > 0);
    }

    private void EditKeyView_FormClosing(object sender, FormClosingEventArgs e)
    {
      if (isNotClickXButton == false)
      {
        if (MessageBox.Show(Resources.CANCEL_OR_RELOAD_CONFIRM, Text, MessageBoxButtons.OKCancel, MessageBoxIcon.Question) == DialogResult.Cancel)
          e.Cancel = true;
      }
    }
  }
}
