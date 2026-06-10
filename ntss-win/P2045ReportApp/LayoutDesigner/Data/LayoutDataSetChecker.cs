using LayoutDesigner.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Excel = Microsoft.Office.Interop.Excel;

namespace LayoutDesigner
{
    /// <summary>
    /// レイアウトデータチェッククラス
    /// </summary>
    public class LayoutDataSetChecker : IRldDesignSendOnlyColleague
    {
        #region メンバイベント定義

        public event EventHandler<RldDesignNotifyInfoEventArgs> NotifyInfo;

        #endregion

        // add 2020-10-19 FNSI-改修 帳票に使用できるExcel関数 夏 start
        //mod 6720 EXCEL関数で使用できないものがある 吉 start
        //private String[] functionNames = {"SUM","MOD","IF","OR","AND","LEFT","RIGHT","MID","SUBSTITUTE","COUTNIF",
        // "SUMIF","VALUE","VLOOKUP","HLOOKUP","INT","ABS","ROUNDUP","ROUNDDOWN","ROUND","VBRColor"};

        //mod 8559 動作に関する指摘２ 董兆龙 start
        // mod #12621 ##=の計算式が保存できないことがある、また、プレビュー値が異常 高 start
        //private String[] functionNames = {"SUM","MOD","IF","OR","AND","LEFT","RIGHT","MID","SUBSTITUTE","COUNTIF",
        //                                  "SUMIF","VALUE","VLOOKUP","HLOOKUP","INT","ABS","ROUNDUP","ROUNDDOWN","ROUND","VBRColor","+","-","*","/"};
        private String[] functionNames = {
                                            "SUM", "SUMIF", "SUMPRODUCT",
                                            "AVERAGE", "AVERAGEIF",
                                            "COUNT", "COUNTA", "COUNTIF",
                                            "MAX", "MIN",
                                            "ABS", "INT", "ROUND", "ROUNDUP", "ROUNDDOWN", "MOD",
                                            "IF", "IFERROR", "AND", "OR", "NOT",
                                            "LEFT", "RIGHT", "MID", "LEN", "TRIM", "CONCATENATE", "SUBSTITUTE",
                                            "VALUE", "TEXT",
                                            "VLOOKUP", "HLOOKUP", "MATCH", "INDEX",
                                            "DATE", "DAY", "MONTH", "YEAR", "TODAY", "NOW",
                                            "VBRColor",
                                            "+", "-", "*", "/"
};
        // mod #12621 ##=の計算式が保存できないことがある、また、プレビュー値が異常 高 end
        //mod 8559 動作に関する指摘２ 董兆龙 end
        //mod 6720 EXCEL関数で使用できないものがある 吉 end
        // add 2020-10-19 FNSI-改修 帳票に使用できるExcel関数 夏 end

        #region 生成と破棄

        /// <summary>
        /// チェック対象のレイアウトデータと Excel ヘルパークラスを指定して、レイアウトデータチェッククラスの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aDataSet"></param>
        /// <param name="aXlHelper"></param>
        public LayoutDataSetChecker(LayoutDataSet aDataSet, RldExcelHelper aXlHelper)
        {
            this.DataSet = aDataSet;
            this.XlHelper = aXlHelper;
        }

        #endregion

        #region メンバプロパティ定義

        private LayoutDataSet DataSet { get; set; } = null;

        private RldExcelHelper XlHelper { get; set; } = null;

        #endregion

        #region メンバ関数定義(公開)

        /// <summary>
        /// データの整合性を確認します。
        /// </summary>
        /// <returns></returns>
        public Boolean CheckConsistency()
        {
            Boolean wRet = false;

            try
            {
                // add #10858 「##=[##データ項目」」の形式で null が出力される 高 start
                if (!this.CheckConsistencyTotalData()) return false;
                // add #10858 「##=[##データ項目」」の形式で null が出力される 高 end
                // パラメータ編集データをチェック
                if (!this.CheckConsistencyParamData()) return false;

                // グループデータチェック
                if (!this.CheckConsistencyGroupData()) return false;

                // テンプレート繰り返しデータチェック
                if (this.DataSet.DesignSettingData.IsSupportTempleteRepeat)
                    if (!this.CheckConsistencyTempleteData()) return false;

                // add 2021-05-13 #4891:"Bitmap"の文字がプレビューの上に表示されるの修正 趙 start
                // 帳票レイアウトに画像を確認
                // if (!this.CheckShape()) return false;
                // add 2021-05-13 #4891:"Bitmap"の文字がプレビューの上に表示されるの修正 趙 end

                // ここまでくればOK
                wRet = true;
            }
            catch (Exception ex)
            {
                this.SendNotifyInfo(new RldDesignNotifyInfoRequestRecordExceptionEventArgs(ex, true));
            }

            return wRet;
        }

        #endregion

        #region メンバ関数定義(非公開)

        /// <summary>
        /// 通知メッセージを送信します。
        /// </summary>
        /// <param name="e"></param>
        private void SendNotifyInfo(RldDesignNotifyInfoEventArgs e) => this.NotifyInfo?.Invoke(this, e);

        // add 2021-05-13 #4891:"Bitmap"の文字がプレビューの上に表示されるの修正 趙 start
        /// <summary>
        /// 帳票レイアウトに画像を確認します。
        /// </summary>
        /// <returns></returns>
        private Boolean CheckShape()
        {
            const String MSG_TITLE = @"帳票レイアウトの画像を確認してください";
            try
            {
                // 現在のレイアウトシート上の画像ファイル数を取得
                Int32 wImgCount = 0;

                using (var wXlShapes = new ExcelShapesEx(RldLib.XlHelper.XlSheetLayout))
                {
                    wImgCount = wXlShapes.Shapes.Count;
                }

                if (wImgCount != 0)
                {
                    if (this.ShowMsgBox(String.Format(@"帳票レイアウトに画像があります。{0}保存してもよろしいですか？", System.Environment.NewLine),
                        MSG_TITLE, System.Windows.Forms.MessageBoxButtons.YesNo, System.Windows.Forms.MessageBoxIcon.Question) != System.Windows.Forms.DialogResult.Yes)
                    {
                        using (var wXlShapes = new ExcelShapesEx(RldLib.XlHelper.XlSheetLayout))
                        {
                            wXlShapes.Shapes.SelectAll();
                        }

                        return false;
                    }
                }
            }
            catch (Exception ex)
            {
                throw;
            }

            // ここまでくればOK
            return true;
        }
        // add 2021-05-13 #4891:"Bitmap"の文字がプレビューの上に表示されるの修正 趙 end

