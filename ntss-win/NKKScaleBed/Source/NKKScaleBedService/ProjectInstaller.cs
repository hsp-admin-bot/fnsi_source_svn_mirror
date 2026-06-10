using System;
using System.Collections;
using System.ComponentModel;
using System.Configuration.Install;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.ServiceProcess;
using System.Threading;
using System.Windows.Forms;

namespace NKKScaleBedService
{
    [RunInstaller(true)]
    public partial class ProjectInstaller : Installer
    {
        [DllImport("USER32.DLL")]
        public static extern void SwitchToThisWindow(IntPtr hwnd, Boolean fAltTab);

        [DllImport("USER32.DLL")]
        public static extern IntPtr GetForegroundWindow();

        private const int ALT = 0xA4;
        private const int EXTENDEDKEY = 0x1;
        private const int KEYUP = 0x2;

        [DllImport("USER32.DLL")]
        public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, int dwExtraInfo);

        private const String installerTitle = "NKKScaleBed";
        private const String paramenterTitle = "NKKScaleBedParameter";

        public ProjectInstaller()
        {
            InitializeComponent();
        }

        private void serviceInstaller1_AfterInstall(object sender, InstallEventArgs e)
        {
            
        }
        private void serviceProcessInstaller_AfterInstall(object sender, InstallEventArgs e)
        {

        }

        public override void Commit(IDictionary savedState)
        {
            Thread trdInstaller = new Thread(DoWork)
            {
                Name = "InstallParameterSetting.",
                IsBackground = true
            };
            trdInstaller.Start();

            // 設定を変更する
            string path = this.Context.Parameters["assemblypath"];
            path = path.Replace("NKKScaleBedService.exe", "");
            ModifyInstallParameter updateConfig = new ModifyInstallParameter(path);
            updateConfig.ShowDialog();
            try
            {
                foreach (Process process in Process.GetProcessesByName("msiexec"))
                {
                    if (installerTitle.Equals(process.MainWindowTitle))
                    {
                        SwitchToThisWindow(process.MainWindowHandle, true);
                        break;
                    }
                }
            }
            catch (Exception)
            {
                MessageBox.Show("パラメータ設定画面に問題が発生しました。再インストールしてください。");
            }
            base.Commit(savedState);

            // サービスを再起動する
            ServiceController sc = new ServiceController("NKKScaleBed");
            if (sc.Status.Equals(ServiceControllerStatus.Running) || sc.Status.Equals(ServiceControllerStatus.StartPending))
            {
                int count = 0;
                sc.Stop();
                while (true)
                {
                    Thread.Sleep(1000);
                    count++;
                    sc.Refresh();
                    if (sc.Status.Equals(ServiceControllerStatus.Stopped))
                    {
                        break;
                    }

                    if (count > 5)
                    {
                        MessageBox.Show("サービスの停止に失敗しました。");
                        break;
                    }
                }
            }
            if (sc.Status.Equals(ServiceControllerStatus.Stopped) || sc.Status.Equals(ServiceControllerStatus.StopPending))
            {
                sc.Start();
                int count = 0;
                while (true)
                {
                    Thread.Sleep(1000);
                    count++;
                    sc.Refresh();
                    if (sc.Status.Equals(ServiceControllerStatus.Running))
                    {
                        break;
                    }

                    if (count > 5)
                    {
                        MessageBox.Show("サービスの起動に失敗しました。");
                        break;
                    }
                }
            }
        }

        private void DoWork()
        {
            //System.Diagnostics.Debugger.Launch();
            // 設定画面の最上位の対応
            try
            {
                Process installProcessInfo = null;
                Process paramenterProcessInfo = null;

                while (true)
                {
                    foreach (Process process in Process.GetProcessesByName("msiexec"))
                    {
                        if (paramenterProcessInfo == null && paramenterTitle.Equals(process.MainWindowTitle))
                        {
                            // 設定画面のTitleより、ハンドルを取得する
                            paramenterProcessInfo = process;
                        }
                        else if (installProcessInfo == null && installerTitle.Equals(process.MainWindowTitle))
                        {
                            // インストーラ画面のTitleより、ハンドルを取得する
                            installProcessInfo = process;
                        }
                    }

                    if (installProcessInfo != null && paramenterProcessInfo != null)
                    {
                        break;
                    }
                    Thread.Sleep(50);
                }

                while (true)
                {
                    // 最上位画面を取得する
                    IntPtr hCurrHandle = GetForegroundWindow();

                    // 最上位画面がインストール画面の場合、設定画面に最上位画面を設定する
                    if (hCurrHandle.Equals(installProcessInfo.MainWindowHandle))
                    {
                        if (paramenterProcessInfo != null)
                        {
                            keybd_event((byte)ALT, 0x45, EXTENDEDKEY | 0, 0);
                            keybd_event((byte)ALT, 0x45, EXTENDEDKEY | KEYUP, 0);
                            SwitchToThisWindow(paramenterProcessInfo.MainWindowHandle, true);
                        }
                    }
                    Thread.Sleep(50);
                }
            }
            catch (Exception)
            {
                MessageBox.Show("パラメータ設定画面に問題が発生しました。再インストールしてください。");
            }
        }
    }
}