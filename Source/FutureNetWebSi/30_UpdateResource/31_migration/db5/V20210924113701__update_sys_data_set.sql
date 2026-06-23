UPDATE "ntss"."sys_data_set" 
SET "sql" = 'with ord_key_tbl as (
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
  left join equipment_class_tbl eqp_cls on eqp.class_cd = eqp_cls.class_cd	'

	
	WHERE
"sql_cd" = 74;