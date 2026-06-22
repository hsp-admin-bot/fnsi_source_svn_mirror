using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using ConvertCommon.Common;
using ConvertCommon.Const;
using ConvertCommon.dto;
using Newtonsoft.Json.Linq;

namespace ConvertCommon
{
    /// <summary>
    /// コンバート処理クラス(Motion)
    /// </summary>
    sealed public class ConvertMotion : ConvertBase
    {

        private readonly RelationCacheBaseXml _relationCache;
        private static readonly Regex ConditionRegex =
              new Regex(@"(\s)([A-Za-z\._]*\s*=\s*'\{4\}')", RegexOptions.Compiled);
        public override int FnwDataRowCount()
        {
            return dtFnwData.Rows.Count;
        }
        /// <summary>
        /// コンストラクタ
        /// </summary>
        public ConvertMotion() {
            _relationCache = new RelationCacheBaseXml(
                     () => "mnt_motion_record"
                 );
        }
        public  bool isAttention = false;

        public override DataRow[] GetRelationArray(string xmlName, string fnwColName, string ntssColNo)
        {

            return _relationCache.GetRelationArray(xmlName, fnwColName);

        }
        /// <summary>
        /// マスタを取得
        /// </summary>
        /// <remarks>
        /// マスタ情報定義XMLからSQLを読み込んで実行する
        /// </remarks>
        /// <returns>成功：true、失敗：false</returns>

