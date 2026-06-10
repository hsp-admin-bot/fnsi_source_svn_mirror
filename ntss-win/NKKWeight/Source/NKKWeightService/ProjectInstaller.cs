using System;
using System.Collections;
using System.ComponentModel;
using System.Configuration.Install;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.ServiceProcess;
using System.Threading;
using System.Windows.Forms;

namespace NKKWeightService
{
    [RunInstaller(true)]
    public partial class ProjectInstaller : Installer
    {
        // add 2022-10-31 bug #5536 インストーラの設定画面を全面にもってくる 孫 start
        [DllImport("USER32.DLL")]
        public static extern void SwitchToThisWindow(IntPtr hwnd, Boolean fAltTab);

        [DllImport("USER32.DLL")]
        public static extern IntPtr GetForegroundWindow();

        private const int ALT = 0xA4;
        private const int EXTENDEDKEY = 0x1;
        private const int KEYUP = 0x2;

        [DllImport("USER32.DLL")]
        public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, int dwExtraInfo);

        private const String installerTitle = "NKKWeight";
        private const String paramenterTitle = "NKKWeightParameter";
        // add 2022-10-31 bug #5536 インストーラの設定画面を全面にもってくる 孫 end

        public ProjectInstaller()
        {
            InitializeComponent();
        }

        private void serviceInstaller1_AfterInstall(object sender, InstallEventArgs e)
        {
            // add FNSI-改修内容:No.317:インストーラーを作ること。分散したモジュール＋バッチではダメ。 孫 start
            //del 2021 - 06 - 03 サービス再起動失敗問題 趙 start
            //ServiceInstaller serviceInstaller = (ServiceInstaller)sender;
            //using (ServiceController sc = new ServiceController(serviceInstaller.ServiceName))
            //{
            //    sc.Start();
            //}
            // add FNSI-改修内容:No.317:インストーラーを作ること。分散したモジュール＋バッチではダメ。 孫 start
            //del 2021 - 06 - 03 サービス再起動失敗問題 趙 end
        }
        private void serviceProcessInstaller_AfterInstall(object sender, InstallEventArgs e)
        {

        }

        public override void Commit(IDictionary savedState)
        {
            // ダイアログ表示条件:
            //   1) Environment.UserInteractive が true（セッション0でない）
            //   2) かつ WiX から /silent=1 が渡されていない（UILevel < 5 のサイレント/ベーシックUI時に付与）
            // UAC昇格インストールではImpersonate="no"でもユーザーセッション内で動くため
            // UserInteractiveだけでは不十分。/silent=1 パラメータで確実に抑制する。
            bool silentInstall = !Environment.UserInteractive ||
                                 "1" == Context.Parameters["silent"];
            if (!silentInstall)
            {
                // add 2022-10-31 bug #5536 インストーラの設定画面を全面にもってくる 孫 start
                Thread trdInstaller = new Thread(DoWork)
                {
                    Name = "InstallParameterSetting.",
                    IsBackground = true
                };
                trdInstaller.Start();
                // add 2022-10-31 bug #5536 インストーラの設定画面を全面にもってくる 孫 end

                // 設定を変更する
                string path = this.Context.Parameters["assemblypath"];
                path = path.Replace("FNWSiScale.exe", "");
                ModifyInstallParameter updateConfig = new ModifyInstallParameter(path);
                updateConfig.ShowDialog();
                // add 2022-10-31 bug #5536 インストーラの設定画面を全面にもってくる 孫 start
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
                // add 2022-10-31 bug #5536 インストーラの設定画面を全面にもってくる 孫 end
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
                // サイレントインストール かつ インストール前にサービスが停止していた場合:
                // サービスは起動しない（インストール前の状態を維持）
                return;
            }

            // サービスを起動する
            ServiceController sc = new ServiceController("NKKWeightService");
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
                // 自動(遅延開始) など、StartPending が長く続く環境向けに待機を延長（最大約90秒）
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

        // add 2022-10-31 bug #5536 インストーラの設定画面を全面にもってくる 孫 start
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
        // add 2022-10-31 bug #5536 インストーラの設定画面を全面にもってくる 孫 end
    }
}