DELETE FROM sys_data_set WHERE sql_cd=-1104002;

INSERT INTO sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1104002, 'WITH ind_memo AS (
  SELECT COALESCE(save_2 ->> ''sequence_no'', '''') AS sequence_no
  FROM pat_coop_detail
  WHERE
    save_2 ->> ''ord_no'' = @ordNo
    AND save_2 ->> ''coop_code'' = ''ind_dial''
    AND facility_cd = @facilityCd
  ORDER BY up_date
  LIMIT 1
),
acc_memo AS (
  SELECT COALESCE(save_2 ->> ''sequence_no'', '''') AS sequence_no
  FROM pat_coop_detail
  WHERE
    save_2 ->> ''coop_code'' = ''accept''
    AND facility_cd = @facilityCd
    AND save_2 ->> ''ord_no'' <> @ordNo
  ORDER BY up_date
  LIMIT 1
)
SELECT 
  CASE 
    WHEN (SELECT sequence_no FROM ind_memo) = '''' THEN NULL
    WHEN (SELECT sequence_no FROM acc_memo) <> '''' THEN NULL
    ELSE 1
  END AS result;
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム　再来受付', '2025-05-27 13:22:20.305', '2025-05-27 13:22:20.305', NULL);

