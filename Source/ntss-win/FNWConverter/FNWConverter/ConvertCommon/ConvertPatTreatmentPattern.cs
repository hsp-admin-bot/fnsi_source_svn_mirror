using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.IO;
using Fnw.Common.Ind;
using ConvertCommon.Common;
using Fnw.IOControl.DB;
using Fnw.Common.Cmn;
using System.Text.RegularExpressions;

namespace ConvertCommon
{
    /// <summary>
    /// コンバート処理クラス(pat_treatment_pattern)
    /// </summary>
    /// <remarks>
    /// 
    /// </remarks>
    sealed public class ConvertPatTreatmentPattern : ConvertBase
    {
        private readonly RelationCacheBase _relationCache;
        private static readonly Regex ConditionRegex =
              new Regex(@"(\s)([A-Za-z\._]*\s*=\s*'\{SERIES_CD\}')", RegexOptions.Compiled);
        /// <summary>透析条件項目番号変換リスト</summary>
        private static Dictionary<string, string> CtlNoConvList = new Dictionary<string, string>()
        {
            { "002", "1" },		// 治療時間
            { "003", "2" },		// VA
            { "005", "3" },		// 目標体重
            { "007", "4" },		// 除水量制限
            { "008", "5" },		// ダイアライザ
            { "009", "6" },		// 吸着カラム
            { "010", "14" },	// 血流量
            { "011", "25" },	// 抗凝固剤
            { "012", "26" },	// 抗凝固剤ワンショット量
            { "013", "27" },	// 抗凝固剤持続速度
            { "014", "28" },	// IP使用選択
            { "015", "29" },	// IPワンショット量
            { "016", "31" },	// IP速度
            { "017", "32" },	// 透析液
            { "018", "15" },	// 透析液流量
            { "019", "16" },	// 透析液量
            { "020", "17" },	// 透析液温度
            { "021", "18" },	// 補液
            { "022", "19" },	// 補液
            { "023", "20" },	// 補液量
            { "024", "21" },	// 補液選択
            { "025", "23" },	// 補液温度
            { "029", "12" },	// シングルニードル使用
            { "030", "22" },	// 補液使用数
            { "031", "30" },	// IPスタート
            { "032", "34" },	// 自動ワンショット
            { "033", "35" },	// IP電源自動切り
            { "034", "36" },	// IP電源自動切り時間
            { "035", "37" },	// IP電源OKモニタ切り
            { "036", "38" },	// IP電源OKモニタ切り時
            { "037", "33" },	// IP速度最大値
            { "038", "24" },	// 補液速度
            { "039", "7" },		// 1次膜間
            { "040", "8" },		// 2次膜
            { "9", "9" },		// 穿刺針(A針)
            { "10", "10" },		// 穿刺針(V針)
            { "11", "11" },		// 穿刺針(SN)
            { "13", "13" },		// 血液回路
        };

        /// <summary>透析条件不足情報追加リスト</summary>
        private static List<string> AddCtlNoList = new List<string>()
        {
            "9",		// 穿刺針(A針)
            "10",		// 穿刺針(V針)
            "11",		// 穿刺針(SN)
            "13",		// 血液回路
        };

        private struct IndInfoColumn
        {
            public string name;
            public string value;
        }

        public override int FnwDataRowCount()
        {
            // mod 10378-24-4 PatTreatmentPattern再構築対応 zkm start
            int dataCount = 0;
            foreach (DataTable dt in mapFnwDataPatTreatmentPattern.Values)
            {
                dataCount += dt.Rows.Count;
            }
            return dataCount;
            // mod 10378-24-4 PatTreatmentPattern再構築対応 zkm end
        }

        /// <summary>
        /// コンストラクタ
        /// </summary>
        public ConvertPatTreatmentPattern() {

            _relationCache = new RelationCacheBase(
                        () => "pat_treatment_pattern"
                    );
        }

        // add 10378-24-4 PatTreatmentPattern再構築対応 zkm start
        /// <summary>
        /// 処理基準日を表す構造体
        /// </summary>
        struct DealDateSpan
        {
            public DateTime startDate;
            public DateTime endDate;
        }

        // 処理基準日算出（指示自動延長日以降の最初の月曜日）
        private DealDateSpan GetDealDate() {

            // 処理基準日算出（指示自動延長日以降の最初の月曜日）
            DateTime currentDate = DateTime.Now;
            //mod #12229 start
            DateTime lastMonthDayNextYear = new DateTime(currentDate.Year + 1, currentDate.Month,
            DateTime.DaysInMonth(currentDate.Year + 1, currentDate.Month));
            string firstMonday = GetNextMonday(lastMonthDayNextYear.AddDays(1)).ToString("yyyy/MM/dd");
            //mod #12229 end
            DateTime startDate = DateTime.Parse(firstMonday);
            DateTime endDate = startDate.AddDays(27);
            return new DealDateSpan() { startDate = startDate, endDate = endDate };
        }

        private static DateTime GetNextMonday(DateTime startDate)
        {
            int daysUntilMonday = ((int)DayOfWeek.Monday - (int)startDate.DayOfWeek + 7) % 7;
            return startDate.AddDays(daysUntilMonday == 0 ? 7 : daysUntilMonday);
        }
        // add 10378-24-4 PatTreatmentPattern再構築対応 zkm end

        public override bool SetFnwData(List<string> listSelectedPatId, DateTime startDate, DateTime endDate, bool isSync)
        {
            // 処理なし（FNWデータ取得・登録用データ作成はConvertにて実施）   
            WriteTraceLog("===== コンバート元データ取得処理開始 =====");

            // add 10378-24-4 PatTreatmentPattern再構築対応 zkm start
            DealDateSpan dealDate = GetDealDate();
            startDate = dealDate.startDate;
            endDate = dealDate.endDate;

            // 透析スケジュール、予定指示から透析予定取得
            var isSuccess = SetDialysisData(ConvertControl.FNW_TABLE_IND_DIALYSIS_PLAN,
                listSelectedPatId,
                startDate,
                endDate);
            if (isSuccess == false)
            {
                return false;
            }
            var dtSch = mapFnwDataPatTreatmentPattern[ConvertControl.FNW_TABLE_IND_DIALYSIS_PLAN];
            if (dtSch.Rows.Count > 0)
            {
                // 予定がある場合はPATID,PLURALを全て取得する
                List<string> patIdList = dtSch.Select().Select(sch => sch["PATID"].ToString()).Distinct().ToList();

                // 治療条件展開取得
                isSuccess = SetDialysisData(ConvertControl.FNW_TABLE_IND_DIALYSIS_COND, patIdList, startDate, endDate);
                if (isSuccess == false)
                {
                    return false;
                }
                // 投薬指示展開取得
                isSuccess = SetDialysisData(ConvertControl.FNW_TABLE_IND_DIALYSIS_MEDI, patIdList, startDate, endDate);
                if (isSuccess == false)
                {
                    return false;
                }

                // 材料指示展開取得
                isSuccess = SetDialysisData(ConvertControl.FNW_TABLE_IND_DIALYSIS_EQUIP, patIdList, startDate, endDate);
                if (isSuccess == false)
                {
                    return false;
                }

                // 指示簿指示展開取得
                isSuccess = SetDialysisData(ConvertControl.FNW_TABLE_IND_DIALYSIS_ADD, patIdList, startDate, endDate);
                if (isSuccess == false)
                {
                    return false;
                }

                // 患者除水補正情報取得
                isSuccess = SetDialysisData(ConvertControl.FNW_TABLE_PAT_REVISE_OFFWATER, patIdList, null, null);
                if (isSuccess == false)
                {
                    return false;
                }

                // 患者風袋補正情報取得
                isSuccess = SetDialysisData(ConvertControl.FNW_TABLE_PAT_REVISE_TARE, patIdList, null, null);
                if (isSuccess == false)
                {
                    return false;
                }

                // 患者装置設定情報取得
                isSuccess = SetDialysisData(ConvertControl.FNW_TABLE_PAT_DEVICE_SET, patIdList, null, null);
                if (isSuccess == false)
                {
                    return false;
                }
            }
            // add 10378-24-4 PatTreatmentPattern再構築対応 zkm end

            WriteTraceLog("===== コンバート元データ取得処理完了 =====");
            return true;
        }

        /// <summary>
        /// 紐付け情報取得
        /// </summary>
        /// <param name="fnwTableName">FNWテーブル名</param>
        /// <param name="fnwColName">FNWカラム名</param>
        /// <param name="ntssColNo">NTSSカラム名</param>
        /// <returns>紐付け情報</returns>
        public override DataRow[] GetRelationArray(string fnwTableName, string fnwColName, string ntssColNo)
        {
            return _relationCache.GetRelationArray(fnwTableName, fnwColName);
        }

        // mod 10378-24-4 PatTreatmentPattern再構築対応 zkm start
        /// <summary>
        /// 紐付け情報取得(存在確認用に1件のみ返却)
        /// </summary>
        /// <param name="fnwTableName">FNWテーブル名</param>
        /// <param name="fnwColName">FNWカラム名</param>
        /// <param name="ntssColumnName">NTSSカラム名</param>
        /// <returns>紐付け情報(1件のみ)</returns>
        public override DataRow GetRelation(string fnwTableName, string fnwColName, string ntssColumnName)
        {
            var relation = _relationCache.GetRelationArray(fnwTableName, fnwColName);
            if (relation.Length == 1)
            {
                return relation[0];
            }
            else if (relation.Length > 1)
            {
                // FNWのカラム１に対して紐付け先のNTSSのカラムが２以上ある場合に対応していないため、
                // エラーにしない。
                return relation[0];
            }
            else
            {
                return null;
            }
        }
        // mod 10378-24-4 PatTreatmentPattern再構築対応 zkm end

        // add 10378-24-4 PatTreatmentPattern再構築対応 zkm start
        /// <summary>
        /// SearchMapFnwDataOrdNewをテーブル名とキーで検索する
        /// </summary>
        /// <param name="tableName"></param>
        /// <param name="key"></param>
        /// <returns>
        /// ヒットした件数分のDataRowの配列を返す
        /// （既存の判定処理に影響が及ばないようにnullは返さない）
        /// </returns>
        private DataRow[] SearchMapFnwDataOrdNew(string tableName, string key)
        {
            DataRow[] records = new DataRow[] { };
            if (mapFnwDataOrdNew[tableName].ContainsKey(key))
            {
                records = mapFnwDataOrdNew[tableName][key];
            }

            return records;
        }
        // add 10378-24-4 PatTreatmentPattern再構築対応 zkm end

