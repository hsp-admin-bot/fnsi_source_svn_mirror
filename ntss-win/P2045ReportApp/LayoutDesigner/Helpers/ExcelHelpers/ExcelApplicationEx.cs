using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Excel = Microsoft.Office.Interop.Excel;

namespace LayoutDesigner
{
    /// <summary>
    /// Microsoft.Office.Interop.Excel.Application 拡張クラス
    /// </summary>
    public class ExcelApplicationEx : AbstructExcelComEx
    {
        #region 生成と破棄

        /// <summary>
        /// Microsoft.Office.Interop.Excel.Application 拡張クラスの新しいインスタンスを初期化します。
        /// </summary>
        public ExcelApplicationEx() : this(new Excel.Application()) { }

        /// <summary>
        /// Microsoft.Office.Interop.Excel.Application インターフェースを指定して、Microsoft.Office.Interop.Excel.Application 拡張クラスの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aXlApplication"></param>
        public ExcelApplicationEx(Excel.Application aXlApplication) : base(aXlApplication) { }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// Microsoft.Office.Interop.Excel.Application インターフェースへの参照の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public Excel.Application Application
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                return base.XlObject as Excel.Application;
            }
        }

        #endregion

        #region メンバ関数定義

        /// <summary>
        /// アクティブセルの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public ExcelRangeEx GetActiveCell
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                return new ExcelRangeEx(this.Application.ActiveCell);
            }
        }

        /// <summary>
        /// 選択中のセルの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public ExcelRangeEx GetSelectedCell
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                var wRange = this.Application.Selection as Excel.Range;
                if( wRange == null ) return null;

                return new ExcelRangeEx(wRange);
            }
        }

        /// <summary>
        /// R1C1形式をA1形式に変換します。
        /// </summary>
        /// <param name="aRowNo"></param>
        /// <param name="aColNo"></param>
        /// <returns></returns>
        public string ConvertR1C1ToA1(Int32 aRowNo, Int32 aColNo)
        {
            return this.Application.ConvertFormula(
                string.Format("R{0}C{1}", aRowNo, aColNo),
                Excel.XlReferenceStyle.xlR1C1,
                Excel.XlReferenceStyle.xlA1,
                Excel.XlReferenceType.xlRelative,
                Type.Missing);
        }

		// add #10399 【デグレ】出力時に非表示セルが処理されない limingzhe start
        /// <summary>
        /// range Intersect
        /// </summary>
        public bool IsInRange(String addr1, String addr2, bool CanRepeat)
        {
            if (String.IsNullOrEmpty(addr1) || String.IsNullOrEmpty(addr2)) return false;
            Excel.Range wRange1 = null;
            if (CanRepeat)
            {
                string[] addr = addr1.Split(',');
                for(int i = 0; i < addr.Length; i++)
                {
                    if (i == 0) {
                        wRange1 = this.Application.get_Range(addr[0]);
                        continue;
                    }
                    wRange1 = this.Application.Union(wRange1, this.Application.get_Range(addr[i]));
                }
            }
            else
            {
                wRange1 = this.Application.get_Range(addr1);   
            }
            Excel.Range wRange2 = this.Application.get_Range(addr2);
            Excel.Range iRange = this.Application.Intersect(wRange1, wRange2);

            String wAddr1 = "", iAddr = "";
            if (wRange1 != null) wAddr1 = wRange1.Address[false, false];
            if (iRange != null) iAddr = iRange.Address[false, false];
            return iRange != null && wAddr1 != iAddr;
        }
		// add #10399 【デグレ】出力時に非表示セルが処理されない limingzhe end

        // add #9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 高 start
        /// <summary>
        /// Range1 が Range2 内にある
        /// </summary>
        public bool IsInTemplete(String addr1, String addr2)
        {
            if (String.IsNullOrEmpty(addr1) || String.IsNullOrEmpty(addr2)) return false;
            Excel.Range wRange1 = this.Application.get_Range(addr1);
            Excel.Range wRange2 = this.Application.get_Range(addr2);
            Excel.Range iRange = this.Application.Intersect(wRange1, wRange2);
            String wAddr1 = "", iAddr = "";
            if (wRange1 != null) wAddr1 = wRange1.Address[false, false];
            if (iRange != null) iAddr = iRange.Address[false, false];
            return iRange != null && wAddr1.Equals(iAddr);
        }
        // add #9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 高 end

        // add #11331 「印刷範囲外に～」のメッセージが編集開始後最初の保存で毎回出る 高 start
        /// <summary>
        /// if last address of printRange >= last address of useRange, return true, else false.
        /// </summary>
        public bool IsSameLast(Excel.Range printRange, Excel.Range useRange)
        {
            bool bRet = false;

            // printRange is null
            if (printRange == null)
                return bRet;

            // useRange is null
            if (useRange == null)
                return bRet;

            // down position: printRange < useRange
            if ((RldLib.XlHelper.XlSheetLayout.Worksheet.UsedRange.Row + RldLib.XlHelper.XlSheetLayout.Worksheet.UsedRange.Rows.Count) > (printRange.Row + printRange.Rows.Count))
            {
                return false;
            }

            // right position: printRange < useRange
            if ((RldLib.XlHelper.XlSheetLayout.Worksheet.UsedRange.Column + RldLib.XlHelper.XlSheetLayout.Worksheet.UsedRange.Columns.Count) > (printRange.Column + printRange.Columns.Count))
            {
                return false;
            }

            return true;
        }

        /// <summary>
        /// printRange address of Range1 >= usedRange address of Range2
        /// find data of left and up range.
        /// return : 1: left, 2:up 3:left and up, 0:not data
        /// </summary>
        public int FindLeftUpRange(Excel.Range printRange)
        {
            Excel.Range wCurrentFind = null;
            int iRet = 0;

            if(printRange == null)
                return iRet;

            // left range
            if (printRange.Column > 1)
            {
                string leftRangeAddress = "A1:" + ConvertNumberToLetter(printRange.Column - 1) + (printRange.Row - 1 + printRange.Rows.Count);
                Microsoft.Office.Interop.Excel.Range rn1 = null;
                try
                {
                    // find data
                    rn1 = RldLib.XlHelper.XlSheetLayout.Worksheet.Range[leftRangeAddress];
                    wCurrentFind = rn1.SpecialCells(Excel.XlCellType.xlCellTypeConstants, Excel.XlSpecialCellsValue.xlTextValues);
                }
                catch (Exception ex)
                {
                    wCurrentFind = null;
                }
                if(wCurrentFind != null)
                {
                    iRet = 1;
                }
            }

            // up range
            if(printRange.Row > 1)
            {
                wCurrentFind = null;
                string topRangeAddress = "A1:" + ConvertNumberToLetter(printRange.Column - 1 + printRange.Columns.Count) + (printRange.Row - 1);
                Microsoft.Office.Interop.Excel.Range rn1 = null;
                try
                {
                    // find data
                    rn1 = RldLib.XlHelper.XlSheetLayout.Worksheet.Range[topRangeAddress];
                    wCurrentFind = rn1.SpecialCells(Excel.XlCellType.xlCellTypeConstants, Excel.XlSpecialCellsValue.xlTextValues);
                }
                catch (Exception ex)
                {
                    wCurrentFind = null;
                }
                if (wCurrentFind != null)
                {
                    if (iRet == 1)
                        iRet = 3;
                    else
                        iRet = 2;
                }
            }
            return iRet;
        }

        /// <summary>
        /// convert number to execl column
        /// </summary>
        private string ConvertNumberToLetter(int colIndex)
        {
            string result = "";
            while (colIndex > 0)
            {
                int remainder = (colIndex - 1) % 26;
                char letter = (char)('A' + remainder);
                result = letter + result;
                colIndex = (colIndex - 1) / 26;
            }
            return result;
        }
        // add #11331 「印刷範囲外に～」のメッセージが編集開始後最初の保存で毎回出る 高 end
        #endregion
    }
}
