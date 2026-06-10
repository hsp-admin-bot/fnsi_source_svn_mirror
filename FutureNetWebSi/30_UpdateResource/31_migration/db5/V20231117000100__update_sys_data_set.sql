DELETE FROM "ntss"."sys_data_set" WHERE sql_cd = 10;
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (10, 'WITH x AS (
	SELECT
		om.*,
		save.supplies_source_class,
		save.supplies_class,
		save.ind_rst_class,
		save.supplies_cd,
		save.receipt_value,
		save.ind_rst_value,
		save.medicine_mix_cd,
		TO_NUMBER( save.supplies_cd, ''9999999999'' ) supplies_cd_n,
		kr.kur_cd,
		kr.kur_name,
		bd.bed_name
	FROM
		ord_main AS om
		INNER JOIN ord_material_save AS save ON ( om.ord_no = save.supplies_base_no AND om.facility_cd = save.facility_cd AND save.ind_rst_class = ''1'' )
		LEFT OUTER JOIN mst_kur AS kr ON ( om.ind_kur_cd = kr.kur_cd AND kr.is_del = ''0'' )
		LEFT OUTER JOIN mst_bed AS bd ON ( om.ind_bed_cd = bd.bed_cd AND bd.is_del = ''0'' AND bd.is_disp = ''1'' )
	WHERE
		om.ord_no IN ( @ordNo )
		AND om.is_del = ''0''
	) SELECT
	to_timestamp( treat_date, ''YYYYMMDD'' ) AS treat_date,
	kur_cd,
	kur_name,
	bed_name,
	pat_id,
	kind,
	NAME,
	SUM ( Amount ) AS amount,
	unit,
	in_hospital_cd_1,
	in_hospital_cd_2,
	in_hospital_cd_3,
	in_hospital_cd_4,
	pat_id AS pat_id_to_name
