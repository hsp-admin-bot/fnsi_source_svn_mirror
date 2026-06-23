DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (11);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (11, 'WITH om AS ( SELECT * FROM ord_main WHERE is_del = ''0'' AND ord_no IN ( @ordNos ) ),
fncd AS ( SELECT facility_cd FROM ord_main WHERE is_del = ''0'' AND ord_no IN ( @ordNos ) LIMIT 1 ),
dz AS ( SELECT * FROM mst_dialyzer mst JOIN fncd ON fncd.facility_cd = mst.facility_cd WHERE is_del = ''0'' AND is_disp = ''1'' ),
kr AS ( SELECT * FROM mst_kur mst JOIN fncd ON fncd.facility_cd = mst.facility_cd WHERE is_del = ''0'' ),
bd AS ( SELECT * FROM mst_bed mst JOIN fncd ON fncd.facility_cd = mst.facility_cd WHERE is_del = ''0'' AND is_disp = ''1'' ),
eq AS ( SELECT * FROM mst_equipment mst JOIN fncd ON fncd.facility_cd = mst.facility_cd WHERE is_del = ''0'' AND is_disp = ''1'' ),
eqc AS ( SELECT * FROM mst_equipment_class mst JOIN fncd ON fncd.facility_cd = mst.facility_cd WHERE is_del = ''0'' AND is_disp = ''1'' ),
md AS ( SELECT * FROM mst_medicine mst JOIN fncd ON fncd.facility_cd = mst.facility_cd WHERE is_del = ''0'' AND is_disp = ''1'' ),
mdx AS ( SELECT * FROM mst_medicine_mix mst JOIN fncd ON fncd.facility_cd = mst.facility_cd WHERE is_del = ''0'' AND is_disp = ''1'' ),
mdc AS ( SELECT * FROM mst_medicine_class mst JOIN fncd ON fncd.facility_cd = mst.facility_cd WHERE is_del = ''0'' AND is_disp = ''1'' ) SELECT
to_timestamp( treat_date, ''YYYYMMDD'' ) AS treat_date,
kind,
NAME,
code,
kur_cd,
kur_name,
SUM ( Amount ) AS amount,
unit,
bed_name,
pat_id,
pat_id AS pat_id1,
in_hospital_cd_1,
in_hospital_cd_2,
in_hospital_cd_3,
in_hospital_cd_4
FROM
	(
	SELECT
		1 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN dz.model_number IS NOT NULL THEN
			''ダイアライザ'' ELSE NULL
		END AS kind,
		dz.model_number AS NAME,
		dz.dialyzer_cd AS code,
	CASE

			WHEN dz.model_number IS NOT NULL THEN
			1 ELSE NULL
		END AS Amount,
		COALESCE ( om.ind_cond_info :: json #>> ''{5,unit}'', '''' ) AS Unit,
		dz.in_hospital_cd_1,
		dz.in_hospital_cd_2,
		dz.in_hospital_cd_3,
		dz.in_hospital_cd_4
	FROM
		om
		INNER JOIN dz ON TO_NUMBER( om.ind_cond_info :: json #>> ''{5,value}'', ''99999999'' ) = dz.dialyzer_cd
		AND dz.dialyzer_cd IN ( @diaIds )
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{5,value}'' IS NOT NULL UNION ALL--吸着カラム
	SELECT
		2 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
		COALESCE ( eqc.class_name, '''' ) AS kind,
		eq.equipment_name AS NAME,
		eq.equipment_cd AS code,
		1 AS Amount,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{6,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{6,value}'' IS NOT NULL UNION ALL--1次膜
	SELECT
		3 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
		eq.equipment_name AS NAME,
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{7,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{7,value}'' IS NOT NULL UNION ALL--2次膜
	SELECT
		4 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
		eq.equipment_name AS NAME,
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{8,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{8,value}'' IS NOT NULL UNION ALL--穿刺針(A針)
	SELECT
		5 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
		eq.equipment_name AS NAME,
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{9,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{9,value}'' IS NOT NULL UNION ALL--穿刺針(V針)
	SELECT
		5 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
		eq.equipment_name AS NAME,
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{10,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{10,value}'' IS NOT NULL UNION ALL--穿刺針(SN)
	SELECT
		6 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''''''' )
		END AS kind,
		eq.equipment_name AS NAME,
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{11,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{11,value}'' IS NOT NULL UNION ALL--血液回路
	SELECT
		7 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
		eq.equipment_name AS NAME,
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{13,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{13,value}'' IS NOT NULL UNION ALL--透析液
	SELECT
		8 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN mdc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
		END AS kind,
		md.medicine_name AS NAME,
		md.medicine_cd AS code,
		TO_NUMBER( om.ind_cond_info :: json #>> ''{17,value}'', ''99999999.99'' ) AS Amount,
		COALESCE ( md.unit, '''' ) AS Unit,
		md.in_hospital_cd_1,
		md.in_hospital_cd_2,
		md.in_hospital_cd_3,
		md.in_hospital_cd_4
	FROM
		om
		INNER JOIN md ON TO_NUMBER( om.ind_cond_info :: json #>> ''{15,value}'', ''99999999'' ) = md.medicine_cd
		AND md.class_cd IN ( @medIds )
		LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{15,value}'' IS NOT NULL UNION ALL--補液
	SELECT
		9 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN mdc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
		END AS kind,
		md.medicine_name AS NAME,
		md.medicine_cd AS code,
		TO_NUMBER( om.ind_cond_info :: json #>> ''{22,value}'', ''99999999.99'' ) AS Amount,
		COALESCE ( md.unit, '''' ) AS Unit,
		md.in_hospital_cd_1,
		md.in_hospital_cd_2,
		md.in_hospital_cd_3,
		md.in_hospital_cd_4
	FROM
		om
		INNER JOIN md ON TO_NUMBER( om.ind_cond_info :: json #>> ''{19,value}'', ''99999999'' ) = md.medicine_cd
		AND md.class_cd IN ( @medIds )
		LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{19,value}'' IS NOT NULL UNION ALL--抗凝固剤
	SELECT
		10 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN mdc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
		END AS kind,
		md.medicine_name AS NAME,
		md.medicine_cd AS code,
		CEIL (
			(
				( TO_NUMBER( om.ind_cond_info :: json #>> ''{26,value}'', ''99999999.99'' ) + TO_NUMBER( om.ind_cond_info :: json #>> ''{28,value}'', ''99999999.99'' ) ) / ( CASE WHEN md.unit_converted_amount IS NULL OR md.unit_converted_amount = 0 THEN 1 ELSE md.unit_converted_amount END )
					) * ( CASE WHEN md.unit_converted_amount_second IS NULL OR md.unit_converted_amount_second = 0 THEN 1 ELSE md.unit_converted_amount_second END )
				) AS Amount,
				COALESCE ( md.unit, '''' ) AS Unit,
				md.in_hospital_cd_1,
				md.in_hospital_cd_2,
				md.in_hospital_cd_3,
				md.in_hospital_cd_4
			FROM
				om
				INNER JOIN md ON TO_NUMBER( om.ind_cond_info :: json #>> ''{25,value}'', ''99999999'' ) = md.medicine_cd
				AND md.class_cd IN ( @medIds )
				LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
				LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
				LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
			WHERE
				om.ord_no IN ( @ordNos )
				AND om.ind_cond_info :: json #>> ''{25,value}'' IS NOT NULL  UNION ALL--抗凝固剤調製薬剤
	SELECT
		10 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN mdc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
		END AS kind,
		mdx.medicine_mix_name AS NAME,
		mdx.medicine_mix_cd AS code,
		( TO_NUMBER( om.ind_cond_info :: json #>> ''{26,value}'', ''99999999.99'' ) + TO_NUMBER( om.ind_cond_info :: json #>> ''{28,value}'', ''99999999.99'' ) ) AS Amount,
				COALESCE ( mdx.unit, '''' ) AS Unit,
				mdx.in_hospital_cd_1,
				mdx.in_hospital_cd_2,
				mdx.in_hospital_cd_3,
				null as in_hospital_cd_4
			FROM
				om
				INNER JOIN mdx ON mdx.medicine_mix_cd = TO_NUMBER( om.ind_cond_info -> ''25'' ->> ''value'', ''999999999999'' )
				LEFT OUTER JOIN mdc ON mdx.class_cd = mdc.class_cd
				LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
				LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
			WHERE
				om.ord_no IN ( @ordNos )
				AND om.ind_cond_info :: json #>> ''{25,value}'' IS NOT NULL UNION ALL--投薬
			SELECT
				11 AS disp_order,
				om.treat_date,
				kr.kur_cd,
				COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
				COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
				om.pat_id,
			CASE

					WHEN mdc.class_name IS NULL THEN
					''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS kind,
				md.medicine_name AS NAME,
				md.medicine_cd AS code,
				TO_NUMBER(save.ind_rst_value, ''99999999.99'' )  AS Amount,
						COALESCE ( md.unit_second, COALESCE ( md.unit, '''' ) ) AS Unit,
						md.in_hospital_cd_1,
						md.in_hospital_cd_2,
						md.in_hospital_cd_3,
						md.in_hospital_cd_4
					FROM
						om
						LEFT OUTER JOIN ord_material_save as save on om.ord_no = save.supplies_base_no
									and om.facility_cd = save.facility_cd
									and save.supplies_source_class = ''1''
									and save.supplies_class = ''12''
									and save.ind_rst_class = ''1''
						INNER JOIN md ON TO_NUMBER( save.supplies_cd, ''99999999'' ) = md.medicine_cd
						AND md.class_cd IN ( @medIds )
						LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
						LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
						LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
					WHERE
						om.ord_no IN ( @ordNos ) UNION ALL--投薬
			SELECT
				11 AS disp_order,
				om.treat_date,
				kr.kur_cd,
				COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
				COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
				om.pat_id,
			CASE

					WHEN mdc.class_name IS NULL THEN
					''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS kind,
				mdx.medicine_mix_name AS NAME,
				mdx.medicine_mix_cd AS code,
				TO_NUMBER(save.ind_rst_value, ''99999999.99'' )  AS Amount,
						 COALESCE ( mdx.unit, '''' )  AS Unit,
						mdx.in_hospital_cd_1,
						mdx.in_hospital_cd_2,
						mdx.in_hospital_cd_3,
						null as in_hospital_cd_4
					FROM
						om
						LEFT OUTER JOIN ord_material_save as save on om.ord_no = save.supplies_base_no
									and om.facility_cd = save.facility_cd
									and save.supplies_source_class = ''1''
									and save.supplies_class = ''13''
									and save.ind_rst_class = ''1''
						INNER JOIN mdx ON TO_NUMBER(save.medicine_mix_cd, ''99999999'' ) = mdx.medicine_mix_cd
						AND mdx.class_cd IN ( @medIds )
						LEFT OUTER JOIN mdc ON mdx.class_cd = mdc.class_cd
						LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
						LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
					WHERE
						om.ord_no IN ( @ordNos ) UNION ALL--医材
					SELECT
						12 AS disp_order,
						om.treat_date,
						kr.kur_cd,
						COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
						COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
						om.pat_id,
					CASE

							WHEN eqc.class_name IS NULL THEN
							''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
						END AS kind,
						eq.equipment_name AS NAME,
						eq.equipment_cd AS code,
						TO_NUMBER(save.ind_rst_value, ''99999999.99'' )  AS Amount,
						COALESCE ( eq.unit, '''' ) AS Unit,
						eq.in_hospital_cd_1,
						eq.in_hospital_cd_2,
						eq.in_hospital_cd_3,
						eq.in_hospital_cd_4
					FROM
						om
            LEFT OUTER JOIN ord_material_save as save on om.ord_no = save.supplies_base_no
									and om.facility_cd = save.facility_cd
									and save.supplies_source_class = ''2''
									and save.ind_rst_class = ''1''
						INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = eq.equipment_cd
						AND eq.class_cd IN ( @eqIds )
						LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
						LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
						LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
					WHERE
						om.ord_no IN ( @ordNos )
					) AS EquipmentList
				GROUP BY
					treat_date,
					kind,
					NAME,
					code,
					kur_cd,
					kur_name,
					Unit,
					bed_name,
					pat_id,
					pat_id1,
					disp_order,
					in_hospital_cd_1,
					in_hospital_cd_2,
					in_hospital_cd_3,
					in_hospital_cd_4
				ORDER BY
					disp_order,
					kind,
					code,
					NAME,
					kur_cd,
					kur_name,
				bed_name,
	pat_id;', 2, '[{"preview": "1", "can_calc": "", "data_code": "kur_cd", "data_name": "クールコード", "data_type": "decimal", "conv_table": [], "data_class": "ベッド情報", "field_name": "kur_cd", "disp_format": "", "data_category": "配布リスト(器材)", "facility_table": "", "facility_filter_type": ""}, {"preview": "午後", "can_calc": "", "data_code": "kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "kur_name", "disp_format": "", "data_category": "配布リスト(器材)", "facility_table": "", "facility_filter_type": ""}, {"preview": "北1", "can_calc": "", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "bed_name", "disp_format": "", "data_category": "配布リスト(器材)", "facility_table": "", "facility_filter_type": ""}, {"preview": "テープ", "can_calc": "0", "data_code": "kind", "data_name": "分類名称", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "kind", "disp_format": "", "data_category": "配布リスト(器材)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70%ブドウ糖注射液350ml", "can_calc": "0", "data_code": "name", "data_name": "型番･名称", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "name", "disp_format": "", "data_category": "配布リスト(器材)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "1", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "物品情報", "field_name": "amount", "disp_format": "0.00", "data_category": "配布リスト(器材)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "個", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "unit", "disp_format": "", "data_category": "配布リスト(器材)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20200101", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "抽出条件", "field_name": "treat_date", "disp_format": "", "data_category": "印刷情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789012", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "hosp_pat_id", "target_var": "@patId"}, "data_code": "hosp_pat_id", "data_name": "患者ID", "data_type": "string", "conv_table": [], "data_class": "基本情報", "field_name": "pat_id", "disp_format": "", "data_category": "配布リスト(器材)", "facility_filter_type": "0"}, {"preview": "テスト患者1", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_name", "target_var": "@patId"}, "data_code": "pat_name", "data_name": "患者名", "data_type": "string", "conv_table": [], "data_class": "基本情報", "field_name": "pat_id1", "disp_format": "", "data_category": "配布リスト(器材)", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [6]}', '配布リスト(器材)', '2020-01-11 13:28:00', CURRENT_TIMESTAMP, NULL);

DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (206);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (206, 'WITH om AS ( SELECT * FROM ord_main WHERE is_del = ''0'' AND ord_no IN ( @ordNos ) ),
fncd AS ( SELECT facility_cd FROM ord_main WHERE is_del = ''0'' AND ord_no IN ( @ordNos ) LIMIT 1 ),
dz AS ( SELECT * FROM mst_dialyzer mst JOIN fncd ON fncd.facility_cd = mst.facility_cd WHERE is_del = ''0'' AND is_disp = ''1'' ),
kr AS ( SELECT * FROM mst_kur mst JOIN fncd ON fncd.facility_cd = mst.facility_cd WHERE is_del = ''0'' ),
bd AS ( SELECT * FROM mst_bed mst JOIN fncd ON fncd.facility_cd = mst.facility_cd WHERE is_del = ''0'' AND is_disp = ''1'' ),
eq AS ( SELECT * FROM mst_equipment mst JOIN fncd ON fncd.facility_cd = mst.facility_cd WHERE is_del = ''0'' AND is_disp = ''1'' ),
eqc AS ( SELECT * FROM mst_equipment_class mst JOIN fncd ON fncd.facility_cd = mst.facility_cd WHERE is_del = ''0'' AND is_disp = ''1'' ),
md AS ( SELECT * FROM mst_medicine mst JOIN fncd ON fncd.facility_cd = mst.facility_cd WHERE is_del = ''0'' AND is_disp = ''1'' ),
mdx AS ( SELECT * FROM mst_medicine_mix mst JOIN fncd ON fncd.facility_cd = mst.facility_cd WHERE is_del = ''0'' AND is_disp = ''1'' ),
mdc AS ( SELECT * FROM mst_medicine_class mst JOIN fncd ON fncd.facility_cd = mst.facility_cd WHERE is_del = ''0'' AND is_disp = ''1'' ) SELECT
to_timestamp( treat_date, ''YYYYMMDD'' ) AS treat_date,
kind,
NAME,
code,
kur_cd,
kur_name,
SUM ( Amount ) AS amount,
unit,
bed_name,
pat_id,
pat_id AS pat_id1,
in_hospital_cd_1,
in_hospital_cd_2,
in_hospital_cd_3,
in_hospital_cd_4
FROM
	(
	SELECT
		1 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN dz.model_number IS NOT NULL THEN
			''ダイアライザ'' ELSE NULL
		END AS kind,
		dz.model_number AS NAME,
		dz.dialyzer_cd AS code,
	CASE

			WHEN dz.model_number IS NOT NULL THEN
			1 ELSE NULL
		END AS Amount,
		COALESCE ( om.ind_cond_info :: json #>> ''{5,unit}'', '''' ) AS Unit,
		dz.in_hospital_cd_1,
		dz.in_hospital_cd_2,
		dz.in_hospital_cd_3,
		dz.in_hospital_cd_4
	FROM
		om
		INNER JOIN dz ON TO_NUMBER( om.ind_cond_info :: json #>> ''{5,value}'', ''99999999'' ) = dz.dialyzer_cd
		AND dz.dialyzer_cd IN ( @diaIds )
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{5,value}'' IS NOT NULL UNION ALL--吸着カラム
	SELECT
		2 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
		COALESCE ( eqc.class_name, '''' ) AS kind,
		eq.equipment_name AS NAME,
		eq.equipment_cd AS code,
		1 AS Amount,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{6,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{6,value}'' IS NOT NULL UNION ALL--1次膜
	SELECT
		3 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
		eq.equipment_name AS NAME,
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{7,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{7,value}'' IS NOT NULL UNION ALL--2次膜
	SELECT
		4 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
		eq.equipment_name AS NAME,
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{8,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{8,value}'' IS NOT NULL UNION ALL--穿刺針(A針)
	SELECT
		5 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
		eq.equipment_name AS NAME,
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{9,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{9,value}'' IS NOT NULL UNION ALL--穿刺針(V針)
	SELECT
		5 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
		eq.equipment_name AS NAME,
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{10,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{10,value}'' IS NOT NULL UNION ALL--穿刺針(SN)
	SELECT
		6 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''''''' )
		END AS kind,
		eq.equipment_name AS NAME,
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{11,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{11,value}'' IS NOT NULL UNION ALL--血液回路
	SELECT
		7 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
		eq.equipment_name AS NAME,
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{13,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{13,value}'' IS NOT NULL UNION ALL--透析液
	SELECT
		8 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN mdc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
		END AS kind,
		md.medicine_name AS NAME,
		md.medicine_cd AS code,
		TO_NUMBER( om.ind_cond_info :: json #>> ''{17,value}'', ''99999999.99'' ) AS Amount,
		COALESCE ( md.unit, '''' ) AS Unit,
		md.in_hospital_cd_1,
		md.in_hospital_cd_2,
		md.in_hospital_cd_3,
		md.in_hospital_cd_4
	FROM
		om
		INNER JOIN md ON TO_NUMBER( om.ind_cond_info :: json #>> ''{15,value}'', ''99999999'' ) = md.medicine_cd
		AND md.class_cd IN ( @medIds )
		LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{15,value}'' IS NOT NULL UNION ALL--補液
	SELECT
		9 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN mdc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
		END AS kind,
		md.medicine_name AS NAME,
		md.medicine_cd AS code,
		TO_NUMBER( om.ind_cond_info :: json #>> ''{22,value}'', ''99999999.99'' ) AS Amount,
		COALESCE ( md.unit, '''' ) AS Unit,
		md.in_hospital_cd_1,
		md.in_hospital_cd_2,
		md.in_hospital_cd_3,
		md.in_hospital_cd_4
	FROM
		om
		INNER JOIN md ON TO_NUMBER( om.ind_cond_info :: json #>> ''{19,value}'', ''99999999'' ) = md.medicine_cd
		AND md.class_cd IN ( @medIds )
		LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{19,value}'' IS NOT NULL UNION ALL--抗凝固剤
	SELECT
		10 AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
	CASE

			WHEN mdc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
		END AS kind,
		md.medicine_name AS NAME,
		md.medicine_cd AS code,
		CEIL (
			(
				( TO_NUMBER( om.ind_cond_info :: json #>> ''{26,value}'', ''99999999.99'' ) + TO_NUMBER( om.ind_cond_info :: json #>> ''{28,value}'', ''99999999.99'' ) ) / ( CASE WHEN md.unit_converted_amount IS NULL OR md.unit_converted_amount = 0 THEN 1 ELSE md.unit_converted_amount END )
					) * ( CASE WHEN md.unit_converted_amount_second IS NULL OR md.unit_converted_amount_second = 0 THEN 1 ELSE md.unit_converted_amount_second END )
				) AS Amount,
				COALESCE ( md.unit, '''' ) AS Unit,
				md.in_hospital_cd_1,
				md.in_hospital_cd_2,
				md.in_hospital_cd_3,
				md.in_hospital_cd_4
			FROM
				om
				INNER JOIN md ON TO_NUMBER( om.ind_cond_info :: json #>> ''{25,value}'', ''99999999'' ) = md.medicine_cd
				AND md.class_cd IN ( @medIds )
				LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
				LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
				LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
			WHERE
				om.ord_no IN ( @ordNos )
				AND om.ind_cond_info :: json #>> ''{25,value}'' IS NOT NULL UNION ALL--抗凝固剤
			SELECT
				10 AS disp_order,
				om.treat_date,
				kr.kur_cd,
				COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
				COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
				om.pat_id,
			CASE

					WHEN mdc.class_name IS NULL THEN
					''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS kind,
				md.medicine_name AS NAME,
				md.medicine_cd AS code,
				CEIL (
					(
						( TO_NUMBER( om.ind_cond_info :: json #>> ''{26,value}'', ''99999999.99'' ) + TO_NUMBER( om.ind_cond_info :: json #>> ''{28,value}'', ''99999999.99'' ) ) / ( CASE WHEN md.unit_converted_amount IS NULL OR md.unit_converted_amount = 0 THEN 1 ELSE md.unit_converted_amount END )
							) * ( CASE WHEN md.unit_converted_amount_second IS NULL OR md.unit_converted_amount_second = 0 THEN 1 ELSE md.unit_converted_amount_second END )
						) AS Amount,
						COALESCE ( md.unit, '''' ) AS Unit,
						md.in_hospital_cd_1,
						md.in_hospital_cd_2,
						md.in_hospital_cd_3,
						md.in_hospital_cd_4
					FROM
						om
						INNER JOIN mdx ON TO_NUMBER( om.ind_cond_info :: json #>> ''{25,value}'', ''99999999'' ) = mdx.medicine_mix_cd
						CROSS JOIN LATERAL json_array_elements ( mdx.mix_info :: json ) mix_info1
						INNER JOIN md ON TO_NUMBER( mix_info1->> ''cd'', ''99999999'' ) = md.medicine_cd
						AND md.class_cd IN ( @medIds )
						LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
						LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
						LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
					WHERE
						om.ord_no IN ( @ordNos )
						AND om.ind_cond_info :: json #>> ''{25,value}'' IS NOT NULL UNION ALL--投薬
			SELECT
				11 AS disp_order,
				om.treat_date,
				kr.kur_cd,
				COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
				COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
				om.pat_id,
			CASE

					WHEN mdc.class_name IS NULL THEN
					''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS kind,
				md.medicine_name AS NAME,
				md.medicine_cd AS code,
				TO_NUMBER(save.ind_rst_value, ''99999999.99'' )  AS Amount,
						COALESCE ( md.unit_second, COALESCE ( md.unit, '''' ) ) AS Unit,
						md.in_hospital_cd_1,
						md.in_hospital_cd_2,
						md.in_hospital_cd_3,
						md.in_hospital_cd_4
					FROM
						om
						LEFT OUTER JOIN ord_material_save as save on om.ord_no = save.supplies_base_no
									and om.facility_cd = save.facility_cd
									and save.supplies_source_class = ''1''
									and save.ind_rst_class = ''1''
									and save.supplies_class in (''12'', ''20'')
						INNER JOIN md ON TO_NUMBER( save.supplies_cd, ''99999999'' ) = md.medicine_cd
						AND md.class_cd IN ( @medIds )
						LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
						LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
						LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
					WHERE
						om.ord_no IN ( @ordNos ) UNION ALL--医材
					SELECT
						12 AS disp_order,
						om.treat_date,
						kr.kur_cd,
						COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
						COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
						om.pat_id,
					CASE

							WHEN eqc.class_name IS NULL THEN
							''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
						END AS kind,
						eq.equipment_name AS NAME,
						eq.equipment_cd AS code,
						TO_NUMBER(save.ind_rst_value, ''99999999.99'' )  AS Amount,
						COALESCE ( eq.unit, '''' ) AS Unit,
						eq.in_hospital_cd_1,
						eq.in_hospital_cd_2,
						eq.in_hospital_cd_3,
						eq.in_hospital_cd_4
					FROM
						om
						LEFT OUTER JOIN ord_material_save as save on om.ord_no = save.supplies_base_no
									and om.facility_cd = save.facility_cd
									and save.supplies_source_class = ''2''
									and save.ind_rst_class = ''1''
						INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = eq.equipment_cd
						AND eq.class_cd IN ( @eqIds )
						LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
						LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
						LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
					WHERE
						om.ord_no IN ( @ordNos )
					) AS EquipmentList
				GROUP BY
					treat_date,
					kind,
					NAME,
					code,
					kur_cd,
					kur_name,
					Unit,
					bed_name,
					pat_id,
					pat_id1,
					disp_order,
					in_hospital_cd_1,
					in_hospital_cd_2,
					in_hospital_cd_3,
					in_hospital_cd_4
				ORDER BY
					disp_order,
					kind,
					code,
					NAME,
					kur_cd,
					kur_name,
				bed_name,
	pat_id;', 2, '[{"preview": "1", "can_calc": "", "data_code": "kur_cd", "data_name": "クールコード", "data_type": "decimal", "conv_table": [], "data_class": "ベッド情報（分解）", "field_name": "kur_cd", "disp_format": "", "data_category": "配布リスト(器材)", "facility_table": "", "facility_filter_type": ""}, {"preview": "午後", "can_calc": "", "data_code": "kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報（分解）", "field_name": "kur_name", "disp_format": "", "data_category": "配布リスト(器材)", "facility_table": "", "facility_filter_type": ""}, {"preview": "北1", "can_calc": "", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報（分解）", "field_name": "bed_name", "disp_format": "", "data_category": "配布リスト(器材)", "facility_table": "", "facility_filter_type": ""}, {"preview": "テープ", "can_calc": "0", "data_code": "kind", "data_name": "分類名称", "data_type": "string", "conv_table": [], "data_class": "物品情報（分解）", "field_name": "kind", "disp_format": "", "data_category": "配布リスト(器材)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70%ブドウ糖注射液350ml", "can_calc": "0", "data_code": "name", "data_name": "型番･名称", "data_type": "string", "conv_table": [], "data_class": "物品情報（分解）", "field_name": "name", "disp_format": "", "data_category": "配布リスト(器材)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "1", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "物品情報（分解）", "field_name": "amount", "disp_format": "0.00", "data_category": "配布リスト(器材)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "個", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "物品情報（分解）", "field_name": "unit", "disp_format": "", "data_category": "配布リスト(器材)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20200101", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "抽出条件", "field_name": "treat_date", "disp_format": "", "data_category": "印刷情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789012", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "hosp_pat_id", "target_var": "@patId"}, "data_code": "hosp_pat_id", "data_name": "患者ID", "data_type": "string", "conv_table": [], "data_class": "基本情報（分解）", "field_name": "pat_id", "disp_format": "", "data_category": "配布リスト(器材)", "facility_filter_type": "0"}, {"preview": "テスト患者1", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_name", "target_var": "@patId"}, "data_code": "pat_name", "data_name": "患者名", "data_type": "string", "conv_table": [], "data_class": "基本情報（分解）", "field_name": "pat_id1", "disp_format": "", "data_category": "配布リスト(器材)", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [6]}', '配布リスト(器材)', '2020-01-11 13:28:00', CURRENT_TIMESTAMP, NULL);
