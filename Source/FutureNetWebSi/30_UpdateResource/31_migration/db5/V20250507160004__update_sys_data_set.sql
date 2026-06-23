DELETE FROM "ntss"."sys_data_set" where sql_cd in (10,207,16,17);
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
    kind;', 2, '[{"preview": "1", "can_calc": "", "data_code": "kur_cd", "data_name": "クールコード", "data_type": "decimal", "conv_table": [], "data_class": "ベッド情報", "field_name": "kur_cd", "disp_format": "0", "data_category": "配布リスト(ベッド)", "facility_filter_type": ""}, {"preview": "午後", "can_calc": "", "data_code": "kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "kur_name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": ""}, {"preview": "北1", "can_calc": "", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "bed_name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": ""}, {"preview": "123456789012", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "hosp_pat_id", "target_var": "@patId"}, "data_code": "hosp_pat_id", "data_name": "患者ID", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "pat_id", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "テスト患者1", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_name", "target_var": "@patId"}, "data_code": "pat_id_to_name", "data_name": "患者名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "pat_id_to_name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "医材・薬剤", "can_calc": "0", "data_code": "kind", "data_name": "分類名称", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "kind", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "ダイアライザ", "can_calc": "0", "data_code": "class", "data_name": "データ分類", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "class", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "テスト医材・薬剤1", "can_calc": "0", "data_code": "name", "data_name": "型番･名称", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "物品情報", "field_name": "amount", "disp_format": "0", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "個", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "unit", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_1", "data_name": "院内コード", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_1", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_2", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_3", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_4", "data_name": "院内コード4", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_4", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [5]}', '配布リスト(ベッド)', '2024-11-22 16:21:00', CURRENT_TIMESTAMP, NULL);
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
    kind;', 2, '[{"preview": "1", "can_calc": "", "data_code": "kur_cd", "data_name": "クールコード", "data_type": "decimal", "conv_table": [], "data_class": "ベッド情報(分解)", "field_name": "kur_cd", "disp_format": "0", "data_category": "配布リスト(ベッド)", "facility_filter_type": ""}, {"preview": "午後", "can_calc": "", "data_code": "kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報(分解)", "field_name": "kur_name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": ""}, {"preview": "北1", "can_calc": "", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報(分解)", "field_name": "bed_name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": ""}, {"preview": "123456789012", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "hosp_pat_id", "target_var": "@patId"}, "data_code": "hosp_pat_id", "data_name": "患者ID", "data_type": "string", "conv_table": [], "data_class": "ベッド情報(分解)", "field_name": "pat_id", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "テスト患者1", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_name", "target_var": "@patId"}, "data_code": "pat_id_to_name", "data_name": "患者名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報(分解)", "field_name": "pat_id_to_name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "医材・薬剤", "can_calc": "0", "data_code": "kind", "data_name": "分類名称", "data_type": "string", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "kind", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "ダイアライザ", "can_calc": "0", "data_code": "class", "data_name": "データ分類", "data_type": "string", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "class", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "テスト医材・薬剤1", "can_calc": "0", "data_code": "name", "data_name": "型番･名称", "data_type": "string", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "amount", "disp_format": "0", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "個", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "unit", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_1", "data_name": "院内コード", "data_type": "string", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "in_hospital_cd_1", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "in_hospital_cd_2", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "in_hospital_cd_3", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_4", "data_name": "院内コード4", "data_type": "string", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "in_hospital_cd_4", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [5]}', '配布リスト(ベッド)（分解）', '2020-01-11 13:28:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (16, 'WITH plan_time AS (
    SELECT
        om.ord_no,
        om.ind_cond_info :: json #>> ''{1, value}'' AS plan_time,
        ( pat_unique.physical_info :: json ->> 0 ) :: json ->> ''dw'' || '' Kg'' AS cond_dw,
        om.ind_cond_info :: json #>> ''{3, value}'' || '' Kg'' AS cond_tg_wei,
        case when om.rst_dialysis_state = ''0'' 
        then mst_treatment.treatment_name
        else om.ind_treatment_name end AS cond_tre_nm,
        om.ind_cond_info :: json #>> ''{14, value}'' || '' mL/min'' AS cond_bld_fl
    FROM
        ord_main om
        INNER JOIN pat_unique ON om.pat_id = pat_unique.pat_id
        AND pat_unique.is_del = ''0''
        INNER JOIN mst_treatment on om.ind_treatment_cd = mst_treatment.treatment_cd
        AND mst_treatment.is_del = ''0'' 
        AND mst_treatment.is_disp = ''1''
        AND mst_treatment.facility_cd = @facilityCd
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
        facility_cd = @facilityCd
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
        facility_cd = @facilityCd
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
        facility_cd = @facilityCd
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
        facility_cd = @facilityCd
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
        facility_cd = @facilityCd
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
        facility_cd = @facilityCd
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
        facility_cd = @facilityCd
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
        facility_cd = @facilityCd
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
        facility_cd = @facilityCd
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
        facility_cd = @facilityCd
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
        facility_cd = @facilityCd
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
        class_cd,
        do_action,
        data_type_order,
        kind_order,
        code,
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
            CASE WHEN @dataTypeOrder = ''0'' THEN 2
           WHEN @dataTypeOrder = ''1'' THEN 3
           WHEN @dataTypeOrder = ''2'' THEN 1
           WHEN @dataTypeOrder = ''3'' THEN 1
           WHEN @dataTypeOrder = ''4'' THEN 2
           WHEN @dataTypeOrder = ''5'' THEN 3
           ELSE 1  END AS disp_order,
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
            ''0'' AS class_cd,
            ''ダイアライザ'' AS do_action,
            ''医療材料'' AS data_type_order,
            2 AS kind_order,
            dz.dialyzer_cd as code,
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
        CASE WHEN @dataTypeOrder = ''0'' THEN 2
           WHEN @dataTypeOrder = ''1'' THEN 3
           WHEN @dataTypeOrder = ''2'' THEN 1
           WHEN @dataTypeOrder = ''3'' THEN 1
           WHEN @dataTypeOrder = ''4'' THEN 2
           WHEN @dataTypeOrder = ''5'' THEN 3
           ELSE 1  END AS disp_order,
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
            eqc.class_cd AS class_cd,
            ''医材'' as do_action,
            ''医療材料'' AS data_type_order,
            1 AS kind_order,
            eq.equipment_cd as code,
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
            CASE WHEN @dataTypeOrder = ''0'' THEN 2
           WHEN @dataTypeOrder = ''1'' THEN 3
           WHEN @dataTypeOrder = ''2'' THEN 1
           WHEN @dataTypeOrder = ''3'' THEN 1
           WHEN @dataTypeOrder = ''4'' THEN 2
           WHEN @dataTypeOrder = ''5'' THEN 3
           ELSE 1  END AS disp_order,
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
            eqc.class_cd AS class_cd,
            ''医材'' as do_action,
            ''医療材料'' AS data_type_order,
            1 AS kind_order,
            eq.equipment_cd as code,
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
            CASE WHEN @dataTypeOrder = ''0'' THEN 2
           WHEN @dataTypeOrder = ''1'' THEN 3
           WHEN @dataTypeOrder = ''2'' THEN 1
           WHEN @dataTypeOrder = ''3'' THEN 1
           WHEN @dataTypeOrder = ''4'' THEN 2
           WHEN @dataTypeOrder = ''5'' THEN 3
           ELSE 1  END AS disp_order,
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
            eqc.class_cd AS class_cd,
            ''医材'' as do_action,
            ''医療材料'' AS data_type_order,
            1 AS kind_order,
            eq.equipment_cd as code,
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
            CASE WHEN @dataTypeOrder = ''0'' THEN 2
           WHEN @dataTypeOrder = ''1'' THEN 3
           WHEN @dataTypeOrder = ''2'' THEN 1
           WHEN @dataTypeOrder = ''3'' THEN 1
           WHEN @dataTypeOrder = ''4'' THEN 2
           WHEN @dataTypeOrder = ''5'' THEN 3
           ELSE 1  END AS disp_order,
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
            eqc.class_cd AS class_cd,
            ''医材'' as do_action,
            ''医療材料'' AS data_type_order,
            1 AS kind_order,
            eq.equipment_cd as code,
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
            CASE WHEN @dataTypeOrder = ''0'' THEN 2
           WHEN @dataTypeOrder = ''1'' THEN 3
           WHEN @dataTypeOrder = ''2'' THEN 1
           WHEN @dataTypeOrder = ''3'' THEN 1
           WHEN @dataTypeOrder = ''4'' THEN 2
           WHEN @dataTypeOrder = ''5'' THEN 3
           ELSE 1  END AS disp_order,
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
            eqc.class_cd AS class_cd,
            ''医材'' as do_action,
            ''医療材料'' AS data_type_order,
            1 AS kind_order,
            eq.equipment_cd as code,
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
            CASE WHEN @dataTypeOrder = ''0'' THEN 2
           WHEN @dataTypeOrder = ''1'' THEN 3
           WHEN @dataTypeOrder = ''2'' THEN 1
           WHEN @dataTypeOrder = ''3'' THEN 1
           WHEN @dataTypeOrder = ''4'' THEN 2
           WHEN @dataTypeOrder = ''5'' THEN 3
           ELSE 1  END AS disp_order,
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
            eqc.class_cd AS class_cd,
            ''医材'' as do_action,
            ''医療材料'' AS data_type_order,
            1 AS kind_order,
            eq.equipment_cd as code,
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
            CASE WHEN @dataTypeOrder = ''0'' THEN 2
           WHEN @dataTypeOrder = ''1'' THEN 3
           WHEN @dataTypeOrder = ''2'' THEN 1
           WHEN @dataTypeOrder = ''3'' THEN 1
           WHEN @dataTypeOrder = ''4'' THEN 2
           WHEN @dataTypeOrder = ''5'' THEN 3
           ELSE 1  END AS disp_order,
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
            eqc.class_cd AS class_cd,
            ''医材'' as do_action,
            ''医療材料'' AS data_type_order,
            1 AS kind_order,
            eq.equipment_cd as code,
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
            AND eq.class_cd IN ( @eqIds ) UNION ALL--医材(ダイアライザ)
      SELECT
                    CASE WHEN @dataTypeOrder = ''0'' THEN 2
           WHEN @dataTypeOrder = ''1'' THEN 3
           WHEN @dataTypeOrder = ''2'' THEN 1
           WHEN @dataTypeOrder = ''3'' THEN 1
           WHEN @dataTypeOrder = ''4'' THEN 2
           WHEN @dataTypeOrder = ''5'' THEN 3
           ELSE 1  END AS disp_order,
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
                    ''0'' AS class_cd,
                    ''医材'' as do_action,
                    ''医療材料'' AS data_type_order,
                    1 AS kind_order,
                    dz.dialyzer_cd as code,
          dz.model_number AS NAME,
                    ( CAST( eqi ->> ''amount'' AS DECIMAL) ) AS Amount,
                    COALESCE (eqi ->> ''amount'',''本'') AS Unit,
                    NULL AS function_class,
                    NULL AS area,
                    NULL AS ufr,
                    NULL AS koa,
                    NULL AS material,
                    NULL AS wetdry,
                    ''ダイアライザ'' AS class_name,
                    NULL AS Anticoagulant_name,
                    om.ord_no,
                    dz.in_hospital_cd_1,
          dz.in_hospital_cd_2,
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
                    concat ( eqi ->> ''amount'', ''本'' ) AS num_unit,
                    NULL AS cond_va_dir,
                    NULL AS cond_va,
                    NULL AS equip_pnc_cls,
                    ''Equip'' AS class_ename
                FROM
                    ord_main AS om
                    CROSS JOIN LATERAL json_array_elements ( om.ind_equip_info :: json ) eqi
          INNER JOIN mst_dialyzer dz ON TO_NUMBER( eqi ->> ''cd'', ''9999999999'' ) = dz.dialyzer_cd
          AND dz.is_del = ''0''
          AND dz.is_disp = ''1''
                    LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd = kr.kur_cd
                    AND kr.is_del = ''0''
                    LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd = bd.bed_cd
                    AND bd.is_del = ''0''
                    AND bd.is_disp = ''1''
                WHERE
                    om.ord_no IN ( @ordNos )
                    AND om.is_del = ''0''
                    AND dz.dialyzer_cd IN ( @diaIds ) UNION ALL--医材
                SELECT
                    CASE WHEN @dataTypeOrder = ''0'' THEN 2
           WHEN @dataTypeOrder = ''1'' THEN 3
           WHEN @dataTypeOrder = ''2'' THEN 1
           WHEN @dataTypeOrder = ''3'' THEN 1
           WHEN @dataTypeOrder = ''4'' THEN 2
           WHEN @dataTypeOrder = ''5'' THEN 3
           ELSE 1  END AS disp_order,
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
                    eqc.class_cd AS class_cd,
                    ''医材'' as do_action,
                    ''医療材料'' AS data_type_order,
                    1 AS kind_order,
                    eq.equipment_cd as code,
                    eq.equipment_name AS NAME,
                    ( CAST( eqi ->> ''amount'' AS DECIMAL) ) AS Amount,
                    COALESCE ( eq.unit, '''' ) AS Unit,
                    NULL AS function_class,
                    NULL AS area,
                    NULL AS ufr,
                    NULL AS koa,
                    NULL AS material,
                    NULL AS wetdry,
                    COALESCE ( eqc.class_name, ''未登録'' ) AS class_name,
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
                    AND eq.class_cd IN ( @eqIds )  UNION ALL--抗凝固剤(調製薬剤)
            SELECT
                CASE WHEN @dataTypeOrder = ''0'' THEN 3
             WHEN @dataTypeOrder = ''1'' THEN 2
             WHEN @dataTypeOrder = ''2'' THEN 2
             WHEN @dataTypeOrder = ''3'' THEN 3
             WHEN @dataTypeOrder = ''4'' THEN 1
             WHEN @dataTypeOrder = ''5'' THEN 1
             ELSE 1  END AS disp_order,
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
                mdc.class_cd AS class_cd,
                ''調製薬剤'' as do_action,
                ''薬剤'' AS data_type_order,
                2 AS kind_order,
                mmx.medicine_mix_cd as code,
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
                AND om.ind_cond_info :: json #>> ''{25, medicine_type}'' = ''2''
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
                AND mmx.class_cd IN ( @medIds ) UNION ALL--投薬(調製薬剤)
                SELECT
                    CASE WHEN @dataTypeOrder = ''0'' THEN 3
             WHEN @dataTypeOrder = ''1'' THEN 2
             WHEN @dataTypeOrder = ''2'' THEN 2
             WHEN @dataTypeOrder = ''3'' THEN 3
             WHEN @dataTypeOrder = ''4'' THEN 1
             WHEN @dataTypeOrder = ''5'' THEN 1
             ELSE 1  END AS disp_order,
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
                    mdc.class_cd AS class_cd,
                    ''調製薬剤'' as do_action,
                    ''薬剤'' AS data_type_order,
                    2 AS kind_order,
                    mdx.medicine_mix_cd as code,
                    mdx.medicine_mix_name AS NAME,
                    CAST( om.amount AS DECIMAL) AS Amount,
                    COALESCE ( mdx.unit, '''' ) AS Unit,
                    NULL AS function_class,
                    NULL AS area,
                    NULL AS ufr,
                    NULL AS koa,
                    NULL AS material,
                    NULL AS wetdry,
                    COALESCE ( mdc.class_name, ''未登録'' ) AS class_name,
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
                    om.medicine_type = ''2'' AND mdx.medicine_mix_cd IS NOT NULL UNION ALL--透析液
        SELECT
            CASE WHEN @dataTypeOrder = ''0'' THEN 3
             WHEN @dataTypeOrder = ''1'' THEN 2
             WHEN @dataTypeOrder = ''2'' THEN 2
             WHEN @dataTypeOrder = ''3'' THEN 3
             WHEN @dataTypeOrder = ''4'' THEN 1
             WHEN @dataTypeOrder = ''5'' THEN 1
             ELSE 1  END AS disp_order,
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
            mdc.class_cd AS class_cd,
            ''通常薬剤'' as do_action,
            ''薬剤'' AS data_type_order,
            1 AS kind_order,
            md.medicine_cd as code,
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
            CASE WHEN @dataTypeOrder = ''0'' THEN 3
             WHEN @dataTypeOrder = ''1'' THEN 2
             WHEN @dataTypeOrder = ''2'' THEN 2
             WHEN @dataTypeOrder = ''3'' THEN 3
             WHEN @dataTypeOrder = ''4'' THEN 1
             WHEN @dataTypeOrder = ''5'' THEN 1
             ELSE 1  END AS disp_order,
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
            mdc.class_cd AS class_cd,
            ''通常薬剤'' as do_action,
            ''薬剤'' AS data_type_order,
            1 AS kind_order,
            md.medicine_cd as code,
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
            CASE WHEN @dataTypeOrder = ''0'' THEN 3
             WHEN @dataTypeOrder = ''1'' THEN 2
             WHEN @dataTypeOrder = ''2'' THEN 2
             WHEN @dataTypeOrder = ''3'' THEN 3
             WHEN @dataTypeOrder = ''4'' THEN 1
             WHEN @dataTypeOrder = ''5'' THEN 1
             ELSE 1  END AS disp_order,
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
            mdc.class_cd AS class_cd,
            ''通常薬剤'' as do_action,
            ''薬剤'' AS data_type_order,
            1 AS kind_order,
            md.medicine_cd as code,
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
                ( om.medicine_type = ''1'' AND md.class_cd IN ( @medIds ) ) UNION ALL--投薬(薬剤)
            SELECT
                CASE WHEN @dataTypeOrder = ''0'' THEN 3
             WHEN @dataTypeOrder = ''1'' THEN 2
             WHEN @dataTypeOrder = ''2'' THEN 2
             WHEN @dataTypeOrder = ''3'' THEN 3
             WHEN @dataTypeOrder = ''4'' THEN 1
             WHEN @dataTypeOrder = ''5'' THEN 1
             ELSE 1  END AS disp_order,
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
                mdc.class_cd AS class_cd,
                ''通常薬剤'' as do_action,
                ''薬剤'' AS data_type_order,
                1 AS kind_order,
                md.medicine_cd as code,
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
                    COALESCE ( mdc.class_name, ''未登録'' ) AS class_name,
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
                    ( om.medicine_type = ''1'' AND md.class_cd IN ( @medIds ) )
                ) AS EquipmentList
                INNER JOIN plan_time ON EquipmentList.ord_no = plan_time.ord_no
            ),
