using Fnw.IOControl.DB;
using System;
using System.Data;
using System.Linq;


namespace ConvertCommon.Common
{
   public  class ConvertSQL
    {
		DBCtrl db = ConvertControl.DBConnectFnw();
		public void SetMEDICINELATESTNO(string sCd)
		{
			string sql = @"INSERT INTO SYNC_MEDICINE_LATEST_NO ( PATID, IND_NO, RST_NO, DIALYSIS_NO, PLURAL, UP_DATE, NO ,SERIES_CD) (
	                            SELECT
		                            a.*,
		                            COALESCE( b.no, 0 ) + row_number ( ) over ( partition BY a.PATID ORDER BY a.PATID, a.IND_NO, RST_NO ) AS no ,:SERIES_CD
	                            FROM
		                            (
			                            WITH MEDI_TMP AS ( SELECT DIALYSIS_NO, CTL_NO, IND_NO, MAX( IND_UP_DATE ) MAX_UP_DATE FROM RST_DIALYSIS_MEDICATION GROUP BY DIALYSIS_NO, CTL_NO, IND_NO ),
			                            IND_DEVELOP_MEDI_NORMAL AS (
			                            SELECT
				                            w1.IND_ID,
				                            w1.CTL_NO,
				                            w1.MEDICINE_CD,
				                            w1.PATID,
				                            row_number ( ) over ( partition BY w1.IND_ID, MEDICINE_CD ORDER BY w1.IND_ID, w1.CTL_NO ) AS row_no 
			                            FROM
				                            IND_DEVELOP_MEDI w1 
			                            ),
			                            RST_DIALYSIS_MEDICATION_NORMAL AS (
			                            SELECT
                                            w2.CTL_NO,
				                            w2.DIALYSIS_NO,
				                            w2.IND_UP_DATE,
				                            w2.IND_NO,
				                            SCH_PLAN.IND_ID,
				                            SCH_PLAN.PLURAL,
				                            SCH_PLAN.PATID,
				                            w2.UP_DATE,
			                            CASE				
					                            WHEN SET_MEDICINE_FLG = '0' THEN
					                            MEDICINE_CD ELSE SET_MEDICINE_CD 
				                            END AS MEDI_CD,
				                             row_number ( ) over ( partition BY w2.DIALYSIS_NO, MEDICINE_CD ORDER BY w2.DIALYSIS_NO, EFFECT_DATE ) AS row_no 
			                            FROM
				                            RST_DIALYSIS_MEDICATION w2
				                            INNER JOIN SCH_DIALYSIS_PLAN SCH_PLAN ON SCH_PLAN.RESULT_DIALYSISNO = w2.DIALYSIS_NO
                                            INNER JOIN  RST_DIALYSIS R  ON w2.DIALYSIS_NO=R.DIALYSIS_NO and  R.SERIES_CD=:SERIES_CD
			                            ) SELECT
			                            MEDI.PATID,
			                            MEDI.CTL_NO AS IND_NO,
			                            NULL AS RST_NO,
			                            NULL AS DIALYSIS_NO,
			                            MEDI.PLURAL,
			                            MAX( MEDI.UP_DATE ) AS UP_DATE 
		                            FROM
			                            IND_DIALYSIS_MEDI MEDI
			                            LEFT JOIN SYNC_MEDICINE_LATEST_NO s ON s.IND_NO = MEDI.CTL_NO  and s.SERIES_CD=:SERIES_CD
										AND s.PLURAL = MEDI.PLURAL
			                            AND s.PATID = MEDI.PATID 
		                            WHERE
			                            s.IND_NO IS NULL 
		                            GROUP BY
			                            MEDI.PATID,
			                            MEDI.PLURAL,
			                            MEDI.CTL_NO UNION ALL
		                            SELECT
			                            RST_MEDI.PATID,
			                            NULL AS IND_NO,
			                            RST_MEDI.CTL_NO AS RST_NO,
			                            RST_MEDI.DIALYSIS_NO,
			                            RST_MEDI.PLURAL,
			                            RST_MEDI.UP_DATE 
		                            FROM
			                            RST_DIALYSIS_MEDICATION_NORMAL RST_MEDI
			                            INNER JOIN MEDI_TMP MEDI ON RST_MEDI.DIALYSIS_NO = MEDI.DIALYSIS_NO 
			                            AND RST_MEDI.CTL_NO = MEDI.CTL_NO 
			                            AND RST_MEDI.IND_NO = MEDI.IND_NO 
			                            AND RST_MEDI.IND_UP_DATE = MEDI.MAX_UP_DATE
			                            LEFT JOIN IND_DEVELOP_MEDI_NORMAL DEVELOP_MEDI ON RST_MEDI.IND_ID = DEVELOP_MEDI.IND_ID 
			                            AND DEVELOP_MEDI.MEDICINE_CD = RST_MEDI.MEDI_CD 
			                            AND RST_MEDI.row_no = DEVELOP_MEDI.row_no
			                            LEFT JOIN SYNC_MEDICINE_LATEST_NO s ON s.DIALYSIS_NO = RST_MEDI.DIALYSIS_NO  and s.SERIES_CD=:SERIES_CD
			                            AND s.PATID = RST_MEDI.PATID  and  s.RST_NO = RST_MEDI.CTL_NO
		                            WHERE
			                            DEVELOP_MEDI.CTL_NO IS NULL 
			                            AND s.RST_NO IS NULL
                                       UNION ALL
										SELECT
											r.PATID,
											NULL AS IND_NO,
				                            w2.CTL_NO  AS RST_NO,
				                            w2.DIALYSIS_NO,
				                            null as PLURAL,	                           
				                            w2.UP_DATE 
			                            FROM
				                            RST_DIALYSIS_MEDICATION w2
											INNER JOIN   RST_DIALYSIS r on r.DIALYSIS_NO= w2.DIALYSIS_NO and   r.SERIES_CD=:SERIES_CD
				                            LEFT JOIN SCH_DIALYSIS_PLAN SCH_PLAN ON SCH_PLAN.RESULT_DIALYSISNO = w2.DIALYSIS_NO 	
　　　　　　　　　　　　　　　　　　　　　　LEFT JOIN SYNC_MEDICINE_LATEST_NO s ON s.DIALYSIS_NO = w2.DIALYSIS_NO   and s.SERIES_CD=:SERIES_CD
			                           　　　 AND s.PATID = r.PATID　and  s.RST_NO = w2.CTL_NO
　　　　　　　　　　　　　　　　　　　　where  SCH_PLAN.RESULT_DIALYSISNO IS NULL　and  s.RST_NO IS NULL
		                            ) a
	                            LEFT JOIN ( SELECT PATID, max( NO ) AS NO FROM SYNC_MEDICINE_LATEST_NO WHERE  SERIES_CD=:SERIES_CD GROUP BY PATID ) b ON a.PATID = b.PATID 
	                            )";

