
using System;
using System.Collections.Generic;
using System.Linq;
using ConvertCommon.Common;
using System.Data;
using ConvertCommon.dto;
using ConvertCommon.parts;

using Fnw.IOControl.DB;
using static ConvertCommon.Common.CacheInformation;

namespace ConvertCommon
{
    /// <summary>
    /// コンバート処理クラス（期間指定）
    /// 固有処理が必要なテーブルが発生したら
    /// 本クラスを継承して実装する
    /// </summary>
    public class ConvertSpecifyPeriod : ConvertBase
    {

        /// <summary>
        /// コンストラクタ
        /// </summary>
        public ConvertSpecifyPeriod() { }

        private string XmlPath()
        {
            //return @".\SQL\config\period\"+ this.fnwTableName + "-" + this.convertTableName + ".xml";
            return sqlDirectory + "\\" + this.fnwTableName + "-" + this.convertTableName + ".xml";
        }


        //add 8400 zc start
        private string getListkey(string skey, string stable, string sqlForExclusiveOutputted, string tablename,string type, DateTime convertDateTime) {
            if (tablename.Equals("pat_exam_main"))
            {
                sqlForExclusiveOutputted = sqlForExclusiveOutputted.Replace("a.EXAM_DATE", "b.EXAM_DATE");
            }
            //mod #11753 start
            string withtable = $" WITH min_convert AS {sqlForExclusiveOutputted}";
            string sql = $"{withtable}  select  {skey} as key from {stable} CROSS JOIN  min_convert m  WHERE b.EXAM_DATE >= m.start_date AND b.EXAM_DATE < end_date+1 AND a.up_date > m.CONVERT_DATETIME";
            //mod #11753 end
             //add #12229 start
            IMakeSqlParameters param = db.GetIMakeSqlParameters();
            if (sql.Contains(":CONVERT_DATETIME"))
            {
                param.AddParam(":CONVERT_DATETIME", convertDateTime);
            }
            if (sql.Contains(":table_kind"))
            {
                param.AddParam(":table_kind", type);
            }
            if (sql.Contains(":facility_cd"))
            {
                param.AddParam(":facility_cd", this.facilityCd);
            }

            DataTable resultTable = db.SelectTable(sql, param.GetParam());
            //add #12229 end
            List<string> lListkey = new List<string>();
            if (resultTable.Rows.Count == 0) {
                return "";
            }
            //mod  11753 start
            lListkey = resultTable.AsEnumerable().Select(row => row.Field<string>("KEY")).Distinct().ToList();
            //mod  11753 end
            List<string> listInClauseParam = SplitListValueForSqlInClause(lListkey);
            string sListkey = listInClauseParam.FirstOrDefault();
            return sListkey = "  or " + skey + " IN (" + sListkey + ") ";
        }
        //add 8400 zc end