        public override bool SetFnwDataForMotion(string url,  DateTime startDate, DateTime endDate, string tableName)
        {
            WriteTraceLog("===== コンバート元データ取得処理開始 =====");

            // XMLConfigNameの設定
            string xmlConfigName = this.fnwTableName + "-" + this.convertTableName;
            // 権限設定用SQLの取得
            string authoritySettingWithBlock = AuthoritySettingsDtoUtil.authoritySettingWithBlock;

            rootNodeTableInfo tableConfig = ConfigMotionInfoDtoUtil.getTableInfoByXmlConfigName(xmlConfigName);

            MakeSqlDto condDto;
            string sqlForTool = tableConfig.sqlForTool;
            condDto = new MakeSqlDto
             {
                sqlForTool = sqlForTool,
                sqlForSync = tableConfig.sqlForSync,
                sqlForDiff = "",
                sqlForExclusiveOutputted = "",
                seriesCd = this.seriesCd,
                authoritySettingWithBlock = authoritySettingWithBlock
            };

            //------------------------------------
            // 主テーブルを取得
            //------------------------------------
            string sql;
            sql = condDto.sqlForTool;
            if (tableName.Contains("LOG_DEV_MENTE")) {

                //mod #10418 start
                var param2 = db.GetIMakeSqlParameters();
                param2.AddParam(":table_name", tableName);
                DataTable dt=db.SelectTable("select count(*) as COUNT  from all_tab_columns where table_name=:table_name  and column_name='CCP_SELFDIAG_MEASURE_DATE'", param2.GetParam());
                //mod #10418 end
                int con = 0;
                if (dt != null)
                {
                    con = int.Parse(dt.Rows[0]["COUNT"].ToString());
                }
                if (con ==0) {
                    StringBuilder sb = new StringBuilder();
                    sb.Append(@"WITH MST_DEVICE_list AS(
                                        SELECT
                                        m.DEVICE_NO
                                        FROM
                                        MST_DEVICE m
                                        where 1 = 1  ");
                        if (CacheInformation.Instance.FacilityCd.Equals("1")) {
                            sb.Append(" AND m.SERIES_CD=:SERIES_CD");
                        }

                        sb.Append(@" AND NOT EXISTS ( SELECT * FROM MST_DEVICE b WHERE m.DEVICE_NO = b.DEVICE_NO AND m.UP_DATE < b.UP_DATE )
			                            ),
　　　　　　　　　　　　　　　　　　　　　UFRC_DATE AS (
			                                    SELECT
			                                    null as event_reg_date,
			                                    null as m_notice_status,
			                                    ldm.MENTE_SEQ_NO AS mente_seq_no,
			                                    null as device_edge_no,
			                                    ldm.DEVICE_NO as machine_type_cd,
			                                    ldm.DEVICE_NO as machine_serial,
			                                    ldm.DEVICE_NO as com_format_cd,
			                                    4 as data_type,
			                                    1 as test_type,
			                                    null as gathering_manage_no,
			                                    null as email_send_date,
			                                    null as email_text,
			                                    null as machine_record_cd,
			                                    null as machine_record_message,
			                                    ldm.MENTE_DATA as contents,
			                                    null as machine_record_aux_data,
			                                    null as email_address,
			                                    '0' as email_name,
			                                    null as remarks,
			                                    0 as is_correction,
			                                    null as user_id,
			                                    null  as ord_no,
			                                    0 as log_type,
			                                    null as reg_date,
			                                    ldm.OCCUR_DATE as up_date,
			                                    null as is_correction_up_date,
			                                    0 as service_support_type,
			                                    null as service_support_user_id,
			                                    null as service_support_up_date,
			                                    '0' as report_disp_flg,
			                                    '配管（UFRC）自己診断' AS log_message,
			                                    ldm.DEVICE_NO AS device_no,
			                                    '1' AS device_type,
			                                    ldm.UFRC_MEASURE_DATE AS occur_date
			                                    FROM
			                                    ( {0} ) ldm
			                                    WHERE
			                                    ldm.UFRC_MEASURE_DATE IS NOT NULL
			                                    ),
			                                    LEAK_DATE AS (
			                                    SELECT
			                                    null as event_reg_date,
			                                    null as m_notice_status,
			                                    ldm.MENTE_SEQ_NO AS mente_seq_no,
			                                    null as device_edge_no,
			                                    ldm.DEVICE_NO as machine_type_cd,
			                                    ldm.DEVICE_NO as machine_serial,
			                                    ldm.DEVICE_NO as com_format_cd,
			                                    4 as data_type,
			                                    2 as test_type,
			                                    null as gathering_manage_no,
			                                    null as email_send_date,
			                                    null as email_text,
			                                    null as machine_record_cd,
			                                    null as machine_record_message,
			                                    ldm.MENTE_DATA as contents,
			                                    null as machine_record_aux_data,
			                                    null as email_address,
			                                    '0' as email_name,
			                                    null as remarks,
			                                    0 as is_correction,
			                                    null as user_id,
			                                    null  as ord_no,
			                                    0 as log_type,
			                                    null as reg_date,
			                                    ldm.OCCUR_DATE as up_date,
			                                    null as is_correction_up_date,
			                                    0 as service_support_type,
			                                    null as service_support_user_id,
			                                    null as service_support_up_date,
			                                    '0' as report_disp_flg,
			                                    '漏血自己診断' AS log_message,
			                                    ldm.DEVICE_NO AS device_no,
			                                    '1' AS device_type,
			                                    ldm.LEAK_MEASURE_DATE AS occur_date
			                                    FROM
			                                    ( {0} ) ldm
			                                    WHERE
			                                    ldm.LEAK_MEASURE_DATE IS NOT NULL
			                                    ),
			                                    QD_DATE AS (
			                                    SELECT
			                                    null as event_reg_date,
			                                    null as m_notice_status,
			                                    ldm.MENTE_SEQ_NO AS mente_seq_no,
			                                    null as device_edge_no,
			                                    ldm.DEVICE_NO as machine_type_cd,
			                                    ldm.DEVICE_NO as machine_serial,
			                                    ldm.DEVICE_NO as com_format_cd,
			                                    4 as data_type,
			                                    3 as test_type,
			                                    null as gathering_manage_no,
			                                    null as email_send_date,
			                                    null as email_text,
			                                    null as machine_record_cd,
			                                    null as machine_record_message,
			                                    ldm.MENTE_DATA as contents,
			                                    null as machine_record_aux_data,
			                                    null as email_address,
			                                    '0' as email_name,
			                                    null as remarks,
			                                    0 as is_correction,
			                                    null as user_id,
			                                    null  as ord_no,
			                                    0 as log_type,
			                                    null as reg_date,
			                                    ldm.OCCUR_DATE as up_date,
			                                    null as is_correction_up_date,
			                                    0 AS service_support_type,
			                                    null as service_support_user_id,
			                                    null as service_support_up_date,
			                                    '0' as report_disp_flg,
			                                    '透析液流量自己診断' AS log_message,
			                                    ldm.DEVICE_NO AS device_no,
			                                    '1' AS device_type,
			                                    ldm.QD_MEASURE_DATE AS occur_date
			                                    FROM
			                                    ( {0} ) ldm
			                                    WHERE
			                                    ldm.QD_MEASURE_DATE IS NOT NULL
			                                    ),
			                                    DENSITY_DATE AS (
			                                    SELECT
			                                    null as event_reg_date,
			                                    null as m_notice_status,
			                                    ldm.MENTE_SEQ_NO AS mente_seq_no,
			                                    null as device_edge_no,
			                                    ldm.DEVICE_NO as machine_type_cd,
			                                    ldm.DEVICE_NO as machine_serial,
			                                    ldm.DEVICE_NO as com_format_cd,
			                                    4 as data_type,
			                                    4 as test_type,
			                                    null as gathering_manage_no,
			                                    null as email_send_date,
			                                    null as email_text,
			                                    null as machine_record_cd,
			                                    null as machine_record_message,
			                                    ldm.MENTE_DATA as contents,
			                                    null as machine_record_aux_data,
			                                    null as email_address,
			                                    '0' as email_name,
			                                    null as remarks,
			                                    0 as is_correction,
			                                    null as user_id,
			                                    null  as ord_no,
			                                    0 as log_type,
			                                    null as reg_date,
			                                    ldm.OCCUR_DATE as up_date,
			                                    null as is_correction_up_date,
			                                    0 as service_support_type,
			                                    null as service_support_user_id,
			                                    null as service_support_up_date,
			                                    '0'  as report_disp_flg,
			                                    '濃度自己診断' AS log_message,
			                                    ldm.DEVICE_NO AS device_no,
			                                    '1' AS device_type,
			                                    ldm.DENSITY_MEASURE_DATE AS occur_date
			                                    FROM
			                                    ( {0} ) ldm
			                                    WHERE
			                                    ldm.DENSITY_MEASURE_DATE IS NOT NULL
			                                    )
			                                    select a.* from(
			                                    SELECT
			                                    *
			                                    FROM
			                                    UFRC_DATE UNION ALL
			                                    SELECT
			                                    *
			                                    FROM
			                                    LEAK_DATE UNION ALL
			                                    SELECT
			                                    *
			                                    FROM
			                                    QD_DATE UNION ALL
			                                    SELECT
			                                    *
			                                    FROM
			                                    DENSITY_DATE) a
                                                INNER JOIN MST_DEVICE_list b on  a.DEVICE_NO=b.DEVICE_NO
			                                    WHERE a.up_date>= :START_DATE
			                                    AND a.up_date < :END_DATE
			                                    {1}");
                  sql=  sb.ToString();
                }
            
            }
            string fromTableSql = MakeFromTable(tableName);
            //mod 8400 zc start
            string sdiff = string.Empty;
            if (CommonConfig.isDiff)
            {
                //mod #12229 前回convertを実行した時刻 start
                if (tableName.Contains("LOG_DEV_LOG"))
                {                  
                    sdiff = $"and OCCUR_DATE >:CONVERT_DATETIME";
                }
                else
                {
                    sdiff = $"and up_date >:CONVERT_DATETIME";
                }
                //mod #12229 前回convertを実行した時刻 end
            }

            // テーブル取得
            //mod #10418 start
            if (CacheInformation.Instance.FacilityCd.Equals("0"))
            {
                sql = ConditionRegex.Replace(sql, "  1=1");
            }
            else
            {
                sql = sql.Replace("'{4}'", ":SERIES_CD");
            }
            string selectSql = string.Format(sql, fromTableSql, sdiff);
            var param = db.GetIMakeSqlParameters();
            
            param.AddParam(":START_DATE", startDate.ToString("yyyy-MM-dd"));
            param.AddParam(":END_DATE", endDate.AddDays(1).ToString("yyyy-MM-dd"));

            if (selectSql.Contains(":SERIES_CD"))
                param.AddParam(":SERIES_CD", CommonConfig.seriesCd);


            if (selectSql.Contains(":CONVERT_DATETIME"))
                param.AddParam(":CONVERT_DATETIME", CacheInformation.Instance.GetEffectiveConvertDatetime("REC").ConvertDatetime);


            dtFnwData = db.SelectTable(selectSql, param.GetParam());
            //mod #1418 end 


            // #8400 zl end
            if (dtFnwData == null) 
            {
                return false;
            }
            // #8400 年月テーブルのデータが取得していない場合、テーブルから取得する zl start
            if (dtFnwData.Rows.Count == 0 && tableName != this.fnwTableName)
            {
                string tableSql = MakeFromTable(this.fnwTableName);

                //mod #10418 start
                selectSql = string.Format(sql, tableSql, sdiff);
                var param1 = db.GetIMakeSqlParameters();

                param1.AddParam(":START_DATE", startDate.ToString("yyyy-MM-dd"));
                param1.AddParam(":END_DATE", endDate.AddDays(1).ToString("yyyy-MM-dd"));

                if (selectSql.Contains(":SERIES_CD"))
                    param1.AddParam(":SERIES_CD", CommonConfig.seriesCd);


                if (selectSql.Contains(":CONVERT_DATETIME"))
                    param1.AddParam(":CONVERT_DATETIME", CacheInformation.Instance.GetEffectiveConvertDatetime("REC").ConvertDatetime);

                dtFnwData = db.SelectTable(selectSql, param1.GetParam());
                //mod #1418 end 
                if (dtFnwData == null)
                {
                    return false;
                }
            }
            // #8400 年月テーブルのデータが取得していない場合、テーブルから取得する zl end

            dtFnwData.TableName = xmlConfigName;

            WriteTraceLog("===== コンバート元データ取得処理完了 =====");
            return true;
        }

        /// <summary>
        /// テーブル名をSQL句へ変換する
        /// </summary>
        /// <param name="tableName"></param>
        /// <returns></returns>
        public string MakeFromTable(string tableName)
        {
            string ret =  "SELECT * FROM " + tableName;
            return ret;
        }
        public void setResult(DataTable mstDt)
        {
            var groupedData = dtFnwData.AsEnumerable().GroupBy(r => new
            {
                seqNo = int.Parse(r.Field<object>("DEVICE_NO").ToString()),
                EventDate = r.Field<DateTime>("EVENT_REG_DATE").Date

            }).OrderBy(grp => grp.Key.EventDate).Select(g => new
            {
                Rows = g.OrderBy(r => r.Field<DateTime>("EVENT_REG_DATE")).ToList()
            }).ToList();

            DataTable newdtFnwData = dtFnwData.Clone();

            foreach (var group in groupedData)
            {
                Dictionary<string, HashSet<int>> myMap = new Dictionary<string, HashSet<int>>();
                isAttention = false;
                foreach (DataRow row in group.Rows) {              
                    string contents = row["CONTENTS"] == null ? null : row["CONTENTS"].ToString();
                    if (!string.IsNullOrEmpty(contents))
                    {
                        string testType = row["TEST_TYPE"].ToString();
                        var sbValue = new StringBuilder();

                        foreach (string element in contents.Split('`'))
                        {    
                            //add 10458 start
                            if (element.Length <= 2)
                                continue;

                            string key = element.Substring(0, 2);

                            string data = element.Substring(2).ToString();

                            if (testType == "7")
                            {
                                row["LOG_MESSAGE"] = $"{row["LOG_MESSAGE"]}:{data}";
                                sbValue.Clear(); 
                                continue;
                            }

                            int mappedKey = CommonConstants.GetValueFromMNT_KEY(testType, key);
                            if (mappedKey == 0)
                                continue;
                            sbValue.Append('"').Append(mappedKey).Append("\":");

                            // key = "0m" or "15"
                            if (key == "0m" || key == "15")
                            {
                                sbValue.Append('"').Append(data).Append("\",");
                            }
                            else
                            {
                                sbValue.Append(data).Append(',');
                            }
                            //add 10458 end
                        }

                        string value = sbValue.Length > 0
                            ? sbValue.ToString(0, sbValue.Length - 1)
                            : string.Empty;

                        if (!string.IsNullOrEmpty(value)&& fnwTableName.ToString().Equals("LOG_DEV_MENTE"))
                        {
                            
                            var deviceType = row["DEVICE_TYPE_CD"].ToString();
                            var eventDate = row.Field<DateTime>("EVENT_REG_DATE");
                            var foundRows = mstDt.AsEnumerable()
                                .Where(r =>
                                    r.Field<string>("DEVICE_TYPE_CD") == deviceType &&
                                    r.Field<DateTime>("UP_DATE") < eventDate &&
                                    r.Field<DateTime>("enddate") > eventDate)
                                .ToArray();
                            string Svalue = string.Empty;
                            var sb = new StringBuilder();
                            sb.Append(",\"999\":[");

                            bool first = true;
                            foreach (DataRow r in foundRows)
                            {
                                if (!first)
                                    sb.Append(',');
                                first = false;

                                sb.Append("{\"key\":\"").Append(r["SELFDIAG_ITEM_NO"])
                                  .Append("\",\"judge\":\"").Append(r["ON_FLG"])
                                  .Append("\",\"caution_up\":\"").Append(r["CAUTION_UP"])
                                  .Append("\",\"failure_up\":\"").Append(r["FAILURE_UP"])
                                  .Append("\",\"caution_low\":\"").Append(r["CAUTION_LOW"])
                                  .Append("\",\"failure_low\":\"").Append(r["FAILURE_LOW"])
                                  .Append("\"}");
                            }
                            if (first)
                            {
                                Svalue = ",\"999\":[]";
                            }
                            else
                            {
                                sb.Append(']');
                                Svalue = sb.ToString();
                            }
                        
                            row["CONTENTS"] = ("{" + value + Svalue + "}").Replace("\"", "\"\"");
                            //getGhecklist(newdtFnwData, row, myMap, int.Parse(row["TEST_TYPE"].ToString()));
                            GetChecklist(newdtFnwData, row, myMap, int.Parse(row["TEST_TYPE"].ToString()));
                        } else {
                            row["CONTENTS"] = null;
                        }
                    }
                }

            }
            dtFnwData= newdtFnwData;
        }

        /// <summary>
        /// データコンバート処理
        /// </summary>
        /// <param name="mapConvertData">コンバートデータ(戻り値)</param>
        /// <param name="listErrorMstCd">失敗したマスタコード(戻り値)</param>
        /// <returns>成功：true、失敗：false</returns>
        public override bool Convert(Dictionary<string, List<NtssRecord>> mapConvertData, List<string> listErrorMstCd)
        {
            

            WriteTraceLog("===== コンバート処理開始 =====");

            int procCount = 0;
      
            //add 10458 start
            if (fnwTableName.ToString().Equals("LOG_DEV_MENTE")) {
                setResult(getMstSelfMeasureResult());
            }
            //add 10458 end
            foreach (DataRow row in dtFnwData.Rows)
            {
                // マスタコードを取得
                var mstCd = row[GetXmlElementValue("fnwPk")].ToString();
                //7407 add zc start
                string contents = row["CONTENTS"] as string;

                if (!string.IsNullOrEmpty(contents) && !fnwTableName.Equals("LOG_DEV_MENTE"))
                {
                    var sb = new StringBuilder();
                    int start = 0;

                    while (true)
                    {
                        int idx = contents.IndexOf('`', start);
                        string element;

                        if (idx == -1)
                        {
                            element = contents.Substring(start);
                        }
                        else
                        {
                            element = contents.Substring(start, idx - start);
                        }

                        if (element.Length > 2)
                        {
                            string key = element.Substring(0, 2);
                            string val = element.Substring(2);

                            int valueFor0i = CommonConstants.GetValueFromMNT_KEY(row["TEST_TYPE"].ToString(), key);
                            if (valueFor0i != 0)
                            {
                                if (key == "0O" || key == "0a")
                                    sb.Append('"').Append(valueFor0i).Append("\":\"").Append(val).Append("\",");
                                else
                                    sb.Append('"').Append(valueFor0i).Append("\":").Append(val).Append(",");
                            }
                        }

                        if (idx == -1) break;
                        start = idx + 1;
                    }

                    if (sb.Length > 0)
                    {
                        sb.Length--;
                        row["CONTENTS"] = ("{" + sb.ToString() + "}").Replace("\"", "\"\"");
                    }
                    else
                    {
                        row["CONTENTS"] = "null";
                    }
                }


                if (listErrorMstCd.Contains(mstCd))
                {
                    // エラーがあったマスタコードのそれ以降のレコード(系列施設レコード)は処理しない
                    continue;
                }

            
                var isConvertError = false;
                var ntssColumns = new List<NtssColumn>();
                var mapJson = new Dictionary<string, List<JsonElement>>();

                //------------------------------------
                // 主テーブルの加工処理
                //------------------------------------
                ConvertRecord(row, ntssColumns, mapJson, ref isConvertError);

                if (isConvertError)
                {
                    // 次のマスタレコードへ
                    listErrorMstCd.Add(mstCd);
                    continue;
                }

                

                // 施設コードの列が存在しない
                ntssColumns.Insert(2, CreateNtssColumn("facility_cd", NTSS_DATA_TYPE_CHARACTER_VARYING, this.facilityCd, true));

                if (mapConvertData.ContainsKey(mstCd) == false)
                {
                    mapConvertData[mstCd] = new List<NtssRecord>();
                }
                mapConvertData[mstCd].Add(new NtssRecord() { columns = ntssColumns });
                if (++procCount % 100 == 0)
                {
                    WriteTraceLog("コンバート処理中 " + procCount.ToString() + "/" + dtFnwData.Rows.Count.ToString());
                }
            }
            WriteTraceLog("===== コンバート処理完了 =====");
            return true;
        }
       

        public  DataTable getMstSelfMeasureResult() {

            string sql = @"select
				DEVICE_TYPE_CD,
				case  a.SELFDIAG_ITEM_NO
				when 4  then 47
				when 6  then 43
				when 7  then 44
				when 8  then 48
				when 9  then 46
				when 10  then 45
				when 11  then 49
				when 15  then 53
				when 16  then 54
				when 20  then 65
				when 21  then 63
				when 22  then 64
				when 32  then 58
				else a.SELFDIAG_ITEM_NO
				end SELFDIAG_ITEM_NO,
				ON_FLG,
				case a.SELFDIAG_ITEM_NO when 32 then
				case when b.ERROR_UP_OR_DOWN = '0' or b.ERROR_UP_OR_DOWN = '2' then ROUND(500 ＋ (500 * ALARM_POINT  / 100), 3) end
				else case when b.ERROR_UP_OR_DOWN = '0' or b.ERROR_UP_OR_DOWN = '2' then ALARM_POINT end
				end failure_up,
				case a.SELFDIAG_ITEM_NO when 32 then
				case when b.ERROR_UP_OR_DOWN = '1' then ROUND(500 ＋ (500 * ALARM_POINT  / 100), 3) when b.ERROR_UP_OR_DOWN = '2' then ROUND((500 ＋ (500 * ALARM_POINT * (-1)  / 100)), 3) end
				else case when b.ERROR_UP_OR_DOWN = '1' then ALARM_POINT when b.ERROR_UP_OR_DOWN = '2' then ALARM_POINT * (-1) end
				end failure_low,
				case a.SELFDIAG_ITEM_NO when 32 then
				case when b.ERROR_UP_OR_DOWN = '0' or b.ERROR_UP_OR_DOWN = '2' then ROUND(500 ＋ (500 * WARNING_POINT  / 100), 3)  end
				else case when b.ERROR_UP_OR_DOWN = '0' or b.ERROR_UP_OR_DOWN = '2' then WARNING_POINT end
				end caution_up,
				case a.SELFDIAG_ITEM_NO when 32 then
				case when b.ERROR_UP_OR_DOWN = '1' then ROUND(500 ＋ (500 * WARNING_POINT  / 100), 3)  when b.ERROR_UP_OR_DOWN = '2' then ROUND((500 ＋ (500 * WARNING_POINT * (-1)  / 100)), 3) end
				else case when b.ERROR_UP_OR_DOWN = '1' then WARNING_POINT when b.ERROR_UP_OR_DOWN = '2' then WARNING_POINT * (-1) end
				end caution_low,a.UP_DATE,nvl(lead (a.UP_DATE, 1, NULL) over (PARTITION BY  a.DEVICE_TYPE_CD, a.VERSION, a.SELFDIAG_ITEM_NO,a.SERIES_CD ORDER BY a.DEVICE_TYPE_CD, a.VERSION, a.SELFDIAG_ITEM_NO,a.SERIES_CD,a.UP_DATE ASC), SYSDATE) AS enddate
				from MST_SELFDIAG_ALERMSET a
				left join MST_SELFDIAG_LISTITEM b on a.SELFDIAG_ITEM_NO = b.SELFDIAG_ITEM_NO		
				ORDER BY
				DEVICE_TYPE_CD,SELFDIAG_ITEM_NO";


           DataTable  FnwDataMst = db.SelectTable(sql);

           return FnwDataMst;
        }

        //mod #10418 start
        public void GetChecklist(
            DataTable newdtData,
            DataRow row,
            Dictionary<string, HashSet<int>> myMap,
            int testType)
        {
            newdtData.ImportRow(row);

            if (row["TEST_TYPE"]?.ToString() == "7")
            {
                HandleTestType7(newdtData, row);
                return;
            }

            HandleNormalTest(newdtData, row, myMap, testType);
        }
        private void HandleTestType7(DataTable table, DataRow row)
        {
            bool isOk = row["LOG_MESSAGE"]?.ToString().Contains("OK") == true;

            AddMachineRecord(
                table,
                row,
                isOk ? "G100" : "G101",
                isOk ? "自己診断合格" : "自己診断不合格");
        }
        private void AddMachineRecord(
            DataTable table,
            DataRow sourceRow,
            string code,
            string message)
        {
            DataRow newRow = table.NewRow();
            newRow.ItemArray = sourceRow.ItemArray.Clone() as object[];

            newRow["CONTENTS"] = DBNull.Value;
            newRow["DATA_TYPE"] = "1";
            newRow["TEST_TYPE"] = DBNull.Value;
            newRow["LOG_TYPE"] = DBNull.Value;
            newRow["EMAIL_NAME"] = DBNull.Value;
            newRow["MACHINE_RECORD_CD"] = code;
            newRow["MACHINE_RECORD_MESSAGE"] = message;

            table.Rows.Add(newRow);
        }


        private void HandleNormalTest(
            DataTable table,
            DataRow row,
            Dictionary<string, HashSet<int>> myMap,
            int testType)
        {
            var result = CheckJsonResult(row);

            if (result.isInFailureRange)//不合格
            {
                AddMachineRecord(table, row, "G101", "自己診断不合格");
                return;
            }
            //合格
            CheckAndOutputFinalResult(table, row, myMap, testType);
        }
        private void CheckAndOutputFinalResult(
            DataTable table,
            DataRow row,
            Dictionary<string, HashSet<int>> myMap,int testType)
        {
            string sDeviceNO = row["DEVICE_NO"].ToString();
            if (myMap.ContainsKey(sDeviceNO))
            {
                myMap[sDeviceNO].Add(testType);
            }
            else
            {
                myMap[sDeviceNO] = new HashSet<int> { testType };
            }

            HashSet<int> numbersToCheck1 = new HashSet<int> { 1, 2, 3, 4 };
            bool contains1234 = numbersToCheck1.IsSubsetOf(myMap[sDeviceNO]);

            if (contains1234) {
                if (isAttention)
                {
                    AddMachineRecord(table, row, "G102", "自己診断合格（要注意）");
                    isAttention = false;
                }
                else {
                    AddMachineRecord(table, row, "G100", "自己診断合格");

                }
            }
            myMap.Clear();
        }

        public class CheckResult
        {
            //不合格
            public bool isInFailureRange { get; set; }
            //注意点
            public bool isInCautionRange { get; set; }
        }
        private CheckResult  CheckJsonResult(DataRow row)
        {
            var result = new CheckResult();
            result.isInCautionRange = false;
            result.isInFailureRange = true;

            var json = JToken.Parse(
                row["CONTENTS"].ToString().Replace("\"\"", "\""));

            foreach (JObject item in json["999"].Children<JObject>())
            {
                if (item["judge"]?.ToString() != "1")
                    continue;

                string key = item["key"].ToString();
                JToken outerValue = json[key];

                if (outerValue == null)
                    continue;

                var ruleResult = EvaluateRule(key, item, outerValue, result);

                //注意点
                if (ruleResult.isInCautionRange && isAttention == false)
                {
                    isAttention = true;
                }
                
            }

            return result;
        }
        private CheckResult EvaluateRule(string key, JObject item, JToken outerValue, CheckResult result)
        {

            decimal cautionUp = 0;
            decimal failureUp = 0;
            decimal cautionLow = 0;
            decimal failureLow = 0;
            switch (key)
            {
                case "43"://以上
                case "48":
                case "45":
                case "49":
                    decimal outerIntValue = outerValue.Value<decimal>();
                    outerValue.Value<decimal>();
                    if (string.IsNullOrWhiteSpace(item["caution_up"]?.ToString()) == false
                        && string.IsNullOrWhiteSpace(item["failure_up"]?.ToString()) == false)
                    {
                        cautionUp = decimal.Parse(item["caution_up"].ToString());//注意点上限
                        failureUp = decimal.Parse(item["failure_up"].ToString());//不合格上限
                                                                                 //注意点
                        result.isInCautionRange = (outerIntValue >= cautionUp && outerIntValue <= failureUp);
                        //不合格
                        result.isInFailureRange = (outerIntValue > failureUp);
                    }
                    else if (string.IsNullOrWhiteSpace(item["caution_up"]?.ToString()) == false)
                    {
                        cautionUp = decimal.Parse(item["caution_up"].ToString());//注意点上限
                                                                                 //注意点
                        result.isInCautionRange = (outerIntValue >= cautionUp);
                    }
                    else if (string.IsNullOrWhiteSpace(item["failure_up"]?.ToString()) == false)
                    {
                        failureUp = decimal.Parse(item["failure_up"].ToString());//不合格上限
                                                                                 //不合格
                        result.isInFailureRange = (outerIntValue >= failureUp);
                    }
                    return result;

                case "46":
                case "63":
                case "64":
                case "58":
                    

                    outerIntValue = outerValue.Value<decimal>();
                    if (string.IsNullOrWhiteSpace(item["caution_up"]?.ToString()) == false
                        && string.IsNullOrWhiteSpace(item["failure_up"]?.ToString()) == false)
                    {
                        cautionUp = decimal.Parse(item["caution_up"].ToString());//注意点上限
                        failureUp = decimal.Parse(item["failure_up"].ToString());//不合格上限
                        failureLow = decimal.Parse(item["failure_low"].ToString());//不合格下限
                        cautionLow = decimal.Parse(item["caution_low"].ToString());//注意点下限
                                                                                   //注意点
                        result.isInCautionRange = ((cautionUp <= outerIntValue && outerIntValue <= failureUp) || (failureLow < outerIntValue && outerIntValue <= cautionLow));
                        //不合格
                        result.isInFailureRange = (outerIntValue > failureUp) || (outerIntValue <= failureLow);
                    }
                    else if (string.IsNullOrWhiteSpace(item["caution_up"]?.ToString()) == false)
                    {
                        cautionUp = decimal.Parse(item["caution_up"].ToString());//注意点上限
                        cautionLow = decimal.Parse(item["caution_low"].ToString());//注意点下限
                                                                                   //注意点
                        result.isInCautionRange = (outerIntValue >= cautionUp || outerIntValue <= cautionLow);
                    }
                    else if (string.IsNullOrWhiteSpace(item["failure_up"]?.ToString()) == false)
                    {
                        failureUp = decimal.Parse(item["failure_up"].ToString());//不合格上限
                        failureLow = decimal.Parse(item["failure_low"].ToString());//不合格下限
                                                                                   //不合格
                        result.isInFailureRange = (outerIntValue >= failureUp) || (outerIntValue <= failureLow);
                    }
                    return result;
                case "47":
                case "65":
                    string path = outerValue.Value<string>();
                    if (2 <= path.Length && !"01".Equals(path.Substring(path.Length - 2)))
                    {
                        //自己診断結果不合格
                        result.isInFailureRange = true;
                    }
                    return result;

                case "44"://以下
                case "53":
                case "54":
                    outerIntValue = outerValue.Value<decimal>();
                    if (string.IsNullOrWhiteSpace(item["caution_low"]?.ToString()) == false
                                    && string.IsNullOrWhiteSpace(item["failure_low"]?.ToString()) == false)
                    {
                        outerValue.Value<decimal>();
                        cautionLow = decimal.Parse(item["caution_low"].ToString());//注意点下限
                        failureLow = decimal.Parse(item["failure_low"].ToString());//不合格下限
                                                                                   //注意点
                        result.isInCautionRange = (outerIntValue <= cautionLow && outerIntValue >= failureLow);
                        //不合格
                        result.isInFailureRange = (outerIntValue < failureLow);
                    }
                    else if (string.IsNullOrWhiteSpace(item["caution_low"]?.ToString()) == false)
                    {
                        cautionLow = decimal.Parse(item["caution_low"].ToString());//注意点下限
                                                                                   //注意点
                        result.isInCautionRange = (outerIntValue <= cautionLow);
                    }
                    else if (string.IsNullOrWhiteSpace(item["failure_low"]?.ToString()) == false)
                    {
                        failureLow = decimal.Parse(item["failure_low"].ToString());//不合格下限
                                                                                   //不合格
                        result.isInFailureRange = (outerIntValue <= failureLow);
                    }
                    return result;
                default:
                    return result;
            }
        }
        //mod #10418 end
    }
}
