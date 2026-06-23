DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (74,97);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (74, 'WITH ord_tbl AS (
	SELECT
		facility_cd,
		to_date( treat_date, ''yyyymmdd'' ) AS treat_date,
		CAST(info ->> ''no'' AS INTEGER) AS no,
		info ->> ''class_cd'' AS class_cd,
		info ->> ''class_name'' AS class_name,
		info ->> ''class_type'' AS class_type,
		info ->> ''equip_type'' AS equip_type,
		info ->> ''cd'' AS cd,
		info ->> ''name'' AS name,
		info ->> ''short_name'' AS short_name,
		info ->> ''amount'' AS amount,
		info ->> ''unit'' AS unit,
		info ->> ''ind_user_id'' AS ind_user_id,
		info ->> ''ind_user_last_name'' AS ind_user_last_name,
		info ->> ''ind_user_first_name'' AS ind_user_first_name,
		info ->> ''upd_user_id'' AS upd_user_id,
		info ->> ''upd_user_last_name'' AS upd_user_last_name,
		info ->> ''upd_user_first_name'' AS upd_user_first_name,
		info ->> ''input_class'' AS input_class,
		info ->> ''is_editable'' AS is_editable,
		info ->> ''cop_order_no'' AS cop_order_no,
		ord_no,
		rst_dialysis_state
	FROM
		ord_main
		CROSS JOIN LATERAL jsonb_array_elements ( ind_equip_info ) WITH ORDINALITY AS tmp ( info )
	WHERE
		facility_cd = @facilityCd
	AND
		pat_id in ( @patIds )
	AND
		ord_no in ( @ordNos )
	AND
		is_del = ''0''
)
, dialyzer_tbl AS (
	SELECT
		*
	FROM
		mst_dialyzer
	WHERE
		mst_dialyzer.facility_cd = @facilityCd
		AND mst_dialyzer.is_disp = ''1''
		AND mst_dialyzer.is_del = ''0''
),
equipment_tbl AS (
	SELECT
		*
	FROM
		mst_equipment
	WHERE
		mst_equipment.facility_cd = @facilityCd
		AND mst_equipment.is_disp = ''1''
		AND mst_equipment.is_del = ''0''
),
equipment_class_tbl AS (
	SELECT
		*
	FROM
		mst_equipment_class
	WHERE
		mst_equipment_class.facility_cd = @facilityCd
		AND mst_equipment_class.is_disp = ''1''
		AND mst_equipment_class.is_del = ''0''
)
, selector_sort AS (
	SELECT
		index_no AS code_order,
		TO_NUMBER(info ->> ''code'', ''999999999999'') AS code,
		info ->> ''name'' AS name,
    master_physical_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements (order_settings -> ''items'') WITH ORDINALITY AS tmp (info, index_no)
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name in (''mst_equipment_class'', ''mst_equipment'', ''mst_dialyzer'')
)
, sort_fields AS (
  SELECT
		elem, ord
  FROM
		mst_facility_setting mfs,
		jsonb_array_elements_text(mfs.value::jsonb) WITH ORDINALITY t(elem, ord)
  WHERE
		facility_setting_no = ''3006''
    AND facility_cd = @facilityCd
)
, priority AS (
  SELECT sf.ord, mp.col
  FROM sort_fields sf
  JOIN (
    VALUES
      (''0'', ''reg_order''),
      (''1'', ''class_order''),
      (''2'', ''code_order'')
  ) AS mp(elem, col)
  ON mp.elem = sf.elem
)