        /// <summary>
        /// 期間を指定してFNWのデータを取得する
        /// </summary>
        /// <param name="listlistSelectedPatId">処理対象の患者IDリスト</param>
        /// <param name="startDate">期間開始日</param>
        /// <param name="endDate">期間終了日</param>
        /// <param name="isSync">同期フラグ</param>
        /// <returns>
        /// 同期時の処理（isSyncがtrueの場合）は未実装、
        /// 実装することになった場合、処理対象の患者IDリスト
        /// に１患者だけ設定して実行すればうまくいくはず。
        /// </returns>
        public override bool SetFnwData(
            List<string> listlistSelectedPatId,
            DateTime startDate,
            DateTime endDate,
            bool isSync)
        {
            WriteTraceLog("===== コンバート元データ取得処理開始 =====");

            WriteTraceLog("===== メインテーブル取得処理開始 =====");

            // 設定XMLファイルからDTOに変換する（コーディングの簡略化のため）
            ConfigInfoDto configDto = ConfigInfoDtoUtil.getConfigXml(this.XmlPath());

            //add 8400 zc start
            var type = "EXM";
            var colName = "a.EXAM_DATE";
            if (!(configDto.tableInfo[0].ntssTableName.Equals("pat_exam_main") || configDto.tableInfo[0].ntssTableName.Equals("pat_rad_main")))
            {
                type = "ORD";
                colName = "START_DATE";
            }
            //add 8400 zc start
            string sqlwhere = string.Empty;
            string stable = string.Empty;
            string key = string.Empty;

            ConvertDatetimeResult resultConvertDatetime = new ConvertDatetimeResult();
            //add 8400 zc end
            if (!configDto.tableInfo[0].ntssTableName.Equals("ind_history") && !configDto.tableInfo[0].ntssTableName.Equals("rst_history")) {
                //add #122229  前回convertを実行した時刻 start
                resultConvertDatetime = CacheInformation.Instance.GetEffectiveConvertDatetime(type);
                bool hasDiff = resultConvertDatetime.HasDiff;
                
                string dialysisPlanAddTbl = string.Empty;
                if (!hasDiff)
                {
                    dialysisPlanAddTbl = " ("
                       + " SELECT a.facility_cd , a.START_DATE,a.CONVERT_DATETIME, LAST_DAY(ADD_MONTHS(SYSDATE, 12)) AS end_date "
                       + " FROM "
                       + " sync_convert_history a where a.CONVERT_DATETIME=:CONVERT_DATETIME"
                       + " and  a.table_kind =:table_kind and facility_cd=:facility_cd) ";
                }
                else
                {
                   
                    dialysisPlanAddTbl = " ( SELECT :CONVERT_DATETIME as CONVERT_DATETIME,"
                             + "            START_DATE,"
                             + "             CASE"
                             + "                 WHEN CONVERT_DATETIME = MIN(CONVERT_DATETIME)"
                             + "                      OVER()"
                             + "                THEN LAST_DAY(ADD_MONTHS(SYSDATE, 12)) "
                             + "                 ELSE END_DATE"
                             + "            END AS END_DATE"
                             + "        FROM sync_convert_history"
                             + "         WHERE FACILITY_CD = :facility_cd"
                             + "          AND TABLE_KIND = :table_kind "
                             + "           AND(TABLE_NAME <> 'diff'  OR TABLE_NAME IS NULL)"
                             + "        ) ";
                }
                //add #122229  前回convertを実行した時刻 end



                if (configDto.tableInfo[0].ntssTableName.Equals("ord_coop_no"))
                {
                    sqlwhere = @"  exists(
		                                                                        select * from " + dialysisPlanAddTbl + @" ch
		                                                                        where  a.START_DATE >= ch.start_date
                                                                                 and a.START_DATE < ch.end_date + 1 AND (EVENT_OCCUR_DATE > ch.CONVERT_DATETIME or (UP_DATE IS NOT NULL AND UP_DATE > CH.CONVERT_DATETIME)) )";
                }
                else if (configDto.tableInfo[0].ntssTableName.Equals("pat_ind_approve")) 
                {
                    sqlwhere = @"  exists(
		                                                                        select * from " + dialysisPlanAddTbl + @" ch
		                                                                        where  UPD_DATE > ch.CONVERT_DATETIME
                                                                                 and UPD_DATE < ch.end_date + 1) ";
                    if (CommonConfig.ordListIndId != null) {
                        sqlwhere += " or " + CommonConfig.ordListIndId;
                    }
                    if (CommonConfig.ordListRst != null)
                    {
                        sqlwhere += " or " + CommonConfig.ordListRst;
                    }

                }
                //add 10739 start
                else if (configDto.tableInfo[0].ntssTableName.Equals("pat_ind_approve_history"))
                {
                    sqlwhere = "   a.PATID || a.DIALYSIS_DATE || a.PLURAL in({0})";

                    string swhere = @"select  a.PATID||a.DIALYSIS_DATE||a.PLURAL from ( select PATID,DIALYSIS_DATE,PLURAL,REG_DATE from  IND_RECEIVE WHERE DIALYSIS_DATE >= :START_DATE and DIALYSIS_DATE < :END_DATE
                                          {sqlForSync}and  DEL_FLG='0' ) a  LEFT JOIN SCH_DIALYSIS_PLAN plan on a.PATID||a.DIALYSIS_DATE||a.PLURAL = plan.IND_ID 	LEFT JOIN RST_DIALYSIS rst ON rst.DIALYSIS_NO =  plan.RESULT_DIALYSISNO";
                    swhere += @" where  exists(select * from " + dialysisPlanAddTbl + @" ch
		                                                                        where " + colName + @" >= ch.start_date
		                                                                        and " + colName + @" < ch.end_date + 1 and REG_DATE > ch.CONVERT_DATETIME)";
                    if (CommonConfig.ordListRst != null)
                    {
                        swhere += " or " + CommonConfig.ordListRst;
                    }
                    sqlwhere = string.Format(sqlwhere, swhere);

                } //add 10739 end
                else {

                    sqlwhere = @"  exists(select * from " + dialysisPlanAddTbl + @" ch
		                                                                        where " + colName + @" >= ch.start_date
		                                                                        and " + colName + @" < ch.end_date + 1 and a.up_date > ch.CONVERT_DATETIME)";
                }
                //add 8400 zc start
                string skey = string.Empty;
                //mod #11753 start
                if (configDto.tableInfo[0].fnwTableName.Equals("PAT_EXAMIN_HST") && CommonConfig.isDiff)
                {
                    if (string.IsNullOrEmpty(CommonConfig.examinPatid)) {
                        colName = "b.EXAM_DATE";
                        key = "a.PATID || ',' || TO_CHAR( a.REG_DATE, 'yyyy/mm/dd hh24:mi:ss' ) || ',' || TO_CHAR( a.REG_EXAM_DATE, 'yyyy/mm/dd hh24:mi:ss' ) || ',' || a.REG_ORDER_CLASS";
                        stable = "PAT_EXAMIN_HST_DETAIL a INNER JOIN PAT_EXAMIN_HST  b   on b.PATID=a.PATID and  b.REG_DATE=a.REG_DATE  and  b.REG_EXAM_DATE=a.REG_EXAM_DATE and  b.REG_ORDER_CLASS=a.REG_ORDER_CLASS";
                        skey = getListkey(key, stable, dialysisPlanAddTbl, configDto.tableInfo[0].ntssTableName, type, resultConvertDatetime.ConvertDatetime);
                        CommonConfig.examinPatid = skey;
                    }
                    skey = CommonConfig.examinPatid;
                }
                  //mod #11753 end
                //add 10755 zc start
                if (configDto.tableInfo[0].fnwTableName.Equals("PAT_EXAMIN_SCHEDULE") && CommonConfig.isDiff)
                {
                    //mod #10418 start
                    DateTime objRunningStartDate = CacheInformation.Instance.GetEffectiveConvertDatetime("EXM").ConvertDatetime;
                    //mod #10418 end

                    if (DateTime.Now.Month != objRunningStartDate.Month)
                    {
                        string start_date = (DateTime.Now.Year + 1).ToString() + (objRunningStartDate.Month+1).ToString("D2") + "01";
                        string end_date = new DateTime(DateTime.Now.Year + 1, DateTime.Now.Month, DateTime.DaysInMonth(DateTime.Now.Year + 1, DateTime.Now.Month)).ToString("yyyyMMdd");
                        configDto.tableInfo[0].sqlForSpecifyPeriod = configDto.tableInfo[0].sqlForSpecifyPeriod.Replace("a.EXAM_DATE >=", " (a.EXAM_DATE >=");
                        configDto.tableInfo[0].sqlForTool = configDto.tableInfo[0].sqlForTool.Replace("{sqlForExclusiveOutputted}", "{sqlForExclusiveOutputted}"+ " or (EXAM_DATE>='"+ start_date + "' and EXAM_DATE<='" + end_date + "') )");
                    }                  
                }
                //add 10755  zc end

                //add 8400 zc end
                configDto.tableInfo[0].sqlForExclusiveOutputted = "and (" + sqlwhere + skey + ")";


            }

            if (configDto.tableInfo[0].ntssTableName.Equals("rst_history") && CommonConfig.isDiff)
            {   
                //mod #10418 start
                List<string> targetYmList = CommonFunc.GetYmList("LOG_CHANGE_LOG", startDate, endDate,db);
                //mod #10418 end
                // 検索対象テーブル名リストにオリジナルのテーブル名を追加
                targetYmList.Add("LOG_CHANGE_LOG");

                // 検索対象テーブル名リストからUNION句を作成
                string unionBlock = MakeUnionFromTableNameList(targetYmList);
                configDto.tableInfo[0].sqlForTool = configDto.tableInfo[0].sqlForTool.Replace("{1}", unionBlock);

            }

            //add 8400 zc start
            // 補足
            // pkeyValueに患者IDで絞るin句を作成している
            // isSync=trueにしてin句が設定されているpkeyValueをSQLに挿入する
            string tableAlias = "";
            if (configDto.tableInfo[0].sqlForSyncTableAlias != null && 
                !string.IsNullOrEmpty(configDto.tableInfo[0].sqlForSyncTableAlias.ToString()))
            {
                tableAlias = configDto.tableInfo[0].sqlForSyncTableAlias.ToString() + ".";
            }
            //add 7997  zc start
           
            string sVALUE = "1";
            if (!string.IsNullOrEmpty(CacheInformation.Instance.FacilityCd))
            {
                sVALUE = CacheInformation.Instance.FacilityCd;
            }
            //add 7997  zc end
            string InClause = CommonFunc.MakeInClause(
                tableAlias + "patid",
                1000,
                listlistSelectedPatId);
            MakeSqlDto condDto = new MakeSqlDto
            {
                facilityCd = this.facilityCd,
                seriesCd = CommonConfig.seriesCd,
                tableName = this.convertTableName,
                startDate = startDate.ToString("yyyyMMdd"),
                endDate = endDate.AddDays(1).ToString("yyyyMMdd"),
                pkeyValue = InClause,
                sqlForTool = configDto.tableInfo[0].sqlForTool,
                sqlForSync = configDto.tableInfo[0].sqlForSync,
                sqlForExclusiveOutputted = configDto.tableInfo[0].sqlForExclusiveOutputted,
                sqlForSpecifyPeriod = configDto.tableInfo[0].sqlForSpecifyPeriod,
                // add FNSI-差分コンバート対応 楊 start
                isExclusion = CommonConfig.isExclusion || CommonConfig.isDiff,
                // add FNSI-差分コンバート対応 楊 end
                //add 7997 zc start
                isSERIESCD = sVALUE,
                //add 7997 zc end
                // add FNSI-差分コンバート対応 楊 end
                isPeriod = true,
                isSync = isSync
            };

            if (listlistSelectedPatId.Count > 0)
            {
                // 患者IDの指定がある場合、同期フラグをtrueにして取得データを絞る
                condDto.isSync = true;
            }

            // SQL実行
            //add #12229 start 
            //mod #10418 end
            dtFnwData = SqlCreator.MakeSqlForSpecifyPeriod(condDto, type, db, resultConvertDatetime.ConvertDatetime, this.facilityCd);
            //add #12229 end 

            if (dtFnwData == null)
            {
                // SQL実行失敗
                WriteErrorLog("コンバート元データ取得SQLが失敗しました。");
                return false;
            }
            if (configDto.tableInfo[0].ntssTableName.Equals("pat_ind_approve") && dtFnwData.Rows.Count > 0) {
                CheckPatIndApprove.SelectMstKurCheck(db);
                CheckPatIndApprove.SelectMstBedCheck(db);
                CheckPatIndApprove.SelectMstEquipmentCheck(db);
                CheckPatIndApprove.SelectMstMediCheck(db);
                CheckPatIndApprove.SelectMstSetMediCheck(db);
                CheckPatIndApprove.SelectMstDialyzerCheck(db);
                CheckPatIndApprove.SelectMstSetMedicineCheck(db);
                foreach (DataRow row in dtFnwData.Rows)
                {
         
                    // デフォルト：更新無し
                    //dtFnwData.Rows[iIndex]["is_content_changed"] = "0";

                    //【ベッド、クール】
                    // 必須データ存在確認
                    String strPatID= row["PATID"] as String;

                    //透析開始日
                    String strDialysisDate = row["DIALYSIS_DATE"] as String;
                    Decimal decPlural = (decimal)row["PLURAL"];

                    DateTime dateTarget;
                    if ((DBNull.Value.Equals(row["CHECK_DATE_BASE"]))
                        || !(row["CHECK_DATE_BASE"] is DateTime))
                    {
                        // 変換失敗
                        row["CHECK_CONTENT"] = "'{}'";
                        continue;
                    }
                    dateTarget = (DateTime)row["CHECK_DATE_BASE"];
                    bool TargetStartTime = "1".Equals(CheckPatIndApprove.GetSystemDefine(db));
                    // 差分確認
                    bool isUpdate = CheckPatIndApprove.CheckIndUpdate(db, strPatID, strDialysisDate, decPlural, dateTarget, TargetStartTime);
                    if (true == isUpdate)
                    {
                        // 更新あり
                   
                        row["IS_CONTENT_CHANGED"] = 1;
                    }
                    //check_content
                    string treatmethod = CheckPatIndApprove.CheckContentUpdate(row, db, strPatID, strDialysisDate, decPlural, dateTarget);
                    string templeteJBASql = "json_build_array(VARIADIC ARRAY[{0}])";
                   
                    row["CHECK_CONTENT"] = string.Format(templeteJBASql, treatmethod);
                }

            }

            // DataTable取得後に名称を設定する
            dtFnwData.TableName = configDto.tableInfo[0].xmlConfigName;

            WriteTraceLog("===== メインテーブル取得処理終了 =====");

            if (dtFnwData.Rows.Count == 0)
            {
                // 0件の場合処理終了
                WriteTraceLog("コンバート元データが０件です。");
                WriteTraceLog("===== コンバート元データ取得処理完了 =====");
                return true;
            }

            WriteTraceLog("===== JSON作成用サブテーブル取得処理開始 =====");


            // 存在する場合、子テーブルデータ取得をSQLファイル数分実行
           if (configDto.tableInfo[0].child == null)
            {
                WriteTraceLog("===== JSON作成用サブテーブル処理対象なし =====");
            }
            else
            {
                foreach (var childXml in configDto.tableInfo[0].child)
                {
                    WriteTraceLog("実行SQL設定名：{0}", childXml.xmlConfigName);
                    //add 8400 zc start
                    if (CommonConfig.isDiff) {
                        childXml.sqlForExclusiveOutputted = string.Empty;
                        //add #12229 start
                        if (configDto.tableInfo[0].ntssTableName.Equals("pat_exam_main"))
                        {
                            childXml.sqlForSync = "";
                            childXml.sqlForSpecifyPeriod = "";
                            List<string> stringValues = dtFnwData.AsEnumerable()
                                          .Select(row => row.Field<string>("KEY"))
                                          .ToList();
                            string skey = "";
                            if (childXml.fnwTableName.Equals("PAT_EXAMIN_SCHEDULE"))
                            {
                                skey = "a.PATID||a.UP_DATE||a.EXAM_DATE||a.EXAM_DIVISION";
                            }
                            else
                            {
                                skey = "a.PATID||','||TO_CHAR(a.REG_DATE,'yyyy/mm/dd hh24:mi:ss')||','||TO_CHAR(a.REG_EXAM_DATE,'yyyy/mm/dd hh24:mi:ss')||','||a.REG_ORDER_CLASS";
                            }
                            childXml.sqlForExclusiveOutputted = "and " + CommonFunc.MakeInClause(
                            skey,
                            1000,
                            stringValues);
                        }
                        //add #12229 end
                    }
                    //add 8400 zc end
                    MakeSqlDto childCondDto = new MakeSqlDto
                    {
                        facilityCd = this.facilityCd,
                        seriesCd = CommonConfig.seriesCd,
                        tableName = this.convertTableName,
                        startDate = startDate.ToString("yyyyMMdd"),
                        endDate = endDate.AddDays(1).ToString("yyyyMMdd"),
                        pkeyValue = InClause,
                        sqlForTool = childXml.sqlForTool,
                        sqlForSync = childXml.sqlForSync,
                        sqlForExclusiveOutputted = childXml.sqlForExclusiveOutputted,
                        sqlForSpecifyPeriod = childXml.sqlForSpecifyPeriod,
                        // add FNSI-差分コンバート対応 楊 start
                        //isExclusion = CommonConfig.isExclusion,
                        isExclusion = CommonConfig.isExclusion || CommonConfig.isDiff,
                        // add FNSI-差分コンバート対応 楊 end
                        //add 7997 zc start
                        isSERIESCD = sVALUE,
                        //add 7997 zc end
                        isPeriod = true,
                        isSync = isSync
                    };

                    if (listlistSelectedPatId.Count > 0)
                    {
                        // 患者IDの指定がある場合、同期フラグをtrueにして取得データを絞る
                        childCondDto.isSync = true;
                    }

                    // SQL作成
                     
                    // 子テーブル取得
                    //mod #10418 start
                    DataTable childDt = SqlCreator.MakeSqlForSpecifyPeriod(childCondDto, type, db, resultConvertDatetime.ConvertDatetime, this.facilityCd);
                    //mod #10418 end
                    if (childDt == null)
                    {
                        // SQL実行失敗
                        WriteErrorLog("JSON作成用サブテーブル取得SQLが失敗しました。");
                        return false;
                    }
                    // DataTable取得後に名称を設定する
                    childDt.TableName = childXml.xmlConfigName;
                    mapFnwDataJson[childXml.xmlConfigName] = childDt;

                    if (childDt.Rows.Count == 0)
                    {
                        // 0件の場合処理終了
                        WriteTraceLog("JSON作成用サブテーブル取得件数０件のため、処理をスキップします。");
                        continue;
                    }
                }
            }

            WriteTraceLog("===== JSON作成用サブテーブル取得処理終了 =====");
            WriteTraceLog("===== コンバート元データ取得処理終了 =====");

            return true;
        }


        
        public override bool Convert(Dictionary<string, List<NtssRecord>> mapConvertData, List<string> listErrorKey)
        {
            WriteTraceLog("===== コンバート処理開始 =====");

            // 設定XMLファイルからDTOに変換する（コーディングの簡略化のため）
            ConfigInfoDto configDto = ConfigInfoDtoUtil.getConfigXml(this.XmlPath());
            // Dictionaryの構造変更
            Dictionary<string, Dictionary<string, DataRow[]>> dic = new Dictionary<string, Dictionary<string, DataRow[]>>();
            // 子テーブル要素をループ
            if (configDto.tableInfo[0].child != null) 
            { 
                foreach (var child in configDto.tableInfo[0].child)
                {
                    dic.Add(child.xmlConfigName, mapFnwDataJson[child.xmlConfigName].AsEnumerable()
                            .ToLookup(dr => dr[child.childPk].ToString())
                            .ToDictionary(
                                drGroup => drGroup.Key,
                                drGroup => drGroup.ToArray()
                            ));
                }
            }

            int procCount = 0;
            foreach (DataRow row in dtFnwData.Rows)
            {
                // メインテーブルのコンバート

                // 系列施設コードがある場合は取得
                string seriesCd = null;
                if (row.Table.Columns.Contains("SERIES_CD"))
                {
                    seriesCd = row["SERIES_CD"].ToString();
                }

                // メインテーブルとサブテーブルの紐付けキーの値を取得
                var relationKeyValue = row[configDto.tableInfo[0].fnwPk].ToString();
                if (configDto.tableInfo[0].ntssTableName.Equals("ord_coop_no")) {
                    relationKeyValue = row["PATID"].ToString();
                }
                if (listErrorKey.Contains(relationKeyValue))
                {
                    // エラーがあった紐付けキーのそれ以降のレコードは処理しない
                    continue;
                }

                var isCriticalError = false;
                var isConvertError = false;
                var ntssColumns = new List<NtssColumn>();
                var mapJson = new Dictionary<string, List<JsonElement>>();

                //------------------------------------
                // 主テーブルの加工処理
                //------------------------------------
                ConvertRecord(row, ntssColumns, mapJson, ref isConvertError);
                if (isConvertError)
                {
                    // 次のレコードへ
                    listErrorKey.Add(relationKeyValue);
                    continue;
                }


                //------------------------------------
                // 子テーブルの加工処理
                //------------------------------------
                // 子テーブル要素をループ
                if (configDto.tableInfo[0].child != null)
                {
                    foreach (var childXml in configDto.tableInfo[0].child)
                    {
                        // 主テーブルの子テーブルに紐付くカラムの値
                        string parentValue = row[childXml.parentPk].ToString();

                        var childRows = new DataRow[] { };
                        if (dic[childXml.xmlConfigName].ContainsKey(parentValue))
                        {
                            childRows = dic[childXml.xmlConfigName][parentValue];
                        }
                        ConvertJsonArrayData(childRows, childXml.jsonName, ntssColumns, ref isCriticalError, ref isConvertError);

                        if (isCriticalError)
                        {
                            return false;
                        }
                        if (isConvertError)
                        {
                            // 次のマスタレコードへ
                            listErrorKey.Add(parentValue);
                            continue;
                        }
                    }
                }

                // 施設コードの列が存在しない
                if (!ntssColumns.Any(col => col.name.Equals("facility_cd")))
                {
                    ntssColumns.Insert(0, CreateNtssColumn("facility_cd", NTSS_DATA_TYPE_CHARACTER_VARYING, this.facilityCd, true));
                }

                // 登録日時・更新日時を追加
                if(!ntssColumns.Any(col => col.name.Equals("reg_date"))){ 
                   ntssColumns.Add(CreateNtssColumn("reg_date", NTSS_DATA_TYPE_TIMESTAMP, CommonConfig.UpDate.ToString(), false));

                }
                if (!ntssColumns.Any(col => col.name.Equals("up_date")))
                {
                    ntssColumns.Add(CreateNtssColumn("up_date", NTSS_DATA_TYPE_TIMESTAMP, CommonConfig.UpDate.ToString(), false));

                }

                // add #10930 zkm start
                if (configDto.tableInfo[0].ntssTableName.Equals("pat_exam_main"))
                {
                    relationKeyValue = row["PATID"].ToString();
                }
                // add #10930 zkm end

                if (mapConvertData.ContainsKey(relationKeyValue) == false)
                {
                    mapConvertData[relationKeyValue] = new List<NtssRecord>();
                }
                mapConvertData[relationKeyValue].Add(new NtssRecord() { columns = ntssColumns });
                //add 8333 zc start
                if (++procCount % 100 == 0)
                //add 8333 zc end
                {
                    WriteTraceLog("コンバート処理中 " + procCount.ToString() + "/" + dtFnwData.Rows.Count.ToString());
                }
            }

            WriteTraceLog("===== コンバート処理完了 =====");
            return true;
        }

      

        /// <summary>
        /// FNWデータ件数を返す
        /// </summary>
        /// <param name="conn"></param>
        /// <param name="listConvertData"></param>
        /// <returns></returns>
        public override int FnwDataRowCount()
        {
            return dtFnwData.Rows.Count;
        }

      

        public string MakeUnionFromTableNameList(List<string> tableNameList)
        {
            string ret = string.Join(" UNION ", tableNameList.AsEnumerable().Select(s =>
            "SELECT  trim(STAFF_CD) as STAFF_CD , OCCUR_DATE, STAFF_NAME, LOG_CHANGE, DIALYSIS_NO FROM " + s + " WHERE LOG_TYPE1='02' and LOG_TYPE2='01'").ToArray());
            return ret;
        }
    }
}
