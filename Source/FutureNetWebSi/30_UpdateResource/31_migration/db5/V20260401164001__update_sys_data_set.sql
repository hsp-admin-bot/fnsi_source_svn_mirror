DELETE FROM ntss.sys_data_set
WHERE sql_cd=1004;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(1004, '-- 【SQL_CD=1004】
WITH add_selector AS (
  SELECT
    index_no ::int AS idx_no
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS add_cd
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_addition''
)
, mst_add AS (
  SELECT *
  FROM mst_addition
  LEFT JOIN add_selector
    ON mst_addition.addition_cd = add_selector.add_cd
  WHERE facility_cd = @facilityCd
    AND is_del = ''0''
    AND is_disp = ''1''
  ORDER BY add_selector.idx_no ASC
)
SELECT
  json_agg (
    (SELECT
      jsonb_build_object(
        ''cd'',
        addition_cd,
        ''reg_date'',
        to_char(reg_date ::timestamp AT TIME ZONE ''JST'' AT TIME ZONE ''UTC'', ''YYYY-MM-DD"T"HH24:MI:SS.MS+00:00''),
        ''is_enable'',
        CASE addition_kind
          WHEN ''1'' THEN ''1''
          ELSE ''0''
          END,
        ''start_date'',
        NULL
      )
    ) :: JSON
  ) AS addition_info
FROM mst_add
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '外部連携用の[患者基本情報→加算情報]デフォルト値の取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);