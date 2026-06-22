delete from ntss.sys_data_set
where sql_cd in (-1104002,-1104005);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1104002, 'WITH ind_memo AS (
  SELECT COALESCE(save_2 ->> ''sequence_no'', '''') AS sequence_no
  FROM pat_coop_detail
  WHERE
    save_2 ->> ''ord_no'' = @ordNo
    AND save_2 ->> ''coop_cd'' = ''ind_dial'' 
    AND facility_cd = @facilityCd
  ORDER BY up_date
  LIMIT 1
),
acc_memo AS (
  SELECT 1
  FROM pat_coop_detail p
  JOIN ind_memo i
    ON COALESCE(p.save_2 ->> ''sequence_no'', '''') = i.sequence_no
  WHERE
    p.save_2 ->> ''coop_cd'' = ''accept''
    AND p.facility_cd = @facilityCd
    AND p.save_2 ->> ''ord_no'' <> @ordNo
  LIMIT 1
)
SELECT 1 AS result
FROM ind_memo
WHERE NOT EXISTS (SELECT 1 FROM acc_memo);', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム　再来受付', '2025-05-27 13:22:20.305', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1104005, 'WITH
  get_sequence_no AS (
	SELECT save_2->>''sequence_no'' AS sequence_no
	FROM pat_coop_detail
	WHERE save_2->>''ord_no'' = @ordNo
	  AND save_2->>''coop_cd'' = ''ind_dial''
	ORDER BY up_date DESC
	LIMIT 1
  )
, create_memo AS (
    SELECT json_build_object(
      ''coop_cd'', ''accept'',
      ''ord_no'', @ordNo::text,
      ''sequence_no'', sequence_no
    ) AS result_json
    FROM get_sequence_no
  )

INSERT INTO ntss.pat_coop_detail(
    facility_cd,
    pat_id,
    save_1,
    save_2,
    is_disp,
    is_del,
    user_id,
    up_date,
    reg_date,
    coop_version
)
SELECT
    @facilityCd,
    @patId::bigint,
    ''{"pkg": "Secom"}''::jsonb,
    (SELECT result_json FROM create_memo),
    ''1'',
    ''0'',
    - 1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    ''Secom''', 2, '[]'::jsonb, '0', '{"applications": [6]}'::jsonb, NULL, '再来受付_送信履歴メモ', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);