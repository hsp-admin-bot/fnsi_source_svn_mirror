delete from ntss.sys_data_set where sql_cd = '9';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9, 'WITH dz AS (
	SELECT
		*
	FROM
		mst_dialyzer
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND is_del = ''0''
		AND is_disp = ''1''
	),
	kr AS (
	SELECT
		*
	FROM
		mst_kur
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND is_del = ''0''
	),
	eq AS (
	SELECT
		*
	FROM
		mst_equipment
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND is_del = ''0''
		AND is_disp = ''1''
	),
	eqc AS (
	SELECT
		*
	FROM
		mst_equipment_class
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND is_del = ''0''
		AND is_disp = ''1''
	),
	md AS (
	SELECT
		*
	FROM
		mst_medicine
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND is_del = ''0''
		AND is_disp = ''1''
	),
	mdc AS (
	SELECT
		*
	FROM
		mst_medicine_class
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND is_del = ''0''
		AND is_disp = ''1''
	),
	dmcc AS (
	SELECT
		index_no AS code_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_class_code,
		order_cd ->> ''name'' AS medi_class_code_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND master_physical_name = ''mst_medicine_class''
	),
	meqc AS (
	SELECT
		index_no AS code_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS meq_class_code,
		order_cd ->> ''name'' AS meq_class_code_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND master_physical_name = ''mst_equipment_class''
	),
	dmccc AS (
	SELECT
		index_no AS medi_code_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_code,
		order_cd ->> ''name'' AS medi_code_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND master_physical_name = ''mst_medicine''
	),
	meqcc AS (
	SELECT
		index_no AS meq_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS meq_code,
		order_cd ->> ''name'' AS meq_code_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_main om WHERE om.ord_no IN ( @ordNos ) LIMIT 1 )
		AND master_physical_name = ''mst_equipment''
	) SELECT
	disp_order,
	to_timestamp( treat_date, ''YYYYMMDD'' ) AS treat_date,
	kind,
	NAME,
	SUM ( Amount ) AS amount,
	unit,
	in_hospital_cd_1,
	in_hospital_cd_2,
	in_hospital_cd_3,
	in_hospital_cd_4,
	class_cd,
	cd,
	pk_order,
	do_action
