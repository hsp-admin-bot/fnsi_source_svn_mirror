DELETE FROM ntss.sys_data_set
WHERE sql_cd=-501105;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501105, 'WITH coop_ini as (
    SELECT COALESCE
        ( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
    WHERE
            facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info->>''key0'','''') = @key0
        AND info ->> ''key1'' = ''SSI_DIALYSIS_SEND''
        AND info ->> ''key2'' = ''MEDICINE_RESOLVE_MODE''
  ),
  ord_main_max AS (
    (
      SELECT
        ord.ord_no,
        ord.del_date as up_date,
        ord.ind_medi_info
      FROM
        ord_main_restore AS ord,
        sys_coop_journal as journal
      WHERE
        ord.ord_no = @ordNo
        AND journal.ctl_no = @ctlNo
        AND ord.ord_no = journal.ord_no
        AND journal.reg_date >= ord.del_date
      ORDER BY
        del_date DESC
      LIMIT
        1
    )
    UNION
    (
      SELECT
        ord.ord_no,
        ord.rst_edition_date as up_date,
        ord.ind_medi_info
      FROM
        ord_main AS ord
      WHERE
        ord.ord_no = @ordNo
    )
    ORDER BY
      up_date DESC NULLS LAST
    LIMIT
      1
  )
SELECT
  ord_cost.*
  , TO_CHAR(ROW_NUMBER() OVER (), ''FM9999'') AS cost_no 
FROM
  (
    WITH medi_order_data AS (
      SELECT
        ROW_NUMBER () OVER () AS no2
        , TO_NUMBER(datt.a1  :: text, ''999999999999'') AS ora
      FROM (
        SELECT TO_NUMBER((unnest(string_to_array((
          SELECT mst_f.value AS rtt
          FROM mst_facility_setting AS mst_f
          WHERE mst_f.facility_setting_no = ''3007'' AND mst_f.facility_cd = @facilityCd
        ),'',''))), ''999999999999'') AS a1) AS datt
    )
    SELECT
      cost_fin.*
    FROM
      ( 
        SELECT
          all_cost.detail_id
          , all_cost.e01
          , all_cost.e02
          , all_cost.e03
          , CASE WHEN RIGHT(all_cost.e04,1)=''.'' THEN TO_CHAR( TO_NUMBER(all_cost.e04, ''FM99999''), ''FM99990'')
            ELSE all_cost.e04 END
          , all_cost.e05
          , all_cost.e06
          , all_cost.e07 
          , all_cost.medi_reg_order
          , all_cost.medi_code_order
          , all_cost.medi_class_code_order
          , all_cost.medicine_type
          , all_cost.timing_code_order
          , all_cost.procedure_code_order
          , all_cost.interval_no
        FROM
          ( 
            WITH medi_order AS (
              SELECT
                index_no AS medi_code_order
                , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_code
              FROM mst_selector
              CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
              WHERE facility_cd = @facilityCd
                AND master_physical_name = ''mst_medicine''
            )
            , medi_class_order AS (
              SELECT
                index_no AS medi_class_code_order
                , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_class_code
              FROM mst_selector
              CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
              WHERE facility_cd = @facilityCd
                AND master_physical_name = ''mst_medicine_class''
            )
            , timing_order AS (
              SELECT
                index_no AS timing_code_order
                , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS timing_code
              FROM mst_selector
              CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
              WHERE facility_cd = @facilityCd
                AND master_physical_name = ''mst_medicate_timing''
            )
            , procedure_order AS (
              SELECT
                index_no AS procedure_code_order
                , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS procedure_code
              FROM mst_selector
              CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
              WHERE facility_cd = @facilityCd
                AND master_physical_name = ''mst_procedure''
            )
            , mst_medi AS (
              SELECT
                medicine_cd
                , medicine_name
                , class_cd
                , unit
                , in_hospital_cd_1
                , in_hospital_cd_2
                , medi_order.medi_code_order
                , medi_class_order.medi_class_code_order
              FROM mst_medicine mmd
              LEFT JOIN medi_order ON mmd.medicine_cd = medi_order.medi_code
              LEFT JOIN medi_class_order ON mmd.class_cd = medi_class_order.medi_class_code
              WHERE facility_cd = @facilityCd
            )
            SELECT
              --投与薬剤情報(通常)
              ''投与薬剤'' AS detail_id
              , mmd.in_hospital_cd_1 AS e01
              , mmd.medicine_name AS e02
              , mclass.class_name AS e03
              , TO_CHAR( TO_NUMBER(t.medi ->> ''amount'', ''FM99999.99''), ''FM99990.99'') AS e04
              , mmd.unit AS e05
              , mp.in_hospital_cd_a1 AS e06
              , CASE WHEN COALESCE(mp.in_hospital_cd_a1,'''') <>'''' THEN mp.pricedure_name ELSE NULL END AS e07 
              , t.idx AS medi_reg_order
              , mmd.medi_code_order AS medi_code_order
              , mmd.medi_class_code_order AS medi_class_code_order
              , 1 AS medicine_type
              , tio.timing_code_order AS timing_code_order
              , pro.procedure_code_order AS procedure_code_order
              , (t.medi ->> ''date_interval'') ::int AS interval_no
            FROM
              ord_main_max AS ord 
              CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info ::json) WITH ORDINALITY AS t(medi, idx)
              LEFT OUTER JOIN mst_medi AS mmd 
                ON mmd.medicine_cd = TO_NUMBER(t.medi ->> ''cd'', ''FM999999999999'') 
              LEFT OUTER JOIN mst_procedure AS mp 
                ON mp.procedure_cd = TO_NUMBER(t.medi ->> ''procedure_cd'', ''FM999999999999'') 
              LEFT OUTER JOIN mst_medicine_class AS mclass 
                ON mclass.class_cd = mmd.class_cd
              LEFT OUTER JOIN timing_order AS tio
                ON tio.timing_code = TO_NUMBER(t.medi ->> ''timing_cd'', ''FM999999999999'') 
              LEFT OUTER JOIN procedure_order AS pro 
                ON pro.procedure_code = TO_NUMBER(t.medi ->> ''procedure_cd'', ''FM999999999999'') 
            WHERE
              medi ->> ''medicine_type'' = ''1'' 
              AND COALESCE(mmd.in_hospital_cd_1, ''ZERO'') <> ''ZERO'' 
              AND COALESCE(mmd.in_hospital_cd_2, ''ZERO'') = ''ZERO''
              AND ord.ord_no = @ordNo 
            UNION 
            SELECT
              --投与薬剤情報(調製)分解
              ''投与薬剤'' AS detail_id
              , mmd.in_hospital_cd_1 AS e1
              , mmd.medicine_name AS e2
              , mmdc.class_name AS e03
              , COALESCE( 
                ( 
                  CASE mmxd ->> ''solvent'' 
                    WHEN ''1'' THEN TO_CHAR( TO_NUMBER(mmxd ->> ''amount'', ''FM99999.99''), ''FM99990.99'') 
                    ELSE TO_CHAR(TRUNC(TO_NUMBER(t.medi ->> ''amount'', ''FM99999.99'') * TO_NUMBER(mmxd ->> ''amount'', ''FM99999.99''),2), ''FM99990.99'')
                    END
                ) 
                , ''0.00''
              ) AS e04
              , mmd.unit AS e05
              , mp.in_hospital_cd_a1 AS e06
              , mp.pricedure_name AS e07 
              , t.idx AS medi_reg_order
              , mmd.medi_code_order AS medi_code_order
              , mmd.medi_class_code_order AS medi_class_code_order
              , 2 AS medicine_type
              , tio.timing_code_order AS timing_code_order
              , pro.procedure_code_order AS procedure_code_order
              , (t.medi ->> ''date_interval'') ::int AS interval_no
            FROM
              ord_main_max AS ord 
              CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info ::json) WITH ORDINALITY AS t(medi, idx)
              LEFT OUTER JOIN mst_procedure AS mp 
                ON mp.procedure_cd = TO_NUMBER(t.medi ->> ''procedure_cd'', ''FM999999999999'') 
              LEFT OUTER JOIN mst_medicine_mix AS mmx 
                ON mmx.medicine_mix_cd = TO_NUMBER(t.medi ->> ''cd'', ''FM999999999999'')
              CROSS JOIN LATERAL json_array_elements(mmx.mix_info ::json) mmxd 
              LEFT OUTER JOIN timing_order AS tio
                ON tio.timing_code = TO_NUMBER(t.medi ->> ''timing_cd'', ''FM999999999999'') 
              LEFT OUTER JOIN procedure_order AS pro 
                ON pro.procedure_code = TO_NUMBER(t.medi ->> ''procedure_cd'', ''FM999999999999'') 
              LEFT OUTER JOIN mst_medi AS mmd 
                ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''FM999999999999'') 
              LEFT OUTER JOIN mst_medicine_class AS mmdc 
                ON mmdc.class_cd = mmd.class_cd 
            WHERE
              t.medi ->> ''medicine_type'' = ''2'' 
              AND ord.ord_no = @ordNo
              AND (select value from coop_ini) = ''1''
            UNION 
            SELECT
              --投与薬剤情報(調製)セット
              ''投与薬剤'' AS detail_id
              , mmx.in_hospital_cd_1 AS e1
              , mmx.medicine_mix_name AS e2
              , mmdc.class_name AS e03
              , COALESCE( TO_CHAR( TO_NUMBER(t.medi ->> ''amount'', ''FM99999.99''), ''FM99990.99'') , ''0.00'') AS e04
              , mmx.unit AS e05
              , mp.in_hospital_cd_a1 AS e06
              , mp.pricedure_name AS e07 
              , t.idx AS medi_reg_order
              , medi_order.medi_code_order AS medi_code_order
              , medi_class_order.medi_class_code_order AS medi_class_code_order
              , 2 AS medicine_type
              , tio.timing_code_order AS timing_code_order
              , pro.procedure_code_order AS procedure_code_order
              , (t.medi ->> ''date_interval'') ::int AS interval_no
            FROM
              ord_main_max AS ord 
              CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info ::json) WITH ORDINALITY AS t(medi, idx)
              LEFT OUTER JOIN mst_procedure AS mp 
                ON mp.procedure_cd = TO_NUMBER(t.medi ->> ''procedure_cd'', ''FM999999999999'') 
              LEFT OUTER JOIN mst_medicine_mix AS mmx 
                ON mmx.medicine_mix_cd = TO_NUMBER(t.medi ->> ''cd'', ''FM999999999999'')
              LEFT OUTER JOIN timing_order AS tio
                ON tio.timing_code = TO_NUMBER(t.medi ->> ''timing_cd'', ''FM999999999999'') 
              LEFT OUTER JOIN procedure_order AS pro 
                ON pro.procedure_code = TO_NUMBER(t.medi ->> ''procedure_cd'', ''FM999999999999'') 
              LEFT OUTER JOIN mst_medicine_class AS mmdc 
                ON mmdc.class_cd = mmx.class_cd 
              LEFT JOIN medi_order 
                ON mmx.medicine_mix_cd = medi_order.medi_code
              LEFT JOIN medi_class_order 
                ON mmx.class_cd = medi_class_order.medi_class_code
            WHERE
              t.medi ->> ''medicine_type'' = ''2'' 
              AND ord.ord_no = @ordNo
              AND (select value from coop_ini) = ''0''
          ) all_cost 
        WHERE
          all_cost.e01 IS NOT NULL
      ) cost_fin 
    ORDER BY
    CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 0 THEN cost_fin.medi_reg_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 1 THEN cost_fin.medi_class_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 2 THEN cost_fin.medicine_type
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 3 THEN cost_fin.medi_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 4 THEN cost_fin.timing_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 5 THEN cost_fin.procedure_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 6 THEN cost_fin.interval_no END,
    CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 0 THEN cost_fin.medi_reg_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 1 THEN cost_fin.medi_class_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 2 THEN cost_fin.medicine_type
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 3 THEN cost_fin.medi_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 4 THEN cost_fin.timing_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 5 THEN cost_fin.procedure_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 6 THEN cost_fin.interval_no END,
    CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 0 THEN cost_fin.medi_reg_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 1 THEN cost_fin.medi_class_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 2 THEN cost_fin.medicine_type
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 3 THEN cost_fin.medi_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 4 THEN cost_fin.timing_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 5 THEN cost_fin.procedure_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 6 THEN cost_fin.interval_no END,
    CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 0 THEN cost_fin.medi_reg_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 1 THEN cost_fin.medi_class_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 2 THEN cost_fin.medicine_type
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 3 THEN cost_fin.medi_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 4 THEN cost_fin.timing_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 5 THEN cost_fin.procedure_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 6 THEN cost_fin.interval_no END,
    CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 0 THEN cost_fin.medi_reg_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 1 THEN cost_fin.medi_class_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 2 THEN cost_fin.medicine_type
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 3 THEN cost_fin.medi_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 4 THEN cost_fin.timing_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 5 THEN cost_fin.procedure_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 6 THEN cost_fin.interval_no END,
    CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 0 THEN cost_fin.medi_reg_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 1 THEN cost_fin.medi_class_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 2 THEN cost_fin.medicine_type
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 3 THEN cost_fin.medi_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 4 THEN cost_fin.timing_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 5 THEN cost_fin.procedure_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 6 THEN cost_fin.interval_no END,
    CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 0 THEN cost_fin.medi_reg_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 1 THEN cost_fin.medi_class_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 2 THEN cost_fin.medicine_type
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 3 THEN cost_fin.medi_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 4 THEN cost_fin.timing_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 5 THEN cost_fin.procedure_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 6 THEN cost_fin.interval_no END, cost_fin.medi_code_order
  ) ord_cost', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SSI予約）薬剤繰り返し部', '2025-03-17 09:41:58.788', CURRENT_TIMESTAMP, NULL);