        // add #10858 「##=[##データ項目」」の形式で null が出力される 高 start
        /// <summary>
        /// Totalデータの整合性を確認します。
        /// </summary>
        /// <returns></returns>
        private Boolean CheckConsistencyTotalData()
        {
            try
            {
                bool bError = false;

                if ( RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_ONE_TOTAL
                  || RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_MULTI_TOTAL
                  || (RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_REFERRAL_LETTER && "1".Equals(RldLib.totalLayoutData.ReportType)))
                {
                    if (RldLib.CurrentLayoutData.DesignSettingData.HasTemplete == RldConst.SettingData.VAL_HAS_TEMPLETE_NO)
                    {
                        if (!string.IsNullOrEmpty(RldLib.totalLayoutData.UnitV))            // 横の集計単位
                        {
                            bError = true;
                        }
                        else if (!string.IsNullOrEmpty(RldLib.totalLayoutData.UnitH))       // 縦の集計単位
                        {
                            bError = true;
                        }
                        // mod #11973 日常点検一覧帳票が正常に出せない 高 start
                        //else if (!string.IsNullOrEmpty(RldLib.totalLayoutData.UnitDate))    // 集計単位日付
                        else if (RldLib.totalLayoutData.UnitDateVisible == true && !string.IsNullOrEmpty(RldLib.totalLayoutData.UnitDate))
                        // mod #11973 日常点検一覧帳票が正常に出せない 高 end
                        {
                            bError = true;
                        }
                        else if (!string.IsNullOrEmpty(RldLib.totalLayoutData.Contents))    // 表示内容
                        {
                            bError = true;
                        }

                        // add #11011 集計内訳タブ仕様変更 高 start
                        // check 横の集計単位address
                        if (bError == false)
                        {
                            if (!string.IsNullOrEmpty(RldLib.totalLayoutData.UnitVAddress))
                            {
                                bError = true;
                            }
                        }
                        // check 縦の集計単位address
                        if (bError == false)
                        {
                            if (!string.IsNullOrEmpty(RldLib.totalLayoutData.UnitHAddress))
                            {
                                bError = true;
                            }
                        }
                        // add #11011 集計内訳タブ仕様変更 高 end

                        if (bError)
                        {
                            this.ShowMsgBox(
                                            "集計設定を行う場合は、集計内容セル、横の単位、縦の単位、表示内容を全て設定してください。",
                                            "集計設定が不十分", System.Windows.Forms.MessageBoxButtons.OK, System.Windows.Forms.MessageBoxIcon.Exclamation);
                            return false;

                        }
                    }
                    else
                    {
                        if (string.IsNullOrEmpty(RldLib.totalLayoutData.UnitV))             // 横の集計単位
                        {
                            bError = true;
                        }
                        else if (string.IsNullOrEmpty(RldLib.totalLayoutData.UnitH))        // 縦の集計単位
                        {
                            bError = true;
                        }
                        // mod #11973 日常点検一覧帳票が正常に出せない 高 start
                        // else if (string.IsNullOrEmpty(RldLib.totalLayoutData.UnitDate))    // 集計単位日付
                        else if (RldLib.totalLayoutData.UnitDateVisible == true && string.IsNullOrEmpty(RldLib.totalLayoutData.UnitDate))
                        // mod #11973 日常点検一覧帳票が正常に出せない 高 start
                        {
                            bError = true;
                        }
                        else if (string.IsNullOrEmpty(RldLib.totalLayoutData.Contents))    // 表示内容
                        {
                            bError = true;
                        }
                        // add #11011 集計内訳タブ仕様変更 高 start
                        // del #11056 集計の「単位セル繰返し回数」と集計の「繰返回数」が縦横どちらか不一致のときエラーとならない 高 start
                        //int cnt1, cnt2;
                        //// check 横の集計単位 count == address count
                        //if (bError == false)
                        //{
                        //    cnt1 = RldLib.totalLayoutData.UnitV.Count(ch => ch == ',');
                        //    cnt2 = RldLib.totalLayoutData.UnitVAddress.Count(ch => ch == ',');
                        //    if(cnt1 != cnt2)
                        //    {
                        //        bError = true;
                        //    }
                        //}
                        //// check 縦の集計単位 count == address count
                        //if (bError == false)
                        //{
                        //    cnt1 = RldLib.totalLayoutData.UnitH.Count(ch => ch == ',');
                        //    cnt2 = RldLib.totalLayoutData.UnitHAddress.Count(ch => ch == ',');
                        //    if (cnt1 != cnt2)
                        //    {
                        //        bError = true;
                        //    }
                        //}
                        // del #11056 集計の「単位セル繰返し回数」と集計の「繰返回数」が縦横どちらか不一致のときエラーとならない 高 end
                        // add #11011 集計内訳タブ仕様変更 高 end

                        if (bError)
                        {
                            this.ShowMsgBox(
                                        "集計設定を行う場合は、集計内容セル、横の単位、縦の単位、表示内容を全て設定してください。",
                                        "集計設定が不十分", System.Windows.Forms.MessageBoxButtons.OK, System.Windows.Forms.MessageBoxIcon.Exclamation);
                            
                            return false;

                        }
                        // add #11011 集計内訳タブ仕様変更 高 start
                        // check 横の集計単位address valid
                        bError = false;

                        if (bError == false)
                        {
                            bool bExist = false;
                            foreach (var wData in RldLib.CurrentLayoutData.DesignParamList)
                            {
                                if (RldLib.CurrentLayoutData.DesignTempleteData.Range.Equals(wData.CellAddress))
                                {
                                    bExist = true;
                                    break;
                                }
                            }
                            if (bExist == false)
                                bError = true;
                        }
                        if (bError == false)
                        {
                            List<string> totalTotalList = new List<string>(RldLib.totalLayoutData.UnitHAddress.Trim().Split(','));
                            bool bExist = false;
                            foreach (var wAddress in totalTotalList)
                            {
                                bExist = false;
                                foreach (var wData in RldLib.CurrentLayoutData.DesignParamList)
                                {
                                    if (wAddress.Equals(wData.CellAddress))
                                    {
                                        bExist = true;
                                        break;
                                    }
                                }
                                if (bExist == false)
                                    break;
                            }
                            if (bExist == false)
                                bError = true;
                        }
                        // check 縦の集計単位address valid
                        if (bError == false)
                        {
                            List<string> totalTotalList = new List<string>(RldLib.totalLayoutData.UnitVAddress.Trim().Split(','));
                            bool bExist = false;
                            foreach (var wAddress in totalTotalList)
                            {
                                bExist = false;
                                foreach (var wData in RldLib.CurrentLayoutData.DesignParamList)
                                {
                                    if (wAddress.Equals(wData.CellAddress))
                                    {
                                        bExist = true;
                                        break;
                                    }
                                }
                                if (bExist == false)
                                    break;
                            }
                            if (bExist == false)
                                bError = true;
                        }

                        if (bError)
                        {
                            this.ShowMsgBox(
                                        "集計設定に指定されたデータ項目が帳票内に見つかりません。",
                                        "集計設定が不十分", System.Windows.Forms.MessageBoxButtons.OK, System.Windows.Forms.MessageBoxIcon.Exclamation);
                            return false;
                        }
                        // add #11011 集計内訳タブ仕様変更 高 end
                    }
                }

                // add #11056 集計の「単位セル繰返し回数」と集計の「繰返回数」が縦横どちらか不一致のときエラーとならない 高 start
                // 単一集計,複数集計,集計紹介状
                if (RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_ONE_TOTAL
                 || RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_MULTI_TOTAL
                 || (RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_REFERRAL_LETTER && "1".Equals(RldLib.totalLayoutData.ReportType)))
                {
                    // テンプレート繰返し有無値 - 有り
                    if (RldLib.CurrentLayoutData.DesignSettingData.HasTemplete == RldConst.SettingData.VAL_HAS_TEMPLETE_YES)
                    {
                        List<String> retTotalUnitH = null;      // 縦の単位
                        List<String> retTotalUnitV = null;      // 横の単位
                        string repeatCountH = string.Empty;     // 縦の単位
                        string repeatCountV = string.Empty;     // 横の単位

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

                        if (bError == false)
                        {
                            foreach (var wData in RldLib.CurrentLayoutData.DesignParamList)
                            {
                                // 横の単位
                                if (retTotalUnitV != null && retTotalUnitV.Contains(wData.CellAddress) == true)
                                {
                                    if (string.IsNullOrEmpty(repeatCountV))
                                    {
                                        if (string.IsNullOrEmpty(wData.RepeatCount))
                                            repeatCountV = "1";
                                        else
                                            repeatCountV = wData.RepeatCount;
                                    }
                                    else
                                    {
                                        if (string.IsNullOrEmpty(wData.RepeatCount))
                                        {
                                            if (repeatCountV.Equals("1") == false)
                                            {
                                                bError = true;
                                                break;
                                            }
                                        }
                                        else if (repeatCountV.Equals(wData.RepeatCount) == false)
                                        {
                                            bError = true;
                                            break;
                                        }
                                    }
                                }
                                // 縦の単位
                                if (retTotalUnitH != null && retTotalUnitH.Contains(wData.CellAddress) == true)
                                {
                                    if (string.IsNullOrEmpty(repeatCountH))
                                    {
                                        if(string.IsNullOrEmpty(wData.RepeatCount))
                                            repeatCountH = "1";
                                        else
                                            repeatCountH = wData.RepeatCount;
                                    }
                                    else
                                    {
                                        if (string.IsNullOrEmpty(wData.RepeatCount))
                                        {
                                            if (repeatCountH.Equals("1") == false)
                                            {
                                                bError = true;
                                                break;
                                            }
                                        }
                                        else if (repeatCountH.Equals(wData.RepeatCount) == false)
                                        {
                                            bError = true;
                                            break;
                                        }
                                    }
                                }
                            }
                            if(bError == true)
                            {
                                // mod #12645 集計設定不十分メッセージの誤字 高 start
                                this.ShowMsgBox(
                                         "縦、または横の単位に設定した複数のデータ項目間で繰返回数が一致していません。",
                                         "集計設定が不十分", System.Windows.Forms.MessageBoxButtons.OK, System.Windows.Forms.MessageBoxIcon.Exclamation);
                                // mod #12645 集計設定不十分メッセージの誤字 高 end
                                return false;
                            }
                        }
                        if (bError == false)
                        {
                            // 横の単位
                            if (string.IsNullOrEmpty(repeatCountV))
                            {
                                if (RldLib.CurrentLayoutData.DesignTempleteData.RepeatCountH.Equals("1") == false)
                                {
                                    bError = true;
                                }
                            }
                            else if(RldLib.CurrentLayoutData.DesignTempleteData.RepeatCountH.Equals(repeatCountV) == false)
                            {
                                bError = true;
                            }
                            // 縦の単位
                            if (string.IsNullOrEmpty(repeatCountH))
                            {
                                if (RldLib.CurrentLayoutData.DesignTempleteData.RepeatCountV.Equals("1") == false)
                                {
                                    bError = true;
                                }
                            }
                            else if (RldLib.CurrentLayoutData.DesignTempleteData.RepeatCountV.Equals(repeatCountH) == false)
                            {
                                bError = true;
                            }

                            if (bError == true)
                            {
                                this.ShowMsgBox(
                                         "縦・横の単位に指定したデータ項目の繰返回数と、集計内訳の繰返回数は一致させなければなりません。",
                                         "集計設定が不十分", System.Windows.Forms.MessageBoxButtons.OK, System.Windows.Forms.MessageBoxIcon.Exclamation);
                                return false;
                            }
                        }
                    }
                }
                // add #11056 集計の「単位セル繰返し回数」と集計の「繰返回数」が縦横どちらか不一致のときエラーとならない 高 end

                // add #11973 日常点検一覧帳票が正常に出せない 高 start
                // 単一集計,複数集計,集計紹介状
                if (RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_ONE_TOTAL
                 || RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_MULTI_TOTAL
                 || (RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_REFERRAL_LETTER && "1".Equals(RldLib.totalLayoutData.ReportType)))
                {
                    // テンプレート繰返し有無値 - 有り
                    if (RldLib.CurrentLayoutData.DesignSettingData.HasTemplete == RldConst.SettingData.VAL_HAS_TEMPLETE_YES)
                    {
                        string unitTotalH = "unit_H_total";     // 横の合計
                        string unitTotalV = "unit_V_total";     // 縦の合計

                        if (bError == false)
                        {
                            foreach (var wData in RldLib.CurrentLayoutData.DesignParamList)
                            {
                                // 横の合計
                                // del #11973 日常点検一覧帳票が正常に出せない 高 start
                                //if (RldLib.totalLayoutData.CountV == "1")
                                // del #11973 日常点検一覧帳票が正常に出せない 高 end
                                {
                                    if (unitTotalV.Equals(wData.DataCode) == true)
                                    {
                                        if (string.IsNullOrEmpty(wData.RepeatCount))
                                        {
                                            if (RldLib.CurrentLayoutData.DesignTempleteData.RepeatCountH.Equals("1") == false)
                                            {
                                                bError = true;
                                                break;
                                            }
                                        }
                                        // 縦の合計データ項目の繰返し回数と集計の横繰返し回数一致しない場合
                                        else if (RldLib.CurrentLayoutData.DesignTempleteData.RepeatCountH.Equals(wData.RepeatCount) == false)
                                        {
                                            bError = true;
                                            break;
                                        }
                                    }
                                }
                                // 縦の合計
                                // del #11973 日常点検一覧帳票が正常に出せない 高 start
                                //if (RldLib.totalLayoutData.CountH == "1")
                                // del #11973 日常点検一覧帳票が正常に出せない 高 end
                                {
                                    if (unitTotalH.Equals(wData.DataCode) == true)
                                    {
                                        if (string.IsNullOrEmpty(wData.RepeatCount))
                                        {
                                            if (RldLib.CurrentLayoutData.DesignTempleteData.RepeatCountV.Equals("1") == false)
                                            {
                                                bError = true;
                                                break;
                                            }
                                        }
                                        // 横の合計データ項目の繰返し回数と集計の縦繰返し回数一致しない場合
                                        else if (RldLib.CurrentLayoutData.DesignTempleteData.RepeatCountV.Equals(wData.RepeatCount) == false)
                                        {
                                            bError = true;
                                            break;
                                        }
                                    }
                                }
                            }
                            if (bError == true)
                            {
                                this.ShowMsgBox(
                                         "縦・横の合計データ項目の繰返回数と、集計内訳の繰返回数は一致させなければなりません。",
                                         "集計設定が不十分", System.Windows.Forms.MessageBoxButtons.OK, System.Windows.Forms.MessageBoxIcon.Exclamation);
                                return false;
                            }
                        }
                    }
                }
                // add #11973 日常点検一覧帳票が正常に出せない 高 end

                // add #10546 複数集計出力時にサーバが高負荷になる 高 start
                // 単一集計,複数集計,集計紹介状
                if (RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_ONE_TOTAL
                 || RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_MULTI_TOTAL
                 || (RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_REFERRAL_LETTER && "1".Equals(RldLib.totalLayoutData.ReportType)))
                {
                    // テンプレート繰返し有無値 - 有り
                    if (RldLib.CurrentLayoutData.DesignSettingData.HasTemplete == RldConst.SettingData.VAL_HAS_TEMPLETE_YES)
                    {
                        List<string> totalUnitVList = new List<string>(RldLib.totalLayoutData.UnitV.Split(','));
                        List<string> totalUnitHList = new List<string>(RldLib.totalLayoutData.UnitH.Split(','));
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
                        foreach (var wParam in this.DataSet.DesignParamList)
                        {
                            // 繰返し回数が 1 回以下の場合は確認
                            // mod #11011 集計内訳タブ仕様変更 高 start
                            //if (wParam!= null && wParam.CanRepeat == true &&
                            //    RldLib.ConvertStrToInt32(wParam.RepeatCount, false) <= 1)
                            if (wParam!= null && RldLib.ConvertStrToInt32(wParam.RepeatCount, false) <= 1)
                            // mod #11011 集計内訳タブ仕様変更 高 end
                            {
                                bool bErr = false;
                                // 横の集計単位
                                foreach (var wList in totalUnitVList)
                                {
                                    if (wParam.DataCode.Equals(wList) && !string.IsNullOrEmpty(wList))
                                    {
                                        // add #11294 紹介状で集計部分がずれて出力される 高 start
                                        if (retTotalUnitV != null && retTotalUnitV.Contains(wParam.CellAddress) == true)
                                        {
                                        // add #11294 紹介状で集計部分がずれて出力される 高 end
                                            bErr = true;
                                            break;
                                        }
                                    }
                                }
                                // 縦の集計単位
                                foreach (var wList in totalUnitHList)
                                {
                                    if (wParam.DataCode.Equals(wList) && !string.IsNullOrEmpty(wList))
                                    {
                                        // add #11294 紹介状で集計部分がずれて出力される 高 start
                                        // 縦の単位
                                        if (retTotalUnitH != null && retTotalUnitH.Contains(wParam.CellAddress) == true)
                                        {
                                        // add #11294 紹介状で集計部分がずれて出力される 高 end
                                            bErr = true;
                                            break;
                                        }
                                    }
                                }
                                if (bErr)
                                {
                                    if (this.ShowMsgBox(
                                            String.Format(@"集計設定の縦の単位、または横の単位に繰返し回数が１回の項目があります。{0}このまま保存してもよろしいですか？", System.Environment.NewLine),
                                            "集計繰返回数の確認", System.Windows.Forms.MessageBoxButtons.YesNo, System.Windows.Forms.MessageBoxIcon.Question) != System.Windows.Forms.DialogResult.Yes)
                                        return false;

                                    break;
                                }
                            }
                        }
                    }
                }
                // add #10546 複数集計出力時にサーバが高負荷になる 高 end
                // add #11294 紹介状で集計部分がずれて出力される 高 start
                // 集計紹介状
                if (RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_REFERRAL_LETTER && "1".Equals(RldLib.totalLayoutData.ReportType))
                {
                    // テンプレート繰返し有無値 - 有り
                    if (RldLib.CurrentLayoutData.DesignSettingData.HasTemplete == RldConst.SettingData.VAL_HAS_TEMPLETE_YES)
                    {
                        if (!string.IsNullOrEmpty(RldLib.CurrentLayoutData.DesignTempleteData.Range))
                        {
                            foreach (var wData in RldLib.CurrentLayoutData.DesignParamList)
                            {
                                if (RldLib.CurrentLayoutData.DesignTempleteData.Range.Equals(wData.CellAddress))
                                {
                                    if (wData.CanRepeat == true)
                                    {
                                        var directionData = RldLib.CurrentLayoutData.DesignTempleteData.DirectionData == RldConst.TempleteData.VAL_DIRECTION_N ? "0" : "1";
                                        if (!string.IsNullOrEmpty(wData.repDirection) && wData.repDirection.Equals(directionData) == false)
                                        {
                                            this.ShowMsgBox(
                                                 "集計内容セルの繰返方向と、集計内訳の繰返方向は一致させなければなりません。",
                                                 "集計設定が不十分", System.Windows.Forms.MessageBoxButtons.OK, System.Windows.Forms.MessageBoxIcon.Exclamation);
                                            return false;
                                        }

                                        if (string.IsNullOrEmpty(RldLib.CurrentLayoutData.DesignTempleteData.RepeatCountV) == false
                                          && string.IsNullOrEmpty(RldLib.CurrentLayoutData.DesignTempleteData.RepeatCountH) == false
                                          && string.IsNullOrEmpty(wData.RepeatCount) == false)
                                        {
                                            int repeatCountV = int.Parse(RldLib.CurrentLayoutData.DesignTempleteData.RepeatCountV);
                                            int repeatCountH = int.Parse(RldLib.CurrentLayoutData.DesignTempleteData.RepeatCountH);
                                            int RepeatCount = int.Parse(wData.RepeatCount);

                                            if (repeatCountV > 0 && repeatCountH > 0 && (RepeatCount != repeatCountV * repeatCountH))
                                            {
                                                this.ShowMsgBox(
                                                     "集計内容セルの繰返回数と、集計内訳の繰返回数は一致させなければなりません。",
                                                     "集計設定が不十分", System.Windows.Forms.MessageBoxButtons.OK, System.Windows.Forms.MessageBoxIcon.Exclamation);
                                                return false;
                                            }
                                        }
                                    }
                                    break;
                                }
                            }
                        }
                    }
                }
                // add #11294 紹介状で集計部分がずれて出力される 高 end
                // add #11106 集計帳票で集計範囲外のグループ項目が出力されない 高 start
                // グループ名の使用制限
                bError = CheckGroupInTemplete();
                if (bError == false)
                    return false;
                // add #11106 集計帳票で集計範囲外のグループ項目が出力されない 高 end
            }
            catch (Exception ex)
            {
                throw;
            }

            // ここまでくればOK
            return true;
        }
        // add #10858 「##=[##データ項目」」の形式で null が出力される 高 end

