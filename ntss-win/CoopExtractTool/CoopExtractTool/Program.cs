using System;
using System.Reflection;
using System.Windows.Forms;

namespace CoopExtractTool
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
            string mutexName = "CoopExtractTool";
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

                // Config設定ファイルを読み込む
                var ret = ConfigSettingManager.ReadXML();
                if (ret == Commons.RetCode_Nothing)
                {
                    MessageBox.Show("設定ファイルCoopExtractTool.configがEXEと同じ場所に見つかりませんでした。", Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
                }
                else if (ret == Commons.RetCode_Error)
                {
                    MessageBox.Show("設定ファイルCoopExtractTool.configの読み込み中にエラーが発生しました。", Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
                }

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
