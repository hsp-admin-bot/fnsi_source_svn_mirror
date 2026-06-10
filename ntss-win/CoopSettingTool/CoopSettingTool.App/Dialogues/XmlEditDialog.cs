// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-15-2022
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-15-2022
// ***********************************************************************
// <copyright file="XmlEditDialog.cs" company="">
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
using System.IO;
using System.Windows.Forms;
using System.Xml;

namespace CoopSettingTool.App.Dialogues
{

    /// <summary>
    /// Class XmlEditDialog.
    /// Implements the <see cref="MaterialSkin.Controls.MaterialForm" />
    /// </summary>
    /// <seealso cref="MaterialSkin.Controls.MaterialForm" />
    public partial class XmlEditDialog : BaseView
    {
        /// <summary>
        /// The output XML
        /// </summary>
        private string outputXml = null;

        /// <summary>
        /// Gets the output XML.
        /// </summary>
        /// <value>The output XML.</value>
        public string OutputXml { get => outputXml; }


        /// <summary>
        /// Initializes a new instance of the <see cref="CoopCdSelectDialogue" /> class.
        /// </summary>
        public XmlEditDialog()
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
                XmlDocument xmlDoc = new XmlDocument();
                StringWriter sw = new StringWriter();
                xmlDoc.LoadXml(this.textBox1.Text);
                xmlDoc.Save(sw);
                this.outputXml = sw.ToString();
            }
            catch
            {
                this.outputXml = string.Empty;
            }

            if (string.IsNullOrEmpty(this.outputXml))
            {
                MessageBox.Show(this, "XMLデータの形式は正しくないです。",　"エラー", MessageBoxButtons.OK, MessageBoxIcon.Error);
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
        /// <param name="inputXml">The input XML.</param>
        /// <returns>DialogResult.</returns>
        public DialogResult ShowDialog(IWin32Window parent, string inputXml)
        {
            try
            {
                XmlDocument xmlDoc = new XmlDocument();
                StringWriter sw = new StringWriter();
                xmlDoc.LoadXml(inputXml);
                xmlDoc.Save(sw);
                this.textBox1.Text = sw.ToString();
            }
            catch
            {
                this.textBox1.Text = inputXml;
            }
            return this.ShowDialog(parent);
        }
    }
}
