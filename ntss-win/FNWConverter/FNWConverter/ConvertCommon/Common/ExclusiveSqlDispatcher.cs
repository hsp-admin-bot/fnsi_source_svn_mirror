using ConvertCommon.Const;
using ConvertCommon.dto;
using ConvertCommon.parts;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using static ConvertCommon.Common.CommonConfig;

namespace ConvertCommon.Common
{
    public static class ExclusiveSqlDispatcher
    {
        private static readonly Dictionary<string, Func<string>> TableHandlers =
            new Dictionary<string, Func<string>>
            {
                ["mst_exam_item"] = BuildMstExamItemSql,
                ["mst_treatment|MST_TREAT_ITEM"] = BuildMstTreatmentSql,
                ["__DEFAULT__"] = BuildDefaultSql
            };

        //9679 zc start
        private static string BuildMstExamItemSql()
        {
            return "and ( (a.REG_DATE>:CONVERT_DATETIME or c.UP_DATE > :CONVERT_DATETIME ) " +
                       " or a.EXAM_ITEM_CD in ( select DISTINCT EXAM_ITEM_CD from MST_EXAM_CALC_ITEM WHERE CALC_ITEM_CD IN (select DISTINCT CALC_ITEM_CD from MST_EXAM_CALC_ITEM " +
                       " WHERE MST_EXAM_CALC_ITEM.UP_DATE > :CONVERT_DATETIME) and EXAM_ITEM_CD is not null )" +
                       " or a.EXAM_ITEM_CD in (select DISTINCT EXAM_ITEM_CD from MST_EXAM_SET_DETAIL WHERE EXAM_KIND_CD || EXAM_SET_CD IN(select DISTINCT EXAM_KIND_CD || EXAM_SET_CD " +
                       " from MST_EXAM_SET WHERE MST_EXAM_SET.UP_DATE > :CONVERT_DATETIME) and EXAM_ITEM_CD is not null )" +
                       ")";
        }
        //9679 zc end

        private static string BuildDefaultSql()
        {
            return " and a.REG_DATE >:CONVERT_DATETIME ";
        }
        //add 10470 start
        private static string BuildMstTreatmentSql()
        {
            return @"AND (a.REG_DATE > :CONVERT_DATETIME  or 
                           a.TREAT_ITEM_CD in( (select TREAT_ITEM_CD from SYS_TREAT_COND_SETTING a where  a.up_date >:CONVERT_DATETIME ))  or 
                           a.TREAT_ITEM_CD in((select TREAT_ITEM_CD from SYS_TREAT_MONITOR_SETTING a where a.up_date > :CONVERT_DATETIME ))  or 
                           0 < (select count(1)   from  SYS_SYSTEM_DEFINE a where id in('679','554','558','676','677','678','555','559','676','677','678','593','594','676','677','678','556','560','681','682','683','557','561','671','672','673',
                           '562','572','576','577','575','578','579','590','580','581','582','583','584','591','585','586','587','588','589','592','611','612','613','614','615','616','617','621','622','623','624','625','626','627',
                            '631','632','633','634','635','636','637','641','642','643','644','645','646','647','651','652','653','654','655','656','657','661','662','663','664','665','666','667')
                              and a.UP_DATE > :CONVERT_DATETIME))";
        }
        //add 10470 end

        public static string Resolve(string convertTableName, string fnwTableName)
        {
            string key = $"{convertTableName}|{fnwTableName}";

            if (TableHandlers.TryGetValue(key, out var handler))
                return handler();

            if (TableHandlers.TryGetValue(convertTableName, out handler))
                return handler();

            return TableHandlers["__DEFAULT__"]();
        }




