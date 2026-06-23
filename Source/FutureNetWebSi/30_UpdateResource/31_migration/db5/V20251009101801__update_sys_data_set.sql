DELETE FROM "ntss"."sys_data_set" where sql_cd in (9, 242, 251, 252, 253, 254);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9, 'WITH
save as (
	SELECT
		* 
	FROM
		ord_material_save save 
	WHERE save.supplies_base_no in (@ordNos)
		AND save.facility_cd = @facilityCd
		AND save.ind_rst_class = ''1''
)
, ord_ind_medi_info AS (
	SELECT
		ord_no,
		info->>''cd'' AS cd,
		info->>''class_cd'' AS class_cd,
		info->>''class_name'' AS class_name
	FROM
		ord_main
	CROSS JOIN LATERAL jsonb_array_elements (ind_medi_info) WITH ORDINALITY AS tmp (info, json_idx)
	WHERE
		ord_no in (@ordNos)
	AND rst_dialysis_state <> ''0''
	AND info->>''class_cd'' IS NOT NULL
)
, ord_ind_equip_info AS (
	SELECT
		ord_no,
		info->>''cd'' AS cd,
		info->>''class_cd'' AS class_cd,
		info->>''class_name'' AS class_name
	FROM
		ord_main
	CROSS JOIN LATERAL jsonb_array_elements (ind_equip_info) WITH ORDINALITY AS tmp (info, json_idx)
	WHERE
		ord_no in (@ordNos)
	AND rst_dialysis_state <> ''0''
	AND info->>''class_cd'' IS NOT NULL
)
, dz AS (
	SELECT
		*
	FROM
		mst_dialyzer
	WHERE
		facility_cd = @facilityCd
		AND is_del = ''0''
		AND is_disp = ''1''
	),
	eq AS (
	SELECT
		*
	FROM
		mst_equipment
	WHERE
		facility_cd = @facilityCd
		AND is_del = ''0''
		AND is_disp = ''1''
	),
	eqc AS (
	SELECT
		*
	FROM
		mst_equipment_class
	WHERE
		facility_cd = @facilityCd
		AND is_del = ''0''
		AND is_disp = ''1''
	),
	md AS (
	SELECT
		*
	FROM
		mst_medicine
	WHERE
		facility_cd = @facilityCd
		AND is_del = ''0''
		AND is_disp = ''1''
	),
	mdc AS (
	SELECT
		*
	FROM
		mst_medicine_class
	WHERE
		facility_cd = @facilityCd
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
		facility_cd = @facilityCd
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
		facility_cd = @facilityCd
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
		facility_cd = @facilityCd
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
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_equipment''
	),
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
	),
