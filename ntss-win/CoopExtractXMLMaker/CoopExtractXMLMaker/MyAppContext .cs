using System.Windows.Forms;

namespace CoopExtractXMLMaker
{
    /// <summary>
    /// 画面遷移をコントロールするクラス
    /// </summary>
    class MyAppContext : ApplicationContext
    {
        /// <summary>
        /// 設定値読み込み画面
        /// </summary>
        private FormSetData formSetData = null;

        /// <summary>
        /// 設定作成画面
        /// </summary>
        private FormMakeMain formMakeMain = null;

        /// <summary>
        /// コンストラクタ
        /// </summary>
        public MyAppContext()
        {
            // 設定値読み込み画面を表示する
            ShowFormSetData();
        }

        /// <summary>
        /// 設定値読み込み画面を表示する
        /// </summary>
        private void ShowFormSetData()
        {
            if (formSetData == null)
            {
                formSetData = new FormSetData();
                formSetData.FormClosed += OnFormSetDataClosed;
                formSetData.VisibleChanged += FormSetData_VisibleChanged;
            }
            formSetData.Show();
        }

        /// <summary>
        /// 設定値読み込み画面の表示状態変更時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void FormSetData_VisibleChanged(object sender, System.EventArgs e)
        {
            if (formSetData.Visible == true) return;

            if (formSetData.DialogResult == DialogResult.OK)
            {
                // 設定作成画面を表示する
                ShowFormMakeMain();
            }
            else
            {
                ExitThread(); // アプリケーション終了
            }
        }

        /// <summary>
        /// 設定値読み込み画面が閉じられた時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void OnFormSetDataClosed(object sender, FormClosedEventArgs e)
        {
            ExitThread(); // アプリケーション終了
        }

        /// <summary>
        /// 設定作成画面を表示する
        /// </summary>
        private void ShowFormMakeMain()
        {
            formMakeMain = new FormMakeMain();
            formMakeMain.FormClosed += OnFormMakeMain;
            formMakeMain.Show();
        }

        /// <summary>
        /// 設定作成画面が閉じれたとき
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void OnFormMakeMain(object sender, FormClosedEventArgs e)
        {
            if (formMakeMain.DialogResult == DialogResult.Cancel)
            {
                // 設定値読み込み画面を表示する
                ShowFormSetData();
            }
            else
            {
                ExitThread(); // アプリケーション終了
            }
        }
    }
}
