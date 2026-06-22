using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// デザイン設定ファイルの保存/破棄要求通知用データ
    /// </summary>
    public class RldDesignNotifyInfoRequestSaveDropFileEventArgs : RldDesignNotifyInfoEventArgs
    {
        #region 生成と破棄

        /// <summary>
        /// デザイン設定ファイルの保存/破棄要求通知用データの新しいインスタンスを初期化します。
        /// </summary>
        public RldDesignNotifyInfoRequestSaveDropFileEventArgs() : base(EnumInfoType.RequestSaveDropFile) { }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// 保存するかどうかの取得及び設定を行います。
        /// </summary>
        public Boolean IsSave { get; set; } = false;

        /// <summary>
        /// 一時ファイルとして処理を行うかどうかの取得及び設定を行います。
        /// </summary>
        public Boolean IsWorkFile { get; set; } = false;

        /// <summary>
        /// 処理を途中で中止したかどうかの取得及び設定を行います。
        /// </summary>
        public Boolean IsCanceled { get; set; } = true;

        /// <summary>
        /// 処理結果の取得及び設定を行います。
        /// </summary>
        public Boolean Result { get; set; } = false;

        /// <summary>
        /// 処理結果メッセージの取得及び設定を行います。
        /// </summary>
        public String ResultMessage { get; set; } = String.Empty;

        /// <summary>
        /// 名前を付けて保存フラグ
        /// </summary>
        public bool IsSaveAs { get; internal set; }

        #endregion
    }
}
