delete from "sys_data_set" where "sql_cd" in (-204,-34,-13);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-204, 'SELECT
  to_char(ROW_NUMBER() OVER (), ''FM000'') AS cost_no
  , cost_fin.* 
FROM
  ( 
    SELECT
      all_cost.* 
    FROM
      ( 
        SELECT --加算情報
          ''指示詳細'' AS detail_id
          , ''加算'' AS sbt_key
          , mdd.in_hospital_cd_1 AS e01 --コード
          , ''0'' AS e02
          , COALESCE(mdd.in_hospital_cd_2, ''20'') AS e03
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''01'' AS e07 
        FROM
          mst_dialysis_difficulty mdd 
        WHERE
          mdd.dialysis_difficulty_cd IN (SELECT regexp_split_to_table(@mstCddd, '','')::INT)
          AND mdd.is_del = ''0'' 
        UNION 
        SELECT --VA情報
          ''指示詳細'' AS detail_id
          , ''VA'' AS sbt_key
          , mva.in_hospital_cd_1 AS e01
          , ''1'' AS e02
          , COALESCE(mva.in_hospital_cd_2, ''21'') AS e03
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''02'' AS e07 
        FROM
          ord_main ord 
          LEFT OUTER JOIN mst_va AS mva 
            ON mva.va_cd = TO_NUMBER( ord.ind_cond_info -> ''2'' ->> ''value'', ''FM999999999999'') 
        WHERE
          ord.ord_no = @ordNo 
        UNION 
        SELECT --治療項目情報
          ''指示詳細'' AS detail_id
          , ''治療項目'' AS sbt_key
          , mtt.in_hospital_cd_a1 AS e01 --治療コード
          , ''1'' AS e02
          , COALESCE(mtt.in_hospital_cd_a2, ''21'') AS e03
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''03'' AS e07 
        FROM
          ord_main ord 
          LEFT OUTER JOIN mst_treatment AS mtt 
            ON mtt.treatment_cd = ord.ind_treatment_cd 
        WHERE
          ord.ord_no = @ordNo 
        UNION 
        SELECT --ダイアライザ情報
          ''指示詳細'' AS detail_id
          , ''ダイアライザ'' AS sbt_key
          , mdz.in_hospital_cd_1 AS e01
          , ''1'' AS e02
          , COALESCE(mdz.in_hospital_cd_2, ''25'') AS e03
          , ''000010000'' AS e04
          , ''HON'' AS e5
          , ''000000000'' AS e06
          , ''04'' AS e07 
        FROM
          ord_main ord 
          LEFT OUTER JOIN mst_dialyzer AS mdz 
            ON mdz.dialyzer_cd = TO_NUMBER( ord.ind_cond_info -> ''5'' ->> ''value'', ''FM999999999999'') 
        WHERE
          ord.ord_no = @ordNo 
        UNION 
        SELECT --医材内ダイアライザ情報
          ''指示詳細'' AS detail_id
          , ''ダイアライザ'' AS sbt_key
          , mdz.in_hospital_cd_1 AS e01
          , ''1'' AS e02
          , COALESCE(mdz.in_hospital_cd_2, ''25'') AS e03
          , ''000010000'' AS e04
          , ''HON'' AS e5
          , ''000000000'' AS e06
          , ''05'' AS e07 
        FROM
          ord_main ord 
          CROSS JOIN LATERAL json_array_elements(ord.ind_equip_info ::json) equip 
          LEFT OUTER JOIN mst_dialyzer AS mdz 
            ON mdz.dialyzer_cd = TO_NUMBER(equip ->> ''cd'', ''FM999999999999'') 
        WHERE
          equip ->> ''equip_type'' = ''1'' 
          AND ord.ord_no = @ordNo 
        UNION 
        SELECT --抗凝固剤(単独分）
          ''指示詳細'' AS detail_id
          , ''抗凝固剤'' AS sbt_cd
          , mmd.in_hospital_cd_1 AS e01
          , ''1'' AS e02
          , COALESCE(mmd.in_hospital_cd_2, ''25'') AS e03
          , to_char( 
            ( 
              TO_NUMBER( 
                COALESCE(ord.ind_cond_info -> ''26'' ->> ''value'', ''0'')
                , ''FM999999999.999''
              ) + TO_NUMBER( 
                COALESCE(ord.ind_cond_info -> ''28'' ->> ''value'', ''0'')
                , ''FM999999999.999''
              )
            ) / mmd.unit_converted_amount * mmd.unit_converted_amount_second * 1000
            , ''FM999999999''
          ) AS e04
          , mmd.unit_second AS e05
          , ''000000000'' AS e06
          , ''06'' AS e07 
        FROM
          ord_main ord 
          LEFT OUTER JOIN mst_medicine AS mmd 
            ON mmd.medicine_cd = TO_NUMBER( ord.ind_cond_info -> ''25'' ->> ''value'', ''FM999999999999'') 
        WHERE
          ord.ind_cond_info -> ''25'' ->> ''medicine_type'' = ''1'' 
          AND ord.ord_no = @ordNo 
        UNION 
        SELECT --抗凝固剤(調製分）
          ''指示詳細'' AS detail_id
          , ''抗凝固剤'' AS sbt_key
          , mmd.in_hospital_cd_1 AS e01 
          , ''1'' AS e02
          , COALESCE(mmd.in_hospital_cd_2, ''25'') AS e03
          , ( 
            CASE mmxd ->> ''solvent'' 
              WHEN ''1'' THEN to_char( 
                to_number(mmxd ->> ''amount'', ''FM99999.9999'') * 1000
                , ''FM999999999''
              ) 
              ELSE to_char( 
                ( 
                  TO_NUMBER( 
                    COALESCE(ord.ind_cond_info -> ''26'' ->> ''value'', ''0'')
                    , ''FM99999.9999''
                  ) + TO_NUMBER( 
                    COALESCE(ord.ind_cond_info -> ''28'' ->> ''value'', ''0'')
                    , ''FM99999.9999''
                  )
                ) / mmx2.amount_unit * to_number(mmxd ->> ''amount'', ''FM99999.9999'') * 1000
                , ''FM999999999''
              ) 
              END
          ) AS e04
          , mmd.unit AS e05
          , ''000000000'' AS e06
          , ''07'' AS e07 
        FROM
          ord_main AS ord 
          LEFT OUTER JOIN mst_medicine_mix AS mmx 
            ON mmx.medicine_mix_cd = TO_NUMBER( ord.ind_cond_info -> ''25'' ->> ''value'', ''F<999999999999'') 
          , mst_medicine_mix AS mmx2 
          CROSS JOIN LATERAL json_array_elements(mmx2.mix_info ::json) mmxd 
          LEFT OUTER JOIN mst_medicine AS mmd 
            ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''FM999999999999'') 
        WHERE
          ord.ind_cond_info -> ''25'' ->> ''medicine_type'' = ''2'' 
          AND ord.ord_no = @ordNo 
        UNION 
        SELECT --透析液情報
          ''指示詳細'' AS detail_id
          , ''透析液'' AS sbt_key
          , mmd.in_hospital_cd_1 AS e01
          , ''1'' AS e02
          , COALESCE(mmd.in_hospital_cd_2, ''27'') AS e03
          , to_char( 
            TO_NUMBER( 
              COALESCE(ord.ind_cond_info -> ''17'' ->> ''value'', ''0'')
              , ''FM999999999.999''
            ) 
            , ''FM999990.999''
          ) AS e4
          , mmd.unit AS e05 
          , ''000000000'' AS e06
          , ''08'' AS e07 
        FROM
          ord_main ord 
          LEFT OUTER JOIN mst_medicine AS mmd 
            ON mmd.medicine_cd = TO_NUMBER( ord.ind_cond_info -> ''15'' ->> ''value'', ''FM999999999999'') 
        WHERE
          ord.ord_no = @ordNo 
        UNION 
        SELECT --補液情報
          ''指示詳細'' AS detail_id
          , ''補液'' AS sbt_key
          , mmd.in_hospital_cd_1 AS e01
          , ''1'' AS e02
          , COALESCE(mmd.in_hospital_cd_2, ''27'') AS e03
          , to_char( 
            TO_NUMBER( 
              COALESCE(ord.ind_cond_info -> ''22'' ->> ''value'', ''0'')
              , ''FM99999.9999''
            ) * 1000
            , ''FM999999999''
          ) AS e04
          , mmd.unit AS e05
          , ''000000000'' AS e06
          , ''09'' AS e07 
        FROM
          ord_main ord 
          LEFT OUTER JOIN mst_medicine AS mmd 
            ON mmd.medicine_cd = TO_NUMBER( ord.ind_cond_info -> ''19'' ->> ''value'', ''FM999999999999'') 
        WHERE
          ord.ord_no = @ordNo 
        UNION 
        SELECT --投与薬剤情報(通常)
          ''指示詳細'' AS detail_id
          , ''投与薬剤'' AS sbt_key
          , mmd.in_hospital_cd_1 AS e01
          , ''1'' AS e02
          , COALESCE(mmd.in_hospital_cd_2, ''27'') AS e03
          , ( 
            CASE mmd.in_hospital_cd_2 
              WHEN ''30'' THEN ''000000000'' 
              WHEN ''32'' THEN ''000000000'' 
              WHEN ''3A'' THEN ''000000000'' 
              WHEN ''3B'' THEN ''000000000'' 
              WHEN ''3C'' THEN ''000000000'' 
              ELSE to_char( 
                to_number(medi ->> ''amount'', ''FM99999.9999'') * 1000
                , ''FM999999999''
              ) 
              END
          ) AS e04 
          , medi ->> ''unit'' AS e05
          , ''000000000'' AS e06
          , ''10'' AS e07 
        FROM
          ord_main AS ord 
          CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info ::json) medi 
          LEFT OUTER JOIN mst_medicine AS mmd 
            ON mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'', ''FM999999999999'') 
          LEFT OUTER JOIN mst_procedure AS mp 
            ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''FM999999999999'') 
        WHERE
          medi ->> ''medicine_type'' = ''1'' 
          AND ord.ord_no = @ordNo 
          --order by medi ->> ''effect_date'',medi ->> ''cd''
        UNION 
        SELECT --投与薬剤情報(調製)
          ''指示詳細'' AS detail_id
          , ''調製'' AS sbt_key
          , mmd.in_hospital_cd_1 AS e01
          , ''1'' AS e02
          , COALESCE(mmd.in_hospital_cd_2, ''27'') AS e03
          , ( 
            CASE mmxd ->> ''solvent'' 
              WHEN ''1'' THEN to_char( 
                to_number(mmxd ->> ''amount'', ''FM99999.9999'') * 1000
                , ''FM999999999''
              ) 
              ELSE to_char( 
                to_number(medi ->> ''amount'', ''FM99999.9999'') / mmx2.amount_unit * to_number(mmxd ->> ''amount'', ''FM99999.9999'')
                 * 1000
                , ''FM999999999''
              ) 
              END
          ) AS e04
          , COALESCE(mmd.unit_second, mmd.unit) AS e05 
          , ''000000000'' AS e06
          , ''11'' AS e07 
        FROM
          ord_main AS ord 
          CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info ::json) medi 
          LEFT OUTER JOIN mst_procedure AS mp 
            ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''FM999999999999'') 
          LEFT OUTER JOIN mst_medicine_mix AS mmx 
            ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''FM999999999999'')
          , mst_medicine_mix AS mmx2 
          CROSS JOIN LATERAL json_array_elements(mmx2.mix_info ::json) mmxd 
          LEFT OUTER JOIN mst_medicine AS mmd 
            ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''FM999999999999'') 
        WHERE
          medi ->> ''medicine_type'' = ''2'' 
          AND ord.ord_no = @ordNo 
        UNION 
        SELECT --A針情報
          ''指示詳細'' AS detail_id
          , ''A針'' AS sbt_key
          , meq.in_hospital_cd_1 AS e01
          , ''1'' AS e02
          , COALESCE(meq.in_hospital_cd_2, ''28'') AS e03
          , ''000010000'' AS e04
          , meq.unit AS e05
          , ''000000000'' AS e06
          , ''13'' AS e07 
        FROM
          ord_main ord 
          LEFT OUTER JOIN mst_equipment AS meq 
            ON meq.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''9'' ->> ''value'', ''FM999999999999'') 
        WHERE
          ord.ord_no = @ordNo 
        UNION 
        SELECT --V針情報
          ''指示詳細'' AS detail_id
          , ''V針'' AS sbt_key
          , meq.in_hospital_cd_1 AS e01
          , ''1'' AS e02
          , COALESCE(meq.in_hospital_cd_2, ''28'') AS e03
          , ''000010000'' AS e04
          , meq.unit AS e05
          , ''000000000'' AS e06
          , ''14'' AS e07 
        FROM
          ord_main ord 
          LEFT OUTER JOIN mst_equipment AS meq 
            ON meq.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''10'' ->> ''value'', ''FM999999999999'') 
        WHERE
          ord.ord_no = @ordNo 
        UNION 
        SELECT --SN針情報
          ''指示詳細'' AS detail_id
          , ''SN針'' AS sbt_key
          , meq.in_hospital_cd_1 AS e01
          , ''1'' AS e02
          , COALESCE(meq.in_hospital_cd_2, ''28'') AS e03
          , ''000010000'' AS e04
          , meq.unit AS e05
          , ''000000000'' AS e06
          , ''15'' AS e07 
        FROM
          ord_main ord 
          LEFT OUTER JOIN mst_equipment AS meq 
            ON meq.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''11'' ->> ''value'', ''FM999999999999'') 
        WHERE
          ord.ord_no = @ordNo 
        UNION 
        SELECT --医材内穿刺針情報
          ''指示詳細'' AS detail_id
          , ''穿刺針'' AS sbt_key
          , meq.in_hospital_cd_1 AS e01
          , ''1'' AS e02
          , COALESCE(meq.in_hospital_cd_2, ''28'') AS e03
          , equip ->> ''amount'' AS e04
          , equip ->> ''unit'' AS e05
          , ''000000000'' AS e06
          , ''16'' AS e07 
        FROM
          ord_main ord 
          CROSS JOIN LATERAL json_array_elements(ord.ind_equip_info ::json) equip 
          LEFT OUTER JOIN mst_equipment AS meq 
            ON meq.equipment_cd = TO_NUMBER(equip ->> ''cd'', ''FM999999999999'') 
        WHERE
          equip ->> ''class_type'' IN (''2'', ''3'') 
          AND ord.ord_no = @ordNo 
        UNION 
        SELECT --医材情報
          ''指示詳細'' AS detail_id
          , ''医材'' AS sbt_key
          , meq.in_hospital_cd_1 AS e01
          , ''1'' AS e02
          , COALESCE(meq.in_hospital_cd_2, ''29'') AS e03
          , to_char( 
            to_number(equip ->> ''amount'', ''99999.9999'') * 1000
            , ''FM999999999''
          ) AS e04
          , equip ->> ''unit'' AS e05
          , ''000000000'' AS e06
          , ''17'' AS e07 
        FROM
          ord_main ord 
          CROSS JOIN LATERAL json_array_elements(ord.ind_equip_info ::json) equip 
          LEFT OUTER JOIN mst_equipment AS meq 
            ON meq.equipment_cd = TO_NUMBER(equip ->> ''cd'', ''FM999999999999'') 
        WHERE
          equip ->> ''equip_type'' = ''0'' 
          AND equip ->> ''class_type'' NOT IN (''2'', ''3'') 
          AND ord.ord_no = @ordNo 
        UNION 
        SELECT --1次膜情報
          ''指示詳細'' AS detail_id
          , ''1次膜'' AS sbt_key
          , meq.in_hospital_cd_1 AS e01
          , ''1'' AS e02
          , COALESCE(meq.in_hospital_cd_2, ''29'') AS e03
          , ''000010000'' AS e05
          , meq.unit AS e6
          , ''000000000'' AS e06
          , ''18'' AS e07 
        FROM
          ord_main ord 
          LEFT OUTER JOIN mst_equipment AS meq 
            ON meq.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''7'' ->> ''value'', ''FM999999999999'') 
        WHERE
          ord.ord_no = @ordNo 
        UNION 
        SELECT --2次膜情報
          ''指示詳細'' AS detail_id
          , ''2次膜'' AS sbt_key
          , meq.in_hospital_cd_1 AS e01
          , ''1'' AS e02
          , COALESCE(meq.in_hospital_cd_2, ''29'') AS e03
          , ''000010000'' AS e05
          , meq.unit AS e6
          , ''000000000'' AS e06
          , ''19'' AS e07 
        FROM
          ord_main ord 
          LEFT OUTER JOIN mst_equipment AS meq 
            ON meq.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''8'' ->> ''value'', ''FM999999999999'') 
        WHERE
          ord.ord_no = @ordNo 
        UNION 
        SELECT --透析所要時間情報
          ''指示詳細'' AS detail_id
          , ''所要時間'' AS sbt_key
          , ''999999'' AS e01 --コード
          , ''1'' AS e02
          , ''31'' AS e03 --項目名
          , to_char( 
            TO_NUMBER( 
              ord.ind_cond_info -> ''1'' ->> ''value''
              , ''FM999999999999''
            ) * 1000
            , ''FM999999999''
          ) AS e04
          , ''MI'' AS e05
          , ''000000000'' AS e06
          , ''20'' AS e07 
        FROM
          ord_main ord 
        WHERE
          ord.ord_no = @ordNo
      ) all_cost 
    WHERE
      all_cost.e01 IS NOT NULL 
    ORDER BY
      all_cost.e07, all_cost.e01
  ) cost_fin
