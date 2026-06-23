DELETE FROM "ntss"."sys_data_set" WHERE "sql_cd" = -53;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-53, 'WITH sch_start_time_info AS (
  SELECT
    0 AS order_no 
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS start_time_kbn 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''COOP_CONFIG'' 
    AND info ->> ''key2'' = ''SCH_START_TIME'' 
  UNION
  SELECT
    1 AS order_no 
    , ''0'' AS start_time_kbn 
  ORDER BY order_no ASC LIMIT 1
)
, start_time_info AS (
SELECT
  CASE WHEN (SELECT start_time_kbn FROM sch_start_time_info) = ''0''
  THEN mk.kur_standard_start_time
  ELSE ord.ind_treat_start_time || ''00''
  END AS start_time,
	RIGHT(''00''||TRUNC(TO_NUMBER(ord.ind_cond_info->''1''->>''value'',''9999'')/60,0),2)||'':''||RIGHT(''00''||MOD(TO_NUMBER(ord.ind_cond_info->''1''->>''value'',''9999''),60),2) AS treat_time
FROM 
  ord_main ord
LEFT OUTER JOIN
  mst_kur mk
ON
  ord.ind_kur_cd = mk.kur_cd
WHERE
  ord.ord_no = @ordNo
)
SELECT
  ord.treat_date AS start_date,
  (SELECT start_time FROM start_time_info) AS start_time,
  to_char((cast(ord.treat_date as date) ||'' ''|| cast((SELECT start_time FROM start_time_info) as time))::TIMESTAMP + ((SELECT treat_time FROM start_time_info) || ''H'')::interval, ''YYYYMMDD'') AS end_date,
  to_char((cast(ord.treat_date as date) ||'' ''|| cast((SELECT start_time FROM start_time_info) as time))::TIMESTAMP + ((SELECT treat_time FROM start_time_info) || ''H'')::interval, ''HH24MISS'') AS end_time
FROM 
  ord_main ord
WHERE
  ord.ord_no = @ordNo', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）透析予約：予約時間取得', '2022-02-23 16:10:41.424', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-59, 'WITH sch_start_time_info AS (
  SELECT
    0 AS order_no 
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS start_time_kbn 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''COOP_CONFIG'' 
    AND info ->> ''key2'' = ''SCH_START_TIME'' 
  UNION
  SELECT
    1 AS order_no 
    , ''0'' AS start_time_kbn 
  ORDER BY order_no ASC LIMIT 1
)
SELECT
  ord.treat_date AS treat_date,
  CASE WHEN (SELECT start_time_kbn FROM sch_start_time_info) = ''0''
  THEN mk.kur_standard_start_time
  ELSE ord.ind_treat_start_time || ''00''
  END AS start_time
FROM
  ord_main ord
LEFT OUTER JOIN
  mst_kur mk
ON
  ord.ind_kur_cd = mk.kur_cd
WHERE
  ord.ord_no = @ordNo', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）透析予約：オーダ日付とオーダ時間取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
