using System.Windows.Forms;

namespace CoopExtractTool
{
    /// <summary>
    /// 画面遷移をコントロールするクラス
    /// </summary>
    class MyAppContext : ApplicationContext
    {
        /// <summary>
        /// 接続画面
        /// </summary>
        private CoopExtractTool.FormConnection formConnection;

        /// <summary>
        /// FNW連携設定情報画面
        /// </summary>
        private CoopExtractTool.FormDBView formDBView;

        /// <summary>
        /// FNSi連携設定変換結果
        /// </summary>
        private CoopExtractTool.FormCSVView formCSVView;

        /// <summary>
        /// コンストラクタ
        /// </summary>
        public MyAppContext()
        {
            // 接続画面を表示する
            ShowFormConnection();
        }

        /// <summary>
        /// 接続画面を表示する
        /// </summary>
        private void ShowFormConnection()
        {
            formConnection = new CoopExtractTool.FormConnection();
            formConnection.FormClosed += OnFormConnectionClosed;
            formConnection.Show();
        }

        /// <summary>
        /// 接続画面が閉じられた時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void OnFormConnectionClosed(object sender, FormClosedEventArgs e)
        {
            if (formConnection.DialogResult == DialogResult.OK)
            {
                // FNW連携設定情報画面を表示する
                ShowFormDBView();
            }
            else
            {
                ExitThread(); // アプリケーション終了
            }
        }

        /// <summary>
        /// FNW連携設定情報画面を表示する
        /// </summary>
        private void ShowFormDBView()
        {
            formDBView = new CoopExtractTool.FormDBView();
            formDBView.FormClosed += OnFormDBViewClosed;
            formDBView.Show();
        }

        /// <summary>
        /// FNW連携設定情報画面が閉じれたとき
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void OnFormDBViewClosed(object sender, FormClosedEventArgs e)
        {
            if (formDBView.DialogResult == DialogResult.OK)
            {
                // CSV確認画面を表示する
                ShowFormCSVView();
            }
            else if (formDBView.DialogResult == DialogResult.Cancel)
            {
                // 接続画面を表示する
                ShowFormConnection();
            }
            else
            {
                ExitThread(); // アプリケーション終了
            }
        }

        /// <summary>
        /// CSV確認画面を表示する
        /// </summary>
        private void ShowFormCSVView()
        {
            formCSVView = new CoopExtractTool.FormCSVView();
            formCSVView.FormClosed += OnFormCSVViewClosed;
            formCSVView.Show();
        }

        /// <summary>
        /// CSV確認画面が閉じられたとき
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void OnFormCSVViewClosed(object sender, FormClosedEventArgs e)
        {
            if (formCSVView.DialogResult == DialogResult.OK)
            {
                ExitThread(); // アプリケーション終了
            }
            else if (formCSVView.DialogResult == DialogResult.Cancel)
            {
                // 接続画面を表示する
                ShowFormConnection();
            }
            else
            {
                ExitThread(); // アプリケーション終了
            }
        }
    }
}
