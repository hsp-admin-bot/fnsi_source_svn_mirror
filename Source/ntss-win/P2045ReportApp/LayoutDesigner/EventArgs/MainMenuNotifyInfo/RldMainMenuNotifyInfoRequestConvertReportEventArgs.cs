using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// メインメニュー(コンバート)処理用パラメータデータクラス
    /// </summary>
    public class RldMainMenuNotifyInfoRequestConvertReportEventArgs : RldMainMenuNotifyInfoEventArgs
    {
        #region 生成と破棄

        /// <summary>
        /// メインメニュー(コンバート)処理用パラメータデータクラスの新しいインスタンスを初期化します。
        /// </summary>
        public RldMainMenuNotifyInfoRequestConvertReportEventArgs() : base(EnumInfoType.ConvertReport) { }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// 帳票種別の取得及び設定を行います。
        /// </summary>
        public String ReportType { get; set; } = String.Empty;

        /// <summary>
        /// テンプレート繰返しをサポートしているかどうかの取得及び設定を行います。
        /// </summary>
        public Boolean IsSupportTempleteRepeat { get; set; } = false;

        /// <summary>
        /// コンバートレイアウトファイルへのフルパスの取得及び設定を行います。
        /// </summary>
        public String ConvertFilePath { get; set; } = String.Empty;

        #endregion
    }
}
