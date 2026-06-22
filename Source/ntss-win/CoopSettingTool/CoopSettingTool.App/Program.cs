// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-16-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-16-2021
// ***********************************************************************
// <copyright file="Program.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.App.DI;
using CoopSettingTool.App.Module;
using CoopSettingTool.App.Views;
using CoopSettingTool.Log;
using CoopSettingTool.Service.Configuration;
using System;
using System.Windows.Forms;

namespace CoopSettingTool.App
{
    /// <summary>
    /// Class Program.
    /// </summary>
    static class Program
    {
        /// <summary>
        /// アプリケーションのメイン エントリ ポイントです。
        /// </summary>
        [STAThread]
        static void Main()
        {
            //Mutex名を決める（必ずアプリケーション固有の文字列に変更すること！）
            string mutexName = "CoopSettingTool";
            //Mutexオブジェクトを作成する
            bool createdNew;
            System.Threading.Mutex mutex =
                new System.Threading.Mutex(true, mutexName, out createdNew);

            //ミューテックスの初期所有権が付与されたか調べる
            if (createdNew == false)
            {
                //されなかった場合は、すでに起動していると判断して終了
                MessageBox.Show("このアプリケーションはすでに起動しています。", "多重起動禁止", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                mutex.Close();
                return;
            }
            try
            {
                LogHelper.CreateInstance();
                // Register global exception
                AppDomain.CurrentDomain.UnhandledException += new UnhandledExceptionEventHandler(AppGlobalHandler);
                AppSettingConfig.LoadConfig(CoopSettingTool.Service.Constant.API_CONFIG_FILE_PATH);
                ApplicationModule module = new ApplicationModule();
                module.Dispose();
                CompositionRoot.Wire(module);
                Application.EnableVisualStyles();
                LoginView view = CompositionRoot.Resolve<ILoginView>() as LoginView;
                Application.Run(view);
            }
            finally
            {
                //ミューテックスを解放する
                mutex.ReleaseMutex();
                mutex.Close();
            }
}

        /// <summary>
        /// Applications the global handler.
        /// </summary>
        /// <param name="sender">The sender.</param>
        /// <param name="args">The <see cref="UnhandledExceptionEventArgs"/> instance containing the event data.</param>
        private static void AppGlobalHandler(object sender, UnhandledExceptionEventArgs args)
        {
            Exception e = (Exception)args.ExceptionObject;
            LogHelper.LogError("APP", e);
            Application.SetCompatibleTextRenderingDefault(false);
        }
    }
}