FROM
	(
	SELECT
		om.ord_no AS ord_no,
		1 AS disp_order,
		om.treat_date,
		''ダイアライザ'' AS kind,
		dz.model_number AS NAME,
		1 AS Amount,
		COALESCE ( om.ind_cond_info :: json #>> ''{5,unit}'', '''' ) AS Unit,
		dz.in_hospital_cd_1,
		dz.in_hospital_cd_2,
		dz.in_hospital_cd_3,
		dz.in_hospital_cd_4,
		0 AS class_cd,
		''0'' AS cd,
		0 AS code_order,
		0 AS order_cd,
		dz.dialyzer_cd AS pk_order,
		''ダイアライザ'' AS do_action
	FROM
		ord_main om
		INNER JOIN dz ON TO_NUMBER( om.ind_cond_info :: json #>> ''{5,value}'', ''99999999'' ) = dz.dialyzer_cd
		AND dz.dialyzer_cd IN ( @diaIds )
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{5,value}'' IS NOT NULL
		AND om.is_del = ''0'' UNION ALL
		(
		SELECT
			emq.ord_no,
			emq.disp_order,
			emq.treat_date,
			emq.kind,
			emq.NAME,
			emq.Amount,
			emq.Unit,
			emq.in_hospital_cd_1,
			emq.in_hospital_cd_2,
			emq.in_hospital_cd_3,
			emq.in_hospital_cd_4,
			emq.class_cd,
			emq.cd,
			meqc.code_order,
			meqcc.meq_order AS order_cd,
		  emq.pk_order AS pk_order,
			emq.do_action
		FROM
			(
				SELECT--吸着カラム
				om.ord_no AS ord_no,
				2 AS disp_order,
				om.treat_date,
				COALESCE ( eqc.class_name, '''' ) AS kind,
				eq.equipment_name AS NAME,
				1 AS Amount,
				COALESCE ( eq.unit, '''' ) AS Unit,
				eq.in_hospital_cd_1,
				eq.in_hospital_cd_2,
				eq.in_hospital_cd_3,
				eq.in_hospital_cd_4,
				eq.class_cd :: INTEGER AS class_cd,
				eq.equipment_cd :: TEXT AS cd,
		    eq.equipment_cd AS pk_order,
				''医材'' AS do_action
			FROM
				ord_main om
				LEFT OUTER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{6,value}'', ''99999999'' ) = eq.equipment_cd
				LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
				LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
			WHERE
				om.ord_no IN ( @ordNos )
				AND om.ind_cond_info :: json #>> ''{6,value}'' IS NOT NULL
				AND eq.class_cd IN ( @eqIds )
				AND om.is_del = ''0'' UNION ALL--1次膜
			SELECT
				om.ord_no AS ord_no,
				2 AS disp_order,
				om.treat_date,
				COALESCE ( eqc.class_name, '''' ) AS kind,
				eq.equipment_name AS NAME,
				1 AS Amount,
				COALESCE ( eq.unit, '''' ) AS Unit,
				eq.in_hospital_cd_1,
				eq.in_hospital_cd_2,
				eq.in_hospital_cd_3,
				eq.in_hospital_cd_4,
				eq.class_cd :: INTEGER AS class_cd,
				eq.equipment_cd :: TEXT AS cd,
		    eq.equipment_cd AS pk_order,
				''医材'' AS do_action
			FROM
				ord_main om
				LEFT OUTER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{7,value}'', ''99999999'' ) = eq.equipment_cd
				LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
				LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
			WHERE
				om.ord_no IN ( @ordNos )
				AND om.ind_cond_info :: json #>> ''{7,value}'' IS NOT NULL
				AND eq.class_cd IN ( @eqIds )
				AND om.is_del = ''0'' UNION ALL--2次膜
			SELECT
				om.ord_no AS ord_no,
				2 AS disp_order,
				om.treat_date,
				COALESCE ( eqc.class_name, '''' ) AS kind,
				eq.equipment_name AS NAME,
				1 AS Amount,
				COALESCE ( eq.unit, '''' ) AS Unit,
				eq.in_hospital_cd_1,
				eq.in_hospital_cd_2,
				eq.in_hospital_cd_3,
				eq.in_hospital_cd_4,
				eq.class_cd :: INTEGER AS class_cd,
				eq.equipment_cd :: TEXT AS cd,
		    eq.equipment_cd AS pk_order,
				''医材'' AS do_action
			FROM
				ord_main om
				LEFT OUTER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{8,value}'', ''99999999'' ) = eq.equipment_cd
				LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
				LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
			WHERE
				om.ord_no IN ( @ordNos )
				AND om.ind_cond_info :: json #>> ''{8,value}'' IS NOT NULL
				AND eq.class_cd IN ( @eqIds )
				AND om.is_del = ''0'' UNION ALL--穿刺針(A針)
			SELECT
				om.ord_no AS ord_no,
				2 AS disp_order,
				om.treat_date,
				COALESCE ( eqc.class_name, '''' ) AS kind,
				eq.equipment_name AS NAME,
				1 AS Amount,
				COALESCE ( eq.unit, '''' ) AS Unit,
				eq.in_hospital_cd_1,
				eq.in_hospital_cd_2,
				eq.in_hospital_cd_3,
				eq.in_hospital_cd_4,
				eq.class_cd :: INTEGER AS class_cd,
				eq.equipment_cd :: TEXT AS cd,
		    eq.equipment_cd AS pk_order,
				''医材'' AS do_action
			FROM
				ord_main om
				LEFT OUTER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{9,value}'', ''99999999'' ) = eq.equipment_cd
				LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
				LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
			WHERE
				om.ord_no IN ( @ordNos )
				AND om.ind_cond_info :: json #>> ''{9,value}'' IS NOT NULL
				AND eq.class_cd IN ( @eqIds )
				AND om.is_del = ''0'' UNION ALL--穿刺針(V針)
			SELECT
				om.ord_no AS ord_no,
				2 AS disp_order,
				om.treat_date,
				COALESCE ( eqc.class_name, '''' ) AS kind,
				eq.equipment_name AS NAME,
				1 AS Amount,
				COALESCE ( eq.unit, '''' ) AS Unit,
				eq.in_hospital_cd_1,
				eq.in_hospital_cd_2,
				eq.in_hospital_cd_3,
				eq.in_hospital_cd_4,
				eq.class_cd :: INTEGER AS class_cd,
				eq.equipment_cd :: TEXT AS cd,
		    eq.equipment_cd AS pk_order,
				''医材'' AS do_action
			FROM
				ord_main om
				LEFT OUTER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{10,value}'', ''99999999'' ) = eq.equipment_cd
				LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
				LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
			WHERE
				om.ord_no IN ( @ordNos )
				AND om.ind_cond_info :: json #>> ''{10,value}'' IS NOT NULL
				AND eq.class_cd IN ( @eqIds )
				AND om.is_del = ''0'' UNION ALL--穿刺針(SN)
			SELECT
				om.ord_no AS ord_no,
				2 AS disp_order,
				om.treat_date,
				COALESCE ( eqc.class_name, '''' ) AS kind,
				eq.equipment_name AS NAME,
				1 AS Amount,
				COALESCE ( eq.unit, '''' ) AS Unit,
				eq.in_hospital_cd_1,
				eq.in_hospital_cd_2,
				eq.in_hospital_cd_3,
				eq.in_hospital_cd_4,
				eq.class_cd :: INTEGER AS class_cd,
				eq.equipment_cd :: TEXT AS cd,
		    eq.equipment_cd AS pk_order,
				''医材'' AS do_action
			FROM
				ord_main om
				LEFT OUTER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{11,value}'', ''99999999'' ) = eq.equipment_cd
				LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
				LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
			WHERE
				om.ord_no IN ( @ordNos )
				AND om.ind_cond_info :: json #>> ''{11,value}'' IS NOT NULL
				AND eq.class_cd IN ( @eqIds )
				AND om.is_del = ''0'' UNION ALL--血液回路
			SELECT
				om.ord_no AS ord_no,
				2 AS disp_order,
				om.treat_date,
				COALESCE ( eqc.class_name, '''' ) AS kind,
				eq.equipment_name AS NAME,
				1 AS Amount,
				COALESCE ( eq.unit, '''' ) AS Unit,
				eq.in_hospital_cd_1,
				eq.in_hospital_cd_2,
				eq.in_hospital_cd_3,
				eq.in_hospital_cd_4,
				eq.class_cd :: INTEGER AS class_cd,
				eq.equipment_cd :: TEXT AS cd,
		    eq.equipment_cd AS pk_order,
				''医材'' AS do_action
			FROM
				ord_main om
				LEFT OUTER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{13,value}'', ''99999999'' ) = eq.equipment_cd
				LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
				LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
			WHERE
				om.ord_no IN ( @ordNos )
				AND om.ind_cond_info :: json #>> ''{13,value}'' IS NOT NULL
				AND eq.class_cd IN ( @eqIds )
				AND om.is_del = ''0'' UNION ALL--医材登録
			SELECT
				om.ord_no AS ord_no,
				2 AS disp_order,
				om.treat_date,
				COALESCE ( eqc.class_name, '''' ) AS kind,
				eq.equipment_name AS NAME,
				TO_NUMBER( save.ind_rst_value, ''99999999.99'' ) AS Amount,
				COALESCE ( eq.unit, '''' ) AS Unit,
				eq.in_hospital_cd_1,
				eq.in_hospital_cd_2,
				eq.in_hospital_cd_3,
				eq.in_hospital_cd_4,
				eq.class_cd :: INTEGER AS class_cd,
				eq.equipment_cd :: TEXT AS cd,
		    eq.equipment_cd AS pk_order,
				''医材'' AS do_action
			FROM
				ord_main AS om
				LEFT OUTER JOIN ord_material_save  save on om.ord_no = save.supplies_base_no
		            		and om.facility_cd = save.facility_cd and save.supplies_source_class = ''2''
				LEFT OUTER JOIN eq ON TO_NUMBER( save.supplies_cd, ''99999999'' ) = eq.equipment_cd
				LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
				LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
			WHERE
				om.ord_no IN ( @ordNos )
				AND eq.class_cd IN ( @eqIds )
				AND om.is_del = ''0''
				AND eq.class_cd <> - 1
			) emq
			LEFT OUTER JOIN meqc ON emq.class_cd = meqc.meq_class_code
			LEFT OUTER JOIN meqcc ON emq.pk_order = meqcc.meq_code
		ORDER BY
			meqc.code_order,meqcc.meq_order
		) UNION ALL--医材未登録
								(
								SELECT
									om.ord_no AS ord_no,
									3 AS disp_order,
									om.treat_date,
									COALESCE ( eqc.class_name, '''' ) AS kind,
									eq.equipment_name AS NAME,
									TO_NUMBER( save.ind_rst_value, ''99999999.99'' ) AS Amount,
									COALESCE ( eq.unit, '''' ) AS Unit,
									eq.in_hospital_cd_1,
									eq.in_hospital_cd_2,
									eq.in_hospital_cd_3,
									eq.in_hospital_cd_4,
									eq.class_cd :: INTEGER AS class_cd,
									eq.equipment_cd :: TEXT AS cd,
									0 AS code_order,
									0 AS order_cd,
		              eq.equipment_cd AS pk_order,
									''医材'' AS do_action
								FROM
									ord_main AS om
									LEFT OUTER JOIN ord_material_save  save on om.ord_no = save.supplies_base_no
		            		and om.facility_cd = save.facility_cd and save.supplies_source_class = ''2''
									LEFT OUTER JOIN eq ON TO_NUMBER( save.supplies_cd, ''99999999'' ) = eq.equipment_cd
									LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
									LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
								WHERE
									om.ord_no IN ( @ordNos )
									AND eq.class_cd IN ( @eqIds )
									AND om.is_del = ''0''
									AND eq.class_cd = - 1
								) UNION ALL--投薬登録
								(
								SELECT
									mdcc.ord_no AS ord_no,
									mdcc.disp_order,
									mdcc.treat_date,
									mdcc.kind AS kind,
									mdcc.NAME AS NAME,
									mdcc.Amount AS Amount,
									mdcc.unit AS Unit,
									mdcc.in_hospital_cd_1,
									mdcc.in_hospital_cd_2,
									mdcc.in_hospital_cd_3,
									mdcc.in_hospital_cd_4,
									mdcc.class_cd,
									mdcc.cd,
									dmcc.code_order,
									dmccc.medi_code_order AS order_cd,
		              mdcc.pk_order,
									mdcc.do_action
								FROM
									(
									SELECT
										om.ord_no AS ord_no,
										4 AS disp_order,
										om.treat_date,
										COALESCE ( mdc.class_name, '''' ) AS kind,
										md.medicine_name AS NAME,
										TO_NUMBER( save.ind_rst_value, ''99999999.99'' ) AS Amount,
										COALESCE ( md.unit, '''' ) AS Unit,
										md.in_hospital_cd_1,
										md.in_hospital_cd_2,
										md.in_hospital_cd_3,
										md.in_hospital_cd_4,
										md.class_cd AS class_cd,
										''0'' AS cd,
										md.medicine_cd AS pk_order,
										''投薬'' AS do_action
									FROM
										ord_main AS om
										LEFT OUTER JOIN ord_material_save  save on om.ord_no = save.supplies_base_no
		            		and om.facility_cd = save.facility_cd and save.supplies_source_class = ''1''
										LEFT OUTER JOIN md ON TO_NUMBER( save.supplies_cd, ''99999999'' ) = md.medicine_cd
										LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
										LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
									WHERE
										om.ord_no IN ( @ordNos )
										AND md.class_cd IN ( @medIds )
										AND om.is_del = ''0''
										AND md.class_cd <> - 1 UNION ALL
										SELECT--投与薬剤情報(調製)
										om.ord_no AS ord_no,
										4 AS disp_order,
										om.treat_date,
										COALESCE ( mdc.class_name, '''' ) AS kind,
										md.medicine_name AS NAME,
										to_number( save.ind_rst_value, ''99999.99'' )  AS Amount,
										COALESCE ( md.unit, '''' ) AS Unit,
										md.in_hospital_cd_1,
										md.in_hospital_cd_2,
										md.in_hospital_cd_3,
										md.in_hospital_cd_4,
										md.class_cd AS class_cd,
										''0'' AS cd,
										md.medicine_cd AS pk_order,
										''投薬'' AS do_action
									FROM
										ord_main AS om
										LEFT OUTER JOIN ord_material_save as save on om.ord_no = save.supplies_base_no
										and om.facility_cd = save.facility_cd and save.supplies_source_class = ''1''
										and save.supplies_class = ''20''
				            LEFT OUTER JOIN md ON md.medicine_cd = TO_NUMBER( save.supplies_cd, ''999999999999'' )
										LEFT OUTER JOIN mdc ON mdc.class_cd = md.class_cd
									WHERE
										om.ord_no IN ( @ordNos )
										AND md.class_cd IN ( @medIds )
										AND om.is_del = ''0''
										AND md.class_cd <> - 1
										UNION ALL--透析液
						(
						SELECT
							om.ord_no AS ord_no,
							4 AS disp_order,
							om.treat_date,
							COALESCE ( mdc.class_name, '''' ) AS kind,
							md.medicine_name AS NAME,
							TO_NUMBER( om.ind_cond_info :: json #>> ''{17,value}'', ''99999999.99'' ) AS Amount,
							COALESCE ( md.unit, '''' ) AS Unit,
							md.in_hospital_cd_1,
							md.in_hospital_cd_2,
							md.in_hospital_cd_3,
							md.in_hospital_cd_4,
							md.class_cd :: INTEGER AS class_cd,
							''0'' AS cd,
							md.medicine_cd AS pk_order,
							''投薬'' AS do_action
						FROM
							ord_main om
							LEFT OUTER JOIN md ON TO_NUMBER( om.ind_cond_info :: json #>> ''{15,value}'', ''99999999'' ) = md.medicine_cd
							LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
							LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
						WHERE
							om.ord_no IN ( @ordNos )
							AND om.ind_cond_info :: json #>> ''{15,value}'' IS NOT NULL
							AND md.class_cd IN ( @medIds )
							AND om.is_del = ''0''
						) UNION ALL--補液
					SELECT
						om.ord_no AS ord_no,
						4 AS disp_order,
						om.treat_date,
						COALESCE ( mdc.class_name, '''' ) AS kind,
						md.medicine_name AS NAME,
						TO_NUMBER( om.ind_cond_info :: json #>> ''{22,value}'', ''99999999.99'' ) AS Amount,
						COALESCE ( md.unit, '''' ) AS Unit,
						md.in_hospital_cd_1,
						md.in_hospital_cd_2,
						md.in_hospital_cd_3,
						md.in_hospital_cd_4,
						md.class_cd :: INTEGER AS class_cd,
						''0'' AS cd,
						md.medicine_cd AS pk_order,
						''投薬'' AS do_action
					FROM
						ord_main om
						LEFT OUTER JOIN md ON TO_NUMBER( om.ind_cond_info :: json #>> ''{19,value}'', ''99999999'' ) = md.medicine_cd
						LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
						LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
					WHERE
						om.ord_no IN ( @ordNos )
						AND om.ind_cond_info :: json #>> ''{19,value}'' IS NOT NULL
						AND md.class_cd IN ( @medIds )
						AND om.is_del = ''0'' UNION ALL--抗凝固剤
					SELECT
						om.ord_no AS ord_no,
						4 AS disp_order,
						om.treat_date,
						COALESCE ( mdc.class_name, '''' ) AS kind,
						md.medicine_name AS NAME,
						COALESCE (
							CEIL (
								(
									( TO_NUMBER( om.ind_cond_info :: json #>> ''{26,value}'', ''99999999.99'' ) + TO_NUMBER( om.ind_cond_info :: json #>> ''{28,value}'', ''99999999.99'' ) ) /
								CASE

										WHEN md.unit_converted_amount IS NULL
										OR md.unit_converted_amount = 0 THEN
											1 ELSE md.unit_converted_amount
										END
											) * ( CASE WHEN md.unit_converted_amount_second IS NULL OR md.unit_converted_amount_second = 0 THEN 1 ELSE md.unit_converted_amount_second END )
										),
										( TO_NUMBER( om.ind_cond_info :: json #>> ''{26,value}'', ''99999999.99'' ) + TO_NUMBER( om.ind_cond_info :: json #>> ''{28,value}'', ''99999999.99'' ) )
									) AS Amount,
					COALESCE ( md.unit_second, COALESCE ( md.unit, '''' ) ) AS Unit,
					md.in_hospital_cd_1,
					md.in_hospital_cd_2,
					md.in_hospital_cd_3,
					md.in_hospital_cd_4,
					md.class_cd :: INTEGER AS class_cd,
					''0'' AS cd,
					md.medicine_cd AS pk_order,
					''投薬'' AS do_action
				FROM
					ord_main om
					LEFT OUTER JOIN md ON TO_NUMBER( om.ind_cond_info :: json #>> ''{25,value}'', ''99999999'' ) = md.medicine_cd
					LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
					LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
				WHERE
					om.ord_no IN ( @ordNos )
					AND om.ind_cond_info :: json #>> ''{25,value}'' IS NOT NULL
					AND md.class_cd IN ( @medIds )
					AND om.is_del = ''0'' UNION ALL--抗凝固剤(調製)
				SELECT
					om.ord_no AS ord_no,
					4 AS disp_order,
					om.treat_date,
					COALESCE ( mdc.class_name, '''' ) AS kind,
					md.medicine_name AS NAME,
					(
						COALESCE (
							CEIL (
								(
									( TO_NUMBER( om.ind_cond_info :: json #>> ''{26,value}'', ''99999999.99'' ) + TO_NUMBER( om.ind_cond_info :: json #>> ''{28,value}'', ''99999999.99'' ) ) /
								CASE

										WHEN md.unit_converted_amount IS NULL
										OR md.unit_converted_amount = 0 THEN
											1 ELSE md.unit_converted_amount
										END
											) * ( CASE WHEN md.unit_converted_amount_second IS NULL OR md.unit_converted_amount_second = 0 THEN 1 ELSE md.unit_converted_amount_second END )
										),
										( TO_NUMBER( om.ind_cond_info :: json #>> ''{26,value}'', ''99999999.99'' ) + TO_NUMBER( om.ind_cond_info :: json #>> ''{28,value}'', ''99999999.99'' ) )
									) * to_number( mmxd ->> ''amount'', ''99999.99'' )
								) AS Amount,
								COALESCE ( md.unit_second, COALESCE ( md.unit, '''' ) ) AS Unit,
								md.in_hospital_cd_1,
								md.in_hospital_cd_2,
								md.in_hospital_cd_3,
								md.in_hospital_cd_4,
								md.class_cd :: INTEGER AS class_cd,
								''0'' AS cd,
					    	md.medicine_cd AS pk_order,
								''投薬'' AS do_action
							FROM
								ord_main om
								LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( om.ind_cond_info -> ''25'' ->> ''value'', ''999999999999'' )
								CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
								LEFT OUTER JOIN md ON md.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
								LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
								LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
							WHERE
								om.ord_no IN ( @ordNos )
								AND om.ind_cond_info :: json #>> ''{25,value}'' IS NOT NULL
								AND md.class_cd IN ( @medIds )
								AND om.is_del = ''0''
									) mdcc
									LEFT OUTER JOIN dmcc ON dmcc.medi_class_code = mdcc.class_cd
									LEFT OUTER JOIN dmccc ON dmccc.medi_code = mdcc.pk_order
								ORDER BY
									dmcc.code_order,dmccc.medi_code_order ASC
								) UNION ALL--投薬未登録
								(
								SELECT
									om.ord_no AS ord_no,
									5 AS disp_order,
									om.treat_date,
									COALESCE ( mdc.class_name, '''' ) AS kind,
									md.medicine_name AS NAME,
									TO_NUMBER( save.ind_rst_value, ''99999999.99'' ) AS Amount,
									COALESCE ( md.unit, '''' ) AS Unit,
									md.in_hospital_cd_1,
									md.in_hospital_cd_2,
									md.in_hospital_cd_3,
									md.in_hospital_cd_4,
									- 1 AS class_cd,
									''0'' AS cd,
									0 AS code_order,
									0 AS order_cd,
					      	md.medicine_cd AS pk_order,
									''投薬'' AS do_action
								FROM
									ord_main AS om
									LEFT OUTER JOIN ord_material_save as save on om.ord_no = save.supplies_base_no
									and om.facility_cd = save.facility_cd
									and save.supplies_source_class = ''1''
									LEFT OUTER JOIN md ON TO_NUMBER( save.supplies_cd, ''99999999'' ) = md.medicine_cd
									LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
									LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
								WHERE
									om.ord_no IN ( @ordNos )
									AND md.class_cd IN ( @medIds )
									AND om.is_del = ''0''
									AND md.class_cd = - 1
								)
							) AS EquipmentList
						GROUP BY
							disp_order,
							treat_date,
							kind,
							NAME,
							Unit,
							in_hospital_cd_1,
							in_hospital_cd_2,
							in_hospital_cd_3,
							in_hospital_cd_4,
							class_cd,
							cd,
							code_order,
							order_cd,
							pk_order,
							do_action
						HAVING
							SUM ( Amount ) > 0
						ORDER BY
							disp_order,
						code_order,
						order_cd,
						pk_order,
	kind;', 2, '[{"preview": "テープ", "can_calc": "0", "data_code": "kind", "data_name": "分類名称", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "kind", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70%ブドウ糖注射液350ml", "can_calc": "0", "data_code": "name", "data_name": "型番･名称", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "name", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "1", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "物品情報", "field_name": "amount", "disp_format": "0.00", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "個", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "unit", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_1", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_2", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_3", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_4", "data_name": "院内コード4", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_4", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [4]}', '器材準備リスト', '2020-01-11 13:28:00', CURRENT_TIMESTAMP, NULL);
