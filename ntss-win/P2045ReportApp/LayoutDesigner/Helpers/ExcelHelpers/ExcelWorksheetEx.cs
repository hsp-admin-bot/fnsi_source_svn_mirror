using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Excel = Microsoft.Office.Interop.Excel;

namespace LayoutDesigner
{
    /// <summary>
    /// 
    /// </summary>
    public class ExcelWorksheetEx : AbstructExcelComEx
    {
        #region 生成と破棄

        /// <summary>
        /// Microsoft.Office.Interop.Excel.Worksheet インターフェースを指定して、Microsoft.Office.Interop.Excel.Worksheet 拡張クラスの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aXlWorksheet"></param>
        public ExcelWorksheetEx(Excel.Worksheet aXlWorksheet) : base(aXlWorksheet) { }

        /// <summary>
        /// Microsoft.Office.Interop.Excel.Worksheets 拡張クラスのインスタンスとインデックスを指定して、Microsoft.Office.Interop.Excel.Worksheet 拡張クラスの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aXlWorksheets"></param>
        /// <param name="aIndex"></param>
        public ExcelWorksheetEx(ExcelWorksheetsEx aXlWorksheets, Int32 aIndex) : this(aXlWorksheets.Worksheets.Item[aIndex] as Excel.Worksheet) { }

        /// <summary>
        /// Microsoft.Office.Interop.Excel.Worksheets 拡張クラスのインスタンスとワークシート名を指定して、Microsoft.Office.Interop.Excel.Worksheet 拡張クラスの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aXlWorksheets"></param>
        /// <param name="aName"></param>
        public ExcelWorksheetEx(ExcelWorksheetsEx aXlWorksheets, string aName) : this(aXlWorksheets.Worksheets.Item[aName] as Excel.Worksheet) { }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// Microsoft.Office.Interop.Excel.Worksheet インターフェースへの参照の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public Excel.Worksheet Worksheet
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                return base.XlObject as Excel.Worksheet;
            }
        }

        /// <summary>
        /// シートの保護状態の取得及び設定を行います。
        /// </summary>
        public bool IsProtected
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                return this.Worksheet.ProtectContents;
            }
            [System.Diagnostics.DebuggerStepThrough()]
            set {
                this.Worksheet?.Protect(
                    Type.Missing,
                    value,
                    value,
                    value,
                    value,
                    !value,
                    !value,
                    !value,
                    !value,
                    !value,
                    !value,
                    !value,
                    !value,
                    !value,
                    !value,
                    !value
                    );
            }
        }

        #endregion

    }
}
