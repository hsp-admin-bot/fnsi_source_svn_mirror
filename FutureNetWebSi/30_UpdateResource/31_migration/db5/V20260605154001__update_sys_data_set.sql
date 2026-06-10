DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (9, 10, 11, 206, 207, 239, 242, 251, 252, 253, 254);
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
      COALESCE (save.class_cd , ''-1'') AS class_cd,
      save.supplies_cd AS cd,
      ''ダイアライザ'' AS do_action,
      ''医療材料'' AS data_type_order,
      2 AS kind_order,
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
        COALESCE (save.class_cd , ''-1'') AS class_cd,
        save.supplies_cd AS cd,
        ''ダイアライザ'' AS do_action,
        ''医療材料'' AS data_type_order,
        2 AS kind_order,
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

SELECT * from result_all as res @orderBy, rn', 2, '[{"preview": "テープ", "can_calc": "0", "data_code": "kind", "data_name": "分類名称", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "kind", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70%ブドウ糖注射液350ml", "can_calc": "0", "data_code": "name", "data_name": "型番･名称", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "name", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "1", "data_code": "amount", "data_name": "指示数量", "data_type": "decimal", "conv_table": [], "data_class": "物品情報", "field_name": "amount", "disp_format": "0.00", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "個", "can_calc": "0", "data_code": "unit", "data_name": "指示単位", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "unit", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "1", "data_code": "receipt_value", "data_name": "レせ数量", "data_type": "decimal", "conv_table": [], "data_class": "物品情報", "field_name": "receipt_value", "disp_format": "0.00", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レせ個", "can_calc": "0", "data_code": "receipt_unit", "data_name": "レせ単位", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "receipt_unit", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_1", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_2", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_3", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_4", "data_name": "院内コード4", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_4", "disp_format": "", "filter_type": "Equip", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [4]}', '器材準備リスト', '2024-11-22 16:21:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (10, 'WITH x AS (
	SELECT
		om.*,
		save.supplies_source_class,
		save.supplies_class,
		save.ind_rst_class,
		save.supplies_cd::int,
		save.receipt_value,
		save.ind_rst_value,
		save.medicine_mix_cd::int,
		save.receipt_unit,
		save.ind_unit,
		save.class_cd,
		NULLIF(save.medicine_no ->> ''no'','''')::numeric AS reg_order,
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
		om.ord_no IN ( @ordNos )
		AND om.is_del = ''0''
)
, goods_sort AS (
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
		AND master_physical_name IN (''mst_dialyzer'',''mst_equipment'',''mst_equipment_class'',''mst_medicine'',''mst_medicine_mix'',''mst_medicine_class'',''mst_medicate_timing'',''mst_procedure'')
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

SELECT
	pat_id as repeat_pat_id,
	ord_no as repeat_ord_no,
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
	SUM ( receipt_value ) AS receipt_value,
	receipt_unit,
	in_hospital_cd_1,
	in_hospital_cd_2,
	in_hospital_cd_3,
	in_hospital_cd_4,
	reg_order,
	class_order,
	code_medi_order,
	code_mix_order,
	code_equ_order,
	code_dia_order,
	medicine_type,
	timing_order,
	proc_order,
	date_interval,
	rn,
	pat_id AS pat_id_to_name
FROM
	(
  SELECT -- 透析条件（医材）
    disp_order,
    ord_no,
    treat_date,
    kur_cd,
    kur_name,
    bed_name,
    pat_id,
    class,
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
    NULL::int AS reg_order,
    NULL::int AS class_order,
    NULL::int AS code_medi_order,
    NULL::int AS code_mix_order,
    NULL::int AS code_equ_order,
    NULL::int AS code_dia_order,
    NULL::int AS medicine_type,
    NULL::int timing_order,
    NULL::int proc_order,
    NULL::int date_interval,
    NULL::int[] AS sort_key,
    NULL::int AS rn
  FROM
    (
      SELECT -- 透析条件（ダイアライザ）
        1 AS disp_order,
        x.ord_no,
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
        CAST(NULLIF(x.receipt_value, '''') AS DECIMAL) AS receipt_value,
        COALESCE ( x.receipt_unit, '''' ) AS receipt_unit,
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

      UNION ALL
      
      SELECT -- 透析条件(血液回路、吸着カラム、1次膜、2次膜、シングルニードル、穿刺針(A)、穿刺針(V))
        1 AS disp_order,
        x.ord_no,
        x.treat_date,
        x.kur_cd,
        x.kur_name,
        COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
        x.pat_id,
        CASE x.supplies_class
            WHEN ''02'' THEN ''吸着カラム''
            WHEN ''03'' THEN ''1次膜''
            WHEN ''04'' THEN ''2次膜''
            WHEN ''05'' THEN ''シングルニードル''
            WHEN ''06'' THEN ''穿刺針(A)''
            WHEN ''07'' THEN ''穿刺針(V)''
            WHEN ''00'' THEN ''血液回路''
        END AS class,
        COALESCE(eqc.class_name, ''未分類'') AS kind,
        eq.equipment_name AS NAME,
        CAST(NULLIF(x.ind_rst_value, '''') AS DECIMAL) AS Amount,
        COALESCE ( x.ind_unit, '''' ) AS Unit,
        CAST(NULLIF(x.receipt_value, '''') AS DECIMAL) AS receipt_value,
        COALESCE ( x.receipt_unit, '''' ) AS receipt_unit,
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
        AND x.supplies_class IN (''00'',''02'',''03'',''04'',''05'',''06'',''07'')
    ) COND_EQU
  
  UNION ALL
  
  SELECT -- 透析条件（薬剤）
    disp_order,
    ord_no,
    treat_date,
    kur_cd,
    kur_name,
    bed_name,
    pat_id,
    class,
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
    NULL::int AS reg_order,
    NULL::int AS class_order,
    NULL::int code_medi_order,
    NULL::int code_mix_order,
    NULL::int code_equ_order,
    NULL::int code_dia_order,
    NULL::int AS medicine_type,
    NULL::int timing_order,
    NULL::int proc_order,
    NULL::int date_interval,
    NULL::int[] AS sort_key,
    NULL::int AS rn
  FROM
    (
      SELECT -- 透析条件（透析液、補液、抗凝固剤)
        2 AS disp_order,
        x.ord_no,
        x.treat_date,
        x.kur_cd,
        x.kur_name,
        COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
        x.pat_id,
        CASE x.supplies_class
          WHEN ''10'' THEN ''抗凝固剤''
          WHEN ''08'' THEN ''透析液''
          WHEN ''09'' THEN ''補液''
        END AS class,
        COALESCE(mdc.class_name, ''未分類'') AS kind,
        md.medicine_name AS NAME,
        CAST(NULLIF(x.ind_rst_value, '''') AS DECIMAL) AS Amount,
        COALESCE ( x.ind_unit, '''' ) AS Unit,
        CAST(NULLIF(x.receipt_value, '''') AS DECIMAL) AS receipt_value,
        COALESCE ( x.receipt_unit, '''' ) AS receipt_unit,
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
        AND x.supplies_class IN (''08'',''09'',''10'')
      
      UNION ALL
      
      SELECT -- 透析条件（抗凝固剤_調製)
        2 AS disp_order,
        x.ord_no,
        x.treat_date,
        x.kur_cd,
        x.kur_name,
        COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
        x.pat_id,
        ''抗凝固剤'' as class,
        COALESCE(mdc.class_name, ''未分類'') AS kind,
        mdx.medicine_mix_name AS NAME,
        CAST(NULLIF(x.ind_rst_value, '''') AS DECIMAL) AS Amount,
        COALESCE ( x.ind_unit, '''' ) AS Unit,
        CAST(NULLIF(x.receipt_value, '''') AS DECIMAL) AS receipt_value,
        COALESCE ( x.receipt_unit, '''' ) AS receipt_unit,
        mdx.in_hospital_cd_1,
        mdx.in_hospital_cd_2,
        mdx.in_hospital_cd_3,
        NULL AS in_hospital_cd_4
      FROM
        x
        INNER JOIN mst_medicine_mix AS mdx ON mdx.medicine_mix_cd = x.medicine_mix_cd
  			AND mdx.class_cd IN ( @medIds )
        LEFT OUTER JOIN mst_medicine_class AS mdc ON ( mdx.class_cd = mdc.class_cd AND mdc.is_del = ''0'' AND mdc.is_disp = ''1'' )
      WHERE
        x.supplies_source_class = ''0''
        AND x.supplies_class = ''17''
    ) COND_MEDI
    
  UNION ALL
  
  SELECT
    *,
    ROW_NUMBER() OVER (ORDER BY sort_key) AS rn
  FROM
  (
    SELECT -- 投与薬剤
      disp_order,
      ord_no,
      treat_date,
      kur_cd,
      kur_name,
      bed_name,
      pat_id,
      class,
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
      reg_order,
      class_order,
      code_medi_order,
      code_mix_order,
      NULL::int code_equ_order,
      NULL::int code_dia_order,
      medicine_type,
      timing_order,
      proc_order,
      date_interval,
      s.sort_key
    FROM
      (
        SELECT -- 投与薬剤(通常薬剤)
          2 AS disp_order,
          x.ord_no,
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
          CAST(NULLIF(x.receipt_value, '''') AS DECIMAL) AS receipt_value,
          COALESCE ( x.receipt_unit, '''' ) AS receipt_unit,
          md.in_hospital_cd_1,
          md.in_hospital_cd_2,
          md.in_hospital_cd_3,
          md.in_hospital_cd_4,
          x.reg_order,
          gsmc.code_order AS class_order,
          1 AS medicine_type,
          gsm.code_order AS code_medi_order,
          NULL::int AS code_mix_order,
          NULL::int timing_order,
          NULL::int proc_order,
          NULL::int date_interval
        FROM
          x
          INNER JOIN mst_medicine AS md ON x.supplies_cd = md.medicine_cd
          AND md.is_del = ''0''
          AND md.is_disp = ''1''
    			AND md.class_cd IN ( @medIds )
          LEFT JOIN mst_medicine_class AS mdc ON ( md.class_cd = mdc.class_cd AND mdc.is_del = ''0'' AND mdc.is_disp = ''1'' )
          LEFT JOIN goods_sort AS gsm ON ( gsm.master_physical_name = ''mst_medicine'' AND gsm.code = x.supplies_cd::numeric )
          LEFT JOIN goods_sort AS gsmc ON ( gsmc.master_physical_name = ''mst_medicine_class'' AND gsmc.code = x.class_cd::numeric )
        WHERE
          x.supplies_source_class = ''1''
          AND x.supplies_class = ''12''
          
        UNION ALL
        
        SELECT  -- 投与薬剤(調製薬剤)
          2 AS disp_order,
          x.ord_no,
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
          CAST(NULLIF(x.receipt_value, '''') AS DECIMAL) AS receipt_value,
          COALESCE ( x.receipt_unit, '''' ) AS receipt_unit,
          md.in_hospital_cd_1,
          md.in_hospital_cd_2,
          md.in_hospital_cd_3,
          NULL AS in_hospital_cd_4,
          x.reg_order,
          gsmc.code_order AS class_order,
          2 AS medicine_type,
          NULL::int AS code_medi_order,
          gsx.code_order AS code_mix_order,
          NULL::int timing_order,
          NULL::int proc_order,
          NULL::int date_interval
        FROM
          x
          INNER JOIN mst_medicine_mix AS md ON ( x.medicine_mix_cd = md.medicine_mix_cd AND md.is_del = ''0'' AND md.is_disp = ''1'' AND md.class_cd IN ( @medIds ) )
          LEFT JOIN mst_medicine_class AS mdc ON ( md.class_cd = mdc.class_cd AND mdc.is_del = ''0'' AND mdc.is_disp = ''1'' )
          LEFT JOIN goods_sort AS gsx ON (gsx.master_physical_name = ''mst_medicine_mix'' AND gsx.code = x.medicine_mix_cd::numeric)
          LEFT JOIN goods_sort AS gsmc ON ( gsmc.master_physical_name = ''mst_medicine_class'' AND gsmc.code = x.class_cd::numeric )
        WHERE
          x.supplies_source_class = ''1''
          AND x.supplies_class = ''13''
      ) IND_MEDI
      LEFT JOIN LATERAL (
        SELECT array_agg (
          CASE pm.col
            WHEN ''reg_order'' THEN ARRAY[reg_order::int, NULL]
            WHEN ''class_order'' THEN ARRAY[class_order::int, NULL]
            WHEN ''medicine_type'' THEN ARRAY[medicine_type::int, NULL]
            WHEN ''cd'' THEN ARRAY[code_medi_order::int, code_mix_order::int]
            WHEN ''timing_order'' THEN ARRAY[timing_order::int, NULL]
            WHEN ''proc_order'' THEN ARRAY[proc_order::int, NULL]
            WHEN ''date_interval'' THEN ARRAY[date_interval::int, NULL]
           END
           ORDER BY pm.ord
       ) AS sort_key
       FROM priority_medi pm
     ) s ON true
    GROUP BY
      disp_order,
      ord_no,
      treat_date,
      kur_cd,
      kur_name,
      bed_name,
      pat_id,
      class,
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
      reg_order,
      class_order,
      code_medi_order,
      code_mix_order,
      medicine_type,
      timing_order,
      proc_order,
      date_interval,
      sort_key
    ORDER BY
      sort_key
  ) IND_MEDI_SORT 
  
  UNION ALL
  
  SELECT
    *,
    ROW_NUMBER() OVER (ORDER BY sort_key) AS rn
  FROM
  (
    SELECT -- 医療材料
      disp_order,
      ord_no,
      treat_date,
      kur_cd,
      kur_name,
      bed_name,
      pat_id,
      class,
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
      reg_order,
      class_order,
      NULL::int code_medi_order,
      NULL::int code_mix_order,
      code_equ_order,
      code_dia_order,
      NULL::int AS medicine_type,
      NULL::int timing_order,
      NULL::int proc_order,
      NULL::int date_interval,
      s.sort_key
    FROM
      (
        SELECT -- 医療材料(ダイアライザ)
          1 AS disp_order,
          x.ord_no,
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
          CAST(NULLIF(x.receipt_value, '''') AS DECIMAL) AS receipt_value,
          COALESCE ( x.receipt_unit, '''' ) AS receipt_unit,
          dz.in_hospital_cd_1,
          dz.in_hospital_cd_2,
          dz.in_hospital_cd_3,
          dz.in_hospital_cd_4,
          x.reg_order,
          NULL::int AS class_order,
          NULL::int AS code_equ_order,
          gsd.code_order AS code_dia_order
        FROM
          x
          INNER JOIN mst_dialyzer AS dz ON (x.supplies_cd_n = dz.dialyzer_cd AND dz.is_del = ''0'' AND dz.is_disp = ''1'' AND dz.dialyzer_cd IN ( @diaIds ) )
          LEFT JOIN goods_sort AS gsd ON (gsd.master_physical_name = ''mst_dialyzer'' AND gsd.code = x.supplies_cd::numeric)
        WHERE
          x.supplies_source_class = ''2''
          AND x.supplies_class = ''01''
          
        UNION ALL
        
        SELECT -- 医療材料(医材)
          1 AS disp_order,
          x.ord_no,
          x.treat_date,
          x.kur_cd,
          x.kur_name,
          COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
          x.pat_id,
          COALESCE(eqc.class_name, ''未分類'') AS class,
          COALESCE(eqc.class_name, ''未分類'') AS kind,
          eq.equipment_name AS NAME,
          CAST(NULLIF( x.ind_rst_value, '''') AS DECIMAL) AS Amount,
          COALESCE ( x.ind_unit, '''' ) AS Unit,
          CAST(NULLIF(x.receipt_value, '''') AS DECIMAL) AS receipt_value,
          COALESCE ( x.receipt_unit, '''' ) AS receipt_unit,
          eq.in_hospital_cd_1,
          eq.in_hospital_cd_2,
          eq.in_hospital_cd_3,
          eq.in_hospital_cd_4,
          x.reg_order,
          gsec.code_order AS class_order,
          gse.code_order AS code_equ_order,
          NULL::int AS code_dia_order
        FROM
          x
          INNER JOIN mst_equipment AS eq ON (x.supplies_cd_n = eq.equipment_cd AND eq.is_del = ''0'' AND eq.is_disp = ''1'' AND eq.class_cd IN ( @eqIds ) )
          LEFT JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'' )
          LEFT JOIN goods_sort AS gse ON (gse.master_physical_name = ''mst_equipment'' AND gse.code = x.supplies_cd::numeric)
          LEFT JOIN goods_sort AS gsec ON (gsec.master_physical_name = ''mst_equipment_class'' AND gsec.code = x.class_cd::numeric)
        WHERE
          x.supplies_source_class = ''2''
          AND x.supplies_class = ''11''
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
      disp_order,
      ord_no,
      treat_date,
      kur_cd,
      kur_name,
      bed_name,
      pat_id,
      class,
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
      reg_order,
      class_order,
      code_equ_order,
      code_dia_order,
      sort_key
    ORDER BY
      sort_key
  ) IND_EQU_SORT
  
) AS EquipmentList

GROUP BY
  ord_no,
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
  receipt_value,
  receipt_unit,
  in_hospital_cd_1,
  in_hospital_cd_2,
  in_hospital_cd_3,
  in_hospital_cd_4,
  reg_order,
  class_order,
  code_medi_order,
  code_mix_order,
  code_equ_order,
  code_dia_order,
  medicine_type,
  timing_order,
  proc_order,
  date_interval,
  rn
ORDER BY
  ARRAY_POSITION(ARRAY[@ordNos], ord_no),
  disp_order,
  rn,
  kur_cd,
  kur_name,
  bed_name,
  pat_id,
  disp_order,
  kind
', 2, '[{"preview": "1", "can_calc": "0", "data_code": "kur_cd", "data_name": "クールコード", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "kur_cd", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": ""}, {"preview": "午後", "can_calc": "0", "data_code": "kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "kur_name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": ""}, {"preview": "北1", "can_calc": "0", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "bed_name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": ""}, {"preview": "123456789012", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "hosp_pat_id", "target_var": "@patId"}, "data_code": "hosp_pat_id", "data_name": "患者ID", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "pat_id", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "テスト患者1", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_name", "target_var": "@patId"}, "data_code": "pat_id_to_name", "data_name": "患者名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "pat_id_to_name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "医材・薬剤", "can_calc": "0", "data_code": "kind", "data_name": "分類名称", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "kind", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "ダイアライザ", "can_calc": "0", "data_code": "class", "data_name": "治療条件名", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "class", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "テスト医材・薬剤1", "can_calc": "0", "data_code": "name", "data_name": "型番･名称", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "amount", "data_name": "指示数量", "data_type": "decimal", "conv_table": [], "data_class": "物品情報", "field_name": "amount", "disp_format": "0", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "個", "can_calc": "0", "data_code": "unit", "data_name": "指示単位", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "unit", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "receipt_value", "data_name": "レせ数量", "data_type": "decimal", "conv_table": [], "data_class": "物品情報", "field_name": "receipt_value", "disp_format": "0", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "レせ個", "can_calc": "0", "data_code": "receipt_unit", "data_name": "レせ単位", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "receipt_unit", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_1", "data_name": "院内コード", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_1", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_2", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_3", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_4", "data_name": "院内コード4", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "in_hospital_cd_4", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [5]}', '配布リスト(ベッド) 複数型 @ordNos', '2024-11-22 16:21:00', CURRENT_TIMESTAMP, NULL);
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
		save.class_cd,
		NULLIF(save.medicine_no ->> ''no'','''')::numeric AS reg_order,
		TO_NUMBER( save.supplies_cd, ''9999999999'' ) supplies_cd_n,
		kr.kur_cd,
		kr.kur_name,
		bd.bed_cd,
		bd.bed_name
	FROM
		ord_main AS om
		INNER JOIN ord_material_save AS save ON ( om.ord_no = save.supplies_base_no AND om.facility_cd = save.facility_cd AND save.ind_rst_class = ''1'' )
		LEFT JOIN mst_kur AS kr ON ( om.ind_kur_cd = kr.kur_cd AND kr.is_del = ''0'' )
		LEFT JOIN mst_bed AS bd ON ( om.ind_bed_cd = bd.bed_cd AND bd.is_del = ''0'' AND bd.is_disp = ''1'' )
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.is_del = ''0''
	),
dz AS ( SELECT * FROM mst_dialyzer WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' ),
kr AS ( SELECT * FROM mst_kur WHERE facility_cd = @facilityCd AND is_del = ''0'' ),
bd AS ( SELECT * FROM mst_bed WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' ),
eq AS ( SELECT * FROM mst_equipment WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' ),
eqc AS ( SELECT * FROM mst_equipment_class WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' ),
md AS ( SELECT * FROM mst_medicine WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' ),
mdx AS ( SELECT * FROM mst_medicine_mix WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' ),
mdc AS ( SELECT * FROM mst_medicine_class WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' )
, goods_sort AS (
	SELECT
		index_no AS code_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS cd,
		master_physical_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name IN (''mst_dialyzer'',''mst_equipment'',''mst_equipment_class'',''mst_medicine'',''mst_medicine_mix'',''mst_medicine_class'',''mst_bed'',''mst_medicate_timing'',''mst_procedure'')
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
		to_timestamp( treat_date, ''YYYYMMDD'' ) AS treat_date,
		disp_order,
		kind,
		class_cd,
		class,
		class_data_order,
		do_action,
		name,
		code,
		kur_cd,
		kur_name,
		Amount AS amount,
		unit,
		receipt_value,
		receipt_unit,
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
		dia.code_order AS dia_order,
		medic.code_order AS medic_order,
		equic.code_order AS equic_order,
		medi_mix.code_order AS medi_mix_order,
		bed.code_order AS bed_order,
		reg_order,
		class_order,
		medicine_type,
		code_medi_order,
		code_mix_order,
    code_equ_order,
		code_dia_order,
		timing_order,
		proc_order,
		date_interval,
		rn
	FROM
	(
		SELECT --治療条件:医材
			disp_order,
			treat_date,
			kur_cd,
			kur_name,
			bed_cd,
			bed_name,
			pat_id,
			class,
			class_data_order,
			kind,
			class_cd,
			do_action,
			name,
			code,
			Amount,
			unit,
			receipt_value,
			receipt_unit,
			in_hospital_cd_1,
			in_hospital_cd_2,
			in_hospital_cd_3,
			in_hospital_cd_4,
			data_type_order,
			kind_order,
			NULL::int AS medicine_cd,
			NULL::int AS medicine_mix_cd,
			NULL::int AS medicine_class_cd,
			equipment_cd,
			equipment_class_cd,
			dialyzer_cd,
			NULL::int AS reg_order,
			NULL::int AS class_order,
			NULL::int AS code_equ_order,
			NULL::int AS code_dia_order,
			NULL::int AS code_medi_order,
			NULL::int AS code_mix_order,
			NULL::int AS medicine_type,
			NULL::int AS timing_order,
			NULL::int AS proc_order,
			NULL::int AS date_interval,
			NULL::int[] AS sort_key,
			NULL::int AS rn
      
		FROM
		(
			SELECT --治療条件:ダイアライザ
        @equsort AS disp_order,
        save.supplies_base_date AS treat_date,
        save.kur_cd,
        COALESCE(save.kur_name, ''未登録'') AS kur_name,
        save.bed_cd,
        COALESCE(save.bed_name, ''未登録'') AS bed_name,
        save.pat_id,
        ''ダイアライザ'' AS class,
        1 AS class_data_order,
        CASE WHEN dz.model_number IS NOT NULL THEN ''ダイアライザ'' END AS kind,
        COALESCE(save.class_cd, ''-1'') AS class_cd,
        ''ダイアライザ'' AS do_action,
        dz.model_number AS name,
        TO_NUMBER(save.supplies_cd, ''99999999'') AS code,
        CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
        COALESCE(save.ind_unit, '''') AS unit,
        CAST(NULLIF(save.receipt_value, '''') AS DECIMAL) AS receipt_value,
        COALESCE(save.receipt_unit, '''') AS receipt_unit,
        dz.in_hospital_cd_1,
        dz.in_hospital_cd_2,
        dz.in_hospital_cd_3,
        dz.in_hospital_cd_4,
        NULL::int AS reg_order,
        ''医療材料'' AS data_type_order,
        2 AS kind_order,
        NULL::int AS equipment_cd,
        NULL::int AS equipment_class_cd,
        TO_NUMBER(save.supplies_cd, ''99999999'') AS dialyzer_cd
			FROM save
			INNER JOIN dz 
					ON TO_NUMBER(save.supplies_cd, ''99999999'') = dz.dialyzer_cd
	        AND dz.dialyzer_cd IN ( @diaIds )
			WHERE save.supplies_source_class = ''0''
				AND save.supplies_class = ''01''

			UNION ALL

			SELECT -- 血液回路、吸着カラム、1次膜、2次膜、シングルニードル、穿刺針(A)、穿刺針(V)
        @equsort AS disp_order,
        save.supplies_base_date AS treat_date,
        save.kur_cd,
        COALESCE(save.kur_name, ''未登録'') AS kur_name,
        save.bed_cd,
        COALESCE(save.bed_name, ''未登録'') AS bed_name,
        save.pat_id,

        CASE save.supplies_class
            WHEN ''02'' THEN ''吸着カラム''
            WHEN ''03'' THEN ''1次膜''
            WHEN ''04'' THEN ''2次膜''
            WHEN ''05'' THEN ''シングルニードル''
            WHEN ''06'' THEN ''穿刺針(A)''
            WHEN ''07'' THEN ''穿刺針(V)''
            WHEN ''00'' THEN ''血液回路''
        END AS class,

        CASE save.supplies_class
            WHEN ''02'' THEN 3
            WHEN ''03'' THEN 4
            WHEN ''04'' THEN 5
            WHEN ''05'' THEN 6
            WHEN ''06'' THEN 7
            WHEN ''07'' THEN 8
            WHEN ''00'' THEN 2
        END AS class_data_order,

        COALESCE(eqc.class_name, ''未分類'') AS kind,
        COALESCE(save.class_cd, ''-1'') AS class_cd,
        ''医材'' AS do_action,
        eq.equipment_name,
        TO_NUMBER(save.supplies_cd, ''99999999'') AS code,
        CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
        COALESCE(save.ind_unit, '''') AS unit,
        CAST(NULLIF(save.receipt_value, '''') AS DECIMAL) AS receipt_value,
        COALESCE(save.receipt_unit, '''') AS receipt_unit,
        eq.in_hospital_cd_1,
        eq.in_hospital_cd_2,
        eq.in_hospital_cd_3,
        eq.in_hospital_cd_4,
        NULL::int AS reg_order,
        ''医療材料'' AS data_type_order,
        1 AS kind_order,
        TO_NUMBER(save.supplies_cd, ''99999999'') AS equipment_cd,
        TO_NUMBER(save.class_cd, ''99999999'') AS equipment_class_cd,
        NULL::int AS dialyzer_cd
			FROM save
			INNER JOIN eq 
					ON TO_NUMBER(save.supplies_cd, ''99999999'') = eq.equipment_cd
	        AND TO_NUMBER(save.class_cd, ''99999999'') IN ( @eqIds )
			LEFT JOIN eqc 
					ON TO_NUMBER(save.class_cd, ''99999999'') = eqc.class_cd
			WHERE save.supplies_source_class = ''0''
				AND save.supplies_class IN (''00'',''02'',''03'',''04'',''05'',''06'',''07'')

		) CON_EQU
		
		UNION ALL
		
		SELECT --透析条件:薬剤
			disp_order,
			treat_date,
			kur_cd,
			kur_name,
			bed_cd,
			bed_name,
			pat_id,
			class,
			class_data_order,
			kind,
			class_cd,
			do_action,
			NAME,
			code,
			Amount,
			unit,
			receipt_value,
			receipt_unit,
			in_hospital_cd_1,
			in_hospital_cd_2,
			in_hospital_cd_3,
			in_hospital_cd_4,
			data_type_order,
			kind_order,
			medicine_cd,
			medicine_mix_cd,
			medicine_class_cd,
			NULL::int AS equipment_cd,
			NULL::int AS equipment_class_cd,
			NULL::int AS dialyzer_cd,
			NULL::int AS reg_order,
			NULL::int AS class_order,
			NULL::int AS code_equ_order,
			NULL::int AS code_dia_order,
			NULL::int AS code_medi_order,
			NULL::int AS code_mix_order,
			NULL::int AS medicine_type,
			NULL::int AS timing_order,
			NULL::int AS proc_order,
			NULL::int AS date_interval,
			NULL::int[] AS sort_key,
			NULL::int AS rn
		FROM
		(
			SELECT --透析条件:透析液、補液、抗凝固剤
				@medsort AS disp_order,
				save.supplies_base_date AS treat_date,
				save.kur_cd,
				COALESCE(save.kur_name, ''未登録'') AS kur_name,
				save.bed_cd,
				COALESCE(save.bed_name, ''未登録'') AS bed_name,
				save.pat_id,
				CASE save.supplies_class
						WHEN ''10'' THEN ''抗凝固剤''
						WHEN ''08'' THEN ''透析液''
						WHEN ''09'' THEN ''補液''
				END AS class,
				CASE save.supplies_class
						WHEN ''10'' THEN 9
						WHEN ''08'' THEN 10
						WHEN ''09'' THEN 11
				END AS class_data_order,
				COALESCE(mdc.class_name, ''未分類'') AS kind,
				COALESCE(save.class_cd, ''-1'') AS class_cd,
				''通常薬剤'' AS do_action,
				md.medicine_name AS NAME,
				TO_NUMBER(save.supplies_cd, ''99999999'') AS code,
				CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
				COALESCE(save.ind_unit, '''') AS unit,
				CAST(NULLIF(save.receipt_value, '''') AS DECIMAL) AS receipt_value,
				COALESCE(save.receipt_unit, '''') AS receipt_unit,
				md.in_hospital_cd_1,
				md.in_hospital_cd_2,
				md.in_hospital_cd_3,
				md.in_hospital_cd_4,
				NULL::int AS reg_order,
				''薬剤'' AS data_type_order,
				1 AS kind_order,
				TO_NUMBER(save.supplies_cd, ''99999999'') AS medicine_cd,
				NULL::int AS medicine_mix_cd,
				TO_NUMBER(save.class_cd, ''99999999'') AS medicine_class_cd
			FROM save
			INNER JOIN md 
					ON TO_NUMBER(save.supplies_cd, ''99999999'') = md.medicine_cd
	        AND TO_NUMBER(save.class_cd, ''99999999'') IN (@medIds)
			LEFT JOIN mdc 
					ON TO_NUMBER(save.class_cd, ''99999999'') = mdc.class_cd
			WHERE save.supplies_source_class = ''0''
				AND save.supplies_class IN (''10'',''08'',''09'')

			UNION ALL

			SELECT --透析条件:抗凝固剤(調製)
				@medsort AS disp_order,
				save.supplies_base_date AS treat_date,
				save.kur_cd,
				COALESCE(save.kur_name, ''未登録'') AS kur_name,
				save.bed_cd,
				COALESCE(save.bed_name, ''未登録'') AS bed_name,
				save.pat_id,
				''抗凝固剤'' AS class,
				9 AS class_data_order,
				COALESCE(mdc.class_name, ''未分類'') AS kind,
				COALESCE(save.class_cd, ''-1'') AS class_cd,
				''調製薬剤'' AS do_action,
				mdx.medicine_mix_name AS NAME,
				TO_NUMBER(save.supplies_cd, ''99999999'') AS code,
				CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
				COALESCE(save.ind_unit, '''') AS unit,
				CAST(NULLIF(save.receipt_value, '''') AS DECIMAL) AS receipt_value,
				COALESCE(save.receipt_unit, '''') AS receipt_unit,
				mdx.in_hospital_cd_1,
				mdx.in_hospital_cd_2,
				mdx.in_hospital_cd_3,
				NULL AS in_hospital_cd_4,
				NULL::int AS reg_order,
				''薬剤'' AS data_type_order,
				2 AS kind_order,
				NULL::int AS medicine_cd,
				TO_NUMBER(save.supplies_cd, ''99999999'') AS medicine_mix_cd,
				TO_NUMBER(save.class_cd, ''99999999'') AS medicine_class_cd
		FROM save
			INNER JOIN mdx 
					ON mdx.medicine_mix_cd = TO_NUMBER(save.medicine_mix_cd, ''999999999999'')
	        AND TO_NUMBER(save.class_cd, ''99999999'') IN ( @medIds )
			LEFT JOIN mdc 
					ON TO_NUMBER(save.class_cd, ''99999999'') = mdc.class_cd
			WHERE save.supplies_source_class = ''0''
				AND save.supplies_class = ''17''

		) CON_MEDI
		
		UNION ALL

		SELECT
			*,
			ROW_NUMBER() OVER (ORDER BY sort_key) AS rn
		FROM
		(
		SELECT --医療材料
			disp_order
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
			, SUM(equInfo.Amount) AS Amount
			, unit
			, SUM(equInfo.receipt_value) AS receipt_value
			, receipt_unit
			, in_hospital_cd_1
			, in_hospital_cd_2
			, in_hospital_cd_3
			, in_hospital_cd_4
			, ''医療材料'' AS data_type_order
			, 1 AS kind_order
			, NULL::int AS medicine_cd
			, NULL::int AS medicine_mix_cd
			, NULL::int AS medicine_class_cd
			, equipment_cd
			, equipment_class_cd
			, dialyzer_cd
			,	reg_order
			,	class_order
			,	code_equ_order
			,	code_dia_order
			,	NULL::int AS code_medi_order
			,	NULL::int AS code_mix_order
			,	NULL::int AS medicine_type
			,	NULL::int AS timing_order
			,	NULL::int AS proc_order
			,	NULL::int AS date_interval
			, s.sort_key
			
		FROM (
			SELECT --医療材料:医材
				@equsort AS disp_order,
				save.supplies_base_date as treat_date,
				save.kur_cd,
				COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
				save.bed_cd,
				COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
				save.pat_id,
				COALESCE ( eqc.class_name , ''未分類'' ) AS class,
				12 as class_data_order,
				COALESCE ( eqc.class_name , ''未分類'' ) AS kind,
				COALESCE ( save.class_cd , ''-1'' ) AS class_cd,
				eq.equipment_name AS NAME,
				TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
				CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
				COALESCE ( save.ind_unit, '''' ) AS unit,
				CAST(NULLIF(save.receipt_value, '''') AS DECIMAL) AS receipt_value,
				COALESCE ( save.receipt_unit, '''' ) AS receipt_unit,
				eq.in_hospital_cd_1,
				eq.in_hospital_cd_2,
				eq.in_hospital_cd_3,
				eq.in_hospital_cd_4,
				TO_NUMBER(save.supplies_cd, ''99999999'') AS equipment_cd,
				TO_NUMBER(save.class_cd, ''99999999'') AS equipment_class_cd,
				NULL::int AS dialyzer_cd,
				save.reg_order,
				equic.code_order AS class_order,
				equ_sort.code_order AS code_equ_order,
				NULL::int AS code_dia_order 
			FROM
				save
				INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = eq.equipment_cd
				AND TO_NUMBER(save.class_cd, ''99999999'') IN ( @eqIds )
				LEFT JOIN eqc ON TO_NUMBER(save.class_cd, ''99999999'') = eqc.class_cd
				LEFT JOIN goods_sort AS equic ON equic.cd = TO_NUMBER(save.class_cd, ''99999999'') AND equic.master_physical_name = ''mst_equipment_class''
				LEFT JOIN goods_sort AS equ_sort ON equ_sort.cd = TO_NUMBER(save.supplies_cd, ''99999999'') AND equ_sort.master_physical_name = ''mst_equipment''
			WHERE
				save.supplies_source_class = ''2''
				and save.supplies_class = ''11''
				
			UNION ALL
			
			SELECT --医療材料:ダイアライザ
				@equsort AS disp_order,
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
				COALESCE ( save.class_cd , ''-1'' ) AS class_cd,
				dz.model_number NAME,
				TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
				CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
				COALESCE ( save.ind_unit, '''' ) AS unit,
				CAST(NULLIF(save.receipt_value, '''') AS DECIMAL) AS receipt_value,
				COALESCE ( save.receipt_unit, '''' ) AS receipt_unit,
				dz.in_hospital_cd_1,
				dz.in_hospital_cd_2,
				dz.in_hospital_cd_3,
				dz.in_hospital_cd_4,
				NULL::int AS equipment_cd,
				NULL::int AS equipment_class_cd,
				TO_NUMBER(save.supplies_cd, ''99999999'') AS dialyzer_cd,
				save.reg_order,
				NULL::int AS class_order,
				NULL::int AS code_equ_order,
				dia_sort.code_order AS code_dia_order
			FROM
				save
				INNER JOIN dz ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = dz.dialyzer_cd
				LEFT JOIN goods_sort AS dia_sort ON dia_sort.cd = TO_NUMBER(save.supplies_cd, ''99999999'') AND dia_sort.master_physical_name = ''mst_dialyzer''
			  AND dz.dialyzer_cd IN ( @diaIds )
			WHERE
			save.supplies_source_class = ''2''
			and save.supplies_class = ''01''	
		) equInfo
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
			disp_order
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
			, do_action
			, NAME
			, code
			, Amount
			, unit
			, receipt_value
			, receipt_unit
			, in_hospital_cd_1
			, in_hospital_cd_2
			, in_hospital_cd_3
			, in_hospital_cd_4
			, data_type_order
			, kind_order
			, equipment_cd
			, equipment_class_cd
			, dialyzer_cd
			,	reg_order
			,	class_order
			,	code_equ_order
			,	code_dia_order
      ,	sort_key
		ORDER BY
			sort_key

		) IND_EQU
    
		UNION ALL
		
		SELECT
			*,
			ROW_NUMBER() OVER (ORDER BY sort_key) AS rn
		FROM 
		(
			SELECT --投与薬剤
				disp_order,
				treat_date,
				kur_cd,
				kur_name,
				bed_cd,
				bed_name,
				pat_id,
				class,
				class_data_order,
				kind,
				class_cd,
				do_action,
				NAME,
				code,
				SUM(Amount) AS Amount,
				unit,
				SUM(receipt_value) AS receipt_value,
				receipt_unit,
				in_hospital_cd_1,
				in_hospital_cd_2,
				in_hospital_cd_3,
				in_hospital_cd_4,
				''薬剤'' AS data_type_order,
				kind_order,
				medicine_cd,
				medicine_mix_cd,
				medicine_class_cd,
				NULL::int AS equipment_cd,
				NULL::int AS equipment_class_cd,
				NULL::int AS dialyzer_cd,
				reg_order,
				class_order,
				NULL::int AS code_equ_order,
				NULL::int AS code_dia_order,
				code_medi_order,
				code_mix_order,
				medicine_type,
				timing_order,
				proc_order,
				date_interval,
				s.sort_key
			FROM (

				SELECT -- 通常薬剤
					@medsort AS disp_order,
					save.supplies_base_date AS treat_date,
					save.kur_cd,
					COALESCE(save.kur_name, ''未登録'') AS kur_name,
					save.bed_cd,
					COALESCE(save.bed_name, ''未登録'') AS bed_name,
					save.pat_id,
					COALESCE(mdc.class_name, ''未分類'') AS class,
					13 AS class_data_order,
					COALESCE(mdc.class_name, ''未分類'') AS kind,
					COALESCE(save.class_cd, ''-1'') AS class_cd,
					''通常薬剤'' AS do_action,
					md.medicine_name AS NAME,
					TO_NUMBER(save.supplies_cd, ''99999999'') AS code,
					CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
					COALESCE(save.ind_unit, '''') AS unit,
					CAST(NULLIF(save.receipt_value, '''') AS DECIMAL) AS receipt_value,
					COALESCE(save.receipt_unit, '''') AS receipt_unit,
					md.in_hospital_cd_1,
					md.in_hospital_cd_2,
					md.in_hospital_cd_3,
					md.in_hospital_cd_4,
					1 AS kind_order,
					TO_NUMBER(save.supplies_cd, ''99999999'') AS medicine_cd,
					NULL::int AS medicine_mix_cd,
					TO_NUMBER(save.class_cd, ''99999999'') AS medicine_class_cd,
					save.reg_order,
					medic.code_order AS class_order,
					1 AS medicine_type,
					med_sort.code_order AS code_medi_order,
					NULL::int AS code_mix_order,
					NULL::int timing_order,
					NULL::int proc_order,
					NULL::int date_interval
				FROM save
				INNER JOIN md 
					ON TO_NUMBER(save.supplies_cd, ''99999999'') = md.medicine_cd
	        AND TO_NUMBER(save.class_cd, ''99999999'') IN (@medIds)
				LEFT JOIN mdc ON TO_NUMBER(save.class_cd, ''99999999'') = mdc.class_cd
				LEFT JOIN goods_sort AS medic ON medic.cd = TO_NUMBER(save.class_cd, ''99999999'') AND medic.master_physical_name = ''mst_medicine_class''
				LEFT JOIN goods_sort AS med_sort ON med_sort.cd = TO_NUMBER(save.supplies_cd, ''99999999'') AND med_sort.master_physical_name = ''mst_medicine''
				WHERE save.supplies_source_class = ''1''
					AND save.supplies_class = ''12''

				UNION ALL

				SELECT -- 調製薬剤
					@medsort AS disp_order,
					save.supplies_base_date AS treat_date,
					save.kur_cd,
					COALESCE(save.kur_name, ''未登録'') AS kur_name,
					save.bed_cd,
					COALESCE(save.bed_name, ''未登録'') AS bed_name,
					save.pat_id,
					COALESCE(mdc.class_name, ''未分類'') AS class_name,
					14 AS class_data_order,
					COALESCE(mdc.class_name, ''未分類'') AS class_name,
					COALESCE(save.class_cd, ''-1'') AS class_cd,
					''調製薬剤'' AS do_action,
					mdx.medicine_mix_name,
					TO_NUMBER(save.supplies_cd, ''99999999'') AS code,
					CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
					COALESCE(save.ind_unit, '''') AS unit,
					CAST(NULLIF(save.receipt_value, '''') AS DECIMAL) AS receipt_value,
					COALESCE(save.receipt_unit, '''') AS receipt_unit,
					mdx.in_hospital_cd_1,
					mdx.in_hospital_cd_2,
					mdx.in_hospital_cd_3,
					null as in_hospital_cd_4,
					2 AS kind_order,
					NULL::int AS medicine_cd,
					TO_NUMBER(save.supplies_cd, ''99999999'') AS medicine_mix_cd,
					TO_NUMBER(save.class_cd, ''99999999'') AS medicine_class_cd,
					save.reg_order,
					medic.code_order AS class_order,
					2 AS medicine_type,
					NULL::int AS code_medi_order,
					med_mix_sort.code_order AS code_mix_order,
					NULL::int timing_order,
					NULL::int proc_order,
					NULL::int date_interval
				FROM save
				INNER JOIN mdx 
						ON TO_NUMBER(save.medicine_mix_cd, ''99999999'') = mdx.medicine_mix_cd
	          AND TO_NUMBER(save.class_cd, ''99999999'') IN (@medIds)
				LEFT JOIN mdc ON TO_NUMBER(save.class_cd, ''99999999'') = mdc.class_cd
				LEFT JOIN goods_sort AS medic ON medic.cd = TO_NUMBER(save.class_cd, ''99999999'') AND medic.master_physical_name = ''mst_medicine_class'' 
				LEFT JOIN goods_sort AS med_mix_sort ON med_mix_sort.cd = TO_NUMBER(save.supplies_cd, ''99999999'') AND med_mix_sort.master_physical_name = ''mst_medicine_mix''
				WHERE save.supplies_source_class = ''1''
					AND save.supplies_class = ''13''

			) medInfo
        LEFT JOIN LATERAL (
          SELECT array_agg (
            CASE pm.col
              WHEN ''reg_order'' THEN ARRAY[reg_order::int, NULL]
              WHEN ''class_order'' THEN ARRAY[class_order::int, NULL]
              WHEN ''medicine_type'' THEN ARRAY[medicine_type::int, NULL]
              WHEN ''cd'' THEN ARRAY[code_medi_order::int, code_mix_order::int]
              WHEN ''timing_order'' THEN ARRAY[timing_order::int, NULL]
              WHEN ''proc_order'' THEN ARRAY[proc_order::int, NULL]
              WHEN ''date_interval'' THEN ARRAY[date_interval::int, NULL]
             END
             ORDER BY pm.ord
         ) AS sort_key
         FROM priority_medi pm
       ) s ON true
			GROUP BY
				disp_order,
				treat_date,
				kur_cd,
				kur_name,
				bed_cd,
				bed_name,
				pat_id,
				class,
				class_data_order,
				kind,
				class_cd,
				do_action,
				NAME,
				code,
				Amount,
				unit,
				receipt_value,
				receipt_unit,
				in_hospital_cd_1,
				in_hospital_cd_2,
				in_hospital_cd_3,
				in_hospital_cd_4,
				data_type_order,
				kind_order,
				medicine_cd,
				medicine_mix_cd,
				medicine_class_cd,
				reg_order,
				class_order,
				code_medi_order,
				code_mix_order,
				medicine_type,
				timing_order,
				proc_order,
				date_interval,
        sort_key
			ORDER BY
				sort_key
				
		) IND_MEDI
  
	) AS EquipmentList
		LEFT JOIN goods_sort AS medic ON medic.cd = EquipmentList.medicine_class_cd AND medic.master_physical_name = ''mst_medicine_class''
		LEFT JOIN goods_sort AS equic ON equic.cd = EquipmentList.equipment_class_cd AND equic.master_physical_name = ''mst_equipment_class''
		LEFT JOIN goods_sort AS dia ON dia.cd = EquipmentList.dialyzer_cd AND dia.master_physical_name = ''mst_dialyzer''
		LEFT JOIN goods_sort AS medi_mix ON medi_mix.cd = EquipmentList.medicine_class_cd AND medi_mix.master_physical_name = ''mst_medicine_mix''
		LEFT JOIN goods_sort AS bed ON bed.cd = EquipmentList.bed_cd AND bed.master_physical_name = ''mst_bed''
) 
SELECT * from result_all as res @orderBy, bed_order ASC, rn
', 2, '[{"preview": "1", "can_calc": "", "data_code": "kur_cd", "data_name": "クールコード", "data_type": "decimal", "conv_table": [], "data_class": "ベッド情報", "field_name": "kur_cd", "disp_format": "0", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": ""}, {"preview": "午後", "can_calc": "", "data_code": "kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "kur_name", "disp_format": "", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": ""}, {"preview": "北1", "can_calc": "", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "bed_name", "disp_format": "", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": ""}, {"preview": "テープ", "can_calc": "0", "data_code": "kind", "data_name": "分類名称", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "kind", "disp_format": "", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ダイアライザ", "can_calc": "0", "data_code": "class", "data_name": "治療条件名", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "class", "disp_format": "", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70%ブドウ糖注射液350ml", "can_calc": "0", "data_code": "name", "data_name": "型番･名称", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "name", "disp_format": "", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "1", "data_code": "amount", "data_name": "指示数量", "data_type": "decimal", "conv_table": [], "data_class": "物品情報", "field_name": "amount", "disp_format": "0.00", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "個", "can_calc": "0", "data_code": "unit", "data_name": "指示単位", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "unit", "disp_format": "", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "1", "data_code": "receipt_value", "data_name": "レせ数量", "data_type": "decimal", "conv_table": [], "data_class": "物品情報", "field_name": "receipt_value", "disp_format": "0.00", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レせ個", "can_calc": "0", "data_code": "receipt_unit", "data_name": "レせ単位", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "receipt_unit", "disp_format": "", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789012", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "hosp_pat_id", "target_var": "@patId"}, "data_code": "hosp_pat_id", "data_name": "患者ID", "data_type": "string", "conv_table": [], "data_class": "基本情報", "field_name": "pat_id", "disp_format": "", "data_category": "配布リスト(物品)", "facility_filter_type": "0"}, {"preview": "テスト患者1", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_name", "target_var": "@patId"}, "data_code": "pat_name", "data_name": "患者名", "data_type": "string", "conv_table": [], "data_class": "基本情報", "field_name": "pat_id1", "disp_format": "", "data_category": "配布リスト(物品)", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [6]}', '配布リスト(物品) 複数型 @facilityCd @ordNos', '2024-11-22 16:21:00', CURRENT_TIMESTAMP, NULL);
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
		save.receipt_unit,
		save.ind_unit,
		save.class_cd,
		NULLIF(save.medicine_no ->> ''no'','''')::numeric AS reg_order,
		TO_NUMBER( save.supplies_cd, ''9999999999'' ) supplies_cd_n,
		kr.kur_cd,
		kr.kur_name,
		bd.bed_cd,
		bd.bed_name
	FROM
		ord_main AS om
		INNER JOIN ord_material_save AS save ON ( om.ord_no = save.supplies_base_no AND om.facility_cd = save.facility_cd AND save.ind_rst_class = ''1'' )
		LEFT JOIN mst_kur AS kr ON ( om.ind_kur_cd = kr.kur_cd AND kr.is_del = ''0'' )
		LEFT JOIN mst_bed AS bd ON ( om.ind_bed_cd = bd.bed_cd AND bd.is_del = ''0'' AND bd.is_disp = ''1'' )
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.is_del = ''0''
	),
dz AS ( SELECT * FROM mst_dialyzer WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' ),
kr AS ( SELECT * FROM mst_kur WHERE facility_cd = @facilityCd AND is_del = ''0'' ),
bd AS ( SELECT * FROM mst_bed WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' ),
eq AS ( SELECT * FROM mst_equipment WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' ),
eqc AS ( SELECT * FROM mst_equipment_class WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' ),
md AS ( SELECT * FROM mst_medicine WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' ),
mdc AS ( SELECT * FROM mst_medicine_class WHERE facility_cd = @facilityCd AND is_del = ''0'' AND is_disp = ''1'' )
, goods_sort AS (
	SELECT
		index_no AS code_order,
		TO_NUMBER( order_cd ->> ''code'', ''999999999999'' ) AS cd,
		master_physical_name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> ''items'' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name IN (''mst_dialyzer'',''mst_equipment'',''mst_equipment_class'',''mst_medicine'',''mst_medicine_class'',''mst_bed'',''mst_medicate_timing'',''mst_procedure'')
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
		to_timestamp( treat_date, ''YYYYMMDD'' ) AS treat_date,
		disp_order,
		kind,
		class_cd,
		class,
		class_data_order,
		do_action,
		name,
		code,
		kur_cd,
		kur_name,
		Amount AS amount,
		unit,
		receipt_value,
		receipt_unit,
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
		dia.code_order AS dia_order,
		medic.code_order AS medic_order,
		equic.code_order AS equic_order,
		NULL AS medi_mix_order,
		bed.code_order AS bed_order,
		reg_order,
		class_order,
		medicine_type,
		code_medi_order,
    code_equ_order,
		code_dia_order,
		timing_order,
		proc_order,
		date_interval,
		rn
	FROM
	(
		SELECT --治療条件:医材
			disp_order,
			treat_date,
			kur_cd,
			kur_name,
			bed_cd,
			bed_name,
			pat_id,
			class,
			class_data_order,
			kind,
			class_cd,
			do_action,
			name,
			code,
			Amount,
			unit,
			receipt_value,
			receipt_unit,
			in_hospital_cd_1,
			in_hospital_cd_2,
			in_hospital_cd_3,
			in_hospital_cd_4,
			data_type_order,
			kind_order,
			NULL::int AS medicine_cd,
			NULL::int AS medicine_class_cd,
			equipment_cd,
			equipment_class_cd,
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
					@equsort AS disp_order,
					save.supplies_base_date AS treat_date,
					save.kur_cd,
					COALESCE(save.kur_name, ''未登録'') AS kur_name,
					save.bed_cd,
					COALESCE(save.bed_name, ''未登録'') AS bed_name,
					save.pat_id,
					''ダイアライザ'' AS class,
					1 AS class_data_order,
					CASE WHEN dz.model_number IS NOT NULL THEN ''ダイアライザ'' END AS kind,
					COALESCE(save.class_cd, ''-1'') AS class_cd,
					''ダイアライザ'' AS do_action,
					dz.model_number AS name,
					TO_NUMBER(save.supplies_cd, ''99999999'') AS code,
					CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
					COALESCE(save.ind_unit, '''') AS unit,
					CAST(NULLIF(save.receipt_value, '''') AS DECIMAL) AS receipt_value,
					COALESCE(save.receipt_unit, '''') AS receipt_unit,
					dz.in_hospital_cd_1,
					dz.in_hospital_cd_2,
					dz.in_hospital_cd_3,
					dz.in_hospital_cd_4,
					NULL::int AS reg_order,
					''医療材料'' AS data_type_order,
					2 AS kind_order,
					NULL::int AS equipment_cd,
					NULL::int AS equipment_class_cd,
					TO_NUMBER(save.supplies_cd, ''99999999'') AS dialyzer_cd
			FROM save
			INNER JOIN dz 
					ON TO_NUMBER(save.supplies_cd, ''99999999'') = dz.dialyzer_cd
	        AND dz.dialyzer_cd IN ( @diaIds )
			WHERE save.supplies_source_class = ''0''
				AND save.supplies_class = ''01''

			UNION ALL

			SELECT -- 血液回路、吸着カラム、1次膜、2次膜、シングルニードル、穿刺針(A)、穿刺針(V)
					@equsort AS disp_order,
					save.supplies_base_date AS treat_date,
					save.kur_cd,
					COALESCE(save.kur_name, ''未登録'') AS kur_name,
					save.bed_cd,
					COALESCE(save.bed_name, ''未登録'') AS bed_name,
					save.pat_id,

					CASE save.supplies_class
							WHEN ''02'' THEN ''吸着カラム''
							WHEN ''03'' THEN ''1次膜''
							WHEN ''04'' THEN ''2次膜''
							WHEN ''05'' THEN ''シングルニードル''
							WHEN ''06'' THEN ''穿刺針(A)''
							WHEN ''07'' THEN ''穿刺針(V)''
							WHEN ''00'' THEN ''血液回路''
					END AS class,

					CASE save.supplies_class
							WHEN ''02'' THEN 3
							WHEN ''03'' THEN 4
							WHEN ''04'' THEN 5
							WHEN ''05'' THEN 6
							WHEN ''06'' THEN 7
							WHEN ''07'' THEN 8
							WHEN ''00'' THEN 2
					END AS class_data_order,

					COALESCE(eqc.class_name, ''未分類'') AS kind,
					COALESCE(save.class_cd, ''-1'') AS class_cd,
					''医材'' AS do_action,
					eq.equipment_name,
					TO_NUMBER(save.supplies_cd, ''99999999'') AS code,
					CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
					COALESCE(save.ind_unit, '''') AS unit,
					CAST(NULLIF(save.receipt_value, '''') AS DECIMAL) AS receipt_value,
					COALESCE(save.receipt_unit, '''') AS receipt_unit,
					eq.in_hospital_cd_1,
					eq.in_hospital_cd_2,
					eq.in_hospital_cd_3,
					eq.in_hospital_cd_4,
					NULL::int AS reg_order,
					''医療材料'' AS data_type_order,
					1 AS kind_order,
					TO_NUMBER(save.supplies_cd, ''99999999'') AS equipment_cd,
					TO_NUMBER(save.class_cd, ''99999999'') AS equipment_class_cd,
					NULL::int AS dialyzer_cd
			FROM save
			INNER JOIN eq 
					ON TO_NUMBER(save.supplies_cd, ''99999999'') = eq.equipment_cd
	        AND eq.class_cd IN ( @eqIds )
			LEFT JOIN eqc 
					ON TO_NUMBER(save.class_cd, ''99999999'') = eqc.class_cd
			WHERE save.supplies_source_class = ''0''
				AND save.supplies_class IN (''00'',''02'',''03'',''04'',''05'',''06'',''07'')

		) CON_EQU
		
		UNION ALL
		
		SELECT --透析条件:薬剤
			disp_order,
			treat_date,
			kur_cd,
			kur_name,
			bed_cd,
			bed_name,
			pat_id,
			class,
			class_data_order,
			kind,
			class_cd,
			do_action,
			NAME,
			code,
			Amount,
			unit,
			receipt_value,
			receipt_unit,
			in_hospital_cd_1,
			in_hospital_cd_2,
			in_hospital_cd_3,
			in_hospital_cd_4,
			data_type_order,
			kind_order,
			medicine_cd,
			medicine_class_cd,
			NULL::int AS equipment_cd,
			NULL::int AS equipment_class_cd,
			NULL::int AS dialyzer_cd,
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
			SELECT --透析条件:透析液、補液、抗凝固剤
				@medsort AS disp_order,
				save.supplies_base_date AS treat_date,
				save.kur_cd,
				COALESCE(save.kur_name, ''未登録'') AS kur_name,
				save.bed_cd,
				COALESCE(save.bed_name, ''未登録'') AS bed_name,
				save.pat_id,
				CASE save.supplies_class
						WHEN ''22'' THEN ''抗凝固剤''
						WHEN ''10'' THEN ''抗凝固剤''
						WHEN ''08'' THEN ''透析液''
						WHEN ''09'' THEN ''補液''
				END AS class,
				CASE save.supplies_class
						WHEN ''22'' THEN 9
						WHEN ''10'' THEN 9
						WHEN ''08'' THEN 10
						WHEN ''09'' THEN 11
				END AS class_data_order,
				COALESCE(mdc.class_name, ''未分類'') AS kind,
				COALESCE(save.class_cd, ''-1'') AS class_cd,
				''通常薬剤'' AS do_action,
				md.medicine_name AS NAME,
				TO_NUMBER(save.supplies_cd, ''99999999'') AS code,
				CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
				COALESCE(save.ind_unit, '''') AS unit,
				CAST(NULLIF(save.receipt_value, '''') AS DECIMAL) AS receipt_value,
				COALESCE(save.receipt_unit, '''') AS receipt_unit,
				md.in_hospital_cd_1,
				md.in_hospital_cd_2,
				md.in_hospital_cd_3,
				md.in_hospital_cd_4,
				NULL::int AS reg_order,
				''薬剤'' AS data_type_order,
				1 AS kind_order,
				TO_NUMBER(save.supplies_cd, ''99999999'') AS medicine_cd,
				TO_NUMBER(save.class_cd, ''99999999'') AS medicine_class_cd
			FROM save
			INNER JOIN md 
					ON TO_NUMBER(save.supplies_cd, ''99999999'') = md.medicine_cd
	        AND md.class_cd IN (@medIds)
			LEFT JOIN mdc 
					ON TO_NUMBER(save.class_cd, ''99999999'') = mdc.class_cd
			WHERE save.supplies_source_class = ''0''
				AND save.supplies_class IN (''22'',''10'',''08'',''09'')

		) CON_MEDI
		
		UNION ALL

		SELECT
			*,
			ROW_NUMBER() OVER (ORDER BY sort_key) AS rn
		FROM
		(
		SELECT --医療材料
			disp_order
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
			, SUM(equInfo.Amount) AS Amount
			, unit
			, SUM(equInfo.receipt_value) AS receipt_value
			, receipt_unit
			, in_hospital_cd_1
			, in_hospital_cd_2
			, in_hospital_cd_3
			, in_hospital_cd_4
			, ''医療材料'' AS data_type_order
			, 1 AS kind_order
			, NULL::int AS medicine_cd
			, NULL::int AS medicine_class_cd
			, equipment_cd
			, equipment_class_cd
			, dialyzer_cd
			, reg_order
			, class_order
			, code_equ_order
			, code_dia_order
			, NULL::int AS code_medi_order
			, NULL::int AS medicine_type
			, NULL::int AS timing_order
			, NULL::int AS proc_order
			, NULL::int AS date_interval
			, s.sort_key
			
		FROM (
			SELECT --医療材料:医材
				@equsort AS disp_order,
				save.supplies_base_date as treat_date,
				save.kur_cd,
				COALESCE ( save.kur_name, ''未登録'' ) AS kur_name,
				save.bed_cd,
				COALESCE ( save.bed_name, ''未登録'' ) AS bed_name,
				save.pat_id,
				COALESCE ( eqc.class_name , ''未分類'' ) AS class,
				12 as class_data_order,
				COALESCE ( eqc.class_name , ''未分類'' ) AS kind,
				COALESCE ( save.class_cd , ''-1'' ) AS class_cd,
				eq.equipment_name AS NAME,
				TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
				CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
				COALESCE ( save.ind_unit, '''' ) AS unit,
				CAST(NULLIF(save.receipt_value, '''') AS DECIMAL) AS receipt_value,
				COALESCE ( save.receipt_unit, '''' ) AS receipt_unit,
				eq.in_hospital_cd_1,
				eq.in_hospital_cd_2,
				eq.in_hospital_cd_3,
				eq.in_hospital_cd_4,
				TO_NUMBER(save.supplies_cd, ''99999999'') AS equipment_cd,
				TO_NUMBER(save.class_cd, ''99999999'') AS equipment_class_cd,
				NULL::int AS dialyzer_cd,
				save.reg_order,
				equic.code_order AS class_order,
				equ_sort.code_order AS code_equ_order,
				NULL::int AS code_dia_order 
			FROM
				save
				INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = eq.equipment_cd
				AND eq.class_cd IN ( @eqIds )
				LEFT JOIN eqc ON TO_NUMBER(save.class_cd, ''99999999'') = eqc.class_cd
				LEFT JOIN goods_sort AS equic ON equic.cd = TO_NUMBER(save.class_cd, ''99999999'') AND equic.master_physical_name = ''mst_equipment_class''
				LEFT JOIN goods_sort AS equ_sort ON equ_sort.cd = TO_NUMBER(save.supplies_cd, ''99999999'') AND equ_sort.master_physical_name = ''mst_equipment''
			WHERE
				save.supplies_source_class = ''2''
				and save.supplies_class = ''11''
				
			UNION ALL
			
			SELECT --医療材料:ダイアライザ
				@equsort AS disp_order,
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
				COALESCE ( save.class_cd , ''-1'' ) AS class_cd,
				dz.model_number NAME,
				TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
				CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
				COALESCE ( save.ind_unit, '''' ) AS unit,
				CAST(NULLIF(save.receipt_value, '''') AS DECIMAL) AS receipt_value,
				COALESCE ( save.receipt_unit, '''' ) AS receipt_unit,
				dz.in_hospital_cd_1,
				dz.in_hospital_cd_2,
				dz.in_hospital_cd_3,
				dz.in_hospital_cd_4,
				NULL::int AS equipment_cd,
				NULL::int AS equipment_class_cd,
				TO_NUMBER(save.supplies_cd, ''99999999'') AS dialyzer_cd,
				save.reg_order,
				NULL::int AS class_order,
				NULL::int AS code_equ_order,
				dia_sort.code_order AS code_dia_order
			FROM
				save
				INNER JOIN dz ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = dz.dialyzer_cd
				LEFT JOIN goods_sort AS dia_sort ON dia_sort.cd = TO_NUMBER(save.supplies_cd, ''99999999'') AND dia_sort.master_physical_name = ''mst_dialyzer''
			  	AND dz.dialyzer_cd IN ( @diaIds )
			WHERE
			save.supplies_source_class = ''2''
			and save.supplies_class = ''01''	
		) equInfo
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
			disp_order
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
			, do_action
			, NAME
			, code
			, Amount
			, unit
			, receipt_value
			, receipt_unit
			, in_hospital_cd_1
			, in_hospital_cd_2
			, in_hospital_cd_3
			, in_hospital_cd_4
			, data_type_order
			, kind_order
			, equipment_cd
			, equipment_class_cd
			, dialyzer_cd
			, reg_order
			, class_order
			, code_equ_order
			, code_dia_order
			, sort_key
		ORDER BY
			sort_key

		) IND_EQU
		
		
		
		UNION ALL
		
		SELECT
			*,
			ROW_NUMBER() OVER (ORDER BY sort_key) AS rn
		FROM 
		(
			SELECT --投与薬剤
				disp_order,
				treat_date,
				kur_cd,
				kur_name,
				bed_cd,
				bed_name,
				pat_id,
				class,
				class_data_order,
				kind,
				class_cd,
				do_action,
				NAME,
				code,
				SUM(Amount) AS Amount,
				unit,
				SUM(receipt_value) AS receipt_value,
				receipt_unit,
				in_hospital_cd_1,
				in_hospital_cd_2,
				in_hospital_cd_3,
				in_hospital_cd_4,
				''薬剤'' AS data_type_order,
				kind_order,
				medicine_cd,
				medicine_class_cd,
				NULL::int AS equipment_cd,
				NULL::int AS equipment_class_cd,
				NULL::int AS dialyzer_cd,
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
			FROM (

				SELECT -- 通常薬剤
					@medsort AS disp_order,
					save.supplies_base_date AS treat_date,
					save.kur_cd,
					COALESCE(save.kur_name, ''未登録'') AS kur_name,
					save.bed_cd,
					COALESCE(save.bed_name, ''未登録'') AS bed_name,
					save.pat_id,
					COALESCE(mdc.class_name, ''未分類'') AS class,
					13 AS class_data_order,
					COALESCE(mdc.class_name, ''未分類'') AS kind,
					COALESCE(save.class_cd, ''-1'') AS class_cd,
					''通常薬剤'' AS do_action,
					md.medicine_name AS NAME,
					TO_NUMBER(save.supplies_cd, ''99999999'') AS code,
					CAST(NULLIF(save.ind_rst_value, '''') AS DECIMAL) AS Amount,
					COALESCE(save.ind_unit, '''') AS unit,
					CAST(NULLIF(save.receipt_value, '''') AS DECIMAL) AS receipt_value,
					COALESCE(save.receipt_unit, '''') AS receipt_unit,
					md.in_hospital_cd_1,
					md.in_hospital_cd_2,
					md.in_hospital_cd_3,
					md.in_hospital_cd_4,
					1 AS kind_order,
					TO_NUMBER(save.supplies_cd, ''99999999'') AS medicine_cd,
					TO_NUMBER(save.class_cd, ''99999999'') AS medicine_class_cd,
					save.reg_order,
					medic.code_order AS class_order,
					1 AS medicine_type,
					med_sort.code_order AS code_medi_order,
					NULL::int timing_order,
					NULL::int proc_order,
					NULL::int date_interval
				FROM save
				INNER JOIN md 
					ON TO_NUMBER(save.supplies_cd, ''99999999'') = md.medicine_cd
	        AND md.class_cd IN (@medIds)
				LEFT JOIN mdc ON TO_NUMBER(save.class_cd, ''99999999'') = mdc.class_cd
				LEFT JOIN goods_sort AS medic ON medic.cd = TO_NUMBER(save.class_cd, ''99999999'') AND medic.master_physical_name = ''mst_medicine_class''
				LEFT JOIN goods_sort AS med_sort ON med_sort.cd = TO_NUMBER(save.supplies_cd, ''99999999'') AND med_sort.master_physical_name = ''mst_medicine''
				WHERE save.supplies_source_class = ''1''
					AND save.supplies_class IN (''12'',''20'')

			) medInfo
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
				disp_order,
				treat_date,
				kur_cd,
				kur_name,
				bed_cd,
				bed_name,
				pat_id,
				class,
				class_data_order,
				kind,
				class_cd,
				do_action,
				NAME,
				code,
				Amount,
				unit,
				receipt_value,
				receipt_unit,
				in_hospital_cd_1,
				in_hospital_cd_2,
				in_hospital_cd_3,
				in_hospital_cd_4,
				data_type_order,
				kind_order,
				medicine_cd,
				medicine_class_cd,
				reg_order,
				class_order,
				code_medi_order,
				medicine_type,
				timing_order,
				proc_order,
				date_interval,
				sort_key
			ORDER BY
				sort_key
				
		) IND_MEDI
  
	) AS EquipmentList
		LEFT JOIN goods_sort AS medic ON medic.cd = EquipmentList.medicine_class_cd AND medic.master_physical_name = ''mst_medicine_class''
		LEFT JOIN goods_sort AS equic ON equic.cd = EquipmentList.equipment_class_cd AND equic.master_physical_name = ''mst_equipment_class''
		LEFT JOIN goods_sort AS dia ON dia.cd = EquipmentList.dialyzer_cd AND dia.master_physical_name = ''mst_dialyzer''
		LEFT JOIN goods_sort AS bed ON bed.cd = EquipmentList.bed_cd AND bed.master_physical_name = ''mst_bed''
	
) 
SELECT * from result_all as res @orderBy, bed_order ASC, rn
', 2, '[{"preview": "1", "can_calc": "", "data_code": "kur_cd", "data_name": "クールコード", "data_type": "decimal", "conv_table": [], "data_class": "ベッド情報(分解)", "field_name": "kur_cd", "disp_format": "0", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": ""}, {"preview": "午後", "can_calc": "", "data_code": "kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報(分解)", "field_name": "kur_name", "disp_format": "", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": ""}, {"preview": "北1", "can_calc": "", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報(分解)", "field_name": "bed_name", "disp_format": "", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": ""}, {"preview": "テープ", "can_calc": "0", "data_code": "kind", "data_name": "分類名称", "data_type": "string", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "kind", "disp_format": "", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ダイアライザ", "can_calc": "0", "data_code": "class", "data_name": "治療条件名", "data_type": "string", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "class", "disp_format": "", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70%ブドウ糖注射液350ml", "can_calc": "0", "data_code": "name", "data_name": "型番･名称", "data_type": "string", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "name", "disp_format": "", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "1", "data_code": "amount", "data_name": "指示数量", "data_type": "decimal", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "amount", "disp_format": "0.00", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "個", "can_calc": "0", "data_code": "unit", "data_name": "指示単位", "data_type": "string", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "unit", "disp_format": "", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "1", "data_code": "receipt_value", "data_name": "レせ数量", "data_type": "decimal", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "receipt_value", "disp_format": "0.00", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レせ個", "can_calc": "0", "data_code": "receipt_unit", "data_name": "レせ単位", "data_type": "string", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "receipt_unit", "disp_format": "", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789012", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "hosp_pat_id", "target_var": "@patId"}, "data_code": "hosp_pat_id", "data_name": "患者ID", "data_type": "string", "conv_table": [], "data_class": "基本情報(分解)", "field_name": "pat_id", "disp_format": "", "data_category": "配布リスト(物品)", "facility_filter_type": "0"}, {"preview": "テスト患者1", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_name", "target_var": "@patId"}, "data_code": "pat_name", "data_name": "患者名", "data_type": "string", "conv_table": [], "data_class": "基本情報(分解)", "field_name": "pat_id1", "disp_format": "", "data_category": "配布リスト(物品)", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [6]}', '配布リスト(物品)(分解) 複数型 @facilityCd @ordNos', '2020-01-11 13:28:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (207, 'WITH x AS (
	SELECT
		om.*,
		save.supplies_source_class,
		save.supplies_class,
		save.ind_rst_class,
		save.supplies_cd::int,
		save.receipt_value,
		save.ind_rst_value,
		save.medicine_mix_cd::int,
		save.receipt_unit,
		save.ind_unit,
		save.class_cd,
		NULLIF(save.medicine_no ->> ''no'','''')::numeric AS reg_order,
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
		om.ord_no IN ( @ordNos )
		AND om.is_del = ''0''
)
, goods_sort AS (
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
		AND master_physical_name IN (''mst_dialyzer'',''mst_equipment'',''mst_equipment_class'',''mst_medicine'',''mst_medicine_mix'',''mst_medicine_class'',''mst_medicate_timing'',''mst_procedure'')
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

SELECT
	pat_id as repeat_pat_id,
	ord_no as repeat_ord_no,
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
	SUM ( receipt_value ) AS receipt_value,
	receipt_unit,
	in_hospital_cd_1,
	in_hospital_cd_2,
	in_hospital_cd_3,
	in_hospital_cd_4,
	reg_order,
	class_order,
	code_medi_order,
	code_mix_order,
	code_equ_order,
	code_dia_order,
	medicine_type,
	timing_order,
	proc_order,
	date_interval,
	rn,
	pat_id AS pat_id_to_name
FROM
	(
  SELECT -- 透析条件（医材）
    disp_order,
    ord_no,
    treat_date,
    kur_cd,
    kur_name,
    bed_name,
    pat_id,
    class,
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
    NULL::int AS reg_order,
    NULL::int AS class_order,
    NULL::int AS code_medi_order,
    NULL::int AS code_mix_order,
    NULL::int AS code_equ_order,
    NULL::int AS code_dia_order,
    NULL::int AS medicine_type,
    NULL::int timing_order,
    NULL::int proc_order,
    NULL::int date_interval,
    NULL::int[] AS sort_key,
    NULL::int AS rn
  FROM
    (
      SELECT -- 透析条件（ダイアライザ）
        1 AS disp_order,
        x.ord_no,
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
        CAST(NULLIF(x.receipt_value, '''') AS DECIMAL) AS receipt_value,
        COALESCE ( x.receipt_unit, '''' ) AS receipt_unit,
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

      UNION ALL
      
      SELECT -- 透析条件(血液回路、吸着カラム、1次膜、2次膜、シングルニードル、穿刺針(A)、穿刺針(V))
        1 AS disp_order,
        x.ord_no,
        x.treat_date,
        x.kur_cd,
        x.kur_name,
        COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
        x.pat_id,
        CASE x.supplies_class
            WHEN ''02'' THEN ''吸着カラム''
            WHEN ''03'' THEN ''1次膜''
            WHEN ''04'' THEN ''2次膜''
            WHEN ''05'' THEN ''シングルニードル''
            WHEN ''06'' THEN ''穿刺針(A)''
            WHEN ''07'' THEN ''穿刺針(V)''
            WHEN ''00'' THEN ''血液回路''
        END AS class,
        COALESCE(eqc.class_name, ''未分類'') AS kind,
        eq.equipment_name AS NAME,
        CAST(NULLIF(x.ind_rst_value, '''') AS DECIMAL) AS Amount,
        COALESCE ( x.ind_unit, '''' ) AS Unit,
        CAST(NULLIF(x.receipt_value, '''') AS DECIMAL) AS receipt_value,
        COALESCE ( x.receipt_unit, '''' ) AS receipt_unit,
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
        AND x.supplies_class IN (''00'',''02'',''03'',''04'',''05'',''06'',''07'')
    ) COND_EQU
  
  UNION ALL
  
  SELECT -- 透析条件（薬剤）
    disp_order,
    ord_no,
    treat_date,
    kur_cd,
    kur_name,
    bed_name,
    pat_id,
    class,
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
    NULL::int AS reg_order,
    NULL::int AS class_order,
    NULL::int code_medi_order,
    NULL::int code_mix_order,
    NULL::int code_equ_order,
    NULL::int code_dia_order,
    NULL::int AS medicine_type,
    NULL::int timing_order,
    NULL::int proc_order,
    NULL::int date_interval,
    NULL::int[] AS sort_key,
    NULL::int AS rn
  FROM
    (
      SELECT -- 透析条件（透析液、補液、抗凝固剤)
        2 AS disp_order,
        x.ord_no,
        x.treat_date,
        x.kur_cd,
        x.kur_name,
        COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
        x.pat_id,
        CASE x.supplies_class
          WHEN ''22'' THEN ''抗凝固剤''
          WHEN ''10'' THEN ''抗凝固剤''
          WHEN ''08'' THEN ''透析液''
          WHEN ''09'' THEN ''補液''
        END AS class,
        COALESCE(mdc.class_name, ''未分類'') AS kind,
        md.medicine_name AS NAME,
        CAST(NULLIF(x.ind_rst_value, '''') AS DECIMAL) AS Amount,
        COALESCE ( x.ind_unit, '''' ) AS Unit,
        CAST(NULLIF(x.receipt_value, '''') AS DECIMAL) AS receipt_value,
        COALESCE ( x.receipt_unit, '''' ) AS receipt_unit,
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
        AND x.supplies_class IN (''08'',''09'',''10'',''22'')
    ) COND_MEDI
    
  UNION ALL
  
  SELECT
    *,
    ROW_NUMBER() OVER (ORDER BY sort_key) AS rn
  FROM
  (
    SELECT -- 投与薬剤
      disp_order,
      ord_no,
      treat_date,
      kur_cd,
      kur_name,
      bed_name,
      pat_id,
      class,
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
      reg_order,
      class_order,
      code_medi_order,
      code_mix_order,
      NULL::int code_equ_order,
      NULL::int code_dia_order,
      medicine_type,
      timing_order,
      proc_order,
      date_interval,
      s.sort_key
    FROM
      (
        SELECT -- 投与薬剤(通常薬剤、分解薬剤)
          2 AS disp_order,
          x.ord_no,
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
          CAST(NULLIF(x.receipt_value, '''') AS DECIMAL) AS receipt_value,
          COALESCE ( x.receipt_unit, '''' ) AS receipt_unit,
          md.in_hospital_cd_1,
          md.in_hospital_cd_2,
          md.in_hospital_cd_3,
          md.in_hospital_cd_4,
          x.reg_order,
          gsmc.code_order AS class_order,
          1 AS medicine_type,
          gsm.code_order AS code_medi_order,
          NULL::int AS code_mix_order,
          NULL::int timing_order,
          NULL::int proc_order,
          NULL::int date_interval
        FROM
          x
          INNER JOIN mst_medicine AS md ON x.supplies_cd = md.medicine_cd
          AND md.is_del = ''0''
          AND md.is_disp = ''1''
    			AND md.class_cd IN ( @medIds )
          LEFT JOIN mst_medicine_class AS mdc ON ( md.class_cd = mdc.class_cd AND mdc.is_del = ''0'' AND mdc.is_disp = ''1'' )
          LEFT JOIN goods_sort AS gsm ON ( gsm.master_physical_name = ''mst_medicine'' AND gsm.code = x.supplies_cd::numeric )
          LEFT JOIN goods_sort AS gsmc ON ( gsmc.master_physical_name = ''mst_medicine_class'' AND gsmc.code = x.class_cd::numeric )
        WHERE
          x.supplies_source_class = ''1''
          AND x.supplies_class IN (''12'',''20'')
      ) IND_MEDI
      LEFT JOIN LATERAL (
        SELECT array_agg (
          CASE pm.col
            WHEN ''reg_order'' THEN ARRAY[reg_order::int, NULL]
            WHEN ''class_order'' THEN ARRAY[class_order::int, NULL]
            WHEN ''medicine_type'' THEN ARRAY[medicine_type::int, NULL]
            WHEN ''cd'' THEN ARRAY[code_medi_order::int, code_mix_order::int]
            WHEN ''timing_order'' THEN ARRAY[timing_order::int, NULL]
            WHEN ''proc_order'' THEN ARRAY[proc_order::int, NULL]
            WHEN ''date_interval'' THEN ARRAY[date_interval::int, NULL]
           END
           ORDER BY pm.ord
       ) AS sort_key
       FROM priority_medi pm
     ) s ON true
    GROUP BY
      disp_order,
      ord_no,
      treat_date,
      kur_cd,
      kur_name,
      bed_name,
      pat_id,
      class,
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
      reg_order,
      class_order,
      code_medi_order,
      code_mix_order,
      medicine_type,
      timing_order,
      proc_order,
      date_interval,
      sort_key
    ORDER BY
      sort_key
  ) IND_MEDI_SORT 
  
  UNION ALL
  
  SELECT
    *,
    ROW_NUMBER() OVER (ORDER BY sort_key) AS rn
  FROM
  (
    SELECT -- 医療材料
      disp_order,
      ord_no,
      treat_date,
      kur_cd,
      kur_name,
      bed_name,
      pat_id,
      class,
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
      reg_order,
      class_order,
      NULL::int code_medi_order,
      NULL::int code_mix_order,
      code_equ_order,
      code_dia_order,
      NULL::int AS medicine_type,
      NULL::int timing_order,
      NULL::int proc_order,
      NULL::int date_interval,
      s.sort_key
    FROM
      (
        SELECT -- 医療材料(ダイアライザ)
          1 AS disp_order,
          x.ord_no,
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
          CAST(NULLIF(x.receipt_value, '''') AS DECIMAL) AS receipt_value,
          COALESCE ( x.receipt_unit, '''' ) AS receipt_unit,
          dz.in_hospital_cd_1,
          dz.in_hospital_cd_2,
          dz.in_hospital_cd_3,
          dz.in_hospital_cd_4,
          x.reg_order,
          NULL::int AS class_order,
          NULL::int AS code_equ_order,
          gsd.code_order AS code_dia_order
        FROM
          x
          INNER JOIN mst_dialyzer AS dz ON (x.supplies_cd_n = dz.dialyzer_cd AND dz.is_del = ''0'' AND dz.is_disp = ''1'' AND dz.dialyzer_cd IN ( @diaIds ) )
          LEFT JOIN goods_sort AS gsd ON (gsd.master_physical_name = ''mst_dialyzer'' AND gsd.code = x.supplies_cd::numeric)
        WHERE
          x.supplies_source_class = ''2''
          AND x.supplies_class = ''01''
          
        UNION ALL
        
        SELECT -- 医療材料(医材)
          1 AS disp_order,
          x.ord_no,
          x.treat_date,
          x.kur_cd,
          x.kur_name,
          COALESCE ( x.bed_name, ''未登録'' ) AS bed_name,
          x.pat_id,
          COALESCE(eqc.class_name, ''未分類'') AS class,
          COALESCE(eqc.class_name, ''未分類'') AS kind,
          eq.equipment_name AS NAME,
          CAST(NULLIF( x.ind_rst_value, '''') AS DECIMAL) AS Amount,
          COALESCE ( x.ind_unit, '''' ) AS Unit,
          CAST(NULLIF(x.receipt_value, '''') AS DECIMAL) AS receipt_value,
          COALESCE ( x.receipt_unit, '''' ) AS receipt_unit,
          eq.in_hospital_cd_1,
          eq.in_hospital_cd_2,
          eq.in_hospital_cd_3,
          eq.in_hospital_cd_4,
          x.reg_order,
          gsec.code_order AS class_order,
          gse.code_order AS code_equ_order,
          NULL::int AS code_dia_order
        FROM
          x
          INNER JOIN mst_equipment AS eq ON (x.supplies_cd_n = eq.equipment_cd AND eq.is_del = ''0'' AND eq.is_disp = ''1'' AND eq.class_cd IN ( @eqIds ) )
          LEFT JOIN mst_equipment_class AS eqc ON ( eq.class_cd = eqc.class_cd AND eqc.is_del = ''0'' AND eqc.is_disp = ''1'' )
          LEFT JOIN goods_sort AS gse ON (gse.master_physical_name = ''mst_equipment'' AND gse.code = x.supplies_cd::numeric)
          LEFT JOIN goods_sort AS gsec ON (gsec.master_physical_name = ''mst_equipment_class'' AND gsec.code = x.class_cd::numeric)
        WHERE
          x.supplies_source_class = ''2''
          AND x.supplies_class = ''11''
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
      disp_order,
      ord_no,
      treat_date,
      kur_cd,
      kur_name,
      bed_name,
      pat_id,
      class,
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
      reg_order,
      class_order,
      code_equ_order,
      code_dia_order,
      sort_key
    ORDER BY
      sort_key
  ) IND_EQU_SORT
  
) AS EquipmentList

GROUP BY
  ord_no,
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
  receipt_value,
  receipt_unit,
  in_hospital_cd_1,
  in_hospital_cd_2,
  in_hospital_cd_3,
  in_hospital_cd_4,
  reg_order,
  class_order,
  code_medi_order,
  code_mix_order,
  code_equ_order,
  code_dia_order,
  medicine_type,
  timing_order,
  proc_order,
  date_interval,
  rn
ORDER BY
  ARRAY_POSITION(ARRAY[@ordNos], ord_no),
  disp_order,
  rn,
  kur_cd,
  kur_name,
  bed_name,
  pat_id,
  disp_order,
  kind
', 2, '[{"preview": "1", "can_calc": "0", "data_code": "kur_cd", "data_name": "クールコード", "data_type": "string", "conv_table": [], "data_class": "ベッド情報(分解)", "field_name": "kur_cd", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": ""}, {"preview": "午後", "can_calc": "0", "data_code": "kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報(分解)", "field_name": "kur_name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": ""}, {"preview": "北1", "can_calc": "0", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報(分解)", "field_name": "bed_name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": ""}, {"preview": "123456789012", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "hosp_pat_id", "target_var": "@patId"}, "data_code": "hosp_pat_id", "data_name": "患者ID", "data_type": "string", "conv_table": [], "data_class": "ベッド情報(分解)", "field_name": "pat_id", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "テスト患者1", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_name", "target_var": "@patId"}, "data_code": "pat_id_to_name", "data_name": "患者名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報(分解)", "field_name": "pat_id_to_name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "医材・薬剤", "can_calc": "0", "data_code": "kind", "data_name": "分類名称", "data_type": "string", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "kind", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "ダイアライザ", "can_calc": "0", "data_code": "class", "data_name": "治療条件名", "data_type": "string", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "class", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "テスト医材・薬剤1", "can_calc": "0", "data_code": "name", "data_name": "型番･名称", "data_type": "string", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "name", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "amount", "data_name": "指示数量", "data_type": "decimal", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "amount", "disp_format": "0", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "個", "can_calc": "0", "data_code": "unit", "data_name": "指示単位", "data_type": "string", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "unit", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "1", "data_code": "receipt_value", "data_name": "レせ数量", "data_type": "decimal", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "receipt_value", "disp_format": "0", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "レせ個", "can_calc": "0", "data_code": "receipt_unit", "data_name": "レせ単位", "data_type": "string", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "receipt_unit", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_1", "data_name": "院内コード", "data_type": "string", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "in_hospital_cd_1", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "in_hospital_cd_2", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "in_hospital_cd_3", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}, {"preview": "01234567890123456789", "can_calc": "0", "data_code": "in_hospital_cd_4", "data_name": "院内コード4", "data_type": "string", "conv_table": [], "data_class": "物品情報(分解)", "field_name": "in_hospital_cd_4", "disp_format": "", "data_category": "配布リスト(ベッド)", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [5]}', '配布リスト(ベッド)(分解) 複数型 @ordNos', '2020-01-11 13:28:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (239, 'with ordMS_tbl AS (
	SELECT
		facility_cd
		, ord_material_save_no
		, supplies_base_no
		, supplies_source_class
		, ind_rst_class
		, supplies_class
		, CAST(class_cd AS INTEGER)
		, CAST(supplies_cd AS INTEGER)
		, receipt_value
		, receipt_unit
		, CAST(timing_cd AS INTEGER)
		, CAST(procedure_cd AS INTEGER)
		, medicine_no ->> ''no'' AS reg_order
		, reg_date
		, effect_flg
	FROM 
		ord_material_save
	WHERE 
		facility_cd = @facilityCd
		AND supplies_base_no = @ordNo
		AND supplies_source_class in (''0'', ''1'', ''2'', ''3'')
		AND ind_rst_class = ''2''
), 
dia_tbl AS (
	SELECT
		dialyzer_cd
		, model_number
		, maker
		, area
		, function_class
		, sterilization
		, in_hospital_cd_1
		, in_hospital_cd_2
		, in_hospital_cd_3
		, in_hospital_cd_4
	FROM 
		mst_dialyzer
	WHERE 
		facility_cd = @facilityCd
		--AND is_del = ''0'' 
		--AND is_disp = ''1''
),
dia_sort AS(
	SELECT
		index_no AS code_order,
		TO_NUMBER(info ->> ''code'', ''999999999999'') AS code,
		info ->> ''name'' AS name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements (order_settings -> ''items'') WITH ORDINALITY AS tmp (info, index_no)
	WHERE
		facility_cd = ''NKKSBR''
		AND master_physical_name = ''mst_dialyzer''
),
equ_tbl AS (
	SELECT
		equipment_cd
		, equipment_name
		, class_cd
		, in_hospital_cd_1
		, in_hospital_cd_2
		, in_hospital_cd_3
		, in_hospital_cd_4
	FROM 
		mst_equipment
	WHERE 
		facility_cd = @facilityCd
		--AND is_del = ''0'' 
		--AND is_disp = ''1''
),
equ_class_tbl AS (
	SELECT
		class_cd
		, class_name
	FROM 
		mst_equipment_class
	WHERE 
		facility_cd = @facilityCd
		--AND is_del = ''0'' 
		--AND is_disp = ''1''
),
equ_sort AS(
	SELECT
		index_no AS code_order,
		TO_NUMBER(info ->> ''code'', ''999999999999'') AS code,
		info ->> ''name'' AS name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements (order_settings -> ''items'') WITH ORDINALITY AS tmp (info, index_no)
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_equipment''
),
equ_class_sort AS(
	SELECT
		index_no AS class_order,
		TO_NUMBER(info ->> ''code'', ''999999999999'') AS code,
		info ->> ''name'' AS name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements (order_settings -> ''items'') WITH ORDINALITY AS tmp (info, index_no)
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_equipment_class''
),
med_tbl AS (
	SELECT
		medicine_cd
		, medicine_name
		, class_cd
		, in_hospital_cd_1
		, in_hospital_cd_2
		, in_hospital_cd_3
		, in_hospital_cd_4
	FROM 
		mst_medicine
	WHERE 
		facility_cd = @facilityCd
		--AND is_del = ''0'' 
		--AND is_disp = ''1''
),
med_class_tbl AS (
	SELECT
		class_cd
		, class_name
	FROM 
		mst_medicine_class
	WHERE 
		facility_cd = @facilityCd
		--AND is_del = ''0'' 
		--AND is_disp = ''1''
),
Antico_mix_sort AS (
	SELECT 
		index_no AS reg_order,
		TO_NUMBER(info ->> ''cd'', ''999999999999'') AS code
	FROM
		mst_medicine_mix
		CROSS JOIN LATERAL jsonb_array_elements (mix_info) WITH ORDINALITY AS tmp (info, index_no)
	WHERE
		facility_cd = @facilityCd
		AND medicine_mix_cd = (SELECT supplies_cd FROM ordMS_tbl WHERE supplies_class = ''17'')
),
med_sort AS (
	SELECT
		index_no AS code_order,
		TO_NUMBER(info ->> ''code'', ''999999999999'') AS code,
		info ->> ''name'' AS name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements (order_settings -> ''items'') WITH ORDINALITY AS tmp (info, index_no)
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicine''
),
med_mix_sort AS (
	SELECT
		index_no AS code_mix_order,
		TO_NUMBER(info ->> ''code'', ''999999999999'') AS code,
		info ->> ''name'' AS name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements (order_settings -> ''items'') WITH ORDINALITY AS tmp (info, index_no)
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicine_mix''
),
med_class_sort AS (
	SELECT
		index_no AS class_order,
		TO_NUMBER(info ->> ''code'', ''999999999999'') AS code,
		info ->> ''name'' AS name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements (order_settings -> ''items'') WITH ORDINALITY AS tmp (info, index_no)
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicine_class''
),
med_timing_sort AS (
	SELECT
		index_no AS timing_order,
		TO_NUMBER(info ->> ''code'', ''999999999999'') AS code,
		info ->> ''name'' AS name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements (order_settings -> ''items'') WITH ORDINALITY AS tmp (info, index_no)
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_medicate_timing''
),
proc_sort AS (
	SELECT
		index_no AS proc_order,
		TO_NUMBER(info ->> ''code'', ''999999999999'') AS code,
		info ->> ''name'' AS name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements (order_settings -> ''items'') WITH ORDINALITY AS tmp (info, index_no)
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_procedure''
),
diff_info AS (
	SELECT 
		item->>''dial_diff_cd'' AS dial_diff_cd
		, item->>''pat_dial_diff_name'' AS dial_diff_name
		, item->>''pat_in_hospital_cd_1'' AS in_hospital_cd_1
		, item->>''pat_in_hospital_cd_2'' AS in_hospital_cd_2
	FROM 
		jsonb_array_elements(COALESCE(NULLIF(@dialDiffComInfo, ''''), ''[]'') :: JSONB) AS item
),
addi_sort AS (
	SELECT
		index_no AS code_order,
		TO_NUMBER(info ->> ''code'', ''999999999999'') AS code,
		info ->> ''name'' AS name
	FROM
		mst_selector
		CROSS JOIN LATERAL jsonb_array_elements (order_settings -> ''items'') WITH ORDINALITY AS tmp (info, index_no)
	WHERE
		facility_cd = @facilityCd
		AND master_physical_name = ''mst_addition''
),
addi_info AS (
	SELECT
		om.ord_no
		, json_idx
		, addi.addition_cd
		, addi.addition_name
		, addi.in_hospital_cd_1
		, addi.in_hospital_cd_2
		, addi.in_hospital_cd_3
	FROM
		ord_main AS om
		CROSS JOIN LATERAL jsonb_array_elements (om.addition_info) WITH ORDINALITY AS tmp (info, json_idx)
		LEFT JOIN mst_addition as addi ON addi.addition_cd = CAST(info ->> ''cd'' AS INTEGER)
		LEFT JOIN addi_sort ads ON ads.code = CAST(info ->> ''cd'' AS INTEGER)
	WHERE
		om.is_del = ''0''
		AND om.facility_cd = @facilityCd
		AND ord_no = @ordNo
		--AND addi.is_del = ''0''
		--AND addi.is_disp = ''1''
	ORDER BY ads.code_order ASC
),
sort_rule AS (
     SELECT
        j.value AS receipt_kind_cd,
        j.ordinality AS sort_no
     FROM mst_facility_setting s
     CROSS JOIN LATERAL json_array_elements_text(s.value::json)
          WITH ORDINALITY AS j(value, ordinality)
     WHERE s.facility_setting_no = ''3143''
       AND s.facility_cd = @facilityCd
),
union_data AS (
select * from (

(SELECT
  *
from
(SELECT
	supplies_base_no AS ord_no
  	, ROW_NUMBER() OVER () AS seq_no
	, CAST(CAST(supplies_class AS INTEGER) AS VARCHAR) AS receipt_class_cd
	, ''ダイアライザ'' AS receipt_class
	, ''1'' AS receipt_kind_cd
	, ''ダイアライザ'' AS receipt_kind
	, oms.supplies_cd AS receipt_cd
	, dia.model_number AS receipt_name
	, oms.receipt_value AS receipt_amount
	, receipt_unit
	, dia.in_hospital_cd_1
	, dia.in_hospital_cd_2
	, dia.in_hospital_cd_3
	, dia.in_hospital_cd_4
	, ''1'' AS ord_by_key
FROM
	ordMS_tbl AS oms
	LEFT JOIN dia_tbl AS dia ON oms.supplies_cd = dia.dialyzer_cd
WHERE
	oms.supplies_class = ''01''
	AND supplies_source_class = ''0''
UNION ALL
SELECT
	supplies_base_no AS ord_no
	, ROW_NUMBER() OVER () AS seq_no
	, CAST(CAST(supplies_class AS INTEGER) AS VARCHAR) AS receipt_class_cd
	, ''ダイアライザ'' AS receipt_class
	, ''2'' AS receipt_kind_cd
	, ''メーカ'' AS receipt_kind
	, oms.supplies_cd AS receipt_cd
	, dia.maker AS receipt_name
	, NULL AS receipt_amount
	, NULL AS receipt_unit
	, NULL AS in_hospital_cd_1
	, NULL AS in_hospital_cd_2
	, NULL AS in_hospital_cd_3
	, NULL AS in_hospital_cd_4
	, ''1'' AS ord_by_key
FROM
	ordMS_tbl AS oms
	LEFT JOIN dia_tbl AS dia ON oms.supplies_cd = dia.dialyzer_cd
WHERE
	oms.supplies_class = ''01''
	AND supplies_source_class = ''0''
UNION ALL
SELECT
	supplies_base_no AS ord_no
	, ROW_NUMBER() OVER () AS seq_no
	, CAST(CAST(supplies_class AS INTEGER) AS VARCHAR) AS receipt_class_cd
	, ''ダイアライザ'' AS receipt_class
	, ''3'' AS receipt_kind_cd
	, ''面積'' AS receipt_kind
	, oms.supplies_cd AS receipt_cd
	, CAST(dia.area AS VARCHAR) AS receipt_name
	, NULL AS receipt_amount
	, NULL AS receipt_unit
	, NULL AS in_hospital_cd_1
	, NULL AS in_hospital_cd_2
	, NULL AS in_hospital_cd_3
	, NULL AS in_hospital_cd_4
	, ''1'' AS ord_by_key
FROM
	ordMS_tbl AS oms
	LEFT JOIN dia_tbl AS dia ON oms.supplies_cd = dia.dialyzer_cd
WHERE
	oms.supplies_class = ''01''
	AND supplies_source_class = ''0''
UNION ALL
SELECT
	supplies_base_no AS ord_no
	, ROW_NUMBER() OVER () AS seq_no
	, CAST(CAST(supplies_class AS INTEGER) AS VARCHAR) AS receipt_class_cd
	, ''ダイアライザ'' AS receipt_class
	, ''4'' AS receipt_kind_cd
	, ''機能分類'' AS receipt_kind
	, oms.supplies_cd AS receipt_cd
	, dia.function_class AS receipt_name
	, NULL AS receipt_amount
	, NULL AS receipt_unit
	, NULL AS in_hospital_cd_1
	, NULL AS in_hospital_cd_2
	, NULL AS in_hospital_cd_3
	, NULL AS in_hospital_cd_4
	, ''1'' AS ord_by_key
FROM
	ordMS_tbl AS oms
	LEFT JOIN dia_tbl AS dia ON oms.supplies_cd = dia.dialyzer_cd
WHERE
	oms.supplies_class = ''01''
	AND supplies_source_class = ''0''
UNION ALL
SELECT
	supplies_base_no AS ord_no
	, ROW_NUMBER() OVER () AS seq_no
	, CAST(CAST(supplies_class AS INTEGER) AS VARCHAR) AS receipt_class_cd
	, ''ダイアライザ'' AS receipt_class
	, ''5'' AS receipt_kind_cd
	, ''滅菌'' AS receipt_kind
	, oms.supplies_cd AS receipt_cd
	, dia.sterilization AS receipt_name
	, NULL AS receipt_amount
	, NULL AS receipt_unit
	, NULL AS in_hospital_cd_1
	, NULL AS in_hospital_cd_2
	, NULL AS in_hospital_cd_3
	, NULL AS in_hospital_cd_4
	, ''1'' AS ord_by_key
FROM
	ordMS_tbl AS oms
	LEFT JOIN dia_tbl AS dia ON oms.supplies_cd = dia.dialyzer_cd
WHERE
	oms.supplies_class = ''01''
	AND supplies_source_class = ''0''
) dialInfo
ORDER BY receipt_kind_cd)
  
UNION ALL
(SELECT
	supplies_base_no AS ord_no
	, ROW_NUMBER() OVER () AS seq_no
	, CAST(CAST(supplies_class AS INTEGER) AS VARCHAR) AS receipt_class_cd
	, CASE 
		WHEN oms.supplies_class = ''00'' THEN ''血液回路''
		WHEN oms.supplies_class = ''02'' THEN ''吸着カラム''
		WHEN oms.supplies_class = ''03'' THEN ''1次膜''
		WHEN oms.supplies_class = ''04'' THEN ''2次膜''
		WHEN oms.supplies_class = ''05'' THEN ''シングルニードル''
		WHEN oms.supplies_class = ''06'' THEN ''穿刺針(A)''
		WHEN oms.supplies_class = ''07'' THEN ''穿刺針(V)''
		ELSE '''' 
	END AS receipt_class
	, NULL AS receipt_kind_cd
	, CASE 
		WHEN oms.supplies_class = ''00'' THEN ''血液回路''
		WHEN oms.supplies_class = ''02'' THEN ''吸着カラム''
		WHEN oms.supplies_class = ''03'' THEN ''1次膜''
		WHEN oms.supplies_class = ''04'' THEN ''2次膜''
		WHEN oms.supplies_class = ''05'' THEN ''シングルニードル''
		WHEN oms.supplies_class = ''06'' THEN ''穿刺針(A)''
		WHEN oms.supplies_class = ''07'' THEN ''穿刺針(V)''
		ELSE '''' 
	END AS receipt_kind
	, oms.supplies_cd AS receipt_cd
	, equ.equipment_name AS receipt_name
	, oms.receipt_value AS receipt_amount
	, oms.receipt_unit
	, equ.in_hospital_cd_1
	, equ.in_hospital_cd_2
	, equ.in_hospital_cd_3
	, equ.in_hospital_cd_4
	, CASE 
		WHEN oms.supplies_class = ''00'' THEN ''6''
		WHEN oms.supplies_class = ''02'' THEN ''7''
		WHEN oms.supplies_class = ''03'' THEN ''8''
		WHEN oms.supplies_class = ''04'' THEN ''9''
		WHEN oms.supplies_class = ''05'' THEN ''10''
		WHEN oms.supplies_class = ''06'' THEN ''11''
		WHEN oms.supplies_class = ''07'' THEN ''12''
		ELSE '''' 
	END AS ord_by_key
FROM
	ordMS_tbl AS oms
	LEFT JOIN equ_tbl AS equ ON oms.supplies_cd = equ.equipment_cd
WHERE
	oms.supplies_class in (''00'', ''02'', ''03'', ''04'', ''05'', ''06'', ''07'')
ORDER BY oms.supplies_class ASC)
UNION ALL	
(SELECT
	supplies_base_no AS ord_no
	, ROW_NUMBER() OVER () AS seq_no
	, ''10'' AS receipt_class_cd
	, ''抗凝固剤'' AS receipt_class
	, NULL AS receipt_kind_cd
	, ''抗凝固剤'' AS receipt_kind
	, oms.supplies_cd AS receipt_cd
	, med.medicine_name AS receipt_name
	, oms.receipt_value AS receipt_amount
	, oms.receipt_unit
	, med.in_hospital_cd_1
	, med.in_hospital_cd_2
	, med.in_hospital_cd_3
	, med.in_hospital_cd_4
	, ''13'' AS ord_by_key
FROM
	ordMS_tbl AS oms
	LEFT JOIN med_tbl AS med ON oms.supplies_cd = med.medicine_cd
	LEFT JOIN Antico_mix_sort AS ams ON oms.supplies_cd = ams.code
WHERE
	oms.supplies_class in (''10'', ''22'')
ORDER BY ams.reg_order ASC)
UNION ALL	
(SELECT
	supplies_base_no AS ord_no
	, ROW_NUMBER() OVER () AS seq_no
	, CAST(CAST(supplies_class AS INTEGER) AS VARCHAR) AS receipt_class_cd
	, CASE 
		WHEN oms.supplies_class = ''08'' THEN ''透析液''
		WHEN oms.supplies_class = ''09'' THEN ''補液''
		ELSE '''' 
	END AS receipt_class
	, NULL AS receipt_kind_cd
	, CASE 
		WHEN oms.supplies_class = ''08'' THEN ''透析液''
		WHEN oms.supplies_class = ''09'' THEN ''補液''
		ELSE '''' 
	END AS receipt_kind
	, oms.supplies_cd AS receipt_cd
	, med.medicine_name AS receipt_name
	, oms.receipt_value AS receipt_amount
	, oms.receipt_unit
	, med.in_hospital_cd_1
	, med.in_hospital_cd_2
	, med.in_hospital_cd_3
	, med.in_hospital_cd_4
	, CASE 
		WHEN oms.supplies_class = ''08'' THEN ''14''
		WHEN oms.supplies_class = ''09'' THEN ''15''
		ELSE '''' 
	END AS ord_by_key
FROM
	ordMS_tbl AS oms
	LEFT JOIN med_tbl AS med ON oms.supplies_cd = med.medicine_cd
WHERE
	oms.supplies_class in (''08'', ''09'')
ORDER BY oms.supplies_class)
UNION ALL
(SELECT
  ord_no,
  ROW_NUMBER() OVER (ORDER BY @equsort) AS seq_no,
  receipt_class_cd,
  receipt_class,
  CAST(class_cd AS VARCHAR) AS receipt_kind_cd,
  receipt_kind,
  receipt_cd,
  receipt_name,
  receipt_amount,
  receipt_unit,
  in_hospital_cd_1,
  in_hospital_cd_2,
  in_hospital_cd_3,
  in_hospital_cd_4,
  ''16'' AS ord_by_key
FROM (
    -- ダイアライザ部分
  SELECT
    oms.supplies_base_no AS ord_no,
    NULL AS code_order,
    code_order AS code_dia_order,
    oms.reg_order,
    eqc.class_order,
    CAST(CAST(oms.supplies_class AS INTEGER) AS VARCHAR) AS receipt_class_cd,
    ''医療材料'' AS receipt_class,
    NULL AS class_cd,
    ''ダイアライザ'' AS receipt_kind,
    oms.supplies_cd AS receipt_cd,
    dia.model_number AS receipt_name,
    CAST(SUM(CAST(COALESCE(NULLIF(oms.receipt_value, ''''), ''0'') AS NUMERIC)) AS VARCHAR) AS receipt_amount,
    oms.receipt_unit,
    dia.in_hospital_cd_1,
    dia.in_hospital_cd_2,
    dia.in_hospital_cd_3,
    dia.in_hospital_cd_4
  FROM
    ordMS_tbl AS oms
  LEFT JOIN dia_tbl AS dia ON oms.supplies_cd = dia.dialyzer_cd
  LEFT JOIN dia_sort AS dias ON dias.code = dia.dialyzer_cd
  LEFT JOIN equ_class_sort AS eqc ON eqc.code = oms.class_cd
  WHERE
    oms.supplies_class = ''01''
    AND supplies_source_class = ''2''
  GROUP BY
    oms.supplies_base_no,
    dias.code_order,
    oms.reg_order,
    eqc.class_order,
    oms.supplies_class,
    oms.supplies_cd,
    dia.model_number,
    oms.receipt_unit,
    dia.in_hospital_cd_1,
    dia.in_hospital_cd_2,
    dia.in_hospital_cd_3,
    dia.in_hospital_cd_4

  UNION ALL

  -- 医療材料部分
  SELECT
    oms.supplies_base_no AS ord_no,
    code_order,
    NULL AS code_dia_order,
    oms.reg_order,
    eqc.class_order,
    CAST(CAST(oms.supplies_class AS INTEGER) AS VARCHAR) AS receipt_class_cd,
    ''医療材料'' AS receipt_class,
    oms.class_cd,
    CASE
      WHEN oms.class_cd = -1 THEN ''未分類''
      ELSE equc.class_name
    END AS receipt_kind,
    oms.supplies_cd AS receipt_cd,
    equ.equipment_name AS receipt_name,
    CAST(SUM(CAST(COALESCE(NULLIF(oms.receipt_value, ''''), ''0'') AS NUMERIC)) AS VARCHAR) AS receipt_amount,
    oms.receipt_unit,
    equ.in_hospital_cd_1,
    equ.in_hospital_cd_2,
    equ.in_hospital_cd_3,
    equ.in_hospital_cd_4
  FROM
    ordMS_tbl AS oms
  LEFT JOIN equ_tbl AS equ ON oms.supplies_cd = equ.equipment_cd
  LEFT JOIN equ_class_tbl AS equc ON oms.class_cd = equc.class_cd
  LEFT JOIN equ_sort AS eq ON eq.code = oms.supplies_cd
  LEFT JOIN equ_class_sort AS eqc ON eqc.code = oms.class_cd
  WHERE
    oms.supplies_class = ''11''
  GROUP BY
    oms.supplies_base_no,
    oms.reg_order,
    eqc.class_order,
    eq.code_order,
    oms.supplies_class,
    oms.class_cd,
    oms.supplies_cd,
    equ.equipment_name,
    equc.class_name,
    oms.receipt_unit,
    equ.in_hospital_cd_1,
    equ.in_hospital_cd_2,
    equ.in_hospital_cd_3,
    equ.in_hospital_cd_4
) equinfo
ORDER BY @equsort)
UNION ALL	
SELECT 
	ord_no
	, ROW_NUMBER() OVER () AS seq_no
	, receipt_class_cd
	, receipt_class
	, receipt_kind_cd
	, receipt_kind
	, receipt_cd
	, receipt_name
	, receipt_amount
	, receipt_unit
	, in_hospital_cd_1
	, in_hospital_cd_2
	, in_hospital_cd_3
	, in_hospital_cd_4
	, ''17'' AS ord_by_key
FROM(
	SELECT 
		ord_no
		, receipt_class_cd
		, receipt_class
		, CAST(class_cd AS VARCHAR) AS receipt_kind_cd
		, receipt_kind
		, receipt_cd
		, receipt_name
		, receipt_amount
		, receipt_unit
		, in_hospital_cd_1
		, in_hospital_cd_2
		, in_hospital_cd_3
		, in_hospital_cd_4
		, 1 AS medicine_type
		, 0 AS date_interval
		, timing_cd
		, procedure_cd
	FROM
	(SELECT
		supplies_base_no AS ord_no
		, ''12'' AS receipt_class_cd
		, ''投与薬剤'' AS receipt_class
				, oms.class_cd
		, CASE
			WHEN oms.class_cd = -1 THEN ''未分類''
			ELSE medc.class_name
		END AS receipt_kind
		, oms.supplies_cd AS receipt_cd
		, med.medicine_name AS receipt_name
		, CAST(SUM(CAST(COALESCE(NULLIF(oms.receipt_value, ''''), ''0'') AS NUMERIC)) AS VARCHAR) AS receipt_amount		
		, oms.receipt_unit
		, med.in_hospital_cd_1
		, med.in_hospital_cd_2
		, med.in_hospital_cd_3
		, med.in_hospital_cd_4
		, oms.timing_cd
		, oms.procedure_cd
		, oms.reg_order
	FROM
		ordMS_tbl AS oms
		LEFT JOIN med_tbl AS med ON oms.supplies_cd = med.medicine_cd
		LEFT JOIN med_class_tbl AS medc ON oms.class_cd = medc.class_cd
	WHERE
		oms.supplies_class in (''12'', ''14'', ''20'', ''21'')
		AND oms.effect_flg = ''1''
	GROUP BY 
		supplies_base_no
		, oms.class_cd
		, oms.supplies_cd
		, med.medicine_name
		, medc.class_name
		, oms.receipt_unit
		, med.in_hospital_cd_1
		, med.in_hospital_cd_2
		, med.in_hospital_cd_3
		, med.in_hospital_cd_4
		, oms.timing_cd
		, oms.procedure_cd
		, oms.reg_order
	) medinfo
	LEFT JOIN med_sort me ON me.code = medinfo.receipt_cd
	LEFT JOIN med_mix_sort mex ON mex.code = medinfo.receipt_cd
	LEFT JOIN med_class_sort mec ON mec.code = medinfo.class_cd
	LEFT JOIN med_timing_sort met ON met.code = medinfo.timing_cd
	LEFT JOIN proc_sort p ON p.code = medinfo.procedure_cd		
	ORDER BY @medsort
) medall
UNION ALL	
SELECT
	@ordNo AS ord_no
	, ROW_NUMBER() OVER () AS seq_no
	, ''13'' AS receipt_class_cd
	, ''透析困難'' AS receipt_class
	, dial_diff_cd AS receipt_kind_cd
	, ''透析困難'' AS receipt_kind
	, CAST(dial_diff_cd AS INTEGER) AS receipt_cd
	, dial_diff_name AS receipt_name
	, NULL AS receipt_amount
	, NULL AS receipt_unit
	, in_hospital_cd_1
	, in_hospital_cd_2
	, NULL AS in_hospital_cd_3
	, NULL AS in_hospital_cd_4
	, ''18'' AS ord_by_key
FROM
	diff_info
UNION ALL	
SELECT
	ord_no
	, ROW_NUMBER() OVER () AS seq_no
	, ''14'' AS receipt_class_cd
	, ''加算・管理料'' AS receipt_class
	, CAST(addition_cd AS VARCHAR) AS receipt_kind_cd
	, ''加算・管理料'' AS receipt_kind
	, addition_cd AS receipt_cd
	, addition_name AS receipt_name
	, NULL AS receipt_amount
	, NULL AS receipt_unit
	, in_hospital_cd_1
	, in_hospital_cd_2
	, in_hospital_cd_3
	, NULL AS in_hospital_cd_4
	, ''19'' AS ord_by_key
FROM
	addi_info

	) t

),
big_sorted AS (

SELECT
    u.*,
    COALESCE(r.sort_no,999) AS big_sort
FROM union_data u
LEFT JOIN sort_rule r
    ON r.receipt_kind_cd = u.ord_by_key

)
SELECT
  *
FROM
  big_sorted
ORDER BY
  big_sort,
  ord_by_key::int,
  seq_no', 2, '[{"preview": "ダイアライザ", "can_calc": "0", "data_code": "receipt_class", "data_name": "データ種別", "data_type": "string", "conv_table": [], "data_class": "明細", "field_name": "receipt_class", "disp_format": "", "filter_type": "Receipt", "data_category": "レセプト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ダイアライザ", "can_calc": "0", "data_code": "receipt_kind", "data_name": "データ分類", "data_type": "string", "conv_table": [], "data_class": "明細", "field_name": "receipt_kind", "disp_format": "", "filter_type": "Receipt", "data_category": "レセプト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "FDX-120GW", "can_calc": "0", "data_code": "receipt_name", "data_name": "項目", "data_type": "string", "conv_table": [], "data_class": "明細", "field_name": "receipt_name", "disp_format": "", "filter_type": "Receipt", "data_category": "レセプト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd_1", "data_name": "連携コード１", "data_type": "string", "conv_table": [], "data_class": "明細", "field_name": "in_hospital_cd_1", "disp_format": "", "filter_type": "Receipt", "data_category": "レセプト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd_2", "data_name": "連携コード2", "data_type": "string", "conv_table": [], "data_class": "明細", "field_name": "in_hospital_cd_2", "disp_format": "", "filter_type": "Receipt", "data_category": "レセプト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd_3", "data_name": "連携コード3", "data_type": "string", "conv_table": [], "data_class": "明細", "field_name": "in_hospital_cd_3", "disp_format": "", "filter_type": "Receipt", "data_category": "レセプト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234", "can_calc": "0", "data_code": "in_hospital_cd_4", "data_name": "連携コード4", "data_type": "string", "conv_table": [], "data_class": "明細", "field_name": "in_hospital_cd_4", "disp_format": "", "filter_type": "Receipt", "data_category": "レセプト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "receipt_amount", "data_name": "数量", "data_type": "string", "conv_table": [], "data_class": "明細", "field_name": "receipt_amount", "disp_format": "", "filter_type": "Receipt", "data_category": "レセプト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "本", "can_calc": "0", "data_code": "receipt_unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "明細", "field_name": "receipt_unit", "disp_format": "", "filter_type": "Receipt", "data_category": "レセプト", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [2]}', 'レセプト：@facilityCd @ordNo 使用', '2025-03-26 21:13:57.36', CURRENT_TIMESTAMP, '[{"sql_cd": 241, "field_name": "dial_diff_com_info_receipt", "replace_var": "@dialDiffComInfo"}]');
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (251, 'WITH
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
    AND master_physical_name IN (''mst_medicine'',''mst_medicine_class'')
)
, sort_fields AS (
  SELECT elem, ord, facility_setting_no
  FROM mst_facility_setting mfs,
       jsonb_array_elements_text(mfs.value::jsonb) WITH ORDINALITY t(elem, ord)
  WHERE facility_setting_no = ''3007''
    AND facility_cd = @facilityCd
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
	NULL AS dia_order,
	medic.code_order AS medic_order,
	NULL AS equic_order,
  medicine_cd,
  medicine_class_cd,
  reg_order,
  class_order,
  code_medi_order,
  NULL AS medi_mix_order,
  medicine_type,
  timing_order,
  proc_order,
  date_interval,
  rn
FROM
(
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
    medicine_cd,
    medicine_class_cd,
    NULL::int AS reg_order,
    NULL::int AS class_order,
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
      save.supplies_cd AS medicine_cd,
      save.class_cd AS medicine_class_cd
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
      medicine_cd,
      medicine_class_cd,
      reg_order,
      class_order,
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
        save.supplies_cd AS medicine_cd,
        save.class_cd AS medicine_class_cd,
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
      medicine_cd,
      medicine_class_cd,
      reg_order,
      class_order,
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
	medic_order,
  medicine_cd,
  medicine_class_cd,
  reg_order,
  class_order,
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

SELECT * from result_all as res @orderBy ,rn', 2, '[{"preview": "テープ", "can_calc": "0", "data_code": "kind", "data_name": "分類名称", "data_type": "string", "conv_table": [], "data_class": "物品情報(薬剤)", "field_name": "kind", "disp_format": "", "filter_type": "Medicine", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70%ブドウ糖注射液350ml", "can_calc": "0", "data_code": "name", "data_name": "型番･名称", "data_type": "string", "conv_table": [], "data_class": "物品情報(薬剤)", "field_name": "name", "disp_format": "", "filter_type": "Medicine", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "1", "data_code": "amount", "data_name": "指示数量", "data_type": "decimal", "conv_table": [], "data_class": "物品情報(薬剤)", "field_name": "amount", "disp_format": "0.00", "filter_type": "Medicine", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "個", "can_calc": "0", "data_code": "unit", "data_name": "指示単位", "data_type": "string", "conv_table": [], "data_class": "物品情報(薬剤)", "field_name": "unit", "disp_format": "", "filter_type": "Medicine", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "1", "data_code": "receipt_value", "data_name": "レせ数量", "data_type": "decimal", "conv_table": [], "data_class": "物品情報(薬剤)", "field_name": "receipt_value", "disp_format": "0.00", "filter_type": "Medicine", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レせ個", "can_calc": "0", "data_code": "receipt_unit", "data_name": "レせ単位", "data_type": "string", "conv_table": [], "data_class": "物品情報(薬剤)", "field_name": "receipt_unit", "disp_format": "", "filter_type": "Medicine", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "物品情報(薬剤)", "field_name": "in_hospital_cd_1", "disp_format": "", "filter_type": "Medicine", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "物品情報(薬剤)", "field_name": "in_hospital_cd_2", "disp_format": "", "filter_type": "Medicine", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "物品情報(薬剤)", "field_name": "in_hospital_cd_3", "disp_format": "", "filter_type": "Medicine", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_4", "data_name": "院内コード4", "data_type": "string", "conv_table": [], "data_class": "物品情報(薬剤)", "field_name": "in_hospital_cd_4", "disp_format": "", "filter_type": "Medicine", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [4]}', '器材準備リスト (物品情報(薬剤))', '2025-04-30 15:59:32.312', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (253, 'WITH
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
    AND master_physical_name IN (''mst_dialyzer'',''mst_equipment'',''mst_equipment_class'')
)
, sort_fields AS (
  SELECT elem, ord, facility_setting_no
  FROM mst_facility_setting mfs,
       jsonb_array_elements_text(mfs.value::jsonb) WITH ORDINALITY t(elem, ord)
  WHERE facility_setting_no = ''3006''
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
	dia.code_order AS dia_order,
	equic.code_order AS equic_order,
	NULL AS medic_order,
	NULL AS medi_mix_order,
	equipment_cd,
	equipment_class_cd,
	dialyzer_cd,
	reg_order,
	class_order,
	code_dia_order,
	code_equ_order,
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
    equipment_cd,
    equipment_class_cd,
    dialyzer_cd,
    NULL::int AS reg_order,
    NULL::int AS class_order,
    NULL::int AS code_equ_order,
    NULL::int AS code_dia_order,
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
      COALESCE (save.class_cd , ''-1'') AS class_cd,
      save.supplies_cd AS cd,
      ''ダイアライザ'' AS do_action,
      ''医療材料'' AS data_type_order,
      2 AS kind_order,
      NULL AS equipment_cd,
      NULL AS equipment_class_cd,
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
      save.supplies_cd AS equipment_cd,
      save.class_cd AS equipment_class_cd,
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
      equipment_cd,
      equipment_class_cd,
      dialyzer_cd,
      reg_order,
      class_order,
      code_equ_order,
      code_dia_order,
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
        COALESCE (save.class_cd , ''-1'') AS class_cd,
        save.supplies_cd AS cd,
        ''ダイアライザ'' AS do_action,
        ''医療材料'' AS data_type_order,
        2 AS kind_order,
        NULL AS equipment_cd,
        NULL AS equipment_class_cd,
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
        save.supplies_cd AS equipment_cd,
        save.class_cd AS equipment_class_cd,
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
      equipment_cd,
      equipment_class_cd,
      dialyzer_cd,
      reg_order,
      class_order,
      code_equ_order,
      code_dia_order,
      sort_key
    ORDER BY
      sort_key
  ) IND_EQU_SORT

) AS EquipmentList
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
  dia_order,
	equic_order,
  equipment_cd,
  equipment_class_cd,
  dialyzer_cd,
  reg_order,
  class_order,
  code_dia_order,
  code_equ_order,
  rn
HAVING
  SUM ( Amount ) > 0
ORDER BY
  disp_order,
	kind
) 

SELECT * from result_all as res @orderBy, rn', 2, '[{"preview": "テープ", "can_calc": "0", "data_code": "kind", "data_name": "分類名称", "data_type": "string", "conv_table": [], "data_class": "物品情報(器材)", "field_name": "kind", "disp_format": "", "filter_type": "EquipDia", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70%ブドウ糖注射液350ml", "can_calc": "0", "data_code": "name", "data_name": "型番･名称", "data_type": "string", "conv_table": [], "data_class": "物品情報(器材)", "field_name": "name", "disp_format": "", "filter_type": "EquipDia", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "1", "data_code": "amount", "data_name": "指示数量", "data_type": "decimal", "conv_table": [], "data_class": "物品情報(器材)", "field_name": "amount", "disp_format": "0.00", "filter_type": "EquipDia", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "個", "can_calc": "0", "data_code": "unit", "data_name": "指示単位", "data_type": "string", "conv_table": [], "data_class": "物品情報(器材)", "field_name": "unit", "disp_format": "", "filter_type": "EquipDia", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "1", "data_code": "receipt_value", "data_name": "レせ数量", "data_type": "decimal", "conv_table": [], "data_class": "物品情報(器材)", "field_name": "receipt_value", "disp_format": "0.00", "filter_type": "EquipDia", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "レせ個", "can_calc": "0", "data_code": "receipt_unit", "data_name": "レせ単位", "data_type": "string", "conv_table": [], "data_class": "物品情報(器材)", "field_name": "receipt_unit", "disp_format": "", "filter_type": "EquipDia", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_1", "data_name": "院内コード1", "data_type": "string", "conv_table": [], "data_class": "物品情報(器材)", "field_name": "in_hospital_cd_1", "disp_format": "", "filter_type": "EquipDia", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_2", "data_name": "院内コード2", "data_type": "string", "conv_table": [], "data_class": "物品情報(器材)", "field_name": "in_hospital_cd_2", "disp_format": "", "filter_type": "EquipDia", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_3", "data_name": "院内コード3", "data_type": "string", "conv_table": [], "data_class": "物品情報(器材)", "field_name": "in_hospital_cd_3", "disp_format": "", "filter_type": "EquipDia", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "in_hospital_cd_4", "data_name": "院内コード4", "data_type": "string", "conv_table": [], "data_class": "物品情報(器材)", "field_name": "in_hospital_cd_4", "disp_format": "", "filter_type": "EquipDia", "data_category": "準備リスト", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [4]}', '器材準備リスト(物品情報(器材))', '2025-04-30 15:59:32.321', CURRENT_TIMESTAMP, NULL);
