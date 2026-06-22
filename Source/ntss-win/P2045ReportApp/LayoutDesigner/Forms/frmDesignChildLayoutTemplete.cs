using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using RldUtility = LayoutDesignerUtilityLib.LayoutDesignerUtility;
//ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG START
using LayoutDesigner.Helpers;
//ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG END
//ADD #9425 テンプレート設定範囲に影響のあるレイアウト変更時は範囲プレビューを更新すること DONGZHAOLONG START
using System.Text.RegularExpressions;
//ADD #9425 テンプレート設定範囲に影響のあるレイアウト変更時は範囲プレビューを更新すること DONGZHAOLONG END

namespace LayoutDesigner
{
    /// <summary>
    /// デザイナーウィンドウ内テンプレート繰返し編集画面
    /// </summary>
    public partial class frmDesignChildLayoutTemplete : LayoutDesignerUtilityLib.Controls.frmRldBase, IRldDesignRecvOnlyColleague, IRldDesignSendOnlyColleague
    {
        #region メンバ定数定義

        /// <summary>
        /// 下部プロパティウィンドウの列インデックス(プロパティ名)
        /// </summary>
        private const int DETAIL_COL_INDEX_NAME = 0;
        /// <summary>
        /// 下部プロパティウィンドウの列インデックス(プロパティ値)
        /// </summary>
        private const int DETAIL_COL_INDEX_VALUE = 1;
        //mod #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董昊 START
        private static int oldRepeatH { get; set; } = 1;
        private static int oldRepeatV { get; set; } = 1;
        private int newRepeatH { get; set; } = 1;
        private int newRepeatV { get; set; } = 1;
        private static int oldMarginH { get; set; } = 0;
        private static int oldMarginV { get; set; } = 0;
        private int newMarginH { get; set; } = 0;
        private int newMarginV { get; set; } = 0;
        private static Boolean cellEdit { get; set; } = false;
        public Boolean meditTotal { get; set; } = false;
        //mod #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董昊 END
        //edit #9794 セル連続クリックで致命的エラー2種類 dongzhaolong start
        //ADD #9425 テンプレート設定範囲に影響のあるレイアウト変更時は範囲プレビューを更新すること DONGZHAOLONG START
        public static Boolean isSkip = false;
        public static Boolean isSelectionDone = true;
        //ADD #9425 テンプレート設定範囲に影響のあるレイアウト変更時は範囲プレビューを更新すること DONGZHAOLONG START
		// add #10137 テンプレート設定されているとコピー領域が1回しかペーストできない limingzhe start
        public static Boolean isChanged = false;
		// add #10137 テンプレート設定されているとコピー領域が1回しかペーストできない limingzhe end
        public static Boolean methodExecuted = false;
        private static bool alreadyOnLoad = false;
        private static SemaphoreSlim semaphore = new SemaphoreSlim(1, 1);
        private static readonly ManualResetEventSlim condition = new ManualResetEventSlim();
        //edit #9794 セル連続クリックで致命的エラー2種類 dongzhaolong start
        #endregion

        #region メンバイベント定義

        /// <summary>
        /// 通知用イベント
        /// </summary>
        public event EventHandler<RldDesignNotifyInfoEventArgs> NotifyInfo;

        #endregion

        #region 生成と破棄

        /// <summary>
        /// デザイナーウィンドウ内テンプレート繰返し編集画面の新しいインスタンスを初期化します。
        /// </summary>
        public frmDesignChildLayoutTemplete()
        {
            InitializeComponent();
            this.pnlBottom.Height = 0;

            //add #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 START
            /*    if (RldLib.CurrentLayoutData.DesignParamList.Count > 0 && RldLib.CurrentLayoutData.DesignTempleteData != null)
                {
                    meditTotal = true;
                }*/

            meditTotal = true;

            if (RldLib.CurrentLayoutData.DesignTempleteData != null)
            {
                newRepeatV = int.Parse(RldLib.CurrentLayoutData.DesignTempleteData.RepeatCountV);
                newRepeatH = int.Parse(RldLib.CurrentLayoutData.DesignTempleteData.RepeatCountH);
                newMarginV = int.Parse(RldLib.CurrentLayoutData.DesignTempleteData.MarginV);
                newMarginH = int.Parse(RldLib.CurrentLayoutData.DesignTempleteData.MarginH);

            }
            //add #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 END
            //add #9794 セル連続クリックで致命的エラー2種類 dongzhaolong start 
            RldLib.XlHelper.LayoutSheetChange += new EventHandler<RldSimpleTextEventArgs>(this.XlLayoutSheet_Change);
			// add #10137 テンプレート設定されているとコピー領域が1回しかペーストできない limingzhe start
            RldLib.XlHelper.LayoutSheetBeforeDoubleClick += new EventHandler<RldSimpleTextEventArgs>(this.XlLayoutSheet_BeforeDoubleClick);
			// add #10137 テンプレート設定されているとコピー領域が1回しかペーストできない limingzhe end
            //#9822 NG 【デグレ】セル選択移動時の不具合 DONGZHAOLONG START
            //RldLib.XlHelper.LayoutSheetSelectionChange += new EventHandler<RldSimpleTextEventArgs>(this.XlLayoutSheet_SelectionChange);
            //#9822 NG 【デグレ】セル選択移動時の不具合 DONGZHAOLONG END
            //add #9794 セル連続クリックで致命的エラー2種類 dongzhaolong end
            // add #10230 コピーした内容がリセットされる 高 start
            // 画像を更新
            this.UpdateTempleteAreaImage();
            // add #10230 コピーした内容がリセットされる 高 end
        }

        #endregion

        #region メンバ関数定義(override...)

