// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-20-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-23-2021
// ***********************************************************************
// <copyright file="CoopInstallView.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.App.Controllers;
using CoopSettingTool.App.Dialogues;
using CoopSettingTool.App.Models;
using CoopSettingTool.Service.Models;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace CoopSettingTool.App.Views
{
    /// <summary>
    /// Class CoopInstallView.
    /// Implements the <see cref="CoopSettingTool.App.Views.BaseView" />
    /// Implements the <see cref="CoopSettingTool.App.Views.ICoopInstallView" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Views.BaseView" />
    /// <seealso cref="CoopSettingTool.App.Views.ICoopInstallView" />
    public partial class CoopInstallView : BaseView, ICoopInstallView
    {
        /// <summary>
        /// The controller
        /// </summary>
        ICoopInstallController controller;

        /// <summary>
        /// The updating tree check state
        /// </summary>
        private bool updatingTreeCheckState;

        /// <summary>
        /// Initializes a new instance of the <see cref="CoopInstallView"/> class.
        /// </summary>
        /// <param name="model">The model.</param>
        public CoopInstallView(ICoopInstallModel model)
        {
            InitializeComponent();
            this.StartPosition = FormStartPosition.CenterParent;

            controller = new CoopInstallController(this, model);
            this.RegisterEvent();
        }

        /// <summary>
        /// Registers the event.
        /// </summary>
        private void RegisterEvent()
        {
            this.Shown += new EventHandler(OnFormShown);
            this.FormClosing += new FormClosingEventHandler(CoopInstallView_FormClosing);
            this.controller.Model.PropertyChanged += new PropertyChangedEventHandler(Model_PropertyChanged);

            this.btnCancel.Click += new EventHandler(BtnCancel_Click);
            this.btnSave.Click += new EventHandler(BtnSave_Click);

            this.tvCoopArtifact.AfterCheck += new TreeViewEventHandler(TvCoopArtifact_AfterCheck);

            this.cbShowFullCoop.CheckStateChanged += CbShowFullCoop_CheckStateChanged;
        }

        /// <summary>
        /// Handles the FormClosing event of the CoopInstallView control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="FormClosingEventArgs"/> instance containing the event data.</param>
        private void CoopInstallView_FormClosing(object sender, FormClosingEventArgs e)
        {
            this.controller.ClearData();
        }

        /// <summary>
        /// Handles the CheckStateChanged event of the CbShowFullCoop control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void CbShowFullCoop_CheckStateChanged(object sender, EventArgs e)
        {
            this.controller.LoadCoopFacilityArtifactsData(this.cbShowFullCoop.Checked);
        }

        /// <summary>
        /// Handles the AfterCheck event of the TvCoopArtifact control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="TreeViewEventArgs"/> instance containing the event data.</param>
        private void TvCoopArtifact_AfterCheck(object sender, TreeViewEventArgs e)
        {
            if (this.updatingTreeCheckState)
            {
                return;
            }

            RunUpdatingTreeCheckState(() =>
            {
                if (e.Node.Nodes.Count > 0)
                {
                    foreach (TreeNode childNode in e.Node.Nodes)
                    {
                        childNode.Checked = e.Node.Checked;
                    }
                }

                UpdateVenderNodeCheckStates();
            });

            UpdateSelectedArtifactIndices();

            if (!this.tvCoopArtifact.IsDisposed && this.tvCoopArtifact.IsHandleCreated)
            {
                this.tvCoopArtifact.BeginInvoke(new MethodInvoker(SynchronizeTreeCheckStates));
            }
        }

        /// <summary>
        /// Synchronizes the tree check states after the tree view completes its native check update.
        /// </summary>
        private void SynchronizeTreeCheckStates()
        {
            if (this.tvCoopArtifact.IsDisposed)
            {
                return;
            }

            RunUpdatingTreeCheckState(() =>
            {
                UpdateVenderNodeCheckStates();
            });

            UpdateSelectedArtifactIndices();
            this.tvCoopArtifact.Refresh();
        }

        /// <summary>
        /// Runs the action while suppressing recursive tree check events.
        /// </summary>
        /// <param name="action">The action.</param>
        private void RunUpdatingTreeCheckState(Action action)
        {
            bool previousUpdatingTreeCheckState = this.updatingTreeCheckState;
            this.updatingTreeCheckState = true;

            try
            {
                action();
            }
            finally
            {
                this.updatingTreeCheckState = previousUpdatingTreeCheckState;
            }
        }

        /// <summary>
        /// Updates the vendor node check states from child node check states.
        /// </summary>
        private void UpdateVenderNodeCheckStates()
        {
            foreach (TreeNode venderNode in this.tvCoopArtifact.Nodes)
            {
                bool checkedState = IsAnyChildNodeChecked(venderNode);
                if (venderNode.Checked != checkedState)
                {
                    venderNode.Checked = checkedState;
                }
            }
        }

        /// <summary>
        /// Determines whether any child node is checked.
        /// </summary>
        /// <param name="parentNode">The parent node.</param>
        /// <returns><c>true</c> if any child node is checked; otherwise, <c>false</c>.</returns>
        private bool IsAnyChildNodeChecked(TreeNode parentNode)
        {
            if (parentNode == null || parentNode.Nodes.Count == 0)
            {
                return false;
            }

            foreach (TreeNode childNode in parentNode.Nodes)
            {
                if (childNode.Checked)
                {
                    return true;
                }
            }

            return false;
        }

        /// <summary>
        /// Updates the selected artifact indices.
        /// </summary>
        private void UpdateSelectedArtifactIndices()
        {
            List<int> selectedIndices = new List<int>();

            foreach (TreeNode venderNode in this.tvCoopArtifact.Nodes)
            {
                foreach (TreeNode coopNameNode in venderNode.Nodes)
                {
                    if (coopNameNode.Checked && coopNameNode.Tag is int)
                    {
                        selectedIndices.Add((int)coopNameNode.Tag);
                    }
                }
            }

            this.controller.Model.SelectedArtifactIndices = selectedIndices;
            this.btnSave.Enabled = selectedIndices.Count > 0;
        }

        /// <summary>
        /// Handles the Click event of the BtnSave control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void BtnSave_Click(object sender, EventArgs e)
        {
            this.controller.SaveData();
        }

        /// <summary>
        /// Handles the Click event of the BtnCancel control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void BtnCancel_Click(object sender, EventArgs e)
        {
            this.CloseView(System.Windows.Forms.DialogResult.Cancel);
        }

        /// <summary>
        /// Handles the PropertyChanged event of the Model control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="PropertyChangedEventArgs"/> instance containing the event data.</param>
        private void Model_PropertyChanged(object sender, PropertyChangedEventArgs e)
        {
            switch (e.PropertyName)
            {
                case "CoopFacilityArtifacts":
                    {
                        UpdateCoopFacilityArtifactsView();

                        break;
                    }
                case "Facility":
                    {
                        UpdateViewByFacility();
                        break;
                    }
            }
        }

        /// <summary>
        /// Delegate UpdateViewByFacilityCallback
        /// </summary>
        private delegate void UpdateViewByFacilityCallback();
        /// <summary>
        /// Updates the view by facility.
        /// </summary>
        private void UpdateViewByFacility()
        {
            if (this.lbFacName.InvokeRequired)
            {
                UpdateViewByFacilityCallback calback = new UpdateViewByFacilityCallback(UpdateViewByFacility);
                this.Invoke(calback);
            }
            else
            {
                if (this.controller.Model.Facility != null)
                {
                    this.lbFacName.Text = this.controller.Model.Facility.DisplayMember;
                }
            }
        }

        /// <summary>
        /// Delegate UpdateCoopFacilityArtifactsViewCallback
        /// </summary>
        private delegate void UpdateCoopFacilityArtifactsViewCallback();
        /// <summary>
        /// Updates the coop facility artifacts view.
        /// </summary>
        private void UpdateCoopFacilityArtifactsView()
        {
            if (this.tvCoopArtifact.InvokeRequired)
            {
                UpdateCoopFacilityArtifactsViewCallback calback = new UpdateCoopFacilityArtifactsViewCallback(UpdateCoopFacilityArtifactsView);
                this.Invoke(calback);
            }
            else
            {
                RunUpdatingTreeCheckState(() =>
                {
                    this.tvCoopArtifact.BeginUpdate();
                    this.tvCoopArtifact.Nodes.Clear();

                    try
                    {
                        Dictionary<string, TreeNode> venderNodes = new Dictionary<string, TreeNode>();
                        HashSet<int> selectedArtifactIndices = new HashSet<int>(this.controller.Model.SelectedArtifactIndices ?? new List<int>());

                        if (this.controller.Model.CoopFacilityArtifacts != null)
                        {
                            for (int i = 0; i < this.controller.Model.CoopFacilityArtifacts.Count; i++)
                            {
                                OrdCd coopOrdCd = GetCoopOrdCd(this.controller.Model.CoopFacilityArtifacts[i]);
                                if (coopOrdCd == null)
                                {
                                    continue;
                                }

                                string coopVender = string.IsNullOrWhiteSpace(coopOrdCd.CoopVender) ? "(ベンダ未設定)" : coopOrdCd.CoopVender;
                                string coopName = string.IsNullOrWhiteSpace(coopOrdCd.CoopName) ? "(機能名未設定)" : coopOrdCd.CoopName;

                                if (!venderNodes.ContainsKey(coopVender))
                                {
                                    TreeNode venderNode = new TreeNode(coopVender);
                                    venderNodes.Add(coopVender, venderNode);
                                    this.tvCoopArtifact.Nodes.Add(venderNode);
                                }

                                TreeNode coopNameNode = new TreeNode(coopName);
                                coopNameNode.Tag = i;
                                coopNameNode.Checked = selectedArtifactIndices.Contains(i);
                                venderNodes[coopVender].Nodes.Add(coopNameNode);
                            }
                        }

                        UpdateVenderNodeCheckStates();
                    }
                    finally
                    {
                        this.tvCoopArtifact.EndUpdate();
                    }
                });

                UpdateSelectedArtifactIndices();
            }
        }

        /// <summary>
        /// Gets the first coop order code.
        /// </summary>
        /// <param name="coopFacilityArtifact">The coop facility artifact.</param>
        /// <returns>The first coop order code.</returns>
        private OrdCd GetCoopOrdCd(MstCoopFacilityEntity coopFacilityArtifact)
        {
            if (coopFacilityArtifact == null || coopFacilityArtifact.CommonSettingObject == null)
            {
                return null;
            }

            JObject commonSettingObject = GetCommonSettingJObject(coopFacilityArtifact);
            JArray coopOrdCds = commonSettingObject["coop_ord_cd"] as JArray;
            if (coopOrdCds == null || coopOrdCds.Count == 0)
            {
                return null;
            }

            return CreateCoopOrdCd(coopOrdCds.FirstOrDefault());
        }

        /// <summary>
        /// Gets the common setting JSON object.
        /// </summary>
        /// <param name="coopFacilityArtifact">The coop facility artifact.</param>
        /// <returns>The common setting JSON object.</returns>
        private JObject GetCommonSettingJObject(MstCoopFacilityEntity coopFacilityArtifact)
        {
            if (coopFacilityArtifact == null || coopFacilityArtifact.CommonSettingObject == null)
            {
                return new JObject();
            }

            JObject commonSettingObject = coopFacilityArtifact.CommonSettingObject as JObject;
            if (commonSettingObject != null)
            {
                return (JObject)commonSettingObject.DeepClone();
            }

            string commonSetting = coopFacilityArtifact.CommonSettingObject as string;
            if (string.IsNullOrWhiteSpace(commonSetting))
            {
                commonSetting = coopFacilityArtifact.CommonSetting;
            }

            return ParseCommonSettingJObject(commonSetting);
        }

        /// <summary>
        /// Parses common setting JSON object.
        /// </summary>
        /// <param name="commonSetting">The common setting.</param>
        /// <returns>The common setting JSON object.</returns>
        private JObject ParseCommonSettingJObject(string commonSetting)
        {
            if (string.IsNullOrWhiteSpace(commonSetting) || commonSetting == "null")
            {
                return new JObject();
            }

            try
            {
                JToken commonSettingToken = JToken.Parse(commonSetting);
                if (commonSettingToken.Type == JTokenType.String)
                {
                    string commonSettingString = commonSettingToken.ToObject<string>();
                    if (string.IsNullOrWhiteSpace(commonSettingString))
                    {
                        return new JObject();
                    }

                    commonSettingToken = JToken.Parse(commonSettingString);
                }

                return commonSettingToken as JObject ?? new JObject();
            }
            catch (JsonReaderException)
            {
                return new JObject();
            }
        }

        /// <summary>
        /// Creates the coop order code from JSON token.
        /// </summary>
        /// <param name="coopOrdCdToken">The coop order code token.</param>
        /// <returns>The coop order code.</returns>
        private OrdCd CreateCoopOrdCd(JToken coopOrdCdToken)
        {
            if (coopOrdCdToken == null)
            {
                return null;
            }

            OrdCd coopOrdCd = coopOrdCdToken.ToObject<OrdCd>();
            if (coopOrdCd == null)
            {
                return null;
            }

            if (string.IsNullOrWhiteSpace(coopOrdCd.CoopVender))
            {
                coopOrdCd.CoopVender = GetJsonString(coopOrdCdToken, "coop_vender");
            }

            if (string.IsNullOrWhiteSpace(coopOrdCd.CoopName))
            {
                coopOrdCd.CoopName = GetJsonString(coopOrdCdToken, "coop_name");
            }

            return coopOrdCd;
        }

        /// <summary>
        /// Gets the JSON string value.
        /// </summary>
        /// <param name="token">The token.</param>
        /// <param name="propertyName">Name of the property.</param>
        /// <returns>The JSON string value.</returns>
        private string GetJsonString(JToken token, string propertyName)
        {
            if (token == null)
            {
                return null;
            }

            JToken valueToken = token[propertyName];
            if (valueToken == null || valueToken.Type == JTokenType.Null)
            {
                return null;
            }

            return valueToken.ToString();
        }

        /// <summary>
        /// Handles the <see cref="E:FormShown" /> event.
        /// </summary>
        /// <param name="sender">The sender.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void OnFormShown(object sender, EventArgs e)
        {
            LoadView();
        }

        /// <summary>
        /// Loads the view.
        /// </summary>
        private void LoadView()
        {
            this.controller.LoadCoopFacilityArtifactsData(this.cbShowFullCoop.Checked);
        }

        /// <summary>
        /// Shows the dialog.
        /// </summary>
        /// <param name="parent">The parent.</param>
        /// <param name="selectedFacility">The selected facility.</param>
        /// <returns>DialogResult.</returns>
        public DialogResult ShowDialog(IWin32Window parent, MstFacilityEntity selectedFacility)
        {
            this.controller.Model.Facility = selectedFacility;

            return this.ShowDialog(parent);
        }
    }
}