        public static string BuildExclusiveSql(
                string convertTableName,
                string fnwTableName)
        {
            string key = $"{convertTableName}|{fnwTableName}";
            var handlers = new Dictionary<string, Func<string>>(StringComparer.OrdinalIgnoreCase)
            {
                ["mst_take_medicine|*"] = BuildMstTakeMedicineSql,
                ["mst_weight|*"] = BuildMstWeightSql,
                ["pat_group_detail|MST_PAT_GROUP"] = BuildPatGroupDetailSql,
                ["mst_machine|MST_DEVICE"] = BuildMstMachineSql,
                ["mst_facility_setting|SYS_SYSTEM_DEFINE"] = BuildMstFacilitySettingSql,
                ["mnt_water_survey|MNT_WATER_SURVEY"] = BuildMntWaterSurveySql,
                ["mst_water_survey_type|MST_WATER_SURVEY_TYPE"] = BuildMstWaterSurveyTypeSql,
                ["mnt_mainte_main|MNT_PERIOD_CHECKLIST"] = BuildMntMainteMainSql,
                ["bbs_info|PAT_BBS_INF"] = BuildBbsInfoSql,
                ["mst_bed|MST_BED"] = BuildMstBedSql,
                ["__DEFAULT__"] = () => BuildDefaultDiffSql(convertTableName, fnwTableName)
            };

            if (handlers.TryGetValue(key, out var handler))
                return handler();
            key = $"{convertTableName}|*";
            if (handlers.TryGetValue(key, out handler))
                return handler();
            return handlers["__DEFAULT__"]();
        }

        //mod 8400 zc start
        private static string BuildMstTakeMedicineSql()
        {
            return "and exists(SELECT * from MST_TAKE_MEDICINE c where   c.up_date > :CONVERT_DATETIME) ";
        }
        //mod 8400 zc end

