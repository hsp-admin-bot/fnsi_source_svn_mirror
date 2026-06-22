using Fnw.StatisticsTool.FrmLogin;
using System.Windows.Forms;
using System;
using Fnw.StatisticsTool.FrmDispCode;
using Fnw.StatisticsTool.Properties;

namespace Fnw.StatisticsTool
{
    /// <summary>
    /// フォームの基底クラス
    /// </summary>
    public class StatisticsBase : Form
    {
        #region 完了状態の情報（2015年度対応）

        /// <summary>
        /// 完了状態を取得・設定します。
        /// </summary>
        public ProcessItem ProcItem { get; set; }

        /// <summary>
        /// 完了状態とするかどうか問い合わせた結果を格納します。
        /// </summary>
        protected void ConfirmCompletionStatus(Boolean status)
        {
            if (ProcItem == null)
            {
                // 未設定の場合は何もしない
                return;
            }

            if (status)
            {
                if (MessageBox.Show("完了状態にしますか？", "確認", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes)
                {
                    ProcItem.Status = 1;
                }
                else
                {
                    ProcItem.Status = 0;
                }
            }
            else
            {
                ProcItem.Status = 0;
            }

            ProcItem.Timestamp = DateTime.Now;

            // 結果をXMLに保存
            CompletionStatus.Save();

            return;
        }
        #endregion

        #region 無操作タイムアウト
        /// <summary>
        /// 最後のアクティビティ日時
        /// </summary>
        public DateTime lastActivity;
        
        /// <summary>
        /// 無操作タイムアウト時間（分）
        /// </summary>
        private TimeSpan sessionTimeout = TimeSpan.FromMinutes(Settings.Default.SessionTimeout);

        /// <summary>
        /// 子画面表示中のフラグ
        /// </summary>
        private bool isChildFormVisible = false;

        /// <summary>
        /// セッションタイムアウトがアクティブかどうかを示すフラグ
        /// </summary>
        private bool isSessionTimeoutActive = false;

        /// <summary>
        /// 
        /// </summary>
        public StatisticsBase()
        {
        }

        /// <summary>
        /// コンストラクタ
        /// </summary>
        /// <param name="isUserLoggedIn"></param>
        public StatisticsBase(bool isUserLoggedIn = false)
        {
            lastActivity = DateTime.Now;
            // イベントハンドラの追加
            if (isUserLoggedIn)
            {
                RegisterEvents(this); // 基底クラスのコンストラクタでイベント登録
            }
        }

        /// <summary>
        /// 子コントロールに対して再帰的にイベントを登録
        /// </summary>
        /// <param name="control"></param>
        private void RegisterEvents(Control control)
        {
            control.MouseEnter += OnUserActivity;
            control.MouseLeave += OnUserActivity;
            control.MouseMove += OnUserActivity;
            control.KeyDown += OnUserActivity;

            foreach (Control child in control.Controls)
            {
                RegisterEvents(child); 
            }
        }

        /// <summary>
        /// ユーザー操作時の処理
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        public void OnUserActivity(object sender, EventArgs e)
        {
            // タイムアウト判定を行う
            if (!isChildFormVisible && IsSessionTimeout())
            {
                // タイムアウト処理がアクティブでない場合のみ実行
                if (!isSessionTimeoutActive)
                {
                    isSessionTimeoutActive = true; // フラグをセット
                    HandleSessionTimeout(); // タイムアウト処理を呼び出す
                }
            }
            // 最後のアクティビティを更新
            lastActivity = DateTime.Now; // ユーザーのアクティビティがあった時刻を更新
        }

        /// <summary>
        /// セッションのタイムアウトを確認する
        /// </summary>
        /// <returns></returns>
        private bool IsSessionTimeout()
        {
            return (DateTime.Now - lastActivity) > sessionTimeout;
        }

        /// <summary>
        /// セッションがタイムアウトした場合の処理
        /// </summary>
        private void HandleSessionTimeout()
        {
            DialogResult result = MessageBox.Show("セッションの有効期限が切れました。再ログインしますか？",
                "セッションタイムアウト", MessageBoxButtons.YesNo, MessageBoxIcon.Warning);
            this.Hide();
            if (result == DialogResult.Yes)
            {
                isSessionTimeoutActive = true; // タイムアウト処理が開始されたことを記録
                PerformReLogin();
            }
            else
            {
                Application.Exit();
            }
        }

        /// <summary>
        /// ユーザーが再ログインを行うための処理
        /// </summary>
        protected void PerformReLogin()
        {
            using (FrmLoginInput loginForm = new FrmLoginInput())
            {
                if (loginForm.ShowDialog() == DialogResult.OK)
                {
                    isSessionTimeoutActive = false; // フラグをリセット
                    this.Show();
                }
                else
                {
                    Application.Exit();
                }
            }
        }

        /// <summary>
        /// 指定された子フォームを表示し、ユーザーの応答を返すためのメソッド
        /// </summary>
        /// <param name="childForm"></param>
        public DialogResult ShowChildForm(Form childForm, string targetName ,string freeWord)
        {
            isChildFormVisible = true; // 子画面表示中フラグを設定
            childForm.FormClosed += (s, e) => isChildFormVisible = false; // 子画面が閉じられたときにフラグをリセット
                                                                          // childFormを適切な型にキャスト
                                                                          // childFormを適切な型にキャスト
            if (childForm is FrmDispCodeSelect meChildForm) // ここを実際のクラス名に変更
            {
                meChildForm.TargetName = targetName;
                 meChildForm.DefaultFreeWord = freeWord;
                 meChildForm.ShowList(); // ShowListメソッドを呼び出す
             }

            DialogResult result = childForm.ShowDialog(); // ダイアログを表示
            return result;
        }
        #endregion
    }
}
