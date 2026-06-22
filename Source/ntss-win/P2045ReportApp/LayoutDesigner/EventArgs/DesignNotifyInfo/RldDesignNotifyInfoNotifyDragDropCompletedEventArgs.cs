using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// ドラッグアンドドロップ操作完了イベント通知用データ
    /// </summary>
    public class RldDesignNotifyInfoNotifyDragDropCompletedEventArgs : RldDesignNotifyInfoEventArgs
    {
        #region 生成と破棄

        /// <summary>
        /// ドラッグアンドドロップ操作完了イベント通知用データクラスの新しいインスタンスを初期化します。
        /// </summary>
        public RldDesignNotifyInfoNotifyDragDropCompletedEventArgs() : base(EnumInfoType.NotifyDragDropCompleted) { }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// ドロップが完了したセルのアドレスの取得及び設定を行います。
        /// </summary>
        public String DroppedCellAddress { get; set; } = String.Empty;

		// add 8394 動作に関する指摘 吉 start
        public Boolean isRefreshAllFlag { get; set; } = true;
		// add 8394 動作に関する指摘 吉 end
        #endregion

    }
}
