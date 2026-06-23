--------------------------------------------------
-- データセット
-- スケジュール表のSQL文を更新
--------------------------------------------------
UPDATE
  sys_data_set
SET
  "sql" = '
   with mb as (
     select * from mst_bed where facility_cd = @facilityCd and is_disp = ''1'' and is_del = ''0''
  )
  , mk as (
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
        mb, mk, treat_date_records
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
   , bed_disp_order_tbl as (
     select
        one_json->>''code'' as bed_cd
         --,one_json->>''name'' as bed_name
         ,json_idx as bed_disp_order
      from
        mst_selector
      cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(one_json, json_idx)
      where
        facility_cd = @facilityCd and master_physical_name = ''mst_bed''
  )
   
  select
     lpad(bed_disp_order::text, 19, ''0'') as bed_disp_order
      ,sche_cells.bed_name
      ,sche_cells.bed_cd
      ,sche_cells.treat_date
      ,sche_cells.kur_name
      ,pat_id
   from
     sche_cells
      left outer join om
      on sche_cells.treat_date = om.treat_date
          and sche_cells.bed_cd = om.ind_bed_cd
            and sche_cells.kur_cd = om.ind_kur_cd
      left outer join bed_disp_order_tbl
        on sche_cells.bed_cd::text = bed_disp_order_tbl.bed_cd::text
   order by
     bed_disp_order nulls last, sche_cells.treat_date, kur_start_time
  ;
  ',
  up_date = current_timestamp
WHERE
  sql_cd = 128
;
