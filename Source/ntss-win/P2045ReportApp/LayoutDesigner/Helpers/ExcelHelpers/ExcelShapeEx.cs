using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Excel = Microsoft.Office.Interop.Excel;

namespace LayoutDesigner
{
    /// <summary>
    /// Microsoft.Office.Interop.Excel.Shape 拡張クラス
    /// </summary>
    public class ExcelShapeEx : AbstructExcelComEx
    {
        #region 生成と破棄

        /// <summary>
        /// Microsoft.Office.Interop.Excel.Shape インターフェースを指定して、Microsoft.Office.Interop.Excel.Shape 拡張クラスの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aXlShape"></param>
        public ExcelShapeEx(Excel.Shape aXlShape) : base(aXlShape) { }

        /// <summary>
        /// Microsoft.Office.Interop.Excel.Shapes 拡張クラスのインスタンスとインデックスを指定して、Microsoft.Office.Interop.Excel.Shape 拡張クラスの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aXlShapes"></param>
        /// <param name="aIndex"></param>
        public ExcelShapeEx(ExcelShapesEx aXlShapes, int aIndex) : this(aXlShapes.Shapes.Item(aIndex)) { }

        /// <summary>
        /// Microsoft.Office.Interop.Excel.Shapes 拡張クラスのインスタンスとオブジェクト名を指定して、Microsoft.Office.Interop.Excel.Shape 拡張クラスの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aXlShapes"></param>
        /// <param name="aName"></param>
        public ExcelShapeEx(ExcelShapesEx aXlShapes, string aName) : this(aXlShapes.Shapes.Item(aName)) { }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// Microsoft.Office.Interop.Excel.Shape インターフェースへの参照の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public Excel.Shape Shape
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                return base.XlObject as Excel.Shape;
            }
        }

        #endregion
    }
}
