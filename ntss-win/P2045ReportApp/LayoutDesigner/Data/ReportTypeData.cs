using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// 帳票種別データ
    /// </summary>
    public class ReportTypeData
    {
        #region メンバプロパティ定義

        /// <summary>
        /// 帳票種別の取得及び設定を行います。
        /// </summary>
        public String ReportClass { get; set; } = String.Empty;

        /// <summary>
        /// 帳票種別名の取得及び設定を行います。
        /// </summary>
        public String ReportClassName { get; set; } = String.Empty;

        /// <summary>
        /// テンプレート繰返しをサポートしているかどうかの取得及び設定を行います。
        /// </summary>
        public Boolean IsSupportTempleteRepeat { get; set; } = false;

        #endregion
    }
}
