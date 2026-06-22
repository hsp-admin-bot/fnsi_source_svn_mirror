DELETE FROM sys_data_set WHERE sql_cd IN 
(-1100000);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1100000, 'WITH all_values AS (
SELECT
  COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
  info ->> ''key1'' AS key1,
  info ->> ''key2'' AS key2
FROM
  mst_coop_ini AS ini
CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
WHERE
  facility_cd = @facilityCd
  AND is_del = ''0''
  AND COALESCE(info ->> ''key0'', '''') = @key0
  AND info ->> ''key1'' IN (
    ''SCM_COMMON'',
    ''SCM_XRAY_ORDER_SEND'',
    ''SCM_CONV_UNIT_MEDI''
    )
)
, jounal AS (
SELECT
  to_char(reg_date, ''YYYY-MM-DD'') AS occur_date,
  to_char(reg_date, ''HH24:MI:SS'') AS occur_time
FROM
  sys_coop_journal
WHERE
  ctl_no = @ctlNo
)
SELECT
  ini_value.hospital_id AS hospital_id,
  ini_value.course_cd1 AS course_cd1,
  ini_value.course_cd2 AS course_cd2,
  ini_value.unit_medi AS unit_medi,
  ini_value.xx_type_code AS xx_type_code,
  to_char(to_timestamp(@sharedSysdate, ''YYYYMMDDHH24MISS''), ''YYYY-MM-DD'') AS occur_date,
  to_char(to_timestamp(@sharedSysdate, ''YYYYMMDDHH24MISS''), ''HH24:MI:SS'') AS occur_time
FROM
  (SELECT
    (SELECT value FROM all_values WHERE key1 = ''SCM_COMMON'' AND key2 = ''HOSPITAL_ID'') AS hospital_id,
    (SELECT value FROM all_values WHERE key1 = ''SCM_COMMON'' AND key2 = ''COURSE_CD1'') AS course_cd1,
    (SELECT value FROM all_values WHERE key1 = ''SCM_COMMON'' AND key2 = ''COURSE_CD2'') AS course_cd2,
    (SELECT value FROM all_values WHERE key1 = ''SCM_CONV_UNIT_MEDI'' AND key2 = ''ml'') AS unit_medi,
    (SELECT value FROM all_values WHERE key1 = ''SCM_COMMON'' AND key2 = ''XX_TYPE_CODE'') AS xx_type_code
  ) AS ini_value
CROSS JOIN jounal', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携汎用_連携設定、検査日時、発生日取得', '2025-06-03 08:30:43.103', CURRENT_TIMESTAMP, NULL);