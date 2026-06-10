delete from sys_data_set where sql_cd in (-1202021);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1202021, '-- 【SQL_CD=-1202021】
WITH dial_diff_com_info AS (
SELECT
  info ->> ''reg_date'' AS reg_date,
  info ->> ''is_main'' AS is_main,
  info ->> ''dial_diff_cd'' AS dial_diff_cd,
  info ->> ''is_dial_diff'' AS is_dial_diff
FROM
  pat_personal_main ppm
CROSS JOIN LATERAL json_array_elements(ppm.dial_diff_com_info::json) info
WHERE
  ppm.pat_id = @patId
  AND ppm.is_del = ''0''
)
SELECT
  COALESCE(json_agg(dial_diff_com_info), ''[{"dial_diff_cd":"","is_dial_diff":""}]''::json)::text AS pat_personal_info
FROM
  dial_diff_com_info',3,'[{}]','0','{"applications": [4]}',NULL,'SX_医事連携（患者情報取得）',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,NULL);
