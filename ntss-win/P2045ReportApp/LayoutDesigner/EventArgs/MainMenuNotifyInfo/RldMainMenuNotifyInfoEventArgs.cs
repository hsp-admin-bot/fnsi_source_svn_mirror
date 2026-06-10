using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// メインメニュー画面で使用するイベントデータクラス
    /// </summary>
    public abstract class RldMainMenuNotifyInfoEventArgs : System.EventArgs
    {
        #region メンバ列挙体定義

        /// <summary>
        /// 通知種別
        /// </summary>
        public enum EnumInfoType
        {
            /// <summary>
            /// 新規作成
            /// </summary>
            NewReport = 0,
            /// <summary>
            /// 編集
            /// </summary>
            EditReport,
            // add 2021-02-19 No.517:FNW帳票レイアウトコンバート 趙 start
            /// <summary>
            /// コンバート
            /// </summary>
            ConvertReport,
            // add 2021-02-19 No.517:FNW帳票レイアウトコンバート 趙 end
            // add #11502 レイアウトデザイナに2件の管理者用機能を追加 高 start
            /// <summary>
            /// 一時ファイル
            /// </summary>
            TempReport,
            // add #11502 レイアウトデザイナに2件の管理者用機能を追加 高 end
            /// <summary>
            /// 非アクティブ
            /// </summary>
            Deactive
        }

        #endregion

        #region 生成と破棄

        /// <summary>
        /// 通知種別を指定して、メインメニュー画面で使用するイベントデータクラスの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aInfoType"></param>
        protected RldMainMenuNotifyInfoEventArgs(EnumInfoType aInfoType)
        {
            this.InfoType = aInfoType;
        }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// 通知種別の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public EnumInfoType InfoType { get; private set; }

        #endregion
    }
}
