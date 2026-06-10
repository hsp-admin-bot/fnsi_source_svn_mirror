using NKKWeightScaleApp.Services;
using NKKWeightScaleApp.Views;
using System;
using System.Windows.Forms;

namespace NKKWeightScaleApp
{
    internal static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        private static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.ThreadException += Application_ThreadException;
            Application.SetUnhandledExceptionMode(UnhandledExceptionMode.CatchException);
            Application.Run(new FrmLoadingScreen());
        }

        private static void Application_ThreadException(object sender, System.Threading.ThreadExceptionEventArgs e)
        {
            LoggerController.WriteException(e.Exception, "Main");
            Console.WriteLine(e);
        }
    }
}