using NKKLoggingLib;
using NKKWeightLib;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.ServiceProcess;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Win32.SafeHandles;

namespace NKKPrintServer
{
    public partial class NKKPrintServer : ServiceBase
    {

        /// <summary>
        /// サービス名称
        /// </summary>
        private static readonly string SERVICE_NAME = System.Reflection.Assembly.GetExecutingAssembly().GetName().Name;

        /// <summary>
        /// NKKPrintクラスオブジェクト
        /// </summary>
        private NKKPrint m_NkkWeight = null;

        private const string TrayProcessName = "FNWSiPrintServerTool";
        private const string TrayExeName = "FNWSiPrintServerTool.exe";
        private static int s_trayLaunchAttempted;

        public NKKPrintServer()
        {
            InitializeComponent();
        }

        protected override void OnStart(string[] args)
        {

            // 捕捉されない例外ハンドラを設定
            AppDomain.CurrentDomain.UnhandledException += CurrentDomain_UnhandledException;

            // ログオブジェクト取得
            NKKLogging log = NKKLogging.GetInstance();

            // 信頼できないSSL証明書を「問題なし」にするメソッド
            bool OnRemoteCertificateValidationCallback(
                      Object sender,
                      System.Security.Cryptography.X509Certificates.X509Certificate certificate,
                      System.Security.Cryptography.X509Certificates.X509Chain chain,
                      System.Net.Security.SslPolicyErrors sslPolicyErrors)
            {
                return true;  // 「SSL証明書の使用は問題なし」と示す
            }

            System.Net.ServicePointManager.ServerCertificateValidationCallback =
              new System.Net.Security.RemoteCertificateValidationCallback(
                OnRemoteCertificateValidationCallback);

            // 各オブジェクト構築
            this.m_NkkWeight = new NKKPrint(AppDomain.CurrentDomain.BaseDirectory);
            //this.m_ViewLogServer = new TdcViewLogServer(TdcViewLogModule.GetInstance().ViewLog);
            //this.m_ViewLogServer.LogExt = "VIEW";

            // ログ記録
            log.AddLogInfo(DateTime.Now, SERVICE_NAME, NKKLogging.LOGGING_CLASS.INFO, "サービス構築完了");

            try
            {

                // OnStart処理開始
                log.AddLogInfo(DateTime.Now, SERVICE_NAME, NKKLogging.LOGGING_CLASS.INFO, "OnStart処理開始");

                // 以下の処理で失敗した場合はthrowされる
                // NKKWeight初期化処理
                if (this.m_NkkWeight.Start() == true)
                {
                    TryStartTrayInActiveUserSession(log);
                }
                else
                {
                    //throw (new Exception("NKKWeight初期化、待ち受け失敗"));
                    log.AddLogInfo(DateTime.Now, SERVICE_NAME, NKKLogging.LOGGING_CLASS.ERROR, "NKKPrint初期化、待ち受け失敗");
                    Stop();
                }

                // OnStart処理終了
                log.AddLogInfo(DateTime.Now, SERVICE_NAME, NKKLogging.LOGGING_CLASS.INFO, "OnStart処理終了");
            }
            catch (Exception ex)
            {

                // ログ記録：エラー
                log.AddLogInfo(DateTime.Now, SERVICE_NAME, NKKLogging.LOGGING_CLASS.ERROR, String.Format("Error,{0}", ex.Message));

                //throw;
            }

        }

        private void CurrentDomain_UnhandledException(object sender, UnhandledExceptionEventArgs e)
        {
            //throw new NotImplementedException();
            // ログオブジェクト取得
            NKKLogging log = NKKLogging.GetInstance();

            try
            {

                Exception ex = (Exception)e.ExceptionObject;

                // ログ記録：エラー
                log.AddLogInfo(DateTime.Now, System.Reflection.Assembly.GetExecutingAssembly().GetName().Name,
                    NKKLogging.LOGGING_CLASS.ERROR, string.Format("Error,UnhandledExceptionEventHandler,{0}", "\r\n" + ex.ToString()));

                // サービス停止
                Stop();

            }
            catch (Exception ex)
            {
                Trace.WriteLine(ex.Message);
            }

        }

