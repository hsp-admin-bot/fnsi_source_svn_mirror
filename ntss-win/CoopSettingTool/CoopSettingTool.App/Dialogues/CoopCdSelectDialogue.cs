// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 07-14-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 07-14-2021
// ***********************************************************************
// <copyright file="CoopCdSelectDialogue.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.App.Views;
using CoopSettingTool.Service.Models;
using MaterialSkin.Controls;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Windows.Forms;

namespace CoopSettingTool.App.Dialogues
{
    /// <summary>
    /// Class CoopCdSelectDialogue.
    /// Implements the <see cref="MaterialSkin.Controls.MaterialForm" />
    /// </summary>
    /// <seealso cref="MaterialSkin.Controls.MaterialForm" />
    public partial class CoopCdSelectDialogue : BaseView
    {
        /// <summary>
        /// The selected coop CDS
        /// </summary>
        private string selectedCoopCds = null;

        /// <summary>
        /// Gets the selected coop CDS.
        /// </summary>
        /// <value>The selected coop CDS.</value>
        public string SelectedCoopCds { get => selectedCoopCds; }

        /// <summary>
        /// Initializes a new instance of the <see cref="CoopCdSelectDialogue"/> class.
        /// </summary>
        public CoopCdSelectDialogue()
        {
            InitializeComponent();
            this.StartPosition = FormStartPosition.CenterParent;

            List<string> coopCd = new List<string>();
            coopCd.Add("ini_dial");
            coopCd.Add("is_death");
            coopCd.Add("profile");
            coopCd.Add("ind_dial");
            coopCd.Add("ord_dial");
            coopCd.Add("accept");
            coopCd.Add("rst_dial");
            coopCd.Add("rep_dial");
            coopCd.Add("exam_rst");
            coopCd.Add("exam_ord");
            coopCd.Add("rad_ord");
            coopCd.Add("phy_ord");
            coopCd.Add("shot_ord");
            coopCd.Add("pre_ord");
            coopCd.Add("staff_mst");
            coopCd.Add("vit_cop");
            coopCd.Add("karte_ord");

            this.clbCoopCd.DataSource = coopCd;
        }

        /// <summary>
        /// Handles the Click event of the btnCancel control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.DialogResult = DialogResult.Cancel;
            this.Close();
        }

        /// <summary>
        /// Handles the Click event of the btnOk control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void btnOk_Click(object sender, EventArgs e)
        {
            List<CoopCdItem> coopCdItems = new List<CoopCdItem>();
            foreach(string coopCd in this.clbCoopCd.CheckedItems)
            {
                coopCdItems.Add(new CoopCdItem() { CoopCd = coopCd });
            }

            var settings = new JsonSerializerSettings
            {
                NullValueHandling = NullValueHandling.Ignore,
                MissingMemberHandling = MissingMemberHandling.Ignore
            };
            selectedCoopCds = JsonConvert.SerializeObject(coopCdItems, settings);

            this.DialogResult = DialogResult.OK;
            this.Close();
        }

        public DialogResult ShowDialog(IWin32Window parent, string selectedCoopCds)
        {
            this.selectedCoopCds = selectedCoopCds;


            return this.ShowDialog(parent);
        }

        /// <summary>
        /// Handles the Load event of the CoopCdSelectDialogue control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void CoopCdSelectDialogue_Load(object sender, EventArgs e)
        {
            List<CoopCdItem> coopCdItems = new List<CoopCdItem>();
            try
            {
                var settings = new JsonSerializerSettings
                {
                    NullValueHandling = NullValueHandling.Ignore,
                    MissingMemberHandling = MissingMemberHandling.Ignore,
                    TypeNameHandling = TypeNameHandling.Auto
                };
                coopCdItems = JsonConvert.DeserializeObject<List<CoopCdItem>>(this.selectedCoopCds, settings);
            }
            catch
            {
            }

            // 手書きCoopCdをマスターに追加する
            List<string> coopCd = (List<string>)this.clbCoopCd.DataSource;
            for (int i = 0; i < coopCdItems.Count; i++)
            {
                if(!coopCd.Contains(coopCdItems[i].CoopCd))
                {
                    coopCd.Add(coopCdItems[i].CoopCd);
                }
            }
            this.clbCoopCd.DataSource = null;
            this.clbCoopCd.DataSource = coopCd;

            // 現在のチェック状態表示する
            for (int i = 0; i < this.clbCoopCd.Items.Count; i++)
            {
                if (coopCdItems.Exists(x => x.CoopCd.Equals(this.clbCoopCd.Items[i])))
                {
                    this.clbCoopCd.SetItemCheckState(i, CheckState.Checked);
                }
                else
                {
                    this.clbCoopCd.SetItemCheckState(i, CheckState.Unchecked);
                }
            }
        }
    }
}
