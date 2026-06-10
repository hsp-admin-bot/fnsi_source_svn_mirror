using ConvertCommon.Common;
using Fnw.Common.Cmn;
using Fnw.Common.Com;
using Fnw.IOControl.DB;
using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Linq;
using System.Text;


namespace ConvertCommon
{
    public class CheckPatIndApprove
    {


        private static readonly List<ItemAV> itemAV = new List<ItemAV>
        {
            new ItemAV("A","未登録", ""),
            new ItemAV("V","未登録", ""),
            new ItemAV("SN","未登録", ""),
            new ItemAV("BOOLD","未登録", ""),
        };

        public static bool CheckIndUpdate(DBCtrl db, string strPatId, string strDialysisDate, decimal decPlural, DateTime dtTargetDate, bool visibleStartTime)
        {
            // ---------------------------------
            // 予定指示情報
            // ---------------------------------
            DataTable tbIndPlan = GetIndPlan(db, strPatId, strDialysisDate, decPlural, dtTargetDate, true);
            if (null == tbIndPlan)
            {
                return false;
            }
            // レコードが1件以上存在する場合は更新情報ありと判断
            if (0 < tbIndPlan.Rows.Count)
            {
                return true;
            }

            #region
            // 透析日を FnwDate に変換(引数チェックしているので TryParse しない)
            FnwDate fnwDialysisDate = FnwDate.YyyyMmDd(strDialysisDate);
            tbIndPlan = ProcSelectIndDialysisPlan(db, strPatId, strDialysisDate, decPlural, fnwDialysisDate, null, false);
            if (null == tbIndPlan)
            {
                return false;
            }

            if (0 == tbIndPlan.Rows.Count)
            {
                return false;
            }

            #endregion

            // ---------------------------------
            // 投薬指示情報
            // ---------------------------------
            DataTable tbIndMedi = GetIndMedi(db, strPatId, strDialysisDate, decPlural, dtTargetDate, true, tbIndPlan, true);
            if (null == tbIndMedi)
            {
                return false;
            }
            // レコードが1件以上存在する場合は更新情報ありと判断
            if (0 < tbIndMedi.Rows.Count)
            {
                return true;
            }

            // ---------------------------------
            // 指示簿指示情報
            // ---------------------------------
            DataTable tbIndAdd = GetIndAddition(db, strPatId, strDialysisDate, decPlural, dtTargetDate, true, tbIndPlan, true);
            if (null == tbIndAdd)
            {
                return false;
            }
            // レコードが1件以上存在する場合は更新情報ありと判断
            if (0 < tbIndAdd.Rows.Count)
            {
                return true;
            }

            // ---------------------------------
            // 条件指示情報
            // ---------------------------------
            DataTable tbIndCond = GetIndCond(db, strPatId, strDialysisDate, decPlural, dtTargetDate, tbIndPlan, true, visibleStartTime);
            if (null == tbIndCond)
            {
                return false;
            }
            // レコードが1件以上存在する場合は更新情報ありと判断
            if (0 < tbIndCond.Rows.Count)
            {
                return true;
            }

            // ---------------------------------
            // 医材指示情報
            // ---------------------------------
            DataTable tbIndEquip = GetIndEquip(db, strPatId, strDialysisDate, decPlural, dtTargetDate, true, tbIndPlan, true);
            if (null == tbIndEquip)
            {
                return false;
            }
            // レコードが1件以上存在する場合は更新情報ありと判断
            if (0 < tbIndEquip.Rows.Count)
            {
                return true;
            }

            // 変更無し
            return false;
        }


        private static DataTable GetIndPlan(DBCtrl db, string strPatId, string strDialysisDate, decimal decPlural, DateTime? dtTargetDate, bool isGetFuture)
        {


            // 透析日を FnwDate に変換(引数チェックしているので TryParse しない)
            FnwDate fnwDialysisDate = FnwDate.YyyyMmDd(strDialysisDate);

            // 予定指示情報取得(翻訳データ無し)
            DataTable tbIndPlan = ProcSelectIndDialysisPlan(db, strPatId, strDialysisDate, decPlural, fnwDialysisDate, dtTargetDate, isGetFuture);
            if (null == tbIndPlan)
            {
                return null;
            }
            // 未来情報取得時はここでreturn
            if (isGetFuture)
            {
                return tbIndPlan;
            }
            // 取得結果が0件の場合、そのまま返す
            if (0 == tbIndPlan.Rows.Count)
            {

                return tbIndPlan;
            }


            // ------------------------------------------------------------
            // 取得出来た場合は、翻訳データを設定(ベッド、クール、指示者)
            // ------------------------------------------------------------

            // 取得予定指示情報
            DataRow rowIndPlan = tbIndPlan.Rows[0];

            // 透析日が本日より過去かどうかの確認
            // 本日より過去の場合、その日付時点でのマスタ情報を取得するための
            // 指定日時を設定
            DateTime? dtUpdate = null;
            if (fnwDialysisDate < FnwDate.Today)
            {
                dtUpdate = fnwDialysisDate.OnlyDate.AddDays(1).AddSeconds(-1);
            }

            // ベッド名設定
            if (true == FnwNumber.Is(rowIndPlan["BED_NO"]) && false == int.Equals(NonReg.BED_NO, FnwNumber.ToDecimal(rowIndPlan["BED_NO"])))
            {
                decimal decBedNo = FnwNumber.ToDecimal(rowIndPlan["BED_NO"]);

                // ベッドマスタから対象ベッドを取得
                DataTable tbMstBed = SelectMstBed(db, dtUpdate, decBedNo);
                if (null == tbMstBed)
                {
                    return null;
                }
            }
            // クール名設定
            string strKur = rowIndPlan["KUR_CD"] as string;
            if (false == string.IsNullOrEmpty(strKur) && false == string.Equals(NonReg.KUR_CD, strKur))
            {
                // クールマスタから対象クールを取得
                DataTable tbMstKur = SelectMstKur(db, dtUpdate, strKur);
                if (null == tbMstKur)
                {
                    return null;
                }


            }
            // 指示者名設定
            string strStaff = rowIndPlan["INDICATOR_CD"] as string;
            if (false == string.IsNullOrEmpty(strStaff))
            {
                // スタッフマスタから対象スタッフを取得
                DataTable tbMstStaff = SelectMstStaff(db, dtUpdate, strStaff, null);
                if (null == tbMstStaff)
                {
                    return null;
                }

            }

            return tbIndPlan;
        }

        private static DataTable ProcSelectIndDialysisPlan(DBCtrl db, string strPatId, string strDialysisDate, decimal decPlural, FnwDate fnwDialysisDate, DateTime? dtTargetDate, bool isGetFuture)
        {
            // 予定指示情報取得
            DataTable tbIndPlan = SelectIndDialysisPlan(db, strPatId, strDialysisDate, decPlural);
            if (null == tbIndPlan)
            {
                return null;
            }
            if (0 == tbIndPlan.Rows.Count)
            {
                return CreateTableIndPlan();
            }

            // スケジュール情報取得
            string strIndId = strPatId + strDialysisDate + decPlural.ToString();
            DataTable tbSch = SelectSchDialysisPlan(db, strIndId);
            if (null == tbSch)
            {
                return null;
            }
            if (0 == tbSch.Rows.Count)
            {
                // 0件の場合はそのまま返す

                return CreateTableIndPlan();
            }

            // 予定指示情報格納用
            DataRow[] row = new DataRow[0];
            // 予定作成区分によって分岐
            string strOpe = tbSch.Rows[0]["OPE_IND_PLAN"] as string;
            if (true == dtTargetDate.HasValue)
            {
                // 指定抽出日時が存在する場合
                if (isGetFuture)
                {
                    // 未来情報取得の場合
                    row = tbIndPlan.Select(string.Format("#{0}# < UP_DATE and OPE_IND_PLAN = '{1}'", dtTargetDate.Value, strOpe));
                }
                else
                {
                    // 過去情報取得の場合
                    row = tbIndPlan.Select(string.Format("UP_DATE <= #{0}# and OPE_IND_PLAN = '{1}'", dtTargetDate.Value, strOpe));
                }
            }
            else
            {
                // 指定抽出日時が存在しない場合
                row = tbIndPlan.Select(string.Format("OPE_IND_PLAN = {0}", strOpe));
            }
            // 取得した情報の中でも最新情報に抽出
            if (0 != row.Length)
            {
                row = row.CopyToDataTable().Select("UP_DATE = max(UP_DATE) and DEL_FLG = '0'");
            }

            // 取得結果が0件の場合
            if (0 == row.Length)
            {
                if (false == isGetFuture)
                {
                    // 指定した条件の予定指示が存在しない

                    return null;
                }

                return CreateTableIndPlan();
            }

            // --------------------------------------------
            // 取得指示情報を戻り値用データテーブルに設定
            // --------------------------------------------
            // 戻り値用データテーブル
            DataTable tbMain = CreateTableIndPlan();
            DataRow rowMain = tbMain.NewRow();

            // 「設定値(VALUE_○W○N)」の取得カラム名設定用
            string strValue = null;

            // 定期指示 or 臨時指示で分岐
            switch (strOpe)
            {
                // 定期指示
                case "0":

                    // 更新日時
                    rowMain["UP_DATE"] = row[0]["UP_DATE"];
                    // 指示者コード
                    rowMain["INDICATOR_CD"] = row[0]["INDICATOR_CD"];
                    rowMain["UPDATE_STAFF_CD"] = row[0]["UPDATE_STAFF_CD"];
                    // 予定作成区分
                    rowMain["OPE_IND_PLAN"] = row[0]["OPE_IND_PLAN"];

                    // 設定値の確認(※後で関数化した方がいいで)
                    // @abe 隔日透析対応
                    // 予定指示開始日を取得
                    FnwDate planStart;
                    if (false == FnwDate.TryYyyyMmDd(row[0]["IND_START_DATE"].ToString(), out planStart))
                    {

                        return null;
                    }
                    // サイクル週数を取得
                    decimal decCycleWeek = decimal.One;
                    if (true == FnwNumber.Is(row[0]["CYCLE_WEEK"]))
                    {
                        decCycleWeek = FnwNumber.ToDecimal(row[0]["CYCLE_WEEK"]);
                    }
                    // 予定指示の設定値カラム名を取得
                    strValue = GetIndPlanValueColumnName(fnwDialysisDate, planStart, strOpe, decCycleWeek);
                    // 設定値を取得
                    strValue = row[0][strValue] as string;

                    if (true == string.IsNullOrEmpty(strValue))
                    {
                        return CreateTableIndPlan();
                    }
                    else if (8 != strValue.Length)
                    {

                        return null;
                    }
                    else
                    {
                        // ベッド番号
                        string strBed = strValue.Substring(0, 4);
                        decimal decBedNo;
                        if (false == decimal.TryParse(strBed, out decBedNo))
                        {

                            return null;
                        }
                        rowMain["BED_NO"] = decBedNo;

                        // クールコード
                        rowMain["KUR_CD"] = strValue.Substring(4, 3);

                        // 条件指示・投薬指示・医材指示の設定値の参照順(○番目)
                        string strTurn = strValue.Substring(7, 1);
                        decimal decTurn;
                        if (false == decimal.TryParse(strTurn, out decTurn))
                        {
                            return null;
                        }
                        rowMain["TURN"] = decTurn;
                    }

                    break;

                // 臨時指示
                case "1":

                    // 更新日時
                    rowMain["UP_DATE"] = row[0]["UP_DATE"];
                    // 指示者コード
                    rowMain["INDICATOR_CD"] = row[0]["INDICATOR_CD"];
                    rowMain["UPDATE_STAFF_CD"] = row[0]["UPDATE_STAFF_CD"];

                    // 予定作成区分
                    rowMain["OPE_IND_PLAN"] = row[0]["OPE_IND_PLAN"];

                    // 設定値の確認(※後で関数化した方がいいで)
                    strValue = row[0]["VALUE_1W1N"] as string;
                    if (true == string.IsNullOrEmpty(strValue))
                    {
                        return null;
                    }
                    else if (8 != strValue.Length)
                    {

                        return null;
                    }
                    else
                    {
                        // ベッド番号
                        string strBed = strValue.Substring(0, 4);
                        decimal decBedNo;
                        if (false == decimal.TryParse(strBed, out decBedNo))
                        {
                            return null;
                        }
                        rowMain["BED_NO"] = decBedNo;
                        // クールコード
                        rowMain["KUR_CD"] = strValue.Substring(4, 3);

                        // 条件指示・投薬指示・医材指示の設定値の参照順(○番目)
                        string strTurn = strValue.Substring(7, 1);
                        decimal decTurn;
                        if (false == decimal.TryParse(strTurn, out decTurn) || decTurn < 1m)
                        {
                            return null;
                        }
                        rowMain["TURN"] = decTurn;
                    }

                    break;

                default:
                    return null;
            }
            tbMain.Rows.Add(rowMain);

            return tbMain;
        }

        private static DataTable SelectMstBed(DBCtrl db, DateTime? dtTarget, decimal? decBedNo)
        {
            bool isNew = true;
            bool isAll = true;
            IMakeSqlParameters param = db.GetIMakeSqlParameters();

            // 指定日時が存在する場合、SQLパラメータ設定
            if (true == dtTarget.HasValue)
            {
                isNew = false;
                param.AddParam(":REG_DATE", dtTarget);
            }
            // 指定情報が存在する場合SQLパラメータ設定
            if (true == decBedNo.HasValue)
            {
                isAll = false;
                param.AddParam(":BED_NO", decBedNo);
            }

            return db.SelectTable(SelectMstBed(isNew, isAll), param.GetParam());
        }

