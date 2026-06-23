DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (16,133);
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
	medic_mix AS (
	SELECT
		index_no AS medic_mix_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medic_mix_code,
		order_cd ->> ''name'' AS medi_mix_name
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
	dia AS (
	SELECT
		index_no AS dia_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS dia_code,
		order_cd ->> ''name'' AS equi_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND master_physical_name = ''mst_dialyzer''
	),
	medi_mix AS (
	SELECT
		index_no AS medi_mix_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_mix_code,
		order_cd ->> ''name'' AS equi_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND master_physical_name = ''mst_medicine_mix''
	),
  spi AS (
	SELECT
		index_no AS spitz_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS spitz_code,
		order_cd ->> ''name'' AS spitz_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND master_physical_name = ''mst_spitz''
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
		dialyzer_cd,
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
			dz.dialyzer_cd,
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
			2 AS disp_order,
			eq.equipment_cd AS equipment_cd,
			eqc.class_cd AS equipment_class_cd,
			NULL AS medicine_cd,
			NULL AS medicine_class_cd,
			NULL AS dialyzer_cd,
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
			2 AS disp_order,
			eq.equipment_cd AS equipment_cd,
			eqc.class_cd AS equipment_class_cd,
			NULL AS medicine_cd,
			NULL AS medicine_class_cd,
			NULL AS dialyzer_cd,
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
			2 AS disp_order,
			eq.equipment_cd AS equipment_cd,
			eqc.class_cd AS equipment_class_cd,
			NULL AS medicine_cd,
			NULL AS medicine_class_cd,
			NULL AS dialyzer_cd,
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
			2 AS disp_order,
			eq.equipment_cd AS equipment_cd,
			eqc.class_cd AS equipment_class_cd,
			NULL AS medicine_cd,
			NULL AS medicine_class_cd,
			NULL AS dialyzer_cd,
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
			2 AS disp_order,
			eq.equipment_cd AS equipment_cd,
			eqc.class_cd AS equipment_class_cd,
			NULL AS medicine_cd,
			NULL AS medicine_class_cd,
			NULL AS dialyzer_cd,
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
			2 AS disp_order,
			eq.equipment_cd AS equipment_cd,
			eqc.class_cd AS equipment_class_cd,
			NULL AS medicine_cd,
			NULL AS medicine_class_cd,
			NULL AS dialyzer_cd,
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
			2 AS disp_order,
			eq.equipment_cd AS equipment_cd,
			eqc.class_cd AS equipment_class_cd,
			NULL AS medicine_cd,
			NULL AS medicine_class_cd,
			NULL AS dialyzer_cd,
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
			3 AS disp_order,
			NULL AS equipment_cd,
			NULL AS equipment_class_cd,
			md.medicine_cd :: TEXT AS medicine_cd,
			mdc.class_cd :: TEXT AS medicine_class_cd,
			NULL AS dialyzer_cd,
			om.treat_date,
			kr.kur_cd,
			kr.kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.ind_bed_cd AS bed_cd,
			om.pat_id,
			COALESCE ( mdc.class_name, '''' ) AS kind,
			md.medicine_name AS NAME,
			CAST( cond_dl_am AS DECIMAL) AS Amount,
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
			3 AS disp_order,
			NULL AS equipment_cd,
			NULL AS equipment_class_cd,
			md.medicine_cd :: TEXT AS medicine_cd,
			mdc.class_cd :: TEXT AS medicine_class_cd,
			NULL AS dialyzer_cd,
			om.treat_date,
			kr.kur_cd,
			kr.kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.ind_bed_cd AS bed_cd,
			om.pat_id,
			COALESCE ( mdc.class_name, '''' ) AS kind,
			md.medicine_name AS NAME,
			CAST( om.ind_cond_info :: json #>> ''{22,value}'' AS DECIMAL) AS Amount,
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
			3 AS disp_order,
			NULL AS equipment_cd,
			NULL AS equipment_class_cd,
			md.medicine_cd :: TEXT AS medicine_cd,
			mdc.class_cd :: TEXT AS medicine_class_cd,
			NULL AS dialyzer_cd,
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
					( CAST( om.ind_cond_info :: json #>> ''{26,value}'' AS DECIMAL) + CAST( om.ind_cond_info :: json #>> ''{28,value}'' AS DECIMAL) ) /
				CASE

						WHEN md.unit_converted_amount IS NULL
						OR md.unit_converted_amount = 0 THEN
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
				CAST( om.ind_cond_info :: json #>> ''{26,value}'' AS DECIMAL ) || om.unit AS cond_ac_shot,
				CAST( om.ind_cond_info :: json #>> ''{27,value}'' AS DECIMAL) ||
			CASE

					WHEN om.unit IS NULL THEN
					'''' ELSE om.unit || ''/h''
				END AS cond_ac_spd,
				CAST( om.ind_cond_info :: json #>> ''{28,value}'' AS DECIMAL) || om.unit AS cond_ac_dur_total,
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
				CAST( om.ind_cond_info :: json #>> ''{26,value}'' AS DECIMAL) + CAST( om.ind_cond_info :: json #>> ''{28,value}'' AS DECIMAL) || om.unit AS num_unit,
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
				4 AS disp_order,
				NULL AS equipment_cd,
				NULL AS equipment_class_cd,
				mmx.medicine_mix_cd :: TEXT AS medicine_cd,
				mdc.class_cd :: TEXT AS medicine_class_cd,
			  NULL AS dialyzer_cd,
				om.treat_date,
				kr.kur_cd,
				kr.kur_name,
				COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
				om.ind_bed_cd AS bed_cd,
				om.pat_id,
				COALESCE ( mdc.class_name, '''' ) AS kind,
				mmx.medicine_mix_name AS NAME,
				( CAST( om.ind_cond_info :: json #>> ''{26,value}'' AS DECIMAL) + CAST( om.ind_cond_info :: json #>> ''{28,value}'' AS DECIMAL) ) AS Amount,
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
				CAST( om.ind_cond_info :: json #>> ''{26,value}'' AS DECIMAL) || om.unit AS cond_ac_shot,
				CAST( om.ind_cond_info :: json #>> ''{27,value}'' AS DECIMAL) ||
			CASE

					WHEN om.unit IS NULL THEN
					'''' ELSE om.unit || ''/h''
				END AS cond_ac_spd,
				CAST( om.ind_cond_info :: json #>> ''{28,value}'' AS DECIMAL) || om.unit AS cond_ac_dur_total,
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
				( CAST( om.ind_cond_info :: json #>> ''{26,value}'' AS DECIMAL) + CAST( om.ind_cond_info :: json #>> ''{28,value}'' AS DECIMAL) ) || COALESCE ( mmx.unit, '''' ) AS num_unit,
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
				3 AS disp_order,
				NULL AS equipment_cd,
				NULL AS equipment_class_cd,
				md.medicine_cd :: TEXT AS medicine_cd,
				mdc.class_cd :: TEXT AS medicine_class_cd,
			  NULL AS dialyzer_cd,
				om.treat_date,
				kr.kur_cd,
				kr.kur_name,
				COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
				om.ind_bed_cd AS bed_cd,
				om.pat_id,
				COALESCE ( mdc.class_name, '''' ) AS kind,
				md.medicine_name AS NAME,
				CEIL (
					( ( CAST( medi ->> ''amount'' AS DECIMAL) ) / CASE WHEN md.unit_converted_amount_second IS NULL OR md.unit_converted_amount = 0 THEN 1 ELSE md.unit_converted_amount END ) /
				CASE

						WHEN md.unit_converted_amount_second IS NULL
						OR md.unit_converted_amount_second = 0 THEN
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
					4 AS disp_order,
					NULL AS equipment_cd,
					NULL AS equipment_class_cd,
					mdx.medicine_mix_cd :: TEXT AS medicine_cd,
					mdc.class_cd :: TEXT AS medicine_class_cd,
			    NULL AS dialyzer_cd,
					om.treat_date,
					kr.kur_cd,
					kr.kur_name,
					COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
					om.ind_bed_cd AS bed_cd,
					om.pat_id,
					COALESCE ( mdc.class_name, '''' ) AS kind,
					mdx.medicine_mix_name AS NAME,
					CAST( om.amount AS DECIMAL) AS Amount,
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
					CAST( om.amount AS DECIMAL) || COALESCE ( mdx.unit, '''' ) AS num_unit,
					NULL AS cond_va_dir,
					NULL AS cond_va,
					NULL AS equip_pnc_cls,
					''Medicine'' AS class_ename
				FROM
					ord_medi AS om
					LEFT OUTER JOIN (
					SELECT
						medicine_mix_cd,
						unit AS unit,
						class_cd,
						medicine_mix_name,
						in_hospital_cd_1,
						in_hospital_cd_2
					FROM
						mst_medicine_mix
					WHERE
						mst_medicine_mix.is_del = ''0''
						AND mst_medicine_mix.is_disp = ''1''
						AND mst_medicine_mix.class_cd IN ( @medIds )
					) mdx ON om.cd = mdx.medicine_mix_cd
					LEFT OUTER JOIN mst_medicine_class mdc ON mdx.class_cd = mdc.class_cd
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
					2 AS disp_order,
					eq.equipment_cd AS equipment_cd,
					eqc.class_cd AS equipment_class_cd,
					NULL AS medicine_cd,
					NULL AS medicine_class_cd,
			    NULL AS dialyzer_cd,
					om.treat_date,
					kr.kur_cd,
					kr.kur_name,
					COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
					om.ind_bed_cd AS bed_cd,
					om.pat_id,
					COALESCE ( eqc.class_name, '''' ) AS kind,
					eq.equipment_name AS NAME,
					( CAST( eqi ->> ''amount'' AS DECIMAL) ) AS Amount,
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
		medi_mix.medi_mix_order,
		equi.equi_order,
		bed.bed_order,
		medic.medic_order,
		equic.equic_order,
		medic_mix.medic_mix_order,
		dia.dia_order,
		MIN(rb1.room_bed_order) AS room_bed_group,
		MIN(rb2.room_bed_order) AS dialysis_room_group,
		NULL AS spitz_order
		FROM
			EquipmentList_Tmp AS bd
			LEFT OUTER JOIN medi ON medi.medi_code :: TEXT = bd.medicine_cd
			LEFT OUTER JOIN medic ON medic.medic_code :: TEXT = bd.medicine_class_cd
			LEFT OUTER JOIN equi ON equi.equi_code = bd.equipment_cd
			LEFT OUTER JOIN equic ON equic.equic_code = bd.equipment_class_cd
			LEFT OUTER JOIN bed ON bed.bed_code = bd.bed_cd
			LEFT OUTER JOIN dia ON dia.dia_code = bd.dialyzer_cd
      LEFT OUTER JOIN medi_mix ON medi_mix.medi_mix_code :: TEXT = bd.medicine_cd
			LEFT OUTER JOIN medic_mix ON medic_mix.medic_mix_code :: TEXT = bd.medicine_class_cd
			-- ベッドグループ
			LEFT OUTER JOIN mst_room_bed_group_1 AS rbg1 ON rbg1.bed_list :: jsonb @> ('''' || bd.bed_cd) :: jsonb
			LEFT OUTER JOIN room_bed AS rb1 ON rbg1.room_bed_group_cd = rb1.room_bed_code
			-- 透析室
			LEFT OUTER JOIN mst_room_bed_group_2 AS rbg2 ON rbg2.bed_list :: jsonb @> ('''' || bd.bed_cd) :: jsonb
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
			medi_mix.medi_mix_order,
			equi.equi_order,
			bed.bed_order,
			medic.medic_order,
			equic.equic_order,
			medic_mix.medic_mix_order,
			dia.dia_order
		ORDER BY
			disp_order,
			dia.dia_order NULLS LAST,
			medic.medic_order NULLS LAST ,
			equic.equic_order NULLS LAST ,
			medi.medi_order,
			medi_mix.medi_mix_order,
			equi.equi_order,
			bd.kur_cd NULLS LAST,
			bd.bed_cd NULLS LAST)
			UNION ALL--採血管
		(SELECT NULL AS
			treat_date,
			NULL AS equipment_cd,
			NULL AS equipment_class_cd,
			NULL AS medicine_cd,
			NULL AS medicine_class_cd,
			NULL AS kur_cd,
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
			5 AS disp_order,
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
			NULL AS medi_mix_order,
			NULL AS equi_order,
			NULL AS bed_order,
			NULL AS medic_order,
			NULL AS equic_order,
			NULL AS medic_mix_order,
			NULL AS dia_order,
		  NULL AS room_bed_order1,
		  NULL AS room_bed_order2,
			spi.spitz_order
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
			LEFT OUTER JOIN spi ON spi.spitz_code = spitz.spitz_cd
		WHERE
			spitz.spitz_name IS NOT NULL
		ORDER BY
		  spi.spitz_order)', 2, '[{"preview": "午後", "can_calc": "", "data_code": "kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "透析予定", "field_name": "kur_name", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": ""}, {"preview": "北1", "can_calc": "", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "透析予定", "field_name": "bed_name", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": ""}, {"preview": "70%ブドウ糖注射液350ml", "can_calc": "0", "data_code": "name", "data_name": "名称/採血管名", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "name", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/01/01", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "透析予定", "field_name": "treat_date", "disp_format": "yyyy/MM/dd", "data_category": "ラベル", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "disp_order", "data_name": "分類", "data_type": "Integer", "conv_table": [], "data_class": "", "field_name": "disp_order", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "class_name", "data_name": "分類/検査区分", "data_type": "String", "conv_table": [{"code": "0", "disp": "その他", "item": "その他"}, {"code": "1", "disp": "透析前", "item": "透析前"}, {"code": "2", "disp": "透析後", "item": "透析後"}], "data_class": "物品情報", "field_name": "class_name", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "plan_time", "data_name": "透析時間", "data_type": "String", "conv_table": [], "data_class": "物品情報", "field_name": "plan_time", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_dw", "data_name": "DW", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_dw", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_tg_wei", "data_name": "目標体重", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_tg_wei", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_tre_nm", "data_name": "治療項目", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_tre_nm", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_bld_fl", "data_name": "血流量", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_bld_fl", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "function_class", "data_name": "機能分類", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "function_class", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "area", "data_name": "面積", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "area", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "ufr", "data_name": "UFR", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "ufr", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "koa", "data_name": "KOA", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "koa", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "material", "data_name": "材質", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "material", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "wetdry", "data_name": "DRYWET", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "wetdry", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "anticoagulant_name", "data_name": "抗凝固剤", "data_type": "String", "conv_table": [], "data_class": "", "field_name": "anticoagulant_name", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "equip_circuit", "data_name": "血液回路", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "equip_circuit", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ac_shot", "data_name": "ワンショット量", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_ac_shot", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ac_spd", "data_name": "持続速度", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_ac_spd", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ac_dur_total", "data_name": "持続総量", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_ac_dur_total", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_use", "data_name": "IP使用選択", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_ip_use", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_start", "data_name": "IPスタート", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_start", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_spd", "data_name": "IP速度", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_spd", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_shot_st", "data_name": "自動ワンショット", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_shot_st", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_shot", "data_name": "IPワンショット量", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_shot", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_off", "data_name": "IP電源自動切り", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_off", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_off_tm", "data_name": "IP電源自動切り時間", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_off_tm", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_ok", "data_name": "IP電源OKモニタ切り", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_ok", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_ok_tm", "data_name": "IP電源OKモニタ切り時間", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_ok_tm", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_dl_fl", "data_name": "透析液流量", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_dl_fl", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_dl_am", "data_name": "透析液量", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_dl_am", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_dl_temp", "data_name": "透析温度", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_dl_temp", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_rl_am", "data_name": "補液量", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_rl_am", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_rl_sel", "data_name": "補液選択", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_rl_sel", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_rl_use", "data_name": "補液使用数", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_rl_use", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_rl_temp", "data_name": "補液温度", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_rl_temp", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_rl_spd", "data_name": "補液速度", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_rl_spd", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "medi_timing", "data_name": "投与時間帯", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "medi_timing", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "medi_proc", "data_name": "手技", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "medi_proc", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "1", "can_calc": "0", "data_code": "num_unit", "data_name": "数量・単位", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "num_unit", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_va_dir", "data_name": "VA方向", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_va_dir", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_va", "data_name": "VA", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_va", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "equip_pnc_cls", "data_name": "穿刺針区分", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "equip_pnc_cls", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_1", "data_name": "院内コード", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_1", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_2", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "ベッドグループ1", "can_calc": "", "data_code": "room_bed_group_name_1", "data_name": "ベッドグループ名", "data_type": "string", "conv_table": [], "data_class": "透析予定", "field_name": "room_bed_group_name_1", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": ""}, {"preview": "透析室名１", "can_calc": "", "data_code": "room_bed_group_name_2", "data_name": "透析室名", "data_type": "string", "conv_table": [], "data_class": "透析予定", "field_name": "room_bed_group_name_2", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": ""}, {"preview": "ラベル印字項目", "can_calc": "0", "data_code": "label_print", "data_name": "ラベル印字項目(採血管)", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "label_print", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": "0"}, {"preview": "院内・院外", "can_calc": "0", "data_code": "is_in_hospital", "data_name": "院内・院外(採血管)", "data_type": "string", "conv_table": [{"code": "0", "disp": "院内", "item": "院内"}, {"code": "1", "disp": "院外", "item": "院外"}], "data_class": "物品情報", "field_name": "is_in_hospital", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [8]}', 'ラベル', '2020-03-17 14:17:00', CURRENT_TIMESTAMP, NULL);
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
    , to_number(mni_monitor.monitor_data::json->>''78'', ''9999'') AS 残り時間_補液完了
--     , to_number(mni_monitor.monitor_data::json->>''1'', ''9999'') + to_number(mni_monitor.monitor_data::json->>''3'', ''9999'') AS 予測時間_除水
--     , to_number(mni_monitor.monitor_data::json->>''1'', ''9999'') + to_number(mni_monitor.monitor_data::json->>''4'', ''9999'') AS 予測時間_透析
    from d
    inner join mni_monitor on (d.bio_moni_ctl_no = mni_monitor.bio_moni_ctl_no)
--     where mni_monitor.data_type = 1
    where d.data_type = 1
), h as (select machine_no,b.ord_no,mst_bed.bed_cd from mst_bed INNER JOIN b on b.rst_bed_cd = mst_bed.bed_cd
), f AS (
    select e.*
--     to_number(mni_monitor.monitor_data::json->>''1'', ''9999'') AS 経過時間
--     , to_number(mni_monitor.monitor_data::json->>''3'', ''9999'') AS 残り時間_除水完了
--     , to_number(mni_monitor.monitor_data::json->>''4'', ''9999'') AS 残り時間_透析完了
		, COALESCE(e.経過時間,0) + COALESCE(e.残り時間_除水完了,0) AS 予測時間_除水
		, COALESCE(e.経過時間,0) + COALESCE(e.残り時間_透析完了,0) AS 予測時間_透析
		, COALESCE(e.経過時間,0) + COALESCE(e.残り時間_補液完了,0) AS 予測時間_補液 
    from e
--     inner join mni_monitor on (d.bio_moni_ctl_no = mni_monitor.bio_moni_ctl_no)
--     where mni_monitor.data_type = 1
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
),j as(
    select pat_event.pat_id, count(*) as 観察記録件数 
		from  pat_event INNER JOIN b on (pat_event.pat_id = b.pat_id) AND (pat_event.ord_no = b.ord_no)
		WHERE pat_event.ord_no > 0 AND pat_event.facility_cd <> ''null'' AND pat_event.use_type = 2 AND  pat_event.event_status = ''1'' AND pat_event.is_newest = ''1'' AND pat_event.is_del = ''0''
		GROUP BY pat_event.pat_id
)
,k as (select h.ord_no, machine_status as 警報・報知 , machine_serial from mnt_machine_state INNER JOIN h on mnt_machine_state.bed_cd = h.bed_cd)
,q as (
   select
	 e.ord_no,
	 to_number(mnt_machine_state.monitor_data::json->>''4'', ''9999'') AS 残り時間_透析完了
	 from e
	 inner join mnt_machine_state on
	 e.facility_cd = mnt_machine_state.facility_cd and
	 e.machine_type_cd = mnt_machine_state.machine_type_cd and
	 e.machine_serial = mnt_machine_state.machine_type_cd and
	 e.ord_no = mnt_machine_state.ord_no and
	 e.pat_id = mnt_machine_state.pat_id
)
,p as (select com_format_cd,com_type,h.ord_no from mst_machine INNER JOIN h on h.machine_no = mst_machine.machine_no)
,l as (select pat_ind_approve.ord_no, pat_ind_approve.is_content_changed_for_map as 指示変更 from pat_ind_approve INNER JOIN b on pat_ind_approve.ord_no = b.ord_no)
,m as (select a2.ord_no,concat(effect,''/'',effect_count) as 投与状況
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
((rst_weight_info->''recrcl_rt'') -> ''1'') -> ''rate''
 when (rst_weight_info->''recrcl_rt'') -> ''valid_no'' = ''2'' then
((rst_weight_info->''recrcl_rt'') -> ''2'') -> ''rate''
 when (rst_weight_info->''recrcl_rt'') -> ''valid_no'' = ''3'' then
((rst_weight_info->''recrcl_rt'') -> ''2'') -> ''rate''
 when (rst_weight_info->''recrcl_rt'') -> ''valid_no'' = ''4'' then
((rst_weight_info->''recrcl_rt'') -> ''2'') -> ''rate''
 when (rst_weight_info->''recrcl_rt'') -> ''valid_no'' = ''5'' then
((rst_weight_info->''recrcl_rt'') -> ''2'') -> ''rate''
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
select b.ord_no, b.treat_date
, b.pat_id AS pat_id
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
, b.rst_cond_info::json#>>''{3, value}'' AS 目標体重
, CASE WHEN b.rst_cond_info::json#>>''{3, value}'' is not null AND b.rst_cond_info::json#>>''{3, value}'' <> ''null'' THEN CAST(b.rst_weight_info::json->>''weight_before'' AS DECIMAL) - CAST(b.rst_cond_info::json#>>''{3, value}'' AS DECIMAL) 
  ELSE CAST(b.rst_weight_info::json->>''weight_before'' AS DECIMAL) - b.rst_dw 
  END AS 目標体重から
, b.rst_start_date
, CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN b.rst_dialysis_state > ''3'' THEN b.rst_end_date
       WHEN f.残り時間_除水完了 > f.残り時間_透析完了 AND f.残り時間_除水完了 > f.残り時間_補液完了 THEN b.rst_start_date + f.予測時間_除水 * interval ''1 minute''
			 WHEN f.残り時間_透析完了 > f.残り時間_補液完了 THEN b.rst_start_date + f.予測時間_透析 * interval ''1 minute''
       ELSE b.rst_start_date + f.予測時間_補液 * interval ''1 minute''
  END AS 終了予測
, CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN b.rst_dialysis_state > ''3'' THEN b.rst_end_date
       ELSE b.rst_start_date + f.予測時間_除水 * interval ''1 minute''
  END AS 終了予測_除水完了
, CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN b.rst_dialysis_state > ''3'' THEN b.rst_end_date
       ELSE b.rst_start_date + f.予測時間_透析 * interval ''1 minute''
  END AS 終了予測_透析完了
, b.rst_end_date
, b.rst_cond_info#>>''{1, value}'' AS 治療時間分
, b.rst_cond_info#>>''{1, value}'' AS 治療時間
, CASE WHEN b.rst_dialysis_state <> ''3'' THEN 0
       WHEN f.残り時間_除水完了 > f.残り時間_透析完了 AND f.残り時間_除水完了 > f.残り時間_補液完了 THEN f.予測時間_除水 - to_number(b.rst_cond_info#>>''{1, value}'', ''9999'')
			 WHEN f.残り時間_透析完了 > f.残り時間_補液完了 THEN f.予測時間_透析 - to_number(b.rst_cond_info#>>''{1, value}'', ''9999'')
       ELSE COALESCE(f.予測時間_補液,0) - to_number(b.rst_cond_info#>>''{1, value}'', ''9999'')
  END AS 遅れ時間
 ,CASE WHEN b.rst_dialysis_state < ''3'' THEN 0
       WHEN b.rst_cond_info::json#>>''{1, value}'' is null or b.rst_cond_info::json#>>''{1, value}'' = 0 THEN null
       WHEN (p.com_format_cd = ''F'' AND p.com_type = 0) AND to_char(b.rst_end_date, ''YYYY-MM-DD'') is null THEN FLOOR(cast((round(extract(epoch from now() - b.rst_start_date) / 60)*100 / CAST(b.rst_cond_info::json#>>''{1, value}'' AS DECIMAL)) as numeric))
			 WHEN (p.com_format_cd = ''F'' AND p.com_type = 0) AND to_char(b.rst_end_date, ''YYYY-MM-DD'') is not null THEN FLOOR(cast((round(extract(epoch from CAST(b.rst_end_date AS TIMESTAMP) - b.rst_start_date) / 60)*100 / CAST(b.rst_cond_info::json#>>''{1, value}'' AS DECIMAL)) as numeric))
			 WHEN d.data_type = 1 THEN FLOOR(((CAST(b.rst_cond_info::json#>>''{1, value}'' AS DECIMAL) - cast(q.残り時間_透析完了 as DECIMAL)) / CAST(b.rst_cond_info::json#>>''{1, value}'' AS DECIMAL))*100)
			 WHEN d.data_type <> 1 THEN FLOOR(((CAST(b.rst_cond_info::json#>>''{1, value}'' AS DECIMAL) - cast(e.残り時間_透析完了 as DECIMAL)) / CAST(b.rst_cond_info::json#>>''{1, value}'' AS DECIMAL))*100)  
			 END AS 進捗率 
, b.rst_weight_info::json->>''weight_before'' AS weight_before
, BpBefore.monitor_data->''90'' AS 前血圧_最高
, BpBefore.monitor_data->''91'' AS 前血圧_最低
, BpBefore.monitor_data->''92'' AS 前血圧_平均
, (BpBefore.monitor_data->>''90'') || ''/ '' || (BpBefore.monitor_data->>''91'') || ''/ '' || (BpBefore.monitor_data->>''92'') || '' ('' || (BpBefore.monitor_data->>''93'') || '')'' AS 前血圧
, BpBefore.monitor_data->''93'' AS 前脈拍
, (BpCurrent.monitor_data->>''90'') || ''/ '' || (BpCurrent.monitor_data->>''91'') || ''/ '' || (BpCurrent.monitor_data->>''92'') || '' ('' || (BpCurrent.monitor_data->>''93'') || '')'' AS 現在血圧
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
, BpAfter.monitor_data->''90'' AS 後血圧_最高
, BpAfter.monitor_data->''91'' AS 後血圧_最低
, BpAfter.monitor_data->''92'' AS 後血圧_平均
, (BpAfter.monitor_data->>''90'') || ''/ '' || (BpAfter.monitor_data->>''91'') || ''/ '' || (BpAfter.monitor_data->>''92'') || '' ('' || (BpAfter.monitor_data->>''93'') || '')'' AS 後血圧
, BpAfter.monitor_data->''93'' AS 後脈拍
, b.rst_weight_info->>''water_removal_target'' AS water_removal_target
, CASE WHEN b.rst_dialysis_state < ''2'' THEN null
       ELSE ''済''
  END AS 患者確認
, b.rst_weight_info->>''weight_before_date'' AS weight_before_date
, b.rst_start_date + to_number(b.rst_cond_info#>>''{1, value}'', ''9999'') * interval ''1 minute'' AS 終了予定
, CASE WHEN b.rst_rounds_info->''round_type_name'' IS NULL THEN ''未''
       ELSE ''済''
  END AS 回診状態
, CASE WHEN b.rst_rounds_info->''round_type_name'' IS NULL THEN ''未回診''
       ELSE b.rst_rounds_info->>''round_type_name''
  END AS 回診データ
, b.rst_weight_info->>''ctr'' AS ctr
, b.rst_cond_info#>>''{2, value_name_1}'' AS va
, b.rst_cond_info#>>''{4, value}'' AS 除水量制限
, (b.rst_cond_info#>>''{5, value_name_2}'') || ''['' || (b.rst_cond_info#>>''{5, value_name_1}'') || '']'' AS ダイアライザ
, b.rst_cond_info#>>''{6, value_name_1}'' AS 吸着カラム
, b.rst_cond_info#>>''{7, value_name_1}'' AS 一次膜
, b.rst_cond_info#>>''{8, value_name_1}'' AS 二次膜
, b.rst_cond_info#>>''{9, value_name_1}'' AS 穿刺針_a針
, b.rst_cond_info#>>''{10, value_name_1}'' AS 穿刺針_v針
, b.rst_cond_info#>>''{11, value_name_1}'' AS 穿刺針_sn
, CASE WHEN b.rst_cond_info#>>''{12, value}'' IS NULL THEN NULL
       WHEN b.rst_cond_info#>>''{12, value}'' = ''0'' THEN ''使用しない''
       ELSE ''使用する''
  END AS シングルニードル使用
, b.rst_cond_info#>>''{13, value_name_1}'' AS 血液回路
, b.rst_cond_info#>>''{14, value}'' AS 血流量
, b.rst_cond_info#>>''{15, value_name_1}'' AS 透析液
, b.rst_cond_info#>>''{16, value}'' AS 透析液流量
, b.rst_cond_info#>>''{17, value}'' AS 透析液量
, to_char(CAST(b.rst_cond_info#>>''{18, value}'' AS DECIMAL), ''FM999.0'') AS 透析液温度
, b.rst_cond_info#>>''{19, value_name_1}'' AS 補液
, b.rst_cond_info#>>''{20, value}'' AS 補液量
, CASE b.rst_cond_info#>>''{21, value}'' WHEN ''0'' THEN ''後補液''
                                       WHEN ''1'' THEN ''前補液''
                                       ELSE NULL
  END AS 補液選択
, b.rst_cond_info#>>''{22, value}'' AS 補液使用数
, to_char(CAST(b.rst_cond_info#>>''{23, value}'' AS DECIMAL), ''FM990.0'') AS 補液温度
, b.rst_cond_info#>>''{24, value}'' AS 補液速度
, b.rst_cond_info#>>''{25, value_name_1}'' AS 抗凝固剤
, b.rst_cond_info#>>''{26, value}'' AS 抗凝固剤ワンショット量
, b.rst_cond_info#>>''{27, value}'' AS 抗凝固剤持続速度
, b.rst_cond_info#>>''{28, value}'' AS 抗凝固剤持続総量
-- , CASE WHEN b.rst_cond_info#>>''{29, value}'' IS NULL THEN NULL
--        WHEN b.rst_cond_info#>>''{29, value}'' = ''0'' THEN ''使用しない''
--        ELSE ''使用する''
--   END AS ip使用選択
, b.rst_cond_info#>>''{29, value}'' AS ip使用選択
-- , null AS ipスタート
-- , CASE b.rst_cond_info#>>''{30, value}'' WHEN ''0'' THEN ''手動''
--                                        WHEN ''1'' THEN ''自動''
--                                        ELSE NULL
--   END AS ipスタート
, b.rst_cond_info#>>''{30, value}'' AS ipスタート
-- , to_char(to_number(b.rst_cond_info#>>''{31, value}'', ''999.99''), ''FM990.0'') AS ipワンショット量
-- , to_char(to_number(b.rst_cond_info#>>''{32, value}'', ''999.99''), ''FM990.0'') AS ip速度
-- , to_char(to_number(b.rst_cond_info#>>''{33, value}'', ''999.99''), ''FM990.0'') AS ip速度最大値
, CAST(b.rst_cond_info#>>''{31, value}'' AS DECIMAL) AS ipワンショット量
, CAST(b.rst_cond_info#>>''{32, value}'' AS DECIMAL) AS ip速度
, CAST(b.rst_cond_info#>>''{33, value}'' AS DECIMAL) AS ip速度最大値
-- , CASE WHEN b.rst_cond_info#>>''{34, value}'' IS NULL THEN NULL
--        WHEN b.rst_cond_info#>>''{34, value}'' = ''0'' THEN ''使用しない''
--        ELSE ''使用する''
--   END AS 自動ワンショット
, b.rst_cond_info#>>''{34, value}'' AS 自動ワンショット
-- , CASE b.rst_cond_info#>>''{35, value}'' WHEN ''0'' THEN ''切''
--                                        WHEN ''1'' THEN ''入''
--                                        ELSE NULL
--   END AS ip電源自動切り
, b.rst_cond_info#>>''{35, value}'' AS ip電源自動切り
, b.rst_cond_info#>>''{36, value}'' AS ip電源自動切り時間
-- , CASE b.rst_cond_info#>>''{37, value}'' WHEN ''0'' THEN ''切''
--                                        WHEN ''1'' THEN ''入''
--                                        ELSE NULL
--   END AS ip電源okモニタ切り
, b.rst_cond_info#>>''{37, value}'' AS ip電源okモニタ切り
, b.rst_cond_info#>>''{38, value}'' AS ip電源okモニタ切り時間
, f.monitor_data->''0'' AS m000
, f.monitor_data->''1'' AS m001
, f.monitor_data->''2'' AS m002
, f.monitor_data->''3'' AS m003
, f.monitor_data->''4'' AS m004
, f.monitor_data->''5'' AS m005
, f.monitor_data->''6'' AS m006
, f.monitor_data->''7'' AS m007
, f.monitor_data->''8'' AS m008
, f.monitor_data->''9'' AS m009
, f.monitor_data->''10'' AS m010
, f.monitor_data->''11'' AS m011
, f.monitor_data->''12'' AS m012
, f.monitor_data->''13'' AS m013
, f.monitor_data->''14'' AS m014
, f.monitor_data->''15'' AS m015
, f.monitor_data->''16'' AS m016
, f.monitor_data->''17'' AS m017
, f.monitor_data->''18'' AS m018
, f.monitor_data->''19'' AS m019
, f.monitor_data->''20'' AS m020
, f.monitor_data->''21'' AS m021
, f.monitor_data->''22'' AS m022
, f.monitor_data->''23'' AS m023
, f.monitor_data->''24'' AS m024
, f.monitor_data->''25'' AS m025
, f.monitor_data->''26'' AS m026
, f.monitor_data->''27'' AS m027
, f.monitor_data->''28'' AS m028
, f.monitor_data->''29'' AS m029
, f.monitor_data->''30'' AS m030
, f.monitor_data->''31'' AS m031
, f.monitor_data->''32'' AS m032
, f.monitor_data->''33'' AS m033
, f.monitor_data->''34'' AS m034
, f.monitor_data->''35'' AS m035
, f.monitor_data->''36'' AS m036
, f.monitor_data->''37'' AS m037
, f.monitor_data->''38'' AS m038
, f.monitor_data->''39'' AS m039
, f.monitor_data->''40'' AS m040
, f.monitor_data->''41'' AS m041
, f.monitor_data->''42'' AS m042
, f.monitor_data->''43'' AS m043
, f.monitor_data->''44'' AS m044
, f.monitor_data->''45'' AS m045
, f.monitor_data->''46'' AS m046
, f.monitor_data->''47'' AS m047
, f.monitor_data->''48'' AS m048
, f.monitor_data->''49'' AS m049
, f.monitor_data->''50'' AS m050
, f.monitor_data->''51'' AS m051
, f.monitor_data->''52'' AS m052
, f.monitor_data->''53'' AS m053
, f.monitor_data->''54'' AS m054
, f.monitor_data->''55'' AS m055
, f.monitor_data->''56'' AS m056
, f.monitor_data->''57'' AS m057
, f.monitor_data->''58'' AS m058
, f.monitor_data->''59'' AS m059
, f.monitor_data->''60'' AS m060
, f.monitor_data->''61'' AS m061
, f.monitor_data->''62'' AS m062
, f.monitor_data->''63'' AS m063
, f.monitor_data->''64'' AS m064
, f.monitor_data->''65'' AS m065
, f.monitor_data->''66'' AS m066
, f.monitor_data->''67'' AS m067
, f.monitor_data->''68'' AS m068
, f.monitor_data->''69'' AS m069
, f.monitor_data->''70'' AS m070
, f.monitor_data->''71'' AS m071
, f.monitor_data->''72'' AS m072
, f.monitor_data->''73'' AS m073
, f.monitor_data->''74'' AS m074
, f.monitor_data->''75'' AS m075
, f.monitor_data->''76'' AS m076
, f.monitor_data->''77'' AS m077
, f.monitor_data->''78'' AS m078
, f.monitor_data->''79'' AS m079
, f.monitor_data->''80'' AS m080
, f.monitor_data->''81'' AS m081
, f.monitor_data->''82'' AS m082
, f.monitor_data->''83'' AS m083
, f.monitor_data->''84'' AS m084
, f.monitor_data->''85'' AS m085
, f.monitor_data->''86'' AS m086
, f.monitor_data->''87'' AS m087
, f.monitor_data->''88'' AS m088
, f.monitor_data->''89'' AS m089
, f.monitor_data->''95'' AS m095
, f.monitor_data->''96'' AS m096
, f.monitor_data->''97'' AS m097
, f.monitor_data->''98'' AS m098
, f.monitor_data->''100'' AS m100
, f.monitor_data->''101'' AS m101
, f.monitor_data->''102'' AS m102
, f.monitor_data->''Z11'' AS mz11
, f.monitor_data->''Z21'' AS mz21
, f.monitor_data->''Z31'' AS mz31
, f.monitor_data->''Z41'' AS mz41
, f.monitor_data->''Z51'' AS mz51
, f.monitor_data->''Z61'' AS mz61
, f.monitor_data->''Z71'' AS mz71
, f.monitor_data->''Z81'' AS mz81
, f.monitor_data->''Z91'' AS mz91
, f.monitor_data->''Z101'' AS mz101
, f.monitor_data->''Z111'' AS mz111
, f.monitor_data->''Z121'' AS mz121
, f.monitor_data->''Z131'' AS mz131
, f.monitor_data->''Z141'' AS mz141
, f.monitor_data->''Z151'' AS mz151
, f.monitor_data->''Z161'' AS mz161
, f.monitor_data->''Z171'' AS mz171
, f.monitor_data->''Z181'' AS mz181
, f.monitor_data->''Z191'' AS mz191
, f.monitor_data->''Z201'' AS mz201
, f.monitor_data->''Z211'' AS mz211
, f.monitor_data->''Z221'' AS mz221
, f.monitor_data->''Z231'' AS mz231
, f.monitor_data->''Z241'' AS mz241
, f.monitor_data->''Z251'' AS mz251
, f.monitor_data->''Z261'' AS mz261
, f.monitor_data->''Z271'' AS mz271
, f.monitor_data->''Z281'' AS mz281
, f.monitor_data->''Z291'' AS mz291
, f.monitor_data->''Z301'' AS mz301
, f.monitor_data->''Z311'' AS mz311
, f.monitor_data->''Z321'' AS mz321
, f.monitor_data->''Z331'' AS mz331
, f.monitor_data->''Z341'' AS mz341
, f.monitor_data->''Z351'' AS mz351
, f.monitor_data->''Z361'' AS mz361
, f.monitor_data->''Z371'' AS mz371
, f.monitor_data->''Z381'' AS mz381
, f.monitor_data->''Z391'' AS mz391
, f.monitor_data->''Z401'' AS mz401
, f.monitor_data->''Z411'' AS mz411
, f.monitor_data->''Z421'' AS mz421
, f.monitor_data->''Z431'' AS mz431
, f.monitor_data->''Z441'' AS mz441
, f.monitor_data->''Z451'' AS mz451
, f.monitor_data->''Z12'' AS mz12
, f.monitor_data->''Z22'' AS mz22
, f.monitor_data->''Z32'' AS mz32
, f.monitor_data->''Z42'' AS mz42
, f.monitor_data->''Z52'' AS mz52
, f.monitor_data->''Z62'' AS mz62
, f.monitor_data->''Z72'' AS mz72
, f.monitor_data->''Z82'' AS mz82
, f.monitor_data->''Z92'' AS mz92
, f.monitor_data->''Z102'' AS mz102
, f.monitor_data->''Z112'' AS mz112
, f.monitor_data->''Z122'' AS mz122
, f.monitor_data->''Z132'' AS mz132
, f.monitor_data->''Z142'' AS mz142
, f.monitor_data->''Z152'' AS mz152
, f.monitor_data->''Z162'' AS mz162
, f.monitor_data->''Z172'' AS mz172
, f.monitor_data->''Z182'' AS mz182
, f.monitor_data->''Z192'' AS mz192
, f.monitor_data->''Z202'' AS mz202
, f.monitor_data->''Z212'' AS mz212
, f.monitor_data->''Z222'' AS mz222
, f.monitor_data->''Z232'' AS mz232
, f.monitor_data->''Z13'' AS mz13
, f.monitor_data->''Z23'' AS mz23
, f.monitor_data->''Z33'' AS mz33
, f.monitor_data->''Z43'' AS mz43
, f.monitor_data->''Z53'' AS mz53
, f.monitor_data->''Z63'' AS mz63
, f.monitor_data->''Z73'' AS mz73
, f.monitor_data->''Z83'' AS mz83
, f.monitor_data->''Z93'' AS mz93
, f.monitor_data->''Z103'' AS mZ103
, f.monitor_data->''Z113'' AS mZ113
, f.monitor_data->''Z123'' AS mZ123
, f.monitor_data->''Z133'' AS mZ133
, f.monitor_data->''Z143'' AS mZ143
, f.monitor_data->''Z153'' AS mZ153
, f.monitor_data->''Z163'' AS mZ163
, f.monitor_data->''Z173'' AS mZ173
, f.monitor_data->''Z183'' AS mZ183
, f.monitor_data->''Z193'' AS mZ193
, f.monitor_data->''Z203'' AS mZ203
, f.monitor_data->''Z213'' AS mZ213
, f.monitor_data->''Z223'' AS mZ223
, f.monitor_data->''Z233'' AS mZ233
, f.monitor_data->''Z243'' AS mZ243
, f.monitor_data->''Z253'' AS mZ253
, f.monitor_data->''Z263'' AS mZ263
, f.monitor_data->''Z14'' AS mz14
, f.monitor_data->''Z24'' AS mz24
, f.monitor_data->''Z34'' AS mz34
, f.monitor_data->''Z44'' AS mz44
, f.monitor_data->''Z54'' AS mz54
, f.monitor_data->''Z64'' AS mz64
, f.monitor_data->''Z74'' AS mz74
, f.monitor_data->''Z84'' AS mz84
, f.monitor_data->''Z94'' AS mz94
, f.monitor_data->''Z104'' AS mz104
, f.monitor_data->''Z114'' AS mz114
, f.monitor_data->''Z124'' AS mz124
, f.monitor_data->''Z134'' AS mz134
, f.monitor_data->''Z144'' AS mz144
, f.monitor_data->''Z154'' AS mz154
, f.monitor_data->''Z164'' AS mz164
, f.monitor_data->''Z174'' AS mz174
, f.monitor_data->''Z184'' AS mz184
, f.monitor_data->''Z194'' AS mz194
, f.monitor_data->''Z204'' AS mz204
, f.monitor_data->''Z214'' AS mz214
, f.monitor_data->''Z224'' AS mz224
, f.monitor_data->''Z234'' AS mz234
, f.monitor_data->''Z244'' AS mz244
, f.monitor_data->''Z254'' AS mz254
, f.monitor_data->''Z264'' AS mz264
, f.monitor_data->''Z274'' AS mz274
, f.monitor_data->''Z284'' AS mz284
, f.monitor_data->''Z294'' AS mz294
, f.monitor_data->''Z304'' AS mz304
, f.monitor_data->''Z314'' AS mz314
, f.monitor_data->''Z324'' AS mz324
, f.monitor_data->''Z334'' AS mz334
, f.monitor_data->''Z344'' AS mz344
, f.monitor_data->''Z354'' AS mz354
, f.monitor_data->''Z364'' AS mz364
, f.monitor_data->''Z374'' AS mz374
, BpBefore.*
, b.ord_no
, CAST(b.rst_weight_info ->> ''weight_after'' AS DECIMAL) - CAST(b.rst_cond_info::json#>>''{3, value}'' AS DECIMAL)  AS 引き残し
, b.pat_id AS hosp_pat_id
, b.rst_end_date as 治療終了
, CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN b.rst_dialysis_state > ''3'' THEN b.rst_end_date
       ELSE b.rst_start_date + f.予測時間_補液 * interval ''1 minute''
  END AS 終了予測補液完了
, b.rst_weight_info #>> ''{sttc_vns_prssr}'' AS 静的静脈圧
, b.rst_dw AS 前回後体重
, b.rst_weight_info ->> ''weight_before'' AS 前体重
, b.rst_weight_info #>> ''{ihdf_pll}'' AS IHDF引き残し量
, round((CAST(b.rst_off_water_info ->> ''weight_1'' AS DECIMAL)+CAST(b.rst_off_water_info ->> ''weight_2'' AS DECIMAL)+CAST(b.rst_off_water_info ->> ''weight_3'' AS DECIMAL)
+CAST(b.rst_off_water_info ->> ''weight_4'' AS DECIMAL)+CAST(b.rst_off_water_info ->> ''weight_5'' AS DECIMAL))/1000,2) AS 除水補正合計
, b.rst_weight_info #>> ''{iap_rt}'' AS IAPRatio
,f.monitor_data->''Z212'' AS 装置自己診断
,b.rst_bed_name AS ベッド名
, round((CAST(b.rst_tare_info -> ''before'' ->> ''weight_1'' AS DECIMAL)+CAST(b.rst_tare_info -> ''before'' ->> ''weight_2'' AS DECIMAL)+CAST(b.rst_tare_info -> ''before'' ->> ''weight_3'' AS DECIMAL)+CAST(b.rst_tare_info -> ''before'' ->> ''weight_4'' AS DECIMAL)+CAST(b.rst_tare_info -> ''before'' ->> ''weight_5'' AS DECIMAL))/1000,2) AS 前体重風袋合計
,  round((CAST(b.rst_tare_info -> ''after'' ->> ''weight_1'' AS DECIMAL)+CAST(b.rst_tare_info -> ''after'' ->> ''weight_2'' AS DECIMAL)+CAST(b.rst_tare_info -> ''after'' ->> ''weight_3'' AS DECIMAL)+CAST(b.rst_tare_info -> ''after'' ->> ''weight_4'' AS DECIMAL)+CAST(b.rst_tare_info -> ''after'' ->> ''weight_5'' AS DECIMAL))/1000,2 )AS 後体重風袋合計
, cast(b.rst_complaint_info->-1 ->> ''occur_date'' as timestamp (3)) || '' '' || COALESCE((b.rst_complaint_info->-1 ->> ''complaint''), '''') AS 最新愁訴
, o.treatment AS 最新処置
, COALESCE(b.rst_cond_info -> ''17'' ->> ''value'', ''0'')  as 透析液使用数
, (CAST(b.rst_weight_info ->> ''weight_before'' AS DECIMAL) - b.rst_dw) AS 前体重DW
,CAST(b.rst_weight_info ->> ''weight_before'' AS DECIMAL) - CAST(b.rst_cond_info::json#>>''{3, value}'' AS DECIMAL) AS 前体重目標体重
,(CAST(b.rst_weight_info ->> ''weight_before'' AS DECIMAL) - CAST(b.rst_weight_info ->> ''weight_after'' AS DECIMAL)) AS 前体重後体重
,CASE WHEN b.rst_dw is NULL OR b.rst_dw = 0 THEN 0 ELSE(CAST(b.rst_weight_info  ->> ''weight_before'' AS DECIMAL) - b.rst_dw)/ b.rst_dw*100 END AS 増加率
,(CAST(b.rst_weight_info  ->> ''weight_before'' AS DECIMAL) - b.rst_dw) as 増加量
,CASE WHEN CAST(b.rst_weight_info  ->> ''water_removal_target'' AS DECIMAL) > 0 THEN round( CAST(b.rst_weight_info  ->> ''water_removal_rst'' AS DECIMAL)/CAST(b.rst_weight_info  ->> ''water_removal_target'' AS DECIMAL),2)  ELSE 0 END as 達成率
,round( (CAST(b.rst_weight_info ->> ''weight_before'' AS DECIMAL)*1000 - CAST(b.rst_weight_info  ->> ''water_removal_target'' AS DECIMAL)*1000 -
 CAST(b.rst_cond_info::json#>>''{3, value}'' AS DECIMAL)*1000 + (CAST(b.rst_off_water_info ->> ''weight_1'' AS DECIMAL)+CAST(b.rst_off_water_info ->> ''weight_2'' AS DECIMAL)+CAST(b.rst_off_water_info ->> ''weight_3'' AS DECIMAL)
+CAST(b.rst_off_water_info ->> ''weight_4'' AS DECIMAL)+CAST(b.rst_off_water_info ->> ''weight_5'' AS DECIMAL)) )/1000,2) as 予想引き残し
,COALESCE(j.観察記録件数,0) as 観察記録件数
,k.警報・報知
,l.指示変更
,m.投与状況
,n.rate as 再循環率有効値
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
order by b.treat_date, b.ord_no, f.bio_moni_ctl_no', 2, '[{"preview": "2020/06/15", "can_calc": "0", "data_code": "treat_date", "data_name": "治療日", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "treat_date", "disp_format": "yyyy/MM/dd HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト患者", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_name", "target_var": "@patId"}, "data_code": "pat_name", "data_name": "患者名", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "pat_id", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "午後", "can_calc": "0", "data_code": "ind_kur_name", "data_name": "クール", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "ind_kur_name", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "運転", "can_calc": "0", "data_code": "process_state", "data_name": "状態", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "process_state", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "0", "data_code": "目標体重", "data_name": "目標体重", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "目標体重", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "0", "data_code": "目標体重から", "data_name": "目標体重から", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "目標体重から", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/06/15 11:24:00", "can_calc": "0", "data_code": "rst_start_date", "data_name": "治療開始", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "rst_start_date", "disp_format": "yyyy/MM/dd HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/06/15 11:24:00", "can_calc": "0", "data_code": "終了予測", "data_name": "終了予測", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "終了予測", "disp_format": "yyyy/MM/dd HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/06/15 11:24:00", "can_calc": "0", "data_code": "終了予測_除水完了", "data_name": "終了予測(除水完了)", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "終了予測_除水完了", "disp_format": "yyyy/MM/dd HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/06/15 11:24:00", "can_calc": "0", "data_code": "終了予測_透析完了", "data_name": "終了予測(透析完了)", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "終了予測_透析完了", "disp_format": "yyyy/MM/dd HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/06/15 11:24:00", "can_calc": "0", "data_code": "rst_end_date", "data_name": "rst_end_date", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "rst_end_date", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10:10", "can_calc": "0", "data_code": "治療時間", "data_name": "治療時間", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "治療時間", "disp_format": "HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "240", "can_calc": "0", "data_code": "治療時間分", "data_name": "治療時間(分)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "治療時間分", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "0", "data_code": "遅れ時間", "data_name": "遅れ時間", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "遅れ時間", "disp_format": "H:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "進捗率", "data_name": "進捗率", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "進捗率", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60.5", "can_calc": "0", "data_code": "weight_before", "data_name": "後体重", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "weight_before", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60.5", "can_calc": "0", "data_code": "前血圧_最高", "data_name": "前血圧(最高)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前血圧_最高", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60.5", "can_calc": "0", "data_code": "前血圧_最低", "data_name": "前血圧(最低)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前血圧_最低", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60.5", "can_calc": "0", "data_code": "前血圧_平均", "data_name": "前血圧(平均)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前血圧_平均", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "115/ 71/ 85 (80)", "can_calc": "0", "data_code": "前血圧", "data_name": "前血圧", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "前血圧", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "85", "can_calc": "0", "data_code": "前脈拍", "data_name": "前脈拍", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前脈拍", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "115/ 71/ 85 (80)", "can_calc": "0", "data_code": "現在血圧", "data_name": "現在血圧", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "現在血圧", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "charge_user_id_1", "data_name": "担当者1", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "charge_user_id_1", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "charge_date_1", "data_name": "担当1日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "charge_date_1", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "charge_user_id_2", "data_name": "担当者2", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "charge_user_id_2", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "charge_date_2", "data_name": "担当1日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "charge_date_2", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "puncture_date", "data_name": "穿刺日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "puncture_date", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "puncture_user_id_1", "data_name": "穿刺者1", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "puncture_user_id_1", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "puncture_date_1", "data_name": "穿刺1日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "puncture_date_1", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "puncture_user_id_2", "data_name": "穿刺者2", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "puncture_user_id_2", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "puncture_date_2", "data_name": "穿刺2日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "puncture_date_2", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "return_date", "data_name": "返血日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "return_date", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "return_user_id_1", "data_name": "返血者1", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "return_user_id_1", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "return_date_1", "data_name": "返血1日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "return_date_1", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "return_user_id_2", "data_name": "返血者2", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "return_user_id_2", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020-01-10T15:33:16.000+09:00", "can_calc": "0", "data_code": "return_date_2", "data_name": "返血2日時", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "return_date_2", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "85", "can_calc": "0", "data_code": "weight_after", "data_name": "後体重", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "weight_after", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60.5", "can_calc": "0", "data_code": "後血圧_最高", "data_name": "後血圧(最高)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "後血圧_最高", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60.5", "can_calc": "0", "data_code": "後血圧_最低", "data_name": "後血圧(最低)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "後血圧_最低", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60.5", "can_calc": "0", "data_code": "後血圧_平均", "data_name": "後血圧(平均)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "後血圧_平均", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "115/ 71/ 85 (80)", "can_calc": "0", "data_code": "後血圧", "data_name": "後血圧", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "後血圧", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "85", "can_calc": "0", "data_code": "後脈拍", "data_name": "後脈拍", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "後脈拍", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.5", "can_calc": "0", "data_code": "water_removal_target", "data_name": "除水目標", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "water_removal_target", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "済", "can_calc": "0", "data_code": "患者確認", "data_name": "患者確認", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "患者確認", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2019-03-25T09:20:30.000+09:00", "can_calc": "0", "data_code": "weight_before_date", "data_name": "前体重測定時刻", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "weight_before_date", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2019-12-10 01:56:01", "can_calc": "0", "data_code": "終了予定", "data_name": "終了予定", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "終了予定", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "済", "can_calc": "0", "data_code": "回診状態", "data_name": "回診状態", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "回診状態", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "未回診", "can_calc": "0", "data_code": "回診データ", "data_name": "回診データ", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "回診データ", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.2", "can_calc": "0", "data_code": "ctr", "data_name": "CTR", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "ctr", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "右", "can_calc": "0", "data_code": "va", "data_name": "VA", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "va", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.5", "can_calc": "0", "data_code": "除水量制限", "data_name": "除水量制限", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "除水量制限", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装[FDY-21GW]", "can_calc": "0", "data_code": "ダイアライザ", "data_name": "ダイアライザ", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "ダイアライザ", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト吸着カラム１", "can_calc": "0", "data_code": "吸着カラム", "data_name": "吸着カラム", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "吸着カラム", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト１次膜", "can_calc": "0", "data_code": "一次膜", "data_name": "1次膜", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "一次膜", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト２次膜", "can_calc": "0", "data_code": "二次膜", "data_name": "2次膜", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "二次膜", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト穿刺針１", "can_calc": "0", "data_code": "穿刺針_a針", "data_name": "穿刺針(A針)", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "穿刺針_a針", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト穿刺針２", "can_calc": "0", "data_code": "穿刺針_v針", "data_name": "穿刺針(V針)", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "穿刺針_v針", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針3", "can_calc": "0", "data_code": "穿刺針_sn", "data_name": "穿刺針(SN)", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "穿刺針_sn", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "シングルニードル使用", "data_name": "シングルニードル使用", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "シングルニードル使用", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト血液回路１", "can_calc": "0", "data_code": "血液回路", "data_name": "血液回路", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "血液回路", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "210", "can_calc": "0", "data_code": "血流量", "data_name": "血流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "血流量", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト透析液１", "can_calc": "0", "data_code": "透析液", "data_name": "透析液", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "透析液", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "透析液流量", "data_name": "透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "透析液流量", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "349", "can_calc": "0", "data_code": "透析液量", "data_name": "透析液量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "透析液量", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "35.0", "can_calc": "0", "data_code": "透析液温度", "data_name": "透析液温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "透析液温度", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト補液１", "can_calc": "0", "data_code": "補液", "data_name": "補液", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "補液", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "補液量", "data_name": "補液量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "補液量", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "前補液", "can_calc": "0", "data_code": "補液選択", "data_name": "補液選択", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "補液選択", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "補液使用数", "data_name": "補液使用数", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "補液使用数", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "37.9", "can_calc": "0", "data_code": "補液温度", "data_name": "補液温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "補液温度", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.5", "can_calc": "0", "data_code": "補液速度", "data_name": "補液速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "補液速度", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト抗凝固剤１", "can_calc": "0", "data_code": "抗凝固剤", "data_name": "抗凝固剤", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "抗凝固剤", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3", "can_calc": "0", "data_code": "抗凝固剤ワンショット量", "data_name": "抗凝固剤ワンショット量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "抗凝固剤ワンショット量", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3", "can_calc": "0", "data_code": "抗凝固剤持続速度", "data_name": "抗凝固剤持続速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "抗凝固剤持続速度", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "ip使用選択", "data_name": "ip使用選択", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "治療状況", "field_name": "ip使用選択", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "自動", "can_calc": "0", "data_code": "ipスタート", "data_name": "ipスタート", "data_type": "string", "conv_table": [{"code": "0", "disp": "手動", "item": "手動"}, {"code": "1", "disp": "自動", "item": "自動"}], "data_class": "治療状況", "field_name": "ipスタート", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "33.0", "can_calc": "0", "data_code": "ipワンショット量", "data_name": "ipワンショット量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "ipワンショット量", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13.2", "can_calc": "0", "data_code": "ip速度", "data_name": "ip速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "ip速度", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13.2", "can_calc": "0", "data_code": "ip速度最大値", "data_name": "ip速度最大値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "ip速度最大値", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "使用する", "can_calc": "0", "data_code": "自動ワンショット", "data_name": "自動ワンショット", "data_type": "string", "conv_table": [{"code": "0", "disp": "使用しない", "item": "使用しない"}, {"code": "1", "disp": "使用する", "item": "使用する"}], "data_class": "治療状況", "field_name": "自動ワンショット", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "入", "can_calc": "0", "data_code": "ip電源自動切り", "data_name": "ip電源自動切り", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "治療状況", "field_name": "ip電源自動切り", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "入", "can_calc": "0", "data_code": "ip電源okモニタ切り", "data_name": "ip電源okモニタ切り", "data_type": "string", "conv_table": [{"code": "0", "disp": "切", "item": "切"}, {"code": "1", "disp": "入", "item": "入"}], "data_class": "治療状況", "field_name": "ip電源okモニタ切り", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "ip電源okモニタ切り時間", "data_name": "ip電源okモニタ切り時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "ip電源okモニタ切り時間", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "9", "can_calc": "0", "data_code": "m000", "data_name": "工程", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m000", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "m001", "data_name": "経過時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m001", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "200", "can_calc": "0", "data_code": "m002", "data_name": "経過時間(ECUM)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m002", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "210", "can_calc": "0", "data_code": "m003", "data_name": "残り時間(除水完了)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m003", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "240", "can_calc": "0", "data_code": "m004", "data_name": "残り時間(透析完了)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m004", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "m005", "data_name": "除水積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m005", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.55", "can_calc": "0", "data_code": "m006", "data_name": "除水速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m006", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "3.0", "can_calc": "0", "data_code": "m007", "data_name": "血液循環量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m007", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.0", "can_calc": "0", "data_code": "m009", "data_name": "IP総量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m009", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.0", "can_calc": "0", "data_code": "m010", "data_name": "IP速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m010", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "0", "data_code": "m011", "data_name": "静脈圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m011", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "8", "can_calc": "0", "data_code": "m012", "data_name": "透析液圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m012", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "9", "can_calc": "0", "data_code": "m013", "data_name": "TMP", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m013", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "m014", "data_name": "ダイアライザー入口圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m014", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "11", "can_calc": "0", "data_code": "m015", "data_name": "ダイアライザー差圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m015", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12", "can_calc": "0", "data_code": "m016", "data_name": "血液入口～静脈平均圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m016", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13.0", "can_calc": "0", "data_code": "m017", "data_name": "⊿BV", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m017", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.40", "can_calc": "0", "data_code": "m018", "data_name": "バイカーボ濃度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m018", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "15.0", "can_calc": "0", "data_code": "m019", "data_name": "透析液濃度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m019", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "16", "can_calc": "0", "data_code": "m020", "data_name": "Na濃度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m020", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "37.0", "can_calc": "0", "data_code": "m021", "data_name": "透析液温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m021", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "18", "can_calc": "0", "data_code": "m022", "data_name": "透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m022", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.9", "can_calc": "0", "data_code": "m023", "data_name": "漏血量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m023", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "0", "data_code": "m024", "data_name": "給液圧(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m024", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "0", "data_code": "m025", "data_name": "給液圧(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m025", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "22.00", "can_calc": "0", "data_code": "m026", "data_name": "UFR", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m026", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "23", "can_calc": "0", "data_code": "m027", "data_name": "UFR低下率", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m027", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "24.00", "can_calc": "0", "data_code": "m028", "data_name": "初期UFR測定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m028", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "25.0", "can_calc": "0", "data_code": "m029", "data_name": "TMP補正値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m029", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "26", "can_calc": "0", "data_code": "m030", "data_name": "透析運転時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m030", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "0", "data_code": "m031", "data_name": "治療モード", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m031", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "28.00", "can_calc": "0", "data_code": "m032", "data_name": "除水目標値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m032", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.00", "can_calc": "0", "data_code": "m033", "data_name": "除水速度設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m033", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "33.0", "can_calc": "0", "data_code": "m034", "data_name": "透析液温度設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m034", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "31", "can_calc": "0", "data_code": "m035", "data_name": "透析液流量設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m035", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "32", "can_calc": "0", "data_code": "m036", "data_name": "血流量設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m036", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "33.0", "can_calc": "0", "data_code": "m037", "data_name": "IP速度設定", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m037", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.34", "can_calc": "0", "data_code": "m038", "data_name": "Kt/V測定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m038", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "35", "can_calc": "0", "data_code": "m039", "data_name": "静脈圧警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m039", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36", "can_calc": "0", "data_code": "m040", "data_name": "静脈圧警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m040", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "37", "can_calc": "0", "data_code": "m041", "data_name": "透析液圧警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m041", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "38", "can_calc": "0", "data_code": "m042", "data_name": "透析液圧警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m042", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "39", "can_calc": "0", "data_code": "m043", "data_name": "TMP警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m043", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "40", "can_calc": "0", "data_code": "m044", "data_name": "TMP警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m044", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "40", "can_calc": "0", "data_code": "m045", "data_name": "ダイアライザー入口圧警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m045", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "42", "can_calc": "0", "data_code": "m046", "data_name": "ダイアライザー入口圧警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m046", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "43", "can_calc": "0", "data_code": "m047", "data_name": "ダイアライザー差圧警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m047", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "44", "can_calc": "0", "data_code": "m048", "data_name": "ダイアライザー差圧警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m048", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-45.0", "can_calc": "0", "data_code": "m049", "data_name": "⊿BV低下警報点１", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m049", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-46.0", "can_calc": "0", "data_code": "m050", "data_name": "⊿BV低下警報点２", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m050", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-17.0", "can_calc": "0", "data_code": "m051", "data_name": "⊿BV変化率警報点", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m051", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "48", "can_calc": "0", "data_code": "m052", "data_name": "BPM関連データ9", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m052", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-49", "can_calc": "0", "data_code": "m053", "data_name": "BPM関連データ10", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m053", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.00", "can_calc": "0", "data_code": "m054", "data_name": "バイカーボ濃度警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m054", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.10", "can_calc": "0", "data_code": "m055", "data_name": "バイカーボ濃度警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m055", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.2", "can_calc": "0", "data_code": "m056", "data_name": "透析液濃度警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m056", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "53.0", "can_calc": "0", "data_code": "m057", "data_name": "透析液濃度警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m057", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "54", "can_calc": "0", "data_code": "m058", "data_name": "Na濃度警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m058", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55", "can_calc": "0", "data_code": "m059", "data_name": "Na濃度警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m059", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "56.0", "can_calc": "0", "data_code": "m060", "data_name": "透析液温度警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m060", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "57.0", "can_calc": "0", "data_code": "m061", "data_name": "透析液温度警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m061", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "5.8", "can_calc": "0", "data_code": "m062", "data_name": "漏血量警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m062", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "59", "can_calc": "0", "data_code": "m063", "data_name": "給水圧警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m063", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "60", "can_calc": "0", "data_code": "m064", "data_name": "給水圧警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m064", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.10", "can_calc": "0", "data_code": "m065", "data_name": "初期UFR警報点(上限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m065", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "62.00", "can_calc": "0", "data_code": "m066", "data_name": "初期UFR警報点(下限)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m066", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "63", "can_calc": "0", "data_code": "m067", "data_name": "UFR低下率警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m067", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.60", "can_calc": "0", "data_code": "m068", "data_name": "Kt/V", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m068", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.50", "can_calc": "0", "data_code": "m069", "data_name": "運転中の血流量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m069", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.5", "can_calc": "0", "data_code": "m070", "data_name": "補液量設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m070", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.68", "can_calc": "0", "data_code": "m071", "data_name": "補液速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m071", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "69.00", "can_calc": "0", "data_code": "m072", "data_name": "補液量現在値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m072", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.70", "can_calc": "0", "data_code": "m073", "data_name": "補液速度設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m073", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.7", "can_calc": "0", "data_code": "m074", "data_name": "補液温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m074", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30.0", "can_calc": "0", "data_code": "m075", "data_name": "補液温度設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m075", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7.30", "can_calc": "0", "data_code": "m076", "data_name": "濾液速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m076", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "74.00", "can_calc": "0", "data_code": "m077", "data_name": "荷重計", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m077", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "m078", "data_name": "残り時間(補液完了)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m078", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50.0", "can_calc": "0", "data_code": "m079", "data_name": "URR", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m079", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "77.0", "can_calc": "0", "data_code": "m080", "data_name": "⊿BV変化率", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m080", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "78.00", "can_calc": "0", "data_code": "m081", "data_name": "PWI", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m081", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "79", "can_calc": "0", "data_code": "m082", "data_name": "BPM関連データ1", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m082", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "180", "can_calc": "0", "data_code": "m083", "data_name": "BPM関連データ2", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m083", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "39", "can_calc": "0", "data_code": "m084", "data_name": "BPM関連データ3", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m084", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "82.0", "can_calc": "0", "data_code": "m085", "data_name": "⊿BVリファレンスエリア上限", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m085", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "83.0", "can_calc": "0", "data_code": "m086", "data_name": "⊿BVリファレンスエリア下限", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m086", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "84", "can_calc": "0", "data_code": "m087", "data_name": "BPM関連データ6", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m087", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4.00", "can_calc": "0", "data_code": "m088", "data_name": "PRR", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m088", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "m089", "data_name": "再循環率測定結果(BVMS連携用)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m089", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "0", "data_code": "m095", "data_name": "⊿BV5分平均値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m095", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.0", "can_calc": "0", "data_code": "m096", "data_name": "⊿BV最大最小を除いた5分平均値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m096", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "30", "can_calc": "0", "data_code": "m097", "data_name": "推定血流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m097", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50.0", "can_calc": "0", "data_code": "m098", "data_name": "血流量不足率", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m098", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "m100", "data_name": "⊿BV(BVplus)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m100", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "m101", "data_name": "Ht", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m101", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "m102", "data_name": "LDQb", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "m102", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz11", "data_name": "[ACHΣ]治療モード", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz11", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz21", "data_name": "[ACHΣ]工程状態", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz21", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz31", "data_name": "[ACHΣ]除水速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz31", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz41", "data_name": "[ACHΣ]血液流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz41", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz51", "data_name": "[ACHΣ]シリンジ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz51", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz61", "data_name": "[ACHΣ]ろ過流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz61", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz71", "data_name": "[ACHΣ]透析液/ドレン流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz71", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz81", "data_name": "[ACHΣ]補液流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz81", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz91", "data_name": "[ACHΣ]透析液加温器温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz91", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz101", "data_name": "[ACHΣ]補液加温器温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz101", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz111", "data_name": "[ACHΣ]現在除水量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz111", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz121", "data_name": "[ACHΣ]現在血液循環量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz121", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz131", "data_name": "[ACHΣ]現在ろ過量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz131", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz141", "data_name": "[ACHΣ]現在透析液/ドレン量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz141", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz151", "data_name": "[ACHΣ]現在補液量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz151", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz161", "data_name": "[ACHΣ]治療時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz161", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz171", "data_name": "[ACHΣ]シリンジ積算量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz171", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz181", "data_name": "[ACHΣ]目標除水量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz181", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz191", "data_name": "[ACHΣ]目標血液循環量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz191", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz201", "data_name": "[ACHΣ]目標ろ過量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz201", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz211", "data_name": "[ACHΣ]目標透析液/ドレン量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz211", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz221", "data_name": "[ACHΣ]目標補液量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz221", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz231", "data_name": "[ACHΣ]目標治療時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz231", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz241", "data_name": "[ACHΣ]脱血圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz241", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz251", "data_name": "[ACHΣ]入口圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz251", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz261", "data_name": "[ACHΣ]静脈圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz261", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz271", "data_name": "[ACHΣ]ろ過圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz271", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz281", "data_name": "[ACHΣ]排気圧/2次膜圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz281", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz291", "data_name": "[ACHΣ]TMP/TMP1", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz291", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz301", "data_name": "[ACHΣ]TMP2", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz301", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz311", "data_name": "[ACHΣ]差圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz311", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz321", "data_name": "[ACHΣ]気泡検知警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz321", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz331", "data_name": "[ACHΣ]漏血警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz331", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz341", "data_name": "[ACHΣ]加温器警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz341", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz351", "data_name": "[ACHΣ]脱血圧警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz351", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz361", "data_name": "[ACHΣ]入口圧警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz361", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz371", "data_name": "[ACHΣ]静脈圧警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz371", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz381", "data_name": "[ACHΣ]ろ過圧警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz381", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz391", "data_name": "[ACHΣ]排気圧/2次膜圧警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz391", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz401", "data_name": "[ACHΣ]TMP警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz401", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz411", "data_name": "[ACHΣ]TMP2警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz411", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz421", "data_name": "[ACHΣ]差圧警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz421", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz431", "data_name": "[ACHΣ]その他警報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz431", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz441", "data_name": "[ACHΣ]クエン酸流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz441", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz451", "data_name": "[ACHΣ]現在クエン酸量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz451", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz12", "data_name": "[KM8900]測定値TMP", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz12", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz22", "data_name": "[KM8900]測定値入口圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz22", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz32", "data_name": "[KM8900]測定値返血圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz32", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz42", "data_name": "[KM8900]測定値2次膜圧(吸着圧)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz42", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz52", "data_name": "[KM8900]圧力上限警報設定値TMP", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz52", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz62", "data_name": "[KM8900]圧力上限警報設定値入口圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz62", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz72", "data_name": "[KM8900]圧力上限警報設定値返血圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz72", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz82", "data_name": "[KM8900]圧力上限警報設定値2次膜圧(吸着圧)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz82", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz92", "data_name": "[KM8900]流量情報BP瞬時流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz92", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz102", "data_name": "[KM8900]流量情報PP瞬時流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz102", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz112", "data_name": "[KM8900]流量情報DP瞬時流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz112", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz122", "data_name": "[KM8900]流量情報BP積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz122", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz132", "data_name": "[KM8900]流量情報PP積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz132", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz142", "data_name": "[KM8900]流量情報DP積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz142", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz152", "data_name": "[KM8900]流量情報除水積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz152", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz162", "data_name": "[KM8900]流量情報血漿処理目標値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz162", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz172", "data_name": "[KM8900]その他情報加温器温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz172", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz182", "data_name": "[KM8900]その他情報バランス", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz182", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz192", "data_name": "[KM8900]経過時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz192", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz202", "data_name": "[KM8900]その他情報アラーム番号", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz202", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz212", "data_name": "[KM8900]その他情報自己診断番号", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz212", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz222", "data_name": "[KM8900]その他情報モード(用途)", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz222", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz232", "data_name": "[KM8900]その他情報工程情報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz232", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz13", "data_name": "[iQ21]治療経過時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz13", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz23", "data_name": "[iQ21]除水速度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz23", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz33", "data_name": "[iQ21]ろ過ポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz33", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz43", "data_name": "[iQ21]補液ポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz43", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz53", "data_name": "[iQ21]透析液ポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz53", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz63", "data_name": "[iQ21]血液ポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz63", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz73", "data_name": "[iQ21]シリンジポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz73", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz83", "data_name": "[iQ21]除水量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz83", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz93", "data_name": "[iQ21]ろ過量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz93", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz103", "data_name": "[iQ21]補液量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz103", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz113", "data_name": "[iQ21]透析液量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz113", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz123", "data_name": "[iQ21]血液循環量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz123", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz133", "data_name": "[iQ21]シリンジポンプ積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz133", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz143", "data_name": "[iQ21]採血圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz143", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz153", "data_name": "[iQ21]動脈圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz153", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz163", "data_name": "[iQ21]静脈圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz163", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz173", "data_name": "[iQ21]ろ過圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz173", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz183", "data_name": "[iQ21]TMP", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz183", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz193", "data_name": "[iQ21]分離ポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz193", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz203", "data_name": "[iQ21]返漿ポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz203", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz213", "data_name": "[iQ21]ドレンポンプ流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz213", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz223", "data_name": "[iQ21]分離量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz223", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz233", "data_name": "[iQ21]返漿量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz233", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz243", "data_name": "[iQ21]ドレン量積算値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz243", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz253", "data_name": "[iQ21]血漿圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz253", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz263", "data_name": "[iQ21]血漿入口圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz263", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz14", "data_name": "[KM9000]測定値TMP圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz14", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz24", "data_name": "[KM9000]測定値入口圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz24", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz34", "data_name": "[KM9000]測定値返血圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz34", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz44", "data_name": "[KM9000]測定値ろ過圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz44", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz54", "data_name": "[KM9000]測定値浄化器圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz54", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz64", "data_name": "[KM9000]設定値TMP圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz64", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz74", "data_name": "[KM9000]設定値入口圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz74", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz84", "data_name": "[KM9000]設定値返血圧・上限", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz84", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz94", "data_name": "[KM9000]設定値返血圧・下限", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz94", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz104", "data_name": "[KM9000]設定値浄化器圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz104", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz114", "data_name": "[KM9000]設定値除水設定値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz114", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz124", "data_name": "[KM9000]流量情報血液ﾎﾟﾝﾌﾟ指令流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz124", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz134", "data_name": "[KM9000]流量情報透析液ﾎﾟﾝﾌﾟ指令流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz134", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz144", "data_name": "[KM9000]流量情報補充液ﾎﾟﾝﾌﾟ指令流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz144", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz154", "data_name": "[KM9000]流量情報ろ液ﾎﾟﾝﾌﾟ指令流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz154", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz164", "data_name": "[KM9000]流量情報血液ﾎﾟﾝﾌﾟ積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz164", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz174", "data_name": "[KM9000]流量情報透析液ﾎﾟﾝﾌﾟ積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz174", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz184", "data_name": "[KM9000]流量情報補充液ﾎﾟﾝﾌﾟ積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz184", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz194", "data_name": "[KM9000]流量情報除水積算流量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz194", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz204", "data_name": "[KM9000]その他情報加温器温度", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz204", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz214", "data_name": "[KM9000]その他情報除水差分/重量値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz214", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz224", "data_name": "[KM9000]その他情報初期診断情報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz224", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz234", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報1", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz234", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz244", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報2", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz244", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz254", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報3", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz254", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz264", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報4", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz264", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz274", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報5", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz274", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz284", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報6", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz284", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz294", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報7", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz294", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz304", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報8", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz304", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz314", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報9", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz314", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz324", "data_name": "[KM9000]その他情報ｱﾗｰﾑ情報10", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz324", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz334", "data_name": "[KM9000]その他情報注意情報", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz334", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz344", "data_name": "[KM9000]経過時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz344", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz354", "data_name": "[KM9000]その他情報用途", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz354", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz364", "data_name": "[KM9000]その他情報工程", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz364", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mz374", "data_name": "[KM9000]その他情報動作日、時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "mz374", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "0", "data_code": "dw", "data_name": "DW", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "dw", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.00", "can_calc": "0", "data_code": "iapratio", "data_name": "IAP Ratio", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "iapratio", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.10", "can_calc": "0", "data_code": "ihdf引き残し量", "data_name": "I-HDF引き残し量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "ihdf引き残し量", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "ip電源自動切り時間", "data_name": "IP電源自動切り時間", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "ip電源自動切り時間", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "引き残し", "data_name": "引き残し", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "引き残し", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト患者", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "hosp_pat_id", "target_var": "@patId"}, "data_code": "hosp_pat_id", "data_name": "患者ID", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "hosp_pat_id", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "観察記録件数", "data_name": "観察記録件数", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "観察記録件数", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "警報・報知", "data_name": "警報・報知", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "警報・報知", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "後体重風袋合計", "data_name": "後体重風袋合計", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "後体重風袋合計", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2000", "can_calc": "0", "data_code": "抗凝固剤持続総量", "data_name": "抗凝固剤持続総量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "抗凝固剤持続総量", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "25", "can_calc": "0", "data_code": "再循環率有効値", "data_name": "再循環率有効値", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "再循環率有効値", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト愁訴", "can_calc": "0", "data_code": "最新愁訴", "data_name": "最新愁訴", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "最新愁訴", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト処置", "can_calc": "0", "data_code": "最新処置", "data_name": "最新処置", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "最新処置", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "はい", "can_calc": "0", "data_code": "指示変更", "data_name": "指示変更", "data_type": "string", "conv_table": [{"code": 0, "disp": "変更なし", "item": "変更なし"}, {"code": 1, "disp": "変更あり", "item": "変更あり"}], "data_class": "治療状況", "field_name": "指示変更", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/06/15 11:24:00", "can_calc": "0", "data_code": "治療終了", "data_name": "治療終了", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "治療終了", "disp_format": "yyyy/MM/dd HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/06/15 11:24:00", "can_calc": "0", "data_code": "終了予測補液完了", "data_name": "終了予測(補液完了)", "data_type": "DateTime", "conv_table": [], "data_class": "治療状況", "field_name": "終了予測補液完了", "disp_format": "yyyy/MM/dd HH:mm", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "除水補正合計", "data_name": "除水補正合計", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "除水補正合計", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.00", "can_calc": "0", "data_code": "静的静脈圧", "data_name": "静的静脈圧", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "静的静脈圧", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "前回後体重", "data_name": "前回後体重", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前回後体重", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "57.90", "can_calc": "0", "data_code": "前体重", "data_name": "前体重", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前体重", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "0", "data_code": "前体重dw", "data_name": "前体重DW", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前体重dw", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "55.00", "can_calc": "0", "data_code": "前体重目標体重", "data_name": "前体重 - 目標体重", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前体重目標体重", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "前体重後体重", "data_name": "前体重-後体重", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前体重後体重", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "前体重風袋合計", "data_name": "前体重風袋合計", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "前体重風袋合計", "disp_format": "0", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "装置自己診断", "data_name": "装置自己診断", "data_type": "string", "conv_table": [{"code": 0, "disp": "未実施", "item": "未実施"}, {"code": 1, "disp": "已実施", "item": "已実施"}], "data_class": "治療状況", "field_name": "装置自己診断", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "増加率", "data_name": "増加率", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "増加率", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "増加量", "data_name": "増加量", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "増加量", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "達成率", "data_name": "達成率", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "達成率", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0/0", "can_calc": "0", "data_code": "投与状況", "data_name": "投与状況", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "投与状況", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4", "can_calc": "0", "data_code": "透析液使用数", "data_name": "透析液使用数", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "透析液使用数", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "予想引き残し", "data_name": "予想引き残し", "data_type": "decimal", "conv_table": [], "data_class": "治療状況", "field_name": "予想引き残し", "disp_format": "0.00", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "BED-01", "can_calc": "0", "data_code": "ベッド名", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "治療状況", "field_name": "ベッド名", "disp_format": "", "data_category": "治療状況リスト", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [3]}', '治療状況リスト', '2020-04-25 00:00:00', CURRENT_TIMESTAMP, NULL);
