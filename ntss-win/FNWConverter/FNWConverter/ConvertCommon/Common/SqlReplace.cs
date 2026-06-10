
using Fnw.IOControl.DB;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;

namespace ConvertCommon.Common
{
    public class SqlReplace
    {

        public static string BuildExclusiveSql(
                string convertTableName,
                string sql,string diffsql,string output, string fnwTableName, DateTime ConvertDatetime ,DBCtrl db)
        {
            string key = $"{convertTableName}";
            var handlers = new Dictionary<string, Func<string>>(StringComparer.OrdinalIgnoreCase)
            {
                ["mst_pat_event_sub_category"] = () => BuildMstPatEventSubCategory(sql, diffsql, output),
                ["mst_facility_setting"] = () => BuildMstFacilitySettingSql(sql),
                ["mst_device_set_info_default"] = () => BuildMstDeviceSetInfoDefault(sql),
                ["mst_machine_record_control"] = () => BuildMstMachineRecordControl(sql),
                ["mst_pat_viewer_layout"] = () => BuildMstPatViewerLayout(sql),
                ["mst_medicine_mix"] = () => BuildMstMedicineMix(sql),
                ["mst_medicine_group"] = () => BuildMstMedicineGroup(sql),
                ["mst_exam_set"] = () => BuildMstExamSet(sql),
                ["mst_room_bed_group"] = () => BuildMstRoomBedGroup(sql, diffsql, fnwTableName),
                ["mst_treatment_set"] = () => BuildMstTreatmentSet(sql),
                ["pat_unique"] = () => BuildPatUnique(sql),
                ["pat_personal_main"] = () => BuildPatPersonalMain(sql),
                ["pat_main_history"] = () => BuildPatMainHistory(sql),
                ["pat_personal_main_history"] = () => BuildPatPersonalMainHistory(sql),
                ["pat_main"] = () => BuildPatlMain(sql, ConvertDatetime, db),
            };

            if (handlers.TryGetValue(key, out var handler))
                return handler();

            return sql;   
        }


        //add 9778 zl start
        private static string BuildMstPatEventSubCategory(string sql,string diffsql,string output) {

            if (diffsql.Length > 0)
            {
                output = output.Replace("and a.up_date ", "and ( a.up_date ") + " or " + diffsql.Replace("a.EVENT_CATEGORY_CD_2", "TO_CHAR(to_number('9' || a.KIND_ID))") + ")";

            }

            return ReplaceWhenDiff(sql, "{3}", () => output);
        }
        //add 9778 zl end

        //add 12339 コンバート対象とコンバータの設定値見直し hyl start
        private static string BuildMstFacilitySettingSql(string sql)
        {
            string mstsql = $"union all SELECT 137 AS KEY, 3131 AS FACILITY_SETTING_NO, to_date('1900/01/01') as up_date,'0' AS VALUE FROM DUAL" +
                                $" union all SELECT 140 AS KEY, 3134 AS FACILITY_SETTING_NO, to_date('1900/01/01') as up_date,'1' AS VALUE FROM DUAL" +
                                $" union all SELECT 133 AS KEY, 3127 AS FACILITY_SETTING_NO, to_date('1900/01/01') as up_date,'1' AS VALUE FROM DUAL";


             return sql.Replace("{4}", mstsql);

        }
        //add 12339 コンバート対象とコンバータの設定値見直し hyl end

        private static string BuildMstDeviceSetInfoDefault(string sql)
        {


            string childStr = @" or 0 < (select count(1) from  SYS_DEVICE_DEFAULT a where a.UP_DATE > :CONVERT_DATETIME)
                                  or 0 < (select count(1) from    SYS_SYSTEM_DEFINE a where a.UP_DATE > :CONVERT_DATETIME)";
            return ReplaceWhenDiff(sql, "{3}", () => childStr);

        }

        //add #11781 start
        private static string BuildMstMachineRecordControl(string sql)
        {

            string childStr = " or 0 < (select count(1) from SYS_SYSTEM_DEFINE a where  id='511' and a.UP_DATE > :CONVERT_DATETIME) ";
            return ReplaceWhenDiff(sql, "{3}", () => childStr);

        }
        //add #11781 end

