using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Excel = Microsoft.Office.Interop.Excel;

namespace LayoutDesigner
{
    /// <summary>
    /// Microsoft.Office.Interop.Excel.Window 拡張クラス
    /// </summary>
    internal class ExcelWindowEx : AbstructExcelComEx
    {
        #region 生成と破棄

        /// <summary>
        /// Microsoft.Office.Interop.Excel.Window インターフェースを指定して、Microsoft.Office.Interop.Excel.Window 拡張クラスの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aXlWindow"></param>
        private ExcelWindowEx(Excel.Window aXlWindow) : base(aXlWindow) { }

        /// <summary>
        /// Microsoft.Office.Interop.Excel.Windows 拡張クラスのインスタンスとインデックスを指定して、Microsoft.Office.Interop.Excel.Window 拡張クラスの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aXlWindows"></param>
        /// <param name="aIndex"></param>
        public ExcelWindowEx(ExcelWindowsEx aXlWindows, int aIndex) : this(aXlWindows.Windows.Item[aIndex]) { }

        /// <summary>
        /// Microsoft.Office.Interop.Excel.Windows 拡張クラスのインスタンスとウィンドウ名を指定して、Microsoft.Office.Interop.Excel.Window 拡張クラスの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aXlWindows"></param>
        /// <param name="aName"></param>
        public ExcelWindowEx(ExcelWindowsEx aXlWindows, string aName) : this(aXlWindows.Windows.Item[aName]) { }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// Microsoft.Office.Interop.Excel.Window インターフェースへの参照の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public Excel.Window Window
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                return base.XlObject as Excel.Window;
            }
        }

        #endregion
    }
}
