using System;
using System.Windows.Forms;
using NKSConverter.Properties;
using Fnw.IOControl.Log;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Reflection;
using System.Xml;
using System.IO;
using ConvertCommon.Common;

namespace NKSConverter
{
    static class Program
    {
        //add #7445 二重起動  鄭晨 start      
        [DllImport("User32.dll")]
        private static extern bool ShowWindowAsync(IntPtr hWnd, int cmdShow);        
        [DllImport("User32.dll")]
        private static extern bool SetForegroundWindow(IntPtr hWnd);
        private const int WS_SHOWNORMAL = 1;
        //add #7445 二重起動  鄭晨 end

        /// <summary>
        /// アプリケーションのメイン エントリ ポイントです。
        /// </summary>
        [STAThread]
        static void Main(string[] args)
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            // add #12685 単体アプリ、サービスの名称見直し limingzhe start
            TaskbarAppIdentity.SetProcessAppUserModelId();
            // add #12685 単体アプリ、サービスの名称見直し limingzhe end
            Process instance = RunningInstance();         
            if (instance == null)
            {
                if (LogFileError.NO_ERROR != LogManager.Init(
                                                    Settings.Default.TraceFolder,
                                                    Settings.Default.TraceFile,
                                                    Settings.Default.TraceSize,
                                                    Settings.Default.TraceNumber,
                                                    Settings.Default.TraceSpan,
                                                    Settings.Default.TraceIsZip,
                                                    Settings.Default.ErrorFolder,
                                                    Settings.Default.ErrorFile,
                                                    Settings.Default.ErrorSize,
                                                    Settings.Default.ErrorNumber,
                                                    Settings.Default.ErrorSpan,
                                                    Settings.Default.ErrorIsZip))
                {
                    MessageBox.Show("ログ初期化に失敗しました\r\n設定ファイルを見直してください", "初期化エラー", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                    return;
                }

                //add 12338 start
                ConfigurationInitialization();
                //add 12388 end

                //7997 start
                getIndTimePeriod();
                //7997 end

                if (args != null && args.Length > 0 && "diff".Equals(args[0]))
                {
                    // 定時起動
                    FnwService fnwService = new FnwService();
                    fnwService.OnStart();
                    //System.Environment.Exit(0);
                }
                else
                {
                    // add #9686 指示コンバートで終了日ありにも関わらずそれ以降も延長されている zkm start
                    try
                    {
                    // add #9686 指示コンバートで終了日ありにも関わらずそれ以降も延長されている zkm end

                        //Application.Run(new ConvertForm());
                        Application.Run(new FrmSignIn());
                        // add #9686 指示コンバートで終了日ありにも関わらずそれ以降も延長されている zkm start
                    }
                    catch (Exception e)
                    {
                        LogManager.WriteErrorLog(null, null, "コンバートエラーが発生しました。", e);
                    }
                    // add #9686 指示コンバートで終了日ありにも関わらずそれ以降も延長されている zkm end
                }
            }
            else
            {
                HandleRunningInstance(instance);
            }
        }


        private static void ConfigurationInitialization()
        {
            
            string configPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "FNW2FNSI_Converter.config");
            XmlDocument doc = new XmlDocument();
            doc.Load(configPath);
            XmlNode commonSection = doc.SelectSingleNode("/configuration/CommonSection");

            string oracleIp = commonSection.SelectSingleNode("OracleIp").InnerText;
            string oracleUserId = commonSection.SelectSingleNode("OracleUserId").InnerText;
            string oraclePassword = commonSection.SelectSingleNode("OraclePassword").InnerText;
            string oraclePort = commonSection.SelectSingleNode("OraclePort").InnerText;
            CommonConfig.ZipFilePassword = commonSection.SelectSingleNode("ZipFilePassword").InnerText;
            CommonConfig.uploadServPathValue = commonSection.SelectSingleNode("uploadServPathValue").InnerText;
            CommonConfig.DefaultExportFolderPathLen = commonSection.SelectSingleNode("DefaultExportFolderPathLen").InnerText;
            CommonConfig.ConvertRestWebServerIp = commonSection.SelectSingleNode("ConvertRestWebServerIp").InnerText;
            CommonConfig.LoadBalancing = commonSection.SelectSingleNode("LoadBalancing").InnerText;
            CommonConfig.oraConnStr = $"User Id={oracleUserId};Password={oraclePassword};Data Source={oracleIp}:{oraclePort}/nkkfn3;Pooling=yes;Max Pool Size=30;Min Pool Size=5;Connection Lifetime=0;";
           

        }

