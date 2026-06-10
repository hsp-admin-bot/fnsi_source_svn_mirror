using ConvertCommon.Common;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;

namespace ConvertCommon
{
    sealed public class ConvertOrdTreatCondition : ConvertBase
    {
       
        private const string _targetTableName = "RST_SEND_CONDITION";
        private readonly RelationCacheBase _relationCache;

        /// <summary>
        /// 更新日時
        /// </summary>
        public ConvertOrdTreatCondition()
        {
            _relationCache = new RelationCacheBase(
                 () => "ord_treat_condition"
            );
        }

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

            // SQLファイル取得
            var baseTableSqlFile = Directory.GetFiles(sqlDirectory, "*.sql");
            if (baseTableSqlFile.Length == 0)
            {
                // SQLファイルなし
                WriteErrorLog("コンバート元データ取得用SQLファイルが存在しません。");
                return false;
            }
            else if (baseTableSqlFile.Length > 1)
            {
                WriteErrorLog("コンバート元データ取得用SQLファイルが複数存在します。");
                return false;
            }

            // SQLファイル名から処理対象テーブル名の取得
            var tableName = Path.GetFileNameWithoutExtension(baseTableSqlFile[0]);

            // 出力済のデータを除外するオプションがTrueの場合
            string whereAddCond = null;

            if (CommonConfig.isDiff)
            {
                //mod #12229 前回convertを実行した時刻 start
                whereAddCond = " WHERE  rsc.RESEND_DATE > :RESEND_DATE ";
                //mod #12229 前回convertを実行した時刻 start 
            }

            if (CommonConfig.isExclusion)
            {
                // コンバート履歴を参照し、出力済の指示・実績データは処理対象から除外する
                whereAddCond = "and not exists(select * from CONVERT_HISTORY ch where ch.facility_cd=:facility_cd and rsc.patid=ch.CONVERTTS and rsc.RESEND_DATE >= ch.start_date and rsc.RESEND_DATE < ch.end_date + 1) ";
            }

            // 検索対象テーブル名リストの取得
            List<string> targetYmList = CommonFunc.GetYmList(_targetTableName, startDate, endDate,db);
            // 検索対象テーブル名リストにオリジナルのテーブル名を追加
            targetYmList.Add(_targetTableName);

            // 検索対象テーブル名リストからUNION句を作成
            string unionBlock = MakeUnionFromTableNameList(targetYmList);
            //mod #10418 start
            // 選択患者リストからSQLのin句の生成
            CommonFunc.InClauseResult inResult = CommonFunc.BuildParameterizedInCondition("patid", 1000, listSelectedPatIdCopy, "P_");
            string inClause = inResult.Clause;
            unionBlock = string.Format(unionBlock,inClause);
            //mod #10418 end

            string sVALUE = "1";
            if (!string.IsNullOrEmpty(CacheInformation.Instance.FacilityCd))
            {
                sVALUE = CacheInformation.Instance.FacilityCd;
            }
            WriteTraceLog("実行SQL：{0}", baseTableSqlFile);
            try
            {
                using (var sr = new StreamReader(baseTableSqlFile[0]))
                {
                    // SQLファイル読込
                    var sql = sr.ReadToEnd().Replace(Environment.NewLine, " ").TrimEnd(';');
                    string sCd = string.Empty;
                    if (sVALUE.Equals("1")) {
                        sCd = $" and d.SERIES_CD =:SERIES_CD ";
                    }
                   
                    // 取得対象患者IDと取得期間をWHERE句に記述
                    // (終了日の条件はSQL上で「 < 終了日」としているため1日足す)
                    sql = string.Format(sql,
                        whereAddCond,
                        unionBlock, sCd);


                    //mod #10418 start
                    var param = db.GetIMakeSqlParameters();
                    foreach (var p in inResult.Parameters)
                    {
                        param.AddParam(p.Key, p.Value);
                    }
                    param.AddParam(":START_DATE", startDate.ToString("yyyy-MM-dd"));
                    param.AddParam(":END_DATE", endDate.AddDays(1).ToString("yyyy-MM-dd"));

                    if (sql.Contains(":SERIES_CD"))
                        param.AddParam(":SERIES_CD", CommonConfig.seriesCd);

                    if (sql.Contains(":facility_cd"))
                        param.AddParam(":facility_cd", this.facilityCd);

                    if (sql.Contains(":RESEND_DATE"))
                        param.AddParam(":RESEND_DATE", CacheInformation.Instance.GetEffectiveConvertDatetime("ORD").ConvertDatetime);
                    dtFnwData = db.SelectTable(sql, param.GetParam());
                    //mod #1418 end 

                    if (dtFnwData == null)
                    {
                        // SQL実行失敗
                        WriteErrorLog("コンバート元データ取得に失敗しました。");
                        return false;
                    }

                    //dtFnwData = dt;
                    dtFnwData.TableName = tableName;

                    if (dtFnwData.Rows.Count == 0)
                    {
                        // 全患者回しても元データが存在しない場合
                        WriteTraceLog("コンバート元データが存在しません。");
                        WriteTraceLog("===== コンバート元データ取得処理完了 =====");
                        return true;
                    }
                }
            }
            catch (Exception e)
            {
                WriteErrorLog(e, "コンバート元データ取得に失敗しました。");
                return false;
            }
            return true;
        }

