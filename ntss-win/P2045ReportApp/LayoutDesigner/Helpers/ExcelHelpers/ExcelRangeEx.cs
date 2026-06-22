using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Excel = Microsoft.Office.Interop.Excel;
// add #10137 テンプレート設定されているとコピー領域が1回しかペーストできない limingzhe start
using System.Collections.Specialized;
using System.IO;
// add #10137 テンプレート設定されているとコピー領域が1回しかペーストできない limingzhe end
// add #10230 コピーした内容がリセットされる 高 start
using System.Threading;
// add #10230 コピーした内容がリセットされる 高 end

namespace LayoutDesigner
{
    /// <summary>
    /// Microsoft.Office.Interop.Excel.Range 拡張クラス
    /// </summary>
    public class ExcelRangeEx : AbstructExcelComEx
    {
        // add #10528 レイアウトデザイナのセル移動時のパフォーマンスが悪化している 高 start
        #region 内部使用クラス定義
        private class MergeData
        {
            public MergeData() { }
            public MergeData(int p_row_st, int p_column_st, int p_row_end, int p_column_end)
            {
                row_st = p_row_st;
                column_st = p_column_st;
                row_end = p_row_end;
                column_end = p_column_end;
            }

            #region メンバ変数定義
            public int row_st = 0;      // start row
            public int column_st = 0;   // start column
            public int row_end = 0;     // end row
            public int column_end = 0;  // end column
            #endregion
        }
        #endregion
        // add #10528 レイアウトデザイナのセル移動時のパフォーマンスが悪化している 高 end

        #region 生成と破棄

        /// <summary>
        /// Microsoft.Office.Interop.Excel.Range インターフェースを指定して、Microsoft.Office.Interop.Excel.Range 拡張クラスの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aXlRange"></param>
        internal ExcelRangeEx(Excel.Range aXlRange) : base(aXlRange)
        {
            //Object wMergeCells = aXlRange.MergeCells;
            //if( wMergeCells == System.DBNull.Value )
            //    ;// System.Diagnostics.Debug.Assert(false);
        }

        /// <summary>
        /// Microsoft.Office.Interop.Excel.Worksheet インターフェースとセルアドレス(A1フォーマット)を指定して、Microsoft.Office.Interop.Excel.Range 拡張クラスの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aXlWorksheet"></param>
        /// <param name="aA1Format"></param>
        private ExcelRangeEx(Excel.Worksheet aXlWorksheet, string aA1Format) : this(aXlWorksheet.Range[aA1Format]) { }

        /// <summary>
        /// Microsoft.Office.Interop.Excel.Worksheet 拡張クラスのインスタンスとセルアドレス(A1フォーマット)を指定して、Microsoft.Office.Interop.Excel.Range 拡張クラスの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aXlWorksheet"></param>
        /// <param name="aA1Format"></param>
        public ExcelRangeEx(ExcelWorksheetEx aXlWorksheet, string aA1Format) : this(aXlWorksheet.Worksheet, aA1Format) { }

        /// <summary>
        /// Microsoft.Office.Interop.Excel.Worksheet 拡張クラスのインスタンスと行列番号を指定して、Microsoft.Office.Interop.Excel.Range 拡張クラスの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aXlWorksheet"></param>
        /// <param name="aRowNo"></param>
        /// <param name="aColNo"></param>
        public ExcelRangeEx(ExcelWorksheetEx aXlWorksheet, Int32 aRowNo, Int32 aColNo)
            : this(aXlWorksheet, aXlWorksheet.Worksheet.Application.ConvertFormula($"R{aRowNo}C{aColNo}", Excel.XlReferenceStyle.xlR1C1, Excel.XlReferenceStyle.xlA1, Excel.XlReferenceType.xlRelative, Type.Missing) as String) { }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// Microsoft.Office.Interop.Excel.Range インターフェースへの参照の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public Excel.Range Range
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get
            {
                return base.XlObject as Excel.Range;
            }
        }

        #endregion

        #region メンバ関数定義

        /// <summary>
        /// 現在の Microsoft.Office.Interop.Excel.Range に含まれているセルのアドレスリストを取得します。
        /// </summary>
        /// <returns></returns>
        public IEnumerable<String> GetContainCellAddressList()
        {
            foreach (Excel.Range wRange in this.Range.Cells)
            {
                using (var wXlRange = new ExcelRangeEx(wRange))
                {
                    using (var wXlMergeArea = new ExcelRangeEx(wXlRange.Range.MergeArea))
                    {
                        // 左上以外はスキップ
                        if (wXlRange.Range.Row != wXlMergeArea.Range.Row || wXlRange.Range.Column != wXlMergeArea.Range.Column)
                            continue;

                        yield return wXlMergeArea.Range.Address[false, false];
                    }
                }
            }
        }

        /// <summary>
        /// 現在の Microsoft.Office.Interop.Excel.Range に含まれているセルのリストを取得します。
        /// </summary>
        /// <returns></returns>
        public IEnumerable<ExcelRangeEx> GetContainCellList()
        {
            foreach (var wAddress in this.GetContainCellAddressList())
                yield return new ExcelRangeEx(this.Range.Worksheet, wAddress);
        }