result_all AS (
 --採血管
        (SELECT
            date_trunc( ''day'',  ord_main.treat_date  :: TIMESTAMP) AS treat_date,
            NULL AS equipment_cd,
            NULL AS equipment_class_cd,
            NULL AS medicine_cd,
            NULL AS medicine_class_cd,
            ord_main.ind_kur_cd AS kur_cd,
            mst_kur.kur_name AS kur_name,
            mst_bed.bed_name AS bed_name,
            ord_main.ind_bed_cd AS bed_cd,
            P.pat_id,
            NULL AS kind,
            NULL AS class_cd,
            NULL AS do_action,
            ''検査'' AS data_type_order,
            1 AS kind_order,
            NULL AS code,
            spitz.spitz_name AS NAME,
            NULL AS amount,
            NULL AS unit,
            NULL AS function_class,
            NULL AS area,
            NULL AS ufr,
            NULL AS koa,
            NULL AS material,
            NULL AS wetdry,
            CASE WHEN @dataTypeOrder = ''0'' THEN 1
           WHEN @dataTypeOrder = ''1'' THEN 1
           WHEN @dataTypeOrder = ''2'' THEN 3
           WHEN @dataTypeOrder = ''3'' THEN 2
           WHEN @dataTypeOrder = ''4'' THEN 3
           WHEN @dataTypeOrder = ''5'' THEN 2
           ELSE 1  END AS disp_order,
            P.reg_order_class AS class_name,
            ''Exam'' AS class_ename,
            NULL AS anticoagulant_name,
            ord_main.plan_time,
          ord_main.cond_dw,
          ord_main.cond_tg_wei,
          ord_main.cond_tre_nm,
          ord_main.cond_bld_fl,
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
            spitz.label_print AS label_print,
            meim.is_in_hospital AS is_in_hospital ,
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
            P CROSS JOIN LATERAL jsonb_array_elements(P.order_exam_set_info) WITH ORDINALITY AS infoExam(exam_info, exam_index)
            LEFT OUTER JOIN mst_exam_set AS mest CROSS JOIN LATERAL json_array_elements ( mest.exam_item_info :: json) infoExamInfo
             ON infoExam.exam_info ->> ''set_cd'' = mest.exam_set_cd :: TEXT
            AND mest.is_del = ''0''
            AND mest.is_disp = ''1''
            AND mest.facility_cd = @facilityCd
            LEFT OUTER JOIN mst_exam_item AS meim on infoExamInfo ->> ''exam_item_cd'' = meim.exam_item_cd :: TEXT
            AND meim.is_del = ''0''
            AND meim.is_disp = ''1''
            AND mest.facility_cd = @facilityCd
            LEFT OUTER JOIN spi ON spi.spitz_code = meim.spitz_cd
            LEFT OUTER JOIN mst_spitz AS spitz ON spitz.spitz_cd = meim.spitz_cd
            left join
      ( SELECT
        ord_main.treat_date,
        ord_main.ind_kur_cd,
        ord_main.ind_bed_cd,
        ord_main.ord_no,
        ord_main.pat_id,
                ord_main.plan_time,
            ord_main.cond_dw,
            ord_main.cond_tg_wei,
            ord_main.cond_tre_nm,
            ord_main.cond_bld_fl
        FROM
        (
          SELECT
            ord_main.treat_date AS treat_date,
            ord_main.ind_kur_cd AS ind_kur_cd,
            ord_main.ind_bed_cd AS ind_bed_cd,
            ord_main.ord_no AS ord_no,
            ord_main.pat_id AS pat_id,
            ROW_NUMBER( ) OVER ( PARTITION BY ord_main.treat_date,ord_main.pat_id ORDER BY ord_main.ind_kur_cd ) AS row_num,
                        plan_time.plan_time,
                plan_time.cond_dw,
                plan_time.cond_tg_wei,
                plan_time.cond_tre_nm,
                plan_time.cond_bld_fl
          FROM
            ord_main 
                        inner join plan_time on ord_main.ord_no = plan_time.ord_no 
          WHERE
            ord_main.pat_id IN ( @patIds ) 
            AND ord_main.treat_date = @treatDate 
        ) AS ord_main 
        WHERE
          row_num = 1 
        ORDER BY
          ind_kur_cd 
      ) AS ord_main ON date_trunc( ''day'',  ord_main.treat_date  :: TIMESTAMP) = date_trunc( ''day'', P.reg_exam_date :: TIMESTAMP )
      and ord_main.pat_id = P.pat_id
            left join mst_kur on mst_kur.kur_cd = ord_main.ind_kur_cd
            left join mst_bed on mst_bed.bed_cd = ord_main.ind_bed_cd
            -- ベッドグループ
            LEFT OUTER JOIN mst_room_bed_group_1 AS rbg1 ON rbg1.bed_list :: jsonb @> ('''' || mst_bed.bed_cd) :: jsonb
            LEFT OUTER JOIN room_bed AS rb1 ON rbg1.room_bed_group_cd = rb1.room_bed_code
            -- 透析室
            LEFT OUTER JOIN mst_room_bed_group_2 AS rbg2 ON rbg2.bed_list :: jsonb @> ('''' || mst_bed.bed_cd) :: jsonb
            LEFT OUTER JOIN room_bed AS rb2 ON rbg2.room_bed_group_cd = rb2.room_bed_code
        WHERE
            spitz.spitz_name IS NOT NULL
            AND P.reg_order_class IN (@regOrderClass)
        AND
            1 in (@inspectIds)
        group by
            treat_date,
            ord_main.ind_kur_cd,
            mst_kur.kur_name,
            mst_bed.bed_name,
            ord_main.ind_bed_cd,
            P.pat_id,
            spitz.spitz_name,
            P.reg_order_class,
            spitz.label_print,
            meim.is_in_hospital,
            spi.spitz_order,
            data_type_order,
            plan_time,
          cond_dw,
          cond_tg_wei,
          cond_tre_nm,
          cond_bld_fl  
        ORDER BY
          spi.spitz_order)
     UNION ALL
          (SELECT
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
            bd.class_cd,
            bd.do_action,
            bd.data_type_order,
            bd.kind_order,
            bd.code,
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
            bd.class_cd,
            bd.do_action,
            bd.data_type_order,
            bd.kind_order,
            bd.code,
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
            dia.dia_order) UNION ALL
            (SELECT
            date_trunc( ''day'',  ord_main.treat_date  :: TIMESTAMP) AS treat_date,
            NULL AS equipment_cd,
            NULL AS equipment_class_cd,
            NULL AS medicine_cd,
            NULL AS medicine_class_cd,
            ord_main.ind_kur_cd AS kur_cd,
            mst_kur.kur_name AS kur_name,
            mst_bed.bed_name AS bed_name,
            ord_main.ind_bed_cd AS bed_cd,
            P.pat_id,
            NULL AS kind,
            NULL AS class_cd,
            NULL AS do_action,
            ''検査'' AS data_type_order,
            1 AS kind_order,
            NULL AS code,
            mest.exam_set_name AS NAME,
            NULL AS amount,
            NULL AS unit,
            NULL AS function_class,
            NULL AS area,
            NULL AS ufr,
            NULL AS koa,
            NULL AS material,
            NULL AS wetdry,
            CASE WHEN @dataTypeOrder = ''0'' THEN 1
           WHEN @dataTypeOrder = ''1'' THEN 1
           WHEN @dataTypeOrder = ''2'' THEN 3
           WHEN @dataTypeOrder = ''3'' THEN 2
           WHEN @dataTypeOrder = ''4'' THEN 3
           WHEN @dataTypeOrder = ''5'' THEN 2
           ELSE 1  END AS disp_order,
            P.reg_order_class AS class_name,
            ''Exam'' AS class_ename,
            NULL AS anticoagulant_name,
            ord_main.plan_time,
          ord_main.cond_dw,
          ord_main.cond_tg_wei,
          ord_main.cond_tre_nm,
          ord_main.cond_bld_fl,
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
            NULL AS is_in_hospital ,
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
            NULL AS spitz_order
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
            P CROSS JOIN LATERAL jsonb_array_elements(P.order_exam_set_info) WITH ORDINALITY AS infoExam(exam_info, exam_index)
            LEFT OUTER JOIN mst_exam_set AS mest CROSS JOIN LATERAL json_array_elements ( mest.exam_item_info :: json) infoExamInfo
             ON infoExam.exam_info ->> ''set_cd'' = mest.exam_set_cd :: TEXT
            AND mest.is_del = ''0''
            AND mest.is_disp = ''1''
            AND mest.facility_cd = @facilityCd
            LEFT OUTER JOIN mst_exam_item AS meim on infoExamInfo ->> ''exam_item_cd'' = meim.exam_item_cd :: TEXT
            AND meim.is_del = ''0''
            AND meim.is_disp = ''1''
            AND mest.facility_cd = @facilityCd
            LEFT OUTER JOIN spi ON spi.spitz_code = meim.spitz_cd
            left join
      ( SELECT
        ord_main.treat_date,
        ord_main.ind_kur_cd,
        ord_main.ind_bed_cd,
        ord_main.ord_no,
        ord_main.pat_id,
                ord_main.plan_time,
            ord_main.cond_dw,
            ord_main.cond_tg_wei,
            ord_main.cond_tre_nm,
            ord_main.cond_bld_fl
        FROM
        (
          SELECT
            ord_main.treat_date AS treat_date,
            ord_main.ind_kur_cd AS ind_kur_cd,
            ord_main.ind_bed_cd AS ind_bed_cd,
            ord_main.ord_no AS ord_no,
            ord_main.pat_id AS pat_id,
            ROW_NUMBER( ) OVER ( PARTITION BY ord_main.treat_date,ord_main.pat_id ORDER BY ord_main.ind_kur_cd ) AS row_num,
                        plan_time.plan_time,
                plan_time.cond_dw,
                plan_time.cond_tg_wei,
                plan_time.cond_tre_nm,
                plan_time.cond_bld_fl
          FROM
            ord_main 
                        inner join plan_time on ord_main.ord_no = plan_time.ord_no 
          WHERE
            ord_main.pat_id IN ( @patIds ) 
            AND ord_main.treat_date = @treatDate 
        ) AS ord_main 
        WHERE
          row_num = 1 
        ORDER BY
          ind_kur_cd 
      ) AS ord_main ON date_trunc( ''day'',  ord_main.treat_date  :: TIMESTAMP) = date_trunc( ''day'', P.reg_exam_date :: TIMESTAMP )
      and ord_main.pat_id = P.pat_id
            left join mst_kur on mst_kur.kur_cd = ord_main.ind_kur_cd
            left join mst_bed on mst_bed.bed_cd = ord_main.ind_bed_cd
            -- ベッドグループ
            LEFT OUTER JOIN mst_room_bed_group_1 AS rbg1 ON rbg1.bed_list :: jsonb @> ('''' || mst_bed.bed_cd) :: jsonb
            LEFT OUTER JOIN room_bed AS rb1 ON rbg1.room_bed_group_cd = rb1.room_bed_code
            -- 透析室
            LEFT OUTER JOIN mst_room_bed_group_2 AS rbg2 ON rbg2.bed_list :: jsonb @> ('''' || mst_bed.bed_cd) :: jsonb
            LEFT OUTER JOIN room_bed AS rb2 ON rbg2.room_bed_group_cd = rb2.room_bed_code
        WHERE
            P.reg_order_class IN (@regOrderClass)
            AND mest.exam_set_cd in (@esIds)
        group by
            treat_date,
            ord_main.ind_kur_cd,
            mst_kur.kur_name,
            mst_bed.bed_name,
            ord_main.ind_bed_cd,
            P.pat_id,
            P.reg_order_class,
            data_type_order,
            plan_time,
          cond_dw,
          cond_tg_wei,
          cond_tre_nm,
          cond_bld_fl,
          mest.exam_set_name) 
)            
SELECT * ,res.pat_id as pat_Id1 ,res.pat_id as pat_Id2 ,res.pat_id as pat_Id3 FROM result_all as res @orderBy', 2, '[{"preview": "午後", "can_calc": "", "data_code": "kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "透析予定", "field_name": "kur_name", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": ""}, {"preview": "北1", "can_calc": "", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "透析予定", "field_name": "bed_name", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": ""}, {"preview": "70%ブドウ糖注射液350ml", "can_calc": "0", "data_code": "name", "data_name": "名称/採血管名", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "name", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/01/01", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "透析予定", "field_name": "treat_date", "disp_format": "yyyy/MM/dd", "data_category": "ラベル", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "disp_order", "data_name": "分類", "data_type": "Integer", "conv_table": [], "data_class": "", "field_name": "disp_order", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "class_name", "data_name": "分類/検査区分", "data_type": "String", "conv_table": [{"code": "0", "disp": "その他", "item": "その他"}, {"code": "1", "disp": "透析前", "item": "透析前"}, {"code": "2", "disp": "透析後", "item": "透析後"}], "data_class": "物品情報", "field_name": "class_name", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "plan_time", "data_name": "透析時間", "data_type": "String", "conv_table": [], "data_class": "物品情報", "field_name": "plan_time", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_dw", "data_name": "DW", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_dw", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_tg_wei", "data_name": "目標体重", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_tg_wei", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_tre_nm", "data_name": "治療項目", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_tre_nm", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_bld_fl", "data_name": "血流量", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_bld_fl", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "function_class", "data_name": "機能分類", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "function_class", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "area", "data_name": "面積", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "area", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "ufr", "data_name": "UFR", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "ufr", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "koa", "data_name": "KOA", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "koa", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "material", "data_name": "材質", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "material", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "wetdry", "data_name": "DRYWET", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "wetdry", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "anticoagulant_name", "data_name": "抗凝固剤", "data_type": "String", "conv_table": [], "data_class": "", "field_name": "anticoagulant_name", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "equip_circuit", "data_name": "血液回路", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "equip_circuit", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ac_shot", "data_name": "ワンショット量", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_ac_shot", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ac_spd", "data_name": "持続速度", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_ac_spd", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ac_dur_total", "data_name": "持続総量", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_ac_dur_total", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_use", "data_name": "IP使用選択", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "cond_ip_use", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_start", "data_name": "IPスタート", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_start", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_spd", "data_name": "IP速度", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_spd", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_shot_st", "data_name": "自動ワンショット", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_shot_st", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_shot", "data_name": "IPワンショット量", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_shot", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_off", "data_name": "IP電源自動切り", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_off", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_off_tm", "data_name": "IP電源自動切り時間", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_off_tm", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_ok", "data_name": "IP電源OKモニタ切り", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_ok", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_ip_ok_tm", "data_name": "IP電源OKモニタ切り時間", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_ip_ok_tm", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_dl_fl", "data_name": "透析液流量", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_dl_fl", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_dl_am", "data_name": "透析液量", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_dl_am", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_dl_temp", "data_name": "透析温度", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_dl_temp", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_rl_am", "data_name": "補液量", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_rl_am", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_rl_sel", "data_name": "補液選択", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_rl_sel", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_rl_use", "data_name": "補液使用数", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_rl_use", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_rl_temp", "data_name": "補液温度", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_rl_temp", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_rl_spd", "data_name": "補液速度", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_rl_spd", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "medi_timing", "data_name": "投与時間帯", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "medi_timing", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "medi_proc", "data_name": "手技", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "medi_proc", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "1", "can_calc": "0", "data_code": "num_unit", "data_name": "数量・単位", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "num_unit", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_va_dir", "data_name": "VA方向", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_va_dir", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "cond_va", "data_name": "VA", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "cond_va", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "equip_pnc_cls", "data_name": "穿刺針区分", "data_type": "string", "conv_table": [], "data_class": "", "field_name": "equip_pnc_cls", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_1", "data_name": "院内コード", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_1", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_2", "disp_format": "", "data_category": "", "facility_table": "", "facility_filter_type": ""}, {"preview": "ベッドグループ1", "can_calc": "", "data_code": "room_bed_group_name_1", "data_name": "ベッドグループ名", "data_type": "string", "conv_table": [], "data_class": "透析予定", "field_name": "room_bed_group_name_1", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": ""}, {"preview": "透析室名１", "can_calc": "", "data_code": "room_bed_group_name_2", "data_name": "透析室名", "data_type": "string", "conv_table": [], "data_class": "透析予定", "field_name": "room_bed_group_name_2", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": ""}, {"preview": "ラベル印字項目", "can_calc": "0", "data_code": "label_print", "data_name": "ラベル印字項目(採血管)", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "label_print", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": "0"}, {"preview": "院内・院外", "can_calc": "0", "data_code": "is_in_hospital", "data_name": "院内・院外(採血管)", "data_type": "string", "conv_table": [{"code": "0", "disp": "院外", "item": "院外"}, {"code": "1", "disp": "院内", "item": "院内"}], "data_class": "物品情報", "field_name": "is_in_hospital", "disp_format": "", "data_category": "ラベル", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789012", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "hosp_pat_id", "target_var": "@patId"}, "data_code": "hosp_pat_id", "data_name": "患者ID", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "pat_id1", "disp_format": "", "data_category": "ラベル", "facility_filter_type": "0"}, {"preview": "テスト患者1", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_name", "target_var": "@patId"}, "data_code": "pat_name", "data_name": "氏名", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "pat_id2", "disp_format": "", "data_category": "ラベル", "facility_filter_type": "0"}, {"preview": "テスト患者1", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_name_kana", "target_var": "@patId"}, "data_code": "pat_name_kana", "data_name": "カナ氏名", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "pat_id3", "disp_format": "", "data_category": "ラベル", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [8]}', 'ラベル', '2020-03-17 14:17:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (17, 'WITH plan_time AS (
    SELECT 
        om.ord_no,
        om.ind_cond_info :: json #>> ''{1, value}'' AS plan_time,
        ( pat_unique.physical_info :: json ->> 0 ) :: json ->> ''dw'' || '' Kg'' AS cond_dw,
        om.ind_cond_info :: json #>> ''{3, value}'' || '' Kg'' AS cond_tg_wei,
        case when om.rst_dialysis_state = ''0'' 
        then mst_treatment.treatment_name
        else om.ind_treatment_name end AS cond_tre_nm,
        om.ind_cond_info :: json #>> ''{14, value}'' || '' mL/min'' AS cond_bld_fl
    FROM
        ord_main om
        INNER JOIN pat_unique ON om.pat_id = pat_unique.pat_id
        AND pat_unique.is_del = ''0''
        INNER JOIN mst_treatment on om.ind_treatment_cd = mst_treatment.treatment_cd
        AND mst_treatment.is_del = ''0'' 
        AND mst_treatment.is_disp = ''1''
        AND mst_treatment.facility_cd = @facilityCd
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
        facility_cd = @facilityCd
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
        facility_cd = @facilityCd
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
        facility_cd = @facilityCd
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
        facility_cd = @facilityCd
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
        facility_cd = @facilityCd
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
        facility_cd = @facilityCd
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
        facility_cd = @facilityCd
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
        facility_cd = @facilityCd
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
        facility_cd = @facilityCd
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
        facility_cd = @facilityCd
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
        facility_cd = @facilityCd
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
        class_cd,
        do_action,
        data_type_order,
        kind_order,
        code,
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
            CASE WHEN @dataTypeOrder = ''0'' THEN 2
           WHEN @dataTypeOrder = ''1'' THEN 1
           WHEN @dataTypeOrder = ''2'' THEN 3
           WHEN @dataTypeOrder = ''3'' THEN 3
           WHEN @dataTypeOrder = ''4'' THEN 2
           WHEN @dataTypeOrder = ''5'' THEN 1
           ELSE 1  END AS disp_order,
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
            ''0'' AS class_cd,
            ''ダイアライザ'' AS do_action,
            ''医療材料'' AS data_type_order,
            2 AS kind_order,
            dz.dialyzer_cd as code,
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
            CASE WHEN @dataTypeOrder = ''0'' THEN 2
           WHEN @dataTypeOrder = ''1'' THEN 1
           WHEN @dataTypeOrder = ''2'' THEN 3
           WHEN @dataTypeOrder = ''3'' THEN 3
           WHEN @dataTypeOrder = ''4'' THEN 2
           WHEN @dataTypeOrder = ''5'' THEN 1
           ELSE 1  END AS disp_order,
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
            eqc.class_cd AS class_cd,
            ''医材'' as do_action,
            ''医療材料'' AS data_type_order,
            1 AS kind_order,
            eq.equipment_cd as code,
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
            CASE WHEN @dataTypeOrder = ''0'' THEN 2
           WHEN @dataTypeOrder = ''1'' THEN 1
           WHEN @dataTypeOrder = ''2'' THEN 3
           WHEN @dataTypeOrder = ''3'' THEN 3
           WHEN @dataTypeOrder = ''4'' THEN 2
           WHEN @dataTypeOrder = ''5'' THEN 1
           ELSE 1  END AS disp_order,
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
            eqc.class_cd AS class_cd,
            ''医材'' as do_action,
            ''医療材料'' AS data_type_order,
            1 AS kind_order,
            eq.equipment_cd as code,
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
            CASE WHEN @dataTypeOrder = ''0'' THEN 2
           WHEN @dataTypeOrder = ''1'' THEN 1
           WHEN @dataTypeOrder = ''2'' THEN 3
           WHEN @dataTypeOrder = ''3'' THEN 3
           WHEN @dataTypeOrder = ''4'' THEN 2
           WHEN @dataTypeOrder = ''5'' THEN 1
           ELSE 1  END AS disp_order,
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
            eqc.class_cd AS class_cd,
            ''医材'' as do_action,
            ''医療材料'' AS data_type_order,
            1 AS kind_order,
            eq.equipment_cd as code,
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
            CASE WHEN @dataTypeOrder = ''0'' THEN 2
           WHEN @dataTypeOrder = ''1'' THEN 1
           WHEN @dataTypeOrder = ''2'' THEN 3
           WHEN @dataTypeOrder = ''3'' THEN 3
           WHEN @dataTypeOrder = ''4'' THEN 2
           WHEN @dataTypeOrder = ''5'' THEN 1
           ELSE 1  END AS disp_order,
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
            eqc.class_cd AS class_cd,
            ''医材'' as do_action,
            ''医療材料'' AS data_type_order,
            1 AS kind_order,
            eq.equipment_cd as code,
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
            CASE WHEN @dataTypeOrder = ''0'' THEN 2
           WHEN @dataTypeOrder = ''1'' THEN 1
           WHEN @dataTypeOrder = ''2'' THEN 3
           WHEN @dataTypeOrder = ''3'' THEN 3
           WHEN @dataTypeOrder = ''4'' THEN 2
           WHEN @dataTypeOrder = ''5'' THEN 1
           ELSE 1  END AS disp_order,
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
            eqc.class_cd AS class_cd,
            ''医材'' as do_action,
            ''医療材料'' AS data_type_order,
            1 AS kind_order,
            eq.equipment_cd as code,
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
            CASE WHEN @dataTypeOrder = ''0'' THEN 2
           WHEN @dataTypeOrder = ''1'' THEN 1
           WHEN @dataTypeOrder = ''2'' THEN 3
           WHEN @dataTypeOrder = ''3'' THEN 3
           WHEN @dataTypeOrder = ''4'' THEN 2
           WHEN @dataTypeOrder = ''5'' THEN 1
           ELSE 1  END AS disp_order,
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
            eqc.class_cd AS class_cd,
            ''医材'' as do_action,
            ''医療材料'' AS data_type_order,
            1 AS kind_order,
            eq.equipment_cd as code,
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
            CASE WHEN @dataTypeOrder = ''0'' THEN 2
           WHEN @dataTypeOrder = ''1'' THEN 1
           WHEN @dataTypeOrder = ''2'' THEN 3
           WHEN @dataTypeOrder = ''3'' THEN 3
           WHEN @dataTypeOrder = ''4'' THEN 2
           WHEN @dataTypeOrder = ''5'' THEN 1
           ELSE 1  END AS disp_order,
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
            eqc.class_cd AS class_cd,
            ''医材'' as do_action,
            ''医療材料'' AS data_type_order,
            1 AS kind_order,
            eq.equipment_cd as code,
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
            AND eq.class_cd IN ( @eqIds ) UNION ALL--医材(ダイアライザ)
      SELECT
                    CASE WHEN @dataTypeOrder = ''0'' THEN 2
           WHEN @dataTypeOrder = ''1'' THEN 3
           WHEN @dataTypeOrder = ''2'' THEN 1
           WHEN @dataTypeOrder = ''3'' THEN 1
           WHEN @dataTypeOrder = ''4'' THEN 2
           WHEN @dataTypeOrder = ''5'' THEN 3
           ELSE 1  END AS disp_order,
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
                    ''0'' AS class_cd,
                    ''医材'' as do_action,
                    ''医療材料'' AS data_type_order,
                    1 AS kind_order,
                    dz.dialyzer_cd as code,
          dz.model_number AS NAME,
                    ( CAST( eqi ->> ''amount'' AS DECIMAL) ) AS Amount,
                    COALESCE (eqi ->> ''amount'',''本'') AS Unit,
                    NULL AS function_class,
                    NULL AS area,
                    NULL AS ufr,
                    NULL AS koa,
                    NULL AS material,
                    NULL AS wetdry,
                    ''ダイアライザ'' AS class_name,
                    NULL AS Anticoagulant_name,
                    om.ord_no,
                    dz.in_hospital_cd_1,
          dz.in_hospital_cd_2,
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
                    concat ( eqi ->> ''amount'', ''本'' ) AS num_unit,
                    NULL AS cond_va_dir,
                    NULL AS cond_va,
                    NULL AS equip_pnc_cls,
                    ''Equip'' AS class_ename
                FROM
                    ord_main AS om
                    CROSS JOIN LATERAL json_array_elements ( om.ind_equip_info :: json ) eqi
          INNER JOIN mst_dialyzer dz ON TO_NUMBER( eqi ->> ''cd'', ''9999999999'' ) = dz.dialyzer_cd
          AND dz.is_del = ''0''
          AND dz.is_disp = ''1''
                    LEFT OUTER JOIN mst_kur kr ON om.ind_kur_cd = kr.kur_cd
                    AND kr.is_del = ''0''
                    LEFT OUTER JOIN mst_bed bd ON om.ind_bed_cd = bd.bed_cd
                    AND bd.is_del = ''0''
                    AND bd.is_disp = ''1''
                WHERE
                    om.ord_no IN ( @ordNos )
                    AND om.is_del = ''0''
                    AND dz.dialyzer_cd IN ( @diaIds ) UNION ALL--医材
                SELECT
                    CASE WHEN @dataTypeOrder = ''0'' THEN 2
           WHEN @dataTypeOrder = ''1'' THEN 1
           WHEN @dataTypeOrder = ''2'' THEN 3
           WHEN @dataTypeOrder = ''3'' THEN 3
           WHEN @dataTypeOrder = ''4'' THEN 2
           WHEN @dataTypeOrder = ''5'' THEN 1
           ELSE 1  END AS disp_order,
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
                    eqc.class_cd AS class_cd,
                    ''医材'' as do_action,
                    ''医療材料'' AS data_type_order,
                    1 AS kind_order,
                    eq.equipment_cd as code,
                    eq.equipment_name AS NAME,
                    ( CAST( eqi ->> ''amount'' AS DECIMAL) ) AS Amount,
                    COALESCE ( eq.unit, '''' ) AS Unit,
                    NULL AS function_class,
                    NULL AS area,
                    NULL AS ufr,
                    NULL AS koa,
                    NULL AS material,
                    NULL AS wetdry,
                    COALESCE ( eqc.class_name, ''未登録'' ) AS class_name,
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
                    AND eq.class_cd IN ( @eqIds )  UNION ALL--抗凝固剤(調製薬剤)
            SELECT
                CASE WHEN @dataTypeOrder = ''0'' THEN 1
             WHEN @dataTypeOrder = ''1'' THEN 2
             WHEN @dataTypeOrder = ''2'' THEN 2
             WHEN @dataTypeOrder = ''3'' THEN 1
             WHEN @dataTypeOrder = ''4'' THEN 3
             WHEN @dataTypeOrder = ''5'' THEN 3
             ELSE 1  END AS disp_order,
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
                mdc.class_cd AS class_cd,
                ''調製薬剤'' as do_action,
                ''薬剤'' AS data_type_order,
                2 AS kind_order,
                mmx.medicine_mix_cd as code,
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
                AND om.ind_cond_info :: json #>> ''{25, medicine_type}'' = ''2''
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
                AND mmx.class_cd IN ( @medIds ) UNION ALL--投薬(調製薬剤)
                SELECT
                    CASE WHEN @dataTypeOrder = ''0'' THEN 1
             WHEN @dataTypeOrder = ''1'' THEN 2
             WHEN @dataTypeOrder = ''2'' THEN 2
             WHEN @dataTypeOrder = ''3'' THEN 1
             WHEN @dataTypeOrder = ''4'' THEN 3
             WHEN @dataTypeOrder = ''5'' THEN 3
             ELSE 1  END AS disp_order,
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
                    mdc.class_cd AS class_cd,
                    ''調製薬剤'' as do_action,
                    ''薬剤'' AS data_type_order,
                    2 AS kind_order,
                    mdx.medicine_mix_cd as code,
                    mdx.medicine_mix_name AS NAME,
                    CAST( om.amount AS DECIMAL) AS Amount,
                    COALESCE ( mdx.unit, '''' ) AS Unit,
                    NULL AS function_class,
                    NULL AS area,
                    NULL AS ufr,
                    NULL AS koa,
                    NULL AS material,
                    NULL AS wetdry,
                    COALESCE ( mdc.class_name, ''未登録'' ) AS class_name,
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
                    om.medicine_type = ''2'' AND mdx.medicine_mix_cd IS NOT NULL UNION ALL--透析液
        SELECT
            CASE WHEN @dataTypeOrder = ''0'' THEN 1
             WHEN @dataTypeOrder = ''1'' THEN 2
             WHEN @dataTypeOrder = ''2'' THEN 2
             WHEN @dataTypeOrder = ''3'' THEN 1
             WHEN @dataTypeOrder = ''4'' THEN 3
             WHEN @dataTypeOrder = ''5'' THEN 3
             ELSE 1  END AS disp_order,
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
            mdc.class_cd AS class_cd,
            ''通常薬剤'' as do_action,
            ''薬剤'' AS data_type_order,
            1 AS kind_order,
            md.medicine_cd as code,
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
            CASE WHEN @dataTypeOrder = ''0'' THEN 1
             WHEN @dataTypeOrder = ''1'' THEN 2
             WHEN @dataTypeOrder = ''2'' THEN 2
             WHEN @dataTypeOrder = ''3'' THEN 1
             WHEN @dataTypeOrder = ''4'' THEN 3
             WHEN @dataTypeOrder = ''5'' THEN 3
             ELSE 1  END AS disp_order,
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
            mdc.class_cd AS class_cd,
            ''通常薬剤'' as do_action,
            ''薬剤'' AS data_type_order,
            1 AS kind_order,
            md.medicine_cd as code,
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
            CASE WHEN @dataTypeOrder = ''0'' THEN 1
             WHEN @dataTypeOrder = ''1'' THEN 2
             WHEN @dataTypeOrder = ''2'' THEN 2
             WHEN @dataTypeOrder = ''3'' THEN 1
             WHEN @dataTypeOrder = ''4'' THEN 3
             WHEN @dataTypeOrder = ''5'' THEN 3
             ELSE 1  END AS disp_order,
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
            mdc.class_cd AS class_cd,
            ''通常薬剤'' as do_action,
            ''薬剤'' AS data_type_order,
            1 AS kind_order,
            md.medicine_cd as code,
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
                ( om.medicine_type = ''1'' AND md.class_cd IN ( @medIds ) ) UNION ALL--投薬(薬剤)
            SELECT
                CASE WHEN @dataTypeOrder = ''0'' THEN 1
             WHEN @dataTypeOrder = ''1'' THEN 2
             WHEN @dataTypeOrder = ''2'' THEN 2
             WHEN @dataTypeOrder = ''3'' THEN 1
             WHEN @dataTypeOrder = ''4'' THEN 3
             WHEN @dataTypeOrder = ''5'' THEN 3
             ELSE 1  END AS disp_order,
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
                mdc.class_cd AS class_cd,
                ''通常薬剤'' as do_action,
                ''薬剤'' AS data_type_order,
                1 AS kind_order,
                md.medicine_cd as code,
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
                    COALESCE ( mdc.class_name, ''未登録'' ) AS class_name,
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
                    ( om.medicine_type = ''1'' AND md.class_cd IN ( @medIds ) )
                ) AS EquipmentList
                INNER JOIN plan_time ON EquipmentList.ord_no = plan_time.ord_no
            ) ,
result_all AS (
(SELECT
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
            bd.class_cd,
            bd.do_action,
            bd.data_type_order,
            bd.kind_order,
            bd.code,
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
            bd.class_cd,
            bd.do_action,
            bd.data_type_order,
            bd.kind_order,
            bd.code,
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
        )
            UNION ALL--採血管
        (SELECT
            date_trunc( ''day'',  ord_main.treat_date  :: TIMESTAMP) AS treat_date,
            NULL AS equipment_cd,
            NULL AS equipment_class_cd,
            NULL AS medicine_cd,
            NULL AS medicine_class_cd,
            ord_main.ind_kur_cd AS kur_cd,
            mst_kur.kur_name AS kur_name,
            mst_bed.bed_name AS bed_name,
            ord_main.ind_bed_cd AS bed_cd,
            P.pat_id,
            NULL AS kind,
            NULL AS class_cd,
            NULL AS do_action,
            ''検査'' AS data_type_order,
            1 AS kind_order,
            NULL AS code,
            spitz.spitz_name AS NAME,
            NULL AS amount,
            NULL AS unit,
            NULL AS function_class,
            NULL AS area,
            NULL AS ufr,
            NULL AS koa,
            NULL AS material,
            NULL AS wetdry,
            CASE WHEN @dataTypeOrder = ''0'' THEN 3
           WHEN @dataTypeOrder = ''1'' THEN 3
           WHEN @dataTypeOrder = ''2'' THEN 1
           WHEN @dataTypeOrder = ''3'' THEN 2
           WHEN @dataTypeOrder = ''4'' THEN 1
           WHEN @dataTypeOrder = ''5'' THEN 2
           ELSE 1  END AS disp_order,
            P.reg_order_class AS class_name,
            ''Exam'' AS class_ename,
            NULL AS anticoagulant_name,
            ord_main.plan_time,
          ord_main.cond_dw,
          ord_main.cond_tg_wei,
          ord_main.cond_tre_nm,
          ord_main.cond_bld_fl,
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
            spitz.label_print AS label_print,
            meim.is_in_hospital AS is_in_hospital ,
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
            P CROSS JOIN LATERAL jsonb_array_elements(P.order_exam_set_info) WITH ORDINALITY AS infoExam(exam_info, exam_index)
            LEFT OUTER JOIN mst_exam_set AS mest CROSS JOIN LATERAL json_array_elements ( mest.exam_item_info :: json) infoExamInfo
             ON infoExam.exam_info ->> ''set_cd'' = mest.exam_set_cd :: TEXT
            AND mest.is_del = ''0''
            AND mest.is_disp = ''1''
            AND mest.facility_cd = @facilityCd
            LEFT OUTER JOIN mst_exam_item AS meim on infoExamInfo ->> ''exam_item_cd'' = meim.exam_item_cd :: TEXT
            AND meim.is_del = ''0''
            AND meim.is_disp = ''1''
            AND mest.facility_cd = @facilityCd
            LEFT OUTER JOIN spi ON spi.spitz_code = meim.spitz_cd
            LEFT OUTER JOIN mst_spitz AS spitz ON spitz.spitz_cd = meim.spitz_cd
            left join
      ( SELECT
        ord_main.treat_date,
        ord_main.ind_kur_cd,
        ord_main.ind_bed_cd,
        ord_main.ord_no,
        ord_main.pat_id,
                ord_main.plan_time,
            ord_main.cond_dw,
            ord_main.cond_tg_wei,
            ord_main.cond_tre_nm,
            ord_main.cond_bld_fl 
        FROM
        (
          SELECT
            ord_main.treat_date AS treat_date,
            ord_main.ind_kur_cd AS ind_kur_cd,
            ord_main.ind_bed_cd AS ind_bed_cd,
            ord_main.ord_no AS ord_no,
            ord_main.pat_id AS pat_id,
            ROW_NUMBER( ) OVER ( PARTITION BY ord_main.treat_date,ord_main.pat_id ORDER BY ord_main.ind_kur_cd ) AS row_num ,
                        plan_time.plan_time,
                plan_time.cond_dw,
                plan_time.cond_tg_wei,
                plan_time.cond_tre_nm,
                plan_time.cond_bld_fl
          FROM
            ord_main 
                        inner join plan_time on ord_main.ord_no = plan_time.ord_no 
          WHERE
            ord_main.pat_id IN ( @patIds ) 
            AND ord_main.treat_date = @treatDate 
        ) AS ord_main 
        WHERE
          row_num = 1 
        ORDER BY
          ind_kur_cd 
      ) AS ord_main ON date_trunc( ''day'',  ord_main.treat_date  :: TIMESTAMP) = date_trunc( ''day'', P.reg_exam_date :: TIMESTAMP )
      and ord_main.pat_id = P.pat_id
            left join mst_kur on mst_kur.kur_cd = ord_main.ind_kur_cd
            left join mst_bed on mst_bed.bed_cd = ord_main.ind_bed_cd
            -- ベッドグループ
            LEFT OUTER JOIN mst_room_bed_group_1 AS rbg1 ON rbg1.bed_list :: jsonb @> ('''' || mst_bed.bed_cd) :: jsonb
            LEFT OUTER JOIN room_bed AS rb1 ON rbg1.room_bed_group_cd = rb1.room_bed_code
            -- 透析室
            LEFT OUTER JOIN mst_room_bed_group_2 AS rbg2 ON rbg2.bed_list :: jsonb @> ('''' || mst_bed.bed_cd) :: jsonb
            LEFT OUTER JOIN room_bed AS rb2 ON rbg2.room_bed_group_cd = rb2.room_bed_code
        WHERE
            spitz.spitz_name IS NOT NULL
            AND P.reg_order_class IN (@regOrderClass)
        AND
            1 in (@inspectIds)
        group by
            treat_date,
            ord_main.ind_kur_cd,
            mst_kur.kur_name,
            mst_bed.bed_name,
            ord_main.ind_bed_cd,
            P.pat_id,
            spitz.spitz_name,
            P.reg_order_class,
            spitz.label_print,
            meim.is_in_hospital,
            spi.spitz_order,
            data_type_order,
            plan_time,
          cond_dw,
          cond_tg_wei,
          cond_tre_nm,
          cond_bld_fl    
        ORDER BY
          spi.spitz_order)
          UNION ALL--採血管
        (SELECT
            date_trunc( ''day'',  ord_main.treat_date  :: TIMESTAMP) AS treat_date,
            NULL AS equipment_cd,
            NULL AS equipment_class_cd,
            NULL AS medicine_cd,
            NULL AS medicine_class_cd,
            ord_main.ind_kur_cd AS kur_cd,
            mst_kur.kur_name AS kur_name,
            mst_bed.bed_name AS bed_name,
            ord_main.ind_bed_cd AS bed_cd,
            P.pat_id,
            NULL AS kind,
            NULL AS class_cd,
            NULL AS do_action,
            ''検査'' AS data_type_order,
            1 AS kind_order,
            NULL AS code,
            mest.exam_set_name AS NAME,
            NULL AS amount,
            NULL AS unit,
            NULL AS function_class,
            NULL AS area,
            NULL AS ufr,
            NULL AS koa,
            NULL AS material,
            NULL AS wetdry,
            CASE WHEN @dataTypeOrder = ''0'' THEN 3
           WHEN @dataTypeOrder = ''1'' THEN 3
           WHEN @dataTypeOrder = ''2'' THEN 1
           WHEN @dataTypeOrder = ''3'' THEN 2
           WHEN @dataTypeOrder = ''4'' THEN 1
           WHEN @dataTypeOrder = ''5'' THEN 2
           ELSE 1  END AS disp_order,
            P.reg_order_class AS class_name,
            ''Exam'' AS class_ename,
            NULL AS anticoagulant_name,
            ord_main.plan_time,
          ord_main.cond_dw,
          ord_main.cond_tg_wei,
          ord_main.cond_tre_nm,
          ord_main.cond_bld_fl,
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
            NULL AS is_in_hospital ,
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
            NULL AS spitz_order
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
            P CROSS JOIN LATERAL jsonb_array_elements(P.order_exam_set_info) WITH ORDINALITY AS infoExam(exam_info, exam_index)
            LEFT OUTER JOIN mst_exam_set AS mest CROSS JOIN LATERAL json_array_elements ( mest.exam_item_info :: json) infoExamInfo
             ON infoExam.exam_info ->> ''set_cd'' = mest.exam_set_cd :: TEXT
            AND mest.is_del = ''0''
            AND mest.is_disp = ''1''
            AND mest.facility_cd = @facilityCd
            LEFT OUTER JOIN mst_exam_item AS meim on infoExamInfo ->> ''exam_item_cd'' = meim.exam_item_cd :: TEXT
            AND meim.is_del = ''0''
            AND meim.is_disp = ''1''
            AND mest.facility_cd = @facilityCd
            LEFT OUTER JOIN spi ON spi.spitz_code = meim.spitz_cd
            left join
      ( SELECT
        ord_main.treat_date,
        ord_main.ind_kur_cd,
        ord_main.ind_bed_cd,
        ord_main.ord_no,
        ord_main.pat_id,
                ord_main.plan_time,
            ord_main.cond_dw,
            ord_main.cond_tg_wei,
            ord_main.cond_tre_nm,
            ord_main.cond_bld_fl 
        FROM
        (
          SELECT
            ord_main.treat_date AS treat_date,
            ord_main.ind_kur_cd AS ind_kur_cd,
            ord_main.ind_bed_cd AS ind_bed_cd,
            ord_main.ord_no AS ord_no,
            ord_main.pat_id AS pat_id,
            ROW_NUMBER( ) OVER ( PARTITION BY ord_main.treat_date,ord_main.pat_id ORDER BY ord_main.ind_kur_cd ) AS row_num ,
                        plan_time.plan_time,
                plan_time.cond_dw,
                plan_time.cond_tg_wei,
                plan_time.cond_tre_nm,
                plan_time.cond_bld_fl
          FROM
            ord_main 
                        inner join plan_time on ord_main.ord_no = plan_time.ord_no 
          WHERE
            ord_main.pat_id IN ( @patIds ) 
            AND ord_main.treat_date = @treatDate 
        ) AS ord_main 
        WHERE
          row_num = 1 
        ORDER BY
          ind_kur_cd 
      ) AS ord_main ON date_trunc( ''day'',  ord_main.treat_date  :: TIMESTAMP) = date_trunc( ''day'', P.reg_exam_date :: TIMESTAMP )
      and ord_main.pat_id = P.pat_id
            left join mst_kur on mst_kur.kur_cd = ord_main.ind_kur_cd
            left join mst_bed on mst_bed.bed_cd = ord_main.ind_bed_cd
            -- ベッドグループ
            LEFT OUTER JOIN mst_room_bed_group_1 AS rbg1 ON rbg1.bed_list :: jsonb @> ('''' || mst_bed.bed_cd) :: jsonb
            LEFT OUTER JOIN room_bed AS rb1 ON rbg1.room_bed_group_cd = rb1.room_bed_code
            -- 透析室
            LEFT OUTER JOIN mst_room_bed_group_2 AS rbg2 ON rbg2.bed_list :: jsonb @> ('''' || mst_bed.bed_cd) :: jsonb
            LEFT OUTER JOIN room_bed AS rb2 ON rbg2.room_bed_group_cd = rb2.room_bed_code
        WHERE P.reg_order_class IN (@regOrderClass)
            AND mest.exam_set_cd in (@esIds)
        group by
            treat_date,
            ord_main.ind_kur_cd,
            mst_kur.kur_name,
            mst_bed.bed_name,
            ord_main.ind_bed_cd,
            P.pat_id,
            P.reg_order_class,
            data_type_order,
            plan_time,
          cond_dw,
          cond_tg_wei,
          cond_tre_nm,
          cond_bld_fl,
          mest.exam_set_name)
)        

SELECT * ,res.pat_id as pat_Id1 ,res.pat_id as pat_Id2 ,res.pat_id as pat_Id3 FROM result_all as res @orderBy            ', 2, '[]', '1', '{"applications": [1]}', '{"classes": [8]}', 'ラベル（降順）', '2024-03-20 08:56:21', CURRENT_TIMESTAMP, NULL);
