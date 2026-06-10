using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// ダイアログ表示要求イベント通知用データ
    /// </summary>
    public class RldDesignNotifyInfoRequestOpenDialogEventArgs : RldDesignNotifyInfoEventArgs
    {
        #region 生成と破棄

        /// <summary>
        /// 表示するダイアログウィンドウへの参照を指定してダイアログ表示要求イベント通知用データの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aTarget"></param>
        public RldDesignNotifyInfoRequestOpenDialogEventArgs(System.Windows.Forms.Form aTarget) : base(EnumInfoType.RequestOpenDialog)
        {
            this.TargetForm = aTarget;
        }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// 表示するダイアログウィンドウへの参照の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public System.Windows.Forms.Form TargetForm { get; private set; } = null;

        /// <summary>
        /// 全ての子ウィンドウをロックするかどうかの取得及び設定を行います。
        /// </summary>
        public Boolean IsAllWindowLock { get; set; } = false;

        /// <summary>
        /// Excel のレイアウトシートを保護するかどうかの取得及び設定を行います。
        /// </summary>
        public Boolean IsProtectLayoutSheet { get; set; } = false;

        #endregion

    }
}
