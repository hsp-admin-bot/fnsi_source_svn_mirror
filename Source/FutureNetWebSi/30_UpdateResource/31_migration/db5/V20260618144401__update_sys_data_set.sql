DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (9, 74, 97);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9, 'WITH
save as (
	SELECT
		* ,
    NULLIF(save.medicine_no ->> ''no'','''')::numeric AS reg_order
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
)
, eq AS (
	SELECT
		*
	FROM
		mst_equipment
	WHERE
		facility_cd = @facilityCd
		AND is_del = ''0''
		AND is_disp = ''1''
)
, eqc AS (
	SELECT
		*
	FROM
		mst_equipment_class
	WHERE
		facility_cd = @facilityCd
		AND is_del = ''0''
		AND is_disp = ''1''
)
, md AS (
	SELECT
		*
	FROM
		mst_medicine
	WHERE
		facility_cd = @facilityCd
		AND is_del = ''0''
		AND is_disp = ''1''
)
, mdc AS (
	SELECT
		*
	FROM
		mst_medicine_class
	WHERE
		facility_cd = @facilityCd
		AND is_del = ''0''
		AND is_disp = ''1''
)
, goods_sort AS (
  SELECT
    index_no AS code_order,
    TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) code,
    master_physical_name
  FROM
    mst_selector
    CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
  WHERE
    facility_cd = @facilityCd
    AND master_physical_name IN (''mst_dialyzer'',''mst_equipment'',''mst_equipment_class'',''mst_medicine'',''mst_medicine_class'')
)
, sort_fields AS (
  SELECT elem, ord, facility_setting_no
  FROM mst_facility_setting mfs,
       jsonb_array_elements_text(mfs.value::jsonb) WITH ORDINALITY t(elem, ord)
  WHERE facility_setting_no IN (''3006'', ''3007'')
    AND facility_cd = @facilityCd
)
, priority_equ AS (
  SELECT sf.ord, mp.col
  FROM sort_fields sf
  JOIN (
    VALUES
      (''0'', ''reg_order''),
      (''1'', ''class_order''),
      (''2'', ''cd'')
  ) AS mp(elem, col)
  ON mp.elem = sf.elem
  AND facility_setting_no = ''3006''
)
, priority_medi AS (
  SELECT sf.ord, mp.col
  FROM sort_fields sf
  JOIN (
    VALUES
      (''0'', ''reg_order''),
      (''1'', ''class_order''),
      (''2'', ''medicine_type''),
      (''3'', ''cd''),
      (''4'', ''timing_order''),
      (''5'', ''proc_order''),
      (''6'', ''date_interval'')
  ) AS mp(elem, col)
  ON mp.elem = sf.elem
  AND facility_setting_no = ''3007''
)
, result_all as (
	SELECT
	disp_order,
	to_timestamp( treat_date, ''YYYYMMDD'' ) AS treat_date,
	kind,
	NAME,
	SUM ( Amount ) AS amount,
	unit,
	SUM ( receipt_value ) AS receipt_value,
	receipt_unit,
	in_hospital_cd_1,
	in_hospital_cd_2,
	in_hospital_cd_3,
	in_hospital_cd_4,
	class_cd,
	cd,
	do_action,
	data_type_order,
	kind_order,
	goods_type,
  dia.code_order AS dia_order,
	medic.code_order AS medic_order,
	equic.code_order AS equic_order,
  NULL AS medi_mix_order,
  equipment_cd,
  equipment_class_cd,
  medicine_cd,
  medicine_class_cd,
  dialyzer_cd,
  reg_order,
  class_order,
  code_dia_order,
  code_equ_order,
  code_medi_order,
  medicine_type,
  timing_order,
  proc_order,
  date_interval,
  rn
FROM
(
  
	SELECT --治療条件:医材
    ord_no,
    disp_order,
    treat_date,
    kind,
    NAME,
    Amount,
    Unit,
    receipt_value,
    receipt_unit,
    in_hospital_cd_1,
    in_hospital_cd_2,
    in_hospital_cd_3,
    in_hospital_cd_4,
    class_cd,
    cd,
    do_action,
    data_type_order,
    kind_order,
    goods_type,
    equipment_cd,
    equipment_class_cd,
    medicine_cd,
    medicine_class_cd,
    dialyzer_cd,
    NULL::int AS reg_order,
    NULL::int AS class_order,
    NULL::int AS code_equ_order,
    NULL::int AS code_dia_order,
    NULL::int AS code_medi_order,
    NULL::int AS medicine_type,
    NULL::int AS timing_order,
    NULL::int AS proc_order,
    NULL::int AS date_interval,
    NULL::int[] AS sort_key,
    NULL::int AS rn
  FROM
  (
    SELECT --治療条件:ダイアライザ
      save.supplies_base_no AS ord_no,
      @equsort AS disp_order,
      save.supplies_base_date AS treat_date,
      ''ダイアライザ'' AS kind,
      dz.model_number AS NAME,
      CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
      COALESCE(save.ind_unit, '''') AS Unit,
      CAST(NULLIF(save.receipt_value, '''') AS DECIMAL) AS receipt_value,
      COALESCE(save.receipt_unit, '''') AS receipt_unit,
      dz.in_hospital_cd_1,
      dz.in_hospital_cd_2,
      dz.in_hospital_cd_3,
      dz.in_hospital_cd_4,
      ''-10'' AS class_cd,
      save.supplies_cd AS cd,
      ''ダイアライザ'' AS do_action,
      ''医療材料'' AS data_type_order,
      2 AS kind_order,
      1 AS goods_type,
      NULL AS equipment_cd,
      NULL AS equipment_class_cd,
      NULL AS medicine_cd,
      NULL AS medicine_class_cd,
      dz.dialyzer_cd::TEXT
    FROM
      save
    LEFT JOIN dz ON save.supplies_cd = CAST( dz.dialyzer_cd AS VARCHAR )
    WHERE
      save.supplies_class = ''01''
      AND save.supplies_source_class = ''0''
      AND save.supplies_cd::int IN ( @diaIds )
      
    UNION ALL
    
    SELECT --治療条件:血液回路、吸着カラム、1次膜、2次膜、シングルニードル、穿刺針(A)、穿刺針(V)
      save.supplies_base_no AS ord_no,
      @equsort AS disp_order,
      save.supplies_base_date AS treat_date,
      COALESCE ( eqc.class_name, '''' ) AS kind,
      eq.equipment_name AS NAME,
      CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
      COALESCE(save.ind_unit, '''') AS Unit,
      CAST(NULLIF(save.receipt_value, '''') AS DECIMAL) AS receipt_value,
      COALESCE(save.receipt_unit, '''') AS receipt_unit,
      eq.in_hospital_cd_1,
      eq.in_hospital_cd_2,
      eq.in_hospital_cd_3,
      eq.in_hospital_cd_4,
      COALESCE (save.class_cd , ''-1'') AS class_cd,
      save.supplies_cd AS cd,
      ''医材'' AS do_action,
      ''医療材料'' AS data_type_order,
      1 AS kind_order,
      1 AS goods_type,
      save.supplies_cd AS equipment_cd,
      save.class_cd AS equipment_class_cd,
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
      AND save.class_cd::int IN ( @eqIds )
  ) COND_EQU
  
  UNION ALL
  
  SELECT --透析条件：薬剤
    ord_no,
    disp_order,
    treat_date,
    kind,
    NAME,
    Amount,
    Unit,
    receipt_value,
    receipt_unit,
    in_hospital_cd_1,
    in_hospital_cd_2,
    in_hospital_cd_3,
    in_hospital_cd_4,
    class_cd,
    cd,
    do_action,
    data_type_order,
    kind_order,
    goods_type,
    equipment_cd,
    equipment_class_cd,
    medicine_cd,
    medicine_class_cd,
    dialyzer_cd,
    NULL::int AS reg_order,
    NULL::int AS class_order,
    NULL::int AS code_equ_order,
    NULL::int AS code_dia_order,
    NULL::int AS code_medi_order,
    NULL::int AS medicine_type,
    NULL::int AS timing_order,
    NULL::int AS proc_order,
    NULL::int AS date_interval,
    NULL::int[] AS sort_key,
    NULL::int AS rn
  FROM
  (
    SELECT --透析条件：透析液、補液、抗凝固剤、抗凝固剤(分解)
      save.supplies_base_no AS ord_no,
      @medsort AS disp_order,
      save.supplies_base_date AS treat_date,
      COALESCE(mdc.class_name, '''') AS kind,
      md.medicine_name AS NAME,
      CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
      COALESCE(save.ind_unit, '''') AS Unit,
      CAST(NULLIF(save.receipt_value, '''') AS DECIMAL) AS receipt_value,
      COALESCE(save.receipt_unit, '''') AS receipt_unit,
      md.in_hospital_cd_1,
      md.in_hospital_cd_2,
      md.in_hospital_cd_3,
      md.in_hospital_cd_4,
      COALESCE (save.class_cd , ''-1'') AS class_cd,
      save.supplies_cd AS cd,
      ''通常薬剤'' AS do_action,
      ''薬剤'' AS data_type_order,
      1 AS kind_order,
      2 AS goods_type,
      NULL AS equipment_cd,
      NULL AS equipment_class_cd,
      save.supplies_cd AS medicine_cd,
      save.class_cd AS medicine_class_cd,
      NULL AS dialyzer_cd
    FROM
      save
    LEFT JOIN md ON save.supplies_cd = CAST(md.medicine_cd AS VARCHAR)
    LEFT JOIN mdc ON save.class_cd = CAST(mdc.class_cd AS VARCHAR)
    WHERE
      save.supplies_class in (''08'', ''09'', ''10'', ''22'')
      AND save.supplies_source_class = ''0''
      AND save.class_cd::int IN ( @medIds )
  )　COND_MEDI
    
  UNION ALL
  
  SELECT
    *,
    ROW_NUMBER() OVER (ORDER BY sort_key) AS rn
  FROM
  (
    SELECT -- 医療材料
      ord_no,
      disp_order,
      treat_date,
      kind,
      NAME,
      Amount,
      Unit,
      receipt_value,
      receipt_unit,
      in_hospital_cd_1,
      in_hospital_cd_2,
      in_hospital_cd_3,
      in_hospital_cd_4,
      class_cd,
      cd,
      do_action,
      data_type_order,
      kind_order,
      goods_type,
      equipment_cd,
      equipment_class_cd,
      medicine_cd,
      medicine_class_cd,
      dialyzer_cd,
      reg_order,
      class_order,
      code_equ_order,
      code_dia_order,
      NULL::int AS code_medi_order,
      NULL::int AS medicine_type,
      NULL::int AS timing_order,
      NULL::int AS proc_order,
      NULL::int AS date_interval,
      s.sort_key
      
    FROM
    ( 
      SELECT --医療材料(ダイアライザ)
        save.supplies_base_no AS ord_no,
        @equsort AS disp_order,
        save.supplies_base_date AS treat_date,
        ''ダイアライザ'' AS kind,
        dz.model_number AS NAME,
        CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
        COALESCE(save.ind_unit, '''') AS Unit,
        CAST(NULLIF(save.receipt_value, '''') AS DECIMAL) AS receipt_value,
        COALESCE(save.receipt_unit, '''') AS receipt_unit,
        dz.in_hospital_cd_1,
        dz.in_hospital_cd_2,
        dz.in_hospital_cd_3,
        dz.in_hospital_cd_4,
        ''-10'' AS class_cd,
        save.supplies_cd AS cd,
        ''ダイアライザ'' AS do_action,
        ''医療材料'' AS data_type_order,
        2 AS kind_order,
        1 AS goods_type,
        NULL AS equipment_cd,
        NULL AS equipment_class_cd,
        NULL AS medicine_cd,
        NULL AS medicine_class_cd,
        dz.dialyzer_cd::TEXT,
        save.reg_order,
        NULL::int AS class_order,
        NULL::int AS code_equ_order,
        gsd.code_order AS code_dia_order
      FROM
        save
        LEFT JOIN dz ON save.supplies_cd = CAST( dz.dialyzer_cd AS VARCHAR )
        LEFT JOIN goods_sort AS gsd ON save.supplies_cd = CAST( gsd.code AS VARCHAR ) AND gsd.master_physical_name = ''mst_dialyzer''
      WHERE
        save.supplies_class = ''01''
        AND save.supplies_source_class = ''2''
        AND save.supplies_cd::int IN ( @diaIds )
      
      UNION ALL
      
      SELECT -- 医療材料(医材)
        save.supplies_base_no AS ord_no,
        @equsort AS disp_order,
        save.supplies_base_date AS treat_date,
        COALESCE (
          CASE WHEN oEqu.class_name IS NOT NULL THEN oEqu.class_name
            WHEN eqc.class_name IS NOT NULL THEN eqc.class_name
            ELSE NULL END
        , ''未分類'' ) AS kind,
        eq.equipment_name AS NAME,
        CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
        COALESCE(save.ind_unit, '''') AS Unit,
        CAST(NULLIF(save.receipt_value, '''') AS DECIMAL) AS receipt_value,
        COALESCE(save.receipt_unit, '''') AS receipt_unit,
        eq.in_hospital_cd_1,
        eq.in_hospital_cd_2,
        eq.in_hospital_cd_3,
        eq.in_hospital_cd_4,
        COALESCE (save.class_cd , ''-1'') AS class_cd,
        save.supplies_cd AS cd,
        ''医材'' AS do_action,
        ''医療材料'' AS data_type_order,
        1 AS kind_order,
        1 AS goods_type,
        save.supplies_cd AS equipment_cd,
        save.class_cd AS equipment_class_cd,
        NULL AS medicine_cd,
        NULL AS medicine_class_cd,
        NULL AS dialyzer_cd,
        save.reg_order,
        gsec.code_order AS class_order,
        gse.code_order AS code_equ_order,
        NULL::int AS code_dia_order
      FROM
        save
      LEFT JOIN eq ON save.supplies_cd = CAST(eq.equipment_cd AS VARCHAR)
      LEFT JOIN ord_ind_equip_info AS oEqu ON save.supplies_cd = CAST(oEqu.cd AS VARCHAR) AND save.supplies_base_no = oEqu.ord_no
      LEFT JOIN eqc ON save.class_cd = CAST(eqc.class_cd AS VARCHAR)
      LEFT JOIN goods_sort AS gse ON save.supplies_cd = CAST(gse.code AS VARCHAR) AND gse.master_physical_name = ''mst_equipment''
      LEFT JOIN goods_sort AS gsec ON save.class_cd = CAST(gsec.code AS VARCHAR) AND gsec.master_physical_name = ''mst_equipment_class''
      
      WHERE
        save.supplies_class = ''11''
        AND save.supplies_source_class = ''2''
        AND save.class_cd::int IN ( @eqIds )
    ) IND_EQU
    LEFT JOIN LATERAL (
      SELECT array_agg (
        CASE pq.col
          WHEN ''reg_order'' THEN ARRAY[reg_order::int, NULL]
          WHEN ''class_order'' THEN ARRAY[class_order::int, NULL]
          WHEN ''cd'' THEN ARRAY[code_equ_order::int, code_dia_order::int]
        END
        ORDER BY pq.ord
      ) AS sort_key
      FROM priority_equ pq
    ) s ON true
    GROUP BY
      ord_no,
      disp_order,
      treat_date,
      kind,
      NAME,
      Amount,
      Unit,
      receipt_value,
      receipt_unit,
      in_hospital_cd_1,
      in_hospital_cd_2,
      in_hospital_cd_3,
      in_hospital_cd_4,
      class_cd,
      cd,
      do_action,
      data_type_order,
      kind_order,
      goods_type,
      equipment_cd,
      equipment_class_cd,
      medicine_cd,
      medicine_class_cd,
      dialyzer_cd,
      reg_order,
      class_order,
      code_equ_order,
      code_dia_order,
      code_medi_order,
      medicine_type,
      timing_order,
      proc_order,
      date_interval,
      sort_key
    ORDER BY
      sort_key
  ) IND_EQU_SORT

  UNION ALL
  
  SELECT
    *,
    ROW_NUMBER() OVER (ORDER BY sort_key) AS rn
  FROM
  (
    SELECT --投与薬剤
      ord_no,
      disp_order,
      treat_date,
      kind,
      NAME,
      Amount,
      Unit,
      receipt_value,
      receipt_unit,
      in_hospital_cd_1,
      in_hospital_cd_2,
      in_hospital_cd_3,
      in_hospital_cd_4,
      class_cd,
      cd,
      do_action,
      data_type_order,
      kind_order,
      goods_type,
      equipment_cd,
      equipment_class_cd,
      medicine_cd,
      medicine_class_cd,
      dialyzer_cd,
      reg_order,
      class_order,
      NULL::int AS code_equ_order,
      NULL::int AS code_dia_order,
      code_medi_order,
      medicine_type,
      timing_order,
      proc_order,
      date_interval,
      s.sort_key
    FROM
    (
      SELECT --投与薬剤：通常薬剤、分解薬剤
        save.supplies_base_no AS ord_no,
        @medsort AS disp_order,
        save.supplies_base_date AS treat_date,
        COALESCE (
          CASE WHEN oMed.class_name IS NOT NULL THEN oMed.class_name
          WHEN mdc.class_name IS NOT NULL THEN mdc.class_name
          ELSE NULL END
        , ''未分類'' ) AS kind,
        md.medicine_name AS NAME,
        CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
        COALESCE(save.ind_unit, '''') AS Unit,
        CAST(NULLIF(save.receipt_value, '''') AS DECIMAL) AS receipt_value,
        COALESCE(save.receipt_unit, '''') AS receipt_unit,
        md.in_hospital_cd_1,
        md.in_hospital_cd_2,
        md.in_hospital_cd_3,
        md.in_hospital_cd_4,
        COALESCE (save.class_cd , ''-1'') AS class_cd,
        save.supplies_cd AS cd,
        ''通常薬剤'' AS do_action,
        ''薬剤'' AS data_type_order,
        1 AS kind_order,
        2 AS goods_type,
        NULL AS equipment_cd,
        NULL AS equipment_class_cd,
        save.supplies_cd AS medicine_cd,
        save.class_cd AS medicine_class_cd,
        NULL AS dialyzer_cd,
        save.reg_order,
        gsmc.code_order AS class_order,
        1 AS medicine_type,
        gsm.code_order AS code_medi_order,
        NULL::int timing_order,
        NULL::int proc_order,
        NULL::int date_interval
        
      FROM
        save
        LEFT JOIN md ON save.supplies_cd = CAST(md.medicine_cd AS VARCHAR)
        LEFT JOIN ord_ind_medi_info AS oMed ON save.supplies_cd = CAST(oMed.cd AS VARCHAR) AND save.supplies_base_no = oMed.ord_no
        LEFT JOIN mdc ON save.class_cd = CAST(mdc.class_cd AS VARCHAR)
        LEFT JOIN goods_sort AS gsm ON save.supplies_cd = CAST(gsm.code AS VARCHAR) AND gsm.master_physical_name = ''mst_medicine''
        LEFT JOIN goods_sort AS gsmc ON save.class_cd = CAST(gsmc.code AS VARCHAR) AND gsmc.master_physical_name = ''mst_medicine_class''
      WHERE
        save.supplies_class in (''12'', ''20'')
        AND save.class_cd::int IN ( @medIds )
    ) IND_MEDI
    LEFT JOIN LATERAL (
      SELECT array_agg (
          CASE pm.col
             WHEN ''reg_order'' THEN ARRAY[reg_order::int, NULL]
             WHEN ''class_order'' THEN ARRAY[class_order::int, NULL]
             WHEN ''medicine_type'' THEN ARRAY[medicine_type::int, NULL]
             WHEN ''cd'' THEN ARRAY[code_medi_order::int, NULL]
             WHEN ''timing_order'' THEN ARRAY[timing_order::int, NULL]
             WHEN ''proc_order'' THEN ARRAY[proc_order::int, NULL]
             WHEN ''date_interval'' THEN ARRAY[date_interval::int, NULL]
           END
           ORDER BY pm.ord
       ) AS sort_key
       FROM priority_medi pm
     ) s ON true
    GROUP BY
      ord_no,
      disp_order,
      treat_date,
      kind,
      NAME,
      Amount,
      Unit,
      receipt_value,
      receipt_unit,
      in_hospital_cd_1,
      in_hospital_cd_2,
      in_hospital_cd_3,
      in_hospital_cd_4,
      class_cd,
      cd,
      do_action,
      data_type_order,
      kind_order,
      goods_type,
      equipment_cd,
      equipment_class_cd,
      medicine_cd,
      medicine_class_cd,
      dialyzer_cd,
      reg_order,
      class_order,
      code_equ_order,
      code_dia_order,
      code_medi_order,
      medicine_type,
      timing_order,
      proc_order,
      date_interval,
      sort_key
    ORDER BY
      sort_key
  ) IND_MEDI_SORT

) AS EquipmentList
  LEFT JOIN goods_sort AS medic ON medic.code::TEXT = EquipmentList.medicine_class_cd AND medic.master_physical_name = ''mst_medicine_class''
	LEFT JOIN goods_sort AS equic ON equic.code::TEXT = EquipmentList.equipment_class_cd AND equic.master_physical_name = ''mst_equipment_class''
	LEFT JOIN goods_sort AS dia ON dia.code::TEXT = EquipmentList.dialyzer_cd AND dia.master_physical_name = ''mst_dialyzer'' 
GROUP BY
  disp_order,
  treat_date,
  kind,
  NAME,
  Unit,
  receipt_unit,
  in_hospital_cd_1,
  in_hospital_cd_2,
  in_hospital_cd_3,
  in_hospital_cd_4,
  class_cd,
  cd,
  do_action,
  data_type_order,
  kind_order,
  goods_type,
  dia_order,
	medic_order,
	equic_order,
  equipment_cd,
  equipment_class_cd,
  medicine_cd,
  medicine_class_cd,
  dialyzer_cd,
  reg_order,
  class_order,
  code_dia_order,
  code_equ_order,
  code_medi_order,
  medicine_type,
  timing_order,
  proc_order,
  date_interval,
  rn
HAVING
  SUM ( Amount ) > 0
ORDER BY
  disp_order,
	kind
) 

SELECT * from result_all as res @orderBy, rn', 2, '[{"preview": "テープ", "can_calc": "0", "data_code": "kind", "data_name": "分類名称", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "kind", "disp_format": "", "filter_type": "Goods", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70%ブドウ糖注射液350ml", "can_calc": "0", "data_code": "name", "data_name": "型番･名称", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "name", "disp_format": "", "filter_type": "Goods", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "1", "data_code": "amount", "data_name": "指示数量", "data_type": "decimal", "conv_table": [], "data_class": "物品情報", "field_name": "amount", "disp_format": "0.00", "filter_type": "Goods", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "個", "can_calc": "0", "data_code": "unit", "data_name": "指示単位", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "unit", "disp_format": "", "filter_type": "Goods", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "1", "data_code": "receipt_value", "data_name": "レせ数量", "data_type": "decimal", "conv_table": [], "data_class": "物品情報", "field_name": "receipt_value", "disp_format": "0.00", "filter_type": "Goods", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レせ個", "can_calc": "0", "data_code": "receipt_unit", "data_name": "レせ単位", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "receipt_unit", "disp_format": "", "filter_type": "Goods", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_1", "disp_format": "", "filter_type": "Goods", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_2", "disp_format": "", "filter_type": "Goods", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_3", "disp_format": "", "filter_type": "Goods", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_4", "data_name": "院内コード4", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_4", "disp_format": "", "filter_type": "Goods", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [4]}', '器材準備リスト', '2024-11-22 16:21:00', CURRENT_TIMESTAMP, NULL);
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
		-10 AS equip_class_cd,
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
		-10 AS equip_class_cd,
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
', 2, '[{"preview": "2011/3/12", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "医材", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "filter_type": "EquipDia", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "テスト穿刺針", "can_calc": "0", "data_code": "equip_name", "data_name": "医療材料名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_name", "disp_format": "", "filter_type": "EquipDia", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "穿刺針", "can_calc": "0", "data_code": "equip_class_name", "data_name": "医療材料分類名", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_class_name", "disp_format": "", "filter_type": "EquipDia", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "医材", "field_name": "amount", "disp_format": "0", "filter_type": "EquipDia", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "equip_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "equip_unit", "disp_format": "", "filter_type": "EquipDia", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_1", "data_name": "医療材料連携コード１", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_1", "disp_format": "", "filter_type": "EquipDia", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_2", "data_name": "医療材料連携コード２", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_2", "disp_format": "", "filter_type": "EquipDia", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_3", "data_name": "医療材料連携コード３", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_3", "disp_format": "", "filter_type": "EquipDia", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_equip_in_hospital_cd_4", "data_name": "医療材料連携コード４", "data_type": "string", "conv_table": [], "data_class": "医材", "field_name": "rst_equip_in_hospital_cd_4", "disp_format": "", "filter_type": "EquipDia", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：医材 @patIds @facilityCd @ordNos @diaIds @eqIds', '2020-03-31 23:59:59', CURRENT_TIMESTAMP, NULL);
