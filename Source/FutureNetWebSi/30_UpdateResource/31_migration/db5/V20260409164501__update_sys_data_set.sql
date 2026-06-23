DELETE FROM "ntss"."sys_data_set" WHERE sql_cd = 239;
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
equ_reg_sort AS (
	SELECT 
		ROW_NUMBER() OVER (PARTITION BY supplies_cd) AS idx,
		ord_material_save_no AS reg_order,
		supplies_cd AS code,
		supplies_class
	FROM
		ordMS_tbl
	WHERE
		supplies_class = ''11''
	ORDER BY reg_date,reg_order ASC
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
med_reg_sort AS (
	SELECT 
		ROW_NUMBER() OVER (PARTITION BY supplies_cd) AS idx,
		ord_material_save_no AS reg_order,
		supplies_cd AS code,
		supplies_class
	FROM
		ordMS_tbl
	WHERE
		supplies_class in (''12'', ''14'', ''20'', ''21'')		
	ORDER BY reg_date,reg_order ASC
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
),
union_data AS (
select * from (

SELECT
  ord_no,
  ROW_NUMBER() OVER (ORDER BY receipt_kind_cd) AS seq_no,
  receipt_class_cd,
  receipt_class,
  receipt_kind_cd,
  receipt_kind,
  receipt_cd,
  receipt_name,
  receipt_amount,
  receipt_unit,
  in_hospital_cd_1,
  in_hospital_cd_2,
  in_hospital_cd_3,
  in_hospital_cd_4,
  ord_by_key
from
(SELECT
	supplies_base_no AS ord_no
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
SELECT
  ord_no,
  ROW_NUMBER() OVER (ORDER BY receipt_class_cd) AS seq_no,
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
  (SELECT
    oms.supplies_base_no AS ord_no,
    code_order,
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
  WHERE
    oms.supplies_class = ''01''
    AND supplies_source_class = ''2''
  GROUP BY
    oms.supplies_base_no,
    dias.code_order,
    oms.supplies_class,
    oms.supplies_cd,
    dia.model_number,
    oms.receipt_unit,
    dia.in_hospital_cd_1,
    dia.in_hospital_cd_2,
    dia.in_hospital_cd_3,
    dia.in_hospital_cd_4
  ORDER BY code_order)

  UNION ALL

  -- 医療材料部分
  (SELECT
    oms.supplies_base_no AS ord_no,
    code_order,
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
  LEFT JOIN equ_reg_sort AS mer ON mer.code = oms.supplies_cd AND mer.idx = 1
  LEFT JOIN equ_class_sort AS eqc ON eqc.code = oms.class_cd
  WHERE
    oms.supplies_class = ''11''
  GROUP BY
    oms.supplies_base_no,
    mer.reg_order,
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
  ORDER BY @equsort ASC)
) equinfo
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
	) medinfo
	LEFT JOIN med_reg_sort mer ON mer.code = medinfo.receipt_cd AND mer.idx = 1
	LEFT JOIN med_sort me ON me.code = medinfo.receipt_cd
	LEFT JOIN med_mix_sort mex ON mex.code = medinfo.receipt_cd
	LEFT JOIN med_class_sort mec ON mec.code = medinfo.class_cd
	LEFT JOIN med_timing_sort met ON met.code = medinfo.timing_cd
	LEFT JOIN proc_sort p ON p.code = medinfo.procedure_cd		
	ORDER BY @medsort ASC
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