        /// <summary>
        /// Form.Load イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnLoad(EventArgs e)
        {
            //add #9794 セル連続クリックで致命的エラー2種類 dongzhaolong start
            if (this.Visible == false && alreadyOnLoad == false)
            {
				// add #10137 テンプレート設定されているとコピー領域が1回しかペーストできない limingzhe start
                isChanged = false;
				// add #10137 テンプレート設定されているとコピー領域が1回しかペーストできない limingzhe end
                return;
            }
            //add #9794 セル連続クリックで致命的エラー2種類 dongzhaolong end
            base.OnLoad(e);

            if (base.DesignMode) return;

            // 画面をクリア
            // mod #10230 コピーした内容がリセットされる 高 start
            //this.DataClear(true);
            this.DataClear(false);
            // mod #10230 コピーした内容がリセットされる 高 end

            // add 2020-10-29 FNSI-改修 637バグの修正 夏 start
            Control.CheckForIllegalCrossThreadCalls = false;
            // add 2020-10-29 FNSI-改修 637バグの修正 夏 end
            //del #9794 セル連続クリックで致命的エラー2種類 dongzhaolong start
            //ADD #9425 テンプレート設定範囲に影響のあるレイアウト変更時は範囲プレビューを更新すること DONGZHAOLONG START
            //RldLib.XlHelper.LayoutSheetChange -= new EventHandler<RldSimpleTextEventArgs>(this.XlLayoutSheet_Change);
            //RldLib.XlHelper.LayoutSheetChange += new EventHandler<RldSimpleTextEventArgs>(this.XlLayoutSheet_Change);
            //RldLib.XlHelper.LayoutSheetSelectionChange -= new EventHandler<RldSimpleTextEventArgs>(this.XlLayoutSheet_SelectionChange);
            //RldLib.XlHelper.LayoutSheetSelectionChange += new EventHandler<RldSimpleTextEventArgs>(this.XlLayoutSheet_SelectionChange);
            //ADD #9425 テンプレート設定範囲に影響のあるレイアウト変更時は範囲プレビューを更新すること DONGZHAOLONG END
            //del #9794 セル連続クリックで致命的エラー2種類 dongzhaolong end
            //add #9794 セル連続クリックで致命的エラー2種類 dongzhaolong start
            // del #10230 コピーした内容がリセットされる 高 start
            //alreadyOnLoad = true;
            // del #10230 コピーした内容がリセットされる 高 start
            //edaddit #9794 セル連続クリックで致命的エラー2種類 dongzhaolong end
        }
        //ADD #9425 テンプレート設定範囲に影響のあるレイアウト変更時は範囲プレビューを更新すること DONGZHAOLONG START
        /// <summary>
        /// Excel レイアウトシートの SelectionChange イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void XlLayoutSheet_SelectionChange(Object sender, RldSimpleTextEventArgs e)
        {
            //edit #9794 セル連続クリックで致命的エラー2種類 dongzhaolong start
            if (semaphore.Wait(0))
            {
                try
                {
                    //edit #9794 セル連続クリックで致命的エラー2種類 dongzhaolong end
                    var currentCell = e.Text.Split(':');
                    if (!(Regex.Matches(currentCell[0], "[a-zA-z]").Count > 0 && Regex.Matches(currentCell[0], @"\d").Count > 0))
                    {
                        return;
                    }
                    //edit #9794 セル連続クリックで致命的エラー2種類 dongzhaolong end
                    isSelectionDone = false;
                    this.OnLoad(e);
                    isSelectionDone = true;
                }
                catch (Exception ex)
                {
                    isSelectionDone = true;
                }
                finally
                {
                    semaphore.Release();
                }
            }
            //edit #9794 セル連続クリックで致命的エラー2種類 dongzhaolong end
        }
		// add #10137 テンプレート設定されているとコピー領域が1回しかペーストできない limingzhe start
        /// <summary>
        /// Excel レイアウトシートの BeforeDoubleClick イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void XlLayoutSheet_BeforeDoubleClick(Object sender, RldSimpleTextEventArgs e)
        {
            isChanged = true;
        }
		// add #10137 テンプレート設定されているとコピー領域が1回しかペーストできない limingzhe end
        //ADD #9425 テンプレート設定範囲に影響のあるレイアウト変更時は範囲プレビューを更新すること DONGZHAOLONG END

        /// <summary>
        /// Excel レイアウトシートの SelectionChange イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void XlLayoutSheet_Change(Object sender, RldSimpleTextEventArgs e)
        {
            //edit #9794 セル連続クリックで致命的エラー2種類 dongzhaolong start
            if (semaphore.Wait(0))
            {
                try
                {
                    isSelectionDone = false;
                    this.OnLoad(e);
                    isSelectionDone = true;
                }
                catch (Exception ex)
                {
                    isSelectionDone = true;
                }
                finally
                {
                    semaphore.Release();
                }
            }
            //edit #9794 セル連続クリックで致命的エラー2種類 dongzhaolong end
        }

        // add 2020-10-29 FNSI-改修 637バグの修正 夏 start
        public void FormRefresh()
        {
            //RldLib.XlHelper.XlSheetLayout.Worksheet.Range[RldLib.CurrentLayoutData.DesignTempleteData.Range].Select();
            bool IfTimesEnd = false;
            bool IfRunOver = false;
            Thread th_wordprocess = new Thread(new ThreadStart(RefreshTempleteAreaData));
            th_wordprocess.SetApartmentState(ApartmentState.STA);
            th_wordprocess.Start();
            while (!IfRunOver)
            {

                IfTimesEnd = th_wordprocess.IsAlive;
                System.Windows.Forms.Application.DoEvents();
                if (!IfTimesEnd || IfRunOver)
                {
                    th_wordprocess.Interrupt();
                    th_wordprocess.Abort();
                    IfTimesEnd = false;
                    break;
                }
            }
        }
        private void RefreshTempleteAreaData()
        {
            // 画像を更新
            // del #10230 コピーした内容がリセットされる 高 start
            //this.UpdateTempleteAreaImage();
            // del #10230 コピーした内容がリセットされる 高 end
            // データを再読み込み
            this.UpdateDetailGrid(true);
            // 全てのパラメータデータがテンプレート範囲に含まれているか更新
            RldLib.UpdateDesignParamDataIsInTemplete();
        }
        // add 2020-10-29 FNSI-改修 637バグの修正 夏 end

        /// <summary>
        /// Form.Shown イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnShown(EventArgs e)
        {
            base.OnShown(e);

            // 画像を更新
            // mod #10230 コピーした内容がリセットされる 高 start
            if (alreadyOnLoad == false)
            {
                alreadyOnLoad = true;
                this.UpdateTempleteAreaImage();
            }
            // mod #10230 コピーした内容がリセットされる 高 end
            // 画面にデータを読み込む
            this.UpdateDetailGrid(false);
			// add #10137 テンプレート設定されているとコピー領域が1回しかペーストできない limingzhe start
            if (isChanged)
            {
                RldLib.XlHelper.ClearClipboard();
                isChanged = false;
            }
			// add #10137 テンプレート設定されているとコピー領域が1回しかペーストできない limingzhe end
        }

        #endregion

        #region メンバ関数定義

        /// <summary>
        /// 画面の入力内容をクリアします。
        /// </summary>
        /// <param name="aIsKeyClear">(未使用)</param>
        private void DataClear(Boolean aIskeyClear)
        {
            if (aIskeyClear)
                this.picTmpl.Image = null;
            //edit #9794 セル連続クリックで致命的エラー2種類 dongzhaolong start
            if (isSelectionDone == true)
            {
                this.dgvTmplDetail.RowCount = 0;
            }
            //edit #9794 セル連続クリックで致命的エラー2種類 dongzhaolong start
        }

