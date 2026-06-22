using ConvertCommon.Common;
using Fnw.IOControl.DB;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;

namespace ConvertCommon
{
    sealed public class ConvertOrdWeightScale : ConvertBase
    {

        private readonly RelationCacheBase _relationCache;
        private const string _targetTableName = "RST_WEIGHT_HST";
       
        /// <summary>
        /// 更新日時
        /// </summary>
        public ConvertOrdWeightScale ()
        {
            _relationCache = new RelationCacheBase(
                 () => "ord_weight_scale"
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

            // SQLファイル名から処理対象テーブル名の取得
            var tableName = Path.GetFileNameWithoutExtension(baseTableSqlFile[0]);


            // 出力済のデータを除外するオプションがTrueの場合
            string whereAddCond = null;
          
            // add FNSI-差分コンバート対応 楊 start
            if (CommonConfig.isDiff)
            {
                //mod #12229 前回convertを実行した時刻 start
                whereAddCond = $" WHERE rd.up_date >:ConvertDatetime " ;
                //mod #12229 前回convertを実行した時刻 start 
               

            }
            // add FNSI-差分コンバート対応 楊 end

            if (CommonConfig.isExclusion)
            {
                // コンバート履歴を参照し、出力済の指示・実績データは処理対象から除外する
                whereAddCond = "and not exists(select * from CONVERT_HISTORY ch where ch.facility_cd=:facility_cd  and rd.patid=ch.CONVERTTS and rd.MEASURE_DATE >= ch.start_date and rd.MEASURE_DATE < ch.end_date + 1) ";
            }

            // 検索対象テーブル名リストの取得
            List<string> targetYmList = CommonFunc.GetYmList(_targetTableName, startDate, endDate,db);
            // 検索対象テーブル名リストにオリジナルのテーブル名を追加
            targetYmList.Add(_targetTableName);
           
            string sVALUE = "1";
            if (!string.IsNullOrEmpty(CacheInformation.Instance.FacilityCd))
            {
                sVALUE = CacheInformation.Instance.FacilityCd;
            }
            // 検索対象テーブル名リストからUNION句を作成
            string unionBlock = MakeUnionFromTableNameList(targetYmList, sVALUE);

           
            WriteTraceLog("実行SQL：{0}", baseTableSqlFile);
            try
            {
                using (var sr = new StreamReader(baseTableSqlFile[0]))
                {
                    // mod #10418 start
                    // mod #10835 体重計測定記録の一部がFNWからコンバートされていない zkm start
                    CommonFunc.InClauseResult inResult = CommonFunc.BuildParameterizedInCondition("patid", 1000, listSelectedPatIdCopy, "P_");
                    string inClause = inResult.Clause;
                    // mod #10835 体重計測定記録の一部がFNWからコンバートされていない zkm end
                    var param = db.GetIMakeSqlParameters();
                    foreach (var p in inResult.Parameters)
                    {
                        param.AddParam(p.Key, p.Value);
                    }
                    param.AddParam(":START_DATE", startDate.ToString("yyyy-MM-dd"));
                    param.AddParam(":END_DATE", endDate.AddDays(1).ToString("yyyy-MM-dd"));
                    // mod #10418 end

                    // SQLファイル読込
                    var sql = sr.ReadToEnd().Replace(Environment.NewLine, " ").TrimEnd(';');
                    string  tableList = string.Format(unionBlock,inClause);
                    // add #10835 体重計測定記録の一部がFNWからコンバートされていない zkm start
                    if (sVALUE == "0")
                    {
                        sql = sql.Replace("{SERIES_CD}", "");
                    }
                    else
                    {
                        sql = sql.Replace(
                            "{SERIES_CD}",
                            $" WHERE SERIES_CD =:SERIES_CD "
                        );
                    }
                    // add #10835 体重計測定記録の一部がFNWからコンバートされていない zkm end

                    // 取得対象患者IDと取得期間をWHERE句に記述
                    // (終了日の条件はSQL上で「 < 終了日」としているため1日足す)
                    sql = string.Format(sql, 
                        whereAddCond,
                        tableList);
                    // mod #10418 start
                    if (sql.Contains(":SERIES_CD"))
                        param.AddParam(":SERIES_CD", CommonConfig.seriesCd);

                    if (sql.Contains(":facility_cd"))
                        param.AddParam(":facility_cd", this.facilityCd);

                    if (sql.Contains(":ConvertDatetime"))
                        param.AddParam(":ConvertDatetime", CacheInformation.Instance.GetEffectiveConvertDatetime("ORD").ConvertDatetime);

                    dtFnwData = db.SelectTable(sql, param.GetParam());
                    // mod #10418 end

                    if (dtFnwData == null)
                    {
                        // SQL実行失敗
                        WriteErrorLog("コンバート元データ取得に失敗しました。");
                        return false;
                    }

                    //dtFnwData = dt;
                    dtFnwData.TableName = tableName;
                }

                // add #10835 体重計測定記録の一部がFNWからコンバートされていない zkm start
                if (listSelectedPatId.Contains(CommonConfig.WeightScaleNoPatConvertMark)) {
                    using (var sr = new StreamReader(baseTableSqlFile[1]))
                    {
                        // SQLファイル読込
                        var sql = sr.ReadToEnd().Replace(Environment.NewLine, " ").TrimEnd(';');
                        // mod #10418 start
                        string tableList = string.Format(unionBlock,"PATID IS NULL");
                        IMakeSqlParameters param1 = db.GetIMakeSqlParameters();
                        param1.AddParam(":START_DATE", startDate.ToString("yyyy-MM-dd"));
                        param1.AddParam(":END_DATE", endDate.AddDays(1).ToString("yyyy-MM-dd"));
                        if (sVALUE == "0")
                        {
                            sql = sql.Replace("{SERIES_CD}", "");
                        }
                        else
                        {
                            sql = sql.Replace(
                                "{SERIES_CD}",
                                " WHERE SERIES_CD = :SERIES_CD "
                            );
                           
                        }
                        // 取得対象患者IDと取得期間をWHERE句に記述
                        // (終了日の条件はSQL上で「 < 終了日」としているため1日足す)
                        sql = string.Format(sql,
                            whereAddCond,
                            tableList);
                      
                        if (sql.Contains(":SERIES_CD"))
                            param1.AddParam(":SERIES_CD", CommonConfig.seriesCd);

                        if (sql.Contains(":facility_cd"))
                            param1.AddParam(":facility_cd", this.facilityCd);

                        if (sql.Contains(":ConvertDatetime"))
                            param1.AddParam(":ConvertDatetime", CacheInformation.Instance.GetEffectiveConvertDatetime("ORD").ConvertDatetime);

                        DataTable noPatData = db.SelectTable(sql, param1.GetParam());
                        // mod #10418 end

                        if (noPatData == null)
                        {
                            // SQL実行失敗
                            WriteErrorLog("コンバート元データ取得に失敗しました。");
                            return false;
                        }
                        dtFnwData.Merge(noPatData);
                    }
                }
                if (dtFnwData.Rows.Count == 0)
                {
                    // 全患者回しても元データが存在しない場合
                    WriteTraceLog("コンバート元データが存在しません。");
                    WriteTraceLog("===== コンバート元データ取得処理完了 =====");
                    return true;
                }
                // add #10835 体重計測定記録の一部がFNWからコンバートされていない zkm end
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

                var patid = dtFnwData.Rows[i]["PATID"].ToString();

                if (mapConvertData.ContainsKey(patid) == false)
                {
                    mapConvertData[patid] = new List<NtssRecord>();
                }
                mapConvertData[patid].Add(new NtssRecord() { columns = ntssColumns });

                // 登録施設コードが存在しない場合追加
                
                // 移行先に施設コードの列が無いテーブルの場合は施設コードをSQL出力対象外列に設定
                NtssColumn facilityCdColumn = CreateNtssColumn("facility_cd", NTSS_DATA_TYPE_CHARACTER_VARYING, this.facilityCd, true);
                if (!ntssColumns.Any(col => col.name.Equals("facility_cd")))
                {
                    // 施設コードを追加
                    ntssColumns.Insert(0, facilityCdColumn);
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
        public string MakeUnionFromTableNameList(List<string> tableNameList,string sVALUE)
        {
          
            string sCD = "";
            if (sVALUE.Equals("1"))
            {
                sCD = $" and SERIES_CD =:SERIES_CD ";
            }

            //mod  7975 鄭  start 
            string ret = string.Join(" UNION ", tableNameList.AsEnumerable()
                .Select(s => @"SELECT SERIES_CD,
                    REVISE_OFFWATER1,
                    REVISE_OFFWATER2,
                    REVISE_OFFWATER3,
                    REVISE_OFFWATER4,
                    REVISE_OFFWATER5,
                    REVISE_OFFWATER_NAME1,
                    REVISE_OFFWATER_NAME2,
                    REVISE_OFFWATER_NAME3,
                    REVISE_OFFWATER_NAME4,
                    REVISE_OFFWATER_NAME5,
                    REVISE_TARE1,
	                REVISE_TARE2,
	                REVISE_TARE3,
	                REVISE_TARE4,
	                REVISE_TARE5,
	                REVISE_TARE_NAME1,
	                REVISE_TARE_NAME2,
	                REVISE_TARE_NAME3,
	                REVISE_TARE_NAME4,
	                REVISE_TARE_NAME5,
                   UP_DATE,WEIGHT_NO,MEASURE_DATE,PATID,WEIGHT_CLASS,BED_NO,WHEEL_CHAIR_FLG,TARGET_WEIGHT,MEASURE_WEIGHT" +
                ",WEIGHT_VALUE, OFFWATER_AMT_LIMIT, WHEEL_CHAIR_WEIGHT, WHEEL_CHAIR_CD, WHEEL_CHAIR_NAME, MEASURE_STAFF_CD FROM "+ s+ " WHERE {0} AND MEASURE_DATE >= :START_DATE AND MEASURE_DATE< :END_DATE " + sCD).ToArray());

            //mod  7975 鄭  end 
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
