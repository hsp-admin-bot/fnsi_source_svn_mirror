DELETE FROM ntss.sys_data_set
WHERE sql_cd in (-1106003, -1100016);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1106003, 'select
  case @crud
    when ''del'' then
  		CASE @dumpResult
  			WHEN ''1'' THEN ''01''
  			ELSE ''02''
  		END 
  	else ''01''
  end AS detail_id,
  @facilityCd AS facility_cd,
  @ctlNo AS ctl_no,
  @key0 AS key0,
  @patId AS pat_id,
  @ordNo AS ord_no,
  @fileName AS file_name,
  '''' AS folder_name', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの放射線オーダー_実施単位のdetail特定', '2025-06-25 16:30:15.736', CURRENT_TIMESTAMP, '[{"sql_cd": -1100008, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}, {"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1100016, 'WITH dump_text AS (
SELECT
  convert_from(scj.dump, ''shift-jis'') AS dump_text
FROM
  sys_coop_journal AS scj
WHERE
  pat_id = @patId
  AND facility_cd = @facilityCd
  AND crud = ''C''
  AND ord_no = @ordNo
  AND coop_cd = @coopCd
  AND key0 = @key0
  AND ana_result = ''9''
  AND coop_result = ''9''
ORDER BY
  scj.up_date DESC
LIMIT 1
)
SELECT
  CASE Count(*)
    WHEN 0 THEN NULL
	ELSE 1
  END AS dump_result
FROM
	dump_text', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携_従来処理呼出判定', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