        /// <summary>
        /// 選択範囲をテンプレート繰返し領域として取得します。
        /// </summary>
        private void UpdateTempleteAreaData()
        {
            try
            {
                using (var wXlRange = RldLib.XlHelper.XlApp.GetSelectedCell)
                {

                    if (RldLib.CurrentLayoutData.DesignTempleteData == null)
                        RldLib.CurrentLayoutData.DesignTempleteData = new DesignTempleteData();

                    // セル範囲を取得
                    RldLib.CurrentLayoutData.DesignTempleteData.Range = wXlRange.Range.Address[false, false];
                    RldLib.CurrentLayoutData.DesignTempleteData.RangeRowNo = wXlRange.Range.Row;
                    RldLib.CurrentLayoutData.DesignTempleteData.RangeColumnNo = wXlRange.Range.Column;

                    using (var wXlRows = new ExcelRangeEx(wXlRange.Range.Rows))
                    using (var wXlColumns = new ExcelRangeEx(wXlRange.Range.Columns))
                    {
                        // add #9157 FNW帳票取り込み時の不正 董昊 start
                        RldLib.CurrentLayoutData.DesignTempleteData.SizeRowCount = 0;
                        RldLib.CurrentLayoutData.DesignTempleteData.SizeColumnCount = 0;
                        // add #9157 FNW帳票取り込み時の不正 董昊 end

                        // 行数と列数を取得
                        RldLib.CurrentLayoutData.DesignTempleteData.RowCount = wXlRows.Range.Count;
                        RldLib.CurrentLayoutData.DesignTempleteData.ColumnCount = wXlColumns.Range.Count;
                    }
                }

                if (!String.IsNullOrEmpty(RldLib.CurrentLayoutData.DesignTempleteData.Range))
                    RldLib.CurrentLayoutData.DesignSettingData.HasTemplete = RldConst.SettingData.VAL_HAS_TEMPLETE_YES;

                // 画像を更新
                // del #10230 コピーした内容がリセットされる 高 start
                //this.UpdateTempleteAreaImage();
                // del #10230 コピーした内容がリセットされる 高 end
                // データを再読み込み
                this.UpdateDetailGrid(true);
                // 全てのパラメータデータがテンプレート範囲に含まれているか更新
                RldLib.UpdateDesignParamDataIsInTemplete();
            }
            catch (Exception ex)
            {
                // 例外情報を生成
                var wEx = new System.ApplicationException("テンプレート繰返し範囲の更新中にエラーが発生しました。\r\n編集途中の場合は編集を完了して下さい。", ex);
                // 例外情報を記録(画面にメッセージボックスを表示)
                this.SendNotifyInfo(new RldDesignNotifyInfoRequestRecordExceptionEventArgs(wEx, true));
            }
        }

        /// <summary>
        /// テンプレート繰返し範囲を示す画像を更新します。
        /// </summary>
        /// <param name="aRangeStr"></param>
        // mod #10230 コピーした内容がリセットされる 高 start
        //private void UpdateTempleteAreaImage()
        public void UpdateTempleteAreaImage()
        // mod #10230 コピーした内容がリセットされる 高 end
        {
            System.Drawing.Image wImage = null;

            this.lblTmplDescription.Visible = true;
            this.picTmpl.Image = null;

            if (RldLib.CurrentLayoutData.DesignTempleteData != null && !String.IsNullOrEmpty(RldLib.CurrentLayoutData.DesignTempleteData.Range))
            {
                // セルの画像を取得
                using (var wXlRange = new ExcelRangeEx(RldLib.XlHelper.XlSheetLayout, RldLib.CurrentLayoutData.DesignTempleteData.Range))
				// add #10137 テンプレート設定されているとコピー領域が1回しかペーストできない limingzhe start
                {
                    RldLib.XlHelper.XlSheetLayout.Worksheet.Activate();
                    wImage = wXlRange.GetImage();
                }
                // add #10137 テンプレート設定されているとコピー領域が1回しかペーストできない limingzhe end    
            }

            if (wImage != null)
            {
                this.lblTmplDescription.Visible = false;
                this.picTmpl.Image = wImage;
                this.picTmpl.Refresh();
            }
        }

