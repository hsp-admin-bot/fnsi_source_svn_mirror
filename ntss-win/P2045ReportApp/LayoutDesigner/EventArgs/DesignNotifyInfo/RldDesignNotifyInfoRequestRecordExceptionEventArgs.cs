using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// 例外情報記録要求イベントデータクラス
    /// </summary>
    public class RldDesignNotifyInfoRequestRecordExceptionEventArgs : RldDesignNotifyInfoEventArgs
    {
        #region 生成と破棄

        /// <summary>
        /// 例外情報と画面にメッセージボックスを表示するかどうかを指定してイベントデータクラスの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aEx"></param>
        /// <param name="aIsShowMsg"></param>
        public RldDesignNotifyInfoRequestRecordExceptionEventArgs(Exception aEx, bool aIsShowMsg) : base(EnumInfoType.RequestRecordException)
        {
            this.Exception = aEx;
            this.IsShowMessage = aIsShowMsg;
        }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// 発生した例外情報の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public Exception Exception { get; } = null;

        /// <summary>
        /// 画面にメッセージボックスを表示するかどうかの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public bool IsShowMessage { get; } = false;

        #endregion

    }
}