        protected override void OnStop()
        {
            // ログオブジェクト取得
            NKKLogging log = NKKLogging.GetInstance();

            try
            {
                // OnStop処理開始
                log.AddLogInfo(DateTime.Now, SERVICE_NAME, NKKLogging.LOGGING_CLASS.INFO, "OnStop処理開始");

                //// Tool待ち受け処理停止
                //this.m_ViewLogServer.StopListner();

                // NKKWeight終了
                this.m_NkkWeight.Stop();

                // OnStop処理終了
                log.AddLogInfo(DateTime.Now, SERVICE_NAME, NKKLogging.LOGGING_CLASS.INFO, "OnStop処理終了");
            }
            catch (Exception ex)
            {
                // ログ記録：エラー
                log.AddLogInfo(DateTime.Now, SERVICE_NAME, NKKLogging.LOGGING_CLASS.ERROR, string.Format("Error,{0}", ex.Message));

                throw;
            }


        }

        private static void TryStartTrayInActiveUserSession(NKKLogging log)
        {
            try
            {
                if (System.Threading.Interlocked.CompareExchange(ref s_trayLaunchAttempted, 1, 0) != 0)
                {
                    return;
                }

                int activeSessionId = (int)WTSGetActiveConsoleSessionId();
                if (activeSessionId < 0)
                {
                    log.AddLogInfo(DateTime.Now, SERVICE_NAME, NKKLogging.LOGGING_CLASS.INFO, "Tray起動スキップ: アクティブユーザーセッションなし");
                    return;
                }

                Process[] existing = Process.GetProcessesByName(TrayProcessName);
                if (existing.Any(p =>
                {
                    try { return p.SessionId == activeSessionId; } catch { return false; }
                }))
                {
                    log.AddLogInfo(DateTime.Now, SERVICE_NAME, NKKLogging.LOGGING_CLASS.INFO, "Tray起動不要: 既に起動済み(Session一致)");
                    return;
                }

                string baseDir = AppDomain.CurrentDomain.BaseDirectory;
                string trayExePath = Path.Combine(baseDir, TrayExeName);
                if (!File.Exists(trayExePath))
                {
                    log.AddLogInfo(DateTime.Now, SERVICE_NAME, NKKLogging.LOGGING_CLASS.ERROR, "Tray起動失敗: exe不在 " + trayExePath);
                    return;
                }

                IntPtr userToken;
                if (!WTSQueryUserToken((uint)activeSessionId, out userToken))
                {
                    int err = Marshal.GetLastWin32Error();
                    log.AddLogInfo(DateTime.Now, SERVICE_NAME, NKKLogging.LOGGING_CLASS.ERROR, "Tray起動失敗: WTSQueryUserToken err=" + err);
                    return;
                }

                using (SafeTokenHandle tokenHandle = new SafeTokenHandle(userToken))
                {
                    if (!DuplicateTokenForCreateProcess(tokenHandle, out SafeTokenHandle primaryToken))
                    {
                        int err = Marshal.GetLastWin32Error();
                        log.AddLogInfo(DateTime.Now, SERVICE_NAME, NKKLogging.LOGGING_CLASS.ERROR, "Tray起動失敗: DuplicateTokenEx err=" + err);
                        return;
                    }

                    using (primaryToken)
                    {
                        IntPtr env = IntPtr.Zero;
                        try
                        {
                            CreateEnvironmentBlock(out env, primaryToken.DangerousGetHandle(), false);

                            STARTUPINFO si = new STARTUPINFO();
                            si.cb = Marshal.SizeOf(typeof(STARTUPINFO));
                            si.lpDesktop = "winsta0\\default";

                            PROCESS_INFORMATION pi;
                            bool ok = CreateProcessAsUser(
                                primaryToken.DangerousGetHandle(),
                                trayExePath,
                                null,
                                IntPtr.Zero,
                                IntPtr.Zero,
                                false,
                                CreateProcessFlags.CREATE_UNICODE_ENVIRONMENT,
                                env,
                                baseDir,
                                ref si,
                                out pi);

                            if (!ok)
                            {
                                int err = Marshal.GetLastWin32Error();
                                log.AddLogInfo(DateTime.Now, SERVICE_NAME, NKKLogging.LOGGING_CLASS.ERROR, "Tray起動失敗: CreateProcessAsUser err=" + err);
                                return;
                            }

                            CloseHandle(pi.hProcess);
                            CloseHandle(pi.hThread);
                            log.AddLogInfo(DateTime.Now, SERVICE_NAME, NKKLogging.LOGGING_CLASS.INFO, "Tray起動成功: Session=" + activeSessionId + ", exe=" + trayExePath);
                        }
                        finally
                        {
                            if (env != IntPtr.Zero)
                            {
                                DestroyEnvironmentBlock(env);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                log.AddLogInfo(DateTime.Now, SERVICE_NAME, NKKLogging.LOGGING_CLASS.ERROR, "Tray起動例外: " + ex.Message);
            }
        }

        private static bool DuplicateTokenForCreateProcess(SafeTokenHandle token, out SafeTokenHandle primaryToken)
        {
            primaryToken = null;
            IntPtr dup;
            bool ok = DuplicateTokenEx(
                token.DangerousGetHandle(),
                TokenAccess.TOKEN_ALL_ACCESS,
                IntPtr.Zero,
                SECURITY_IMPERSONATION_LEVEL.SecurityImpersonation,
                TOKEN_TYPE.TokenPrimary,
                out dup);
            if (!ok)
            {
                return false;
            }
            primaryToken = new SafeTokenHandle(dup);
            return true;
        }

        private sealed class SafeTokenHandle : SafeHandleZeroOrMinusOneIsInvalid
        {
            public SafeTokenHandle() : base(true) { }
            public SafeTokenHandle(IntPtr handle) : base(true) { SetHandle(handle); }
            protected override bool ReleaseHandle() { return CloseHandle(handle); }
        }

        [DllImport("kernel32.dll")]
        private static extern uint WTSGetActiveConsoleSessionId();

        [DllImport("wtsapi32.dll", SetLastError = true)]
        private static extern bool WTSQueryUserToken(uint SessionId, out IntPtr phToken);

        [DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        private static extern bool CreateProcessAsUser(
            IntPtr hToken,
            string lpApplicationName,
            string lpCommandLine,
            IntPtr lpProcessAttributes,
            IntPtr lpThreadAttributes,
            bool bInheritHandles,
            CreateProcessFlags dwCreationFlags,
            IntPtr lpEnvironment,
            string lpCurrentDirectory,
            ref STARTUPINFO lpStartupInfo,
            out PROCESS_INFORMATION lpProcessInformation);

        [DllImport("advapi32.dll", SetLastError = true)]
        private static extern bool DuplicateTokenEx(
            IntPtr hExistingToken,
            uint dwDesiredAccess,
            IntPtr lpTokenAttributes,
            SECURITY_IMPERSONATION_LEVEL ImpersonationLevel,
            TOKEN_TYPE TokenType,
            out IntPtr phNewToken);

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool CloseHandle(IntPtr hObject);

        [DllImport("userenv.dll", SetLastError = true)]
        private static extern bool CreateEnvironmentBlock(out IntPtr lpEnvironment, IntPtr hToken, bool bInherit);

        [DllImport("userenv.dll", SetLastError = true)]
        private static extern bool DestroyEnvironmentBlock(IntPtr lpEnvironment);

        [Flags]
        private enum CreateProcessFlags : uint
        {
            CREATE_UNICODE_ENVIRONMENT = 0x00000400
        }

        private enum SECURITY_IMPERSONATION_LEVEL
        {
            SecurityAnonymous = 0,
            SecurityIdentification = 1,
            SecurityImpersonation = 2,
            SecurityDelegation = 3,
        }

        private enum TOKEN_TYPE
        {
            TokenPrimary = 1,
            TokenImpersonation = 2
        }

        private static class TokenAccess
        {
            public const uint TOKEN_ALL_ACCESS = 0xF01FF;
        }

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
        private struct STARTUPINFO
        {
            public int cb;
            public string lpReserved;
            public string lpDesktop;
            public string lpTitle;
            public int dwX;
            public int dwY;
            public int dwXSize;
            public int dwYSize;
            public int dwXCountChars;
            public int dwYCountChars;
            public int dwFillAttribute;
            public int dwFlags;
            public short wShowWindow;
            public short cbReserved2;
            public IntPtr lpReserved2;
            public IntPtr hStdInput;
            public IntPtr hStdOutput;
            public IntPtr hStdError;
        }

        [StructLayout(LayoutKind.Sequential)]
        private struct PROCESS_INFORMATION
        {
            public IntPtr hProcess;
            public IntPtr hThread;
            public int dwProcessId;
            public int dwThreadId;
        }

        /// <summary>
        /// 起動時処理テスト用メソッド
        /// </summary>
        /// <param name="args">OnStartメソッドの引数</param>
        internal void TestStartupAndStop(string[] args)
        {
            this.OnStart(args);
            Console.ReadLine();
            this.OnStop();
        }

    }
}
