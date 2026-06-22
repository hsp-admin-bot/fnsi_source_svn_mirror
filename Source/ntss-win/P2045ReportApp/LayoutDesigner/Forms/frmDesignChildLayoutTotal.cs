using LayoutDesigner.Data;
using NKKWebAccessLib;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
// add 単一集計帳票／複数集計帳票：帳票分類コンボボックスの追加 鄧シン  start
using System.Web.Script.Serialization;
// add 単一集計帳票／複数集計帳票：帳票分類コンボボックスの追加 鄧シン  end
using System.Windows.Forms;
using RldUtility = LayoutDesignerUtilityLib.LayoutDesignerUtility;
//ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG START
using LayoutDesigner.Helpers;
//ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG END

namespace LayoutDesigner
{
    /// <summary>
    /// デザイナーウィンドウ内テンプレート繰返し編集画面
    /// </summary>
    public partial class frmDesignChildLayoutTotal : LayoutDesignerUtilityLib.Controls.frmRldBase, IRldDesignRecvOnlyColleague, IRldDesignSendOnlyColleague
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

        private DesignConvertList ConvertList = new DesignConvertList();

        //mod #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 START
        //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG START
        private static int oldRepeatH { get; set; } = 1;
        private static int oldRepeatV { get; set; } = 1;
        private int newRepeatH { get; set; } = 1;
        private int newRepeatV { get; set; } = 1;
        public Boolean medit { get; set; } = false;
        private static Boolean cellEdit { get; set; } = false;
        //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG END
        //mod #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 END

        // add 単一集計帳票／複数集計帳票：帳票分類コンボボックスの追加 鄧シン  start
        List<ReportType> reportType = new List<ReportType>();
        // add 単一集計帳票／複数集計帳票：帳票分類コンボボックスの追加 鄧シン  end

        //add #9484 因島帳票の表示不具合（帳票種別：紹介状）dongzhaolong start
        // mod #9816 テンプレート設定に関する処理がデザイナと帳票生成時で重複している donghao start
        //private static string totalTotal = string.Empty;
        public static string totalTotal = string.Empty;
        // mod #9816 テンプレート設定に関する処理がデザイナと帳票生成時で重複している donghao end
        //add #9484 因島帳票の表示不具合（帳票種別：紹介状）dongzhaolong end

        // add #12274 集計使用項目と同じグループ名を禁止するエラーの頻度が高くなりすぎる 高 start
        private const string GROUP_NAME_UNIT = "集計単位";
        // add #12274 集計使用項目と同じグループ名を禁止するエラーの頻度が高くなりすぎる 高 end
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
        public frmDesignChildLayoutTotal()
        {
            InitializeComponent();
            // add #11106 集計帳票で集計範囲外のグループ項目が出力されない 高 start
            totalTotal = string.Empty;
            // add #11106 集計帳票で集計範囲外のグループ項目が出力されない 高 end

            this.pnlBottom.Height = 0;

            // mod UT帳票No.136 二次元帳票再編集の場合、横の単位表示不正の対応 夏 start
            //foreach (var wData in RldLib.CurrentLayoutData.DesignParamList)
            //{
            //    if (wData.DataCode.Equals(RldLib.totalLayoutData.UnitV))
            //    {
            //        txtTotalUnitV.Text = wData.DataPath;
            //    }
            //}

            string strTmp = "";
            //add #12311 複数集計で患者毎の汎用的な集計を作成できない 高 start
            Dictionary<string, string> unitDic = new Dictionary<string, string>();
            //add #12311 複数集計で患者毎の汎用的な集計を作成できない 高 end
            List<string> totalUnitVList = new List<string>(RldLib.totalLayoutData.UnitV.Split(','));
            // add #11294 紹介状で集計部分がずれて出力される 高 start
            List<String> retTotalUnitH = null;      // 縦の単位
            List<String> retTotalUnitV = null;      // 横の単位

            // 横の単位
            if (string.IsNullOrEmpty(RldLib.totalLayoutData.UnitVAddress) == false)
            {
                retTotalUnitV = new List<string>(RldLib.totalLayoutData.UnitVAddress.Trim().Split(','));
            }
            // 縦の単位
            if (string.IsNullOrEmpty(RldLib.totalLayoutData.UnitHAddress) == false)
            {
                retTotalUnitH = new List<string>(RldLib.totalLayoutData.UnitHAddress.Trim().Split(','));
            }
            // add #11294 紹介状で集計部分がずれて出力される 高 end
            foreach (var wList in totalUnitVList)
            {
                foreach (var wData in RldLib.CurrentLayoutData.DesignParamList)
                {
                    // mod #10858 「##=[##データ項目」」の形式で null が出力される 高 start
                    // if (wData.DataCode.Equals(wList))
                    //mod #12311 複数集計で患者毎の汎用的な集計を作成できない 高 start
                    //if (wData.DataCode.Equals(wList) && !string.IsNullOrEmpty(wList))
                    if (wData.DataCode.Equals(wList) && wList != null)
                    //mod #12311 複数集計で患者毎の汎用的な集計を作成できない 高 end
                    // mod #10858 「##=[##データ項目」」の形式で null が出力される 高 end
                    {
                        // add #11294 紹介状で集計部分がずれて出力される 高 start
                        // 横の単位
                        if (retTotalUnitV != null && retTotalUnitV.Contains(wData.CellAddress) == true)
                        {
                        // add #11294 紹介状で集計部分がずれて出力される 高 end
                            //mod #12311 複数集計で患者毎の汎用的な集計を作成できない 高 start
                            //if (strTmp == "")
                            //{
                            //    strTmp = wData.DataPath;
                            //}
                            //else
                            //{
                            //    strTmp = string.Format("{0},{1}", strTmp, wData.DataPath);
                            //}
                            if (unitDic.ContainsKey(wData.CellAddress) == false)
                            {
                                unitDic.Add(wData.CellAddress, wData.DataPath);
                            }
                            //mod #12311 複数集計で患者毎の汎用的な集計を作成できない 高 end
                        }
                    }
                }
            }
            //add #12311 複数集計で患者毎の汎用的な集計を作成できない 高 start
            if (unitDic.Count > 0)
            {
                bool bFirst = false;
                foreach (var unit in unitDic)
                {
                    if (bFirst == false)
                    {
                        strTmp = unit.Value;
                        bFirst = true;

                    }
                    else
                        strTmp = string.Format("{0},{1}", strTmp, unit.Value);
                }
            }
            //add #12311 複数集計で患者毎の汎用的な集計を作成できない 高 end
            txtTotalUnitV.Text = strTmp;

            //add #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 START
            /* if (RldLib.CurrentLayoutData.DesignParamList.Count > 0 && RldLib.CurrentLayoutData.DesignTempleteData != null)
             {
                 medit = true;
             }*/
            medit = true;

            if (RldLib.CurrentLayoutData.DesignTempleteData != null)
            {
                newRepeatV = int.Parse(RldLib.CurrentLayoutData.DesignTempleteData.RepeatCountV);
                newRepeatH = int.Parse(RldLib.CurrentLayoutData.DesignTempleteData.RepeatCountH);
            }
            //add #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 END

            //foreach (var wData in RldLib.CurrentLayoutData.DesignParamList)
            //{
            //    if (wData.DataCode.Equals(RldLib.totalLayoutData.UnitH))
            //    {
            //        txtTotalUnitH.Text = wData.DataPath;
            //    }
            //}
            strTmp = "";
            //add #12311 複数集計で患者毎の汎用的な集計を作成できない 高 start
            unitDic.Clear();
            //add #12311 複数集計で患者毎の汎用的な集計を作成できない 高 end
            // add Aspose.cells関連問題8の三回目対応 夏 start
            if (RldLib.totalLayoutData.UnitH.StartsWith(RldConst.PATH_HEADER))
            {
                strTmp = RldLib.totalLayoutData.UnitH.Replace(RldConst.PATH_HEADER, "");
            }
            else
            {
                // add Aspose.cells関連問題8の三回目対応 夏 end
                List<string> totalUnitHList = new List<string>(RldLib.totalLayoutData.UnitH.Split(','));
                foreach (var wList in totalUnitHList)
                {
                    foreach (var wData in RldLib.CurrentLayoutData.DesignParamList)
                    {
                        // mod #10858 「##=[##データ項目」」の形式で null が出力される 高 start
                        // if (wData.DataCode.Equals(wList))
                        //mod #12311 複数集計で患者毎の汎用的な集計を作成できない 高 start
                        //if (wData.DataCode.Equals(wList) && !string.IsNullOrEmpty(wList))
                        if (wData.DataCode.Equals(wList) && wList != null)
                        //mod #12311 複数集計で患者毎の汎用的な集計を作成できない 高 end
                        // mod #10858 「##=[##データ項目」」の形式で null が出力される 高 end
                        {
                            // add #11294 紹介状で集計部分がずれて出力される 高 start
                            // 縦の単位
                            if (retTotalUnitH != null && retTotalUnitH.Contains(wData.CellAddress) == true)
                            {
                            // add #11294 紹介状で集計部分がずれて出力される 高 end
                                //mod #12311 複数集計で患者毎の汎用的な集計を作成できない 高 start
                                //if (strTmp == "")
                                //{
                                //    strTmp = wData.DataPath;
                                //}
                                //else
                                //{
                                //    strTmp = string.Format("{0},{1}", strTmp, wData.DataPath);
                                //}
                                if (unitDic.ContainsKey(wData.CellAddress) == false)
                                {
                                    unitDic.Add(wData.CellAddress, wData.DataPath);
                                }
                                //mod #12311 複数集計で患者毎の汎用的な集計を作成できない 高 end
                            }
                        }
                    }
                }
                // add Aspose.cells関連問題8の三回目対応 夏 start
            }
            // add Aspose.cells関連問題8の三回目対応 夏 end
            //add #12311 複数集計で患者毎の汎用的な集計を作成できない 高 start
            if (unitDic.Count > 0)
            {
                bool bFirst = false;
                foreach (var unit in unitDic)
                {
                    if (bFirst == false)
                    {
                        strTmp = unit.Value;
                        bFirst = true;

                    }
                    else
                        strTmp = string.Format("{0},{1}", strTmp, unit.Value);
                }
            }
            //add #12311 複数集計で患者毎の汎用的な集計を作成できない 高 end
            txtTotalUnitH.Text = strTmp;
            // mod UT帳票No.136 二次元帳票再編集の場合、横の単位表示不正の対応 夏 end

            cobTotalUnitDate.SelectedItem = RldLib.totalLayoutData.UnitDate;

            cobTotalContents.SelectedItem = RldLib.totalLayoutData.Contents;
            // add #6035　2021-12-28 紹介状で曜日単位の投与マトリクスが表示できない 孟堅 start
            if (RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_REFERRAL_LETTER && "1".Equals(RldLib.totalLayoutData.ReportType))
            {
                cobTotalUnitDate.Items.Remove("年");
                cobTotalUnitDate.Items.Remove("月");
                cobTotalUnitDate.SelectedItem = RldLib.totalLayoutData.UnitDate;
            }
            // add #6035　2021-12-28 紹介状で曜日単位の投与マトリクスが表示できない　孟堅 end
            // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe start
            if (string.IsNullOrEmpty(RldLib.totalLayoutData.EffectDataV)) RldLib.totalLayoutData.EffectDataV = "0";
            chkEffectDataV.Checked = RldLib.totalLayoutData.EffectDataV.Equals("1");
            // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe end
            // add #12218 集計の縦単位でも値のない行が出力できない limingzhe start
            if (string.IsNullOrEmpty(RldLib.totalLayoutData.EffectDataH)) RldLib.totalLayoutData.EffectDataH = "0";
            chkEffectDataH.Checked = RldLib.totalLayoutData.EffectDataH.Equals("1");
            // add #12218 集計の縦単位でも値のない行が出力できない limingzhe end
            // add #11973 日常点検一覧帳票が正常に出せない 高 start
            if (RldLib.totalLayoutData.Contents.Equals("項目値"))
            {
                if(string.IsNullOrEmpty(RldLib.totalLayoutData.ContentsType))
                {
                    cobTotalContentsType.SelectedIndex = 0;
                    RldLib.totalLayoutData.ContentsType = cobTotalContentsType.SelectedItem.ToString();
                }
                else
                {
                    cobTotalContentsType.SelectedItem = RldLib.totalLayoutData.ContentsType;
                }
                cobTotalContentsType.Visible = true;
            }
            else
            {
                cobTotalContentsType.SelectedIndex = 0;
                cobTotalContentsType.Text = string.Empty;
                RldLib.totalLayoutData.ContentsType = string.Empty;
                cobTotalContentsType.Visible = false;
            }
            totalUnitDateVisible();
            // add #11973 日常点検一覧帳票が正常に出せない 高 end
            // add 単一集計帳票／複数集計帳票：帳票分類コンボボックスの追加 鄧シン  start
            // mod add #5714 紹介状が正しく出力できない start
            // mod #5884 紹介状は単集計の場合の処理 鄧シン start
            // if (RldLib.CurrentReport.ReportClass == 10 || RldLib.CurrentReport.ReportClass == 11)
            //if (RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_ONE_TOTAL ||
            //    RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_MULTI_TOTAL ||
            //    (RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_REFERRAL_LETTER && "1".Equals(RldLib.CurrentReport.ReportType)))
            // mod #12404 単集計帳票の集計内訳タブに「帳票区分」は不要 高 start
            //if (RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_ONE_TOTAL ||
            //    RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_MULTI_TOTAL)
            if (RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_MULTI_TOTAL)
            // mod #12404 単集計帳票の集計内訳タブに「帳票区分」は不要 高 end
            // mod #5884 紹介状は単集計の場合の処理 鄧シン end
            // mod add #5714 紹介状が正しく出力できない end
            {
                // 表示区分リストを取得する。
                // mod #5884 紹介状は単集計の場合の処理 鄧シン start
                // List<SysReportClass>  wRepotrType = Task.Run<List<SysReportClass>>(async () => await GetReportType(RldLib.CurrentReport.ReportClass)).Result;
                int getReportType = RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_REFERRAL_LETTER ? RldConst.MasterData.Report.VAL_TYPE_ONE_TOTAL : RldLib.CurrentReport.ReportClass;
                List<SysReportClass> wRepotrType = Task.Run<List<SysReportClass>>(async () => await GetReportType(getReportType)).Result;
                // mod #5884 紹介状は単集計の場合の処理 鄧シン end

                if (wRepotrType.Count == 1)
                {
                    String jsonString = wRepotrType[0].ReportType;
                    JavaScriptSerializer json = new JavaScriptSerializer();
                    reportType = json.Deserialize<List<ReportType>>(jsonString);
                    var items = reportType.Select(x => x.Name);

                    // 帳票区分リストに空白Itemを追加する。
                    this.cobTotalReportType.Items.AddRange(new String[] { "" });

                    if (items.Count() > 0)
                    {
                        this.cobTotalReportType.Items.AddRange(items.ToArray());
                    }
                }

                // 帳票区分を表示する。
                this.label7.Visible = true;
                this.cobTotalReportType.Visible = true;
            }
            else
            {
                // 帳票区分を表示しない
                this.label7.Visible = false;
                this.cobTotalReportType.Visible = false;
            }

            if (reportType.Where(item => item.Cd == RldLib.CurrentReport.ReportType).Select(item => item.Name).Count() != 0)
            {
                // 帳票区分を取得する。
                cobTotalReportType.SelectedItem = reportType.Where(item => item.Cd == RldLib.CurrentReport.ReportType).Select(item => item.Name).First();
            }
            // add 単一集計帳票／複数集計帳票：帳票分類コンボボックスの追加 鄧シン  end

            if (RldLib.totalLayoutData.CountH == "1")
            {
                radTotalCountHDisp.Checked = true;
                radTotalCountH.Checked = false;
            }
            else
            {
                radTotalCountHDisp.Checked = false;
                radTotalCountH.Checked = true;
            }

            if (RldLib.totalLayoutData.CountV == "1")
            {
                radTotalCountVDisp.Checked = true;
                radTotalCountV.Checked = false;
            }
            else
            {
                radTotalCountVDisp.Checked = false;
                radTotalCountV.Checked = true;
            }

        }

