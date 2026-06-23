DELETE from sys_data_set where sql_cd = 74;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (74, 'with ord_key_tbl as (
select
	facility_cd
from
	ord_main
where
	ord_no = @ordNo
	and is_del = ''0'' 
	and rst_dialysis_state = ''0''
	), dialyzer_tbl as (
select
	*
from
	mst_dialyzer
where
	mst_dialyzer.facility_cd = (select facility_cd from ord_key_tbl)
and
	mst_dialyzer.is_disp = ''1''
and
	mst_dialyzer.is_del = ''0''
	
	), equipment_tbl as (
select
    *
  from
    mst_equipment
  where
    mst_equipment.facility_cd = (select facility_cd from ord_key_tbl)
  and
    mst_equipment.is_disp = ''1''
  and
    mst_equipment.is_del = ''0''
		
		), equipment_class_tbl as (
  select
    *
  from
    mst_equipment_class
  where
    mst_equipment_class.facility_cd = (select facility_cd from ord_key_tbl)
  and
    mst_equipment_class.is_disp = ''1''
  and
    mst_equipment_class.is_del = ''0''
		
		), ord_tbl as (
  select
    facility_cd,
    to_date(treat_date, ''yyyymmdd'') as treat_date,
    to_date(treat_date, ''yyyymmdd'') as treat_date_start,
		
    info->>''class_cd'' as class_cd,
    info->>''class_type'' as class_type,
    info->>''equip_type'' as equip_type,
    info->>''cd'' as cd,
    info->>''amount'' as amount,
		
    info->>''ind_user_id'' as ind_user_id,
    info->>''ind_user_last_name''as ind_user_last_name,
    info->>''ind_user_first_name'' as ind_user_first_name,
    info->>''upd_user_id'' as upd_user_id,
    info->>''upd_user_last_name'' as upd_user_last_name,
    info->>''upd_user_first_name'' as upd_user_first_name,
    info->>''input_class'' as input_class,
    info->>''is_editable'' as is_editable,
    info->>''needle_type'' as needle_type,
    info->>''cop_order_no'' as cop_order_no
  from
    ord_main
		cross join lateral
		json_array_elements (ord_main.ind_equip_info :: json) info
  where
    ord_no = @ordNo
    and is_del = ''0''
    and rst_dialysis_state=''0''  
		
		)
	
	
select
  ord.*,eqp.class_cd  as medi_class_cd,
case
    when equip_type = ''1''then dia.model_number
    else eqp.equipment_name
  end as equip_name,
case
    when equip_type = ''1'' then dia.in_hospital_cd_1
    else eqp.in_hospital_cd_1
  end as equip_in_hospital_cd_1,
  
case
    when equip_type = ''1'' then dia.in_hospital_cd_2
    else eqp.in_hospital_cd_2
  end as equip_in_hospital_cd_2,
  
  
case
    when equip_type = ''1'' then dia.in_hospital_cd_3
    else eqp.in_hospital_cd_3
  end as equip_in_hospital_cd_3,
  
case
    when equip_type = ''1'' then dia.in_hospital_cd_4
    else eqp.in_hospital_cd_4
  end as equip_in_hospital_cd_4,
case
    when equip_type = ''1'' then null
    else eqp.unit
  end as equip_unit,
  eqp_cls.class_name as equip_class_name,
  eqp_cls.class_type as equip_class_type
	
