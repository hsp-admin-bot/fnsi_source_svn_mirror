using System;
using System.Collections;
using System.ComponentModel;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Threading;
using System.Windows.Forms;

namespace LayoutDesigner
{
    [RunInstaller(true)]
    public partial class ProjectInstaller : System.Configuration.Install.Installer
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

        // mod #12685 単体アプリ、サービスの名称見直し limingzhe start
        //private const String installerTitle = "LayoutDesigner";
        private const String installerTitle = "FNWSiLayoutDesigner";
        // mod #12685 単体アプリ、サービスの名称見直し limingzhe end
        private const String paramenterTitle = "UpdateConfig";
        // add 2022-10-31 bug #5536 インストーラの設定画面を全面にもってくる 孫 end

        public ProjectInstaller()
        {
            InitializeComponent();
        }
        protected override void OnAfterInstall(IDictionary savedState)
        {
            // セッション0またはサイレントインストール（/quiet）では UI を表示しない
            if (Environment.UserInteractive && "1" != Context.Parameters["silent"])
            {
                // add 2022-10-31 bug #5536 インストーラの設定画面を全面にもってくる 孫 start
                Thread trdInstaller = new Thread(DoWork)
                {
                    Name = "InstallParameterSetting.",
                    IsBackground = true
                };
                trdInstaller.Start();
                // add 2022-10-31 bug #5536 インストーラの設定画面を全面にもってくる 孫 end
                string path = this.Context.Parameters["assemblypath"];
                // mod #12685 単体アプリ、サービスの名称見直し limingzhe start
                //path = path.Replace("LayoutDesigner.exe", "");
                path = path.Replace("FNWSiLayoutDesigner.exe", "");
                // mod #12685 単体アプリ、サービスの名称見直し limingzhe end
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
            base.OnAfterInstall(savedState);
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
                if (Environment.UserInteractive)
                    MessageBox.Show("パラメータ設定画面に問題が発生しました。再インストールしてください。");
            }
        }
        // add 2022-10-31 bug #5536 インストーラの設定画面を全面にもってくる 孫 end

        public override void Install(IDictionary stateSaver)
        {
            base.Install(stateSaver);
        }
        protected override void OnBeforeInstall(IDictionary savedState)
        {
            base.OnBeforeInstall(savedState);
        }
        public override void Uninstall(IDictionary savedState)
        {
            // add #11239 単体アプリをバージョンアップできない 高 start
            try
            {
                String taskkill = System.IO.Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.System), "taskkill.exe");

                // mod #12685 単体アプリ、サービスの名称見直し limingzhe start
                //System.Diagnostics.Process[] ps = System.Diagnostics.Process.GetProcessesByName("LayoutDesigner");
                System.Diagnostics.Process[] ps = System.Diagnostics.Process.GetProcessesByName("FNWSiLayoutDesigner");
                // mod #12685 単体アプリ、サービスの名称見直し limingzhe end

                foreach (System.Diagnostics.Process p in ps)
                {
                    using (System.Diagnostics.Process killproc = new System.Diagnostics.Process())
                    {
                        killproc.StartInfo.Verb = "RunAs";
                        killproc.StartInfo.FileName = taskkill;
                        killproc.StartInfo.Arguments = String.Format("/PID {0} /T /F", p.Id);
                        killproc.StartInfo.CreateNoWindow = false;
                        killproc.StartInfo.UseShellExecute = false;
                        //
                        killproc.Start();
                        // プロセス終了待ち
                        killproc.WaitForExit(10000);
                    }
                }
            }
            catch (Exception ex)
            {
            }
            // add #11239 単体アプリをバージョンアップできない 高 end
            base.Uninstall(savedState);
        }
        public override void Rollback(IDictionary savedState)
        {
            base.Rollback(savedState);
        }
    }
}