        #endregion

        #region メンバ関数定義(override...)

        /// <summary>
        /// Form.Load イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);

            if (base.DesignMode) return;

            // 画面をクリア
            this.DataClear(true);

            Control.CheckForIllegalCrossThreadCalls = false;
        }

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
            this.UpdateTempleteAreaImage();
            // データを再読み込み
            this.UpdateDetailGrid();
            // 全てのパラメータデータがテンプレート範囲に含まれているか更新
            RldLib.UpdateDesignParamDataIsInTemplete();
        }

        /// <summary>
        /// Form.Shown イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnShown(EventArgs e)
        {
            base.OnShown(e);

            // 画像を更新
            this.UpdateTempleteAreaImage();
            // 画面にデータを読み込む
            //EDIT #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG START
            this.UpdateDetailGrid(false);
            //EDIT #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG START
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

            this.dgvTmplDetail.RowCount = 0;
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

                        // 行数と列数を取得totalTable 
                        RldLib.CurrentLayoutData.DesignTempleteData.RowCount = wXlRows.Range.Count;
                        RldLib.CurrentLayoutData.DesignTempleteData.ColumnCount = wXlColumns.Range.Count;
                    }
                    //add #9537 手入力できない箇所がある dongzhaolong start
                    this.UpdateRepeatAddress();
                    //add #9537 手入力できない箇所がある dongzhaolong end
                }

                if (!String.IsNullOrEmpty(RldLib.CurrentLayoutData.DesignTempleteData.Range))
                    RldLib.CurrentLayoutData.DesignSettingData.HasTemplete = RldConst.SettingData.VAL_HAS_TEMPLETE_YES;

                // 画像を更新
                this.UpdateTempleteAreaImage();
                // データを再読み込み
                this.UpdateDetailGrid(true);
                // 全てのパラメータデータがテンプレート範囲に含まれているか更新
                //edit #9484 因島帳票の表示不具合（帳票種別：紹介状）dongzhaolong start
                RldLib.UpdateDesignParamDataIsInTemplete(totalTotal);
                //edit #9484 因島帳票の表示不具合（帳票種別：紹介状）dongzhaolong end
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
        private void UpdateTempleteAreaImage()
        {
            System.Drawing.Image wImage = null;

            this.lblTmplDescription.Visible = true;
            this.picTmpl.Image = null;
            if (RldLib.CurrentLayoutData.DesignTempleteData == null)
                RldLib.CurrentLayoutData.DesignTempleteData = new DesignTempleteData();
            if (!String.IsNullOrEmpty(RldLib.CurrentLayoutData.DesignTempleteData.Range))
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
            // add #11011 集計内訳タブ仕様変更 高 start
            if (RldLib.CurrentLayoutData.DesignSettingData.HasTemplete == RldConst.SettingData.VAL_HAS_TEMPLETE_YES)
            {
                btnTotalUnitH.Enabled = true;
                btnTotalUnitV.Enabled = true;
                cobTotalUnitDate.Enabled = true;
                // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe start
                chkEffectDataV.Enabled = true;
                // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe end
                // add #12218 集計の縦単位でも値のない行が出力できない limingzhe start
                chkEffectDataH.Enabled = true;
                // add #12218 集計の縦単位でも値のない行が出力できない limingzhe end
                cobTotalContents.Enabled = true;
                if (cobTotalReportType.Visible == true)
                {
                    cobTotalReportType.Enabled = true;
                }
            }
            else
            {
                btnTotalUnitH.Enabled = false;
                btnTotalUnitV.Enabled = false;
                cobTotalUnitDate.Enabled = false;
                // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe start
                chkEffectDataV.Enabled = false;
                // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe end
                // add #12218 集計の縦単位でも値のない行が出力できない limingzhe start
                chkEffectDataH.Enabled = false;
                // add #12218 集計の縦単位でも値のない行が出力できない limingzhe end
                cobTotalContents.Enabled = false;
                if (cobTotalReportType.Visible == true)
                {
                    cobTotalReportType.Enabled = false;
                }
            }
            // add #11011 集計内訳タブ仕様変更 高 end
        }

        /// <summary>
        /// テンプレート繰返し明細表示用グリッドの表示を更新します。
        /// </summary>
        private void UpdateDetailGrid(Boolean bEdit = true)
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

                // テンプレート繰返し明細表示用データグリッドビューの内容をリセット
                RldGridRCAttributeReflector.ApplyToRow(this.dgvTmplDetail, wProperties);

                //del #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 START
                //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG START
                //Boolean editTotal = false;
                //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG END
                //del #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 END

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
                                //editTotal = true;
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
                                //editTotal = true;
                            }
                            //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG END
                        }
                        // 余白(横)
                        else if (wFuncIsEqualPropName(DesignTempleteData.EnumDataIndex.MarginV))
                        {
                            wValueCell.Value = RldLib.CurrentLayoutData.DesignTempleteData.MarginV;
                        }
                        // 余白(縦)
                        else if (wFuncIsEqualPropName(DesignTempleteData.EnumDataIndex.MarginH))
                        {
                            wValueCell.Value = RldLib.CurrentLayoutData.DesignTempleteData.MarginH;
                        }
                        // 繰返方向
                        else if (wFuncIsEqualPropName(DesignTempleteData.EnumDataIndex.ComboBoxEditDirectionText))
                        {
                            DesignTempleteData.SetDirectionComboBoxItem(ref wValueCell);
                            wValueCell.Value = RldLib.CurrentLayoutData.DesignTempleteData.DirectionData;
                            // mod #5598 帳票を出力方法（N/Z）について　鄧シン start
                            // wFuncSetCellReadOnly(true);
                            wFuncSetCellReadOnly(false);
                            // mod #5598 帳票を出力方法（N/Z）について　鄧シン end
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
                                RldLib.CurrentLayoutData.DesignSettingData.ReportClass == RldConst.ReportTypeData.VAL_TYPE_MULTI_PATIENT)
                                wCanEditRepeatMode = true;
                            wFuncSetCellReadOnly(!wCanEditRepeatMode);
                        }
                        //add #8763 zhu start
                        // 繰返しモード
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
                }
                //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG START
                //del #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 START
                /* if (editTotal == true || bEdit == true)

                       {
                         this.syncStyle(bEdit);
                       }*/
                //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG END
                //del #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 END
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

        // add 単一集計帳票／複数集計帳票：帳票分類コンボボックスの追加 鄧シン  start
        /// <summary>
        /// 帳票区分リストを取得する。
        /// </summary>
        /// <param name="classCd">帳票種別</param>
        private static async Task<List<SysReportClass>> GetReportType(int classCd)
        {
            try
            {
                List<SysReportClass> m_MstMainteLayoutData = null;

                string wUri = $"{NKKWebAccess.BaseUri}{RldConst.Uri.WEB_APP}{RldConst.Uri.GET_SYS_REPORT_CLASS}{"?classCd="}{classCd}";
                var wReportType = await NKKWebAccess.Get("帳票区分取得", wUri, NKKWebAccess.SKIP_OTP);

                // 取得データを戻り値にセット
                if (wReportType.isLogin && wReportType.response.IsSuccessStatusCode)
                {
                    m_MstMainteLayoutData = RldJsonDataSerializeHelper<List<SysReportClass>>.Deserialize(wReportType.strContent);
                }


                return m_MstMainteLayoutData;
            }
            catch (Exception ex)
            {
                LayoutDesignerUtilityLib.LayoutDesignerUtility.RecordException(ex, true);
                return null;
            }
        }
        // add 単一集計帳票／複数集計帳票：帳票分類コンボボックスの追加 鄧シン  end

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

            // add #12274 集計使用項目と同じグループ名を禁止するエラーの頻度が高くなりすぎる 高 start
            unitClearGroupName(RldLib.totalLayoutData.UnitHAddress, string.Empty);
            unitClearGroupName(RldLib.totalLayoutData.UnitVAddress, string.Empty);
            // add #12274 集計使用項目と同じグループ名を禁止するエラーの頻度が高くなりすぎる 高 end

            this.DataClear(true);

            // add #10858 「##=[##データ項目」」の形式で null が出力される 高 start
            txtTotalUnitH.Text = string.Empty;
            txtTotalUnitV.Text = string.Empty;
            // add #11011 集計内訳タブ仕様変更 高 start
            RldLib.totalLayoutData.UnitHAddress = string.Empty;
            btnTotalUnitH.Enabled = false;
            RldLib.totalLayoutData.UnitVAddress = string.Empty;
            btnTotalUnitV.Enabled = false;
            // add #11011 集計内訳タブ仕様変更 高 end
            this.lblTmplDescription.Visible = true;
            // add #11973 日常点検一覧帳票が正常に出せない 高 start
            cobTotalUnitDate.Visible = true;
            // add #11973 日常点検一覧帳票が正常に出せない 高 end

            // mod #11011 集計内訳タブ仕様変更 高 start
            //if (cobTotalUnitDate.SelectedIndex != -1)
            //{
            //    cobTotalUnitDate.SelectedIndex = -1;
            //    cobTotalUnitDate.Text = string.Empty;
            //    RldLib.totalLayoutData.UnitDate = string.Empty;
            //}
            cobTotalUnitDate.SelectedIndex = 0;
            cobTotalUnitDate.Text = string.Empty;
            RldLib.totalLayoutData.UnitDate = string.Empty;
            cobTotalUnitDate.Enabled = false;
            // mod #11011 集計内訳タブ仕様変更 高 end

            // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe start
            chkEffectDataV.Checked = false;
            chkEffectDataV.Enabled = false;
            RldLib.totalLayoutData.EffectDataV = "0";
            // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe end
            // add #12218 集計の縦単位でも値のない行が出力できない limingzhe start
            chkEffectDataH.Checked = false;
            chkEffectDataH.Enabled = false;
            RldLib.totalLayoutData.EffectDataH = "0";
            // add #12218 集計の縦単位でも値のない行が出力できない limingzhe end

            // mod #11011 集計内訳タブ仕様変更 高 start
            //if (cobTotalContents.SelectedIndex != -1)
            //{
            //    cobTotalContents.SelectedIndex = -1;
            //    cobTotalContents.Text = string.Empty;
            //    RldLib.totalLayoutData.Contents = string.Empty;
            //}
            cobTotalContents.SelectedIndex = 0;
            cobTotalContents.Text = string.Empty;
            RldLib.totalLayoutData.Contents = string.Empty;
            cobTotalContents.Enabled = false;
            // mod #11011 集計内訳タブ仕様変更 高 end

            // add #11973 日常点検一覧帳票が正常に出せない 高 start
            cobTotalContentsType.SelectedIndex = 0;
            cobTotalContentsType.Text = string.Empty;
            RldLib.totalLayoutData.ContentsType = string.Empty;
            cobTotalContentsType.Visible = false;
            // add #11973 日常点検一覧帳票が正常に出せない 高 end

            // add #10942 「表示変換」の動作が不正 limingzhe start
            btnChange.Enabled = false;
            ConvertList = new DesignConvertList();
            RldLib.totalLayoutData.Conversion = string.Empty;
            // add #10942 「表示変換」の動作が不正 limingzhe end

            // mod #11011 集計内訳タブ仕様変更 高 start
            // if (cobTotalReportType.SelectedIndex != 0 && cobTotalReportType.Visible == true)
            if (cobTotalReportType.Visible == true)
            // mod #11011 集計内訳タブ仕様変更 高 end
            {
                cobTotalReportType.SelectedIndex = 0;
                RldLib.totalLayoutData.ReportType = "0";
                RldLib.CurrentReport.ReportType = "0";
                // add #11011 集計内訳タブ仕様変更 高 start
                cobTotalReportType.Enabled = false;
                // add #11011 集計内訳タブ仕様変更 高 end
            }
            // add #10858 「##=[##データ項目」」の形式で null が出力される 高 end


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

            // add #11011 集計内訳タブ仕様変更 高 start
            bool bExist = false;
            using (var wXlRange = RldLib.XlHelper.XlApp.GetSelectedCell)
            {
                Microsoft.Office.Interop.Excel.Range range1 = wXlRange.Range;
                string cellAddrSelect = wXlRange.Range.Address[false, false];
                foreach (var wData in RldLib.CurrentLayoutData.DesignParamList)
                {
                    if (string.IsNullOrEmpty(wData.DataPath) == false && wData.DataPath.StartsWith(RldConst.PATH_HEADER))
                    {

                        Microsoft.Office.Interop.Excel.Range cell1 = RldLib.XlHelper.XlSheetLayout.Worksheet.get_Range(wData.CellAddress);
                        Microsoft.Office.Interop.Excel.Range intersectRange = RldLib.XlHelper.XlApp.Application.Intersect(range1, cell1);
                        if (intersectRange != null)
                        {
                            if(wData.CellAddress.Equals(cellAddrSelect) == false)
                            {
                                var wEventArgs = new RldDesignNotifyInfoRequestShowMessageEventArgs()
                                {
                                    Text = @"集計内容は単一セルしか設定できません。",
                                    Caption = @"集計内容が不適切",
                                    Buttons = MessageBoxButtons.OK,
                                    Icon = MessageBoxIcon.Warning,
                                    DefaultButton = MessageBoxDefaultButton.Button1
                                };
                                SendNotifyInfo(wEventArgs);
                                return;
                            }
                            bExist = true;
                            break;
                        }
                    }
                }
                if(bExist == false)
                {
                    var wEventArgs = new RldDesignNotifyInfoRequestShowMessageEventArgs()
                    {
                        Text = @"集計内容に指定されたセルにデータ項目がありません。",
                        Caption = @"集計内容が不適切",
                        Buttons = MessageBoxButtons.OK,
                        Icon = MessageBoxIcon.Warning,
                        DefaultButton = MessageBoxDefaultButton.Button1
                    };
                    SendNotifyInfo(wEventArgs);
                    return;
                }
            }
            // add #11011 集計内訳タブ仕様変更 高 end
            // add #11973 日常点検一覧帳票が正常に出せない 高 start
            cobTotalUnitDate.Visible = true;
            // add #11973 日常点検一覧帳票が正常に出せない 高 end

            // add #12274 集計使用項目と同じグループ名を禁止するエラーの頻度が高くなりすぎる 高 start
            unitClearGroupName(RldLib.totalLayoutData.UnitHAddress, string.Empty);
            unitClearGroupName(RldLib.totalLayoutData.UnitVAddress, string.Empty);
            // add #12274 集計使用項目と同じグループ名を禁止するエラーの頻度が高くなりすぎる 高 end

            // add #11106 集計帳票で集計範囲外のグループ項目が出力されない 高 start
            // リストのループ
            for (int i = 0; i < RldLib.CurrentLayoutData.DesignGroupList.Count; i++)
            {
                var wData = RldLib.CurrentLayoutData.DesignGroupList[i];
                wData.CanEditNewPage = true;
            }
            // add #11106 集計帳票で集計範囲外のグループ項目が出力されない 高 end

                this.UpdateTempleteAreaData();
            // add #11011 集計内訳タブ仕様変更 高 start
            if (RldLib.CurrentLayoutData.DesignSettingData.HasTemplete == RldConst.SettingData.VAL_HAS_TEMPLETE_YES)
            {
                // mod #11106 集計帳票で集計範囲外のグループ項目が出力されない 高 start
                RldLib.totalLayoutData.UnitHAddress = string.Empty;
                RldLib.totalLayoutData.UnitVAddress = string.Empty;
                RldLib.totalLayoutData.UnitDate = string.Empty;
                cobTotalUnitDate.SelectedIndex = 0;
                txtTotalUnitH.Text = string.Empty;
                txtTotalUnitV.Text = string.Empty;
                cobTotalUnitDate.Text = string.Empty;
               

                // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe start
                chkEffectDataV.Checked = false;
                RldLib.totalLayoutData.EffectDataV = "0";
                // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe end
                // add #12218 集計の縦単位でも値のない行が出力できない limingzhe start
                chkEffectDataH.Checked = false;
                RldLib.totalLayoutData.EffectDataH = "0";
                // add #12218 集計の縦単位でも値のない行が出力できない limingzhe end

                RldLib.totalLayoutData.Contents = string.Empty;
                cobTotalContents.SelectedIndex = 0;
                cobTotalContents.Text = string.Empty;

                // add #11973 日常点検一覧帳票が正常に出せない 高 start
                RldLib.totalLayoutData.ContentsType = string.Empty;
                cobTotalContentsType.SelectedIndex = 0;
                cobTotalContentsType.Text = string.Empty;
                cobTotalContentsType.Visible = false;
                // add #11973 日常点検一覧帳票が正常に出せない 高 end

                // add #10942 「表示変換」の動作が不正 limingzhe start
                btnChange.Enabled = false;
                ConvertList = new DesignConvertList();
                RldLib.totalLayoutData.Conversion = string.Empty;
                // add #10942 「表示変換」の動作が不正 limingzhe end

                if (cobTotalReportType.Visible == true)
                {
                    RldLib.totalLayoutData.ReportType = "0";
                    RldLib.CurrentReport.ReportType = "0";
                    cobTotalReportType.SelectedIndex = 0;
                    
                }
                // mod #11106 集計帳票で集計範囲外のグループ項目が出力されない 高 end
            }
            // add #11011 集計内訳タブ仕様変更 高 end
        }

        /// <summary>
        /// ドラッグアンドドロップ受付用パネルの DragDrop イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void pnlTmplDrop_DragDrop(object sender, DragEventArgs e)
        {
            if (e.Data.GetDataPresent("SymbolicLink"))
            {
                // mod #11011 集計内訳タブ仕様変更 高 start
                //using (var wXlRange = RldLib.XlHelper.XlApp.GetSelectedCell)
                //{
                //    if (!String.IsNullOrEmpty(wXlRange.Range.Text))
                //    {
                //        txtTotalUnitV.Text = wXlRange.Range.Text;
                //    }
                //}
                this.btnTmplSelect.PerformClick();
                // mod #11011 集計内訳タブ仕様変更 高 end
            }
            //this.UpdateTempleteAreaData();
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
                //del #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 START
                /*//ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG START
                //bool editTotal = false;
                //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG END*/
                //del #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 START

                // プロパティ名チェック用
                Boolean wFuncIsEqualPropName(DesignTempleteData.EnumDataIndex aIndex) =>
                    wPropName == DesignTempleteData.GetPropertyName(aIndex);

                // 繰返し回数(横)
                if (wFuncIsEqualPropName(DesignTempleteData.EnumDataIndex.RepeatCountV))
                {
                    Int32 wConvValue = RldLib.ConvertStrToInt32(wValue, false);
                    if (wConvValue < 1) wConvValue = 1;    // 最低回数は1回
                    //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG START
                    if (newRepeatV != wConvValue)
                    {
                        newRepeatV = wConvValue;
                        medit = true;
                        //del #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 START
                        //editTotal = true;
                        //del #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 END
                    }
                    //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG END

                    RldLib.CurrentLayoutData.DesignTempleteData.RepeatCountV = wConvValue.ToString();
                    this.dgvTmplDetail[(Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.ItemValue, e.RowIndex].Value = wConvValue.ToString();
                    //add #9537 手入力できない箇所がある dongzhaolong start
                    this.UpdateRepeatAddress();
                    //add #9537 手入力できない箇所がある dongzhaolong end
                }
                // 繰返し回数(縦)
                else if (wFuncIsEqualPropName(DesignTempleteData.EnumDataIndex.RepeatCountH))
                {
                    Int32 wConvValue = RldLib.ConvertStrToInt32(wValue, false);
                    if (wConvValue < 1) wConvValue = 1;    // 最低回数は1回
                    //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG START
                    if (newRepeatH != wConvValue)
                    {
                        newRepeatH = wConvValue;
                        medit = true;
                        //del #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 START
                        //editTotal = true;
                        //del #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 END
                    }
                    //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG END

                    RldLib.CurrentLayoutData.DesignTempleteData.RepeatCountH = wConvValue.ToString();
                    this.dgvTmplDetail[(Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.ItemValue, e.RowIndex].Value = wConvValue.ToString();
                    //add #9537 手入力できない箇所がある dongzhaolong start
                    this.UpdateRepeatAddress();
                    //add #9537 手入力できない箇所がある dongzhaolong end
                }
                // 余白(横)
                else if (wFuncIsEqualPropName(DesignTempleteData.EnumDataIndex.MarginV))
                {
                    String wConvValue = Convert.ToString(RldLib.ConvertStrToInt32(wValue, false));
                    RldLib.CurrentLayoutData.DesignTempleteData.MarginV = wConvValue;
                    this.dgvTmplDetail[(Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.ItemValue, e.RowIndex].Value = wConvValue;
                }
                // 余白(縦)
                else if (wFuncIsEqualPropName(DesignTempleteData.EnumDataIndex.MarginH))
                {
                    String wConvValue = Convert.ToString(RldLib.ConvertStrToInt32(wValue, false));
                    RldLib.CurrentLayoutData.DesignTempleteData.MarginH = wConvValue;
                    this.dgvTmplDetail[(Int32)RldGridRCAttributeReflector.EnumRowModeColumnIndex.ItemValue, e.RowIndex].Value = wConvValue;
                }
                // 繰返し方向
                else if (wFuncIsEqualPropName(DesignTempleteData.EnumDataIndex.ComboBoxEditDirectionText))
                {
                    RldLib.CurrentLayoutData.DesignTempleteData.DirectionData = wValue;
                    // add #11294 紹介状で集計部分がずれて出力される 高 start
                    this.UpdateRepeatAddress();
                    // add #11294 紹介状で集計部分がずれて出力される 高 end
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
                //del #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 START
                /* //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG START
                 if (editTotal == true)
                 {
                     this.syncStyle();
                 }
                 //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG END*/
                //del #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 START
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
                    // del 6941 集計内訳＞繰返回数の入力動作不正 start
                    //e.Cancel = true;
                    // del 6941 集計内訳＞繰返回数の入力動作不正 end
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
                //add #9537 手入力できない箇所がある dongzhaolong start
                cellEdit = false;
                dgvTmplDetail_CellEndEdit(sender, new DataGridViewCellEventArgs(this.dgvTmplDetail.CurrentCell.ColumnIndex, this.dgvTmplDetail.CurrentCell.RowIndex));
                //add #9537 手入力できない箇所がある dongzhaolong end
                cellEdit = true;
            }
        }

        #endregion

        private void txtTotalUnitV_Changed(Object sender, System.EventArgs e)
        {
            string strTmp = "";
            //add #12311 複数集計で患者毎の汎用的な集計を作成できない 高 start
            Dictionary<string, string> unitDic = new Dictionary<string, string>();
            //add #12311 複数集計で患者毎の汎用的な集計を作成できない 高 end
            //add #9484 因島帳票の表示不具合（帳票種別：紹介状）dongzhaolong start
            List<string> readOnly = new List<string>();
            List<DesignGroupData> groupList = RldLib.CurrentLayoutData.DesignGroupList.ToList();
            // mod #11106 集計帳票で集計範囲外のグループ項目が出力されない 高 start
            //totalTotal = txtTotalUnitV.Text.Trim() + "," + txtTotalUnitH.Text.Trim();

            //List<string> totalTotalList = new List<string>(totalTotal.Trim().Split(','));
            //foreach (var wList in totalTotalList)
            string totalAddress = RldLib.totalLayoutData.UnitVAddress.Trim() + "," + RldLib.totalLayoutData.UnitHAddress.Trim();
            List<string> totalAddressList = new List<string>(totalAddress.Split(','));
            foreach (var wList in totalAddressList)
            // mod #11106 集計帳票で集計範囲外のグループ項目が出力されない 高 end
            {
                foreach (var wData in RldLib.CurrentLayoutData.DesignParamList)
                {
                    if (!readOnly.Contains(wData.GroupName))
                    {
                        RldLib.CurrentLayoutData.UpdateDesignGroupData(wData, true);
                    }

                    // mod #11106 集計帳票で集計範囲外のグループ項目が出力されない 高 start
                    //if (wData.DataPath.Equals(wList))
                    if (wData.CellAddress.Equals(wList))
                    // mod #11106 集計帳票で集計範囲外のグループ項目が出力されない 高 end
                    {
                        foreach (var groupData in groupList)
                        {
                            if (!readOnly.Contains(groupData.GroupName))
                            {
                                if (groupData.GroupName == wData.GroupName && groupData.IsInTemplete == wData.IsInTemplete && this.Visible == true)
                                {
                                    groupData.IsNewPage = "";
                                    RldLib.CurrentLayoutData.UpdateDesignGroupData(wData, false);
                                    readOnly.Add(groupData.GroupName);
                                    break;
                                }
                                else
                                {
                                    RldLib.CurrentLayoutData.UpdateDesignGroupData(wData, true);
                                }
                            }
                            else
                            {
                                if (readOnly.Count == 0)
                                {
                                    if (groupData.GroupName == wData.GroupName && groupData.IsInTemplete == wData.IsInTemplete && this.Visible == true)
                                    {
                                        groupData.IsNewPage = "";
                                        RldLib.CurrentLayoutData.UpdateDesignGroupData(wData, false);
                                        readOnly.Add(groupData.GroupName);
                                        break;
                                    }
                                    else
                                    {
                                        RldLib.CurrentLayoutData.UpdateDesignGroupData(wData, true);
                                    }
                                }
                                else
                                {
                                    RldLib.CurrentLayoutData.UpdateDesignGroupData(wData, true);
                                }
                            }
                        }
                    }
                }
            }
            //add #9484 因島帳票の表示不具合（帳票種別：紹介状）dongzhaolong end
            // add #6691 複数集計：対象項目の不足対応 夏 start
            if (txtTotalUnitV.Text.StartsWith(RldConst.PATH_HEADER))
            {
                // add #11973 日常点検一覧帳票が正常に出せない 高 start
                List<String> retTotalUnitV = new List<string>(RldLib.totalLayoutData.UnitVAddress.Trim().Split(','));
                // add #11973 日常点検一覧帳票が正常に出せない 高 end
                // add #6691 複数集計：対象項目の不足対応 夏 end
                List<string> totalUnitVList = new List<string>(txtTotalUnitV.Text.Trim().Split(','));
                foreach (var wList in totalUnitVList)
                {
                    foreach (var wData in RldLib.CurrentLayoutData.DesignParamList)
                    {
                        if (wData.DataPath.Equals(wList))
                        {
                            // add #11973 日常点検一覧帳票が正常に出せない 高 start
                            if (retTotalUnitV != null && retTotalUnitV.Contains(wData.CellAddress) == true)
                            {
                            // add #11973 日常点検一覧帳票が正常に出せない 高 end
                                //mod #12311 複数集計で患者毎の汎用的な集計を作成できない 高 start
                                //if (strTmp == "")
                                //{
                                //    strTmp = wData.DataCode;
                                //}
                                //else
                                //{
                                //    // add Aspose.cells関連問題8の三回目対応 夏 start
                                //    if (!wData.DataCode.Equals(strTmp))
                                //    {
                                //        // add Aspose.cells関連問題8の三回目対応 夏 end
                                //        // mod UT帳票No.136 二次元帳票再編集の場合、横の単位表示不正の対応 夏 start
                                //        //strTmp = string.Format("{0},{1}", RldLib.totalLayoutData.UnitV, wData.DataCode);
                                //        strTmp = string.Format("{0},{1}", strTmp, wData.DataCode);
                                //        // mod UT帳票No.136 二次元帳票再編集の場合、横の単位表示不正の対応 夏 end
                                //        // add Aspose.cells関連問題8の三回目対応 夏 start
                                //    }
                                //    // add Aspose.cells関連問題8の三回目対応 夏 end
                                //}
                                if (unitDic.ContainsKey(wData.CellAddress) == false)
                                {
                                    unitDic.Add(wData.CellAddress, wData.DataCode);
                                }
                                //mod #12311 複数集計で患者毎の汎用的な集計を作成できない 高 end
                            }
                        }
                    }
                }
                //add #12311 複数集計で患者毎の汎用的な集計を作成できない 高 start
                if(unitDic.Count > 0)
                {
                    bool bFirst = false;
                    foreach (var unit in unitDic)
                    {
                        if(bFirst == false)
                        {
                            strTmp = unit.Value;
                            bFirst = true;

                        }
                        else
                            strTmp = string.Format("{0},{1}", strTmp, unit.Value);
                    }
                }
                //add #12311 複数集計で患者毎の汎用的な集計を作成できない 高 end
                RldLib.totalLayoutData.UnitV = strTmp;
            }
            // add #6691 複数集計：対象項目の不足対応 夏 start
            else
            {
                // mod #10858 「##=[##データ項目」」の形式で null が出力される 高 start
                // RldLib.totalLayoutData.UnitV = RldConst.PATH_HEADER + txtTotalUnitV.Text.Trim();
                if(string.IsNullOrEmpty(txtTotalUnitV.Text))
                {
                    RldLib.totalLayoutData.UnitV = string.Empty;
                }
                else
                {
                    RldLib.totalLayoutData.UnitV = RldConst.PATH_HEADER + txtTotalUnitV.Text.Trim();
                }
                // mod #10858 「##=[##データ項目」」の形式で null が出力される 高 end

            }
            // add #6691 複数集計：対象項目の不足対応 夏 end
        }

        private void txtTotalUnitH_Changed(Object sender, System.EventArgs e)
        {
            string strTmp = "";
            //add #12311 複数集計で患者毎の汎用的な集計を作成できない 高 start
            Dictionary<string, string> unitDic = new Dictionary<string, string>();
            //add #12311 複数集計で患者毎の汎用的な集計を作成できない 高 end
            //add #9484 因島帳票の表示不具合（帳票種別：紹介状）dongzhaolong start
            List<string> readOnly = new List<string>();
            List<DesignGroupData> groupList = RldLib.CurrentLayoutData.DesignGroupList.ToList();
            // mod #11106 集計帳票で集計範囲外のグループ項目が出力されない 高 start
            //totalTotal = txtTotalUnitV.Text.Trim() + "," + txtTotalUnitH.Text.Trim();

            //List<string> totalTotalList = new List<string>(totalTotal.Trim().Split(','));
            //foreach (var wList in totalTotalList)
            string totalAddress = RldLib.totalLayoutData.UnitVAddress.Trim() + "," + RldLib.totalLayoutData.UnitHAddress.Trim();
            List<string> totalAddressList = new List<string>(totalAddress.Split(','));
            foreach (var wList in totalAddressList)
            // mod #11106 集計帳票で集計範囲外のグループ項目が出力されない 高 end
            {
                foreach (var wData in RldLib.CurrentLayoutData.DesignParamList)
                {
                    if (!readOnly.Contains(wData.GroupName))
                    {
                        RldLib.CurrentLayoutData.UpdateDesignGroupData(wData, true);
                    }

                    // mod #11106 集計帳票で集計範囲外のグループ項目が出力されない 高 start
                    //if (wData.DataPath.Equals(wList))
                    if (wData.CellAddress.Equals(wList))
                    // mod #11106 集計帳票で集計範囲外のグループ項目が出力されない 高 end
                    {
                        foreach (var groupData in groupList)
                        {
                            if (!readOnly.Contains(groupData.GroupName))
                            {
                                if (groupData.GroupName == wData.GroupName && groupData.IsInTemplete == wData.IsInTemplete && this.Visible == true)
                                {
                                    groupData.IsNewPage = "";
                                    RldLib.CurrentLayoutData.UpdateDesignGroupData(wData, false);
                                    readOnly.Add(groupData.GroupName);
                                    break;
                                }
                                else
                                {
                                    RldLib.CurrentLayoutData.UpdateDesignGroupData(wData, true);
                                }
                            }
                            else
                            {
                                if (readOnly.Count == 0)
                                {
                                    if (groupData.GroupName == wData.GroupName && groupData.IsInTemplete == wData.IsInTemplete && this.Visible == true)
                                    {
                                        groupData.IsNewPage = "";
                                        RldLib.CurrentLayoutData.UpdateDesignGroupData(wData, false);
                                        readOnly.Add(groupData.GroupName);
                                        break;
                                    }
                                    else
                                    {
                                        RldLib.CurrentLayoutData.UpdateDesignGroupData(wData, true);
                                    }
                                }
                                else
                                {
                                    RldLib.CurrentLayoutData.UpdateDesignGroupData(wData, true);
                                }
                            }
                        }
                    }
                }
            }
            //add #9484 因島帳票の表示不具合（帳票種別：紹介状）dongzhaolong end
            // add Aspose.cells関連問題8の三回目対応 夏 start
            if (txtTotalUnitH.Text.StartsWith(RldConst.PATH_HEADER))
            {
                // add #11973 日常点検一覧帳票が正常に出せない 高 start
                List<String> retTotalUnitH = new List<string>(RldLib.totalLayoutData.UnitHAddress.Trim().Split(','));
                // add #11973 日常点検一覧帳票が正常に出せない 高 end
                // add Aspose.cells関連問題8の三回目対応 夏 end
                List<string> totalUnitHList = new List<string>(txtTotalUnitH.Text.Trim().Split(','));
                foreach (var wList in totalUnitHList)
                {
                    foreach (var wData in RldLib.CurrentLayoutData.DesignParamList)
                    {
                        if (wData.DataPath.Equals(wList))
                        {
                            // add #11973 日常点検一覧帳票が正常に出せない 高 start
                            if (retTotalUnitH != null && retTotalUnitH.Contains(wData.CellAddress) == true)
                            {
                            // add #11973 日常点検一覧帳票が正常に出せない 高 end
                                //mod #12311 複数集計で患者毎の汎用的な集計を作成できない 高 start
                                //if (strTmp == "")
                                //{
                                //    strTmp = wData.DataCode;
                                //}
                                //else
                                //{
                                //    // add Aspose.cells関連問題8の三回目対応 夏 start
                                //    if (!wData.DataCode.Equals(strTmp))
                                //    {
                                //        // add Aspose.cells関連問題8の三回目対応 夏 end
                                //        // mod UT帳票No.136 二次元帳票再編集の場合、横の単位表示不正の対応 夏 start
                                //        //strTmp = string.Format("{0},{1}", RldLib.totalLayoutData.UnitH, wData.DataCode);
                                //        strTmp = string.Format("{0},{1}", strTmp, wData.DataCode);
                                //        // mod UT帳票No.136 二次元帳票再編集の場合、横の単位表示不正の対応 夏 end
                                //        // add Aspose.cells関連問題8の三回目対応 夏 start
                                //    }
                                //    // add Aspose.cells関連問題8の三回目対応 夏 end
                                //}
                                if (unitDic.ContainsKey(wData.CellAddress) == false)
                                {
                                    unitDic.Add(wData.CellAddress, wData.DataCode);
                                }
                                //mod #12311 複数集計で患者毎の汎用的な集計を作成できない 高 end
                            }
                        }
                    }
                }
                //add #12311 複数集計で患者毎の汎用的な集計を作成できない 高 start
                if(unitDic.Count > 0)
                {
                    bool bFirst = false;
                    foreach (var unit in unitDic)
                    {
                        if(bFirst == false)
                        {
                            strTmp = unit.Value;
                            bFirst = true;

                        }
                        else
                            strTmp = string.Format("{0},{1}", strTmp, unit.Value);
                    }
                }
                //add #12311 複数集計で患者毎の汎用的な集計を作成できない 高 end
                RldLib.totalLayoutData.UnitH = strTmp;
            }
            // add Aspose.cells関連問題8の三回目対応 夏 start
            else
            {
                // mod #10858 「##=[##データ項目」」の形式で null が出力される 高 start
                // RldLib.totalLayoutData.UnitH = RldConst.PATH_HEADER + txtTotalUnitH.Text.Trim();
                if (string.IsNullOrEmpty(txtTotalUnitH.Text))
                {
                    RldLib.totalLayoutData.UnitH = string.Empty;
                }
                else
                {
                    RldLib.totalLayoutData.UnitH = RldConst.PATH_HEADER + txtTotalUnitH.Text.Trim();
                }
                // mod #10858 「##=[##データ項目」」の形式で null が出力される 高 end

            }
            // add Aspose.cells関連問題8の三回目対応 夏 end
        }

        private void cobTotalUnitDate_SelectIndexChanged(Object sender, System.EventArgs e)
        {
            // add #10858 「##=[##データ項目」」の形式で null が出力される 高 start
            // del #11011 集計内訳タブ仕様変更 高 start
            //if (cobTotalUnitDate.SelectedIndex == -1)
            //{
            //    RldLib.totalLayoutData.UnitDate = string.Empty;
            //    return;
            //}
            // del #11011 集計内訳タブ仕様変更 高 end
            // add #10858 「##=[##データ項目」」の形式で null が出力される 高 end

            RldLib.totalLayoutData.UnitDate = cobTotalUnitDate.SelectedItem.ToString();
        }

        // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe start
        private void chkEffectDataV_CheckedChanged(object sender, EventArgs e)
        {
            RldLib.totalLayoutData.EffectDataV = chkEffectDataV.Checked ? "1" : "0";
        }
        // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe end

        // add #12218 集計の縦単位でも値のない行が出力できない limingzhe start
        private void chkEffectDataH_CheckedChanged(object sender, EventArgs e)
        {
            RldLib.totalLayoutData.EffectDataH = chkEffectDataH.Checked ? "1" : "0";
        }
        // add #12218 集計の縦単位でも値のない行が出力できない limingzhe end

        private void cobTotalContents_SelectIndexChanged(Object sender, System.EventArgs e)
        {
            // add #10858 「##=[##データ項目」」の形式で null が出力される 高 start
            // del #11011 集計内訳タブ仕様変更 高 start
            //if (cobTotalContents.SelectedIndex == -1)
            //{
            //    RldLib.totalLayoutData.Contents = string.Empty;
            //    return;
            //}
            // del #11011 集計内訳タブ仕様変更 高 end
            // add #10858 「##=[##データ項目」」の形式で null が出力される 高 end

            RldLib.totalLayoutData.Contents = cobTotalContents.SelectedItem.ToString();
            // del #10942 「表示変換」の動作が不正 limingzhe start
            //if (cobTotalContents.SelectedItem != null)
            //{
            //    foreach (var wData in ConvertList)
            //    {
            //        if (wData.ItemValue.IndexOf(cobTotalContents.SelectedItem.ToString()) >= 0)
            //        {
            //            RldLib.totalLayoutData.Conversion = wData.DisplayValue;
            //        }
            //    }
            //}
            // del #10942 「表示変換」の動作が不正 limingzhe end

            // add #11973 日常点検一覧帳票が正常に出せない 高 start
            if (RldLib.totalLayoutData.Contents.Equals("項目値"))
            {
                if (string.IsNullOrEmpty(RldLib.totalLayoutData.ContentsType))
                {
                    cobTotalContentsType.SelectedIndex = 0;
                    RldLib.totalLayoutData.ContentsType = cobTotalContentsType.SelectedItem.ToString();
                }
                cobTotalContentsType.Visible = true;

                // add #10942 「表示変換」の動作が不正 limingzhe start
                btnChange.Enabled = true;
                if (string.IsNullOrEmpty(RldLib.totalLayoutData.Conversion) == false)
                {
                    if(ConvertList.Count == 0)
                    {
                        DesignConvertListData designConvertList = new DesignConvertListData();
                        designConvertList.Code = "1";
                        designConvertList.ItemValue = "項目値　＝　";
                        designConvertList.DisplayValue = RldLib.totalLayoutData.Conversion;
                        ConvertList.Add(designConvertList);
                    }
                    else
                    {
                        foreach (var wData in ConvertList)
                        {
                            if (wData.ItemValue.Contains(cobTotalContents.SelectedItem.ToString()))
                            {
                                wData.DisplayValue = RldLib.totalLayoutData.Conversion;
                            }
                        }
                    }
                   
                }
                // add #10942 「表示変換」の動作が不正 limingzhe end
            }
            else
            {
                cobTotalContentsType.SelectedIndex = 0;
                cobTotalContentsType.Text = string.Empty;
                RldLib.totalLayoutData.ContentsType = string.Empty;
                cobTotalContentsType.Visible = false;

                // add #10942 「表示変換」の動作が不正 limingzhe start
                btnChange.Enabled = false;
                ConvertList = new DesignConvertList();
                RldLib.totalLayoutData.Conversion = string.Empty;
                // add #10942 「表示変換」の動作が不正 limingzhe end
            }
            // add #11973 日常点検一覧帳票が正常に出せない 高 end

            // add #10942 「表示変換」の動作が不正 limingzhe start
            if (cobTotalContents.SelectedItem != null)
            {
                bool bSetSucc = false;
                foreach (var wData in ConvertList)
                {
                    if (wData.ItemValue.Contains(cobTotalContents.SelectedItem.ToString()))
                    {
                        RldLib.totalLayoutData.Conversion = wData.DisplayValue;
                        bSetSucc = true;
                    }
                }
                if (!bSetSucc)
                {
                    ConvertList = new DesignConvertList();
                    RldLib.totalLayoutData.Conversion = String.Empty;
                }
            }
            // add #10942 「表示変換」の動作が不正 limingzhe end
        }

        // add 単一集計帳票／複数集計帳票：帳票分類コンボボックスの追加 鄧シン  start
        private void cobTotalReportType_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (reportType.Where(item => item.Name == cobTotalReportType.SelectedItem.ToString()).Select(item => item.Cd).Count() != 0)
            {
                // mod Aspose.cells関連問題8の対応 夏 start
                //RldLib.CurrentReport.ReportType = reportType.Where(item => item.Name == cobTotalReportType.SelectedItem.ToString()).Select(item => item.Cd).First();
                RldLib.totalLayoutData.ReportType = reportType.Where(item => item.Name == cobTotalReportType.SelectedItem.ToString()).Select(item => item.Cd).First();
                // mod Aspose.cells関連問題8の対応 夏 end
                // add #10858 「##=[##データ項目」」の形式で null が出力される 高 start
                RldLib.CurrentReport.ReportType = RldLib.totalLayoutData.ReportType;
                // add #10858 「##=[##データ項目」」の形式で null が出力される 高 end
            }
            else
            {
                // mod Aspose.cells関連問題8の対応 夏 start
                //RldLib.CurrentReport.ReportType = "0";
                RldLib.totalLayoutData.ReportType = "0";
                // mod Aspose.cells関連問題8の対応 夏 end
                // add #10858 「##=[##データ項目」」の形式で null が出力される 高 start
                RldLib.CurrentReport.ReportType = "0";
                // add #10858 「##=[##データ項目」」の形式で null が出力される 高 end
            }
        }
        // add 単一集計帳票／複数集計帳票：帳票分類コンボボックスの追加 鄧シン  end

        private void radTotalCountHDisp_CheckedChanged(Object sender, System.EventArgs e)
        {
            if (radTotalCountHDisp.Checked == true)
            {
                RldLib.totalLayoutData.CountH = "1";
            }
        }

        private void radTotalCountH_CheckedChanged(Object sender, System.EventArgs e)
        {
            if (radTotalCountH.Checked == true)
            {
                RldLib.totalLayoutData.CountH = "0";
            }
        }

        private void radTotalCountVDisp_CheckedChanged(Object sender, System.EventArgs e)
        {
            if (radTotalCountVDisp.Checked == true)
            {
                RldLib.totalLayoutData.CountV = "1";
            }
        }

        private void radTotalCountV_CheckedChanged(Object sender, System.EventArgs e)
        {
            if (radTotalCountV.Checked == true)
            {
                RldLib.totalLayoutData.CountV = "0";
            }
        }

        private void btnChange_Click(object sender, EventArgs e)
        {
            // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 start
            if (RldLib.chkExeclDialog(2) == false)
                return;
            // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 end

            using (var wDlg = new frmEditConvList())
            {

                // 必要なパラメータをセット
                wDlg.DataPath = "表示変換";
                String[] strItemValue = { "項目値", "合　計", "平均値", "最大値", "最小値" };
                // del #10983 mst_report の未使用カラム「multi_total_defaul」を廃止 limingzhe start
                ////mod 6608 2次元帳票excel エクスポート 吉 start
                ////String[] strDisplayValue = { "○", "本", "枚", "個", "＊" };
                //String[] strDisplayValue = { "", "", "", "", "" };
                //if (!String.IsNullOrEmpty(RldLib.CurrentReport.MultiTotalDefaul))
                //{
                //    strDisplayValue = RldLib.CurrentReport.MultiTotalDefaul.Split(',');
                //}
                ////mod 6608 2次元帳票excel エクスポート 吉 end
                // del #10983 mst_report の未使用カラム「multi_total_defaul」を廃止 limingzhe end
                if (ConvertList.Count == 0)
                {
                    // mod #9662 紹介状で曜日単位の投与マトリクスが表示できない 高 start
                    //for (int i = 1; i <= 5; i++)
                    //{

                    //    DesignConvertListData designConvertList = new DesignConvertListData();
                    //    designConvertList.Code = i.ToString();
                    //    if ("項目値".Equals(strItemValue[i - 1]))
                    //    {
                    //        designConvertList.ItemValue = strItemValue[i - 1] + "　＝　";
                    //    }
                    //    else
                    //    {
                    //        designConvertList.ItemValue = strItemValue[i - 1] + "　＆　";
                    //    }

                    //    designConvertList.DisplayValue = strDisplayValue[i - 1];

                    //    // add 2023-04-11 #8417 帳票ツールでデータ変換が設定されても 鵬 start
                    //    if (i == 1 && string.IsNullOrEmpty(RldLib.totalLayoutData.Conversion) == false)
                    //    {
                    //        designConvertList.DisplayValue = RldLib.totalLayoutData.Conversion;
                    //    }
                    //    // add 2023-04-11 #8417 鵬 end

                    //    ConvertList.Add(designConvertList);
                    //}
                    DesignConvertListData designConvertList = new DesignConvertListData();
                    designConvertList.Code = "1";
                    if ("項目値".Equals(strItemValue[0]))
                    {
                        designConvertList.ItemValue = strItemValue[0] + "　＝　";
                    }
                    // del #10983 mst_report の未使用カラム「multi_total_defaul」を廃止 limingzhe start
                    //designConvertList.DisplayValue = strDisplayValue[0];
                    // del #10983 mst_report の未使用カラム「multi_total_defaul」を廃止 limingzhe end
                    if (string.IsNullOrEmpty(RldLib.totalLayoutData.Conversion) == false)
                    {
                        designConvertList.DisplayValue = RldLib.totalLayoutData.Conversion;
                    }
                    // add #10942 「表示変換」の動作が不正 limingzhe start
                    else
                    {
                        designConvertList.DisplayValue = string.Empty;
                    }
                    // add #10942 「表示変換」の動作が不正 limingzhe end

                    ConvertList.Add(designConvertList);
                    // mod #9662 紹介状で曜日単位の投与マトリクスが表示できない 高 end
                }
                wDlg.ConvertList = ConvertList;
                // ダイアログの表示を要求
                SendNotifyInfo(new RldDesignNotifyInfoRequestOpenDialogEventArgs(wDlg)
                {
                    IsAllWindowLock = true,
                    IsProtectLayoutSheet = true
                });

                // OKボタン押下時は変換リストを更新
                if (wDlg.DialogResult == DialogResult.OK)
                {
                    ConvertList = wDlg.ConvertList;
                    if (cobTotalContents.SelectedItem != null)
                    {
                        // del #10983 mst_report の未使用カラム「multi_total_defaul」を廃止 limingzhe start
                        ////add 6608 2次元帳票excel エクスポート 吉 start
                        //string multiTotalDefaul = null;
                        ////add 6608 2次元帳票excel エクスポート 吉 end
                        // del #10983 mst_report の未使用カラム「multi_total_defaul」を廃止 limingzhe end
                        // add #10942 「表示変換」の動作が不正 limingzhe start
                        bool bSetSucc = false;
                        // add #10942 「表示変換」の動作が不正 limingzhe end
                        foreach (var wData in ConvertList)
                        {
                            // mod #10942 「表示変換」の動作が不正 limingzhe start
                            // if (wData.ItemValue.IndexOf(cobTotalContents.SelectedItem.ToString()) >= 0)
                            if (wData.ItemValue.Contains(cobTotalContents.SelectedItem.ToString()))
                            // mod #10942 「表示変換」の動作が不正 limingzhe end
                            {
                                RldLib.totalLayoutData.Conversion = wData.DisplayValue;
                                // add #10942 「表示変換」の動作が不正 limingzhe start
                                bSetSucc = true;
                                // add #10942 「表示変換」の動作が不正 limingzhe end
                            }
                            // del #10983 mst_report の未使用カラム「multi_total_defaul」を廃止 limingzhe start
                            ////add 6608 2次元帳票excel エクスポート 吉 start
                            //multiTotalDefaul += wData.DisplayValue + ",";
                            ////add 6608 2次元帳票excel エクスポート 吉 end
                            // del #10983 mst_report の未使用カラム「multi_total_defaul」を廃止 limingzhe end
                        }
                        // del #10983 mst_report の未使用カラム「multi_total_defaul」を廃止 limingzhe start
                        ////add 6608 2次元帳票excel エクスポート 吉 start
                        //multiTotalDefaul = multiTotalDefaul.Substring(0, multiTotalDefaul.LastIndexOf(','));
                        //RldLib.totalLayoutData.MultiTotalDefaul = multiTotalDefaul;
                        ////add 6608 2次元帳票excel エクスポート 吉 end
                        // del #10983 mst_report の未使用カラム「multi_total_defaul」を廃止 limingzhe end
                        // add #10942 「表示変換」の動作が不正 limingzhe start
                        if (!bSetSucc)
                        {
                            ConvertList = new DesignConvertList();
                            RldLib.totalLayoutData.Conversion = String.Empty;
                        }
                        // add #10942 「表示変換」の動作が不正 limingzhe end
                    }
                }
            }
        }
        // del #9816 テンプレート設定に関する処理がデザイナと帳票生成時で重複している limingzhe start
        //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG START
        //public void syncStyle(Boolean edit = true)
        //{
        //    //del  #9870  紹介状で集計設定の保存時にエラー dongzhaolong start
        //    //if (cellEdit == false)
        //    //{
        //    //    medit = false;
        //    //    return;
        //    //}
        //    ////del #9648 【デグレ】オンライン保存の実行中Excelのウインドウがグレーで潰れる dongzhaolong start
        //    //add #9878 【デグレ】Excelの編集欄が更新されないときがある dongzhaolong start
        //    //add #9878 【デグレ】Excelの編集欄が更新されないときがある dongzhaolong start
        //    RldLib.XlHelper.XlApp.Application.ScreenUpdating = false;
        //    RldLib.XlHelper.IsHandleLayoutSheetEvent = false;
        //    //add #9878 【デグレ】Excelの編集欄が更新されないときがある dongzhaolong end
        //    //add #9878 【デグレ】Excelの編集欄が更新されないときがある dongzhaolong end
        //    ////add #9196 オンライン保存すると例外発生することがある dongzhaolong start
        //    ////del #9648 【デグレ】オンライン保存の実行中Excelのウインドウがグレーで潰れる dongzhaolong end
        //    ////del #9602 デグレ】フィルタ設定に関する不具合2点 dongzhaolong start
        //    ////RldLib.XlHelper.XlSheetLayout.IsProtected = false;
        //    ////del #9602 デグレ】フィルタ設定に関する不具合2点 dongzhaolong end
        //    ////add #9196 オンライン保存すると例外発生することがある dongzhaolong end

        //    ////del #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 START
        //    ///*Form formzd = new Form();
        //    //int width = Screen.PrimaryScreen.Bounds.Width;
        //    //int height = Screen.PrimaryScreen.Bounds.Height;
        //    //formzd.ControlBox = false;
        //    //formzd.FormBorderStyle = FormBorderStyle.FixedSingle;
        //    //formzd.Opacity = 0.5;
        //    //formzd.ShowInTaskbar = false;
        //    //formzd.StartPosition = FormStartPosition.CenterScreen;
        //    //formzd.Size = new Size(width, height);
        //    //formzd.BackColor = Color.LightGray;
        //    //formzd.Show();
        //    //LoadingHelper.ShowLoadingDialog();*/
        //    ////del #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 END

        //    //try
        //    //{

        //    //    /* if (edit == false)
        //    //     {

        //    //         return;
        //    //     }*/

        //    //    //RldLib.XlHelper.IsHandleLayoutSheetEvent = false;
        //    //    //RldLib.XlHelper.XlBook.IsProtected = false;
        //    //    var cellList = RldLib.CurrentLayoutData.DesignTempleteData.Range.Split(':');
        //    //    Microsoft.Office.Interop.Excel.Range currentRange = RldLib.XlHelper.XlSheetLayout.Worksheet.get_Range(cellList[0]);
        //    //    int firstRow = currentRange.Row;
        //    //    int firstColumn = currentRange.Column;
        //    //    int mergeRow = 1;
        //    //    int mergeColumn = 1;
        //    //    Boolean bMerged = currentRange.MergeCells;

        //    //    if (bMerged == true)
        //    //    {
        //    //        mergeRow = currentRange.MergeArea.Rows.Count;
        //    //        mergeColumn = currentRange.MergeArea.Columns.Count;
        //    //    }

        //    //    //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 START
        //    //    if (newRepeatV > oldRepeatV)
        //    //    {
        //    //        oldRepeatV = newRepeatV;
        //    //    }

        //    //    if (newRepeatH > oldRepeatH)
        //    //    {
        //    //        oldRepeatH = newRepeatH;
        //    //    }
        //    //    //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 END

        //    //    for (int i = 0; i < oldRepeatH * mergeRow; i++)
        //    //    {
        //    //        for (int j = 0; j < oldRepeatV * mergeColumn; j++)
        //    //        {
        //    //            if ((firstColumn + j) >= firstColumn + mergeColumn || (firstRow + i) >= firstRow + mergeRow)
        //    //            {
        //    //                string currentAddress = GetExcelCol(firstColumn + j - 1) + (firstRow + i).ToString();
        //    //                Microsoft.Office.Interop.Excel.Range Range = RldLib.XlHelper.XlSheetLayout.Worksheet.get_Range(currentAddress);
        //    //                if (Range.MergeCells == true)
        //    //                {
        //    //                    Range.UnMerge();
        //    //                }
        //    //                //Range.Clear();
        //    //            }

        //    //        }
        //    //    }

        //    //    //del #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 start
        //    //    /*int cellColor = Convert.ToInt32(currentRange.Font.Color);
        //    //    System.Drawing.Color oldColor = System.Drawing.ColorTranslator.FromOle(cellColor);
        //    //    currentRange.Font.Color = Color.White;*/
        //    //    //del #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 END

        //    //    if (bMerged == true)
        //    //    {
        //    //        for (int i = 0; i < newRepeatV; i++)
        //    //        {
        //    //            for (int j = 0; j < newRepeatH; j++)
        //    //            {
        //    //                if (i != 0 || j != 0)
        //    //                {
        //    //                    string nextAddress = GetExcelCol(firstColumn + j * mergeColumn - 1) + (firstRow + i * mergeRow).ToString();
        //    //                    string lastAddress = GetExcelCol(firstColumn + (j + 1) * mergeColumn - 1 - 1) + (firstRow + (i + 1) * mergeRow - 1).ToString();
        //    //                    Microsoft.Office.Interop.Excel.Range mergeRange = RldLib.XlHelper.XlSheetLayout.Worksheet.get_Range(nextAddress, lastAddress);
        //    //                    mergeRange.Clear();
        //    //                    currentRange.Copy(Type.Missing);
        //    //                    RldLib.XlHelper.XlSheetLayout.Worksheet.Range[nextAddress].PasteSpecial(Microsoft.Office.Interop.Excel.XlPasteType.xlPasteAllExceptBorders, Microsoft.Office.Interop.Excel.XlPasteSpecialOperation.xlPasteSpecialOperationNone, System.Type.Missing, System.Type.Missing);
        //    //                    RldLib.XlHelper.XlSheetLayout.Worksheet.Range[nextAddress].Cells.Value = "";
        //    //                    mergeRange.Merge();


        //    //                }
        //    //            }
        //    //        }
        //    //    }
        //    //    else
        //    //    {
        //    //        for (int i = 0; i < newRepeatV; i++)
        //    //        {
        //    //            for (int j = 0; j < newRepeatH; j++)
        //    //            {
        //    //                if (i != 0 || j != 0)
        //    //                {

        //    //                    string currentAddress = GetExcelCol(firstColumn + j - 1) + (firstRow + i).ToString();
        //    //                    //mod #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 START
        //    //                    //RldLib.XlHelper.XlSheetLayout.Worksheet.Range[currentAddress].Clear();
        //    //                    //RldLib.XlHelper.XlSheetLayout.Worksheet.Range[currentAddress].PasteSpecial(Microsoft.Office.Interop.Excel.XlPasteType.xlPasteAllExceptBorders, Microsoft.Office.Interop.Excel.XlPasteSpecialOperation.xlPasteSpecialOperationNone, System.Type.Missing, System.Type.Missing);
        //    //                    Microsoft.Office.Interop.Excel.Range Range = RldLib.XlHelper.XlSheetLayout.Worksheet.get_Range(currentAddress);
        //    //                    //Range.Clear();                            
        //    //                    currentRange.Copy(Type.Missing);
        //    //                    RldLib.XlHelper.XlSheetLayout.Worksheet.Range[currentAddress].PasteSpecial(Microsoft.Office.Interop.Excel.XlPasteType.xlPasteAllExceptBorders, Microsoft.Office.Interop.Excel.XlPasteSpecialOperation.xlPasteSpecialOperationNone, System.Type.Missing, System.Type.Missing);
        //    //                    RldLib.XlHelper.XlSheetLayout.Worksheet.Range[currentAddress].Cells.Value = "";
        //    //                    //mod #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 END

        //    //                    //add #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董昊 START
        //    //                    Range.Interior.Pattern = Microsoft.Office.Interop.Excel.Constants.xlNone;
        //    //                    Range.Interior.TintAndShade = 0;
        //    //                    Range.Interior.PatternTintAndShade = 0;
        //    //                    //add #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董昊 START
        //    //                }
        //    //            }
        //    //        }
        //    //    }

        //    //    oldRepeatH = newRepeatH;
        //    //    oldRepeatV = newRepeatV;

        //    //    //del #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 start
        //    //    //currentRange.Font.Color = oldColor;
        //    //    //del #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 end

        //    //    currentRange.Select();
        //    //}
        //    //catch (Exception)
        //    //{

        //    //    throw;

        //    //}
        //    //finally
        //    //{
        //    //    //del #9648 【デグレ】オンライン保存の実行中Excelのウインドウがグレーで潰れる dongzhaolong start
        //    RldLib.XlHelper.IsHandleLayoutSheetEvent = true;
        //    RldLib.XlHelper.XlApp.Application.ScreenUpdating = true;
        //    //    //DEL #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 START
        //    //    /*LoadingHelper.CloseLoadingDialog();
        //    //    formzd.Close();*/
        //    //    //RldLib.XlHelper.XlSheetLayout.IsProtected = true;
        //    //    //DEL #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 董 END
        //    //    ////add #9196 オンライン保存すると例外発生することがある dongzhaolong start
        //    //    //RldLib.XlHelper.XlApp.Application.ScreenUpdating = true;
        //    //    //del #9648 【デグレ】オンライン保存の実行中Excelのウインドウがグレーで潰れる dongzhaolong end
        //    //    //del #9602 デグレ】フィルタ設定に関する不具合2点 dongzhaolong start
        //    //    //RldLib.XlHelper.XlSheetLayout.IsProtected = true;
        //    //    //del #9602 デグレ】フィルタ設定に関する不具合2点 dongzhaolong end
        //    //    //add #9196 オンライン保存すると例外発生することがある dongzhaolong end

        //    //    cellEdit = false;

        //    //}
        //    //del  #9870  紹介状で集計設定の保存時にエラー dongzhaolong start
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
        //ADD #8599 帳票ツールでの繰り返し設定により発生する書式のコピー問題 DONGZHAOLONG END
        //add #9537 手入力できない箇所がある dongzhaolong start
        public void UpdateRepeatAddress()
        {
            if (RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_REFERRAL_LETTER)
            {
                DesignParamData wData = null;
                StringBuilder repeatAddtress = new StringBuilder();
                string startAddress = RldLib.CurrentLayoutData.DesignTempleteData.Range;
                int repeatCountV = int.Parse(RldLib.CurrentLayoutData.DesignTempleteData.RepeatCountV);
                int repeatCountH = int.Parse(RldLib.CurrentLayoutData.DesignTempleteData.RepeatCountH);
                Microsoft.Office.Interop.Excel.Range Range = RldLib.XlHelper.XlSheetLayout.Worksheet.get_Range(startAddress);
                repeatAddtress.Append(startAddress);
                wData = RldLib.CurrentLayoutData.FindDesignParamData(startAddress);
                if (wData != null)
                {
					//mod  #10442  【デグレ】帳票画面の紹介状の表示でシステムエラー limingzhe start
                    //edit  #9870  紹介状で集計設定の保存時にエラー dongzhaolong start
                    //for (int j = 1; j <= repeatCountH - 1; j++)
                    //{
                    //    repeatAddtress.Append(",");
                    //    using (var wXlRange = new ExcelRangeEx(RldLib.XlHelper.XlSheetLayout, Range.Offset[0, j].Address[false, false]))
                    //    {
                    //        if (wXlRange.Range.MergeCells)
                    //        {
                    //            using (var wXlMerge = new ExcelRangeEx(wXlRange.Range.MergeArea))
                    //                repeatAddtress.Append(wXlMerge.Range.Address[false, false]);
                    //        }
                    //        else
                    //        {
                    //            repeatAddtress.Append(Range.Offset[0, j].Address[false, false]);
                    //        }
                    //    }

                    //}

                    //for (int i = 1; i <= repeatCountV - 1; i++)
                    //{
                    //    repeatAddtress.Append(",");
                    //    using (var wXlRange = new ExcelRangeEx(RldLib.XlHelper.XlSheetLayout, Range.Offset[i, 0].Address[false, false]))
                    //    {
                    //        if (wXlRange.Range.MergeCells)
                    //        {
                    //            using (var wXlMerge = new ExcelRangeEx(wXlRange.Range.MergeArea))
                    //                repeatAddtress.Append(wXlMerge.Range.Address[false, false]);
                    //        }
                    //        else
                    //        {
                    //            repeatAddtress.Append(Range.Offset[i, 0].Address[false, false]);
                    //        }
                    //    }


                    //    for (int j = 1; j <= repeatCountH - 1; j++)
                    //    {
                    //        repeatAddtress.Append(",");
                    //        using (var wXlRange = new ExcelRangeEx(RldLib.XlHelper.XlSheetLayout, Range.Offset[i, j].Address[false, false]))
                    //        {
                    //            if (wXlRange.Range.MergeCells)
                    //            {
                    //                using (var wXlMerge = new ExcelRangeEx(wXlRange.Range.MergeArea))
                    //                    repeatAddtress.Append(wXlMerge.Range.Address[false, false]);
                    //            }
                    //            else
                    //            {
                    //                repeatAddtress.Append(Range.Offset[i, j].Address[false, false]);
                    //            }
                    //        }
                    //    }
                    //}
                    //edit  #9870  紹介状で集計設定の保存時にエラー dongzhaolong end
                    // add #11294 紹介状で集計部分がずれて出力される 高 start
                    if (wData.CanRepeat == false)
                    {
                        return;
                    }
                    // add #11294 紹介状で集計部分がずれて出力される 高 end
                    Microsoft.Office.Interop.Excel.Range rangeDown = Range;
                    Microsoft.Office.Interop.Excel.Range rangeRight = Range;
                    // add #11294 紹介状で集計部分がずれて出力される 高 start
                    if (RldLib.CurrentLayoutData.DesignTempleteData.DirectionData == RldConst.TempleteData.VAL_DIRECTION_N)
                    {
                        wData.repDirection = "0";
                        for (int i = 0; i < repeatCountH; i++)
                        {
                            if (i > 0)
                            {
                                rangeRight = rangeRight.Offset[0, 1];
                                if (rangeRight == null) break;
                                repeatAddtress.Append(",");
                                using (var wXlRange = new ExcelRangeEx(RldLib.XlHelper.XlSheetLayout, rangeRight.Address[false, false]))
                                {
                                    if (wXlRange.Range.MergeCells)
                                    {
                                        using (var wXlMerge = new ExcelRangeEx(wXlRange.Range.MergeArea))
                                            repeatAddtress.Append(wXlMerge.Range.Address[false, false]);
                                    }
                                    else
                                    {
                                        repeatAddtress.Append(wXlRange.Range.Address[false, false]);
                                    }
                                }
                            }
                            rangeDown = rangeRight;
                            for (int j = 1; j < repeatCountV; j++)
                            {
                                rangeDown = rangeDown.Offset[1, 0];
                                if (rangeDown == null) break;
                                repeatAddtress.Append(",");
                                using (var wXlRange = new ExcelRangeEx(RldLib.XlHelper.XlSheetLayout, rangeDown.Address[false, false]))
                                {
                                    if (wXlRange.Range.MergeCells)
                                    {
                                        using (var wXlMerge = new ExcelRangeEx(wXlRange.Range.MergeArea))
                                            repeatAddtress.Append(wXlMerge.Range.Address[false, false]);
                                    }
                                    else
                                    {
                                        repeatAddtress.Append(wXlRange.Range.Address[false, false]);
                                    }
                                }
                            }
                        }
                    }
                    else
                    {
                        wData.repDirection = "1";
                        // add #11294 紹介状で集計部分がずれて出力される 高 end
                        for (int i = 0; i < repeatCountV; i++)
                        {
                            if (i > 0)
                            {
                                rangeDown = rangeDown.Offset[1, 0];
                                if (rangeDown == null) break;
                                repeatAddtress.Append(",");
                                using (var wXlRange = new ExcelRangeEx(RldLib.XlHelper.XlSheetLayout, rangeDown.Address[false, false]))
                                {
                                    if (wXlRange.Range.MergeCells)
                                    {
                                        using (var wXlMerge = new ExcelRangeEx(wXlRange.Range.MergeArea))
                                            repeatAddtress.Append(wXlMerge.Range.Address[false, false]);
                                    }
                                    else
                                    {
                                        repeatAddtress.Append(wXlRange.Range.Address[false, false]);
                                    }
                                }
                            }
                            rangeRight = rangeDown;
                            for (int j = 1; j < repeatCountH; j++)
                            {
                                rangeRight = rangeRight.Offset[0, 1];
                                if (rangeRight == null) break;
                                repeatAddtress.Append(",");
                                using (var wXlRange = new ExcelRangeEx(RldLib.XlHelper.XlSheetLayout, rangeRight.Address[false, false]))
                                {
                                    if (wXlRange.Range.MergeCells)
                                    {
                                        using (var wXlMerge = new ExcelRangeEx(wXlRange.Range.MergeArea))
                                            repeatAddtress.Append(wXlMerge.Range.Address[false, false]);
                                    }
                                    else
                                    {
                                        repeatAddtress.Append(wXlRange.Range.Address[false, false]);
                                    }
                                }
                            }
                        }
                    }
					//mod  #10442  【デグレ】帳票画面の紹介状の表示でシステムエラー limingzhe end
                    wData.RepeatAddress = repeatAddtress.ToString();
                }
            
            }
        }
        //add #9537 手入力できない箇所がある dongzhaolong end

        // add #10858 「##=[##データ項目」」の形式で null が出力される 高 start
        private void cobTotalUnitDate_TextUpdate(object sender, EventArgs e)
        {
            if(string.IsNullOrEmpty(cobTotalUnitDate.Text))
            {
                // mod #11011 集計内訳タブ仕様変更 高 start
                // cobTotalUnitDate.SelectedIndex = -1;
                cobTotalUnitDate.SelectedIndex = 0;
                // mod #11011 集計内訳タブ仕様変更 高 end
                RldLib.totalLayoutData.UnitDate = string.Empty;
            }

        }

        private void cobTotalContents_TextUpdate(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(cobTotalContents.Text))
            {
                // mod #11011 集計内訳タブ仕様変更 高 start
                // cobTotalContents.SelectedIndex = -1;
                cobTotalContents.SelectedIndex = 0;
                // mod #11011 集計内訳タブ仕様変更 高 end
                RldLib.totalLayoutData.Contents = string.Empty;

                // add #11973 日常点検一覧帳票が正常に出せない 高 start
                cobTotalContentsType.SelectedIndex = 0;
                cobTotalContentsType.Text = string.Empty;
                RldLib.totalLayoutData.ContentsType = string.Empty;
                cobTotalContentsType.Visible = false;
                // add #11973 日常点検一覧帳票が正常に出せない 高 end

                // add #10942 「表示変換」の動作が不正 limingzhe start
                btnChange.Enabled = false;
                ConvertList = new DesignConvertList();
                RldLib.totalLayoutData.Conversion = string.Empty;
                // add #10942 「表示変換」の動作が不正 limingzhe end
            }
        }

        private void cobTotalReportType_TextUpdate(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(cobTotalReportType.Text))
            {
                cobTotalReportType.SelectedIndex = 0;
                RldLib.totalLayoutData.ReportType = "0";
                RldLib.CurrentReport.ReportType = "0";
            }
        }

        // add #10858 「##=[##データ項目」」の形式で null が出力される 高 end

        // add #11011 集計内訳タブ仕様変更 高 start
        private void btnTotalUnitH_Click(object sender, EventArgs e)
        {
            // 横の単位
            totalUnitSearch(1);
        }

        private void btnTotalUnitV_Click(object sender, EventArgs e)
        {
            // 縦の単位
            totalUnitSearch(2);
        }

        // totalUnitFlag = 1    横の単位
        // totalUnitFlag = 2    縦の単位
        private void totalUnitSearch(int totalUnitFlag)
        {
            // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 start
            if (RldLib.chkExeclDialog(2) == false)
                return;
            // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 end

            // 横の単位/縦の単位選択画面
            using (var wDlg = new frmSelectTotalUnit())
            {
                // 必要なパラメータをセット
                wDlg.totalUnitFlag = totalUnitFlag;
                wDlg.totalUnitDic.Clear();
                // add #11056 集計の「単位セル繰返し回数」と集計の「繰返回数」が縦横どちらか不一致のときエラーとならない 高 start
                List<String> retTotalUnit = null;

                if (totalUnitFlag == 1)   // 横の単位の場所、 get value of 縦の単位
                {
                    if (string.IsNullOrEmpty(RldLib.totalLayoutData.UnitHAddress) == false)
                        retTotalUnit = new List<string>(RldLib.totalLayoutData.UnitHAddress.Trim().Split(','));
                }
                else    // 縦の単位位の場所、get value of 横の単位
                {
                    if (string.IsNullOrEmpty(RldLib.totalLayoutData.UnitVAddress) == false)
                        retTotalUnit = new List<string>(RldLib.totalLayoutData.UnitVAddress.Trim().Split(','));
                }
                // add #11056 集計の「単位セル繰返し回数」と集計の「繰返回数」が縦横どちらか不一致のときエラーとならない 高 end
                if (!String.IsNullOrEmpty(RldLib.CurrentLayoutData.DesignTempleteData.Range))
                {
                    Microsoft.Office.Interop.Excel.Range range1 = RldLib.XlHelper.XlSheetLayout.Worksheet.get_Range(RldLib.CurrentLayoutData.DesignTempleteData.Range);
                    foreach (var wData in RldLib.CurrentLayoutData.DesignParamList)
                    {
                        if (string.IsNullOrEmpty(wData.DataPath) == false && wData.DataPath.StartsWith(RldConst.PATH_HEADER))
                        {
                                
                            Microsoft.Office.Interop.Excel.Range cell1 = RldLib.XlHelper.XlSheetLayout.Worksheet.get_Range(wData.CellAddress);
                            Microsoft.Office.Interop.Excel.Range intersectRange = RldLib.XlHelper.XlApp.Application.Intersect(range1, cell1);
                            if(intersectRange == null)
                            {
                                // mod #11056 集計の「単位セル繰返し回数」と集計の「繰返回数」が縦横どちらか不一致のときエラーとならない 高 start
                                if(retTotalUnit != null && retTotalUnit.Count > 0)
                                {
                                    if(retTotalUnit.Contains(wData.CellAddress) == false)
                                    {
                                        wDlg.totalUnitDic.Add(wData.CellAddress, wData.DataPath);
                                    }
                                }
                                else
                                {
                                    wDlg.totalUnitDic.Add(wData.CellAddress, wData.DataPath);
                                }
                                // wDlg.totalUnitDic.Add(wData.CellAddress, wData.DataPath);
                                // mod #11056 集計の「単位セル繰返し回数」と集計の「繰返回数」が縦横どちらか不一致のときエラーとならない 高 end
                            }
                        }
                    }
                }
                if (totalUnitFlag == 1)   // 横の単位
                {
                    wDlg.retTotalUnit = new List<string>(RldLib.totalLayoutData.UnitVAddress.Trim().Split(','));
                }
                else    // 縦の単位
                {
                    wDlg.retTotalUnit = new List<string>(RldLib.totalLayoutData.UnitHAddress.Trim().Split(','));
                }

                // ダイアログの表示を要求
                SendNotifyInfo(new RldDesignNotifyInfoRequestOpenDialogEventArgs(wDlg)
                {
                    IsAllWindowLock = true,
                    IsProtectLayoutSheet = true
                });

                if (wDlg.DialogResult == DialogResult.OK)
                {
                    string totalUnit = string.Empty;
                    string totalUnitAddress = string.Empty;
                    if (wDlg.retTotalUnit.Count > 0)
                    {
                        for (int i = 0; i < wDlg.retTotalUnit.Count; i++)
                        {
                            if (i == 0)
                            {
                                totalUnit = wDlg.totalUnitDic[wDlg.retTotalUnit[0]];
                                totalUnitAddress = wDlg.retTotalUnit[0];
                            }
                            else
                            {
                                totalUnit += "," + wDlg.totalUnitDic[wDlg.retTotalUnit[i]];
                                totalUnitAddress += "," + wDlg.retTotalUnit[i];
                            }
                        }
                    }
                    if (totalUnitFlag == 1)   // 横の単位
                    {
                        // add #12274 集計使用項目と同じグループ名を禁止するエラーの頻度が高くなりすぎる 高 start
                        unitChangeGroupName(RldLib.totalLayoutData.UnitVAddress, totalUnitAddress);
                        // add #12274 集計使用項目と同じグループ名を禁止するエラーの頻度が高くなりすぎる 高 end
                        // mod #11973 日常点検一覧帳票が正常に出せない 高 start
                        RldLib.totalLayoutData.UnitVAddress = totalUnitAddress;
                        txtTotalUnitV.Text = totalUnit;
                        //RldLib.totalLayoutData.UnitVAddress = totalUnitAddress;
                        // mod #11973 日常点検一覧帳票が正常に出せない 高 end
                    }
                    else    // 縦の単位
                    {
                        // add #12274 集計使用項目と同じグループ名を禁止するエラーの頻度が高くなりすぎる 高 start
                        unitChangeGroupName(RldLib.totalLayoutData.UnitHAddress, totalUnitAddress);
                        // add #12274 集計使用項目と同じグループ名を禁止するエラーの頻度が高くなりすぎる 高 end
                        // mod #11973 日常点検一覧帳票が正常に出せない 高 start
                        RldLib.totalLayoutData.UnitHAddress = totalUnitAddress;
                        txtTotalUnitH.Text = totalUnit;
                        //RldLib.totalLayoutData.UnitHAddress = totalUnitAddress;
                        // mod #11973 日常点検一覧帳票が正常に出せない 高 end
                    }
                    // add #11973 日常点検一覧帳票が正常に出せない 高 start
                    totalUnitDateVisible();
                    // add #11973 日常点検一覧帳票が正常に出せない 高 end
                }
            }
        }
        // add #11011 集計内訳タブ仕様変更 高 end
        // add #11973 日常点検一覧帳票が正常に出せない 高 start
        // 集計内訳の「横の単位」にDateTime型の項目が含まれていないときは「年月日曜日」の選択は隠す
        private void totalUnitDateVisible()
        {
            // 複数集計
            if (RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_MULTI_TOTAL)
            {
                // テンプレート繰返し有無値 - 有り
                if (RldLib.CurrentLayoutData.DesignSettingData.HasTemplete == RldConst.SettingData.VAL_HAS_TEMPLETE_YES)
                {
                    List<String> retTotalUnitV = null;      // 横の単位
                    bool bExist = false;

                    // 横の単位
                    if (string.IsNullOrEmpty(RldLib.totalLayoutData.UnitVAddress) == false)
                    {
                        retTotalUnitV = new List<string>(RldLib.totalLayoutData.UnitVAddress.Trim().Split(','));
                        foreach (var wData in RldLib.CurrentLayoutData.DesignParamList)
                        {
                            if (retTotalUnitV != null && retTotalUnitV.Contains(wData.CellAddress) == true)
                            {
                                if (string.Compare(wData.DataType, RldConst.ParamData.VAL_DATATYPE_DATETIME, true) == 0)
                                {
                                    // 集計内訳の「横の単位」にDateTime型の項目が含まれる
                                    bExist = true;
                                    break;
                                }
                            }
                        }
                    }

                    // 集計内訳の「横の単位」にDateTime型の項目が含まれていないときは
                    if (bExist == false)
                    {
                        cobTotalUnitDate.SelectedIndex = 0;
                        cobTotalUnitDate.Text = string.Empty;
                        RldLib.totalLayoutData.UnitDate = string.Empty;
                        cobTotalUnitDate.Visible = false;
                        RldLib.totalLayoutData.UnitDateVisible = false;
                    }
                    else
                    {
                        cobTotalUnitDate.Visible = true;
                        RldLib.totalLayoutData.UnitDateVisible = true;
                    }
                }
            }
        }

        // add #11973 日常点検一覧帳票が正常に出せない 高 start
        private void cobTotalContentsType_SelectIndexChanged(object sender, EventArgs e)
        {
            RldLib.totalLayoutData.ContentsType = cobTotalContentsType.SelectedItem.ToString();
        }

        private void cobTotalContentsType_TextUpdate(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(cobTotalContentsType.Text))
            {
                cobTotalContentsType.SelectedIndex = 0;
                RldLib.totalLayoutData.ContentsType = cobTotalContentsType.SelectedItem.ToString();
            }
        }
        // add #11973 日常点検一覧帳票が正常に出せない 高 end
        // add #11973 日常点検一覧帳票が正常に出せない 高 end

        // add #12274 集計使用項目と同じグループ名を禁止するエラーの頻度が高くなりすぎる 高 start
        // 強制的にグループ名を以下に変更する: 集計単位
        // unitBefortAddress: Befort Address of 横の単位/縦の単位選択画面
        // unitAfterAddress: After Address of 横の単位/縦の単位選択画面
        private void unitChangeGroupName(string unitBefortAddress, string unitAfterAddress)
        {
            unitClearGroupName(unitBefortAddress, unitAfterAddress);
            unitSetGroupName(unitAfterAddress);
        }

        // reset 集計使用項目のグループ名, グループ名: 各項目のデフォルト値に変更する
        // unitBefortAddress: Befort Address of 横の単位/縦の単位選択画面
        // unitAfterAddress: After Address of 横の単位/縦の単位選択画面
        private void unitClearGroupName(string unitBefortAddress, string unitAfterAddress)
        {
            List<String> lstUnitBefortAddress = null;
            List<String> lstUnitAfterAddress = null;
            bool bRemove = false;

            if (string.IsNullOrEmpty(unitBefortAddress) == false)
            {
                lstUnitBefortAddress = new List<string>(unitBefortAddress.Trim().Split(','));
            }
            else
            {
                return;
            }

            if (string.IsNullOrEmpty(unitAfterAddress) == false)
            {
                lstUnitAfterAddress = new List<string>(unitAfterAddress.Trim().Split(','));
            }

            foreach (var wData in RldLib.CurrentLayoutData.DesignParamList)
            {
                bRemove = false;

                // data is in Befort 横の単位/縦の単位 and 繰返し可能項目の場合
                if (lstUnitBefortAddress.Contains(wData.CellAddress) == true && wData.GroupName.Equals(GROUP_NAME_UNIT) && wData.CanRepeat)
                {
                    if (lstUnitAfterAddress != null && lstUnitAfterAddress.Count() > 0)
                    {
                        // data is not in After 横の単位/縦の単位
                        if (lstUnitAfterAddress.Contains(wData.CellAddress) == false)
                        {
                            bRemove = true;
                        }
                    }
                    else
                    {
                        bRemove = true;
                    }
                }

                if(bRemove)
                {
                    if (RldLib.CurrentLayoutData.RemoveNonReferGroupData(wData))
                    {
                        wData.GroupName = String.Format("{0}{1}{2}", wData.DataCategory, RldConst.PATH_SPLIT, wData.DataClass);
                        // グルプが存在するか確認し無ければ追加する
                        RldLib.CurrentLayoutData.CreateAndAddDesignGroupData(wData);
                    }
                }
            }
        }

        // 強制的にグループ名を以下に変更する: 集計単位
        // unitAfterAddress: After Address of 横の単位/縦の単位選択画面
        private void unitSetGroupName(string unitAfterAddress)
        {
            List<String> lstUnitAfterAddress = null;

            if (string.IsNullOrEmpty(unitAfterAddress) == false)
            {
                lstUnitAfterAddress = new List<string>(unitAfterAddress.Trim().Split(','));
            }
            else
            {
                return;
            }

            foreach (var wData in RldLib.CurrentLayoutData.DesignParamList)
            {
                // data is in After 横の単位/縦の単位
                if (lstUnitAfterAddress.Contains(wData.CellAddress) == true)
                {
                    // 繰返し可能項目の場合
                    if (wData.GroupName.Equals(GROUP_NAME_UNIT) == false && wData.CanRepeat)
                    {
                        RldLib.CurrentLayoutData.RemoveNonReferGroupData(wData);

                        wData.GroupName = GROUP_NAME_UNIT;
                        // グルプが存在するか確認し無ければ追加する
                        RldLib.CurrentLayoutData.CreateAndAddDesignGroupData(wData);
                    }
                }

            }
        }
        // add #12274 集計使用項目と同じグループ名を禁止するエラーの頻度が高くなりすぎる 高 end
    }
}
