delete from ntss.sys_data_set where sql_cd in (-78, -59, -53, -502, -194, -131,-132,-661,-191);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-131, 'SELECT
  ord.treat_date AS dialysis_date,
  ord.facility_cd AS facility_cd,
  COALESCE ( concat ( ord.ind_schedule_user_info ->> ''ind_user_last_name'', '' '', ord.ind_schedule_user_info ->> ''ind_user_first_name'' ), '''' ) AS ind_name,
  COALESCE ( LEFT ( concat ( ord.ind_schedule_user_info ->> ''ind_user_last_name'', '' '', ord.ind_schedule_user_info ->> ''ind_user_first_name'' ), 5 ), '''' ) AS ind_name10,
   COALESCE ( SUBSTRING ( (ord.ind_schedule_user_info->''ind_treat_start_time'')::text, 2, 4 ), '''' ) AS start_time,
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
  )::INTEGER + COALESCE ( SUBSTRING ( (ord.ind_schedule_user_info->''ind_treat_start_time'')::text, 2, 4 ), ''0'' )::INTEGER)::TEXT ,2)::INTEGER >= 60
then(COALESCE (
    RIGHT ( ''00'' || TRUNC( TO_NUMBER( ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'' ) / 60, 0 ), 2 ) || RIGHT ( ''00'' || MOD ( TO_NUMBER( ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'' ), 60 ), 2 ),
    ''0''
  )::INTEGER + COALESCE ( SUBSTRING ( (ord.ind_schedule_user_info->''ind_treat_start_time'')::text, 2, 4 ), ''0'' )::INTEGER) + 100 - 60

else COALESCE (
    RIGHT ( ''00'' || TRUNC( TO_NUMBER( ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'' ) / 60, 0 ), 2 ) || RIGHT ( ''00'' || MOD ( TO_NUMBER( ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'' ), 60 ), 2 ),
    ''0''
  )::INTEGER + COALESCE ( SUBSTRING ( (ord.ind_schedule_user_info->''ind_treat_start_time'')::text, 2, 4 ), ''0'' )::INTEGER
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
  COALESCE ( med15.unit_second, '''' ) AS dialysate_amount_unit,
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
  )::INTEGER + COALESCE ( ord.ind_treat_start_time, ''0'' )::INTEGER)::TEXT ,2)::INTEGER >= 60
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
  COALESCE ( med15.unit_second, '''' ) AS dialysate_amount_unit,
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
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）指示）透析条件', '2022-06-18 05:06:30.638',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-502, 'WITH dialysateSql AS (
    SELECT
        1 AS order_no,
        COALESCE ( NULLIF(info ->> ''value'', ''''), info ->> ''default_v'' ) :: INT AS dialysateTransCd 
    FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
    WHERE
        facility_cd = @facilityCd
        
        AND is_del = ''0'' 
                -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 start
                AND COALESCE(info ->> ''key0'', '''') = @key0
                -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 end
        AND info ->> ''key1'' = ''DIALYSISSCHESEND'' 
        AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'' UNION
    SELECT
        2 AS order_no,
        0 AS dialysateTransCd 
    ORDER BY
        order_no ASC 
        LIMIT 1 
    ) 
		
		SELECT
CASE
        
    WHEN
        ( ord.ind_cond_info -> ''17'' ->> ''value'' ) ISNULL THEN
            ( CASE dialysateSql.dialysateTransCd WHEN 0 THEN ''0'' WHEN 1 THEN ''000'' END ) 
                WHEN ( ord.ind_cond_info -> ''17'' ->> ''value'' ) :: NUMERIC >= 1 THEN
                (
                CASE
                        WHEN strpos( ( ord.ind_cond_info -> ''17'' ->> ''value'' ), ''.'' ) <= 0 THEN
                        TRIM ( to_char( ( ( ord.ind_cond_info -> ''17'' ->> ''value'' ) :: NUMERIC ) * 100, ''999999'' ) ) ELSE TRIM (
                            to_char(
                                (
                                    SUBSTR(
                                        TRIM ( ( ord.ind_cond_info -> ''17'' ->> ''value'' ) ),
                                        0,
                                        strpos( ( ord.ind_cond_info -> ''17'' ->> ''value'' ), ''.'' ) + 3 
                                    ) :: NUMERIC 
                                ) * 100,
                                ''999999'' 
                            ) 
                        ) 
                    END 
                        ) ELSE (
                    CASE
                            dialysateSql.dialysateTransCd 
                            WHEN 0 THEN
                            TRIM (
                                to_char(
                                    ( SUBSTR( TRIM ( ( ord.ind_cond_info -> ''17'' ->> ''value'' ) ), 0, 5 ) :: NUMERIC ) * 100,
                                    ''99'' 
                                ) 
                            ) 
                            WHEN 1 THEN
                            TRIM (
                                to_char(
                                    ( SUBSTR( TRIM ( ( ord.ind_cond_info -> ''17'' ->> ''value'' ) ), 0, 5 ) :: NUMERIC ) * 100,
                                    ''000'' 
                                ) 
                            ) 
                        END 
                        ) 
                    END AS dialysate_amount 
                FROM
                    ord_main ord,
                    dialysateSql 
            WHERE
    ord.ord_no = @ordNo
		UNION
		SELECT
CASE
        
    WHEN
        ( ord.ind_cond_info -> ''17'' ->> ''value'' ) ISNULL THEN
            ( CASE dialysateSql.dialysateTransCd WHEN 0 THEN ''0'' WHEN 1 THEN ''000'' END ) 
                WHEN ( ord.ind_cond_info -> ''17'' ->> ''value'' ) :: NUMERIC >= 1 THEN
                (
                CASE
                        WHEN strpos( ( ord.ind_cond_info -> ''17'' ->> ''value'' ), ''.'' ) <= 0 THEN
                        TRIM ( to_char( ( ( ord.ind_cond_info -> ''17'' ->> ''value'' ) :: NUMERIC ) * 100, ''999999'' ) ) ELSE TRIM (
                            to_char(
                                (
                                    SUBSTR(
                                        TRIM ( ( ord.ind_cond_info -> ''17'' ->> ''value'' ) ),
                                        0,
                                        strpos( ( ord.ind_cond_info -> ''17'' ->> ''value'' ), ''.'' ) + 3 
                                    ) :: NUMERIC 
                                ) * 100,
                                ''999999'' 
                            ) 
                        ) 
                    END 
                        ) ELSE (
                    CASE
                            dialysateSql.dialysateTransCd 
                            WHEN 0 THEN
                            TRIM (
                                to_char(
                                    ( SUBSTR( TRIM ( ( ord.ind_cond_info -> ''17'' ->> ''value'' ) ), 0, 5 ) :: NUMERIC ) * 100,
                                    ''99'' 
                                ) 
                            ) 
                            WHEN 1 THEN
                            TRIM (
                                to_char(
                                    ( SUBSTR( TRIM ( ( ord.ind_cond_info -> ''17'' ->> ''value'' ) ), 0, 5 ) :: NUMERIC ) * 100,
                                    ''000'' 
                                ) 
                            ) 
                        END 
                        ) 
                    END AS dialysate_amount 
                FROM
                    ord_main_restore ord,
                    dialysateSql 
            WHERE
    ord.ord_no = @ordNo
		AND (SELECT COUNT(1) FROM ord_main WHERE ord_no = @ordNo )=''0''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(送信用)日機装)ind_dial連携:透析液使用量（単体薬剤）DEL', '2022-08-05 11:01:18.916',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-53, 'WITH sch_start_time_info AS (
  SELECT
    0 AS order_no 
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS start_time_kbn 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info ->> ''key1'' = ''COOP_CONFIG'' 
    AND info ->> ''key2'' = ''SCH_START_TIME'' 
  UNION
  SELECT
    1 AS order_no 
    , ''0'' AS start_time_kbn 
  ORDER BY order_no ASC LIMIT 1
)
, start_time_info AS (
SELECT
  CASE WHEN (SELECT start_time_kbn FROM sch_start_time_info) = ''0''
  THEN mk.kur_standard_start_time
  ELSE  SUBSTRING ( (ord.ind_schedule_user_info->''ind_treat_start_time'')::text, 2, 4 ) || ''00''
  END AS start_time,
	RIGHT(''00''||TRUNC(TO_NUMBER(ord.ind_cond_info->''1''->>''value'',''9999'')/60,0),2)||'':''||RIGHT(''00''||MOD(TO_NUMBER(ord.ind_cond_info->''1''->>''value'',''9999''),60),2) AS treat_time
FROM 
  ord_main ord
LEFT OUTER JOIN
  mst_kur mk
ON
(ord.ind_schedule_user_info->''ind_kur_cd'')::TEXT = mk.kur_cd::text
WHERE
  ord.ord_no = @ordNo
	union 
(SELECT
  CASE WHEN (SELECT start_time_kbn FROM sch_start_time_info) = ''0''
  THEN mk.kur_standard_start_time
  ELSE ord.ind_treat_start_time || ''00''
  END AS start_time,
	RIGHT(''00''||TRUNC(TO_NUMBER(ord.ind_cond_info->''1''->>''value'',''9999'')/60,0),2)||'':''||RIGHT(''00''||MOD(TO_NUMBER(ord.ind_cond_info->''1''->>''value'',''9999''),60),2) AS treat_time
FROM 
  ord_main_restore ord
LEFT OUTER JOIN
  mst_kur mk
ON
  ord.ind_kur_cd = mk.kur_cd
WHERE
  ord.ord_no = @ordNo
and (select count(1) from ord_main where ord_no = @ordNo)=''0''
order by ord.del_date desc limit 1)
)
SELECT
  ord.treat_date AS start_date,
  (SELECT start_time FROM start_time_info) AS start_time,
  to_char((cast(ord.treat_date as date) ||'' ''|| cast((SELECT start_time FROM start_time_info) as time))::TIMESTAMP + ((SELECT treat_time FROM start_time_info) || ''H'')::interval, ''YYYYMMDD'') AS end_date,
  to_char((cast(ord.treat_date as date) ||'' ''|| cast((SELECT start_time FROM start_time_info) as time))::TIMESTAMP + ((SELECT treat_time FROM start_time_info) || ''H'')::interval, ''HH24MISS'') AS end_time
FROM 
  ord_main ord
WHERE
  ord.ord_no = @ordNo
union
(SELECT
  ord.treat_date AS start_date,
  (SELECT start_time FROM start_time_info) AS start_time,
  to_char((cast(ord.treat_date as date) ||'' ''|| cast((SELECT start_time FROM start_time_info) as time))::TIMESTAMP + ((SELECT treat_time FROM start_time_info) || ''H'')::interval, ''YYYYMMDD'') AS end_date,
  to_char((cast(ord.treat_date as date) ||'' ''|| cast((SELECT start_time FROM start_time_info) as time))::TIMESTAMP + ((SELECT treat_time FROM start_time_info) || ''H'')::interval, ''HH24MISS'') AS end_time
FROM 
  ord_main_restore ord
WHERE
  ord.ord_no = @ordNo
	and (select count(1) from ord_main where ord_no = @ordNo)=''0''
order by del_date desc limit 1)
', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）透析予約：予約時間取得', '2022-02-23 16:10:41.424',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-78, 'WITH document_no_info AS(
  SELECT
    ''0'' AS order_no 
    , CASE WHEN COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') = ''1'' 
      THEN ''01''
      ELSE ''00'' 
      END AS document_no 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info->>''key1'' = ''FJI_COM_INFO''
    AND info->>''key2'' = ''DOCUMENT_NO_SETTING''
  UNION
  SELECT
    ''1'' AS order_no 
    , ''00'' AS document_no 
  ORDER BY order_no ASC LIMIT 1
)
, ord_coop_no_info AS (
  SELECT
    ctl_no,
		ord_no,
		facility_cd,
	  coop_ord_no
  FROM
	  ord_coop_no
	WHERE
	  pat_id = @patId
		AND
		ord_no = @ordNo
-- add 2023-01-18 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
		AND facility_cd = @facilityCd 
		AND coop_version = @coopVersion 
-- add 2023-01-18 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
	ORDER BY
	  up_date DESC
	LIMIT 1
)
, ord_main_restore_info AS (
 (SELECT
	  ord_no,
		facility_cd
	FROM
	  ord_main
			WHERE
	  ord_no = @ordNo
		AND
		facility_cd = @facilityCd )
		UNION 
  (SELECT
	  ord_no,
		facility_cd
	FROM
	  ord_main_restore
	WHERE
	  ord_no = @ordNo
		AND
		facility_cd = @facilityCd 
	ORDER BY
	  del_date DESC
	LIMIT 1)
)
SELECT
  ocn.coop_ord_no || (SELECT document_no FROM document_no_info) AS ord_no
FROM
  ord_main_restore_info AS ord
	, ord_coop_no_info AS ocn
WHERE
  ord.ord_no = @ordNo
	AND ord.facility_cd = @facilityCd 
	AND ord.ord_no = ocn.ord_no
	AND ord.facility_cd = ocn.facility_cd', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）透析予約：文書番号(オーダ番号)取得', '2022-09-06 01:55:56.256',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-194, 'WITH dialysis_item_send AS (-- 透析項目送信
 SELECT
  info ->> ''key2'' AS key2,
  COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS VALUE
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
 WHERE
  facility_cd = @facilityCd
  AND is_del = ''0'' 
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
  AND COALESCE(info->>''key0'','''') = @key0
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
  AND info ->> ''key1'' = ''DIALYSIS_ITEM_SEND'' 
)
, do_ord_main AS (
(SELECT 
ord_no,
null as del_date,
pat_id,
fn_pat_id,
treat_date,
treat_week,
facility_cd,
facility_name,
ind_va_cd,
ind_treatment_cd,
ind_treatment_name,
ind_kur_cd,
ind_kur_name,
ind_treat_start_time,
ind_bed_cd,
ind_bed_name,
ind_schedule_user_info,
ind_cond_info,
ind_medi_info,
ind_equip_info,
ind_ind_comment_info,
ind_tare_info,
ind_off_water_info,
ind_device_set_info,
rst_fn_dialysis_no,
rst_relation_dialysis_no,
rst_edition,
rst_is_update_edition,
rst_input_class,
rst_dialysis_state,
rst_treatment_cd,
rst_treatment_name,
rst_kur_cd,
rst_kur_name,
rst_bed_cd,
rst_bed_name,
rst_machine_no,
rst_machine_name,
rst_cond_send_date,
rst_accept_date,
rst_start_date,
rst_end_date,
rst_return_home_date,
rst_in_out_class,
rst_dialysis_cnt,
rst_ward_cd,
rst_ward_name,
rst_course_cd,
rst_course_name,
rst_puncture_user_info,
rst_return_user_info,
rst_charge_user_info,
rst_blood_circulate_total,
rst_running_time,
rst_kt_v,
rec_set_date,
send_ctl_no,
blood_purifier_name,
pull_leave_amount,
rst_cond_info,
rst_medi_info,
rst_equip_info,
rst_ind_comment_info,
rst_tare_info,
rst_off_water_info,
rst_device_set_info,
rst_weight_info,
rst_vital_info,
rst_complaint_info,
rst_treatment_info,
rst_treat_staff_info,
rst_rounds_info,
is_del,
up_date ,
up_ind_user_id,
up_user_id,
reg_date,
treat_type,
rst_purification_cnt,
rst_dw,
weight_scale_no,
fn_plural,
is_confirm,
ind_dw,
addition_info,
rst_edition_date,
cur_edition_date,
bvms_path
 FROM ord_main as ord_i
WHERE ord_i.ord_no =  @ordNo
 AND ord_i.facility_cd = @facilityCd)
 UNION all
(SELECT 
*
FROM ord_main_restore as ord_i
WHERE ord_i.ord_no =  @ordNo
 AND ord_i.facility_cd = @facilityCd
 AND (SELECT count(1) FROM ord_main as ord_i
WHERE ord_i.ord_no =  @ordNo)=''0''
ORDER BY del_date DESC LIMIT 1)
)
,item_set_info AS (
  --連携設定の項目設定値
  SELECT
    info->>''key2'' AS key2 
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS value 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info ->> ''key1'' = ''DIALYSIS_ITEM_SEND'' 
)
, item_sort_info AS (
  --連携設定「項目情報部出力順（予約/実績送信用）」の設定値
  SELECT
    info->>''key2'' AS key2 
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS value 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info->>''key1'' = ''DIALYSIS_ITEM_SORT''
)
, ind_set_medicine_resolve_info AS (
  --セット薬剤の扱いの設定値
  SELECT
    info ->> ''key2'' AS key2 
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS value 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info 
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info ->> ''key1'' = ''IND_SET_MEDICINE_RESOLVE'' 
)
, solution_cnt AS (
  --透析液取得件数
  SELECT 
    COUNT(*) AS cnt
  FROM
    do_ord_main ord
  LEFT OUTER JOIN
     mst_medicine mmd ON mmd.medicine_cd = TO_NUMBER(ord.ind_cond_info->''15''->>''value'',''999999999999'')
  WHERE
    (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''SOLUTION_RESOLVE_MODE'') = ''0''
)
, dialysis_item_procedure_tag_info AS (
  --手技タグ名称の設定値
  SELECT
    info ->> ''key2'' AS key2 
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS value 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info 
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info ->> ''key1'' = ''DIALYSIS_ITEM_PROCEDURE_TAG'' 
)
,  device AS (
        SELECT device_mode
        FROM mst_treatment mst JOIN do_ord_main ord 
        ON ord.ind_treatment_cd = mst.treatment_cd 
)
, fji_com_info AS (-- 富士通共通設定
 SELECT
  info ->> ''key2'' AS key2,
  COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS VALUE
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
 WHERE
  facility_cd = @facilityCd
  AND is_del = ''0'' 
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
  AND COALESCE(info->>''key0'','''') = @key0
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
  AND info ->> ''key1'' = ''FJI_COM_INFO'' 
 )
, dialyis_item_sort AS (-- 項目情報部出力順（予約/実績送信用）
 SELECT
  info ->> ''key2'' AS key2,
  COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS VALUE 
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
 WHERE
  facility_cd =  @facilityCd
  AND is_del = ''0'' 
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
  AND COALESCE(info->>''key0'','''') = @key0
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
  AND info ->> ''key1'' = ''DIALYSIS_ITEM_SORT'' 
 )
, conv_teart_item_send_out AS ( -- 浄化方法変換（予約/実績送信用：外来）
 SELECT
  info ->> ''key2'' AS key2,
  UNNEST ( STRING_TO_ARRAY( ( COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) ), '','' ) ) AS VALUE
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
 WHERE
  facility_cd = @facilityCd
  AND is_del = ''0'' 
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
  AND COALESCE(info->>''key0'','''') = @key0
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
  AND info ->> ''key1'' = ''CONV_TREAT_ITEM_SEND_OUT'' 
 )
, conv_treat_item_send_in AS ( -- 浄化方法変換（予約/実績送信用：入院）
 SELECT
  info ->> ''key2'' AS key2,
  UNNEST ( string_to_array( COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ), '','' ) ) AS VALUE
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
 WHERE
  facility_cd = @facilityCd
  AND is_del = ''0'' 
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
  AND COALESCE(info->>''key0'','''') = @key0
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
  AND info ->> ''key1'' = ''CONV_TREAT_ITEM_SEND_IN'' 
 )
, dialysis_send AS ( -- 透析发送
 SELECT
  info ->> ''key2'' AS key2,
  COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS VALUE
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
 WHERE
  facility_cd = @facilityCd
  AND is_del = ''0'' 
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
  AND COALESCE(info->>''key0'','''') = @key0
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
  AND info ->> ''key1'' = ''DIALYSIS_SEND'' 
 )
, int_set_medicine_resolve AS ( -- 薬剤分類が「透析液」のもの。セット薬剤の扱いについては、連携設定に従う。
 SELECT
  info ->> ''key2'' AS key2,
  COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS VALUE
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
 WHERE
  facility_cd = @facilityCd
  AND is_del = ''0'' 
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
  AND COALESCE(info->>''key0'','''') = @key0
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
  AND info ->> ''key1'' = ''IND_SET_MEDICINE_RESOLVE'' 
 )
, DIALYSIS_ITEM_PROCEDURE_TAG AS( -- 連携設定「手技あり１～１０－手技コード」 
  SELECT
   info ->> ''key2'' AS key2,
   COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS VALUE 
  FROM
   mst_coop_ini AS ini
   CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
  WHERE
   facility_cd = @facilityCd
   AND is_del = ''0'' 
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
  AND COALESCE(info->>''key0'','''') = @key0
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
   AND info ->> ''key1'' = ''DIALYSIS_ITEM_PROCEDURE_TAG'' 
 )
 , bed_conv as(       
    SELECT
    0 AS order_no,
        to_number(COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ), ''9999999999'') AS bed_conv
     FROM
        mst_coop_ini AS ini
   CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
     WHERE
    facility_cd = @facilityCd
    AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
        AND info ->> ''key1'' = ''FJI_COM_INFO'' 
        AND info ->> ''key2'' = ''BED_CODE_CONV'' UNION
    SELECT
        1 AS order_no,
        1 AS bed_conv 
    ORDER BY
        order_no ASC 
        LIMIT 1 
)
, dialysis_difficulty_info AS ( 
    SELECT ROW_NUMBER
        ( ) OVER ( ) AS row_no,
        details 
    FROM
        ( SELECT regexp_split_to_table( ''182''
, '','' ) AS details ) AS T)
, do_order_data_equip_from AS ( --施設設定106设置获取
SELECT ROW_NUMBER () OVER () AS no2, TO_NUMBER(datt.a1  :: text, ''999999999999'') AS ora
FROM (SELECT TO_NUMBER((unnest(string_to_array((
SELECT mst_f.value AS rtt
  FROM mst_facility_setting AS mst_f 
  WHERE mst_f.facility_setting_no = ''3006'' AND mst_f.facility_cd = @facilityCd
),'',''))), ''999999999999'') AS a1) AS datt)
, do_mstmeq_cd AS (--医療材料マスタ表示顺
SELECT index_no AS meq_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_code, order_cd ->> ''name'' AS meq_code_name
FROM mst_selector
    CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd
AND master_physical_name = ''mst_equipment'' )
, do_mstmeq_class_cd AS (--医療材料分類マスタ表示顺
SELECT index_no AS meq_class_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_class_code, order_cd ->> ''name'' AS meq_class_code_name
FROM mst_selector
    CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd
AND master_physical_name = ''mst_equipment_class'' )
, do_order_data_from AS (--施設設定107设置获取
SELECT ROW_NUMBER () OVER () AS no2, datt.a1
FROM (SELECT TO_NUMBER((unnest(string_to_array((
SELECT mst_f.value AS rtt
  FROM mst_facility_setting AS mst_f
  WHERE mst_f.facility_setting_no = ''3007'' AND mst_f.facility_cd = @facilityCd
),'',''))), ''999999999999'') AS a1) AS datt)
, do_medicine_mix_cd AS (
SELECT index_no AS medi_mix_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_mix_code, order_cd ->> ''name'' AS medi_mix_code_name
FROM mst_selector
     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd
 
   AND master_physical_name = ''mst_medicine_mix'' 
)
, do_mstmedi_cd AS (
SELECT index_no AS medi_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_code, order_cd ->> ''name'' AS medi_code_name
FROM mst_selector
     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd
 
   AND master_physical_name = ''mst_medicine'' 
)
, do_mstmedi_class_cd AS (
SELECT index_no AS medi_class_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_class_code, order_cd ->> ''name'' AS medi_class_code_name
FROM mst_selector
     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd
 
   AND master_physical_name = ''mst_medicine_class'' 
)
, do_mst_timing AS (
SELECT index_no AS timing_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS timing_code, order_cd ->> ''name'' AS timing_code_name
FROM mst_selector
     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd
 
   AND master_physical_name = ''mst_medicate_timing'' 
)
, do_mst_procedure AS (
SELECT index_no AS procedure_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS procedure_code, order_cd ->> ''name'' AS procedure_code_name
FROM mst_selector
     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd
 
   AND master_physical_name = ''mst_procedure'' 
)
,kou_coag_procedur_falg AS (
    SELECT
        1 AS ctl 
    FROM
        (
        SELECT COUNT
            ( * ) AS cnt 
        FROM
            ind_set_medicine_resolve_info 
        WHERE
            ( key2 IN ( ''KOU_COAG_PROCEDURE_ATTR'' ) AND ( ( VALUE IS NOT NULL ) AND VALUE <> '''' ) AND VALUE <> ''0'' ) 
            OR ( key2 IN ( ''KOU_COAG_PROCEDURE_CODE'' ) AND ( ( VALUE IS NOT NULL ) AND VALUE <> '''' ) AND VALUE <> ''0'' ) 
            OR ( key2 IN ( ''KOU_COAG_PROCEDURE_NAME'' ) AND ( ( VALUE IS NOT NULL ) AND VALUE <> '''' ) AND VALUE <> ''0'' ) 
        ) T 
    WHERE
        cnt = 3 UNION
    SELECT
        2 AS ctl 
    ORDER BY
        ctl 
        LIMIT 1
    ) 
, kou_coag_procedur_data AS(            
    SELECT 
    VALUE   
    FROM
        (
        SELECT
            info ->> ''key2'' AS key2,
            COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS 
        VALUE
            
        FROM
            mst_coop_ini AS ini
            CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: JSON ) info 
        WHERE
            facility_cd = @facilityCd
            AND is_del = ''0'' 
            -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start            
            AND COALESCE ( info ->> ''key0'', '''' ) = @key0 
            -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
        AND info ->> ''key1'' = ''DIALYSIS_ITEM_PROCEDURE_TAG'' 
        ) T 
    WHERE
        key2 = ( SELECT VALUE FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_PROCEDURE_CODE'' ) 
        LIMIT 1
) 
, data_middle_all AS (
SELECT
 all_cost.* 
FROM
 (SELECT
    --①ベッドＮＯ
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE(
    CASE
      WHEN (ord.ind_bed_cd IS NULL or ord.ind_bed_cd = 0)
        THEN ''V9999999''
      ELSE
        CASE
          WHEN COALESCE((SELECT value FROM fji_com_info WHERE key2 = ''BED_CODE_CONV''), '''') = ''1''
            THEN mbd.in_hospital_cd_1
          WHEN COALESCE((SELECT value FROM fji_com_info WHERE key2 = ''BED_CODE_CONV''), '''') = ''2''
            THEN mbd.in_hospital_cd_2
          ELSE ''V9999999''
        END
    END, '''') AS e01, 
    --項目属性
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_BED_NO_ATTR''), '''') AS e02, 
    --項目名称
    COALESCE(mbd.bed_name, ''ベッド未登録'') AS e03, 
    --数量
    ''0000000.000'' AS e04, 
    --選択単位フラグ
    ''0'' AS e05, 
    --単位コード
    '''' AS e06, 
    --単位名称
    '''' AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_BED_NO_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_BED_NO''), '''') AS e09 ,
        '''' as sorttag1,
        '''' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_bed mbd ON mbd.bed_cd = ord.ind_bed_cd
UNION
SELECT
    --②浄化方法
    ''予約詳細'' AS detail_id, 
    --項目コード
    CASE
    --患者の入外区分が外来の場合
     WHEN @inOut = ''0'' THEN COALESCE(mtt.in_hospital_cd_a1, '''')
    --患者の入外区分が入院の場合
    WHEN @inOut = ''1'' THEN COALESCE(NULLIF(mtt.in_hospital_cd_a2, ''''), mtt.in_hospital_cd_a1, '''')
    ELSE '''' END AS e01, 
    --項目属性
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_TREAT_ATTR''), '''') AS e02, 
    --項目名称
    COALESCE(mtt.treatment_name, '''') AS e03, 
    --数量
    ''0000000.000'' AS e04, 
    --選択単位フラグ
    ''0'' AS e05, 
    --単位コード
    '''' AS e06, 
    --単位名称
    '''' AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_TREAT_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_TREAT''), '''') AS e09,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_treatment mtt ON mtt.treatment_cd = ord.ind_treatment_cd
UNION
SELECT
    --③希望開始時刻
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_START_DATE_TIME_CODE''), '''') AS e01, 
    --項目属性
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_START_DATE_TIME_ATTR''), '''') AS e02, 
    --項目名称
    SUBSTRING((ord.ind_schedule_user_info->''ind_treat_start_time'')::text,2,2) || '':'' || SUBSTRING((ord.ind_schedule_user_info->''ind_treat_start_time'')::text,4,2) AS e03, 
    --数量
    ''0000000.000'' AS e04, 
    --選択単位フラグ
    ''0'' AS e05, 
    --単位コード
    '''' AS e06, 
    --単位名称
    '''' AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_START_DATE_TIME_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_START_DATE_TIME''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    ord_main ord
		WHERE ord.ord_no =  @ordNo
 AND ord.facility_cd = @facilityCd
UNION
SELECT
    --④希望終了時刻
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_END_DATE_TIME_CODE''), '''') AS e01, 
    --項目属性
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_END_DATE_TIME_ATTR''), '''') AS e02, 
    --項目名称
    TO_CHAR(TO_TIMESTAMP(ord.treat_date||'' ''||SUBSTRING((ord.ind_schedule_user_info->''ind_treat_start_time'')::text,2,2)||'':''||SUBSTRING((ord.ind_schedule_user_info->''ind_treat_start_time'')::text,4,2)||'':00'', ''YYYYMMDD HH24:MI:SS'') + (interval ''1minute'' * TO_NUMBER(ord.ind_cond_info->''1''->>''value'',''9999'')) ,''HH24:MI'') AS e03, 
    --数量
    ''0000000.000'' AS e04, 
    --選択単位フラグ
    ''0'' AS e05, 
    --単位コード
    '''' AS e06, 
    --単位名称
    '''' AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_END_DATE_TIME_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_END_DATE_TIME''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    ord_main ord
		WHERE ord.ord_no =  @ordNo
 AND ord.facility_cd = @facilityCd
 UNION
SELECT
    --③希望開始時刻
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_START_DATE_TIME_CODE''), '''') AS e01, 
    --項目属性
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_START_DATE_TIME_ATTR''), '''') AS e02, 
    --項目名称
    SUBSTRING(ord.ind_treat_start_time,1,2) || '':'' || SUBSTRING(ord.ind_treat_start_time,3,2) AS e03, 
    --数量
    ''0000000.000'' AS e04, 
    --選択単位フラグ
    ''0'' AS e05, 
    --単位コード
    '''' AS e06, 
    --単位名称
    '''' AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_START_DATE_TIME_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_START_DATE_TIME''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    ord_main_restore ord
		WHERE ord.ord_no =  @ordNo
 AND ord.facility_cd = @facilityCd
  AND (SELECT count(1) FROM ord_main as ord_i
WHERE ord_i.ord_no =  @ordNo)=''0''
UNION
SELECT
    --④希望終了時刻
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_END_DATE_TIME_CODE''), '''') AS e01, 
    --項目属性
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_END_DATE_TIME_ATTR''), '''') AS e02, 
    --項目名称
    TO_CHAR(TO_TIMESTAMP(ord.treat_date||'' ''||SUBSTRING(ord.ind_treat_start_time,1,2)||'':''||SUBSTRING(ord.ind_treat_start_time,3,2)||'':00'', ''YYYYMMDD HH24:MI:SS'') + (interval ''1minute'' * TO_NUMBER(ord.ind_cond_info->''1''->>''value'',''9999'')) ,''HH24:MI'') AS e03, 
    --数量
    ''0000000.000'' AS e04, 
    --選択単位フラグ
    ''0'' AS e05, 
    --単位コード
    '''' AS e06, 
    --単位名称
    '''' AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_END_DATE_TIME_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_END_DATE_TIME''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
 FROM
    ord_main_restore ord
		WHERE ord.ord_no =  @ordNo
 AND ord.facility_cd = @facilityCd
  AND (SELECT count(1) FROM ord_main as ord_i
WHERE ord_i.ord_no =  @ordNo)=''0''
UNION
SELECT 
    --⑤予定所要時間
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SCHE_TIME_CODE''), '''') AS e01, 
    --項目属性
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SCHE_TIME_ATTR''), '''') AS e02, 
    --項目名称
    RIGHT(''00''||TRUNC(TO_NUMBER(ord.ind_cond_info->''1''->>''value'',''9999'')/60,0),2)||'':''||RIGHT(''00''||MOD(TO_NUMBER(ord.ind_cond_info->''1''->>''value'',''9999''),60),2) AS e03, 
    --数量
    ''0000000.000'' AS e04, 
    --選択単位フラグ
    ''0'' AS e05, 
    --単位コード
    '''' AS e06, 
    --単位名称
    '''' AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SCHE_TIME_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_SCHE_TIME''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
UNION
SELECT
    --⑥目標体重
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_TARGET_WEIGHT_CODE''), '''') AS e01, 
    --項目属性
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_TARGET_WEIGHT_ATTR''), '''') AS e02, 
    --項目名称
    COALESCE(SUBSTRING(ord.treat_date, 1, 4) || ''/'' || SUBSTRING(ord.treat_date, 5, 2) || ''/'' || SUBSTRING(ord.treat_date, 7, 2), '''') AS e03, 
    --数量
    CASE
    --DWと同じの場合
    WHEN TO_NUMBER(COALESCE(ord.ind_cond_info ->''3''->>''value'', ''0''),''9999999.999'') = -1
      THEN TO_CHAR(TO_NUMBER(COALESCE(ord.ind_cond_info ->''3''->>''value_dw'', ''0''),''9999999.999'') ,''FM0999999.990'')
    ELSE TO_CHAR(TO_NUMBER(COALESCE(ord.ind_cond_info ->''3''->>''value'', ''0''),''9999999.999'') ,''FM0999999.990'') END AS e04, 
    --選択単位フラグ
    ''1'' AS e05, 
    --単位コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_TARGET_WEIGHT_UNIT''), '''') AS e06, 
    --単位名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_TARGET_WEIGHT_UNIT''), '''') AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_TARGET_WEIGHT_TAG''), '''') as e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_TARGET_WEIGHT''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
UNION
SELECT
    --⑦ドライウェイト
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_DRY_WEIGHT_CODE''), '''') AS e01, 
    --項目属性
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_DRY_WEIGHT_ATTR''), '''') AS e02, 
    --項目名称
    COALESCE(SUBSTRING(ord.treat_date, 1, 4) || ''/'' || SUBSTRING(ord.treat_date, 5, 2) || ''/'' || SUBSTRING(ord.treat_date, 7, 2), '''') AS e03, 
    --数量
    TO_CHAR(TO_NUMBER(COALESCE(ord.ind_cond_info->''3''->>''value_dw'', ''0''),''9999999.999'') ,''FM0999999.990'') AS e04, 
    --選択単位フラグ
    ''1'' AS e05, 
    --単位コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_DRY_WEIGHT_UNIT''), '''') AS e06, 
    --単位名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_DRY_WEIGHT_UNIT''), '''') AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_DRY_WEIGHT_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_DRY_WEIGHT''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
