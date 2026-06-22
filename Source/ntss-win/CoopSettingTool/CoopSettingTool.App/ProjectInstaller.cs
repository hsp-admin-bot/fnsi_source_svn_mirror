// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 10-25-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 10-25-2021
// ***********************************************************************
// <copyright file="ProjectInstaller.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.App.Dialogues;
using System;
using System.Collections;
using System.ComponentModel;
using System.IO;

namespace CoopSettingTool.App
{
    /// <summary>
    /// Class ProjectInstaller.
    /// Implements the <see cref="System.Configuration.Install.Installer" />
    /// </summary>
    /// <seealso cref="System.Configuration.Install.Installer" />
    [RunInstaller(true)]
    public partial class ProjectInstaller : System.Configuration.Install.Installer
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="ProjectInstaller"/> class.
        /// </summary>
        public ProjectInstaller()
        {
            InitializeComponent();
        }

        /// <summary>
        /// <see cref="E:System.Configuration.Install.Installer.AfterInstall" /> イベントを発生させます。
        /// </summary>
        /// <param name="savedState"><see cref="P:System.Configuration.Install.Installer.Installers" /> プロパティに格納されているすべてのインストーラーがインストールを完了した後のコンピューターの状態を格納する <see cref="T:System.Collections.IDictionary" />。</param>
        protected override void OnAfterInstall(IDictionary savedState)
        {
            if (!Environment.UserInteractive || "1" == Context.Parameters["silent"])
            {
                base.OnAfterInstall(savedState);
                return;
            }
            string assemblyPath = Context.Parameters["assemblypath"];
            string paths = Path.GetDirectoryName(assemblyPath) + Path.DirectorySeparatorChar;
            ModifyConfigDialogue nKKWeights = new ModifyConfigDialogue(paths);
            nKKWeights.ShowDialog();
            base.OnAfterInstall(savedState);
        }
    }
}
