DELETE FROM ntss.sys_data_set
WHERE sql_cd=-1202004;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1202004, 'SELECT
  CASE
    WHEN ppm.in_out_class IN (0, 1) THEN ppm.in_out_class
    ELSE NULL
    END AS in_out_class
  , CASE @aligh
		WHEN ''0'' THEN lpad(RIGHT(hosp_pat_id, COALESCE(@len, 15)), 15, ''0'')
    ELSE rpad(RIGHT(hosp_pat_id, COALESCE(@len, 15)), 15, ''0'')
    END AS hosp_pat_id
  , CONCAT(personal_info_decrypt(pat_first_name_kana), '' '', personal_info_decrypt(pat_last_name_kana)) AS pat_name_kana
  , CASE
    WHEN ppm.pat_sex IN (1, 2) THEN ppm.pat_sex
    ELSE 0
    END AS pat_sex
  , SUBSTRING(ppm.pat_birthday, 3) AS pat_birthday
FROM pat_personal_main ppm
WHERE
  ppm.pat_id = @patId
  AND ppm.is_del = ''0''', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SX_血液検査依頼患者情報', '2025-06-12 17:44:01.429', CURRENT_TIMESTAMP, '[{"sql_cd": -1201009, "field_name": "len", "replace_var": "@len"}, {"sql_cd": -1201008, "field_name": "aligh", "replace_var": "@aligh"}]'::jsonb);
