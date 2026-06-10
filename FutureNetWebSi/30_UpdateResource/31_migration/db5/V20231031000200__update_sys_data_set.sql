DELETE FROM "ntss"."sys_data_set" where sql_cd in (45);		
		
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (45, 'with ord_tbl as (		
  select		
    facility_cd,		
    pat_id,		
    ind_bed_cd,		
		treat_date,
    to_timestamp(treat_date, ''yyyymmdd'') + ''1 days - 1 milliseconds'' as treat_date_end		
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
	 and rst_dialysis_state = ''0'') and is_del = ''0'' and rst_dialysis_state = ''0'' ORDER BY treat_date ASC limit 1	
		
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
		
),		
 b AS (		
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
    from b inner join mni_monitor on (b.ord_no = mni_monitor.ord_no)		
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
),g as (		
select				
b.rst_start_date + e.経過時間  * interval ''1 minute'' AS  ind_end_date,			
CASE WHEN b.rst_dialysis_state < ''3'' THEN null		
       WHEN f.残り時間_除水完了 > f.残り時間_透析完了 THEN b.rst_start_date + f.予測時間_除水 * interval ''1 minute''		
       ELSE b.rst_start_date + f.予測時間_透析 * interval ''1 minute''		
  END AS ind_end_date_time				
, b.rst_start_date			
, b.rst_end_date		
, b.ord_no as ordnob		
from  b left join e on b.ord_no = e.ord_no left join f on b.ord_no = f.ord_no)		
select g.*,		
  to_date(ord.treat_date, ''yyyymmdd'') as treat_date,		
  ord.ind_kur_cd as kur_cd,		
  ord.ind_va_cd as va_cd,		
  ord.ind_treatment_cd as treatment_cd,		
	treatment_tbl.treatment_name AS treatment_name1,	
  to_char(to_timestamp(ord.ind_treat_start_time, ''HH24MI''), ''HH24:MI'') as treat_start_time,		
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
		
  CAST(ord.ind_cond_info->''26''->>''value'' AS DECIMAL)		
    + CAST(ord.ind_cond_info->''28''->>''value'' AS DECIMAL)		
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
	case 	
	  when treatment_tbl.in_hosp_a_startdate <= cast(ord_tbl.treat_date as TIMESTAMP) and cast(ord_tbl.treat_date as TIMESTAMP) < treatment_tbl.in_hosp_b_startdate then treatment_tbl.in_hospital_cd_a1 	
	  when treatment_tbl.in_hosp_b_startdate <= cast(ord_tbl.treat_date as TIMESTAMP) and cast(ord_tbl.treat_date as TIMESTAMP) < treatment_tbl.in_hosp_a_startdate then treatment_tbl.in_hospital_cd_b1 	
	  when treatment_tbl.in_hosp_a_startdate <= cast(ord_tbl.treat_date as TIMESTAMP) and treatment_tbl.in_hosp_b_startdate is null then treatment_tbl.in_hospital_cd_a1	
		when treatment_tbl.in_hosp_b_startdate <= cast(ord_tbl.treat_date as TIMESTAMP) and treatment_tbl.in_hosp_a_startdate is null then treatment_tbl.in_hospital_cd_b1
		when treatment_tbl.in_hosp_b_startdate < treatment_tbl.in_hosp_a_startdate and treatment_tbl.in_hosp_a_startdate <= cast(ord_tbl.treat_date as TIMESTAMP) then treatment_tbl.in_hospital_cd_a1
	  when treatment_tbl.in_hosp_a_startdate < treatment_tbl.in_hosp_b_startdate and treatment_tbl.in_hosp_b_startdate <= cast(ord_tbl.treat_date as TIMESTAMP) then treatment_tbl.in_hospital_cd_b1	
		when cast(ord_tbl.treat_date as TIMESTAMP) = treatment_tbl.in_hosp_a_startdate and cast(ord_tbl.treat_date as TIMESTAMP) = treatment_tbl.in_hosp_b_startdate then treatment_tbl.in_hospital_cd_a1
		else ''''
	end as treatment_in_hospital_cd1,	
	case 	
	  when treatment_tbl.in_hosp_a_startdate <= cast(ord_tbl.treat_date as TIMESTAMP) and cast(ord_tbl.treat_date as TIMESTAMP) < treatment_tbl.in_hosp_b_startdate then treatment_tbl.in_hospital_cd_a2	
		when treatment_tbl.in_hosp_b_startdate <= cast(ord_tbl.treat_date as TIMESTAMP) and cast(ord_tbl.treat_date as TIMESTAMP) < treatment_tbl.in_hosp_a_startdate then treatment_tbl.in_hospital_cd_b2 
	  when treatment_tbl.in_hosp_a_startdate <= cast(ord_tbl.treat_date as TIMESTAMP) and treatment_tbl.in_hosp_b_startdate is null then treatment_tbl.in_hospital_cd_a2	
		when treatment_tbl.in_hosp_b_startdate <= cast(ord_tbl.treat_date as TIMESTAMP) and treatment_tbl.in_hosp_a_startdate is null then treatment_tbl.in_hospital_cd_b2
		when treatment_tbl.in_hosp_b_startdate < treatment_tbl.in_hosp_a_startdate and treatment_tbl.in_hosp_a_startdate <= cast(ord_tbl.treat_date as TIMESTAMP) then treatment_tbl.in_hospital_cd_a2
	  when treatment_tbl.in_hosp_a_startdate < treatment_tbl.in_hosp_b_startdate and treatment_tbl.in_hosp_b_startdate <= cast(ord_tbl.treat_date as TIMESTAMP) then treatment_tbl.in_hospital_cd_b2	
		when cast(ord_tbl.treat_date as TIMESTAMP) = treatment_tbl.in_hosp_a_startdate and cast(ord_tbl.treat_date as TIMESTAMP) = treatment_tbl.in_hosp_b_startdate then treatment_tbl.in_hospital_cd_a2
		else ''''
	end as treatment_in_hospital_cd2,	
	case 	
	  when treatment_tbl.in_hosp_a_startdate <= cast(ord_tbl.treat_date as TIMESTAMP) and cast(ord_tbl.treat_date as TIMESTAMP) < treatment_tbl.in_hosp_b_startdate then treatment_tbl.in_hospital_cd_a3	
		when treatment_tbl.in_hosp_b_startdate <= cast(ord_tbl.treat_date as TIMESTAMP) and cast(ord_tbl.treat_date as TIMESTAMP) < treatment_tbl.in_hosp_a_startdate then treatment_tbl.in_hospital_cd_b3 
	  when treatment_tbl.in_hosp_a_startdate <= cast(ord_tbl.treat_date as TIMESTAMP) and treatment_tbl.in_hosp_b_startdate is null then treatment_tbl.in_hospital_cd_a3	
		when treatment_tbl.in_hosp_b_startdate <= cast(ord_tbl.treat_date as TIMESTAMP) and treatment_tbl.in_hosp_a_startdate is null then treatment_tbl.in_hospital_cd_b3
		when treatment_tbl.in_hosp_b_startdate < treatment_tbl.in_hosp_a_startdate and treatment_tbl.in_hosp_a_startdate <= cast(ord_tbl.treat_date as TIMESTAMP) then treatment_tbl.in_hospital_cd_a3
	  when treatment_tbl.in_hosp_a_startdate < treatment_tbl.in_hosp_b_startdate and treatment_tbl.in_hosp_b_startdate <= cast(ord_tbl.treat_date as TIMESTAMP) then treatment_tbl.in_hospital_cd_b3	
		when cast(ord_tbl.treat_date as TIMESTAMP) = treatment_tbl.in_hosp_a_startdate and cast(ord_tbl.treat_date as TIMESTAMP) = treatment_tbl.in_hosp_b_startdate then treatment_tbl.in_hospital_cd_a3
		else ''''
	end as treatment_in_hospital_cd3,	
	case 	
	  when treatment_tbl.in_hosp_a_startdate <= cast(ord_tbl.treat_date as TIMESTAMP) and cast(ord_tbl.treat_date as TIMESTAMP) < treatment_tbl.in_hosp_b_startdate then treatment_tbl.in_hospital_cd_a4	
		when treatment_tbl.in_hosp_b_startdate <= cast(ord_tbl.treat_date as TIMESTAMP) and cast(ord_tbl.treat_date as TIMESTAMP) < treatment_tbl.in_hosp_a_startdate then treatment_tbl.in_hospital_cd_b4 
	  when treatment_tbl.in_hosp_a_startdate <= cast(ord_tbl.treat_date as TIMESTAMP) and treatment_tbl.in_hosp_b_startdate is null then treatment_tbl.in_hospital_cd_a4	
		when treatment_tbl.in_hosp_b_startdate <= cast(ord_tbl.treat_date as TIMESTAMP) and treatment_tbl.in_hosp_a_startdate is null then treatment_tbl.in_hospital_cd_b4
		when treatment_tbl.in_hosp_b_startdate < treatment_tbl.in_hosp_a_startdate and treatment_tbl.in_hosp_a_startdate <= cast(ord_tbl.treat_date as TIMESTAMP) then treatment_tbl.in_hospital_cd_a4
	  when treatment_tbl.in_hosp_a_startdate < treatment_tbl.in_hosp_b_startdate and treatment_tbl.in_hosp_b_startdate <= cast(ord_tbl.treat_date as TIMESTAMP) then treatment_tbl.in_hospital_cd_b4	
		when cast(ord_tbl.treat_date as TIMESTAMP) = treatment_tbl.in_hosp_a_startdate and cast(ord_tbl.treat_date as TIMESTAMP) = treatment_tbl.in_hosp_b_startdate then treatment_tbl.in_hospital_cd_a4
		else ''''
	end as treatment_in_hospital_cd4,	
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
	left join g	
	on ord.ord_no=g.ordnob	
where		
		
	ord.ord_no = @ordNo	
  ', 2, '[{"preview": "2011/05/20", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "透析予定", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:10", "can_calc": "0", "data_code": "treatment_time", "data_name": "透析時間", "data_type": "DateTime", "conv_table": [], "data_class": "透析予定", "field_name": "treatment_time", "disp_format": "hh:mm", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "420", "can_calc": "0", "data_code": "treatment_time", "data_name": "透析時間(分)", "data_type": "decimal", "conv_table": [], "data_class": "透析予定", "field_name": "treatment_time", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "午前", "can_calc": "0", "data_code": "kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "透析予定", "field_name": "kur_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "09:00", "can_calc": "0", "data_code": "treat_start_time", "data_name": "透析開始時間", "data_type": "DateTime", "conv_table": [], "data_class": "透析予定", "field_name": "treat_start_time", "disp_format": "hh:mm", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ベッド001", "can_calc": "0", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "透析予定", "field_name": "bed_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/22", "can_calc": "0", "data_code": "next_treat_date", "data_name": "次回透析予定日", "data_type": "DateTime", "conv_table": [], "data_class": "透析予定", "field_name": "next_treat_date", "disp_format": "yyyy/mm/dd", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "04:00", "can_calc": "0", "data_code": "treatment_time", "data_name": "透析時間", "data_type": "DateTime", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_time", "disp_format": "[h]:mm", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "420", "can_calc": "0", "data_code": "treatment_time", "data_name": "透析時間(分)", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_time", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左手前腕内シャント化静脈", "can_calc": "0", "data_code": "va_name", "data_name": "VA", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "va_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "va_in_hospital_cd_1", "data_name": "VA連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "va_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "va_in_hospital_cd_2", "data_name": "VA連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "va_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左", "can_calc": "0", "data_code": "va_direct", "data_name": "VA方向", "data_type": "string", "conv_table": [{"code": "0", "disp": "両方", "item": "両方"}, {"code": "1", "disp": "左", "item": "左"}, {"code": "2", "disp": "右", "item": "右"}, {"code": "3", "disp": "なし", "item": "なし"}, {"code": "-", "disp": "不明", "item": "不明"}], "data_class": "透析条件", "field_name": "va_direct", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "DWと同じ", "can_calc": "0", "data_code": "target_weight_mode", "data_name": "目標体重指定設定", "data_type": "string", "conv_table": [{"code": "0", "disp": "DWと違う", "item": "DWと違う"}, {"code": "1", "disp": "DWと同じ", "item": "DWと同じ"}], "data_class": "透析条件", "field_name": "target_weight_mode", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "0", "data_code": "target_weight", "data_name": "目標体重", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "target_weight", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "HDF", "can_calc": "0", "data_code": "device_mode", "data_name": "装置モード", "data_type": "string", "conv_table": [{"code": "0", "disp": "HD", "item": "HD"}, {"code": "1", "disp": "ECUM", "item": "ECUM"}, {"code": "2", "disp": "HDF", "item": "HDF"}, {"code": "3", "disp": "HF", "item": "HF"}, {"code": "4", "disp": "HD＋補液", "item": "HD＋補液"}, {"code": "5", "disp": "ECUM＋補液", "item": "ECUM＋補液"}, {"code": "6", "disp": "AFBF", "item": "AFBF"}, {"code": "7", "disp": "OHDF", "item": "OHDF"}, {"code": "8", "disp": "OHF", "item": "OHF"}, {"code": "9", "disp": "特殊浄化", "item": "特殊浄化"}, {"code": "10", "disp": "I-HDF", "item": "I-HDF"}, {"code": "-", "disp": "不明", "item": "不明"}], "data_class": "透析条件", "field_name": "device_mode", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.00", "can_calc": "0", "data_code": "water_removal_amount_limit", "data_name": "除水量制限", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "water_removal_amount_limit", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト１次膜", "can_calc": "0", "data_code": "primary_film_name", "data_name": "1次膜", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "primary_film_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "primary_film_in_hospital_cd_1", "data_name": "1次膜連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "primary_film_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "primary_film_in_hospital_cd_2", "data_name": "1次膜連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "primary_film_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "primary_film_in_hospital_cd_3", "data_name": "1次膜連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "primary_film_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "primary_film_in_hospital_cd_4", "data_name": "1次膜連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "primary_film_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト２次膜", "can_calc": "0", "data_code": "secondary_film_name", "data_name": "2次膜", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "secondary_film_name", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "secondary_film_in_hospital_cd_1", "data_name": "2次膜連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "secondary_film_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "secondary_film_in_hospital_cd_2", "data_name": "2次膜連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "secondary_film_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "secondary_film_in_hospital_cd_3", "data_name": "2次膜連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "secondary_film_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "secondary_film_in_hospital_cd_4", "data_name": "2次膜連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "secondary_film_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リクセルS-15", "can_calc": "0", "data_code": "adsorption_column_name", "data_name": "吸着カラム", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "adsorption_column_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "adsorption_in_hospital_cd_1", "data_name": "吸着カラム連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "adsorption_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "adsorption_in_hospital_cd_2", "data_name": "吸着カラム連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "adsorption_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "adsorption_in_hospital_cd_3", "data_name": "吸着カラム連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "adsorption_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "adsorption_in_hospital_cd_4", "data_name": "吸着カラム連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "adsorption_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "Dドライ3.0S", "can_calc": "0", "data_code": "dialysate_name", "data_name": "透析液", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialysate_in_hospital_cd_1", "data_name": "透析液連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialysate_in_hospital_cd_2", "data_name": "透析液連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialysate_in_hospital_cd_3", "data_name": "透析液連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialysate_in_hospital_cd_4", "data_name": "透析液連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_dialysate_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/min", "can_calc": "0", "data_code": "dialysate_unit", "data_name": "透析液単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_flow_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "dialysate_flow_rate", "data_name": "透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_flow_rate", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "120.00", "can_calc": "0", "data_code": "dialysate_amount", "data_name": "透析液量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_amount", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.0", "can_calc": "1", "data_code": "dialysate_temperature", "data_name": "透析液温度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "dialysate_temperature", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト補液", "can_calc": "0", "data_code": "fluid_replacement_name", "data_name": "補液", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "fluid_in_hospital_cd_1", "data_name": "補液連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "fluid_in_hospital_cd_2", "data_name": "補液連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "fluid_in_hospital_cd_3", "data_name": "補液連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "fluid_in_hospital_cd_4", "data_name": "補液連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_fluid_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "L", "can_calc": "0", "data_code": "fluid_replacement_unit", "data_name": "補液単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "8.0", "can_calc": "1", "data_code": "fluid_replacement_amount", "data_name": "補液量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_amount", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.0", "can_calc": "0", "data_code": "fluid_replacement_speed", "data_name": "補液速度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_speed", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "前補液", "can_calc": "0", "data_code": "fluid_replacement_timing", "data_name": "補液選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "後補液", "item": "後補液"}, {"code": "1", "disp": "前補液", "item": "前補液"}], "data_class": "透析条件", "field_name": "fluid_replacement_timing", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "fluid_replacement_use_count", "data_name": "補液使用数", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_use_count", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.0", "can_calc": "0", "data_code": "fluid_replacement_temperature", "data_name": "補液温度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "fluid_replacement_temperature", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3000", "can_calc": "0", "data_code": "anti_coagulant_total_amount", "data_name": "抗凝固剤総量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_total_amount", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "anti_coagulant_name", "data_name": "抗凝固剤", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "anti_coagulant_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "anti_in_hospital_cd_1", "data_name": "抗凝固剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "anti_in_hospital_cd_2", "data_name": "抗凝固剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "anti_in_hospital_cd_3", "data_name": "抗凝固剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "anti_in_hospital_cd_4", "data_name": "抗凝固剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "rst_anti_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "する", "can_calc": "0", "data_code": "ip", "data_name": "IP使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "透析条件", "field_name": "ip", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "自動", "can_calc": "0", "data_code": "ip_start", "data_name": "IPスタート", "data_type": "string", "conv_table": [{"code": "0", "disp": "手動", "item": "手動"}, {"code": "1", "disp": "自動", "item": "自動"}], "data_class": "透析条件", "field_name": "ip_start", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.2", "can_calc": "0", "data_code": "ip_speed", "data_name": "IP速度", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/h", "can_calc": "0", "data_code": "ip_speed_unit", "data_name": "IP速度単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10.0", "can_calc": "0", "data_code": "ip_speed_max", "data_name": "HD+IP速度最大値", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed_max", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL/h", "can_calc": "0", "data_code": "ip_speed_max_unit", "data_name": "IP速度最大値単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "ip_speed_max_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "auto_one_shot", "data_name": "自動ワンショット", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "透析条件", "field_name": "auto_one_shot", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "ip_one_shot_amount", "data_name": "IPワンショット量", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_one_shot_amount", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "mL", "can_calc": "0", "data_code": "ip_one_shot_amount_unit", "data_name": "IPワンショット量単位", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "ip_one_shot_amount_unit", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切", "can_calc": "0", "data_code": "ip_auto_off", "data_name": "IP電源自動切り", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "透析条件", "field_name": "ip_auto_off", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "ip_auto_off_time", "data_name": "IP電源自動切り時間", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_auto_off_time", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "切", "can_calc": "0", "data_code": "ip_monitor_auto_off", "data_name": "IP電源OKモニタ切り", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "透析条件", "field_name": "ip_monitor_auto_off", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "ip_monitor_auto_off_time", "data_name": "IP電源OKモニタ切り時間", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "ip_monitor_auto_off_time", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "しない", "can_calc": "1", "data_code": "single_needle", "data_name": "シングルニードル使用", "data_type": "string", "conv_table": [{"code": "0", "disp": "しない", "item": "しない"}, {"code": "1", "disp": "する", "item": "する"}], "data_class": "透析条件", "field_name": "single_needle", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針A針", "can_calc": "0", "data_code": "puncture_needle_a_name", "data_name": "穿刺針A針名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "puncture_needle_a_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_a_in_hospital_cd_1", "data_name": "穿刺針A針連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_a_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_a_in_hospital_cd_2", "data_name": "穿刺針A針連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_a_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_a_in_hospital_cd_3", "data_name": "穿刺針A針連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_a_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_a_in_hospital_cd_4", "data_name": "穿刺針A針連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_a_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針V針", "can_calc": "0", "data_code": "puncture_needle_v_name", "data_name": "穿刺針V針名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "puncture_needle_v_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_v_in_hospital_cd_1", "data_name": "穿刺針V針連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_v_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_v_in_hospital_cd_2", "data_name": "穿刺針V針連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_v_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_v_in_hospital_cd_3", "data_name": "穿刺針V針連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_v_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_v_in_hospital_cd_4", "data_name": "穿刺針V針連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_v_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針S針", "can_calc": "0", "data_code": "puncture_needle_s_name", "data_name": "穿刺針S針名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "puncture_needle_sn_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_s_in_hospital_cd_1", "data_name": "穿刺針S針連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_s_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_s_in_hospital_cd_2", "data_name": "穿刺針S針連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_s_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_s_in_hospital_cd_3", "data_name": "穿刺針S針連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_s_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "pn_s_in_hospital_cd_4", "data_name": "穿刺針S針連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "pn_s_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "血液回路", "can_calc": "0", "data_code": "blood_circuit_name", "data_name": "血液回路名称", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "blood_circuit_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "bc_in_hospital_cd_1", "data_name": "血液回路連携コード１", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "bc_in_hospital_cd_1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "bc_in_hospital_cd_2", "data_name": "血液回路連携コード２", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "bc_in_hospital_cd_2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "bc_in_hospital_cd_3", "data_name": "血液回路連携コード３", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "bc_in_hospital_cd_3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "bc_in_hospital_cd_4", "data_name": "血液回路連携コード４", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "bc_in_hospital_cd_4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "スリッパ", "can_calc": "0", "data_code": "tare_name1", "data_name": "風袋名称１", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_name1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "tare_weight1", "data_name": "風袋重量１", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_weight1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "服", "can_calc": "0", "data_code": "tare_name2", "data_name": "風袋名称２", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_name2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "1", "data_code": "tare_weight2", "data_name": "風袋重量２", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_weight2", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "義足", "can_calc": "1", "data_code": "tare_name3", "data_name": "風袋名称３", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_name3", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1200", "can_calc": "0", "data_code": "tare_weight3", "data_name": "風袋重量３", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_weight3", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋１", "can_calc": "0", "data_code": "tare_name4", "data_name": "風袋名称４", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_name4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "tare_weight4", "data_name": "風袋重量４", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_weight4", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他風袋２", "can_calc": "0", "data_code": "tare_name5", "data_name": "風袋名称５", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_name5", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "tare_weight5", "data_name": "風袋重量５", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_weight5", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1800", "can_calc": "0", "data_code": "tare_weight_total", "data_name": "風袋重量合計", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "tare_weight_total", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "食事量", "can_calc": "0", "data_code": "off_water_name1", "data_name": "除水補正名称１", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name1", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "off_water_weight1", "data_name": "除水補正重量１", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight1", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "プライミング", "can_calc": "0", "data_code": "off_water_name2", "data_name": "除水補正名称２", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name2", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "0", "data_code": "off_water_weight2", "data_name": "除水補正重量２"		
, "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight2", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "輸液量", "can_calc": "0", "data_code": "off_water_name3", "data_name": "除水補正名称３", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name3", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "off_water_weight3", "data_name": "除水補正重量３", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight3", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他（不感蒸泄）", "can_calc": "0", "data_code": "off_water_name4", "data_name": "除水補正名称４", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name4", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "off_water_weight4", "data_name": "除水補正重量４", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight4", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "その他", "can_calc": "0", "data_code": "off_water_name5", "data_name": "除水補正名称５", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_name5", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "off_water_weight5", "data_name": "除水補正重量５", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight5", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "900", "can_calc": "0", "data_code": "off_water_weight_total", "data_name": "除水補正重量合計", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "off_water_weight_total", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.00", "can_calc": "0", "data_code": "pre_scale_upper", "data_name": "前体重許容割合（上限）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "pre_scale_upper", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.00", "can_calc": "0", "data_code": "pre_scale_lower", "data_name": "前体重許容割合（下限）", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "pre_scale_lower", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "車椅子１", "can_calc": "0", "data_code": "wheel_chair_name", "data_name": "HD/ECUMTMP自動設定警報幅下限", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "wheel_chair_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "車椅子１", "can_calc": "0", "data_code": "wheel_chair_name", "data_name": "車椅子名称", "data_type": "string", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "wheel_chair_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15000", "can_calc": "0", "data_code": "wheel_chair_weight", "data_name": "車椅子重量", "data_type": "decimal", "conv_table": [], "data_class": "風袋・除水補正", "field_name": "wheel_chair_weight", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ベッド001", "can_calc": "0", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "bed_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左", "can_calc": "0", "data_code": "shunt_position", "data_name": "シャント位置", "data_type": "string", "conv_table": [{"code": "0", "disp": "両方", "item": "両方"}, {"code": "1", "disp": "左", "item": "左"}, {"code": "2", "disp": "右", "item": "右"}, {"code": "3", "disp": "なし", "item": "なし"}, {"code": "-", "disp": "不明", "item": "不明"}], "data_class": "ベッド情報", "field_name": "shunt_position", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "感染症あり", "can_calc": "0", "data_code": "is_infection", "data_name": "感染症対応", "data_type": "string", "conv_table": [{"code": "0", "disp": "感染症なし", "item": "感染症なし"}, {"code": "1", "disp": "感染症あり", "item": "感染症あり"}], "data_class": "ベッド情報", "field_name": "is_infection", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "通常ベッド", "can_calc": "0", "data_code": "emergency_class", "data_name": "緊急区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "通常ベッド", "item": "通常ベッド"}, {"code": "1", "disp": "緊急ベッド", "item": "緊急ベッド"}], "data_class": "ベッド情報", "field_name": "emergency_class", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "Aグループ", "can_calc": "0", "data_code": "room_bed_group_name_list", "data_name": "透析室・ベッドグループ名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "room_bed_group_name_list", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "装置001", "can_calc": "0", "data_code": "machine_name", "data_name": "装置名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "machine_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装", "can_calc": "0", "data_code": "maker", "data_name": "メーカー", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "maker", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "function_class", "data_name": "機能分類", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "function_class", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.2", "can_calc": "0", "data_code": "area", "data_name": "面積", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "area", "disp_format": "0.0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "45.00", "can_calc": "0", "data_code": "ufr", "data_name": "UFR", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "ufr", "disp_format": "0.00", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "600", "can_calc": "0", "data_code": "koa", "data_name": "KOA", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "koa", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "親水化PEPA", "can_calc": "0", "data_code": "material", "data_name": "材質", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "material", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "WET", "can_calc": "0", "data_code": "wetdry", "data_name": "WET/DRY", "data_type": "string", "conv_table": [{"code": "0", "disp": "不明", "item": "不明"}, {"code": "1", "disp": "WET", "item": "WET"}, {"code": "2", "disp": "DRY", "item": "DRY"}], "data_class": "ダイアライザ情報", "field_name": "wetdry", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "γ線", "can_calc": "0", "data_code": "sterilization", "data_name": "滅菌", "data_type": "string", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "sterilization", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "0", "data_code": "bloodamt", "data_name": "血流量", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "bloodamt", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "alqd_flood_vol", "data_name": "透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "alqd_flood_vol", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "190", "can_calc": "0", "data_code": "urea_clearance", "data_name": "尿素クリアランス", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "urea_clearance", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5", "can_calc": "0", "data_code": "gas_purge_time", "data_name": "ガスパージ時間", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "gas_purge_time", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1000", "can_calc": "0", "data_code": "substituent_wash_amt", "data_name": "置換洗浄量（透析液）", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "substituent_wash_amt", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用しない", "can_calc": "0", "data_code": "membrane_wash", "data_name": "膜洗浄（中空糸）", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "ダイアライザ情報", "field_name": "membrane_wash", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialyzer_in_hospital_cd_1", "data_name": "ダイアライザ連携コード１", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "dialyzer_in_hospital_cd_1", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialyzer_in_hospital_cd_2", "data_name": "ダイアライザ連携コード２", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "dialyzer_in_hospital_cd_2", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialyzer_in_hospital_cd_3", "data_name": "ダイアライザ連携コード３", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "dialyzer_in_hospital_cd_3", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "dialyzer_in_hospital_cd_4", "data_name": "ダイアライザ連携コード４", "data_type": "decimal", "conv_table": [], "data_class": "ダイアライザ情報", "field_name": "dialyzer_in_hospital_cd_4", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd1", "data_name": "治療方法連携コード1", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd1", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd2", "data_name": "治療方法連携コード2", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd2", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd3", "data_name": "治療方法連携コード3", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd3", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "treatment_in_hospital_cd4", "data_name": "治療方法連携コード4", "data_type": "decimal", "conv_table": [], "data_class": "透析条件", "field_name": "treatment_in_hospital_cd4", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "bed_in_hospital_cd_1", "data_name": "ベッド携コード1", "data_type": "decimal", "conv_table": [], "data_class": "ベッド情報", "field_name": "bed_in_hospital_cd_1", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "bed_in_hospital_cd_2", "data_name": "ベッド携コード2", "data_type": "decimal", "conv_table": [], "data_class": "ベッド情報", "field_name": "bed_in_hospital_cd_2", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '指示：透析条件/ベッド情報/ダイアライザ情報　@ordNo使用', '2020-03-26 17:10:00', CURRENT_TIMESTAMP, NULL);		
		

DELETE FROM "ntss"."sys_data_set" where sql_cd in (84);

INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (84, 'with input_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,input_param
  from
    pat_event
    cross join lateral jsonb_array_elements(input_params) with ordinality as tmp(input_param, json_idx)
  where
    is_del = ''0''
    and input_params != ''null''
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
)
, result_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,result_param
  from
    pat_event
    cross join lateral jsonb_array_elements(result_params) with ordinality as tmp(result_param, json_idx)
  where
    is_del = ''0''
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
)
, pe_basicinfo as
(
  select
    pat_event_cd
    ,event_start_date
    ,event_end_date
    ,event_start_time
    ,event_end_time
    ,category_name
    ,sub_category_cd
    ,sub_category_name
    ,reg_staff_info->>''reg_staff_name'' as reg_staff_name
    ,reg_date
    ,up_staff_info->>''up_staff_name'' as up_staff_name
    ,up_date
  from
    pat_event
  where
    is_del = ''0''
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
)
, pe_picked as
(
  select
    ipe.pat_event_cd
    ,ipe.json_idx
    ,input_param
    ,result_param
  from
    input_params_expand as ipe
    inner join result_params_expand as rpe
      on ipe.pat_event_cd = rpe.pat_event_cd and ipe.json_idx = rpe.json_idx
  where
    input_param->>''format_class'' = ''0'' 
)
, pe_array_agg as
(
  select
    pat_event_cd
    ,array_agg(input_param order by json_idx) as picked_input_params
    ,array_agg(result_param order by json_idx) as picked_result_params
  from
    pe_picked
  group by pat_event_cd
)

