using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Excel = Microsoft.Office.Interop.Excel;

namespace LayoutDesigner
{
    /// <summary>
    /// Microsoft.Office.Interop.Excel.Windows 拡張クラス
    /// </summary>
    internal class ExcelWindowsEx : AbstructExcelComEx
    {
        #region 生成と破棄

        /// <summary>
        /// Microsoft.Office.Interop.Excel.Application インターフェースを指定して、Microsoft.Office.Interop.Excel.Windows 拡張クラスの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aXlApp"></param>
        private ExcelWindowsEx(Excel.Application aXlApp) : base(aXlApp.Windows) { }

        /// <summary>
        /// Microsoft.Office.Interop.Excel.Application 拡張クラスのインスタンスを指定して、Microsoft.Office.Interop.Excel.Windows 拡張クラスの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aXlApp"></param>
        public ExcelWindowsEx(ExcelApplicationEx aXlApp) : this(aXlApp.Application) { }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// Microsoft.Office.Interop.Excel.Windows インターフェースへの参照の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public Excel.Windows Windows
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                return base.XlObject as Excel.Windows;
            }
        }

        #endregion
    }
}
