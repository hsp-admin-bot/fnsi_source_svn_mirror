DELETE FROM "ntss"."sys_data_set" where sql_cd in (11, 206, 243, 244);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (11, 'WITH om AS ( SELECT * FROM ord_main WHERE is_del = ''0'' AND ord_no IN ( @ordNos ) ),
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
	),
	result_all as (
	SELECT
to_timestamp( treat_date, ''YYYYMMDD'' ) AS treat_date,
disp_order,
kind,
class_cd,
class,
do_action,
NAME,
code,
kur_cd,
kur_name,
Amount AS amount,
unit,
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
medi_mix.medi_mix_order
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
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''ダイアライザ'' AS class,
	CASE

			WHEN dz.model_number IS NOT NULL THEN
			''ダイアライザ'' ELSE NULL
		END AS kind,
	    ''0'' AS class_cd,
			''ダイアライザ'' AS do_action, 
		dz.model_number AS NAME,
		dz.dialyzer_cd AS code,
	CASE

			WHEN dz.model_number IS NOT NULL THEN
			1 ELSE NULL
		END AS Amount,
		COALESCE ( om.ind_cond_info :: json #>> ''{5,unit}'', ''本'' ) AS Unit,
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
		om
		INNER JOIN dz ON TO_NUMBER( om.ind_cond_info :: json #>> ''{5,value}'', ''99999999'' ) = dz.dialyzer_cd
		AND dz.dialyzer_cd IN ( @diaIds )
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{5,value}'' IS NOT NULL
	UNION ALL--吸着カラム
	SELECT
				CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 3
         WHEN @dataTypeOrder = ''2'' THEN 1
         WHEN @dataTypeOrder = ''3'' THEN 1
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 3
         ELSE 1  END AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''吸着カラム'' AS class,
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
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
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
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{6,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{6,value}'' IS NOT NULL
	UNION ALL--1次膜
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 3
         WHEN @dataTypeOrder = ''2'' THEN 1
         WHEN @dataTypeOrder = ''3'' THEN 1
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 3
         ELSE 1  END AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''1次膜'' AS class,
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
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
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
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{7,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{7,value}'' IS NOT NULL
	UNION ALL--2次膜
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 3
         WHEN @dataTypeOrder = ''2'' THEN 1
         WHEN @dataTypeOrder = ''3'' THEN 1
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 3
         ELSE 1  END AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''2次膜'' AS class,
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
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
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
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{8,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{8,value}'' IS NOT NULL
	UNION ALL--穿刺針(A針)
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 3
         WHEN @dataTypeOrder = ''2'' THEN 1
         WHEN @dataTypeOrder = ''3'' THEN 1
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 3
         ELSE 1  END AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''穿刺針(A)'' AS class,
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
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
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
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{9,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{9,value}'' IS NOT NULL
	UNION ALL--穿刺針(V針)
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 3
         WHEN @dataTypeOrder = ''2'' THEN 1
         WHEN @dataTypeOrder = ''3'' THEN 1
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 3
         ELSE 1  END AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''穿刺針(V)'' AS class,
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
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
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
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{10,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{10,value}'' IS NOT NULL
	UNION ALL--穿刺針(SN)
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 3
         WHEN @dataTypeOrder = ''2'' THEN 1
         WHEN @dataTypeOrder = ''3'' THEN 1
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 3
         ELSE 1  END AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''シングルニードル'' AS class,
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
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
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
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{11,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{11,value}'' IS NOT NULL
	UNION ALL--血液回路
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 3
         WHEN @dataTypeOrder = ''2'' THEN 1
         WHEN @dataTypeOrder = ''3'' THEN 1
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 3
         ELSE 1  END AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''血液回路'' AS class,
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
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
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
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{13,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{13,value}'' IS NOT NULL
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
		, bed_name
		, pat_id
		, class
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
			om.treat_date,
			kr.kur_cd,
			COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.pat_id,
			CASE
				WHEN eqc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
				END AS class,
			CASE
				WHEN eqc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
				END AS kind,
			CASE
				WHEN eqc.class_name IS NULL THEN
				''-1'' ELSE eqc.class_cd
				END AS class_cd,
			CASE WHEN save.supplies_class = ''01'' then dz.model_number
				ELSE eq.equipment_name
				END AS NAME,
			TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
			CAST(save.ind_rst_value AS DECIMAL),
      CASE WHEN save.supplies_class = ''01'' then ''本''
        ELSE COALESCE ( eq.unit, '''' )
        END AS Unit,
			eq.in_hospital_cd_1,
			eq.in_hospital_cd_2,
			eq.in_hospital_cd_3,
			eq.in_hospital_cd_4
		FROM
			om
			LEFT OUTER JOIN ord_material_save as save on om.ord_no = save.supplies_base_no
						and om.facility_cd = save.facility_cd
						and save.supplies_source_class = ''2''
						and save.ind_rst_class = ''1''
			INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = eq.equipment_cd
			AND eq.class_cd IN ( @eqIds )
			LEFT JOIN mst_dialyzer as dz ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = dz.dialyzer_cd
			AND dz.dialyzer_cd IN ( @diaIds )
			LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
			LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
			LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
		WHERE
			om.ord_no IN ( @ordNos ) 
	) equInfo
	GROUP BY
		treat_date,
		kind,
		class_cd,
		class,
		do_action,
		NAME,
		code,
		kur_cd,
		kur_name,
		Unit,
		bed_name,
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
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''抗凝固剤'' AS class,
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
		md.medicine_cd AS code,
		CEIL (
			(
				( CAST( om.ind_cond_info :: json #>> ''{26,value}'' AS DECIMAL) + CAST( om.ind_cond_info :: json #>> ''{28,value}'' AS DECIMAL) ) / ( CASE WHEN md.unit_converted_amount IS NULL OR md.unit_converted_amount = 0 THEN 1 ELSE md.unit_converted_amount END )
					) * ( CASE WHEN md.unit_converted_amount_second IS NULL OR md.unit_converted_amount_second = 0 THEN 1 ELSE md.unit_converted_amount_second END )
		) AS Amount,
		COALESCE ( md.unit, '''' ) AS Unit,
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
		om
		INNER JOIN md ON TO_NUMBER( om.ind_cond_info :: json #>> ''{25,value}'', ''99999999'' ) = md.medicine_cd
		AND md.class_cd IN ( @medIds )
		LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{25,value}'' IS NOT NULL
	UNION ALL--抗凝固剤調製薬剤
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 3
         WHEN @dataTypeOrder = ''1'' THEN 2
         WHEN @dataTypeOrder = ''2'' THEN 2
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 1
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''抗凝固剤'' AS class,
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
		mdx.medicine_mix_cd AS code,
		( CAST( om.ind_cond_info :: json #>> ''{26,value}'' AS DECIMAL) + CAST( om.ind_cond_info :: json #>> ''{28,value}'' AS DECIMAL) ) AS Amount,
				COALESCE ( mdx.unit, '''' ) AS Unit,
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
		om
		INNER JOIN mdx ON mdx.medicine_mix_cd = TO_NUMBER( om.ind_cond_info -> ''25'' ->> ''value'', ''999999999999'' )
		AND TO_NUMBER( om.ind_cond_info -> ''25'' ->> ''medicine_type'', ''999999999999'' ) = ''2''
		LEFT OUTER JOIN mdc ON mdx.class_cd = mdc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{25,value}'' IS NOT NULL
	UNION ALL--透析液
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 3
         WHEN @dataTypeOrder = ''1'' THEN 2
         WHEN @dataTypeOrder = ''2'' THEN 2
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 1
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''透析液'' AS class,
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
		md.medicine_cd AS code,
		CAST( om.ind_cond_info :: json #>> ''{17,value}'' AS DECIMAL) AS Amount,
		COALESCE ( md.unit_second, '''' ) AS Unit,
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
		om
		INNER JOIN md ON TO_NUMBER( om.ind_cond_info :: json #>> ''{15,value}'', ''99999999'' ) = md.medicine_cd
		AND md.class_cd IN ( @medIds )
		LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{15,value}'' IS NOT NULL
	UNION ALL--補液
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 3
         WHEN @dataTypeOrder = ''1'' THEN 2
         WHEN @dataTypeOrder = ''2'' THEN 2
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 1
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''補液'' AS class,
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
		md.medicine_cd AS code,
		CAST( om.ind_cond_info :: json #>> ''{22,value}'' AS DECIMAL) AS Amount,
		COALESCE ( md.unit_second, '''' ) AS Unit,
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
		om
		INNER JOIN md ON TO_NUMBER( om.ind_cond_info :: json #>> ''{19,value}'', ''99999999'' ) = md.medicine_cd
		AND md.class_cd IN ( @medIds )
		LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{19,value}'' IS NOT NULL 
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
		, bed_name
		, pat_id
		, class
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
			om.treat_date,
			kr.kur_cd,
			COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.pat_id,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS class,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS kind,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''-1'' ELSE mdc.class_cd
				END AS class_cd,
			md.medicine_name AS NAME,
			md.medicine_cd AS code,
			CAST(save.ind_rst_value AS DECIMAL),
			COALESCE ( md.unit, '''' ) AS Unit,
			md.in_hospital_cd_1,
			md.in_hospital_cd_2,
			md.in_hospital_cd_3,
			md.in_hospital_cd_4
		FROM
			om
			LEFT OUTER JOIN ord_material_save as save on om.ord_no = save.supplies_base_no
						and om.facility_cd = save.facility_cd
						and save.supplies_source_class = ''1''
						and save.supplies_class = ''12''
						and save.ind_rst_class = ''1''
			INNER JOIN md ON TO_NUMBER( save.supplies_cd, ''99999999'' ) = md.medicine_cd
			AND md.class_cd IN ( @medIds )
			LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
			LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
			LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
		WHERE
			om.ord_no IN ( @ordNos ) 
	) medInfo
	GROUP BY
		treat_date,
		kind,
		class_cd,
		class,
		do_action,
		NAME,
		code,
		kur_cd,
		kur_name,
		Unit,
		bed_name,
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
		, bed_name
		, pat_id
		, class
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
			om.treat_date,
			kr.kur_cd,
			COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.pat_id,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS class,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS kind,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''-1'' ELSE mdc.class_cd
				END AS class_cd,
			mdx.medicine_mix_name AS NAME,
			mdx.medicine_mix_cd AS code,
			CAST(save.ind_rst_value AS DECIMAL),
			COALESCE ( mdx.unit, '''' )  AS Unit,
			mdx.in_hospital_cd_1,
			mdx.in_hospital_cd_2,
			mdx.in_hospital_cd_3,
			null as in_hospital_cd_4
		FROM
			om
			LEFT OUTER JOIN ord_material_save as save on om.ord_no = save.supplies_base_no
						and om.facility_cd = save.facility_cd
						and save.supplies_source_class = ''1''
						and save.supplies_class = ''13''
						and save.ind_rst_class = ''1''
			INNER JOIN mdx ON TO_NUMBER(save.medicine_mix_cd, ''99999999'' ) = mdx.medicine_mix_cd
			AND mdx.class_cd IN ( @medIds )
			LEFT OUTER JOIN mdc ON mdx.class_cd = mdc.class_cd
			LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
			LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
		WHERE
			om.ord_no IN ( @ordNos )
	) medInfo
	GROUP BY
		treat_date,
		kind,
		class_cd,
		class,
		do_action,
		NAME,
		code,
		kur_cd,
		kur_name,
		Unit,
		bed_name,
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
		bed_name,
		pat_id
	)
	) AS EquipmentList
	LEFT OUTER JOIN medic ON medic.medic_code :: TEXT = EquipmentList.medicine_class_cd
	LEFT OUTER JOIN equic ON equic.equic_code = EquipmentList.equipment_class_cd
	LEFT OUTER JOIN dia ON dia.dia_code = EquipmentList.dialyzer_cd
	LEFT OUTER JOIN medi_mix ON medi_mix.medi_mix_code :: TEXT = EquipmentList.medicine_class_cd
) 
SELECT * from result_all as res @orderBy	', 2, '[{"preview": "1", "can_calc": "", "data_code": "kur_cd", "data_name": "クールコード", "data_type": "decimal", "conv_table": [], "data_class": "ベッド情報", "field_name": "kur_cd", "disp_format": "0", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": ""}, {"preview": "午後", "can_calc": "", "data_code": "kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "kur_name", "disp_format": "", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": ""}, {"preview": "北1", "can_calc": "", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報", "field_name": "bed_name", "disp_format": "", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": ""}, {"preview": "テープ", "can_calc": "0", "data_code": "kind", "data_name": "分類名称", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "kind", "disp_format": "", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ダイアライザ", "can_calc": "0", "data_code": "class", "data_name": "データ分類", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "class", "disp_format": "", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70%ブドウ糖注射液350ml", "can_calc": "0", "data_code": "name", "data_name": "型番･名称", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "name", "disp_format": "", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "1", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "物品情報", "field_name": "amount", "disp_format": "0.00", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "個", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "物品情報", "field_name": "unit", "disp_format": "", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789012", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "hosp_pat_id", "target_var": "@patId"}, "data_code": "hosp_pat_id", "data_name": "患者ID", "data_type": "string", "conv_table": [], "data_class": "基本情報", "field_name": "pat_id", "disp_format": "", "data_category": "配布リスト(物品)", "facility_filter_type": "0"}, {"preview": "テスト患者1", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_name", "target_var": "@patId"}, "data_code": "pat_name", "data_name": "患者名", "data_type": "string", "conv_table": [], "data_class": "基本情報", "field_name": "pat_id1", "disp_format": "", "data_category": "配布リスト(物品)", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [6]}', '配布リスト(物品)', '2024-11-22 16:21:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (206, 'WITH om AS ( SELECT * FROM ord_main WHERE is_del = ''0'' AND ord_no IN ( @ordNos ) ),
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
	),
	result_all as (
	SELECT
	disp_order,
to_timestamp( treat_date, ''YYYYMMDD'' ) AS treat_date,
kind,
class,
class_cd,
do_action,
NAME,
code,
kur_cd,
kur_name,
Amount AS amount,
unit,
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
medi_mix.medi_mix_order
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
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''ダイアライザ'' AS class,
	CASE

			WHEN dz.model_number IS NOT NULL THEN
			''ダイアライザ'' ELSE NULL
		END AS kind,
		''0'' AS class_cd,
		''ダイアライザ'' AS do_action, 
		dz.model_number AS NAME,
		dz.dialyzer_cd AS code,
	CASE

			WHEN dz.model_number IS NOT NULL THEN
			1 ELSE NULL
		END AS Amount,
		COALESCE ( om.ind_cond_info :: json #>> ''{5,unit}'', ''本'' ) AS Unit,
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
		om
		INNER JOIN dz ON TO_NUMBER( om.ind_cond_info :: json #>> ''{5,value}'', ''99999999'' ) = dz.dialyzer_cd
		AND dz.dialyzer_cd IN ( @diaIds )
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{5,value}'' IS NOT NULL
	UNION ALL--吸着カラム
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 3
         WHEN @dataTypeOrder = ''2'' THEN 1
         WHEN @dataTypeOrder = ''3'' THEN 1
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 3
         ELSE 1  END AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''吸着カラム'' AS class,
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
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
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
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{6,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{6,value}'' IS NOT NULL
	UNION ALL--1次膜
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 3
         WHEN @dataTypeOrder = ''2'' THEN 1
         WHEN @dataTypeOrder = ''3'' THEN 1
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 3
         ELSE 1  END AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''1次膜'' AS class,
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
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
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
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{7,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{7,value}'' IS NOT NULL
	UNION ALL--2次膜
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 3
         WHEN @dataTypeOrder = ''2'' THEN 1
         WHEN @dataTypeOrder = ''3'' THEN 1
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 3
         ELSE 1  END AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''2次膜'' AS class,
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
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
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
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{8,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{8,value}'' IS NOT NULL
	UNION ALL--穿刺針(A針)
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 3
         WHEN @dataTypeOrder = ''2'' THEN 1
         WHEN @dataTypeOrder = ''3'' THEN 1
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 3
         ELSE 1  END AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''穿刺針(A)'' AS class,
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
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
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
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{9,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{9,value}'' IS NOT NULL
	UNION ALL--穿刺針(V針)
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 3
         WHEN @dataTypeOrder = ''2'' THEN 1
         WHEN @dataTypeOrder = ''3'' THEN 1
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 3
         ELSE 1  END AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''穿刺針(V)'' AS class,
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
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
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
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{10,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{10,value}'' IS NOT NULL
	UNION ALL--穿刺針(SN)
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 3
         WHEN @dataTypeOrder = ''2'' THEN 1
         WHEN @dataTypeOrder = ''3'' THEN 1
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 3
         ELSE 1  END AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''シングルニードル'' AS class,
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
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
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
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{11,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{11,value}'' IS NOT NULL
	UNION ALL--血液回路
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 3
         WHEN @dataTypeOrder = ''2'' THEN 1
         WHEN @dataTypeOrder = ''3'' THEN 1
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 3
         ELSE 1  END AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''血液回路'' AS class,
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
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
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
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{13,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{13,value}'' IS NOT NULL
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
		, bed_name
		, pat_id
		, class
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
			om.treat_date,
			kr.kur_cd,
			COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.pat_id,
			CASE
				WHEN eqc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
				END AS class,
			CASE
				WHEN eqc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
				END AS kind,
			CASE
				WHEN eqc.class_name IS NULL THEN
				''-1'' ELSE eqc.class_cd
				END AS class_cd,
			CASE WHEN save.supplies_class = ''01'' then dz.model_number
				ELSE eq.equipment_name
				END AS NAME,
			TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
			CAST(save.ind_rst_value  AS DECIMAL),
			CASE WHEN save.supplies_class = ''01'' then ''本''
				ELSE COALESCE ( eq.unit, '''' )
				END AS Unit,
			eq.in_hospital_cd_1,
			eq.in_hospital_cd_2,
			eq.in_hospital_cd_3,
			eq.in_hospital_cd_4
		FROM
			om
			LEFT OUTER JOIN ord_material_save as save on om.ord_no = save.supplies_base_no
						and om.facility_cd = save.facility_cd
						and save.supplies_source_class = ''2''
						and save.ind_rst_class = ''1''
			INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = eq.equipment_cd
			AND eq.class_cd IN ( @eqIds )
			LEFT JOIN mst_dialyzer as dz ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = dz.dialyzer_cd
			AND dz.dialyzer_cd IN ( @diaIds )
			LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
			LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
			LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
		WHERE
			om.ord_no IN ( @ordNos )
	) equInfo
	GROUP BY
		treat_date,
		kind,
		class_cd,
		class,
		do_action,
		NAME,
		code,
		kur_cd,
		kur_name,
		Unit,
		bed_name,
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
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''抗凝固剤'' AS class,
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
		md.medicine_cd AS code,
		CEIL (
			(
				( CAST( om.ind_cond_info :: json #>> ''{26,value}'' AS DECIMAL) + CAST( om.ind_cond_info :: json #>> ''{28,value}'' AS DECIMAL) ) / ( CASE WHEN md.unit_converted_amount IS NULL OR md.unit_converted_amount = 0 THEN 1 ELSE md.unit_converted_amount END )
					) * ( CASE WHEN md.unit_converted_amount_second IS NULL OR md.unit_converted_amount_second = 0 THEN 1 ELSE md.unit_converted_amount_second END )
		) AS Amount,
		COALESCE ( md.unit, '''' ) AS Unit,
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
		om
		INNER JOIN md ON TO_NUMBER( om.ind_cond_info :: json #>> ''{25,value}'', ''99999999'' ) = md.medicine_cd
		AND md.class_cd IN ( @medIds )
		LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{25,value}'' IS NOT NULL 
	UNION ALL--抗凝固剤調製薬剤
	SELECT
				CASE WHEN @dataTypeOrder = ''0'' THEN 3
             WHEN @dataTypeOrder = ''1'' THEN 2
             WHEN @dataTypeOrder = ''2'' THEN 2
             WHEN @dataTypeOrder = ''3'' THEN 3
             WHEN @dataTypeOrder = ''4'' THEN 1
             WHEN @dataTypeOrder = ''5'' THEN 1
             ELSE 1  END AS disp_order,
				om.treat_date,
				kr.kur_cd,
				COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
				COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
				om.pat_id,
        ''抗凝固剤'' AS class,
			CASE

					WHEN mdc.class_name IS NULL THEN
					''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS kind,
							CASE
			WHEN mdc.class_name IS NULL THEN
			''-1'' ELSE mdc.class_cd
		END AS class_cd,
		''調製薬剤'' AS do_action,
				md.medicine_name AS NAME,
				md.medicine_cd AS code,
				CEIL (
					(
						( CAST( om.ind_cond_info :: json #>> ''{26,value}'' AS DECIMAL) + CAST( om.ind_cond_info :: json #>> ''{28,value}'' AS DECIMAL) ) * CAST(mix_info1->> ''amount'' AS DECIMAL) 
						 / ( CASE WHEN md.unit_converted_amount IS NULL OR md.unit_converted_amount = 0 THEN 1 ELSE md.unit_converted_amount END )
							) * ( CASE WHEN md.unit_converted_amount_second IS NULL OR md.unit_converted_amount_second = 0 THEN 1 ELSE md.unit_converted_amount_second END )
						) AS Amount,
						COALESCE ( md.unit, '''' ) AS Unit,
						md.in_hospital_cd_1,
						md.in_hospital_cd_2,
						md.in_hospital_cd_3,
						md.in_hospital_cd_4,
				''薬剤'' AS data_type_order,
				2 AS kind_order,
				NULL AS equipment_cd,
				NULL AS equipment_class_cd,
				mdx.medicine_mix_cd :: TEXT AS medicine_cd,
				mdc.class_cd :: TEXT AS medicine_class_cd,
			  NULL AS dialyzer_cd
					FROM
						om
						INNER JOIN mdx ON TO_NUMBER( om.ind_cond_info :: json #>> ''{25,value}'', ''99999999'' ) = mdx.medicine_mix_cd
						AND TO_NUMBER( om.ind_cond_info -> ''25'' ->> ''medicine_type'', ''999999999999'' ) = ''2''
						CROSS JOIN LATERAL json_array_elements ( mdx.mix_info :: json ) mix_info1
						INNER JOIN md ON TO_NUMBER( mix_info1->> ''cd'', ''99999999'' ) = md.medicine_cd
						AND md.class_cd IN ( @medIds )
						LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
						LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
						LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
					WHERE
						om.ord_no IN ( @ordNos )
						AND om.ind_cond_info :: json #>> ''{25,value}'' IS NOT NULL 
	UNION ALL--透析液
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 3
             WHEN @dataTypeOrder = ''1'' THEN 2
             WHEN @dataTypeOrder = ''2'' THEN 2
             WHEN @dataTypeOrder = ''3'' THEN 3
             WHEN @dataTypeOrder = ''4'' THEN 1
             WHEN @dataTypeOrder = ''5'' THEN 1
             ELSE 1  END AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''透析液'' AS class,
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
		md.medicine_cd AS code,
		CAST( om.ind_cond_info :: json #>> ''{17,value}'' AS DECIMAL) AS Amount,
		COALESCE ( md.unit, '''' ) AS Unit,
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
		om
		INNER JOIN md ON TO_NUMBER( om.ind_cond_info :: json #>> ''{15,value}'', ''99999999'' ) = md.medicine_cd
		AND md.class_cd IN ( @medIds )
		LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{15,value}'' IS NOT NULL
	UNION ALL--補液
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 3
             WHEN @dataTypeOrder = ''1'' THEN 2
             WHEN @dataTypeOrder = ''2'' THEN 2
             WHEN @dataTypeOrder = ''3'' THEN 3
             WHEN @dataTypeOrder = ''4'' THEN 1
             WHEN @dataTypeOrder = ''5'' THEN 1
             ELSE 1  END AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''補液'' AS class,
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
		md.medicine_cd AS code,
		CAST( om.ind_cond_info :: json #>> ''{22,value}'' AS DECIMAL) AS Amount,
		COALESCE ( md.unit, '''' ) AS Unit,
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
		om
		INNER JOIN md ON TO_NUMBER( om.ind_cond_info :: json #>> ''{19,value}'', ''99999999'' ) = md.medicine_cd
		AND md.class_cd IN ( @medIds )
		LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{19,value}'' IS NOT NULL
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
		, bed_name
		, pat_id
		, class
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
			om.treat_date,
			kr.kur_cd,
			COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.pat_id,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS class,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS kind,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''-1'' ELSE mdc.class_cd
				END AS class_cd,
			md.medicine_name AS NAME,
			md.medicine_cd AS code,
			CAST(save.ind_rst_value AS DECIMAL),
			COALESCE ( md.unit, '''' ) AS Unit,
			md.in_hospital_cd_1,
			md.in_hospital_cd_2,
			md.in_hospital_cd_3,
			md.in_hospital_cd_4
		FROM
			om
			LEFT OUTER JOIN ord_material_save as save on om.ord_no = save.supplies_base_no
						and om.facility_cd = save.facility_cd
						and save.supplies_source_class = ''1''
						and save.ind_rst_class = ''1''
						and save.supplies_class in (''12'', ''20'')
			INNER JOIN md ON TO_NUMBER( save.supplies_cd, ''99999999'' ) = md.medicine_cd
			AND md.class_cd IN ( @medIds )
			LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
			LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
			LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
		WHERE
			om.ord_no IN ( @ordNos ) 
	) medInfo
	GROUP BY
		treat_date,
		kind,
		class_cd,
		class,
		do_action,
		NAME,
		code,
		kur_cd,
		kur_name,
		Unit,
		bed_name,
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
		bed_name,
		pat_id
	)
	) AS EquipmentList
	LEFT OUTER JOIN medic ON medic.medic_code :: TEXT = EquipmentList.medicine_class_cd
	LEFT OUTER JOIN equic ON equic.equic_code = EquipmentList.equipment_class_cd
	LEFT OUTER JOIN dia ON dia.dia_code = EquipmentList.dialyzer_cd
	LEFT OUTER JOIN medi_mix ON medi_mix.medi_mix_code :: TEXT = EquipmentList.medicine_class_cd
) 
SELECT * from result_all as res @orderBy	', 2, '[{"preview": "1", "can_calc": "", "data_code": "kur_cd", "data_name": "クールコード", "data_type": "decimal", "conv_table": [], "data_class": "ベッド情報（分解）", "field_name": "kur_cd", "disp_format": "0", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": ""}, {"preview": "午後", "can_calc": "", "data_code": "kur_name", "data_name": "クール名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報（分解）", "field_name": "kur_name", "disp_format": "", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": ""}, {"preview": "北1", "can_calc": "", "data_code": "bed_name", "data_name": "ベッド名", "data_type": "string", "conv_table": [], "data_class": "ベッド情報（分解）", "field_name": "bed_name", "disp_format": "", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": ""}, {"preview": "テープ", "can_calc": "0", "data_code": "kind", "data_name": "分類名称", "data_type": "string", "conv_table": [], "data_class": "物品情報（分解）", "field_name": "kind", "disp_format": "", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "ダイアライザ", "can_calc": "0", "data_code": "class", "data_name": "データ分類", "data_type": "string", "conv_table": [], "data_class": "物品情報（分解）", "field_name": "class", "disp_format": "", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "70%ブドウ糖注射液350ml", "can_calc": "0", "data_code": "name", "data_name": "型番･名称", "data_type": "string", "conv_table": [], "data_class": "物品情報（分解）", "field_name": "name", "disp_format": "", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "10", "can_calc": "1", "data_code": "amount", "data_name": "数量", "data_type": "decimal", "conv_table": [], "data_class": "物品情報（分解）", "field_name": "amount", "disp_format": "0.00", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "個", "can_calc": "0", "data_code": "unit", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "物品情報（分解）", "field_name": "unit", "disp_format": "", "data_category": "配布リスト(物品)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789012", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "hosp_pat_id", "target_var": "@patId"}, "data_code": "hosp_pat_id", "data_name": "患者ID", "data_type": "string", "conv_table": [], "data_class": "基本情報（分解）", "field_name": "pat_id", "disp_format": "", "data_category": "配布リスト(物品)", "facility_filter_type": "0"}, {"preview": "テスト患者1", "can_calc": "0", "conv_sql": {"sql_cd": -1, "field_name": "pat_name", "target_var": "@patId"}, "data_code": "pat_name", "data_name": "患者名", "data_type": "string", "conv_table": [], "data_class": "基本情報（分解）", "field_name": "pat_id1", "disp_format": "", "data_category": "配布リスト(物品)", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [6]}', '配布リスト(物品)(分解)', '2020-01-11 13:28:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (243, 'WITH om AS ( SELECT * FROM ord_main WHERE is_del = ''0'' AND ord_no IN ( @ordNos ) ),
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
	),
	result_all as (
	SELECT
to_timestamp( treat_date, ''YYYYMMDD'' ) AS treat_date,
disp_order,
kind,
class_cd,
class,
do_action,
NAME,
code,
kur_cd,
kur_name,
Amount AS amount,
unit,
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
medi_mix.medi_mix_order
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
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''ダイアライザ'' AS class,
	CASE

			WHEN dz.model_number IS NOT NULL THEN
			''ダイアライザ'' ELSE NULL
		END AS kind,
	    ''0'' AS class_cd,
			''ダイアライザ'' AS do_action, 
		dz.model_number AS NAME,
		dz.dialyzer_cd AS code,
	CASE

			WHEN dz.model_number IS NOT NULL THEN
			1 ELSE NULL
		END AS Amount,
		COALESCE ( om.ind_cond_info :: json #>> ''{5,unit}'', ''本'' ) AS Unit,
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
		om
		INNER JOIN dz ON TO_NUMBER( om.ind_cond_info :: json #>> ''{5,value}'', ''99999999'' ) = dz.dialyzer_cd
		AND dz.dialyzer_cd IN ( @diaIds )
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{5,value}'' IS NOT NULL
	UNION ALL--吸着カラム
	SELECT
				CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 1
         WHEN @dataTypeOrder = ''2'' THEN 3
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''吸着カラム'' AS class,
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
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
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
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{6,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{6,value}'' IS NOT NULL
	UNION ALL--1次膜
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 1
         WHEN @dataTypeOrder = ''2'' THEN 3
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''1次膜'' AS class,
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
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
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
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{7,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{7,value}'' IS NOT NULL
	UNION ALL--2次膜
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 1
         WHEN @dataTypeOrder = ''2'' THEN 3
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''2次膜'' AS class,
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
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
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
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{8,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{8,value}'' IS NOT NULL
	UNION ALL--穿刺針(A針)
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 1
         WHEN @dataTypeOrder = ''2'' THEN 3
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''穿刺針(A)'' AS class,
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
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
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
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{9,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{9,value}'' IS NOT NULL
	UNION ALL--穿刺針(V針)
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 1
         WHEN @dataTypeOrder = ''2'' THEN 3
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''穿刺針(V)'' AS class,
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
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
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
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{10,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{10,value}'' IS NOT NULL
	UNION ALL--穿刺針(SN)
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 1
         WHEN @dataTypeOrder = ''2'' THEN 3
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''シングルニードル'' AS class,
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
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
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
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{11,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{11,value}'' IS NOT NULL
	UNION ALL--血液回路
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 1
         WHEN @dataTypeOrder = ''2'' THEN 3
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''血液回路'' AS class,
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
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
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
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{13,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{13,value}'' IS NOT NULL
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
		, bed_name
		, pat_id
		, class
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
			om.treat_date,
			kr.kur_cd,
			COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.pat_id,
			CASE
				WHEN eqc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
				END AS class,
			CASE
				WHEN eqc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
				END AS kind,
			CASE
				WHEN eqc.class_name IS NULL THEN
				''-1'' ELSE eqc.class_cd
				END AS class_cd,
			CASE WHEN save.supplies_class = ''01'' then dz.model_number
				ELSE eq.equipment_name
				END AS NAME,
			TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
			CAST(save.ind_rst_value AS DECIMAL),
			CASE WHEN save.supplies_class = ''01'' then ''本''
				ELSE COALESCE ( eq.unit, '''' )
				END AS Unit,
			eq.in_hospital_cd_1,
			eq.in_hospital_cd_2,
			eq.in_hospital_cd_3,
			eq.in_hospital_cd_4
		FROM
			om
			LEFT OUTER JOIN ord_material_save as save on om.ord_no = save.supplies_base_no
						and om.facility_cd = save.facility_cd
						and save.supplies_source_class = ''2''
						and save.ind_rst_class = ''1''
			INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = eq.equipment_cd
			AND eq.class_cd IN ( @eqIds )
			LEFT JOIN mst_dialyzer as dz ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = dz.dialyzer_cd
			AND dz.dialyzer_cd IN ( @diaIds )
			LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
			LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
			LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
		WHERE
			om.ord_no IN ( @ordNos ) 
	) equInfo
	GROUP BY
		treat_date,
		kind,
		class_cd,
		class,
		do_action,
		NAME,
		code,
		kur_cd,
		kur_name,
		Unit,
		bed_name,
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
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''抗凝固剤'' AS class,
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
		md.medicine_cd AS code,
		CEIL (
			(
				( CAST( om.ind_cond_info :: json #>> ''{26,value}'' AS DECIMAL) + CAST( om.ind_cond_info :: json #>> ''{28,value}'' AS DECIMAL) ) / ( CASE WHEN md.unit_converted_amount IS NULL OR md.unit_converted_amount = 0 THEN 1 ELSE md.unit_converted_amount END )
					) * ( CASE WHEN md.unit_converted_amount_second IS NULL OR md.unit_converted_amount_second = 0 THEN 1 ELSE md.unit_converted_amount_second END )
		) AS Amount,
		COALESCE ( md.unit, '''' ) AS Unit,
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
		om
		INNER JOIN md ON TO_NUMBER( om.ind_cond_info :: json #>> ''{25,value}'', ''99999999'' ) = md.medicine_cd
		AND md.class_cd IN ( @medIds )
		LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{25,value}'' IS NOT NULL	
	UNION ALL--抗凝固剤調製薬剤
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 1
         WHEN @dataTypeOrder = ''1'' THEN 2
         WHEN @dataTypeOrder = ''2'' THEN 2
         WHEN @dataTypeOrder = ''3'' THEN 1
         WHEN @dataTypeOrder = ''4'' THEN 3
         WHEN @dataTypeOrder = ''5'' THEN 3
         ELSE 1  END AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''抗凝固剤'' AS class,
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
		mdx.medicine_mix_cd AS code,
		( CAST( om.ind_cond_info :: json #>> ''{26,value}'' AS DECIMAL) + CAST( om.ind_cond_info :: json #>> ''{28,value}'' AS DECIMAL) ) AS Amount,
				COALESCE ( mdx.unit, '''' ) AS Unit,
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
				om
				INNER JOIN mdx ON mdx.medicine_mix_cd = TO_NUMBER( om.ind_cond_info -> ''25'' ->> ''value'', ''999999999999'' )
        AND TO_NUMBER( om.ind_cond_info -> ''25'' ->> ''medicine_type'', ''999999999999'' ) = ''2''
				LEFT OUTER JOIN mdc ON mdx.class_cd = mdc.class_cd
				LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
				LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
			WHERE
				om.ord_no IN ( @ordNos )
				AND om.ind_cond_info :: json #>> ''{25,value}'' IS NOT NULL
	UNION ALL--透析液
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 1
         WHEN @dataTypeOrder = ''1'' THEN 2
         WHEN @dataTypeOrder = ''2'' THEN 2
         WHEN @dataTypeOrder = ''3'' THEN 1
         WHEN @dataTypeOrder = ''4'' THEN 3
         WHEN @dataTypeOrder = ''5'' THEN 3
         ELSE 1  END AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''透析液'' AS class,
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
		md.medicine_cd AS code,
		CAST( om.ind_cond_info :: json #>> ''{17,value}'' AS DECIMAL) AS Amount,
		COALESCE ( md.unit_second, '''' ) AS Unit,
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
		om
		INNER JOIN md ON TO_NUMBER( om.ind_cond_info :: json #>> ''{15,value}'', ''99999999'' ) = md.medicine_cd
		AND md.class_cd IN ( @medIds )
		LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{15,value}'' IS NOT NULL
	UNION ALL--補液
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 1
         WHEN @dataTypeOrder = ''1'' THEN 2
         WHEN @dataTypeOrder = ''2'' THEN 2
         WHEN @dataTypeOrder = ''3'' THEN 1
         WHEN @dataTypeOrder = ''4'' THEN 3
         WHEN @dataTypeOrder = ''5'' THEN 3
         ELSE 1  END AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''補液'' AS class,
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
		md.medicine_cd AS code,
		CAST( om.ind_cond_info :: json #>> ''{22,value}'' AS DECIMAL) AS Amount,
		COALESCE ( md.unit_second, '''' ) AS Unit,
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
		om
		INNER JOIN md ON TO_NUMBER( om.ind_cond_info :: json #>> ''{19,value}'', ''99999999'' ) = md.medicine_cd
		AND md.class_cd IN ( @medIds )
		LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{19,value}'' IS NOT NULL 
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
		, bed_name
		, pat_id
		, class
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
			om.treat_date,
			kr.kur_cd,
			COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.pat_id,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS class,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS kind,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''-1'' ELSE mdc.class_cd
				END AS class_cd,
			md.medicine_name AS NAME,
			md.medicine_cd AS code,
			CAST(save.ind_rst_value AS DECIMAL),
			COALESCE ( md.unit, '''' ) AS Unit,
			md.in_hospital_cd_1,
			md.in_hospital_cd_2,
			md.in_hospital_cd_3,
			md.in_hospital_cd_4
		FROM
			om
			LEFT OUTER JOIN ord_material_save as save on om.ord_no = save.supplies_base_no
						and om.facility_cd = save.facility_cd
						and save.supplies_source_class = ''1''
						and save.supplies_class = ''12''
						and save.ind_rst_class = ''1''
			INNER JOIN md ON TO_NUMBER( save.supplies_cd, ''99999999'' ) = md.medicine_cd
			AND md.class_cd IN ( @medIds )
			LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
			LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
			LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
		WHERE
			om.ord_no IN ( @ordNos ) 
	) medInfo
	GROUP BY
		treat_date,
		kind,
		class_cd,
		class,
		do_action,
		NAME,
		code,
		kur_cd,
		kur_name,
		Unit,
		bed_name,
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
		, bed_name
		, pat_id
		, class
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
			om.treat_date,
			kr.kur_cd,
			COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.pat_id,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS class,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS kind,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''-1'' ELSE mdc.class_cd
				END AS class_cd,
			mdx.medicine_mix_name AS NAME,
			mdx.medicine_mix_cd AS code,
			CAST(save.ind_rst_value AS DECIMAL),
			COALESCE ( mdx.unit, '''' )  AS Unit,
			mdx.in_hospital_cd_1,
			mdx.in_hospital_cd_2,
			mdx.in_hospital_cd_3,
			null as in_hospital_cd_4
		FROM
			om
			LEFT OUTER JOIN ord_material_save as save on om.ord_no = save.supplies_base_no
						and om.facility_cd = save.facility_cd
						and save.supplies_source_class = ''1''
						and save.supplies_class = ''13''
						and save.ind_rst_class = ''1''
			INNER JOIN mdx ON TO_NUMBER(save.medicine_mix_cd, ''99999999'' ) = mdx.medicine_mix_cd
			AND mdx.class_cd IN ( @medIds )
			LEFT OUTER JOIN mdc ON mdx.class_cd = mdc.class_cd
			LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
			LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
		WHERE
			om.ord_no IN ( @ordNos )
	) medInfo
	GROUP BY
		treat_date,
		kind,
		class_cd,
		class,
		do_action,
		NAME,
		code,
		kur_cd,
		kur_name,
		Unit,
		bed_name,
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
		bed_name,
		pat_id
	)
	) AS EquipmentList
	LEFT OUTER JOIN medic ON medic.medic_code :: TEXT = EquipmentList.medicine_class_cd
	LEFT OUTER JOIN equic ON equic.equic_code = EquipmentList.equipment_class_cd
	LEFT OUTER JOIN dia ON dia.dia_code = EquipmentList.dialyzer_cd
	LEFT OUTER JOIN medi_mix ON medi_mix.medi_mix_code :: TEXT = EquipmentList.medicine_class_cd
) 
SELECT * from result_all as res @orderBy	', 2, '[]', '1', '{"applications": [1]}', '{"classes": [6]}', '配布リスト(物品)（SQL11降順）', '2025-03-19 18:29:56.853', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (244, 'WITH om AS ( SELECT * FROM ord_main WHERE is_del = ''0'' AND ord_no IN ( @ordNos ) ),
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
	),
	result_all as (
	SELECT
	disp_order,
to_timestamp( treat_date, ''YYYYMMDD'' ) AS treat_date,
kind,
class,
class_cd,
do_action,
NAME,
code,
kur_cd,
kur_name,
Amount AS amount,
unit,
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
medi_mix.medi_mix_order
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
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''ダイアライザ'' AS class,
	CASE

			WHEN dz.model_number IS NOT NULL THEN
			''ダイアライザ'' ELSE NULL
		END AS kind,
		''0'' AS class_cd,
		''ダイアライザ'' AS do_action, 
		dz.model_number AS NAME,
		dz.dialyzer_cd AS code,
	CASE

			WHEN dz.model_number IS NOT NULL THEN
			1 ELSE NULL
		END AS Amount,
		COALESCE ( om.ind_cond_info :: json #>> ''{5,unit}'', ''本'' ) AS Unit,
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
		om
		INNER JOIN dz ON TO_NUMBER( om.ind_cond_info :: json #>> ''{5,value}'', ''99999999'' ) = dz.dialyzer_cd
		AND dz.dialyzer_cd IN ( @diaIds )
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{5,value}'' IS NOT NULL
	UNION ALL--吸着カラム
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 1
         WHEN @dataTypeOrder = ''2'' THEN 3
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''吸着カラム'' AS class,
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
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
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
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{6,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{6,value}'' IS NOT NULL
	UNION ALL--1次膜
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 1
         WHEN @dataTypeOrder = ''2'' THEN 3
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''1次膜'' AS class,
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
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
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
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{7,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{7,value}'' IS NOT NULL
	UNION ALL--2次膜
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 1
         WHEN @dataTypeOrder = ''2'' THEN 3
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''2次膜'' AS class,
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
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
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
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{8,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{8,value}'' IS NOT NULL
	UNION ALL--穿刺針(A針)
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 1
         WHEN @dataTypeOrder = ''2'' THEN 3
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''穿刺針(A)'' AS class,
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
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
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
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{9,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{9,value}'' IS NOT NULL
	UNION ALL--穿刺針(V針)
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 1
         WHEN @dataTypeOrder = ''2'' THEN 3
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''穿刺針(V)'' AS class,
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
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
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
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{10,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{10,value}'' IS NOT NULL
	UNION ALL--穿刺針(SN)
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 1
         WHEN @dataTypeOrder = ''2'' THEN 3
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''シングルニードル'' AS class,
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
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
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
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{11,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{11,value}'' IS NOT NULL
	UNION ALL--血液回路
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 2
         WHEN @dataTypeOrder = ''1'' THEN 1
         WHEN @dataTypeOrder = ''2'' THEN 3
         WHEN @dataTypeOrder = ''3'' THEN 3
         WHEN @dataTypeOrder = ''4'' THEN 2
         WHEN @dataTypeOrder = ''5'' THEN 1
         ELSE 1  END AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''血液回路'' AS class,
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
		eq.equipment_cd AS code,
		1 AS Amount,
		COALESCE ( eq.unit, '''' ) AS Unit,
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
		om
		INNER JOIN eq ON TO_NUMBER( om.ind_cond_info :: json #>> ''{13,value}'', ''99999999'' ) = eq.equipment_cd
		AND eq.class_cd IN ( @eqIds )
		LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{13,value}'' IS NOT NULL
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
		, bed_name
		, pat_id
		, class
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
			om.treat_date,
			kr.kur_cd,
			COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.pat_id,
			CASE
				WHEN eqc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
				END AS class,
			CASE
				WHEN eqc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( eqc.class_name, '''' )
				END AS kind,
			CASE
				WHEN eqc.class_name IS NULL THEN
				''-1'' ELSE eqc.class_cd
				END AS class_cd,
			CASE WHEN save.supplies_class = ''01'' then dz.model_number
				ELSE eq.equipment_name
				END AS NAME,
			TO_NUMBER(save.supplies_cd, ''99999999'' ) AS code,
			CAST(save.ind_rst_value  AS DECIMAL),
			CASE WHEN save.supplies_class = ''01'' then ''本''
				ELSE COALESCE ( eq.unit, '''' )
				END AS Unit,
			eq.in_hospital_cd_1,
			eq.in_hospital_cd_2,
			eq.in_hospital_cd_3,
			eq.in_hospital_cd_4
		FROM
			om
			LEFT OUTER JOIN ord_material_save as save on om.ord_no = save.supplies_base_no
						and om.facility_cd = save.facility_cd
						and save.supplies_source_class = ''2''
						and save.ind_rst_class = ''1''
			INNER JOIN eq ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = eq.equipment_cd
			AND eq.class_cd IN ( @eqIds )
			LEFT JOIN mst_dialyzer as dz ON TO_NUMBER(save.supplies_cd, ''99999999'' ) = dz.dialyzer_cd
			AND dz.dialyzer_cd IN ( @diaIds )
			LEFT OUTER JOIN eqc ON eq.class_cd = eqc.class_cd
			LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
			LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
		WHERE
			om.ord_no IN ( @ordNos )
	) equInfo
	GROUP BY
		treat_date,
		kind,
		class_cd,
		class,
		do_action,
		NAME,
		code,
		kur_cd,
		kur_name,
		Unit,
		bed_name,
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
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''抗凝固剤'' AS class,
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
		md.medicine_cd AS code,
		CEIL (
			(
				( CAST( om.ind_cond_info :: json #>> ''{26,value}'' AS DECIMAL) + CAST( om.ind_cond_info :: json #>> ''{28,value}'' AS DECIMAL) ) / ( CASE WHEN md.unit_converted_amount IS NULL OR md.unit_converted_amount = 0 THEN 1 ELSE md.unit_converted_amount END )
					) * ( CASE WHEN md.unit_converted_amount_second IS NULL OR md.unit_converted_amount_second = 0 THEN 1 ELSE md.unit_converted_amount_second END )
		) AS Amount,
		COALESCE ( md.unit, '''' ) AS Unit,
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
		om
		INNER JOIN md ON TO_NUMBER( om.ind_cond_info :: json #>> ''{25,value}'', ''99999999'' ) = md.medicine_cd
		AND md.class_cd IN ( @medIds )
		LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{25,value}'' IS NOT NULL 
	UNION ALL--抗凝固剤調製薬剤
	SELECT
				CASE WHEN @dataTypeOrder = ''0'' THEN 1
             WHEN @dataTypeOrder = ''1'' THEN 2
             WHEN @dataTypeOrder = ''2'' THEN 2
             WHEN @dataTypeOrder = ''3'' THEN 1
             WHEN @dataTypeOrder = ''4'' THEN 3
             WHEN @dataTypeOrder = ''5'' THEN 3
             ELSE 1  END AS disp_order,
				om.treat_date,
				kr.kur_cd,
				COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
				COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
				om.pat_id,
        ''抗凝固剤'' AS class,
			CASE

					WHEN mdc.class_name IS NULL THEN
					''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS kind,
							CASE
			WHEN mdc.class_name IS NULL THEN
			''-1'' ELSE mdc.class_cd
		END AS class_cd,
		''調製薬剤'' AS do_action,
				md.medicine_name AS NAME,
				md.medicine_cd AS code,
				CEIL (
					(
						( CAST( om.ind_cond_info :: json #>> ''{26,value}'' AS DECIMAL) + CAST( om.ind_cond_info :: json #>> ''{28,value}'' AS DECIMAL) ) * CAST(mix_info1->> ''amount'' AS DECIMAL) 
						 / ( CASE WHEN md.unit_converted_amount IS NULL OR md.unit_converted_amount = 0 THEN 1 ELSE md.unit_converted_amount END )
							) * ( CASE WHEN md.unit_converted_amount_second IS NULL OR md.unit_converted_amount_second = 0 THEN 1 ELSE md.unit_converted_amount_second END )
						) AS Amount,
						COALESCE ( md.unit, '''' ) AS Unit,
						md.in_hospital_cd_1,
						md.in_hospital_cd_2,
						md.in_hospital_cd_3,
						md.in_hospital_cd_4,
				''薬剤'' AS data_type_order,
				2 AS kind_order,
				NULL AS equipment_cd,
				NULL AS equipment_class_cd,
				mdx.medicine_mix_cd :: TEXT AS medicine_cd,
				mdc.class_cd :: TEXT AS medicine_class_cd,
			  NULL AS dialyzer_cd
					FROM
						om
						INNER JOIN mdx ON TO_NUMBER( om.ind_cond_info :: json #>> ''{25,value}'', ''99999999'' ) = mdx.medicine_mix_cd
						AND TO_NUMBER( om.ind_cond_info -> ''25'' ->> ''medicine_type'', ''999999999999'' ) = ''2''
						CROSS JOIN LATERAL json_array_elements ( mdx.mix_info :: json ) mix_info1
						INNER JOIN md ON TO_NUMBER( mix_info1->> ''cd'', ''99999999'' ) = md.medicine_cd
						AND md.class_cd IN ( @medIds )
						LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
						LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
						LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
					WHERE
						om.ord_no IN ( @ordNos )
						AND om.ind_cond_info :: json #>> ''{25,value}'' IS NOT NULL
	UNION ALL--透析液
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 1
             WHEN @dataTypeOrder = ''1'' THEN 2
             WHEN @dataTypeOrder = ''2'' THEN 2
             WHEN @dataTypeOrder = ''3'' THEN 1
             WHEN @dataTypeOrder = ''4'' THEN 3
             WHEN @dataTypeOrder = ''5'' THEN 3
             ELSE 1  END AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''透析液'' AS class,
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
		md.medicine_cd AS code,
		CAST( om.ind_cond_info :: json #>> ''{17,value}'' AS DECIMAL) AS Amount,
		COALESCE ( md.unit, '''' ) AS Unit,
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
		om
		INNER JOIN md ON TO_NUMBER( om.ind_cond_info :: json #>> ''{15,value}'', ''99999999'' ) = md.medicine_cd
		AND md.class_cd IN ( @medIds )
		LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{15,value}'' IS NOT NULL
	UNION ALL--補液
	SELECT
		CASE WHEN @dataTypeOrder = ''0'' THEN 1
             WHEN @dataTypeOrder = ''1'' THEN 2
             WHEN @dataTypeOrder = ''2'' THEN 2
             WHEN @dataTypeOrder = ''3'' THEN 1
             WHEN @dataTypeOrder = ''4'' THEN 3
             WHEN @dataTypeOrder = ''5'' THEN 3
             ELSE 1  END AS disp_order,
		om.treat_date,
		kr.kur_cd,
		COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
		COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
		om.pat_id,
    ''補液'' AS class,
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
		md.medicine_cd AS code,
		CAST( om.ind_cond_info :: json #>> ''{22,value}'' AS DECIMAL) AS Amount,
		COALESCE ( md.unit, '''' ) AS Unit,
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
		om
		INNER JOIN md ON TO_NUMBER( om.ind_cond_info :: json #>> ''{19,value}'', ''99999999'' ) = md.medicine_cd
		AND md.class_cd IN ( @medIds )
		LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
		LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
		LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
	WHERE
		om.ord_no IN ( @ordNos )
		AND om.ind_cond_info :: json #>> ''{19,value}'' IS NOT NULL
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
		, bed_name
		, pat_id
		, class
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
			om.treat_date,
			kr.kur_cd,
			COALESCE ( kr.kur_name, ''未登録'' ) AS kur_name,
			COALESCE ( bd.bed_name, ''未登録'' ) AS bed_name,
			om.pat_id,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS class,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''未分類'' ELSE COALESCE ( mdc.class_name, '''' )
				END AS kind,
			CASE
				WHEN mdc.class_name IS NULL THEN
				''-1'' ELSE mdc.class_cd
				END AS class_cd,
			md.medicine_name AS NAME,
			md.medicine_cd AS code,
			CAST(save.ind_rst_value AS DECIMAL),
			COALESCE ( md.unit, '''' ) AS Unit,
			md.in_hospital_cd_1,
			md.in_hospital_cd_2,
			md.in_hospital_cd_3,
			md.in_hospital_cd_4
		FROM
			om
			LEFT OUTER JOIN ord_material_save as save on om.ord_no = save.supplies_base_no
						and om.facility_cd = save.facility_cd
						and save.supplies_source_class = ''1''
						and save.ind_rst_class = ''1''
						and save.supplies_class in (''12'', ''20'')
			INNER JOIN md ON TO_NUMBER( save.supplies_cd, ''99999999'' ) = md.medicine_cd
			AND md.class_cd IN ( @medIds )
			LEFT OUTER JOIN mdc ON md.class_cd = mdc.class_cd
			LEFT OUTER JOIN kr ON om.ind_kur_cd = kr.kur_cd
			LEFT OUTER JOIN bd ON om.ind_bed_cd = bd.bed_cd
		WHERE
			om.ord_no IN ( @ordNos ) 
	) medInfo
	GROUP BY
		treat_date,
		kind,
		class_cd,
		class,
		do_action,
		NAME,
		code,
		kur_cd,
		kur_name,
		Unit,
		bed_name,
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
		bed_name,
		pat_id
	)
	) AS EquipmentList
	LEFT OUTER JOIN medic ON medic.medic_code :: TEXT = EquipmentList.medicine_class_cd
	LEFT OUTER JOIN equic ON equic.equic_code = EquipmentList.equipment_class_cd
	LEFT OUTER JOIN dia ON dia.dia_code = EquipmentList.dialyzer_cd
	LEFT OUTER JOIN medi_mix ON medi_mix.medi_mix_code :: TEXT = EquipmentList.medicine_class_cd
) 
SELECT * from result_all as res @orderBy', 2, '[]', '1', '{"applications": [1]}', '{"classes": [6]}', '配布リスト(物品)(分解)（SQL206降順）', '2025-03-19 18:29:56.857', CURRENT_TIMESTAMP, NULL);
