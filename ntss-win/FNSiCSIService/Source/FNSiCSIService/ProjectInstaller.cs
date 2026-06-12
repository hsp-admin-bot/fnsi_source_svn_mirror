using System;
using System.Collections;
using System.ComponentModel;
using System.Configuration.Install;
using System.Diagnostics;
using System.IO;
using System.Runtime.InteropServices;
using System.ServiceProcess;
using System.Threading;
using System.Windows.Forms;

namespace FNSiCSIService
{
    [RunInstaller(true)]
    public partial class ProjectInstaller :Installer
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

        private const String installerTitle = "FNSiCSIService";
        private const String paramenterTitle = "ModifyInstallParameter";
        // add 2022-10-31 bug #5536 インストーラの設定画面を全面にもってくる 孫 end
        public ProjectInstaller()
        {
            InitializeComponent();
        }


        private void serviceInstaller1_AfterInstall(object sender, InstallEventArgs e)
        {
            //del 2021 - 06 - 03 サービス再起動失敗問題 趙 start
            //ServiceInstaller serviceInstaller = (ServiceInstaller)sender;
            //using (ServiceController sc = new ServiceController(serviceInstaller.ServiceName))
            //{
            //    sc.Start();
            //}
            //del 2021 - 06 - 03 サービス再起動失敗問題 趙 end
        }

        private void serviceProcessInstaller_AfterInstall(object sender, InstallEventArgs e)
        {

        }

        protected override void OnAfterInstall(IDictionary savedState)
        {
            string assemblyPath = Context.Parameters["assemblypath"];
            string paths = Path.GetDirectoryName(assemblyPath) + Path.DirectorySeparatorChar;

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
                ModifyInstallParameter nKKWeights = new ModifyInstallParameter(paths);
                nKKWeights.ShowDialog();
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

            try
            {
                string collectionFactoryDllPath = Path.Combine(paths, "CollectionFactory.dll");
                if (RegisterDll(collectionFactoryDllPath) != 0)
                {
                    if (Environment.UserInteractive)
                    {
                        MessageBox.Show(string.Format("Dllの登録に失敗しました。Dllパス：{0}", collectionFactoryDllPath));
                    }
                }

                // Registryにパスを登録する
                using (Microsoft.Win32.RegistryKey key = Microsoft.Win32.Registry.LocalMachine.OpenSubKey("SOFTWARE", true))
                {
                    if (key != null)
                    {
                        Microsoft.Win32.RegistryKey subkey = key.CreateSubKey("FNSiCSIService");
                        subkey.SetValue("InstallPath", paths);
                    }
                }
            }
            catch (Exception ex)
            {
                if (Environment.UserInteractive)
                {
                    MessageBox.Show(ex.ToString());
                }
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
                MessageBox.Show("パラメータ設定画面に問題が発生しました。再インストールしてください。");
            }
        }
        // add 2022-10-31 bug #5536 インストーラの設定画面を全面にもってくる 孫 end

        public override void Commit(IDictionary savedState)
        {
            base.Commit(savedState);
            ServiceController sc = new ServiceController("FNSiCSIService");

            if (sc.Status.Equals(ServiceControllerStatus.Running) || sc.Status.Equals(ServiceControllerStatus.StartPending))
            {
                sc.Stop();
            }
            if (sc.Status.Equals(ServiceControllerStatus.Stopped) || sc.Status.Equals(ServiceControllerStatus.StopPending))
            {
                sc.Start();
            }
        }

        public override void Uninstall(IDictionary savedState)
        {
            base.Uninstall(savedState);

            try
            {
                using (Microsoft.Win32.RegistryKey key = Microsoft.Win32.Registry.LocalMachine.OpenSubKey("SOFTWARE\\FNSiCSIService", true))
                {
                    if (key != null)
                    {
                        string installPath = key.GetValue("InstallPath") as string;
                        string dllPath = Path.Combine(installPath, "CollectionFactory.dll");
                        if (UnregisterDll(dllPath) != 0)
                        {
                            if (Environment.UserInteractive)
                            {
                                MessageBox.Show(string.Format("Dllの登録の解除に失敗しました。Dllパス：{0}", dllPath));
                            }
                        }
                    }
                }

                Microsoft.Win32.Registry.LocalMachine.DeleteSubKeyTree("SOFTWARE\\FNSiCSIService");
            }
            catch(Exception ex)
            {
                if (Environment.UserInteractive)
                {
                    MessageBox.Show(ex.ToString());
                }
            }
        }

        private int RegisterDll(string dllPath)
        {
            string regsvr32Path = "regsvr32.exe";

            Process process = new Process();
            process.StartInfo.FileName = regsvr32Path;
            process.StartInfo.Arguments = $"/s {dllPath}";

            process.Start();
            process.WaitForExit();

            return  process.ExitCode;
        }

        private int UnregisterDll(string dllPath)
        {
            string regsvr32Path = "regsvr32.exe";

            Process process = new Process();
            process.StartInfo.FileName = regsvr32Path;
            process.StartInfo.Arguments = $"/u /s {dllPath}";

            process.Start();
            process.WaitForExit();

            return process.ExitCode;
        }
    }
}