select
  pe_array_agg.pat_event_cd
  ,to_timestamp(event_start_date||
    case when event_start_time is null then ''0000''
         else event_start_time
    end, ''yyyyMMDDHH24mi'') AS event_start_date
  ,to_timestamp(event_end_date||
    case when event_end_time is null then ''0000''
         else event_end_time
    end, ''yyyyMMDDHH24mi'') AS event_end_date
  ,pe_basicinfo.category_name
  ,pe_basicinfo.sub_category_cd
  ,pe_basicinfo.sub_category_name
  ,pe_basicinfo.reg_staff_name
  ,pe_basicinfo.reg_date
  ,pe_basicinfo.up_staff_name
  ,pe_basicinfo.up_date
  ,picked_input_params[1]->>''field_name'' as data1_field_name
  ,picked_input_params[2]->>''field_name'' as data2_field_name
  ,picked_input_params[3]->>''field_name'' as data3_field_name
  ,picked_input_params[4]->>''field_name'' as data4_field_name
  ,picked_input_params[5]->>''field_name'' as data5_field_name
  ,picked_input_params[6]->>''field_name'' as data6_field_name
  ,picked_input_params[7]->>''field_name'' as data7_field_name
  ,picked_input_params[8]->>''field_name'' as data8_field_name
  ,picked_input_params[9]->>''field_name'' as data9_field_name
  ,picked_input_params[10]->>''field_name'' as data10_field_name
  ,picked_input_params[11]->>''field_name'' as data11_field_name
  ,picked_input_params[12]->>''field_name'' as data12_field_name
  ,picked_input_params[13]->>''field_name'' as data13_field_name
  ,picked_input_params[14]->>''field_name'' as data14_field_name
  ,picked_input_params[15]->>''field_name'' as data15_field_name
  ,picked_input_params[16]->>''field_name'' as data16_field_name
  ,picked_input_params[17]->>''field_name'' as data17_field_name
  ,picked_input_params[18]->>''field_name'' as data18_field_name
  ,picked_input_params[19]->>''field_name'' as data19_field_name
  ,picked_input_params[20]->>''field_name'' as data20_field_name
  ,picked_input_params[21]->>''field_name'' as data21_field_name
  ,picked_input_params[22]->>''field_name'' as data22_field_name
  ,picked_input_params[23]->>''field_name'' as data23_field_name
  ,picked_input_params[24]->>''field_name'' as data24_field_name
  ,picked_input_params[25]->>''field_name'' as data25_field_name
  ,picked_input_params[26]->>''field_name'' as data26_field_name
  ,picked_input_params[27]->>''field_name'' as data27_field_name
  ,picked_input_params[28]->>''field_name'' as data28_field_name
  ,picked_input_params[29]->>''field_name'' as data29_field_name
  ,picked_input_params[30]->>''field_name'' as data30_field_name
  ,case when picked_result_params[1]->>''result_value'' is null or picked_result_params[1]->>''result_value'' = '''' then picked_input_params[1]->''item_json''->>''default_value''
        else picked_result_params[1]->>''result_value''
   end as data1
  ,case when picked_result_params[2]->>''result_value'' is null or picked_result_params[2]->>''result_value'' = '''' then picked_input_params[2]->''item_json''->>''default_value''
        else picked_result_params[2]->>''result_value''
   end as data2
  ,case when picked_result_params[3]->>''result_value'' is null or picked_result_params[3]->>''result_value'' = '''' then picked_input_params[3]->''item_json''->>''default_value''
        else picked_result_params[3]->>''result_value''
   end as data3
  ,case when picked_result_params[4]->>''result_value'' is null or picked_result_params[4]->>''result_value'' = '''' then picked_input_params[4]->''item_json''->>''default_value''
        else picked_result_params[4]->>''result_value''
   end as data4
  ,case when picked_result_params[5]->>''result_value'' is null or picked_result_params[5]->>''result_value'' = '''' then picked_input_params[5]->''item_json''->>''default_value''
        else picked_result_params[5]->>''result_value''
   end as data5
  ,case when picked_result_params[6]->>''result_value'' is null or picked_result_params[6]->>''result_value'' = '''' then picked_input_params[6]->''item_json''->>''default_value''
        else picked_result_params[6]->>''result_value''
   end as data6
  ,case when picked_result_params[7]->>''result_value'' is null or picked_result_params[7]->>''result_value'' = '''' then picked_input_params[7]->''item_json''->>''default_value''
        else picked_result_params[7]->>''result_value''
   end as data7
  ,case when picked_result_params[8]->>''result_value'' is null or picked_result_params[8]->>''result_value'' = '''' then picked_input_params[8]->''item_json''->>''default_value''
        else picked_result_params[8]->>''result_value''
   end as data8
  ,case when picked_result_params[9]->>''result_value'' is null or picked_result_params[9]->>''result_value'' = '''' then picked_input_params[9]->''item_json''->>''default_value''
        else picked_result_params[9]->>''result_value''
   end as data9
  ,case when picked_result_params[10]->>''result_value'' is null or picked_result_params[10]->>''result_value'' = '''' then picked_input_params[10]->''item_json''->>''default_value''
        else picked_result_params[10]->>''result_value''
   end as data10
  ,case when picked_result_params[11]->>''result_value'' is null or picked_result_params[11]->>''result_value'' = '''' then picked_input_params[11]->''item_json''->>''default_value''
        else picked_result_params[11]->>''result_value''
   end as data11
  ,case when picked_result_params[12]->>''result_value'' is null or picked_result_params[12]->>''result_value'' = '''' then picked_input_params[12]->''item_json''->>''default_value''
        else picked_result_params[12]->>''result_value''
   end as data12
  ,case when picked_result_params[13]->>''result_value'' is null or picked_result_params[13]->>''result_value'' = '''' then picked_input_params[13]->''item_json''->>''default_value''
        else picked_result_params[13]->>''result_value''
   end as data13
  ,case when picked_result_params[14]->>''result_value'' is null or picked_result_params[14]->>''result_value'' = '''' then picked_input_params[14]->''item_json''->>''default_value''
        else picked_result_params[14]->>''result_value''
   end as data14
  ,case when picked_result_params[15]->>''result_value'' is null or picked_result_params[15]->>''result_value'' = '''' then picked_input_params[15]->''item_json''->>''default_value''
        else picked_result_params[15]->>''result_value''
   end as data15
  ,case when picked_result_params[16]->>''result_value'' is null or picked_result_params[16]->>''result_value'' = '''' then picked_input_params[16]->''item_json''->>''default_value''
        else picked_result_params[16]->>''result_value''
   end as data16
  ,case when picked_result_params[17]->>''result_value'' is null or picked_result_params[17]->>''result_value'' = '''' then picked_input_params[17]->''item_json''->>''default_value''
        else picked_result_params[17]->>''result_value''
   end as data17
  ,case when picked_result_params[18]->>''result_value'' is null or picked_result_params[18]->>''result_value'' = '''' then picked_input_params[18]->''item_json''->>''default_value''
        else picked_result_params[18]->>''result_value''
   end as data18
  ,case when picked_result_params[19]->>''result_value'' is null or picked_result_params[19]->>''result_value'' = '''' then picked_input_params[19]->''item_json''->>''default_value''
        else picked_result_params[19]->>''result_value''
   end as data19
  ,case when picked_result_params[20]->>''result_value'' is null or picked_result_params[20]->>''result_value'' = '''' then picked_input_params[20]->''item_json''->>''default_value''
        else picked_result_params[20]->>''result_value''
   end as data20
  ,case when picked_result_params[21]->>''result_value'' is null or picked_result_params[21]->>''result_value'' = '''' then picked_input_params[21]->''item_json''->>''default_value''
        else picked_result_params[21]->>''result_value''
   end as data21
  ,case when picked_result_params[22]->>''result_value'' is null or picked_result_params[22]->>''result_value'' = '''' then picked_input_params[22]->''item_json''->>''default_value''
        else picked_result_params[22]->>''result_value''
   end as data22
  ,case when picked_result_params[23]->>''result_value'' is null or picked_result_params[23]->>''result_value'' = '''' then picked_input_params[23]->''item_json''->>''default_value''
        else picked_result_params[23]->>''result_value''
   end as data23
  ,case when picked_result_params[24]->>''result_value'' is null or picked_result_params[24]->>''result_value'' = '''' then picked_input_params[24]->''item_json''->>''default_value''
        else picked_result_params[24]->>''result_value''
   end as data24
  ,case when picked_result_params[25]->>''result_value'' is null or picked_result_params[25]->>''result_value'' = '''' then picked_input_params[25]->''item_json''->>''default_value''
        else picked_result_params[25]->>''result_value''
   end as data25
  ,case when picked_result_params[26]->>''result_value'' is null or picked_result_params[26]->>''result_value'' = '''' then picked_input_params[26]->''item_json''->>''default_value''
        else picked_result_params[26]->>''result_value''
   end as data26
  ,case when picked_result_params[27]->>''result_value'' is null or picked_result_params[27]->>''result_value'' = '''' then picked_input_params[27]->''item_json''->>''default_value''
        else picked_result_params[27]->>''result_value''
   end as data27
  ,case when picked_result_params[28]->>''result_value'' is null or picked_result_params[28]->>''result_value'' = '''' then picked_input_params[28]->''item_json''->>''default_value''
        else picked_result_params[28]->>''result_value''
   end as data28
  ,case when picked_result_params[29]->>''result_value'' is null or picked_result_params[29]->>''result_value'' = '''' then picked_input_params[29]->''item_json''->>''default_value''
        else picked_result_params[29]->>''result_value''
   end as data29
  ,case when picked_result_params[30]->>''result_value'' is null or picked_result_params[30]->>''result_value'' = '''' then picked_input_params[30]->''item_json''->>''default_value''
        else picked_result_params[30]->>''result_value''
   end as data30
from
  pe_array_agg 
  inner join pe_basicinfo on pe_array_agg.pat_event_cd = pe_basicinfo.pat_event_cd
ORDER BY event_start_date, reg_date
;', 2, '[{"preview": "2020/03/26", "can_calc": "0", "data_code": "event_start_date", "data_name": "イベント開始日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "event_start_date", "disp_format": "yyyy/mm/dd", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "event_end_date", "data_name": "イベント終了日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "event_end_date", "disp_format": "yyyy/mm/dd", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "起票者", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "reg_staff_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/25", "can_calc": "0", "data_code": "reg_date", "data_name": "起票日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "reg_date", "disp_format": "yyyy/mm/dd", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師２", "can_calc": "0", "data_code": "up_staff_name", "data_name": "最終編集者", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "up_staff_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "up_date", "data_name": "最終編集日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "up_date", "disp_format": "yyyy/mm/dd", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data1_field_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data2_field_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data3_field_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data4_field_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data5_field_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data6_field_name", "data_name": "データ6 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data6_field_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data7_field_name", "data_name": "データ7 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data7_field_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data8_field_name", "data_name": "データ8 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data8_field_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data9_field_name", "data_name": "データ9 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data9_field_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data10_field_name", "data_name": "データ10 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data10_field_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data11_field_name", "data_name": "データ11 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data11_field_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data12_field_name", "data_name": "データ12 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data12_field_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data13_field_name", "data_name": "データ13 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data13_field_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data14_field_name", "data_name": "データ14 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data14_field_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data15_field_name", "data_name": "データ15 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data15_field_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data16_field_name", "data_name": "データ16 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data16_field_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data17_field_name", "data_name": "データ17 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data17_field_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data18_field_name", "data_name": "データ18 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data18_field_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data19_field_name", "data_name": "データ19 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data19_field_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data20_field_name", "data_name": "データ20 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data20_field_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data21_field_name", "data_name": "データ21 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data21_field_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data22_field_name", "data_name": "データ22 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data22_field_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data23_field_name", "data_name": "データ23 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data23_field_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data24_field_name", "data_name": "データ24 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data24_field_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data25_field_name", "data_name": "データ25 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data25_field_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data26_field_name", "data_name": "データ26 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data26_field_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data27_field_name", "data_name": "データ27 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data27_field_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data28_field_name", "data_name": "データ28 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data28_field_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data29_field_name", "data_name": "データ29 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data29_field_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "S", "can_calc": "0", "data_code": "data30_field_name", "data_name": "データ30 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data30_field_name", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data1", "data_name": "データ1", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data1", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data2", "data_name": "データ2", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data2", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data3", "data_name": "データ3", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data3", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data4", "data_name": "データ4", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data4", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data5", "data_name": "データ5", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data5", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data6", "data_name": "データ6", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data6", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data7", "data_name": "データ7", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data7", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data8", "data_name": "データ8", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data8", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data9", "data_name": "データ9", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data9", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data10", "data_name": "データ10", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data10", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data11", "data_name": "データ11", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data11", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data12", "data_name": "データ12", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data12", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data13", "data_name": "データ13", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data13", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data14", "data_name": "データ14", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data14", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data15", "data_name": "データ15", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data15", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data16", "data_name": "データ16", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data16", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data17", "data_name": "データ17", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data17", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data18", "data_name": "データ18", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data18", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data19", "data_name": "データ19", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data19", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data20", "data_name": "データ20", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data20", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data21", "data_name": "データ21", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data21", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data22", "data_name": "データ22", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data22", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data23", "data_name": "データ23", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data23", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data24", "data_name": "データ24", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data24", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data25", "data_name": "データ25", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data25", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data26", "data_name": "データ26", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data26", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data27", "data_name": "データ27", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data27", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data28", "data_name": "データ28", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data28", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data29", "data_name": "データ29", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data29", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data30", "data_name": "データ30", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキスト)", "field_name": "data30", "disp_format": "", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '患者情報：患者イベント テキスト　@patId @fromDate @toDate使用', '2021-08-26 13:50:14',CURRENT_TIMESTAMP, NULL);



DELETE FROM "ntss"."sys_data_set" where sql_cd in (85);

INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (85, 'with input_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,input_param
  from
    pat_event
    cross join lateral jsonb_array_elements(input_params) with ordinality as tmp(input_param, json_idx)
  where
    is_del = ''0''
    and input_params != ''null''
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
)
, result_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,result_param
  from
    pat_event
    cross join lateral jsonb_array_elements(result_params) with ordinality as tmp(result_param, json_idx)
  where
    is_del = ''0''
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
)
, pe_basicinfo as
(
  select
    pat_event_cd
    ,event_start_date
    ,event_end_date
    ,event_start_time
    ,event_end_time
    ,category_name
    ,sub_category_cd
    ,sub_category_name
    ,reg_staff_info->>''reg_staff_name'' as reg_staff_name
    ,reg_date
    ,up_staff_info->>''up_staff_name'' as up_staff_name
    ,up_date
  from
    pat_event
  where
    is_del = ''0''
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
)
, pe_picked as
(
  select
    ipe.pat_event_cd
    ,ipe.json_idx
    ,input_param
    ,result_param
  from
    input_params_expand as ipe
    inner join result_params_expand as rpe
      on ipe.pat_event_cd = rpe.pat_event_cd and ipe.json_idx = rpe.json_idx
  where
    input_param->>''format_class'' = ''1''
)
, pe_array_agg as
(
  select
    pat_event_cd
    ,array_agg(input_param order by json_idx) as picked_input_params
    ,array_agg(result_param order by json_idx) as picked_result_params
  from
    pe_picked
  group by pat_event_cd
)

select
  pe_array_agg.pat_event_cd
  ,to_timestamp(event_start_date||
    case when event_start_time is null then ''0000''
         else event_start_time
    end, ''yyyyMMDDHH24mi'') AS event_start_date
  ,to_timestamp(event_end_date||
    case when event_end_time is null then ''0000''
         else event_end_time
    end, ''yyyyMMDDHH24mi'') AS event_end_date
  ,category_name
  ,pe_basicinfo.sub_category_cd
  ,pe_basicinfo.sub_category_name
  ,reg_staff_name
  ,pe_basicinfo.reg_date
  ,up_staff_name
  ,pe_basicinfo.up_date
  ,picked_input_params[1]->>''field_name'' as data1_field_name
  ,picked_input_params[2]->>''field_name'' as data2_field_name
  ,picked_input_params[3]->>''field_name'' as data3_field_name
  ,picked_input_params[4]->>''field_name'' as data4_field_name
  ,picked_input_params[5]->>''field_name'' as data5_field_name
  ,picked_input_params[6]->>''field_name'' as data6_field_name
  ,picked_input_params[7]->>''field_name'' as data7_field_name
  ,picked_input_params[8]->>''field_name'' as data8_field_name
  ,picked_input_params[9]->>''field_name'' as data9_field_name
  ,picked_input_params[10]->>''field_name'' as data10_field_name
  ,case when picked_result_params[1]->>''result_value'' is null or picked_result_params[1]->>''result_value'' = '''' then picked_input_params[1]->''item_json''->>''default_value''
        else picked_result_params[1]->>''result_value''
   end as data1
  ,case when picked_result_params[2]->>''result_value'' is null or picked_result_params[2]->>''result_value'' = '''' then picked_input_params[2]->''item_json''->>''default_value''
        else picked_result_params[2]->>''result_value''
   end as data2
  ,case when picked_result_params[3]->>''result_value'' is null or picked_result_params[3]->>''result_value'' = '''' then picked_input_params[3]->''item_json''->>''default_value''
        else picked_result_params[3]->>''result_value''
   end as data3
  ,case when picked_result_params[4]->>''result_value'' is null or picked_result_params[4]->>''result_value'' = '''' then picked_input_params[4]->''item_json''->>''default_value''
        else picked_result_params[4]->>''result_value''
   end as data4
  ,case when picked_result_params[5]->>''result_value'' is null or picked_result_params[5]->>''result_value'' = '''' then picked_input_params[5]->''item_json''->>''default_value''
        else picked_result_params[5]->>''result_value''
   end as data5
  ,case when picked_result_params[6]->>''result_value'' is null or picked_result_params[6]->>''result_value'' = '''' then picked_input_params[6]->''item_json''->>''default_value''
        else picked_result_params[6]->>''result_value''
   end as data6
  ,case when picked_result_params[7]->>''result_value'' is null or picked_result_params[7]->>''result_value'' = '''' then picked_input_params[7]->''item_json''->>''default_value''
        else picked_result_params[7]->>''result_value''
   end as data7
  ,case when picked_result_params[8]->>''result_value'' is null or picked_result_params[8]->>''result_value'' = '''' then picked_input_params[8]->''item_json''->>''default_value''
        else picked_result_params[8]->>''result_value''
   end as data8
  ,case when picked_result_params[9]->>''result_value'' is null or picked_result_params[9]->>''result_value'' = '''' then picked_input_params[9]->''item_json''->>''default_value''
        else picked_result_params[9]->>''result_value''
   end as data9
  ,case when picked_result_params[10]->>''result_value'' is null or picked_result_params[10]->>''result_value'' = '''' then picked_input_params[10]->''item_json''->>''default_value''
        else picked_result_params[10]->>''result_value''
   end as data10
from
  pe_array_agg
  inner join pe_basicinfo on pe_array_agg.pat_event_cd = pe_basicinfo.pat_event_cd
ORDER BY event_start_date, reg_date
;', 2, '[{"preview": "2020/03/26", "can_calc": "0", "data_code": "event_start_date", "data_name": "イベント開始日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "event_start_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "event_end_date", "data_name": "イベント終了日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "event_end_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "起票者", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "reg_staff_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/25", "can_calc": "0", "data_code": "reg_date", "data_name": "起票日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "reg_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師２", "can_calc": "0", "data_code": "up_staff_name", "data_name": "最終編集者", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "up_staff_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "up_date", "data_name": "最終編集日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "up_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data1_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data2_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data3_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data4_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data5_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "data6_field_name", "data_name": "データ6フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data6_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "data7_field_name", "data_name": "データ7フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data7_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "data8_field_name", "data_name": "データ8フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data8_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "data9_field_name", "data_name": "データ9フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data9_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "data10_field_name", "data_name": "データ10フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data10_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data1", "data_name": "データ1", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data1", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data2", "data_name": "データ2", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data2", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data3", "data_name": "データ3", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data3", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data4", "data_name": "データ4", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data4", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data5", "data_name": "データ5", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data5", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data6", "data_name": "データ6", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data6", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data7", "data_name": "データ7", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data7", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data8", "data_name": "データ8", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data8", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data9", "data_name": "データ9", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data9", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "コメントです。", "can_calc": "0", "data_code": "data10", "data_name": "データ10", "data_type": "string", "conv_table": [], "data_class": "患者イベント(テキストエリア)", "field_name": "data10", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '患者情報：患者イベント テキストエリア　@patId @fromDate @toDate使用', '2021-08-26 13:50:14', '2023-07-17 21:02:04.069', NULL);


DELETE FROM "ntss"."sys_data_set" where sql_cd in (86);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (86, 'with input_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,input_param
  from
    pat_event
    cross join lateral jsonb_array_elements(input_params) with ordinality as tmp(input_param, json_idx)
  where
    is_del = ''0''
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @imageDateFrom ::timestamp ) and date_trunc(''day'', @imageDateTo ::timestamp) + ''1 days - 1 milliseconds''
)
, result_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,result_param
  from
    pat_event
    cross join lateral jsonb_array_elements(result_params) with ordinality as tmp(result_param, json_idx)
  where
    is_del = ''0''
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @imageDateFrom ::timestamp ) and date_trunc(''day'', @imageDateTo ::timestamp) + ''1 days - 1 milliseconds''
)
, pe_basicinfo as
(
  select
    pat_event_cd
    ,event_start_date
    ,event_end_date
    ,event_start_time
    ,event_end_time
    ,category_name
    ,sub_category_cd
    ,sub_category_name
    ,reg_staff_info->>''reg_staff_name'' as reg_staff_name
    ,reg_date
    ,up_staff_info->>''up_staff_name'' as up_staff_name
    ,up_date
  from
    pat_event
  where
    is_del = ''0''
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @imageDateFrom ::timestamp ) and date_trunc(''day'', @imageDateTo ::timestamp) + ''1 days - 1 milliseconds''
)
, pe_picked as
(
  select
    ipe.pat_event_cd
    ,ipe.json_idx
    ,input_param
    ,result_param
  from
    input_params_expand as ipe
    inner join result_params_expand as rpe
      on ipe.pat_event_cd = rpe.pat_event_cd and ipe.json_idx = rpe.json_idx
  where
    input_param->>''format_class'' = ''2''
)
, pe_array_agg as
(
  select
    pat_event_cd
    ,array_agg(input_param order by json_idx) as picked_input_params
    ,array_agg(result_param order by json_idx) as picked_result_params
  from
    pe_picked
  group by pat_event_cd
)

