DELETE FROM ntss.sys_data_set
WHERE sql_cd=95;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(95, 'WITH DATA AS (


	with ord_tbl as (
  select
    facility_cd,
    pat_id,
    rst_bed_cd,
    to_timestamp(treat_date, ''yyyymmdd'') + ''1 days - 1 milliseconds'' as treat_date_end
  from ord_main
  where ord_no = @ordNo
  and is_del = ''0''
), bed_group_tbl AS (
  select
    facility_cd,
    room_bed_group_name as bed_group_name
  from
    mst_room_bed_group
  where
    mst_room_bed_group.bed_list @> (''['' || (select rst_bed_cd from ord_tbl) || '']'')::jsonb
  and
    mst_room_bed_group.group_class = 1
  and mst_room_bed_group.is_del = ''0''
  and mst_room_bed_group.is_disp = ''1''
  group by
    facility_cd, room_bed_group_cd
    limit 1
), room_tbl AS (
  select
    facility_cd,
    room_bed_group_name as room_name
  from
    mst_room_bed_group
  where
    mst_room_bed_group.bed_list @> (''['' || (select rst_bed_cd from ord_tbl) || '']'')::jsonb
  and
    mst_room_bed_group.group_class = 2
  and mst_room_bed_group.is_del = ''0''
  and mst_room_bed_group.is_disp = ''1''
  group by
    facility_cd, room_bed_group_cd
    limit 1
), pat_physical_tbl AS (
-- 指定患者、基準日以前のDWがある身体情報を取得
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
      (select * from pat_unique where is_del = ''0'') as pat_unique
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
), pat_wheel_chair_tbl AS (
-- 指定患者の車いす情報を取得
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
),equipment_tbl as (
  select
    *
  from
    mst_equipment
  where
    mst_equipment.facility_cd = (select facility_cd from ord_tbl)
  and
    mst_equipment.is_disp = ''1''
  and
    mst_equipment.is_del = ''0''
-- 指定患者、基準日以前のDWがある身体情報を取得
),oms_puncture_needle_a_tbl as (
	SELECT
		*
	FROM
		ord_material_save oms
	WHERE
		oms.supplies_base_no = @ordNo
		AND supplies_source_class = ''0''
		AND supplies_class = ''06''
		AND ind_rst_class=''2''

),oms_puncture_needle_v_tbl as (
	SELECT
		*
	FROM
		ord_material_save oms
	WHERE
		oms.supplies_base_no = @ordNo
		AND supplies_source_class = ''0''
		AND supplies_class = ''07''
		AND ind_rst_class=''2''

),oms_puncture_needle_sn_tbl as (
	SELECT
		*
	FROM
		ord_material_save oms
	WHERE
		oms.supplies_base_no = @ordNo
		AND supplies_source_class = ''0''
		AND supplies_class = ''05''
		AND ind_rst_class=''2''

),oms_blood_circuit_tbl as (
	SELECT
		*
	FROM
		ord_material_save oms
	WHERE
		oms.supplies_base_no = @ordNo
		AND supplies_source_class = ''0''
		AND supplies_class = ''00''
		AND ind_rst_class=''2''

)
select
	ord.ord_no as ord_no,
  to_date(ord.treat_date, ''yyyymmdd'') as treat_date,
  ord.rst_kur_cd as kur_cd,

  ord.rst_treatment_cd as treatment_cd,
  to_char(ord.rst_start_date, ''HH24:MI'') as treat_start_time,

  to_char(ord.rst_end_date, ''HH24:MI'') as treat_end_time,

  ord.rst_bed_cd as bed_cd,

  ord.rst_cond_info->''1''->>''value'' as treatment_time,
  --ord.rst_cond_info->''2''->>''value_name_1'' as va,
  ord.rst_cond_info->''4''->>''value'' as water_removal_amount_limit,
  ord.rst_cond_info->''12''->>''value'' as single_needle,
  ord.rst_cond_info->''14''->>''value'' as blood_flow,
  ord.rst_cond_info->''16''->>''value'' as dialysate_flow_rate,
  ord.rst_cond_info->''17''->>''value'' as dialysate_amount,
  ord.rst_cond_info->''18''->>''value'' as dialysate_temperature,
  ord.rst_cond_info->''20''->>''value'' as fluid_replacement_amount,
  ord.rst_cond_info->''21''->>''value'' as fluid_replacement_timing,
  ord.rst_cond_info->''22''->>''value'' as fluid_replacement_use_count,
  ord.rst_cond_info->''23''->>''value'' as fluid_replacement_temperature,
  ord.rst_cond_info->''24''->>''value'' as fluid_replacement_speed,
  ord.rst_cond_info->''26''->>''value'' as anti_coagulant_one_shot_amount,
  ord.rst_cond_info->''27''->>''value'' as anti_coagulant_sustained_speed,
  ord.rst_cond_info->''27''->>''unit'' as anti_coagulant_sustained_speed_unit,
  ord.rst_cond_info->''28''->>''value'' as anti_coagulant_sustained_amount,
  ord.rst_cond_info->''29''->>''value'' as ip,
  ord.rst_cond_info->''30''->>''value'' as ip_start,
  ord.rst_cond_info->''31''->>''value'' as ip_one_shot_amount,
  ord.rst_cond_info->''32''->>''value'' as ip_speed,
  ord.rst_cond_info->''33''->>''value'' as ip_speed_max,
  ord.rst_cond_info->''34''->>''value'' as auto_one_shot,
  ord.rst_cond_info->''35''->>''value'' as ip_auto_off,
  ord.rst_cond_info->''36''->>''value'' as ip_auto_off_time,
  ord.rst_cond_info->''37''->>''value'' as ip_monitor_auto_off,
  ord.rst_cond_info->''38''->>''value'' as ip_monitor_auto_off_time,
	
	case 
		when ord.rst_device_mode is null then mst_treatment.device_mode
		else ord.rst_device_mode 
	end as device_mode,
	case 	
		when date_trunc(''day'', mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mst_treatment.in_hosp_b_startdate) then mst_treatment.in_hospital_cd_a1 
		when date_trunc(''day'', mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mst_treatment.in_hosp_a_startdate) then mst_treatment.in_hospital_cd_b1 
		when date_trunc(''day'', mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mst_treatment.in_hosp_b_startdate) is null then mst_treatment.in_hospital_cd_a1
		when date_trunc(''day'', mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mst_treatment.in_hosp_a_startdate) is null then mst_treatment.in_hospital_cd_b1
		when date_trunc(''day'', mst_treatment.in_hosp_b_startdate) < date_trunc(''day'', mst_treatment.in_hosp_a_startdate) and date_trunc(''day'', mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then mst_treatment.in_hospital_cd_a1
		when date_trunc(''day'', mst_treatment.in_hosp_a_startdate) < date_trunc(''day'', mst_treatment.in_hosp_b_startdate) and date_trunc(''day'', mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then mst_treatment.in_hospital_cd_b1
		when ord.treat_date :: TIMESTAMP = date_trunc(''day'', mst_treatment.in_hosp_a_startdate) and ord.treat_date :: TIMESTAMP = date_trunc(''day'', mst_treatment.in_hosp_b_startdate) then mst_treatment.in_hospital_cd_a1
		else ''''
	end as treatment_in_hospital_cd_1,	
	case 	
		when date_trunc(''day'', mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mst_treatment.in_hosp_b_startdate) then mst_treatment.in_hospital_cd_a2 
		when date_trunc(''day'', mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mst_treatment.in_hosp_a_startdate) then mst_treatment.in_hospital_cd_b2 
		when date_trunc(''day'', mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mst_treatment.in_hosp_b_startdate) is null then mst_treatment.in_hospital_cd_a2
		when date_trunc(''day'', mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mst_treatment.in_hosp_a_startdate) is null then mst_treatment.in_hospital_cd_b2
		when date_trunc(''day'', mst_treatment.in_hosp_b_startdate) < date_trunc(''day'', mst_treatment.in_hosp_a_startdate) and date_trunc(''day'', mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then mst_treatment.in_hospital_cd_a2
		when date_trunc(''day'', mst_treatment.in_hosp_a_startdate) < date_trunc(''day'', mst_treatment.in_hosp_b_startdate) and date_trunc(''day'', mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then mst_treatment.in_hospital_cd_b2
		when ord.treat_date :: TIMESTAMP = date_trunc(''day'', mst_treatment.in_hosp_a_startdate) and ord.treat_date :: TIMESTAMP = date_trunc(''day'', mst_treatment.in_hosp_b_startdate) then mst_treatment.in_hospital_cd_a2
		else ''''
	end as treatment_in_hospital_cd_2,
	case 	
		when date_trunc(''day'', mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mst_treatment.in_hosp_b_startdate) then mst_treatment.in_hospital_cd_a3 
		when date_trunc(''day'', mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mst_treatment.in_hosp_a_startdate) then mst_treatment.in_hospital_cd_b3 
		when date_trunc(''day'', mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mst_treatment.in_hosp_b_startdate) is null then mst_treatment.in_hospital_cd_a3
		when date_trunc(''day'', mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mst_treatment.in_hosp_a_startdate) is null then mst_treatment.in_hospital_cd_b3
		when date_trunc(''day'', mst_treatment.in_hosp_b_startdate) < date_trunc(''day'', mst_treatment.in_hosp_a_startdate) and date_trunc(''day'', mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then mst_treatment.in_hospital_cd_a3
		when date_trunc(''day'', mst_treatment.in_hosp_a_startdate) < date_trunc(''day'', mst_treatment.in_hosp_b_startdate) and date_trunc(''day'', mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then mst_treatment.in_hospital_cd_b3
		when ord.treat_date :: TIMESTAMP = date_trunc(''day'', mst_treatment.in_hosp_a_startdate) and ord.treat_date :: TIMESTAMP = date_trunc(''day'', mst_treatment.in_hosp_b_startdate) then mst_treatment.in_hospital_cd_a3
		else ''''
	end as treatment_in_hospital_cd_3,
	case 	
		when date_trunc(''day'', mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mst_treatment.in_hosp_b_startdate) then mst_treatment.in_hospital_cd_a4 
		when date_trunc(''day'', mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and ord.treat_date :: TIMESTAMP < date_trunc(''day'', mst_treatment.in_hosp_a_startdate) then mst_treatment.in_hospital_cd_b4 
		when date_trunc(''day'', mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mst_treatment.in_hosp_b_startdate) is null then mst_treatment.in_hospital_cd_a4
		when date_trunc(''day'', mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP and date_trunc(''day'', mst_treatment.in_hosp_a_startdate) is null then mst_treatment.in_hospital_cd_b4
		when date_trunc(''day'', mst_treatment.in_hosp_b_startdate) < date_trunc(''day'', mst_treatment.in_hosp_a_startdate) and date_trunc(''day'', mst_treatment.in_hosp_a_startdate) <= ord.treat_date :: TIMESTAMP then mst_treatment.in_hospital_cd_a4
		when date_trunc(''day'', mst_treatment.in_hosp_a_startdate) < date_trunc(''day'', mst_treatment.in_hosp_b_startdate) and date_trunc(''day'', mst_treatment.in_hosp_b_startdate) <= ord.treat_date :: TIMESTAMP then mst_treatment.in_hospital_cd_b4
		when ord.treat_date :: TIMESTAMP = date_trunc(''day'', mst_treatment.in_hosp_a_startdate) and ord.treat_date :: TIMESTAMP = date_trunc(''day'', mst_treatment.in_hosp_b_startdate) then mst_treatment.in_hospital_cd_a4
		else ''''
	end as treatment_in_hospital_cd_4,	
	

  CAST(ord.rst_cond_info->''26''->>''value'' AS DECIMAL)
    + CAST(ord.rst_cond_info->''28''->>''value'' AS DECIMAL)
    as anti_coagulant_total_amount,

  case
    when ord.rst_cond_info->''31''->>''value'' is not null then ''ml/h''
    else null
  end as ip_one_shot_amount_unit,
  case
    when ord.rst_cond_info->''32''->>''value'' is not null then ''ml/h''
    else null
  end as ip_speed_unit,
  case
    when ord.rst_cond_info->''33''->>''value'' is not null then ''ml''
    else null
  end as ip_speed_max_unit,

  ord.rst_tare_info->>''name_1'' as tare_name1,
  ord.rst_tare_info->>''name_2'' as tare_name2,
  ord.rst_tare_info->>''name_3'' as tare_name3,
  ord.rst_tare_info->>''name_4'' as tare_name4,
  ord.rst_tare_info->>''name_5'' as tare_name5,
  ord.rst_tare_info->>''weight_1'' as tare_weight1,
  ord.rst_tare_info->>''weight_2'' as tare_weight2,
  ord.rst_tare_info->>''weight_3'' as tare_weight3,
  ord.rst_tare_info->>''weight_4'' as tare_weight4,
  ord.rst_tare_info->>''weight_5'' as tare_weight5,
  CAST(ord.rst_tare_info->>''weight_1'' AS DECIMAL)
    + CAST(ord.rst_tare_info->>''weight_2'' AS DECIMAL)
    + CAST(ord.rst_tare_info->>''weight_3'' AS DECIMAL)
    + CAST(ord.rst_tare_info->>''weight_4'' AS DECIMAL)
    + CAST(ord.rst_tare_info->>''weight_5'' AS DECIMAL)
    as tare_weight_total,

  ord.rst_off_water_info->>''name_1'' as off_water_name1,
  ord.rst_off_water_info->>''name_2'' as off_water_name2,
  ord.rst_off_water_info->>''name_3'' as off_water_name3,
  ord.rst_off_water_info->>''name_4'' as off_water_name4,
  ord.rst_off_water_info->>''name_5'' as off_water_name5,
  ord.rst_off_water_info->>''weight_1'' as off_water_weight1,
  ord.rst_off_water_info->>''weight_2'' as off_water_weight2,
  ord.rst_off_water_info->>''weight_3'' as off_water_weight3,
  ord.rst_off_water_info->>''weight_4'' as off_water_weight4,
  ord.rst_off_water_info->>''weight_5'' as off_water_weight5,
  CAST(ord.rst_off_water_info->>''weight_1'' AS DECIMAL)
    + CAST(ord.rst_off_water_info->>''weight_2'' AS DECIMAL)
    + CAST(ord.rst_off_water_info->>''weight_3'' AS DECIMAL)
    + CAST(ord.rst_off_water_info->>''weight_4'' AS DECIMAL)
    + CAST(ord.rst_off_water_info->>''weight_5'' AS DECIMAL)
    as off_water_weight_total,

  case
    when ord.rst_cond_info->''3''->>''value'' = ''-1'' then ''1''
    else ''0''
  end as target_weight_mode,
  case
    when ord.rst_cond_info->''3''->>''value'' = ''-1'' then pat_physical_tbl.dw
    else ord.rst_cond_info->''3''->>''value''
  end as target_weight,


  pat_physical_tbl.pre_scale_upper,
  pat_physical_tbl.pre_scale_lower,

  pat_wheel_chair_tbl.wheel_chair_name,
  pat_wheel_chair_tbl.wheel_chair_weight,

  mst_va.va_name as va_name,
  mst_va.in_hospital_cd_1 as va_in_hospital_cd_1,
  mst_va.in_hospital_cd_2  as va_in_hospital_cd_2,
  mst_va.va_direct as va_direct,


  mst_bed.shunt_position,
  mst_bed.is_infection,
  mst_bed.emergency_class,
  mst_machine.machine_name,

  bed_group_tbl.bed_group_name, -- 実績
  room_tbl.room_name, -- 実績

  mst_dialyzer.model_number as dialyzer_name,
  mst_dialyzer.maker,
  mst_dialyzer.function_class,
  mst_dialyzer.area,
  mst_dialyzer.ufr,
  mst_dialyzer.koa,
  mst_dialyzer.material,
  mst_dialyzer.wetdry,
  mst_dialyzer.sterilization,
  mst_dialyzer.bloodamt,
  mst_dialyzer.alqd_flood_vol,
  mst_dialyzer.urea_clearance,
  mst_dialyzer.gas_purge_time,
  mst_dialyzer.substituent_wash_amt,
  mst_dialyzer.membrane_wash,
  mst_dialyzer.in_hospital_cd_1 as rst_dialyzer_in_hospital_cd_1,
  mst_dialyzer.in_hospital_cd_2 as rst_dialyzer_in_hospital_cd_2,
  mst_dialyzer.in_hospital_cd_3 as rst_dialyzer_in_hospital_cd_3,
  mst_dialyzer.in_hospital_cd_4 as rst_dialyzer_in_hospital_cd_4,

  adsorption_column_tbl.equipment_name as adsorption_column_name,
  adsorption_column_tbl.in_hospital_cd_1 as rst_adsorption_in_hospital_cd_1,
  adsorption_column_tbl.in_hospital_cd_2 as rst_adsorption_in_hospital_cd_2,
  adsorption_column_tbl.in_hospital_cd_3 as rst_adsorption_in_hospital_cd_3,
  adsorption_column_tbl.in_hospital_cd_4 as rst_adsorption_in_hospital_cd_4,

  primary_film_tbl.equipment_name as primary_film_name,
  primary_film_tbl.in_hospital_cd_1 as rst_primary_film_in_hospital_cd_1,
  primary_film_tbl.in_hospital_cd_2 as rst_primary_film_in_hospital_cd_2,
  primary_film_tbl.in_hospital_cd_3 as rst_primary_film_in_hospital_cd_3,
  primary_film_tbl.in_hospital_cd_4 as rst_primary_film_in_hospital_cd_4,

  secondary_film_tbl.equipment_name as secondary_film_name,
  secondary_film_tbl.in_hospital_cd_1 as rst_secondary_film_in_hospital_cd_1,
  secondary_film_tbl.in_hospital_cd_2 as rst_secondary_film_in_hospital_cd_2,
  secondary_film_tbl.in_hospital_cd_3 as rst_secondary_film_in_hospital_cd_3,
  secondary_film_tbl.in_hospital_cd_4 as rst_secondary_film_in_hospital_cd_4,

  puncture_needle_a_tbl.equipment_name as puncture_needle_a_name,
  puncture_needle_a_tbl.in_hospital_cd_1 as rst_pn_a_in_hospital_cd_1,
  puncture_needle_a_tbl.in_hospital_cd_2 as rst_pn_a_in_hospital_cd_2,
  puncture_needle_a_tbl.in_hospital_cd_3 as rst_pn_a_in_hospital_cd_3,
  puncture_needle_a_tbl.in_hospital_cd_4 as rst_pn_a_in_hospital_cd_4,

  puncture_needle_v_tbl.equipment_name as puncture_needle_v_name,
  puncture_needle_v_tbl.in_hospital_cd_1 as rst_pn_v_in_hospital_cd_1,
  puncture_needle_v_tbl.in_hospital_cd_2 as rst_pn_v_in_hospital_cd_2,
  puncture_needle_v_tbl.in_hospital_cd_3 as rst_pn_v_in_hospital_cd_3,
  puncture_needle_v_tbl.in_hospital_cd_4 as rst_pn_v_in_hospital_cd_4,

  puncture_needle_sn_tbl.equipment_name as puncture_needle_s_name,
  puncture_needle_sn_tbl.in_hospital_cd_1 as rst_pn_s_in_hospital_cd_1,
  puncture_needle_sn_tbl.in_hospital_cd_2 as rst_pn_s_in_hospital_cd_2,
  puncture_needle_sn_tbl.in_hospital_cd_3 as rst_pn_s_in_hospital_cd_3,
  puncture_needle_sn_tbl.in_hospital_cd_4 as rst_pn_s_in_hospital_cd_4,

  blood_circuit_tbl.equipment_name as blood_circuit_name,
  blood_circuit_tbl.in_hospital_cd_1 as rst_bc_in_hospital_cd_1,
  blood_circuit_tbl.in_hospital_cd_2 as rst_bc_in_hospital_cd_2,
  blood_circuit_tbl.in_hospital_cd_3 as rst_bc_in_hospital_cd_3,
  blood_circuit_tbl.in_hospital_cd_4 as rst_bc_in_hospital_cd_4,

  case
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then mix_dialysate_tbl.medicine_mix_name
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
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then mix_fluid_replacement_tbl.medicine_mix_name
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
    when ord.rst_cond_info->''25''->>''medicine_type'' = ''2'' then mix_anti_coagulant_tbl.medicine_mix_name
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
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then mix_dialysate_tbl.unit
    else med_dialysate_tbl.unit
  end as dialysate_amount_unit,
  case
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then mix_fluid_replacement_tbl.unit
    else med_fluid_replacement_tbl.unit
  end as fluid_replacement_unit,
  case
    when ord.rst_cond_info->''25''->>''medicine_type'' = ''2'' then mix_anti_coagulant_tbl.unit
    else med_anti_coagulant_tbl.unit
  end as anti_coagulant_unit,
  case
    when ord.rst_cond_info->''25''->>''medicine_type'' = ''2'' then mix_anti_coagulant_tbl.unit
    else med_anti_coagulant_tbl.unit
  end as anti_coagulant_speed_unit

  -- 実績
  ,rst_dialysis_cnt
  ,rst_in_out_class
  ,rst_ward_name
  ,mst_ward_tbl.in_hospital_cd_1 as  rst_ward_in_hospital_cd_1
  ,rst_course_name
  ,mst_course_tbl.in_hospital_cd_1 as  rst_course_in_hospital_cd_1
  ,rst_accept_date
  ,rst_return_home_date
  ,rst_purification_cnt
  ,trim(coalesce(rst_charge_user_info->>''user_id_1'', '''') , '' '') as rst_charge_user_id_1
  ,trim(coalesce(rst_charge_user_info->>''user_id_2'', '''') , '' '') as rst_charge_user_id_2
  ,coalesce(rst_charge_user_info->>''user_last_name_1'', '''') || coalesce(rst_charge_user_info->>''user_first_name_1'', '''') as rst_charge_user_name1
  ,coalesce(rst_charge_user_info->>''user_last_name_2'', '''') || coalesce(rst_charge_user_info->>''user_first_name_2'', '''') as rst_charge_user_name2
  ,(rst_charge_user_info->>''date_1'')::timestamp as rst_charge_date1
  ,(rst_charge_user_info->>''date_2'')::timestamp as rst_charge_date2
  ,trim(coalesce(rst_puncture_user_info->>''user_id_1'', '''') , '' '') as rst_puncture_user_id_1
  ,trim(coalesce(rst_puncture_user_info->>''user_id_2'', '''') , '' '') as rst_puncture_user_id_2
  ,coalesce(rst_puncture_user_info->>''user_last_name_1'', '''') || coalesce(rst_puncture_user_info->>''user_first_name_1'', '''') as rst_puncture_user_name1
  ,coalesce(rst_puncture_user_info->>''user_last_name_2'', '''') || coalesce(rst_puncture_user_info->>''user_first_name_2'', '''') as rst_puncture_user_name2
  ,(rst_puncture_user_info->>''date_1'')::timestamp as rst_puncture_date1
  ,(rst_puncture_user_info->>''date_2'')::timestamp as rst_puncture_date2
  ,trim(coalesce(rst_return_user_info->>''user_id_1'', '''') , '' '') as rst_return_user_id_1
  ,trim(coalesce(rst_return_user_info->>''user_id_2'', '''') , '' '') as rst_return_user_id_2
  ,coalesce(rst_return_user_info->>''user_last_name_1'', '''') || coalesce(rst_return_user_info->>''user_first_name_1'', '''') as rst_return_user_name1
  ,coalesce(rst_return_user_info->>''user_last_name_2'', '''') || coalesce(rst_return_user_info->>''user_first_name_2'', '''') as rst_return_user_name2
  ,(rst_return_user_info->>''date_1'')::timestamp as rst_return_date1
  ,(rst_return_user_info->>''date_2'')::timestamp as rst_return_date2
  ,ord.rst_dw
  ,ord.rst_treatment_name
  ,ord.pat_id as pat_id
  ,ord.pat_id AS pat_name
from
  ord_main as ord

  left join pat_physical_tbl on ord.pat_id = pat_physical_tbl.pat_id
  left join pat_wheel_chair_tbl on ord.pat_id = pat_wheel_chair_tbl.pat_id

  left join mst_va on cast(rst_cond_info->''2''->>''value'' as integer) = mst_va.va_cd  and mst_va.is_del = ''0'' and mst_va.is_disp = ''1''  -- 実績

  left join mst_treatment on ord.rst_treatment_cd = mst_treatment.treatment_cd and mst_treatment.is_del = ''0'' and mst_treatment.is_disp = ''1''
  left join mst_bed on ord.rst_bed_cd = mst_bed.bed_cd and mst_bed.is_del = ''0'' and mst_bed.is_disp = ''1''
  left join mst_machine on mst_bed.machine_no = mst_machine.machine_no and mst_machine.is_del = ''0'' and mst_machine.is_disp = ''1''

  left join bed_group_tbl on mst_bed.facility_cd = bed_group_tbl.facility_cd -- 実績
  left join room_tbl on mst_bed.facility_cd = room_tbl.facility_cd -- 実績

  left join mst_dialyzer on ord.rst_cond_info->''5''->>''value'' = mst_dialyzer.dialyzer_cd::text and mst_dialyzer.is_del = ''0'' and mst_dialyzer.is_disp = ''1''AND mst_dialyzer.dialyzer_cd IN (@diaIds)

  left join mst_equipment as adsorption_column_tbl on ord.rst_cond_info->''6''->>''value'' = adsorption_column_tbl.equipment_cd::text and adsorption_column_tbl.is_del = ''0'' and adsorption_column_tbl.is_disp = ''1'' AND adsorption_column_tbl.class_cd IN (@eqIds)
	and adsorption_column_tbl.facility_cd = ord.facility_cd
  left join mst_equipment as primary_film_tbl on ord.rst_cond_info->''7''->>''value'' = primary_film_tbl.equipment_cd::text and primary_film_tbl.is_del = ''0'' and primary_film_tbl.is_disp = ''1'' AND primary_film_tbl.class_cd IN (@eqIds)
	and primary_film_tbl.facility_cd = ord.facility_cd
  left join mst_equipment as secondary_film_tbl on ord.rst_cond_info->''8''->>''value'' = secondary_film_tbl.equipment_cd::text and secondary_film_tbl.is_del = ''0'' and secondary_film_tbl.is_disp = ''1'' AND secondary_film_tbl.class_cd IN (@eqIds)
and secondary_film_tbl.facility_cd = ord.facility_cd
  left join mst_equipment as puncture_needle_a_tbl on ord.rst_cond_info->''9''->>''value'' = puncture_needle_a_tbl.equipment_cd::text and puncture_needle_a_tbl.is_del = ''0'' and puncture_needle_a_tbl.is_disp = ''1'' and puncture_needle_a_tbl.class_cd IN (@eqIds)
	and puncture_needle_a_tbl.facility_cd = ord.facility_cd
  left join mst_equipment as puncture_needle_v_tbl on ord.rst_cond_info->''10''->>''value'' = puncture_needle_v_tbl.equipment_cd::text and puncture_needle_v_tbl.is_del = ''0'' and puncture_needle_v_tbl.is_disp = ''1'' and puncture_needle_v_tbl.class_cd IN (@eqIds)
	and puncture_needle_v_tbl.facility_cd = ord.facility_cd
  left join mst_equipment as puncture_needle_sn_tbl on ord.rst_cond_info->''11''->>''value'' = puncture_needle_sn_tbl.equipment_cd::text and puncture_needle_sn_tbl.is_del = ''0'' and puncture_needle_sn_tbl.is_disp = ''1'' and puncture_needle_sn_tbl.class_cd IN (@eqIds)
	and puncture_needle_sn_tbl.facility_cd = ord.facility_cd
  left join mst_equipment as blood_circuit_tbl on ord.rst_cond_info->''13''->>''value'' = blood_circuit_tbl.equipment_cd::text and blood_circuit_tbl.is_del = ''0'' and blood_circuit_tbl.is_disp = ''1'' and blood_circuit_tbl.class_cd IN (@eqIds)
and blood_circuit_tbl.facility_cd = ord.facility_cd
  left join mst_medicine as med_dialysate_tbl on ord.rst_cond_info->''15''->>''value'' = med_dialysate_tbl.medicine_cd::text and med_dialysate_tbl.is_del = ''0'' and med_dialysate_tbl.is_disp = ''1'' AND med_dialysate_tbl.class_cd IN (@medIds)
	and med_dialysate_tbl.facility_cd = ord.facility_cd
  left join mst_medicine as med_fluid_replacement_tbl on ord.rst_cond_info->''19''->>''value'' = med_fluid_replacement_tbl.medicine_cd::text and med_fluid_replacement_tbl.is_del = ''0'' and med_fluid_replacement_tbl.is_disp = ''1'' and med_fluid_replacement_tbl.class_cd in  (@medIds)
	and med_fluid_replacement_tbl.facility_cd = ord.facility_cd
  left join mst_medicine as med_anti_coagulant_tbl on ord.rst_cond_info->''25''->>''value'' = med_anti_coagulant_tbl.medicine_cd::text and med_anti_coagulant_tbl.is_del = ''0'' and med_anti_coagulant_tbl.is_disp = ''1''and med_anti_coagulant_tbl.class_cd in  (@medIds)
and med_anti_coagulant_tbl.facility_cd = ord.facility_cd
  left join mst_medicine_mix as mix_dialysate_tbl on ord.rst_cond_info->''15''->>''value'' = mix_dialysate_tbl.medicine_mix_cd::text and mix_dialysate_tbl.is_del = ''0'' and mix_dialysate_tbl.is_disp = ''1'' and mix_dialysate_tbl.class_cd in (@medIds)
  left join mst_medicine_mix as mix_fluid_replacement_tbl on ord.rst_cond_info->''19''->>''value'' = mix_fluid_replacement_tbl.medicine_mix_cd::text and mix_fluid_replacement_tbl.is_del = ''0'' and mix_fluid_replacement_tbl.is_disp = ''1'' and mix_fluid_replacement_tbl.class_cd in (@medIds)
  left join mst_medicine_mix as mix_anti_coagulant_tbl on ord.rst_cond_info->''25''->>''value'' = mix_anti_coagulant_tbl.medicine_mix_cd::text and mix_anti_coagulant_tbl.is_del = ''0'' and mix_anti_coagulant_tbl.is_disp = ''1'' and mix_anti_coagulant_tbl.class_cd in (@medIds)
  left join mst_ward as mst_ward_tbl on (ord.rst_ward_cd = mst_ward_tbl.ward_cd and mst_ward_tbl.is_disp =''1'' and mst_ward_tbl.is_del =''0''    )
  left join mst_course as mst_course_tbl on (ord.rst_course_cd = mst_course_tbl.course_cd and mst_course_tbl.is_disp =''1'' and mst_course_tbl.is_del =''0''   )
where
  ord.ord_no = @ordNo
 and ord.rst_dialysis_state > ''0''
 and ord.is_del = ''0''


	),
time_info AS (
	WITH b AS (
    select ord_main.* from ord_main
     where rst_dialysis_state between ''1'' and ''5''
     and
			 ord_no = @ordNo
     and
       is_del = ''0''
	), d AS (
    select b.ord_no
    , data_type
    , MAX(bio_moni_ctl_no) AS bio_moni_ctl_no
    from b inner join mni_monitor on (b.ord_no = mni_monitor.ord_no) and b.facility_cd = mni_monitor.facility_cd
    group by b.ord_no
    , mni_monitor.data_type
	), e AS (
    select mni_monitor.*,
    to_number(mni_monitor.monitor_data::json->>''1'', ''9999'') AS 経過時間
    , to_number(mni_monitor.monitor_data::json->>''3'', ''9999'') AS 残り時間_除水完了
    , to_number(mni_monitor.monitor_data::json->>''4'', ''9999'') AS 残り時間_透析完了
    from d
    inner join mni_monitor on (d.bio_moni_ctl_no = mni_monitor.bio_moni_ctl_no) 
    where d.data_type = 1
	), f AS (
    select e.*
    , e.経過時間 + e.残り時間_除水完了 AS 予測時間_除水
    , e.経過時間 + e.残り時間_透析完了 AS 予測時間_透析
    from e
	)
	select
	b.ord_no,
	-- 終了予定
	b.rst_start_date + e.経過時間  * interval ''1 minute'' AS  ind_end_date,
	-- 終了予測
	CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN f.残り時間_除水完了 > f.残り時間_透析完了 THEN b.rst_start_date + f.予測時間_除水 * interval ''1 minute''
       ELSE b.rst_start_date + f.予測時間_透析 * interval ''1 minute''
	END AS ind_end_date_time
	-- 透析開始
	, b.rst_start_date
	-- 透析終了
	, b.rst_end_date
	from  b left JOIN e on b.ord_no=e.ord_no left JOIN f on b.ord_no=f.ord_no
)
SELECT
	DATA.*,time_info.ind_end_date,time_info.ind_end_date_time,time_info.rst_start_date,time_info.rst_end_date
FROM
	DATA
	LEFT JOIN
	time_info
	on
	DATA.ord_no = time_info.ord_no', 2, '[{"preview": "2011/3/12", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/3/12 08:21", "can_calc": "0", "data_code": "treat_start_time", "data_name": "透析開始時刻", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "treat_start_time", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/3/12  12:45", "can_calc": "0", "data_code": "treat_end_time", "data_name": "透析終了時刻", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "treat_end_time", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "0", "data_code": "treatment_time", "data_name": "透析時間", "data_type": "decimal", "conv_table": [], "data_class": "", "field_name": "treatment_time", "disp_format": "0", "data_category": "", "facility_table": "", "facility_filter_type": "0"}, {"preview": "89", "can_calc": "1", "data_code": "rst_dialysis_cnt", "data_name": "透析回数", "data_type": "decimal", "conv_table": [], "data_class": "実績情報", "field_name": "rst_dialysis_cnt", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "89", "can_calc": "1", "data_code": "rst_purification_cnt", "data_name": "特殊浄化回数", "data_type": "decimal", "conv_table": [], "data_class": "実績情報", "field_name": "rst_purification_cnt", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789012", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "hosp_pat_id", "target_var": "@patId"}, "data_code": "pat_id", "data_name": "患者ID（集計項目用）", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "pat_id", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装　太郎", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_name", "target_var": "@patId"}, "data_code": "pat_name", "data_name": "氏名（集計項目用）", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "pat_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "外来", "can_calc": "0", "data_code": "rst_in_out_class", "data_name": "入外区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "外来", "item": "外来"}, {"code": "1", "disp": "入院", "item": "入院"}], "data_class": "実績情報", "field_name": "rst_in_out_class", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "A棟", "can_calc": "0", "data_code": "rst_ward_name", "data_name": "病棟名", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_ward_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_ward_in_hospital_cd_1", "data_name": "病棟連携コード", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_ward_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "泌尿器科", "can_calc": "0", "data_code": "rst_course_name", "data_name": "診療科名", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_course_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "泌尿器科", "can_calc": "0", "data_code": "rst_course_in_hospital_cd_1", "data_name": "診療科連携コード", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_course_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:01", "can_calc": "0", "data_code": "rst_accept_date", "data_name": "受付時刻", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_accept_date", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13:02", "can_calc": "0", "data_code": "rst_return_home_date", "data_name": "帰宅時刻", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_home_date", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_charge_user_id_1", "data_name": "担当者ID１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_user_id_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "rst_charge_user_name1", "data_name": "担当者名１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_user_name1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:03", "can_calc": "0", "data_code": "rst_charge_date1", "data_name": "担当日時１", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_date1", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_charge_user_id_2", "data_name": "担当者ID２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_user_id_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師２", "can_calc": "0", "data_code": "rst_charge_user_name2", "data_name": "担当者名２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_user_name2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:04", "can_calc": "0", "data_code": "rst_charge_date2", "data_name": "担当日時２", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_date2", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_puncture_user_id_1", "data_name": "穿刺者ID１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_user_id_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "data_code": "rst_puncture_user_name1", "data_name": "穿刺者名１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_user_name1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:16", "can_calc": "0", "data_code": "rst_puncture_date1", "data_name": "穿刺日時１", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_date1", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_puncture_user_id_2", "data_name": "穿刺者ID２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_user_id_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "data_code": "rst_puncture_user_name2", "data_name": "穿刺者名２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_user_name2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:16", "can_calc": "0", "data_code": "rst_puncture_date2", "data_name": "穿刺日時２", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_date2", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_return_user_id_1", "data_name": "返血者ID１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_user_id_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "rst_return_user_name1", "data_name": "返血者名１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_user_name1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:51", "can_calc": "0", "data_code": "rst_return_date1", "data_name": "返血日時１", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_date1", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_return_user_id_2", "data_name": "返血者ID２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_user_id_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "data_code": "rst_return_user_name2", "data_name": "返血者名２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_user_name2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:51", "can_calc": "0", "data_code": "rst_return_date2", "data_name": "返血日時２", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_date2", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "04:00", "can_calc": "0", "data_code": "treatment_time", "data_name": "透析時間", "data_type": "DateTime", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_time", "disp_format": "[h]:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "420", "can_calc": "0", "data_code": "treatment_time", "data_name": "透析時間(分)", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_time", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左手前腕部シャント化静脈", "can_calc": "0", "data_code": "va_name", "data_name": "VA", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "va_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "va_in_hospital_cd_1", "data_name": "VA連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "va_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "va_in_hospital_cd_2", "data_name": "VA連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "va_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左", "can_calc": "0", "data_code": "va_direct", "data_name": "VA方向", "data_type": "string", "conv_table": [{"code": "0", "disp": "右", "item": "右"}, {"code": "1", "disp": "左", "item": "左"}, {"code": "2", "disp": "両方", "item": "両方"}, {"code": "3", "disp": "なし", "item": "なし"}, {"code": "-", "disp": "不明", "item": "不明"}], "data_class": "透析条件", "field_name": "va_direct", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "1", "data_code": "dw", "data_name": "DW", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dw", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DWと同じ", "can_calc": "0", "data_code": "target_weight_mode", "data_name": "目標体重指定設定", "data_type": "string", "conv_table": [{"code": "0", "disp": "DWと違う", "item": "DWと違う"}, {"code": "1", "disp": "DWと同じ", "item": "DWと同じ"}], "data_class": "透析条件", "field_name": "target_weight_mode", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "1", "data_code": "target_weight", "data_name": "目標体重", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "target_weight", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "HDF", "can_calc": "0", "data_code": "treatment_name", "data_name": "治療方法", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_treatment_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "HDF", "can_calc": "0", "data_code": "device_mode", "data_name": "装置モード", "data_type": "string", "conv_table": [{"code": "-1", "disp": "不明", "item": "不明"}, {"code": "0", "disp": "HD", "item": "HD"}, {"code": "1", "disp": "ECUM", "item": "ECUM"}, {"code": "2", "disp": "HDF", "item": "HDF"}, {"code": "3", "disp": "HF", "item": "HF"}, {"code": "4", "disp": "HD+補液", "item": "HD+補液"}, {"code": "5", "disp": "ECUM+補液", "item": "ECUM+補液"}, {"code": "6", "disp": "AFBF", "item": "AFBF"}, {"code": "7", "disp": "OHDF", "item": "OHDF"}, {"code": "8", "disp": "OHF", "item": "OHF"}, {"code": "9", "disp": "特殊浄化", "item": "特殊浄化"}, {"code": "10", "disp": "I-HDF", "item": "I-HDF"}], "data_class": "透析条件", "field_name": "device_mode", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "water_removal_amount_limit", "data_name": "除水量制限", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "water_removal_amount_limit", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "FDX-120GW", "can_calc": "0", "data_code": "dialyzer_name", "data_name": "ダイアライザ", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "dialyzer_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト１次膜", "can_calc": "0", "data_code": "primary_film_name", "data_name": "1次膜", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "primary_film_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_primary_film_in_hospital_cd_1", "data_name": "1次膜連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_primary_film_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_primary_film_in_hospital_cd_2", "data_name": "1次膜連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_primary_film_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_primary_film_in_hospital_cd_3", "data_name": "1次膜連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_primary_film_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_primary_film_in_hospital_cd_4", "data_name": "1次膜連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_primary_film_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト２次膜", "can_calc": "0", "data_code": "secondary_film_name", "data_name": "2次膜", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "secondary_film_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_secondary_film_in_hospital_cd_1", "data_name": "2次膜連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_secondary_film_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_secondary_film_in_hospital_cd_2", "data_name": "2次膜連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_secondary_film_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_secondary_film_in_hospital_cd_3", "data_name": "2次膜連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_secondary_film_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_secondary_film_in_hospital_cd_4", "data_name": "2次膜連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_secondary_film_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リクセルS-15", "can_calc": "0", "data_code": "adsorption_column_name", "data_name": "吸着カラム", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "adsorption_column_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_adsorption_in_hospital_cd_1", "data_name": "吸着カラム連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_adsorption_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_adsorption_in_hospital_cd_2", "data_name": "吸着カラム連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_adsorption_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_adsorption_in_hospital_cd_3", "data_name": "吸着カラム連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_adsorption_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_adsorption_in_hospital_cd_4", "data_name": "吸着カラム連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_adsorption_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "180", "can_calc": "1", "data_code": "blood_flow", "data_name": "血流量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "blood_flow", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "Dドライ3.0S", "can_calc": "0", "data_code": "dialysate_name", "data_name": "透析液", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialysate_in_hospital_cd_1", "data_name": "透析液連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialysate_in_hospital_cd_2", "data_name": "透析液連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialysate_in_hospital_cd_3", "data_name": "透析液連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialysate_in_hospital_cd_4", "data_name": "透析液連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/min", "can_calc": "0", "data_code": "dialysate_amount_unit", "data_name": "透析液単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_amount_unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "dialysate_flow_rate", "data_name": "透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_flow_rate", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120.00", "can_calc": "1", "data_code": "dialysate_amount", "data_name": "透析液量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_amount", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.0", "can_calc": "1", "data_code": "dialysate_temperature", "data_name": "透析液温度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_temperature", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト補液", "can_calc": "0", "data_code": "fluid_replacement_name", "data_name": "補液", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_fluid_in_hospital_cd_1", "data_name": "補液連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_fluid_in_hospital_cd_2", "data_name": "補液連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_fluid_in_hospital_cd_3", "data_name": "補液連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_fluid_in_hospital_cd_4", "data_name": "補液連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "L", "can_calc": "0", "data_code": "fluid_replacement_unit", "data_name": "補液単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "8.0", "can_calc": "1", "data_code": "fluid_replacement_amount", "data_name": "補液量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_amount", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.0", "can_calc": "1", "data_code": "fluid_replacement_speed", "data_name": "補液速度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_speed", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "後補液", "can_calc": "0", "data_code": "fluid_replacement_timing", "data_name": "補液選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "後補液", "item": "後補液"}, {"code": "1", "disp": "前補液", "item": "前補液"}], "data_class": "透析条件", "field_name": "fluid_replacement_timing", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "1", "data_code": "fluid_replacement_use_count", "data_name": "補液使用数", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_use_count", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.0", "can_calc": "1", "data_code": "fluid_replacement_temperature", "data_name": "補液温度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_temperature", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト抗凝固剤", "can_calc": "0", "data_code": "anti_coagulant_name", "data_name": "抗凝固剤", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_anti_in_hospital_cd_1", "data_name": "抗凝固剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_anti_in_hospital_cd_2", "data_name": "抗凝固剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_anti_in_hospital_cd_3", "data_name": "抗凝固剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_anti_in_hospital_cd_4", "data_name": "抗凝固剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "U", "can_calc": "0", "data_code": "anti_coagulant_unit", "data_name": "抗凝固剤単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1000", "can_calc": "1", "data_code": "anti_coagulant_one_shot_amount", "data_name": "抗凝固剤ワンショット量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_one_shot_amount", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "anti_coagulant_sustained_speed", "data_name": "抗凝固剤持続速度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_sustained_speed", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "U/h", "can_calc": "0", "data_code": "anti_coagulant_sustained_speed_unit", "data_name": "抗凝固剤持続速度単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_sustained_speed_unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2000", "can_calc": "1", "data_code": "anti_coagulant_sustained_amount", "data_name": "抗凝固剤持続総量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_sustained_amount", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3000", "can_calc": "1", "data_code": "anti_coagulant_total_amount", "data_name": "抗凝固剤総量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_total_amount", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "する", "can_calc": "0", "data_code": "ip", "data_name": "IP使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "透析条件", "field_name": "ip", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "自動", "can_calc": "0", "data_code": "ip_start", "data_name": "IPスタート", "data_type": "string", "conv_table": [{"code": "0", "disp": "手動", "item": "手動"}, {"code": "1", "disp": "自動", "item": "自動"}], "data_class": "透析条件", "field_name": "ip_start", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.2", "can_calc": "1", "data_code": "ip_speed", "data_name": "IP速度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/h", "can_calc": "0", "data_code": "ip_speed_unit", "data_name": "IP速度単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed_unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "1", "data_code": "ip_speed_max", "data_name": "IP速度最大値", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed_max", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/h", "can_calc": "0", "data_code": "ip_speed_max_unit", "data_name": "IP速度最大値単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed_max_unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "auto_one_shot", "data_name": "自動ワンショット", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "透析条件", "field_name": "auto_one_shot", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ip_one_shot_amount", "data_name": "IPワンショット量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_one_shot_amount", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL", "can_calc": "0", "data_code": "ip_one_shot_amount_unit", "data_name": "IPワンショット量単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "ip_one_shot_amount_unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切", "can_calc": "0", "data_code": "ip_auto_off", "data_name": "IP電源自動切り", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "透析条件", "field_name": "ip_auto_off", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ip_auto_off_time", "data_name": "IP電源自動切り時間", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_auto_off_time", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切", "can_calc": "0", "data_code": "ip_monitor_auto_off", "data_name": "IP電源OKモニタ切り", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "透析条件", "field_name": "ip_monitor_auto_off", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ip_monitor_auto_off_time", "data_name": "IP電源OKモニタ切り時間", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_monitor_auto_off_time", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "しない", "can_calc": "0", "data_code": "single_needle", "data_name": "シングルニードル使用", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "透析条件", "field_name": "single_needle", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針A", "can_calc": "0", "data_code": "puncture_needle_a_name", "data_name": "穿刺針A針名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "puncture_needle_a_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_a_in_hospital_cd_1", "data_name": "穿刺針A針連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_a_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_a_in_hospital_cd_2", "data_name": "穿刺針A針連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_a_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_a_in_hospital_cd_3", "data_name": "穿刺針A針連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_a_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_a_in_hospital_cd_4", "data_name": "穿刺針A針連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_a_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針V針", "can_calc": "0", "data_code": "puncture_needle_v_name", "data_name": "穿刺針V針名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "puncture_needle_v_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_v_in_hospital_cd_1", "data_name": "穿刺針V針連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_v_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_v_in_hospital_cd_2", "data_name": "穿刺針V針連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_v_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_v_in_hospital_cd_3", "data_name": "穿刺針V針連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_v_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_v_in_hospital_cd_4", "data_name": "穿刺針V針連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_v_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針S針", "can_calc": "0", "data_code": "puncture_needle_s_name", "data_name": "穿刺針S針名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "puncture_needle_s_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_s_in_hospital_cd_1", "data_name": "穿刺針S針連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_s_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_s_in_hospital_cd_2", "data_name": "穿刺針S針連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_s_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_s_in_hospital_cd_3", "data_name": "穿刺針S針連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_s_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_s_in_hospital_cd_4", "data_name": "穿刺針S針連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_s_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "血液回路", "can_calc": "0", "data_code": "blood_circuit_name", "data_name": "血液回路名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "blood_circuit_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_bc_in_hospital_cd_1", "data_name": "血液回路連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_bc_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_bc_in_hospital_cd_2", "data_name": "血液回路連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_bc_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_bc_in_hospital_cd_3", "data_name": "血液回路連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_bc_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_bc_in_hospital_cd_4", "data_name": "血液回路連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_bc_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左", "can_calc": "0", "data_code": "shunt_position", "data_name": "シャント位置", "data_type": "string", "conv_table": [{"code": "0", "disp": "右", "item": "右"}, {"code": "1", "disp": "左", "item": "左"}, {"code": "2", "disp": "両方", "item": "両方"}, {"code": "3", "disp": "なし", "item": "なし"}, {"code": "-", "disp": "不明", "item": "不明"}], "data_class": "ベッド情報", "field_name": "shunt_position", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "感染症あり", "can_calc": "0", "data_code": "is_infection", "data_name": "感染症対応", "data_type": "string", "conv_table": [{"code": "0", "disp": "感染症なし", "item": "感染症なし"}, {"code": "1", "disp": "感染症あり", "item": "感染症あり"}], "data_class": "ベッド情報", "field_name": "is_infection", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常ベッド", "can_calc": "0", "data_code": "emergency_class", "data_name": "緊急区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "通常ベッド", "item": "通常ベッド"}, {"code": "1", "disp": "緊急ベッド", "item": "緊急ベッド"}], "data_class": "ベッド情報", "field_name": "emergency_class", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "Aグループ", "can_calc": "0", "data_code": "bed_group_name", "data_name": "ベッドグループ名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "bed_group_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "第二透析室", "can_calc": "0", "data_code": "room_name", "data_name": "透析室名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "room_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "装置001", "can_calc": "0", "data_code": "machine_name", "data_name": "装置名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "machine_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装", "can_calc": "0", "data_code": "maker", "data_name": "メーカー", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "maker", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "function_class", "data_name": "機能分類", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "function_class", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.2", "can_calc": "1", "data_code": "area", "data_name": "面積", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "area", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "45.00", "can_calc": "1", "data_code": "ufr", "data_name": "UFR", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "ufr", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "koa", "data_name": "KOA", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "koa", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "親水化PEPA", "can_calc": "0", "data_code": "material", "data_name": "材質", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "material", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "WET", "can_calc": "0", "data_code": "wetdry", "data_name": "WET/DRY", "data_type": "string", "conv_table": [{"code": "0", "disp": "不明", "item": "不明"}, {"code": "1", "disp": "WET", "item": "WET"}, {"code": "2", "disp": "DRY", "item": "DRY"}], "data_class": "ダイアライザ情報", "field_name": "wetdry", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "γ線滅菌", "can_calc": "0", "data_code": "sterilization", "data_name": "滅菌", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "sterilization", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "0", "data_code": "bloodamt", "data_name": "血流量", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "bloodamt", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "alqd_flood_vol", "data_name": "透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "alqd_flood_vol", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "190", "can_calc": "0", "data_code": "urea_clearance", "data_name": "尿素クリアランス", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "urea_clearance", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "1", "data_code": "gas_purge_time", "data_name": "ガスパージ時間", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "gas_purge_time", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1000", "can_calc": "1", "data_code": "substituent_wash_amt", "data_name": "置換洗浄量（透析液）", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "substituent_wash_amt", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "membrane_wash", "data_name": "膜洗浄（中空糸）", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "ダイアライザ情報", "field_name": "membrane_wash", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialyzer_in_hospital_cd_1", "data_name": "ダイアライザ連携コード１", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "rst_dialyzer_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialyzer_in_hospital_cd_2", "data_name": "ダイアライザ連携コード２", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "rst_dialyzer_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialyzer_in_hospital_cd_3", "data_name": "ダイアライザ連携コード３", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "rst_dialyzer_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialyzer_in_hospital_cd_4", "data_name": "ダイアライザ連携コード４", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "rst_dialyzer_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_1", "data_name": "治療方法連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_2", "data_name": "治療方法連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_3", "data_name": "治療方法連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_4", "data_name": "治療方法連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]'::jsonb, '0', '{"applications": [1]}'::jsonb, '{"classes": [1, 2, 3, 9, 10, 11]}'::jsonb, '実績：透析条件/ベッド情報/ダイアライザ情報/実績情報 @ordNo 使用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