        // add #10528 レイアウトデザイナのセル移動時のパフォーマンスが悪化している 高 start
        private static string GetExcelCol(int colIndex)
        {
            var major = colIndex / 26;
            var minor = colIndex % 26;
            var last = ((char)(minor + 'A')).ToString();
            if (major > 0)
                return GetExcelCol(major - 1) + last;
            return last;
        }
        // add #10528 レイアウトデザイナのセル移動時のパフォーマンスが悪化している 高 end

        /// <summary>
        /// 指定された条件で検索した結果のセルと値を取得します。
        /// </summary>
        /// <param name="What"></param>
        /// <param name="After"></param>
        /// <param name="LookIn"></param>
        /// <param name="LookAt"></param>
        /// <param name="SearchOrder"></param>
        /// <param name="SearchDirection"></param>
        /// <param name="MatchCase"></param>
        /// <param name="MatchByte"></param>
        /// <param name="SearchFormat"></param>
        /// <returns></returns>
        // mod #10399 【デグレ】出力時に非表示セルが処理されない limingzhe start
        // mod #12131 レイアウトデザイナのセル移動時のパフォーマンスが再度悪化 高 start
        //public Dictionary<String, dynamic> FindCellAddrValue(Object What, Object After, Object LookIn, Object LookAt, Object SearchOrder, Excel.XlSearchDirection SearchDirection = Excel.XlSearchDirection.xlNext, Object MatchCase = null, Object MatchByte = null, Object SearchFormat = null)
        //// mod #10399 【デグレ】出力時に非表示セルが処理されない limingzhe end
        //{
        //    var wRet = new Dictionary<String, dynamic>();
        //    Excel.Range wCurrentFind = null;

        //    try
        //    {
        //        Object wMergeCells = this.Range.MergeCells;

        //        Boolean wIsSingleCell = false;
        //        if (wMergeCells != System.DBNull.Value)
        //        {
        //            if ((Boolean)wMergeCells)
        //                wIsSingleCell = true;
        //            else
        //                if (this.Range.Cells.CountLarge == 1)
        //                wIsSingleCell = true;
        //        }

        //        // 検索範囲が単独セルの場合
        //        if (wIsSingleCell)
        //        {
        //            //if( wMergeCells != System.DBNull.Value ) {
        //            String wValue2 = this.GetValue2() as String;
        //            if (!String.IsNullOrEmpty(wValue2) && wValue2.Contains(What as String))
        //                wRet.Add(this.Range.Address[false, false], wValue2);
        //        }
        //        // 検索範囲が複数セルの場合
        //        else
        //        {
        //            //mod #10399 【デグレ】出力時に非表示セルが処理されない limingzhe start
        //            // mod #9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 高 start
        //            try
        //            {
        //                wCurrentFind = this.Range.SpecialCells(Excel.XlCellType.xlCellTypeConstants, Excel.XlSpecialCellsValue.xlTextValues);
        //            }
        //            catch (Exception ex)
        //            {
        //                return wRet;
        //            }
        //            // mod #9951 縮小表示ONと表示文字列長が併存したとき、後者が機能するのはNG 高 end
        //            // mod #10528 レイアウトデザイナのセル移動時のパフォーマンスが悪化している 高 start
        //            //foreach (Excel.Range cell in wCurrentFind.Cells)
        //            //{
        //            //    String value = cell.Value2;
        //            //    if (String.IsNullOrEmpty(value)) continue;
        //            //    if (!value.Contains(What.ToString())) continue;
        //            //    String wAddress = cell.MergeArea.Address[false, false];
        //            //    if (!wRet.ContainsKey(wAddress))
        //            //        wRet.Add(wAddress, cell.Value2);
        //            //}
        //            int area_Rows_Count;
        //            int area_Columns_Count;
        //            int area_Row_st;
        //            int area_Columns_st;
        //            int area_Row_end;
        //            int area_Columns_end;
        //            int mergeArea_Rows_Count;
        //            int mergeArea_Columns_Count;
        //            int mergeArea_Row_st;
        //            int mergeArea_Row_end;
        //            int mergeArea_Columns_st;
        //            int mergeArea_Columns_end;
        //            String cell_Value = "";
        //            List<MergeData> mergeList = new List<MergeData>();

        //            foreach (Excel.Range area in wCurrentFind.Areas)
        //            {
        //                area_Rows_Count = area.Rows.Count;
        //                area_Columns_Count = area.Columns.Count;
        //                area_Row_st = area.Row;
        //                area_Columns_st = area.Column;
        //                area_Row_end = area_Row_st + area_Rows_Count - 1;
        //                area_Columns_end = area_Columns_st + area_Columns_Count - 1;