        private static void getIndTimePeriod()
        {

            string sql = @" DAY_AGG AS (
                SELECT
                    PATID,
                    TO_DATE(PROC_DATE, 'YYYYMMDD') AS PROC_DT,
                    MAX(TO_SERIES_CD) KEEP(
                        DENSE_RANK LAST ORDER BY CTL_NO
                    ) AS FINAL_TO,
                    MAX(FROM_SERIES_CD) KEEP(
                        DENSE_RANK FIRST ORDER BY CTL_NO
                    ) AS FIRST_FROM
                FROM SYS_PAT_MOVE_PLAN
                WHERE STATUS = '1'
                  AND DEL_FLG = 0
                GROUP BY PATID, PROC_DATE
            ),
            SEQ AS(
                SELECT
                    PATID,
                    PROC_DT,
                    FIRST_FROM,
                    FINAL_TO,
                    ROW_NUMBER() OVER (
                        PARTITION BY PATID
                        ORDER BY PROC_DT
                    ) rn,
                    LEAD(PROC_DT) OVER(
                        PARTITION BY PATID
                        ORDER BY PROC_DT
                    ) next_dt
                FROM DAY_AGG
            ), Tohospital as (
            SELECT
                PATID,
                SERIES_CD,
                START_DATE,
                END_DATE
            FROM(
                SELECT
                    PATID,
                    FIRST_FROM AS SERIES_CD,
                    DATE '1900-01-01' AS START_DATE,
                    PROC_DT  AS END_DATE
                FROM SEQ
                WHERE rn = 1
                UNION ALL
                SELECT
                    PATID,
                    FINAL_TO AS SERIES_CD,
                    PROC_DT AS START_DATE,
                    NVL(
                        next_dt - 1,
                        LAST_DAY(ADD_MONTHS(TRUNC(SYSDATE, 'MM'), 12)) + 1
                    ) AS END_DATE
                FROM SEQ
            )), NoTohospital as (
              SELECT PATID,SERIES_CD,DATE '1900-01-01' AS START_DATE,LAST_DAY(ADD_MONTHS(TRUNC(SYSDATE, 'MM'), 12)) + 1 AS END_DATE 
               FROM 	SYS_PAT_SERIES_FACILITY
			WHERE	 MAIN_FLG='1' and PATID NOT IN (SELECT PATID FROM  Tohospital))
                , IndTimePeriod as (
                 select * from  Tohospital UNION ALL select * from  NoTohospital
                )
            ";
            CommonConfig.NoWITHIndTimePeriod = ", "+ sql;
            

        }

        //add #7445 二重起動  鄭晨 start
        /// <summary> 
        /// 実行されているプログラムを表示。 
        /// </summary> 
        public static void HandleRunningInstance(Process instance)
        {
           
            ShowWindowAsync(instance.MainWindowHandle, WS_SHOWNORMAL); 
            SetForegroundWindow(instance.MainWindowHandle);            
        }
        /// <summary> 
        /// 実行中のインスタンスを取得し、実行していないインスタンスはnullに戻ります
        /// </summary> 
        public static Process RunningInstance()
        {
            Process current = Process.GetCurrentProcess();
            Process[] processes = Process.GetProcessesByName(current.ProcessName);
            foreach (Process process in processes)
            {
                if (process.Id != current.Id)
                {
                    if (Assembly.GetExecutingAssembly().Location.Replace("/", "\\") == current.MainModule.FileName)
                    {
                        return process;
                    }
                }
            }
            return null;
        }
        //add #7445 二重起動  鄭晨 end
    }
}
