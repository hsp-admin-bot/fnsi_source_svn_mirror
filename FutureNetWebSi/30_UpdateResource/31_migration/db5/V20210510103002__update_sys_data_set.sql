UPDATE "ntss"."sys_data_set" 
SET 
"can_repeat" = '0', 
"use_application" = '{"applications": []}',
"report_class" = '{"classes": []}'
WHERE 
"sql_cd" = 132;

DELETE FROM "ntss"."sys_data_set" WHERE "sql_cd"  = 153;

INSERT INTO "ntss"."sys_data_set" ( "sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info" )
VALUES
	( 153, 'with mk as (
  select kur_cd, kur_name, kur_start_time from mst_kur where facility_cd = @facilityCd and is_del = ''0''
)
, treat_date_records as (
  select
    to_char(generate_series, ''yyyymmdd'') as treat_date
  from
    generate_series(date_trunc(''day'', ( @fromDate )::timestamp), date_trunc(''day'', ( @toDate )::timestamp) + ''1 days - 1 milliseconds'', ''1 day'')
)
, sche_cells as (
  select
    *
  from
    mk, treat_date_records
)
, om as (
  select
    *
  from
    ord_main
  where
    facility_cd = @facilityCd
  and
    treat_date between to_char(date_trunc(''day'', ( @fromDate )::timestamp), ''yyyymmdd'') and to_char(date_trunc(''day'', ( @toDate )::timestamp) + ''1 days - 1 milliseconds'', ''yyyymmdd'')
  and
    is_del = ''0''
)
, bed_unreg_count_tbl as (
  select
    treat_date, ind_kur_cd, count(*) as bed_unreg_count
  from
    om
  where
    ind_bed_cd = 0 and ind_kur_cd <> 0
  group by
    treat_date, ind_kur_cd
  order by
    treat_date
)
, count_tbl as (
  select
    treat_date, ind_kur_cd, count(*) as count
  from
    om
  where
    ind_bed_cd <> 0  and ind_kur_cd <> 0
  group by
    treat_date, ind_kur_cd
  order by
    treat_date
)

select
  sche_cells.treat_date
  ,sche_cells.kur_name
  ,case when bed_unreg_count is not null then bed_unreg_count else 0 end as bed_unreg_count
  ,case when count is not null then count else 0 end as count
  ,''dummy_bed_name'' as dummy_bed_name
from
  sche_cells
  left outer join bed_unreg_count_tbl
    on sche_cells.treat_date = bed_unreg_count_tbl.treat_date and sche_cells.kur_cd = bed_unreg_count_tbl.ind_kur_cd
  left outer join count_tbl
    on sche_cells.treat_date = count_tbl.treat_date and sche_cells.kur_cd = count_tbl.ind_kur_cd
order by
  sche_cells.treat_date, kur_start_time
;', 2, '[{"preview": "5", "can_calc": "0", "data_code": "bed_unreg_count", "data_name": "ベッド未登録数", "data_type": "decimal", "conv_table": [], "data_class": "予約数／ベッド未登録数", "field_name": "bed_unreg_count", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "23", "can_calc": "0", "data_code": "count", "data_name": "予約数", "data_type": "decimal", "conv_table": [], "data_class": "予約数／ベッド未登録数", "field_name": "count", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20200407", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "string", "conv_table": [], "data_class": "予約数／ベッド未登録数", "field_name": "treat_date", "disp_format": "yyyymmdd", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "午前", "can_calc": "0", "data_code": "kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "予約数／ベッド未登録数", "field_name": "kur_name", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dummy_bed_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "予約数／ベッド未登録数", "field_name": "dummy_bed_name", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '@facilityCd  @fromdate  @todate', '2021-05-10 16:40:02', '2021-05-10 16:40:02', NULL );