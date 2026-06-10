using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Diagnostics;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace InstallerCustomAction
{
    [System.ComponentModel.RunInstaller(true)]
    public class InstallerCustomAction : System.Configuration.Install.Installer
    {
        // InstallUtil.exe は自身のディレクトリを AppDomain ベースとするため、
        // InstallerCustomAction.dll と同じフォルダにある依存 DLL が解決できない。
        // 静的コンストラクタで AssemblyResolve を登録し、実行ファイルと同じフォルダから解決する。
        static InstallerCustomAction()
        {
            AppDomain.CurrentDomain.AssemblyResolve += (sender, args) =>
            {
                string assemblyName = new System.Reflection.AssemblyName(args.Name).Name;
                string dllDirectory = System.IO.Path.GetDirectoryName(
                    System.Reflection.Assembly.GetExecutingAssembly().Location);
                string assemblyPath = System.IO.Path.Combine(dllDirectory, assemblyName + ".dll");
                if (System.IO.File.Exists(assemblyPath))
                    return System.Reflection.Assembly.LoadFrom(assemblyPath);
                return null;
            };
        }

        [DllImport("USER32.DLL")]
        public static extern void SwitchToThisWindow(IntPtr hwnd, Boolean fAltTab);

        [DllImport("USER32.DLL")]
        public static extern IntPtr GetForegroundWindow();

        private const int ALT = 0xA4;
        private const int EXTENDEDKEY = 0x1;
        private const int KEYUP = 0x2;

        [DllImport("USER32.DLL")]
        public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, int dwExtraInfo);

        private static string userConfigPath = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData) + @"\Fnw.StatisticsTool";
        private const String installerTitle = "Statistics";
        private const String paramenterTitle = "UpdateConfig";
        private const String exeName = "StatisticsTool_2025.exe";

        private AutoResetEvent stopEvent = new AutoResetEvent(false); // スレッド終了のシグナル用
        private Exception threadException = null; // スレッド内で発生した例外を保持
        protected override void OnAfterInstall(System.Collections.IDictionary savedState)
        {
            base.OnAfterInstall(savedState);

            // セッション0またはサイレントインストール（/quiet）では UI を表示しない
            if (Environment.UserInteractive && "1" != Context.Parameters["silent"])
            {
                // InstallContextのPropertiesを使って設定
                Context.Parameters["REINSTALL"] = "ALL";  // すべてのコンポーネントを再インストール
                Context.Parameters["REINSTALLMODE"] = "vomus";  // 再インストール時の動作指定
                Context.Parameters["MEDIA"] = "None";

                // exe.configの場所を生成（assemblypath から自ディレクトリを取得）
                string assemblyPath = Context.Parameters["assemblypath"];
                string targetDir = Path.GetDirectoryName(assemblyPath) + Path.DirectorySeparatorChar;
                string exePath = Path.Combine(targetDir, exeName);
                string configPath = exePath + ".config";

                Thread trdInstaller = new Thread(DoWork)
                {
                    Name = "InstallParameterSetting.",
                    IsBackground = true
                };

                trdInstaller.Start();

                ModifyInstallParameter updateConfig = new ModifyInstallParameter(configPath);

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
                    MessageBox.Show((IWin32Window)this, "パラメータ設定画面に問題が発生しました。再インストールしてください。");
                }
                // IsBackground = true のため、InstallUtil 終了時にスレッドは自動終了する
            }
        }

        // 非同期でインストール後処理を実行
        private void DoWork()
        {
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
                            //keybd_event((byte)ALT, 0x45, EXTENDEDKEY | 0, 0);
                            //keybd_event((byte)ALT, 0x45, EXTENDEDKEY | KEYUP, 0);
                            SwitchToThisWindow(paramenterProcessInfo.MainWindowHandle, true);
                        }
                    }
                    if (stopEvent.WaitOne(0))  // ここでイベントがセットされるとループが終了
                    {
                        break;
                    }
                    Thread.Sleep(50);
                }
            }
            catch (Exception ex)
            {
                threadException = ex; // メインスレッドに渡すために例外を保存
            }
        }

        public override void Commit(System.Collections.IDictionary state) { base.Commit(state); }
        public override void Rollback(System.Collections.IDictionary state) { base.Rollback(state); }
        public override void Uninstall(System.Collections.IDictionary savedState) {
            base.Uninstall(savedState); // 最初に基底のアンインストール処理を実行

            // インストーラーがインストールしようとしているバージョンを取得
            string productVersion = GetInstallerVersion();

            if (!string.IsNullOrEmpty(productVersion))
            {
                // バージョンアップの場合、フォルダ削除をスキップ
                return;
            }
            // アンインストール時はフォルダ削除
            try
            {
                // フォルダが存在する場合は削除
                if (Directory.Exists(userConfigPath))
                {
                    Directory.Delete(userConfigPath, true); // true: フォルダ内のファイルとサブフォルダも削除
                }
            }
            catch (UnauthorizedAccessException)
            {
                MessageBox.Show((IWin32Window)this,"フォルダの削除権限がありません。", "エラー", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            catch (IOException ex)
            {
                MessageBox.Show((IWin32Window)this,$"削除中にエラーが発生しました: {ex.Message}", "エラー", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            catch (Exception ex)
            {
                MessageBox.Show((IWin32Window)this,$"予期しないエラーが発生しました: {ex.Message}", "エラー", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        public string GetInstallerVersion()
        {
            return this.Context.Parameters["ProductVersion"];  // インストーラーのバージョンを取得
        }
    }
}
