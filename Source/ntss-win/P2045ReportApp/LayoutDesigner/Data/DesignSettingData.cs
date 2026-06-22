using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// 設定データクラス
    /// </summary>
    public class DesignSettingData : ReportTypeData
    {
        #region メンバプロパティ定義

        /// <summary>
        /// レポートCDの取得及び設定を行います。
        /// </summary>
        public String ReportCode { get; set; } = String.Empty;

        /// <summary>
        /// テンプレート繰返しが設定されているかどうかの取得及び設定を行います。
        /// </summary>
        public String HasTemplete { get; set; } = String.Empty;

        #endregion
    }
}