        //                String wAddress2 = area.Address[false, false];
        //                int index = wAddress2.IndexOf(":");
        //                if (index > 0)
        //                {
        //                    for (int ii = area_Row_st; ii <= area_Row_end; ii++)
        //                    {
        //                        for (int jj = area_Columns_st; jj <= area_Columns_end; jj++)
        //                        {
        //                            if (mergeList.Count > 0 && mergeList.Exists(ele => ii >= ele.row_st && ii <= ele.row_end && jj >= ele.column_st && jj <= ele.column_end))
        //                            {
        //                                continue;
        //                            }
        //                            Excel.Range cur_ran;
        //                            string addr = GetExcelCol(jj - 1) + ii.ToString();
        //                            cur_ran = this.Range.Worksheet.get_Range(addr);
        //                            if (cur_ran.MergeCells && cur_ran.MergeArea != null)
        //                            {
        //                                mergeArea_Rows_Count = cur_ran.MergeArea.Rows.Count;
        //                                mergeArea_Columns_Count = cur_ran.MergeArea.Columns.Count;
        //                                mergeArea_Row_st = cur_ran.MergeArea.Row;
        //                                mergeArea_Columns_st = cur_ran.MergeArea.Column;
        //                                mergeArea_Row_end = mergeArea_Row_st + mergeArea_Rows_Count - 1;
        //                                mergeArea_Columns_end = mergeArea_Columns_st + mergeArea_Columns_Count - 1;
        //                                mergeList.Add(new MergeData(mergeArea_Row_st, mergeArea_Columns_st, mergeArea_Row_end, mergeArea_Columns_end));
        //                                cell_Value = cur_ran.Value2;
        //                                if (String.IsNullOrEmpty(cell_Value)) continue;
        //                                if (!cell_Value.Contains(What.ToString())) continue;
        //                                addr = cur_ran.MergeArea.Address[false, false];
        //                                if (!wRet.ContainsKey(addr))
        //                                    wRet.Add(addr, cell_Value);
        //                            }
        //                            else
        //                            {
        //                                cell_Value = cur_ran.Value2;
        //                                if (String.IsNullOrEmpty(cell_Value)) continue;
        //                                if (!cell_Value.Contains(What.ToString())) continue;
        //                                if (!wRet.ContainsKey(addr))
        //                                    wRet.Add(addr, cell_Value);
        //                            }
        //                        }
        //                    }
        //                }
        //                else
        //                {
        //                    cell_Value = area.Value2;
        //                    if (String.IsNullOrEmpty(cell_Value)) continue;
        //                    if (!cell_Value.Contains(What.ToString())) continue;
        //                    if (!wRet.ContainsKey(wAddress2))
        //                        wRet.Add(wAddress2, cell_Value);
        //                }

        //            }
        //            mergeList = null;
        //            // mod #10528 レイアウトデザイナのセル移動時のパフォーマンスが悪化している 高 end
        //            // mod #10399 【デグレ】出力時に非表示セルが処理されない limingzhe end
        //            // del #10399 【デグレ】出力時に非表示セルが処理されない limingzhe start
        //            //wCurrentFind = this.Range.Find(What, After, LookIn, LookAt, SearchOrder, SearchDirection, MatchCase, MatchByte, SearchFormat);
        //            //if (wCurrentFind != null)
        //            //{

        //            //    var wFirstAddr = wCurrentFind.Address[false, false];
        //            //    do
        //            //    {
        //            //        String wAddress = wCurrentFind.MergeArea.Address[false, false];
        //            //        if (!wRet.ContainsKey(wAddress))
        //            //            wRet.Add(wAddress, wCurrentFind.Value2);

        //            //        var row = wCurrentFind.MergeArea.Row;
        //            //        var rangeRow = wCurrentFind.MergeArea.Rows.Count;
        //            //        var iBreakRow = 0;
        //            //        //while (iNullNum < rangeRow && row < iFirstRow + rangeRow - 1) 
        //            //        do
        //            //        {
        //            //            Excel.Range wnext = this.Range.Cells[++row, wCurrentFind.MergeArea.Column];

        //            //            if (wnext.Rows.Hidden == false || string.IsNullOrEmpty(wnext.Value2)) iBreakRow++;
        //            //            else
        //            //            {
        //            //                wAddress = wnext.Address[false, false];
        //            //                if (!wRet.ContainsKey(wAddress))
        //            //                    wRet.Add(wAddress, wnext.Value2);
        //            //                iBreakRow = 0;
        //            //            }
        //            //        } while (iBreakRow < 3);
        //            //        iBreakRow = 0;

        //            //        wCurrentFind = this.Range.FindNext(wCurrentFind);

        //            //    } while (wCurrentFind != null && wCurrentFind.Address[false, false] != wFirstAddr);
        //            //}
        //            // del #10399 【デグレ】出力時に非表示セルが処理されない limingzhe end
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        throw;
        //    }
        //    finally
        //    {
        //        if (wCurrentFind != null)
        //            System.Runtime.InteropServices.Marshal.FinalReleaseComObject(wCurrentFind);
        //    }

        //    return wRet;
        //}

