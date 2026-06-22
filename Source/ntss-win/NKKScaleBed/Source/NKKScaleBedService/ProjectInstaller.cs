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
            // ダイアログ表示条件:
            //   1) Environment.UserInteractive が true（セッション0でない）
            //   2) かつ WiX から /silent=1 が渡されていない（UILevel < 5 のサイレント/ベーシックUI時に付与）
            bool silentInstall = !Environment.UserInteractive ||
                                 "1" == Context.Parameters["silent"];
            if (!silentInstall)
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
            }

            base.Commit(savedState);

            // サービス起動判定:
            //   - 対話型インストール（silentInstall=false）: 常に起動（従来動作）
            //   - サイレントインストール（silentInstall=true） : インストール前にサービスが
            //     起動していた場合（/servicewasrunning=1）のみ起動。停止中だった場合は起動しない。
            bool serviceWasRunning = "1" == Context.Parameters["servicewasrunning"];
            bool shouldStartService = !silentInstall || serviceWasRunning;

            if (!shouldStartService)
            {
                return;
            }

            // サービスを起動する
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
                        if (Environment.UserInteractive)
                            MessageBox.Show("サービスの停止に失敗しました。");
                        break;
                    }
                }
            }
            if (sc.Status.Equals(ServiceControllerStatus.Stopped) || sc.Status.Equals(ServiceControllerStatus.StopPending))
            {
                sc.Start();
                const int maxStartWaitSeconds = 90;
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

                    if (count > maxStartWaitSeconds)
                    {
                        if (Environment.UserInteractive)
                            MessageBox.Show("サービスの起動に失敗しました。");
                        break;
                    }
                }
            }
        }

        private void DoWork()
        {
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
                            paramenterProcessInfo = process;
                        }
                        else if (installProcessInfo == null && installerTitle.Equals(process.MainWindowTitle))
                        {
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
                    IntPtr hCurrHandle = GetForegroundWindow();

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