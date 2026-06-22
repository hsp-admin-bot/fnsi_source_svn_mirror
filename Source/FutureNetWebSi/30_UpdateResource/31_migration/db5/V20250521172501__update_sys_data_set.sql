DELETE FROM sys_data_set WHERE sql_cd=-1104004;

INSERT INTO sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1104004, 'WITH staff_candidates AS (
  SELECT 
    (elem ->> ''staff_cd'')::int AS staff_cd,
    (elem ->> ''disp_order'')::int AS disp_order
  FROM pat_main
  CROSS JOIN LATERAL jsonb_array_elements(charge_staff_info) AS elem
  WHERE pat_id = @patId
    AND elem ->> ''is_main'' = ''1''
  ORDER BY (elem ->> ''disp_order'')::int ASC
  LIMIT 2
),
ranked_staff AS (
  SELECT staff_cd
  FROM staff_candidates
  ORDER BY disp_order ASC
  LIMIT 1 OFFSET 0
),
fallback_staff AS (
  SELECT staff_cd
  FROM staff_candidates
  ORDER BY disp_order ASC
  LIMIT 1 OFFSET 1
)
,selected_staff AS (
  SELECT COALESCE(
    (SELECT staff_cd FROM ranked_staff),
    (SELECT staff_cd FROM fallback_staff),
    NULL
  ) AS reserved_by_user_id
),
user_auth_list AS (
  SELECT
    (auth_elem ->> ''user_id'')::int AS user_id,
    auth_elem ->> ''disp_user_id'' AS disp_user_id
  FROM jsonb_array_elements(@userList::jsonb) AS auth_elem
),
ini AS (
  SELECT
    COALESCE(NULLIF(info ->> ''value'',''''),info ->> ''default_v'') AS value
  FROM
    MST_COOP_INI ini
  CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    1 = 1
    AND ini.FACILITY_CD = @facilityCd
    AND ini.IS_DEL = ''0''
    AND info ->> ''key1'' = ''DIALYSISSCHESEND''
    AND info ->> ''key2'' = ''DEFAULT_DOCTOR'' 
),
final AS (
  SELECT
    s.reserved_by_user_id,
    CASE 
      WHEN LENGTH(COALESCE(u.disp_user_id, ini.value , ''      '')) >= 7 
        THEN RIGHT(COALESCE(u.disp_user_id, ini.value , ''      ''), 6)
      ELSE LPAD(COALESCE(u.disp_user_id, ini.value , ''      ''), 6, '' '')
    END AS disp_user_id
  FROM selected_staff s
  LEFT JOIN user_auth_list u
    ON s.reserved_by_user_id = u.user_id
  CROSS JOIN ini
)
SELECT * FROM final', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'セコム連携 再来受付予約担当ユーザーID', '2020-07-31 18:29:49.000', '2020-07-31 18:29:49.000', '[{"sql_cd": -1100003, "field_name": "user_list", "replace_var": "@userList"}]'::jsonb);