        //add #11773 start
        private static string BuildMstPatViewerLayout(string sql)
        {
            string childStr = @" or 0 < (select count(1) from SYS_SYSTEM_DEFINE a where id in(211,212,216,215,217,218,222,221,224,223,226,225,584,583,589,588,228,227,234,233,236,235 ) 
                                and  a.UP_DATE > :CONVERT_DATETIME) 
                                   or 0 < (select count(1) from MST_MEDICINE_GROUP a 
                                            where  a.UP_DATE > :CONVERT_DATETIME) 
                                   or 0 < (select count(1) from MST_EXAM_ITEM a 
                                               where a.REG_DATE> :CONVERT_DATETIME) ";
            return ReplaceWhenDiff(sql, "{3}", () => childStr);
        }
        //add #11773 end


        private static string BuildMstMedicineMix(string sql) {

            string childStr = $" or a.SET_MEDICINE_CD in ( select a.SET_MEDICINE_CD from MST_SET_MEDICINE a INNER JOIN MST_MEDICINE b on a.MEDICINE_CD = b.MEDICINE_CD    where not exists( select * from MST_SET_MEDICINE b where a.SET_MEDICINE_CD = b.SET_MEDICINE_CD  and a.MEDICINE_CD = b.MEDICINE_CD and a.UP_DATE  < b.UP_DATE)  ";
            // mod #12392 gcl start
            string existsSyncSetMedicine = $"EXISTS (SELECT 1 FROM SYNC_SET_MEDICINE s INNER JOIN MST_MEDICINE_SUB_NEW d ON s.MEDICINE_CD = d.MEDICINE_CD and s.SERIES_CD=:SERIES_CD WHERE B.SET_MEDICINE_CD = s.SET_MEDICINE_CD AND d.MEDICINE_CD = B.MEDICINE_CD AND (d.DISP_FLG = '0' AND s.FUNCTION_CD = '1' OR b.UP_DATE = (SELECT MAX(b2.UP_DATE) FROM MST_MEDICINE b2 WHERE b2.MEDICINE_CD = b.MEDICINE_CD AND b2.DEL_FLG = '1')))";
            string existsLatestSet = "EXISTS (WITH max_name_sub AS (SELECT SET_MEDICINE_CD, MAX(UP_DATE) AS max_up FROM MST_SET_MEDI_NAME_SUB_NEW GROUP BY SET_MEDICINE_CD), latest_set AS (SELECT a.* FROM MST_SET_MEDICINE a INNER JOIN max_name_sub m ON a.SET_MEDICINE_CD = m.SET_MEDICINE_CD AND a.UP_DATE = m.max_up WHERE a.DEL_FLG = '0') SELECT 1 FROM latest_set s INNER JOIN MST_MEDICINE_SUB_NEW d ON s.MEDICINE_CD = d.MEDICINE_CD AND d.DISP_FLG = '1' LEFT JOIN (SELECT DISTINCT TRIM(SET_MEDICINE_CD) AS SET_MEDICINE_CD, TRIM(MEDICINE_CD) AS MEDICINE_CD, FUNCTION_CD FROM SYNC_SET_MEDICINE) x ON x.SET_MEDICINE_CD = TRIM(s.SET_MEDICINE_CD) AND x.MEDICINE_CD = TRIM(s.MEDICINE_CD) AND x.FUNCTION_CD = '1' WHERE x.SET_MEDICINE_CD IS NULL AND s.SET_MEDICINE_CD = B.SET_MEDICINE_CD AND s.MEDICINE_CD = B.MEDICINE_CD)";
            childStr += $"  and exists( select * from MST_SET_MEDI_NAME_SUB_NEW c where a.SET_MEDICINE_CD = c.SET_MEDICINE_CD) and not exists( select * from MST_MEDICINE c where b.MEDICINE_CD = c.MEDICINE_CD and b.UP_DATE  < c.UP_DATE) and a.DEL_FLG = '0' and B.up_date > :CONVERT_DATETIME or {existsSyncSetMedicine} or {existsLatestSet}) ";
            // mod #12392 gcl end
            return ReplaceWhenDiff(sql, "{3}", () => childStr);

        }
        private static string BuildMstMedicineGroup(string sql) {

            // mod #12392 gcl start
            string existsSyncGroupMedicine = $"exists(select 1 from SYNC_SET_MEDICINE s inner join MST_MEDICINE_SUB_NEW d on s.MEDICINE_CD = d.MEDICINE_CD and s.SERIES_CD=:SERIES_CD where s.SET_MEDICINE_CD = mgd.MEDICINE_GROUP_CD and d.MEDICINE_CD = mgd.MEDICINE_CD and ((d.DISP_FLG = '0' and s.FUNCTION_CD = '2') or d.UP_DATE = (select max(b2.UP_DATE) from MST_MEDICINE b2 where b2.MEDICINE_CD = d.MEDICINE_CD and b2.DEL_FLG = '1')))";
            string existsLatestGroup = "EXISTS ( SELECT grp.MEDICINE_GROUP_CD, grp.MEDICINE_CD FROM ( SELECT lgd.MEDICINE_GROUP_CD, lgd.MEDICINE_CD, ROW_NUMBER() OVER ( PARTITION BY lgd.MEDICINE_GROUP_CD, lgd.MEDICINE_CD ORDER BY lgd.MEDICINE_UPDATE DESC ) AS rn FROM MST_MEDICINE_GROUP_DETAIL lgd WHERE lgd.DEL_FLG = '0' ) grp JOIN MST_MEDICINE_SUB_NEW d ON d.MEDICINE_CD = grp.MEDICINE_CD AND d.DISP_FLG = '1' LEFT JOIN SYNC_SET_MEDICINE s ON s.SET_MEDICINE_CD = grp.MEDICINE_GROUP_CD AND s.MEDICINE_CD = grp.MEDICINE_CD AND s.FUNCTION_CD = '2' WHERE grp.rn = 1 AND s.SET_MEDICINE_CD IS NULL AND grp.MEDICINE_GROUP_CD = mgd.MEDICINE_GROUP_CD AND grp.MEDICINE_CD = mgd.MEDICINE_CD )";
            string childStr = $"or MEDICINE_GROUP_CD in (select MEDICINE_GROUP_CD from MST_MEDICINE_GROUP_DETAIL mgd where MEDICINE_CD in (select MEDICINE_CD from MST_MEDICINE where (up_date > :CONVERT_DATETIME or {existsSyncGroupMedicine} or {existsLatestGroup}))) AND NOT EXISTS ( SELECT 1 FROM MST_MEDICINE_GROUP x WHERE x.MEDICINE_GROUP_CD = a.MEDICINE_GROUP_CD AND x.UP_DATE > a.UP_DATE )";
            // mod #12392 gcl end
            return ReplaceWhenDiff(sql, "{3}", () => childStr);

        }

