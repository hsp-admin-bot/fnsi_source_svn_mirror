using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Data;
using ConvertCommon.Common;
using System.Text.RegularExpressions;

namespace ConvertCommon
{
    sealed public class ConvertMniMonitor:ConvertBase
    {

        private readonly RelationCacheBase _relationCache;

        public ConvertMniMonitor() {
            _relationCache = new RelationCacheBase(
                () => "mni_monitor"
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
            string addCond = "and not exists(select * from CONVERT_HISTORY ch where ch.facility_cd=:facility_cd and rd.patid=ch.CONVERTTS and rd.START_DATE >= ch.start_date and rd.START_DATE < ch.end_date + 1) ";

            if (CommonConfig.isDiff)
            {
                //mod 8400 zc start
              
                //mod #122229  前回convertを実行した時刻 start
                string dialysisPlanAddTbl = CommonConfig.dialysisPlanHistTblSql;
                //mod #122229  前回convertを実行した時刻 end
                addCond = " and  exists(select * from "+ dialysisPlanAddTbl + " ch where  rd.START_DATE >= ch.start_date and rd.START_DATE < ch.end_date + 1 and rd.up_date > ch.CONVERT_DATETIME)";
                // コンバート履歴を参照し、出力済の指示・実績データは処理対象から除外する
                //mod 8400 zc end
            }
            return this.SetFnwDataSprcifyPeriodPrivate(listSelectedPatId,
                startDate,
                endDate,
                addCond);
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
        /// データコンバート処理
        /// </summary>
        /// <param name="patid">患者ID</param>
        /// <param name="listConvertData">コンバートデータ</param>
        /// <remarks>
        /// ConvertControlXXX(Pat, Ord, ...)YYY(Main, Event, ...)にて実装
        /// </remarks>
        /// <returns>成功：true、失敗：false</returns>
        public override bool Convert(Dictionary<string, List<NtssRecord>> mapConvertData, List<string> listErrorPat)
        {
            WriteTraceLog("===== コンバート処理開始 =====");
            int procCount = 0;
            for (int i = 0; i < dtFnwData.Rows.Count; i++)
            {
               
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

                // #9223 再循環率が-1の場合、このモニタデータはコンバート処理されていない zhoutao Start
                if ("3".Equals(dtFnwData.Rows[i]["DATA_TYPE"].ToString()))
                {
                    string subDataMatch = @"(`1T-1)";
                    string mniData = dtFnwData.Rows[i]["MONITOR_DATA"].ToString();

                    Match dataMatch = Regex.Match(mniData, subDataMatch);

                    if (dataMatch.Success)
                    {
                        continue;
                    }
                }
                // #9223 再循環率が-1の場合、このモニタデータはコンバート処理されていない zhoutao Start

                // MONITOR_DATA固定処理
                ConvertJsonArrayXmlData(
                    "monitor_data",
                    "MONITOR_DATA",
                    "MONI_DATA",
                    "mni_",
                    ConvertCommon.Const.CommonConstants.MONITOR_DATA_ELEMENT_NAME_LIST_PAT,
                    dtFnwData.Rows[i], ntssColumns);

                var patid = dtFnwData.Rows[i]["PATID"].ToString();

                if (mapConvertData.ContainsKey(patid) == false)
                {
                    mapConvertData[patid] = new List<NtssRecord>();
                }
                mapConvertData[patid].Add(new NtssRecord() { columns = ntssColumns });

                // 登録施設コードが存在しない場合追加
                // 施設コードの列が無いテーブルリストを取得する
                if (!ntssColumns.Any(col => col.name.Equals("facility_cd")))
                {
                    // 施設コードを追加
                    ntssColumns.Insert(0, CreateNtssColumn("facility_cd", NTSS_DATA_TYPE_CHARACTER_VARYING, this.facilityCd, true));
                }
                
                // 7341 AWS側アプリの処理が遅い start
                // 更新者IDを追加
                ntssColumns.Add(CreateNtssColumn("upd_staff_id", NTSS_DATA_TYPE_NUMERIC, null, false));
                // 7341 AWS側アプリの処理が遅い end

                if (++procCount % 100 == 0)
                {
                    WriteTraceLog("コンバート処理中 " + procCount.ToString() + "/" + dtFnwData.Rows.Count.ToString());
                }
            }
            WriteTraceLog("===== コンバート処理完了 =====");

            return true;
        }


      

        /// <summary>
        /// コンバート元データ数
        /// </summary>
        public override int FnwDataRowCount()
        {
            return dtFnwData.Rows.Count;
        }

        /*==== #9223 再循環率追加対応 ZHOU 2023-08-07 START ====*/
        /// <summary>
        /// FNWから期間指定、患者IDでデータを取得する
        /// </summary>
        /// <param name="listSelectedPatId">患者IDリスト</param>
        /// <param name="startDate">期間開始</param>
        /// <param name="endDate">期間終了</param>
        /// <param name="addCond">追加条件</param>
        /// 
        /// <returns></returns>
        private bool SetFnwDataSprcifyPeriodPrivate(List<string> listSelectedPatId, DateTime startDate, DateTime endDate, string addCond)
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

            
            string whereAddCond = null;
            // 出力済のデータを除外するオプションがTrueの場合
            // add FNSI-差分コンバート対応 楊 start
            // if (CommonConfig.isExclusion)
            if (CommonConfig.isExclusion || CommonConfig.isDiff)
            // add FNSI-差分コンバート対応 楊 end
            {
                // コンバート履歴を参照し、出力済の指示・実績データは処理対象から除外する
                whereAddCond = addCond;
            }

            WriteTraceLog("実行SQL：{0}", baseTableSqlFile);
            string sVALUE = "1";
            if (!string.IsNullOrEmpty(CacheInformation.Instance.FacilityCd))
            {
                sVALUE = CacheInformation.Instance.FacilityCd;
            }

           
            try
            {
                using (var sr = new StreamReader(baseTableSqlFile[0]))
                {
                    // SQLファイル読込
                    var sql = sr.ReadToEnd().Replace(Environment.NewLine, " ").TrimEnd(';');

                    // LOG_DEV_LOG中に、再循環率を取得する
                    string logSQL = this.CreateLog( "LOG_DEV_LOG", startDate, endDate, sVALUE);
                    if (logSQL == null)
                    {
                        logSQL = string.Empty;
                    }
                    // 構築SQL文を置換
                    sql = sql.Replace("{4}", logSQL);
                    if (sVALUE.Equals("1"))
                    {
                        sql = sql.Replace("{SERIES_CD}", $"and rd.SERIES_CD = :SERIES_CD");
                    }
                    else {
                        sql = sql.Replace("{SERIES_CD}", "");
                    }

                    ////mod #10418 start
                    CommonFunc.InClauseResult inResult = CommonFunc.BuildParameterizedInCondition("PATID", 1000, listSelectedPatIdCopy,"P_");
                    string inClause = inResult.Clause;

                    // 取得対象患者IDと取得期間をWHERE句に記述
                    // (終了日の条件はSQL上で「 < 終了日」としているため1日足す)
                    sql = string.Format(sql, inClause, whereAddCond);
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

                    dtFnwData = db.SelectTable(sql, param.GetParam());
                    //mod #10418 end

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
        /// FNWから期間指定、患者IDでデータを取得する
        /// </summary>
        /// <param name="db">患者IDリスト</param>
        /// <param name="tableName"></param>
        /// <param name="startDate">期間開始</param>
        /// <param name="endDate">期間終了</param>
        /// <returns></returns>
        private string CreateLog(string tableName, DateTime startDate, DateTime endDate,string sVALUE)
        {
            // Get Log table name list
           
            List<string> retList = CommonFunc.GetYmList(tableName, startDate, endDate,db);

            if (!retList.Contains("LOG_DEV_LOG"))
            {
                retList.Add("LOG_DEV_LOG");
            }

            // Build all union SQL
            StringBuilder sb = new StringBuilder();
            retList.ForEach(getlogdata => {
                sb.Append("SELECT rd.DEVICE_NO AS DEVICE_NO, rd.DIALYSIS_NO AS DIALYSIS_NO, rd.PATID AS PATID,");
                sb.Append(" 3 AS DATA_TYPE,  rd.DEL_FLG AS DEL_FLG, ldl.OCCUR_DATE AS OCCUR_DATE");
                sb.Append(", 'MONI_DATA`1T' || ldl.LOG_NUMBER1 AS MONITOR_DATA,rd.UP_DATE");
                sb.Append(" FROM RST_DIALYSIS rd");
                sb.Append(" INNER JOIN ");
                sb.Append(getlogdata + " ldl");
                sb.Append(" ON rd.device_no = ldl.device_no  ");
                sb.Append(" AND ldl.occur_date between rd.enter_date and rd.leave_date ");
                sb.Append(" AND trim(ldl.log_cd) = '0106' ");
                sb.Append(" WHERE {0} and rd.START_DATE >= :START_DATE and rd.START_DATE < :END_DATE {1}");
                if (sVALUE.Equals("1")) {
                    sb.Append($"and rd.SERIES_CD = :SERIES_CD");
                }
                sb.Append(" UNION  ");
            });
            return sb.ToString();
        }
        /*==== #9223 再循環率追加対応 ZHOU 2023-08-07 END ====*/
    }
}