        // add #11106 集計帳票で集計範囲外のグループ項目が出力されない 高 start
        // 集計内訳の縦の単位、横の単位に使用された項目のグループ名は、集計以外の項目では使用できません。
        private bool CheckGroupInTemplete()
        {
            bool bRet = true;
            bool bError = false;

            // 単一集計,複数集計,集計紹介状
            if (RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_ONE_TOTAL
             || RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_MULTI_TOTAL
             || (RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_REFERRAL_LETTER && "1".Equals(RldLib.totalLayoutData.ReportType)))
            {
                // テンプレート繰返し有無値 - 有り
                if (RldLib.CurrentLayoutData.DesignSettingData.HasTemplete == RldConst.SettingData.VAL_HAS_TEMPLETE_YES)
                {
                    List<String> retTotalUnitH = null;      // 縦の単位
                    List<String> retTotalUnitV = null;      // 横の単位
                    DesignParamDatasList totalUnitList = new DesignParamDatasList();

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

                    // loop data of paramlist
                    foreach (var wData in RldLib.CurrentLayoutData.DesignParamList)
                    {
                        // 横の単位
                        if (retTotalUnitV != null && retTotalUnitV.Contains(wData.CellAddress) == true)
                        {
                            totalUnitList.Add(wData);
                            continue;
                        }

                        // 縦の単位
                        if (retTotalUnitH != null && retTotalUnitH.Contains(wData.CellAddress) == true)
                        {
                            totalUnitList.Add(wData);
                            continue;
                        }
                    }

                    if (totalUnitList.Count < 1)
                        return true;

                    foreach (var wData in RldLib.CurrentLayoutData.DesignParamList)
                    {
                        // data is not in 横の単位/縦の単位
                        if (retTotalUnitV.Contains(wData.CellAddress) == false
                            && retTotalUnitH.Contains(wData.CellAddress) == false)
                        {
                            // group name is same and IsInTemplete is same
                            foreach (var wUnitData in totalUnitList)
                            {
                                if (wUnitData.CellAddress != wData.CellAddress
                                    && wUnitData.IsInTemplete == wData.IsInTemplete
                                    && wUnitData.GroupName == wData.GroupName)
                                {
                                    bError = true;
                                    break;
                                }
                            }
                        }

                        if (bError)
                            break;
                    }
                    if (bError == true)
                    {
                        this.ShowMsgBox(
                                    "集計内訳の縦の単位、横の単位に使用された項目のグループ名は、集計以外の項目では使用できません。グループ名を変更してください。",
                                    "グループ名の使用制限", System.Windows.Forms.MessageBoxButtons.OK, System.Windows.Forms.MessageBoxIcon.Exclamation);
                        return false;
                    }
                }
            }
            return bRet;
        }
        // add #11106 集計帳票で集計範囲外のグループ項目が出力されない 高 end

