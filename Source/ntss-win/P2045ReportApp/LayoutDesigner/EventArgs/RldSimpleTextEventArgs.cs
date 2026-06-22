using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// 帳票レイアウトデザイナ用簡易テキスト転送イベントデータクラス
    /// </summary>
    public class RldSimpleTextEventArgs : System.EventArgs
    {
        #region 生成と破棄

        /// <summary>
        /// 転送するテキストを指定して帳票レイアウトデザイナ用簡易テキスト転送イベントデータクラスの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aText"></param>
        public RldSimpleTextEventArgs(String aText) : base() { this.Text = aText; }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// テキストの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public String Text { get; protected set; } = String.Empty;

        #endregion
    }
}