from
  ord_tbl as ord
	
  left join dialyzer_tbl as dia on ord.cd = dia.dialyzer_cd::text
  left join equipment_tbl as eqp on ord.cd = eqp.equipment_cd::text
  left join equipment_class_tbl eqp_cls on eqp.class_cd = eqp_cls.class_cd	', 2, '[{"preview": "2011/03/04", "can_calc": "0", "data_code": "treat_date", "data_name": "指示日", "data_type": "DateTime", "conv_table": [], "data_class": "医材", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト穿刺針", "can_calc": "0", "data_code": "equip_name", "data_name": "医療材料名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_name", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針", "can_calc": "0", "data_code": "equip_class_name", "data_name": "医療材料分類名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_class_name", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "医材", "field_name": "amount", "disp_format": "0", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "equip_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_unit", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "ind_user_id", "data_name": "指示者", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "ind_user_id", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "upd_user_id", "data_name": "更新者", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "upd_user_id", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "A針", "can_calc": "0", "data_code": "needle_type", "data_name": "穿刺針区分", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "needle_type", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "equip_in_hospital_cd_1", "data_name": "医療材料連携コード１", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_in_hospital_cd_1", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "equip_in_hospital_cd_2", "data_name": "医療材料連携コード２", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_in_hospital_cd_2", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "equip_in_hospital_cd_3", "data_name": "医療材料連携コード３", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_in_hospital_cd_3", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "equip_in_hospital_cd_4", "data_name": "医療材料連携コード４", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_in_hospital_cd_4", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/05", "can_calc": "0", "data_code": "treat_date_start", "data_name": "指示開始日", "data_type": "DateTime", "conv_table": [], "data_class": "医材", "field_name": "treat_date_start", "disp_format": "yyyy/mm/dd", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/05", "can_calc": "0", "data_code": "treat_date_end", "data_name": "指示終了日", "data_type": "DateTime", "conv_table": [], "data_class": "医材", "field_name": "treat_date_end", "disp_format": "yyyy/mm/dd", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '指示：医材　@ordNo使用', '2020-03-27 12:59:00', current_timestamp, NULL);

DELETE from sys_data_set where sql_cd = 97;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (97, 'with ord_key_tbl as (
  select
    facility_cd
  from
    ord_main
  where
    ord_no = @ordNo and is_del = ''0'' and rst_dialysis_state <> ''0''


), dialyzer_tbl as (
  select
    *
  from
    mst_dialyzer
  where
    mst_dialyzer.facility_cd = (select facility_cd from ord_key_tbl)
  and
    mst_dialyzer.is_disp = ''1''
  and
    mst_dialyzer.is_del = ''0''

), equipment_tbl as (
  select
    *
  from
    mst_equipment
  where
    mst_equipment.facility_cd = (select facility_cd from ord_key_tbl)
  and
    mst_equipment.is_disp = ''1''
  and
    mst_equipment.is_del = ''0''

), equipment_class_tbl as (
  select
    *
  from
    mst_equipment_class
  where
    mst_equipment_class.facility_cd = (select facility_cd from ord_key_tbl)
  and
    mst_equipment_class.is_disp = ''1''
  and
    mst_equipment_class.is_del = ''0''

), ord_tbl as (
  select
    facility_cd,
    to_date(treat_date, ''yyyymmdd'') as treat_date,

    info->>''class_cd'' as class_cd,
    info->>''class_type'' as class_type,
    info->>''equip_type'' as equip_type,
    info->>''cd'' as cd,
    info->>''amount'' as amount,

    info->>''ind_user_id'' as ind_user_id,
    info->>''ind_user_last_name'' as ind_user_last_name,
    info->>''ind_user_first_name'' as ind_user_first_name,
    info->>''upd_user_id'' as upd_user_id,
    info->>''upd_user_last_name'' as upd_user_last_name,
    info->>''upd_user_first_name'' as upd_user_first_name,
    info->>''input_class'' as input_class,
    info->>''is_editable'' as is_editable,
    info->>''cop_order_no'' as cop_order_no

    -- 実績
    ,info->>''needle_type'' as needle_type
  from
    ord_main
      cross join lateral
        json_array_elements (ord_main.rst_equip_info :: json) info
  where
    ord_no = @ordNo and is_del = ''0'' and rst_dialysis_state <> ''0''

)


select
  ord.*,
  case
    when equip_type = ''1'' then dia.model_number
    else eqp.equipment_name
  end as equip_name,
  
  case
    when equip_type = ''1'' then dia.in_hospital_cd_1
    else eqp.in_hospital_cd_1
  end as rst_equip_in_hospital_cd_1,
  
  case
    when equip_type = ''1'' then dia.in_hospital_cd_2
    else eqp.in_hospital_cd_2
  end as rst_equip_in_hospital_cd_2,
  
  
  case
    when equip_type = ''1'' then dia.in_hospital_cd_3
    else eqp.in_hospital_cd_3
  end as rst_equip_in_hospital_cd_3,
  
  case
    when equip_type = ''1'' then dia.in_hospital_cd_4
    else eqp.in_hospital_cd_4
  end as rst_equip_in_hospital_cd_4,
  
  
  case
    when equip_type = ''1'' then null
    else eqp.unit
  end as equip_unit,
  eqp_cls.class_name as equip_class_name,
  eqp_cls.class_type as equip_class_type

from
  ord_tbl as ord

  left join dialyzer_tbl as dia on ord.cd = dia.dialyzer_cd::text
  left join equipment_tbl as eqp on ord.cd = eqp.equipment_cd::text
  left join equipment_class_tbl eqp_cls on eqp.class_cd = eqp_cls.class_cd
  
order by class_cd, cd
;', 2, '[{"preview": "テスト穿刺針", "can_calc": "0", "data_code": "equip_name", "data_name": "医療材料名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_name", "disp_format": "", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針", "can_calc": "0", "data_code": "equip_class_name", "data_name": "医療材料分類名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_class_name", "disp_format": "", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "医材", "field_name": "amount", "disp_format": "0", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "equip_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_unit", "disp_format": "", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "A針", "can_calc": "0", "data_code": "needle_type", "data_name": "穿刺針区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "未使用", "item": "未使用"}, {"code": "1", "disp": "A針", "item": "A針"}, {"code": "2", "disp": "V針", "item": "V針"}, {"code": "3", "disp": "SN", "item": "SN"}], "data_class": "医材", "field_name": "needle_type", "disp_format": "", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_1", "data_name": "医療材料連携コード１", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_1", "disp_format": "", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_2", "data_name": "医療材料連携コード２", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_2", "disp_format": "", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_3", "data_name": "医療材料連携コード３", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_3", "disp_format": "", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_4", "data_name": "医療材料連携コード４", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_4", "disp_format": "", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：医材 @ordNo 使用', '2020-03-31 23:59:59', current_timestamp, NULL);


DELETE from sys_data_set where sql_cd = 149;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (149, 'with 
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
    and sv.pat_id in (@patIds)', 2, '[{"preview": "テスト穿刺針", "can_calc": "0", "data_code": "supplies_name", "data_name": "医療材料名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "supplies_name", "disp_format": "", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/15", "can_calc": "0", "data_code": "supplies_base_date", "data_name": "データ基準日", "data_type": "DateTime", "conv_table": [], "data_class": "医材", "field_name": "supplies_base_date", "disp_format": "yyyy/mm/dd", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "ind_rst_value", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "医材", "field_name": "ind_rst_value", "disp_format": "0", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "total_unitH", "data_name": "各日医材合計", "data_type": "decimal", "conv_table": [], "data_class": "医材", "field_name": "total_unitH", "disp_format": "0", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "total_unitV", "data_name": "医材計", "data_type": "decimal", "conv_table": [], "data_class": "医材", "field_name": "total_unitV", "disp_format": "0", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [11]}', '薬剤週間薬剤集計表　@patId @facilityCd  @fromdate  @todate', '2021-04-25 16:40:02', current_timestamp, '[]');


DELETE from sys_data_set where sql_cd = 167;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (167, 'with ord_key_tbl as (
  select
    facility_cd
  from
    ord_main
  where
    ord_no = @ordNo and is_del = ''0'' and rst_dialysis_state > ''0'' and rst_dialysis_state < ''6''


), dialyzer_tbl as (
  select
    *
  from
    mst_dialyzer
  where
    mst_dialyzer.facility_cd = (select facility_cd from ord_key_tbl)
  and
    mst_dialyzer.is_disp = ''1''
  and
    mst_dialyzer.is_del = ''0''

), equipment_tbl as (
  select
    *
  from
    mst_equipment
  where
    mst_equipment.facility_cd = (select facility_cd from ord_key_tbl)
  and
    mst_equipment.is_disp = ''1''
  and
    mst_equipment.is_del = ''0''

), equipment_class_tbl as (
  select
    *
  from
    mst_equipment_class
  where
    mst_equipment_class.facility_cd = (select facility_cd from ord_key_tbl)
  and
    mst_equipment_class.is_disp = ''1''
  and
    mst_equipment_class.is_del = ''0''

), ord_tbl as (
  select
    facility_cd,
    to_date(treat_date, ''yyyymmdd'') as treat_date,

    info->>''class_cd'' as class_cd,
    info->>''class_type'' as class_type,
    info->>''equip_type'' as equip_type,
    info->>''cd'' as cd,
    info->>''amount'' as amount,

    info->>''ind_user_id'' as ind_user_id,
    info->>''ind_user_last_name'' as ind_user_last_name,
    info->>''ind_user_first_name'' as ind_user_first_name,
    info->>''upd_user_id'' as upd_user_id,
    info->>''upd_user_last_name'' as upd_user_last_name,
    info->>''upd_user_first_name'' as upd_user_first_name,
    info->>''input_class'' as input_class,
    info->>''is_editable'' as is_editable,
    info->>''cop_order_no'' as cop_order_no

    -- 実績
    ,info->>''needle_type'' as needle_type
  from
    ord_main
      cross join lateral
        json_array_elements (ord_main.rst_equip_info :: json) info
  where
    ord_no = @ordNo and is_del = ''0'' and rst_dialysis_state > ''0'' and rst_dialysis_state < ''6''

), ord_tbl_cond as (
  select
    facility_cd,
    to_date(treat_date, ''yyyymmdd'') as treat_date,

    info->>'''' as class_cd,
    info->>'''' as class_type,
    info->>'''' as equip_type,
    info->>''value'' as cd,
    info->>'''' as amount,

    info->>''ind_user_id'' as ind_user_id,
    info->>''ind_user_last_name'' as ind_user_last_name,
    info->>''ind_user_first_name'' as ind_user_first_name,
    info->>''upd_user_id'' as upd_user_id,
    info->>''upd_user_last_name'' as upd_user_last_name,
    info->>''upd_user_first_name'' as upd_user_first_name,
    info->>''input_class'' as input_class,
    info->>''is_editable'' as is_editable,
    info->>''cop_order_no'' as cop_order_no

    -- 実績
    ,info->>'''' as needle_type
  from
    ord_main
      cross join lateral
        json_array_elements (ord_main.rst_cond_info :: json) info
  where
    ord_no = @ordNo and is_del = ''0'' and rst_dialysis_state > ''0'' and rst_dialysis_state < ''6''

)


(select
  ord.*,
  case
    when equip_type = ''1'' then dia.model_number
    else eqp.equipment_name
  end as equip_name,
  
  case
    when equip_type = ''1'' then dia.in_hospital_cd_1
    else eqp.in_hospital_cd_1
  end as rst_equip_in_hospital_cd_1,
  
  case
    when equip_type = ''1'' then dia.in_hospital_cd_2
    else eqp.in_hospital_cd_2
  end as rst_equip_in_hospital_cd_2,
  
  
  case
    when equip_type = ''1'' then dia.in_hospital_cd_3
    else eqp.in_hospital_cd_3
  end as rst_equip_in_hospital_cd_3,
  
  case
    when equip_type = ''1'' then dia.in_hospital_cd_4
    else eqp.in_hospital_cd_4
  end as rst_equip_in_hospital_cd_4,
  
  
  case
    when equip_type = ''1'' then null
    else eqp.unit
  end as equip_unit,
  eqp_cls.class_name as equip_class_name,
  eqp_cls.class_type as equip_class_type

from
  ord_tbl as ord

  left join dialyzer_tbl as dia on ord.cd = dia.dialyzer_cd::text
  left join equipment_tbl as eqp on ord.cd = eqp.equipment_cd::text
  left join equipment_class_tbl eqp_cls on eqp.class_cd = eqp_cls.class_cd
  
order by class_cd, cd)
union all
(select
  ord.*,
  case
    when equip_type = ''1'' then dia.model_number
    else eqp.equipment_name
  end as equip_name,
  
  case
    when equip_type = ''1'' then dia.in_hospital_cd_1
    else eqp.in_hospital_cd_1
  end as rst_equip_in_hospital_cd_1,
  
  case
    when equip_type = ''1'' then dia.in_hospital_cd_2
    else eqp.in_hospital_cd_2
  end as rst_equip_in_hospital_cd_2,
  
  
  case
    when equip_type = ''1'' then dia.in_hospital_cd_3
    else eqp.in_hospital_cd_3
  end as rst_equip_in_hospital_cd_3,
  
  case
    when equip_type = ''1'' then dia.in_hospital_cd_4
    else eqp.in_hospital_cd_4
  end as rst_equip_in_hospital_cd_4,
  
  
  case
    when equip_type = ''1'' then null
    else eqp.unit
  end as equip_unit,
  eqp_cls.class_name as equip_class_name,
  eqp_cls.class_type as equip_class_type

from
  ord_tbl_cond as ord

  left join dialyzer_tbl as dia on ord.cd = dia.dialyzer_cd::text
  left join equipment_tbl as eqp on ord.cd = eqp.equipment_cd::text
  left join equipment_class_tbl eqp_cls on eqp.class_cd = eqp_cls.class_cd
  
order by class_cd, cd)
;', 2, '[{"preview": "テスト穿刺針", "can_calc": "0", "data_code": "equip_name", "data_name": "医療材料名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_name", "disp_format": "", "filter_type": "Equip", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針", "can_calc": "0", "data_code": "equip_class_name", "data_name": "医療材料分類名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_class_name", "disp_format": "", "filter_type": "Equip", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "医材", "field_name": "amount", "disp_format": "0", "filter_type": "Equip", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "equip_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_unit", "disp_format": "", "filter_type": "Equip", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "A針", "can_calc": "0", "data_code": "needle_type", "data_name": "穿刺針区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "未使用", "item": "未使用"}, {"code": "1", "disp": "A針", "item": "A針"}, {"code": "2", "disp": "V針", "item": "V針"}, {"code": "3", "disp": "SN", "item": "SN"}], "data_class": "医材", "field_name": "needle_type", "disp_format": "", "filter_type": "Equip", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_1", "data_name": "医療材料連携コード１", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_1", "disp_format": "", "filter_type": "Equip", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_2", "data_name": "医療材料連携コード２", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_2", "disp_format": "", "filter_type": "Equip", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_3", "data_name": "医療材料連携コード３", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_3", "disp_format": "", "filter_type": "Equip", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_4", "data_name": "医療材料連携コード４", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_4", "disp_format": "", "filter_type": "Equip", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績（治療中）：医材 @ordNo 使用', '2021-08-05 13:30:00', current_timestamp, NULL);
