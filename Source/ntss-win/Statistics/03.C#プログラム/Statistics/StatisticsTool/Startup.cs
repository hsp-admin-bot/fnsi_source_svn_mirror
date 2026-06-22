using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography.X509Certificates;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Fnw.StatisticsTool;
using Fnw.StatisticsTool.FrmLogin;
using Fnw.StatisticsTool.Properties;
using NKKCommon;


namespace Fnw.StatisticsTool
{
    /// <summary>
    /// フォーム表示制御用クラス
    /// </summary>
    internal sealed class Startup
    {
        #region 生成と破棄

        /// <summary>
        /// フォーム表示制御用クラスの新しいインスタンスを生成します。
        /// </summary>
        public Startup() { }

        /// <summary>
        /// デストラクタ
        /// </summary>
        ~Startup() { }

        #endregion

        #region メンバ関数定義

        /// <summary>
        /// 表示処理を開始します。
        /// </summary>
        public void Start()
        {
            // サインイン画面を表示
            var ret = FrmLoginInput.ShowSignInDialog();
            if (ret == DialogResult.Abort
                || ret == DialogResult.Cancel)
            {
                return;
            }

            LogManagement.LogMessage = "統計調査アプリが起動しました。";
            LogManagement.SetLogingProperties();
   
            // アプリケーション初期化処理実行
            if (!StatisticsLib.AppStartUp())
            {
                return;
            }

            var wResult = System.Windows.Forms.DialogResult.OK;

            while (true)
            {
                // メインメニューを表示
                using( var wDlg = new FrmStatistics())
                   wResult = wDlg.ShowDialog();
                // キャンセル時は抜ける
                if (wResult == System.Windows.Forms.DialogResult.Cancel)
                {
                    break;
                }
            }
        }

        #endregion
    }
}
