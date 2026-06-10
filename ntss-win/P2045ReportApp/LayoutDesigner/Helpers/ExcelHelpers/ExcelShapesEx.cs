using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Excel = Microsoft.Office.Interop.Excel;

namespace LayoutDesigner
{
    /// <summary>
    /// Microsoft.Office.Interop.Excel.Shapes 拡張クラス
    /// </summary>
    public class ExcelShapesEx : AbstructExcelComEx
    {
        #region 生成と破棄

        /// <summary>
        /// Microsoft.Office.Interop.Excel.Shapes インターフェースを指定して、Microsoft.Office.Interop.Excel.Shapes 拡張クラスの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aXlShapes"></param>
        private ExcelShapesEx(Excel.Shapes aXlShapes) : base(aXlShapes) { }

        /// <summary>
        /// Microsoft.Office.Interop.Excel.Worksheet インターフェースを指定して、Microsoft.Office.Interop.Excel.Shapes 拡張クラスの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aXlSheet"></param>
        private ExcelShapesEx(Excel.Worksheet aXlSheet) : this(aXlSheet.Shapes) { }

        /// <summary>
        /// Microsoft.Office.Interop.Excel.Worksheet 拡張クラスのインスタンスを指定して、Microsoft.Office.Interop.Excel.Shapes 拡張クラスの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aXlSheet"></param>
        public ExcelShapesEx(ExcelWorksheetEx aXlSheet) : this(aXlSheet.Worksheet.Shapes) { }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// Microsoft.Office.Interop.Excel.Shapes インターフェースへの参照の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public Excel.Shapes Shapes
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                return base.XlObject as Excel.Shapes;
            }
        }

        #endregion

    }
}
