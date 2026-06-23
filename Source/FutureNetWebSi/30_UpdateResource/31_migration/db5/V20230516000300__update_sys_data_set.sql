DELETE FROM "ntss"."sys_data_set" where sql_cd in (74);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (74, 'WITH ord_key_tbl AS ( SELECT facility_cd FROM ord_main WHERE ord_no = @ordNo AND is_del = ''0'' ),
dialyzer_tbl AS (
	SELECT
		*
	FROM
		mst_dialyzer
	WHERE
		mst_dialyzer.facility_cd = ( SELECT facility_cd FROM ord_key_tbl )
		AND mst_dialyzer.is_disp = ''1''
		AND mst_dialyzer.is_del = ''0''
	),
	equipment_tbl AS (
	SELECT
		*
	FROM
		mst_equipment
	WHERE
		mst_equipment.facility_cd = ( SELECT facility_cd FROM ord_key_tbl )
		AND mst_equipment.is_disp = ''1''
		AND mst_equipment.is_del = ''0''
	),
	equipment_class_tbl AS (
	SELECT
		*
	FROM
		mst_equipment_class
	WHERE
		mst_equipment_class.facility_cd = ( SELECT facility_cd FROM ord_key_tbl )
		AND mst_equipment_class.is_disp = ''1''
		AND mst_equipment_class.is_del = ''0''
	),
	dialyzer AS (
	SELECT
		index_no AS code_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS dia_code,
		order_cd ->> ''name'' AS equi_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_key_tbl )
		AND master_physical_name = ''mst_dialyzer''
	),
	equipment AS (
	SELECT
		index_no AS code_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS equ_code,
		order_cd ->> ''name'' AS meq_class_code_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_key_tbl )
		AND master_physical_name = ''mst_equipment''
	),
	equipment_class AS (
	SELECT
		index_no AS code_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS equ_class_code,
		order_cd ->> ''name'' AS meq_class_code_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = ( SELECT facility_cd FROM ord_key_tbl )
		AND master_physical_name = ''mst_equipment_class''
	),
	ord_tbl AS (
	SELECT
		facility_cd,
		json_idx,
		to_date( treat_date, ''yyyymmdd'' ) AS treat_date,
		to_date( treat_date, ''yyyymmdd'' ) AS treat_date_start,
		info ->> ''class_cd'' AS class_cd,
		info ->> ''class_type'' AS class_type,
		info ->> ''equip_type'' AS equip_type,
		info ->> ''cd'' AS cd,
		info ->> ''amount'' AS amount,
		info ->> ''ind_user_id'' AS ind_user_id,
		info ->> ''ind_user_last_name'' AS ind_user_last_name,
		info ->> ''ind_user_first_name'' AS ind_user_first_name,
		info ->> ''upd_user_id'' AS upd_user_id,
		info ->> ''upd_user_last_name'' AS upd_user_last_name,
		info ->> ''upd_user_first_name'' AS upd_user_first_name,
		info ->> ''input_class'' AS input_class,
		info ->> ''is_editable'' AS is_editable,
		info ->> ''needle_type'' AS needle_type,
		info ->> ''cop_order_no'' AS cop_order_no,
		ord_no
	FROM
		ord_main
		CROSS JOIN LATERAL jsonb_array_elements ( ind_equip_info ) WITH ORDINALITY AS tmp ( info, json_idx )
	WHERE
		ord_no = @ordNo
		AND is_del = ''0''
	) SELECT
	1 AS dis_order,
	ord.*,
	NULL AS equip_class_cd,
	dia.model_number AS equip_name,
	dia.in_hospital_cd_1 AS equip_in_hospital_cd_1,
	dia.in_hospital_cd_2 AS equip_in_hospital_cd_2,
	dia.in_hospital_cd_3 AS equip_in_hospital_cd_3,
	dia.in_hospital_cd_4 AS equip_in_hospital_cd_4,
	NULL AS equip_unit,
	NULL AS equip_class_name,
	NULL AS equip_class_type,
	ord_no,
	diaz.code_order AS code_order,
	NULL AS class_order
FROM
	ord_tbl AS ord
	INNER JOIN dialyzer_tbl AS dia ON ord.cd = dia.dialyzer_cd :: TEXT
	AND equip_type = ''1''
	AND dia.dialyzer_cd IN ( @diaIds )
	LEFT JOIN dialyzer diaz ON dia.dialyzer_cd = diaz.dia_code UNION ALL
SELECT
	2 AS dis_order,
	ord.*,
	eqp.class_cd AS equip_class_cd,
	eqp.equipment_name AS equip_name,
	eqp.in_hospital_cd_1 AS equip_in_hospital_cd_1,
	eqp.in_hospital_cd_2 AS equip_in_hospital_cd_2,
	eqp.in_hospital_cd_3 AS equip_in_hospital_cd_3,
	eqp.in_hospital_cd_4 AS equip_in_hospital_cd_4,
	eqp.unit AS equip_unit,
	eqp_cls.class_name AS equip_class_name,
	eqp_cls.class_type AS equip_class_type,
	ord_no,
	eq.code_order AS code_order,
	eqc.code_order AS class_order
FROM
	ord_tbl AS ord
	INNER JOIN equipment_tbl AS eqp ON ord.cd = eqp.equipment_cd :: TEXT
	AND equip_type = ''0''
	AND eqp.class_cd IN ( @eqIds )
	LEFT JOIN equipment eq ON eq.equ_code = eqp.equipment_cd
	LEFT JOIN equipment_class_tbl eqp_cls ON eqp.class_cd = eqp_cls.class_cd
	LEFT JOIN equipment_class eqc ON eqp_cls.class_cd = eqc.equ_class_code', 2, '[{"preview": "2011/03/04", "can_calc": "0", "data_code": "treat_date", "data_name": "指示日", "data_type": "DateTime", "conv_table": [], "data_class": "医材", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト穿刺針", "can_calc": "0", "data_code": "equip_name", "data_name": "医療材料名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_name", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針", "can_calc": "0", "data_code": "equip_class_name", "data_name": "医療材料分類名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_class_name", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "医材", "field_name": "amount", "disp_format": "0", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "equip_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_unit", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "ind_user_id", "data_name": "指示者", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "ind_user_id", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "conv_sql": {"sql_cd": -2, "field_name": "user_name", "target_var": "@userId"}, "data_code": "upd_user_id", "data_name": "更新者", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "upd_user_id", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "A針", "can_calc": "0", "data_code": "needle_type", "data_name": "穿刺針区分", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "needle_type", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "equip_in_hospital_cd_1", "data_name": "医療材料連携コード１", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_in_hospital_cd_1", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "equip_in_hospital_cd_2", "data_name": "医療材料連携コード２", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_in_hospital_cd_2", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "equip_in_hospital_cd_3", "data_name": "医療材料連携コード３", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_in_hospital_cd_3", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "equip_in_hospital_cd_4", "data_name": "医療材料連携コード４", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_in_hospital_cd_4", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/05", "can_calc": "0", "data_code": "treat_date_start", "data_name": "指示開始日", "data_type": "DateTime", "conv_table": [], "data_class": "医材", "field_name": "treat_date_start", "disp_format": "yyyy/mm/dd", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/05", "can_calc": "0", "data_code": "treat_date_end", "data_name": "指示終了日", "data_type": "DateTime", "conv_table": [], "data_class": "医材", "field_name": "treat_date_end", "disp_format": "yyyy/mm/dd", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '指示：医材　@ordNo使用', '2020-03-27 12:59:00', CURRENT_TIMESTAMP, NULL);