FROM
	(
	SELECT
		1 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
	CASE

			WHEN dz.model_number IS NOT NULL THEN
			''ダイアライザ'' ELSE NULL
		END AS kind,
		dz.model_number AS NAME,
	CASE

			WHEN dz.model_number IS NOT NULL THEN
			1 ELSE NULL
		END AS Amount,
		'''' AS Unit,
		dz.in_hospital_cd_1,
		dz.in_hospital_cd_2,
		dz.in_hospital_cd_3,
		dz.in_hospital_cd_4
	FROM
		x
		INNER JOIN mst_dialyzer AS dz ON ( x.supplies_cd_n = dz.dialyzer_cd AND dz.is_del = ''0'' AND dz.is_disp = ''1'' )
		AND dz.dialyzer_cd IN ( @diaIds )
	WHERE
		x.supplies_source_class = ''0''
		AND x.supplies_class = ''01''
		AND x.ind_rst_class = ''1'' UNION ALL--吸着カラム
	SELECT
		2 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
		eq.equipment_name AS NAME,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		x
		INNER JOIN mst_equipment AS eq ON (
			x.supplies_cd_n = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			AND eq.class_cd IN ( @eqIds )
		)
		LEFT OUTER JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'' )
	WHERE
		x.supplies_source_class = ''0''
		AND x.supplies_class = ''02''
		AND x.ind_rst_class = ''1'' UNION ALL--1次膜
	SELECT
		3 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
		eq.equipment_name AS NAME,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		x
		INNER JOIN mst_equipment AS eq ON (
			x.supplies_cd_n = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			AND eq.class_cd IN ( @eqIds )
		)
		LEFT OUTER JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'' )
	WHERE
		x.supplies_source_class = ''0''
		AND x.supplies_class = ''03''
		AND x.ind_rst_class = ''1'' UNION ALL--2次膜
	SELECT
		4 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
		eq.equipment_name AS NAME,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		x
		INNER JOIN mst_equipment AS eq ON (
			x.supplies_cd_n = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			AND eq.class_cd IN ( @eqIds )
		)
		LEFT OUTER JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'' )
	WHERE
		x.supplies_source_class = ''0''
		AND x.supplies_class = ''04''
		AND x.ind_rst_class = ''1'' UNION ALL--穿刺針(A針)
	SELECT
		5 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
		eq.equipment_name AS NAME,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		x
		INNER JOIN mst_equipment AS eq ON (
			x.supplies_cd_n = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			AND eq.class_cd IN ( @eqIds )
		)
		LEFT OUTER JOIN mst_equipment_class AS eqc ON (
			eq.class_cd = eqc.class_cd
			AND eqc.is_del = ''0''
			AND eqc.is_disp = ''1''
			AND eqc.class_cd IN ( @eqIds )
		)
	WHERE
		x.supplies_source_class = ''0''
		AND x.supplies_class = ''06''
		AND x.ind_rst_class = ''1'' UNION ALL--穿刺針(V針)
	SELECT
		5 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
		eq.equipment_name AS NAME,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		x
		INNER JOIN mst_equipment AS eq ON (
			x.supplies_cd_n = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			AND eq.class_cd IN ( @eqIds )
		)
		LEFT OUTER JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'' )
	WHERE
		x.supplies_source_class = ''0''
		AND x.supplies_class = ''07''
		AND x.ind_rst_class = ''1'' UNION ALL--穿刺針(SN)
	SELECT
		6 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
		eq.equipment_name AS NAME,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		x
		INNER JOIN mst_equipment AS eq ON (
			x.supplies_cd_n = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			AND eq.class_cd IN ( @eqIds )
		)
		LEFT OUTER JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'' )
	WHERE
		x.supplies_source_class = ''0''
		AND x.supplies_class = ''05''
		AND x.ind_rst_class = ''1'' UNION ALL--血液回路
	SELECT
		7 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
		eq.equipment_name AS NAME,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
		x
		INNER JOIN mst_equipment AS eq ON (
			x.supplies_cd_n = eq.equipment_cd
			AND eq.is_del = ''0''
			AND eq.is_disp = ''1''
			AND eq.class_cd IN ( @eqIds )
		)
		LEFT OUTER JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'' )
	WHERE
		x.supplies_source_class = ''0''
		AND x.supplies_class = ''00''
		AND x.ind_rst_class = ''1'' UNION ALL--透析液
	SELECT
		8 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
	CASE

			WHEN mdc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
		END AS kind,
		md.medicine_name AS NAME,
		CASE WHEN CAST ( x.receipt_value  AS DECIMAL ) = 0 THEN  CAST ( x.ind_rst_value AS DECIMAL )  ELSE  CAST ( x.receipt_value  AS DECIMAL ) END  AS Amount,
		CASE WHEN CAST ( x.receipt_value  AS DECIMAL ) = 0 THEN  COALESCE ( md.unit, '''' )  ELSE  COALESCE ( md.unit_second, '''' )  END AS Unit,
		md.in_hospital_cd_1,
		md.in_hospital_cd_2,
		md.in_hospital_cd_3,
		md.in_hospital_cd_4
	FROM
		x
		INNER JOIN mst_medicine AS md ON (
			CAST ( x.supplies_cd AS DECIMAL ) = md.medicine_cd
			AND md.is_del = ''0''
			AND md.is_disp = ''1''
			AND md.class_cd IN ( @medIds )
		)
		LEFT OUTER JOIN mst_medicine_class AS mdc ON ( md.class_cd = mdc.class_cd AND mdc.is_del = ''0'' AND mdc.is_disp = ''1'' )
	WHERE
		x.supplies_source_class = ''0''
		AND x.supplies_class = ''08''
		AND x.ind_rst_class = ''1'' UNION ALL--補液
	SELECT
		9 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
	CASE

			WHEN mdc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
		END AS kind,
		md.medicine_name AS NAME,
		CASE WHEN CAST ( x.receipt_value  AS DECIMAL ) = 0 THEN  CAST ( x.ind_rst_value AS DECIMAL )  ELSE  CAST ( x.receipt_value  AS DECIMAL ) END  AS Amount,
		CASE WHEN CAST ( x.receipt_value  AS DECIMAL ) = 0 THEN  COALESCE ( md.unit, '''' )  ELSE  COALESCE ( md.unit_second, '''' )  END AS Unit,
		md.in_hospital_cd_1,
		md.in_hospital_cd_2,
		md.in_hospital_cd_3,
		md.in_hospital_cd_4
	FROM
		x
		INNER JOIN mst_medicine AS md ON (
			x.supplies_cd_n = md.medicine_cd
			AND md.is_del = ''0''
			AND md.is_disp = ''1''
			AND md.class_cd IN ( @medIds )
		)
		LEFT OUTER JOIN mst_medicine_class AS mdc ON ( md.class_cd = mdc.class_cd AND mdc.is_del = ''0'' AND mdc.is_disp = ''1'' )
	WHERE
		x.supplies_source_class = ''0''
		AND x.supplies_class = ''09''
		AND x.ind_rst_class = ''1'' UNION ALL--抗凝固剤
	SELECT
		10 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
	CASE

			WHEN mdc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
		END AS kind,
		md.medicine_name AS NAME,
		CEIL (
			(
				( CAST ( x.ind_rst_value AS DECIMAL ) ) / ( CASE WHEN md.unit_converted_amount IS NULL OR md.unit_converted_amount = 0 THEN 1 ELSE md.unit_converted_amount END )
				) * md.unit_converted_amount_second
			) AS Amount,
			COALESCE ( md.unit_second, COALESCE ( md.unit, '''' ) ) AS Unit,
			md.in_hospital_cd_1,
			md.in_hospital_cd_2,
			md.in_hospital_cd_3,
			md.in_hospital_cd_4
		FROM
			x
			INNER JOIN mst_medicine AS md ON (
				x.supplies_cd_n = md.medicine_cd
				AND md.is_del = ''0''
				AND md.is_disp = ''1''
				AND md.class_cd IN ( @medIds )
			)
			LEFT OUTER JOIN mst_medicine_class AS mdc ON ( md.class_cd = mdc.class_cd AND mdc.is_del = ''0'' AND mdc.is_disp = ''1'' )
		WHERE
			x.supplies_source_class = ''0''
			AND x.supplies_class = ''10''
			AND x.ind_rst_class = ''1'' UNION ALL--抗凝固剤調製薬剤
		SELECT
			10 AS disp_order,
			x.treat_date,
			x.kur_cd,
			x.kur_name,
			COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
			x.pat_id,
		CASE

				WHEN mdc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
			END AS kind,
			mdx.medicine_mix_name AS NAME,
			CAST ( x.ind_rst_value AS DECIMAL ) AS Amount,
			COALESCE ( mdx.unit, '''' ) AS Unit,
			mdx.in_hospital_cd_1,
			mdx.in_hospital_cd_2,
			mdx.in_hospital_cd_3,
			NULL AS in_hospital_cd_4
		FROM
			x
			INNER JOIN mst_medicine_mix AS mdx ON mdx.medicine_mix_cd = TO_NUMBER( x.medicine_mix_cd, ''999999999999'' )
			LEFT OUTER JOIN mst_medicine_class AS mdc ON ( mdx.class_cd = mdc.class_cd AND mdc.is_del = ''0'' AND mdc.is_disp = ''1'' )
		WHERE
			x.supplies_source_class = ''0''
			AND x.supplies_class = ''17''
			AND x.ind_rst_class = ''1'' UNION ALL--投薬
		SELECT
			11 AS disp_order,
			x.treat_date,
			x.kur_cd,
			x.kur_name,
			COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
			x.pat_id,
		CASE

				WHEN mdc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
			END AS kind,
			md.medicine_name AS NAME,
			-- CAST ( COALESCE ( NULLIF ( regexp_replace( x.receipt_value, ''[^0-9.]+'', '''', ''g'' ), '''' ), ''0'' ) AS DECIMAL ) AS Amount,
			CASE WHEN CAST ( x.receipt_value  AS DECIMAL ) = 0 THEN  CAST ( x.ind_rst_value AS DECIMAL )  ELSE  CAST ( x.receipt_value  AS DECIMAL ) END  AS Amount,
      CASE WHEN CAST ( x.receipt_value  AS DECIMAL ) = 0 THEN  COALESCE ( md.unit, '''' )  ELSE  COALESCE ( md.unit_second, '''' )  END AS Unit,
			md.in_hospital_cd_1,
			md.in_hospital_cd_2,
			md.in_hospital_cd_3,
			md.in_hospital_cd_4
		FROM
			x
			INNER JOIN mst_medicine AS md ON TO_NUMBER( x.supplies_cd, ''99999999'' ) = md.medicine_cd
			AND md.is_del = ''0''
			AND md.is_disp = ''1''
			AND md.class_cd IN ( @medIds )
			LEFT JOIN mst_medicine_class AS mdc ON ( md.class_cd = mdc.class_cd AND mdc.is_del = ''0'' AND mdc.is_disp = ''1'' )
		WHERE
			x.supplies_source_class = ''1''
			AND x.supplies_class = ''12''
			AND x.ind_rst_class = ''1'' UNION ALL--投薬調製薬剤
		SELECT
			11 AS disp_order,
			x.treat_date,
			x.kur_cd,
			x.kur_name,
			COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
			x.pat_id,
		CASE

				WHEN mdc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
			END AS kind,
			md.medicine_mix_name AS NAME,
			CAST ( COALESCE ( NULLIF ( regexp_replace( x.receipt_value, ''[^0-9.]+'', '''', ''g'' ), '''' ), ''0'' ) AS DECIMAL ) AS Amount,
			COALESCE ( md.unit, '''' ) AS Unit,
			md.in_hospital_cd_1,
			md.in_hospital_cd_2,
			md.in_hospital_cd_3,
			NULL AS in_hospital_cd_4
		FROM
			x
			INNER JOIN mst_medicine_mix AS md ON ( TO_NUMBER( x.medicine_mix_cd, ''9999999999'' ) = md.medicine_mix_cd AND md.is_del = ''0'' AND md.is_disp = ''1'' AND md.class_cd IN ( @medIds ))
			LEFT JOIN mst_medicine_class AS mdc ON ( md.class_cd = mdc.class_cd AND mdc.is_del = ''0'' AND mdc.is_disp = ''1'' )
		WHERE
			x.supplies_source_class = ''1''
			AND x.supplies_class = ''13''
			AND x.ind_rst_class = ''1'' UNION ALL--医材
		SELECT
			12 AS disp_order,
			x.treat_date,
			x.kur_cd,
			x.kur_name,
			COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
			x.pat_id,
		CASE

				WHEN eqc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
			END AS kind,
			eq.equipment_name AS NAME,
			CAST ( COALESCE ( NULLIF ( regexp_replace( x.receipt_value, ''[^0-9.]+'', '''', ''g'' ), '''' ), ''0'' ) AS DECIMAL ) AS Amount,
			COALESCE ( eq.unit, '''' ) AS Unit,
			eq.in_hospital_cd_1,
			eq.in_hospital_cd_2,
			eq.in_hospital_cd_3,
			eq.in_hospital_cd_4
		FROM
			x
			INNER JOIN mst_equipment AS eq ON x.supplies_cd_n = eq.equipment_cd
			AND eq.class_cd IN ( @eqIds )
			LEFT JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'' )
		WHERE
			x.facility_cd = x.facility_cd
			AND x.supplies_source_class = ''2''
			AND x.ind_rst_class = ''1''
		) AS EquipmentList
	GROUP BY
		treat_date,
		kur_cd,
		kur_name,
		bed_name,
		pat_id,
		disp_order,
		kind,
		NAME,
		Unit,
		in_hospital_cd_1,
		in_hospital_cd_2,
		in_hospital_cd_3,
		in_hospital_cd_4
-- 	HAVING
-- 		SUM ( Amount ) > 0
	ORDER BY
		kur_cd,
		kur_name,
		bed_name,
		pat_id,
	disp_order,
	kind;', 2, '[{"preview": "1", "can_calc": "", "data_code": "kur_cd", "data_name": "クールコード", "data_type": "decimal", "conv_table": [], "data_class": "ベッド情報", "field_name": "kur_cd", "disp_format": "0", "data_category": "配布リスト(ベッド)", "facility_filter_type": ""}, {"preview": "午後", "can_calc": "", "data_code": "kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "kur_name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": ""}, {"preview": "北1", "can_calc": "", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "bed_name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": ""}, {"preview": "20200101", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "抽出条件", "field_name": "treat_date", "disp_format": "", "data_category": "印刷情報", "facility_filter_type": "0"}, {"preview": "123456789012", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "hosp_pat_id", "target_var": "@patId"}, "data_code": "hosp_pat_id", "data_name": "患者ID", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "pat_id", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "テスト患者1", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_name", "target_var": "@patId"}, "data_code": "pat_id_to_name", "data_name": "患者名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "pat_id_to_name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "医材・薬剤", "can_calc": "0", "data_code": "kind", "data_name": "分類名称", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "kind", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "テスト医材・薬剤1", "can_calc": "0", "data_code": "name", "data_name": "型番･名称", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "物品情報", "field_name": "amount", "disp_format": "0", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "個", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "unit", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_1", "data_name": "院内コード", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_1", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_2", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_3", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_4", "data_name": "院内コード4", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_4", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [5]}', '配布リスト(ベッド)', '2020-01-11 13:28:00', CURRENT_TIMESTAMP, NULL);
