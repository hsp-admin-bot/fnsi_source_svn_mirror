using LDT.APP.Controllers.Implements;
using LDT.APP.Controllers.Interfaces;
using LDT.APP.Models.Interfaces;
using LDT.APP.Properties;
using LDT.APP.Views.implements;
using LDT.APP.Views.Interfaces;
using LDT.SERVICE.Configuration;
using LDT.SERVICE.Enums;
using LDT.SERVICE.Interfaces;
using LDT.SERVICE.Models;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace LDT.APP.Views.Implements
{
  public partial class FacilityView : BaseView, IFacilityView
  {
    private IFacilityController _controller;

    public bool IsCancel { get; set; }

    private bool HasFirstCancel = true;

    public FacilityView(IFacilityModel model, IMstFacilityService service, IMstCoopLayoutService mstCoopLayoutService)
    {
      InitializeComponent();
      IFacilityController cont = new FacilityController(this, model, service, mstCoopLayoutService);
      this.SetController(cont);
      this.RegisterEvent();
    }

    public void HandleNextView(Form nextView)
    {
      if (nextView != null)
      {
        nextView.VisibleChanged += new EventHandler(NextView_VisibleChanged);
      }
    }

    private void NextView_VisibleChanged(object sender, EventArgs e)
    {
      dynamic nextView = sender as dynamic;
      if (nextView.IsCancel == true)
      {
        this.Show();
        this._controller.LoadFacilityData();
      }
    }

    private delegate void InitDataInComboboxCallBack(List<MstFacilityEntity> data);

    public void InitDataInCombobox(List<MstFacilityEntity> data)
    {
      data = data ?? new List<MstFacilityEntity>();
      if (this.cbbFacility.InvokeRequired)
      {
        InitDataInComboboxCallBack setAddDataToDropdownCallBack = new InitDataInComboboxCallBack(InitDataInCombobox);
        this.Invoke(setAddDataToDropdownCallBack, new object[] { data });
      }
      else
      {
        cbbFacility.Items.Clear();
        this.btnAddNew.Enabled = false;
        this.btnCopy.Enabled = false;
        this.btnUpdate.Enabled = false;
        this.LoadDataCoopLayout(new List<MstCoopLayoutEntity>());
        foreach (var item in data)
        {
          cbbFacility.Items.Add(item);
        }
        cbbFacility.DisplayMember = "DisplayMember";
        cbbFacility.ValueMember = "ValueMember";
      }
    }

    public void RegisterEvent()
    {
      btnCancel.Click += new EventHandler(BtnCancel_Click);
      btnUpdate.Click += new EventHandler(BtnUpdate_Click);
      btnAddNew.Click += new EventHandler(BtnAddNew_Click);
      btnCopy.Click += new EventHandler(BtnCopy_Click);
      this.cbbFacility.SelectedValueChanged += new EventHandler(CbbFacility_SelectedValueChanged);
      this.Shown += new EventHandler(OnFormShown);
      dgvCoopLayout.SelectionChanged += new EventHandler(DgvCoopLayout_SelectionChanged);
      this.btnReload.Click += new EventHandler(BtnReload_Click);
      this.FormClosing += new FormClosingEventHandler(FacilityView_FormClosing);
    }

    private void DgvCoopLayout_SelectionChanged(object sender, EventArgs e)
    {
      if (dgvCoopLayout.SelectedRows.Count == 1)
      {
        this._controller.Tmodel.MstCoopLayoutSelected = dgvCoopLayout.SelectedRows[0].DataBoundItem as MstCoopLayoutEntity;
        btnCopy.Enabled = true;
        btnUpdate.Enabled = true;
      }
      else
      {
        btnCopy.Enabled = false;
        btnUpdate.Enabled = false;
      }
    }

    private void BtnCopy_Click(object sender, EventArgs e)
    {
      _controller.Tmodel.MstCoopLayoutSelected.CtlNo = null;
      this._controller.OnCopy();
    }

    private void BtnAddNew_Click(object sender, EventArgs e)
    {
      this._controller.Tmodel.MstCoopLayoutSelected = new MstCoopLayoutEntity()
      {
        CtlNo = null,
        FacilityCd = this._controller.Tmodel.SelectItem.FacilityCd,
        CoopName = this._controller.Tmodel.SelectItem.FacilityName,
        Direction = DIRECTION.RECEIVE,
        CoopCdSub = AppSettingConfig.ApplicationConfigJSON.CONSTANT.COOP_SUB_CD_QUERIES
      };
      this._controller.OnAddNew();
    }

    private void FacilityView_FormClosing(object sender, FormClosingEventArgs e)
    {
      if (HasFirstCancel)
      {
        if (MessageBox.Show(Resources.EXIT_APP, Text, MessageBoxButtons.OKCancel, MessageBoxIcon.Question) == DialogResult.Cancel)
        {
          e.Cancel = true;
        }
      }
    }

    private void CbbFacility_SelectedValueChanged(object sender, EventArgs e)
    {
      if (this.cbbFacility.SelectedItem == null)
      {
        this.btnUpdate.Enabled = false;
        this.btnAddNew.Enabled = false;
        this.btnCopy.Enabled = false;
      }
      else
      {
        this.btnAddNew.Enabled = true;
        this._controller.Tmodel.SelectItem = this.cbbFacility.SelectedItem as MstFacilityEntity;
        this._controller.LoadCoopLayoutByFacilityInfo(this._controller.Tmodel.SelectItem);
      }
    }

    private void OnFormShown(object sender, EventArgs e)
    {
      this._controller.LoadFacilityData();
    }

    public void SetController(IFacilityController controller)
    {
      _controller = controller;
    }

    private void BtnReload_Click(object sender, EventArgs e)
    {
      this.btnUpdate.Enabled = false;
      this._controller.LoadFacilityData();
    }

    private void HandleBtnCancel()
    {
      this._controller.OnCancel();
    }

    private void BtnCancel_Click(object sender, EventArgs e)
    {
      HasFirstCancel = false;
      HandleBtnCancel();
    }

    private void BtnUpdate_Click(object sender, EventArgs e)
    {
      this._controller.OnUpdate();
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

    private delegate void LoadDataCoopLayoutCallback(List<MstCoopLayoutEntity> data);

    public void LoadDataCoopLayout(List<MstCoopLayoutEntity> data)
    {
      if (dgvCoopLayout.InvokeRequired)
      {
        LoadDataCoopLayoutCallback calback = new LoadDataCoopLayoutCallback(LoadDataCoopLayout);
        this.Invoke(calback, new object[] { data });
      }
      else
      {
        data = data ?? new List<MstCoopLayoutEntity>();
        lblCoopLayoutRecord.Text = $"{data.Count}";
        dgvCoopLayout.DataSource = data;
        dgvCoopLayout.Refresh();
      }
    }
  }
}
