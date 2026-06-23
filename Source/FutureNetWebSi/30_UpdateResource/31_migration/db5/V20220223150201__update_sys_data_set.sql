DELETE FROM "ntss"."sys_data_set" where "sql_cd" = -14;
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
  ELSE ord.ind_treat_start_time
  END AS start_time
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
  to_char((cast(ord.treat_date as date) ||'' ''|| cast((SELECT start_time FROM start_time_info) as time))::TIMESTAMP + ((ord.ind_cond_info->''1''->>''value'') || ''H'')::interval, ''YYYYMMDD'') AS end_date,
  to_char((cast(ord.treat_date as date) ||'' ''|| cast((SELECT start_time FROM start_time_info) as time))::TIMESTAMP + ((ord.ind_cond_info->''1''->>''value'') || ''H'')::interval, ''HH24MISS'') AS end_time
FROM 
  ord_main ord
WHERE
  ord.ord_no = @ordNo', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）透析予約：予約時間取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-14, 'select
  to_char(ord.rst_start_date,''YYYYMMDDHH24MISS'') as start_date14,--透析開始日時
  to_char(ord.rst_start_date,''YYYY/MM/DD HH24:MI:SS'') as start_date14a,--透析開始日時
  to_char(ord.rst_start_date,''YYYYMMDD'') as start_date8,--透析開始日時
  to_char(ord.rst_start_date,''YYYY/MM/DD'') as start_date8a,--透析開始日時
  to_char(ord.rst_start_date,''HH24MISS'') as start_date6,--透析開始日時
  to_char(ord.rst_start_date,''HH24:MI:SS'') as start_date6a,--透析開始日時
  to_char(ord.rst_end_date,''YYYYMMDDHH24MISS'') as end_date14,--透析終了日時
  to_char(ord.rst_end_date,''YYYYMMDD'') as end_date8,--透析終了日時
  to_char(ord.rst_end_date,''HH24MISS'') as end_date6,--透析終了日時
  to_char(ord.rst_end_date,''YYYY/MM/DD HH24:MI:SS'') as end_date14a,--透析終了日時
  to_char(ord.rst_end_date,''YYYY/MM/DD'') as end_date8a,--透析終了日時
  to_char(ord.rst_end_date,''HH24:MI:SS'') as end_date6a,--透析終了日時
  to_char(ord.rst_start_date,''HH24MI'') as start_time4,--透析開始時刻
  to_char(ord.rst_end_date,''HH24MI'') as end_time4,--透析終了時刻
  ord.rst_running_time as running_time,
  RIGHT(''00''||TRUNC(TO_NUMBER(ord.rst_cond_info->''1''->>''value'',''999999'')/60,0),2)||'':''||RIGHT(''00''||MOD(TO_NUMBER(ord.rst_cond_info->''1''->>''value'',''999999''),60),2) as treatment_time,
  to_char(timestamp ''now'',''YYYYMMDDHH24MISS'') as nowtime14,
  ord.treat_date as treat_date,
  ord.ind_treat_start_time || ''00'' as ind_treat_start_time
from
  ord_main as ord
where
  ord.ord_no = @ordNo', 2, '[{}]', '0', '{"applications": [4]}', NULL, '実績）透析開始終了日時変換', '2020-03-27 10:46:07', CURRENT_TIMESTAMP, NULL);
