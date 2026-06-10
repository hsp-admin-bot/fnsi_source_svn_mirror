using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Excel = Microsoft.Office.Interop.Excel;

namespace LayoutDesigner
{
    /// <summary>
    /// Microsoft.Office.Interop.Excel.Workbook 拡張クラス
    /// </summary>
    public class ExcelWorkbookEx : AbstructExcelComEx
    {
        #region 生成と破棄

        /// <summary>
        /// Microsoft.Office.Interop.Excel.Workbook インターフェースを指定して、Microsoft.Office.Interop.Excel.Workbook 拡張クラスの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aXlWorkbook"></param>
        public ExcelWorkbookEx(Excel.Workbook aXlWorkbook) : base(aXlWorkbook) { }

        /// <summary>
        /// Microsoft.Office.Interop.Excel.Workbooks 拡張クラスのインスタンスとインデックスを指定して、Microsoft.Office.Interop.Excel.Workbook 拡張クラスの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aXlWorkbooks"></param>
        /// <param name="aIndex"></param>
        public ExcelWorkbookEx(ExcelWorkbooksEx aXlWorkbooks, int aIndex) : this(aXlWorkbooks.Workbooks.Item[aIndex]) { }

        /// <summary>
        /// Microsoft.Office.Interop.Excel.Workbooks 拡張クラスのインスタンスとワークブック名を指定して、Microsoft.Office.Interop.Excel.Workbook 拡張クラスの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aXWorkbooks"></param>
        /// <param name="aName"></param>
        public ExcelWorkbookEx(ExcelWorkbooksEx aXWorkbooks, string aName) : this(aXWorkbooks.Workbooks.Item[aName]) { }

        // add #12557 レイアウトデザイナで開くExcelのワークシートが編集可能 高 start
        public string PASSWORD = "nkk";
        // add #12557 レイアウトデザイナで開くExcelのワークシートが編集可能 高 end

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// Microsoft.Office.Interop.Excel.Workbook インターフェースへの参照の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public Excel.Workbook Workbook
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                return base.XlObject as Excel.Workbook;
            }
        }
        
        /// <summary>
        /// ブックの保護状態の取得及び設定を行います。
        /// </summary>
        public bool IsProtected
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                return this.Workbook.ProtectWindows;
            }
            [System.Diagnostics.DebuggerStepThrough()]
            set {
                // mod #12557 レイアウトデザイナで開くExcelのワークシートが編集可能 高 start
                //this.Workbook.Protect(Type.Missing, value, value);
                this.Workbook.Protect(PASSWORD, value, value);
                // mod #12557 レイアウトデザイナで開くExcelのワークシートが編集可能 高 end
            }
        }

        /// <summary>
        /// ブックの読み取り専用状態の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public bool IsReadOnly
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                return this.Workbook.ReadOnly;
            }
        }

        #endregion
    }
}
