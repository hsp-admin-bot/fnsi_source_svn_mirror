DELETE FROM "ntss"."sys_data_set" where sql_cd in (11,206,243,244,10,207);
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
		save.receipt_unit,
		save.ind_unit,
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
	class,
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
    ''ダイアライザ'' as class,
	CASE
    WHEN dz.model_number IS NOT NULL THEN
    ''ダイアライザ'' ELSE NULL
		END AS kind,
		dz.model_number AS NAME,
    CAST(NULLIF(x.ind_rst_value, '''') AS DECIMAL) AS Amount,
		COALESCE ( x.ind_unit, '''' ) AS Unit,
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
		AND x.supplies_class = ''01'' UNION ALL--吸着カラム
	SELECT
		2 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
		''吸着カラム'' as class,
    COALESCE(eqc.class_name, ''未分類'') AS kind,
		eq.equipment_name AS NAME,
    CAST(NULLIF(x.ind_rst_value, '''') AS DECIMAL) AS Amount,
		COALESCE ( x.ind_unit, '''' ) AS Unit,
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
		AND x.supplies_class = ''02'' UNION ALL--1次膜
	SELECT
		3 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
    ''1次膜'' as class,
    COALESCE(eqc.class_name, ''未分類'') AS kind,
		eq.equipment_name AS NAME,
    CAST(NULLIF(x.ind_rst_value, '''') AS DECIMAL) AS Amount,
		COALESCE ( x.ind_unit, '''' ) AS Unit,
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
		AND x.supplies_class = ''03'' UNION ALL--2次膜
	SELECT
		4 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
    ''2次膜'' as class,
    COALESCE(eqc.class_name, ''未分類'') AS kind,
		eq.equipment_name AS NAME,
    CAST(NULLIF(x.ind_rst_value, '''') AS DECIMAL) AS Amount,
		COALESCE ( x.ind_unit, '''' ) AS Unit,
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
		AND x.supplies_class = ''04'' UNION ALL--穿刺針(A針)
	SELECT
		5 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
    ''穿刺針(A)'' as class,
    COALESCE(eqc.class_name, ''未分類'') AS kind,
		eq.equipment_name AS NAME,
    CAST(NULLIF(x.ind_rst_value, '''') AS DECIMAL) AS Amount,
		COALESCE ( x.ind_unit, '''' ) AS Unit,
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
		)
	WHERE
		x.supplies_source_class = ''0''
		AND x.supplies_class = ''06'' UNION ALL--穿刺針(V針)
	SELECT
		5 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
    ''穿刺針(V)'' as class,
    COALESCE(eqc.class_name, ''未分類'') AS kind,
		eq.equipment_name AS NAME,
    CAST(NULLIF(x.ind_rst_value, '''') AS DECIMAL) AS Amount,
		COALESCE ( x.ind_unit, '''' ) AS Unit,
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
		AND x.supplies_class = ''07'' UNION ALL--穿刺針(SN)
	SELECT
		6 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
    ''シングルニードル'' as class,
    COALESCE(eqc.class_name, ''未分類'') AS kind,
		eq.equipment_name AS NAME,
    CAST(NULLIF(x.ind_rst_value, '''') AS DECIMAL) AS Amount,
		COALESCE ( x.ind_unit, '''' ) AS Unit,
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
		AND x.supplies_class = ''05'' UNION ALL--血液回路
	SELECT
		7 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
    ''血液回路'' as class,
    COALESCE(eqc.class_name, ''未分類'') AS kind,
		eq.equipment_name AS NAME,
    CAST(NULLIF(x.ind_rst_value, '''') AS DECIMAL) AS Amount,
		COALESCE ( x.ind_unit, '''' ) AS Unit,
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
		AND x.supplies_class = ''00'' UNION ALL--透析液
	SELECT
		8 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
    ''透析液'' as class,
    COALESCE(mdc.class_name, ''未分類'') AS kind,
		md.medicine_name AS NAME,
    CAST(NULLIF(x.receipt_value, '''') AS DECIMAL) AS Amount,
		COALESCE ( x.receipt_unit, '''' ) AS Unit,
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
		AND x.supplies_class = ''08'' UNION ALL--補液
	SELECT
		9 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
    ''補液'' as class,
    COALESCE(mdc.class_name, ''未分類'') AS kind,
		md.medicine_name AS NAME,
    CAST(NULLIF(x.receipt_value, '''') AS DECIMAL) AS Amount,
		COALESCE ( x.receipt_unit, '''' ) AS Unit,
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
		AND x.supplies_class = ''09'' UNION ALL--抗凝固剤
	SELECT
		10 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
    ''抗凝固剤'' as class,
    COALESCE(mdc.class_name, ''未分類'') AS kind,
		md.medicine_name AS NAME,
    CAST(
      CASE 
        WHEN NULLIF(x.receipt_value, '''') IS NULL 
             OR CAST(NULLIF(x.receipt_value, '''') AS DECIMAL) = 0 
        THEN NULLIF(x.ind_rst_value, '''') 
        ELSE NULLIF(x.receipt_value, '''') 
      END 
    AS DECIMAL) AS Amount,
    CASE 
      WHEN NULLIF(x.receipt_value, '''') IS NULL 
           OR CAST(NULLIF(x.receipt_value, '''') AS DECIMAL) = 0 
      THEN COALESCE(x.ind_unit, '''') 
      ELSE x.receipt_unit 
    END AS Unit,
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
			AND x.supplies_class = ''10'' UNION ALL--抗凝固剤調製薬剤
		SELECT
			10 AS disp_order,
			x.treat_date,
			x.kur_cd,
			x.kur_name,
			COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
			x.pat_id,
      ''抗凝固剤'' as class,
      COALESCE(mdc.class_name, ''未分類'') AS kind,
			mdx.medicine_mix_name AS NAME,
			--CAST ( x.ind_rst_value AS DECIMAL ) AS Amount,
			1 AS Amount,
			'''' AS Unit,
			mdx.in_hospital_cd_1,
			mdx.in_hospital_cd_2,
			mdx.in_hospital_cd_3,
			NULL AS in_hospital_cd_4
		FROM
			x
			INNER JOIN mst_medicine_mix AS mdx ON mdx.medicine_mix_cd = TO_NUMBER( x.medicine_mix_cd, ''999999999999'' )
			AND mdx.class_cd IN ( @medIds )
			LEFT OUTER JOIN mst_medicine_class AS mdc ON ( mdx.class_cd = mdc.class_cd AND mdc.is_del = ''0'' AND mdc.is_disp = ''1'' )
		WHERE
			x.supplies_source_class = ''0''
			AND x.supplies_class = ''17'' UNION ALL--投薬
		SELECT
			11 AS disp_order,
			x.treat_date,
			x.kur_cd,
			x.kur_name,
			COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
			x.pat_id,
      COALESCE(mdc.class_name, ''未分類'') AS class,
      COALESCE(mdc.class_name, ''未分類'') AS kind,
			md.medicine_name AS NAME,
      CAST(NULLIF(x.ind_rst_value, '''') AS DECIMAL) AS Amount,
      COALESCE ( x.ind_unit, '''' ) AS Unit,
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
			AND x.supplies_class = ''12'' UNION ALL--投薬調製薬剤
		SELECT
			11 AS disp_order,
			x.treat_date,
			x.kur_cd,
			x.kur_name,
			COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
			x.pat_id,
      COALESCE(mdc.class_name, ''未分類'') AS class,
      COALESCE(mdc.class_name, ''未分類'') AS kind,
			md.medicine_mix_name AS NAME,
			CAST(NULLIF(x.ind_rst_value, '''') AS DECIMAL) AS Amount,
			COALESCE ( x.ind_unit, '''' ) AS Unit,
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
			AND x.supplies_class = ''13'' UNION ALL--医材(ダイアライザ)
		SELECT
			12 AS disp_order,
			x.treat_date,
			x.kur_cd,
			x.kur_name,
			COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
			x.pat_id,
      ''ダイアライザ'' AS class,
      ''ダイアライザ'' AS kind,
      dz.model_number AS NAME,
			CAST(NULLIF(x.ind_rst_value, '''') AS DECIMAL) AS Amount,
      COALESCE ( x.ind_unit, '''' ) AS Unit,
			dz.in_hospital_cd_1,
			dz.in_hospital_cd_2,
			dz.in_hospital_cd_3,
			dz.in_hospital_cd_4
		FROM
			x
      INNER JOIN mst_dialyzer AS dz ON (x.supplies_cd_n = dz.dialyzer_cd AND dz.is_del = ''0'' AND dz.is_disp = ''1'' AND dz.dialyzer_cd IN ( @diaIds ))
		WHERE
			x.supplies_source_class = ''2''
      AND x.supplies_class = ''01'' UNION ALL--医材
		SELECT
			12 AS disp_order,
			x.treat_date,
			x.kur_cd,
			x.kur_name,
			COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
			x.pat_id,
      COALESCE(eqc.class_name, ''未分類'') AS class,
      COALESCE(eqc.class_name, ''未分類'') AS kind,
      eq.equipment_name AS NAME,
			CAST(NULLIF(x.ind_rst_value, '''') AS DECIMAL) AS Amount,
      COALESCE ( x.ind_unit, '''' ) AS Unit,
			eq.in_hospital_cd_1,
			eq.in_hospital_cd_2,
			eq.in_hospital_cd_3,
			eq.in_hospital_cd_4
		FROM
			x
      INNER JOIN mst_equipment AS eq ON (x.supplies_cd_n = eq.equipment_cd AND eq.is_del = ''0'' AND eq.is_disp = ''1'' AND eq.class_cd IN ( @eqIds ))
			LEFT JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'' )
		WHERE
			x.supplies_source_class = ''2''
      AND x.supplies_class = ''11''
		) AS EquipmentList
	GROUP BY
		treat_date,
		kur_cd,
		kur_name,
		bed_name,
		pat_id,
		disp_order,
		kind,
		class,
		NAME,
		Unit,
		in_hospital_cd_1,
		in_hospital_cd_2,
		in_hospital_cd_3,
		in_hospital_cd_4
	ORDER BY
		kur_cd,
		kur_name,
		bed_name,
		pat_id,
    disp_order,
    kind;', 2, '[{"preview": "1", "can_calc": "", "data_code": "kur_cd", "data_name": "クールコード", "data_type": "decimal", "conv_table": [], "data_class": "ベッド情報", "field_name": "kur_cd", "disp_format": "0", "data_category": "配布リスト(ベッド)", "facility_filter_type": ""}, {"preview": "午後", "can_calc": "", "data_code": "kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "kur_name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": ""}, {"preview": "北1", "can_calc": "", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "bed_name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": ""}, {"preview": "123456789012", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "hosp_pat_id", "target_var": "@patId"}, "data_code": "hosp_pat_id", "data_name": "患者ID", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "pat_id", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "テスト患者1", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_name", "target_var": "@patId"}, "data_code": "pat_id_to_name", "data_name": "患者名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "pat_id_to_name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "医材・薬剤", "can_calc": "0", "data_code": "kind", "data_name": "分類名称", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "kind", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "ダイアライザ", "can_calc": "0", "data_code": "class", "data_name": "治療条件名", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "class", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "テスト医材・薬剤1", "can_calc": "0", "data_code": "name", "data_name": "型番･名称", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "物品情報", "field_name": "amount", "disp_format": "0", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "個", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "unit", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_1", "data_name": "院内コード", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_1", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_2", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_3", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_4", "data_name": "院内コード4", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_4", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [5]}', '配布リスト(ベッド)', '2024-11-22 16:21:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (11, 'WITH 
save AS (
	SELECT
		om.*,
		save.supplies_base_date,
		save.supplies_source_class,
		save.supplies_class,
		save.ind_rst_class,
		save.supplies_cd,
		save.receipt_value,
		save.ind_rst_value,
		save.medicine_mix_cd,
		save.receipt_unit,
		save.ind_unit,
		TO_NUMBER( save.supplies_cd, ''9999999999'' ) supplies_cd_n,
		kr.kur_cd,
		kr.kur_name,
		bd.bed_cd,
		bd.bed_name
	FROM
		ord_main AS om
		INNER JOIN ord_material_save AS save ON ( om.ord_no = save.supplies_base_no AND om.facility_cd = save.facility_cd AND save.ind_rst_class = ''1'' )
		LEFT OUTER JOIN mst_kur AS kr ON ( om.ind_kur_cd = kr.kur_cd AND kr.is_del = ''0'' )
		LEFT OUTER JOIN mst_bed AS bd ON ( om.ind_bed_cd = bd.bed_cd AND bd.is_del = ''0'' AND bd.is_disp = ''1'' )
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.is_del = ''0''
	),
dz AS ( SELECT * FROM mst_dialyzer mst WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' ),
kr AS ( SELECT * FROM mst_kur mst WHERE facility_cd = @facilityCd AND is_del = ''0'' ),
bd AS ( SELECT * FROM mst_bed mst WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' ),
eq AS ( SELECT * FROM mst_equipment mst WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' ),
eqc AS ( SELECT * FROM mst_equipment_class mst WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' ),
md AS ( SELECT * FROM mst_medicine mst WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' ),
mdx AS ( SELECT * FROM mst_medicine_mix mst WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' ),
mdc AS ( SELECT * FROM mst_medicine_class mst WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' ) ,
		medic AS (
	SELECT
		index_no AS medic_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medic_code,
		order_cd ->> ''name'' AS medi_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicine_class''
	),equic AS (
	SELECT
		index_no AS equic_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS equic_code,
		order_cd ->> ''name'' AS equic_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_equipment_class''
	),medi_mix AS (
	SELECT
		index_no AS medi_mix_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_mix_code,
		order_cd ->> ''name'' AS medi_mix_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicine_class''
	),dia AS (
	SELECT
		index_no AS dia_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS dia_code,
		order_cd ->> ''name'' AS equi_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_dialyzer''
	)
, bed_sort AS (
	SELECT
		index_no AS bed_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS bed_code,
		order_cd ->> ''name'' AS bed_sort_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_bed''
),
	result_all as (
	SELECT
to_timestamp( treat_date, ''YYYYMMDD'' ) AS treat_date,
disp_order,
kind,
class_cd,
class,
class_data_order,
do_action,
NAME,
code,
kur_cd,
kur_name,
Amount AS amount,
unit,
bed_cd,
bed_name,
pat_id,
pat_id AS pat_id1,
in_hospital_cd_1,
in_hospital_cd_2,
in_hospital_cd_3,
in_hospital_cd_4,
data_type_order,
kind_order,
dia.dia_order,
medic.medic_order,
equic.equic_order,
medi_mix.medi_mix_order,
bed.bed_order
FROM
	(
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 3
         WHEN @dataTypeOrder = ''2'' THEN 1
         WHEN @dataTypeOrder = ''3'' THEN 1
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 3
         ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''ダイアライザ'' AS class,
		1 as class_data_order,
	CASE

			WHEN dz.model_number IS NOT NULL THEN
			''ダイアライザ'' ELSE NULL
		END AS kind,
	    ''0'' AS class_cd,
			''ダイアライザ'' AS do_action, 
		dz.model_number AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
    CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
		COALESCE ( save.ind_unit, '''' ) AS Unit,
		dz.in_hospital_cd_1,
		dz.in_hospital_cd_2,
		dz.in_hospital_cd_3,
		dz.in_hospital_cd_4,
		''医療材料'' AS data_type_order,
		2 AS kind_order,
		NULL AS equipment_cd,
		NULL AS equipment_class_cd,
		NULL AS medicine_cd,
		NULL AS medicine_class_cd,
		dz.dialyzer_cd
	FROM
		save
		INNER JOIN dz ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = dz.dialyzer_cd
		AND dz.dialyzer_cd IN ( @diaIds )
	WHERE
		save.supplies_source_class = ''0''
		and save.supplies_class = ''01''
	UNION ALL--吸着カラム
	SELECT
				CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 3
         WHEN @dataTypeOrder = ''2'' THEN 1
         WHEN @dataTypeOrder = ''3'' THEN 1
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 3
         ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''吸着カラム'' AS class,
		3 as class_data_order,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
	CASE
			WHEN eqc.class_name IS NULL THEN
			''-1'' ELSE eqc.class_cd
		END AS class_cd,
		''医材'' AS do_action, 
		eq.equipment_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
		1 AS Amount,
		COALESCE ( save.ind_unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4,
		''医療材料'' AS data_type_order,
		1 AS kind_order,
		eq.equipment_cd AS equipment_cd,
		eqc.class_cd AS equipment_class_cd,
		NULL AS medicine_cd,
		NULL AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
	WHERE
		save.supplies_source_class = ''0''
		and save.supplies_class = ''02''
	UNION ALL--1次膜
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 3
         WHEN @dataTypeOrder = ''2'' THEN 1
         WHEN @dataTypeOrder = ''3'' THEN 1
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 3
         ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''1次膜'' AS class,
		4 as class_data_order,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
    CASE
			WHEN eqc.class_name IS NULL THEN
			''-1'' ELSE eqc.class_cd
		END AS class_cd,
		''医材'' AS do_action, 
		eq.equipment_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
		1 AS Amount,
		COALESCE ( save.ind_unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4,
		''医療材料'' AS data_type_order,
		1 AS kind_order,
		eq.equipment_cd AS equipment_cd,
		eqc.class_cd AS equipment_class_cd,
		NULL AS medicine_cd,
		NULL AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
	WHERE
		save.supplies_source_class = ''0''
		and save.supplies_class = ''03''
	UNION ALL--2次膜
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 3
         WHEN @dataTypeOrder = ''2'' THEN 1
         WHEN @dataTypeOrder = ''3'' THEN 1
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 3
         ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''2次膜'' AS class,
		5 as class_data_order,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
    CASE
			WHEN eqc.class_name IS NULL THEN
			''-1'' ELSE eqc.class_cd
		END AS class_cd,
		''医材'' AS do_action, 
		eq.equipment_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
		1 AS Amount,
		COALESCE ( save.ind_unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4,
		''医療材料'' AS data_type_order,
		1 AS kind_order,
		eq.equipment_cd AS equipment_cd,
		eqc.class_cd AS equipment_class_cd,
		NULL AS medicine_cd,
		NULL AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
	WHERE
		save.supplies_source_class = ''0''
		and save.supplies_class = ''04''
	UNION ALL--穿刺針(A針)
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 3
         WHEN @dataTypeOrder = ''2'' THEN 1
         WHEN @dataTypeOrder = ''3'' THEN 1
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 3
         ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''穿刺針(A)'' AS class,
		7 as class_data_order,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
    CASE
			WHEN eqc.class_name IS NULL THEN
			''-1'' ELSE eqc.class_cd
		END AS class_cd,
		''医材'' AS do_action, 
		eq.equipment_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
		1 AS Amount,
		COALESCE ( save.ind_unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4,
		''医療材料'' AS data_type_order,
		1 AS kind_order,
		eq.equipment_cd AS equipment_cd,
		eqc.class_cd AS equipment_class_cd,
		NULL AS medicine_cd,
		NULL AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' )  = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
	WHERE
		save.supplies_source_class = ''0''
		and save.supplies_class = ''06''
	UNION ALL--穿刺針(V針)
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 3
         WHEN @dataTypeOrder = ''2'' THEN 1
         WHEN @dataTypeOrder = ''3'' THEN 1
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 3
         ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''穿刺針(V)'' AS class,
		8 as class_data_order,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
    CASE
			WHEN eqc.class_name IS NULL THEN
			''-1'' ELSE eqc.class_cd
		END AS class_cd,
		''医材'' AS do_action, 
		eq.equipment_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
		1 AS Amount,
		COALESCE ( save.ind_unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4,
		''医療材料'' AS data_type_order,
		1 AS kind_order,
		eq.equipment_cd AS equipment_cd,
		eqc.class_cd AS equipment_class_cd,
		NULL AS medicine_cd,
		NULL AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
	WHERE
		save.supplies_source_class = ''0''
		and save.supplies_class = ''07''
	UNION ALL--穿刺針(SN)
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 3
         WHEN @dataTypeOrder = ''2'' THEN 1
         WHEN @dataTypeOrder = ''3'' THEN 1
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 3
         ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''シングルニードル'' AS class,
		6 as class_data_order,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''''''' )
		END AS kind,
    CASE
			WHEN eqc.class_name IS NULL THEN
			''-1'' ELSE eqc.class_cd
		END AS class_cd,
		''医材'' AS do_action, 
		eq.equipment_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
		1 AS Amount,
		COALESCE ( save.ind_unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4,
		''医療材料'' AS data_type_order,
		1 AS kind_order,
		eq.equipment_cd AS equipment_cd,
		eqc.class_cd AS equipment_class_cd,
		NULL AS medicine_cd,
		NULL AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
	WHERE
		save.supplies_source_class = ''0''
		and save.supplies_class = ''05''
	UNION ALL--血液回路
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 3
         WHEN @dataTypeOrder = ''2'' THEN 1
         WHEN @dataTypeOrder = ''3'' THEN 1
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 3
         ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''血液回路'' AS class,
		2 as class_data_order,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
    CASE
			WHEN eqc.class_name IS NULL THEN
			''-1'' ELSE eqc.class_cd
		END AS class_cd,
		''医材'' AS do_action, 
		eq.equipment_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
		1 AS Amount,
		COALESCE ( save.ind_unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4,
		''医療材料'' AS data_type_order,
		1 AS kind_order,
		eq.equipment_cd AS equipment_cd,
		eqc.class_cd AS equipment_class_cd,
		NULL AS medicine_cd,
		NULL AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
	WHERE
		save.supplies_source_class = ''0''
		and save.supplies_class = ''00''
	UNION ALL--医材
	(SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
			WHEN @dataTypeOrder = ''1'' THEN 3
			WHEN @dataTypeOrder = ''2'' THEN 1
			WHEN @dataTypeOrder = ''3'' THEN 1
			WHEN @dataTypeOrder = ''4'' THEN 2
			WHEN @dataTypeOrder = ''5'' THEN 3
			ELSE 1  END AS disp_order
		, treat_date
		, kur_cd
		, kur_name
		, bed_cd
		, bed_name
		, pat_id
		, class
		, class_data_order
		, kind
		, class_cd
		, ''医材'' AS do_action
		, NAME
		, code
		, SUM(equInfo.ind_rst_value) AS Amount
		, Unit
		, in_hospital_cd_1
		, in_hospital_cd_2
		, in_hospital_cd_3
		, in_hospital_cd_4
		, ''医療材料'' AS data_type_order
		,	1 AS kind_order
		, code AS equipment_cd
		, class_cd AS equipment_class_cd
		, NULL AS medicine_cd
		, NULL AS medicine_class_cd
		, NULL AS dialyzer_cd
	FROM (
		SELECT
			save.supplies_base_date as treat_date,
			save.kur_cd,
			COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
			save.bed_cd,
			COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
			save.pat_id,
			CASE
				WHEN eqc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
				END AS class,
				12 as class_data_order,
			CASE
				WHEN eqc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
				END AS kind,
			CASE
				WHEN eqc.class_name IS NULL THEN
				''-1'' ELSE eqc.class_cd
				END AS class_cd,
			eq.equipment_name AS NAME,
			TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
			CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS ind_rst_value ,
      COALESCE ( save.ind_unit, '''' ) AS Unit,
			eq.in_hospital_cd_1,
			eq.in_hospital_cd_2,
			eq.in_hospital_cd_3,
			eq.in_hospital_cd_4
		FROM
			save
			INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = eq.equipment_cd
			AND eq.class_cd IN ( @eqIds )
			LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		WHERE
			save.supplies_source_class = ''2''
      and save.supplies_class = ''11''
		UNION ALL -- ダイアライザ（医材）
		SELECT
			save.supplies_base_date as treat_date,
			save.kur_cd,
			COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
			save.bed_cd,
			COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
			save.pat_id,
			''ダイアライザ'' AS class,
			12 as class_data_order,
			CASE WHEN dz.model_number IS NOT NULL THEN
			''ダイアライザ'' ELSE NULL
		   END AS kind,
			''0'' AS class_cd,
			dz.model_number NAME,
			TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
			CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS ind_rst_value ,
      COALESCE ( save.ind_unit, '''' ) AS Unit,
			dz.in_hospital_cd_1,
			dz.in_hospital_cd_2,
			dz.in_hospital_cd_3,
			dz.in_hospital_cd_4
		FROM
			save
			INNER JOIN dz ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = dz.dialyzer_cd
		  AND dz.dialyzer_cd IN ( @diaIds )
	  WHERE
		save.supplies_source_class = ''2''
		and save.supplies_class = ''01''	
	) equInfo
	GROUP BY
		treat_date,
		kind,
		class_cd,
		class,
		class_data_order,
		do_action,
		NAME,
		code,
		kur_cd,
		kur_name,
		bed_cd,
		bed_name,
		Unit,
		pat_id,
		disp_order,
		in_hospital_cd_1,
		in_hospital_cd_2,
		in_hospital_cd_3,
		in_hospital_cd_4,
		data_type_order,
		kind_order
	ORDER BY
		disp_order,
		kind,
		class_cd,
		do_action,
		data_type_order,
		kind_order,
		code,
		NAME,
		kur_cd,
		kur_name,
		bed_cd,
		bed_name,
		pat_id
	)
	UNION ALL--抗凝固剤
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 3
			WHEN @dataTypeOrder = ''1'' THEN 2
			WHEN @dataTypeOrder = ''2'' THEN 2
			WHEN @dataTypeOrder = ''3'' THEN 3
			WHEN @dataTypeOrder = ''4'' THEN 1
			WHEN @dataTypeOrder = ''5'' THEN 1
			ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''抗凝固剤'' AS class,
		9 as class_data_order,
		CASE
			WHEN mdc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
			END AS kind,
    CASE
			WHEN mdc.class_name IS NULL THEN
			''-1'' ELSE mdc.class_cd
			END AS class_cd,
		''通常薬剤'' AS do_action, 
		md.medicine_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
    CAST(
      CASE 
        WHEN NULLIF(save.receipt_value, '''') IS NULL 
             OR CAST(NULLIF(save.receipt_value, '''') AS DECIMAL) = 0 
        THEN NULLIF(save.ind_rst_value, '''') 
        ELSE NULLIF(save.receipt_value, '''') 
      END 
    AS DECIMAL) AS Amount,
    CASE 
      WHEN NULLIF(save.receipt_value, '''') IS NULL 
           OR CAST(NULLIF(save.receipt_value, '''') AS DECIMAL) = 0 
      THEN COALESCE(save.ind_unit, '''') 
      ELSE save.receipt_unit 
    END AS Unit,
		md.in_hospital_cd_1,
		md.in_hospital_cd_2,
		md.in_hospital_cd_3,
		md.in_hospital_cd_4,
		''薬剤'' AS data_type_order,
		1 AS kind_order,
		NULL AS equipment_cd,
		NULL AS equipment_class_cd,
		md.medicine_cd :: TEXT AS medicine_cd,
		mdc.class_cd :: TEXT AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN md ON TO_NUMBER( save.supplies_cd, ''99999999'' ) = md.medicine_cd
		AND md.class_cd IN ( @medIds )
		LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
	WHERE
	  save.supplies_source_class = ''0''
		and save.supplies_class = ''10''
	UNION ALL--抗凝固剤調製薬剤
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 3
         WHEN @dataTypeOrder = ''1'' THEN 2
         WHEN @dataTypeOrder = ''2'' THEN 2
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 1
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''抗凝固剤'' AS class,
		9 as class_data_order,
		CASE
			WHEN mdc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
		END AS kind,
    CASE
			WHEN mdc.class_name IS NULL THEN
			''-1'' ELSE mdc.class_cd
		END AS class_cd,		
		''調製薬剤'' AS do_action, 
		mdx.medicine_mix_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
		1 AS Amount,
		'''' AS Unit,
		mdx.in_hospital_cd_1,
		mdx.in_hospital_cd_2,
		mdx.in_hospital_cd_3,
		null as in_hospital_cd_4,
		''薬剤'' AS data_type_order,
		2 AS kind_order,
		NULL AS equipment_cd,
		NULL AS equipment_class_cd,
		mdx.medicine_mix_cd :: TEXT AS medicine_cd,
		mdc.class_cd :: TEXT AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
	  save
		INNER JOIN mdx ON mdx.medicine_mix_cd = TO_NUMBER( save.medicine_mix_cd, ''999999999999'' )
		AND mdx.class_cd IN ( @medIds )
		LEFT OUTER JOIN mdc ON mdx.class_cd = mdc.class_cd
	WHERE
	  save.supplies_source_class = ''0''
		and save.supplies_class = ''17''
	UNION ALL--透析液
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 3
         WHEN @dataTypeOrder = ''1'' THEN 2
         WHEN @dataTypeOrder = ''2'' THEN 2
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 1
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''透析液'' AS class,
		10 as class_data_order,
	CASE

			WHEN mdc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
		END AS kind,
    CASE
			WHEN mdc.class_name IS NULL THEN
			''-1'' ELSE mdc.class_cd
		END AS class_cd,
		''通常薬剤'' AS do_action, 
		md.medicine_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
		CAST ( save.receipt_value AS DECIMAL )  AS Amount,
		COALESCE ( save.receipt_unit, '''' ) AS Unit,
		md.in_hospital_cd_1,
		md.in_hospital_cd_2,
		md.in_hospital_cd_3,
		md.in_hospital_cd_4,
		''薬剤'' AS data_type_order,
		1 AS kind_order,
		NULL AS equipment_cd,
		NULL AS equipment_class_cd,
		md.medicine_cd :: TEXT AS medicine_cd,
		mdc.class_cd :: TEXT AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN md ON TO_NUMBER( save.supplies_cd, ''99999999'' )  = md.medicine_cd
		AND md.class_cd IN ( @medIds )
		LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
		WHERE
	  save.supplies_source_class = ''0''
		and save.supplies_class = ''08''
	UNION ALL--補液
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 3
         WHEN @dataTypeOrder = ''1'' THEN 2
         WHEN @dataTypeOrder = ''2'' THEN 2
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 1
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''補液'' AS class,
		11 as class_data_order,
	CASE

			WHEN mdc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
		END AS kind,
    CASE
			WHEN mdc.class_name IS NULL THEN
			''-1'' ELSE mdc.class_cd
		END AS class_cd,
		''通常薬剤'' AS do_action, 
		md.medicine_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
		CAST ( save.receipt_value AS DECIMAL )  AS Amount,
		COALESCE ( save.receipt_unit, '''' ) AS Unit,
		md.in_hospital_cd_1,
		md.in_hospital_cd_2,
		md.in_hospital_cd_3,
		md.in_hospital_cd_4,
		''薬剤'' AS data_type_order,
		1 AS kind_order,
		NULL AS equipment_cd,
		NULL AS equipment_class_cd,
		md.medicine_cd :: TEXT AS medicine_cd,
		mdc.class_cd :: TEXT AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN md ON TO_NUMBER( save.supplies_cd, ''99999999'' )  = md.medicine_cd
		AND md.class_cd IN ( @medIds )
		LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
	WHERE
	  save.supplies_source_class = ''0''
		and save.supplies_class = ''09''
	UNION ALL--投薬
	(SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 3
			WHEN @dataTypeOrder = ''1'' THEN 2
			WHEN @dataTypeOrder = ''2'' THEN 2
			WHEN @dataTypeOrder = ''3'' THEN 3
			WHEN @dataTypeOrder = ''4'' THEN 1
			WHEN @dataTypeOrder = ''5'' THEN 1
			ELSE 1  END AS disp_order
		, treat_date
		, kur_cd
		, kur_name
		, bed_cd
		, bed_name
		, pat_id
		, class
		, class_data_order
		, kind
		, class_cd
		, ''通常薬剤'' AS do_action
		, NAME
		, code
		, SUM(medInfo.ind_rst_value) AS Amount
		, Unit
		, in_hospital_cd_1
		, in_hospital_cd_2
		, in_hospital_cd_3
		, in_hospital_cd_4
		, ''薬剤'' AS data_type_order
		,	1 AS kind_order
		, NULL AS equipment_cd
		, NULL AS equipment_class_cd
		, code::TEXT AS medicine_cd
		, class_cd::TEXT AS medicine_class_cd
		, NULL AS dialyzer_cd
	FROM (
		SELECT
			save.supplies_base_date as treat_date,
			save.kur_cd,
			COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
			save.bed_cd,
			COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
			save.pat_id,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS class,
				13 as class_data_order,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS kind,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''-1'' ELSE mdc.class_cd
				END AS class_cd,
			md.medicine_name AS NAME,
			TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
			CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS ind_rst_value ,
			COALESCE ( save.ind_unit, '''' ) AS Unit,
			md.in_hospital_cd_1,
			md.in_hospital_cd_2,
			md.in_hospital_cd_3,
			md.in_hospital_cd_4
		FROM
			save
			INNER JOIN md ON TO_NUMBER( save.supplies_cd, ''99999999'' ) = md.medicine_cd
			AND md.class_cd IN ( @medIds )
			LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
		WHERE
			save.supplies_source_class = ''1''
		and save.supplies_class = ''12''
	) medInfo
	GROUP BY
		treat_date,
		kind,
		class_cd,
		class,
		class_data_order,
		do_action,
		NAME,
		code,
		kur_cd,
		kur_name,
		bed_cd,
		bed_name,
		Unit,
		pat_id,
		disp_order,
		in_hospital_cd_1,
		in_hospital_cd_2,
		in_hospital_cd_3,
		in_hospital_cd_4,
		data_type_order,
		kind_order
	ORDER BY
		disp_order,
		kind,
		class_cd,
		do_action,
		data_type_order,
		kind_order,
		code,
		NAME,
		kur_cd,
		kur_name,
		bed_cd,
		bed_name,
		pat_id
	)
	UNION ALL--投薬調製薬剤
	(SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 3
			WHEN @dataTypeOrder = ''1'' THEN 2
			WHEN @dataTypeOrder = ''2'' THEN 2
			WHEN @dataTypeOrder = ''3'' THEN 3
			WHEN @dataTypeOrder = ''4'' THEN 1
			WHEN @dataTypeOrder = ''5'' THEN 1
			ELSE 1  END AS disp_order
		, treat_date
		, kur_cd
		, kur_name
		, bed_cd
		, bed_name
		, pat_id
		, class
		, class_data_order
		, kind
		, class_cd
		, ''調製薬剤'' AS do_action
		, NAME
		, code
		, SUM(medInfo.ind_rst_value) AS Amount
		, Unit
		, in_hospital_cd_1
		, in_hospital_cd_2
		, in_hospital_cd_3
		, in_hospital_cd_4
		, ''薬剤'' AS data_type_order
		,	2 AS kind_order
		, NULL AS equipment_cd
		, NULL AS equipment_class_cd
		, code::TEXT AS medicine_cd
		, class_cd::TEXT AS medicine_class_cd
		, NULL AS dialyzer_cd
	FROM (
		SELECT
			save.supplies_base_date as treat_date,
			save.kur_cd,
			COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
			save.bed_cd,
			COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
			save.pat_id,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS class,
				14 as class_data_order,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS kind,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''-1'' ELSE mdc.class_cd
				END AS class_cd,
			mdx.medicine_mix_name AS NAME,
			TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
			CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS ind_rst_value ,
			COALESCE ( save.ind_unit, '''' ) AS Unit,
			mdx.in_hospital_cd_1,
			mdx.in_hospital_cd_2,
			mdx.in_hospital_cd_3,
			null as in_hospital_cd_4
		FROM
			save
			INNER JOIN mdx ON TO_NUMBER(save.medicine_mix_cd, ''99999999'' ) = mdx.medicine_mix_cd
			AND mdx.class_cd IN ( @medIds )
			LEFT OUTER JOIN mdc ON mdx.class_cd = mdc.class_cd
		WHERE
			save.supplies_source_class = ''1''
		and save.supplies_class = ''13''
	) medInfo
	GROUP BY
		treat_date,
		kind,
		class_cd,
		class,
		class_data_order,
		do_action,
		NAME,
		code,
		kur_cd,
		kur_name,
		bed_cd,
		bed_name,
		Unit,
		pat_id,
		disp_order,
		in_hospital_cd_1,
		in_hospital_cd_2,
		in_hospital_cd_3,
		in_hospital_cd_4,
		data_type_order,
		kind_order
	ORDER BY
		disp_order,
		kind,
		class_cd,
		do_action,
		data_type_order,
		kind_order,
		code,
		NAME,
		kur_cd,
		kur_name,
		bed_cd,
		bed_name,
		pat_id
	)
	) AS EquipmentList
	LEFT OUTER JOIN medic ON medic.medic_code :: TEXT = EquipmentList.medicine_class_cd
	LEFT OUTER JOIN equic ON equic.equic_code = EquipmentList.equipment_class_cd
	LEFT OUTER JOIN dia ON dia.dia_code = EquipmentList.dialyzer_cd
	LEFT OUTER JOIN medi_mix ON medi_mix.medi_mix_code :: TEXT = EquipmentList.medicine_class_cd
	LEFT OUTER JOIN bed_sort AS bed ON bed.bed_code = EquipmentList.bed_cd
) 
SELECT * from result_all as res @orderBy, bed_order ASC
', 2, '[{"preview": "1", "can_calc": "", "data_code": "kur_cd", "data_name": "クールコード", "data_type": "decimal", "conv_table": [], "data_class": "ベッド情報", "field_name": "kur_cd", "disp_format": "0", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": ""}, {"preview": "午後", "can_calc": "", "data_code": "kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "kur_name", "disp_format": "", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": ""}, {"preview": "北1", "can_calc": "", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "bed_name", "disp_format": "", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": ""}, {"preview": "テープ", "can_calc": "0", "data_code": "kind", "data_name": "分類名称", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "kind", "disp_format": "", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ダイアライザ", "can_calc": "0", "data_code": "class", "data_name": "治療条件名", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "class", "disp_format": "", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70%ブドウ糖注射液350ml", "can_calc": "0", "data_code": "name", "data_name": "型番･名称", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "name", "disp_format": "", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "1", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "物品情報", "field_name": "amount", "disp_format": "0.00", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "個", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "unit", "disp_format": "", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789012", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "hosp_pat_id", "target_var": "@patId"}, "data_code": "hosp_pat_id", "data_name": "患者ID", "data_type": "string", "conv_table": [], "data_class": "基本情報", "field_name": "pat_id", "disp_format": "", "data_category": "配布リスト(物品)", "facility_filter_type": "0"}, {"preview": "テスト患者1", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_name", "target_var": "@patId"}, "data_code": "pat_name", "data_name": "患者名", "data_type": "string", "conv_table": [], "data_class": "基本情報", "field_name": "pat_id1", "disp_format": "", "data_category": "配布リスト(物品)", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [6]}', '配布リスト(物品)', '2024-11-22 16:21:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (206, 'WITH 
save AS (
	SELECT
		om.*,
		save.supplies_base_date,
		save.supplies_source_class,
		save.supplies_class,
		save.ind_rst_class,
		save.supplies_cd,
		save.receipt_value,
		save.ind_rst_value,
		save.medicine_mix_cd,
		save.receipt_unit,
		save.ind_unit,
		TO_NUMBER( save.supplies_cd, ''9999999999'' ) supplies_cd_n,
		kr.kur_cd,
		kr.kur_name,
		bd.bed_cd,
		bd.bed_name
	FROM
		ord_main AS om
		INNER JOIN ord_material_save AS save ON ( om.ord_no = save.supplies_base_no AND om.facility_cd = save.facility_cd AND save.ind_rst_class = ''1'' )
		LEFT OUTER JOIN mst_kur AS kr ON ( om.ind_kur_cd = kr.kur_cd AND kr.is_del = ''0'' )
		LEFT OUTER JOIN mst_bed AS bd ON ( om.ind_bed_cd = bd.bed_cd AND bd.is_del = ''0'' AND bd.is_disp = ''1'' )
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.is_del = ''0''
	),
dz AS ( SELECT * FROM mst_dialyzer mst WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' ),
kr AS ( SELECT * FROM mst_kur mst WHERE facility_cd = @facilityCd AND is_del = ''0'' ),
bd AS ( SELECT * FROM mst_bed mst WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' ),
eq AS ( SELECT * FROM mst_equipment mst WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' ),
eqc AS ( SELECT * FROM mst_equipment_class mst WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' ),
md AS ( SELECT * FROM mst_medicine mst WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' ),
mdx AS ( SELECT * FROM mst_medicine_mix mst WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' ),
mdc AS ( SELECT * FROM mst_medicine_class mst WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' ) ,
		medic AS (
	SELECT
		index_no AS medic_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medic_code,
		order_cd ->> ''name'' AS medi_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicine_class''
	),equic AS (
	SELECT
		index_no AS equic_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS equic_code,
		order_cd ->> ''name'' AS equic_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_equipment_class''
	),medi_mix AS (
	SELECT
		index_no AS medi_mix_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_mix_code,
		order_cd ->> ''name'' AS medi_mix_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicine_class''
	),dia AS (
	SELECT
		index_no AS dia_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS dia_code,
		order_cd ->> ''name'' AS equi_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_dialyzer''
	)
, bed_sort AS (
	SELECT
		index_no AS bed_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS bed_code,
		order_cd ->> ''name'' AS bed_sort_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_bed''
),
	result_all as (
	SELECT
	disp_order,
to_timestamp( treat_date, ''YYYYMMDD'' ) AS treat_date,
kind,
class,
class_data_order,
class_cd,
do_action,
NAME,
code,
kur_cd,
kur_name,
Amount AS amount,
unit,
bed_cd,
bed_name,
pat_id,
pat_id AS pat_id1,
in_hospital_cd_1,
in_hospital_cd_2,
in_hospital_cd_3,
in_hospital_cd_4,
data_type_order,
kind_order,
dia.dia_order,
medic.medic_order,
equic.equic_order,
medi_mix.medi_mix_order,
bed.bed_order
FROM
	(
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 3
         WHEN @dataTypeOrder = ''2'' THEN 1
         WHEN @dataTypeOrder = ''3'' THEN 1
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 3
         ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''ダイアライザ'' AS class,
		1 as class_data_order,
	CASE

			WHEN dz.model_number IS NOT NULL THEN
			''ダイアライザ'' ELSE NULL
		END AS kind,
		''0'' AS class_cd,
		''ダイアライザ'' AS do_action, 
		dz.model_number AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
    CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
		COALESCE ( save.ind_unit, '''' ) AS Unit,
		dz.in_hospital_cd_1,
		dz.in_hospital_cd_2,
		dz.in_hospital_cd_3,
		dz.in_hospital_cd_4,
		''医療材料'' AS data_type_order,
		2 AS kind_order,
		NULL AS equipment_cd,
		NULL AS equipment_class_cd,
		NULL AS medicine_cd,
		NULL AS medicine_class_cd,
		dz.dialyzer_cd
	FROM
		save
		INNER JOIN dz ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = dz.dialyzer_cd
		AND dz.dialyzer_cd IN ( @diaIds )
	WHERE
		save.supplies_source_class = ''0''
		and save.supplies_class = ''01''
	UNION ALL--吸着カラム
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 3
         WHEN @dataTypeOrder = ''2'' THEN 1
         WHEN @dataTypeOrder = ''3'' THEN 1
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 3
         ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''吸着カラム'' AS class,
		3 as class_data_order,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
	CASE
			WHEN eqc.class_name IS NULL THEN
			''-1'' ELSE eqc.class_cd
		END AS class_cd,
		''医材'' AS do_action, 
		eq.equipment_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
		CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
		COALESCE ( save.ind_unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4,
		''医療材料'' AS data_type_order,
		1 AS kind_order,
		eq.equipment_cd AS equipment_cd,
		eqc.class_cd AS equipment_class_cd,
		NULL AS medicine_cd,
		NULL AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
	WHERE
		save.supplies_source_class = ''0''
		and save.supplies_class = ''02''
	UNION ALL--1次膜
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 3
         WHEN @dataTypeOrder = ''2'' THEN 1
         WHEN @dataTypeOrder = ''3'' THEN 1
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 3
         ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''1次膜'' AS class,
		4 as class_data_order,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
			CASE
			WHEN eqc.class_name IS NULL THEN
			''-1'' ELSE eqc.class_cd
		END AS class_cd,
		''医材'' AS do_action,
		eq.equipment_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
		CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
		COALESCE ( save.ind_unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4,
		''医療材料'' AS data_type_order,
		1 AS kind_order,
		eq.equipment_cd AS equipment_cd,
		eqc.class_cd AS equipment_class_cd,
		NULL AS medicine_cd,
		NULL AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
	WHERE
		save.supplies_source_class = ''0''
		and save.supplies_class = ''03''
	UNION ALL--2次膜
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 3
         WHEN @dataTypeOrder = ''2'' THEN 1
         WHEN @dataTypeOrder = ''3'' THEN 1
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 3
         ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''2次膜'' AS class,
		5 as class_data_order,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
			CASE
			WHEN eqc.class_name IS NULL THEN
			''-1'' ELSE eqc.class_cd
		END AS class_cd,
		''医材'' AS do_action,
		eq.equipment_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
		CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
		COALESCE ( save.ind_unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4,
		''医療材料'' AS data_type_order,
		1 AS kind_order,
		eq.equipment_cd AS equipment_cd,
		eqc.class_cd AS equipment_class_cd,
		NULL AS medicine_cd,
		NULL AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
	WHERE
		save.supplies_source_class = ''0''
		and save.supplies_class = ''04''
	UNION ALL--穿刺針(A針)
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 3
         WHEN @dataTypeOrder = ''2'' THEN 1
         WHEN @dataTypeOrder = ''3'' THEN 1
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 3
         ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''穿刺針(A)'' AS class,
		7 as class_data_order,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
			CASE
			WHEN eqc.class_name IS NULL THEN
			''-1'' ELSE eqc.class_cd
		END AS class_cd,
		''医材'' AS do_action,
		eq.equipment_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
		CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
		COALESCE ( save.ind_unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4,
		''医療材料'' AS data_type_order,
		1 AS kind_order,
		eq.equipment_cd AS equipment_cd,
		eqc.class_cd AS equipment_class_cd,
		NULL AS medicine_cd,
		NULL AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' )  = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
	WHERE
		save.supplies_source_class = ''0''
		and save.supplies_class = ''06''
	UNION ALL--穿刺針(V針)
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 3
         WHEN @dataTypeOrder = ''2'' THEN 1
         WHEN @dataTypeOrder = ''3'' THEN 1
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 3
         ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''穿刺針(V)'' AS class,
		8 as class_data_order,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
			CASE
			WHEN eqc.class_name IS NULL THEN
			''-1'' ELSE eqc.class_cd
		END AS class_cd,
		''医材'' AS do_action,
		eq.equipment_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
		CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
		COALESCE ( save.ind_unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4,
		''医療材料'' AS data_type_order,
		1 AS kind_order,
		eq.equipment_cd AS equipment_cd,
		eqc.class_cd AS equipment_class_cd,
		NULL AS medicine_cd,
		NULL AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
	WHERE
		save.supplies_source_class = ''0''
		and save.supplies_class = ''07''
	UNION ALL--穿刺針(SN)
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 3
         WHEN @dataTypeOrder = ''2'' THEN 1
         WHEN @dataTypeOrder = ''3'' THEN 1
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 3
         ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''シングルニードル'' AS class,
		6 as class_data_order,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''''''' )
		END AS kind,
			CASE
			WHEN eqc.class_name IS NULL THEN
			''-1'' ELSE eqc.class_cd
		END AS class_cd,
		''医材'' AS do_action,
		eq.equipment_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
		CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
		COALESCE ( save.ind_unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4,
		''医療材料'' AS data_type_order,
		1 AS kind_order,
		eq.equipment_cd AS equipment_cd,
		eqc.class_cd AS equipment_class_cd,
		NULL AS medicine_cd,
		NULL AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
	WHERE
		save.supplies_source_class = ''0''
		and save.supplies_class = ''05''
	UNION ALL--血液回路
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 3
         WHEN @dataTypeOrder = ''2'' THEN 1
         WHEN @dataTypeOrder = ''3'' THEN 1
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 3
         ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''血液回路'' AS class,
		2 as class_data_order,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
			CASE
			WHEN eqc.class_name IS NULL THEN
			''-1'' ELSE eqc.class_cd
		END AS class_cd,
		''医材'' AS do_action,
		eq.equipment_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
		CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
		COALESCE ( save.ind_unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4,
		''医療材料'' AS data_type_order,
		1 AS kind_order,
		eq.equipment_cd AS equipment_cd,
		eqc.class_cd AS equipment_class_cd,
		NULL AS medicine_cd,
		NULL AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
	WHERE
		save.supplies_source_class = ''0''
		and save.supplies_class = ''00''
	UNION ALL--医材
	(SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
			WHEN @dataTypeOrder = ''1'' THEN 3
			WHEN @dataTypeOrder = ''2'' THEN 1
			WHEN @dataTypeOrder = ''3'' THEN 1
			WHEN @dataTypeOrder = ''4'' THEN 2
			WHEN @dataTypeOrder = ''5'' THEN 3
			ELSE 1  END AS disp_order
		, treat_date
		, kur_cd
		, kur_name
		, bed_cd
		, bed_name
		, pat_id
		, class
		, class_data_order
		, kind
		, class_cd
		, ''医材'' AS do_action
		, NAME
		, code
		, SUM(equInfo.ind_rst_value) AS Amount
		, Unit
		, in_hospital_cd_1
		, in_hospital_cd_2
		, in_hospital_cd_3
		, in_hospital_cd_4
		, ''医療材料'' AS data_type_order
		,	1 AS kind_order
		, code AS equipment_cd
		, class_cd AS equipment_class_cd
		, NULL AS medicine_cd
		, NULL AS medicine_class_cd
		, NULL AS dialyzer_cd
	FROM (
		SELECT
			save.supplies_base_date as treat_date,
			save.kur_cd,
			COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
			save.bed_cd,
			COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
			save.pat_id,
			CASE
				WHEN eqc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
				END AS class,
				12 as class_data_order,
			CASE
				WHEN eqc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
				END AS kind,
			CASE
				WHEN eqc.class_name IS NULL THEN
				''-1'' ELSE eqc.class_cd
				END AS class_cd,
			eq.equipment_name AS NAME,
			TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
			CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS ind_rst_value ,
      COALESCE ( save.ind_unit, '''' ) AS Unit,
			eq.in_hospital_cd_1,
			eq.in_hospital_cd_2,
			eq.in_hospital_cd_3,
			eq.in_hospital_cd_4
		FROM
			save
			INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = eq.equipment_cd
			AND eq.class_cd IN ( @eqIds )
			LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		WHERE
			save.supplies_source_class = ''2''
      and save.supplies_class = ''11''
		UNION ALL -- ダイアライザ（医材）
		SELECT
			save.supplies_base_date as treat_date,
			save.kur_cd,
			COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
			save.bed_cd,
			COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
			save.pat_id,
			''ダイアライザ'' AS class,
			12 as class_data_order,
			CASE WHEN dz.model_number IS NOT NULL THEN
			''ダイアライザ'' ELSE NULL
		   END AS kind,
			''0'' AS class_cd,
			dz.model_number NAME,
			TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
			CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS ind_rst_value ,
      COALESCE ( save.ind_unit, '''' ) AS Unit,
			dz.in_hospital_cd_1,
			dz.in_hospital_cd_2,
			dz.in_hospital_cd_3,
			dz.in_hospital_cd_4
		FROM
			save
			INNER JOIN dz ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = dz.dialyzer_cd
		  AND dz.dialyzer_cd IN ( @diaIds )
	  WHERE
		save.supplies_source_class = ''2''
		and save.supplies_class = ''01''	
	) equInfo
	GROUP BY
		treat_date,
		kind,
		class_cd,
		class,
		class_data_order,
		do_action,
		NAME,
		code,
		kur_cd,
		kur_name,
		bed_cd,
		bed_name,
		Unit,
		pat_id,
		disp_order,
		in_hospital_cd_1,
		in_hospital_cd_2,
		in_hospital_cd_3,
		in_hospital_cd_4,
		data_type_order,
		kind_order
	ORDER BY
		disp_order,
		kind,
		class_cd,
		do_action,
		data_type_order,
		kind_order,
		code,
		NAME,
		kur_cd,
		kur_name,
		bed_cd,
		bed_name,
		pat_id
	)
	UNION ALL--抗凝固剤
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 3
			WHEN @dataTypeOrder = ''1'' THEN 2
			WHEN @dataTypeOrder = ''2'' THEN 2
			WHEN @dataTypeOrder = ''3'' THEN 3
			WHEN @dataTypeOrder = ''4'' THEN 1
			WHEN @dataTypeOrder = ''5'' THEN 1
			ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''抗凝固剤'' AS class,
		9 as class_data_order,
		CASE
			WHEN mdc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
			END AS kind,
		CASE
			WHEN mdc.class_name IS NULL THEN
			''-1'' ELSE mdc.class_cd
			END AS class_cd,
		''通常薬剤'' AS do_action,
		md.medicine_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
    CAST(
      CASE 
        WHEN NULLIF(save.receipt_value, '''') IS NULL 
             OR CAST(NULLIF(save.receipt_value, '''') AS DECIMAL) = 0 
        THEN NULLIF(save.ind_rst_value, '''') 
        ELSE NULLIF(save.receipt_value, '''') 
      END 
    AS DECIMAL) AS Amount,
    CASE 
      WHEN NULLIF(save.receipt_value, '''') IS NULL 
           OR CAST(NULLIF(save.receipt_value, '''') AS DECIMAL) = 0 
      THEN COALESCE(save.ind_unit, '''') 
      ELSE save.receipt_unit 
    END AS Unit,
		md.in_hospital_cd_1,
		md.in_hospital_cd_2,
		md.in_hospital_cd_3,
		md.in_hospital_cd_4,
		''薬剤'' AS data_type_order,
		1 AS kind_order,
		NULL AS equipment_cd,
		NULL AS equipment_class_cd,
		md.medicine_cd :: TEXT AS medicine_cd,
		mdc.class_cd :: TEXT AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN md ON TO_NUMBER( save.supplies_cd, ''99999999'' ) = md.medicine_cd
		AND md.class_cd IN ( @medIds )
		LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
	WHERE
	  save.supplies_source_class = ''0''
		and save.supplies_class = ''10''
	UNION ALL--抗凝固剤調製薬剤
	SELECT
				CASE WHEN @dataTypeOrder = ''0'' THEN 3
             WHEN @dataTypeOrder = ''1'' THEN 2
             WHEN @dataTypeOrder = ''2'' THEN 2
             WHEN @dataTypeOrder = ''3'' THEN 3
             WHEN @dataTypeOrder = ''4'' THEN 1
             WHEN @dataTypeOrder = ''5'' THEN 1
             ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
        ''抗凝固剤'' AS class,
				9 as class_data_order,
			CASE

					WHEN mdc.class_name IS NULL THEN
					''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS kind,
							CASE
			WHEN mdc.class_name IS NULL THEN
			''-1'' ELSE mdc.class_cd
		END AS class_cd,
		''通常薬剤'' AS do_action,
				md.medicine_name AS NAME,
				TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
    CAST(
      CASE 
        WHEN NULLIF(save.receipt_value, '''') IS NULL 
             OR CAST(NULLIF(save.receipt_value, '''') AS DECIMAL) = 0 
        THEN NULLIF(save.ind_rst_value, '''') 
        ELSE NULLIF(save.receipt_value, '''') 
      END 
    AS DECIMAL) AS Amount,
    CASE 
      WHEN NULLIF(save.receipt_value, '''') IS NULL 
           OR CAST(NULLIF(save.receipt_value, '''') AS DECIMAL) = 0 
      THEN COALESCE(save.ind_unit, '''') 
      ELSE save.receipt_unit 
    END AS Unit,
						md.in_hospital_cd_1,
						md.in_hospital_cd_2,
						md.in_hospital_cd_3,
						md.in_hospital_cd_4,
				''薬剤'' AS data_type_order,
				1 AS kind_order,
				NULL AS equipment_cd,
				NULL AS equipment_class_cd,
				mdx.medicine_mix_cd :: TEXT AS medicine_cd,
				mdc.class_cd :: TEXT AS medicine_class_cd,
			  NULL AS dialyzer_cd
					FROM
						save 
						INNER JOIN mdx ON mdx.medicine_mix_cd = TO_NUMBER( save.medicine_mix_cd, ''999999999999'' )
						INNER JOIN md ON TO_NUMBER( save.supplies_cd, ''99999999'' )  = md.medicine_cd
						AND mdx.class_cd IN ( @medIds )
						LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
					WHERE
					save.supplies_source_class = ''0''
		      and save.supplies_class = ''22''
	UNION ALL--透析液
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 3
             WHEN @dataTypeOrder = ''1'' THEN 2
             WHEN @dataTypeOrder = ''2'' THEN 2
             WHEN @dataTypeOrder = ''3'' THEN 3
             WHEN @dataTypeOrder = ''4'' THEN 1
             WHEN @dataTypeOrder = ''5'' THEN 1
             ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''透析液'' AS class,
		10 as class_data_order,
	CASE

			WHEN mdc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
		END AS kind,
			CASE
			WHEN mdc.class_name IS NULL THEN
			''-1'' ELSE mdc.class_cd
		END AS class_cd,
		''通常薬剤'' AS do_action,
		md.medicine_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
		CAST ( save.receipt_value AS DECIMAL )  AS Amount,
		COALESCE ( save.receipt_unit, '''' ) AS Unit,
		md.in_hospital_cd_1,
		md.in_hospital_cd_2,
		md.in_hospital_cd_3,
		md.in_hospital_cd_4,
		''薬剤'' AS data_type_order,
		1 AS kind_order,
		NULL AS equipment_cd,
		NULL AS equipment_class_cd,
		md.medicine_cd :: TEXT AS medicine_cd,
		mdc.class_cd :: TEXT AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN md ON TO_NUMBER( save.supplies_cd, ''99999999'' )  = md.medicine_cd
		AND md.class_cd IN ( @medIds )
		LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
		WHERE
	  save.supplies_source_class = ''0''
		and save.supplies_class = ''08''
	UNION ALL--補液
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 3
             WHEN @dataTypeOrder = ''1'' THEN 2
             WHEN @dataTypeOrder = ''2'' THEN 2
             WHEN @dataTypeOrder = ''3'' THEN 3
             WHEN @dataTypeOrder = ''4'' THEN 1
             WHEN @dataTypeOrder = ''5'' THEN 1
             ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''補液'' AS class,
		11 as class_data_order,
	CASE

			WHEN mdc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
		END AS kind,
					CASE
			WHEN mdc.class_name IS NULL THEN
			''-1'' ELSE mdc.class_cd
		END AS class_cd,
		''通常薬剤'' AS do_action,
		md.medicine_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
		CAST ( save.receipt_value AS DECIMAL )  AS Amount,
		COALESCE ( save.receipt_unit, '''' ) AS Unit,
		md.in_hospital_cd_1,
		md.in_hospital_cd_2,
		md.in_hospital_cd_3,
		md.in_hospital_cd_4,
		''薬剤'' AS data_type_order,
		1 AS kind_order,
		NULL AS equipment_cd,
		NULL AS equipment_class_cd,
		md.medicine_cd :: TEXT AS medicine_cd,
		mdc.class_cd :: TEXT AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN md ON TO_NUMBER( save.supplies_cd, ''99999999'' )  = md.medicine_cd
		AND md.class_cd IN ( @medIds )
		LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
	WHERE
	  save.supplies_source_class = ''0''
		and save.supplies_class = ''09''
	UNION ALL--投薬
	(SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 3
			WHEN @dataTypeOrder = ''1'' THEN 2
			WHEN @dataTypeOrder = ''2'' THEN 2
			WHEN @dataTypeOrder = ''3'' THEN 3
			WHEN @dataTypeOrder = ''4'' THEN 1
			WHEN @dataTypeOrder = ''5'' THEN 1
			ELSE 1  END AS disp_order
		, treat_date
		, kur_cd
		, kur_name
		, bed_cd
		, bed_name
		, pat_id
		, class
		, class_data_order
		, kind
		, class_cd
		, ''通常薬剤'' AS do_action
		, NAME
		, code
		, SUM(medInfo.ind_rst_value) AS Amount
		, Unit
		, in_hospital_cd_1
		, in_hospital_cd_2
		, in_hospital_cd_3
		, in_hospital_cd_4
		, ''薬剤'' AS data_type_order
		,	1 AS kind_order
		, NULL AS equipment_cd
		, NULL AS equipment_class_cd
		, code::TEXT AS medicine_cd
		, class_cd::TEXT AS medicine_class_cd
		, NULL AS dialyzer_cd
	FROM (
		SELECT
			save.supplies_base_date as treat_date,
			save.kur_cd,
			COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
			save.bed_cd,
			COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
			save.pat_id,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS class,
				13 as class_data_order,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS kind,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''-1'' ELSE mdc.class_cd
				END AS class_cd,
			md.medicine_name AS NAME,
			TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
			CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS ind_rst_value ,
			COALESCE ( save.ind_unit, '''' ) AS Unit,
			md.in_hospital_cd_1,
			md.in_hospital_cd_2,
			md.in_hospital_cd_3,
			md.in_hospital_cd_4
		FROM
			save
			INNER JOIN md ON TO_NUMBER( save.supplies_cd, ''99999999'' ) = md.medicine_cd
			AND md.class_cd IN ( @medIds )
			LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
		WHERE
			save.supplies_source_class = ''1''
		and save.supplies_class = ''12''
	) medInfo
	GROUP BY
		treat_date,
		kind,
		class_cd,
		class,
		class_data_order,
		do_action,
		NAME,
		code,
		kur_cd,
		kur_name,
		bed_cd,
		bed_name,
		Unit,
		pat_id,
		disp_order,
		in_hospital_cd_1,
		in_hospital_cd_2,
		in_hospital_cd_3,
		in_hospital_cd_4,
		data_type_order,
		kind_order
	ORDER BY
		disp_order,
		kind,
		class_cd,
		do_action,
		data_type_order,
		kind_order,
		code,
		NAME,
		kur_cd,
		kur_name,
		bed_cd,
		bed_name,
		pat_id
	)
	UNION ALL--投薬調製薬剤
	(SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 3
			WHEN @dataTypeOrder = ''1'' THEN 2
			WHEN @dataTypeOrder = ''2'' THEN 2
			WHEN @dataTypeOrder = ''3'' THEN 3
			WHEN @dataTypeOrder = ''4'' THEN 1
			WHEN @dataTypeOrder = ''5'' THEN 1
			ELSE 1  END AS disp_order
		, treat_date
		, kur_cd
		, kur_name
		, bed_cd
		, bed_name
		, pat_id
		, class
		, class_data_order
		, kind
		, class_cd
		, ''通常薬剤'' AS do_action
		, NAME
		, code
		, SUM(medInfo.ind_rst_value) AS Amount
		, Unit
		, in_hospital_cd_1
		, in_hospital_cd_2
		, in_hospital_cd_3
		, in_hospital_cd_4
		, ''薬剤'' AS data_type_order
		,	1 AS kind_order
		, NULL AS equipment_cd
		, NULL AS equipment_class_cd
		, code::TEXT AS medicine_cd
		, class_cd::TEXT AS medicine_class_cd
		, NULL AS dialyzer_cd
	FROM (
		SELECT
			save.supplies_base_date as treat_date,
			save.kur_cd,
			COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
			save.bed_cd,
			COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
			save.pat_id,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS class,
				13 as class_data_order,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS kind,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''-1'' ELSE mdc.class_cd
				END AS class_cd,
			md.medicine_name AS NAME,
			TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
			CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS ind_rst_value ,
			COALESCE ( save.ind_unit, '''' ) AS Unit,
			md.in_hospital_cd_1,
			md.in_hospital_cd_2,
			md.in_hospital_cd_3,
			md.in_hospital_cd_4
		FROM
			save
			INNER JOIN md ON TO_NUMBER( save.supplies_cd, ''99999999'' )  = md.medicine_cd
			AND md.class_cd IN ( @medIds )
			LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
		WHERE
			save.supplies_source_class = ''1''
		and save.supplies_class = ''20''
	) medInfo
	GROUP BY
		treat_date,
		kind,
		class_cd,
		class,
		class_data_order,
		do_action,
		NAME,
		code,
		kur_cd,
		kur_name,
		bed_cd,
		bed_name,
		Unit,
		pat_id,
		disp_order,
		in_hospital_cd_1,
		in_hospital_cd_2,
		in_hospital_cd_3,
		in_hospital_cd_4,
		data_type_order,
		kind_order
	ORDER BY
		disp_order,
		kind,
		class_cd,
		do_action,
		data_type_order,
		kind_order,
		code,
		NAME,
		kur_cd,
		kur_name,
		bed_cd,
		bed_name,
		pat_id
	)
	) AS EquipmentList
	LEFT OUTER JOIN medic ON medic.medic_code :: TEXT = EquipmentList.medicine_class_cd
	LEFT OUTER JOIN equic ON equic.equic_code = EquipmentList.equipment_class_cd
	LEFT OUTER JOIN dia ON dia.dia_code = EquipmentList.dialyzer_cd
	LEFT OUTER JOIN medi_mix ON medi_mix.medi_mix_code :: TEXT = EquipmentList.medicine_class_cd
	LEFT OUTER JOIN bed_sort AS bed ON bed.bed_code = EquipmentList.bed_cd
) 
SELECT * from result_all as res @orderBy, bed_order ASC
', 2, '[{"preview": "1", "can_calc": "", "data_code": "kur_cd", "data_name": "クールコード", "data_type": "decimal", "conv_table": [], "data_class": "ベッド情報（分解）", "field_name": "kur_cd", "disp_format": "0", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": ""}, {"preview": "午後", "can_calc": "", "data_code": "kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報（分解）", "field_name": "kur_name", "disp_format": "", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": ""}, {"preview": "北1", "can_calc": "", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報（分解）", "field_name": "bed_name", "disp_format": "", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": ""}, {"preview": "テープ", "can_calc": "0", "data_code": "kind", "data_name": "分類名称", "data_type": "string", "conv_table": [], "data_class": "物品情報（分解）", "field_name": "kind", "disp_format": "", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ダイアライザ", "can_calc": "0", "data_code": "class", "data_name": "治療条件名", "data_type": "string", "conv_table": [], "data_class": "物品情報（分解）", "field_name": "class", "disp_format": "", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70%ブドウ糖注射液350ml", "can_calc": "0", "data_code": "name", "data_name": "型番･名称", "data_type": "string", "conv_table": [], "data_class": "物品情報（分解）", "field_name": "name", "disp_format": "", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "1", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "物品情報（分解）", "field_name": "amount", "disp_format": "0.00", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "個", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "物品情報（分解）", "field_name": "unit", "disp_format": "", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789012", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "hosp_pat_id", "target_var": "@patId"}, "data_code": "hosp_pat_id", "data_name": "患者ID", "data_type": "string", "conv_table": [], "data_class": "基本情報（分解）", "field_name": "pat_id", "disp_format": "", "data_category": "配布リスト(物品)", "facility_filter_type": "0"}, {"preview": "テスト患者1", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_name", "target_var": "@patId"}, "data_code": "pat_name", "data_name": "患者名", "data_type": "string", "conv_table": [], "data_class": "基本情報（分解）", "field_name": "pat_id1", "disp_format": "", "data_category": "配布リスト(物品)", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [6]}', '配布リスト(物品)(分解)', '2020-01-11 13:28:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (207, 'WITH x AS (
	SELECT
		om.*,
		save.supplies_source_class,
		save.supplies_class,
		save.ind_rst_class,
		save.supplies_cd,
    save.medicine_mix_cd,
    save.ind_rst_value,
		save.receipt_value,
    save.ind_unit,
    save.receipt_unit,
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
	)
SELECT
	to_timestamp( treat_date, ''YYYYMMDD'' ) AS treat_date,
	kur_cd,
	kur_name,
	bed_name,
	pat_id,
	kind,
  class,
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
    ''ダイアライザ'' as class,
		case when dz.model_number is not null then ''ダイアライザ'' else null END AS kind,
		dz.model_number AS NAME,
		case when dz.model_number is not null then CAST(NULLIF(x.ind_rst_value, '''') AS DECIMAL) else null END AS Amount,
		x.ind_unit AS Unit,
		dz.in_hospital_cd_1,
		dz.in_hospital_cd_2,
		dz.in_hospital_cd_3,
		dz.in_hospital_cd_4
	FROM
    x
		INNER JOIN mst_dialyzer AS dz ON ( x.supplies_cd_n = dz.dialyzer_cd AND dz.is_del = ''0'' AND dz.is_disp = ''1'' )
		AND dz.dialyzer_cd IN (@diaIds)
	WHERE
    x.supplies_source_class = ''0''
		AND x.supplies_class = ''01'' UNION ALL--吸着カラム
  SELECT
		2 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
    ''吸着カラム'' as class,
    COALESCE(eqc.class_name, ''未分類'') AS kind,
		eq.equipment_name AS NAME,
    CAST(NULLIF(x.ind_rst_value, '''') AS DECIMAL) AS Amount,
		COALESCE ( x.ind_unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
    x
    INNER JOIN mst_equipment  AS eq ON ( x.supplies_cd_n = eq.equipment_cd AND eq.is_del = ''0'' AND eq.is_disp = ''1'' AND eq.class_cd IN ( @eqIds ))
		LEFT OUTER JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'' )
	WHERE
		x.supplies_source_class = ''0''
    AND x.supplies_class = ''02'' UNION ALL--1次膜
  SELECT
		3 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
    ''1次膜'' as class,
		COALESCE(eqc.class_name, ''未分類'') AS kind,
		eq.equipment_name AS NAME,
    CAST(NULLIF(x.ind_rst_value, '''') AS DECIMAL) AS Amount,
		COALESCE ( x.ind_unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
    x
    INNER JOIN mst_equipment AS eq ON (x.supplies_cd_n = eq.equipment_cd AND eq.is_del = ''0'' AND eq.is_disp = ''1'' AND eq.class_cd IN ( @eqIds ))
		LEFT OUTER JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'')
	WHERE
		x.supplies_source_class = ''0''
    AND x.supplies_class = ''03'' UNION ALL--2次膜
	SELECT
		4 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
    ''2次膜'' as class,
		COALESCE(eqc.class_name, ''未分類'') AS kind,
		eq.equipment_name AS NAME,
		CAST(NULLIF(x.ind_rst_value, '''') AS DECIMAL) AS Amount,
		COALESCE ( x.ind_unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
    x
    INNER JOIN mst_equipment AS eq ON (x.supplies_cd_n = eq.equipment_cd AND eq.is_del = ''0'' AND eq.is_disp = ''1'' AND eq.class_cd IN ( @eqIds ))
		LEFT OUTER JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'')
	WHERE
		x.supplies_source_class = ''0''
		AND x.supplies_class = ''04'' UNION ALL--穿刺針(A針)
	SELECT
		5 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
    ''穿刺針(A)'' as class,
		COALESCE(eqc.class_name, ''未分類'') AS kind,
		eq.equipment_name AS NAME,
		CAST(NULLIF(x.ind_rst_value, '''') AS DECIMAL) AS Amount,
		COALESCE ( x.ind_unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
    x
    INNER JOIN mst_equipment AS eq ON (x.supplies_cd_n = eq.equipment_cd AND eq.is_del = ''0'' AND eq.is_disp = ''1'' AND eq.class_cd IN ( @eqIds ))
		LEFT OUTER JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'')
	WHERE
		x.supplies_source_class = ''0''
		AND x.supplies_class = ''06'' UNION ALL--穿刺針(V針)
	SELECT
		5 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
    ''穿刺針(V)'' as class,
		COALESCE(eqc.class_name, ''未分類'') AS kind,
		eq.equipment_name AS NAME,
		CAST(NULLIF(x.ind_rst_value, '''') AS DECIMAL) AS Amount,
		COALESCE ( x.ind_unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
    x
    INNER JOIN mst_equipment AS eq ON (x.supplies_cd_n = eq.equipment_cd AND eq.is_del = ''0'' AND eq.is_disp = ''1'' AND eq.class_cd IN ( @eqIds ))
		LEFT OUTER JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'')
	WHERE
		x.supplies_source_class = ''0''
		AND x.supplies_class = ''07'' UNION ALL--穿刺針(SN)
	SELECT
		6 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
    ''シングルニードル'' as class,
		COALESCE(eqc.class_name, ''未分類'') AS kind,
		eq.equipment_name AS NAME,
		CAST(NULLIF(x.ind_rst_value, '''') AS DECIMAL) AS Amount,
		COALESCE ( x.ind_unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
    x
    INNER JOIN mst_equipment AS eq ON (x.supplies_cd_n = eq.equipment_cd AND eq.is_del = ''0'' AND eq.is_disp = ''1'' AND eq.class_cd IN ( @eqIds ))
		LEFT OUTER JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'' )
	WHERE
		x.supplies_source_class = ''0''
		AND x.supplies_class = ''05'' UNION ALL--血液回路
	SELECT
		7 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
    ''血液回路'' as class,
		COALESCE(eqc.class_name, ''未分類'') AS kind,
		eq.equipment_name AS NAME,
		CAST(NULLIF(x.ind_rst_value, '''') AS DECIMAL) AS Amount,
		COALESCE ( x.ind_unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4
	FROM
    x
    INNER JOIN mst_equipment AS eq ON (x.supplies_cd_n = eq.equipment_cd AND eq.is_del = ''0'' AND eq.is_disp = ''1'' AND eq.class_cd IN ( @eqIds ))
		LEFT OUTER JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'')
	WHERE
		x.supplies_source_class = ''0''
		AND x.supplies_class = ''00'' UNION ALL--透析液
	SELECT
		8 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
    ''透析液'' as class,
		COALESCE(mdc.class_name, ''未分類'') AS kind,
		md.medicine_name AS NAME,
		CAST(NULLIF(x.receipt_value, '''') AS DECIMAL) AS Amount,
		COALESCE ( x.receipt_unit, '''' ) AS Unit,
		md.in_hospital_cd_1,
		md.in_hospital_cd_2,
		md.in_hospital_cd_3,
		md.in_hospital_cd_4
	FROM
    x
    INNER JOIN mst_medicine AS md ON (x.supplies_cd_n = md.medicine_cd AND md.is_del = ''0'' AND md.is_disp = ''1'' AND md.class_cd IN ( @medIds ))
		LEFT OUTER JOIN mst_medicine_class AS mdc ON ( md.class_cd = mdc.class_cd AND mdc.is_del = ''0'' AND mdc.is_disp = ''1'')
	WHERE
		x.supplies_source_class = ''0''
		AND x.supplies_class = ''08'' UNION ALL--補液
	SELECT
		9 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
    ''補液'' as class,
		COALESCE(mdc.class_name, ''未分類'') AS kind,
		md.medicine_name AS NAME,
		CAST(NULLIF(x.receipt_value, '''') AS DECIMAL) AS Amount,
		COALESCE ( x.receipt_unit, '''' ) AS Unit,
		md.in_hospital_cd_1,
		md.in_hospital_cd_2,
		md.in_hospital_cd_3,
		md.in_hospital_cd_4
	FROM
    x
    INNER JOIN mst_medicine AS md ON (x.supplies_cd_n = md.medicine_cd AND md.is_del = ''0'' AND md.is_disp = ''1'' AND md.class_cd IN ( @medIds ))
		LEFT OUTER JOIN mst_medicine_class AS mdc ON ( md.class_cd = mdc.class_cd AND mdc.is_del = ''0'' AND mdc.is_disp = ''1'')
	WHERE
		x.supplies_source_class = ''0''
		AND x.supplies_class = ''09'' UNION ALL--抗凝固剤
	SELECT
		10 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
    ''抗凝固剤'' as class,
		COALESCE(mdc.class_name, ''未分類'') AS kind,
		md.medicine_name AS NAME,
    CAST(
      CASE 
        WHEN NULLIF(x.receipt_value, '''') IS NULL 
             OR CAST(NULLIF(x.receipt_value, '''') AS DECIMAL) = 0 
        THEN NULLIF(x.ind_rst_value, '''') 
        ELSE NULLIF(x.receipt_value, '''') 
      END 
    AS DECIMAL) AS Amount,
    CASE 
      WHEN NULLIF(x.receipt_value, '''') IS NULL 
           OR CAST(NULLIF(x.receipt_value, '''') AS DECIMAL) = 0 
      THEN COALESCE(x.ind_unit, '''') 
      ELSE x.receipt_unit 
    END AS Unit,
		md.in_hospital_cd_1,
		md.in_hospital_cd_2,
		md.in_hospital_cd_3,
		md.in_hospital_cd_4
	FROM
    x    
    INNER JOIN mst_medicine AS md ON (x.supplies_cd_n = md.medicine_cd AND md.is_del = ''0'' AND md.is_disp = ''1'' AND md.class_cd IN ( @medIds ))
    LEFT OUTER JOIN mst_medicine_class AS mdc ON ( md.class_cd = mdc.class_cd AND mdc.is_del = ''0'' AND mdc.is_disp = ''1'')
	WHERE
    x.supplies_source_class = ''0''
    AND x.supplies_class = ''10'' UNION ALL--抗凝固剤調製薬剤
	SELECT
		10 AS disp_order,
		x.treat_date,
		x.kur_cd,
		x.kur_name,
		COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
		x.pat_id,
    ''抗凝固剤'' as class,
		COALESCE(mdc.class_name, ''未分類'') AS kind,
		md.medicine_name AS NAME,
    CAST(
      CASE 
        WHEN NULLIF(x.receipt_value, '''') IS NULL 
             OR CAST(NULLIF(x.receipt_value, '''') AS DECIMAL) = 0 
        THEN NULLIF(x.ind_rst_value, '''') 
        ELSE NULLIF(x.receipt_value, '''') 
      END 
    AS DECIMAL) AS Amount,
    CASE 
      WHEN NULLIF(x.receipt_value, '''') IS NULL 
           OR CAST(NULLIF(x.receipt_value, '''') AS DECIMAL) = 0 
      THEN COALESCE(x.ind_unit, '''') 
      ELSE x.receipt_unit 
    END AS Unit,
    md.in_hospital_cd_1,
    md.in_hospital_cd_2,
    md.in_hospital_cd_3,
    md.in_hospital_cd_4
  FROM
    x
		INNER JOIN mst_medicine_mix AS mdx ON mdx.medicine_mix_cd = TO_NUMBER( x.medicine_mix_cd, ''999999999999'' )
    INNER JOIN mst_medicine AS md ON (x.supplies_cd_n = md.medicine_cd AND md.is_del = ''0'' AND md.is_disp = ''1'' AND mdx.class_cd IN ( @medIds ))
    LEFT OUTER JOIN mst_medicine_class AS mdc ON ( md.class_cd = mdc.class_cd AND mdc.is_del = ''0'' AND mdc.is_disp = ''1'')
  WHERE
    x.supplies_source_class = ''0''
    AND x.supplies_class = ''22'' UNION ALL--投薬
  SELECT
    11 AS disp_order,
    x.treat_date,
    x.kur_cd,
    x.kur_name,
    COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
    x.pat_id,
    COALESCE(mdc.class_name, ''未分類'') AS class,
    COALESCE(mdc.class_name, ''未分類'') AS kind,
    md.medicine_name AS NAME,
    CAST(NULLIF(x.ind_rst_value, '''') AS DECIMAL) AS Amount,
    COALESCE ( x.ind_unit, '''' ) AS Unit,
    md.in_hospital_cd_1,
    md.in_hospital_cd_2,
    md.in_hospital_cd_3,
    md.in_hospital_cd_4
  FROM
    x
    INNER JOIN mst_medicine AS md ON (x.supplies_cd_n = md.medicine_cd AND md.is_del = ''0'' AND md.is_disp = ''1'' AND md.class_cd IN ( @medIds ))
    LEFT JOIN mst_medicine_class AS mdc ON ( md.class_cd = mdc.class_cd AND mdc.is_del = ''0'' AND mdc.is_disp = ''1'')
  WHERE
    x.supplies_source_class = ''1''
    AND x.supplies_class = ''12'' UNION ALL--投薬調製薬剤
  SELECT
    11 AS disp_order,
    x.treat_date,
    x.kur_cd,
    x.kur_name,
    COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
    x.pat_id,
    COALESCE(mdc.class_name, ''未分類'') AS class,
    COALESCE(mdc.class_name, ''未分類'') AS kind,
    md.medicine_name AS NAME,
    CAST(NULLIF(x.ind_rst_value, '''') AS DECIMAL) AS Amount,
    COALESCE (x.ind_unit, '''' ) AS Unit,
    md.in_hospital_cd_1,
    md.in_hospital_cd_2,
    md.in_hospital_cd_3,
    md.in_hospital_cd_4
  FROM
    x
    INNER JOIN mst_medicine AS md ON (x.supplies_cd_n = md.medicine_cd AND md.is_del = ''0'' AND md.is_disp = ''1'' AND md.class_cd IN ( @medIds ))
    LEFT JOIN mst_medicine_class AS mdc ON ( md.class_cd = mdc.class_cd AND mdc.is_del = ''0'' AND mdc.is_disp = ''1'')
  WHERE
    x.supplies_source_class = ''1''
    AND x.supplies_class = ''20'' UNION ALL--医材(ダイアライザ)
  SELECT
    12 AS disp_order,
    x.treat_date,
    x.kur_cd,
    x.kur_name,
    COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
    x.pat_id,
    ''ダイアライザ'' AS class,
    ''ダイアライザ'' AS kind,
    dz.model_number AS NAME,
    CAST(NULLIF(x.ind_rst_value, '''') AS DECIMAL) AS Amount,
    COALESCE (x.ind_unit, '''' ) AS Unit,
    dz.in_hospital_cd_1,
    dz.in_hospital_cd_2,
    dz.in_hospital_cd_3,
    dz.in_hospital_cd_4
  FROM  
    x
    INNER JOIN mst_dialyzer AS dz ON (x.supplies_cd_n = dz.dialyzer_cd AND dz.is_del = ''0'' AND dz.is_disp = ''1'' AND dz.dialyzer_cd IN ( @diaIds ))
  WHERE
    x.supplies_source_class = ''2''
    AND x.supplies_class = ''01'' UNION ALL--医材
  SELECT
    12 AS disp_order,
    x.treat_date,
    x.kur_cd,
    x.kur_name,
    COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
    x.pat_id,
    COALESCE(eqc.class_name, ''未分類'') AS class,
    COALESCE(eqc.class_name, ''未分類'') AS kind,
    eq.equipment_name AS NAME,
    CAST(NULLIF(x.ind_rst_value, '''') AS DECIMAL) AS Amount,
    COALESCE ( x.ind_unit, '''' ) AS Unit,
    eq.in_hospital_cd_1,
    eq.in_hospital_cd_2,
    eq.in_hospital_cd_3,
    eq.in_hospital_cd_4
  FROM
    x
    INNER JOIN mst_equipment AS eq ON (x.supplies_cd_n = eq.equipment_cd AND eq.is_del = ''0'' AND eq.is_disp = ''1'' AND eq.class_cd IN ( @eqIds ))
    LEFT JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'' )
  WHERE
    x.supplies_source_class = ''2''
    AND x.supplies_class = ''11''
  ) AS EquipmentList
	GROUP BY
		treat_date,
		kur_cd,
		kur_name,
		bed_name,
		pat_id,
		disp_order,
		kind,
    class,
		NAME,
		Unit,
		in_hospital_cd_1,
		in_hospital_cd_2,
		in_hospital_cd_3,
		in_hospital_cd_4
	ORDER BY
		kur_cd,
		kur_name,
		bed_name,
		pat_id,
    disp_order,
    kind;', 2, '[{"preview": "1", "can_calc": "", "data_code": "kur_cd", "data_name": "クールコード", "data_type": "decimal", "conv_table": [], "data_class": "ベッド情報(分解)", "field_name": "kur_cd", "disp_format": "0", "data_category": "配布リスト(ベッド)", "facility_filter_type": ""}, {"preview": "午後", "can_calc": "", "data_code": "kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報(分解)", "field_name": "kur_name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": ""}, {"preview": "北1", "can_calc": "", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報(分解)", "field_name": "bed_name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": ""}, {"preview": "123456789012", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "hosp_pat_id", "target_var": "@patId"}, "data_code": "hosp_pat_id", "data_name": "患者ID", "data_type": "string", "conv_table": [], "data_class": "ベッド情報(分解)", "field_name": "pat_id", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "テスト患者1", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_name", "target_var": "@patId"}, "data_code": "pat_id_to_name", "data_name": "患者名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報(分解)", "field_name": "pat_id_to_name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "医材・薬剤", "can_calc": "0", "data_code": "kind", "data_name": "分類名称", "data_type": "string", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "kind", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "ダイアライザ", "can_calc": "0", "data_code": "class", "data_name": "治療条件名", "data_type": "string", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "class", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "テスト医材・薬剤1", "can_calc": "0", "data_code": "name", "data_name": "型番･名称", "data_type": "string", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "amount", "disp_format": "0", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "個", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "unit", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_1", "data_name": "院内コード", "data_type": "string", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "in_hospital_cd_1", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "in_hospital_cd_2", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "in_hospital_cd_3", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_4", "data_name": "院内コード4", "data_type": "string", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "in_hospital_cd_4", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [5]}', '配布リスト(ベッド)（分解）', '2020-01-11 13:28:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (243, 'WITH 
save AS (
	SELECT
		om.*,
		save.supplies_base_date,
		save.supplies_source_class,
		save.supplies_class,
		save.ind_rst_class,
		save.supplies_cd,
		save.receipt_value,
		save.ind_rst_value,
		save.medicine_mix_cd,
		save.receipt_unit,
		save.ind_unit,
		TO_NUMBER( save.supplies_cd, ''9999999999'' ) supplies_cd_n,
		kr.kur_cd,
		kr.kur_name,
		bd.bed_cd,
		bd.bed_name
	FROM
		ord_main AS om
		INNER JOIN ord_material_save AS save ON ( om.ord_no = save.supplies_base_no AND om.facility_cd = save.facility_cd AND save.ind_rst_class = ''1'' )
		LEFT OUTER JOIN mst_kur AS kr ON ( om.ind_kur_cd = kr.kur_cd AND kr.is_del = ''0'' )
		LEFT OUTER JOIN mst_bed AS bd ON ( om.ind_bed_cd = bd.bed_cd AND bd.is_del = ''0'' AND bd.is_disp = ''1'' )
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.is_del = ''0''
	),	
dz AS ( SELECT * FROM mst_dialyzer mst WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' ),
kr AS ( SELECT * FROM mst_kur mst WHERE facility_cd = @facilityCd AND is_del = ''0'' ),
bd AS ( SELECT * FROM mst_bed mst WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' ),
eq AS ( SELECT * FROM mst_equipment mst WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' ),
eqc AS ( SELECT * FROM mst_equipment_class mst WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' ),
md AS ( SELECT * FROM mst_medicine mst WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' ),
mdx AS ( SELECT * FROM mst_medicine_mix mst WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' ),
mdc AS ( SELECT * FROM mst_medicine_class mst WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' ) ,
		medic AS (
	SELECT
		index_no AS medic_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medic_code,
		order_cd ->> ''name'' AS medi_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicine_class''
	),equic AS (
	SELECT
		index_no AS equic_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS equic_code,
		order_cd ->> ''name'' AS equic_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_equipment_class''
	),medi_mix AS (
	SELECT
		index_no AS medi_mix_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_mix_code,
		order_cd ->> ''name'' AS medi_mix_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicine_class''
	),dia AS (
	SELECT
		index_no AS dia_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS dia_code,
		order_cd ->> ''name'' AS equi_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_dialyzer''
	)
, bed_sort AS (
	SELECT
		index_no AS bed_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS bed_code,
		order_cd ->> ''name'' AS bed_sort_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_bed''
),
	result_all as (
	SELECT
to_timestamp( treat_date, ''YYYYMMDD'' ) AS treat_date,
disp_order,
kind,
class_cd,
class,
class_data_order,
do_action,
NAME,
code,
kur_cd,
kur_name,
Amount AS amount,
unit,
bed_cd,
bed_name,
pat_id,
pat_id AS pat_id1,
in_hospital_cd_1,
in_hospital_cd_2,
in_hospital_cd_3,
in_hospital_cd_4,
data_type_order,
kind_order,
dia.dia_order,
medic.medic_order,
equic.equic_order,
medi_mix.medi_mix_order,
bed.bed_order
FROM
	(
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 1
         WHEN @dataTypeOrder = ''2'' THEN 3
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''ダイアライザ'' AS class,
		1 as class_data_order,
	CASE

			WHEN dz.model_number IS NOT NULL THEN
			''ダイアライザ'' ELSE NULL
		END AS kind,
	    ''0'' AS class_cd,
			''ダイアライザ'' AS do_action, 
		dz.model_number AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
    CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
		COALESCE ( save.ind_unit, '''' ) AS Unit,
		dz.in_hospital_cd_1,
		dz.in_hospital_cd_2,
		dz.in_hospital_cd_3,
		dz.in_hospital_cd_4,
		''医療材料'' AS data_type_order,
		2 AS kind_order,
		NULL AS equipment_cd,
		NULL AS equipment_class_cd,
		NULL AS medicine_cd,
		NULL AS medicine_class_cd,
		dz.dialyzer_cd
	FROM
		save
		INNER JOIN dz ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = dz.dialyzer_cd
		AND dz.dialyzer_cd IN ( @diaIds )
	WHERE
		save.supplies_source_class = ''0''
		and save.supplies_class = ''01''
	UNION ALL--吸着カラム
	SELECT
				CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 1
         WHEN @dataTypeOrder = ''2'' THEN 3
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''吸着カラム'' AS class,
		3 as class_data_order,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
	CASE
			WHEN eqc.class_name IS NULL THEN
			''-1'' ELSE eqc.class_cd
		END AS class_cd,
		''医材'' AS do_action, 
		eq.equipment_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
		1 AS Amount,
		COALESCE ( save.ind_unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4,
		''医療材料'' AS data_type_order,
		1 AS kind_order,
		eq.equipment_cd AS equipment_cd,
		eqc.class_cd AS equipment_class_cd,
		NULL AS medicine_cd,
		NULL AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
	WHERE
		save.supplies_source_class = ''0''
		and save.supplies_class = ''02''
	UNION ALL--1次膜
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 1
         WHEN @dataTypeOrder = ''2'' THEN 3
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''1次膜'' AS class,
		4 as class_data_order,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
    CASE
			WHEN eqc.class_name IS NULL THEN
			''-1'' ELSE eqc.class_cd
		END AS class_cd,
		''医材'' AS do_action, 
		eq.equipment_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
		1 AS Amount,
		COALESCE ( save.ind_unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4,
		''医療材料'' AS data_type_order,
		1 AS kind_order,
		eq.equipment_cd AS equipment_cd,
		eqc.class_cd AS equipment_class_cd,
		NULL AS medicine_cd,
		NULL AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
	WHERE
		save.supplies_source_class = ''0''
		and save.supplies_class = ''03''
	UNION ALL--2次膜
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 1
         WHEN @dataTypeOrder = ''2'' THEN 3
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''2次膜'' AS class,
		5 as class_data_order,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
    CASE
			WHEN eqc.class_name IS NULL THEN
			''-1'' ELSE eqc.class_cd
		END AS class_cd,
		''医材'' AS do_action, 
		eq.equipment_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
		1 AS Amount,
		COALESCE ( save.ind_unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4,
		''医療材料'' AS data_type_order,
		1 AS kind_order,
		eq.equipment_cd AS equipment_cd,
		eqc.class_cd AS equipment_class_cd,
		NULL AS medicine_cd,
		NULL AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
	WHERE
		save.supplies_source_class = ''0''
		and save.supplies_class = ''04''
	UNION ALL--穿刺針(A針)
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 1
         WHEN @dataTypeOrder = ''2'' THEN 3
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''穿刺針(A)'' AS class,
		7 as class_data_order,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
    CASE
			WHEN eqc.class_name IS NULL THEN
			''-1'' ELSE eqc.class_cd
		END AS class_cd,
		''医材'' AS do_action, 
		eq.equipment_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
		1 AS Amount,
		COALESCE ( save.ind_unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4,
		''医療材料'' AS data_type_order,
		1 AS kind_order,
		eq.equipment_cd AS equipment_cd,
		eqc.class_cd AS equipment_class_cd,
		NULL AS medicine_cd,
		NULL AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' )  = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
	WHERE
		save.supplies_source_class = ''0''
		and save.supplies_class = ''06''
	UNION ALL--穿刺針(V針)
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 1
         WHEN @dataTypeOrder = ''2'' THEN 3
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''穿刺針(V)'' AS class,
		8 as class_data_order,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
    CASE
			WHEN eqc.class_name IS NULL THEN
			''-1'' ELSE eqc.class_cd
		END AS class_cd,
		''医材'' AS do_action, 
		eq.equipment_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
		1 AS Amount,
		COALESCE ( save.ind_unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4,
		''医療材料'' AS data_type_order,
		1 AS kind_order,
		eq.equipment_cd AS equipment_cd,
		eqc.class_cd AS equipment_class_cd,
		NULL AS medicine_cd,
		NULL AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
	WHERE
		save.supplies_source_class = ''0''
		and save.supplies_class = ''07''
	UNION ALL--穿刺針(SN)
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 1
         WHEN @dataTypeOrder = ''2'' THEN 3
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''シングルニードル'' AS class,
		6 as class_data_order,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''''''' )
		END AS kind,
    CASE
			WHEN eqc.class_name IS NULL THEN
			''-1'' ELSE eqc.class_cd
		END AS class_cd,
		''医材'' AS do_action, 
		eq.equipment_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
		1 AS Amount,
		COALESCE ( save.ind_unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4,
		''医療材料'' AS data_type_order,
		1 AS kind_order,
		eq.equipment_cd AS equipment_cd,
		eqc.class_cd AS equipment_class_cd,
		NULL AS medicine_cd,
		NULL AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
	WHERE
		save.supplies_source_class = ''0''
		and save.supplies_class = ''05''
	UNION ALL--血液回路
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 1
         WHEN @dataTypeOrder = ''2'' THEN 3
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''血液回路'' AS class,
		2 as class_data_order,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
    CASE
			WHEN eqc.class_name IS NULL THEN
			''-1'' ELSE eqc.class_cd
		END AS class_cd,
		''医材'' AS do_action, 
		eq.equipment_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
		1 AS Amount,
		COALESCE ( save.ind_unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4,
		''医療材料'' AS data_type_order,
		1 AS kind_order,
		eq.equipment_cd AS equipment_cd,
		eqc.class_cd AS equipment_class_cd,
		NULL AS medicine_cd,
		NULL AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
	WHERE
		save.supplies_source_class = ''0''
		and save.supplies_class = ''00''
	UNION ALL--医材
	(SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
			WHEN @dataTypeOrder = ''1'' THEN 1
			WHEN @dataTypeOrder = ''2'' THEN 3
			WHEN @dataTypeOrder = ''3'' THEN 3
			WHEN @dataTypeOrder = ''4'' THEN 2
			WHEN @dataTypeOrder = ''5'' THEN 1
			ELSE 1  END AS disp_order
		, treat_date
		, kur_cd
		, kur_name
		, bed_cd
		, bed_name
		, pat_id
		, class
		, class_data_order
		, kind
		, class_cd
		, ''医材'' AS do_action
		, NAME
		, code
		, SUM(equInfo.ind_rst_value) AS Amount
		, Unit
		, in_hospital_cd_1
		, in_hospital_cd_2
		, in_hospital_cd_3
		, in_hospital_cd_4
		, ''医療材料'' AS data_type_order
		,	1 AS kind_order
		, code AS equipment_cd
		, class_cd AS equipment_class_cd
		, NULL AS medicine_cd
		, NULL AS medicine_class_cd
		, NULL AS dialyzer_cd
	FROM (
		SELECT
			save.supplies_base_date as treat_date,
			save.kur_cd,
			COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
			save.bed_cd,
			COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
			save.pat_id,
			CASE
				WHEN eqc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
				END AS class,
				12 as class_data_order,
			CASE
				WHEN eqc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
				END AS kind,
			CASE
				WHEN eqc.class_name IS NULL THEN
				''-1'' ELSE eqc.class_cd
				END AS class_cd,
			eq.equipment_name AS NAME,
			TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
			CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS ind_rst_value ,
      COALESCE ( save.ind_unit, '''' ) AS Unit,
			eq.in_hospital_cd_1,
			eq.in_hospital_cd_2,
			eq.in_hospital_cd_3,
			eq.in_hospital_cd_4
		FROM
			save
			INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = eq.equipment_cd
			AND eq.class_cd IN ( @eqIds )
			LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		WHERE
			save.supplies_source_class = ''2''
      and save.supplies_class = ''11''
		UNION ALL -- ダイアライザ（医材）
		SELECT
			save.supplies_base_date as treat_date,
			save.kur_cd,
			COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
			save.bed_cd,
			COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
			save.pat_id,
			''ダイアライザ'' AS class,
			12 as class_data_order,
			CASE WHEN dz.model_number IS NOT NULL THEN
			''ダイアライザ'' ELSE NULL
		   END AS kind,
			''0'' AS class_cd,
			dz.model_number NAME,
			TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
			CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS ind_rst_value ,
      COALESCE ( save.ind_unit, '''' ) AS Unit,
			dz.in_hospital_cd_1,
			dz.in_hospital_cd_2,
			dz.in_hospital_cd_3,
			dz.in_hospital_cd_4
		FROM
			save
			INNER JOIN dz ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = dz.dialyzer_cd
		  AND dz.dialyzer_cd IN ( @diaIds )
	  WHERE
		save.supplies_source_class = ''2''
		and save.supplies_class = ''01''	
	) equInfo
	GROUP BY
		treat_date,
		kind,
		class_cd,
		class,
		class_data_order,
		do_action,
		NAME,
		code,
		kur_cd,
		kur_name,
		bed_cd,
		bed_name,
		Unit,
		pat_id,
		disp_order,
		in_hospital_cd_1,
		in_hospital_cd_2,
		in_hospital_cd_3,
		in_hospital_cd_4,
		data_type_order,
		kind_order
	ORDER BY
		disp_order,
		kind,
		class_cd,
		do_action,
		data_type_order,
		kind_order,
		code,
		NAME,
		kur_cd,
		kur_name,
		bed_cd,
		bed_name,
		pat_id
	)
	UNION ALL--抗凝固剤
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 1
			WHEN @dataTypeOrder = ''1'' THEN 2
			WHEN @dataTypeOrder = ''2'' THEN 2
			WHEN @dataTypeOrder = ''3'' THEN 1
			WHEN @dataTypeOrder = ''4'' THEN 3
			WHEN @dataTypeOrder = ''5'' THEN 3
			ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''抗凝固剤'' AS class,
		9 as class_data_order,
		CASE
			WHEN mdc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
			END AS kind,
    CASE
			WHEN mdc.class_name IS NULL THEN
			''-1'' ELSE mdc.class_cd
			END AS class_cd,
		''通常薬剤'' AS do_action, 
		md.medicine_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
    CAST(
      CASE 
        WHEN NULLIF(save.receipt_value, '''') IS NULL 
             OR CAST(NULLIF(save.receipt_value, '''') AS DECIMAL) = 0 
        THEN NULLIF(save.ind_rst_value, '''') 
        ELSE NULLIF(save.receipt_value, '''') 
      END 
    AS DECIMAL) AS Amount,
    CASE 
      WHEN NULLIF(save.receipt_value, '''') IS NULL 
           OR CAST(NULLIF(save.receipt_value, '''') AS DECIMAL) = 0 
      THEN COALESCE(save.ind_unit, '''') 
      ELSE save.receipt_unit 
    END AS Unit,
		md.in_hospital_cd_1,
		md.in_hospital_cd_2,
		md.in_hospital_cd_3,
		md.in_hospital_cd_4,
		''薬剤'' AS data_type_order,
		1 AS kind_order,
		NULL AS equipment_cd,
		NULL AS equipment_class_cd,
		md.medicine_cd :: TEXT AS medicine_cd,
		mdc.class_cd :: TEXT AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN md ON TO_NUMBER( save.supplies_cd, ''99999999'' ) = md.medicine_cd
		AND md.class_cd IN ( @medIds )
		LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
	WHERE
	  save.supplies_source_class = ''0''
		and save.supplies_class = ''10''
	UNION ALL--抗凝固剤調製薬剤
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 1
         WHEN @dataTypeOrder = ''1'' THEN 2
         WHEN @dataTypeOrder = ''2'' THEN 2
         WHEN @dataTypeOrder = ''3'' THEN 1
         WHEN @dataTypeOrder = ''4'' THEN 3
         WHEN @dataTypeOrder = ''5'' THEN 3
         ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''抗凝固剤'' AS class,
		9 as class_data_order,
		CASE
			WHEN mdc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
		END AS kind,
    CASE
			WHEN mdc.class_name IS NULL THEN
			''-1'' ELSE mdc.class_cd
		END AS class_cd,		
		''調製薬剤'' AS do_action, 
		mdx.medicine_mix_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
		1 AS Amount,
		'''' AS Unit,
		mdx.in_hospital_cd_1,
		mdx.in_hospital_cd_2,
		mdx.in_hospital_cd_3,
		null as in_hospital_cd_4,
		''薬剤'' AS data_type_order,
		2 AS kind_order,
		NULL AS equipment_cd,
		NULL AS equipment_class_cd,
		mdx.medicine_mix_cd :: TEXT AS medicine_cd,
		mdc.class_cd :: TEXT AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
	  save
		INNER JOIN mdx ON mdx.medicine_mix_cd = TO_NUMBER( save.medicine_mix_cd, ''999999999999'' )
		AND mdx.class_cd IN ( @medIds )
		LEFT OUTER JOIN mdc ON mdx.class_cd = mdc.class_cd
	WHERE
	  save.supplies_source_class = ''0''
		and save.supplies_class = ''17''
	UNION ALL--透析液
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 1
         WHEN @dataTypeOrder = ''1'' THEN 2
         WHEN @dataTypeOrder = ''2'' THEN 2
         WHEN @dataTypeOrder = ''3'' THEN 1
         WHEN @dataTypeOrder = ''4'' THEN 3
         WHEN @dataTypeOrder = ''5'' THEN 3
         ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''透析液'' AS class,
		10 as class_data_order,
	CASE

			WHEN mdc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
		END AS kind,
    CASE
			WHEN mdc.class_name IS NULL THEN
			''-1'' ELSE mdc.class_cd
		END AS class_cd,
		''通常薬剤'' AS do_action, 
		md.medicine_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
		CAST ( save.receipt_value AS DECIMAL )  AS Amount,
		COALESCE ( save.receipt_unit, '''' ) AS Unit,
		md.in_hospital_cd_1,
		md.in_hospital_cd_2,
		md.in_hospital_cd_3,
		md.in_hospital_cd_4,
		''薬剤'' AS data_type_order,
		1 AS kind_order,
		NULL AS equipment_cd,
		NULL AS equipment_class_cd,
		md.medicine_cd :: TEXT AS medicine_cd,
		mdc.class_cd :: TEXT AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN md ON TO_NUMBER( save.supplies_cd, ''99999999'' )  = md.medicine_cd
		AND md.class_cd IN ( @medIds )
		LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
		WHERE
	  save.supplies_source_class = ''0''
		and save.supplies_class = ''08''
	UNION ALL--補液
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 1
         WHEN @dataTypeOrder = ''1'' THEN 2
         WHEN @dataTypeOrder = ''2'' THEN 2
         WHEN @dataTypeOrder = ''3'' THEN 1
         WHEN @dataTypeOrder = ''4'' THEN 3
         WHEN @dataTypeOrder = ''5'' THEN 3
         ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''補液'' AS class,
		11 as class_data_order,
	CASE

			WHEN mdc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
		END AS kind,
    CASE
			WHEN mdc.class_name IS NULL THEN
			''-1'' ELSE mdc.class_cd
		END AS class_cd,
		''通常薬剤'' AS do_action, 
		md.medicine_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
		CAST ( save.receipt_value AS DECIMAL )  AS Amount,
		COALESCE ( save.receipt_unit, '''' ) AS Unit,
		md.in_hospital_cd_1,
		md.in_hospital_cd_2,
		md.in_hospital_cd_3,
		md.in_hospital_cd_4,
		''薬剤'' AS data_type_order,
		1 AS kind_order,
		NULL AS equipment_cd,
		NULL AS equipment_class_cd,
		md.medicine_cd :: TEXT AS medicine_cd,
		mdc.class_cd :: TEXT AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN md ON TO_NUMBER( save.supplies_cd, ''99999999'' )  = md.medicine_cd
		AND md.class_cd IN ( @medIds )
		LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
	WHERE
	  save.supplies_source_class = ''0''
		and save.supplies_class = ''09''
	UNION ALL--投薬
	(SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 1
			WHEN @dataTypeOrder = ''1'' THEN 2
			WHEN @dataTypeOrder = ''2'' THEN 2
			WHEN @dataTypeOrder = ''3'' THEN 1
			WHEN @dataTypeOrder = ''4'' THEN 3
			WHEN @dataTypeOrder = ''5'' THEN 3
			ELSE 1  END AS disp_order
		, treat_date
		, kur_cd
		, kur_name
		, bed_cd
		, bed_name
		, pat_id
		, class
		, class_data_order
		, kind
		, class_cd
		, ''通常薬剤'' AS do_action
		, NAME
		, code
		, SUM(medInfo.ind_rst_value) AS Amount
		, Unit
		, in_hospital_cd_1
		, in_hospital_cd_2
		, in_hospital_cd_3
		, in_hospital_cd_4
		, ''薬剤'' AS data_type_order
		,	1 AS kind_order
		, NULL AS equipment_cd
		, NULL AS equipment_class_cd
		, code::TEXT AS medicine_cd
		, class_cd::TEXT AS medicine_class_cd
		, NULL AS dialyzer_cd
	FROM (
		SELECT
			save.supplies_base_date as treat_date,
			save.kur_cd,
			COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
			save.bed_cd,
			COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
			save.pat_id,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS class,
				13 as class_data_order,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS kind,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''-1'' ELSE mdc.class_cd
				END AS class_cd,
			md.medicine_name AS NAME,
			TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
			CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS ind_rst_value ,
			COALESCE ( save.ind_unit, '''' ) AS Unit,
			md.in_hospital_cd_1,
			md.in_hospital_cd_2,
			md.in_hospital_cd_3,
			md.in_hospital_cd_4
		FROM
			save
			INNER JOIN md ON TO_NUMBER( save.supplies_cd, ''99999999'' ) = md.medicine_cd
			AND md.class_cd IN ( @medIds )
			LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
		WHERE
			save.supplies_source_class = ''1''
		and save.supplies_class = ''12''
	) medInfo
	GROUP BY
		treat_date,
		kind,
		class_cd,
		class,
		class_data_order,
		do_action,
		NAME,
		code,
		kur_cd,
		kur_name,
		bed_cd,
		bed_name,
		Unit,
		pat_id,
		disp_order,
		in_hospital_cd_1,
		in_hospital_cd_2,
		in_hospital_cd_3,
		in_hospital_cd_4,
		data_type_order,
		kind_order
	ORDER BY
		disp_order,
		kind,
		class_cd,
		do_action,
		data_type_order,
		kind_order,
		code,
		NAME,
		kur_cd,
		kur_name,
		bed_cd,
		bed_name,
		pat_id
	)
	UNION ALL--投薬調製薬剤
	(SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 1
			WHEN @dataTypeOrder = ''1'' THEN 2
			WHEN @dataTypeOrder = ''2'' THEN 2
			WHEN @dataTypeOrder = ''3'' THEN 1
			WHEN @dataTypeOrder = ''4'' THEN 3
			WHEN @dataTypeOrder = ''5'' THEN 3
			ELSE 1  END AS disp_order
		, treat_date
		, kur_cd
		, kur_name
		, bed_cd
		, bed_name
		, pat_id
		, class
		, class_data_order
		, kind
		, class_cd
		, ''調製薬剤'' AS do_action
		, NAME
		, code
		, SUM(medInfo.ind_rst_value) AS Amount
		, Unit
		, in_hospital_cd_1
		, in_hospital_cd_2
		, in_hospital_cd_3
		, in_hospital_cd_4
		, ''薬剤'' AS data_type_order
		,	2 AS kind_order
		, NULL AS equipment_cd
		, NULL AS equipment_class_cd
		, code::TEXT AS medicine_cd
		, class_cd::TEXT AS medicine_class_cd
		, NULL AS dialyzer_cd
	FROM (
		SELECT
			save.supplies_base_date as treat_date,
			save.kur_cd,
			COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
			save.bed_cd,
			COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
			save.pat_id,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS class,
				14 as class_data_order,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS kind,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''-1'' ELSE mdc.class_cd
				END AS class_cd,
			mdx.medicine_mix_name AS NAME,
			TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
			CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS ind_rst_value ,
			COALESCE ( save.ind_unit, '''' ) AS Unit,
			mdx.in_hospital_cd_1,
			mdx.in_hospital_cd_2,
			mdx.in_hospital_cd_3,
			null as in_hospital_cd_4
		FROM
			save
			INNER JOIN mdx ON TO_NUMBER(save.medicine_mix_cd, ''99999999'' ) = mdx.medicine_mix_cd
			AND mdx.class_cd IN ( @medIds )
			LEFT OUTER JOIN mdc ON mdx.class_cd = mdc.class_cd
		WHERE
			save.supplies_source_class = ''1''
		and save.supplies_class = ''13''
	) medInfo
	GROUP BY
		treat_date,
		kind,
		class_cd,
		class,
		class_data_order,
		do_action,
		NAME,
		code,
		kur_cd,
		kur_name,
		bed_cd,
		bed_name,
		Unit,
		pat_id,
		disp_order,
		in_hospital_cd_1,
		in_hospital_cd_2,
		in_hospital_cd_3,
		in_hospital_cd_4,
		data_type_order,
		kind_order
	ORDER BY
		disp_order,
		kind,
		class_cd,
		do_action,
		data_type_order,
		kind_order,
		code,
		NAME,
		kur_cd,
		kur_name,
		bed_cd,
		bed_name,
		pat_id
	)
	) AS EquipmentList
	LEFT OUTER JOIN medic ON medic.medic_code :: TEXT = EquipmentList.medicine_class_cd
	LEFT OUTER JOIN equic ON equic.equic_code = EquipmentList.equipment_class_cd
	LEFT OUTER JOIN dia ON dia.dia_code = EquipmentList.dialyzer_cd
	LEFT OUTER JOIN medi_mix ON medi_mix.medi_mix_code :: TEXT = EquipmentList.medicine_class_cd
	LEFT OUTER JOIN bed_sort AS bed ON bed.bed_code = EquipmentList.bed_cd
) 
SELECT * from result_all as res @orderBy, bed_order ASC
', 2, '[]', '1', '{"applications": [1]}', '{"classes": [6]}', '配布リスト(物品)（SQL11降順）', '2025-03-19 18:29:56.853', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (244, 'WITH 
save AS (
	SELECT
		om.*,
		save.supplies_base_date,
		save.supplies_source_class,
		save.supplies_class,
		save.ind_rst_class,
		save.supplies_cd,
		save.receipt_value,
		save.ind_rst_value,
		save.medicine_mix_cd,
		save.receipt_unit,
		save.ind_unit,
		TO_NUMBER( save.supplies_cd, ''9999999999'' ) supplies_cd_n,
		kr.kur_cd,
		kr.kur_name,
		bd.bed_cd,
		bd.bed_name
	FROM
		ord_main AS om
		INNER JOIN ord_material_save AS save ON ( om.ord_no = save.supplies_base_no AND om.facility_cd = save.facility_cd AND save.ind_rst_class = ''1'' )
		LEFT OUTER JOIN mst_kur AS kr ON ( om.ind_kur_cd = kr.kur_cd AND kr.is_del = ''0'' )
		LEFT OUTER JOIN mst_bed AS bd ON ( om.ind_bed_cd = bd.bed_cd AND bd.is_del = ''0'' AND bd.is_disp = ''1'' )
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.is_del = ''0''
	),	
dz AS ( SELECT * FROM mst_dialyzer mst WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' ),
kr AS ( SELECT * FROM mst_kur mst WHERE facility_cd = @facilityCd AND is_del = ''0'' ),
bd AS ( SELECT * FROM mst_bed mst WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' ),
eq AS ( SELECT * FROM mst_equipment mst WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' ),
eqc AS ( SELECT * FROM mst_equipment_class mst WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' ),
md AS ( SELECT * FROM mst_medicine mst WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' ),
mdx AS ( SELECT * FROM mst_medicine_mix mst WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' ),
mdc AS ( SELECT * FROM mst_medicine_class mst WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' ) ,
		medic AS (
	SELECT
		index_no AS medic_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medic_code,
		order_cd ->> ''name'' AS medi_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicine_class''
	),equic AS (
	SELECT
		index_no AS equic_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS equic_code,
		order_cd ->> ''name'' AS equic_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_equipment_class''
	),medi_mix AS (
	SELECT
		index_no AS medi_mix_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS medi_mix_code,
		order_cd ->> ''name'' AS medi_mix_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicine_class''
	),dia AS (
	SELECT
		index_no AS dia_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS dia_code,
		order_cd ->> ''name'' AS equi_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_dialyzer''
	)
, bed_sort AS (
	SELECT
		index_no AS bed_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS bed_code,
		order_cd ->> ''name'' AS bed_sort_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_bed''
),
	result_all as (
	SELECT
	disp_order,
to_timestamp( treat_date, ''YYYYMMDD'' ) AS treat_date,
kind,
class,
class_data_order,
class_cd,
do_action,
NAME,
code,
kur_cd,
kur_name,
Amount AS amount,
unit,
bed_cd,
bed_name,
pat_id,
pat_id AS pat_id1,
in_hospital_cd_1,
in_hospital_cd_2,
in_hospital_cd_3,
in_hospital_cd_4,
data_type_order,
kind_order,
dia.dia_order,
medic.medic_order,
equic.equic_order,
medi_mix.medi_mix_order,
bed.bed_order
FROM
	(
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 1
         WHEN @dataTypeOrder = ''2'' THEN 3
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''ダイアライザ'' AS class,
		1 as class_data_order,
	CASE

			WHEN dz.model_number IS NOT NULL THEN
			''ダイアライザ'' ELSE NULL
		END AS kind,
		''0'' AS class_cd,
		''ダイアライザ'' AS do_action, 
		dz.model_number AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
    CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
		COALESCE ( save.ind_unit, '''' ) AS Unit,
		dz.in_hospital_cd_1,
		dz.in_hospital_cd_2,
		dz.in_hospital_cd_3,
		dz.in_hospital_cd_4,
		''医療材料'' AS data_type_order,
		2 AS kind_order,
		NULL AS equipment_cd,
		NULL AS equipment_class_cd,
		NULL AS medicine_cd,
		NULL AS medicine_class_cd,
		dz.dialyzer_cd
	FROM
		save
		INNER JOIN dz ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = dz.dialyzer_cd
		AND dz.dialyzer_cd IN ( @diaIds )
	WHERE
		save.supplies_source_class = ''0''
		and save.supplies_class = ''01''
	UNION ALL--吸着カラム
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 1
         WHEN @dataTypeOrder = ''2'' THEN 3
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''吸着カラム'' AS class,
		3 as class_data_order,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
	CASE
			WHEN eqc.class_name IS NULL THEN
			''-1'' ELSE eqc.class_cd
		END AS class_cd,
		''医材'' AS do_action, 
		eq.equipment_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
		CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
		COALESCE ( save.ind_unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4,
		''医療材料'' AS data_type_order,
		1 AS kind_order,
		eq.equipment_cd AS equipment_cd,
		eqc.class_cd AS equipment_class_cd,
		NULL AS medicine_cd,
		NULL AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
	WHERE
		save.supplies_source_class = ''0''
		and save.supplies_class = ''02''
	UNION ALL--1次膜
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 1
         WHEN @dataTypeOrder = ''2'' THEN 3
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''1次膜'' AS class,
		4 as class_data_order,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
			CASE
			WHEN eqc.class_name IS NULL THEN
			''-1'' ELSE eqc.class_cd
		END AS class_cd,
		''医材'' AS do_action,
		eq.equipment_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
		CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
		COALESCE ( save.ind_unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4,
		''医療材料'' AS data_type_order,
		1 AS kind_order,
		eq.equipment_cd AS equipment_cd,
		eqc.class_cd AS equipment_class_cd,
		NULL AS medicine_cd,
		NULL AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
	WHERE
		save.supplies_source_class = ''0''
		and save.supplies_class = ''03''
	UNION ALL--2次膜
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 1
         WHEN @dataTypeOrder = ''2'' THEN 3
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''2次膜'' AS class,
		5 as class_data_order,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
			CASE
			WHEN eqc.class_name IS NULL THEN
			''-1'' ELSE eqc.class_cd
		END AS class_cd,
		''医材'' AS do_action,
		eq.equipment_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
		CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
		COALESCE ( save.ind_unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4,
		''医療材料'' AS data_type_order,
		1 AS kind_order,
		eq.equipment_cd AS equipment_cd,
		eqc.class_cd AS equipment_class_cd,
		NULL AS medicine_cd,
		NULL AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
	WHERE
		save.supplies_source_class = ''0''
		and save.supplies_class = ''04''
	UNION ALL--穿刺針(A針)
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 1
         WHEN @dataTypeOrder = ''2'' THEN 3
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''穿刺針(A)'' AS class,
		7 as class_data_order,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
			CASE
			WHEN eqc.class_name IS NULL THEN
			''-1'' ELSE eqc.class_cd
		END AS class_cd,
		''医材'' AS do_action,
		eq.equipment_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
		CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
		COALESCE ( save.ind_unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4,
		''医療材料'' AS data_type_order,
		1 AS kind_order,
		eq.equipment_cd AS equipment_cd,
		eqc.class_cd AS equipment_class_cd,
		NULL AS medicine_cd,
		NULL AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' )  = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
	WHERE
		save.supplies_source_class = ''0''
		and save.supplies_class = ''06''
	UNION ALL--穿刺針(V針)
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 1
         WHEN @dataTypeOrder = ''2'' THEN 3
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''穿刺針(V)'' AS class,
		8 as class_data_order,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
			CASE
			WHEN eqc.class_name IS NULL THEN
			''-1'' ELSE eqc.class_cd
		END AS class_cd,
		''医材'' AS do_action,
		eq.equipment_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
		CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
		COALESCE ( save.ind_unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4,
		''医療材料'' AS data_type_order,
		1 AS kind_order,
		eq.equipment_cd AS equipment_cd,
		eqc.class_cd AS equipment_class_cd,
		NULL AS medicine_cd,
		NULL AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
	WHERE
		save.supplies_source_class = ''0''
		and save.supplies_class = ''07''
	UNION ALL--穿刺針(SN)
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 1
         WHEN @dataTypeOrder = ''2'' THEN 3
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''シングルニードル'' AS class,
		6 as class_data_order,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''''''' )
		END AS kind,
			CASE
			WHEN eqc.class_name IS NULL THEN
			''-1'' ELSE eqc.class_cd
		END AS class_cd,
		''医材'' AS do_action,
		eq.equipment_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
		CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
		COALESCE ( save.ind_unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4,
		''医療材料'' AS data_type_order,
		1 AS kind_order,
		eq.equipment_cd AS equipment_cd,
		eqc.class_cd AS equipment_class_cd,
		NULL AS medicine_cd,
		NULL AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
	WHERE
		save.supplies_source_class = ''0''
		and save.supplies_class = ''05''
	UNION ALL--血液回路
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 1
         WHEN @dataTypeOrder = ''2'' THEN 3
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''血液回路'' AS class,
		2 as class_data_order,
	CASE

			WHEN eqc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
		END AS kind,
			CASE
			WHEN eqc.class_name IS NULL THEN
			''-1'' ELSE eqc.class_cd
		END AS class_cd,
		''医材'' AS do_action,
		eq.equipment_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
		CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
		COALESCE ( save.ind_unit, '''' ) AS Unit,
		eq.in_hospital_cd_1,
		eq.in_hospital_cd_2,
		eq.in_hospital_cd_3,
		eq.in_hospital_cd_4,
		''医療材料'' AS data_type_order,
		1 AS kind_order,
		eq.equipment_cd AS equipment_cd,
		eqc.class_cd AS equipment_class_cd,
		NULL AS medicine_cd,
		NULL AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
	WHERE
		save.supplies_source_class = ''0''
		and save.supplies_class = ''00''
	UNION ALL--医材
	(SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
			WHEN @dataTypeOrder = ''1'' THEN 1
			WHEN @dataTypeOrder = ''2'' THEN 3
			WHEN @dataTypeOrder = ''3'' THEN 3
			WHEN @dataTypeOrder = ''4'' THEN 2
			WHEN @dataTypeOrder = ''5'' THEN 1
			ELSE 1  END AS disp_order
		, treat_date
		, kur_cd
		, kur_name
		, bed_cd
		, bed_name
		, pat_id
		, class
		, class_data_order
		, kind
		, class_cd
		, ''医材'' AS do_action
		, NAME
		, code
		, SUM(equInfo.ind_rst_value) AS Amount
		, Unit
		, in_hospital_cd_1
		, in_hospital_cd_2
		, in_hospital_cd_3
		, in_hospital_cd_4
		, ''医療材料'' AS data_type_order
		,	1 AS kind_order
		, code AS equipment_cd
		, class_cd AS equipment_class_cd
		, NULL AS medicine_cd
		, NULL AS medicine_class_cd
		, NULL AS dialyzer_cd
	FROM (
		SELECT
			save.supplies_base_date as treat_date,
			save.kur_cd,
			COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
			save.bed_cd,
			COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
			save.pat_id,
			CASE
				WHEN eqc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
				END AS class,
				12 as class_data_order,
			CASE
				WHEN eqc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
				END AS kind,
			CASE
				WHEN eqc.class_name IS NULL THEN
				''-1'' ELSE eqc.class_cd
				END AS class_cd,
			eq.equipment_name AS NAME,
			TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
			CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS ind_rst_value ,
      COALESCE ( save.ind_unit, '''' ) AS Unit,
			eq.in_hospital_cd_1,
			eq.in_hospital_cd_2,
			eq.in_hospital_cd_3,
			eq.in_hospital_cd_4
		FROM
			save
			INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = eq.equipment_cd
			AND eq.class_cd IN ( @eqIds )
			LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		WHERE
			save.supplies_source_class = ''2''
      and save.supplies_class = ''11''
		UNION ALL -- ダイアライザ（医材）
		SELECT
			save.supplies_base_date as treat_date,
			save.kur_cd,
			COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
			save.bed_cd,
			COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
			save.pat_id,
			''ダイアライザ'' AS class,
			12 as class_data_order,
			CASE WHEN dz.model_number IS NOT NULL THEN
			''ダイアライザ'' ELSE NULL
		   END AS kind,
			''0'' AS class_cd,
			dz.model_number NAME,
			TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
			CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS ind_rst_value ,
      COALESCE ( save.ind_unit, '''' ) AS Unit,
			dz.in_hospital_cd_1,
			dz.in_hospital_cd_2,
			dz.in_hospital_cd_3,
			dz.in_hospital_cd_4
		FROM
			save
			INNER JOIN dz ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = dz.dialyzer_cd
		  AND dz.dialyzer_cd IN ( @diaIds )
	  WHERE
		save.supplies_source_class = ''2''
		and save.supplies_class = ''01''	
	) equInfo
	GROUP BY
		treat_date,
		kind,
		class_cd,
		class,
		class_data_order,
		do_action,
		NAME,
		code,
		kur_cd,
		kur_name,
		bed_cd,
		bed_name,
		Unit,
		pat_id,
		disp_order,
		in_hospital_cd_1,
		in_hospital_cd_2,
		in_hospital_cd_3,
		in_hospital_cd_4,
		data_type_order,
		kind_order
	ORDER BY
		disp_order,
		kind,
		class_cd,
		do_action,
		data_type_order,
		kind_order,
		code,
		NAME,
		kur_cd,
		kur_name,
		bed_cd,
		bed_name,
		pat_id
	)
	UNION ALL--抗凝固剤
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 1
			WHEN @dataTypeOrder = ''1'' THEN 2
			WHEN @dataTypeOrder = ''2'' THEN 2
			WHEN @dataTypeOrder = ''3'' THEN 1
			WHEN @dataTypeOrder = ''4'' THEN 3
			WHEN @dataTypeOrder = ''5'' THEN 3
			ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''抗凝固剤'' AS class,
		9 as class_data_order,
		CASE
			WHEN mdc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
			END AS kind,
		CASE
			WHEN mdc.class_name IS NULL THEN
			''-1'' ELSE mdc.class_cd
			END AS class_cd,
		''通常薬剤'' AS do_action,
		md.medicine_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
    CAST(
      CASE 
        WHEN NULLIF(save.receipt_value, '''') IS NULL 
             OR CAST(NULLIF(save.receipt_value, '''') AS DECIMAL) = 0 
        THEN NULLIF(save.ind_rst_value, '''') 
        ELSE NULLIF(save.receipt_value, '''') 
      END 
    AS DECIMAL) AS Amount,
    CASE 
      WHEN NULLIF(save.receipt_value, '''') IS NULL 
           OR CAST(NULLIF(save.receipt_value, '''') AS DECIMAL) = 0 
      THEN COALESCE(save.ind_unit, '''') 
      ELSE save.receipt_unit 
    END AS Unit,
		md.in_hospital_cd_1,
		md.in_hospital_cd_2,
		md.in_hospital_cd_3,
		md.in_hospital_cd_4,
		''薬剤'' AS data_type_order,
		1 AS kind_order,
		NULL AS equipment_cd,
		NULL AS equipment_class_cd,
		md.medicine_cd :: TEXT AS medicine_cd,
		mdc.class_cd :: TEXT AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN md ON TO_NUMBER( save.supplies_cd, ''99999999'' ) = md.medicine_cd
		AND md.class_cd IN ( @medIds )
		LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
	WHERE
	  save.supplies_source_class = ''0''
		and save.supplies_class = ''10''
	UNION ALL--抗凝固剤調製薬剤
	SELECT
				CASE WHEN @dataTypeOrder = ''0'' THEN 1
             WHEN @dataTypeOrder = ''1'' THEN 2
             WHEN @dataTypeOrder = ''2'' THEN 2
             WHEN @dataTypeOrder = ''3'' THEN 1
             WHEN @dataTypeOrder = ''4'' THEN 3
             WHEN @dataTypeOrder = ''5'' THEN 3
             ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
        ''抗凝固剤'' AS class,
				9 as class_data_order,
			CASE

					WHEN mdc.class_name IS NULL THEN
					''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS kind,
							CASE
			WHEN mdc.class_name IS NULL THEN
			''-1'' ELSE mdc.class_cd
		END AS class_cd,
		''通常薬剤'' AS do_action,
				md.medicine_name AS NAME,
				TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
    CAST(
      CASE 
        WHEN NULLIF(save.receipt_value, '''') IS NULL 
             OR CAST(NULLIF(save.receipt_value, '''') AS DECIMAL) = 0 
        THEN NULLIF(save.ind_rst_value, '''') 
        ELSE NULLIF(save.receipt_value, '''') 
      END 
    AS DECIMAL) AS Amount,
    CASE 
      WHEN NULLIF(save.receipt_value, '''') IS NULL 
           OR CAST(NULLIF(save.receipt_value, '''') AS DECIMAL) = 0 
      THEN COALESCE(save.ind_unit, '''') 
      ELSE save.receipt_unit 
    END AS Unit,
						md.in_hospital_cd_1,
						md.in_hospital_cd_2,
						md.in_hospital_cd_3,
						md.in_hospital_cd_4,
				''薬剤'' AS data_type_order,
				1 AS kind_order,
				NULL AS equipment_cd,
				NULL AS equipment_class_cd,
				mdx.medicine_mix_cd :: TEXT AS medicine_cd,
				mdc.class_cd :: TEXT AS medicine_class_cd,
			  NULL AS dialyzer_cd
					FROM
						save 
						INNER JOIN mdx ON mdx.medicine_mix_cd = TO_NUMBER( save.medicine_mix_cd, ''999999999999'' )
						INNER JOIN md ON TO_NUMBER( save.supplies_cd, ''99999999'' )  = md.medicine_cd
						AND mdx.class_cd IN ( @medIds )
						LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
					WHERE
					save.supplies_source_class = ''0''
		      and save.supplies_class = ''22''
	UNION ALL--透析液
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 1
             WHEN @dataTypeOrder = ''1'' THEN 2
             WHEN @dataTypeOrder = ''2'' THEN 2
             WHEN @dataTypeOrder = ''3'' THEN 1
             WHEN @dataTypeOrder = ''4'' THEN 3
             WHEN @dataTypeOrder = ''5'' THEN 3
             ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''透析液'' AS class,
		10 as class_data_order,
	CASE

			WHEN mdc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
		END AS kind,
			CASE
			WHEN mdc.class_name IS NULL THEN
			''-1'' ELSE mdc.class_cd
		END AS class_cd,
		''通常薬剤'' AS do_action,
		md.medicine_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
		CAST ( save.receipt_value AS DECIMAL )  AS Amount,
		COALESCE ( save.receipt_unit, '''' ) AS Unit,
		md.in_hospital_cd_1,
		md.in_hospital_cd_2,
		md.in_hospital_cd_3,
		md.in_hospital_cd_4,
		''薬剤'' AS data_type_order,
		1 AS kind_order,
		NULL AS equipment_cd,
		NULL AS equipment_class_cd,
		md.medicine_cd :: TEXT AS medicine_cd,
		mdc.class_cd :: TEXT AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN md ON TO_NUMBER( save.supplies_cd, ''99999999'' )  = md.medicine_cd
		AND md.class_cd IN ( @medIds )
		LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
		WHERE
	  save.supplies_source_class = ''0''
		and save.supplies_class = ''08''
	UNION ALL--補液
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 1
             WHEN @dataTypeOrder = ''1'' THEN 2
             WHEN @dataTypeOrder = ''2'' THEN 2
             WHEN @dataTypeOrder = ''3'' THEN 1
             WHEN @dataTypeOrder = ''4'' THEN 3
             WHEN @dataTypeOrder = ''5'' THEN 3
             ELSE 1  END AS disp_order,
		save.supplies_base_date as treat_date,
		save.kur_cd,
		COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
		save.bed_cd,
		COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
		save.pat_id,
    ''補液'' AS class,
		11 as class_data_order,
	CASE

			WHEN mdc.class_name IS NULL THEN
			''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
		END AS kind,
					CASE
			WHEN mdc.class_name IS NULL THEN
			''-1'' ELSE mdc.class_cd
		END AS class_cd,
		''通常薬剤'' AS do_action,
		md.medicine_name AS NAME,
		TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
		CAST ( save.receipt_value AS DECIMAL )  AS Amount,
		COALESCE ( save.receipt_unit, '''' ) AS Unit,
		md.in_hospital_cd_1,
		md.in_hospital_cd_2,
		md.in_hospital_cd_3,
		md.in_hospital_cd_4,
		''薬剤'' AS data_type_order,
		1 AS kind_order,
		NULL AS equipment_cd,
		NULL AS equipment_class_cd,
		md.medicine_cd :: TEXT AS medicine_cd,
		mdc.class_cd :: TEXT AS medicine_class_cd,
		NULL AS dialyzer_cd
	FROM
		save
		INNER JOIN md ON TO_NUMBER( save.supplies_cd, ''99999999'' )  = md.medicine_cd
		AND md.class_cd IN ( @medIds )
		LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
	WHERE
	  save.supplies_source_class = ''0''
		and save.supplies_class = ''09''
	UNION ALL--投薬
	(SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 1
			WHEN @dataTypeOrder = ''1'' THEN 2
			WHEN @dataTypeOrder = ''2'' THEN 2
			WHEN @dataTypeOrder = ''3'' THEN 1
			WHEN @dataTypeOrder = ''4'' THEN 3
			WHEN @dataTypeOrder = ''5'' THEN 3
			ELSE 1  END AS disp_order
		, treat_date
		, kur_cd
		, kur_name
		, bed_cd
		, bed_name
		, pat_id
		, class
		, class_data_order
		, kind
		, class_cd
		, ''通常薬剤'' AS do_action
		, NAME
		, code
		, SUM(medInfo.ind_rst_value) AS Amount
		, Unit
		, in_hospital_cd_1
		, in_hospital_cd_2
		, in_hospital_cd_3
		, in_hospital_cd_4
		, ''薬剤'' AS data_type_order
		,	1 AS kind_order
		, NULL AS equipment_cd
		, NULL AS equipment_class_cd
		, code::TEXT AS medicine_cd
		, class_cd::TEXT AS medicine_class_cd
		, NULL AS dialyzer_cd
	FROM (
		SELECT
			save.supplies_base_date as treat_date,
			save.kur_cd,
			COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
			save.bed_cd,
			COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
			save.pat_id,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS class,
				13 as class_data_order,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS kind,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''-1'' ELSE mdc.class_cd
				END AS class_cd,
			md.medicine_name AS NAME,
			TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
			CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS ind_rst_value ,
			COALESCE ( save.ind_unit, '''' ) AS Unit,
			md.in_hospital_cd_1,
			md.in_hospital_cd_2,
			md.in_hospital_cd_3,
			md.in_hospital_cd_4
		FROM
			save
			INNER JOIN md ON TO_NUMBER( save.supplies_cd, ''99999999'' ) = md.medicine_cd
			AND md.class_cd IN ( @medIds )
			LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
		WHERE
			save.supplies_source_class = ''1''
		and save.supplies_class = ''12''
	) medInfo
	GROUP BY
		treat_date,
		kind,
		class_cd,
		class,
		class_data_order,
		do_action,
		NAME,
		code,
		kur_cd,
		kur_name,
		bed_cd,
		bed_name,
		Unit,
		pat_id,
		disp_order,
		in_hospital_cd_1,
		in_hospital_cd_2,
		in_hospital_cd_3,
		in_hospital_cd_4,
		data_type_order,
		kind_order
	ORDER BY
		disp_order,
		kind,
		class_cd,
		do_action,
		data_type_order,
		kind_order,
		code,
		NAME,
		kur_cd,
		kur_name,
		bed_cd,
		bed_name,
		pat_id
	)
	UNION ALL--投薬調製薬剤
	(SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 1
			WHEN @dataTypeOrder = ''1'' THEN 2
			WHEN @dataTypeOrder = ''2'' THEN 2
			WHEN @dataTypeOrder = ''3'' THEN 1
			WHEN @dataTypeOrder = ''4'' THEN 3
			WHEN @dataTypeOrder = ''5'' THEN 3
			ELSE 1  END AS disp_order
		, treat_date
		, kur_cd
		, kur_name
		, bed_cd
		, bed_name
		, pat_id
		, class
		, class_data_order
		, kind
		, class_cd
		, ''通常薬剤'' AS do_action
		, NAME
		, code
		, SUM(medInfo.ind_rst_value) AS Amount
		, Unit
		, in_hospital_cd_1
		, in_hospital_cd_2
		, in_hospital_cd_3
		, in_hospital_cd_4
		, ''薬剤'' AS data_type_order
		,	1 AS kind_order
		, NULL AS equipment_cd
		, NULL AS equipment_class_cd
		, code::TEXT AS medicine_cd
		, class_cd::TEXT AS medicine_class_cd
		, NULL AS dialyzer_cd
	FROM (
		SELECT
			save.supplies_base_date as treat_date,
			save.kur_cd,
			COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
			save.bed_cd,
			COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
			save.pat_id,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS class,
				13 as class_data_order,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS kind,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''-1'' ELSE mdc.class_cd
				END AS class_cd,
			md.medicine_name AS NAME,
			TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
			CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS ind_rst_value ,
			COALESCE ( save.ind_unit, '''' ) AS Unit,
			md.in_hospital_cd_1,
			md.in_hospital_cd_2,
			md.in_hospital_cd_3,
			md.in_hospital_cd_4
		FROM
			save
			INNER JOIN md ON TO_NUMBER( save.supplies_cd, ''99999999'' )  = md.medicine_cd
			AND md.class_cd IN ( @medIds )
			LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
		WHERE
			save.supplies_source_class = ''1''
		and save.supplies_class = ''20''
	) medInfo
	GROUP BY
		treat_date,
		kind,
		class_cd,
		class,
		class_data_order,
		do_action,
		NAME,
		code,
		kur_cd,
		kur_name,
		bed_cd,
		bed_name,
		Unit,
		pat_id,
		disp_order,
		in_hospital_cd_1,
		in_hospital_cd_2,
		in_hospital_cd_3,
		in_hospital_cd_4,
		data_type_order,
		kind_order
	ORDER BY
		disp_order,
		kind,
		class_cd,
		do_action,
		data_type_order,
		kind_order,
		code,
		NAME,
		kur_cd,
		kur_name,
		bed_cd,
		bed_name,
		pat_id
	)
	) AS EquipmentList
	LEFT OUTER JOIN medic ON medic.medic_code :: TEXT = EquipmentList.medicine_class_cd
	LEFT OUTER JOIN equic ON equic.equic_code = EquipmentList.equipment_class_cd
	LEFT OUTER JOIN dia ON dia.dia_code = EquipmentList.dialyzer_cd
	LEFT OUTER JOIN medi_mix ON medi_mix.medi_mix_code :: TEXT = EquipmentList.medicine_class_cd
	LEFT OUTER JOIN bed_sort AS bed ON bed.bed_code = EquipmentList.bed_cd
) 
SELECT * from result_all as res @orderBy, bed_order ASC
', 2, '[]', '1', '{"applications": [1]}', '{"classes": [6]}', '配布リスト(物品)(分解)（SQL206降順）', '2025-03-19 18:29:56.857', CURRENT_TIMESTAMP, NULL);
