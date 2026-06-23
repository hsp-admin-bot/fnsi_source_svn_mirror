DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (45, 95, 133, 192);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (45, 'with ord_tbl as (
  select
    facility_cd,
    pat_id,
    ind_bed_cd,
		treat_date,
    to_timestamp(treat_date, ''yyyymmdd'') + ''1 days - 1 milliseconds'' as treat_date_end,
    rst_dialysis_state
  from
    ord_main
  where
    ord_no = @ordNo
    and is_del = ''0''
), next_date as (
  select
     pat_id,
     treat_date
  from
     ord_main
  where
     pat_id =(select pat_id from ord_main
	 where
	 ord_no= @ordNo
	 and is_del = ''0''
	 and rst_dialysis_state = ''0'')
  and
     treat_date > (select treat_date from ord_main
	 where
	 ord_no=@ordNo
	 and is_del = ''0''
	 and rst_dialysis_state = ''0'') and is_del = ''0'' and rst_dialysis_state = ''0'' and facility_cd = @facilityCd ORDER BY treat_date ASC limit 1

), kur_tbl as (
  select
    *
  from
    mst_kur
  where
    mst_kur.facility_cd = @facilityCd
  and
    mst_kur.is_del = ''0''
), va_tbl as (
  select
    *
  from
    mst_va
  where
    mst_va.facility_cd = @facilityCd
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
    mst_treatment.facility_cd = @facilityCd
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
    mst_bed.facility_cd = @facilityCd
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
    mst_machine.facility_cd = @facilityCd
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
    mst_room_bed_group.facility_cd = @facilityCd
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
    mst_dialyzer.facility_cd = @facilityCd
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
    mst_medicine.facility_cd = @facilityCd
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
    mst_medicine_mix.facility_cd = @facilityCd
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
    mst_equipment.facility_cd = @facilityCd
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
      pat_unique.pat_id = @patId
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
        facility_cd = @facilityCd
      and
        master_physical_name = ''mst_wheel_chair''
  ) ms
  where
    mst_wheel_chair.wheel_chair_cd = ms.code
  and
    pat_id = @patId
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
    AND facility_cd = @facilityCd
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
    AND facility_cd = @facilityCd
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
    AND facility_cd = @facilityCd
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
		AND facility_cd = @facilityCd
		AND supplies_source_class = ''0''
		AND supplies_class = ''00''
		AND ind_rst_class=''1''

)
select
  to_date(ord.treat_date, ''yyyymmdd'') as treat_date,
  ord.ind_kur_cd as kur_cd,
  kur_tbl.kur_name as kur_name,
  COALESCE (
  NULLIF(
  CASE
  WHEN treat_week = ''1'' THEN(SELECT mst_user_authentication FROM mst_kur WHERE kur_cd = ind_kur_cd) ->''data''->0->''Mon''->>''user_id''
  WHEN treat_week = ''2'' THEN(SELECT mst_user_authentication FROM mst_kur WHERE kur_cd = ind_kur_cd) ->''data''->0->''Tues''->>''user_id''
  WHEN treat_week = ''3'' THEN(SELECT mst_user_authentication FROM mst_kur WHERE kur_cd = ind_kur_cd) ->''data''->0->''Wednes''->>''user_id''
  WHEN treat_week = ''4'' THEN(SELECT mst_user_authentication FROM mst_kur WHERE kur_cd = ind_kur_cd) ->''data''->0->''Thurs''->>''user_id''
  WHEN treat_week = ''5'' THEN(SELECT mst_user_authentication FROM mst_kur WHERE kur_cd = ind_kur_cd) ->''data''->0->''Fri''->>''user_id''
  WHEN treat_week = ''6'' THEN(SELECT mst_user_authentication FROM mst_kur WHERE kur_cd = ind_kur_cd) ->''data''->0->''Satur''->>''user_id''
  WHEN treat_week = ''7'' THEN(SELECT mst_user_authentication FROM mst_kur WHERE kur_cd = ind_kur_cd) ->''data''->0->''Sun''->>''user_id''
  END,''''), 
  NULLIF(((SELECT mst_user_authentication FROM mst_kur WHERE kur_cd = ind_kur_cd) ->''data''->0->''All''->>''user_id''),''''),
  NULLIF((SELECT "value" FROM mst_facility_setting  WHERE facility_cd = @facilityCd AND facility_setting_no = ''1025''),''0''),'''')
  AS full_time_doctor,
  ord.ind_va_cd as va_cd,
  va_tbl.va_direct as va_direct,
  ord.ind_treatment_cd as treatment_cd,
  treatment_tbl.treatment_name,
-- 	treatment_tbl.treatment_name AS treatment_name1,
  to_char(to_timestamp(ord.ind_treat_start_time, ''HH24MI''), ''HH24:MI'') as treat_start_time,
  ord.ind_bed_cd as bed_cd,
  -- 治療時間
  ord.ind_cond_info->''1''->>''value'' as treatment_time,
  --VA
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN va_tbl.va_name
    ELSE ord.ind_cond_info->''2''->>''value_name_1''
  END AS va_name,
  va_tbl.in_hospital_cd_1 as va_in_hospital_cd_1,
  va_tbl.in_hospital_cd_2 as va_in_hospital_cd_2,
  -- 目標体重
  case
    when ord.ind_cond_info->''3''->>''value'' = ''-1'' then ''1''
    else ''0''
  end as target_weight_mode,
  case
    when ord.ind_cond_info->''3''->>''value'' = ''-1'' then pat_physical_tbl.dw
    else ord.ind_cond_info->''3''->>''value''
  end as target_weight,
  -- 除水量制限
  ord.ind_cond_info->''4''->>''value'' as water_removal_amount_limit,
  -- ダイアライザ
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN dialyzer_tbl.model_number
    ELSE ord.ind_cond_info->''5''->>''value_name_1''
  END AS dialyzer_name,
  dialyzer_tbl.in_hospital_cd_1 as dialyzer_in_hospital_cd_1,
  dialyzer_tbl.in_hospital_cd_2 as dialyzer_in_hospital_cd_2,
  dialyzer_tbl.in_hospital_cd_3 as dialyzer_in_hospital_cd_3,
  dialyzer_tbl.in_hospital_cd_4 as dialyzer_in_hospital_cd_4,
  dialyzer_tbl.*,
  -- 吸着カラム
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN adsorption_column_tbl.equipment_name
    ELSE ord.ind_cond_info->''6''->>''value_name_1''
  END AS adsorption_column_name,
  adsorption_column_tbl.in_hospital_cd_1 as adsorption_in_hospital_cd_1,
  adsorption_column_tbl.in_hospital_cd_2 as adsorption_in_hospital_cd_2,
  adsorption_column_tbl.in_hospital_cd_3 as adsorption_in_hospital_cd_3,
  adsorption_column_tbl.in_hospital_cd_4 as adsorption_in_hospital_cd_4,
  -- 1次膜
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN primary_film_tbl.equipment_name
    ELSE ord.ind_cond_info->''7''->>''value_name_1''
  END AS primary_film_name,
  primary_film_tbl.in_hospital_cd_1 as primary_film_in_hospital_cd_1,
  primary_film_tbl.in_hospital_cd_2 as primary_film_in_hospital_cd_2,
  primary_film_tbl.in_hospital_cd_3 as primary_film_in_hospital_cd_3,
  primary_film_tbl.in_hospital_cd_4 as primary_film_in_hospital_cd_4,
  -- 2次膜
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN secondary_film_tbl.equipment_name
    ELSE ord.ind_cond_info->''8''->>''value_name_1''
  END AS secondary_film_name,
  secondary_film_tbl.in_hospital_cd_1 as secondary_film_in_hospital_cd_1,
  secondary_film_tbl.in_hospital_cd_2 as secondary_film_in_hospital_cd_2,
  secondary_film_tbl.in_hospital_cd_3 as secondary_film_in_hospital_cd_3,
  secondary_film_tbl.in_hospital_cd_4 as secondary_film_in_hospital_cd_4,
  -- 穿刺針(A針)
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN puncture_needle_a_tbl.equipment_name
    ELSE ord.ind_cond_info->''9''->>''value_name_1''
  END AS puncture_needle_a_name,
  puncture_needle_a_tbl.in_hospital_cd_1 as pn_a_in_hospital_cd_1,
  puncture_needle_a_tbl.in_hospital_cd_2 as pn_a_in_hospital_cd_2,
  puncture_needle_a_tbl.in_hospital_cd_3 as pn_a_in_hospital_cd_3,
  puncture_needle_a_tbl.in_hospital_cd_4 as pn_a_in_hospital_cd_4,
  -- 穿刺針(V針)
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN puncture_needle_v_tbl.equipment_name
    ELSE ord.ind_cond_info->''10''->>''value_name_1''
  END AS puncture_needle_v_name,
  puncture_needle_v_tbl.in_hospital_cd_1 as pn_v_in_hospital_cd_1,
  puncture_needle_v_tbl.in_hospital_cd_2 as pn_v_in_hospital_cd_2,
  puncture_needle_v_tbl.in_hospital_cd_3 as pn_v_in_hospital_cd_3,
  puncture_needle_v_tbl.in_hospital_cd_4 as pn_v_in_hospital_cd_4,
  -- 穿刺針(SN)
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN puncture_needle_sn_tbl.equipment_name
    ELSE ord.ind_cond_info->''11''->>''value_name_1''
  END AS puncture_needle_sn_name,
  puncture_needle_sn_tbl.in_hospital_cd_1 as pn_s_in_hospital_cd_1,
  puncture_needle_sn_tbl.in_hospital_cd_2 as pn_s_in_hospital_cd_2,
  puncture_needle_sn_tbl.in_hospital_cd_3 as pn_s_in_hospital_cd_3,
  puncture_needle_sn_tbl.in_hospital_cd_4 as pn_s_in_hospital_cd_4,
  -- シングルニードル使用
  ord.ind_cond_info->''12''->>''value'' as single_needle,
  -- 血液回路
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN blood_circuit_tbl.equipment_name
    ELSE ord.ind_cond_info->''13''->>''value_name_1''
  END AS blood_circuit_name,
  blood_circuit_tbl.in_hospital_cd_1 as bc_in_hospital_cd_1,
  blood_circuit_tbl.in_hospital_cd_2 as bc_in_hospital_cd_2,
  blood_circuit_tbl.in_hospital_cd_3 as bc_in_hospital_cd_3,
  blood_circuit_tbl.in_hospital_cd_4 as bc_in_hospital_cd_4,
  -- 血流量
  ord.ind_cond_info->''14''->>''value'' as blood_flow,
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN ''mL/min''
    ELSE ord.ind_cond_info->''14''->>''unit'' 
  END AS blood_flow_unit,
  -- 透析液
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN med_dialysate_tbl.medicine_name
    ELSE ord.ind_cond_info->''15''->>''value_name_1''
  END AS dialysate_name,
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN med_dialysate_tbl.unit_second
    ELSE ord.ind_cond_info->''15''->>''unit''
  END AS dialysate_flow_unit,
  med_dialysate_tbl.in_hospital_cd_1 AS rst_dialysate_in_hospital_cd_1,
  med_dialysate_tbl.in_hospital_cd_2 AS rst_dialysate_in_hospital_cd_2,
  med_dialysate_tbl.in_hospital_cd_3 AS rst_dialysate_in_hospital_cd_3,
  med_dialysate_tbl.in_hospital_cd_4 AS rst_dialysate_in_hospital_cd_4,
  -- 透析液流量
  ord.ind_cond_info->''16''->>''value'' as dialysate_flow_rate,
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN ''mL/min''
    ELSE ord.ind_cond_info->''16''->>''unit'' 
  END AS dialysate_flow_rate_unit,
  -- 透析液使用数
  ord.ind_cond_info->''17''->>''value'' as dialysate_amount,
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN med_dialysate_tbl.unit_second
    ELSE ord.ind_cond_info->''17''->>''unit''
  END AS dialysate_amount_unit,
  -- 透析液温度
  ord.ind_cond_info->''18''->>''value'' as dialysate_temperature,
  -- 補液
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN med_fluid_replacement_tbl.medicine_name
    ELSE ord.ind_cond_info->''19''->>''value_name_1''
  END AS fluid_replacement_name,
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN med_fluid_replacement_tbl.unit_second
    ELSE ord.ind_cond_info->''22''->>''unit''
  END AS fluid_replacement_unit,
  med_fluid_replacement_tbl.in_hospital_cd_1 AS rst_fluid_in_hospital_cd_1,
  med_fluid_replacement_tbl.in_hospital_cd_2 AS rst_fluid_in_hospital_cd_2,
  med_fluid_replacement_tbl.in_hospital_cd_3 AS rst_fluid_in_hospital_cd_3,
  med_fluid_replacement_tbl.in_hospital_cd_4 AS rst_fluid_in_hospital_cd_4,  
  -- 補液量
	case
		when ord.ind_cond_info->''20''->>''value'' = ''-1'' then ''濾過率から算出''
		else ord.ind_cond_info->''20''->>''value''
		end as fluid_replacement_amount,
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN ''L''
    ELSE ord.ind_cond_info->''20''->>''unit''
  END AS fluid_replacement_amount_unit,
  -- 補液選択
  ord.ind_cond_info->''21''->>''value'' as fluid_replacement_timing,
  -- 補液使用数
  ord.ind_cond_info->''22''->>''value'' as fluid_replacement_use_count,
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN med_fluid_replacement_tbl.unit_second
    ELSE ord.ind_cond_info->''22''->>''unit''
  END AS fluid_replacement_use_count_unit,
  -- 補液温度
  ord.ind_cond_info->''23''->>''value'' as fluid_replacement_temperature,
  -- 補液速度
	case
		when ord.ind_cond_info->''24''->>''value'' = ''-1'' then ''濾過率から算出''
		else ord.ind_cond_info->''24''->>''value''
		end as fluid_replacement_speed,
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN ''L/h''
    ELSE ord.ind_cond_info->''24''->>''unit''
  END AS fluid_replacement_speed_unit,
  -- 抗凝固剤
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN
      CASE
        WHEN ord.ind_cond_info->''25''->>''medicine_type'' = ''2'' THEN mix_anti_coagulant_tbl.medicine_mix_name
        ELSE med_anti_coagulant_tbl.medicine_name
      END
    ELSE ord.ind_cond_info->''25''->>''value_name_1''
  END AS anti_coagulant_name,
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN
      CASE
        WHEN ord.ind_cond_info->''25''->>''medicine_type'' = ''2'' THEN mix_anti_coagulant_tbl.unit
        ELSE med_anti_coagulant_tbl.unit
      END
    ELSE ord.ind_cond_info->''25''->>''unit''
  END AS anti_coagulant_unit,
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
  -- 抗凝固剤ワンショット量
  ord.ind_cond_info->''26''->>''value'' as anti_coagulant_one_shot_amount,
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN
      CASE
        WHEN ord.ind_cond_info->''25''->>''medicine_type'' = ''2'' THEN mix_anti_coagulant_tbl.unit
        ELSE med_anti_coagulant_tbl.unit
      END
    ELSE ord.ind_cond_info->''26''->>''unit''
   END AS anti_coagulant_one_shot_amount_unit,
  -- 抗凝固剤持続速度
  ord.ind_cond_info->''27''->>''value'' as anti_coagulant_sustained_speed,
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN
      CASE
        WHEN ord.ind_cond_info->''25''->>''medicine_type'' = ''2'' THEN mix_anti_coagulant_tbl.unit || ''/h''
        ELSE med_anti_coagulant_tbl.unit || ''/h''
      END
    ELSE ord.ind_cond_info->''27''->>''unit''
  END AS anti_coagulant_sustained_speed_unit,
  -- 抗凝固剤持続総量
  ord.ind_cond_info->''28''->>''value'' as anti_coagulant_sustained_amount,
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN
      CASE
        WHEN ord.ind_cond_info->''25''->>''medicine_type'' = ''2'' THEN mix_anti_coagulant_tbl.unit
        ELSE med_anti_coagulant_tbl.unit
      END
    ELSE ord.ind_cond_info->''28''->>''unit''
   END AS anti_coagulant_sustained_amount_unit,
   
   CAST(ord.ind_cond_info->''26''->>''value'' AS DECIMAL)
    + CAST(ord.ind_cond_info->''28''->>''value'' AS DECIMAL)
    as anti_coagulant_total_amount,
  -- IP使用選択
  ord.ind_cond_info->''29''->>''value'' as ip,
  -- IPスタート
  ord.ind_cond_info->''30''->>''value'' as ip_start,
  -- IPワンショット量
  ord.ind_cond_info->''31''->>''value'' as ip_one_shot_amount,
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN
      CASE
        WHEN ord.ind_cond_info->''31''->>''value'' IS NOT NULL THEN ''mL''
        ELSE NULL
      END
    ELSE 
      ord.ind_cond_info->''31''->>''unit''
  END AS ip_one_shot_amount_unit,
  -- IP速度
  ord.ind_cond_info->''32''->>''value'' as ip_speed,
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN
      CASE
        WHEN ord.ind_cond_info->''32''->>''value'' IS NOT NULL THEN ''mL/h''
        ELSE NULL
      END
    ELSE 
      ord.ind_cond_info->''32''->>''unit''
  END AS ip_speed_unit,
  -- IP速度最大値
  ord.ind_cond_info->''33''->>''value'' as ip_speed_max,
  CASE
    WHEN ord.rst_dialysis_state = ''0'' THEN
      CASE
        WHEN ord.ind_cond_info->''33''->>''value'' IS NOT NULL THEN ''mL/h''
        ELSE NULL
      END
    ELSE 
      ord.ind_cond_info->''33''->>''unit''
  END AS ip_speed_max_unit,
  -- 自動ワンショット
  ord.ind_cond_info->''34''->>''value'' as auto_one_shot,
  -- IP電源自動切り
  ord.ind_cond_info->''35''->>''value'' as ip_auto_off,
  -- IP電源自動切り時間
  ord.ind_cond_info->''36''->>''value'' as ip_auto_off_time,
  -- IP電源OKモニタ切り
  ord.ind_cond_info->''37''->>''value'' as ip_monitor_auto_off,
  -- IP電源OKモニタ切り時間
  ord.ind_cond_info->''38''->>''value'' as ip_monitor_auto_off_time,

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
  CAST(ord.ind_tare_info->>''weight_1'' AS DECIMAL)
    + CAST(ord.ind_tare_info->>''weight_2'' AS DECIMAL)
    + CAST(ord.ind_tare_info->>''weight_3'' AS DECIMAL)
    + CAST(ord.ind_tare_info->>''weight_4'' AS DECIMAL)
    + CAST(ord.ind_tare_info->>''weight_5'' AS DECIMAL)
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
  CAST(ord.ind_off_water_info->>''weight_1'' AS DECIMAL)
    + CAST(ord.ind_off_water_info->>''weight_2'' AS DECIMAL)
    + CAST(ord.ind_off_water_info->>''weight_3'' AS DECIMAL)
    + CAST(ord.ind_off_water_info->>''weight_4'' AS DECIMAL)
    + CAST(ord.ind_off_water_info->>''weight_5'' AS DECIMAL)
    as off_water_weight_total,

  pat_physical_tbl.dw,
  pat_physical_tbl.pre_scale_upper,
  pat_physical_tbl.pre_scale_lower,

  pat_wheel_chair_tbl.wheel_chair_name,
  pat_wheel_chair_tbl.wheel_chair_weight,

  case 
  	when ord.ind_device_mode is null then treatment_tbl.device_mode
	else ord.ind_device_mode 
  end as device_mode,
	case 	
		when date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) <= ord_tbl.treat_date :: TIMESTAMP and ord_tbl.treat_date :: TIMESTAMP < date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) then treatment_tbl.in_hospital_cd_a1 	
		when date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) <= ord_tbl.treat_date :: TIMESTAMP and ord_tbl.treat_date :: TIMESTAMP < date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) then treatment_tbl.in_hospital_cd_b1 	
		when date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) <= ord_tbl.treat_date :: TIMESTAMP and date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) is null then treatment_tbl.in_hospital_cd_a1	
		when date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) <= ord_tbl.treat_date :: TIMESTAMP and date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) is null then treatment_tbl.in_hospital_cd_b1
		when date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) < date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) and date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) <= ord_tbl.treat_date :: TIMESTAMP then treatment_tbl.in_hospital_cd_a1
		when date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) < date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) and date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) <= ord_tbl.treat_date :: TIMESTAMP then treatment_tbl.in_hospital_cd_b1	
		when ord_tbl.treat_date :: TIMESTAMP = date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) and ord_tbl.treat_date :: TIMESTAMP = date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) then treatment_tbl.in_hospital_cd_a1
		else ''''
	end as treatment_in_hospital_cd_1,	
	case 	
		when date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) <= ord_tbl.treat_date :: TIMESTAMP and ord_tbl.treat_date :: TIMESTAMP < date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) then treatment_tbl.in_hospital_cd_a2 	
		when date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) <= ord_tbl.treat_date :: TIMESTAMP and ord_tbl.treat_date :: TIMESTAMP < date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) then treatment_tbl.in_hospital_cd_b2 	
		when date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) <= ord_tbl.treat_date :: TIMESTAMP and date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) is null then treatment_tbl.in_hospital_cd_a2	
		when date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) <= ord_tbl.treat_date :: TIMESTAMP and date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) is null then treatment_tbl.in_hospital_cd_b2
		when date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) < date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) and date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) <= ord_tbl.treat_date :: TIMESTAMP then treatment_tbl.in_hospital_cd_a2
		when date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) < date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) and date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) <= ord_tbl.treat_date :: TIMESTAMP then treatment_tbl.in_hospital_cd_b2	
		when ord_tbl.treat_date :: TIMESTAMP = date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) and ord_tbl.treat_date :: TIMESTAMP = date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) then treatment_tbl.in_hospital_cd_a2
		else ''''
	end as treatment_in_hospital_cd_2,
	case 	
		when date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) <= ord_tbl.treat_date :: TIMESTAMP and ord_tbl.treat_date :: TIMESTAMP < date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) then treatment_tbl.in_hospital_cd_a3 	
		when date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) <= ord_tbl.treat_date :: TIMESTAMP and ord_tbl.treat_date :: TIMESTAMP < date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) then treatment_tbl.in_hospital_cd_b3 	
		when date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) <= ord_tbl.treat_date :: TIMESTAMP and date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) is null then treatment_tbl.in_hospital_cd_a3	
		when date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) <= ord_tbl.treat_date :: TIMESTAMP and date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) is null then treatment_tbl.in_hospital_cd_b3
		when date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) < date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) and date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) <= ord_tbl.treat_date :: TIMESTAMP then treatment_tbl.in_hospital_cd_a3
		when date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) < date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) and date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) <= ord_tbl.treat_date :: TIMESTAMP then treatment_tbl.in_hospital_cd_b3	
		when ord_tbl.treat_date :: TIMESTAMP = date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) and ord_tbl.treat_date :: TIMESTAMP = date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) then treatment_tbl.in_hospital_cd_a3
		else ''''
	end as treatment_in_hospital_cd_3,
	case 	
		when date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) <= ord_tbl.treat_date :: TIMESTAMP and ord_tbl.treat_date :: TIMESTAMP < date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) then treatment_tbl.in_hospital_cd_a4 	
		when date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) <= ord_tbl.treat_date :: TIMESTAMP and ord_tbl.treat_date :: TIMESTAMP < date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) then treatment_tbl.in_hospital_cd_b4 	
		when date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) <= ord_tbl.treat_date :: TIMESTAMP and date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) is null then treatment_tbl.in_hospital_cd_a4	
		when date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) <= ord_tbl.treat_date :: TIMESTAMP and date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) is null then treatment_tbl.in_hospital_cd_b4
		when date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) < date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) and date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) <= ord_tbl.treat_date :: TIMESTAMP then treatment_tbl.in_hospital_cd_a4
		when date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) < date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) and date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) <= ord_tbl.treat_date :: TIMESTAMP then treatment_tbl.in_hospital_cd_b4	
		when ord_tbl.treat_date :: TIMESTAMP = date_trunc(''day'',treatment_tbl.in_hosp_a_startdate) and ord_tbl.treat_date :: TIMESTAMP = date_trunc(''day'',treatment_tbl.in_hosp_b_startdate) then treatment_tbl.in_hospital_cd_a4
		else ''''
	end as treatment_in_hospital_cd_4,
  bed_tbl.*,
  CASE
    WHEN bed_tbl.is_infection IS NULL THEN ''未登録''
    ELSE bed_tbl.is_infection
  END AS bed_is_infection,
	bed_tbl.in_hospital_cd_1 as bed_in_hospital_cd_1,
	bed_tbl.in_hospital_cd_2 as bed_in_hospital_cd_2,
  machine_tbl.*,
  room_bed_group_tbl.room_bed_group_name_list,
  nt.treat_date as next_treat_date,
  ord.ord_no
from
  ord_main as ord

  left join ord_tbl on ord.pat_id = ord_tbl.pat_id
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

  left join medicine_tbl as med_dialysate_tbl on ord.ind_cond_info->''15''->>''value'' = med_dialysate_tbl.medicine_cd::text
  left join medicine_tbl as med_fluid_replacement_tbl on ord.ind_cond_info->''19''->>''value'' = med_fluid_replacement_tbl.medicine_cd::text
  left join medicine_tbl as med_anti_coagulant_tbl on ord.ind_cond_info->''25''->>''value'' = med_anti_coagulant_tbl.medicine_cd::text

  left join medicine_mix_tbl as mix_dialysate_tbl on ord.ind_cond_info->''15''->>''value'' = mix_dialysate_tbl.medicine_mix_cd::text
  left join medicine_mix_tbl as mix_fluid_replacement_tbl on ord.ind_cond_info->''19''->>''value'' = mix_fluid_replacement_tbl.medicine_mix_cd::text
  left join medicine_mix_tbl as mix_anti_coagulant_tbl on ord.ind_cond_info->''25''->>''value'' = mix_anti_coagulant_tbl.medicine_mix_cd::text
  left join next_date as nt on nt.pat_id = ord.pat_id
where
	ord.ord_no = @ordNo
  ', 2, '[{"preview": "HDF", "can_calc": "0", "data_code": "treatment_name", "data_name": "治療方法", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_1", "data_name": "治療方法連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_2", "data_name": "治療方法連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_3", "data_name": "治療方法連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_4", "data_name": "治療方法連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/20", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "透析予定", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "午前", "can_calc": "0", "data_code": "kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "透析予定", "field_name": "kur_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "常勤医", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "full_time_doctor", "data_name": "常勤医", "data_type": "string", "conv_table": [], "data_class": "透析予定", "field_name": "full_time_doctor", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:00", "can_calc": "0", "data_code": "treat_start_time", "data_name": "治療開始時刻", "data_type": "DateTime", "conv_table": [], "data_class": "透析予定", "field_name": "treat_start_time", "disp_format": "hh:mm", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ベッド001", "can_calc": "0", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "透析予定", "field_name": "bed_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/22", "can_calc": "0", "data_code": "next_treat_date", "data_name": "次回透析予定日", "data_type": "DateTime", "conv_table": [], "data_class": "透析予定", "field_name": "next_treat_date", "disp_format": "yyyy/mm/dd", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "04:00", "can_calc": "0", "data_code": "treatment_time", "data_name": "透析時間", "data_type": "DateTime", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_time", "disp_format": "hh:mm", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "240", "can_calc": "0", "data_code": "treatment_time", "data_name": "透析時間(分)", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_time", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左手前腕内シャント化静脈", "can_calc": "0", "data_code": "va_name", "data_name": "VA", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "va_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "va_in_hospital_cd_1", "data_name": "VA連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "va_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "va_in_hospital_cd_2", "data_name": "VA連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "va_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左", "can_calc": "0", "data_code": "va_direct", "data_name": "VA方向", "data_type": "string", "conv_table": [{"code": "0", "disp": "両方", "item": "両方"}, {"code": "1", "disp": "左", "item": "左"}, {"code": "2", "disp": "右", "item": "右"}, {"code": "3", "disp": "なし", "item": "なし"}, {"code": "-", "disp": "不明", "item": "不明"}], "data_class": "透析条件", "field_name": "va_direct", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "1", "data_code": "dw", "data_name": "DW", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dw", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DWと同じ", "can_calc": "0", "data_code": "target_weight_mode", "data_name": "目標体重指定設定", "data_type": "string", "conv_table": [{"code": "0", "disp": "DWと違う", "item": "DWと違う"}, {"code": "1", "disp": "DWと同じ", "item": "DWと同じ"}], "data_class": "透析条件", "field_name": "target_weight_mode", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "0", "data_code": "target_weight", "data_name": "目標体重", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "target_weight", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "HDF", "can_calc": "0", "data_code": "device_mode", "data_name": "装置モード", "data_type": "string", "conv_table": [{"code": "0", "disp": "HD", "item": "HD"}, {"code": "1", "disp": "ECUM", "item": "ECUM"}, {"code": "2", "disp": "HDF", "item": "HDF"}, {"code": "3", "disp": "HF", "item": "HF"}, {"code": "4", "disp": "HD＋補液", "item": "HD＋補液"}, {"code": "5", "disp": "ECUM＋補液", "item": "ECUM＋補液"}, {"code": "6", "disp": "AFBF", "item": "AFBF"}, {"code": "7", "disp": "OHDF", "item": "OHDF"}, {"code": "8", "disp": "OHF", "item": "OHF"}, {"code": "9", "disp": "特殊浄化", "item": "特殊浄化"}, {"code": "10", "disp": "I-HDF", "item": "I-HDF"}, {"code": "-", "disp": "不明", "item": "不明"}], "data_class": "透析条件", "field_name": "device_mode", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "0", "data_code": "water_removal_amount_limit", "data_name": "除水量制限", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "water_removal_amount_limit", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "FDX-120GW", "can_calc": "0", "data_code": "dialyzer_name", "data_name": "ダイアライザ", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "dialyzer_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リクセルS-15", "can_calc": "0", "data_code": "adsorption_column_name", "data_name": "吸着カラム", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "adsorption_column_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "adsorption_in_hospital_cd_1", "data_name": "吸着カラム連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "adsorption_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "adsorption_in_hospital_cd_2", "data_name": "吸着カラム連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "adsorption_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "adsorption_in_hospital_cd_3", "data_name": "吸着カラム連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "adsorption_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "adsorption_in_hospital_cd_4", "data_name": "吸着カラム連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "adsorption_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト１次膜", "can_calc": "0", "data_code": "primary_film_name", "data_name": "1次膜", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "primary_film_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "primary_film_in_hospital_cd_1", "data_name": "1次膜連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "primary_film_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "primary_film_in_hospital_cd_2", "data_name": "1次膜連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "primary_film_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "primary_film_in_hospital_cd_3", "data_name": "1次膜連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "primary_film_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "primary_film_in_hospital_cd_4", "data_name": "1次膜連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "primary_film_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト２次膜", "can_calc": "0", "data_code": "secondary_film_name", "data_name": "2次膜", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "secondary_film_name", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "secondary_film_in_hospital_cd_1", "data_name": "2次膜連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "secondary_film_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "secondary_film_in_hospital_cd_2", "data_name": "2次膜連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "secondary_film_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "secondary_film_in_hospital_cd_3", "data_name": "2次膜連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "secondary_film_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "secondary_film_in_hospital_cd_4", "data_name": "2次膜連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "secondary_film_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針A針", "can_calc": "0", "data_code": "puncture_needle_a_name", "data_name": "穿刺針A針名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "puncture_needle_a_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_a_in_hospital_cd_1", "data_name": "穿刺針A針連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_a_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_a_in_hospital_cd_2", "data_name": "穿刺針A針連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_a_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_a_in_hospital_cd_3", "data_name": "穿刺針A針連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_a_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_a_in_hospital_cd_4", "data_name": "穿刺針A針連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_a_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針V針", "can_calc": "0", "data_code": "puncture_needle_v_name", "data_name": "穿刺針V針名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "puncture_needle_v_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_v_in_hospital_cd_1", "data_name": "穿刺針V針連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_v_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_v_in_hospital_cd_2", "data_name": "穿刺針V針連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_v_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_v_in_hospital_cd_3", "data_name": "穿刺針V針連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_v_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_v_in_hospital_cd_4", "data_name": "穿刺針V針連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_v_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針S針", "can_calc": "0", "data_code": "puncture_needle_s_name", "data_name": "穿刺針S針名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "puncture_needle_sn_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_s_in_hospital_cd_1", "data_name": "穿刺針S針連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_s_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_s_in_hospital_cd_2", "data_name": "穿刺針S針連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_s_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_s_in_hospital_cd_3", "data_name": "穿刺針S針連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_s_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_s_in_hospital_cd_4", "data_name": "穿刺針S針連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_s_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "1", "data_code": "single_needle", "data_name": "シングルニードル使用", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "透析条件", "field_name": "single_needle", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "血液回路", "can_calc": "0", "data_code": "blood_circuit_name", "data_name": "血液回路名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "blood_circuit_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "bc_in_hospital_cd_1", "data_name": "血液回路連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "bc_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "bc_in_hospital_cd_2", "data_name": "血液回路連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "bc_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "bc_in_hospital_cd_3", "data_name": "血液回路連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "bc_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "bc_in_hospital_cd_4", "data_name": "血液回路連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "bc_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "180", "can_calc": "1", "data_code": "blood_flow", "data_name": "血流量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "blood_flow", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/min", "can_calc": "0", "data_code": "blood_flow_unit", "data_name": "血流量単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "blood_flow_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "Dドライ3.0S", "can_calc": "0", "data_code": "dialysate_name", "data_name": "透析液", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/min", "can_calc": "0", "data_code": "dialysate_amount_unit", "data_name": "透析液単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_amount_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialysate_in_hospital_cd_1", "data_name": "透析液連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialysate_in_hospital_cd_2", "data_name": "透析液連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialysate_in_hospital_cd_3", "data_name": "透析液連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialysate_in_hospital_cd_4", "data_name": "透析液連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "dialysate_flow_rate", "data_name": "透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_flow_rate", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/min", "can_calc": "0", "data_code": "dialysate_flow_rate_unit", "data_name": "透析液流量単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_flow_rate_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120.00", "can_calc": "1", "data_code": "dialysate_amount", "data_name": "透析液使用数", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_amount", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レ袋", "can_calc": "0", "data_code": "dialysate_amount_unit", "data_name": "透析液使用数単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_amount_unit", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.0", "can_calc": "1", "data_code": "dialysate_temperature", "data_name": "透析液温度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_temperature", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト補液", "can_calc": "0", "data_code": "fluid_replacement_name", "data_name": "補液", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "L", "can_calc": "0", "data_code": "fluid_replacement_unit", "data_name": "補液単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "fluid_in_hospital_cd_1", "data_name": "補液連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "fluid_in_hospital_cd_2", "data_name": "補液連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "fluid_in_hospital_cd_3", "data_name": "補液連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "fluid_in_hospital_cd_4", "data_name": "補液連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "8.0", "can_calc": "1", "data_code": "fluid_replacement_amount", "data_name": "補液量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_amount", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "L", "can_calc": "0", "data_code": "fluid_replacement_amount_unit", "data_name": "補液量単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_amount_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "前補液", "can_calc": "0", "data_code": "fluid_replacement_timing", "data_name": "補液選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "後補液", "item": "後補液"}, {"code": "1", "disp": "前補液", "item": "前補液"}], "data_class": "透析条件", "field_name": "fluid_replacement_timing", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "1", "data_code": "fluid_replacement_use_count", "data_name": "補液使用数", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_use_count", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ml", "can_calc": "0", "data_code": "fluid_replacement_use_count_unit", "data_name": "補液使用数単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_use_count_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.0", "can_calc": "1", "data_code": "fluid_replacement_temperature", "data_name": "補液温度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_temperature", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.00", "can_calc": "1", "data_code": "fluid_replacement_speed", "data_name": "補液速度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_speed", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "L/h", "can_calc": "0", "data_code": "fluid_replacement_speed_unit", "data_name": "補液速度単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_speed_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "フサン", "can_calc": "0", "data_code": "anti_coagulant_name", "data_name": "抗凝固剤", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "U", "can_calc": "0", "data_code": "anti_coagulant_unit", "data_name": "抗凝固剤単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "anti_in_hospital_cd_1", "data_name": "抗凝固剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "anti_in_hospital_cd_2", "data_name": "抗凝固剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "anti_in_hospital_cd_3", "data_name": "抗凝固剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "anti_in_hospital_cd_4", "data_name": "抗凝固剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1000", "can_calc": "1", "data_code": "anti_coagulant_one_shot_amount", "data_name": "抗凝固剤ワンショット量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_one_shot_amount", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "U", "can_calc": "0", "data_code": "anti_coagulant_one_shot_amount_unit", "data_name": "抗凝固剤ワンショット量単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_one_shot_amount_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "anti_coagulant_sustained_speed", "data_name": "抗凝固剤持続速度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_sustained_speed", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "U/h", "can_calc": "0", "data_code": "anti_coagulant_sustained_speed_unit", "data_name": "抗凝固剤持続速度単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_sustained_speed_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2000", "can_calc": "1", "data_code": "anti_coagulant_sustained_amount", "data_name": "抗凝固剤持続総量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_sustained_amount", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "U", "can_calc": "0", "data_code": "anti_coagulant_sustained_amount_unit", "data_name": "抗凝固剤持続総量単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_sustained_amount_unit", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3000", "can_calc": "0", "data_code": "anti_coagulant_total_amount", "data_name": "抗凝固剤総量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_total_amount", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "ip", "data_name": "IP使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "透析条件", "field_name": "ip", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "自動", "can_calc": "0", "data_code": "ip_start", "data_name": "IPスタート", "data_type": "string", "conv_table": [{"code": "0", "disp": "手動", "item": "手動"}, {"code": "1", "disp": "自動", "item": "自動"}], "data_class": "透析条件", "field_name": "ip_start", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ip_one_shot_amount", "data_name": "IPワンショット量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_one_shot_amount", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.2", "can_calc": "1", "data_code": "ip_speed", "data_name": "IP速度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/h", "can_calc": "0", "data_code": "ip_speed_unit", "data_name": "IP速度単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "1", "data_code": "ip_speed_max", "data_name": "IP速度最大値", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed_max", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/h", "can_calc": "0", "data_code": "ip_speed_max_unit", "data_name": "IP速度最大値単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed_max_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "自動", "can_calc": "0", "data_code": "auto_one_shot", "data_name": "IPワンショットスタート", "data_type": "string", "conv_table": [{"code": "0", "disp": "手動", "item": "手動"}, {"code": "1", "disp": "自動", "item": "自動"}], "data_class": "透析条件", "field_name": "auto_one_shot", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL", "can_calc": "0", "data_code": "ip_one_shot_amount_unit", "data_name": "自動ワンショット単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "ip_one_shot_amount_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切", "can_calc": "0", "data_code": "ip_auto_off", "data_name": "IP電源自動切り", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "透析条件", "field_name": "ip_auto_off", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ip_auto_off_time", "data_name": "IP電源自動切り時間", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_auto_off_time", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切", "can_calc": "0", "data_code": "ip_monitor_auto_off", "data_name": "IP電源OKモニタ切り", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "透析条件", "field_name": "ip_monitor_auto_off", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ip_monitor_auto_off_time", "data_name": "IP電源OKモニタ切り時間", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_monitor_auto_off_time", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "スリッパ", "can_calc": "0", "data_code": "tare_name1", "data_name": "風袋名称１", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_name1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "tare_weight1", "data_name": "風袋重量１", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_weight1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "服", "can_calc": "0", "data_code": "tare_name2", "data_name": "風袋名称２", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_name2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "tare_weight2", "data_name": "風袋重量２", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_weight2", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "義足", "can_calc": "1", "data_code": "tare_name3", "data_name": "風袋名称３", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_name3", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1200", "can_calc": "0", "data_code": "tare_weight3", "data_name": "風袋重量３", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_weight3", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋１", "can_calc": "0", "data_code": "tare_name4", "data_name": "風袋名称４", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_name4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "tare_weight4", "data_name": "風袋重量４", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_weight4", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋２", "can_calc": "0", "data_code": "tare_name5", "data_name": "風袋名称５", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_name5", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "tare_weight5", "data_name": "風袋重量５", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_weight5", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1800", "can_calc": "0", "data_code": "tare_weight_total", "data_name": "風袋重量合計", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_weight_total", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "食事量", "can_calc": "0", "data_code": "off_water_name1", "data_name": "除水補正名称１", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "off_water_weight1", "data_name": "除水補正重量１", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight1", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "プライミング", "can_calc": "0", "data_code": "off_water_name2", "data_name": "除水補正名称２", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "0", "data_code": "off_water_weight2", "data_name": "除水補正重量２", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight2", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "輸液量", "can_calc": "0", "data_code": "off_water_name3", "data_name": "除水補正名称３", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "off_water_weight3", "data_name": "除水補正重量３", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight3", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他（不感蒸泄）", "can_calc": "0", "data_code": "off_water_name4", "data_name": "除水補正名称４", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "off_water_weight4", "data_name": "除水補正重量４", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight4", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他", "can_calc": "0", "data_code": "off_water_name5", "data_name": "除水補正名称５", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name5", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "off_water_weight5", "data_name": "除水補正重量５", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight5", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "900", "can_calc": "0", "data_code": "off_water_weight_total", "data_name": "除水補正重量合計", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_total", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.00", "can_calc": "0", "data_code": "pre_scale_upper", "data_name": "前体重許容割合（上限）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "pre_scale_upper", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.00", "can_calc": "0", "data_code": "pre_scale_lower", "data_name": "前体重許容割合（下限）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "pre_scale_lower", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "車椅子１", "can_calc": "0", "data_code": "wheel_chair_name", "data_name": "車椅子名称", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "wheel_chair_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15000", "can_calc": "1", "data_code": "wheel_chair_weight", "data_name": "車椅子重量", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "wheel_chair_weight", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ベッド001", "can_calc": "0", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "bed_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左", "can_calc": "0", "data_code": "shunt_position", "data_name": "シャント位置", "data_type": "string", "conv_table": [{"code": "0", "disp": "両方", "item": "両方"}, {"code": "1", "disp": "左", "item": "左"}, {"code": "2", "disp": "右", "item": "右"}, {"code": "3", "disp": "なし", "item": "なし"}, {"code": "-", "disp": "不明", "item": "不明"}], "data_class": "ベッド情報", "field_name": "shunt_position", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "感染症あり", "can_calc": "0", "data_code": "is_infection", "data_name": "感染症対応", "data_type": "string", "conv_table": [{"code": "0", "disp": "感染症なし", "item": "感染症なし"}, {"code": "1", "disp": "感染症あり", "item": "感染症あり"}], "data_class": "ベッド情報", "field_name": "is_infection", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常ベッド", "can_calc": "0", "data_code": "emergency_class", "data_name": "緊急区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "通常ベッド", "item": "通常ベッド"}, {"code": "1", "disp": "緊急ベッド", "item": "緊急ベッド"}], "data_class": "ベッド情報", "field_name": "emergency_class", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "Aグループ", "can_calc": "0", "data_code": "room_bed_group_name_list", "data_name": "透析室・ベッドグループ名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "room_bed_group_name_list", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "装置001", "can_calc": "0", "data_code": "machine_name", "data_name": "装置名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "machine_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "BED001", "can_calc": "0", "data_code": "bed_in_hospital_cd_1", "data_name": "ベッド連携コード1", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "bed_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "BED002", "can_calc": "0", "data_code": "bed_in_hospital_cd_2", "data_name": "ベッド連携コード2", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "bed_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装", "can_calc": "0", "data_code": "maker", "data_name": "メーカー", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "maker", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "中空糸", "can_calc": "0", "data_code": "dialyzer_type", "data_name": "ダイアライザ種別", "data_type": "string", "conv_table": [{"code": "0", "disp": "中空糸", "item": "中空糸"}, {"code": "1", "disp": "積層", "item": "積層"}], "data_class": "ダイアライザ情報", "field_name": "dialyzer_type", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "function_class", "data_name": "機能分類", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "function_class", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.2", "can_calc": "0", "data_code": "area", "data_name": "面積", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "area", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "45.00", "can_calc": "0", "data_code": "ufr", "data_name": "UFR", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "ufr", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "0", "data_code": "koa", "data_name": "KOA", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "koa", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "親水化PEPA", "can_calc": "0", "data_code": "material", "data_name": "材質", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "material", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "WET", "can_calc": "0", "data_code": "wetdry", "data_name": "WET/DRY", "data_type": "string", "conv_table": [{"code": "0", "disp": "不明", "item": "不明"}, {"code": "1", "disp": "WET", "item": "WET"}, {"code": "2", "disp": "DRY", "item": "DRY"}], "data_class": "ダイアライザ情報", "field_name": "wetdry", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "γ線", "can_calc": "0", "data_code": "sterilization", "data_name": "滅菌", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "sterilization", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "1", "data_code": "ufr_warning_max", "data_name": "UFR警告点上限", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "ufr_warning_max", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "ufr_warning_min", "data_name": "UFR警告点下限", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "ufr_warning_min", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "1", "data_code": "ufr_warning_reduction", "data_name": "UFR低下警報点", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "ufr_warning_reduction", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "0", "data_code": "bloodamt", "data_name": "血流量", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "bloodamt", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "alqd_flood_vol", "data_name": "透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "alqd_flood_vol", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "190", "can_calc": "0", "data_code": "urea_clearance", "data_name": "尿素クリアランス", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "urea_clearance", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "0", "data_code": "gas_purge_time", "data_name": "ガスパージ時間", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "gas_purge_time", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1000", "can_calc": "0", "data_code": "substituent_wash_amt", "data_name": "置換洗浄量（透析液）", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "substituent_wash_amt", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "membrane_wash", "data_name": "膜洗浄（中空糸）", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "ダイアライザ情報", "field_name": "membrane_wash", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "in_number", "data_name": "入り数", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "in_number", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2025/01/01", "can_calc": "0", "data_code": "use_start_date", "data_name": "使用開始日", "data_type": "DateTime", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "use_start_date", "disp_format": "yyyy/mm/dd", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2025/12/31", "can_calc": "0", "data_code": "use_end_date", "data_name": "使用終了日", "data_type": "DateTime", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "use_end_date", "disp_format": "yyyy/mm/dd", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialyzer_in_hospital_cd_1", "data_name": "ダイアライザ連携コード１", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "dialyzer_in_hospital_cd_1", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialyzer_in_hospital_cd_2", "data_name": "ダイアライザ連携コード２", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "dialyzer_in_hospital_cd_2", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialyzer_in_hospital_cd_3", "data_name": "ダイアライザ連携コード３", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "dialyzer_in_hospital_cd_3", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialyzer_in_hospital_cd_4", "data_name": "ダイアライザ連携コード４", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "dialyzer_in_hospital_cd_4", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '指示：透析条件/ベッド情報/ダイアライザ情報　@ordNo使用', '2020-03-26 17:10:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (95, 'WITH
ord_tbl as (
  select
    facility_cd,
    pat_id,
    rst_bed_cd,
    to_timestamp(treat_date, ''yyyymmdd'') + ''1 days - 1 milliseconds'' as treat_date_end
  from ord_main
  where 
  facility_cd = @facilityCd
  and ord_no = @ordNo
  and is_del = ''0''
)
, bed_group_tbl AS (
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
)
, room_tbl AS (
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
)
, pat_physical_tbl AS (
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
)
, pat_wheel_chair_tbl AS (
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
        facility_cd = @facilityCd
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
)
,equipment_tbl as (
  select
    *
  from
    mst_equipment
  where
    mst_equipment.facility_cd = @facilityCd
  and
    mst_equipment.is_disp = ''1''
  and
    mst_equipment.is_del = ''0''
-- 指定患者、基準日以前のDWがある身体情報を取得
)
,oms_puncture_needle_a_tbl as (
	SELECT
		*
	FROM
		ord_material_save oms
	WHERE
		facility_cd = @facilityCd
		AND oms.supplies_base_no = @ordNo
		AND supplies_source_class = ''0''
		AND supplies_class = ''06''
		AND ind_rst_class=''2''

)
,oms_puncture_needle_v_tbl as (
	SELECT
		*
	FROM
		ord_material_save oms
	WHERE
		facility_cd = @facilityCd
		AND oms.supplies_base_no = @ordNo
		AND supplies_source_class = ''0''
		AND supplies_class = ''07''
		AND ind_rst_class=''2''

)
,oms_puncture_needle_sn_tbl as (
	SELECT
		*
	FROM
		ord_material_save oms
	WHERE
		facility_cd = @facilityCd
		AND oms.supplies_base_no = @ordNo
		AND supplies_source_class = ''0''
		AND supplies_class = ''05''
		AND ind_rst_class=''2''

)
,oms_blood_circuit_tbl as (
	SELECT
		*
	FROM
		ord_material_save oms
	WHERE
		facility_cd = @facilityCd
		AND oms.supplies_base_no = @ordNo
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
	ord.facility_cd = @facilityCd
	AND ord.ord_no = @ordNo
	AND ord.rst_dialysis_state > ''0''
 and ord.is_del = ''0''
', 2, '[{"preview": "2011/3/12", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/3/12 08:21", "can_calc": "0", "data_code": "treat_start_time", "data_name": "透析開始時刻", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "treat_start_time", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/3/12 12:45", "can_calc": "0", "data_code": "treat_end_time", "data_name": "透析終了時刻", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "treat_end_time", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "0", "data_code": "treatment_time", "data_name": "透析時間", "data_type": "decimal", "conv_table": [], "data_class": "", "field_name": "treatment_time", "disp_format": "0", "data_category": "", "facility_table": "", "facility_filter_type": "0"}, {"preview": "89", "can_calc": "1", "data_code": "rst_dialysis_cnt", "data_name": "透析回数", "data_type": "decimal", "conv_table": [], "data_class": "実績情報", "field_name": "rst_dialysis_cnt", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "89", "can_calc": "1", "data_code": "rst_purification_cnt", "data_name": "特殊浄化回数", "data_type": "decimal", "conv_table": [], "data_class": "実績情報", "field_name": "rst_purification_cnt", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "外来", "can_calc": "0", "data_code": "rst_in_out_class", "data_name": "入外区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "外来", "item": "外来"}, {"code": "1", "disp": "入院", "item": "入院"}], "data_class": "実績情報", "field_name": "rst_in_out_class", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "A棟", "can_calc": "0", "data_code": "rst_ward_name", "data_name": "病棟名", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_ward_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_ward_in_hospital_cd_1", "data_name": "病棟連携コード", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_ward_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "泌尿器科", "can_calc": "0", "data_code": "rst_course_name", "data_name": "診療科名", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_course_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "泌尿器科", "can_calc": "0", "data_code": "rst_course_in_hospital_cd_1", "data_name": "診療科連携コード", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_course_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:01", "can_calc": "0", "data_code": "rst_accept_date", "data_name": "受付時刻", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_accept_date", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13:02", "can_calc": "0", "data_code": "rst_return_home_date", "data_name": "帰宅時刻", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_home_date", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_charge_user_id_1", "data_name": "担当者ID１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_user_id_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "rst_charge_user_name1", "data_name": "担当者名１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_user_name1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:03", "can_calc": "0", "data_code": "rst_charge_date1", "data_name": "担当日時１", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_date1", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_charge_user_id_2", "data_name": "担当者ID２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_user_id_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師２", "can_calc": "0", "data_code": "rst_charge_user_name2", "data_name": "担当者名２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_user_name2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:04", "can_calc": "0", "data_code": "rst_charge_date2", "data_name": "担当日時２", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_charge_date2", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_puncture_user_id_1", "data_name": "穿刺者ID１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_user_id_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士１", "can_calc": "0", "data_code": "rst_puncture_user_name1", "data_name": "穿刺者名１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_user_name1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:16", "can_calc": "0", "data_code": "rst_puncture_date1", "data_name": "穿刺日時１", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_date1", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_puncture_user_id_2", "data_name": "穿刺者ID２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_user_id_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "data_code": "rst_puncture_user_name2", "data_name": "穿刺者名２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_user_name2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "08:16", "can_calc": "0", "data_code": "rst_puncture_date2", "data_name": "穿刺日時２", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_puncture_date2", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_return_user_id_1", "data_name": "返血者ID１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_user_id_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "rst_return_user_name1", "data_name": "返血者名１", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_user_name1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:51", "can_calc": "0", "data_code": "rst_return_date1", "data_name": "返血日時１", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_date1", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "rst_return_user_id_2", "data_name": "返血者ID２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_user_id_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士２", "can_calc": "0", "data_code": "rst_return_user_name2", "data_name": "返血者名２", "data_type": "string", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_user_name2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12:51", "can_calc": "0", "data_code": "rst_return_date2", "data_name": "返血日時２", "data_type": "DateTime", "conv_table": [], "data_class": "実績情報", "field_name": "rst_return_date2", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "04: 00", "can_calc": "0", "data_code": "treatment_time", "data_name": "透析時間", "data_type": "DateTime", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_time", "disp_format": "[h]: mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "420", "can_calc": "0", "data_code": "treatment_time", "data_name": "透析時間(分)", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_time", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左手前腕部シャント化静脈", "can_calc": "0", "data_code": "va_name", "data_name": "VA", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "va_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "va_in_hospital_cd_1", "data_name": "VA連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "va_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "va_in_hospital_cd_2", "data_name": "VA連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "va_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左", "can_calc": "0", "data_code": "va_direct", "data_name": "VA方向", "data_type": "string", "conv_table": [{"code": "0", "disp": "右", "item": "右"}, {"code": "1", "disp": "左", "item": "左"}, {"code": "2", "disp": "両方", "item": "両方"}, {"code": "3", "disp": "なし", "item": "なし"}, {"code": "-", "disp": "不明", "item": "不明"}], "data_class": "透析条件", "field_name": "va_direct", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "1", "data_code": "dw", "data_name": "DW", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dw", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DWと同じ", "can_calc": "0", "data_code": "target_weight_mode", "data_name": "目標体重指定設定", "data_type": "string", "conv_table": [{"code": "0", "disp": "DWと違う", "item": "DWと違う"}, {"code": "1", "disp": "DWと同じ", "item": "DWと同じ"}], "data_class": "透析条件", "field_name": "target_weight_mode", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "1", "data_code": "target_weight", "data_name": "目標体重", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "target_weight", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "HDF", "can_calc": "0", "data_code": "treatment_name", "data_name": "治療方法", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_treatment_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "HDF", "can_calc": "0", "data_code": "device_mode", "data_name": "装置モード", "data_type": "string", "conv_table": [{"code": "-1", "disp": "不明", "item": "不明"}, {"code": "0", "disp": "HD", "item": "HD"}, {"code": "1", "disp": "ECUM", "item": "ECUM"}, {"code": "2", "disp": "HDF", "item": "HDF"}, {"code": "3", "disp": "HF", "item": "HF"}, {"code": "4", "disp": "HD+補液", "item": "HD+補液"}, {"code": "5", "disp": "ECUM+補液", "item": "ECUM+補液"}, {"code": "6", "disp": "AFBF", "item": "AFBF"}, {"code": "7", "disp": "OHDF", "item": "OHDF"}, {"code": "8", "disp": "OHF", "item": "OHF"}, {"code": "9", "disp": "特殊浄化", "item": "特殊浄化"}, {"code": "10", "disp": "I-HDF", "item": "I-HDF"}], "data_class": "透析条件", "field_name": "device_mode", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "1", "data_code": "water_removal_amount_limit", "data_name": "除水量制限", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "water_removal_amount_limit", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "FDX-120GW", "can_calc": "0", "data_code": "dialyzer_name", "data_name": "ダイアライザ", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "dialyzer_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト１次膜", "can_calc": "0", "data_code": "primary_film_name", "data_name": "1次膜", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "primary_film_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_primary_film_in_hospital_cd_1", "data_name": "1次膜連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_primary_film_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_primary_film_in_hospital_cd_2", "data_name": "1次膜連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_primary_film_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_primary_film_in_hospital_cd_3", "data_name": "1次膜連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_primary_film_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_primary_film_in_hospital_cd_4", "data_name": "1次膜連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_primary_film_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト２次膜", "can_calc": "0", "data_code": "secondary_film_name", "data_name": "2次膜", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "secondary_film_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_secondary_film_in_hospital_cd_1", "data_name": "2次膜連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_secondary_film_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_secondary_film_in_hospital_cd_2", "data_name": "2次膜連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_secondary_film_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_secondary_film_in_hospital_cd_3", "data_name": "2次膜連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_secondary_film_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_secondary_film_in_hospital_cd_4", "data_name": "2次膜連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_secondary_film_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リクセルS-15", "can_calc": "0", "data_code": "adsorption_column_name", "data_name": "吸着カラム", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "adsorption_column_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_adsorption_in_hospital_cd_1", "data_name": "吸着カラム連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_adsorption_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_adsorption_in_hospital_cd_2", "data_name": "吸着カラム連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_adsorption_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_adsorption_in_hospital_cd_3", "data_name": "吸着カラム連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_adsorption_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_adsorption_in_hospital_cd_4", "data_name": "吸着カラム連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_adsorption_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "180", "can_calc": "1", "data_code": "blood_flow", "data_name": "血流量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "blood_flow", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "Dドライ3.0S", "can_calc": "0", "data_code": "dialysate_name", "data_name": "透析液", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialysate_in_hospital_cd_1", "data_name": "透析液連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialysate_in_hospital_cd_2", "data_name": "透析液連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialysate_in_hospital_cd_3", "data_name": "透析液連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialysate_in_hospital_cd_4", "data_name": "透析液連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/min", "can_calc": "0", "data_code": "dialysate_amount_unit", "data_name": "透析液単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_amount_unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "dialysate_flow_rate", "data_name": "透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_flow_rate", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120.00", "can_calc": "1", "data_code": "dialysate_amount", "data_name": "透析液量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_amount", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.0", "can_calc": "1", "data_code": "dialysate_temperature", "data_name": "透析液温度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_temperature", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト補液", "can_calc": "0", "data_code": "fluid_replacement_name", "data_name": "補液", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_fluid_in_hospital_cd_1", "data_name": "補液連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_fluid_in_hospital_cd_2", "data_name": "補液連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_fluid_in_hospital_cd_3", "data_name": "補液連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_fluid_in_hospital_cd_4", "data_name": "補液連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "L", "can_calc": "0", "data_code": "fluid_replacement_unit", "data_name": "補液単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "8.0", "can_calc": "1", "data_code": "fluid_replacement_amount", "data_name": "補液量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_amount", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.0", "can_calc": "1", "data_code": "fluid_replacement_speed", "data_name": "補液速度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_speed", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "後補液", "can_calc": "0", "data_code": "fluid_replacement_timing", "data_name": "補液選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "後補液", "item": "後補液"}, {"code": "1", "disp": "前補液", "item": "前補液"}], "data_class": "透析条件", "field_name": "fluid_replacement_timing", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "1", "data_code": "fluid_replacement_use_count", "data_name": "補液使用数", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_use_count", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.0", "can_calc": "1", "data_code": "fluid_replacement_temperature", "data_name": "補液温度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_temperature", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト抗凝固剤", "can_calc": "0", "data_code": "anti_coagulant_name", "data_name": "抗凝固剤", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_anti_in_hospital_cd_1", "data_name": "抗凝固剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_anti_in_hospital_cd_2", "data_name": "抗凝固剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_anti_in_hospital_cd_3", "data_name": "抗凝固剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_anti_in_hospital_cd_4", "data_name": "抗凝固剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "U", "can_calc": "0", "data_code": "anti_coagulant_unit", "data_name": "抗凝固剤単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1000", "can_calc": "1", "data_code": "anti_coagulant_one_shot_amount", "data_name": "抗凝固剤ワンショット量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_one_shot_amount", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "anti_coagulant_sustained_speed", "data_name": "抗凝固剤持続速度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_sustained_speed", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "U/h", "can_calc": "0", "data_code": "anti_coagulant_sustained_speed_unit", "data_name": "抗凝固剤持続速度単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_sustained_speed_unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2000", "can_calc": "1", "data_code": "anti_coagulant_sustained_amount", "data_name": "抗凝固剤持続総量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_sustained_amount", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3000", "can_calc": "1", "data_code": "anti_coagulant_total_amount", "data_name": "抗凝固剤総量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_total_amount", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "する", "can_calc": "0", "data_code": "ip", "data_name": "IP使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "透析条件", "field_name": "ip", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "自動", "can_calc": "0", "data_code": "ip_start", "data_name": "IPスタート", "data_type": "string", "conv_table": [{"code": "0", "disp": "手動", "item": "手動"}, {"code": "1", "disp": "自動", "item": "自動"}], "data_class": "透析条件", "field_name": "ip_start", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.2", "can_calc": "1", "data_code": "ip_speed", "data_name": "IP速度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/h", "can_calc": "0", "data_code": "ip_speed_unit", "data_name": "IP速度単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed_unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "1", "data_code": "ip_speed_max", "data_name": "IP速度最大値", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed_max", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/h", "can_calc": "0", "data_code": "ip_speed_max_unit", "data_name": "IP速度最大値単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed_max_unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "自動", "can_calc": "0", "data_code": "auto_one_shot", "data_name": "IPワンショットスタート", "data_type": "string", "conv_table": [{"code": "0", "disp": "手動", "item": "手動"}, {"code": "1", "disp": "自動", "item": "自動"}], "data_class": "透析条件", "field_name": "auto_one_shot", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ip_one_shot_amount", "data_name": "IPワンショット量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_one_shot_amount", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL", "can_calc": "0", "data_code": "ip_one_shot_amount_unit", "data_name": "IPワンショット量単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "ip_one_shot_amount_unit", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切", "can_calc": "0", "data_code": "ip_auto_off", "data_name": "IP電源自動切り", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "透析条件", "field_name": "ip_auto_off", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ip_auto_off_time", "data_name": "IP電源自動切り時間", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_auto_off_time", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切", "can_calc": "0", "data_code": "ip_monitor_auto_off", "data_name": "IP電源OKモニタ切り", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "透析条件", "field_name": "ip_monitor_auto_off", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "1", "data_code": "ip_monitor_auto_off_time", "data_name": "IP電源OKモニタ切り時間", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_monitor_auto_off_time", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "しない", "can_calc": "0", "data_code": "single_needle", "data_name": "シングルニードル使用", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "透析条件", "field_name": "single_needle", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針A", "can_calc": "0", "data_code": "puncture_needle_a_name", "data_name": "穿刺針A針名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "puncture_needle_a_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_a_in_hospital_cd_1", "data_name": "穿刺針A針連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_a_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_a_in_hospital_cd_2", "data_name": "穿刺針A針連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_a_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_a_in_hospital_cd_3", "data_name": "穿刺針A針連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_a_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_a_in_hospital_cd_4", "data_name": "穿刺針A針連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_a_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針V針", "can_calc": "0", "data_code": "puncture_needle_v_name", "data_name": "穿刺針V針名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "puncture_needle_v_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_v_in_hospital_cd_1", "data_name": "穿刺針V針連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_v_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_v_in_hospital_cd_2", "data_name": "穿刺針V針連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_v_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_v_in_hospital_cd_3", "data_name": "穿刺針V針連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_v_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_v_in_hospital_cd_4", "data_name": "穿刺針V針連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_v_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針S針", "can_calc": "0", "data_code": "puncture_needle_s_name", "data_name": "穿刺針S針名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "puncture_needle_s_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_s_in_hospital_cd_1", "data_name": "穿刺針S針連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_s_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_s_in_hospital_cd_2", "data_name": "穿刺針S針連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_s_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_s_in_hospital_cd_3", "data_name": "穿刺針S針連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_s_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_pn_s_in_hospital_cd_4", "data_name": "穿刺針S針連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_pn_s_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "血液回路", "can_calc": "0", "data_code": "blood_circuit_name", "data_name": "血液回路名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "blood_circuit_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_bc_in_hospital_cd_1", "data_name": "血液回路連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_bc_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_bc_in_hospital_cd_2", "data_name": "血液回路連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_bc_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_bc_in_hospital_cd_3", "data_name": "血液回路連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_bc_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_bc_in_hospital_cd_4", "data_name": "血液回路連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_bc_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左", "can_calc": "0", "data_code": "shunt_position", "data_name": "シャント位置", "data_type": "string", "conv_table": [{"code": "0", "disp": "右", "item": "右"}, {"code": "1", "disp": "左", "item": "左"}, {"code": "2", "disp": "両方", "item": "両方"}, {"code": "3", "disp": "なし", "item": "なし"}, {"code": "-", "disp": "不明", "item": "不明"}], "data_class": "ベッド情報", "field_name": "shunt_position", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "感染症あり", "can_calc": "0", "data_code": "is_infection", "data_name": "感染症対応", "data_type": "string", "conv_table": [{"code": "0", "disp": "感染症なし", "item": "感染症なし"}, {"code": "1", "disp": "感染症あり", "item": "感染症あり"}], "data_class": "ベッド情報", "field_name": "is_infection", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常ベッド", "can_calc": "0", "data_code": "emergency_class", "data_name": "緊急区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "通常ベッド", "item": "通常ベッド"}, {"code": "1", "disp": "緊急ベッド", "item": "緊急ベッド"}], "data_class": "ベッド情報", "field_name": "emergency_class", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "Aグループ", "can_calc": "0", "data_code": "bed_group_name", "data_name": "ベッドグループ名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "bed_group_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "第二透析室", "can_calc": "0", "data_code": "room_name", "data_name": "透析室名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "room_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "装置001", "can_calc": "0", "data_code": "machine_name", "data_name": "装置名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "machine_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装", "can_calc": "0", "data_code": "maker", "data_name": "メーカー", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "maker", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "function_class", "data_name": "機能分類", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "function_class", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.2", "can_calc": "1", "data_code": "area", "data_name": "面積", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "area", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "45.00", "can_calc": "1", "data_code": "ufr", "data_name": "UFR", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "ufr", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "1", "data_code": "koa", "data_name": "KOA", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "koa", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "親水化PEPA", "can_calc": "0", "data_code": "material", "data_name": "材質", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "material", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "WET", "can_calc": "0", "data_code": "wetdry", "data_name": "WET/DRY", "data_type": "string", "conv_table": [{"code": "0", "disp": "不明", "item": "不明"}, {"code": "1", "disp": "WET", "item": "WET"}, {"code": "2", "disp": "DRY", "item": "DRY"}], "data_class": "ダイアライザ情報", "field_name": "wetdry", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "γ線滅菌", "can_calc": "0", "data_code": "sterilization", "data_name": "滅菌", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "sterilization", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "0", "data_code": "bloodamt", "data_name": "血流量", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "bloodamt", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "alqd_flood_vol", "data_name": "透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "alqd_flood_vol", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "190", "can_calc": "0", "data_code": "urea_clearance", "data_name": "尿素クリアランス", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "urea_clearance", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "1", "data_code": "gas_purge_time", "data_name": "ガスパージ時間", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "gas_purge_time", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1000", "can_calc": "1", "data_code": "substituent_wash_amt", "data_name": "置換洗浄量（透析液）", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "substituent_wash_amt", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "membrane_wash", "data_name": "膜洗浄（中空糸）", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "ダイアライザ情報", "field_name": "membrane_wash", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialyzer_in_hospital_cd_1", "data_name": "ダイアライザ連携コード１", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "rst_dialyzer_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialyzer_in_hospital_cd_2", "data_name": "ダイアライザ連携コード２", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "rst_dialyzer_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialyzer_in_hospital_cd_3", "data_name": "ダイアライザ連携コード３", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "rst_dialyzer_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_dialyzer_in_hospital_cd_4", "data_name": "ダイアライザ連携コード４", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "rst_dialyzer_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_1", "data_name": "治療方法連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_2", "data_name": "治療方法連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_3", "data_name": "治療方法連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd_4", "data_name": "治療方法連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd_4", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：透析条件/ベッド情報/ダイアライザ情報/実績情報 @ordNo @facilityCd 使用', '2026-01-21 19:19:49.398', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (133, 'WITH b AS (
select ord_main.* from ord_main
     where facility_cd = @facilityCd
 and rst_dialysis_state between ''1'' and ''5''
     and
       pat_id is not null
     and
       treat_date between to_char(date_trunc(''day'', ( @fromDate
 )::timestamp), ''yyyymmdd'') and to_char(date_trunc(''day'', ( @toDate
 )::timestamp) + ''1 days - 1 milliseconds'', ''yyyymmdd'')
     and
       is_del = ''0''
             and pat_id IN (@patIds)
), d AS (
    select
      DISTINCT ON (ord_no, data_type)
      b.ord_no
    , data_type
    , bio_moni_ctl_no
    , occur_date
    from b inner join mni_monitor on (b.ord_no = mni_monitor.ord_no)
        where mni_monitor.facility_cd = @facilityCd
    order by ord_no, data_type, occur_date desc
), e AS (
    select mni_monitor.*,
    to_number(mni_monitor.monitor_data::json->>''1'', ''9999'') AS 経過時間
    , to_number(mni_monitor.monitor_data::json->>''3'', ''9999'') AS 残り時間_除水完了
    , to_number(mni_monitor.monitor_data::json->>''4'', ''9999'') AS 残り時間_透析完了
    , to_number(mni_monitor.monitor_data::json->>''78'', ''9999'') AS 残り時間_補液完了
    from d
    inner join mni_monitor on (d.bio_moni_ctl_no = mni_monitor.bio_moni_ctl_no)
    where d.data_type = 1
), h as (select machine_no,b.ord_no,mst_bed.bed_cd from mst_bed INNER JOIN b on b.rst_bed_cd = mst_bed.bed_cd 
), BpBefore AS (
    select mni_monitor.ord_no, mni_monitor.monitor_data
    from d
    inner join mni_monitor on (d.bio_moni_ctl_no = mni_monitor.bio_moni_ctl_no)
    where d.data_type = 5
), BpCurrent AS (
    select mni_monitor.ord_no, mni_monitor.monitor_data
    from d
    inner join mni_monitor on (d.bio_moni_ctl_no = mni_monitor.bio_moni_ctl_no)
    where d.data_type = 2
), BpAfter AS (
    select mni_monitor.ord_no, mni_monitor.monitor_data
    from d
    inner join mni_monitor on (d.bio_moni_ctl_no = mni_monitor.bio_moni_ctl_no)
    where d.data_type = 6
), Vital AS (
    select DISTINCT ON (mni_monitor.ord_no) 
      mni_monitor.ord_no, 
      mni_monitor.monitor_data
    from d
    inner join mni_monitor on (d.bio_moni_ctl_no = mni_monitor.bio_moni_ctl_no)
    where d.data_type in (2, 4, 5, 6)
    order by mni_monitor.ord_no,mni_monitor.occur_date desc
),j as(
    select pat_event.pat_id, count(*) as observation_records_num 
        from  pat_event INNER JOIN b on (pat_event.pat_id = b.pat_id) AND (pat_event.ord_no = b.ord_no)
        WHERE pat_event.ord_no > 0 AND pat_event.facility_cd <> ''null'' AND pat_event.use_type = 2 AND  pat_event.event_status = ''1'' AND pat_event.is_newest = ''1'' AND pat_event.is_del = ''0''
        GROUP BY pat_event.pat_id
)
,k as (select h.ord_no, machine_status as machine_status , machine_serial from mnt_machine_state INNER JOIN h on mnt_machine_state.bed_cd = h.bed_cd)
,q as (
   select
     e.ord_no,
     to_number(mnt_machine_state.monitor_data::json->>''1'', ''9999'') AS 経過時間,
     to_number(mnt_machine_state.monitor_data::json->>''3'', ''9999'') AS 残り時間_除水完了,
     to_number(mnt_machine_state.monitor_data::json->>''4'', ''9999'') AS 残り時間_透析完了,
     to_number(mnt_machine_state.monitor_data::json->>''78'', ''9999'') AS 残り時間_補液完了
     from e
     inner join mnt_machine_state on
     e.facility_cd = mnt_machine_state.facility_cd and
     e.machine_type_cd = mnt_machine_state.machine_type_cd and
     e.machine_serial = mnt_machine_state.machine_serial and
     e.ord_no = mnt_machine_state.ord_no and
     e.pat_id = mnt_machine_state.pat_id
), f AS (
    select q.*
        , COALESCE(q.経過時間,0) + COALESCE(q.残り時間_除水完了,0) AS 予測時間_除水
        , COALESCE(q.経過時間,0) + COALESCE(q.残り時間_透析完了,0) AS 予測時間_透析
        , COALESCE(q.経過時間,0) + COALESCE(q.残り時間_補液完了,0) AS 予測時間_補液 
    from q
)
,p as (select com_format_cd,com_type,h.ord_no from mst_machine INNER JOIN h on h.machine_no = mst_machine.machine_no)
,l as (select pat_ind_approve.ord_no, pat_ind_approve.is_content_changed_for_map as is_content_changed_for_map from pat_ind_approve INNER JOIN b on pat_ind_approve.ord_no = b.ord_no)
,m as (select a2.ord_no,concat(effect,''/'',effect_count) as dosing_status
from
(
select b.ord_no,
count(1) as effect
from b,jsonb_array_elements(b.rst_medi_info) as a1
where a1->''effect_flg''=''"1"''
GROUP BY b.ord_no
) as b2,
(
select b.ord_no,
count(1) as effect_count
from b,jsonb_array_elements(b.rst_medi_info) as a1
  GROUP BY b.ord_no
) as a2 where a2.ord_no=b2.ord_no
)
,n as  (
 select b.ord_no,
case when (rst_weight_info->''recrcl_rt'') -> ''valid_no'' = ''1'' then
((rst_weight_info->''recrcl_rt'') -> ''1'') ->> ''rate''
 when (rst_weight_info->''recrcl_rt'') -> ''valid_no'' = ''2'' then
((rst_weight_info->''recrcl_rt'') -> ''2'') ->> ''rate''
 when (rst_weight_info->''recrcl_rt'') -> ''valid_no'' = ''3'' then
((rst_weight_info->''recrcl_rt'') -> ''2'') ->> ''rate''
 when (rst_weight_info->''recrcl_rt'') -> ''valid_no'' = ''4'' then
((rst_weight_info->''recrcl_rt'') -> ''2'') ->> ''rate''
 when (rst_weight_info->''recrcl_rt'') -> ''valid_no'' = ''5'' then
((rst_weight_info->''recrcl_rt'') -> ''2'') ->> ''rate''
else ''0'' end  as rate
 from b
 )
 ,o as (
 select b.ord_no,
max(info ->> ''treat_cd'')|| ''　'' || max(info ->> ''treat_name'')  AS treatment
 from b
   CROSS JOIN LATERAL json_array_elements(b.rst_treatment_info ::json) info
 GROUP BY b.ord_no
 )
 ,bed_group as (
 SELECT
        index_no AS bed_group_order,
        TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS bed_group_code,
        order_cd ->> ''name'' AS bed_group_name
    FROM
        mst_selector
        CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
    WHERE
        facility_cd = @facilityCd

        AND master_physical_name = ''mst_room_bed_group''
 )
  ,bed as (
 SELECT
        index_no AS bed_order,
        TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS bed_code,
        order_cd ->> ''name'' AS bed_name
    FROM
        mst_selector
        CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
    WHERE
        facility_cd = @facilityCd

        AND master_physical_name = ''mst_bed''
 )
,kur as (
 SELECT
        index_no AS kur_order,
        TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS kur_code,
        order_cd ->> ''name'' AS kur_name
    FROM
        mst_selector
        CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
    WHERE
        facility_cd = @facilityCd

        AND master_physical_name = ''mst_kur''
 )
 ,patgrou as (
 SELECT
        index_no AS pat_group_order,
        TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS pat_group_code,
        order_cd ->> ''name'' AS pat_group_name
    FROM
        mst_selector
        CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
    WHERE
        facility_cd = @facilityCd

        AND master_physical_name = ''pat_group''
 )
 ,mst_room_bed_group_1 AS ( SELECT * FROM mst_room_bed_group WHERE is_del = ''0'' AND is_disp = ''1'' AND group_class = 1 )
select 
  DISTINCT ON (b.ord_no)
  b.ord_no
, b.pat_id AS pat_id_tmp
, b.treat_date
, b.pat_id AS pat_id
, b.pat_id AS pat_id1
, b.pat_id AS pat_id2
, b.pat_id AS pat_id3
, b.pat_id AS pat_id4
, b.pat_id AS pat_id5
, MIN(patgrou.pat_group_order) AS pat_group_order
, pt.is_infect
, b.pat_id AS pat_name
, b.ind_kur_name
, b.ind_bed_cd
, b.rst_dw as DW
, CASE mnt_machine_state.process_state WHEN ''01'' THEN ''プリセット''
                                       WHEN ''02'' THEN ''洗浄''
                                       WHEN ''03'' THEN ''酸洗''
                                       WHEN ''04'' THEN ''消毒''
                                       WHEN ''05'' THEN ''滞留''
                                       WHEN ''06'' THEN ''液置換''
                                       WHEN ''07'' THEN ''準備回収''
                                       WHEN ''08'' THEN ''ガスパージ''
                                       WHEN ''09'' THEN ''排液''
                                       WHEN ''10'' THEN ''停止''
                                       WHEN ''11'' THEN ''運転''
                                       WHEN ''99'' THEN ''通信異常、電源OFF、異常''
                                       ELSE mnt_machine_state.process_state
  END
, b.rst_cond_info::json#>>''{3, value}'' AS target_weight
, CASE WHEN b.rst_cond_info::json#>>''{3, value}'' is not null AND b.rst_cond_info::json#>>''{3, value}'' <> ''null'' THEN CAST(b.rst_weight_info::json->>''weight_before'' AS DECIMAL) - CAST(b.rst_cond_info::json#>>''{3, value}'' AS DECIMAL) 
  ELSE CAST(b.rst_weight_info::json->>''weight_before'' AS DECIMAL) - b.rst_dw 
  END AS target_weight_2
, b.rst_start_date
, CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN b.rst_dialysis_state > ''3'' THEN b.rst_end_date
       WHEN f.残り時間_除水完了 > f.残り時間_透析完了 AND f.残り時間_除水完了 > f.残り時間_補液完了 THEN b.rst_start_date + f.予測時間_除水 * interval ''1 minute''
             WHEN f.残り時間_透析完了 > f.残り時間_補液完了 THEN b.rst_start_date + f.予測時間_透析 * interval ''1 minute''
       ELSE b.rst_start_date + f.予測時間_補液 * interval ''1 minute''
  END AS forecast_end
, CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN b.rst_dialysis_state > ''3'' THEN b.rst_end_date
       ELSE b.rst_start_date + f.予測時間_除水 * interval ''1 minute''
  END AS forecast_end_water_removal_end
, CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN b.rst_dialysis_state > ''3'' THEN b.rst_end_date
       ELSE b.rst_start_date + f.予測時間_透析 * interval ''1 minute''
  END AS forecast_end_dialysis_end
, b.rst_end_date
, b.rst_cond_info#>>''{1, value}'' AS treatment_minute
, b.rst_cond_info#>>''{1, value}'' AS treatment_time
, CASE WHEN b.rst_dialysis_state <> ''3'' THEN 0
       WHEN f.残り時間_除水完了 > f.残り時間_透析完了 AND f.残り時間_除水完了 > f.残り時間_補液完了 THEN f.予測時間_除水 - to_number(b.rst_cond_info#>>''{1, value}'', ''9999'')
             WHEN f.残り時間_透析完了 > f.残り時間_補液完了 THEN f.予測時間_透析 - to_number(b.rst_cond_info#>>''{1, value}'', ''9999'')
       ELSE COALESCE(f.予測時間_補液,0) - to_number(b.rst_cond_info#>>''{1, value}'', ''9999'')
  END AS delay_time
, CASE WHEN b.rst_dialysis_state < ''4'' THEN 
          GREATEST(CASE WHEN COALESCE(f.残り時間_除水完了,0) > COALESCE(f.残り時間_透析完了,0) AND COALESCE(f.残り時間_除水完了,0) > COALESCE(f.残り時間_補液完了,0) THEN f.残り時間_除水完了
                        WHEN COALESCE(f.残り時間_透析完了,0) > COALESCE(f.残り時間_補液完了,0) THEN f.残り時間_透析完了
                        ELSE f.残り時間_補液完了
                        END,0)
     ELSE GREATEST(CASE WHEN COALESCE(e.残り時間_除水完了,0) > COALESCE(e.残り時間_透析完了,0) AND COALESCE(e.残り時間_除水完了,0) > COALESCE(e.残り時間_補液完了,0) THEN e.残り時間_除水完了
                        WHEN COALESCE(e.残り時間_透析完了,0) > COALESCE(e.残り時間_補液完了,0) THEN e.残り時間_透析完了
                        ELSE e.残り時間_補液完了
                        END,0)
     END as remaining_time
 ,CASE WHEN b.rst_dialysis_state < ''3'' THEN 0
       WHEN b.rst_cond_info::json#>>''{1, value}'' is null or b.rst_cond_info::json#>>''{1, value}'' = ''0'' THEN null
       WHEN (p.com_format_cd = ''F'' AND p.com_type = 0) AND to_char(b.rst_end_date, ''YYYY-MM-DD'') is null THEN FLOOR(cast((round(extract(epoch from now() - b.rst_start_date) / 60)*100 / CAST(b.rst_cond_info::json#>>''{1, value}'' AS DECIMAL)) as numeric))
             WHEN (p.com_format_cd = ''F'' AND p.com_type = 0) AND to_char(b.rst_end_date, ''YYYY-MM-DD'') is not null THEN FLOOR(cast((round(extract(epoch from CAST(b.rst_end_date AS TIMESTAMP) - b.rst_start_date) / 60)*100 / CAST(b.rst_cond_info::json#>>''{1, value}'' AS DECIMAL)) as numeric))
             WHEN d.data_type = 1 THEN FLOOR(((CAST(b.rst_cond_info::json#>>''{1, value}'' AS DECIMAL) - cast(q.残り時間_透析完了 as DECIMAL)) / CAST(b.rst_cond_info::json#>>''{1, value}'' AS DECIMAL))*100)
             WHEN d.data_type <> 1 THEN FLOOR(((CAST(b.rst_cond_info::json#>>''{1, value}'' AS DECIMAL) - cast(e.残り時間_透析完了 as DECIMAL)) / CAST(b.rst_cond_info::json#>>''{1, value}'' AS DECIMAL))*100)  
             END AS progress_rate 
, b.rst_weight_info::json->>''weight_before'' AS weight_before
, BpBefore.monitor_data->>''90'' AS bpbefore_max
, BpBefore.monitor_data->>''91'' AS bpbefore_min
, BpBefore.monitor_data->>''92'' AS bpbefore_avg
, (BpBefore.monitor_data->>''90'') || ''/ '' || (BpBefore.monitor_data->>''91'') || ''/ '' || (BpBefore.monitor_data->>''92'') || '' ('' || (BpBefore.monitor_data->>''93'') || '')'' AS bpbefore
, BpBefore.monitor_data->>''93'' AS pulse_before
, (BpCurrent.monitor_data->>''90'') || ''/ '' || (BpCurrent.monitor_data->>''91'') || ''/ '' || (BpCurrent.monitor_data->>''92'') || '' ('' || (BpCurrent.monitor_data->>''93'') || '')'' AS bpcurrent
, b.rst_charge_user_info->>''user_id_1'' AS charge_user_id_1
, b.rst_charge_user_info->>''date_1'' AS charge_date_1
, b.rst_charge_user_info->>''user_id_2'' AS charge_user_id_2
, b.rst_charge_user_info->>''date_2'' AS charge_date_2
, b.rst_puncture_user_info->>''date'' AS puncture_date
, b.rst_puncture_user_info->>''user_id_1'' AS puncture_user_id_1
, b.rst_puncture_user_info->>''date_1'' AS puncture_date_1
, b.rst_puncture_user_info->>''user_id_2'' AS puncture_user_id_2
, b.rst_puncture_user_info->>''date_2'' AS puncture_date_2
, b.rst_return_user_info->>''date'' AS return_date
, b.rst_return_user_info->>''user_id_1'' AS return_user_id_1
, b.rst_return_user_info->>''date_1'' AS return_date_1
, b.rst_return_user_info->>''user_id_2'' AS return_user_id_2
, b.rst_return_user_info->>''date_2'' AS return_date_2
, b.rst_weight_info->>''weight_after'' AS weight_after
, to_number(b.rst_weight_info::json->>''weight_before'', ''999.99'') - to_number(b.rst_weight_info::json->>''weight_after'', ''999.99'') AS weight_diff
, BpAfter.monitor_data->>''90'' AS bpafter_max
, BpAfter.monitor_data->>''91'' AS bpafter_min
, BpAfter.monitor_data->>''92'' AS bpafter_avg
, (BpAfter.monitor_data->>''90'') || ''/ '' || (BpAfter.monitor_data->>''91'') || ''/ '' || (BpAfter.monitor_data->>''92'') || '' ('' || (BpAfter.monitor_data->>''93'') || '')'' AS bpafter
, BpAfter.monitor_data->>''93'' AS pulse_after
, Vital.monitor_data->>''-2'' AS SpO2
, Vital.monitor_data->>''-1'' AS blood_glucose_level
, Vital.monitor_data->>''90'' AS bp_high
, Vital.monitor_data->>''91'' AS bp_low
, Vital.monitor_data->>''92'' AS bp_ave
, Vital.monitor_data->>''93'' AS pulse
, Vital.monitor_data->>''94'' AS body_temperature
, b.rst_weight_info->>''water_removal_target'' AS water_removal_target
, CASE WHEN b.rst_dialysis_state < ''2'' THEN null
       ELSE ''済''
  END AS pat_confirm
, b.rst_weight_info->>''weight_before_date'' AS weight_before_date
, b.rst_start_date + to_number(b.rst_cond_info#>>''{1, value}'', ''9999'') * interval ''1 minute'' AS plan_end
, CASE WHEN b.rst_rounds_info->''round_type_name'' IS NULL THEN ''未''
       ELSE ''済''
  END AS rounds_status
, CASE WHEN b.rst_rounds_info->''round_type_name'' IS NULL THEN ''未回診''
       ELSE b.rst_rounds_info->>''round_type_name''
  END AS rounds_data
, b.rst_weight_info->>''ctr'' AS ctr
, b.rst_cond_info#>>''{2, value_name_1}'' AS va
, b.rst_cond_info#>>''{4, value}'' AS water_removal_limit
, (b.rst_cond_info#>>''{5, value_name_2}'') || ''['' || (b.rst_cond_info#>>''{5, value_name_1}'') || '']'' AS dialyzer
, b.rst_cond_info#>>''{6, value_name_1}'' AS adsorption_column
, b.rst_cond_info#>>''{7, value_name_1}'' AS primary_membrane
, b.rst_cond_info#>>''{8, value_name_1}'' AS Second_membrane
, b.rst_cond_info#>>''{9, value_name_1}'' AS needles_a
, b.rst_cond_info#>>''{10, value_name_1}'' AS needles_v
, b.rst_cond_info#>>''{11, value_name_1}'' AS needles_sn
, CASE WHEN b.rst_cond_info#>>''{12, value}'' IS NULL THEN NULL
       WHEN b.rst_cond_info#>>''{12, value}'' = ''0'' THEN ''使用しない''
       ELSE ''使用する''
  END AS single_needle_use
, b.rst_cond_info#>>''{13, value_name_1}'' AS blood_circuit
, b.rst_cond_info#>>''{14, value}'' AS blood_flow
, b.rst_cond_info#>>''{15, value_name_1}'' AS dialysate
, b.rst_cond_info#>>''{16, value}'' AS dialysate_flow
, b.rst_cond_info#>>''{17, value}'' AS dialysate_volume
, to_char(CAST(b.rst_cond_info#>>''{18, value}'' AS DECIMAL), ''FM999.0'') AS dialysate_temperature
, b.rst_cond_info#>>''{19, value_name_1}'' AS fluid_replenishment
, b.rst_cond_info#>>''{20, value}'' AS fr_volume
, CASE b.rst_cond_info#>>''{21, value}'' WHEN ''0'' THEN ''後補液''
                                       WHEN ''1'' THEN ''前補液''
                                       ELSE NULL
  END AS fr_selection
, b.rst_cond_info#>>''{22, value}'' AS fr_use_num
, to_char(CAST(b.rst_cond_info#>>''{23, value}'' AS DECIMAL), ''FM990.0'') AS fr_temperature
, b.rst_cond_info#>>''{24, value}'' AS fr_velocity
, b.rst_cond_info#>>''{25, value_name_1}'' AS anticoagulants
, b.rst_cond_info#>>''{26, value}'' AS anticoagulants_oneshot_quantity
, b.rst_cond_info#>>''{27, value}'' AS anticoagulants_duration_rate
, b.rst_cond_info#>>''{28, value}'' AS anticoagulants_total_volume
-- , CASE WHEN b.rst_cond_info#>>''{29, value}'' IS NULL THEN NULL
--        WHEN b.rst_cond_info#>>''{29, value}'' = ''0'' THEN ''使用しない''
--        ELSE ''使用する''
--   END AS ip_usage_selection
, b.rst_cond_info#>>''{29, value}'' AS ip_usage_selection
-- , null AS ip_start
-- , CASE b.rst_cond_info#>>''{30, value}'' WHEN ''0'' THEN ''手動''
--                                        WHEN ''1'' THEN ''自動''
--                                        ELSE NULL
--   END AS ip_start
, b.rst_cond_info#>>''{30, value}'' AS ip_start
-- , to_char(to_number(b.rst_cond_info#>>''{31, value}'', ''999.99''), ''FM990.0'') AS ip_oneshot_quantity
-- , to_char(to_number(b.rst_cond_info#>>''{32, value}'', ''999.99''), ''FM990.0'') AS ip_velocity
-- , to_char(to_number(b.rst_cond_info#>>''{33, value}'', ''999.99''), ''FM990.0'') AS ip_velocity_max
, CAST(b.rst_cond_info#>>''{31, value}'' AS DECIMAL) AS ip_oneshot_quantity
, CAST(b.rst_cond_info#>>''{32, value}'' AS DECIMAL) AS ip_velocity
, CAST(b.rst_cond_info#>>''{33, value}'' AS DECIMAL) AS ip_velocity_max
-- , CASE WHEN b.rst_cond_info#>>''{34, value}'' IS NULL THEN NULL
--        WHEN b.rst_cond_info#>>''{34, value}'' = ''0'' THEN ''使用しない''
--        ELSE ''使用する''
--   END AS auto_oneshot
, b.rst_cond_info#>>''{34, value}'' AS auto_oneshot
-- , CASE b.rst_cond_info#>>''{35, value}'' WHEN ''0'' THEN ''切''
--                                        WHEN ''1'' THEN ''入''
--                                        ELSE NULL
--   END AS ip_auto_off
, b.rst_cond_info#>>''{35, value}'' AS ip_auto_off
, b.rst_cond_info#>>''{36, value}'' AS ip_auto_cycle_time
-- , CASE b.rst_cond_info#>>''{37, value}'' WHEN ''0'' THEN ''切''
--                                        WHEN ''1'' THEN ''入''
--                                        ELSE NULL
--   END AS ip_power_ok_monitor_off
, b.rst_cond_info#>>''{37, value}'' AS ip_power_ok_monitor_off
, b.rst_cond_info#>>''{38, value}'' AS ip_power_ok_monitor_off_time
, e.monitor_data->>''0'' AS m000
, e.monitor_data->>''1'' AS m001
, e.monitor_data->>''2'' AS m002
, CASE 
    WHEN b.rst_dialysis_state < ''4'' and mnt_machine_state.monitor_data->>''3'' is not null THEN mnt_machine_state.monitor_data->>''3''
    WHEN b.rst_dialysis_state < ''4'' and mnt_machine_state.monitor_data->>''3'' is null THEN null
    WHEN b.rst_dialysis_state > ''3'' and e.monitor_data->>''3'' is not null THEN e.monitor_data->>''3''
    WHEN b.rst_dialysis_state > ''3'' and e.monitor_data->>''3'' is null THEN null
  END AS m003
, CASE 
    WHEN b.rst_dialysis_state < ''4'' and mnt_machine_state.monitor_data->>''4'' is not null THEN mnt_machine_state.monitor_data->>''4''
    WHEN b.rst_dialysis_state < ''4'' and mnt_machine_state.monitor_data->>''4'' is null THEN null
    WHEN b.rst_dialysis_state > ''3'' and e.monitor_data->>''4'' is not null THEN e.monitor_data->>''4''
    WHEN b.rst_dialysis_state > ''3'' and e.monitor_data->>''4'' is null THEN null
  END AS m004
, e.monitor_data->>''5'' AS m005
, e.monitor_data->>''6'' AS m006
, e.monitor_data->>''7'' AS m007
, e.monitor_data->>''8'' AS m008
, e.monitor_data->>''9'' AS m009
, e.monitor_data->>''10'' AS m010
, e.monitor_data->>''11'' AS m011
, e.monitor_data->>''12'' AS m012
, e.monitor_data->>''13'' AS m013
, e.monitor_data->>''14'' AS m014
, e.monitor_data->>''15'' AS m015
, e.monitor_data->>''16'' AS m016
, e.monitor_data->>''17'' AS m017
, e.monitor_data->>''18'' AS m018
, e.monitor_data->>''19'' AS m019
, e.monitor_data->>''20'' AS m020
, e.monitor_data->>''21'' AS m021
, e.monitor_data->>''22'' AS m022
, e.monitor_data->>''23'' AS m023
, e.monitor_data->>''24'' AS m024
, e.monitor_data->>''25'' AS m025
, e.monitor_data->>''26'' AS m026
, e.monitor_data->>''27'' AS m027
, e.monitor_data->>''28'' AS m028
, e.monitor_data->>''29'' AS m029
, e.monitor_data->>''30'' AS m030
, e.monitor_data->>''31'' AS m031
, e.monitor_data->>''32'' AS m032
, e.monitor_data->>''33'' AS m033
, e.monitor_data->>''34'' AS m034
, e.monitor_data->>''35'' AS m035
, e.monitor_data->>''36'' AS m036
, e.monitor_data->>''37'' AS m037
, e.monitor_data->>''38'' AS m038
, e.monitor_data->>''39'' AS m039
, e.monitor_data->>''40'' AS m040
, e.monitor_data->>''41'' AS m041
, e.monitor_data->>''42'' AS m042
, e.monitor_data->>''43'' AS m043
, e.monitor_data->>''44'' AS m044
, e.monitor_data->>''45'' AS m045
, e.monitor_data->>''46'' AS m046
, e.monitor_data->>''47'' AS m047
, e.monitor_data->>''48'' AS m048
, e.monitor_data->>''49'' AS m049
, e.monitor_data->>''50'' AS m050
, e.monitor_data->>''51'' AS m051
, e.monitor_data->>''52'' AS m052
, e.monitor_data->>''53'' AS m053
, e.monitor_data->>''54'' AS m054
, e.monitor_data->>''55'' AS m055
, e.monitor_data->>''56'' AS m056
, e.monitor_data->>''57'' AS m057
, e.monitor_data->>''58'' AS m058
, e.monitor_data->>''59'' AS m059
, e.monitor_data->>''60'' AS m060
, e.monitor_data->>''61'' AS m061
, e.monitor_data->>''62'' AS m062
, e.monitor_data->>''63'' AS m063
, e.monitor_data->>''64'' AS m064
, e.monitor_data->>''65'' AS m065
, e.monitor_data->>''66'' AS m066
, e.monitor_data->>''67'' AS m067
, e.monitor_data->>''68'' AS m068
, e.monitor_data->>''69'' AS m069
, e.monitor_data->>''70'' AS m070
, e.monitor_data->>''71'' AS m071
, e.monitor_data->>''72'' AS m072
, e.monitor_data->>''73'' AS m073
, e.monitor_data->>''74'' AS m074
, e.monitor_data->>''75'' AS m075
, e.monitor_data->>''76'' AS m076
, e.monitor_data->>''77'' AS m077
, CASE 
    WHEN b.rst_dialysis_state < ''4'' and mnt_machine_state.monitor_data->>''78'' is not null THEN mnt_machine_state.monitor_data->>''78''
    WHEN b.rst_dialysis_state < ''4'' and mnt_machine_state.monitor_data->>''78'' is null THEN null
    WHEN b.rst_dialysis_state > ''3'' and e.monitor_data->>''78'' is not null THEN e.monitor_data->>''78''
    WHEN b.rst_dialysis_state > ''3'' and e.monitor_data->>''78'' is null THEN null
  END AS m078
, e.monitor_data->>''79'' AS m079
, e.monitor_data->>''80'' AS m080
, e.monitor_data->>''81'' AS m081
, e.monitor_data->>''82'' AS m082
, e.monitor_data->>''83'' AS m083
, e.monitor_data->>''84'' AS m084
, e.monitor_data->>''85'' AS m085
, e.monitor_data->>''86'' AS m086
, e.monitor_data->>''87'' AS m087
, e.monitor_data->>''88'' AS m088
, e.monitor_data->>''89'' AS m089
, e.monitor_data->>''95'' AS m095
, e.monitor_data->>''96'' AS m096
, e.monitor_data->>''97'' AS m097
, e.monitor_data->>''98'' AS m098
, e.monitor_data->>''100'' AS m100
, e.monitor_data->>''101'' AS m101
, e.monitor_data->>''102'' AS m102
, e.monitor_data->>''103'' AS m103
, e.monitor_data->>''Z11'' AS mz11
, e.monitor_data->>''Z21'' AS mz21
, e.monitor_data->>''Z31'' AS mz31
, e.monitor_data->>''Z41'' AS mz41
, e.monitor_data->>''Z51'' AS mz51
, e.monitor_data->>''Z61'' AS mz61
, e.monitor_data->>''Z71'' AS mz71
, e.monitor_data->>''Z81'' AS mz81
, e.monitor_data->>''Z91'' AS mz91
, e.monitor_data->>''Z101'' AS mz101
, e.monitor_data->>''Z111'' AS mz111
, e.monitor_data->>''Z121'' AS mz121
, e.monitor_data->>''Z131'' AS mz131
, e.monitor_data->>''Z141'' AS mz141
, e.monitor_data->>''Z151'' AS mz151
, e.monitor_data->>''Z161'' AS mz161
, e.monitor_data->>''Z171'' AS mz171
, e.monitor_data->>''Z181'' AS mz181
, e.monitor_data->>''Z191'' AS mz191
, e.monitor_data->>''Z201'' AS mz201
, e.monitor_data->>''Z211'' AS mz211
, e.monitor_data->>''Z221'' AS mz221
, e.monitor_data->>''Z231'' AS mz231
, e.monitor_data->>''Z241'' AS mz241
, e.monitor_data->>''Z251'' AS mz251
, e.monitor_data->>''Z261'' AS mz261
, e.monitor_data->>''Z271'' AS mz271
, e.monitor_data->>''Z281'' AS mz281
, e.monitor_data->>''Z291'' AS mz291
, e.monitor_data->>''Z301'' AS mz301
, e.monitor_data->>''Z311'' AS mz311
, e.monitor_data->>''Z321'' AS mz321
, e.monitor_data->>''Z331'' AS mz331
, e.monitor_data->>''Z341'' AS mz341
, e.monitor_data->>''Z351'' AS mz351
, e.monitor_data->>''Z361'' AS mz361
, e.monitor_data->>''Z371'' AS mz371
, e.monitor_data->>''Z381'' AS mz381
, e.monitor_data->>''Z391'' AS mz391
, e.monitor_data->>''Z401'' AS mz401
, e.monitor_data->>''Z411'' AS mz411
, e.monitor_data->>''Z421'' AS mz421
, e.monitor_data->>''Z431'' AS mz431
, e.monitor_data->>''Z441'' AS mz441
, e.monitor_data->>''Z451'' AS mz451
, e.monitor_data->>''Z12'' AS mz12
, e.monitor_data->>''Z22'' AS mz22
, e.monitor_data->>''Z32'' AS mz32
, e.monitor_data->>''Z42'' AS mz42
, e.monitor_data->>''Z52'' AS mz52
, e.monitor_data->>''Z62'' AS mz62
, e.monitor_data->>''Z72'' AS mz72
, e.monitor_data->>''Z82'' AS mz82
, e.monitor_data->>''Z92'' AS mz92
, e.monitor_data->>''Z102'' AS mz102
, e.monitor_data->>''Z112'' AS mz112
, e.monitor_data->>''Z122'' AS mz122
, e.monitor_data->>''Z132'' AS mz132
, e.monitor_data->>''Z142'' AS mz142
, e.monitor_data->>''Z152'' AS mz152
, e.monitor_data->>''Z162'' AS mz162
, e.monitor_data->>''Z172'' AS mz172
, e.monitor_data->>''Z182'' AS mz182
, e.monitor_data->>''Z192'' AS mz192
, e.monitor_data->>''Z202'' AS mz202
, e.monitor_data->>''Z212'' AS mz212
, e.monitor_data->>''Z222'' AS mz222
, e.monitor_data->>''Z232'' AS mz232
, e.monitor_data->>''Z13'' AS mz13
, e.monitor_data->>''Z23'' AS mz23
, e.monitor_data->>''Z33'' AS mz33
, e.monitor_data->>''Z43'' AS mz43
, e.monitor_data->>''Z53'' AS mz53
, e.monitor_data->>''Z63'' AS mz63
, e.monitor_data->>''Z73'' AS mz73
, e.monitor_data->>''Z83'' AS mz83
, e.monitor_data->>''Z93'' AS mz93
, e.monitor_data->>''Z103'' AS mZ103
, e.monitor_data->>''Z113'' AS mZ113
, e.monitor_data->>''Z123'' AS mZ123
, e.monitor_data->>''Z133'' AS mZ133
, e.monitor_data->>''Z143'' AS mZ143
, e.monitor_data->>''Z153'' AS mZ153
, e.monitor_data->>''Z163'' AS mZ163
, e.monitor_data->>''Z173'' AS mZ173
, e.monitor_data->>''Z183'' AS mZ183
, e.monitor_data->>''Z193'' AS mZ193
, e.monitor_data->>''Z203'' AS mZ203
, e.monitor_data->>''Z213'' AS mZ213
, e.monitor_data->>''Z223'' AS mZ223
, e.monitor_data->>''Z233'' AS mZ233
, e.monitor_data->>''Z243'' AS mZ243
, e.monitor_data->>''Z253'' AS mZ253
, e.monitor_data->>''Z263'' AS mZ263
, e.monitor_data->>''Z14'' AS mz14
, e.monitor_data->>''Z24'' AS mz24
, e.monitor_data->>''Z34'' AS mz34
, e.monitor_data->>''Z44'' AS mz44
, e.monitor_data->>''Z54'' AS mz54
, e.monitor_data->>''Z64'' AS mz64
, e.monitor_data->>''Z74'' AS mz74
, e.monitor_data->>''Z84'' AS mz84
, e.monitor_data->>''Z94'' AS mz94
, e.monitor_data->>''Z104'' AS mz104
, e.monitor_data->>''Z114'' AS mz114
, e.monitor_data->>''Z124'' AS mz124
, e.monitor_data->>''Z134'' AS mz134
, e.monitor_data->>''Z144'' AS mz144
, e.monitor_data->>''Z154'' AS mz154
, e.monitor_data->>''Z164'' AS mz164
, e.monitor_data->>''Z174'' AS mz174
, e.monitor_data->>''Z184'' AS mz184
, e.monitor_data->>''Z194'' AS mz194
, e.monitor_data->>''Z204'' AS mz204
, e.monitor_data->>''Z214'' AS mz214
, e.monitor_data->>''Z224'' AS mz224
, e.monitor_data->>''Z234'' AS mz234
, e.monitor_data->>''Z244'' AS mz244
, e.monitor_data->>''Z254'' AS mz254
, e.monitor_data->>''Z264'' AS mz264
, e.monitor_data->>''Z274'' AS mz274
, e.monitor_data->>''Z284'' AS mz284
, e.monitor_data->>''Z294'' AS mz294
, e.monitor_data->>''Z304'' AS mz304
, e.monitor_data->>''Z314'' AS mz314
, e.monitor_data->>''Z324'' AS mz324
, e.monitor_data->>''Z334'' AS mz334
, e.monitor_data->>''Z344'' AS mz344
, e.monitor_data->>''Z354'' AS mz354
, e.monitor_data->>''Z364'' AS mz364
, e.monitor_data->>''Z374'' AS mz374
, BpBefore.monitor_data
--, b.ord_no
, CAST(b.rst_weight_info ->> ''weight_after'' AS DECIMAL) - CAST(b.rst_cond_info::json#>>''{3, value}'' AS DECIMAL)  AS leftovers
, b.pat_id AS hosp_pat_id
, b.rst_end_date as treatment_end
, CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN b.rst_dialysis_state > ''3'' THEN b.rst_end_date
       ELSE b.rst_start_date + f.予測時間_補液 * interval ''1 minute''
  END AS forecast_end_fr_end
, b.rst_weight_info #>> ''{sttc_vns_prssr}'' AS sttc_vns_prssr
, b.rst_dw AS last_weight_after
, b.rst_weight_info #>> ''{ihdf_pll}'' AS ihdf_pll
, round((CAST(b.rst_off_water_info ->> ''weight_1'' AS DECIMAL)+CAST(b.rst_off_water_info ->> ''weight_2'' AS DECIMAL)+CAST(b.rst_off_water_info ->> ''weight_3'' AS DECIMAL)
+CAST(b.rst_off_water_info ->> ''weight_4'' AS DECIMAL)+CAST(b.rst_off_water_info ->> ''weight_5'' AS DECIMAL))/1000,2) AS off_water_total
, b.rst_weight_info #>> ''{iap_rt}'' AS IAPRatio
,e.monitor_data->>''Z212'' AS device_self_diagnosis
,b.rst_bed_name AS bed_name
, round((CAST(b.rst_tare_info -> ''before'' ->> ''weight_1'' AS DECIMAL)+CAST(b.rst_tare_info -> ''before'' ->> ''weight_2'' AS DECIMAL)+CAST(b.rst_tare_info -> ''before'' ->> ''weight_3'' AS DECIMAL)+CAST(b.rst_tare_info -> ''before'' ->> ''weight_4'' AS DECIMAL)+CAST(b.rst_tare_info -> ''before'' ->> ''weight_5'' AS DECIMAL))/1000,2) AS weight_before_tare_total
,  round((CAST(b.rst_tare_info -> ''after'' ->> ''weight_1'' AS DECIMAL)+CAST(b.rst_tare_info -> ''after'' ->> ''weight_2'' AS DECIMAL)+CAST(b.rst_tare_info -> ''after'' ->> ''weight_3'' AS DECIMAL)+CAST(b.rst_tare_info -> ''after'' ->> ''weight_4'' AS DECIMAL)+CAST(b.rst_tare_info -> ''after'' ->> ''weight_5'' AS DECIMAL))/1000,2 )AS weight_after_tare_total
, cast(b.rst_complaint_info->-1 ->> ''occur_date'' as timestamp (3)) || '' '' || COALESCE((b.rst_complaint_info->-1 ->> ''complaint''), '''') AS complaint_latest
, o.treatment AS treatment_latest
, COALESCE(b.rst_cond_info -> ''17'' ->> ''value'', ''0'')  as dialysates_used_num
, (CAST(b.rst_weight_info ->> ''weight_before'' AS DECIMAL) - b.rst_dw) AS weight_before_dw
,CAST(b.rst_weight_info ->> ''weight_before'' AS DECIMAL) - CAST(b.rst_cond_info::json#>>''{3, value}'' AS DECIMAL) AS weight_before_weight_target
,(CAST(b.rst_weight_info ->> ''weight_before'' AS DECIMAL) - CAST(b.rst_weight_info ->> ''weight_after'' AS DECIMAL)) AS weight_before_weight_after
,CASE WHEN b.rst_dw is NULL OR b.rst_dw = 0 THEN 0 ELSE(CAST(b.rst_weight_info  ->> ''weight_before'' AS DECIMAL) - b.rst_dw)/ b.rst_dw*100 END AS per_increase
,(CAST(b.rst_weight_info  ->> ''weight_before'' AS DECIMAL) - b.rst_dw) as amount_increase
,CASE WHEN CAST(b.rst_weight_info  ->> ''water_removal_target'' AS DECIMAL) > 0 THEN round( CAST(b.rst_weight_info  ->> ''water_removal_rst'' AS DECIMAL)/CAST(b.rst_weight_info  ->> ''water_removal_target'' AS DECIMAL),2)  ELSE 0 END as achievement_rate
,round( (CAST(b.rst_weight_info ->> ''weight_before'' AS DECIMAL)*1000 - CAST(b.rst_weight_info  ->> ''water_removal_target'' AS DECIMAL)*1000 -
 CAST(b.rst_cond_info::json#>>''{3, value}'' AS DECIMAL)*1000 + (CAST(b.rst_off_water_info ->> ''weight_1'' AS DECIMAL)+CAST(b.rst_off_water_info ->> ''weight_2'' AS DECIMAL)+CAST(b.rst_off_water_info ->> ''weight_3'' AS DECIMAL)
+CAST(b.rst_off_water_info ->> ''weight_4'' AS DECIMAL)+CAST(b.rst_off_water_info ->> ''weight_5'' AS DECIMAL)) )/1000,2) as leftovers_expected 
,COALESCE(j.observation_records_num,0) as observation_records_num
,k.machine_status
,l.is_content_changed_for_map
,m.dosing_status
,n.rate as recirculation_rate_eff 
,bed.bed_order
,kur.kur_order
,MIN(rb1.bed_group_order) as bed_group_order
,b.rst_start_date as start_time
,b.rst_end_date as end_time
-- 終了予定
, b.rst_start_date + to_number(b.rst_cond_info#>>''{1, value}'', ''9999'') * interval ''1 minute'' AS  ind_end_date
-- 終了予測
, CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN b.rst_dialysis_state > ''3'' THEN b.rst_end_date
       WHEN f.残り時間_除水完了 > f.残り時間_透析完了 AND f.残り時間_除水完了 > f.残り時間_補液完了 THEN b.rst_start_date + f.予測時間_除水 * interval ''1 minute''
             WHEN f.残り時間_透析完了 > f.残り時間_補液完了 THEN b.rst_start_date + f.予測時間_透析 * interval ''1 minute''
       ELSE b.rst_start_date + f.予測時間_補液 * interval ''1 minute''
END AS ind_end_date_time
from b
LEFT outer JOIN j on (b.pat_id = j.pat_id)
LEFT JOIN d on (b.ord_no = d.ord_no)
LEFT JOIN e on (b.ord_no = e.ord_no)
LEFT JOIN k on (b.ord_no = k.ord_no)
LEFT JOIN q on (b.ord_no = q.ord_no)
LEFT JOIN p on (b.ord_no = p.ord_no)
LEFT JOIN l ON (b.ord_no = l.ord_no)
LEFT JOIN m ON (b.ord_no = m.ord_no)
LEFT JOIN n ON (b.ord_no = n.ord_no)
LEFT JOIN o on (b.ord_no = o.ord_no)
left outer join f on (b.ord_no = f.ord_no)
left outer join mnt_machine_state on (b.facility_cd = mnt_machine_state.facility_cd and b.ind_bed_cd = mnt_machine_state.bed_cd)
left outer join pat_unique on (b.pat_id = pat_unique.pat_id)
left outer join BpBefore on (b.ord_no = BpBefore.ord_no)
left outer join BpCurrent on (b.ord_no = BpCurrent.ord_no)
left outer join BpAfter on (b.ord_no = BpAfter.ord_no)
left outer join Vital on (b.ord_no = Vital.ord_no)
    -- ベッドグループ
            LEFT OUTER JOIN mst_room_bed_group_1 AS rbg1 ON rbg1.bed_list :: jsonb @> ('''' || b.rst_bed_cd) :: jsonb
            LEFT OUTER JOIN bed_group AS rb1 ON rbg1.room_bed_group_cd = rb1.bed_group_code
            LEFT OUTER JOIN bed ON bed.bed_code = b.rst_bed_cd
            LEFT OUTER JOIN kur ON kur.kur_code = b.rst_kur_cd
            LEFT OUTER JOIN pat_main as pt ON b.pat_id = pt.pat_id
            LEFT OUTER JOIN pat_group_detail as pgd ON b.pat_id = pgd.pat_id
            LEFT OUTER JOIN patgrou ON pgd.pat_group_cd = patgrou.pat_group_code
group by 
b.ord_no
, b.treat_date
, b.pat_id
, b.ind_kur_name
, b.ind_bed_cd
, b.rst_dw
, mnt_machine_state.process_state
, b.rst_cond_info
, b.rst_weight_info
, b.rst_dialysis_state
, f.残り時間_除水完了
, f.残り時間_透析完了
, f.残り時間_補液完了
, f.予測時間_除水
, f.予測時間_透析
, f.予測時間_補液
, e.残り時間_除水完了
, e.残り時間_透析完了
, e.残り時間_補液完了
, mnt_machine_state.monitor_data
, p.com_format_cd
, p.com_type
, d.data_type
, q.残り時間_透析完了
, e.残り時間_透析完了
, bpbefore.monitor_data
, bpcurrent.monitor_data
, Vital.monitor_data
, b.rst_charge_user_info
, b.rst_puncture_user_info
, b.rst_return_user_info
, bpafter.monitor_data
, b.rst_rounds_info
, e.monitor_data
, bpbefore.ord_no
, b.rst_off_water_info
, b.rst_tare_info
, b.rst_bed_name
, b.rst_complaint_info
, o.treatment
, j.observation_records_num
, k.machine_status
, l.is_content_changed_for_map
, m.dosing_status
, n.rate
, bed.bed_order
, kur.kur_order
, e.経過時間
, e.bio_moni_ctl_no
, b.rst_start_date
, b.rst_end_date    
, pt.is_infect      
order by b.ord_no, d.data_type desc, b.treat_date,  e.bio_moni_ctl_no', 2, '[{"preview": "テスト患者", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "in_out_class", "target_var": "@patId"}, "data_code": "in_out_class", "data_name": "入外区分", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "pat_id1", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト患者", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_sex", "target_var": "@patId"}, "data_code": "pat_sex", "data_name": "性別", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "pat_id2", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト患者", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_blood_type_abo", "target_var": "@patId"}, "data_code": "pat_blood_type_abo", "data_name": "血液型(ABO)", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "pat_id3", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト患者", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_blood_type_rh", "target_var": "@patId"}, "data_code": "pat_blood_type_rh", "data_name": "血液型(Rh)", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "pat_id4", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト患者", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_name_kana", "target_var": "@patId"}, "data_code": "pat_name_kana", "data_name": "フリガナ", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "pat_id5", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/06/15", "can_calc": "0", "data_code": "treat_date", "data_name": "治療日", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "treat_date", "disp_format": "yyyy/MM/dd HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト患者", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_name", "target_var": "@patId"}, "data_code": "pat_name", "data_name": "患者名", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "pat_id", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "午後", "can_calc": "0", "data_code": "ind_kur_name", "data_name": "クール", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "ind_kur_name", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "運転", "can_calc": "0", "data_code": "process_state", "data_name": "状態", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "process_state", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "0", "data_code": "target_weight", "data_name": "目標体重", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "目標体重", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "0", "data_code": "target_weight_2", "data_name": "目標体重から", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "目標体重から", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/06/15 11:24:00", "can_calc": "0", "data_code": "rst_start_date", "data_name": "治療開始", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "rst_start_date", "disp_format": "yyyy/MM/dd HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/06/15 11:24:00", "can_calc": "0", "data_code": "ind_end_date_time", "data_name": "終了予測", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "終了予測", "disp_format": "yyyy/MM/dd HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/06/15 11:24:00", "can_calc": "0", "data_code": "forecast_end_water_removal_end", "data_name": "終了予測(除水完了)", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "終了予測_除水完了", "disp_format": "yyyy/MM/dd HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/06/15 11:24:00", "can_calc": "0", "data_code": "forecast_end_dialysis_end", "data_name": "終了予測(透析完了)", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "終了予測_透析完了", "disp_format": "yyyy/MM/dd HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/06/15 11:24:00", "can_calc": "0", "data_code": "rst_end_date", "data_name": "透析終了日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "rst_end_date", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:10", "can_calc": "0", "data_code": "treatment_time", "data_name": "治療時間", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "治療時間", "disp_format": "HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "240", "can_calc": "0", "data_code": "treatment_minute", "data_name": "治療時間(分)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "治療時間分", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "0", "data_code": "delay_time", "data_name": "遅れ時間", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "遅れ時間", "disp_format": "H:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1:00", "can_calc": "0", "data_code": "remaining_time", "data_name": "残り時間", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "remaining_time", "disp_format": "HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "progress_rate", "data_name": "進捗率", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "進捗率", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60.5", "can_calc": "0", "data_code": "weight_before", "data_name": "前体重", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前体重", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60.5", "can_calc": "0", "data_code": "bpbefore_max", "data_name": "前血圧(最高)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前血圧_最高", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60.5", "can_calc": "0", "data_code": "bpbefore_min", "data_name": "前血圧(最低)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前血圧_最低", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60.5", "can_calc": "0", "data_code": "bpbefore_avg", "data_name": "前血圧(平均)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前血圧_平均", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "115/ 71/ 85 (80)", "can_calc": "0", "data_code": "bpbefore", "data_name": "前血圧", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "前血圧", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "85", "can_calc": "0", "data_code": "pulse_before", "data_name": "前脈拍", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前脈拍", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "115/ 71/ 85 (80)", "can_calc": "0", "data_code": "bpcurrent", "data_name": "現在血圧", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "現在血圧", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "charge_user_id_1", "data_name": "担当者1", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "charge_user_id_1", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "charge_date_1", "data_name": "担当1日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "charge_date_1", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "charge_user_id_2", "data_name": "担当者2", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "charge_user_id_2", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "charge_date_2", "data_name": "担当2日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "charge_date_2", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "puncture_date", "data_name": "穿刺日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "puncture_date", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "puncture_user_id_1", "data_name": "穿刺者1", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "puncture_user_id_1", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "puncture_date_1", "data_name": "穿刺1日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "puncture_date_1", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "puncture_user_id_2", "data_name": "穿刺者2", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "puncture_user_id_2", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "puncture_date_2", "data_name": "穿刺2日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "puncture_date_2", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "return_date", "data_name": "返血日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "return_date", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "return_user_id_1", "data_name": "返血者1", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "return_user_id_1", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "return_date_1", "data_name": "返血1日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "return_date_1", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "return_user_id_2", "data_name": "返血者2", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "return_user_id_2", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "return_date_2", "data_name": "返血2日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "return_date_2", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "85", "can_calc": "0", "data_code": "weight_after", "data_name": "後体重", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "weight_after", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60.5", "can_calc": "0", "data_code": "bpafter_max", "data_name": "後血圧(最高)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "後血圧_最高", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60.5", "can_calc": "0", "data_code": "bpafter_min", "data_name": "後血圧(最低)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "後血圧_最低", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60.5", "can_calc": "0", "data_code": "bpafter_avg", "data_name": "後血圧(平均)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "後血圧_平均", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "115/ 71/ 85 (80)", "can_calc": "0", "data_code": "bpafter", "data_name": "後血圧", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "後血圧", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "85", "can_calc": "0", "data_code": "pulse_after", "data_name": "後脈拍", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "後脈拍", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.5", "can_calc": "0", "data_code": "water_removal_target", "data_name": "除水目標", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "water_removal_target", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "済", "can_calc": "0", "data_code": "pat_confirm", "data_name": "患者確認", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "患者確認", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2019-03-25T09:20:30.000+09:00", "can_calc": "0", "data_code": "weight_before_date", "data_name": "前体重測定時刻", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "weight_before_date", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2019-12-10 01:56:01", "can_calc": "0", "data_code": "ind_end_date", "data_name": "終了予定", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "終了予定", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "済", "can_calc": "0", "data_code": "rounds_status", "data_name": "回診状態", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "回診状態", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "未回診", "can_calc": "0", "data_code": "rounds_data", "data_name": "回診データ", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "回診データ", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.2", "can_calc": "0", "data_code": "ctr", "data_name": "CTR", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "ctr", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "右", "can_calc": "0", "data_code": "va", "data_name": "VA", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "va", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.5", "can_calc": "0", "data_code": "water_removal_limit", "data_name": "除水量制限", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "除水量制限", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装[FDY-21GW]", "can_calc": "0", "data_code": "dialyzer", "data_name": "ダイアライザ", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "ダイアライザ", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト吸着カラム１", "can_calc": "0", "data_code": "adsorption_column", "data_name": "吸着カラム", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "吸着カラム", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト１次膜", "can_calc": "0", "data_code": "primary_membrane", "data_name": "1次膜", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "一次膜", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト２次膜", "can_calc": "0", "data_code": "Second_membrane", "data_name": "2次膜", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "二次膜", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト穿刺針１", "can_calc": "0", "data_code": "needles_a", "data_name": "穿刺針(A針)", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "穿刺針_a針", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト穿刺針２", "can_calc": "0", "data_code": "needles_v", "data_name": "穿刺針(V針)", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "穿刺針_v針", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針3", "can_calc": "0", "data_code": "needles_sn", "data_name": "穿刺針(SN)", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "穿刺針_sn", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "single_needle_use", "data_name": "シングルニードル使用", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "シングルニードル使用", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト血液回路１", "can_calc": "0", "data_code": "blood_circuit", "data_name": "血液回路", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "血液回路", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "210", "can_calc": "0", "data_code": "blood_flow", "data_name": "血流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "血流量", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト透析液１", "can_calc": "0", "data_code": "dialysate", "data_name": "透析液", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "透析液", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "dialysate_flow", "data_name": "透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "透析液流量", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "349", "can_calc": "0", "data_code": "dialysate_volume", "data_name": "透析液量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "透析液量", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "35.0", "can_calc": "0", "data_code": "dialysate_temperature", "data_name": "透析液温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "透析液温度", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト補液１", "can_calc": "0", "data_code": "fluid_replenishment", "data_name": "補液", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "補液", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "fr_volume", "data_name": "補液量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "補液量", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "前補液", "can_calc": "0", "data_code": "fr_selection", "data_name": "補液選択", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "補液選択", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "fr_use_num", "data_name": "補液使用数", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "補液使用数", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "37.9", "can_calc": "0", "data_code": "fr_temperature", "data_name": "補液温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "補液温度", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.5", "can_calc": "0", "data_code": "fr_velocity", "data_name": "補液速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "補液速度", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト抗凝固剤１", "can_calc": "0", "data_code": "anticoagulants", "data_name": "抗凝固剤", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "抗凝固剤", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3", "can_calc": "0", "data_code": "anticoagulants_oneshot_quantity", "data_name": "抗凝固剤ワンショット量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "抗凝固剤ワンショット量", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3", "can_calc": "0", "data_code": "anticoagulants_duration_rate", "data_name": "抗凝固剤持続速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "抗凝固剤持続速度", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "ip_usage_selection", "data_name": "IP使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "治療状況", "field_name": "IP使用選択", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "自動", "can_calc": "0", "data_code": "ip_start", "data_name": "IPスタート", "data_type": "string", "conv_table": [{"code": "0", "disp": "手動", "item": "手動"}, {"code": "1", "disp": "自動", "item": "自動"}], "data_class": "治療状況", "field_name": "IPスタート", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "33.0", "can_calc": "0", "data_code": "ip_oneshot_quantity", "data_name": "IPワンショット量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "IPワンショット量", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13.2", "can_calc": "0", "data_code": "ip_velocity", "data_name": "IP速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "IP速度", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13.2", "can_calc": "0", "data_code": "ip_velocity_max", "data_name": "IP速度最大値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "IP速度最大値", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "auto_oneshot", "data_name": "自動ワンショット", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "治療状況", "field_name": "自動ワンショット", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "入", "can_calc": "0", "data_code": "ip_auto_off", "data_name": "IP電源自動切り", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "治療状況", "field_name": "IP電源自動切り", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "入", "can_calc": "0", "data_code": "ip_power_ok_monitor_off", "data_name": "IP電源OKモニタ切り", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "治療状況", "field_name": "IP電源OKモニタ切り", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "ip_power_ok_monitor_off_time", "data_name": "IP電源OKモニタ切り時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "IP電源OKモニタ切り時間", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "90", "can_calc": "0", "data_code": "spo2", "data_name": "SpO2", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "spo2", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6", "can_calc": "0", "data_code": "blood_glucose_level", "data_name": "血糖値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "blood_glucose_level", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120", "can_calc": "0", "data_code": "bp_high", "data_name": "最高血圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "bp_high", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "80", "can_calc": "0", "data_code": "bp_low", "data_name": "最低血圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "bp_low", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "bp_ave", "data_name": "平均血圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "bp_ave", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "0", "data_code": "pulse", "data_name": "脈拍", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "pulse", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70", "can_calc": "0", "data_code": "body_temperature", "data_name": "体温", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "body_temperature", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "m001", "data_name": "[モニタ]経過時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m001", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "0", "data_code": "m002", "data_name": "[モニタ]経過時間(ECUM)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m002", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "210", "can_calc": "0", "data_code": "m003", "data_name": "[モニタ]残り時間(除水完了)", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "m003", "disp_format": "HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "240", "can_calc": "0", "data_code": "m004", "data_name": "[モニタ]残り時間(透析完了)", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "m004", "disp_format": "HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "m005", "data_name": "[モニタ]除水積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m005", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.55", "can_calc": "0", "data_code": "m006", "data_name": "[モニタ]除水速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m006", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3.0", "can_calc": "0", "data_code": "m007", "data_name": "[モニタ]血液循環量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m007", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "210", "can_calc": "0", "data_code": "m008", "data_name": "[モニタ]血流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m008", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.0", "can_calc": "0", "data_code": "m009", "data_name": "[モニタ]IP総量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m009", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.0", "can_calc": "0", "data_code": "m010", "data_name": "[モニタ]IP速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m010", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "0", "data_code": "m011", "data_name": "[モニタ]静脈圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m011", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "8", "can_calc": "0", "data_code": "m012", "data_name": "[モニタ]透析液圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m012", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "9", "can_calc": "0", "data_code": "m013", "data_name": "[モニタ]TMP", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m013", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "m014", "data_name": "[モニタ]ダイアライザー入口圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m014", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "11", "can_calc": "0", "data_code": "m015", "data_name": "[モニタ]ダイアライザー差圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m015", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12", "can_calc": "0", "data_code": "m016", "data_name": "[モニタ]血液入口～静脈平均圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m016", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13.0", "can_calc": "0", "data_code": "m017", "data_name": "[モニタ]⊿BV", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m017", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.40", "can_calc": "0", "data_code": "m018", "data_name": "[モニタ]バイカーボ濃度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m018", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15.0", "can_calc": "0", "data_code": "m019", "data_name": "[モニタ]透析液濃度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m019", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "16", "can_calc": "0", "data_code": "m020", "data_name": "[モニタ]Na濃度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m020", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "37.0", "can_calc": "0", "data_code": "m021", "data_name": "[モニタ]透析液温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m021", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "18", "can_calc": "0", "data_code": "m022", "data_name": "[モニタ]透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m022", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.9", "can_calc": "0", "data_code": "m023", "data_name": "[モニタ]漏血量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m023", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "0", "data_code": "m024", "data_name": "[モニタ]給液圧(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m024", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "0", "data_code": "m025", "data_name": "[モニタ]給液圧(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m025", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "22.00", "can_calc": "0", "data_code": "m026", "data_name": "[モニタ]UFR", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m026", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "23", "can_calc": "0", "data_code": "m027", "data_name": "[モニタ]UFR低下率", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m027", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "24.00", "can_calc": "0", "data_code": "m028", "data_name": "[モニタ]初期UFR測定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m028", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "25.0", "can_calc": "0", "data_code": "m029", "data_name": "[モニタ]TMP補正値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m029", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "26", "can_calc": "0", "data_code": "m030", "data_name": "[モニタ]透析運転時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m030", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "m031", "data_name": "[モニタ]治療モード", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m031", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "28.00", "can_calc": "0", "data_code": "m032", "data_name": "[モニタ]除水目標値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m032", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.00", "can_calc": "0", "data_code": "m033", "data_name": "[モニタ]除水速度設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m033", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "33.0", "can_calc": "0", "data_code": "m034", "data_name": "[モニタ]透析液温度設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m034", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "31", "can_calc": "0", "data_code": "m035", "data_name": "[モニタ]透析液流量設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m035", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "32", "can_calc": "0", "data_code": "m036", "data_name": "[モニタ]血流量設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m036", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "33.0", "can_calc": "0", "data_code": "m037", "data_name": "[モニタ]IP速度設定", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m037", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.34", "can_calc": "0", "data_code": "m038", "data_name": "[モニタ]Kt/V測定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m038", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "35", "can_calc": "0", "data_code": "m039", "data_name": "[モニタ]静脈圧警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m039", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36", "can_calc": "0", "data_code": "m040", "data_name": "[モニタ]静脈圧警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m040", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "37", "can_calc": "0", "data_code": "m041", "data_name": "[モニタ]透析液圧警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m041", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "38", "can_calc": "0", "data_code": "m042", "data_name": "[モニタ]透析液圧警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m042", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "39", "can_calc": "0", "data_code": "m043", "data_name": "[モニタ]TMP警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m043", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "40", "can_calc": "0", "data_code": "m044", "data_name": "[モニタ]TMP警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m044", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "40", "can_calc": "0", "data_code": "m045", "data_name": "[モニタ]ダイアライザー入口圧警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m045", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "42", "can_calc": "0", "data_code": "m046", "data_name": "[モニタ]ダイアライザー入口圧警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m046", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "43", "can_calc": "0", "data_code": "m047", "data_name": "[モニタ]ダイアライザー差圧警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m047", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "44", "can_calc": "0", "data_code": "m048", "data_name": "[モニタ]ダイアライザー差圧警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m048", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-45.0", "can_calc": "0", "data_code": "m049", "data_name": "[モニタ]⊿BV低下警報点１", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m049", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-46.0", "can_calc": "0", "data_code": "m050", "data_name": "[モニタ]⊿BV低下警報点２", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m050", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-17.0", "can_calc": "0", "data_code": "m051", "data_name": "[モニタ]⊿BV変化率警報点", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m051", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "48", "can_calc": "0", "data_code": "m052", "data_name": "[モニタ]BPM関連データ9", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m052", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-49", "can_calc": "0", "data_code": "m053", "data_name": "[モニタ]BPM関連データ10", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m053", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.00", "can_calc": "0", "data_code": "m054", "data_name": "[モニタ]バイカーボ濃度警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m054", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.10", "can_calc": "0", "data_code": "m055", "data_name": "[モニタ]バイカーボ濃度警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m055", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.2", "can_calc": "0", "data_code": "m056", "data_name": "[モニタ]透析液濃度警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m056", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "53.0", "can_calc": "0", "data_code": "m057", "data_name": "[モニタ]透析液濃度警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m057", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "54", "can_calc": "0", "data_code": "m058", "data_name": "[モニタ]Na濃度警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m058", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55", "can_calc": "0", "data_code": "m059", "data_name": "[モニタ]Na濃度警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m059", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "56.0", "can_calc": "0", "data_code": "m060", "data_name": "[モニタ]透析液温度警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m060", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "57.0", "can_calc": "0", "data_code": "m061", "data_name": "[モニタ]透析液温度警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m061", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.8", "can_calc": "0", "data_code": "m062", "data_name": "[モニタ]漏血量警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m062", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "59", "can_calc": "0", "data_code": "m063", "data_name": "[モニタ]給水圧警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m063", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "0", "data_code": "m064", "data_name": "[モニタ]給水圧警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m064", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.10", "can_calc": "0", "data_code": "m065", "data_name": "[モニタ]初期UFR警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m065", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "62.00", "can_calc": "0", "data_code": "m066", "data_name": "[モニタ]初期UFR警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m066", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "63", "can_calc": "0", "data_code": "m067", "data_name": "[モニタ]UFR低下率警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m067", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.60", "can_calc": "0", "data_code": "m068", "data_name": "[モニタ]Kt/V", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m068", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.50", "can_calc": "0", "data_code": "m069", "data_name": "[モニタ]運転中の血流量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m069", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.5", "can_calc": "0", "data_code": "m070", "data_name": "[モニタ]補液量設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m070", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.68", "can_calc": "0", "data_code": "m071", "data_name": "[モニタ]補液速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m071", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "69.00", "can_calc": "0", "data_code": "m072", "data_name": "[モニタ]補液量現在値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m072", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.70", "can_calc": "0", "data_code": "m073", "data_name": "[モニタ]補液速度設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m073", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.7", "can_calc": "0", "data_code": "m074", "data_name": "[モニタ]補液温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m074", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30.0", "can_calc": "0", "data_code": "m075", "data_name": "[モニタ]補液温度設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m075", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7.30", "can_calc": "0", "data_code": "m076", "data_name": "[モニタ]濾液速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m076", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "74.00", "can_calc": "0", "data_code": "m077", "data_name": "[モニタ]荷重計", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m077", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "m078", "data_name": "[モニタ]残り時間(補液完了)", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "m078", "disp_format": "HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50.0", "can_calc": "0", "data_code": "m079", "data_name": "[モニタ]URR", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m079", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "77.0", "can_calc": "0", "data_code": "m080", "data_name": "[モニタ]⊿BV変化率", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m080", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "78.00", "can_calc": "0", "data_code": "m081", "data_name": "[モニタ]PWI", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m081", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "79", "can_calc": "0", "data_code": "m082", "data_name": "[モニタ]BPM関連データ1", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m082", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "180", "can_calc": "0", "data_code": "m083", "data_name": "[モニタ]BPM関連データ2", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m083", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "39", "can_calc": "0", "data_code": "m084", "data_name": "[モニタ]BPM関連データ3", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m084", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "82.0", "can_calc": "0", "data_code": "m085", "data_name": "[モニタ]⊿BVリファレンスエリア上限", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m085", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "83.0", "can_calc": "0", "data_code": "m086", "data_name": "[モニタ]⊿BVリファレンスエリア下限", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m086", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "84", "can_calc": "0", "data_code": "m087", "data_name": "[モニタ]BPM関連データ6", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m087", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4.00", "can_calc": "0", "data_code": "m088", "data_name": "[モニタ]PRR", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m088", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "m089", "data_name": "[モニタ]再循環率測定結果(BVMS連携用)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m089", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "0", "data_code": "m095", "data_name": "[モニタ]⊿BV5分平均値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m095", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.0", "can_calc": "0", "data_code": "m096", "data_name": "[モニタ]⊿BV最大最小を除いた5分平均値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m096", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "0", "data_code": "m097", "data_name": "[モニタ]推定血流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m097", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50.0", "can_calc": "0", "data_code": "m098", "data_name": "[モニタ]血流量不足率", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m098", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "m100", "data_name": "[モニタ]⊿BV(BVplus)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m100", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "m101", "data_name": "[モニタ]Ht", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m101", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "m102", "data_name": "[モニタ]LDQb", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m102", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "m103", "data_name": "[モニタ]補液回路内圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m103", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz11", "data_name": "[ACHΣ]治療モード", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz11", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz21", "data_name": "[ACHΣ]工程状態", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz21", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz31", "data_name": "[ACHΣ]除水速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz31", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz41", "data_name": "[ACHΣ]血液流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz41", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz51", "data_name": "[ACHΣ]シリンジ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz51", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz61", "data_name": "[ACHΣ]ろ過流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz61", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz71", "data_name": "[ACHΣ]透析液/ドレン流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz71", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz81", "data_name": "[ACHΣ]補液流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz81", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz91", "data_name": "[ACHΣ]透析液加温器温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz91", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz101", "data_name": "[ACHΣ]補液加温器温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz101", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz111", "data_name": "[ACHΣ]現在除水量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz111", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz121", "data_name": "[ACHΣ]現在血液循環量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz121", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz131", "data_name": "[ACHΣ]現在ろ過量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz131", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz141", "data_name": "[ACHΣ]現在透析液/ドレン量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz141", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz151", "data_name": "[ACHΣ]現在補液量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz151", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz161", "data_name": "[ACHΣ]治療時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz161", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz171", "data_name": "[ACHΣ]シリンジ積算量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz171", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz181", "data_name": "[ACHΣ]目標除水量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz181", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz191", "data_name": "[ACHΣ]目標血液循環量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz191", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz201", "data_name": "[ACHΣ]目標ろ過量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz201", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz211", "data_name": "[ACHΣ]目標透析液/ドレン量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz211", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz221", "data_name": "[ACHΣ]目標補液量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz221", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz231", "data_name": "[ACHΣ]目標治療時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz231", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz241", "data_name": "[ACHΣ]脱血圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz241", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz251", "data_name": "[ACHΣ]入口圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz251", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz261", "data_name": "[ACHΣ]静脈圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz261", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz271", "data_name": "[ACHΣ]ろ過圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz271", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz281", "data_name": "[ACHΣ]排気圧/2次膜圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz281", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz291", "data_name": "[ACHΣ]TMP/TMP1", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz291", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz301", "data_name": "[ACHΣ]TMP2", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz301", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz311", "data_name": "[ACHΣ]差圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz311", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz321", "data_name": "[ACHΣ]気泡検知警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz321", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz331", "data_name": "[ACHΣ]漏血警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz331", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz341", "data_name": "[ACHΣ]加温器警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz341", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz351", "data_name": "[ACHΣ]脱血圧警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz351", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz361", "data_name": "[ACHΣ]入口圧警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz361", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz371", "data_name": "[ACHΣ]静脈圧警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz371", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz381", "data_name": "[ACHΣ]ろ過圧警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz381", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz391", "data_name": "[ACHΣ]排気圧/2次膜圧警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz391", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz401", "data_name": "[ACHΣ]TMP警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz401", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz411", "data_name": "[ACHΣ]TMP2警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz411", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz421", "data_name": "[ACHΣ]差圧警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz421", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz431", "data_name": "[ACHΣ]その他警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz431", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz441", "data_name": "[ACHΣ]クエン酸流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz441", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz451", "data_name": "[ACHΣ]現在クエン酸量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz451", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz12", "data_name": "[KM8900]測定値TMP", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz12", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz22", "data_name": "[KM8900]測定値入口圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz22", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz32", "data_name": "[KM8900]測定値返血圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz32", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz42", "data_name": "[KM8900]測定値2次膜圧(吸着圧)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz42", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz52", "data_name": "[KM8900]圧力上限警報設定値TMP", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz52", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz62", "data_name": "[KM8900]圧力上限警報設定値入口圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz62", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz72", "data_name": "[KM8900]圧力上限警報設定値返血圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz72", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz82", "data_name": "[KM8900]圧力上限警報設定値2次膜圧(吸着圧)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz82", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz92", "data_name": "[KM8900]流量情報BP瞬時流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz92", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz102", "data_name": "[KM8900]流量情報PP瞬時流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz102", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz112", "data_name": "[KM8900]流量情報DP瞬時流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz112", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz122", "data_name": "[KM8900]流量情報BP積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz122", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz132", "data_name": "[KM8900]流量情報PP積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz132", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz142", "data_name": "[KM8900]流量情報DP積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz142", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz152", "data_name": "[KM8900]流量情報除水積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz152", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz162", "data_name": "[KM8900]流量情報血漿処理目標値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz162", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz172", "data_name": "[KM8900]その他情報加温器温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz172", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz182", "data_name": "[KM8900]その他情報バランス", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz182", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz192", "data_name": "[KM8900]経過時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz192", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz202", "data_name": "[KM8900]その他情報アラーム番号", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz202", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz212", "data_name": "[KM8900]その他情報自己診断番号", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz212", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz222", "data_name": "[KM8900]その他情報モード(用途)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz222", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz232", "data_name": "[KM8900]その他情報工程情報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz232", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz13", "data_name": "[iQ21]治療経過時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz13", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz23", "data_name": "[iQ21]除水速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz23", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz33", "data_name": "[iQ21]ろ過ポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz33", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz43", "data_name": "[iQ21]補液ポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz43", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz53", "data_name": "[iQ21]透析液ポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz53", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz63", "data_name": "[iQ21]血液ポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz63", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz73", "data_name": "[iQ21]シリンジポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz73", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz83", "data_name": "[iQ21]除水量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz83", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz93", "data_name": "[iQ21]ろ過量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz93", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz103", "data_name": "[iQ21]補液量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz103", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz113", "data_name": "[iQ21]透析液量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz113", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz123", "data_name": "[iQ21]血液循環量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz123", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz133", "data_name": "[iQ21]シリンジポンプ積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz133", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz143", "data_name": "[iQ21]採血圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz143", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz153", "data_name": "[iQ21]動脈圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz153", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz163", "data_name": "[iQ21]静脈圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz163", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz173", "data_name": "[iQ21]ろ過圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz173", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz183", "data_name": "[iQ21]TMP", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz183", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz193", "data_name": "[iQ21]分離ポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz193", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz203", "data_name": "[iQ21]返漿ポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz203", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz213", "data_name": "[iQ21]ドレンポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz213", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz223", "data_name": "[iQ21]分離量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz223", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz233", "data_name": "[iQ21]返漿量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz233", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz243", "data_name": "[iQ21]ドレン量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz243", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz253", "data_name": "[iQ21]血漿圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz253", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz263", "data_name": "[iQ21]血漿入口圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz263", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz14", "data_name": "[KM9000]測定値TMP圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz14", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz24", "data_name": "[KM9000]測定値入口圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz24", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz34", "data_name": "[KM9000]測定値返血圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz34", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz44", "data_name": "[KM9000]測定値ろ過圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz44", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz54", "data_name": "[KM9000]測定値浄化器圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz54", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz64", "data_name": "[KM9000]設定値TMP圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz64", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz74", "data_name": "[KM9000]設定値入口圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz74", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz84", "data_name": "[KM9000]設定値返血圧・上限", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz84", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz94", "data_name": "[KM9000]設定値返血圧・下限", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz94", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz104", "data_name": "[KM9000]設定値浄化器圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz104", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz114", "data_name": "[KM9000]設定値除水設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz114", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz124", "data_name": "[KM9000]流量情報血液ﾎﾟﾝﾌﾟ指令流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz124", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz134", "data_name": "[KM9000]流量情報透析液ﾎﾟﾝﾌﾟ指令流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz134", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz144", "data_name": "[KM9000]流量情報補充液ﾎﾟﾝﾌﾟ指令流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz144", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz154", "data_name": "[KM9000]流量情報ろ液ﾎﾟﾝﾌﾟ指令流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz154", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz164", "data_name": "[KM9000]流量情報血液ﾎﾟﾝﾌﾟ積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz164", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz174", "data_name": "[KM9000]流量情報透析液ﾎﾟﾝﾌﾟ積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz174", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz184", "data_name": "[KM9000]流量情報補充液ﾎﾟﾝﾌﾟ積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz184", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz194", "data_name": "[KM9000]流量情報除水積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz194", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz204", "data_name": "[KM9000]その他情報加温器温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz204", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz214", "data_name": "[KM9000]その他情報除水差分/重量値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz214", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz224", "data_name": "[KM9000]その他情報初期診断情報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz224", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz234", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報1", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz234", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz244", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報2", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz244", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz254", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報3", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz254", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz264", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報4", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz264", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz274", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報5", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz274", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz284", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報6", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz284", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz294", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報7", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz294", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz304", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報8", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz304", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz314", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報9", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz314", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz324", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報10", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz324", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz334", "data_name": "[KM9000]その他情報注意情報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz334", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz344", "data_name": "[KM9000]経過時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz344", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz354", "data_name": "[KM9000]その他情報用途", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz354", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz364", "data_name": "[KM9000]その他情報工程", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz364", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz374", "data_name": "[KM9000]その他情報動作日、時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz374", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "0", "data_code": "dw", "data_name": "DW", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "dw", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.00", "can_calc": "0", "data_code": "iapratio", "data_name": "IAP Ratio", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "iapratio", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.10", "can_calc": "0", "data_code": "ihdf_pll", "data_name": "I-HDF引き残し量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "ihdf引き残し量", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "ip_auto_cycle_time", "data_name": "IP電源自動切り時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "ip電源自動切り時間", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "leftovers", "data_name": "引き残し", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "引き残し", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト患者", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "hosp_pat_id", "target_var": "@patId"}, "data_code": "hosp_pat_id", "data_name": "患者ID", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "hosp_pat_id", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "observation_records_num", "data_name": "観察記録件数", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "観察記録件数", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "machine_status", "data_name": "警報・報知", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "警報・報知", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "weight_after_tare_total", "data_name": "後体重風袋合計", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "後体重風袋合計", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2000", "can_calc": "0", "data_code": "anticoagulants_total_volume", "data_name": "抗凝固剤持続総量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "抗凝固剤持続総量", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "25", "can_calc": "0", "data_code": "recirculation_rate_eff", "data_name": "再循環率有効値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "再循環率有効値", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト愁訴", "can_calc": "0", "data_code": "complaint_latest", "data_name": "最新愁訴", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "最新愁訴", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト処置", "can_calc": "0", "data_code": "treatment_latest", "data_name": "最新処置", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "最新処置", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "はい", "can_calc": "0", "data_code": "is_content_changed_for_map", "data_name": "指示変更", "data_type": "string", "conv_table": [{"code": 0, "disp": "変更なし", "item": "変更なし"}, {"code": 1, "disp": "変更あり", "item": "変更あり"}], "data_class": "治療状況", "field_name": "指示変更", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/06/15 11:24:00", "can_calc": "0", "data_code": "treatment_end", "data_name": "治療終了", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "治療終了", "disp_format": "yyyy/MM/dd HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/06/15 11:24:00", "can_calc": "0", "data_code": "forecast_end_fr_end", "data_name": "終了予測(補液完了)", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "終了予測補液完了", "disp_format": "yyyy/MM/dd HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "off_water_total", "data_name": "除水補正合計", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "除水補正合計", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.00", "can_calc": "0", "data_code": "sttc_vns_prssr", "data_name": "静的静脈圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "静的静脈圧", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "last_weight_after", "data_name": "前回後体重", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前回後体重", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "0", "data_code": "weight_before_dw", "data_name": "前体重 - DW", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前体重dw", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "0", "data_code": "weight_before_weight_target", "data_name": "前体重 - 目標体重", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前体重目標体重", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "weight_before_weight_after", "data_name": "前体重-後体重", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前体重後体重", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "weight_before_tare_total", "data_name": "前体重風袋合計", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前体重風袋合計", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "device_self_diagnosis", "data_name": "装置自己診断", "data_type": "string", "conv_table": [{"code": 0, "disp": "未実施", "item": "未実施"}, {"code": 1, "disp": "実施済み", "item": "実施済み"}], "data_class": "治療状況", "field_name": "装置自己診断", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "per_increase", "data_name": "増加率", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "増加率", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "amount_increase", "data_name": "増加量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "増加量", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "achievement_rate", "data_name": "達成率", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "達成率", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0/0", "can_calc": "0", "data_code": "dosing_status", "data_name": "投与状況", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "投与状況", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "dialysates_used_num", "data_name": "透析液使用数", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "透析液使用数", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "leftovers_expected", "data_name": "予想引き残し", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "予想引き残し", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "BED-01", "can_calc": "0", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "ベッド名", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/3/12 08:21", "can_calc": "0", "data_code": "start_time", "data_name": "透析開始時刻", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "start_time", "disp_format": "hh:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/3/12  12:45", "can_calc": "0", "data_code": "end_time", "data_name": "透析終了時刻", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "end_time", "disp_format": "hh:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [3]}', '治療状況リスト', '2020-04-25 00:00:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (192, '{"collection" : "ind_history","eq" : { "pat_id" : "@patId","facility_cd" : "@facilityCd" }, "lte": {"treatment_start_date": "@endDate"}, "or":{"treatment_end_date":"{ gte: ''@fromDate'',exists: false ,eq:''''}" }, "sort" : {"log_date" : "asc"}}', 4, '[{"preview": "〇", "can_calc": "0", "data_code": "treatment_schedule__before", "data_name": "治療予定（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "treatment_schedule__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "treatment_schedule__after", "data_name": "治療予定（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "treatment_schedule__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "treatment_method__before", "data_name": "治療方法（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "treatment_method__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "treatment_method__after", "data_name": "治療方法（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "treatment_method__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "treatment_date__before", "data_name": "治療日（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "treatment_date__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "treatment_date__after", "data_name": "治療日（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "treatment_date__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "cool__before", "data_name": "クール（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "cool__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "cool__after", "data_name": "クール（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "cool__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "treatment_start_date__before", "data_name": "治療開始時刻（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "treatment_start_date__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "treatment_start_date__after", "data_name": "治療開始時刻（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "treatment_start_date__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "bed__before", "data_name": "ベッド（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "bed__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "bed__after", "data_name": "ベッド（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "bed__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "treatment_time__before", "data_name": "治療時間（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "treatment_time__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "treatment_time__after", "data_name": "治療時間（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "treatment_time__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "dw__before", "data_name": "DW（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "dw__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "dw__after", "data_name": "DW（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "dw__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "va__before", "data_name": "VA（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "va__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "va__after", "data_name": "VA（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "va__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "target_weight__before", "data_name": "目標体重（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "target_weight__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "target_weight__after", "data_name": "目標体重（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "target_weight__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "water_limit__before", "data_name": "除水量制限（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "water_limit__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "water_limit__after", "data_name": "除水量制限（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "water_limit__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "dializer__before", "data_name": "ダイアライザ（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "dializer__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "dializer__after", "data_name": "ダイアライザ（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "dializer__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "adsorption_column__before", "data_name": "吸着カラム（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "adsorption_column__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "adsorption_column__after", "data_name": "吸着カラム（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "adsorption_column__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "one_film__before", "data_name": "1次膜（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "one_film__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "one_film__after", "data_name": "1次膜（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "one_film__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "two_film__before", "data_name": "2次膜（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "two_film__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "two_film__after", "data_name": "2次膜（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "two_film__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "puncture_needle_a__before", "data_name": "穿刺針(A針)（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "puncture_needle_a__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "puncture_needle_a__after", "data_name": "穿刺針(A針)（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "puncture_needle_a__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "puncture_needle_v__before", "data_name": "穿刺針(V針)（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "puncture_needle_v__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "puncture_needle_v__after", "data_name": "穿刺針(V針)（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "puncture_needle_v__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "puncture_needle_sn__before", "data_name": "穿刺針(SN)（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "puncture_needle_sn__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "puncture_needle_sn__after", "data_name": "穿刺針(SN)（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "puncture_needle_sn__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "use_single_needle__before", "data_name": "シングルニードル使用（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "use_single_needle__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "use_single_needle__after", "data_name": "シングルニードル使用（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "use_single_needle__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "blood_circuit__before", "data_name": "血液回路（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "blood_circuit__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "blood_circuit__after", "data_name": "血液回路（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "blood_circuit__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "blood_flow__before", "data_name": "血流量（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "blood_flow__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "blood_flow__after", "data_name": "血流量（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "blood_flow__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "dialysate__before", "data_name": "透析液（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "dialysate__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "dialysate__after", "data_name": "透析液（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "dialysate__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "dialysate_flow_rate__before", "data_name": "透析液流量（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "dialysate_flow_rate__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "dialysate_flow_rate__after", "data_name": "透析液流量（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "dialysate_flow_rate__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "amount_of_dialysate__before", "data_name": "透析液量（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "amount_of_dialysate__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "amount_of_dialysate__after", "data_name": "透析液量（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "amount_of_dialysate__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "dialysate_temperature__before", "data_name": "透析液温度（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "dialysate_temperature__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "dialysate_temperature__after", "data_name": "透析液温度（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "dialysate_temperature__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "fluid_replacement__before", "data_name": "補液（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "fluid_replacement__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "fluid_replacement__after", "data_name": "補液（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "fluid_replacement__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "fluid_replacement_volume__before", "data_name": "補液量（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "fluid_replacement_volume__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "fluid_replacement_volume__after", "data_name": "補液量（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "fluid_replacement_volume__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "fluid_replacement_selection__before", "data_name": "補液選択（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "fluid_replacement_selection__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "fluid_replacement_selection__after", "data_name": "補液選択（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "fluid_replacement_selection__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "number_replacement_fluids_used__before", "data_name": "補液使用数（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "number_replacement_fluids_used__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "number_replacement_fluids_used__after", "data_name": "補液使用数（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "number_replacement_fluids_used__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "fluid_replacement_temperature__before", "data_name": "補液温度（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "fluid_replacement_temperature__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "fluid_replacement_temperature__after", "data_name": "補液温度（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "fluid_replacement_temperature__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "fluid_replacement_speed__before", "data_name": "補液速度（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "fluid_replacement_speed__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "fluid_replacement_speed__after", "data_name": "補液速度（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "fluid_replacement_speed__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "anticoagulant__before", "data_name": "抗凝固剤（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "anticoagulant__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "anticoagulant__after", "data_name": "抗凝固剤（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "anticoagulant__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "anticoagulant_one-shot_amount__before", "data_name": "抗凝固剤ワンショット量（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "anticoagulant_one-shot_amount__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "anticoagulant_one-shot_amount__after", "data_name": "抗凝固剤ワンショット量（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "anticoagulant_one-shot_amount__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "anticoagulant_duration__before", "data_name": "抗凝固剤持続速度（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "anticoagulant_duration__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "anticoagulant_duration__after", "data_name": "抗凝固剤持続速度（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "anticoagulant_duration__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "anticoagulant_sustained_total_amount__before", "data_name": "抗凝固剤持続総量（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "anticoagulant_sustained_total_amount__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "anticoagulant_sustained_total_amount__after", "data_name": "抗凝固剤持続総量（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "anticoagulant_sustained_total_amount__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "ip_usage_selection__before", "data_name": "IP使用選択（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "ip_usage_selection__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "ip_usage_selection__after", "data_name": "IP使用選択（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "ip_usage_selection__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "ip_start__before", "data_name": "IPスタート（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "ip_start__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "ip_start__after", "data_name": "IPスタート（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "ip_start__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "ip_one-shot_amount__before", "data_name": "IPワンショット量（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "ip_one-shot_amount__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "ip_one-shot_amount__after", "data_name": "IPワンショット量（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "ip_one-shot_amount__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "ip_speed__before", "data_name": "IP速度（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "ip_speed__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "ip_speed__after", "data_name": "IP速度（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "ip_speed__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "ip_speed_max__before", "data_name": "IP速度最大値（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "ip_speed_max__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "ip_speed_max__after", "data_name": "IP速度最大値（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "ip_speed_max__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "automatic_one_shot__before", "data_name": "IPワンショットスタート（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "automatic_one_shot__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "automatic_one_shot__after", "data_name": "IPワンショットスタート（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "automatic_one_shot__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "ip_power_off_automatically__before", "data_name": "IP電源自動切り（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "ip_power_off_automatically__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "ip_power_off_automatically__after", "data_name": "IP電源自動切り（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "ip_power_off_automatically__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "ip_power_off_time__before", "data_name": "IP電源自動切り時間（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "ip_power_off_time__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "ip_power_off_time__after", "data_name": "IP電源自動切り時間（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "ip_power_off_time__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "ip_power_monitor_off__before", "data_name": "IP電源OKモニタ切り（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "ip_power_monitor_off__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "ip_power_monitor_off__after", "data_name": "IP電源OKモニタ切り（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "ip_power_monitor_off__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "ip_power_monitor_off_time__before", "data_name": "IP電源OKモニタ切り時間（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "ip_power_monitor_off_time__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "ip_power_monitor_off_time__after", "data_name": "IP電源OKモニタ切り時間（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "ip_power_monitor_off_time__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "administered_drug__before", "data_name": "投与薬剤（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "administered_drug__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "administered_drug__after", "data_name": "投与薬剤（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "administered_drug__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "medical_materials__before", "data_name": "医療材料（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "medical_materials__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "medical_materials__after", "data_name": "医療材料（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "medical_materials__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "instructional_comment__before", "data_name": "指示コメント（修正前）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "instructional_comment__before", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "〇", "can_calc": "0", "data_code": "instructional_comment__after", "data_name": "指示コメント（修正後）", "data_type": "string", "conv_table": [], "data_class": "修正内容", "field_name": "instructional_comment__after", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '修正内容：指示', '2020-07-31 18:29:49', CURRENT_TIMESTAMP, NULL);