UNION
SELECT
    --⑧ＶＡ
    ''予約詳細'' AS detail_id, 
    --項目コード 
    COALESCE(mva.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(mva.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SHUNT_PART_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE(mva.va_name, '''') AS e03, 
    --数量
    ''0000000.000'' AS e04, 
    --選択単位フラグ
    ''0'' AS e05, 
    --単位コード
    '''' AS e06, 
    --単位名称
    '''' AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SHUNT_PART_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_SHUNT_PART''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_va mva ON mva.va_cd = TO_NUMBER(ord.ind_cond_info->''2''->>''value'',''999999999999'')
UNION
SELECT
    --⑨透析器
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE(mdz.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(mdz.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_DIAL_INST_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE(mdz.model_number, '''') AS e03, 
    --数量
    ''0000001.000'' AS e04, 
    --選択単位フラグ
    ''1'' AS e05, 
    --単位コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_DIAL_INST_UNIT''), '''') AS e06, 
    --単位名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_DIAL_INST_UNIT''), '''') AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_DIAL_INST_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_DIAL_INST''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_dialyzer mdz ON mdz.dialyzer_cd = TO_NUMBER(ord.ind_cond_info->''5''->>''value'',''999999999999'')
UNION
SELECT
    --⑩吸着器
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_ADSORPTION_INST_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE(meq.equipment_name, '''') AS e03, 
    --数量
    ''0000001.000'' AS e04, 
    --選択単位フラグ
    CASE WHEN meq.unit IS NULL OR meq.unit = ''''
    THEN ''0'' ELSE ''1'' END AS e05, 
    --単位コード
    COALESCE(meq.unit, '''') AS e06,
    --単位名称
    COALESCE(meq.unit, '''') AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_ADSORPTION_INST_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_FILM''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_equipment meq ON meq.equipment_cd = TO_NUMBER(ord.ind_cond_info->''6''->>''value'',''999999999999'')
UNION
SELECT
    --⑪1次膜(吸着器or血漿分離器)
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_FIRST_FILM_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE(meq.equipment_name, '''') AS e03, 
    --数量
    ''0000001.000'' AS e04, 
    --選択単位フラグ
    CASE WHEN meq.unit IS NULL OR meq.unit = ''''
    THEN ''0'' ELSE ''1'' END AS e05, 
    --単位コード
    COALESCE(meq.unit, '''') AS e06, 
    --単位名称
    COALESCE(meq.unit, '''') AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_FIRST_FILM_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_FIRST_FILM''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_equipment meq ON meq.equipment_cd = TO_NUMBER(ord.ind_cond_info->''7''->>''value'',''999999999999'')
UNION
SELECT
    --⑫2次膜(吸着器or血漿分離器)
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SECOND_FILM_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE(meq.equipment_name, '''') AS e03, 
    --数量
    ''0000001.000'' AS e04, 
    --選択単位フラグ
    CASE WHEN meq.unit IS NULL OR meq.unit = ''''
    THEN ''0'' ELSE ''1'' END AS e05, 
    --単位コード
    COALESCE(meq.unit, '''') AS e06, 
    --単位名称
    COALESCE(meq.unit, '''') AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SECOND_FILM_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_SECOND_FILM''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_equipment meq ON meq.equipment_cd = TO_NUMBER(ord.ind_cond_info->''8''->>''value'',''999999999999'')
UNION
--⑬医療材料（回路・針など）
SELECT
    --A針情報
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_EQUIP_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE(meq.equipment_name, '''') AS e03, 
    --数量
    ''0000001.000'' AS e04, 
    --選択単位フラグ
    CASE WHEN meq.unit IS NULL OR meq.unit = ''''
    THEN ''0'' ELSE ''1'' END AS e05, 
    --単位コード
    COALESCE(meq.unit, '''') AS e06, 
    --単位名称
    COALESCE(meq.unit, '''') AS e07, 
    --タグ名称
    COALESCE(meqc.class_name, '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_EQUIP''), '''') AS e09 ,
    ''1'' as sorttag1,
    ''18'' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_equipment as meq ON meq.equipment_cd = TO_NUMBER(ord.ind_cond_info->''9''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_equipment_class meqc ON meq.class_cd = meqc.class_cd
WHERE
    ord.ind_cond_info->''9''->>''value'' IS NOT NULL
UNION
SELECT
    --V針情報
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_EQUIP_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE(meq.equipment_name, '''') AS e03, 
    --数量
    ''0000001.000'' AS e04, 
    --選択単位フラグ
    CASE WHEN meq.unit IS NULL OR meq.unit = ''''
    THEN ''0'' ELSE ''1'' END AS e05, 
    --単位コード
    COALESCE(meq.unit, '''') AS e06, 
    --単位名称
    COALESCE(meq.unit, '''') AS e07, 
    --タグ名称
    COALESCE(meqc.class_name, '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_EQUIP''), '''') AS e09 ,
    ''2'' as sorttag1,
    ''18'' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_equipment as meq ON meq.equipment_cd = TO_NUMBER(ord.ind_cond_info->''10''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_equipment_class meqc ON meq.class_cd = meqc.class_cd
WHERE
    ord.ind_cond_info->''10''->>''value'' IS NOT NULL
UNION
SELECT
    --SN針情報
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_EQUIP_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE(meq.equipment_name, '''') AS e03, 
    --数量
    ''0000001.000'' AS e04, 
    --選択単位フラグ
    CASE WHEN meq.unit IS NULL OR meq.unit = ''''
    THEN ''0'' ELSE ''1'' END AS e05, 
    --単位コード
    COALESCE(meq.unit, '''') AS e06, 
    --単位名称
    COALESCE(meq.unit, '''') AS e07, 
    --タグ名称
    COALESCE(meqc.class_name, '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_EQUIP''), '''') AS e09 ,
    ''3'' as sorttag1,
    ''18'' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_equipment as meq ON meq.equipment_cd = TO_NUMBER(ord.ind_cond_info->''11''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_equipment_class meqc ON meq.class_cd = meqc.class_cd
WHERE
    ord.ind_cond_info->''11''->>''value'' IS NOT NULL
UNION
SELECT
    --血液回路情報
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_EQUIP_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE(meq.equipment_name, '''') AS e03, 
    --数量
    ''0000001.000'' AS e04, 
    --選択単位フラグ
    CASE WHEN meq.unit IS NULL OR meq.unit = ''''
    THEN ''0'' ELSE ''1'' END AS e05, 
    --単位コード
    COALESCE(meq.unit, '''') AS e06, 
    --単位名称
    COALESCE(meq.unit, '''') AS e07, 
    --タグ名称
    COALESCE(meqc.class_name, '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_EQUIP''), '''') AS e09 ,
    ''4'' as sorttag1,
    ''18'' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_equipment meq ON meq.equipment_cd = TO_NUMBER(ord.ind_cond_info->''13''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_equipment_class meqc ON meq.class_cd = meqc.class_cd
WHERE
    ord.ind_cond_info->''13''->>''value'' IS NOT NULL
UNION
SELECT 
    --⑭透析液
    ''予約詳細'' AS detail_id, 
    --項目コード
    --CASE WHEN LENGTH(TRIM(mmd.in_hospital_cd_1)) > 8 THEN RIGHT(TRIM(mmd.in_hospital_cd_1), 8) ELSE RPAD(TRIM(mmd.in_hospital_cd_1), 8, '' '') END AS e01,
        COALESCE(mmd.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(mmd.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SOLUTION_ATTR''), '''')) AS e02,
    --項目名称
    COALESCE(mmd.medicine_name, '''') AS e03,
    --数量
    CASE
      WHEN ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''0'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''0'') OR
           ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''0'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''2'') OR
           ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''0'') OR
           ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''2'') OR
                     ((SELECT device_mode FROM device) NOT IN (7, 8, 10))
        THEN
          TO_CHAR(TO_NUMBER(COALESCE(ord.ind_cond_info->''17''->>''value'',''0''), ''9999999.999''), ''FM0999999.990'')
      WHEN ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''0'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''1'') OR
           ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''1'') AND
                     ((SELECT device_mode FROM device) IN (7, 8, 10))
        THEN
          TO_CHAR(TO_NUMBER(COALESCE(ord.ind_cond_info->''17''->>''value'',''0''), ''9999999.999'') + TO_NUMBER(COALESCE(ord.ind_cond_info->''22''->>''value'',''0''), ''9999999.999''), ''FM0999999.990'')
      ELSE ''0000000.000''
    END AS e04,
    --選択単位フラグ
    ''1'' AS e05, 
    --単位コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SOLUTION_UNIT''), '''') AS e06, 
    --単位名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SOLUTION_UNIT''), '''') AS e07,
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SOLUTION_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_SOLUTION''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_medicine mmd ON mmd.medicine_cd = TO_NUMBER(ord.ind_cond_info->''15''->>''value'',''999999999999'')
--WHERE
--     AND (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''SOLUTION_RESOLVE_MODE'') = ''0''
UNION
SELECT 
    --⑮置換液（補液）
    ''予約詳細'' AS detail_id, 
    --項目コード
    --CASE WHEN LENGTH(TRIM(mmd.in_hospital_cd_1)) > 8 THEN RIGHT(TRIM(mmd.in_hospital_cd_1), 8) ELSE COALESCE(TRIM(mmd.in_hospital_cd_1), '''') END AS e01,
        COALESCE(mmd.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(mmd.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_REPLACE_ATTR''), '''')) AS e02,
    --項目名称
    COALESCE(mmd.medicine_name, '''') AS e03,
    --数量
    TO_CHAR(TO_NUMBER(COALESCE(ord.ind_cond_info->''22''->>''value'',''0''), ''9999999.999''), ''FM0999999.990'') AS e04,
    --選択単位フラグ
    ''1'' AS e05, 
    --単位コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_REPLACE_UNIT''), '''') AS e06, 
    --単位名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_REPLACE_UNIT''), '''') AS e07,
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_REPLACE_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_REPLACE''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_medicine mmd ON mmd.medicine_cd = TO_NUMBER(ord.ind_cond_info->''19''->>''value'',''999999999999'')
WHERE
--     AND (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''REPLACE_RESOLVE_MODE'') = ''0''
    ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''0'' 
    OR ((SELECT device_mode FROM device) NOT IN (7, 8, 10)))
UNION
SELECT
    --⑯抗凝固剤・初回
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE  mmd.in_hospital_cd_1 END), '''') AS e01, 
    --項目属性
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END), COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_KOU_COAG_ONESHOT_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE mmd.medicine_name END), '''') AS e03, 
    --数量
    TO_CHAR(TO_NUMBER(COALESCE(ord.ind_cond_info->''26''->>''value'', ''0''), ''9999999.999''), ''FM0999999.990'') AS e04, 
    --選択単位フラグ
    CASE 
      WHEN (CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) IS NULL OR 
           (CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) = ''''
        THEN ''0''
      ELSE
        CASE
          WHEN (SELECT value FROM item_set_info WHERE key2 = ''ITEM_KOU_COAG_ONESHOT_UNIT_SEL'') = ''2''
            THEN ''2''
          ELSE ''1''
        END
    END AS e05, 
    --単位コード
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e06, 
    --単位名称
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' then mmx.unit ELSE mmd.unit END), '''') AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_KOU_COAG_ONESHOT_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_KOU_COAG_ONESHOT''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_medicine mmd ON mmd.medicine_cd = TO_NUMBER(ord.ind_cond_info->''25''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_medicine_mix mmx ON mmx.medicine_mix_cd = TO_NUMBER(ord.ind_cond_info->''25''->>''value'',''999999999999'')
WHERE
    CASE WHEN (ord.ind_cond_info->''25''->>''medicine_type'' = ''2'') THEN ((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''0'' or
    (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'')
        ELSE ((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''0'' or
    (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'' or
    (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''2'') END
UNION
SELECT
    --⑰抗凝固剤・持続
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE  
        (CASE WHEN LENGTH(TRIM(mmd.in_hospital_cd_1)) > 8 THEN RIGHT(TRIM(mmd.in_hospital_cd_1), 8) ELSE RPAD(TRIM(mmd.in_hospital_cd_1), 8, '' '') END) END), '''') AS e01, 
    --項目属性
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END), COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_KOU_COAG_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE  mmd.medicine_name END), '''') AS e03, 
    --数量
    TO_CHAR(TO_NUMBER(COALESCE(ord.ind_cond_info->''27''->>''value'', ''0''), ''9999999.999''), ''FM0999999.990'') AS e04, 
    --選択単位フラグ
    CASE 
      WHEN (CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) IS NULL OR 
           (CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) = ''''
        THEN ''0''
      ELSE
        CASE
          WHEN (SELECT value FROM item_set_info WHERE key2 = ''ITEM_KOU_COAG_UNIT_SEL'') = ''2''
            THEN ''2''
          ELSE ''1''
        END
    END AS e05, 
    --単位コード
    CASE
      WHEN (SELECT value FROM item_set_info WHERE key2 = ''ADD_UNIT_FLG'') = ''1''
        THEN
          CASE 
            WHEN ord.ind_cond_info->''25''->>''medicine_type'' = ''2''
              THEN 
                CASE
                  WHEN mmx.unit IS NULL OR mmx.unit = ''''
                    THEN ''''
                  ELSE mmx.unit || ''/h'' 
                END
            ELSE
              CASE
                WHEN mmd.unit IS NULL OR mmd.unit = ''''
                  THEN ''''
                ELSE mmd.unit || ''/h'' 
              END
          END
      ELSE 
        CASE 
          WHEN ord.ind_cond_info->''25''->>''medicine_type'' = ''2'' 
            THEN
              COALESCE(mmx.unit, '''')
          ELSE
            COALESCE(mmd.unit, '''')
        END
    END AS e06, 
    --単位名称
    CASE
      WHEN (SELECT value FROM item_set_info WHERE key2 = ''ADD_UNIT_FLG'') = ''1''
        THEN
          CASE 
            WHEN ord.ind_cond_info->''25''->>''medicine_type'' = ''2''
              THEN 
                CASE
                  WHEN mmx.unit IS NULL OR mmx.unit = ''''
                    THEN ''''
                  ELSE mmx.unit || ''/h'' 
                END
            ELSE
              CASE
                WHEN mmd.unit IS NULL OR mmd.unit = ''''
                  THEN ''''
                ELSE mmd.unit || ''/h'' 
              END
          END
      ELSE 
        CASE 
          WHEN ord.ind_cond_info->''25''->>''medicine_type'' = ''2'' 
            THEN
              COALESCE(mmx.unit, '''')
          ELSE
            COALESCE(mmd.unit, '''')
        END
    END AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_KOU_COAG_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_KOU_COAG''), '''') AS e09 ,
        '''' as sorttag1,
        '''' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_medicine mmd ON mmd.medicine_cd = TO_NUMBER(ord.ind_cond_info->''25''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_medicine_mix mmx ON mmx.medicine_mix_cd = TO_NUMBER(ord.ind_cond_info->''25''->>''value'',''999999999999'')
WHERE
    CASE WHEN (ord.ind_cond_info->''25''->>''medicine_type'' = ''2'') THEN ((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''0'' or
    (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'')
        ELSE ((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''0'' or
    (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'' or
    (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''2'') END
UNION
SELECT 
    --⑱抗凝固剤・ＴＯＴＡＬ
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE  
        (CASE WHEN LENGTH(TRIM(mmd.in_hospital_cd_1)) > 8 THEN RIGHT(TRIM(mmd.in_hospital_cd_1), 8) ELSE RPAD(TRIM(mmd.in_hospital_cd_1), 8, '' '') END) END), '''') AS e01,
    --項目属性
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END), COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_KOU_COAG_TOTAL_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE  mmd.medicine_name END), '''') AS e03, 
    --数量
    TO_CHAR(TO_NUMBER(COALESCE(ord.ind_cond_info->''26''->>''value'', ''0''), ''9999999.999'') + TO_NUMBER(COALESCE(ord.ind_cond_info->''28''->>''value'',''0''), ''9999999.999''), ''FM0999999.990'') AS e04, 
    --選択単位フラグ
    CASE 
      WHEN (CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) IS NULL OR 
           (CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) = ''''
        THEN ''0''
      ELSE
        CASE
          WHEN (SELECT value FROM item_set_info WHERE key2 = ''ITEM_KOU_COAG_TOTAL_UNIT_SEL'') = ''2''
            THEN ''2''
          ELSE ''1''
        END
    END AS e05, 
    --単位コード
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e06, 
    --単位名称
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' then mmx.unit ELSE mmd.unit END), '''') AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_KOU_COAG_TOTAL_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_KOU_COAG_TOTAL''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_medicine mmd ON mmd.medicine_cd = TO_NUMBER(ord.ind_cond_info->''25''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_medicine_mix as mmx ON mmx.medicine_mix_cd = TO_NUMBER(ord.ind_cond_info->''25''->>''value'',''999999999999'')
WHERE
    CASE WHEN (ord.ind_cond_info->''25''->>''medicine_type'' = ''2'') THEN ((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''0'' or
    (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'')
        ELSE ((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''0'' or
    (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'' or
    (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''2'') END
UNION
SELECT
    --⑲血液流量
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_BLOOD_AMT_CODE''), '''') AS e01, 
    --項目属性
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_BLOOD_AMT_ATTR''), '''') AS e02, 
    --項目名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_BLOOD_AMT_NAME''), '''') AS e03,
    --数量
    TO_CHAR(TO_NUMBER(ord.ind_cond_info->''14''->>''value'', ''9999999.999''), ''FM0999999.990'') AS e04, 
    --選択単位フラグ
    ''1'' AS e05, 
    --単位コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_BLOOD_AMT_UNIT''), '''') AS e06, 
    --単位名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_BLOOD_AMT_UNIT''), '''') AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_BLOOD_AMT_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_BLOOD_AMT''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
WHERE
    TO_NUMBER(ord.ind_cond_info->''14''->>''value'',''999999999999'') > 1
UNION
SELECT
    --⑳透析液流量
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SOLUTION_AMT_CODE''), '''') AS e01, 
    --項目属性
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SOLUTION_AMT_ATTR''), '''') AS e02, 
    --項目名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SOLUTION_AMT_NAME''), '''') AS e03, 
    --数量
    TO_CHAR(TO_NUMBER(ord.ind_cond_info->''16''->>''value'', ''9999999.999''), ''FM0999999.990'') AS e04, 
    --選択単位フラグ
    ''1'' AS e05, 
    --単位コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SOLUTION_AMT_UNIT''), '''') AS e06, 
    --単位名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SOLUTION_AMT_UNIT''), '''') AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SOLUTION_AMT_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_SOLUTION_AMT''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
WHERE
    (SELECT cnt FROM solution_cnt) > 0 
    AND TO_NUMBER(ord.ind_cond_info->''16''->>''value'',''999999999999'') > 1
UNION
SELECT
    --21補液量
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_UP_LIQUID_CODE''), '''') AS e01, 
    --項目属性
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_UP_LIQUID_ATTR''), '''') AS e02, 
    --項目名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_UP_LIQUID_NAME''), '''') AS e03, 
    --数量
    TO_CHAR(TO_NUMBER(ord.ind_cond_info->''20''->>''value'', ''9999999.999''), ''FM0999999.990'') AS e04, 
    --選択単位フラグ
    ''1'' AS e05, 
    --単位コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_UP_LIQUID_UNIT''), '''') AS e06, 
    --単位名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_UP_LIQUID_UNIT''), '''') AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_UP_LIQUID_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_UP_LIQUID''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
WHERE
    TO_NUMBER(ord.ind_cond_info->''20''->>''value'',''999999999999'') > 1
--  AND (SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1''
    AND ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1'' OR ((SELECT device_mode FROM device) NOT IN (7, 8, 10)))
UNION
SELECT
    --24指示受け確認者1
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE(@dispUser1Id :: TEXT, '''') AS e01, 
    --項目属性
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_CHECK_STAFF_ATTR''), '''') AS e02, 
    --項目名称
    COALESCE(@checkUser1Name :: TEXT, '''') AS e03, 
    --数量
    ''0000000.000'' AS e04, 
    --選択単位フラグ
    ''0'' AS e05, 
    --単位コード
    '''' AS e06, 
    --単位名称
    '''' AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_CHECK_STAFF_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_CHECK_STAFF'')|| ''-1'', '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    pat_ind_approve pia
WHERE
    pia.ord_no = @ordNo
    AND (SELECT value FROM fji_com_info WHERE key2 = ''CHECK_STAFF_SEND_FLAG'') = ''1''
UNION
SELECT
    --24指示受け確認者2
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE(@dispUser2Id :: TEXT, '''') AS e01, 
    --項目属性
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_CHECK_STAFF_ATTR''), '''') AS e02, 
    --項目名称
    COALESCE(@checkUser2Name :: TEXT, '''') AS e03, 
    --数量
    ''0000000.000'' AS e04, 
    --選択単位フラグ
    ''0'' AS e05, 
    --単位コード
    '''' AS e06, 
    --単位名称
    '''' AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_CHECK_STAFF_TAG''), '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_CHECK_STAFF'') || ''-2'', '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    pat_ind_approve pia
WHERE
    pia.ord_no = @ordNo
    AND (SELECT value FROM fji_com_info WHERE key2 = ''CHECK_STAFF_SEND_FLAG'') = ''1''
 ) all_cost 
WHERE
     all_cost.e09 IS NOT NULL AND all_cost.e09 <> ''''
 AND all_cost.e01 != '''' AND all_cost.e01 IS NOT NULL
)
,data_middle AS (
SELECT  --抗凝固剤    
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE  
    (CASE WHEN LENGTH(TRIM(mmd.in_hospital_cd_1)) > 8 THEN RIGHT(TRIM(mmd.in_hospital_cd_1), 8) ELSE        RPAD(TRIM(mmd.in_hospital_cd_1), 8, '' '') END) END), '''') AS yakuzai,
        ord.ind_cond_info->''25''->>''medicine_type'' AS medicine_type_yakuzai
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_medicine mmd ON mmd.medicine_cd = TO_NUMBER(ord.ind_cond_info->''25''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_medicine_mix as mmx ON mmx.medicine_mix_cd = TO_NUMBER(ord.ind_cond_info->''25''->>''value'',''999999999999'')
WHERE
    CASE WHEN (ord.ind_cond_info->''25''->>''medicine_type'' = ''2'') THEN ((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''0'' or
    (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'')
        ELSE ((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''0'' or
    (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'' or
    (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''2'') END
)
, equip_data as (--医療材料の選択
  select 
    (SELECT in_hospital_cd_1 FROM mst_equipment WHERE equipment_cd = TO_NUMBER( eqp ->> ''cd'' :: text, ''999999999999'')) AS item_cd_s,
    COALESCE( TO_CHAR(TO_NUMBER(eqp ->> ''amount'',''9999999999.999''),''FM0999999.990'') ) AS e04
  FROM
    do_ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_equip_info :: json) with ordinality as tmp(eqp, json_idx)
)
, medi_data as(--薬剤の選択
select 
     (SELECT in_hospital_cd_1 FROM mst_medicine WHERE medicine_cd = TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'')) AS item_cd_s,
    COALESCE( TO_CHAR(TO_NUMBER(medi ->> ''amount'',''9999999999''),''FM0999999.990'') )  AS e04
  FROM
    do_ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)

)
, do_medicine_mix_in_orders AS ( --調製薬剤内のソート順
SELECT medicine_mix_cd, in_idx AS login_ord_in_mm, TRIM(mmd.in_hospital_cd_1) AS item_cd_mm
FROM mst_medicine_mix AS mmx
        CROSS JOIN LATERAL json_array_elements(mmx.mix_info :: json) with ordinality as tmp(mmxd, in_idx)
        LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'')
WHERE mmx.facility_cd = @facilityCd
AND medicine_mix_cd IN (
        SELECT mix_M_cd
        FROM (SELECT TRIM(mmd.in_hospital_cd_1) AS item_cd,
             json_idx AS login_ord,
             TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'') AS mix_M_cd
FROM do_ord_main AS ord
         CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)
         LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''999999999999'')
         CROSS JOIN LATERAL json_array_elements(mmx.mix_info :: json ) mmxd
         LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'')
WHERE medi ->> ''medicine_type'' = ''2'') AS middl
        GROUP BY mix_M_cd)
)
, equip_all_data AS (
SELECT
    --22薬品手技(手技あり薬剤),単体薬剤
    TRIM(mmd.in_hospital_cd_1) AS e01, 
    medi ->> ''no'' as sorttag1,
        medi ->> ''procedure_cd'' :: text AS procedure_cd_no,
        medi ->> ''cd'' :: text AS medi_cd_no,
    json_idx AS login_ord,
        0 AS ord_medicine_mix,
        TO_NUMBER( medi_class_code_order :: text, ''999999999999'' ) AS medi_class_M_cd,
        TO_NUMBER( medi ->> ''medicine_type'' :: text, ''999999999999'' ) AS medicine_type,
        TO_NUMBER( medi_code_order :: text, ''999999999999'' ) AS mix_M_cd,
        TO_NUMBER( timing_code_order :: text, ''999999999999'' ) AS timing_cd,
        TO_NUMBER( procedure_code_order :: text, ''999999999999'' ) AS procedure_cd,
        TO_NUMBER( medi ->> ''date_interval'' :: text, ''999999999999'' ) AS date_interval
FROM
    do_ord_main ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)
LEFT OUTER JOIN
    mst_medicine_mix mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_medicine mmd ON mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_procedure mp ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'',''999999999999'')
LEFT OUTER JOIN do_mstmedi_cd ON medi_code = TO_NUMBER(medi ->> ''cd'' :: text, ''999999999999'' )
LEFT OUTER JOIN do_mstmedi_class_cd ON medi_class_code = TO_NUMBER(mmd.class_cd :: text, ''999999999999'' )
LEFT OUTER JOIN do_mst_timing ON timing_code = TO_NUMBER(medi ->> ''timing_cd'' :: text, ''999999999999'' )
LEFT OUTER JOIN do_mst_procedure ON procedure_code = TO_NUMBER(medi ->> ''procedure_cd'' :: text, ''999999999999'' )
WHERE
    --患者経過総合ビューアの投与薬剤に手技が設定されている場合
    medi ->> ''procedure_cd'' IS NOT NULL
    AND medi->>''medicine_type'' = ''1''
    --連携設定 DIALYSIS_ITEM_PROCEDURE_TAGのkey2＝患者経過総合ビューアの投与薬剤に設定した手技の連携コード1がある場合
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) IS NOT NULL 
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) <> ''''
UNION
SELECT
    --23処置薬品名(手技なし薬剤),単体薬剤
    TRIM(mmd.in_hospital_cd_1) AS e01, 
    medi ->> ''no'' as sorttag1,
        medi ->> ''procedure_cd'' :: text AS procedure_cd_no,
        medi ->> ''cd'' :: text AS medi_cd_no,
    json_idx AS login_ord,
        0 AS ord_medicine_mix,
        TO_NUMBER( medi_class_code_order :: text, ''999999999999'' ) AS medi_class_M_cd,
        TO_NUMBER( medi ->> ''medicine_type'' :: text, ''999999999999'' ) AS medicine_type,
        TO_NUMBER( medi_code_order :: text, ''999999999999'' ) AS mix_M_cd,
        TO_NUMBER( timing_code_order :: text, ''999999999999'' ) AS timing_cd,
        TO_NUMBER( procedure_code_order :: text, ''999999999999'' ) AS procedure_cd,
        TO_NUMBER( medi ->> ''date_interval'' :: text, ''999999999999'' ) AS date_interval
FROM
    do_ord_main ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)
LEFT OUTER JOIN
    mst_medicine_mix mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_medicine mmd ON mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_procedure mp ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'',''999999999999'')
