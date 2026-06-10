DELETE  FROM "ntss"."sys_data_set" WHERE sql_cd IN (45);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (
45
,'with ord_tbl as (
  select
    facility_cd,
    pat_id,
    ind_bed_cd,
    to_timestamp(treat_date, ''yyyymmdd'') + ''1 days - 1 milliseconds'' as treat_date_end
  from
    ord_main
  where
    ord_no = @ordNo
    and is_del = ''0''
    and rst_dialysis_state = ''0''
), next_date as (
  select 
     pat_id,
     treat_date 
  from 
     ord_main 
  where 
     pat_id =(select pat_id from ord_main where ord_no=@ordNo and is_del = ''0'' and rst_dialysis_state = ''0'')
  and 
     treat_date > (select treat_date from ord_main where ord_no=@ordNo and is_del = ''0'' and rst_dialysis_state = ''0'') and is_del = ''0'' and rst_dialysis_state = ''0'' ORDER BY treat_date ASC limit 1    
 
), kur_tbl as (
  select
    *
  from
    mst_kur
  where
    mst_kur.facility_cd = (select facility_cd from ord_tbl)
  and
    mst_kur.is_del = ''0''
), va_tbl as (
  select
    *
  from
    mst_va
  where
    mst_va.facility_cd = (select facility_cd from ord_tbl)
  and
    mst_va.is_disp = ''1''
  and
    mst_va.is_del = ''0''
), treatment_tbl as (
  select
    *
  from
    mst_treatment
  where
    mst_treatment.facility_cd = (select facility_cd from ord_tbl)
  and
    mst_treatment.is_disp = ''1''
  and
    mst_treatment.is_del = ''0''
), bed_tbl as (
  select
    *
  from
    mst_bed
  where
    mst_bed.facility_cd = (select facility_cd from ord_tbl)
  and
    mst_bed.is_disp = ''1''
  and
    mst_bed.is_del = ''0''
), machine_tbl as (
  select
    *
  from
    mst_machine
  where
    mst_machine.facility_cd = (select facility_cd from ord_tbl)
  and
    mst_machine.is_disp = ''1''
  and
    mst_machine.is_del = ''0''
), room_bed_group_tbl as (
  select
    facility_cd,
    array_to_string(array_agg(room_bed_group_name), '','') as room_bed_group_name_list
  from
    mst_room_bed_group
  where
    mst_room_bed_group.facility_cd = (select facility_cd from ord_tbl)
  and
    mst_room_bed_group.is_disp = ''1''
  and
    mst_room_bed_group.is_del = ''0''
  and
    mst_room_bed_group.bed_list @> (''['' || (select ind_bed_cd from ord_tbl) || '']'')::jsonb
  group by
    facility_cd
), dialyzer_tbl as (
  select
    *
  from
    mst_dialyzer
  where
    mst_dialyzer.facility_cd = (select facility_cd from ord_tbl)
  and
    mst_dialyzer.is_disp = ''1''
  and
    mst_dialyzer.is_del = ''0'' and mst_dialyzer.dialyzer_cd IN (@diaIds)
), medicine_tbl as (
  select
    *
  from
    mst_medicine
  where
    mst_medicine.facility_cd = (select facility_cd from ord_tbl)
  and
    mst_medicine.is_disp = ''1''
  and
    mst_medicine.is_del = ''0'' and mst_medicine.class_cd IN ( @medIds )
), medicine_mix_tbl as (
  select
    *
  from
    mst_medicine_mix
  where
    mst_medicine_mix.facility_cd = (select facility_cd from ord_tbl)
  and
    mst_medicine_mix.is_disp = ''1''
  and
    mst_medicine_mix.is_del = ''0'' and mst_medicine_mix.class_cd IN ( @medIds )
), equipment_tbl as (
  select
    *
  from
    mst_equipment
  where
    mst_equipment.facility_cd = (select facility_cd from ord_tbl)
  and
    mst_equipment.is_disp = ''1''
  and
    mst_equipment.is_del = ''0'' and mst_equipment.class_cd IN (@eqIds)
-- 指定患者、基準日以前のDWがある身体情報を取得
), pat_physical_tbl as (
  select
    work_tbl.*
  from
    (
    select
      pat_id,
      info->>''exam_date'' as exam_date,
      info->>''dw'' as dw,
      info->>''pre_scale_upper'' as pre_scale_upper,
      info->>''pre_scale_lower'' as pre_scale_lower
    from
      pat_unique
      cross join lateral
        json_array_elements (pat_unique.physical_info :: json) info
    where
      pat_unique.pat_id = (select pat_id from ord_tbl)
    ) work_tbl
  where
    exam_date::timestamp <= (select treat_date_end from ord_tbl)
  and
    dw is not null
  order by
    exam_date desc
  limit 1
-- 指定患者の車いす情報を取得
), pat_wheel_chair_tbl as (
  select
    pat_id,
    wheel_chair_name,
    wheel_chair_weight
  from
    mst_wheel_chair,
    (
      select
        mss.facility_cd, ms.*, row_number() over() as index
      from
        mst_selector mss
      cross join lateral jsonb_to_recordset(mss.order_settings->''items'') as ms
      (
        code bigint,
        name text
      )
      where
        facility_cd = (select facility_cd from ord_tbl)
      and
        master_physical_name = ''mst_wheel_chair''
  ) ms
  where
    mst_wheel_chair.wheel_chair_cd = ms.code
  and
    pat_id = (select pat_id from ord_tbl)
  and
    is_disp = ''1''
  and
    is_del = ''0''
  and
    is_personal = ''1''
  limit 1
),oms_puncture_needle_a_tbl as (
	SELECT
		* 
	FROM
		ord_material_save oms 
	WHERE
		oms.supplies_base_no = @ordNo 
		AND supplies_source_class = ''0'' 
		AND supplies_class = ''06''
		AND ind_rst_class=''1''

),oms_puncture_needle_v_tbl as (
	SELECT
		* 
	FROM
		ord_material_save oms 
	WHERE
		oms.supplies_base_no = @ordNo 
		AND supplies_source_class = ''0'' 
		AND supplies_class = ''07''
		AND ind_rst_class=''1''

),oms_puncture_needle_sn_tbl as (
	SELECT
		* 
	FROM
		ord_material_save oms 
	WHERE
		oms.supplies_base_no = @ordNo 
		AND supplies_source_class = ''0'' 
		AND supplies_class = ''05''
		AND ind_rst_class=''1''

),oms_blood_circuit_tbl as (
	SELECT
		* 
	FROM
		ord_material_save oms 
	WHERE
		oms.supplies_base_no = @ordNo 
		AND supplies_source_class = ''0'' 
		AND supplies_class = ''00''
		AND ind_rst_class=''1''

)
select
  to_date(ord.treat_date, ''yyyymmdd'') as treat_date,
  ord.ind_kur_cd as kur_cd,
  ord.ind_va_cd as va_cd,
  ord.ind_treatment_cd as treatment_cd,
	treatment_tbl.treatment_name AS treatment_name1,
  to_char(to_date(ord.ind_treat_start_time, ''HH24MI''), ''HH24:MI'') as treat_start_time,
  ord.ind_bed_cd as bed_cd,

  ord.ind_cond_info->''1''->>''value'' as treatment_time,
  --ord.ind_cond_info->''2''->>''value_name_1'' as va,
  ord.ind_cond_info->''4''->>''value'' as water_removal_amount_limit,
  ord.ind_cond_info->''12''->>''value'' as single_needle,
  ord.ind_cond_info->''14''->>''value'' as blood_flow,
  ord.ind_cond_info->''15''->>''unit'' as dialysate_flow_unit,
  ord.ind_cond_info->''16''->>''value'' as dialysate_flow_rate,
  ord.ind_cond_info->''17''->>''value'' as dialysate_amount,
  ord.ind_cond_info->''18''->>''value'' as dialysate_temperature,
  ord.ind_cond_info->''20''->>''value'' as fluid_replacement_amount,
  ord.ind_cond_info->''21''->>''value'' as fluid_replacement_timing,
  ord.ind_cond_info->''22''->>''value'' as fluid_replacement_use_count,
  ord.ind_cond_info->''23''->>''value'' as fluid_replacement_temperature,
  ord.ind_cond_info->''24''->>''value'' as fluid_replacement_speed,
  ord.ind_cond_info->''26''->>''value'' as anti_coagulant_one_shot_amount,
  ord.ind_cond_info->''27''->>''value'' as anti_coagulant_sustained_speed,
  ord.ind_cond_info->''27''->>''unit'' as anti_coagulant_sustained_speed_unit,
  ord.ind_cond_info->''28''->>''value'' as anti_coagulant_sustained_amount,
  ord.ind_cond_info->''29''->>''value'' as ip,
  ord.ind_cond_info->''30''->>''value'' as ip_start,
  ord.ind_cond_info->''31''->>''value'' as ip_one_shot_amount,
  ord.ind_cond_info->''32''->>''value'' as ip_speed,
  ord.ind_cond_info->''33''->>''value'' as ip_speed_max,
  ord.ind_cond_info->''34''->>''value'' as auto_one_shot,
  ord.ind_cond_info->''35''->>''value'' as ip_auto_off,
  ord.ind_cond_info->''36''->>''value'' as ip_auto_off_time,
  ord.ind_cond_info->''37''->>''value'' as ip_monitor_auto_off,
  ord.ind_cond_info->''38''->>''value'' as ip_monitor_auto_off_time,

  to_number(ord.ind_cond_info->''26''->>''value'', ''999999.999'')
    + to_number(ord.ind_cond_info->''28''->>''value'', ''999999.999'')
    as anti_coagulant_total_amount,

  case
    when ord.ind_cond_info->''31''->>''value'' is not null then ''ml/h''
    else null
  end as ip_one_shot_amount_unit,
  case
    when ord.ind_cond_info->''32''->>''value'' is not null then ''ml/h''
    else null
  end as ip_speed_unit,
  case
    when ord.ind_cond_info->''33''->>''value'' is not null then ''ml''
    else null
  end as ip_speed_max_unit,

  ord.ind_tare_info->>''name_1'' as tare_name1,
  ord.ind_tare_info->>''name_2'' as tare_name2,
  ord.ind_tare_info->>''name_3'' as tare_name3,
  ord.ind_tare_info->>''name_4'' as tare_name4,
  ord.ind_tare_info->>''name_5'' as tare_name5,
  ord.ind_tare_info->>''weight_1'' as tare_weight1,
  ord.ind_tare_info->>''weight_2'' as tare_weight2,
  ord.ind_tare_info->>''weight_3'' as tare_weight3,
  ord.ind_tare_info->>''weight_4'' as tare_weight4,
  ord.ind_tare_info->>''weight_5'' as tare_weight5,
  to_number(ord.ind_tare_info->>''weight_1'', ''999999'')
    + to_number(ord.ind_tare_info->>''weight_2'', ''999999'')
    + to_number(ord.ind_tare_info->>''weight_3'', ''999999'')
    + to_number(ord.ind_tare_info->>''weight_4'', ''999999'')
    + to_number(ord.ind_tare_info->>''weight_5'', ''999999'')
    as tare_weight_total,

  ord.ind_off_water_info->>''name_1'' as off_water_name1,
  ord.ind_off_water_info->>''name_2'' as off_water_name2,
  ord.ind_off_water_info->>''name_3'' as off_water_name3,
  ord.ind_off_water_info->>''name_4'' as off_water_name4,
  ord.ind_off_water_info->>''name_5'' as off_water_name5,
  ord.ind_off_water_info->>''weight_1'' as off_water_weight1,
  ord.ind_off_water_info->>''weight_2'' as off_water_weight2,
  ord.ind_off_water_info->>''weight_3'' as off_water_weight3,
  ord.ind_off_water_info->>''weight_4'' as off_water_weight4,
  ord.ind_off_water_info->>''weight_5'' as off_water_weight5,
  to_number(ord.ind_off_water_info->>''weight_1'', ''999999'')
    + to_number(ord.ind_off_water_info->>''weight_2'', ''999999'')
    + to_number(ord.ind_off_water_info->>''weight_3'', ''999999'')
    + to_number(ord.ind_off_water_info->>''weight_4'', ''999999'')
    + to_number(ord.ind_off_water_info->>''weight_5'', ''999999'')
    as off_water_weight_total,

  case
    when ord.ind_cond_info->''3''->>''value'' = ''-1'' then ''1''
    else ''0''
  end as target_weight_mode,
  case
    when ord.ind_cond_info->''3''->>''value'' = ''-1'' then pat_physical_tbl.dw
    else ord.ind_cond_info->''3''->>''value''
  end as target_weight,
  pat_physical_tbl.dw,
  pat_physical_tbl.pre_scale_upper,
  pat_physical_tbl.pre_scale_lower,

  pat_wheel_chair_tbl.wheel_chair_name,
  pat_wheel_chair_tbl.wheel_chair_weight,

  kur_tbl.kur_name as kur_name,
  va_tbl.va_name as va_name,
  va_tbl.in_hospital_cd_1 as va_in_hospital_cd_1,
  va_tbl.in_hospital_cd_2  as va_in_hospital_cd_2,  
  
  va_tbl.va_direct as va_direct,
  treatment_tbl.treatment_name,
  treatment_tbl.device_mode,
	treatment_tbl.in_hospital_cd_a1 as treatment_in_hospital_cd_a1,
	treatment_tbl.in_hospital_cd_a2 as treatment_in_hospital_cd_a2,
	treatment_tbl.in_hospital_cd_a3 as treatment_in_hospital_cd_a3,
	treatment_tbl.in_hospital_cd_a4 as treatment_in_hospital_cd_a4,
	treatment_tbl.in_hospital_cd_b1 as treatment_in_hospital_cd_b1,
	treatment_tbl.in_hospital_cd_b2 as treatment_in_hospital_cd_b2,
	treatment_tbl.in_hospital_cd_b3 as treatment_in_hospital_cd_b3,
	treatment_tbl.in_hospital_cd_b4 as treatment_in_hospital_cd_b4,
  bed_tbl.*,
	bed_tbl.in_hospital_cd_1 as bed_in_hospital_cd_1,
	bed_tbl.in_hospital_cd_2 as bed_in_hospital_cd_2,
  machine_tbl.*,
  room_bed_group_tbl.room_bed_group_name_list,

  dialyzer_tbl.model_number as dialyzer_name,
  dialyzer_tbl.in_hospital_cd_1 as dialyzer_in_hospital_cd_1,
  dialyzer_tbl.in_hospital_cd_2 as dialyzer_in_hospital_cd_2,
  dialyzer_tbl.in_hospital_cd_3 as dialyzer_in_hospital_cd_3,
  dialyzer_tbl.in_hospital_cd_4 as dialyzer_in_hospital_cd_4,
  dialyzer_tbl.*,

  adsorption_column_tbl.equipment_name as adsorption_column_name,
  adsorption_column_tbl.in_hospital_cd_1 as adsorption_in_hospital_cd_1,
  adsorption_column_tbl.in_hospital_cd_2 as adsorption_in_hospital_cd_2,
  adsorption_column_tbl.in_hospital_cd_3 as adsorption_in_hospital_cd_3,
  adsorption_column_tbl.in_hospital_cd_4 as adsorption_in_hospital_cd_4,   
  
  primary_film_tbl.equipment_name as primary_film_name,

  primary_film_tbl.in_hospital_cd_1 as primary_film_in_hospital_cd_1,
  primary_film_tbl.in_hospital_cd_2 as primary_film_in_hospital_cd_2,
  primary_film_tbl.in_hospital_cd_3 as primary_film_in_hospital_cd_3,
  primary_film_tbl.in_hospital_cd_4 as primary_film_in_hospital_cd_4,  
  
  secondary_film_tbl.equipment_name as secondary_film_name,
  secondary_film_tbl.in_hospital_cd_1 as secondary_film_in_hospital_cd_1,
  secondary_film_tbl.in_hospital_cd_2 as secondary_film_in_hospital_cd_2,
  secondary_film_tbl.in_hospital_cd_3 as secondary_film_in_hospital_cd_3,
  secondary_film_tbl.in_hospital_cd_4 as secondary_film_in_hospital_cd_4,  

  puncture_needle_a_tbl.equipment_name as puncture_needle_a_name,
  puncture_needle_a_tbl.in_hospital_cd_1 as pn_a_in_hospital_cd_1,
  puncture_needle_a_tbl.in_hospital_cd_1 as pn_a_in_hospital_cd_2,
  puncture_needle_a_tbl.in_hospital_cd_1 as pn_a_in_hospital_cd_3,  
  puncture_needle_a_tbl.in_hospital_cd_1 as pn_a_in_hospital_cd_4,
  
  puncture_needle_v_tbl.equipment_name as puncture_needle_v_name,
  puncture_needle_v_tbl.in_hospital_cd_1 as pn_v_in_hospital_cd_1,
  puncture_needle_v_tbl.in_hospital_cd_1 as pn_v_in_hospital_cd_2,
  puncture_needle_v_tbl.in_hospital_cd_1 as pn_v_in_hospital_cd_3,  
  puncture_needle_v_tbl.in_hospital_cd_1 as pn_v_in_hospital_cd_4, 
  
  puncture_needle_sn_tbl.equipment_name as puncture_needle_sn_name,
  puncture_needle_sn_tbl.in_hospital_cd_1 as pn_s_in_hospital_cd_1,
  puncture_needle_sn_tbl.in_hospital_cd_1 as pn_s_in_hospital_cd_2,
  puncture_needle_sn_tbl.in_hospital_cd_1 as pn_s_in_hospital_cd_3,  
  puncture_needle_sn_tbl.in_hospital_cd_1 as pn_s_in_hospital_cd_4, 
  
  blood_circuit_tbl.equipment_name as blood_circuit_name,
  blood_circuit_tbl.in_hospital_cd_1 as bc_in_hospital_cd_1,
  blood_circuit_tbl.in_hospital_cd_1 as bc_in_hospital_cd_2,
  blood_circuit_tbl.in_hospital_cd_1 as bc_in_hospital_cd_3,  
  blood_circuit_tbl.in_hospital_cd_1 as bc_in_hospital_cd_4, 
  

  case
    when ord.ind_cond_info->''15''->>''medicine_type'' = ''2'' then mix_dialysate_tbl.medicine_mix_name
    else med_dialysate_tbl.medicine_name
  end as dialysate_name,
  
  case
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then mix_dialysate_tbl.in_hospital_cd_1
    else med_dialysate_tbl.in_hospital_cd_1
  end as rst_dialysate_in_hospital_cd_1,
  
  case
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then mix_dialysate_tbl.in_hospital_cd_2
    else med_dialysate_tbl.in_hospital_cd_2
  end as rst_dialysate_in_hospital_cd_2,
  
  case
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then mix_dialysate_tbl.in_hospital_cd_3
    else med_dialysate_tbl.in_hospital_cd_3
  end as rst_dialysate_in_hospital_cd_3,
  
  case
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then ''''
    else med_dialysate_tbl.in_hospital_cd_4
  end as rst_dialysate_in_hospital_cd_4,  
  
  case
    when ord.ind_cond_info->''19''->>''medicine_type'' = ''2'' then mix_fluid_replacement_tbl.medicine_mix_name
    else med_fluid_replacement_tbl.medicine_name
  end as fluid_replacement_name,
  
  case
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then mix_fluid_replacement_tbl.in_hospital_cd_1
    else med_fluid_replacement_tbl.in_hospital_cd_1
  end as rst_fluid_in_hospital_cd_1,
  
  case
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then mix_fluid_replacement_tbl.in_hospital_cd_2
    else med_fluid_replacement_tbl.in_hospital_cd_2
  end as rst_fluid_in_hospital_cd_2,
  
  case
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then mix_fluid_replacement_tbl.in_hospital_cd_3
    else med_fluid_replacement_tbl.in_hospital_cd_3
  end as rst_fluid_in_hospital_cd_3,
  
  case
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then ''''
    else med_fluid_replacement_tbl.in_hospital_cd_4
  end as rst_fluid_in_hospital_cd_4,
  
  case
    when ord.ind_cond_info->''25''->>''medicine_type'' = ''2'' then mix_anti_coagulant_tbl.medicine_mix_name
    else med_anti_coagulant_tbl.medicine_name
  end as anti_coagulant_name,
  
  case
    when ord.rst_cond_info->''25''->>''medicine_type'' = ''2'' then mix_anti_coagulant_tbl.in_hospital_cd_1
    else med_anti_coagulant_tbl.in_hospital_cd_1
  end as rst_anti_in_hospital_cd_1,
  
  case
    when ord.rst_cond_info->''25''->>''medicine_type'' = ''2'' then mix_anti_coagulant_tbl.in_hospital_cd_2
    else med_anti_coagulant_tbl.in_hospital_cd_2
  end as rst_anti_in_hospital_cd_2,
  
  case
    when ord.rst_cond_info->''25''->>''medicine_type'' = ''2'' then mix_anti_coagulant_tbl.in_hospital_cd_3
    else med_anti_coagulant_tbl.in_hospital_cd_3
  end as rst_anti_in_hospital_cd_3,
  
  case
    when ord.rst_cond_info->''25''->>''medicine_type'' = ''2'' then ''''
    else med_anti_coagulant_tbl.in_hospital_cd_4
  end as rst_anti_in_hospital_cd_4,  

  case
    when ord.ind_cond_info->''15''->>''medicine_type'' = ''2'' then mix_dialysate_tbl.unit
    else med_dialysate_tbl.unit
  end as dialysate_amount_unit,
  case
    when ord.ind_cond_info->''19''->>''medicine_type'' = ''2'' then mix_fluid_replacement_tbl.unit
    else med_fluid_replacement_tbl.unit
  end as fluid_replacement_unit,
  case
    when ord.ind_cond_info->''25''->>''medicine_type'' = ''2'' then mix_anti_coagulant_tbl.unit
    else med_anti_coagulant_tbl.unit
  end as anti_coagulant_unit,
  case
    when ord.ind_cond_info->''25''->>''medicine_type'' = ''2'' then mix_anti_coagulant_tbl.unit
    else med_anti_coagulant_tbl.unit
  end as anti_coagulant_speed_unit,
  nt.treat_date as next_treat_date
  ,ord.ord_no
from
  ord_main as ord

  left join pat_physical_tbl on ord.pat_id = pat_physical_tbl.pat_id
  left join pat_wheel_chair_tbl on ord.pat_id = pat_wheel_chair_tbl.pat_id 

  left join kur_tbl on ord.ind_kur_cd = kur_tbl.kur_cd
  left join va_tbl on ord.ind_va_cd = va_tbl.va_cd
  left join treatment_tbl on ord.ind_treatment_cd = treatment_tbl.treatment_cd
  left join bed_tbl on ord.ind_bed_cd = bed_tbl.bed_cd
  left join machine_tbl on bed_tbl.machine_no = machine_tbl.machine_no
  left join room_bed_group_tbl on bed_tbl.facility_cd = room_bed_group_tbl.facility_cd

  left join dialyzer_tbl on ord.ind_cond_info->''5''->>''value'' = dialyzer_tbl.dialyzer_cd::text

  left join equipment_tbl as adsorption_column_tbl on ord.ind_cond_info->''6''->>''value'' = adsorption_column_tbl.equipment_cd::text
  left join equipment_tbl as primary_film_tbl on ord.ind_cond_info->''7''->>''value'' = primary_film_tbl.equipment_cd::text
  left join equipment_tbl as secondary_film_tbl on ord.ind_cond_info->''8''->>''value'' = secondary_film_tbl.equipment_cd::text
	
	left join oms_puncture_needle_a_tbl as opnat  on opnat.supplies_base_no=ord.ord_no
	left join oms_puncture_needle_v_tbl as opnvt on opnvt.supplies_base_no=ord.ord_no
	left join oms_puncture_needle_sn_tbl as opnsnt on opnsnt.supplies_base_no=ord.ord_no
	left join oms_blood_circuit_tbl as obct on obct.supplies_base_no=ord.ord_no
	
	left join equipment_tbl as puncture_needle_a_tbl on opnat.supplies_cd= puncture_needle_a_tbl.equipment_cd::text   
	left join equipment_tbl as puncture_needle_v_tbl on opnvt.supplies_cd = puncture_needle_v_tbl.equipment_cd::text
	left join equipment_tbl as puncture_needle_sn_tbl on opnsnt.supplies_cd = puncture_needle_sn_tbl.equipment_cd::text
  left join equipment_tbl as blood_circuit_tbl on obct.supplies_cd= blood_circuit_tbl.equipment_cd::text 
  -- left join equipment_tbl as puncture_needle_a_tbl on ord.ind_cond_info->''9''->>''value'' = puncture_needle_a_tbl.equipment_cd::text
  -- left join equipment_tbl as puncture_needle_v_tbl on ord.ind_cond_info->''10''->>''value'' = puncture_needle_v_tbl.equipment_cd::text
  -- left join equipment_tbl as puncture_needle_sn_tbl on ord.ind_cond_info->''11''->>''value'' = puncture_needle_sn_tbl.equipment_cd::text
  -- left join equipment_tbl as blood_circuit_tbl on ord.ind_cond_info->''13''->>''value'' = blood_circuit_tbl.equipment_cd::text

  left join medicine_tbl as med_dialysate_tbl on ord.ind_cond_info->''15''->>''value'' = med_dialysate_tbl.medicine_cd::text
  left join medicine_tbl as med_fluid_replacement_tbl on ord.ind_cond_info->''19''->>''value'' = med_fluid_replacement_tbl.medicine_cd::text
  left join medicine_tbl as med_anti_coagulant_tbl on ord.ind_cond_info->''25''->>''value'' = med_anti_coagulant_tbl.medicine_cd::text

  left join medicine_mix_tbl as mix_dialysate_tbl on ord.ind_cond_info->''15''->>''value'' = mix_dialysate_tbl.medicine_mix_cd::text
  left join medicine_mix_tbl as mix_fluid_replacement_tbl on ord.ind_cond_info->''19''->>''value'' = mix_fluid_replacement_tbl.medicine_mix_cd::text
  left join medicine_mix_tbl as mix_anti_coagulant_tbl on ord.ind_cond_info->''25''->>''value'' = mix_anti_coagulant_tbl.medicine_mix_cd::text
  left join next_date as nt on nt.pat_id = ord.pat_id
where
  ord.ord_no = @ordNo'
,2
,'[{"preview": "2011/05/20", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "透析予定", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:10", "can_calc": "0", "data_code": "treatment_time", "data_name": "透析時間", "data_type": "DateTime", "conv_table": [], "data_class": "透析予定", "field_name": "treatment_time", "disp_format": "hh:mm", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "午前", "can_calc": "0", "data_code": "kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "透析予定", "field_name": "kur_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:00", "can_calc": "0", "data_code": "treat_start_time", "data_name": "透析開始時間", "data_type": "DateTime", "conv_table": [], "data_class": "透析予定", "field_name": "treat_start_time", "disp_format": "hh:mm", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ベッド001", "can_calc": "0", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "透析予定", "field_name": "bed_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/22", "can_calc": "0", "data_code": "next_treat_date", "data_name": "次回透析予定日", "data_type": "DateTime", "conv_table": [], "data_class": "透析予定", "field_name": "next_treat_date", "disp_format": "yyyy/mm/dd", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左手前腕内シャント化静脈", "can_calc": "0", "data_code": "va_name", "data_name": "VA", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "va_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "va_in_hospital_cd_1", "data_name": "VA連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "va_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "va_in_hospital_cd_2", "data_name": "VA連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "va_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左", "can_calc": "0", "data_code": "va_direct", "data_name": "VA方向", "data_type": "strnig", "conv_table": [{"code": "0", "disp": "両方", "item": "両方"}, {"code": "1", "disp": "左", "item": "左"}, {"code": "2", "disp": "右", "item": "右"}, {"code": "3", "disp": "なし", "item": "なし"}, {"code": "-", "disp": "不明", "item": "不明"}], "data_class": "透析条件", "field_name": "va_direct", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DWと同じ", "can_calc": "0", "data_code": "target_weight_mode", "data_name": "目標体重指定設定", "data_type": "string", "conv_table": [{"code": "0", "disp": "DWと違う", "item": "DWと違う"}, {"code": "1", "disp": "DWと同じ", "item": "DWと同じ"}], "data_class": "透析条件", "field_name": "target_weight_mode", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "0", "data_code": "target_weight", "data_name": "目標体重", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "target_weight", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "00000000000000000002", "can_calc": "0", "data_code": "treatment_cd", "data_name": "治療方法コード", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_cd", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "00000000000000000003", "can_calc": "0", "data_code": "treatment_name1", "data_name": "治療方法名", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_name1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "HDF", "can_calc": "0", "data_code": "device_mode", "data_name": "装置モード", "data_type": "string", "conv_table": [{"code": "0", "disp": "HD", "item": "HD"}, {"code": "1", "disp": "ECUM", "item": "ECUM"}, {"code": "2", "disp": "HDF", "item": "HDF"}, {"code": "3", "disp": "HF", "item": "HF"}, {"code": "4", "disp": "HD＋補液", "item": "HD＋補液"}, {"code": "5", "disp": "ECUM＋補液", "item": "ECUM＋補液"}, {"code": "6", "disp": "AFBF", "item": "AFBF"}, {"code": "7", "disp": "OHDF", "item": "OHDF"}, {"code": "8", "disp": "OHF", "item": "OHF"}, {"code": "9", "disp": "特殊浄化", "item": "特殊浄化"}, {"code": "10", "disp": "I-HDF", "item": "I-HDF"}, {"code": "-", "disp": "不明", "item": "不明"}], "data_class": "透析条件", "field_name": "device_mode", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "0", "data_code": "water_removal_amount_limit", "data_name": "除水量制限", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "water_removal_amount_limit", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト１次膜", "can_calc": "0", "data_code": "primary_film_name", "data_name": "1次膜", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "primary_film_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "primary_film_in_hospital_cd_1", "data_name": "1次膜連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "primary_film_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "primary_film_in_hospital_cd_2", "data_name": "1次膜連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "primary_film_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "primary_film_in_hospital_cd_3", "data_name": "1次膜連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "primary_film_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "primary_film_in_hospital_cd_4", "data_name": "1次膜連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "primary_film_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト２次膜", "can_calc": "0", "data_code": "secondary_film_name", "data_name": "2次膜", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "secondary_film_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "secondary_film_in_hospital_cd_1", "data_name": "2次膜連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "secondary_film_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "secondary_film_in_hospital_cd_2", "data_name": "2次膜連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "secondary_film_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "secondary_film_in_hospital_cd_3", "data_name": "2次膜連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "secondary_film_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "secondary_film_in_hospital_cd_4", "data_name": "2次膜連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "secondary_film_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リクセルS-15", "can_calc": "0", "data_code": "adsorption_column_name", "data_name": "吸着カラム", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "adsorption_column_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "adsorption_in_hospital_cd_1", "data_name": "吸着カラム連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "adsorption_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "adsorption_in_hospital_cd_2", "data_name": "吸着カラム連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "adsorption_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "adsorption_in_hospital_cd_3", "data_name": "吸着カラム連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "adsorption_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "adsorption_in_hospital_cd_4", "data_name": "吸着カラム連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "adsorption_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "Dドライ3.0S", "can_calc": "0", "data_code": "dialysate_name", "data_name": "透析液", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialysate_in_hospital_cd_1", "data_name": "透析液連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialysate_in_hospital_cd_2", "data_name": "透析液連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialysate_in_hospital_cd_3", "data_name": "透析液連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialysate_in_hospital_cd_4", "data_name": "透析液連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/min", "can_calc": "0", "data_code": "dialysate_unit", "data_name": "透析液単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_flow_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "dialysate_flow_rate", "data_name": "透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_flow_rate", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120.00", "can_calc": "0", "data_code": "dialysate_amount", "data_name": "透析液量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_amount", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.0", "can_calc": "1", "data_code": "dialysate_temperature", "data_name": "透析液温度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_temperature", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト補液", "can_calc": "0", "data_code": "fluid_replacement_name", "data_name": "補液", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "fluid_in_hospital_cd_1", "data_name": "補液連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "fluid_in_hospital_cd_2", "data_name": "補液連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "fluid_in_hospital_cd_3", "data_name": "補液連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "fluid_in_hospital_cd_4", "data_name": "補液連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "L", "can_calc": "0", "data_code": "fluid_replacement_unit", "data_name": "補液単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "8.0", "can_calc": "1", "data_code": "fluid_replacement_amount", "data_name": "補液量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_amount", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.0", "can_calc": "0", "data_code": "fluid_replacement_speed", "data_name": "補液速度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_speed", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "前補液", "can_calc": "0", "data_code": "fluid_replacement_timing", "data_name": "補液選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "後補液", "item": "後補液"}, {"code": "1", "disp": "前補液", "item": "前補液"}], "data_class": "透析条件", "field_name": "fluid_replacement_timing", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "fluid_replacement_use_count", "data_name": "補液使用数", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_use_count", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.0", "can_calc": "0", "data_code": "fluid_replacement_temperature", "data_name": "補液温度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_temperature", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3000", "can_calc": "0", "data_code": "anti_coagulant_total_amount", "data_name": "抗凝固剤総量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_total_amount", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "anti_coagulant_name", "data_name": "抗凝固剤", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "anti_in_hospital_cd_1", "data_name": "抗凝固剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "anti_in_hospital_cd_2", "data_name": "抗凝固剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "anti_in_hospital_cd_3", "data_name": "抗凝固剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "anti_in_hospital_cd_4", "data_name": "抗凝固剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "する", "can_calc": "0", "data_code": "ip", "data_name": "IP使用選択", "data_type": "strnig", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "透析条件", "field_name": "ip", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "自動", "can_calc": "0", "data_code": "ip_start", "data_name": "IPスタート", "data_type": "string", "conv_table": [{"code": "0", "disp": "手動", "item": "手動"}, {"code": "1", "disp": "自動", "item": "自動"}], "data_class": "透析条件", "field_name": "ip_start", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.2", "can_calc": "0", "data_code": "ip_speed", "data_name": "IP速度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/h", "can_calc": "0", "data_code": "ip_speed_unit", "data_name": "IP速度単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "0", "data_code": "ip_speed_max", "data_name": "HD+IP速度最大値", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed_max", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/h", "can_calc": "0", "data_code": "ip_speed_max_unit", "data_name": "IP速度最大値単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed_max_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "auto_one_shot", "data_name": "自動ワンショット", "data_type": "decimal", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "透析条件", "field_name": "auto_one_shot", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "ip_one_shot_amount", "data_name": "IPワンショット量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_one_shot_amount", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL", "can_calc": "0", "data_code": "ip_one_shot_amount_unit", "data_name": "IPワンショット量単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "ip_one_shot_amount_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切", "can_calc": "0", "data_code": "ip_auto_off", "data_name": "IP電源自動切り", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "透析条件", "field_name": "ip_auto_off", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "ip_auto_off_time", "data_name": "IP電源自動切り時間", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_auto_off_time", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切", "can_calc": "0", "data_code": "ip_monitor_auto_off", "data_name": "IP電源OKモニタ切り", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "透析条件", "field_name": "ip_monitor_auto_off", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "ip_monitor_auto_off_time", "data_name": "IP電源OKモニタ切り時間", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_monitor_auto_off_time", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "しない", "can_calc": "1", "data_code": "single_needle", "data_name": "シングルニードル使用", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "透析条件", "field_name": "single_needle", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針A針", "can_calc": "0", "data_code": "puncture_needle_a_name", "data_name": "穿刺針A針名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "puncture_needle_a_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_a_in_hospital_cd_1", "data_name": "穿刺針A針連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_a_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_a_in_hospital_cd_2", "data_name": "穿刺針A針連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_a_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_a_in_hospital_cd_3", "data_name": "穿刺針A針連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_a_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_a_in_hospital_cd_4", "data_name": "穿刺針A針連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_a_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針V針", "can_calc": "0", "data_code": "puncture_needle_v_name", "data_name": "穿刺針V針名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "puncture_needle_v_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_v_in_hospital_cd_1", "data_name": "穿刺針V針連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_v_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_v_in_hospital_cd_2", "data_name": "穿刺針V針連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_v_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_v_in_hospital_cd_3", "data_name": "穿刺針V針連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_v_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_v_in_hospital_cd_4", "data_name": "穿刺針V針連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_v_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針S針", "can_calc": "0", "data_code": "puncture_needle_s_name", "data_name": "穿刺針S針名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "puncture_needle_sn_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_s_in_hospital_cd_1", "data_name": "穿刺針S針連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_s_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_s_in_hospital_cd_2", "data_name": "穿刺針S針連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_s_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_s_in_hospital_cd_3", "data_name": "穿刺針S針連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_s_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_s_in_hospital_cd_4", "data_name": "穿刺針S針連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_s_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "血液回路", "can_calc": "0", "data_code": "blood_circuit_name", "data_name": "血液回路名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "blood_circuit_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "bc_in_hospital_cd_1", "data_name": "血液回路連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "bc_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "bc_in_hospital_cd_2", "data_name": "血液回路連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "bc_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "bc_in_hospital_cd_3", "data_name": "血液回路連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "bc_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "bc_in_hospital_cd_4", "data_name": "血液回路連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "bc_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "スリッパ", "can_calc": "0", "data_code": "tare_name1", "data_name": "風袋名称１", "data_type": "strnig", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_name1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "tare_weight1", "data_name": "風袋重量１", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_weight1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "服", "can_calc": "0", "data_code": "tare_name2", "data_name": "風袋名称２", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_name2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "tare_weight2", "data_name": "風袋重量２", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_weight2", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "義足", "can_calc": "1", "data_code": "tare_name3", "data_name": "風袋名称３", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_name3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1200", "can_calc": "0", "data_code": "tare_weight3", "data_name": "風袋重量３", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_weight3", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋１", "can_calc": "0", "data_code": "tare_name4", "data_name": "風袋名称４", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_name4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "tare_weight4", "data_name": "風袋重量４", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_weight4", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋２", "can_calc": "0", "data_code": "tare_name5", "data_name": "風袋名称５", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_name5", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "tare_weight5", "data_name": "風袋重量５", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_weight5", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1800", "can_calc": "0", "data_code": "tare_weight_total", "data_name": "風袋重量合計", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_weight_total", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "食事量", "can_calc": "0", "data_code": "off_water_name1", "data_name": "除水補正名称１", "data_type": "strnig", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "off_water_weight1", "data_name": "除水補正重量１", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight1", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "プライミング", "can_calc": "0", "data_code": "off_water_name2", "data_name": "除水補正名称２", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "0", "data_code": "off_water_weight2", "data_name": "除水補正重量２", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight2", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "輸液量", "can_calc": "0", "data_code": "off_water_name3", "data_name": "除水補正名称３", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "off_water_weight3", "data_name": "除水補正重量３", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight3", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他（不感蒸泄）", "can_calc": "0", "data_code": "off_water_name4", "data_name": "除水補正名称４", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "off_water_weight4", "data_name": "除水補正重量４", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight4", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他", "can_calc": "0", "data_code": "off_water_name5", "data_name": "除水補正名称５", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name5", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "off_water_weight5", "data_name": "除水補正重量５", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight5", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "900", "can_calc": "0", "data_code": "off_water_weight_total", "data_name": "除水補正重量合計", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_total", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.00", "can_calc": "0", "data_code": "pre_scale_upper", "data_name": "前体重許容割合（上限）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "pre_scale_upper", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.00", "can_calc": "0", "data_code": "pre_scale_lower", "data_name": "前体重許容割合（下限）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "pre_scale_lower", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "車椅子１", "can_calc": "0", "data_code": "wheel_chair_name", "data_name": "HD/ECUMTMP自動設定警報幅下限", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "wheel_chair_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "車椅子１", "can_calc": "0", "data_code": "wheel_chair_name", "data_name": "車椅子名称", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "wheel_chair_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15000", "can_calc": "0", "data_code": "wheel_chair_weight", "data_name": "車椅子重量", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "wheel_chair_weight", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ベッド001", "can_calc": "0", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "bed_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左", "can_calc": "0", "data_code": "shunt_position", "data_name": "シャント位置", "data_type": "string", "conv_table": [{"code": "0", "disp": "両方", "item": "両方"}, {"code": "1", "disp": "左", "item": "左"}, {"code": "2", "disp": "右", "item": "右"}, {"code": "3", "disp": "なし", "item": "なし"}, {"code": "-", "disp": "不明", "item": "不明"}], "data_class": "ベッド情報", "field_name": "shunt_position", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "感染症あり", "can_calc": "0", "data_code": "is_infection", "data_name": "感染症対応", "data_type": "string", "conv_table": [{"code": "0", "disp": "感染症なし", "item": "感染症なし"}, {"code": "1", "disp": "感染症あり", "item": "感染症あり"}], "data_class": "ベッド情報", "field_name": "is_infection", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常ベッド", "can_calc": "0", "data_code": "emergency_class", "data_name": "緊急区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "通常ベッド", "item": "通常ベッド"}, {"code": "1", "disp": "緊急ベッド", "item": "緊急ベッド"}], "data_class": "ベッド情報", "field_name": "emergency_class", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "Aグループ", "can_calc": "0", "data_code": "room_bed_group_name_list", "data_name": "透析室・ベッドグループ名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "room_bed_group_name_list", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "装置001", "can_calc": "0", "data_code": "machine_name", "data_name": "装置名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "machine_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装", "can_calc": "0", "data_code": "maker", "data_name": "メーカー", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "maker", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "function_class", "data_name": "機能分類", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "function_class", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "GDF-21M", "can_calc": "0", "data_code": "model_number", "data_name": "ダイアライザ名", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "model_number", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.2", "can_calc": "0", "data_code": "area", "data_name": "面積", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "area", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "45.00", "can_calc": "0", "data_code": "ufr", "data_name": "UFR", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "ufr", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "0", "data_code": "koa", "data_name": "KOA", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "koa", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "親水化PEPA", "can_calc": "0", "data_code": "material", "data_name": "材質", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "material", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "WET", "can_calc": "0", "data_code": "wetdry", "data_name": "WET/DRY", "data_type": "string", "conv_table": [{"code": "0", "disp": "不明", "item": "不明"}, {"code": "1", "disp": "WET", "item": "WET"}, {"code": "2", "disp": "DRY", "item": "DRY"}], "data_class": "ダイアライザ情報", "field_name": "wetdry", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "γ線", "can_calc": "0", "data_code": "sterilization", "data_name": "滅菌", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "sterilization", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "0", "data_code": "bloodamt", "data_name": "血流量", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "bloodamt", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "alqd_flood_vol", "data_name": "透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "alqd_flood_vol", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "190", "can_calc": "0", "data_code": "urea_clearance", "data_name": "尿素クリアランス", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "urea_clearance", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "0", "data_code": "gas_purge_time", "data_name": "ガスパージ時間", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "gas_purge_time", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1000", "can_calc": "0", "data_code": "substituent_wash_amt", "data_name": "置換洗浄量（透析液）", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "substituent_wash_amt", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "membrane_wash", "data_name": "膜洗浄（中空糸）", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "ダイアライザ情報", "field_name": "membrane_wash", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialyzer_in_hospital_cd_1", "data_name": "ダイアライザ連携コード１", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "dialyzer_in_hospital_cd_1", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialyzer_in_hospital_cd_2", "data_name": "ダイアライザ連携コード２", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "dialyzer_in_hospital_cd_2", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialyzer_in_hospital_cd_3", "data_name": "ダイアライザ連携コード３", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "dialyzer_in_hospital_cd_3", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialyzer_in_hospital_cd_4", "data_name": "ダイアライザ連携コード４", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "dialyzer_in_hospital_cd_4", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_a1", "data_name": "治療方法連携コードa1", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_a1", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_a2", "data_name": "治療方法連携コードa2", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_a2", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_a3", "data_name": "治療方法連携コードa3", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_a3", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_a4", "data_name": "治療方法連携コードa4", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_a4", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_b1", "data_name": "治療方法連携コードb1", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_b1", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_b2", "data_name": "治療方法連携コードb2", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_b2", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_b3", "data_name": "治療方法連携コードb3", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_b3", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_b4", "data_name": "治療方法連携コードb4", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_b4", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "bed_in_hospital_cd_1", "data_name": "ベッド携コード1", "data_type": "decimal", "conv_table": [], "data_class": "ベッド情報", "field_name": "bed_in_hospital_cd_1", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "bed_in_hospital_cd_2", "data_name": "ベッド携コード2", "data_type": "decimal", "conv_table": [], "data_class": "ベッド情報", "field_name": "bed_in_hospital_cd_2", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]',
'1'
,'{"applications": [1]}'
,'{"classes": [1, 2, 3, 9, 10, 11]}'
,'指示：透析条件/ベッド情報/ダイアライザ情報　@ordNo使用'
,'2020-03-26 17:10:00'
, CURRENT_TIMESTAMP
,NULL
);
DELETE  FROM "ntss"."sys_data_set" WHERE sql_cd IN (197);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (
197
,'SELECT
	info ->> ''item_cd'' AS item_cd,
	item.in_hospital_cd1 AS in_hospital_cd1,
	item.in_hospital_cd2 AS in_hospital_cd2,
	item.in_hospital_cd3 AS in_hospital_cd3,
	item.sbt_cd1 AS sbt_cd1,
	item.sbt_cd2 AS sbt_cd2,
	item.sbt_cd3 AS sbt_cd3,
	info ->> ''item_name'' AS item_name,
	info ->> ''result'' AS RESULT,
	info ->> ''unit'' AS unit,
	info ->> ''freememo'' AS freememo,
	P.result_exam_date AS result_exam_date,
	P.reg_exam_date,
	P.reg_order_class,
	info ->> ''upper'' AS UPPER,
	info ->> ''lower'' AS LOWER,
	P.pat_id AS pat_id,
	P.pat_id AS pat_name,
	p.pat_id AS pat_birthday,
	p.pat_id AS pat_age,
	p.pat_id AS pat_sex,
	p.pat_id AS in_out_class,
	p.pat_id AS pat_blood_type_abo_rh
FROM
	(
	select DISTINCT P1.*
	from (
	SELECT M
		.* 
	FROM
		pat_exam_main AS M 
	WHERE
		M.is_del = ''0'' 
		AND M.exam_status = ''1'' 
		AND M.pat_id in (@patIds)
		AND M.result_exam_date BETWEEN date_trunc( ''day'', @fromDate :: TIMESTAMP ) 
		AND date_trunc( ''day'', @toDate :: TIMESTAMP ) + ''1 days - 1 milliseconds'' 
	ORDER BY
		M.result_exam_date DESC
	) as p1,
  jsonb_to_recordset(exam_result_info) 
    AS j1(
	  disp_order text,
	  hl text,
	  result text,
	  com_cd text,
      item_cd text,
	  result_date text,
	  freememo text,
	  jlac10_cd text
    )
WHERE NOT EXISTS(
	SELECT 1
	FROM pat_exam_main AS p2, 
  	jsonb_to_recordset(exam_result_info) 
    	AS j2(
	  	disp_order text,
	  	hl text,
	  	result text,
	  	com_cd text,
      	item_cd text,
	  	result_date text,
	  	freememo text,
	  	jlac10_cd text
    	)
			WHERE p1.pat_id = p2.pat_id 
	AND p1.facility_cd = p2.facility_cd 
	AND p1.reg_order_class = p2.reg_order_class 
	AND j1.item_cd = j2.item_cd 
	AND p1.result_exam_date < p2.result_exam_date
	AND p1.exam_status = p2.exam_status
	AND p1.is_del = p2.is_del
	)
	)
	AS P CROSS JOIN LATERAL json_array_elements ( P.exam_result_info :: json ) info
	Inner JOIN mst_exam_item AS item ON info ->> ''item_cd'' = ( item.exam_item_cd || '''' ) 
	AND ((@examItemCd
::text is not null and @examItemCd
::text  <> '''') and (item.exam_item_cd = @examItemCd
))
	AND item.facility_Cd = @facilityCd
	AND item.is_del = ''0'' 
	AND is_disp = ''1'' 
ORDER BY
	pat_id;
'
,2
,'[{"preview": "検査項目テスト", "can_calc": "0", "data_code": "item_name", "data_name": "検査項目名", "data_type": "string", "conv_table": [], "data_class": "検査結果（集計項目用）", "field_name": "item_name", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "11.2", "can_calc": "0", "data_code": "result", "data_name": "検査結果", "data_type": "string", "conv_table": [], "data_class": "検査結果（集計項目用）", "field_name": "result", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mg/dL", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "検査結果（集計項目用）", "field_name": "unit", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/12", "can_calc": "0", "data_code": "result_exam_date", "data_name": "検査日", "data_type": "DateTime", "conv_table": [], "data_class": "検査結果（集計項目用）", "field_name": "result_exam_date", "disp_format": "yyyy/mm/dd", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析前", "can_calc": "0", "data_code": "reg_order_class", "data_name": "検査区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "その他", "item": "その他"}, {"code": "1", "disp": "透析前", "item": "透析前"}, {"code": "2", "disp": "透析後", "item": "透析後"}], "data_class": "検査結果（集計項目用）", "field_name": "reg_order_class", "disp_format": "", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789012", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "hosp_pat_id", "target_var": "@patId"}, "data_code": "pat_id", "data_name": "患者ID", "data_type": "string", "conv_table": [], "data_class": "検査結果（集計項目用）", "field_name": "pat_id", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装　太郎", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_name", "target_var": "@patId"}, "data_code": "pat_name", "data_name": "氏名", "data_type": "string", "conv_table": [], "data_class": "検査結果（集計項目用）", "field_name": "pat_name", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1945/01/01", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_birthday", "target_var": "@patId"}, "data_code": "pat_birthday", "data_name": "生年月日", "data_type": "DateTime", "conv_table": [], "data_class": "検査結果（集計項目用）", "field_name": "pat_birthday", "disp_format": "yyyy/mm/dd", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_age", "target_var": "@patId"}, "data_code": "pat_age", "data_name": "年齢", "data_type": "decimal", "conv_table": [], "data_class": "検査結果（集計項目用）", "field_name": "pat_age", "disp_format": "0", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "男性", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_sex", "target_var": "@patId"}, "data_code": "pat_sex", "data_name": "性別", "data_type": "string", "conv_table": [{"code": "0", "disp": "不明", "item": "不明"}, {"code": "1", "disp": "男性", "item": "男性"}, {"code": "2", "disp": "女性", "item": "女性"}], "data_class": "検査結果（集計項目用）", "field_name": "pat_sex", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "in_out_class", "target_var": "@patId"}, "data_code": "in_out_class", "data_name": "入外区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "外来", "item": "外来"}, {"code": "1", "disp": "入院", "item": "入院"}, {"code": "2", "disp": "死亡", "item": "死亡"}, {"code": "3", "disp": "(不在)", "item": "(不在)"}], "data_class": "検査結果（集計項目用）", "field_name": "in_out_class", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "A型 RH-", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_blood_type_abo_rh", "target_var": "@patId"}, "data_code": "pat_blood_type_abo_rh", "data_name": "血液型ABORH", "data_type": "string", "conv_table": [{"code": "00", "disp": "不明", "item": "不明"}, {"code": "10", "disp": "A型 RH不明", "item": "A型 RH不明"}, {"code": "20", "disp": "B型 RH不明", "item": "B型 RH不明"}, {"code": "30", "disp": "O型 RH不明", "item": "O型 RH不明"}, {"code": "40", "disp": "AB型 RH不明", "item": "AB型 RH不明"}, {"code": "01", "disp": "不明 RH+", "item": "不明 RH+"}, {"code": "11", "disp": "A型 RH+", "item": "A型 RH+"}, {"code": "21", "disp": "B型 RH+", "item": "B型 RH+"}, {"code": "31", "disp": "O型 RH+", "item": "O型 RH+"}, {"code": "41", "disp": "AB型 RH+", "item": "AB型 RH+"}, {"code": "02", "disp": "不明 RH-", "item": "不明 RH-"}, {"code": "12", "disp": "A型 RH-+", "item": "A型 RH-"}, {"code": "22", "disp": "B型 RH-", "item": "B型 RH-"}, {"code": "32", "disp": "O型 RH-", "item": "O型 RH-"}, {"code": "42", "disp": "AB型 RH-", "item": "AB型 RH-"}], "data_class": "検査結果（集計項目用）", "field_name": "pat_blood_type_abo_rh", "disp_format": "", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]',
'1'
,'{"applications": [1]}'
,'{"classes": [1, 2, 3, 9, 10, 11]}'
,'検査結果(指定日)複@patId @date 使用'
,'2020-03-25 18:00:00'
, CURRENT_TIMESTAMP
,NULL
);
DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (16);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (16, 'WITH plan_time AS (
	SELECT
		om.ord_no,
		om.ind_cond_info :: json #>> ''{1, value}'' AS plan_time,
		( pat_unique.physical_info :: json ->> 0 ) :: json ->> ''dw'' || '' Kg'' AS cond_dw,
		om.ind_cond_info :: json #>> ''{3, value}'' || '' Kg'' AS cond_tg_wei,
		om.ind_treatment_name AS cond_tre_nm,
		om.ind_cond_info :: json #>> ''{14, value}'' || '' mL/min'' AS cond_bld_fl
	FROM
		ord_main om
		INNER JOIN pat_unique ON om.pat_id = pat_unique.pat_id
		AND pat_unique.is_del = ''0''
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.is_del = ''0''
	),
	mst_room_bed_group_1 AS ( SELECT * FROM mst_room_bed_group WHERE is_del = ''0'' AND is_disp = ''1'' AND group_class = 1 ),
	mst_room_bed_group_2 AS ( SELECT * FROM mst_room_bed_group WHERE is_del = ''0'' AND is_disp = ''1'' AND group_class = 2 ),
	medic AS (
	SELECT
		index_no AS medic_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medic_code,
		order_cd ->> ''name'' AS medi_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND master_physical_name = ''mst_medicine_class''
	),
	equic AS (
	SELECT
		index_no AS equic_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS equic_code,
		order_cd ->> ''name'' AS equic_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND master_physical_name = ''mst_equipment_class''
	),
	medi AS (
	SELECT
		index_no AS medi_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_code,
		order_cd ->> ''name'' AS medi_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND master_physical_name = ''mst_medicine''
	),
	equi AS (
	SELECT
		index_no AS equi_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS equi_code,
		order_cd ->> ''name'' AS equi_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND master_physical_name = ''mst_equipment''
	),
	bed AS (
	SELECT
		index_no AS bed_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS bed_code,
		order_cd ->> ''name'' AS bed_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND master_physical_name = ''mst_bed''
	),
	kur AS (
	SELECT
		index_no AS kur_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS kur_code,
		order_cd ->> ''name'' AS kur_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND master_physical_name = ''mst_kur''
	),
	room_bed AS (
	SELECT
		index_no AS room_bed_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS room_bed_code,
		order_cd ->> ''name'' AS room_bed_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND master_physical_name = ''mst_room_bed_group''
	),
	EquipmentList_Tmp AS (
	SELECT
		to_timestamp( treat_date, ''YYYYMMDD'' ) AS treat_date,
		medicine_cd,
		medicine_class_cd,
		equipment_cd,
		equipment_class_cd,
		kur_cd,
		kur_name,
		bed_name,
		bed_cd,
		pat_id,
		kind,
		NAME,
		amount,
		unit,
		function_class,
		area,
		ufr,
		koa,
		material,
		wetdry,
		disp_order,
		class_name,
		class_ename,
		anticoagulant_name,
		plan_time.plan_time,
		plan_time.cond_dw,
		plan_time.cond_tg_wei,
		plan_time.cond_tre_nm,
		plan_time.cond_bld_fl,
		in_hospital_cd_1,
		in_hospital_cd_2,
		equip_circuit,
		cond_ac_shot,
		cond_ac_spd,
		cond_ac_dur_total,
		cond_ip_use,
		cond_ip_start,
		cond_ip_spd,
		cond_ip_shot_st,
		cond_ip_shot,
		cond_ip_off,
		cond_ip_off_tm,
		cond_ip_ok,
		cond_ip_ok_tm,
		cond_dl_fl,
		cond_dl_am,
		cond_dl_temp,
		cond_rl_am,
		cond_rl_sel,
		cond_rl_use,
		cond_rl_temp,
		cond_rl_spd,
		medi_timing,
		medi_proc,
		num_unit,
		cond_va_dir,
		cond_va,
		equip_pnc_cls
	FROM
		(
			WITH Anticoagulant AS (
			SELECT
				om.ord_no,
				pat_id,
				treat_date,
				ind_kur_cd,
				ind_bed_cd,
				ind_cond_info,
			CASE

					WHEN om.ind_cond_info :: json #>> ''{25, medicine_type}'' = ''1'' THEN
					md.medicine_name ELSE mdx.medicine_mix_name
				END AS medicine_name,
			CASE

					WHEN om.ind_cond_info :: json #>> ''{25, medicine_type}'' = ''1'' THEN
					md.unit ELSE mdx.unit
				END AS unit,
				om.ind_cond_info :: json #>> ''{25, medicine_type}'' AS medicine_type,
				to_number( om.ind_cond_info :: json #>> ''{25,value}'', ''9999999999'' ) AS medicine_cd
			FROM
				ord_main om
				LEFT OUTER JOIN mst_medicine md ON (
					om.ind_cond_info :: json #>> ''{25, medicine_type}'' = ''1''
					AND TO_NUMBER( om.ind_cond_info :: json #>> ''{25,value}'', ''99999999'' ) = md.medicine_cd
					AND md.is_del = ''0''
					AND md.is_disp = ''1''
				)
				LEFT OUTER JOIN mst_medicine_mix mdx ON (
					om.ind_cond_info :: json #>> ''{25, medicine_type}'' = ''2''
					AND TO_NUMBER( om.ind_cond_info :: json #>> ''{25,value}'', ''99999999'' ) = mdx.medicine_mix_cd
					AND mdx.is_del = ''0''
					AND mdx.is_disp = ''1''
				)
			WHERE
				om.ord_no IN ( @ordNos )
				AND om.ind_cond_info :: json #>> ''{25,value}'' IS NOT NULL
				AND om.is_del = ''0''
			),
			ord_dialysisLiquid AS (
			SELECT
				om.ord_no,
				pat_id,
				treat_date,
				ind_kur_cd,
				ind_bed_cd,
				ind_cond_info,
				to_number( om.ind_cond_info :: json #>> ''{15,value}'', ''9999999999'' ) AS medicine_cd,
				om.ind_cond_info :: json #>> ''{15, medicine_type}'' AS medicine_type,
				om.ind_cond_info :: json #>> ''{16, value}'' AS cond_dl_fl,
				om.ind_cond_info :: json #>> ''{17, value}'' AS cond_dl_am,
				om.ind_cond_info :: json #>> ''{18, value}'' AS cond_dl_temp
			FROM
				ord_main om
			WHERE
				om.ord_no IN ( @ordNos )
				AND om.ind_cond_info :: json #>> ''{15,value}'' IS NOT NULL
				AND om.is_del = ''0''
			),
			ord_replenishLiquid AS (
			SELECT
				om.ord_no,
				pat_id,
				treat_date,
				ind_kur_cd,
				ind_bed_cd,
				ind_cond_info,
				to_number( om.ind_cond_info :: json #>> ''{19,value}'', ''9999999999'' ) AS medicine_cd,
				om.ind_cond_info :: json #>> ''{19, medicine_type}'' AS medicine_type
			FROM
				ord_main om
			WHERE
				om.ord_no IN ( @ordNos )
				AND om.ind_cond_info :: json #>> ''{19,value}'' IS NOT NULL
				AND om.is_del = ''0''
			),
			ord_medi AS (
			SELECT
				om.ord_no,
				pat_id,
				treat_date,
				ind_kur_cd,
				ind_bed_cd,
				medi,
				to_number( medi ->> ''cd'', ''9999999999'' ) AS cd,
				medi ->> ''medicine_type'' AS medicine_type,
				medi ->> ''amount'' AS amount
			FROM
				ord_main AS om
				CROSS JOIN LATERAL json_array_elements ( om.ind_medi_info :: json ) medi
			WHERE
				om.ord_no IN ( @ordNos )
				AND om.is_del = ''0''
			) SELECT
			1 AS disp_order,
			NULL AS equipment_cd,
			NULL AS equipment_class_cd,
			NULL AS medicine_cd,
			NULL AS medicine_class_cd,
			om.treat_date,
			kr.kur_cd,
			kr.kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.ind_bed_cd AS bed_cd,
			om.pat_id,
			''ダイアライザ'' AS kind,
			dz.model_number AS NAME,
			1 AS Amount,
			COALESCE ( om.ind_cond_info :: json #>> ''{5,unit}'', '''' ) AS Unit,
			function_class,
			area || ''㎡'' AS area,
			ufr,
			koa,
			material,
			wetdry,
			''ダイアライザ'' AS class_name,
			Anticoagulant.medicine_name AS Anticoagulant_name,
			om.ord_no,
			dz.in_hospital_cd_1,
			dz.in_hospital_cd_2,
			eq.equipment_name AS equip_circuit,
			NULL AS cond_ac_shot,
			NULL AS cond_ac_spd,
			NULL AS cond_ac_dur_total,
			NULL AS cond_ip_use,
			NULL AS cond_ip_start,
			NULL AS cond_ip_spd,
			NULL AS cond_ip_shot_st,
			NULL AS cond_ip_shot,
			NULL AS cond_ip_off,
			NULL AS cond_ip_off_tm,
			NULL AS cond_ip_ok,
			NULL AS cond_ip_ok_tm,
			NULL AS cond_dl_fl,
			NULL AS cond_dl_am,
			NULL AS cond_dl_temp,
			NULL AS cond_rl_am,
			NULL AS cond_rl_sel,
			NULL AS cond_rl_use,
			NULL AS cond_rl_temp,
			NULL AS cond_rl_spd,
			NULL AS medi_timing,
			NULL AS medi_proc,
			''1本'' AS num_unit,
			NULL AS cond_va_dir,
			NULL AS cond_va,
			NULL AS equip_pnc_cls,
			''Dialyser'' AS class_ename
		FROM
			ord_main om
			LEFT OUTER JOIN mst_dialyzer dz ON TO_NUMBER( om.ind_cond_info :: json #>> ''{5,value}'', ''9999999999'' ) = dz.dialyzer_cd
			AND dz.is_del = ''0''
			AND dz.is_disp = ''1''
			LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd = kr.kur_cd
			AND kr.is_del = ''0''
			LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd = bd.bed_cd
			AND bd.is_del = ''0''
			AND bd.is_disp = ''1''
			LEFT OUTER JOIN Anticoagulant ON om.ord_no = Anticoagulant.ord_no
			LEFT OUTER JOIN mst_equipment eq ON to_number( om.ind_cond_info :: json #>> ''{13,value}'', ''9999999999'' ) = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
		WHERE
			om.ord_no IN ( @ordNos )
			AND om.ind_cond_info :: json #>> ''{5,value}'' IS NOT NULL
			AND om.is_del = ''0''
			AND 0 NOT IN ( @diaIds ) UNION ALL--吸着カラム
		SELECT
			3 AS disp_order,
			eq.equipment_cd AS equipment_cd,
			eqc.class_cd AS equipment_class_cd,
			NULL AS medicine_cd,
			NULL AS medicine_class_cd,
			om.treat_date,
			kr.kur_cd,
			kr.kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.ind_bed_cd AS bed_cd,
			om.pat_id,
			COALESCE ( eqc.class_name, '''' ) AS kind,
			eq.equipment_name AS NAME,
			1 AS Amount,
			COALESCE ( eq.unit, '''' ) AS Unit,
			NULL AS function_class,
			NULL AS area,
			NULL AS ufr,
			NULL AS koa,
			NULL AS material,
			NULL AS wetdry,
			''吸着カラム'' AS class_name,
			NULL AS Anticoagulant_name,
			om.ord_no,
			eq.in_hospital_cd_1,
			eq.in_hospital_cd_2,
			NULL AS equip_circuit,
			NULL AS cond_ac_shot,
			NULL AS cond_ac_spd,
			NULL AS cond_ac_dur_total,
			NULL AS cond_ip_use,
			NULL AS cond_ip_start,
			NULL AS cond_ip_spd,
			NULL AS cond_ip_shot_st,
			NULL AS cond_ip_shot,
			NULL AS cond_ip_off,
			NULL AS cond_ip_off_tm,
			NULL AS cond_ip_ok,
			NULL AS cond_ip_ok_tm,
			NULL AS cond_dl_fl,
			NULL AS cond_dl_am,
			NULL AS cond_dl_temp,
			NULL AS cond_rl_am,
			NULL AS cond_rl_sel,
			NULL AS cond_rl_use,
			NULL AS cond_rl_temp,
			NULL AS cond_rl_spd,
			NULL AS medi_timing,
			NULL AS medi_proc,
			concat ( ''1'', eq.unit ) AS num_unit,
			NULL AS cond_va_dir,
			NULL AS cond_va,
			NULL AS equip_pnc_cls,
			''Adsorption'' AS class_ename
		FROM
			ord_main om
			LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{6,value}'', ''9999999999'' ) = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			LEFT OUTER JOIN mst_equipment_class eqc ON eq.class_cd = eqc.class_cd
			AND eqc.is_del = ''0''
			AND eqc.is_disp = ''1''
			LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd = kr.kur_cd
			AND kr.is_del = ''0''
			LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd = bd.bed_cd
			AND bd.is_del = ''0''
			AND bd.is_disp = ''1''
		WHERE
			om.ord_no IN ( @ordNos )
			AND om.ind_cond_info :: json #>> ''{6,value}'' IS NOT NULL
			AND om.is_del = ''0''
			AND eq.class_cd IN ( @eqIds ) UNION ALL--1次膜
		SELECT
			3 AS disp_order,
			eq.equipment_cd AS equipment_cd,
			eqc.class_cd AS equipment_class_cd,
			NULL AS medicine_cd,
			NULL AS medicine_class_cd,
			om.treat_date,
			kr.kur_cd,
			kr.kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.ind_bed_cd AS bed_cd,
			om.pat_id,
			COALESCE ( eqc.class_name, '''' ) AS kind,
			eq.equipment_name AS NAME,
			1 AS Amount,
			COALESCE ( eq.unit, '''' ) AS Unit,
			NULL AS function_class,
			NULL AS area,
			NULL AS ufr,
			NULL AS koa,
			NULL AS material,
			NULL AS wetdry,
			''1次膜'' AS class_name,
			NULL AS Anticoagulant_name,
			om.ord_no,
			eq.in_hospital_cd_1,
			eq.in_hospital_cd_2,
			NULL AS equip_circuit,
			NULL AS cond_ac_shot,
			NULL AS cond_ac_spd,
			NULL AS cond_ac_dur_total,
			NULL AS cond_ip_use,
			NULL AS cond_ip_start,
			NULL AS cond_ip_spd,
			NULL AS cond_ip_shot_st,
			NULL AS cond_ip_shot,
			NULL AS cond_ip_off,
			NULL AS cond_ip_off_tm,
			NULL AS cond_ip_ok,
			NULL AS cond_ip_ok_tm,
			NULL AS cond_dl_fl,
			NULL AS cond_dl_am,
			NULL AS cond_dl_temp,
			NULL AS cond_rl_am,
			NULL AS cond_rl_sel,
			NULL AS cond_rl_use,
			NULL AS cond_rl_temp,
			NULL AS cond_rl_spd,
			NULL AS medi_timing,
			NULL AS medi_proc,
			concat ( ''1'', eq.unit ) AS num_unit,
			NULL AS cond_va_dir,
			NULL AS cond_va,
			NULL AS equip_pnc_cls,
			''Film1'' AS class_ename
		FROM
			ord_main om
			LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{7,value}'', ''9999999999'' ) = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			LEFT OUTER JOIN mst_equipment_class eqc ON eq.class_cd = eqc.class_cd
			AND eqc.is_del = ''0''
			AND eqc.is_disp = ''1''
			LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd = kr.kur_cd
			AND kr.is_del = ''0''
			LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd = bd.bed_cd
			AND bd.is_del = ''0''
			AND bd.is_disp = ''1''
		WHERE
			om.ord_no IN ( @ordNos )
			AND om.ind_cond_info :: json #>> ''{7,value}'' IS NOT NULL
			AND om.is_del = ''0''
			AND eq.class_cd IN ( @eqIds ) UNION ALL--2次膜
		SELECT
			3 AS disp_order,
			eq.equipment_cd AS equipment_cd,
			eqc.class_cd AS equipment_class_cd,
			NULL AS medicine_cd,
			NULL AS medicine_class_cd,
			om.treat_date,
			kr.kur_cd,
			kr.kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.ind_bed_cd AS bed_cd,
			om.pat_id,
			COALESCE ( eqc.class_name, '''' ) AS kind,
			eq.equipment_name AS NAME,
			1 AS Amount,
			COALESCE ( eq.unit, '''' ) AS Unit,
			NULL AS function_class,
			NULL AS area,
			NULL AS ufr,
			NULL AS koa,
			NULL AS material,
			NULL AS wetdry,
			''2次膜'' AS class_name,
			NULL AS Anticoagulant_name,
			om.ord_no,
			eq.in_hospital_cd_1,
			eq.in_hospital_cd_2,
			NULL AS equip_circuit,
			NULL AS cond_ac_shot,
			NULL AS cond_ac_spd,
			NULL AS cond_ac_dur_total,
			NULL AS cond_ip_use,
			NULL AS cond_ip_start,
			NULL AS cond_ip_spd,
			NULL AS cond_ip_shot_st,
			NULL AS cond_ip_shot,
			NULL AS cond_ip_off,
			NULL AS cond_ip_off_tm,
			NULL AS cond_ip_ok,
			NULL AS cond_ip_ok_tm,
			NULL AS cond_dl_fl,
			NULL AS cond_dl_am,
			NULL AS cond_dl_temp,
			NULL AS cond_rl_am,
			NULL AS cond_rl_sel,
			NULL AS cond_rl_use,
			NULL AS cond_rl_temp,
			NULL AS cond_rl_spd,
			NULL AS medi_timing,
			NULL AS medi_proc,
			concat ( ''1'', eq.unit ) AS num_unit,
			NULL AS cond_va_dir,
			NULL AS cond_va,
			NULL AS equip_pnc_cls,
			''Film2'' AS class_ename
		FROM
			ord_main om
			LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{8,value}'', ''99999999'' ) = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			LEFT OUTER JOIN mst_equipment_class eqc ON eq.class_cd = eqc.class_cd
			AND eqc.is_del = ''0''
			AND eqc.is_disp = ''1''
			LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd = kr.kur_cd
			AND kr.is_del = ''0''
			LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd = bd.bed_cd
			AND bd.is_del = ''0''
			AND bd.is_disp = ''1''
		WHERE
			om.ord_no IN ( @ordNos )
			AND om.ind_cond_info :: json #>> ''{8,value}'' IS NOT NULL
			AND om.is_del = ''0''
			AND eq.class_cd IN ( @eqIds ) UNION ALL--穿刺針(A針)
		SELECT
			3 AS disp_order,
			eq.equipment_cd AS equipment_cd,
			eqc.class_cd AS equipment_class_cd,
			NULL AS medicine_cd,
			NULL AS medicine_class_cd,
			om.treat_date,
			kr.kur_cd,
			kr.kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.ind_bed_cd AS bed_cd,
			om.pat_id,
			COALESCE ( eqc.class_name, '''' ) AS kind,
			eq.equipment_name AS NAME,
			1 AS Amount,
			COALESCE ( eq.unit, '''' ) AS Unit,
			NULL AS function_class,
			NULL AS area,
			NULL AS ufr,
			NULL AS koa,
			NULL AS material,
			NULL AS wetdry,
			''穿刺針(A針)'' AS class_name,
			NULL AS Anticoagulant_name,
			om.ord_no,
			eq.in_hospital_cd_1,
			eq.in_hospital_cd_2,
			NULL AS equip_circuit,
			NULL AS cond_ac_shot,
			NULL AS cond_ac_spd,
			NULL AS cond_ac_dur_total,
			NULL AS cond_ip_use,
			NULL AS cond_ip_start,
			NULL AS cond_ip_spd,
			NULL AS cond_ip_shot_st,
			NULL AS cond_ip_shot,
			NULL AS cond_ip_off,
			NULL AS cond_ip_off_tm,
			NULL AS cond_ip_ok,
			NULL AS cond_ip_ok_tm,
			NULL AS cond_dl_fl,
			NULL AS cond_dl_am,
			NULL AS cond_dl_temp,
			NULL AS cond_rl_am,
			NULL AS cond_rl_sel,
			NULL AS cond_rl_use,
			NULL AS cond_rl_temp,
			NULL AS cond_rl_spd,
			NULL AS medi_timing,
			NULL AS medi_proc,
			concat ( ''1'', eq.unit ) AS num_unit,
			va.va_direct AS cond_va_dir,
			va.va_name AS cond_va,
			''A針'' AS equip_pnc_cls,
			''Puncture'' AS class_ename
		FROM
			ord_main om
			LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{9,value}'', ''9999999999'' ) = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			LEFT OUTER JOIN mst_equipment_class eqc ON eq.class_cd = eqc.class_cd
			AND eqc.is_del = ''0''
			AND eqc.is_disp = ''1''
			LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd = kr.kur_cd
			AND kr.is_del = ''0''
			LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd = bd.bed_cd
			AND bd.is_del = ''0''
			AND bd.is_disp = ''1''
			LEFT OUTER JOIN mst_va va ON to_number( om.ind_cond_info :: json #>> ''{2, value}'', ''9999999999'' ) = va.va_cd
			AND va.is_del = ''0''
			AND va.is_disp = ''1''
		WHERE
			om.ord_no IN ( @ordNos )
			AND om.ind_cond_info :: json #>> ''{9,value}'' IS NOT NULL
			AND om.is_del = ''0''
			AND eq.class_cd IN ( @eqIds ) UNION ALL--穿刺針(V針)
		SELECT
			3 AS disp_order,
			eq.equipment_cd AS equipment_cd,
			eqc.class_cd AS equipment_class_cd,
			NULL AS medicine_cd,
			NULL AS medicine_class_cd,
			om.treat_date,
			kr.kur_cd,
			kr.kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.ind_bed_cd AS bed_cd,
			om.pat_id,
			COALESCE ( eqc.class_name, '''' ) AS kind,
			eq.equipment_name AS NAME,
			1 AS Amount,
			COALESCE ( eq.unit, '''' ) AS Unit,
			NULL AS function_class,
			NULL AS area,
			NULL AS ufr,
			NULL AS koa,
			NULL AS material,
			NULL AS wetdry,
			''穿刺針(V針)'' AS class_name,
			NULL AS Anticoagulant_name,
			om.ord_no,
			eq.in_hospital_cd_1,
			eq.in_hospital_cd_2,
			NULL AS equip_circuit,
			NULL AS cond_ac_shot,
			NULL AS cond_ac_spd,
			NULL AS cond_ac_dur_total,
			NULL AS cond_ip_use,
			NULL AS cond_ip_start,
			NULL AS cond_ip_spd,
			NULL AS cond_ip_shot_st,
			NULL AS cond_ip_shot,
			NULL AS cond_ip_off,
			NULL AS cond_ip_off_tm,
			NULL AS cond_ip_ok,
			NULL AS cond_ip_ok_tm,
			NULL AS cond_dl_fl,
			NULL AS cond_dl_am,
			NULL AS cond_dl_temp,
			NULL AS cond_rl_am,
			NULL AS cond_rl_sel,
			NULL AS cond_rl_use,
			NULL AS cond_rl_temp,
			NULL AS cond_rl_spd,
			NULL AS medi_timing,
			NULL AS medi_proc,
			concat ( ''1'', eq.unit ) AS num_unit,
			NULL AS cond_va_dir,
			NULL AS cond_va,
			''V針'' AS equip_pnc_cls,
			''Puncture'' AS class_ename
		FROM
			ord_main om
			LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{10,value}'', ''99999999'' ) = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			LEFT OUTER JOIN mst_equipment_class eqc ON eq.class_cd = eqc.class_cd
			AND eqc.is_del = ''0''
			AND eqc.is_disp = ''1''
			LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd = kr.kur_cd
			AND kr.is_del = ''0''
			LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd = bd.bed_cd
			AND bd.is_del = ''0''
			AND bd.is_disp = ''1''
		WHERE
			om.ord_no IN ( @ordNos )
			AND om.ind_cond_info :: json #>> ''{10,value}'' IS NOT NULL
			AND om.is_del = ''0''
			AND eq.class_cd IN ( @eqIds ) UNION ALL--穿刺針(SN)
		SELECT
			3 AS disp_order,
			eq.equipment_cd AS equipment_cd,
			eqc.class_cd AS equipment_class_cd,
			NULL AS medicine_cd,
			NULL AS medicine_class_cd,
			om.treat_date,
			kr.kur_cd,
			kr.kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.ind_bed_cd AS bed_cd,
			om.pat_id,
			COALESCE ( eqc.class_name, '''' ) AS kind,
			eq.equipment_name AS NAME,
			1 AS Amount,
			COALESCE ( eq.unit, '''' ) AS Unit,
			NULL AS function_class,
			NULL AS area,
			NULL AS ufr,
			NULL AS koa,
			NULL AS material,
			NULL AS wetdry,
			''穿刺針(SN)'' AS class_name,
			NULL AS Anticoagulant_name,
			om.ord_no,
			eq.in_hospital_cd_1,
			eq.in_hospital_cd_2,
			NULL AS equip_circuit,
			NULL AS cond_ac_shot,
			NULL AS cond_ac_spd,
			NULL AS cond_ac_dur_total,
			NULL AS cond_ip_use,
			NULL AS cond_ip_start,
			NULL AS cond_ip_spd,
			NULL AS cond_ip_shot_st,
			NULL AS cond_ip_shot,
			NULL AS cond_ip_off,
			NULL AS cond_ip_off_tm,
			NULL AS cond_ip_ok,
			NULL AS cond_ip_ok_tm,
			NULL AS cond_dl_fl,
			NULL AS cond_dl_am,
			NULL AS cond_dl_temp,
			NULL AS cond_rl_am,
			NULL AS cond_rl_sel,
			NULL AS cond_rl_use,
			NULL AS cond_rl_temp,
			NULL AS cond_rl_spd,
			NULL AS medi_timing,
			NULL AS medi_proc,
			concat ( ''1'', eq.unit ) AS num_unit,
			NULL AS cond_va_dir,
			NULL AS cond_va,
			''SN'' AS equip_pnc_cls,
			''Puncture'' AS class_ename
		FROM
			ord_main om
			LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{11,value}'', ''99999999'' ) = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			LEFT OUTER JOIN mst_equipment_class eqc ON eq.class_cd = eqc.class_cd
			AND eqc.is_del = ''0''
			AND eqc.is_disp = ''1''
			LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd = kr.kur_cd
			AND kr.is_del = ''0''
			LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd = bd.bed_cd
			AND bd.is_del = ''0''
			AND bd.is_disp = ''1''
		WHERE
			om.ord_no IN ( @ordNos )
			AND om.ind_cond_info :: json #>> ''{11,value}'' IS NOT NULL
			AND om.is_del = ''0''
			AND eq.class_cd IN ( @eqIds ) UNION ALL--血液回路
		SELECT
			3 AS disp_order,
			eq.equipment_cd AS equipment_cd,
			eqc.class_cd AS equipment_class_cd,
			NULL AS medicine_cd,
			NULL AS medicine_class_cd,
			om.treat_date,
			kr.kur_cd,
			kr.kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.ind_bed_cd AS bed_cd,
			om.pat_id,
			COALESCE ( eqc.class_name, '''' ) AS kind,
			eq.equipment_name AS NAME,
			1 AS Amount,
			COALESCE ( eq.unit, '''' ) AS Unit,
			NULL AS function_class,
			NULL AS area,
			NULL AS ufr,
			NULL AS koa,
			NULL AS material,
			NULL AS wetdry,
			''血液回路'' AS class_name,
			NULL AS Anticoagulant_name,
			om.ord_no,
			eq.in_hospital_cd_1,
			eq.in_hospital_cd_2,
			NULL AS equip_circuit,
			NULL AS cond_ac_shot,
			NULL AS cond_ac_spd,
			NULL AS cond_ac_dur_total,
			NULL AS cond_ip_use,
			NULL AS cond_ip_start,
			NULL AS cond_ip_spd,
			NULL AS cond_ip_shot_st,
			NULL AS cond_ip_shot,
			NULL AS cond_ip_off,
			NULL AS cond_ip_off_tm,
			NULL AS cond_ip_ok,
			NULL AS cond_ip_ok_tm,
			NULL AS cond_dl_fl,
			NULL AS cond_dl_am,
			NULL AS cond_dl_temp,
			NULL AS cond_rl_am,
			NULL AS cond_rl_sel,
			NULL AS cond_rl_use,
			NULL AS cond_rl_temp,
			NULL AS cond_rl_spd,
			NULL AS medi_timing,
			NULL AS medi_proc,
			concat ( ''1'', eq.unit ) AS num_unit,
			NULL AS cond_va_dir,
			NULL AS cond_va,
			NULL AS equip_pnc_cls,
			''BloodRoad'' AS class_ename
		FROM
			ord_main om
			LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{13,value}'', ''9999999999'' ) = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			LEFT OUTER JOIN mst_equipment_class eqc ON eq.class_cd = eqc.class_cd
			AND eqc.is_del = ''0''
			AND eqc.is_disp = ''1''
			LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd = kr.kur_cd
			AND kr.is_del = ''0''
			LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd = bd.bed_cd
			AND bd.is_del = ''0''
			AND bd.is_disp = ''1''
		WHERE
			om.ord_no IN ( @ordNos )
			AND om.ind_cond_info :: json #>> ''{13,value}'' IS NOT NULL
			AND om.is_del = ''0''
			AND eq.class_cd IN ( @eqIds ) UNION ALL--透析液
		SELECT
			2 AS disp_order,
			NULL AS equipment_cd,
			NULL AS equipment_class_cd,
			md.medicine_cd :: TEXT AS medicine_cd,
			mdc.class_cd :: TEXT AS medicine_class_cd,
			om.treat_date,
			kr.kur_cd,
			kr.kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.ind_bed_cd AS bed_cd,
			om.pat_id,
			COALESCE ( mdc.class_name, '''' ) AS kind,
			md.medicine_name AS NAME,
			TO_NUMBER( cond_dl_am, ''99999999.99'' ) AS Amount,
			COALESCE ( md.unit, '''' ) AS Unit,
			NULL AS function_class,
			NULL AS area,
			NULL AS ufr,
			NULL AS koa,
			NULL AS material,
			NULL AS wetdry,
			''透析液'' AS class_name,
			NULL AS Anticoagulant_name,
			om.ord_no,
			md.in_hospital_cd_1,
			md.in_hospital_cd_2,
			NULL AS equip_circuit,
			NULL AS cond_ac_shot,
			NULL AS cond_ac_spd,
			NULL AS cond_ac_dur_total,
			NULL AS cond_ip_use,
			NULL AS cond_ip_start,
			NULL AS cond_ip_spd,
			NULL AS cond_ip_shot_st,
			NULL AS cond_ip_shot,
			NULL AS cond_ip_off,
			NULL AS cond_ip_off_tm,
			NULL AS cond_ip_ok,
			NULL AS cond_ip_ok_tm,
			om.cond_dl_fl || ''mL/min'' AS cond_dl_fl,
			concat ( cond_dl_am, md.unit) AS cond_dl_am,
			om.cond_dl_temp || ''℃'' AS cond_dl_temp,
			NULL AS cond_rl_am,
			NULL AS cond_rl_sel,
			NULL AS cond_rl_use,
			NULL AS cond_rl_temp,
			NULL AS cond_rl_spd,
			NULL AS medi_timing,
			NULL AS medi_proc,
			concat ( cond_dl_am, md.unit_second ) AS num_unit,
			NULL AS cond_va_dir,
			NULL AS cond_va,
			NULL AS equip_pnc_cls,
			''DialysisLiquid'' AS class_ename
		FROM
			ord_dialysisLiquid om
			LEFT OUTER JOIN mst_medicine md ON ( om.medicine_type = ''1'' AND om.medicine_cd = md.medicine_cd AND md.is_del = ''0'' AND md.is_disp = ''1'' )
			LEFT OUTER JOIN mst_medicine_class mdc ON md.class_cd = mdc.class_cd
			AND mdc.is_del = ''0''
			AND mdc.is_disp = ''1''
			LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd = kr.kur_cd
			AND kr.is_del = ''0''
			LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd = bd.bed_cd
			AND bd.is_del = ''0''
			AND bd.is_disp = ''1''
		WHERE
			( om.medicine_type = ''1'' AND md.class_cd IN ( @medIds ) ) UNION ALL--補液
		SELECT
			2 AS disp_order,
			NULL AS equipment_cd,
			NULL AS equipment_class_cd,
			md.medicine_cd :: TEXT AS medicine_cd,
			mdc.class_cd :: TEXT AS medicine_class_cd,
			om.treat_date,
			kr.kur_cd,
			kr.kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.ind_bed_cd AS bed_cd,
			om.pat_id,
			COALESCE ( mdc.class_name, '''' ) AS kind,
			md.medicine_name AS NAME,
			TO_NUMBER( om.ind_cond_info :: json #>> ''{22,value}'', ''99999999.99'' ) AS Amount,
			COALESCE ( md.unit, '''' ) AS Unit,
			NULL AS function_class,
			NULL AS area,
			NULL AS ufr,
			NULL AS koa,
			NULL AS material,
			NULL AS wetdry,
			''補液'' AS class_name,
			NULL AS Anticoagulant_name,
			om.ord_no,
			md.in_hospital_cd_1,
			md.in_hospital_cd_2,
			NULL AS equip_circuit,
			NULL AS cond_ac_shot,
			NULL AS cond_ac_spd,
			NULL AS cond_ac_dur_total,
			NULL AS cond_ip_use,
			NULL AS cond_ip_start,
			NULL AS cond_ip_spd,
			NULL AS cond_ip_shot_st,
			NULL AS cond_ip_shot,
			NULL AS cond_ip_off,
			NULL AS cond_ip_off_tm,
			NULL AS cond_ip_ok,
			NULL AS cond_ip_ok_tm,
			NULL AS cond_dl_fl,
			NULL AS cond_dl_am,
			NULL AS cond_dl_temp,
			om.ind_cond_info :: json #>> ''{20, value}'' || ''L'' AS cond_rl_am,
		CASE

				WHEN om.ind_cond_info :: json #>> ''{21, value}'' = ''0'' THEN
				''後補液'' ELSE''前補液''
			END AS cond_rl_sel,
			om.ind_cond_info :: json #>> ''{22, value}'' ||
			md.unit AS cond_rl_use,
			om.ind_cond_info :: json #>> ''{23, value}'' || ''℃'' AS cond_rl_temp,
			om.ind_cond_info :: json #>> ''{24, value}'' || ''L/min'' AS cond_rl_spd,
			NULL AS medi_timing,
			NULL AS medi_proc,
			om.ind_cond_info :: json #>> ''{22,value}'' ||
			COALESCE ( md.unit_second, '''' ) AS num_unit,
			NULL AS cond_va_dir,
			NULL AS cond_va,
			NULL AS equip_pnc_cls,
			''ReplenishLiquid'' AS class_ename
		FROM
			ord_replenishLiquid om
			LEFT OUTER JOIN mst_medicine md ON ( om.medicine_type = ''1'' AND om.medicine_cd = md.medicine_cd AND md.is_del = ''0'' AND md.is_disp = ''1'' )
			LEFT OUTER JOIN mst_medicine_class mdc ON md.class_cd = mdc.class_cd
			AND mdc.is_del = ''0''
			AND mdc.is_disp = ''1''
			LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd = kr.kur_cd
			AND kr.is_del = ''0''
			LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd = bd.bed_cd
			AND bd.is_del = ''0''
			AND bd.is_disp = ''1''
		WHERE
			( om.medicine_type = ''1'' AND md.class_cd IN ( @medIds ) ) UNION ALL--抗凝固剤
		SELECT
			2 AS disp_order,
			NULL AS equipment_cd,
			NULL AS equipment_class_cd,
			md.medicine_cd :: TEXT AS medicine_cd,
			mdc.class_cd :: TEXT AS medicine_class_cd,
			om.treat_date,
			kr.kur_cd,
			kr.kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.ind_bed_cd AS bed_cd,
			om.pat_id,
			COALESCE ( mdc.class_name, '''' ) AS kind,
			md.medicine_name AS NAME,
			CEIL (
				(
					( TO_NUMBER( om.ind_cond_info :: json #>> ''{26,value}'', ''99999999.99'' ) + TO_NUMBER( om.ind_cond_info :: json #>> ''{28,value}'', ''99999999.99'' ) ) /
				CASE

						WHEN md.unit_converted_amount = 0 THEN
						1 ELSE md.unit_converted_amount
					END
					) * md.unit_converted_amount_second
				) AS Amount,
				COALESCE ( md.unit, '''' ) AS Unit,
				NULL AS function_class,
				NULL AS area,
				NULL AS ufr,
				NULL AS koa,
				NULL AS material,
				NULL AS wetdry,
				''抗凝固剤'' AS class_name,
				NULL AS Anticoagulant_name,
				om.ord_no,
				md.in_hospital_cd_1,
				md.in_hospital_cd_2,
				NULL AS equip_circuit,
				TO_NUMBER( om.ind_cond_info :: json #>> ''{26,value}'', ''99999999.99'' ) || om.unit AS cond_ac_shot,
				TO_NUMBER( om.ind_cond_info :: json #>> ''{27,value}'', ''99999999.99'' ) ||
			CASE

					WHEN om.unit IS NULL THEN
					'''' ELSE om.unit || ''/h''
				END AS cond_ac_spd,
				TO_NUMBER( om.ind_cond_info :: json #>> ''{28,value}'', ''99999999.99'' ) || om.unit AS cond_ac_dur_total,
			CASE

					WHEN om.ind_cond_info :: json #>> ''{29,value}'' = ''1'' THEN
					''使用する'' ELSE''使用しない''
				END AS cond_ip_use,
			CASE

					WHEN om.ind_cond_info :: json #>> ''{30,value}'' = ''1'' THEN
					''自動'' ELSE''手動''
				END AS cond_ip_start,
				om.ind_cond_info :: json #>> ''{32,value}'' || ''mL/h'' AS cond_ip_spd,
			CASE

					WHEN om.ind_cond_info :: json #>> ''{34,value}'' = ''1'' THEN
					''自動'' ELSE''手動''
				END AS cond_ip_shot_st,
				om.ind_cond_info :: json #>> ''{31,value}'' || ''mL'' AS cond_ip_shot,
			CASE

					WHEN om.ind_cond_info :: json #>> ''{35,value}'' = ''1'' THEN
					''入'' ELSE''切''
				END AS cond_ip_off,
				om.ind_cond_info :: json #>> ''{36,value}'' || ''分'' AS cond_ip_off_tm,
			CASE

					WHEN om.ind_cond_info :: json #>> ''{37,value}'' = ''1'' THEN
					''入'' ELSE''切''
				END AS cond_ip_ok,
				om.ind_cond_info :: json #>> ''{38,value}'' || ''分'' AS cond_ip_ok_tm,
				NULL AS cond_dl_fl,
				NULL AS cond_dl_am,
				NULL AS cond_dl_temp,
				NULL AS cond_rl_am,
				NULL AS cond_rl_sel,
				NULL AS cond_rl_use,
				NULL AS cond_rl_temp,
				NULL AS cond_rl_spd,
				NULL AS medi_timing,
				NULL AS medi_proc,
				om.ind_cond_info :: json #>> ''{28,value}'' || om.unit AS num_unit,
				NULL AS cond_va_dir,
				NULL AS cond_va,
				NULL AS equip_pnc_cls,
				''AntiCoagulan'' AS class_ename
			FROM
				Anticoagulant om
				LEFT OUTER JOIN mst_medicine md ON ( om.medicine_type = ''1'' AND om.medicine_cd = md.medicine_cd AND md.is_del = ''0'' AND md.is_disp = ''1'' )
				LEFT OUTER JOIN mst_medicine_mix mdx ON ( om.medicine_type = ''2'' AND om.medicine_cd = mdx.medicine_mix_cd AND mdx.is_del = ''0'' AND mdx.is_disp = ''1'' )
				LEFT OUTER JOIN mst_medicine_class mdc ON md.class_cd = mdc.class_cd
				AND mdc.is_del = ''0''
				AND mdc.is_disp = ''1''
				LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd = kr.kur_cd
				AND kr.is_del = ''0''
				LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd = bd.bed_cd
				AND bd.is_del = ''0''
				AND bd.is_disp = ''1''
			WHERE
				( om.medicine_type = ''1'' AND md.class_cd IN ( @medIds ) ) UNION ALL--抗凝固剤(調製薬剤)
			SELECT
				2 AS disp_order,
				NULL AS equipment_cd,
				NULL AS equipment_class_cd,
				mmx.medicine_mix_cd :: TEXT AS medicine_cd,
				mdc.class_cd :: TEXT AS medicine_class_cd,
				om.treat_date,
				kr.kur_cd,
				kr.kur_name,
				COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
				om.ind_bed_cd AS bed_cd,
				om.pat_id,
				COALESCE ( mdc.class_name, '''' ) AS kind,
				mmx.medicine_mix_name AS NAME,
				( TO_NUMBER( om.ind_cond_info :: json #>> ''{26,value}'', ''99999999.99'' ) + TO_NUMBER( om.ind_cond_info :: json #>> ''{28,value}'', ''99999999.99'' ) ) AS Amount,
				COALESCE ( mmx.unit, '''' ) AS Unit,
				NULL AS function_class,
				NULL AS area,
				NULL AS ufr,
				NULL AS koa,
				NULL AS material,
				NULL AS wetdry,
				''抗凝固剤'' AS class_name,
				NULL AS Anticoagulant_name,
				om.ord_no,
				mmx.in_hospital_cd_1,
				mmx.in_hospital_cd_2,
				NULL AS equip_circuit,
				TO_NUMBER( om.ind_cond_info :: json #>> ''{26,value}'', ''99999999.99'' ) || om.unit AS cond_ac_shot,
				TO_NUMBER( om.ind_cond_info :: json #>> ''{27,value}'', ''99999999.99'' ) ||
			CASE

					WHEN om.unit IS NULL THEN
					'''' ELSE om.unit || ''/h''
				END AS cond_ac_spd,
				TO_NUMBER( om.ind_cond_info :: json #>> ''{28,value}'', ''99999999.99'' ) || om.unit AS cond_ac_dur_total,
			CASE

					WHEN om.ind_cond_info :: json #>> ''{29,value}'' = ''1'' THEN
					''使用する'' ELSE''使用しない''
				END AS cond_ip_use,
			CASE

					WHEN om.ind_cond_info :: json #>> ''{30,value}'' = ''1'' THEN
					''自動'' ELSE''手動''
				END AS cond_ip_start,
				om.ind_cond_info :: json #>> ''{32,value}'' || ''mL/h'' AS cond_ip_spd,
			CASE

					WHEN om.ind_cond_info :: json #>> ''{34,value}'' = ''1'' THEN
					''自動'' ELSE''手動''
				END AS cond_ip_shot_st,
				om.ind_cond_info :: json #>> ''{31,value}'' || ''mL'' AS cond_ip_shot,
			CASE

					WHEN om.ind_cond_info :: json #>> ''{35,value}'' = ''1'' THEN
					''入'' ELSE''切''
				END AS cond_ip_off,
				om.ind_cond_info :: json #>> ''{36,value}'' || ''分'' AS cond_ip_off_tm,
			CASE

					WHEN om.ind_cond_info :: json #>> ''{37,value}'' = ''1'' THEN
					''入'' ELSE''切''
				END AS cond_ip_ok,
				om.ind_cond_info :: json #>> ''{38,value}'' || ''分'' AS cond_ip_ok_tm,
				NULL AS cond_dl_fl,
				NULL AS cond_dl_am,
				NULL AS cond_dl_temp,
				NULL AS cond_rl_am,
				NULL AS cond_rl_sel,
				NULL AS cond_rl_use,
				NULL AS cond_rl_temp,
				NULL AS cond_rl_spd,
				NULL AS medi_timing,
				NULL AS medi_proc,
				( TO_NUMBER( om.ind_cond_info :: json #>> ''{26,value}'', ''99999999.99'' ) + TO_NUMBER( om.ind_cond_info :: json #>> ''{28,value}'', ''99999999.99'' ) ) || COALESCE ( mmx.unit, '''' ) AS num_unit,
				NULL AS cond_va_dir,
				NULL AS cond_va,
				NULL AS equip_pnc_cls,
				''AntiCoagulan'' AS class_ename
			FROM
				Anticoagulant om
				LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( om.ind_cond_info -> ''25'' ->> ''value'', ''999999999999'' )
				CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
				LEFT OUTER JOIN mst_medicine_class mdc ON mmx.class_cd = mdc.class_cd
				AND mdc.is_del = ''0''
				AND mdc.is_disp = ''1''
				LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd = kr.kur_cd
				AND kr.is_del = ''0''
				LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd = bd.bed_cd
				AND bd.is_del = ''0''
				AND bd.is_disp = ''1''
			WHERE
				om.ord_no IN ( @ordNos )
				AND om.ind_cond_info :: json #>> ''{25,value}'' IS NOT NULL
				AND mmx.class_cd IN ( @medIds ) UNION ALL--投薬(薬剤)
			SELECT
				2 AS disp_order,
				NULL AS equipment_cd,
				NULL AS equipment_class_cd,
				md.medicine_cd :: TEXT AS medicine_cd,
				mdc.class_cd :: TEXT AS medicine_class_cd,
				om.treat_date,
				kr.kur_cd,
				kr.kur_name,
				COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
				om.ind_bed_cd AS bed_cd,
				om.pat_id,
				COALESCE ( mdc.class_name, '''' ) AS kind,
				md.medicine_name AS NAME,
				CEIL (
					( ( TO_NUMBER( medi ->> ''amount'', ''99999999.99'' ) ) / CASE WHEN md.unit_converted_amount = 0 THEN 1 ELSE md.unit_converted_amount END ) /
				CASE

						WHEN md.unit_converted_amount_second = 0 THEN
						1 ELSE md.unit_converted_amount_second
					END
					) AS Amount,
					COALESCE ( md.unit_second, COALESCE ( md.unit, '''' ) ) AS Unit,
					NULL AS function_class,
					NULL AS area,
					NULL AS ufr,
					NULL AS koa,
					NULL AS material,
					NULL AS wetdry,
					''投与薬剤'' AS class_name,
					NULL AS Anticoagulant_name,
					om.ord_no,
					md.in_hospital_cd_1,
					md.in_hospital_cd_2,
					NULL AS equip_circuit,
					NULL AS cond_ac_shot,
					NULL AS cond_ac_spd,
					NULL AS cond_ac_dur_total,
					NULL AS cond_ip_use,
					NULL AS cond_ip_start,
					NULL AS cond_ip_spd,
					NULL AS cond_ip_shot_st,
					NULL AS cond_ip_shot,
					NULL AS cond_ip_off,
					NULL AS cond_ip_off_tm,
					NULL AS cond_ip_ok,
					NULL AS cond_ip_ok_tm,
					NULL AS cond_dl_fl,
					NULL AS cond_dl_am,
					NULL AS cond_dl_temp,
					NULL AS cond_rl_am,
					NULL AS cond_rl_sel,
					NULL AS cond_rl_use,
					NULL AS cond_rl_temp,
					NULL AS cond_rl_spd,
					mt.medicate_timing_name AS medi_timing,
					mp.pricedure_name AS medi_proc,
					om.amount || COALESCE ( md.unit, '''' ) AS num_unit,
					NULL AS cond_va_dir,
					NULL AS cond_va,
					NULL AS equip_pnc_cls,
					''Medicine'' AS class_ename
				FROM
					ord_medi AS om
					LEFT OUTER JOIN mst_medicine md ON ( om.medicine_type = ''1'' AND om.cd = md.medicine_cd AND md.is_del = ''0'' AND md.is_disp = ''1'' )
					LEFT OUTER JOIN mst_medicine_class mdc ON md.class_cd = mdc.class_cd
					AND mdc.is_del = ''0''
					AND mdc.is_disp = ''1''
					LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd = kr.kur_cd
					AND kr.is_del = ''0''
					LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd = bd.bed_cd
					AND bd.is_del = ''0''
					AND bd.is_disp = ''1''
					LEFT OUTER JOIN mst_medicate_timing mt ON to_number( medi ->> ''timing_cd'', ''9999999999'' ) = mt.medicate_timing_cd
					AND mt.is_del = ''0''
					AND mt.is_disp = ''1''
					LEFT OUTER JOIN mst_procedure mp ON to_number( medi ->> ''procedure_cd'', ''9999999999'' ) = mp.procedure_cd
					AND mp.is_del = ''0''
					AND mp.is_disp = ''1''
				WHERE
					( om.medicine_type = ''1'' AND md.class_cd IN ( @medIds ) ) UNION ALL--投薬(調製薬剤)
				SELECT
					2 AS disp_order,
					NULL AS equipment_cd,
					NULL AS equipment_class_cd,
					mdx.medicine_mix_cd :: TEXT AS medicine_cd,
					mdc.class_cd :: TEXT AS medicine_class_cd,
					om.treat_date,
					kr.kur_cd,
					kr.kur_name,
					COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
					om.ind_bed_cd AS bed_cd,
					om.pat_id,
					COALESCE ( mdc.class_name, '''' ) AS kind,
					mdx.medicine_mix_name AS NAME,
					to_number( om.amount, ''9999999999.999'' ) AS Amount,
					COALESCE ( mdx.unit, '''' ) AS Unit,
					NULL AS function_class,
					NULL AS area,
					NULL AS ufr,
					NULL AS koa,
					NULL AS material,
					NULL AS wetdry,
					''投与薬剤'' AS class_name,
					NULL AS Anticoagulant_name,
					om.ord_no,
					mdx.in_hospital_cd_1,
					mdx.in_hospital_cd_2,
					NULL AS equip_circuit,
					NULL AS cond_ac_shot,
					NULL AS cond_ac_spd,
					NULL AS cond_ac_dur_total,
					NULL AS cond_ip_use,
					NULL AS cond_ip_start,
					NULL AS cond_ip_spd,
					NULL AS cond_ip_shot_st,
					NULL AS cond_ip_shot,
					NULL AS cond_ip_off,
					NULL AS cond_ip_off_tm,
					NULL AS cond_ip_ok,
					NULL AS cond_ip_ok_tm,
					NULL AS cond_dl_fl,
					NULL AS cond_dl_am,
					NULL AS cond_dl_temp,
					NULL AS cond_rl_am,
					NULL AS cond_rl_sel,
					NULL AS cond_rl_use,
					NULL AS cond_rl_temp,
					NULL AS cond_rl_spd,
					mt.medicate_timing_name AS medi_timing,
					mp.pricedure_name AS medi_proc,
					to_number( om.amount, ''9999999999.999'' ) || COALESCE ( mdx.unit, '''' ) AS num_unit,
					NULL AS cond_va_dir,
					NULL AS cond_va,
					NULL AS equip_pnc_cls,
					''Medicine'' AS class_ename
				FROM
					ord_medi AS om
					LEFT OUTER JOIN (
					SELECT
						medicine_mix_cd,
						info ->> ''cd'' AS cd,
						info ->> ''amount'' AS amount,
						unit AS unit,
						medicine_mix_name,
						in_hospital_cd_1,
						in_hospital_cd_2
					FROM
						mst_medicine_mix
						CROSS JOIN LATERAL json_array_elements ( mst_medicine_mix.mix_info :: json ) info
					WHERE
						mst_medicine_mix.is_del = ''0''
						AND mst_medicine_mix.is_disp = ''1''
						AND mst_medicine_mix.class_cd IN ( @medIds )
					) mdx ON om.cd = mdx.medicine_mix_cd
					LEFT OUTER JOIN mst_medicine_class mdc ON to_number( mdx.cd, ''9999999999'' ) = mdc.class_cd
					AND mdc.is_del = ''0''
					AND mdc.is_disp = ''1''
					LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd = kr.kur_cd
					AND kr.is_del = ''0''
					LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd = bd.bed_cd
					AND bd.is_del = ''0''
					AND bd.is_disp = ''1''
					LEFT OUTER JOIN mst_medicate_timing mt ON to_number( medi ->> ''timing_cd'', ''9999999999'' ) = mt.medicate_timing_cd
					AND mt.is_del = ''0''
					AND mt.is_disp = ''1''
					LEFT OUTER JOIN mst_procedure mp ON to_number( medi ->> ''procedure_cd'', ''9999999999'' ) = mp.procedure_cd
					AND mp.is_del = ''0''
					AND mp.is_disp = ''1''
				WHERE
					om.medicine_type = ''2'' UNION ALL--医材
				SELECT
					12 AS disp_order,
					eq.equipment_cd AS equipment_cd,
					eqc.class_cd AS equipment_class_cd,
					NULL AS medicine_cd,
					NULL AS medicine_class_cd,
					om.treat_date,
					kr.kur_cd,
					kr.kur_name,
					COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
					om.ind_bed_cd AS bed_cd,
					om.pat_id,
					COALESCE ( eqc.class_name, '''' ) AS kind,
					eq.equipment_name AS NAME,
					( TO_NUMBER( eqi ->> ''amount'', ''99999999.99'' ) ) AS Amount,
					COALESCE ( eq.unit, '''' ) AS Unit,
					NULL AS function_class,
					NULL AS area,
					NULL AS ufr,
					NULL AS koa,
					NULL AS material,
					NULL AS wetdry,
					''Equip'' AS class_name,
					NULL AS Anticoagulant_name,
					om.ord_no,
					eq.in_hospital_cd_1,
					eq.in_hospital_cd_2,
					NULL AS equip_circuit,
					NULL AS cond_ac_shot,
					NULL AS cond_ac_spd,
					NULL AS cond_ac_dur_total,
					NULL AS cond_ip_use,
					NULL AS cond_ip_start,
					NULL AS cond_ip_spd,
					NULL AS cond_ip_shot_st,
					NULL AS cond_ip_shot,
					NULL AS cond_ip_off,
					NULL AS cond_ip_off_tm,
					NULL AS cond_ip_ok,
					NULL AS cond_ip_ok_tm,
					NULL AS cond_dl_fl,
					NULL AS cond_dl_am,
					NULL AS cond_dl_temp,
					NULL AS cond_rl_am,
					NULL AS cond_rl_sel,
					NULL AS cond_rl_use,
					NULL AS cond_rl_temp,
					NULL AS cond_rl_spd,
					NULL AS medi_timing,
					NULL AS medi_proc,
					concat ( eqi ->> ''amount'', eq.unit ) AS num_unit,
					NULL AS cond_va_dir,
					NULL AS cond_va,
					NULL AS equip_pnc_cls,
					''Equip'' AS class_ename
				FROM
					ord_main AS om
					CROSS JOIN LATERAL json_array_elements ( om.ind_equip_info :: json ) eqi
					LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER( eqi ->> ''cd'', ''9999999999'' ) = eq.equipment_cd
					AND eq.is_del = ''0''
					AND eq.is_disp = ''1''
					LEFT OUTER JOIN mst_equipment_class eqc ON eq.class_cd = eqc.class_cd
					AND eqc.is_del = ''0''
					AND eqc.is_disp = ''1''
					LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd = kr.kur_cd
					AND kr.is_del = ''0''
					LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd = bd.bed_cd
					AND bd.is_del = ''0''
					AND bd.is_disp = ''1''
				WHERE
					om.ord_no IN ( @ordNos )
					AND om.is_del = ''0''
					AND eq.class_cd IN ( @eqIds )
				) AS EquipmentList
				INNER JOIN plan_time ON EquipmentList.ord_no = plan_time.ord_no
			) (SELECT
			bd.treat_date,
			bd.equipment_cd,
			bd.equipment_class_cd,
			bd.medicine_cd,
			bd.medicine_class_cd,
			bd.kur_cd,
			bd.kur_name,
			bd.bed_name,
			bd.bed_cd,
			bd.pat_id,
			bd.kind,
			bd.NAME,
			bd.amount,
			bd.unit,
			bd.function_class,
			bd.area,
			bd.ufr,
			bd.koa,
			bd.material,
			bd.wetdry,
			bd.disp_order,
			bd.class_name,
			bd.class_ename,
			bd.anticoagulant_name,
			bd.plan_time,
			bd.cond_dw,
			bd.cond_tg_wei,
			bd.cond_tre_nm,
			bd.cond_bld_fl,
			bd.in_hospital_cd_1,
			bd.in_hospital_cd_2,
			bd.equip_circuit,
			bd.cond_ac_shot,
			bd.cond_ac_spd,
			bd.cond_ac_dur_total,
			bd.cond_ip_use,
			bd.cond_ip_start,
			bd.cond_ip_spd,
			bd.cond_ip_shot_st,
			bd.cond_ip_shot,
			bd.cond_ip_off,
			bd.cond_ip_off_tm,
			bd.cond_ip_ok,
			bd.cond_ip_ok_tm,
			bd.cond_dl_fl,
			bd.cond_dl_am,
			bd.cond_dl_temp,
			bd.cond_rl_am,
			bd.cond_rl_sel,
			bd.cond_rl_use,
			bd.cond_rl_temp,
			bd.cond_rl_spd,
			bd.medi_timing,
			bd.medi_proc,
			bd.num_unit,
			bd.cond_va_dir,
			bd.cond_va,
			bd.equip_pnc_cls,
		CASE

				WHEN COUNT ( DISTINCT rbg1.room_bed_group_name ) = 0 THEN
				''グループ未登録''
				WHEN COUNT ( DISTINCT rbg1.room_bed_group_name ) = 1 THEN
				( MAX ( rbg1.room_bed_group_name ) ) ELSE''グループ複数選択''
			END AS room_bed_group_name_1,
		CASE

				WHEN COUNT ( DISTINCT rbg2.room_bed_group_name ) = 0 THEN
				''グループ未登録''
				WHEN COUNT ( DISTINCT rbg2.room_bed_group_name ) = 1 THEN
				( MAX ( rbg2.room_bed_group_name ) ) ELSE''グループ複数選択''
			END AS room_bed_group_name_2,
			NULL AS label_print,
			NULL AS is_in_hospital,
		medi.medi_order,
		equi.equi_order,
		bed.bed_order,
		medic.medic_order,
		equic.equic_order,
		MIN(rb1.room_bed_order) AS room_bed_group,
		MIN(rb2.room_bed_order) AS dialysis_room_group
		FROM
			EquipmentList_Tmp AS bd
			LEFT OUTER JOIN medi ON medi.medi_code :: TEXT = bd.medicine_cd
			LEFT OUTER JOIN medic ON medic.medic_code :: TEXT = bd.medicine_class_cd
			LEFT OUTER JOIN equi ON equi.equi_code = bd.equipment_cd
			LEFT OUTER JOIN equic ON equic.equic_code = bd.equipment_class_cd
			LEFT OUTER JOIN bed ON bed.bed_code = bd.bed_cd -- ベッドグループ
			LEFT OUTER JOIN mst_room_bed_group_1 AS rbg1 ON rbg1.bed_list :: TEXT LIKE''%'' || bd.bed_cd || ''%''
			LEFT OUTER JOIN room_bed AS rb1 ON rbg1.room_bed_group_cd = rb1.room_bed_code
			-- 透析室
			LEFT OUTER JOIN mst_room_bed_group_2 AS rbg2 ON rbg2.bed_list :: TEXT LIKE''%'' || bd.bed_cd || ''%''
			LEFT OUTER JOIN room_bed AS rb2 ON rbg2.room_bed_group_cd = rb2.room_bed_code
		GROUP BY
			bd.equipment_cd,
			bd.equipment_class_cd,
			bd.medicine_cd,
			bd.medicine_class_cd,
			bd.treat_date,
			bd.kur_cd,
			bd.kur_name,
			bd.bed_name,
			bd.bed_cd,
			bd.pat_id,
			bd.kind,
			bd.NAME,
			bd.amount,
			bd.unit,
			bd.function_class,
			bd.area,
			bd.ufr,
			bd.koa,
			bd.material,
			bd.wetdry,
			bd.disp_order,
			bd.class_name,
			bd.class_ename,
			bd.anticoagulant_name,
			bd.plan_time,
			bd.cond_dw,
			bd.cond_tg_wei,
			bd.cond_tre_nm,
			bd.cond_bld_fl,
			bd.in_hospital_cd_1,
			bd.in_hospital_cd_2,
			bd.equip_circuit,
			bd.cond_ac_shot,
			bd.cond_ac_spd,
			bd.cond_ac_dur_total,
			bd.cond_ip_use,
			bd.cond_ip_start,
			bd.cond_ip_spd,
			bd.cond_ip_shot_st,
			bd.cond_ip_shot,
			bd.cond_ip_off,
			bd.cond_ip_off_tm,
			bd.cond_ip_ok,
			bd.cond_ip_ok_tm,
			bd.cond_dl_fl,
			bd.cond_dl_am,
			bd.cond_dl_temp,
			bd.cond_rl_am,
			bd.cond_rl_sel,
			bd.cond_rl_use,
			bd.cond_rl_temp,
			bd.cond_rl_spd,
			bd.medi_timing,
			bd.medi_proc,
			bd.num_unit,
			bd.cond_va_dir,
			bd.cond_va,
			bd.equip_pnc_cls,
			medi.medi_order,
			equi.equi_order,
			bed.bed_order,
			medic.medic_order,
			equic.equic_order
		ORDER BY
			disp_order,
			medi.medi_order,
			equi.equi_order,
			bed.bed_order,
			medic.medic_order,
			equic.equic_order)
			UNION ALL--採血管
		(SELECT NULL AS
			treat_date,
			NULL AS equipment_cd,
			NULL AS equipment_class_cd,
			NULL AS medicine_cd,
			NULL AS medicine_class_cd,
			0 AS kur_cd,
			NULL AS kur_name,
			NULL AS bed_name,
			NULL AS bed_cd,
			P.pat_id,
			NULL AS kind,
			spitz.spitz_name AS NAME,
			NULL AS amount,
			NULL AS unit,
			NULL AS function_class,
			NULL AS area,
			NULL AS ufr,
			NULL AS koa,
			NULL AS material,
			NULL AS wetdry,
			4 AS disp_order,
			P.reg_order_class AS class_name,
			NULL AS class_ename,
			NULL AS anticoagulant_name,
			NULL AS plan_time,
			NULL AS cond_dw,
			NULL AS cond_tg_wei,
			NULL AS cond_tre_nm,
			NULL AS cond_bld_fl,
			NULL AS in_hospital_cd_1,
			NULL AS in_hospital_cd_2,
			NULL AS equip_circuit,
			NULL AS cond_ac_shot,
			NULL AS cond_ac_spd,
			NULL AS cond_ac_dur_total,
			NULL AS cond_ip_use,
			NULL AS cond_ip_start,
			NULL AS cond_ip_spd,
			NULL AS cond_ip_shot_st,
			NULL AS cond_ip_shot,
			NULL AS cond_ip_off,
			NULL AS cond_ip_off_tm,
			NULL AS cond_ip_ok,
			NULL AS cond_ip_ok_tm,
			NULL AS cond_dl_fl,
			NULL AS cond_dl_am,
			NULL AS cond_dl_temp,
			NULL AS cond_rl_am,
			NULL AS cond_rl_sel,
			NULL AS cond_rl_use,
			NULL AS cond_rl_temp,
			NULL AS cond_rl_spd,
			NULL AS medi_timing,
			NULL AS medi_proc,
			NULL AS num_unit,
			NULL AS cond_va_dir,
			NULL AS cond_va,
			NULL AS equip_pnc_cls,
			NULL AS room_bed_group_name_1,
			NULL AS room_bed_group_name_2,
			spitz.label_print AS label_print,
			spitz.is_in_hospital AS is_in_hospital ,
			NULL AS medi_order,
			NULL AS equi_order,
			NULL AS bed_order,
			NULL AS medic_order,
			NULL AS equic_order,
		  NULL AS room_bed_order1,
		  NULL AS room_bed_order2
		FROM
			(
			SELECT M
				.*
			FROM
				pat_exam_main AS M
			WHERE
				M.is_del = ''0''
				AND jsonb_array_length ( M.order_exam_set_info ) > 0
				AND M.pat_id IN ( @patIds )
				AND M.reg_exam_date BETWEEN date_trunc( ''day'',  @treatDate :: TIMESTAMP )
				AND date_trunc( ''day'',  @treatDate :: TIMESTAMP ) + ''1 days - 1 milliseconds''
			ORDER BY
				M.reg_exam_date
			)
			P CROSS JOIN LATERAL json_array_elements ( P.order_label_info :: json ) info
			LEFT OUTER JOIN mst_spitz AS spitz ON info ->> ''spitz_cd'' = spitz.spitz_cd :: TEXT
			AND spitz.is_del = ''0''
			AND spitz.is_disp = ''1''
		WHERE
			spitz.spitz_name IS NOT NULL
		ORDER BY
			disp_order,
			kur_cd,
		kur_name,
	bed_name)', 2, '[{"preview": "午後", "can_calc": "", "data_code": "kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "透析予定", "field_name": "kur_name", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": ""}, {"preview": "北1", "can_calc": "", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "透析予定", "field_name": "bed_name", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": ""}, {"preview": "70%ブドウ糖注射液350ml", "can_calc": "0", "data_code": "name", "data_name": "名称/採血管名", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "name", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20200101", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "透析予定", "field_name": "treat_date", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "disp_order", "data_name": "分類", "data_type": "Integer", "conv_table": [], "data_class": "", "field_name": "disp_order", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "class_name", "data_name": "分類/検査区分", "data_type": "String", "conv_table": [{"code": "0", "disp": "その他", "item": "その他"}, {"code": "1", "disp": "透析前", "item": "透析前"}, {"code": "2", "disp": "透析後", "item": "透析後"}], "data_class": "物品情報", "field_name": "class_name", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "plan_time", "data_name": "透析時間", "data_type": "String", "conv_table": [], "data_class": "物品情報", "field_name": "plan_time", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_dw", "data_name": "DW", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_dw", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_tg_wei", "data_name": "目標体重", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_tg_wei", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_tre_nm", "data_name": "治療項目", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_tre_nm", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_bld_fl", "data_name": "血流量", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_bld_fl", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "function_class", "data_name": "機能分類", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "function_class", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "area", "data_name": "面積", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "area", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "ufr", "data_name": "UFR", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "ufr", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "koa", "data_name": "KOA", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "koa", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "material", "data_name": "材質", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "material", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "wetdry", "data_name": "DRYWET", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "wetdry", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "anticoagulant_name", "data_name": "抗凝固剤", "data_type": "String", "conv_table": [], "data_class": "", "field_name": "anticoagulant_name", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "equip_circuit", "data_name": "血液回路", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "equip_circuit", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ac_shot", "data_name": "ワンショット量", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_ac_shot", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ac_spd", "data_name": "持続速度", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_ac_spd", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ac_dur_total", "data_name": "持続総量", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_ac_dur_total", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_use", "data_name": "IP使用選択", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_ip_use", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_start", "data_name": "IPスタート", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_start", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_spd", "data_name": "IP速度", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_spd", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_shot_st", "data_name": "自動ワンショット", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_shot_st", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_shot", "data_name": "IPワンショット量", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_shot", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_off", "data_name": "IP電源自動切り", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_off", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_off_tm", "data_name": "IP電源自動切り時間", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_off_tm", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_ok", "data_name": "IP電源OKモニタ切り", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_ok", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_ok_tm", "data_name": "IP電源OKモニタ切り時間", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_ok_tm", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_dl_fl", "data_name": "透析液流量", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_dl_fl", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_dl_am", "data_name": "透析液量", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_dl_am", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_dl_temp", "data_name": "透析温度", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_dl_temp", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_rl_am", "data_name": "補液量", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_rl_am", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_rl_sel", "data_name": "補液選択", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_rl_sel", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_rl_use", "data_name": "補液使用数", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_rl_use", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_rl_temp", "data_name": "補液温度", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_rl_temp", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_rl_spd", "data_name": "補液速度", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_rl_spd", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "medi_timing", "data_name": "投与時間帯", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "medi_timing", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "medi_proc", "data_name": "手技", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "medi_proc", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "1", "can_calc": "0", "data_code": "num_unit", "data_name": "数量・単位", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "num_unit", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_va_dir", "data_name": "VA方向", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_va_dir", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_va", "data_name": "VA", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_va", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "equip_pnc_cls", "data_name": "穿刺針区分", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "equip_pnc_cls", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_1", "data_name": "院内コード", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_1", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_2", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "ベッドグループ1", "can_calc": "", "data_code": "room_bed_group_name_1", "data_name": "ベッドグループ名", "data_type": "string", "conv_table": [], "data_class": "透析予定", "field_name": "room_bed_group_name_1", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": ""}, {"preview": "透析室名１", "can_calc": "", "data_code": "room_bed_group_name_2", "data_name": "透析室名", "data_type": "string", "conv_table": [], "data_class": "透析予定", "field_name": "room_bed_group_name_2", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": ""}, {"preview": "ラベル印字項目", "can_calc": "0", "data_code": "label_print", "data_name": "ラベル印字項目(採血管)", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "label_print", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": "0"}, {"preview": "院内・院外", "can_calc": "0", "data_code": "is_in_hospital", "data_name": "院内・院外(採血管)", "data_type": "string", "conv_table": [{"code": "0", "disp": "院内", "item": "院内"}, {"code": "1", "disp": "院外", "item": "院外"}], "data_class": "物品情報", "field_name": "is_in_hospital", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [8]}', 'ラベル', '2020-03-17 14:17:00', CURRENT_TIMESTAMP, NULL);
DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (31);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (31, 'with  pat_facility as (
   select facility_cd    
   from
    pat_exam_main
   where  
     pat_id =  @patId limit 1
),
infection_order AS (

  select
    one_json ->> ''code'' as infection_cd
    , json_idx as infection_cd_order 
from
    mst_selector 
    cross join lateral jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(one_json, json_idx)
where
    facility_cd =  (select facility_cd from pat_facility )
    and master_physical_name = ''mst_exam_item''
)
select
  info->>''item_cd'' as item_cd,
  item.in_hospital_cd1 as in_hospital_cd1,
  item.in_hospital_cd2 as in_hospital_cd2,
  item.in_hospital_cd3 as in_hospital_cd3,
  item.sbt_cd1 as sbt_cd1,
  item.sbt_cd2 as sbt_cd2,
  item.sbt_cd3 as sbt_cd3,
  info->>''item_name'' as item_name,
  info->>''result'' as result,
  info->>''unit'' as unit,
  info->>''freememo'' as freememo,
  p.result_exam_date as result_exam_date,
  p.reg_exam_date,
  p.reg_order_class,
  info->>''upper'' as upper,
  info->>''lower'' as lower 
from (
  select
    m.*
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
    and m.exam_status = ''1''
    and m.pat_id = @patId
    and m.result_exam_date < date_trunc(''day'', @date ::timestamp) + ''1 days''
    and m.result_exam_date >= (date_trunc(''day'', @date ::timestamp) - interval ''1 year'')
    order by m.result_exam_date desc
  ) as p
  cross join lateral
    json_array_elements (p.exam_result_info :: json) info
  left outer join
    mst_exam_item as item on info->>''item_cd'' = (item.exam_item_cd || '''')  and item.is_del = ''0'' and item.is_disp =''1''
	left  join  infection_order as inf  on  info->>''item_cd''=inf.infection_cd
	ORDER BY  
  infection_cd_order,reg_exam_date 
  limit 100
;', 2, '[{"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "in_hospital_cd1", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4567", "can_calc": "0", "data_code": "in_hospital_cd2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "in_hospital_cd2", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7890", "can_calc": "0", "data_code": "in_hospital_cd3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "in_hospital_cd3", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0123", "can_calc": "0", "data_code": "sbt_cd1", "data_name": "属性コード1", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "sbt_cd1", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3456", "can_calc": "0", "data_code": "sbt_cd2", "data_name": "属性コード2", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "sbt_cd2", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6789", "can_calc": "0", "data_code": "sbt_cd3", "data_name": "属性コード3", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "sbt_cd3", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査項目テスト", "can_calc": "0", "data_code": "item_name", "data_name": "検査項目名", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "item_name", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "11.2", "can_calc": "0", "data_code": "result", "data_name": "検査結果", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "result", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mg/dL", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "unit", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "検査結果のテストです。", "can_calc": "0", "data_code": "freememo", "data_name": "検査コメント", "data_type": "string", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "freememo", "disp_format": "", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/12", "can_calc": "0", "data_code": "result_exam_date", "data_name": "検査日", "data_type": "DateTime", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "result_exam_date", "disp_format": "yyyy/mm/dd", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析前", "can_calc": "0", "data_code": "reg_order_class", "data_name": "検査区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "その他", "item": "その他"}, {"code": "1", "disp": "透析前", "item": "透析前"}, {"code": "2", "disp": "透析後", "item": "透析後"}], "data_class": "検査結果(指定日以前)", "field_name": "reg_order_class", "disp_format": "", "filter_type": "ExamNull", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15.0", "can_calc": "0", "data_code": "upper", "data_name": "正常値上限", "data_type": "decimal", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "upper", "disp_format": "0.0", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "0", "data_code": "lower", "data_name": "正常値下限", "data_type": "decimal", "conv_table": [], "data_class": "検査結果(指定日以前)", "field_name": "lower", "disp_format": "0.0", "filter_type": "Examin", "data_category": "検査", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '検査結果(指定日以前) @patId @date 使用', '2020-03-25 18:00:00', CURRENT_TIMESTAMP, NULL);
delete from ntss.sys_data_set where sql_cd = '141';
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (141, 'select a.f_medi_cd,a.medicine_name as f_medi_name,a.f_medi_amount,a.medicine_unit as f_medicine_unit,array_agg(a.f_week) as f_week from (
select
		weekmedi_info.cd as f_medi_cd,
    mmd.medicine_name as medicine_name,
	  weekmedi_info.amount as f_medi_amount,
    mmd.unit as medicine_unit,
    weekmedi_info.week as f_week
from
(select
    distinct
    medi ->> ''cd''  as cd,
    to_number(medi ->>''amount'',''9999999.9999'') as amount,
		medi ->> ''medicine_type'' as medicine_type,
    medi ->> ''unit'' as unit,
    medi ->> ''no''  as medi_no,
    case ord.treat_week
        when 1 then ''月''
        when 2 then ''火''
        when 3 then ''水''
        when 4 then ''木''
        when 5 then ''金''
        when 6 then ''土''
        when 7 then ''日''
        else  ''未''
    end as week
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.ind_medi_info :: json) medi
    where
      ord.facility_cd = @facilityCd
 and 
      ord.treat_date between to_char(date_trunc(''day'', ( @fromDate

 )::timestamp), ''yyyymmdd'') and to_char(date_trunc(''day'', ( @toDate

 )::timestamp) + ''1 days - 1 milliseconds'', ''yyyymmdd'') and 
      ord.pat_id = @patId

 and 
      ord.is_del = ''0''
    order by medi_no,cd,amount,unit,week) as weekmedi_info
    inner join
      mst_medicine as mmd
    on
      mmd.medicine_cd = TO_NUMBER (weekmedi_info.cd,''999999999999'') AND mmd.class_cd IN ( @medIds
 )  where  weekmedi_info.medicine_type = ''1''
 UNION ALL
 select
		weekmedi_info.cd as f_medi_cd,
    mix.medicine_mix_name as medicine_name,
	  weekmedi_info.amount as f_medi_amount,
		mix.unit as medicine_unit,
   weekmedi_info.week as f_week
from
(select
    distinct
    medi ->> ''cd''  as cd,
    to_number(medi ->>''amount'',''9999999.9999'') as amount,
		medi ->> ''medicine_type'' as medicine_type,
    medi ->> ''unit'' as unit,
    medi ->> ''no''  as medi_no,
    case ord.treat_week
        when 1 then ''月''
        when 2 then ''火''
        when 3 then ''水''
        when 4 then ''木''
        when 5 then ''金''
        when 6 then ''土''
        when 7 then ''日''
        else  ''未''
    end as week
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.ind_medi_info :: json) medi
    where
      ord.facility_cd = @facilityCd
 and 
      ord.treat_date between to_char(date_trunc(''day'', ( @fromDate

 )::timestamp), ''yyyymmdd'') and to_char(date_trunc(''day'', ( @toDate

 )::timestamp) + ''1 days - 1 milliseconds'', ''yyyymmdd'') and 
      ord.pat_id = @patId

 and 
      ord.is_del = ''0''
    order by medi_no,cd,amount,unit,week) as weekmedi_info
    inner join
      mst_medicine_mix as mix
    on
      mix.medicine_mix_cd = TO_NUMBER (weekmedi_info.cd,''999999999999'') AND mix.class_cd IN ( @medIds
 )  where  weekmedi_info.medicine_type = ''2''
 )  a
      group by a.f_medi_cd,a.medicine_name,a.f_medi_amount,a.medicine_unit', 2, '[{"preview": "1", "can_calc": "0", "data_code": "f_medi_cd", "data_name": "薬剤(調整薬剤)コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬(未来有効）", "field_name": "f_medi_cd", "disp_format": "", "filter_type": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト薬剤１", "can_calc": "0", "data_code": "f_medi_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬(未来有効）", "field_name": "f_medi_name", "disp_format": "", "filter_type": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "f_medi_amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "投薬(未来有効）", "field_name": "f_medi_amount", "disp_format": "0", "filter_type": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "f_medicine_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "投薬(未来有効）", "field_name": "f_medicine_unit", "disp_format": "", "filter_type": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "火,水,木", "can_calc": "0", "data_code": "f_week", "data_name": "指示曜日", "data_type": "string", "conv_table": [], "data_class": "投薬(未来有効）", "field_name": "f_week", "disp_format": "", "filter_type": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 9, 10]}', '紹介状　指示：投薬(未来有効）　@facilityCd@patId@fromdate@todate使用', '2021-03-31 14:09:45', CURRENT_TIMESTAMP, '[]');
DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (13);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (13, 'select 
    (pat_memo_info->>0)::json->>''title'' as memo01_title,
    (pat_memo_info->>0)::json->>''content'' as memo01_content,
    (pat_memo_info->>1)::json->>''title'' as memo02_title,
    (pat_memo_info->>1)::json->>''content'' as memo02_content,
    (pat_memo_info->>2)::json->>''title'' as memo03_title,
    (pat_memo_info->>2)::json->>''content'' as memo03_content,
    (pat_memo_info->>3)::json->>''title'' as memo04_title,
    (pat_memo_info->>3)::json->>''content'' as memo04_content,
    (pat_memo_info->>4)::json->>''title'' as memo05_title,
    (pat_memo_info->>4)::json->>''content'' as memo05_content,
    (pat_memo_info->>5)::json->>''title'' as memo06_title,
    (pat_memo_info->>5)::json->>''content'' as memo06_content,
    (pat_memo_info->>6)::json->>''title'' as memo07_title,
    (pat_memo_info->>6)::json->>''content'' as memo07_content,
    (pat_memo_info->>7)::json->>''title'' as memo08_title,
    (pat_memo_info->>7)::json->>''content'' as memo08_content,
    (pat_memo_info->>8)::json->>''title'' as memo09_title,
    (pat_memo_info->>8)::json->>''content'' as memo09_content,
    (pat_memo_info->>9)::json->>''title'' as memo10_title,
    (pat_memo_info->>9)::json->>''content'' as memo10_content,
    (pat_memo_info->>10)::json->>''title'' as memo11_title,
    (pat_memo_info->>10)::json->>''content'' as memo11_content,
    (pat_memo_info->>11)::json->>''title'' as memo12_title,
    (pat_memo_info->>11)::json->>''content'' as memo12_content,
    (pat_memo_info->>12)::json->>''title'' as memo13_title,
    (pat_memo_info->>12)::json->>''content'' as memo13_content,
    (pat_memo_info->>13)::json->>''title'' as memo14_title,
    (pat_memo_info->>13)::json->>''content'' as memo14_content,
    (pat_memo_info->>14)::json->>''title'' as memo15_title,
    (pat_memo_info->>14)::json->>''content'' as memo15_content,
    (pat_memo_info->>15)::json->>''title'' as memo16_title,
    (pat_memo_info->>15)::json->>''content'' as memo16_content,
    (pat_memo_info->>16)::json->>''title'' as memo17_title,
    (pat_memo_info->>16)::json->>''content'' as memo17_content,
    (pat_memo_info->>17)::json->>''title'' as memo18_title,
    (pat_memo_info->>17)::json->>''content'' as memo18_content,
    (pat_memo_info->>18)::json->>''title'' as memo19_title,
    (pat_memo_info->>18)::json->>''content'' as memo19_content,
    (pat_memo_info->>19)::json->>''title'' as memo20_title,
    (pat_memo_info->>19)::json->>''content'' as memo20_content
from pat_main as pm
where pm.is_del=''0'' and pm.pat_id=@patId', 2, '[{"preview": "", "can_calc": "1", "data_code": "memo01_title", "data_name": "タイトル1", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo01_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "memo01_content", "data_name": "内容1", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo01_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "memo02_title", "data_name": "タイトル2", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo02_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "memo02_content", "data_name": "内容2", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo02_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "memo03_title", "data_name": "タイトル3", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo03_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "memo03_content", "data_name": "内容3", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo03_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "memo04_title", "data_name": "タイトル4", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo04_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "memo04_content", "data_name": "内容4", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo04_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "memo05_title", "data_name": "タイトル5", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo05_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "memo05_content", "data_name": "内容5", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo05_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "memo06_title", "data_name": "タイトル6", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo06_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "memo06_content", "data_name": "内容6", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo06_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "memo07_title", "data_name": "タイトル7", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo07_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "memo07_content", "data_name": "内容7", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo07_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "memo08_title", "data_name": "タイトル8", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo08_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "memo08_content", "data_name": "内容8", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo08_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "memo09_title", "data_name": "タイトル9", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo09_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "memo09_content", "data_name": "内容9", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo09_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "memo10_title", "data_name": "タイトル10", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo10_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "memo10_content", "data_name": "内容10", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo10_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "memo11_title", "data_name": "タイトル11", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo11_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "memo11_content", "data_name": "内容11", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo11_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "memo12_title", "data_name": "タイトル12", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo12_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "memo12_content", "data_name": "内容12", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo12_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "memo13_title", "data_name": "タイトル13", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo13_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "memo13_content", "data_name": "内容13", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo13_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "memo14_title", "data_name": "タイトル14", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo14_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "memo14_content", "data_name": "内容14", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo14_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "memo15_title", "data_name": "タイトル15", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo15_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "memo15_content", "data_name": "内容15", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo15_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "memo16_title", "data_name": "タイトル16", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo16_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "memo16_content", "data_name": "内容16", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo16_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "memo17_title", "data_name": "タイトル17", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo17_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "memo17_content", "data_name": "内容17", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo17_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "memo18_title", "data_name": "タイトル18", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo18_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "memo18_content", "data_name": "内容18", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo18_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "memo19_title", "data_name": "タイトル19", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo19_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "memo19_content", "data_name": "内容19", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo19_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "memo20_title", "data_name": "タイトル20", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo20_title", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "1", "data_code": "memo20_content", "data_name": "内容20", "data_type": "string", "conv_table": [], "data_class": "患者フリーコメント", "field_name": "memo20_content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '患者情報：患者フリーコメント　@patId使用', '2020-03-04 13:17:00', CURRENT_TIMESTAMP, NULL);