        /// <summary>
        /// パラメータ編集データの整合性を確認します。
        /// </summary>
        /// <returns></returns>
        private Boolean CheckConsistencyParamData()
        {
            const String MSG_TITLE = @"パラメータデータを確認してください";

            Boolean wIsAllowSingleItem = false;
            Boolean wHasTemplete = this.DataSet.DesignSettingData.HasTemplete == RldConst.SettingData.VAL_HAS_TEMPLETE_YES;

            System.Drawing.RectangleF wRectTemplete = System.Drawing.RectangleF.Empty;
			// add #10399 【デグレ】出力時に非表示セルが処理されない limingzhe start
            ExcelRangeEx wRangeTemplete = null;
			// add #10399 【デグレ】出力時に非表示セルが処理されない limingzhe end
            try
            {
                // add #8037 【デグレ】帳票（準備リスト）保存できない 夏 start
                if ((RldConst.ReportTypeData.VAL_TYPE_DIALYSIS.Equals(this.DataSet.DesignSettingData.ReportClass)
                    || RldConst.ReportTypeData.VAL_TYPE_EQUIPMENT_LIST.Equals(this.DataSet.DesignSettingData.ReportClass))
                    && (wHasTemplete || RldLib.CurrentLayoutData.DesignTempleteData != null))
                {
                    wHasTemplete = false;
                    // テンプレート繰返しデータを削除する
                    RldLib.CurrentLayoutData.DesignSettingData.HasTemplete = RldConst.SettingData.VAL_HAS_TEMPLETE_NO;
                    RldLib.CurrentLayoutData.DesignSettingData.IsSupportTempleteRepeat = false;
                    RldLib.CurrentLayoutData.DesignTempleteData = null;
                }
                // add #8037 【デグレ】帳票（準備リスト）保存できない 夏 end

                // テンプレート繰返しの設定がある場合は該当領域を取得しておく
                if (wHasTemplete)
                {
                    //mod 6720 EXCEL関数で使用できないものがある 吉 start
                    //using (var wXlRange = new ExcelRangeEx(this.XlHelper.XlSheetLayout, this.DataSet.DesignTempleteData.Range))
					// mod #10399 【デグレ】出力時に非表示セルが処理されない limingzhe start
                    wRangeTemplete = new ExcelRangeEx(this.XlHelper.XlSheetLayout, this.DataSet.DesignTempleteData != null ? this.DataSet.DesignTempleteData.Range : null);
                    wRectTemplete = wRangeTemplete.GetRectangle();
					// mod #10399 【デグレ】出力時に非表示セルが処理されない limingzhe end
                }

                // add 2021-08-06 #5981:ラベルが検査に対応していないの対応 孫 start
                // del #7949 「帳票種別：ラベル　sqlcode=16とsqlcode=17の項目を1つの帳票に設定すると、保存できない」 商 start
                //List<string> sqlCodeList = new List<string>();
                //// 帳票種別がラベルの場合、ベースレコードのSQLコードを取得する。
                //if (RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_LABEL)
                //{
                //    IEnumerable<DesignItemListData> enumerator = RldLib.CurrentLayoutData.DataItemList.Where(n => IsClassficationInfo(n.DataCategory, n.DataClass, n.DataName));
                //    if (enumerator.Count() > 0)
                //    {
                //        // 分類別情報のパラメータが存在する
                //        // ベースレコードのSQLコードを追加する
                //        string sqlCode = enumerator.First().SqlCode;
                //        sqlCodeList.Add(sqlCode);
                //    }
                //}
                // del #7949 「帳票種別：ラベル　sqlcode=16とsqlcode=17の項目を1つの帳票に設定すると、保存できない」 商 end
                // add 2021-08-06 #5981:ラベルが検査に対応していないの対応 孫 start

                // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 start
                // del #12399 複数患者帳票で繰り返し設定の「セル順を逆転する」が保存されない 高 start
                //int repeatIndex = 0;
                //Dictionary<Int32, List<String>> repeatAddressDictionary = new Dictionary<Int32, List<String>>();
                // del #12399 複数患者帳票で繰り返し設定の「セル順を逆転する」が保存されない 高 end
                // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 end

                // add #7677 「作成した帳票ファイルをアップロード時にエラー」について、対応する。 鄧シン start
                foreach (var wParam in this.DataSet.DesignParamList)
                {
                    if (RldLib.CurrentReport.ReportClass != RldConst.MasterData.Report.VAL_TYPE_ONE_TOTAL
                        && RldLib.CurrentReport.ReportClass != RldConst.MasterData.Report.VAL_TYPE_MULTI_TOTAL
                        && !(RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_REFERRAL_LETTER
                        && "1".Equals(RldLib.totalLayoutData.ReportType)))
                    {

                        if (wHasTemplete)
                        {
                            foreach (String wAddress in DesignParamData.GetSplitAddress(wParam.RepeatAddress).Where(ele => ele != wParam.CellAddress))
                            {
                                // 繰返し部分のセルの領域を取得
                                System.Drawing.RectangleF wRectRange = System.Drawing.RectangleF.Empty;
                                using (var wXlRange = new ExcelRangeEx(this.XlHelper.XlSheetLayout, wAddress))
                                {
                                    wRectRange = wXlRange.GetRectangle();
                                }

                                // テンプレート内にあるパラメータで、繰返し結果がテンプレート外に達する場合はエラー
                                if (wParam.IsInTemplete == RldConst.ParamData.VAL_IS_IN_TEMPLETE_IN && !wRectTemplete.Contains(wRectRange))
                                {
                                    //edit #9782 【デグレ】テンプレート範囲設定後にオンライン保存できなくなる。 dongzhaolong start
                                    // 設定を取得
                                    ExcelWorksheetEx settingSheet = RldLib.XlHelper.XlSheetSetting;

                                    //using (var wXlBufRange = new ExcelRangeEx(settingSheet.Worksheet.Cells[11, 1]))
                                    //{
                                    //    // テンプレートの範囲を取得
                                    //    string templetArea = wXlBufRange.GetValue2();
                                    //    string startCell = templetArea.Substring(0, templetArea.IndexOf(":"));
                                    //    string endCell = templetArea.Substring(templetArea.IndexOf(":") + 1);

                                    //    // テンプレート部分のセルの領域を取得
                                    //    Excel.Range templetRange = settingSheet.Worksheet.get_Range(startCell, endCell);
                                    //    int templetColumStart = templetRange.Column;
                                    //    int templetRowStart = templetRange.Row;
                                    //    int templetColumEnd = templetRange.Cells.Columns.Count + templetColumStart - 1;
                                    //    int templetRowEnd = templetRange.Cells.Rows.Count + templetRowStart - 1;

                                    //    // テンプレート範囲以外の場合
                                    //    Excel.Range cell = this.XlHelper.XlSheetLayout.Worksheet.Range[wAddress];
                                    //    if (cell.Column < templetColumStart || cell.Column > templetColumEnd
                                    //        || cell.Row < templetRowStart || cell.Row > templetRowEnd)
                                    //    {
                                    //        // 範囲外の繰返し項目を削除する。
                                    //        wParam.RepeatAddress = wParam.RepeatAddress.Replace(wAddress, "");

                                    //        if (wParam.RepeatAddress.Contains(",,"))
                                    //        {
                                    //            wParam.RepeatAddress = wParam.RepeatAddress.Replace(",,", ",");
                                    //        }

                                    //        wParam.RepeatAddress = wParam.RepeatAddress.TrimEnd(',');
                                    //    }
                                    //}
                                    DesignTempleteData aData = RldLib.CurrentLayoutData.DesignTempleteData;
                                    if (aData != null && !string.IsNullOrEmpty(aData.Range))
                                    {
                                        // テンプレートの範囲を取得
                                        string templetArea = aData.Range;
                                        // mod #12399 複数患者帳票で繰り返し設定の「セル順を逆転する」が保存されない 高 start
                                        //string startCell = templetArea.Substring(0, templetArea.IndexOf(":"));
                                        //string endCell = templetArea.Substring(templetArea.IndexOf(":") + 1);
                                        string startCell;
                                        string endCell;
                                        string[] address = templetArea.ToString().Split(':');
                                        if (address.Length == 1)
                                        {
                                            startCell = address[0];
                                            endCell = address[0];
                                        }
                                        else
                                        {
                                            startCell = address[0];
                                            endCell = address[1];
                                        }
                                        // mod #12399 複数患者帳票で繰り返し設定の「セル順を逆転する」が保存されない 高 end

                                        // テンプレート部分のセルの領域を取得
                                        Excel.Range templetRange = RldLib.XlHelper.XlSheetLayout.Worksheet.get_Range(startCell, endCell);
                                        int templetColumStart = templetRange.Column;
                                        int templetRowStart = templetRange.Row;
                                        int templetColumEnd = templetRange.Cells.Columns.Count + templetColumStart - 1;
                                        int templetRowEnd = templetRange.Cells.Rows.Count + templetRowStart - 1;

                                        // テンプレート範囲以外の場合
                                        Excel.Range cell = this.XlHelper.XlSheetLayout.Worksheet.Range[wAddress];
                                        if (cell.Column < templetColumStart || cell.Column > templetColumEnd
                                            || cell.Row < templetRowStart || cell.Row > templetRowEnd)
                                        {
                                            // mod #10108 テンプレート領域を超えた繰り返し設定が自動的に変更されるのはNG 高 start
                                            // 範囲外の繰返し項目を削除する。
                                            //wParam.RepeatAddress = wParam.RepeatAddress.Replace(wAddress, "");

                                            //if (wParam.RepeatAddress.Contains(",,"))
                                            //{
                                            //    wParam.RepeatAddress = wParam.RepeatAddress.Replace(",,", ",");
                                            //}

                                            //wParam.RepeatAddress = wParam.RepeatAddress.TrimEnd(',');
                                            this.ShowMsgBox(
                                                    "テンプレート内の項目の繰り返しが、\r\nテンプレート外まで設定されています。\r\n\r\n繰り返しをテンプレート内だけで設定しなおして下さい", 
                                                    "繰り返し範囲違反", System.Windows.Forms.MessageBoxButtons.OK, System.Windows.Forms.MessageBoxIcon.Exclamation);
                                            return false;
                                            // mod #10108 テンプレート領域を超えた繰り返し設定が自動的に変更されるのはNG 高 end
                                        }
                                    }
                                    //edit #9782 【デグレ】テンプレート範囲設定後にオンライン保存できなくなる。 dongzhaolong end
                                }
                            }
                        }
                    }
                }
                // del #9770 繰り返し設定で罫線と背景に異常 donghao start
                //// add #9770 繰り返し設定で罫線と背景に異常 donghao start
                //foreach (var wParam in this.DataSet.DesignParamList)
                //{
                //    frmEditRepeat frmEditRepeat = new frmEditRepeat();

                //    if (wParam.CanRepeat == true)
                //    {
                //        var CellList = wParam.RepeatAddress.Split(',');

                //        for (int i = 0; i < CellList.Length; i++)
                //        {

                //                Microsoft.Office.Interop.Excel.Range Range = RldLib.XlHelper.XlSheetLayout.Worksheet.get_Range(CellList[i]);
                //                if (frmEditRepeat.DicBackColor.ContainsKey(CellList[i]))
                //                {
                //                    Range.Interior.Color = frmEditRepeat.DicBackColor[CellList[i]];
                //                }                               

                //        }
                //    }

                //}
                //// add #9770 繰り返し設定で罫線と背景に異常 donghao end
                // del #9770 繰り返し設定で罫線と背景に異常 donghao end
                // add #7677 「作成した帳票ファイルをアップロード時にエラー」について、対応する。 鄧シン end
                // 配置されているパラメータを列挙しながらチェック
                foreach (var wParam in this.DataSet.DesignParamList)
                {
                                     
                    // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 start
                    // del #12399 複数患者帳票で繰り返し設定の「セル順を逆転する」が保存されない 高 start
                    //repeatIndex++;
                    // del #12399 複数患者帳票で繰り返し設定の「セル順を逆転する」が保存されない 高 end
                    // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 end               
                    // TODO: ラベルの場合
                    // add 2021-03-25 分類別情報かどうかの判定を追加する 趙 start
                    // 分類別情報であればの場合、ラベル項目設定の必須チェックを追加する
                    if (IsClassficationInfo(wParam.DataCategory, wParam.DataClass, wParam.DataName))
                    {
                        if (string.IsNullOrEmpty(wParam.LabelItem))
                        {
                            this.ShowMsgBox(
                                "分類別情報のラベル項目設定が必須です。\r\n分類別情報のラベル項目を設定して下さい。",
                                MSG_TITLE, System.Windows.Forms.MessageBoxButtons.OK, System.Windows.Forms.MessageBoxIcon.Exclamation);
                            return false;
                        }
                    }
                    // add 2021-03-25 分類別情報かどうかの判定を追加する 趙 end

                    // add 2021-08-06 #5981:ラベルが検査に対応していないの対応 孫 start
                    // 帳票種別がラベルの場合、結合先レコードのSQLコードは複数存在しますか？
                    // del #7949 「帳票種別：ラベル　sqlcode=16とsqlcode=17の項目を1つの帳票に設定すると、保存できない」 商 start
                    //if (RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_LABEL)
                    //{
                    //    if (!sqlCodeList.Contains(wParam.SqlCode))
                    //    {
                    //        sqlCodeList.Add(wParam.SqlCode);
                    //    }

                    //    if (sqlCodeList.Count > 2)
                    //    {
                    //        this.ShowMsgBox(
                    //            "採血管情報と治療情報は同時に存在できない。\r\n一つ情報をお願いします",
                    //            MSG_TITLE, System.Windows.Forms.MessageBoxButtons.OK, System.Windows.Forms.MessageBoxIcon.Exclamation);
                    //        return false;
                    //    }
                    //}
                    // del #7949 「帳票種別：ラベル　sqlcode=16とsqlcode=17の項目を1つの帳票に設定すると、保存できない」 商 end
                    // add 2021-08-06 #5981:ラベルが検査に対応していないの対応 孫 end
                    // mod #5714 紹介状が正しく出力できない 孟堅 start
                    // mod FNSI-523 2次元帳票対応 夏 start
                    // if (RldLib.CurrentReport.ReportClass != RldConst.MasterData.Report.VAL_TYPE_ONE_TOTAL && RldLib.CurrentReport.ReportClass != RldConst.MasterData.Report.VAL_TYPE_MULTI_TOTAL)
                    if (RldLib.CurrentReport.ReportClass != RldConst.MasterData.Report.VAL_TYPE_ONE_TOTAL && RldLib.CurrentReport.ReportClass != RldConst.MasterData.Report.VAL_TYPE_MULTI_TOTAL && !(RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_REFERRAL_LETTER && "1".Equals(RldLib.totalLayoutData.ReportType)))
                    {// mod #5714 紹介状が正しく出力できない 孟堅 end
                        // add FNSI-523 2次元帳票対応 夏 end

                        // テンプレート繰返しがある場合
                        if (wHasTemplete)
                        {
							// add #10399 【デグレ】出力時に非表示セルが処理されない limingzhe start
                            if(this.XlHelper.XlApp.IsInRange(wParam.CanRepeat ? wParam.RepeatAddress : wParam.CellAddress, wRangeTemplete.Range.Address[false, false], wParam.CanRepeat))
                            {
                                this.ShowMsgBox(
                                    // mod #5602 李明 start
                                    //String.Format(@"テンプレート繰返し領域を跨ぐデータがデータが配置されています。{0}設定を見直して下さい。", System.Environment.NewLine),
                                    String.Format(@"テンプレート繰返し領域を跨ぐデータが配置されています。{0}設定を見直して下さい。", System.Environment.NewLine),
                                    // mod #5602 李明 end
                                    MSG_TITLE, System.Windows.Forms.MessageBoxButtons.OK, System.Windows.Forms.MessageBoxIcon.Exclamation);
                                return false;
                            }
							// add #10399 【デグレ】出力時に非表示セルが処理されない limingzhe end
							// del #10399 【デグレ】出力時に非表示セルが処理されない limingzhe start
                            //// パラメータが配置されているセルの領域を取得
                            //System.Drawing.RectangleF wRectRange = System.Drawing.RectangleF.Empty;
                            //using (var wXlRange = new ExcelRangeEx(this.XlHelper.XlSheetLayout, wParam.CellAddress))
                            //    wRectRange = wXlRange.GetRectangle();

                            //// add #7943 帳票レイアウトデザイナーが正しく動作しない 商 start
                            //System.Drawing.RectangleF intersectRange = System.Drawing.RectangleF.Intersect(wRectRange, wRectTemplete);
                            //if (intersectRange.Width != 0 && intersectRange.Height != 0)
                            //{
                            //    // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 end
                            //    // テンプレート領域の境界を跨ぐ場合はエラー
                            //    if (System.Drawing.RectangleF.Intersect(wRectRange, wRectTemplete) != System.Drawing.RectangleF.Empty)
                            //    {
                            //        if (wRectTemplete.Contains(wRectRange) == false)
                            //        {
                            //            this.ShowMsgBox(
                            //                // mod #5602 李明 start
                            //                //String.Format(@"テンプレート繰返し領域を跨ぐデータがデータが配置されています。{0}設定を見直して下さい。", System.Environment.NewLine),
                            //                String.Format(@"テンプレート繰返し領域を跨ぐデータが配置されています。{0}設定を見直して下さい。", System.Environment.NewLine),
                            //                // mod #5602 李明 end
                            //                MSG_TITLE, System.Windows.Forms.MessageBoxButtons.OK, System.Windows.Forms.MessageBoxIcon.Exclamation);
                            //            return false;
                            //        }
                            //    }
                            //    // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 start
                            //}
                            //// add #7943 帳票レイアウトデザイナーが正しく動作しない 商 end
							// del #10399 【デグレ】出力時に非表示セルが処理されない limingzhe end
                        }
                    }
                    // 計算式の場合
                    if (wParam.IsCalcResult)
                    {
                        // add 2020-10-19 FNSI-改修 帳票に使用できるExcel関数 夏 start
                        Boolean functionFlg = false;
                        for (int j = 0; j < functionNames.Length; j++)
                        {
                            if (wParam.DataPath.IndexOf(functionNames[j]) >= 0)
                            {
                                functionFlg = true;
                                break;
                            }
                        }
                        if (functionFlg == false)
                        {
                            // add 2020-10-19 FNSI-改修 帳票に使用できるExcel関数 夏 end
                            // サンプリング用計算式を試行する
                            // mod #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 start
                            //var wRes = this.XlHelper.XlApp.Application.Evaluate(this.GetSamplingFormula(wParam.DataPath));
                            var wRes = this.XlHelper.XlApp.Application.Evaluate(RldLib.GetSamplingFormula(wParam.DataPath, this.DataSet.DesignParamList, this.DataSet.DataItemList));
                            // mod #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 end

                            // add #11784 レイアウトデザイナのフリー計算ツールにセル番地がドロップできない 高 start
                            bool bExeclNull = false;
                            try
                            {
                                do
                                {
                                    // exception
                                    if (wRes == null)
                                    {
                                        bExeclNull = true;
                                        break;
                                    }
                                    if (wRes is System.Reflection.Missing)
                                    {
                                        bExeclNull = true;
                                        break;
                                    }
                                    if (wRes is Microsoft.Office.Interop.Excel.XlCVError)
                                    {
                                        bExeclNull = true;
                                        break;
                                    }

                                    // check array
                                    if (wRes.GetType().IsArray)
                                    {
                                        try
                                        {
                                            Array arr = (Array)wRes;
                                            if(arr.Length == 0)
                                            {
                                                bExeclNull = true;
                                                break;
                                            }
                                        }
                                        catch
                                        {
                                            bExeclNull = true;
                                            break;
                                        }
                                    }
                                    bExeclNull = false;
                                } while (false);
                            }
                            catch
                            {
                                // is null
                                bExeclNull = true;
                            }

                            if (bExeclNull == true)
                            {
                                _ = ShowMsgBox(
                                    "数式が不正です。\r\n設定を見直して下さい。",
                                    MSG_TITLE, System.Windows.Forms.MessageBoxButtons.OK, System.Windows.Forms.MessageBoxIcon.Exclamation);
                                return false;

                            }
                            // add #11784 レイアウトデザイナのフリー計算ツールにセル番地がドロップできない 高 end

                            foreach (ExcelUtility.EnumCVErr wValue in Enum.GetValues(typeof(ExcelUtility.EnumCVErr)))
                            {
                                if (wValue != ExcelUtility.EnumCVErr.ErrDiv0 && ExcelUtility.IsEqualXlCVErr(wRes, wValue))
                                {

                                    // TODO: CellAddress と DataPath を表示して、修正すべきところが分かるようにする

                                    _ = ShowMsgBox(
                                        "数式が不正です。\r\n設定を見直して下さい。",
                                        MSG_TITLE, System.Windows.Forms.MessageBoxButtons.OK, System.Windows.Forms.MessageBoxIcon.Exclamation);
                                    return false;

                                }
                            }
                        }
                        // mod #10444 複数患者帳票のオンライン保存でエラーになることがある 高 start
                        else
                        {
                            if(!string.IsNullOrEmpty(wParam.DataPath))
                            {
                                // mod #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 start
                                //var wRes = (this.GetSamplingFormula(wParam.DataPath));
                                var wRes = (RldLib.GetSamplingFormula(wParam.DataPath, this.DataSet.DesignParamList, this.DataSet.DataItemList));
                                // mod #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 end
                                if (string.IsNullOrEmpty(wRes))
                                {
                                    _ = ShowMsgBox(
                                        "数式が不正です。\r\n設定を見直して下さい。",
                                        MSG_TITLE, System.Windows.Forms.MessageBoxButtons.OK, System.Windows.Forms.MessageBoxIcon.Exclamation);
                                    return false;
                                }
                            }
                        }
                        // mod #10444 複数患者帳票のオンライン保存でエラーになることがある 高 end
                        // add 2020-10-19 FNSI-改修 帳票に使用できるExcel関数 夏 start
                    }
                    // add 2020-10-19 FNSI-改修 帳票に使用できるExcel関数 夏 end

                    // 繰返し可能項目ではない場合は以降のチェックは不要のためスキップ
                    if (!wParam.CanRepeat) continue;

                    // グループ名が未設定の場合はエラー
                    if (String.IsNullOrEmpty(wParam.GroupName))
                    {
                        this.ShowMsgBox(
                            String.Format(@"[{0}]{1}のグループ名を設定して下さい。", wParam.DataPath, System.Environment.NewLine),
                            MSG_TITLE, System.Windows.Forms.MessageBoxButtons.OK, System.Windows.Forms.MessageBoxIcon.Exclamation);
                        return false;
                    }

                    // データ種別が画像以外で繰返し回数が 1 回以下の場合は確認
                    if (!wIsAllowSingleItem &&
                        wParam.DataType != RldConst.ParamData.VAL_DATATYPE_IMAGE &&
                        RldLib.ConvertStrToInt32(wParam.RepeatCount, false) <= 1)
                    {
                       
                        if (this.ShowMsgBox(
                                String.Format(@"繰返し回数が１回の項目があります。{0}このまま保存してもよろしいですか？", System.Environment.NewLine),
                                MSG_TITLE, System.Windows.Forms.MessageBoxButtons.YesNo, System.Windows.Forms.MessageBoxIcon.Question) != System.Windows.Forms.DialogResult.Yes)
                            return false;

                        wIsAllowSingleItem = true;
                    }
                    // mod #5714 紹介状が正しく出力できない 孟堅 start
                    // if (RldLib.CurrentReport.ReportClass != RldConst.MasterData.Report.VAL_TYPE_ONE_TOTAL && RldLib.CurrentReport.ReportClass != RldConst.MasterData.Report.VAL_TYPE_MULTI_TOTAL）
                    // add FNSI-523 2次元帳票対応 夏 start
                    if (RldLib.CurrentReport.ReportClass != RldConst.MasterData.Report.VAL_TYPE_ONE_TOTAL && RldLib.CurrentReport.ReportClass != RldConst.MasterData.Report.VAL_TYPE_MULTI_TOTAL && !(RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_REFERRAL_LETTER && "1".Equals(RldLib.totalLayoutData.ReportType)))
                    {// mod #5714 紹介状が正しく出力できない 孟堅 end
                        // add FNSI-523 2次元帳票対応 夏 end
                        // 同一グループで繰返し回数が異なるパラメータがある場合はエラー
                        // mod UT帳票No.125 特殊帳票「交換部品記録簿」レイアウト出力の対応 夏 start
                        //if (this.DataSet.DesignParamList.Count(ele => ele.GroupName == wParam.GroupName && ele.RepeatCount != wParam.RepeatCount) != 0)
                        // mod #12538 日常点検／定期点検のデータ項目補完 limingzhe start
                        //if (this.DataSet.DesignParamList.Count(ele => ele.GroupName == wParam.GroupName && ele.RepeatCount != wParam.RepeatCount) != 0 && RldLib.CurrentReport.ReportClass != RldConst.MasterData.Report.VAL_TYPE_DEVICE)
                        if (this.DataSet.DesignParamList.Count(ele => ele.GroupName == wParam.GroupName && ele.RepeatCount != wParam.RepeatCount) != 0)
                        // mod #12538 日常点検／定期点検のデータ項目補完 limingzhe end
                        // mod UT帳票No.125 特殊帳票「交換部品記録簿」レイアウト出力の対応 夏 end
                        {
                            this.ShowMsgBox(
                                String.Format(@"[{0}.{1}]クラスの[{2}]グループに設定された繰返し回数が一致しません。{3}同一カテゴリ・クラスで同じグループ名を指定した項目は、繰返し回数を同数に設定して下さい。", wParam.DataCategory, wParam.DataClass, wParam.GroupName, System.Environment.NewLine),
                                MSG_TITLE, System.Windows.Forms.MessageBoxButtons.OK, System.Windows.Forms.MessageBoxIcon.Exclamation);
                            return false;
                        }

                        if (wHasTemplete)
                        {

                            // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 start
                            // del #12399 複数患者帳票で繰り返し設定の「セル順を逆転する」が保存されない 高 start
                            //List<String> repeatAddressList = new List<string>();
                            //repeatAddressList.Add(wParam.CellAddress);
                            // del #12399 複数患者帳票で繰り返し設定の「セル順を逆転する」が保存されない 高 end
                            // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 end
                            foreach (String wAddress in DesignParamData.GetSplitAddress(wParam.RepeatAddress).Where(ele => ele != wParam.CellAddress))
                            {

                                // 繰返し部分のセルの領域を取得
                                System.Drawing.RectangleF wRectRange = System.Drawing.RectangleF.Empty;
                                using (var wXlRange = new ExcelRangeEx(this.XlHelper.XlSheetLayout, wAddress))
                                    wRectRange = wXlRange.GetRectangle();

                                // mod #7677 「作成した帳票ファイルをアップロード時にエラー」について、対応する。 鄧シン start
                                // // テンプレート内にあるパラメータで、繰返し結果がテンプレート外に達する場合はエラー
                                // if (wParam.IsInTemplete == RldConst.ParamData.VAL_IS_IN_TEMPLETE_IN && !wRectTemplete.Contains(wRectRange))
                                // {
                                // 
                                //     this.ShowMsgBox(
                                //         "テンプレート内の項目の繰返しが、テンプレート外まで設定されています。\r\n繰返し範囲をテンプレート内のみで設定し直して下さい。",
                                //         MSG_TITLE, System.Windows.Forms.MessageBoxButtons.OK, System.Windows.Forms.MessageBoxIcon.Exclamation);
                                //     return false;
                                // }
                                // // テンプレート外にあるパラメータで、繰返し結果がテンプレート内に達する場合はエラー
                                // else if (wParam.IsInTemplete == RldConst.ParamData.VAL_IS_IN_TEMPLETE_OUT && wRectTemplete.Contains(wRectRange))
                                // テンプレート外にあるパラメータで、繰返し結果がテンプレート内に達する場合はエラー
                                if (wParam.IsInTemplete == RldConst.ParamData.VAL_IS_IN_TEMPLETE_OUT && wRectTemplete.Contains(wRectRange))
                                // mod #7677 「作成した帳票ファイルをアップロード時にエラー」について、対応する。 鄧シン end
                                {
                                    this.ShowMsgBox(
                                        "テンプレート外の項目の繰返しが、テンプレート内まで設定されています。\r\n繰返し範囲をテンプレート外のみで設定し直して下さい。",
                                        MSG_TITLE, System.Windows.Forms.MessageBoxButtons.OK, System.Windows.Forms.MessageBoxIcon.Exclamation);
                                    return false;
                                }
                                // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 start
                                // del #12399 複数患者帳票で繰り返し設定の「セル順を逆転する」が保存されない 高 start
                                //repeatAddressList.Add(wAddress);
                                // del #12399 複数患者帳票で繰り返し設定の「セル順を逆転する」が保存されない 高 end
                                // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 end
                            }
                            // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 start
                            // del #12399 複数患者帳票で繰り返し設定の「セル順を逆転する」が保存されない 高 start
                            //repeatAddressDictionary.Add(repeatIndex - 1, repeatAddressList);
                            // del #12399 複数患者帳票で繰り返し設定の「セル順を逆転する」が保存されない 高 end
                            // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 end
                        }
                    }
                    // add 5598 改ページが正しく機能しない 李 start
                    else if (RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_ONE_TOTAL || RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_MULTI_TOTAL)
                    {
                        // add #10858 「##=[##データ項目」」の形式で null が出力される 高 start
                        if (this.DataSet.DesignTempleteData != null)
                        {
                        // add #10858 「##=[##データ項目」」の形式で null が出力される 高 end
                            if (this.DataSet.DesignParamList.Count(ele => ele.GroupName == wParam.GroupName && (wParam.RepeatCount == "1" && !(this.DataSet.DesignTempleteData.RepeatCountH == ele.RepeatCount || this.DataSet.DesignTempleteData.RepeatCountV == ele.RepeatCount || ele.RepeatCount == "1"))) != 0)
                            {
                                this.ShowMsgBox(
                                    String.Format(@"集計項目の繰返回数と集計内訳の横・縦の繰返回数は不一致です。"),
                                    MSG_TITLE, System.Windows.Forms.MessageBoxButtons.OK, System.Windows.Forms.MessageBoxIcon.Exclamation);
                                return false;
                            }
                        }
                    }
                    // add 5598 改ページが正しく機能しない 李 end
                    // TODO: 水質調査箇所フィルタの正式実装時に以下の case 句を復活させる
                    // 設定必須なフィルタ種別で未設定の場合はエラー
                    switch (wParam.FilterType)
                    {
                        case RldConst.FilterType.Parameter.EXAMINE:         // 検査項目フィルタ
                        case RldConst.FilterType.Parameter.EXAM_SET:        // 検査セットフィルタ
                        // add #12050 FNW帳票コンバートで維持されない設定がある 高 start
                            if (wParam.FilterState == RldConst.ParamData.VAL_FILTER_STATE_RESET || String.IsNullOrEmpty(wParam.FilterData))
                            {
                                this.ShowMsgBox(
                                    String.Format("[{0}]は\r\nフィルタリングの設定が必須です。", wParam.DataPath),
                                    MSG_TITLE, System.Windows.Forms.MessageBoxButtons.OK, System.Windows.Forms.MessageBoxIcon.Exclamation);
                                return false;
                            }
                            break;
                        // add #12050 FNW帳票コンバートで維持されない設定がある 高 end
                        // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
                        case RldConst.FilterType.Parameter.WQTESTPOINT:
                        // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
                        // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
                        case RldConst.FilterType.Parameter.INSPECTION:          // 点検フィルタ
                            if (String.IsNullOrEmpty(wParam.FilterData) && RldLib.CurrentReport.ReportClass == RldConst.MasterData.Report.VAL_TYPE_DEVICE)
                            {
                                this.ShowMsgBox(
                                    String.Format("[{0}]は\r\nフィルタリングの設定が必須です。", wParam.DataPath),
                                    MSG_TITLE, System.Windows.Forms.MessageBoxButtons.OK, System.Windows.Forms.MessageBoxIcon.Exclamation);
                                return false;
                            }
                            break;
                        // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
                        // add FNSI-5915 李 start
                        case RldConst.FilterType.Parameter.CATEGORY:
                            // add FNSI-5915 李 end
                            //case RldConst.FilterType.Parameter.WATER_SURVEY:    // 水質調査箇所フィルタ
                            if (String.IsNullOrEmpty(wParam.FilterData))
                            {
                                this.ShowMsgBox(
                                    String.Format("[{0}]は\r\nフィルタリングの設定が必須です。", wParam.DataPath),
                                    MSG_TITLE, System.Windows.Forms.MessageBoxButtons.OK, System.Windows.Forms.MessageBoxIcon.Exclamation);
                                return false;
                            }
                            break;

                        default:
                            break;
                    }
                }
                // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 start
                // del #12399 複数患者帳票で繰り返し設定の「セル順を逆転する」が保存されない 高 start
                //foreach (KeyValuePair<Int32, List<String>> keyValue in repeatAddressDictionary)
                //{
                //    RldLib.CurrentLayoutData.SetDesignParamDataListForRepeat(keyValue.Key, keyValue.Value);
                //}
                // del #12399 複数患者帳票で繰り返し設定の「セル順を逆転する」が保存されない 高 end
                // add #7943 帳票レイアウトデザイナーが正しく動作しない 商 end
            }
            catch (Exception ex)
            {
                throw;
            }

            // ここまでくればOK
            return true;
        }