LEFT OUTER JOIN do_mstmedi_cd ON medi_code = TO_NUMBER(medi ->> ''cd'' :: text, ''999999999999'' )
LEFT OUTER JOIN do_mstmedi_class_cd ON medi_class_code = TO_NUMBER(mmd.class_cd :: text, ''999999999999'' )
LEFT OUTER JOIN do_mst_timing ON timing_code = TO_NUMBER(medi ->> ''timing_cd'' :: text, ''999999999999'' )
LEFT OUTER JOIN do_mst_procedure ON procedure_code = TO_NUMBER(medi ->> ''procedure_cd'' :: text, ''999999999999'' )
WHERE
    medi->>''medicine_type'' = ''1'' 
    AND (
      --患者経過総合ビューアの投与薬剤に手技が設定されていない場合
      medi ->> ''procedure_cd'' IS NULL
      OR(
        --患者経過総合ビューアの投与薬剤に手技が設定されている場合
        medi ->> ''procedure_cd'' IS NOT NULL
        --連携設定 DIALYSIS_ITEM_PROCEDURE_TAGのkey2＝患者経過総合ビューアの投与薬剤に設定した手技の連携コード1がない場合
        AND ((SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) IS  NULL 
        OR (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) = '''')
      )
    )
UNION
SELECT
    --22薬品手技(手技あり薬剤),調製薬剤
        TRIM(mmd.in_hospital_cd_1) AS e01,
    (medi->>''no'') as sorttag1,
        medi ->> ''procedure_cd'' :: text AS procedure_cd_no,
        medi ->> ''cd'' :: text AS medi_cd_no,
        json_idx AS login_ord,
        (SELECT login_ord_in_mm FROM do_medicine_mix_in_orders 
                            WHERE TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'') = medicine_mix_cd 
                            AND TRIM(mmd.in_hospital_cd_1) = item_cd_mm) AS ord_medicine_mix,
        TO_NUMBER( medi_class_code_order :: text, ''999999999999'' ) AS medi_class_M_cd,
        TO_NUMBER( medi ->> ''medicine_type'' :: text, ''999999999999'' ) AS medicine_type,
        TO_NUMBER( medi_mix_code_order :: text, ''999999999999'' ) AS mix_M_cd,
        TO_NUMBER( timing_code_order :: text, ''999999999999'' ) AS timing_cd,
        TO_NUMBER( procedure_code_order :: text, ''999999999999'' ) AS procedure_cd,
        TO_NUMBER( medi ->> ''date_interval'' :: text, ''999999999999'' ) AS date_interval
FROM
        do_ord_main AS ord
        CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)
        LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''999999999999'' )
        LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''999999999999'' )
                    LEFT OUTER JOIN do_medicine_mix_cd ON medi_mix_code = mmx.medicine_mix_cd
                    LEFT OUTER JOIN do_mstmedi_class_cd ON medi_class_code = TO_NUMBER(mmx.class_cd :: text, ''999999999999'' )
                    LEFT OUTER JOIN do_mst_timing ON timing_code = TO_NUMBER(medi ->> ''timing_cd'' :: text, ''999999999999'' )
                    LEFT OUTER JOIN do_mst_procedure ON procedure_code = TO_NUMBER(medi ->> ''procedure_cd'' :: text, ''999999999999'' )
        CROSS JOIN LATERAL json_array_elements(mmx.mix_info :: json ) mmxd
        LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'' )
        LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd
WHERE
    --患者経過総合ビューアの投与薬剤に手技が設定されている場合
    medi ->> ''procedure_cd'' IS NOT NULL
    AND medi ->> ''medicine_type'' = ''2''
    --連携設定 DIALYSIS_ITEM_PROCEDURE_TAGのkey2＝患者経過総合ビューアの投与薬剤に設定した手技の連携コード1がある場合
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) IS NOT NULL 
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) <> ''''
UNION
SELECT
    --23処置薬品名(手技なし薬剤),調製薬剤
    TRIM(mmd.in_hospital_cd_1) AS e01,
    (medi->>''no'') as sorttag1,
        medi ->> ''procedure_cd'' :: text AS procedure_cd_no,
        medi ->> ''cd'' :: text AS medi_cd_no,
        json_idx AS login_ord,
        (SELECT login_ord_in_mm FROM do_medicine_mix_in_orders 
                            WHERE TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'') = medicine_mix_cd 
                            AND TRIM(mmd.in_hospital_cd_1) = item_cd_mm) AS ord_medicine_mix,
        TO_NUMBER( medi_class_code_order :: text, ''999999999999'' ) AS medi_class_M_cd,
        TO_NUMBER( medi ->> ''medicine_type'' :: text, ''999999999999'' ) AS medicine_type,
        TO_NUMBER( medi_mix_code_order :: text, ''999999999999'' ) AS mix_M_cd,
        TO_NUMBER( timing_code_order :: text, ''999999999999'' ) AS timing_cd,
        TO_NUMBER( procedure_code_order :: text, ''999999999999'' ) AS procedure_cd,
        TO_NUMBER( medi ->> ''date_interval'' :: text, ''999999999999'' ) AS date_interval
FROM
        do_ord_main AS ord
        CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)
        LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''999999999999'' )
        LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''999999999999'' )
        LEFT OUTER JOIN do_medicine_mix_cd ON medi_mix_code = mmx.medicine_mix_cd
        LEFT OUTER JOIN do_mstmedi_class_cd ON medi_class_code = TO_NUMBER(mmx.class_cd :: text, ''999999999999'' )
        LEFT OUTER JOIN do_mst_timing ON timing_code = TO_NUMBER(medi ->> ''timing_cd'' :: text, ''999999999999'' )
        LEFT OUTER JOIN do_mst_procedure ON procedure_code = TO_NUMBER(medi ->> ''procedure_cd'' :: text, ''999999999999'' )
        CROSS JOIN LATERAL json_array_elements(mmx.mix_info :: json ) mmxd
        LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'' )
        LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd
