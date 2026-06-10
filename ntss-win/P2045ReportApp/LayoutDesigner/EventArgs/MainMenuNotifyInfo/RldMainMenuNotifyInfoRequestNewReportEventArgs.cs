using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// メインメニュー(新規作成)処理用パラメータデータクラス
    /// </summary>
    public class RldMainMenuNotifyInfoRequestNewReportEventArgs : RldMainMenuNotifyInfoEventArgs
    {
        #region 生成と破棄

        /// <summary>
        /// メインメニュー(新規作成)処理用パラメータデータクラスの新しいインスタンスを初期化します。
        /// </summary>
        public RldMainMenuNotifyInfoRequestNewReportEventArgs() : base(EnumInfoType.NewReport) { }

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
        /// サンプルレイアウトファイルから作成するかどうかの取得及び設定を行います。
        /// </summary>
        public Boolean IsModelFile { get; set; } = false;

        /// <summary>
        /// サンプルレイアウトファイルへのフルパスの取得及び設定を行います。
        /// </summary>
        public String ModelFilePath { get; set; } = String.Empty;

        #endregion
    }
}