        /// <summary>
        /// データコンバート処理
        /// </summary>
        /// <param name="mapConvertData">コンバートデータ(戻り値)</param>
        /// <param name="listErrorPat">失敗した患者ID</param>
        /// <returns>成功：true、失敗：false</returns>
        public override bool Convert(Dictionary<string, List<NtssRecord>> mapConvertData, List<string> listErrorPat)
        {
            WriteTraceLog("===== コンバート処理開始 =====");
            // データテーブルをキーとDataRowの配列のディクショナリに変換する
            mapFnwDataOrdNew = new Dictionary<string, Dictionary<string, DataRow[]>>();
            foreach (KeyValuePair<string, string> kvp in mapTableNameToKey)
            {
                string key = mapTableNameToKey[kvp.Key].ToString();
                if (mapFnwDataPatTreatmentPattern.ContainsKey(kvp.Key))
                {
                    mapFnwDataOrdNew.Add(kvp.Key, mapFnwDataPatTreatmentPattern[kvp.Key].AsEnumerable()
                            .ToLookup(dr => dr[key].ToString())
                            .ToDictionary(
                                drGroup => drGroup.Key,
                                drGroup => drGroup.ToArray()
                            ));
                }
            }

            var groupDtsch = mapFnwDataPatTreatmentPattern[ConvertControl.FNW_TABLE_IND_DIALYSIS_PLAN].AsEnumerable().GroupBy(row => new { PATID = row["PATID"] });

            foreach (var group in groupDtsch) {

                // 月曜日～日曜日の指示格納用ディクショナリ
                SortedDictionary<int, NtssRecord> indOneWeek = new SortedDictionary<int, NtssRecord>();
                string patid = group.Key.PATID.ToString();

                // 月曜日～日曜日の指示格納用リスト
                Dictionary<int, List<NtssColumn>> dailyMedi = new Dictionary<int, List<NtssColumn>>();
                foreach (DataRow schRecord in group)
                {
                    if (listErrorPat.Contains(patid))
                    {
                        // エラーがあった患者のそれ以降のレコードは処理しない
                        continue;
                    }
                    var indId = schRecord["IND_ID"].ToString();
                    var planVal = schRecord["VALUE"].ToString();
                    DateTime dialDate = (DateTime)GetFormatedDate(schRecord["DIALYSIS_DATE"].ToString());

                    var ntssColumns = new List<NtssColumn>();
                    // JSONデータ作成用連想配列
                    var mapJson = new Dictionary<string, List<JsonElement>>();
                    // 失敗フラグ
                    var isCriticalError = false;
                    var isConvertError = false;

                    //------------------------------------
                    // 透析予定
                    //------------------------------------
                    ConvertRecord(schRecord, ntssColumns, mapJson, ref isConvertError);
                    if (isCriticalError)
                    {
                        return false;
                    }
                    if (isConvertError)
                    {
                        listErrorPat.Add(patid);
                        // 次の予定レコードへ
                        continue;
                    }

                    //------------------------------------
                    // 条件指示
                    //------------------------------------
                    List<IndicationInfo> listCondInfo = new List<IndicationInfo>();
                    DataRow[] rows = SearchMapFnwDataOrdNew(ConvertControl.FNW_TABLE_IND_DIALYSIS_COND, indId);
                    ConvertCond(rows, planVal, ref listCondInfo);
                    ConvertIndication(ntssColumns, "ind_cond_info", listCondInfo, ref isCriticalError, ref isConvertError);
                    if (isCriticalError)
                    {
                        return false;
                    }
                    if (isConvertError)
                    {
                        listErrorPat.Add(patid);
                        // 次の予定レコードへ
                        continue;
                    }

                    //------------------------------------
                    // スケジュール情報
                    //------------------------------------
                    List<IndicationInfo> listSchInfo = new List<IndicationInfo>();
                    IndicationPlanInfo info = new IndicationPlanInfo();
                    DataRow[] schRows = SearchMapFnwDataOrdNew(ConvertControl.FNW_TABLE_IND_DIALYSIS_PLAN, indId);
                    if (schRows.Length > 0)
                    {
                        info.decBedNo = FnwNumber.ToDecimal(schRows[0]["BED_NO"]);
                        info.strIndicatorCd = schRows[0]["INDICATOR_CD"].ToString();
                        info.strUpdaterCd = schRows[0]["UPDATE_STAFF_CD"].ToString();
                        
                    }
                    if (listCondInfo.Count > 0)
                    {
                        // 指示：治療開始時刻
                        IndicationInfo startTimeInfo = listCondInfo.Where(col => "001".Equals(col.strCtlNo)).FirstOrDefault();
                        if (startTimeInfo != null)
                        {
                            if (!string.IsNullOrEmpty(startTimeInfo.strCd) && startTimeInfo.strCd.Length >= 4)
                            {
                                info.strIndStartDate = startTimeInfo.strCd.Substring(0, 4);
                            }
                            else
                            {
                                info.strIndStartDate = startTimeInfo.strCd;
                            }
                        }
                    }
                    listSchInfo.Add(info);
                    ConvertIndication(ntssColumns, "ind_sch_info", listSchInfo, ref isCriticalError, ref isConvertError);
                    if (isCriticalError)
                    {
                        return false;
                    }
                    if (isConvertError)
                    {
                        listErrorPat.Add(patid);
                        // 次の予定レコードへ
                        continue;
                    }

                    //------------------------------------
                    // 投薬指示
                    //------------------------------------
                    List<IndicationInfo> listMediInfo = new List<IndicationInfo>();
                    DataRow[] mediRows = SearchMapFnwDataOrdNew(ConvertControl.FNW_TABLE_IND_DIALYSIS_MEDI, indId);
                    ConvertMedi(mediRows, dialDate, planVal, ref listMediInfo);
                    ConvertIndication(ntssColumns, "ind_medi_info", listMediInfo, ref isCriticalError, ref isConvertError);
                    if (isCriticalError)
                    {
                        return false;
                    }
                    if (isConvertError)
                    {
                        listErrorPat.Add(patid);
                        // 次の予定レコードへ
                        continue;
                    }

                    //------------------------------------
                    // 材料指示
                    //------------------------------------
                    List<IndicationInfo> listEquipInfo = new List<IndicationInfo>();
                    DataRow[] equipRows = SearchMapFnwDataOrdNew(ConvertControl.FNW_TABLE_IND_DIALYSIS_EQUIP, indId);
                    ConvertEquip(equipRows, dialDate, planVal, ref listEquipInfo);
                    ConvertIndication(ntssColumns, "ind_equip_info", listEquipInfo, ref isCriticalError, ref isConvertError);
                    if (isCriticalError)
                    {
                        return false;
                    }
                    if (isConvertError)
                    {
                        listErrorPat.Add(patid);
                        // 次の予定レコードへ
                        continue;
                    }

                    //------------------------------------
                    // 指示簿指示
                    //------------------------------------
                    List<IndicationInfo> listIndCommentInfo = new List<IndicationInfo>();
                    DataRow[] indCommentRows = SearchMapFnwDataOrdNew(ConvertControl.FNW_TABLE_IND_DIALYSIS_ADD, indId);
                    ConvertAdd(indCommentRows, dialDate, planVal, ref listIndCommentInfo);
                    ConvertIndication(ntssColumns, "ind_ind_comment_info", listIndCommentInfo, ref isCriticalError, ref isConvertError);
                    if (isCriticalError)
                    {
                        return false;
                    }
                    if (isConvertError)
                    {
                        listErrorPat.Add(patid);
                        // 次の予定レコードへ
                        continue;
                    }

                    // 透析条件医材項目セット（指示データ）
                    if (false == setDialysisCondFromEquip(ntssColumns, "ind_equip_info", "ind_cond_info"))
                    {
                        return false;
                    }

                    // 指示：除水補正を追加
                    DataRow[] indOffWaterRecords = SearchMapFnwDataOrdNew(ConvertControl.FNW_TABLE_PAT_REVISE_OFFWATER, patid);
                    var offWaterRows = indOffWaterRecords.ToList().Where(row => row.Field<decimal>("DAY_OF_WEEK") == (decimal)dialDate.DayOfWeek).ToArray();
                    var defaultOffWaterRows = indOffWaterRecords.ToList().Where(row => row.Field<decimal>("DAY_OF_WEEK") == -1).ToArray();
                    if (offWaterRows.Length > 0
                        && (DateTime)GetFormatedDate(offWaterRows[0]["UP_DATE"].ToString()) > (DateTime)GetFormatedDate(defaultOffWaterRows[0]["UP_DATE"].ToString()))
                    {
                        ConvertJsonArrayData(offWaterRows, "ind_off_water_info", ntssColumns, ref isCriticalError, ref isConvertError);
                    }
                    else
                    {
                        ConvertJsonArrayData(defaultOffWaterRows, "ind_off_water_info", ntssColumns, ref isCriticalError, ref isConvertError);
                    }
                    if (isCriticalError)
                    {
                        return false;
                    }
                    if (isConvertError)
                    {
                        listErrorPat.Add(patid);
                        // 次の予定レコードへ
                        continue;
                    }

                    // 指示：風袋補正を追加
                    DataRow[] indTareRecords = SearchMapFnwDataOrdNew(ConvertControl.FNW_TABLE_PAT_REVISE_TARE, patid);
                    var tareRows = indTareRecords.ToList().Where(row => row.Field<decimal>("DAY_OF_WEEK") == (decimal)dialDate.DayOfWeek).ToArray();
                    var defaultTareRows = indTareRecords.ToList().Where(row => row.Field<decimal>("DAY_OF_WEEK") == -1).ToArray();
                    if (tareRows.Length > 0
                        && (DateTime)GetFormatedDate(tareRows[0]["UP_DATE"].ToString()) > (DateTime)GetFormatedDate(defaultTareRows[0]["UP_DATE"].ToString()))
                    {
                        ConvertJsonArrayData(tareRows, "ind_tare_info", ntssColumns, ref isCriticalError, ref isConvertError);
                    }
                    else
                    {
                        ConvertJsonArrayData(defaultTareRows, "ind_tare_info", ntssColumns, ref isCriticalError, ref isConvertError);
                    }
                    if (isCriticalError)
                    {
                        return false;
                    }
                    if (isConvertError)
                    {
                        listErrorPat.Add(patid);
                        // 次の予定レコードへ
                        continue;
                    }

                    //------------------------------------
                    // 指示装置設定
                    // 過去指示および、透析日が当日かつ実績がある指示には設定しない
                    //------------------------------------
                    DataRow[] patDeviceSetRows = SearchMapFnwDataOrdNew(ConvertControl.FNW_TABLE_PAT_DEVICE_SET, patid);
                    // add #9686 指示コンバートで終了日ありにも関わらずそれ以降も延長されている zkm start
                    if (patDeviceSetRows.Length < 1)
                    {
                        StringBuilder sb = new StringBuilder();
                        sb.Append(@"SELECT DISTINCT '");
                        sb.Append(indId);
                        sb.Append("' ind_id, '");
                        sb.Append(patid);
                        sb.Append("' patid, '");
                        sb.Append(patid);
                        sb.Append(@"' dialysis_date , day_of_week,
                        set_data
                    FROM
                        v_pat_device_set
                    WHERE
                        patid = '");
                        sb.Append(patid);
                        sb.Append(@"' 
                        AND day_of_week = (TO_CHAR( TO_DATE('");
                        sb.Append(dialDate.ToString("yyyyMMdd"));
                        sb.Append(@"' ), 'D') - 1)");
                        DataTable deviceSetInfo = db.SelectTable(sb.ToString());
                        if ((null != deviceSetInfo) && (0 != deviceSetInfo.Rows.Count))
                        {
                            patDeviceSetRows = deviceSetInfo.Select();
                        }

                    }
                    var deviceSetRows = patDeviceSetRows.ToList().Where(row => row.Field<decimal>("DAY_OF_WEEK") == (decimal)dialDate.DayOfWeek).ToArray();
                    if (deviceSetRows.Length < 1)
                    {

                        deviceSetRows = patDeviceSetRows.ToList().Where(row => row.Field<decimal>("DAY_OF_WEEK") == -1).ToArray();

                    }
                    // add #9686 指示コンバートで終了日ありにも関わらずそれ以降も延長されている zkm end
                    ConvertJsonArrayDeviceSetInfoData(deviceSetRows, "ind_device_set_info", ntssColumns, ref isCriticalError, ref isConvertError);
                    if (isCriticalError)
                    {
                        return false;
                    }
                    if (isConvertError)
                    {
                        listErrorPat.Add(patid);
                        // 次の予定レコードへ
                        continue;
                    }

                    // カラム追加：管理番号
                    ntssColumns.Insert(1, CreateNtssColumn("ctl_no", NTSS_DATA_TYPE_CHARACTER_VARYING, "", true));

                    // カラム追加：施設コード
                    ntssColumns.Insert(2, CreateNtssColumn("facility_cd", NTSS_DATA_TYPE_CHARACTER_VARYING, this.facilityCd, true));

                    // 治療曜日
                    int treatWeek = ((int)dialDate.DayOfWeek);
                    if (treatWeek == 0) treatWeek = 7; // 日曜日のみ変換(「0」 ⇒ 「7」)
                    if (!indOneWeek.Keys.Contains(treatWeek))
                    {
                        indOneWeek.Add(treatWeek, new NtssRecord() { columns = ntssColumns });
                    }

                    // 投薬指示
                    var NtssColMedi = ntssColumns.Where(col => col.name.Equals("ind_medi_info")).FirstOrDefault();
                    if (NtssColMedi != null && NtssColMedi.jsonArray != null)
                    {
                        if (dailyMedi.Keys.Contains(treatWeek))
                        {
                            dailyMedi[treatWeek].Add(NtssColMedi);
                        }
                        else
                        {
                            dailyMedi.Add(treatWeek, new List<NtssColumn>() { NtssColMedi });
                        }
                    }
                    // mod #9688 zl end

                    Console.Out.WriteLine("患者治療パターン" + patid + "," + dialDate.ToString());
                }

                if (indOneWeek.Count == 0)
                {
                    continue;
                }

                // 投薬指示再設定
                ResetMediInfo(dailyMedi, indOneWeek);

                mapConvertData[patid] = indOneWeek.Values.ToList();

                // 加工処理失敗時、次の予定レコードへ
                continue;
            }

            WriteTraceLog("===== コンバート処理完了 =====");
            return true;
        }

        private void ConvertCond(DataRow[] rows, string planVal, ref List<IndicationInfo> list)
        {
            foreach (DataRow row in rows)
            {
                IndicationCondInfo info = new IndicationCondInfo();
                // 指示情報取得
                string strCtlNo = row["CTL_NO"].ToString();
                // 指示項目番号
                info.strCtlNo = strCtlNo;
                // 予定指示が中止されているか
                if ("0" != row["DEL_FLG"].ToString())
                {
                    continue; // 削除フラグが立っているなら指示無し
                }
                string num = planVal.Substring(7, 1);
                string treatmentKey = string.Format("VALUE_1W{0}N", num);
                // 抗凝固剤、透析液、補液はセット薬剤使用フラグ確認
                if (row[treatmentKey] is string)
                {
                    string val = row[treatmentKey].ToString();
                    if ((CommonIndConst.DialysisCond.COND_ANTICOAGULAN_LIQUID == strCtlNo) ||
                         (CommonIndConst.DialysisCond.COND_DIALYZE_LIQUID == strCtlNo) ||
                         (CommonIndConst.DialysisCond.COND_REPLENISH_LIQUID == strCtlNo))
                    {
                        // VALUEにセット薬剤使用フラグ＋コードで値が入っている
                        string strValue = val;
                        string strSetFlg = strValue.Substring(0, 1);
                        string strMediCd = strValue.Substring(1);
                        info.strCd = strMediCd;
                        if ("1" == strSetFlg)
                        {
                            info.bolSetMediFlg = true;
                        }
                    }
                    else
                    {
                        // 他の条件項目はコードがそのまま入っている
                        // @abe 隔日透析NKK受入NG対応 #1022隔日透析NG一覧 No.21
                        if ((CommonIndConst.DialysisCond.COND_DW.Equals(strCtlNo))
                            || (CommonIndConst.DialysisCond.COND_TW.Equals(strCtlNo)))
                        {
                            // DW、目標体重
                            if (string.IsNullOrEmpty(val))
                            {
                                info.strCd = string.Empty;
                            }
                            else
                            {
                                info.strCd = AdjustStringForCond(strCtlNo, val);
                            }
                        }
                        else
                        {
                            info.strCd = AdjustStringForCond(strCtlNo, val);
                        }
                    }
                }

                // 更新者
                info.strUpdaterCd = row["UPDATE_STAFF_CD"].ToString();

                // 指示者
                info.strIndicatorCd = row["INDICATOR_CD"].ToString();

                // 特殊設定フラグ
                info.strSpeIndFlg = row["SPE_IND_FLG"].ToString();

                // 更新日
                info.dtIndUpdate = (DateTime)GetFormatedDate(row["UP_DATE"].ToString());

                // 同日複数回
                if (FnwNumber.Is(row["PLURAL"]))
                {
                    info.decPlural = 1;
                }
                else
                {
                    continue;
                }

                // abe オーダ受け対応
                // 連携オーダ番号
                info.strCopOrderNumber = row["COP_ORDER_NUMBER"].ToString();
                // 編集可能フラグ
                if (FnwNumber.Is(row["EDITABLE_FLG"]))
                {
                    info.decEditableFlg = FnwNumber.ToDecimal(row["EDITABLE_FLG"]);
                }
                else
                {
                    continue;
                }

                // リストに追加
                list.Add(info);
            }
        }

        /// <summary>
        /// 透析条件用に数値文字列を表示用に調整する
        /// </summary>
        /// <param name="strCtlNo">項目番号</param>
        /// <param name="strSettingValue">設定値</param>
        /// <returns></returns>
        public string AdjustStringForCond(string strCtlNo, string strSettingValue)
        {
            //	このメソッドと同様の機能がFnw.Client.Util.IndUtil.AdjustStringForCondにも存在するため
            //	このメソッドを修正する際はそちらも修正すること。

            string strFormat = null;
            // 調整対象は、数値項目のみ
            switch (strCtlNo)
            {
                case CommonIndConst.DialysisCond.COND_DW:
                    strFormat = "f2";
                    break;
                case CommonIndConst.DialysisCond.COND_TW:
                    strFormat = "f2";
                    break;
                case CommonIndConst.DialysisCond.COND_REMOVE_WATER_LIMIT:
                    strFormat = "f2";
                    break;
                case CommonIndConst.DialysisCond.COND_ANTICOAGULAN_ONESHOT:
                    strFormat = "f2";
                    break;
                case CommonIndConst.DialysisCond.COND_ANTICOAGULAN_SPEED:
                    strFormat = "f2";
                    break;
                case CommonIndConst.DialysisCond.COND_ANTICOAGULAN_TOTAL:
                    strFormat = "f2";
                    break;
                case CommonIndConst.DialysisCond.COND_IP_MEASURE:
                    strFormat = "f1";
                    break;
                case CommonIndConst.DialysisCond.COND_IP_SPEED:
                    strFormat = "f1";
                    break;
                case CommonIndConst.DialysisCond.COND_DIALYZE_MEASURE:
                    strFormat = "f2";
                    break;
                case CommonIndConst.DialysisCond.COND_DIALYZE_TEMPERATURE:
                    strFormat = "f1";
                    break;
                case CommonIndConst.DialysisCond.COND_REPLENISH_MEASURE:
                    strFormat = "f1";
                    break;
                case CommonIndConst.DialysisCond.COND_REPLENISH_TEMPERATURE:
                    strFormat = "f1";
                    break;
                case CommonIndConst.DialysisCond.COND_REPLENISH_USE_COUNT:
                    strFormat = "f2";
                    break;
                case CommonIndConst.DialysisCond.COND_IP_MAX_SPEED:
                    strFormat = "f1";
                    break;
                case CommonIndConst.DialysisCond.COND_REPLENISH_SPEED:
                    strFormat = "f2";
                    break;
                default:
                    return strSettingValue;
            }

            // null許容項目対処（DW、目標体重）
            if (true == string.IsNullOrEmpty(strSettingValue))
            {
                return "未登録";
            }

            // 数値調整
            decimal decValue;
            decimal.TryParse(strSettingValue, out decValue);

            return decValue.ToString(strFormat);
        }

        private void ConvertMedi(DataRow[] rows, DateTime dtNwDate, string planVal, ref List<IndicationInfo> list)
        {
            foreach (DataRow rowMedi in rows)
            {
                IndicationMediInfo info = new IndicationMediInfo();

                // 投薬指示有無判定 
                string strSettingValue = GetIndSettingValue(planVal, rowMedi, dtNwDate);
                if (("NONE" == strSettingValue))
                {
                    // 指定日にこの投薬指示は行われない
                    continue;
                }

                string strCtlNo = rowMedi["CTL_NO"].ToString();
                // 指示項目番号
                info.strCtlNo = strCtlNo;
                // 指示設定値
                info.strIndContents = strSettingValue;

                // 手技
                info.strProcedureCd = rowMedi["PROCEDURE_CD"].ToString();

                // 投与時間帯
                info.strTimingCd = rowMedi["TIMING_CD"].ToString();

                // コード
                info.strCd = rowMedi["MEDICINE_CD"].ToString();
                // セット薬剤使用フラグ
                if ("1" == rowMedi["SET_MEDICINE_FLG"].ToString())
                {
                    info.bolSetMediFlg = true;
                }

                // 更新者
                info.strUpdaterCd = rowMedi["UPDATE_STAFF_CD"].ToString();

                // 指示者
                info.strIndicatorCd = rowMedi["INDICATOR_CD"].ToString();

                // 特殊設定フラグ
                info.strSpeIndFlg = rowMedi["SPE_IND_FLG"].ToString();

                // コメント
                if ((rowMedi.Table.Columns.Contains("COMMENTS")))
                {
                    info.strComment = rowMedi["COMMENTS"].ToString();
                }

                // abe 月1投与対応　詳細設計⑩
                // 月毎投与設定
                if (FnwNumber.Is(rowMedi["COUNT_EVERY_MONTH"]))
                {
                    info.decCntEveryMonth = FnwNumber.ToDecimal(rowMedi["COUNT_EVERY_MONTH"]);
                }

                // 曜日パターン
                info.strDayPattern = rowMedi["DAY_PATTERN"].ToString();

                // 初回投与日 TODO by zkm 一旦、fnwと一致IND_START_DATEを設定
                info.strIndStartDate = rowMedi["IND_START_DATE"].ToString();

                // abe 注射オーダ対応　詳細設計25
                // 連携オーダ番号
                info.strCopOrderNumber = rowMedi["COP_ORDER_NUMBER"].ToString();

                // 編集可能フラグ
                if (FnwNumber.Is(rowMedi["EDITABLE_FLG"]))
                {
                    info.decEditableFlg = FnwNumber.ToDecimal(rowMedi["EDITABLE_FLG"]);
                }

                // 有効薬剤情報格納
                info.rowIndMedi = rowMedi;

                // リストに追加
                list.Add(info);
            }
        }

        private void ConvertAdd(DataRow[] rows, DateTime dtNwDate, string planVal, ref List<IndicationInfo> list)
        {
            List<string> indidList = new List<string>();
            var result = rows.AsEnumerable()
               .GroupBy(row => new { IndId = row.Field<string>("IND_ID"), Addition = row.Field<string>("ADDITION") })
               .Where(group => group.Count() > 1)
               .Select(group => new { IndId = group.Key.IndId, Addition = group.Key.Addition })
               .Distinct().ToList();
            foreach (DataRow rowAdd in rows)
            {
                IndicationAddInfo info = new IndicationAddInfo();

                // 指示簿指示有無判定 
                string strSettingValue = GetIndSettingValue(planVal, rowAdd, dtNwDate);
                if ("NONE" == strSettingValue)
                {
                    // 指定日にこの指示簿指示は行われない
                    continue;
                }
                //add 10830 start
                string additions = rowAdd["ADDITION"].ToString();
                string indid = rowAdd["IND_ID"].ToString();
                if (indidList.Contains((indid + additions)))
                {
                    continue;
                }
                else
                {
                    indidList.Add(indid + additions);
                }
                if (result.Any(item => item.IndId == indid && item.Addition == additions))
                {
                    var newRow = rows.AsEnumerable().Where(row => row.Field<string>("IND_ID") == indid && row.Field<string>("ADDITION") == additions && row.Field<string>("DEL_FLG") == "0")
                    .OrderByDescending(row => row.Field<Decimal>("CTL_NO")).ThenByDescending(row => row.Field<DateTime>("UP_DATE")).FirstOrDefault();
                    if (newRow != null)
                    {
                        rowAdd["UPDATE_STAFF_CD"] = newRow["UPDATE_STAFF_CD"];//更新者
                        rowAdd["COP_ORDER_NUMBER"] = newRow["COP_ORDER_NUMBER"];//連携オーダ番号
                        rowAdd["SPE_IND_FLG"] = newRow["SPE_IND_FLG"];//登録区分

                    }
                }
                //add 10830 end

                // 指示情報取得
                string strCtlNo = rowAdd["CTL_NO"].ToString();
                // 指示項目番号
                info.strCtlNo = strCtlNo;
                // 指示設定値
                info.strIndContents = strSettingValue;

                // 更新者
                info.strUpdaterCd = rowAdd["UPDATE_STAFF_CD"].ToString();

                // 指示者
                info.strIndicatorCd = rowAdd["INDICATOR_CD"].ToString();

                // 特殊設定フラグ
                info.strSpeIndFlg = rowAdd["SPE_IND_FLG"].ToString();

                // abe オーダ受け対応
                // 連携オーダ番号
                info.strCopOrderNumber = rowAdd["COP_ORDER_NUMBER"].ToString();

                // 編集可能フラグ
                if (FnwNumber.Is(rowAdd["EDITABLE_FLG"]))
                {
                    info.decEditableFlg = FnwNumber.ToDecimal(rowAdd["EDITABLE_FLG"]);
                }
                else
                {
                    return;
                }

                // リストに追加
                list.Add(info);
            }
        }

        private void ConvertEquip(DataRow[] rows, DateTime dtNwDate, string planVal, ref List<IndicationInfo> list)
        {
            foreach (DataRow rowEquip in rows)
            {
                IndicationEquipInfo info = new IndicationEquipInfo();

                // 材料指示有無判定 
                string strSettingValue = GetIndSettingValue(planVal, rowEquip, dtNwDate);
                if ("NONE" == strSettingValue)
                {
                    // 指定日にこの材料指示は行われない
                    continue;
                }

                // 指示情報取得
                string strCtlNo = rowEquip["CTL_NO"].ToString();
                // 指示項目番号
                info.strCtlNo = strCtlNo;
                // 指示設定値
                info.strIndContents = strSettingValue;

                // 穿刺針区分
                info.strSetting = rowEquip["SETTING"].ToString();

                // コード
                info.strCd = rowEquip["EQUIP_CD"].ToString();

                // 更新者
                info.strUpdaterCd = rowEquip["UPDATE_STAFF_CD"].ToString();

                // 指示者
                info.strIndicatorCd = rowEquip["INDICATOR_CD"].ToString();

                // 特殊設定フラグ
                info.strSpeIndFlg = rowEquip["SPE_IND_FLG"].ToString();

                // abe オーダ受け対応
                // 連携オーダ番号
                info.strCopOrderNumber = rowEquip["COP_ORDER_NUMBER"].ToString();

                // 編集可能フラグ
                if (FnwNumber.Is(rowEquip["EDITABLE_FLG"]))
                {
                    info.decEditableFlg = FnwNumber.ToDecimal(rowEquip["EDITABLE_FLG"]);
                }
                else
                {
                    return;
                }

                // リストに追加
                list.Add(info);
            }
        }

        /// <summary>
        /// 確認したい日の指示設定値取得
        /// </summary>
        /// <param name="infoPlan">予定指示情報</param>
        /// <param name="rowInd">指示レコード</param>
        /// <param name="dtDate">指示内容確認日</param>
        /// <returns>指示設定値 ※設定しない場合は"NONE"</returns>
        private string GetIndSettingValue(string planVal, DataRow rowInd, DateTime dtDate)
        {
            // 返却設定値初期化
            string strSettingValue = "NONE";

            // 時分秒切捨て
            dtDate = dtDate.Date;

            // 中止されているか
            if ("0" != rowInd["DEL_FLG"].ToString())
            {
                return strSettingValue; // 削除フラグが立っているなら指示無し
            }

            // 指示簿指示判定
            if (-1 != rowInd.Table.Columns.IndexOf("ADDITION"))
            {
                // 指示簿指示ならこの時点で補足指示内容を返す
                return rowInd["ADDITION"].ToString();
            }

            // abe 月1回対応　詳細設計⑨
            // 指示設定値検索
            int intStartBitPos = -1;    // 適用パターン検索開始位置
            int intTargetWeek = -1;     // 当該週数
            int intCycleWeek = 0;       // サイクル週数

            // 月毎投与設定を取得(この行が存在しない場合は投薬指示以外となる)
            decimal decCntEveryMonth = -1;
            if (-1 != rowInd.Table.Columns.IndexOf("COUNT_EVERY_MONTH"))
            {
                if (FnwNumber.Is(rowInd["COUNT_EVERY_MONTH"]))
                {
                    decCntEveryMonth = FnwNumber.ToDecimal(rowInd["COUNT_EVERY_MONTH"]);
                }
                else
                {
                    // エラー
                    return strSettingValue;
                }
            }

            int intPos = int.Parse(planVal[7].ToString());

            // 曜日パターンを取得
            string strIndDayPattern = rowInd["DAY_PATTERN"].ToString();

            // 月毎の投与ではない(=0)か、投薬指示ではない場合(=-1)
            if ((0 == decCntEveryMonth) || (-1 == decCntEveryMonth))
            {
                if (7 == strIndDayPattern.Length)
                {
                    intCycleWeek = 1;
                }
                else if (14 == strIndDayPattern.Length)
                {
                    intCycleWeek = 2;
                }
                else if (21 == strIndDayPattern.Length)
                {
                    intCycleWeek = 3;
                }
                else if (28 == strIndDayPattern.Length)
                {
                    intCycleWeek = 4;
                }
                else
                {
                    return strSettingValue;
                }

                // 当該週数、適用パターン検索開始位置取得
                if (1 == intCycleWeek) // サイクル週数1週の場合
                {
                    intStartBitPos = 0;
                    intTargetWeek = 1;
                }
                else
                {
                    // 指示開始日取得
                    DateTime dtIndStartDate = new DateTime();
                    if (false == DateTime.TryParseExact(rowInd["IND_START_DATE"].ToString(), "yyyyMMdd", null, 0, out dtIndStartDate))
                    {
                        // エラー
                        return strSettingValue;
                    }

                    // 指示開始日当該週の月曜日取得
                    DateTime dtMonDay = GetMonday(dtIndStartDate);

                    // 指示開始日から何週目か判定
                    intTargetWeek = ((((dtDate - dtMonDay).Days) / 7) % intCycleWeek) + 1;
                    if (1 == intTargetWeek)
                    {
                        intStartBitPos = 0;
                    }
                    else if (2 == intTargetWeek)
                    {
                        intStartBitPos = 7;
                    }
                    else if (3 == intTargetWeek)
                    {
                        intStartBitPos = 14;
                    }
                    else if (4 == intTargetWeek)
                    {
                        intStartBitPos = 21;
                    }
                    else
                    {
                        return strSettingValue;
                    }
                }

                // 予定指示のデータ表示順を取得
                int intSearchPos = intStartBitPos + intPos - 1;

                if ("1" == strIndDayPattern.Substring(intSearchPos, 1))
                {
                    string strRowIndName = string.Format("VALUE_1W{0}N", intSearchPos + 1);
                    // 曜日単位に値が設定されていたらその値を設定する
                    strSettingValue = rowInd[strRowIndName].ToString();
                }
            }
            else if (1 == decCntEveryMonth) // 月1投与の場合
            {
                if (28 != strIndDayPattern.Length)
                {
                    // 月毎投与は必ず28桁なのでそれ以外はエラー
                    return strSettingValue;
                }

                // ---------------------------------------------------------
                // 第何週目の何回目の透析の投薬指示かを取得する
                // ---------------------------------------------------------
                int intWeekPos; // 何週目？かを取得
                int intDiaPos;  // その週の何回目の透析時か？を取得
                GetOnceEveryMonthMediDayPtn(strIndDayPattern, out intWeekPos, out intDiaPos);
                if (-1 == intDiaPos)
                {
                    // どこにもビットが立ってないのはエラー
                    return strSettingValue;
                }

                // ---------------------------------------------------------
                // 設定値の取得
                // ---------------------------------------------------------
                // 予定指示の設定値参照位置のビットが立っていれば取得処理に進む
                if (intDiaPos == intPos)
                {
                    // 指定日の年の月の第1週目の月曜日取得
                    DateTime dtFirstMonday = DateTime.MinValue; // 取得用の変数
                    DateTime firstDate = new DateTime(dtDate.Year, dtDate.Month, 1); // 指定日の年の月の最初の日

                    if (GetMonday(firstDate).Month != firstDate.Month)
                    {
                        // 指定日の年の月の最初の日の週の月曜日が前の月ならば開始日の年の月の最初の日の週の月曜日＋7日をセット
                        dtFirstMonday = GetMonday(firstDate.AddDays(7));
                    }
                    else
                    {
                        // 最初の日の週の月曜日をセット
                        dtFirstMonday = GetMonday(firstDate);
                    }

                    DateTime dtMediWeekMonday = DateTime.MinValue;   // 投薬指示が出ている週の月曜日取得用
                    string strRowIndName = string.Empty;                // 設定値カラム名
                    switch (intWeekPos)
                    {
                        // 1週目
                        case 1:
                            strRowIndName = string.Format("VALUE_1W{0}N", intDiaPos);
                            dtMediWeekMonday = dtFirstMonday;
                            break;

                        // 2週目
                        case 2:
                            strRowIndName = string.Format("VALUE_2W{0}N", intDiaPos);
                            dtMediWeekMonday = dtFirstMonday.AddDays(7);
                            break;

                        // 3週目
                        case 3:
                            strRowIndName = string.Format("VALUE_3W{0}N", intDiaPos);
                            dtMediWeekMonday = dtFirstMonday.AddDays(14);
                            break;

                        // 4週目
                        case 4:
                            strRowIndName = string.Format("VALUE_4W{0}N", intDiaPos);
                            dtMediWeekMonday = dtFirstMonday.AddDays(21);
                            break;

                        // それ以外
                        default:
                            return strSettingValue;
                    }

                    if (dtDate < dtMediWeekMonday)
                    {
                        // 指定日が月1投与の出ている週の月曜日より過去の場合は取得対象外
                        return strSettingValue;
                    }
                    else
                    {
                        // 指定日が月1投与の出ている週であれば投薬指示の設定値を取得する
                        if (7 > (dtDate - dtMediWeekMonday).Days)
                        {
                            strSettingValue = rowInd[strRowIndName].ToString();
                        }
                    }
                }
            }

            return strSettingValue ?? "";
        }

        /// <summary>
        /// 月曜日取得
        /// </summary>
        /// <param name="dt">日時</param>
        /// <returns></returns>
        private static DateTime GetMonday(DateTime dt)
        {
            // 指定日の曜日値取得（月：０、火：１、水：２、木：３、金：４、土：５、日：６）
            int intIndWeekBit = ((int)dt.DayOfWeek + 6) % 7;

            // 指定日当該週の月曜日取得
            return dt.AddDays(-intIndWeekBit).Date;
        }

        /// <summary>
        /// 月1回投薬指示の曜日パターン情報を取得する
        /// </summary>
        /// <param name="strDayPtn">曜日ビットパターン</param>
        /// <param name="intWeekPos">何週目か？</param>
        /// <param name="intDiaPos">その週の何回目の透析か？</param>
        public void GetOnceEveryMonthMediDayPtn(string strDayPtn, out int intWeekPos, out int intDiaPos)
        {
            // out引数初期化
            intWeekPos = 0;
            intDiaPos = -1;

            if (28 != strDayPtn.Length)
            {
                intWeekPos = 1;
                intDiaPos = 1;
                return;
            }

            for (int i = 0; i < 4; i++)
            {
                // 28桁の曜日ビットパターンの先頭から7桁ずつ順番に取り出して
                // ビットが立っているかチェック
                string work = strDayPtn.Substring(7 * i, 7);
                int index = work.IndexOf("1");
                if (-1 != index)
                {
                    intWeekPos = i + 1;
                    intDiaPos = index + 1;
                    break;
                }
            }

            return;
        }

        /// <summary>
        /// 指示情報をNTSSカラムに加工
        /// </summary>
        /// <param name="ntssColumns">NTSSカラムのリスト</param>
        /// <param name="jsonName">指示情報のJSONキー名</param>
        /// <param name="listIndInfo">指示ID</param>
        /// <param name="isDevTable">透析予定の設定値</param>
        /// <param name="isCriticalError">続行不可エラーフラグ</param>
        /// <param name="isConvertError">データ加工エラーフラグ</param>
        private void ConvertIndication(List<NtssColumn> ntssColumns, string jsonName, List<IndicationInfo> listIndInfo, ref bool isCriticalError, ref bool isConvertError)
        {
            string indTableName = null;
            switch (jsonName)
            {
                case "ind_cond_info":
                    indTableName = ConvertControl.FNW_TABLE_IND_DIALYSIS_COND;
                    break;

                case "ind_medi_info":
                    indTableName = ConvertControl.FNW_TABLE_IND_DIALYSIS_MEDI;
                    break;

                case "ind_equip_info":
                    indTableName = ConvertControl.FNW_TABLE_IND_DIALYSIS_EQUIP;
                    break;

                case "ind_ind_comment_info":
                    indTableName = ConvertControl.FNW_TABLE_IND_DIALYSIS_ADD;
                    break;

                case "ind_sch_info":
                    indTableName = ConvertControl.FNW_TABLE_IND_DIALYSIS_PLAN;
                    break;
            }

            if (jsonName == "ind_cond_info")
            {
                //add zl start
                if (listIndInfo.Count > 0)
                {
                    // 指示：治療方法コード、指示：治療方法名
                    IndicationInfo treatItemInfo = listIndInfo.Where(col => "006".Equals(col.strCtlNo)).FirstOrDefault();
                    //add #12092 FNWで「DWと同じ」となっている治療予定の目標体重が「DWと同じ」ではない start
                    IndicationInfo indDwInfo = listIndInfo.Where(col => "004".Equals(col.strCtlNo)).FirstOrDefault();
                    //add #12092 FNWで「DWと同じ」となっている治療予定の目標体重が「DWと同じ」ではない end
                    if (treatItemInfo != null)
                    {
                        ntssColumns.Add(CreateNtssColumn("ind_treatment_cd", NTSS_DATA_TYPE_INTEGER, treatItemInfo.strCd, false));

                        //add 8262 zc start
                        List<IndicationInfo> IndInfo = new List<IndicationInfo>();
                        //string sql = "select COND_CTL_NO from SYS_TREAT_COND_SETTING where TREAT_ITEM_CD='" + treatItemInfo.strCd + "' and use_flg = '0'";
                        //DataTable dt = db.SelectTable(sql);
                        foreach (var indInfo in listIndInfo)
                        {
                            //int count = dt.Select("COND_CTL_NO='" + indInfo.strCtlNo + "'").Count();
                            //if (count == 0)
                            if (!treatItemInfo.strCd.ContainsCondCtlNo(indInfo.strCtlNo))
                            {
                                //add #12092 FNWで「DWと同じ」となっている治療予定の目標体重が「DWと同じ」ではない start
                                if (indInfo.strCtlNo.Equals("005"))
                                {
                                    if (string.Equals(indDwInfo.strCd, indInfo.strCd))
                                    {
                                        indInfo.strCd = "-1";
                                    }
                                }
                                //add #12092 FNWで「DWと同じ」となっている治療予定の目標体重が「DWと同じ」ではない end
                                IndInfo.Add(indInfo);
                            }
                        }
                        listIndInfo = IndInfo;
                        //add 8262 zc end
                    }

                    //10112 zc start
                    string av = string.Empty;
                    if (listIndInfo.Count > 0)
                    {
                        IndicationInfo info = listIndInfo.Where(col => col.strCtlNo.Equals("029")).FirstOrDefault();
                        if (info != null)
                        {
                            av = info.strCd;
                        }

                    }
                    //10112 zc end
                    foreach (string ctlno in AddCtlNoList)
                    {
                        IndicationCondInfo info = new IndicationCondInfo();
                        //10112 zc start
                        if (av.Equals("0"))
                        {
                            if (ctlno.Equals("11"))
                            {
                                continue;
                            }
                        }
                        else
                        {
                            if (ctlno.Equals("9") || ctlno.Equals("10"))
                            {
                                continue;
                            }
                        }
                        //10112 zc end
                        //項目番号セット
                        info.strCtlNo = ctlno;

                        listIndInfo.Add(info);
                    }
                }
            }
            ConvertIndInfo(listIndInfo, indTableName, jsonName, ntssColumns, ref isCriticalError, ref isConvertError);
        }

        /// <summary>
        /// 指示情報をNTSSカラムに加工
        /// </summary>
        /// <param name="listIndInfo">指示情報のリスト</param>
        /// <param name="jsonName">JSONデータ名</param>
        /// <param name="ntssColumns">NTSSカラムのリスト</param>
        /// <param name="isCriticalError">続行不可エラーフラグ</param>
        /// <param name="isConvertError">データ加工エラーフラグ</param>
        private void ConvertIndInfo(List<IndicationInfo> listIndInfo, string tableName, string jsonName, List<NtssColumn> ntssColumns, ref bool isCriticalError, ref bool isConvertError)
        {
            // JSONデータのリスト
            List<List<JsonElement>> jsonElementList = new List<List<JsonElement>>();

            DataRow[] drRelationArray = GetRelationArrayByFnwTableNtssInfo(tableName, this.convertTableName, jsonName);

            foreach (var indInfo in listIndInfo)
            {
                if (indInfo is IndicationCondInfo)
                {
                    // 移行対象の項目番号かチェック
                    if (false == CtlNoConvList.ContainsKey(indInfo.strCtlNo))
                    {
                        // 追加対象でない
                        continue;
                    }
                }

                List<IndInfoColumn> listExtractIndInfo = ExtractIndInfo(indInfo);

                // 展開した情報をコンバート
                var mapJsonTmp = new Dictionary<string, List<JsonElement>>();
                foreach (IndInfoColumn extractIndInfo in listExtractIndInfo)
                {

                    if (extractIndInfo.name == "INDICATOR_CD" || extractIndInfo.name == "UPDATE_STAFF_CD")
                    {
                        DataRow[] relations = GetRelationArray(tableName, extractIndInfo.name, null);
                        if (relations.Length == 0)
                        {
                            // コンバート先の情報が取得できない場合、コンバート対象外にして、次のカラムを判定する
                            continue;
                        }
                        foreach (DataRow relation in relations)
                        {
                            if (ConvertColumn(extractIndInfo.value, relation, ntssColumns, mapJsonTmp) == false)
                            {
                                WriteErrorLog(MSG_ERR_FAILED_DATA, tableName, extractIndInfo.name, extractIndInfo.value);
                                isConvertError = true;
                                return;
                            }
                        }
                    }
                    else
                    { 
                        var relation = GetRelation(tableName, extractIndInfo.name, jsonName);
                        if (relation != null)
                        {
                            if (ConvertColumn(extractIndInfo.value, relation, ntssColumns, mapJsonTmp) == false)
                            {
                                WriteErrorLog(MSG_ERR_FAILED_DATA, tableName, extractIndInfo.name, extractIndInfo.value);
                                isConvertError = true;
                                return;
                            }
                        }
                    }

                }
                if (mapJsonTmp.Count > 0)
                {
                    // 紐付け対象外の空のJSON要素を追加
                    AddNotExistsThenEmptyJsonElement(drRelationArray,
                                                        mapJsonTmp,
                                                        jsonName);

                    jsonElementList.Add(mapJsonTmp[jsonName]);
                }
            }
            if (jsonElementList.Count > 0)
            {
                ntssColumns.Add(CreateNtssColumnForJson(jsonName, NTSS_DATA_TYPE_JSONB, jsonElementList, false));
            }
        }

        // add #9688 zl start
        /// <summary>
        /// 同じ投薬を取り除く
        /// </summary>
        public class Compare : IEqualityComparer<List<JsonElement>>
        {
            public bool Equals(List<JsonElement> x, List<JsonElement> y)
            {
                return x.Where(col => col.keyName.Equals("\"cd\"")).First().value.Equals(y.Where(col => col.keyName.Equals("\"cd\"")).First().value);
            }

            public int GetHashCode(List<JsonElement> obj)
            {
                return obj.Where(col => col.keyName.Equals("\"cd\"")).First().value.GetHashCode();
            }
        }

        /// <summary>
        /// 投薬指示をNTSSカラムに加工
        /// </summary>
        /// <param name="monday">4週目：月曜日～日曜日の投薬リスト</param>
        /// <param name="indOneWeek">月曜日～日曜日の指示格納用ディクショナリ</param>
        private void ResetMediInfo(Dictionary<int, List<NtssColumn>> mediNtssColumns, SortedDictionary<int, NtssRecord> indOneWeek)
        {
            foreach (var item in mediNtssColumns)
            {
                int i = item.Key;
                List<List<JsonElement>> listMedi = new List<List<JsonElement>>();
                List<string> listMediNo = new List<string>();
                
                foreach (NtssColumn json in item.Value)
                {
                    foreach (List<JsonElement> jsonE in json.jsonArray)
                    {
                        string no = jsonE.AsEnumerable().Where(medi => medi.getKeyNameDeleteEscape()== "no" ).Select(medi => medi.getValueDeleteEscape()).FirstOrDefault();
                        
                        if (!listMediNo.Contains(no)) { 
                                listMedi.Add(jsonE);
                                listMediNo.Add(no);
                            }
                        }
                }

                if (listMedi.Count > 0) { 
                    if (!indOneWeek[i].columns.Any(col => col.name.Equals(IND_MEDI_INFO)))
                    {
                        indOneWeek[i].columns.Add(CreateNtssColumn(IND_MEDI_INFO, NTSS_DATA_TYPE_CHARACTER_VARYING, "[]", false));
                    }

                    NtssColumn ntssColumn = indOneWeek[i].columns.Where(col => col.name.Equals("ind_medi_info")).First();
                    ntssColumn.jsonArray = listMedi;
                    ntssColumn.value = null;
                    ntssColumn.colType = "jsonb";
                }
            }
        }



        /// <summary>
        /// 指示情報内のコンバート対象データを取り出す
        /// </summary>
        /// <param name="indInfo">指示情報</param>
        /// <returns>取り出した指示情報のリスト</returns>
        private List<IndInfoColumn> ExtractIndInfo(IndicationInfo indInfo)
        {
            var list = new List<IndInfoColumn>();
            if (indInfo is IndicationPlanInfo)
            {
                ExtractIndInfoPlan(list, indInfo as IndicationPlanInfo);
            }
            else if (indInfo is IndicationCondInfo)
            {
                ExtracIndInfoCond(list, indInfo as IndicationCondInfo);
            }
            else if (indInfo is IndicationMediInfo)
            {
                ExtracIndInfoMedi(list, indInfo as IndicationMediInfo);
            }
            else if (indInfo is IndicationEquipInfo)
            {
                ExtracIndInfoEquip(list, indInfo as IndicationEquipInfo);
            }
            else if (indInfo is IndicationAddInfo)
            {
                ExtracIndInfoAdd(list, indInfo as IndicationAddInfo);
            }

            // 以下は各指示情報共通で必要な値
            var mapIndInfo = new Dictionary<string, object>()
            {
                { "UPDATE_STAFF_CD", indInfo.strUpdaterCd }, // 更新者
                { "INDICATOR_CD", indInfo.strIndicatorCd }, // 指示者
                { "SPE_IND_FLG", indInfo.strSpeIndFlg }, // 特殊設定フラグ
                { "COP_ORDER_NUMBER", indInfo.strCopOrderNumber }, // 連携オーダ番号
                { "EDITABLE_FLG", indInfo.decEditableFlg }, // 編集可能フラグ
            };

            CreateIndInfoColumns(list, mapIndInfo);

            return list;
        }

        /// <summary>
        /// 予定指示情報内のコンバート対象データを取り出して格納する
        /// </summary>
        /// <param name="list">格納する指示情報のリスト</param>
        /// <param name="indInfo">予定指示情報</param>
        private void ExtractIndInfoPlan(List<IndInfoColumn> list, IndicationPlanInfo indInfo)
        {
            var mapIndInfo = new Dictionary<string, object>()
            {
                { "BED_NO", indInfo.decBedNo },
                { "START_TIME", indInfo.strIndStartDate },
            };

            CreateIndInfoColumns(list, mapIndInfo);
        }

        /// <summary>
        /// 条件指示情報内のコンバート対象データを取り出して格納する
        /// </summary>
        /// <param name="list">格納する指示情報のリスト</param>
        /// <param name="indInfo">条件指示情報</param>
        private void ExtracIndInfoCond(List<IndInfoColumn> list, IndicationCondInfo indInfo)
        {
            // 項目番号チェック
            string NtssCtlNo = ConvCtlNo(indInfo.strCtlNo);
            if (string.IsNullOrEmpty(NtssCtlNo))
            {
                // 追加対象でない
                return;
            }

            // 薬剤フラグセット(項目番号「011」、「018」、「022」のみ)
            string meditype = null;
            if (false == string.IsNullOrEmpty(indInfo.strCd) &&
                 (indInfo.strCtlNo == "011" || indInfo.strCtlNo == "018" || indInfo.strCtlNo == "022"))
            {
                meditype = indInfo.bolSetMediFlg ? "2" : "1";
            }

            // 項目番号「018」、「022」のみ そして、セット薬剤使用しての場合：
            // VALUEの前1桁が「1」であれば、調剤と認識される、薬剤コード前2桁を「TS」に変更して
            if (!string.IsNullOrEmpty(indInfo.strCd)
                && ("018".Equals(indInfo.strCtlNo) || "022".Equals(indInfo.strCtlNo))
                && indInfo.bolSetMediFlg)
            {
                indInfo.strCd = "TS" + indInfo.strCd.Substring(2);
                // 治療条件の「018」、「022」は透析液と補液、この部分のmedicine_type=1と固定コンバートする
                meditype = "1";
            }

            var mapIndInfo = new Dictionary<string, object>()
            {
                { "CTL_NO", NtssCtlNo }, // 項目番号
                { "VALUE_1W1N", indInfo.strCd }, // 設定値
                { "ADD_MEDICINE_TYPE", meditype }, // 薬剤区分
            };

            CreateIndInfoColumns(list, mapIndInfo);
        }

        /// <summary>
        /// 透析条件項目番号変換
        /// </summary>
        /// <param name="CtlNo">項目番号</param>
        /// <returns>NTSS項目番号(null:変換対象が存在しない）</returns>
        private string ConvCtlNo(string CtlNo)
        {
            string NtssCtlNo = null;
            if (CtlNoConvList.ContainsKey(CtlNo))
            {
                NtssCtlNo = CtlNoConvList[CtlNo];
            }
            return NtssCtlNo;
        }

        /// <summary>
        /// 投薬指示情報内のコンバート対象データを取り出して格納する
        /// </summary>
        /// <param name="list">格納する指示情報のリスト</param>
        /// <param name="indInfo">投薬指示情報</param>
        private void ExtracIndInfoMedi(List<IndInfoColumn> list, IndicationMediInfo indInfo)
        {
            // 数量取得(数値変換失敗時は「0」セット)
            decimal decAmount;
            if (false == decimal.TryParse(indInfo.strIndContents, out decAmount))
            {
                // 変換失敗時は0セット
                decAmount = 0;
            }

            // 投与間隔
            string dateInterval = getDateInterval(indInfo.decCntEveryMonth, indInfo.strDayPattern);

            var mapIndInfo = new Dictionary<string, object>()
            {
                { "CTL_NO", indInfo.strCtlNo }, // 項目番号
                { "MEDICINE_CD", indInfo.strCd }, // 薬剤コード
                { "SET_MEDICINE_FLG", indInfo.bolSetMediFlg ? "1" : "0" }, // セット薬剤フラグ
                { "TIMING_CD", indInfo.strTimingCd }, // 穿刺針区分
                { "PROCEDURE_CD", indInfo.strProcedureCd }, // 手技コード
                { "VALUE_1W1N", decAmount }, // 設定値
                { "COMMENTS", indInfo.strComment }, // コメント
                { "INIT_DATE", indInfo.strIndStartDate },// 初回投与日 TODO BY ZKM
                { "DATE_INTERVAL", dateInterval },
                { "COUNT_EVERY_MONTH", indInfo.decCntEveryMonth }
            };

            CreateIndInfoColumns(list, mapIndInfo);
        }

        private string getDateInterval(decimal decCntEveryMonth, string dayPattern)
        {
            string dateInterval = null;
            if (decCntEveryMonth == 0)
            {
                if (dayPattern.Length == 7)
                {
                    dateInterval = "1";
                }
                else if (dayPattern.Length == 14)
                {
                    dateInterval = "2";
                }
                else if (dayPattern.Length == 21)
                {
                    dateInterval = "3";
                }
                else if (dayPattern.Length == 28)
                {
                    dateInterval = "4";
                }
            }
            else if (decCntEveryMonth == 1 && dayPattern.Length == 28)
            {
                if (dayPattern.IndexOf("1") < 7 && dayPattern.IndexOf("1") >= 0)
                {
                    dateInterval = "5";
                }
                else if (dayPattern.IndexOf("1") < 14 && dayPattern.IndexOf("1") >= 7)
                {
                    dateInterval = "6";
                }
                else if (dayPattern.IndexOf("1") < 21 && dayPattern.IndexOf("1") >= 14)
                {
                    dateInterval = "7";
                }
                else if (dayPattern.IndexOf("1") < 28 && dayPattern.IndexOf("1") >= 21)
                {
                    dateInterval = "8";
                }
            }
            return dateInterval;
        }

        /// <summary>
        /// 材料指示情報内のコンバート対象データを取り出して格納する
        /// </summary>
        /// <param name="list">格納する指示情報のリスト</param>
        /// <param name="indInfo">材料指示情報</param>
        private void ExtracIndInfoEquip(List<IndInfoColumn> list, IndicationEquipInfo indInfo)
        {
            var mapIndInfo = new Dictionary<string, object>()
            {
                { "EQUIP_CD", indInfo.strCd }, // 医療材料コード
                { "VALUE_1W1N", indInfo.strIndContents }, // 設定値
                { "SETTING", indInfo.strSetting }, // 穿刺針区分
                { "EQUIP_TYPE", 0 }, // 医療材料区分
            };

            CreateIndInfoColumns(list, mapIndInfo);
        }

        /// <summary>
        /// 指示簿指示情報内のコンバート対象データを取り出して格納する
        /// </summary>
        /// <param name="list">格納する指示情報のリスト</param>
        /// <param name="indInfo">指示簿指示情報</param>
        private void ExtracIndInfoAdd(List<IndInfoColumn> list, IndicationAddInfo indInfo)
        {
            var mapIndInfo = new Dictionary<string, object>()
            {
                { "CTL_NO", indInfo.strCtlNo }, // 項目番号
                { "ADDITION", indInfo.strIndContents }, // 設定値
            };

            CreateIndInfoColumns(list, mapIndInfo);
        }

        /// <summary>
        /// 指示情報のカラム名・値を指示情報構造体に加工して格納する
        /// </summary>
        /// <param name="list">格納する指示情報のリスト</param>
        /// <param name="mapIndInfo">指示情報の連想配列(key: カラム名, value: 値)</param>
        private void CreateIndInfoColumns(List<IndInfoColumn> list, Dictionary<string, object> mapIndInfo)
        {
            foreach (var map in mapIndInfo)
            {
                // NULLは空文字
                object value = map.Value ?? "";
                list.Add(new IndInfoColumn() { name = map.Key, value = value.ToString() });
            }
        }

        /// <summary>
        /// 医材情報取得
        /// </summary>
        /// <param name="ntssColumn">NTSSカラム</param>
        /// <param name="targetList">対象コードリスト</param>
        /// <returns></returns>
        private List<JsonElement> GetTargetEquipInfo(NtssColumn ntssColumn, List<string> targetList,string needle_type)
        {
            List<string> cdlist = targetList;
            List<JsonElement> Equip = new List<JsonElement>();

            // 指定コードリストと一致する先頭の医材情報を取得
            foreach (var json in ntssColumn.jsonArray)
            {
                //add 9443 zc start
                if (!string.IsNullOrEmpty(needle_type))
                {
                    if (!json.Where(col => col.keyName.Equals("\"needle_type\"")).First().value.ToString().Equals(needle_type))
                    {
                        continue;
                    }
                }
                //add 9443 zc end
                bool findflg = false;
                foreach (var je in json)
                {
                    var val = je.value;
                    if ("3".Equals(needle_type) && null != val && val.ToString().Contains("SN"))
                    {
                        val = "00" + val.ToString().Substring(2);
                    }
                    if (je.keyName == "\"cd\"" && cdlist.Any(cd => cd.Trim().Equals(val)))
                    {
                        findflg = true;
                        break;
                    }
                }
                if (findflg == true)
                {
                    Equip = json;
                    break;
                }
            }

            return Equip;
        }

        /// <summary>
        /// 条件設定(医材情報)セット
        /// </summary>
        /// <param name="Cond">透析条件のJsonリスト</param>
        /// <param name="Equip">透析条件のJsonリスト</param>
        private void setCondData(List<JsonElement> CondJsonList, List<JsonElement> EquipJsonList)
        {
            CondJsonList.Where(col => col.keyName.Equals("\"value\"")).First().value = EquipJsonList.Where(col => col.keyName.Equals("\"cd\"")).First().value;
            CondJsonList.Where(col => col.keyName.Equals("\"ind_user_id\"")).First().value = EquipJsonList.Where(col => col.keyName.Equals("\"ind_user_id\"")).First().value;
            CondJsonList.Where(col => col.keyName.Equals("\"ind_user_last_name\"")).First().value = EquipJsonList.Where(col => col.keyName.Equals("\"ind_user_last_name\"")).First().value;
            CondJsonList.Where(col => col.keyName.Equals("\"ind_user_first_name\"")).First().value = EquipJsonList.Where(col => col.keyName.Equals("\"ind_user_first_name\"")).First().value;
            CondJsonList.Where(col => col.keyName.Equals("\"upd_user_id\"")).First().value = EquipJsonList.Where(col => col.keyName.Equals("\"upd_user_id\"")).First().value;
            CondJsonList.Where(col => col.keyName.Equals("\"upd_user_last_name\"")).First().value = EquipJsonList.Where(col => col.keyName.Equals("\"upd_user_last_name\"")).First().value;
            CondJsonList.Where(col => col.keyName.Equals("\"upd_user_first_name\"")).First().value = EquipJsonList.Where(col => col.keyName.Equals("\"upd_user_first_name\"")).First().value;
            CondJsonList.Where(col => col.keyName.Equals("\"input_class\"")).First().value = EquipJsonList.Where(col => col.keyName.Equals("\"input_class\"")).First().value;
        }

        /// <summary>
        /// 条件指示に指定医材情報をセット
        /// </summary>
        /// <param name="ntssColumns">NTSSカラム</param>
        /// <returns></returns>
        private bool setDialysisCondFromEquip(List<NtssColumn> ntssColumns,
            string equipInfoJsonName,
            string condInfoJsonName)
        {

            // 透析条件医材項目セット
            if (ntssColumns.Any(col => col.name.Equals(equipInfoJsonName)))
            {
                // 指示：医材情報取得
                var NtssColEquip = ntssColumns.Where(col => col.name.Equals(equipInfoJsonName)).First();

                // 血液回路
                List<JsonElement> Equip_BloodCircuit = GetTargetEquipInfo(NtssColEquip, this.listBloodCircuit,"");
                // 穿刺針(A針)
                List<JsonElement> Equip_Puncture_A = GetTargetEquipInfo(NtssColEquip, this.listNeedleA, "1");
                // 穿刺針(V針)
                List<JsonElement> Equip_Puncture_V = GetTargetEquipInfo(NtssColEquip, this.listNeedleV, "2");
                // 穿刺針(SN)
                List<JsonElement> Equip_Puncture_SN = GetTargetEquipInfo(NtssColEquip, this.listNeedleSN, "3");

                // 透析条件にセット
                var NtssColCond = ntssColumns.Where(col => col.name.Equals(condInfoJsonName)).First();
                List<JsonElement> Cond_BloodCircuit = new List<JsonElement>();
                List<JsonElement> Cond_Puncture_A = new List<JsonElement>();
                List<JsonElement> Cond_Puncture_V = new List<JsonElement>();
                List<JsonElement> Cond_Puncture_SN = new List<JsonElement>();
                // シングルニードル使用
                string SN_use = string.Empty;
                foreach (var json in NtssColCond.jsonArray)
                {
                    // 血液回路
                    var bloodCircuitValue = json.Where(col => col.keyName.Equals("\"key\"")).First().value.ToString();
                    switch (bloodCircuitValue)
                    {
                        case "9":
                            Cond_Puncture_A = json;
                            break;
                        case "10":
                            Cond_Puncture_V = json;
                            break;
                        case "11":
                            Cond_Puncture_SN = json;
                            break;
                        case "12":
                            SN_use = json.Where(col => col.keyName.Equals("\"value\"")).First().value.ToString();
                            break;
                        case "13":
                            Cond_BloodCircuit = json;
                            break;
                    }
                }

                // 血液回路セット
                if (0 != Equip_BloodCircuit.Count && 0 != Cond_BloodCircuit.Count)
                {
                    setCondData(Cond_BloodCircuit, Equip_BloodCircuit);

                    // セットした医材を削除
                    NtssColEquip.jsonArray.Remove(Equip_BloodCircuit);
                }

                if (SN_use == "1")
                {
                    // 穿刺針SNセット
                    if (0 != Equip_Puncture_SN.Count && 0 != Cond_Puncture_SN.Count)
                    {
                        // 透析条件にセット
                        setCondData(Cond_Puncture_SN, Equip_Puncture_SN);

                        // セットした医材を削除
                        NtssColEquip.jsonArray.Remove(Equip_Puncture_SN);
                    }

                }
                else
                {
                    // 穿刺針Aセット
                    if (0 != Equip_Puncture_A.Count && 0 != Cond_Puncture_A.Count)
                    {
                        // 透析条件にセット
                        setCondData(Cond_Puncture_A, Equip_Puncture_A);

                        // セットした医材を削除
                        NtssColEquip.jsonArray.Remove(Equip_Puncture_A);
                    }

                    // 穿刺針Vセット
                    if (0 != Equip_Puncture_V.Count && 0 != Cond_Puncture_V.Count)
                    {
                        // 透析条件にセット
                        setCondData(Cond_Puncture_V, Equip_Puncture_V);

                        // セットした医材を削除
                        NtssColEquip.jsonArray.Remove(Equip_Puncture_V);
                    }
                }
                //10106 start
                if (NtssColEquip.jsonArray.Count > 0)
                {

                    List<string> list = new List<string>(); ;
                    foreach (var json in NtssColEquip.jsonArray)
                    {
                        list.Add(json.Where(col => col.keyName.Equals("\"cd\"")).First().value.ToString());
                    }
                    list = list.Distinct().ToList();
                    List<List<JsonElement>> EQlist = new List<List<JsonElement>>();
                    foreach (string item in list)
                    {
                        int un = 0;
                        bool deleq = false;
                        NtssColEquip.jsonArray.ForEach(row =>
                        {
                            if (row.Where(i => "\"cd\"".Equals(i.keyName)).First().value.Equals(item))
                            {
                                if (!row.Where(i => "\"amount\"".Equals(i.keyName)).First().value.Equals("") && !row.Where(i => "\"amount\"".Equals(i.keyName)).First().value.Equals("null"))
                                {
                                    un += int.Parse(row.Where(i =>
                                          "\"amount\"".Equals(i.keyName)
                                   ).First().value.ToString());
                                }
                            }
                        });

                        NtssColEquip.jsonArray.ForEach(row =>
                        {
                            if (!deleq)
                            {
                                if (row.Where(i => "\"cd\"".Equals(i.keyName)).First().value.Equals(item))
                                {
                                    row.Where(i => "\"amount\"".Equals(i.keyName)).First().value = un;
                                    deleq = true;
                                    EQlist.Add(row);
                                }

                            }
                        });
                    }
                    NtssColEquip.jsonArray = EQlist;
                }
                //10106 end
            }

            return true;
        }

        // add PatTreatmentPattern再構築対応 zkm start
        /// <summary>
        /// 透析系テーブル取得
        /// </summary>
        /// <param name="targetTableName">取得対象テーブル名</param>
        /// <param name="listParam">SQLパラメータリスト</param>
        /// <param name="startDate">対象期間(開始日)</param>
        /// <param name="endDate">対象期間(終了日)</param>
        /// <param name="endDate">対象期間(終了日)</param>
        /// <param name="addCondition">
        /// </param>
        /// <returns>成功：true、失敗：false</returns>
        private bool SetDialysisData(string targetTableName,
            List<string> listParam,
            DateTime? startDate,
            DateTime? endDate)
        {
            var isSuccess = true;
            // 取得対象テーブル用SQLのパスを設定
            var sqlFilePath = CreateSqlPathString(sqlDirectory, targetTableName);
            if (sqlFilePath == null)
            {
                return false;
            }

            // パラメータを1000個ずつに分けて取得
            CommonFunc.InClauseResult inResult = CommonFunc.BuildParameterizedInCondition("patid", 1000, listParam, "P_");

            //mod #10418 SQLクエリの文字列置換が多用されており、SQLインジェクション攻撃によりDBが壊され脆弱性がある。 start
            // 患者ID 1000個ずつでループ
            var resultTable  = ProcSql(db, sqlFilePath, inResult, startDate?.ToString("yyyyMMdd"), endDate?.ToString("yyyyMMdd"));

            if (resultTable.Rows.Count == 0 || resultTable==null)
            {
                // 全パラメータで回しても元データが存在しない場合
                WriteTraceLog("コンバート元データが存在しません。(テーブル名：{0})", targetTableName);
            }
            //mod #10418 SQLクエリの文字列置換が多用されており、SQLインジェクション攻撃によりDBが壊され脆弱性がある。 end

            // 取得したテーブルを透析系テーブル用連想配列に格納
            resultTable.TableName = targetTableName;
            if (targetTableName.Equals("RST_DIALYSIS_COND"))
            {
                if (resultTable.Rows.Count > 0)
                {
                    
                    var rowIndex = resultTable.AsEnumerable()
                        .GroupBy(r => r["DIALYSIS_NO"].ToString())
                        .ToDictionary(g => g.Key, g => g.ToLookup(r => r["CTL_NO"].ToString().Trim()));
                    List<string> rstID = rowIndex.Keys.ToList();
                    var rowsToRemove = new List<DataRow>();
                    foreach (var item in rstID)
                    {
                        if (rowIndex.TryGetValue(item, out var ctlLookup))
                        {
                            var svRow = ctlLookup["12"].FirstOrDefault();
                            if (svRow != null && svRow["VALUE"].ToString().Equals("0"))
                            {
                                // CTL_NO='11'削除
                                var rowToRemove = ctlLookup["11"].FirstOrDefault();
                                if (rowToRemove != null)
                                    rowsToRemove.Add(rowToRemove);
                            }
                            else
                            {
                                // CTL_NO='9'、'10' 削除
                                rowsToRemove.AddRange(ctlLookup["9"]);
                                rowsToRemove.AddRange(ctlLookup["10"]);
                            }
                        }
                    }

                    foreach (var row in rowsToRemove)
                    {
                        resultTable.Rows.Remove(row);
                    }
                }
            }
            mapFnwDataPatTreatmentPattern[targetTableName] = resultTable;
            return isSuccess;
        }


        //mod #10418 SQLクエリの文字列置換が多用されており、SQLインジェクション攻撃によりDBが壊され脆弱性がある。 start
        private static DataTable ProcSql(DBCtrl db, string sqlFilePath, CommonFunc.InClauseResult inResult, params string[] param)
        {
            DataTable dt = null;

            WriteTraceLog("実行SQL：{0}", sqlFilePath);
            try
            {
                using (var sr = new StreamReader(sqlFilePath))
                {
                    // SQLファイル読込
                    var sql = sr.ReadToEnd().Replace(Environment.NewLine, " ").TrimEnd(';');
                    // パラメータをWHERE句に記述
                    //7997 start 
                    if (CacheInformation.Instance.FacilityCd.Equals("0"))
                    {
                        sql = ConditionRegex.Replace(sql, "  1=1");
                    }
                    else
                    {
                        sql = sql.Replace("'{SERIES_CD}'", ":SERIES_CD");
                    }  
                    //7997 end

                    // mod #10418 start
                    sql = sql.Replace("{0}", inResult.Clause);
                    IMakeSqlParameters Sqlparam = db.GetIMakeSqlParameters();
                    if (sql.Contains(":facility_cd"))     
                        Sqlparam.AddParam(":facility_cd", CommonConfig.FacilityCd);
                    
                    if (sql.Contains(":SERIES_CD"))
                        Sqlparam.AddParam(":SERIES_CD", CommonConfig.seriesCd);
                    
                    if (sql.Contains(":START_DATE"))
                        Sqlparam.AddParam(":START_DATE", param[0]);

                    if (sql.Contains(":END_DATE"))
                        Sqlparam.AddParam(":END_DATE", param[1]);

                    foreach (var p in inResult.Parameters)
                    {
                        Sqlparam.AddParam(p.Key, p.Value);
                    }

                    dt = db.SelectTable(sql, Sqlparam.GetParam());
                    // mod #10418 end
                    if (dt == null)
                    {
                        // SQL実行失敗
                        WriteErrorLog("元データ取得SQL実行に失敗しました。(ファイル名：{0})", sqlFilePath);
                    }
                }
            }
            catch (Exception e)
            {
                WriteErrorLog(e, "コンバート元データ取得に失敗しました。" + sqlFilePath);
            }

            return dt;
        }
        //mod #10418 SQLクエリの文字列置換が多用されており、SQLインジェクション攻撃によりDBが壊され脆弱性がある。 end

        // mod #10761 差分コンバートでFNWの治療項目マスタの内容が一部反映されない 孟堅　20240618 start　
        public List<string> GetPatIdList(
            DBCtrl db,
            string schDialysisPlanAddCond,
            string schDialysisPlanDeviceCond,
            string mstSysTreatCond)
        // mod #10761 差分コンバートでFNWの治療項目マスタの内容が一部反映されない 孟堅　20240618 end　
        {
            DealDateSpan dealDate = GetDealDate();
            DateTime startDate = dealDate.startDate;
            DateTime endDate = dealDate.endDate;

            List<string> ListPatId = new List<string>();

            // 指示取得
            ListPatId = getPatIdData(ConvertControl.FNW_ORD_MAIN_IND,
                startDate,
                endDate,
                schDialysisPlanAddCond, ListPatId, db);

            // 指示装置設定取得
            ListPatId = getPatIdData(ConvertControl.FNW_TABLE_PAT_DEVICE_SET,
                startDate,
                endDate,
                schDialysisPlanDeviceCond, ListPatId, db);
            // add #10761 差分コンバートでFNWの治療項目マスタの内容が一部反映されない 孟堅　20240618 start　
            // 治療条件が変更になった場合
            ListPatId = DiffMstSysTreatCond(ListPatId, db, startDate, endDate, mstSysTreatCond);
            // add #10761 差分コンバートでFNWの治療項目マスタの内容が一部反映されない 孟堅　20240618 end　

            ListPatId = ListPatId.Distinct().ToList();
            return ListPatId;

        }

        private List<string> getPatIdData(string targetTableName,
         DateTime? startDate,
         DateTime? endDate,
         string addCondition,
         List<string> ListDialysisId, DBCtrl db)
        {
            var sqlFilePath = CreateSqlPathString(Directory.GetCurrentDirectory() + @"\SQL\pat_treatment_pattern_diff", targetTableName);
            if (sqlFilePath == null)
            {
                return ListDialysisId;
            }
            
            DataTable resultTable = ProcSqlPatid(db, sqlFilePath,  ((DateTime)startDate).ToString("yyyyMMdd"), ((DateTime)endDate).ToString("yyyyMMdd"), addCondition);

            for (int i = 0; i < resultTable.Rows.Count; i++)
            {
                ListDialysisId.Add(resultTable.Rows[i]["PATID"].ToString());
            }
            return ListDialysisId;
        }
        // add PatTreatmentPattern再構築対応 zkm end

       
        //add #10418 end

        //add #10761 差分コンバートでFNWの治療項目マスタの内容が一部反映されない 孟堅　20240618 start　
        /// <summary>
        /// 治療条件が変更になった場合、影響を受けた患者が取得します。
        /// </summary>
        /// <param name="ListPatId">患者ID</param>
        /// <param name="db">データベース接続</param>
        /// <param name="startDate">開始時間</param>
        /// <param name="endDate">終了時間</param>
        /// <param name="cond">条件</param>
        /// <returns></returns>
        private List<string> DiffMstSysTreatCond(List<string> ListPatId, DBCtrl db, DateTime startDate, DateTime endDate, string cond)
        {
            var sqlFilePath = CreateSqlPathString(Directory.GetCurrentDirectory() + @"\SQL\ord_main_list_diff", "ORD_MST_SYS_TREAT_COND");
            if (sqlFilePath == null)
            {
                return ListPatId;
            }
           
            DataTable resultTable = ProcSqlPatid(db, sqlFilePath, null, null, cond);

            if (null != resultTable)
            {
                foreach (DataRow dr in resultTable.Rows)
                {
                    ListPatId.Add(dr["PATID"].ToString());
                }
            }
            return ListPatId;
        }
        //add #10761 差分コンバートでFNWの治療項目マスタの内容が一部反映されない 孟堅　20240618  end　
    }
}
