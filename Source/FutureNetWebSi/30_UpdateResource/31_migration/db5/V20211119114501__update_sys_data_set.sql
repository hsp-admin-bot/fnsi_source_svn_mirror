delete from "sys_data_set" where "sql_cd" in (-206,-203,-202);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-206, 'SELECT
  ARRAY_TO_STRING( 
    ARRAY ( 
      ( 
        SELECT
          CAST(diff ->> ''dial_diff_cd'' AS TEXT) AS cd 
        FROM
          pat_personal_main AS ppm 
          CROSS JOIN LATERAL json_array_elements(ppm.dial_diff_com_info ::json) diff 
        WHERE
          diff ->> ''is_dial_diff'' = ''1'' 
          AND ppm.pat_id = @patId 
        ORDER BY
          (diff ->> ''is_main'') ::INT DESC
      ) 
      UNION 
      SELECT
        ''-1'' AS cd
    ) 
    , '',''
  ) AS pat_dial_diff_cd', 3, '[{}]', '0', '{"applications": [4]}', NULL, 'NEC標準(MegaOakHR) 透析困難コメントコード(無し場合、-1です)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-203, 'SELECT
  ''コメント'' AS detail_id
  , to_char(ROW_NUMBER() OVER (), ''000'') AS com_no
  , com_fin.* 
FROM
  ( 
    SELECT
      com_all.* 
    FROM
      ( 
        (SELECT -- 原疾患
          ''01'' AS fin_cd
          , SUBSTRING(md.disease_name, 1, 30) AS com_text 
        FROM
          pat_unique AS medical 
          CROSS JOIN LATERAL json_array_elements(medical.medical_hst_info ::json) info 
          LEFT JOIN mst_disease AS md ON (info ->> ''disease_cd'') ::INT = md.disease_cd 
        WHERE
          medical.pat_id = @patId
          AND medical.is_del = ''0''
          AND info ->> ''disease_cd'' IS NOT NULL
        ORDER BY (info ->> ''is_main_disease'') ::INT DESC, info ->> ''ctl_no'' )

        UNION 
        SELECT -- 透析困難コメント
          ''40'' AS fin_cd
          , SUBSTRING(mdd.dialysis_difficulty_name, 1, 30) AS com_text 
        FROM
          mst_dialysis_difficulty mdd 
        WHERE
          mdd.dialysis_difficulty_cd IN (SELECT regexp_split_to_table(@mstCddd, '','')::INT)
          AND mdd.is_del = ''0'' 

        UNION 
        SELECT
          -- 会計コメン
          ''60'' AS fin_cd
          , TRANSLATE( 
            CONCAT( 
              ''開始　'', TO_CHAR(ord.rst_start_date, ''HH24:MI'')
              , ''　終了　'', TO_CHAR(ord.rst_end_date, ''HH24:MI'')
              , ''　時間　'', TO_CHAR( ord.rst_end_date - ord.rst_start_date, ''HH24:MI'')
            ) 
            , ''0123456789:'', ''０１２３４５６７８９：''
          ) AS com_text 
        FROM
          ord_main ord 
        WHERE
          ord.ord_no = @ordNo
      ) com_all 
    WHERE
      COALESCE(com_all.com_text, ''空白'') <> ''空白''
    ORDER BY fin_cd ASC
  ) com_fin
