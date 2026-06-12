using FNWConverter;
using NKSConverter;
using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration.Install;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace NKSConverter
{
    [RunInstaller(true)]
    public partial class ProjectInstaller : System.Configuration.Install.Installer
    {
        // インストーラ(InstallUtil.exe)経由で本アセンブリが実行される場合、
        // FNWSiConvertTool.exe.config のバインディングリダイレクトは適用されない。
        // そのため Oracle.ManagedDataAccess(23.x) の依存アセンブリ(System.Text.Json 等)の
        // バージョン解決に失敗し、ProviderConfig の型初期化で例外となる。
        // インストール先フォルダから単純名で依存 DLL を解決し、これを回避する。
        static ProjectInstaller()
        {
            AppDomain.CurrentDomain.AssemblyResolve += ResolveDependencyFromInstallDir;
        }

        private static Assembly ResolveDependencyFromInstallDir(object sender, ResolveEventArgs args)
        {
            try
            {
                string simpleName = new AssemblyName(args.Name).Name;
                string baseDir = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
                if (string.IsNullOrEmpty(baseDir))
                {
                    return null;
                }

                string candidate = Path.Combine(baseDir, simpleName + ".dll");
                if (File.Exists(candidate))
                {
                    return Assembly.LoadFrom(candidate);
                }
            }
            catch
            {
                // 解決できない場合は既定の動作に委ねる
            }

            return null;
        }

        // #12338 add Start
        // ===== Shortcut 定義 Start =====
        private const string ShortcutFileName = "コンバートツール.lnk";
        private const string ShortcutDescription = "";
        private const string ShortcutArguments = "";
        private const int ShortcutWindowStyle = 1; // 1 = 通常Window
        // ===== Shortcut 定義 End =====
        // #12338 add End

        public ProjectInstaller()
        {
            InitializeComponent();
        }

        // #12338 add Start
        // ===== ALLUSERS 判定 Start =====
        private bool IsAllUsersInstall()
        {
            string allUsers = Context.Parameters["ALLUSERS"];
            return string.Equals(allUsers, "1", StringComparison.OrdinalIgnoreCase);
        }

        private string GetDesktopPath()
        {
            if (IsAllUsersInstall())
            {
                return Environment.GetFolderPath(
                    Environment.SpecialFolder.CommonDesktopDirectory);
            }
            else
            {
                return Environment.GetFolderPath(
                    Environment.SpecialFolder.DesktopDirectory);
            }
        }
        // ===== ALLUSERS 判定 End =====

        private void CreateShortcut(string targetPath, string shortcutPath, string description, string workingDirectory)
        {
            IWshRuntimeLibrary.WshShell shell = null;

            try
            {
                shell = new IWshRuntimeLibrary.WshShell();
                var shortcut = (IWshRuntimeLibrary.IWshShortcut)shell.CreateShortcut(shortcutPath);

                shortcut.TargetPath = targetPath;
                shortcut.WorkingDirectory = workingDirectory;
                shortcut.Description = description;
                shortcut.IconLocation = targetPath + ",0"; // Icon設定

                // オプション
                shortcut.Arguments = ShortcutArguments;
                shortcut.WindowStyle = ShortcutWindowStyle;

                shortcut.Save();

                System.Runtime.InteropServices.Marshal.ReleaseComObject(shortcut);
            }
            finally
            {
                if (shell != null)
                {
                    System.Runtime.InteropServices.Marshal.ReleaseComObject(shell);
                }
            }
        }

        private void DeleteShortcut(string shortcutPath)
        {
            try
            {
                if (File.Exists(shortcutPath))
                {
                    File.Delete(shortcutPath);
                }
            }
            catch (Exception ex)
            {
                // Uninstall時はExceptionをthrowしない
                MessageBox.Show(
                    "ショットカット削除に失敗しました：" + ex.Message,
                    "Uninstall",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Warning
                );
            }
        }
        // #12338 add End

        protected override void OnAfterInstall(IDictionary savedState)
        {
            // #12338 ショートカットは WiX インストーラーで作成するため不要
            // (CreateShortcut は WiX の Component/Shortcut で代替)

            // add #10856 コンバータツールのインストーラに内包物と設定が不足している start
            // セッション0またはサイレントインストール（/quiet）では UI を表示しない
            if (Environment.UserInteractive && "1" != Context.Parameters["silent"])
            {
                string assemblyPath = Context.Parameters["assemblypath"];
                string installDir = Path.GetDirectoryName(assemblyPath);

                ConfigSetting setting = new ConfigSetting(installDir);
                setting.TopMost = true;
                setting.ShowDialog();
                setting.Activate();
            }
            // add #10856 コンバータツールのインストーラに内包物と設定が不足している end

            base.OnAfterInstall(savedState);
        }

        protected override void OnAfterUninstall(IDictionary savedState)
        {
            // #12338 ショートカットは WiX インストーラーで削除するため不要
            // (DeleteShortcut は WiX の RemoveFile で代替)

            // add #10856 コンバータツールのインストーラに内包物と設定が不足している start
            try
            {
                string assemblyPath = Context.Parameters["assemblypath"];
                string installDir = Path.GetDirectoryName(assemblyPath);
                EnvironmentVariableDelete delete = new EnvironmentVariableDelete(installDir);
                delete.Delete();
            }
            catch (Exception ex)
            {
                if (Environment.UserInteractive)
                    MessageBox.Show(ex.Message);
            }
            // add #10856 コンバータツールのインストーラに内包物と設定が不足している end

            base.OnAfterUninstall(savedState);
        }
    }
}
