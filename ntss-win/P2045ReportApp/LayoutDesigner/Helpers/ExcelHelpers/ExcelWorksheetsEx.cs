using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Excel = Microsoft.Office.Interop.Excel;

namespace LayoutDesigner
{
    /// <summary>
    /// Microsoft.Office.Interop.Excel.Worksheets 拡張クラス
    /// </summary>
    public class ExcelWorksheetsEx : AbstructExcelComEx
    {
        #region 生成と破棄

        /// <summary>
        /// Microsoft.Office.Interop.Excel.Workbook インターフェースを指定して、Microsoft.Office.Interop.Excel.Worksheets 拡張クラスの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aWorkbook"></param>
        protected ExcelWorksheetsEx(Excel.Workbook aWorkbook) : base(aWorkbook.Worksheets) { }

        /// <summary>
        /// Microsoft.Office.Interop.Excel.Workbook 拡張クラスのインスタンスを指定して、Microsoft.Office.Interop.Excel.Worksheets 拡張クラスの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aXlWorkbook"></param>
        public ExcelWorksheetsEx(ExcelWorkbookEx aXlWorkbook) : this(aXlWorkbook.Workbook) { }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// Microsoft.Office.Interop.Excel.WorkSheets インターフェースへの参照の取得を行います。
        /// </summary>
        public Excel.Sheets Worksheets
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                return base.XlObject as Excel.Sheets;
            }
        }

        #endregion

        #region メンバ関数定義

        /// <summary>
        /// 指定されたシートが存在するか確認します。
        /// </summary>
        /// <param name="aWorksheetName">存在を確認するワークシート名</param>
        /// <returns></returns>
        public bool IsExists(string aWorksheetName)
        {
            bool wRet = false;

            foreach( Excel.Worksheet wWorkSheet in this.Worksheets ) {
                if( wWorkSheet.Name == aWorksheetName ) {
                    wRet = true;
                    break;
                }
            }

            return wRet;
        }

        #endregion
    }
}
