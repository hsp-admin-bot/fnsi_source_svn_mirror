//----------------------------------------------------------------------------------------------------
//
//----------------------------------------------------------------------------------------------------
using System;
using System.IO;
using System.Linq;
using System.Text;
using System.Data;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.ServiceProcess;
using Microsoft.Win32.SafeHandles;

//----------------------------------------------------------------------------------------------------
// 名前空間:NKKLoggingLib
//----------------------------------------------------------------------------------------------------
using NKKLoggingLib;
//----------------------------------------------------------------------------------------------------
//  名前空間:NKKWeightLib
//----------------------------------------------------------------------------------------------------
using NKKWeightLib;
//----------------------------------------------------------------------------------------------------


//----------------------------------------------------------------------------------------------------
//
//----------------------------------------------------------------------------------------------------
namespace NKKWeightService
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// NKKWeightServiceクラス定義
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public partial class NKKWeightService : ServiceBase
    {
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サービス名称
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static readonly String SERVICE_NAME = System.Reflection.Assembly.GetExecutingAssembly().GetName().Name;
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// NKKWeightクラスオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private NKKWeight m_NkkWeight = null;

        private const string TRAY_PROCESS_NAME = "FNWSiScaleTool";
        private const string TRAY_EXE_NAME = "FNWSiScaleTool.exe";
        private static int s_trayLaunchAttempted = 0;
        ////----------------------------------------------------------------------------------------------------
        ///// <summary>
        ///// 表示用処理ログ通知サーバーオブジェクト
        ///// </summary>
        ////----------------------------------------------------------------------------------------------------
        //private TdcViewLogServer m_ViewLogServer = null;
        ////----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// コンストラクタ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public NKKWeightService()
        {
            InitializeComponent();

            // ログオブジェクト取得
            NKKLogging log = NKKLogging.GetInstance();

            // 各オブジェクト構築
            this.m_NkkWeight = new NKKWeight(AppDomain.CurrentDomain.BaseDirectory);
            //this.m_ViewLogServer = new TdcViewLogServer(TdcViewLogModule.GetInstance().ViewLog);
            //this.m_ViewLogServer.LogExt = "VIEW";

            // ログ記録
            log.AddLogInfo(DateTime.Now, NKKWeightService.SERVICE_NAME, NKKLogging.LOGGING_CLASS.INFO, "サービス構築完了");
        }
        //----------------------------------------------------------------------------------------------------


        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サービス開始処理
        /// </summary>
        /// <param name="args"></param>
        //----------------------------------------------------------------------------------------------------
        protected override void OnStart(string[] args)
        {
            // TODO: サービスを開始するためのコードをここに追加します。

            // ログオブジェクト取得
            NKKLogging log = NKKLogging.GetInstance();

            try
            {
                // OnStart処理開始
                log.AddLogInfo(DateTime.Now, NKKWeightService.SERVICE_NAME, NKKLogging.LOGGING_CLASS.INFO, "OnStart処理開始");

                // 以下の処理で失敗した場合はthrowされる

                // NKKWeight初期化処理
                if (this.m_NkkWeight.Start() == true)
                {
                    TryStartTrayInActiveUserSession(log);
                }
                else
                {
                    throw (new Exception("NKKWeight初期化、待ち受け失敗"));
                }

                // OnStart処理終了
                log.AddLogInfo(DateTime.Now, NKKWeightService.SERVICE_NAME, NKKLogging.LOGGING_CLASS.INFO, "OnStart処理終了");
            }
            catch (Exception ex)
            {
                // ログ記録：エラー
                log.AddLogInfo(DateTime.Now, NKKWeightService.SERVICE_NAME, NKKLogging.LOGGING_CLASS.ERROR, String.Format("Error,{0}", ex.Message));

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

                Process[] existing = Process.GetProcessesByName(TRAY_PROCESS_NAME);
                if (existing.Any(p =>
                {
                    try { return p.SessionId == activeSessionId; } catch { return false; }
                }))
                {
                    log.AddLogInfo(DateTime.Now, SERVICE_NAME, NKKLogging.LOGGING_CLASS.INFO, "Tray起動不要: 既に起動済み(Session一致)");
                    return;
                }

                string baseDir = AppDomain.CurrentDomain.BaseDirectory;
                string trayExePath = Path.Combine(baseDir, TRAY_EXE_NAME);
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
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サービス停止処理
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        protected override void OnStop()
        {
            // TODO: サービスを停止するのに必要な終了処理を実行するコードをここに追加します。

            // ログオブジェクト取得
            NKKLogging log = NKKLogging.GetInstance();

            try
            {
                // OnStop処理開始
                log.AddLogInfo(DateTime.Now, NKKWeightService.SERVICE_NAME, NKKLogging.LOGGING_CLASS.INFO, "OnStop処理開始");

                //// Tool待ち受け処理停止
                //this.m_ViewLogServer.StopListner();

                // NKKWeight終了
                this.m_NkkWeight.Stop();

                // OnStop処理終了
                log.AddLogInfo( DateTime.Now, NKKWeightService.SERVICE_NAME, NKKLogging.LOGGING_CLASS.INFO, "OnStop処理終了");
            }
            catch (Exception ex)
            {
                // ログ記録：エラー
                log.AddLogInfo(DateTime.Now, NKKWeightService.SERVICE_NAME, NKKLogging.LOGGING_CLASS.ERROR, String.Format("Error,{0}", ex.Message));

                throw;
            }
        }
        //----------------------------------------------------------------------------------------------------
    }
    //----------------------------------------------------------------------------------------------------
}
//----------------------------------------------------------------------------------------------------
