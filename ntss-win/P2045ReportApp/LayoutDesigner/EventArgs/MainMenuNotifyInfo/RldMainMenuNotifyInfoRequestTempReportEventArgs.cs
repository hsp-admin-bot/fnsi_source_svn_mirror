using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// メインメニュー(一時ファイル)処理用パラメータデータクラス
    /// </summary>
    public class RldMainMenuNotifyInfoRequestTempReportEventArgs : RldMainMenuNotifyInfoEventArgs
    {
        #region 生成と破棄

        /// <summary>
        /// メインメニュー(一時ファイル)処理用パラメータデータクラスの新しいインスタンスを初期化します。
        /// </summary>
        public RldMainMenuNotifyInfoRequestTempReportEventArgs() : base(EnumInfoType.TempReport) { }

        #endregion

        #region メンバプロパティ定義
        
        /// <summary>
        /// 一時ファイルのフルパスの取得及び設定を行います。
        /// </summary>
        public String TempFilePath { get; set; } = String.Empty;

        #endregion

    }
}