        public Dictionary<String, dynamic> FindCellAddrValue(Object What, Object After, Object LookIn, Object LookAt, Object SearchOrder, Excel.XlSearchDirection SearchDirection = Excel.XlSearchDirection.xlNext, Object MatchCase = null, Object MatchByte = null, Object SearchFormat = null)
        {
            var wRet = new Dictionary<String, dynamic>();
            Excel.Range wCurrentFind = null;

            try
            {
                Object wMergeCells = this.Range.MergeCells;
                Boolean wIsSingleCell = false;

                if (wMergeCells != System.DBNull.Value)
                {
                    if ((Boolean)wMergeCells)
                        wIsSingleCell = true;
                    else if (this.Range.Cells.CountLarge == 1)
                        wIsSingleCell = true;
                }

                // 検索範囲が単独セルの場合
                if (wIsSingleCell)
                {
                    String wValue2 = this.GetValue2() as String;
                    if (!String.IsNullOrEmpty(wValue2) && wValue2.Contains(What as String))
                        wRet.Add(this.Range.Address[false, false], wValue2);
                    return wRet;
                }

                // 検索範囲が複数セルの場合
                // mod #12616 データ項目の縮小表示が機能しないことがある 高 start
                bool originalEventState = RldLib.XlHelper.XlApp.Application.EnableEvents;
                try
                {
                    RldLib.XlHelper.XlApp.Application.EnableEvents = false;
                    wCurrentFind = this.Range.SpecialCells(Excel.XlCellType.xlCellTypeConstants, Excel.XlSpecialCellsValue.xlTextValues);
                }
                catch
                {
                    return wRet;
                }
                finally
                {
                    RldLib.XlHelper.XlApp.Application.EnableEvents = originalEventState;
                }
                // mod #12616 データ項目の縮小表示が機能しないことがある 高 end

                if (wCurrentFind == null) return wRet;

                string searchText = What?.ToString() ?? "";

                // convert area to list and Parallel task process
                var areasList = new List<Excel.Range>();
                foreach (Excel.Range area in wCurrentFind.Areas)
                {
                    areasList.Add(area);
                }

                var parallelResults = new System.Collections.Concurrent.ConcurrentDictionary<string, dynamic>();
                var processedCells = new System.Collections.Concurrent.ConcurrentDictionary<string, bool>();

                // Parallel task process
                System.Threading.Tasks.Parallel.ForEach(areasList, area =>
                {
                    ProcessAreaFast(area, searchText, parallelResults, processedCells);
                });

                // convert to Dictionary from ConcurrentDictionary
                wRet = new Dictionary<string, dynamic>(parallelResults);
            }
            catch (Exception ex)
            {
                throw;
            }
            finally
            {
                if (wCurrentFind != null)
                    System.Runtime.InteropServices.Marshal.FinalReleaseComObject(wCurrentFind);
            }

            return wRet;
        }

        // process area
        private void ProcessAreaFast(Excel.Range area, string searchText, System.Collections.Concurrent.ConcurrentDictionary<string, dynamic> result, System.Collections.Concurrent.ConcurrentDictionary<string, bool> processedCells)
        {
            try
            {
                // get all area value2 in once
                if (TryProcessAreaBulk(area, searchText, result, processedCells))
                    return;
            }
            catch
            {
                // TODO
            }

            // search all cells
            ProcessAreaQuick(area, searchText, result, processedCells);
        }

        // get information of all area value2 in once
        private bool TryProcessAreaBulk(Excel.Range area, string searchText, System.Collections.Concurrent.ConcurrentDictionary<string, dynamic> result, System.Collections.Concurrent.ConcurrentDictionary<string, bool> processedCells)
        {
            try
            {
                // get information of all area value2 in once
                object[,] values = area.Value2 as object[,];
                if (values == null) return false;

                int rowCount = values.GetLength(0);
                int colCount = values.GetLength(1);
                int startRow = area.Row;
                int startCol = area.Column;

                // process all cells
                for (int i = 1; i <= rowCount; i++)
                {
                    for (int j = 1; j <= colCount; j++)
                    {
                        object cellValue = values[i, j];
                        if (cellValue == null) continue;

                        string valueStr = cellValue.ToString();
                        if (!string.IsNullOrEmpty(valueStr) && valueStr.Contains(searchText))
                        {
                            int currentRow = startRow + i - 1;
                            int currentCol = startCol + j - 1;
                            string cellKey = $"{currentRow},{currentCol}";

                            // already processed
                            if (processedCells.ContainsKey(cellKey)) continue;

                            // get cell and check Merge Cell
                            Excel.Range cell = null;
                            try
                            {
                                cell = area.Worksheet.Cells[currentRow, currentCol];
                                string address = GetCorrectCellAddress(cell, processedCells);

                                if (!string.IsNullOrEmpty(address) && !result.ContainsKey(address))
                                {
                                    result.TryAdd(address, valueStr);
                                }
                            }
                            finally
                            {
                                if (cell != null)
                                    System.Runtime.InteropServices.Marshal.FinalReleaseComObject(cell);
                            }
                        }
                    }
                }

                return true;
            }
            catch
            {
                return false;
            }
        }

