// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 07-14-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-13-2022
// ***********************************************************************
// <copyright file="JsonEditDialog.cs" company="">
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
    public partial class JsonEditDialog : BaseView
    {
        /// <summary>
        /// The output json
        /// </summary>
        private string outputJson = null;

        /// <summary>
        /// Gets the output json.
        /// </summary>
        /// <value>The output json.</value>
        public string OutputJson { get => outputJson; }


        /// <summary>
        /// Initializes a new instance of the <see cref="CoopCdSelectDialogue" /> class.
        /// </summary>
        public JsonEditDialog()
        {
            InitializeComponent();
            this.StartPosition = FormStartPosition.CenterParent;
        }

        /// <summary>
        /// Handles the Click event of the btnCancel control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs" /> instance containing the event data.</param>
        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.DialogResult = DialogResult.Cancel;
            this.Close();
        }

        /// <summary>
        /// Handles the Click event of the btnOk control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs" /> instance containing the event data.</param>
        private void btnOk_Click(object sender, EventArgs e)
        {
            try
            {
                var item = JsonConvert.DeserializeObject(this.textBox1.Text);

                this.outputJson = JsonConvert.SerializeObject(item, Formatting.None);
            }
            catch
            {
                this.outputJson = string.Empty;
            }

            if (string.IsNullOrEmpty(this.outputJson))
            {
                MessageBox.Show(this, "JSONデータの形式は正しくないです。",　"エラー", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            else
            {
                this.DialogResult = DialogResult.OK;
                this.Close();
            }
        }

        /// <summary>
        /// Shows the dialog.
        /// </summary>
        /// <param name="parent">The parent.</param>
        /// <param name="inputJson">The input json.</param>
        /// <returns>DialogResult.</returns>
        public DialogResult ShowDialog(IWin32Window parent, string inputJson)
        {
            try
            {
                var item = JsonConvert.DeserializeObject(inputJson);

                this.textBox1.Text = JsonConvert.SerializeObject(item, Formatting.Indented);
            }
            catch
            {
                this.textBox1.Text = inputJson;
            }
            return this.ShowDialog(parent);
        }
    }
}
