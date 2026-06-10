using System;
using System.Reflection;
using System.Windows.Forms;

namespace CoopExtractXMLMaker
{
    static class Program
    {
        /// <summary>
        /// アプリケーションのメイン エントリ ポイントです。
        /// </summary>
        [STAThread]
        static void Main()
        {
            //アプリケーション名の取得
            Commons.AppName = Assembly.GetExecutingAssembly().GetName().Name;

            //Mutex名を決める（必ずアプリケーション固有の文字列に変更すること！）
            string mutexName = "CoopExtractXMLMaker";
            //Mutexオブジェクトを作成する
            bool createdNew;
            System.Threading.Mutex mutex =
                new System.Threading.Mutex(true, mutexName, out createdNew);

            //ミューテックスの初期所有権が付与されたか調べる
            if (createdNew == false)
            {
                //されなかった場合は、すでに起動していると判断して終了
                MessageBox.Show(Commons.AppName + "は既に起動しています。", Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Information);
                mutex.Close();
                return;
            }

            try
            {
                Application.EnableVisualStyles();
                Application.SetCompatibleTextRenderingDefault(false);

                Application.Run(new MyAppContext());
            }
            finally
            {
                //ミューテックスを解放する
                mutex.ReleaseMutex();
                mutex.Close();
            }
        }
    }
}