WHERE
    medi->>''medicine_type'' = ''2'' 
    AND (
      --患者経過総合ビューアの投与薬剤に手技が設定されていない場合
      medi ->> ''procedure_cd'' IS NULL
      OR(
        --患者経過総合ビューアの投与薬剤に手技が設定されている場合
        medi ->> ''procedure_cd'' IS NOT NULL
        --連携設定 DIALYSIS_ITEM_PROCEDURE_TAGのkey2＝患者経過総合ビューアの投与薬剤に設定した手技の連携コード1がない場合
        AND ((SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) IS  NULL 
        OR (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) = '''')
      )
    )
)
, equip_all_over_order AS (
SELECT ROW_NUMBER () OVER () AS no2, *
FROM (SELECT *
    FROM equip_all_data
    ORDER BY 
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''3'' THEN mix_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''6'' THEN date_interval END,
      CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''3'' THEN login_ord ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''3'' THEN ord_medicine_mix ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''3'' THEN mix_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''6'' THEN date_interval END,
      CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''3'' THEN login_ord ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''3'' THEN ord_medicine_mix ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''3'' THEN mix_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''6'' THEN date_interval END,
      CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''3'' THEN login_ord ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''3'' THEN ord_medicine_mix ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''3'' THEN mix_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''6'' THEN date_interval END,
      CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''3'' THEN login_ord ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''3'' THEN ord_medicine_mix ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''3'' THEN mix_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''6'' THEN date_interval END,
      CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''3'' THEN login_ord ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''3'' THEN ord_medicine_mix ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''3'' THEN mix_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''6'' THEN date_interval END,
      CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''3'' THEN login_ord ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''3'' THEN ord_medicine_mix ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''3'' THEN mix_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''6'' THEN date_interval END,
      CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''3'' THEN login_ord ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''3'' THEN ord_medicine_mix ELSE 0 END,
        ord_medicine_mix ) AS mid_data
)
, equip_all_copy AS (
SELECT
    --22薬品手技(手技),単体薬剤
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE(mp.in_hospital_cd_a1, '''') AS e01, 
    --項目属性
    COALESCE(mp.in_hospital_cd_a2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_PROCEDURE_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE(mp.pricedure_name, '''') AS e03, 
    --数量
    ''0000000.000'' AS e04, 
    --選択単位フラグ
    ''0'' AS e05, 
    --単位コード
    '''' AS e06, 
    --単位名称
    '''' AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1), '''') AS e08, 
    --出力順
    CASE length((SELECT no2 FROM equip_all_over_order 
        WHERE medi ->> ''procedure_cd'' :: TEXT = procedure_cd_no
        AND mmd.in_hospital_cd_1 = e01 AND medi ->> ''no'' = sorttag1) :: TEXT) WHEN 1 THEN COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-0'' || (SELECT no2 FROM equip_all_over_order 
        WHERE medi ->> ''procedure_cd'' :: TEXT = procedure_cd_no
        AND mmd.in_hospital_cd_1 = e01 AND medi ->> ''no'' = sorttag1) :: TEXT || ''-''|| ''1'' 
    ELSE COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-'' || (SELECT no2 FROM equip_all_over_order 
        WHERE medi ->> ''procedure_cd'' :: TEXT = procedure_cd_no
        AND mmd.in_hospital_cd_1 = e01 AND medi ->> ''no'' = sorttag1) :: TEXT || ''-''|| ''1'' END AS e09,
        ''手技'' AS aa,
    medi ->> ''no'' as sorttag1,
    ''2''  as sorttag2,
    '''' as sorttagclass
FROM
    do_ord_main ord
    cross join lateral json_array_elements (ord.ind_medi_info :: json) medi
LEFT OUTER JOIN
    mst_medicine mmd ON mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_procedure mp ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'',''999999999999'')
WHERE
    --患者経過総合ビューアの投与薬剤に手技が設定されている場合
    medi ->> ''procedure_cd'' IS NOT NULL
    AND medi->>''medicine_type'' = ''1''
    --連携設定 DIALYSIS_ITEM_PROCEDURE_TAGのkey2＝患者経過総合ビューアの投与薬剤に設定した手技の連携コード1がある場合
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) IS NOT NULL 
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) <> ''''
UNION
SELECT
    --22薬品手技(手技あり薬剤),単体薬剤
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE (CASE WHEN LENGTH(TRIM(mmd.in_hospital_cd_1)) > 8 THEN RIGHT(TRIM(mmd.in_hospital_cd_1), 8) ELSE RPAD(TRIM(mmd.in_hospital_cd_1), 8, '' '') END) END), '''') AS e01, 
    --項目属性
    COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END), COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_MEDICINE_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE mmd.medicine_name END), '''') AS e03, 
    --数量
    TO_CHAR(TO_NUMBER(medi ->> ''amount'', ''9999999.999''), ''FM0999999.990'') AS e04, 
    --選択単位フラグ
    CASE 
      WHEN (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) IS NULL OR 
           (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) = ''''
        THEN ''0'' 
      ELSE ''1''
    END AS e05, 
    --単位コード
    COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e06, 
    --単位名称
    COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_MEASURE_MEDICINE_TAG''), '''') AS e08, 
    --出力順
    CASE length((SELECT no2 FROM equip_all_over_order 
        WHERE medi ->> ''procedure_cd'' :: TEXT = procedure_cd_no
        AND mmd.in_hospital_cd_1 = e01 AND medi ->> ''no'' = sorttag1) :: TEXT) WHEN 1 THEN COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-0'' || (SELECT no2 FROM equip_all_over_order 
        WHERE medi ->> ''procedure_cd'' :: TEXT = procedure_cd_no
        AND mmd.in_hospital_cd_1 = e01 AND medi ->> ''no'' = sorttag1) :: TEXT || ''-''|| ''2'' 
    ELSE COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-'' || (SELECT no2 FROM equip_all_over_order 
        WHERE medi ->> ''procedure_cd'' :: TEXT = procedure_cd_no
        AND mmd.in_hospital_cd_1 = e01 AND medi ->> ''no'' = sorttag1) :: TEXT || ''-''|| ''2'' END AS e09,
        ''薬剤'' AS aa,
    medi ->> ''no''   as sorttag1,
    ''2''  as sorttag2,
    '''' as sorttagclass
FROM
    do_ord_main ord
    cross join lateral json_array_elements (ord.ind_medi_info :: json) medi
LEFT OUTER JOIN
    mst_medicine_mix mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_medicine mmd ON mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_procedure mp ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'',''999999999999'')
WHERE
    --患者経過総合ビューアの投与薬剤に手技が設定されている場合
    medi ->> ''procedure_cd'' IS NOT NULL
    AND medi->>''medicine_type'' = ''1''
    --連携設定 DIALYSIS_ITEM_PROCEDURE_TAGのkey2＝患者経過総合ビューアの投与薬剤に設定した手技の連携コード1がある場合
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) IS NOT NULL 
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) <> ''''
UNION
SELECT
    --23処置薬品名(手技なし薬剤),単体薬剤
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE (CASE WHEN LENGTH(TRIM(mmd.in_hospital_cd_1)) > 8 THEN RIGHT(TRIM(mmd.in_hospital_cd_1), 8) ELSE RPAD(TRIM(mmd.in_hospital_cd_1), 8, '' '') END) END), '''') AS e01, 
    --項目属性
    COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END), COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_NON_PROCEDURE_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE mmd.medicine_name END), '''') AS e03, 
    --数量
    TO_CHAR(TO_NUMBER(medi->>''amount'', ''9999999.999''), ''FM0999999.990'') AS e04, 
    --選択単位フラグ
    CASE 
      WHEN (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) IS NULL OR 
           (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) = ''''
        THEN ''0'' 
      ELSE ''1''
    END AS e05, 
    --単位コード
    COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e06, 
    --単位名称
    COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_MEASURE_MEDICINE_TAG''), '''') AS e08,
    --出力順
    CASE length((SELECT no2 FROM equip_all_over_order 
        WHERE medi ->> ''procedure_cd'' :: TEXT = procedure_cd_no
        AND mmd.in_hospital_cd_1 = e01 AND medi ->> ''no'' = sorttag1) :: TEXT) WHEN 1 THEN COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-0'' || (SELECT no2 FROM equip_all_over_order 
        WHERE medi ->> ''procedure_cd'' :: TEXT = procedure_cd_no
        AND mmd.in_hospital_cd_1 = e01 AND medi ->> ''no'' = sorttag1) :: TEXT || ''-''|| ''2'' 
    ELSE COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-'' || (SELECT no2 FROM equip_all_over_order 
        WHERE medi ->> ''procedure_cd'' :: TEXT = procedure_cd_no
        AND mmd.in_hospital_cd_1 = e01 AND medi ->> ''no'' = sorttag1) :: TEXT || ''-''|| ''2'' END AS e09,
        ''薬剤'' AS aa,
    medi ->> ''no'' as sorttag1,
    ''3'' as sorttag2,
    '''' as sorttagclass
FROM
    do_ord_main ord
    cross join lateral json_array_elements (ord.ind_medi_info :: json) medi
LEFT OUTER JOIN
    mst_medicine_mix mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_medicine mmd ON mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_procedure mp ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'',''999999999999'')
WHERE
    medi->>''medicine_type'' = ''1'' 
    AND (
      --患者経過総合ビューアの投与薬剤に手技が設定されていない場合
      medi ->> ''procedure_cd'' IS NULL
      OR(
        --患者経過総合ビューアの投与薬剤に手技が設定されている場合
        medi ->> ''procedure_cd'' IS NOT NULL
        --連携設定 DIALYSIS_ITEM_PROCEDURE_TAGのkey2＝患者経過総合ビューアの投与薬剤に設定した手技の連携コード1がない場合
        AND ((SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) IS  NULL 
        OR (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) = '''')
      )
    )
UNION
SELECT
    --22薬品手技(手技),調製薬剤
    ''予約詳細'' AS detail_id,  
    --項目コード
    COALESCE(mp.in_hospital_cd_a1, '''') AS e01, 
    --項目属性
    COALESCE(mp.in_hospital_cd_a2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_PROCEDURE_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE(mp.pricedure_name, '''') AS e03, 
    --数量
    ''0000000.000'' AS e04, 
    --選択単位フラグ
    ''0'' AS e05, 
    --単位コード
    '''' AS e06, 
    --単位名称
    '''' AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1), '''') AS e08, 
    --出力順
    CASE length((SELECT no2 FROM equip_all_over_order 
        WHERE medicine_type = ''2'' AND procedure_cd_no :: TEXT = medi ->> ''procedure_cd'' :: TEXT 
        AND e01 = mmd.in_hospital_cd_1 AND sorttag1 = medi ->> ''no'' AND ord_medicine_mix = 1) :: TEXT) WHEN 1 THEN COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-0'' || (SELECT no2 FROM equip_all_over_order 
        WHERE medicine_type = ''2'' AND procedure_cd_no :: TEXT = medi ->> ''procedure_cd'' :: TEXT 
        AND e01 = mmd.in_hospital_cd_1 AND sorttag1 = medi ->> ''no'' AND ord_medicine_mix = 1) :: TEXT || ''-''|| ''1'' 
    ELSE COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-'' || (SELECT no2 FROM equip_all_over_order 
        WHERE medicine_type = ''2'' AND procedure_cd_no :: TEXT = medi ->> ''procedure_cd'' :: TEXT 
        AND e01 = mmd.in_hospital_cd_1 AND sorttag1 = medi ->> ''no'' AND ord_medicine_mix = 1) :: TEXT || ''-''|| ''1'' END AS e09,
        ''手技'' AS aa,
    medi ->> ''no'' as sorttag1,
    ''2''  as sorttag2,
    '''' as sorttagclass
FROM
    do_ord_main ord
    cross join lateral json_array_elements (ord.ind_medi_info :: json) medi
LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'' :: TEXT, ''999999999999'' )
    CROSS JOIN LATERAL json_array_elements(mmx.mix_info :: json ) mmxd
LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'' )
LEFT OUTER JOIN
    mst_procedure mp ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'',''999999999999'')