        // search all cells
        private void ProcessAreaQuick(Excel.Range area, string searchText, System.Collections.Concurrent.ConcurrentDictionary<string, dynamic> result, System.Collections.Concurrent.ConcurrentDictionary<string, bool> processedCells)
        {
            // loop all cells
            foreach (Excel.Range cell in area.Cells)
            {
                try
                {
                    string cellKey = $"{cell.Row},{cell.Column}";
                    if (processedCells.ContainsKey(cellKey)) continue;

                    string valueStr = cell.Value2?.ToString();
                    if (string.IsNullOrEmpty(valueStr) || !valueStr.Contains(searchText))
                        continue;

                    string address = GetCorrectCellAddress(cell, processedCells);

                    if (!string.IsNullOrEmpty(address) && !result.ContainsKey(address))
                    {
                        result.TryAdd(address, valueStr);
                    }
                }
                catch
                {
                    // TODO
                }
                finally
                {
                    if (cell != null)
                        System.Runtime.InteropServices.Marshal.FinalReleaseComObject(cell);
                }
            }
        }

        // get address and check Merge Cell
        private string GetCorrectCellAddress(Excel.Range cell, System.Collections.Concurrent.ConcurrentDictionary<string, bool> processedCells)
        {
            if (cell.MergeCells)
            {
                Excel.Range mergeArea = cell.MergeArea;
                string mergeAddress = mergeArea.Address[false, false];

                // mark process Merge Area
                MarkMergeAreaProcessed(mergeArea, processedCells);

                System.Runtime.InteropServices.Marshal.FinalReleaseComObject(mergeArea);
                return mergeAddress;
            }
            else
            {
                string singleAddress = cell.Address[false, false];
                processedCells.TryAdd($"{cell.Row},{cell.Column}", true);
                return singleAddress;
            }
        }

        // mark process Merge Area
        private void MarkMergeAreaProcessed(Excel.Range mergeArea, System.Collections.Concurrent.ConcurrentDictionary<string, bool> processedCells)
        {
            try
            {
                int startRow = mergeArea.Row;
                int endRow = startRow + mergeArea.Rows.Count - 1;
                int startCol = mergeArea.Column;
                int endCol = startCol + mergeArea.Columns.Count - 1;

                for (int row = startRow; row <= endRow; row++)
                {
                    for (int col = startCol; col <= endCol; col++)
                    {
                        processedCells.TryAdd($"{row},{col}", true);
                    }
                }
            }
            catch
            {
                // TODO
            }
        }

        // mod #12131 レイアウトデザイナのセル移動時のパフォーマンスが再度悪化 高 end