        /// <summary>
        /// データコンバート処理
        /// </summary>
        /// <param name="recordCount">現在のレコード件数</param>
        /// <returns>成功：true、失敗：false</returns>
        public override bool Convert(Dictionary<string, List<NtssRecord>> mapConvertData, List<string> listErrorPat)
        {
            WriteTraceLog("===== コンバート処理開始 =====");
            DataTable dtFnwDataNew = new DataTable();
            var key = "SET_DATA";
            dtFnwDataNew = dtFnwData.DefaultView.ToTable(false, new string[] { key });

            for (int i = 0; i < dtFnwData.Rows.Count; i++)
            {
                var isCriticalError = false;
                var isConvertError = false;
                var ntssColumns = new List<NtssColumn>();
                var mapJson = new Dictionary<string, List<JsonElement>>();

                //------------------------------------
                // 主テーブルの加工処理
                //------------------------------------
                ConvertRecord(dtFnwData.Rows[i], ntssColumns, mapJson, ref isConvertError);
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

                DataRow[] records = new DataRow[] { };
                var record = new DataRow[1];
                record[0] = dtFnwDataNew.Rows[i];
                records = record;
                var mapJsonTmp = new Dictionary<string, List<JsonElement>>();
           
                ConvertJsonArrayDeviceSetInfoData(records, "treat_condition", ntssColumns, ref isCriticalError, ref isConvertError);
                
                var patid = dtFnwData.Rows[i]["PATID"].ToString();

                if (mapConvertData.ContainsKey(patid) == false)
                {
                    mapConvertData[patid] = new List<NtssRecord>();
                }
                mapConvertData[patid].Add(new NtssRecord() { columns = ntssColumns });

             
                // 移行先に施設コードの列が無いテーブルの場合は施設コードをSQL出力対象外列に設定
                NtssColumn facilityCdColumn = CreateNtssColumn("facility_cd", NTSS_DATA_TYPE_CHARACTER_VARYING, this.facilityCd, true);
                if (!ntssColumns.Any(col => col.name.Equals("facility_cd")))
                {
                    // 施設コードを追加
                    ntssColumns.Insert(0, facilityCdColumn);
                }

                // 登録日時を追加
                if (!ntssColumns.Any(col => col.name.Equals("reg_date")))
                {
                    ntssColumns.Insert(0, CreateNtssColumn("reg_date", NTSS_DATA_TYPE_TIMESTAMP, CommonConfig.UpDate.ToString(), true));
                }
                // 更新日時を追加
                if (!ntssColumns.Any(col => col.name.Equals("up_date")))
                {
                    ntssColumns.Insert(0, CreateNtssColumn("up_date", NTSS_DATA_TYPE_TIMESTAMP, CommonConfig.UpDate.ToString(), true));
                }
            }

            WriteTraceLog("===== コンバート処理完了 =====");
            return true;
        }

        /// <summary>
        /// テーブル名のリストをUNION句へ変換する
        /// </summary>
        /// <param name="tableNameList"></param>
        /// <returns></returns>
        public string MakeUnionFromTableNameList(List<string> tableNameList)
        {
            string ret = string.Join(" UNION ", tableNameList.AsEnumerable().Select(s =>
            "SELECT DEVICE_NO, PATID, BED_NO, KUR_CD, DIALYSIS_DATE, SET_DATA, nvl(RESEND_DATE, SEND_DATE) RESEND_DATE, SEND_STATUS, SET_CD, " +
            "BEFORE_WEIGHT,	DW, TARGET_WEIGHT, MEASURE_WEIGHT, OFFWATER_LIMIT, OFFWATER_CORRECT_CODE1,OFFWATER_CORRECT_VALUE1, OFFWATER_UPDATE_DAY1, " +
            "OFFWATER_CORRECT_CODE2, OFFWATER_CORRECT_VALUE2, OFFWATER_UPDATE_DAY2, OFFWATER_CORRECT_CODE3, OFFWATER_CORRECT_VALUE3, " +
            "OFFWATER_UPDATE_DAY3, OFFWATER_CORRECT_CODE4, OFFWATER_CORRECT_VALUE4, OFFWATER_UPDATE_DAY4, OFFWATER_CORRECT_CODE5, OFFWATER_CORRECT_VALUE5, " +
            "OFFWATER_UPDATE_DAY5, TARE_CORRECT_CODE1, TARE_CORRECT_VALUE1, TARE_UPDATE_DAY1, TARE_CORRECT_CODE2, TARE_CORRECT_VALUE2, " +
            "TARE_UPDATE_DAY2, TARE_CORRECT_CODE3, TARE_CORRECT_VALUE3, TARE_UPDATE_DAY3, TARE_CORRECT_CODE4, TARE_CORRECT_VALUE4, TARE_UPDATE_DAY4,OFFWATER_TARGET, " +
            "TARE_CORRECT_CODE5, TARE_CORRECT_VALUE5, TARE_UPDATE_DAY5, TARE_CORRECT_CODE6, TARE_CORRECT_VALUE6, TARE_UPDATE_DAY6, WHEEL_CHAIR_CD, " +
            "WHEEL_CHAIR_UPDATE FROM " + s + " where {0} " +
            "AND ( (RESEND_DATE IS NOT NULL AND  RESEND_DATE >= :START_DATE AND RESEND_DATE < :END_DATE) or (RESEND_DATE IS NULL AND SEND_DATE >= :START_DATE  AND SEND_DATE <:END_DATE)) ").ToArray());
            return ret;
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
            return dtFnwData.Rows.Count;
        }
    }
}