WHERE
    --患者経過総合ビューアの投与薬剤に手技が設定されている場合
    medi ->> ''procedure_cd'' IS NOT NULL
    AND medi->>''medicine_type'' = ''2''
        AND (SELECT ord_medicine_mix FROM equip_all_over_order 
                 WHERE medicine_type = ''2'' AND procedure_cd_no :: TEXT = medi ->> ''procedure_cd'' :: TEXT 
                 AND e01 = mmd.in_hospital_cd_1 AND sorttag1 = medi ->> ''no'') = 1
    --連携設定 DIALYSIS_ITEM_PROCEDURE_TAGのkey2＝患者経過総合ビューアの投与薬剤に設定した手技の連携コード1がある場合
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) IS NOT NULL 
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) <> ''''
UNION
SELECT
    --22薬品手技(手技あり薬剤),調製薬剤
    ''予約詳細'' AS detail_id, 
    --項目コード
        CASE WHEN LENGTH(TRIM(mmd.in_hospital_cd_1)) > 8 THEN RIGHT(TRIM(mmd.in_hospital_cd_1), 8) ELSE RPAD(TRIM(mmd.in_hospital_cd_1), 8, '' '') END AS e01, 
        --項目属性
        COALESCE(mmd.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_MEDICINE_ATTR''), '''')) AS e02, 
        --項目名称
        COALESCE(mmd.medicine_name, '''') AS e03, 
        --数量
        TO_CHAR((TO_NUMBER(medi ->> ''amount'', ''9999999.999'') * TO_NUMBER(mmxd ->> ''amount'', ''9999999.999'' )), ''FM0999999.990'' ) AS e04, 
        --選択単位フラグ
        CASE 
            WHEN mmd.unit IS NULL OR mmd.unit = '''' THEN ''0'' ELSE ''1'' END AS e05, 
        --単位コード
        COALESCE(mmd.unit, '''') AS e06, 
        --単位名称
        COALESCE(mmd.unit, '''') AS e07,  
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_MEASURE_MEDICINE_TAG''), '''') AS e08, 
    --出力順
    CASE length((SELECT no2 FROM equip_all_over_order 
        WHERE medicine_type = ''2'' AND procedure_cd_no :: TEXT = medi ->> ''procedure_cd'' :: TEXT 
        AND e01 = mmd.in_hospital_cd_1 AND sorttag1 = medi ->> ''no'') :: TEXT) WHEN 1 THEN COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-0'' || (SELECT no2 FROM equip_all_over_order 
        WHERE medicine_type = ''2'' AND procedure_cd_no :: TEXT = medi ->> ''procedure_cd'' :: TEXT 
        AND e01 = mmd.in_hospital_cd_1 AND sorttag1 = medi ->> ''no'') :: TEXT || ''-''|| ''2''
    ELSE COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-'' || (SELECT no2 FROM equip_all_over_order 
        WHERE medicine_type = ''2'' AND procedure_cd_no :: TEXT = medi ->> ''procedure_cd'' :: TEXT 
        AND e01 = mmd.in_hospital_cd_1 AND sorttag1 = medi ->> ''no'') :: TEXT || ''-''|| ''2'' END AS e09,
        ''薬剤'' AS aa,
    (medi->>''no'') as sorttag1,
    ''22'' as sorttag2,
    (medi->>''class_cd'') as sorttagclass
FROM
    do_ord_main AS ord
        CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)
        LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
        LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
        CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
        LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
WHERE
    --患者経過総合ビューアの投与薬剤に手技が設定されている場合
    medi ->> ''procedure_cd'' IS NOT NULL
    AND medi ->> ''medicine_type'' = ''2''
    --連携設定 DIALYSIS_ITEM_PROCEDURE_TAGのkey2＝患者経過総合ビューアの投与薬剤に設定した手技の連携コード1がある場合
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) IS NOT NULL 
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) <> ''''
UNION
SELECT
    --23処置薬品名(手技なし薬剤),調製薬剤
    ''予約詳細'' AS detail_id, 
    --項目コード
        CASE WHEN LENGTH(TRIM(mmd.in_hospital_cd_1)) > 8 THEN RIGHT(TRIM(mmd.in_hospital_cd_1), 8) ELSE RPAD(TRIM(mmd.in_hospital_cd_1), 8, '' '') END AS e01, 
        --項目属性
        COALESCE(mmd.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_MEDICINE_ATTR''), '''')) AS e02, 
        --項目名称
        COALESCE(mmd.medicine_name, '''') AS e03, 
        --数量
        TO_CHAR((TO_NUMBER(medi ->> ''amount'', ''9999999.999'') * TO_NUMBER(mmxd ->> ''amount'', ''9999999.999'' )), ''FM0999999.990'' ) AS e04, 
        --選択単位フラグ
        CASE 
            WHEN mmd.unit IS NULL OR mmd.unit = '''' THEN ''0'' ELSE ''1'' END AS e05, 
        --単位コード
        COALESCE(mmd.unit, '''') AS e06, 
        --単位名称
        COALESCE(mmd.unit, '''') AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_MEASURE_MEDICINE_TAG''), '''') AS e08,
    --出力順
    CASE length((SELECT no2 FROM equip_all_over_order 
        WHERE medi ->> ''procedure_cd'' :: TEXT = procedure_cd_no
        AND mmd.in_hospital_cd_1 = e01 AND medi ->> ''no'' = sorttag1) :: TEXT) WHEN 1 THEN COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-0'' || (SELECT no2 FROM equip_all_over_order 
        WHERE medi ->> ''procedure_cd'' :: TEXT = procedure_cd_no
        AND mmd.in_hospital_cd_1 = e01 AND medi ->> ''no'' = sorttag1) :: TEXT || ''-''|| ''2''
    ELSE COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-'' || (SELECT no2 FROM equip_all_over_order 
        WHERE medi ->> ''procedure_cd'' :: TEXT = procedure_cd_no
        AND mmd.in_hospital_cd_1 = e01 AND medi ->> ''no'' = sorttag1) :: TEXT || ''-''|| ''2'' END AS e09,
        ''薬剤'' AS aa,
    (medi->>''no'') as sorttag1,
        ''33'' as sorttag2,
        (medi->>''class_cd'') as sorttagclass
FROM
    do_ord_main AS ord
        CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)
        LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
        LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
        CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
        LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
WHERE
    medi->>''medicine_type'' = ''2'' 
    AND (
      --患者経過総合ビューアの投与薬剤に手技が設定されていない場合
      medi ->> ''procedure_cd'' IS NULL
      OR(
        --患者経過総合ビューアの投与薬剤に手技が設定されている場合
        medi ->> ''procedure_cd'' IS NOT NULL
        --連携設定 DIALYSIS_ITEM_PROCEDURE_TAGのkey2＝患者経過総合ビューアの投与薬剤に設定した手技の連携コード1がない場合
        AND ((SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) IS  NULL 
        OR (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) = '''')
      )
    )
)
, data_all_copy AS (--と薬剤、の適合
SELECT equip_all_copy.detail_id, equip_all_copy.e01, equip_all_copy.e02, equip_all_copy.e03, equip_all_copy.e04, equip_all_copy.e05, equip_all_copy.e06, equip_all_copy.e07, equip_all_copy.e08, equip_all_copy.e09,sortTag1,sortTag2,sorttagclass, mmd.medicine_cd, mmd.class_cd as mdclass_cd 
FROM equip_all_copy 
    LEFT JOIN mst_medicine mmd ON equip_all_copy.e01 = mmd.in_hospital_cd_1 and equip_all_copy.e03 = mmd.medicine_name
        order by e09
)
, data_all_med as(--薬剤のモジュール
select detail_id,e01,e02,e03,data_all_copy.e04,e05,e06,e07,e08,e09,sortTag1,sortTag2,medicine_cd,
case when sorttag2 = ''22'' or sorttag2 = ''33'' then sorttagclass::text else mdclass_cd::text  end  as mdclass_cd 
             from data_all_copy where e09 > (SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_MEASURE_MEDICINE'') or e09::INTEGER < ((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_MEASURE_MEDICINE'')::INTEGER + 1)
)
, data_commmon as(--一般のモジュール
select detail_id, e01, e02, e03, e04, e05, e06, e07, e08, e09,sortTag1,sortTag2,''標準''::text as  aa from data_middle_all where e09<>(SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_EQUIP'')


ORDER BY  e09
)
, data_all_meq as(--医療材料のモジュール
SELECT
    --医療材料情報
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_EQUIP_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE(meq.equipment_name, '''') AS e03, 
    --数量
    COALESCE(TO_CHAR(TO_NUMBER(equip->>''amount'',''9999999.999'') ,''FM0999999.990''), '''') AS e04, 
    --選択単位フラグ
    CASE WHEN meq.unit IS NULL OR meq.unit = ''''
    THEN ''0'' ELSE ''1'' END AS e05, 
    --単位コード
    COALESCE(meq.unit, '''') AS e06, 
    --単位名称
    COALESCE(meq.unit, '''') AS e07, 
    --タグ名称
    COALESCE(meqc.class_name, '''') AS e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_EQUIP''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2,
		''医療材料''::text as aa,
		equip->>''cd'' as equipment_cd,
		equip->>''class_cd'' as mqclass_cd 
FROM
    do_ord_main ord
    cross join lateral json_array_elements (ord.ind_equip_info :: json) equip
LEFT OUTER JOIN
    mst_equipment meq ON meq.equipment_cd = TO_NUMBER(equip->>''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_equipment_class meqc ON meq.class_cd = meqc.class_cd
WHERE
    equip->>''equip_type'' = ''0''
)
, order_qcode_F AS (--医療材料の1，2场合
 SELECT DISTINCT ON (item_cd_f)* FROM (
   SELECT
     e01 AS item_cd_f,  
     CASE WHEN ''1'' in (SELECT ora FROM do_order_data_equip_from) THEN TO_NUMBER( meq_class_code_order :: text, ''999999999999'' ) ELSE NULL END AS class_qcd_f,
     CASE WHEN ''2'' in (SELECT ora FROM do_order_data_equip_from) THEN TO_NUMBER( meq_code_order :: text, ''999999999999'' ) ELSE NULL END AS meq_cd_f
   FROM
     data_all_meq
     LEFT OUTER JOIN do_mstmeq_cd ON meq_code ::text = data_all_meq.equipment_cd
--      LEFT OUTER JOIN do_mstmeq_class_cd ON meq_class_code ::text= data_all_meq.mqclass_cd
     LEFT OUTER JOIN mst_equipment ON mst_equipment.equipment_cd ::text = data_all_meq.equipment_cd
     LEFT OUTER JOIN do_mstmeq_class_cd ON meq_class_code = mst_equipment.class_cd
   ORDER BY item_cd_f asc) AS order_code_middle_QA 
 )
, order_qcode_S AS (--医療材料のない治療条件0场合
   SELECT
     (SELECT in_hospital_cd_1 FROM mst_equipment WHERE equipment_cd = TO_NUMBER( eqp ->> ''cd'' :: text, ''999999999999'')) AS item_cd_s,
     CASE WHEN ''0'' in (SELECT ora FROM do_order_data_equip_from) THEN TO_NUMBER( json_idx :: text, ''999999999999'' ) ELSE NULL END AS login_ord_s,
         (SELECT COALESCE(TO_CHAR(TO_NUMBER(eqp->> ''amount'',''9999999.999'') ,''FM0999999.990''), '''') FROM mst_equipment WHERE equipment_cd = TO_NUMBER( eqp ->> ''cd'', ''FM0999999.990'')) AS amount,
         ROW_NUMBER() OVER() as class_cd,
         ROW_NUMBER() OVER() as equip_cd
   FROM
     do_ord_main AS ord
     CROSS JOIN LATERAL json_array_elements(ord.ind_equip_info :: json) with ordinality as tmp(eqp, json_idx)
   ORDER BY item_cd_s, login_ord_s asc
    )   
, dataequipOrder as(--医療材料の0场合すでにソートされている
        select detail_id, e01, e02, e03, e04, e05, e06, e07, e08, e09,sortTag1,sortTag2,aa,ROW_NUMBER() OVER() as login_ord,class_cd,equip_cd from ( 
    (select ''予約詳細'' as detail_id, order_qcode_S.item_cd_s as e01, data_all_meq.e02, data_all_meq.e03, 
        order_qcode_S.amount as e04, data_all_meq.e05, data_all_meq.e06, data_all_meq.e07, data_all_meq.e08,
        data_all_meq.e09,data_all_meq.sortTag1,data_all_meq.sortTag2,
        data_all_meq.aa,order_qcode_S.login_ord_s,
     class_cd, 
      equip_cd
        from order_qcode_S,data_all_meq where order_qcode_S.item_cd_s = data_all_meq.e01 
        and aa = ''医療材料''
        and order_qcode_S.amount = data_all_meq.e04 order by login_ord_s
     )) as dataequipOrder)
, dataequipOrder1 as(
    select detail_id, e01, e02, e03, e04, e05, e06, e07, e08, e09,sortTag1,sortTag2,aa, 
    dataequipOrder.login_ord,order_qcode_F.class_qcd_f as class_cd,order_qcode_F.meq_cd_f as equip_cd
    from dataequipOrder,order_qcode_F where dataequipOrder.e01 =order_qcode_F.item_cd_f ) 
, equip_order as(
select *, ROW_NUMBER() OVER() as ordnow from (
 (select detail_id::text, e01, e02, e03, e04, e05, e06, e07, e08, e09, sortTag1::text,sortTag2::text,''治医療材料''::text as  aa
  from data_middle_all where e09=(SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_EQUIP'') and sortTag2 =''18'' 
	order by sorttag1)
	union all
(SELECT detail_id::text, e01, e02, e03, e04, e05, e06, e07, e08, e09, sortTag1::text,sortTag2::text, aa
 FROM dataequipOrder1
 ORDER BY 
     CASE WHEN (SELECT ora FROM do_order_data_equip_from WHERE no2 = 1) = 0 THEN login_ord
          WHEN (SELECT ora FROM do_order_data_equip_from WHERE no2 = 1) = 1 THEN class_cd
          WHEN (SELECT ora FROM do_order_data_equip_from WHERE no2 = 1) = 2 THEN equip_cd END,
     CASE WHEN (SELECT ora FROM do_order_data_equip_from WHERE no2 = 2) = 0 THEN login_ord
          WHEN (SELECT ora FROM do_order_data_equip_from WHERE no2 = 2) = 1 THEN class_cd
          WHEN (SELECT ora FROM do_order_data_equip_from WHERE no2 = 2) = 2 THEN equip_cd END,
     CASE WHEN (SELECT ora FROM do_order_data_equip_from WHERE no2 = 3) = 0 THEN login_ord
          WHEN (SELECT ora FROM do_order_data_equip_from WHERE no2 = 3) = 1 THEN class_cd
          WHEN (SELECT ora FROM do_order_data_equip_from WHERE no2 = 3) = 2 THEN equip_cd END)
)as equip_order
) 
, kou_coag_procedu AS(
    SELECT
    * 
FROM
    ( SELECT 
   ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 =''KOU_COAG_PROCEDURE_CODE''),'''') AS e01, 
    --項目属性
    COALESCE((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 =''KOU_COAG_PROCEDURE_ATTR''),'''') AS e02, 
    --項目名称
    COALESCE((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 =''KOU_COAG_PROCEDURE_NAME''),'''')  AS e03, 
    --数量
   ''0000000.000'' AS e04, 
    --選択単位フラグ
   ''0'' AS e05, 
    --単位コード
   '''' AS e06, 
    --単位名称
   '''' AS e07, 
    --タグ名称
   -- COALESCE((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 =''KOU_COAG_PROCEDURE_CODE''),'''') AS e08, 
      COALESCE(((SELECT VALUE FROM kou_coag_procedur_data)),'''') AS e08,
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-'' || ''0''||''-''||''0'' AS e09 ,
   '''' as sorttag1,
   '''' as sorttag2,
     '''' as aa
     FROM kou_coag_procedur_falg
         WHERE ctl = 1 
         AND ((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'' or
        (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''2'')       
                AND EXISTS(SELECT 1 FROM do_ord_main WHERE  (ind_cond_info->''25''->>''value'' is NOT NULL) AND (ind_cond_info->''25''->>''medicine_type'' = ''2'') )
        ) T
        
        UNION 
    SELECT
    --⑯抗凝固剤・初回(調製情報)
    ''予約詳細'' AS detail_id, 
    --項目コード
        CASE WHEN LENGTH(TRIM(mmd.in_hospital_cd_1)) > 8 THEN RIGHT(TRIM(mmd.in_hospital_cd_1), 8) ELSE RPAD(TRIM(mmd.in_hospital_cd_1), 8, '''') END AS e01,
    --項目属性
        CASE (select ctl FROM kou_coag_procedur_falg) WHEN 1  THEN COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_MEDICINE_ATTR''), '''') WHEN 2 THEN COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_NON_PROCEDURE_ATTR''), '''') ELSE ''''  end AS e02,
    --項目名称
    COALESCE(mmd.medicine_name, '''') AS e03,
    --数量
    COALESCE( TO_CHAR(TO_NUMBER(mmxd ->> ''amount'', ''9999999.999'' ), ''FM0999999.990'' ) )  AS e04,
    --選択単位フラグ
    CASE 
      WHEN mmd.unit IS NULL OR 
          mmd.unit = ''''
        THEN ''0''
          ELSE ''1''
  
    END AS e05, 
    --単位コード
   COALESCE(mmd.unit, '''') AS e06,
    --単位名称
   COALESCE(mmd.unit, '''') AS e07,
    --タグ名称
   COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_MEASURE_MEDICINE_TAG''), '''') AS e08, 
   COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''') || ''-00-'' ||json_idx AS e09,
    '''' as sorttag1,
    '''' as sorttag2,
        '''' as aa
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_medicine_mix mmx ON mmx.medicine_mix_cd = TO_NUMBER(ord.ind_cond_info->''25''->>''value'',''999999999999'')
 CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) with ordinality as tmp(mmxd, json_idx)
  LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
WHERE
    ((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'' or
        (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''2'')
        AND ord.ind_cond_info->''25''->>''medicine_type'' = ''2''
        AND (mmd.in_hospital_cd_2 IS NULL OR mmd.in_hospital_cd_2 ='''')
            UNION
SELECT
    --⑯抗凝固剤・初回(調製情報)
    ''予約詳細'' AS detail_id, 
    --項目コード
        CASE WHEN LENGTH(TRIM(mmd.in_hospital_cd_1)) > 8 THEN RIGHT(TRIM(mmd.in_hospital_cd_1), 8) ELSE RPAD(TRIM(mmd.in_hospital_cd_1), 8, '''') END AS e01,
    --項目属性
    COALESCE(mmd.in_hospital_cd_2, '''') AS e02, 
    --項目名称
    COALESCE(mmd.medicine_name, '''') AS e03,
    --数量
    COALESCE( TO_CHAR(TO_NUMBER(mmxd ->> ''amount'', ''9999999.999'' ), ''FM0999999.990'' ) )  AS e04,
    --選択単位フラグ
    CASE 
      WHEN mmd.unit IS NULL OR 
          mmd.unit = ''''
        THEN ''0''
          ELSE ''1''
  
    END AS e05, 
    --単位コード
   COALESCE(mmd.unit, '''') AS e06,
    --単位名称
   COALESCE(mmd.unit, '''') AS e07,
    --タグ名称
   COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_MEASURE_MEDICINE_TAG''), '''') AS e08, 
   COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''') || ''-00-'' ||json_idx AS e09,
    '''' as sorttag1,
    '''' as sorttag2,
        '''' as aa
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_medicine_mix mmx ON mmx.medicine_mix_cd = TO_NUMBER(ord.ind_cond_info->''25''->>''value'',''999999999999'')
 CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) with ordinality as tmp(mmxd, json_idx)
  LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
WHERE
    ((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'' or
        (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''2'')
        AND ord.ind_cond_info->''25''->>''medicine_type'' = ''2''
        AND (mmd.in_hospital_cd_2 IS NOT NULL OR mmd.in_hospital_cd_2 <>'''')
        AND ((select ctl FROM kou_coag_procedur_falg) = 1   OR (select ctl FROM kou_coag_procedur_falg) = 2) 
 ),
 combination as(
 --各部分の組み合わせ
    select *,ROW_NUMBER() OVER() as ordnow from  data_commmon
    union all
    select * from equip_order
    union all 
    select  detail_id::text, e01::text, e02::text, e03::text, e04::text, e05::text, e06::text, e07::text, e08::text, e09::text,sortTag1::text,sortTag2::text, aa,ROW_NUMBER() OVER() as ordnow from equip_all_copy
    union all
    select *,ROW_NUMBER() OVER() as ordnow from kou_coag_procedu
        )
        
  SELECT * FROM combination WHERE e01 <>'''' OR e01 is NOT NULL ORDER BY e09,ordnow', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通：透析予約繰り返し部', '2022-11-19 05:34:21.059',CURRENT_TIMESTAMP, '[{"sql_cd": -20, "field_name": "in_out", "replace_var": "@inOut"}, {"sql_cd": -151, "field_name": "check_user1_name", "replace_var": "@checkUser1Name"}, {"sql_cd": -151, "field_name": "check_user2_name", "replace_var": "@checkUser2Name"}, {"sql_cd": -152, "field_name": "disp_user_1_id", "replace_var": "@dispUser1Id"}, {"sql_cd": -152, "field_name": "disp_user_2_id", "replace_var": "@dispUser2Id"}]');
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-59, 'WITH sch_start_time_info AS (
  SELECT
    0 AS order_no 
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS start_time_kbn 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info ->> ''key1'' = ''COOP_CONFIG'' 
    AND info ->> ''key2'' = ''SCH_START_TIME'' 
  UNION
  SELECT
    1 AS order_no 
    , ''0'' AS start_time_kbn 
  ORDER BY order_no ASC LIMIT 1
)
(SELECT
  ord.treat_date AS treat_date,
  CASE WHEN (SELECT start_time_kbn FROM sch_start_time_info) = ''0''
  THEN mk.kur_standard_start_time
  ELSE SUBSTRING ( (ord.ind_schedule_user_info->''ind_treat_start_time'')::text, 2, 4 ) || ''00''
  END AS start_time
FROM
  ord_main ord
LEFT OUTER JOIN
  mst_kur mk
ON
(ord.ind_schedule_user_info->''ind_kur_cd'')::TEXT = mk.kur_cd::text
WHERE
  ord.ord_no = @ordNo)
	UNION
	(SELECT
  ord.treat_date AS treat_date,
  CASE WHEN (SELECT start_time_kbn FROM sch_start_time_info) = ''0''
  THEN mk.kur_standard_start_time
  ELSE ord.ind_treat_start_time || ''00''
  END AS start_time
FROM
  ord_main_restore ord
LEFT OUTER JOIN
  mst_kur mk
ON
  ord.ind_kur_cd = mk.kur_cd
WHERE
  ord.ord_no = @ordNo
	and (select count(1) from ord_main where ord_no = @ordNo) = ''0''
	order by del_date desc limit 1)', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）透析予約：オーダ日付とオーダ時間取得', '2022-03-22 10:53:38.415', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-132, 'WITH ord_main_data AS ( 
   ( SELECT (((ind_cond_info -> ''26'' ->> ''value'' )::FLOAT + (ind_cond_info -> ''28'' ->> ''value'')::FLOAT))::TEXT AS anti_coagulant_amount, pat_id
    FROM ord_main 
    WHERE ord_no = @ordNo)
		union 
				   ( SELECT (((ind_cond_info -> ''26'' ->> ''value'' )::FLOAT + (ind_cond_info -> ''28'' ->> ''value'')::FLOAT))::TEXT AS anti_coagulant_amount, pat_id
    FROM ord_main_restore
    WHERE ord_no = @ordNo
		and (select count(1) from  ord_main 
    WHERE ord_no = @ordNo) = ''0''
		ORDER BY del_date desc limit 1)
)
, ini_data AS (
    SELECT COALESCE
        ( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS default_setting 
    FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
    WHERE
        facility_cd = @facilityCd
     
        AND is_del = ''0''
                -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 start
                AND COALESCE(info ->> ''key0'', '''') = @key0
                -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 end 
        AND info ->> ''key1'' = ''DIALYSISSCHESEND'' 
        AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'' 
) 
, dialysis_date AS (
    SELECT
        REPLACE(MIN(I.period_start_date) :: TEXT, ''-'', '''') AS dialysis_start_date
    FROM
        pat_unique U
        CROSS JOIN LATERAL jsonb_to_recordset(U.in_out_visit_history_info) AS I
        (   ctl_no bigint,
            period_start_date date,
            period_start_day bigint,
            period_start_month bigint,
            period_start_year bigint,
            move_in_out smallint
        )
    WHERE pat_id = (SELECT pat_id FROM ord_main_data)
    AND U.is_del = ''0''
    AND I.period_start_day IS NOT NULL
    AND I.period_start_month IS NOT NULL
    AND I.period_start_year IS NOT NULL
    AND I.period_start_date IS NOT NULL
    AND I.move_in_out = 1
) 
, hospital_date AS (
    SELECT 
        REPLACE(MAX(I.period_start_date) :: TEXT, ''-'', '''') AS hospital_start_date
    FROM
        pat_unique U
        CROSS JOIN LATERAL jsonb_to_recordset(U.in_out_visit_history_info) AS I
        (   ctl_no bigint,
            period_start_date date,
            from_facility bigint,
            move_in_out smallint
        )
    WHERE pat_id = (SELECT pat_id FROM ord_main_data)
    AND U.is_del = ''0''
    AND I.period_start_date IS NOT NULL
    AND I.from_facility IS NULL
    AND (I.move_in_out = 1 OR I.move_in_out = 2)
)
SELECT dialysis_date.dialysis_start_date, hospital_date.hospital_start_date, ini_data.default_setting,
(CASE ord_main_data.anti_coagulant_amount::FLOAT >= 1
    WHEN TRUE THEN
        LPAD(split_part((ord_main_data.anti_coagulant_amount::FLOAT*100)::TEXT, ''.'', 1), 8, '' '')
    ELSE
        (
        CASE ini_data.default_setting
    WHEN ''0'' THEN
        LPAD(split_part((ord_main_data.anti_coagulant_amount::FLOAT*100)::TEXT, ''.'', 1), 8, '' '')
    WHEN ''1'' THEN
        LPAD(LPAD(split_part((ord_main_data.anti_coagulant_amount::FLOAT*100)::TEXT, ''.'', 1), 3, ''0''), 8, '' '')
  END
    )
END
) AS calculate_one_shot_amount
FROM ord_main_data, ini_data, dialysis_date, hospital_date', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）指示）透析条件', '2022-08-18 15:49:19.638',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-661, 'WITH  KOU_COAG_RESOLVE_MODE_cd AS(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 start
        AND COALESCE(info ->> ''key0'', '''') = @key0
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 end
    AND info ->> ''key1'' = ''DIALYSISSCHESEND''
    AND info ->> ''key2'' = ''KOU_COAG_RESOLVE_MODE'')
,CREATE_NUMBER_FUNCTION_cd AS(SELECT
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 start
        AND COALESCE(info ->> ''key0'', '''') = @key0
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 end
    AND info ->> ''key1'' = ''DIALYSISSCHESEND''
    AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'')
,IND_COND_INFO AS (
select ord.ord_no,
ord.ind_cond_info:: json ->''25'' ->> ''value'' as mix_cd, 
ord.ind_cond_info:: json ->''25'' ->> ''medicine_type'' as mix_medicine_type, 
to_number(ord.ind_cond_info:: json ->''26'' ->> ''value'', ''9999.99'')+
to_number(ord.ind_cond_info:: json ->''28'' ->> ''value'', ''9999.99'') as mix_count
from ord_main ord where ord.ord_no = @ordNo
union 
(
select ord.ord_no,
ord.ind_cond_info:: json ->''25'' ->> ''value'' as mix_cd, 
ord.ind_cond_info:: json ->''25'' ->> ''medicine_type'' as mix_medicine_type, 
to_number(ord.ind_cond_info:: json ->''26'' ->> ''value'', ''9999.99'')+
to_number(ord.ind_cond_info:: json ->''28'' ->> ''value'', ''9999.99'') as mix_count
from ord_main_restore ord where ord.ord_no = @ordNo
and (select count(1) from ord_main where ord_no = @ordNo) = ''0''
order by del_date desc limit 1)
)
select 
TRIM(condinfo.e01) as medi_cd1,
CASE WHEN ''0'' = (SELECT case when (select staff_cd from CREATE_NUMBER_FUNCTION_cd) IS NULL or 
            (select staff_cd from CREATE_NUMBER_FUNCTION_cd) = ''''
            then  ''0'' else (select staff_cd from CREATE_NUMBER_FUNCTION_cd)
            END) THEN  
                                        (((condinfo.e02::float)*100) :: INTEGER :: TEXT)
                                 ELSE
                                        case when(((condinfo.e02::float)*100)::INTEGER) > 99 then (((condinfo.e02::float)*100) :: INTEGER :: TEXT)
                                        else 
                                            case when (((condinfo.e02::float)*100)::INTEGER)>10 then ''0''||(((condinfo.e02::float)*100) :: INTEGER :: TEXT)
                                            else ''00''||(((condinfo.e02::float)*100) :: INTEGER :: TEXT)
                                            end
                                        END 
                                 END as medi_amount,
TRIM(condinfo.e03) as medi_unit 
from 
(
SELECT * FROM 
    (--①調製
select mmx.in_hospital_cd_1 as e01,
to_char((select mix_count from IND_COND_INFO) :: NUMERIC, ''FM99990.00'' ) as e02,
mmx.unit as e03,
''1'' as e04
from mst_medicine_mix as mmx 
where mmx.medicine_mix_cd = to_number((select mix_cd from IND_COND_INFO), ''999999'')
AND (select mix_medicine_type from IND_COND_INFO) = ''2''
UNION ALL
    select mmx.in_hospital_cd_1 as e01,
to_char((select mix_count from IND_COND_INFO) :: NUMERIC, ''FM99990.00'' ) as e02,
mmx.unit as e03,
''0'' as e04
from mst_medicine_mix as mmx 
where mmx.medicine_mix_cd = to_number((select mix_cd from IND_COND_INFO), ''999999'')
AND (select mix_medicine_type from IND_COND_INFO) = ''2'' ) as a 
    where a.e04 = (SELECT case when (select staff_cd from KOU_COAG_RESOLVE_MODE_cd) IS NULL or 
            (select staff_cd from KOU_COAG_RESOLVE_MODE_cd) = ''''
            then  ''0'' else (select staff_cd from KOU_COAG_RESOLVE_MODE_cd)
            END)
        AND (select mix_medicine_type from IND_COND_INFO) = ''2''
UNION --②単体
select mmd.in_hospital_cd_1 as e01,
to_char((select mix_count from IND_COND_INFO) :: NUMERIC, ''FM99990.00'' ) as e02,
mmd.unit as e03,
''-1'' as e04
from mst_medicine as mmd 
where mmd.medicine_cd = to_number((select mix_cd from IND_COND_INFO), ''999999'')
AND (select mix_medicine_type from IND_COND_INFO) = ''1'') AS condinfo

', 2, '[{}]', '1', '{"applications": [4]}', NULL, '抗凝固剤', '2022-12-17 05:44:06.942',CURRENT_TIMESTAMP, NULL);

INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-191, 'WITH do_order_data_from AS (
SELECT ROW_NUMBER () OVER () AS no2, TO_NUMBER(datt.a1  :: text, ''999999999999'') AS ora
FROM (SELECT TO_NUMBER((unnest(string_to_array((
SELECT mst_f.value AS rtt
  FROM mst_facility_setting AS mst_f 
  WHERE mst_f.facility_setting_no = ''3006'' AND mst_f.facility_cd = @facilityCd),'',''))), ''999999999999'') AS a1) AS datt
)
, do_mstmeq_cd AS (
SELECT index_no AS meq_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_code, order_cd ->> ''name'' AS meq_code_name
FROM mst_selector
    CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd 
   AND master_physical_name = ''mst_equipment'' 
)
, do_mstmeq_class_cd AS (
SELECT index_no AS meq_class_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_class_code, order_cd ->> ''name'' AS meq_class_code_name
FROM mst_selector
    CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd 
   AND master_physical_name = ''mst_equipment_class'' 
)
, do_ord AS (
SELECT * FROM ord_main_restore as ord_i
WHERE ord_i.ord_no = @ordNo AND ord_i.facility_cd = @facilityCd
ORDER BY del_date DESC LIMIT 1
)
, data_middle_all AS (
select 
 ''指示医材del'' as detail_id,
 row_number() over() as equip_no,
 all_equip.equip_class_type as class,
 all_equip.cd1 as cd1,
 all_equip.cd2 as cd2,
 all_equip.cd3 as cd3,
 all_equip.cd4 as cd4,
 all_equip.equip_name as name,
 ((COALESCE(all_equip.amount, ''0'')::FLOAT))::INTEGER as amount,
 all_equip.unit as unit,
 all_equip.syoumouhinOrder as syoumouhinOrder
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
  meqad.unit,
  1 as syoumouhinOrder
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
  meqpr.unit,
    2 as syoumouhinOrder
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
  meqse.unit,
    3 as syoumouhinOrder
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
  meqa.unit,
    4 as syoumouhinOrder
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
  meqv.unit,
    4 as syoumouhinOrder
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
  meqsn.unit,
    4 as syoumouhinOrder
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
  meqbc.unit,
    5 as syoumouhinOrder
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
   meq.unit as equip_unit,
     6 as syoumouhinOrder
from
        ord_main as ord
    cross join lateral
        json_array_elements (ord.ind_equip_info :: json) equip
     left outer join
         mst_equipment as meq
     on
         meq.equipment_cd = TO_NUMBER (equip ->> ''cd'',''999999999999'')
     left join mst_equipment_class as meqc
     on meq.class_cd = meqc.class_cd
    where
        --meq.class_cd = meqc.class_cd and
        ord.ord_no =@ordNo
				and equip ->> ''equip_type'' = ''0''
						UNION ALL
  SELECT--医材情報
    ''ダイアライザ'' as equip_class_type,
		meq.model_number as equip_name,
    meq.in_hospital_cd_1 AS cd1,
		meq.in_hospital_cd_2 AS cd2,
		meq.in_hospital_cd_3 AS cd3,
		meq.in_hospital_cd_4 AS cd4,
		equip ->> ''amount'' as equip_amount,
    equip ->> ''unit'' as equip_unit,
    25 AS syoumouhinOrder
  FROM
   do_ord as ord
    CROSS JOIN LATERAL json_array_elements ( ord.ind_equip_info :: json ) equip
    LEFT OUTER JOIN mst_dialyzer AS meq ON meq.dialyzer_cd = TO_NUMBER( equip ->> ''cd'', ''999999999999'' )
  WHERE
    equip ->> ''equip_type'' = ''1''
    and ord.ord_no =@ordNo
				
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
 ((COALESCE(all_equip.amount, ''0'')::FLOAT))::INTEGER as amount,
 all_equip.unit as unit,
 all_equip.syoumouhinOrder as syoumouhinOrder
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
  meqad.unit,
    1 as syoumouhinOrder
from
  --ord_main_restore as ord
    do_ord as ord
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
  meqpr.unit,
    2 as syoumouhinOrder
 from
  --ord_main_restore as ord
    do_ord as ord
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
  meqse.unit,
    3 as syoumouhinOrder
  from
  --ord_main_restore as ord
    do_ord as ord
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
  meqa.unit,
    4 as syoumouhinOrder
 from
  --ord_main_restore as ord
    do_ord as ord
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
  meqv.unit,
    4 as syoumouhinOrder
  from
  --ord_main_restore as ord
    do_ord as ord
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
  meqsn.unit,
    4 as syoumouhinOrder
   from
  --ord_main_restore as ord
    do_ord as ord
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
  meqbc.unit,
    5 as syoumouhinOrder
from
  --ord_main_restore as ord
    do_ord as ord
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
   meq.unit as equip_unit,
     6 as syoumouhinOrder
from
        --ord_main_restore as ord
    do_ord as ord
    cross join lateral
        json_array_elements (ord.ind_equip_info :: json) equip
     left outer join
         mst_equipment as meq
     on
         meq.equipment_cd = TO_NUMBER (equip ->> ''cd'',''999999999999'')
     left join mst_equipment_class as meqc
     on meq.class_cd = meqc.class_cd
    where
        --meq.class_cd = meqc.class_cd and
        ord.ord_no =@ordNo
				and equip ->> ''equip_type'' = ''0''
        and ''0'' =(
        select count(*) from ord_main where ord_no =@ordNo)
			UNION ALL
  SELECT--医材情報
    ''ダイアライザ'' as equip_class_type,
		meq.model_number as equip_name,
    meq.in_hospital_cd_1 AS cd1,
		meq.in_hospital_cd_2 AS cd2,
		meq.in_hospital_cd_3 AS cd3,
		meq.in_hospital_cd_4 AS cd4,
		equip ->> ''amount'' as equip_amount,
    equip ->> ''unit'' as equip_unit,
    25 AS syoumouhinOrder
  FROM
   do_ord as ord
    CROSS JOIN LATERAL json_array_elements ( ord.ind_equip_info :: json ) equip
    LEFT OUTER JOIN mst_dialyzer AS meq ON meq.dialyzer_cd = TO_NUMBER( equip ->> ''cd'', ''999999999999'' )
  WHERE
    equip ->> ''equip_type'' = ''1''
    and ord.ord_no =@ordNo
    and ''0'' =(
        select count(*) from ord_main where ord_no =@ordNo)
) all_equip
where
 all_equip.cd1 is not null)
 )
, do_data_group AS (
SELECT 
    (detail_id:: text) as detail_id, cd1, name, sum(amount) as amount
        , CASE WHEN SUM(syoumouhinOrder) > 6 THEN SUM(syoumouhinOrder) - 6 ELSE SUM(syoumouhinOrder) END AS syoumouhinOrder
FROM  
    data_middle_all
GROUP BY cd1, detail_id :: text, name
)
, data_all AS (
 SELECT DISTINCT do_data_group.detail_id AS detail_id, do_data_group.cd1 AS cd1, cd2, cd3, cd4, do_data_group.name AS name, do_data_group.amount AS amount, unit, 
        do_data_group.syoumouhinOrder AS syoumouhinOrder
 FROM do_data_group
      LEFT JOIN data_middle_all ON data_middle_all.cd1 = do_data_group.cd1
)
, order_code_up_F AS (
SELECT DISTINCT ON (e01f)* FROM (
  SELECT 
    meq.in_hospital_cd_1 AS e01f
    , CASE WHEN 1 in (SELECT ora FROM do_order_data_from) THEN TO_NUMBER(do_mstmeq_class_cd.meq_class_code_order :: text, ''999999999999'') ELSE NULL END AS cl_cd_f
    , CASE WHEN 2 in (SELECT ora FROM do_order_data_from) THEN TO_NUMBER(do_mstmeq_cd.meq_code_order :: text, ''999999999999'') ELSE NULL END AS eq_cd_f
  FROM
    do_mstmeq_cd
    LEFT JOIN mst_equipment AS meq ON do_mstmeq_cd.meq_code = meq.equipment_cd
    LEFT JOIN do_mstmeq_class_cd ON do_mstmeq_class_cd.meq_class_code = meq.class_cd
  WHERE meq.in_hospital_cd_1 IS NOT NULL
  ORDER BY e01f asc) AS order_code_middle_F
)
, order_code_up_S AS (
SELECT DISTINCT ON (e01s)* FROM (
  SELECT 
    CASE WHEN (SELECT in_hospital_cd_1 FROM mst_equipment AS meq 
                   WHERE meq.equipment_cd = TO_NUMBER(equip ->> ''cd'' :: text, ''999999999999'') 
                     AND meq.in_hospital_cd_1 IS NOT NULL) IS NULL
         THEN (SELECT in_hospital_cd_1 FROM mst_dialyzer AS dia 
                   WHERE dia.dialyzer_cd = TO_NUMBER(equip ->> ''cd'' :: text, ''999999999999'') 
                     AND dia.in_hospital_cd_1 IS NOT NULL)
         ELSE (SELECT in_hospital_cd_1 FROM mst_equipment AS meq 
                   WHERE meq.equipment_cd = TO_NUMBER(equip ->> ''cd'' :: text, ''999999999999'') 
                     AND meq.in_hospital_cd_1 IS NOT NULL) END AS e01s,
    CASE WHEN 0 in (SELECT ora FROM do_order_data_from) THEN TO_NUMBER(json_idx :: text, ''999999999999'') ELSE NULL END AS login_ord_s
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_equip_info :: json) with ordinality as tmp(equip, json_idx)
  WHERE
    ord.ord_no = @ordNo
  ORDER BY e01s, login_ord_s asc) AS order_code_middle_S
	union 
	(
	SELECT DISTINCT ON (e01s)* FROM (
  SELECT 
    CASE WHEN (SELECT in_hospital_cd_1 FROM mst_equipment AS meq 
                   WHERE meq.equipment_cd = TO_NUMBER(equip ->> ''cd'' :: text, ''999999999999'') 
                     AND meq.in_hospital_cd_1 IS NOT NULL) IS NULL
         THEN (SELECT in_hospital_cd_1 FROM mst_dialyzer AS dia 
                   WHERE dia.dialyzer_cd = TO_NUMBER(equip ->> ''cd'' :: text, ''999999999999'') 
                     AND dia.in_hospital_cd_1 IS NOT NULL)
         ELSE (SELECT in_hospital_cd_1 FROM mst_equipment AS meq 
                   WHERE meq.equipment_cd = TO_NUMBER(equip ->> ''cd'' :: text, ''999999999999'') 
                     AND meq.in_hospital_cd_1 IS NOT NULL) END AS e01s,
    CASE WHEN 0 in (SELECT ora FROM do_order_data_from) THEN TO_NUMBER(json_idx :: text, ''999999999999'') ELSE NULL END AS login_ord_s
  FROM
    do_ord AS ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_equip_info :: json) with ordinality as tmp(equip, json_idx)
		where ''0'' =(
        select count(*) from ord_main where ord_no = @ordNo )
  ORDER BY e01s, login_ord_s asc) AS order_code_middle_S
	)
)
, do_data AS (
SELECT detail_id, cd1, cd2, cd3, cd4, name, amount, unit, syoumouhinOrder
    , (SELECT login_ord_s FROM order_code_up_S WHERE e01s = cd1) AS login_ord
        , CASE WHEN (SELECT cl_cd_f FROM order_code_up_F WHERE e01f = cd1) IS NULL THEN 0 ELSE (SELECT cl_cd_f FROM order_code_up_F WHERE e01f = cd1) END AS cl_cd
    , (SELECT eq_cd_f FROM order_code_up_F WHERE e01f = cd1) AS eq_cd
FROM  data_all
)
SELECT detail_id, cd1, cd2, cd3, cd4, name, amount, unit, syoumouhinOrder, login_ord, cl_cd, eq_cd
FROM do_data
ORDER BY syoumouhinOrder,
    CASE WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 1) = 0 THEN login_ord
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 1) = 1 THEN cl_cd
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 1) = 2 THEN eq_cd END,
    CASE WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 2) = 0 THEN login_ord
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 2) = 1 THEN cl_cd
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 2) = 2 THEN eq_cd END,
    CASE WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 3) = 0 THEN login_ord
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 3) = 1 THEN cl_cd
         WHEN (SELECT ora FROM do_order_data_from WHERE no2 = 3) = 2 THEN eq_cd END
limit 12', 2, '[{}]', '1', '{"applications": [4]}', NULL, '指示)中止時）指示医材1コード', '2022-06-18 05:06:30.633',CURRENT_TIMESTAMP, NULL);