			try
			{
				// mod #7997 コンバータソースコード改善   start
				IMakeSqlParameters param = db.GetIMakeSqlParameters();
				param.AddParam(":SERIES_CD", sCd);
				db.ExecuteSQL(sql,param.GetParam());
				// mod #7997 コンバータソースコード改善   end
			}
			catch (Exception e)
			{

				throw e;
			}


		}

		public void SetDiffMEDICINELATESTNO(string facilityCd,string sCd)
		{

			string sql = @"INSERT INTO SYNC_MEDICINE_LATEST_NO ( PATID, IND_NO, RST_NO, DIALYSIS_NO, PLURAL, UP_DATE, NO,SERIES_CD) (
	                            SELECT
		                            a.*,
		                            COALESCE( b.no, 0 ) + row_number ( ) over ( partition BY a.PATID ORDER BY a.PATID, a.IND_NO, RST_NO ) AS no ,:SERIES_CD
	                            FROM
		                            (
			                            WITH MEDI_TMP AS ( SELECT DIALYSIS_NO, CTL_NO, IND_NO, MAX( IND_UP_DATE ) MAX_UP_DATE FROM RST_DIALYSIS_MEDICATION GROUP BY DIALYSIS_NO, CTL_NO, IND_NO ),
			                            IND_DEVELOP_MEDI_NORMAL AS (
			                            SELECT
				                            w1.IND_ID,
				                            w1.CTL_NO,
				                            w1.MEDICINE_CD,
				                            w1.PATID,
				                            row_number ( ) over ( partition BY w1.IND_ID, MEDICINE_CD ORDER BY w1.IND_ID, w1.CTL_NO ) AS row_no 
			                            FROM
				                            IND_DEVELOP_MEDI w1 
			                            ),
			                            RST_DIALYSIS_MEDICATION_NORMAL AS (
			                            SELECT
				                            w2.CTL_NO,
				                            w2.DIALYSIS_NO,
				                            w2.IND_UP_DATE,
				                            w2.IND_NO,
				                            SCH_PLAN.IND_ID,
				                            SCH_PLAN.PLURAL,
				                            SCH_PLAN.PATID,
				                            w2.UP_DATE,
			                            CASE				
					                            WHEN SET_MEDICINE_FLG = '0' THEN
					                            MEDICINE_CD ELSE SET_MEDICINE_CD 
				                            END AS MEDI_CD,
				                            row_number ( ) over ( partition BY  w2.DIALYSIS_NO, MEDICINE_CD ORDER BY  w2.DIALYSIS_NO, EFFECT_DATE ) AS row_no 
			                            FROM
				                            RST_DIALYSIS_MEDICATION w2
				                            INNER JOIN SCH_DIALYSIS_PLAN SCH_PLAN ON SCH_PLAN.RESULT_DIALYSISNO = w2.DIALYSIS_NO
                                            INNER JOIN  RST_DIALYSIS R  ON w2.DIALYSIS_NO=R.DIALYSIS_NO and  R.SERIES_CD=:SERIES_CD
			                            ) SELECT
			                            MEDI.PATID,
			                            MEDI.CTL_NO AS IND_NO,
			                            NULL AS RST_NO,
			                            NULL AS DIALYSIS_NO,
			                            MEDI.PLURAL,
			                            MAX( MEDI.UP_DATE ) AS UP_DATE 
		                            FROM
			                            IND_DIALYSIS_MEDI MEDI
			                            LEFT JOIN SYNC_MEDICINE_LATEST_NO s ON s.IND_NO = MEDI.CTL_NO  and s.SERIES_CD=:SERIES_CD
										AND s.PLURAL = MEDI.PLURAL
			                            AND s.PATID = MEDI.PATID 
		                            WHERE
			                            s.IND_NO IS NULL 
		                            GROUP BY
			                            MEDI.PATID,
			                            MEDI.PLURAL,
			                            MEDI.CTL_NO UNION ALL
		                            SELECT
			                            RST_MEDI.PATID,
			                            NULL AS IND_NO,
			                            RST_MEDI.CTL_NO AS RST_NO,
			                            RST_MEDI.DIALYSIS_NO,
			                            RST_MEDI.PLURAL,
			                            RST_MEDI.UP_DATE 
		                            FROM
			                            RST_DIALYSIS_MEDICATION_NORMAL RST_MEDI
			                            INNER JOIN MEDI_TMP MEDI ON RST_MEDI.DIALYSIS_NO = MEDI.DIALYSIS_NO 
			                            AND RST_MEDI.CTL_NO = MEDI.CTL_NO 
			                            AND RST_MEDI.IND_NO = MEDI.IND_NO 
			                            AND RST_MEDI.IND_UP_DATE = MEDI.MAX_UP_DATE
			                            LEFT JOIN IND_DEVELOP_MEDI_NORMAL DEVELOP_MEDI ON RST_MEDI.IND_ID = DEVELOP_MEDI.IND_ID 
			                            AND DEVELOP_MEDI.MEDICINE_CD = RST_MEDI.MEDI_CD 
			                            AND RST_MEDI.row_no = DEVELOP_MEDI.row_no
			                            LEFT JOIN SYNC_MEDICINE_LATEST_NO s ON s.DIALYSIS_NO = RST_MEDI.DIALYSIS_NO  and s.SERIES_CD=:SERIES_CD
			                            AND s.PATID = RST_MEDI.PATID  and  s.RST_NO = RST_MEDI.CTL_NO
		                            WHERE
			                            DEVELOP_MEDI.CTL_NO IS NULL 
			                            AND s.RST_NO IS NULL
                                       UNION ALL
										SELECT
											r.PATID,
											NULL AS IND_NO,
				                            w2.CTL_NO  AS RST_NO,
				                            w2.DIALYSIS_NO,
				                            null as PLURAL,	                           
				                            w2.UP_DATE 
			                            FROM
				                            RST_DIALYSIS_MEDICATION w2
											INNER JOIN   RST_DIALYSIS r on r.DIALYSIS_NO= w2.DIALYSIS_NO  and   r.SERIES_CD=:SERIES_CD
				                            LEFT JOIN SCH_DIALYSIS_PLAN SCH_PLAN ON SCH_PLAN.RESULT_DIALYSISNO = w2.DIALYSIS_NO 	
　　　　　　　　　　　　　　　　　　　　　　LEFT JOIN SYNC_MEDICINE_LATEST_NO s ON s.DIALYSIS_NO = w2.DIALYSIS_NO   and s.SERIES_CD=:SERIES_CD
			                           　　　 AND s.PATID = r.PATID　and  s.RST_NO = w2.CTL_NO
　　　　　　　　　　　　　　　　　　　　where  SCH_PLAN.RESULT_DIALYSISNO IS NULL　and  s.RST_NO IS NULL
		                            ) a
								LEFT JOIN(SELECT PATID, NO AS NO FROM SYNC_FNSI_MEDICINE_LATEST_NO WHERE FACILITYCD= :FACILITY_CD ) b ON a.PATID = b.PATID)";
			try
			{
				// mod #7997 コンバータソースコード改善   start
				// db.ExecuteSQL(sql);
				IMakeSqlParameters param1 = db.GetIMakeSqlParameters();
				param1.AddParam(":FACILITY_CD", facilityCd);
				param1.AddParam(":SERIES_CD", sCd);
				db.ExecuteSQL(sql, param1.GetParam());
				// mod #7997 コンバータソースコード改善   end
			}
			catch (Exception e)
			{

				throw e;
			}
		}

		//add  #10840 COP_EVENT_MANAGEの最新連携種別を取得する　　start
		public void GetRenkeiType(string funcStr) {

			IMakeSqlParameters param1 = db.GetIMakeSqlParameters();
			//add  #11576 pat_coop_detailのsave_1がGX固定でコンバートされる start
			string firstFunc = funcStr.Split(',')[0];
			param1.AddParam(":FIRST_FUNC", firstFunc);
			param1.AddParam(":FUNC_STR", funcStr);

			string sql = @"	WITH PRIORITY AS (
								SELECT REGEXP_SUBSTR(:FUNC_STR, '[^,]+', 1, LEVEL) AS NAME,
									   LEVEL AS ORD
								FROM DUAL
								CONNECT BY REGEXP_SUBSTR(:FUNC_STR, '[^,]+', 1, LEVEL) IS NOT NULL
							),
							BASE AS (
								SELECT c.SERIES_CD,
									   c.COOP_FUNCTION_NAME,
									   x.FNSI_COOP_VERSION,
									   c.EVENT_OCCUR_DATE
								FROM COP_EVENT_MANAGE c
								LEFT JOIN (
									SELECT FNW_COOP_ID,
										   FNSI_COOP_VERSION,
										   ROW_NUMBER() OVER (
											   PARTITION BY FNW_COOP_ID
											   ORDER BY 
												   CASE WHEN FNSI_COOP_VERSION = '-' THEN 1 ELSE 0 END,
												   NO ASC
										   ) RN
									FROM SYNC_COOP_CONVERT_SET
								) x
								  ON SUBSTR(c.COOP_ID, 1, LENGTH(x.FNW_COOP_ID)) = x.FNW_COOP_ID
								 AND x.RN = 1
                                 JOIN PRIORITY p ON c.COOP_FUNCTION_NAME = TRIM(p.NAME)
							)
							SELECT b.SERIES_CD,
								    	MAX(
											  CASE 
												WHEN b.COOP_FUNCTION_NAME = :FIRST_FUNC
												THEN b.FNSI_COOP_VERSION 
											  END
											)
											KEEP (
											  DENSE_RANK FIRST 
											  ORDER BY 
												CASE 
												  WHEN b.COOP_FUNCTION_NAME = :FIRST_FUNC THEN 0
												  ELSE 1
												END,
												b.EVENT_OCCUR_DATE DESC
											) AS COOPSET,
								   MAX(b.FNSI_COOP_VERSION) KEEP (
									   DENSE_RANK FIRST 
									   ORDER BY p.ORD ASC, b.EVENT_OCCUR_DATE DESC
								   ) AS COOPVERSION

							FROM BASE b
							INNER JOIN PRIORITY p
							  ON b.COOP_FUNCTION_NAME = TRIM(p.NAME)
							GROUP BY b.SERIES_CD";
			DataTable dt = db.SelectTable(sql, param1.GetParam());

			string upSql = "UPDATE SYNC_FACILITY_CD SET COOPSET = :COOPSET,COOPVERSION=:COOPVERSION WHERE SERIES_CD = :SERIES_CD";

		    DataTable dtCoop=db.SelectTable("select COOPSET,SERIES_CD,COOPVERSION from SYNC_FACILITY_CD");
			//add  #11576 pat_coop_detailのsave_1がGX固定でコンバートされる end

			foreach (DataRow row in dt.Rows)
			{
				IMakeSqlParameters param = db.GetIMakeSqlParameters();

				object coopSet = row["COOPSET"] == DBNull.Value
									? DBNull.Value
									: row["COOPSET"];
				//add  #11576 pat_coop_detailのsave_1がGX固定でコンバートされる start
				object coopVersion = row["COOPVERSION"] == DBNull.Value
									? DBNull.Value
									: row["COOPVERSION"];
				//add  #11576 pat_coop_detailのsave_1がGX固定でコンバートされる end

				if (CommonConfig.isDiff)
				{

					DataRow coopRow = dtCoop.Select($"SERIES_CD = '{row["SERIES_CD"]}'").FirstOrDefault();
					object coopSetDb = coopRow["COOPSET"];
					string oldVal = coopSetDb == DBNull.Value ? null : coopSetDb.ToString();
					string newVal = coopSet == DBNull.Value ? null : coopSet.ToString();

					bool result = oldVal != newVal && (oldVal == "GX" || newVal == "GX");
					CommonConfig.HashCoopSet[row["SERIES_CD"].ToString()] = result;

					//add  #11576 pat_coop_detailのsave_1がGX固定でコンバートされる start
					object coopVerDb = coopRow["COOPVERSION"];
					string oldVersion = coopVerDb == DBNull.Value ? null : coopVerDb.ToString();
					string newVersion = coopVersion == DBNull.Value ? null : coopVersion.ToString();

					CommonConfig.HashCoopSetSave_1[row["SERIES_CD"].ToString()] = IsSpecialChanged(oldVal, newVal, oldVersion, newVersion);
					//add  #11576 pat_coop_detailのsave_1がGX固定でコンバートされる end
				}

				param.AddParam(":COOPSET", coopSet);
				param.AddParam(":COOPVERSION", coopVersion);
				param.AddParam(":SERIES_CD", row["SERIES_CD"]);

				db.ExecuteSQL(upSql, param.GetParam());
			}
		}
		//add  #10840 COP_EVENT_MANAGEの最新連携種別を取得する end

		//add  #11576 pat_coop_detailのsave_1がGX固定でコンバートされる start
		bool IsSpecialChanged(string oldVal, string newVal, string oldVersion, string newVersion)
		{
			var specialSet = new System.Collections.Generic.HashSet<string> { "GX", "HR", "MED" };

			bool isSetChanged =
	             !string.Equals(oldVal, newVal)
				&& (specialSet.Contains(oldVal) || specialSet.Contains(newVal));

			// Version
			bool isVersionChanged =
				!string.Equals(oldVersion, newVersion);

			return isSetChanged || isVersionChanged;
		}
		//add  #11576 pat_coop_detailのsave_1がGX固定でコンバートされる end
	}
}