select
  pe_array_agg.pat_event_cd
  ,to_timestamp(event_start_date||
    case when event_start_time is null then ''0000''
         else event_start_time
    end, ''yyyyMMDDHH24mi'') AS event_start_date
  ,to_timestamp(event_end_date||
    case when event_end_time is null then ''0000''
         else event_end_time
    end, ''yyyyMMDDHH24mi'') AS event_end_date
  ,category_name
  ,sub_category_cd
  ,sub_category_name
  ,reg_staff_name
  ,reg_date
  ,up_staff_name
  ,up_date
  
  ,picked_input_params[1]->>''field_name'' as data1_field_name
  ,picked_input_params[2]->>''field_name'' as data2_field_name
  ,picked_input_params[3]->>''field_name'' as data3_field_name
  ,picked_input_params[4]->>''field_name'' as data4_field_name
  ,picked_input_params[5]->>''field_name'' as data5_field_name
  ,picked_input_params[6]->>''field_name'' as data6_field_name
  ,picked_input_params[7]->>''field_name'' as data7_field_name
  ,picked_input_params[8]->>''field_name'' as data8_field_name
  ,picked_input_params[9]->>''field_name'' as data9_field_name
  ,picked_input_params[10]->>''field_name'' as data10_field_name
  
  ,(picked_input_params[1]->''item_json''->''values''->0)->>''name'' as data1_pic1_name
  ,(picked_result_params[1]->''result_value''->0)->>''file_name'' as data1_pic1_file_name
  ,(picked_result_params[1]->''result_value''->0)->>''file_path'' as data1_pic1_file_path
  ,(picked_input_params[1]->''item_json''->''values''->1)->>''name'' as data1_pic2_name
  ,(picked_result_params[1]->''result_value''->1)->>''file_name'' as data1_pic2_file_name
  ,(picked_result_params[1]->''result_value''->1)->>''file_path'' as data1_pic2_file_path
  ,(picked_input_params[1]->''item_json''->''values''->2)->>''name'' as data1_pic3_name
  ,(picked_result_params[1]->''result_value''->2)->>''file_name'' as data1_pic3_file_name
  ,(picked_result_params[1]->''result_value''->2)->>''file_path'' as data1_pic3_file_path
  ,(picked_input_params[1]->''item_json''->''values''->3)->>''name'' as data1_pic4_name
  ,(picked_result_params[1]->''result_value''->3)->>''file_name'' as data1_pic4_file_name
  ,(picked_result_params[1]->''result_value''->3)->>''file_path'' as data1_pic4_file_path
  ,(picked_input_params[1]->''item_json''->''values''->4)->>''name'' as data1_pic5_name
  ,(picked_result_params[1]->''result_value''->4)->>''file_name'' as data1_pic5_file_name
  ,(picked_result_params[1]->''result_value''->4)->>''file_path'' as data1_pic5_file_path
  ,(picked_input_params[1]->''item_json''->''values''->5)->>''name'' as data1_pic6_name
  ,(picked_result_params[1]->''result_value''->5)->>''file_name'' as data1_pic6_file_name
  ,(picked_result_params[1]->''result_value''->5)->>''file_path'' as data1_pic6_file_path
  ,(picked_input_params[1]->''item_json''->''values''->6)->>''name'' as data1_pic7_name
  ,(picked_result_params[1]->''result_value''->6)->>''file_name'' as data1_pic7_file_name
  ,(picked_result_params[1]->''result_value''->6)->>''file_path'' as data1_pic7_file_path
  ,(picked_input_params[1]->''item_json''->''values''->7)->>''name'' as data1_pic8_name
  ,(picked_result_params[1]->''result_value''->7)->>''file_name'' as data1_pic8_file_name
  ,(picked_result_params[1]->''result_value''->7)->>''file_path'' as data1_pic8_file_path
  ,(picked_input_params[1]->''item_json''->''values''->8)->>''name'' as data1_pic9_name
  ,(picked_result_params[1]->''result_value''->8)->>''file_name'' as data1_pic9_file_name
  ,(picked_result_params[1]->''result_value''->8)->>''file_path'' as data1_pic9_file_path
  
  ,(picked_input_params[2]->''item_json''->''values''->0)->>''name'' as data2_pic1_name
  ,(picked_result_params[2]->''result_value''->0)->>''file_name'' as data2_pic1_file_name
  ,(picked_result_params[2]->''result_value''->0)->>''file_path'' as data2_pic1_file_path
  ,(picked_input_params[2]->''item_json''->''values''->1)->>''name'' as data2_pic2_name
  ,(picked_result_params[2]->''result_value''->1)->>''file_name'' as data2_pic2_file_name
  ,(picked_result_params[2]->''result_value''->1)->>''file_path'' as data2_pic2_file_path
  ,(picked_input_params[2]->''item_json''->''values''->2)->>''name'' as data2_pic3_name
  ,(picked_result_params[2]->''result_value''->2)->>''file_name'' as data2_pic3_file_name
  ,(picked_result_params[2]->''result_value''->2)->>''file_path'' as data2_pic3_file_path
  ,(picked_input_params[2]->''item_json''->''values''->3)->>''name'' as data2_pic4_name
  ,(picked_result_params[2]->''result_value''->3)->>''file_name'' as data2_pic4_file_name
  ,(picked_result_params[2]->''result_value''->3)->>''file_path'' as data2_pic4_file_path
  ,(picked_input_params[2]->''item_json''->''values''->4)->>''name'' as data2_pic5_name
  ,(picked_result_params[2]->''result_value''->4)->>''file_name'' as data2_pic5_file_name
  ,(picked_result_params[2]->''result_value''->4)->>''file_path'' as data2_pic5_file_path
  ,(picked_input_params[2]->''item_json''->''values''->5)->>''name'' as data2_pic6_name
  ,(picked_result_params[2]->''result_value''->5)->>''file_name'' as data2_pic6_file_name
  ,(picked_result_params[2]->''result_value''->5)->>''file_path'' as data2_pic6_file_path
  ,(picked_input_params[2]->''item_json''->''values''->6)->>''name'' as data2_pic7_name
  ,(picked_result_params[2]->''result_value''->6)->>''file_name'' as data2_pic7_file_name
  ,(picked_result_params[2]->''result_value''->6)->>''file_path'' as data2_pic7_file_path
  ,(picked_input_params[2]->''item_json''->''values''->7)->>''name'' as data2_pic8_name
  ,(picked_result_params[2]->''result_value''->7)->>''file_name'' as data2_pic8_file_name
  ,(picked_result_params[2]->''result_value''->7)->>''file_path'' as data2_pic8_file_path
  ,(picked_input_params[2]->''item_json''->''values''->8)->>''name'' as data2_pic9_name
  ,(picked_result_params[2]->''result_value''->8)->>''file_name'' as data2_pic9_file_name
  ,(picked_result_params[2]->''result_value''->8)->>''file_path'' as data2_pic9_file_path
  
  ,(picked_input_params[3]->''item_json''->''values''->0)->>''name'' as data3_pic1_name
  ,(picked_result_params[3]->''result_value''->0)->>''file_name'' as data3_pic1_file_name
  ,(picked_result_params[3]->''result_value''->0)->>''file_path'' as data3_pic1_file_path
  ,(picked_input_params[3]->''item_json''->''values''->1)->>''name'' as data3_pic2_name
  ,(picked_result_params[3]->''result_value''->1)->>''file_name'' as data3_pic2_file_name
  ,(picked_result_params[3]->''result_value''->1)->>''file_path'' as data3_pic2_file_path
  ,(picked_input_params[3]->''item_json''->''values''->2)->>''name'' as data3_pic3_name
  ,(picked_result_params[3]->''result_value''->2)->>''file_name'' as data3_pic3_file_name
  ,(picked_result_params[3]->''result_value''->2)->>''file_path'' as data3_pic3_file_path
  ,(picked_input_params[3]->''item_json''->''values''->3)->>''name'' as data3_pic4_name
  ,(picked_result_params[3]->''result_value''->3)->>''file_name'' as data3_pic4_file_name
  ,(picked_result_params[3]->''result_value''->3)->>''file_path'' as data3_pic4_file_path
  ,(picked_input_params[3]->''item_json''->''values''->4)->>''name'' as data3_pic5_name
  ,(picked_result_params[3]->''result_value''->4)->>''file_name'' as data3_pic5_file_name
  ,(picked_result_params[3]->''result_value''->4)->>''file_path'' as data3_pic5_file_path
  ,(picked_input_params[3]->''item_json''->''values''->5)->>''name'' as data3_pic6_name
  ,(picked_result_params[3]->''result_value''->5)->>''file_name'' as data3_pic6_file_name
  ,(picked_result_params[3]->''result_value''->5)->>''file_path'' as data3_pic6_file_path
  ,(picked_input_params[3]->''item_json''->''values''->6)->>''name'' as data3_pic7_name
  ,(picked_result_params[3]->''result_value''->6)->>''file_name'' as data3_pic7_file_name
  ,(picked_result_params[3]->''result_value''->6)->>''file_path'' as data3_pic7_file_path
  ,(picked_input_params[3]->''item_json''->''values''->7)->>''name'' as data3_pic8_name
  ,(picked_result_params[3]->''result_value''->7)->>''file_name'' as data3_pic8_file_name
  ,(picked_result_params[3]->''result_value''->7)->>''file_path'' as data3_pic8_file_path
  ,(picked_input_params[3]->''item_json''->''values''->8)->>''name'' as data3_pic9_name
  ,(picked_result_params[3]->''result_value''->8)->>''file_name'' as data3_pic9_file_name
  ,(picked_result_params[3]->''result_value''->8)->>''file_path'' as data3_pic9_file_path
  
  ,(picked_input_params[4]->''item_json''->''values''->0)->>''name'' as data4_pic1_name
  ,(picked_result_params[4]->''result_value''->0)->>''file_name'' as data4_pic1_file_name
  ,(picked_result_params[4]->''result_value''->0)->>''file_path'' as data4_pic1_file_path
  ,(picked_input_params[4]->''item_json''->''values''->1)->>''name'' as data4_pic2_name
  ,(picked_result_params[4]->''result_value''->1)->>''file_name'' as data4_pic2_file_name
  ,(picked_result_params[4]->''result_value''->1)->>''file_path'' as data4_pic2_file_path
  ,(picked_input_params[4]->''item_json''->''values''->2)->>''name'' as data4_pic3_name
  ,(picked_result_params[4]->''result_value''->2)->>''file_name'' as data4_pic3_file_name
  ,(picked_result_params[4]->''result_value''->2)->>''file_path'' as data4_pic3_file_path
  ,(picked_input_params[4]->''item_json''->''values''->3)->>''name'' as data4_pic4_name
  ,(picked_result_params[4]->''result_value''->3)->>''file_name'' as data4_pic4_file_name
  ,(picked_result_params[4]->''result_value''->3)->>''file_path'' as data4_pic4_file_path
  ,(picked_input_params[4]->''item_json''->''values''->4)->>''name'' as data4_pic5_name
  ,(picked_result_params[4]->''result_value''->4)->>''file_name'' as data4_pic5_file_name
  ,(picked_result_params[4]->''result_value''->4)->>''file_path'' as data4_pic5_file_path
  ,(picked_input_params[4]->''item_json''->''values''->5)->>''name'' as data4_pic6_name
  ,(picked_result_params[4]->''result_value''->5)->>''file_name'' as data4_pic6_file_name
  ,(picked_result_params[4]->''result_value''->5)->>''file_path'' as data4_pic6_file_path
  ,(picked_input_params[4]->''item_json''->''values''->6)->>''name'' as data4_pic7_name
  ,(picked_result_params[4]->''result_value''->6)->>''file_name'' as data4_pic7_file_name
  ,(picked_result_params[4]->''result_value''->6)->>''file_path'' as data4_pic7_file_path
  ,(picked_input_params[4]->''item_json''->''values''->7)->>''name'' as data4_pic8_name
  ,(picked_result_params[4]->''result_value''->7)->>''file_name'' as data4_pic8_file_name
  ,(picked_result_params[4]->''result_value''->7)->>''file_path'' as data4_pic8_file_path
  ,(picked_input_params[4]->''item_json''->''values''->8)->>''name'' as data4_pic9_name
  ,(picked_result_params[4]->''result_value''->8)->>''file_name'' as data4_pic9_file_name
  ,(picked_result_params[4]->''result_value''->8)->>''file_path'' as data4_pic9_file_path
  
  ,(picked_input_params[5]->''item_json''->''values''->0)->>''name'' as data5_pic1_name
  ,(picked_result_params[5]->''result_value''->0)->>''file_name'' as data5_pic1_file_name
  ,(picked_result_params[5]->''result_value''->0)->>''file_path'' as data5_pic1_file_path
  ,(picked_input_params[5]->''item_json''->''values''->1)->>''name'' as data5_pic2_name
  ,(picked_result_params[5]->''result_value''->1)->>''file_name'' as data5_pic2_file_name
  ,(picked_result_params[5]->''result_value''->1)->>''file_path'' as data5_pic2_file_path
  ,(picked_input_params[5]->''item_json''->''values''->2)->>''name'' as data5_pic3_name
  ,(picked_result_params[5]->''result_value''->2)->>''file_name'' as data5_pic3_file_name
  ,(picked_result_params[5]->''result_value''->2)->>''file_path'' as data5_pic3_file_path
  ,(picked_input_params[5]->''item_json''->''values''->3)->>''name'' as data5_pic4_name
  ,(picked_result_params[5]->''result_value''->3)->>''file_name'' as data5_pic4_file_name
  ,(picked_result_params[5]->''result_value''->3)->>''file_path'' as data5_pic4_file_path
  ,(picked_input_params[5]->''item_json''->''values''->4)->>''name'' as data5_pic5_name
  ,(picked_result_params[5]->''result_value''->4)->>''file_name'' as data5_pic5_file_name
  ,(picked_result_params[5]->''result_value''->4)->>''file_path'' as data5_pic5_file_path
  ,(picked_input_params[5]->''item_json''->''values''->5)->>''name'' as data5_pic6_name
  ,(picked_result_params[5]->''result_value''->5)->>''file_name'' as data5_pic6_file_name
  ,(picked_result_params[5]->''result_value''->5)->>''file_path'' as data5_pic6_file_path
  ,(picked_input_params[5]->''item_json''->''values''->6)->>''name'' as data5_pic7_name
  ,(picked_result_params[5]->''result_value''->6)->>''file_name'' as data5_pic7_file_name
  ,(picked_result_params[5]->''result_value''->6)->>''file_path'' as data5_pic7_file_path
  ,(picked_input_params[5]->''item_json''->''values''->7)->>''name'' as data5_pic8_name
  ,(picked_result_params[5]->''result_value''->7)->>''file_name'' as data5_pic8_file_name
  ,(picked_result_params[5]->''result_value''->7)->>''file_path'' as data5_pic8_file_path
  ,(picked_input_params[5]->''item_json''->''values''->8)->>''name'' as data5_pic9_name
  ,(picked_result_params[5]->''result_value''->8)->>''file_name'' as data5_pic9_file_name
  ,(picked_result_params[5]->''result_value''->8)->>''file_path'' as data5_pic9_file_path
  
  ,(picked_input_params[6]->''item_json''->''values''->0)->>''name'' as data6_pic1_name
  ,(picked_result_params[6]->''result_value''->0)->>''file_name'' as data6_pic1_file_name
  ,(picked_result_params[6]->''result_value''->0)->>''file_path'' as data6_pic1_file_path
  ,(picked_input_params[6]->''item_json''->''values''->1)->>''name'' as data6_pic2_name
  ,(picked_result_params[6]->''result_value''->1)->>''file_name'' as data6_pic2_file_name
  ,(picked_result_params[6]->''result_value''->1)->>''file_path'' as data6_pic2_file_path
  ,(picked_input_params[6]->''item_json''->''values''->2)->>''name'' as data6_pic3_name
  ,(picked_result_params[6]->''result_value''->2)->>''file_name'' as data6_pic3_file_name
  ,(picked_result_params[6]->''result_value''->2)->>''file_path'' as data6_pic3_file_path
  ,(picked_input_params[6]->''item_json''->''values''->3)->>''name'' as data6_pic4_name
  ,(picked_result_params[6]->''result_value''->3)->>''file_name'' as data6_pic4_file_name
  ,(picked_result_params[6]->''result_value''->3)->>''file_path'' as data6_pic4_file_path
  ,(picked_input_params[6]->''item_json''->''values''->4)->>''name'' as data6_pic5_name
  ,(picked_result_params[6]->''result_value''->4)->>''file_name'' as data6_pic5_file_name
  ,(picked_result_params[6]->''result_value''->4)->>''file_path'' as data6_pic5_file_path
  ,(picked_input_params[6]->''item_json''->''values''->5)->>''name'' as data6_pic6_name
  ,(picked_result_params[6]->''result_value''->5)->>''file_name'' as data6_pic6_file_name
  ,(picked_result_params[6]->''result_value''->5)->>''file_path'' as data6_pic6_file_path
  ,(picked_input_params[6]->''item_json''->''values''->6)->>''name'' as data6_pic7_name
  ,(picked_result_params[6]->''result_value''->6)->>''file_name'' as data6_pic7_file_name
  ,(picked_result_params[6]->''result_value''->6)->>''file_path'' as data6_pic7_file_path
  ,(picked_input_params[6]->''item_json''->''values''->7)->>''name'' as data6_pic8_name
  ,(picked_result_params[6]->''result_value''->7)->>''file_name'' as data6_pic8_file_name
  ,(picked_result_params[6]->''result_value''->7)->>''file_path'' as data6_pic8_file_path
  ,(picked_input_params[6]->''item_json''->''values''->8)->>''name'' as data6_pic9_name
  ,(picked_result_params[6]->''result_value''->8)->>''file_name'' as data6_pic9_file_name
  ,(picked_result_params[6]->''result_value''->8)->>''file_path'' as data6_pic9_file_path
  
  ,(picked_input_params[7]->''item_json''->''values''->0)->>''name'' as data7_pic1_name
  ,(picked_result_params[7]->''result_value''->0)->>''file_name'' as data7_pic1_file_name
  ,(picked_result_params[7]->''result_value''->0)->>''file_path'' as data7_pic1_file_path
  ,(picked_input_params[7]->''item_json''->''values''->1)->>''name'' as data7_pic2_name
  ,(picked_result_params[7]->''result_value''->1)->>''file_name'' as data7_pic2_file_name
  ,(picked_result_params[7]->''result_value''->1)->>''file_path'' as data7_pic2_file_path
  ,(picked_input_params[7]->''item_json''->''values''->2)->>''name'' as data7_pic3_name
  ,(picked_result_params[7]->''result_value''->2)->>''file_name'' as data7_pic3_file_name
  ,(picked_result_params[7]->''result_value''->2)->>''file_path'' as data7_pic3_file_path
  ,(picked_input_params[7]->''item_json''->''values''->3)->>''name'' as data7_pic4_name
  ,(picked_result_params[7]->''result_value''->3)->>''file_name'' as data7_pic4_file_name
  ,(picked_result_params[7]->''result_value''->3)->>''file_path'' as data7_pic4_file_path
  ,(picked_input_params[7]->''item_json''->''values''->4)->>''name'' as data7_pic5_name
  ,(picked_result_params[7]->''result_value''->4)->>''file_name'' as data7_pic5_file_name
  ,(picked_result_params[7]->''result_value''->4)->>''file_path'' as data7_pic5_file_path
  ,(picked_input_params[7]->''item_json''->''values''->5)->>''name'' as data7_pic6_name
  ,(picked_result_params[7]->''result_value''->5)->>''file_name'' as data7_pic6_file_name
  ,(picked_result_params[7]->''result_value''->5)->>''file_path'' as data7_pic6_file_path
  ,(picked_input_params[7]->''item_json''->''values''->6)->>''name'' as data7_pic7_name
  ,(picked_result_params[7]->''result_value''->6)->>''file_name'' as data7_pic7_file_name
  ,(picked_result_params[7]->''result_value''->6)->>''file_path'' as data7_pic7_file_path
  ,(picked_input_params[7]->''item_json''->''values''->7)->>''name'' as data7_pic8_name
  ,(picked_result_params[7]->''result_value''->7)->>''file_name'' as data7_pic8_file_name
  ,(picked_result_params[7]->''result_value''->7)->>''file_path'' as data7_pic8_file_path
  ,(picked_input_params[7]->''item_json''->''values''->8)->>''name'' as data7_pic9_name
  ,(picked_result_params[7]->''result_value''->8)->>''file_name'' as data7_pic9_file_name
  ,(picked_result_params[7]->''result_value''->8)->>''file_path'' as data7_pic9_file_path
  
  ,(picked_input_params[8]->''item_json''->''values''->0)->>''name'' as data8_pic1_name
  ,(picked_result_params[8]->''result_value''->0)->>''file_name'' as data8_pic1_file_name
  ,(picked_result_params[8]->''result_value''->0)->>''file_path'' as data8_pic1_file_path
  ,(picked_input_params[8]->''item_json''->''values''->1)->>''name'' as data8_pic2_name
  ,(picked_result_params[8]->''result_value''->1)->>''file_name'' as data8_pic2_file_name
  ,(picked_result_params[8]->''result_value''->1)->>''file_path'' as data8_pic2_file_path
  ,(picked_input_params[8]->''item_json''->''values''->2)->>''name'' as data8_pic3_name
  ,(picked_result_params[8]->''result_value''->2)->>''file_name'' as data8_pic3_file_name
  ,(picked_result_params[8]->''result_value''->2)->>''file_path'' as data8_pic3_file_path
  ,(picked_input_params[8]->''item_json''->''values''->3)->>''name'' as data8_pic4_name
  ,(picked_result_params[8]->''result_value''->3)->>''file_name'' as data8_pic4_file_name
  ,(picked_result_params[8]->''result_value''->3)->>''file_path'' as data8_pic4_file_path
  ,(picked_input_params[8]->''item_json''->''values''->4)->>''name'' as data8_pic5_name
  ,(picked_result_params[8]->''result_value''->4)->>''file_name'' as data8_pic5_file_name
  ,(picked_result_params[8]->''result_value''->4)->>''file_path'' as data8_pic5_file_path
  ,(picked_input_params[8]->''item_json''->''values''->5)->>''name'' as data8_pic6_name
  ,(picked_result_params[8]->''result_value''->5)->>''file_name'' as data8_pic6_file_name
  ,(picked_result_params[8]->''result_value''->5)->>''file_path'' as data8_pic6_file_path
  ,(picked_input_params[8]->''item_json''->''values''->6)->>''name'' as data8_pic7_name
  ,(picked_result_params[8]->''result_value''->6)->>''file_name'' as data8_pic7_file_name
  ,(picked_result_params[8]->''result_value''->6)->>''file_path'' as data8_pic7_file_path
  ,(picked_input_params[8]->''item_json''->''values''->7)->>''name'' as data8_pic8_name
  ,(picked_result_params[8]->''result_value''->7)->>''file_name'' as data8_pic8_file_name
  ,(picked_result_params[8]->''result_value''->7)->>''file_path'' as data8_pic8_file_path
  ,(picked_input_params[8]->''item_json''->''values''->8)->>''name'' as data8_pic9_name
  ,(picked_result_params[8]->''result_value''->8)->>''file_name'' as data8_pic9_file_name
  ,(picked_result_params[8]->''result_value''->8)->>''file_path'' as data8_pic9_file_path
  
  ,(picked_input_params[9]->''item_json''->''values''->0)->>''name'' as data9_pic1_name
  ,(picked_result_params[9]->''result_value''->0)->>''file_name'' as data9_pic1_file_name
  ,(picked_result_params[9]->''result_value''->0)->>''file_path'' as data9_pic1_file_path
  ,(picked_input_params[9]->''item_json''->''values''->1)->>''name'' as data9_pic2_name
  ,(picked_result_params[9]->''result_value''->1)->>''file_name'' as data9_pic2_file_name
  ,(picked_result_params[9]->''result_value''->1)->>''file_path'' as data9_pic2_file_path
  ,(picked_input_params[9]->''item_json''->''values''->2)->>''name'' as data9_pic3_name
  ,(picked_result_params[9]->''result_value''->2)->>''file_name'' as data9_pic3_file_name
  ,(picked_result_params[9]->''result_value''->2)->>''file_path'' as data9_pic3_file_path
  ,(picked_input_params[9]->''item_json''->''values''->3)->>''name'' as data9_pic4_name
  ,(picked_result_params[9]->''result_value''->3)->>''file_name'' as data9_pic4_file_name
  ,(picked_result_params[9]->''result_value''->3)->>''file_path'' as data9_pic4_file_path
  ,(picked_input_params[9]->''item_json''->''values''->4)->>''name'' as data9_pic5_name
  ,(picked_result_params[9]->''result_value''->4)->>''file_name'' as data9_pic5_file_name
  ,(picked_result_params[9]->''result_value''->4)->>''file_path'' as data9_pic5_file_path
  ,(picked_input_params[9]->''item_json''->''values''->5)->>''name'' as data9_pic6_name
  ,(picked_result_params[9]->''result_value''->5)->>''file_name'' as data9_pic6_file_name
  ,(picked_result_params[9]->''result_value''->5)->>''file_path'' as data9_pic6_file_path
  ,(picked_input_params[9]->''item_json''->''values''->6)->>''name'' as data9_pic7_name
  ,(picked_result_params[9]->''result_value''->6)->>''file_name'' as data9_pic7_file_name
  ,(picked_result_params[9]->''result_value''->6)->>''file_path'' as data9_pic7_file_path
  ,(picked_input_params[9]->''item_json''->''values''->7)->>''name'' as data9_pic8_name
  ,(picked_result_params[9]->''result_value''->7)->>''file_name'' as data9_pic8_file_name
  ,(picked_result_params[9]->''result_value''->7)->>''file_path'' as data9_pic8_file_path
  ,(picked_input_params[9]->''item_json''->''values''->8)->>''name'' as data9_pic9_name
  ,(picked_result_params[9]->''result_value''->8)->>''file_name'' as data9_pic9_file_name
  ,(picked_result_params[9]->''result_value''->8)->>''file_path'' as data9_pic9_file_path
  
  ,(picked_input_params[10]->''item_json''->''values''->0)->>''name'' as data10_pic1_name
  ,(picked_result_params[10]->''result_value''->0)->>''file_name'' as data10_pic1_file_name
  ,(picked_result_params[10]->''result_value''->0)->>''file_path'' as data10_pic1_file_path
  ,(picked_input_params[10]->''item_json''->''values''->1)->>''name'' as data10_pic2_name
  ,(picked_result_params[10]->''result_value''->1)->>''file_name'' as data10_pic2_file_name
  ,(picked_result_params[10]->''result_value''->1)->>''file_path'' as data10_pic2_file_path
  ,(picked_input_params[10]->''item_json''->''values''->2)->>''name'' as data10_pic3_name
  ,(picked_result_params[10]->''result_value''->2)->>''file_name'' as data10_pic3_file_name
  ,(picked_result_params[10]->''result_value''->2)->>''file_path'' as data10_pic3_file_path
  ,(picked_input_params[10]->''item_json''->''values''->3)->>''name'' as data10_pic4_name
  ,(picked_result_params[10]->''result_value''->3)->>''file_name'' as data10_pic4_file_name
  ,(picked_result_params[10]->''result_value''->3)->>''file_path'' as data10_pic4_file_path
  ,(picked_input_params[10]->''item_json''->''values''->4)->>''name'' as data10_pic5_name
  ,(picked_result_params[10]->''result_value''->4)->>''file_name'' as data10_pic5_file_name
  ,(picked_result_params[10]->''result_value''->4)->>''file_path'' as data10_pic5_file_path
  ,(picked_input_params[10]->''item_json''->''values''->5)->>''name'' as data10_pic6_name
  ,(picked_result_params[10]->''result_value''->5)->>''file_name'' as data10_pic6_file_name
  ,(picked_result_params[10]->''result_value''->5)->>''file_path'' as data10_pic6_file_path
  ,(picked_input_params[10]->''item_json''->''values''->6)->>''name'' as data10_pic7_name
  ,(picked_result_params[10]->''result_value''->6)->>''file_name'' as data10_pic7_file_name
  ,(picked_result_params[10]->''result_value''->6)->>''file_path'' as data10_pic7_file_path
  ,(picked_input_params[10]->''item_json''->''values''->7)->>''name'' as data10_pic8_name
  ,(picked_result_params[10]->''result_value''->7)->>''file_name'' as data10_pic8_file_name
  ,(picked_result_params[10]->''result_value''->7)->>''file_path'' as data10_pic8_file_path
  ,(picked_input_params[10]->''item_json''->''values''->8)->>''name'' as data10_pic9_name
  ,(picked_result_params[10]->''result_value''->8)->>''file_name'' as data10_pic9_file_name
  ,(picked_result_params[10]->''result_value''->8)->>''file_path'' as data10_pic9_file_path
from
  pe_array_agg
  inner join pe_basicinfo on pe_array_agg.pat_event_cd = pe_basicinfo.pat_event_cd
