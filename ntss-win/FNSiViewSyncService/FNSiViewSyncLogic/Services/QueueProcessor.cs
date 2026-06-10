using FNSiViewSyncLogicLib.Services;
using NKKLoggingLib;
using System;
using System.Collections.Concurrent;
using System.Threading.Tasks;

namespace FNSiViewSyncLogicLib.Service
{
    public static class QueueProcessor
    {
        private static int _maxDegreeOfParallelism = FNSiViewSyncSetting.ViewSyncCnt;

        static QueueProcessor()
        {
            Console.WriteLine("キューワーカー実行");
            for (int i = 0; i < _maxDegreeOfParallelism; i++)
            {
                Task.Factory.StartNew(ProcessQueue, TaskCreationOptions.LongRunning);
            }
        }

        public static void Enqueue(Action action)
        {
            Console.WriteLine("キュー登録");
            FNSiViewSyncSetting.Queue.Enqueue(action);
        }

        private static void ProcessQueue()
        {
            while (true)
            {
                if (FNSiViewSyncSetting.Queue.TryDequeue(out Action action))
                {
                    try
                    {
                        Console.WriteLine("キュー実行");
                        action();
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine("キュー失敗");
                        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, $"{ex.Message}:{ex.StackTrace}");
                        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"status=500, message=\"VIEWアプリ要求部エラー\", result=\"\"");
                    }
                }
                else
                {
                    Task.Delay(100).Wait(); // Avoid tight loop
                }
            }
        }

        public static void ClearQueue()
        {
            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, $"{FNSiViewSyncSetting.Queue.Count}件のキューを削除開始");
            while (FNSiViewSyncSetting.Queue.TryDequeue(out _))
            {
                Console.WriteLine("キュー削除");
            }
            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, $"キューを削除完了");
        }
    }
}
