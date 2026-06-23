DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (-77);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-77, 'WITH ord_main_restore_info AS (
  SELECT 
	  ord_no,
		rst_fn_dialysis_no,
		rst_edition
	FROM
	  ord_main_restore
	WHERE
	  pat_id = @patId
		AND
		ord_no = @ordNo
	ORDER BY
	  del_date DESC
	LIMIT 1
)
, data_info AS (
  SELECT
    TO_CHAR((CASE WHEN ord.rst_fn_dialysis_no IS NOT NULL AND ord.rst_fn_dialysis_no > 0 THEN ord.rst_fn_dialysis_no ELSE ord.ord_no END), ''FM0999999999999999999'') AS ord_no
    , ord.rst_edition
    , coop.hosp_pat_id
  FROM
    ord_main_restore_info AS ord, sys_coop_journal AS coop
  WHERE
    ord.ord_no = @ordNo
  AND coop.ord_no = ord.ord_no
	AND coop.ctl_no = @ctlNo
)
SELECT
  LPAD(LTRIM(hosp_pat_id)::TEXT, 12, ''0'')
  || (CASE WHEN CHAR_LENGTH(ord_no::TEXT) > 12 THEN RIGHT(ord_no::TEXT,12) ELSE RPAD(ord_no::TEXT, 12, ''0'') END)
  || LPAD(rst_edition::TEXT, 4, ''0'') 
  || ''.pdf'' AS filename
FROM data_info', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）PDFの名称の取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