        /// <summary>
        /// グループデータの整合性を確認します。
        /// </summary>
        /// <returns></returns>
        private Boolean CheckConsistencyGroupData()
        {
            try
            {


            }
            catch (Exception ex)
            {
                throw;
            }

            // ここまでくればOK
            return true;
        }

        /// <summary>
        /// テンプレート繰返しデータの整合性を確認します。
        /// </summary>
        /// <returns></returns>
        private Boolean CheckConsistencyTempleteData()
        {
            const String MSG_TITLE = @"テンプレート繰返しデータを確認してください";

            try
            {
                // テンプレート繰返しを設定している場合
                if (this.DataSet.DesignSettingData.HasTemplete == RldConst.SettingData.VAL_HAS_TEMPLETE_YES)
                {
                    // デバッグ用チェック
                    if (String.IsNullOrEmpty(this.DataSet.DesignTempleteData.Range))
                        System.Diagnostics.Debug.Assert(false, "テンプレート繰返しが設定されているが選択範囲が未設定です。");

                    // 抽出条件
                    // mod 2020-11-02 UTバグ2の修正 抽出条件の判定不正 夏 start
                    //if (String.IsNullOrEmpty(this.DataSet.DesignTempleteData.RepeatMode) == RldConst.TempleteData.VAL_REPEAT_MODE_NONE)
                    // mod #12474 FNW帳票取り込みでテンプレートの抽出条件を更新しないと正常出力されない limingzhe start
                    //if (String.IsNullOrEmpty(this.DataSet.DesignTempleteData.RepeatMode))
                    if (!IsEffectiveRepeatMode(this.DataSet.DesignTempleteData.RepeatMode))
                    // mod #12474 FNW帳票取り込みでテンプレートの抽出条件を更新しないと正常出力されない limingzhe end
                    // mod 2020-11-02 UTバグ2の修正 抽出条件の判定不正 夏 end
                    {
                        if (this.DataSet.DesignSettingData.ReportClass == RldConst.ReportTypeData.VAL_TYPE_ONE_PATIENT ||
                            // mod 2020-11-02 UTバグ3の修正 複数患者帳票の判定修正 夏 start
                            //this.DataSet.DesignSettingData.ReportClass == RldConst.ReportTypeData.VAL_TYPE_ONE_PATIENT)
                            this.DataSet.DesignSettingData.ReportClass == RldConst.ReportTypeData.VAL_TYPE_MULTI_PATIENT ||
                            // mod 2020-11-02 UTバグ3の修正 複数患者帳票の判定修正 夏 end
                            // add #11226 患者情報系historyの取得条件見直し② 高 start
                            (RldLib.CurrentLayoutData.DesignSettingData.ReportClass == RldConst.ReportTypeData.VAL_TYPE_REFERRAL_LETTER && "2".Equals(RldLib.totalLayoutData.ReportType)))
                            // add #11226 患者情報系historyの取得条件見直し② 高 end
                        {
                            this.ShowMsgBox(
                                // mod #7677 「作成した帳票ファイルをアップロード時にエラー」について、対応する。 鄧シン start
                                // "繰返しモードを設定して下さい。",
                                "抽出条件を設定して下さい。",
                                // mod #7677 「作成した帳票ファイルをアップロード時にエラー」について、対応する。 鄧シン start
                                MSG_TITLE, System.Windows.Forms.MessageBoxButtons.OK, System.Windows.Forms.MessageBoxIcon.Exclamation);
                            return false;
                        }
                    }
                }
                // テンプレート繰返しを設定していない場合
                else
                {
                    // デバッグ用チェック
                    // mod #7943 帳票レイアウトデザイナーが正しく動作しない 商 start
                    //if (!String.IsNullOrEmpty(this.DataSet.DesignTempleteData.Range))
                    if ((this.DataSet.DesignTempleteData != null) && (!String.IsNullOrEmpty(this.DataSet.DesignTempleteData.Range)))
                        // mod #7943 帳票レイアウトデザイナーが正しく動作しない 商 end
                        System.Diagnostics.Debug.Assert(false, "テンプレート繰返しが未設定だが選択範囲が設定されています。");

                    switch (this.DataSet.DesignSettingData.ReportClass)
                    {
                        case RldConst.ReportTypeData.VAL_TYPE_MULTI_PATIENT:
                        case RldConst.ReportTypeData.VAL_TYPE_DISTRIBUTE_LIST_BED:
                        // del Aspose.cells関連問題対応 夏 start
                        //case RldConst.ReportTypeData.VAL_TYPE_DISTRIBUTE_LIST_EQUIPMENT:
                        // del Aspose.cells関連問題対応 夏 end
                        case RldConst.ReportTypeData.VAL_TYPE_LABEL:
                            this.ShowMsgBox(
                                "テンプレート設定が必須です。\r\nテンプレート範囲と繰返し回数を設定して下さい。",
                                MSG_TITLE, System.Windows.Forms.MessageBoxButtons.OK, System.Windows.Forms.MessageBoxIcon.Exclamation);
                            return false;

                        default:
                            break;
                    }
                }
            }
            catch (Exception ex)
            {
                throw;
            }

            // ここまでくればOK
            return true;
        }

