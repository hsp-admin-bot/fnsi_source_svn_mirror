UPDATE "ntss"."sys_data_set" SET "sql" = 'with 
 eq as ( 
    select
        equipment_name,equipment_cd
    from
        mst_equipment 
    where
        is_del = ''0''
        and is_disp = ''1''
				and facility_cd =@facilityCd
) 
 
, md as ( 
    select
       medicine_name,medicine_cd
    from
        mst_medicine 
    where
        is_del = ''0''
        and is_disp = ''1''
				and facility_cd =@facilityCd
) 

select

     supplies_base_date
    , supplies_source_class
    , supplies_class
    , supplies_cd
    , medicine_mix_cd
    , class_cd
    , ind_rst_value
    , receipt_value
    , case sv.supplies_class
        when ''01'' then (select model_number from ( select  model_number, dialyzer_cd  from  mst_dialyzer   where 
        is_del = ''0''
        and is_disp = ''1'' and facility_cd =@facilityCd ) dz where dialyzer_cd = TO_NUMBER(supplies_cd, ''99999999''))      
        when ''00'' then (select equipment_name  from  eq where equipment_cd = TO_NUMBER(supplies_cd, ''99999999''))
        when ''02'' then (select equipment_name  from  eq where equipment_cd = TO_NUMBER(supplies_cd, ''99999999''))
        when ''03'' then (select equipment_name  from  eq where equipment_cd = TO_NUMBER(supplies_cd, ''99999999''))
        when ''04'' then (select equipment_name  from  eq where equipment_cd = TO_NUMBER(supplies_cd, ''99999999''))
        when ''05'' then (select equipment_name  from  eq where equipment_cd = TO_NUMBER(supplies_cd, ''99999999''))
        when ''06'' then (select equipment_name  from  eq where equipment_cd = TO_NUMBER(supplies_cd, ''99999999''))
        when ''07'' then (select equipment_name  from  eq where equipment_cd = TO_NUMBER(supplies_cd, ''99999999''))        
        when ''11'' then (select equipment_name  from  eq where equipment_cd = TO_NUMBER(supplies_cd, ''99999999''))  
                 
        when ''08'' then (select medicine_name from  md where medicine_cd = TO_NUMBER(supplies_cd, ''99999999''))
        when ''09'' then (select medicine_name from  md where medicine_cd = TO_NUMBER(supplies_cd, ''99999999''))
        when ''10'' then (select medicine_name from  md where medicine_cd = TO_NUMBER(supplies_cd, ''99999999''))
        when ''12'' then (select medicine_name from  md where medicine_cd = TO_NUMBER(supplies_cd, ''99999999''))
        when ''13'' then (select medicine_name from  md where medicine_cd = TO_NUMBER(medicine_mix_cd, ''99999999''))
        when ''14'' then (select medicine_name from  md where medicine_cd = TO_NUMBER(supplies_cd, ''99999999''))
        when ''15'' then (select medicine_name from  md where medicine_cd = TO_NUMBER(medicine_mix_cd, ''99999999''))        
        when ''16'' then (select medicine_name from  md where medicine_cd = TO_NUMBER(supplies_cd, ''99999999'')) 
        when ''17'' then (select medicine_name from  md where medicine_cd = TO_NUMBER(supplies_cd, ''99999999'')) 
        
        else ''''
        end as supplies_name 

from
    ord_material_save as sv 
where
    sv.facility_cd = @facilityCd
    and sv.supplies_base_date >= @fromDate
    and sv.supplies_base_date <= @toDate
    and sv.pat_id in (@patIds)' WHERE "sql_cd" = 149;
UPDATE "ntss"."sys_data_set" SET "sql" = 'with mb as (
  select * from mst_bed where facility_cd = @facilityCd and is_disp = ''1'' and is_del = ''0'' and machine_no is not null
)
, mk as (
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
	,mb.in_hospital_cd_1
	,mb.in_hospital_cd_2
from
  sche_cells
  left outer join om
    on sche_cells.treat_date = om.treat_date
      and sche_cells.bed_cd = om.ind_bed_cd
      and sche_cells.kur_cd = om.ind_kur_cd
  left outer join bed_disp_order_tbl
    on sche_cells.bed_cd::text = bed_disp_order_tbl.bed_cd::text
	left join  mb 
   on 	   mb.bed_cd=sche_cells.bed_cd
order by
  bed_disp_order nulls last, sche_cells.treat_date, kur_start_time
;', "detail" = '[{"preview": "テスト患者", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_name", "target_var": "@patId"}, "data_code": "pat_name", "data_name": "患者名", "data_type": "string", "conv_table": [], "data_class": "スケジュール表", "field_name": "pat_id", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0000000000000000010", "can_calc": "0", "data_code": "bed_disp_order", "data_name": "ベッド表示順", "data_type": "string", "conv_table": [], "data_class": "スケジュール表", "field_name": "bed_disp_order", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テストベッド０１", "can_calc": "0", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "スケジュール表", "field_name": "bed_name", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_1", "data_name": "連携コード1", "data_type": "string", "conv_table": [], "data_class": "スケジュール表", "field_name": "in_hospital_cd_1", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_2", "data_name": "連携コード2", "data_type": "string", "conv_table": [], "data_class": "スケジュール表", "field_name": "in_hospital_cd_2", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/04/07", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "スケジュール表", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "午前", "can_calc": "0", "data_code": "kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "スケジュール表", "field_name": "kur_name", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}]' WHERE "sql_cd" = 152;
UPDATE "ntss"."sys_data_set" SET  "detail" = '[{"preview": "5", "can_calc": "0", "data_code": "bed_unreg_count", "data_name": "ベッド未登録数", "data_type": "decimal", "conv_table": [], "data_class": "予約数／ベッド未登録数", "field_name": "bed_unreg_count", "disp_format": "0", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "23", "can_calc": "0", "data_code": "count", "data_name": "予約数", "data_type": "decimal", "conv_table": [], "data_class": "予約数／ベッド未登録数", "field_name": "count", "disp_format": "0", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20200407", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "string", "conv_table": [], "data_class": "予約数／ベッド未登録数", "field_name": "treat_date", "disp_format": "yyyymmdd", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "午前", "can_calc": "0", "data_code": "kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "予約数／ベッド未登録数", "field_name": "kur_name", "disp_format": "", "data_category": "スケジュール表", "facility_table": "", "facility_filter_type": "0"}]' WHERE "sql_cd" = 153;
UPDATE "ntss"."sys_data_set" SET "sql" = 'SELECT
	rst_bed_cd,	
	rst_machine_name,
	rst_start_date,
	rst_dialysis_state
from ord_main ord 
where ord.facility_cd = @facilityCd
and rst_start_date >= @fromDate
and rst_start_date <= @toDate
and ord.rst_dialysis_state <>''0''
and rst_machine_name <>''''
order by rst_start_date desc
;', "detail" = '[{"preview": "2020/04/07", "can_calc": "0", "data_code": "rst_start_date", "data_name": "使用日", "data_type": "DateTime", "conv_table": [], "data_class": "装置一覧表", "field_name": "rst_start_date", "disp_format": "yyyy/mm/dd", "data_category": "装置一覧表", "facility_table": "", "facility_filter_type": "0"}, {"preview": "装置A", "can_calc": "0", "data_code": "rst_machine_name", "data_name": "装置名", "data_type": "string", "conv_table": [], "data_class": "装置一覧表", "field_name": "rst_machine_name", "disp_format": "", "data_category": "装置一覧表", "facility_table": "", "facility_filter_type": "0"}]' WHERE "sql_cd" = 156;
