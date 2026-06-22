using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceProcess;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace NKKPrintServer
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
                var service1 = new NKKPrintServer();
                service1.TestStartupAndStop(null);
            }
            else
            {
                ServiceBase[] ServicesToRun;
                ServicesToRun = new ServiceBase[]
                {
                    new NKKPrintServer()
                };
                ServiceBase.Run(ServicesToRun);
            }
        }
    }
}
