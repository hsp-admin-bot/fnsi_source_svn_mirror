using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// メインメニュー(編集)処理用パラメータデータクラス
    /// </summary>
    public class RldMainMenuNotifyInfoRequestEditReportEventArgs : RldMainMenuNotifyInfoEventArgs
    {
        #region 生成と破棄

        /// <summary>
        /// メインメニュー(編集)処理用パラメータデータクラスの新しいインスタンスを初期化します。
        /// </summary>
        public RldMainMenuNotifyInfoRequestEditReportEventArgs() : base(EnumInfoType.EditReport) { }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// 帳票マスタデータの取得及び設定を行います。
        /// </summary>
        public MstReportData ReportData { get; set; } = null;

        #endregion

    }
}
