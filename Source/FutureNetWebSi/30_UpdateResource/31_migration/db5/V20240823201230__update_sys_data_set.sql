DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-59)
;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-59, 'WITH sch_start_time_info AS (
  SELECT
    0 AS order_no 
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS start_time_kbn 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info ->> ''key1'' = ''COOP_CONFIG'' 
    AND info ->> ''key2'' = ''SCH_START_TIME'' 
  UNION
  SELECT
    1 AS order_no 
    , ''0'' AS start_time_kbn 
  ORDER BY order_no ASC LIMIT 1
)
(SELECT
  ord.treat_date AS treat_date,
  CASE WHEN (SELECT start_time_kbn FROM sch_start_time_info) = ''0''
  THEN mk.kur_standard_start_time
  ELSE SUBSTRING ( (ord.ind_schedule_user_info->''ind_treat_start_time'')::text, 2, 4 ) || ''00''
  END AS start_time
FROM
  ord_main ord
LEFT OUTER JOIN
  mst_kur mk
ON
  ord.ind_kur_cd = mk.kur_cd
WHERE
  ord.ord_no = @ordNo)
	UNION
	(SELECT
  ord.treat_date AS treat_date,
  CASE WHEN (SELECT start_time_kbn FROM sch_start_time_info) = ''0''
  THEN mk.kur_standard_start_time
  ELSE ord.ind_treat_start_time || ''00''
  END AS start_time
FROM
  ord_main_restore ord
LEFT OUTER JOIN
  mst_kur mk
ON
  ord.ind_kur_cd = mk.kur_cd
WHERE
  ord.ord_no = @ordNo
	and (select count(1) from ord_main where ord_no = @ordNo) = ''0''
	order by del_date desc limit 1)', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '富士通）透析予約：オーダ日付とオーダ時間取得', '2022-03-22 10:53:38.415', '2023-09-15 14:09:11.112', NULL);

