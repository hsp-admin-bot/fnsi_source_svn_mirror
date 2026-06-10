using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// プレビュー表示要求通知用データ
    /// </summary>
    public class RldDesignNotifyInfoRequestPreviewEventArgs : RldDesignNotifyInfoEventArgs
    {
        #region メンバ列挙体定義

        /// <summary>
        /// 表示モード
        /// </summary>
        public enum EnumMode
        {
            /// <summary>
            /// 初期値
            /// </summary>
            None = 0,
            /// <summary>
            /// Excel で表示
            /// </summary>
            Excel,
            /// <summary>
            /// ブラウザで表示
            /// </summary>
            Html
        }

        #endregion

        #region 生成と破棄

        /// <summary>
        /// 表示モードを指定してプレビュー表示要求通知用データの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aMode"></param>
        public RldDesignNotifyInfoRequestPreviewEventArgs(EnumMode aMode) : base(EnumInfoType.RequestPreview)
        {
            this.Mode = aMode;
        }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// 表示モードの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public EnumMode Mode { get; private set; } = EnumMode.None;

        #endregion

    }
}
