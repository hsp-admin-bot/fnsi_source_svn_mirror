
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using ConvertCommon.dto;
using ConvertCommon.Common;
using Fnw.IOControl.DB;
using System.Data;
using ConvertCommon.Const;


namespace ConvertCommon.parts
{
    public class SqlCreator
    {
        public const string sqlForSync = "{sqlForSync}";
        public const string AUTHORITY_SETTINGS = "{AUTHORITY_SETTINGS}";
        public const string FACILITY_CD = "{FACILITY_CD}";
        public const string SERIES_CD = "'{SERIES_CD}'";
        public const string sqlForSpecifyPeriod = "{sqlForSpecifyPeriod}";
        public const string sqlForExclusiveOutputted = "{sqlForExclusiveOutputted}";
        public const string TABLE_NAME = "{TABLE_NAME}";
        public const string START_DATE = "{START_DATE}";
        public const string END_DATE = "{END_DATE}";
        // add FNSI-差分コンバート対応 楊 start
        public const string sqlForDiff = "{sqlForDiff}";

        /// <summary>検索条件がないのSQL</summary>
        private static List<string> sqlCondList = new List<string>()
        {
            "mst_personal_user",
            "mst_user",
            "mst_checklist",
            "mst_device_set_info_default",
            "mst_trend_graph_template",
            "pat_unique",
            "pat_personal_main",
            "pat_main"
        };
        // add FNSI-差分コンバート対応 楊 end


        /// <summary>
        /// MstSelector用SQLをMstSelectorDtoから作成し、コードと値のセットを件数分分割した
        /// SQL文字列リストで返す
        /// </summary>
        /// <param name="mstSelectorDto"></param>
        /// <returns></returns>
        /// 移行元テーブル２つ以上ある次世代テーブルに対応するためINSERT→UPSERTに変更
        public static List<string> MakeSql(MstSelectorDto mstSelectorDto,bool isDiff)
        {
            List<string> retList = new List<string>();
            foreach (var chunk in mstSelectorDto.chunkOrderSettingList())
            {
                string sql = "INSERT INTO " + MstSelectorDto.TABLE_NAME + " (" +
                string.Join(",", mstSelectorDto.columnNames) +
                ") values (" +
                 mstSelectorDto.getValues(chunk.ToList()) + ")" +
                 " ON CONFLICT(" +
                 string.Join(",", mstSelectorDto.uniqueKeys) + ")" +
                 " DO UPDATE SET " +
                 mstSelectorDto.getValuesForUpdate(chunk.ToList(), isDiff);
                retList.Add(sql);
            }
            return retList;
        }

        public static string MakeSqlForAllData(MakeSqlDto condDto)
        {
            // テンプレートSQLの取得
            string sql = condDto.sqlForTool;
           

            // 同期時の主キーを指定して取得するための条件（しない場合は空文字が設定されるようにする）
            if (condDto.isSync)
            {
                sql = sql.Replace(sqlForSync, condDto.sqlForSync);
                sql = sql.Replace("{0}", condDto.pkeyValue);
            }
            else
            {
                sql = sql.Replace(sqlForSync, "");
            }

            // add FNSI-差分コンバート対応 楊 start
            // 差分コンバートための条件
             //mod #12229 start
            if (CommonConfig.isDiff) 
             //mod #12229 end
            {

                //add 10840 薬剤,医材,ダイアライザマスタの連携コード3へコンバート対応 start
                if (CommonConstants.DIFF_IN_HOSPITAL_CD_3.Contains(condDto.tableName))
                {
                    if (CommonConfig.HashCoopSet[CommonConfig.seriesCd])
                    {
                        sql = sql.Replace("{1}", "");
                        sql = sql.Replace("{2}", "");
                    }
                }
                //add 10840 薬剤,医材,ダイアライザマスタの連携コード3へコンバート対応 start


                //add  #11576 pat_coop_detailのsave_1がGX固定でコンバートされる start
                if ("pat_coop_detail".Equals(condDto.tableName))
                {
                    if (CommonConfig.HashCoopSetSave_1[CommonConfig.seriesCd])
                    {
                        sql = sql.Replace("{1}", "");
                        sql = sql.Replace("{2}", "");
                    }
                }
                //add  #11576 pat_coop_detailのsave_1がGX固定でコンバートされる end

                sql = sql.Replace("{1}", condDto.sqlForDiff);
                if (sqlCondList.Contains(condDto.tableName))
                {
                    sql = sql.Replace("{2}", " where " + condDto.sqlForExclusiveOutputted.Substring(4));
                }
                else
                {
                    sql = sql.Replace("{2}", condDto.sqlForExclusiveOutputted);
                }
            }
            else
            {
                sql = sql.Replace("{1}", "");
                sql = sql.Replace("{2}", "");
            }
            // add FNSI-差分コンバート対応 楊 end

            // 施設コード
            sql = sql.Replace(FACILITY_CD, condDto.facilityCd);

            //mod 7997 zc start
            if (condDto.isSERIESCD.Equals("0")){              
                Regex reg = new Regex(@"(\s|\()([A-Za-z\._]{1,}\s*=\s*'\{SERIES_CD\}')");             
                sql = reg.Replace(sql, "$1 1=1");
                sql = sql.Replace("{STATUS}", "");
            }
            else {
                sql = sql.Replace(SERIES_CD, ":SERIES_CD");
                if (CommonConfig.isDiff)
                {
                    sql = sql.Replace("{STATUS}", " where  STATUS='1'");
                }
                else {
                    sql = sql.Replace("{STATUS}", "");
                }
                   
              
            }
            // 系列施設
            //sql = sql.Replace(SERIES_CD, condDto.seriesCd);
            //mod 7997 zc end

            // 権限設定用のWith句
            sql = sql.Replace(AUTHORITY_SETTINGS, condDto.authoritySettingWithBlock);


            return sql;
        }

