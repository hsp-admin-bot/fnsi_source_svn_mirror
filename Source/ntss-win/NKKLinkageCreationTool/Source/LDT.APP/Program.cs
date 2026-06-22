using LDT.APP.DI;
using LDT.APP.Module;
using LDT.APP.Views;
using LDT.LOG;
using LDT.SERVICE.Configuration;
using System;
using System.Windows.Forms;

namespace LDT.APP
{
  internal static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        private static void Main()
        {
            LogHelper.CreateInstance();
            // Register global exception
            AppDomain.CurrentDomain.UnhandledException += new UnhandledExceptionEventHandler(AppGlobalHandler);
            AppSettingConfig.LoadConfig();
            ApplicationModule module = new ApplicationModule();
            module.Dispose();
            CompositionRoot.Wire(module);
            Application.EnableVisualStyles();
            LoginView view = CompositionRoot.Resolve<ILoginView>() as LoginView;
            Application.Run(view);
        }

        private static void AppGlobalHandler(object sender, UnhandledExceptionEventArgs args)
        {
            Exception e = (Exception)args.ExceptionObject;
            LogHelper.LogError("APP", e);
            Application.SetCompatibleTextRenderingDefault(false);
        }
    }
}
