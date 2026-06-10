DELETE FROM "ntss"."sys_data_set" where sql_cd in (74, 97, 4, 8, 190, 188, 261, 326, 141, 149, 230);
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
		-1 AS equip_class_cd,
		dia.model_number AS equip_name,
		NULL AS equipment_short_name,
		dia.in_hospital_cd_1 AS equip_in_hospital_cd_1,
		dia.in_hospital_cd_2 AS equip_in_hospital_cd_2,
		dia.in_hospital_cd_3 AS equip_in_hospital_cd_3,
		dia.in_hospital_cd_4 AS equip_in_hospital_cd_4,
		NULL AS equip_unit,
		concat(ind_user_last_name, ind_user_first_name) AS ind_user_name,
		concat(upd_user_last_name, upd_user_first_name) AS upd_user_name,
		NULL AS equip_class_name,
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
		END AS equip_class_cd,
		
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
', 2, '[{"preview": "2011/03/04", "can_calc": "0", "data_code": "treat_date", "data_name": "指示日", "data_type": "DateTime", "conv_table": [], "data_class": "医材", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト穿刺針", "can_calc": "0", "data_code": "equip_name", "data_name": "医療材料名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_name", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テ針", "can_calc": "0", "data_code": "equipment_short_name", "data_name": "省略医療材料名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equipment_short_name", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針", "can_calc": "0", "data_code": "equip_class_name", "data_name": "医療材料分類名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_class_name", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "医療材料", "can_calc": "0", "data_code": "equip_type", "data_name": "医療材料区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "医療材料", "item": "医療材料"}, {"code": "1", "disp": "ダイアライザ", "item": "ダイアライザ"}], "data_class": "医材", "field_name": "equip_type", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "医材", "field_name": "amount", "disp_format": "0", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "equip_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_unit", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師", "can_calc": "0", "data_code": "ind_user_name", "data_name": "指示者", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "ind_user_name", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "data_code": "upd_user_name", "data_name": "更新者", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "upd_user_name", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "equip_in_hospital_cd_1", "data_name": "医療材料連携コード１", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_in_hospital_cd_1", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "equip_in_hospital_cd_2", "data_name": "医療材料連携コード２", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_in_hospital_cd_2", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "equip_in_hospital_cd_3", "data_name": "医療材料連携コード３", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_in_hospital_cd_3", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "equip_in_hospital_cd_4", "data_name": "医療材料連携コード４", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_in_hospital_cd_4", "disp_format": "", "filter_type": "Equip", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '指示：医材 @patIds @facilityCd @ordNos @diaIds @eqIds', '2020-03-27 12:59:00', CURRENT_TIMESTAMP, NULL);
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
		-1 AS equip_class_cd,
		dia.in_hospital_cd_1 as rst_equip_in_hospital_cd_1,
		dia.in_hospital_cd_2 as rst_equip_in_hospital_cd_2,
		dia.in_hospital_cd_3 as rst_equip_in_hospital_cd_3,
		dia.in_hospital_cd_4 as rst_equip_in_hospital_cd_4,
		null as equip_unit,
		null as equip_class_name,
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
		eqp.class_cd AS equip_class_cd,
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
', 2, '[{"preview": "2011/3/12", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "医材", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト穿刺針", "can_calc": "0", "data_code": "equip_name", "data_name": "医療材料名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_name", "disp_format": "", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針", "can_calc": "0", "data_code": "equip_class_name", "data_name": "医療材料分類名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_class_name", "disp_format": "", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "医材", "field_name": "amount", "disp_format": "0", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "equip_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_unit", "disp_format": "", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_1", "data_name": "医療材料連携コード１", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_1", "disp_format": "", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_2", "data_name": "医療材料連携コード２", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_2", "disp_format": "", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_3", "data_name": "医療材料連携コード３", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_3", "disp_format": "", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_4", "data_name": "医療材料連携コード４", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_4", "disp_format": "", "filter_type": "Equip", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：医材 @patIds @facilityCd @ordNos @diaIds @eqIds', '2020-03-31 23:59:59', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (4, 'WITH ord_tbl AS (
	SELECT
			ord_no
		, facility_cd
		, treat_date
		, treat_week
		, rst_dialysis_state
		, ind_medi_info
	FROM
		ord_main
	WHERE
		facility_cd = @facilityCd
	AND
		pat_id in ( @patIds )
	AND
		ord_no in ( @ordNos )
	AND
		is_del = ''0''
	ORDER BY treat_date
)
, med_info AS (
	SELECT
		ord_no
		, facility_cd
		, treat_date
		, treat_week
		, rst_dialysis_state
		, CAST(info ->> ''no'' AS INTEGER) as no
		, CAST(info ->> ''medicine_type'' AS INTEGER) as medicine_type
		, CAST(info ->> ''class_cd'' AS INTEGER) AS class_cd
		, info ->> ''class_name'' AS class_name
		, CAST(info ->> ''class_type'' AS INTEGER) AS class_type
		, info ->> ''cd'' as cd
		, info ->> ''name'' AS medicine_name
		, info ->> ''short_name'' AS medicine_short_name
		, info ->> ''amount'' AS amount
		, info ->> ''unit'' AS unit
		, to_date(info ->> ''init_date'', ''yyyymmdd'') as init_date
		, info ->> ''timing_cd'' as timing_cd
		, info ->> ''timing_name'' AS timing_name
		, info ->> ''procedure_cd'' as procedure_cd
		, info ->> ''procedure_name'' AS procedure_name
		, (info ->> ''date_interval'')::NUMERIC as date_interval
		, info ->> ''comment'' as comment
		, info ->> ''ind_user_id'' as ind_user_id
		, info ->> ''upd_user_id'' as upd_user_id
		, info ->> ''ind_user_last_name'' as ind_user_last_name
		, info ->> ''upd_user_last_name'' as upd_user_last_name
		, info ->> ''ind_user_first_name'' as ind_user_first_name
		, info ->> ''upd_user_first_name'' as upd_user_first_name
	FROM
		ord_tbl ord
	CROSS JOIN LATERAL jsonb_array_elements (ind_medi_info) WITH ORDINALITY AS tmp (info)
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
		AND master_physical_name in (''mst_medicine'', ''mst_medicine_mix'', ''mst_medicine_class'', ''mst_medicate_timing'', ''mst_procedure'')
)
, med_tbl AS (
		SELECT
			ord.ord_no
      , ord.facility_cd
      , ord.treat_date
      , ord.treat_week
      , ord.rst_dialysis_state
			, ord.init_date
			, ord.no
			, ord.medicine_type
			, CASE
				WHEN rst_dialysis_state = ''0'' THEN
					CASE
						WHEN medicine_type = 2 THEN mix.class_cd
						ELSE med.class_cd
					END
				ELSE ord.class_cd
			END AS class_cd
			, CASE WHEN rst_dialysis_state = ''0'' THEN
				CASE WHEN mix.class_cd = -1 THEN ''未分類'' ELSE med_cls.class_name END 
			ELSE
				CASE WHEN ord.class_cd = -1 THEN ''未分類'' ELSE ord.class_name END 
			END AS class_name
			, CASE
				WHEN rst_dialysis_state = ''0'' THEN med_cls.class_type
				ELSE ord.class_type
			END AS class_type
			
      , CASE
          WHEN medicine_type = 1 THEN ord.cd
          ELSE null
        END AS medicine_cd
      , CASE
          WHEN medicine_type = 2 THEN ord.cd
          ELSE null
        END AS medicine_mix_cd  
			, CASE
				WHEN rst_dialysis_state = ''0'' THEN
					CASE
						WHEN medicine_type = 2 THEN mix.medicine_mix_name
						ELSE med.medicine_name
					END
				ELSE ord.medicine_name
			END AS medicine_name,
			CASE
				WHEN rst_dialysis_state = ''0'' THEN
					CASE
						WHEN medicine_type = 2 THEN mix.medicine_mix_short_name
						ELSE med.medicine_short_name
					END
				ELSE ord.medicine_short_name
			END AS medicine_short_name,
			ord.amount,
			CASE
				WHEN rst_dialysis_state = ''0'' THEN
					CASE
						WHEN medicine_type = 2 THEN mix.unit
						ELSE med.unit
					END
				ELSE ord.unit
			END AS medicine_unit,
			ord.comment, 
			
			ord.timing_cd,
			CASE
				WHEN rst_dialysis_state = ''0'' THEN tim.medicate_timing_name
				ELSE ord.timing_name
			END AS medicate_timing_name,
			
			ord.procedure_cd,
			CASE
				WHEN rst_dialysis_state = ''0'' THEN pro.pricedure_name
				ELSE ord.procedure_name
			END AS pricedure_name
			
			, ord.date_interval
			
			, ord.ind_user_id
			, ord.ind_user_last_name
			, ord.upd_user_last_name
			, concat(ord.ind_user_last_name, ord.ind_user_first_name) AS ind_user_name
			, ord.upd_user_id
			, ord.ind_user_first_name
			, ord.upd_user_first_name
			, concat(ord.upd_user_last_name, ord.upd_user_first_name) AS upd_user_name
			
			,case when  ord.medicine_type = 1 then med.in_hospital_cd_1 else mix.in_hospital_cd_1 end as medi_in_hospital_cd_1
			,case when  ord.medicine_type = 1 then med.in_hospital_cd_2 else mix.in_hospital_cd_2 end as medi_in_hospital_cd_2
			,case when  ord.medicine_type = 1 then med.in_hospital_cd_3 else mix.in_hospital_cd_3 end as medi_in_hospital_cd_3
			,case when  ord.medicine_type = 1 then med.in_hospital_cd_4 else '''' end as medi_in_hospital_cd_4
			,CASE
				WHEN pro.in_hosp_a_startdate <= ord.treat_date :: TIMESTAMP
				 AND (pro.in_hosp_b_startdate IS NULL OR ord.treat_date :: TIMESTAMP < pro.in_hosp_b_startdate)
				THEN pro.in_hospital_cd_a1
				WHEN pro.in_hosp_b_startdate <= ord.treat_date :: TIMESTAMP THEN pro.in_hospital_cd_b1
				ELSE ''''
			END AS procedure_in_hospital_cd_1
			,CASE
				WHEN pro.in_hosp_a_startdate <= ord.treat_date :: TIMESTAMP
				 AND (pro.in_hosp_b_startdate IS NULL OR ord.treat_date :: TIMESTAMP < pro.in_hosp_b_startdate)
				THEN pro.in_hospital_cd_a2
				WHEN pro.in_hosp_b_startdate <= ord.treat_date :: TIMESTAMP THEN pro.in_hospital_cd_b2
				ELSE ''''
			END AS procedure_in_hospital_cd_2
			,save.receipt_value
			,save.receipt_unit
		from
			med_info as ord
			left join mst_medicine as med on (ord.cd = med.medicine_cd :: text and med.is_del = ''0'' and med.is_disp = ''1'' and med.facility_cd = ord.facility_cd and ord.medicine_type = 1)
			left join mst_medicine_mix as mix on (ord.cd = mix.medicine_mix_cd :: text and mix.is_del = ''0'' and mix.is_disp = ''1'' and mix.facility_cd = ord.facility_cd and ord.medicine_type = 2)
			LEFT JOIN mst_medicine_class as med_cls on (rst_dialysis_state = ''0'' AND med.class_cd = med_cls.class_cd and ord.medicine_type = 1) OR (rst_dialysis_state = ''0'' AND mix.class_cd = med_cls.class_cd and ord.medicine_type = 2) 
			left join mst_medicate_timing as tim on (ord.timing_cd = tim.medicate_timing_cd::text)
			left join mst_procedure as pro on (ord.procedure_cd = pro.procedure_cd::text)
			left join ord_material_save as save on (save.supplies_base_no = ord.ord_no and ord.facility_cd = save.facility_cd and ord.cd = save.supplies_cd and save.supplies_source_class = ''1'' and save.ind_rst_class =''1'' and supplies_class != ''20'')
			and save.medicine_no ->>''no'' = ord.no::TEXT
)
, med_order_tbl AS (
	SELECT
		m.*
		, dmed_cls.code_order AS class_order
		, dmed.code_order as code_order
		, dmed_mix.code_order as code_mix_order
		, dtim.code_order as timing_order
		, dpro.code_order as proc_order
	FROM
		med_tbl m
	LEFT JOIN selector_sort as dmed_cls on dmed_cls.code = m.class_cd AND dmed_cls.master_physical_name = ''mst_medicine_class''
	LEFT JOIN selector_sort as dmed on dmed.code = CAST(m.medicine_cd AS INTEGER) AND dmed.master_physical_name = ''mst_medicine''
	LEFT JOIN selector_sort as dmed_mix on dmed_mix.code = CAST(m.medicine_mix_cd AS INTEGER) AND dmed_mix.master_physical_name = ''mst_medicine_mix''
	LEFT JOIN selector_sort as dtim on dtim.code = CAST(m.timing_cd AS INTEGER) AND dtim.master_physical_name = ''mst_medicate_timing''
	LEFT JOIN selector_sort as dpro on dpro.code = CAST(m.procedure_cd AS INTEGER) AND dpro.master_physical_name = ''mst_procedure''
	WHERE
		m.class_cd IN (@medIds)
)
, sort_fields AS (
  SELECT
		elem, ord
  FROM
		mst_facility_setting mfs,
		jsonb_array_elements_text(mfs.value::jsonb) WITH ORDINALITY t(elem, ord)
  WHERE
		facility_setting_no = ''3007''
    AND facility_cd = @facilityCd
)
, priority AS (
  SELECT sf.ord, mp.col
  FROM sort_fields sf
  JOIN (
    VALUES
      (''0'', ''reg_order''),
      (''1'', ''class_order''),
      (''2'', ''medicine_type''),
      (''3'', ''code_order''),
      (''4'', ''timing_order''),
      (''5'', ''proc_order''),
      (''6'', ''date_interval'')
  ) AS mp(elem, col)
  ON mp.elem = sf.elem
)
	
SELECT * FROM med_order_tbl tbl
ORDER BY (
  SELECT array_agg(
    CASE col
      WHEN ''reg_order''     THEN ARRAY[tbl.no,							 NULL]
      WHEN ''class_order''   THEN ARRAY[tbl.class_order,     NULL]
      WHEN ''medicine_type'' THEN ARRAY[tbl.medicine_type,   NULL]
      WHEN ''code_order''    THEN ARRAY[tbl.code_order,      tbl.code_mix_order]
      WHEN ''timing_order''  THEN ARRAY[tbl.timing_order,    NULL]
      WHEN ''proc_order''    THEN ARRAY[tbl.proc_order,      NULL]
      WHEN ''date_interval'' THEN ARRAY[tbl.date_interval,   NULL]
    END
    ORDER BY ord
  )
  FROM priority
)
', 2, '[{"preview": "1", "can_calc": "0", "data_code": "medi_class_cd", "data_name": "薬剤分類コード", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "class_cd", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "未分類", "can_calc": "0", "data_code": "medi_class_type", "data_name": "分類区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "未分類", "item": "未分類"}, {"code": "1", "disp": "抗凝固剤", "item": "抗凝固剤"}, {"code": "2", "disp": "透析液", "item": "透析液"}, {"code": "3", "disp": "補液", "item": "補液"}], "data_class": "投薬", "field_name": "class_type", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "medi_cd", "data_name": "薬剤(調整薬剤)コード", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "cd", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/04", "can_calc": "0", "data_code": "treat_date", "data_name": "治療日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/07", "can_calc": "0", "data_code": "init_date", "data_name": "指示開始日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬", "field_name": "init_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト薬剤１", "can_calc": "0", "data_code": "medi_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medicine_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テ薬１", "can_calc": "0", "data_code": "medicine_short_name", "data_name": "省略薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medicine_short_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "項目未分類", "can_calc": "0", "data_code": "class_name", "data_name": "薬剤分類名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "class_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_1", "data_name": "薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_2", "data_name": "薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_3", "data_name": "薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_in_hospital_cd_3", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_4", "data_name": "薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_in_hospital_cd_4", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "medi_amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "amount", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "medicine_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medicine_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "receipt_value", "data_name": "数量(レセ)", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "receipt_value", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "receipt_unit", "data_name": "単位(レセ)", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "receipt_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "静脈側回路内注射", "can_calc": "0", "data_code": "pricedure_name", "data_name": "手技", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "pricedure_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "procedure_in_hospital_cd_1", "data_name": "手技連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "procedure_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "procedure_in_hospital_cd_2", "data_name": "手技連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "procedure_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "medicate_timing_name", "data_name": "投与時間帯", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medicate_timing_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "予定薬剤です。", "can_calc": "0", "data_code": "comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "comment", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師", "can_calc": "0", "data_code": "ind_user_name", "data_name": "指示者", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "ind_user_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "data_code": "upd_user_name", "data_name": "更新者", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "upd_user_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "毎回", "can_calc": "0", "data_code": "date_interval", "data_name": "投与間隔", "data_type": "string", "conv_table": [{"code": "0", "disp": "毎回", "item": "毎回"}, {"code": "1", "disp": "毎週", "item": "毎週"}, {"code": "2", "disp": "1回/2週", "item": "1回/2週"}, {"code": "3", "disp": "1回/3週", "item": "1回/3週"}, {"code": "4", "disp": "1回/4週", "item": "1回/4週"}, {"code": "5", "disp": "1回/月：第1曜日", "item": "1回/月：第1曜日"}, {"code": "6", "disp": "1回/月：第2曜日", "item": "1回/月：第2曜日"}, {"code": "7", "disp": "1回/月：第3曜日", "item": "1回/月：第3曜日"}, {"code": "8", "disp": "1回/月：第4曜日", "item": "1回/月：第4曜日"}, {"code": "9", "disp": "1回/月：最終曜日", "item": "1回/月：最終曜日"}, {"code": "10", "disp": "1回/月：最終治療日", "item": "1回/月：最終治療日"}], "data_class": "投薬", "field_name": "date_interval", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '指示：投薬 @patIds @facilityCd @ordNos @medIds', '2021-08-11 09:43:41', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (8, 'WITH ord_tbl AS (
	SELECT
		ord_no
		, facility_cd
		, treat_date
		, rst_medi_info
	FROM
			ord_main
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
, med_info AS (
	SELECT
		ord_no
		, facility_cd
		, treat_date
		, to_date(info ->> ''init_date'', ''yyyymmdd'') as init_date
		, CAST(info ->> ''no'' AS INTEGER) as no
		, CAST(info ->> ''medicine_type'' AS INTEGER) AS medicine_type
		, CAST(info ->> ''class_cd'' AS INTEGER) AS class_cd
		, info ->> ''class_name'' AS class_name
		, info ->> ''class_type'' AS class_type
		, info ->> ''cd'' AS cd
		, info ->> ''name'' AS medicine_name
		, info ->> ''short_name'' as short_name
		, info ->> ''amount'' AS amount
		, info ->> ''unit'' AS unit
		, info ->> ''comment'' as comment
		, info ->> ''timing_cd'' as timing_cd
		, info ->> ''timing_name'' as medi_timing_name
		, info ->> ''procedure_cd'' as procedure_cd
		, info ->> ''procedure_name'' as procedure_name
		, CAST(info ->> ''date_interval'' AS INTEGER) as date_interval
		, info ->> ''effect_flg'' as effect_flg
		, info ->> ''effect_date'' as effect_date
		, info ->> ''effect_user_id'' as effect_user_id
		, info ->> ''effect_user_first_name'' as effect_user_first_name
		, info ->> ''effect_user_last_name'' as effect_user_last_name
	FROM
		ord_tbl
	CROSS JOIN LATERAL jsonb_array_elements (rst_medi_info) WITH ORDINALITY AS tmp (info)
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
		AND master_physical_name in (''mst_medicine'', ''mst_medicine_mix'', ''mst_medicine_class'', ''mst_medicate_timing'', ''mst_procedure'')
)
, med_tbl AS (
	SELECT
		ord.ord_no,
		ord.facility_cd, 
		ord.treat_date,
		ord.no,
		ord.medicine_type as medicine_type,
		ord.class_cd as medi_class_cd,
		case when ord.class_cd = -1 then ''未分類'' else ord.class_name end as medi_class_name,
		ord.class_type as medi_class_type,
		
		ord.cd as medi_cd,
		ord.medicine_name as medi_name,
		ord.short_name,
		ord.amount as medi_amount,
		ord.unit as medi_unit,
		ord.comment as comment,
		case when  ord.medicine_type = 1 then mstMedic.in_hospital_cd_1 else mstMedicMix.in_hospital_cd_1 end as rst_medi_in_hospital_cd_1,
		case when  ord.medicine_type = 1 then mstMedic.in_hospital_cd_2 else mstMedicMix.in_hospital_cd_2 end as rst_medi_in_hospital_cd_2,
		case when  ord.medicine_type = 1 then mstMedic.in_hospital_cd_3 else mstMedicMix.in_hospital_cd_3 end as rst_medi_in_hospital_cd_3,
		case when  ord.medicine_type = 1 then mstMedic.in_hospital_cd_4 else '''' end as rst_medi_in_hospital_cd_4,
		
		ord.medi_timing_name,
		
		ord.procedure_name,
		CASE
				WHEN pro.in_hosp_a_startdate <= ord.treat_date :: TIMESTAMP
				 AND (pro.in_hosp_b_startdate IS NULL OR ord.treat_date :: TIMESTAMP < pro.in_hosp_b_startdate)
				THEN pro.in_hospital_cd_a1
				WHEN pro.in_hosp_b_startdate <= ord.treat_date :: TIMESTAMP THEN pro.in_hospital_cd_b1
				ELSE ''''
			END AS rst_procedure_in_hospital_cd_1,
		CASE
			WHEN pro.in_hosp_a_startdate <= ord.treat_date :: TIMESTAMP
			 AND (pro.in_hosp_b_startdate IS NULL OR ord.treat_date :: TIMESTAMP < pro.in_hosp_b_startdate)
			THEN pro.in_hospital_cd_a2
			WHEN pro.in_hosp_b_startdate <= ord.treat_date :: TIMESTAMP THEN pro.in_hospital_cd_b2
			ELSE ''''
		END AS rst_procedure_in_hospital_cd_2,
		
		ord.date_interval,

		ord.effect_flg,
		CASE WHEN ord.effect_date <> ''null'' THEN
			to_timestamp( substring(ord.effect_date::text from 0 for 11) || '' '' || substring(ord.effect_date::text from 12 for 12),''YYYY-MM-DD HH24:MI:SS.MS'')
		END as effect_date,
		ord.effect_user_id,
		COALESCE(ord.effect_user_last_name::text, '''') || '' '' || COALESCE(ord.effect_user_first_name::text, '''') as effect_user_name
	 
  ,save.receipt_value as receipt_value
  ,mstMedic.unit_second as unit_second
	
	,dmed_cls.code_order as class_order
  ,dmed.code_order as code_order
  ,dmed_mix.code_order as code_mix_order
  ,dtim.code_order as timing_order
  ,dpro.code_order as proc_order
  from
    med_info ord
    left join mst_medicine as mstMedic on (ord.cd = mstMedic.medicine_cd :: text and mstMedic.is_del = ''0'' and mstMedic.is_disp = ''1'' and mstMedic.facility_cd = ord.facility_cd and ord.medicine_type = 1)
		left join mst_medicine_mix as mstMedicMix on (ord.cd = mstMedicMix.medicine_mix_cd :: text and mstMedicMix.is_del = ''0'' and mstMedicMix.is_disp = ''1'' and mstMedicMix.facility_cd = ord.facility_cd and ord.medicine_type = 2)
		left join mst_medicate_timing as tim on (ord.timing_cd = tim.medicate_timing_cd::text)
		left join mst_procedure as pro on (ord.procedure_cd = pro.procedure_cd :: text and pro.is_del = ''0'' and pro.is_disp = ''1''  )
    left join ord_material_save as save on (save.supplies_base_no = ord.ord_no and ord.facility_cd = save.facility_cd and mstMedic.medicine_cd :: text  = save.supplies_cd and save.supplies_source_class = ''1'' and save.ind_rst_class =''2'' and supplies_class != ''20'')
    and save.medicine_no ->>''no'' = ord.no::TEXT
		LEFT JOIN selector_sort as dmed_cls on dmed_cls.code = ord.class_cd AND dmed_cls.master_physical_name = ''mst_medicine_class''
		LEFT JOIN selector_sort as dmed on dmed.code = mstMedic.medicine_cd AND dmed.master_physical_name = ''mst_medicine''
		LEFT JOIN selector_sort as dmed_mix on dmed_mix.code = mstMedicMix.medicine_mix_cd AND dmed_mix.master_physical_name = ''mst_medicine_mix''
		LEFT JOIN selector_sort as dtim on dtim.code = tim.medicate_timing_cd AND dtim.master_physical_name = ''mst_medicate_timing''
		LEFT JOIN selector_sort as dpro on dpro.code = pro.procedure_cd AND dpro.master_physical_name = ''mst_procedure''
		where ord.class_cd IN ( @medIds )
)
, sort_fields AS (
  SELECT
		elem, ord
  FROM
		mst_facility_setting mfs,
		jsonb_array_elements_text(mfs.value::jsonb) WITH ORDINALITY t(elem, ord)
  WHERE
		facility_setting_no = ''3007''
    AND facility_cd = @facilityCd
)
, priority AS (
  SELECT sf.ord, mp.col
  FROM sort_fields sf
  JOIN (
    VALUES
      (''0'', ''reg_order''),
      (''1'', ''class_order''),
      (''2'', ''medicine_type''),
      (''3'', ''code_order''),
      (''4'', ''timing_order''),
      (''5'', ''proc_order''),
      (''6'', ''date_interval'')
  ) AS mp(elem, col)
  ON mp.elem = sf.elem
)
SELECT * FROM med_tbl tbl
ORDER BY (
  SELECT array_agg(
    CASE col
      WHEN ''reg_order''     THEN ARRAY[tbl.no,        			 NULL]
      WHEN ''class_order''   THEN ARRAY[tbl.class_order,     NULL]
      WHEN ''medicine_type'' THEN ARRAY[tbl.medicine_type,   NULL]
      WHEN ''code_order''    THEN ARRAY[tbl.code_order,      tbl.code_mix_order]
      WHEN ''timing_order''  THEN ARRAY[tbl.timing_order,    NULL]
      WHEN ''proc_order''    THEN ARRAY[tbl.proc_order,      NULL]
      WHEN ''date_interval'' THEN ARRAY[tbl.date_interval,   NULL]
    END
    ORDER BY ord
  )
  FROM priority
)
', 2, '[{"preview": "2011/3/12", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト薬剤１", "can_calc": "0", "data_code": "medi_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析液", "can_calc": "0", "data_code": "medi_class_name", "data_name": "薬剤分類名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_class_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_medi_in_hospital_cd_1", "data_name": "薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "rst_medi_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_medi_in_hospital_cd_2", "data_name": "薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "rst_medi_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_medi_in_hospital_cd_3", "data_name": "薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "rst_medi_in_hospital_cd_3", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_medi_in_hospital_cd_4", "data_name": "薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "rst_medi_in_hospital_cd_4", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "medi_amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "medi_amount", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "medi_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "receipt_value", "data_name": "数量(レセ)", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "receipt_value", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "袋", "can_calc": "0", "data_code": "unit_second", "data_name": "単位(レセ)", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "unit_second", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "静脈側回路内注射", "can_calc": "0", "data_code": "procedure_name", "data_name": "手技", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "procedure_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_procedure_in_hospital_cd_1", "data_name": "手技連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "rst_procedure_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_procedure_in_hospital_cd_2", "data_name": "手技連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "rst_procedure_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "medi_timing_name", "data_name": "投与時間帯", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "medi_timing_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "予定薬剤です。", "can_calc": "0", "data_code": "comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "comment", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "effect_date", "data_name": "実施時刻", "data_type": "DateTime", "conv_table": [], "data_class": "投薬", "field_name": "effect_date", "disp_format": "yyyy/mm/dd hh:mm", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "effect_user_id", "data_name": "実施者ID", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "effect_user_id", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "data_code": "effect_user_name", "data_name": "実施者名", "data_type": "string", "conv_table": [], "data_class": "投薬", "field_name": "effect_user_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "effect_flg", "data_name": "実施マーク", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未使用"}, {"code": "1", "disp": "■", "item": "実施済"}], "data_class": "投薬", "field_name": "effect_flg", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "medi_cd", "data_name": "薬剤コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "medi_cd", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "medi_class_cd", "data_name": "薬剤分類コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬", "field_name": "medi_class_cd", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：投薬 @patIds @facilityCd @ordNos @medIds', '2019-09-17 11:32:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (190, 'WITH ord_tbl AS (
	SELECT
			ord_no
		, facility_cd
		, treat_date
		, treat_week
		, rst_dialysis_state
		, ind_medi_info
	FROM
		 ord_main
	WHERE
		facility_cd = @facilityCd
	AND
		pat_id in ( @patIds )
	AND
		ord_no in ( @ordNos )
	AND
		is_del = ''0''
)
, med_info AS (
	SELECT
		ord_no
		, facility_cd
		, treat_date
		, treat_week
		, rst_dialysis_state
		, to_date(info ->> ''init_date'', ''yyyymmdd'') as init_date
		, CAST(info ->> ''no'' AS INTEGER) as no
		, CAST(info ->> ''medicine_type'' AS INTEGER) as medicine_type
		, CAST(info ->> ''class_cd'' AS INTEGER) as class_cd
		, info ->> ''class_name'' as class_name
		, CAST(info ->> ''class_type'' AS INTEGER) as class_type
		, info ->> ''cd'' as cd
		, info ->> ''name'' as medicine_name
		, info ->> ''short_name'' as medicine_short_name
		, CAST(info ->> ''amount'' AS NUMERIC) as amount
		, info ->> ''unit'' AS unit
		, info ->> ''comment'' as comment
		, info ->> ''timing_cd'' as timing_cd
		, info ->> ''timing_name'' as timing_name
		, info ->> ''procedure_cd'' as procedure_cd
		, info ->> ''procedure_name'' as procedure_name
		, CAST(info ->> ''date_interval'' AS INTEGER) as date_interval
		, info ->> ''ind_user_id'' as ind_user_id
		, info ->> ''upd_user_id'' as upd_user_id
		, info ->> ''ind_user_first_name'' as ind_user_first_name
		, info ->> ''ind_user_last_name'' as ind_user_last_name
		, info ->> ''upd_user_first_name'' as upd_user_first_name
		, info ->> ''upd_user_last_name'' as upd_user_last_name
	FROM
			ord_tbl
	CROSS JOIN LATERAL jsonb_array_elements (ind_medi_info) WITH ORDINALITY AS tmp (info)
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
		AND master_physical_name in (''mst_medicine'', ''mst_medicine_class'', ''mst_medicate_timing'', ''mst_procedure'')
)
, medicine_mix_tbl as (
	select
		 mix.*
		, medimix ->> ''cd'' as medi_cd
		, medimix ->> ''amount'' as amount
		, medimix ->> ''solvent'' as solvent
	from
		mst_medicine_mix mix
		CROSS JOIN LATERAL jsonb_array_elements(mix_info) WITH ORDINALITY AS tmp(medimix, json_idx)
	where
		mix.facility_cd  = @facilityCd
	and
		mix.is_disp = ''1''
	and
		mix.is_del = ''0''
)
, med_tbl AS (
	select
		ord_no
		, ord.facility_cd
		, ord.treat_date
		, ord.treat_date as dial_treat_date
		, ord.no
		, ord.medicine_type
		, CASE
			WHEN rst_dialysis_state = ''0'' THEN med.class_cd
			ELSE ord.class_cd
		 END AS class_cd
		, CASE WHEN ord.rst_dialysis_state = ''0'' THEN
					CASE WHEN med.class_cd = -1 THEN ''未分類'' ELSE med_cls.class_name END 
		 ELSE			
					CASE WHEN ord.class_cd = -1 THEN ''未分類'' ELSE ord.class_name END
		 END as class_name		
		, CASE
			WHEN rst_dialysis_state = ''0'' THEN med_cls.class_type
			ELSE ord.class_type
		 END AS class_type
		 
		, ord.cd
		, CASE
			WHEN rst_dialysis_state = ''0'' THEN med.medicine_name
			ELSE ord.medicine_name
		END AS medicine_name
		, CASE
			WHEN rst_dialysis_state = ''0'' THEN med.medicine_short_name
			ELSE ord.medicine_short_name
		 END AS medicine_short_name
		, CASE
			WHEN rst_dialysis_state = ''0'' THEN med.unit
			ELSE ord.unit
		 END AS medicine_unit
		, ord.amount
		
		, ord.timing_cd
		, CASE
			WHEN rst_dialysis_state = ''0'' THEN tim.medicate_timing_name
			ELSE ord.timing_name
		 END AS medicate_timing_name

		, ord.procedure_cd
		, CASE
			WHEN rst_dialysis_state = ''0'' THEN pro.pricedure_name
			ELSE ord.procedure_name
		 END AS procedure_name

		, ord.init_date
		, ord.date_interval
		, ord.comment
		, ord.ind_user_id
		, ord.upd_user_id
		, concat(ord.ind_user_last_name, ord.ind_user_first_name) AS ind_user_name
		, concat(ord.upd_user_last_name, ord.upd_user_first_name) AS upd_user_name
		, med.in_hospital_cd_1 as medi_in_hospital_cd_1
		, med.in_hospital_cd_2 as medi_in_hospital_cd_2
		, med.in_hospital_cd_3 as medi_in_hospital_cd_3
		, med.in_hospital_cd_4 as medi_in_hospital_cd_4

		,CASE
			WHEN pro.in_hosp_a_startdate <= ord.treat_date :: TIMESTAMP
			 AND (pro.in_hosp_b_startdate IS NULL OR ord.treat_date :: TIMESTAMP < pro.in_hosp_b_startdate)
			THEN pro.in_hospital_cd_a1
			WHEN pro.in_hosp_b_startdate <= ord.treat_date :: TIMESTAMP THEN pro.in_hospital_cd_b1
			ELSE ''''
		END AS procedure_in_hospital_cd_1
		,CASE
			WHEN pro.in_hosp_a_startdate <= ord.treat_date :: TIMESTAMP
			 AND (pro.in_hosp_b_startdate IS NULL OR ord.treat_date :: TIMESTAMP < pro.in_hosp_b_startdate)
			THEN pro.in_hospital_cd_a2
			WHEN pro.in_hosp_b_startdate <= ord.treat_date :: TIMESTAMP THEN pro.in_hospital_cd_b2
			ELSE ''''
		END AS procedure_in_hospital_cd_2,
		save.receipt_value,
		save.receipt_unit
from
  med_info as ord
  inner join mst_medicine as med on ord.cd = med.medicine_cd::text AND ord.facility_cd = med.facility_cd AND med.is_del = ''0'' AND med.is_disp = ''1''
  left join mst_medicine_class as med_cls on med.class_cd = med_cls.class_cd AND ord.facility_cd = med_cls.facility_cd AND med_cls.is_del = ''0'' AND med_cls.is_disp = ''1'' 
  left join mst_medicate_timing as tim on ord.timing_cd = tim.medicate_timing_cd::text AND ord.facility_cd = tim.facility_cd AND tim.is_del = ''0'' AND tim.is_disp = ''1'' 
  left join mst_procedure as pro on ord.procedure_cd = pro.procedure_cd::text AND ord.facility_cd = pro.facility_cd AND pro.is_del = ''0'' AND pro.is_disp = ''1''
	left join ord_material_save as save on (save.supplies_base_no = ord.ord_no and ord.facility_cd = save.facility_cd and ord.cd  = save.supplies_cd and save.supplies_source_class = ''1'' 
  and save.ind_rst_class =''1'' and (save.supplies_class = ''12'' or save.supplies_class = ''20'') and save.medicine_no ->>''no'' = ord.no::TEXT)
where
	ord.medicine_type = 1

union all

select
     ord_no
   , ord.facility_cd
   , ord.treat_date
   , ord.treat_date as dial_treat_date
	 , ord.no
	 , 1 as medicine_type
	 , med.class_cd as class_cd
   , CASE
      WHEN med.class_cd = -1 THEN ''未分類''
      ELSE med_cls.class_name
     END as class_name
   , CASE
      WHEN med.class_cd = -1 THEN 0
      ELSE med_cls.class_type
     END as class_type
		 
   , mixtemp.medi_cd  :: text  as cd
   , med.medicine_name
   , med.medicine_short_name
   , med.unit as medicine_unit
   , CASE
      WHEN mixtemp.solvent = ''1'' THEN mixtemp.amount :: NUMERIC
      ELSE ord.amount * mixtemp.amount :: NUMERIC
    END AS amount

		, ord.timing_cd
		, CASE
      WHEN rst_dialysis_state = ''0'' THEN tim.medicate_timing_name
      ELSE ord.timing_name
     END AS medicate_timing_name

		, ord.procedure_cd
		, CASE
      WHEN rst_dialysis_state = ''0'' THEN pro.pricedure_name
      ELSE ord.procedure_name
     END AS procedure_name

   , ord.init_date
   , ord.date_interval
   , ord.comment
   , ord.ind_user_id
   , ord.upd_user_id
   , concat(ord.ind_user_last_name, ord.ind_user_first_name) AS ind_user_name
   , concat(ord.upd_user_last_name, ord.upd_user_first_name) AS upd_user_name
   , med.in_hospital_cd_1 as medi_in_hospital_cd_1
   , med.in_hospital_cd_2 as medi_in_hospital_cd_2
   , med.in_hospital_cd_3 as medi_in_hospital_cd_3
   , med.in_hospital_cd_4 as medi_in_hospital_cd_4
	 ,CASE
			WHEN pro.in_hosp_a_startdate <= ord.treat_date :: TIMESTAMP
			 AND (pro.in_hosp_b_startdate IS NULL OR ord.treat_date :: TIMESTAMP < pro.in_hosp_b_startdate)
			THEN pro.in_hospital_cd_a1
			WHEN pro.in_hosp_b_startdate <= ord.treat_date :: TIMESTAMP THEN pro.in_hospital_cd_b1
			ELSE ''''
		END AS procedure_in_hospital_cd_1
		,CASE
			WHEN pro.in_hosp_a_startdate <= ord.treat_date :: TIMESTAMP
			 AND (pro.in_hosp_b_startdate IS NULL OR ord.treat_date :: TIMESTAMP < pro.in_hosp_b_startdate)
			THEN pro.in_hospital_cd_a2
			WHEN pro.in_hosp_b_startdate <= ord.treat_date :: TIMESTAMP THEN pro.in_hospital_cd_b2
			ELSE ''''
		END AS procedure_in_hospital_cd_2,
		save.receipt_value,
		save.receipt_unit
from
  med_info as ord
  inner join  medicine_mix_tbl  mixtemp on (mixtemp.medicine_mix_cd :: text= ord.cd)
  left join mst_medicine as med on  med.medicine_cd::text = mixtemp.medi_cd AND ord.facility_cd = med.facility_cd AND med.is_del = ''0'' AND med.is_disp = ''1''
	left join mst_medicine_class as med_cls on med.class_cd = med_cls.class_cd AND ord.facility_cd = med_cls.facility_cd AND med_cls.is_del = ''0'' AND med_cls.is_disp = ''1'' 
	left join mst_medicate_timing as tim on ord.timing_cd = tim.medicate_timing_cd::text AND ord.facility_cd = tim.facility_cd AND tim.is_del = ''0'' AND tim.is_disp = ''1''
	left join mst_procedure as pro on ord.procedure_cd = pro.procedure_cd::text AND ord.facility_cd = pro.facility_cd AND pro.is_del = ''0'' AND pro.is_disp = ''1''
	left join ord_material_save as save on (save.supplies_base_no = ord.ord_no and ord.facility_cd = save.facility_cd and ord.cd  = save.supplies_cd and save.supplies_source_class = ''1'' 
  and save.ind_rst_class =''1'' and (save.supplies_class = ''12'' or save.supplies_class = ''20'') and save.medicine_no ->>''no'' = ord.no::TEXT)
where
	ord.medicine_type = 2
)
, med_order_tbl AS (
	select
		m.*,
		dmed_cls.code_order AS class_order,
		dmed.code_order AS code_order,
		0 AS code_mix_order,
		dtim.code_order as timing_order,
		dpro.code_order as proc_order
	from
		med_tbl m
  LEFT JOIN selector_sort AS dmed_cls ON dmed_cls.code = m.class_cd AND dmed_cls.master_physical_name = ''mst_medicine_class''
  LEFT JOIN selector_sort AS dmed ON dmed.code :: text = m.cd AND dmed.master_physical_name = ''mst_medicine''
  LEFT JOIN selector_sort AS dtim ON dtim.code :: text = m.timing_cd AND dtim.master_physical_name = ''mst_medicate_timing''
  LEFT JOIN selector_sort AS dpro ON dpro.code :: text = m.procedure_cd AND dpro.master_physical_name = ''mst_procedure''
	WHERE
		m.class_cd IN ( @medIds )
)
, sort_fields AS (
  SELECT
		elem, ord
  FROM
		mst_facility_setting mfs,
		jsonb_array_elements_text(mfs.value::jsonb) WITH ORDINALITY t(elem, ord)
  WHERE
		facility_setting_no = ''3007''
    AND facility_cd = @facilityCd
)
, priority AS (
  SELECT sf.ord, mp.col
  FROM sort_fields sf
  JOIN (
    VALUES
      (''0'', ''reg_order''),
      (''1'', ''class_order''),
      (''2'', ''medicine_type''),
      (''3'', ''code_order''),
      (''4'', ''timing_order''),
      (''5'', ''proc_order''),
      (''6'', ''date_interval'')
  ) AS mp(elem, col)
  ON mp.elem = sf.elem
)
	
SELECT * FROM med_order_tbl tbl
ORDER BY (
  SELECT array_agg(
    CASE col
      WHEN ''reg_order''     THEN ARRAY[tbl.no,        			 NULL]
      WHEN ''class_order''   THEN ARRAY[tbl.class_order,     NULL]
      WHEN ''medicine_type'' THEN ARRAY[tbl.medicine_type,   NULL]
      WHEN ''code_order''    THEN ARRAY[tbl.code_order,      tbl.code_mix_order]
      WHEN ''timing_order''  THEN ARRAY[tbl.timing_order,    NULL]
      WHEN ''proc_order''    THEN ARRAY[tbl.proc_order,      NULL]
      WHEN ''date_interval'' THEN ARRAY[tbl.date_interval,   NULL]
    END
    ORDER BY ord
  )
  FROM priority
)
', 2, '[{"preview": "1", "can_calc": "0", "data_code": "dial_medi_class_cd", "data_name": "薬剤分類コード", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "class_cd", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dial_medi_class_type", "data_name": "分類区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "未分類", "item": "未分類"}, {"code": "1", "disp": "抗凝固剤", "item": "抗凝固剤"}, {"code": "2", "disp": "透析液", "item": "透析液"}, {"code": "3", "disp": "補液", "item": "補液"}], "data_class": "投薬(分解)", "field_name": "class_type", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dial_medi_cd", "data_name": "薬剤(調整薬剤)コード", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "cd", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/04", "can_calc": "0", "data_code": "dial_treat_date", "data_name": "治療日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬(分解)", "field_name": "dial_treat_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/07", "can_calc": "0", "data_code": "dial_init_date", "data_name": "指示開始日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬(分解)", "field_name": "init_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト薬剤１", "can_calc": "0", "data_code": "dial_medi_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "medicine_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テ薬１", "can_calc": "0", "data_code": "dial_medi_short_name", "data_name": "省略薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "medicine_short_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "項目未分類", "can_calc": "0", "data_code": "dial_class_name", "data_name": "薬剤分類名", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "class_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_medi_in_hospital_cd_1", "data_name": "薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "medi_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_medi_in_hospital_cd_2", "data_name": "薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "medi_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_medi_in_hospital_cd_3", "data_name": "薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "medi_in_hospital_cd_3", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_medi_in_hospital_cd_4", "data_name": "薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "medi_in_hospital_cd_4", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "dial_medi_amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "投薬(分解)", "field_name": "amount", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "dial_medicine_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "medicine_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "receipt_value", "data_name": "数量(レセ)", "data_type": "decimal", "conv_table": [], "data_class": "投薬(分解)", "field_name": "receipt_value", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "receipt_unit", "data_name": "単位(レセ)", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "receipt_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "静脈側回路内注射", "can_calc": "0", "data_code": "dial_procedure_name", "data_name": "手技", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "procedure_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_procedure_in_hospital_cd_1", "data_name": "手技連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "procedure_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dial_procedure_in_hospital_cd_2", "data_name": "手技連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "procedure_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "dial_medicate_timing_name", "data_name": "投与時間帯", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "medicate_timing_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "予定薬剤です。", "can_calc": "0", "data_code": "dial_comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "comment", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師", "can_calc": "0", "data_code": "dial_ind_user_name", "data_name": "指示者", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "ind_user_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "data_code": "dial_upd_user_name", "data_name": "更新者", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "upd_user_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "毎回", "can_calc": "0", "data_code": "dial_date_interval", "data_name": "投与間隔", "data_type": "string", "conv_table": [{"code": "0", "disp": "毎回", "item": "毎回"}, {"code": "1", "disp": "毎週", "item": "毎週"}, {"code": "2", "disp": "1回/2週", "item": "1回/2週"}, {"code": "3", "disp": "1回/3週", "item": "1回/3週"}, {"code": "4", "disp": "1回/4週", "item": "1回/4週"}, {"code": "5", "disp": "1回/月：第1曜日", "item": "1回/月：第1曜日"}, {"code": "6", "disp": "1回/月：第2曜日", "item": "1回/月：第2曜日"}, {"code": "7", "disp": "1回/月：第3曜日", "item": "1回/月：第3曜日"}, {"code": "8", "disp": "1回/月：第4曜日", "item": "1回/月：第4曜日"}, {"code": "9", "disp": "1回/月：最終曜日", "item": "1回/月：最終曜日"}, {"code": "10", "disp": "1回/月：最終治療日", "item": "1回/月：最終治療日"}], "data_class": "投薬(分解)", "field_name": "date_interval", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '指示：投薬(分解) @patIds @facilityCd @ordNos @medIds', '2021-10-08 09:47:36', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (188, 'WITH ord_tbl AS (
	SELECT
			ord_no
		, facility_cd
		, treat_date
		, rst_medi_info
	FROM
		 ord_main
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
, med_info AS (
	SELECT
		ord_no
		, facility_cd
		, treat_date
		, to_date(info ->> ''init_date'', ''yyyymmdd'') as init_date
		, CAST(info ->> ''no'' AS INTEGER) as no
		, CAST(info ->> ''medicine_type'' AS INTEGER) as medicine_type
		, CAST(info ->> ''class_cd'' AS INTEGER) as class_cd
		, info ->> ''class_name'' as class_name
		, CAST(info ->> ''class_type'' AS INTEGER) as class_type
		, info ->> ''cd'' as cd
		, info ->> ''name'' as medicine_name
		, info ->> ''short_name'' as medicine_short_name
		, CAST(info ->> ''amount'' AS NUMERIC) as amount
		, info ->> ''unit'' AS unit
		, info ->> ''comment'' as comment
		, info ->> ''timing_cd'' as timing_cd
		, info ->> ''timing_name'' as timing_name
		, info ->> ''procedure_cd'' as procedure_cd
		, info ->> ''procedure_name'' as procedure_name
		, CAST(info ->> ''date_interval'' AS INTEGER) as date_interval
		, info ->> ''effect_flg'' as effect_flg
		, info ->> ''effect_date'' as effect_date
		, info ->> ''effect_user_id'' as effect_user_id
		, info ->> ''effect_user_first_name'' as effect_user_first_name
		, info ->> ''effect_user_last_name'' as effect_user_last_name
	FROM
			ord_tbl
	CROSS JOIN LATERAL jsonb_array_elements (rst_medi_info) WITH ORDINALITY AS tmp (info)
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
		AND master_physical_name in (''mst_medicine'', ''mst_medicine_class'', ''mst_medicate_timing'', ''mst_procedure'')
)
, medicine_mix_temp AS (
	select
		mix.facility_cd
		, mix.medicine_mix_cd
		, medimix ->> ''cd'' as medi_cd
		, medimix ->> ''amount'' as amount
	from
		mst_medicine_mix mix
	CROSS JOIN LATERAL jsonb_array_elements(mix_info) WITH ORDINALITY AS tmp(medimix, json_idx)
	where
		mix.facility_cd  = @facilityCd
	and mix.is_del = ''0''
	and mix.is_disp = ''1''
)
, med_tbl AS (
	select
		ord_no,
		ord.facility_cd,
		treat_date,
		ord.no,
		ord.medicine_type,
		ord.class_cd as medi_class_cd,
		CASE WHEN ord.class_cd = -1 THEN ''未分類'' ELSE ord.class_name END as medi_class_name,
		ord.class_type as medi_class_type,
		
		ord.cd as medi_cd,
		ord.medicine_name as medi_name,
		ord.medicine_short_name as short_name,
		ord.unit as medi_unit,
		ord.amount as medi_amount,

		ord.effect_flg,
		CASE WHEN ord.effect_date <> ''null'' THEN
		to_timestamp( substring(ord.effect_date::text from 0 for 11) || '' '' || substring(ord.effect_date::text from 12 for 12),''YYYY-MM-DD HH24:MI:SS.MS'')
		END as effect_date,
		ord.effect_user_id as effect_user_id,
		COALESCE(ord.effect_user_last_name::text, '''') || '' '' || COALESCE(ord.effect_user_first_name::text, '''') as effect_user_name,
		
		ord.timing_cd,
		ord.timing_name as medi_timing_name,
		
		ord.procedure_cd,
		ord.procedure_name,
		
		ord.date_interval,
		
		ord.comment as comment
		,mstMedic.in_hospital_cd_1 as rst_medi_in_hospital_cd_1
		,mstMedic.in_hospital_cd_2 as rst_medi_in_hospital_cd_2
		,mstMedic.in_hospital_cd_3 as rst_medi_in_hospital_cd_3
		,mstMedic.in_hospital_cd_4 as rst_medi_in_hospital_cd_4
		,CASE
				WHEN pro.in_hosp_a_startdate <= ord.treat_date :: TIMESTAMP
				 AND (pro.in_hosp_b_startdate IS NULL OR ord.treat_date :: TIMESTAMP < pro.in_hosp_b_startdate)
				THEN pro.in_hospital_cd_a1
				WHEN pro.in_hosp_b_startdate <= ord.treat_date :: TIMESTAMP THEN pro.in_hospital_cd_b1
				ELSE ''''
			END AS rst_procedure_in_hospital_cd_1
		,CASE
			WHEN pro.in_hosp_a_startdate <= ord.treat_date :: TIMESTAMP
			 AND (pro.in_hosp_b_startdate IS NULL OR ord.treat_date :: TIMESTAMP < pro.in_hosp_b_startdate)
			THEN pro.in_hospital_cd_a2
			WHEN pro.in_hosp_b_startdate <= ord.treat_date :: TIMESTAMP THEN pro.in_hospital_cd_b2
			ELSE ''''
		END AS rst_procedure_in_hospital_cd_2
		,save.receipt_value
		,save.receipt_unit
	from
		med_info ord
	inner join mst_medicine as  mstMedic  on (ord.cd = mstMedic.medicine_cd::text and mstMedic.is_del = ''0'' and mstMedic.is_disp = ''1'' and mstMedic.facility_cd = ord.facility_cd )
	left join mst_procedure as pro on (ord.procedure_cd = pro.procedure_cd :: text and pro.is_del = ''0'' and pro.is_disp = ''1''  and pro.facility_cd = ord.facility_cd)
	left join ord_material_save as save on (save.supplies_base_no = ord.ord_no and ord.facility_cd = save.facility_cd and ord.cd :: text = save.supplies_cd and save.supplies_source_class = ''1'' and save.ind_rst_class =''2'' and save.supplies_class != ''20'')
	and save.medicine_no ->>''no'' = ord.no::TEXT
	where
		ord.medicine_type = 1
	union all
	SELECT
		ord_no,
		facility_cd,
		treat_date,
		no,
		medicine_type,
		medi_class_cd,
		medi_class_name,
		medi_class_type,
		medi_cd,
		medi_name,
		short_name,
		medi_unit,
		medi_amount,
		effect_flg,
		effect_date,
		effect_user_id,
		effect_user_name,
		timing_cd,
		medi_timing_name,
		procedure_cd,
		procedure_name,
		date_interval,
		comment
		,rst_medi_in_hospital_cd_1
		,rst_medi_in_hospital_cd_2
		,rst_medi_in_hospital_cd_3
		,rst_medi_in_hospital_cd_4
		,rst_procedure_in_hospital_cd_1
		,rst_procedure_in_hospital_cd_2
		,receipt_value
		,receipt_unit
	FROM (
		select
			ROW_NUMBER() OVER (PARTITION BY ord_no,ord.cd,ord.no,mixtemp.medi_cd) AS rn,
			ord_no,
			ord.facility_cd,
			ord.treat_date,
			ord.no,
			1 AS medicine_type,
			mstMedic.class_cd as medi_class_cd,
			CASE WHEN mstMedic.class_cd = -1 THEN ''未分類'' ELSE classtemp.class_name END as medi_class_name,
			CASE WHEN mstMedic.class_cd = -1 THEN 0 ELSE classtemp.class_type END as medi_class_type,
			
			mixtemp.medi_cd  :: text  as medi_cd,
			mstMedic.medicine_name as medi_name,
			mstMedic.medicine_short_name as short_name,
			mstMedic.unit  as medi_unit,
			ord.amount *  mixtemp.amount :: NUMERIC as medi_amount,
			
			ord.effect_flg,
			CASE WHEN ord.effect_date <> ''null'' THEN
			to_timestamp( substring(ord.effect_date::text from 0 for 11) || '' '' || substring(ord.effect_date::text from 12 for 12),''YYYY-MM-DD HH24:MI:SS.MS'')
			END as effect_date,
			ord.effect_user_id as effect_user_id,
			(ord.effect_user_last_name::text) || '' '' || (ord.effect_user_first_name::text) as effect_user_name,
			
			ord.timing_cd,
			ord.timing_name as medi_timing_name,
			
			ord.procedure_cd,
			ord.procedure_name,
			
			ord.date_interval,
			
			ord.comment
			,mstMedic.in_hospital_cd_1 as rst_medi_in_hospital_cd_1
			,mstMedic.in_hospital_cd_2 as rst_medi_in_hospital_cd_2
			,mstMedic.in_hospital_cd_3 as rst_medi_in_hospital_cd_3
			,mstMedic.in_hospital_cd_4 as rst_medi_in_hospital_cd_4
			,case when  abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',mstP.in_hosp_a_startdate )) ::text,''days'',''''),''99999'')) < abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',mstP.in_hosp_b_startdate)) ::text,''days'',''''),''99999''))
			then  mstP.in_hospital_cd_a1 else mstP.in_hospital_cd_b1 end as rst_procedure_in_hospital_cd_1
			,case when  abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',mstP.in_hosp_a_startdate )) ::text,''days'',''''),''99999'')) < abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',mstP.in_hosp_b_startdate)) ::text,''days'',''''),''99999''))
			then  mstP.in_hospital_cd_a2 else mstP.in_hospital_cd_b2 end as rst_procedure_in_hospital_cd_2
			,save.receipt_value
			,save.receipt_unit
		from
			med_info ord
		inner join  medicine_mix_temp  mixtemp on (mixtemp.medicine_mix_cd :: text= ord.cd )
		left join mst_medicine as  mstMedic  on (mstMedic.medicine_cd :: text = mixtemp.medi_cd and mstMedic.is_del = ''0'' and mstMedic.is_disp = ''1'' and mstMedic.facility_cd = ord.facility_cd )
		left join  mst_medicine_class  classtemp on (classtemp.class_cd :: text = mstMedic.class_cd :: text  and classtemp.facility_cd = mstMedic.facility_cd )
		left join mst_procedure as mstP on (ord.procedure_cd = mstP.procedure_cd :: text and mstP.is_del = ''0'' and mstP.is_disp = ''1''  and mstP.facility_cd = ord.facility_cd)
		left join ord_material_save as save on (save.supplies_base_no = ord.ord_no and ord.facility_cd = save.facility_cd and mixtemp.medi_cd :: text = save.supplies_cd and save.supplies_source_class = ''1'' and save.ind_rst_class =''2'' and save.supplies_class = ''20'' )
		where
			ord.medicine_type = 2
	) med_sp WHERE med_sp.rn = 1
)
, med_order_tbl AS (
	select
		m.*,
		dmed_cls.code_order AS class_order,
		dmed.code_order AS code_order,
		0 AS code_mix_order,
		dtim.code_order as timing_order,
		dpro.code_order as proc_order
	from
		med_tbl m
  LEFT JOIN selector_sort AS dmed_cls ON dmed_cls.code = m.medi_class_cd AND dmed_cls.master_physical_name = ''mst_medicine_class''
  LEFT JOIN selector_sort AS dmed ON dmed.code :: text = m.medi_cd AND dmed.master_physical_name = ''mst_medicine''
  LEFT JOIN selector_sort AS dtim ON dtim.code :: text = m.timing_cd AND dtim.master_physical_name = ''mst_medicate_timing''
  LEFT JOIN selector_sort AS dpro ON dpro.code :: text = m.procedure_cd AND dpro.master_physical_name = ''mst_procedure''
	WHERE
		m.medi_class_cd in (@medIds)
)
, sort_fields AS (
  SELECT
		elem, ord
  FROM
		mst_facility_setting mfs,
		jsonb_array_elements_text(mfs.value::jsonb) WITH ORDINALITY t(elem, ord)
  WHERE
		facility_setting_no = ''3007''
    AND facility_cd = @facilityCd
)
, priority AS (
  SELECT sf.ord, mp.col
  FROM sort_fields sf
  JOIN (
    VALUES
      (''0'', ''reg_order''),
      (''1'', ''class_order''),
      (''2'', ''medicine_type''),
      (''3'', ''code_order''),
      (''4'', ''timing_order''),
      (''5'', ''proc_order''),
      (''6'', ''date_interval'')
  ) AS mp(elem, col)
  ON mp.elem = sf.elem
)
	
SELECT * FROM med_order_tbl tbl
ORDER BY (
  SELECT array_agg(
    CASE col
      WHEN ''reg_order''     THEN ARRAY[tbl.no,        			 NULL]
      WHEN ''class_order''   THEN ARRAY[tbl.class_order,     NULL]
      WHEN ''medicine_type'' THEN ARRAY[tbl.medicine_type,   NULL]
      WHEN ''code_order''    THEN ARRAY[tbl.code_order,      tbl.code_mix_order]
      WHEN ''timing_order''  THEN ARRAY[tbl.timing_order,    NULL]
      WHEN ''proc_order''    THEN ARRAY[tbl.proc_order,      NULL]
      WHEN ''date_interval'' THEN ARRAY[tbl.date_interval,   NULL]
    END
    ORDER BY ord
  )
  FROM priority
)
', 2, '[{"preview": "テスト薬剤１", "can_calc": "0", "data_code": "dia_medi_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "medi_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析液", "can_calc": "0", "data_code": "dia_medi_class_name", "data_name": "薬剤分類名", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "medi_class_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dia_rst_medi_in_hospital_cd_1", "data_name": "薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "rst_medi_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dia_rst_medi_in_hospital_cd_2", "data_name": "薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "rst_medi_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dia_rst_medi_in_hospital_cd_3", "data_name": "薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "rst_medi_in_hospital_cd_3", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dia_rst_medi_in_hospital_cd_4", "data_name": "薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "rst_medi_in_hospital_cd_4", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "dia_medi_amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "投薬(分解)", "field_name": "medi_amount", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "dia_medi_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "medi_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "receipt_value", "data_name": "数量(レセ)", "data_type": "decimal", "conv_table": [], "data_class": "投薬(分解)", "field_name": "receipt_value", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "receipt_unit", "data_name": "単位(レセ)", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "receipt_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "静脈側回路内注射", "can_calc": "0", "data_code": "dia_procedure_name", "data_name": "手技", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "procedure_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dia_rst_procedure_in_hospital_cd_1", "data_name": "手技連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "rst_procedure_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "dia_rst_procedure_in_hospital_cd_2", "data_name": "手技連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "rst_procedure_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "dia_medi_timing_name", "data_name": "投与時間帯", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "medi_timing_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "予定薬剤です。", "can_calc": "0", "data_code": "dia_comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "comment", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/18 08:00", "can_calc": "0", "data_code": "dia_effect_date", "data_name": "実施時刻", "data_type": "DateTime", "conv_table": [], "data_class": "投薬(分解)", "field_name": "effect_date", "disp_format": "yyyy/mm/dd hh:mm", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "dia_effect_user_id", "data_name": "実施者ID", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "effect_user_id", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "data_code": "dia_effect_user_name", "data_name": "実施者名", "data_type": "string", "conv_table": [], "data_class": "投薬(分解)", "field_name": "effect_user_name", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "■", "can_calc": "0", "data_code": "dia_effect_flg", "data_name": "実施マーク", "data_type": "string", "conv_table": [{"code": "0", "disp": "□", "item": "未使用"}, {"code": "1", "disp": "■", "item": "実施済"}], "data_class": "投薬(分解)", "field_name": "effect_flg", "disp_format": "", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dia_medi_cd", "data_name": "薬剤コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬(分解)", "field_name": "medi_cd", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "dia_medi_class_cd", "data_name": "薬剤分類コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬(分解)", "field_name": "medi_class_cd", "disp_format": "0", "filter_type": "Medicine", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：投薬(分解) @patIds @facilityCd @ordNos @medIds', '2021-10-08 09:47:36', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (261, 'WITH pat_treat_patt AS (
  SELECT
    pat_id,
    ind_treatment_cd,
    ind_kur_cd,
    treat_week,
    CAST(info->>''cd'' AS INTEGER) AS cd,
    CAST(info->>''no'' AS INTEGER) AS no,
    CAST(info->>''medicine_type'' AS INTEGER) AS medicine_type,
    CAST(info->>''init_date'' AS TIMESTAMP) AS init_date,
    CAST(info->>''timing_cd'' AS INTEGER) AS timing_cd,
    CAST(info->>''amount'' AS DECIMAL) AS amount,
    CAST(info->>''procedure_cd'' AS INTEGER) AS procedure_cd,
		info->>''comment'' AS comment,
		CAST(info->>''date_interval'' AS INTEGER) AS date_interval,
    CONCAT(info->>''ind_user_last_name'', info->>''ind_user_first_name'') AS ind_user_name,
    CONCAT(info->>''upd_user_last_name'', info->>''upd_user_first_name'') AS upd_user_name
  FROM
    pat_treatment_pattern,
    LATERAL jsonb_array_elements(ind_medi_info) AS info
  WHERE
    facility_cd = @facilityCd
    AND pat_id in ( @patIds )
    AND CAST(info->>''init_date'' AS TIMESTAMP) <= @toDate
)
, pat_treat_patt_ext AS (
	SELECT
		ptp.*,
		CASE
			WHEN medicine_type = ''2'' THEN mix.medicine_mix_name
			ELSE mm.medicine_name
		END AS medicine_name,
		CASE
			WHEN medicine_type = ''2'' THEN mix.class_cd
			ELSE mm.class_cd
		END AS class_cd,
		CASE
			WHEN medicine_type = ''2'' THEN
				CASE WHEN mix.class_cd = ''-1'' THEN ''未分類''
				ELSE mix_cls.class_name END
			ELSE
				CASE WHEN mm.class_cd = ''-1'' THEN ''未分類''
				ELSE med_cls.class_name END 
		END AS class_name,
		CASE
			WHEN medicine_type = ''2'' THEN mix_cls.class_type
			ELSE med_cls.class_type
		END AS class_type,
		CASE WHEN medicine_type = ''1'' THEN mm.in_hospital_cd_1 ELSE mix.in_hospital_cd_1 END AS medi_in_hospital_cd_1,
		CASE WHEN medicine_type = ''1'' THEN mm.in_hospital_cd_2 ELSE mix.in_hospital_cd_2 END AS medi_in_hospital_cd_2,
		CASE WHEN medicine_type = ''1'' THEN mm.in_hospital_cd_3 ELSE mix.in_hospital_cd_3 END AS medi_in_hospital_cd_3,
		CASE WHEN medicine_type = ''1'' THEN mm.in_hospital_cd_4 ELSE '''' END AS medi_in_hospital_cd_4,
		CASE
			WHEN medicine_type = ''2'' THEN mix.unit
			ELSE mm.unit
		END AS unit,
    mp.pricedure_name,
    mp.in_hosp_a_startdate,
    mp.in_hospital_cd_a1,
    mp.in_hospital_cd_a2,
    mp.in_hosp_b_startdate,
    mp.in_hospital_cd_b1,
    mp.in_hospital_cd_b2,
    mmt.medicate_timing_name,
    CASE
      WHEN is_exchange IS NOT NULL THEN
        CASE
          WHEN is_exchange = ''0'' THEN
            CASE
              WHEN unit_converted_amount <> 0
               AND unit_converted_amount_second <> 0
              THEN ROUND(ptp.amount / unit_converted_amount * unit_converted_amount_second, unit_decimal_point_second)
              ELSE 0
            END

          WHEN is_exchange = ''1'' THEN
            CASE
              WHEN unit_converted_amount <> 0
               AND unit_converted_amount_second <> 0
              THEN ROUND(CEIL(ptp.amount / unit_converted_amount) * unit_converted_amount_second, unit_decimal_point_second)
              ELSE 0
            END

          WHEN is_exchange = ''2'' THEN
            COALESCE(unit_converted_amount_second, 0)
          ELSE 0
        END
        
      ELSE NULL
    END AS receipt_value,
    mm.unit_second
  FROM
    pat_treat_patt ptp
    LEFT JOIN mst_medicine mm
           ON mm.medicine_cd = ptp.cd AND ptp.medicine_type = 1
    LEFT JOIN mst_medicine_mix mix
           ON mix.medicine_mix_cd = ptp.cd AND ptp.medicine_type = 2
    LEFT JOIN mst_medicine_class med_cls 
           ON mm.class_cd = med_cls.class_cd
    LEFT JOIN mst_medicine_class mix_cls 
           ON mix.class_cd = mix_cls.class_cd
    LEFT JOIN mst_procedure mp
           ON mp.procedure_cd = ptp.procedure_cd
    LEFT JOIN mst_medicate_timing mmt
           ON mmt.medicate_timing_cd = ptp.timing_cd
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
		AND master_physical_name in (''mst_medicine_class'', ''mst_medicine'', ''mst_medicine_mix'', ''mst_medicate_timing'', ''mst_procedure'')
)
, ord_mai AS (
	SELECT
		ord_no,
		pat_id,
		om.treat_date,
		ind_treatment_cd,
		ind_kur_cd,
		treat_week
	FROM
    ord_main om
	WHERE
		facility_cd = @facilityCd
    AND pat_id IN ( @patIds )
		AND ord_no IN ( @ordNos )
)
, pat_treat_patt_last AS (
	SELECT
		om.ord_no,
		om.treat_date,
		ptpe.no,
		mcs.code_order AS class_order,
		ptpe.medicine_type,
		ms.code_order,
		mms.code_order AS code_mix_order,
		mts.code_order AS timing_order,
		p.code_order AS proc_order,
		ptpe.date_interval,
		ptpe.pat_id,
		ptpe.ind_treatment_cd,
		ptpe.ind_kur_cd,
		ptpe.treat_week,
		ptpe.cd,
		ptpe.class_cd,
		ptpe.class_type,
		ptpe.init_date,
		ptpe.medicine_name,    
		ptpe.class_name,  
		ptpe.medi_in_hospital_cd_1,
		ptpe.medi_in_hospital_cd_2,
		ptpe.medi_in_hospital_cd_3,
		ptpe.medi_in_hospital_cd_4,  
		ptpe.amount,
		ptpe.unit,
		ptpe.receipt_value,
		ptpe.unit_second,
		ptpe.procedure_cd,
		ptpe.pricedure_name,
		ptpe.timing_cd,
		CASE
			WHEN ptpe.in_hosp_a_startdate <= om.treat_date :: TIMESTAMP
			 AND (ptpe.in_hosp_b_startdate IS NULL OR om.treat_date :: TIMESTAMP < ptpe.in_hosp_b_startdate)
			THEN ptpe.in_hospital_cd_a1
			WHEN ptpe.in_hosp_b_startdate <= om.treat_date :: TIMESTAMP THEN ptpe.in_hospital_cd_b1
			ELSE ''''
		END AS procedure_in_hospital_cd_1,
		CASE
			WHEN ptpe.in_hosp_a_startdate <= om.treat_date :: TIMESTAMP
			 AND (ptpe.in_hosp_b_startdate IS NULL OR om.treat_date :: TIMESTAMP < ptpe.in_hosp_b_startdate)
			THEN ptpe.in_hospital_cd_a2
			WHEN ptpe.in_hosp_b_startdate <= om.treat_date :: TIMESTAMP THEN ptpe.in_hospital_cd_b2
			ELSE ''''
		END AS procedure_in_hospital_cd_2,
		ptpe.medicate_timing_name,
		ptpe.comment,
		ptpe.ind_user_name,
		ptpe.upd_user_name
	FROM
		ord_mai om
		JOIN pat_treat_patt_ext ptpe
			ON ptpe.ind_treatment_cd = om.ind_treatment_cd
			AND ptpe.treat_week = om.treat_week
			AND ptpe.pat_id = om.pat_id
			AND ptpe.init_date <= CAST(om.treat_date AS TIMESTAMP)
			AND ptpe.class_cd in (@medIds)
		LEFT JOIN selector_sort mcs ON mcs.code = ptpe.class_cd AND mcs.master_physical_name = ''mst_medicine_class''
		LEFT JOIN selector_sort ms ON ms.code = ptpe.cd AND ptpe.medicine_type = 1 AND ms.master_physical_name = ''mst_medicine''
		LEFT JOIN selector_sort mms ON mms.code = ptpe.cd AND ptpe.medicine_type = 2 AND mms.master_physical_name = ''mst_medicine_mix''
		LEFT JOIN selector_sort mts ON mts.code = ptpe.timing_cd AND mts.master_physical_name = ''mst_medicate_timing''
		LEFT JOIN selector_sort p ON p.code = ptpe.procedure_cd	AND p.master_physical_name = ''mst_procedure''
)
, sort_fields AS (
  SELECT
		elem, ord
  FROM
		mst_facility_setting mfs,
		jsonb_array_elements_text(mfs.value::jsonb) WITH ORDINALITY t(elem, ord)
  WHERE
		facility_setting_no = ''3007''
    AND facility_cd = @facilityCd
)
, priority AS (
  SELECT sf.ord, mp.col
  FROM sort_fields sf
  JOIN (
    VALUES
      (''0'', ''reg_order''),
      (''1'', ''class_order''),
      (''2'', ''medicine_type''),
      (''3'', ''code_order''),
      (''4'', ''timing_order''),
      (''5'', ''proc_order''),
      (''6'', ''date_interval'')
  ) AS mp(elem, col)
  ON mp.elem = sf.elem
)

SELECT * FROM pat_treat_patt_last tbl
ORDER BY (
  SELECT array_agg(
    CASE col
      WHEN ''reg_order''     THEN ARRAY[tbl.no,        			 NULL]
      WHEN ''class_order''   THEN ARRAY[tbl.class_order,     NULL]
      WHEN ''medicine_type'' THEN ARRAY[tbl.medicine_type,   NULL]
      WHEN ''code_order''    THEN ARRAY[tbl.code_order,      tbl.code_mix_order]
      WHEN ''timing_order''  THEN ARRAY[tbl.timing_order,    NULL]
      WHEN ''proc_order''    THEN ARRAY[tbl.proc_order,      NULL]
      WHEN ''date_interval'' THEN ARRAY[tbl.date_interval,   NULL]
    END
    ORDER BY ord
  )
  FROM priority
)
', 2, '[{"preview": "1", "can_calc": "0", "data_code": "medi_class_cd", "data_name": "薬剤分類コード", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "class_cd", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "未分類", "can_calc": "0", "data_code": "medi_class_type", "data_name": "分類区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "未分類", "item": "未分類"}, {"code": "1", "disp": "抗凝固剤", "item": "抗凝固剤"}, {"code": "2", "disp": "透析液", "item": "透析液"}, {"code": "3", "disp": "補液", "item": "補液"}], "data_class": "投薬(定期)", "field_name": "class_type", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "medi_cd", "data_name": "薬剤(調整薬剤)コード", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "cd", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/04", "can_calc": "0", "data_code": "treat_date", "data_name": "治療日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬(定期)", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/03/07", "can_calc": "0", "data_code": "init_date", "data_name": "指示開始日", "data_type": "DateTime", "conv_table": [], "data_class": "投薬(定期)", "field_name": "init_date", "disp_format": "yyyy/mm/dd", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト薬剤１", "can_calc": "0", "data_code": "medi_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "medicine_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "項目未分類", "can_calc": "0", "data_code": "class_name", "data_name": "薬剤分類名", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "class_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_1", "data_name": "薬剤連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "medi_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_2", "data_name": "薬剤連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "medi_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_3", "data_name": "薬剤連携コード３", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "medi_in_hospital_cd_3", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "medi_in_hospital_cd_4", "data_name": "薬剤連携コード４", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "medi_in_hospital_cd_4", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "medi_amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "投薬(定期)", "field_name": "amount", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "medicine_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "unit", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "receipt_value", "data_name": "数量(レセ)", "data_type": "decimal", "conv_table": [], "data_class": "投薬(定期)", "field_name": "receipt_value", "disp_format": "0", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "unit_second", "data_name": "単位(レセ)", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "unit_second", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "静脈側回路内注射", "can_calc": "0", "data_code": "pricedure_name", "data_name": "手技", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "pricedure_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "procedure_in_hospital_cd_1", "data_name": "手技連携コード１", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "procedure_in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "procedure_in_hospital_cd_2", "data_name": "手技連携コード２", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "procedure_in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "透析中", "can_calc": "0", "data_code": "medicate_timing_name", "data_name": "投与時間帯", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "medicate_timing_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "予定薬剤です。", "can_calc": "0", "data_code": "comment", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "comment", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト医師", "can_calc": "0", "data_code": "ind_user_name", "data_name": "指示者", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "ind_user_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト技士", "can_calc": "0", "data_code": "upd_user_name", "data_name": "更新者", "data_type": "string", "conv_table": [], "data_class": "投薬(定期)", "field_name": "upd_user_name", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "毎回", "can_calc": "0", "data_code": "date_interval", "data_name": "投与間隔", "data_type": "string", "conv_table": [{"code": "0", "disp": "毎回", "item": "毎回"}, {"code": "1", "disp": "毎週", "item": "毎週"}, {"code": "2", "disp": "1回/2週", "item": "1回/2週"}, {"code": "3", "disp": "1回/3週", "item": "1回/3週"}, {"code": "4", "disp": "1回/4週", "item": "1回/4週"}, {"code": "5", "disp": "1回/月：第1曜日", "item": "1回/月：第1曜日"}, {"code": "6", "disp": "1回/月：第2曜日", "item": "1回/月：第2曜日"}, {"code": "7", "disp": "1回/月：第3曜日", "item": "1回/月：第3曜日"}, {"code": "8", "disp": "1回/月：第4曜日", "item": "1回/月：第4曜日"}, {"code": "9", "disp": "1回/月：最終曜日", "item": "1回/月：最終曜日"}, {"code": "10", "disp": "1回/月：最終治療日", "item": "1回/月：最終治療日"}], "data_class": "投薬(定期)", "field_name": "date_interval", "disp_format": "", "filter_type": "Medicine", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '指示：投薬(定期) @patIds @facilityCd @toDate @ordNos @medIds', '2026-03-25 17:22:53.756', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (141, 'WITH selector_sort AS (
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
		AND master_physical_name in (''mst_medicine_class'', ''mst_medicine'', ''mst_medicine_mix'', ''mst_medicate_timing'', ''mst_procedure'')
)
, sort_fields AS (
  SELECT
		elem, ord
  FROM
		mst_facility_setting mfs,
		jsonb_array_elements_text(mfs.value::jsonb) WITH ORDINALITY t(elem, ord)
  WHERE
		facility_setting_no = ''3007''
    AND facility_cd = @facilityCd
)
, priority AS (
  SELECT sf.ord, mp.col
  FROM sort_fields sf
  JOIN (
    VALUES
      (''0'', ''reg_order''),
      (''1'', ''class_order''),
      (''2'', ''medicine_type''),
      (''3'', ''code_order''),
      (''4'', ''timing_order''),
      (''5'', ''proc_order''),
      (''6'', ''date_interval'')
  ) AS mp(elem, col)
  ON mp.elem = sf.elem
)

SELECT
  A.ord_no,
  A.treat_date,
	A.medi_no as no,
	A.medicine_type,
	dmed_cls.code_order AS class_order,
  dmed.code_order AS code_order,
  dmed_mix.code_order AS code_mix_order,
  dtim.code_order as timing_order,
  dpro.code_order as proc_order,
  A.f_medi_cd,
  A.medicine_name AS f_medi_name,
  A.f_medi_amount,
  A.medicine_unit AS f_medicine_unit,
  ARRAY_AGG ( A.f_week ) AS f_week,
  A.date_interval
FROM
  (
  SELECT
    weekmedi_info.cd AS f_medi_cd,
    mmd.medicine_name AS medicine_name,
    weekmedi_info.amount AS f_medi_amount,
    mmd.unit AS medicine_unit,
    weekmedi_info.medicine_type,
    weekmedi_info.week AS f_week,
    weekmedi_info.ord_no,
    weekmedi_info.treat_date,
    weekmedi_info.medi_no,
    weekmedi_info.timing_cd,
    weekmedi_info.procedure_cd,
    weekmedi_info.date_interval
  FROM
    (
    SELECT DISTINCT
      ord.ord_no,
      ord.treat_date,
      medi ->> ''cd'' AS cd,
      CAST ( medi ->> ''amount'' AS DECIMAL ) AS amount,
      CAST ( medi ->> ''medicine_type'' AS INTEGER ) AS medicine_type,
      medi ->> ''unit'' AS unit,
      CAST ( medi ->> ''no'' AS INTEGER ) AS medi_no,
      CAST ( medi ->> ''timing_cd'' AS INTEGER ) AS timing_cd,
      CAST ( medi ->> ''procedure_cd'' AS INTEGER ) AS procedure_cd,
      CAST ( medi ->> ''date_interval'' AS DECIMAL ) AS date_interval,
    CASE
        ord.treat_week 
        WHEN 1 THEN
        ''月'' 
        WHEN 2 THEN
        ''火'' 
        WHEN 3 THEN
        ''水'' 
        WHEN 4 THEN
        ''木'' 
        WHEN 5 THEN
        ''金'' 
        WHEN 6 THEN
        ''土'' 
        WHEN 7 THEN
        ''日'' ELSE''未'' 
      END AS week 
    FROM
      ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.ind_medi_info :: JSON ) WITH ORDINALITY AS tmp ( medi ) 
    WHERE
      ord.facility_cd = @facilityCd 
      AND ord.treat_date BETWEEN to_char( date_trunc( ''day'', ( @fromDate ) :: TIMESTAMP ), ''yyyymmdd'' ) 
      AND to_char( date_trunc( ''day'', ( @toDate ) :: TIMESTAMP ) + ''1 days - 1 milliseconds'', ''yyyymmdd'' ) 
      AND ord.pat_id = @patId 
      AND ord.is_del = ''0'' 
    ORDER BY
      medi_no,
      cd,
      amount,
      unit,
      week
    ) AS weekmedi_info
    INNER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( weekmedi_info.cd, ''999999999999'' ) 
    AND mmd.class_cd IN ( @medIds ) 
  WHERE
    weekmedi_info.medicine_type = ''1''
    
  UNION ALL
  
  SELECT
    weekmedi_info.cd AS f_medi_cd,
    mix.medicine_mix_name AS medicine_name,
    weekmedi_info.amount AS f_medi_amount,
    mix.unit AS medicine_unit,
    weekmedi_info.medicine_type,
    weekmedi_info.week AS f_week,
    weekmedi_info.ord_no,
    weekmedi_info.treat_date,
    weekmedi_info.medi_no,
    weekmedi_info.timing_cd,
    weekmedi_info.procedure_cd,
    weekmedi_info.date_interval
  FROM
    (
    SELECT DISTINCT
      ord.ord_no,
      ord.treat_date,
      medi ->> ''cd'' AS cd,
      CAST ( medi ->> ''amount'' AS DECIMAL ) AS amount,
      CAST ( medi ->> ''medicine_type'' AS INTEGER ) AS medicine_type,
      medi ->> ''unit'' AS unit,
      CAST ( medi ->> ''no'' AS INTEGER ) AS medi_no,
      CAST ( medi ->> ''timing_cd'' AS INTEGER ) AS timing_cd,
      CAST ( medi ->> ''procedure_cd'' AS INTEGER ) AS procedure_cd,
      CAST ( medi ->> ''date_interval'' AS DECIMAL ) AS date_interval,
    CASE
        ord.treat_week 
        WHEN 1 THEN
        ''月'' 
        WHEN 2 THEN
        ''火'' 
        WHEN 3 THEN
        ''水'' 
        WHEN 4 THEN
        ''木'' 
        WHEN 5 THEN
        ''金'' 
        WHEN 6 THEN
        ''土'' 
        WHEN 7 THEN
        ''日'' ELSE''未'' 
      END AS week 
    FROM
      ord_main AS ord
      CROSS JOIN LATERAL json_array_elements ( ord.ind_medi_info :: JSON ) WITH ORDINALITY AS tmp ( medi ) 
    WHERE
      ord.facility_cd = @facilityCd 
      AND ord.treat_date BETWEEN to_char( date_trunc( ''day'', ( @fromDate ) :: TIMESTAMP ), ''yyyymmdd'' ) 
      AND to_char( date_trunc( ''day'', ( @toDate ) :: TIMESTAMP ) + ''1 days - 1 milliseconds'', ''yyyymmdd'' ) 
      AND ord.pat_id = @patId 
      AND ord.is_del = ''0'' 
    ORDER BY
      medi_no,
      cd,
      amount,
      unit,
      week
    ) AS weekmedi_info
    INNER JOIN mst_medicine_mix AS mix ON mix.medicine_mix_cd = TO_NUMBER( weekmedi_info.cd, ''999999999999'' ) 
    AND mix.class_cd IN ( @medIds ) 
  WHERE
    weekmedi_info.medicine_type = ''2'' 
  ) A
  LEFT JOIN mst_medicine as med on (A.f_medi_cd = med.medicine_cd :: text and med.is_del = ''0'' and med.is_disp = ''1'' and A.medicine_type = ''1'')
  LEFT JOIN mst_medicine_mix as mix on (A.f_medi_cd = mix.medicine_mix_cd :: text and mix.is_del = ''0'' and mix.is_disp = ''1'' and A.medicine_type = ''2'')
  LEFT JOIN selector_sort AS dmed_cls ON (dmed_cls.code = med.class_cd or dmed_cls.code = mix.class_cd) AND dmed_cls.master_physical_name = ''mst_medicine_class''
  LEFT JOIN selector_sort AS dmed ON dmed.code = med.medicine_cd AND dmed.master_physical_name = ''mst_medicine''
  LEFT JOIN selector_sort AS dmed_mix ON dmed_mix.code = mix.medicine_mix_cd AND dmed_mix.master_physical_name = ''mst_medicine_mix''
  LEFT JOIN selector_sort AS dtim ON dtim.code = A.timing_cd AND dtim.master_physical_name = ''mst_medicate_timing''
  LEFT JOIN selector_sort AS dpro ON dpro.code = A.procedure_cd AND dpro.master_physical_name = ''mst_procedure''
  GROUP BY
    A.f_medi_cd,
    A.medicine_name,
    A.f_medi_amount,
    A.medicine_unit,
    A.medicine_type,
    A.ord_no,
    A.treat_date,
    A.medi_no,
    dmed_cls.code_order,
    dmed.code_order,
    dmed_mix.code_order,
    dtim.code_order,
    dpro.code_order,
    A.date_interval
ORDER BY (
  SELECT array_agg(
    CASE col
      WHEN ''reg_order''     THEN ARRAY[A.medi_no,        NULL]
      WHEN ''class_order''   THEN ARRAY[dmed_cls.code_order,     NULL]
      WHEN ''medicine_type'' THEN ARRAY[A.medicine_type,   NULL]
      WHEN ''code_order''    THEN ARRAY[dmed.code_order,      dmed_mix.code_order]
      WHEN ''timing_order''  THEN ARRAY[dtim.code_order,    NULL]
      WHEN ''proc_order''    THEN ARRAY[dpro.code_order,      NULL]
      WHEN ''date_interval'' THEN ARRAY[A.date_interval,   NULL]
    END
    ORDER BY ord
  )
  FROM priority
)
', 2, '[{"preview": "1", "can_calc": "0", "data_code": "f_medi_cd", "data_name": "薬剤(調整薬剤)コード", "data_type": "decimal", "conv_table": [], "data_class": "投薬(未来有効)", "field_name": "f_medi_cd", "disp_format": "0", "filter_type": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト薬剤１", "can_calc": "0", "data_code": "f_medi_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "投薬(未来有効)", "field_name": "f_medi_name", "disp_format": "", "filter_type": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "f_medi_amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "投薬(未来有効)", "field_name": "f_medi_amount", "disp_format": "0", "filter_type": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "f_medicine_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "投薬(未来有効)", "field_name": "f_medicine_unit", "disp_format": "", "filter_type": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "火,水,木", "can_calc": "0", "data_code": "f_week", "data_name": "指示曜日", "data_type": "string", "conv_table": [], "data_class": "投薬(未来有効)", "field_name": "f_week", "disp_format": "", "filter_type": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9]}', '指示：投薬(未来有効) @patId @facilityCd @fromDate @toDate @medIds', '2021-03-31 14:09:45', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (149, 'WITH mst_equi AS (
	SELECT
		equipment_cd,
		equipment_name
	FROM
		mst_equipment
	WHERE
		facility_cd = @facilityCd
),
mst_equic AS (
	SELECT
		class_cd,
		class_name
	FROM
		mst_equipment_class
	WHERE
		facility_cd = @facilityCd
),
mst_medi AS (
	SELECT
		medicine_cd,
		medicine_name
	FROM
		mst_medicine
	WHERE
		facility_cd = @facilityCd
),
mst_medic AS (
	SELECT
		class_cd,
		class_name
	FROM
		mst_medicine_class
	WHERE
		facility_cd = @facilityCd
),
mst_medim AS (
	SELECT
		medicine_mix_cd,
		medicine_mix_name
	FROM
		mst_medicine_mix
	WHERE
		facility_cd = @facilityCd
),
mst_dial AS (
	SELECT
		dialyzer_cd,
		model_number
	FROM
		mst_dialyzer
	WHERE
		facility_cd = @facilityCd
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
		AND master_physical_name in (''mst_equipment_class'', ''mst_equipment'', ''mst_dialyzer'', ''mst_medicine_class'', ''mst_medicine'', ''mst_medicine_mix'', ''mst_medicate_timing'', ''mst_procedure'')
)
, sort_fields AS (
  SELECT
		elem, ord, facility_setting_no
  FROM
		mst_facility_setting mfs,
		jsonb_array_elements_text(mfs.value::jsonb) WITH ORDINALITY t(elem, ord)
  WHERE
		facility_setting_no in (''3006'',''3007'')
    AND facility_cd = @facilityCd
)
, equ_priority AS (
  SELECT sf.ord, mp.col
  FROM sort_fields sf
  JOIN (
    VALUES
      (''0'', ''reg_order''),
      (''1'', ''class_order''),
      (''2'', ''code_order'')
  ) AS mp(elem, col)
  ON mp.elem = sf.elem
	WHERE sf.facility_setting_no = ''3006''
)
, med_priority AS (
  SELECT sf.ord, mp.col
  FROM sort_fields sf
  JOIN (
    VALUES
      (''0'', ''reg_order''),
      (''1'', ''class_order''),
      (''2'', ''medicine_type''),
      (''3'', ''code_order''),
      (''4'', ''timing_order''),
      (''5'', ''proc_order''),
      (''6'', ''date_interval'')
  ) AS mp(elem, col)
  ON mp.elem = sf.elem
	WHERE sf.facility_setting_no = ''3007''
)
, result_tbl AS (
	SELECT
		supplies_cd,
		supplies_source_class,
		supplies_class,
		CASE WHEN supplies_class IN (''00'',''02'',''03'',''04'',''05'',''06'',''07'',''11'') THEN equipment_name
				 WHEN supplies_class IN (''08'',''09'',''10'',''12'') THEN medicine_name
				 WHEN supplies_class IN (''13'',''17'') THEN medicine_mix_name
				 WHEN supplies_class IN (''01'') THEN model_number
		END AS supplies_name,
		CASE WHEN oms.class_cd is not null OR oms.class_cd <> '''' THEN oms.class_cd
				 ELSE ''-1''
		END AS class_cd,
		CASE WHEN supplies_class IN (''00'',''02'',''03'',''04'',''05'',''06'',''07'',''11'') THEN mec.class_name
				 WHEN supplies_class IN (''08'',''09'',''10'',''12'',''13'',''17'') THEN mmc.class_name
				 WHEN supplies_class IN (''01'') THEN ''ダイアライザ''
				 END AS class_name,
		supplies_base_date,
		NULLIF(ind_rst_value, '''') AS ind_rst_value,
		CASE
			WHEN medicine_no::TEXT IS NOT NULL THEN medicine_no ->>''no''::TEXT
			ELSE medicine_no::TEXT
		END AS medi_info_no,
		CASE WHEN supplies_class IN (''01'') THEN supplies_cd
		END AS dialyzer_cd,
		CASE WHEN supplies_class IN (''00'',''02'',''03'',''04'',''05'',''06'',''07'',''11'') THEN supplies_cd
		END AS equipment_cd,
		CASE WHEN supplies_class IN (''08'',''09'',''10'',''12'') THEN 1
					WHEN supplies_class IN (''13'',''17'') THEN 2
		END AS medicine_type,
		CASE WHEN supplies_class IN (''08'',''09'',''10'',''12'') THEN supplies_cd
		END AS medicine_cd,
		CASE WHEN supplies_class IN (''13'',''17'') THEN supplies_cd
		END AS medicine_mix_cd,
		CASE WHEN supplies_class IN (''08'',''09'',''10'',''12'',''13'',''17'') THEN procedure_cd
		END AS procedure_cd,
		CASE WHEN supplies_class IN (''08'',''09'',''10'',''12'',''13'',''17'') THEN timing_cd
		END AS timing_cd,
		CASE WHEN supplies_class IN (''08'',''09'',''10'',''12'',''13'',''17'') THEN 0
		END AS date_interval
	FROM
		ord_material_save oms
	LEFT JOIN mst_equi me ON oms.supplies_cd::INTEGER = me.equipment_cd
	LEFT JOIN mst_equic mec ON oms.class_cd::INTEGER = mec.class_cd
	LEFT JOIN mst_medi mm ON oms.supplies_cd::INTEGER = mm.medicine_cd
	LEFT JOIN mst_medic mmc ON oms.class_cd::INTEGER = mmc.class_cd
	LEFT JOIN mst_medim mmm ON oms.supplies_cd::INTEGER = mmm.medicine_mix_cd
	LEFT JOIN mst_dialyzer md ON oms.supplies_cd::INTEGER = md.dialyzer_cd
	WHERE
		pat_id in (@patIds)
	AND oms.facility_cd = @facilityCd
	AND supplies_base_no in (@ordNos)
	AND supplies_base_date::TIMESTAMP BETWEEN date_trunc(''day'', @fromDate ::timestamp) AND date_trunc(''day'', @toDate ::timestamp)
	AND	ind_rst_class = ''1''
	AND supplies_class <> ''16''
	AND supplies_class <> ''23''
	AND supplies_class <> ''24''
	AND CASE WHEN supplies_class IN (''00'',''02'',''03'',''04'',''05'',''06'',''07'',''11'') THEN
						 CASE WHEN oms.class_cd is not null OR oms.class_cd <> '''' THEN oms.class_cd::INTEGER IN (@eqIds)
						 ELSE -1 IN (@eqIds)
						 END
					 WHEN supplies_class IN (''08'',''09'',''10'',''12'',''13'',''17'') THEN
						 CASE WHEN oms.class_cd is not null OR oms.class_cd <> '''' THEN oms.class_cd::INTEGER IN (@medIds)
						 ELSE -1 IN (@medIds)
						 END
					 WHEN supplies_class IN (''01'') THEN supplies_cd::INTEGER IN (@diaIds)
			END
)
, order_tbl AS (
	SELECT
		m.*
		, CASE WHEN supplies_class IN (''00'',''02'',''03'',''04'',''05'',''06'',''07'',''11'') THEN CAST(m.medi_info_no AS INTEGER)
				 WHEN supplies_class IN (''08'',''09'',''10'',''12'',''13'',''17'') THEN CAST(m.medi_info_no AS INTEGER)
				 ELSE NULL
		END as json_idx
		, CASE WHEN supplies_class IN (''00'',''02'',''03'',''04'',''05'',''06'',''07'',''11'') THEN eqc.code_order
				 WHEN supplies_class IN (''08'',''09'',''10'',''12'',''13'',''17'') THEN dmed_cls.code_order
				 ELSE NULL
		END AS class_order
		, CASE WHEN supplies_class IN (''00'',''02'',''03'',''04'',''05'',''06'',''07'',''11'') THEN eq.code_order
				 WHEN supplies_class IN (''08'',''09'',''10'',''12'') THEN dmed.code_order
				 WHEN supplies_class IN (''01'') THEN diaz.code_order
				 ELSE NULL
		END as code_order
		, dmed_mix.code_order as code_mix_order
		, dtim.code_order as timing_order
		, dpro.code_order as proc_order
	FROM
		result_tbl m
	LEFT JOIN selector_sort diaz ON diaz.code = CAST(m.dialyzer_cd AS INTEGER) AND diaz.master_physical_name = ''mst_dialyzer''
	LEFT JOIN selector_sort eq ON eq.code = CAST(m.equipment_cd AS INTEGER) AND eq.master_physical_name = ''mst_equipment''
	LEFT JOIN selector_sort eqc ON eqc.code = CAST(m.class_cd AS INTEGER) AND eqc.master_physical_name = ''mst_equipment_class''
	LEFT JOIN selector_sort as dmed_cls on dmed_cls.code = CAST(m.class_cd AS INTEGER) AND dmed_cls.master_physical_name = ''mst_medicine_class''
	LEFT JOIN selector_sort as dmed on dmed.code = CAST(m.medicine_cd AS INTEGER) AND dmed.master_physical_name = ''mst_medicine''
	LEFT JOIN selector_sort as dmed_mix on dmed_mix.code = CAST(m.medicine_mix_cd AS INTEGER) AND dmed_mix.master_physical_name = ''mst_medicine_mix''
	LEFT JOIN selector_sort as dtim on dtim.code = CAST(m.timing_cd AS INTEGER) AND dtim.master_physical_name = ''mst_medicate_timing''
	LEFT JOIN selector_sort as dpro on dpro.code = CAST(m.procedure_cd AS INTEGER) AND dpro.master_physical_name = ''mst_procedure''
)
SELECT * FROM order_tbl tbl
ORDER BY
	CASE
		WHEN tbl.supplies_class IN (''01'') THEN 1
		WHEN tbl.supplies_class IN (''00'',''02'',''03'',''04'',''05'',''06'',''07'',''11'') THEN 2
		WHEN tbl.supplies_class IN (''08'',''09'',''10'',''12'',''13'',''17'') THEN 3
		ELSE 4
	END,
	CASE
		WHEN tbl.supplies_class IN (''01'',''00'',''02'',''03'',''04'',''05'',''06'',''07'',''11'') THEN (
			SELECT array_agg(
				CASE col
					WHEN ''reg_order''     THEN tbl.json_idx
					WHEN ''class_order''   THEN tbl.class_order
					WHEN ''code_order''    THEN tbl.code_order
				END
				ORDER BY ord
			)
			FROM equ_priority
		)	
		WHEN tbl.supplies_class IN (''08'',''09'',''10'',''12'',''13'',''17'') THEN (
			SELECT array_agg(
				CASE col
					WHEN ''reg_order''     THEN ARRAY[tbl.json_idx,        NULL]
					WHEN ''class_order''   THEN ARRAY[tbl.class_order,     NULL]
					WHEN ''medicine_type'' THEN ARRAY[tbl.medicine_type,   NULL]
					WHEN ''code_order''    THEN ARRAY[tbl.code_order,      tbl.code_mix_order]
					WHEN ''timing_order''  THEN ARRAY[tbl.timing_order,    NULL]
					WHEN ''proc_order''    THEN ARRAY[tbl.proc_order,      NULL]
					WHEN ''date_interval'' THEN ARRAY[tbl.date_interval,   NULL]
				END
				ORDER BY ord
			)
			FROM med_priority
		)
	END,
	class_name NULLS LAST,
	supplies_name NULLS LAST
', 2, '[{"preview": "1", "can_calc": "0", "data_code": "supplies_cd", "data_name": "物品コード", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "supplies_cd", "disp_format": "", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "medi_info_no", "data_name": "薬剤識別番号", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "medi_info_no", "disp_format": "", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "supplies_source_class", "data_name": "データ発生元区分", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "supplies_source_class", "disp_format": "", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}, {"preview": "00", "can_calc": "0", "data_code": "supplies_class", "data_name": "物品区分", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "supplies_class", "disp_format": "", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト穿刺針", "can_calc": "0", "data_code": "supplies_name", "data_name": "医療材料名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "supplies_name", "disp_format": "", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/15", "can_calc": "0", "data_code": "supplies_base_date", "data_name": "データ基準日", "data_type": "DateTime", "conv_table": [], "data_class": "医材", "field_name": "supplies_base_date", "disp_format": "yyyy/mm/dd", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "ind_rst_value", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "医材", "field_name": "ind_rst_value", "disp_format": "0", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [10, 11]}', '週間：医材 @patIds @facilityCd @fromdate @todate @ordNos @eqIds @diaIds @medIds', '2021-04-25 16:40:02', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (230, 'WITH mst_equi AS (
	SELECT
		equipment_cd,
		equipment_name
	FROM
		mst_equipment
	WHERE
		facility_cd = @facilityCd
),
mst_equic AS (
	SELECT
		class_cd,
		class_name
	FROM
		mst_equipment_class
	WHERE
		facility_cd = @facilityCd
),
mst_medi AS (
	SELECT
		medicine_cd,
		medicine_name
	FROM
		mst_medicine
	WHERE
		facility_cd = @facilityCd
),
mst_medic AS (
	SELECT
		class_cd,
		class_name
	FROM
		mst_medicine_class
	WHERE
		facility_cd = @facilityCd
),
mst_dial AS (
	SELECT
		dialyzer_cd,
		model_number
	FROM
		mst_dialyzer
	WHERE
		facility_cd = @facilityCd
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
		AND master_physical_name in (''mst_equipment_class'', ''mst_equipment'', ''mst_dialyzer'', ''mst_medicine_class'', ''mst_medicine'', ''mst_medicine_mix'', ''mst_medicate_timing'', ''mst_procedure'')
)
, sort_fields AS (
  SELECT
		elem, ord, facility_setting_no
  FROM
		mst_facility_setting mfs,
		jsonb_array_elements_text(mfs.value::jsonb) WITH ORDINALITY t(elem, ord)
  WHERE
		facility_setting_no in (''3006'',''3007'')
    AND facility_cd = @facilityCd
)
, equ_priority AS (
  SELECT sf.ord, mp.col
  FROM sort_fields sf
  JOIN (
    VALUES
      (''0'', ''reg_order''),
      (''1'', ''class_order''),
      (''2'', ''code_order'')
  ) AS mp(elem, col)
  ON mp.elem = sf.elem
	WHERE sf.facility_setting_no = ''3006''
)
, med_priority AS (
  SELECT sf.ord, mp.col
  FROM sort_fields sf
  JOIN (
    VALUES
      (''0'', ''reg_order''),
      (''1'', ''class_order''),
      (''2'', ''medicine_type''),
      (''3'', ''code_order''),
      (''4'', ''timing_order''),
      (''5'', ''proc_order''),
      (''6'', ''date_interval'')
  ) AS mp(elem, col)
  ON mp.elem = sf.elem
	WHERE sf.facility_setting_no = ''3007''
)
, result_tbl AS (
	SELECT
		supplies_cd,
		supplies_class,
		CASE WHEN supplies_class IN (''00'',''02'',''03'',''04'',''05'',''06'',''07'',''11'') THEN equipment_name
				 WHEN supplies_class IN (''08'',''09'',''10'',''12'',''20'',''21'',''22'') THEN medicine_name
				 WHEN supplies_class IN (''01'') THEN model_number
		END AS supplies_name,
		CASE WHEN oms.class_cd is not null OR oms.class_cd <> '''' THEN oms.class_cd
				 ELSE ''-1''
		END AS class_cd,
		CASE WHEN supplies_class IN (''00'',''02'',''03'',''04'',''05'',''06'',''07'',''11'') THEN mec.class_name
				 WHEN supplies_class IN (''08'',''09'',''10'',''12'',''20'',''21'',''22'') THEN mmc.class_name
				 WHEN supplies_class IN (''01'') THEN ''ダイアライザ''
				 END AS class_name,
		supplies_base_date,
		ind_rst_value,
		CASE
			WHEN medicine_no::TEXT IS NOT NULL THEN medicine_no ->>''no''::TEXT
			ELSE medicine_no::TEXT
		END AS medi_info_no,
		CASE WHEN supplies_class IN (''01'') THEN supplies_cd
		END AS dialyzer_cd,
		CASE WHEN supplies_class IN (''00'',''02'',''03'',''04'',''05'',''06'',''07'',''11'') THEN supplies_cd
		END AS equipment_cd,
		CASE WHEN supplies_class IN (''08'',''09'',''10'',''12'',''20'',''21'',''22'') THEN 1
		END AS medicine_type,
		CASE WHEN supplies_class IN (''08'',''09'',''10'',''12'',''20'',''21'',''22'') THEN supplies_cd
		END AS medicine_cd,
		NULL AS medicine_mix_cd,
		CASE WHEN supplies_class IN (''08'',''09'',''10'',''12'',''20'',''21'',''22'') THEN oms.procedure_cd
		END AS procedure_cd,
		CASE WHEN supplies_class IN (''08'',''09'',''10'',''12'',''20'',''21'',''22'') THEN oms.timing_cd
		END AS timing_cd,
		CASE WHEN supplies_class IN (''08'',''09'',''10'',''12'',''20'',''21'',''22'') THEN 0
		END AS date_interval
	FROM
		ord_material_save oms
	LEFT JOIN mst_equi me ON oms.supplies_cd::INTEGER = me.equipment_cd
	LEFT JOIN mst_equic mec ON oms.class_cd::INTEGER = mec.class_cd
	LEFT JOIN mst_medi mm ON oms.supplies_cd::INTEGER = mm.medicine_cd
	LEFT JOIN mst_medic mmc ON oms.class_cd::INTEGER = mmc.class_cd
	LEFT JOIN mst_dialyzer md ON oms.supplies_cd::INTEGER = md.dialyzer_cd
	WHERE
		pat_id in (@patIds)
	AND oms.facility_cd = @facilityCd
	AND supplies_base_no in (@ordNos)
	AND supplies_base_date::TIMESTAMP BETWEEN date_trunc(''day'', @fromDate ::timestamp) AND date_trunc(''day'', @toDate ::timestamp)
	AND	ind_rst_class = ''1''
	AND supplies_class <> ''16''
	AND supplies_class <> ''23''
	AND supplies_class <> ''24''
	AND CASE WHEN supplies_class IN (''00'',''02'',''03'',''04'',''05'',''06'',''07'',''11'') THEN
						 CASE WHEN oms.class_cd is not null OR oms.class_cd <> '''' THEN oms.class_cd::INTEGER IN (@eqIds)
						 ELSE -1 IN (@eqIds)
						 END
					 WHEN supplies_class IN (''08'',''09'',''10'',''12'',''20'',''21'',''22'') THEN
						 CASE WHEN oms.class_cd is not null OR oms.class_cd <> '''' THEN oms.class_cd::INTEGER IN (@medIds)
						 ELSE -1 IN (@medIds)
						 END
					 WHEN supplies_class IN (''01'') THEN supplies_cd::INTEGER IN (@diaIds)
			END
)
, order_tbl AS (
	SELECT
		m.*
		, CASE WHEN supplies_class IN (''00'',''02'',''03'',''04'',''05'',''06'',''07'',''11'') THEN CAST(m.medi_info_no AS INTEGER)
				 WHEN supplies_class IN (''08'',''09'',''10'',''12'',''20'',''21'',''22'') THEN CAST(m.medi_info_no AS INTEGER)
				 ELSE NULL
		END as json_idx
		, CASE WHEN supplies_class IN (''00'',''02'',''03'',''04'',''05'',''06'',''07'',''11'') THEN eqc.code_order
				 WHEN supplies_class IN (''08'',''09'',''10'',''12'',''20'',''21'',''22'') THEN dmed_cls.code_order
				 ELSE NULL
		END AS class_order
		, CASE WHEN supplies_class IN (''00'',''02'',''03'',''04'',''05'',''06'',''07'',''11'') THEN eq.code_order
				 WHEN supplies_class IN (''08'',''09'',''10'',''12'',''20'',''21'',''22'') THEN dmed.code_order
				 WHEN supplies_class IN (''01'') THEN diaz.code_order
				 ELSE NULL
		END as code_order
		, dmed_mix.code_order as code_mix_order
		, dtim.code_order as timing_order
		, dpro.code_order as proc_order
	FROM
		result_tbl m
	LEFT JOIN selector_sort diaz ON diaz.code = CAST(m.dialyzer_cd AS INTEGER) AND diaz.master_physical_name = ''mst_dialyzer''
	LEFT JOIN selector_sort eq ON eq.code = CAST(m.equipment_cd AS INTEGER) AND eq.master_physical_name = ''mst_equipment''
	LEFT JOIN selector_sort eqc ON eqc.code = CAST(m.class_cd AS INTEGER) AND eqc.master_physical_name = ''mst_equipment_class''
	LEFT JOIN selector_sort as dmed_cls on dmed_cls.code = CAST(m.class_cd AS INTEGER) AND dmed_cls.master_physical_name = ''mst_medicine_class''
	LEFT JOIN selector_sort as dmed on dmed.code = CAST(m.medicine_cd AS INTEGER) AND dmed.master_physical_name = ''mst_medicine''
	LEFT JOIN selector_sort as dmed_mix on dmed_mix.code = CAST(m.medicine_mix_cd AS INTEGER) AND dmed_mix.master_physical_name = ''mst_medicine_mix''
	LEFT JOIN selector_sort as dtim on dtim.code = CAST(m.timing_cd AS INTEGER) AND dtim.master_physical_name = ''mst_medicate_timing''
	LEFT JOIN selector_sort as dpro on dpro.code = CAST(m.procedure_cd AS INTEGER) AND dpro.master_physical_name = ''mst_procedure''
)
SELECT * FROM order_tbl tbl
ORDER BY
	CASE
		WHEN tbl.supplies_class IN (''01'') THEN 1
		WHEN tbl.supplies_class IN (''00'',''02'',''03'',''04'',''05'',''06'',''07'',''11'') THEN 2
		WHEN tbl.supplies_class IN (''08'',''09'',''10'',''12'',''20'',''21'',''22'') THEN 3
		ELSE 4
	END,
	CASE
		WHEN tbl.supplies_class IN (''01'',''00'',''02'',''03'',''04'',''05'',''06'',''07'',''11'') THEN (
			SELECT array_agg(
				CASE col
					WHEN ''reg_order''     THEN tbl.json_idx
					WHEN ''class_order''   THEN tbl.class_order
					WHEN ''code_order''    THEN tbl.code_order
				END
				ORDER BY ord
			)
			FROM equ_priority
		)	
		WHEN tbl.supplies_class IN (''08'',''09'',''10'',''12'',''20'',''21'',''22'') THEN (
			SELECT array_agg(
				CASE col
					WHEN ''reg_order''     THEN ARRAY[tbl.json_idx,        NULL]
					WHEN ''class_order''   THEN ARRAY[tbl.class_order,     NULL]
					WHEN ''medicine_type'' THEN ARRAY[tbl.medicine_type,   NULL]
					WHEN ''code_order''    THEN ARRAY[tbl.code_order,      tbl.code_mix_order]
					WHEN ''timing_order''  THEN ARRAY[tbl.timing_order,    NULL]
					WHEN ''proc_order''    THEN ARRAY[tbl.proc_order,      NULL]
					WHEN ''date_interval'' THEN ARRAY[tbl.date_interval,   NULL]
				END
				ORDER BY ord
			)
			FROM med_priority
		)
	END,
	class_name NULLS LAST,
	supplies_name NULLS LAST
', 2, '[{"preview": "テスト穿刺針", "can_calc": "0", "data_code": "supplies_name", "data_name": "医療材料名(分解)", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "supplies_name", "disp_format": "", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/15", "can_calc": "0", "data_code": "supplies_base_date", "data_name": "データ基準日(分解)", "data_type": "DateTime", "conv_table": [], "data_class": "医材", "field_name": "supplies_base_date", "disp_format": "yyyy/mm/dd", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "ind_rst_value", "data_name": "数量(分解)", "data_type": "decimal", "conv_table": [], "data_class": "医材", "field_name": "ind_rst_value", "disp_format": "0", "data_category": "週間", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [10, 11]}', '週間：医材(分解) @patIds @facilityCd @fromdate @todate @ordNos @eqIds @diaIds @medIds', '2021-04-25 16:40:02', CURRENT_TIMESTAMP, NULL);