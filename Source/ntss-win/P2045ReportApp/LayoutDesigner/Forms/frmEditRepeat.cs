//// add #9770 繰り返し設定で罫線と背景に異常 donghao start
//using Microsoft.Office.Interop.Excel;
//// add #9770 繰り返し設定で罫線と背景に異常 donghao end
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace LayoutDesigner
{
    /// <summary>
    /// 繰り返しエリア編集画面
    /// </summary>
    public partial class frmEditRepeat : LayoutDesignerUtilityLib.Controls.frmRldSizableBase
    {
        #region 生成と破棄

        /// <summary>
        /// 繰り返しエリア編集画面
        /// </summary>
        public frmEditRepeat()
        {
            InitializeComponent();

            // アイコンの設定
            this.Icon = Properties.Resources.LayoutDesigner;

            // イベントハンドラ割り当て
            this.btnListInit.Click += new System.EventHandler(this.btnListInit_Click);
            this.btnSelectedAdd.Click += new System.EventHandler(this.btnSelectedAdd_Click);

            this.radDirectionN.CheckedChanged += new EventHandler(this.radDirection_CheckedChanged);

            this.chkReverse.CheckedChanged += new System.EventHandler(this.chkReverse_CheckedChanged);

            this.lstCell.DragDrop += new System.Windows.Forms.DragEventHandler(this.lstCell_DragDrop);
            this.lstCell.DragEnter += new System.Windows.Forms.DragEventHandler(this.lstCell_DragEnter);

            this.btnAddOK.Click += new System.EventHandler(this.btnAddOK_Click);
            this.btnCancel.Click += new System.EventHandler(this.btnCancel_Click);
            this.btnOK.Click += new System.EventHandler(this.btnOK_Click);
        }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// 編集箇所を特定できる情報の取得及び設定を行います。
        /// </summary>
        internal String DataPath { get; set; } = String.Empty;

        /// <summary>
        /// 繰返し項目を配置したセルアドレスの取得及び設定を行います。
        /// </summary>
        internal String MainCellAddr { get; set; } = String.Empty;

        /// <summary>
        /// 繰返範囲の取得及び設定を行います。
        /// </summary>
        internal String SelectedRepeatAddress { get; set; } = null;
        internal String OldSelectedRepeatAddress { get; set; } = null;
        //add #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董昊 start
        private string RepeatAddress { get; set; } = string.Empty;
        //add #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董昊 end
        // del #9770 繰り返し設定で罫線と背景に異常 donghao start
        //// add #9770 繰り返し設定で罫線と背景に異常 donghao start
        //public static Dictionary<string,Color> DicBackColor = new Dictionary<string, Color>();
        //// add #9770 繰り返し設定で罫線と背景に異常 donghao end
        /// // del #9770 繰り返し設定で罫線と背景に異常 donghao end
        // add #11294 紹介状で集計部分がずれて出力される 高 start
        internal string RepDirection { get; set; } = string.Empty;
        // add #11294 紹介状で集計部分がずれて出力される 高 end
        #endregion

        #region メンバ関数定義(override...)

        /// <summary>
        /// Form.Load イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);

            this.lblDataPathAddr.Text = String.Format("{0}({1})", this.DataPath, this.MainCellAddr);

            // 画面クリア
            this.DataClear(true);

            // データ読み込み
            this.DataRead();

            // 並び替える
            this.SortList();

            // 前回設定時の状態に画面を変更する
            for (Int32 i = 0; i < 4; i++)
            {
                switch (i)
                {
                    case 1:
                        this.radDirectionZ.Checked = true;
                        break;
                    case 2:
                        this.chkReverse.Checked = true;
                        break;
                    case 3:
                        this.radDirectionN.Checked = true;
                        break;
                    default:
                        break;
                }

                if (this.MakeCurrentList() == this.SelectedRepeatAddress) break;
            }
        }

        #endregion

        #region メンバ関数定義

        /// <summary>
        /// 画面の入力内容をクリアします。
        /// </summary>
        /// <param name="aIsKeyClear"></param>
        private void DataClear(Boolean aIsKeyClear)
        {
            if (aIsKeyClear)
            {
                this.radDirectionN.Checked = true;
                this.chkReverse.Checked = false;
            }

            this.lstCell.Items.Clear();
        }

        /// <summary>
        /// 画面にデータを読み込みます。
        /// </summary>
        private void DataRead()
        {
            try
            {
                this.lstCell.SuspendLayout();

                // 最初に配置したセルは必ずセットする
                this.lstCell.Items.Add(this.MainCellAddr);

                // 追加で選択されたセルをセットする
                foreach (var wAddress in DesignParamData.GetSplitAddress(this.SelectedRepeatAddress))
                {
                    if (!this.lstCell.Items.Contains(wAddress))
                        this.lstCell.Items.Add(wAddress);
                }
            }
            catch (Exception ex)
            {

            }
            finally
            {
                this.lstCell.ResumeLayout();
            }
        }

        /// <summary>
        /// リストをソートします。
        /// </summary>
        private void SortList()
        {
            var wList = new List<ExcelRangeEx>();

            foreach (String wItem in this.lstCell.Items)
                wList.Add(new ExcelRangeEx(RldLib.XlHelper.XlSheetLayout, wItem));

            // 並び替える
            wList.Sort(LFunc_Compare);

            this.lstCell.Items.Clear();

            wList.ForEach(ele => this.lstCell.Items.Add(ele.Range.Address[false, false]));

            /// <summary>
            /// (ローカル関数)セルリストのソートに使用します。
            /// </summary>
            /// <returns></returns>
            Int32 LFunc_Compare(ExcelRangeEx aRange1, ExcelRangeEx aRange2)
            {
                Int32 wRet = this.chkReverse.Checked ? -1 : 1;

                // N型の場合は列数
                if (this.radDirectionN.Checked)
                    return wRet * (aRange1.Range.Column == aRange2.Range.Column ?
                        aRange1.Range.Row.CompareTo(aRange2.Range.Row) :
                        aRange1.Range.Column.CompareTo(aRange2.Range.Column));
                else
                {
                    return wRet * (aRange1.Range.Row == aRange2.Range.Row ?
                        aRange1.Range.Column.CompareTo(aRange2.Range.Column) :
                        aRange1.Range.Row.CompareTo(aRange2.Range.Row));
                }
            }
        }

        /// <summary>
        /// 現在画面で選択中のセルリスト文字列を取得します。
        /// </summary>
        /// <returns></returns>
        private String MakeCurrentList()
        {
            var wRet = new System.Text.StringBuilder() { Length = 0 };

            for (Int32 i = 0; i < lstCell.Items.Count; i++) wRet.Append(lstCell.Items[i] as String + RldConst.ParamData.SPLITSTR_REPEATADDRESS);

            if (wRet.Length > 0) wRet.Length -= 1;

            return wRet.ToString();
        }

        #endregion

        #region コントロールイベントハンドラ定義

        /// <summary>
        /// 初期化ボタンの Click イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnListInit_Click(object sender, EventArgs e)
        {
            this.DataClear(true);
            this.lstCell.Items.Add(this.MainCellAddr);
        }

        /// <summary>
        /// 選択中セルを追加ボタンの Click イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnSelectedAdd_Click(object sender, EventArgs e)
        {
            try
            {
                this.lstCell.SuspendLayout();

                // 再描画を抑制
                RldLib.XlHelper.XlApp.Application.ScreenUpdating = false;

                var wItems = new List<String>();
                //add 8615-710 zhu start
                wItems.Add(this.MainCellAddr);
                //add 8615-710 zhu end
                //del 8615-710 zhu start
                //foreach (var wItem in this.lstCell.Items) wItems.Add(wItem as String);
                //del 8615-710 zhu end
                // 選択中セルを取得
                using (var wXlSelectedCell = RldLib.XlHelper.XlApp.GetSelectedCell)
                    foreach (var wAddress in wXlSelectedCell.GetContainCellAddressList())
                        // 重複しない場合は追加する
                        if (!wItems.Contains(wAddress)) wItems.Add(wAddress);

                // mod #10427 繰返し設定の「選択中セルを追加」が正しく機能しない 高 start
                //this.lstCell.Items.Clear();
                //this.lstCell.Items.AddRange(wItems.ToArray());

                // 追加で選択されたセルをセットする
                foreach (String wItem in wItems)
                {
                    if (!this.lstCell.Items.Contains(wItem))
                        this.lstCell.Items.Add(wItem);
                }
                // mod #10427 繰返し設定の「選択中セルを追加」が正しく機能しない 高 end

                // 並び替える
                this.SortList();
            }
            catch (Exception ex)
            {

            }
            finally
            {
                // 再描画を再開
                RldLib.XlHelper.XlApp.Application.ScreenUpdating = true;

                this.lstCell.ResumeLayout();
            }
        }

        /// <summary>
        /// 繰返し方向ラジオボタンの CheckedChanged イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void radDirection_CheckedChanged(object sender, EventArgs e)
        {
            // 並び替える
            this.SortList();
        }

        /// <summary>
        /// セル順を逆転するチェックボックスの CheckedChanged イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void chkReverse_CheckedChanged(object sender, EventArgs e)
        {
            // 並び替える
            this.SortList();
        }

        /// <summary>
        /// 繰返しセルリストの DragEnter イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void lstCell_DragEnter(object sender, DragEventArgs e)
        {
            // Excel からのドラッグの場合は許可
            if (e.Data.GetDataPresent("SymbolicLink"))
                e.Effect = DragDropEffects.Copy;
        }

        /// <summary>
        /// 繰返しセルリストの DragDrop イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void lstCell_DragDrop(object sender, DragEventArgs e)
        {
            // Excel からのドラッグアンドドロップの場合のみ許可
            if (e.Data.GetDataPresent("SymbolicLink")) this.btnSelectedAdd.PerformClick();
        }

        /// <summary>
        /// 選択中セルを追加してOKボタンの Click イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnAddOK_Click(object sender, EventArgs e)
        {
            // 選択中セルを追加ボタンを押したことにする
            this.btnSelectedAdd.PerformClick();
            // OKボタンを押したことにする
            this.btnOK.PerformClick();
        }

        /// <summary>
        /// キャンセルボタンの Click イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.DialogResult = DialogResult.Cancel;
            this.Close();
        }

        /// <summary>
        /// OKボタンの Click イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnOK_Click(object sender, EventArgs e)
        {
            //edit #9721 繰返し設定で背景に色が付く＆セル内容が消える dongzhaolong start
            try
            {
                this.OldSelectedRepeatAddress = this.SelectedRepeatAddress;
                this.SelectedRepeatAddress = this.MakeCurrentList();
                // add #11294 紹介状で集計部分がずれて出力される 高 start
                // N型の場合は列数
                if (this.radDirectionN.Checked)
                {
                    this.RepDirection = "0";
                }
                else
                {
                    this.RepDirection = "1";
                }
                // add #11294 紹介状で集計部分がずれて出力される 高 end

                //add #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董昊 start
                RldLib.XlHelper.XlApp.Application.ScreenUpdating = false;
                RldLib.XlHelper.IsHandleLayoutSheetEvent = false;
                //DEL #9964 繰返し設定を連続して行っていると致命的エラー DONGZHAOLONG START
                //RldLib.XlHelper.XlSheetLayout.IsProtected = false;
                //DEL #9964 繰返し設定を連続して行っていると致命的エラー DONGZHAOLONG END
                //add #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董昊 end

                // del #9770 繰り返し設定で罫線と背景に異常 donghao start
                // add #9399 【デグレ】オンライン保存時にセル背景色が初期化される donghao start
                //Color color = new Color();
                // add #9399 【デグレ】オンライン保存時にセル背景色が初期化される donghao end
                // mod #9770 繰り返し設定で罫線と背景に異常 donghao start
                //dynamic leftlineStyle = null;
                //dynamic rightlineStyle = null;
                //dynamic toplineStyle = null;
                //dynamic bottomlineStyle = null;

                //dynamic pattern = null;
                //int patternInt = 0;
                //dynamic patternTintAndShade = null;
                //dynamic fontStyle = null;
                //dynamic tintAndShade = null;
                // mod #9770 繰り返し設定で罫線と背景に異常 donghao end
                //add #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董兆龙 start
                //var cellList = this.SelectedRepeatAddress.Split(',');
                //string oldAdress = string.Empty;
                //var oldCellList = this.OldSelectedRepeatAddress.Split(',');
                //var cellList = this.SelectedRepeatAddress.Split(',');
                ////add  #9870  紹介状で集計設定の保存時にエラー dongzhaolong start
                //Microsoft.Office.Interop.Excel.Range copyRange = null;
                ////add  #9870  紹介状で集計設定の保存時にエラー dongzhaolong end
                //    List<DesignParamData> repeatList = RldLib.CurrentLayoutData.DesignParamList.Where(x => x.CanEditRepeat && oldCellList.Contains(x.CellAddress)).ToList();
                //    repeatList.ForEach(a =>
                //    {
                //        RepeatAddress = a.RepeatAddress;
                //        oldAdress = a.CellAddress;
                //        if (oldCellList.Length > 0)
                //        {
                //            for (int i = 0; i < oldCellList.Length; i++)
                //            {
                //                if (oldCellList[i] != oldAdress)
                //                {
                //                    // mod #9770 繰り返し設定で罫線と背景に異常 donghao start
                //                    //Microsoft.Office.Interop.Excel.Range Range = RldLib.XlHelper.XlSheetLayout.Worksheet.get_Range(oldCellList[i].Split(':')[0]);
                //                    Microsoft.Office.Interop.Excel.Range Range = RldLib.XlHelper.XlSheetLayout.Worksheet.get_Range(oldCellList[i]);
                //                    // mod #9770 繰り返し設定で罫線と背景に異常 donghao end
                //                    //pattern = Range.Interior.Pattern;
                //                    //edit  #9870  紹介状で集計設定の保存時にエラー dongzhaolong start
                //                    //if (int.TryParse(Convert.ToString(Range.Interior.Pattern),out patternInt) && patternInt != -4142)
                //                    ////edit  #9870  紹介状で集計設定の保存時にエラー dongzhaolong end
                //                    //{
                //                    //    color = System.Drawing.ColorTranslator.FromOle(Convert.ToInt32(Range.Interior.Color));
                //                    //}
                //                    //else
                //                    //{
                //                    //    color = Color.White;
                //                    //}
                //                    //// add #9770 繰り返し設定で罫線と背景に異常 donghao start
                //                    //if (!DicBackColor.ContainsKey(oldCellList[i]))
                //                    //{
                //                    //    DicBackColor.Add(oldCellList[i], color);
                //                    //}
                //                    //else
                //                    //{
                //                    //    DicBackColor[oldCellList[i]] = color;
                //                    //}

                //                    //leftlineStyle = Range.Borders.Item[Microsoft.Office.Interop.Excel.XlBordersIndex.xlEdgeLeft].LineStyle;
                //                    //rightlineStyle = Range.Borders.Item[Microsoft.Office.Interop.Excel.XlBordersIndex.xlEdgeRight].LineStyle;
                //                    //toplineStyle = Range.Borders.Item[Microsoft.Office.Interop.Excel.XlBordersIndex.xlEdgeTop].LineStyle;
                //                    //bottomlineStyle = Range.Borders.Item[Microsoft.Office.Interop.Excel.XlBordersIndex.xlEdgeBottom].LineStyle;
                //                    //// add #9770 繰り返し設定で罫線と背景に異常 donghao end
                //                    //patternTintAndShade = Range.Interior.PatternTintAndShade;
                //                    //// del #9770 繰り返し設定で罫線と背景に異常 donghao start
                //                    ////tintAndShade = Range.Interior.TintAndShade;
                //                    //// del #9770 繰り返し設定で罫線と背景に異常 donghao end
                //                    //fontStyle = Range.Font.FontStyle;
                //                    if (Range.MergeCells)
                //                    {
                //                        Range.UnMerge();


                //                        RldLib.XlHelper.XlSheetLayout.Worksheet.Range[oldCellList[i]].Clear();
                //                        RldLib.XlHelper.XlSheetLayout.Worksheet.Range[oldCellList[i]].Merge();
                //                        Range = RldLib.XlHelper.XlSheetLayout.Worksheet.Range[oldCellList[i]];
                //                    }
                //                    else
                //                    {
                //                        RldLib.XlHelper.XlSheetLayout.Worksheet.Range[oldCellList[i]].Clear();
                //                    }

                //                    //Range.Interior.Color = color;
                //                    //// add #9770 繰り返し設定で罫線と背景に異常 donghao start
                //                    //Range.Borders.Item[Microsoft.Office.Interop.Excel.XlBordersIndex.xlEdgeLeft].LineStyle = leftlineStyle;
                //                    //Range.Borders.Item[Microsoft.Office.Interop.Excel.XlBordersIndex.xlEdgeRight].LineStyle = rightlineStyle;
                //                    //Range.Borders.Item[Microsoft.Office.Interop.Excel.XlBordersIndex.xlEdgeTop].LineStyle = toplineStyle;
                //                    //Range.Borders.Item[Microsoft.Office.Interop.Excel.XlBordersIndex.xlEdgeBottom].LineStyle = bottomlineStyle;
                //                    //// add #9770 繰り返し設定で罫線と背景に異常 donghao end
                //                    //Range.Interior.Pattern = pattern;
                //                    //// del #9770 繰り返し設定で罫線と背景に異常 donghao start
                //                    ////Range.Interior.TintAndShade = tintAndShade;
                //                    //// del #9770 繰り返し設定で罫線と背景に異常 donghao end
                //                    //Range.Interior.PatternTintAndShade = patternTintAndShade;  
                //                    //Range.Font.FontStyle = fontStyle;
                //                }
                //            }
                //        }
                //        if (cellList.Length > 0)
                //        {

                //            if (cellList.Contains(oldAdress))
                //            {
                //                Microsoft.Office.Interop.Excel.Range currentRange = RldLib.XlHelper.XlSheetLayout.Worksheet.get_Range(oldAdress);
                //                Boolean bMerged = currentRange.MergeCells;
                //                if (bMerged == true)
                //                {
                //                    currentRange.UnMerge();
                //                    //edit  #9870  紹介状で集計設定の保存時にエラー dongzhaolong start
                //                    copyRange = RldLib.XlHelper.XlSheetLayout.Worksheet.Range[oldAdress.Split(':')[0]];
                //                    //currentRange.Copy(Type.Missing);
                //                    //edit  #9870  紹介状で集計設定の保存時にエラー dongzhaolong end
                //                }
                //                else
                //                {
                //                    //edit  #9870  紹介状で集計設定の保存時にエラー dongzhaolong start
                //                    copyRange = currentRange;
                //                    //RldLib.XlHelper.XlSheetLayout.Worksheet.Range[oldAdress].Copy(Type.Missing);
                //                    //edit  #9870  紹介状で集計設定の保存時にエラー dongzhaolong end
                //                }
                //                for (int i = 0; i < cellList.Length; i++)
                //                {
                //                    if (cellList[i] != oldAdress)
                //                    {
                //                        // mod #9770 繰り返し設定で罫線と背景に異常 donghao start
                //                        //Microsoft.Office.Interop.Excel.Range Range = RldLib.XlHelper.XlSheetLayout.Worksheet.get_Range(cellList[i].Split(':')[0]);
                //                        Microsoft.Office.Interop.Excel.Range Range = RldLib.XlHelper.XlSheetLayout.Worksheet.get_Range(cellList[i]);
                //                        // mod #9770 繰り返し設定で罫線と背景に異常 donghao end
                //                        //color = System.Drawing.ColorTranslator.FromOle(Convert.ToInt32(Range.Interior.Color));
                //                        //// add #9770 繰り返し設定で罫線と背景に異常 donghao start
                //                        ////lineStyle = Range.Borders.LineStyle;
                //                        //leftlineStyle = Range.Borders.Item[Microsoft.Office.Interop.Excel.XlBordersIndex.xlEdgeLeft].LineStyle;
                //                        //rightlineStyle = Range.Borders.Item[Microsoft.Office.Interop.Excel.XlBordersIndex.xlEdgeRight].LineStyle;
                //                        //toplineStyle = Range.Borders.Item[Microsoft.Office.Interop.Excel.XlBordersIndex.xlEdgeTop].LineStyle;
                //                        //bottomlineStyle = Range.Borders.Item[Microsoft.Office.Interop.Excel.XlBordersIndex.xlEdgeBottom].LineStyle;
                //                        //// add #9770 繰り返し設定で罫線と背景に異常 donghao end
                //                        //pattern = Range.Interior.Pattern;
                //                        //patternTintAndShade = Range.Interior.PatternTintAndShade;
                //                        //// del #9770 繰り返し設定で罫線と背景に異常 donghao start
                //                        ////tintAndShade = Range.Interior.TintAndShade;
                //                        //// del #9770 繰り返し設定で罫線と背景に異常 donghao end
                //                        //fontStyle = Range.Font.FontStyle;
                //                        if (Range.MergeCells)
                //                        {
                //                            Range.UnMerge();
                //                            //edit  #9870  紹介状で集計設定の保存時にエラー dongzhaolong start
                //                            copyRange.Copy(Type.Missing);
                //                            //edit  #9870  紹介状で集計設定の保存時にエラー dongzhaolong end
                //                            //RldLib.XlHelper.XlSheetLayout.Worksheet.Range[cellList[i].Split(':')[0]].PasteSpecial(Microsoft.Office.Interop.Excel.XlPasteType.xlPasteAllExceptBorders, Microsoft.Office.Interop.Excel.XlPasteSpecialOperation.xlPasteSpecialOperationNone, System.Type.Missing, System.Type.Missing);
                //                            if (oldAdress != cellList[i])
                //                            {
                //                                RldLib.XlHelper.XlSheetLayout.Worksheet.Range[cellList[i]].Cells.Value = "";
                //                            }
                //                            RldLib.XlHelper.XlSheetLayout.Worksheet.Range[cellList[i]].Merge();
                //                        }
                //                        else
                //                        {
                //                            //edit  #9870  紹介状で集計設定の保存時にエラー dongzhaolong start
                //                            copyRange.Copy(Type.Missing);
                //                            //edit  #9870  紹介状で集計設定の保存時にエラー dongzhaolong end
                //                            //RldLib.XlHelper.XlSheetLayout.Worksheet.Range[cellList[i]].PasteSpecial(Microsoft.Office.Interop.Excel.XlPasteType.xlPasteAllExceptBorders, Microsoft.Office.Interop.Excel.XlPasteSpecialOperation.xlPasteSpecialOperationNone, System.Type.Missing, System.Type.Missing);
                //                            if (oldAdress != cellList[i])
                //                            {
                //                                RldLib.XlHelper.XlSheetLayout.Worksheet.Range[cellList[i]].Cells.Value = "";
                //                            }
                //                        }
                //                        //Range.Interior.Color = color;
                //                        //// mod #9770 繰り返し設定で罫線と背景に異常 donghao start
                //                        ////Range.Borders.LineStyle = lineStyle;
                //                        ////Range.Borders.Item[XlBordersIndex.xlEdgeLeft].LineStyle = lineStyle;
                //                        //Range.Borders.Item[Microsoft.Office.Interop.Excel.XlBordersIndex.xlEdgeLeft].LineStyle = leftlineStyle;
                //                        //Range.Borders.Item[Microsoft.Office.Interop.Excel.XlBordersIndex.xlEdgeRight].LineStyle = rightlineStyle;
                //                        //Range.Borders.Item[Microsoft.Office.Interop.Excel.XlBordersIndex.xlEdgeTop].LineStyle = toplineStyle;
                //                        //Range.Borders.Item[Microsoft.Office.Interop.Excel.XlBordersIndex.xlEdgeBottom].LineStyle = bottomlineStyle;
                //                        //Range.Interior.Pattern = pattern;
                //                        ////Range.Interior.TintAndShade = tintAndShade;
                //                        //// mod #9770 繰り返し設定で罫線と背景に異常 donghao end
                //                        //Range.Interior.PatternTintAndShade = patternTintAndShade;
                //                    }
                //                }
                //                if (bMerged == true)
                //                {
                //                    Microsoft.Office.Interop.Excel.Range mergeRange = RldLib.XlHelper.XlSheetLayout.Worksheet.get_Range(oldAdress.Split(':')[0], oldAdress.Split(':')[1]);
                //                    mergeRange.Merge();
                //                    mergeRange.Select();
                //                }
                //                else
                //                {                            
                //                    RldLib.XlHelper.XlSheetLayout.Worksheet.Range[oldAdress].Select();
                //                }
                //            }
                //        }
                //    });
                // del #9770 繰り返し設定で罫線と背景に異常 donghao end
                this.OldSelectedRepeatAddress = this.SelectedRepeatAddress;

                    this.DialogResult = DialogResult.OK;
                    this.Close();
            }
            catch (Exception)
            {

                throw;
            }
            finally
            {
                RldLib.XlHelper.XlApp.Application.ScreenUpdating = true;
                RldLib.XlHelper.IsHandleLayoutSheetEvent = true;
                //DEL #9964 繰返し設定を連続して行っていると致命的エラー DONGZHAOLONG START
                //RldLib.XlHelper.XlSheetLayout.IsProtected = true;
                //DEL #9964 繰返し設定を連続して行っていると致命的エラー DONGZHAOLONG END
            }
            //edit #9721 繰返し設定で背景に色が付く＆セル内容が消える dongzhaolong end
        }

        // del #9816 テンプレート設定に関する処理がデザイナと帳票生成時で重複している limingzhe start
        //add #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董昊 start
        /// <summary>
        /// フォーマット同期
        /// </summary>
        //public void syncStyle()
        //{
        //    // add #9816 テンプレート設定に関する処理がデザイナと帳票生成時で重複している 高 start
        //    if (RldLib.CurrentLayoutData.DesignSettingData.ReportClass == RldConst.ReportTypeData.VAL_TYPE_ONE_PATIENT)
        //    {
        //        return;
        //    }
        //    // add #9816 テンプレート設定に関する処理がデザイナと帳票生成時で重複している 高 end
        //    //edit #9721 繰返し設定で背景に色が付く＆セル内容が消える dongzhaolong start
        //    //del #9648 【デグレ】オンライン保存の実行中Excelのウインドウがグレーで潰れる dongzhaolong start
        //    //add #9878 【デグレ】Excelの編集欄が更新されないときがある dongzhaolong start
        //    RldLib.XlHelper.XlApp.Application.ScreenUpdating = false;
        //    RldLib.XlHelper.IsHandleLayoutSheetEvent = false;
        //    //add #9878 【デグレ】Excelの編集欄が更新されないときがある dongzhaolong end
        //    //del #9648 【デグレ】オンライン保存の実行中Excelのウインドウがグレーで潰れる dongzhaolong end
        //    //del #9602 デグレ】フィルタ設定に関する不具合2点 dongzhaolong start
        //    //RldLib.XlHelper.XlSheetLayout.IsProtected = false;
        //    //del #9602 デグレ】フィルタ設定に関する不具合2点 dongzhaolong end

        //    string oldAdress = string.Empty;
        //    // add #9399 【デグレ】オンライン保存時にセル背景色が初期化される donghao start
        //    Color color = new Color();
        //    // mod #9770 繰り返し設定で罫線と背景に異常 donghao start
        //    //dynamic lineStyle = null;
        //    dynamic pattern = null;
        //    int patternInt = 0;
        //    dynamic patternTintAndShade = null;
        //    //dynamic tintAndShade = null;
        //    dynamic leftlineStyle = null;
        //    dynamic rightlineStyle = null;
        //    dynamic toplineStyle = null;
        //    dynamic bottomlineStyle = null;
        //    // mod #9770 繰り返し設定で罫線と背景に異常 donghao end
        //    // add #9399 【デグレ】オンライン保存時にセル背景色が初期化される donghao end
        //    List<DesignParamData> repeatList = RldLib.CurrentLayoutData.DesignParamList.Where(x => x.CanEditRepeat).ToList();
        //    //add  #9870  紹介状で集計設定の保存時にエラー dongzhaolong start
        //    Microsoft.Office.Interop.Excel.Range copyRange = null;
        //    //add  #9870  紹介状で集計設定の保存時にエラー dongzhaolong end
        //    repeatList.ForEach( a =>{
        //        RepeatAddress = a.RepeatAddress;
        //        oldAdress = a.CellAddress;
        //        var cellList = RepeatAddress.Split(',');

        //        if (cellList.Length > 0)
        //        {
        //            Microsoft.Office.Interop.Excel.Range currentRange = RldLib.XlHelper.XlSheetLayout.Worksheet.get_Range(oldAdress);

        //            Boolean bMerged = currentRange.MergeCells;

        //            if (bMerged == true)
        //            {
        //                currentRange.UnMerge();
        //                //edit  #9870  紹介状で集計設定の保存時にエラー dongzhaolong start
        //                copyRange = RldLib.XlHelper.XlSheetLayout.Worksheet.Range[oldAdress.Split(':')[0]];
        //                //currentRange.Copy(Type.Missing);
        //                //edit  #9870  紹介状で集計設定の保存時にエラー dongzhaolong end
        //            }
        //            else
        //            {
        //                //edit  #9870  紹介状で集計設定の保存時にエラー dongzhaolong start
        //                copyRange = currentRange;
        //                //RldLib.XlHelper.XlSheetLayout.Worksheet.Range[oldAdress].Copy(Type.Missing);
        //                //edit  #9870  紹介状で集計設定の保存時にエラー dongzhaolong end
        //            }


        //            for (int i = 0; i < cellList.Length; i++)
        //            {
        //                if (cellList[i] != oldAdress)
        //                {
        //                    // mod #9770 繰り返し設定で罫線と背景に異常 donghao start
        //                    //Microsoft.Office.Interop.Excel.Range Range = RldLib.XlHelper.XlSheetLayout.Worksheet.get_Range(cellList[i].Split(':')[0]);
        //                    Microsoft.Office.Interop.Excel.Range Range = RldLib.XlHelper.XlSheetLayout.Worksheet.get_Range(cellList[i]);
        //                    // mod #9770 繰り返し設定で罫線と背景に異常 donghao end
        //                    // add #9399 【デグレ】オンライン保存時にセル背景色が初期化される donghao start
        //                    //edit  #9870  紹介状で集計設定の保存時にエラー dongzhaolong start
        //                    if (int.TryParse(Convert.ToString(Range.Interior.Pattern), out patternInt) && patternInt != -4142)
        //                    //edit  #9870  紹介状で集計設定の保存時にエラー dongzhaolong end
        //                    {
        //                        color = System.Drawing.ColorTranslator.FromOle(Convert.ToInt32(Range.Interior.Color));
        //                    }
        //                    else
        //                    {
        //                        color = Color.White;
        //                    }
        //                    //// mod #9770 繰り返し設定で罫線と背景に異常 donghao start
        //                    //if (!DicBackColor.ContainsKey(cellList[i]))
        //                    //{
        //                    //    DicBackColor.Add(cellList[i], color);
        //                    //}
        //                    //else
        //                    //{
        //                    //    DicBackColor[cellList[i]] = color;
        //                    //}

        //                    //lineStyle = Range.Borders.LineStyle;
        //                    pattern = Range.Interior.Pattern;
        //                    patternTintAndShade = Range.Interior.PatternTintAndShade;
        //                    //tintAndShade = Range.Interior.TintAndShade;
        //                    leftlineStyle = Range.Borders.Item[Microsoft.Office.Interop.Excel.XlBordersIndex.xlEdgeLeft].LineStyle;
        //                    rightlineStyle = Range.Borders.Item[Microsoft.Office.Interop.Excel.XlBordersIndex.xlEdgeRight].LineStyle;
        //                    toplineStyle = Range.Borders.Item[Microsoft.Office.Interop.Excel.XlBordersIndex.xlEdgeTop].LineStyle;
        //                    bottomlineStyle = Range.Borders.Item[Microsoft.Office.Interop.Excel.XlBordersIndex.xlEdgeBottom].LineStyle;
        //                    // add #9399 【デグレ】オンライン保存時にセル背景色が初期化される donghao end
        //                    // mod #9770 繰り返し設定で罫線と背景に異常 donghao end

        //                    if (Range.MergeCells)
        //                    {
        //                        Range.UnMerge();
        //                        //edit  #9870  紹介状で集計設定の保存時にエラー dongzhaolong start
        //                        copyRange.Copy(Type.Missing);
        //                        //edit  #9870  紹介状で集計設定の保存時にエラー dongzhaolong end
        //                        // mod #9770 繰り返し設定で罫線と背景に異常 donghao start
        //                        //RldLib.XlHelper.XlSheetLayout.Worksheet.Range[cellList[i].Split(':')[0]].PasteSpecial(Microsoft.Office.Interop.Excel.XlPasteType.xlPasteAllExceptBorders, Microsoft.Office.Interop.Excel.XlPasteSpecialOperation.xlPasteSpecialOperationNone, System.Type.Missing, System.Type.Missing);
        //                        RldLib.XlHelper.XlSheetLayout.Worksheet.Range[cellList[i].Split(':')[0]].PasteSpecial(Microsoft.Office.Interop.Excel.XlPasteType.xlPasteFormats);
        //                        RldLib.XlHelper.XlSheetLayout.Worksheet.Range[cellList[i].Split(':')[0]].PasteSpecial(Microsoft.Office.Interop.Excel.XlPasteType.xlPasteValuesAndNumberFormats);
        //                        // mod #9770 繰り返し設定で罫線と背景に異常 donghao end
        //                        //RldLib.XlHelper.XlSheetLayout.Worksheet.Range[cellList[i]].Cells.Value = "";
        //                        if (oldAdress != cellList[i])
        //                        {
        //                            RldLib.XlHelper.XlSheetLayout.Worksheet.Range[cellList[i]].Cells.Value = "";
        //                        }
        //                        // mod #9399 【デグレ】オンライン保存時にセル背景色が初期化される donghao start
        //                        /*   Range.Interior.Pattern = Microsoft.Office.Interop.Excel.Constants.xlNone;
        //                           Range.Interior.TintAndShade = 0;
        //                           Range.Interior.PatternTintAndShade = 0;*/
        //                        //Range.Interior.Color = color;
        //                        // mod #9399 【デグレ】オンライン保存時にセル背景色が初期化される donghao end

        //                        RldLib.XlHelper.XlSheetLayout.Worksheet.Range[cellList[i]].Merge();

        //                    }
        //                    else
        //                    {
        //                        //edit  #9870  紹介状で集計設定の保存時にエラー dongzhaolong start
        //                        copyRange.Copy(Type.Missing);
        //                        //edit  #9870  紹介状で集計設定の保存時にエラー dongzhaolong end
        //                        // mod #9770 繰り返し設定で罫線と背景に異常 donghao start
        //                        //RldLib.XlHelper.XlSheetLayout.Worksheet.Range[cellList[i]].PasteSpecial(Microsoft.Office.Interop.Excel.XlPasteType.xlPasteAllExceptBorders, Microsoft.Office.Interop.Excel.XlPasteSpecialOperation.xlPasteSpecialOperationNone, System.Type.Missing, System.Type.Missing);
        //                        RldLib.XlHelper.XlSheetLayout.Worksheet.Range[cellList[i].Split(':')[0]].PasteSpecial(Microsoft.Office.Interop.Excel.XlPasteType.xlPasteFormats);
        //                        RldLib.XlHelper.XlSheetLayout.Worksheet.Range[cellList[i].Split(':')[0]].PasteSpecial(Microsoft.Office.Interop.Excel.XlPasteType.xlPasteValuesAndNumberFormats);
        //                        // mod #9770 繰り返し設定で罫線と背景に異常 donghao end
        //                        //RldLib.XlHelper.XlSheetLayout.Worksheet.Range[cellList[i]].Cells.Value = "";
        //                        if (oldAdress != cellList[i])
        //                        {
        //                            RldLib.XlHelper.XlSheetLayout.Worksheet.Range[cellList[i]].Cells.Value = "";
        //                        }
        //                        // add #9399 【デグレ】オンライン保存時にセル背景色が初期化される donghao start
        //                        /* Range.Interior.Pattern = Microsoft.Office.Interop.Excel.Constants.xlNone;
        //                         Range.Interior.TintAndShade = 0;
        //                         Range.Interior.PatternTintAndShade = 0;*/
        //                        //Range.Interior.Color = color;
        //                        // add #9399 【デグレ】オンライン保存時にセル背景色が初期化される donghao end
        //                    }
        //                    Range.Interior.Color = color;
        //                    // mod #9770 繰り返し設定で罫線と背景に異常 donghao start
        //                    //Range.Borders.LineStyle = lineStyle;
        //                    Range.Interior.Pattern = pattern;
        //                    //Range.Interior.TintAndShade = tintAndShade;
        //                    Range.Interior.PatternTintAndShade = patternTintAndShade;
        //                    Range.Borders.Item[Microsoft.Office.Interop.Excel.XlBordersIndex.xlEdgeLeft].LineStyle = leftlineStyle;
        //                    Range.Borders.Item[Microsoft.Office.Interop.Excel.XlBordersIndex.xlEdgeRight].LineStyle = rightlineStyle;
        //                    Range.Borders.Item[Microsoft.Office.Interop.Excel.XlBordersIndex.xlEdgeTop].LineStyle = toplineStyle;
        //                    Range.Borders.Item[Microsoft.Office.Interop.Excel.XlBordersIndex.xlEdgeBottom].LineStyle = bottomlineStyle;
        //                    // mod #9770 繰り返し設定で罫線と背景に異常 donghao end
        //                }
        //            }

        //            if (bMerged == true)
        //            {
        //                //edit #9196 オンライン保存すると例外発生することがある dongzhaolong start
        //                Microsoft.Office.Interop.Excel.Range mergeRange = RldLib.XlHelper.XlSheetLayout.Worksheet.get_Range(oldAdress.Split(':')[0], oldAdress.Split(':')[1]);
        //                //edit #9196 オンライン保存すると例外発生することがある dongzhaolong end
        //                //currentRange.Copy(Type.Missing);
        //                mergeRange.Merge();
        //                mergeRange.Select();
        //            }
        //            else
        //            {

        //                RldLib.XlHelper.XlSheetLayout.Worksheet.Range[oldAdress].Select();
        //            }
        //        }

        //        this.OldSelectedRepeatAddress = RepeatAddress;
        //    });
        //    // mod #9399 【デグレ】オンライン保存時にセル背景色が初期化される donghao end

        //    //del #9648 【デグレ】オンライン保存の実行中Excelのウインドウがグレーで潰れる dongzhaolong start
        //    //add #9878 【デグレ】Excelの編集欄が更新されないときがある dongzhaolong start
        //    RldLib.XlHelper.XlApp.Application.ScreenUpdating = true;
        //    RldLib.XlHelper.IsHandleLayoutSheetEvent = true;
        //    //add #9878 【デグレ】Excelの編集欄が更新されないときがある dongzhaolong end
        //    //del #9648 【デグレ】オンライン保存の実行中Excelのウインドウがグレーで潰れる dongzhaolong end
        //    //del #9602 デグレ】フィルタ設定に関する不具合2点 dongzhaolong start
        //    //RldLib.XlHelper.XlSheetLayout.IsProtected = true;
        //    //del #9602 デグレ】フィルタ設定に関する不具合2点 dongzhaolong end
        //    //edit #9721 繰返し設定で背景に色が付く＆セル内容が消える dongzhaolong end
        //}
        //add #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董昊 end
        // del #9816 テンプレート設定に関する処理がデザイナと帳票生成時で重複している limingzhe end
        #endregion
    }
}
