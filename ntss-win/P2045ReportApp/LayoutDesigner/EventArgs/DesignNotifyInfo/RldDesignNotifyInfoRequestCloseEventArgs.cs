using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// デザイン画面の終了要求通知用データ
    /// </summary>
    public class RldDesignNotifyInfoRequestCloseEventArgs : RldDesignNotifyInfoEventArgs
    {
        #region 生成と破棄

        /// <summary>
        /// 終了理由を指定してデザイン画面の終了要求通知用データの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="e"></param>
        public RldDesignNotifyInfoRequestCloseEventArgs(System.Windows.Forms.FormClosingEventArgs e, System.Windows.Forms.DialogResult aDialogResult) : this(e.CloseReason, e.Cancel, aDialogResult) { }

        /// <summary>
        /// 終了理由を指定してデザイン画面の終了要求通知用データの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aReason"></param>
        /// <param name="aIsCancel"></param>
        public RldDesignNotifyInfoRequestCloseEventArgs(System.Windows.Forms.CloseReason aReason, Boolean aIsCancel, System.Windows.Forms.DialogResult aDialogResult) : base(EnumInfoType.RequestCloseApp)
        {
            this.CloseReason = aReason;
            this.Cancel = aIsCancel;
            this.DialogResult = aDialogResult;
        }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// 終了理由の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public System.Windows.Forms.CloseReason CloseReason { get; } = System.Windows.Forms.CloseReason.None;

        /// <summary>
        /// 終了をキャンセルするかどうかの取得及び設定を行います。
        /// </summary>
        public Boolean Cancel { get; set; } = false;

        /// <summary>
        /// 終了結果の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public System.Windows.Forms.DialogResult DialogResult { get; } = System.Windows.Forms.DialogResult.None;

        #endregion
    }
}
