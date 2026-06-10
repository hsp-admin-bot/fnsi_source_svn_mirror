delete from ntss.sys_data_set where sql_cd in (-82);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-82, '
WITH del_time AS (
  SELECT
	  COUNT(*)::TEXT AS del
	FROM
		ord_coop_no ocn
	WHERE
		ocn.coop_cd = ''rst_dial'' 
		AND ocn.ord_no = @ordNo

		AND ocn.is_del = ''1''
)

SELECT
  (CASE 
		WHEN rst_fn_dialysis_no > 0 THEN
		LPAD(del, 3, ''0'') || SUBSTR(LPAD(rst_fn_dialysis_no::TEXT, 20, ''0''), 4, 20)
		ELSE
		LPAD(del, 3, ''0'') || SUBSTR(LPAD(ord_no::TEXT, 20, ''0''), 4, 20) 
		END)  AS document_no
FROM
	ord_main, del_time
WHERE
	ord_no = @ordNo
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）透析実績：伝票情報.文書番号取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -666, "field_name": "default_staff_cd", "replace_var": "@defaultStaffCd"}, {"sql_cd": -666, "field_name": "staff_cd_data", "replace_var": "@userId"}]');