        public static string SelectMstBed(bool isNew, bool isAll)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append(@"
                    select
                        BED_NO,
                        BED_NAME,
                        DEL_FLG
                    from
                        MST_BED base
                    where
                        REG_DATE = (
                                    select
                                        max(REG_DATE)
                                    from
                                        MST_BED
                                    where
                                        BED_NO = base.BED_NO");

            // 最新取得ではなく日時指定の場合
            if (!isNew)
            {
                sb.Append(@"
                                    and
                                        REG_DATE <= :REG_DATE");
            }

            sb.Append(@"
                                   )");

            // 全情報ではなく指定情報の場合
            if (!isAll)
            {
                sb.Append(@"
                    and
                        BED_NO = :BED_NO
                    ");
            }

            return sb.ToString();
        }

        private static DataTable CreateTableIndPlan()
        {
            DataTable tb = new DataTable();

            // 更新日時
            tb.Columns.Add("UP_DATE", typeof(DateTime));
            // ベッド番号
            tb.Columns.Add("BED_NO", typeof(decimal));
            // ベッド名
            tb.Columns.Add("BED_NAME", typeof(string));
            // クールコード
            tb.Columns.Add("KUR_CD", typeof(string));
            // クール名
            tb.Columns.Add("KUR_NAME", typeof(string));
            // 指示者コード
            tb.Columns.Add("INDICATOR_CD", typeof(string));
            // 指示者コード
            tb.Columns.Add("UPDATE_STAFF_CD", typeof(string));
            // 指示者名
            tb.Columns.Add("INDICATOR_NAME", typeof(string));
            // 予定区分[定期or臨時]
            tb.Columns.Add("OPE_IND_PLAN", typeof(string));
            // 週何回目かの情報
            tb.Columns.Add("TURN", typeof(decimal));

            return tb;
        }
        public static string GetIndPlanValueColumnName(FnwDate date, FnwDate planStart, string strOpeIndPlan, decimal decCycleWeek)
        {
            // 戻り値初期化
            string strRet = string.Empty;

            if ("0".Equals(strOpeIndPlan))
            {
                // 定期指示の場合
                // 指定日の曜日値取得（月：１、火：２、水：３、木：４、金：５、土：６、日：７）
                int intIndWeekBit = ((int)date.OnlyDate.DayOfWeek + 6) % 7 + 1;

                if ("2".Equals(decCycleWeek.ToString()))
                {
                    // 隔日透析
                    if (0 == ((date.OnlyDate - GetMonday(planStart.OnlyDate)).Days / 7) % 2)
                    {
                        // 奇数週
                        strRet = string.Format("VALUE_1W{0}N", intIndWeekBit);
                    }
                    else
                    {
                        // 偶数週
                        strRet = string.Format("VALUE_2W{0}N", intIndWeekBit);
                    }
                }
                else
                {
                    // 通常透析
                    strRet = string.Format("VALUE_1W{0}N", intIndWeekBit);
                }
            }
            else
            {
                // 1日指示の場合は常に「VALUE_1W1N」に値があるはず
                strRet = "VALUE_1W1N";
            }

            return strRet;
        }

        private static DateTime GetMonday(DateTime dt)
        {
            // 指定日の曜日値取得（月：０、火：１、水：２、木：３、金：４、土：５、日：６）
            int intIndWeekBit = ((int)dt.DayOfWeek + 6) % 7;

            // 指定日当該週の月曜日取得
            return dt.AddDays(-intIndWeekBit).Date;
        }
        private static DataTable SelectSchDialysisPlan(DBCtrl db, string strIndId)
        {
            IMakeSqlParameters param = db.GetIMakeSqlParameters();
            param.AddParam(":IND_ID", strIndId);

            return db.SelectTable(SelectSchDialysisPlan(), param.GetParam());
        }
        public static string SelectSchDialysisPlan()
        {
            return @"
                    select
                        OPE_IND_PLAN
                    from
                        SCH_DIALYSIS_PLAN
                    where
                        IND_ID = :IND_ID
                    and
                        DUMMY_FLG = '0'
                    ";
        }

        private static DataTable SelectIndDialysisPlan(DBCtrl db, string strPatId, string strDialysisDate, decimal decPlural)
        {
            IMakeSqlParameters param = db.GetIMakeSqlParameters();
            param.AddParam(":PATID", strPatId);
            param.AddParam(":DIALYSIS_DATE", strDialysisDate);
            param.AddParam(":PLURAL", decPlural);

            return db.SelectTable(SelectIndDialysisPlan(), param.GetParam());
        }
        public static string SelectIndDialysisPlan()
        {
            return @"
                    select
                        UP_DATE,
                        UPDATE_STAFF_CD,
                        IND_START_DATE,
                        IND_END_DATE,
                        IND_CLASS,
                        VALUE_1W1N,
                        VALUE_1W2N,
                        VALUE_1W3N,
                        VALUE_1W4N,
                        VALUE_1W5N,
                        VALUE_1W6N,
                        VALUE_1W7N,
                        VALUE_2W1N,
                        VALUE_2W2N,
                        VALUE_2W3N,
                        VALUE_2W4N,
                        VALUE_2W5N,
                        VALUE_2W6N,
                        VALUE_2W7N,
                        INDICATOR_CD,
                        DEL_FLG,
                        OPE_IND_PLAN,
                        CYCLE_WEEK
                    from
                        IND_DIALYSIS_PLAN
                    where
                        PATID = :PATID
                    and
                        PLURAL = :PLURAL
                    and
                        IND_START_DATE <= :DIALYSIS_DATE
                    and
                        :DIALYSIS_DATE <= IND_END_DATE
                    ";
        }
        private static DataTable SelectMstStaff(DBCtrl db, DateTime? dtTarget, string strStaff, string seriesCd)
        {
            bool isNew = true;
            bool isAll = true;
            IMakeSqlParameters param = db.GetIMakeSqlParameters();

            // 指定日時が存在する場合、SQLパラメータ設定
            if (true == dtTarget.HasValue)
            {
                isNew = false;
                param.AddParam(":UP_DATE", dtTarget);
            }
            // 指定情報が存在する場合SQLパラメータ設定
            if (false == string.IsNullOrEmpty(strStaff))
            {
                isAll = false;
                param.AddParam(":STAFF_CD", strStaff);
            }
            else
            {
                param.AddParam(":SERIES_CD", seriesCd);
            }

            return db.SelectTable(SelectMstStaff(isNew, isAll), param.GetParam());
        }
        public static string SelectMstStaff(bool isNew, bool isAll)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append(@"
                    select
                        STAFF_CD,
                        TRIM(STAFF_NAME) AS STAFF_NAME,
                        DEL_FLG
                    from
                        MST_STAFF base
                    where
                        UP_DATE = (
                                   select
                                       max(UP_DATE)
                                   from
                                       MST_STAFF
                                   where
                                       STAFF_CD = base.STAFF_CD");

            // 最新取得ではなく日時指定の場合
            if (!isNew)
            {
                sb.Append(@"
                                   and
                                       UP_DATE <= :UP_DATE");
            }

            sb.Append(@"
                                  )");

            // 全情報ではなく指定情報の場合
            if (!isAll)
            {
                sb.Append(@"
                    and
                        STAFF_CD = :STAFF_CD
                    ");
            }
            else
            {
                sb.Append(@"
                    and
                        1 = FN_SERIES_STAFF_FILTER(:SERIES_CD, base.STAFF_CD) 
                    ");
            }

            return sb.ToString();
        }

        private static DataTable SelectMstKur(DBCtrl db, DateTime? dtTarget, string strKur)
        {
            bool isNew = true;
            bool isAll = true;
            IMakeSqlParameters param = db.GetIMakeSqlParameters();

            // 指定日時が存在する場合、SQLパラメータ設定
            if (true == dtTarget.HasValue)
            {
                isNew = false;
                param.AddParam(":UP_DATE", dtTarget);
            }
            // 指定情報が存在する場合SQLパラメータ設定
            if (false == string.IsNullOrEmpty(strKur))
            {
                isAll = false;
                param.AddParam(":KUR_CD", strKur);
            }

            return db.SelectTable(SelectMstKur(isNew, isAll), param.GetParam());
        }

        public static string SelectMstKur(bool isNew, bool isAll)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append(@"
                            select
                                KUR_CD,
                                KUR_NAME,
                                DEL_FLG
                            from
                                MST_KUR base
                            where
                                UP_DATE = (
                                           select
                                               max(UP_DATE)
                                           from
                                               MST_KUR
                                           where
                                               KUR_CD = base.KUR_CD");

            // 最新取得ではなく日時指定の場合
            if (!isNew)
            {
                sb.Append(@"
                                           and
                                               UP_DATE <= :UP_DATE");
            }

            sb.Append(@"
                                          )");

            // 全情報ではなく指定情報の場合
            if (!isAll)
            {
                sb.Append(@"
                            and
                                KUR_CD = :KUR_CD
                            ");
            }

            return sb.ToString();
        }
        private class NonReg
        {
            /// <summary>クール未登録コード</summary>
            public const string KUR_CD = "NON";
            /// <summary>ベッド未登録番号</summary>
            public const decimal BED_NO = 0;
        }

        private static DataTable GetIndMedi(DBCtrl db, string strPatId, string strDialysisDate, decimal decPlural, DateTime? dtTargetDate, bool isGetDelete, DataTable tbIndPlan, bool isGetFuture)
        {


            // 透析日を FnwDate に変換(引数チェックしているので TryParse しない)
            FnwDate fnwDialysisDate = FnwDate.YyyyMmDd(strDialysisDate);

            // 透析日が本日より過去かどうかの確認
            // 本日より過去の場合、その日付時点でのマスタ情報を取得するための
            // 指定日時を設定
            DateTime? dtUpdate = null;
            if (fnwDialysisDate < FnwDate.Today)
            {
                dtUpdate = fnwDialysisDate.OnlyDate.AddDays(1).AddSeconds(-1);
            }

           

            // 指示作成区分の設定
            string strOpeIndPlan = tbIndPlan.Rows[0]["OPE_IND_PLAN"] as string;

            // 投薬指示情報取得時に使用する、更新日時と比較用日時
            DateTime dtIndUpdate = DateTime.Now;
            if (true == dtTargetDate.HasValue)
            {
                // 確認日時が存在する場合は、その日付を使用する
                dtIndUpdate = dtTargetDate.Value;
            }
            // 投薬指示情報取得
            DataTable tbIndMedi = SelectIndDialysisMedi(db, strPatId, strDialysisDate, decPlural, strOpeIndPlan, dtIndUpdate, isGetFuture);
            if (null == tbIndMedi)
            {
                return null;
            }
            if (0 == tbIndMedi.Rows.Count)
            {
                // 投薬指示 0件
                return CreateTableIndMedi();
            }

            // --------------------------------------------
            // 取得指示情報を戻り値用データテーブルに設定
            // --------------------------------------------
            // 戻り値用データテーブル
            DataTable tbMain = CreateTableIndMedi();
            DataRow rowMain;

            // その週の何回目かの情報の設定(VALUE_1W○N)
            if (false == FnwNumber.Is(tbIndPlan.Rows[0]["TURN"]))
            {

                return null;
            }
            int intTurn = (int)FnwNumber.ToDecimal(tbIndPlan.Rows[0]["TURN"]);

            // 取得した投薬指示情報(DataTable)から有効最新情報を抽出し、戻り値用データテーブルに設定
            // 該当項目番号(CTL_NO)を取得
            for (int i = 0; i < tbIndMedi.Rows.Count; i++)
            {
                rowMain = tbMain.NewRow();

                // 該当行のデータを取得
                DataRow rowMedi = tbIndMedi.Rows[i];

                // 中止されていない投薬のみ取得する場合は、削除フラグを確認
                if (!isGetDelete && false == "0".Equals(rowMedi["DEL_FLG"]))
                {
                    continue;
                }

                // ------------------------------------------------------------------------------------------------
                // 該当投薬の抽出②
                // 曜日パターン(DAY_PATTERN)、月毎投与設定(COUNT_EVERY_MONTH)による抽出
                // (※抽出した該当投薬指示の削除フラグが'0'以外の場合、以下の曜日パターンによる処理は行わない)
                // ------------------------------------------------------------------------------------------------
                // その週の何回目かのカラム名(VALUE_○W○N)設定用の変数
                string strTrun = null;

                if ("0".Equals(rowMedi["DEL_FLG"]))
                {
                    // 曜日パターン(DAY_PATTERN)取得
                    string strDayPattern = rowMedi["DAY_PATTERN"] as string;
                    if (true == string.IsNullOrEmpty(strDayPattern) || strDayPattern.Length < 7)
                    {

                        return null;
                    }

                    // 月毎投与設定(COUNT_EVERY_MONTH)取得
                    decimal decCountEveryMonth;
                    if (false == FnwNumber.Is(rowMedi["COUNT_EVERY_MONTH"]))
                    {

                        return null;
                    }
                    decCountEveryMonth = FnwNumber.ToDecimal(rowMedi["COUNT_EVERY_MONTH"]);

                    // 月毎投与設定(COUNT_EVERY_MONTH)によって分岐
                    int intWeekCnt = 0;
                    switch ((CountEveryMonth)decCountEveryMonth)
                    {
                        // 月毎投与ではない
                        case CountEveryMonth.NON:

                            // 投薬指示の指示開始日を取得
                            FnwDate fnwIndStartDate;
                            if (false == FnwDate.TryYyyyMmDd(rowMedi["IND_START_DATE"] as string, out fnwIndStartDate))
                            {

                                return null;
                            }

                            // 透析開始日が指示開始日から何週間後にあたるかを確認
                            intWeekCnt = WeekCount(fnwIndStartDate.OnlyDate, fnwDialysisDate.OnlyDate);
                            if (intWeekCnt < 0)
                            {
                                // 先週以前なので、エラーとする(既に絞込みを掛けているため、このようなデータが取得されるはずがないため)
                                return null;
                            }

                            // 該当する週かどうかのチェック
                            if (0 != intWeekCnt % (strDayPattern.Length / 7))
                            {
                                if (isGetDelete)
                                {
                                    // 投薬パターンが変更されているので削除扱いで取得する
                                    rowMedi["DEL_FLG"] = "1";
                                }
                                else
                                {
                                    // 該当する週ではないので、次の投薬へ
                                    continue;
                                }
                            }

                            // 有効指示の曜日かどうかチェック
                            strDayPattern = strDayPattern.Substring((intTurn - 1), 1);
                            if (true != "1".Equals(strDayPattern))
                            {
                                if (isGetDelete)
                                {
                                    // 投薬パターンが変更されているので削除扱いで取得する
                                    rowMedi["DEL_FLG"] = "1";
                                }
                                else
                                {
                                    continue;
                                }
                            }

                            // その週の何回目かの情報の設定(VALUE_1W○N)
                            strTrun = "VALUE_1W" + intTurn.ToString() + "N";

                            break;

                        // 1回/月の投与
                        case CountEveryMonth.ONE_TIME:

                            // 曜日パターン(DAY_PATTERN)の文字列長チェック
                            if (28 != strDayPattern.Length)
                            {
                                return null;
                            }

                            // 透析日の月の最初の月曜日を取得
                            DateTime dtFirstMonday = DateFirstMonday(fnwDialysisDate.OnlyDate);

                            // 月の最初の月曜日から、透析日が何週後かを確認
                            intWeekCnt = WeekCount(dtFirstMonday, fnwDialysisDate.OnlyDate);
                            if (intWeekCnt < 0)
                            {
                                // 先週以前なので、次の投薬へ
                                // (月一投与以外と動作が異なる ⇒ 透析日が月の最初の月曜日の前週となることがあるため)
                                continue;
                            }
                            if (3 < intWeekCnt)
                            {
                                // 4週以降なので、次の投薬へ(月一投与は3週目までしか登録できないため)
                                continue;
                            }

                            // 該当する部分の曜日パターンを取得
                            strDayPattern = strDayPattern.Substring((intWeekCnt * 7), 7);

                            // 有効指示の曜日かどうかチェック
                            strDayPattern = strDayPattern.Substring((intTurn - 1), 1);
                            // @abe 隔日透析NKK受入NG対応 #1022隔日透析NG一覧 No.14
                         
                            if (true != "1".Equals(strDayPattern))
                            {
                                if (isGetDelete)
                                {
                                    // 投薬パターンが変更されているので削除扱いで取得する
                                    rowMedi["DEL_FLG"] = "1";
                                }
                                else
                                {
                                    continue;
                                }
                            }

                            // その週の何回目かの情報の設定(VALUE_○W○N)
                            strTrun = "VALUE_" + (intWeekCnt + 1).ToString() + "W" + intTurn.ToString() + "N";

                            break;

                        default:

                            return null;
                    }
                }

                // 未来情報取得時はここでreturn
                if (isGetFuture)
                {
                    tbMain.Rows.Add(rowMain);
                    return tbMain;
                }

                // -----------------
                // 以下、値を設定
                // -----------------

                // 項目番号
                rowMain["CTL_NO"] = rowMedi["CTL_NO"];
                // 更新日時
                rowMain["UP_DATE"] = rowMedi["UP_DATE"];
                // 指示削除フラグ
                rowMain["DEL_FLG"] = rowMedi["DEL_FLG"];

                // 薬剤情報
                // セット薬剤フラグ
                string strSetMediFlg = rowMedi["SET_MEDICINE_FLG"] as string;
                rowMain["SET_MEDI_FLG"] = strSetMediFlg;
                // 薬剤コード
                string strMediCode = rowMedi["MEDICINE_CD"] as string;
                if (true == string.IsNullOrEmpty(strMediCode))
                {

                    return null;
                }
                rowMain["MEDICINE_CD"] = strMediCode;

                // 薬剤マスタ(セット薬剤名称マスタ)から情報取得
                string strMediName;
                string strClassCd;
                string strClassName;
                string strUnit;
                string dispFlg;
                if (false == ProcGetMedicineInfo(db, dtUpdate, strMediCode, strSetMediFlg, out strMediName, out strUnit, out strClassCd, out strClassName, out dispFlg))
                {
                    return null;
                }

                // 手技情報
                string strProcedureCd = rowMedi["PROCEDURE_CD"] as string;
                if (false == string.IsNullOrEmpty(strProcedureCd))
                {
                    // 手技コード
                    rowMain["PROCEDURE_CD"] = strProcedureCd;

                    // 手技マスタ情報取得
                    DataTable tbMstProcedure = SelectMstProcedure(db, dtUpdate, strProcedureCd);
                    if (null == tbMstProcedure)
                    {
                        return null;
                    }

                }

                // 投与時間帯情報
                string strTimingCd = rowMedi["TIMING_CD"] as string;
                if (false == string.IsNullOrEmpty(strTimingCd))
                {
                    // 投与時間帯コード
                    rowMain["TIMING_CD"] = strTimingCd;

                    // 投与時間帯マスタ情報取得
                    DataTable tbMstTiming = SelectMstTiming(db, dtUpdate, strTimingCd);
                    if (null == tbMstTiming)
                    {
                        return null;
                    }

                }

                // コメント
                rowMain["COMMENTS"] = rowMedi["COMMENTS"];

                // 指示者情報
                string strStaffCd = rowMedi["INDICATOR_CD"] as string;
                if (false == string.IsNullOrEmpty(strStaffCd))
                {
                    // 指示者コード
                    rowMain["INDICATOR_CD"] = strStaffCd;

                    // スタッフマスタ情報取得
                    DataTable tbMstStaff = SelectMstStaff(db, dtUpdate, strStaffCd, null);
                    if (null == tbMstStaff)
                    {
                        return null;
                    }

                }

                // 戻り値用データテーブルに格納
                tbMain.Rows.Add(rowMain);
            }

            return tbMain;
        }
        private static DataTable SelectIndDialysisMedi(DBCtrl db, string strPatId, string strDialysisDate, decimal decPlural, string strOpeIndPlan, DateTime dtTargetDate, bool isGetFuture)
        {
            IMakeSqlParameters param = db.GetIMakeSqlParameters();
            param.AddParam(":PATID", strPatId);
            param.AddParam(":DIALYSIS_DATE", strDialysisDate);
            param.AddParam(":PLURAL", decPlural);
            param.AddParam(":OPE_IND_PLAN", strOpeIndPlan);
            param.AddParam(":UP_DATE", dtTargetDate);

            return db.SelectTable(SelectIndDialysisMedi(isGetFuture), param.GetParam());
        }
        public static string SelectIndDialysisMedi(bool isGetFuture)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append(@"
                        select
                            CTL_NO,
                            UP_DATE,
                            UPDATE_STAFF_CD,
                            IND_START_DATE,
                            IND_END_DATE,
                            IND_CLASS,
                            DAY_PATTERN,
                            MEDICINE_CD,
                            SET_MEDICINE_FLG,
                            TIMING_CD,
                            PROCEDURE_CD,
                            VALUE_1W1N,
                            VALUE_1W2N,
                            VALUE_1W3N,
                            VALUE_1W4N,
                            VALUE_1W5N,
                            VALUE_1W6N,
                            VALUE_1W7N,
                            VALUE_2W1N,
                            VALUE_2W2N,
                            VALUE_2W3N,
                            VALUE_2W4N,
                            VALUE_2W5N,
                            VALUE_2W6N,
                            VALUE_2W7N,
                            VALUE_3W1N,
                            VALUE_3W2N,
                            VALUE_3W3N,
                            VALUE_3W4N,
                            VALUE_3W5N,
                            VALUE_3W6N,
                            VALUE_3W7N,
                            VALUE_4W1N,
                            VALUE_4W2N,
                            VALUE_4W3N,
                            VALUE_4W4N,
                            VALUE_4W5N,
                            VALUE_4W6N,
                            VALUE_4W7N,
                            INDICATOR_CD,
                            COMMENTS,
                            DEL_FLG,
                            OPE_IND_PLAN,
                            COUNT_EVERY_MONTH
                        from
                            IND_DIALYSIS_MEDI base
                        where
                            UP_DATE =
                            (
                                select
                                    max(UP_DATE)
                                from
                                    IND_DIALYSIS_MEDI
                                where
                                    base.PATID = PATID
                                and
                                    base.PLURAL = PLURAL
                                and
                                    base.CTL_NO = CTL_NO");

            if (isGetFuture)
            {
                // 未来情報を取得する場合
                sb.Append(@"
                                and
                                    :UP_DATE < UP_DATE");
            }
            else
            {
                // 未来情報を取得しない場合
                sb.Append(@"
                                and
                                    UP_DATE <= :UP_DATE");
            }

            sb.Append(@"
                                and
                                    IND_START_DATE <= :DIALYSIS_DATE
                                and
                                    :DIALYSIS_DATE <= IND_END_DATE
                                and
                                    OPE_IND_PLAN = :OPE_IND_PLAN
                            )
                        and
                            PATID = :PATID
                        and
                            PLURAL = :PLURAL
                        and
                            IND_START_DATE <= :DIALYSIS_DATE
                        and
                            :DIALYSIS_DATE <= IND_END_DATE
                        and
                            OPE_IND_PLAN = :OPE_IND_PLAN
                        order by
                            CTL_NO
                        ");

            return sb.ToString();
        }
        private static DataTable CreateTableIndMedi()
        {
            DataTable tb = new DataTable();

            // 項目番号
            tb.Columns.Add("CTL_NO", typeof(string));
            // 更新日時
            tb.Columns.Add("UP_DATE", typeof(DateTime));
            // セット薬剤フラグ
            tb.Columns.Add("SET_MEDI_FLG", typeof(string));
            // (セット)薬剤コード
            tb.Columns.Add("MEDICINE_CD", typeof(string));
            // (セット)薬剤名
            tb.Columns.Add("MEDICINE_NAME", typeof(string));
            // 薬剤分類コード
            tb.Columns.Add("MEDICINE_GROUP_CD", typeof(string));
            // 薬剤分類名
            tb.Columns.Add("MEDICINE_GROUP_NAME", typeof(string));
            // 数量
            tb.Columns.Add("AMOUNT", typeof(decimal));
            // 単位
            tb.Columns.Add("UNIT", typeof(string));
            // 手技コード
            tb.Columns.Add("PROCEDURE_CD", typeof(string));
            // 手技名
            tb.Columns.Add("PROCEDURE_NAME", typeof(string));
            // 投与時間帯コード
            tb.Columns.Add("TIMING_CD", typeof(string));
            // 投与時間帯名
            tb.Columns.Add("TIMING_NAME", typeof(string));
            // コメント
            tb.Columns.Add("COMMENTS", typeof(string));
            // 指示者コード
            tb.Columns.Add("INDICATOR_CD", typeof(string));
            // 指示者名
            tb.Columns.Add("INDICATOR_NAME", typeof(string));
            // 削除フラグ
            tb.Columns.Add("DEL_FLG", typeof(string));

            return tb;
        }
        private enum CountEveryMonth
        {
            /// <summary>月毎投与ではない</summary>
            NON = 0,
            /// <summary>1回/月の投与</summary>
            ONE_TIME,
            /// <summary>2回/月の投与(※まだない)</summary>
            TWO_TIMES,
        }
        private static int WeekCount(DateTime date1, DateTime date2)
        {
            date1 = DateMonday(date1);
            date2 = DateMonday(date2);

            return (date2 - date1).Days / 7;
        }
        private static DateTime DateMonday(DateTime date)
        {
            int intDiff = DayOfWeek.Monday - date.DayOfWeek;
            if (0 < intDiff)
            {
                intDiff -= 7;
            }

            return date.AddDays(intDiff).Date;
        }

        private static DataTable SelectMstTiming(DBCtrl db, DateTime? dtTarget, string strTiming)
        {
            bool isNew = true;
            bool isAll = true;
            IMakeSqlParameters param = db.GetIMakeSqlParameters();

            // 指定日時が存在する場合、SQLパラメータ設定
            if (true == dtTarget.HasValue)
            {
                isNew = false;
                param.AddParam(":UP_DATE", dtTarget);
            }
            // 指定情報が存在する場合SQLパラメータ設定
            if (false == string.IsNullOrEmpty(strTiming))
            {
                isAll = false;
                param.AddParam(":TIMING_CD", strTiming);
            }

            return db.SelectTable(SelectMstTiming(isNew, isAll), param.GetParam());
        }
        public static String SelectMstTiming(bool isNew, bool isAll)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append(@"
                        select
                            TIMING_CD,
                            TIMING_NAME,
                            DEL_FLG
                        from
                            MST_TIMING base
                        where
                            UP_DATE = (
                                       select
                                           max(UP_DATE)
                                       from
                                           MST_TIMING
                                       where
                                           TIMING_CD = base.TIMING_CD");

            // 最新取得ではなく日時指定の場合
            if (!isNew)
            {
                sb.Append(@"
                                       and
                                           UP_DATE <= :UP_DATE");
            }

            sb.Append(@"
                                      )");

            // 全情報ではなく指定情報の場合
            if (!isAll)
            {
                sb.Append(@"
                        and
                            TIMING_CD = :TIMING_CD
                        ");
            }

            return sb.ToString();
        }

        private static bool ProcGetMedicineInfo(DBCtrl db, DateTime? dtUpdate, string strMedicineCd, string strSetMediFlg, out string strMediName, out string strUnit, out string strClassCd, out string strClassName, out string dispFlg)
        {
            strMediName = null;
            strUnit = null;
            strClassCd = null;
            strClassName = null;
            dispFlg = null;

            // セット薬剤フラグで分岐
            switch (strSetMediFlg)
            {
                // 薬剤
                case "0":

                    // 薬剤マスタ情報取得
                    DataTable tbMedi = SelectMstMedicine(db, dtUpdate, strMedicineCd);
                    if (null == tbMedi)
                    {
                        return false;
                    }
                    strMediName = tbMedi.Rows[0]["MEDICINE_NAME"].ToString();
                    strUnit = tbMedi.Rows[0]["UNIT"].ToString();
                    dispFlg = tbMedi.Rows[0]["DISP_FLG"].ToString();
                    break;

                // セット薬剤
                case "1":

                    // セット薬剤マスタ情報取得
                    DataTable tbSetMedi = SelectMstSetMediName(db, dtUpdate, strMedicineCd);
                    if (null == tbSetMedi)
                    {
                        return false;
                    }
                    strMediName = tbSetMedi.Rows[0]["SET_MEDICINE_NAME"].ToString();
                    if ("302".Equals(tbSetMedi.Rows[0]["MEDICINE_GROUP_CD"].ToString())
                        || "303".Equals(tbSetMedi.Rows[0]["MEDICINE_GROUP_CD"].ToString()))
                    {
                        strUnit = tbSetMedi.Rows[0]["IND_UNIT"].ToString();
                    }
                    else
                    {
                        strUnit = tbSetMedi.Rows[0]["UNIT"].ToString();
                    }
                    dispFlg = tbSetMedi.Rows[0]["DISP_FLG"].ToString();
                    break;

                default:
                    return false;
            }

            return true;
        }

        private static DataTable SelectMstSetMediName(DBCtrl db, DateTime? dtTarget, string strSetMedi)
        {
            bool isNew = true;
            bool isAll = true;
            IMakeSqlParameters param = db.GetIMakeSqlParameters();

            // 指定日時が存在する場合、SQLパラメータ設定
            if (true == dtTarget.HasValue)
            {
                isNew = false;
                param.AddParam(":UP_DATE", dtTarget);
            }
            // 指定情報が存在する場合SQLパラメータ設定
            if (false == string.IsNullOrEmpty(strSetMedi))
            {
                isAll = false;
                param.AddParam(":SET_MEDICINE_CD", strSetMedi);
            }

            return db.SelectTable(SelectMstSetMediName(isNew, isAll), param.GetParam());
        }
        public static string SelectMstSetMediName(bool isNew, bool isAll)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append(@"
                    select
	                    medi.SET_MEDICINE_CD,
	                    medi.SET_MEDICINE_NAME,
	                    medi.UNIT,
	                    medi.IND_UNIT,
	                    medi.MEDICINE_GROUP_CD,
	                    class.CLASS_NAME,
	                    medi.DEL_FLG,
                        medi.DISP_FLG
                    from
	                    (
		                    select
			                    base.SET_MEDICINE_CD,
			                    SET_MEDICINE_NAME,
			                    UNIT,
			                    IND_UNIT,
			                    MEDICINE_GROUP_CD,
			                    DEL_FLG,
                                decode(base.DEL_FLG,'1','0',new.DISP_FLG) AS DISP_FLG
		                    from
			                    MST_SET_MEDI_NAME base
                            left join 
                                MST_SET_MEDI_NAME_SUB_NEW new 
                            on base.SET_MEDICINE_CD = new.SET_MEDICINE_CD 
		                    where
			                    base.UP_DATE =
			                    (
				                    select
					                    max(UP_DATE)
				                    from
					                    MST_SET_MEDI_NAME
				                    where
					                    SET_MEDICINE_CD = base.SET_MEDICINE_CD");

            // 最新取得ではなく日時指定の場合
            if (!isNew)
            {
                sb.Append(@"
				                    and
					                    UP_DATE <= :UP_DATE");
            }

            sb.Append(@"
			                    )");

            // 全情報ではなく指定情報の場合
            if (!isAll)
            {
                sb.Append(@"
		                    and
			                    base.SET_MEDICINE_CD = :SET_MEDICINE_CD");
            }
            sb.Append(@"
	                    ) medi,
	                    (
		                    select
			                    CLASS_CD,
			                    CLASS_NAME
		                    from
			                    MST_CLASS_NAME base
		                    where
			                    UP_DATE =
			                    (
				                    select
					                    max(UP_DATE)
				                    from
					                    MST_CLASS_NAME
				                    where
					                    CLASS_KIND = '3'
				                    and
					                    CLASS_CD = base.CLASS_CD");

            // 最新取得ではなく日時指定の場合
            if (!isNew)
            {
                sb.Append(@"
				                    and
					                    UP_DATE <= :UP_DATE");
            }
            sb.Append(@"
			                    )
		                    and
			                    CLASS_KIND = '3'
	                    ) class
                    where
	                    medi.MEDICINE_GROUP_CD = class.CLASS_CD(+)");

            return sb.ToString();
        }
        private static DataTable SelectMstMedicine(DBCtrl db, DateTime? dtTarget, string strMedi)
        {
            bool isNew = true;
            bool isAll = true;
            IMakeSqlParameters param = db.GetIMakeSqlParameters();

            // 指定日時が存在する場合、SQLパラメータ設定
            if (true == dtTarget.HasValue)
            {
                isNew = false;
                param.AddParam(":UP_DATE", dtTarget);
            }
            // 指定情報が存在する場合SQLパラメータ設定
            if (false == string.IsNullOrEmpty(strMedi))
            {
                isAll = false;
                param.AddParam(":MEDICINE_CD", strMedi);
            }

            return db.SelectTable(SelectMstMedicine(isNew, isAll), param.GetParam());
        }
        public static String SelectMstMedicine(bool isNew, bool isAll)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append(@"
                        select
	                        medi.MEDICINE_CD,
	                        medi.MEDICINE_NAME,
	                        medi.UNIT,
	                        medi.MEDICINE_GROUP_CD,
	                        class.CLASS_NAME,
	                        medi.DEL_FLG,
                            medi.DISP_FLG
                        from
	                        (
		                        select
			                        base.MEDICINE_CD,
			                        MEDICINE_NAME,
			                        UNIT,
			                        MEDICINE_GROUP_CD,
			                        DEL_FLG,
                                    decode(base.DEL_FLG,'1','0',new.DISP_FLG) AS DISP_FLG
		                        from
			                        MST_MEDICINE base
                                left join 
                                    MST_MEDICINE_SUB_NEW new 
                                on base.MEDICINE_CD = new.MEDICINE_CD 
		                        where
			                        base.UP_DATE =
			                        (
				                        select
					                        max(UP_DATE)
				                        from
					                        MST_MEDICINE
				                        where
					                        MEDICINE_CD = base.MEDICINE_CD");

            // 最新取得ではなく日時指定の場合
            if (!isNew)
            {
                sb.Append(@"
				                        and
					                        UP_DATE <= :UP_DATE");
            }

            sb.Append(@"
			                        )");

            // 全情報ではなく指定情報の場合
            if (!isAll)
            {
                sb.Append(@"
		                        and
			                        base.MEDICINE_CD = :MEDICINE_CD");
            }
            sb.Append(@"
	                        ) medi,
	                        (
		                        select
			                        CLASS_CD,
			                        CLASS_NAME
		                        from
			                        MST_CLASS_NAME base
		                        where
			                        UP_DATE =
			                        (
				                        select
					                        max(UP_DATE)
				                        from
					                        MST_CLASS_NAME
				                        where
					                        CLASS_KIND = '3'
				                        and
					                        CLASS_CD = base.CLASS_CD");

            // 最新取得ではなく日時指定の場合
            if (!isNew)
            {
                sb.Append(@"
				                        and
					                        UP_DATE <= :UP_DATE");
            }
            sb.Append(@"
			                        )
		                        and
			                        CLASS_KIND = '3'
	                        ) class
                        where
	                        medi.MEDICINE_GROUP_CD = class.CLASS_CD(+)
                        ");

            return sb.ToString();
        }
        private static DataTable SelectMstProcedure(DBCtrl db, DateTime? dtTarget, string strProcedure)
        {
            bool isNew = true;
            bool isAll = true;
            IMakeSqlParameters param = db.GetIMakeSqlParameters();

            // 指定日時が存在する場合、SQLパラメータ設定
            if (true == dtTarget.HasValue)
            {
                isNew = false;
                param.AddParam(":UP_DATE", dtTarget);
            }
            // 指定情報が存在する場合SQLパラメータ設定
            if (false == string.IsNullOrEmpty(strProcedure))
            {
                isAll = false;
                param.AddParam(":PROCEDURE_CD", strProcedure);
            }

            return db.SelectTable(SelectMstProcedure(isNew, isAll), param.GetParam());
        }
        public static String SelectMstProcedure(bool isNew, bool isAll)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append(@"
                select
                    PROCEDURE_CD,
                    PROCEDURE_NAME,
                    DEL_FLG
                from
                    MST_PROCEDURE base
                where
                    UP_DATE = (
                               select
                                   max(UP_DATE)
                               from
                                   MST_PROCEDURE
                               where
                                   PROCEDURE_CD = base.PROCEDURE_CD");

            // 最新取得ではなく日時指定の場合
            if (!isNew)
            {
                sb.Append(@"
                               and
                                   UP_DATE <= :UP_DATE");
            }

            sb.Append(@"
                              )");

            // 全情報ではなく指定情報の場合
            if (!isAll)
            {
                sb.Append(@"
                and
                    PROCEDURE_CD = :PROCEDURE_CD
                ");
            }

            return sb.ToString();
        }
        private static DateTime DateFirstMonday(DateTime date)
        {
            DateTime d = new DateTime(date.Year, date.Month, 1);

            return d.AddDays((8 - (int)d.DayOfWeek) % 7);
        }

        private static DataTable GetIndAddition(DBCtrl db, string strPatId, string strDialysisDate, decimal decPlural, DateTime? dtTargetDate, bool isGetDelete, DataTable tbIndPlan, bool isGetFuture)
        {


            // 透析日を FnwDate に変換(引数チェックしているので TryParse しない)
            FnwDate fnwDialysisDate = FnwDate.YyyyMmDd(strDialysisDate);

            // 透析日が本日より過去かどうかの確認
            // 本日より過去の場合、その日付時点でのマスタ情報を取得するための
            // 指定日時を設定
            DateTime? dtUpdate = null;
            if (fnwDialysisDate < FnwDate.Today)
            {
                dtUpdate = fnwDialysisDate.OnlyDate.AddDays(1).AddSeconds(-1);
            }


            // 指示作成区分の設定
            string strOpeIndPlan = tbIndPlan.Rows[0]["OPE_IND_PLAN"] as string;

            // 指示簿指示情報取得時に使用する、更新日時と比較用日時
            DateTime dtIndUpdate = DateTime.Now;
            if (true == dtTargetDate.HasValue)
            {
                // 確認日時が存在する場合は、その日付を使用する
                dtIndUpdate = dtTargetDate.Value;
            }
            // 指示簿指示情報取得
            DataTable tbIndAdd = SelectIndDialysisAdd(db, strPatId, strDialysisDate, decPlural, strOpeIndPlan, dtIndUpdate, isGetFuture);
            if (null == tbIndAdd)
            {
                return null;
            }
            if (0 == tbIndAdd.Rows.Count)
            {
                // 指示簿指示 0件
                return CreateTableIndAdd();
            }

            // --------------------------------------------
            // 取得指示情報を戻り値用データテーブルに設定
            // --------------------------------------------
            // 戻り値用データテーブル
            DataTable tbMain = CreateTableIndAdd();
            DataRow rowMain;

            // 該当項目番号(CTL_NO)を取得
            for (int i = 0; i < tbIndAdd.Rows.Count; i++)
            {
                rowMain = tbMain.NewRow();

                // 該当行のデータを取得
                DataRow rowAdd = tbIndAdd.Rows[i];

                // 中止されていない投薬のみ取得する場合は、削除フラグを確認
                if (!isGetDelete && false == "0".Equals(rowAdd["DEL_FLG"]))
                {
                    continue;
                }

                // 未来情報取得時はここでreturn
                if (isGetFuture)
                {
                    tbMain.Rows.Add(rowMain);
                    return tbMain;
                }

                // -----------------
                // 以下、値を設定
                // -----------------

                // 指示者名
                string strStaffCd = rowAdd["INDICATOR_CD"] as string;
                if (false == string.IsNullOrEmpty(strStaffCd))
                {
                    // スタッフマスタ情報取得
                    DataTable tbMstStaff = SelectMstStaff(db, dtUpdate, strStaffCd, null);
                    if (null == tbMstStaff)
                    {
                        return null;
                    }

                }

                // 戻り値用データテーブルに格納
                tbMain.Rows.Add(rowMain);
            }

            return tbMain;
        }
        private static DataTable CreateTableIndAdd()
        {
            DataTable tb = new DataTable();

            tb.Columns.Add("CTL_NO", typeof(string));
            tb.Columns.Add("UP_DATE", typeof(DateTime));
            tb.Columns.Add("ADDITION", typeof(string));
            tb.Columns.Add("INDICATOR_CD", typeof(string));
            tb.Columns.Add("INDICATOR_NAME", typeof(string));
            tb.Columns.Add("DEL_FLG", typeof(string));

            return tb;
        }
        /// <summary>
        /// 指示簿指示情報取得
        /// ①この関数を実行しただけでは有効な指示簿指示は取得不可(必ず事後処理を行うこと)
        /// ②引数チェックは、必ず呼び元で行うこと
        /// </summary>
        /// <param name="logInfo">ログクラス</param>
        /// <param name="db">DB操作クラス</param>
        /// <param name="strPatId">患者ID</param>
        /// <param name="strDialysisDate">透析日(yyyyMMdd 形式)</param>
        /// <param name="decPlural">同日複数回</param>
        /// <param name="strOpeIndPlan">指示作成区分('0':定期、'1':臨時)</param>
        /// <param name="dtTargetDate">抽出日時(更新日時と比較、最新情報を取得する場合はsysdate)</param>
        /// <param name="isGetFuture">
        /// 抽出日時と更新日時の比較方法
        /// (true:更新日時が抽出日時より未来の情報、false:更新日時が抽出日時以前の情報)
        /// (最新情報を取得する場合は false 指定)</param>
        /// <returns>指示簿指示情報</returns>
        private static DataTable SelectIndDialysisAdd(DBCtrl db, string strPatId, string strDialysisDate, decimal decPlural, string strOpeIndPlan, DateTime dtTargetDate, bool isGetFuture)
        {
            IMakeSqlParameters param = db.GetIMakeSqlParameters();
            param.AddParam(":PATID", strPatId);
            param.AddParam(":DIALYSIS_DATE", strDialysisDate);
            param.AddParam(":PLURAL", decPlural);
            param.AddParam(":OPE_IND_PLAN", strOpeIndPlan);
            param.AddParam(":UP_DATE", dtTargetDate);

            return db.SelectTable(SelectIndDialysisAdd(isGetFuture), param.GetParam());
        }
        /// <summary>
        /// 指示簿指示情報取得
        /// </remarks>
        public static string SelectIndDialysisAdd(bool isGetFuture)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append(@"
                    select
                        CTL_NO,
                        UP_DATE,
                        UPDATE_STAFF_CD,
                        IND_START_DATE,
                        IND_END_DATE,
                        IND_CLASS,
                        ADDITION,
                        INDICATOR_CD,
                        DEL_FLG,
                        OPE_IND_PLAN
                    from
                        IND_DIALYSIS_ADD base
                    where
                        UP_DATE =
                        (
                            select
                                max(UP_DATE)
                            from
                                IND_DIALYSIS_ADD
                            where
                                base.PATID = PATID
                            and
                                base.PLURAL = PLURAL
                            and
                                base.CTL_NO = CTL_NO");

            if (isGetFuture)
            {
                // 未来情報を取得する場合
                sb.Append(@"
                            and
                                :UP_DATE < UP_DATE");
            }
            else
            {
                // 未来情報を取得しない場合
                sb.Append(@"
                            and
                                UP_DATE <= :UP_DATE");
            }

            sb.Append(@"
                            and
                                IND_START_DATE <= :DIALYSIS_DATE
                            and
                                :DIALYSIS_DATE <= IND_END_DATE
                            and
                                OPE_IND_PLAN = :OPE_IND_PLAN
                        )
                    and
                        PATID = :PATID
                    and
                        PLURAL = :PLURAL
                    and
                        IND_START_DATE <= :DIALYSIS_DATE
                    and
                        :DIALYSIS_DATE <= IND_END_DATE
                    and
                        OPE_IND_PLAN = :OPE_IND_PLAN
                    order by
                        CTL_NO
                    ");

            return sb.ToString();
        }

        /// <summary>
        /// 条件指示情報取得
        /// ①最新情報
        /// ②予定自体が存在しない場合は null を返す
        /// ③存在しない場合は、レコードなしで返す
        /// </summary>
        /// <param name="logInfo">ログクラス</param>
        /// <param name="db">DB操作クラス(null の場合は関数内でインスタンス作成)</param>
        /// <param name="strPatId">患者ID</param>
        /// <param name="strDialysisDate">透析日(yyyyMMdd 形式)</param>
        /// <param name="decPlural">同日複数回</param>
        /// <param name="dtTargetDate">指定抽出日時(指定日時より過去or未来の更新日時で抽出。nullの場合は最新)</param>
        /// <param name="tbIndPlan">予定指示情報(null の場合は関数内で予定指示情報を取得)</param>
        /// <param name="isGetFuture">指定抽出日時の抽出方法(true: 指定日時から未来の更新日時、false: 指定日時より過去の更新日時)</param>
        /// <param name="seriesCd">系列施設コード</param>
        /// <param name="visibleStartTime">透析開始時刻　true:比較対象 false:比較対象外</param>
        /// <returns>条件指示情報(※isGetFuture がtrue の場合、レコードが取得された時点で即return)</returns>
        private static DataTable GetIndCond(DBCtrl db, string strPatId, string strDialysisDate, decimal decPlural, DateTime? dtTargetDate, DataTable tbIndPlan, bool isGetFuture, bool visibleStartTime)
        {

            // 透析日を FnwDate に変換(引数チェックしているので TryParse しない)
            FnwDate fnwDialysisDate = FnwDate.YyyyMmDd(strDialysisDate);

            // 指示作成区分の設定
            string strOpeIndPlan = tbIndPlan.Rows[0]["OPE_IND_PLAN"] as string;

            // 条件指示情報取得時に使用する、更新日時と比較用日時
            DateTime dtIndUpdate = DateTime.Now;
            if (true == dtTargetDate.HasValue)
            {
                // 確認日時が存在する場合は、その日付を使用する
                dtIndUpdate = dtTargetDate.Value;
            }
            // 条件指示情報取得
            DataTable tbIndCond = SelectIndDialysisCond(db, strPatId, strDialysisDate, decPlural, strOpeIndPlan, dtIndUpdate, isGetFuture);
            if (null == tbIndCond)
            {
                return null;
            }
            if (isGetFuture && 0 == tbIndCond.Rows.Count)
            {
                // 未来情報取得時で、条件指示 0件の場合
                return CreateTableIndCond();
            }

            // -------------------------
            // 各条件項目の確認・抽出
            // -------------------------

            // 透析日が本日より過去かどうかの確認
            // 本日より過去の場合、その日付時点でのマスタ情報を取得するための
            // 指定日時を設定
            DateTime? dtUpdate = null;
            if (fnwDialysisDate < FnwDate.Today)
            {
                dtUpdate = fnwDialysisDate.OnlyDate.AddDays(1).AddSeconds(-1);
            }

            // その週の何回目かの情報の設定(VALUE_1W○N)
            if (false == FnwNumber.Is(tbIndPlan.Rows[0]["TURN"]))
            {
                return null;
            }
            string strTrun = "VALUE_1W" + tbIndPlan.Rows[0]["TURN"].ToString() + "N";

            // 戻り値用データテーブル
            DataTable tbMain = CreateTableIndCond();
            DataRow rowMain = tbMain.NewRow();


            // ※共通で使用する値
            // 抗凝固剤関連で使用する単位
            string strAntiLiquidUnit = null;
            // 透析液関連で使用する単位
            string strDialysisLiquidUnit = null;
            // 補液関連で使用する単位
            string strReplenishLiquidUnit = null;
            // 治療条件設定情報
            DataTable tbSysTreatCond = null;

            // 条件項目の項目番号情報を取得し、条件項目数でループ
            CondCtlNo[] CtlNo = (CondCtlNo[])Enum.GetValues(typeof(CondCtlNo));
            for (int i = 0; i < CtlNo.Length; i++)
            {
                // 指定条件項目を抽出
                string strSelect = "CTL_NO = '" + ((int)CtlNo[i]).ToString("000") + "' and DEL_FLG = '0'";
                DataRow[] rowIndCond = tbIndCond.Select(strSelect);

                if (isGetFuture)
                {
                    // 指定日時よりも未来情報を取得する場合は、取得され次第return
                    if (0 < rowIndCond.Length)
                    {
                        //①CTL_NOが"001"
                        //②透析開始時刻が非表示
                        //①と②がTrueの場合、変更ログの対象としない
                        if ("001".Equals(((int)CtlNo[i]).ToString("000")) &&
                            false == visibleStartTime)
                        {
                            continue;
                        }
                        tbMain.Rows.Add(rowMain);
                        return tbMain;
                    }

                    // 1件も抽出されなかった場合は次へ
                    continue;
                }
                else
                {
                    // 必要な条件項目が存在しない場合
                    if (0 == rowIndCond.Length)
                    {
                        if (false == "001".Equals(((int)CtlNo[i]).ToString("000")))
                        {
                            // 透析開始時刻以外はレコードを作成せず、次の条件項目へ
                            continue;
                        }

                        //DataRow[]に行追加
                        DataRow dr = tbIndCond.NewRow();
                        //透析開始時刻が存在しない場合は追加する
                        // 項目番号
                        dr["CTL_NO"] = ((int)CtlNo[i]).ToString("000");

                        if (dtTargetDate.HasValue)
                        {
                            // 過去の透析開始時刻は、レコードが無い場合は予定指示から作るしかない(スケジュールは履歴が無いため)
                            DataTable tbIndKur = ProcSelectIndDialysisPlan(db, strPatId, strDialysisDate, decPlural, fnwDialysisDate, dtTargetDate, false);
                            if (null == tbIndKur)
                            {
                                return null;
                            }

                            if (0 == tbIndKur.Rows.Count)
                            {
                                // 予定指示 0件の場合、エラーとして返す
                                return null;
                            }

                            IMakeSqlParameters kurParam = db.GetIMakeSqlParameters();
                            kurParam.AddParam(":KUR_CD", tbIndKur.Rows[0]["KUR_CD"]);
                            // 前回確認した時点でのクールマスタ情報を取得する
                            kurParam.AddParam(":UP_DATE", dtTargetDate.Value);
                            DataTable mstKur = db.SelectTable(@"
                                        select
	                                        k.STANDARD_START_TIME
                                        from
	                                        MST_KUR k
                                        where
	                                        k.KUR_CD = :KUR_CD
                                        and
	                                        k.UP_DATE =
	                                        (
		                                        select
			                                        max(UP_DATE)
		                                        from
			                                        MST_KUR
		                                        where
			                                        k.KUR_CD = KUR_CD
		                                        and
			                                        UP_DATE <= :UP_DATE
	                                        )
                                        ", kurParam.GetParam());
                            if (null == mstKur)
                            {
                                return null;
                            }

                        }

                        //指示者と更新日時はバージョンアップ直後はNULL
                        // 更新日時
                        dr["UP_DATE"] = DBNull.Value;
                        // 指示者コード
                        dr["INDICATOR_CD"] = string.Empty;

                        //挿入
                        rowIndCond = new DataRow[] { dr };
                    }

                    // 有効な条件項目が2件以上存在する場合
                    if (1 < rowIndCond.Length)
                    {
                        // レコードを作成せず、次の条件項目へ
                        continue;
                    }
                }


                // ---------------------------------------------
                // 取得指示情報を戻り値用データテーブルに設定
                // ---------------------------------------------

                rowMain = tbMain.NewRow();

                // ※共通情報部分の設定
                // 項目番号
                rowMain["CTL_NO"] = rowIndCond[0]["CTL_NO"];
                // 更新日時
                rowMain["UP_DATE"] = rowIndCond[0]["UP_DATE"];
                // 治療条件設定
                rowMain["USE_FLG"] = true;
                // 指示者コード
                rowMain["INDICATOR_CD"] = rowIndCond[0]["INDICATOR_CD"];

                // ※共通情報部分以外の設定
                // 条件項目によって分岐
                switch ((CondCtlNo)CtlNo[i])
                {

                    // VA(003)
                    case CondCtlNo.VA:

                        // 値(VAコード)の取得
                        string strVaCd = rowIndCond[0][strTrun] as string;
                        if (true == string.IsNullOrEmpty(strVaCd))
                        {
                            // コードが存在しない場合は抜ける
                            break;
                        }

                        // VAコード
                        rowMain["VALUE"] = strVaCd;

                        // VAマスタ情報取得
                        DataTable tbMstVA = SelectMstVA(db, dtUpdate, strVaCd);
                        if (null == tbMstVA)
                        {
                            return null;
                        }

                        break;
                    // 治療方法(006)
                    case CondCtlNo.TREAT_ITEM:

                        // 値(治療方法コード)の取得
                        string strTreatItemCd = rowIndCond[0][strTrun] as string;
                        if (true == string.IsNullOrEmpty(strTreatItemCd))
                        {
                            // コードが存在しない場合は抜ける
                            break;
                        }

                        // 治療方法コード
                        rowMain["VALUE"] = strTreatItemCd;

                        // 治療項目マスタ情報取得
                        DataTable tbMstTreatItem = SelectMstTreatItem(db, dtUpdate, strTreatItemCd);
                        if (null == tbMstTreatItem)
                        {
                            return null;
                        }


                        // 治療条件設定情報取得
                        tbSysTreatCond = SelectSysTreatCondSetting(db, strTreatItemCd);
                        if (null == tbSysTreatCond)
                        {
                            return null;
                        }

                        break;


                    // 血液浄化器[ダイアライザ](008)
                    case CondCtlNo.DIALYZER:

                        // 値(ダイアライザコード)の取得
                        string strDialyzerCd = rowIndCond[0][strTrun] as string;
                        if (true == string.IsNullOrEmpty(strDialyzerCd))
                        {
                            // コードが存在しない場合は抜ける
                            break;
                        }

                        // ダイアライザコード
                        rowMain["VALUE"] = strDialyzerCd;

                        // ダイアライザマスタ情報取得
                        DataTable tbMstDialyzer = SelectMstDialyzer(db, dtUpdate, strDialyzerCd);
                        if (null == tbMstDialyzer)
                        {
                            return null;
                        }
                        break;

                    // 吸着カラム(009)
                    case CondCtlNo.ADSORB:

                        // 値(医材コード)の取得
                        string strAdsorbCd = rowIndCond[0][strTrun] as string;
                        if (true == string.IsNullOrEmpty(strAdsorbCd))
                        {
                            // コードが存在しない場合は抜ける
                            break;
                        }
                        // 医材コード
                        rowMain["VALUE"] = strAdsorbCd;

                        // 医療材料マスタ情報取得
                        DataTable tbMstAdsorb = SelectMstEquipment(db, dtUpdate, strAdsorbCd);
                        if (null == tbMstAdsorb)
                        {
                            return null;
                        }
                        break;

                    // 抗凝固剤(011)
                    case CondCtlNo.ANTI_LIQUID:

                        // 値(セット薬剤フラグ＋薬剤コード)を取得
                        string strAntiLiquidValue = rowIndCond[0][strTrun] as string;
                        if (true == string.IsNullOrEmpty(strAntiLiquidValue))
                        {
                            // コードが存在しない場合は抜ける
                            break;
                        }

                        // セット薬剤フラグ＋薬剤コード
                        rowMain["VALUE"] = strAntiLiquidValue;

                        // セット薬剤フラグ
                        string strAntiLiquidSetMediFlg = strAntiLiquidValue.Substring(0, 1);
                        // 薬剤コード
                        string strAntiLiquidCd = strAntiLiquidValue.Substring(1);

                        // 薬剤名格納用
                        string strAntiLiquidMediName;

                        // 薬剤マスタ(セット薬剤名称マスタ)から、薬剤名・単位情報の取得
                        if (false == ProcGetMedicineInfo(db, dtUpdate, strAntiLiquidCd, strAntiLiquidSetMediFlg, out strAntiLiquidMediName, out strAntiLiquidUnit))
                        {
                            return null;
                        }
                        break;


                    // 透析液(018)
                    case CondCtlNo.DIALYSIS_LIQUID:

                        // 値(セット薬剤フラグ＋薬剤コード)を取得
                        string strDialysisLiquidValue = rowIndCond[0][strTrun] as string;
                        if (true == string.IsNullOrEmpty(strDialysisLiquidValue))
                        {
                            // コードが存在しない場合は抜ける
                            break;
                        }

                        // セット薬剤フラグ＋薬剤コード
                        rowMain["VALUE"] = strDialysisLiquidValue;

                        // セット薬剤フラグ
                        string strDialysisLiquidSetMediFlg = strDialysisLiquidValue.Substring(0, 1);
                        // 薬剤コード
                        string strDialysisLiquidCd = strDialysisLiquidValue.Substring(1);

                        // 薬剤名格納用
                        string strDialysisLiquidMediName;

                        // 薬剤マスタ(セット薬剤名称マスタ)から、薬剤名・単位情報の取得
                        if (false == ProcGetMedicineInfo(db, dtUpdate, strDialysisLiquidCd, strDialysisLiquidSetMediFlg, out strDialysisLiquidMediName, out strDialysisLiquidUnit))
                        {
                            return null;
                        }
                        break;

                    // 補液(022)
                    case CondCtlNo.REP_LIQUID:

                        // 値(セット薬剤フラグ＋薬剤コード)を取得
                        string strReplenishLiquidValue = rowIndCond[0][strTrun] as string;
                        if (true == string.IsNullOrEmpty(strReplenishLiquidValue))
                        {
                            // コードが存在しない場合は抜ける
                            break;
                        }

                        // セット薬剤フラグ＋薬剤コード
                        rowMain["VALUE"] = strReplenishLiquidValue;

                        // セット薬剤フラグ
                        string strReplenishLiquidSetMediFlg = strReplenishLiquidValue.Substring(0, 1);
                        // 薬剤コード
                        string strReplenishLiquidCd = strReplenishLiquidValue.Substring(1);

                        // 薬剤名格納用
                        string strReplenishLiquidMediName;

                        // 薬剤マスタ(セット薬剤名称マスタ)から、薬剤名・単位情報の取得
                        if (false == ProcGetMedicineInfo(db, dtUpdate, strReplenishLiquidCd, strReplenishLiquidSetMediFlg, out strReplenishLiquidMediName, out strReplenishLiquidUnit))
                        {
                            return null;
                        }
                        break;

                    // 1次膜(039)
                    case CondCtlNo.FIRST_FILM:

                        // 値(医材コード)の取得
                        string strFirstFilmCd = rowIndCond[0][strTrun] as string;
                        if (true == string.IsNullOrEmpty(strFirstFilmCd))
                        {
                            // コードが存在しない場合は抜ける
                            break;
                        }
                        // 医材コード
                        rowMain["VALUE"] = strFirstFilmCd;

                        // 医療材料マスタ情報取得
                        DataTable tbMstFirstFilm = SelectMstEquipment(db, dtUpdate, strFirstFilmCd);
                        if (null == tbMstFirstFilm)
                        {
                            return null;
                        }
                        break;

                    // 2次膜(040)
                    case CondCtlNo.SECOND_FILM:

                        // 値(医材コード)の取得
                        string strSecondFilmCd = rowIndCond[0][strTrun] as string;
                        if (true == string.IsNullOrEmpty(strSecondFilmCd))
                        {
                            // コードが存在しない場合は抜ける
                            break;
                        }
                        // 医材コード
                        rowMain["VALUE"] = strSecondFilmCd;

                        // 医療材料マスタ情報取得
                        DataTable tbMstSecondFilm = SelectMstEquipment(db, dtUpdate, strSecondFilmCd);
                        if (null == tbMstSecondFilm)
                        {
                            return null;
                        }
                        break;

                    default:
                        return null;
                }

                // 戻り値用データテーブルに格納
                tbMain.Rows.Add(rowMain);
            }

            // 指定日時よりも未来情報を取得する場合はここで終了
            if (isGetFuture)
            {
                return CreateTableIndCond();
            }

            return tbMain;
        }
        private static DataTable CreateTableIndCond()
        {
            DataTable tb = new DataTable();

            // 項目番号
            tb.Columns.Add("CTL_NO", typeof(string));
            // 更新日時
            tb.Columns.Add("UP_DATE", typeof(DateTime));
            // 値(数量、コード)
            tb.Columns.Add("VALUE", typeof(string));
            // 翻訳名1
            tb.Columns.Add("VALUE_NAME_1", typeof(string));
            // 翻訳名2
            tb.Columns.Add("VALUE_NAME_2", typeof(string));
            // 単位
            tb.Columns.Add("UNIT", typeof(string));
            // 治療条件設定の使用/未使用フラグ
            tb.Columns.Add("USE_FLG", typeof(bool));
            // 指示者コード
            tb.Columns.Add("INDICATOR_CD", typeof(string));
            // 指示者名
            tb.Columns.Add("INDICATOR_NAME", typeof(string));

            return tb;
        }
        private static DataTable SelectMstEquipment(DBCtrl db, DateTime? dtTarget, string strEquip)
        {
            bool isNew = true;
            bool isAll = true;
            IMakeSqlParameters param = db.GetIMakeSqlParameters();

            // 指定日時が存在する場合、SQLパラメータ設定
            if (true == dtTarget.HasValue)
            {
                isNew = false;
                param.AddParam(":UP_DATE", dtTarget);
            }
            // 指定情報が存在する場合SQLパラメータ設定
            if (false == string.IsNullOrEmpty(strEquip))
            {
                isAll = false;
                param.AddParam(":EQUIP_CD", strEquip);
            }

            return db.SelectTable(SelectMstEquipment(isNew, isAll), param.GetParam());
        }
        public static String SelectMstEquipment(bool isNew, bool isAll)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append(@"
                    select
	                    equip.EQUIP_CD,
	                    equip.EQUIP_NAME,
	                    equip.EQUIP_GROUP_CD,
	                    class.CLASS_NAME,
	                    equip.UNIT,
	                    equip.DEL_FLG
                    from
	                    (
		                    select
			                    EQUIP_CD,
			                    EQUIP_NAME,
			                    EQUIP_GROUP_CD,
			                    UNIT,
			                    DEL_FLG
		                    from
			                    MST_EQUIPMENT base
		                    where
			                    UP_DATE =
			                    (
				                    select
					                    max(UP_DATE)
				                    from
					                    MST_EQUIPMENT
				                    where
					                    EQUIP_CD = base.EQUIP_CD");

            // 最新取得ではなく日時指定の場合
            if (!isNew)
            {
                sb.Append(@"
				                    and
					                    UP_DATE <= :UP_DATE");
            }

            sb.Append(@"
			                    )");

            // 全情報ではなく指定情報の場合
            if (!isAll)
            {
                sb.Append(@"
		                    and
			                    EQUIP_CD = :EQUIP_CD");
            }
            sb.Append(@"
	                    ) equip,
	                    (
		                    select
			                    CLASS_CD,
			                    CLASS_NAME
		                    from
			                    MST_CLASS_NAME base
		                    where
			                    UP_DATE =
			                    (
				                    select
					                    max(UP_DATE)
				                    from
					                    MST_CLASS_NAME
				                    where
					                    CLASS_KIND = '2'
				                    and
					                    CLASS_CD = base.CLASS_CD");

            // 最新取得ではなく日時指定の場合
            if (!isNew)
            {
                sb.Append(@"
				                    and
					                    UP_DATE <= :UP_DATE");
            }

            sb.Append(@"
			                    )
		                    and
			                    CLASS_KIND = '2'
	                    ) class
                    where
	                    equip.EQUIP_GROUP_CD = class.CLASS_CD(+)");

            return sb.ToString();
        }
        public enum CondCtlNo
        {
            /// <summary>透析開始時刻(001)</summary>
            START_TIME = 1,
            /// <summary>透析時間(002)</summary>
            DIALYSIS_TIME = 2,
            /// <summary>VA(003)</summary>
            VA = 3,
            /// <summary>DW(004)</summary>
            DW = 4,
            /// <summary>目標体重(005)</summary>
            TW = 5,
            /// <summary>治療方法(006)</summary>
            TREAT_ITEM = 6,
            /// <summary>除水量制限(007)</summary>
            REMOVE_WATER_LIMIT = 7,
            /// <summary>血液浄化器[ダイアライザ](008)</summary>
            DIALYZER = 8,
            /// <summary>吸着カラム(009)</summary>
            ADSORB = 9,
            /// <summary>血流量(010)</summary>
            BLOOD_MEASURE = 10,
            /// <summary>抗凝固剤(011)</summary>
            ANTI_LIQUID = 11,
            /// <summary>抗凝固剤ワンショット量(012)</summary>
            ANTI_ONESHOT = 12,
            /// <summary>抗凝固剤持続速度(013)</summary>
            ANTI_SPEED = 13,
            /// <summary>抗凝固剤持続総量(014)</summary>
            ANTI_TOTAL = 14,
            /// <summary>IP使用選択(015)</summary>
            IP_SELECT = 15,
            /// <summary>IPワンショット量(016)</summary>
            IP_MEASURE = 16,
            /// <summary>IP速度(017)</summary>
            IP_SPEED = 17,
            /// <summary>透析液(018)</summary>
            DIALYSIS_LIQUID = 18,
            /// <summary>透析液流量(019)</summary>
            DIALYSIS_FLOW = 19,
            /// <summary>透析液量(020)</summary>
            DIALYSIS_MEASURE = 20,
            /// <summary>透析液温度(021)</summary>
            DIALYSIS_TEMP = 21,
            /// <summary>補液(022)</summary>
            REP_LIQUID = 22,
            /// <summary>補液量(023)</summary>
            REP_MEASURE = 23,
            /// <summary>補液選択(024)</summary>
            REP_SELECT = 24,
            /// <summary>補液温度(025)</summary>
            REP_TEMP = 25,
            /// <summary>シングルニードル使用(029)</summary>
            SINGLE_NEEDLE = 29,
            /// <summary>補液使用数(030)</summary>
            REP_USE_COUNT = 30,
            /// <summary>IPスタート(031)</summary>
            IP_START = 31,
            /// <summary>自動ワンショット(032)</summary>
            IP_AUTO_ONESHOT = 32,
            /// <summary>IP電源自動切り(033)</summary>
            IP_AUTO_OFF = 33,
            /// <summary>IP電源自動切り時間(034)</summary>
            IP_AUTO_OFF_TIME = 34,
            /// <summary>IP電源OKモニタ切り(035)</summary>
            IP_OK_MON_OFF = 35,
            /// <summary>IP電源OKモニタ切り時間(036)</summary>
            IP_OK_MON_OFF_TIME = 36,
            /// <summary>IP速度最大値(037)</summary>
            IP_MAX_SPEED = 37,
            /// <summary>補液速度(038)</summary>
            REP_SPEED = 38,
            /// <summary>1次膜(039)</summary>
            FIRST_FILM = 39,
            /// <summary>2次膜(040)</summary>
            SECOND_FILM = 40,
        }


        public enum CheckCondCtlNo
        {
            /// <summary>透析開始時刻(001)</summary>
            START_TIME = 1,
            /// <summary>透析時間(002)</summary>
            DIALYSIS_TIME = 2,
            /// <summary>VA(003)</summary>
            VA = 3,
            /// <summary>DW(004)</summary>
            DW = 4,
            /// <summary>目標体重(005)</summary>
            TW = 5,
            /// <summary>治療方法(006)</summary>
            TREAT_ITEM = 6,
            /// <summary>除水量制限(007)</summary>
            REMOVE_WATER_LIMIT = 7,
            /// <summary>血液浄化器[ダイアライザ](008)</summary>
            DIALYZER = 8,
            /// <summary>吸着カラム(009)</summary>
            ADSORB = 9,
            /// <summary>血流量(010)</summary>
            BLOOD_MEASURE = 10,
            /// <summary>抗凝固剤(011)</summary>
            ANTI_LIQUID = 11,
            /// <summary>抗凝固剤ワンショット量(012)</summary>
            ANTI_ONESHOT = 12,
            /// <summary>抗凝固剤持続速度(013)</summary>
            ANTI_SPEED = 13,
            /// <summary>抗凝固剤持続総量(014)</summary>
            ANTI_TOTAL = 14,
            /// <summary>IP使用選択(015)</summary>
            IP_SELECT = 15,
            /// <summary>IPワンショット量(016)</summary>
            IP_MEASURE = 16,
            /// <summary>IP速度(017)</summary>
            IP_SPEED = 17,
            /// <summary>透析液(018)</summary>
            DIALYSIS_LIQUID = 18,
            /// <summary>透析液流量(019)</summary>
            DIALYSIS_FLOW = 19,
            /// <summary>透析液量(020)</summary>
            DIALYSIS_MEASURE = 20,
            /// <summary>透析液温度(021)</summary>
            DIALYSIS_TEMP = 21,
            /// <summary>補液(022)</summary>
            REP_LIQUID = 22,
            /// <summary>補液量(023)</summary>
            REP_MEASURE = 23,
            /// <summary>補液選択(024)</summary>
            REP_SELECT = 24,
            /// <summary>補液温度(025)</summary>
            REP_TEMP = 25,
            /// <summary>シングルニードル使用(029)</summary>
            SINGLE_NEEDLE = 29,
            /// <summary>補液使用数(030)</summary>
            REP_USE_COUNT = 30,
            /// <summary>IPスタート(031)</summary>
            IP_START = 31,
            /// <summary>自動ワンショット(032)</summary>
            IP_AUTO_ONESHOT = 32,
            /// <summary>IP電源自動切り(033)</summary>
            IP_AUTO_OFF = 33,
            /// <summary>IP電源自動切り時間(034)</summary>
            IP_AUTO_OFF_TIME = 34,
            /// <summary>IP電源OKモニタ切り(035)</summary>
            IP_OK_MON_OFF = 35,
            /// <summary>IP電源OKモニタ切り時間(036)</summary>
            IP_OK_MON_OFF_TIME = 36,
            /// <summary>IP速度最大値(037)</summary>
            IP_MAX_SPEED = 37,
            /// <summary>補液速度(038)</summary>
            REP_SPEED = 38,
            /// <summary>1次膜(039)</summary>
            FIRST_FILM = 39,
            /// <summary>2次膜(040)</summary>
            SECOND_FILM = 40,
            /// <summary>穿刺針(A針)(041)</summary>
            A = 41,
            /// <summary>穿刺針(V針)(042)</summary>
            V = 42,
            /// <summary>穿刺針(SN針)(043)</summary>
            SN = 43,
            /// <summary>血液回路(044)</summary>
            BOOLD = 44,

        }
        private static bool ProcGetMedicineInfo(DBCtrl db, DateTime? dtUpdate, string strMedicineCd, string strSetMediFlg, out string strMediName, out string strUnit)
        {
            string strClassCd;
            string strClassName;
            string dispFlg;
            return ProcGetMedicineInfo(db, dtUpdate, strMedicineCd, strSetMediFlg, out strMediName, out strUnit, out strClassCd, out strClassName, out dispFlg);
        }
        private static DataTable SelectMstDialyzer(DBCtrl db, DateTime? dtTarget, string strDialyzer)
        {
            bool isNew = true;
            bool isAll = true;
            IMakeSqlParameters param = db.GetIMakeSqlParameters();

            // 指定日時が存在する場合、SQLパラメータ設定
            if (true == dtTarget.HasValue)
            {
                isNew = false;
                param.AddParam(":UP_DATE", dtTarget);
            }
            // 指定情報が存在する場合SQLパラメータ設定
            if (false == string.IsNullOrEmpty(strDialyzer))
            {
                isAll = false;
                param.AddParam(":DIALYZER_CD", strDialyzer);
            }

            return db.SelectTable(SelectMstDialyzer(isNew, isAll), param.GetParam());
        }
        public static String SelectMstDialyzer(bool isNew, bool isAll)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append(@"
                        select
                            DIALYZER_CD,
                            MAKER,
                            MODEL_NUMBER,
                            DEL_FLG
                        from
                            MST_DIALYZER base
                        where
                            UP_DATE = (
                                       select
                                           max(UP_DATE)
                                       from
                                           MST_DIALYZER
                                       where
                                           DIALYZER_CD = base.DIALYZER_CD");

            // 最新取得ではなく日時指定の場合
            if (!isNew)
            {
                sb.Append(@"
                                       and
                                           UP_DATE <= :UP_DATE");
            }
            sb.Append(@"
                                      )");

            // 全情報ではなく指定情報の場合
            if (!isAll)
            {
                sb.Append(@"
                        and
                            DIALYZER_CD = :DIALYZER_CD
                        ");
            }

            return sb.ToString();
        }
        private static DataTable SelectMstTreatItem(DBCtrl db, DateTime? dtTarget, string strTreatItem)
        {
            bool isNew = true;
            bool isAll = true;
            IMakeSqlParameters param = db.GetIMakeSqlParameters();

            // 指定日時が存在する場合、SQLパラメータ設定
            if (true == dtTarget.HasValue)
            {
                isNew = false;
                param.AddParam(":REG_DATE", dtTarget);
            }
            // 指定情報が存在する場合SQLパラメータ設定
            if (false == string.IsNullOrEmpty(strTreatItem))
            {
                isAll = false;
                param.AddParam(":TREAT_ITEM_CD", strTreatItem);
            }

            return db.SelectTable(SelectMstTreatItem(isNew, isAll), param.GetParam());
        }
        public static String SelectMstTreatItem(bool isNew, bool isAll)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append(@"
                select
                    TREAT_ITEM_CD,
                    TREAT_ITEM_NAME,
                    DEVICE_MODE,
                    DEL_FLG
                from
                    MST_TREAT_ITEM base
                where
                    REG_DATE = (
                                select
                                    max(REG_DATE)
                                from
                                    MST_TREAT_ITEM
                                where
                                    TREAT_ITEM_CD = base.TREAT_ITEM_CD");

            // 最新取得ではなく日時指定の場合
            if (!isNew)
            {
                sb.Append(@"
                                and
                                    REG_DATE <= :REG_DATE");
            }

            sb.Append(@"
                               )");

            // 全情報ではなく指定情報の場合
            if (!isAll)
            {
                sb.Append(@"
                and
                    TREAT_ITEM_CD = :TREAT_ITEM_CD
                ");
            }

            return sb.ToString();
        }
        private static DataTable SelectSysTreatCondSetting(DBCtrl db, string strTreatItem)
        {
            bool isAll = true;
            IMakeSqlParameters param = db.GetIMakeSqlParameters();

            // 指定情報が存在する場合SQLパラメータ設定
            if (false == string.IsNullOrEmpty(strTreatItem))
            {
                isAll = false;
                param.AddParam(":TREAT_ITEM_CD", strTreatItem);
            }

            return db.SelectTable(SelectSysTreatCondSetting(isAll), param.GetParam());
        }
        public static String SelectSysTreatCondSetting(bool isAll)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append(@"
                select
                    TREAT_ITEM_CD,
                    COND_CTL_NO,
                    USE_FLG
                from
                    SYS_TREAT_COND_SETTING");

            // 全情報ではなく指定情報の場合
            if (!isAll)
            {
                sb.Append(@"
                where
                    TREAT_ITEM_CD = :TREAT_ITEM_CD
                ");
            }

            return sb.ToString();
        }
        private static DataTable SelectMstVA(DBCtrl db, DateTime? dtTarget, string strVA)
        {
            bool isNew = true;
            bool isAll = true;
            IMakeSqlParameters param = db.GetIMakeSqlParameters();

            // 指定日時が存在する場合、SQLパラメータ設定
            if (true == dtTarget.HasValue)
            {
                isNew = false;
                param.AddParam(":UP_DATE", dtTarget);
            }
            // 指定情報が存在する場合SQLパラメータ設定
            if (false == string.IsNullOrEmpty(strVA))
            {
                isAll = false;
                param.AddParam(":VA_ACCESS_CD", strVA);
            }

            return db.SelectTable(SelectMstVA(isNew, isAll), param.GetParam());
        }

        public static String SelectMstVA(bool isNew, bool isAll)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append(@"
                    select
                        VA_ACCESS_CD,
                        VA_ACCESS_NAME,
                        DEL_FLG
                    from
                        MST_VA_ACCESS base
                    where
                        UP_DATE = (
                                   select
                                       max(UP_DATE)
                                   from
                                       MST_VA_ACCESS
                                   where
                                       VA_ACCESS_CD = base.VA_ACCESS_CD");

            // 最新取得ではなく日時指定の場合
            if (!isNew)
            {
                sb.Append(@"
                                   and
                                       UP_DATE <= :UP_DATE");
            }

            sb.Append(@"
                                  )");

            // 全情報ではなく指定情報の場合
            if (!isAll)
            {
                sb.Append(@"
                    and
                        VA_ACCESS_CD = :VA_ACCESS_CD
                    ");
            }

            return sb.ToString();
        }
        private static DataTable SelectIndDialysisCond(DBCtrl db, string strPatId, string strDialysisDate, decimal decPlural, string strOpeIndPlan, DateTime dtTargetDate, bool isGetFuture)
        {
            IMakeSqlParameters param = db.GetIMakeSqlParameters();
            param.AddParam(":PATID", strPatId);
            param.AddParam(":DIALYSIS_DATE", strDialysisDate);
            param.AddParam(":PLURAL", decPlural);
            param.AddParam(":OPE_IND_PLAN", strOpeIndPlan);
            param.AddParam(":UP_DATE", dtTargetDate);
            return db.SelectTable(SelectIndDialysisCond(isGetFuture), param.GetParam());
        }
        public static string SelectIndDialysisCond(bool isGetFuture)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append(@"
                        select
                             CTL_NO,
                             UP_DATE,
                             UPDATE_STAFF_CD,
                             IND_START_DATE,
                             IND_END_DATE,
                             IND_CLASS,
                             DAY_PATTERN,
                             VALUE_ALL,
                             VALUE_1W1N,
                             VALUE_1W2N,
                             VALUE_1W3N,
                             VALUE_1W4N,
                             VALUE_1W5N,
                             VALUE_1W6N,
                             VALUE_1W7N,
                             INDICATOR_CD,
                             DEL_FLG,
                             OPE_IND_PLAN
                        from
                            IND_DIALYSIS_COND base
                        where
                            UP_DATE =
                            (
                                select
                                    max(UP_DATE)
                                from
                                    IND_DIALYSIS_COND
                                where
                                    base.PATID = PATID
                                and
                                    base.PLURAL = PLURAL
                                and
                                    base.CTL_NO = CTL_NO");

            if (isGetFuture)
            {
                // 未来情報を取得する場合
                sb.Append(@"
                                and
                                    :UP_DATE < UP_DATE");
            }
            else
            {
                // 未来情報を取得しない場合
                sb.Append(@"
                                and
                                    UP_DATE <= :UP_DATE");
            }

            sb.Append(@"
                                and
                                    IND_START_DATE <= :DIALYSIS_DATE
                                and
                                    :DIALYSIS_DATE <= IND_END_DATE
                                and
                                    OPE_IND_PLAN = :OPE_IND_PLAN
                            )
                                and
                                    PATID = :PATID
                                and
                                    PLURAL = :PLURAL
                                and
                                    IND_START_DATE <= :DIALYSIS_DATE
                                and
                                    :DIALYSIS_DATE <= IND_END_DATE
                                and
                                    OPE_IND_PLAN = :OPE_IND_PLAN
                                ");

            return sb.ToString();
        }
        public static string GetSystemDefine(DBCtrl db)
        {
            //add 7997 start 
            string sql = @"
                select
	                VALUE
                from
	                SYS_SYSTEM_DEFINE
                where
	                ID = '80'";
            if (CacheInformation.Instance.FacilityCd.Equals("1"))
            {
                string sCD = $" AND  SERIES_CD = '{CommonConfig.seriesCd}'";
                sql = sql + sCD;
            }
            //add 7997 end 
            DataTable dt = db.SelectTable(sql);
            if (null == dt)
            {
                return null;
            }

            if (0 == dt.Rows.Count)
            {
                return null;
            }

            if (1 != dt.Rows.Count)
            {
                return null;
            }

            return dt.Rows[0]["VALUE"] as string;
        }
        private static DataTable GetIndEquip(DBCtrl db, string strPatId, string strDialysisDate, decimal decPlural, DateTime? dtTargetDate, bool isGetDelete, DataTable tbIndPlan, bool isGetFuture)
        {


            // 透析日を FnwDate に変換(引数チェックしているので TryParse しない)
            FnwDate fnwDialysisDate = FnwDate.YyyyMmDd(strDialysisDate);

            // 透析日が本日より過去かどうかの確認
            // 本日より過去の場合、その日付時点でのマスタ情報を取得するための
            // 指定日時を設定
            DateTime? dtUpdate = null;
            if (fnwDialysisDate < FnwDate.Today)
            {
                dtUpdate = fnwDialysisDate.OnlyDate.AddDays(1).AddSeconds(-1);
            }

           
            // 指示作成区分の設定
            string strOpeIndPlan = tbIndPlan.Rows[0]["OPE_IND_PLAN"] as string;

            // 医材指示情報取得時に使用する、更新日時と比較用日時
            DateTime dtIndUpdate = DateTime.Now;
            if (true == dtTargetDate.HasValue)
            {
                // 確認日時が存在する場合は、その日付を使用する
                dtIndUpdate = dtTargetDate.Value;
            }
            // 医材指示情報取得
            DataTable tbIndEquip = SelectIndDialysisEquip(db, strPatId, strDialysisDate, decPlural, strOpeIndPlan, dtIndUpdate, isGetFuture);
            if (null == tbIndEquip)
            {
                return null;
            }
            if (0 == tbIndEquip.Rows.Count)
            {
                // 医材指示 0件
                return CreateTableIndEquip();
            }

            // --------------------------------------------
            // 取得指示情報を戻り値用データテーブルに設定
            // --------------------------------------------
            // 戻り値用データテーブル
            DataTable tbMain = CreateTableIndEquip();
            DataRow rowMain;

            // その週の何回目かの情報の設定(VALUE_1W○N)
            if (false == FnwNumber.Is(tbIndPlan.Rows[0]["TURN"]))
            {

                return null;
            }
            int intTurn = (int)FnwNumber.ToDecimal(tbIndPlan.Rows[0]["TURN"]);
            string strTrun = "VALUE_1W" + intTurn.ToString() + "N";

            // 取得した医材指示情報(DataTable)から有効最新情報を抽出し、戻り値用データテーブルに設定
            // 該当項目番号(CTL_NO)を取得
            for (int i = 0; i < tbIndEquip.Rows.Count; i++)
            {
                rowMain = tbMain.NewRow();

                // 該当行のデータを取得
                DataRow rowEquip = tbIndEquip.Rows[i];

                // 中止されていない投薬のみ取得する場合は、削除フラグを確認
                if (!isGetDelete && false == "0".Equals(rowEquip["DEL_FLG"]))
                {
                    continue;
                }

                // ------------------------------------------------------------------------------------------------
                // 曜日パターン(DAY_PATTERN)による抽出
                // (※抽出した該当医材指示の削除フラグが'0'以外の場合、以下の曜日パターンによる処理は行わない)
                // ------------------------------------------------------------------------------------------------

                // 削除フラグが'0'の場合のみ、曜日パターンの検証         
                if ("0".Equals(rowEquip["DEL_FLG"]))
                {
                    // 曜日パターン(DAY_PATTERN)取得
                    string strDayPattern = rowEquip["DAY_PATTERN"] as string;
                    if (true == string.IsNullOrEmpty(strDayPattern))
                    {

                        return null;
                    }
                }

                // 未来情報取得時はここでreturn
                if (isGetFuture)
                {
                    tbMain.Rows.Add(rowMain);
                    return tbMain;
                }

                // -----------------
                // 以下、値を設定
                // -----------------

                // 項目番号
                rowMain["CTL_NO"] = rowEquip["CTL_NO"];
                // 更新日時
                rowMain["UP_DATE"] = rowEquip["UP_DATE"];
                // 指示削除フラグ
                rowMain["DEL_FLG"] = rowEquip["DEL_FLG"];

                // 医療材料情報
                // 医療材料コード
                string strEquipCd = rowEquip["EQUIP_CD"] as string;
                if (true == string.IsNullOrEmpty(strEquipCd))
                {
                    // エラー

                    return null;
                }
                rowMain["EQUIP_CD"] = strEquipCd;

                // 医療材料マスタから情報取得
                DataTable tbMstEquip = SelectMstEquipment(db, dtUpdate, strEquipCd);
                if (null == tbMstEquip)
                {
                    return null;
                }


                // 穿刺針区分
                rowMain["SETTING"] = rowEquip["SETTING"];
                switch (rowMain["SETTING"] as string)
                {
                    // 穿刺針以外 or 未指定
                    case "0":
                        break;
                    // A針
                    case "1":
                        break;
                    // V針
                    case "2":
                        break;
                    // SN(シングルニードル)
                    case "3":
                        break;
                    default:
                        return null;
                }

                // 数量
                rowMain["AMOUNT"] = rowEquip[strTrun];
                // コメント
                rowMain["COMMENTS"] = rowEquip["COMMENTS"];

                // 指示者名
                string strStaffCd = rowEquip["INDICATOR_CD"] as string;
                if (false == string.IsNullOrEmpty(strStaffCd))
                {
                    // 指示者コード
                    rowMain["INDICATOR_CD"] = strStaffCd;

                    // スタッフマスタ情報取得
                    DataTable tbMstStaff = SelectMstStaff(db, dtUpdate, strStaffCd, null);
                    if (null == tbMstStaff)
                    {
                        return null;
                    }

                }

                // 戻り値用データテーブルに格納
                tbMain.Rows.Add(rowMain);
            }

            return tbMain;
        }
        private static DataTable CreateTableIndEquip()
        {
            DataTable tb = new DataTable();

            tb.Columns.Add("CTL_NO", typeof(string));
            tb.Columns.Add("UP_DATE", typeof(DateTime));
            tb.Columns.Add("EQUIP_CD", typeof(string));
            tb.Columns.Add("EQUIP_NAME", typeof(string));
            tb.Columns.Add("EQUIP_GROUP_CD", typeof(string));
            tb.Columns.Add("EQUIP_GROUP_NAME", typeof(string));
            tb.Columns.Add("SETTING", typeof(string));
            tb.Columns.Add("SETTING_NAME", typeof(string));
            tb.Columns.Add("AMOUNT", typeof(decimal));
            tb.Columns.Add("UNIT", typeof(string));
            tb.Columns.Add("COMMENTS", typeof(string));
            tb.Columns.Add("INDICATOR_CD", typeof(string));
            tb.Columns.Add("INDICATOR_NAME", typeof(string));
            tb.Columns.Add("DEL_FLG", typeof(string));

            return tb;
        }
        private static DataTable SelectIndDialysisEquip(DBCtrl db, string strPatId, string strDialysisDate, decimal decPlural, string strOpeIndPlan, DateTime dtTargetDate, bool isGetFuture)
        {
            IMakeSqlParameters param = db.GetIMakeSqlParameters();
            param.AddParam(":PATID", strPatId);
            param.AddParam(":DIALYSIS_DATE", strDialysisDate);
            param.AddParam(":PLURAL", decPlural);
            param.AddParam(":OPE_IND_PLAN", strOpeIndPlan);
            param.AddParam(":UP_DATE", dtTargetDate);

            return db.SelectTable(SelectIndDialysisEquip(isGetFuture), param.GetParam());
        }
        public static string SelectIndDialysisEquip(bool isGetFuture)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append(@"
                select
                    CTL_NO,
                    UP_DATE,
                    UPDATE_STAFF_CD,
                    IND_START_DATE,
                    IND_END_DATE,
                    IND_CLASS,
                    DAY_PATTERN,
                    SETTING,
                    LPAD(TRIM(EQUIP_CD), 10, '0')  as  EQUIP_CD,
                    CASE SETTING
                        WHEN '3' THEN
                            (CASE
                            WHEN (LPAD(TRIM(EQUIP_CD), 10, '0') IN (SELECT TRIM( REGEXP_SUBSTR( P_SN, '[^,]+', 1, LEVEL ) ) AS EXTRACTED_VALUE FROM SYNC_CONDSET CONNECT BY LEVEL <= REGEXP_COUNT ( P_SN, ',' ) + 1))
                            THEN 'SN' || SUBSTR(LPAD(TRIM(EQUIP_CD), 10, '0'), 3)
                            ELSE LPAD(TRIM(EQUIP_CD), 10, '0')
                            END)
                        ELSE LPAD(TRIM(EQUIP_CD), 10, '0')
                    END SN_EQUIP_CD,
                    VALUE_1W1N,
                    VALUE_1W2N,
                    VALUE_1W3N,
                    VALUE_1W4N,
                    VALUE_1W5N,
                    VALUE_1W6N,
                    VALUE_1W7N,
                    INDICATOR_CD,
                    COMMENTS,
                    DEL_FLG,
                    OPE_IND_PLAN
                from
                    IND_DIALYSIS_EQUIP base
                where
                    UP_DATE =
                    (
                        select
                            max(UP_DATE)
                        from
                            IND_DIALYSIS_EQUIP
                        where
                            base.PATID = PATID
                        and
                            base.PLURAL = PLURAL
                        and
                            base.CTL_NO = CTL_NO");

            if (isGetFuture)
            {
                // 未来情報を取得する場合
                sb.Append(@"
                        and
                            :UP_DATE < UP_DATE");
            }
            else
            {
                // 未来情報を取得しない場合
                sb.Append(@"
                        and
                            UP_DATE <= :UP_DATE");
            }

            sb.Append(@"
                        and
                            IND_START_DATE <= :DIALYSIS_DATE
                        and
                            :DIALYSIS_DATE <= IND_END_DATE
                        and
                            OPE_IND_PLAN = :OPE_IND_PLAN
                    )
                and
                    PATID = :PATID
                and
                    PLURAL = :PLURAL
                and
                    IND_START_DATE <= :DIALYSIS_DATE
                and
                    :DIALYSIS_DATE <= IND_END_DATE
                and
                    OPE_IND_PLAN = :OPE_IND_PLAN
                order by
                    CTL_NO
");

            return sb.ToString();
        }


        private static DataTable SelectPatTaboo(DBCtrl db, string strPatId, DateTime dtTargetDate)
        {
            IMakeSqlParameters param = db.GetIMakeSqlParameters();
            param.AddParam(":PATID", strPatId);
            param.AddParam(":UP_DATE", dtTargetDate);

            return db.SelectTable(SelectPatTaboo(), param.GetParam());
        }
        public static string SelectPatTaboo()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append(@"
                        SELECT
                        CASE
		                        a.TABOO_CLASS 
		                        WHEN '0' THEN
		                        c.TABOO_CLASS ELSE a.TABOO_CLASS 
	                        END AS TABOO_CLASS,
                        CASE
		                        a.TABOO_CLASS 
		                        WHEN '0' THEN
		                        c.TABOO_CD ELSE a.TABOO_CD 
	                        END AS TABOO_CD 
                        FROM
	                        PAT_TABOO a
	                        LEFT JOIN (
	                        SELECT
		                        a.TABOO_CD,
		                        a.TABOO_CLASS,
		                        a.TABOO_GROUP_CD 
	                        FROM
		                        MST_TABOO_GROUP_ITEM a
		                        INNER JOIN MST_TABOO_GROUP_SUB_NEW b ON ( a.TABOO_GROUP_CD = b.TABOO_GROUP_CD AND b.DISP_FLG = '1' )
		                        INNER JOIN MST_TABOO_GROUP c ON ( a.TABOO_GROUP_CD = c.TABOO_GROUP_CD AND a.UP_DATE = c.UP_DATE AND c.DEL_FLG = '0' ) 
	                        WHERE
		                        NOT EXISTS (
		                        SELECT
			                        * 
		                        FROM
			                        MST_TABOO_GROUP_ITEM b 
		                        WHERE
			                        a.TABOO_GROUP_CD = b.TABOO_GROUP_CD 
			                        AND a.UP_DATE < b.UP_DATE 
			                        AND b.UP_DATE <= :UP_DATE
		                        ) 
		                        AND a.DEL_FLG = '0' 
		                        AND a.UP_DATE <= :UP_DATE
	                        ) c ON a.TABOO_CD = c.TABOO_GROUP_CD 
	                        AND a.TABOO_CLASS = '0' 
                        WHERE
	                        NOT EXISTS (
	                        SELECT
		                        * 
	                        FROM
		                        PAT_TABOO b 
	                        WHERE
		                        a.PATID = b.PATID 
		                        AND a.CTL_NO = b.CTL_NO 
		                        AND a.UP_DATE < b.UP_DATE 
		                        AND b.UP_DATE <= :UP_DATE 
	                        ) 
	                        AND a.DEL_FLG = '0' 
	                        AND a.UP_DATE <= :UP_DATE
	                        AND a.PATID = :PATID 
	                        AND a.TABOO_CLASS IS NOT NULL 
	                        AND a.TABOO_CD IS NOT NULL
                    ");

            return sb.ToString();
        }


        #region
        public static string CheckContentUpdate(DataRow dr, DBCtrl db, string strPatId, string strDialysisDate, decimal decPlural, DateTime dtTargetDate)
        {

            // 透析日を FnwDate に変換(引数チェックしているので TryParse しない)
            FnwDate fnwDialysisDate = FnwDate.YyyyMmDd(strDialysisDate);
            DataTable tbIndPlan = ProcSelectIndDialysisPlan(db, strPatId, strDialysisDate, decPlural, fnwDialysisDate, dtTargetDate, false);
            if (null == tbIndPlan)
            {
                return null;
            }

            if (0 == tbIndPlan.Rows.Count)
            {
                return null;
            }
            string KUR_NAME = string.Empty;
            string KUR_TIME = string.Empty;



            string schedule = "json_build_object('component','schedule','subCategoryNo',3,'subCategoryItem',json_build_array({0}),'subCategoryName','スケジュール')";

            string UPDATE_STAFF_CD = GetSTAFF_NAME(db, tbIndPlan.Rows[0]["UPDATE_STAFF_CD"] as string, dtTargetDate);
            string INDICATOR_CD = GetSTAFF_NAME(db, tbIndPlan.Rows[0]["INDICATOR_CD"] as string, dtTargetDate);



            bool isRst = !string.IsNullOrEmpty(dr["DIALYSIS_NO"].ToString());
            string dialysis_date = dr["DIALYSIS_DATE"].ToString();
            DateTime date = DateTime.ParseExact(dialysis_date, "yyyyMMdd", CultureInfo.InvariantCulture);
            DataTable taboo = SelectPatTaboo(db, strPatId, dtTargetDate);
            //医療材料
            DataTable equipment = GetCheckIndEquip(db, strPatId, strDialysisDate, decPlural, dtTargetDate, tbIndPlan, false);
            //
            string starttime = string.Empty;
            string method = string.Empty;
            string treat_cond = GetCheckContentCond(isRst, equipment, taboo, db, strPatId, strDialysisDate, decPlural, dtTargetDate, tbIndPlan, false, out starttime, out method);

            var items = new List<ScheduleItem>();

            if (tbIndPlan.Rows[0]["KUR_CD"].Equals("NON"))
            {
                items.Add(new ScheduleItem("'クール'", 1, "null", "'未登録'", "null"));
                items.Add(new ScheduleItem("'治療開始時刻'", 2, "null", "'未登録'", "null"));

            }
            else
            {
                string KUR_CD = tbIndPlan.Rows[0]["KUR_CD"].ToString();
                DataRow rowIndCond = Kurdt.AsEnumerable().Where(row => row.Field<string>("KUR_CD") == KUR_CD && row.Field<DateTime>("UP_DATE") <= dtTargetDate).OrderByDescending(crow => (DateTime)crow["UP_DATE"]).FirstOrDefault();
                string kur_name = "null";
                if (isRst)
                {
                    kur_name = "'" + SpecialDataFormat(rowIndCond["KUR_NAME"].ToString()) + "'";
                }

                items.Add(new ScheduleItem("'クール'", 1, "(select kur_cd from  mst_kur where facility_cd='" + CommonConfig.FacilityCd + "' and fn_kur_cd='" + KUR_CD + "' )", kur_name, "null"));
                items.Add(new ScheduleItem("'治療開始時刻'", 2, "null", starttime == null ? "未登録" : "'" + $"{starttime.Substring(0, 2)}:{starttime.Substring(2, 2)}" + "'", "'" + date.ToString("yyyy/MM/dd") + " '"));

            }

            if (tbIndPlan.Rows[0]["BED_NO"].ToString().Equals("0"))
            {
                items.Add(new ScheduleItem("'ベッド'", 3, "0", "'未登録'", "null"));
            }
            else
            {
                int BED_NO = int.Parse(tbIndPlan.Rows[0]["BED_NO"].ToString());
                DataRow rowIndCond = Beddt.AsEnumerable().Where(row => row.Field<decimal>("BED_NO") == BED_NO && row.Field<DateTime>("REG_DATE") <= dtTargetDate).OrderByDescending(crow => (DateTime)crow["REG_DATE"]).FirstOrDefault();
                string name = "null";
                if (isRst)
                {
                    name = "'" + SpecialDataFormat(rowIndCond["BED_NAME"].ToString()) + "'";
                }

                items.Add(new ScheduleItem("'ベッド'", 3, "(select bed_cd from  mst_bed where facility_cd='" + CommonConfig.FacilityCd + "' and fn_bed_no='" + BED_NO + "' )", name, "null"));

            }
            List<string> scheduleInfo = new List<string>();

            foreach (var item in items)
            {
                scheduleInfo.Add("json_build_object('itemInfo',json_build_object('itemName'," + item.itemName + ",'itemNo'," + item.itemNo + ",'itemCd'," + item.itemCd + ",'itemType',null, 'data',json_build_object('value',json_build_object('unit',null,'prefix'," + item.prefix + ", 'dispVal'," + item.dispVal + "),'updater','" + SpecialDataFormat(UPDATE_STAFF_CD) + "','instructor','" + SpecialDataFormat(INDICATOR_CD) + "')" +
                        "))");

            }

            string treat_medi = GetCheckContentMedi(db, taboo, strPatId, strDialysisDate, decPlural, dtTargetDate, tbIndPlan, false, isRst);

            string treat_equip = GetCheckContentEquip(equipment, taboo, db, dtTargetDate, tbIndPlan, isRst);

            string treat_addition = GetCheckContentAddition(db, strPatId, strDialysisDate, decPlural, dtTargetDate, tbIndPlan, false);

            schedule = string.Format(schedule, string.Join(",", scheduleInfo.ToArray()));

            return method + "," + schedule + "," + treat_cond + "," + treat_medi + "," + treat_equip + "," + treat_addition;
        }
        private static string GetCheckContentMedi(DBCtrl db, DataTable taboo, string strPatId, string strDialysisDate, decimal decPlural, DateTime? dtTargetDate, DataTable tbIndPlan, bool isGetFuture, bool isRst)
        {
            // 指示作成区分の設定
            string strOpeIndPlan = tbIndPlan.Rows[0]["OPE_IND_PLAN"] as string;

            // 透析日を FnwDate に変換(引数チェックしているので TryParse しない)
            FnwDate fnwDialysisDate = FnwDate.YyyyMmDd(strDialysisDate);

            // 投薬指示情報取得時に使用する、更新日時と比較用日時
            DateTime dtIndUpdate = DateTime.Now;
            if (true == dtTargetDate.HasValue)
            {
                // 確認日時が存在する場合は、その日付を使用する
                dtIndUpdate = dtTargetDate.Value;
            }
            // 投薬指示情報取得
            DataTable tbIndMedi = SelectIndDialysisMedi(db, strPatId, strDialysisDate, decPlural, strOpeIndPlan, dtIndUpdate, isGetFuture);
            DataRow[] drIndMedi = tbIndMedi.Select("DEL_FLG='0'");
            if (null == drIndMedi || 0 == drIndMedi.Length)
            {
                // 投薬指示 0件
                return "json_build_object('component','medicine','subCategoryNo',5,'subCategoryItem',json_build_array(),'subCategoryName','投与薬剤')";
            }

            string all = "json_build_object('component','medicine','subCategoryNo',5,'subCategoryItem',json_build_array({0}),'subCategoryName','投与薬剤')";
            List<string> items = new List<string>();
            string itemtemplete = "json_build_object('itemInfo',json_build_object('itemName','{6}','itemNo',{5}, 'itemCd',{7}, 'itemType',{8},'data',json_build_object('value',json_build_object('prefix',{0},'dispVal','{1}','unit',{2}),'updater','{3}','instructor','{4}')))";

            // その週の何回目かの情報の設定(VALUE_1W○N)
            if (false == FnwNumber.Is(tbIndPlan.Rows[0]["TURN"]))
            {
                return "json_build_object('component','medicine','subCategoryNo',5,'subCategoryItem',json_build_array(),'subCategoryName','投与薬剤')";
            }

            int intTurn = (int)FnwNumber.ToDecimal(tbIndPlan.Rows[0]["TURN"]);

            // 取得した投薬指示情報(DataTable)から有効最新情報を抽出し、戻り値用データテーブルに設定
            // 該当項目番号(CTL_NO)を取得
            for (int i = 0; i < drIndMedi.Length; i++)
            {
                // 該当行のデータを取得
                DataRow rowMedi = drIndMedi[i];
                // ------------------------------------------------------------------------------------------------
                // 該当投薬の抽出②
                // 曜日パターン(DAY_PATTERN)、月毎投与設定(COUNT_EVERY_MONTH)による抽出
                // (※抽出した該当投薬指示の削除フラグが'0'以外の場合、以下の曜日パターンによる処理は行わない)
                // ------------------------------------------------------------------------------------------------
                // その週の何回目かのカラム名(VALUE_○W○N)設定用の変数
                string strTrun = null;

                if ("0".Equals(rowMedi["DEL_FLG"]))
                {

                    // 月毎投与設定(COUNT_EVERY_MONTH)取得
                    decimal decCountEveryMonth;
                    if (false == FnwNumber.Is(rowMedi["COUNT_EVERY_MONTH"]))
                    {
                        continue; ;
                    }
                    decCountEveryMonth = FnwNumber.ToDecimal(rowMedi["COUNT_EVERY_MONTH"]);

                    // 月毎投与設定(COUNT_EVERY_MONTH)によって分岐
                    int intWeekCnt = 0;
                    switch ((CountEveryMonth)decCountEveryMonth)
                    {
                        // 月毎投与ではない
                        case CountEveryMonth.NON:
                            // その週の何回目かの情報の設定(VALUE_1W○N)
                            strTrun = "VALUE_1W" + intTurn.ToString() + "N";
                            break;
                        // 1回/月の投与
                        case CountEveryMonth.ONE_TIME:

                            // 透析日の月の最初の月曜日を取得
                            DateTime dtFirstMonday = DateFirstMonday(fnwDialysisDate.OnlyDate);

                            // 月の最初の月曜日から、透析日が何週後かを確認
                            intWeekCnt = WeekCount(dtFirstMonday, fnwDialysisDate.OnlyDate);

                            // その週の何回目かの情報の設定(VALUE_○W○N)
                            strTrun = "VALUE_" + (intWeekCnt + 1).ToString() + "W" + intTurn.ToString() + "N";

                            break;

                        default:

                            continue;
                    }

                    // -----------------
                    // 以下、値を設定
                    // -----------------


                    // 薬剤マスタ(セット薬剤名称マスタ)から情報取得
                    string strMediName;
                    string strUnit;
                    string strUnitind;
                    bool isTaboo;
                    bool isDel;
                    bool isDelItem;
                    bool isDiff;
                    // セット薬剤フラグ
                    string strSetMediFlg = rowMedi["SET_MEDICINE_FLG"] as string;

                    // 薬剤コード
                    string strMediCode = rowMedi["MEDICINE_CD"] as string;
                    if (true == string.IsNullOrEmpty(strMediCode))
                    {
                        continue;
                    }

                    if (false == getMediInfo(strMediCode, strSetMediFlg, taboo, null, dtTargetDate, out isTaboo, out isDel, out isDiff, out isDelItem, out strMediName, out strUnit, out strUnitind))
                    {
                        continue;
                    }

                    if (!string.IsNullOrEmpty(strMediName))
                    {
                        strMediName = SpecialDataFormat(strMediName);
                    }
                    else
                    {
                        strMediName = "";
                    }

                    string amount = rowMedi[strTrun].ToString();
                    if (string.IsNullOrEmpty(amount))
                    {
                        continue;
                    }

                    string prefix = "null";

                    if (isRst)
                    {
                        if (!string.IsNullOrEmpty(strUnit))
                        {
                            strUnit = "'" + SpecialDataFormat(strUnit) + "'";
                        }
                        else
                        {
                            strUnit = "null";
                        }
                        // prefix = GetPrefix(isTaboo, false, isDel, isDelItem);
                    }
                    else
                    {
                        strUnit = "null";
                    }

                    // 指示者情報

                    string strStaffCd = rowMedi["INDICATOR_CD"] as string;
                    string strStaffName = SpecialDataFormat(GetSTAFF_NAME(db, strStaffCd, dtTargetDate));

                    // 更新情報
                    string strUpdaterCd = rowMedi["UPDATE_STAFF_CD"] as string;
                    string strUpdaterName = SpecialDataFormat(GetSTAFF_NAME(db, strUpdaterCd, dtTargetDate));
                    string strCltNO = rowMedi["CTL_NO"] as string;
                    decimal no = 0;
                    if (false == string.IsNullOrEmpty(strCltNO))
                    {
                        DataTable tbMedicineLastNo = SelectMedicineLastNo(db, strPatId, strCltNO, decPlural);
                        if (null == tbMedicineLastNo)
                        {
                            continue;
                        }
                        no = (decimal)tbMedicineLastNo.Rows[0]["NO"];

                    }
                    else
                    {
                        continue;
                    }
                    //if (strSetMediFlg.Equals("1")) {
                    //    DataRow rowMstSetMedi = SetMedidt.AsEnumerable().Where(row => row.Field<string>("SET_MEDICINE_CD") == strMediCode && row.Field<DateTime>("UP_DATE") <= dtTargetDate).OrderByDescending(crow => (DateTime)crow["UP_DATE"]).FirstOrDefault();
                    //    if ("302".Equals(rowMstSetMedi["MEDICINE_GROUP_CD"].ToString())
                    //        || "303".Equals(rowMstSetMedi["MEDICINE_GROUP_CD"].ToString()))
                    //    {
                    //        strMediCode = "TS" + strMediCode.Substring(2);
                    //    }
                    //}
                    items.Add(string.Format(itemtemplete, prefix, amount, strUnit, strUpdaterName, strStaffName, no, strMediName, getMedCd(strSetMediFlg, strMediCode), getMedType(strSetMediFlg)));
                }
            }
            if (items == null || items.Count() == 0)
            {
                return "json_build_object('component','medicine','subCategoryNo',5,'subCategoryItem',json_build_array(),'subCategoryName','投与薬剤')";
            }

            return string.Format(all, string.Join(",", items.ToArray()));
        }
        private static DataTable SelectMedicineLastNo(DBCtrl db, string strPatId, string indNo, decimal? plural)
        {

            IMakeSqlParameters param = db.GetIMakeSqlParameters();

            if (false == string.IsNullOrEmpty(strPatId))
            {
                param.AddParam(":PATID", strPatId);
            }
            if (false == string.IsNullOrEmpty(indNo))
            {
                param.AddParam(":IND_NO", indNo);
            }
            if (true == plural.HasValue)
            {
                param.AddParam(":PLURAL", plural);
            }
            if (false == string.IsNullOrEmpty(CommonConfig.seriesCd))
            {
                param.AddParam(":SERIES_CD", CommonConfig.seriesCd);
            }
            return db.SelectTable(SelectMedicineLastNo(), param.GetParam());
        }

        private static bool getMediInfo(string strMediCode, string strSetMediFlg, DataTable taboo, string strClass, DateTime? dtTargetDate, out bool isTaboo, out bool isDel, out bool isDiff, out bool isDelItem, out string strMediName, out string strUnit, out string strUnitind)
        {

            strMediName = null;
            strUnit = null;
            strUnitind = null;
            isTaboo = false;
            isDiff = false;
            isDel = false;
            isDelItem = false;

            // セット薬剤フラグで分岐
            switch (strSetMediFlg)
            {
                // 薬剤
                case "0":
                    isTaboo = isTaBoo(strMediCode, "1", taboo);
                    // 薬剤マスタ情報取得
                    DataRow rowMstMedi = Medidt.AsEnumerable().Where(row => row.Field<string>("MEDICINE_CD") == strMediCode && row.Field<DateTime>("UP_DATE") <= dtTargetDate).OrderByDescending(crow => (DateTime)crow["UP_DATE"]).FirstOrDefault();
                    strMediName = rowMstMedi["MEDICINE_NAME"].ToString();
                    strUnit = rowMstMedi["UNIT"].ToString();
                    strUnitind = rowMstMedi["UNIT"].ToString();
                    isDel = "0".Equals(rowMstMedi["DISP_FLG"].ToString());
                    if (!string.IsNullOrEmpty(strClass))
                    {
                        isDiff = !strClass.Equals(rowMstMedi["MEDICINE_GROUP_CD"].ToString());
                    }
                    break;

                // セット薬剤
                case "1":
                    isTaboo = isTaBoo(strMediCode, "2", taboo);
                    // セット薬剤マスタ情報取得
                    DataRow rowMstSetMedi = SetMedidt.AsEnumerable().Where(row => row.Field<string>("SET_MEDICINE_CD") == strMediCode && row.Field<DateTime>("UP_DATE") <= dtTargetDate).OrderByDescending(crow => (DateTime)crow["UP_DATE"]).FirstOrDefault();
                    strMediName = rowMstSetMedi["SET_MEDICINE_NAME"].ToString();
                    //if ("302".Equals(rowMstSetMedi["MEDICINE_GROUP_CD"].ToString())
                    //    || "303".Equals(rowMstSetMedi["MEDICINE_GROUP_CD"].ToString()))
                    //{
                    //    strUnit = rowMstSetMedi["IND_UNIT"].ToString();
                    //    strMediName = strMediName + "(調剤)";
                    //    strUnitind = rowMstSetMedi["UNIT"].ToString();
                    //}
                    //else
                    //{
                    //    strUnit = rowMstSetMedi["UNIT"].ToString();
                    //    strUnitind = rowMstSetMedi["UNIT"].ToString();
                    //}
                    strUnit = rowMstSetMedi["UNIT"].ToString();
                    strUnitind = rowMstSetMedi["UNIT"].ToString();
                    isDel = "0".Equals(rowMstSetMedi["DISP_FLG"].ToString());
                    if (!string.IsNullOrEmpty(strClass))
                    {
                        isDiff = !strClass.Equals(rowMstSetMedi["MEDICINE_GROUP_CD"].ToString());
                    }
                    DataRow[] rowSetMedicine = SetMedicinedt.AsEnumerable().Where(row => row.Field<string>("SET_MEDICINE_CD") == strMediCode && row.Field<DateTime>("UP_DATE") == (DateTime)rowMstSetMedi["UP_DATE"])?.ToArray();
                    foreach (DataRow rowMedicine in rowSetMedicine)
                    {
                        DataRow rowMstMediItem = Medidt.AsEnumerable().Where(row => row.Field<string>("MEDICINE_CD") == rowMedicine["MEDICINE_CD"].ToString() && row.Field<DateTime>("UP_DATE") <= dtTargetDate).OrderByDescending(crow => (DateTime)crow["UP_DATE"]).FirstOrDefault();

                        if (!isTaboo)
                        {
                            isTaboo = isTaBoo(rowMstMediItem["MEDICINE_CD"].ToString(), "1", taboo);
                        }

                        if (!isDelItem && !isDel && "0".Equals(rowMstMediItem["DISP_FLG"].ToString()))
                        {
                            isDelItem = true;
                        }

                    }
                    break;

                default:
                    return false;
            }

            return true;
        }
        public static string SelectMedicineLastNo()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append(@"
                    select
                        NO
                    from
                        SYNC_MEDICINE_LATEST_NO 
                    where
                        PATID = :PATID
                    and IND_NO = :IND_NO
                    and PLURAL = :PLURAL
                    and SERIES_CD=:SERIES_CD
                   ");

            return sb.ToString();
        }

        private static string GetSTAFF_NAME(DBCtrl db, string strUpdaterCd, DateTime? dtTargetDate)
        {

            if (false == string.IsNullOrEmpty(strUpdaterCd))
            {
                // スタッフマスタ情報取得
                DataTable tbMstStaff = SelectMstStaff(db, dtTargetDate, strUpdaterCd, null);
                if (null == tbMstStaff)
                {
                    return "";
                }
                else
                {
                    return tbMstStaff.Rows[0]["STAFF_NAME"].ToString();
                }

            }
            return "";

        }


        private static string GetCheckContentCond(bool isRst, DataTable equipment, DataTable taboo, DBCtrl db, string strPatId, string strDialysisDate, decimal decPlural, DateTime? dtTargetDate, DataTable tbIndPlan, bool isGetFuture, out string starttime, out string method)
        {
            // 指示作成区分の設定
            string strOpeIndPlan = tbIndPlan.Rows[0]["OPE_IND_PLAN"] as string;

            // 条件指示情報取得時に使用する、更新日時と比較用日時
            DateTime dtIndUpdate = DateTime.Now;
            if (true == dtTargetDate.HasValue)
            {
                // 確認日時が存在する場合は、その日付を使用する
                dtIndUpdate = dtTargetDate.Value;
            }
            // 条件指示情報取得
            DataTable tbIndCond = SelectIndDialysisCond(db, strPatId, strDialysisDate, decPlural, strOpeIndPlan, dtIndUpdate, isGetFuture);

            //mod #10418 start
            if (ShouldAbortIndication(
                tbIndCond,
                isGetFuture,
                tbIndPlan,
                out starttime,
                out method))
            {
                return null;
            }
            //mod #10418 end

            string strTrun = "VALUE_1W" + tbIndPlan.Rows[0]["TURN"].ToString() + "N";

            DataRow dr = tbIndCond.Select("CTL_NO='001'").FirstOrDefault();
            starttime = dr == null ? null : dr[strTrun]?.ToString();


            DataRow[] drIndCond = tbIndCond.Select("CTL_NO='006'");
            string strTreatItemCd = drIndCond[0][strTrun].ToString();
            // 治療項目マスタ情報取得
            DataTable tbMstTreatItem = SelectMstTreatItemCheck(db, dtTargetDate, strTreatItemCd);
            string strUpdaterCd = drIndCond[0]["UPDATE_STAFF_CD"] as string;

            string strUpdaterName = GetSTAFF_NAME(db, strUpdaterCd, dtTargetDate);
            // 指示者名設定
            string strStaffCd = drIndCond[0]["INDICATOR_CD"] as string;
            string strStaffName = GetSTAFF_NAME(db, strStaffCd, dtTargetDate);

            //mod #10418 start
            method = BuildTreatMethodJson(
                     isRst,
                     tbMstTreatItem,
                     strUpdaterName,
                     strStaffName);
            //mod #10418 end

            string treatmentCdSql = "(select treatment_cd from mst_treatment where fn_treatment_cd = '" + strTreatItemCd + "' and facility_cd = '" + CommonConfig.FacilityCd + "')";
            method = String.Format(method, treatmentCdSql);
            DataTable tbSysTreatCond = SelectSysTreatCondSetting(db, strTreatItemCd);

            //シングルニードル使用　
            DataRow[] drAV = tbIndCond.Select("CTL_NO='029'");
            string sAV = drAV[0][strTrun].ToString();


            CheckCondCtlNo[] CtlNo = (CheckCondCtlNo[])Enum.GetValues(typeof(CheckCondCtlNo));


            //itemName,value,order,itemNo,指示者名設定,更新者名設定
            //var items = new List<Tuple<string, string, int,int, string, string>>();
            var items = new List<TreatCondItem>();
            //isDisable
            List<int> isDisable = new List<int>();

           

            //mod #10418 start
            HandleEquipmentAV(
                db,
                equipment,
                sAV,
                dtTargetDate,
                itemAV,
                isDisable);

            //mod #10418 start

            string k_unit = string.Empty;
            string h_unitind = string.Empty;
            string t_unitind = string.Empty;
            string sDW = string.Empty;
            for (int i = 0; i < CtlNo.Length; i++)
            {
                //mod #10418 start
                BuildCheckCondCtlNo(db, i, CtlNo, drIndCond, strTrun, items, tbIndCond, dtTargetDate, tbSysTreatCond,
                    isDisable, isRst, taboo, ref k_unit, ref h_unitind, ref t_unitind, ref sDW);
                //mod #10418 end

            }
            string treat_cond = "json_build_object('component','treat-cond','subCategoryNo',4,'subCategoryItem',json_build_array({0}),'subCategoryName','治療条件')";

            //mod #10418 start
            List<string> treatInfo = BuildItemJson(items, isRst, isDisable);
            //mod #10418 end

            return string.Format(treat_cond, string.Join(",", treatInfo.ToArray()));
        }

        private static string GetPrefix(bool isToboo, bool isDiff, bool isDel, bool isDelItem)
        {
            string retPrefix = "null";
            List<string> prefixs = new List<string>();

            if (isToboo)
            {
                prefixs.Add("【禁忌】");
            }

            if (isDiff)
            {
                prefixs.Add("【分類不一致】");
            }


            if (isDel)
            {
                prefixs.Add("【削除済み】");
            }
            else
            {
                if (isDelItem)
                {
                    prefixs.Add("【削除済み含む】");
                }
            }

            if (prefixs.Count() > 0)
            {
                retPrefix = string.Join("", prefixs);
            }

            return retPrefix;
        }

        private static DataTable SelectMstTreatItemCheck(DBCtrl db, DateTime? dtTarget, string strTreatItem)
        {
            IMakeSqlParameters param = db.GetIMakeSqlParameters();
            param.AddParam(":REG_DATE", dtTarget);
            param.AddParam(":TREAT_ITEM_CD", strTreatItem);
            StringBuilder sb = new StringBuilder();
            sb.Append(@"
                select
                    base.TREAT_ITEM_NAME,
                    a.DISP_FLG,base.DEL_FLG
                from
                    MST_TREAT_ITEM base
                      left join  MST_TREAT_ITEM_SUB_NEW  a on a.TREAT_ITEM_CD=base.TREAT_ITEM_CD
                where
                      base.REG_DATE <= :REG_DATE
                    and
                     base.TREAT_ITEM_CD = :TREAT_ITEM_CD
                    and ROWNUM=1
                ORDER BY   base.REG_DATE DESC     ");
            return db.SelectTable(sb.ToString(), param.GetParam());
        }
        private static DataTable Beddt = new DataTable();
        private static DataTable Kurdt = new DataTable();
        //医療材料マスタ情報
        private static DataTable Equipmentdt = new DataTable();
        //薬剤マスタマスタ情報
        private static DataTable Medidt = new DataTable();
        //セット薬剤名称マスタ情報
        private static DataTable SetMedidt = new DataTable();
        //ダイアライザマスタ情報
        private static DataTable MstDialyzerdt = new DataTable();
        //セット薬剤マスタ情報
        private static DataTable SetMedicinedt = new DataTable();

        private static List<string> itemName = new List<string>();
        public static void SelectMstBedCheck(DBCtrl db)
        {

            StringBuilder sb = new StringBuilder();
            sb.Append(@"
                select
                  BED_NAME,REG_DATE,BED_NO
                from
                    MST_BED ");
            Beddt = db.SelectTable(sb.ToString());
        }
        public static void SelectMstKurCheck(DBCtrl db)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append(@"
                select
                  KUR_NAME,KUR_CD,UP_DATE,
                  TO_CHAR(TO_DATE(SUBSTR(STANDARD_START_TIME, 1, LENGTH(STANDARD_START_TIME) - 2), 'HH24MI'), 'HH24:MI') as  STANDARD_START_TIME
                from
                    MST_KUR  ");
            Kurdt = db.SelectTable(sb.ToString());
        }
        public static void SelectMstEquipmentCheck(DBCtrl db)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append(@"
                select
                        LPAD(TRIM(a.EQUIP_CD), 10, '0')  as  EQUIP_CD,
	                    a.EQUIP_NAME,
	                    a.EQUIP_GROUP_CD,
	                    a.UNIT,
	                    a.DEL_FLG,
	                    decode(a.DEL_FLG,'1','0',b.DISP_FLG) AS DISP_FLG,
						a.UP_DATE
                    from
	                   MST_EQUIPMENT a
                       LEFT JOIN MST_EQUIPMENT_SUB_NEW b
                       ON 
                       a.EQUIP_CD=b.EQUIP_CD
           ");
            Equipmentdt = db.SelectTable(sb.ToString());

        }
        public static void SelectMstMediCheck(DBCtrl db)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append(@"
                select
                        trim( a.MEDICINE_CD ) AS MEDICINE_CD,
			            a.MEDICINE_NAME,
			            a.UNIT,
			            a.MEDICINE_GROUP_CD,
			            decode(a.DEL_FLG,'1','0',b.DISP_FLG) AS DISP_FLG,
                        a.UP_DATE
                    from
	                   MST_MEDICINE a
                       LEFT JOIN MST_MEDICINE_SUB_NEW b
                       ON 
                       a.MEDICINE_CD = b.MEDICINE_CD
           ");
            Medidt = db.SelectTable(sb.ToString());
        }
        public static void SelectMstSetMediCheck(DBCtrl db)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append(@"
                select
                        a.SET_MEDICINE_CD,
			            a.SET_MEDICINE_NAME,
			            a.MEDICINE_GROUP_CD,
			            a.UNIT,
			            a.IND_UNIT,
			            a.CAPACITY,
			            decode(a.DEL_FLG,'1','0',b.DISP_FLG) AS DISP_FLG,
                        a.UP_DATE
                    from
	                   MST_SET_MEDI_NAME a
                       LEFT JOIN MST_SET_MEDI_NAME_SUB_NEW b
                       ON 
                       a.SET_MEDICINE_CD = b.SET_MEDICINE_CD
           ");
            SetMedidt = db.SelectTable(sb.ToString());
        }

        public static void SelectMstDialyzerCheck(DBCtrl db)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append(@"
                        select
                            a.DIALYZER_CD,
                            a.MAKER,
                            a.MODEL_NUMBER,
                            decode(a.DEL_FLG,'1','0',b.DISP_FLG) AS DISP_FLG,
                            a.UP_DATE
                        from
                            MST_DIALYZER a
                           LEFT JOIN MST_DIALYZER_SUB_NEW b
                           ON 
                           a.DIALYZER_CD = b.DIALYZER_CD
                        ");

            MstDialyzerdt = db.SelectTable(sb.ToString());
        }

        public static void SelectMstSetMedicineCheck(DBCtrl db)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append(@"
                select
				        a.SET_MEDICINE_CD,
				        a.MEDICINE_CD,
				        a.UP_DATE
				        from
				        MST_SET_MEDICINE a
				        INNER JOIN MST_MEDICINE b on a.MEDICINE_CD = b.MEDICINE_CD
				        where
				            a.DEL_FLG = '0'
                        ORDER BY a.UP_DATE
           ");
            SetMedicinedt = db.SelectTable(sb.ToString());
        }

        private static DataTable GetCheckIndEquip(DBCtrl db, string strPatId, string strDialysisDate, decimal decPlural, DateTime? dtTargetDate, DataTable tbIndPlan, bool isGetFuture)
        {

            // 指示作成区分の設定
            string strOpeIndPlan = tbIndPlan.Rows[0]["OPE_IND_PLAN"] as string;

            // 医材指示情報取得時に使用する、更新日時と比較用日時
            DateTime dtIndUpdate = DateTime.Now;
            if (true == dtTargetDate.HasValue)
            {
                // 確認日時が存在する場合は、その日付を使用する
                dtIndUpdate = dtTargetDate.Value;
            }
            // 医材指示情報取得
            DataTable tbIndEquip = SelectIndDialysisEquip(db, strPatId, strDialysisDate, decPlural, strOpeIndPlan, dtIndUpdate, isGetFuture);
            DataTable filteredTable = tbIndEquip.Clone();

            var query = tbIndEquip.AsEnumerable().Where(row => row.Field<string>("DEL_FLG") == "0")?.ToArray();
            foreach (var row in query)
            {
                filteredTable.ImportRow(row);
            }
            if (null == filteredTable)
            {
                return null;
            }
            if (0 == filteredTable.Rows.Count)
            {
                // 医材指示 0件
                return CreateTableIndEquip();
            }

            return filteredTable;
        }

        private static string GetCheckContentEquip(DataTable equipment, DataTable taboo, DBCtrl db, DateTime? dtTargetDate, DataTable tbIndPlan, bool isRst)
        {

            if (null == equipment || 0 == equipment.Rows.Count || false == FnwNumber.Is(tbIndPlan.Rows[0]["TURN"]))
            {
                return "json_build_object('component','equipment','subCategoryNo',6,'subCategoryItem',json_build_array(),'subCategoryName','医療材料')";
            }

            int intTurn = (int)FnwNumber.ToDecimal(tbIndPlan.Rows[0]["TURN"]);

            string strTrun = "VALUE_1W" + intTurn.ToString() + "N";

            string all = "json_build_object('component','equipment','subCategoryNo',6,'subCategoryItem',json_build_array({0}),'subCategoryName','医療材料')";

            List<string> items = new List<string>();

            string itemtemplete = "json_build_object('itemInfo',json_build_object('itemName','{6}','itemNo',null,'itemCd',{5},'itemType',0,'data',json_build_object('value',json_build_object('prefix',{0},'dispVal','{1}','unit',{2}),'updater','{3}','instructor','{4}')))";

            // 取得した医材指示情報(DataTable)から有効最新情報を抽出し、戻り値用データテーブルに設定
            // 該当項目番号(CTL_NO)を取得

            var groupData = from row in equipment.Select("DEL_FLG='0'")
                            group row by row.Field<string>("SN_EQUIP_CD") into g
                            where g.Any()
                            select new
                            {
                                SN_EQUIP_CD = g.Key,
                                EQUIP_CD = g.First().Field<string>("EQUIP_CD"),
                                INDICATOR_CD = g.First().Field<string>("INDICATOR_CD"),
                                UPDATE_STAFF_CD = g.First().Field<string>("UPDATE_STAFF_CD"),
                                AMOUNT = g.Sum(r =>
                                {
                                    decimal amount;
                                    if (r.IsNull(strTrun) || !decimal.TryParse(r.Field<string>(strTrun), out amount))
                                    {
                                        amount = 0;
                                    }
                                    return amount;
                                })

                            };
            foreach (var item in groupData)
            {
                // 医療材料コード
                if (true == string.IsNullOrEmpty(item.SN_EQUIP_CD))
                {
                    continue;
                }
                string equipCdSql = "(select equipment_cd from mst_equipment where fn_equipment_cd = '" + item.SN_EQUIP_CD + "' and facility_cd = '" + CommonConfig.FacilityCd + "')";

                // 医療材料マスタから情報取得
                DataRow tbMstEquip = Equipmentdt.AsEnumerable().Where(row => row.Field<string>("EQUIP_CD") == item.EQUIP_CD && row.Field<DateTime>("UP_DATE") <= dtTargetDate).OrderByDescending(crow => (DateTime)crow["UP_DATE"]).FirstOrDefault();
                if (null == tbMstEquip)
                {
                    continue;
                }

                string strMediName = SpecialDataFormat(tbMstEquip["EQUIP_NAME"].ToString());

                string dispFlg = tbMstEquip["DISP_FLG"].ToString();

                string amount = item.AMOUNT.ToString();
                if (string.IsNullOrEmpty(amount) || amount.Equals("0"))
                {
                    continue;
                }

                string strUnit = "null";

                string prefix = "null";

                if (isRst)
                {
                    bool isTaboo = isTaBoo(item.EQUIP_CD, "3", taboo);
                    
                    strUnit = SpecialDataFormat(tbMstEquip["UNIT"].ToString());

                    if (!string.IsNullOrEmpty(strUnit))
                    {
                        strUnit = "'" + strUnit + "'";
                    }
                    else
                    {
                        strUnit = "null";
                    }

                    
                }



                // 指示者情報
                string strStaffName = SpecialDataFormat(GetSTAFF_NAME(db, item.INDICATOR_CD, dtTargetDate));

                // 更新情報
                string strUpdaterName = SpecialDataFormat(GetSTAFF_NAME(db, item.UPDATE_STAFF_CD, dtTargetDate));

                // 戻り値用データテーブルに格納

                items.Add(string.Format(itemtemplete, prefix, amount, strUnit, strUpdaterName, strStaffName, equipCdSql, strMediName));

            }

            if (items == null || items.Count() == 0)
            {
                return "json_build_object('component','equipment','subCategoryNo',6,'subCategoryItem',json_build_array(),'subCategoryName','医療材料')";
            }

            return string.Format(all, string.Join(",", items.ToArray()));
        }

        private static string GetCheckContentAddition(DBCtrl db, string strPatId, string strDialysisDate, decimal decPlural, DateTime? dtTargetDate, DataTable tbIndPlan, bool isGetFuture)
        {

            // 指示簿指示情報取得時に使用する、更新日時と比較用日時
            DateTime dtIndUpdate = DateTime.Now;
            if (true == dtTargetDate.HasValue)
            {
                // 確認日時が存在する場合は、その日付を使用する
                dtIndUpdate = dtTargetDate.Value;
            }

            // 指示作成区分の設定
            string strOpeIndPlan = tbIndPlan.Rows[0]["OPE_IND_PLAN"] as string;

            // 指示簿指示情報取得
            DataTable tbIndAdd = SelectIndDialysisAdd(db, strPatId, strDialysisDate, decPlural, strOpeIndPlan, dtIndUpdate, isGetFuture);

            if (null == tbIndAdd || 0 == tbIndAdd.Rows.Count)
            {
                //  指示簿指示情報 0件
                return "json_build_object('component','ind-comment','subCategoryNo',7,'subCategoryItem',json_build_array(),'subCategoryName','指示コメント')";
            }


            string all = "json_build_object('component','ind-comment','subCategoryNo',7,'subCategoryItem',json_build_array({0}),'subCategoryName','指示コメント')";
            List<string> items = new List<string>();
            string itemtemplete = "json_build_object('itemInfo',json_build_object('itemName','{4}','itemNo',{3}, 'itemCd',null,'itemType',null,'data',json_build_object('value',json_build_object('unit',null,'prefix',null,'dispVal','{0}'),'updater','{1}','instructor','{2}')))";


            var groupData = from row in tbIndAdd.Select("DEL_FLG='0'")
                            group row by new { ADDITION = row.Field<string>("ADDITION") } into g
                            select new
                            {
                                Key = g.Key,
                                CTL_NO = g.First().Field<string>("CTL_NO"),
                                INDICATOR_CD = g.First().Field<string>("INDICATOR_CD"),
                                UPDATE_STAFF_CD = g.First().Field<string>("UPDATE_STAFF_CD")
                            };

            foreach (var item in groupData)
            {
                decimal ctl_no;

                if (!decimal.TryParse(item.CTL_NO, out ctl_no))
                {
                    continue;
                }

                string addition = SpecialDataFormat(item.Key.ADDITION);


                // -----------------
                // 以下、値を設定
                // -----------------
                // 指示者情報
                string strStaffName = SpecialDataFormat(GetSTAFF_NAME(db, item.INDICATOR_CD, dtTargetDate));

                // 更新情報
                string strUpdaterName = SpecialDataFormat(GetSTAFF_NAME(db, item.UPDATE_STAFF_CD, dtTargetDate));

                // 戻り値用データテーブルに格納
                items.Add(string.Format(itemtemplete, addition, strUpdaterName, strStaffName, ctl_no, "コメント" + ctl_no));


            }


            if (items == null || items.Count() == 0)
            {
                return "json_build_object('component','ind-comment','subCategoryNo',7,'subCategoryItem',json_build_array(),'subCategoryName','指示コメント')";
            }

            return string.Format(all, string.Join(",", items.ToArray()));
        }

        protected static string SpecialDataFormat(string value)
        {
            if (!string.IsNullOrEmpty(value))
            {
                return value.Replace("'", "''").Replace("\\", "\\\\").Replace(Environment.NewLine, "\\n").Replace("\n", "\\n").Replace("\r", "\\n").Replace("\t", "\\t");

            }
            else
            {
                return value;
            }
        }

        protected static string SpecialDataFormatCon(string value)
        {

            if (!value.Equals("null") && !string.IsNullOrEmpty(value))
            {
                return "'" + value.Replace("'", "''").Replace("\\", "\\\\").Replace(Environment.NewLine, "\\n").Replace("\n", "\\n").Replace("\r", "\\n").Replace("\t", "\\t") + "'";

            }
            else
            {
                return "null";

            }
        }

        private static bool isTaBoo(string tabooCd, string tabooClass, DataTable taboo)
        {
            DataRow[] tabooMediItem = taboo.Select("TABOO_CLASS = '" + tabooClass + "' and TABOO_CD = '" + tabooCd + "'");

            if (tabooMediItem.Length > 0)
            {
                return true;
            }
            return false;
        }
        public class ItemAV
        {
            public string Key { get; set; }
            public string Value1 { get; set; }
            public string Value2 { get; set; }
            public string Value3 { get; set; }

            public ItemAV(string key, string value1, string value2)
            {
                Key = key;
                Value1 = value1;
                Value2 = value2;
                Value3 = Value3;
            }
        }

        struct TreatCondItem
        {
            public string value;
            public int order;
            public int itemNo;
            public string itemName;
            public string unit;
            public string prefix;
            public string instructor;
            public string updater;
            public string itemCd;
            public string itemType;
            public TreatCondItem(string _itemName, string _value, int _order, int _itemNo, string _updater, string _instructor, string _unit, string _prefix, string _itemCd, string _itemType)
            {
                value = _value;
                order = _order;
                itemNo = _itemNo;
                itemName = _itemName;
                unit = _unit;
                prefix = _prefix;
                instructor = _instructor;
                updater = _updater;
                itemCd = _itemCd;
                itemType = _itemType;
            }
        }

        struct ScheduleItem
        {
            public string itemName;
            public int itemNo;
            public string itemCd;
            public string dispVal;
            public string prefix;

            public ScheduleItem(string _itemName, int _itemNo, string _itemCd, string _dispVal, string _prefix)
            {
                itemName = _itemName;
                itemNo = _itemNo;
                itemCd = _itemCd;
                dispVal = _dispVal;
                prefix = _prefix;

            }
        }

        private static string getMedCd(string classCd, string code)
        {

            //セット薬剤
            if (classCd.Equals("1"))
            {
                return "( select medicine_mix_cd from mst_medicine_mix where facility_cd='" + CommonConfig.FacilityCd + "' and fn_set_medicine_cd='" + code + "')";
            }
            else
            {
                return "( select medicine_cd from mst_medicine where facility_cd='" + CommonConfig.FacilityCd + "' and fn_medicine_cd='" + code + "')";
            }

        }
        private static string getMedType(string classCd)
        {

            //セット薬剤
            return classCd == "0" ? "1" : "2";

        }
        #endregion


        //add #10418 start
        private static List<string> BuildItemJson(List<TreatCondItem> items, bool isRst, List<int> isDisable)
        {

            var sortedItems = items.OrderBy(t => t.order).ToList();
            List<string> treatInfo = new List<string>();
            foreach (var item in sortedItems)
            {


                if (isRst)
                {
                    if (isDisable.Contains(item.itemNo))
                    {
                        treatInfo.Add("json_build_object('itemInfo' ,json_build_object( 'itemName', '" + item.itemName + "','itemNo'," + item.itemNo + ",'itemCd'," + item.itemCd + ",'itemType'," + item.itemType + ",'data',json_build_object('value',json_build_object('prefix',null,'dispVal','未登録','unit',null),'updater','','isDisable',true,'instructor','')" +
                             "))");
                    }
                    else
                    {

                        treatInfo.Add("json_build_object('itemInfo' ,json_build_object('itemName', '" + item.itemName + "','itemNo'," + item.itemNo + ",'itemCd'," + item.itemCd + ",'itemType'," + item.itemType + ",'data',json_build_object('value',json_build_object('prefix',null,'dispVal','" + SpecialDataFormat(item.value) + "','unit'," + SpecialDataFormatCon(item.unit) + "),'updater','','instructor','')" +
                           "))");
                    }
                }
                else
                {
                    if (isDisable.Contains(item.itemNo))
                    {
                        treatInfo.Add("json_build_object('itemInfo' ,json_build_object('itemName', '" + item.itemName + "','itemNo'," + item.itemNo + ",'itemCd'," + item.itemCd + ",'itemType'," + item.itemType + ",'data',json_build_object('value',json_build_object('prefix',null,'dispVal','未登録','unit',null),'updater','" + SpecialDataFormat(item.updater) + "','isDisable',true,'instructor','" + SpecialDataFormat(item.instructor) + "')" +
                        "))");
                    }
                    else
                    {
                        if (string.IsNullOrEmpty(item.value))
                        {
                            treatInfo.Add("json_build_object('itemInfo' ,json_build_object('itemName', '" + item.itemName + "','itemNo'," + item.itemNo + ",'itemCd'," + item.itemCd + ",'itemType'," + item.itemType + ",'data',json_build_object('value',json_build_object('prefix',null,'dispVal',null,'unit',null),'updater','" + SpecialDataFormat(item.updater) + "','instructor','" + SpecialDataFormat(item.instructor) + "')" +
                         "))");
                        }
                        else
                        {
                            treatInfo.Add("json_build_object('itemInfo' ,json_build_object('itemName', '" + item.itemName + "','itemNo'," + item.itemNo + ",'itemCd'," + item.itemCd + ",'itemType'," + item.itemType + ",'data',json_build_object('value',json_build_object('prefix',null,'dispVal','" + SpecialDataFormat(item.value) + "','unit',null),'updater','" + SpecialDataFormat(item.updater) + "','instructor','" + SpecialDataFormat(item.instructor) + "')" +
                         "))");
                        }

                    }

                }

            }

            return treatInfo;
        }

        private static string BuildTreatMethodJson(
            bool isRst,
            DataTable tbMstTreatItem,
            string strUpdaterName,
            string strStaffName)
        {

            if (isRst)
            {
                if (tbMstTreatItem.Rows[0]["DISP_FLG"].ToString().Equals("0") || tbMstTreatItem.Rows[0]["DEL_FLG"].ToString().Equals("1"))
                {
                    return @"json_build_object('component','treat-method', 'subCategoryNo',2,'subCategoryItem',json_build_array(),'subCategoryName','治療方法'," +
                         "'itemInfo',json_build_object('itemName', null , 'itemNo', 1, 'itemCd',{0} ,'itemType', null," +
                         "'data',json_build_object('value',json_build_object('unit',null, 'prefix','【削除済み】','dispVal','" + SpecialDataFormat(tbMstTreatItem.Rows[0]["TREAT_ITEM_NAME"].ToString()) + "'), 'updater', '" + strUpdaterName + "', 'instructor', '" + strStaffName + "')))";
                }
                else
                {
                    return @"json_build_object('component','treat-method', 'subCategoryNo',2,'subCategoryItem',json_build_array(),'subCategoryName','治療方法'," +
                  "'itemInfo',json_build_object('itemName', null , 'itemNo', 1, 'itemCd',{0} ,'itemType', null," +
                  "'data',json_build_object('value',json_build_object('unit',null, 'prefix',null,'dispVal','" + SpecialDataFormat(tbMstTreatItem.Rows[0]["TREAT_ITEM_NAME"].ToString()) + "'), 'updater', '" + strUpdaterName + "', 'instructor', '" + strStaffName + "')))";
                }
            }
            else
            {
                return @"json_build_object('component','treat-method', 'subCategoryNo',2,'subCategoryItem',json_build_array(),'subCategoryName','治療方法'," +
                    "'itemInfo',json_build_object('itemName', null , 'itemNo', 1, 'itemCd',{0} ,'itemType', null," +
                    "'data',json_build_object('value',json_build_object('unit',null, 'prefix',null,'dispVal',null), 'updater', '" + strUpdaterName + "', 'instructor', '" + strStaffName + "')))";
            }

        }
        //add #10418 end
        private static bool ShouldAbortIndication(
            DataTable tbIndCond,
            bool isGetFuture,
            DataTable tbIndPlan,
            out string starttime,
            out string method)
        {
            starttime = null;
            method = null;

            // 条件指示が存在しない
            if (tbIndCond == null)
                return true;

            // 未来情報取得時で、条件指示 0件の場合
            if (isGetFuture && tbIndCond.Rows.Count == 0)
                return true;

            // その週の何回目かの情報の設定(VALUE_1W○N)
            if (false == FnwNumber.Is(tbIndPlan.Rows[0]["TURN"]))
                return true;

            return false;
        }
        private static void HandleEquipmentAV(
            DBCtrl db,
            DataTable equipment,
            string sAV,
            DateTime? dtTargetDate,
            List<ItemAV> itemAV,
            List<int> isDisable)
        {

            // 血液回路
            List<string> LBoold = CommonConfig.Boold[CommonConfig.seriesCd];
            if (LBoold != null)
            {
                foreach (DataRow rows in equipment.Select("SETTING='0' and DEL_FLG='0'"))
                {
                    if (LBoold.Contains(rows["EQUIP_CD"]))
                    {
                        itemAV.FirstOrDefault(i => i.Key == "BOOLD").Value1 = rows["EQUIP_CD"].ToString();
                        itemAV.FirstOrDefault(i => i.Key == "BOOLD").Value2 = GetSTAFF_NAME(db, rows["UPDATE_STAFF_CD"] as string, dtTargetDate);
                        itemAV.FirstOrDefault(i => i.Key == "BOOLD").Value3 = GetSTAFF_NAME(db, rows["INDICATOR_CD"] as string, dtTargetDate);

                        equipment.Rows.Remove(rows);
                        break;
                    }
                }
            }
            if (sAV.Equals("0"))
            {
                isDisable.Add(11);
                //穿刺針(A針)
                List<string> Lp_A = CommonConfig.p_A[CommonConfig.seriesCd];
                if (Lp_A != null)
                {

                    foreach (DataRow rows in equipment.Select("SETTING='1' and DEL_FLG='0'"))
                    {
                        if (Lp_A.Contains(rows["EQUIP_CD"]))
                        {
                            itemAV.FirstOrDefault(i => i.Key == "A").Value1 = rows["EQUIP_CD"].ToString();
                            itemAV.FirstOrDefault(i => i.Key == "A").Value2 = GetSTAFF_NAME(db, rows["UPDATE_STAFF_CD"] as string, dtTargetDate);
                            itemAV.FirstOrDefault(i => i.Key == "A").Value3 = GetSTAFF_NAME(db, rows["INDICATOR_CD"] as string, dtTargetDate);
                            equipment.Rows.Remove(rows);
                            break;
                        }
                    }
                }
                //穿刺針(V針)
                List<string> Lp_V = CommonConfig.p_V[CommonConfig.seriesCd];
                if (Lp_V != null)
                {

                    foreach (DataRow rows in equipment.Select("SETTING='2' and DEL_FLG='0'"))
                    {
                        if (Lp_V.Contains(rows["EQUIP_CD"]))
                        {
                            itemAV.FirstOrDefault(i => i.Key == "V").Value1 = rows["EQUIP_CD"].ToString();
                            itemAV.FirstOrDefault(i => i.Key == "V").Value2 = GetSTAFF_NAME(db, rows["UPDATE_STAFF_CD"] as string, dtTargetDate);
                            itemAV.FirstOrDefault(i => i.Key == "V").Value3 = GetSTAFF_NAME(db, rows["INDICATOR_CD"] as string, dtTargetDate);
                            equipment.Rows.Remove(rows);
                            break;
                        }
                    }
                }

            }
            else
            {
                isDisable.Add(9);
                isDisable.Add(10);
                //穿刺針(SN針)
                List<string> Lp_SN = CommonConfig.p_SN[CommonConfig.seriesCd];
                if (Lp_SN != null)
                {

                    foreach (DataRow rows in equipment.Select("SETTING='3' and DEL_FLG='0'"))
                    {
                        if (Lp_SN.Contains(rows["EQUIP_CD"]))
                        {
                            itemAV.FirstOrDefault(i => i.Key == "SN").Value1 = rows["EQUIP_CD"].ToString();
                            itemAV.FirstOrDefault(i => i.Key == "SN").Value2 = GetSTAFF_NAME(db, rows["UPDATE_STAFF_CD"] as string, dtTargetDate);
                            itemAV.FirstOrDefault(i => i.Key == "SN").Value3 = GetSTAFF_NAME(db, rows["INDICATOR_CD"] as string, dtTargetDate);
                            equipment.Rows.Remove(rows);
                            break;
                        }
                    }
                }

            }

        }

        private static bool isDisableSet(DataRow dr, int No, List<int> isDisable)
        {

            if (dr["USE_FLG"].ToString().Equals("0"))
            {
                isDisable.Add(No);
                return true;
            }
            return false;
        }

        private static void BuildNumericTreatItem(string name,List<TreatCondItem> items,DataTable tbSysTreatCond, string CtlNo, List<int> isDisable, DataRow[] rowIndCond,
              string strTrun,string strUpdaterName,string strStaffName, string unit, int itemNo, int parentNo) {

            DataRow dr = tbSysTreatCond.Select($"COND_CTL_NO='{CtlNo}'").FirstOrDefault();
            if (!isDisableSet(dr, parentNo, isDisable))
            {
                if (string.IsNullOrEmpty(rowIndCond[0][strTrun].ToString()))
                {
                    items.Add(new TreatCondItem(name, "未登録", itemNo, parentNo, strUpdaterName, strStaffName, "null", "null", "null", "null"));
                }
                else
                {
                    items.Add(new TreatCondItem(name, Convert.ToDouble(rowIndCond[0][strTrun]).ToString("F2"), itemNo, parentNo, strUpdaterName, strStaffName, unit, "null", "null", "null"));
                }

            }


        }

        private static void BuildCheckCondCtlNo(DBCtrl db, int i, CheckCondCtlNo[] CtlNo, DataRow[] drIndCond, string strTrun, List<TreatCondItem> items,
              DataTable tbIndCond, DateTime? dtTargetDate, DataTable tbSysTreatCond, List<int> isDisable, bool isRst,
             DataTable taboo, ref string k_unit,
             ref string h_unitind,
                ref string t_unitind,
                ref string sDW)
        {

            string strUpdaterCd = drIndCond[0]["UPDATE_STAFF_CD"] as string;
            string strUpdaterName = GetSTAFF_NAME(db, drIndCond[0]["UPDATE_STAFF_CD"] as string, dtTargetDate);

            // 指示者名設定
            string strStaffCd = drIndCond[0]["INDICATOR_CD"] as string;
            string strStaffName = GetSTAFF_NAME(db, strStaffCd, dtTargetDate);


            string strSelect = "CTL_NO = '" + ((int)CtlNo[i]).ToString("000") + "' and DEL_FLG = '0'";
            DataRow[] rowIndCond = tbIndCond.Select(strSelect);

            switch ((CheckCondCtlNo)CtlNo[i])
            {
                // 透析時間(002)
                case CheckCondCtlNo.DIALYSIS_TIME:

                    // 値(VAコード)の取得
                    if (string.IsNullOrEmpty(rowIndCond[0][strTrun].ToString()))
                    {
                        items.Add(new TreatCondItem("治療時間", "未登録", 1, 1, strUpdaterName, strStaffName, "null", "null", "null", "null"));
                    }
                    else
                    {
                        int totalMinutes = int.Parse(rowIndCond[0][strTrun].ToString());
                        int hours = totalMinutes / 60;
                        int minutes = totalMinutes % 60;
                        items.Add(new TreatCondItem("治療時間", $"{hours:D2}:{minutes:D2}", 1, 1, strUpdaterName, strStaffName, "null", "null", "null", "null"));
                    }
                    break;

                // VA(003)
                case CheckCondCtlNo.VA:

                    BuildVA(db, tbSysTreatCond, items, isRst, strUpdaterName, strStaffName, isDisable, strTrun, rowIndCond, dtTargetDate);

                    break;
                // DW(004)
                case CheckCondCtlNo.DW:

                    BuildNumericTreatItem("DW", items, tbSysTreatCond, "004", isDisable, rowIndCond, strTrun, strUpdaterName, strStaffName, "kg", 3, -1);
                    sDW = rowIndCond[0][strTrun].ToString();
                   
                    break;
                //目標体重(005)
                case CheckCondCtlNo.TW:

                    BuildTW( tbSysTreatCond, items,  strUpdaterName,  strStaffName ,isDisable,  strTrun, rowIndCond, ref sDW); 
                    break;

                // 除水量制限(007)
                case CheckCondCtlNo.REMOVE_WATER_LIMIT:

                    BuildNumericTreatItem("除水量制限",items,tbSysTreatCond, "007", isDisable, rowIndCond, strTrun, strUpdaterName, strStaffName, "L", 5, 4);

                    break;
                // 血液浄化器[ダイアライザ](008)
                case CheckCondCtlNo.DIALYZER:

                    BuildDialyzer(tbSysTreatCond, items, taboo, isRst, strUpdaterName, strStaffName, isDisable, strTrun, rowIndCond, dtTargetDate);
                    break;

                // 吸着カラム(009)
                case CheckCondCtlNo.ADSORB:
                    
                    BuildAdsorb(tbSysTreatCond, items, taboo, isRst, strUpdaterName, strStaffName, isDisable, strTrun, rowIndCond, dtTargetDate);
                    break;
                // 1次膜(039)
                case CheckCondCtlNo.FIRST_FILM:

                    BuildFirstFilm(tbSysTreatCond, items, taboo, isRst, strUpdaterName, strStaffName, isDisable, strTrun, rowIndCond, dtTargetDate);
                    break;
                // 2次膜(040)
                case CheckCondCtlNo.SECOND_FILM:

                    BuildSecondFilm(tbSysTreatCond, items, taboo, isRst, strUpdaterName, strStaffName, isDisable, strTrun, rowIndCond, dtTargetDate);
                    break;
                // 穿刺針(A針)(041)
                case CheckCondCtlNo.A:

                    BuildA(items, taboo, isRst, dtTargetDate);
                    break;
                // 穿刺針(V針)(042)
                case CheckCondCtlNo.V:

                    BuildV(items, taboo, isRst, dtTargetDate);
                    break;
                // 穿刺針(SN針)(043)
                case CheckCondCtlNo.SN:

                    BuildSN(items, taboo, isRst, dtTargetDate);
                    break;
                // シングルニードル使用(029)
                case CheckCondCtlNo.SINGLE_NEEDLE:

                    if (rowIndCond[0][strTrun].Equals("0"))
                    {
                        isDisable.Add(11);
                        items.Add(new TreatCondItem("シングルニードル使用", "使用しない", 13, 12, strUpdaterName, strStaffName, "null", "null", "null", "null"));
                    }
                    else
                    {
                        isDisable.Add(9);
                        isDisable.Add(10);
                        items.Add(new TreatCondItem("シングルニードル使用", "使用する", 13, 12, strUpdaterName, strStaffName, "null", "null", "null", "null"));
                    }
                    break;
                // 血液回路(044)
                case CheckCondCtlNo.BOOLD:

                    BuildBOOLD(tbSysTreatCond, items,  taboo, isRst, dtTargetDate, isDisable);
                    break;
                // 血流量(010)
                case CheckCondCtlNo.BLOOD_MEASURE:

                    BuildAddDisableItem(tbSysTreatCond, "010", isDisable, items, "血流量", 15, 14, rowIndCond, strTrun, strUpdaterName, strStaffName, "mL/min",0);

                    break;
                // 透析液(018)
                case CheckCondCtlNo.DIALYSIS_LIQUID:
                   
                    BuildDIALYSIS_LIQUID(tbSysTreatCond, items, taboo, isRst, strUpdaterName, strStaffName, isDisable, strTrun, rowIndCond, dtTargetDate,ref t_unitind);      
                    break;
                // 透析液流量(019)
                case CheckCondCtlNo.DIALYSIS_FLOW:

                    BuildAddDisableItem(tbSysTreatCond, "019", isDisable, items, "透析液流量", 17, 16, rowIndCond, strTrun, strUpdaterName, strStaffName, "mL/min", 0);
                    break;
                // 透析液量(020)
                case CheckCondCtlNo.DIALYSIS_MEASURE:

                    BuildAddDisableItem(tbSysTreatCond, "020", isDisable, items, "透析液使用数", 18, 17, rowIndCond, strTrun, strUpdaterName, strStaffName, t_unitind, 2);
                    break;
                // 透析液温度(021)
                case CheckCondCtlNo.DIALYSIS_TEMP:

                    BuildAddDisableItem(tbSysTreatCond, "021", isDisable, items, "透析液温度", 19, 18, rowIndCond, strTrun, strUpdaterName, strStaffName, "℃", 1);

                    break;
                // 補液(022)
                case CheckCondCtlNo.REP_LIQUID:
                 
                    BuildREP_LIQUID(tbSysTreatCond, items, taboo, isRst, strUpdaterName, strStaffName, isDisable, strTrun, rowIndCond, dtTargetDate,ref h_unitind);
                    break;
                // 補液量(023)
                case CheckCondCtlNo.REP_MEASURE:

                    BuildAddDisableItem(tbSysTreatCond, "023", isDisable, items, "補液量", 21, 20, rowIndCond, strTrun, strUpdaterName, strStaffName, "L", 1);
                    break;
                // 補液選択(024)
                case CheckCondCtlNo.REP_SELECT:

                    if (AddDisableItem(tbSysTreatCond, "024", isDisable, items, "補液選択", 22, 21))
                    {
                        items.Add(new TreatCondItem("補液選択", rowIndCond[0][strTrun] == null ? "未登録" : rowIndCond[0][strTrun].ToString().Equals("1") ? "前補液" : "後補液", 22, 21, strUpdaterName, strStaffName, "null", "null", "null", "null"));
                    }
                    break;
                // 補液使用数(030)
                case CheckCondCtlNo.REP_USE_COUNT:
                    BuildAddDisableItem(tbSysTreatCond, "030", isDisable, items, "補液使用数", 23, 22, rowIndCond, strTrun, strUpdaterName, strStaffName, h_unitind, 2);
                    break;
                // 補液温度(025)
                case CheckCondCtlNo.REP_TEMP:

                    BuildAddDisableItem(tbSysTreatCond, "025", isDisable, items, "補液温度", 24, 23, rowIndCond, strTrun, strUpdaterName, strStaffName, "℃", 1);
                    break;
                //補液速度(038)
                case CheckCondCtlNo.REP_SPEED:

                    BuildAddDisableItem(tbSysTreatCond, "038", isDisable, items, "補液速度", 25, 24, rowIndCond, strTrun, strUpdaterName, strStaffName, "L/h", 2);
                    break;
                // 抗凝固剤(011)
                case CheckCondCtlNo.ANTI_LIQUID:

                    BuildANTI_LIQUID(tbSysTreatCond, items, taboo, isRst, strUpdaterName, strStaffName, isDisable, strTrun, rowIndCond, dtTargetDate,ref k_unit);
                    break;
                // 抗凝固剤ワンショット量(012)
                case CheckCondCtlNo.ANTI_ONESHOT:

                    BuildAddDisableItem(tbSysTreatCond, "012", isDisable, items, "抗凝固剤ワンショット量", 27, 26, rowIndCond, strTrun, strUpdaterName, strStaffName, k_unit, 2);
                    break;
                // 抗凝固剤持続速度(013)
                case CheckCondCtlNo.ANTI_SPEED:

                    BuildAddDisableItem(tbSysTreatCond, "013", isDisable, items, "抗凝固剤持続速度", 28, 27, rowIndCond, strTrun, strUpdaterName, strStaffName, k_unit + "/h", 2);
                    break;
                // 抗凝固剤持続総量(014)
                case CheckCondCtlNo.ANTI_TOTAL:

                    BuildAddDisableItem(tbSysTreatCond, "014", isDisable, items, "抗凝固剤持続総量", 29, 28, rowIndCond, strTrun, strUpdaterName, strStaffName, k_unit, 2);
                    break;
                // IP使用選択(015)
                case CheckCondCtlNo.IP_SELECT:

                    BuildAddDisableItem(tbSysTreatCond, "015", isDisable, items, "IP使用選択", 30, 29, rowIndCond, strTrun, strUpdaterName, strStaffName, "mL",5);
                    break;
                // IPスタート(031)
                case CheckCondCtlNo.IP_START:

                    BuildAddDisableItem(tbSysTreatCond, "031", isDisable, items, "IPスタート", 31, 30, rowIndCond, strTrun, strUpdaterName, strStaffName, "mL", 6);
                    break;
                // IPワンショット量(016)
                case CheckCondCtlNo.IP_MEASURE:

                    BuildAddDisableItem(tbSysTreatCond, "016", isDisable, items, "IPワンショット量", 32, 31, rowIndCond, strTrun, strUpdaterName, strStaffName, "mL", 1);
                    break;
                // IP速度(017)
                case CheckCondCtlNo.IP_SPEED:

                    BuildAddDisableItem(tbSysTreatCond, "017", isDisable, items, "IP速度", 33, 32, rowIndCond, strTrun, strUpdaterName, strStaffName, "mL/h", 1);
                    break;
                // IP速度最大値(037)
                case CheckCondCtlNo.IP_MAX_SPEED:

                    BuildAddDisableItem(tbSysTreatCond, "037", isDisable, items, "IP速度最大値", 34, 33, rowIndCond, strTrun, strUpdaterName, strStaffName, "mL/h", 1);
                    break;
                // 自動ワンショット(032)
                case CheckCondCtlNo.IP_AUTO_ONESHOT:

                    BuildAddDisableItem(tbSysTreatCond, "032", isDisable, items, "自動ワンショット", 35, 34, rowIndCond, strTrun, strUpdaterName, strStaffName, "null", 5);
                    break;
                // IP電源自動切り(033)
                case CheckCondCtlNo.IP_AUTO_OFF:

                    BuildAddDisableItem(tbSysTreatCond, "033", isDisable, items, "IP電源自動切り", 36, 35, rowIndCond, strTrun, strUpdaterName, strStaffName, "null", 4);
                    break;
                // IP電源自動切り時間(034)
                case CheckCondCtlNo.IP_AUTO_OFF_TIME:

                    BuildAddDisableItem(tbSysTreatCond, "034", isDisable, items, "IP電源自動切り時間", 37, 36, rowIndCond, strTrun, strUpdaterName, strStaffName, "分",0);
                    break;
                // IP電源OKモニタ切り(035)
                case CheckCondCtlNo.IP_OK_MON_OFF:

                    BuildAddDisableItem(tbSysTreatCond, "035", isDisable, items, "IP電源OKモニタ切り", 38, 37, rowIndCond, strTrun, strUpdaterName, strStaffName, "null", 4);
                    break;
                // IP電源OKモニタ切り時間(036)
                case CheckCondCtlNo.IP_OK_MON_OFF_TIME:

                    BuildAddDisableItem(tbSysTreatCond, "036", isDisable, items, "IP電源OKモニタ切り時間", 39, 38, rowIndCond, strTrun, strUpdaterName, strStaffName, "分",0);
                    break;
            }
        }

        private static void BuildAdsorb(DataTable tbSysTreatCond, List<TreatCondItem> items,DataTable taboo,bool isRst,string strUpdaterName, string strStaffName
            , List<int> isDisable,string strTrun, DataRow[] rowIndCond, DateTime? dtTargetDate) {


            DataRow dr = tbSysTreatCond.Select("COND_CTL_NO='009'").FirstOrDefault();
            if (isDisableSet(dr, 6, isDisable))
            {
                items.Add(new TreatCondItem("吸着カラム", "未登録", 7, 6, "", "", "null", "null", "null", "null"));
            }
            else
            {

                if (string.IsNullOrEmpty(rowIndCond[0][strTrun].ToString()))
                {
                    items.Add(new TreatCondItem("吸着カラム", "未登録", 7, 6, strUpdaterName, strStaffName, "null", "null", "null", "null"));
                }
                else
                {     // 医療材料マスタ情報取得
                    DataRow rowEquipment = Equipmentdt.AsEnumerable().Where(row => row.Field<string>("EQUIP_CD") == rowIndCond[0][strTrun].ToString() && row.Field<DateTime>("UP_DATE") <= dtTargetDate).OrderByDescending(crow => (DateTime)crow["UP_DATE"]).FirstOrDefault();
                    if (null == rowEquipment)
                    {
                        items.Add(new TreatCondItem("吸着カラム", "未登録", 7, 6, strUpdaterName, strStaffName, "null", "null", "null", "null"));
                    }
                    else
                    {
                        bool isDel = "0".Equals(rowEquipment["DISP_FLG"].ToString());
                        bool isTaboo = isTaBoo(rowEquipment["EQUIP_CD"].ToString(), "3", taboo);
                        bool isDiff = !"201".Equals(rowEquipment["EQUIP_GROUP_CD"].ToString());
                        string prefix = GetPrefix(isTaboo, isDiff, isDel, false);
                        string strUnit = rowEquipment["UNIT"].ToString();
                        if (!string.IsNullOrEmpty(strUnit))
                        {
                            strUnit = SpecialDataFormat(strUnit);
                        }
                        else
                        {
                            strUnit = "null";
                        }
        
                        items.Add(new TreatCondItem("吸着カラム", isRst == true ? rowEquipment["EQUIP_NAME"].ToString() : null, 7, 6, strUpdaterName, strStaffName, "null", prefix, "(select equipment_cd from mst_equipment where facility_cd='" + CommonConfig.FacilityCd + "' and fn_equipment_cd='" + rowIndCond[0][strTrun].ToString() + "')", "null"));
                    }
                }
            }
        }



        private static void BuildFirstFilm(DataTable tbSysTreatCond, List<TreatCondItem> items, DataTable taboo, bool isRst, string strUpdaterName, string strStaffName
            , List<int> isDisable, string strTrun, DataRow[] rowIndCond, DateTime? dtTargetDate)
        {

            DataRow dr = tbSysTreatCond.Select("COND_CTL_NO='039'").FirstOrDefault();
            if (isDisableSet(dr, 7, isDisable))
            {
                items.Add(new TreatCondItem("1次膜", "未登録", 8, 7, "", "", "null", "null", "null", "null"));
            }
            else
            {

                if (rowIndCond[0][strTrun] == null)
                {
                    items.Add(new TreatCondItem("1次膜", "未登録", 8, 7, strUpdaterName, strStaffName, "null", "null", "null", "null"));
                }
                else
                {     // 医療材料マスタ情報取得

                    DataRow rowEquipment = Equipmentdt.AsEnumerable().Where(row => row.Field<string>("EQUIP_CD") == rowIndCond[0][strTrun].ToString() && row.Field<DateTime>("UP_DATE") <= dtTargetDate).OrderByDescending(crow => (DateTime)crow["UP_DATE"]).FirstOrDefault();
                    if (null == rowEquipment)
                    {
                        items.Add(new TreatCondItem("1次膜", "未登録", 8, 7, strUpdaterName, strStaffName, "null", "null", "null", "null"));
                    }
                    else
                    {
                        bool isDel = "0".Equals(rowEquipment["DISP_FLG"].ToString());
                        bool isTaboo = isTaBoo(rowEquipment["EQUIP_CD"].ToString(), "3", taboo);
                        bool isDiff = !"001".Equals(rowEquipment["EQUIP_GROUP_CD"].ToString()) && !"002".Equals(rowEquipment["EQUIP_GROUP_CD"].ToString());
                        string prefix = GetPrefix(isTaboo, isDiff, isDel, false);
                        string strUnit = rowEquipment["UNIT"].ToString();
                        if (!string.IsNullOrEmpty(strUnit))
                        {
                            strUnit = SpecialDataFormat(strUnit);
                        }
                        else
                        {
                            strUnit = "null";
                        }
                        items.Add(new TreatCondItem("1次膜", isRst == true ? rowEquipment["EQUIP_NAME"].ToString() : null, 8, 7, strUpdaterName, strStaffName, "null", prefix, "(select equipment_cd from mst_equipment where facility_cd='" + CommonConfig.FacilityCd + "' and fn_equipment_cd='" + rowIndCond[0][strTrun].ToString() + "')", "null"));
                    }
                }
            }

        }



        private static void BuildSecondFilm(DataTable tbSysTreatCond, List<TreatCondItem> items, DataTable taboo, bool isRst, string strUpdaterName, string strStaffName
            , List<int> isDisable, string strTrun, DataRow[] rowIndCond, DateTime? dtTargetDate)
        {


            DataRow dr = tbSysTreatCond.Select("COND_CTL_NO='040'").FirstOrDefault();
            if (isDisableSet(dr, 8, isDisable))
            {
                items.Add(new TreatCondItem("2次膜", "未登録", 9, 8, "", "", "null", "null", "null", "null"));
            }
            else
            {

                if (rowIndCond[0][strTrun] == null)
                {
                    items.Add(new TreatCondItem("2次膜", "未登録", 9, 8, strUpdaterName, strStaffName, "null", "null", "null", "null"));
                }
                else
                {     // 医療材料マスタ情報取得

                    DataRow rowEquipment = Equipmentdt.AsEnumerable().Where(row => row.Field<string>("EQUIP_CD") == rowIndCond[0][strTrun].ToString() && row.Field<DateTime>("UP_DATE") <= dtTargetDate).OrderByDescending(crow => (DateTime)crow["UP_DATE"]).FirstOrDefault();
                    if (null == rowEquipment)
                    {
                        items.Add(new TreatCondItem("2次膜", "未登録", 9, 8, strUpdaterName, strStaffName, "null", "null", "null", "null"));
                    }
                    else
                    {
                        bool isDel = "0".Equals(rowEquipment["DISP_FLG"].ToString());
                        bool isTaboo = isTaBoo(rowEquipment["EQUIP_CD"].ToString(), "3", taboo);
                        bool isDiff = !"001".Equals(rowEquipment["EQUIP_GROUP_CD"].ToString()) && !"002".Equals(rowEquipment["EQUIP_GROUP_CD"].ToString());
                        string prefix = GetPrefix(isTaboo, isDiff, isDel, false);
                        string strUnit = rowEquipment["UNIT"].ToString();
                        if (!string.IsNullOrEmpty(strUnit))
                        {
                            strUnit = SpecialDataFormat(strUnit);
                        }
                        else
                        {
                            strUnit = "null";
                        }
                        items.Add(new TreatCondItem("2次膜", isRst == true ? rowEquipment["EQUIP_NAME"].ToString() : null, 9, 8, strUpdaterName, strStaffName, "null", prefix, "(select equipment_cd from mst_equipment where facility_cd='" + CommonConfig.FacilityCd + "' and fn_equipment_cd='" + rowIndCond[0][strTrun].ToString() + "')", "null"));

                    }
                }
            }


        }
       
        
        private static void BuildVA(DBCtrl db, DataTable tbSysTreatCond, List<TreatCondItem> items, bool isRst, string strUpdaterName, string strStaffName
, List<int> isDisable, string strTrun, DataRow[] rowIndCond, DateTime? dtTargetDate)
        {

            DataRow drTreatCond = tbSysTreatCond.Select("COND_CTL_NO='003'").FirstOrDefault();
            if (!isDisableSet(drTreatCond, 2, isDisable))
            {
                if (string.IsNullOrEmpty(rowIndCond[0][strTrun].ToString()))
                {
                    items.Add(new TreatCondItem("VA", "未登録", 2, 2, strUpdaterName, strStaffName, "null", "null", "null", "null"));
                }
                else
                {
                    // VAマスタ情報取得
                    DataTable tbMstVA = SelectMstVA(db, dtTargetDate, rowIndCond[0][strTrun].ToString());
                    if (null == tbMstVA)
                    {
                        items.Add(new TreatCondItem("VA", "未登録", 2, 2, strUpdaterName, strStaffName, "null", "null", "null", "null"));
                    }
                    else
                    {
                        string prefix = "null";
                        if ("1".Equals(tbMstVA.Rows[0]["DEL_FLG"].ToString()))
                        {
                            prefix = GetPrefix(false, false, true, false);
                        }
                        items.Add(new TreatCondItem("VA", isRst == true ? tbMstVA.Rows[0]["VA_ACCESS_NAME"].ToString() : null, 2, 2, strUpdaterName, strStaffName, "null", prefix, "(select va_cd FROM mst_va WHERE facility_cd='" + CommonConfig.FacilityCd + "' AND fn_va_cd='" + rowIndCond[0][strTrun].ToString() + "')", "null"));
                    }
                }

            }
           

        }


        private static void BuildTW(DataTable tbSysTreatCond, List<TreatCondItem> items,  string strUpdaterName, string strStaffName
          , List<int> isDisable, string strTrun, DataRow[] rowIndCond,ref string sDW)
        {

            DataRow dr = tbSysTreatCond.Select("COND_CTL_NO='005'").FirstOrDefault();
            if (!isDisableSet(dr, 3, isDisable))
            {
                if (string.Equals(sDW, rowIndCond[0][strTrun].ToString()))
                {
                    items.Add(new TreatCondItem("目標体重", "DWと同じ", 4, 3, strUpdaterName, strStaffName, "null", "null", "null", "null"));
                }
                else if (string.IsNullOrEmpty(rowIndCond[0][strTrun].ToString()))
                {
                    items.Add(new TreatCondItem("目標体重", "未登録", 4, 3, strUpdaterName, strStaffName, "null", "null", "null", "null"));
                }
                else
                {
                    items.Add(new TreatCondItem("目標体重", Convert.ToDouble(rowIndCond[0][strTrun]).ToString("F2"), 4, 3, strUpdaterName, strStaffName, "kg", "null", "null", "null"));

                }
            }


        }

        private static void BuildDialyzer(DataTable tbSysTreatCond, List<TreatCondItem> items, DataTable taboo, bool isRst, string strUpdaterName, string strStaffName
            , List<int> isDisable, string strTrun, DataRow[] rowIndCond, DateTime? dtTargetDate)
        {


            DataRow dr = tbSysTreatCond.Select("COND_CTL_NO='008'").FirstOrDefault();
            if (!isDisableSet(dr, 5, isDisable))
            {
                if (string.IsNullOrEmpty(rowIndCond[0][strTrun].ToString()))
                {
                    items.Add(new TreatCondItem("ダイアライザ", "未登録", 6, 5, strUpdaterName, strStaffName, "null", "null", "null", "null"));
                }
                else
                {    // ダイアライザマスタ情報取得
                    DataRow rowMstDialyzer = MstDialyzerdt.AsEnumerable().Where(row => row.Field<string>("DIALYZER_CD") == rowIndCond[0][strTrun].ToString() && row.Field<DateTime>("UP_DATE") <= dtTargetDate).OrderByDescending(crow => (DateTime)crow["UP_DATE"]).FirstOrDefault();
                    if (null == rowMstDialyzer)
                    {
                        items.Add(new TreatCondItem("ダイアライザ", "未登録", 6, 5, strUpdaterName, strStaffName, "null", "null", "null", "null"));
                    }
                    else
                    {
                        bool isTaboo = isTaBoo(rowMstDialyzer["DIALYZER_CD"].ToString(), "4", taboo);
                        bool isDel = "0".Equals(rowMstDialyzer["DISP_FLG"].ToString());
                        string prefix = GetPrefix(isTaboo, false, isDel, false);
                        if (isRst)
                        {
                            items.Add(new TreatCondItem("ダイアライザ", "[" + SpecialDataFormat(rowMstDialyzer["MODEL_NUMBER"].ToString()) + "]", 6, 5, strUpdaterName, strStaffName, "本", prefix, "(select dialyzer_cd from mst_dialyzer where facility_cd='" + CommonConfig.FacilityCd + "' and fn_dialyzer_cd='" + rowIndCond[0][strTrun].ToString() + "')", "null"));

                        }
                        else
                        {
                            items.Add(new TreatCondItem("ダイアライザ", null, 6, 5, strUpdaterName, strStaffName, "本", prefix, "(select dialyzer_cd from mst_dialyzer where facility_cd='" + CommonConfig.FacilityCd + "' and fn_dialyzer_cd='" + rowIndCond[0][strTrun].ToString() + "')", "null"));

                        }
                    }
                }

            }


        }


        private static void BuildA(List<TreatCondItem> items, DataTable taboo, bool isRst, DateTime? dtTargetDate)
        {

            var A = itemAV.FirstOrDefault(a => a.Key == "A");
            if (A.Value1.Equals("未登録"))
            {
                items.Add(new TreatCondItem("穿刺針(A針)", "未登録", 10, 9, A.Value2, A.Value3, "null", "null", "null", "null"));
            }
            else
            {
                // 医療材料マスタ情報取得
                DataRow rowEquipment = Equipmentdt.AsEnumerable().Where(row => row.Field<string>("EQUIP_CD") == A.Value1 && row.Field<DateTime>("UP_DATE") <= dtTargetDate).OrderByDescending(crow => (DateTime)crow["UP_DATE"]).FirstOrDefault();
                if (null == rowEquipment)
                {
                    items.Add(new TreatCondItem("穿刺針(A針)", "未登録", 10, 9, A.Value2, A.Value3, "null", "null", "null", "null"));
                }
                else
                {
                    bool isDel = "0".Equals(rowEquipment["DISP_FLG"].ToString());
                    bool isTaboo = isTaBoo(rowEquipment["EQUIP_CD"].ToString(), "3", taboo);
                    bool isDiff = !"202".Equals(rowEquipment["EQUIP_GROUP_CD"].ToString());
                    string prefix = GetPrefix(isTaboo, isDiff, isDel, false);
                    string strUnit = rowEquipment["UNIT"].ToString();
                    if (!string.IsNullOrEmpty(strUnit))
                    {
                        strUnit = SpecialDataFormat(strUnit);
                    }
                    else
                    {
                        strUnit = "null";
                    }
                    items.Add(new TreatCondItem("穿刺針(A針)", isRst == true ? rowEquipment["EQUIP_NAME"].ToString() : null, 10, 9, A.Value2, A.Value3, strUnit, prefix, "(select equipment_cd from mst_equipment where facility_cd='" + CommonConfig.FacilityCd + "' and fn_equipment_cd='" + A.Value1 + "')", "null"));
                }
            }

        }

        private static void BuildV(List<TreatCondItem> items, DataTable taboo, bool isRst
            , DateTime? dtTargetDate)
        {

            var V = itemAV.FirstOrDefault(a => a.Key == "V");
            if (V.Value1.Equals("未登録"))
            {
                items.Add(new TreatCondItem("穿刺針(V針)", "未登録", 11, 10, V.Value2, V.Value3, "null", "null", "null", "null"));
            }
            else
            {     // 医療材料マスタ情報取得

                DataRow rowEquipment = Equipmentdt.AsEnumerable().Where(row => row.Field<string>("EQUIP_CD") == V.Value1 && row.Field<DateTime>("UP_DATE") <= dtTargetDate).OrderByDescending(crow => (DateTime)crow["UP_DATE"]).FirstOrDefault();
                if (null == rowEquipment)
                {
                    items.Add(new TreatCondItem("穿刺針(V針)", "未登録", 11, 10, V.Value2, V.Value3, "null", "null", "null", "null"));
                }
                else
                {
                    bool isDel = "0".Equals(rowEquipment["DISP_FLG"].ToString());
                    bool isTaboo = isTaBoo(rowEquipment["EQUIP_CD"].ToString(), "3", taboo);
                    bool isDiff = !"202".Equals(rowEquipment["EQUIP_GROUP_CD"].ToString());
                    string prefix = GetPrefix(isTaboo, isDiff, isDel, false);
                    string strUnit = rowEquipment["UNIT"].ToString();
                    if (!string.IsNullOrEmpty(strUnit))
                    {
                        strUnit = SpecialDataFormat(strUnit);
                    }
                    else
                    {
                        strUnit = "null";
                    }
                    items.Add(new TreatCondItem("穿刺針(V針)", isRst == true ? rowEquipment["EQUIP_NAME"].ToString() : null, 11, 10, V.Value2, V.Value3, strUnit, prefix, "(select equipment_cd from mst_equipment where facility_cd='" + CommonConfig.FacilityCd + "' and fn_equipment_cd='" + V.Value1 + "')", "null"));
                }
            }

        }



        private static void BuildSN(List<TreatCondItem> items, DataTable taboo, bool isRst
            , DateTime? dtTargetDate)
        {

            var sSN = itemAV.FirstOrDefault(a => a.Key == "SN");
            if (sSN.Value1.Equals("未登録"))
            {
                items.Add(new TreatCondItem("穿刺針(SN針)", "未登録", 12, 11, sSN.Value2, sSN.Value3, "null", "null", "null", "null"));
            }
            else
            {     // 医療材料マスタ情報取得

                DataRow rowEquipment = Equipmentdt.AsEnumerable().Where(row => row.Field<string>("EQUIP_CD") == sSN.Value1 && row.Field<DateTime>("UP_DATE") <= dtTargetDate).OrderByDescending(crow => (DateTime)crow["UP_DATE"]).FirstOrDefault();
                if (null == rowEquipment)
                {
                    items.Add(new TreatCondItem("穿刺針(SN針)", "未登録", 12, 11, sSN.Value2, sSN.Value3, "null", "null", "null", "null"));
                }
                else
                {
                    bool isDel = "0".Equals(rowEquipment["DISP_FLG"].ToString());
                    bool isTaboo = isTaBoo(rowEquipment["EQUIP_CD"].ToString(), "3", taboo);
                    bool isDiff = !"202".Equals(rowEquipment["EQUIP_GROUP_CD"].ToString());
                    string prefix = GetPrefix(isTaboo, isDiff, isDel, false);
                    string strUnit = rowEquipment["UNIT"].ToString();
                    if (!string.IsNullOrEmpty(strUnit))
                    {
                        strUnit = SpecialDataFormat(strUnit);
                    }
                    else
                    {
                        strUnit = "null";
                    }
                    items.Add(new TreatCondItem("穿刺針(SN針)", isRst == true ? rowEquipment["EQUIP_NAME"].ToString() : null, 12, 11, sSN.Value2, sSN.Value3, strUnit, prefix, "(select equipment_cd from mst_equipment where facility_cd='" + CommonConfig.FacilityCd + "' and fn_equipment_cd='SN" + sSN.Value1.Substring(2) + "')", "null"));
                }
            }

        }


        private static void BuildBOOLD(DataTable tbSysTreatCond, List<TreatCondItem> items, DataTable taboo, bool isRst
            , DateTime? dtTargetDate, List<int> isDisable)
        {
            DataRow dr = tbSysTreatCond.Select("COND_CTL_NO='040'").FirstOrDefault();
            var sBOOLD = itemAV.FirstOrDefault(a => a.Key == "BOOLD");
            if (sBOOLD.Value1.Equals("未登録"))
            {
                items.Add(new TreatCondItem("血液回路", "未登録", 14, 13, sBOOLD.Value2, sBOOLD.Value3, "null", "null", "null", "null"));
            }
            else
            {
                if (isDisableSet(dr, 8, isDisable))
                {
                    isDisable.Add(8);
                    items.Add(new TreatCondItem("血液回路", "未登録", 14, 13, "", "", "null", "null", "null", "null"));
                }
                else
                {
                    // 医療材料マスタ情報取得
                    DataRow rowEquipment = Equipmentdt.AsEnumerable().Where(row => row.Field<string>("EQUIP_CD") == sBOOLD.Value1 && row.Field<DateTime>("UP_DATE") <= dtTargetDate).OrderByDescending(crow => (DateTime)crow["UP_DATE"]).FirstOrDefault();
                    if (null == rowEquipment)
                    {
                        items.Add(new TreatCondItem("血液回路", "未登録", 14, 13, sBOOLD.Value2, sBOOLD.Value3, "null", "null", "null", "null"));
                    }
                    else
                    {
                        bool isDel = "0".Equals(rowEquipment["DISP_FLG"].ToString());
                        bool isTaboo = isTaBoo(rowEquipment["EQUIP_CD"].ToString(), "3", taboo);
                        bool isDiff = !"203".Equals(rowEquipment["EQUIP_GROUP_CD"].ToString());
                        string prefix = GetPrefix(isTaboo, isDiff, isDel, false);
                        string strUnit = rowEquipment["UNIT"].ToString();
                        if (!string.IsNullOrEmpty(strUnit))
                        {
                            strUnit = SpecialDataFormat(strUnit);
                        }
                        else
                        {
                            strUnit = "null";
                        }
                        items.Add(new TreatCondItem("血液回路", isRst == true ? rowEquipment["EQUIP_NAME"].ToString() : null, 14, 13, sBOOLD.Value2, sBOOLD.Value3, strUnit, prefix, "(select equipment_cd from mst_equipment where facility_cd='" + CommonConfig.FacilityCd + "' and fn_equipment_cd='" + sBOOLD.Value1 + "')", "null"));
                    }

                }

            }

        }

        private static void BuildDIALYSIS_LIQUID(DataTable tbSysTreatCond, List<TreatCondItem> items, DataTable taboo, bool isRst, string strUpdaterName, string strStaffName
            , List<int> isDisable, string strTrun, DataRow[] rowIndCond, DateTime? dtTargetDate ,ref string t_unitind )
        {


            DataRow dr = tbSysTreatCond.Select("COND_CTL_NO='018'").FirstOrDefault();
            if (isDisableSet(dr, 15, isDisable))
            {
                items.Add(new TreatCondItem("透析液", "未登録", 16, 15, "", "", "null", "null", "null", "null"));
            }
            else
            {

                if (string.IsNullOrEmpty(rowIndCond[0][strTrun].ToString()))
                {
                    items.Add(new TreatCondItem("透析液", "未登録", 16, 15, strUpdaterName, strStaffName, "null", "null", "null", "null"));
                }
                else
                {
                    string strAntiLiquidValue = rowIndCond[0][strTrun] as string;
                    // セット薬剤フラグ
                    string strAntiLiquidSetMediFlg = strAntiLiquidValue.Substring(0, 1);
                    // 薬剤コード
                    string strAntiLiquidCd = strAntiLiquidValue.Substring(1);

                    string strMediName;
                    string strUnit;
                    string strUnitind;
                    bool isTaboo;
                    bool isDel;
                    bool isDelItem;
                    bool isDiff;

                    // 薬剤マスタ(セット薬剤名称マスタ)から、薬剤名・単位情報の取得

                    bool bMedi = getMediInfo(strAntiLiquidCd, strAntiLiquidSetMediFlg, taboo, "302", dtTargetDate, out isTaboo, out isDel, out isDiff, out isDelItem, out strMediName, out strUnit, out strUnitind);

                    string prefix = GetPrefix(isTaboo, isDiff, isDel, isDelItem);
                    string t_unit;

                    if (!string.IsNullOrEmpty(strUnit))
                    {
                        t_unit = SpecialDataFormat(strUnit);
                    }
                    else
                    {
                        t_unit = "null";
                    }

                    if (!string.IsNullOrEmpty(strUnitind))
                    {
                        t_unitind = SpecialDataFormat(strUnitind);
                    }
                    else
                    {
                        t_unitind = "null";
                    }

                    if (string.IsNullOrEmpty(strMediName))
                    {
                        strMediName = "";
                    }
                    if (strAntiLiquidSetMediFlg.Equals("1"))
                    {
                        strAntiLiquidCd = "TS" + strAntiLiquidCd.Substring(2);
                    }
                    if (isRst == false)
                    {
                        strMediName = null;
                    }

                    items.Add(new TreatCondItem("透析液", bMedi == false ? "未登録" : strMediName, 16, 15, strUpdaterName, strStaffName, t_unit, prefix, getMedCd("0", strAntiLiquidCd), "1"));
                }
            }



        }

        private static void BuildREP_LIQUID(DataTable tbSysTreatCond, List<TreatCondItem> items, DataTable taboo, bool isRst, string strUpdaterName, string strStaffName
            , List<int> isDisable, string strTrun, DataRow[] rowIndCond, DateTime? dtTargetDate,ref string h_unitind)
        {

            DataRow dr = tbSysTreatCond.Select("COND_CTL_NO='022'").FirstOrDefault();
            if (isDisableSet(dr, 19, isDisable))
            {
                items.Add(new TreatCondItem("補液", "未登録", 20, 19, "", "", "null", "null", "null", "null"));

            }
            else
            {
                if (rowIndCond[0][strTrun] as string == null)
                {
                    items.Add(new TreatCondItem("補液", "未登録", 20, 19, strUpdaterName, strStaffName, "null", "null", "null", "null"));
                }
                else
                {

                    string strAntiLiquidValue = rowIndCond[0][strTrun] as string;
                    // セット薬剤フラグ
                    string strAntiLiquidSetMediFlg = strAntiLiquidValue.Substring(0, 1);
                    // 薬剤コード
                    string strAntiLiquidCd = strAntiLiquidValue.Substring(1);

                    // 薬剤マスタ(セット薬剤名称マスタ)から、薬剤名・単位情報の取得

                    string strMediName;
                    string strUnit;
                    string strUnitind;
                    bool isTaboo;
                    bool isDel;
                    bool isDelItem;
                    bool isDiff;
                    string h_unit;

                    // 薬剤マスタ(セット薬剤名称マスタ)から、薬剤名・単位情報の取得

                    bool bMedi = getMediInfo(strAntiLiquidCd, strAntiLiquidSetMediFlg, taboo, "303", dtTargetDate, out isTaboo, out isDel, out isDiff, out isDelItem, out strMediName, out strUnit, out strUnitind);

                    string prefix = GetPrefix(isTaboo, isDiff, isDel, isDelItem);

                    if (!string.IsNullOrEmpty(strUnit))
                    {
                        h_unit = SpecialDataFormat(strUnit);
                    }
                    else
                    {
                        h_unit = "null";
                    }

                    if (!string.IsNullOrEmpty(strUnitind))
                    {
                        h_unitind = SpecialDataFormat(strUnitind);
                    }
                    else
                    {
                        h_unitind = "null";
                    }

                    if (string.IsNullOrEmpty(strMediName))
                    {
                        strMediName = "";
                    }
                    if (strAntiLiquidSetMediFlg.Equals("1"))
                    {
                        strAntiLiquidCd = "TS" + strAntiLiquidCd.Substring(2);
                    }
                    if (isRst == false)
                    {
                        strMediName = null;
                    }
                    items.Add(new TreatCondItem("補液", bMedi == false ? "未登録" : strMediName, 20, 19, strUpdaterName, strStaffName, h_unit, prefix, getMedCd("0", strAntiLiquidCd), "1"));
                }

            }

        }

        private static void BuildANTI_LIQUID(DataTable tbSysTreatCond, List<TreatCondItem> items, DataTable taboo, bool isRst, string strUpdaterName, string strStaffName
            , List<int> isDisable, string strTrun, DataRow[] rowIndCond, DateTime? dtTargetDate,ref string k_unit)
        {

            DataRow dr = tbSysTreatCond.Select("COND_CTL_NO='011'").FirstOrDefault();
            if (isDisableSet(dr, 25, isDisable))
            {
                items.Add(new TreatCondItem("抗凝固剤", "未登録", 26, 25, "", "", "null", "null", "null", "null"));
            }
            else
            {
                // 値(セット薬剤フラグ＋薬剤コード)を取得
                string strAntiLiquidValue = rowIndCond[0][strTrun] as string;
                if (true == string.IsNullOrEmpty(strAntiLiquidValue))
                {
                    items.Add(new TreatCondItem("抗凝固剤", "未登録", 26, 25, strUpdaterName, strStaffName, "null", "null", "null", "null"));
                }
                else
                {

                    // セット薬剤フラグ
                    string strAntiLiquidSetMediFlg = strAntiLiquidValue.Substring(0, 1);
                    // 薬剤コード
                    string strAntiLiquidCd = strAntiLiquidValue.Substring(1);

                    string strMediName;
                    string strUnit;
                    string strUnitind;
                    bool isTaboo;
                    bool isDel;
                    bool isDelItem;
                    bool isDiff;

                    // 薬剤マスタ(セット薬剤名称マスタ)から、薬剤名・単位情報の取得

                    bool bMedi = getMediInfo(strAntiLiquidCd, strAntiLiquidSetMediFlg, taboo, "301", dtTargetDate, out isTaboo, out isDel, out isDiff, out isDelItem, out strMediName, out strUnit, out strUnitind);

                    string prefix = GetPrefix(isTaboo, isDiff, isDel, isDelItem);

                    if (!string.IsNullOrEmpty(strUnit))
                    {
                        k_unit = SpecialDataFormat(strUnit);

                    }
                    else
                    {
                        k_unit = "null";

                    }

                    if (string.IsNullOrEmpty(strMediName))
                    {
                        strMediName = "";
                    }
                    if (isRst == false)
                    {
                        strMediName = null;
                    }

                    items.Add(new TreatCondItem("抗凝固剤", bMedi == false ? "未登録" : strMediName, 26, 25, strUpdaterName, strStaffName, k_unit, prefix, getMedCd(strAntiLiquidSetMediFlg, strAntiLiquidCd), getMedType(strAntiLiquidSetMediFlg)));

                }
            }


        }


        private static void BuildAddDisableItem(
        DataTable tbSysTreatCond, string condCtlNo,
        List<int> isDisable,
        List<TreatCondItem> items,
        string itemName,
        int itemNo,
        int parentNo, DataRow[] rowIndCond, string strTrun, string strUpdaterName, string strStaffName, string unit,int type)
        {
            if (AddDisableItem(tbSysTreatCond, condCtlNo, isDisable, items, itemName, itemNo, parentNo))
            {
                if(type==0)
                   items.Add(new TreatCondItem(itemName, rowIndCond[0][strTrun] == null ? "未登録" : rowIndCond[0][strTrun].ToString(), itemNo, parentNo, strUpdaterName, strStaffName, unit, "null", "null", "null"));

                if(type == 2)
                    items.Add(new TreatCondItem(itemName, rowIndCond[0][strTrun] == null ? "未登録" : Convert.ToDouble(rowIndCond[0][strTrun]).ToString("F2"), itemNo, parentNo, strUpdaterName, strStaffName, unit, "null", "null", "null"));

                if (type == 1)
                    items.Add(new TreatCondItem(itemName, rowIndCond[0][strTrun] == null ? "未登録" : Convert.ToDouble(rowIndCond[0][strTrun]).ToString("F1"), itemNo, parentNo, strUpdaterName, strStaffName, unit, "null", "null", "null"));

                if (type == 4)
                {
                    items.Add(new TreatCondItem(itemName, rowIndCond[0][strTrun] == null ? "未登録" : rowIndCond[0][strTrun].ToString().Equals("1") ? "入" : "切", itemNo, parentNo, strUpdaterName, strStaffName, unit, "null", "null", "null"));
                }

                if (type == 5)
                {
                    items.Add(new TreatCondItem(itemName, rowIndCond[0][strTrun] == null ? "未登録" : rowIndCond[0][strTrun].ToString().Equals("1") ? "使用する" : "使用しない", itemNo, parentNo, strUpdaterName, strStaffName, "null", "null", "null", "null"));
                }

                if (type == 6)
                {
                    items.Add(new TreatCondItem("IPスタート", rowIndCond[0][strTrun] == null ? "未登録" : rowIndCond[0][strTrun].ToString().Equals("1") ? "自動" : "手動", 31, 30, strUpdaterName, strStaffName, "null", "null", "null", "null"));
                }
            
            }

        }


        private static bool  AddDisableItem(
        DataTable table, string condCtlNo,
        List<int> isDisable,
        List<TreatCondItem> items,
        string itemName,
        int itemNo,
        int parentNo)
        {
            DataRow dr= table
                .Select($"COND_CTL_NO='{condCtlNo}'")
                .FirstOrDefault();

            if (dr["USE_FLG"].ToString() == "0")
            {
                isDisable.Add(parentNo);

                items.Add(new TreatCondItem(itemName, "未登録", itemNo, parentNo, "", "", "null", "null", "null", "null"));
                return false;
            }
            return true;
        }

    }
}