        //9666 zc start
        private static string BuildMstWeightSql()
        {
            return @"AND(a.up_date > :CONVERT_DATETIME   or
                               0 < (select count(1) from MST_FREE_OPERATES a where a.up_date > :CONVERT_DATETIME))";
        }
        //9666 zc end

        private static string BuildPatGroupDetailSql()
        {
            return " AND b.REG_DATE > :CONVERT_DATETIME";
        }

        //8009 zc start
        private static string BuildMstMachineSql()
        {
            return @" AND(a.up_date > :CONVERT_DATETIME  OR  b.up_date > :CONVERT_DATETIME
                         OR a.DEVICE_NO in(SELECT  a.DEVICE_NO  FROM MST_DEVICE a  INNER JOIN  SYNC_MST_DEVICE_HIS s on s.DEVICE_NO = a.DEVICE_NO and s.DEVICE_OPTION != a.DEVICE_OPTION
                        WHERE  NOT EXISTS(SELECT * FROM MST_DEVICE b WHERE a.DEVICE_NO = b.DEVICE_NO AND a.UP_DATE < b.UP_DATE) ) )";
        }
        //8009 zc end



        private static string BuildMntWaterSurveySql()
        {
            return @" AND (a.up_date > :CONVERT_DATETIME	
                        OR 0 < ( SELECT count(1) FROM MST_WATER_SURVEY_TYPE a WHERE a.UP_DATE > :CONVERT_DATETIME))";
        }

        //add #10663 djy start
        private static string BuildMstWaterSurveyTypeSql()
        {

            return @" AND (a.up_date > :CONVERT_DATETIME 	
                 OR 0 < ( SELECT count(1) FROM SYNC_WATER_SURVEY_TYPE_TEXT a WHERE a.UP_DATE > :CONVERT_DATETIME))";
        }
        //add #10663 djy end

        // add #10870 zkm start
        private static string BuildMntMainteMainSql()
        {

            return @" AND (MPCP.up_date > :CONVERT_DATETIME  OR  CR.up_date > :CONVERT_DATETIME)";
        }


        private static string BuildMstFacilitySettingSql()
        {

            string sqlForExclusiveOutputtedStr = @" AND (a.up_date > :CONVERT_DATETIME	OR 0 < ( SELECT count(1) FROM SYS_DEFAULT_SETTING a WHERE a.UP_DATE >:CONVERT_DATETIME)  OR 0 < ( SELECT count(1) FROM SYS_WEIGHT_SETTING a WHERE a.UP_DATE >:CONVERT_DATETIME))";
            //add 12339 コンバート対象とコンバータの設定値見直し hyl start
            sqlForExclusiveOutputtedStr = sqlForExclusiveOutputtedStr.Replace("{4}", "");
            //add 12339 コンバート対象とコンバータの設定値見直し hyl end
            return sqlForExclusiveOutputtedStr;
        }


        //add #11579 start
        private static string BuildBbsInfoSql()
        {
            string patId = "";
            if (CacheInformation.Instance.FacilityCd.Equals("1"))
            {
                List<string> patIdList = new List<string>();
                foreach (PatProcInfo pp in CommonConfig.patProcInfoList)
                {
                    if (pp.isFirst.Equals("1"))
                    {
                        patIdList.Add(pp.PatId);
                    }
                }
                if (patIdList.Count > 0)
                {
                    patId = "or" + CommonFunc.MakeInClause("PATID", 1000, patIdList);
                }

            }
            //add 7997 初めての転院のbbs_info end

            return @"AND (a.up_date > :CONVERT_DATETIME  
                      or  a.SEQ_ID in (  select  DISTINCT SEQ_ID  from PAT_BBS_PAT b  INNER JOIN  PAT_INDEX_INFO a  ON a.PATID=b.PATID
                    WHERE a.PAT_REG_DATE > :CONVERT_DATETIME AND pat_status = 1) " + patId + ")";
        }
        //add #11579 end



        //add #7997 装置変更に伴い、関連するベッド差分が生じる start
        private static string BuildMstBedSql()
        {
            return @"AND ( a.REG_DATE > :CONVERT_DATETIME 
                or a.DEVICE_NO in(select DEVICE_NO from MST_DEVICE where UP_DATE>:CONVERT_DATETIME  and SERIES_CD=':SERIES_CD') )";
        }
        //add #7997 装置変更に伴い、関連するベッド差分が生じる end


        //add #11383  mst_addition start  
        public static string BuildSqlForTool(string sqlForTool, string xmlConfigName)
        {
            if ((CommonConfig.diffPatMainAll && "PAT_BASIC_INFO-pat_main".Equals(xmlConfigName)) || (CommonConfig.diffPatPersonalMainAll && "PAT_BASIC_INFO-pat_personal_main".Equals(xmlConfigName)))
            {
                sqlForTool = sqlForTool.Replace("{3}", "");
                sqlForTool = sqlForTool.Replace("{1}", "");
                sqlForTool = sqlForTool.Replace("{2}", "");
                sqlForTool = sqlForTool.Replace("{sqlForSync}", "");
            }
            return sqlForTool;
        }
        //add 11383 end
        private static string BuildDefaultDiffSql(string convertTableName, string fnwTableName)
        {
            //add 7997 start 
            if (CacheInformation.Instance.FacilityCd.Equals("1") && CommonConstants.DIFF_PAT_INFO_SYNCHRONIZA.Contains(fnwTableName + "-" + convertTableName))
            {
                string patId = "";
                List<string> patIdList = new List<string>();
                foreach (PatProcInfo pp in CommonConfig.patProcInfoList)
                {
                    if (pp.isFirst.Equals("1"))
                    {
                        patIdList.Add(pp.PatId);
                    }
                }
                if (patIdList.Count > 0)
                {
                    patId = "or" + CommonFunc.MakeInClause("a.PATID", 1000, patIdList);
                }
                return "and (a.up_date > :CONVERT_DATETIME " + patId + ")";
            }
            else
            {
                return "and a.up_date > :CONVERT_DATETIME ";

            }
            //add 7997 end 
        }


        public static MakeSqlDto BuildSqlDto(string sqlForTool,string sqlForSync, string sqlForDiff, string sqlForExclusiveOutputted,bool isSync,string mstCd,string convertTableName)
        {
            // 権限設定用SQLの取得
            string authoritySettingWithBlock = AuthoritySettingsDtoUtil.authoritySettingWithBlock;

            var condDto = new MakeSqlDto
            {
                sqlForTool = sqlForTool,
                sqlForSync = sqlForSync,
                sqlForDiff = sqlForDiff,
                sqlForExclusiveOutputted = sqlForExclusiveOutputted,
                seriesCd = CommonConfig.seriesCd,
                isSync = isSync,
                pkeyValue = mstCd,
                isSERIESCD = CacheInformation.Instance.FacilityCd,
                facilityCd = CommonConfig.FacilityCd,
                authoritySettingWithBlock = authoritySettingWithBlock,
                tableName =convertTableName,
            };

            return condDto;
        }

        //add #11902 セコム連携 COP_COOP_SEND_HST.MEMOのコンバート start
        public static string BuildSecomSql() {

            return @"WITH PAT_BASIC_INFO_NORMAL AS ( SELECT w1.PATID
                                    FROM PAT_BASIC_INFO w1 INNER JOIN PAT_INDEX_INFO w2 ON(w1.PATID= w2.PATID AND w1.REG_DATE= w2.PAT_REG_DATE)
                                    INNER JOIN(SELECT DISTINCT PATID, SERIES_CD
                                    FROM (
                                    SELECT PATID, FROM_SERIES_CD AS SERIES_CD
                                    FROM SYS_PAT_MOVE_PLAN
                                    UNION ALL
                                    SELECT PATID, TO_SERIES_CD
                                    FROM SYS_PAT_MOVE_PLAN {STATUS}
                                    UNION ALL
                                    SELECT PATID, SERIES_CD
                                    FROM SYS_PAT_SERIES_FACILITY where MAIN_FLG= '1' AND  S.SERIES_CD='{SERIES_CD}'
                                    )) s on s.PATID=w1.PATID )
                        ,
                        COOP_DATA AS(
                            SELECT
                                p.PATID,
                                c.COOP_ID,
                                c.MEMO,
                                c.UP_DATE,c.SPECIFIC_KEY
                            FROM COP_COOP_SEND_HST c
                            INNER JOIN PAT_BASIC_INFO_NORMAL p
                                ON p.PATID = SUBSTR(c.SPECIFIC_KEY, 16, 12)
                            WHERE c.COOP_ID = 'SCM02' and  c.SEND_CLASS!=2 and  MEMO is not null
                            UNION ALL
                            SELECT
                                p.PATID,
                                c.COOP_ID,
                                c.MEMO,
                                c.UP_DATE,c.SPECIFIC_KEY
                            FROM COP_COOP_SEND_HST c
                            INNER JOIN RST_DIALYSIS d
                                ON TO_CHAR(d.DIALYSIS_NO) = c.SPECIFIC_KEY
                            INNER JOIN PAT_BASIC_INFO_NORMAL p
                                ON p.PATID = d.PATID
                            WHERE c.COOP_ID in ('SCM03','SCM04','SCM09')  and  c.SEND_CLASS!=2 and  MEMO is not null
                            UNION ALL
                            SELECT
                                p.PATID,
                                c.COOP_ID,
                                c.MEMO,
                                c.UP_DATE,c.SPECIFIC_KEY
                            FROM COP_COOP_SEND_HST c
                            INNER JOIN PAT_BASIC_INFO_NORMAL p
                                ON p.PATID = SUBSTR(c.SPECIFIC_KEY, 1, 12)
                            WHERE c.COOP_ID in ('SCM05','SCM06') and  c.SEND_CLASS!=2 and  MEMO is not null
                        )
                        SELECT
                            SPECIFIC_KEY as PKEY,
                            PATID,
                            COOP_ID,
                            MEMO,
                            UP_DATE,
                            'Secom' as COOPVERSION,
                           '{""pkg"": ""Secom""}' as SAVE_1
                        FROM(
                            SELECT
                                PATID,
                                COOP_ID,
                                MEMO,
                                UP_DATE,SPECIFIC_KEY,
                                ROW_NUMBER() OVER (
                                    PARTITION BY PATID
                                    ORDER BY UP_DATE DESC
                                ) RN
                            FROM COOP_DATA
                        ) a
                        WHERE RN = 1 {2}";

        }
        //add #11902 セコム連携 COP_COOP_SEND_HST.MEMOのコンバート end
    }

}