        /// <summary>
        /// XMLを元に作成したDTO、作成条件DTOを受け取り、
        /// SQLを作成して返す。
        /// </summary>
        /// <param name="infoDto"></param>
        /// <param name="condDto"></param>
        /// <param name="isChild"></param>
        /// <returns></returns>
        public static DataTable MakeSqlForSpecifyPeriod(MakeSqlDto condDto,string type,DBCtrl db, System.DateTime ConvertDatetime, string facilityCd)
        {
            // テンプレートSQLの取得
            string sql = condDto.sqlForTool;

            // ===各置換変数の設定===
            // 期間指定（しない場合は空文字が設定されるようにする）
            sql = sql.Replace(sqlForSpecifyPeriod, condDto.isPeriod ? condDto.sqlForSpecifyPeriod : "");

            // 出力済を除外（しない場合は空文字が設定されるようにする）
            sql = sql.Replace(sqlForExclusiveOutputted, condDto.isExclusion ? condDto.sqlForExclusiveOutputted : "");

            // 同期時の主キーを指定して取得するための条件（しない場合は空文字が設定されるようにする）
            if (condDto.isSync)
            {
                sql = sql.Replace(sqlForSync, condDto.sqlForSync);
                sql = sql.Replace("{0}", condDto.pkeyValue);
            }else
            {
                sql = sql.Replace(sqlForSync, "");
            }

            // 施設コード
            sql = sql.Replace(FACILITY_CD, condDto.facilityCd);
            //mod 7997 zc start           
            // 系列施設   
            if (condDto.isSERIESCD.Equals("0"))
            {
                Regex reg = new Regex(@"(\s|\()([A-Za-z\._]{1,}\s*=\s*'\{SERIES_CD\}')");
                sql = reg.Replace(sql, "$1 1=1");
                sql = sql.Replace("{NoWITHIndTimePeriod}", "");
                sql = sql.Replace("{IndTimePeriodWhere}", "");
            }
            else
            {
                sql = sql.Replace(SERIES_CD, ":SERIES_CD");
                sql = sql.Replace("{NoWITHIndTimePeriod}", CommonConfig.NoWITHIndTimePeriod);
                string IndTimePeriodWhere = "INNER JOIN  IndTimePeriod  i on i.PATID=a.PATID and i.SERIES_CD=:SERIES_CD and  {0} >=i.START_DATE  AND  {1} <END_DATE";
                if (condDto.tableName.Equals("pat_exam_main") || condDto.tableName.Equals("pat_rad_main"))
                {
                    
                    sql = sql.Replace("{IndTimePeriodWhere}", string.Format(IndTimePeriodWhere, "a.EXAM_DATE", "a.EXAM_DATE"));

                }
                else { 
                sql = sql.Replace("{IndTimePeriodWhere}", string.Format(IndTimePeriodWhere, "a.IND_START_DATE", "a.IND_START_DATE"));

                }
            }
            //mod 7997 zc end
            // コンバート履歴取得条件のテーブル名
            sql = sql.Replace(TABLE_NAME, condDto.tableName);

           
           

            // 権限設定用のWith句
            sql = sql.Replace(AUTHORITY_SETTINGS, condDto.authoritySettingWithBlock);

            IMakeSqlParameters param = db.GetIMakeSqlParameters();

            var paramMap1 = new Dictionary<string, object>
                        {
                            { ":START_DATE", condDto.startDate },
                            { ":END_DATE", condDto.endDate },
                            { ":SERIES_CD", CommonConfig.seriesCd},
                            { ":table_kind", type },
                            { ":facility_cd", facilityCd },
                            { ":CONVERT_DATETIME", ConvertDatetime}
                        };

            CommonFunc.AutoBindSqlParams(sql, param, paramMap1);


            //mod #10418 end
            return  db.SelectTable(sql, param.GetParam());
            //add #12229 end 

        }
    }
}

