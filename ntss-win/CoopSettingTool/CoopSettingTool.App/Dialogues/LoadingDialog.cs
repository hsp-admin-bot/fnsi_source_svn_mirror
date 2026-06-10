// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 06-16-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 07-14-2021
// ***********************************************************************
// <copyright file="LoadingDialog.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using System;
using System.Drawing;
using System.Windows.Forms;

namespace CoopSettingTool.App.Dialogues
{

    /// <summary>
    /// Class LoadingDialog.
    /// Implements the <see cref="System.Windows.Forms.Form" />
    /// </summary>
    /// <seealso cref="System.Windows.Forms.Form" />
    public partial class LoadingDialog : Form
    {
        /// <summary>
        /// The GIF image
        /// </summary>
        private GifImage gifImage = null;
        /// <summary>
        /// The file path
        /// </summary>
        private string filePath = @"Assets\imgs\loading.gif";

        /// <summary>
        /// The instance
        /// </summary>
        private static LoadingDialog instance;

        /// <summary>
        /// Prevents a default instance of the <see cref="LoadingDialog"/> class from being created.
        /// </summary>
        private LoadingDialog()
        {
            InitializeComponent();
            this.BackColor = Color.DarkSlateGray;
            this.TransparencyKey = Color.DarkSlateGray;
            this.StartPosition = FormStartPosition.CenterParent;

            gifImage = new GifImage(filePath);
            gifImage.ReverseAtEnd = false; //dont reverse at end
            timer1.Enabled = true;
        }

        /// <summary>
        /// Shows the view.
        /// </summary>
        /// <param name="parent">The parent.</param>
        public static void ShowView(Form parent)
        {
            if(instance == null)
            {
                instance = new LoadingDialog();
            }

            var parentLoc = parent.DesktopLocation;

            var x = parentLoc.X + (parent.Width - instance.Width)/2;
            var y = parentLoc.Y + (parent.Height - instance.Height)/2;

            instance.Visible = false;
            instance.Show(parent);
            instance.Location = new Point(x, y);
        }

        /// <summary>
        /// Closes the view.
        /// </summary>
        /// <param name="baseView">The base view.</param>
        public static void CloseView(Views.BaseView baseView)
        {
            if (instance == null)
            {
                instance = new LoadingDialog();
            }

            instance.Hide();
        }

        /// <summary>
        /// Handles the Tick event of the timer1 control.
        /// </summary>
        /// <param name="sender">The source of the event.</param>
        /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
        private void timer1_Tick(object sender, EventArgs e)
        {
        }
    }
}