SELECT * FROM (
	SELECT
		1 AS dis_order,
		ord.*,
		-10 AS class_cd,
		dia.model_number AS equip_name,
		NULL AS equipment_short_name,
		dia.in_hospital_cd_1 AS equip_in_hospital_cd_1,
		dia.in_hospital_cd_2 AS equip_in_hospital_cd_2,
		dia.in_hospital_cd_3 AS equip_in_hospital_cd_3,
		dia.in_hospital_cd_4 AS equip_in_hospital_cd_4,
		NULL AS equip_unit,
		concat(ind_user_last_name, ind_user_first_name) AS ind_user_name,
		concat(upd_user_last_name, upd_user_first_name) AS upd_user_name,
		''ダイアライザ'' AS equip_class_name,
		NULL AS equip_class_type,
		diaz.code_order AS code_order,
		NULL AS class_order
	FROM
		ord_tbl AS ord
		INNER JOIN dialyzer_tbl AS dia ON ord.cd = dia.dialyzer_cd :: TEXT
		AND equip_type = ''1''
		AND dia.dialyzer_cd IN ( @diaIds )
		LEFT JOIN selector_sort diaz ON dia.dialyzer_cd = diaz.code AND diaz.master_physical_name = ''mst_dialyzer''

	UNION ALL

	SELECT
		2 AS dis_order,
		ord.*,
		
		CASE
			WHEN rst_dialysis_state = ''0'' THEN eqp.class_cd
			ELSE ord.class_cd :: NUMERIC
		END AS class_cd,
		
		CASE
			WHEN rst_dialysis_state = ''0'' THEN eqp.equipment_name
			ELSE ord.name
		END AS equip_name,

		CASE
			WHEN rst_dialysis_state = ''0'' THEN eqp.equipment_short_name
			ELSE ord.short_name
		END AS equipment_short_name,

		eqp.in_hospital_cd_1 AS equip_in_hospital_cd_1,
		eqp.in_hospital_cd_2 AS equip_in_hospital_cd_2,
		eqp.in_hospital_cd_3 AS equip_in_hospital_cd_3,
		eqp.in_hospital_cd_4 AS equip_in_hospital_cd_4,
		
		CASE
			WHEN rst_dialysis_state = ''0'' THEN eqp.unit
			ELSE ord.unit
		END AS equip_unit,
		
		concat(ind_user_last_name, ind_user_first_name) AS ind_user_name,
		concat(upd_user_last_name, upd_user_first_name) AS upd_user_name,
		CASE WHEN ord.rst_dialysis_state = ''0'' THEN
			CASE WHEN eqp.class_cd = ''-1'' THEN ''未分類'' ELSE eqp_cls.class_name END 
		ELSE
			CASE WHEN ord.class_cd = ''-1'' THEN ''未分類'' ELSE ord.class_name END 
		END AS	equip_class_name,
		
		CASE
			WHEN rst_dialysis_state = ''0'' THEN eqp_cls.class_type
			ELSE ord.class_type :: NUMERIC
		END AS equip_class_type,
		
		eq.code_order AS code_order,
		eqc.code_order AS class_order
	FROM
		ord_tbl AS ord
		INNER JOIN equipment_tbl AS eqp ON ord.cd = eqp.equipment_cd :: TEXT
		AND equip_type = ''0''
		AND eqp.class_cd IN (@eqIds)
		LEFT JOIN equipment_class_tbl eqp_cls ON eqp.class_cd = eqp_cls.class_cd
		LEFT JOIN selector_sort eq ON eq.code = eqp.equipment_cd AND eq.master_physical_name = ''mst_equipment''
		LEFT JOIN selector_sort eqc ON eqp_cls.class_cd = eqc.code AND eqc.master_physical_name = ''mst_equipment_class''
)	tbl
ORDER BY (
  SELECT array_agg(
    CASE col
      WHEN ''reg_order''     THEN tbl.no
      WHEN ''class_order''   THEN tbl.class_order
      WHEN ''code_order''    THEN tbl.code_order
    END
    ORDER BY ord
  )
  FROM priority
)	
', 2, '[{"preview": "2011/03/04", "can_calc": "0", "data_code": "treat_date", "data_name": "指示日", "data_type": "DateTime", "conv_table": [], "data_class": "医材", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "filter_type": "EquipDia", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト穿刺針", "can_calc": "0", "data_code": "equip_name", "data_name": "医療材料名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_name", "disp_format": "", "filter_type": "EquipDia", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テ針", "can_calc": "0", "data_code": "equipment_short_name", "data_name": "省略医療材料名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equipment_short_name", "disp_format": "", "filter_type": "EquipDia", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針", "can_calc": "0", "data_code": "equip_class_name", "data_name": "医療材料分類名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_class_name", "disp_format": "", "filter_type": "EquipDia", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "医療材料", "can_calc": "0", "data_code": "equip_type", "data_name": "医療材料区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "医療材料", "item": "医療材料"}, {"code": "1", "disp": "ダイアライザ", "item": "ダイアライザ"}], "data_class": "医材", "field_name": "equip_type", "disp_format": "", "filter_type": "EquipDia", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "医材", "field_name": "amount", "disp_format": "0", "filter_type": "EquipDia", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "equip_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_unit", "disp_format": "", "filter_type": "EquipDia", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師", "can_calc": "0", "data_code": "ind_user_name", "data_name": "指示者", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "ind_user_name", "disp_format": "", "filter_type": "EquipDia", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "data_code": "upd_user_name", "data_name": "更新者", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "upd_user_name", "disp_format": "", "filter_type": "EquipDia", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "equip_in_hospital_cd_1", "data_name": "医療材料連携コード１", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_in_hospital_cd_1", "disp_format": "", "filter_type": "EquipDia", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "equip_in_hospital_cd_2", "data_name": "医療材料連携コード２", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_in_hospital_cd_2", "disp_format": "", "filter_type": "EquipDia", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "equip_in_hospital_cd_3", "data_name": "医療材料連携コード３", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_in_hospital_cd_3", "disp_format": "", "filter_type": "EquipDia", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "equip_in_hospital_cd_4", "data_name": "医療材料連携コード４", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_in_hospital_cd_4", "disp_format": "", "filter_type": "EquipDia", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '指示：医材 @patIds @facilityCd @ordNos @diaIds @eqIds', '2020-03-27 12:59:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (97, 'with ord_tbl as (
  select
    facility_cd,
    to_date(treat_date, ''yyyymmdd'') as treat_date,
		CAST(info ->> ''no'' AS INTEGER) AS no,
    info->>''class_cd'' as class_cd,
    info->>''class_type'' as class_type,
    info->>''equip_type'' as equip_type,
    info->>''cd'' as cd,
    info->>''amount'' as amount,

    info->>''ind_user_id'' as ind_user_id,
    info->>''ind_user_last_name'' as ind_user_last_name,
    info->>''ind_user_first_name'' as ind_user_first_name,
    info->>''upd_user_id'' as upd_user_id,
    info->>''upd_user_last_name'' as upd_user_last_name,
    info->>''upd_user_first_name'' as upd_user_first_name,
    info->>''input_class'' as input_class,
    info->>''is_editable'' as is_editable,
    info->>''cop_order_no'' as cop_order_no
		,info
    ,ord_no
  from
    ord_main
		CROSS JOIN LATERAL jsonb_array_elements ( rst_equip_info ) WITH ORDINALITY AS tmp ( info )
	WHERE
		facility_cd = @facilityCd
	AND
		pat_id in ( @patIds )
	AND
		ord_no in ( @ordNos )
	AND
		is_del = ''0''
	AND
		rst_dialysis_state <> ''0''
)
, dialyzer_tbl as (
  select
    *
  from
    mst_dialyzer
  where
    mst_dialyzer.facility_cd = @facilityCd
  and
    mst_dialyzer.is_disp = ''1''
  and
    mst_dialyzer.is_del = ''0''
)
, equipment_tbl as (
  select
    *
  from
    mst_equipment
  where
    mst_equipment.facility_cd = @facilityCd
  and
    mst_equipment.is_disp = ''1''
  and
    mst_equipment.is_del = ''0''
)
, equipment_class_tbl as (
  select
    *
  from
    mst_equipment_class
  where
    mst_equipment_class.facility_cd = @facilityCd
  and
    mst_equipment_class.is_disp = ''1''
  and
    mst_equipment_class.is_del = ''0''
)
, selector_sort AS (
	SELECT
		index_no AS code_order,
		TO_NUMBER(info ->> ''code'', ''999999999999'') AS code,
		info ->> ''name'' AS name,
    master_physical_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements (order_settings -> ''items'') WITH ORDINALITY AS tmp (info, index_no)
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name in (''mst_equipment_class'', ''mst_equipment'', ''mst_dialyzer'')
)
, sort_fields AS (
  SELECT
		elem, ord
  FROM
		mst_facility_setting mfs,
		jsonb_array_elements_text(mfs.value::jsonb) WITH ORDINALITY t(elem, ord)
  WHERE
		facility_setting_no = ''3006''
    AND facility_cd = @facilityCd
)
, priority AS (
  SELECT sf.ord, mp.col
  FROM sort_fields sf
  JOIN (
    VALUES
      (''0'', ''reg_order''),
      (''1'', ''class_order''),
      (''2'', ''code_order'')
  ) AS mp(elem, col)
  ON mp.elem = sf.elem
)

