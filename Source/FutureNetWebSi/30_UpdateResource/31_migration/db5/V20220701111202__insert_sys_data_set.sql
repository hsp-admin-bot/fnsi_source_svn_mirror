delete from ntss.sys_data_set where sql_cd in (-13);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-13, 'SELECT
  ord.treat_date AS dialysis_date,
  ord.facility_cd AS facility_cd,
  COALESCE ( concat ( ord.ind_schedule_user_info ->> ''ind_user_last_name'', '' '', ord.ind_schedule_user_info ->> ''ind_user_first_name'' ), '''' ) AS ind_name,
  COALESCE ( LEFT ( concat ( ord.ind_schedule_user_info ->> ''ind_user_last_name'', '' '', ord.ind_schedule_user_info ->> ''ind_user_first_name'' ), 5 ), '''' ) AS ind_name10,
	COALESCE(ord.ind_schedule_user_info ->> ''ind_user_id'', '''') AS staff_cd_comm,
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
  ord.ord_no = @ordNo and
  pm.pat_id = ord.pat_id', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）指示）透析条件', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

delete from ntss.sys_data_set where sql_cd in (-951);
  INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-951, 'SELECT 
    disp_user_id AS disp_user_id 
FROM 
    mst_user_authentication 
WHERE 
    user_id = @userId', 1, '[{}]', '0', '{"applications": [4]}', NULL, '(日机装)ind_dial', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -13, "field_name": "staff_cd_comm", "replace_var": "@userId"}, {"sql_cd": -753, "field_name": "staff_cd", "replace_var": "@userId"}, {"sql_cd": -852, "field_name": "staff_cd", "replace_var": "@userId"}]');

delete from ntss.sys_data_set where sql_cd in (-753);
  INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-753, 'with ind_user_id as (SELECT ord.ind_schedule_user_info ->> ''ind_user_id''  AS staff_cd FROM  ord_main AS ord 
WHERE  ord.ord_no = @ordNo),
ini_key as (SELECT COALESCE ( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS staff_cd 
FROM mst_coop_ini AS ini
CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
WHERE
	facility_cd = @facilityCd 
	AND is_del = ''0'' 
	AND info ->> ''key1'' = ''DIALYSISSCHESEND'' 
	AND info ->> ''key2'' = ''DEFAULT_DOCTOR'' 
	) 
select staff_cd from ind_user_id
where 
  ''0'' = (select * from ini_key)		
	UNION
		
(SELECT 
 charge_staff ->> ''staff_cd'' AS lll
  FROM
    pat_main AS pm,jsonb_array_elements(pm.charge_staff_info) as charge_staff
  WHERE
    pm.pat_id = @patId
		AND charge_staff ->> ''is_main'' = ''1''
		and ''1'' = (select * from ini_key)
		order by charge_staff ->> ''ctl_no'' LIMIT 1)
	UNION
	
	select staff_cd from ind_user_id
		where  ''0'' = (SELECT COUNT(charge_staff ->> ''staff_cd'')FROM
    pat_main AS pm,jsonb_array_elements(pm.charge_staff_info) as charge_staff
  WHERE
    pm.pat_id = @patId
		AND charge_staff ->> ''is_main'' = ''1'')
		AND ''1'' = (select * from ini_key)', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(日机装)ind_dial', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
delete from ntss.sys_data_set where sql_cd in (-852);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-852, 'with ind_user_id as (SELECT ord.ind_schedule_user_info ->> ''ind_user_id''  AS staff_cd FROM  ord_main AS ord 
WHERE  ord.ord_no = @ordNo),
ini_key as (SELECT COALESCE ( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS staff_cd 
FROM mst_coop_ini AS ini
CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
WHERE
	facility_cd = @facilityCd 
	AND is_del = ''0'' 
	AND info ->> ''key1'' = ''DIALYSISSCHESEND'' 
	AND info ->> ''key2'' = ''DEFAULT_DOCTOR'' 
	) ,
ind_user_count as (SELECT count( ord.ind_schedule_user_info ->> ''ind_user_id'' ) FROM ord_main AS ord WHERE ord.ord_no = @ordNo),
restore_ind_user_id as (SELECT ord.ind_schedule_user_info ->> ''ind_user_id''  AS staff_cd FROM  ord_main_restore AS ord  WHERE  ord.ord_no = @ordNo)
SELECT  staff_cd from ind_user_id
where 
''0'' = (select * from ini_key)
AND 0 < ( SELECT *  from ind_user_count ) 
UNION
	( SELECT charge_staff ->> ''staff_cd'' AS staff_cd 
FROM pat_main AS pm,
jsonb_array_elements ( pm.charge_staff_info ) AS charge_staff
WHERE
	pm.pat_id = @patId 
	AND charge_staff ->> ''is_main'' = ''1'' 
	AND 0 < ( SELECT *  from ind_user_count )  
	AND ''1'' = (select * from ini_key)
ORDER BY
	charge_staff ->> ''ctl_no'' 
	LIMIT 1 
	)
	UNION
SELECT staff_cd from ind_user_id 
	where
 ''0'' = (
SELECT COUNT( charge_staff ->> ''staff_cd'' ) 
FROM pat_main AS pm,
jsonb_array_elements ( pm.charge_staff_info ) AS charge_staff 
WHERE
	pm.pat_id = @patId 
	AND charge_staff ->> ''is_main'' = ''1'' 
	) 
	AND ''0'' < ( select * from ind_user_count) 
	AND ''1'' = (select * from ini_key ) 
	union
	select staff_cd from restore_ind_user_id where 
	''0'' = ( select * from ind_user_count) 
	AND ''0'' = (select * from ini_key ) 
	UNION
	(
SELECT
	charge_staff ->> ''staff_cd'' AS staff_cd 
FROM
	pat_main AS pm,
	jsonb_array_elements ( pm.charge_staff_info ) AS charge_staff 
WHERE
	pm.pat_id = @patId 
	AND charge_staff ->> ''is_main'' = ''1'' 
	AND ''0'' = ( select * from ind_user_count ) 
	AND ''1'' = ( select * from ini_key ) 
ORDER BY
	charge_staff ->> ''ctl_no'' 
	LIMIT 1 
	) UNION
select staff_cd from restore_ind_user_id
	where ''0'' = (
SELECT
	COUNT( charge_staff ->> ''staff_cd'' ) 
FROM
	pat_main AS pm,
	jsonb_array_elements ( pm.charge_staff_info ) AS charge_staff 
WHERE
	pm.pat_id = @patId 
	AND charge_staff ->> ''is_main'' = ''1'' 
	) 
	AND ''0'' = ( select * from ind_user_count ) 
	AND ''1'' = ( select * from ini_key)
	', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(日机装)ind_dial', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

