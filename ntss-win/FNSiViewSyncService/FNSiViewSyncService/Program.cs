using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceProcess;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace FNSiViewSyncService
{
    static class Program
    {
        /// <summary>
        /// アプリケーションのメイン エントリ ポイントです。
        /// </summary>
        static void Main()
        {
            if (Environment.UserInteractive)
            {
                // テストモード
                var serviceTest = new FNSiViewSyncService();
                serviceTest.TestStartupAndStop(null);
            }
            else
            {
                ServiceBase[] ServicesToRun;
                ServicesToRun = new ServiceBase[]
                {
                    new FNSiViewSyncService()
                };
                ServiceBase.Run(ServicesToRun);
            }
        }
    }
}