;', 2, '[{"preview": "2020/03/26 08:00", "can_calc": "0", "data_code": "event_start_date", "data_name": "イベント開始日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "event_start_date", "disp_format": "yyyy/mm/dd hh:mm", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26 08:00", "can_calc": "0", "data_code": "event_end_date", "data_name": "イベント終了日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "event_end_date", "disp_format": "yyyy/mm/dd hh:mm", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "起票者", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "reg_staff_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/25 08:00", "can_calc": "0", "data_code": "reg_date", "data_name": "起票日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "reg_date", "disp_format": "yyyy/mm/dd hh:mm", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師２", "can_calc": "0", "data_code": "up_staff_name", "data_name": "最終編集者", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "up_staff_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26 08:00 ", "can_calc": "0", "data_code": "up_date", "data_name": "最終編集日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "up_date", "disp_format": "yyyy/mm/dd hh:mm", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連患者イベント(画像)", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連患者イベント(画像)", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連患者イベント(画像)", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連患者イベント(画像)", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連患者イベント(画像)", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連患者イベント(画像)", "can_calc": "0", "data_code": "data6_field_name", "data_name": "データ6 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連患者イベント(画像)", "can_calc": "0", "data_code": "data7_field_name", "data_name": "データ7 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連患者イベント(画像)", "can_calc": "0", "data_code": "data8_field_name", "data_name": "データ8 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連患者イベント(画像)", "can_calc": "0", "data_code": "data9_field_name", "data_name": "データ9 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート関連患者イベント(画像)", "can_calc": "0", "data_code": "data10_field_name", "data_name": "データ10 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data1_pic1_file_name", "data_name": "データ1 患者イベント(画像)1 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic1_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data1_pic1_file_path", "data_name": "データ1 患者イベント(画像)1Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic1_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data1_pic2_file_name", "data_name": "データ1 患者イベント(画像)2 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic2_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data1_pic2_file_path", "data_name": "データ1 患者イベント(画像)2Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic2_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data1_pic3_file_name", "data_name": "データ1 患者イベント(画像)3 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic3_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data1_pic3_file_path", "data_name": "データ1 患者イベント(画像)3Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic3_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data1_pic4_file_name", "data_name": "データ1 患者イベント(画像)4 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic4_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data1_pic4_file_path", "data_name": "データ1 患者イベント(画像)4Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic4_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data1_pic5_file_name", "data_name": "データ1 患者イベント(画像)5 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic5_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data1_pic5_file_path", "data_name": "データ1 患者イベント(画像)5Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic5_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data1_pic6_file_name", "data_name": "データ1 患者イベント(画像)6 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic6_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data1_pic6_file_path", "data_name": "データ1 患者イベント(画像)6Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic6_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data1_pic7_file_name", "data_name": "データ1 患者イベント(画像)7 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic7_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data1_pic7_file_path", "data_name": "データ1 患者イベント(画像)7Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic7_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data1_pic8_file_name", "data_name": "データ1 患者イベント(画像)8 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic8_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data1_pic8_file_path", "data_name": "データ1 患者イベント(画像)8Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic8_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data1_pic9_file_name", "data_name": "データ1 患者イベント(画像)9 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic9_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data1_pic9_file_path", "data_name": "データ1 患者イベント(画像)9Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data1_pic9_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data2_pic1_file_name", "data_name": "データ2 患者イベント(画像)1 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic1_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data2_pic1_file_path", "data_name": "データ2 患者イベント(画像)1Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic1_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data2_pic2_file_name", "data_name": "データ2 患者イベント(画像)2 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic2_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data2_pic2_file_path", "data_name": "データ2 患者イベント(画像)2Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic2_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data2_pic3_file_name", "data_name": "データ2 患者イベント(画像)3 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic3_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data2_pic3_file_path", "data_name": "データ2 患者イベント(画像)3Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic3_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data2_pic4_file_name", "data_name": "データ2 患者イベント(画像)4 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic4_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data2_pic4_file_path", "data_name": "データ2 患者イベント(画像)4Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic4_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data2_pic5_file_name", "data_name": "データ2 患者イベント(画像)5 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic5_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data2_pic5_file_path", "data_name": "データ2 患者イベント(画像)5Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic5_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data2_pic6_file_name", "data_name": "データ2 患者イベント(画像)6 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic6_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data2_pic6_file_path", "data_name": "データ2 患者イベント(画像)6Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic6_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data2_pic7_file_name", "data_name": "データ2 患者イベント(画像)7 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic7_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data2_pic7_file_path", "data_name": "データ2 患者イベント(画像)7Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic7_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data2_pic8_file_name", "data_name": "データ2 患者イベント(画像)8 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic8_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data2_pic8_file_path", "data_name": "データ2 患者イベント(画像)8Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic8_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data2_pic9_file_name", "data_name": "データ2 患者イベント(画像)9 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic9_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data2_pic9_file_path", "data_name": "データ2 患者イベント(画像)9Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data2_pic9_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data3_pic1_file_name", "data_name": "データ3 患者イベント(画像)1 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic1_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data3_pic1_file_path", "data_name": "データ3 患者イベント(画像)1Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic1_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data3_pic2_file_name", "data_name": "データ3 患者イベント(画像)2 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic2_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data3_pic2_file_path", "data_name": "データ3 患者イベント(画像)2Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic2_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data3_pic3_file_name", "data_name": "データ3 患者イベント(画像)3 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic3_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data3_pic3_file_path", "data_name": "データ3 患者イベント(画像)3Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic3_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data3_pic4_file_name", "data_name": "データ3 患者イベント(画像)4 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic4_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data3_pic4_file_path", "data_name": "データ3 患者イベント(画像)4Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic4_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data3_pic5_file_name", "data_name": "データ3 患者イベント(画像)5 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic5_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data3_pic5_file_path", "data_name": "データ3 患者イベント(画像)5Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic5_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data3_pic6_file_name", "data_name": "データ3 患者イベント(画像)6 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic6_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data3_pic6_file_path", "data_name": "データ3 患者イベント(画像)6Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic6_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data3_pic7_file_name", "data_name": "データ3 患者イベント(画像)7 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic7_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data3_pic7_file_path", "data_name": "データ3 患者イベント(画像)7Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic7_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data3_pic8_file_name", "data_name": "データ3 患者イベント(画像)8 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic8_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data3_pic8_file_path", "data_name": "データ3 患者イベント(画像)8Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic8_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data3_pic9_file_name", "data_name": "データ3 患者イベント(画像)9 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic9_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data3_pic9_file_path", "data_name": "データ3 患者イベント(画像)9Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data3_pic9_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data4_pic1_file_name", "data_name": "データ4 患者イベント(画像)1 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic1_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data4_pic1_file_path", "data_name": "データ4 患者イベント(画像)1Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic1_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data4_pic2_file_name", "data_name": "データ4 患者イベント(画像)2 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic2_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data4_pic2_file_path", "data_name": "データ4 患者イベント(画像)2Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic2_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data4_pic3_file_name", "data_name": "データ4 患者イベント(画像)3 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic3_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data4_pic3_file_path", "data_name": "データ4 患者イベント(画像)3Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic3_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data4_pic4_file_name", "data_name": "データ4 患者イベント(画像)4 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic4_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data4_pic4_file_path", "data_name": "データ4 患者イベント(画像)4Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic4_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data4_pic5_file_name", "data_name": "データ4 患者イベント(画像)5 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic5_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data4_pic5_file_path", "data_name": "データ4 患者イベント(画像)5Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic5_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data4_pic6_file_name", "data_name": "データ4 患者イベント(画像)6 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic6_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data4_pic6_file_path", "data_name": "データ4 患者イベント(画像)6Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic6_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data4_pic7_file_name", "data_name": "データ4 患者イベント(画像)7 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic7_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data4_pic7_file_path", "data_name": "データ4 患者イベント(画像)7Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic7_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data4_pic8_file_name", "data_name": "データ4 患者イベント(画像)8 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic8_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data4_pic8_file_path", "data_name": "データ4 患者イベント(画像)8Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic8_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data4_pic9_file_name", "data_name": "データ4 患者イベント(画像)9 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic9_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data4_pic9_file_path", "data_name": "データ4 患者イベント(画像)9Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data4_pic9_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data5_pic1_file_name", "data_name": "データ5 患者イベント(画像)1 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic1_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "graph.jpg", "can_calc": "0", "is_image": "true", "data_code": "data5_pic1_file_path", "data_name": "データ5 患者イベント(画像)1Image", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic1_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data5_pic2_file_name", "data_name": "データ5 患者イベント(画像)2 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic2_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data5_pic2_file_path", "data_name": "データ5 患者イベント(画像)2Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic2_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data5_pic3_file_name", "data_name": "データ5 患者イベント(画像)3 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic3_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data5_pic3_file_path", "data_name": "データ5 患者イベント(画像)3Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic3_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data5_pic4_file_name", "data_name": "データ5 患者イベント(画像)4 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic4_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data5_pic4_file_path", "data_name": "データ5 患者イベント(画像)4Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic4_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data5_pic5_file_name", "data_name": "データ5 患者イベント(画像)5 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic5_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data5_pic5_file_path", "data_name": "データ5 患者イベント(画像)5Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic5_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data5_pic6_file_name", "data_name": "データ5 患者イベント(画像)6 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic6_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data5_pic6_file_path", "data_name": "データ5 患者イベント(画像)6Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic6_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data5_pic7_file_name", "data_name": "データ5 患者イベント(画像)7 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic7_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data5_pic7_file_path", "data_name": "データ5 患者イベント(画像)7Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic7_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data5_pic8_file_name", "data_name": "データ5 患者イベント(画像)8 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic8_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data5_pic8_file_path", "data_name": "データ5 患者イベント(画像)8Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic8_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data5_pic9_file_name", "data_name": "データ5 患者イベント(画像)9 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic9_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data5_pic9_file_path", "data_name": "データ5 患者イベント(画像)9Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data5_pic9_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data6_pic1_file_name", "data_name": "データ6 患者イベント(画像)1 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic1_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data6_pic1_file_path", "data_name": "データ6 患者イベント(画像)1Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic1_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data6_pic2_file_name", "data_name": "データ6 患者イベント(画像)2 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic2_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data6_pic2_file_path", "data_name": "データ6 患者イベント(画像)2Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic2_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data6_pic3_file_name", "data_name": "データ6 患者イベント(画像)3 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic3_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data6_pic3_file_path", "data_name": "データ6 患者イベント(画像)3Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic3_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data6_pic4_file_name", "data_name": "データ6 患者イベント(画像)4 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic4_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data6_pic4_file_path", "data_name": "データ6 患者イベント(画像)4Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic4_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data6_pic5_file_name", "data_name": "データ6 患者イベント(画像)5 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic5_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data6_pic5_file_path", "data_name": "データ6 患者イベント(画像)5Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic5_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data6_pic6_file_name", "data_name": "データ6 患者イベント(画像)6 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic6_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data6_pic6_file_path", "data_name": "データ6 患者イベント(画像)6Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic6_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data6_pic7_file_name", "data_name": "データ6 患者イベント(画像)7 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic7_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data6_pic7_file_path", "data_name": "データ6 患者イベント(画像)7Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic7_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data6_pic8_file_name", "data_name": "データ6 患者イベント(画像)8 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic8_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data6_pic8_file_path", "data_name": "データ6 患者イベント(画像)8Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic8_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data6_pic9_file_name", "data_name": "データ6 患者イベント(画像)9 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic9_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data6_pic9_file_path", "data_name": "データ6 患者イベント(画像)9Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data6_pic9_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data7_pic1_file_name", "data_name": "データ7 患者イベント(画像)1 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic1_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data7_pic1_file_path", "data_name": "データ7 患者イベント(画像)1Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic1_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data7_pic2_file_name", "data_name": "データ7 患者イベント(画像)2 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic2_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data7_pic2_file_path", "data_name": "データ7 患者イベント(画像)2Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic2_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data7_pic3_file_name", "data_name": "データ7 患者イベント(画像)3 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic3_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data7_pic3_file_path", "data_name": "データ7 患者イベント(画像)3Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic3_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data7_pic4_file_name", "data_name": "データ7 患者イベント(画像)4 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic4_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data7_pic4_file_path", "data_name": "データ7 患者イベント(画像)4Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic4_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data7_pic5_file_name", "data_name": "データ7 患者イベント(画像)5 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic5_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data7_pic5_file_path", "data_name": "データ7 患者イベント(画像)5Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic5_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data7_pic6_file_name", "data_name": "データ7 患者イベント(画像)6 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic6_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data7_pic6_file_path", "data_name": "データ7 患者イベント(画像)6Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic6_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data7_pic7_file_name", "data_name": "データ7 患者イベント(画像)7 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic7_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data7_pic7_file_path", "data_name": "データ7 患者イベント(画像)7Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic7_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data7_pic8_file_name", "data_name": "データ7 患者イベント(画像)8 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic8_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data7_pic8_file_path", "data_name": "データ7 患者イベント(画像)8Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic8_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data7_pic9_file_name", "data_name": "データ7 患者イベント(画像)9 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic9_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data7_pic9_file_path", "data_name": "データ7 患者イベント(画像)9Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data7_pic9_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data8_pic1_file_name", "data_name": "データ8 患者イベント(画像)1 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic1_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data8_pic1_file_path", "data_name": "データ8 患者イベント(画像)1Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic1_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data8_pic2_file_name", "data_name": "データ8 患者イベント(画像)2 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic2_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data8_pic2_file_path", "data_name": "データ8 患者イベント(画像)2Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic2_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data8_pic3_file_name", "data_name": "データ8 患者イベント(画像)3 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic3_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data8_pic3_file_path", "data_name": "データ8 患者イベント(画像)3Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic3_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data8_pic4_file_name", "data_name": "データ8 患者イベント(画像)4 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic4_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data8_pic4_file_path", "data_name": "データ8 患者イベント(画像)4Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic4_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data8_pic5_file_name", "data_name": "データ8 患者イベント(画像)5 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic5_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data8_pic5_file_path", "data_name": "データ8 患者イベント(画像)5Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic5_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data8_pic6_file_name", "data_name": "データ8 患者イベント(画像)6 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic6_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data8_pic6_file_path", "data_name": "データ8 患者イベント(画像)6Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic6_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data8_pic7_file_name", "data_name": "データ8 患者イベント(画像)7 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic7_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data8_pic7_file_path", "data_name": "データ8 患者イベント(画像)7Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic7_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data8_pic8_file_name", "data_name": "データ8 患者イベント(画像)8 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic8_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data8_pic8_file_path", "data_name": "データ8 患者イベント(画像)8Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic8_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data8_pic9_file_name", "data_name": "データ8 患者イベント(画像)9 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic9_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data8_pic9_file_path", "data_name": "データ8 患者イベント(画像)9Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data8_pic9_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data9_pic1_file_name", "data_name": "データ9 患者イベント(画像)1 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic1_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data9_pic1_file_path", "data_name": "データ9 患者イベント(画像)1Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic1_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data9_pic2_file_name", "data_name": "データ9 患者イベント(画像)2 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic2_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data9_pic2_file_path", "data_name": "データ9 患者イベント(画像)2Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic2_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data9_pic3_file_name", "data_name": "データ9 患者イベント(画像)3 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic3_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data9_pic3_file_path", "data_name": "データ9 患者イベント(画像)3Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic3_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data9_pic4_file_name", "data_name": "データ9 患者イベント(画像)4 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic4_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data9_pic4_file_path", "data_name": "データ9 患者イベント(画像)4Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic4_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data9_pic5_file_name", "data_name": "データ9 患者イベント(画像)5 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic5_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data9_pic5_file_path", "data_name": "データ9 患者イベント(画像)5Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic5_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data9_pic6_file_name", "data_name": "データ9 患者イベント(画像)6 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic6_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data9_pic6_file_path", "data_name": "データ9 患者イベント(画像)6Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic6_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data9_pic7_file_name", "data_name": "データ9 患者イベント(画像)7 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic7_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data9_pic7_file_path", "data_name": "データ9 患者イベント(画像)7Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic7_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data9_pic8_file_name", "data_name": "データ9 患者イベント(画像)8 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic8_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data9_pic8_file_path", "data_name": "データ9 患者イベント(画像)8Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic8_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data9_pic9_file_name", "data_name": "データ9 患者イベント(画像)9 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic9_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data9_pic9_file_path", "data_name": "データ9 患者イベント(画像)9Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data9_pic9_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data10_pic1_file_name", "data_name": "データ10 患者イベント(画像)1 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic1_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data10_pic1_file_path", "data_name": "データ10 患者イベント(画像)1Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic1_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data10_pic2_file_name", "data_name": "データ10 患者イベント(画像)2 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic2_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data10_pic2_file_path", "data_name": "データ10 患者イベント(画像)2Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic2_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data10_pic3_file_name", "data_name": "データ10 患者イベント(画像)3 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic3_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data10_pic3_file_path", "data_name": "データ10 患者イベント(画像)3Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic3_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data10_pic4_file_name", "data_name": "データ10 患者イベント(画像)4 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic4_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data10_pic4_file_path", "data_name": "データ10 患者イベント(画像)4Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic4_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data10_pic5_file_name", "data_name": "データ10 患者イベント(画像)5 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic5_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data10_pic5_file_path", "data_name": "データ10 患者イベント(画像)5Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic5_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data10_pic6_file_name", "data_name": "データ10 患者イベント(画像)6 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic6_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data10_pic6_file_path", "data_name": "データ10 患者イベント(画像)6Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic6_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data10_pic7_file_name", "data_name": "データ10 患者イベント(画像)7 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic7_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data10_pic7_file_path", "data_name": "データ10 患者イベント(画像)7Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic7_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data10_pic8_file_name", "data_name": "データ10 患者イベント(画像)8 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic8_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data10_pic8_file_path", "data_name": "データ10 患者イベント(画像)8Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic8_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レポート患者イベント(画像)", "can_calc": "0", "data_code": "data10_pic9_file_name", "data_name": "データ10 患者イベント(画像)9 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic9_file_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "placeholder.jpg", "can_calc": "0", "is_image": "true", "data_code": "data10_pic9_file_path", "data_name": "データ10 患者イベント(画像)9Image", "data_type": "byte[]", "conv_table": [], "data_class": "患者イベント(画像)", "field_name": "data10_pic9_file_path", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 11]}', '患者情報：患者イベント 画像　@patId @fromDate @toDate使用', '2021-08-26 00:00:22', CURRENT_TIMESTAMP, NULL);



DELETE FROM "ntss"."sys_data_set" where sql_cd in (87);

INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (87, 'with input_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,input_param
  from
    pat_event
    cross join lateral jsonb_array_elements(input_params) with ordinality as tmp(input_param, json_idx)
  where
    is_del = ''0''
    and input_params != ''null''
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
)
, result_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,result_param
  from
    pat_event
    cross join lateral jsonb_array_elements(result_params) with ordinality as tmp(result_param, json_idx)
  where
    is_del = ''0''
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
)
, pe_basicinfo as
(
  select
    pat_event_cd
    ,event_start_date
    ,event_end_date
    ,event_start_time
    ,event_end_time
    ,category_name
    ,sub_category_cd
    ,sub_category_name
    ,reg_staff_info->>''reg_staff_name'' as reg_staff_name
    ,reg_date
    ,up_staff_info->>''up_staff_name'' as up_staff_name
    ,up_date
  from
    pat_event
  where
    is_del = ''0''
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
)
, pe_picked as
(
  select
    ipe.pat_event_cd
    ,ipe.json_idx
    ,input_param
    ,result_param
  from
    input_params_expand as ipe
    inner join result_params_expand as rpe
      on ipe.pat_event_cd = rpe.pat_event_cd and ipe.json_idx = rpe.json_idx
  where
    input_param->>''format_class'' = ''3''
)
, pe_array_agg as
(
  select
    pat_event_cd
    ,array_agg(input_param order by json_idx) as picked_input_params
    ,array_agg(result_param order by json_idx) as picked_result_params
  from
    pe_picked
  group by pat_event_cd
)

select
  pe_array_agg.pat_event_cd
  ,to_timestamp(event_start_date||
    case when event_start_time is null then ''0000''
         else event_start_time
    end, ''yyyyMMDDHH24mi'') AS event_start_date
  ,to_timestamp(event_end_date||
    case when event_end_time is null then ''0000''
         else event_end_time
    end, ''yyyyMMDDHH24mi'') AS event_end_date
  ,category_name
  ,pe_basicinfo.sub_category_cd
  ,pe_basicinfo.sub_category_name
  ,reg_staff_name
  ,pe_basicinfo.reg_date
  ,up_staff_name
  ,pe_basicinfo.up_date

  ,picked_input_params[1]->>''field_name'' as data1_field_name
  ,picked_input_params[2]->>''field_name'' as data2_field_name
  ,picked_input_params[3]->>''field_name'' as data3_field_name
  ,picked_input_params[4]->>''field_name'' as data4_field_name
  ,picked_input_params[5]->>''field_name'' as data5_field_name
  ,picked_input_params[6]->>''field_name'' as data6_field_name
  ,picked_input_params[7]->>''field_name'' as data7_field_name
  ,picked_input_params[8]->>''field_name'' as data8_field_name
  ,picked_input_params[9]->>''field_name'' as data9_field_name
  ,picked_input_params[10]->>''field_name'' as data10_field_name
  ,picked_input_params[11]->>''field_name'' as data11_field_name
  ,picked_input_params[12]->>''field_name'' as data12_field_name
  ,picked_input_params[13]->>''field_name'' as data13_field_name
  ,picked_input_params[14]->>''field_name'' as data14_field_name
  ,picked_input_params[15]->>''field_name'' as data15_field_name
  ,picked_input_params[16]->>''field_name'' as data16_field_name
  ,picked_input_params[17]->>''field_name'' as data17_field_name
  ,picked_input_params[18]->>''field_name'' as data18_field_name
  ,picked_input_params[19]->>''field_name'' as data19_field_name
  ,picked_input_params[20]->>''field_name'' as data20_field_name
  ,picked_input_params[21]->>''field_name'' as data21_field_name
  ,picked_input_params[22]->>''field_name'' as data22_field_name
  ,picked_input_params[23]->>''field_name'' as data23_field_name
  ,picked_input_params[24]->>''field_name'' as data24_field_name
  ,picked_input_params[25]->>''field_name'' as data25_field_name
  ,picked_input_params[26]->>''field_name'' as data26_field_name
  ,picked_input_params[27]->>''field_name'' as data27_field_name
  ,picked_input_params[28]->>''field_name'' as data28_field_name
  ,picked_input_params[29]->>''field_name'' as data29_field_name
  ,picked_input_params[30]->>''field_name'' as data30_field_name

  ,picked_result_params[1]->''result_value''->>''name'' as data1_name
  ,picked_result_params[1]->''result_value''->>''score'' as data1_score
  ,picked_result_params[2]->''result_value''->>''name'' as data2_name
  ,picked_result_params[2]->''result_value''->>''score'' as data2_score
  ,picked_result_params[3]->''result_value''->>''name'' as data3_name
  ,picked_result_params[3]->''result_value''->>''score'' as data3_score
  ,picked_result_params[4]->''result_value''->>''name'' as data4_name
  ,picked_result_params[4]->''result_value''->>''score'' as data4_score
  ,picked_result_params[5]->''result_value''->>''name'' as data5_name
  ,picked_result_params[5]->''result_value''->>''score'' as data5_score
  ,picked_result_params[6]->''result_value''->>''name'' as data6_name
  ,picked_result_params[6]->''result_value''->>''score'' as data6_score
  ,picked_result_params[7]->''result_value''->>''name'' as data7_name
  ,picked_result_params[7]->''result_value''->>''score'' as data7_score
  ,picked_result_params[8]->''result_value''->>''name'' as data8_name
  ,picked_result_params[8]->''result_value''->>''score'' as data8_score
  ,picked_result_params[9]->''result_value''->>''name'' as data9_name
  ,picked_result_params[9]->''result_value''->>''score'' as data9_score
  ,picked_result_params[10]->''result_value''->>''name'' as data10_name
  ,picked_result_params[10]->''result_value''->>''score'' as data10_score
  ,picked_result_params[11]->''result_value''->>''name'' as data11_name
  ,picked_result_params[11]->''result_value''->>''score'' as data11_score
  ,picked_result_params[12]->''result_value''->>''name'' as data12_name
  ,picked_result_params[12]->''result_value''->>''score'' as data12_score
  ,picked_result_params[13]->''result_value''->>''name'' as data13_name
  ,picked_result_params[13]->''result_value''->>''score'' as data13_score
  ,picked_result_params[14]->''result_value''->>''name'' as data14_name
  ,picked_result_params[14]->''result_value''->>''score'' as data14_score
  ,picked_result_params[15]->''result_value''->>''name'' as data15_name
  ,picked_result_params[15]->''result_value''->>''score'' as data15_score
  ,picked_result_params[16]->''result_value''->>''name'' as data16_name
  ,picked_result_params[16]->''result_value''->>''score'' as data16_score
  ,picked_result_params[17]->''result_value''->>''name'' as data17_name
  ,picked_result_params[17]->''result_value''->>''score'' as data17_score
  ,picked_result_params[18]->''result_value''->>''name'' as data18_name
  ,picked_result_params[18]->''result_value''->>''score'' as data18_score
  ,picked_result_params[19]->''result_value''->>''name'' as data19_name
  ,picked_result_params[19]->''result_value''->>''score'' as data19_score
  ,picked_result_params[20]->''result_value''->>''name'' as data20_name
  ,picked_result_params[20]->''result_value''->>''score'' as data20_score
  ,picked_result_params[21]->''result_value''->>''name'' as data21_name
  ,picked_result_params[21]->''result_value''->>''score'' as data21_score
  ,picked_result_params[22]->''result_value''->>''name'' as data22_name
  ,picked_result_params[22]->''result_value''->>''score'' as data22_score
  ,picked_result_params[23]->''result_value''->>''name'' as data23_name
  ,picked_result_params[23]->''result_value''->>''score'' as data23_score
  ,picked_result_params[24]->''result_value''->>''name'' as data24_name
  ,picked_result_params[24]->''result_value''->>''score'' as data24_score
  ,picked_result_params[25]->''result_value''->>''name'' as data25_name
  ,picked_result_params[25]->''result_value''->>''score'' as data25_score
  ,picked_result_params[26]->''result_value''->>''name'' as data26_name
  ,picked_result_params[26]->''result_value''->>''score'' as data26_score
  ,picked_result_params[27]->''result_value''->>''name'' as data27_name
  ,picked_result_params[27]->''result_value''->>''score'' as data27_score
  ,picked_result_params[28]->''result_value''->>''name'' as data28_name
  ,picked_result_params[28]->''result_value''->>''score'' as data28_score
  ,picked_result_params[29]->''result_value''->>''name'' as data29_name
  ,picked_result_params[29]->''result_value''->>''score'' as data29_score
  ,picked_result_params[30]->''result_value''->>''name'' as data30_name
  ,picked_result_params[30]->''result_value''->>''score'' as data30_score
from
  pe_array_agg
  inner join pe_basicinfo on pe_array_agg.pat_event_cd = pe_basicinfo.pat_event_cd
ORDER BY event_start_date, reg_date
;', 2, '[{"preview": "2020/03/26", "can_calc": "0", "data_code": "event_start_date", "data_name": "イベント開始日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "event_start_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "event_end_date", "data_name": "イベント終了日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "event_end_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "起票者", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "reg_staff_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/25", "can_calc": "0", "data_code": "reg_date", "data_name": "起票日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "reg_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師２", "can_calc": "0", "data_code": "up_staff_name", "data_name": "最終編集者", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "up_staff_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "up_date", "data_name": "最終編集日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "up_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data1_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data2_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data3_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data4_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data5_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data6_field_name", "data_name": "データ6 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data6_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data7_field_name", "data_name": "データ7 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data7_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data8_field_name", "data_name": "データ8 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data8_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data9_field_name", "data_name": "データ9 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data9_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data10_field_name", "data_name": "データ10 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data10_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data11_field_name", "data_name": "データ11 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data11_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data12_field_name", "data_name": "データ12 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data12_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data13_field_name", "data_name": "データ13 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data13_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data14_field_name", "data_name": "データ14 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data14_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data15_field_name", "data_name": "データ15 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data15_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data16_field_name", "data_name": "データ16 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data16_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data17_field_name", "data_name": "データ17 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data17_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data18_field_name", "data_name": "データ18 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data18_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data19_field_name", "data_name": "データ19 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data19_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data20_field_name", "data_name": "データ20 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data20_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data21_field_name", "data_name": "データ21 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data21_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data22_field_name", "data_name": "データ22 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data22_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data23_field_name", "data_name": "データ23 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data23_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data24_field_name", "data_name": "データ24 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data24_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data25_field_name", "data_name": "データ25 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data25_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data26_field_name", "data_name": "データ26 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data26_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data27_field_name", "data_name": "データ27 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data27_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data28_field_name", "data_name": "データ28 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data28_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data29_field_name", "data_name": "データ29 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data29_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択患者イベント(リスト)", "can_calc": "0", "data_code": "data30_field_name", "data_name": "データ30 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data30_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data1_name", "data_name": "データ1 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data1_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data1_score", "data_name": "データ1 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data1_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data2_name", "data_name": "データ2 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data2_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data2_score", "data_name": "データ2 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data2_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data3_name", "data_name": "データ3 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data3_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data3_score", "data_name": "データ3 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data3_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data4_name", "data_name": "データ4 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data4_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data4_score", "data_name": "データ4 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data4_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data5_name", "data_name": "データ5 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data5_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data5_score", "data_name": "データ5 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data5_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data6_name", "data_name": "データ6 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data6_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data6_score", "data_name": "データ6 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data6_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data7_name", "data_name": "データ7 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data7_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data7_score", "data_name": "データ7 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data7_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data8_name", "data_name": "データ8 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data8_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data8_score", "data_name": "データ8 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data8_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data9_name", "data_name": "データ9 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data9_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data9_score", "data_name": "データ9 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data9_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data10_name", "data_name": "データ10 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data10_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data10_score", "data_name": "データ10 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data10_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data11_name", "data_name": "データ11 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data11_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data11_score", "data_name": "データ11 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data11_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data12_name", "data_name": "データ12 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data12_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data12_score", "data_name": "データ12 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data12_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data13_name", "data_name": "データ13 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data13_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data13_score", "data_name": "データ13 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data13_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data14_name", "data_name": "データ14 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data14_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data14_score", "data_name": "データ14 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data14_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data15_name", "data_name": "データ15 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data15_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data15_score", "data_name": "データ15 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data15_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data16_name", "data_name": "データ16 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data16_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data16_score", "data_name": "データ16 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data16_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data17_name", "data_name": "データ17 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data17_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data17_score", "data_name": "データ17 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data17_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data18_name", "data_name": "データ18 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data18_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data18_score", "data_name": "データ18 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data18_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data19_name", "data_name": "データ19 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data19_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data19_score", "data_name": "データ19 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data19_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data20_name", "data_name": "データ20 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data20_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data20_score", "data_name": "データ20 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data20_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data21_name", "data_name": "データ21 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data21_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data21_score", "data_name": "データ21 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data21_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data22_name", "data_name": "データ22 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data22_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data22_score", "data_name": "データ22 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data22_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data23_name", "data_name": "データ23 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data23_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data23_score", "data_name": "データ23 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data23_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data24_name", "data_name": "データ24 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data24_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data24_score", "data_name": "データ24 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data24_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data25_name", "data_name": "データ25 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data25_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data25_score", "data_name": "データ25 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data25_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data26_name", "data_name": "データ26 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data26_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data26_score", "data_name": "データ26 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data26_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data27_name", "data_name": "データ27 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data27_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data27_score", "data_name": "データ27 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data27_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data28_name", "data_name": "データ28 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data28_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data28_score", "data_name": "データ28 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data28_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data29_name", "data_name": "データ29 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data29_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data29_score", "data_name": "データ29 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data29_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(リスト)の項目", "can_calc": "0", "data_code": "data30_name", "data_name": "データ30 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data30_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data30_score", "data_name": "データ30 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(リスト)", "field_name": "data30_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '患者情報：患者イベント リスト　@patId @fromDate @toDate使用', '2021-08-26 13:50:14', CURRENT_TIMESTAMP, NULL);


DELETE FROM "ntss"."sys_data_set" where sql_cd in (88);

INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (88, 'with input_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,input_param
  from
    pat_event
    cross join lateral jsonb_array_elements(input_params) with ordinality as tmp(input_param, json_idx)
  where
    is_del = ''0''
    and input_params != ''null''
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
)
, result_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,result_param
  from
    pat_event
    cross join lateral jsonb_array_elements(result_params) with ordinality as tmp(result_param, json_idx)
  where
    is_del = ''0''
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
)
, pe_basicinfo as
(
  select
    pat_event_cd
    ,event_start_date
    ,event_end_date
    ,event_start_time
    ,event_end_time
    ,category_name
    ,sub_category_cd
    ,sub_category_name
    ,reg_staff_info->>''reg_staff_name'' as reg_staff_name
    ,reg_date
    ,up_staff_info->>''up_staff_name'' as up_staff_name
    ,up_date
  from
    pat_event
  where
    is_del = ''0''
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
)
, pe_picked as
(
  select
    ipe.pat_event_cd
    ,ipe.json_idx
    ,input_param
    ,result_param
  from
    input_params_expand as ipe
    inner join result_params_expand as rpe
      on ipe.pat_event_cd = rpe.pat_event_cd and ipe.json_idx = rpe.json_idx
  where
    input_param->>''format_class'' = ''4''
)
, pe_array_agg as
(
  select
    pat_event_cd
    ,array_agg(input_param order by json_idx) as picked_input_params
    ,array_agg(result_param order by json_idx) as picked_result_params
  from
    pe_picked
  group by pat_event_cd
)

select
  pe_array_agg.pat_event_cd
  ,to_timestamp(event_start_date||
    case when event_start_time is null then ''0000''
         else event_start_time
    end, ''yyyyMMDDHH24mi'') AS event_start_date
  ,to_timestamp(event_end_date||
    case when event_end_time is null then ''0000''
         else event_end_time
    end, ''yyyyMMDDHH24mi'') AS event_end_date
  ,category_name
  ,pe_basicinfo.sub_category_cd
  ,pe_basicinfo.sub_category_name
  ,reg_staff_name
  ,pe_basicinfo.reg_date
  ,up_staff_name
  ,pe_basicinfo.up_date
  
  ,picked_input_params[1]->>''field_name'' as data1_field_name
  ,picked_input_params[2]->>''field_name'' as data2_field_name
  ,picked_input_params[3]->>''field_name'' as data3_field_name
  ,picked_input_params[4]->>''field_name'' as data4_field_name
  ,picked_input_params[5]->>''field_name'' as data5_field_name
  ,picked_input_params[6]->>''field_name'' as data6_field_name
  ,picked_input_params[7]->>''field_name'' as data7_field_name
  ,picked_input_params[8]->>''field_name'' as data8_field_name
  ,picked_input_params[9]->>''field_name'' as data9_field_name
  ,picked_input_params[10]->>''field_name'' as data10_field_name
  ,picked_input_params[11]->>''field_name'' as data11_field_name
  ,picked_input_params[12]->>''field_name'' as data12_field_name
  ,picked_input_params[13]->>''field_name'' as data13_field_name
  ,picked_input_params[14]->>''field_name'' as data14_field_name
  ,picked_input_params[15]->>''field_name'' as data15_field_name
  ,picked_input_params[16]->>''field_name'' as data16_field_name
  ,picked_input_params[17]->>''field_name'' as data17_field_name
  ,picked_input_params[18]->>''field_name'' as data18_field_name
  ,picked_input_params[19]->>''field_name'' as data19_field_name
  ,picked_input_params[20]->>''field_name'' as data20_field_name
  ,picked_input_params[21]->>''field_name'' as data21_field_name
  ,picked_input_params[22]->>''field_name'' as data22_field_name
  ,picked_input_params[23]->>''field_name'' as data23_field_name
  ,picked_input_params[24]->>''field_name'' as data24_field_name
  ,picked_input_params[25]->>''field_name'' as data25_field_name
  ,picked_input_params[26]->>''field_name'' as data26_field_name
  ,picked_input_params[27]->>''field_name'' as data27_field_name
  ,picked_input_params[28]->>''field_name'' as data28_field_name
  ,picked_input_params[29]->>''field_name'' as data29_field_name
  ,picked_input_params[30]->>''field_name'' as data30_field_name

  ,picked_result_params[1]->''result_value''->>''name'' as data1_name
  ,picked_result_params[1]->''result_value''->>''score'' as data1_score
  ,picked_result_params[2]->''result_value''->>''name'' as data2_name
  ,picked_result_params[2]->''result_value''->>''score'' as data2_score
  ,picked_result_params[3]->''result_value''->>''name'' as data3_name
  ,picked_result_params[3]->''result_value''->>''score'' as data3_score
  ,picked_result_params[4]->''result_value''->>''name'' as data4_name
  ,picked_result_params[4]->''result_value''->>''score'' as data4_score
  ,picked_result_params[5]->''result_value''->>''name'' as data5_name
  ,picked_result_params[5]->''result_value''->>''score'' as data5_score
  ,picked_result_params[6]->''result_value''->>''name'' as data6_name
  ,picked_result_params[6]->''result_value''->>''score'' as data6_score
  ,picked_result_params[7]->''result_value''->>''name'' as data7_name
  ,picked_result_params[7]->''result_value''->>''score'' as data7_score
  ,picked_result_params[8]->''result_value''->>''name'' as data8_name
  ,picked_result_params[8]->''result_value''->>''score'' as data8_score
  ,picked_result_params[9]->''result_value''->>''name'' as data9_name
  ,picked_result_params[9]->''result_value''->>''score'' as data9_score
  ,picked_result_params[10]->''result_value''->>''name'' as data10_name
  ,picked_result_params[10]->''result_value''->>''score'' as data10_score
  ,picked_result_params[11]->''result_value''->>''name'' as data11_name
  ,picked_result_params[11]->''result_value''->>''score'' as data11_score
  ,picked_result_params[12]->''result_value''->>''name'' as data12_name
  ,picked_result_params[12]->''result_value''->>''score'' as data12_score
  ,picked_result_params[13]->''result_value''->>''name'' as data13_name
  ,picked_result_params[13]->''result_value''->>''score'' as data13_score
  ,picked_result_params[14]->''result_value''->>''name'' as data14_name
  ,picked_result_params[14]->''result_value''->>''score'' as data14_score
  ,picked_result_params[15]->''result_value''->>''name'' as data15_name
  ,picked_result_params[15]->''result_value''->>''score'' as data15_score
  ,picked_result_params[16]->''result_value''->>''name'' as data16_name
  ,picked_result_params[16]->''result_value''->>''score'' as data16_score
  ,picked_result_params[17]->''result_value''->>''name'' as data17_name
  ,picked_result_params[17]->''result_value''->>''score'' as data17_score
  ,picked_result_params[18]->''result_value''->>''name'' as data18_name
  ,picked_result_params[18]->''result_value''->>''score'' as data18_score
  ,picked_result_params[19]->''result_value''->>''name'' as data19_name
  ,picked_result_params[19]->''result_value''->>''score'' as data19_score
  ,picked_result_params[20]->''result_value''->>''name'' as data20_name
  ,picked_result_params[20]->''result_value''->>''score'' as data20_score
  ,picked_result_params[21]->''result_value''->>''name'' as data21_name
  ,picked_result_params[21]->''result_value''->>''score'' as data21_score
  ,picked_result_params[22]->''result_value''->>''name'' as data22_name
  ,picked_result_params[22]->''result_value''->>''score'' as data22_score
  ,picked_result_params[23]->''result_value''->>''name'' as data23_name
  ,picked_result_params[23]->''result_value''->>''score'' as data23_score
  ,picked_result_params[24]->''result_value''->>''name'' as data24_name
  ,picked_result_params[24]->''result_value''->>''score'' as data24_score
  ,picked_result_params[25]->''result_value''->>''name'' as data25_name
  ,picked_result_params[25]->''result_value''->>''score'' as data25_score
  ,picked_result_params[26]->''result_value''->>''name'' as data26_name
  ,picked_result_params[26]->''result_value''->>''score'' as data26_score
  ,picked_result_params[27]->''result_value''->>''name'' as data27_name
  ,picked_result_params[27]->''result_value''->>''score'' as data27_score
  ,picked_result_params[28]->''result_value''->>''name'' as data28_name
  ,picked_result_params[28]->''result_value''->>''score'' as data28_score
  ,picked_result_params[29]->''result_value''->>''name'' as data29_name
  ,picked_result_params[29]->''result_value''->>''score'' as data29_score
  ,picked_result_params[30]->''result_value''->>''name'' as data30_name
  ,picked_result_params[30]->''result_value''->>''score'' as data30_score
from
  pe_array_agg
  inner join pe_basicinfo on pe_array_agg.pat_event_cd = pe_basicinfo.pat_event_cd
ORDER BY event_start_date, reg_date
;', 2, '[{"preview": "2020/03/26", "can_calc": "0", "data_code": "event_start_date", "data_name": "イベント開始日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "event_start_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "event_end_date", "data_name": "イベント終了日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "event_end_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "起票者", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "reg_staff_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/25", "can_calc": "0", "data_code": "reg_date", "data_name": "起票日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "reg_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師２", "can_calc": "0", "data_code": "up_staff_name", "data_name": "最終編集者", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "up_staff_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "up_date", "data_name": "最終編集日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "up_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data1_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data2_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data3_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data4_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data5_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data6_field_name", "data_name": "データ6 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data6_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data7_field_name", "data_name": "データ7 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data7_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data8_field_name", "data_name": "データ8 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data8_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data9_field_name", "data_name": "データ9 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data9_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data10_field_name", "data_name": "データ10 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data10_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data11_field_name", "data_name": "データ11 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data11_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data12_field_name", "data_name": "データ12 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data12_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data13_field_name", "data_name": "データ13 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data13_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data14_field_name", "data_name": "データ14 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data14_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data15_field_name", "data_name": "データ15 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data15_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data16_field_name", "data_name": "データ16 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data16_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data17_field_name", "data_name": "データ17 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data17_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data18_field_name", "data_name": "データ18 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data18_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data19_field_name", "data_name": "データ19 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data19_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data20_field_name", "data_name": "データ20 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data20_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data21_field_name", "data_name": "データ21 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data21_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data22_field_name", "data_name": "データ22 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data22_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data23_field_name", "data_name": "データ23 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data23_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data24_field_name", "data_name": "データ24 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data24_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data25_field_name", "data_name": "データ25 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data25_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data26_field_name", "data_name": "データ26 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data26_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data27_field_name", "data_name": "データ27 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data27_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data28_field_name", "data_name": "データ28 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data28_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data29_field_name", "data_name": "データ29 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data29_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "選択内容", "can_calc": "0", "data_code": "data30_field_name", "data_name": "データ30 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data30_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data1_name", "data_name": "データ1 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data1_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data1_score", "data_name": "データ1 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data1_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data2_name", "data_name": "データ2 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data2_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data2_score", "data_name": "データ2 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data2_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data3_name", "data_name": "データ3 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data3_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data3_score", "data_name": "データ3 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data3_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data4_name", "data_name": "データ4 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data4_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data4_score", "data_name": "データ4 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data4_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data5_name", "data_name": "データ5 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data5_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data5_score", "data_name": "データ5 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data5_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data6_name", "data_name": "データ6 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data6_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data6_score", "data_name": "データ6 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data6_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data7_name", "data_name": "データ7 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data7_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data7_score", "data_name": "データ7 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data7_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data8_name", "data_name": "データ8 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data8_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data8_score", "data_name": "データ8 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data8_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data9_name", "data_name": "データ9 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data9_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data9_score", "data_name": "データ9 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data9_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data10_name", "data_name": "データ10 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data10_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data10_score", "data_name": "データ10 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data10_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data11_name", "data_name": "データ11 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data11_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data11_score", "data_name": "データ11 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data11_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data12_name", "data_name": "データ12 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data12_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data12_score", "data_name": "データ12 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data12_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data13_name", "data_name": "データ13 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data13_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data13_score", "data_name": "データ13 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data13_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data14_name", "data_name": "データ14 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data14_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data14_score", "data_name": "データ14 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data14_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data15_name", "data_name": "データ15 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data15_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data15_score", "data_name": "データ15 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data15_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data16_name", "data_name": "データ16 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data16_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data16_score", "data_name": "データ16 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data16_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data17_name", "data_name": "データ17 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data17_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data17_score", "data_name": "データ17 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data17_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data18_name", "data_name": "データ18 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data18_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data18_score", "data_name": "データ18 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data18_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data19_name", "data_name": "データ19 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data19_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data19_score", "data_name": "データ19 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data19_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data20_name", "data_name": "データ20 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data20_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data20_score", "data_name": "データ20 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data20_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data21_name", "data_name": "データ21 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data21_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data21_score", "data_name": "データ21 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data21_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data22_name", "data_name": "データ22 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data22_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data22_score", "data_name": "データ22 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data22_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data23_name", "data_name": "データ23 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data23_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data23_score", "data_name": "データ23 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data23_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data24_name", "data_name": "データ24 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data24_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data24_score", "data_name": "データ24 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data24_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data25_name", "data_name": "データ25 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data25_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data25_score", "data_name": "データ25 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data25_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data26_name", "data_name": "データ26 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data26_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data26_score", "data_name": "データ26 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data26_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data27_name", "data_name": "データ27 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data27_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data27_score", "data_name": "データ27 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data27_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data28_name", "data_name": "データ28 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data28_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data28_score", "data_name": "データ28 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data28_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data29_name", "data_name": "データ29 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data29_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data29_score", "data_name": "データ29 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data29_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(ラジオボタン)の項目", "can_calc": "0", "data_code": "data30_name", "data_name": "データ30 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data30_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "data30_score", "data_name": "データ30 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(ラジオボタン)", "field_name": "data30_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '患者情報：患者イベント ラジオボタン　@patId @fromDate @toDate使用', '2021-08-26 13:50:14', CURRENT_TIMESTAMP, NULL);



DELETE FROM "ntss"."sys_data_set" where sql_cd in (89);

INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (89, 'with input_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,input_param
  from
    pat_event
    cross join lateral jsonb_array_elements(input_params) with ordinality as tmp(input_param, json_idx)
  where
    is_del = ''0''
    and input_params != ''null''
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
)
, result_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,result_param
  from
    pat_event
    cross join lateral jsonb_array_elements(result_params) with ordinality as tmp(result_param, json_idx)
  where
    is_del = ''0''
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
)
, pe_basicinfo as
(
  select
    pat_event_cd
    ,event_start_date
    ,event_end_date
    ,event_start_time
    ,event_end_time
    ,category_name
    ,sub_category_cd
    ,sub_category_name
    ,reg_staff_info->>''reg_staff_name'' as reg_staff_name
    ,reg_date
    ,up_staff_info->>''up_staff_name'' as up_staff_name
    ,up_date
  from
    pat_event
  where
    is_del = ''0''
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
)
, pe_picked as
(
  select
    ipe.pat_event_cd
    ,ipe.json_idx
    ,input_param
    ,result_param
  from
    input_params_expand as ipe
    inner join result_params_expand as rpe
      on ipe.pat_event_cd = rpe.pat_event_cd and ipe.json_idx = rpe.json_idx
  where
    input_param->>''format_class'' = ''5''
)
, pe_array_agg as
(
  select
    pat_event_cd
    ,array_agg(input_param order by json_idx) as picked_input_params
    ,array_agg(result_param order by json_idx) as picked_result_params
  from
    pe_picked
  group by pat_event_cd
)

select
  pe_array_agg.pat_event_cd
  ,to_timestamp(event_start_date||
    case when event_start_time is null then ''0000''
         else event_start_time
    end, ''yyyyMMDDHH24mi'') AS event_start_date
  ,to_timestamp(event_end_date||
    case when event_end_time is null then ''0000''
         else event_end_time
    end, ''yyyyMMDDHH24mi'') AS event_end_date
  ,category_name
  ,pe_basicinfo.sub_category_cd
  ,pe_basicinfo.sub_category_name
  ,reg_staff_name
  ,pe_basicinfo.reg_date
  ,up_staff_name
  ,pe_basicinfo.up_date
  
  ,picked_input_params[1]->>''field_name'' as data1_field_name
  ,picked_input_params[2]->>''field_name'' as data2_field_name
  ,picked_input_params[3]->>''field_name'' as data3_field_name
  ,picked_input_params[4]->>''field_name'' as data4_field_name
  ,picked_input_params[5]->>''field_name'' as data5_field_name
  ,picked_input_params[6]->>''field_name'' as data6_field_name
  ,picked_input_params[7]->>''field_name'' as data7_field_name
  ,picked_input_params[8]->>''field_name'' as data8_field_name
  ,picked_input_params[9]->>''field_name'' as data9_field_name
  ,picked_input_params[10]->>''field_name'' as data10_field_name

  ,picked_result_params[1]->>''result_value'' as data1
  ,picked_result_params[2]->>''result_value'' as data2
  ,picked_result_params[3]->>''result_value'' as data3
  ,picked_result_params[4]->>''result_value'' as data4
  ,picked_result_params[5]->>''result_value'' as data5
  ,picked_result_params[6]->>''result_value'' as data6
  ,picked_result_params[7]->>''result_value'' as data7
  ,picked_result_params[8]->>''result_value'' as data8
  ,picked_result_params[9]->>''result_value'' as data9
  ,picked_result_params[10]->>''result_value'' as data10
from
  pe_array_agg
  inner join pe_basicinfo on pe_array_agg.pat_event_cd = pe_basicinfo.pat_event_cd
;', 2, '[{"preview": "2020/03/26", "can_calc": "0", "data_code": "event_start_date", "data_name": "イベント開始日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "event_start_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "event_end_date", "data_name": "イベント終了日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "event_end_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "起票者", "data_type": "string", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "reg_staff_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/25", "can_calc": "0", "data_code": "reg_date", "data_name": "起票日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "reg_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師２", "can_calc": "0", "data_code": "up_staff_name", "data_name": "最終編集者", "data_type": "string", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "up_staff_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "up_date", "data_name": "最終編集日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "up_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施患者イベント(日付)", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data1_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施患者イベント(日付)", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data2_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施患者イベント(日付)", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data3_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施患者イベント(日付)", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data4_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施患者イベント(日付)", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data5_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施患者イベント(日付)", "can_calc": "0", "data_code": "data6_field_name", "data_name": "データ6 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data6_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施患者イベント(日付)", "can_calc": "0", "data_code": "data7_field_name", "data_name": "データ7 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data7_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施患者イベント(日付)", "can_calc": "0", "data_code": "data8_field_name", "data_name": "データ8 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data8_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施患者イベント(日付)", "can_calc": "0", "data_code": "data9_field_name", "data_name": "データ9 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data9_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "実施患者イベント(日付)", "can_calc": "0", "data_code": "data10_field_name", "data_name": "データ10 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data10_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-03-27", "can_calc": "0", "data_code": "data1", "data_name": "データ1", "data_type": "string", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data1", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-03-27", "can_calc": "0", "data_code": "data2", "data_name": "データ2", "data_type": "string", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data2", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-03-27", "can_calc": "0", "data_code": "data3", "data_name": "データ3", "data_type": "string", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data3", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-03-27", "can_calc": "0", "data_code": "data4", "data_name": "データ4", "data_type": "string", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data4", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-03-27", "can_calc": "0", "data_code": "data5", "data_name": "データ5", "data_type": "string", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data5", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-03-27", "can_calc": "0", "data_code": "data6", "data_name": "データ6", "data_type": "string", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data6", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-03-27", "can_calc": "0", "data_code": "data7", "data_name": "データ7", "data_type": "string", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data7", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-03-27", "can_calc": "0", "data_code": "data8", "data_name": "データ8", "data_type": "string", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data8", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-03-27", "can_calc": "0", "data_code": "data9", "data_name": "データ9", "data_type": "string", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data9", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-03-27", "can_calc": "0", "data_code": "data10", "data_name": "データ10", "data_type": "string", "conv_table": [], "data_class": "患者イベント(日付)", "field_name": "data10", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '患者情報：患者イベント 日付　@patId @fromDate @toDate使用', '2021-08-26 13:50:14',CURRENT_TIMESTAMP, NULL);


DELETE FROM "ntss"."sys_data_set" where sql_cd in (90);

INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (90, 'with input_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,input_param
  from
    pat_event
    cross join lateral jsonb_array_elements(input_params) with ordinality as tmp(input_param, json_idx)
  where
    is_del = ''0''
    and input_params != ''null''
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
)
, result_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,result_param
  from
    pat_event
    cross join lateral jsonb_array_elements(result_params) with ordinality as tmp(result_param, json_idx)
  where
    is_del = ''0''
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
)
, pe_basicinfo as
(
  select
    pat_event_cd
    ,event_start_date
    ,event_end_date
    ,event_start_time
    ,event_end_time
    ,category_name
    ,sub_category_cd
    ,sub_category_name
    ,reg_staff_info->>''reg_staff_name'' as reg_staff_name
    ,reg_date
    ,up_staff_info->>''up_staff_name'' as up_staff_name
    ,up_date
  from
    pat_event
  where
    is_del = ''0''
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
)
, pe_picked as
(
  select
    ipe.pat_event_cd
    ,ipe.json_idx
    ,input_param
    ,result_param
  from
    input_params_expand as ipe
    inner join result_params_expand as rpe
      on ipe.pat_event_cd = rpe.pat_event_cd and ipe.json_idx = rpe.json_idx
  where
    input_param->>''format_class'' = ''6''
)
, pe_array_agg as
(
  select
    pat_event_cd
    ,array_agg(input_param order by json_idx) as picked_input_params
    ,array_agg(result_param order by json_idx) as picked_result_params
  from
    pe_picked
  group by pat_event_cd
)

select
  pe_array_agg.pat_event_cd
  ,to_timestamp(event_start_date||
    case when event_start_time is null then ''0000''
         else event_start_time
    end, ''yyyyMMDDHH24mi'') AS event_start_date
  ,to_timestamp(event_end_date||
    case when event_end_time is null then ''0000''
         else event_end_time
    end, ''yyyyMMDDHH24mi'') AS event_end_date
  ,category_name
  ,pe_basicinfo.sub_category_cd
  ,pe_basicinfo.sub_category_name
  ,reg_staff_name
  ,pe_basicinfo.reg_date
  ,up_staff_name
  ,pe_basicinfo.up_date
  
  ,picked_input_params[1]->>''field_name'' as data1_field_name
  ,picked_input_params[2]->>''field_name'' as data2_field_name
  ,picked_input_params[3]->>''field_name'' as data3_field_name
  ,picked_input_params[4]->>''field_name'' as data4_field_name
  ,picked_input_params[5]->>''field_name'' as data5_field_name
  ,picked_input_params[6]->>''field_name'' as data6_field_name
  ,picked_input_params[7]->>''field_name'' as data7_field_name
  ,picked_input_params[8]->>''field_name'' as data8_field_name
  ,picked_input_params[9]->>''field_name'' as data9_field_name
  ,picked_input_params[10]->>''field_name'' as data10_field_name
  ,picked_input_params[11]->>''field_name'' as data11_field_name
  ,picked_input_params[12]->>''field_name'' as data12_field_name
  ,picked_input_params[13]->>''field_name'' as data13_field_name
  ,picked_input_params[14]->>''field_name'' as data14_field_name
  ,picked_input_params[15]->>''field_name'' as data15_field_name
  ,picked_input_params[16]->>''field_name'' as data16_field_name
  ,picked_input_params[17]->>''field_name'' as data17_field_name
  ,picked_input_params[18]->>''field_name'' as data18_field_name
  ,picked_input_params[19]->>''field_name'' as data19_field_name
  ,picked_input_params[20]->>''field_name'' as data20_field_name
  ,picked_input_params[21]->>''field_name'' as data21_field_name
  ,picked_input_params[22]->>''field_name'' as data22_field_name
  ,picked_input_params[23]->>''field_name'' as data23_field_name
  ,picked_input_params[24]->>''field_name'' as data24_field_name
  ,picked_input_params[25]->>''field_name'' as data25_field_name
  ,picked_input_params[26]->>''field_name'' as data26_field_name
  ,picked_input_params[27]->>''field_name'' as data27_field_name
  ,picked_input_params[28]->>''field_name'' as data28_field_name
  ,picked_input_params[29]->>''field_name'' as data29_field_name
  ,picked_input_params[30]->>''field_name'' as data30_field_name

  ,trim
  (trailing '', '' from
    coalesce((picked_result_params[1]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->19)->>''name'', '''')
  ) as data1_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[1]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[1]->''result_value''->19)->>''score'', '''')
  ) as data1_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[2]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->19)->>''name'', '''')
  ) as data2_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[2]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[2]->''result_value''->19)->>''score'', '''')
  ) as data2_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[3]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->19)->>''name'', '''')
  ) as data3_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[3]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[3]->''result_value''->19)->>''score'', '''')
  ) as data3_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[4]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->19)->>''name'', '''')
  ) as data4_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[4]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[4]->''result_value''->19)->>''score'', '''')
  ) as data4_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[5]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->19)->>''name'', '''')
  ) as data5_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[5]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[5]->''result_value''->19)->>''score'', '''')
  ) as data5_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[6]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->19)->>''name'', '''')
  ) as data6_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[6]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[6]->''result_value''->19)->>''score'', '''')
  ) as data6_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[7]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->19)->>''name'', '''')
  ) as data7_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[7]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[7]->''result_value''->19)->>''score'', '''')
  ) as data7_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[8]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->19)->>''name'', '''')
  ) as data8_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[8]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[8]->''result_value''->19)->>''score'', '''')
  ) as data8_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[9]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->19)->>''name'', '''')
  ) as data9_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[9]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[9]->''result_value''->19)->>''score'', '''')
  ) as data9_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[10]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->19)->>''name'', '''')
  ) as data10_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[10]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[10]->''result_value''->19)->>''score'', '''')
  ) as data10_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[11]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->19)->>''name'', '''')
  ) as data11_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[11]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[11]->''result_value''->19)->>''score'', '''')
  ) as data11_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[12]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->19)->>''name'', '''')
  ) as data12_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[12]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[12]->''result_value''->19)->>''score'', '''')
  ) as data12_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[13]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->19)->>''name'', '''')
  ) as data13_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[13]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[13]->''result_value''->19)->>''score'', '''')
  ) as data13_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[14]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->19)->>''name'', '''')
  ) as data14_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[14]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[14]->''result_value''->19)->>''score'', '''')
  ) as data14_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[15]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->19)->>''name'', '''')
  ) as data15_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[15]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[15]->''result_value''->19)->>''score'', '''')
  ) as data15_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[16]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->19)->>''name'', '''')
  ) as data16_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[16]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[16]->''result_value''->19)->>''score'', '''')
  ) as data16_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[17]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->17)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->18)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->19)->>''name'', '''')
  ) as data17_name,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[17]->''result_value''->0)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->1)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->2)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->3)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->4)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->5)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->6)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->7)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->8)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->9)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->10)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->11)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->12)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->13)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->14)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->15)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->16)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->17)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->18)->>''score'', '''') || '', '' ||
    coalesce((picked_result_params[17]->''result_value''->19)->>''score'', '''')
  ) as data17_score,
  trim
  (trailing '', '' from
    coalesce((picked_result_params[18]->''result_value''->0)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->1)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->2)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->3)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->4)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->5)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->6)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->7)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->8)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->9)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->10)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->11)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->12)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->13)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->14)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->15)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_value''->16)->>''name'', '''') || '', '' ||
    coalesce((picked_result_params[18]->''result_v', 2, '[{"preview": "2020/03/26", "can_calc": "0", "data_code": "event_start_date", "data_name": "イベント開始日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "event_start_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "event_end_date", "data_name": "イベント終了日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "event_end_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "起票者", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "reg_staff_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/25", "can_calc": "0", "data_code": "reg_date", "data_name": "起票日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "reg_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師２", "can_calc": "0", "data_code": "up_staff_name", "data_name": "最終編集者", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "up_staff_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "up_date", "data_name": "最終編集日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "up_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data1_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data2_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data3_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data4_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data5_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data6_field_name", "data_name": "データ6 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data6_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data7_field_name", "data_name": "データ7 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data7_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data8_field_name", "data_name": "データ8 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data8_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data9_field_name", "data_name": "データ9 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data9_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data10_field_name", "data_name": "データ10 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data10_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data11_field_name", "data_name": "データ11 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data11_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data12_field_name", "data_name": "データ12 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data12_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data13_field_name", "data_name": "データ13 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data13_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data14_field_name", "data_name": "データ14 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data14_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data15_field_name", "data_name": "データ15 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data15_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data16_field_name", "data_name": "データ16 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data16_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data17_field_name", "data_name": "データ17 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data17_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data18_field_name", "data_name": "データ18 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data18_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data19_field_name", "data_name": "データ19 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data19_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data20_field_name", "data_name": "データ20 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data20_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data21_field_name", "data_name": "データ21 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data21_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data22_field_name", "data_name": "データ22 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data22_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data23_field_name", "data_name": "データ23 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data23_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data24_field_name", "data_name": "データ24 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data24_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data25_field_name", "data_name": "データ25 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data25_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data26_field_name", "data_name": "データ26 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data26_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data27_field_name", "data_name": "データ27 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data27_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data28_field_name", "data_name": "データ28 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data28_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data29_field_name", "data_name": "データ29 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data29_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)内容", "can_calc": "0", "data_code": "data30_field_name", "data_name": "データ30 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data30_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data1_name", "data_name": "データ1 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data1_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data1_score", "data_name": "データ1 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data1_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data2_name", "data_name": "データ2 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data2_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data2_score", "data_name": "データ2 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data2_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data3_name", "data_name": "データ3 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data3_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data3_score", "data_name": "データ3 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data3_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data4_name", "data_name": "データ4 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data4_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data4_score", "data_name": "データ4 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data4_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data5_name", "data_name": "データ5 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data5_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data5_score", "data_name": "データ5 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data5_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data6_name", "data_name": "データ6 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data6_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data6_score", "data_name": "データ6 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data6_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data7_name", "data_name": "データ7 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data7_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data7_score", "data_name": "データ7 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data7_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data8_name", "data_name": "データ8 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data8_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data8_score", "data_name": "データ8 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data8_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data9_name", "data_name": "データ9 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data9_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data9_score", "data_name": "データ9 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data9_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data10_name", "data_name": "データ10 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data10_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data10_score", "data_name": "データ10 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data10_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data11_name", "data_name": "データ11 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data11_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data11_score", "data_name": "データ11 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data11_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data12_name", "data_name": "データ12 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data12_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data12_score", "data_name": "データ12 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data12_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data13_name", "data_name": "データ13 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data13_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data13_score", "data_name": "データ13 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data13_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data14_name", "data_name": "データ14 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data14_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data14_score", "data_name": "データ14 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data14_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data15_name", "data_name": "データ15 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data15_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data15_score", "data_name": "データ15 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data15_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data16_name", "data_name": "データ16 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data16_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data16_score", "data_name": "データ16 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data16_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data17_name", "data_name": "データ17 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data17_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data17_score", "data_name": "データ17 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data17_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data18_name", "data_name": "データ18 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data18_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data18_score", "data_name": "データ18 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data18_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data19_name", "data_name": "データ19 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data19_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data19_score", "data_name": "データ19 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data19_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data20_name", "data_name": "データ20 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data20_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data20_score", "data_name": "データ20 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data20_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data21_name", "data_name": "データ21 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data21_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data21_score", "data_name": "データ21 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data21_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data22_name", "data_name": "データ22 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data22_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data22_score", "data_name": "データ22 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data22_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data23_name", "data_name": "データ23 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data23_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data23_score", "data_name": "データ23 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data23_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data24_name", "data_name": "データ24 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data24_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data24_score", "data_name": "データ24 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data24_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data25_name", "data_name": "データ25 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data25_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data25_score", "data_name": "データ25 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data25_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data26_name", "data_name": "データ26 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data26_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data26_score", "data_name": "データ26 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data26_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data27_name", "data_name": "データ27 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data27_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data27_score", "data_name": "データ27 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data27_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data28_name", "data_name": "データ28 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data28_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data28_score", "data_name": "データ28 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data28_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data29_name", "data_name": "データ29 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data29_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data29_score", "data_name": "データ29 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data29_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(チェック)の項目1, 患者イベント(チェック)の項目3", "can_calc": "0", "data_code": "data30_name", "data_name": "データ30 名前", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data30_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10, 20", "can_calc": "0", "data_code": "data30_score", "data_name": "データ30 スコア", "data_type": "string", "conv_table": [], "data_class": "患者イベント(チェック)", "field_name": "data30_score", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '患者情報：患者イベント チェック　@patId @fromDate @toDate使用', '2021-08-26 13:50:14', CURRENT_TIMESTAMP, NULL);


DELETE FROM "ntss"."sys_data_set" where sql_cd in (91);

INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (91, 'with input_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,input_param
  from
    pat_event
    cross join lateral jsonb_array_elements(input_params) with ordinality as tmp(input_param, json_idx)
  where
    is_del = ''0''
    and input_params != ''null''
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
, result_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,result_param
  from
    pat_event
    cross join lateral jsonb_array_elements(result_params) with ordinality as tmp(result_param, json_idx)
  where
    is_del = ''0''
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
)
, pe_basicinfo as
(
  select
    pat_event_cd
    ,event_start_date
    ,event_end_date
    ,event_start_time
    ,event_end_time
    ,category_name
    ,sub_category_cd
    ,sub_category_name
    ,reg_staff_info->>''reg_staff_name'' as reg_staff_name
    ,reg_date
    ,up_staff_info->>''up_staff_name'' as up_staff_name
    ,up_date
  from
    pat_event
  where
    is_del = ''0''
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
)
, pe_picked as
(
  select
    ipe.pat_event_cd
    ,ipe.json_idx
    ,input_param
    ,result_param
  from
    input_params_expand as ipe
    inner join result_params_expand as rpe
      on ipe.pat_event_cd = rpe.pat_event_cd and ipe.json_idx = rpe.json_idx
  where
    input_param->>''format_class'' = ''7''
)
, pe_array_agg as
(
  select
    pat_event_cd
    ,array_agg(input_param order by json_idx) as picked_input_params
    ,array_agg(result_param order by json_idx) as picked_result_params
  from
    pe_picked
  group by pat_event_cd
)

select
  pe_array_agg.pat_event_cd
  ,to_timestamp(event_start_date||
    case when event_start_time is null then ''0000''
         else event_start_time
    end, ''yyyyMMDDHH24mi'') AS event_start_date
  ,to_timestamp(event_end_date||
    case when event_end_time is null then ''0000''
         else event_end_time
    end, ''yyyyMMDDHH24mi'') AS event_end_date
  ,category_name
  ,pe_basicinfo.sub_category_cd
  ,pe_basicinfo.sub_category_name
  ,reg_staff_name
  ,pe_basicinfo.reg_date
  ,up_staff_name
  ,pe_basicinfo.up_date
  
  ,picked_input_params[1]->>''field_name'' as data1_field_name
  ,picked_input_params[2]->>''field_name'' as data2_field_name
  ,picked_input_params[3]->>''field_name'' as data3_field_name
  ,picked_input_params[4]->>''field_name'' as data4_field_name
  ,picked_input_params[5]->>''field_name'' as data5_field_name

  ,picked_result_params[1]->''result_value''->0->>''file_name'' as data1_file_name1
  ,picked_result_params[1]->''result_value''->0->>''file_path'' as data1_file_path1
  ,picked_result_params[1]->''result_value''->1->>''file_name'' as data1_file_name2
  ,picked_result_params[1]->''result_value''->1->>''file_path'' as data1_file_path2
  ,picked_result_params[1]->''result_value''->2->>''file_name'' as data1_file_name3
  ,picked_result_params[1]->''result_value''->2->>''file_path'' as data1_file_path3
  ,picked_result_params[1]->''result_value''->3->>''file_name'' as data1_file_name4
  ,picked_result_params[1]->''result_value''->3->>''file_path'' as data1_file_path4
  ,picked_result_params[1]->''result_value''->4->>''file_name'' as data1_file_name5
  ,picked_result_params[1]->''result_value''->4->>''file_path'' as data1_file_path5
  ,picked_result_params[1]->''result_value''->5->>''file_name'' as data1_file_name6
  ,picked_result_params[1]->''result_value''->5->>''file_path'' as data1_file_path6
  ,picked_result_params[1]->''result_value''->6->>''file_name'' as data1_file_name7
  ,picked_result_params[1]->''result_value''->6->>''file_path'' as data1_file_path7
  ,picked_result_params[1]->''result_value''->7->>''file_name'' as data1_file_name8
  ,picked_result_params[1]->''result_value''->7->>''file_path'' as data1_file_path8
  ,picked_result_params[1]->''result_value''->8->>''file_name'' as data1_file_name9
  ,picked_result_params[1]->''result_value''->8->>''file_path'' as data1_file_path9
  ,picked_result_params[1]->''result_value''->9->>''file_name'' as data1_file_name10
  ,picked_result_params[1]->''result_value''->9->>''file_path'' as data1_file_path10

  ,picked_result_params[2]->''result_value''->0->>''file_name'' as data2_file_name1
  ,picked_result_params[2]->''result_value''->0->>''file_path'' as data2_file_path1
  ,picked_result_params[2]->''result_value''->1->>''file_name'' as data2_file_name2
  ,picked_result_params[2]->''result_value''->1->>''file_path'' as data2_file_path2
  ,picked_result_params[2]->''result_value''->2->>''file_name'' as data2_file_name3
  ,picked_result_params[2]->''result_value''->2->>''file_path'' as data2_file_path3
  ,picked_result_params[2]->''result_value''->3->>''file_name'' as data2_file_name4
  ,picked_result_params[2]->''result_value''->3->>''file_path'' as data2_file_path4
  ,picked_result_params[2]->''result_value''->4->>''file_name'' as data2_file_name5
  ,picked_result_params[2]->''result_value''->4->>''file_path'' as data2_file_path5
  ,picked_result_params[2]->''result_value''->5->>''file_name'' as data2_file_name6
  ,picked_result_params[2]->''result_value''->5->>''file_path'' as data2_file_path6
  ,picked_result_params[2]->''result_value''->6->>''file_name'' as data2_file_name7
  ,picked_result_params[2]->''result_value''->6->>''file_path'' as data2_file_path7
  ,picked_result_params[2]->''result_value''->7->>''file_name'' as data2_file_name8
  ,picked_result_params[2]->''result_value''->7->>''file_path'' as data2_file_path8
  ,picked_result_params[2]->''result_value''->8->>''file_name'' as data2_file_name9
  ,picked_result_params[2]->''result_value''->8->>''file_path'' as data2_file_path9
  ,picked_result_params[2]->''result_value''->9->>''file_name'' as data2_file_name10
  ,picked_result_params[2]->''result_value''->9->>''file_path'' as data2_file_path10

  ,picked_result_params[3]->''result_value''->0->>''file_name'' as data3_file_name1
  ,picked_result_params[3]->''result_value''->0->>''file_path'' as data3_file_path1
  ,picked_result_params[3]->''result_value''->1->>''file_name'' as data3_file_name2
  ,picked_result_params[3]->''result_value''->1->>''file_path'' as data3_file_path2
  ,picked_result_params[3]->''result_value''->2->>''file_name'' as data3_file_name3
  ,picked_result_params[3]->''result_value''->2->>''file_path'' as data3_file_path3
  ,picked_result_params[3]->''result_value''->3->>''file_name'' as data3_file_name4
  ,picked_result_params[3]->''result_value''->3->>''file_path'' as data3_file_path4
  ,picked_result_params[3]->''result_value''->4->>''file_name'' as data3_file_name5
  ,picked_result_params[3]->''result_value''->4->>''file_path'' as data3_file_path5
  ,picked_result_params[3]->''result_value''->5->>''file_name'' as data3_file_name6
  ,picked_result_params[3]->''result_value''->5->>''file_path'' as data3_file_path6
  ,picked_result_params[3]->''result_value''->6->>''file_name'' as data3_file_name7
  ,picked_result_params[3]->''result_value''->6->>''file_path'' as data3_file_path7
  ,picked_result_params[3]->''result_value''->7->>''file_name'' as data3_file_name8
  ,picked_result_params[3]->''result_value''->7->>''file_path'' as data3_file_path8
  ,picked_result_params[3]->''result_value''->8->>''file_name'' as data3_file_name9
  ,picked_result_params[3]->''result_value''->8->>''file_path'' as data3_file_path9
  ,picked_result_params[3]->''result_value''->9->>''file_name'' as data3_file_name10
  ,picked_result_params[3]->''result_value''->9->>''file_path'' as data3_file_path10

  ,picked_result_params[4]->''result_value''->0->>''file_name'' as data4_file_name1
  ,picked_result_params[4]->''result_value''->0->>''file_path'' as data4_file_path1
  ,picked_result_params[4]->''result_value''->1->>''file_name'' as data4_file_name2
  ,picked_result_params[4]->''result_value''->1->>''file_path'' as data4_file_path2
  ,picked_result_params[4]->''result_value''->2->>''file_name'' as data4_file_name3
  ,picked_result_params[4]->''result_value''->2->>''file_path'' as data4_file_path3
  ,picked_result_params[4]->''result_value''->3->>''file_name'' as data4_file_name4
  ,picked_result_params[4]->''result_value''->3->>''file_path'' as data4_file_path4
  ,picked_result_params[4]->''result_value''->4->>''file_name'' as data4_file_name5
  ,picked_result_params[4]->''result_value''->4->>''file_path'' as data4_file_path5
  ,picked_result_params[4]->''result_value''->5->>''file_name'' as data4_file_name6
  ,picked_result_params[4]->''result_value''->5->>''file_path'' as data4_file_path6
  ,picked_result_params[4]->''result_value''->6->>''file_name'' as data4_file_name7
  ,picked_result_params[4]->''result_value''->6->>''file_path'' as data4_file_path7
  ,picked_result_params[4]->''result_value''->7->>''file_name'' as data4_file_name8
  ,picked_result_params[4]->''result_value''->7->>''file_path'' as data4_file_path8
  ,picked_result_params[4]->''result_value''->8->>''file_name'' as data4_file_name9
  ,picked_result_params[4]->''result_value''->8->>''file_path'' as data4_file_path9
  ,picked_result_params[4]->''result_value''->9->>''file_name'' as data4_file_name10
  ,picked_result_params[4]->''result_value''->9->>''file_path'' as data4_file_path10

  ,picked_result_params[5]->''result_value''->0->>''file_name'' as data5_file_name1
  ,picked_result_params[5]->''result_value''->0->>''file_path'' as data5_file_path1
  ,picked_result_params[5]->''result_value''->1->>''file_name'' as data5_file_name2
  ,picked_result_params[5]->''result_value''->1->>''file_path'' as data5_file_path2
  ,picked_result_params[5]->''result_value''->2->>''file_name'' as data5_file_name3
  ,picked_result_params[5]->''result_value''->2->>''file_path'' as data5_file_path3
  ,picked_result_params[5]->''result_value''->3->>''file_name'' as data5_file_name4
  ,picked_result_params[5]->''result_value''->3->>''file_path'' as data5_file_path4
  ,picked_result_params[5]->''result_value''->4->>''file_name'' as data5_file_name5
  ,picked_result_params[5]->''result_value''->4->>''file_path'' as data5_file_path5
  ,picked_result_params[5]->''result_value''->5->>''file_name'' as data5_file_name6
  ,picked_result_params[5]->''result_value''->5->>''file_path'' as data5_file_path6
  ,picked_result_params[5]->''result_value''->6->>''file_name'' as data5_file_name7
  ,picked_result_params[5]->''result_value''->6->>''file_path'' as data5_file_path7
  ,picked_result_params[5]->''result_value''->7->>''file_name'' as data5_file_name8
  ,picked_result_params[5]->''result_value''->7->>''file_path'' as data5_file_path8
  ,picked_result_params[5]->''result_value''->8->>''file_name'' as data5_file_name9
  ,picked_result_params[5]->''result_value''->8->>''file_path'' as data5_file_path9
  ,picked_result_params[5]->''result_value''->9->>''file_name'' as data5_file_name10
  ,picked_result_params[5]->''result_value''->9->>''file_path'' as data5_file_path10
from
  pe_array_agg
  inner join pe_basicinfo on pe_array_agg.pat_event_cd = pe_basicinfo.pat_event_cd
;', 2, '[{"preview": "2020/03/26", "can_calc": "0", "data_code": "event_start_date", "data_name": "イベント開始日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "event_start_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "event_end_date", "data_name": "イベント終了日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "event_end_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "起票者", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "reg_staff_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/25", "can_calc": "0", "data_code": "reg_date", "data_name": "起票日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "reg_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師２", "can_calc": "0", "data_code": "up_staff_name", "data_name": "最終編集者", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "up_staff_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "up_date", "data_name": "最終編集日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "up_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "関連患者イベント(添付ファイル)", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data1_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "関連患者イベント(添付ファイル)", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data2_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "関連患者イベント(添付ファイル)", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data3_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "関連患者イベント(添付ファイル)", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data4_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "関連患者イベント(添付ファイル)", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data5_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data1_file_name1", "data_name": "データ1 ファイル名1", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data1_file_name1", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data1_file_name2", "data_name": "データ1 ファイル名2", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data1_file_name2", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data1_file_name3", "data_name": "データ1 ファイル名3", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data1_file_name3", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data1_file_name4", "data_name": "データ1 ファイル名4", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data1_file_name4", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data1_file_name5", "data_name": "データ1 ファイル名5", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data1_file_name5", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data1_file_name6", "data_name": "データ1 ファイル名6", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data1_file_name6", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data1_file_name7", "data_name": "データ1 ファイル名7", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data1_file_name7", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data1_file_name8", "data_name": "データ1 ファイル名8", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data1_file_name8", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data1_file_name9", "data_name": "データ1 ファイル名9", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data1_file_name9", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data1_file_name10", "data_name": "データ1 ファイル名10", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data1_file_name10", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data2_file_name1", "data_name": "データ2 ファイル名1", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data2_file_name1", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data2_file_name2", "data_name": "データ2 ファイル名2", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data2_file_name2", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data2_file_name3", "data_name": "データ2 ファイル名3", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data2_file_name3", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data2_file_name4", "data_name": "データ2 ファイル名4", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data2_file_name4", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data2_file_name5", "data_name": "データ2 ファイル名5", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data2_file_name5", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data2_file_name6", "data_name": "データ2 ファイル名6", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data2_file_name6", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data2_file_name7", "data_name": "データ2 ファイル名7", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data2_file_name7", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data2_file_name8", "data_name": "データ2 ファイル名8", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data2_file_name8", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data2_file_name9", "data_name": "データ2 ファイル名9", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data2_file_name9", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data2_file_name10", "data_name": "データ2 ファイル名10", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data2_file_name10", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data3_file_name1", "data_name": "データ3 ファイル名1", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data3_file_name1", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data3_file_name2", "data_name": "データ3 ファイル名2", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data3_file_name2", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data3_file_name3", "data_name": "データ3 ファイル名3", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data3_file_name3", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data3_file_name4", "data_name": "データ3 ファイル名4", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data3_file_name4", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data3_file_name5", "data_name": "データ3 ファイル名5", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data3_file_name5", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data3_file_name6", "data_name": "データ3 ファイル名6", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data3_file_name6", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data3_file_name7", "data_name": "データ3 ファイル名7", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data3_file_name7", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data3_file_name8", "data_name": "データ3 ファイル名8", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data3_file_name8", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data3_file_name9", "data_name": "データ3 ファイル名9", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data3_file_name9", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data3_file_name10", "data_name": "データ3 ファイル名10", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data3_file_name10", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data4_file_name1", "data_name": "データ4 ファイル名1", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data4_file_name1", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data4_file_name2", "data_name": "データ4 ファイル名2", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data4_file_name2", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data4_file_name3", "data_name": "データ4 ファイル名3", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data4_file_name3", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data4_file_name4", "data_name": "データ4 ファイル名4", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data4_file_name4", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data4_file_name5", "data_name": "データ4 ファイル名5", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data4_file_name5", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data4_file_name6", "data_name": "データ4 ファイル名6", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data4_file_name6", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data4_file_name7", "data_name": "データ4 ファイル名7", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data4_file_name7", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data4_file_name8", "data_name": "データ4 ファイル名8", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data4_file_name8", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data4_file_name9", "data_name": "データ4 ファイル名9", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data4_file_name9", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data4_file_name10", "data_name": "データ4 ファイル名10", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data4_file_name10", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data5_file_name1", "data_name": "データ5 ファイル名1", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data5_file_name1", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data5_file_name2", "data_name": "データ5 ファイル名2", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data5_file_name2", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data5_file_name3", "data_name": "データ5 ファイル名3", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data5_file_name3", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data5_file_name4", "data_name": "データ5 ファイル名4", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data5_file_name4", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data5_file_name5", "data_name": "データ5 ファイル名5", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data5_file_name5", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data5_file_name6", "data_name": "データ5 ファイル名6", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data5_file_name6", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data5_file_name7", "data_name": "データ5 ファイル名7", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data5_file_name7", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data5_file_name8", "data_name": "データ5 ファイル名8", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data5_file_name8", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data5_file_name9", "data_name": "データ5 ファイル名9", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data5_file_name9", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "患者イベント(添付ファイル).txt", "can_calc": "0", "data_code": "data5_file_name10", "data_name": "データ5 ファイル名10", "data_type": "string", "conv_table": [], "data_class": "患者イベント(添付ファイル)", "field_name": "data5_file_name10", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '患者情報：患者イベント 添付ファイル　@patId @fromDate @toDate使用', '2021-08-26 13:50:14',CURRENT_TIMESTAMP, NULL);


DELETE FROM "ntss"."sys_data_set" where sql_cd in (92);

INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (92, 'with input_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,input_param
  from
    pat_event
    cross join lateral jsonb_array_elements(input_params) with ordinality as tmp(input_param, json_idx)
  where
    is_del = ''0''
    and input_params != ''null''
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
)
, result_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,result_param
  from
    pat_event
    cross join lateral jsonb_array_elements(result_params) with ordinality as tmp(result_param, json_idx)
  where
    is_del = ''0''
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
)
, pe_basicinfo_plus as
(
  select
    pat_event_cd
    ,event_start_date
    ,event_end_date
    ,event_start_time
    ,event_end_time
    ,category_name
    ,sub_category_cd
    ,sub_category_name
    ,reg_staff_info->>''reg_staff_name'' as reg_staff_name
    ,reg_date
    ,up_staff_info->>''up_staff_name'' as up_staff_name
    ,up_date
    ,score_total
  from
    pat_event
  where
    is_del = ''0''
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
)
, pe_picked as
(
  select
    ipe.pat_event_cd
    ,ipe.json_idx
    ,input_param
    ,result_param
  from
    input_params_expand as ipe
    inner join result_params_expand as rpe
      on ipe.pat_event_cd = rpe.pat_event_cd and ipe.json_idx = rpe.json_idx
  where
    input_param->>''format_class'' = ''8''
)
, pe_array_agg as
(
  select
    pat_event_cd
    ,array_agg(input_param order by json_idx) as picked_input_params
    ,array_agg(result_param order by json_idx) as picked_result_params
  from
    pe_picked
  group by pat_event_cd
)

select
  pe_array_agg.pat_event_cd
  ,to_timestamp(event_start_date||
    case when event_start_time is null then ''0000''
         else event_start_time
    end, ''yyyyMMDDHH24mi'') AS event_start_date
  ,to_timestamp(event_end_date||
    case when event_end_time is null then ''0000''
         else event_end_time
    end, ''yyyyMMDDHH24mi'') AS event_end_date
  ,category_name
  ,pe_basicinfo_plus.sub_category_cd
  ,pe_basicinfo_plus.sub_category_name
  ,reg_staff_name
  ,pe_basicinfo_plus.reg_date
  ,up_staff_name
  ,pe_basicinfo_plus.up_date
  
  ,picked_input_params[1]->>''field_name'' as data1_field_name
  ,picked_input_params[2]->>''field_name'' as data2_field_name
  ,picked_input_params[3]->>''field_name'' as data3_field_name
  ,picked_input_params[4]->>''field_name'' as data4_field_name
  ,picked_input_params[5]->>''field_name'' as data5_field_name
  
  ,rtrim(picked_result_params[1]->''result_value''->>''score'' || '' '' || coalesce(picked_result_params[1]->''result_value''->>''unit'', ''''), '' '') as data1
  ,rtrim(picked_result_params[2]->''result_value''->>''score'' || '' '' || coalesce(picked_result_params[2]->''result_value''->>''unit'', ''''), '' '') as data2
  ,rtrim(picked_result_params[3]->''result_value''->>''score'' || '' '' || coalesce(picked_result_params[3]->''result_value''->>''unit'', ''''), '' '') as data3
  ,rtrim(picked_result_params[4]->''result_value''->>''score'' || '' '' || coalesce(picked_result_params[4]->''result_value''->>''unit'', ''''), '' '') as data4
  ,rtrim(picked_result_params[5]->''result_value''->>''score'' || '' '' || coalesce(picked_result_params[5]->''result_value''->>''unit'', ''''), '' '') as data5
  
  , score_total || '''' as score_total
from
  pe_array_agg
  inner join pe_basicinfo_plus on pe_array_agg.pat_event_cd = pe_basicinfo_plus.pat_event_cd
;', 2, '[{"preview": "2020/03/26", "can_calc": "0", "data_code": "event_start_date", "data_name": "イベント開始日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "event_start_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "event_end_date", "data_name": "イベント終了日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "event_end_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "起票者", "data_type": "string", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "reg_staff_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/25", "can_calc": "0", "data_code": "reg_date", "data_name": "起票日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "reg_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師２", "can_calc": "0", "data_code": "up_staff_name", "data_name": "最終編集者", "data_type": "string", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "up_staff_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "up_date", "data_name": "最終編集日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "up_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "スコア説明", "can_calc": "0", "data_code": "data1_field_name", "data_name": "データ1 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "data1_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "スコア説明", "can_calc": "0", "data_code": "data2_field_name", "data_name": "データ2 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "data2_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "スコア説明", "can_calc": "0", "data_code": "data3_field_name", "data_name": "データ3 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "data3_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "スコア説明", "can_calc": "0", "data_code": "data4_field_name", "data_name": "データ4 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "data4_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "スコア説明", "can_calc": "0", "data_code": "data5_field_name", "data_name": "データ5 フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "data5_field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30 点", "can_calc": "0", "data_code": "data1", "data_name": "データ1", "data_type": "string", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "data1", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30 点", "can_calc": "0", "data_code": "data2", "data_name": "データ2", "data_type": "string", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "data2", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30 点", "can_calc": "0", "data_code": "data3", "data_name": "データ3", "data_type": "string", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "data3", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30 点", "can_calc": "0", "data_code": "data4", "data_name": "データ4", "data_type": "string", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "data4", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30 点", "can_calc": "0", "data_code": "data5", "data_name": "データ5", "data_type": "string", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "data5", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500 点", "can_calc": "0", "data_code": "score_total", "data_name": "スコア合計", "data_type": "string", "conv_table": [], "data_class": "患者イベント(スコア計算)", "field_name": "score_total", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '患者情報：患者イベント スコア計算　@patId @fromDate @toDate使用', '2021-08-26 13:50:14', CURRENT_TIMESTAMP, NULL);


DELETE FROM "ntss"."sys_data_set" where sql_cd in (93);			
			
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (93, 'WITH DATA AS (			
			
with input_params_expand as			
(			
  select			
    pat_event_cd			
    ,json_idx			
    ,input_param			
  from			
    pat_event			
    cross join lateral jsonb_array_elements(input_params) with ordinality as tmp(input_param, json_idx)			
  where			
    is_del = ''0''			
		and input_params != ''null''	
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''			
)			
, result_params_expand as			
(			
  select			
    pat_event_cd			
    ,json_idx			
    ,result_param			
  from			
    pat_event			
    cross join lateral jsonb_array_elements(result_params) with ordinality as tmp(result_param, json_idx)			
  where			
    is_del = ''0''			
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''			
)			
, pe_basicinfo_plus as			
(			
  select			
		pat_event_cd	
    ,pat_event.ord_no			
    ,event_start_date			
    ,event_end_date			
    ,event_start_time			
    ,event_end_time			
    ,category_name			
    ,sub_category_cd			
    ,sub_category_name			
    ,reg_staff_info->>''reg_staff_name'' as reg_staff_name			
    ,pat_event.reg_date			
    ,up_staff_info->>''up_staff_name'' as up_staff_name			
    ,pat_event.up_date			
    ,treat_date			
    ,case			
      when rst_dialysis_state <> ''0'' then rst_kur_name			
      else ind_kur_name			
    end as linked_kur_name			
    ,case			
      when rst_dialysis_state <> ''0'' then rst_bed_name			
      else ind_bed_name			
    end as linked_bed_name			
    ,case			
      when rst_dialysis_state <> ''0'' then rst_treatment_name			
      else ind_treatment_name			
    end as linked_treatment_name			
  from			
    pat_event			
    left outer join (select * from ord_main where is_del = ''0'') as ord_main			
      on pat_event.ord_no = ord_main.ord_no			
  where			
    pat_event.is_del = ''0''			
    and pat_event.pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''			
)			
, pe_picked as			
(			
  select			
    ipe.pat_event_cd			
    ,ipe.json_idx			
    ,input_param			
    ,result_param			
  from			
    input_params_expand as ipe			
    inner join result_params_expand as rpe			
      on ipe.pat_event_cd = rpe.pat_event_cd and ipe.json_idx = rpe.json_idx			
  where			
    input_param->>''format_class'' = ''9''			
)			
, pe_array_agg as			
(			
  select			
    pat_event_cd			
    ,array_agg(input_param order by json_idx) as picked_input_params			
    ,array_agg(result_param order by json_idx) as picked_result_params			
  from			
    pe_picked			
  group by pat_event_cd			
)			
			
select			
  pe_basicinfo_plus.ord_no as ord_no_t			
	,pe_array_agg.pat_event_cd		
  ,to_timestamp(event_start_date||event_start_time, ''yyyyMMDDHH24mi'') AS event_start_date			
  ,to_timestamp(event_end_date||event_end_time, ''yyyyMMDDHH24mi'') AS event_end_date			
  ,category_name			
  ,pe_basicinfo_plus.sub_category_cd			
  ,pe_basicinfo_plus.sub_category_name			
  ,reg_staff_name			
  ,pe_basicinfo_plus.reg_date			
  ,up_staff_name			
  ,pe_basicinfo_plus.up_date			
  ,picked_input_params[1]->>''field_name'' as field_name			
  ,case			
    when treat_date is null then ''治療実績 リンクなし'' else ''治療実績 リンクあり''			
  end as is_linked			
  ,to_char(to_date(treat_date, ''YYYYMMDD''), ''YYYY/MM/DD/'')			
    || ''(''			
    || (array[''日'',''月'',''火'',''水'',''木'',''金'',''土''])[extract(''dow'' from to_date(treat_date, ''YYYYMMDD'')) + 1]			
    || '')'' as linked_treat_date			
  ,case			
    when linked_kur_name is null or linked_kur_name = ''''			
      then kbt.kur_name			
      else linked_kur_name			
    end			
  ,case			
    when linked_bed_name is null or linked_bed_name = ''''			
      then kbt.bed_name			
      else linked_bed_name			
    end			
  ,case			
    when linked_treatment_name is null or linked_treatment_name = ''''			
      then kbt.treatment_name			
      else linked_treatment_name			
    end			
  ,to_char(to_date(treat_date, ''YYYYMMDD''), ''YYYY/MM/DD/'')			
    || ''(''			
    || (array[''日'',''月'',''火'',''水'',''木'',''金'',''土''])[extract(''dow'' from to_date(treat_date, ''YYYYMMDD'')) + 1]			
    || '')'' || '' '' || linked_kur_name || '' '' || linked_bed_name || '' '' || linked_treatment_name as linked_detail			
from			
  pe_array_agg			
  inner join pe_basicinfo_plus on pe_array_agg.pat_event_cd = pe_basicinfo_plus.pat_event_cd			
	left outer join (select		
                       om.ord_no,			
                       mk.kur_name as kur_name,			
                       mb.bed_name as bed_name,			
                       mt.treatment_name as treatment_name			
                     from			
                       ord_main as om			
                       left outer join mst_kur mk on om.ind_kur_cd = mk.kur_cd			
                       left outer join mst_bed mb on om.ind_bed_cd = mb.bed_cd			
                       left outer join mst_treatment mt on om.ind_treatment_cd = mt.treatment_cd			
                     where om.is_del = ''0'') as kbt			
               on pe_basicinfo_plus.ord_no = kbt.ord_no			
			
	),		
time_info AS (			
	WITH b AS (		
    select ord_main.* from ord_main			
     where rst_dialysis_state between ''1'' and ''5''			
     and			
			pat_id in (@patId)
     and			
       treat_date between to_char(date_trunc(''day'', ( @fromDate )::timestamp), ''yyyymmdd'') and to_char(date_trunc(''day'', ( @toDate )::timestamp) + ''1 days - 1 milliseconds'', ''yyyymmdd'')			
			
		 and	
       is_del = ''0''			
	), d AS (		
    select b.ord_no			
    , data_type			
    , MAX(bio_moni_ctl_no) AS bio_moni_ctl_no			
    from b inner join mni_monitor on (b.ord_no = mni_monitor.ord_no)			
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
	b.rst_start_date + e.経過時間  * interval ''1 minute'' AS  ind_end_date,			
	CASE WHEN b.rst_dialysis_state < ''3'' THEN null		
       WHEN f.残り時間_除水完了 > f.残り時間_透析完了 THEN b.rst_start_date + f.予測時間_除水 * interval ''1 minute''			
       ELSE b.rst_start_date + f.予測時間_透析 * interval ''1 minute''			
	END AS ind_end_date_time			
	, b.rst_start_date			
	, b.rst_end_date		
	from  b left JOIN e on b.ord_no=e.ord_no left JOIN f on b.ord_no=f.ord_no		
)			
SELECT			
DATA.ord_no_t as ord_no,			
	*		
FROM			
	DATA		
	LEFT JOIN		
	time_info		
	on		
	DATA.ord_no_t = time_info.ord_no		
;', 2, '[{"preview": "2020/03/26", "can_calc": "0", "data_code": "event_date", "data_name": "イベント開始日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "event_start_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "event_end_date", "data_name": "イベント終了日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "event_end_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リンク情報", "can_calc": "0", "data_code": "field_name", "data_name": "フィールド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "起票者", "data_type": "string", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "reg_staff_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/25", "can_calc": "0", "data_code": "reg_date", "data_name": "起票日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "reg_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師２", "can_calc": "0", "data_code": "up_staff_name", "data_name": "最終編集者", "data_type": "string", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "up_staff_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "up_date", "data_name": "最終編集日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "up_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "治療実績 リンクあり", "can_calc": "0", "data_code": "is_linked", "data_name": "患者イベント(治療実績リンク)有無", "data_type": "string", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "is_linked", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27(金)", "can_calc": "0", "data_code": "linked_treat_date", "data_name": "治療日", "data_type": "string", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "linked_treat_date", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "午前", "can_calc": "0", "data_code": "linked_kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "linked_kur_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "BED-01", "can_calc": "0", "data_code": "linked_bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "linked_bed_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4時間未満HD", "can_calc": "0", "data_code": "linked_treatment_name", "data_name": "治療方法名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "linked_treatment_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27(金) 午前 BED-01 4時間未満HD", "can_calc": "0", "data_code": "linked_detail", "data_name": "治療実績詳細", "data_type": "string", "conv_table": [], "data_class": "患者イベント(治療実績リンク)", "field_name": "linked_detail", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '患者情報：患者イベント 治療実績リンク　@patId @fromDate @toDate使用', '2021-08-26 13:50:14', CURRENT_TIMESTAMP, NULL);			


DELETE FROM "ntss"."sys_data_set" where sql_cd in (94);

INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (94, 'with input_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,input_param
  from
    pat_event
    cross join lateral jsonb_array_elements(input_params) with ordinality as tmp(input_param, json_idx)
  where
    is_del = ''0''
    and input_params != ''null''
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
)
, result_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,result_param
  from
    pat_event
    cross join lateral jsonb_array_elements(result_params) with ordinality as tmp(result_param, json_idx)
  where
    is_del = ''0''
    and pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
)
, pe_basicinfo_plus as
(
  select
    pat_event_cd
    ,pat_event.facility_cd
    ,event_start_date
    ,event_end_date
    ,event_start_time
    ,event_end_time
    ,category_name
    ,sub_category_cd
    ,sub_category_name
    ,reg_staff_info->>''reg_staff_name'' as reg_staff_name
    ,pat_event.reg_date
    ,up_staff_info->>''up_staff_name'' as up_staff_name
    ,pat_event.up_date
    ,notice_start_date
    ,notice_end_date
  from
    pat_event
    left outer join (select * from bbs_info where is_del = ''0'' and is_disp = ''1'') as bbs_info
      on pat_event.bbs_ctl_no = bbs_info.bbs_ctl_no
  where
    pat_event.is_del = ''0''
    and pat_event.pat_id = @patId and cast(event_start_date as date) between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
)
, pe_picked as
(
  select
    ipe.pat_event_cd
    ,ipe.json_idx
    ,input_param
    ,result_param
  from
    input_params_expand as ipe
    inner join result_params_expand as rpe
      on ipe.pat_event_cd = rpe.pat_event_cd and ipe.json_idx = rpe.json_idx
  where
    input_param->>''format_class'' = ''10''
)
, pe_array_agg as
(
  select
    pat_event_cd
    ,array_agg(input_param order by json_idx) as picked_input_params
    ,array_agg(result_param order by json_idx) as picked_result_params
  from
    pe_picked
  group by pat_event_cd
)

select
  pe_array_agg.pat_event_cd
  ,to_timestamp(event_start_date||
    case when event_start_time is null then ''0000''
         else event_start_time
    end, ''yyyyMMDDHH24mi'') AS event_start_date
  ,to_timestamp(event_end_date||
    case when event_end_time is null then ''0000''
         else event_end_time
    end, ''yyyyMMDDHH24mi'') AS event_end_date
  ,category_name
  ,pe_basicinfo_plus.sub_category_cd
  ,pe_basicinfo_plus.sub_category_name
  ,reg_staff_name
  ,pe_basicinfo_plus.reg_date
  ,up_staff_name
  ,pe_basicinfo_plus.up_date
  ,(select mk.kind_name from mst_bbs_kind as mk where mk.kind_no::TEXT = ((picked_input_params[1]->>''item_json'')::jsonb)::jsonb->>''kind_no'' and mk.facility_cd = pe_basicinfo_plus.facility_cd) as field_name
  ,case
    when notice_start_date is null then ''掲示板掲載なし''
    else ''掲示板掲載あり''
  end as is_linked
  ,to_char(to_date(notice_start_date, ''YYYYMMDD''), ''YYYY/MM/DD'') || '' ～ '' || to_char(to_date(notice_end_date, ''YYYYMMDD''), ''YYYY/MM/DD'') as bbs_notice_term
from
  pe_array_agg
  inner join pe_basicinfo_plus on pe_array_agg.pat_event_cd = pe_basicinfo_plus.pat_event_cd
;', 2, '[{"preview": "2020/03/26", "can_calc": "0", "data_code": "event_start_date", "data_name": "イベント開始日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(掲示板リンク)", "field_name": "event_start_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "event_end_date", "data_name": "イベント終了日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(掲示板リンク)", "field_name": "event_end_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "リンク情報", "can_calc": "0", "data_code": "field_name", "data_name": "掲示板カテゴリ名", "data_type": "string", "conv_table": [], "data_class": "患者イベント(掲示板リンク)", "field_name": "field_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師１", "can_calc": "0", "data_code": "reg_staff_name", "data_name": "起票者", "data_type": "string", "conv_table": [], "data_class": "患者イベント(掲示板リンク)", "field_name": "reg_staff_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/25", "can_calc": "0", "data_code": "reg_date", "data_name": "起票日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(掲示板リンク)", "field_name": "reg_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト看護師２", "can_calc": "0", "data_code": "up_staff_name", "data_name": "最終編集者", "data_type": "string", "conv_table": [], "data_class": "患者イベント(掲示板リンク)", "field_name": "up_staff_name", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/26", "can_calc": "0", "data_code": "up_date", "data_name": "最終編集日", "data_type": "DateTime", "conv_table": [], "data_class": "患者イベント(掲示板リンク)", "field_name": "up_date", "disp_format": "yyyy/mm/dd", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "掲示板掲載あり", "can_calc": "0", "data_code": "is_linked", "data_name": "患者イベント(掲示板リンク)有無", "data_type": "string", "conv_table": [], "data_class": "患者イベント(掲示板リンク)", "field_name": "is_linked", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/27～2020/03/28", "can_calc": "0", "data_code": "bbs_notice_term", "data_name": "掲示板掲載期間", "data_type": "string", "conv_table": [], "data_class": "患者イベント(掲示板リンク)", "field_name": "bbs_notice_term", "disp_format": "", "filter_type": "Category", "data_category": "患者イベント", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '患者情報：患者イベント 掲示板リンク @patId @fromDate @toDate 使用', '2021-08-26 13:50:14', CURRENT_TIMESTAMP, NULL);

DELETE FROM "ntss"."sys_data_set" where sql_cd in (174);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (174, 'select
CASE WHEN (monitor_data->>''1'') IS NULL THEN 0 ELSE  (monitor_data->>''1'')::INTEGER END  as mon1 -- 経過時間
,monitor_data->>''2'' as mon2 -- 経過時間（ＥＣＵＭ）
,case when monitor_data->>''3'' is null then ''0'' else monitor_data->>''3'' end as mon3 -- 残り時間（除水完了）
,case when monitor_data->>''4'' is null then ''0'' else monitor_data->>''4'' end as mon4 -- 残り時間（透析完了）
,monitor_data->>''5'' as mon5 -- 除水積算値
,monitor_data->>''6'' as mon6 -- 除水速度
,monitor_data->>''7'' as mon7 -- 血液循環量
,monitor_data->>''8'' as mon8 -- 血流量
,monitor_data->>''9'' as mon9 -- ＩＰ総量
,monitor_data->>''10'' as mon10 -- ＩＰ速度
,monitor_data->>''11'' as mon11 -- 静脈圧
,monitor_data->>''12'' as mon12 -- 透析液圧
,monitor_data->>''13'' as mon13 -- TMP
,monitor_data->>''14'' as mon14 -- ダイアライザ入口圧
,monitor_data->>''15'' as mon15 -- ダイアライザ差圧
,monitor_data->>''16'' as mon16 -- 血液入口～静脈平均圧
,monitor_data->>''17'' as mon17 -- ⊿BV
,monitor_data->>''18'' as mon18 -- バイカーボ濃度
,monitor_data->>''19'' as mon19 -- 透析液濃度
,monitor_data->>''20'' as mon20 -- Ｎａ濃度
,monitor_data->>''21'' as mon21 -- 透析液温度
,monitor_data->>''22'' as mon22 -- 透析液流量
,monitor_data->>''23'' as mon23 -- 漏血量
,monitor_data->>''24'' as mon24 -- 給液圧（上限）
,monitor_data->>''25'' as mon25 -- 給液圧（下限）
,monitor_data->>''26'' as mon26 -- ＵＦＲ
,monitor_data->>''27'' as mon27 -- ＵＦＲ低下率
,monitor_data->>''28'' as mon28 -- 初期ＵＦＲ測定値
,monitor_data->>''29'' as mon29 -- TMP補正値
,monitor_data->>''30'' as mon30 -- 透析運転時間
,monitor_data->>''31'' as mon31 -- 治療モード
,monitor_data->>''32'' as mon32 -- 除水目標値
,monitor_data->>''33'' as mon33 -- 除水速度設定値
,monitor_data->>''34'' as mon34 -- 透析液温度設定値
,monitor_data->>''35'' as mon35 -- 透析液流量設定値
,monitor_data->>''36'' as mon36 -- 血流量設定値
,monitor_data->>''37'' as mon37 -- ＩＰ速度設定
,monitor_data->>''39'' as mon39 -- 静脈圧警報点（上限）
,monitor_data->>''40'' as mon40 -- 静脈圧警報点（下限）
,monitor_data->>''41'' as mon41 -- 透析液圧警報点（上限）
,monitor_data->>''42'' as mon42 -- 透析液圧警報点（下限）
,monitor_data->>''43'' as mon43 -- TMP警報点（上限）
,monitor_data->>''44'' as mon44 -- TMP警報点（下限）
,monitor_data->>''45'' as mon45 -- ダイアライザ入口圧警報点（上限）
,monitor_data->>''46'' as mon46 -- ダイアライザ入口圧警報点（下限）
,monitor_data->>''47'' as mon47 -- ダイアライザ差圧警報点（上限）
,monitor_data->>''48'' as mon48 -- ダイアライザ差圧警報点（下限）
,monitor_data->>''49'' as mon49 -- ⊿ＢＶ低下警報点1
,monitor_data->>''50'' as mon50 -- ⊿ＢＶ低下警報点2
,monitor_data->>''51'' as mon51 -- ⊿BV変化率警報点
,monitor_data->>''54'' as mon54 -- バイカーボ濃度警報点（上限）
,monitor_data->>''55'' as mon55 -- バイカーボ濃度警報点（下限）
,monitor_data->>''56'' as mon56 -- 透析液濃度警報点（上限）
,monitor_data->>''57'' as mon57 -- 透析液濃度警報点（下限）
,monitor_data->>''58'' as mon58 -- Ｎａ濃度警報点（上限）
,monitor_data->>''59'' as mon59 -- Ｎａ濃度警報点（下限）
,monitor_data->>''60'' as mon60 -- 透析液温度警報点（上限）
,monitor_data->>''61'' as mon61 -- 透析液温度警報点（下限）
,monitor_data->>''62'' as mon62 -- 漏血量警報
,monitor_data->>''63'' as mon63 -- 給水圧警報点（上限）
,monitor_data->>''64'' as mon64 -- 給水圧警報点（下限）
,monitor_data->>''65'' as mon65 -- 初期ＵＦＲ警報点（上限）
,monitor_data->>''66'' as mon66 -- 初期ＵＦＲ警報点（下限）
,monitor_data->>''67'' as mon67 -- ＵＦＲ低下率警報
,monitor_data->>''68'' as mon68 -- Kt/V
,monitor_data->>''69'' as mon69 -- 運転中の血流量積算値
,monitor_data->>''70'' as mon70 -- 補液量設定値
,monitor_data->>''71'' as mon71 -- 補液速度
,monitor_data->>''72'' as mon72 -- 補液量現在値
,monitor_data->>''73'' as mon73 -- 補液速度設定値
,monitor_data->>''74'' as mon74 -- 補液温度
,monitor_data->>''75'' as mon75 -- 補液温度設定値
,monitor_data->>''76'' as mon76 -- 濾液速度
,monitor_data->>''77'' as mon77 -- 荷重計
,case when monitor_data->>''78'' is null then ''0'' else monitor_data->>''78'' end as mon78 -- 残り時間（補液完了）
,monitor_data->>''80'' as mon80 -- ⊿ＢＶ変化率
,monitor_data->>''85'' as mon85 -- ⊿BVリファレンスエリア上限
,monitor_data->>''86'' as mon86 -- ⊿BVリファレンスエリア下限
,monitor_data->>''88'' as mon88 -- PRR
,monitor_data->>''89'' as mon89 -- 再循環率測定結果（BVMS連携用）
,monitor_data->>''90'' as mon90 -- 最高血圧
,monitor_data->>''91'' as mon91 -- 最低血圧
,monitor_data->>''92'' as mon92 -- 平均血圧
,monitor_data->>''93'' as mon93 -- 脈拍
,monitor_data->>''94'' as mon94 -- 体温
,monitor_data->>''95'' as mon95 -- ⊿ＢＶ_5分平均値
,monitor_data->>''96'' as mon96 -- ⊿ＢＶ_最大最小を除いた5分平均値
,monitor_data->>''97'' as mon97 -- 推定血流量
,monitor_data->>''98'' as mon98 -- 血流量不足率

,monitor_data->>''38'' as mon38 -- Kt/V測定値
,monitor_data->>''79'' as mon79 -- URR
,monitor_data->>''100'' as mon100 -- ⊿BV(BVplus)
,monitor_data->>''101'' as mon101 -- Ht
,monitor_data->>''102'' as mon102 -- LDQb

,monitor_data->>''Z11'' as monZ1sigma -- 治療モード(Σ)
,monitor_data->>''Z21'' as monZ2sigma -- 工程状態(Σ)
,monitor_data->>''Z31'' as monZ3sigma -- 除水速度(Σ)
,monitor_data->>''Z41'' as monZ4sigma -- 血液流量(Σ)
,monitor_data->>''Z51'' as monZ5sigma -- シリンジ流量(Σ)
,monitor_data->>''Z61'' as monZ6sigma -- ろ過流量(Σ)
,monitor_data->>''Z71'' as monZ7sigma -- 透析液/ドレン流量(Σ)
,monitor_data->>''Z81'' as monZ8sigma -- 補液流量(Σ)
,monitor_data->>''Z91'' as monZ9sigma -- 透析液加温器温度(Σ)
,monitor_data->>''Z101'' as monZ10sigma -- 補液加温器温度(Σ)
,monitor_data->>''Z111'' as monZ11sigma -- 現在 除水量(Σ)
,monitor_data->>''Z121'' as monZ12sigma -- 現在 血液循環量(Σ)
,monitor_data->>''Z131'' as monZ13sigma -- 現在 ろ過量(Σ)
,monitor_data->>''Z141'' as monZ14sigma -- 現在 透析液/ドレン量(Σ)
,monitor_data->>''Z151'' as monZ15sigma -- 現在 補液量(Σ)
,monitor_data->>''Z161'' as monZ16sigma -- 治療時間(Σ)
,monitor_data->>''Z171'' as monZ17sigma -- シリンジ積算量(Σ)
,monitor_data->>''Z181'' as monZ18sigma -- 目標 除水量(Σ)
,monitor_data->>''Z191'' as monZ19sigma -- 目標 血液循環量(Σ)
,monitor_data->>''Z201'' as monZ20sigma -- 目標 ろ過量(Σ)
,monitor_data->>''Z211'' as monZ21sigma -- 目標 透析液/ドレン量(Σ)
,monitor_data->>''Z221'' as monZ22sigma -- 目標 補液量(Σ)
,monitor_data->>''Z231'' as monZ23sigma -- 目標 治療時間(Σ)
,monitor_data->>''Z241'' as monZ24sigma -- 脱血圧(Σ)
,monitor_data->>''Z251'' as monZ25sigma -- 入口圧(Σ)
,monitor_data->>''Z261'' as monZ26sigma -- 静脈圧(Σ)
,monitor_data->>''Z271'' as monZ27sigma -- ろ過圧(Σ)
,monitor_data->>''Z281'' as monZ28sigma -- 排気圧/2次膜圧(Σ)
,monitor_data->>''Z291'' as monZ29sigma -- TMP/TMP1(Σ)
,monitor_data->>''Z301'' as monZ30sigma -- TMP2(Σ)
,monitor_data->>''Z311'' as monZ31sigma -- 差圧(Σ)
,monitor_data->>''Z321'' as monZ32sigma -- 気泡検知警報(Σ)
,monitor_data->>''Z331'' as monZ33sigma -- 漏血警報(Σ)
,monitor_data->>''Z341'' as monZ34sigma -- 加温器警報(Σ)
,monitor_data->>''Z351'' as monZ35sigma -- 脱血圧警報(Σ)
,monitor_data->>''Z361'' as monZ36sigma -- 入口圧警報(Σ)
,monitor_data->>''Z371'' as monZ37sigma -- 静脈圧警報(Σ)
,monitor_data->>''Z381'' as monZ38sigma -- ろ過圧警報(Σ)
,monitor_data->>''Z391'' as monZ39sigma -- 排気圧/2次膜圧警報(Σ)
,monitor_data->>''Z401'' as monZ40sigma -- TMP警報(Σ)
,monitor_data->>''Z411'' as monZ41sigma -- TMP2警報(Σ)
,monitor_data->>''Z421'' as monZ42sigma -- 差圧警報(Σ)
,monitor_data->>''Z431'' as monZ43sigma -- その他警報(Σ)

,monitor_data->>''Z12'' as monZ1km -- 測定値 TMP(KM)
,monitor_data->>''Z22'' as monZ2km -- 測定値 入口圧(KM)
,monitor_data->>''Z32'' as monZ3km -- 測定値 返血圧(KM)
,monitor_data->>''Z42'' as monZ4km -- 測定値 2次膜圧（吸着圧）(KM)
,monitor_data->>''Z52'' as monZ5km -- 圧力上限警報設定値 TMP(KM)
,monitor_data->>''Z62'' as monZ6km -- 圧力上限警報設定値 入口圧(KM)
,monitor_data->>''Z72'' as monZ7km -- 圧力上限警報設定値 返血圧(KM)
,monitor_data->>''Z82'' as monZ8km -- 圧力上限警報設定値 2次膜圧（吸着圧）(KM)
,monitor_data->>''Z92'' as monZ9km -- 流量情報 BP瞬時流量(KM)
,monitor_data->>''Z102'' as monZ10km -- 流量情報 PP瞬時流量(KM)
,monitor_data->>''Z112'' as monZ11km -- 流量情報 DP瞬時流量(KM)
,monitor_data->>''Z122'' as monZ12km -- 流量情報 BP積算流量(KM)
,monitor_data->>''Z132'' as monZ13km -- 流量情報 PP積算流量(KM)
,monitor_data->>''Z142'' as monZ14km -- 流量情報 DP積算流量(KM)
,monitor_data->>''Z152'' as monZ15km -- 流量情報 除水積算流量(KM)
,monitor_data->>''Z162'' as monZ16km -- 流量情報 血漿処理目標値(KM)
,monitor_data->>''Z172'' as monZ17km -- その他情報 加温器温度(KM)
,monitor_data->>''Z182'' as monZ18km -- その他情報 バランス(KM)
,monitor_data->>''Z192'' as monZ19km -- その他情報 経過時間(KM)
,monitor_data->>''Z202'' as monZ20km -- その他情報 アラーム番号(KM)
,monitor_data->>''Z212'' as monZ21km -- その他情報 自己診断番号(KM)
,monitor_data->>''Z222'' as monZ22km -- その他情報 モード(KM)
,monitor_data->>''Z232'' as monZ23km -- その他情報 工程情報(KM)

,monitor_data->>''Z13'' as monZ1iq -- 治療経過時間(iQ)
,monitor_data->>''Z23'' as monZ2iq -- 除水速度(iQ)
,monitor_data->>''Z33'' as monZ3iq -- ろ過ポンプ流量(iQ)
,monitor_data->>''Z43'' as monZ4iq -- 補液ポンプ流量(iQ)
,monitor_data->>''Z53'' as monZ5iq -- 透析ポンプ流量(iQ)
,monitor_data->>''Z63'' as monZ6iq -- 血液ポンプ流量(iQ)
,monitor_data->>''Z73'' as monZ7iq -- シリンジポンプ流量(iQ)
,monitor_data->>''Z83'' as monZ8iq -- 除水量積算値(iQ)
,monitor_data->>''Z93'' as monZ9iq -- ろ過量積算値(iQ)
,monitor_data->>''Z103'' as monZ10iq -- 補液量積算値(iQ)
,monitor_data->>''Z113'' as monZ11iq -- 透析液量積算値(iQ)
,monitor_data->>''Z123'' as monZ12iq -- 血液循環量(iQ)
,monitor_data->>''Z133'' as monZ13iq -- シリンジポンプ積算値(iQ)
,monitor_data->>''Z143'' as monZ14iq -- 採血圧(iQ)
,monitor_data->>''Z153'' as monZ15iq -- 動脈圧(iQ)
,monitor_data->>''Z163'' as monZ16iq -- 静脈圧(iQ)
,monitor_data->>''Z173'' as monZ17iq -- ろ過圧(iQ)
,monitor_data->>''Z183'' as monZ18iq -- TMP(iQ)
,monitor_data->>''Z193'' as monZ19iq -- 分離ポンプ流量(iQ)
,monitor_data->>''Z203'' as monZ20iq -- 返漿ポンプ流量(iQ)
,monitor_data->>''Z213'' as monZ21iq -- ドレンポンプ流量(iQ)
,monitor_data->>''Z223'' as monZ22iq -- 分離量積算値(iQ)
,monitor_data->>''Z233'' as monZ23iq -- 返漿量積算値(iQ)
,monitor_data->>''Z243'' as monZ24iq -- ドレン量積算値(iQ)
,monitor_data->>''Z253'' as monZ25iq -- 血漿圧(iQ)
,monitor_data->>''Z263'' as monZ26iq -- 血漿入口圧(iQ)

,monitor_data->>''Z14'' as monZ1km90 -- 測定値 TMP圧(KM90)
,monitor_data->>''Z24'' as monZ2km90 -- 測定値 入口圧(KM90)
,monitor_data->>''Z34'' as monZ3km90 -- 測定値 返血圧(KM90)
,monitor_data->>''Z44'' as monZ4km90 -- 測定値 ろ過圧(KM90)
,monitor_data->>''Z54'' as monZ5km90 -- 測定値 浄化器圧(KM90)
,monitor_data->>''Z64'' as monZ6km90 -- 設定値 TMP圧(KM90)
,monitor_data->>''Z74'' as monZ7km90 -- 設定値 入口圧(KM90)
,monitor_data->>''Z84'' as monZ8km90 -- 設定値 返血圧・上限(KM90)
,monitor_data->>''Z94'' as monZ9km90 -- 設定値 返血圧・下限(KM90)
,monitor_data->>''Z104'' as monZ10km90 -- 設定値 浄化器圧(KM90)
,monitor_data->>''Z114'' as monZ11km90 -- 設定値 除水設定値(KM90)
,monitor_data->>''Z124'' as monZ12km90 -- 流量情報 血液ﾎﾟﾝﾌﾟ指令流量(KM90)
,monitor_data->>''Z134'' as monZ13km90 -- 流量情報 透析液ﾎﾟﾝﾌﾟ指令流量(KM90)
,monitor_data->>''Z144'' as monZ14km90 -- 流量情報 補充液ﾎﾟﾝﾌﾟ指令流量(KM90)
,monitor_data->>''Z154'' as monZ15km90 -- 流量情報 ろ液ﾎﾟﾝﾌﾟ指令流量(KM90)
,monitor_data->>''Z164'' as monZ16km90 -- 流量情報 血液ﾎﾟﾝﾌﾟ積算流量(KM90)
,monitor_data->>''Z174'' as monZ17km90 -- 流量情報 透析液ﾎﾟﾝﾌﾟ積算流量(KM90)
,monitor_data->>''Z184'' as monZ18km90 -- 流量情報 補充液ﾎﾟﾝﾌﾟ積算流量(KM90)
,monitor_data->>''Z194'' as monZ19km90 -- 流量情報 除水積算流量(KM90)
,monitor_data->>''Z204'' as monZ20km90 -- その他情報 加温器温度(KM90)
,monitor_data->>''Z214'' as monZ21km90 -- その他情報 除水差分/重量値(KM90)
,monitor_data->>''Z224'' as monZ22km90 -- その他情報 初期診断情報(KM90)
,monitor_data->>''Z234'' as monZ23km90 -- その他情報 ｱﾗｰﾑ情報1(KM90)
,monitor_data->>''Z244'' as monZ24km90 -- その他情報 ｱﾗｰﾑ情報2(KM90)
,monitor_data->>''Z254'' as monZ25km90 -- その他情報 ｱﾗｰﾑ情報3(KM90)
,monitor_data->>''Z264'' as monZ26km90 -- その他情報 ｱﾗｰﾑ情報4(KM90)
,monitor_data->>''Z274'' as monZ27km90 -- その他情報 ｱﾗｰﾑ情報5(KM90)
,monitor_data->>''Z284'' as monZ28km90 -- その他情報 ｱﾗｰﾑ情報6(KM90)
,monitor_data->>''Z294'' as monZ29km90 -- その他情報 ｱﾗｰﾑ情報7(KM90)
,monitor_data->>''Z304'' as monZ30km90 -- その他情報 ｱﾗｰﾑ情報8(KM90)
,monitor_data->>''Z314'' as monZ31km90 -- その他情報 ｱﾗｰﾑ情報9(KM90)
,monitor_data->>''Z324'' as monZ32km90 -- その他情報 ｱﾗｰﾑ情報10(KM90)
,monitor_data->>''Z334'' as monZ33km90 -- その他情報 注意情報(KM90)
,monitor_data->>''Z344'' as monZ34km90 -- 経過時間(KM90)
,monitor_data->>''Z354'' as monZ35km90 -- その他情報 用途(KM90)
,monitor_data->>''Z364'' as monZ36km90 -- その他情報 工程(KM90)
,monitor_data->>''Z374'' as monZ37km90 -- その他情報 動作日、時間(KM90)
,occur_date as occur_date -- 発生日時
from
  mni_monitor
where
  ord_no = @ordNo and data_type = 1 and is_del = ''0''
	order by occur_date desc;', 2, '[{"preview": "00：11", "can_calc": "0", "data_code": "mon1", "data_name": "経過時間", "data_type": "DateTime", "conv_table": [], "data_class": "モニタ", "field_name": "mon1", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "00：12", "can_calc": "0", "data_code": "mon2", "data_name": "経過時間（ＥＣＵＭ）", "data_type": "DateTime", "conv_table": [], "data_class": "モニタ", "field_name": "mon2", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "00：13", "can_calc": "0", "data_code": "mon3", "data_name": "残り時間（除水完了）", "data_type": "DateTime", "conv_table": [], "data_class": "モニタ", "field_name": "mon3", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "00：14", "can_calc": "0", "data_code": "mon4", "data_name": "残り時間（透析完了）", "data_type": "DateTime", "conv_table": [], "data_class": "モニタ", "field_name": "mon4", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.21", "can_calc": "0", "data_code": "mon5", "data_name": "除水積算値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon5", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.18", "can_calc": "0", "data_code": "mon6", "data_name": "除水速度", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon6", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "8.58", "can_calc": "0", "data_code": "mon7", "data_name": "血液循環量", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon7", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "0", "data_code": "mon8", "data_name": "血流量", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon8", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4.4", "can_calc": "0", "data_code": "mon9", "data_name": "ＩＰ総量", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon9", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.2", "can_calc": "0", "data_code": "mon10", "data_name": "ＩＰ速度", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon10", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "138", "can_calc": "0", "data_code": "mon11", "data_name": "静脈圧", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon11", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "144", "can_calc": "0", "data_code": "mon12", "data_name": "透析液圧", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon12", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-7", "can_calc": "0", "data_code": "mon13", "data_name": "TMP", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon13", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-830", "can_calc": "0", "data_code": "mon14", "data_name": "ダイアライザ入口圧", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon14", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-925", "can_calc": "0", "data_code": "mon15", "data_name": "ダイアライザ差圧", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon15", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-367", "can_calc": "0", "data_code": "mon16", "data_name": "血液入口～静脈平均圧", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon16", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon17", "data_name": "⊿BV", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon17", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "0", "data_code": "mon18", "data_name": "バイカーボ濃度", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon18", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13.8", "can_calc": "0", "data_code": "mon19", "data_name": "透析液濃度", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon19", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon20", "data_name": "Ｎａ濃度", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon20", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.2", "can_calc": "0", "data_code": "mon21", "data_name": "透析液温度", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon21", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "mon22", "data_name": "透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon22", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "0", "data_code": "mon23", "data_name": "漏血量", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon23", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "38", "can_calc": "0", "data_code": "mon24", "data_name": "給液圧（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon24", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "22", "can_calc": "0", "data_code": "mon25", "data_name": "給液圧（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon25", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-72.13", "can_calc": "0", "data_code": "mon26", "data_name": "ＵＦＲ", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon26", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon27", "data_name": "ＵＦＲ低下率", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon27", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "0", "data_code": "mon28", "data_name": "初期ＵＦＲ測定値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon28", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "0", "data_code": "mon29", "data_name": "TMP補正値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon29", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon30", "data_name": "透析運転時間", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon30", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "HD", "can_calc": "0", "data_code": "mon31", "data_name": "治療モード", "data_type": "string", "conv_table": [{"code": "-1", "disp": "不明", "item": "不明"}, {"code": "0", "disp": "HD", "item": "HD"}, {"code": "1", "disp": "ECUM", "item": "ECUM"}, {"code": "2", "disp": "HDF", "item": "HDF"}, {"code": "3", "disp": "HF", "item": "HF"}, {"code": "4", "disp": "HD+補液", "item": "HD+補液"}, {"code": "5", "disp": "ECUM+補液", "item": "ECUM+補液"}, {"code": "6", "disp": "AFBF", "item": "AFBF"}, {"code": "7", "disp": "OHDF", "item": "OHDF"}, {"code": "8", "disp": "OHF", "item": "OHF"}, {"code": "9", "disp": "特殊浄化", "item": "特殊浄化"}, {"code": "10", "disp": "I-HDF", "item": "I-HDF"}], "data_class": "モニタ", "field_name": "mon31", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.85", "can_calc": "0", "data_code": "mon32", "data_name": "除水目標値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon32", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.2", "can_calc": "0", "data_code": "mon33", "data_name": "除水速度設定値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon33", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.5", "can_calc": "0", "data_code": "mon34", "data_name": "透析液温度設定値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon34", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "mon35", "data_name": "透析液流量設定値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon35", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "0", "data_code": "mon36", "data_name": "血流量設定値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon36", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.2", "can_calc": "0", "data_code": "mon37", "data_name": "ＩＰ速度設定", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon37", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "0", "data_code": "mon39", "data_name": "静脈圧警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon39", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "0", "data_code": "mon40", "data_name": "静脈圧警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon40", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "0", "data_code": "mon41", "data_name": "透析液圧警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon41", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "0", "data_code": "mon42", "data_name": "透析液圧警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon42", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "0", "data_code": "mon43", "data_name": "TMP警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon43", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "0", "data_code": "mon44", "data_name": "TMP警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon44", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "0", "data_code": "mon45", "data_name": "ダイアライザ入口圧警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon45", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "0", "data_code": "mon46", "data_name": "ダイアライザ入口圧警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon46", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "0", "data_code": "mon47", "data_name": "ダイアライザ差圧警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon47", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-20", "can_calc": "0", "data_code": "mon48", "data_name": "ダイアライザ差圧警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon48", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-20.0", "can_calc": "0", "data_code": "mon49", "data_name": "⊿ＢＶ低下警報点1", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon49", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-40.0", "can_calc": "0", "data_code": "mon50", "data_name": "⊿ＢＶ低下警報点2", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon50", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-10.0", "can_calc": "0", "data_code": "mon51", "data_name": "⊿BV変化率警報点", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon51", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "0", "data_code": "mon54", "data_name": "バイカーボ濃度警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon54", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "0", "data_code": "mon55", "data_name": "バイカーボ濃度警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon55", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon56", "data_name": "透析液濃度警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon56", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon57", "data_name": "透析液濃度警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon57", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon58", "data_name": "Ｎａ濃度警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon58", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon59", "data_name": "Ｎａ濃度警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon59", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "40.0", "can_calc": "0", "data_code": "mon60", "data_name": "透析液温度警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon60", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "33.0", "can_calc": "0", "data_code": "mon61", "data_name": "透析液温度警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon61", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "0", "data_code": "mon62", "data_name": "漏血量警報", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon62", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "45", "can_calc": "0", "data_code": "mon63", "data_name": "給水圧警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon63", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "8", "can_calc": "0", "data_code": "mon64", "data_name": "給水圧警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon64", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-40.00", "can_calc": "0", "data_code": "mon65", "data_name": "初期ＵＦＲ警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon65", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-100.00", "can_calc": "0", "data_code": "mon66", "data_name": "初期ＵＦＲ警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon66", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "29", "can_calc": "0", "data_code": "mon67", "data_name": "ＵＦＲ低下率警報", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon67", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.1", "can_calc": "0", "data_code": "mon68", "data_name": "Kt/V", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon68", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "8.58", "can_calc": "0", "data_code": "mon69", "data_name": "運転中の血流量積算値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon69", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "8", "can_calc": "0", "data_code": "mon70", "data_name": "補液量設定値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon70", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.0", "can_calc": "0", "data_code": "mon71", "data_name": "補液速度", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon71", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.4", "can_calc": "0", "data_code": "mon72", "data_name": "補液量現在値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon72", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.0", "can_calc": "0", "data_code": "mon73", "data_name": "補液速度設定値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon73", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.4", "can_calc": "0", "data_code": "mon74", "data_name": "補液温度", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon74", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.4", "can_calc": "0", "data_code": "mon75", "data_name": "補液温度設定値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon75", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "0", "data_code": "mon76", "data_name": "濾液速度", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon76", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.62", "can_calc": "0", "data_code": "mon77", "data_name": "荷重計", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon77", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "00：15", "can_calc": "0", "data_code": "mon78", "data_name": "残り時間（補液完了）", "data_type": "DateTime", "conv_table": [], "data_class": "モニタ", "field_name": "mon78", "disp_format": "hh:mm", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-5.0", "can_calc": "0", "data_code": "mon80", "data_name": "⊿ＢＶ変化率", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon80", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon85", "data_name": "⊿BVリファレンスエリア上限", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon85", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon86", "data_name": "⊿BVリファレンスエリア下限", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon86", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "0", "data_code": "mon88", "data_name": "PRR", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon88", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon89", "data_name": "再循環率測定結果（BVMS連携用）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon89", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "132", "can_calc": "0", "data_code": "mon90", "data_name": "最高血圧", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon90", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "88", "can_calc": "0", "data_code": "mon91", "data_name": "最低血圧", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon91", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "102", "can_calc": "0", "data_code": "mon92", "data_name": "平均血圧", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon92", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "66", "can_calc": "0", "data_code": "mon93", "data_name": "脈拍", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon93", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.6", "can_calc": "0", "data_code": "mon94", "data_name": "体温", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon94", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "0", "data_code": "mon95", "data_name": "⊿ＢＶ_5分平均値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon95", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "0", "data_code": "mon96", "data_name": "⊿ＢＶ_最大最小を除いた5分平均値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon96", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.51", "can_calc": "0", "data_code": "mon38", "data_name": "Kt/V測定値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon38", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "35.5", "can_calc": "0", "data_code": "mon79", "data_name": "URR", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon79", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "0", "data_code": "mon97", "data_name": "推定血流量", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon97", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50.1", "can_calc": "0", "data_code": "mon98", "data_name": "血流量不足率", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon98", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "SCUF", "can_calc": "0", "data_code": "monz1sigma", "data_name": "治療モード(Σ)", "data_type": "string", "conv_table": [{"code": "00", "disp": "SCUF", "item": "SCUF"}, {"code": "01", "disp": "CHF 前希釈", "item": "CHF 前希釈"}, {"code": "02", "disp": "CHF 後希釈", "item": "CHF 後希釈"}, {"code": "03", "disp": "CHD", "item": "CHD"}, {"code": "04", "disp": "CHDF 前希釈", "item": "CHDF 前希釈"}, {"code": "05", "disp": "CHDF 後希釈", "item": "CHDF 後希釈"}, {"code": "06", "disp": "PE", "item": "PE"}, {"code": "07", "disp": "PA プラソーバ", "item": "PA プラソーバ"}, {"code": "08", "disp": "PA イムソーバ", "item": "PA イムソーバ"}, {"code": "09", "disp": "DFPP 補液無し", "item": "DFPP 補液無し"}, {"code": "10", "disp": "DFPP 補液有り", "item": "DFPP 補液有り"}, {"code": "11", "disp": "HA", "item": "HA"}, {"code": "12", "disp": "LCAP", "item": "LCAP"}, {"code": "13", "disp": "(腹水)", "item": "(腹水)"}], "data_class": "モニタ", "field_name": "monz1sigma", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "治療", "can_calc": "0", "data_code": "monz2sigma", "data_name": "工程状態(Σ)", "data_type": "string", "conv_table": [{"code": "1", "disp": "治療", "item": "治療"}, {"code": "2", "disp": "治療停止", "item": "治療停止"}, {"code": "3", "disp": "回収", "item": "回収"}, {"code": "4", "disp": "回収 廃棄", "item": "回収 廃棄"}, {"code": "5", "disp": "準備", "item": "準備"}, {"code": "6", "disp": "点検", "item": "点検"}, {"code": "7", "disp": "その他", "item": "その他"}], "data_class": "モニタ", "field_name": "monz2sigma", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz3sigma", "data_name": "除水速度(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz3sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz4sigma", "data_name": "血液流量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz4sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz5sigma", "data_name": "シリンジ流量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz5sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz6sigma", "data_name": "ろ過流量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz6sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz7sigma", "data_name": "透析液/ドレン流量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz7sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz8sigma", "data_name": "補液流量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz8sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz9sigma", "data_name": "透析液加温器温度(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz9sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz10sigma", "data_name": "補液加温器温度(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz10sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz11sigma", "data_name": "現在 除水量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz11sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz12sigma", "data_name": "現在 血液循環量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz12sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz13sigma", "data_name": "現在 ろ過量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz13sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz14sigma", "data_name": "現在 透析液/ドレン量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz14sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz15sigma", "data_name": "現在 補液量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz15sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz16sigma", "data_name": "治療時間(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz16sigma", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz17sigma", "data_name": "シリンジ積算量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz17sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz18sigma", "data_name": "目標 除水量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz18sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz19sigma", "data_name": "目標 血液循環量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz19sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz20sigma", "data_name": "目標 ろ過量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz20sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz21sigma", "data_name": "目標 透析液/ドレン量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz21sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz22sigma", "data_name": "目標 補液量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz22sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz23sigma", "data_name": "目標 治療時間(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz23sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz24sigma", "data_name": "脱血圧(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz24sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz25sigma", "data_name": "入口圧(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz25sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz26sigma", "data_name": "静脈圧(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz26sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz27sigma", "data_name": "ろ過圧(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz27sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz28sigma", "data_name": "排気圧/2次膜圧(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz28sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz29sigma", "data_name": "TMP/TMP1(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz29sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz30sigma", "data_name": "TMP2(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz30sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz31sigma", "data_name": "差圧(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz31sigma", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz32sigma", "data_name": "気泡検知警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz32sigma", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz33sigma", "data_name": "漏血警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz33sigma", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz34sigma", "data_name": "加温器警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz34sigma", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz35sigma", "data_name": "脱血圧警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz35sigma", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz36sigma", "data_name": "入口圧警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz36sigma", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz37sigma", "data_name": "静脈圧警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz37sigma", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz38sigma", "data_name": "ろ過圧警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz38sigma", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz39sigma", "data_name": "排気圧/2次膜圧警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz39sigma", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz40sigma", "data_name": "TMP警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz40sigma", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz41sigma", "data_name": "TMP2警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz41sigma", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz42sigma", "data_name": "差圧警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz42sigma", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz43sigma", "data_name": "その他警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz43sigma", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz1km", "data_name": "測定値 TMP(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz1km", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz2km", "data_name": "測定値 入口圧(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz2km", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz3km", "data_name": "測定値 返血圧(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz3km", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz4km", "data_name": "測定値 2次膜圧（吸着圧）(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz4km", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz5km", "data_name": "圧力上限警報設定値 TMP(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz5km", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz6km", "data_name": "圧力上限警報設定値 入口圧(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz6km", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz7km", "data_name": "圧力上限警報設定値 返血圧(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz7km", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz8km", "data_name": "圧力上限警報設定値 2次膜圧（吸着圧）(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz8km", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz9km", "data_name": "流量情報 BP瞬時流量(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz9km", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz10km", "data_name": "流量情報 PP瞬時流量(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz10km", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz11km", "data_name": "流量情報 DP瞬時流量(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz11km", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz12km", "data_name": "流量情報 BP積算流量(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz12km", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz13km", "data_name": "流量情報 PP積算流量(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz13km", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz14km", "data_name": "流量情報 DP積算流量(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz14km", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz15km", "data_name": "流量情報 除水積算流量(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz15km", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz16km", "data_name": "流量情報 血漿処理目標値(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz16km", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz17km", "data_name": "その他情報 加温器温度(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz17km", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz18km", "data_name": "その他情報 バランス(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz18km", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz19km", "data_name": "その他情報 経過時間(KM)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz19km", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz20km", "data_name": "その他情報 アラーム番号(KM)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz20km", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz21km", "data_name": "その他情報 自己診断番号(KM)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz21km", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "情報なし", "can_calc": "0", "data_code": "monz22km", "data_name": "その他情報 モード(KM)", "data_type": "string", "conv_table": [{"code": "0", "disp": "情報なし", "item": "情報なし"}, {"code": "1", "disp": "CHDF", "item": "CHDF"}, {"code": "2", "disp": "CHD", "item": "CHD"}, {"code": "3", "disp": "CHF", "item": "CHF"}, {"code": "4", "disp": "PE", "item": "PE"}, {"code": "5", "disp": "PP", "item": "PP"}, {"code": "6", "disp": "DF", "item": "DF"}, {"code": "7", "disp": "手動", "item": "手動"}], "data_class": "モニタ", "field_name": "monz22km", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "情報なし", "can_calc": "0", "data_code": "monz23km", "data_name": "その他情報 工程情報(KM)", "data_type": "string", "conv_table": [{"code": "0", "disp": "情報なし", "item": "情報なし"}, {"code": "1", "disp": "洗浄工程", "item": "洗浄工程"}, {"code": "2", "disp": "臨床工程", "item": "臨床工程"}, {"code": "3", "disp": "回収工程", "item": "回収工程"}, {"code": "4", "disp": "手動工程", "item": "手動工程"}], "data_class": "モニタ", "field_name": "monz23km", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz1iq", "data_name": "治療経過時間(iQ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz1iq", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz2iq", "data_name": "除水速度(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz2iq", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz3iq", "data_name": "ろ過ポンプ流量(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz3iq", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz4iq", "data_name": "補液ポンプ流量(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz4iq", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz5iq", "data_name": "透析ポンプ流量(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz5iq", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz6iq", "data_name": "血液ポンプ流量(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz6iq", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz7iq", "data_name": "シリンジポンプ流量(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz7iq", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz8iq", "data_name": "除水量積算値(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz8iq", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz9iq", "data_name": "ろ過量積算値(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz9iq", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz10iq", "data_name": "補液量積算値(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz10iq", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz11iq", "data_name": "透析液量積算値(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz11iq", "disp_format": "0.000", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz12iq", "data_name": "血液循環量(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz12iq", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz13iq", "data_name": "シリンジポンプ積算値(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz13iq", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz14iq", "data_name": "採血圧(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz14iq", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz15iq", "data_name": "動脈圧(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz15iq", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz16iq", "data_name": "静脈圧(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz16iq", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz17iq", "data_name": "ろ過圧(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz17iq", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz18iq", "data_name": "TMP(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz18iq", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz19iq", "data_name": "分離ポンプ流量(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz19iq", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz20iq", "data_name": "返漿ポンプ流量(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz20iq", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz21iq", "data_name": "ドレンポンプ流量(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz21iq", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz22iq", "data_name": "分離量積算値(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz22iq", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz23iq", "data_name": "返漿量積算値(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz23iq", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz24iq", "data_name": "ドレン量積算値(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz24iq", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz25iq", "data_name": "血漿圧(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz25iq", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz26iq", "data_name": "血漿入口圧(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz26iq", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz1km90", "data_name": "測定値 TMP圧(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz1km90", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz2km90", "data_name": "測定値 入口圧(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz2km90", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz3km90", "data_name": "測定値 返血圧(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz3km90", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz4km90", "data_name": "測定値 ろ過圧(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz4km90", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz5km90", "data_name": "測定値 浄化器圧(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz5km90", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz6km90", "data_name": "設定値 TMP圧(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz6km90", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz7km90", "data_name": "設定値 入口圧(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz7km90", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz8km90", "data_name": "設定値 返血圧・上限(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz8km90", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz9km90", "data_name": "設定値 返血圧・下限(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz9km90", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz10km90", "data_name": "設定値 浄化器圧(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz10km90", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz11km90", "data_name": "設定値 除水設定値(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz11km90", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz12km90", "data_name": "流量情報 血液ﾎﾟﾝﾌﾟ指令流量(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz12km90", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz13km90", "data_name": "流量情報 透析液ﾎﾟﾝﾌﾟ指令流量(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz13km90", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz14km90", "data_name": "流量情報 補充液ﾎﾟﾝﾌﾟ指令流量(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz14km90", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz15km90", "data_name": "流量情報 ろ液ﾎﾟﾝﾌﾟ指令流量(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz15km90", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz16km90", "data_name": "流量情報 血液ﾎﾟﾝﾌﾟ積算流量(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz16km90", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz17km90", "data_name": "流量情報 透析液ﾎﾟﾝﾌﾟ積算流量(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz17km90", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz18km90", "data_name": "流量情報 補充液ﾎﾟﾝﾌﾟ積算流量(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz18km90", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz19km90", "data_name": "流量情報 除水積算流量(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz19km90", "disp_format": "0.00", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz20km90", "data_name": "その他情報 加温器温度(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz20km90", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz21km90", "data_name": "その他情報 除水差分/重量値(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz21km90", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz22km90", "data_name": "その他情報 初期診断情報(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz22km90", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz23km90", "data_name": "その他情報 ｱﾗｰﾑ情報1(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz23km90", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz24km90", "data_name": "その他情報 ｱﾗｰﾑ情報2(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz24km90", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz25km90", "data_name": "その他情報 ｱﾗｰﾑ情報3(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz25km90", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz26km90", "data_name": "その他情報 ｱﾗｰﾑ情報4(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz26km90", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz27km90", "data_name": "その他情報 ｱﾗｰﾑ情報5(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz27km90", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz28km90", "data_name": "その他情報 ｱﾗｰﾑ情報6(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz28km90", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz29km90", "data_name": "その他情報 ｱﾗｰﾑ情報7(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz29km90", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz30km90", "data_name": "その他情報 ｱﾗｰﾑ情報8(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz30km90", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz31km90", "data_name": "その他情報 ｱﾗｰﾑ情報9(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz31km90", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz32km90", "data_name": "その他情報 ｱﾗｰﾑ情報10(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz32km90", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz33km90", "data_name": "その他情報 注意情報(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz33km90", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz34km90", "data_name": "経過時間(KM9000)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz34km90", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz35km90", "data_name": "その他情報 用途(KM90)", "data_type": "string", "conv_table": [{"code": "1", "disp": "CRRT", "item": "CRRT"}, {"code": "2", "disp": "ECUM", "item": "ECUM"}, {"code": "3", "disp": "DF", "item": "DF"}, {"code": "4", "disp": "DFT", "item": "DFT"}, {"code": "5", "disp": "PP", "item": "PP"}, {"code": "6", "disp": "PE", "item": "PE"}, {"code": "7", "disp": "DHP", "item": "DHP"}, {"code": "8", "disp": "ASCT", "item": "ASCT"}, {"code": "9", "disp": "TEST", "item": "TEST"}], "data_class": "モニタ", "field_name": "monz35km90", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz36km90", "data_name": "その他情報 工程(KM90)", "data_type": "string", "conv_table": [{"code": "1", "disp": "装着", "item": "装着"}, {"code": "2", "disp": "確認", "item": "確認"}, {"code": "3", "disp": "洗浄", "item": "洗浄"}, {"code": "4", "disp": "臨床", "item": "臨床"}, {"code": "5", "disp": "回収", "item": "回収"}], "data_class": "モニタ", "field_name": "monz36km90", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz37km90", "data_name": "その他情報 動作日、時間(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz37km90", "disp_format": "", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "mon100", "data_name": "⊿BV(BVplus)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon100", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "mon101", "data_name": "Ht", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon101", "disp_format": "0.0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "mon102", "data_name": "LDQb", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon102", "disp_format": "0", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/25", "can_calc": "0", "data_code": "occur_date", "data_name": "発生日時", "data_type": "DateTime", "conv_table": [], "data_class": "モニタ", "field_name": "occur_date", "disp_format": "yyyy/mm/dd", "data_category": "実績（治療中）", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績（治療中）：モニタ @ordNo 使用', '2021-08-05 13:30:00', CURRENT_TIMESTAMP, NULL);
	
	