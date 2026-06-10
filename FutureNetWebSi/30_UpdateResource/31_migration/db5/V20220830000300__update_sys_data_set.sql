DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (-62);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-62, 'WITH data_info AS (
  SELECT
    TO_CHAR((CASE WHEN ord.rst_fn_dialysis_no IS NOT NULL AND ord.rst_fn_dialysis_no > 0 THEN ord.rst_fn_dialysis_no ELSE ord.ord_no END), ''FM0999999999999999999'') AS ord_no
    , ord.rst_edition
    , coop.hosp_pat_id
  FROM
    ord_main AS ord, sys_coop_journal AS coop
  WHERE
    ord.ord_no = @ordNo
  AND coop.ctl_no = @ctlNo
  AND coop.ord_no = ord.ord_no
)
SELECT
  LPAD(LTRIM(hosp_pat_id)::TEXT, 12, ''0'')
  || (CASE WHEN CHAR_LENGTH(ord_no::TEXT) > 12 THEN RIGHT(ord_no::TEXT,12) ELSE RPAD(ord_no::TEXT, 12, ''0'') END)
  || LPAD(rst_edition::TEXT, 4, ''0'') 
  || ''.pdf'' AS filename
FROM data_info', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）PDFの名称の取得', '2022-04-04 16:37:06.279', CURRENT_TIMESTAMP, NULL);
