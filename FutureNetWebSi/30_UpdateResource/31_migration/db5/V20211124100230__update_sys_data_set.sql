UPDATE "ntss"."sys_data_set" SET "sql" = '
   with mb as (
     select * from mst_bed where facility_cd = @facilityCd and is_disp = ''1'' and is_del = ''0''  and machine_no is not null
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
  ', "db_class" = 2, "detail" = '[{"preview": "テスト患者", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_name", "target_var": "@patId"}, "data_code": "pat_id", "data_name": "患者名", "data_type": "string", "conv_table": [], "data_class": "スケジュール表", "field_name": "pat_id", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0000000000000000010", "can_calc": "0", "data_code": "bed_disp_order", "data_name": "ベッド表示順", "data_type": "string", "conv_table": [], "data_class": "スケジュール表", "field_name": "bed_disp_order", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テストベッド０１", "can_calc": "0", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "スケジュール表", "field_name": "bed_name", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "23", "can_calc": "0", "data_code": "bed_cd", "data_name": "ベッドコード", "data_type": "string", "conv_table": [], "data_class": "スケジュール表", "field_name": "bed_cd", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20200407", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "string", "conv_table": [], "data_class": "スケジュール表", "field_name": "treat_date", "disp_format": "yyyymmdd", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "午前", "can_calc": "0", "data_code": "kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "スケジュール表", "field_name": "kur_name", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}]', "can_repeat" = '0', "use_application" = '{"applications": [1]}', "report_class" = '{"classes": []}', "memo" = 'スケジュール表 @facilityCd @fromDate @toDate 使用', "reg_date" = '2020-04-02 00:00:00', "up_date" = '2021-05-13 19:34:54', "pre_sql_info" = NULL WHERE "sql_cd" = 128;