        /// <summary>
        /// サンプリング用計算式を取得します。
        /// </summary>
        /// <param name="aFormula"></param>
        /// <returns></returns>
        // del #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 start
        //private String GetSamplingFormula(String aFormula)
        //{
        //    String wRet = aFormula.Replace(RldConst.CALC_HEADER, String.Empty);

        //    Int32 wStartPos = -1, wEndPos = -1;

        //    // mod #10444 複数患者帳票のオンライン保存でエラーになることがある 高 start
        //    //string cal_start = RldConst.CALC_ITEM_START + RldConst.PATH_HEADER;
        //    ////while ((wStartPos = aFormula.IndexOf(RldConst.CALC_ITEM_START, wEndPos + 1)) >= 0)
        //    //while ((wStartPos = aFormula.IndexOf(cal_start, wEndPos + 1)) >= 0)
        //    //{
        //    //    wEndPos = aFormula.IndexOf(RldConst.CALC_ITEM_END, wStartPos + 1);
        //    //    if (wEndPos == -1)
        //    //        break;

        //    //    // データ項目名を切り出し
        //    //    var wItemPath = aFormula.Substring(wStartPos + 1, wEndPos - wStartPos - 1);

        //    //    if (RldLib.CurrentLayoutData.DataItemList.Count(ele => ele.DataPath == wItemPath) > 0)
        //    //    {
        //    //        var wData = RldLib.CurrentLayoutData.DataItemList.Single(ele => ele.DataPath == wItemPath);
        //    //        wRet = wRet.Replace(
        //    //            $"{RldConst.CALC_ITEM_START}{wItemPath}{RldConst.CALC_ITEM_END}",
        //    //            RldLib.ConvertStrToDecimal(wData.PreviewData, true).ToString());
        //    //    }
        //    //}
        //    //return wRet;
        //    string wTemp = string.Empty;
        //    int commStrPos = -1, commEndPos = -1;
        //    bool endFlag = false;
        //    string cal_start = RldConst.CALC_ITEM_START + RldConst.PATH_HEADER;

