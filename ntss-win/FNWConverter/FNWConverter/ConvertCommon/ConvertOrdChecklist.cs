using ConvertCommon.Common;
using Fnw.IOControl.DB;
using Fnw.IOControl.Log;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace ConvertCommon
{
    sealed public class ConvertOrdChecklist : ConvertBase
    {
        private static readonly Regex ConditionRegex =
    new Regex(@"(\s)([A-Za-z\._]*\s*=\s*'\{4\}')", RegexOptions.Compiled);
        private readonly RelationCacheBase _relationCache;
        private void deleteTempDataByPatIdList(List<string> patIds) {
            //mod #10418 SQLクエリの文字列置換が多用されており、SQLインジェクション攻撃によりDBが壊され脆弱性がある。 start
            var param = db.GetIMakeSqlParameters();

            var inParams = new List<string>();
            for (int i = 0; i < patIds.Count; i++)
            {
                string paramName = ":p" + i;
                inParams.Add(paramName);
                param.AddParam(paramName, patIds[i]);
            }

            string sql = $"DELETE FROM NKK.SYNC_SYS_CHECKLIST  WHERE PATID IN ({string.Join(",", inParams)})";
            db.ExecuteSQL(sql, param.GetParam());

            //mod #10418 SQLクエリの文字列置換が多用されており、SQLインジェクション攻撃によりDBが壊され脆弱性がある。 end
        }

        private void deleteChecklistHisTByPatIdList(List<string> patIds)
        {

            //mod #10418 SQLクエリの文字列置換が多用されており、SQLインジェクション攻撃によりDBが壊され脆弱性がある。 start
            var param = db.GetIMakeSqlParameters();
            var inParams = new List<string>();
            for (int i = 0; i < patIds.Count; i++)
            {
                string paramName = ":p" + i;
                inParams.Add(paramName);
                param.AddParam(paramName, patIds[i]);
            }
            string sql = $"DELETE FROM NKK.SYNC_CHECKLIST_HIST  WHERE PATID IN ({string.Join(",", inParams)})";
            db.ExecuteSQL(sql, param.GetParam());

            //mod #10418 SQLクエリの文字列置換が多用されており、SQLインジェクション攻撃によりDBが壊され脆弱性がある。 end
        }

        public ConvertOrdChecklist() {

            _relationCache = new RelationCacheBase(
              () => "ord_checklist"
          );
        }

		// add #10418 コンバータソースコード改善  吉 start
        private void CreateSyncCKHistTable(List<string> listParam,
                                   DateTime startDate,
                                   DateTime endDate)
        {
            if (listParam.Count < 1)
            {
                return;
            }

            var sqlFilePath = Path.Combine("SQL\\ord_checklist", "SYNC_CHECKLIST_HIST.sql");

            IMakeSqlParameters param = db.GetIMakeSqlParameters();
                                                                                           
            var patientListSqlParts = new List<string>();
            for (int i = 0; i < listParam.Count; i++)
            {
                string pName = $":PAT{i}";
                patientListSqlParts.Add($"SELECT {pName} AS pat_id FROM DUAL");
                param.AddParam(pName, listParam[i]);
            }

            string listInClauseParam = string.Join(" UNION ALL" + Environment.NewLine + "  ", patientListSqlParts);

            var unionSqlParts = new List<string>();

            for (int i = 0; i < CommonConfig.targetYmList.Count; i++)
            {
                string tableName = CommonConfig.targetYmList[i];

                string startParam = $":START{i}";
                string endParam = $":END{i}";

                param.AddParam(startParam, startDate.ToString("yyyyMMdd"));
                param.AddParam(endParam, endDate.ToString("yyyyMMdd"));

                string sqlPart = $@"
                       SELECT PATID,
                       DIALYSIS_NO,
                       DIALYSIS_DATE,
                       OCCUR_DATE,
                       ITEM_NUMBER,
                       STAFF_CD,
                       CODE,
                       LIST_CD,
                       LIST_CD_UP_DATE,
                       RESULT_NO,
                       KUR_CD,
                       C.BED_NO,
                       UP_DATE
                       FROM {tableName} C
                       INNER JOIN MST_BED_LIST B ON C.BED_NO = B.BED_NO
                       WHERE PATID IN (SELECT pat_id FROM patient_list)
                        AND DIALYSIS_DATE BETWEEN {startParam} AND {endParam}
        ";

                unionSqlParts.Add(sqlPart);
            }

            string unionBlock = string.Join(" UNION ALL ", unionSqlParts);

            // 3. SERIES_CD 条件（参数化）
            string sCD = "";
            if (CacheInformation.Instance.FacilityCd.Equals("1"))
            {
                sCD = "WHERE SERIES_CD = :SERIES_CD";
                param.AddParam(":SERIES_CD", CommonConfig.seriesCd);
            }

            LogManager.WriteTraceLog(null, null, "[情報]" + $"実行SQL：{sqlFilePath}");

            try
            {
                string sqlTemplate;
                using (var sr = new StreamReader(sqlFilePath))
                {
                    sqlTemplate = sr.ReadToEnd();
                }

                string finalSql = sqlTemplate
                    .Replace(Environment.NewLine, " ")
                    .Replace("{0}", listInClauseParam)
                    .Replace("{1}", unionBlock)
                    .Replace("{2}", sCD);

                // 执行（安全参数化）
                db.SelectTable(finalSql, param.GetParam());
            }
            catch (Exception e)
            {
                LogManager.WriteErrorLog(null, null, "[エラー] コンバート元データ取得に失敗しました。", e);
            }
        }
        // add #10418 コンバータソースコード改善  吉 end

        /// <summary>
        /// FNWからデータの取得・設定
        /// </summary>
        /// <param name="listSelectedPatId">患者IDリスト</param>
        /// <param name="startDate">開始日時</param>
        /// <param name="endDate">終了日時</param>
        /// <param name="isSync"></param>
        /// <returns></returns>
        public override bool SetFnwData(List<string> listSelectedPatId, DateTime startDate, DateTime endDate, bool isSync)
        {
            WriteTraceLog("===== コンバート元データ取得処理開始 =====");
            // 患者IDリストをコピー(破壊されるため)
            var listSelectedPatIdCopy = new List<string>(listSelectedPatId);
            deleteTempDataByPatIdList(listSelectedPatId);
            CreateSyncCKHistTable(listSelectedPatId, startDate, endDate);

            // SQLファイル取得
            string[] baseTableSqlFile = Directory.GetFiles(sqlDirectory, "SYNC_SYS_CHECKLIST.sql");
            baseTableSqlFile = baseTableSqlFile.Concat(Directory.GetFiles(sqlDirectory, "RST_CHECKLIST_*.sql")).ToArray();
            if (baseTableSqlFile.Length == 0)
            {
                // SQLファイルなし
                WriteErrorLog("コンバート元データ取得用SQLファイルが存在しません。");
                return false;
            }

            string sVALUE = "1";
            if (!string.IsNullOrEmpty(CacheInformation.Instance.FacilityCd))
            {
                sVALUE = CacheInformation.Instance.FacilityCd;
            }

            // add FNSI-差分コンバート対応 楊 start
            if (CommonConfig.isDiff)
            {
                //mod #10418 start
                // 前回実行した時間がコンバート開始時間として実行する
                startDate = CacheInformation.Instance.GetEffectiveConvertDatetime("ORD").ConvertDatetime;
                //mod #10418 start
            }
            // add FNSI-差分コンバート対応 楊 end
            // 選択患者リストからSQLのin句の生成
            //mod #10418 start
            CommonFunc.InClauseResult inResult = CommonFunc.BuildParameterizedInCondition("DIALYSIS.PATID", 1000, listSelectedPatIdCopy,"P_");
            //mod #10418 start
            foreach (string sqlFile in baseTableSqlFile)
            {

                // SQLファイル名から処理対象テーブル名の取得
                var tableName = Path.GetFileNameWithoutExtension(sqlFile);

                WriteTraceLog("実行SQL：{0}", sqlFile);
                try
                {
                    var sb = new StringBuilder();
                    using (var sr = new StreamReader(sqlFile))
                    {
                        // SQLファイル読込
                        
                        sb.Append(sr.ReadToEnd().Replace(Environment.NewLine, " ").TrimEnd(';'));
                        var sql = sb.ToString();
                        if (sVALUE.Equals("0"))
                        {

                            sql = ConditionRegex.Replace(sql, "  1=1");
                        }
                        else {

                            sql = sql.Replace("'{4}'", ":SERIES_CD");
                        }
                        // 取得対象患者IDと取得期間をWHERE句に記述
                        // (終了日の条件はSQL上で「 < 終了日」としているため1日足す)
                        sql = string.Format(sql,inResult.Clause,"");

                        //mod #10418 start
                        var param = db.GetIMakeSqlParameters();
                        foreach (var p in inResult.Parameters)
                        {
                            param.AddParam(p.Key, p.Value);
                        }
                        param.AddParam(":START_DATE", startDate.ToString("yyyyMMdd"));
                        param.AddParam(":END_DATE", endDate.ToString("yyyyMMdd"));

                        if (sql.Contains(":SERIES_CD"))
                            param.AddParam(":SERIES_CD", CommonConfig.seriesCd);

                        dtFnwData = db.SelectTable(sql, param.GetParam());
                        //mod #1418 end 

                        if (dtFnwData == null)
                        {
                            // SQL実行失敗
                            WriteErrorLog("コンバート元データ取得に失敗しました。");
                            deleteTempDataByPatIdList(listSelectedPatId);
                            return false;
                        }

                        dtFnwData.TableName = tableName;

                        // 透析日単位のチェック済みデータを全てチェックアウトになる場合、差分データを作成して、api側には、ord_checklistのデータを削除する
                        // (予定のみチェック状態を変更可能ですので、実際データを対象外です)
                        if (CommonConfig.isDiff && "RST_CHECKLIST_PLAN".Equals(tableName)) {
                            if (dtFnwData.Rows.Count < 1)
                            {
                                DataTable ckDt = GetDateFromChecklist(inResult.Clause, inResult.Parameters, startDate, endDate);
                                foreach (DataRow dr in ckDt.Rows)
                                {
                                    DataRow row = dtFnwData.NewRow();

                                    row["PATID"] = dr["PATID"];
                                    row["IND_ID"] = dr["IND_ID"];

                                    dtFnwData.Rows.Add(row);
                                }
                            }
                            else {
                                var data = dtFnwData.AsEnumerable().GroupBy(row => new { IND_ID = row["IND_ID"], CODE = row["CODE"] })
                                    .Select(group => new { key = group.Key.IND_ID.ToString() + group.Key.CODE.ToString(), count = group.Count() });

                                DataTable ckDt = GetDateFromChecklist(inResult.Clause, inResult.Parameters, startDate, endDate);
                                foreach (DataRow dr in ckDt.Rows)
                                {
                                    var delData = data.Where(d => d.key.Equals(dr["ind_id"].ToString() + dr["code"].ToString())).ToList();
                                    if (delData.Count < 1)
                                    {
                                        DataRow row = dtFnwData.NewRow();
                                        
                                        row["PATID"] = dr["PATID"];
                                        row["IND_ID"] = dr["IND_ID"];

                                        dtFnwData.Rows.Add(row);
                                    }
                                    foreach (var item in data)
                                    {
                                        object key = item.key;
                                        if ((dr["ind_id"].ToString() + dr["code"].ToString()).Equals(key.ToString())
                                            && decimal.Parse(item.count.ToString()) < decimal.Parse(dr["RST_CHECK_COUNT"].ToString())) {
                                           
                                            DataRow row = dtFnwData.NewRow();

                                            row["PATID"] = dr["PATID"];
                                            row["IND_ID"] = dr["IND_ID"];

                                            dtFnwData.Rows.Add(row);
                                        }
                                    }
                                }
                            }
                        }
                    }
                    mapFnwDataOrd[tableName] = dtFnwData;
                }
                catch (Exception e)
                {
                    WriteErrorLog(e, "コンバート元データ取得に失敗しました。");
                    deleteTempDataByPatIdList(listSelectedPatId);
                    return false;
                }
            }

            deleteTempDataByPatIdList(listSelectedPatId);
            deleteChecklistHisTByPatIdList(listSelectedPatId);

            if (mapFnwDataOrd.Count == 0)
            {
                // 全患者回しても元データが存在しない場合
                WriteTraceLog("コンバート元データが存在しません。");
                WriteTraceLog("===== コンバート元データ取得処理完了 =====");
                return true;
            }
            return true;
        }

        public DataTable GetDateFromChecklist(string patIds, List<KeyValuePair<string, object>> Parameters, DateTime startDate, DateTime endDate) {
            //mod #10418 start
            string searchSql = $@"
                SELECT
                    PATID
                    ,IND_ID
                    ,CODE
                    ,RST_CHECK_COUNT
                FROM SYNC_ORD_CHECKLIST_HIST DIALYSIS
                WHERE
                    {patIds}
                    AND DIALYSIS_DATE BETWEEN :START_DATE AND :END_DATE
                    AND RST_CHECK_COUNT > 0 ";

            var param = db.GetIMakeSqlParameters();
            foreach (var p in Parameters)
            {
                param.AddParam(p.Key, p.Value);
            }
            param.AddParam(":START_DATE", startDate.ToString("yyyyMMdd"));
            param.AddParam(":END_DATE", endDate.ToString("yyyyMMdd"));

            DataTable dt = db.SelectTable(searchSql,param.GetParam());
            //mod #10418 end
            if (null == dt) {
                // SQL実行失敗
                WriteErrorLog("コンバート元データ取得に失敗しました。");
            }
            return dt;
        }

        private void setDataToOrdChecklist(DataTable planDt) {
            DataTable dt = new DataTable();
            DataTable groupedTable = planDt.Clone();
            groupedTable.Columns.Add("RST_CHECK_COUNT", typeof(decimal));
            var delData = planDt.AsEnumerable().Where(plan => string.IsNullOrEmpty(plan["DIALYSIS_DATE"].ToString())).ToList();
            List<string> indIds = new List<string>();
            foreach (var i in delData)
            {
                indIds.Add(i["IND_ID"].ToString());
            }
            //mod #10418 start
            if (indIds.Count>0) {

                CommonFunc.InClauseResult inResult = CommonFunc.BuildParameterizedInCondition("IND_ID", 1000, indIds, "P_");
                string sql = $"DELETE FROM SYNC_ORD_CHECKLIST_HIST WHERE {inResult.Clause}";
                IMakeSqlParameters Sqlparam = db.GetIMakeSqlParameters();
                foreach (var p in inResult.Parameters)
                {
                    Sqlparam.AddParam(p.Key, p.Value);
                }
                db.ExecuteSQL(sql, Sqlparam.GetParam());
            }
            //mod #10418 end

            var addData = planDt.AsEnumerable().Where(plan => !string.IsNullOrEmpty(plan["DIALYSIS_DATE"].ToString())).ToList();
            var groupCounts = addData.AsEnumerable()
                        .GroupBy(row => new { PATID = row["PATID"], IND_ID = row["IND_ID"], DIALYSIS_DATE = row["DIALYSIS_DATE"], BED_NO = row["BED_NO"], KUR_CD = row["KUR_CD"], CODE = row["CODE"] })
                        .Select(group => {
                            var row = groupedTable.NewRow();
                            row["PATID"] = group.Key.PATID;
                            row["IND_ID"] = group.Key.IND_ID;
                            row["DIALYSIS_DATE"] = group.Key.DIALYSIS_DATE;
                            row["BED_NO"] = group.Key.BED_NO;
                            row["KUR_CD"] = group.Key.KUR_CD;
                            row["CODE"] = group.Key.CODE;
                            row["RST_CHECK_COUNT"] = group.Count();
                            groupedTable.Rows.Add(row);
                            return row;
                        }).ToList();

            //mod #10418 start
            string insertSql = @"INSERT INTO SYNC_ORD_CHECKLIST_HIST(PATID, IND_ID, DIALYSIS_DATE, BED_NO, KUR_CD, CODE, RST_CHECK_COUNT, UP_DATE)";
            var param = db.GetIMakeSqlParameters();
            var valueList = new List<string>();
            int l = 0;
            foreach (DataRow t in groupedTable.Rows)
            {
                string selectBlock = $@"
                    SELECT
                        :PATID{l},
                        :IND_ID{l},
                        :DIALYSIS_DATE{l},
                        :BED_NO{l},
                        :KUR_CD{l},
                        :CODE{l},
                        :RST_CHECK_COUNT{l},
                        SYSDATE
                    FROM DUAL";

                valueList.Add(selectBlock);
                param.AddParam($":PATID{l}", t["PATID"]);
                param.AddParam($":IND_ID{l}", t["IND_ID"]);
                param.AddParam($":DIALYSIS_DATE{l}", t["DIALYSIS_DATE"]);
                param.AddParam($":BED_NO{l}", t["BED_NO"]);
                param.AddParam($":KUR_CD{l}", t["KUR_CD"]);
                param.AddParam($":CODE{l}", t["CODE"]);
                param.AddParam($":RST_CHECK_COUNT{l}", t["RST_CHECK_COUNT"]);
                l++;
            }

            if (valueList.Count > 0)
            {
                string values = string.Join(" UNION ALL ", valueList);
                db.ExecuteSQL(insertSql + values, param.GetParam());
            }
            //mod #10418 end
        }

        /// <summary>
        /// データコンバート処理
        /// </summary>
        /// <param name="recordCount">現在のレコード件数</param>
        /// <returns>成功：true、失敗：false</returns>
        public override bool Convert(Dictionary<string, List<NtssRecord>> mapConvertData, List<string> listErrorPat)
        {
            WriteTraceLog("===== コンバート処理開始 =====");
            DataTable planDt = mapFnwDataOrd["RST_CHECKLIST_PLAN"];
            if (planDt.Rows.Count > 0)
            {
                ConvertRecordInTable(mapConvertData, planDt);
                // 今回導入したチェック済みレコード数をテーブルに格納する(透析日単位に)
                setDataToOrdChecklist(planDt);
            }

            DataTable rstDt = mapFnwDataOrd["RST_CHECKLIST_RST"];
            if (rstDt.Rows.Count > 0)
            {
                ConvertRecordInTable(mapConvertData, rstDt);
            }

            WriteTraceLog("===== コンバート処理完了 =====");
            return true;
        }

        private void ConvertRecordInTable(Dictionary<string, List<NtssRecord>> mapConvertData, DataTable dt) {

            for (int i = 0; i < dt.Rows.Count; i++)
            {
               
                var isConvertError = false;
                var ntssColumns = new List<NtssColumn>();
                var mapJson = new Dictionary<string, List<JsonElement>>();

                //------------------------------------
                // 主テーブルの加工処理
                //------------------------------------
                ConvertRecord(dt.Rows[i], ntssColumns, mapJson, ref isConvertError);
                if (isConvertError)
                {
                    break;
                }


                // JSONデータ有無チェック
                if (mapJson.Count > 0)
                {
                    
                    // JSONデータが存在する場合
                    foreach (string jsonName in mapJson.Keys)
                    {
                        DataRow[] drRelationArray = GetRelationArrayByNtssInfo(this.convertTableName, jsonName);
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

              
                // 移行先に施設コードの列が無いテーブルの場合は施設コードをSQL出力対象外列に設定
                NtssColumn facilityCdColumn = CreateNtssColumn("facility_cd", NTSS_DATA_TYPE_CHARACTER_VARYING, this.facilityCd, true);
                
                if (!ntssColumns.Any(col => col.name.Equals("facility_cd")))
                {
                    // 施設コードを追加
                    ntssColumns.Insert(0, facilityCdColumn);
                }

                var patid = dt.Rows[i]["PATID"].ToString();

                if (mapConvertData.ContainsKey(patid) == false)
                {
                    mapConvertData[patid] = new List<NtssRecord>();
                }
                mapConvertData[patid].Add(new NtssRecord() { columns = ntssColumns });
            }

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
        /// コンバート元データ数
        /// </summary>
        public override int FnwDataRowCount()
        {
            int dataCount = 0;
            foreach (DataTable dt in mapFnwDataOrd.Values)
            {
                dataCount += dt.Rows.Count;
            }
            return dataCount;
        }
    }
}