        /// <summary>
        /// テンプレート繰返し明細表示用グリッドの表示を更新します。
        /// </summary>
        private void UpdateDetailGrid(Boolean bEdit = false)
        {
            // 画面を一旦クリア
            this.DataClear(false);

            // テンプレート繰返しデータがない場合は抜ける
            if (RldLib.CurrentLayoutData.DesignTempleteData == null) return;
            // 範囲選択されていない場合は抜ける
            if (String.IsNullOrEmpty(RldLib.CurrentLayoutData.DesignTempleteData.Range)) return;

            // 明細表示するプロパティを取得(EoCを除外)
            var wProperties = DesignTempleteData.Properties.Where(ele => ele.Name != DesignTempleteData.GetPropertyName(DesignTempleteData.EnumDataIndex.EoC)).ToArray();

            try
            {
                this.dgvTmplDetail.SuspendLayout();

                //del #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 START
                //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG START
                //Boolean editTotal = false;
                //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG END
                //del #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 END

                // テンプレート繰返し明細表示用データグリッドビューの内容をリセット
                RldGridRCAttributeReflector.ApplyToRow(this.dgvTmplDetail, wProperties);

                for (int wRowIndex = 0; wRowIndex < this.dgvTmplDetail.RowCount; wRowIndex++)
                {

                    var wRow = this.dgvTmplDetail.Rows[wRowIndex];
                    var wValueCell = wRow.Cells[(Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.ItemValue];

                    String wKeyCellValue = wRow.Cells[(Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.Property].Value as String;

                    // 選択された行のデータを配置する
                    {
                        /// <summary>
                        /// プロパティ名が一致するか確認します。
                        /// </summary>
                        /// <param name="aIndex"></param>
                        Boolean wFuncIsEqualPropName(DesignTempleteData.EnumDataIndex aIndex) => wKeyCellValue == DesignTempleteData.GetPropertyName(aIndex);

                        /// <summary>
                        /// セルを読取専用に設定します。
                        /// </summary>
                        void wFuncSetCellReadOnly(Boolean aIsSetReadOnly) =>
                            RldDataGridViewStaticMethods.SetCellReadOnly(
                                this.dgvTmplDetail,
                                wRowIndex,
                                (Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.ItemValue,
                                aIsSetReadOnly);

                        // 範囲
                        if (wFuncIsEqualPropName(DesignTempleteData.EnumDataIndex.Range))
                        {
                            wValueCell.Value = RldLib.CurrentLayoutData.DesignTempleteData.Range;
                        }
                        // サイズ
                        else if (wFuncIsEqualPropName(DesignTempleteData.EnumDataIndex.Size))
                        {
                            wValueCell.Value = RldLib.CurrentLayoutData.DesignTempleteData.Size;
                        }
                        // 繰返回数(横)
                        else if (wFuncIsEqualPropName(DesignTempleteData.EnumDataIndex.RepeatCountV))
                        {
                            wValueCell.Value = RldLib.CurrentLayoutData.DesignTempleteData.RepeatCountV;
                            //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG START
                            if (newRepeatV != int.Parse(wValueCell.Value.ToString()))
                            {
                                newRepeatV = int.Parse(wValueCell.Value.ToString());
                                //del #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 START
                                //editTotal = true;
                                //del #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 END
                            }
                            //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG END
                        }
                        // 繰返回数(縦)
                        else if (wFuncIsEqualPropName(DesignTempleteData.EnumDataIndex.RepeatCountH))
                        {
                            wValueCell.Value = RldLib.CurrentLayoutData.DesignTempleteData.RepeatCountH;
                            //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG START
                            if (newRepeatH != int.Parse(wValueCell.Value.ToString()))
                            {
                                newRepeatH = int.Parse(wValueCell.Value.ToString());
                                //del #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 START
                                //editTotal = true;
                                //del #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 END
                            }
                            //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG END
                        }
                        // 余白(横)
                        else if (wFuncIsEqualPropName(DesignTempleteData.EnumDataIndex.MarginV))
                        {
                            wValueCell.Value = RldLib.CurrentLayoutData.DesignTempleteData.MarginV;
                            //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG START
                            if (newMarginV != int.Parse(wValueCell.Value.ToString()))
                            {
                                newMarginV = int.Parse(wValueCell.Value.ToString());
                                //del #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 START
                                //editTotal = true;
                                //del #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 END

                                //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG END
                            }
                        }
                        // 余白(縦)
                        else if (wFuncIsEqualPropName(DesignTempleteData.EnumDataIndex.MarginH))
                        {
                            wValueCell.Value = RldLib.CurrentLayoutData.DesignTempleteData.MarginH;
                            //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG START
                            if (newMarginH != int.Parse(wValueCell.Value.ToString()))
                            {
                                newMarginH = int.Parse(wValueCell.Value.ToString());
                                //del #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 START
                                //editTotal = true;
                                //del #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 END
                            }
                            //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG END
                        }
                        // 繰返方向
                        else if (wFuncIsEqualPropName(DesignTempleteData.EnumDataIndex.ComboBoxEditDirectionText))
                        {
                            DesignTempleteData.SetDirectionComboBoxItem(ref wValueCell);
                            wValueCell.Value = RldLib.CurrentLayoutData.DesignTempleteData.DirectionData;
                            wFuncSetCellReadOnly(!RldLib.CurrentLayoutData.DesignTempleteData.CanEditDirection);
                        }
                        // 改ページ
                        else if (wFuncIsEqualPropName(DesignTempleteData.EnumDataIndex.IsNewPage))
                        {
                            wValueCell.Value = RldLib.CurrentLayoutData.DesignTempleteData.IsNewPage;
                            wFuncSetCellReadOnly(!RldLib.CurrentLayoutData.DesignTempleteData.CanEditNewPage);
                        }
                        // 繰返しモード
                        else if (wFuncIsEqualPropName(DesignTempleteData.EnumDataIndex.ComboBoxEditRepeatModeText))
                        {
                            DesignTempleteData.SetRepeatModeComboBoxItem(ref wValueCell);
                            wValueCell.Value = RldLib.CurrentLayoutData.DesignTempleteData.RepeatMode;

                            var wCanEditRepeatMode = RldLib.CurrentLayoutData.DesignTempleteData.CanEditRepeatMode;
                            if (RldLib.CurrentLayoutData.DesignSettingData.ReportClass == RldConst.ReportTypeData.VAL_TYPE_ONE_PATIENT ||
                                RldLib.CurrentLayoutData.DesignSettingData.ReportClass == RldConst.ReportTypeData.VAL_TYPE_MULTI_PATIENT ||
                                // add #11226 患者情報系historyの取得条件見直し② 高 start
                                (RldLib.CurrentLayoutData.DesignSettingData.ReportClass == RldConst.ReportTypeData.VAL_TYPE_REFERRAL_LETTER && "2".Equals(RldLib.totalLayoutData.ReportType)))
                                // add #11226 患者情報系historyの取得条件見直し② 高 end
                                wCanEditRepeatMode = true;
                            wFuncSetCellReadOnly(!wCanEditRepeatMode);
                        }
                        //add #8763 zhu start
                        // 繰り返しキーkey
                        else if (wFuncIsEqualPropName(DesignTempleteData.EnumDataIndex.ComboBoxEditRepeatNo))
                        {
                            DesignTempleteData.SetRepeatNoComboBoxItem(ref wValueCell);
                            wValueCell.Value = RldLib.CurrentLayoutData.DesignTempleteData.RepeatNo;

                            var wCanEditRepeatNo = RldLib.CurrentLayoutData.DesignTempleteData.CanEditRepeatNo;
                            if (RldLib.CurrentLayoutData.DesignSettingData.ReportClass == RldConst.ReportTypeData.VAL_TYPE_ONE_PATIENT ||
                                RldLib.CurrentLayoutData.DesignSettingData.ReportClass == RldConst.ReportTypeData.VAL_TYPE_MULTI_PATIENT)
                                wCanEditRepeatNo = true;
                            wFuncSetCellReadOnly(!wCanEditRepeatNo);
                        }
                        //add #8763 zhu end
                    }

                    // 読取専用のセルの前景色を変更
                    {
                        if (wRow.Cells[(Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.ItemValue].ReadOnly)
                        {
                            wRow.Cells[(Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.ItemName].Style.ForeColor = System.Drawing.Color.DarkGray;
                            wValueCell.Style.ForeColor = System.Drawing.Color.DarkGray;
                        }
                    }
                    //del #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 START
                    //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG START
                    /*if (editTotal == true || bEdit == true)
                    {
                        this.syncStyle(bEdit);
                    }*/
                    //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG END
                    //del #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 END
                }
            }
            catch
            {
                throw;
            }
            finally
            {
                this.dgvTmplDetail.ResumeLayout();
            }
        }

        /// <summary>
        /// 通知用イベントを発行します。
        /// </summary>
        /// <param name="e"></param>
        protected virtual void SendNotifyInfo(RldDesignNotifyInfoEventArgs e) => this.NotifyInfo?.Invoke(this, e);

        #endregion

        #region メンバ関数定義(Mediator)

        /// <summary>
        /// Mediator からのイベントを受信します。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        public void ReceiveNotifyInfo(Object sender, RldDesignNotifyInfoEventArgs e)
        {
            //switch( e.InfoType ) {
            //    case RldDesignNotifyInfoEventArgs.EnumInfoType.NotifyDragDropStatusChanged:
            //        // ドラッグアンドドロップ状態変更通知受信
            //        this.ActionOfDragDropStatusChanged(sender, (RldDesignNotifyInfoNotifyDragDropStatusChangedEventArgs)e);
            //        break;

            //    case RldDesignNotifyInfoEventArgs.EnumInfoType.NotifyDragDropCompleted:
            //        // ドラッグアンドドロップ操作完了通知受信
            //        this.ActionOfDragDropCompleted(sender, (RldDesignNotifyInfoNotifyDragDropCompletedEventArgs)e);
            //        break;

            //    case RldDesignNotifyInfoEventArgs.EnumInfoType.RequestSaveDropFile:
            //        // ファイル保存/破棄要求受信
            //        this.ActionOfSaveDropFile(sender, (RldDesignNotifyInfoRequestSaveDropFileEventArgs)e);
            //        break;

            //    default:
            //        break;
            //}
        }

        #endregion

        #region コントロールイベントハンドラ定義

        /// <summary>
        /// 初期化ボタンの Click イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnTmplClear_Click(object sender, EventArgs e)
        {
            // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 start
            if (RldLib.chkExeclDialog(2) == false)
                return;
            // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 end

            this.DataClear(true);

            // テンプレート繰返しデータがない場合は抜ける
            if (RldLib.CurrentLayoutData.DesignSettingData.HasTemplete == RldConst.SettingData.VAL_HAS_TEMPLETE_NO) return;

            // テンプレート繰返しデータを削除する
            RldLib.CurrentLayoutData.DesignSettingData.HasTemplete = RldConst.SettingData.VAL_HAS_TEMPLETE_NO;
            RldLib.CurrentLayoutData.DesignTempleteData = null;
            // add #8314 グループタブの表示不正 王占宇 start
            DesignParamDatasList designParamDatasList = new DesignParamDatasList();
            // add #8314 グループタブの表示不正 王占宇 end
            // パラメータ編集データのテンプレート内外状態を更新
            for (int i = 0; i < RldLib.CurrentLayoutData.DesignParamList.Count; i++)
            {
                // パラメータリストのループ

                var wData = RldLib.CurrentLayoutData.DesignParamList[i];

                // テンプレート内外状態を外に更新
                // mod #8314 グループタブの表示不正 王占宇 start
                // wData.IsInTemplete = RldConst.ParamData.VAL_IS_IN_TEMPLETE_OUT;
                wData.IsInTemplete = RldConst.ParamData.VAL_IS_IN_TEMPLETE_NONE;
                // mod #8314 グループタブの表示不正 王占宇 end

                // 指定されたインデックスのパラメータ編集データを更新します

                // del #8314 グループタブの表示不正 王占宇 start
                // if (RldLib.CurrentLayoutData.SetDesignParamData(wData, i) == false)
                // {
                //     break;
                // }
                // del #8314 グループタブの表示不正 王占宇 end

                // add #8314 グループタブの表示不正 王占宇 start
                designParamDatasList.Add(wData);
                // add #8314 グループタブの表示不正 王占宇 end

            }

            // add #8314 グループタブの表示不正 王占宇 start
            FilterDesignGroupData();
            for (int j = 0; j < designParamDatasList.Count; j++)
            {
                var wData = designParamDatasList[j];
                if (RldLib.CurrentLayoutData.SetDesignParamData(wData, j) == false)
                {
                    break;
                }
            }
            // add #8314 グループタブの表示不正 王占宇 end

            // add #10230 コピーした内容がリセットされる 高 start
            // 画像を更新
            this.UpdateTempleteAreaImage();
            // add #10230 コピーした内容がリセットされる 高 end

        }

        // add #8314 グループタブの表示不正 王占宇 start
        private void FilterDesignGroupData()
        {
            List<DesignGroupData> tempList = RldLib.XlHelper.GetSheetGroupDataList().ToList();
            List<DesignGroupData> addTempList = new List<DesignGroupData>();
            for (int i = 0; i < tempList.Count; i++)
            {
                var wData = tempList[i];
                wData.IsInTemplete = RldConst.ParamData.VAL_IS_IN_TEMPLETE_NONE;
                addTempList.Add(wData);
            }
            try
            {
                var newList = addTempList.GroupBy(p => new { p.GroupName, p.IsInTemplete });
                List<DesignGroupData> newAddTempList = new List<DesignGroupData>();
                foreach (var item in newList)
                {
                    newAddTempList.Add(item.ToList()[0]);
                }
                // グループシート読み込み
                List<DesignGroupData> itemList = new List<DesignGroupData>();
                itemList = RldLib.CurrentLayoutData.DesignGroupList.ToList();
                itemList.ForEach(p => RldLib.CurrentLayoutData.DesignGroupList.Remove(p));
                newAddTempList.ForEach(ele => RldLib.CurrentLayoutData.DesignGroupList.Add(ele));
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex, false);
            }
        }
        // add #8314 グループタブの表示不正 王占宇 end

        /// <summary>
        /// 選択セルを範囲に設定ボタンの Click イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnTmplSelect_Click(object sender, EventArgs e)
        {
            // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 start
            if (RldLib.chkExeclDialog(2) == false)
                return;
            // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 end

            this.UpdateTempleteAreaData();
            // add #10230 コピーした内容がリセットされる 高 start
            this.UpdateTempleteAreaImage();
            // add #10230 コピーした内容がリセットされる 高 end
        }

        /// <summary>
        /// ドラッグアンドドロップ受付用パネルの DragDrop イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void pnlTmplDrop_DragDrop(object sender, DragEventArgs e)
        {
            if (e.Data.GetDataPresent("SymbolicLink"))
            // mod #10230 コピーした内容がリセットされる 高 start
            {
                this.UpdateTempleteAreaData();
                this.UpdateTempleteAreaImage();
                
            }
            // mod #10230 コピーした内容がリセットされる 高 end
        }

        /// <summary>
        /// ドラッグアンドドロップ受付用パネルの DragEnter イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void pnlTmplDrop_DragEnter(object sender, DragEventArgs e)
        {
            if (e.Data.GetDataPresent("SymbolicLink"))
                e.Effect = DragDropEffects.Copy;
        }

        /// <summary>
        /// テンプレート繰返し明細表示用 DataGridView の CellClick イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvTmplDetail_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            // ヘッダのクリック時は抜ける
            if (e.RowIndex < 0 || e.ColumnIndex < 0) return;

            try
            {
                // クリックしたセルを取得
                var wCell = this.dgvTmplDetail[e.ColumnIndex, e.RowIndex];

                // クリックしたセルがコンボボックスセルの場合はシングルクリックでドロップダウンさせる
                if (wCell is DataGridViewComboBoxCell wComboBoxCell)
                {

                    // 編集モードに変更
                    this.dgvTmplDetail.BeginEdit(true);

                    // 編集コントロールを取得してドロップダウンさせる
                    if (this.dgvTmplDetail.EditingControl is DataGridViewComboBoxEditingControl wEditingCtrl)
                    {
                        wEditingCtrl.DroppedDown = true;
                    }
                }
            }
            catch (Exception ex)
            {
                this.SendNotifyInfo(new RldDesignNotifyInfoRequestRecordExceptionEventArgs(ex, true));
            }
        }

        /// <summary>
        /// テンプレート繰返し明細表示用 DataGridViewの CellEndEdit イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvTmplDetail_CellEndEdit(object sender, DataGridViewCellEventArgs e)
        {
            try
            {
                // 編集を行った行のプロパティ名を取得
                String wPropName = this.dgvTmplDetail[(Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.Property, e.RowIndex].Value as String;
                String wValue = this.dgvTmplDetail[(Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.ItemValue, e.RowIndex].Value as String;

                // プロパティ名チェック用
                Boolean wFuncIsEqualPropName(DesignTempleteData.EnumDataIndex aIndex) =>
                    wPropName == DesignTempleteData.GetPropertyName(aIndex);

                // 繰返し回数(横)
                if (wFuncIsEqualPropName(DesignTempleteData.EnumDataIndex.RepeatCountV))
                {
                    Int32 wConvValue = RldLib.ConvertStrToInt32(wValue, false);
                    if (wConvValue < 1) wConvValue = 1;    // 最低回数は1回
                    //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG START
                    if (cellEdit == true && newRepeatV != wConvValue)
                    {
                        newRepeatV = wConvValue;
                        meditTotal = true;
                    }
                    //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG END

                    RldLib.CurrentLayoutData.DesignTempleteData.RepeatCountV = wConvValue.ToString();
                    this.dgvTmplDetail[(Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.ItemValue, e.RowIndex].Value = wConvValue.ToString();
                }
                // 繰返し回数(縦)
                else if (wFuncIsEqualPropName(DesignTempleteData.EnumDataIndex.RepeatCountH))
                {
                    Int32 wConvValue = RldLib.ConvertStrToInt32(wValue, false);
                    if (wConvValue < 1) wConvValue = 1;    // 最低回数は1回
                    //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG START
                    if (cellEdit == true && newRepeatH != wConvValue)
                    {
                        newRepeatH = wConvValue;
                        meditTotal = true;
                    }
                    //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG END

                    RldLib.CurrentLayoutData.DesignTempleteData.RepeatCountH = wConvValue.ToString();
                    this.dgvTmplDetail[(Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.ItemValue, e.RowIndex].Value = wConvValue.ToString();
                }
                // 余白(横)
                else if (wFuncIsEqualPropName(DesignTempleteData.EnumDataIndex.MarginV))
                {
                    String wConvValue = Convert.ToString(RldLib.ConvertStrToInt32(wValue, false));
                    RldLib.CurrentLayoutData.DesignTempleteData.MarginV = wConvValue;
                    this.dgvTmplDetail[(Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.ItemValue, e.RowIndex].Value = wConvValue;
                    //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG START
                    if (cellEdit == true && newMarginV != RldLib.ConvertStrToInt32(wValue, false))
                    {
                        newMarginV = RldLib.ConvertStrToInt32(wValue, false);
                        meditTotal = true;
                    }
                    //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG END
                }
                // 余白(縦)
                else if (wFuncIsEqualPropName(DesignTempleteData.EnumDataIndex.MarginH))
                {
                    String wConvValue = Convert.ToString(RldLib.ConvertStrToInt32(wValue, false));
                    RldLib.CurrentLayoutData.DesignTempleteData.MarginH = wConvValue;
                    this.dgvTmplDetail[(Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.ItemValue, e.RowIndex].Value = wConvValue;
                    //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG START
                    if (cellEdit == true && newMarginH != RldLib.ConvertStrToInt32(wValue, false))
                    {
                        newMarginH = RldLib.ConvertStrToInt32(wValue, false);
                        meditTotal = true;
                    }
                    //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG END
                }
                // 繰返し方向
                else if (wFuncIsEqualPropName(DesignTempleteData.EnumDataIndex.ComboBoxEditDirectionText))
                {
                    RldLib.CurrentLayoutData.DesignTempleteData.DirectionData = wValue;
                }
                // 改ページ
                else if (wFuncIsEqualPropName(DesignTempleteData.EnumDataIndex.IsNewPage))
                {
                    RldLib.CurrentLayoutData.DesignTempleteData.IsNewPage = wValue;
                }
                // 繰返しモード
                else if (wFuncIsEqualPropName(DesignTempleteData.EnumDataIndex.ComboBoxEditRepeatModeText))
                {
                    RldLib.CurrentLayoutData.DesignTempleteData.RepeatMode = wValue;
                }
                //add #8763 zhu start
                // 繰り返しキー
                else if (wFuncIsEqualPropName(DesignTempleteData.EnumDataIndex.ComboBoxEditRepeatNo))
                {
                    RldLib.CurrentLayoutData.DesignTempleteData.RepeatNo = wValue;
                }
                //add #8763 zhu end
                //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG START
                /* if (editTotal == true)
                 {
                     this.syncStyle();
                 }*/
                //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG END
            }
            catch (Exception ex)
            {
                this.SendNotifyInfo(new RldDesignNotifyInfoRequestRecordExceptionEventArgs(ex, true));
            }
        }

        private void dgvTmplDetail_CellValidating(object sender, DataGridViewCellValidatingEventArgs e)
        {

            try
            {
                // 入力チェック
                if ((e.ColumnIndex == 2) && ((e.RowIndex == 2) || (e.RowIndex == 3) || (e.RowIndex == 4) || (e.RowIndex == 5)) &&
                    ((int.TryParse(e.FormattedValue.ToString(), out int result) == false) || (result < 0)))
                {
                    // 繰返(縦), 繰返(横), 余白(縦), 余白(横)
                    // 数値に変換できない または マイナス値
                    e.Cancel = true;
                }
            }
            catch (Exception ex)
            {
                LayoutDesignerUtilityLib.LayoutDesignerUtility.RecordException(this, ex, true);
            }

        }

        /// <summary>
        /// テンプレート繰返し明細表示用 DataGridViewの CurrentCellDirtyStateChanged イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvTmplDetail_CurrentCellDirtyStateChanged(Object sender, System.EventArgs e)
        {
            var wDataGridView = sender as DataGridView;

            if (wDataGridView.IsCurrentCellDirty)
            {
                // チェックボックスセルの場合は編集を確定させる
                if (wDataGridView.CurrentCell is DataGridViewCheckBoxCell wCheckBoxCell)
                {
                    wDataGridView.EndEdit();
                }
                // コンボボックスセルの場合は編集を確定させる
                else if (wDataGridView.CurrentCell is DataGridViewComboBoxCell wComboBoxCell)
                {
                    wDataGridView.EndEdit();
                }
                // add #6788 デグレ：繰返回数の編集内容が保存されない 歴程 start
                // テキストボックスセルの場合は編集を確定させる
                else if (wDataGridView.CurrentCell is DataGridViewTextBoxCell wTextBoxCell)
                {
                    wDataGridView.EndEdit();
                    // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 start
                    this.dgvTmplDetail.BeginEdit(false);
                    // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 end
                }
                // add #6788 デグレ：繰返回数の編集内容が保存されない 歴程 end
                cellEdit = false;
                // add 8394 動作に関する指摘 吉 start
                dgvTmplDetail_CellEndEdit(sender, new DataGridViewCellEventArgs(this.dgvTmplDetail.CurrentCell.ColumnIndex, this.dgvTmplDetail.CurrentCell.RowIndex));
                // add 8394 動作に関する指摘 吉 end
                cellEdit = true;
            }
        }

        #endregion

        // add #7943 帳票レイアウトデザイナーが正しく動作しないの対応 夏 start
        private void dgvTmplDetail_DataError(object sender, DataGridViewDataErrorEventArgs e)
        {
            e.Cancel = true;
        }
        // add #7943 帳票レイアウトデザイナーが正しく動作しないの対応 夏 end

        // del #9816 テンプレート設定に関する処理がデザイナと帳票生成時で重複している limingzhe start
        //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG START
        //public void syncStyle(Boolean bEdit = true)
        //{
        //    // add #10448 【デグレ】FNW帳票取込み後のオンライン保存で動作異常 limingzhe start
        //    return;
        //    // add #10448 【デグレ】FNW帳票取込み後のオンライン保存で動作異常 limingzhe end
        //    // add #9816 テンプレート設定に関する処理がデザイナと帳票生成時で重複している 高 start
        //    // !=  帳票種別[単一集計] and != 帳票種別[複数患者帳票] and != 帳票種別[複数集計]
        //    if (RldLib.CurrentLayoutData.DesignSettingData.ReportClass != RldConst.ReportTypeData.VAL_TYPE_ONE_TOTAL
        //        && RldLib.CurrentLayoutData.DesignSettingData.ReportClass != RldConst.ReportTypeData.VAL_TYPE_MULTI_PATIENT
        //        && RldLib.CurrentLayoutData.DesignSettingData.ReportClass != RldConst.ReportTypeData.VAL_TYPE_MULTI_TOTAL)
        //    // add #9816 テンプレート設定に関する処理がデザイナと帳票生成時で重複している 高 end
        //    {
        //        if (cellEdit == false)
        //        {
        //            meditTotal = false;
        //            return;
        //        }
        //    }
        //    // add #9816 テンプレート設定に関する処理がデザイナと帳票生成時で重複している donghao start
        //    if (RldLib.CurrentLayoutData.DesignSettingData.ReportClass == RldConst.ReportTypeData.VAL_TYPE_ONE_PATIENT || RldLib.CurrentLayoutData.DesignSettingData.ReportClass == RldConst.ReportTypeData.VAL_TYPE_LABEL)
        //    {
        //        return;
        //    }
        //    // add #9816 テンプレート設定に関する処理がデザイナと帳票生成時で重複している donghao end
        //    //del #9648 【デグレ】オンライン保存の実行中Excelのウインドウがグレーで潰れる dongzhaolong start
        //    //add #9878 【デグレ】Excelの編集欄が更新されないときがある dongzhaolong start
        //    RldLib.XlHelper.XlApp.Application.ScreenUpdating = false;
        //    RldLib.XlHelper.IsHandleLayoutSheetEvent = false;
        //    //add #9878 【デグレ】Excelの編集欄が更新されないときがある dongzhaolong end
        //    //del #9648 【デグレ】オンライン保存の実行中Excelのウインドウがグレーで潰れる dongzhaolong en
        //    //del #9602 デグレ】フィルタ設定に関する不具合2点 dongzhaolong start
        //    //add #9196 オンライン保存すると例外発生することがある dongzhaolong start
        //    //RldLib.XlHelper.XlSheetLayout.IsProtected = false;
        //    //add #9196 オンライン保存すると例外発生することがある dongzhaolong end
        //    //del #9602 デグレ】フィルタ設定に関する不具合2点 dongzhaolong end

        //    //del #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONG START
        //    /*Form formzd = new Form();
        //    int width = Screen.PrimaryScreen.Bounds.Width;
        //    int height = Screen.PrimaryScreen.Bounds.Height;
        //    formzd.ControlBox = false;
        //    formzd.FormBorderStyle = FormBorderStyle.FixedSingle;
        //    formzd.Opacity = 0.5;
        //    formzd.ShowInTaskbar = false;
        //    formzd.StartPosition = FormStartPosition.CenterScreen;
        //    formzd.Size = new Size(width, height);
        //    formzd.BackColor = Color.LightGray;
        //    formzd.Show();
        //    LoadingHelper.ShowLoadingDialog();*/
        //    //del #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONG END

        //    try
        //    {

        //        /* if (bEdit == false)
        //         {
        //             return;
        //         }*/

        //        // add #9816 テンプレート設定に関する処理がデザイナと帳票生成時で重複している 高 start
        //        if(RldLib.CurrentLayoutData.DesignTempleteData == null)
        //        {
        //            return;
        //        }
        //        // add #9816 テンプレート設定に関する処理がデザイナと帳票生成時で重複している 高 end

        //        //RldLib.CurrentLayoutData.DesignTempleteData
        //        var cellList = RldLib.CurrentLayoutData.DesignTempleteData.Range.Split(':');
        //        // add #9816 テンプレート設定に関する処理がデザイナと帳票生成時で重複している 高 start
        //        if (cellList == null || "".Equals(cellList))
        //        {
        //            return;
        //        }
        //        if(cellList[0] == null || "".Equals(cellList[0]))
        //        {
        //            return;
        //        }
        //        if (cellList.Length > 1)
        //        {
        //            if (cellList[1] == null || "".Equals(cellList[1]))
        //            {
        //                return;
        //            }

        //        }
        //        // add #9816 テンプレート設定に関する処理がデザイナと帳票生成時で重複している 高 end
        //        Microsoft.Office.Interop.Excel.Range currentRange = RldLib.XlHelper.XlSheetLayout.Worksheet.get_Range(cellList[0]);
        //        Microsoft.Office.Interop.Excel.Range copyRange = null;
        //        Boolean bMerged = currentRange.MergeCells;
        //        if (cellList.Length > 1)
        //        {
        //            copyRange = RldLib.XlHelper.XlSheetLayout.Worksheet.get_Range(cellList[0], cellList[1]);
        //        }
        //        else
        //        {
        //            copyRange = currentRange;
        //        }

        //        int firstRow = currentRange.Row;
        //        int firstColumn = currentRange.Column;
        //        int rangeRow = RldLib.CurrentLayoutData.DesignTempleteData.RowCount;
        //        int rangeColumn = RldLib.CurrentLayoutData.DesignTempleteData.ColumnCount;

        //        //add #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董昊 START
        //        if (newRepeatV > oldRepeatV)
        //        {
        //            oldRepeatV = newRepeatV;
        //        }
        //        if (newRepeatH > oldRepeatH)
        //        {
        //            oldRepeatH = newRepeatH;
        //        }
        //        //add #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董昊 END

        //        for (int i = 0; i < oldRepeatV * rangeRow + (oldRepeatV - 1) * oldMarginV; i++)
        //        {
        //            for (int j = 0; j < oldRepeatH * rangeColumn + (oldRepeatH - 1) * oldMarginH; j++)
        //            {
        //                if ((firstColumn + j) >= firstColumn + rangeColumn || (firstRow + i) >= firstRow + rangeRow)
        //                {
        //                    string currentAddress = GetExcelCol(firstColumn + j - 1) + (firstRow + i).ToString();
        //                    Microsoft.Office.Interop.Excel.Range Range = RldLib.XlHelper.XlSheetLayout.Worksheet.get_Range(currentAddress);
        //                    if (Range.MergeCells == true)
        //                    {
        //                        Range.UnMerge();
        //                    }
        //                    //Range.Clear();
        //                }
        //            }
        //        }

        //        /*if (bMerged == true)
        //        {
        //            for (int i = 0; i < newRepeatV; i++)
        //            {
        //                for (int j = 0; j < newRepeatH; j++)
        //                {
        //                    if (i != 0 || j != 0)
        //                    {
        //                        string firstAddress = GetExcelCol(firstColumn + j * mergeColumn - 1 + j * newMarginH) + (firstRow + i * mergeRow + i * newMarginV).ToString();
        //                        string lastAddress = GetExcelCol(firstColumn + (j + 1) * mergeColumn - 1 + (j + 1) * newMarginH - 1) + (firstRow + (i + 1) * mergeRow + (i + 1) * newMarginV - 1).ToString();
        //                        Microsoft.Office.Interop.Excel.Range mergeRange = RldLib.XlHelper.XlSheetLayout.Worksheet.get_Range(firstAddress, lastAddress);
        //                        mergeRange.Clear();
        //                        currentRange.Copy(Type.Missing);
        //                        RldLib.XlHelper.XlSheetLayout.Worksheet.Range[firstAddress].PasteSpecial(Microsoft.Office.Interop.Excel.XlPasteType.xlPasteAllExceptBorders, Microsoft.Office.Interop.Excel.XlPasteSpecialOperation.xlPasteSpecialOperationNone, System.Type.Missing, System.Type.Missing);
        //                        RldLib.XlHelper.XlSheetLayout.Worksheet.Range[firstAddress].Cells.Value = "";
        //                        mergeRange.Merge();
        //                    }
        //                }
        //            }
        //        }*/
        //        //else
        //        //{
        //        for (int i = 0; i < newRepeatV; i++)
        //        {
        //            for (int j = 0; j < newRepeatH; j++)
        //            {
        //                if (i != 0 || j != 0)
        //                {
        //                    string firstAddress = GetExcelCol(firstColumn + j * rangeColumn - 1 + j * newMarginH) + (firstRow + i * rangeRow + i * newMarginV).ToString();
        //                    //string lastAddress = GetExcelCol(firstColumn + j * rangeColumn - 1 + j * newMarginH + rangeColumn) + (firstRow + i * rangeRow + i * newMarginV + rangeRow).ToString();
        //                    copyRange.Copy(Type.Missing);
        //                    // mod #9816 テンプレート設定に関する処理がデザイナと帳票生成時で重複している 高 start
        //                    //RldLib.XlHelper.XlSheetLayout.Worksheet.Range[firstAddress].PasteSpecial(Microsoft.Office.Interop.Excel.XlPasteType.xlPasteAllExceptBorders, Microsoft.Office.Interop.Excel.XlPasteSpecialOperation.xlPasteSpecialOperationNone, System.Type.Missing, System.Type.Missing);
        //                    RldLib.XlHelper.XlSheetLayout.Worksheet.Range[firstAddress].PasteSpecial(Microsoft.Office.Interop.Excel.XlPasteType.xlPasteFormats);
        //                    RldLib.XlHelper.XlSheetLayout.Worksheet.Range[firstAddress].PasteSpecial(Microsoft.Office.Interop.Excel.XlPasteType.xlPasteValuesAndNumberFormats);
        //                    // mod #9816 テンプレート設定に関する処理がデザイナと帳票生成時で重複している 高 end
        //                    //RldLib.XlHelper.XlSheetLayout.Worksheet.Range[firstAddress].Cells.Value = "";

        //                    /* if (bMerged == true)
        //                     {
        //                         RldLib.XlHelper.XlSheetLayout.Worksheet.Range[firstAddress].Merge();
        //                     }*/
        //                }
        //            }
        //        }
        //        // }


        //        for (int i = 0; i < newRepeatV * rangeRow + (newRepeatV - 1) * newMarginV; i++)
        //        {
        //            for (int j = 0; j < newRepeatH * rangeColumn + (newRepeatH - 1) * newMarginH; j++)
        //            {
        //                if ((firstColumn + j) >= firstColumn + rangeColumn || (firstRow + i) >= firstRow + rangeRow)
        //                {
        //                    string currentAddress = GetExcelCol(firstColumn + j - 1) + (firstRow + i).ToString();
        //                    Microsoft.Office.Interop.Excel.Range Range = RldLib.XlHelper.XlSheetLayout.Worksheet.get_Range(currentAddress);

        //                    //mod #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董昊 START
        //                    /*if (!string.IsNullOrEmpty((string)Range.Value) && Convert.ToString(Range.Value).StartsWith("##"))
        //                    {
        //                        Range.Cells.Value = "";
        //                    }*/

        //                    Range.Cells.Value = "";
        //                    //mod #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董昊 END
        //                    //add #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董昊 START
        //                    Range.Interior.Pattern = Microsoft.Office.Interop.Excel.Constants.xlNone;
        //                    Range.Interior.TintAndShade = 0;
        //                    Range.Interior.PatternTintAndShade = 0;
        //                    //add #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董昊 START
        //                }
        //            }
        //        }

        //        oldRepeatH = newRepeatH;
        //        oldRepeatV = newRepeatV;
        //        oldMarginH = newMarginH;
        //        oldMarginV = newMarginV;
        //        currentRange.Select();
        //    }
        //    catch (Exception)
        //    {
        //        throw;
        //    }
        //    finally
        //    {
        //        //del #9648 【デグレ】オンライン保存の実行中Excelのウインドウがグレーで潰れる dongzhaolong start
        //        //add #9878 【デグレ】Excelの編集欄が更新されないときがある dongzhaolong start
        //        RldLib.XlHelper.IsHandleLayoutSheetEvent = true;
        //        RldLib.XlHelper.XlApp.Application.ScreenUpdating = true;
        //        //add #9878 【デグレ】Excelの編集欄が更新されないときがある dongzhaolong end
        //        //LoadingHelper.CloseLoadingDialog();
        //        //del #9648 【デグレ】オンライン保存の実行中Excelのウインドウがグレーで潰れる dongzhaolong end
        //        //del #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONG START
        //        //formzd.Close();
        //        //del #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONG END
        //        //del #9602 デグレ】フィルタ設定に関する不具合2点 dongzhaolong start
        //        //add #9196 オンライン保存すると例外発生することがある dongzhaolong start
        //        //RldLib.XlHelper.XlSheetLayout.IsProtected = true;
        //        //add #9196 オンライン保存すると例外発生することがある dongzhaolong end
        //        //del #9602 デグレ】フィルタ設定に関する不具合2点 dongzhaolong end
        //        cellEdit = false;
        //    }

        //}
        // del #9816 テンプレート設定に関する処理がデザイナと帳票生成時で重複している limingzhe end

        private static string GetExcelCol(int colIndex)
        {
            //int转string，如0转换成string=A
            var major = colIndex / 26;
            var minor = colIndex % 26;
            var last = ((char)(minor + 'A')).ToString();
            if (major > 0)
                return GetExcelCol(major - 1) + last;
            return last;
        }

        // add #10230 コピーした内容がリセットされる 高 start
        private void btnTmplUpdate_Click(object sender, EventArgs e)
        {
            // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 start
            if (RldLib.chkExeclDialog(2) == false)
                return;
            // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 end

            // 画像を更新
            this.UpdateTempleteAreaImage();
        }

        private void picTmpl_Click(object sender, EventArgs e)
        {
            this.btnTmplUpdate_Click(sender, e);
        }
        // add #10230 コピーした内容がリセットされる 高 end
        //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG END
    }
}
