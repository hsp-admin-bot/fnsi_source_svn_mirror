delete from sys_data_set where sql_cd='149';
INSERT INTO "ntss"."sys_data_set" ( "sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info" )
VALUES
	( 149, 'with dz as ( 
    select
        * 
    from
        mst_dialyzer 
    where
        is_del = ''0''
        and is_disp = ''1''
) 
, kr as (select * from mst_kur where is_del = ''0'')
, bd as ( 
    select
        * 
    from
        mst_bed 
    where
        is_del = ''0'' 
        and is_disp = ''1''
) 
, eq as ( 
    select
        * 
    from
        mst_equipment 
    where
        is_del = ''0''
        and is_disp = ''1''
) 
, eqc as ( 
    select
        * 
    from
        mst_equipment_class 
    where
        is_del = ''0''
        and is_disp = ''1''
) 
, md as ( 
    select
        * 
    from
        mst_medicine 
    where
        is_del = ''0''
        and is_disp = ''1''
) 
, mdc as ( 
    select
        * 
    from
        mst_medicine_class 
    where
        is_del = ''0''
        and is_disp = ''1''
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
        when ''01'' then (select model_number from  dz where dialyzer_cd = TO_NUMBER(supplies_cd, ''99999999''))
        
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
    and sv.pat_id in (@patIds)', 2, '[{"preview": "テスト穿刺針", "can_calc": "0", "data_code": "supplies_name", "data_name": "材料名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "supplies_name", "disp_format": "", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/15", "can_calc": "0", "data_code": "supplies_base_date", "data_name": "データ基準日", "data_type": "DateTime", "conv_table": [], "data_class": "医材", "field_name": "supplies_base_date", "disp_format": "yyyy/mm/dd", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "ind_rst_value", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "医材", "field_name": "ind_rst_value", "disp_format": "0", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "total_unitH", "data_name": "各日医材合計", "data_type": "decimal", "conv_table": [], "data_class": "医材", "field_name": "total_unitH", "disp_format": "0", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "total_unitV", "data_name": "医材計", "data_type": "decimal", "conv_table": [], "data_class": "医材", "field_name": "total_unitV", "disp_format": "0", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '@patId @facilityCd  @fromdate  @todate', '2021-04-25 16:40:02', '2021-04-25 16:40:02', NULL );