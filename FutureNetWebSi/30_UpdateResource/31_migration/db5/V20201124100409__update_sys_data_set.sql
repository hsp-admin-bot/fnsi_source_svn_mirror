--------------------------------------------------
-- データセット
-- スケジュール表のSQL文を更新
--------------------------------------------------
UPDATE
  sys_data_set
SET
  "sql" = '
  with mk as (
    select kur_cd, kur_name, kur_start_time from mst_kur where facility_cd = @facilityCd and is_del = ''0'' and kur_cd IN ( @selectKurCd )
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
  ;
  ',
  up_date = current_timestamp
WHERE
  sql_cd = 132
;