        private static string BuildMstExamSet(string sql) {

            string childStr = @" or a.EXAM_SET_CD in ( SELECT a.exam_set_cd FROM ( SELECT * FROM mst_exam_set_detail mes1 WHERE NOT substr(mes1.exam_set_cd,1,1)='X' AND NOT EXISTS (SELECT * FROM mst_exam_set_detail mes2 WHERE mes1.exam_kind_cd = mes2.exam_kind_cd AND mes1.exam_set_cd = mes2.exam_set_cd AND mes1.EXAM_ITEM_CD = mes2.EXAM_ITEM_CD AND mes1.up_date < mes2.up_date ) and DEL_FLG = '0') a  
                                  where  a.EXAM_ITEM_CD in ( SELECT exam_item_cd FROM mst_exam_item msi1 WHERE NOT substr(msi1.exam_item_cd, 1, 1) = 'X'  AND msi1.REG_DATE> :CONVERT_DATETIME)) ";
            return ReplaceWhenDiff(sql, "{3}", () => childStr);

        }


        private static string BuildMstRoomBedGroup(string sql,string diffsql,string fnwTableName) 
        {
            string childStr = null;
            if ("MST_BED_GROUP".Equals(fnwTableName))
            {
                 childStr = $"  and (a.REG_DATE> :CONVERT_DATETIME OR 0< (select count(1) from MST_BED a where a.REG_DATE > :CONVERT_DATETIME))";
            }
            if ("MST_ROOM".Equals(fnwTableName))
            {
                if (diffsql.Length > 0)
                {
                    diffsql = " or " + diffsql;
                }

                 childStr = $"  and (a.UP_DATE > :CONVERT_DATETIME OR 0< (select count(1) from MST_BED a where a.REG_DATE > :CONVERT_DATETIME) " + diffsql + ")";


            }
            return ReplaceWhenDiff(sql, "{3}", () => childStr);

        }

        private static string BuildMstTreatmentSet(string sql) {
            if (CommonConfig.isDiff)
            {
                //add 7997 start
                string sSeriesCD = " 1=1";
                if ("1".Equals(CacheInformation.Instance.FacilityCd))
                {
                    sSeriesCD = $" SERIES_CD = :SERIES_CD";
                }
                //add 7997 end
                string notExists = $" up_date > :CONVERT_DATETIME ";
                string childStr = $" AND ( {notExists}";
                childStr += $" or 0 < (select count(1) from  SYS_DEVICE_DEFAULT a where {notExists})";
                // mod #9673 差分コンバートでFNWのアクションチャート設定がFNSiに正しく反映されない zs start
                childStr += $" or 0 < (select count(1) from  SYS_ACTCHART_DEFINE_EQUIP a where {notExists})) AND ROWNUM = 1 ";
                sql = sql.Replace("{3}", childStr);
                sql = sql.Replace("{initValue}", "TREATMENT_CD.treatment_cd AS treatment_cd");
                sql = sql.Replace("{treatmentSetCd}", $" with TREATMENT_CD AS (SELECT INIT_VALUE AS treatment_cd FROM sys_actchart_define A, ( SELECT ctl_no AS ctl_no2, MAX ( up_date ) AS up_date2 FROM sys_actchart_define WHERE {sSeriesCD}  GROUP BY ctl_no ORDER BY 1 ) sad2 WHERE {sSeriesCD} AND A.CTL_NO = sad2.ctl_no2  AND A.UP_DATE = sad2.up_date2 AND ctl_no = '006')");
                sql = sql.Replace("{treatmentCd}", ",TREATMENT_CD");
                // mod #9673 差分コンバートでFNWのアクションチャート設定がFNSiに正しく反映されない zs end
            }
            else
            {
                // mod #9673 差分コンバートでFNWのアクションチャート設定がFNSiに正しく反映されない zs start
                string childStr = $" and ctl_no = '006'";
                sql = sql.Replace("{3}", childStr);
                sql = sql.Replace("{initValue}", "INIT_VALUE as treatment_cd");
                sql = sql.Replace("{treatmentSetCd}", "");
                sql = sql.Replace("{treatmentCd}", "");
                // mod #9673 差分コンバートでFNWのアクションチャート設定がFNSiに正しく反映されない zs end
            }
            return sql;

        }

        // #8400 zl start
        private static string BuildPatUnique(string sql) {

            string notExists = $" a.up_date > :CONVERT_DATETIME ";
            string childStr = $" OR PATID IN (SELECT DISTINCT PATID FROM (SELECT  PATID FROM PAT_MEDICAL_HST a WHERE {notExists}";
            childStr += $" UNION ALL  SELECT  PATID FROM PAT_INOUT a WHERE {notExists}";
            //10771 zc  start
            childStr += $" UNION ALL SELECT  PATID FROM PAT_CTR a WHERE {notExists}";
            childStr += $" UNION ALL SELECT  PATID FROM IND_DIALYSIS_COND  a WHERE {notExists}))";
            //10771 zc  end
            return ReplaceWhenDiff(sql, "{3}", () => childStr);
        }

        private static string BuildPatPersonalMain(string sql) {

            if (CommonConfig.isDiff && CommonConfig.diffPatPersonalMainAll == false)
            {
                string notExists = $"a.up_date > :CONVERT_DATETIME";
                string childStr = $" OR PATID IN ( SELECT DISTINCT PATID FROM PAT_INSURANCE a WHERE {notExists}";
                childStr += $" UNION SELECT DISTINCT PATID FROM PAT_CONTACT a WHERE {notExists}";
                childStr += $" UNION SELECT DISTINCT PATID FROM PAT_RECEIPT_MEMO a WHERE {notExists} )";
                sql = sql.Replace("{3}", childStr);
            }
            else
            {
                sql = sql.Replace("{3}", "");
            }
            return sql;
        }

        // #8400 zl end

        //add 11383 start
        private static string BuildPatMainHistory(string sql) {


            string sqlUnion = "";
            if (CommonConfig.diffPatMainMongo)
            {
                sqlUnion = "UNION ALL  SELECT  PATID, TO_DATE('" + CommonConfig.appStartTime + "', 'YYYY -MM-DD HH24:MI:SS') FROM  PAT_BASIC_INFO_NOW";
            } //add 12232 start
            else if (CommonConfig.isDiff)
            {

                sqlUnion = "UNION ALL  SELECT PATID,  max(UP_DATE) as UP_DATE  FROM  RST_DIALYSIS  GROUP BY PATID";

            }//add 12232 end
            
            return sql.Replace("{3}", sqlUnion);
        }

        private static string BuildPatPersonalMainHistory(string sql) {

            string sqlUnion = "";
            if (CommonConfig.diffPatPersonalMainMongo)
            {
                sqlUnion= "UNION ALL  SELECT  PATID, TO_DATE('" + CommonConfig.appStartTime + "', 'YYYY -MM-DD HH24:MI:SS') FROM  PAT_BASIC_INFO_NOW";
            }
           
            return sql.Replace("{3}", sqlUnion);

        }
        //add 11383 end


        // 2023-04-18 ADDED BY 周トウ 患者情報（pat_main）差分前に変更するの患者ID 子テーブルよりを取得する Start
        private static string BuildPatlMain(string sql, DateTime ConvertDatetime, DBCtrl db) {

            if (CommonConfig.isDiff && CommonConfig.diffPatMainAll == false)
            {
                // Diff用のSQLを取得
                string patMainDiffSql = "SELECT DISTINCT b.PATID FROM ("
                    + "SELECT PDS.PATID, PDS.REG_DATE AS UP_DATE FROM PAT_DEVICE_SET PDS WHERE PDS.DAY_OF_WEEK = -1 GROUP BY PDS.PATID, PDS.REG_DATE "
                    + " UNION ALL SELECT PFC.PATID,PFC.UP_DATE FROM PAT_FREE_COMMENT PFC GROUP BY PFC.PATID, PFC.UP_DATE"
                    + " UNION ALL SELECT PINF.PATID,PINF.UP_DATE FROM PAT_INFECT PINF GROUP BY PINF.PATID, PINF.UP_DATE"
                    + " UNION ALL SELECT PRM.PATID, PRM.UP_DATE FROM PAT_RECEIPT_MEMO PRM GROUP BY PRM.PATID,PRM.UP_DATE"
                    + " UNION ALL SELECT PRO.PATID, PRO.UP_DATE FROM PAT_REVISE_OFFWATER PRO GROUP BY PRO.PATID,PRO.UP_DATE"
                    + " UNION ALL SELECT PRT.PATID, PRT.UP_DATE FROM PAT_REVISE_TARE PRT GROUP BY  PRT.PATID, PRT.UP_DATE"
                    + " UNION ALL SELECT PT.PATID, PT.UP_DATE FROM  PAT_TABOO PT GROUP BY PT.PATID, PT.UP_DATE"
                    + " UNION ALL SELECT PT.PATID,  max(PT.UP_DATE) as UP_DATE  FROM  RST_DIALYSIS PT GROUP BY PT.PATID"
                    + ") b WHERE {1}";

                // Convert対応条件
                string sqlForExclusiveOutputted = $" b.up_date > : CONVERT_DATETIME";

                patMainDiffSql = patMainDiffSql.Replace("{1}", sqlForExclusiveOutputted);

                // 変更するの患者ID
                IMakeSqlParameters param3 = db.GetIMakeSqlParameters();
                param3.AddParam(":CONVERT_DATETIME", ConvertDatetime);
                DataTable patIdData = db.SelectTable(patMainDiffSql, param3.GetParam());
                List<string> litRate = patIdData.AsEnumerable().Select(r => r["PATID"].ToString()).ToList<string>();
                var listPatidList = litRate.Select((patid, index) => new { patid, index })
                       .GroupBy(x => x.index / 999)
                       .Select(g => g.Select(x => x.patid));
                if (patIdData.Rows.Count > 0)
                {
                    string sqlCondForDiff = string.Empty;
                    foreach (var procPatidList in listPatidList)
                    {
                        List<string> chunkPatIdList = procPatidList.ToList();
                        string tmpCondPatIds = string.Empty;
                        for (var i = 0; i < chunkPatIdList.Count(); i++)
                        {
                            tmpCondPatIds += "'" + chunkPatIdList[i].ToString() + "',";
                        }
                        if (tmpCondPatIds.EndsWith(","))
                        {
                            tmpCondPatIds = tmpCondPatIds.Remove(tmpCondPatIds.LastIndexOf(",")
                                , tmpCondPatIds.Length - tmpCondPatIds.LastIndexOf(","));
                        }

                        sqlCondForDiff += "or a.PATID IN (" + tmpCondPatIds + ")";
                    }

                    sql = sql.Replace("{3}", sqlCondForDiff);
                }
                else
                {
                    sql = sql.Replace("{3}", "");
                }
            }
            else
            {
                sql = sql.Replace("{3}", "");
            }
            return sql;
        }
        // 2023-04-18 ADDED BY 周トウ End

        private static string ReplaceWhenDiff(string sql, string placeholder, Func<string> diffBuilder)
        {
            if (!CommonConfig.isDiff)
                return sql.Replace(placeholder, "");

            return sql.Replace(placeholder, diffBuilder());
        }
    }
}
