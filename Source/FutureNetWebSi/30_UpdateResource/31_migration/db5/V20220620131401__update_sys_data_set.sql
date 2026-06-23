delete from sys_data_set where sql_cd in (-131,-181,-191);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-131, 'SELECT
  ord.treat_date AS dialysis_date,
  ord.facility_cd AS facility_cd,
  COALESCE ( concat ( ord.ind_schedule_user_info ->> ''ind_user_last_name'', '' '', ord.ind_schedule_user_info ->> ''ind_user_first_name'' ), '''' ) AS ind_name,
  COALESCE ( LEFT ( concat ( ord.ind_schedule_user_info ->> ''ind_user_last_name'', '' '', ord.ind_schedule_user_info ->> ''ind_user_first_name'' ), 5 ), '''' ) AS ind_name10,
  COALESCE ( ord.ind_treat_start_time, '''' ) AS start_time,
  COALESCE ( mkr.in_hospital_cd_1, '''' ) AS kur_cd1,
  COALESCE ( mkr.kur_name, '''' ) AS kur_name,
  COALESCE ( mbd.bed_cd, 0 ) AS bed_cd,
  COALESCE ( mbd.in_hospital_cd_1, '''' ) AS bed_cd1,
  COALESCE ( mbd.bed_name, '''' ) AS bed_name,
  COALESCE ( mtt.treatment_name, '''' ) AS treatment_name,
  COALESCE ( mtt.in_hospital_cd_a1, '''' ) AS treatment_cd,
  COALESCE ( ord.ind_dw, 0 ) AS dw,
  TO_NUMBER( ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'' ) AS dialysis_time_m,
	case when RIGHT( (COALESCE (
    RIGHT ( ''00'' || TRUNC( TO_NUMBER( ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'' ) / 60, 0 ), 2 ) || RIGHT ( ''00'' || MOD ( TO_NUMBER( ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'' ), 60 ), 2 ),
    ''0''
  )::INTEGER + COALESCE ( ord.ind_treat_start_time, ''0'' )::INTEGER)::TEXT ,2)::INTEGER > 60
then(COALESCE (
    RIGHT ( ''00'' || TRUNC( TO_NUMBER( ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'' ) / 60, 0 ), 2 ) || RIGHT ( ''00'' || MOD ( TO_NUMBER( ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'' ), 60 ), 2 ),
    ''0''
  )::INTEGER + COALESCE ( ord.ind_treat_start_time, ''0'' )::INTEGER) + 100 - 60

else COALESCE (
    RIGHT ( ''00'' || TRUNC( TO_NUMBER( ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'' ) / 60, 0 ), 2 ) || RIGHT ( ''00'' || MOD ( TO_NUMBER( ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'' ), 60 ), 2 ),
    ''0''
  )::INTEGER + COALESCE ( ord.ind_treat_start_time, ''0'' )::INTEGER
END as end_time,
  COALESCE (
    RIGHT ( ''00'' || TRUNC( TO_NUMBER( ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'' ) / 60, 0 ), 2 ) || '':'' || RIGHT ( ''00'' || MOD ( TO_NUMBER( ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'' ), 60 ), 2 ),
    ''0''
  ) AS treatment_time,
  COALESCE (
    RIGHT ( ''00'' || TRUNC( TO_NUMBER( ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'' ) / 60, 0 ), 2 ) || RIGHT ( ''00'' || MOD ( TO_NUMBER( ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'' ), 60 ), 2 ),
    ''''
  ) AS treatment_time4,
  COALESCE ( ord.rst_cond_info -> ''1'' ->> ''value'', '''' ) AS treatment_time_m,--追加
  COALESCE ( ord.ind_cond_info -> ''2'' ->> ''value_name_1'', '''' ) AS va,
  COALESCE ( SUBSTRING ( ord.ind_cond_info -> ''2'' ->> ''value_name_1'', 1, 3 ), '''' ) AS va3,
  COALESCE ( mva.in_hospital_cd_1, '''' ) AS va_cd1,
  COALESCE (
    ( CASE mva.va_direct WHEN ''0'' THEN ''右'' WHEN ''1'' THEN ''左'' WHEN ''2'' THEN ''両方'' WHEN ''3'' THEN ''無'' ELSE''不明'' END ),
    ''''
  ) AS va_direct,
  COALESCE ( ord.ind_cond_info -> ''3'' ->> ''value'', '''' ) AS target_weight,
  COALESCE ( ord.ind_cond_info -> ''4'' ->> ''value'', '''' ) AS water_removal_amount_limit,
--ord.ind_cond_info->''5''->>''value_name_1'' as dialyzer,
  COALESCE ( mdr.model_number, '''' ) AS dialyzer,
--ord.ind_cond_info->''5''->>''value'' as dialyzer_cd,
  COALESCE ( mdr.in_hospital_cd_1, '''' ) AS dialyzer_cd1,
  COALESCE ( ord.ind_cond_info -> ''6'' ->> ''value_name_1'', '''' ) AS adsorption_column,
  COALESCE ( meqad.in_hospital_cd_1, '''' ) AS ad_cd1,
  COALESCE ( ord.ind_cond_info -> ''7'' ->> ''value_name_1'', '''' ) AS primary_film,
  COALESCE ( meqpr.in_hospital_cd_1, '''' ) AS pr_cd1,
  COALESCE ( ord.ind_cond_info -> ''8'' ->> ''value_name_1'', '''' ) AS secondary_film,
  COALESCE ( meqse.in_hospital_cd_1, '''' ) AS se_cd1,
--ord.ind_cond_info->''9''->>''value_name_1'' as puncture_needle_a,
  COALESCE ( meqa.equipment_name, '''' ) AS puncture_needle_a,
  COALESCE ( meqa.in_hospital_cd_1, '''' ) AS a_cd1,
--ord.ind_cond_info->''10''->>''value_name_1'' as puncture_needle_v,
  COALESCE ( meqv.equipment_name, '''' ) AS puncture_needle_v,
  COALESCE ( meqv.in_hospital_cd_1, '''' ) AS v_cd1,
--ord.ind_cond_info->''11''->>''value_name_1'' as puncture_needle_sn,
  COALESCE ( meqsn.equipment_name, '''' ) AS puncture_needle_sn,
  COALESCE ( meqsn.in_hospital_cd_1, '''' ) AS sn_cd1,
  COALESCE ( ( CASE ord.ind_cond_info -> ''12'' ->> ''value'' WHEN ''1'' THEN ''有り'' WHEN ''0'' THEN ''無し'' ELSE NULL END ), '''' ) AS single_needle,
  COALESCE ( ord.ind_cond_info -> ''13'' ->> ''value'', '''' ) AS blood_circuit,
  COALESCE ( meqbc.in_hospital_cd_1, '''' ) AS bc_cd1,
  COALESCE ( ord.ind_cond_info -> ''14'' ->> ''value'', '''' ) AS blood_flow,
--ord.ind_cond_info->''15''->>''value_name_1'' as dialysate,
  COALESCE ( med15.medicine_name, '''' ) AS dialysate,
  COALESCE ( med15.in_hospital_cd_1, '''' ) AS dialysate_cd1,
  COALESCE ( ord.ind_cond_info -> ''16'' ->> ''value'', '''' ) AS dialysate_flow_rate,
  COALESCE ( ord.ind_cond_info -> ''17'' ->> ''value'', '''' ) AS dialysate_amount,
--ord.ind_cond_info->''17''->>''unit'' as dialysate_amount_unit,
  COALESCE ( med15.unit, '''' ) AS dialysate_amount_unit,
  COALESCE ( ord.ind_cond_info -> ''18'' ->> ''value'', '''' ) AS dialysate_temperature,
--ord.ind_cond_info->''19''->>''value_name_1'' as fluid_replacement,
  COALESCE ( med25.medicine_name, '''' ) AS fluid_replacement,
  COALESCE ( med25.in_hospital_cd_1, '''' ) AS ds_cd1,
  COALESCE ( ord.ind_cond_info -> ''20'' ->> ''value'', '''' ) AS fluid_replacement_amount,
  COALESCE ( ( CASE ord.ind_cond_info -> ''21'' ->> ''value'' WHEN ''1'' THEN ''前補液'' WHEN ''0'' THEN ''後補液'' ELSE NULL END ), '''' ) AS fluid_replacement_timing,
  COALESCE ( ord.ind_cond_info -> ''22'' ->> ''value'', '''' ) AS fluid_replacement_use_count,
  COALESCE ( ord.ind_cond_info -> ''22'' ->> ''unit'', '''' ) AS fluid_replacement_use_count_unit,
  COALESCE ( ord.ind_cond_info -> ''23'' ->> ''value'', '''' ) AS fluid_replacement_temperature,
  COALESCE ( ord.ind_cond_info -> ''24'' ->> ''value'', '''' ) AS fluid_replacement_speed,
--ord.ind_cond_info->''25''->>''value_name_1'' as anti_coagulant,
  COALESCE ( med25.medicine_name, '''' ) AS anti_coagulant,
  COALESCE ( med25.in_hospital_cd_1, '''' ) AS anti_coagulant_cd1,
  COALESCE ( ord.ind_cond_info -> ''26'' ->> ''value'', '''' ) AS anti_coagulant_one_shot_amount,
--ord.ind_cond_info->''26''->>''unit'' as anti_coagulant_one_shot_amount_unit,
  COALESCE ( med25.unit, '''' ) AS anti_coagulant_one_shot_amount_unit,
  COALESCE ( ord.ind_cond_info -> ''27'' ->> ''value'', '''' ) AS anti_coagulant_sustained_speed,
  COALESCE ( ord.ind_cond_info -> ''27'' ->> ''unit'', '''' ) AS anti_coagulant_sustained_speed_unit,
  COALESCE ( ord.ind_cond_info -> ''28'' ->> ''value'', '''' ) AS anti_coagulant_sustained_amount,
  COALESCE ( ord.ind_cond_info -> ''28'' ->> ''unit'', '''' ) AS anti_coagulant_sustained_amount_unit,
  COALESCE (
    TO_NUMBER( ord.ind_cond_info -> ''26'' ->> ''value'', ''999999999999'' ) + TO_NUMBER( ord.ind_cond_info -> ''28'' ->> ''value'', ''999999999999'' ),
    0
  ) AS anti_coagulant_total_amount,--抗凝固剤総量
  COALESCE ( ( CASE ord.ind_cond_info -> ''29'' ->> ''value'' WHEN ''1'' THEN ''使用する'' WHEN ''0'' THEN ''使用しない'' ELSE NULL END ), '''' ) AS ip,
  COALESCE ( ( CASE ord.ind_cond_info -> ''30'' ->> ''value'' WHEN ''0'' THEN ''手動'' WHEN ''1'' THEN ''自動'' ELSE NULL END ), '''' ) AS ip_start,
  COALESCE ( ord.ind_cond_info -> ''31'' ->> ''value'', '''' ) AS ip_one_short_amount,
  COALESCE ( ord.ind_cond_info -> ''32'' ->> ''value'', '''' ) AS ip_speed,
  COALESCE ( ord.ind_cond_info -> ''33'' ->> ''value'', '''' ) AS ip_speed_max,
  COALESCE ( ( CASE ord.ind_cond_info -> ''34'' ->> ''value'' WHEN ''1'' THEN ''使用する'' WHEN ''0'' THEN ''使用しない'' ELSE NULL END ), '''' ) AS auto_one_shot,
  COALESCE ( ( CASE ord.ind_cond_info -> ''35'' ->> ''value'' WHEN ''1'' THEN ''入'' WHEN ''0'' THEN ''切'' ELSE NULL END ), '''' ) AS ip_auto_off,
  COALESCE ( ord.ind_cond_info -> ''36'' ->> ''value'', '''' ) AS ip_auto_off_time,
  COALESCE ( ( CASE ord.ind_cond_info -> ''37'' ->> ''value'' WHEN ''1'' THEN ''入'' WHEN ''0'' THEN ''切'' ELSE NULL END ), '''' ) AS ip_monitor_auto_off,
  COALESCE ( ord.ind_cond_info -> ''38'' ->> ''value'', '''' ) AS ip_monitor_auto_off_time,
  COALESCE ( pm.medical_care_info ->> ''dialysis_start_date'', '''' ) AS dialysis_start_date,
  COALESCE ( to_char( ord.up_date, ''YYYYMMDD'' ), '''' ) AS update_ymd,
  COALESCE ( to_char( ord.up_date, ''HH24MISS'' ), '''' ) AS update_hms
FROM
  pat_main AS pm,
  ord_main AS ord
  LEFT OUTER JOIN mst_equipment AS meqa ON meqa.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''9'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_equipment AS meqv ON meqv.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''10'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_equipment AS meqsn ON meqsn.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''11'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_equipment AS meqad ON meqad.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''6'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_equipment AS meqpr ON meqpr.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''7'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_equipment AS meqbc ON meqbc.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''13'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_equipment AS meqse ON meqse.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''8'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_medicine AS med15 ON med15.medicine_cd = TO_NUMBER( ord.ind_cond_info -> ''15'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_medicine AS med19 ON med19.medicine_cd = TO_NUMBER( ord.ind_cond_info -> ''19'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_medicine AS med25 ON med25.medicine_cd = TO_NUMBER( ord.ind_cond_info -> ''25'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_treatment AS mtt ON mtt.treatment_cd = ord.ind_treatment_cd
  LEFT OUTER JOIN mst_dialyzer AS mdr ON mdr.dialyzer_cd = TO_NUMBER( ord.ind_cond_info -> ''5'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_va AS mva ON mva.va_cd = TO_NUMBER( ord.ind_cond_info -> ''2'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_bed AS mbd ON mbd.bed_cd = ord.ind_bed_cd
  LEFT OUTER JOIN mst_kur AS mkr ON mkr.kur_cd = ord.ind_kur_cd
WHERE
  ord.ord_no =@ordNo and
  pm.pat_id = ord.pat_id
union all
(SELECT
  ord.treat_date AS dialysis_date,
  ord.facility_cd AS facility_cd,
  COALESCE ( concat ( ord.ind_schedule_user_info ->> ''ind_user_last_name'', '' '', ord.ind_schedule_user_info ->> ''ind_user_first_name'' ), '''' ) AS ind_name,
  COALESCE ( LEFT ( concat ( ord.ind_schedule_user_info ->> ''ind_user_last_name'', '' '', ord.ind_schedule_user_info ->> ''ind_user_first_name'' ), 5 ), '''' ) AS ind_name10,
  COALESCE ( ord.ind_treat_start_time, '''' ) AS start_time,
  COALESCE ( mkr.in_hospital_cd_1, '''' ) AS kur_cd1,
  COALESCE ( mkr.kur_name, '''' ) AS kur_name,
  COALESCE ( mbd.bed_cd, 0 ) AS bed_cd,
  COALESCE ( mbd.in_hospital_cd_1, '''' ) AS bed_cd1,
  COALESCE ( mbd.bed_name, '''' ) AS bed_name,
  COALESCE ( mtt.treatment_name, '''' ) AS treatment_name,
  COALESCE ( mtt.in_hospital_cd_a1, '''' ) AS treatment_cd,
  COALESCE ( ord.ind_dw, 0 ) AS dw,
  TO_NUMBER( ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'' ) AS dialysis_time_m,
	case when RIGHT( (COALESCE (
    RIGHT ( ''00'' || TRUNC( TO_NUMBER( ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'' ) / 60, 0 ), 2 ) || RIGHT ( ''00'' || MOD ( TO_NUMBER( ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'' ), 60 ), 2 ),
    ''0''
  )::INTEGER + COALESCE ( ord.ind_treat_start_time, ''0'' )::INTEGER)::TEXT ,2)::INTEGER > 60
then(COALESCE (
    RIGHT ( ''00'' || TRUNC( TO_NUMBER( ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'' ) / 60, 0 ), 2 ) || RIGHT ( ''00'' || MOD ( TO_NUMBER( ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'' ), 60 ), 2 ),
    ''0''
  )::INTEGER + COALESCE ( ord.ind_treat_start_time, ''0'' )::INTEGER) + 100 - 60

else COALESCE (
    RIGHT ( ''00'' || TRUNC( TO_NUMBER( ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'' ) / 60, 0 ), 2 ) || RIGHT ( ''00'' || MOD ( TO_NUMBER( ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'' ), 60 ), 2 ),
    ''0''
  )::INTEGER + COALESCE ( ord.ind_treat_start_time, ''0'' )::INTEGER
END as end_time,
  COALESCE (
    RIGHT ( ''00'' || TRUNC( TO_NUMBER( ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'' ) / 60, 0 ), 2 ) || '':'' || RIGHT ( ''00'' || MOD ( TO_NUMBER( ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'' ), 60 ), 2 ),
    ''0''
  ) AS treatment_time,
  COALESCE (
    RIGHT ( ''00'' || TRUNC( TO_NUMBER( ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'' ) / 60, 0 ), 2 ) || RIGHT ( ''00'' || MOD ( TO_NUMBER( ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'' ), 60 ), 2 ),
    ''''
  ) AS treatment_time4,
  COALESCE ( ord.rst_cond_info -> ''1'' ->> ''value'', '''' ) AS treatment_time_m,--追加
  COALESCE ( ord.ind_cond_info -> ''2'' ->> ''value_name_1'', '''' ) AS va,
  COALESCE ( SUBSTRING ( ord.ind_cond_info -> ''2'' ->> ''value_name_1'', 1, 3 ), '''' ) AS va3,
  COALESCE ( mva.in_hospital_cd_1, '''' ) AS va_cd1,
  COALESCE (
    ( CASE mva.va_direct WHEN ''0'' THEN ''右'' WHEN ''1'' THEN ''左'' WHEN ''2'' THEN ''両方'' WHEN ''3'' THEN ''無'' ELSE''不明'' END ),
    ''''
  ) AS va_direct,
  COALESCE ( ord.ind_cond_info -> ''3'' ->> ''value'', '''' ) AS target_weight,
  COALESCE ( ord.ind_cond_info -> ''4'' ->> ''value'', '''' ) AS water_removal_amount_limit,
--ord.ind_cond_info->''5''->>''value_name_1'' as dialyzer,
  COALESCE ( mdr.model_number, '''' ) AS dialyzer,
--ord.ind_cond_info->''5''->>''value'' as dialyzer_cd,
  COALESCE ( mdr.in_hospital_cd_1, '''' ) AS dialyzer_cd1,
  COALESCE ( ord.ind_cond_info -> ''6'' ->> ''value_name_1'', '''' ) AS adsorption_column,
  COALESCE ( meqad.in_hospital_cd_1, '''' ) AS ad_cd1,
  COALESCE ( ord.ind_cond_info -> ''7'' ->> ''value_name_1'', '''' ) AS primary_film,
  COALESCE ( meqpr.in_hospital_cd_1, '''' ) AS pr_cd1,
  COALESCE ( ord.ind_cond_info -> ''8'' ->> ''value_name_1'', '''' ) AS secondary_film,
  COALESCE ( meqse.in_hospital_cd_1, '''' ) AS se_cd1,
--ord.ind_cond_info->''9''->>''value_name_1'' as puncture_needle_a,
  COALESCE ( meqa.equipment_name, '''' ) AS puncture_needle_a,
  COALESCE ( meqa.in_hospital_cd_1, '''' ) AS a_cd1,
--ord.ind_cond_info->''10''->>''value_name_1'' as puncture_needle_v,
  COALESCE ( meqv.equipment_name, '''' ) AS puncture_needle_v,
  COALESCE ( meqv.in_hospital_cd_1, '''' ) AS v_cd1,
--ord.ind_cond_info->''11''->>''value_name_1'' as puncture_needle_sn,
  COALESCE ( meqsn.equipment_name, '''' ) AS puncture_needle_sn,
  COALESCE ( meqsn.in_hospital_cd_1, '''' ) AS sn_cd1,
  COALESCE ( ( CASE ord.ind_cond_info -> ''12'' ->> ''value'' WHEN ''1'' THEN ''有り'' WHEN ''0'' THEN ''無し'' ELSE NULL END ), '''' ) AS single_needle,
  COALESCE ( ord.ind_cond_info -> ''13'' ->> ''value'', '''' ) AS blood_circuit,
  COALESCE ( meqbc.in_hospital_cd_1, '''' ) AS bc_cd1,
  COALESCE ( ord.ind_cond_info -> ''14'' ->> ''value'', '''' ) AS blood_flow,
--ord.ind_cond_info->''15''->>''value_name_1'' as dialysate,
  COALESCE ( med15.medicine_name, '''' ) AS dialysate,
  COALESCE ( med15.in_hospital_cd_1, '''' ) AS dialysate_cd1,
  COALESCE ( ord.ind_cond_info -> ''16'' ->> ''value'', '''' ) AS dialysate_flow_rate,
  COALESCE ( ord.ind_cond_info -> ''17'' ->> ''value'', '''' ) AS dialysate_amount,
--ord.ind_cond_info->''17''->>''unit'' as dialysate_amount_unit,
  COALESCE ( med15.unit, '''' ) AS dialysate_amount_unit,
  COALESCE ( ord.ind_cond_info -> ''18'' ->> ''value'', '''' ) AS dialysate_temperature,
--ord.ind_cond_info->''19''->>''value_name_1'' as fluid_replacement,
  COALESCE ( med25.medicine_name, '''' ) AS fluid_replacement,
  COALESCE ( med25.in_hospital_cd_1, '''' ) AS ds_cd1,
  COALESCE ( ord.ind_cond_info -> ''20'' ->> ''value'', '''' ) AS fluid_replacement_amount,
  COALESCE ( ( CASE ord.ind_cond_info -> ''21'' ->> ''value'' WHEN ''1'' THEN ''前補液'' WHEN ''0'' THEN ''後補液'' ELSE NULL END ), '''' ) AS fluid_replacement_timing,
  COALESCE ( ord.ind_cond_info -> ''22'' ->> ''value'', '''' ) AS fluid_replacement_use_count,
  COALESCE ( ord.ind_cond_info -> ''22'' ->> ''unit'', '''' ) AS fluid_replacement_use_count_unit,
  COALESCE ( ord.ind_cond_info -> ''23'' ->> ''value'', '''' ) AS fluid_replacement_temperature,
  COALESCE ( ord.ind_cond_info -> ''24'' ->> ''value'', '''' ) AS fluid_replacement_speed,
--ord.ind_cond_info->''25''->>''value_name_1'' as anti_coagulant,
  COALESCE ( med25.medicine_name, '''' ) AS anti_coagulant,
  COALESCE ( med25.in_hospital_cd_1, '''' ) AS anti_coagulant_cd1,
  COALESCE ( ord.ind_cond_info -> ''26'' ->> ''value'', '''' ) AS anti_coagulant_one_shot_amount,
--ord.ind_cond_info->''26''->>''unit'' as anti_coagulant_one_shot_amount_unit,
  COALESCE ( med25.unit, '''' ) AS anti_coagulant_one_shot_amount_unit,
  COALESCE ( ord.ind_cond_info -> ''27'' ->> ''value'', '''' ) AS anti_coagulant_sustained_speed,
  COALESCE ( ord.ind_cond_info -> ''27'' ->> ''unit'', '''' ) AS anti_coagulant_sustained_speed_unit,
  COALESCE ( ord.ind_cond_info -> ''28'' ->> ''value'', '''' ) AS anti_coagulant_sustained_amount,
  COALESCE ( ord.ind_cond_info -> ''28'' ->> ''unit'', '''' ) AS anti_coagulant_sustained_amount_unit,
  COALESCE (
    TO_NUMBER( ord.ind_cond_info -> ''26'' ->> ''value'', ''999999999999'' ) + TO_NUMBER( ord.ind_cond_info -> ''28'' ->> ''value'', ''999999999999'' ),
    0
  ) AS anti_coagulant_total_amount,--抗凝固剤総量
  COALESCE ( ( CASE ord.ind_cond_info -> ''29'' ->> ''value'' WHEN ''1'' THEN ''使用する'' WHEN ''0'' THEN ''使用しない'' ELSE NULL END ), '''' ) AS ip,
  COALESCE ( ( CASE ord.ind_cond_info -> ''30'' ->> ''value'' WHEN ''0'' THEN ''手動'' WHEN ''1'' THEN ''自動'' ELSE NULL END ), '''' ) AS ip_start,
  COALESCE ( ord.ind_cond_info -> ''31'' ->> ''value'', '''' ) AS ip_one_short_amount,
  COALESCE ( ord.ind_cond_info -> ''32'' ->> ''value'', '''' ) AS ip_speed,
  COALESCE ( ord.ind_cond_info -> ''33'' ->> ''value'', '''' ) AS ip_speed_max,
  COALESCE ( ( CASE ord.ind_cond_info -> ''34'' ->> ''value'' WHEN ''1'' THEN ''使用する'' WHEN ''0'' THEN ''使用しない'' ELSE NULL END ), '''' ) AS auto_one_shot,
  COALESCE ( ( CASE ord.ind_cond_info -> ''35'' ->> ''value'' WHEN ''1'' THEN ''入'' WHEN ''0'' THEN ''切'' ELSE NULL END ), '''' ) AS ip_auto_off,
  COALESCE ( ord.ind_cond_info -> ''36'' ->> ''value'', '''' ) AS ip_auto_off_time,
  COALESCE ( ( CASE ord.ind_cond_info -> ''37'' ->> ''value'' WHEN ''1'' THEN ''入'' WHEN ''0'' THEN ''切'' ELSE NULL END ), '''' ) AS ip_monitor_auto_off,
  COALESCE ( ord.ind_cond_info -> ''38'' ->> ''value'', '''' ) AS ip_monitor_auto_off_time,
  COALESCE ( pm.medical_care_info ->> ''dialysis_start_date'', '''' ) AS dialysis_start_date,
  COALESCE ( to_char( ord.up_date, ''YYYYMMDD'' ), '''' ) AS update_ymd,
  COALESCE ( to_char( ord.up_date, ''HH24MISS'' ), '''' ) AS update_hms
FROM
  pat_main AS pm,
  ord_main_restore AS ord
  LEFT OUTER JOIN mst_equipment AS meqa ON meqa.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''9'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_equipment AS meqv ON meqv.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''10'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_equipment AS meqsn ON meqsn.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''11'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_equipment AS meqad ON meqad.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''6'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_equipment AS meqpr ON meqpr.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''7'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_equipment AS meqbc ON meqbc.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''13'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_equipment AS meqse ON meqse.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''8'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_medicine AS med15 ON med15.medicine_cd = TO_NUMBER( ord.ind_cond_info -> ''15'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_medicine AS med19 ON med19.medicine_cd = TO_NUMBER( ord.ind_cond_info -> ''19'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_medicine AS med25 ON med25.medicine_cd = TO_NUMBER( ord.ind_cond_info -> ''25'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_treatment AS mtt ON mtt.treatment_cd = ord.ind_treatment_cd
  LEFT OUTER JOIN mst_dialyzer AS mdr ON mdr.dialyzer_cd = TO_NUMBER( ord.ind_cond_info -> ''5'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_va AS mva ON mva.va_cd = TO_NUMBER( ord.ind_cond_info -> ''2'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_bed AS mbd ON mbd.bed_cd = ord.ind_bed_cd
  LEFT OUTER JOIN mst_kur AS mkr ON mkr.kur_cd = ord.ind_kur_cd
WHERE
  ord.ord_no =@ordNo and
  pm.pat_id = ord.pat_id
	and ''0'' =(
   select count(*) from ord_main where ord_no =@ordNo) 
	ORDER BY ord.del_date desc
  limit 1
)
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）指示）透析条件', '2022-06-18 05:06:30.638', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-181, 'select  
''指示薬剤del''::TEXT as detail_id,
        a.medi_cd1
        ,case when ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd =@facilityCd 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''DIALYSISSCHESEND'' 
    AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'') and sum(medi_amount::Float)*100<100 then 
        (case when sum(medi_amount::Float)*100 >10 
        then ''0''||((sum(medi_amount::Float)*100)::TEXT) 
        else  ''00''||((sum(medi_amount::Float)*100)::TEXT)
         end) 
         else (sum(medi_amount::Float)*100)::TEXT end  as  medi_amount
        ,1 as medi_back
        ,a.medi_unit        
        from 
        (select
      ''指示薬剤1'' as detail_id,
        medc.in_hospital_cd_1 as medi_class_cd,
        medc.class_name as medi_class_type,
        mmd.medicine_name  as medi_name,
        case when medi ->> ''amount''  is null then ''0'' else 
        (case when char_length(split_part(medi ->> ''amount'' ,''.'', 2 ))>2 then ((split_part((((medi ->> ''amount'')::FLOAT)*100)::TEXT,''.'', 1 )::FLOAT)/100)::TEXT else medi ->> ''amount'' end)
 end  as medi_amount,
        mmd.unit as medi_unit,
      (case when mmd.unit_second is null then to_number(medi ->> ''amount'',''FM99999.99'') else (case  when mmd.is_exchange = ''0'' then to_number(medi ->> ''amount'',''FM99999.99'') / mmd.unit_converted_amount * mmd.unit_converted_amount_second   when mmd.is_exchange = ''1'' then trunc( to_number(medi ->> ''amount'',''FM99999.99'') / mmd.unit_converted_amount * mmd.unit_converted_amount_second + 0.9 ,0) when mmd.is_exchange = ''2'' then 1 else  to_number(medi ->> ''amount'',''FM99999.99'') end) end) as res_amount,
        mmd.unit_second as res_unit,
        medi ->> ''timing_name'' as medi_timing_name,
        mp.pricedure_name as procedure_name,
        mp.in_hospital_cd_a1 as procedure_cd1,
        mmd.in_hospital_cd_1 as medi_cd1,
        mmd.in_hospital_cd_2 as medi_cd2,
        mmd.in_hospital_cd_3 as medi_cd3,
        mmd.in_hospital_cd_4 as medi_cd4
    from
        mst_medicine_class as medc,
        ord_main as ord
    cross join lateral
        json_array_elements (ord.ind_medi_info :: json) medi
    left outer join
        mst_medicine as mmd
    on
        mmd.medicine_cd = TO_NUMBER (medi ->> ''cd'',''999999999999'')
    left outer join
        mst_procedure as mp
    on
        mp.procedure_cd = TO_NUMBER (medi ->> ''procedure_cd'',''999999999999'')
    where
        mmd.class_cd = medc.class_cd and 
        mmd.in_hospital_cd_1 is not null and
    ord.ord_no =  @ordNo)  as a 
		GROUP BY a.medi_cd1,a.medi_unit
			union all(
	select  
''指示薬剤del''::TEXT as detail_id,
        a.medi_cd1
        ,case when ''1''=(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd =@facilityCd 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''DIALYSISSCHESEND'' 
    AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'') and sum(medi_amount::Float)*100<100 then 
        (case when sum(medi_amount::Float)*100 >10 
        then ''0''||((sum(medi_amount::Float)*100)::TEXT) 
        else  ''00''||((sum(medi_amount::Float)*100)::TEXT)
         end) 
         else (sum(medi_amount::Float)*100)::TEXT end  as  medi_amount
        ,1 as medi_back
        ,a.medi_unit        
        from 
        (select
      ''指示薬剤1'' as detail_id,
        medc.in_hospital_cd_1 as medi_class_cd,
        medc.class_name as medi_class_type,
        mmd.medicine_name  as medi_name,
        case when medi ->> ''amount''  is null then ''0'' else 
        (case when char_length(split_part(medi ->> ''amount'' ,''.'', 2 ))>2 then ((split_part((((medi ->> ''amount'')::FLOAT)*100)::TEXT,''.'', 1 )::FLOAT)/100)::TEXT else medi ->> ''amount'' end)
 end  as medi_amount,
        mmd.unit as medi_unit,
      (case when mmd.unit_second is null then to_number(medi ->> ''amount'',''FM99999.99'') else (case  when mmd.is_exchange = ''0'' then to_number(medi ->> ''amount'',''FM99999.99'') / mmd.unit_converted_amount * mmd.unit_converted_amount_second   when mmd.is_exchange = ''1'' then trunc( to_number(medi ->> ''amount'',''FM99999.99'') / mmd.unit_converted_amount * mmd.unit_converted_amount_second + 0.9 ,0) when mmd.is_exchange = ''2'' then 1 else  to_number(medi ->> ''amount'',''FM99999.99'') end) end) as res_amount,
        mmd.unit_second as res_unit,
        medi ->> ''timing_name'' as medi_timing_name,
        mp.pricedure_name as procedure_name,
        mp.in_hospital_cd_a1 as procedure_cd1,
        mmd.in_hospital_cd_1 as medi_cd1,
        mmd.in_hospital_cd_2 as medi_cd2,
        mmd.in_hospital_cd_3 as medi_cd3,
        mmd.in_hospital_cd_4 as medi_cd4
    from
        mst_medicine_class as medc,
        ord_main_restore as ord
    cross join lateral
        json_array_elements (ord.ind_medi_info :: json) medi
    left outer join
        mst_medicine as mmd
    on
        mmd.medicine_cd = TO_NUMBER (medi ->> ''cd'',''999999999999'')
    left outer join
        mst_procedure as mp
    on
        mp.procedure_cd = TO_NUMBER (medi ->> ''procedure_cd'',''999999999999'')
    where
        mmd.class_cd = medc.class_cd and 
        mmd.in_hospital_cd_1 is not null and
    ord.ord_no =  @ordNo
		and ''0'' =(
    select count(*) from ord_main where ord_no = @ordNo)
		)  as a
		 GROUP BY a.medi_cd1,a.medi_unit)
    limit 135', 2, '[{}]', '1', '{"applications": [4]}', NULL, '指示）指示医材1コード', '2022-06-18 05:06:30.626', CURRENT_TIMESTAMP, NULL);
    INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-191, '	select 
 ''指示医材del'' as detail_id,
 row_number() over() as equip_no,
 all_equip.equip_class_type as class,
 all_equip.cd1 as cd1,
 all_equip.cd2 as cd2,
 all_equip.cd3 as cd3,
 all_equip.cd4 as cd4,
 all_equip.equip_name as name,
 all_equip.amount as amount,
 all_equip.unit as unit
from
(select
  ''吸着器'' as equip_class_type,
  --ord.ind_cond_info->''6''->>''value_name_1'' as name,
  meqad.equipment_name as equip_name,
  trim(meqad.in_hospital_cd_1) as cd1,--吸着器コード１
   trim(meqad.in_hospital_cd_2) as cd2,
   trim(meqad.in_hospital_cd_3) as cd3,
   trim(meqad.in_hospital_cd_4) as cd4,
  ''1'' as amount,
  meqad.unit
from
  ord_main as ord
left outer join
  mst_equipment as meqad
 on
  meqad.equipment_cd = TO_NUMBER (ord.ind_cond_info->''6''->>''value'',''999999999999'')
 where
  ord.ord_no =@ordNo

 union
 select
  ''1次膜'' as equip_class_type,
  --ord.ind_cond_info->''7''->>''value_name_1'' as primary_film,
  meqpr.equipment_name as equip_name,
  trim(meqpr.in_hospital_cd_1) as cd1,--1次膜コード１
   trim(meqpr.in_hospital_cd_2) as cd2,
   trim(meqpr.in_hospital_cd_3) as cd3,
   trim(meqpr.in_hospital_cd_4) as cd4,
  ''1'' as amount,
  meqpr.unit
 from
  ord_main as ord
  left outer join
  mst_equipment as meqpr
 on
  meqpr.equipment_cd = TO_NUMBER (ord.ind_cond_info->''7''->>''value'',''999999999999'')
  where
  ord.ord_no =@ordNo

 union
 select
  ''2次膜'' as equip_class_type,
  --ord.ind_cond_info->''8''->>''value_name_1'' as secondary_film,
  meqse.equipment_name as equip_name,
  trim(meqse.in_hospital_cd_1) as cd1,--2次膜コード１
   trim(meqse.in_hospital_cd_2) as cd2,
   trim(meqse.in_hospital_cd_3) as cd3,
   trim(meqse.in_hospital_cd_4) as cd4,
  ''1'' as amount,
  meqse.unit
  from
  ord_main as ord
  left outer join
  mst_equipment as meqse
 on
  meqse.equipment_cd = TO_NUMBER (ord.ind_cond_info->''8''->>''value'',''999999999999'')
  where
  ord.ord_no =@ordNo

 union
 select
  ''穿刺針A'' as equip_class_type,
  --ord.ind_cond_info->''9''->>''value_name_1'' as puncture_needle_a,
  meqa.equipment_name as equip_name,
  trim(meqa.in_hospital_cd_1) as cd1,--穿刺針Aコード１
   trim(meqa.in_hospital_cd_2) as cd2,
   trim(meqa.in_hospital_cd_3) as cd3,
   trim(meqa.in_hospital_cd_4) as cd4,
  ''1'' as amount,
  meqa.unit
 from
  ord_main ord
   left outer join
   mst_equipment as meqa
  on
   meqa.equipment_cd = TO_NUMBER (ord.ind_cond_info->''9''->>''value'',''999999999999'')
   where
  ord.ord_no =@ordNo

 union
 select
  ''穿刺針V'' as equip_class_type,
  --ord.ind_cond_info->''10''->>''value_name_1'' as puncture_needle_v,
  meqv.equipment_name as equip_name,
  trim(meqv.in_hospital_cd_1) as cd1,--穿刺針Vコード１
   trim(meqv.in_hospital_cd_2) as cd2,
   trim(meqv.in_hospital_cd_3) as cd3,
   trim(meqv.in_hospital_cd_4) as cd4,
  ''1'' as amount,
  meqv.unit
  from
  ord_main ord
   left outer join
   mst_equipment as meqv
  on
   meqv.equipment_cd = TO_NUMBER (ord.ind_cond_info->''10''->>''value'',''999999999999'')
   where
  ord.ord_no =@ordNo

 union
 select
  ''穿刺針SN'' as equip_class_type,
  --ord.ind_cond_info->''11''->>''value_name_1'' as puncture_needle_sn,
  meqsn.equipment_name as equip_name,
  trim(meqsn.in_hospital_cd_1) as cd1,--穿刺針SNコード１
   trim(meqsn.in_hospital_cd_2) as cd2,
   trim(meqsn.in_hospital_cd_3) as cd3,
   trim(meqsn.in_hospital_cd_4) as cd4,
  ''1'' as amount,
  meqsn.unit
   from
  ord_main ord
  left outer join
   mst_equipment as meqsn
  on
   meqsn.equipment_cd = TO_NUMBER (ord.ind_cond_info->''11''->>''value'',''999999999999'')
 where
  ord.ord_no =@ordNo

 union
 select
  ''血液回路'' as equip_class_type,
  --ord.ind_cond_info->''13''->>''value'' as blood_circuit,
  meqbc.equipment_name as equip_name,
  trim(meqbc.in_hospital_cd_1) as cd1, --血液回路コード１
  trim(meqbc.in_hospital_cd_2) as cd2,
  trim(meqbc.in_hospital_cd_3) as cd3,
  trim(meqbc.in_hospital_cd_4) as cd4,
  ''1'' as amount,
  meqbc.unit
from
  ord_main as ord
 left outer join
  mst_equipment as meqbc
 on
  meqbc.equipment_cd = TO_NUMBER (ord.ind_cond_info->''13''->>''value'',''999999999999'')
where
 ord.ord_no =@ordNo

union
select
   --equip ->> ''class_type'' as equip_class_type,
   --equip ->> ''name'' as equip_name,
   meqc.class_name  as equip_class_type,
   meq.equipment_name as equip_name,
   trim(meq.in_hospital_cd_1) as cd1,
   trim(meq.in_hospital_cd_2) as cd2,
   trim(meq.in_hospital_cd_3) as cd3,
   trim(meq.in_hospital_cd_4) as cd4,
   equip ->> ''amount'' as equip_amount,
   meq.unit as equip_unit
    from
      mst_equipment_class as meqc,
      ord_main as ord
    cross join lateral
      json_array_elements (ord.ind_equip_info :: json) equip
 left outer join
   mst_equipment as meq
 on
   meq.equipment_cd = TO_NUMBER (equip ->> ''cd'',''999999999999'')
    where
      meq.class_cd = meqc.class_cd and
      ord.ord_no =@ordNo
) all_equip
where
 all_equip.cd1 is not null
 union all
 (select 
 ''指示医材del'' as detail_id,
 row_number() over() as equip_no,
 all_equip.equip_class_type as class,
 all_equip.cd1 as cd1,
 all_equip.cd2 as cd2,
 all_equip.cd3 as cd3,
 all_equip.cd4 as cd4,
 all_equip.equip_name as name,
 all_equip.amount as amount,
 all_equip.unit as unit
from
(select
  ''吸着器'' as equip_class_type,
  --ord.ind_cond_info->''6''->>''value_name_1'' as name,
  meqad.equipment_name as equip_name,
  trim(meqad.in_hospital_cd_1) as cd1,--吸着器コード１
   trim(meqad.in_hospital_cd_2) as cd2,
   trim(meqad.in_hospital_cd_3) as cd3,
   trim(meqad.in_hospital_cd_4) as cd4,
  ''1'' as amount,
  meqad.unit
from
  ord_main_restore as ord
left outer join
  mst_equipment as meqad
 on
  meqad.equipment_cd = TO_NUMBER (ord.ind_cond_info->''6''->>''value'',''999999999999'')
 where
  ord.ord_no =@ordNo
  and ''0'' =(
      select count(*) from ord_main where ord_no =@ordNo)
 union
 select
  ''1次膜'' as equip_class_type,
  --ord.ind_cond_info->''7''->>''value_name_1'' as primary_film,
  meqpr.equipment_name as equip_name,
  trim(meqpr.in_hospital_cd_1) as cd1,--1次膜コード１
   trim(meqpr.in_hospital_cd_2) as cd2,
   trim(meqpr.in_hospital_cd_3) as cd3,
   trim(meqpr.in_hospital_cd_4) as cd4,
  ''1'' as amount,
  meqpr.unit
 from
  ord_main_restore as ord
  left outer join
  mst_equipment as meqpr
 on
  meqpr.equipment_cd = TO_NUMBER (ord.ind_cond_info->''7''->>''value'',''999999999999'')
  where
  ord.ord_no =@ordNo
  and ''0'' =(
      select count(*) from ord_main where ord_no =@ordNo)
 union
 select
  ''2次膜'' as equip_class_type,
  --ord.ind_cond_info->''8''->>''value_name_1'' as secondary_film,
  meqse.equipment_name as equip_name,
  trim(meqse.in_hospital_cd_1) as cd1,--2次膜コード１
   trim(meqse.in_hospital_cd_2) as cd2,
   trim(meqse.in_hospital_cd_3) as cd3,
   trim(meqse.in_hospital_cd_4) as cd4,
  ''1'' as amount,
  meqse.unit
  from
  ord_main_restore as ord
  left outer join
  mst_equipment as meqse
 on
  meqse.equipment_cd = TO_NUMBER (ord.ind_cond_info->''8''->>''value'',''999999999999'')
  where
  ord.ord_no =@ordNo
  and ''0'' =(
      select count(*) from ord_main where ord_no =@ordNo)
 union
 select
  ''穿刺針A'' as equip_class_type,
  --ord.ind_cond_info->''9''->>''value_name_1'' as puncture_needle_a,
  meqa.equipment_name as equip_name,
  trim(meqa.in_hospital_cd_1) as cd1,--穿刺針Aコード１
   trim(meqa.in_hospital_cd_2) as cd2,
   trim(meqa.in_hospital_cd_3) as cd3,
   trim(meqa.in_hospital_cd_4) as cd4,
  ''1'' as amount,
  meqa.unit
 from
  ord_main_restore ord
   left outer join
   mst_equipment as meqa
  on
   meqa.equipment_cd = TO_NUMBER (ord.ind_cond_info->''9''->>''value'',''999999999999'')
   where
  ord.ord_no =@ordNo
  and ''0'' =(
      select count(*) from ord_main where ord_no =@ordNo)
 union
 select
  ''穿刺針V'' as equip_class_type,
  --ord.ind_cond_info->''10''->>''value_name_1'' as puncture_needle_v,
  meqv.equipment_name as equip_name,
  trim(meqv.in_hospital_cd_1) as cd1,--穿刺針Vコード１
   trim(meqv.in_hospital_cd_2) as cd2,
   trim(meqv.in_hospital_cd_3) as cd3,
   trim(meqv.in_hospital_cd_4) as cd4,
  ''1'' as amount,
  meqv.unit
  from
  ord_main_restore ord
   left outer join
   mst_equipment as meqv
  on
   meqv.equipment_cd = TO_NUMBER (ord.ind_cond_info->''10''->>''value'',''999999999999'')
   where
  ord.ord_no =@ordNo
  and ''0'' =(
      select count(*) from ord_main where ord_no =@ordNo)
 union
 select
  ''穿刺針SN'' as equip_class_type,
  --ord.ind_cond_info->''11''->>''value_name_1'' as puncture_needle_sn,
  meqsn.equipment_name as equip_name,
  trim(meqsn.in_hospital_cd_1) as cd1,--穿刺針SNコード１
   trim(meqsn.in_hospital_cd_2) as cd2,
   trim(meqsn.in_hospital_cd_3) as cd3,
   trim(meqsn.in_hospital_cd_4) as cd4,
  ''1'' as amount,
  meqsn.unit
   from
  ord_main_restore ord
  left outer join
   mst_equipment as meqsn
  on
   meqsn.equipment_cd = TO_NUMBER (ord.ind_cond_info->''11''->>''value'',''999999999999'')
 where
  ord.ord_no =@ordNo
  and ''0'' =(
      select count(*) from ord_main where ord_no =@ordNo)
 union
 select
  ''血液回路'' as equip_class_type,
  --ord.ind_cond_info->''13''->>''value'' as blood_circuit,
  meqbc.equipment_name as equip_name,
  trim(meqbc.in_hospital_cd_1) as cd1, --血液回路コード１
  trim(meqbc.in_hospital_cd_2) as cd2,
  trim(meqbc.in_hospital_cd_3) as cd3,
  trim(meqbc.in_hospital_cd_4) as cd4,
  ''1'' as amount,
  meqbc.unit
from
  ord_main_restore as ord
 left outer join
  mst_equipment as meqbc
 on
  meqbc.equipment_cd = TO_NUMBER (ord.ind_cond_info->''13''->>''value'',''999999999999'')
where
 ord.ord_no =@ordNo
 and ''0'' =(
      select count(*) from ord_main where ord_no =@ordNo)
union
select
   --equip ->> ''class_type'' as equip_class_type,
   --equip ->> ''name'' as equip_name,
   meqc.class_name  as equip_class_type,
   meq.equipment_name as equip_name,
   trim(meq.in_hospital_cd_1) as cd1,
   trim(meq.in_hospital_cd_2) as cd2,
   trim(meq.in_hospital_cd_3) as cd3,
   trim(meq.in_hospital_cd_4) as cd4,
   equip ->> ''amount'' as equip_amount,
   meq.unit as equip_unit
    from
      mst_equipment_class as meqc,
      ord_main_restore as ord
    cross join lateral
      json_array_elements (ord.ind_equip_info :: json) equip
 left outer join
   mst_equipment as meq
 on
   meq.equipment_cd = TO_NUMBER (equip ->> ''cd'',''999999999999'')
    where
      meq.class_cd = meqc.class_cd and
      ord.ord_no =@ordNo
			and ''0'' =(
      select count(*) from ord_main where ord_no =@ordNo)
) all_equip
where
 all_equip.cd1 is not null)
limit 12
', 2, '[{}]', '1', '{"applications": [4]}', NULL, '指示）投与薬剤コード', '2022-06-18 05:06:30.633', CURRENT_TIMESTAMP, NULL);


