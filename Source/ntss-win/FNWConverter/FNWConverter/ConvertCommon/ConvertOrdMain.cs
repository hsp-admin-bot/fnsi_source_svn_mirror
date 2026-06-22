using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.IO;
using ConvertCommon.Common;
using Fnw.Common.Ind;
using Fnw.IOControl.DB;
using Fnw.Common.Cmn;
using System.Threading;
using static ConvertCommon.Common.CommonConfig;
using System.Text.RegularExpressions;
using static ConvertCommon.Common.CommonFunc;

namespace ConvertCommon
{
    /// <summary>
    /// コンバート処理クラス(ord_main)
    /// </summary>
    /// <remarks>
    /// [備考] コンバート処理は透析予定・予定指示・透析実績のみ対応
    /// </remarks>
    sealed public class ConvertOrdMain : ConvertBase
    {
        private readonly RelationCacheBase _relationCache;
        private static readonly Regex ConditionRegex =
              new Regex(@"(\s)([A-Za-z\._]*\s*=\s*'\{SERIES_CD\}')", RegexOptions.Compiled);

        /// <summary>透析条件項目番号変換リスト</summary>
        private static Dictionary<string, string> CtlNoConvList = new Dictionary<string, string>()
        {
//            { "001", "" },		// 治療開始時刻
            { "002", "1" },		// 治療時間
            { "003", "2" },		// VA
            //{ "004", "" },	// DW
            { "005", "3" },		// 目標体重
//            { "006", "" },	// 治療方法
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
//            { "026", "" },	// UFRプログラム
//            { "027", "" },	// Na注入プログラム
//            { "028", "" },	// 透析液濃度プログラム
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

        /// <summary>薬剤フラグセット関連情報</summary>
        //mod #10401 djy start
        //private static Dictionary<string, string> UnitConvByMedicineTypeMap = new Dictionary<string, string>() { };
        private static readonly ThreadLocal<Dictionary<string, string>> UnitConvByMedicineTypeMapThreadLocal =
            new ThreadLocal<Dictionary<string, string>>(() => new Dictionary<string, string>());
        public static Dictionary<string, string> GetUnitConvByMedicineTypeMap()
        {
            return UnitConvByMedicineTypeMapThreadLocal.Value;
        }
        public static void ClearUnitConvByMedicineTypeMap()
        {
            UnitConvByMedicineTypeMapThreadLocal.Value = new Dictionary<string, string>();
        }
        //mod #10401 djy end

        /// <summary>薬剤フラグセット関連情報</summary>
        private static Dictionary<string, string> MedicineTypeOtherCtlNoMap = new Dictionary<string, string>() { { "17", "15" }, { "22", "19" }, { "26", "25" }, { "27", "25" }, { "28", "25" } };

        /// <summary>薬剤フラグセット情報リスト</summary>
        private static List<string> medicineTypeCtlNoList = new List<string>()
        {
            "15",		// 透析液流量
            "19",		// 補液
            "25",		// 抗凝固剤
        };

        /// <summary>透析条件不足情報追加リスト</summary>
        private static List<string> AddCtlNoList = new List<string>()
        {
            "9",		// 穿刺針(A針)
            "10",		// 穿刺針(V針)
            "11",		// 穿刺針(SN)
            "13",		// 血液回路
        };

        /// <summary>設定値 透析液使用数、補液使用数、ワンショット量、持続速度、持続総量の単位取得用</summary>
        private static Dictionary<string, string> UnitReferenceConvByCtlNoList = new Dictionary<string, string>()
        {
            { "020", "018" },
            { "030", "022" },
            { "012", "011" },
            { "013", "011" },
            { "014", "011" }
        };

       

        private struct IndInfoColumn
        {
            public string name;
            public string value;
        }

        public override int FnwDataRowCount()
        {
            int dataCount = 0;
            foreach (DataTable dt in mapFnwDataOrd.Values)
            {
                dataCount += dt.Rows.Count;
            }
            return dataCount;
        }

        /// <summary>
        /// コンストラクタ
        /// </summary>
        public ConvertOrdMain() {
            _relationCache = new RelationCacheBase(
                 () => "ord_main"
             );

        }

        public override bool SetFnwData(List<string> listSelectedPatId, DateTime startDate, DateTime endDate, bool isSync)
        {
            WriteTraceLog("===== コンバート元データ取得処理開始 =====");

           
            string schDialysisPlanAddCond = null;
            string rstDialysisAddCond = null;

            // 出力済のデータを除外するオプションがTrueの場合
            if (CommonConfig.isExclusion)
            {
                // コンバート履歴を参照し、出力済の指示・実績データは処理対象から除外する             
                schDialysisPlanAddCond = " and not exists(select * from CONVERT_HISTORY ch where ch.facility_cd=:facility_cd  and s.patid=ch.CONVERTTS and s.dialysis_date >= to_char(ch.start_date,'yyyymmdd') and s.dialysis_date <= to_char(ch.end_date,'yyyymmdd')) ";
                rstDialysisAddCond = " and not exists(select * from CONVERT_HISTORY ch where ch.facility_cd=:facility_cd and b.patid=ch.CONVERTTS and b.START_DATE >= ch.start_date and b.START_DATE < ch.end_date + 1) ";
            }

            List<string> filterPlanIndidListParam = new List<string>();
            List<string> filterRstIndidListParam = new List<string>();
            List<string> filterRstDialysisListParam = new List<string>();
            //add #10761 差分コンバートでFNWの治療項目マスタの内容が一部反映されない 孟堅　20240618 start　
            List<string> indDiffMstSysTreatCondListParam = new List<string>();
            //add #10761 差分コンバートでFNWの治療項目マスタの内容が一部反映されない 孟堅　20240618 end　
            // add FNSI-差分コンバート対応 楊 start
            if (CommonConfig.isDiff)
            {
                string dialysisPlanAddTbl = CommonConfig.dialysisPlanHistTblSql;

                schDialysisPlanAddCond = $" s.up_date >:CONVERT_DATETIME";
                rstDialysisAddCond = "   exists(select * from " + dialysisPlanAddTbl + " ch where  b.START_DATE >= to_char(ch.start_date,'yyyymmdd') and b.START_DATE <= ch.end_date + 1 and b.up_date > ch.CONVERT_DATETIME)";
                // 2023-04-13 ADDED BY 周トウ　START
                string rstDialysisDIffCond = " exists(select * from " + dialysisPlanAddTbl + " ch where  RD.START_DATE >= to_char(ch.start_date,'yyyymmdd') and RD.START_DATE <= ch.end_date + 1 and b.up_date > ch.CONVERT_DATETIME)";
                // 2023-04-13 ADDED BY 周トウ　END

                // add zl start
                string rstDislysisPatLiftListCond = "  exists(select * from " + dialysisPlanAddTbl + " ch where  to_date( RD.reg_date || RD.reg_time, 'YYYYMMDDHH24MISS' ) >= ch.start_date and to_date( RD.reg_date || RD.reg_time, 'YYYYMMDDHH24MISS' ) <= ch.end_date + 1 and RD.up_date > ch.CONVERT_DATETIME)";
                // add zl end　
                //指示取得
                filterPlanIndidListParam = GetSchindid(listSelectedPatId);
                // 透析実績取得 ==> 変更するのDIALYSIS_NOリストを取得
                filterRstIndidListParam = GetRstindid(listSelectedPatId);
                filterRstDialysisListParam = GetRstdialNo(listSelectedPatId, rstDialysisDIffCond, rstDialysisAddCond, rstDislysisPatLiftListCond);
                //add #10761 差分コンバートでFNWの治療項目マスタの内容が一部反映されない 孟堅　20240618 start　
                indDiffMstSysTreatCondListParam = GetIndDiffMstSysTreatCondSetting(listSelectedPatId);
                //add #10761 差分コンバートでFNWの治療項目マスタの内容が一部反映されない 孟堅　20240618 end　
            }
            else {
                rstDialysisAddCond = "1=1";
                schDialysisPlanAddCond = "1=1";
            }
        
            // 透析実績取得
            //mod #10418 start
            bool rst= GetDialysisInfoList(listSelectedPatId, startDate, endDate, rstDialysisAddCond, filterRstDialysisListParam,  filterRstIndidListParam);
            if (!rst)
            {
                return false;
            }
            //mod #10418 end


            //mod #10418 start
            // 透析スケジュール、予定指示から透析予定取得
            bool ind=  GetIndInfoList(listSelectedPatId, startDate, endDate, schDialysisPlanAddCond, filterPlanIndidListParam,indDiffMstSysTreatCondListParam);
            if (!ind) {
                return false;
            }
            //mod #10418 end


            WriteTraceLog("===== コンバート元データ取得処理完了 =====");
            return true;
        }
        private bool GetIndInfoList(List<string> listSelectedPatId, DateTime startDate, DateTime endDate,string schDialysisPlanAddCond,List<string> filterPlanIndidListParam, List<string> indDiffMstSysTreatCondListParam) {

            　

            var isSuccess = SetRstOrIndData(ConvertControl.FNW_TABLE_IND_DIALYSIS_PLAN,
                   listSelectedPatId,
                   startDate,
                   endDate,
                   schDialysisPlanAddCond,"IND", filterPlanIndidListParam, indDiffMstSysTreatCondListParam);
            if (isSuccess == false)
            {
                return false;
            }

            var dtSch = mapFnwDataOrd[ConvertControl.FNW_TABLE_IND_DIALYSIS_PLAN];
            if (dtSch.Rows.Count > 0)
            {
                // 予定がある場合はPATID,PLURALを全て取得する
                List<string> listConnectIndId = dtSch.AsEnumerable()
                                .Select(r => r.Field<string>("IND_ID_CONNECT"))
                                .Distinct()
                                .ToList();
                // 指示の最新更新者情報取得
                var slistIndId = dtSch.AsEnumerable().Select(r => r.Field<string>("IND_ID")).Distinct().ToList();

                CommonFunc.InClauseResult inIndIdResult = CommonFunc.BuildParameterizedInCondition("SCH_PLAN.IND_ID ", 1000, slistIndId, "IND_");
                isSuccess = SetDialysisIndData(ConvertControl.FNW_TABLE_IND_DIALYSIS_UPD_INFO, inIndIdResult,null);
                if (isSuccess == false)
                {
                    return false;
                }

                //add #12229 start
                if (!CommonConfig.isDiff)
                {
                    startDate = CacheInformation.Instance.DialysisPlanStartDate;
                }
                //add #12229 end

                // 治療条件展開取得
                isSuccess = SetIndData(ConvertControl.FNW_TABLE_IND_DIALYSIS_COND, listConnectIndId, startDate, endDate, "COND.PATID || CT.DIALYSIS_DATE || COND.PLURAL", slistIndId);

                if (isSuccess == false)
                {
                    return false;
                }
                // 投薬指示展開取得
                isSuccess = SetIndData(ConvertControl.FNW_TABLE_IND_DIALYSIS_MEDI, listConnectIndId, startDate, endDate, "MEDI.PATID||MT.DIALYSIS_DATE||MEDI.PLURAL", slistIndId);
                if (isSuccess == false)
                {
                    return false;
                }

                // 材料指示展開取得
                isSuccess = SetIndData(ConvertControl.FNW_TABLE_IND_DIALYSIS_EQUIP, listConnectIndId, startDate, endDate, "EQUIP.PATID || ET.DIALYSIS_DATE || EQUIP.PLURAL", slistIndId);
                if (isSuccess == false)
                {
                    return false;
                }

                // 指示簿指示展開取得
                isSuccess = SetIndData(ConvertControl.FNW_TABLE_IND_DIALYSIS_ADD, listConnectIndId, startDate, endDate, "IND_ADD.PATID || AT.DIALYSIS_DATE || IND_ADD.PLURAL", slistIndId);
                if (isSuccess == false)
                {
                    return false;
                }

                CommonFunc.InClauseResult inPatIdResult = CommonFunc.BuildParameterizedInCondition("PATID", 1000, listSelectedPatId, "P_");
                // 患者除水補正情報取得
                isSuccess = SetDialysisIndData(ConvertControl.FNW_TABLE_PAT_REVISE_OFFWATER, inPatIdResult,null);
                if (isSuccess == false)
                {
                    return false;
                }

                // 患者風袋補正情報取得
                isSuccess = SetDialysisIndData(ConvertControl.FNW_TABLE_PAT_REVISE_TARE, inPatIdResult, null);
                if (isSuccess == false)
                {
                    return false;
                }

                // 患者装置設定情報取得
                isSuccess = SetDialysisIndData(ConvertControl.FNW_TABLE_PAT_DEVICE_SET, inPatIdResult, null);
                if (isSuccess == false)
                {
                    return false;
                }
            }
            return isSuccess;
        }


        private bool SetDialysisIndData(string targetTableName, CommonFunc.InClauseResult inClauseResult,string addCondition)
        {
            var isSuccess = true;
            // 取得対象テーブル用SQLのパスを設定
            var sqlFilePath = CreateSqlPathString(sqlDirectory, targetTableName);
            if (sqlFilePath == null)
            {
                return false;
            }
            if (!inClauseResult.HasValue) {
                WriteTraceLog("コンバート元データが存在しません。(テーブル名：{0})", targetTableName);
                return isSuccess;
            }
            var resultTable = new DataTable();

            WriteTraceLog("実行SQL：{0}", sqlFilePath);
            try
            {
                using (var sr = new StreamReader(sqlFilePath))
                {
                    // SQLファイル読込
                    var sql = sr.ReadToEnd().Replace(Environment.NewLine, " ").TrimEnd(';');
                    // パラメータをWHERE句に記述
                    var param = db.GetIMakeSqlParameters();
                    foreach (var p in inClauseResult.Parameters)
                    {
                        param.AddParam(p.Key, p.Value);
                    }
                    if (CacheInformation.Instance.FacilityCd.Equals("0"))
                    {
                        sql = ConditionRegex.Replace(sql, "  1=1");

                    }
                    else {
                        sql = sql.Replace("'{SERIES_CD}'", ":SERIES_CD");
                        
                       
                    }
                    if (!string.IsNullOrEmpty(addCondition))
                    {
                        string[] condition = addCondition.Split('@');
                       
                        if (condition.Length > 1)
                        {
                            sql = string.Format(sql, inClauseResult.Clause, condition[0], condition[1]);
                        }
                        else
                        {

                            sql = string.Format(sql, inClauseResult.Clause, condition[0]);
                        }
                    }
                    else {

                        sql = string.Format(sql, inClauseResult.Clause);
                    }

                    if (sql.Contains(":SERIES_CD"))
                    {
                        param.AddParam(":SERIES_CD", CommonConfig.seriesCd);
                    }
                    //add  7997  zc end                 
                    resultTable = db.SelectTable(sql,param.GetParam());

                    if (resultTable == null)
                    {
                        // SQL実行失敗
                        WriteErrorLog("元データ取得SQL実行に失敗しました。(ファイル名：{0})", sqlFilePath);
                    }
                    if (resultTable.Rows.Count == 0)
                    {
                        // 全パラメータで回しても元データが存在しない場合
                        WriteTraceLog("コンバート元データが存在しません。(テーブル名：{0})", targetTableName);
                    }


                    // 取得したテーブルを透析系テーブル用連想配列に格納
                    resultTable.TableName = targetTableName;

                    //10112 zc start
                    if (targetTableName.Equals("IND_DEVELOP_COND") || targetTableName.Equals("RST_DIALYSIS_COND"))
                    {

                        if (resultTable.Rows.Count > 0)
                        {
                            var groupByColumn = targetTableName.Equals("IND_DEVELOP_COND") ? "IND_ID" : "DIALYSIS_NO";
                            var rowIndex = resultTable.AsEnumerable()
                                .GroupBy(r => r[groupByColumn].ToString())
                                .ToDictionary(g => g.Key, g => g.ToLookup(r => r["CTL_NO"].ToString().Trim()));


                            List<string> listID = rowIndex.Keys.ToList();

                            var rowsToRemove = new List<DataRow>();

                            foreach (var item in listID)
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

                    //10112 zc end
                    mapFnwDataOrd[targetTableName] = resultTable;
                    
                }
            }
            catch (Exception e)
            {
                WriteErrorLog(e, "コンバート元データ取得に失敗しました。" + sqlFilePath);
            }
            return isSuccess;
        }

        private  bool GetDialysisInfoList(List<string> listSelectedPatId, DateTime startDate, DateTime endDate, string rstDialysisAddCond,List<string> filterRstDialysisListParam, List<string> filterRstIndidListParam) 
        {

           

            // 透析実績用取得期間終了日
            var endDateDial = endDate.AddDays(1);
            var isSuccess = SetRstOrIndData(ConvertControl.FNW_TABLE_RST_DIALYSIS,
                   listSelectedPatId,
                   startDate,
                   endDateDial,
                   rstDialysisAddCond,"RST", filterRstDialysisListParam, filterRstIndidListParam);

            if (isSuccess == false)
            {
                return false;
            }
            var dtRst = mapFnwDataOrd[ConvertControl.FNW_TABLE_RST_DIALYSIS];

            // 実績がある場合
            if (dtRst.Rows.Count > 0)
            {

                // 透析実績からPATID,DIALYSIS_DATE,PLURALを全て取得する
                List<string> listIndId = dtRst.AsEnumerable().Select(rst => rst.Field<string>("IND_ID")).Where(indId => !string.IsNullOrEmpty(indId)).ToList();

                CommonFunc.InClauseResult inResult = CommonFunc.BuildParameterizedInCondition("IND_ID", 1000, listIndId, "IND_");

                // 予定指示展開取得
                isSuccess = SetDialysisIndData(ConvertControl.FNW_TABLE_IND_DEVELOP_PLAN, inResult, null);
                if (isSuccess == false)
                {
                    return false;
                }

                // 条件指示展開取得
                isSuccess = SetDialysisIndData(ConvertControl.FNW_TABLE_IND_DEVELOP_COND, inResult, null);
                if (isSuccess == false)
                {
                    return false;
                }
                // 投薬指示展開取得
                isSuccess = SetDialysisIndData(ConvertControl.FNW_TABLE_IND_DEVELOP_MEDI, inResult, null);
                if (isSuccess == false)
                {
                    return false;
                }

                // 材料指示展開取得
                isSuccess = SetDialysisIndData(ConvertControl.FNW_TABLE_IND_DEVELOP_EQUIP, inResult, null);
                if (isSuccess == false)
                {
                    return false;
                }

                // 指示コメント開取得
                isSuccess = SetDialysisIndData(ConvertControl.FNW_TABLE_IND_DEVELOP_ADD, inResult, null);
                if (isSuccess == false)
                {
                    return false;
                }
               
                CommonFunc.InClauseResult inPatIdResult = CommonFunc.BuildParameterizedInCondition("PATID", 1000, listSelectedPatId, "PATID_");
                // 患者除水補正情報取得
                isSuccess = SetDialysisIndData(ConvertControl.FNW_TABLE_PAT_REVISE_OFFWATER, inPatIdResult, null);
                if (isSuccess == false)
                {
                    return false;
                }

                // 患者風袋補正情報取得
                isSuccess = SetDialysisIndData(ConvertControl.FNW_TABLE_PAT_REVISE_TARE, inPatIdResult, null);
                if (isSuccess == false)
                {
                    return false;
                }

                // 患者装置設定情報取得
                isSuccess = SetDialysisIndData(ConvertControl.FNW_TABLE_PAT_DEVICE_SET, inPatIdResult, null);
                if (isSuccess == false)
                {
                    return false;
                }

                // DIALYSIS_NOを全て取得する
                List<string> listDialNo = dtRst.Select().Select(rst => rst["DIALYSIS_NO"].ToString()).Where(dialNo => !string.IsNullOrEmpty(dialNo)).ToList();

                //mod #10418 start 
                CommonFunc.InClauseResult inRstResult = CommonFunc.BuildParameterizedInCondition("RD.DIALYSIS_NO", 1000, listDialNo, "RST_");
                

                // 実際指示の最新更新者情報取得
                isSuccess = SetDialysisIndData(ConvertControl.FNW_TABLE_RST_DIALYSIS_UPD_INFO, inRstResult, null);
                if (isSuccess == false)
                {
                    return false;
                }

                // 透析実績測定体重取得
                List<string> getRstHst = GetRstWeightHst(db, "RST_WEIGHT_HST", startDate, endDate);
                //add zc start    
                getRstHst.Add("RST_WEIGHT_HST");
                //add zc end
                //Add  7997 zc start
                string sVALUE = "0";
                if (!string.IsNullOrEmpty(CacheInformation.Instance.FacilityCd))
                {
                    sVALUE = CacheInformation.Instance.FacilityCd;
                }
                string createSQl = CreateAllSQl(getRstHst, sVALUE);
                //Add  7997 zc end

                //#7475 LL start
                List<string> getLog = GetRstWeightHst(db, "LOG_DEV_LOG", startDate, endDate);
                getLog.Add("LOG_DEV_LOG");
                //add zc end
                string logDev = CreateSimpleLog(getLog);
                string addCon = createSQl + "@" + logDev;

                isSuccess = SetDialysisIndData(ConvertControl.FNW_TABLE_RST_DIALYSIS_WEIGHT, inRstResult, addCon);
                //#7475 LL end
                if (isSuccess == false)
                {
                    return false;
                }

                // 透析実績透析条件取得
                isSuccess = SetDialysisIndData(ConvertControl.FNW_TABLE_RST_DIALYSIS_COND, inRstResult,null);
                if (isSuccess == false)
                {
                    return false;
                }



                // 透析実績投薬取得
                isSuccess = SetDialysisIndData(ConvertControl.FNW_TABLE_RST_DIALYSIS_MEDICATION, inRstResult, null);
                if (isSuccess == false)
                {
                    return false;
                }

                // 透析実績医材取得
                isSuccess = SetDialysisIndData(ConvertControl.FNW_TABLE_RST_DIALYSIS_EQUIP, inRstResult, null);
                if (isSuccess == false)
                {
                    return false;
                }

                // 透析実績指示簿取得
                isSuccess = SetDialysisIndData(ConvertControl.FNW_TABLE_RST_DIALYSIS_ADDITION, inRstResult, null);
                if (isSuccess == false)
                {
                    return false;
                }

                // 透析実績除水補正取得
                isSuccess = SetDialysisIndData(ConvertControl.FNW_TABLE_RST_DIALYSIS_WATER_REMOVE, inRstResult, null);
                if (isSuccess == false)
                {
                    return false;
                }

                // del #9686 指示コンバートで終了日ありにも関わらずそれ以降も延長されている zkm start
                //// 透析実績装置設定取得
                //isSuccess = SetDialysisData(ConvertControl.FNW_TABLE_RST_DIALYSIS_DEVICE, listDialNo);
                //if (isSuccess == false)
                //{
                //    return false;
                //}
                // del #9686 指示コンバートで終了日ありにも関わらずそれ以降も延長されている zkm end

                // 透析実績愁訴処置
                isSuccess = SetDialysisIndData(ConvertControl.FNW_TABLE_RST_DIALYSIS_COMPLAINT, inRstResult, null);
                if (isSuccess == false)
                {
                    return false;
                }

                // 透析実績医材取得
                isSuccess = SetDialysisIndData(ConvertControl.FNW_TABLE_RST_DIALYSIS_TREATMENT, inRstResult, null);
                if (isSuccess == false)
                {
                    return false;
                }

                // 透析実績透析実績愁訴処置_処置者
                isSuccess = SetDialysisIndData(ConvertControl.FNW_TABLE_RST_DIALYSIS_TREAT_PERSON, inRstResult, null);
                if (isSuccess == false)
                {
                    return false;
                }
                // add FNSI-加算情報追加 楊 start
                // 加算情報
                isSuccess = SetDialysisIndData(ConvertControl.FNW_TABLE_RST_RECEIPT_MEMO, inRstResult, null);
                if (isSuccess == false)
                {
                    return false;
                }
                // add FNSI-加算情報追加 楊 end

                // 透析実績風袋補正取得
                isSuccess = SetDialysisIndData(ConvertControl.FNW_TABLE_RST_DIALYSIS_TARE_BEFORE, inRstResult, null);
                if (isSuccess == false)
                {
                    return false;
                }
                isSuccess = SetDialysisIndData(ConvertControl.FNW_TABLE_RST_DIALYSIS_TARE_AFTER, inRstResult, null);
                if (isSuccess == false)
                {
                    return false;
                }

                // add zl start
                // 透析実績回診記録取得
                isSuccess = SetDialysisIndData(ConvertControl.FNW_TABLE_PAT_LIFE_LIST, inRstResult, null);
                if (isSuccess == false)
                {
                    return false;
                }
                // add zl end

                // TODO チェックリスト実績取得
            }
            return true;
        }

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
                if (mapFnwDataOrd.ContainsKey(kvp.Key))
                {
                    mapFnwDataOrdNew.Add(kvp.Key, mapFnwDataOrd[kvp.Key].AsEnumerable()
                            .ToLookup(dr => dr[key].ToString())
                            .ToDictionary(
                                drGroup => drGroup.Key,
                                drGroup => drGroup.ToArray()
                            ));
                }
            }

            // 透析予定コンバート
            bool indResFlg = ConvertIndInfo(mapConvertData, listErrorPat);
            if (false == indResFlg)
            {
                return indResFlg;
            }

            // 透析実際コンバート
            bool rstResFlg = ConvertRstInfo(mapConvertData, listErrorPat);
            if (false == rstResFlg)
            {
                return rstResFlg;
            }

            WriteTraceLog("===== コンバート処理完了 =====");
            return true;
        }

        private void SetFixedColumn(List<NtssColumn> ntssColumns)
        {

            // 登録施設コードが存在しない場合追加
            if (!ntssColumns.Any(col => col.name.Equals("facility_cd")))
            {
                ntssColumns.Insert(0, CreateNtssColumn("facility_cd", NTSS_DATA_TYPE_CHARACTER_VARYING, this.facilityCd, true));
            }

            // 施設名を追加(SYNC_CUSTOM_CONVERT_VALUEに転換する)
            ntssColumns.Add(CreateNtssColumn("facility_name", NTSS_DATA_TYPE_CHARACTER_VARYING, this.facilityCd, true));
        }

        private bool ConvertIndInfo(Dictionary<string, List<NtssRecord>> mapConvertData, List<string> listErrorPat)
        {
            var dtSch = mapFnwDataOrd[ConvertControl.FNW_TABLE_IND_DIALYSIS_PLAN];
            foreach (DataRow schRecord in dtSch.Rows)
            {
                //var patid = schRecord["PATID"].ToString();
                var patid = schRecord.Field<string>("PATID");
                if (listErrorPat.Contains(patid))
                {
                    // エラーがあった患者のそれ以降のレコードは処理しない
                    continue;
                }

                string indId = schRecord.Field<string>("IND_ID");
                var planVal = schRecord.Field<string>("VALUE");
                var plural = schRecord.Field<decimal>("PLURAL");
                DateTime dialDate = (DateTime)GetFormatedDate(schRecord.Field<string>("DIALYSIS_DATE"));

                var ntssColumns = new List<NtssColumn>();
                // JSONデータ作成用連想配列
                var mapJson = new Dictionary<string, List<JsonElement>>();
                // 失敗フラグ
                var isCriticalError = false;
                var isConvertError = false;

                //WriteTraceLog("レコード情報(テーブル名：{0} PATID：{1} DIALYSIS_DATE：{2} PLURAL：{3})", dtSch.TableName, patid, dialDate.ToString("yyyyMMdd"), plural.ToString());

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

                DataRow[] ListUpdInfo = SearchMapFnwDataOrdNew(ConvertControl.FNW_TABLE_IND_DIALYSIS_UPD_INFO, indId);
                if (ListUpdInfo.Length == 1) {
                    var updInfo = ListUpdInfo[0];
                    // 最終更新指示者ID
                    ntssColumns.Add(CreateNtssColumn("up_ind_user_id", NTSS_DATA_TYPE_CHARACTER_VARYING, updInfo["INDICATOR_CD"].ToString(), false));
                    // 最終更新者ID
                    ntssColumns.Add(CreateNtssColumn("up_user_id", NTSS_DATA_TYPE_CHARACTER_VARYING, updInfo["UPDATE_STAFF_CD"].ToString(), false));
                }

                //------------------------------------
                // 条件指示
                //------------------------------------
                List<IndicationInfo> listCondInfo = new List<IndicationInfo>();
                DataRow[] rows = SearchMapFnwDataOrdNew(ConvertControl.FNW_TABLE_IND_DIALYSIS_COND, indId);
                ConvertCond(rows, planVal, ref listCondInfo);
                ConvertIndication(ntssColumns, "ind_cond_info", listCondInfo, false, ref isConvertError);
                //mod #10401 djy start
                //UnitConvByMedicineTypeMap.Clear();
                ClearUnitConvByMedicineTypeMap();
                //mod #10401 djy end
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
                // DW指示
                //------------------------------------
                
                List<IndicationInfo> dwRows = listCondInfo.AsEnumerable().Where(col => "004".Equals(col.strCtlNo)).ToList();
                if (dwRows.Count > 0 && !string.IsNullOrEmpty(dwRows[0].strCd))
                {
                    ConvertDwInfo(dwRows[0], "ind_dw_user_info", ntssColumns, ConvertControl.FNW_TABLE_IND_DIALYSIS_COND, ref isConvertError);
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
                }
                

                //------------------------------------
                // 投薬指示
                //------------------------------------
                List<IndicationInfo> listMediInfo = new List<IndicationInfo>();
                DataRow[] mediRows = SearchMapFnwDataOrdNew(ConvertControl.FNW_TABLE_IND_DIALYSIS_MEDI, indId);
                ConvertMedi(mediRows, dialDate, planVal, ref listMediInfo);
                ConvertIndication(ntssColumns, "ind_medi_info", listMediInfo, false, ref isConvertError);
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
                ConvertIndication(ntssColumns, "ind_equip_info", listEquipInfo, false, ref isConvertError);
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
                ConvertAdd(indCommentRows, dialDate, planVal, "IND_DIALYSIS_ADD", ref listIndCommentInfo);
                ConvertIndication(ntssColumns, "ind_ind_comment_info", listIndCommentInfo, false, ref isConvertError);
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

                // JSONデータ作成用連想配列をJSONデータにして追加する
                if (mapJson.Count > 0)
                {
                    foreach (string jsonName in mapJson.Keys)
                    {
                        DataRow[] drRelationArray = GetRelationArrayByNtssInfo(this.convertTableName,
                                                           jsonName);
                        // 紐付け対象外の空のJSON要素を追加
                        AddNotExistsThenEmptyJsonElement(drRelationArray,
                                                            mapJson,
                                                            jsonName);
                        // JSONデータのリスト
                        List<List<JsonElement>> jsonElementList = new List<List<JsonElement>>();
                        jsonElementList.Add(mapJson[jsonName]);

                        if (jsonElementList.Count > 0)
                        {
                            ntssColumns.Add(CreateNtssColumnForJson(jsonName, NTSS_DATA_TYPE_JSONB, jsonElementList, false));
                        }
                    }
                }

                // JSONデータ作成用連想配列をJSONデータにして追加する
                // JSONデータ形式の文字列ではなく、JsonElementのリスト形式で保持するため削除
                // SetJsonToConvertData(mapJson, ntssColumns);

                // 登録施設コード、登録日時、更新日時、施設名を追加
                SetFixedColumn(ntssColumns);

                // JSONキーが存在しない場合は、キーを保留し、値をnullに設定する zkm start
                addKeyWhenKeyNotExist(ntssColumns);
                // JSONキーが存在しない場合は、キーを保留し、値をnullに設定する zkm end

                if (mapConvertData.ContainsKey(patid) == false)
                {
                    mapConvertData[patid] = new List<NtssRecord>();
                }
                mapConvertData[patid].Add(new NtssRecord() { columns = ntssColumns });

                // 加工処理失敗時、次の予定レコードへ
                continue;
            }
            return true;
        }

        private DataTable SetIndDataMedi(DBCtrl db, string sqlFilePath,
          List<string> listParam,
          string startDate,
          string endDate,
         string key, List<string> slistIndId)
        {
            DataTable dt = null;
            CommonFunc.InClauseResult inResult = CommonFunc.BuildParameterizedInCondition(key, 1000, slistIndId, "IND_");


            var rst = CommonFunc.BuildParameterizedTupleValues(listParam, "P");
            WriteTraceLog("実行SQL：{0}", sqlFilePath);
            try
            {
                using (var sr = new StreamReader(sqlFilePath))
                {
                    // SQLファイル読込
                    var sql = sr.ReadToEnd().Replace(Environment.NewLine, " ").TrimEnd(';');
                    // パラメータをWHERE句に記述
                    //add  7997  zc start
                    if (CacheInformation.Instance.FacilityCd.Equals("0"))
                    {
                        sql = ConditionRegex.Replace(sql, "  1=1");
                    }
                    else
                    {
                        sql = sql.Replace("'{SERIES_CD}'", ":SERIES_CD");
                    }
                    sql = string.Format(sql, rst.Clause, inResult.Clause);
                    //add  7997  zc end

                    // mod #10418 start 
                    IMakeSqlParameters Sqlparam = db.GetIMakeSqlParameters();
                    foreach (var p in inResult.Parameters)
                    {
                        Sqlparam.AddParam(p.Key, p.Value);
                    }

                    foreach (var p in rst.Parameters)
                    {
                        Sqlparam.AddParam(p.Key, p.Value);
                    }
                    Sqlparam.AddParam(":START_DATE", startDate);
                    Sqlparam.AddParam(":END_DATE", endDate);

                    if (sql.Contains(":SERIES_CD")) {
                        Sqlparam.AddParam(":SERIES_CD", CommonConfig.seriesCd);
                    }
                     dt = db.SelectTable(sql, Sqlparam.GetParam());
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

        private bool ConvertRstInfo(Dictionary<string, List<NtssRecord>> mapConvertData, List<string> listErrorPat)
        {
           
            var dtRst = mapFnwDataOrd[ConvertControl.FNW_TABLE_RST_DIALYSIS];
            if (dtRst.Rows.Count == 0) {
                return true;
            }
            var slistIndId = dtRst.AsEnumerable()
            .Select(r => r.Field<string>("IND_ID"))
            .Where(id => !string.IsNullOrEmpty(id))
            .Distinct()
            .ToList();
            

            DataTable dt_medi= null;
            if (slistIndId.Count!=0) {
                string strDialDate = ((DateTime)CacheInformation.Instance.DialysisPlanStartDate).ToString("yyyyMMdd");
                string strendDate = DateTime.Now.AddDays(1).ToString("yyyyMMdd");
                var whereInSqlList = dtRst.AsEnumerable()
                       .Where(r => !r.IsNull("IND_ID"))
                       .Select(r => $"{r.Field<string>("PATID")}, {r.Field<decimal>("PLURAL")}")
                       .Distinct()
                       .ToList();
                dt_medi = SetIndDataMedi(db, CreateSqlPathString(sqlDirectory, ConvertControl.FNW_TABLE_IND_DEVELOP_MEDI_MANUAL), whereInSqlList, strDialDate, strendDate, "IND_ID", slistIndId);

            }
              
            var lookup = (dt_medi == null)
                ? Enumerable.Empty<DataRow>().ToLookup(r => "")
                : dt_medi.AsEnumerable().ToLookup(r => r.Field<string>("IND_ID"));

            //------------------------------------
            // 実績の処理
            //------------------------------------
            foreach (DataRow rstRecord in dtRst.Rows)
            {
                //var patid = rstRecord["PATID"].ToString();
                var patid = rstRecord.Field<string>("PATID");
                if (listErrorPat.Contains(patid))
                {
                    // エラーがあった患者のそれ以降のレコードは処理しない
                    continue;
                }
                DateTime startdate = rstRecord.Field<DateTime>("START_DATE");
                var rstDialNo = rstRecord.Field<decimal>("DIALYSIS_NO").ToString();
                var ntssColumns = new List<NtssColumn>();
                var mapJson = new Dictionary<string, List<JsonElement>>();
                // 失敗フラグ
                var isCriticalError = false;
                var isConvertError = false;

                //WriteTraceLog("レコード情報(テーブル名：{0} PATID：{1} DIALYSIS_NO：{2})", dtRst.TableName, patid, rstDialNo);

                string indId = rstRecord.Field<string>("IND_ID");

                // 手動実際作成
                if (string.IsNullOrEmpty(indId))
                {

                    if (!TryAddDialysisBaseColumns(
                        rstRecord,
                        ntssColumns,
                        rstDialNo,
                        startdate))
                    {
                        continue;
                    }

                }
                else
                {
                    TryProcessDialysisResult(rstRecord,
                         indId,
                         rstDialNo,
                        ref ntssColumns);


                    DataRow[] row_medi = lookup[indId].ToArray();

                    // 実際の指示展開情報を取得する
                    AddIndDevelopInfo(row_medi, rstRecord, ntssColumns, mapJson, listErrorPat, ref isCriticalError, ref isConvertError);
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
                }

                // 治療状況は6：後体重確認済み(過去実績)を設定
                ntssColumns.Add(CreateNtssColumn("rst_dialysis_state", NTSS_DATA_TYPE_INTEGER, "6", false));
                ntssColumns.Add(CreateNtssColumn("is_confirm", NTSS_DATA_TYPE_CHARACTER_VARYING, "6", false));

                ntssColumns.Add(CreateNtssColumn("rst_is_update_edition", NTSS_DATA_TYPE_CHARACTER_VARYING, "6", false));

                // 透析実績テーブルの治療方法コードによって、治療項目マスタテーブルから治療分類を取得する。
                AddTreatCountColumns(rstRecord, ntssColumns);
                //------------------------------------
                // 透析実績
                //------------------------------------
                ConvertRecord(rstRecord, ntssColumns, mapJson, ref isConvertError);
                if (isCriticalError)
                {
                    return false;
                }
                if (isConvertError)
                {
                    listErrorPat.Add(patid);
                    // 次の実績レコードへ
                    continue;
                }

                //------------------------------------
                // 透析実績測定体重
                //------------------------------------
                // 透析実績測定体重を1件取得
                DataRow[] indRstWeightRecords = SearchMapFnwDataOrdNew(ConvertControl.FNW_TABLE_RST_DIALYSIS_WEIGHT, rstDialNo);
                if (indRstWeightRecords.Length == 1)
                {
                    // 実績あり
                    ConvertRecord(indRstWeightRecords[0], ntssColumns, mapJson, ref isConvertError);
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
                }

                //------------------------------------
                // 透析実績透析条件
                //------------------------------------
                DataRow[] rows = SearchMapFnwDataOrdNew(ConvertControl.FNW_TABLE_RST_DIALYSIS_COND, rstDialNo);
                ConvertJsonArrayData(rows, "rst_cond_info", ntssColumns, ConvertControl.FNW_TABLE_RST_DIALYSIS_COND, ref isCriticalError, ref isConvertError);
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

                // #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない ZL start 
                // 透析実績透析条件（指示者、更新者設定）
                SetRstOtherInfoFromIndInfo(ntssColumns, "rst_cond_info", "ind_cond_info", "\"key\"");
                // #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない ZL end 

                //------------------------------------
                // 透析実績投薬
                //------------------------------------
                rows = SearchMapFnwDataOrdNew(ConvertControl.FNW_TABLE_RST_DIALYSIS_MEDICATION, rstDialNo);
                ConvertJsonArrayData(rows, "rst_medi_info", ntssColumns, ConvertControl.FNW_TABLE_RST_DIALYSIS_MEDICATION, ref isCriticalError, ref isConvertError);
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

                // #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない ZL start 
                // 透析実績投薬（指示開始日、特殊設定フラグ、指示者、編集可能フラグ設定）
                SetRstOtherInfoFromIndInfo(ntssColumns, "rst_medi_info", "ind_medi_info", "\"cd\"");
                // #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない ZL end 

                //------------------------------------
                // 透析実績医療材料
                //------------------------------------
                rows = SearchMapFnwDataOrdNew(ConvertControl.FNW_TABLE_RST_DIALYSIS_EQUIP, rstDialNo);
                ConvertJsonArrayData(rows, "rst_equip_info", ntssColumns, ConvertControl.FNW_TABLE_RST_DIALYSIS_EQUIP, ref isCriticalError, ref isConvertError);
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

                // #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない ZL start 
                // 透析実績医療材料（指示開始日、特殊設定フラグ、指示者、編集可能フラグ設定）
                SetRstOtherInfoFromIndInfo(ntssColumns, "rst_equip_info", "ind_equip_info", "\"cd\"");
                // #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない ZL end 

                //------------------------------------
                // 透析実績指示簿指示
                //------------------------------------
                rows = SearchMapFnwDataOrdNew(ConvertControl.FNW_TABLE_RST_DIALYSIS_ADDITION, rstDialNo);
                ConvertJsonArrayData(rows, "rst_ind_comment_info", ntssColumns, ConvertControl.FNW_TABLE_RST_DIALYSIS_ADDITION, ref isCriticalError, ref isConvertError);
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

                SetRstOtherInfoFromIndInfo(ntssColumns, "rst_ind_comment_info", "ind_ind_comment_info", "\"no\"");

                //------------------------------------
                // 透析実績愁訴処置
                //------------------------------------
                rows = SearchMapFnwDataOrdNew(ConvertControl.FNW_TABLE_RST_DIALYSIS_TREATMENT, rstDialNo);
                ConvertJsonArrayData(rows, "rst_treatment_info", ntssColumns, ConvertControl.FNW_TABLE_RST_DIALYSIS_TREATMENT, ref isCriticalError, ref isConvertError);
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
                // 透析実績愁訴処置
                //------------------------------------
                rows = SearchMapFnwDataOrdNew(ConvertControl.FNW_TABLE_RST_DIALYSIS_COMPLAINT, rstDialNo);
                ConvertJsonArrayData(rows, "rst_complaint_info", ntssColumns, ConvertControl.FNW_TABLE_RST_DIALYSIS_COMPLAINT, ref isCriticalError, ref isConvertError);
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
                // 透析実績愁訴処置
                //------------------------------------
                rows = SearchMapFnwDataOrdNew(ConvertControl.FNW_TABLE_RST_DIALYSIS_TREAT_PERSON, rstDialNo);
                ConvertJsonArrayData(rows, "rst_treat_staff_info", ntssColumns, ConvertControl.FNW_TABLE_RST_DIALYSIS_TREAT_PERSON, ref isCriticalError, ref isConvertError);
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
                // add FNSI-加算情報追加 楊 start
                //------------------------------------
                // 加算情報
                //------------------------------------
                rows = SearchMapFnwDataOrdNew(ConvertControl.FNW_TABLE_RST_RECEIPT_MEMO, rstDialNo);
                ConvertJsonArrayData(rows, "addition_info", ntssColumns, ConvertControl.FNW_TABLE_RST_RECEIPT_MEMO, ref isCriticalError, ref isConvertError);
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
                // add FNSI-加算情報追加 楊 end

                //------------------------------------
                // 透析実績風袋情報
                //------------------------------------
                ntssColumns.Insert(0, CreateNtssColumn("rst_tare_info", NTSS_DATA_TYPE_CHARACTER_VARYING, "", true));
                // 透析前
                rows = SearchMapFnwDataOrdNew(ConvertControl.FNW_TABLE_RST_DIALYSIS_TARE_BEFORE, rstDialNo);
                ConvertJsonArrayData(rows, "rst_tare_info_before", ntssColumns, ConvertControl.FNW_TABLE_RST_DIALYSIS_TARE_BEFORE, ref isCriticalError, ref isConvertError);
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

                // #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない ZL start 
                RstDialysisDataFormat(ntssColumns, "rst_tare_info_before");
                // #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない ZL end 

                // 透析後
                rows = SearchMapFnwDataOrdNew(ConvertControl.FNW_TABLE_RST_DIALYSIS_TARE_AFTER, rstDialNo);
                ConvertJsonArrayData(rows, "rst_tare_info_after", ntssColumns, ConvertControl.FNW_TABLE_RST_DIALYSIS_TARE_AFTER, ref isCriticalError, ref isConvertError);
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

                // #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない ZL start 
                RstDialysisDataFormat(ntssColumns, "rst_tare_info_after");
                // #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない ZL end 

                //------------------------------------
                // 透析実績除水補正情報
                //------------------------------------
                //rows = mapFnwDataOrd[ConvertControl.FNW_TABLE_RST_DIALYSIS_WATER_REMOVE].Select(string.Format("DIALYSIS_NO = {0}", rstDialNo));
                rows = SearchMapFnwDataOrdNew(ConvertControl.FNW_TABLE_RST_DIALYSIS_WATER_REMOVE, rstDialNo);
                ConvertJsonArrayData(rows, "rst_off_water_info", ntssColumns, ConvertControl.FNW_TABLE_RST_DIALYSIS_WATER_REMOVE, ref isCriticalError, ref isConvertError);
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

                // #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない ZL start 
                RstDialysisDataFormat(ntssColumns, "rst_off_water_info");
                // #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない ZL end

                // 透析条件医材項目セット（実績データ）
                if (false == setDialysisCondFromEquip(ntssColumns, "rst_equip_info", "rst_cond_info"))
                {
                    return false;
                }

                // 透析条件医材項目セット（指示データ）
                if (false == setDialysisCondFromEquip(ntssColumns, "ind_equip_info", "ind_cond_info"))
                {
                    return false;
                }

                // add zl start
                //------------------------------------
                // 実績：回診記録情報
                //------------------------------------
                rows = SearchMapFnwDataOrdNew(ConvertControl.FNW_TABLE_PAT_LIFE_LIST, rstDialNo);
                if (rows.Length > 0)
                {
                    ConvertJsonArrayData(rows, "rst_rounds_info", ntssColumns, ConvertControl.FNW_TABLE_PAT_LIFE_LIST, ref isCriticalError, ref isConvertError);
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
                }
                // add zl end

                // JSONデータ作成用連想配列をJSONデータにして追加する
                //SetJsonToConvertData(mapJson, ntssColumns);
                if (mapJson.Count > 0)
                {
                    foreach (string jsonName in mapJson.Keys)
                    {
                        DataRow[] drRelationArray = GetRelationArrayByNtssInfo(this.convertTableName,
                                                           jsonName);
                        // 紐付け対象外の空のJSON要素を追加
                        AddNotExistsThenEmptyJsonElement(drRelationArray,
                                                            mapJson,
                                                            jsonName);
                        // JSONデータのリスト
                        List<List<JsonElement>> jsonElementList = new List<List<JsonElement>>();
                        jsonElementList.Add(mapJson[jsonName]);

                        if (jsonElementList.Count > 0)
                        {
                            ntssColumns.Add(CreateNtssColumnForJson(jsonName, NTSS_DATA_TYPE_JSONB, jsonElementList, false));
                        }
                    }
                }

                // 登録施設コード、登録日時、更新日時、施設名を追加
                SetFixedColumn(ntssColumns);

                // JSONキーが存在しない場合は、キーを保留し、値をnullに設定する zkm start
                addKeyWhenKeyNotExist(ntssColumns);
                // JSONキーが存在しない場合は、キーを保留し、値をnullに設定する zkm end

                if (mapConvertData.ContainsKey(patid) == false)
                {
                    mapConvertData[patid] = new List<NtssRecord>();
                }
                mapConvertData[patid].Add(new NtssRecord() { columns = ntssColumns });

                // 加工処理失敗時、次の予定レコードへ
                continue;
            }
            return true;
        }

        private void ConvertDwInfo(IndicationInfo dwRow, string jsonName, List<NtssColumn> ntssColumns, string fnwTableName, ref bool isConvertError)
        {
            List<IndInfoColumn> dwInfoColumn = ExtractIndInfo(dwRow, fnwTableName.Contains("_MANUAL"));
            // 展開した情報をコンバート
            var mapJsonTmp = new Dictionary<string, List<JsonElement>>();
            foreach (IndInfoColumn extractIndInfo in dwInfoColumn)
            {

                DataRow relation = GetRelationByFnwInfoNtssInfo(fnwTableName, extractIndInfo.name, this.convertTableName, jsonName);
                if (relation != null)
                {
                    if (ConvertColumn(extractIndInfo.value, relation, ntssColumns, mapJsonTmp) == false)
                    {
                        WriteErrorLog(MSG_ERR_FAILED_DATA, fnwTableName, extractIndInfo.name, extractIndInfo.value);
                        isConvertError = true;
                        return;
                    }
                }
            }
            // JSONデータのリスト
            List<List<JsonElement>> jsonElementList = new List<List<JsonElement>>();

            DataRow[] drRelationArray = GetRelationArrayByFnwTableNtssInfo(fnwTableName, this.convertTableName, jsonName);
            if (mapJsonTmp.Count > 0)
            {
                // 紐付け対象外の空のJSON要素を追加
                AddNotExistsThenEmptyJsonElement(drRelationArray,
                                                    mapJsonTmp,
                                                    jsonName);

                jsonElementList.Add(mapJsonTmp[jsonName]);
            }

            if (jsonElementList.Count > 0)
            {
                ntssColumns.Add(CreateNtssColumnForJson(jsonName, NTSS_DATA_TYPE_JSONB, jsonElementList, false));
            }
        }

      
        private void AddIndDevelopInfo(DataRow[] row_medi,DataRow rstRecord, List<NtssColumn> ntssColumns, Dictionary<string,
          List<JsonElement>> mapJson, List<string> listErrorPat, ref bool isCriticalError, ref bool isConvertError)
        {
            string plural = rstRecord["PLURAL"].ToString();
            DateTime dialDate = (DateTime)GetFormatedDate(rstRecord["DIALYSIS_DATE"].ToString());
            string indId = rstRecord["IND_ID"].ToString();
            var patid = rstRecord["PATID"].ToString();
            string strDialDate = ((DateTime)dialDate).ToString("yyyyMMdd");
            string strPatidPlural = "('" + patid + "','" + plural + "')";
            var planVal = "";
            DateTime DateSchUpDate = (DateTime)GetFormatedDate(rstRecord["SCH_UPDATE"].ToString());
            var schUpDate = DateSchUpDate.ToString("yyyy-MM-dd HH:mm:ss");

            //------------------------------------
            // 予定指示展開
            //------------------------------------
            TryAddIndDevelopPlan(
                      indId,
                      patid,
                      plural,
                      strDialDate,
                      schUpDate,
                      ntssColumns,
                      mapJson,
                      listErrorPat,
                      ref isCriticalError,
                      ref isConvertError, ref planVal);


            //------------------------------------
            // 条件指示
            //------------------------------------
            TryAddIndDevelopCond(
                      indId,
                      planVal,
                      dialDate,
                      ntssColumns,
                      ref isCriticalError,
                      ref isConvertError, listErrorPat, patid, strDialDate,schUpDate, plural);

            //------------------------------------
            // 投薬指示
            //------------------------------------
            TryAddIndDevelopMedi(row_medi,
                      indId,
                      planVal,
                      dialDate,
                      ntssColumns,
                      ref isCriticalError,
                      ref isConvertError, listErrorPat, patid);

            //------------------------------------
            // 材料指示
            //------------------------------------

            TryAddIndDevelopEquip(
                     indId,
                     planVal,
                     dialDate,
                     ntssColumns,
                     ref isCriticalError,
                     ref isConvertError, listErrorPat, patid, strDialDate, schUpDate, plural);



            //------------------------------------
            // 指示簿指示
            //------------------------------------
            TryAddIndDevelopComment(
                     indId,
                     planVal,
                     dialDate,
                     ntssColumns,
                     ref isCriticalError,
                     ref isConvertError, listErrorPat, patid, strDialDate, schUpDate, plural);

            

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
                isCriticalError = false;
                return;
            }
            if (isConvertError)
            {
                listErrorPat.Add(patid);
                // 次の予定レコードへ
                return;
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
                isCriticalError = false;
                return;
            }
            if (isConvertError)
            {
                listErrorPat.Add(patid);
                // 次の予定レコードへ
                return;
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
                sb.Append(strDialDate);
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
                isCriticalError = false;
                return;
            }
            if (isConvertError)
            {
                listErrorPat.Add(patid);
                // 次の予定レコードへ
                return;
            }
        }

        public List<string> GetSchindid(
            List<string> listSelectedPatId)
        {

            List<string> Listindid = new List<string>();
            var listInClauseParam = CommonFunc.BuildParameterizedInCondition("PATID", 1000, listSelectedPatId, "P_");
            // 予定指示取得
            Listindid = SetDialysisDataDatle(ConvertControl.FNW_TABLE_IND_DIALYSIS_PLAN,
                listInClauseParam,
                Listindid,
                listSelectedPatId);
            // 条件指示取得
            Listindid = SetDialysisDataDatle(ConvertControl.FNW_TABLE_IND_DIALYSIS_COND,
               listInClauseParam,
               Listindid,
               null);
            // 投薬指示取得
            Listindid = SetDialysisDataDatle(ConvertControl.FNW_TABLE_IND_DIALYSIS_MEDI,
               listInClauseParam,
               Listindid,
               null);
            // 材料指示取得
            Listindid = SetDialysisDataDatle(ConvertControl.FNW_TABLE_IND_DIALYSIS_EQUIP,
               listInClauseParam,
               Listindid,
               null);
            // 指示簿指示取得
            Listindid = SetDialysisDataDatle(ConvertControl.FNW_TABLE_IND_DIALYSIS_ADD,
               listInClauseParam,
               Listindid,
               null);
            // 指示装置設定取得
            Listindid = SetDialysisDataDatle(ConvertControl.FNW_TABLE_PAT_DEVICE_SET,
               listInClauseParam,
               Listindid,
               null);
            // 風袋補正取得
            Listindid = SetDialysisDataDatle(ConvertControl.FNW_TABLE_PAT_REVISE_TARE,
               listInClauseParam,
               Listindid,
               null);
            // 除水補正取得
            Listindid = SetDialysisDataDatle(ConvertControl.FNW_TABLE_PAT_REVISE_OFFWATER,
               listInClauseParam,
               Listindid,
               null);

            Listindid = Listindid.Distinct().ToList();
            return Listindid;

        }

        public List<string> GetRstindid(
            List<string> listSelectedPatId
           )
        {
            // パラメータを1000個ずつに分けて取得
            var listInClauseParam = CommonFunc.BuildParameterizedInCondition("PATID", 1000, listSelectedPatId, "P_");
            List<string> Listindid = new List<string>();
            // 予定指示展開取得
            Listindid = SetDialysisDataDatle(ConvertControl.FNW_TABLE_IND_DEVELOP_PLAN,
                listInClauseParam,
                Listindid,
                null);
            // 条件指示展開取得
            Listindid = SetDialysisDataDatle(ConvertControl.FNW_TABLE_IND_DEVELOP_COND,
               listInClauseParam,
               Listindid,
               null);
            // 投薬指示展開取得
            Listindid = SetDialysisDataDatle(ConvertControl.FNW_TABLE_IND_DEVELOP_MEDI,
               listInClauseParam,
               Listindid,
               null);
            // 材料指示展開取得
            Listindid = SetDialysisDataDatle(ConvertControl.FNW_TABLE_IND_DEVELOP_EQUIP,
               listInClauseParam,
               Listindid,
               null);

            // 指示簿指示展開取得
            Listindid = SetDialysisDataDatle(ConvertControl.FNW_TABLE_IND_DEVELOP_ADD,
             listInClauseParam,
             Listindid,
             null);

            Listindid = Listindid.Distinct().ToList();
            return Listindid;

        }

        public List<string> GetRstdialNo(
           List<string> listSelectedPatId,
           string rstDialysisAddCond,
           string rstDialysisCond,
           string rstDislysisPatLiftListCond)
        {

            List<string> RstdialNo = new List<string>();

            // パラメータを1000個ずつに分けて取得
            //var listInClauseParam = SplitListValueForSqlInClause(listSelectedPatId);
            var listInClauseParam = CommonFunc.BuildParameterizedInCondition("RD.PATID", 1000, listSelectedPatId, "P_");
            // 2023-04-12 ADDED BY 周トウ　START
            // 実績データに変更するのDIALYSIS_NOリストを取得追加
            // 透析実績透析条件取得
            RstdialNo = SetDialysisNoData(ConvertControl.FNW_TABLE_RST_DIALYSIS_COND,
                listInClauseParam,
                rstDialysisAddCond,
                RstdialNo);
            // 透析実績投薬取得
            RstdialNo = SetDialysisNoData(ConvertControl.FNW_TABLE_RST_DIALYSIS_MEDICATION,
               listInClauseParam,
               rstDialysisAddCond,
               RstdialNo);
            // 透析実績医材取得
            RstdialNo = SetDialysisNoData(ConvertControl.FNW_TABLE_RST_DIALYSIS_EQUIP,
               listInClauseParam,
               rstDialysisAddCond,
               RstdialNo);
            // 透析実績指示簿取得
            RstdialNo = SetDialysisNoData(ConvertControl.FNW_TABLE_RST_DIALYSIS_ADDITION,
               listInClauseParam,
               rstDialysisAddCond,
               RstdialNo);

            // 透析実績医材取得
            RstdialNo = SetDialysisNoData(ConvertControl.FNW_TABLE_RST_DIALYSIS_TREATMENT,
             listInClauseParam,
             rstDialysisAddCond,
             RstdialNo);

            // 透析実績愁訴処置
            RstdialNo = SetDialysisNoData(ConvertControl.FNW_TABLE_RST_DIALYSIS_COMPLAINT,
             listInClauseParam,
             rstDialysisAddCond,
             RstdialNo);

            // 透析実績愁訴処置_処置者
            RstdialNo = SetDialysisNoData(ConvertControl.FNW_TABLE_RST_DIALYSIS_TREAT_PERSON,
             listInClauseParam,
             rstDialysisAddCond,
             RstdialNo);

            // 加算情報
            RstdialNo = SetDialysisNoData(ConvertControl.FNW_TABLE_RST_RECEIPT_MEMO,
             listInClauseParam,
             rstDialysisAddCond,
             RstdialNo);

            // 透析実績風袋補正取得
            RstdialNo = SetDialysisNoData(ConvertControl.FNW_TABLE_RST_DIALYSIS_TARE_BEFORE,
             listInClauseParam,
             rstDialysisAddCond,
             RstdialNo);

            RstdialNo = SetDialysisNoData(ConvertControl.FNW_TABLE_RST_DIALYSIS_TARE_AFTER,
             listInClauseParam,
             rstDialysisAddCond,
             RstdialNo);

            // 透析実績除水補正取得
            RstdialNo = SetDialysisNoData(ConvertControl.FNW_TABLE_RST_DIALYSIS_WATER_REMOVE,
             listInClauseParam,
             rstDialysisAddCond,
             RstdialNo);

           

            // 2023-04-12 ADDED BY 周トウ　END

            // 透析実績測定体重
            string diffSql = DiffRstWeightHst(CommonConfig.seriesCd);
            RstdialNo = SetDialysisNoData(ConvertControl.FNW_TABLE_RST_DIALYSIS_WEIGHT,
             listInClauseParam,
             rstDialysisAddCond,
             RstdialNo,
             diffSql, rstDialysisCond);

            // add zl start
            // 透析実績回診記録
            RstdialNo = SetDialysisNoData(ConvertControl.FNW_TABLE_PAT_LIFE_LIST,
             listInClauseParam,
             rstDislysisPatLiftListCond,
             RstdialNo);
            // add zl end

            RstdialNo = RstdialNo.Distinct().ToList();
            return RstdialNo;

        }

        /// <summary>
        /// 透析系テーブル取得
        /// </summary>
        /// <param name="targetTableName">取得対象テーブル名</param>
        /// <param name="listParam">SQLパラメータリスト</param>
        /// <param name="startDate">対象期間(開始日)</param>
        /// <param name="endDate">対象期間(終了日)</param>
        /// <param name="endDate">対象期間(終了日)</param>
        /// <param name="addCondition">
        /// 追加条件
        /// 現状：
        /// SCH_DIALYSIS_PLAN.sql
        /// RST_DIALYSIS.sql
        /// のコンバート履歴を参照して完了済の患者IDは処理しない条件用
        /// </param>
        /// <returns>成功：true、失敗：false</returns>
        private List<string> SetDialysisDataDatle(string targetTableName,
            InClauseResult listInClauseParam,
            List<string> Listindid,
            List<string> listSelectedPatId)
        {

            // 取得対象テーブル用SQLのパスを設定
            var sqlFilePath = CreateSqlPathString(sqlDirectory + "_diff", targetTableName);
            if (sqlFilePath == null)
            {
                return Listindid;
            }

            // パラメータを1000個ずつに分けて取得
            var resultTable = DiffProcSql(db, sqlFilePath, listInClauseParam, listSelectedPatId);

            
            if (resultTable.Rows.Count == 0 || resultTable == null)
            {
                // 全パラメータで回しても元データが存在しない場合
                WriteTraceLog("コンバート元データが存在しません。(テーブル名：{0})", targetTableName);
            }
            Listindid.AddRange(resultTable.AsEnumerable().Select(r => r["IND_ID"].ToString()).ToList<string>().Distinct().ToList());
            return Listindid;
        }

        private static DataTable DiffProcSql(DBCtrl db, string sqlFilePath, InClauseResult listInClauseParam,List<string> listSelectedPatId)
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
                    //add  7997  zc start
                    if (CacheInformation.Instance.FacilityCd.Equals("0"))
                    {
                        sql = ConditionRegex.Replace(sql, "  1=1");
                        //7997 start 
                        if (sqlFilePath.Contains("ord_main_diff\\IND_DIALYSIS_PLAN.sql"))
                        {
                            sql = sql.Replace("{whereOrSql}", "");
                        }
                        //7997 end
                    }
                    else
                    {
                        sql = sql.Replace("'{SERIES_CD}'", ":SERIES_CD");
                        //add 7997 start
                        if (sqlFilePath.Contains("ord_main_diff\\IND_DIALYSIS_PLAN.sql"))
                        {

                            StringBuilder sb = new StringBuilder();
                            foreach (PatProcInfo pp in CommonConfig.patProcInfoList)
                            {
                                string patId = pp.PatId;
                                if (listSelectedPatId.Contains(patId))
                                {
                                    string procDate = pp.ProcDate;
                                    sb.Append(" OR (PATID = '")
                                      .Append(patId)
                                      .Append("' AND IND_START_DATE >= '")
                                      .Append(procDate)
                                      .Append("')");
                                }

                            }
                            string whereOrSql = sb.ToString();
                            sql = sql.Replace("{whereOrSql}", whereOrSql);

                        }
                        //add 7997 end
                    }

                    sql = string.Format(sql, listInClauseParam.Clause);
                    //add  7997  zc end

                    // mod #10418 start 
                    IMakeSqlParameters Sqlparam = db.GetIMakeSqlParameters();
                    if (sql.Contains(":facility_cd"))
                    {
                        Sqlparam.AddParam(":facility_cd", CommonConfig.FacilityCd);
                    }
                    if (sql.Contains(":CONVERT_DATETIME"))
                    {
                        Sqlparam.AddParam(":CONVERT_DATETIME", CacheInformation.Instance.GetEffectiveConvertDatetime("ORD").ConvertDatetime);
                    }

                    if (sql.Contains(":MST_DIFF_DATETIME"))
                    {
                        Sqlparam.AddParam(":MST_DIFF_DATETIME", CommonConfig.MST_DIFF_DATETIME.ToString());
                    }
                    if (sql.Contains(":SERIES_CD"))
                    {
                        Sqlparam.AddParam(":SERIES_CD", CommonConfig.seriesCd);
                    }
                    foreach (var p in listInClauseParam.Parameters)
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


        // 2023-04-17 ADDED BY 周トウ　START
        /// <summary>
        /// Diff用のDialysisNoリスト取得
        /// </summary>
        /// <param name="targetTableName">取得対象テーブル名</param>
        /// <param name="listParam">SQLパラメータリスト</param>
        /// <param name="startDate">対象期間(開始日)</param>
        /// <param name="endDate">対象期間(終了日)</param>
        /// <param name="endDate">対象期間(終了日)</param>
        /// <param name="addCondition">
        /// 追加条件
        /// 現状：
        /// SCH_DIALYSIS_PLAN.sql
        /// RST_DIALYSIS.sql
        /// のコンバート履歴を参照して完了済の患者IDは処理しない条件用
        /// </param>
        /// <returns>Diff用のDialysisNoリスト</returns>
        private List<string> SetDialysisNoData(string targetTableName,
           InClauseResult listInClauseParam,
            string addCondition,
            List<string> ListDialysisId,
            string diffSql = "",
            string rstDialysisCond = "")
        {

            // 取得対象テーブル用SQLのパスを設定
            var sqlFilePath = CreateSqlPathString(sqlDirectory + "_diff", targetTableName);
            if (sqlFilePath == null)
            {
                return ListDialysisId;
            }

            // RST_DIALYSIS_WEIGHT差分
            if (rstDialysisCond != "" && diffSql != "")
            {
                diffSql = $"SELECT dialysis_no FROM ({diffSql})b where {listInClauseParam.Clause.Replace("RD.PATID", "PATID")} AND {rstDialysisCond} UNION ";
            }
            // SQL実行(期間指定必要)
            // mod  7997 系列施設コードの追加 周 start
             var resultTable = DialysisNoProcSql(db, sqlFilePath, listInClauseParam, listInClauseParam.Clause,addCondition, diffSql);
            // mod  7997 系列施設コードの追加  周 end
            if (resultTable.Rows.Count == 0)
            {
                // 全パラメータで回しても元データが存在しない場合
                WriteTraceLog("コンバート元データが存在しません。(テーブル名：{0})", targetTableName);
            }
            ListDialysisId.AddRange(resultTable.AsEnumerable().Select(r => r["DIALYSIS_NO"].ToString()).ToList<string>().Distinct().ToList());
            return ListDialysisId;
        }

        // 2023-04-17 ADDED BY 周トウ　END



        private static DataTable DialysisNoProcSql(DBCtrl db, string sqlFilePath, InClauseResult listInClauseParam, params string[] param)
        {
            DataTable dt = null;

            string sVALUE = "1";
            if (!string.IsNullOrEmpty(CacheInformation.Instance.FacilityCd))
            {
                sVALUE = CacheInformation.Instance.FacilityCd;
            }
            WriteTraceLog("実行SQL：{0}", sqlFilePath);
            try
            {
                using (var sr = new StreamReader(sqlFilePath))
                {
                    // SQLファイル読込
                    var sql = sr.ReadToEnd().Replace(Environment.NewLine, " ").TrimEnd(';');
                    // パラメータをWHERE句に記述
                    //add  7997  zc start
                    if (sVALUE.Equals("0"))
                    {
                        sql = ConditionRegex.Replace(sql, "  1=1");

                    }
                    else
                    {
                        sql = sql.Replace("'{SERIES_CD}'", ":SERIES_CD");
                    }

                    sql = string.Format(sql,  param);
                    //add  7997  zc end

                    // mod #10418 start 
                    IMakeSqlParameters Sqlparam = db.GetIMakeSqlParameters();
                    if (sql.Contains(":facility_cd"))
                    {
                        Sqlparam.AddParam(":facility_cd", CommonConfig.FacilityCd);
                    }

                    if (sql.Contains(":SERIES_CD"))
                    {
                        Sqlparam.AddParam(":SERIES_CD", CommonConfig.seriesCd);
                    }
                    foreach (var p in listInClauseParam.Parameters)
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


        /// <summary>
        /// 透析系テーブル取得(期間指定不要テーブル)
        /// </summary>
        /// <param name="targetTableName">取得対象テーブル名</param>
        /// <param name="listParam">SQLパラメータリスト</param>
        /// <returns>成功：true、失敗：false</returns>
        private bool SetDialysisData(string tableName, List<string> listParam)
        {
            return SetDialysisData(tableName, listParam, null, null);
        }

        /// <summary>
        /// 透析系テーブル取得
        /// </summary>
        /// <param name="targetTableName">取得対象テーブル名</param>
        /// <param name="listParam">SQLパラメータリスト</param>
        /// <param name="startDate">対象期間(開始日)</param>
        /// <param name="endDate">対象期間(終了日)</param>
        /// <param name="endDate">対象期間(終了日)</param>
        /// <returns>成功：true、失敗：false</returns>
        private bool SetDialysisData(string targetTableName,
            List<string> listParam,
            DateTime? startDate,
            DateTime? endDate)
        {
            return SetDialysisData(targetTableName,
                listParam,
                startDate,
                endDate,
                null);
        }

        private bool SetIndData(string targetTableName,
            List<string> listParam,
            DateTime? startDate,
            DateTime? endDate,
           string key,List<string> slistIndId)
        {
            var sqlFilePath = CreateSqlPathString(sqlDirectory, targetTableName);
            if (sqlFilePath == null)
            {
                return false;
            }
            CommonFunc.InClauseResult inResult = CommonFunc.BuildParameterizedInCondition(key, 1000, slistIndId, "IND_");

            
            var rst = CommonFunc.BuildParameterizedTupleValues(listParam, "P");
            WriteTraceLog("実行SQL：{0}", sqlFilePath);
            try
            {
                using (var sr = new StreamReader(sqlFilePath))
                {
                    // SQLファイル読込
                    var sql = sr.ReadToEnd().Replace(Environment.NewLine, " ").TrimEnd(';');
                    // パラメータをWHERE句に記述
                    //add  7997  zc start
                    if (CacheInformation.Instance.FacilityCd.Equals("0"))
                    {
                        sql = ConditionRegex.Replace(sql, "  1=1");
                    }
                    else
                    {
                        sql = sql.Replace("'{SERIES_CD}'", ":SERIES_CD");
                    }
                    sql = string.Format(sql, rst.Clause, inResult.Clause);
                    //add  7997  zc end

                    // mod #10418 start 
                    IMakeSqlParameters Sqlparam = db.GetIMakeSqlParameters();
                    foreach (var p in inResult.Parameters)
                    {
                        Sqlparam.AddParam(p.Key, p.Value);
                    }

                    foreach (var p in rst.Parameters)
                    {
                        Sqlparam.AddParam(p.Key, p.Value);
                    }
                    Sqlparam.AddParam(":START_DATE", ((DateTime)startDate).ToString("yyyyMMdd"));
                    Sqlparam.AddParam(":END_DATE", ((DateTime)endDate).ToString("yyyyMMdd"));
                    if (sql.Contains(":SERIES_CD")) {
                        Sqlparam.AddParam(":SERIES_CD", CommonConfig.seriesCd);
                    }

                    DataTable resultTable = db.SelectTable(sql, Sqlparam.GetParam());
                    // mod #10418 end
                    if (resultTable == null)
                        // 取得失敗
                        return false;
                    if (resultTable.Rows.Count == 0)
                    {
                        // 全パラメータで回しても元データが存在しない場合
                        WriteTraceLog("コンバート元データが存在しません。(テーブル名：{0})", targetTableName);
                    }

                    // 取得したテーブルを透析系テーブル用連想配列に格納
                    resultTable.TableName = targetTableName;
                    mapFnwDataOrd[targetTableName] = resultTable;
                    return true;
                }
            }
            catch (Exception e)
            {
                WriteErrorLog(e, "コンバート元データ取得に失敗しました。" + sqlFilePath);
                return false;
            }
            
        }


        /// <summary>
        /// 透析系テーブル取得 10418 start
        /// </summary>
        /// <param name="targetTableName">取得対象テーブル名</param>
        /// <param name="listParam">SQLパラメータリスト</param>
        /// <param name="startDate">対象期間(開始日)</param>
        /// <param name="endDate">対象期間(終了日)</param>
        /// <param name="endDate">対象期間(終了日)</param>
        /// <param name="addCondition">
        /// 追加条件
        /// 現状：
        /// SCH_DIALYSIS_PLAN.sql
        /// RST_DIALYSIS.sql
        /// のコンバート履歴を参照して完了済の患者IDは処理しない条件用
        /// </param>
        /// <returns>成功：true、失敗：false</returns>
        private bool SetRstOrIndData(string targetTableName,
            List<string> listParam,
            DateTime? startDate,
            DateTime? endDate,
            string addCondition,string type, List<string> filterRstDialysisListParam, List<string> filterRstIndidListParam)
        {
            var isSuccess = true;
            // 取得対象テーブル用SQLのパスを設定
            var sqlFilePath = CreateSqlPathString(sqlDirectory, targetTableName);
            if (sqlFilePath == null)
            {
                return false;
            }

            var param = db.GetIMakeSqlParameters();
            var listInClauseParam = CommonFunc.BuildSqlInParameterString(listParam, param);


            WriteTraceLog("実行SQL：{0}", sqlFilePath);
            try
            {
                using (var sr = new StreamReader(sqlFilePath))
                {
                    // SQLファイル読込
                    var sql = sr.ReadToEnd().Replace(Environment.NewLine, " ").TrimEnd(';');
                    // パラメータをWHERE句に記述
                    //add  7997  zc start
                    if (CacheInformation.Instance.FacilityCd.Equals("0"))
                    {
                        sql = ConditionRegex.Replace(sql, "  1=1");

                    }
                    else
                    {
                        sql = sql.Replace("'{SERIES_CD}'", ":SERIES_CD");
                    }

                        if (type.Equals("RST"))
                        {
                            if (filterRstDialysisListParam.Count > 0)
                            {
                                // リストからSQLのin句の生成
                                CommonFunc.InClauseResult inRstResult = CommonFunc.BuildParameterizedInCondition("b.DIALYSIS_NO", 1000, filterRstDialysisListParam, "RST_");
                                addCondition = addCondition + " OR " + inRstResult.Clause;
                                foreach (var p in inRstResult.Parameters)
                                {
                                    param.AddParam(p.Key, p.Value);
                                }

                                CommonConfig.ordListRst = MakeInClause("rst.DIALYSIS_NO", 1000, filterRstDialysisListParam);
                            }

                            if (filterRstIndidListParam.Count > 0)
                            {
                                // リストからSQLのin句の生成
                                CommonFunc.InClauseResult inIndResult = CommonFunc.BuildParameterizedInCondition("(SCH_PLAN.PATID || SCH_PLAN.DIALYSIS_DATE || TO_CHAR(SCH_PLAN.PLURAL))", 1000, filterRstIndidListParam, "IND_");
                                addCondition = addCondition + " OR " + inIndResult.Clause;

                                foreach (var p in inIndResult.Parameters)
                                {
                                    param.AddParam(p.Key, p.Value);
                                }
                            }

                        }
                        else {

                            if (filterRstDialysisListParam.Count > 0)
                            {
                                // リストからSQLのin句の生成
                                CommonFunc.InClauseResult inIndResult = CommonFunc.BuildParameterizedInCondition("(TO_CHAR( PATID ) || TO_CHAR( DIALYSIS_DATE ) || TO_CHAR(PLURAL))", 1000, filterRstDialysisListParam, "IND_");
                               // ADD #10739 start
                               CommonConfig.ordListIndId = MakeInClause("(TO_CHAR(IR.PATID ) || TO_CHAR(IR.DIALYSIS_DATE ) || TO_CHAR(IR.PLURAL))", 1000, filterRstDialysisListParam);
                                // ADD #10739 end
                                 addCondition = addCondition + " OR " + inIndResult.Clause;
                                foreach (var p in inIndResult.Parameters)
                                {
                                    param.AddParam(p.Key, p.Value);
                                }
                                //mod #10761 差分コンバートでFNWの治療項目マスタの内容が一部反映されない 孟堅　20240618 start　
                                startDate = CommonConfig.appStartTime;
                                //mod #10761 差分コンバートでFNWの治療項目マスタの内容が一部反映されない 孟堅　20240618 end　
                            }
                            //add #10761 差分コンバートでFNWの治療項目マスタの内容が一部反映されない 孟堅　20240618 start　
                            if (filterRstIndidListParam.Count > 0)
                            {
                                // リストからSQLのin句の生成
                                CommonFunc.InClauseResult inIndResult = CommonFunc.BuildParameterizedInCondition("(TO_CHAR( PATID ) || TO_CHAR( DIALYSIS_DATE ) || TO_CHAR(PLURAL))", 1000, filterRstIndidListParam, "IND1_");
                                addCondition = addCondition + " OR " + inIndResult.Clause;
                                foreach (var p in inIndResult.Parameters)
                                {
                                    param.AddParam(p.Key, p.Value);
                                }
                                startDate = CommonConfig.appStartTime;

                            }
                            //add #10761 差分コンバートでFNWの治療項目マスタの内容が一部反映されない 孟堅　20240618 end
                        }

                    sql = string.Format(sql, listInClauseParam, addCondition);
                    //add  7997  zc end

                    // mod #10418 start 
                    if (sql.Contains(":facility_cd"))
                    {
                        param.AddParam(":facility_cd", CommonConfig.FacilityCd);
                    }

                    if (sql.Contains(":SERIES_CD"))
                    {
                        param.AddParam(":SERIES_CD", CommonConfig.seriesCd);
                    }

                    param.AddParam(":START_DATE", ((DateTime)startDate).ToString("yyyyMMdd"));
                    param.AddParam(":END_DATE", ((DateTime)endDate).ToString("yyyyMMdd"));

                    if (sql.Contains(":CONVERT_DATETIME"))
                    {
                        param.AddParam(":CONVERT_DATETIME", CacheInformation.Instance.GetEffectiveConvertDatetime("ORD").ConvertDatetime);
                    }


                    var  resultTable = db.SelectTable(sql, param.GetParam());
                    // mod #10418 end
                    if (resultTable.Rows.Count == 0 || resultTable == null)
                    {
                        // 全パラメータで回しても元データが存在しない場合
                        WriteTraceLog("コンバート元データが存在しません。(テーブル名：{0})", targetTableName);
                    }
                    // 取得したテーブルを透析系テーブル用連想配列に格納
                    resultTable.TableName = targetTableName;

                    //10112 zc end
                    mapFnwDataOrd[targetTableName] = resultTable;
                    return isSuccess;
                }
            }
            catch (Exception e)
            {
                WriteErrorLog(e, "コンバート元データ取得に失敗しました。" + sqlFilePath);
                return false;
            }

        }
       //add   10418 end


        /// <summary>
        /// 透析系テーブル取得
        /// </summary>
        /// <param name="targetTableName">取得対象テーブル名</param>
        /// <param name="listParam">SQLパラメータリスト</param>
        /// <param name="startDate">対象期間(開始日)</param>
        /// <param name="endDate">対象期間(終了日)</param>
        /// <param name="endDate">対象期間(終了日)</param>
        /// <param name="addCondition">
        /// 追加条件
        /// 現状：
        /// SCH_DIALYSIS_PLAN.sql
        /// RST_DIALYSIS.sql
        /// のコンバート履歴を参照して完了済の患者IDは処理しない条件用
        /// </param>
        /// <returns>成功：true、失敗：false</returns>
        private bool SetDialysisData(string targetTableName,
            List<string> listParam,
            DateTime? startDate,
            DateTime? endDate,
            string addCondition)
        {
            var isSuccess = true;
            // 取得対象テーブル用SQLのパスを設定
            var sqlFilePath = CreateSqlPathString(sqlDirectory, targetTableName);
            if (sqlFilePath == null)
            {
                return false;
            }

            // パラメータを1000個ずつに分けて取得
            var listInClauseParam = SplitListValueForSqlInClause2(listParam);
            var resultTable = new DataTable();

            //#7475 LL START
            var logTable = new DataTable();
            //#7475 LL END
            // 患者ID 1000個ずつでループ
            foreach (var inClauseParam in listInClauseParam)
            {
                DataTable dtTmp = null;
                //#7475 LL START
                DataTable logTmp = null;
                if (startDate == null && endDate == null && !string.IsNullOrEmpty(addCondition))
                {
                    string[] condition = addCondition.Split('@');
                    //dtTmp = ProcSql(db, sqlFilePath, inClauseParam, condition[0]);

                    if (condition.Length > 1)
                    {
                        dtTmp = ProcSql(db, sqlFilePath, inClauseParam, condition[0], condition[1]);
                    }
                    else
                    {
                        dtTmp = ProcSql(db, sqlFilePath, inClauseParam, condition[0]);
                    }
                }
                //#7475 LL END
                else if (startDate == null || endDate == null)
                {
                    // SQL実行(期間指定不要)
                    dtTmp = ProcSql(db, sqlFilePath, inClauseParam);
                }
                else
                {
                    // SQL実行(期間指定必要)
                    // mod  7997 系列施設コードの追加 周 start
                    // dtTmp = ProcSql(db, sqlFilePath, inClauseParam, ((DateTime)startDate).ToString("yyyyMMdd"), ((DateTime)endDate).ToString("yyyyMMdd"), addCondition);
                    dtTmp = ProcSql(db, sqlFilePath, inClauseParam, ((DateTime)startDate).ToString("yyyyMMdd"), ((DateTime)endDate).ToString("yyyyMMdd"), addCondition, CommonConfig.seriesCd);
                    // mod  7997 系列施設コードの追加  周 end
                }
                if (dtTmp == null)
                {
                    // 取得失敗
                    return false;
                }
                resultTable.Merge(dtTmp);

                // #7475 LL START
                if (logTmp != null)
                {
                    logTable.Merge(logTmp);
                }
                // #7475 LL END
            }
            if (resultTable.Rows.Count == 0)
            {
                // 全パラメータで回しても元データが存在しない場合
                WriteTraceLog("コンバート元データが存在しません。(テーブル名：{0})", targetTableName);
            }

            // #7475 LL START
            //if (resultTable.Rows.Count > 0 && logTable.Rows.Count > 0) {
            //    resultTable = MergeLogData(logTable, resultTable);
            //}
            // #7475 LL END

            // 取得したテーブルを透析系テーブル用連想配列に格納
            resultTable.TableName = targetTableName;

            //10112 zc start
            if (targetTableName.Equals("IND_DEVELOP_COND") || targetTableName.Equals("RST_DIALYSIS_COND"))
            {
                
                if (resultTable.Rows.Count > 0)
                {
                    var groupByColumn = targetTableName.Equals("IND_DEVELOP_COND") ? "IND_ID" : "DIALYSIS_NO";
                    var rowIndex = resultTable.AsEnumerable()
                        .GroupBy(r => r[groupByColumn].ToString())
                        .ToDictionary(g => g.Key, g => g.ToLookup(r => r["CTL_NO"].ToString().Trim()));


                    List<string> listID = rowIndex.Keys.ToList();

                    var rowsToRemove = new List<DataRow>();

                    foreach (var item in listID)
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
            
            //10112 zc end
            mapFnwDataOrd[targetTableName] = resultTable;
            return isSuccess;
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

        /// <summary>
        /// 紐付け情報取得(存在確認用に1件のみ返却)
        /// </summary>
        /// <param name="fnwTableName">FNWテーブル名</param>
        /// <param name="fnwColName">FNWカラム名</param>
        /// <param name="ntssColNo">NTSSカラム名</param>
        /// <returns>紐付け情報(1件のみ)</returns>
        public override DataRow GetRelation(string fnwTableName, string fnwColName, string ntssColNo)
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
                // 紐付けレコードが存在しない場合はエラー
                //WriteErrorLog("紐付けテーブル情報取得に失敗しました。(紐付けテーブル：{0} 元テーブル名：{1} 元カラム名：{2})", dtRelation.TableName, fnwTableName, fnwColName);
                // 紐付けレコードが存在しない場合はエラーにせず次のレコードへ処理を移す
                return null;
            }
        }

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

        /// <summary>
        /// 条件指示内容取得
        /// GetTableIndDialysisCondLump関数で取得した
        /// DataRowの
        /// VALUE, VALUE_UPDATE, UNIT, 
        /// VALUE_NAME1, VALUE_NAME2, 
        /// VALUE_NAME3, VALUE_NAME4, 
        /// VALUE_NAME5, VALUE_NAME6, 
        /// VALUE_NAME7, VALUE_NAME8, 
        /// VALUE_NAME9, VALUE_NAME10,
        /// に内容を入れる
        /// </summary>
        /// <param name="logInfo">ログ情報</param>
        /// <param name="rowCond">条件指示データ</param>
        /// <param name="intPos">予定指示表示番</param>
        /// <returns>TRUE：翻訳成功、FALSE：翻訳失敗</returns>
        static private bool GetSettingCondValueNameLump(DataRow rowCond, string intPos)
        {
            // nullチェック
            if (null == rowCond)
            {
                return false;
            }

            // CTL_NO確認
            string strCtlNo = rowCond["CTL_NO"] as string;
            int intCtlNo = 0;
            int.TryParse(strCtlNo, out intCtlNo);

            // 条件指示有効設定CTL_NOリスト取得
            int[] intIndConvMode = (int[])Enum.GetValues(typeof(CommonIndConst.IND_CONV_MODE));
            bool bolMatch = false;
            foreach (int match in intIndConvMode)
            {
                if (match == intCtlNo)
                {
                    bolMatch = true;
                    break;
                }
            }
            if (false == bolMatch)
            {
                // 有効なCTL_NOを設定していない
                return false;
            }

            switch (strCtlNo)
            {
                case CommonIndConst.DialysisCond.COND_VA:
                case CommonIndConst.DialysisCond.COND_TREAT_MODE:
                case CommonIndConst.DialysisCond.COND_ADSORB_EQUIPMENT:
                case CommonIndConst.DialysisCond.COND_ANTICOAGULAN_LIQUID:
                case CommonIndConst.DialysisCond.COND_DIALYZE_LIQUID:
                case CommonIndConst.DialysisCond.COND_REPLENISH_LIQUID:
                case CommonIndConst.DialysisCond.COND_FIRST_FILM:
                case CommonIndConst.DialysisCond.COND_SECOND_FILM:
                    if ((rowCond["VALUE1_NAME"] is string))
                    {
                        rowCond["VALUE1_NAME"] = rowCond["VALUE1_NAME"];
                        rowCond["VALUE2_NAME"] = rowCond["VALUE2_NAME"];
                        rowCond["VALUE1_UNIT"] = rowCond["VALUE1_UNIT"];
                    }
                    break;
                case CommonIndConst.DialysisCond.COND_DIALYZER:
                    if ((rowCond["VALUE1_NAME"] is string))
                    {
                        rowCond["VALUE_1W1N"] = rowCond["VALUE_1W1N"];
                        string strName = rowCond["VALUE1_NAME"] as string;
                        string[] strParams = strName.Split(new string[] { "[", "]" }, StringSplitOptions.None);
                        if ((null != strParams) && (2 <= strParams.Length))
                        {
                            rowCond["VALUE1_NAME"] = strParams[1].Trim();
                            rowCond["VALUE2_NAME"] = strParams[0].Trim();
                        }
                        rowCond["VALUE1_UNIT"] = rowCond["VALUE1_UNIT"];
                    }
                    break;
                case CommonIndConst.DialysisCond.COND_UFR_PROGRAM:
                case CommonIndConst.DialysisCond.COND_NA_PROGRAM:
                case CommonIndConst.DialysisCond.COND_CONCENTRATION_PROGRAM:
                    // プログラム系の設定は条件指示からは取れない
                    break;
                case CommonIndConst.DialysisCond.COND_TOTAL_TIME:
                case CommonIndConst.DialysisCond.COND_DW:
                case CommonIndConst.DialysisCond.COND_TW:
                case CommonIndConst.DialysisCond.COND_REMOVE_WATER_LIMIT:
                case CommonIndConst.DialysisCond.COND_BLOOD_MEASURE:
                case CommonIndConst.DialysisCond.COND_IP_MEASURE:
                case CommonIndConst.DialysisCond.COND_IP_SPEED:
                case CommonIndConst.DialysisCond.COND_IP_MAX_SPEED:
                case CommonIndConst.DialysisCond.COND_DIALYZE_FLOW:
                case CommonIndConst.DialysisCond.COND_DIALYZE_TEMPERATURE:
                case CommonIndConst.DialysisCond.COND_REPLENISH_MEASURE:
                case CommonIndConst.DialysisCond.COND_REPLENISH_TEMPERATURE:
                case CommonIndConst.DialysisCond.COND_IP_POWER_AUTO_OFF_TIME:
                case CommonIndConst.DialysisCond.COND_IP_POWER_OKMONITOR_OFF_TIME:
                case CommonIndConst.DialysisCond.COND_REPLENISH_SPEED:
                    string strFieldName = string.Format("VALUE_1W{0}N", intPos);
                    string strValueAll = rowCond[strFieldName] as string;
                    double dbValueAll = 0;
                    if (true == double.TryParse(strValueAll, out dbValueAll))
                    {
                        rowCond["VALUE_1W1N"] = dbValueAll.ToString();
                    }
                    else
                    {
                        rowCond["VALUE_1W1N"] = rowCond[strFieldName];
                    }
                    break;

                // 透析開始時刻
                case CommonIndConst.DialysisCond.COND_START_TIME:
                    strFieldName = string.Format("VALUE_1W{0}N", intPos);
                    rowCond["VALUE_1W1N"] = rowCond[strFieldName] as string;
                    break;

                default:
                    strFieldName = string.Format("VALUE_1W{0}N", intPos);
                    strValueAll = rowCond[strFieldName] as string;
                    dbValueAll = 0;
                    if (true == double.TryParse(strValueAll, out dbValueAll))
                    {
                        rowCond["VALUE_1W1N"] = dbValueAll.ToString();
                    }
                    else
                    {
                        rowCond["VALUE_1W1N"] = rowCond[strFieldName];
                    }
                    break;
            }

            return true;
        }

        private void ConvertCond(DataRow[] rows, string planVal, ref List<IndicationInfo> list) {
            foreach (DataRow row in rows)
            {
                IndicationCondInfo info = new IndicationCondInfo();
                // 指示情報取得
                string strCtlNo = row["CTL_NO"] as string;
                // 指示項目番号
                info.strCtlNo = strCtlNo;
                // 予定指示が中止されているか
                if ("0" != row["DEL_FLG"] as string)
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
                info.strUpdaterCd = row["UPDATE_STAFF_CD"] as string;

                // 指示者
                info.strIndicatorCd = row["INDICATOR_CD"] as string;

                // 予定作成区分
                info.strOpeIndPlan = row["OPE_IND_PLAN"] as string;

                // 特殊設定フラグ
                info.strSpeIndFlg = row["SPE_IND_FLG"] as string;

                // 更新日
                info.dtIndUpdate = (DateTime)GetFormatedDate(row["UP_DATE"].ToString());

                // 同日複数回
                if (FnwNumber.Is(row["PLURAL"]))
                {
                    info.decPlural = FnwNumber.ToDecimal(row["PLURAL"]);
                }
                else
                {
                    continue;
                }

                // abe オーダ受け対応
                // 連携オーダ番号
                info.strCopOrderNumber = row["COP_ORDER_NUMBER"] as string;
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

        private void ConvertCondByManual(DataRow[] rows, DateTime dtNwDate, string planVal, ref List<IndicationInfo> list) {
            foreach (DataRow row in rows)
            {
                IndicationCondInfo info = new IndicationCondInfo();
                string strSettingValue = GetIndSettingValueForIndCondLump(planVal, row, dtNwDate);
                if (("NONE" == strSettingValue) ||
                     (false == GetSettingCondValueNameLump(row, planVal.Substring(7, 1))))
                {
                    // 指定日にこの条件指示は行われない
                    continue;
                }
                // 指示情報取得
                string strCtlNo = row["CTL_NO"] as string;
                // 指示項目番号
                info.strCtlNo = strCtlNo;
                // 予定指示が中止されているか
                if ("0" != row["DEL_FLG"] as string)
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

                // 単位取得
                if (row.Table.Columns.Contains("VALUE1_UNIT") && row["VALUE1_UNIT"] != null && row["VALUE1_UNIT"] is string)
                {
                    info.strUnit = (string)row["VALUE1_UNIT"];
                }


                if (row.Table.Columns.Contains("VALUE1_NAME") && row["VALUE1_NAME"] != null) {
                    switch (strCtlNo)
                    {
                        // VA
                        // 治療方法
                        // 吸着カラム
                        // 抗凝固剤
                        // 透析液
                        // 補液
                        // 1次膜
                        // 2次膜
                        case CommonIndConst.DialysisCond.COND_VA:
                        case CommonIndConst.DialysisCond.COND_TREAT_MODE:
                        case CommonIndConst.DialysisCond.COND_ADSORB_EQUIPMENT:
                        case CommonIndConst.DialysisCond.COND_ANTICOAGULAN_LIQUID:
                        case CommonIndConst.DialysisCond.COND_DIALYZE_LIQUID:
                        case CommonIndConst.DialysisCond.COND_REPLENISH_LIQUID:
                        case CommonIndConst.DialysisCond.COND_FIRST_FILM:
                        case CommonIndConst.DialysisCond.COND_SECOND_FILM:
                            info.strValueName1 = row["VALUE1_NAME"] as string;
                            break;
                        // ダイアライザ
                        case CommonIndConst.DialysisCond.COND_DIALYZER:
                            info.strValueName1 = row["VALUE1_NAME"] as string;
                            info.strValueName2 = row["VALUE2_NAME"] as string;
                            break;
                    }
                }

                // 更新者
                info.strUpdaterCd = row["UPDATE_STAFF_CD"] as string;
                if (row.Table.Columns.Contains("UPDATE_STAFF_FIRST_NAME") && row["UPDATE_STAFF_FIRST_NAME"] != null
                    && row.Table.Columns.Contains("UPDATE_STAFF_LAST_NAME") && row["UPDATE_STAFF_LAST_NAME"] != null)
                {
                    info.strUpdaterName = row["UPDATE_STAFF_FIRST_NAME"].ToString() + "-" + row["UPDATE_STAFF_LAST_NAME"].ToString();
                }

                // 指示者
                info.strIndicatorCd = row["INDICATOR_CD"] as string; if (row.Table.Columns.Contains("INDICATOR_FIRST_NAME") && row["INDICATOR_FIRST_NAME"] != null
                     && row.Table.Columns.Contains("INDICATOR_LAST_NAME") && row["INDICATOR_LAST_NAME"] != null)
                {
                    info.strIndicatorName = row["INDICATOR_FIRST_NAME"].ToString() + "-" + row["INDICATOR_LAST_NAME"].ToString();
                }

                // 予定作成区分
                info.strOpeIndPlan = row["OPE_IND_PLAN"] as string;

                // 特殊設定フラグ
                info.strSpeIndFlg = row["SPE_IND_FLG"] as string;

                // 更新日
                info.dtIndUpdate = (DateTime)GetFormatedDate(row["UP_DATE"].ToString());

                // 同日複数回
                if (FnwNumber.Is(row["PLURAL"]))
                {
                    info.decPlural = FnwNumber.ToDecimal(row["PLURAL"]);
                }
                else
                {
                    continue;
                }

                // abe オーダ受け対応
                // 連携オーダ番号
                info.strCopOrderNumber = row["COP_ORDER_NUMBER"] as string;
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
            //add #12092 FNWで「DWと同じ」となっている治療予定の目標体重が「DWと同じ」ではない start
            string strDW = list.FirstOrDefault(x => x.strCtlNo == "004")?.strCd;
            string strCD = list.FirstOrDefault(x => x.strCtlNo == "005")?.strCd;
            if (string.Equals(strDW, strCD)) {
                list.FirstOrDefault(x => x.strCtlNo == "005").strCd = "-1";
            }
            //add #12092 FNWで「DWと同じ」となっている治療予定の目標体重が「DWと同じ」ではない end
            List<IndicationInfo> finalList = list;
            foreach (IndicationInfo row in list)
            {
                if (UnitReferenceConvByCtlNoList.ContainsKey(row.strCtlNo))
                {
                    string val = "";
                    UnitReferenceConvByCtlNoList.TryGetValue(row.strCtlNo, out val);
                    IndicationInfo value = finalList.AsEnumerable().Where(ii => ii.strCtlNo.Equals(val)).FirstOrDefault();
                    if (null != value)
                    {
                        if ("013".Equals(row.strCtlNo))
                        {
                            row.strUnit = value.strUnit+ "/h";
                        }
                        else { 
                            row.strUnit = value.strUnit;
                        }
                    }
                }
            }
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
        /// 確認したい日の指示設定値取得
        /// </summary>
        /// <param name="infoPlan">予定指示情報</param>
        /// <param name="rowInd">指示レコード</param>
        /// <param name="dtDate">指示内容確認日</param>
        /// <returns>指示設定値 ※設定しない場合は"NONE"</returns>
        private string GetIndSettingValueForIndCondLump(string planVal, DataRow rowInd, DateTime dtDate)
        {
            // 返却設定値初期化
            string strSettingValue = "NONE";

            if (null == rowInd)
            {
                return strSettingValue;
            }

            // 時分秒切捨て
            dtDate = dtDate.Date;

            // 予定指示が中止されているか
            if ("0" != rowInd["DEL_FLG"] as string)
            {
                return strSettingValue; // 削除フラグが立っているなら指示無し
            }

            // 指示設定値検索
            int intStartBitPos = -1;    // 適用パターン検索開始位置
            int intTargetWeek = -1;     // 当該週数
            int intCycleWeek = 0;       // サイクル週数

            string strIndDayPattern = rowInd["DAY_PATTERN"] as string;
            if (7 == strIndDayPattern.Length)
            {
                intCycleWeek = 1;
            }
            else if (14 == strIndDayPattern.Length)
            {
                intCycleWeek = 2;
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
                if (false == DateTime.TryParseExact(rowInd["IND_START_DATE"] as string, "yyyyMMdd", null, 0, out dtIndStartDate))
                {
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
                else
                {
                    return strSettingValue;
                }
            }

            // 予定指示のデータ表示順を取得
            int intPos = int.Parse(planVal[7].ToString());
            int intSearchPos = intStartBitPos + intPos;

            if ('1' == strIndDayPattern[intSearchPos - 1])
            {
                string strRowIndValue = string.Format("VALUE_1W{0}N", intSearchPos);
                string strRowIndName = string.Format("VALUE{0}_NAME", intSearchPos);
                string strRowIndUnit = string.Format("VALUE{0}_UNIT", intSearchPos);
                // 曜日単位の値を設定する
                strSettingValue = rowInd[strRowIndValue] as string;
                if (rowInd.Table.Columns.Contains(strRowIndName) && rowInd[strRowIndName] != null)
                {
                    rowInd["VALUE_1W1N"] = rowInd[strRowIndValue] as string;
                    rowInd["VALUE1_NAME"] = rowInd[strRowIndName] as string;
                    rowInd["VALUE1_UNIT"] = rowInd[strRowIndUnit] as string;
                }
            }
            return strSettingValue ?? "";
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
            if ("0" != rowInd["DEL_FLG"] as string)
            {
                return strSettingValue; // 削除フラグが立っているなら指示無し
            }

            // 指示簿指示判定
            if (-1 != rowInd.Table.Columns.IndexOf("ADDITION"))
            {
                // 指示簿指示ならこの時点で補足指示内容を返す
                return rowInd["ADDITION"] as string;
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
            string strIndDayPattern = rowInd["DAY_PATTERN"] as string;

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
                    if (false == DateTime.TryParseExact(rowInd["IND_START_DATE"] as string, "yyyyMMdd", null, 0, out dtIndStartDate))
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
                    strSettingValue = rowInd[strRowIndName] as string;
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
                            strSettingValue = rowInd[strRowIndName] as string;
                        }
                    }
                }
            }

            return strSettingValue ?? "";
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
                string strCtlNo = rowEquip["CTL_NO"] as string;
                // 指示項目番号
                info.strCtlNo = strCtlNo;
                // 指示設定値
                info.strIndContents = strSettingValue;

                // 穿刺針区分
                info.strSetting = rowEquip["SETTING"] as string;

                // コード
                info.strCd = rowEquip["EQUIP_CD"] as string;

                // 医療材料名
                if (rowEquip.Table.Columns.Contains("EQUIP_NAME") && rowEquip["EQUIP_NAME"] != null)
                {
                    info.strItem = rowEquip["EQUIP_NAME"].ToString();
                }

                // 単位
                if (rowEquip.Table.Columns.Contains("UNIT") && rowEquip["UNIT"] != null)
                {
                    info.strUnit = rowEquip["UNIT"].ToString();
                }

                // 分類区分(strIndKindに一時格納)
                if (rowEquip.Table.Columns.Contains("EQUIP_GROUP_CD") && rowEquip["EQUIP_GROUP_CD"] != null)
                {
                    info.strIndKind = rowEquip["EQUIP_GROUP_CD"].ToString();
                }

                // 医療材料分類名(strIndClassに一時格納)
                if (rowEquip.Table.Columns.Contains("CLASS_NAME") && rowEquip["CLASS_NAME"] != null)
                {
                    info.strIndClass = rowEquip["CLASS_NAME"].ToString();
                }

                // 更新者
                info.strUpdaterCd = rowEquip["UPDATE_STAFF_CD"] as string;
                if (rowEquip.Table.Columns.Contains("UPDATE_STAFF_FIRST_NAME") && rowEquip["UPDATE_STAFF_FIRST_NAME"] != null
                    && rowEquip.Table.Columns.Contains("UPDATE_STAFF_LAST_NAME") && rowEquip["UPDATE_STAFF_LAST_NAME"] != null)
                {
                    info.strUpdaterName = rowEquip["UPDATE_STAFF_FIRST_NAME"].ToString() + "-" + rowEquip["UPDATE_STAFF_LAST_NAME"].ToString();
                }

                // 指示者
                info.strIndicatorCd = rowEquip["INDICATOR_CD"] as string;
                if (rowEquip.Table.Columns.Contains("INDICATOR_FIRST_NAME") && rowEquip["INDICATOR_FIRST_NAME"] != null
                    && rowEquip.Table.Columns.Contains("INDICATOR_LAST_NAME") && rowEquip["INDICATOR_LAST_NAME"] != null)
                {
                    info.strIndicatorName = rowEquip["INDICATOR_FIRST_NAME"].ToString() + "-" + rowEquip["INDICATOR_LAST_NAME"].ToString();
                }

                // 特殊設定フラグ
                info.strSpeIndFlg = rowEquip["SPE_IND_FLG"] as string;

                // abe オーダ受け対応
                // 連携オーダ番号
                info.strCopOrderNumber = rowEquip["COP_ORDER_NUMBER"] as string;

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
                info.strProcedureCd = rowMedi["PROCEDURE_CD"] as string;

                // 投与時間帯
                info.strTimingCd = rowMedi["TIMING_CD"] as string;

                // コード
                info.strCd = rowMedi["MEDICINE_CD"] as string;
                // セット薬剤使用フラグ
                if ("1" == rowMedi["SET_MEDICINE_FLG"] as string)
                {
                    info.bolSetMediFlg = true;
                }

                // 更新者
                info.strUpdaterCd = rowMedi["UPDATE_STAFF_CD"] as string;
                if (rowMedi.Table.Columns.Contains("UPDATE_STAFF_FIRST_NAME") && rowMedi["UPDATE_STAFF_FIRST_NAME"] != null
                    && rowMedi.Table.Columns.Contains("UPDATE_STAFF_LAST_NAME") && rowMedi["UPDATE_STAFF_LAST_NAME"] != null)
                {
                    info.strUpdaterName = rowMedi["UPDATE_STAFF_FIRST_NAME"].ToString() + "-" + rowMedi["UPDATE_STAFF_LAST_NAME"].ToString();
                }

                // 指示者
                info.strIndicatorCd = rowMedi["INDICATOR_CD"] as string;
                if (rowMedi.Table.Columns.Contains("INDICATOR_FIRST_NAME") && rowMedi["INDICATOR_FIRST_NAME"] != null
                    && rowMedi.Table.Columns.Contains("INDICATOR_LAST_NAME") && rowMedi["INDICATOR_LAST_NAME"] != null)
                {
                    info.strIndicatorName = rowMedi["INDICATOR_FIRST_NAME"].ToString() + "-" + rowMedi["INDICATOR_LAST_NAME"].ToString();
                }

                // 特殊設定フラグ
                info.strSpeIndFlg = rowMedi["SPE_IND_FLG"] as string;

                // コメント
                if ((rowMedi.Table.Columns.Contains("COMMENTS")))
                {
                    info.strComment = rowMedi["COMMENTS"] as string;
                }

                // abe 月1投与対応　詳細設計⑩
                // 月毎投与設定
                if (FnwNumber.Is(rowMedi["COUNT_EVERY_MONTH"]))
                {
                    info.decCntEveryMonth = FnwNumber.ToDecimal(rowMedi["COUNT_EVERY_MONTH"]);
                }

                // 曜日パターン
                info.strDayPattern = rowMedi["DAY_PATTERN"] as string;

                // 初回投与日
                info.dtNextIndDate = (DateTime)GetFormatedDate(rowMedi["DIALYSIS_DATE"].ToString());

                // abe 注射オーダ対応　詳細設計25
                // 連携オーダ番号
                info.strCopOrderNumber = rowMedi["COP_ORDER_NUMBER"] as string;

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

        private void ConvertAdd(DataRow[] rows, DateTime dtNwDate, string planVal,string type,  ref List<IndicationInfo> list)
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
                string addition = rowAdd["ADDITION"].ToString();
                string indid = rowAdd["IND_ID"].ToString();
                if (indidList.Contains((indid + addition)))
                {
                    continue;
                }
                else {
                    indidList.Add(indid + addition);
                }
                if(result.Any(item => item.IndId == indid && item.Addition == addition)) { 
                    var newRow = rows.AsEnumerable().Where(row => row.Field<string>("IND_ID") == indid && row.Field<string>("ADDITION") == addition && row.Field<string>("DEL_FLG") == "0")
                        .OrderByDescending(row => row.Field<Decimal>("CTL_NO")).ThenByDescending(row => row.Field<DateTime>("UP_DATE")).FirstOrDefault();
                    if (newRow != null)
                    {
                        rowAdd["UPDATE_STAFF_CD"] = newRow["UPDATE_STAFF_CD"];//更新者
                        rowAdd["COP_ORDER_NUMBER"] = newRow["COP_ORDER_NUMBER"];//連携オーダ番号
                        rowAdd["SPE_IND_FLG"] = newRow["SPE_IND_FLG"];//登録区分
                        if (type.Equals("IND_DEVELOP_ADD_MANUAL"))
                        {
                            rowAdd["UPDATE_STAFF_LAST_NAME"] = newRow["UPDATE_STAFF_LAST_NAME"];//更新者名_姓
                            rowAdd["UPDATE_STAFF_FIRST_NAME"] = newRow["UPDATE_STAFF_FIRST_NAME"];//更新者名_名
                        }

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
                info.strUpdaterCd = rowAdd["UPDATE_STAFF_CD"] as string;
                if (rowAdd.Table.Columns.Contains("UPDATE_STAFF_FIRST_NAME") && rowAdd["UPDATE_STAFF_FIRST_NAME"] != null
                    && rowAdd.Table.Columns.Contains("UPDATE_STAFF_LAST_NAME") && rowAdd["UPDATE_STAFF_LAST_NAME"] != null) {
                    info.strUpdaterName = rowAdd["UPDATE_STAFF_FIRST_NAME"].ToString() + "-" + rowAdd["UPDATE_STAFF_LAST_NAME"].ToString();
                }

                // 指示者
                info.strIndicatorCd = rowAdd["INDICATOR_CD"] as string;
                if (rowAdd.Table.Columns.Contains("INDICATOR_FIRST_NAME") && rowAdd["INDICATOR_FIRST_NAME"] != null
                    && rowAdd.Table.Columns.Contains("INDICATOR_LAST_NAME") && rowAdd["INDICATOR_LAST_NAME"] != null)
                {
                    info.strIndicatorName = rowAdd["INDICATOR_FIRST_NAME"].ToString() + "-" + rowAdd["INDICATOR_LAST_NAME"].ToString();
                }

                // 特殊設定フラグ
                info.strSpeIndFlg = rowAdd["SPE_IND_FLG"] as string;

                // abe オーダ受け対応
                // 連携オーダ番号
                info.strCopOrderNumber = rowAdd["COP_ORDER_NUMBER"] as string;

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

        /// <summary>
        /// JSON配列となるレコードをNTSSレコードに加工
        /// </summary>
        /// <param name="jsonRecords">元データレコード</param>
        /// <param name="jsonName">JSONデータ名</param>
        /// <param name="ntssColumns">NTSSカラムのリスト</param>
        /// <param name="fnwTableName">FNWテーブル名</param>
        /// <param name="isCriticalError">続行不可エラーフラグ</param>
        /// <param name="isConvertError">データ加工エラーフラグ</param>
        private void ConvertJsonArrayData(DataRow[] jsonRecords, string jsonName, List<NtssColumn> ntssColumns, string fnwTableName, ref bool isCriticalError, ref bool isConvertError)
        {

            // JSONデータのリスト
            List<List<JsonElement>> jsonElementListList = new List<List<JsonElement>>();

            // JSONデータ全格納完了後、紐付け項目ではないが、JSON要素が存在しなければならない場合
            // 要素を作成し、値をnullに設定する。
            // 紐付け情報取得
            DataRow[] drRelationArray = GetRelationArrayByFnwTableNtssInfo(fnwTableName, this.convertTableName, jsonName);
            Dictionary<string, List<JsonElement>> mapJsonTmp;
            //add #9801 djy end
            if (jsonRecords.Length > 0)
            {
                //add10946 start
                if ("ind_cond_info".Equals(jsonName))
                {
                    if (!jsonRecords.Any(row => row["CTL_NO"].ToString() == "001")) {
                        ntssColumns.Add(CreateNtssColumn("ind_treat_start_time", NTSS_DATA_TYPE_CHARACTER_VARYING, null, false));
                    }    
                }
                //add 10946 end
                foreach (DataRow dr in jsonRecords)
                {
                    if ("rst_cond_info".Equals(jsonName)) {
                        if ("006".Equals(dr.Field<string>("CTL_NO"))) { 
                            // 実績：治療方法名
                            ntssColumns.Add(CreateNtssColumn("rst_treatment_name", NTSS_DATA_TYPE_CHARACTER_VARYING, dr.Field<string>("VALUE_NAME1"), false));
                            continue;
                        }
                        if ("39".Equals(dr.Field<string>("CTL_NO"))) {
                            // 実績：DW
                            ntssColumns.Add(CreateNtssColumn("rst_dw", NTSS_DATA_TYPE_CHARACTER_VARYING, dr.Field<string>("VALUE"), false));
                            continue;
                        }
                    }
                    if ("ind_cond_info".Equals(jsonName))
                    {
                        // 指示：DW
                        if ("39".Equals(dr.Field<string>("CTL_NO")))
                        {
                            ntssColumns.Add(CreateNtssColumn("ind_dw", NTSS_DATA_TYPE_CHARACTER_VARYING, dr.Field<string>("VALUE"), false));
                            continue;
                        }
                        // 指示：VAコード
                        if ("2".Equals(dr.Field<string>("CTL_NO")))
                        {
                            ntssColumns.Add(CreateNtssColumn("ind_va_cd", NTSS_DATA_TYPE_INTEGER, dr.Field<string>("VALUE"), false));
                        }
                        // 指示：治療方法コード、指示：治療方法名
                        if ("006".Equals(dr.Field<string>("CTL_NO")))
                        {
                            ntssColumns.Add(CreateNtssColumn("ind_treatment_cd", NTSS_DATA_TYPE_INTEGER, dr.Field<string>("VALUE"), false));
                            ntssColumns.Add(CreateNtssColumn("ind_treatment_name", NTSS_DATA_TYPE_CHARACTER_VARYING, dr.Field<string>("VALUE_NAME1"), false));

                            //string treatItemSql = "SELECT DEVICE_MODE FROM MST_TREAT_ITEM WHERE TREAT_ITEM_CD = '" + dr.Field<string>("VALUE") + "' AND TO_CHAR(REG_DATE, 'yyyy/mm/dd hh24:mi:ss') < '" + dr.Field<DateTime>("UP_DATE").ToString("yyyy/MM/dd HH:mm:ss") + "' ORDER BY REG_DATE DESC";
                            //DataTable treatItem = db.SelectTable(treatItemSql);
                            string value = dr.Field<string>("VALUE");
                            DateTime upDate = dr.Field<DateTime>("UP_DATE");
                            string deviceMode = value.GetCachedDeviceMode(upDate);
                            //if (null != treatItem && treatItem.Rows.Count > 0)
                            if (!string.IsNullOrEmpty(deviceMode))
                            {
                                ntssColumns.Add(CreateNtssColumn("ind_device_mode", NTSS_DATA_TYPE_CHARACTER_VARYING, deviceMode, false));
                            }
                            continue;

                        }
                        // 指示：治療開始時刻
                        if ("001".Equals(dr.Field<string>("CTL_NO")))
                        {
                            ntssColumns.Add(CreateNtssColumn("ind_treat_start_time", NTSS_DATA_TYPE_CHARACTER_VARYING, dr.Field<string>("VALUE").Length > 4 ? dr.Field<string>("VALUE").Substring(0, 4) : dr.Field<string>("VALUE"), false));
                            continue;
                        }
                    }

                    mapJsonTmp = new Dictionary<string, List<JsonElement>>();
                    ConvertRecord(dr, ntssColumns, mapJsonTmp, ref isConvertError);
                    if (isCriticalError || isConvertError)
                    {
                        return;
                    }

                    // 紐付け対象外の空のJSON要素を追加
                    this.AddNotExistsThenEmptyJsonElement(drRelationArray,
                                                        mapJsonTmp,
                                                        jsonName);
                    //add 2020-11/27 FNSI-改修内容 空データを作成した場合のみJSONリストへ追加  う  start
                    if (mapJsonTmp.ContainsKey(jsonName))
                    {
                        jsonElementListList.Add(mapJsonTmp[jsonName]);
                    }
                }
            }
            else
            {
                mapJsonTmp = new Dictionary<string, List<JsonElement>>();
                // 紐付け対象外の空のJSON要素を追加
                this.AddNotExistsThenEmptyJsonElement(drRelationArray,
                                                        mapJsonTmp,
                                                        jsonName);

                // 空データを作成した場合のみJSONリストへ追加
                if (mapJsonTmp.ContainsKey(jsonName))
                {
                    jsonElementListList.Add(mapJsonTmp[jsonName]);
                }
            }

            ntssColumns.Add(CreateNtssColumnForJson(jsonName, NTSS_DATA_TYPE_JSONB, jsonElementListList, false));
        }

        /// <summary>
        /// 指示情報をNTSSカラムに加工
        /// </summary>
        /// <param name="ntssColumns">NTSSカラムのリスト</param>
        /// <param name="jsonName">指示情報のJSONキー名</param>
        /// <param name="listIndInfo">指示ID</param>
        /// <param name="isDevTable">透析予定の設定値</param>
        /// <param name="isConvertError">データ加工エラーフラグ</param>
        /// 
        private void ConvertIndication(List<NtssColumn> ntssColumns, string jsonName, List<IndicationInfo> listIndInfo, bool isDevTable, ref bool isConvertError)
        {
            string indTableName = null;
            string indDevTableName = null;
            switch (jsonName)
            {
                case "ind_cond_info":
                    indDevTableName = ConvertControl.FNW_TABLE_IND_DEVELOP_COND;
                    indTableName = ConvertControl.FNW_TABLE_IND_DIALYSIS_COND;
                    break;

                case "ind_medi_info":
                    indDevTableName = ConvertControl.FNW_TABLE_IND_DEVELOP_MEDI;
                    indTableName = ConvertControl.FNW_TABLE_IND_DIALYSIS_MEDI;
                    break;

                case "ind_equip_info":
                    indDevTableName = ConvertControl.FNW_TABLE_IND_DEVELOP_EQUIP;
                    indTableName = ConvertControl.FNW_TABLE_IND_DIALYSIS_EQUIP;
                    break;

                //case "ind_add_info":
                case "ind_ind_comment_info":
                    indDevTableName = ConvertControl.FNW_TABLE_IND_DEVELOP_ADD;
                    indTableName = ConvertControl.FNW_TABLE_IND_DIALYSIS_ADD;
                    break;
            }

            if (jsonName == "ind_cond_info")
            {
                //add zl start
                if (listIndInfo.Count > 0)
                {
                    // 指示：DW
                    IndicationInfo indDwInfo = listIndInfo.Where(col => "004".Equals(col.strCtlNo)).FirstOrDefault();
                    // mod #10747 条件送信前のデータにind_dwを登録しない zkm start
                    // if (indDwInfo != null)
                    if (isDevTable && indDwInfo != null)
                    // mod #10747 条件送信前のデータにind_dwを登録しない zkm end
                    {
                        ntssColumns.Add(CreateNtssColumn("ind_dw", NTSS_DATA_TYPE_NUMERIC, indDwInfo.strCd, false));
                    }
                    // 指示：VAコード
                    IndicationInfo indVaInfo = listIndInfo.Where(col => "003".Equals(col.strCtlNo)).FirstOrDefault();
                    if (indVaInfo != null)
                    {
                        ntssColumns.Add(CreateNtssColumn("ind_va_cd", NTSS_DATA_TYPE_INTEGER, indVaInfo.strCd, false));
                    }
                    // 指示：治療方法コード、指示：治療方法名
                    IndicationInfo treatItemInfo = listIndInfo.Where(col => "006".Equals(col.strCtlNo)).FirstOrDefault();
                    if (treatItemInfo != null)
                    {
                        ntssColumns.Add(CreateNtssColumn("ind_treatment_cd", NTSS_DATA_TYPE_INTEGER, treatItemInfo.strCd, false));

                        if (!string.IsNullOrEmpty(treatItemInfo.strCd))
                        {
                            
                            string value = treatItemInfo.strCd;
                            DateTime upDate = treatItemInfo.dtIndUpdate;
                            string name = value.GetCachedTreatItemName(upDate);
                            if (isDevTable) {
                                if (!string.IsNullOrEmpty(name))
                                {
                                    ntssColumns.Add(CreateNtssColumn("ind_treatment_name", NTSS_DATA_TYPE_CHARACTER_VARYING, name, false));
                                }
                                string deviceMode = value.GetCachedDeviceMode(upDate);
                                if (!string.IsNullOrEmpty(deviceMode))
                                {
                                    ntssColumns.Add(CreateNtssColumn("ind_device_mode", NTSS_DATA_TYPE_CHARACTER_VARYING, deviceMode.ToString(), false));
                                }

                            }
                            
                        }

                        //add 8262 zc start
                        List<IndicationInfo> IndInfo = new List<IndicationInfo>();
                        
                        foreach (var indInfo in listIndInfo)
                        {
                            
                            if (!treatItemInfo.strCd.ContainsCondCtlNo(indInfo.strCtlNo))
                            {
                                //add #12092 FNWで「DWと同じ」となっている治療予定の目標体重が「DWと同じ」ではない start
                                if (indInfo.strCtlNo.Equals("005")) {
                                    if (string.Equals(indDwInfo.strCd, indInfo.strCd)) {
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
                    // 指示：治療開始時刻
                    IndicationInfo startTimeInfo = listIndInfo.Where(col => "001".Equals(col.strCtlNo)).FirstOrDefault();
                    if (startTimeInfo != null)
                    {
                        if (!string.IsNullOrEmpty(startTimeInfo.strCd) && startTimeInfo.strCd.Length >= 4)
                        {
                            ntssColumns.Add(CreateNtssColumn("ind_treat_start_time", NTSS_DATA_TYPE_CHARACTER_VARYING, startTimeInfo.strCd.Substring(0, 4), false));
                        }
                        else {
                            ntssColumns.Add(CreateNtssColumn("ind_treat_start_time", NTSS_DATA_TYPE_CHARACTER_VARYING, startTimeInfo.strCd, false));
                        }
                    }
                    //add10946 start
                    else
                    {
                        ntssColumns.Add(CreateNtssColumn("ind_treat_start_time", NTSS_DATA_TYPE_CHARACTER_VARYING, null, false));
                    }
                    //add10946 end

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
            ConvertIndInfo(listIndInfo, isDevTable ? indDevTableName + "_MANUAL" : indTableName, jsonName, ntssColumns, ref isConvertError);
        }

        /// <summary>
        /// 指示情報をNTSSカラムに加工
        /// </summary>
        /// <param name="listIndInfo">指示情報のリスト</param>
        /// <param name="jsonName">JSONデータ名</param>
        /// <param name="ntssColumns">NTSSカラムのリスト</param>
        /// <param name="isCriticalError">続行不可エラーフラグ</param>
        /// <param name="isConvertError">データ加工エラーフラグ</param>
        private void ConvertIndInfo(List<IndicationInfo> listIndInfo, string tableName, string jsonName, List<NtssColumn> ntssColumns, ref bool isConvertError)
        {
            // JSONデータのリスト
            List<List<JsonElement>> jsonElementList = new List<List<JsonElement>>();

            DataRow[] drRelationArray = GetRelationArrayByFnwTableNtssInfo(tableName, this.convertTableName, jsonName);

            foreach (var indInfo in listIndInfo)
            {
                List<IndInfoColumn> listExtractIndInfo = null;
                if (indInfo is IndicationPlanInfo)
                {
                    // どの指示種別を選んでも予定指示が含まれているが処理しない
                    continue;
                }
                if (indInfo is IndicationCondInfo)
                {
                    // 移行対象の項目番号かチェック
                    if (false == CtlNoConvList.ContainsKey(indInfo.strCtlNo))
                    {
                        // 追加対象でない
                        continue;
                    }
                }

                listExtractIndInfo = ExtractIndInfo(indInfo, tableName.Contains("_MANUAL"));

                // 展開した情報をコンバート
                var mapJsonTmp = new Dictionary<string, List<JsonElement>>();
                foreach (IndInfoColumn extractIndInfo in listExtractIndInfo)
                {
                    
                    var relation = GetRelation(tableName, extractIndInfo.name, null);
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

       

        

        /// <summary>
        /// 指示情報内のコンバート対象データを取り出す
        /// </summary>
        /// <param name="indInfo">指示情報</param>
        /// <returns>取り出した指示情報のリスト</returns>
        /// <param name="isManual">手動実際作成が予定と関連(true: 関連する、false: 関連しない)</param>
        private List<IndInfoColumn> ExtractIndInfo(IndicationInfo indInfo, bool isManual)
        {
            var list = new List<IndInfoColumn>();
            if (indInfo is IndicationPlanInfo)
            {
                ExtractIndInfoPlan(list, indInfo as IndicationPlanInfo);
            }
            else if (indInfo is IndicationCondInfo)
            {
                ExtracIndInfoCond(list, indInfo as IndicationCondInfo, isManual);
            }
            else if (indInfo is IndicationMediInfo)
            {
                ExtracIndInfoMedi(list, indInfo as IndicationMediInfo, isManual);
            }
            else if (indInfo is IndicationEquipInfo)
            {
                ExtracIndInfoEquip(list, indInfo as IndicationEquipInfo, isManual);
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

            if (isManual && !(indInfo is IndicationCondInfo && AddCtlNoList.Contains(indInfo.strCtlNo)))
            {
                var indicator = indInfo.strIndicatorName.Split('-');
                mapIndInfo.Add("INDICATOR_FIRST_NAME", indicator[0]); // 指示者名_姓
                mapIndInfo.Add("INDICATOR_LAST_NAME", indicator[1]); // 指示者名_名
                var updater = indInfo.strUpdaterName.Split('-');
                mapIndInfo.Add("UPDATE_STAFF_FIRST_NAME", updater[0]); // 更新者名_姓
                mapIndInfo.Add("UPDATE_STAFF_LAST_NAME", updater[1]); // 更新者名_名

            } else { 
                mapIndInfo.Add("INDICATOR_FIRST_NAME", indInfo.strIndicatorCd); // 指示者名_姓
                mapIndInfo.Add("INDICATOR_LAST_NAME", indInfo.strIndicatorCd); // 指示者名_名
                mapIndInfo.Add("UPDATE_STAFF_FIRST_NAME", indInfo.strUpdaterCd); // 更新者名_姓
                mapIndInfo.Add("UPDATE_STAFF_LAST_NAME", indInfo.strUpdaterCd); // 更新者名_名
            }

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
                { "CYCLE_WEEK", indInfo.decCycleWeek }, // サイクル週数
                { "KUR_NAME", indInfo.strKurName },
                { "BED_NAME", indInfo.strBedName }
            };

            CreateIndInfoColumns(list, mapIndInfo);
        }

        /// <summary>
        /// 条件指示情報内のコンバート対象データを取り出して格納する
        /// </summary>
        /// <param name="list">格納する指示情報のリスト</param>
        /// <param name="indInfo">条件指示情報</param>
        /// <param name="isManual">手動実際作成が予定と関連(true: 関連する、false: 関連しない)</param>
        private void ExtracIndInfoCond(List<IndInfoColumn> list, IndicationCondInfo indInfo, bool isManual)
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
                // mod 7813 limingyang start
                //meditype = indInfo.bolSetMediFlg ? "1" : "0";
                meditype = indInfo.bolSetMediFlg ? "2" : "1";
                // mod 7813 limingyang end
            }

            // Add 8512 調整薬剤 2023/05/12 START
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
            // Add 8512 調整薬剤 2023/05/12 END
            string convValue = "";
            //mod #10401 djy start
            //if (MedicineTypeOtherCtlNoMap.ContainsKey(NtssCtlNo) && UnitConvByMedicineTypeMap.ContainsKey(MedicineTypeOtherCtlNoMap[NtssCtlNo]))
            //{
                //convValue = UnitConvByMedicineTypeMap[MedicineTypeOtherCtlNoMap[NtssCtlNo]];
            //}
            if (MedicineTypeOtherCtlNoMap.ContainsKey(NtssCtlNo) && GetUnitConvByMedicineTypeMap().ContainsKey(MedicineTypeOtherCtlNoMap[NtssCtlNo]))
            {
                convValue = GetUnitConvByMedicineTypeMap()[MedicineTypeOtherCtlNoMap[NtssCtlNo]];
            }
            //mod #10401 djy end

            var mapIndInfo = new Dictionary<string, object>()
            {
                { "CTL_NO", NtssCtlNo }, // 項目番号
                { "VALUE_1W1N", indInfo.strCd }, // 設定値
                { "VALUE_CONV", convValue }, // 設定値 透析液使用数、補液使用数、ワンショット量、持続速度、持続総量の単位取得用
                { "ADD_MEDICINE_TYPE", meditype }, // 薬剤区分
            };

            if (isManual) {
                mapIndInfo.Add("UNIT", indInfo.strUnit);
                mapIndInfo.Add("VALUE_NAME1", indInfo.strValueName1);
                mapIndInfo.Add("VALUE_NAME2", indInfo.strValueName2);
            }

            CreateIndInfoColumns(list, mapIndInfo);
            if (medicineTypeCtlNoList.Contains(NtssCtlNo)) {
                //mod #10401 djy start
                //UnitConvByMedicineTypeMap.Add(NtssCtlNo, indInfo.strCd);
                GetUnitConvByMedicineTypeMap().Add(NtssCtlNo, indInfo.strCd);
                //mod #10401 djy end
            }
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
        /// <param name="isManual">手動実際作成が予定と関連(true: 関連する、false: 関連しない)</param>
        private void ExtracIndInfoMedi(List<IndInfoColumn> list, IndicationMediInfo indInfo, bool isManual)
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
                //mod  #7432 鄭 start 
                { "CTL_NO", indInfo.strCtlNo }, // 項目番号
                //{ "CTL_NO", indInfo.strCtlNo.TrimStart('0') }, // 項目番号
                //mod  #7432 鄭 end 
                { "MEDICINE_CD", indInfo.strCd }, // 薬剤コード
                { "SET_MEDICINE_FLG", indInfo.bolSetMediFlg ? "1" : "0" }, // セット薬剤フラグ
                { "TIMING_CD", indInfo.strTimingCd }, // 穿刺針区分
                { "PROCEDURE_CD", indInfo.strProcedureCd }, // 手技コード
                { "VALUE_1W1N", decAmount }, // 設定値
                { "COMMENTS", indInfo.strComment }, // コメント
                { "DIALYSIS_DATE", indInfo.dtNextIndDate.ToString("yyyyMMdd") },// 初回投与日 TODO BY ZKM
                { "DATE_INTERVAL", dateInterval },
                // add #9686 指示コンバートで終了日ありにも関わらずそれ以降も延長されている zkm start
                { "COUNT_EVERY_MONTH", indInfo.decCntEveryMonth }
                // add #9686 指示コンバートで終了日ありにも関わらずそれ以降も延長されている zkm end
            };
            if (isManual)
            {
                DataRow dr = indInfo.rowIndMedi;
                mapIndInfo.Add("UNIT", dr["UNIT"] as string);
                mapIndInfo.Add("CLASS_NAME", dr["CLASS_NAME"] as string);
                mapIndInfo.Add("SHORT_NAME", dr["CLASS_NAME"] as string);
                mapIndInfo.Add("CLASS_CD", dr["CLASS_CD"] as string);
                mapIndInfo.Add("CLASS_TYPE", dr["CLASS_CD"] as string);
                mapIndInfo.Add("MEDICINE_NAME", dr["MEDICINE_NAME"] as string);
                mapIndInfo.Add("TIMING_NAME", dr["TIMING_NAME"] as string);
                mapIndInfo.Add("PROCEDURE_NAME", dr["PROCEDURE_NAME"] as string);
            }

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
        /// <param name="isManual">手動実際作成が予定と関連(true: 関連する、false: 関連しない)</param>
        private void ExtracIndInfoEquip(List<IndInfoColumn> list, IndicationEquipInfo indInfo, bool isManual)
        {
            var mapIndInfo = new Dictionary<string, object>()
            {
                //{ "CTL_NO", indInfo.strCtlNo }, // 項目番号
                { "EQUIP_CD", indInfo.strCd }, // 医療材料コード
                { "VALUE_1W1N", indInfo.strIndContents }, // 設定値
                { "SETTING", indInfo.strSetting }, // 穿刺針区分
                // del #9686 指示コンバートで終了日ありにも関わらずそれ以降も延長されている zkm start
                //{ "COMMENTS", indInfo.strComment }, // コメント
                // del #9686 指示コンバートで終了日ありにも関わらずそれ以降も延長されている zkm end
                { "EQUIP_TYPE", 0 }, // 医療材料区分
                // del #9686 指示コンバートで終了日ありにも関わらずそれ以降も延長されている zkm start
                //{ "CLASS_CD", indInfo.strCd }, // 医療材料区分
                //{ "CLASS_TYPE", indInfo.strCd }, // 医療材料区分
                //{ "EQUIP_NAME", indInfo.strItem }, // 医療材料名
                // del #9686 指示コンバートで終了日ありにも関わらずそれ以降も延長されている zkm end
            };
            if (isManual)
            {
                mapIndInfo.Add("UNIT", indInfo.strUnit);
                mapIndInfo.Add("CLASS_CD", indInfo.strIndKind);
                mapIndInfo.Add("CLASS_TYPE", indInfo.strIndKind);
                mapIndInfo.Add("CLASS_NAME", indInfo.strIndClass);
                mapIndInfo.Add("EQUIP_NAME", indInfo.strItem);
                mapIndInfo.Add("SHORT_NAME", indInfo.strItem);
            }

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
        private List<JsonElement> GetTargetEquipInfo(NtssColumn ntssColumn, List<string> targetList, string needle_type)
        {
            List<string> cdlist = targetList;
            List<JsonElement> Equip = new List<JsonElement>();

            // 指定コードリストと一致する先頭の医材情報を取得
            foreach (var json in ntssColumn.jsonArray)
            {
                //add 9443 zc start
                if (!string.IsNullOrEmpty(needle_type)) {
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
        /// <param name="rstFlg">透析実際フラグ</param>
        private void setCondData(List<JsonElement> CondJsonList, List<JsonElement> EquipJsonList, bool rstFlg)
        {
            CondJsonList.Where(col => col.keyName.Equals("\"value\"")).First().value = EquipJsonList.Where(col => col.keyName.Equals("\"cd\"")).First().value;
            // add #9686 指示コンバートで終了日ありにも関わらずそれ以降も延長されている zkm start
            CondJsonList.Where(col => col.keyName.Equals("\"unit\"")).First().value = EquipJsonList.Where(col => col.keyName.Equals("\"unit\"")).First().value;
            // add #9686 指示コンバートで終了日ありにも関わらずそれ以降も延長されている zkm end
            CondJsonList.Where(col => col.keyName.Equals("\"value_name_1\"")).First().value = EquipJsonList.Where(col => col.keyName.Equals("\"name\"")).First().value;
            CondJsonList.Where(col => col.keyName.Equals("\"input_class\"")).First().value = EquipJsonList.Where(col => col.keyName.Equals("\"input_class\"")).First().value;
            // add #9686 指示コンバートで終了日ありにも関わらずそれ以降も延長されている zkm start
            // ind_*の場合のみ、指示、更新情報を設定する
            if (!rstFlg) {
                CondJsonList.Where(col => col.keyName.Equals("\"ind_user_id\"")).First().value = EquipJsonList.Where(col => col.keyName.Equals("\"ind_user_id\"")).First().value;
                CondJsonList.Where(col => col.keyName.Equals("\"ind_user_last_name\"")).First().value = EquipJsonList.Where(col => col.keyName.Equals("\"ind_user_last_name\"")).First().value;
                CondJsonList.Where(col => col.keyName.Equals("\"ind_user_first_name\"")).First().value = EquipJsonList.Where(col => col.keyName.Equals("\"ind_user_first_name\"")).First().value;
                CondJsonList.Where(col => col.keyName.Equals("\"upd_user_id\"")).First().value = EquipJsonList.Where(col => col.keyName.Equals("\"upd_user_id\"")).First().value;
                CondJsonList.Where(col => col.keyName.Equals("\"upd_user_last_name\"")).First().value = EquipJsonList.Where(col => col.keyName.Equals("\"upd_user_last_name\"")).First().value;
                CondJsonList.Where(col => col.keyName.Equals("\"upd_user_first_name\"")).First().value = EquipJsonList.Where(col => col.keyName.Equals("\"upd_user_first_name\"")).First().value;
            }
            // add #9686 指示コンバートで終了日ありにも関わらずそれ以降も延長されている zkm end
        }

        /// <summary>
        /// 条件指示に指定医材情報をセット
        /// </summary>
        /// <param name="ntssColumns">NTSSカラム</param>
        /// <returns></returns>
        private bool setDialysisCondFromEquip(List<NtssColumn> ntssColumns,
            String equipInfoJsonName,
            String condInfoJsonName)
        {
            bool rstFlg = equipInfoJsonName.Contains("rst");
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
                List<JsonElement> Equip_Puncture_V = GetTargetEquipInfo(NtssColEquip, this.listNeedleV,"2");
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
                    // edit 血液回路コード最適化 limingyang start
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
                    // edit 血液回路コード最適化 limingyang end
                }

                // 血液回路セット
                if (0 != Equip_BloodCircuit.Count && 0 != Cond_BloodCircuit.Count)
                {
                    setCondData(Cond_BloodCircuit, Equip_BloodCircuit, rstFlg);

                    // セットした医材を削除
                    NtssColEquip.jsonArray.Remove(Equip_BloodCircuit);
                }

                if (SN_use == "1")
                {
                    // 穿刺針SNセット
                    if (0 != Equip_Puncture_SN.Count && 0 != Cond_Puncture_SN.Count)
                    {
                        // 透析条件にセット
                        setCondData(Cond_Puncture_SN, Equip_Puncture_SN, rstFlg);

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
                        setCondData(Cond_Puncture_A, Equip_Puncture_A, rstFlg);

                        // セットした医材を削除
                        NtssColEquip.jsonArray.Remove(Equip_Puncture_A);
                    }

                    // 穿刺針Vセット
                    if (0 != Equip_Puncture_V.Count && 0 != Cond_Puncture_V.Count)
                    {
                        // 透析条件にセット
                        setCondData(Cond_Puncture_V, Equip_Puncture_V, rstFlg);

                        // セットした医材を削除
                        NtssColEquip.jsonArray.Remove(Equip_Puncture_V);
                    }
                }

                //10106 start
                if (NtssColEquip.jsonArray.Count > 0)
                {

                    List<string> list = new List<string>();
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
        /// <summary>
        /// テーブル名と開始日-１ヶ月と終了日＋１ヶ月から
        /// テーブル名DB存在をチェックし、存在するテーブル名のリストを返す
        /// </summary>
        /// <param name="tableName"></param>
        /// <param name="startDate"></param>
        /// <param name="endDate"></param>
        /// <returns></returns>
        private List<string> GetRstWeightHst(DBCtrl db,string tableName, DateTime startDate, DateTime endDate)
        {
            
            List<string> retList = new List<string>();
            string workStartDate = startDate.AddMonths(-1).ToString("yyyyMM");
            string workEndDate = endDate.AddMonths(1).ToString("yyyyMM");
            //mod #10418 start
            string startTableName = $"{tableName}_{workStartDate}";
            string endTableName = $"{tableName}_{workEndDate}";
            var param = db.GetIMakeSqlParameters();
            param.AddParam(":START_TABLE", startTableName);
            param.AddParam(":END_TABLE", endTableName);
            string sql = "SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME BETWEEN :START_TABLE AND :END_TABLE ORDER BY TABLE_NAME";
            DataTable dt = db.SelectTable(sql, param.GetParam());
            //mod #10418 end
            retList = dt.AsEnumerable().Select(r => r["TABLE_NAME"].ToString()).ToList<string>();
            return retList;


        }

        private string CreatePartSQL(List<string> getRstWeightHst, string sVALUE)
        {
            StringBuilder sb = new StringBuilder();
            getRstWeightHst.ForEach(retWeightHst =>{
                sb.Append("SELECT a.patid, a.dialysis_no, MAX(b.up_date) AS maxdate,");
                sb.Append("       b.weight_class, b.measure_weight");
                sb.Append(" FROM RST_DIALYSIS a");
                sb.Append(" INNER JOIN ");
                sb.Append(retWeightHst + " b");
                sb.Append(" ON b.patid = a.patid and b.BED_NO=a.BED_NO　 and  not ( b.measure_weight=b.WHEEL_CHAIR_WEIGHT/1000.00 )");
                sb.Append(" INNER JOIN  MST_KUR k on k.KUR_CD=a.KUR_CD");
                sb.Append(" AND b.up_date between TO_DATE(TO_CHAR(a.ENTER_DATE,'yyyy-MM-dd')||TO_CHAR(TO_DATE(k.KUR_START_TIME,'hh24miss'),'hh24:mi:ss'), 'yyyy-MM-dd hh24:mi:ss') and a.leave_date ");
                sb.Append(" WHERE ");
                sb.Append(" b.weight_class IN ('0', '1') and a.ENTER_DATE is not null and b.WHEEL_CHAIR_FLG in (0,1,2,3)");
                //mod 7997 zc start
                if (sVALUE.Equals("1"))
                {
                    sb.Append(" AND b.series_cd =:SERIES_CD ");
                }
                //mod 7997 zc end
                
                sb.Append(" GROUP BY a.patid, a.dialysis_no, b.weight_class, b.measure_weight ");
                sb.Append(" UNION  ");
            });
            //return sb.ToString().Substring(0, sb.ToString().Length - 11);
            return sb.ToString().Substring(0, sb.ToString().Length - 8);
        } 

        private string CreateAllSQl(List<string> getRstWeightHst, string sVALUE)
        {
          
            StringBuilder sb = new StringBuilder();
            sb.Append("SELECT a.patid, a.dialysis_no,");
            sb.Append(" MAX(CASE WHEN a.weight_class = '0' THEN a.measure_weight END ) AS weight_measure_before,");
            sb.Append(" MAX(CASE WHEN a.weight_class = '1' THEN a.measure_weight END ) AS weight_measure_after");
            sb.Append(" FROM ( ");
            sb.Append(CreatePartSQL(getRstWeightHst, sVALUE));
            sb.Append(" ) a");
            sb.Append(" group by a.patid, a.dialysis_no");
            return sb.ToString();
        }



        private string CreateSimpleLog(List<string> getLogDevLog)
        {
            if (getLogDevLog != null && getLogDevLog.Count > 0)
            {
                StringBuilder cBulider = new StringBuilder();
                getLogDevLog.ForEach(eachLog => {
                    cBulider.Append("SELECT OCCUR_DATE, DEVICE_NO, LOG_NUMBER1, LOG_NUMBER2 ");
                    cBulider.Append(" FROM ");
                    cBulider.Append(eachLog);
                    cBulider.Append(" WHERE TRIM(LOG_CD) = '0106'");
                    cBulider.Append(" UNION  ");
                });
                return cBulider.ToString().Substring(0, cBulider.Length - 8);
            }

            return "SELECT OCCUR_DATE, DEVICE_NO, LOG_NUMBER1, LOG_NUMBER2 FROM LOG_DEV_LOG WHERE TRIM(LOG_CD) = '0106'";
        }


        // #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない ZL start 
        /// <summary>
        /// 透析実績透析条件（指示者、更新者設定）(rst_cond_info、ind_cond_info)
        /// 透析実績投薬（指示開始日、特殊設定フラグ、指示者、編集可能フラグ設定）(rst_medi_info、ind_medi_info)
        /// 透析実績医療材料（指示開始日、特殊設定フラグ、指示者、編集可能フラグ設定）(rst_equip_info、ind_equip_info)
        /// </summary>
        /// <param name="ntssColumns">NTSSカラム</param>
        /// <returns></returns>
        private void SetRstOtherInfoFromIndInfo(List<NtssColumn> ntssColumns,
            String rstInfoJsonName, String indInfoJsonName, String key)
        {

            // 値設定
            if (ntssColumns.Any(col => col.name.Equals(rstInfoJsonName)))
            {
                // 実績
                var ResColCond = ntssColumns.Where(col => col.name.Equals(rstInfoJsonName)).FirstOrDefault();
                // 指示
                var IndColCond = ntssColumns.Where(col => col.name.Equals(indInfoJsonName)).FirstOrDefault();

                if (ResColCond == null || IndColCond == null) {
                    return;
                }

                foreach (var json in ResColCond.jsonArray)
                {
                    // key取得
                    var ResKey = json.Where(col => col.keyName.Equals(key)).First().value.ToString();
                    foreach (var json2 in IndColCond.jsonArray)
                    {
                        var IndKey = json2.Where(col => col.keyName.Equals(key)).First().value.ToString();
                        if (ResKey == IndKey) {
                            // add #9686 指示コンバートで終了日ありにも関わらずそれ以降も延長されている zkm start
                            json.Where(col => col.keyName.Equals("\"input_class\"")).First().value = json2.Where(col => col.keyName.Equals("\"input_class\"")).First().value;
                            // add #9686 指示コンバートで終了日ありにも関わらずそれ以降も延長されている zkm end
                            break;
                        }
                    }
                 }
            }
        }

        /// <summary>
        /// JSONキー：rst_tare_info.afterとbefore
        /// JSONキー：rst_off_water_info
        /// 「String：null→''(empty),Number：null→0」
        /// </summary>
        /// <param name="ntssColumns">NTSSカラム</param>
        /// <param name="jsonName">JSON名</param>
        /// <returns></returns>
        private void RstDialysisDataFormat(List<NtssColumn> ntssColumns, String jsonName)
        {
            if (ntssColumns.Any(col => col.name.Equals(jsonName))) {
                // 透析前/後
                var TareInfo = ntssColumns.Where(col => col.name.Equals(jsonName)).FirstOrDefault();
                if (TareInfo == null){
                    return;
                }

                //　データ取得
                foreach (var json in TareInfo.jsonArray)
                {
                    foreach (var data in json)
                    {
                        var JsonValue = data.value;

                        List<string> wheelTableList = new List<string>()
                        {
                            "wheel_chair_cd",
                            "wheel_chair_name",
                            "wheel_chair_weight"
                        };
                        // 値はnullの場合
                        if ((JsonValue == null || JsonValue.ToString() == "null") && !wheelTableList.Contains(data.getKeyNameDeleteEscape()))
                        {
                            // 「String：null→''(empty)、Number：null→0」
                            var JsonValueType = data.jsonValueType;
                            if (JsonValueType == "string")
                            {
                                data.value = "";
                            }
                            else if (JsonValueType == "number")
                            {
                                data.value = 0;
                            }
                        }
                    }
                }
            }
        }
        // #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない ZL end 

        // mod JSONキーが存在しない場合は、キーを追加し、値をnullに設定する zkm start
        /// <summary>
        /// JSONキーが存在しない場合は、キーを追加し、値をnullに設定する
        /// JSONキー名：ind_medi_info、ind_equip_info、ind_ind_comment_info、rst_medi_info、rst_equip_info、rst_ind_comment_info
        /// </summary>
        /// <param name="ntssColumns">NTSSカラム</param>
        /// <returns></returns>
        private void addKeyWhenKeyNotExist(List<NtssColumn> ntssColumns)
        {
            List<string> addKeyList = new List<string>() { IND_EQUIP_INFO, IND_IND_COMMENT_INFO, IND_MEDI_INFO, RST_MEDI_INFO, RST_EQUIP_INFO, RST_IND_COMMENT_INFO };

            foreach (var jsonKey in addKeyList)
            {
                if (!ntssColumns.Any(col => col.name.Equals(jsonKey)))
                {
                    //ntssColumns.Add(CreateNtssColumn(jsonKey, NTSS_DATA_TYPE_CHARACTER_VARYING, "[]", false));
                    ntssColumns.Add(CreateNtssColumn(jsonKey, NTSS_DATA_TYPE_CHARACTER_VARYING, null, false));
                }
            }
        }
        // mod JSONキーが存在しない場合は、キーを追加し、値をnullに設定する zkm end

        //mod #10761 差分コンバートでFNWの治療項目マスタの内容が一部反映されない 孟堅　20240618 start　
        public List<string> GetPatIdList(
            DateTime startDate,
            DateTime endDateDial,
            string rstDialysisDiffCond,
            string rstDialysisAddCond,
            string rstDislysisPatLiftListCond,
            string schDialysisPlanDeviceCond,
            string schDialysisPlanAddCond,
            DBCtrl db, string rstDialysisCond,
            string patIndApproveCond,
            string ordTreatConditionCond,
            string mstSysTreatCond)
        //mod #10761 差分コンバートでFNWの治療項目マスタの内容が一部反映されない 孟堅　20240618 end　
        {

            List<string> ListPatId = new List<string>();

            // ord_main
            // 指示取得
            ListPatId = getPatIdData(ConvertControl.FNW_ORD_MAIN_IND,
                startDate,
                endDateDial,
                CommonConfig.dialysisPatidTblSql, ListPatId, db);

            // 指示装置設定取得
            ListPatId = getPatIdData(ConvertControl.FNW_TABLE_PAT_DEVICE_SET,
            startDate,
            endDateDial,
            schDialysisPlanDeviceCond, ListPatId, db);

            // 透析実績
            ListPatId = getPatIdData(ConvertControl.FNW_ORD_MAIN_RST,
            startDate,
            endDateDial,
            CommonConfig.dialysisPatidTblSql, ListPatId, db);

            // 実績
            ListPatId = getPatIdData(ConvertControl.FNW_TABLE_RST_DIALYSIS,
            startDate,
            endDateDial,
            rstDialysisCond, ListPatId, db);

            // 透析実績測定体重
            string diffSql = DiffRstWeightHst(CommonConfig.seriesCd, db);
            if (diffSql.Length > 0) {
                diffSql = "SELECT b.patid FROM (" + diffSql + ") b where " + rstDialysisAddCond + " UNION ";
            }
            ListPatId = getPatIdData(ConvertControl.FNW_TABLE_RST_DIALYSIS_WEIGHT,
             startDate,
             endDateDial,
             rstDialysisDiffCond, ListPatId, db, diffSql);

            // 透析実績回診記録
            ListPatId = getPatIdData(ConvertControl.FNW_TABLE_PAT_LIFE_LIST,
             startDate,
             endDateDial,
             rstDislysisPatLiftListCond, ListPatId, db);

            // ord_coop_no
            ListPatId = getPatIdData(ConvertControl.FNW_TABLE_COP_EVENT_MANAGE,
             startDate,
             endDateDial,
             CommonConfig.dialysisPatidTblSql, ListPatId, db);

            // pat_ind_approve
            // add #10800 zkm start
            DateTime indApproveEndDate = new DateTime(CommonConfig.appStartTime.Year, CommonConfig.appStartTime.Month, DateTime.DaysInMonth(CommonConfig.appStartTime.Year, CommonConfig.appStartTime.Month)).AddYears(1);

            ListPatId = getPatIdData(ConvertControl.FNW_TABLE_IND_RECEIVE,
             startDate,
             indApproveEndDate,
             patIndApproveCond, ListPatId, db);
            // mod #10800 zkm end

            //ord_treat_condition
            string workStartDate = DateTime.Now.AddMonths(-3).ToString("yyyyMM");

            //mod #10418 start
            string startTableName = $"RST_SEND_CONDITION_{workStartDate}";
            string endTableName = $"RST_SEND_CONDITION_{endDateDial}";
            var param1 = db.GetIMakeSqlParameters();
            param1.AddParam(":START_TABLE", startTableName);
            param1.AddParam(":END_TABLE", endTableName);
            string sql = "SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME BETWEEN :START_TABLE AND :END_TABLE ORDER BY TABLE_NAME";
            DataTable dt1 = db.SelectTable(sql, param1.GetParam());
            List<string> retList = dt1.AsEnumerable().Select(r => r["TABLE_NAME"].ToString()).ToList<string>();
            //mod #10418 end
            

            if (!retList.Contains("RST_SEND_CONDITION"))
            {
                retList.Add("RST_SEND_CONDITION");
            }

            StringBuilder sb = new StringBuilder();
            retList.ForEach(data =>
            {
                sb.Append("SELECT DISTINCT PATID FROM ");
                sb.Append(data + " rsc");
                sb.Append(" WHERE {3}");
                sb.Append(" UNION  ");
            });

            if (sb.ToString().Length > 0)
            {
                string sqlM = sb.ToString().Substring(0, sb.ToString().Length - 8);

                sqlM = sqlM.Replace("{3}", ordTreatConditionCond);
                //mod #10418 start
                var param = db.GetIMakeSqlParameters();
                if (sqlM.Contains(":facility_cd"))
                    param.AddParam(":facility_cd", this.facilityCd);
                DataTable resultTable = db.SelectTable(sqlM,param.GetParam());
                //mod #10418 end

                for (int i = 0; i < resultTable.Rows.Count; i++)
                {
                    ListPatId.Add(resultTable.Rows[i]["PATID"].ToString());
                }
            }

            // ord_checklist変更がある場合
            ListPatId = DiffRstChecklist(ListPatId, db, startDate, endDateDial, schDialysisPlanAddCond);
            //add #10761 差分コンバートでFNWの治療項目マスタの内容が一部反映されない 孟堅　20240618 start　
            //　治療条件が変更になった場合です
            ListPatId = DiffMstSysTreatCond(ListPatId, db, mstSysTreatCond);
            //add #10761 差分コンバートでFNWの治療項目マスタの内容が一部反映されない 孟堅　20240618 end　
            ListPatId = ListPatId.Distinct().ToList();
            return ListPatId;

        }
        //add #10761 差分コンバートでFNWの治療項目マスタの内容が一部反映されない 孟堅　20240618 start　
        /// <summary>
        /// 治療条件が変更になった場合、影響を受けた患者が取得します。
        /// </summary>
        /// <param name="ListPatId">患者ID</param>
        /// <param name="db">データベース接続</param>
        /// <param name="cond"></param>
        /// 
        /// 
        /// <returns></returns>
        private List<string> DiffMstSysTreatCond(List<string> ListPatId, DBCtrl db, string cond)
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
       　// add #10761 差分コンバートでFNWの治療項目マスタの内容が一部反映されない 孟堅　20240618 end　
        /// <summary>
        /// テーブル名と開始日-１ヶ月と終了日＋１ヶ月から
        /// テーブル名DB存在をチェックし、存在するテーブル名のリストを返す
        /// </summary>
        /// <param name="tableName"></param>
        /// <param name="startDate"></param>
        /// <param name="endDate"></param>
        /// <returns></returns>
        public List<string> GetYmList(DBCtrl db, string tableName, DateTime startDate, DateTime endDate)
        {
            List<string> retList = new List<string>();
            string workStartDate = startDate.AddMonths(-1).ToString("yyyyMM");
            string workEndDate = endDate.AddMonths(1).ToString("yyyyMM");
            if (CommonConfig.isDiff)
            {
                workStartDate = CommonConfig.appStartTime.AddMonths(-3).ToString("yyyyMM");
                workEndDate = endDate.ToString("yyyyMM");
            }
           
            //mod #10418 start 
            string startTableName = $"{tableName}_{workStartDate}";
            string endTableName = $"{tableName}_{workEndDate}";
            var param = db.GetIMakeSqlParameters();
            param.AddParam(":START_TABLE", startTableName);
            param.AddParam(":END_TABLE", endTableName);
            string sql = "SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME BETWEEN :START_TABLE AND:END_TABLE ORDER BY TABLE_NAME";
            DataTable dt = db.SelectTable(sql, param.GetParam());
            //mod #10418 end
            retList = dt.AsEnumerable().Select(r => r["TABLE_NAME"].ToString()).ToList<string>();
            retList.Add(tableName);
            return retList;

        }

        private List<string> DiffRstChecklist(List<string> ListPatId, DBCtrl db, DateTime startDate, DateTime endDate, string cond)
        {
            List<string> targetYmList = GetYmList(db, "RST_CHECKLIST", startDate, endDate);
            // 検索対象テーブル名リストからUNION句を作成
            string unionBlock = string.Join(" UNION ", targetYmList.AsEnumerable().Select(s => "SELECT * FROM " + s).ToArray());

            var sqlFilePath = CreateSqlPathString(Directory.GetCurrentDirectory() + @"\SQL\ord_main_list_diff", "ORD_CHECKLIST_IND");
            if (sqlFilePath == null)
            {
                return ListPatId;
            }
            DateTime preDate = CommonConfig.appStartTime.AddMonths(-3);
            DataTable resultTable = ProcSqlPatid(db, sqlFilePath, new DateTime(preDate.Year, preDate.Month, 1).ToString("yyyyMMdd"),null, unionBlock, cond);

            if (null != resultTable) { 
                foreach (DataRow dr in resultTable.Rows) {
                    ListPatId.Add(dr["PATID"].ToString());
                }
            }
            
            return ListPatId;
        }


        private string DiffRstWeightHst(string seriesCd)
        {
            // RST_WEIGHT_HST
            List<string> retList = new List<string>();
            string sql = "SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME LIKE 'RST_WEIGHT_HST%' ORDER BY TABLE_NAME";
            DataTable dt = db.SelectTable(sql);
            retList = dt.AsEnumerable().Select(r => r["TABLE_NAME"].ToString()).ToList<string>();
            if (retList.Count > 0)
            {
                // seriesCd
                //string sql_cd = "select VALUE from SYNC_FACILITY_CD where SERIES_CD='" + seriesCd + "'";
                string sVALUE = "0";
                if (!string.IsNullOrEmpty(CacheInformation.Instance.FacilityCd))
                {
                    sVALUE = CacheInformation.Instance.FacilityCd;
                }
               
                // sql
                StringBuilder sb = new StringBuilder();
                retList.ForEach(retWeightHst => {
                    sb.Append("SELECT a.patid, a.dialysis_no, b.up_date, a.start_date ");
                    sb.Append(" FROM RST_DIALYSIS a");
                    sb.Append(" INNER JOIN ");
                    sb.Append(retWeightHst + " b");
                    sb.Append(" ON b.patid = a.patid and b.BED_NO=a.BED_NO and not ( b.measure_weight=b.WHEEL_CHAIR_WEIGHT/1000.00 )");
                    sb.Append(" INNER JOIN  MST_KUR k on k.KUR_CD=a.KUR_CD");
                    sb.Append(" AND b.up_date between TO_DATE(TO_CHAR(a.ENTER_DATE,'yyyy-MM-dd')||TO_CHAR(TO_DATE(k.KUR_START_TIME,'hh24miss'),'hh24:mi:ss'), 'yyyy-MM-dd hh24:mi:ss') and a.leave_date ");
                    sb.Append(" WHERE ");
                    sb.Append(" b.weight_class IN ('0', '1') and a.ENTER_DATE is not null and b.WHEEL_CHAIR_FLG in (0,1,2,3)");
                    if (sVALUE.Equals("1"))
                    {
                        sb.Append(" AND b.series_cd = '");
                        sb.Append(seriesCd);
                        sb.Append("'");
                    }
                
                    sb.Append(" UNION  ");
                });
                return sb.ToString().Substring(0, sb.ToString().Length - 8);
            }
            return "";
        }

        private string DiffRstWeightHst(string seriesCd, DBCtrl db)
        {
            // RST_WEIGHT_HST
            //mod #10418 start
            List<string> retList = CommonFunc.GetYmList("RST_WEIGHT_HST", DateTime.Now, DateTime.Now ,db);
            //mod #10418 end

            if (retList.Count > 0) {
                // seriesCd
                string sVALUE = "0";
                if (!string.IsNullOrEmpty(CacheInformation.Instance.FacilityCd))
                {
                   sVALUE = CacheInformation.Instance.FacilityCd;
                }
                
                // sql
                StringBuilder sb = new StringBuilder();
                retList.ForEach(retWeightHst => {
                    sb.Append("SELECT a.patid, a.dialysis_no, b.up_date, a.start_date ");
                    sb.Append(" FROM RST_DIALYSIS a");
                    sb.Append(" INNER JOIN ");
                    sb.Append(retWeightHst + " b");
                    sb.Append(" ON b.patid = a.patid and b.BED_NO=a.BED_NO and not ( b.measure_weight=b.WHEEL_CHAIR_WEIGHT/1000.00 )");
                    sb.Append(" INNER JOIN  MST_KUR k on k.KUR_CD=a.KUR_CD");
                    sb.Append(" AND b.up_date between TO_DATE(TO_CHAR(a.ENTER_DATE,'yyyy-MM-dd')||TO_CHAR(TO_DATE(k.KUR_START_TIME,'hh24miss'),'hh24:mi:ss'), 'yyyy-MM-dd hh24:mi:ss') and a.leave_date ");
                    sb.Append(" WHERE ");
                    sb.Append(" b.weight_class IN ('0', '1') and a.ENTER_DATE is not null and b.WHEEL_CHAIR_FLG in (0,1,2,3)");
                    if (sVALUE.Equals("1"))
                    {
                        sb.Append(" AND b.series_cd = '");
                        sb.Append(seriesCd);
                        sb.Append("'");
                    }
                    
                    sb.Append(" UNION  ");
                });
                return sb.ToString().Substring(0, sb.ToString().Length - 8);
            }
            return "";
        }

        private List<string> getPatIdData(string targetTableName,
         DateTime? startDate,
         DateTime? endDate,
         string addCondition,
         List<string> ListDialysisId,DBCtrl db,
         string diffSql = "", string rstDialysisCond = "")
        {
            var sqlFilePath = CreateSqlPathString(Directory.GetCurrentDirectory() + @"\SQL\ord_main" + "_list_diff", targetTableName);
            if (sqlFilePath == null)
            {
                return ListDialysisId;
            }
            // mod #9797 差分コンバートでFNW側の指示内容を変更してもFNSiの指示履歴に反映されない zs start
            // DataTable resultTable = ProcSql(db, sqlFilePath, "", ((DateTime)startDate).ToString("yyyyMMdd"), ((DateTime)endDate).ToString("yyyyMMdd"), addCondition, CommonConfig.seriesCd, diffSql, rstDialysisCond);
            DataTable resultTable = ProcSqlPatid(db, sqlFilePath,((DateTime)startDate).ToString("yyyyMMdd"), ((DateTime)endDate).AddDays(1).ToString("yyyyMMdd"), addCondition,diffSql, rstDialysisCond);
            // mod #9797 差分コンバートでFNW側の指示内容を変更してもFNSiの指示履歴に反映されない zs end
            for (int i = 0; i < resultTable.Rows.Count; i++)
            {
                ListDialysisId.Add(resultTable.Rows[i]["PATID"].ToString());
            }
            return ListDialysisId;
        }
        //add #10761 差分コンバートでFNWの治療項目マスタの内容が一部反映されない 孟堅　20240618 start　
        /// <summary>
        /// 
        /// </summary>
        /// <param name="listSelectedPatId">患者ID</param>
        /// <param name="cond"></param>
        /// <returns></returns>
        private List<string> GetIndDiffMstSysTreatCondSetting(List<string> listSelectedPatId) {
            List<string> reListIndId = new List<string>();
            DataTable resultTable = new DataTable();
            var sqlFilePath = CreateSqlPathString(Directory.GetCurrentDirectory() + @"\SQL\ord_main_list_diff", "IND_DIFF_MST_SYS_TREAT_COND");
            if (sqlFilePath == null)
            {
                return reListIndId;
            }

            //mod #10418 start
            CommonFunc.InClauseResult listInClauseParam = CommonFunc.BuildParameterizedInCondition("IDC.PATID", 1000, listSelectedPatId, "P_");
            resultTable = DiffProcSql(db, sqlFilePath, listInClauseParam, listSelectedPatId);
            if (resultTable == null)
            {
                // 取得失敗
                return reListIndId;
            }
            else
            {
                foreach (DataRow dr in resultTable.Rows)
                {
                    reListIndId.Add(dr["IND_ID"].ToString());
                }
            }
            //mod #10418 end
            return reListIndId;
        }
        //add #10761 差分コンバートでFNWの治療項目マスタの内容が一部反映されない 孟堅　20240618 end　

        //add #10418 start

        private static DataTable ProcSqlManual(DBCtrl db, string sqlFilePath, params string[] param)
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
                    //add  7997  zc start
                    if (CacheInformation.Instance.FacilityCd.Equals("0"))
                    {
                        sql = ConditionRegex.Replace(sql, "  1=1");

                    }
                    else
                    {
                        sql = sql.Replace("'{SERIES_CD}'", ":SERIES_CD");
                    }

                    sql = string.Format(sql, param);
                    //add  7997  zc end

                    // mod #10418 start 
                    IMakeSqlParameters Sqlparam = db.GetIMakeSqlParameters();
                  
                    if (sql.Contains(":SERIES_CD"))
                    {
                        Sqlparam.AddParam(":SERIES_CD", CommonConfig.seriesCd);
                    }
                    Sqlparam.AddParam(":DIALYSIS_DATE", param[2]);
                    Sqlparam.AddParam(":PATID", param[0]);
                    Sqlparam.AddParam(":PLURAL", param[1]);
                    Sqlparam.AddParam(":SCHUPDATE", param[3]);

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


        private void TryAddIndDevelopPlan(
               string indId,
               string patid,
               string plural,
               string strDialDate,
               string schUpDate,
               List<NtssColumn> ntssColumns,
               Dictionary<string, List<JsonElement>> mapJson,
               List<string> listErrorPat,
               ref bool isCriticalError,
               ref bool isConvertError, ref string planVal)
        {

            DataRow[] indDevPlanRecords = SearchMapFnwDataOrdNew(ConvertControl.FNW_TABLE_IND_DEVELOP_PLAN, indId);
            if (indDevPlanRecords.Length < 1)
            {
                // 展開レコードがない場合、指示にたいしてレコードを取得する
                DataTable dt = ProcSqlManual(db, CreateSqlPathString(sqlDirectory, ConvertControl.FNW_TABLE_IND_DEVELOP_PLAN_MANUAL), patid, plural, strDialDate, schUpDate);
                if (dt != null)
                {

                    dt.TableName = ConvertControl.FNW_TABLE_IND_DEVELOP_PLAN_MANUAL;
                    indDevPlanRecords = dt.Select();
                    planVal = indDevPlanRecords[0]["VALUE"].ToString();
                }
            }
            if (indDevPlanRecords.Length > 0)
            {
                // 予定指示展開されている
                ConvertRecord(indDevPlanRecords[0], ntssColumns, mapJson, ref isConvertError);
                if (isCriticalError)
                {
                    isCriticalError = false;
                    return;
                }
                if (isConvertError)
                {
                    listErrorPat.Add(patid);
                    // 次の予定レコードへ
                    return;
                }
            }
        }

        private void TryAddIndDevelopCond(
            string indId,
            string planVal,
            DateTime dialDate,
            List<NtssColumn> ntssColumns,
            ref bool isCriticalError,
            ref bool isConvertError, List<string> listErrorPat, string patid, string strDialDate,
                 string schUpDate, string plural)
        {

            DataRow[] condRows = SearchMapFnwDataOrdNew(ConvertControl.FNW_TABLE_IND_DEVELOP_COND, indId);
            if (condRows.Length < 1 && !string.IsNullOrEmpty(planVal))
            {
                // 展開レコードがない場合、指示にたいしてレコードを取得する
                DataTable dt = ProcSqlManual(db, CreateSqlPathString(sqlDirectory, ConvertControl.FNW_TABLE_IND_DEVELOP_COND_MANUAL), patid, plural, strDialDate, schUpDate);
                if (dt != null)
                {

                    var rowIndex = dt.AsEnumerable()
                      .GroupBy(r => r["IND_ID"].ToString())
                      .ToDictionary(g => g.Key, g => g.ToLookup(r => r["CTL_NO"].ToString().Trim()));
                    List<string> indID = rowIndex.Keys.ToList();
                    var rowsToRemove = new List<DataRow>();
                    foreach (var item in indID)
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
                        dt.Rows.Remove(row);
                    }
                    List<IndicationInfo> listCondInfo = new List<IndicationInfo>();
                    ConvertCondByManual(dt.Select(), dialDate, planVal, ref listCondInfo);
                    ConvertIndication(ntssColumns, "ind_cond_info", listCondInfo, true, ref isConvertError);
                    //mod #10401 djy start
                    ClearUnitConvByMedicineTypeMap();
                    //mod #10401 djy end

                    //------------------------------------
                    // DW指示
                    //------------------------------------
                    List<IndicationInfo> dwRows = listCondInfo.AsEnumerable().Where(col => "004".Equals(col.strCtlNo)).ToList();
                    if (dwRows.Count > 0 && !string.IsNullOrEmpty(dwRows[0].strCd))
                    {
                        ConvertDwInfo(dwRows[0], "ind_dw_user_info", ntssColumns, ConvertControl.FNW_TABLE_IND_DEVELOP_COND_MANUAL, ref isConvertError);
                        if (isCriticalError)
                        {
                            isCriticalError = false;
                            return;
                        }
                        if (isConvertError)
                        {
                            listErrorPat.Add(patid);
                            // 次の予定レコードへ
                            return;
                        }
                    }
                }
            }
            else if (condRows.Length > 0)
            {
                //add #12092 FNWで「DWと同じ」となっている治療予定の目標体重が「DWと同じ」ではない start
                var row3 = condRows.FirstOrDefault(r => r["CTL_NO"].ToString() == "3");
                var row39 = condRows.FirstOrDefault(r => r["CTL_NO"].ToString() == "39");
                if (row3 != null && row39 != null)
                {
                    if (string.Equals(row3["VALUE"], row39["VALUE"]))
                    {
                        row3["VALUE"] = -1;
                    }
                }
                //add #12092 FNWで「DWと同じ」となっている治療予定の目標体重が「DWと同じ」ではない end
                // 指示展開されている場合は指示展開情報をコンバート
                ConvertJsonArrayData(condRows, "ind_cond_info", ntssColumns, ConvertControl.FNW_TABLE_IND_DEVELOP_COND, ref isCriticalError, ref isConvertError);

                //------------------------------------
                // DW指示
                //------------------------------------
                DataRow[] dwRows = condRows.AsEnumerable().Where(col => "39".Equals(col["CTL_NO"].ToString())).ToArray();
                if (dwRows.Length > 0 && !string.IsNullOrEmpty(dwRows[0].Field<string>("VALUE")))
                {
                    ConvertJsonArrayData(dwRows, "ind_dw_user_info", ntssColumns, ref isCriticalError, ref isConvertError);
                    if (isCriticalError)
                    {
                        isCriticalError = false;
                        return;
                    }
                    if (isConvertError)
                    {
                        listErrorPat.Add(patid);
                        // 次の予定レコードへ
                        return;
                    }
                }
            }
            if (isCriticalError)
            {
                isCriticalError = false;
                return;
            }
            if (isConvertError)
            {
                listErrorPat.Add(patid);
                // 次の予定レコードへ
                return;
            }


        }

        private void TryAddIndDevelopMedi(
            DataRow[] row_medi,
            string indId,
            string planVal,
            DateTime dialDate,
            List<NtssColumn> ntssColumns,
            ref bool isCriticalError,
            ref bool isConvertError, List<string> listErrorPat, string patid)
        {

            DataRow[] mediRows = SearchMapFnwDataOrdNew(ConvertControl.FNW_TABLE_IND_DEVELOP_MEDI, indId);
            if (mediRows.Length < 1 && !string.IsNullOrEmpty(planVal))
            {
                // 展開レコードがない場合、指示にたいしてレコードを取得する
                if (row_medi != null && row_medi.Length != 0)
                {
                    List<IndicationInfo> listMediInfo = new List<IndicationInfo>();
                    ConvertMedi(row_medi, dialDate, planVal, ref listMediInfo);
                    ConvertIndication(ntssColumns, "ind_medi_info", listMediInfo, true, ref isConvertError);
                }
            }
            else if (mediRows.Length > 0)
            {
                // 指示展開されている場合は指示展開情報をコンバート
                ConvertJsonArrayData(mediRows, "ind_medi_info", ntssColumns, ConvertControl.FNW_TABLE_IND_DEVELOP_MEDI, ref isCriticalError, ref isConvertError);

                // 展開レコードがない場合、指示にたいしてレコードを取得する

                if (row_medi != null && row_medi.Length != 0)
                {


                    var table = row_medi[0].Table.Columns;

                    int idx_DEL_FLG = table["DEL_FLG"].Ordinal;
                    int idx_CTL_NO = table["CTL_NO"].Ordinal;
                    int idx_COUNT_EVERY_MONTH = table["COUNT_EVERY_MONTH"].Ordinal;
                    int idx_DAY_PATTERN = table["DAY_PATTERN"].Ordinal;
                    Dictionary<string, string> dateIntervalMap = new Dictionary<string, string>();
                    foreach (DataRow row in row_medi)
                    {
                        if (!"0".Equals(row[idx_DEL_FLG]?.ToString()))
                            continue;
                        decimal cnt = FnwNumber.ToDecimal(row[idx_COUNT_EVERY_MONTH]);
                        string dayPattern = row[idx_DAY_PATTERN] as string;
                        string ctlNo = row[idx_CTL_NO]?.ToString().TrimStart('0');
                        string dateInterval = getDateInterval(cnt, dayPattern);
                        dateIntervalMap.Add(ctlNo, dateInterval);

                    }
                    var ind_mediJsons = ntssColumns.FirstOrDefault(c => c.name == "ind_medi_info");
                    if (ind_mediJsons == null) return;

                    var mediJsons = ind_mediJsons.jsonArray;
                    Dictionary<string, List<JsonElement>> jsonMap = new Dictionary<string, List<JsonElement>>();
                    foreach (List<JsonElement> mediJson in mediJsons)
                    {
                        JsonElement mediElement = mediJson.FirstOrDefault(m => m.getKeyNameDeleteEscape() == "no");
                        string dateInterval = null;
                        if (mediElement != null && dateIntervalMap.TryGetValue(mediElement.getValueDeleteEscape(), out dateInterval))
                        {
                            mediJson.Where(col => "date_interval".Equals(col.getKeyNameDeleteEscape())).FirstOrDefault().value = dateInterval;
                        }
                    }
                }

            }
            if (isCriticalError)
            {
                isCriticalError = false;
                return;
            }
            if (isConvertError)
            {
                listErrorPat.Add(patid);
                // 次の予定レコードへ
                return;
            }

        }
        private void TryAddIndDevelopEquip(
           string indId,
           string planVal,
           DateTime dialDate,
           List<NtssColumn> ntssColumns,
           ref bool isCriticalError,
           ref bool isConvertError, List<string> listErrorPat, string patid, string strDialDate,
                string schUpDate, string strPatidPlural)
        {


            DataRow[] equipRows = SearchMapFnwDataOrdNew(ConvertControl.FNW_TABLE_IND_DEVELOP_EQUIP, indId);
            if (equipRows.Length < 1 && !string.IsNullOrEmpty(planVal))
            {
                // 展開レコードがない場合、指示にたいしてレコードを取得する
                DataTable dt = ProcSqlManual(db, CreateSqlPathString(sqlDirectory, ConvertControl.FNW_TABLE_IND_DEVELOP_EQUIP_MANUAL), patid, strPatidPlural, strDialDate, schUpDate);
                if (dt != null)
                {
                    List<IndicationInfo> listEquipInfo = new List<IndicationInfo>();
                    ConvertEquip(dt.Select(), dialDate, planVal, ref listEquipInfo);
                    ConvertIndication(ntssColumns, "ind_equip_info", listEquipInfo, true, ref isConvertError);
                }
            }
            else if (equipRows.Length > 0)
            {
                // 指示展開されている場合は指示展開情報をコンバート
                ConvertJsonArrayData(equipRows, "ind_equip_info", ntssColumns, ConvertControl.FNW_TABLE_IND_DEVELOP_EQUIP, ref isCriticalError, ref isConvertError);
            }
            if (isCriticalError)
            {
                isCriticalError = false;
                return;
            }
            if (isConvertError)
            {
                listErrorPat.Add(patid);
                // 次の予定レコードへ
                return;
            }

        }

        private void TryAddIndDevelopComment(
           string indId,
           string planVal,
           DateTime dialDate,
           List<NtssColumn> ntssColumns,
           ref bool isCriticalError,
           ref bool isConvertError, List<string> listErrorPat, string patid, string strDialDate,
                string schUpDate, string strPatidPlural)
        {

           DataRow[] indCommentRows = SearchMapFnwDataOrdNew(ConvertControl.FNW_TABLE_IND_DEVELOP_ADD, indId);
            if (indCommentRows.Length < 1 && !string.IsNullOrEmpty(planVal))
            {
                // 展開レコードがない場合、指示にたいしてレコードを取得する
                DataTable dt = ProcSqlManual(db, CreateSqlPathString(sqlDirectory, ConvertControl.FNW_TABLE_IND_DEVELOP_ADD_MANUAL), patid,strPatidPlural, strDialDate, schUpDate);
                if (dt != null)
                {
                    List<IndicationInfo> listIndCommentInfo = new List<IndicationInfo>();
                    ConvertAdd(dt.Select(), dialDate, planVal, "IND_DEVELOP_ADD_MANUAL", ref listIndCommentInfo);
                    ConvertIndication(ntssColumns, "ind_ind_comment_info", listIndCommentInfo, true, ref isConvertError);
                }
            }
            else if (indCommentRows.Length > 0)
            {
                // 指示展開されている場合は指示展開情報をコンバート
                ConvertJsonArrayData(indCommentRows, "ind_ind_comment_info", ntssColumns, ConvertControl.FNW_TABLE_IND_DEVELOP_ADD, ref isCriticalError, ref isConvertError);
            }
            if (isCriticalError)
            {
                isCriticalError = false;
                return;
            }
            if (isConvertError)
            {
                listErrorPat.Add(patid);
                // 次の予定レコードへ
                return;
            }
        }


        private bool TryAddDialysisBaseColumns(
            DataRow rstRecord,
            List<NtssColumn> ntssColumns,
            string rstDialNo,
            DateTime startdate)
        {

            //add FNSI_ADD_DEVICE_NAME空の場合出力しない 楊 start
            var deviceName = rstRecord.Field<string>("ADD_DEVICE_NAME") ?? "";
            if (string.IsNullOrWhiteSpace(deviceName))
            {
                // ADD_DEVICE_NAME空の場合出力しない
                return false;
            }
            //add FNSI_ADD_DEVICE_NAME空の場合出力しない 楊 end

            // 透析番号を追加(手動実績の場合は削除キーとする)
            ntssColumns.Add(CreateNtssColumn("rst_fn_dialysis_no", NTSS_DATA_TYPE_INTEGER, rstDialNo, true));

            // 同日複数回（1回目）
            ntssColumns.Add(CreateNtssColumn("fn_plural", NTSS_DATA_TYPE_INTEGER, "0", false));

            // 治療種別
            ntssColumns.Add(CreateNtssColumn("treat_type", NTSS_DATA_TYPE_INTEGER, "1", false));

            // 透析スケジュールから設定する項目を実績からセット
            // 治療日を追加
            ntssColumns.Add(CreateNtssColumn("treat_date", NTSS_DATA_TYPE_CHARACTER_VARYING, startdate.ToString("yyyyMMdd"), false));
            // 治療曜日
            int treat_week = ((int)startdate.DayOfWeek);
            if (treat_week == 0) treat_week = 7; // 日曜日のみ変換(「0」 ⇒ 「7」)
            ntssColumns.Add(CreateNtssColumn("treat_week", NTSS_DATA_TYPE_CHARACTER_VARYING, treat_week.ToString(), false));
            return true;
        }
        //add #10418 start
        private void TryProcessDialysisResult(
            DataRow rstRecord,
            string indId,
            string rstDialNo,
            ref   List<NtssColumn> ntssColumns)
        {
            // 透析番号を追加(予定に紐付く実績の場合は削除キーとしない)
            ntssColumns.Add(CreateNtssColumn("rst_fn_dialysis_no", NTSS_DATA_TYPE_INTEGER, rstDialNo, false));
            DateTime dialDate = (DateTime)GetFormatedDate(rstRecord["DIALYSIS_DATE"].ToString());
            // 治療日を追加
            ntssColumns.Add(CreateNtssColumn("treat_date", NTSS_DATA_TYPE_CHARACTER_VARYING, dialDate.ToString("yyyyMMdd"), false));
            // 治療曜日
            int treat_week = ((int)dialDate.DayOfWeek);
            if (treat_week == 0) treat_week = 7; // 日曜日のみ変換(「0」 ⇒ 「7」)
            ntssColumns.Add(CreateNtssColumn("treat_week", NTSS_DATA_TYPE_CHARACTER_VARYING, treat_week.ToString(), false));

            DataRow[] ListUpdInfo = SearchMapFnwDataOrdNew(ConvertControl.FNW_TABLE_RST_DIALYSIS_UPD_INFO, indId);
            if (ListUpdInfo.Length == 1)
            {
                var updInfo = ListUpdInfo[0];
                // 最終更新指示者ID
                ntssColumns.Add(CreateNtssColumn("up_ind_user_id", NTSS_DATA_TYPE_CHARACTER_VARYING, updInfo["INDICATOR_CD"].ToString(), false));
                // 最終更新者ID
                ntssColumns.Add(CreateNtssColumn("up_user_id", NTSS_DATA_TYPE_CHARACTER_VARYING, updInfo["UPDATE_STAFF_CD"].ToString(), false));
            }

        }

        private void AddTreatCountColumns(
            DataRow rstRecord,
            List<NtssColumn> ntssColumns)
        {
            var treatTypeObj = rstRecord["TREAT_TYPE"];

            if (treatTypeObj == null)
                return;

            string treatType = treatTypeObj.ToString();

            var dialysisNum = rstRecord["DIALYSIS_NUM"];

            switch (treatType)
            {
                case "1":
                    // 取得した治療分類が'1'の場合に、透析回数をセットする。以外の場合、実績：透析回数にnullをセットする。
                    ntssColumns.Add(
                        CreateNtssColumn(
                            "rst_dialysis_cnt",
                            NTSS_DATA_TYPE_INTEGER,
                            null == dialysisNum ? "" : dialysisNum.ToString(),
                            false));
                    break;

                case "2":
                    // 取得した治療分類が'2'の場合に、透析回数をセットする。以外の場合、実績：特殊浄化回数にnullをセットする。
                    ntssColumns.Add(
                        CreateNtssColumn(
                            "rst_purification_cnt",
                            NTSS_DATA_TYPE_INTEGER,
                            null == dialysisNum ? "" : dialysisNum.ToString(),
                            false));
                    break;
            }

        }

    }
}