', 2, '[{}]', '0', '{"applications": [4]}', NULL, 'NEC)詳細指示繰り返し部', '2020-05-20 11:39:52.001', '2020-05-20 11:39:58.001', '[{"sql_cd": -206, "field_name": "pat_dial_diff_cd", "replace_var": "@mstCddd"}]');
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-34, 'SELECT --DW情報
ord.treat_date AS dw_date,
physical ->> ''dw'' AS dw 
FROM
	ord_main ord,
	pat_unique puq
	CROSS JOIN LATERAL json_array_elements ( puq.physical_info :: json ) physical 
WHERE
	ord.pat_id = puq.pat_id 
	AND physical ->> ''exam_date'' = (
	SELECT MAX
		( physical2 ->> ''exam_date'' ) 
	FROM
		ord_main ord2,
		pat_unique puq2
		CROSS JOIN LATERAL json_array_elements ( puq2.physical_info :: json ) physical2 
	WHERE
		TO_CHAR(CAST(physical2 ->> ''exam_date'' AS TIMESTAMP), ''YYYYMMDD'') <= ord.treat_date 
		AND COALESCE ( physical2 ->> ''dw'', ''ZERO'' ) <> ''ZERO'' 
		AND ord.pat_id = puq2.pat_id 
	) 
	AND ord.ord_no = @ordNo', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）直近のDW抽出（ordNo）', '2020-05-20 10:35:18', '2020-05-20 10:35:21.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-13, 'SELECT
  ord.treat_date AS dialysis_date,
  ord.facility_cd AS facility_cd,
  COALESCE ( concat ( ord.ind_schedule_user_info ->> ''ind_user_last_name'', '' '', ord.ind_schedule_user_info ->> ''ind_user_first_name'' ), '''' ) AS ind_name,
  COALESCE ( LEFT ( concat ( ord.ind_schedule_user_info ->> ''ind_user_last_name'', '' '', ord.ind_schedule_user_info ->> ''ind_user_first_name'' ), 5 ), '''' ) AS ind_name10,
  COALESCE ( ord.ind_treat_start_time, '''' ) AS start_time,
  COALESCE ( mkr.in_hospital_cd_1, '''' ) AS kur_cd1,
  COALESCE ( mkr.kur_name, '''' ) AS kur_name,
  COALESCE ( mbd.bed_cd, 0 ) AS bed_cd,
  COALESCE ( mbd.in_hospital_cd_1, '''' ) AS bed_cd1,
  COALESCE ( mbd.bed_name, '''' ) AS bed_name,
  COALESCE ( mtt.treatment_name, '''' ) AS treatment_name,
  COALESCE ( mtt.in_hospital_cd_a1, '''' ) AS treatment_cd,
  COALESCE ( ord.ind_dw, 0 ) AS dw,
  TO_NUMBER( ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'' ) AS dialysis_time_m,
  COALESCE (
    RIGHT ( ''00'' || TRUNC( TO_NUMBER( ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'' ) / 60, 0 ), 2 ) || '':'' || RIGHT ( ''00'' || MOD ( TO_NUMBER( ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'' ), 60 ), 2 ),
    '''' 
  ) AS treatment_time,
  COALESCE (
    RIGHT ( ''00'' || TRUNC( TO_NUMBER( ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'' ) / 60, 0 ), 2 ) || RIGHT ( ''00'' || MOD ( TO_NUMBER( ord.ind_cond_info -> ''1'' ->> ''value'', ''999999'' ), 60 ), 2 ),
    '''' 
  ) AS treatment_time4,
  COALESCE ( ord.rst_cond_info -> ''1'' ->> ''value'', '''' ) AS treatment_time_m,--追加
  COALESCE ( ord.ind_cond_info -> ''2'' ->> ''value_name_1'', '''' ) AS va,
  COALESCE ( SUBSTRING ( ord.ind_cond_info -> ''2'' ->> ''value_name_1'', 1, 3 ), '''' ) AS va3,
  COALESCE ( mva.in_hospital_cd_1, '''' ) AS va_cd1,
  COALESCE (
    ( CASE mva.va_direct WHEN ''0'' THEN ''右'' WHEN ''1'' THEN ''左'' WHEN ''2'' THEN ''両方'' WHEN ''3'' THEN ''無'' ELSE''不明'' END ),
    '''' 
  ) AS va_direct,
  COALESCE ( ord.ind_cond_info -> ''3'' ->> ''value'', '''' ) AS target_weight,
  COALESCE ( ord.ind_cond_info -> ''4'' ->> ''value'', '''' ) AS water_removal_amount_limit,
--ord.ind_cond_info->''5''->>''value_name_1'' as dialyzer,
  COALESCE ( mdr.model_number, '''' ) AS dialyzer,
--ord.ind_cond_info->''5''->>''value'' as dialyzer_cd,
  COALESCE ( mdr.in_hospital_cd_1, '''' ) AS dialyzer_cd1,
  COALESCE ( ord.ind_cond_info -> ''6'' ->> ''value_name_1'', '''' ) AS adsorption_column,
  COALESCE ( meqad.in_hospital_cd_1, '''' ) AS ad_cd1,
  COALESCE ( ord.ind_cond_info -> ''7'' ->> ''value_name_1'', '''' ) AS primary_film,
  COALESCE ( meqpr.in_hospital_cd_1, '''' ) AS pr_cd1,
  COALESCE ( ord.ind_cond_info -> ''8'' ->> ''value_name_1'', '''' ) AS secondary_film,
  COALESCE ( meqse.in_hospital_cd_1, '''' ) AS se_cd1,
--ord.ind_cond_info->''9''->>''value_name_1'' as puncture_needle_a,
  COALESCE ( meqa.equipment_name, '''' ) AS puncture_needle_a,
  COALESCE ( meqa.in_hospital_cd_1, '''' ) AS a_cd1,
--ord.ind_cond_info->''10''->>''value_name_1'' as puncture_needle_v,
  COALESCE ( meqv.equipment_name, '''' ) AS puncture_needle_v,
  COALESCE ( meqv.in_hospital_cd_1, '''' ) AS v_cd1,
--ord.ind_cond_info->''11''->>''value_name_1'' as puncture_needle_sn,
  COALESCE ( meqsn.equipment_name, '''' ) AS puncture_needle_sn,
  COALESCE ( meqsn.in_hospital_cd_1, '''' ) AS sn_cd1,
  COALESCE ( ( CASE ord.ind_cond_info -> ''12'' ->> ''value'' WHEN ''1'' THEN ''有り'' WHEN ''0'' THEN ''無し'' ELSE NULL END ), '''' ) AS single_needle,
  COALESCE ( ord.ind_cond_info -> ''13'' ->> ''value'', '''' ) AS blood_circuit,
  COALESCE ( meqbc.in_hospital_cd_1, '''' ) AS bc_cd1,
  COALESCE ( ord.ind_cond_info -> ''14'' ->> ''value'', '''' ) AS blood_flow,
--ord.ind_cond_info->''15''->>''value_name_1'' as dialysate,
  COALESCE ( med15.medicine_name, '''' ) AS dialysate,
  COALESCE ( med15.in_hospital_cd_1, '''' ) AS dialysate_cd1,
  COALESCE ( ord.ind_cond_info -> ''16'' ->> ''value'', '''' ) AS dialysate_flow_rate,
  COALESCE ( ord.ind_cond_info -> ''17'' ->> ''value'', '''' ) AS dialysate_amount,
--ord.ind_cond_info->''17''->>''unit'' as dialysate_amount_unit,
  COALESCE ( med15.unit, '''' ) AS dialysate_amount_unit,
  COALESCE ( ord.ind_cond_info -> ''18'' ->> ''value'', '''' ) AS dialysate_temperature,
--ord.ind_cond_info->''19''->>''value_name_1'' as fluid_replacement,
  COALESCE ( med19.medicine_name, '''' ) AS fluid_replacement,
  COALESCE ( med19.in_hospital_cd_1, '''' ) AS ds_cd1,
  COALESCE ( ord.ind_cond_info -> ''20'' ->> ''value'', '''' ) AS fluid_replacement_amount,
  COALESCE ( ( CASE ord.ind_cond_info -> ''21'' ->> ''value'' WHEN ''1'' THEN ''前補液'' WHEN ''0'' THEN ''後補液'' ELSE NULL END ), '''' ) AS fluid_replacement_timing,
  COALESCE ( ord.ind_cond_info -> ''22'' ->> ''value'', '''' ) AS fluid_replacement_use_count,
  COALESCE ( ord.ind_cond_info -> ''22'' ->> ''unit'', '''' ) AS fluid_replacement_use_count_unit,
  COALESCE ( ord.ind_cond_info -> ''23'' ->> ''value'', '''' ) AS fluid_replacement_temperature,
  COALESCE ( ord.ind_cond_info -> ''24'' ->> ''value'', '''' ) AS fluid_replacement_speed,
--ord.ind_cond_info->''25''->>''value_name_1'' as anti_coagulant,
  COALESCE ( med25.medicine_name, '''' ) AS anti_coagulant,
  COALESCE ( med25.in_hospital_cd_1, '''' ) AS anti_coagulant_cd1,
  COALESCE ( ord.ind_cond_info -> ''26'' ->> ''value'', '''' ) AS anti_coagulant_one_shot_amount,
--ord.ind_cond_info->''26''->>''unit'' as anti_coagulant_one_shot_amount_unit,
  COALESCE ( med25.unit, '''' ) AS anti_coagulant_one_shot_amount_unit,
  COALESCE ( ord.ind_cond_info -> ''27'' ->> ''value'', '''' ) AS anti_coagulant_sustained_speed,
  COALESCE ( ord.ind_cond_info -> ''27'' ->> ''unit'', '''' ) AS anti_coagulant_sustained_speed_unit,
  COALESCE ( ord.ind_cond_info -> ''28'' ->> ''value'', '''' ) AS anti_coagulant_sustained_amount,
  COALESCE ( ord.ind_cond_info -> ''28'' ->> ''unit'', '''' ) AS anti_coagulant_sustained_amount_unit,
  COALESCE (
    TO_NUMBER( ord.ind_cond_info -> ''26'' ->> ''value'', ''999999999999'' ) + TO_NUMBER( ord.ind_cond_info -> ''28'' ->> ''value'', ''999999999999'' ),
    0 
  ) AS anti_coagulant_total_amount,--抗凝固剤総量
  COALESCE ( ( CASE ord.ind_cond_info -> ''29'' ->> ''value'' WHEN ''1'' THEN ''使用する'' WHEN ''0'' THEN ''使用しない'' ELSE NULL END ), '''' ) AS ip,
  COALESCE ( ( CASE ord.ind_cond_info -> ''30'' ->> ''value'' WHEN ''0'' THEN ''手動'' WHEN ''1'' THEN ''自動'' ELSE NULL END ), '''' ) AS ip_start,
  COALESCE ( ord.ind_cond_info -> ''31'' ->> ''value'', '''' ) AS ip_one_short_amount,
  COALESCE ( ord.ind_cond_info -> ''32'' ->> ''value'', '''' ) AS ip_speed,
  COALESCE ( ord.ind_cond_info -> ''33'' ->> ''value'', '''' ) AS ip_speed_max,
  COALESCE ( ( CASE ord.ind_cond_info -> ''34'' ->> ''value'' WHEN ''1'' THEN ''使用する'' WHEN ''0'' THEN ''使用しない'' ELSE NULL END ), '''' ) AS auto_one_shot,
  COALESCE ( ( CASE ord.ind_cond_info -> ''35'' ->> ''value'' WHEN ''1'' THEN ''入'' WHEN ''0'' THEN ''切'' ELSE NULL END ), '''' ) AS ip_auto_off,
  COALESCE ( ord.ind_cond_info -> ''36'' ->> ''value'', '''' ) AS ip_auto_off_time,
  COALESCE ( ( CASE ord.ind_cond_info -> ''37'' ->> ''value'' WHEN ''1'' THEN ''入'' WHEN ''0'' THEN ''切'' ELSE NULL END ), '''' ) AS ip_monitor_auto_off,
  COALESCE ( ord.ind_cond_info -> ''38'' ->> ''value'', '''' ) AS ip_monitor_auto_off_time,
  COALESCE ( pm.medical_care_info ->> ''dialysis_start_date'', '''' ) AS dialysis_start_date,
  COALESCE ( to_char( ord.up_date, ''YYYYMMDD'' ), '''' ) AS update_ymd,
  COALESCE ( to_char( ord.up_date, ''HH24MISS'' ), '''' ) AS update_hms 
FROM
  pat_main AS pm,
  ord_main AS ord
  LEFT OUTER JOIN mst_equipment AS meqa ON meqa.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''9'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_equipment AS meqv ON meqv.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''10'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_equipment AS meqsn ON meqsn.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''11'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_equipment AS meqad ON meqad.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''6'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_equipment AS meqpr ON meqpr.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''7'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_equipment AS meqbc ON meqbc.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''13'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_equipment AS meqse ON meqse.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''8'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_medicine AS med15 ON med15.medicine_cd = TO_NUMBER( ord.ind_cond_info -> ''15'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_medicine AS med19 ON med19.medicine_cd = TO_NUMBER( ord.ind_cond_info -> ''19'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_medicine AS med25 ON med25.medicine_cd = TO_NUMBER( ord.ind_cond_info -> ''25'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_treatment AS mtt ON mtt.treatment_cd = ord.ind_treatment_cd
  LEFT OUTER JOIN mst_dialyzer AS mdr ON mdr.dialyzer_cd = TO_NUMBER( ord.ind_cond_info -> ''5'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_va AS mva ON mva.va_cd = TO_NUMBER( ord.ind_cond_info -> ''2'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_bed AS mbd ON mbd.bed_cd = ord.ind_bed_cd
  LEFT OUTER JOIN mst_kur AS mkr ON mkr.kur_cd = ord.ind_kur_cd 
WHERE
  ord.ord_no = @ordNo and
  pm.pat_id = ord.pat_id', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）指示）透析条件', '2020-03-18 19:07:17.001', '2020-03-18 19:07:21', NULL);