result_all as (
	SELECT
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
	do_action,
	data_type_order,
	kind_order,
	dia.dia_order,
	medic.medic_order,
	equic.equic_order,
	medi_mix.medi_mix_order
FROM
(
	--治療条件:ダイアライザ
	SELECT
		save.supplies_base_no AS ord_no,
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 3
         WHEN @dataTypeOrder = ''2'' THEN 1
         WHEN @dataTypeOrder = ''3'' THEN 1
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 3
         ELSE 1  END AS disp_order,
		save.supplies_base_date AS treat_date,
		''ダイアライザ'' AS kind,
		dz.model_number AS NAME,
		CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
		COALESCE(save.ind_unit, '''') AS Unit,
		dz.in_hospital_cd_1,
		dz.in_hospital_cd_2,
		dz.in_hospital_cd_3,
		dz.in_hospital_cd_4,
		0 AS class_cd,
		save.supplies_cd AS cd,
		0 AS code_order,
		0 AS order_cd,
		dz.dialyzer_cd AS pk_order,
		''ダイアライザ'' AS do_action,
		''医療材料'' AS data_type_order,
		2 AS kind_order,
		NULL AS equipment_cd,
		NULL AS equipment_class_cd,
		NULL AS medicine_cd,
		NULL AS medicine_class_cd,
		dz.dialyzer_cd
	FROM
		save
	LEFT JOIN dz ON save.supplies_cd = CAST(dz.dialyzer_cd AS VARCHAR)
	WHERE
		save.supplies_class = ''01''
		AND save.supplies_source_class = ''0''
		AND dz.dialyzer_cd IN ( @diaIds )
	UNION ALL
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
			emq.do_action,
			emq.data_type_order,
			emq.kind_order,
			emq.equipment_cd,
			emq.equipment_class_cd,
			emq.medicine_cd,
			emq.medicine_class_cd,
			emq.dialyzer_cd ::INTEGER
		FROM
		(
			--治療条件
			SELECT
				save.supplies_base_no AS ord_no,
				CASE WHEN @dataTypeOrder = ''0'' THEN 2
				 WHEN @dataTypeOrder = ''1'' THEN 3
				 WHEN @dataTypeOrder = ''2'' THEN 1
				 WHEN @dataTypeOrder = ''3'' THEN 1
				 WHEN @dataTypeOrder = ''4'' THEN 2
				 WHEN @dataTypeOrder = ''5'' THEN 3
				 ELSE 1  END AS disp_order,
				save.supplies_base_date AS treat_date,
				COALESCE ( eqc.class_name, '''' ) AS kind,
				eq.equipment_name AS NAME,
				CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
				COALESCE(save.ind_unit, '''') AS Unit,
				eq.in_hospital_cd_1,
				eq.in_hospital_cd_2,
				eq.in_hospital_cd_3,
				eq.in_hospital_cd_4,
				eq.class_cd :: INTEGER AS class_cd,
				save.supplies_cd AS cd,
				eq.equipment_cd AS pk_order,
				''医材'' AS do_action,
				''医療材料'' AS data_type_order,
				1 AS kind_order,
				eq.equipment_cd AS equipment_cd,
				eqc.class_cd AS equipment_class_cd,
				NULL AS medicine_cd,
				NULL AS medicine_class_cd,
				NULL AS dialyzer_cd
			FROM
				save
			LEFT JOIN eq ON save.supplies_cd = CAST(eq.equipment_cd AS VARCHAR)
			LEFT JOIN eqc ON save.class_cd = CAST(eqc.class_cd AS VARCHAR)
			WHERE
				save.supplies_class in (''02'',''03'',''04'',''06'',''07'',''05'',''00'')
				AND save.supplies_source_class = ''0''
				AND eq.class_cd IN ( @eqIds )
			UNION ALL--医材
			SELECT
				save.supplies_base_no AS ord_no,
				CASE WHEN @dataTypeOrder = ''0'' THEN 2
				 WHEN @dataTypeOrder = ''1'' THEN 3
				 WHEN @dataTypeOrder = ''2'' THEN 1
				 WHEN @dataTypeOrder = ''3'' THEN 1
				 WHEN @dataTypeOrder = ''4'' THEN 2
				 WHEN @dataTypeOrder = ''5'' THEN 3
				 ELSE 1  END  AS disp_order,
				save.supplies_base_date AS treat_date,
				COALESCE (
					CASE WHEN oEqu.class_name IS NOT NULL THEN oEqu.class_name
						WHEN eqc.class_name IS NOT NULL THEN eqc.class_name
						ELSE NULL END
				, ''未分類'' ) AS kind,
				eq.equipment_name AS NAME,
				CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
				COALESCE(save.ind_unit, '''') AS Unit,
				eq.in_hospital_cd_1,
				eq.in_hospital_cd_2,
				eq.in_hospital_cd_3,
				eq.in_hospital_cd_4,
				eq.class_cd :: INTEGER AS class_cd,
				save.supplies_cd AS cd,
				eq.equipment_cd AS pk_order,
				''医材'' AS do_action,
				''医療材料'' AS data_type_order,
				1 AS kind_order,
				eq.equipment_cd AS equipment_cd,
			    eqc.class_cd AS equipment_class_cd,
			    NULL AS medicine_cd,
			    NULL AS medicine_class_cd,
			    NULL AS dialyzer_cd
			FROM
				save
			LEFT JOIN eq ON save.supplies_cd = CAST(eq.equipment_cd AS VARCHAR)
			LEFT OUTER JOIN ord_ind_equip_info AS oEqu ON save.supplies_cd = CAST(oEqu.cd AS VARCHAR) AND save.supplies_base_no = oEqu.ord_no
			LEFT OUTER JOIN eqc ON save.class_cd = CAST(eqc.class_cd AS VARCHAR)
			WHERE
				save.supplies_class = ''11''
				AND eq.class_cd IN ( @eqIds )
		) emq
		LEFT OUTER JOIN meqc ON emq.class_cd = meqc.meq_class_code
		LEFT OUTER JOIN meqcc ON emq.pk_order = meqcc.meq_code
		ORDER BY
			meqc.code_order,meqcc.meq_order
	)
	UNION ALL--医材:ダイアライザ
	SELECT
		save.supplies_base_no AS ord_no,
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 3
         WHEN @dataTypeOrder = ''2'' THEN 1
         WHEN @dataTypeOrder = ''3'' THEN 1
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 3
         ELSE 1  END AS disp_order,
		save.supplies_base_date AS treat_date,
		''ダイアライザ'' AS kind,
		dz.model_number AS NAME,
		CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
		COALESCE(save.ind_unit, '''') AS Unit,
		dz.in_hospital_cd_1,
		dz.in_hospital_cd_2,
		dz.in_hospital_cd_3,
		dz.in_hospital_cd_4,
		0 AS class_cd,
		save.supplies_cd AS cd,
		0 AS code_order,
		0 AS order_cd,
		dz.dialyzer_cd AS pk_order,
		''ダイアライザ'' AS do_action,
		''医療材料'' AS data_type_order,
		2 AS kind_order,
		NULL AS equipment_cd,
		NULL AS equipment_class_cd,
		NULL AS medicine_cd,
		NULL AS medicine_class_cd,
		dz.dialyzer_cd
	FROM
		save
	LEFT JOIN dz ON save.supplies_cd = CAST(dz.dialyzer_cd AS VARCHAR)
	WHERE
		save.supplies_class = ''01''
		AND save.supplies_source_class = ''2''
		AND dz.dialyzer_cd IN ( @diaIds )
	UNION ALL--投薬
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
			mdcc.do_action,
			mdcc.data_type_order,
			mdcc.kind_order,
			mdcc.equipment_cd::INTEGER,
			mdcc.equipment_class_cd ::INTEGER,
			mdcc.medicine_cd,
			mdcc.medicine_class_cd,
			mdcc.dialyzer_cd ::INTEGER
		FROM
		(
			--透析液
			SELECT
				save.supplies_base_no AS ord_no,
				CASE WHEN @dataTypeOrder = ''0'' THEN 3
				   WHEN @dataTypeOrder = ''1'' THEN 2
				   WHEN @dataTypeOrder = ''2'' THEN 2
				   WHEN @dataTypeOrder = ''3'' THEN 3
				   WHEN @dataTypeOrder = ''4'' THEN 1
				   WHEN @dataTypeOrder = ''5'' THEN 1
				   ELSE 1  END  AS disp_order,
				save.supplies_base_date AS treat_date,
				COALESCE(mdc.class_name, '''') AS kind,
				md.medicine_name AS NAME,
				CAST(NULLIF(save.receipt_value, '''') AS DECIMAL) AS Amount,
				COALESCE(save.receipt_unit, '''') AS Unit,
				md.in_hospital_cd_1,
				md.in_hospital_cd_2,
				md.in_hospital_cd_3,
				md.in_hospital_cd_4,
				md.class_cd :: INTEGER AS class_cd,
				save.supplies_cd AS cd,
				md.medicine_cd AS pk_order,
				''通常薬剤'' AS do_action,
				''薬剤'' AS data_type_order,
				1 AS kind_order,
				NULL AS equipment_cd,
				NULL AS equipment_class_cd,
				save.supplies_cd AS medicine_cd,
				mdc.class_cd :: TEXT AS medicine_class_cd,
				NULL AS dialyzer_cd
			FROM
				save
			LEFT OUTER JOIN md ON save.supplies_cd = CAST(md.medicine_cd AS VARCHAR)
			LEFT OUTER JOIN mdc ON save.class_cd = CAST(mdc.class_cd AS VARCHAR)
			WHERE
				save.supplies_class in (''08'', ''09'')
				AND save.supplies_source_class = ''0''
				AND md.class_cd IN ( @medIds )
			UNION ALL--抗凝固剤
			SELECT
				save.supplies_base_no AS ord_no,
				CASE WHEN @dataTypeOrder = ''0'' THEN 3
				   WHEN @dataTypeOrder = ''1'' THEN 2
				   WHEN @dataTypeOrder = ''2'' THEN 2
				   WHEN @dataTypeOrder = ''3'' THEN 3
				   WHEN @dataTypeOrder = ''4'' THEN 1
				   WHEN @dataTypeOrder = ''5'' THEN 1
				   ELSE 1  END  AS disp_order,
				save.supplies_base_date AS treat_date,
				COALESCE ( mdc.class_name, '''' ) AS kind,
				md.medicine_name AS NAME,
				CASE WHEN COALESCE(CAST(save.receipt_value AS DECIMAL), 0) <> 0 THEN  CAST ( save.receipt_value  AS DECIMAL ) ELSE  CAST ( save.ind_rst_value AS DECIMAL ) END  AS Amount,
				CASE WHEN COALESCE(CAST(save.receipt_value AS DECIMAL), 0) <> 0 THEN save.receipt_unit ELSE  COALESCE ( save.ind_unit, '''' ) END AS Unit,
				md.in_hospital_cd_1,
				md.in_hospital_cd_2,
				md.in_hospital_cd_3,
				md.in_hospital_cd_4,
				md.class_cd :: INTEGER AS class_cd,
				save.supplies_cd AS cd,
				md.medicine_cd AS pk_order,
				''通常薬剤'' AS do_action,
				''薬剤'' AS data_type_order,
				1 AS kind_order,
				NULL AS equipment_cd,
				NULL AS equipment_class_cd,
				save.supplies_cd AS medicine_cd,
				mdc.class_cd :: TEXT AS medicine_class_cd,
				NULL AS dialyzer_cd
			FROM
				save
			LEFT OUTER JOIN md ON save.supplies_cd = CAST(md.medicine_cd AS VARCHAR)
			LEFT OUTER JOIN mdc ON save.class_cd = CAST(mdc.class_cd AS VARCHAR)
			WHERE
				save.supplies_class = ''10''
				and save.supplies_source_class = ''0''
				AND md.class_cd IN ( @medIds )
			UNION ALL--抗凝固剤(調製)	
			SELECT
				save.supplies_base_no AS ord_no,
				CASE WHEN @dataTypeOrder = ''0'' THEN 3
				   WHEN @dataTypeOrder = ''1'' THEN 2
				   WHEN @dataTypeOrder = ''2'' THEN 2
				   WHEN @dataTypeOrder = ''3'' THEN 3
				   WHEN @dataTypeOrder = ''4'' THEN 1
				   WHEN @dataTypeOrder = ''5'' THEN 1
				   ELSE 1  END AS disp_order,
				save.supplies_base_date AS treat_date,
				COALESCE ( mdc.class_name, ''未分類'' ) AS kind,
				md.medicine_name AS NAME,
				CASE WHEN COALESCE(CAST(save.receipt_value AS DECIMAL), 0) <> 0 THEN  CAST ( save.receipt_value  AS DECIMAL ) ELSE  CAST ( save.ind_rst_value AS DECIMAL ) END  AS Amount,
				CASE WHEN COALESCE(CAST(save.receipt_value AS DECIMAL), 0) <> 0 THEN save.receipt_unit ELSE  COALESCE ( save.ind_unit, '''' ) END AS Unit,
				md.in_hospital_cd_1,
				md.in_hospital_cd_2,
				md.in_hospital_cd_3,
				md.in_hospital_cd_4,
				md.class_cd :: INTEGER AS class_cd,
				save.supplies_cd AS cd,
				md.medicine_cd AS pk_order,
				''通常薬剤'' AS do_action,
				''薬剤'' AS data_type_order,
				1 AS kind_order,
				NULL AS equipment_cd,
				NULL AS equipment_class_cd,
				save.medicine_mix_cd medicine_cd,
				mdc.class_cd :: TEXT AS medicine_class_cd,
				NULL AS dialyzer_cd
			FROM
				save
			LEFT OUTER JOIN mst_medicine_mix AS mmx ON save.medicine_mix_cd = CAST(mmx.medicine_mix_cd AS VARCHAR)
			LEFT OUTER JOIN md ON save.supplies_cd = CAST(md.medicine_cd AS VARCHAR)
			LEFT OUTER JOIN mdc ON save.class_cd = CAST(mdc.class_cd AS VARCHAR)
			WHERE
				save.supplies_class = ''22''
				AND save.supplies_source_class = ''0''
				AND md.class_cd IN ( @medIds )
			UNION ALL--投与薬剤
			SELECT
				save.supplies_base_no AS ord_no,
				CASE WHEN @dataTypeOrder = ''0'' THEN 3
				   WHEN @dataTypeOrder = ''1'' THEN 2
				   WHEN @dataTypeOrder = ''2'' THEN 2
				   WHEN @dataTypeOrder = ''3'' THEN 3
				   WHEN @dataTypeOrder = ''4'' THEN 1
				   WHEN @dataTypeOrder = ''5'' THEN 1
				   ELSE 1  END  AS disp_order,
				save.supplies_base_date AS treat_date,
				COALESCE (
					CASE WHEN oMed.class_name IS NOT NULL THEN oMed.class_name
					WHEN mdc.class_name IS NOT NULL THEN mdc.class_name
					ELSE NULL END
				, ''未分類'' ) AS kind,
				md.medicine_name AS NAME,
				CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
				COALESCE(save.ind_unit, '''') AS Unit,
				md.in_hospital_cd_1,
				md.in_hospital_cd_2,
				md.in_hospital_cd_3,
				md.in_hospital_cd_4,
				md.class_cd AS class_cd,
				save.supplies_cd AS cd,
				md.medicine_cd AS pk_order,
				''通常薬剤'' AS do_action,
				''薬剤'' AS data_type_order,
				1 AS kind_order,
				NULL AS equipment_cd,
				NULL AS equipment_class_cd,
				save.supplies_cd AS medicine_cd,
				mdc.class_cd :: TEXT AS medicine_class_cd,
				NULL AS dialyzer_cd
			FROM
				save
			LEFT OUTER JOIN md ON save.supplies_cd = CAST(md.medicine_cd AS VARCHAR)
			LEFT OUTER JOIN ord_ind_medi_info AS oMed ON save.supplies_cd = CAST(oMed.cd AS VARCHAR) AND save.supplies_base_no = oMed.ord_no
			LEFT OUTER JOIN mdc ON save.class_cd = CAST(mdc.class_cd AS VARCHAR)
			WHERE
				save.supplies_class in (''12'', ''20'')
				AND md.class_cd IN ( @medIds )
		) mdcc
		LEFT OUTER JOIN dmcc ON dmcc.medi_class_code = mdcc.class_cd
		LEFT OUTER JOIN dmccc ON dmccc.medi_code = mdcc.pk_order
		ORDER BY
			dmcc.code_order,dmccc.medi_code_order ASC
		)
	) AS EquipmentList
	LEFT OUTER JOIN medic ON medic.medic_code :: TEXT = EquipmentList.medicine_class_cd
	LEFT OUTER JOIN equic ON equic.equic_code = EquipmentList.equipment_class_cd
	LEFT OUTER JOIN dia ON dia.dia_code = EquipmentList.dialyzer_cd
	LEFT OUTER JOIN medi_mix ON medi_mix.medi_mix_code :: TEXT = EquipmentList.medicine_class_cd
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
		do_action,
		data_type_order,
		kind_order,
		dia_order,
		medic_order,
		equic_order,
		medi_mix_order
	HAVING
		SUM ( Amount ) > 0
	ORDER BY
		disp_order,
	code_order,
	order_cd,
	pk_order,
	kind
)
	
SELECT * from result_all as res @orderBy	', 2, '[{"preview": "テープ", "can_calc": "0", "data_code": "kind", "data_name": "分類名称", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "kind", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70%ブドウ糖注射液350ml", "can_calc": "0", "data_code": "name", "data_name": "型番･名称", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "name", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "1", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "物品情報", "field_name": "amount", "disp_format": "0.00", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "個", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "unit", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_1", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_2", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_3", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_4", "data_name": "院内コード4", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_4", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [4]}', '器材準備リスト', '2024-11-22 16:21:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (242, 'WITH
save as (
	SELECT
		* 
	FROM
		ord_material_save save 
	WHERE save.supplies_base_no in (@ordNos)
		AND save.facility_cd = @facilityCd
		AND save.ind_rst_class = ''1''
)
, ord_ind_medi_info AS (
	SELECT
		ord_no,
		info->>''cd'' AS cd,
		info->>''class_cd'' AS class_cd,
		info->>''class_name'' AS class_name
	FROM
		ord_main
	CROSS JOIN LATERAL jsonb_array_elements (ind_medi_info) WITH ORDINALITY AS tmp (info, json_idx)
	WHERE
		ord_no in (@ordNos)
	AND rst_dialysis_state <> ''0''
	AND info->>''class_cd'' IS NOT NULL
)
, ord_ind_equip_info AS (
	SELECT
		ord_no,
		info->>''cd'' AS cd,
		info->>''class_cd'' AS class_cd,
		info->>''class_name'' AS class_name
	FROM
		ord_main
	CROSS JOIN LATERAL jsonb_array_elements (ind_equip_info) WITH ORDINALITY AS tmp (info, json_idx)
	WHERE
		ord_no in (@ordNos)
	AND rst_dialysis_state <> ''0''
	AND info->>''class_cd'' IS NOT NULL
)
, dz AS (
	SELECT
		*
	FROM
		mst_dialyzer
	WHERE
		facility_cd = @facilityCd
		AND is_del = ''0''
		AND is_disp = ''1''
	),
	eq AS (
	SELECT
		*
	FROM
		mst_equipment
	WHERE
		facility_cd = @facilityCd
		AND is_del = ''0''
		AND is_disp = ''1''
	),
	eqc AS (
	SELECT
		*
	FROM
		mst_equipment_class
	WHERE
		facility_cd = @facilityCd
		AND is_del = ''0''
		AND is_disp = ''1''
	),
	md AS (
	SELECT
		*
	FROM
		mst_medicine
	WHERE
		facility_cd = @facilityCd
		AND is_del = ''0''
		AND is_disp = ''1''
	),
	mdc AS (
	SELECT
		*
	FROM
		mst_medicine_class
	WHERE
		facility_cd = @facilityCd
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
		facility_cd = @facilityCd
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
		facility_cd = @facilityCd
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
		facility_cd = @facilityCd
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
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_equipment''
	),
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
	),
result_all as (
	SELECT
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
	do_action,
	data_type_order,
	kind_order,
	dia.dia_order,
	medic.medic_order,
	equic.equic_order,
	medi_mix.medi_mix_order
FROM
(
	--治療条件:ダイアライザ
	SELECT
		save.supplies_base_no AS ord_no,
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 1
         WHEN @dataTypeOrder = ''2'' THEN 3
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
		save.supplies_base_date AS treat_date,
		''ダイアライザ'' AS kind,
		dz.model_number AS NAME,
		CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
		COALESCE(save.ind_unit, '''') AS Unit,
		dz.in_hospital_cd_1,
		dz.in_hospital_cd_2,
		dz.in_hospital_cd_3,
		dz.in_hospital_cd_4,
		0 AS class_cd,
		save.supplies_cd AS cd,
		0 AS code_order,
		0 AS order_cd,
		dz.dialyzer_cd AS pk_order,
		''ダイアライザ'' AS do_action,
		''医療材料'' AS data_type_order,
		2 AS kind_order,
		NULL AS equipment_cd,
		NULL AS equipment_class_cd,
		NULL AS medicine_cd,
		NULL AS medicine_class_cd,
		dz.dialyzer_cd
	FROM
		save
	LEFT JOIN dz ON save.supplies_cd = CAST(dz.dialyzer_cd AS VARCHAR)
	WHERE
		save.supplies_class = ''01''
		AND save.supplies_source_class = ''0''
		AND dz.dialyzer_cd IN ( @diaIds )
	UNION ALL
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
			emq.do_action,
			emq.data_type_order,
			emq.kind_order,
			emq.equipment_cd,
			emq.equipment_class_cd,
			emq.medicine_cd,
			emq.medicine_class_cd,
			emq.dialyzer_cd ::INTEGER
		FROM
		(
			--治療条件
			SELECT
				save.supplies_base_no AS ord_no,
				CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 1
         WHEN @dataTypeOrder = ''2'' THEN 3
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
				save.supplies_base_date AS treat_date,
				COALESCE ( eqc.class_name, '''' ) AS kind,
				eq.equipment_name AS NAME,
				CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
				COALESCE(save.ind_unit, '''') AS Unit,
				eq.in_hospital_cd_1,
				eq.in_hospital_cd_2,
				eq.in_hospital_cd_3,
				eq.in_hospital_cd_4,
				eq.class_cd :: INTEGER AS class_cd,
				save.supplies_cd AS cd,
				eq.equipment_cd AS pk_order,
				''医材'' AS do_action,
				''医療材料'' AS data_type_order,
				1 AS kind_order,
				eq.equipment_cd AS equipment_cd,
				eqc.class_cd AS equipment_class_cd,
				NULL AS medicine_cd,
				NULL AS medicine_class_cd,
				NULL AS dialyzer_cd
			FROM
				save
			LEFT JOIN eq ON save.supplies_cd = CAST(eq.equipment_cd AS VARCHAR)
			LEFT JOIN eqc ON save.class_cd = CAST(eqc.class_cd AS VARCHAR)
			WHERE
				save.supplies_class in (''02'',''03'',''04'',''06'',''07'',''05'',''00'')
				AND save.supplies_source_class = ''0''
				AND eq.class_cd IN ( @eqIds )
			UNION ALL--医材
			SELECT
				save.supplies_base_no AS ord_no,
				CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 1
         WHEN @dataTypeOrder = ''2'' THEN 3
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
				save.supplies_base_date AS treat_date,
				COALESCE (
					CASE WHEN oEqu.class_name IS NOT NULL THEN oEqu.class_name
						WHEN eqc.class_name IS NOT NULL THEN eqc.class_name
						ELSE NULL END
				, ''未分類'' ) AS kind,
				eq.equipment_name AS NAME,
				CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
				COALESCE(save.ind_unit, '''') AS Unit,
				eq.in_hospital_cd_1,
				eq.in_hospital_cd_2,
				eq.in_hospital_cd_3,
				eq.in_hospital_cd_4,
				eq.class_cd :: INTEGER AS class_cd,
				save.supplies_cd AS cd,
				eq.equipment_cd AS pk_order,
				''医材'' AS do_action,
				''医療材料'' AS data_type_order,
				1 AS kind_order,
				eq.equipment_cd AS equipment_cd,
			    eqc.class_cd AS equipment_class_cd,
			    NULL AS medicine_cd,
			    NULL AS medicine_class_cd,
			    NULL AS dialyzer_cd
			FROM
				save
			LEFT JOIN eq ON save.supplies_cd = CAST(eq.equipment_cd AS VARCHAR)
			LEFT OUTER JOIN ord_ind_equip_info AS oEqu ON save.supplies_cd = CAST(oEqu.cd AS VARCHAR) AND save.supplies_base_no = oEqu.ord_no
			LEFT OUTER JOIN eqc ON save.class_cd = CAST(eqc.class_cd AS VARCHAR)
			WHERE
				save.supplies_class = ''11''
				AND eq.class_cd IN ( @eqIds )
		) emq
		LEFT OUTER JOIN meqc ON emq.class_cd = meqc.meq_class_code
		LEFT OUTER JOIN meqcc ON emq.pk_order = meqcc.meq_code
		ORDER BY
			meqc.code_order,meqcc.meq_order
	)
	UNION ALL--医材:ダイアライザ
	SELECT
		save.supplies_base_no AS ord_no,
									CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 1
         WHEN @dataTypeOrder = ''2'' THEN 3
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
		save.supplies_base_date AS treat_date,
		''ダイアライザ'' AS kind,
		dz.model_number AS NAME,
		CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
		COALESCE(save.ind_unit, '''') AS Unit,
		dz.in_hospital_cd_1,
		dz.in_hospital_cd_2,
		dz.in_hospital_cd_3,
		dz.in_hospital_cd_4,
		0 AS class_cd,
		save.supplies_cd AS cd,
		0 AS code_order,
		0 AS order_cd,
		dz.dialyzer_cd AS pk_order,
		''ダイアライザ'' AS do_action,
		''医療材料'' AS data_type_order,
		2 AS kind_order,
		NULL AS equipment_cd,
		NULL AS equipment_class_cd,
		NULL AS medicine_cd,
		NULL AS medicine_class_cd,
		dz.dialyzer_cd
	FROM
		save
	LEFT JOIN dz ON save.supplies_cd = CAST(dz.dialyzer_cd AS VARCHAR)
	WHERE
		save.supplies_class = ''01''
		AND save.supplies_source_class = ''2''
		AND dz.dialyzer_cd IN ( @diaIds )
	UNION ALL--投薬
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
			mdcc.do_action,
			mdcc.data_type_order,
			mdcc.kind_order,
			mdcc.equipment_cd::INTEGER,
			mdcc.equipment_class_cd ::INTEGER,
			mdcc.medicine_cd,
			mdcc.medicine_class_cd,
			mdcc.dialyzer_cd ::INTEGER
		FROM
		(
			--透析液
			SELECT
				save.supplies_base_no AS ord_no,
				CASE WHEN @dataTypeOrder = ''0'' THEN 1
		               WHEN @dataTypeOrder = ''1'' THEN 2
		               WHEN @dataTypeOrder = ''2'' THEN 2
		               WHEN @dataTypeOrder = ''3'' THEN 1
		               WHEN @dataTypeOrder = ''4'' THEN 3
		               WHEN @dataTypeOrder = ''5'' THEN 3
		               ELSE 1  END AS disp_order,
	       			save.supplies_base_date AS treat_date,
				COALESCE(mdc.class_name, '''') AS kind,
				md.medicine_name AS NAME,
				CAST(NULLIF(save.receipt_value, '''') AS DECIMAL) AS Amount,
				COALESCE(save.receipt_unit, '''') AS Unit,
				md.in_hospital_cd_1,
				md.in_hospital_cd_2,
				md.in_hospital_cd_3,
				md.in_hospital_cd_4,
				md.class_cd :: INTEGER AS class_cd,
				save.supplies_cd AS cd,
				md.medicine_cd AS pk_order,
				''通常薬剤'' AS do_action,
				''薬剤'' AS data_type_order,
				1 AS kind_order,
				NULL AS equipment_cd,
				NULL AS equipment_class_cd,
				save.supplies_cd AS medicine_cd,
				mdc.class_cd :: TEXT AS medicine_class_cd,
				NULL AS dialyzer_cd
			FROM
				save
			LEFT OUTER JOIN md ON save.supplies_cd = CAST(md.medicine_cd AS VARCHAR)
			LEFT OUTER JOIN mdc ON save.class_cd = CAST(mdc.class_cd AS VARCHAR)
			WHERE
				save.supplies_class in (''08'', ''09'')
				AND save.supplies_source_class = ''0''
				AND md.class_cd IN ( @medIds )
			UNION ALL--抗凝固剤
			SELECT
				save.supplies_base_no AS ord_no,
					CASE WHEN @dataTypeOrder = ''0'' THEN 1
               WHEN @dataTypeOrder = ''1'' THEN 2
               WHEN @dataTypeOrder = ''2'' THEN 2
               WHEN @dataTypeOrder = ''3'' THEN 1
               WHEN @dataTypeOrder = ''4'' THEN 3
               WHEN @dataTypeOrder = ''5'' THEN 3
               ELSE 1  END AS disp_order,
				save.supplies_base_date AS treat_date,
				COALESCE ( mdc.class_name, '''' ) AS kind,
				md.medicine_name AS NAME,
				CASE WHEN COALESCE(CAST(save.receipt_value AS DECIMAL), 0) <> 0 THEN  CAST ( save.receipt_value  AS DECIMAL ) ELSE  CAST ( save.ind_rst_value AS DECIMAL ) END  AS Amount,
				CASE WHEN COALESCE(CAST(save.receipt_value AS DECIMAL), 0) <> 0 THEN save.receipt_unit ELSE  COALESCE ( save.ind_unit, '''' ) END AS Unit,
				md.in_hospital_cd_1,
				md.in_hospital_cd_2,
				md.in_hospital_cd_3,
				md.in_hospital_cd_4,
				md.class_cd :: INTEGER AS class_cd,
				save.supplies_cd AS cd,
				md.medicine_cd AS pk_order,
				''通常薬剤'' AS do_action,
				''薬剤'' AS data_type_order,
				1 AS kind_order,
				NULL AS equipment_cd,
				NULL AS equipment_class_cd,
				save.supplies_cd AS medicine_cd,
				mdc.class_cd :: TEXT AS medicine_class_cd,
				NULL AS dialyzer_cd
			FROM
				save
			LEFT OUTER JOIN md ON save.supplies_cd = CAST(md.medicine_cd AS VARCHAR)
			LEFT OUTER JOIN mdc ON save.class_cd = CAST(mdc.class_cd AS VARCHAR)
			WHERE
				save.supplies_class = ''10''
				and save.supplies_source_class = ''0''
				AND md.class_cd IN ( @medIds )
			UNION ALL--抗凝固剤(調製)	
			SELECT
				save.supplies_base_no AS ord_no,
				CASE WHEN @dataTypeOrder = ''0'' THEN 1
			               WHEN @dataTypeOrder = ''1'' THEN 2
			               WHEN @dataTypeOrder = ''2'' THEN 2
			               WHEN @dataTypeOrder = ''3'' THEN 1
			               WHEN @dataTypeOrder = ''4'' THEN 3
			               WHEN @dataTypeOrder = ''5'' THEN 3
			               ELSE 1  END AS disp_order,
				save.supplies_base_date AS treat_date,
				COALESCE ( mdc.class_name, ''未分類'' ) AS kind,
				md.medicine_name AS NAME,
				CASE WHEN COALESCE(CAST(save.receipt_value AS DECIMAL), 0) <> 0 THEN  CAST ( save.receipt_value  AS DECIMAL ) ELSE  CAST ( save.ind_rst_value AS DECIMAL ) END  AS Amount,
				CASE WHEN COALESCE(CAST(save.receipt_value AS DECIMAL), 0) <> 0 THEN save.receipt_unit ELSE  COALESCE ( save.ind_unit, '''' ) END AS Unit,
				md.in_hospital_cd_1,
				md.in_hospital_cd_2,
				md.in_hospital_cd_3,
				md.in_hospital_cd_4,
				md.class_cd :: INTEGER AS class_cd,
				save.supplies_cd AS cd,
				md.medicine_cd AS pk_order,
				''通常薬剤'' AS do_action,
				''薬剤'' AS data_type_order,
				1 AS kind_order,
				NULL AS equipment_cd,
				NULL AS equipment_class_cd,
				save.medicine_mix_cd medicine_cd,
				mdc.class_cd :: TEXT AS medicine_class_cd,
				NULL AS dialyzer_cd
			FROM
				save
			LEFT OUTER JOIN mst_medicine_mix AS mmx ON save.medicine_mix_cd = CAST(mmx.medicine_mix_cd AS VARCHAR)
			LEFT OUTER JOIN md ON save.supplies_cd = CAST(md.medicine_cd AS VARCHAR)
			LEFT OUTER JOIN mdc ON save.class_cd = CAST(mdc.class_cd AS VARCHAR)
			WHERE
				save.supplies_class = ''22''
				AND save.supplies_source_class = ''0''
				AND md.class_cd IN ( @medIds )
			UNION ALL--投与薬剤
			SELECT
				save.supplies_base_no AS ord_no,
				CASE WHEN @dataTypeOrder = ''0'' THEN 1
			               WHEN @dataTypeOrder = ''1'' THEN 2
			               WHEN @dataTypeOrder = ''2'' THEN 2
			               WHEN @dataTypeOrder = ''3'' THEN 1
			               WHEN @dataTypeOrder = ''4'' THEN 3
			               WHEN @dataTypeOrder = ''5'' THEN 3
			               ELSE 1  END AS disp_order,
				save.supplies_base_date AS treat_date,
				COALESCE (
					CASE WHEN oMed.class_name IS NOT NULL THEN oMed.class_name
					WHEN mdc.class_name IS NOT NULL THEN mdc.class_name
					ELSE NULL END
				, ''未分類'' ) AS kind,
				md.medicine_name AS NAME,
				CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
				COALESCE(save.ind_unit, '''') AS Unit,
				md.in_hospital_cd_1,
				md.in_hospital_cd_2,
				md.in_hospital_cd_3,
				md.in_hospital_cd_4,
				md.class_cd AS class_cd,
				save.supplies_cd AS cd,
				md.medicine_cd AS pk_order,
				''通常薬剤'' AS do_action,
				''薬剤'' AS data_type_order,
				1 AS kind_order,
				NULL AS equipment_cd,
				NULL AS equipment_class_cd,
				save.supplies_cd AS medicine_cd,
				mdc.class_cd :: TEXT AS medicine_class_cd,
				NULL AS dialyzer_cd
			FROM
				save
			LEFT OUTER JOIN md ON save.supplies_cd = CAST(md.medicine_cd AS VARCHAR)
			LEFT OUTER JOIN ord_ind_medi_info AS oMed ON save.supplies_cd = CAST(oMed.cd AS VARCHAR) AND save.supplies_base_no = oMed.ord_no
			LEFT OUTER JOIN mdc ON save.class_cd = CAST(mdc.class_cd AS VARCHAR)
			WHERE
				save.supplies_class in (''12'', ''20'')
				AND md.class_cd IN ( @medIds )
		) mdcc
		LEFT OUTER JOIN dmcc ON dmcc.medi_class_code = mdcc.class_cd
		LEFT OUTER JOIN dmccc ON dmccc.medi_code = mdcc.pk_order
		ORDER BY
			dmcc.code_order,dmccc.medi_code_order ASC
		)
	) AS EquipmentList
	LEFT OUTER JOIN medic ON medic.medic_code :: TEXT = EquipmentList.medicine_class_cd
	LEFT OUTER JOIN equic ON equic.equic_code = EquipmentList.equipment_class_cd
	LEFT OUTER JOIN dia ON dia.dia_code = EquipmentList.dialyzer_cd
	LEFT OUTER JOIN medi_mix ON medi_mix.medi_mix_code :: TEXT = EquipmentList.medicine_class_cd
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
		do_action,
		data_type_order,
		kind_order,
		dia_order,
		medic_order,
		equic_order,
		medi_mix_order
	HAVING
		SUM ( Amount ) > 0
	ORDER BY
		disp_order,
	code_order,
	order_cd,
	pk_order,
	kind
)
	
SELECT * from result_all as res @orderBy	', 2, '[]', '1', '{"applications": [1]}', '{"classes": [4]}', '器材準備リスト（降順）', '2025-03-19 18:29:56.851', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (251, 'WITH 
save as (
	SELECT
		* 
	FROM
		ord_material_save save 
	WHERE save.supplies_base_no in (@ordNos)
		AND save.facility_cd = @facilityCd
		AND save.ind_rst_class = ''1''
)
, ord_ind_medi_info AS (
	SELECT
		ord_no,
		info->>''cd'' AS cd,
		info->>''class_cd'' AS class_cd,
		info->>''class_name'' AS class_name
	FROM
		ord_main
	CROSS JOIN LATERAL jsonb_array_elements (ind_medi_info) WITH ORDINALITY AS tmp (info, json_idx)
	WHERE
		ord_no in (@ordNos)
	AND rst_dialysis_state <> ''0''
	AND info->>''class_cd'' IS NOT NULL
),
	md AS (
	SELECT
		*
	FROM
		mst_medicine
	WHERE
		facility_cd = @facilityCd
		AND is_del = ''0''
		AND is_disp = ''1''
	),
	mdc AS (
	SELECT
		*
	FROM
		mst_medicine_class
	WHERE
		facility_cd = @facilityCd
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
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicine_class''
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
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicine''
	),
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
	),
	result_all as (
	SELECT
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
	do_action,
	data_type_order,
	kind_order,
	NULL AS dia_order,
	medic.medic_order,
	NULL AS equic_order,
	medi_mix.medi_mix_order
	FROM
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
			mdcc.do_action,
			mdcc.data_type_order,
			mdcc.kind_order,
			mdcc.medicine_cd,
			mdcc.medicine_class_cd
		FROM
		( 
			--透析液
			SELECT
				save.supplies_base_no AS ord_no,
				CASE WHEN @dataTypeOrder = ''0'' THEN 3
				   WHEN @dataTypeOrder = ''1'' THEN 2
				   WHEN @dataTypeOrder = ''2'' THEN 2
				   WHEN @dataTypeOrder = ''3'' THEN 3
				   WHEN @dataTypeOrder = ''4'' THEN 1
				   WHEN @dataTypeOrder = ''5'' THEN 1
				   ELSE 1  END  AS disp_order,
				save.supplies_base_date AS treat_date,
				COALESCE(mdc.class_name, '''') AS kind,
				md.medicine_name AS NAME,
				CAST(NULLIF(save.receipt_value, '''') AS DECIMAL) AS Amount,
				COALESCE(save.receipt_unit, '''') AS Unit,
				md.in_hospital_cd_1,
				md.in_hospital_cd_2,
				md.in_hospital_cd_3,
				md.in_hospital_cd_4,
				md.class_cd :: INTEGER AS class_cd,
				save.supplies_cd AS cd,
				md.medicine_cd AS pk_order,
				''通常薬剤'' AS do_action,
				''薬剤'' AS data_type_order,
				1 AS kind_order,
				save.supplies_cd AS medicine_cd,
				mdc.class_cd :: TEXT AS medicine_class_cd
			FROM
				save
			LEFT OUTER JOIN md ON save.supplies_cd = CAST(md.medicine_cd AS VARCHAR)
			LEFT OUTER JOIN mdc ON save.class_cd = CAST(mdc.class_cd AS VARCHAR)
			WHERE
				save.supplies_class in (''08'', ''09'')
				AND save.supplies_source_class = ''0''
				AND md.class_cd IN ( @medIds )
			UNION ALL--抗凝固剤
			SELECT
				save.supplies_base_no AS ord_no,
				CASE WHEN @dataTypeOrder = ''0'' THEN 3
				   WHEN @dataTypeOrder = ''1'' THEN 2
				   WHEN @dataTypeOrder = ''2'' THEN 2
				   WHEN @dataTypeOrder = ''3'' THEN 3
				   WHEN @dataTypeOrder = ''4'' THEN 1
				   WHEN @dataTypeOrder = ''5'' THEN 1
				   ELSE 1  END  AS disp_order,
				save.supplies_base_date AS treat_date,
				COALESCE ( mdc.class_name, '''' ) AS kind,
				md.medicine_name AS NAME,
				CASE WHEN COALESCE(CAST(save.receipt_value AS DECIMAL), 0) <> 0 THEN  CAST ( save.receipt_value  AS DECIMAL ) ELSE  CAST ( save.ind_rst_value AS DECIMAL ) END  AS Amount,
				CASE WHEN COALESCE(CAST(save.receipt_value AS DECIMAL), 0) <> 0 THEN save.receipt_unit ELSE  COALESCE ( save.ind_unit, '''' ) END AS Unit,
				md.in_hospital_cd_1,
				md.in_hospital_cd_2,
				md.in_hospital_cd_3,
				md.in_hospital_cd_4,
				md.class_cd :: INTEGER AS class_cd,
				save.supplies_cd AS cd,
				md.medicine_cd AS pk_order,
				''通常薬剤'' AS do_action,
				''薬剤'' AS data_type_order,
				1 AS kind_order,
				save.supplies_cd AS medicine_cd,
				mdc.class_cd :: TEXT AS medicine_class_cd
			FROM
				save
			LEFT OUTER JOIN md ON save.supplies_cd = CAST(md.medicine_cd AS VARCHAR)
			LEFT OUTER JOIN mdc ON save.class_cd = CAST(mdc.class_cd AS VARCHAR)
			WHERE
				save.supplies_class = ''10''
				and save.supplies_source_class = ''0''
				AND md.class_cd IN ( @medIds )
			UNION ALL--抗凝固剤(調製)	
			SELECT
				save.supplies_base_no AS ord_no,
				CASE WHEN @dataTypeOrder = ''0'' THEN 3
				   WHEN @dataTypeOrder = ''1'' THEN 2
				   WHEN @dataTypeOrder = ''2'' THEN 2
				   WHEN @dataTypeOrder = ''3'' THEN 3
				   WHEN @dataTypeOrder = ''4'' THEN 1
				   WHEN @dataTypeOrder = ''5'' THEN 1
				   ELSE 1  END AS disp_order,
				save.supplies_base_date AS treat_date,
				COALESCE ( mdc.class_name, ''未分類'' ) AS kind,
				md.medicine_name AS NAME,
				CASE WHEN COALESCE(CAST(save.receipt_value AS DECIMAL), 0) <> 0 THEN  CAST ( save.receipt_value  AS DECIMAL ) ELSE  CAST ( save.ind_rst_value AS DECIMAL ) END  AS Amount,
				CASE WHEN COALESCE(CAST(save.receipt_value AS DECIMAL), 0) <> 0 THEN save.receipt_unit ELSE  COALESCE ( save.ind_unit, '''' ) END AS Unit,
				md.in_hospital_cd_1,
				md.in_hospital_cd_2,
				md.in_hospital_cd_3,
				md.in_hospital_cd_4,
				md.class_cd :: INTEGER AS class_cd,
				save.supplies_cd AS cd,
				md.medicine_cd AS pk_order,
				''通常薬剤'' AS do_action,
				''薬剤'' AS data_type_order,
				1 AS kind_order,
				save.medicine_mix_cd medicine_cd,
				mdc.class_cd :: TEXT AS medicine_class_cd
			FROM
				save
			LEFT OUTER JOIN mst_medicine_mix AS mmx ON save.medicine_mix_cd = CAST(mmx.medicine_mix_cd AS VARCHAR)
			LEFT OUTER JOIN md ON save.supplies_cd = CAST(md.medicine_cd AS VARCHAR)
			LEFT OUTER JOIN mdc ON save.class_cd = CAST(mdc.class_cd AS VARCHAR)
			WHERE
				save.supplies_class = ''22''
				AND save.supplies_source_class = ''0''
				AND md.class_cd IN ( @medIds )
			UNION ALL--投与薬剤
			SELECT
				save.supplies_base_no AS ord_no,
				CASE WHEN @dataTypeOrder = ''0'' THEN 3
				   WHEN @dataTypeOrder = ''1'' THEN 2
				   WHEN @dataTypeOrder = ''2'' THEN 2
				   WHEN @dataTypeOrder = ''3'' THEN 3
				   WHEN @dataTypeOrder = ''4'' THEN 1
				   WHEN @dataTypeOrder = ''5'' THEN 1
				   ELSE 1  END  AS disp_order,
				save.supplies_base_date AS treat_date,
				COALESCE (
					CASE WHEN oMed.class_name IS NOT NULL THEN oMed.class_name
					WHEN mdc.class_name IS NOT NULL THEN mdc.class_name
					ELSE NULL END
				, ''未分類'' ) AS kind,
				md.medicine_name AS NAME,
				CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
				COALESCE(save.ind_unit, '''') AS Unit,
				md.in_hospital_cd_1,
				md.in_hospital_cd_2,
				md.in_hospital_cd_3,
				md.in_hospital_cd_4,
				md.class_cd AS class_cd,
				save.supplies_cd AS cd,
				md.medicine_cd AS pk_order,
				''通常薬剤'' AS do_action,
				''薬剤'' AS data_type_order,
				1 AS kind_order,
				save.supplies_cd AS medicine_cd,
				mdc.class_cd :: TEXT AS medicine_class_cd
			FROM
				save
			LEFT OUTER JOIN md ON save.supplies_cd = CAST(md.medicine_cd AS VARCHAR)
			LEFT OUTER JOIN ord_ind_medi_info AS oMed ON save.supplies_cd = CAST(oMed.cd AS VARCHAR) AND save.supplies_base_no = oMed.ord_no
			LEFT OUTER JOIN mdc ON save.class_cd = CAST(mdc.class_cd AS VARCHAR)
			WHERE
				save.supplies_class in (''12'', ''20'')
				AND md.class_cd IN ( @medIds )
		) mdcc
		LEFT OUTER JOIN dmcc ON dmcc.medi_class_code = mdcc.class_cd
		LEFT OUTER JOIN dmccc ON dmccc.medi_code = mdcc.pk_order
		ORDER BY
			dmcc.code_order,dmccc.medi_code_order ASC
	) AS EquipmentList
	LEFT OUTER JOIN medic ON medic.medic_code :: TEXT = EquipmentList.medicine_class_cd
	LEFT OUTER JOIN medi_mix ON medi_mix.medi_mix_code :: TEXT = EquipmentList.medicine_class_cd
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
		do_action,
		data_type_order,
		kind_order,
		medic_order,
		medi_mix_order
	HAVING
		SUM ( Amount ) > 0
	ORDER BY
		disp_order,
	code_order,
	order_cd,
	pk_order,
	kind
)
	
SELECT * from result_all as res @orderBy	', 2, '[{"preview": "テープ", "can_calc": "0", "data_code": "kind", "data_name": "分類名称", "data_type": "string", "conv_table": [], "data_class": "物品情報(薬剤)", "field_name": "kind", "disp_format": "", "filter_type": "Medicine", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70%ブドウ糖注射液350ml", "can_calc": "0", "data_code": "name", "data_name": "型番･名称", "data_type": "string", "conv_table": [], "data_class": "物品情報(薬剤)", "field_name": "name", "disp_format": "", "filter_type": "Medicine", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "1", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "物品情報(薬剤)", "field_name": "amount", "disp_format": "0.00", "filter_type": "Medicine", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "個", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "物品情報(薬剤)", "field_name": "unit", "disp_format": "", "filter_type": "Medicine", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "物品情報(薬剤)", "field_name": "in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "物品情報(薬剤)", "field_name": "in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "物品情報(薬剤)", "field_name": "in_hospital_cd_3", "disp_format": "", "filter_type": "Medicine", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_4", "data_name": "院内コード4", "data_type": "string", "conv_table": [], "data_class": "物品情報(薬剤)", "field_name": "in_hospital_cd_4", "disp_format": "", "filter_type": "Medicine", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [4]}', '器材準備リスト (物品情報(薬剤))', '2025-04-30 15:59:32.312', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (252, 'WITH
save as (
	SELECT
		* 
	FROM
		ord_material_save save 
	WHERE save.supplies_base_no in (@ordNos)
		AND save.facility_cd = @facilityCd
		AND save.ind_rst_class = ''1''
)
, ord_ind_medi_info AS (
	SELECT
		ord_no,
		info->>''cd'' AS cd,
		info->>''class_cd'' AS class_cd,
		info->>''class_name'' AS class_name
	FROM
		ord_main
	CROSS JOIN LATERAL jsonb_array_elements (ind_medi_info) WITH ORDINALITY AS tmp (info, json_idx)
	WHERE
		ord_no in (@ordNos)
	AND rst_dialysis_state <> ''0''
	AND info->>''class_cd'' IS NOT NULL
),
	md AS (
	SELECT
		*
	FROM
		mst_medicine
	WHERE
		facility_cd = @facilityCd
		AND is_del = ''0''
		AND is_disp = ''1''
	),
	mdc AS (
	SELECT
		*
	FROM
		mst_medicine_class
	WHERE
		facility_cd = @facilityCd
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
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicine_class''
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
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicine''
	),
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
	),
	result_all as (
	SELECT
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
	do_action,
	data_type_order,
	kind_order,
	NULL AS dia_order,
	medic.medic_order,
	NULL AS equic_order,
	medi_mix.medi_mix_order
FROM
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
			mdcc.do_action,
			mdcc.data_type_order,
			mdcc.kind_order,
			mdcc.medicine_cd,
			mdcc.medicine_class_cd
		FROM
		(
			--透析液
			SELECT
				save.supplies_base_no AS ord_no,
				CASE WHEN @dataTypeOrder = ''0'' THEN 1
		               WHEN @dataTypeOrder = ''1'' THEN 2
		               WHEN @dataTypeOrder = ''2'' THEN 2
		               WHEN @dataTypeOrder = ''3'' THEN 1
		               WHEN @dataTypeOrder = ''4'' THEN 3
		               WHEN @dataTypeOrder = ''5'' THEN 3
		               ELSE 1  END AS disp_order,
	       			save.supplies_base_date AS treat_date,
				COALESCE(mdc.class_name, '''') AS kind,
				md.medicine_name AS NAME,
				CAST(NULLIF(save.receipt_value, '''') AS DECIMAL) AS Amount,
				COALESCE(save.receipt_unit, '''') AS Unit,
				md.in_hospital_cd_1,
				md.in_hospital_cd_2,
				md.in_hospital_cd_3,
				md.in_hospital_cd_4,
				md.class_cd :: INTEGER AS class_cd,
				save.supplies_cd AS cd,
				md.medicine_cd AS pk_order,
				''通常薬剤'' AS do_action,
				''薬剤'' AS data_type_order,
				1 AS kind_order,
				save.supplies_cd AS medicine_cd,
				mdc.class_cd :: TEXT AS medicine_class_cd
			FROM
				save
			LEFT OUTER JOIN md ON save.supplies_cd = CAST(md.medicine_cd AS VARCHAR)
			LEFT OUTER JOIN mdc ON save.class_cd = CAST(mdc.class_cd AS VARCHAR)
			WHERE
				save.supplies_class in (''08'', ''09'')
				AND save.supplies_source_class = ''0''
				AND md.class_cd IN ( @medIds )
			UNION ALL--抗凝固剤
			SELECT
				save.supplies_base_no AS ord_no,
					CASE WHEN @dataTypeOrder = ''0'' THEN 1
               WHEN @dataTypeOrder = ''1'' THEN 2
               WHEN @dataTypeOrder = ''2'' THEN 2
               WHEN @dataTypeOrder = ''3'' THEN 1
               WHEN @dataTypeOrder = ''4'' THEN 3
               WHEN @dataTypeOrder = ''5'' THEN 3
               ELSE 1  END AS disp_order,
				save.supplies_base_date AS treat_date,
				COALESCE ( mdc.class_name, '''' ) AS kind,
				md.medicine_name AS NAME,
				CASE WHEN COALESCE(CAST(save.receipt_value AS DECIMAL), 0) <> 0 THEN  CAST ( save.receipt_value  AS DECIMAL ) ELSE  CAST ( save.ind_rst_value AS DECIMAL ) END  AS Amount,
				CASE WHEN COALESCE(CAST(save.receipt_value AS DECIMAL), 0) <> 0 THEN save.receipt_unit ELSE  COALESCE ( save.ind_unit, '''' ) END AS Unit,
				md.in_hospital_cd_1,
				md.in_hospital_cd_2,
				md.in_hospital_cd_3,
				md.in_hospital_cd_4,
				md.class_cd :: INTEGER AS class_cd,
				save.supplies_cd AS cd,
				md.medicine_cd AS pk_order,
				''通常薬剤'' AS do_action,
				''薬剤'' AS data_type_order,
				1 AS kind_order,
				save.supplies_cd AS medicine_cd,
				mdc.class_cd :: TEXT AS medicine_class_cd
			FROM
				save
			LEFT OUTER JOIN md ON save.supplies_cd = CAST(md.medicine_cd AS VARCHAR)
			LEFT OUTER JOIN mdc ON save.class_cd = CAST(mdc.class_cd AS VARCHAR)
			WHERE
				save.supplies_class = ''10''
				and save.supplies_source_class = ''0''
				AND md.class_cd IN ( @medIds )
			UNION ALL--抗凝固剤(調製)	
			SELECT
				save.supplies_base_no AS ord_no,
				CASE WHEN @dataTypeOrder = ''0'' THEN 1
			               WHEN @dataTypeOrder = ''1'' THEN 2
			               WHEN @dataTypeOrder = ''2'' THEN 2
			               WHEN @dataTypeOrder = ''3'' THEN 1
			               WHEN @dataTypeOrder = ''4'' THEN 3
			               WHEN @dataTypeOrder = ''5'' THEN 3
			               ELSE 1  END AS disp_order,
				save.supplies_base_date AS treat_date,
				COALESCE ( mdc.class_name, ''未分類'' ) AS kind,
				md.medicine_name AS NAME,
				CASE WHEN COALESCE(CAST(save.receipt_value AS DECIMAL), 0) <> 0 THEN  CAST ( save.receipt_value  AS DECIMAL ) ELSE  CAST ( save.ind_rst_value AS DECIMAL ) END  AS Amount,
				CASE WHEN COALESCE(CAST(save.receipt_value AS DECIMAL), 0) <> 0 THEN save.receipt_unit ELSE  COALESCE ( save.ind_unit, '''' ) END AS Unit,
				md.in_hospital_cd_1,
				md.in_hospital_cd_2,
				md.in_hospital_cd_3,
				md.in_hospital_cd_4,
				md.class_cd :: INTEGER AS class_cd,
				save.supplies_cd AS cd,
				md.medicine_cd AS pk_order,
				''通常薬剤'' AS do_action,
				''薬剤'' AS data_type_order,
				1 AS kind_order,
				save.medicine_mix_cd medicine_cd,
				mdc.class_cd :: TEXT AS medicine_class_cd
			FROM
				save
			LEFT OUTER JOIN mst_medicine_mix AS mmx ON save.medicine_mix_cd = CAST(mmx.medicine_mix_cd AS VARCHAR)
			LEFT OUTER JOIN md ON save.supplies_cd = CAST(md.medicine_cd AS VARCHAR)
			LEFT OUTER JOIN mdc ON save.class_cd = CAST(mdc.class_cd AS VARCHAR)
			WHERE
				save.supplies_class = ''22''
				AND save.supplies_source_class = ''0''
				AND md.class_cd IN ( @medIds )
			UNION ALL--投与薬剤
			SELECT
				save.supplies_base_no AS ord_no,
				CASE WHEN @dataTypeOrder = ''0'' THEN 1
			               WHEN @dataTypeOrder = ''1'' THEN 2
			               WHEN @dataTypeOrder = ''2'' THEN 2
			               WHEN @dataTypeOrder = ''3'' THEN 1
			               WHEN @dataTypeOrder = ''4'' THEN 3
			               WHEN @dataTypeOrder = ''5'' THEN 3
			               ELSE 1  END AS disp_order,
				save.supplies_base_date AS treat_date,
				COALESCE (
					CASE WHEN oMed.class_name IS NOT NULL THEN oMed.class_name
					WHEN mdc.class_name IS NOT NULL THEN mdc.class_name
					ELSE NULL END
				, ''未分類'' ) AS kind,
				md.medicine_name AS NAME,
				CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
				COALESCE(save.ind_unit, '''') AS Unit,
				md.in_hospital_cd_1,
				md.in_hospital_cd_2,
				md.in_hospital_cd_3,
				md.in_hospital_cd_4,
				md.class_cd AS class_cd,
				save.supplies_cd AS cd,
				md.medicine_cd AS pk_order,
				''通常薬剤'' AS do_action,
				''薬剤'' AS data_type_order,
				1 AS kind_order,
				save.supplies_cd AS medicine_cd,
				mdc.class_cd :: TEXT AS medicine_class_cd
			FROM
				save
			LEFT OUTER JOIN md ON save.supplies_cd = CAST(md.medicine_cd AS VARCHAR)
			LEFT OUTER JOIN ord_ind_medi_info AS oMed ON save.supplies_cd = CAST(oMed.cd AS VARCHAR) AND save.supplies_base_no = oMed.ord_no
			LEFT OUTER JOIN mdc ON save.class_cd = CAST(mdc.class_cd AS VARCHAR)
			WHERE
				save.supplies_class in (''12'', ''20'')
				AND md.class_cd IN ( @medIds )
		) mdcc
		LEFT OUTER JOIN dmcc ON dmcc.medi_class_code = mdcc.class_cd
		LEFT OUTER JOIN dmccc ON dmccc.medi_code = mdcc.pk_order
		ORDER BY
			dmcc.code_order,dmccc.medi_code_order ASC
	) AS EquipmentList
	LEFT OUTER JOIN medic ON medic.medic_code :: TEXT = EquipmentList.medicine_class_cd
	LEFT OUTER JOIN medi_mix ON medi_mix.medi_mix_code :: TEXT = EquipmentList.medicine_class_cd
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
		do_action,
		data_type_order,
		kind_order,
		medic_order,
		medi_mix_order
	HAVING
		SUM ( Amount ) > 0
	ORDER BY
		disp_order,
	code_order,
	order_cd,
	pk_order,
	kind
)
	
SELECT * from result_all as res @orderBy	', 2, '[]', '1', '{"applications": [1]}', '{"classes": [4]}', '器材準備リスト (物品情報(薬剤))（降順）', '2025-04-30 15:59:32.316', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (253, 'WITH
save as (
	SELECT
		* 
	FROM
		ord_material_save save 
	WHERE save.supplies_base_no in (@ordNos)
		AND save.facility_cd = @facilityCd
		AND save.ind_rst_class = ''1''
)
, ord_ind_equip_info AS (
	SELECT
		ord_no,
		info->>''cd'' AS cd,
		info->>''class_cd'' AS class_cd,
		info->>''class_name'' AS class_name
	FROM
		ord_main
	CROSS JOIN LATERAL jsonb_array_elements (ind_equip_info) WITH ORDINALITY AS tmp (info, json_idx)
	WHERE
		ord_no in (@ordNos)
	AND rst_dialysis_state <> ''0''
	AND info->>''class_cd'' IS NOT NULL
)
, dz AS (
	SELECT
		*
	FROM
		mst_dialyzer
	WHERE
		facility_cd = @facilityCd
		AND is_del = ''0''
		AND is_disp = ''1''
)
,	eq AS (
	SELECT
		*
	FROM
		mst_equipment
	WHERE
		facility_cd = @facilityCd
		AND is_del = ''0''
		AND is_disp = ''1''
)
,	eqc AS (
	SELECT
		*
	FROM
		mst_equipment_class
	WHERE
		facility_cd = @facilityCd
		AND is_del = ''0''
		AND is_disp = ''1''
)
,	meqc AS (
	SELECT
		index_no AS code_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS meq_class_code,
		order_cd ->> ''name'' AS meq_class_code_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_equipment_class''
)
,	meqcc AS (
	SELECT
		index_no AS meq_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS meq_code,
		order_cd ->> ''name'' AS meq_code_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_equipment''
)
,	equic AS (
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
)
,	dia AS (
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
,	result_all as (
	SELECT
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
		do_action,
		data_type_order,
		kind_order,
		dia.dia_order,
		NULL AS medic_order,
		equic.equic_order,
		NULL AS medi_mix_order
	FROM
	(
		--治療条件:ダイアライザ
		SELECT
			save.supplies_base_no AS ord_no,
			CASE WHEN @dataTypeOrder = ''0'' THEN 2
				WHEN @dataTypeOrder = ''1'' THEN 3
				WHEN @dataTypeOrder = ''2'' THEN 1
				WHEN @dataTypeOrder = ''3'' THEN 1
				WHEN @dataTypeOrder = ''4'' THEN 2
				WHEN @dataTypeOrder = ''5'' THEN 3
				ELSE 1  END AS disp_order,
			save.supplies_base_date AS treat_date,
			''ダイアライザ'' AS kind,
			dz.model_number AS NAME,
			CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
			COALESCE(save.ind_unit, '''') AS Unit,
			dz.in_hospital_cd_1,
			dz.in_hospital_cd_2,
			dz.in_hospital_cd_3,
			dz.in_hospital_cd_4,
			-10 AS class_cd,
			save.supplies_cd AS cd,
			0 AS code_order,
			0 AS order_cd,
			dz.dialyzer_cd AS pk_order,
			''ダイアライザ'' AS do_action,
			''医療材料'' AS data_type_order,
			2 AS kind_order,
			NULL AS equipment_cd,
			NULL AS equipment_class_cd,
			dz.dialyzer_cd
		FROM
			save
		LEFT JOIN dz ON save.supplies_cd = CAST(dz.dialyzer_cd AS VARCHAR)
		WHERE
			save.supplies_class = ''01''
			AND save.supplies_source_class = ''0''
			AND dz.dialyzer_cd IN ( @diaIds )
		UNION ALL
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
				emq.do_action,
				emq.data_type_order,
				emq.kind_order,
				emq.equipment_cd,
				emq.equipment_class_cd,
				emq.dialyzer_cd ::INTEGER
			FROM
			(
				--治療条件
				SELECT
					save.supplies_base_no AS ord_no,
					CASE WHEN @dataTypeOrder = ''0'' THEN 2
						WHEN @dataTypeOrder = ''1'' THEN 3
						WHEN @dataTypeOrder = ''2'' THEN 1
						WHEN @dataTypeOrder = ''3'' THEN 1
						WHEN @dataTypeOrder = ''4'' THEN 2
						WHEN @dataTypeOrder = ''5'' THEN 3
						ELSE 1  END AS disp_order,
					save.supplies_base_date AS treat_date,
					COALESCE ( eqc.class_name, '''' ) AS kind,
					eq.equipment_name AS NAME,
					CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
					COALESCE(save.ind_unit, '''') AS Unit,
					eq.in_hospital_cd_1,
					eq.in_hospital_cd_2,
					eq.in_hospital_cd_3,
					eq.in_hospital_cd_4,
					eq.class_cd :: INTEGER AS class_cd,
					save.supplies_cd AS cd,
					eq.equipment_cd AS pk_order,
					''医材'' AS do_action,
					''医療材料'' AS data_type_order,
					1 AS kind_order,
					eq.equipment_cd AS equipment_cd,
					eqc.class_cd AS equipment_class_cd,
					NULL AS dialyzer_cd
				FROM
					save
				LEFT JOIN eq ON save.supplies_cd = CAST(eq.equipment_cd AS VARCHAR)
				LEFT JOIN eqc ON save.class_cd = CAST(eqc.class_cd AS VARCHAR)
				WHERE
					save.supplies_class in (''02'',''03'',''04'',''06'',''07'',''05'',''00'')
					AND save.supplies_source_class = ''0''
					AND eq.class_cd IN ( @eqIds )
				UNION ALL--医材
				SELECT		
					save.supplies_base_no AS ord_no,
					CASE WHEN @dataTypeOrder = ''0'' THEN 2
						WHEN @dataTypeOrder = ''1'' THEN 3
						WHEN @dataTypeOrder = ''2'' THEN 1
						WHEN @dataTypeOrder = ''3'' THEN 1
						WHEN @dataTypeOrder = ''4'' THEN 2
						WHEN @dataTypeOrder = ''5'' THEN 3
						ELSE 1  END  AS disp_order,
					save.supplies_base_date AS treat_date,
				COALESCE (
					CASE WHEN oEqu.class_name IS NOT NULL THEN oEqu.class_name
						WHEN eqc.class_name IS NOT NULL THEN eqc.class_name
						ELSE NULL END
				, ''未分類'' ) AS kind,
					eq.equipment_name AS NAME,
					CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
					COALESCE(save.ind_unit, '''') AS Unit,
					eq.in_hospital_cd_1,
					eq.in_hospital_cd_2,
					eq.in_hospital_cd_3,
					eq.in_hospital_cd_4,
					eq.class_cd :: INTEGER AS class_cd,
					save.supplies_cd AS cd,
					eq.equipment_cd AS pk_order,
					''医材'' AS do_action,
					''医療材料'' AS data_type_order,
					1 AS kind_order,
					eq.equipment_cd AS equipment_cd,
					eqc.class_cd AS equipment_class_cd,
					NULL AS dialyzer_cd
				FROM
					save
				LEFT JOIN eq ON save.supplies_cd = CAST(eq.equipment_cd AS VARCHAR)
			LEFT OUTER JOIN ord_ind_equip_info AS oEqu ON save.supplies_cd = CAST(oEqu.cd AS VARCHAR) AND save.supplies_base_no = oEqu.ord_no
				LEFT OUTER JOIN eqc ON save.class_cd = CAST(eqc.class_cd AS VARCHAR)
				WHERE
					save.supplies_class = ''11''
					AND eq.class_cd IN ( @eqIds )
			) emq
			LEFT OUTER JOIN meqc ON emq.class_cd = meqc.meq_class_code
			LEFT OUTER JOIN meqcc ON emq.pk_order = meqcc.meq_code
			ORDER BY
				meqc.code_order,meqcc.meq_order
		)
		UNION ALL--医材:ダイアライザ
		SELECT
			save.supplies_base_no AS ord_no,
			CASE WHEN @dataTypeOrder = ''0'' THEN 2
				WHEN @dataTypeOrder = ''1'' THEN 3
				WHEN @dataTypeOrder = ''2'' THEN 1
				WHEN @dataTypeOrder = ''3'' THEN 1
				WHEN @dataTypeOrder = ''4'' THEN 2
				WHEN @dataTypeOrder = ''5'' THEN 3
				ELSE 1  END  AS disp_order,
			save.supplies_base_date AS treat_date,
			''ダイアライザ'' AS kind,
			dz.model_number AS NAME,
			CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
			COALESCE(save.ind_unit, '''') AS Unit,
			dz.in_hospital_cd_1,
			dz.in_hospital_cd_2,
			dz.in_hospital_cd_3,
			dz.in_hospital_cd_4,
			-10 AS class_cd,
			save.supplies_cd AS cd,
			0 AS code_order,
			0 AS order_cd,
			dz.dialyzer_cd AS pk_order,
			''ダイアライザ'' AS do_action,
			''医療材料'' AS data_type_order,
			2 AS kind_order,
			NULL AS equipment_cd,
			NULL AS equipment_class_cd,
			dz.dialyzer_cd
		FROM
			save
		LEFT JOIN dz ON save.supplies_cd = CAST(dz.dialyzer_cd AS VARCHAR)
		WHERE
			save.supplies_class = ''01''
			AND save.supplies_source_class = ''2''
			AND dz.dialyzer_cd IN ( @diaIds )
	) AS EquipmentList
	LEFT OUTER JOIN equic ON equic.equic_code = EquipmentList.equipment_class_cd
	LEFT OUTER JOIN dia ON dia.dia_code = EquipmentList.dialyzer_cd
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
		do_action,
		data_type_order,
		kind_order,
		dia_order,
		equic_order
	HAVING
		SUM ( Amount ) > 0
	ORDER BY
		disp_order,
		code_order,
		order_cd,
		pk_order,
		kind
)	
SELECT * from result_all as res @orderBy', 2, '[{"preview": "テープ", "can_calc": "0", "data_code": "kind", "data_name": "分類名称", "data_type": "string", "conv_table": [], "data_class": "物品情報(器材)", "field_name": "kind", "disp_format": "", "filter_type": "EquipDia", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70%ブドウ糖注射液350ml", "can_calc": "0", "data_code": "name", "data_name": "型番･名称", "data_type": "string", "conv_table": [], "data_class": "物品情報(器材)", "field_name": "name", "disp_format": "", "filter_type": "EquipDia", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "1", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "物品情報(器材)", "field_name": "amount", "disp_format": "0.00", "filter_type": "EquipDia", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "個", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "物品情報(器材)", "field_name": "unit", "disp_format": "", "filter_type": "EquipDia", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "物品情報(器材)", "field_name": "in_hospital_cd_1", "disp_format": "", "filter_type": "EquipDia", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "物品情報(器材)", "field_name": "in_hospital_cd_2", "disp_format": "", "filter_type": "EquipDia", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "物品情報(器材)", "field_name": "in_hospital_cd_3", "disp_format": "", "filter_type": "EquipDia", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_4", "data_name": "院内コード4", "data_type": "string", "conv_table": [], "data_class": "物品情報(器材)", "field_name": "in_hospital_cd_4", "disp_format": "", "filter_type": "EquipDia", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [4]}', '器材準備リスト(物品情報(器材))', '2025-04-30 15:59:32.321', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (254, 'WITH
save as (
	SELECT
		* 
	FROM
		ord_material_save save 
	WHERE save.supplies_base_no in (@ordNos)
		AND save.facility_cd = @facilityCd
		AND save.ind_rst_class = ''1''
)
, ord_ind_equip_info AS (
	SELECT
		ord_no,
		info->>''cd'' AS cd,
		info->>''class_cd'' AS class_cd,
		info->>''class_name'' AS class_name
	FROM
		ord_main
	CROSS JOIN LATERAL jsonb_array_elements (ind_equip_info) WITH ORDINALITY AS tmp (info, json_idx)
	WHERE
		ord_no in (@ordNos)
	AND rst_dialysis_state <> ''0''
	AND info->>''class_cd'' IS NOT NULL
)
, dz AS (
	SELECT
		*
	FROM
		mst_dialyzer
	WHERE
		facility_cd = @facilityCd
		AND is_del = ''0''
		AND is_disp = ''1''
)
,	eq AS (
	SELECT
		*
	FROM
		mst_equipment
	WHERE
		facility_cd = @facilityCd
		AND is_del = ''0''
		AND is_disp = ''1''
)
,	eqc AS (
	SELECT
		*
	FROM
		mst_equipment_class
	WHERE
		facility_cd = @facilityCd
		AND is_del = ''0''
		AND is_disp = ''1''
)
,	meqc AS (
	SELECT
		index_no AS code_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS meq_class_code,
		order_cd ->> ''name'' AS meq_class_code_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_equipment_class''
)
,	meqcc AS (
	SELECT
		index_no AS meq_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS meq_code,
		order_cd ->> ''name'' AS meq_code_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_equipment''
)
,	equic AS (
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
)
,	dia AS (
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
,	result_all as (
	SELECT
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
		do_action,
		data_type_order,
		kind_order,
		dia.dia_order,
		NULL AS medic_order,
		equic.equic_order,
		NULL AS medi_mix_order
	FROM
	(
		--治療条件:ダイアライザ
		SELECT
			save.supplies_base_no AS ord_no,
			CASE WHEN @dataTypeOrder = ''0'' THEN 2
				WHEN @dataTypeOrder = ''1'' THEN 1
				WHEN @dataTypeOrder = ''2'' THEN 3
				WHEN @dataTypeOrder = ''3'' THEN 3
				WHEN @dataTypeOrder = ''4'' THEN 2
				WHEN @dataTypeOrder = ''5'' THEN 1
				ELSE 1  END AS disp_order,
			save.supplies_base_date AS treat_date,
			''ダイアライザ'' AS kind,
			dz.model_number AS NAME,
			CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
			COALESCE(save.ind_unit, '''') AS Unit,
			dz.in_hospital_cd_1,
			dz.in_hospital_cd_2,
			dz.in_hospital_cd_3,
			dz.in_hospital_cd_4,
			-10 AS class_cd,
			save.supplies_cd AS cd,
			0 AS code_order,
			0 AS order_cd,
			dz.dialyzer_cd AS pk_order,
			''ダイアライザ'' AS do_action,
			''医療材料'' AS data_type_order,
			2 AS kind_order,
			NULL AS equipment_cd,
			NULL AS equipment_class_cd,
			dz.dialyzer_cd
		FROM
			save
		LEFT JOIN dz ON save.supplies_cd = CAST(dz.dialyzer_cd AS VARCHAR)
		WHERE
			save.supplies_class = ''01''
			AND save.supplies_source_class = ''0''
			AND dz.dialyzer_cd IN ( @diaIds )
		UNION ALL
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
				emq.do_action,
				emq.data_type_order,
				emq.kind_order,
				emq.equipment_cd,
				emq.equipment_class_cd,
				emq.dialyzer_cd ::INTEGER
			FROM
			(
				--治療条件
				SELECT
					save.supplies_base_no AS ord_no,
					CASE WHEN @dataTypeOrder = ''0'' THEN 2
						WHEN @dataTypeOrder = ''1'' THEN 1
						WHEN @dataTypeOrder = ''2'' THEN 3
						WHEN @dataTypeOrder = ''3'' THEN 3
						WHEN @dataTypeOrder = ''4'' THEN 2
						WHEN @dataTypeOrder = ''5'' THEN 1
						ELSE 1  END AS disp_order,
					save.supplies_base_date AS treat_date,
					COALESCE ( eqc.class_name, '''' ) AS kind,
					eq.equipment_name AS NAME,
					CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
					COALESCE(save.ind_unit, '''') AS Unit,
					eq.in_hospital_cd_1,
					eq.in_hospital_cd_2,
					eq.in_hospital_cd_3,
					eq.in_hospital_cd_4,
					eq.class_cd :: INTEGER AS class_cd,
					save.supplies_cd AS cd,
					eq.equipment_cd AS pk_order,
					''医材'' AS do_action,
					''医療材料'' AS data_type_order,
					1 AS kind_order,
					eq.equipment_cd AS equipment_cd,
					eqc.class_cd AS equipment_class_cd,
					NULL AS dialyzer_cd
				FROM
					save
				LEFT JOIN eq ON save.supplies_cd = CAST(eq.equipment_cd AS VARCHAR)
				LEFT JOIN eqc ON save.class_cd = CAST(eqc.class_cd AS VARCHAR)
				WHERE
					save.supplies_class in (''02'',''03'',''04'',''06'',''07'',''05'',''00'')
					AND save.supplies_source_class = ''0''
					AND eq.class_cd IN ( @eqIds )
				UNION ALL--医材
				SELECT		
					save.supplies_base_no AS ord_no,
					CASE WHEN @dataTypeOrder = ''0'' THEN 2
					WHEN @dataTypeOrder = ''1'' THEN 1
					WHEN @dataTypeOrder = ''2'' THEN 3
					WHEN @dataTypeOrder = ''3'' THEN 3
					WHEN @dataTypeOrder = ''4'' THEN 2
					WHEN @dataTypeOrder = ''5'' THEN 1
					ELSE 1  END AS disp_order,
					save.supplies_base_date AS treat_date,
				COALESCE (
					CASE WHEN oEqu.class_name IS NOT NULL THEN oEqu.class_name
						WHEN eqc.class_name IS NOT NULL THEN eqc.class_name
						ELSE NULL END
				, ''未分類'' ) AS kind,
					eq.equipment_name AS NAME,
					CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
					COALESCE(save.ind_unit, '''') AS Unit,
					eq.in_hospital_cd_1,
					eq.in_hospital_cd_2,
					eq.in_hospital_cd_3,
					eq.in_hospital_cd_4,
					eq.class_cd :: INTEGER AS class_cd,
					save.supplies_cd AS cd,
					eq.equipment_cd AS pk_order,
					''医材'' AS do_action,
					''医療材料'' AS data_type_order,
					1 AS kind_order,
					eq.equipment_cd AS equipment_cd,
					eqc.class_cd AS equipment_class_cd,
					NULL AS dialyzer_cd
				FROM
					save
				LEFT JOIN eq ON save.supplies_cd = CAST(eq.equipment_cd AS VARCHAR)
			LEFT OUTER JOIN ord_ind_equip_info AS oEqu ON save.supplies_cd = CAST(oEqu.cd AS VARCHAR) AND save.supplies_base_no = oEqu.ord_no
				LEFT OUTER JOIN eqc ON save.class_cd = CAST(eqc.class_cd AS VARCHAR)
				WHERE
					save.supplies_class = ''11''
					AND eq.class_cd IN ( @eqIds )
			) emq
			LEFT OUTER JOIN meqc ON emq.class_cd = meqc.meq_class_code
			LEFT OUTER JOIN meqcc ON emq.pk_order = meqcc.meq_code
			ORDER BY
				meqc.code_order,meqcc.meq_order
		)
		UNION ALL--医材:ダイアライザ
		SELECT
			save.supplies_base_no AS ord_no,
				CASE WHEN @dataTypeOrder = ''0'' THEN 2
				WHEN @dataTypeOrder = ''1'' THEN 1
				WHEN @dataTypeOrder = ''2'' THEN 3
				WHEN @dataTypeOrder = ''3'' THEN 3
				WHEN @dataTypeOrder = ''4'' THEN 2
				WHEN @dataTypeOrder = ''5'' THEN 1
				ELSE 1  END AS disp_order,
			save.supplies_base_date AS treat_date,
			''ダイアライザ'' AS kind,
			dz.model_number AS NAME,
			CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
			COALESCE(save.ind_unit, '''') AS Unit,
			dz.in_hospital_cd_1,
			dz.in_hospital_cd_2,
			dz.in_hospital_cd_3,
			dz.in_hospital_cd_4,
			-10 AS class_cd,
			save.supplies_cd AS cd,
			0 AS code_order,
			0 AS order_cd,
			dz.dialyzer_cd AS pk_order,
			''ダイアライザ'' AS do_action,
			''医療材料'' AS data_type_order,
			2 AS kind_order,
			NULL AS equipment_cd,
			NULL AS equipment_class_cd,
			dz.dialyzer_cd
		FROM
			save
		LEFT JOIN dz ON save.supplies_cd = CAST(dz.dialyzer_cd AS VARCHAR)
		WHERE
			save.supplies_class = ''01''
			AND save.supplies_source_class = ''2''
			AND dz.dialyzer_cd IN ( @diaIds )
	) AS EquipmentList
	LEFT OUTER JOIN equic ON equic.equic_code = EquipmentList.equipment_class_cd
	LEFT OUTER JOIN dia ON dia.dia_code = EquipmentList.dialyzer_cd
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
		do_action,
		data_type_order,
		kind_order,
		dia_order,
		equic_order
	HAVING
		SUM ( Amount ) > 0
	ORDER BY
		disp_order,
		code_order,
		order_cd,
		pk_order,
		kind
)
SELECT * from result_all as res @orderBy', 2, '[]', '1', '{"applications": [1]}', '{"classes": [4]}', '器材準備リスト(物品情報(器材))（降順）', '2025-04-30 15:59:32.325', CURRENT_TIMESTAMP, NULL);