        /// <summary>
        /// セルの画像を Bitmap 形式で取得します。
        /// </summary>
        /// <returns></returns>
        public System.Drawing.Image GetImage()
        {
            System.Drawing.Image wRet = null;
            // delete #10137 テンプレート設定されているとコピー領域が1回しかペーストできない limingzhe start
            //edit  #9822 【デグレ】セル選択移動時の不具合 dongzhaolong start
            //bool isContainsText = System.Windows.Forms.Clipboard.ContainsText();
            //bool isContainsImage = System.Windows.Forms.Clipboard.ContainsImage();
            //bool isContainsData = false;
            //string strClipboardText = string.Empty;
            //System.Drawing.Image imgClipboardImage = null;
            //if (isContainsText || isContainsImage)
            //{
            //    isContainsData = true;
            //    if (isContainsText)
            //    {
            //        strClipboardText = System.Windows.Forms.Clipboard.GetText();
            //    }
            //    else if (isContainsImage)
            //    {
            //        imgClipboardImage = System.Windows.Forms.Clipboard.GetImage();
            //    }
            //}

            //if ( this.Range.CopyPicture(Excel.XlPictureAppearance.xlScreen, Excel.XlCopyPictureFormat.xlBitmap) ) {
            //    if (System.Windows.Forms.Clipboard.ContainsImage())
            //    {
            //        wRet = System.Windows.Forms.Clipboard.GetImage();
            //        if (isContainsData)
            //        {
            //            if (strClipboardText != string.Empty)
            //            {
            //                System.Windows.Forms.Clipboard.SetText(strClipboardText);
            //            }
            //            else
            //            {
            //                System.Windows.Forms.Clipboard.SetImage(imgClipboardImage);
            //            }
            //        }
            //        else
            //        {
            //            System.Windows.Forms.Clipboard.Clear();
            //        }
            //    }
            //}
            //edit  #9822 【デグレ】セル選択移動時の不具合 dongzhaolong end
            // delete #10137 テンプレート設定されているとコピー領域が1回しかペーストできない limingzhe end

            // mod #10137 テンプレート設定されているとコピー領域が1回しかペーストできない limingzhe start
            Stream ClipboardAudioStream = null;
            if (System.Windows.Forms.Clipboard.ContainsAudio())
            {
                ClipboardAudioStream = System.Windows.Forms.Clipboard.GetAudioStream();
            }
            StringCollection ClipboardFileDropList = null;
            if (System.Windows.Forms.Clipboard.ContainsFileDropList())
            {
                ClipboardFileDropList = System.Windows.Forms.Clipboard.GetFileDropList();
            }
            System.Drawing.Image ClipboardImage = null;
            if (System.Windows.Forms.Clipboard.ContainsImage())
            {
                ClipboardImage = System.Windows.Forms.Clipboard.GetImage();
            }
            // mod #10230 コピーした内容がリセットされる 高 start
            // string ClipboardText = string.Empty;
            object ClipboardText = null;
            if (System.Windows.Forms.Clipboard.ContainsText())
            {
                // ClipboardText = System.Windows.Forms.Clipboard.GetText();
                ClipboardText = System.Windows.Forms.Clipboard.GetData(DataFormats.Text);
            }
            // mod #10230 コピーした内容がリセットされる 高 end
            object ClipboardData = null;
            if (System.Windows.Forms.Clipboard.ContainsData(DataFormats.Html))
            {
                ClipboardData = System.Windows.Forms.Clipboard.GetData(DataFormats.Html);
            }

            // mod #10230 コピーした内容がリセットされる 高 start
            //try
            //{
            //    this.Range.Copy();
            //    if (this.Range.CopyPicture(Excel.XlPictureAppearance.xlScreen, Excel.XlCopyPictureFormat.xlBitmap))
            //    {
            //        wRet = System.Windows.Forms.Clipboard.GetImage();

            //        System.Windows.Forms.Clipboard.Clear();
            //        if (ClipboardAudioStream != null) System.Windows.Forms.Clipboard.SetAudio(ClipboardAudioStream);
            //        if (ClipboardFileDropList != null) System.Windows.Forms.Clipboard.SetFileDropList(ClipboardFileDropList);
            //        if (ClipboardImage != null) System.Windows.Forms.Clipboard.SetImage(ClipboardImage);
            //        if (!string.IsNullOrEmpty(ClipboardText)) System.Windows.Forms.Clipboard.SetText(ClipboardText);
            //        if (ClipboardData != null) System.Windows.Forms.Clipboard.SetData(DataFormats.Html, ClipboardData);
            //    }
            //}
            //catch (Exception)
            //{
            //    System.Windows.Forms.Clipboard.Clear();
            //    if (ClipboardAudioStream != null) System.Windows.Forms.Clipboard.SetAudio(ClipboardAudioStream);
            //    if (ClipboardFileDropList != null) System.Windows.Forms.Clipboard.SetFileDropList(ClipboardFileDropList);
            //    if (ClipboardImage != null) System.Windows.Forms.Clipboard.SetImage(ClipboardImage);
            //    if (!string.IsNullOrEmpty(ClipboardText)) System.Windows.Forms.Clipboard.SetText(ClipboardText);
            //    if (ClipboardData != null) System.Windows.Forms.Clipboard.SetData(DataFormats.Html, ClipboardData);
            //    throw;
            //}
            int excCnt = 3;
            do
            {
                try
                {
                    if (this.Range.CopyPicture(Excel.XlPictureAppearance.xlScreen, Excel.XlCopyPictureFormat.xlBitmap))
                    {
                        wRet = System.Windows.Forms.Clipboard.GetImage();
                    }
                    excCnt = 0;
                }
                catch (Exception)
                {
                    excCnt--;
                    Thread.Sleep(50);
                }
            } while (excCnt != 0);

            System.Windows.Forms.Clipboard.Clear();
            if (ClipboardAudioStream != null)
            {
                System.Windows.Forms.Clipboard.SetAudio(ClipboardAudioStream);
            }
            if (ClipboardFileDropList != null)
            {
                System.Windows.Forms.Clipboard.SetFileDropList(ClipboardFileDropList);
            }
            if (ClipboardImage != null)
            {
                System.Windows.Forms.Clipboard.SetImage(ClipboardImage);
            }
            if (ClipboardText != null)
            {
                System.Windows.Forms.Clipboard.SetData(DataFormats.Text, ClipboardText);
            }
            if (ClipboardData != null)
            {
                System.Windows.Forms.Clipboard.SetData(DataFormats.Html, ClipboardData);
            }
            // mod #10230 コピーした内容がリセットされる 高 end
            // mod #10137 テンプレート設定されているとコピー領域が1回しかペーストできない limingzhe end
            return wRet;
        }

        /// <summary>
        /// 格納可能な文字数('0'を1文字として計算)を取得します。
        /// </summary>
        /// <returns></returns>
        public Int32 GetStringLength()
        {
            Int32 wRet = 0;

            using (var wXlFont = new ExcelFontEx(this.GetFont()))
            {
                using (var wFont = new System.Drawing.Font(wXlFont.Font.Name as String, Convert.ToSingle((Double)wXlFont.Font.Size)))
                using (var wBitmap = new System.Drawing.Bitmap(1, 1))
                using (var wGraphics = System.Drawing.Graphics.FromImage(wBitmap))
                {

                    var wSize1 = wGraphics.MeasureString("0", wFont);
                    var wSize2 = wGraphics.MeasureString("00", wFont);

                    wRet = (Int32)(((Double)this.GetWidth() * wBitmap.HorizontalResolution / 72 - (wSize1.Width * 2 - wSize2.Width)) / ((wSize2.Width - wSize1.Width) * 1.08));
                }
            }

            return wRet;
        }