', 2, '[{}]', '1', '{"applications": [4]}', NULL, 'NEC)コメント繰り返し部(要ordno、patid）', '2020-05-19 16:46:18.001', CURRENT_TIMESTAMP, '[{"sql_cd": -206, "field_name": "pat_dial_diff_cd", "replace_var": "@mstCddd"}]');
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-202, 'SELECT
  LPAD(TO_CHAR(ROW_NUMBER() OVER (), ''FM000''), 3, '' '') AS cost_no
  , cost_fin.* 
FROM
  ( 
    SELECT
      all_cost.* 
    FROM
      ( 
        SELECT
          --加算情報
          ''実績詳細'' AS detail_id
          , ''加算'' AS sbt_key
          , mad.in_hospital_cd_1 AS e01 --コード
          , ''1'' AS e02
          , COALESCE(mad.in_hospital_cd_2, ''20'') AS e03
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''01'' AS e07 
        FROM
          ord_main ord 
          CROSS JOIN LATERAL json_array_elements(ord.addition_info ::json) addi 
          LEFT OUTER JOIN mst_addition AS mad 
            ON mad.addition_cd = TO_NUMBER(addi ->> ''cd'', ''FM9999999999'') 
        WHERE
          mad.addition_class <> ''2'' 
          AND ord.ord_no = @ordNo 
        UNION 
        SELECT
          --VA情報
          ''実績詳細'' AS detail_id
          , ''VA'' AS sbt_key
          , mva.in_hospital_cd_1 AS e1
          , ''1'' AS e2
          , COALESCE(mva.in_hospital_cd_2, ''21'') AS e03
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''02'' AS e07 
        FROM
          ord_main ord 
          LEFT OUTER JOIN mst_va AS mva 
            ON mva.va_cd = TO_NUMBER( ord.rst_cond_info -> ''2'' ->> ''value'', ''FM999999999999'') 
        WHERE
          ord.ord_no = @ordNo 
        UNION 
        SELECT
          --治療項目情報
          ''実績詳細'' AS detail_id
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
            ON mtt.treatment_cd = ord.rst_treatment_cd 
        WHERE
          ord.ord_no = @ordNo 
        UNION 
        SELECT
          --ダイアライザ情報
          ''実績詳細'' AS detail_id
          , ''ダイアライザ'' AS sbt_key
          , mdz.in_hospital_cd_1 AS e1
          , ''1'' AS e2
          , COALESCE(mdz.in_hospital_cd_2, ''25'') AS e3
          , ''000010000'' AS e04
          , ''HON'' AS e5
          , ''000000000'' AS e06
          , ''04'' AS e07 
        FROM
          ord_main ord 
          LEFT OUTER JOIN mst_dialyzer AS mdz 
            ON mdz.dialyzer_cd = TO_NUMBER( ord.rst_cond_info -> ''5'' ->> ''value'', ''FM999999999999'') 
        WHERE
          ord.ord_no = @ordNo 
        UNION 
        SELECT
          --医材内ダイアライザ情報
          ''実績詳細'' AS detail_id
          , ''ダイアライザ'' AS sbt_key
          , mdz.in_hospital_cd_1 AS e1
          , ''1'' AS e2
          , COALESCE(mdz.in_hospital_cd_2, ''25'') AS e3
          , ''000010000'' AS e04
          , ''HON'' AS e5
          , ''000000000'' AS e06
          , ''05'' AS e07 
        FROM
          ord_main ord 
          CROSS JOIN LATERAL json_array_elements(ord.rst_equip_info ::json) equip 
          LEFT OUTER JOIN mst_dialyzer AS mdz 
            ON mdz.dialyzer_cd = TO_NUMBER(equip ->> ''cd'', ''FM999999999999'') 
        WHERE
          equip ->> ''equip_type'' = ''1'' 
          AND ord.ord_no = @ordNo 
        UNION 
        SELECT
          --抗凝固剤(単独分）
          ''実績詳細'' AS detail_id
          , ''抗凝固剤'' AS sbt_cd
          , mmd.in_hospital_cd_1 AS e1
          , ''1'' AS e2
          , COALESCE(mmd.in_hospital_cd_2, ''25'') AS e3
          , TO_CHAR( 
            ( 
              TO_NUMBER( 
                COALESCE(ord.rst_cond_info -> ''26'' ->> ''value'', ''0'')
                , ''FM999999999.999''
              ) + TO_NUMBER( 
                COALESCE(ord.rst_cond_info -> ''28'' ->> ''value'', ''0'')
                , ''FM999999999.999''
              )
            ) / mmd.unit_converted_amount * mmd.unit_converted_amount_second * 1000
            , ''FM999999999''
          ) AS e4
          , mmd.unit_second AS e5
          , ''000000000'' AS e06
          , ''06'' AS e07 
        FROM
          ord_main ord 
          LEFT OUTER JOIN mst_medicine AS mmd 
            ON mmd.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''FM999999999999'') 
        WHERE
          ord.rst_cond_info -> ''25'' ->> ''medicine_type'' = ''1'' 
          AND ord.ord_no = @ordNo 
        UNION 
        SELECT
          --抗凝固剤(調製分）
          ''実績詳細'' AS detail_id
          , ''抗凝固剤''
          , mmd.in_hospital_cd_1 AS e1 
          --e1
          , ''1'' AS e2
          , COALESCE(mmd.in_hospital_cd_2, ''25'') AS e3
          , ( 
            CASE mmxd ->> ''solvent'' 
              WHEN ''1'' THEN TO_CHAR( 
                TO_NUMBER(mmxd ->> ''amount'', ''FM99999.9999'') * 1000
                , ''FM999999999''
              ) 
              ELSE TO_CHAR( 
                ( 
                  TO_NUMBER( 
                    COALESCE(ord.rst_cond_info -> ''26'' ->> ''value'', ''0'')
                    , ''FM99999.9999''
                  ) + TO_NUMBER( 
                    COALESCE(ord.rst_cond_info -> ''28'' ->> ''value'', ''0'')
                    , ''FM99999.9999''
                  )
                ) / mmx2.amount_unit * TO_NUMBER(mmxd ->> ''amount'', ''FM99999.9999'') * 1000
                , ''FM999999999''
              ) 
              END
          ) AS e4
          , mmd.unit AS e5
          , ''000000000'' AS e06
          , ''07'' AS e07 
        FROM
          ord_main AS ord 
          LEFT OUTER JOIN mst_medicine_mix AS mmx 
            ON mmx.medicine_mix_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''FM999999999999'') 
          , mst_medicine_mix AS mmx2 
          CROSS JOIN LATERAL json_array_elements(mmx2.mix_info ::json) mmxd 
          LEFT OUTER JOIN mst_medicine AS mmd 
            ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''FM999999999999'') 
        WHERE
          ord.rst_cond_info -> ''25'' ->> ''medicine_type'' = ''2'' 
          AND ord.ord_no = @ordNo 
        UNION 
        SELECT
          --透析液情報
          ''実績詳細'' AS detail_id
          , ''透析液''
          , mmd.in_hospital_cd_1 AS e1
          , ''1'' AS e2
          , COALESCE(mmd.in_hospital_cd_2, ''27'') AS e3
          , TO_CHAR( 
            TO_NUMBER( 
              COALESCE(ord.rst_cond_info -> ''17'' ->> ''value'', ''0'')
              , ''FM999999999.999''
            ) 
            , ''FM999990.999''
          ) AS e4
          , mmd.unit AS e5 
          , ''000000000'' AS e06
          , ''08'' AS e07 
        FROM
          ord_main ord 
          LEFT OUTER JOIN mst_medicine AS mmd 
            ON mmd.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''15'' ->> ''value'', ''FM999999999999'') 
        WHERE
          ord.ord_no = @ordNo 
        UNION 
        SELECT
          --補液情報
          ''実績詳細'' AS detail_id
          , ''補液''
          , mmd.in_hospital_cd_1 AS e1
          , ''1'' AS e2
          , COALESCE(mmd.in_hospital_cd_2, ''27'') AS e3
          , TO_CHAR( 
            TO_NUMBER( 
              COALESCE(ord.rst_cond_info -> ''22'' ->> ''value'', ''0'')
              , ''FM99999.9999''
            ) * 1000
            , ''FM999999999''
          ) AS e4
          , mmd.unit --e5
          , ''000000000'' AS e06
          , ''09'' AS e07 
        FROM
          ord_main ord 
          LEFT OUTER JOIN mst_medicine AS mmd 
            ON mmd.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''19'' ->> ''value'', ''FM999999999999'') 
        WHERE
          ord.ord_no = @ordNo 
        UNION 
        SELECT
          --投与薬剤情報(通常)
          ''実績詳細'' AS detail_id
          , ''投与薬剤''
          , mmd.in_hospital_cd_1 --e1
          , ''1'' AS e2
          , COALESCE(mmd.in_hospital_cd_2, ''27'') AS e3
          , ( 
            CASE mmd.in_hospital_cd_2 
              WHEN ''30'' THEN ''000000000'' 
              WHEN ''32'' THEN ''000000000'' 
              WHEN ''3A'' THEN ''000000000'' 
              WHEN ''3B'' THEN ''000000000'' 
              WHEN ''3C'' THEN ''000000000'' 
              ELSE TO_CHAR( 
                TO_NUMBER(medi ->> ''amount'', ''FM99999.9999'') * 1000
                , ''FM999999999''
              ) 
              END
          ) AS e04
          , medi ->> ''unit'' --e5
          , ''000000000'' AS e06
          , ''10'' AS e07 
        FROM
          ord_main AS ord 
          CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) medi 
          LEFT OUTER JOIN mst_medicine AS mmd 
            ON mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'', ''FM999999999999'') 
          LEFT OUTER JOIN mst_procedure AS mp 
            ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''FM999999999999'') 
        WHERE
          medi ->> ''effect_flg'' = ''1'' 
          AND medi ->> ''medicine_type'' = ''1'' 
          AND ord.ord_no = @ordNo 
          --order by medi ->> ''effect_date'',medi ->> ''cd''
        UNION 
        SELECT
          --投与薬剤情報(調製)
          ''実績詳細'' AS detail_id
          , ''調製''
          , mmd.in_hospital_cd_1 AS e1
          , ''1'' AS e2
          , COALESCE(mmd.in_hospital_cd_2, ''27'') --e3
          , ( 
            CASE mmxd ->> ''solvent'' 
              WHEN ''1'' THEN TO_CHAR( 
                TO_NUMBER(mmxd ->> ''amount'', ''FM99999.9999'') * 1000
                , ''FM999999999''
              ) 
              ELSE TO_CHAR( 
                TO_NUMBER(medi ->> ''amount'', ''FM99999.9999'') / mmx2.amount_unit * to_number(mmxd ->> ''amount'', ''FM99999.9999'')
                 * 1000
                , ''FM999999999''
              ) 
              END
          ) AS e04
          , COALESCE(mmd.unit_second, mmd.unit) AS e5 
          , ''000000000'' AS e06
          , ''11'' AS e07 
        FROM
          ord_main AS ord 
          CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) medi 
          LEFT OUTER JOIN mst_procedure AS mp 
            ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''FM999999999999'') 
          LEFT OUTER JOIN mst_medicine_mix AS mmx 
            ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''FM999999999999'')
          , mst_medicine_mix AS mmx2 
          CROSS JOIN LATERAL json_array_elements(mmx2.mix_info ::json) mmxd 
          LEFT OUTER JOIN mst_medicine AS mmd 
            ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''FM999999999999'') 
        WHERE
          medi ->> ''effect_flg'' = ''1'' 
          AND medi ->> ''medicine_type'' = ''2'' 
          AND ord.ord_no = @ordNo 
        UNION 
        SELECT
          --処置薬剤情報
          ''実績詳細'' AS detail_id
          , ''処置薬剤''
          , mmd.in_hospital_cd_1 --e1
          , ''1'' AS e2
          , COALESCE(mmd.in_hospital_cd_2, ''27'') --e3
          , TO_CHAR( 
            TO_NUMBER(tmedi ->> ''amount'', ''FM99999.9999'') * 1000
            , ''FM999999999''
          ) AS e04 
          , tmedi ->> ''unit'' AS e5
          , ''000000000'' AS e06
          , ''12'' AS e07 
        FROM
          ord_main AS ord 
          CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) tmedi 
          LEFT OUTER JOIN mst_medicine AS mmd 
            ON mmd.medicine_cd = TO_NUMBER(tmedi ->> ''treat_medicine_cd'', ''FM999999999999'') 
          LEFT OUTER JOIN mst_procedure AS mp 
            ON mp.procedure_cd = TO_NUMBER(tmedi ->> ''procedure_cd'', ''FM999999999999'') 
        WHERE
          ord.ord_no = @ordNo 
        UNION 
        SELECT
          --A針情報
          ''実績詳細'' AS detail_id
          , ''A針''
          , meq.in_hospital_cd_1 AS e1
          , ''1'' AS e2
          , COALESCE(meq.in_hospital_cd_2, ''28'') AS e3
          , ''000010000'' AS e04
          , meq.unit AS e5
          , ''000000000'' AS e06
          , ''13'' AS e07 
        FROM
          ord_main ord 
          LEFT OUTER JOIN mst_equipment AS meq 
            ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''9'' ->> ''value'', ''FM999999999999'') 
        WHERE
          ord.ord_no = @ordNo 
        UNION 
        SELECT
          --V針情報
          ''実績詳細'' AS detail_id
          , ''V針''
          , meq.in_hospital_cd_1 AS e1
          , ''1'' AS e2
          , COALESCE(meq.in_hospital_cd_2, ''28'') AS e3
          , ''000010000'' AS e04
          , meq.unit AS e5
          , ''000000000'' AS e06
          , ''14'' AS e07 
        FROM
          ord_main ord 
          LEFT OUTER JOIN mst_equipment AS meq 
            ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''10'' ->> ''value'', ''FM999999999999'') 
        WHERE
          ord.ord_no = @ordNo 
        UNION 
        SELECT
          --SN針情報
          ''実績詳細'' AS detail_id
          , ''SN針''
          , meq.in_hospital_cd_1 AS e1
          , ''1'' AS e2
          , COALESCE(meq.in_hospital_cd_2, ''28'') AS e3
          , ''000010000'' AS e04
          , meq.unit AS e5
          , ''000000000'' AS e06
          , ''15'' AS e07 
        FROM
          ord_main ord 
          LEFT OUTER JOIN mst_equipment AS meq 
            ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''11'' ->> ''value'', ''FM999999999999'') 
        WHERE
          ord.ord_no = @ordNo 
        UNION 
        SELECT
          --医材内穿刺針情報
          ''実績詳細'' AS detail_id
          , ''穿刺針''
          , meq.in_hospital_cd_1 AS e1
          , ''1'' AS e2
          , COALESCE(meq.in_hospital_cd_2, ''28'') AS e3
          , equip ->> ''amount'' AS e04
          , equip ->> ''unit'' AS e5
          , ''000000000'' AS e06
          , ''16'' AS e07 
        FROM
          ord_main ord 
          CROSS JOIN LATERAL json_array_elements(ord.rst_equip_info ::json) equip 
          LEFT OUTER JOIN mst_equipment AS meq 
            ON meq.equipment_cd = TO_NUMBER(equip ->> ''cd'', ''FM999999999999'') 
        WHERE
          equip ->> ''class_type'' IN (''2'', ''3'') 
          AND ord.ord_no = @ordNo 
        UNION 
        SELECT
          --医材情報
          ''実績詳細'' AS detail_id
          , ''医材''
          , meq.in_hospital_cd_1 AS e1
          , ''1'' AS e2
          , COALESCE(meq.in_hospital_cd_2, ''29'') AS e3
          , TO_CHAR( 
            TO_NUMBER(equip ->> ''amount'', ''FM99999.9999'') * 1000
            , ''FM999999999''
          ) AS e04
          , equip ->> ''unit'' AS e5
          , ''000000000'' AS e06
          , ''17'' AS e07 
        FROM
          ord_main ord 
          CROSS JOIN LATERAL json_array_elements(ord.rst_equip_info ::json) equip 
          LEFT OUTER JOIN mst_equipment AS meq 
            ON meq.equipment_cd = TO_NUMBER(equip ->> ''cd'', ''FM999999999999'') 
        WHERE
          equip ->> ''equip_type'' = ''0'' 
          AND equip ->> ''class_type'' NOT IN (''2'', ''3'') 
          AND ord.ord_no = @ordNo 
        UNION 
        SELECT
          --1次膜情報
          ''実績詳細'' AS detail_id
          , ''1次膜''
          , meq.in_hospital_cd_1 AS e1
          , ''1'' AS e2
          , COALESCE(meq.in_hospital_cd_2, ''29'') AS e3
          , ''000010000'' AS e05
          , meq.unit AS e6
          , ''000000000'' AS e06
          , ''18'' AS e07 
        FROM
          ord_main ord 
          LEFT OUTER JOIN mst_equipment AS meq 
            ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''7'' ->> ''value'', ''FM999999999999'') 
        WHERE
          ord.ord_no = @ordNo 
        UNION 
        SELECT
          --2次膜情報
          ''実績詳細'' AS detail_id
          , ''2次膜''
          , meq.in_hospital_cd_1 AS e1
          , ''1'' AS e2
          , COALESCE(meq.in_hospital_cd_2, ''29'') AS e3
          , ''000010000'' AS e05
          , meq.unit AS e6
          , ''000000000'' AS e06
          , ''19'' AS e07 
        FROM
          ord_main ord 
          LEFT OUTER JOIN mst_equipment AS meq 
            ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''8'' ->> ''value'', ''FM999999999999'') 
        WHERE
          ord.ord_no = @ordNo 
        UNION 
        SELECT
          --透析所要時間情報
          ''実績詳細'' AS detail_id
          , ''所要時間'' AS sbt_key
          , ''999999'' AS e01 
          --コード
          , ''1'' AS e02
          , ''31'' AS e03 
          --項目名
          , TO_CHAR( 
            ( 
              TO_NUMBER( 
                SUBSTRING( 
                  TO_CHAR(rst_end_date - rst_start_date, ''HH24MI'')
                  , 1
                  , 2
                ) 
                , ''FM99''
              ) * 60 + TO_NUMBER( 
                SUBSTRING( 
                  TO_CHAR(rst_end_date - rst_start_date, ''HH24MI'')
                  , 3
                  , 2
                ) 
                , ''FM99''
              )
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
      all_cost.e07
      , all_cost.e01
  ) cost_fin
', 2, '[{}]', '0', '{"applications": [4]}', NULL, 'NEC)実績繰り返し部１', '2020-05-18 18:12:46', CURRENT_TIMESTAMP, NULL);
