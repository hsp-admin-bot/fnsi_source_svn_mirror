using NKKLoggingLib;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FNSiViewSyncLogicLib.Services
{
    public class LogService
    {
        /// <summary>
        /// サービス名称
        /// </summary>
        private static readonly String SERVICE_NAME = String.Format("{0,-20}", System.Reflection.Assembly.GetExecutingAssembly().GetName().Name);

        private static readonly NKKLogging log = NKKLogging.GetInstance();
        /// <summary>
        /// ログ記録
        /// </summary>
        /// <param name="dtNow">発生日時</param>
        /// <param name="LoggingClass">ログ区分</param>
        /// <param name="strMesssage">記録メッセージ</param>
        public static void AddLogInfo(DateTime dtNow, NKKLogging.LOGGING_CLASS LoggingClass, String strMesssage)
        {
            // ログ記録
            Console.WriteLine(strMesssage);
            if(FNSiViewSyncSetting.LogDebugMode == 0 && LoggingClass == NKKLogging.LOGGING_CLASS.DEBUG)
            {
                return;
            }
            log.AddLogInfo(dtNow, SERVICE_NAME, LoggingClass, strMesssage);
        }
    }
}
