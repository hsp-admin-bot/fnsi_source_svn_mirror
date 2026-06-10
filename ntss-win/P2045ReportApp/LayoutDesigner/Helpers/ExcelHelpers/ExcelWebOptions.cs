using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Excel = Microsoft.Office.Interop.Excel;

namespace LayoutDesigner
{
    /// <summary>
    /// Microsoft.Office.Interop.Excel.WebOptions 拡張クラス
    /// </summary>
    internal class ExcelWebOptions : AbstructExcelComEx
    {
        #region 生成と破棄

        /// <summary>
        /// Microsoft.Office.Interop.Excel.Workbook 拡張クラスのインスタンスを指定して、 Microsoft.Office.Interop.Excel.WebOptions 拡張クラスの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aXlBook"></param>
        public ExcelWebOptions(ExcelWorkbookEx aXlBook) : base(aXlBook.Workbook.WebOptions) { }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// Microsoft.Office.Interop.Excel.WebOptions インターフェースへの参照の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public Excel.WebOptions WebOptions
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                return base.XlObject as Excel.WebOptions;
            }
        }

        #endregion
    }
}