        //    while ((commStrPos = wRet.IndexOf("\"", commEndPos + 1)) >= 0)
        //    {
        //        {
        //            string wRetTemp = wRet.Substring(commEndPos + 1, commStrPos - commEndPos - 1);
        //            string wTmp = wRetTemp;
        //            wStartPos = -1;
        //            wEndPos = -1;
        //            while ((wStartPos = wTmp.IndexOf(cal_start, wEndPos + 1)) >= 0)
        //            {
        //                wEndPos = wTmp.IndexOf(RldConst.CALC_ITEM_END, wStartPos + 1);
        //                if (wEndPos == -1)
        //                    break;

        //                // データ項目名を切り出し
        //                var wItemPath = wTmp.Substring(wStartPos + 1, wEndPos - wStartPos - 1);
        //                if (RldLib.CurrentLayoutData.DataItemList.Count(ele => ele.DataPath == wItemPath) > 0)
        //                {
        //                    var wData = RldLib.CurrentLayoutData.DataItemList.Single(ele => ele.DataPath == wItemPath);
        //                    wRetTemp = wRetTemp.Replace(
        //                        $"{RldConst.CALC_ITEM_START}{wItemPath}{RldConst.CALC_ITEM_END}",
        //                        RldLib.ConvertStrToDecimal(wData.PreviewData, true).ToString());
        //                }
        //            }
        //            wTemp = wTemp + wRetTemp;
        //            commEndPos = wRet.IndexOf("\"", commStrPos + 1);
        //            if (commEndPos == -1)
        //            {
        //                return string.Empty;
        //                //wTemp = wTemp + wRet.Substring(commStrPos);
        //                //endFlag = true;
        //                //break;
        //            }
        //            else
        //            {
        //                wTemp = wTemp + wRet.Substring(commStrPos, commEndPos - commStrPos + 1);
        //            }
        //            endFlag = true;
        //        }
        //    }

