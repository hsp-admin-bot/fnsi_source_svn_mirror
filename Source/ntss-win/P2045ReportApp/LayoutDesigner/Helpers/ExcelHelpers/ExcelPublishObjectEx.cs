using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Excel = Microsoft.Office.Interop.Excel;

namespace LayoutDesigner
{
    /// <summary>
    /// Microsoft.Office.Interop.Excel.PublishObject 拡張クラス
    /// </summary>
    public class ExcelPublishObjectEx : AbstructExcelComEx
    {
        #region 生成と破棄

        /// <summary>
        /// Microsoft.Office.Interop.Excel.PublishObject インターフェースを指定して、Microsoft.Office.Interop.Excel.PublishObject 拡張クラスの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aXlPublishObject"></param>
        public ExcelPublishObjectEx(Excel.PublishObject aXlPublishObject) : base(aXlPublishObject) { }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// Microsoft.Office.Interop.Excel.Shape インターフェースへの参照の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public Excel.PublishObject PublishObject
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                return base.XlObject as Excel.PublishObject;
            }
        }

        #endregion
    }
}
