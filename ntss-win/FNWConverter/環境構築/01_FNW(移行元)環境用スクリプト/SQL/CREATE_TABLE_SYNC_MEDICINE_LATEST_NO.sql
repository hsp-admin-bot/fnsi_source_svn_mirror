-- テーブル削除
declare
      num number;
begin
    select count(1) into num from user_tables where table_name = upper('SYNC_MEDICINE_LATEST_NO') ;
    if num > 0 then
        execute immediate 'drop table SYNC_MEDICINE_LATEST_NO CASCADE CONSTRAINTS' ;
    end if;
end;
/
-- テーブル作成
CREATE TABLE SYNC_MEDICINE_LATEST_NO
(
    PATID CHAR(12) NOT NULL,
    IND_NO CHAR(7),
    DIALYSIS_NO NUMBER(12),
    RST_NO NUMBER(7),
    PLURAL NUMBER(1),
    UP_DATE DATE NOT NULL,
    NO NUMBER(12) NOT NULL,
    SERIES_CD CHAR(3) NOT NULL
)
    tablespace NKK_DATA_COP;
    
-- DECLARE
--     v_no NUMBER := 1;
-- BEGIN
--     FOR r IN (
--         SELECT SERIES_CD
--         FROM SYS_SERIES_FACILITY
--         ORDER BY SERIES_CD
--     ) LOOP
-- 
-- insert into  SYNC_MEDICINE_LATEST_NO(PATID,IND_NO,
-- 							RST_NO,
-- 							DIALYSIS_NO,
-- 							PLURAL,UP_DATE,NO,SERIES_CD)
--                            (SELECT
-- 	a.*,
-- 	row_number ( ) over ( partition BY PATID ORDER BY PATID, IND_NO,RST_NO ) AS no，r.SERIES_CD
-- FROM
-- 	(
-- 		WITH MEDI_TMP AS ( SELECT DIALYSIS_NO, CTL_NO, IND_NO, MAX( IND_UP_DATE ) MAX_UP_DATE FROM RST_DIALYSIS_MEDICATION GROUP BY DIALYSIS_NO, CTL_NO, IND_NO ),
-- 		IND_DEVELOP_MEDI_NORMAL AS (
-- 		SELECT
-- 			w1.IND_ID,
-- 			w1.CTL_NO,
-- 			w1.MEDICINE_CD,
-- 			w1.PATID,
-- 			row_number ( ) over ( partition BY w1.IND_ID, MEDICINE_CD ORDER BY w1.IND_ID, w1.CTL_NO ) AS row_no 
-- 		FROM
-- 			IND_DEVELOP_MEDI w1 
-- 		),
-- 		RST_DIALYSIS_MEDICATION_NORMAL AS (
-- 		SELECT
-- 			w2.CTL_NO,
-- 			w2.DIALYSIS_NO,
-- 			IND_UP_DATE,
-- 			IND_NO,
-- 			SCH_PLAN.IND_ID,
-- 			SCH_PLAN.PLURAL,
-- 			PATID,w2.UP_DATE,
-- 		CASE		
-- 				WHEN SET_MEDICINE_FLG = '0' THEN
-- 				MEDICINE_CD ELSE SET_MEDICINE_CD 
-- 			END AS MEDI_CD,
-- 			row_number ( ) over ( partition BY DIALYSIS_NO, MEDICINE_CD ORDER BY DIALYSIS_NO, EFFECT_DATE ) AS row_no 
-- 		FROM
-- 			RST_DIALYSIS_MEDICATION w2
-- 			INNER JOIN SCH_DIALYSIS_PLAN SCH_PLAN ON SCH_PLAN.RESULT_DIALYSISNO = w2.DIALYSIS_NO 
-- 		) SELECT
-- 		MEDI.PATID,
-- 		MEDI.CTL_NO AS IND_NO,
-- 		NULL AS RST_NO,
-- 		NULL AS DIALYSIS_NO,
-- 		MEDI.PLURAL ,MAX(UP_DATE) as UP_DATE
-- 	FROM
-- 		IND_DIALYSIS_MEDI MEDI 
-- 	GROUP BY
-- 		MEDI.PATID,
-- 		MEDI.PLURAL,
-- 		MEDI.CTL_NO UNION ALL
-- 	SELECT
-- 		RST_MEDI.PATID,
-- 		NULL AS IND_NO,
-- 		RST_MEDI.CTL_NO AS RST_NO,
-- 		RST_MEDI.DIALYSIS_NO,
-- 		RST_MEDI.PLURAL,RST_MEDI.UP_DATE
-- 		FROM
-- 		RST_DIALYSIS_MEDICATION_NORMAL RST_MEDI
-- 		INNER JOIN MEDI_TMP MEDI ON RST_MEDI.DIALYSIS_NO = MEDI.DIALYSIS_NO
-- 		AND RST_MEDI.CTL_NO = MEDI.CTL_NO
-- 		AND RST_MEDI.IND_NO = MEDI.IND_NO
-- 		AND RST_MEDI.IND_UP_DATE = MEDI.MAX_UP_DATE
-- 		LEFT JOIN IND_DEVELOP_MEDI_NORMAL DEVELOP_MEDI ON RST_MEDI.IND_ID = DEVELOP_MEDI.IND_ID
-- 		AND DEVELOP_MEDI.MEDICINE_CD = RST_MEDI.MEDI_CD
-- 		AND RST_MEDI.row_no = DEVELOP_MEDI.row_no
-- 		WHERE
-- 		DEVELOP_MEDI.CTL_NO IS NULL
-- 		UNION ALL
-- 		SELECT
-- 			r.PATID,
-- 			NULL AS IND_NO,
--             w2.CTL_NO  AS RST_NO,
--             w2.DIALYSIS_NO,
--             null as PLURAL,	                           
--             w2.UP_DATE 
--         FROM
--             RST_DIALYSIS_MEDICATION w2
-- 										INNER JOIN   RST_DIALYSIS r on r.DIALYSIS_NO= w2.DIALYSIS_NO 
--             LEFT JOIN SCH_DIALYSIS_PLAN SCH_PLAN ON SCH_PLAN.RESULT_DIALYSISNO = w2.DIALYSIS_NO 	
-- 　　　　where  SCH_PLAN.RESULT_DIALYSISNO IS NULL
-- 	) a);
--         v_no := v_no + 1;
--     END LOOP;
-- 
--     COMMIT;
-- END;