        //#9397 表示文字列長の設定、およびフリー計算パラメータの書式設定について dongzhaolong start
        public Int32 GetStringRowCount()
        {
            Int32 wRet = 0;

            using (var wXlFont = new ExcelFontEx(this.GetFont()))
            {
                using (var wFont = new System.Drawing.Font(wXlFont.Font.Name as String, Convert.ToSingle((Double)wXlFont.Font.Size)))
                using (var wBitmap = new System.Drawing.Bitmap(1, 1))
                using (var wGraphics = System.Drawing.Graphics.FromImage(wBitmap))
                {

                    var wSize1 = wGraphics.MeasureString("0", wFont);
                    wRet = (Int32)(((Double)this.GetHeight() * wBitmap.VerticalResolution / 72) / wSize1.Height);
                    if (wRet < 1)
                    {
                        wRet = 1;
                    }
                }
            }

            return wRet;
        }
        //#9397 表示文字列長の設定、およびフリー計算パラメータの書式設定について dongzhaolong end

        //public Int32 GetStringLengthForHtml()
        //{
        //    Int32 wRet = 0;

        //    using( var wXlFont = new ExcelFontEx(this.Range.Font) ) {
        //        using( var wFont = new System.Drawing.Font(wXlFont.Font.Name as String, Convert.ToSingle((Double)wXlFont.Font.Size)) )
        //        using( var wBitmap = new System.Drawing.Bitmap(1, 1) )
        //        using( var wGraphics = System.Drawing.Graphics.FromImage(wBitmap) ) {

        //            var wSize1 = wGraphics.MeasureString("0", wFont);
        //            var wSize2 = wGraphics.MeasureString("00", wFont);

        //            //wRet = (Int32)(((Double)this.Range.Width * wBitmap.HorizontalResolution / 72 - (wSize1.Width * 2 - wSize2.Width)) / ((wSize2.Width - wSize1.Width) * 1.08));
        //            wRet = (Int32)((Double)this.Range.Width / wSize1.Width);
        //        }
        //    }

        //    return wRet;
        //}

        /// <summary>
        /// 指定文字列を格納可能なフォントサイズを取得します。
        /// </summary>
        /// <param name="aCellValue"></param>
        /// <returns></returns>
        public Double GetStringFontSize(String aCellValue)
        {
            Double wRet = 0d, wRequiredWidth = 0;

            using (var wXlFont = new ExcelFontEx(this.GetFont()))
            {

                //add 2021 - 09 - 02 #6370:プロンプトボックスタイプを変更する 鄭  start
                if (wXlFont.Font.Size.Equals(System.DBNull.Value))
                {
                    wXlFont.Font.Size = 14;
                }
                //add 2021 - 09 - 02 #6370:プロンプトボックスタイプを変更する 鄭 end

                // フォントサイズを取得して戻り値にセット
                wRet = wXlFont.Font.Size;

                using (var wFont = new System.Drawing.Font(wXlFont.Font.Name as String, Convert.ToSingle((Double)wXlFont.Font.Size)))
                using (var wBitmap = new System.Drawing.Bitmap(1, 1))
                using (var wGraphics = System.Drawing.Graphics.FromImage(wBitmap))
                {
                    var wSize = wGraphics.MeasureString(aCellValue, wFont);

                    // Pixel -> inch -> point
                    wRequiredWidth = wSize.Width / wBitmap.HorizontalResolution * 72;
                }
            }

            Double wWidth = this.GetWidth();
            if (wWidth < wRequiredWidth) wRet = wRet * wWidth / wRequiredWidth;

            return wRet;
        }

        /// <summary>
        /// セルのフォントを取得します。
        /// 結合セルの場合は左上のセルのフォントを取得します。
        /// </summary>
        /// <returns></returns>
        public Excel.Font GetFont()
        {
            var wRet = this.Range.Font;

            Object wMergeCell = this.Range.MergeCells;

            if (wMergeCell != System.DBNull.Value)
                if ((Boolean)wMergeCell)
                    using (var wXlRange = new ExcelRangeEx(this.Range.Cells[1, 1]))
                        wRet = wXlRange.Range.Font;

            return wRet;
        }

        /// <summary>
        /// セルの値を取得します。
        /// 結合セルの場合は左上のセルの値を取得します。
        /// </summary>
        /// <returns></returns>
        public dynamic GetValue()
        {
            dynamic wRet = this.Range.Value;

            Object wMergeCell = this.Range.MergeCells;

            if (wMergeCell != System.DBNull.Value)
                if ((Boolean)wMergeCell)
                    using (var wXlRange = new ExcelRangeEx(this.Range.Cells[1, 1]))
                        wRet = wXlRange.Range.Value;

            return wRet;
        }