SELECT * FROM (
	select
		1 AS dis_order,
		ord.*,
		dia.model_number as equip_name,
		-10 AS class_cd,
		dia.in_hospital_cd_1 as rst_equip_in_hospital_cd_1,
		dia.in_hospital_cd_2 as rst_equip_in_hospital_cd_2,
		dia.in_hospital_cd_3 as rst_equip_in_hospital_cd_3,
		dia.in_hospital_cd_4 as rst_equip_in_hospital_cd_4,
		null as equip_unit,
		''ダイアライザ'' as equip_class_name,
		null as equip_class_type,
		diaz.code_order as code_order,
		null as class_order
	from
		ord_tbl as ord
		inner join dialyzer_tbl as dia on ord.cd = dia.dialyzer_cd::text
		LEFT JOIN selector_sort diaz ON dia.dialyzer_cd = diaz.code AND diaz.master_physical_name = ''mst_dialyzer''
	where
		equip_type = ''1''
		and dia.dialyzer_cd IN (@diaIds)
	
	UNION all
	
	select
		2 AS dis_order,
		ord.*,
		eqp.equipment_name as equip_name,
		eqp.class_cd AS class_cd,
		eqp.in_hospital_cd_1 as rst_equip_in_hospital_cd_1,
		eqp.in_hospital_cd_2 as rst_equip_in_hospital_cd_2,
		eqp.in_hospital_cd_3 as rst_equip_in_hospital_cd_3,
		eqp.in_hospital_cd_4 as rst_equip_in_hospital_cd_4,
		eqp.unit as equip_unit,
		case when  (info ->> ''class_cd''):: TEXT = ''-1'' then ''未分類'' else info ->> ''class_name'' end as equip_class_name,
		-- eqp_cls.class_name AS equip_class_name,
		eqp_cls.class_type as equip_class_type,
		eq.code_order as code_order,
		eqc.code_order as class_order
	from
		ord_tbl as ord
		inner join equipment_tbl as eqp on ord.cd = eqp.equipment_cd::text
		left join equipment_class_tbl eqp_cls on eqp.class_cd = eqp_cls.class_cd
		LEFT JOIN selector_sort eq ON eq.code = eqp.equipment_cd AND eq.master_physical_name = ''mst_equipment''
		LEFT JOIN selector_sort eqc ON eqp_cls.class_cd = eqc.code AND eqc.master_physical_name = ''mst_equipment_class''
		where
			equip_type <> ''1''
			and eqp.class_cd IN (@eqIds)
) tbl
ORDER BY (
  SELECT array_agg(
    CASE col
      WHEN ''reg_order''     THEN tbl.no
      WHEN ''class_order''   THEN tbl.class_order
      WHEN ''code_order''    THEN tbl.code_order
    END
    ORDER BY ord
  )
  FROM priority
)	
', 2, '[{"preview": "2011/3/12", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "医材", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "filter_type": "EquipDia", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト穿刺針", "can_calc": "0", "data_code": "equip_name", "data_name": "医療材料名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_name", "disp_format": "", "filter_type": "EquipDia", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針", "can_calc": "0", "data_code": "equip_class_name", "data_name": "医療材料分類名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_class_name", "disp_format": "", "filter_type": "EquipDia", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "医材", "field_name": "amount", "disp_format": "0", "filter_type": "EquipDia", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "equip_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_unit", "disp_format": "", "filter_type": "EquipDia", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_1", "data_name": "医療材料連携コード１", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_1", "disp_format": "", "filter_type": "EquipDia", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_2", "data_name": "医療材料連携コード２", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_2", "disp_format": "", "filter_type": "EquipDia", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_3", "data_name": "医療材料連携コード３", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_3", "disp_format": "", "filter_type": "EquipDia", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_4", "data_name": "医療材料連携コード４", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_4", "disp_format": "", "filter_type": "EquipDia", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：医材 @patIds @facilityCd @ordNos @diaIds @eqIds', '2020-03-31 23:59:59', CURRENT_TIMESTAMP, NULL);
