using LDT.APP.Controllers.Implements;
using LDT.APP.Controllers.Interfaces;
using LDT.APP.Models.Interfaces;
using LDT.APP.Properties;
using LDT.APP.Views.implements;
using LDT.APP.Views.Interfaces;
using LDT.SERVICE.Enums;
using LDT.SERVICE.Interfaces;
using LDT.SERVICE.Models;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace LDT.APP.Views.Implements
{
  public partial class SettingView : BaseView, ISettingView
  {
    private readonly string ITEM_TYPE = "item";
    private readonly string OCC_TYPE = "occ";
    private readonly string ROOT = "ROOT";
    private readonly string DATA_CODE_NAME = "data_code";
    private readonly string SQL_PARAM_NAME = "SqlParam";
    private readonly string DATA_SET_NAME = "DataSet";
    private readonly string NO_NAME = "Name1";
    private readonly string LEN_NAME = "Len";
    private readonly string ITEM_TYPE_NAME = "ItemType";
    private readonly string KEY_NAME = "Key";
    private readonly string COL_NAME = "Col";
    private readonly string REPEAT_NAME = "Repeat";
    private readonly string DETAIL_NAME = "Detail";
    private readonly string TERM_NAME = "Term";
    private readonly string VALUE_NAME = "Value";
    private readonly string APPEND_NAME = "Append";
    private readonly string MESSAGE_LEN_NAME = "MessageLen";
    private readonly string PADDING_POSITION_NAME = "PaddingPosition";
    private readonly string PADDING_FORMAT_NAME = "PaddingFormat";
    private readonly string TYPE_NAME = "Type";
    public string EmptyTitle { get; set; }
    private bool IsInit = true;
    private bool IsItem = true;
    private MstCoopLayoutEntity _mstCoopLayoutEntityBackup;

    public MstCoopLayoutEntity MstCoopLayoutEntityBackup
    {
      get => _mstCoopLayoutEntityBackup; set
      {
        _mstCoopLayoutEntityBackup = value;
        if (this._controller != null)
        {
          this._controller.Tmodel.ItemInfoBackup = value;
        }
      }
    }

    private MstCoopLayoutEntity _mstCoopLayoutEntity;

    public MstCoopLayoutEntity MstCoopLayoutEntity
    {
      get => _mstCoopLayoutEntity; set
      {
        _mstCoopLayoutEntity = value;
        if (this._controller != null)
        {
          IsInit = true;
          this._controller.Tmodel.ItemInfo = value;
          MstCoopLayoutEntityBackup = value;
          this._controller.LoadInfoDataForPage();
          IsInit = false;
        }
      }
    }

    private bool _isCancel = false;
    public bool IsCancel { get => _isCancel; set => _isCancel = value; }
    private bool HasFirstCancel = true;
    private ISettingController _controller;
    private TextBox editingBox;
    private Dictionary<string, Dictionary<string, string>> coopExtSetting = new Dictionary<string, Dictionary<string, string>>();
    private List<SubKeyModel> subKeyList = new List<SubKeyModel>();
    private string oldValue;
    private int countEdit = 0;

    public SettingView(ISettingModel model, ISettingService service, IMasterService masterService, ISysDataSetService sysDataSetService, IMstCoopDistributeService mstCoopDistributeService, IMstCoopFacilityService mstCoopFacilityService, IMstCoopLayoutService mstCoopLayoutService, IMstCoopLayoutDetailService mstCoopLayoutDetailService)
    {
      InitializeComponent();
      RegisterEvent();
      SetController(new SettingController(this, model, service, masterService, sysDataSetService, mstCoopDistributeService, mstCoopFacilityService, mstCoopLayoutService, mstCoopLayoutDetailService));
      SetDefault();
      EmptyTitle = string.Empty;
    }

    public void SetDefault()
    {
      btnSettingElementDelete.Enabled = false;
    }

    public void SetController(ISettingController settingController)
    {
      this._controller = settingController;
    }

    public void RegisterEvent()
    {
      this.btnCoopCd.Click += new EventHandler(this.BtnType_Click);
      this.dgvSettingElement.EditingControlShowing += new DataGridViewEditingControlShowingEventHandler(DgvSettingElement_EditingControlShowing);
      this.dgvSettingElement.CellClick += DgvSettingElement_CellClick;
      this.dgvSettingElement.CellEnter += new DataGridViewCellEventHandler(DgvSettingElement_CellEnter);
      this.btnCancel.Click += new EventHandler(BtnCancel_Click);
      this.btnOK.Click += new EventHandler(BtnSubmit_Click);
      this.trvGraph.NodeMouseDoubleClick += new TreeNodeMouseClickEventHandler(TrvGraph_NodeMouseDoubleClick);
      this.btnSettingElementAddNew.Click += new EventHandler(BtnSettingElementAddNew_Click);
      this.btnSettingElementDelete.Click += new EventHandler(BtnSettingElementDelete_Click);
      this.dgvSettingElement.CellEndEdit += new DataGridViewCellEventHandler(this.DgvSettingElement_CellEndEdit);
      this.dgvSettingElement.RowStateChanged += new DataGridViewRowStateChangedEventHandler(this.DgvSettingElement_RowStateChanged);
      this.dgvSettingElement.DataError += new DataGridViewDataErrorEventHandler(this.DgvSettingElement_DataError);
      this.dgvSettingElement.CurrentCellDirtyStateChanged += new EventHandler(this.DgvSettingElement_CurrentCellDirtyStateChanged);
      this.dgvSettingElement.CellBeginEdit += new DataGridViewCellCancelEventHandler(this.DgvSettingElement_CellBeginEdit);
      this.dgvSettingElement.SelectionChanged += new System.EventHandler(this.DgvSettingElement_SelectionChanged);
      this.FormClosing += new FormClosingEventHandler(SettingView_FormClosing);
      this.tbcSettingProtocol.Selecting += new TabControlCancelEventHandler(TbcSettingProtocol_Selecting);
      this.tabProtocolReceive.Selecting += new TabControlCancelEventHandler(TabProtocolReceive_Selecting);
      this.tabProtocolSend.Selecting += new TabControlCancelEventHandler(TabProtocolSend_Selecting);
      this.dgvSettingElement.CellValidating += new DataGridViewCellValidatingEventHandler(DgvSettingElement_CellValidating);
      BindValueControlToModel();
    }

    private void DgvSettingElement_CellValidating(object sender, DataGridViewCellValidatingEventArgs e)
    {
      if (dgvSettingElement.Columns[dgvSettingElement.CurrentCell.ColumnIndex].Name == NO_NAME)
      {
        for (int i = 0; i < dgvSettingElement.Rows.Count; i++)
        {
          if (i != e.RowIndex)
          {
            if (dgvSettingElement[NO_NAME, i].Value != null && dgvSettingElement[NO_NAME, i].Value.ToString() == e.FormattedValue.ToString())
            {
              MessageBox.Show(Resources.NAME_EXISTED, Text, MessageBoxButtons.OK);
              e.Cancel = true;
            }
          }
        }
      }
    }

    private void BindValueToModelOfProtocol()
    {
      if (this.tbcSettingProtocol.SelectedIndex == 0)
      {
        Dictionary<string, string> protocolKV = new Dictionary<string, string>();
        foreach (DataGridViewRow item in dgvReceive.Rows)
        {
          string k = item.Cells[0].Value as string;
          string v = item.Cells[1].Value as string;
          if (!string.IsNullOrEmpty(k) && !string.IsNullOrEmpty(k) && !protocolKV.ContainsKey(k))
          {
            protocolKV.Add(k, v);
          }
        }

        Dictionary<string, string> fileKV = new Dictionary<string, string>();
        foreach (DataGridViewRow item in dgvReceiveFile.Rows)
        {
          string k = item.Cells[0].Value as string;
          string v = item.Cells[1].Value as string;
          if (!string.IsNullOrEmpty(k) && !fileKV.ContainsKey(k))
          {
            fileKV.Add(k, v);
          }
        }

        Dictionary<string, string> socketKV = new Dictionary<string, string>();
        foreach (DataGridViewRow item in dgvReceiveSocket.Rows)
        {
          string k = item.Cells[0].Value as string;
          string v = item.Cells[1].Value as string;
          if (!string.IsNullOrEmpty(k) && !socketKV.ContainsKey(k))
          {
            socketKV.Add(k, v);
          }
        }
        this._controller.Tmodel.MstCoopFacilityEntityAfter = this._controller.Tmodel.MstCoopFacilityEntityAfter ?? new MstCoopFacilityEntity();
        this._controller.Tmodel.MstCoopFacilityEntityAfter.SetIfEdgeSetting(new IfEdgeSettingProtocol()
        {
          ProtocolInfo = new IfEdgeSettingProtocolInfo()
          {
            File = fileKV,
            Protocol = protocolKV,
            Socket = socketKV
          }
        });
        this._controller.Tmodel.MstCoopFacilityEntityAfter.FacilityCd = this._controller.Tmodel.ItemInfo.FacilityCd;
        this._controller.Tmodel.MstCoopDistributeEntityAfter = null;
      }
      else
      {
        // SEND
        Dictionary<string, string> ftpKV = new Dictionary<string, string>();
        foreach (DataGridViewRow item in dgvSendFTP.Rows)
        {
          string k = item.Cells[0].Value as string;
          string v = item.Cells[1].Value as string;
          if (!string.IsNullOrEmpty(k) && !ftpKV.ContainsKey(k))
          {
            ftpKV.Add(k, v);
          }
        }

        Dictionary<string, string> fileKV = new Dictionary<string, string>();
        foreach (DataGridViewRow item in dgvSendFile.Rows)
        {
          string k = item.Cells[0].Value as string;
          string v = item.Cells[1].Value as string;
          if (!string.IsNullOrEmpty(k) && !fileKV.ContainsKey(k))
          {
            fileKV.Add(k, v);
          }
        }

        Dictionary<string, string> socketKV = new Dictionary<string, string>();
        foreach (DataGridViewRow item in dgvSendSocket.Rows)
        {
          string k = item.Cells[0].Value as string;
          string v = item.Cells[1].Value as string;
          if (!string.IsNullOrEmpty(k) && !socketKV.ContainsKey(k))
          {
            socketKV.Add(k, v);
          }
        }
        this._controller.Tmodel.MstCoopDistributeEntityAfter = this._controller.Tmodel.MstCoopDistributeEntityAfter ?? new MstCoopDistributeEntity();
        this._controller.Tmodel.MstCoopDistributeEntityAfter.SetDistributeSetting(new DistributeSettingProtocol()
        {
          ProtocolInfo = new DistributeProtocolInfo()
          {
            File = fileKV,
            FTP = ftpKV,
            Socket = socketKV
          }
        });
        this._controller.Tmodel.MstCoopDistributeEntityAfter.Direction = DIRECTION.SEND;
        this._controller.Tmodel.MstCoopDistributeEntityAfter.CoopCd = btnCoopCd.Text;
        this._controller.Tmodel.MstCoopDistributeEntityAfter.CoopVender = txtCoopVender.Text;
        this._controller.Tmodel.MstCoopFacilityEntityAfter = null;
      }
    }

    private void TabProtocolSend_Selecting(object sender, TabControlCancelEventArgs e)
    {
      int index = e.TabPageIndex;
      switch (index)
      {
        // File
        case 0:
          {
            if (MessageBox.Show(Resources.DELETE_DATA_CURRENT_TAB, Resources.QUESTION, MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes)
            {
              dgvSendFTP.Rows?.Clear();
              dgvSendSocket.Rows?.Clear();
            }
            else
            {
              e.Cancel = true;
            }
            break;
          }
        // socket
        case 1:
          {
            if (MessageBox.Show(Resources.DELETE_DATA_CURRENT_TAB, Resources.QUESTION, MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes)
            {
              dgvSendFile.Rows?.Clear();
              dgvSendFTP.Rows?.Clear();
            }
            else
            {
              e.Cancel = true;
            }
            break;
          }
        // FTP
        case 2:
          {
            if (MessageBox.Show(Resources.DELETE_DATA_CURRENT_TAB, Resources.QUESTION, MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes)
            {
              dgvSendFile.Rows?.Clear();
              dgvSendSocket.Rows?.Clear();
            }
            else
            {
              e.Cancel = true;
            }
            break;
          }
        default:
          break;
      }
    }

    private void TabProtocolReceive_Selecting(object sender, TabControlCancelEventArgs e)
    {
      if (!IsInit)
      {
        int index = e.TabPageIndex;
        switch (index)
        {
          // File
          case 0:
            {
              if (MessageBox.Show(Resources.DELETE_DATA_CURRENT_TAB, Resources.QUESTION, MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes)
              {
                dgvReceiveFile.Rows?.Clear();
              }
              else
              {
                e.Cancel = true;
              }
              break;
            }
          // Socket
          case 1:
            {
              if (MessageBox.Show(Resources.DELETE_DATA_CURRENT_TAB, Resources.QUESTION, MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes)
              {
                dgvReceiveSocket.Rows?.Clear();
              }
              else
              {
                e.Cancel = true;
              }
              break;
            }
          default:
            break;
        }
      }
    }

    private void TbcSettingProtocol_Selecting(object sender, TabControlCancelEventArgs e)
    {
      if (!IsInit)
      {
        int index = e.TabPageIndex;
        switch (index)
        {
          case 0:
            {
              if (MessageBox.Show(Resources.DELETE_DATA_CURRENT_TAB, Resources.QUESTION, MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes)
              {
                dgvSendFile.Rows?.Clear();
                dgvSendFTP.Rows?.Clear();
                dgvSendSocket.Rows?.Clear();
              }
              else
              {
                e.Cancel = true;
              }
              break;
            }
          case 1:
            {
              if (MessageBox.Show(Resources.DELETE_DATA_CURRENT_TAB, Resources.QUESTION, MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes)
              {
                dgvReceive.Rows?.Clear();
                dgvReceiveFile.Rows?.Clear();
                dgvReceiveSocket.Rows?.Clear();
              }
              else
              {
                e.Cancel = true;
              }
              break;
            }
          default:
            break;
        }
      }
    }

    private void SettingView_FormClosing(object sender, FormClosingEventArgs e)
    {
      if (HasFirstCancel)
      {
        if (MessageBox.Show(Resources.EXIT_APP, Text, MessageBoxButtons.OKCancel, MessageBoxIcon.Question) == DialogResult.Cancel)
        {
          e.Cancel = true;
        }
      }
    }

    private void BindValueControlToModel()
    {
      // Facility information
      txtCoopName.TextChanged += new EventHandler(TxtCoopName_TextChanged);
      txtCoopVender.TextChanged += new EventHandler(TxtVendorName_TextChanged);
      btnCoopCd.TextChanged += new EventHandler(BtnCoopCd_TextChanged);
      txtRootName.TextChanged += new EventHandler(TxtRootName_TextChanged);
      txtDescription.TextChanged += new EventHandler(TxtDescription_TextChanged);
      txtCoopFormat.TextChanged += new EventHandler(TxtCoopFormat_TextChanged);
      txtCtlNo.TextChanged += new EventHandler(TxtCtlNo_TextChanged);
      txtFacilityCd.TextChanged += new EventHandler(TxtFacilityCd_TextChanged);
    }

    private void TxtFacilityCd_TextChanged(object sender, EventArgs e)
    {
      this._controller.Tmodel.ItemInfo.FacilityCd = txtFacilityCd.Text;
    }

    private void TxtCtlNo_TextChanged(object sender, EventArgs e)
    {
      this._controller.Tmodel.ItemInfo.CtlNo = txtCtlNo.Text;
    }

    private void TxtCoopFormat_TextChanged(object sender, EventArgs e)
    {
      this._controller.Tmodel.ItemInfo.CoopFormat = txtCoopFormat.Text;
    }

    private void TxtDescription_TextChanged(object sender, EventArgs e)
    {
      this._controller.Tmodel.ItemInfo.Description = txtDescription.Text;
    }

    private void TxtRootName_TextChanged(object sender, EventArgs e)
    {
      this._controller.Tmodel.ItemInfo.CoopSetting = this._controller.Tmodel.ItemInfo.CoopSetting ?? new CoopSetting();
      this._controller.Tmodel.ItemInfo.CoopSetting.Name = txtRootName.Text;
    }

    private void BtnCoopCd_TextChanged(object sender, EventArgs e)
    {
      this._controller.Tmodel.ItemInfo.CoopCd = btnCoopCd.Text;
    }

    private void TxtVendorName_TextChanged(object sender, EventArgs e)
    {
      this._controller.Tmodel.ItemInfo.CoopVender = txtCoopVender.Text;
    }

    private void TxtCoopName_TextChanged(object sender, EventArgs e)
    {
      this._controller.Tmodel.ItemInfo.CoopName = txtCoopName.Text;
    }

    private void BtnSubmit_Click(object sender, EventArgs e)
    {
      bool IsValid = this.ValidateSubmit();
      if (IsValid)
      {
        GetValueElementGrid();
        this._controller.Tmodel.KeyModels = this.subKeyList;
        BindValueToModelOfProtocol();
        this._controller.OnSubmit(!IsItem);
      }
    }

    private void GetValueElementGrid()
    {
      List<ElementGrid> model = new List<ElementGrid>();
      foreach (DataGridViewRow row in dgvSettingElement.Rows)
      {
        model.Add(new ElementGrid()
        {
          Name = row.Cells[NO_NAME]?.Value?.ToString(),
          Len = row.Cells[LEN_NAME]?.Value?.ToString(),
          ItemType = row.Cells[ITEM_TYPE_NAME]?.Value?.ToString(),
          Key = row.Cells[KEY_NAME]?.Value?.ToString(),
          Col = row.Cells[COL_NAME]?.Value?.ToString(),
          Repeat = row.Cells[REPEAT_NAME]?.Value?.ToString(),
          Detail = row.Cells[DETAIL_NAME]?.Value?.ToString(),
          DataSet = row.Cells[DATA_SET_NAME]?.Value?.ToString(),
          SqlParam = row.Cells[SQL_PARAM_NAME]?.Value?.ToString(),
          Type = row.Cells[TYPE_NAME]?.Value?.ToString(),
          Term = row.Cells[TERM_NAME]?.Value?.ToString(),
          Value = row.Cells[VALUE_NAME]?.Value?.ToString(),
          Append = row.Cells[APPEND_NAME]?.Value?.ToString(),
          MessageLen = row.Cells[MESSAGE_LEN_NAME]?.Value?.ToString(),
          PaddingPosition = row.Cells[PADDING_POSITION_NAME]?.Value?.ToString(),
          PaddingFormat = row.Cells[PADDING_FORMAT_NAME]?.Value?.ToString()
        });
      }
      this._controller.Tmodel.ElementGrids = model;
    }

    private void HandleBtnCancel()
    {
      this._controller.OnCancel();
    }

    private void BtnCancel_Click(object sender, EventArgs e)
    {
      if (MessageBox.Show(Resources.CANCEL_OR_RELOAD_CONFIRM, Text, MessageBoxButtons.OKCancel, MessageBoxIcon.Question) == DialogResult.OK)
      {
        HasFirstCancel = false;
        HandleBtnCancel();
      }
    }

    private void DgvSettingElement_EditingControlShowing(object sender, DataGridViewEditingControlShowingEventArgs e)
    {
      if (e.Control is ComboBox)
      {
        ComboBox cb = e.Control as ComboBox;
        if ((dgvSettingElement[DATA_SET_NAME, dgvSettingElement.CurrentCell.RowIndex].Value == null || string.IsNullOrEmpty(value: dgvSettingElement[DATA_SET_NAME, dgvSettingElement.CurrentCell.RowIndex].Value.ToString()))
          && dgvSettingElement.Columns[dgvSettingElement.CurrentCell.ColumnIndex].Name == SQL_PARAM_NAME)
        {
          cb.Items.Insert(0, string.Empty);
          cb.Items.Clear();
        }
        cb.SelectionChangeCommitted -= new EventHandler(CmbItemTypeCol_SelectedIndexChanged);
        cb.SelectionChangeCommitted -= new EventHandler(CmbDataSetCol_SelectedIndexChanged);
        cb.SelectionChangeCommitted -= new EventHandler(CmbTermColOrSqlParamCol_SelectedIndexChanged);
        if (((DataGridView)sender).Columns[dgvSettingElement.CurrentCell.ColumnIndex].Name == ITEM_TYPE_NAME && cb != null)
          cb.SelectionChangeCommitted += new EventHandler(CmbItemTypeCol_SelectedIndexChanged);
        else if (((DataGridView)sender).Columns[dgvSettingElement.CurrentCell.ColumnIndex].Name == DATA_SET_NAME && cb != null)
          cb.SelectionChangeCommitted += new EventHandler(CmbDataSetCol_SelectedIndexChanged);
        else if ((((DataGridView)sender).Columns[dgvSettingElement.CurrentCell.ColumnIndex].Name == TERM_NAME
          || ((DataGridView)sender).Columns[dgvSettingElement.CurrentCell.ColumnIndex].Name == SQL_PARAM_NAME
          || ((DataGridView)sender).Columns[dgvSettingElement.CurrentCell.ColumnIndex].Name == APPEND_NAME
          || ((DataGridView)sender).Columns[dgvSettingElement.CurrentCell.ColumnIndex].Name == MESSAGE_LEN_NAME) && cb != null)
          cb.SelectionChangeCommitted += new EventHandler(CmbTermColOrSqlParamCol_SelectedIndexChanged);
      }
      if (e.Control is TextBox)
      {
        TextBox tb = e.Control as TextBox;
        editingBox = tb;
        if ((((DataGridView)sender).Columns[dgvSettingElement.CurrentCell.ColumnIndex].Name == REPEAT_NAME
          || ((DataGridView)sender).Columns[dgvSettingElement.CurrentCell.ColumnIndex].Name == "Len")
           && tb != null)
        {
          tb.TextChanged += new EventHandler(this.TextBoxColumn_TextChanged);
          tb.KeyPress += new KeyPressEventHandler(TextBoxColumn_KeyPress);
        }
      }
    }

    private void CmbTermColOrSqlParamCol_SelectedIndexChanged(object sender, EventArgs e)
    {
      ComboBox cbb = sender as ComboBox;
      if (cbb.SelectedItem?.ToString() == EmptyTitle)
      {
        cbb.Items.Insert(0, string.Empty);
        cbb.SelectedIndex = 0;
        cbb.Items.Remove(string.Empty);
      }
      else
      {
        if (dgvSettingElement.Columns[dgvSettingElement.CurrentCell.ColumnIndex].Name == SQL_PARAM_NAME)
        {
          DataGridViewTextBoxCell dataGridViewTextBoxCell = (DataGridViewTextBoxCell)dgvSettingElement[VALUE_NAME, dgvSettingElement.CurrentCell.RowIndex];
          DataGridViewComboBoxCell dataSetControl = (DataGridViewComboBoxCell)dgvSettingElement[DATA_SET_NAME, dgvSettingElement.CurrentCell.RowIndex];
          if (!string.IsNullOrEmpty(dataSetControl.Value as string))
          {
            dataGridViewTextBoxCell.Value = $"dataset:{(dataSetControl.Value?.ToString()).Split('-')[0].Trim()}.{cbb.SelectedItem?.ToString()}";
          }
        }
      }
    }

    private void CmbItemTypeCol_SelectedIndexChanged(object sender, EventArgs e)
    {
      HandleEnableRowCell(dgvSettingElement.CurrentCell.RowIndex);
      if (dgvSettingElement[ITEM_TYPE_NAME, dgvSettingElement.CurrentCell.RowIndex].EditedFormattedValue.ToString() == ITEM_TYPE)
      {
        string keyhide = dgvSettingElement["KeyHide", dgvSettingElement.CurrentCell.RowIndex].Value == null ? string.Empty : dgvSettingElement["KeyHide", dgvSettingElement.CurrentCell.RowIndex].Value.ToString();
        dgvSettingElement[KEY_NAME, dgvSettingElement.CurrentCell.RowIndex].Value = keyhide;
      }
    }

    private void CmbDataSetCol_SelectedIndexChanged(object sender, EventArgs e)
    {
      ComboBox cbb = sender as ComboBox;
      if (cbb.SelectedItem?.ToString() == EmptyTitle)
      {
        cbb.Items.Insert(0, string.Empty);
        cbb.SelectedIndex = 0;
        cbb.Items.Remove(string.Empty);
      }
      if (cbb.SelectedIndex > 0)
      {
        var dataSetInfo = this._controller.Tmodel.ListDataSet[cbb.SelectedIndex - 1];
        DataGridViewComboBoxCell colSqlParam = (DataGridViewComboBoxCell)dgvSettingElement[SQL_PARAM_NAME, dgvSettingElement.CurrentCell.RowIndex];
        colSqlParam.Items.Clear();
        colSqlParam.Items.Add(Resources.BLANK_VALUE);
        List<string> dataCodes = new List<string>();
        var dicData = dataSetInfo.DetailInfo?.Details ?? new List<Dictionary<string, object>>();
        dicData.ForEach(item =>
        {
          string val = item[DATA_CODE_NAME] as string;
          if (!string.IsNullOrEmpty(val))
          {
            dataCodes.Add(val);
          }
        });
        colSqlParam.Items.AddRange(dataCodes.OrderBy(i => i).ToArray());
      }
    }

    private void TextBoxColumn_KeyPress(object sender, KeyPressEventArgs e)
    {
      if (!char.IsControl(e.KeyChar) && !char.IsDigit(e.KeyChar))
      {
        e.Handled = true;
      }
    }

    private void TextBoxColumn_TextChanged(object sender, EventArgs e)
    {
      TextBox tb = sender as TextBox;
      string temp = tb.Text;
      foreach (char c in tb.Text.ToCharArray())
      {
        if (!(c >= '0' && c <= '9'))
        {
          temp = temp.Replace($"{c}", "");
        }
      }
      tb.Text = temp;
    }

    private void DgvSettingElement_CellEndEdit(object sender, DataGridViewCellEventArgs e)
    {
      if (editingBox != null)
      {
        editingBox.TextChanged -= new EventHandler(this.TextBoxColumn_TextChanged);
        editingBox.KeyPress -= new KeyPressEventHandler(TextBoxColumn_KeyPress);
        editingBox = null;
      }
      string editValue = dgvSettingElement[e.ColumnIndex, e.RowIndex].Value == null ? string.Empty : dgvSettingElement[e.ColumnIndex, e.RowIndex].Value.ToString();
      if (oldValue != editValue)
        countEdit++;
    }

    public void HandleEnableRowCell(int row)
    {
      ArrayList colNameArray = new ArrayList();
      if (dgvSettingElement[ITEM_TYPE_NAME, row].EditedFormattedValue.ToString() == ITEM_TYPE)
        colNameArray = new ArrayList() { REPEAT_NAME };
      else if (dgvSettingElement[ITEM_TYPE_NAME, row].EditedFormattedValue.ToString() == OCC_TYPE)
        colNameArray = new ArrayList() { KEY_NAME, TERM_NAME };
      for (int i = 0; i < dgvSettingElement.Columns.Count; i++)
      {
        if (colNameArray.IndexOf(dgvSettingElement.Columns[i].Name) != -1 && dgvSettingElement.Columns[i].Name != "No1"
          && dgvSettingElement.Columns[i].Name == colNameArray[colNameArray.IndexOf(dgvSettingElement.Columns[i].Name)].ToString())
        {
          dgvSettingElement[i, row].Style.BackColor = SystemColors.AppWorkspace;
          dgvSettingElement[i, row].ReadOnly = true;
          dgvSettingElement[i, row].Value = string.Empty;
        }
        else if (dgvSettingElement.Columns[i].Name != "No1")
        {
          dgvSettingElement[i, row].Style.BackColor = Color.Empty;
          dgvSettingElement[i, row].ReadOnly = false;
        }
      }
    }

    public void HandleEnableAllRowCell()
    {
      for (int i = 0; i < dgvSettingElement.RowCount; i++)
      {
        HandleEnableRowCell(i);
      }
    }

    public void AddNodeToListView<TType>(TType nodeType, MstCoopLayoutEntity entity)
    {
      entity = entity ?? new MstCoopLayoutEntity();
      entity.CoopSetting = entity.CoopSetting ?? new CoopSetting()
      {
        ItemList = new List<CoopSettingItemList>()
      };
      dynamic nodeNew = nodeType;
      TreeNode newNodeRoot = new TreeNode { Name = ROOT, Text = entity?.CoopSetting?.Name };
      nodeNew.Nodes.Add(newNodeRoot);
      TreeNode itemNode = new TreeNode { Name = ITEM_TYPE, Text = "item" };
      TreeNode occNode = new TreeNode { Name = OCC_TYPE, Text = "occ" };
      newNodeRoot.Nodes.Add(itemNode);
      newNodeRoot.Nodes.Add(occNode);

      // Item
      foreach (string item in entity.CoopExtSetting.Key.Keys)
      {
        TreeNode newNodeParent = new TreeNode { Name = item, Text = item };
        itemNode.Nodes.Add(newNodeParent);
      }

      // Occ
      entity.CoopSetting.ItemList = entity?.CoopSetting.ItemList ?? new List<CoopSettingItemList>();
      foreach (var item in entity?.CoopSetting.ItemList)
      {
        if (item.Occ)
        {
          TreeNode newNodeParent = new TreeNode { Name = item.Name, Text = item.Name };
          occNode.Nodes.Add(newNodeParent);
        }
      }
    }

    private void BtnType_Click(object sender, EventArgs e)
    {
      _controller.LoadCoopCdType();
      OpenTypeView(_controller.Tmodel.CoopCdTypeList);
    }

    public void OpenTypeView(List<CoopCdTypeModel> data)
    {
      CoopCdTypeView typeView = new CoopCdTypeView(data);
      typeView.FormClosed += new FormClosedEventHandler(TypeView_FormClosed);
      typeView.ShowDialog();
    }

    private void DgvSettingElement_CellEnter(object sender, DataGridViewCellEventArgs e)
    {
      bool validClick = (e.RowIndex != -1 && e.ColumnIndex != -1);
      var datagridview = sender as DataGridView;
      if (datagridview.Columns[e.ColumnIndex] is DataGridViewComboBoxColumn && validClick)
      {
        datagridview.BeginEdit(true);
        if ((ComboBox)datagridview.EditingControl != null)
          ((ComboBox)datagridview.EditingControl).DroppedDown = true;
      }
    }

    private void TypeView_FormClosed(object sender, FormClosedEventArgs e)
    {
      CoopCdTypeView form = sender as CoopCdTypeView;
      if (!form.IsClickCloseOnWindow)
      {
        var item = form.SelectedItem;
        if (item != null)
        {
          this.btnCoopCd.Text = item.Code;
        }
      }
      form.Dispose();
    }

    private void DgvSettingElement_CellClick(object sender, DataGridViewCellEventArgs e)
    {
      if (e.RowIndex > -1 && e.ColumnIndex == dgvSettingElement.Columns[KEY_NAME].Index && dgvSettingElement[ITEM_TYPE_NAME, dgvSettingElement.CurrentCell.RowIndex].Value.ToString() == ITEM_TYPE)
      {
        string key = dgvSettingElement[KEY_NAME, dgvSettingElement.CurrentCell.RowIndex].Value == null ? string.Empty : dgvSettingElement[KEY_NAME, dgvSettingElement.CurrentCell.RowIndex].Value.ToString();
        EditKeyView editKeyView = new EditKeyView(subKeyList, key);
        editKeyView.FormClosed += new FormClosedEventHandler(EditKeyView_FormClosed);
        editKeyView.ShowDialog();
      }
    }

    private void EditKeyView_FormClosed(object sender, FormClosedEventArgs e)
    {
      EditKeyView form = sender as EditKeyView;
      if (!form.IsClickCloseOnWindow)
      {
        var item = form.SubKeyList;
        if (item != null)
        {
          subKeyList = form.SubKeyList;
          string oldKey = dgvSettingElement[KEY_NAME, dgvSettingElement.CurrentCell.RowIndex].Value == null ? string.Empty : dgvSettingElement[KEY_NAME, dgvSettingElement.CurrentCell.RowIndex].Value.ToString();
          dgvSettingElement[KEY_NAME, dgvSettingElement.CurrentCell.RowIndex].Value = form.KeyNameEdit;
          dgvSettingElement["KeyHide", dgvSettingElement.CurrentCell.RowIndex].Value = form.KeyNameEdit;
        }
      }
      form.Dispose();
    }

    public void BindValueFacilityInformation(MstCoopLayoutEntity entity)
    {
      txtCoopName.Text = entity?.CoopName;
      txtCoopVender.Text = entity?.CoopVender;
      btnCoopCd.Text = entity?.CoopCd;
      txtCoopFormat.Text = entity?.CoopFormat;
      txtCtlNo.Text = entity?.CtlNo;
      txtDescription.Text = entity?.Description;
      txtFacilityCd.Text = entity?.FacilityCd;
    }

    public void BindValueListElementKey(MstCoopLayoutEntity entity)
    {
      txtRootName.Text = entity?.CoopSetting?.Name;
      if (entity != null && entity.CoopExtSetting?.Key?.Keys != null)
      {
        trvGraph.Nodes.Clear();
        AddNodeToListView(trvGraph, entity);
      }
    }

    private void TrvGraph_NodeMouseDoubleClick(object sender, TreeNodeMouseClickEventArgs e)
    {
      string currentName = e.Node.Name;
      if (currentName == ROOT)
      {
        this._controller.LoadMstCoopLayoutByRoot();
      }
      else
      if (currentName != ITEM_TYPE && currentName != OCC_TYPE)
      {
        var nodes = e.Node.FullPath.Split('\\');
        if (nodes.Length > 2)
        {
          if (nodes[1] == ITEM_TYPE)
          {
            this._controller.LoadMstCoopLayoutByItem(currentName);
          }
          else if (nodes[1] == OCC_TYPE)
          {
            this._controller.LoadMstCoopLayoutByOcc(currentName);
          }
        }
      }
    }

    private delegate void ClearDataGridCallBack();

    private void ClearDataGrid()
    {
      if (dgvSettingElement.InvokeRequired)
      {
        ClearDataGridCallBack callback = new ClearDataGridCallBack(ClearDataGrid);
        this.Invoke(callback);
      }
      else
      {
        dgvSettingElement.Rows.Clear();
      }
    }

    private delegate void BindValueGridViewSettingElementCallBack(List<CoopSettingItemList> data, List<SysDataSetEntity> dataSet);

    public void BindValueGridViewSettingElement(List<CoopSettingItemList> data, List<SysDataSetEntity> dataSet)
    {
      if (dgvSettingElement.InvokeRequired)
      {
        BindValueGridViewSettingElementCallBack callback = new BindValueGridViewSettingElementCallBack(BindValueGridViewSettingElement);
        this.Invoke(callback, new object[] { data, dataSet });
      }
      else
      {
        string[] boolArray = { EmptyTitle, "true", "false" };
        DataGridViewComboBoxColumn colItemType = (DataGridViewComboBoxColumn)dgvSettingElement.Columns[ITEM_TYPE_NAME];
        colItemType.DataSource = new string[] { "item", "occ" };
        DataGridViewComboBoxColumn colTerm = (DataGridViewComboBoxColumn)dgvSettingElement.Columns[TERM_NAME];
        colTerm.Items.Clear();
        colTerm.Items.AddRange(boolArray);
        DataGridViewComboBoxColumn colAppend = (DataGridViewComboBoxColumn)dgvSettingElement.Columns[APPEND_NAME];
        colAppend.Items.Clear();
        colAppend.Items.AddRange(boolArray);
        DataGridViewComboBoxColumn colMessageLen = (DataGridViewComboBoxColumn)dgvSettingElement.Columns[MESSAGE_LEN_NAME];
        colMessageLen.Items.Clear();
        colMessageLen.Items.AddRange(boolArray);
        BindDataDataSet(dataSet);
        data = data ?? new List<CoopSettingItemList>();
        int index = 1;
        ClearDataGrid();
        data.ForEach(item =>
        {
          string no1 = $"{index++}";
          string name = item.Name;
          string len = $"{item.Len}";
          string type = item.Type;
          string itemType = item.ItemType;
          string key = item.Key;
          string col = item.Col;
          string repeat = item.Repeat;
          string detail = item.Detail;
          string dataset = item.DataSet;
          string sqlParam = item.SqlParam;
          string term = $"{item.Term}";
          string value = item.Value;
          string append = item.Append.ToString();
          string messageLen = item.MessageLen.ToString();
          string paddingPosition = item.PaddingPosition;
          string paddingFormat = item.PaddingFormat;
          string keyhide = item.Key;
          if (item.Occ)
          {
            itemType = "occ";
            key = "";
          }
          else
          {
            itemType = "item";
          }
          dgvSettingElement.Rows.Add(no1, name, len, type, itemType, key, col, repeat, detail, dataset, sqlParam, term, value, append, messageLen, paddingPosition, paddingFormat, keyhide);
        });
        int totalWidth = 0;
        int gridviewWidth = dgvSettingElement.Width;
        foreach (DataGridViewColumn column in dgvSettingElement.Columns)
        {
          column.AutoSizeMode = DataGridViewAutoSizeColumnMode.AllCells;
          totalWidth += column.Width;
          column.Width = column.Width;
          column.AutoSizeMode = DataGridViewAutoSizeColumnMode.NotSet;
        }
        if (totalWidth < gridviewWidth)
        {
          foreach (DataGridViewColumn column in dgvSettingElement.Columns)
          {
            column.AutoSizeMode = DataGridViewAutoSizeColumnMode.Fill;
            totalWidth += column.Width;
            column.Width = column.Width;
            column.AutoSizeMode = DataGridViewAutoSizeColumnMode.NotSet;
          }
        }
      }
    }

    public void InitView()
    {
      MstCoopLayoutEntity entity = this.MstCoopLayoutEntity;
      this._controller.LoadDataSet();
      BindValueFacilityInformation(entity);
      BindValueListElementKey(entity);
      if (entity != null)
      {
        coopExtSetting = entity.CoopExtSetting?.Key ?? new Dictionary<string, Dictionary<string, string>>();
        subKeyList = ConvertToSubKeyObject(coopExtSetting);
      }
      this._controller.LoadProtocolInfo(entity.Direction);
    }

    public static List<SubKeyModel> ConvertToSubKeyObject(Dictionary<string, Dictionary<string, string>> coopExtSetting)
    {
      List<SubKeyModel> subkeyList = new List<SubKeyModel>();
      if (coopExtSetting != null)
      {
        foreach (var item in coopExtSetting)
        {
          SubKeyModel subkey = new SubKeyModel();
          List<KeyValue> keyValueList = new List<KeyValue>();
          foreach (var subItem in item.Value)
          {
            KeyValue keyValue = new KeyValue
            {
              KeyName = subItem.Key,
              Value = subItem.Value
            };
            keyValueList.Add(keyValue);
          }
          subkey.KeyName = item.Key;
          subkey.ValueList = keyValueList;
          subkeyList.Add(subkey);
        }
      }
      return subkeyList;
    }

    private void BtnSettingElementDelete_Click(object sender, EventArgs e)
    {
      if (dgvSettingElement.Rows.Count > 0 && dgvSettingElement.SelectedRows.Count > 0 && MessageBox.Show(Resources.DELETE_CONFIRM, Text, MessageBoxButtons.OKCancel, MessageBoxIcon.Question) == DialogResult.OK)
      {
        string key = dgvSettingElement["KeyHide", dgvSettingElement.CurrentCell.RowIndex].Value == null ? string.Empty : dgvSettingElement["KeyHide", dgvSettingElement.CurrentCell.RowIndex].Value.ToString();
        var item = subKeyList.Find(x => x.KeyName == key);
        if (item != null)
          subKeyList.Remove(item);
        dgvSettingElement.Rows.RemoveAt(dgvSettingElement.CurrentCell.RowIndex);
        UpdateNumberNo1();
      }
    }

    private void BtnSettingElementAddNew_Click(object sender, EventArgs e)
    {
      string key = string.Empty;
      if (dgvSettingElement.RowCount > 0)
        key = dgvSettingElement[NO_NAME, dgvSettingElement.RowCount - 1].Value == null ? string.Empty : dgvSettingElement[NO_NAME, dgvSettingElement.RowCount - 1].Value.ToString();
      if (dgvSettingElement.RowCount == 0 || !string.IsNullOrEmpty(key.Trim()))
      {
        this.dgvSettingElement.Rows.Add();
        dgvSettingElement["No1", dgvSettingElement.RowCount - 1].Value = dgvSettingElement.RowCount;
        dgvSettingElement[ITEM_TYPE_NAME, dgvSettingElement.RowCount - 1].Value = "item";
        HandleEnableRowCell(dgvSettingElement.RowCount - 1);
      }
      if (dgvSettingElement.RowCount > 0)
      {
        dgvSettingElement.FirstDisplayedScrollingRowIndex = dgvSettingElement.RowCount - 1;
        dgvSettingElement.CurrentCell = dgvSettingElement[NO_NAME, dgvSettingElement.RowCount - 1];
      }
    }

    public void UpdateNumberNo1()
    {
      if (dgvSettingElement.Rows.Count > 0)
      {
        int rowValue = 1;
        for (int i = 0; i < dgvSettingElement.RowCount; i++)
        {
          dgvSettingElement["No1", i].Value = rowValue++;
        }
      }
    }

    private void BtnSettingElementReset_Click(object sender, EventArgs e)
    {
      if (MessageBox.Show(Resources.CANCEL_OR_RELOAD_CONFIRM, Text, MessageBoxButtons.OKCancel, MessageBoxIcon.Question) == DialogResult.OK)
      {
        BindValueGridViewSettingElement(this._controller.Tmodel.ItemInfoBackup.CoopSetting.ItemList, this._controller.Tmodel.ListDataSetBackup);
        subKeyList = ConvertToSubKeyObject(coopExtSetting);
        HandleEnableAllRowCell();
        btnSettingElementDelete.Enabled = false;
      }
    }

    private void DgvSettingElement_RowStateChanged(object sender, DataGridViewRowStateChangedEventArgs e)
    {
      btnSettingElementDelete.Enabled = (dgvSettingElement.RowCount > 0);
    }

    private void DgvSettingElement_DataError(object sender, DataGridViewDataErrorEventArgs e)
    {
      e.Cancel = true;
    }

    private void DgvSettingElement_CurrentCellDirtyStateChanged(object sender, EventArgs e)
    {
      if (dgvSettingElement.IsCurrentCellDirty)
      {
        dgvSettingElement.CommitEdit(DataGridViewDataErrorContexts.Commit);
      }
    }

    private void DgvSettingElement_CellBeginEdit(object sender, DataGridViewCellCancelEventArgs e)
    {
      oldValue = dgvSettingElement[e.ColumnIndex, e.RowIndex].Value == null ? string.Empty : dgvSettingElement[e.ColumnIndex, e.RowIndex].Value.ToString();
    }

    private void DgvSettingElement_SelectionChanged(object sender, EventArgs e)
    {
      btnSettingElementDelete.Enabled = (dgvSettingElement.SelectedRows.Count > 0);
    }

    public void BindDataDataSet(List<SysDataSetEntity> dataSet)
    {
      DataGridViewComboBoxColumn columnDataSet = dgvSettingElement.Columns[DATA_SET_NAME] as DataGridViewComboBoxColumn;
      columnDataSet.Items.Clear();
      columnDataSet.Items.Add(EmptyTitle);
      dataSet = dataSet ?? new List<SysDataSetEntity>();
      foreach (var item in dataSet)
      {
        columnDataSet.Items.Add(item.TextDisplay);
      }
      foreach (DataGridViewRow row in dgvSettingElement.Rows)
      {
        DataGridViewComboBoxCell colDataSet = row.Cells[DATA_SET_NAME] as DataGridViewComboBoxCell;
        colDataSet.Value = EmptyTitle;
        colDataSet.Items.Clear();
        colDataSet.Items.Add(EmptyTitle);
        dataSet = dataSet ?? new List<SysDataSetEntity>();
        foreach (var item in dataSet)
        {
          colDataSet.Items.Add(item.TextDisplay);
        }
        DataGridViewComboBoxCell sqlParamCell = row.Cells[SQL_PARAM_NAME] as DataGridViewComboBoxCell;
        sqlParamCell.Value = EmptyTitle;
        sqlParamCell.Items?.Clear();
        sqlParamCell.Items?.Add(EmptyTitle);
      }
    }

    private delegate void AddRowDgvSendFileCallBack(MstCoopDistributeEntity entity, bool IsClear = true);

    private delegate void AddRowDgvSendFTPCallBack(MstCoopDistributeEntity entity, bool IsClear = true);

    private delegate void AddRowDgvSendSocketCallBack(MstCoopDistributeEntity entity, bool IsClear = true);

    private void AddRowDgvSendFile(MstCoopDistributeEntity entity, bool IsClear = true)
    {
      if (dgvSendFile.InvokeRequired)
      {
        AddRowDgvSendFileCallBack callback = new AddRowDgvSendFileCallBack(AddRowDgvSendFile);
        this.Invoke(callback, new object[] { entity, IsClear });
      }
      else
      {
        if (IsClear)
        {
          if (dgvSendFile?.Rows.Count > 1)
            dgvSendFile?.Rows?.Clear();
        }
        entity.DistributeSettingProtocol.ProtocolInfo = entity.DistributeSettingProtocol.ProtocolInfo ?? new DistributeProtocolInfo()
        {
          File = new Dictionary<string, string>()
        };
        entity.DistributeSettingProtocol.ProtocolInfo.File = entity.DistributeSettingProtocol?.ProtocolInfo?.File ?? new Dictionary<string, string>();
        if (entity.DistributeSettingProtocol?.ProtocolInfo?.File.Count > 0)
        {
          tabProtocolSend.SelectedIndex = 0;
        }
        foreach (var kv in entity.DistributeSettingProtocol?.ProtocolInfo?.File)
        {
          dgvSendFile.Rows.Add(kv.Key, kv.Value);
        }
      }
    }

    private void AddRowDgvSendFTP(MstCoopDistributeEntity entity, bool IsClear = true)
    {
      if (dgvSendFTP.InvokeRequired)
      {
        AddRowDgvSendFTPCallBack callback = new AddRowDgvSendFTPCallBack(AddRowDgvSendFTP);
        this.Invoke(callback, new object[] { entity, IsClear });
      }
      else
      {
        if (IsClear)
        {
          if (dgvSendFTP?.Rows.Count > 1)
            dgvSendFTP?.Rows?.Clear();
        }
        entity.DistributeSettingProtocol.ProtocolInfo = entity.DistributeSettingProtocol.ProtocolInfo ?? new DistributeProtocolInfo()
        {
          FTP = new Dictionary<string, string>()
        };
        entity.DistributeSettingProtocol.ProtocolInfo.FTP = entity.DistributeSettingProtocol?.ProtocolInfo?.File ?? new Dictionary<string, string>();
        if (entity.DistributeSettingProtocol?.ProtocolInfo?.FTP.Count > 0)
        {
          tabProtocolSend.SelectedIndex = 2;
        }
        foreach (var kv in entity.DistributeSettingProtocol?.ProtocolInfo?.FTP)
        {
          dgvSendFTP.Rows.Add(kv.Key, kv.Value);
        }
      }
    }

    private void AddRowDgvSendSocket(MstCoopDistributeEntity entity, bool IsClear = true)
    {
      if (dgvSendSocket.InvokeRequired)
      {
        AddRowDgvSendSocketCallBack callback = new AddRowDgvSendSocketCallBack(AddRowDgvSendSocket);
        this.Invoke(callback, new object[] { entity, IsClear });
      }
      else
      {
        if (IsClear)
        {
          if (dgvSendSocket?.Rows.Count > 1)
            dgvSendSocket?.Rows?.Clear();
        }
        entity.DistributeSettingProtocol.ProtocolInfo = entity.DistributeSettingProtocol.ProtocolInfo ?? new DistributeProtocolInfo()
        {
          Socket = new Dictionary<string, string>()
        };
        entity.DistributeSettingProtocol.ProtocolInfo.Socket = entity.DistributeSettingProtocol?.ProtocolInfo?.Socket ?? new Dictionary<string, string>();
        if (entity.DistributeSettingProtocol?.ProtocolInfo?.Socket.Count > 0)
        {
          tabProtocolSend.SelectedIndex = 1;
        }
        foreach (var kv in entity.DistributeSettingProtocol?.ProtocolInfo?.Socket)
        {
          dgvSendSocket.Rows.Add(kv.Key, kv.Value);
        }
      }
    }

    public void BindValueProtocolSend(MstCoopDistributeEntity entity)
    {
      this.tbcSettingProtocol.SelectedIndex = 1;
      entity = entity ?? new MstCoopDistributeEntity();
      AddRowDgvSendFile(entity);
      AddRowDgvSendFTP(entity);
      AddRowDgvSendSocket(entity);
    }

    private delegate void AddRowDgvReceiveCallBack(MstCoopFacilityEntity entity, bool IsClear = true);

    private delegate void AddRowDgvReceiveSocketCallBack(MstCoopFacilityEntity entity, bool IsClear = true);

    private delegate void AddRowDgvReceiveFileCallBack(MstCoopFacilityEntity entity, bool IsClear = true);

    private void AddRowDgvReceive(MstCoopFacilityEntity entity, bool IsClear = true)
    {
      if (dgvReceive.InvokeRequired)
      {
        AddRowDgvReceiveCallBack callback = new AddRowDgvReceiveCallBack(AddRowDgvReceive);
        this.Invoke(callback, new object[] { entity, IsClear });
      }
      else
      {
        if (IsClear)
        {
          if (dgvReceive?.Rows.Count > 1)
            dgvReceive?.Rows?.Clear();
        }
        entity.IfEdgeSettingProtocol.ProtocolInfo = entity.IfEdgeSettingProtocol.ProtocolInfo ?? new IfEdgeSettingProtocolInfo()
        {
          Protocol = new Dictionary<string, string>()
        };
        entity.IfEdgeSettingProtocol.ProtocolInfo.Protocol = entity.IfEdgeSettingProtocol?.ProtocolInfo?.Protocol ?? new Dictionary<string, string>();
        foreach (var kv in entity.IfEdgeSettingProtocol?.ProtocolInfo?.Protocol)
        {
          dgvReceive.Rows.Add(kv.Key, kv.Value);
        }
      }
    }

    private void AddRowDgvReceiveSocket(MstCoopFacilityEntity entity, bool IsClear = true)
    {
      if (dgvReceiveSocket.InvokeRequired)
      {
        AddRowDgvReceiveSocketCallBack callback = new AddRowDgvReceiveSocketCallBack(AddRowDgvReceiveSocket);
        this.Invoke(callback, new object[] { entity, IsClear });
      }
      else
      {
        if (IsClear)
        {
          if (dgvReceiveSocket?.Rows.Count > 1)
            dgvReceiveSocket?.Rows?.Clear();
        }
        entity.IfEdgeSettingProtocol.ProtocolInfo = entity.IfEdgeSettingProtocol.ProtocolInfo ?? new IfEdgeSettingProtocolInfo()
        {
          Socket = new Dictionary<string, string>()
        };
        entity.IfEdgeSettingProtocol.ProtocolInfo.Socket = entity.IfEdgeSettingProtocol?.ProtocolInfo?.Socket ?? new Dictionary<string, string>();
        if (entity.IfEdgeSettingProtocol?.ProtocolInfo?.Socket.Count > 0)
        {
          tabProtocolReceive.SelectedIndex = 1;
        }
        foreach (var kv in entity.IfEdgeSettingProtocol?.ProtocolInfo?.Socket)
        {
          dgvReceiveSocket.Rows.Add(kv.Key, kv.Value);
        }
      }
    }

    private void AddRowDgvReceiveFile(MstCoopFacilityEntity entity, bool IsClear = true)
    {
      if (dgvReceiveFile.InvokeRequired)
      {
        AddRowDgvReceiveFileCallBack callback = new AddRowDgvReceiveFileCallBack(AddRowDgvReceiveFile);
        this.Invoke(callback, new object[] { entity, IsClear });
      }
      else
      {
        if (IsClear)
        {
          if (dgvReceiveFile?.Rows.Count > 1)
            dgvReceiveFile?.Rows?.Clear();
        }
        entity.IfEdgeSettingProtocol.ProtocolInfo = entity.IfEdgeSettingProtocol.ProtocolInfo ?? new IfEdgeSettingProtocolInfo()
        {
          File = new Dictionary<string, string>()
        };
        entity.IfEdgeSettingProtocol.ProtocolInfo.File = entity.IfEdgeSettingProtocol?.ProtocolInfo?.File ?? new Dictionary<string, string>();
        if (entity.IfEdgeSettingProtocol?.ProtocolInfo?.File.Count > 0)
        {
          tabProtocolReceive.SelectedIndex = 0;
        }
        foreach (var kv in entity.IfEdgeSettingProtocol?.ProtocolInfo?.File)
        {
          dgvReceiveFile.Rows.Add(kv.Key, kv.Value);
        }
      }
    }

    public void BindValueProtocolReceive(MstCoopFacilityEntity entity)
    {
      this.tbcSettingProtocol.SelectedIndex = 0;
      entity = entity ?? new MstCoopFacilityEntity();
      AddRowDgvReceive(entity);
      AddRowDgvReceiveFile(entity);
      AddRowDgvReceiveSocket(entity);
    }

    private delegate void SetTextLoadingCallback(string text);

    private void SetTextLoading(string text)
    {
      if (lblLoading.InvokeRequired)
      {
        SetTextLoadingCallback callback = new SetTextLoadingCallback(SetTextLoading);
        this.Invoke(callback, new object[] { text });
      }
      else
      {
        lblLoading.Text = text;
        lblLoading.Refresh();
      }
    }

    public void RunLoading()
    {
      this.lblLoading.Visible = true;
      Task.Run(() =>
      {
        while (true)
        {
          if (this.lblLoading.Visible)
          {
            SetTextLoading(Resources.WAITING_FOR_EXECUTED);
            Task.Delay(1000);
            SetTextLoading($"{Resources.WAITING_FOR_EXECUTED} .");
            Task.Delay(1000);
            SetTextLoading($"{Resources.WAITING_FOR_EXECUTED} . . ");
            Task.Delay(1000);
            SetTextLoading($"{Resources.WAITING_FOR_EXECUTED} . . .");
          }
          else
          {
            return;
          }
        }
      });
    }

    public void StopLoading()
    {
      this.lblLoading.Visible = false;
    }

    public void SetMstCoopLayoutEntity(MstCoopLayoutEntity entity)
    {
      IsItem = true;
      SetEnableControl();
      this.MstCoopLayoutEntity = entity;
    }

    public void SetMstCoopLayoutEntityRoot(MstCoopLayoutEntity entity)
    {
      IsItem = true;
      SetEnableControl();
      this._controller.Tmodel.MstCoopLayoutEntityRoot = entity;
    }

    public bool ValidateSubmit()
    {
      bool IsValid = true;
      if (string.IsNullOrEmpty(btnCoopCd.Text))
      {
        this.ShowMessage(Resources.COOP_CD_INVALID, Resources.WARNING, Enums.MessageTypeEnum.WARNING);
        btnCoopCd.Focus();
        return false;
      }
      if (string.IsNullOrEmpty(txtRootName.Text))
      {
        txtRootName.Focus();
        this.ShowMessage(Resources.ROOT_NAME_INVALID, Resources.WARNING, Enums.MessageTypeEnum.WARNING);
        return false;
      }
      return IsValid;
    }

    public void OnSubmit(bool isSuccess = true)
    {
      if (isSuccess)
      {
        HasFirstCancel = false;
        this._controller.OnCancel();
      }
    }

    private void SetEnableControl(bool status = true)
    {
      txtCoopFormat.Enabled = status;
      txtCoopVender.Enabled = status;
      txtCoopName.Enabled = status;
      txtDescription.Enabled = status;
      btnCoopCd.Enabled = status;
    }

    public void SetMstCoopLayoutDetailEntity(MstCoopLayoutDetailEntity entity)
    {
      SetMstCoopLayoutEntity(new MstCoopLayoutEntity()
      {
        CoopCd = entity?.CoopCd,
        CoopExtSetting = entity?.CoopExtSetting,
        CtlNo = entity?.CtlNo,
        Description = entity?.Description,
        Direction = entity?.Direction,
        FacilityCd = entity?.FacilityCd,
        CoopName = entity?.CoopName,
        CoopCdSub = entity?.CoopCdDetailSub,
        CoopSetting = entity?.CoopSetting,
        CoopSettingString = entity?.CoopSettingString
      });
      IsItem = false;
      SetEnableControl(false);
    }
  }
}