        /// <summary>
        /// セルの値を取得します。
        /// 結合セルの場合は左上のセルの値を取得します。
        /// </summary>
        /// <returns></returns>
        public dynamic GetValue2()
        {
            dynamic wRet = this.Range.Value2;

            Object wMergeCell = this.Range.MergeCells;

            if (wMergeCell != System.DBNull.Value)
                if ((Boolean)wMergeCell)
                    using (var wXlRange = new ExcelRangeEx(this.Range.Cells[1, 1]))
                        wRet = wXlRange.Range.Value2;

            return wRet;
        }

        // add #10446 テンプレート繰返しでの計算式繰返しの制限事項対応②（「=」で始まる計算式） 高 start
        /// <summary>
        /// セルに数式が設定されているかを取得します。
        /// 結合セルの場合は左上のセルを参照します。
        /// </summary>
        /// <returns></returns>
        public bool HasFormula()
        {
            Object wMergeCell = this.Range.MergeCells;

            if (wMergeCell != System.DBNull.Value && (Boolean)wMergeCell)
            {
                using (var wXlRange = new ExcelRangeEx(this.Range.Cells[1, 1]))
                    return GetHasFormulaFromRange(wXlRange.Range);
            }

            return GetHasFormulaFromRange(this.Range);
        }

        /// <summary>
        /// セルの数式を取得します。
        /// 結合セルの場合は左上のセルの数式を取得します。
        /// </summary>
        /// <returns></returns>
        public string GetFormula()
        {
            Object wMergeCell = this.Range.MergeCells;

            if (wMergeCell != System.DBNull.Value && (Boolean)wMergeCell)
            {
                using (var wXlRange = new ExcelRangeEx(this.Range.Cells[1, 1]))
                    return Convert.ToString(wXlRange.Range.Formula);
            }

            return Convert.ToString(this.Range.Formula);
        }

        /// <summary>
        /// Range.HasFormula を安全に bool へ変換します。
        /// 結合セルなどで DBNull が返る場合は false とします。
        /// </summary>
        private static bool GetHasFormulaFromRange(Excel.Range aRange)
        {
            Object wHasFormula = aRange.HasFormula;

            if (wHasFormula == null || wHasFormula == System.DBNull.Value)
                return false;

            return (Boolean)wHasFormula;
        }
        // add #10446 テンプレート繰返しでの計算式繰返しの制限事項対応②（「=」で始まる計算式） 高 end

        /// <summary>
        /// セルの幅を取得します。
        /// 結合セルの場合は範囲の幅を取得します。
        /// </summary>
        /// <returns></returns>
        public dynamic GetWidth()
        {
            dynamic wRet = this.Range.Width;

            Object wMergeCells = this.Range.MergeCells;

            if (wMergeCells != System.DBNull.Value)
                if ((Boolean)wMergeCells)
                    if (this.Range.Count == 1)
                        using (var wXlMergeArea = new ExcelRangeEx(this.Range.MergeArea))
                            wRet = wXlMergeArea.Range.Width;

            return wRet;
        }

        /// <summary>
        /// セルの高さを取得します。
        /// 結合セルの場合は範囲の高さを取得します。
        /// </summary>
        /// <returns></returns>
        public dynamic GetHeight()
        {
            dynamic wRet = this.Range.Height;

            Object wMergeCells = this.Range.MergeCells;

            if (wMergeCells != System.DBNull.Value)
                if ((Boolean)wMergeCells)
                    if (this.Range.Count == 1)
                        using (var wXlMergeArea = new ExcelRangeEx(this.Range.MergeArea))
                            wRet = wXlMergeArea.Range.Height;

            return wRet;
        }

        // add #12798 帳票プレビューの画像がセルのサイズに合っていない 高 start
        /// <summary>
        /// 結合セルを含む測定・配置用の Range を取得します。
        /// </summary>
        public Excel.Range GetMeasureArea()
        {
            Excel.Range range = this.Range;
            Object wMergeCells = range.MergeCells;

            if (wMergeCells != System.DBNull.Value)
                if ((Boolean)wMergeCells)
                    if (range.Count == 1)
                        return range.MergeArea;

            return range;
        }
        // add #12798 帳票プレビューの画像がセルのサイズに合っていない 高 end

        /// <summary>
        /// セルを矩形領域として取得します。
        /// </summary>
        /// <returns></returns>
        public System.Drawing.RectangleF GetRectangle()
        {
            return new System.Drawing.RectangleF(
                (Single)this.Range.Left,
                (Single)this.Range.Top,
                (Single)this.GetWidth(),
                (Single)this.GetHeight());
        }

        /// <summary>
        /// セルを選択状態にします。
        /// </summary>
        public void SelectEx()
        {
            try
            {
                this.Range.Select();
            }
            catch (Exception ex)
            {
                // TODO:
            }
        }

        #endregion
    }
}