        //    // del #11556 「##=」型の計算式で関数が使用できなくなっている 高 start
        //    //if (endFlag == false)
        //    // del #11556 「##=」型の計算式で関数が使用できなくなっている 高 end
        //    {
        //        string wRetTemp = wRet.Substring(commEndPos + 1);
        //        string wTmp = wRetTemp;
        //        wStartPos = -1;
        //        wEndPos = -1;
        //        while ((wStartPos = wTmp.IndexOf(cal_start, wEndPos + 1)) >= 0)
        //        {
        //            wEndPos = wTmp.IndexOf(RldConst.CALC_ITEM_END, wStartPos + 1);
        //            if (wEndPos == -1)
        //                break;

        //            // データ項目名を切り出し
        //            var wItemPath = wTmp.Substring(wStartPos + 1, wEndPos - wStartPos - 1);
        //            if (RldLib.CurrentLayoutData.DataItemList.Count(ele => ele.DataPath == wItemPath) > 0)
        //            {
        //                var wData = RldLib.CurrentLayoutData.DataItemList.Single(ele => ele.DataPath == wItemPath);
        //                wRetTemp = wRetTemp.Replace(
        //                    $"{RldConst.CALC_ITEM_START}{wItemPath}{RldConst.CALC_ITEM_END}",
        //                    RldLib.ConvertStrToDecimal(wData.PreviewData, true).ToString());
        //            }
        //        }
        //        wTemp = wTemp + wRetTemp;
        //    }
        //    return wTemp;
        //    // mod #10444 複数患者帳票のオンライン保存でエラーになることがある 高 end
        //}
        // del #12487 レイアウトデザイナアプリのプレビュー機能が正しく機能していない 高 end

        /// <summary>
        /// メッセージボックスを表示して結果を取得します。
        /// </summary>
        /// <returns></returns>
        private System.Windows.Forms.DialogResult ShowMsgBox(String aText, String aCaption, System.Windows.Forms.MessageBoxButtons aButtons, System.Windows.Forms.MessageBoxIcon aIcon)
        {
            LoadingHelper.CloseLoadingDialog ();
            var wData = new RldDesignNotifyInfoRequestShowMessageEventArgs()
            {
                Text = aText,
                Caption = aCaption,
                Buttons = aButtons,
                Icon = aIcon
            };

            this.SendNotifyInfo(wData);
            LoadingHelper.ShowLoadingDialog();
            return wData.DialogResult;
        }

        // add 2021-03-25 分類別情報かどうかの判定を追加する 趙 start
        /// <summary>
        /// 分類別情報かどうかを判定する
        /// </summary>
        /// <param name="dataCategory">カテゴリ</param>
        /// <param name="dataClass">クラス</param>
        /// <param name="dataName">項目名</param>
        /// <returns>分類別情報の場合 True。それ以外の場合 False。</returns>
        private static bool IsClassficationInfo(string dataCategory, string dataClass, string dataName)
        {
            return dataCategory.Equals(DesignItemListData.dcLabel) &&
                                    dataClass.Equals(DesignItemListData.dcMaterialInfo) &&
                                    dataName.Equals(DesignItemListData.dcClassificationInfo);
        }
        // add 2021-03-25 分類別情報かどうかの判定を追加する 趙 end

        // add #12474 FNW帳票取り込みでテンプレートの抽出条件を更新しないと正常出力されない limingzhe start
        private static bool IsEffectiveRepeatMode(string repeatMode)
        {
            if (String.IsNullOrEmpty(repeatMode)) return false;

            switch (repeatMode)
            {
                case RldConst.TempleteData.VAL_REPEAT_MODE_DIALYSIS:
                    return true;
                case RldConst.TempleteData.VAL_REPEAT_MODE_EXAMIN:
                    return true;
                case RldConst.TempleteData.VAL_REPEAT_MODE_PRESCRIPTIONNO:
                    return true;
                case RldConst.TempleteData.VAL_REPEAT_MODE_RESULTCD:
                    return true;
                case RldConst.TempleteData.VAL_REPEAT_MODE_MAINTENO:
                    return true;
                case RldConst.TempleteData.VAL_REPEAT_MODE_EVENTSTARTDATE:
                    return true;
            }
            return false;
        }
        // add #12474 FNW帳票取り込みでテンプレートの抽出条件を更新しないと正常出力されない limingzhe end
        #endregion
    }
}