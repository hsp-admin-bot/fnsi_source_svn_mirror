DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-202,-204, -65, -501091, -501092, -501098, -501100);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-204, 'WITH coop_ini_info AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
        , info ->> ''key2'' AS key2
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''NEC''
)
, sendmsg_gen AS ( --項目世代番号
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''SENDMSG_GEN''
)
, func_addition AS ( --加算(患者)機能コード
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_ADDITION''
)
, va_coop_cd_no AS ( --VAの連携コード番号設定
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''VA_COOP_CD_NO''
)
, va_func_cd_no AS ( --VAの機能コード番号設定
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''VA_FUNC_CD_NO''
)
, func_bloodaccess AS ( --VAの機能コード
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_BLOODACCESS''
)
, treatment_coop_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''TREATMENT_COOP_CD_NO''
)
, treatment_func_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''TREATMENT_FUNC_CD_NO''
)
, func_treat AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_TREAT''
)
, dialyzer_coop_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''DIALYZER_COOP_CD_NO''
)
, dialyzer_func_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''DIALYZER_FUNC_CD_NO''
)
, func_dialyzer AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_DIALYZER''
)
, other_dialyzer_unit AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''OTHER_DIALYZER_UNIT''
)
, func_other_item AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_OTHER_ITEM''
)
, medicine_coop_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''MEDICINE_COOP_CD_NO''
)
, medicine_func_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''MEDICINE_FUNC_CD_NO''
)
, func_medicine AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_MEDICINE''
)
, func_koucoagulant AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_KOUCOAGULANT''
)
, equipment_coop_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''EQUIPMENT_COOP_CD_NO''
)
, equipment_func_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''EQUIPMENT_FUNC_CD_NO''
)
, func_aneedle AS ( --穿刺針
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_ANEEDLE''
)
, func_consumption AS ( --医療材料
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_CONSUMPTION''
)
, other_koucoagulant_speed_unit AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''OTHER_KOUCOAGULANT_SPEED_UNIT''
)
, func_another_add AS ( --時間外薬剤
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_ANOTHER_ADD''
)
, addmed_cd as ( --時間外薬剤コードリスト
	select *
	FROM coop_ini_info
	WHERE key2 like ''MEDICINE_ADDMED_CODE%''
)
, difficult_coop_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''DIFFICULT_COOP_CD_NO''
)
, difficult_func_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''DIFFICULT_FUNC_CD_NO''
)
, addition_coop_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''ADDITION_COOP_CD_NO''
)
, addition_func_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''ADDITION_FUNC_CD_NO''
)
, other_dialysis_time AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''OTHER_DIALYSIS_TIME''
)
, other_dialysis_unit AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''OTHER_DIALYSIS_UNIT''
)
, func_item_comment AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_ITEM_COMMENT''
)
, func_dialysis_comment AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_DIALYSIS_COMMENT''
)
, func_dialysis_comment2 AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_DIALYSIS_COMMENT2''
)
, func_dialysis_comment3 AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_DIALYSIS_COMMENT3''
)
, equip_order_data AS (
  SELECT
    ROW_NUMBER () OVER () AS no2
    , TO_NUMBER(datt.a1  :: text, ''999999999999'') AS ora
  FROM (
    SELECT TO_NUMBER((unnest(string_to_array((
      SELECT mst_f.value AS rtt
      FROM mst_facility_setting AS mst_f
      WHERE mst_f.facility_setting_no = ''3006'' AND mst_f.facility_cd = @facilityCd
    ),'',''))), ''999999999999'') AS a1) AS datt
)
, equip_order AS (
  SELECT
    index_no ::int AS meq_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_equipment''
)
, equip_class_order as (
  SELECT
    index_no ::int AS meq_class_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_class_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_equipment_class''
)
, mst_equip AS (
  SELECT
    equipment_cd
    , equipment_name
    , class_cd
    , unit
    , in_hospital_cd_1
    , in_hospital_cd_2
    , in_hospital_cd_3
    , in_hospital_cd_4
    , equip_order.meq_code_order
    , equip_class_order.meq_class_code_order
  FROM mst_equipment meq
  LEFT JOIN equip_order ON meq.equipment_cd = equip_order.meq_code
  LEFT JOIN equip_class_order ON meq.class_cd = equip_class_order.meq_class_code
  WHERE facility_cd = @facilityCd
)
, medi_order_data AS (
  SELECT
    ROW_NUMBER () OVER () AS no2
    , TO_NUMBER(datt.a1  :: text, ''999999999999'') AS a1
  FROM (
    SELECT TO_NUMBER((unnest(string_to_array((
      SELECT mst_f.value AS rtt
      FROM mst_facility_setting AS mst_f
      WHERE mst_f.facility_setting_no = ''3007'' AND mst_f.facility_cd = @facilityCd
    ),'',''))), ''999999999999'') AS a1) AS datt
)
, medi_order AS (
  SELECT
    index_no ::int AS medi_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_medicine''
)
, medi_class_order AS (
  SELECT
    index_no ::int AS medi_class_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_class_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_medicine_class''
)
, timing_order AS (
  SELECT
    index_no ::int AS timing_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS timing_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_medicate_timing''
)
, procedure_order AS (
  SELECT
    index_no ::int AS procedure_code_order
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
    , in_hospital_cd_3
    , in_hospital_cd_4
    , medi_order.medi_code_order
    , medi_class_order.medi_class_code_order
  FROM mst_medicine mmd
  LEFT JOIN medi_order ON mmd.medicine_cd = medi_order.medi_code
  LEFT JOIN medi_class_order ON mmd.class_cd = medi_class_order.medi_class_code
  WHERE facility_cd = @facilityCd
)
, pcd_save_3 AS (
  SELECT
    t.values ->> ''item_code'' AS item_code
    , t.values ->> ''function_code'' AS function_code
    , t.values ->> ''item_generation'' AS item_generation
    , t.idx AS idx
  FROM pat_coop_detail pcd
  CROSS JOIN jsonb_array_elements(pcd.save_3) WITH ORDINALITY AS t(values, idx)
  WHERE pat_id = @patId
)

SELECT
  LPAD(TO_CHAR(ROW_NUMBER() OVER (), ''FM000''), 3, '' '') AS cost_no
  , cost_fin.*
FROM
  (
    SELECT
      all_cost.*
    FROM
      (
        SELECT
          --加算(患者)Ver1
          ''指示詳細'' AS detail_id
          , ''加算(患者)'' AS sbt_key
          , pcd.item_code AS e01 --項目コード
          , pcd.item_generation AS e02 --項目世代番号
          , (SELECT value FROM func_addition) AS e03
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''01'' AS e08
          , pcd.idx ::int AS e09
        FROM
          pcd_save_3 pcd
        WHERE
          pcd.function_code = ''20''
          AND pcd.item_code IS NOT NULL
          AND ''1'' = @messageType
        UNION

        SELECT
          --VA情報
          ''指示詳細'' AS detail_id
          , ''VA'' AS sbt_key
          , CASE (SELECT value FROM va_coop_cd_no)
            WHEN ''1'' THEN mva.in_hospital_cd_1
            WHEN ''2'' THEN mva.in_hospital_cd_2
            END AS e01
          , (SELECT value FROM sendmsg_gen) AS e02
          , CASE (SELECT value FROM va_func_cd_no)
            WHEN ''1'' THEN COALESCE(mva.in_hospital_cd_1, (SELECT value FROM func_bloodaccess))
            WHEN ''2'' THEN COALESCE(mva.in_hospital_cd_2, (SELECT value FROM func_bloodaccess))
            END AS e03
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''02'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
          LEFT OUTER JOIN mst_va AS mva
            ON mva.va_cd = TO_NUMBER( ord.ind_cond_info -> ''2'' ->> ''value'', ''FM999999999999'')
        WHERE
          ord.ord_no = @ordNo
          AND ''2'' = @messageType
        UNION 

        SELECT --治療項目情報
          ''指示詳細'' AS detail_id
          , ''治療項目'' AS sbt_key
          , CASE (SELECT value FROM treatment_coop_cd_no)
            WHEN ''1''
                THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_a1
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_b1
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN mtt.in_hospital_cd_a1
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN mtt.in_hospital_cd_b1
                ELSE NULL
                END
            WHEN ''2'' 
                THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_a2
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_b2
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN mtt.in_hospital_cd_a2
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN mtt.in_hospital_cd_b2
                ELSE NULL
                END
            WHEN ''3''
            THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_a3
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_b3
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN mtt.in_hospital_cd_a3
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN mtt.in_hospital_cd_b3
                ELSE NULL
                END
            WHEN ''4''
            THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_a4
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_b4
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN mtt.in_hospital_cd_a4
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN mtt.in_hospital_cd_b4
                ELSE NULL
                END
            END AS e1 --治療コード
          , (SELECT value FROM sendmsg_gen) AS e02
          , CASE (SELECT value FROM treatment_func_cd_no)
            WHEN ''1''
            THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_a1, (SELECT value FROM func_treat))
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_b1, (SELECT value FROM func_treat))
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN COALESCE(mtt.in_hospital_cd_a1, (SELECT value FROM func_treat))
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN COALESCE(mtt.in_hospital_cd_b1, (SELECT value FROM func_treat))
                ELSE NULL
                END
            WHEN ''2''
            THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_a2, (SELECT value FROM func_treat))
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_b2, (SELECT value FROM func_treat))
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN COALESCE(mtt.in_hospital_cd_a2, (SELECT value FROM func_treat))
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN COALESCE(mtt.in_hospital_cd_b2, (SELECT value FROM func_treat))
                ELSE NULL
                END
            WHEN ''3''
            THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_a3, (SELECT value FROM func_treat))
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_b3, (SELECT value FROM func_treat))
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN COALESCE(mtt.in_hospital_cd_a3, (SELECT value FROM func_treat))
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN COALESCE(mtt.in_hospital_cd_b3, (SELECT value FROM func_treat))
                ELSE NULL
                END
            WHEN ''4''
            THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_a4, (SELECT value FROM func_treat))
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_b4, (SELECT value FROM func_treat))
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN COALESCE(mtt.in_hospital_cd_a4, (SELECT value FROM func_treat))
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN COALESCE(mtt.in_hospital_cd_b4, (SELECT value FROM func_treat))
                ELSE NULL
                END
            END AS e03 --機能コード
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''03'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
          LEFT OUTER JOIN mst_treatment AS mtt
            ON mtt.treatment_cd = ord.ind_treatment_cd
        WHERE
          ord.ord_no = @ordNo
          AND ''1'' = @messageType
        UNION 

        SELECT --ダイアライザ情報
          ''指示詳細'' AS detail_id
          , ''ダイアライザ'' AS sbt_key
          , CASE (SELECT value FROM dialyzer_coop_cd_no)
            WHEN ''1'' THEN mdz.in_hospital_cd_1
            WHEN ''2'' THEN mdz.in_hospital_cd_2
            WHEN ''3'' THEN mdz.in_hospital_cd_3
            WHEN ''4'' THEN mdz.in_hospital_cd_4
            END AS e01
          , (SELECT value FROM sendmsg_gen) AS e02
          , CASE (SELECT value FROM dialyzer_func_cd_no)
            WHEN ''1'' THEN COALESCE(mdz.in_hospital_cd_1, (SELECT value FROM func_dialyzer))
            WHEN ''2'' THEN COALESCE(mdz.in_hospital_cd_2, (SELECT value FROM func_dialyzer))
            WHEN ''3'' THEN COALESCE(mdz.in_hospital_cd_3, (SELECT value FROM func_dialyzer))
            WHEN ''4'' THEN COALESCE(mdz.in_hospital_cd_4, (SELECT value FROM func_dialyzer))
            END AS e03
          , ''000010000'' AS  e04
          , (SELECT value FROM other_dialyzer_unit) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''04'' AS e08
          , NULL ::int AS e09
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
          , CASE (SELECT value FROM dialyzer_coop_cd_no)
            WHEN ''1'' THEN mdz.in_hospital_cd_1
            WHEN ''2'' THEN mdz.in_hospital_cd_2
            WHEN ''3'' THEN mdz.in_hospital_cd_3
            WHEN ''4'' THEN mdz.in_hospital_cd_4
            END AS e01
          , (SELECT value FROM sendmsg_gen) AS e02
          , CASE (SELECT value FROM dialyzer_func_cd_no)
            WHEN ''1'' THEN COALESCE(mdz.in_hospital_cd_1, (SELECT value FROM func_dialyzer))
            WHEN ''2'' THEN COALESCE(mdz.in_hospital_cd_2, (SELECT value FROM func_dialyzer))
            WHEN ''3'' THEN COALESCE(mdz.in_hospital_cd_3, (SELECT value FROM func_dialyzer))
            WHEN ''4'' THEN COALESCE(mdz.in_hospital_cd_4, (SELECT value FROM func_dialyzer))
            END AS e03
          , ''000010000'' AS e04
          , (SELECT value FROM other_dialyzer_unit) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''05'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.ind_equip_info ::json) equip
          LEFT OUTER JOIN mst_dialyzer AS mdz
            ON mdz.dialyzer_cd = TO_NUMBER(equip ->> ''cd'', ''FM999999999999'')
        WHERE
          ord.ord_no = @ordNo
          AND equip ->> ''equip_type'' = ''1''
          
        UNION 
        SELECT --抗凝固剤
        ''指示詳細'' AS detail_id
        , ''抗凝固剤'' AS sbt_key
        , CASE (SELECT value FROM medicine_coop_cd_no)
            WHEN ''1'' THEN mmd.in_hospital_cd_1
            WHEN ''2'' THEN mmd.in_hospital_cd_2
            WHEN ''3'' THEN mmd.in_hospital_cd_3
            WHEN ''4'' THEN mmd.in_hospital_cd_4
            END AS e01
        , (SELECT value FROM sendmsg_gen) AS e02
        , CASE (SELECT value FROM medicine_func_cd_no)
            WHEN ''1'' THEN COALESCE(mmd.in_hospital_cd_1, (SELECT value FROM func_koucoagulant))
            WHEN ''2'' THEN COALESCE(mmd.in_hospital_cd_2, (SELECT value FROM func_koucoagulant))
            WHEN ''3'' THEN COALESCE(mmd.in_hospital_cd_3, (SELECT value FROM func_koucoagulant))
            WHEN ''4'' THEN COALESCE(mmd.in_hospital_cd_4, (SELECT value FROM func_koucoagulant))
            END AS e03
        , koucoagulant.amount AS e04
        , (SELECT value FROM coop_ini_info WHERE key2 = concat(''26'', mmd.unit)) AS e05
        , ''000000000'' AS e06
        , (SELECT value ::text FROM other_koucoagulant_speed_unit) AS e07
        , ''06'' AS e08
        , ROW_NUMBER() OVER(
            ORDER BY
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''4'' THEN timing_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''5'' THEN procedure_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''4'' THEN timing_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''5'' THEN procedure_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''4'' THEN timing_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''5'' THEN procedure_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''4'' THEN timing_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''5'' THEN procedure_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''4'' THEN timing_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''5'' THEN procedure_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''4'' THEN timing_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''5'' THEN procedure_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''4'' THEN timing_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''5'' THEN procedure_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''6'' THEN interval_no END, medi_code_order
            ) AS e09
         FROM (
          SELECT
            --抗凝固剤(単独分）
            1 AS temp_no
            , 1 AS medicine_type
            , 1 AS timing_no
            , 1 AS procedure_no
            , 1 AS interval_no
            , info.value ->> ''value'' AS medi_cd
            , to_char(
                (
                  CASE
                    WHEN ord.ind_cond_info -> ''26'' ->> ''value'' ~ ''^\d+(\.\d+)?$''
                      AND ord.ind_cond_info -> ''28'' ->> ''value'' ~ ''^\d+(\.\d+)?$''
                    THEN
                      (TO_NUMBER(COALESCE(ord.ind_cond_info -> ''26'' ->> ''value'', ''0''), ''FM99999.9999'')
                      + TO_NUMBER(COALESCE(ord.ind_cond_info -> ''28'' ->> ''value'', ''0''), ''FM99999.9999''))
                    ELSE
                      0
                  END
                ),
                ''FM00000V9999''
              ) AS amount
          FROM ord_main ord
          CROSS JOIN lateral jsonb_each(ord.ind_cond_info) AS info
          WHERE
            ord.ord_no = @ordNo
            AND info.key IN (''25'')
            AND ord.ind_cond_info -> ''25'' ->> ''medicine_type'' = ''1''
          UNION
          SELECT
            --抗凝固剤(調製分）
            t.idx AS temp_no
            , 2 AS medicine_type
            , 1 AS timing_no
            , 1 AS procedure_no
            , 1 AS interval_no
            , t.mmxd ->> ''cd'' AS medi_cd
            , CASE t.mmxd ->> ''solvent''
                WHEN ''0'' THEN TO_CHAR(
                    (TO_NUMBER(COALESCE(ord.ind_cond_info -> ''26'' ->> ''value'', ''0''), ''FM00000.0000'')
                    + TO_NUMBER(COALESCE(ord.ind_cond_info -> ''28'' ->> ''value'', ''0''), ''FM00000.0000'')
                    ) * TO_NUMBER(COALESCE(t.mmxd ->> ''amount'', ''0''), ''FM00000.0000'')
                    , ''FM00000V9999'')
                WHEN ''1'' THEN TO_CHAR(TO_NUMBER(COALESCE(t.mmxd ->> ''amount'', ''0''), ''FM00000.0000''), ''FM00000V9999'')
                END AS amount
          FROM ord_main ord
          CROSS JOIN lateral jsonb_each(ord.ind_cond_info) AS info
          LEFT OUTER JOIN mst_medicine_mix AS mmx
            ON mmx.medicine_mix_cd = TO_NUMBER( ord.ind_cond_info -> ''25'' ->> ''value'', ''FM999999999999'')
          CROSS JOIN LATERAL json_array_elements(mmx.mix_info ::json) WITH ORDINALITY AS t(mmxd, idx)
          WHERE
            ord.ord_no = @ordNo
            AND info.key IN (''25'')
            AND ord.ind_cond_info -> ''25'' ->> ''medicine_type'' = ''2''
        ) AS koucoagulant
        LEFT JOIN mst_medi mmd
          ON koucoagulant.medi_cd = mmd.medicine_cd::text

          UNION
          SELECT --透析液情報
          ''指示詳細'' AS detail_id
          , ''透析液'' AS sbt_key
          , CASE (SELECT value FROM medicine_coop_cd_no)
            WHEN ''1'' THEN mmd.in_hospital_cd_1
            WHEN ''2'' THEN mmd.in_hospital_cd_2
            WHEN ''3'' THEN mmd.in_hospital_cd_3
            WHEN ''4'' THEN mmd.in_hospital_cd_4
            END AS e01
          , (SELECT value FROM sendmsg_gen) AS e02
          , CASE (SELECT value FROM medicine_func_cd_no)
            WHEN ''1'' THEN COALESCE(mmd.in_hospital_cd_1, (SELECT value FROM func_medicine))
            WHEN ''2'' THEN COALESCE(mmd.in_hospital_cd_2, (SELECT value FROM func_medicine))
            WHEN ''3'' THEN COALESCE(mmd.in_hospital_cd_3, (SELECT value FROM func_medicine))
            WHEN ''4'' THEN COALESCE(mmd.in_hospital_cd_4, (SELECT value FROM func_medicine))
            END AS e03
          , to_char(
            TO_NUMBER(
              COALESCE(ord.ind_cond_info -> ''17'' ->> ''value'', ''0'')
              , ''FM00000.0000''
            )
            , ''FM00000V9999''
          ) AS e4
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''27'', mmd.unit)) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''07'' AS e08
          , 1 AS e09
        FROM
          ord_main ord
          LEFT OUTER JOIN mst_medicine AS mmd
            ON mmd.medicine_cd = TO_NUMBER(ord.ind_cond_info -> ''15'' ->> ''value'', ''FM999999999999'')
        WHERE
          ord.ord_no = @ordNo
        UNION
        SELECT --補液情報
          ''指示詳細'' AS detail_id
          , ''補液'' AS sbt_key
          , CASE (SELECT value FROM medicine_coop_cd_no)
            WHEN ''1'' THEN mmd.in_hospital_cd_1
            WHEN ''2'' THEN mmd.in_hospital_cd_2
            WHEN ''3'' THEN mmd.in_hospital_cd_3
            WHEN ''4'' THEN mmd.in_hospital_cd_4
            END AS e01
          , (SELECT value FROM sendmsg_gen) AS e02
          , CASE (SELECT value FROM medicine_func_cd_no)
            WHEN ''1'' THEN COALESCE(mmd.in_hospital_cd_1, (SELECT value FROM func_medicine))
            WHEN ''2'' THEN COALESCE(mmd.in_hospital_cd_2, (SELECT value FROM func_medicine))
            WHEN ''3'' THEN COALESCE(mmd.in_hospital_cd_3, (SELECT value FROM func_medicine))
            WHEN ''4'' THEN COALESCE(mmd.in_hospital_cd_4, (SELECT value FROM func_medicine))
            END AS e03
          , to_char(
              TO_NUMBER(
                COALESCE(ord.ind_cond_info -> ''22'' ->> ''value'', ''0'')
                , ''FM00000.0000''
              )
              , ''FM00000V9999''
            ) AS e04
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''27'', mmd.unit)) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''07'' AS e08
          , 2 AS e09
        FROM
          ord_main ord
          LEFT OUTER JOIN mst_medicine AS mmd
            ON mmd.medicine_cd = TO_NUMBER(ord.ind_cond_info -> ''19'' ->> ''value'', ''FM999999999999'')
        WHERE
          ord.ord_no = @ordNo

        UNION
        SELECT --投与薬剤情報
        ''指示詳細'' AS detail_id
        , ind_medi.sbt_key AS sbt_key
        , ind_medi.e01 AS e01
        , (SELECT value FROM sendmsg_gen) AS e02
        , COALESCE(ind_medi.e03, (SELECT value FROM func_medicine)) AS e03
        , ind_medi.e04 AS e04
        , ind_medi.e05 AS e05
        , ''000000000'' AS e06
        , ''  '' AS e07
        , ind_medi.e07 AS e08
        , ROW_NUMBER() OVER(
            ORDER BY
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''6'' THEN interval_no END, medi_code_order
            ) AS e09
	    FROM (
	      SELECT
            --投与薬剤情報(通常)
            100 + t.idx AS temp_no --登録順
            , 1 AS medicine_type --通常→調整
            , (t.medi ->> ''timing_cd'') ::int AS timing_cd --タイミング
            , (t.medi ->> ''procedure_cd'') ::int AS procedure_cd --手技
            , (t.medi ->> ''date_interval'') ::int AS interval_no --投与間隔
            , ''投与薬剤情報(通常)'' AS kinds
            , CASE (SELECT value FROM medicine_coop_cd_no)
              WHEN ''1'' THEN mmd.in_hospital_cd_1
              WHEN ''2'' THEN mmd.in_hospital_cd_2
              WHEN ''3'' THEN mmd.in_hospital_cd_3
              WHEN ''4'' THEN mmd.in_hospital_cd_4
              END AS e01
            , CASE
              WHEN addmed_cd.value IS NULL
              THEN CASE (SELECT value FROM medicine_func_cd_no)
                WHEN ''1'' THEN COALESCE(mmd.in_hospital_cd_1, (SELECT value FROM func_medicine))
                WHEN ''2'' THEN COALESCE(mmd.in_hospital_cd_2, (SELECT value FROM func_medicine))
                WHEN ''3'' THEN COALESCE(mmd.in_hospital_cd_3, (SELECT value FROM func_medicine))
                WHEN ''4'' THEN COALESCE(mmd.in_hospital_cd_4, (SELECT value FROM func_medicine))
                END
              ELSE (SELECT value FROM func_another_add)
              END AS e03
            , t.medi ->> ''cd'' AS medi_cd
            , to_char(
                to_number(t.medi ->> ''amount'', ''FM99999.9999'')
                  , ''FM00000V9999''
              ) AS e04
            , CASE
              WHEN addmed_cd.value IS NULL
              THEN (SELECT value FROM coop_ini_info WHERE key2 = concat(''27'', mmd.unit))
              ELSE (SELECT value FROM coop_ini_info WHERE key2 = concat(''30'', mmd.unit)) --時間外薬剤
              END AS e05
            , CASE
              WHEN addmed_cd.value IS NULL
              THEN ''08''
              ELSE ''13''
              END AS e07
            , ''投与薬剤'' AS sbt_key
          FROM ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info ::json) WITH ORDINALITY AS t(medi, idx)
          LEFT OUTER JOIN mst_medicine AS mmd
            ON mmd.medicine_cd = TO_NUMBER(t.medi ->> ''cd'', ''FM999999999999'')
          LEFT OUTER JOIN addmed_cd
            ON (CASE (SELECT value FROM medicine_coop_cd_no)
              WHEN ''1'' then mmd.in_hospital_cd_1 = addmed_cd.value
              WHEN ''2'' then mmd.in_hospital_cd_2 = addmed_cd.value
              WHEN ''3'' then mmd.in_hospital_cd_3 = addmed_cd.value
              WHEN ''4'' then mmd.in_hospital_cd_4 = addmed_cd.value
              END)
          WHERE
            ord.ord_no = @ordNo
            AND t.medi ->> ''medicine_type'' = ''1''
            AND (CASE (SELECT value FROM medicine_func_cd_no)
              WHEN ''1'' THEN coalesce(mmd.in_hospital_cd_1, ''null'') NOT IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
              WHEN ''2'' THEN coalesce(mmd.in_hospital_cd_2, ''null'') NOT IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
              WHEN ''3'' THEN coalesce(mmd.in_hospital_cd_3, ''null'') NOT IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
              WHEN ''4'' THEN coalesce(mmd.in_hospital_cd_4, ''null'') NOT IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
              END)
          UNION
          SELECT
            --投与薬剤情報(調整)
            100 + t.idx AS temp_no --登録順
            , 2 AS medicine_type --通常→調整
            , (t.medi ->> ''timing_cd'') ::int AS timing_cd --タイミング
            , (t.medi ->> ''procedure_cd'') ::int AS procedure_cd --手技
            , (t.medi ->> ''date_interval'') ::int AS interval_no --投与間隔
            , ''投与薬剤情報(調整)'' AS kinds
            , CASE (SELECT value FROM medicine_coop_cd_no)
              WHEN ''1'' THEN mmd.in_hospital_cd_1
              WHEN ''2'' THEN mmd.in_hospital_cd_2
              WHEN ''3'' THEN mmd.in_hospital_cd_3
              WHEN ''4'' THEN mmd.in_hospital_cd_4
              END AS e01
            , CASE
              WHEN addmed_cd.value IS NULL
              THEN CASE (SELECT value FROM medicine_func_cd_no)
                WHEN ''1'' THEN COALESCE(mmd.in_hospital_cd_1, (SELECT value FROM func_medicine))
                WHEN ''2'' THEN COALESCE(mmd.in_hospital_cd_2, (SELECT value FROM func_medicine))
                WHEN ''3'' THEN COALESCE(mmd.in_hospital_cd_3, (SELECT value FROM func_medicine))
                WHEN ''4'' THEN COALESCE(mmd.in_hospital_cd_4, (SELECT value FROM func_medicine))
                END
              ELSE (SELECT value FROM func_another_add)
              END AS e03
            , t.medi ->> ''cd'' AS medi_cd
            , CASE mmxd ->> ''solvent''
              WHEN ''1'' THEN to_char(
                  to_number(mmxd ->> ''amount'', ''FM99999.9999'')
                  , ''FM00000V9999''
                )
              ELSE to_char(
                  to_number(t.medi ->> ''amount'', ''FM99999.9999'') * to_number(mmxd ->> ''amount'', ''FM99999.9999'')
                  , ''FM00000V9999''
                )
              END AS e04
          , CASE
              WHEN addmed_cd.value IS NULL
              THEN (SELECT value FROM coop_ini_info WHERE key2 = concat(''27'', mmd.unit))
              ELSE (SELECT value FROM coop_ini_info WHERE key2 = concat(''30'', mmd.unit)) --時間外薬剤
              END AS e05
          , CASE
              WHEN addmed_cd.value IS NULL
              THEN ''08''
              ELSE ''13''
              END AS e07
          , ''調製'' AS sbt_key
          FROM ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info ::json) WITH ORDINALITY AS t(medi, idx)
          LEFT OUTER JOIN mst_medicine_mix AS mmx
            ON mmx.medicine_mix_cd = TO_NUMBER(t.medi ->> ''cd'', ''FM999999999999'')
          CROSS JOIN LATERAL json_array_elements(mmx.mix_info ::json) mmxd
          LEFT OUTER JOIN mst_medicine AS mmd
            ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''FM999999999999'')
          LEFT OUTER JOIN addmed_cd
            ON (CASE (SELECT value FROM medicine_coop_cd_no)
              WHEN ''1'' then mmd.in_hospital_cd_1 = addmed_cd.value
              WHEN ''2'' then mmd.in_hospital_cd_2 = addmed_cd.value
              WHEN ''3'' then mmd.in_hospital_cd_3 = addmed_cd.value
              WHEN ''4'' then mmd.in_hospital_cd_4 = addmed_cd.value
              END)
          WHERE
            ord.ord_no = @ordNo
            AND t.medi ->> ''medicine_type'' = ''2''
            AND (CASE (SELECT value FROM medicine_func_cd_no)
              WHEN ''1'' THEN coalesce(mmd.in_hospital_cd_1, ''null'') NOT IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
              WHEN ''2'' THEN coalesce(mmd.in_hospital_cd_2, ''null'') NOT IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
              WHEN ''3'' THEN coalesce(mmd.in_hospital_cd_3, ''null'') NOT IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
              WHEN ''4'' THEN coalesce(mmd.in_hospital_cd_4, ''null'') NOT IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
              END)
        ) AS ind_medi
        LEFT JOIN mst_medi mmd
        ON ind_medi.medi_cd = mmd.medicine_cd::text
        LEFT JOIN timing_order
        ON ind_medi.timing_cd = timing_order.timing_code
        LEFT JOIN procedure_order
        ON ind_medi.procedure_cd = procedure_order.procedure_code
        UNION

        SELECT
          --穿刺針情報
          ''指示詳細'' AS detail_id
          , ''穿刺針'' AS sbt_key
          , CASE (SELECT value FROM equipment_coop_cd_no)
            WHEN ''1'' THEN meq.in_hospital_cd_1
            WHEN ''2'' THEN meq.in_hospital_cd_2
            WHEN ''3'' THEN meq.in_hospital_cd_3
            WHEN ''4'' THEN meq.in_hospital_cd_4
            END AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02
          , CASE (SELECT value FROM equipment_func_cd_no)
            WHEN ''1'' THEN COALESCE(meq.in_hospital_cd_1, (SELECT value FROM func_aneedle))
            WHEN ''2'' THEN COALESCE(meq.in_hospital_cd_2, (SELECT value FROM func_aneedle))
            WHEN ''3'' THEN COALESCE(meq.in_hospital_cd_3, (SELECT value FROM func_aneedle))
            WHEN ''4'' THEN COALESCE(meq.in_hospital_cd_4, (SELECT value FROM func_aneedle))
            END AS e03
          , TO_CHAR(TO_NUMBER(punc_needle.amount, ''FM00000.0000''), ''FM00000V9999'') AS e04
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''28'', meq.unit)) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''09'' AS e08
          , ROW_NUMBER() OVER(
            ORDER BY
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 0 THEN temp_no
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 1 THEN meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 2 THEN meq_code_order END,
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 0 THEN temp_no
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 1 THEN meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 2 THEN meq_code_order END,
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 0 THEN temp_no
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 1 THEN meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 2 THEN meq_code_order END, meq_code_order
            ) AS e09
          FROM (
            SELECT
              --透析条件A針V針SN針
              CASE
                  WHEN info.key = ''9'' THEN 1
                  WHEN info.key = ''10'' THEN 2
                  WHEN info.key = ''11'' THEN 3
                  END AS temp_no
              , info.value ->> ''value'' AS eq_cd
              , ''1'' AS amount
            FROM ord_main ord
            CROSS JOIN LATERAL jsonb_each(ord.ind_cond_info) AS info
            WHERE
              ord.ord_no = @ordNo
              AND info.key IN (''9'',''10'',''11'')
            UNION
            SELECT
              --医材内穿刺針
              4 + t.idx AS temp_no
              , t.equip ->> ''cd'' AS eq_cd
              , t.equip ->> ''amount'' AS amount
            FROM ord_main ord
            CROSS JOIN LATERAL json_array_elements(ord.ind_equip_info ::json) WITH ORDINALITY AS t(equip, idx)
            LEFT JOIN mst_equip
              ON t.equip ->> ''cd'' = mst_equip.equipment_cd ::text
            LEFT JOIN mst_equipment_class
              ON mst_equip.class_cd = mst_equipment_class.class_cd
            WHERE
              ord.ord_no = @ordNo
              AND mst_equipment_class.class_type IN (''2'', ''3'')
          ) AS punc_needle
          LEFT JOIN mst_equip meq
          ON punc_needle.eq_cd = meq.equipment_cd::text
        UNION

        SELECT --医材情報
          ''指示詳細'' AS detail_id
          , ''医材'' AS sbt_key
          , CASE (SELECT value FROM equipment_coop_cd_no)
            WHEN ''1'' THEN meq.in_hospital_cd_1
            WHEN ''2'' THEN meq.in_hospital_cd_2
            WHEN ''3'' THEN meq.in_hospital_cd_3
            WHEN ''4'' THEN meq.in_hospital_cd_4
            END AS e01
          , (SELECT value FROM sendmsg_gen) AS e02
          , CASE (SELECT value FROM equipment_func_cd_no)
            WHEN ''1'' THEN COALESCE(meq.in_hospital_cd_1, (SELECT value FROM func_consumption))
            WHEN ''2'' THEN COALESCE(meq.in_hospital_cd_2, (SELECT value FROM func_consumption))
            WHEN ''3'' THEN COALESCE(meq.in_hospital_cd_3, (SELECT value FROM func_consumption))
            WHEN ''4'' THEN COALESCE(meq.in_hospital_cd_4, (SELECT value FROM func_consumption))
            END AS e03
          , CASE
            WHEN mst_equipment_class.class_type = ''4'' THEN ''000010000''
            ELSE to_char(
              to_number(equip ->> ''amount'', ''99999.9999'')
              , ''FM00000V9999''
            )
            END AS e04
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''29'', meq.unit)) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''10'' AS e08
          , ROW_NUMBER() OVER(
            ORDER BY
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 0 THEN t.idx
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 1 THEN meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 2 THEN meq_code_order END,
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 0 THEN t.idx
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 1 THEN meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 2 THEN meq_code_order END,
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 0 THEN t.idx
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 1 THEN meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 2 THEN meq_code_order END, meq_code_order
            ) AS e09
        FROM
          ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.ind_equip_info ::json) WITH ORDINALITY AS t(equip, idx)
          LEFT JOIN mst_equip meq
              ON meq.equipment_cd = TO_NUMBER(t.equip ->> ''cd'', ''FM999999999999'')
            LEFT JOIN mst_equipment_class
              ON meq.class_cd = mst_equipment_class.class_cd
        WHERE
          t.equip ->> ''equip_type'' = ''0''
          AND mst_equipment_class.class_type NOT IN (''2'', ''3'')
          AND ord.ord_no = @ordNo

        --特殊血液浄化
        UNION
        SELECT --1次膜情報
          ''指示詳細'' AS detail_id
          , ''1次膜'' AS sbt_key
          , CASE (SELECT value FROM equipment_coop_cd_no)
            WHEN ''1'' THEN meq.in_hospital_cd_1
            WHEN ''2'' THEN meq.in_hospital_cd_2
            WHEN ''3'' THEN meq.in_hospital_cd_3
            WHEN ''4'' THEN meq.in_hospital_cd_4
            END AS e01
          , (SELECT value FROM sendmsg_gen) AS e02
          , CASE (SELECT value FROM equipment_func_cd_no)
            WHEN ''1'' THEN COALESCE(meq.in_hospital_cd_1, (SELECT value FROM func_consumption))
            WHEN ''2'' THEN COALESCE(meq.in_hospital_cd_2, (SELECT value FROM func_consumption))
            WHEN ''3'' THEN COALESCE(meq.in_hospital_cd_3, (SELECT value FROM func_consumption))
            WHEN ''4'' THEN COALESCE(meq.in_hospital_cd_4, (SELECT value FROM func_consumption))
            END AS e03
          , ''000010000'' AS e04
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''29'', meq.unit)) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''11'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
          LEFT OUTER JOIN mst_equip AS meq
            ON meq.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''7'' ->> ''value'', ''FM999999999999'') 
        WHERE
          ord.ord_no = @ordNo
        UNION
        SELECT --2次膜情報
          ''指示詳細'' AS detail_id
          , ''2次膜'' AS sbt_key
          , meq.in_hospital_cd_1 AS e01
          , (SELECT value FROM sendmsg_gen) AS e02
          , COALESCE(meq.in_hospital_cd_2, (SELECT value FROM func_consumption)) AS e03
          , ''000010000'' AS e04
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''29'', meq.unit)) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''12'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
          LEFT OUTER JOIN mst_equipment AS meq
            ON meq.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''8'' ->> ''value'', ''FM999999999999'') 
        WHERE
          ord.ord_no = @ordNo
        UNION
        SELECT --血液回路
          ''指示詳細'' AS detail_id
          , ''血液回路'' AS sbt_key
          , meq.in_hospital_cd_1 AS e01
          , (SELECT value FROM sendmsg_gen) AS e02
          , COALESCE(meq.in_hospital_cd_2, (SELECT value FROM func_consumption)) AS e03
          , ''000010000'' AS e04
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''29'', meq.unit)) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''13'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
          LEFT OUTER JOIN mst_equipment AS meq
            ON meq.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''13'' ->> ''value'', ''FM999999999999'') 
        WHERE
          ord.ord_no = @ordNo
        UNION
        SELECT --吸着カラム
          ''指示詳細'' AS detail_id
          , ''吸着カラム'' AS sbt_key
          , meq.in_hospital_cd_1 AS e01
          , (SELECT value FROM sendmsg_gen) AS e02
          , COALESCE(meq.in_hospital_cd_2, (SELECT value FROM func_consumption)) AS e03
          , ''000010000'' AS e04
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''29'', meq.unit)) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''14'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
          LEFT OUTER JOIN mst_equipment AS meq
            ON meq.equipment_cd = TO_NUMBER( ord.ind_cond_info -> ''6'' ->> ''value'', ''FM999999999999'') 
        WHERE
          ord.ord_no = @ordNo
        UNION
        SELECT
          --加算(その他)Ver1
          ''指示詳細'' AS detail_id
          , ''加算(その他)'' AS sbt_key
          , pcd.item_code AS e01 --項目コード
          , pcd.item_generation AS e02 --項目世代番号
          , (SELECT value FROM func_another_add) AS e03 --機能コード
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''15'' AS e08
          , pcd.idx ::int AS e09
        FROM
          pcd_save_3 pcd
        WHERE
          pcd.function_code = ''30''
          AND pcd.item_code IS NOT NULL
          AND ''1'' = @messageType
        UNION
                --
        SELECT
          --加算(患者)、加算(その他)その2、項目コメント、透析コメント1~3Ver2
          ''指示詳細'' AS detail_id
          , kinds
          , CASE (SELECT value FROM medicine_coop_cd_no)
            WHEN ''1'' THEN mmd.in_hospital_cd_1
            WHEN ''2'' THEN mmd.in_hospital_cd_2
            WHEN ''3'' THEN mmd.in_hospital_cd_3
            WHEN ''4'' THEN mmd.in_hospital_cd_4
            END AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , CASE (SELECT value FROM medicine_func_cd_no)
            WHEN ''1'' THEN mmd.in_hospital_cd_1
            WHEN ''2'' THEN mmd.in_hospital_cd_2
            WHEN ''3'' THEN mmd.in_hospital_cd_3
            WHEN ''4'' THEN mmd.in_hospital_cd_4
            END AS e03 --機能コード
          , ind_medi.amount AS e04
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''27'', mmd.unit)) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , (CASE (SELECT value FROM medicine_func_cd_no)
            WHEN ''1'' THEN
              CASE mmd.in_hospital_cd_1
              WHEN (SELECT value FROM func_addition) THEN ''01''
              WHEN (SELECT value FROM func_another_add) THEN ''16''
              WHEN (SELECT value FROM func_item_comment) THEN ''19''
              WHEN (SELECT value FROM func_dialysis_comment) THEN ''20''
              WHEN (SELECT value FROM func_dialysis_comment2) THEN ''21''
              WHEN (SELECT value FROM func_dialysis_comment3) THEN ''22''
              END
            WHEN ''2'' THEN
              CASE mmd.in_hospital_cd_2
              WHEN (SELECT value FROM func_addition) THEN ''01''
              WHEN (SELECT value FROM func_another_add) THEN ''16''
              WHEN (SELECT value FROM func_item_comment) THEN ''19''
              WHEN (SELECT value FROM func_dialysis_comment) THEN ''20''
              WHEN (SELECT value FROM func_dialysis_comment2) THEN ''21''
              WHEN (SELECT value FROM func_dialysis_comment3) THEN ''22''
              END
            WHEN ''3'' THEN
              CASE mmd.in_hospital_cd_3
              WHEN (SELECT value FROM func_addition) THEN ''01''
              WHEN (SELECT value FROM func_another_add) THEN ''16''
              WHEN (SELECT value FROM func_item_comment) THEN ''19''
              WHEN (SELECT value FROM func_dialysis_comment) THEN ''20''
              WHEN (SELECT value FROM func_dialysis_comment2) THEN ''21''
              WHEN (SELECT value FROM func_dialysis_comment3) THEN ''22''
              END
            WHEN ''4'' THEN
              CASE mmd.in_hospital_cd_4
              WHEN (SELECT value FROM func_addition) THEN ''01''
              WHEN (SELECT value FROM func_another_add) THEN ''16''
              WHEN (SELECT value FROM func_item_comment) THEN ''19''
              WHEN (SELECT value FROM func_dialysis_comment) THEN ''20''
              WHEN (SELECT value FROM func_dialysis_comment2) THEN ''21''
              WHEN (SELECT value FROM func_dialysis_comment3) THEN ''22''
              END
            END) AS e08
          , ROW_NUMBER() OVER(
            ORDER BY
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''6'' THEN interval_no END, medi_code_order
            ) AS e09
        FROM (
          SELECT
            --投与薬剤情報(通常)
            100 + t.idx AS temp_no --登録順
            , 1 AS medicine_type --通常→調整
            , (t.medi ->> ''timing_cd'') ::int AS timing_cd --タイミング
            , (t.medi ->> ''procedure_cd'') ::int AS procedure_cd --手技
            , (t.medi ->> ''date_interval'') ::int AS interval_no --投与間隔
            , ''加算投与薬剤情報(通常)'' AS kinds
            , t.medi ->> ''cd'' AS medi_cd
            , TO_CHAR(
                TO_NUMBER(COALESCE(t.medi ->> ''amount'', ''0''), ''FM00000.0000'')
            , ''FM00000V9999'') AS amount
          FROM ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info ::json) WITH ORDINALITY AS t(medi, idx)
          WHERE
            ord.ord_no = @ordNo
            AND ''2'' = @messageType
            AND t.medi ->> ''medicine_type'' = ''1''
          UNION
          SELECT
            --投与薬剤情報(調整)
            100 + t.idx AS temp_no --登録順
            , 2 AS medicine_type --通常→調整
            , (t.medi ->> ''timing_cd'') ::int AS timing_cd --タイミング
            , (t.medi ->> ''procedure_cd'') ::int AS procedure_cd --手技
            , (t.medi ->> ''date_interval'') ::int AS interval_no --投与間隔
            , ''加算投与薬剤情報(調整)'' AS kinds
            , t2.mmxd ->> ''cd'' AS medi_cd
            , CASE t2.mmxd ->> ''solvent''
                WHEN ''0'' THEN TO_CHAR(
                    TO_NUMBER(COALESCE(t.medi ->> ''amount'', ''0''), ''FM00000.0000'')
                    * TO_NUMBER(COALESCE(t2.mmxd ->> ''amount'', ''0''), ''FM00000.0000'')
                    , ''FM00000V9999'')
                WHEN ''1'' THEN TO_CHAR(TO_NUMBER(COALESCE(t2.mmxd ->> ''amount'', ''0''), ''FM00000.0000''), ''FM00000V9999'')
                END AS amount
          FROM ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info ::json) WITH ORDINALITY AS t(medi, idx)
          LEFT OUTER JOIN mst_medicine_mix AS mmx
            ON mmx.medicine_mix_cd = TO_NUMBER(t.medi ->> ''cd'', ''FM999999999999'')
          CROSS JOIN LATERAL json_array_elements(mmx.mix_info ::json) WITH ORDINALITY AS t2(mmxd, idx)
          WHERE
            ord.ord_no = @ordNo
            AND ''2'' = @messageType
            AND t.medi ->> ''medicine_type'' = ''2''
        ) AS ind_medi
        LEFT JOIN mst_medi mmd ON ind_medi.medi_cd = mmd.medicine_cd::text
        LEFT JOIN timing_order ON ind_medi.timing_cd = timing_order.timing_code
        LEFT JOIN procedure_order ON ind_medi.procedure_cd = procedure_order.procedure_code
        WHERE
          (CASE (SELECT value FROM medicine_func_cd_no)
          WHEN ''1'' THEN mmd.in_hospital_cd_1 IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
          WHEN ''2'' THEN mmd.in_hospital_cd_2 IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
          WHEN ''3'' THEN mmd.in_hospital_cd_3 IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
          WHEN ''4'' THEN mmd.in_hospital_cd_4 IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
          END)
        --
        UNION

        SELECT --加算(透析困難理由)
          ''指示詳細'' AS detail_id
          , ''透析困難'' AS sbt_key
          , CASE (SELECT value FROM difficult_coop_cd_no)
            WHEN ''1'' THEN mdd.in_hospital_cd_1
            WHEN ''2'' THEN mdd.in_hospital_cd_2
            END AS e01
          , (SELECT value FROM sendmsg_gen) AS e02
          , CASE (SELECT value FROM difficult_func_cd_no)
            WHEN ''1'' THEN COALESCE(mdd.in_hospital_cd_1, (SELECT value FROM func_another_add))
            WHEN ''2'' THEN COALESCE(mdd.in_hospital_cd_2, (SELECT value FROM func_another_add))
            END AS e03
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''17'' AS e08
          , NULL ::int AS e09
        FROM
          mst_dialysis_difficulty mdd
        WHERE
          ''2'' = @messageType
          AND mdd.dialysis_difficulty_cd IN (SELECT regexp_split_to_table(@mstCddd, '','')::INT)
          AND mdd.is_del = ''0''
        UNION

        SELECT --その他項目(透析時間)
          ''指示詳細'' AS detail_id
          , ''所要時間'' AS sbt_key
          , (SELECT value FROM other_dialysis_time) AS e01 --コード
          , (SELECT value FROM sendmsg_gen) AS e02
          , (SELECT value FROM func_other_item) AS e03 --項目名
          , to_char(
            TO_NUMBER(
              ord.ind_cond_info -> ''1'' ->> ''value''
              , ''FM999999999999''
            )
            , ''FM00000V9999''
          ) AS e04
          , (SELECT value FROM other_dialysis_unit) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''18'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
        WHERE
          ord.ord_no = @ordNo
        UNION
        SELECT
        --項目コメント Ver.1
        ''指示詳細'' AS detail_id
          , ''項目コメント'' AS sbt_key
          , pcd.item_code AS e01 --項目コード
          , pcd.item_generation AS e02 --項目世代番号
          , (SELECT value FROM func_item_comment) AS e03
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''19'' AS e08
          , pcd.idx ::int AS e09
        FROM
          pcd_save_3 pcd
        WHERE
          pcd.function_code = ''32''
          AND pcd.item_code IS NOT NULL
          AND ''1'' = @messageType
        UNION
        SELECT
        --透析コメント1 Ver.1
        ''指示詳細'' AS detail_id
          , ''透析コメント1'' AS sbt_key
          , pcd.item_code AS e01 --項目コード
          , pcd.item_generation AS e02 --項目世代番号
          , (SELECT value FROM func_dialysis_comment) AS e03
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''20'' AS e08
          , pcd.idx ::int AS e09
        FROM
          pcd_save_3 pcd
        WHERE
          pcd.function_code = ''3A''
          AND pcd.item_code IS NOT NULL
          AND ''1'' = @messageType
        UNION
        SELECT
        --透析コメント2 Ver.1
        ''指示詳細'' AS detail_id
          , ''透析コメント2'' AS sbt_key
          , pcd.item_code AS e01 --項目コード
          , pcd.item_generation AS e02 --項目世代番号
          , (SELECT value FROM func_dialysis_comment2) AS e03
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''21'' AS e08
          , pcd.idx ::int AS e09
        FROM
          pcd_save_3 pcd
        WHERE
          pcd.function_code = ''3B''
          AND pcd.item_code IS NOT NULL
          AND ''1'' = @messageType
        UNION
        SELECT
        --透析コメント3 Ver.1
        ''指示詳細'' AS detail_id
          , ''透析コメント3'' AS sbt_key
          , pcd.item_code AS e01 --項目コード
          , pcd.item_generation AS e02 --項目世代番号
          , (SELECT value FROM func_dialysis_comment3) AS e03
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''22'' AS e08
          , pcd.idx ::int AS e09
        FROM
          pcd_save_3 pcd
        WHERE
          pcd.function_code = ''3C''
          AND pcd.item_code IS NOT NULL
          AND ''1'' = @messageType

      ) all_cost
    WHERE
      all_cost.e01 IS NOT NULL
    ORDER BY
      all_cost.e08
      , CAST(all_cost.e09 as integer)
      , all_cost.e01
  ) cost_fin', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'NEC)詳細指示繰り返し部', '2025-01-09 10:16:16.678', CURRENT_TIMESTAMP, '[{"sql_cd": -206, "field_name": "pat_dial_diff_cd", "replace_var": "@mstCddd"}]'::jsonb);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-202, 'WITH coop_ini_info AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
        , info ->> ''key2'' AS key2
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = ''HR''
        AND info ->> ''key1'' = ''NEC''
)
, sendmsg_gen AS ( --項目世代番号
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''SENDMSG_GEN''
)
, func_addition AS ( --加算(患者)機能コード
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_ADDITION''
)
, va_coop_cd_no AS ( --VAの連携コード番号設定
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''VA_COOP_CD_NO''
)
, va_func_cd_no AS ( --VAの機能コード番号設定
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''VA_FUNC_CD_NO''
)
, func_bloodaccess AS ( --VAの機能コード
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_BLOODACCESS''
)
, treatment_coop_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''TREATMENT_COOP_CD_NO''
)
, treatment_func_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''TREATMENT_FUNC_CD_NO''
)
, func_treat AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_TREAT''
)
, dialyzer_coop_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''DIALYZER_COOP_CD_NO''
)
, dialyzer_func_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''DIALYZER_FUNC_CD_NO''
)
, func_dialyzer AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_DIALYZER''
)
, other_dialyzer_unit AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''OTHER_DIALYZER_UNIT''
)
, medicine_coop_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''MEDICINE_COOP_CD_NO''
)
, medicine_func_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''MEDICINE_FUNC_CD_NO''
)
, func_medicine AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_MEDICINE''
)
, func_koucoagulant AS ( --抗凝固剤
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_KOUCOAGULANT''
)
, other_koucoagulant_speed_unit AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''OTHER_KOUCOAGULANT_SPEED_UNIT''
)
, num_auto_calc AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
        , info ->> ''key2'' AS key2
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = ''HR''
        AND info ->> ''key1'' = ''NUM_AUTO_CALC''
)
, num_auto_calc_ranges AS ( --透析液量自動計算
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS range_string
        , info ->> ''key2'' AS cd
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = ''HR''
        AND info ->> ''key1'' = ''NUM_AUTO_CALC''
        AND info ->> ''key2'' <> ''AUTO_CALC_FLG''
)
, parsed_ranges_check_1 AS ( --透析液量自動計算設定チェック
    SELECT
        CASE WHEN split_part(value, '':'', 1) ~ ''^\d+(\.\d+)?$''
        THEN NULLIF(split_part(value, '':'', 1), '''')
        ELSE NULL
        END AS lower_bound,
        CASE WHEN split_part(value, '':'', 2) ~ ''^\d+(\.\d+)?$''
        THEN NULLIF(split_part(value, '':'', 2), '''')
        ELSE NULL
        END AS value,
        ranges.cd
    FROM num_auto_calc_ranges ranges
    CROSS JOIN unnest(string_to_array(range_string, ''/'')) AS value
)
, parsed_ranges_check_2 AS ( --透析液量自動計算設定チェック
    SELECT distinct
        cd,
        ''NG'' AS check_result
    FROM parsed_ranges_check_1
    WHERE lower_bound IS NULL
        OR value IS NULL
)
, parsed_ranges AS ( --透析液量自動計算
    SELECT
        split_part(value, '':'', 1)::numeric AS lower_bound,
        split_part(value, '':'', 2)::numeric AS value,
        lead(split_part(value, '':'', 1)::numeric, 1, 100000) OVER (PARTITION BY ranges.cd ORDER BY split_part(value, '':'', 1)::numeric) -0.0001 AS upper_bound,
        ranges.cd
    FROM num_auto_calc_ranges ranges
    LEFT JOIN parsed_ranges_check_2 on ranges.cd = parsed_ranges_check_2.cd
    CROSS JOIN unnest(string_to_array(range_string, ''/'')) AS value
    WHERE parsed_ranges_check_2.check_result IS NULL
)
, rst_minutes as ( --透析時間(分)
    SELECT FLOOR(EXTRACT(epoch FROM (date_trunc(''minute'', ord.rst_end_date) - date_trunc(''minute'', ord.rst_start_date))) / 60) as minutes
    FROM ord_main ord
    WHERE ord_no = @ordNo
)
, parsed_table AS ( --透析液量自動計算
    SELECT pr.value, pr.cd
    FROM parsed_ranges pr, rst_minutes
    WHERE rst_minutes.minutes BETWEEN pr.lower_bound AND pr.upper_bound
)
, oxygen_code AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''OXYGEN_CODE''
)
, oxygen_used_unit AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''OXYGEN_USED_UNIT''
)
, equipment_coop_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''EQUIPMENT_COOP_CD_NO''
)
, equipment_func_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''EQUIPMENT_FUNC_CD_NO''
)
, func_aneedle AS ( --穿刺針
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_ANEEDLE''
)
, func_consumption AS ( --医療材料
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_CONSUMPTION''
)
, func_another_add AS ( --時間外薬剤
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_ANOTHER_ADD''
)
, addmed_cd as ( --時間外薬剤コードリスト
	select *
	FROM coop_ini_info
	WHERE key2 like ''MEDICINE_ADDMED_CODE%''
)
, difficult_coop_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''DIFFICULT_COOP_CD_NO''
)
, difficult_func_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''DIFFICULT_FUNC_CD_NO''
)
, addition_coop_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''ADDITION_COOP_CD_NO''
)
, addition_func_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''ADDITION_FUNC_CD_NO''
)
, other_dialysis_time AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''OTHER_DIALYSIS_TIME''
)
, other_dialysis_unit AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''OTHER_DIALYSIS_UNIT''
)
, func_other_item AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_OTHER_ITEM''
)
, other_off_water AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''OTHER_OFF_WATER''
)
, other_off_water_unit AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''OTHER_OFF_WATER_UNIT''
)
, func_item_comment AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_ITEM_COMMENT''
)
, func_dialysis_comment AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_DIALYSIS_COMMENT''
)
, func_dialysis_comment2 AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_DIALYSIS_COMMENT2''
)
, func_dialysis_comment3 AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''FUNC_DIALYSIS_COMMENT3''
)
, equip_order_data AS (
  SELECT
    ROW_NUMBER () OVER () AS no2
    , TO_NUMBER(datt.a1  :: text, ''999999999999'') AS ora
  FROM (
    SELECT TO_NUMBER((unnest(string_to_array((
      SELECT mst_f.value AS rtt
      FROM mst_facility_setting AS mst_f
      WHERE mst_f.facility_setting_no = ''3006'' AND mst_f.facility_cd = @facilityCd
    ),'',''))), ''999999999999'') AS a1) AS datt
)
, equip_order AS (
  SELECT
    index_no ::int AS meq_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_equipment''
)
, equip_class_order as (
  SELECT
    index_no ::int AS meq_class_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_class_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_equipment_class''
)
, mst_equip AS (
  SELECT
    equipment_cd
    , equipment_name
    , class_cd
    , unit
    , in_hospital_cd_1
    , in_hospital_cd_2
    , in_hospital_cd_3
    , in_hospital_cd_4
    , equip_order.meq_code_order
    , equip_class_order.meq_class_code_order
  FROM mst_equipment meq
  LEFT JOIN equip_order ON meq.equipment_cd = equip_order.meq_code
  LEFT JOIN equip_class_order ON meq.class_cd = equip_class_order.meq_class_code
  WHERE facility_cd = @facilityCd
)
, medi_order_data AS (
  SELECT
    ROW_NUMBER () OVER () AS no2
    , TO_NUMBER(datt.a1  :: text, ''999999999999'') AS a1
  FROM (
    SELECT TO_NUMBER((unnest(string_to_array((
      SELECT mst_f.value AS rtt
      FROM mst_facility_setting AS mst_f
      WHERE mst_f.facility_setting_no = ''3007'' AND mst_f.facility_cd = @facilityCd
    ),'',''))), ''999999999999'') AS a1) AS datt
)
, medi_order AS (
  SELECT
    index_no ::int AS medi_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_medicine''
)
, medi_class_order AS (
  SELECT
    index_no ::int AS medi_class_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_class_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_medicine_class''
)
, timing_order AS (
  SELECT
    index_no ::int AS timing_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS timing_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_medicate_timing''
)
, procedure_order AS (
  SELECT
    index_no ::int AS procedure_code_order
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
    , in_hospital_cd_3
    , in_hospital_cd_4
    , medi_order.medi_code_order
    , medi_class_order.medi_class_code_order
  FROM mst_medicine mmd
  LEFT JOIN medi_order ON mmd.medicine_cd = medi_order.medi_code
  LEFT JOIN medi_class_order ON mmd.class_cd = medi_class_order.medi_class_code
  WHERE facility_cd = @facilityCd
)
, pcd_save_3 AS (
  SELECT
    t.values ->> ''item_code'' as item_code
    , t.values ->> ''function_code'' as function_code
    , t.values ->> ''item_generation'' as item_generation
    , t.idx as idx
  FROM pat_coop_detail pcd
  CROSS JOIN jsonb_array_elements(pcd.save_3) with ORDINALITY AS t(values, idx)
  WHERE pat_id = @patId
)
SELECT
  LPAD(TO_CHAR(ROW_NUMBER() OVER (), ''FM000''), 3, '' '') AS cost_no
  , cost_fin.*
FROM
  (
    SELECT
      all_cost.*
    FROM
      (
        SELECT
          --加算(患者)Ver1
          ''実績詳細'' AS detail_id
          , ''加算(患者)'' AS sbt_key
          , pcd.item_code AS e01 --項目コード
          , pcd.item_generation AS e02 --項目世代番号
          , (SELECT value FROM func_addition) AS e03 --機能コード
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''01'' AS e08
          , pcd.idx ::int AS e09
        FROM
          pcd_save_3 pcd
        WHERE
          pcd.function_code = ''20''
          AND pcd.item_code IS NOT NULL
          AND ''1'' = @messageType
        UNION ALL
        SELECT
          --VA情報
          ''実績詳細'' AS detail_id
          , ''VA'' AS sbt_key
          , CASE (SELECT value FROM va_coop_cd_no)
            WHEN ''1'' THEN mva.in_hospital_cd_1
            WHEN ''2'' THEN mva.in_hospital_cd_2
            END AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , CASE (SELECT value FROM va_func_cd_no)
            WHEN ''1'' THEN COALESCE(mva.in_hospital_cd_1, (SELECT value FROM func_bloodaccess))
            WHEN ''2'' THEN COALESCE(mva.in_hospital_cd_2, (SELECT value FROM func_bloodaccess))
            END AS e03 --機能コード
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''02'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
          LEFT OUTER JOIN mst_va AS mva
            ON mva.va_cd = TO_NUMBER( ord.rst_cond_info -> ''2'' ->> ''value'', ''FM999999999999'')
        WHERE
          ord.ord_no = @ordNo
          AND ''2'' = @messageType
        UNION ALL
        SELECT
          --透析方法
          ''実績詳細'' AS detail_id
          , ''治療項目'' AS sbt_key
          , CASE (SELECT value FROM treatment_coop_cd_no)
            WHEN ''1''
                THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_a1
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_b1
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN mtt.in_hospital_cd_a1
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN mtt.in_hospital_cd_b1
                ELSE NULL
                END
            WHEN ''2'' 
                THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_a2
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_b2
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN mtt.in_hospital_cd_a2
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN mtt.in_hospital_cd_b2
                ELSE NULL
                END
            WHEN ''3''
            THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_a3
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_b3
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN mtt.in_hospital_cd_a3
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN mtt.in_hospital_cd_b3
                ELSE NULL
                END
            WHEN ''4''
            THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_a4
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_b4
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN mtt.in_hospital_cd_a4
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN mtt.in_hospital_cd_b4
                ELSE NULL
                END
            END AS e1 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , CASE (SELECT value FROM treatment_func_cd_no)
            WHEN ''1''
            THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_a1, (SELECT value FROM func_treat))
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_b1, (SELECT value FROM func_treat))
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN COALESCE(mtt.in_hospital_cd_a1, (SELECT value FROM func_treat))
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN COALESCE(mtt.in_hospital_cd_b1, (SELECT value FROM func_treat))
                ELSE NULL
                END
            WHEN ''2''
            THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_a2, (SELECT value FROM func_treat))
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_b2, (SELECT value FROM func_treat))
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN COALESCE(mtt.in_hospital_cd_a2, (SELECT value FROM func_treat))
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN COALESCE(mtt.in_hospital_cd_b2, (SELECT value FROM func_treat))
                ELSE NULL
                END
            WHEN ''3''
            THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_a3, (SELECT value FROM func_treat))
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_b3, (SELECT value FROM func_treat))
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN COALESCE(mtt.in_hospital_cd_a3, (SELECT value FROM func_treat))
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN COALESCE(mtt.in_hospital_cd_b3, (SELECT value FROM func_treat))
                ELSE NULL
                END
            WHEN ''4''
            THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_a4, (SELECT value FROM func_treat))
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN COALESCE(mtt.in_hospital_cd_b4, (SELECT value FROM func_treat))
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN COALESCE(mtt.in_hospital_cd_a4, (SELECT value FROM func_treat))
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN COALESCE(mtt.in_hospital_cd_b4, (SELECT value FROM func_treat))
                ELSE NULL
                END
            END AS e03 --機能コード
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''04'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
          LEFT OUTER JOIN mst_treatment AS mtt
            ON mtt.treatment_cd = ord.rst_treatment_cd
        WHERE
          ord.ord_no = @ordNo
          AND ''1'' = @messageType
        UNION ALL
        SELECT
          --ダイアライザ情報
          ''実績詳細'' AS detail_id
          , ''ダイアライザ'' AS sbt_key
          , CASE (SELECT value FROM dialyzer_coop_cd_no)
            WHEN ''1'' THEN mdz.in_hospital_cd_1
            WHEN ''2'' THEN mdz.in_hospital_cd_2
            WHEN ''3'' THEN mdz.in_hospital_cd_3
            WHEN ''4'' THEN mdz.in_hospital_cd_4
            END AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , CASE (SELECT value FROM dialyzer_func_cd_no)
            WHEN ''1'' THEN COALESCE(mdz.in_hospital_cd_1, (SELECT value FROM func_dialyzer))
            WHEN ''2'' THEN COALESCE(mdz.in_hospital_cd_2, (SELECT value FROM func_dialyzer))
            WHEN ''3'' THEN COALESCE(mdz.in_hospital_cd_3, (SELECT value FROM func_dialyzer))
            WHEN ''4'' THEN COALESCE(mdz.in_hospital_cd_4, (SELECT value FROM func_dialyzer))
            END AS e03 --機能コード
          , ''000010000'' AS e04
          , (SELECT value FROM other_dialyzer_unit) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''05'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
          LEFT OUTER JOIN mst_dialyzer AS mdz
            ON mdz.dialyzer_cd = TO_NUMBER( ord.rst_cond_info -> ''5'' ->> ''value'', ''FM999999999999'')
        WHERE
          ord.ord_no = @ordNo
        UNION ALL
        SELECT
          --医材内ダイアライザ情報
          ''実績詳細'' AS detail_id
          , ''ダイアライザ'' AS sbt_key
          , CASE (SELECT value FROM dialyzer_coop_cd_no)
            WHEN ''1'' THEN mdz.in_hospital_cd_1
            WHEN ''2'' THEN mdz.in_hospital_cd_2
            WHEN ''3'' THEN mdz.in_hospital_cd_3
            WHEN ''4'' THEN mdz.in_hospital_cd_4
            END AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , CASE (SELECT value FROM dialyzer_func_cd_no)
            WHEN ''1'' THEN COALESCE(mdz.in_hospital_cd_1, (SELECT value FROM func_dialyzer))
            WHEN ''2'' THEN COALESCE(mdz.in_hospital_cd_2, (SELECT value FROM func_dialyzer))
            WHEN ''3'' THEN COALESCE(mdz.in_hospital_cd_3, (SELECT value FROM func_dialyzer))
            WHEN ''4'' THEN COALESCE(mdz.in_hospital_cd_4, (SELECT value FROM func_dialyzer))
            END AS e03 --機能コード
          , ''000010000'' AS e04
          , (SELECT value FROM other_dialyzer_unit) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''05'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.rst_equip_info ::json) equip
          LEFT OUTER JOIN mst_dialyzer AS mdz
            ON mdz.dialyzer_cd = TO_NUMBER(equip ->> ''cd'', ''FM999999999999'')
        WHERE
          ord.ord_no = @ordNo
          AND equip ->> ''equip_type'' = ''1''
        UNION ALL
        SELECT
          --抗凝固剤
          ''実績詳細'' AS detail_id
          , ''抗凝固剤''
          , CASE (SELECT value FROM medicine_coop_cd_no)
            WHEN ''1'' THEN mmd.in_hospital_cd_1
            WHEN ''2'' THEN mmd.in_hospital_cd_2
            WHEN ''3'' THEN mmd.in_hospital_cd_3
            WHEN ''4'' THEN mmd.in_hospital_cd_4
            END AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , CASE (SELECT value FROM medicine_func_cd_no)
            WHEN ''1'' THEN COALESCE(mmd.in_hospital_cd_1, (SELECT value FROM func_koucoagulant))
            WHEN ''2'' THEN COALESCE(mmd.in_hospital_cd_2, (SELECT value FROM func_koucoagulant))
            WHEN ''3'' THEN COALESCE(mmd.in_hospital_cd_3, (SELECT value FROM func_koucoagulant))
            WHEN ''4'' THEN COALESCE(mmd.in_hospital_cd_4, (SELECT value FROM func_koucoagulant))
            END AS e03 --機能コード
          , koucoagulant.amount AS e04
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''26'', mmd.unit)) AS e05
          , ''000000000'' AS e06
          , (SELECT value ::text FROM other_koucoagulant_speed_unit) AS e07
          , ''06'' AS e08
          , ROW_NUMBER() OVER(
            ORDER BY
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''4'' THEN timing_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''5'' THEN procedure_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''4'' THEN timing_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''5'' THEN procedure_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''4'' THEN timing_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''5'' THEN procedure_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''4'' THEN timing_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''5'' THEN procedure_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''4'' THEN timing_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''5'' THEN procedure_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''4'' THEN timing_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''5'' THEN procedure_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''4'' THEN timing_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''5'' THEN procedure_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''6'' THEN interval_no END, medi_code_order
            ) AS e09
        FROM (
          SELECT
            --抗凝固剤(単独分）
            1 AS temp_no --登録順
            , 1 AS medicine_type --通常→調整
            , 1 AS timing_no --タイミング
            , 1 AS procedure_no --手技
            , 1 AS interval_no --投与間隔
            , info.value ->> ''value'' AS medi_cd
            , TO_CHAR(
              (
                TO_NUMBER(COALESCE(ord.rst_cond_info -> ''26'' ->> ''value'', ''0''), ''FM00000.0000'')
                + TO_NUMBER(COALESCE(ord.rst_cond_info -> ''28'' ->> ''value'', ''0''), ''FM00000.0000'')
              )
            , ''FM00000V9999'') AS amount
          FROM ord_main ord
          CROSS JOIN lateral jsonb_each(ord.rst_cond_info) AS info
          WHERE
            ord.ord_no = @ordNo
            AND info.key IN (''25'')
            AND ord.rst_cond_info -> ''25'' ->> ''medicine_type'' = ''1''
          UNION ALL
          SELECT
            --抗凝固剤(調製分）
            t.idx AS temp_no --登録順
            , 2 AS medicine_type --通常→調整
            , 1 AS timing_no --タイミング
            , 1 AS procedure_no --手技
            , 1 AS interval_no --投与間隔
            , t.mmxd ->> ''cd'' AS medi_cd
            , CASE t.mmxd ->> ''solvent''
                WHEN ''0'' THEN TO_CHAR(
                    (TO_NUMBER(COALESCE(ord.rst_cond_info -> ''26'' ->> ''value'', ''0''), ''FM00000.0000'')
                    + TO_NUMBER(COALESCE(ord.rst_cond_info -> ''28'' ->> ''value'', ''0''), ''FM00000.0000'')
                    ) * TO_NUMBER(COALESCE(t.mmxd ->> ''amount'', ''0''), ''FM00000.0000'')
                    , ''FM00000V9999'')
                WHEN ''1'' THEN TO_CHAR(TO_NUMBER(COALESCE(t.mmxd ->> ''amount'', ''0''), ''FM00000.0000''), ''FM00000V9999'')
                END AS amount
          FROM ord_main ord
          CROSS JOIN lateral jsonb_each(ord.rst_cond_info) AS info
          LEFT OUTER JOIN mst_medicine_mix AS mmx
            ON mmx.medicine_mix_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''FM999999999999'')
          CROSS JOIN LATERAL json_array_elements(mmx.mix_info ::json) WITH ORDINALITY AS t(mmxd, idx)
          WHERE
            ord.ord_no = @ordNo
            AND info.key IN (''25'')
            AND ord.rst_cond_info -> ''25'' ->> ''medicine_type'' = ''2''
        ) AS koucoagulant
        LEFT JOIN mst_medi mmd
          ON koucoagulant.medi_cd = mmd.medicine_cd::text
        UNION ALL
        SELECT
          --薬剤
          ''実績詳細'' AS detail_id
          , kinds
          , CASE (SELECT value FROM medicine_coop_cd_no)
            WHEN ''1'' THEN mmd.in_hospital_cd_1
            WHEN ''2'' THEN mmd.in_hospital_cd_2
            WHEN ''3'' THEN mmd.in_hospital_cd_3
            WHEN ''4'' THEN mmd.in_hospital_cd_4
            END AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , CASE
            WHEN addmed_cd.value IS NULL
            THEN CASE (SELECT value FROM medicine_func_cd_no)
              WHEN ''1'' THEN COALESCE(mmd.in_hospital_cd_1, (SELECT value FROM func_medicine))
              WHEN ''2'' THEN COALESCE(mmd.in_hospital_cd_2, (SELECT value FROM func_medicine))
              WHEN ''3'' THEN COALESCE(mmd.in_hospital_cd_3, (SELECT value FROM func_medicine))
              WHEN ''4'' THEN COALESCE(mmd.in_hospital_cd_4, (SELECT value FROM func_medicine))
              END
            ELSE CASE (SELECT value FROM medicine_func_cd_no) --時間外薬剤
              WHEN ''1'' THEN COALESCE(mmd.in_hospital_cd_1, (SELECT value FROM func_another_add))
              WHEN ''2'' THEN COALESCE(mmd.in_hospital_cd_2, (SELECT value FROM func_another_add))
              WHEN ''3'' THEN COALESCE(mmd.in_hospital_cd_3, (SELECT value FROM func_another_add))
              WHEN ''4'' THEN COALESCE(mmd.in_hospital_cd_4, (SELECT value FROM func_another_add))
              END
            END AS e03 --機能コード
          , CASE (rst_medi.is_auto_calc)
            WHEN ''0'' THEN rst_medi.amount
            WHEN ''1'' THEN
                CASE (SELECT value FROM medicine_coop_cd_no)
                WHEN ''1'' THEN COALESCE(TO_CHAR((SELECT pt.value FROM parsed_table pt WHERE pt.cd =  mmd.in_hospital_cd_1), ''FM00000V9999''), rst_medi.amount)
                WHEN ''2'' THEN COALESCE(TO_CHAR((SELECT pt.value FROM parsed_table pt WHERE pt.cd =  mmd.in_hospital_cd_2), ''FM00000V9999''), rst_medi.amount)
                WHEN ''3'' THEN COALESCE(TO_CHAR((SELECT pt.value FROM parsed_table pt WHERE pt.cd =  mmd.in_hospital_cd_3), ''FM00000V9999''), rst_medi.amount)
                WHEN ''4'' THEN COALESCE(TO_CHAR((SELECT pt.value FROM parsed_table pt WHERE pt.cd =  mmd.in_hospital_cd_4), ''FM00000V9999''), rst_medi.amount)
                END
            END AS e04
          , CASE
            WHEN addmed_cd.value IS NULL
            THEN (SELECT value FROM coop_ini_info WHERE key2 = concat(''27'', mmd.unit))
            ELSE (SELECT value FROM coop_ini_info WHERE key2 = concat(''30'', mmd.unit)) --時間外薬剤
            END AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , CASE
            WHEN addmed_cd.value IS NULL
            THEN ''07''
            ELSE ''11'' --時間外薬剤
            END AS e08
          , ROW_NUMBER() OVER(
            ORDER BY
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''6'' THEN interval_no END, medi_code_order
            ) AS e09
        FROM (
          SELECT
            --透析液
            1 AS temp_no --登録順
            , 1 AS medicine_type --通常→調整
            , NULL ::integer AS timing_cd --タイミング
            , NULL ::integer AS procedure_cd --手技
            , 999 AS interval_no --投与間隔
            , ''透析液'' AS kinds
            , info.value ->> ''value'' AS medi_cd
            , TO_CHAR(
                TO_NUMBER(COALESCE(ord.rst_cond_info -> ''17'' ->> ''value'', ''0''), ''FM00000.0000'')
            , ''FM00000V9999'') AS amount
            , (SELECT value FROM num_auto_calc WHERE key2 = ''AUTO_CALC_FLG'') AS is_auto_calc --自動計算フラグ
          FROM ord_main ord
          CROSS JOIN lateral jsonb_each(ord.rst_cond_info) AS info
          WHERE
            ord.ord_no = @ordNo
            AND info.key IN (''15'')
            AND ord.rst_cond_info -> ''15'' ->> ''medicine_type'' = ''1''
          UNION ALL
          SELECT
            --補液
            2 AS temp_no --登録順
            , 1 AS medicine_type --通常→調整
            , NULL ::integer AS timing_cd --タイミング
            , NULL ::integer AS procedure_cd --手技
            , 999 AS interval_no --投与間隔
            , ''補液'' AS kinds
            , info.value ->> ''value'' AS medi_cd
            , TO_CHAR(
                TO_NUMBER(COALESCE(ord.rst_cond_info -> ''22'' ->> ''value'', ''0''), ''FM00000.0000'')
            , ''FM00000V9999'') AS amount
            , ''0'' AS is_auto_calc --自動計算フラグ
          FROM ord_main ord
          CROSS JOIN lateral jsonb_each(ord.rst_cond_info) AS info
          WHERE
            ord.ord_no = @ordNo
            AND info.key IN (''19'')
            AND ord.rst_cond_info -> ''19'' ->> ''medicine_type'' = ''1''
          UNION ALL
          SELECT
            --投与薬剤情報(通常)
            100 + t.idx AS temp_no --登録順
            , 1 AS medicine_type --通常→調整
            , (t.medi ->> ''timing_cd'') ::int AS timing_cd --タイミング
            , (t.medi ->> ''procedure_cd'') ::int AS procedure_cd --手技
            , (t.medi ->> ''date_interval'') ::int AS interval_no --投与間隔
            , ''投与薬剤情報(通常)'' AS kinds
            , t.medi ->> ''cd'' AS medi_cd
            , TO_CHAR(
                TO_NUMBER(COALESCE(t.medi ->> ''amount'', ''0''), ''FM00000.0000'')
            , ''FM00000V9999'') AS amount
            , ''0'' AS is_auto_calc --自動計算フラグ
          FROM ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) WITH ORDINALITY AS t(medi, idx)
          WHERE
            ord.ord_no = @ordNo
            AND t.medi ->> ''medicine_type'' = ''1''
            AND t.medi ->> ''effect_flg'' = ''1''
          UNION ALL
          SELECT
            --投与薬剤情報(調整)
            100 + t.idx AS temp_no --登録順
            , 2 AS medicine_type --通常→調整
            , (t.medi ->> ''timing_cd'') ::int AS timing_cd --タイミング
            , (t.medi ->> ''procedure_cd'') ::int AS procedure_cd --手技
            , (t.medi ->> ''date_interval'') ::int AS interval_no --投与間隔
            , ''投与薬剤情報(調整)'' AS kinds
            , t2.mmxd ->> ''cd'' AS medi_cd
            , CASE t2.mmxd ->> ''solvent''
                WHEN ''0'' THEN TO_CHAR(
                    TO_NUMBER(COALESCE(t.medi ->> ''amount'', ''0''), ''FM00000.0000'')
                    * TO_NUMBER(COALESCE(t2.mmxd ->> ''amount'', ''0''), ''FM00000.0000'')
                    , ''FM00000V9999'')
                WHEN ''1'' THEN TO_CHAR(TO_NUMBER(COALESCE(t2.mmxd ->> ''amount'', ''0''), ''FM00000.0000''), ''FM00000V9999'')
                END AS amount
            , ''0'' AS is_auto_calc --自動計算フラグ
          FROM ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) WITH ORDINALITY AS t(medi, idx)
          LEFT OUTER JOIN mst_medicine_mix AS mmx
            ON mmx.medicine_mix_cd = TO_NUMBER(t.medi ->> ''cd'', ''FM999999999999'')
          CROSS JOIN LATERAL json_array_elements(mmx.mix_info ::json) WITH ORDINALITY AS t2(mmxd, idx)
          WHERE
            ord.ord_no = @ordNo
            AND t.medi ->> ''medicine_type'' = ''2''
            AND t.medi ->> ''effect_flg'' = ''1''
          UNION ALL
          SELECT
            --処置薬剤情報(通常)
            200 + t.idx AS temp_no --登録順
            , 1 AS medicine_type --通常→調整
            , NULL ::integer AS timing_cd --タイミング
            , (t.tmedi ->> ''procedure_cd'') ::int AS procedure_cd --手技
            , NULL ::integer AS interval_no --投与間隔
            , ''処置薬剤情報(通常)'' AS kinds
            , t.tmedi ->> ''treat_medicine_cd'' AS medi_cd
            , TO_CHAR(
                TO_NUMBER(COALESCE(t.tmedi ->> ''amount'', ''0''), ''FM00000.0000'')
            , ''FM00000V9999'') AS amount
            , ''0'' AS is_auto_calc --自動計算フラグ
          FROM ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) WITH ORDINALITY AS t(tmedi, idx)
          WHERE
            ord.ord_no = @ordNo
            AND t.tmedi ->> ''treat_class'' IN (''1'',''2'')
            AND t.tmedi ->> ''medicine_type'' = ''1''
          UNION ALL
          SELECT
            --処置薬剤情報(調整)
            200 + t.idx AS temp_no --登録順
            , 2 AS medicine_type --通常→調整
            , NULL ::integer AS timing_cd --タイミング
            , (t.tmedi ->> ''procedure_cd'') ::int AS procedure_cd --手技
            , NULL ::integer AS interval_no --投与間隔
            , ''処置薬剤情報(調整)'' AS kinds
            , t2.mmxd ->> ''cd'' AS medi_cd
            , CASE t2.mmxd ->> ''solvent''
                WHEN ''0'' THEN TO_CHAR(
                    TO_NUMBER(COALESCE(t.tmedi ->> ''amount'', ''0''), ''FM00000.0000'')
                    * TO_NUMBER(COALESCE(t2.mmxd ->> ''amount'', ''0''), ''FM00000.0000'')
                    , ''FM00000V9999'')
                WHEN ''1'' THEN TO_CHAR(TO_NUMBER(COALESCE(t2.mmxd ->> ''amount'', ''0''), ''FM00000.0000''), ''FM00000V9999'')
                END AS amount
            , ''0'' AS is_auto_calc --自動計算フラグ
          FROM ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) WITH ORDINALITY AS t(tmedi, idx)
          LEFT OUTER JOIN mst_medicine_mix AS mmx
            ON mmx.medicine_mix_cd = TO_NUMBER(t.tmedi ->> ''treat_medicine_cd'', ''FM999999999999'')
          CROSS JOIN LATERAL json_array_elements(mmx.mix_info ::json) WITH ORDINALITY AS t2(mmxd, idx)
          WHERE
            ord.ord_no = @ordNo
            AND t.tmedi ->> ''treat_class'' IN (''0'',''2'')
            AND t.tmedi ->> ''medicine_type'' = ''2''
        ) AS rst_medi
        LEFT JOIN mst_medi mmd ON rst_medi.medi_cd = mmd.medicine_cd::text
        LEFT OUTER JOIN addmed_cd
          ON (CASE (SELECT value FROM medicine_coop_cd_no)
            WHEN ''1'' then mmd.in_hospital_cd_1 = addmed_cd.value
            WHEN ''2'' then mmd.in_hospital_cd_2 = addmed_cd.value
            WHEN ''3'' then mmd.in_hospital_cd_3 = addmed_cd.value
            WHEN ''4'' then mmd.in_hospital_cd_4 = addmed_cd.value
            END)
        LEFT JOIN timing_order ON rst_medi.timing_cd = timing_order.timing_code
        LEFT JOIN procedure_order ON rst_medi.procedure_cd = procedure_order.procedure_code
        WHERE
          (CASE (SELECT value FROM medicine_func_cd_no)
            WHEN ''1'' THEN coalesce(mmd.in_hospital_cd_1, ''null'') NOT IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
            WHEN ''2'' THEN coalesce(mmd.in_hospital_cd_2, ''null'') NOT IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
            WHEN ''3'' THEN coalesce(mmd.in_hospital_cd_3, ''null'') NOT IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
            WHEN ''4'' THEN coalesce(mmd.in_hospital_cd_4, ''null'') NOT IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
            END)
        UNION ALL
        SELECT
          --酸素吸入情報
          ''実績詳細'' AS detail_id
          , ''酸素吸入''
          , (SELECT value FROM oxygen_code) AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , (SELECT value FROM func_medicine)  AS e03 --機能コード
          , TO_CHAR(TO_NUMBER(tmedi ->> ''oxygen_amount'', ''FM99999.9999''), ''FM00000V9999'') AS e04
          , (SELECT value FROM oxygen_used_unit) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''07'' AS e08
          , 999 AS e09
        FROM
          ord_main AS ord
          CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) tmedi
        WHERE
          ord.ord_no = @ordNo
          AND tmedi ->> ''treat_class'' = ''3''
          AND tmedi ->> ''oxygen_amount'' IS NOT NULL
        UNION ALL
        SELECT
          --穿刺針情報
          ''実績詳細'' AS detail_id
          , ''穿刺針''
          , CASE (SELECT value FROM equipment_coop_cd_no)
            WHEN ''1'' THEN meq.in_hospital_cd_1
            WHEN ''2'' THEN meq.in_hospital_cd_2
            WHEN ''3'' THEN meq.in_hospital_cd_3
            WHEN ''4'' THEN meq.in_hospital_cd_4
            END AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , CASE (SELECT value FROM equipment_func_cd_no)
            WHEN ''1'' THEN COALESCE(meq.in_hospital_cd_1, (SELECT value FROM func_aneedle))
            WHEN ''2'' THEN COALESCE(meq.in_hospital_cd_2, (SELECT value FROM func_aneedle))
            WHEN ''3'' THEN COALESCE(meq.in_hospital_cd_3, (SELECT value FROM func_aneedle))
            WHEN ''4'' THEN COALESCE(meq.in_hospital_cd_4, (SELECT value FROM func_aneedle))
            END AS e03 --機能コード
          , TO_CHAR(TO_NUMBER(punc_needle.amount, ''FM00000.0000''), ''FM00000V9999'') AS e04
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''28'', meq.unit)) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''08'' AS e08
          , ROW_NUMBER() OVER(
            ORDER BY
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 0 THEN temp_no
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 1 THEN meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 2 THEN meq_code_order END,
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 0 THEN temp_no
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 1 THEN meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 2 THEN meq_code_order END,
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 0 THEN temp_no
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 1 THEN meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 2 THEN meq_code_order END, meq_code_order
            ) AS e09
          FROM (
            SELECT
              --透析条件A針V針SN針
              CASE
                  WHEN info.key = ''9'' THEN 1
                  WHEN info.key = ''10'' THEN 2
                  WHEN info.key = ''11'' THEN 3
                  END AS temp_no
              , info.value ->> ''value'' AS eq_cd
              , ''1'' AS amount
            FROM ord_main ord
            CROSS JOIN LATERAL jsonb_each(ord.rst_cond_info) AS info
            WHERE
              ord.ord_no = @ordNo
              AND info.key IN (''9'',''10'',''11'')
            UNION ALL
            SELECT
              --医材内穿刺針
              4 + t.idx AS temp_no
              , t.equip ->> ''cd'' AS eq_cd
              , t.equip ->> ''amount'' AS amount
            FROM ord_main ord
            CROSS JOIN LATERAL json_array_elements(ord.rst_equip_info ::json) WITH ORDINALITY AS t(equip, idx)
            WHERE
              ord.ord_no = @ordNo
              AND t.equip ->> ''class_type'' IN (''2'', ''3'')
          ) AS punc_needle
          LEFT JOIN mst_equip meq
          ON punc_needle.eq_cd = meq.equipment_cd::text
        UNION ALL
        SELECT
          --医材情報
          ''実績詳細'' AS detail_id
          , ''医材''
          , CASE (SELECT value FROM equipment_coop_cd_no)
            WHEN ''1'' THEN meq.in_hospital_cd_1
            WHEN ''2'' THEN meq.in_hospital_cd_2
            WHEN ''3'' THEN meq.in_hospital_cd_3
            WHEN ''4'' THEN meq.in_hospital_cd_4
            END AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , CASE (SELECT value FROM equipment_func_cd_no)
            WHEN ''1'' THEN COALESCE(meq.in_hospital_cd_1, (SELECT value FROM func_consumption))
            WHEN ''2'' THEN COALESCE(meq.in_hospital_cd_2, (SELECT value FROM func_consumption))
            WHEN ''3'' THEN COALESCE(meq.in_hospital_cd_3, (SELECT value FROM func_consumption))
            WHEN ''4'' THEN COALESCE(meq.in_hospital_cd_4, (SELECT value FROM func_consumption))
            END AS e03 --機能コード
          , CASE
            WHEN rst_equip.class_type = ''4'' THEN ''000010000'' --吸着カラム使用量1固定
            ELSE TO_CHAR(TO_NUMBER(rst_equip.amount, ''FM99999.9999''), ''FM00000V9999'') 
            END AS e04
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''29'', meq.unit)) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''09'' AS e08
          , ROW_NUMBER() OVER(
            ORDER BY
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 0 THEN temp_no
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 1 THEN meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 2 THEN meq_code_order END,
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 0 THEN temp_no
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 1 THEN meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 2 THEN meq_code_order END,
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 0 THEN temp_no
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 1 THEN meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 2 THEN meq_code_order END, meq_code_order
            ) AS e09
          FROM (
            SELECT
              t.idx AS temp_no
              , t.equip ->> ''cd'' AS eq_cd
              , t.equip ->> ''amount'' AS amount
              , t.equip ->> ''class_type'' AS class_type
            FROM ord_main ord
            CROSS JOIN LATERAL json_array_elements(ord.rst_equip_info ::json) WITH ORDINALITY AS t(equip, idx)
            WHERE
              ord.ord_no = @ordNo
              AND t.equip ->> ''equip_type'' = ''0''
              AND t.equip ->> ''class_type'' NOT IN (''2'', ''3'')
          ) AS rst_equip
          LEFT JOIN mst_equip meq
          ON rst_equip.eq_cd = meq.equipment_cd::text
        UNION ALL
        SELECT
          --1次膜2次膜情報
          ''実績詳細'' AS detail_id
          , ''1次膜2次膜''
          , CASE (SELECT value FROM equipment_coop_cd_no)
            WHEN ''1'' THEN meq.in_hospital_cd_1
            WHEN ''2'' THEN meq.in_hospital_cd_2
            WHEN ''3'' THEN meq.in_hospital_cd_3
            WHEN ''4'' THEN meq.in_hospital_cd_4
            END AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , CASE (SELECT value FROM equipment_func_cd_no)
            WHEN ''1'' THEN COALESCE(meq.in_hospital_cd_1, (SELECT value FROM func_consumption))
            WHEN ''2'' THEN COALESCE(meq.in_hospital_cd_2, (SELECT value FROM func_consumption))
            WHEN ''3'' THEN COALESCE(meq.in_hospital_cd_3, (SELECT value FROM func_consumption))
            WHEN ''4'' THEN COALESCE(meq.in_hospital_cd_4, (SELECT value FROM func_consumption))
            END AS e03 --機能コード
          , ''000010000'' AS e04
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''29'', meq.unit)) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''10'' AS e08
          , ROW_NUMBER() OVER(
            ORDER BY
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 0 THEN rst_equip.temp_no
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 1 THEN meq.meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 1) = 2 THEN meq.meq_code_order END,
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 0 THEN rst_equip.temp_no
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 1 THEN meq.meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 2) = 2 THEN meq.meq_code_order END,
            CASE WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 0 THEN rst_equip.temp_no
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 1 THEN meq.meq_class_code_order
                WHEN (SELECT ora FROM equip_order_data WHERE no2 = 3) = 2 THEN meq.meq_code_order END, meq.meq_code_order
            ) AS e09
          FROM (
            SELECT
              CASE
                WHEN info.key = ''7'' THEN 1
                WHEN info.key = ''8'' THEN 2
                END AS temp_no
              ,info.value ->> ''value'' AS eq_cd
            FROM ord_main ord
            CROSS JOIN lateral jsonb_each(ord.rst_cond_info) AS info
            WHERE
              ord.ord_no = @ordNo
              AND info.key IN (''7'',''8'')
          ) AS rst_equip
          LEFT JOIN mst_equip meq
          ON rst_equip.eq_cd = meq.equipment_cd::text
        UNION ALL
        SELECT
          --加算(その他)その2Ver1
          ''実績詳細'' AS detail_id
          , ''加算(その他)その2'' AS sbt_key
          , pcd.item_code AS e01 --項目コード
          , pcd.item_generation AS e02 --項目世代番号
          , (SELECT value FROM func_another_add) AS e03 --機能コード
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''12'' AS e08
          , pcd.idx ::int AS e09
        FROM
          pcd_save_3 pcd
        WHERE
          pcd.function_code = ''30''
          AND pcd.item_code IS NOT NULL
          AND ''1'' = @messageType
        UNION ALL
        SELECT
          --加算(患者)Ver2、加算(その他)その2Ver2、項目コメントVer2、透析コメント1~3Ver2
          ''実績詳細'' AS detail_id
          , kinds
          , CASE (SELECT value FROM medicine_coop_cd_no)
            WHEN ''1'' THEN mmd.in_hospital_cd_1
            WHEN ''2'' THEN mmd.in_hospital_cd_2
            WHEN ''3'' THEN mmd.in_hospital_cd_3
            WHEN ''4'' THEN mmd.in_hospital_cd_4
            END AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , CASE (SELECT value FROM medicine_func_cd_no)
            WHEN ''1'' THEN COALESCE(mmd.in_hospital_cd_1, (SELECT value FROM func_medicine))
            WHEN ''2'' THEN COALESCE(mmd.in_hospital_cd_2, (SELECT value FROM func_medicine))
            WHEN ''3'' THEN COALESCE(mmd.in_hospital_cd_3, (SELECT value FROM func_medicine))
            WHEN ''4'' THEN COALESCE(mmd.in_hospital_cd_4, (SELECT value FROM func_medicine))
            END AS e03 --機能コード
          , rst_medi.amount AS e04
          , (SELECT value FROM coop_ini_info WHERE key2 = concat(''27'', mmd.unit)) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , (CASE (SELECT value FROM medicine_func_cd_no)
            WHEN ''1'' THEN
              CASE mmd.in_hospital_cd_1
              WHEN (SELECT value FROM func_addition) THEN ''01''
              WHEN (SELECT value FROM func_another_add) THEN ''12''
              WHEN (SELECT value FROM func_item_comment) THEN ''17''
              WHEN (SELECT value FROM func_dialysis_comment) THEN ''18''
              WHEN (SELECT value FROM func_dialysis_comment2) THEN ''19''
              WHEN (SELECT value FROM func_dialysis_comment3) THEN ''20''
              END
            WHEN ''2'' THEN
              CASE mmd.in_hospital_cd_2
              WHEN (SELECT value FROM func_addition) THEN ''01''
              WHEN (SELECT value FROM func_another_add) THEN ''12''
              WHEN (SELECT value FROM func_item_comment) THEN ''17''
              WHEN (SELECT value FROM func_dialysis_comment) THEN ''18''
              WHEN (SELECT value FROM func_dialysis_comment2) THEN ''19''
              WHEN (SELECT value FROM func_dialysis_comment3) THEN ''20''
              END
            WHEN ''3'' THEN
              CASE mmd.in_hospital_cd_3
              WHEN (SELECT value FROM func_addition) THEN ''01''
              WHEN (SELECT value FROM func_another_add) THEN ''12''
              WHEN (SELECT value FROM func_item_comment) THEN ''17''
              WHEN (SELECT value FROM func_dialysis_comment) THEN ''18''
              WHEN (SELECT value FROM func_dialysis_comment2) THEN ''19''
              WHEN (SELECT value FROM func_dialysis_comment3) THEN ''20''
              END
            WHEN ''4'' THEN
              CASE mmd.in_hospital_cd_4
              WHEN (SELECT value FROM func_addition) THEN ''01''
              WHEN (SELECT value FROM func_another_add) THEN ''12''
              WHEN (SELECT value FROM func_item_comment) THEN ''17''
              WHEN (SELECT value FROM func_dialysis_comment) THEN ''18''
              WHEN (SELECT value FROM func_dialysis_comment2) THEN ''19''
              WHEN (SELECT value FROM func_dialysis_comment3) THEN ''20''
              END
            END) AS e08
          , ROW_NUMBER() OVER(
            ORDER BY
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 1) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 2) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 3) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 4) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 5) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 6) = ''6'' THEN interval_no END,
            CASE WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''0'' THEN temp_no
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''1'' THEN medi_class_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''2'' THEN medicine_type
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''3'' THEN medi_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''4'' THEN timing_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''5'' THEN procedure_code_order
                WHEN (SELECT a1 FROM medi_order_data WHERE no2 = 7) = ''6'' THEN interval_no END, medi_code_order
            ) AS e09
        FROM (
          SELECT
            --投与薬剤情報(通常)
            100 + t.idx AS temp_no --登録順
            , 1 AS medicine_type --通常→調整
            , (t.medi ->> ''timing_cd'') ::int AS timing_cd --タイミング
            , (t.medi ->> ''procedure_cd'') ::int AS procedure_cd --手技
            , (t.medi ->> ''date_interval'') ::int AS interval_no --投与間隔
            , ''加算投与薬剤情報(通常)'' AS kinds
            , t.medi ->> ''cd'' AS medi_cd
            , TO_CHAR(
                TO_NUMBER(COALESCE(t.medi ->> ''amount'', ''0''), ''FM00000.0000'')
            , ''FM00000V9999'') AS amount
            , ''0'' AS is_auto_calc --自動計算フラグ
          FROM ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) WITH ORDINALITY AS t(medi, idx)
          WHERE
            ord.ord_no = @ordNo
            AND ''2'' = @messageType
            AND t.medi ->> ''medicine_type'' = ''1''
            AND t.medi ->> ''effect_flg'' = ''1''
          UNION ALL
          SELECT
            --投与薬剤情報(調整)
            100 + t.idx AS temp_no --登録順
            , 2 AS medicine_type --通常→調整
            , (t.medi ->> ''timing_cd'') ::int AS timing_cd --タイミング
            , (t.medi ->> ''procedure_cd'') ::int AS procedure_cd --手技
            , (t.medi ->> ''date_interval'') ::int AS interval_no --投与間隔
            , ''加算投与薬剤情報(調整)'' AS kinds
            , t2.mmxd ->> ''cd'' AS medi_cd
            , CASE t2.mmxd ->> ''solvent''
                WHEN ''0'' THEN TO_CHAR(
                    TO_NUMBER(COALESCE(t.medi ->> ''amount'', ''0''), ''FM00000.0000'')
                    * TO_NUMBER(COALESCE(t2.mmxd ->> ''amount'', ''0''), ''FM00000.0000'')
                    , ''FM00000V9999'')
                WHEN ''1'' THEN TO_CHAR(TO_NUMBER(COALESCE(t2.mmxd ->> ''amount'', ''0''), ''FM00000.0000''), ''FM00000V9999'')
                END AS amount
            , ''0'' AS is_auto_calc --自動計算フラグ
          FROM ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) WITH ORDINALITY AS t(medi, idx)
          LEFT OUTER JOIN mst_medicine_mix AS mmx
            ON mmx.medicine_mix_cd = TO_NUMBER(t.medi ->> ''cd'', ''FM999999999999'')
          CROSS JOIN LATERAL json_array_elements(mmx.mix_info ::json) WITH ORDINALITY AS t2(mmxd, idx)
          WHERE
            ord.ord_no = @ordNo
            AND ''2'' = @messageType
            AND t.medi ->> ''medicine_type'' = ''2''
            AND t.medi ->> ''effect_flg'' = ''1''
          UNION ALL
          SELECT
            --処置薬剤情報(通常)
            200 + t.idx AS temp_no --登録順
            , 1 AS medicine_type --通常→調整
            , NULL ::integer AS timing_cd --タイミング
            , (t.tmedi ->> ''procedure_cd'') ::int AS procedure_cd --手技
            , NULL ::integer AS interval_no --投与間隔
            , ''加算処置薬剤情報(通常)'' AS kinds
            , t.tmedi ->> ''treat_medicine_cd'' AS medi_cd
            , TO_CHAR(
                TO_NUMBER(COALESCE(t.tmedi ->> ''amount'', ''0''), ''FM00000.0000'')
            , ''FM00000V9999'') AS amount
            , ''0'' AS is_auto_calc --自動計算フラグ
          FROM ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) WITH ORDINALITY AS t(tmedi, idx)
          WHERE
            ord.ord_no = @ordNo
            AND ''2'' = @messageType
            AND t.tmedi ->> ''treat_class'' IN (''1'',''2'')
            AND t.tmedi ->> ''medicine_type'' = ''1''
          UNION ALL
          SELECT
            --処置薬剤情報(調整)
            200 + t.idx AS temp_no --登録順
            , 2 AS medicine_type --通常→調整
            , NULL ::integer AS timing_cd --タイミング
            , (t.tmedi ->> ''procedure_cd'') ::int AS procedure_cd --手技
            , NULL ::integer AS interval_no --投与間隔
            , ''加算処置薬剤情報(調整)'' AS kinds
            , t2.mmxd ->> ''cd'' AS medi_cd
            , CASE t2.mmxd ->> ''solvent''
                WHEN ''0'' THEN TO_CHAR(
                    TO_NUMBER(COALESCE(t.tmedi ->> ''amount'', ''0''), ''FM00000.0000'')
                    * TO_NUMBER(COALESCE(t2.mmxd ->> ''amount'', ''0''), ''FM00000.0000'')
                    , ''FM00000V9999'')
                WHEN ''1'' THEN TO_CHAR(TO_NUMBER(COALESCE(t2.mmxd ->> ''amount'', ''0''), ''FM00000.0000''), ''FM00000V9999'')
                END AS amount
            , ''0'' AS is_auto_calc --自動計算フラグ
          FROM ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) WITH ORDINALITY AS t(tmedi, idx)
          LEFT OUTER JOIN mst_medicine_mix AS mmx
            ON mmx.medicine_mix_cd = TO_NUMBER(t.tmedi ->> ''treat_medicine_cd'', ''FM999999999999'')
          CROSS JOIN LATERAL json_array_elements(mmx.mix_info ::json) WITH ORDINALITY AS t2(mmxd, idx)
          WHERE
            ord.ord_no = @ordNo
            AND ''2'' = @messageType
            AND t.tmedi ->> ''treat_class'' IN (''0'',''2'')
            AND t.tmedi ->> ''medicine_type'' = ''2''
        ) AS rst_medi
        LEFT JOIN mst_medi mmd ON rst_medi.medi_cd = mmd.medicine_cd::text
        LEFT JOIN timing_order ON rst_medi.timing_cd = timing_order.timing_code
        LEFT JOIN procedure_order ON rst_medi.procedure_cd = procedure_order.procedure_code
        WHERE
          (CASE (SELECT value FROM medicine_func_cd_no)
          WHEN ''1'' THEN mmd.in_hospital_cd_1 IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
          WHEN ''2'' THEN mmd.in_hospital_cd_2 IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
          WHEN ''3'' THEN mmd.in_hospital_cd_3 IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
          WHEN ''4'' THEN mmd.in_hospital_cd_4 IN ((SELECT value FROM func_addition),(SELECT value FROM func_another_add),(SELECT value FROM func_item_comment),(SELECT value FROM func_dialysis_comment),(SELECT value FROM func_dialysis_comment2),(SELECT value FROM func_dialysis_comment3))
          END)
        UNION ALL 
        SELECT
          --加算(透析困難)
          ''実績詳細'' AS detail_id
          , ''加算'' AS sbt_key
          , CASE (SELECT value FROM difficult_coop_cd_no)
            WHEN ''1'' THEN mdd.in_hospital_cd_1
            WHEN ''2'' THEN mdd.in_hospital_cd_2
            END AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , CASE (SELECT value FROM difficult_func_cd_no)
            WHEN ''1'' THEN COALESCE(mdd.in_hospital_cd_1, (SELECT value FROM func_another_add))
            WHEN ''2'' THEN COALESCE(mdd.in_hospital_cd_2, (SELECT value FROM func_another_add))
            END AS e03 --機能コード
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''13'' AS e08
          , NULL ::int AS e09
        FROM
          mst_dialysis_difficulty mdd
        WHERE
          ''2'' = @messageType
          AND mdd.dialysis_difficulty_cd IN (SELECT regexp_split_to_table(@mstCddd, '','')::INT)
          AND mdd.is_del = ''0''
        UNION ALL
        SELECT
          --加算(レセプトメモ)
          ''実績詳細'' AS detail_id
          , ''加算'' AS sbt_key
          , CASE (SELECT value FROM addition_coop_cd_no)
            WHEN ''1'' THEN mad.in_hospital_cd_1
            WHEN ''2'' THEN mad.in_hospital_cd_2
            WHEN ''3'' THEN mad.in_hospital_cd_3
            END AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , CASE (SELECT value FROM addition_func_cd_no)
            WHEN ''1'' THEN COALESCE(mad.in_hospital_cd_1, (SELECT value FROM func_another_add))
            WHEN ''2'' THEN COALESCE(mad.in_hospital_cd_2, (SELECT value FROM func_another_add))
            WHEN ''3'' THEN COALESCE(mad.in_hospital_cd_3, (SELECT value FROM func_another_add))
            END AS e03 --機能コード
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''14'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
          CROSS JOIN LATERAL json_array_elements(ord.addition_info ::json) addi
          LEFT OUTER JOIN mst_addition AS mad
            ON mad.addition_cd = TO_NUMBER(addi ->> ''cd'', ''FM9999999999'')
        WHERE
          ''2'' = @messageType
          AND ord.ord_no = @ordNo
        UNION ALL
        SELECT
          --透析所要時間情報
          ''実績詳細'' AS detail_id
          , ''所要時間'' AS sbt_key
          , (SELECT value FROM other_dialysis_time) AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , (SELECT value FROM func_other_item) AS e03 --機能コード
          , TO_CHAR((FLOOR(EXTRACT(epoch FROM (date_trunc(''minute'', ord.rst_end_date) - date_trunc(''minute'', ord.rst_start_date))) / 60)), ''FM00000V9999'') AS e04
          , (SELECT value FROM other_dialysis_unit) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''15'' AS e08
          , NULL ::int AS e09
        FROM
          ord_main ord
        WHERE
          ord.ord_no = @ordNo
        UNION ALL
        SELECT
          --透析除水量情報
          ''実績詳細'' AS detail_id
          , ''除水量'' AS sbt_key
          , (SELECT value FROM other_off_water) AS e01 --項目コード
          , (SELECT value FROM sendmsg_gen) AS e02 --項目世代番号
          , (SELECT value FROM func_other_item) AS e03 --機能コード
          , TO_CHAR(TO_NUMBER(rst_weight_info ->> ''water_removal_rst'', ''FM99999.9999''), ''FM00000V9999'') AS e04
          , (SELECT value FROM other_off_water_unit) AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''16'' AS e08
          , NULL ::int AS e09
        FROM ord_main ord
        WHERE ord.ord_no = @ordNo
        UNION ALL
        SELECT
          --項目コメントVer1
          ''実績詳細'' AS detail_id
          , ''項目コメント'' AS sbt_key
          , pcd.item_code AS e01 --項目コード
          , pcd.item_generation AS e02 --項目世代番号
          , (SELECT value FROM func_item_comment) AS e03 --機能コード
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''17'' AS e08
          , pcd.idx ::int AS e09
        FROM
          pcd_save_3 pcd
        WHERE
          pcd.function_code = ''32''
          AND pcd.item_code IS NOT NULL
          AND ''1'' = @messageType
        UNION ALL
        SELECT
          --透析コメント1Ver1
          ''実績詳細'' AS detail_id
          , ''透析コメント1'' AS sbt_key
          , pcd.item_code AS e01 --項目コード
          , pcd.item_generation AS e02 --項目世代番号
          , (SELECT value FROM func_dialysis_comment) AS e03 --機能コード
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''18'' AS e08
          , pcd.idx ::int AS e09
        FROM
          pcd_save_3 pcd
        WHERE
          pcd.function_code = ''3A''
          AND pcd.item_code IS NOT NULL
          AND ''1'' = @messageType
        UNION ALL
        SELECT
          --透析コメント2Ver1
          ''実績詳細'' AS detail_id
          , ''透析コメント2'' AS sbt_key
          , pcd.item_code AS e01 --項目コード
          , pcd.item_generation AS e02 --項目世代番号
          , (SELECT value FROM func_dialysis_comment2) AS e03 --機能コード
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''19'' AS e08
          , pcd.idx ::int AS e09
        FROM
          pcd_save_3 pcd
        WHERE
          pcd.function_code = ''3B''
          AND pcd.item_code IS NOT NULL
          AND ''1'' = @messageType
        UNION ALL
        SELECT
          --透析コメント3Ver1
          ''実績詳細'' AS detail_id
          , ''透析コメント3'' AS sbt_key
          , pcd.item_code AS e01 --項目コード
          , pcd.item_generation AS e02 --項目世代番号
          , (SELECT value FROM func_dialysis_comment3) AS e03 --機能コード
          , ''000000000'' AS e04
          , ''  '' AS e05
          , ''000000000'' AS e06
          , ''  '' AS e07
          , ''20'' AS e08
          , pcd.idx ::int AS e09
        FROM
          pcd_save_3 pcd
        WHERE
          pcd.function_code = ''3C''
          AND pcd.item_code IS NOT NULL
          AND ''1'' = @messageType
      ) all_cost
    WHERE
      all_cost.e01 IS NOT NULL
    ORDER BY
      all_cost.e08
      , CAST(all_cost.e09 as integer)
      , all_cost.e01
  ) cost_fin
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'NEC)実績繰り返し部１', '2020-05-18 18:12:46.000', CURRENT_TIMESTAMP, '[{"sql_cd": -206, "field_name": "pat_dial_diff_cd", "replace_var": "@mstCddd"}]'::jsonb);


INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-65, 'WITH staff_cd_info AS(
  --指示者
  --条件指示
  SELECT
    1 AS order_no
    , COALESCE(info ->> ''ind_user_id'', '''') AS staff_cd 
  FROM
    (SELECT
      ord.rst_cond_info -> jsonb_object_keys(ord.rst_cond_info) AS info 
    FROM
      ord_main AS ord 
    WHERE
      ord.ord_no = @ordNo AND 
      ord.facility_cd = @facilityCd AND 
      ord.is_del = ''0'' 
    LIMIT 1 ) AS T
  UNION 
  --投薬指示
  SELECT
    2 AS order_no
    , COALESCE(info ->> ''ind_user_id'', '''') AS staff_cd 
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) info 
  WHERE
    ord.ord_no = @ordNo AND 
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0'' 
  UNION 
  --医材指示
  SELECT
    3 AS order_no
    , COALESCE(info ->> ''ind_user_id'', '''') AS staff_cd
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_equip_info ::json) info 
  WHERE
    ord.ord_no = @ordNo AND 
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0'' 
  UNION 
  --指示簿指示
  SELECT
    4 AS order_no
    , COALESCE(info ->> ''ind_user_id'', '''') AS staff_cd
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_ind_comment_info ::json) info 
  WHERE
    ord.ord_no = @ordNo AND 
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0'' 
  ORDER BY order_no ASC LIMIT 1 
)
, rst_vital_info_before AS(
  --前血圧
  SELECT
    mni_m.monitor_data ->> ''90'' AS bp_max, 
    mni_m.monitor_data ->> ''91'' AS bp_min, 
    mni_m.monitor_data ->> ''92'' AS bp_ave, 
    mni_m.monitor_data ->> ''93'' AS pulse, 
    mni_m.occur_date AS occur_date
  FROM 
    ord_main ord
  INNER JOIN
    mni_monitor as mni_m
  ON
    ord.ord_no = mni_m.ord_no
  WHERE 
    ord.ord_no = @ordNo AND
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0'' AND
    mni_m.data_type = 5 
)
, rst_vital_info_after AS(
  --後血圧
  SELECT
    mni_m.monitor_data ->> ''90'' AS bp_max, 
    mni_m.monitor_data ->> ''91'' AS bp_min, 
    mni_m.monitor_data ->> ''92'' AS bp_ave, 
    mni_m.monitor_data ->> ''93'' AS pulse, 
    mni_m.occur_date AS occur_date,
    mni_m.monitor_data ->> ''94'' AS temperature 
  FROM 
    ord_main ord
  INNER JOIN
    mni_monitor as mni_m
  ON
    ord.ord_no = mni_m.ord_no
  WHERE 
    ord.ord_no = @ordNo AND
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0'' AND
    mni_m.data_type = 6
)
, ord_main_info AS (
  SELECT 
    ord.pat_id AS pat_id, 
    ord.treat_date AS treat_date, 
    ord.ind_treat_start_time AS ind_treat_start_time
  FROM 
    ord_main ord
  WHERE
    ord.ord_no = @ordNo AND 
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0'' 
)
--前回後体重
, pre_weight_after_info AS (
  SELECT
    rst_weight_info ->> ''weight_after'' AS weight_after 
  FROM 
    ord_main
  WHERE 
    pat_id = (SELECT pat_id FROM ord_main_info) AND 
    rst_dialysis_state >= ''5'' AND 
    (cast(treat_date as date) ||'' ''|| cast(ind_treat_start_time as time))::TIMESTAMP < (cast((SELECT treat_date FROM ord_main_info) as date) ||'' ''|| cast((SELECT ind_treat_start_time FROM ord_main_info) as time))::TIMESTAMP AND 
    facility_cd = @facilityCd AND 
    is_del = ''0'' 
    ORDER BY (cast(treat_date as date) ||'' ''|| cast(ind_treat_start_time as time))::TIMESTAMP 
    LIMIT 1
)
, equipment_info AS (
  --医療材料
  SELECT
    COALESCE(meq.equipment_name, '''') || ''　'' || COALESCE((info ->> ''amount''), ''0'') || COALESCE((info ->> ''unit''), '''') AS equipment
  FROM 
    ord_main ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_equip_info ::json) info
  LEFT OUTER JOIN
    mst_equipment meq
  ON
    meq.equipment_cd = TO_NUMBER(info->>''cd'',''999999999999'')
  WHERE 
    ord.ord_no = @ordNo AND 
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0'' 
)
, comment_info AS (
  --指示簿指示
  SELECT
    REPLACE(COALESCE((info ->> ''content''), ''''), E''\\n'', ''　'') AS comment
  FROM 
    ord_main ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_ind_comment_info ::json) info
  WHERE 
    ord.ord_no = @ordNo AND 
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0''
  ORDER BY (info->>''no'')::int ASC 
)
, medi_info AS (
  --投与薬剤
  SELECT
    CASE info ->> ''effect_flg'' WHEN ''0'' THEN ''          '' WHEN ''1'' THEN TO_CHAR((info ->> ''effect_date'')::timestamptz, ''YYYY/MM/DD'') END || ''　'' || 
    COALESCE((CASE info ->> ''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE mmd.medicine_name END), '''') || ''　'' || 
    COALESCE(info ->> ''amount'', ''0'') || COALESCE(info ->> ''unit'', '''') || ''　'' || COALESCE(mp.pricedure_name, '''') || ''　'' || 
    COALESCE(info ->> ''effect_user_first_name'', '''') || '' '' || COALESCE(info ->> ''effect_user_last_name'', '''') medi
  FROM 
    ord_main ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info ::json) info
  LEFT OUTER JOIN
    mst_medicine_mix mmx
  ON
    mmx.medicine_mix_cd = TO_NUMBER(info ->> ''cd'',''999999999999'')
  LEFT OUTER JOIN
    mst_medicine mmd
  ON
    mmd.medicine_cd = TO_NUMBER(info ->> ''cd'',''999999999999'')
  LEFT OUTER JOIN
    mst_procedure mp
  ON
    mp.procedure_cd = TO_NUMBER(info ->> ''procedure_cd'',''999999999999'')
  WHERE 
    ord.ord_no = @ordNo AND 
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0''
  ORDER BY
	info ->> ''effect_flg'' ASC,
  	info ->> ''effect_date'' ASC,
  	info ->> ''cd'' ASC 
)
, complaint_info AS (
  --愁訴情報
  SELECT
    ROW_NUMBER () OVER () AS row,
    TO_CHAR((info ->> ''occur_date'') :: TIMESTAMP, ''YYYY/MM/DD HH24:MI'') || ''　'' || COALESCE((info ->> ''complaint''), '''') AS complaint
  FROM 
    ord_main ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_complaint_info ::json) info
  WHERE 
    ord.ord_no = @ordNo AND 
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0''
  ORDER BY 
   	(info ->> ''occur_date'') :: TIMESTAMP ASC,
   	info ->> ''ctl_no'' ASC
)
, treatment_info AS (
  --愁訴処置情報
  SELECT
    ROW_NUMBER () OVER () AS row,
    COALESCE((info ->> ''treat_name''), '''') || ''　'' || COALESCE((info ->> ''treat_medicine_name''), '''') || ''　'' || 
    COALESCE((info ->> ''amount''), '''') || COALESCE((info ->> ''unit''), '''') || ''　'' || 
    COALESCE((info ->> ''procedure_name''), '''') AS treatment 
  FROM 
    ord_main ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_treatment_info ::json) info
  WHERE 
    ord.ord_no = @ordNo AND 
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0''
  ORDER BY 
   	(info ->> ''occur_date'') :: TIMESTAMP ASC,
   	info ->> ''ctl_no'' ASC 
)
, treat_staff_info AS (
  --愁訴処置者情報
  SELECT
    ROW_NUMBER () OVER () AS row,
    COALESCE((info ->> ''treat_staff_name''), '''') AS treat_staff_name
  FROM 
    ord_main ord
    CROSS JOIN LATERAL json_array_elements(ord.rst_treat_staff_info ::json) info
  WHERE 
    ord.ord_no = @ordNo AND 
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0'' 
)
, rounds_info AS (
  --観察記録
  SELECT
    TO_TIMESTAMP(
      pat_e.event_start_date :: text || pat_e.event_start_time :: text,
      ''YYYYMMDDHH24MI''
    ) AS datetime,
    pat_e.sub_category_name,
    STRING_AGG(
      CASE pat_e.sub_category_name
        WHEN ''SOAP'' THEN  
          COALESCE((input.params ->> ''field_name''), '''') || '':'' || REPLACE(COALESCE((result.params ->> ''result_value''), ''''), E''\\n'', ''　'')
        ELSE
          REPLACE(COALESCE((result.params ->> ''result_value''), ''''), E''\\n'', ''　'')
      END,
      E''　''
    ) AS content,
    pat_e.up_staff_info ->> ''up_staff_name'' AS name
  FROM
    ord_main ord
    INNER JOIN pat_event pat_e
    CROSS JOIN LATERAL json_array_elements(pat_e.result_params :: json) WITH ORDINALITY AS result(params, ord)
    CROSS JOIN LATERAL json_array_elements(pat_e.input_params :: json) WITH ORDINALITY AS input(params, ord)
      ON ord.ord_no = pat_e.ord_no
    	AND pat_e.is_del = ''0''
        AND result.ord = input.ord
  WHERE
    ord.ord_no = @ordNo AND 
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0''
  GROUP BY
    pat_e.pat_event_cd
  ORDER BY
    datetime
)
SELECT
  Tmp.values AS values
FROM
(
SELECT 
  split_part(cond_arr.cond_row,''-@-'',1) :: INTEGER AS order_no, 
  split_part(cond_arr.cond_row,''-@-'',2) || 
  split_part(cond_arr.cond_row,''-@-'',3) || 
  CASE WHEN split_part(cond_arr.cond_row,''-@-'',3) IS NULL OR split_part(cond_arr.cond_row,''-@-'',3) = ''''
    THEN ''''
    ELSE  split_part(cond_arr.cond_row,''-@-'',4)
  END || E''\\n'' AS values
FROM 
  (SELECT
    regexp_split_to_table(array_to_string(array[
    concat(''1-@-表示用患者ID:-@-'', (@hospPatId) :: TEXT), 
    concat(''2-@-患者名:-@-'', (@patName) :: TEXT), 
    concat(''3-@-指示者:-@-'', (SELECT staff_cd FROM staff_cd_info)),
    concat(''4-@-透析日:-@-'', 
    COALESCE(SUBSTRING(ord.treat_date, 1, 4) || ''年'' ||
       SUBSTRING(ord.treat_date, 5, 2) || ''月'' || 
       SUBSTRING(ord.treat_date, 7, 2) || ''日'', '''') || 
      ''('' ||
      CASE extract(DOW FROM cast(ord.treat_date as TIMESTAMP))
        WHEN 0 THEN ''日曜日''
        WHEN 1 THEN ''月曜日''
        WHEN 2 THEN ''火曜日''
        WHEN 3 THEN ''水曜日''
        WHEN 4 THEN ''木曜日''
        WHEN 5 THEN ''金曜日''
        WHEN 6 THEN ''土曜日''
        ELSE '''' 
      END || '')''
    ),
    concat(''5-@-予定透析時間:-@-'', ord.rst_cond_info -> ''1'' ->> ''value'', ''-@-分''),
    concat(''6-@-予定透析時間:-@-'', RIGHT(''00'' || TRUNC(TO_NUMBER(ord.rst_cond_info -> ''1'' ->> ''value'', ''9999'')/60, 0), 2) || '':'' ||
          RIGHT(''00'' || MOD(TO_NUMBER(ord.rst_cond_info -> ''1'' ->> ''value'', ''9999''), 60), 2)),
    concat(''7-@-入外区分:-@-'', CASE ord.rst_in_out_class WHEN ''0'' THEN ''1'' WHEN ''1'' THEN ''3'' ELSE ''1'' END),
    concat(''8-@-透析回数:-@-'', ord.rst_dialysis_cnt, ''-@-回''),
    concat(''9-@-透析時間:-@-'', RIGHT(''00'' || TRUNC(COALESCE(ord.rst_running_time, ''0'')/60, 0), 2) || '':'' ||
          RIGHT(''00'' || MOD(COALESCE(ord.rst_running_time, ''0''), 60), 2)),
    concat(''10-@-透析開始時刻:-@-'', TO_CHAR(ord.rst_start_date, ''YYYY/MM/DD HH24:MI'')),
    concat(''11-@-透析終了時刻:-@-'', TO_CHAR(ord.rst_end_date, ''YYYY/MM/DD HH24:MI'')),
    concat(''12-@-クール:-@-'', COALESCE(ord.rst_kur_name, '''')),
    concat(''13-@-ベッド:-@-'', COALESCE(ord.rst_bed_name, '''')),
    concat(''14-@-病棟名:-@-'', COALESCE(ord.rst_ward_name, '''')),
    concat(''15-@-診療科:-@-'', COALESCE(ord.rst_course_name, '''')),
    concat(''16-@-担当者１:-@-'', COALESCE(ord.rst_charge_user_info ->> ''user_last_name_1'', '''') || ''　'' || COALESCE(ord.rst_charge_user_info ->> ''user_first_name_1'', '''')),
    concat(''17-@-担当者２:-@-'', COALESCE(ord.rst_charge_user_info ->> ''user_last_name_2'', '''') || ''　'' || COALESCE(ord.rst_charge_user_info ->> ''user_first_name_2'', '''')),
    concat(''18-@-穿刺者１:-@-'', COALESCE(ord.rst_puncture_user_info ->> ''user_last_name_1'', '''') || ''　'' || COALESCE(ord.rst_puncture_user_info ->> ''user_first_name_1'', '''')),
    concat(''19-@-穿刺時刻１:-@-'', TO_CHAR((ord.rst_puncture_user_info ->> ''date'') :: TIMESTAMP, ''YYYY/MM/DD HH24:MI'')),
    concat(''20-@-穿刺者２:-@-'', COALESCE(ord.rst_puncture_user_info ->> ''user_last_name_2'', '''') || ''　'' || COALESCE(ord.rst_puncture_user_info ->> ''user_first_name_2'', '''')),
    concat(''21-@-穿刺時刻２:-@-'', TO_CHAR((ord.rst_puncture_user_info ->> ''date_2'') :: TIMESTAMP, ''YYYY/MM/DD HH24:MI'')),
    concat(''22-@-回収者１:-@-'', COALESCE(ord.rst_return_user_info ->> ''user_last_name_1'', '''') || ''　'' || COALESCE(ord.rst_return_user_info ->> ''user_first_name_1'', '''')),
    concat(''23-@-回収時刻１:-@-'', TO_CHAR((ord.rst_return_user_info ->> ''date_1'') :: TIMESTAMP, ''YYYY/MM/DD HH24:MI'')),
    concat(''24-@-回収者２:-@-'', COALESCE(ord.rst_return_user_info ->> ''user_last_name_2'', '''') || ''　'' || COALESCE(ord.rst_return_user_info ->> ''user_first_name_2'', '''')),
    concat(''25-@-回収時刻２:-@-'', TO_CHAR((ord.rst_return_user_info ->> ''date_2'') :: TIMESTAMP, ''YYYY/MM/DD HH24:MI'')),
    concat(''26-@-前回後体重:-@-'', (SELECT weight_after FROM pre_weight_after_info), ''-@-kg''),
    concat(''27-@-透析前体重:-@-'', ord.rst_weight_info ->> ''weight_before'', ''-@-kg''),
    concat(''28-@-透析前体重測定日時:-@-'', TO_CHAR((ord.rst_weight_info ->> ''weight_before_date'') :: TIMESTAMP, ''YYYY/MM/DD HH24:MI'')),
    concat(''29-@-ＣＴＲ:-@-'', ord.rst_weight_info ->> ''ctr'', ''-@-%''),
    concat(''30-@-ＣＴＲ測定時体重:-@-'', ord.rst_weight_info ->> ''ctr_weight'', ''-@-kg''),
    concat(''31-@-ＣＴＲ測定日:-@-'', TO_CHAR((ord.rst_weight_info ->> ''ctr_measure_date'') :: DATE, ''YYYY/MM/DD'')),
    concat(''32-@-目標体重:-@-'', ord.rst_cond_info -> ''3'' ->> ''value'', ''-@-kg''),
    concat(''33-@-目標除水量:-@-'', ord.rst_weight_info ->> ''water_removal_target'', ''-@-L''),
    concat(''34-@-除水実績:-@-'', ord.rst_weight_info ->> ''water_removal_rst'', ''-@-L''),
    concat(''35-@-Ｋｔ／Ｖ測定値:-@-'', COALESCE(ord.rst_weight_info ->> ''kt_v_measure'', '''')),
    concat(''36-@-ＵＲＲ:-@-'', ord.rst_weight_info ->> ''urr'', ''-@-%''),
    concat(''37-@-再循環率:-@-'', ord.rst_weight_info ->> ''recrcl_rt'', ''-@-%''),
    concat(''38-@-透析後体重:-@-'', ord.rst_weight_info ->> ''weight_after'', ''-@-kg''),
    concat(''39-@-透析後体重測定日時:-@-'', TO_CHAR((ord.rst_weight_info ->> ''weight_after_date'') :: DATE, ''YYYY/MM/DD'')),
    concat(''40-@-減少量:-@-'', TO_NUMBER(ord.rst_weight_info ->> ''weight_before'', ''999999999D9'') - TO_NUMBER(ord.rst_weight_info ->> ''weight_after'', ''999999999D9''), ''-@-kg''),
    concat(''41-@-前血圧(最高):-@-'', COALESCE((SELECT bp_max FROM rst_vital_info_before), '''')),
    concat(''42-@-前血圧(最低):-@-'', COALESCE((SELECT bp_min FROM rst_vital_info_before), '''')),
    concat(''43-@-前血圧(平均):-@-'', COALESCE((SELECT bp_ave FROM rst_vital_info_before), '''')),
    concat(''44-@-前脈拍:-@-'', COALESCE((SELECT pulse FROM rst_vital_info_before), '''')),
    concat(''45-@-前血圧測定日時:-@-'', TO_CHAR((SELECT occur_date FROM rst_vital_info_before) :: TIMESTAMP, ''YYYY/MM/DD HH24:MI'')),
    concat(''46-@-後血圧(最高):-@-'', COALESCE((SELECT bp_max FROM rst_vital_info_after), '''')),
    concat(''47-@-後血圧(最低):-@-'', COALESCE((SELECT bp_min FROM rst_vital_info_after), '''')),
    concat(''48-@-後血圧(平均):-@-'', COALESCE((SELECT bp_ave FROM rst_vital_info_after), '''')),
    concat(''49-@-後脈拍:-@-'', COALESCE((SELECT pulse FROM rst_vital_info_after), '''')),
    concat(''50-@-後血圧測定日時:-@-'', TO_CHAR((SELECT occur_date FROM rst_vital_info_after) :: TIMESTAMP, ''YYYY/MM/DD HH24:MI'')),
    concat(''51-@-体温:-@-'', (SELECT temperature FROM rst_vital_info_after), ''-@-℃''),
    concat(''52-@-透析条件：-@-'', (SELECT temperature FROM rst_vital_info_after), ''-@-℃''),
    concat(''53-@-透析開始時刻:-@-'', SUBSTRING(ord.ind_treat_start_time,1,2) || '':'' || SUBSTRING(ord.ind_treat_start_time,3,2)), 
    concat(''54-@-透析予定時間:-@-'', ord.rst_cond_info -> ''1'' ->> ''value'', ''-@-分''), 
    concat(''55-@-透析予定時間:-@-'', RIGHT(''00'' || TRUNC(TO_NUMBER(ord.rst_cond_info -> ''1'' ->> ''value'', ''9999'')/60, 0), 2) || '':'' ||
           RIGHT(''00'' || MOD(TO_NUMBER(ord.rst_cond_info -> ''1'' ->> ''value'', ''9999''), 60), 2), ''-@-mL/min''),
    concat(''56-@-VA:-@-'', COALESCE(mva.va_name, '''')),
    concat(''57-@-目標体重:-@-'', ord.rst_cond_info -> ''3'' ->> ''value'', ''-@-kg''),
    concat(''58-@-治療方法:-@-'', COALESCE(mtt.treatment_name , '''')),
    concat(''59-@-除水量制限:-@-'', ord.rst_cond_info -> ''4'' ->> ''value'', ''-@-L''),
    concat(''60-@-ダイアライザ:-@-'', COALESCE(mdz.model_number, '''')),
    concat(''61-@-吸着カラム:-@-'', COALESCE(meq.equipment_name, '''')),
    concat(''62-@-血流量:-@-'', ord.rst_cond_info -> ''14'' ->> ''value'', ''-@-mL/min''),
    concat(''63-@-抗凝固剤:-@-'', COALESCE(mmd25.medicine_name, '''')),
    concat(''64-@-抗凝固剤ワンショット量:-@-'', ord.rst_cond_info -> ''26'' ->> ''value'' || COALESCE((CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx25.unit ELSE mmd25.unit END), '''')),
    concat(''65-@-抗凝固剤持続速度:-@-'', ord.rst_cond_info -> ''27'' ->> ''value'' || COALESCE((CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx25.unit ELSE mmd25.unit END), ''''), ''-@-/h''),
    concat(''66-@-抗凝固剤持続総量:-@-'', ord.rst_cond_info -> ''28'' ->> ''value'' || COALESCE((CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx25.unit ELSE mmd25.unit END), '''')),
    concat(''67-@-IP使用選択:-@-'', CASE ord.rst_cond_info -> ''29'' ->> ''value'' WHEN ''0'' THEN ''使用しない'' WHEN ''1'' THEN ''使用する'' ELSE '''' END),
    concat(''68-@-IPワンショット量:-@-'', ord.rst_cond_info -> ''31'' ->> ''value'', ''-@-mL''),
    concat(''69-@-IP速度:-@-'', ord.rst_cond_info -> ''32'' ->> ''value'', ''-@-mL/h''),
    concat(''70-@-透析液:-@-'', COALESCE(mmd15.medicine_name, '''')),
    concat(''71-@-透析液流量:-@-'', ord.rst_cond_info -> ''16'' ->> ''value'', ''-@-mL/min''),
    concat(''72-@-透析液量:-@-'', COALESCE((ord.rst_cond_info -> ''17'' ->> ''value'') || (ord.rst_cond_info -> ''17'' ->> ''unit''), '''')),
    concat(''73-@-透析液温度:-@-'', ord.rst_cond_info -> ''18'' ->> ''value'', ''-@-℃''),
    concat(''74-@-補液:-@-'', COALESCE(mmd19.medicine_name, '''')),
    concat(''75-@-補液量:-@-'', ord.rst_cond_info -> ''20'' ->> ''value'', ''-@-L''),
    concat(''76-@-補液選択:-@-'', CASE ord.rst_cond_info -> ''21'' ->> ''value'' WHEN ''0'' THEN ''後補液'' WHEN ''1'' THEN ''前補液'' ELSE '''' END),
    concat(''77-@-補液温度:-@-'', ord.rst_cond_info -> ''23'' ->> ''value'', ''-@-℃''),
    concat(''78-@-シングルニードル使用:-@-'', CASE ord.rst_cond_info -> ''12'' ->> ''value'' WHEN ''0'' THEN ''無し'' WHEN ''1'' THEN ''有り'' ELSE '''' END),
    concat(''79-@-補液使用数:-@-'', COALESCE((ord.rst_cond_info -> ''22'' ->> ''value'') || (ord.rst_cond_info -> ''22'' ->> ''unit''), '''')),
    concat(''80-@-IPスタート:-@-'', CASE ord.rst_cond_info -> ''30'' ->> ''value'' WHEN ''0'' THEN ''手動'' WHEN ''1'' THEN ''自動'' ELSE '''' END),
    concat(''81-@-自動ワンショット:-@-'', CASE ord.rst_cond_info -> ''34'' ->> ''value'' WHEN ''0'' THEN ''使用しない'' WHEN ''1'' THEN ''使用する'' ELSE '''' END),
    concat(''82-@-IP電源自動切り:-@-'', CASE ord.rst_cond_info -> ''35'' ->> ''value'' WHEN ''0'' THEN ''切'' WHEN ''1'' THEN ''入'' ELSE '''' END),
    concat(''83-@-IP電源自動切り時間:-@-'', COALESCE(ord.rst_cond_info -> ''36'' ->> ''value'', '''')),
    concat(''84-@-IP電源OKモニタ切り:-@-'', CASE ord.rst_cond_info -> ''37'' ->> ''value'' WHEN ''0'' THEN ''切'' WHEN ''1'' THEN ''入'' ELSE '''' END),
    concat(''85-@-IP電源OKモニタ切り時間:-@-'', COALESCE(ord.rst_cond_info -> ''38'' ->> ''value'', '''')),
    concat(''86-@-IP速度最大値:-@-'', ord.rst_cond_info -> ''33'' ->> ''value'', ''-@-mL/h''),
    concat(''87-@-IP補液速度:-@-'', ord.rst_cond_info -> ''24'' ->> ''value'', ''-@-L/h''),
    concat(''88-@-1次膜:-@-'', COALESCE(meq1.equipment_name, '''')),
    concat(''89-@-2次膜:-@-'', COALESCE(meq2.equipment_name, ''''))
    ],''-@@-''),''-@@-'') AS cond_row
  FROM
    ord_main ord 
  LEFT OUTER JOIN
    mst_va mva
  ON
    mva.va_cd = TO_NUMBER(ord.rst_cond_info -> ''2'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_dialyzer mdz
  ON
    mdz.dialyzer_cd = TO_NUMBER(ord.rst_cond_info -> ''5'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_equipment meq
  ON
    meq.equipment_cd = TO_NUMBER(ord.rst_cond_info -> ''6'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_equipment meq1
  ON
    meq1.equipment_cd = TO_NUMBER(ord.rst_cond_info -> ''7'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_equipment meq2
  ON
    meq2.equipment_cd = TO_NUMBER(ord.rst_cond_info -> ''8'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_medicine mmd15
  ON
    mmd15.medicine_cd = TO_NUMBER(ord.rst_cond_info -> ''15'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_medicine mmd19
  ON
    mmd19.medicine_cd = TO_NUMBER(ord.rst_cond_info -> ''19'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_medicine mmd17
  ON
    mmd17.medicine_cd = TO_NUMBER(ord.rst_cond_info -> ''17'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_medicine_mix mmx17
  ON
    mmx17.medicine_mix_cd = TO_NUMBER(ord.rst_cond_info -> ''17'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_medicine mmd22
  ON
    mmd22.medicine_cd = TO_NUMBER(ord.rst_cond_info -> ''22'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_medicine_mix mmx22
  ON
    mmx22.medicine_mix_cd = TO_NUMBER(ord.rst_cond_info -> ''22'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_medicine mmd25
  ON
    mmd25.medicine_cd = TO_NUMBER(ord.rst_cond_info -> ''25'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_medicine mmd26
  ON
    mmd26.medicine_cd = TO_NUMBER(ord.rst_cond_info -> ''26'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_medicine_mix mmx25
  ON
    mmx25.medicine_mix_cd = TO_NUMBER(ord.rst_cond_info -> ''25'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_medicine mmd27
  ON
    mmd27.medicine_cd = TO_NUMBER(ord.rst_cond_info -> ''27'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_medicine_mix mmx27
  ON
    mmx27.medicine_mix_cd = TO_NUMBER(ord.rst_cond_info -> ''27'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_medicine mmd28
  ON
    mmd28.medicine_cd = TO_NUMBER(ord.rst_cond_info -> ''28'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_medicine_mix mmx28
  ON
    mmx28.medicine_mix_cd = TO_NUMBER(ord.rst_cond_info -> ''28'' ->> ''value'', ''999999999999'')
  LEFT OUTER JOIN
    mst_treatment mtt
  ON
    mtt.treatment_cd = ord.ind_treatment_cd
  WHERE
    ord.ord_no = @ordNo AND 
    ord.facility_cd = @facilityCd AND 
    ord.is_del = ''0'' 
) cond_arr
--医療材料
UNION 
(SELECT 
  99 AS order_no, 
  ''医療材料：'' || E''\\n'' AS values)
UNION
(SELECT 
  100 AS order_no, 
  equipment || E''\\n'' AS values
FROM 
  equipment_info)
--指示簿指示
UNION
(SELECT 
  101 AS order_no, 
  ''指示簿指示：'' || E''\\n'' AS values)
UNION
(SELECT 
  102 AS order_no, 
  STRING_AGG(comment_info.comment, E''\\n'')|| E''\\n'' AS values
FROM 
  comment_info)
--投与薬剤
UNION
(SELECT 
  103 AS order_no, 
  ''投与薬剤：'' || E''\\n'' AS values)
UNION
(SELECT 
  104 AS order_no, 
  STRING_AGG(medi, E''\\n'')|| E''\\n'' AS values
FROM 
  medi_info)
--愁訴処置
UNION
(SELECT 
  105 AS order_no, 
  ''愁訴処置：'' || E''\\n'' AS values) 
UNION
(SELECT
  106 AS order_no,
  STRING_AGG(
    complaint_info.complaint || ''　'' || treatment_info.treatment || ''　'' || treat_staff_info.treat_staff_name,
    E''\\n''
  ) || E''\\n'' AS
values
FROM
  complaint_info
  LEFT JOIN treatment_info ON complaint_info.row = treatment_info.row
  LEFT JOIN treat_staff_info ON complaint_info.row = treat_staff_info.row)
--観察記録
UNION
(SELECT 
  107 AS order_no,
  ''観察記録：'' || E''\\n'' AS values)
UNION
(SELECT
  108 AS order_no, 
  STRING_AGG(
    TO_CHAR(rounds_info.datetime :: TIMESTAMP, ''YYYY/MM/DD HH24:MI'') || ''　'' || 
      COALESCE(rounds_info.sub_category_name, '''') || ''　'' || 
      rounds_info.content || ''　'' || 
      rounds_info.name,
    E''\\n''
  ) || E''\\n'' AS values
FROM rounds_info)
ORDER BY order_no ASC
) Tmp', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SSI）カルテ記載連携：内容取得', '2023-05-18 19:22:02.414', CURRENT_TIMESTAMP, '[{"sql_cd": -1, "field_name": "hosp_pat_id", "replace_var": "@hospPatId"}, {"sql_cd": -1, "field_name": "pat_name", "replace_var": "@patName"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501091, 'WITH new_name_info AS ( 
  SELECT
    COALESCE(substring(''@patLastName'' ::TEXT from ''^(.*?)[\u3000\s]''), ''@patLastName'') AS patLastName
    , substring(''@patLastName'' ::TEXT from ''[\u3000\s](.*)'') AS patFirstName
    , COALESCE(substring(''@patLastNmKana'' ::TEXT from ''^(.*?)[\u3000\s]''), ''@patLastNmKana'') AS patLastNmKana
    , substring(''@patLastNmKana'' ::TEXT from ''[\u3000\s](.*)'') AS patFirstNmKana
) 
INSERT 
INTO pat_personal_main( 
  fn_pat_id
  , hosp_pat_id
  , nkk_pat_id
  , facility_cd
  , pat_last_name
  , pat_first_name
  , pat_last_name_kana
  , pat_first_name_kana
  , pat_last_name_alpha
  , pat_first_name_alpha
  , pat_birth_name
  , pat_birth_name_kana
  , pat_birth_name_alpha
  , pat_birthday
  , pat_sex
  , nationality
  , pat_blood_type_abo
  , pat_blood_type_rh
  , pat_blood_type_serovar
  , in_out_class
  , is_die
  , die_cd
  , die_date
  , dial_diff_com_info
  , severity_cd
  , transport_cd
  , pat_contact_info
  , other_contact_info
  , vendor_contact_info
  , insurance_info
  , is_del
  , up_date
  , reg_date
  , primary_disease_cd
  , remote_monitor_service
  , remote_monitor_user_id
  , remote_monitor_user_pw
) 
VALUES ( 
  NULLIF(''@fnPatId'', '''')
  , NULLIF(''@hospPatId'', '''')
  , NULLIF(''@nkkPatId'', '''')
  , NULLIF(''@facilityCd'', '''')
  , personal_info_encrypt((SELECT CASE WHEN NULLIF(''@patLastName'', '''') IS NULL THEN patLastNmKana ELSE patLastName END FROM new_name_info)) 
  , personal_info_encrypt((SELECT CASE WHEN NULLIF(''@patLastName'', '''') IS NULL THEN patFirstNmKana ELSE patFirstName END FROM new_name_info))
  , personal_info_encrypt((SELECT patLastNmKana FROM new_name_info))
  , personal_info_encrypt((SELECT patFirstNmKana FROM new_name_info))
  , NULLIF(''@patLastNmAlpha'', '''')
  , NULLIF(''@patFirstNmAlpha'', '''')
  , NULLIF(''@patBirthName'', '''')
  , NULLIF(''@patBirthNmKana'', '''')
  , NULLIF(''@patBirthNmAlpha'', '''')
  , CASE
    WHEN LENGTH(''@patBirthday'') = 8 AND ''@patBirthday'' ~ ''^[0-9]+$'' THEN ''@patBirthday''
    ELSE NULL
    END
  , CASE 
    WHEN ''@patSex'' IN (''1'',''2'') THEN TO_NUMBER(''@patSex'', ''FM9999999999999999'') 
    ELSE 0 
    END
  , NULLIF(''@nationality'', '''')
  , CASE ''@patBloodTypeAbo'' 
    WHEN '''' THEN 0 
    WHEN ''NoXmlTag'' THEN 0
    ELSE TO_NUMBER(''@patBloodTypeAbo'', ''FM9999999999999999'') 
    END
  , CASE ''@patBloodTypeRh'' 
    WHEN '''' THEN 0
    WHEN ''NoXmlTag'' THEN 0
    ELSE TO_NUMBER(''@patBloodTypeRh'', ''FM9999999999999999'') 
    END
  , CASE ''@patBloodTypeSerovar'' 
    WHEN '''' THEN 0 
    ELSE TO_NUMBER(''@patBloodTypeSerovar'', ''FM9999999999999999'') 
    END
  , CASE WHEN @inOut = 3 THEN 0
    ELSE @inOut
    END
  , NULLIF(''@isDie'', '''')
  ,  CASE ''@dieCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@dieCd'', ''FM99999999999999999999999999999999'') 
    END
  , CASE ''@dieDate_Date'' 
    WHEN '''' THEN NULL 
    ELSE TO_TIMESTAMP(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS'') 
    END
  , COALESCE(NULLIF(''@dialDiffComInfo'', ''''), ''[]'') ::JSONB
  , CASE ''@severityCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@severityCd'', ''FM99999999999999999999999999999999'') 
    END
  , CASE ''@transportCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@transportCd'', ''FM99999999999999999999999999999999'') 
    END
  , NULL
  , ''@otherContactInfoValue''
  , ''@vendorContactInfoValue''
  , ''@insuranceInfoValue''
  , ''0''
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , CASE ''@primaryDiseaseCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@primaryDiseaseCd'', ''FM99999999999999999999999999999999'') 
    END
  , CASE ''@remoteMonitorService'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@remoteMonitorService'', ''FM99999999999999999999999999999999'') 
    END
  , NULLIF(''@remoteMonitorUserId'', '''')
  , NULLIF(''@remoteMonitorUserPw'', '''')
)', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者個人情報の取得の新規', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 1001, "field_name": "dial_diff_com_info", "replace_var": "@dialDiffComInfo"}, {"sql_cd": -501061, "field_name": "disease_cd", "replace_var": "@dieCd"}, {"sql_cd": -502000, "field_name": "in_out", "replace_var": "@inOut"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501092, 'WITH new_name_info AS ( 
  SELECT
    COALESCE(substring(''@patLastName'' ::TEXT from ''^(.*?)[\u3000\s]''), ''@patLastName'') AS patLastName
    , substring(''@patLastName'' ::TEXT from ''[\u3000\s](.*)'') AS patFirstName
    , COALESCE(substring(''@patLastNmKana'' ::TEXT from ''^(.*?)[\u3000\s]''), ''@patLastNmKana'') AS patLastNmKana
    , substring(''@patLastNmKana'' ::TEXT from ''[\u3000\s](.*)'') AS patFirstNmKana
)
UPDATE pat_personal_main 
SET
  fn_pat_id = NULLIF(''@fnPatId'', '''')
  , hosp_pat_id = NULLIF(''@hospPatId'', '''')
  , nkk_pat_id = NULLIF(''@nkkPatId'', '''')
  , facility_cd = NULLIF(''@facilityCd'', '''')
  , pat_last_name = personal_info_encrypt((SELECT CASE WHEN NULLIF(''@patLastName'', '''') IS NULL THEN patLastNmKana ELSE patLastName END FROM new_name_info)) 
  , pat_first_name = personal_info_encrypt((SELECT CASE WHEN NULLIF(''@patLastName'', '''') IS NULL THEN patFirstNmKana ELSE patFirstName END FROM new_name_info))
  , pat_last_name_kana = personal_info_encrypt((SELECT patLastNmKana FROM new_name_info))
  , pat_first_name_kana = personal_info_encrypt((SELECT patFirstNmKana FROM new_name_info))
  , pat_birth_name = NULLIF(''@patBirthName'', '''')
  , pat_birth_name_kana = NULLIF(''@patBirthNmKana'', '''')
  , pat_birth_name_alpha = NULLIF(''@patBirthNmAlpha'', '''')
  , pat_birthday = CASE
    WHEN LENGTH(''@patBirthday'') = 8 AND ''@patBirthday'' ~ ''^[0-9]+$'' THEN ''@patBirthday''
    ELSE NULL
    END
  , pat_sex = CASE 
    WHEN ''@patSex'' IN (''1'',''2'') THEN TO_NUMBER(''@patSex'', ''FM9999999999999999'') 
    ELSE 0 
    END
  , nationality = NULLIF(''@nationality'', '''')
  , pat_blood_type_abo = CASE ''@patBloodTypeAbo'' 
    WHEN '''' THEN 0 
    WHEN ''NoXmlTag'' THEN pat_blood_type_abo
    ELSE TO_NUMBER(''@patBloodTypeAbo'', ''FM9999999999999999'') 
    END
  , pat_blood_type_rh = CASE ''@patBloodTypeRh'' 
    WHEN '''' THEN 0 
    WHEN ''NoXmlTag'' THEN pat_blood_type_rh
    ELSE TO_NUMBER(''@patBloodTypeRh'', ''FM9999999999999999'') 
    END
  , pat_blood_type_serovar = CASE ''@patBloodTypeSerovar'' 
    WHEN '''' THEN 0 
    ELSE TO_NUMBER(''@patBloodTypeSerovar'', ''FM9999999999999999'') 
    END
  , in_out_class = CASE WHEN @inOut = 3 THEN in_out_class
    ELSE @inOut
    END
  , is_die = NULLIF(''@isDie'', '''')
  , die_cd = CASE ''@dieCd''
    WHEN '''' THEN NULL
    WHEN ''NoXmlTag'' THEN die_cd
    ELSE TO_NUMBER(''@dieCd'', ''FM99999999999999999999999999999999'') 
    END
  , die_date = CASE ''@dieDate_Date'' 
    WHEN '''' THEN NULL 
    ELSE TO_TIMESTAMP(''@dieDate_Date'', ''YYYY-MM-DD HH24:MI:SS'') 
    END
  , dial_diff_com_info = ''@dialDiffComInfoValue''
  , severity_cd = CASE ''@severityCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER( ''@severityCd'', ''FM99999999999999999999999999999999'') 
    END
  , transport_cd = CASE ''@transportCd'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@transportCd'', ''FM99999999999999999999999999999999'') 
    END
  , pat_contact_info = personal_info_encrypt_jsonb(jsonb_build_object(
      ''zip_cd'',
      CASE
        WHEN ''@patContactInfo.zipCd'' = ''NoXmlTag'' THEN personal_info_decrypt_jsonb(pat_contact_info) ->> ''zip_cd''
        ELSE NULLIF(''@patContactInfo.zipCd'', '''')
        END,
      ''address'',
      CASE
        WHEN ''@patContactInfo.address'' = ''NoXmlTag'' THEN personal_info_decrypt_jsonb(pat_contact_info) ->> ''address''
        ELSE NULLIF((TRIM(TRIM(TRIM(''@patContactInfo.address'', ''　''), '' ''), ''　'')), '''')
        END,
      ''tel1'', 
      CASE
        WHEN ''@patContactInfo.tel1'' = ''NoXmlTag'' THEN personal_info_decrypt_jsonb(pat_contact_info) ->> ''tel1''
        ELSE NULLIF(''@patContactInfo.tel1'', '''')
        END,
      ''tel2'',         NULLIF(''@patContactInfo.tel2'', ''''),
      ''fax'',          NULLIF(''@patContactInfo.fax'', ''''),
      ''e_mail'',       NULLIF(''@patContactInfo.eMail'', ''''),
      ''work_name'',    NULLIF(''@patContactInfo.workName'', ''''),
      ''work_address'', NULLIF(''@patContactInfo.workAddress'', ''''),
      ''work_tel'',     NULLIF(''@patContactInfo.workTel'', ''''),
      ''memo1'',
      CASE
        WHEN ''@patContactInfo.memo1'' = ''NoXmlTag''
        THEN CONCAT(regexp_replace(personal_info_decrypt_jsonb(pat_contact_info) ->> ''memo1'', ''【転帰】.*'', ''''),
            CASE
              WHEN ''@isDie'' = ''0''  AND NULLIF(NULLIF(''@tenki'', ''''), ''NoXmlTag'') IS NOT NULL THEN ''【転帰】'' || ''@tenki''
              ELSE NULL
            END
          )
        ELSE CONCAT(regexp_replace(personal_info_decrypt_jsonb(pat_contact_info) ->> ''memo1'', ''【コメント】.*|【転帰】.*'', ''''),
          CASE
            WHEN NULLIF(''@patContactInfo.memo1'', '''') IS NULL THEN
              CASE
                WHEN ''@isDie'' = ''0''  AND NULLIF(NULLIF(''@tenki'', ''''), ''NoXmlTag'') IS NOT NULL THEN ''【転帰】'' || ''@tenki''
                ELSE NULL
              END
            ELSE ''【コメント】'' || ''@patContactInfo.memo1'' || 
              CASE
                WHEN ''@isDie'' = ''0'' AND NULLIF(NULLIF(''@tenki'', ''''), ''NoXmlTag'') IS NOT NULL THEN E''\\n''  || ''【転帰】'' || ''@tenki''
                ELSE ''''
              END
            END
            )
        END,
      ''memo2'',       NULLIF(''@patContactInfo.memo2'', '''')
    ) )
  , vendor_contact_info = ''@vendorContactInfoValue''
  , insurance_info = ''@insuranceInfoValue''
  , reg_date = ''@regDate''
  , up_date = CURRENT_TIMESTAMP
  , primary_disease_cd = CASE ''@primaryDiseaseCd'' 
    WHEN '''' THEN NULL 
    ELSE (CASE WHEN ''@upBaseDiseaseFlg'' = ''0'' THEN NULL ELSE TO_NUMBER(''@primaryDiseaseCd'', ''FM99999999999999999999999999999999'') END) 
    END
  , remote_monitor_service = CASE ''@remoteMonitorService'' 
    WHEN '''' THEN NULL 
    ELSE TO_NUMBER(''@remoteMonitorService'', ''FM99999999999999999999999999999999'') 
    END
  , remote_monitor_user_id = NULLIF(''@remoteMonitorUserId'', '''')
  , remote_monitor_user_pw = NULLIF(''@remoteMonitorUserPw'', '''') 
WHERE
  is_del = ''0'' 
  AND hosp_pat_id = ''@hospPatId''  
  AND facility_cd = ''@facilityCd''', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者個人情報の取得の修正', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 1009, "field_name": "up_base_disease_flg", "replace_var": "@upBaseDiseaseFlg"}, {"sql_cd": -501061, "field_name": "disease_cd", "replace_var": "@dieCd"}, {"sql_cd": -502000, "field_name": "in_out", "replace_var": "@inOut"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501098, 'WITH allergyInfo AS (
    SELECT 
        a.taboo_allergy_info,
        (idx - 1) AS idx,
        CASE 
            WHEN ms->>''content'' = ''@tabooAllergyInfo.content'' AND ''@tabooAllergyInfo.memo'' <> ''''
            THEN ms->>''memo'' || E''\\n'' || ''@tabooAllergyInfo.memo''
            ELSE ms->>''memo''
        END as memo,
        ms->>''ctl_no'' as ctl_no,
        ms->>''content'' as content,
        ms->>''disp_order'' as disp_order,
        ms->>''category_class'' as category_class,
        ms->>''taboo_allergy_cd'' as taboo_allergy_cd,
        ms->>''taboo_allergy_class'' as taboo_allergy_class
    FROM pat_main AS a
    CROSS JOIN LATERAL jsonb_array_elements(a.taboo_allergy_info::jsonb) 
    WITH ORDINALITY AS info(ms, idx)
    WHERE a.is_del = ''0''
    AND a.pat_id = @patId
    AND a.facility_cd = ''@facilityCd''
)
UPDATE pat_main 
SET taboo_allergy_info = 
    CASE 
        WHEN ''@tabooAllergyInfoFlg'' = '''' THEN ''@tabooAllergyInfoValue''::jsonb
        WHEN EXISTS (
            SELECT 1 
            FROM allergyInfo 
            WHERE content = ''@tabooAllergyInfo.content''
        ) THEN (
            SELECT jsonb_agg(
                jsonb_build_object(
                        ''memo'', memo,
                        ''ctl_no'', ctl_no :: int,
                        ''content'', content,
                        ''disp_order'', disp_order :: int,
                        ''category_class'', category_class,
                        ''taboo_allergy_cd'', taboo_allergy_cd,
                        ''taboo_allergy_class'', taboo_allergy_class
                    )
            )
            FROM allergyInfo
        )
        ELSE 
            COALESCE(taboo_allergy_info, ''[]''::jsonb) || jsonb_build_object(
                ''ctl_no'', @nextCtlNo3 :: int,
                ''disp_order'', @nextCtlNo3 :: int,
                ''taboo_allergy_cd'', NULL,
                ''content'', ''@tabooAllergyInfo.content'',
                ''memo'', ''@tabooAllergyInfo.memo'',
                ''category_class'', ''5'',
                ''taboo_allergy_class'', ''1''
            )::jsonb
    END
WHERE is_del = ''0''
AND pat_id = @patId
AND facility_cd = ''@facilityCd''
AND ''@tabooAllergyInfo.status'' IN (''2'', '''');', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者プロファイル(禁忌・アレルギー情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -502002, "field_name": "taboo_allergy_cd", "replace_var": "@tabooAllergyInfo.tabooAllergyCd"}, {"sql_cd": -502002, "field_name": "content", "replace_var": "@tabooAllergyInfo.content"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501100, 'WITH diseaseInfo AS(
SELECT
    disease_cd AS diseaseCd
FROM
    mst_disease
WHERE
    facility_cd = ''@facilityCd''
    AND in_hospital_cd_1 = ''@diseaseCode''
    AND is_del = ''0''
    AND is_disp = ''1''
ORDER BY disease_cd DESC LIMIT 1
),
dieInfo AS(
SELECT
    disease_cd AS dieCd
FROM
    mst_disease
WHERE
    facility_cd = ''@facilityCd''
    AND in_hospital_cd_1 = ''@dieCode''
    AND is_del = ''0''
    AND is_disp = ''1''
ORDER BY disease_cd DESC LIMIT 1
),
isDie AS (SELECT
  CASE 
    WHEN info ->> ''value'' = ''@tenki'' THEN ''1''
    WHEN ''@tenki'' = ''NoXmlTag'' THEN ''@isDie''
    ELSE ''''
  END AS is_die
FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
WHERE
  facility_cd = ''@facilityCd''
  AND is_del = ''0''
  AND info ->> ''key0'' = ''@key0''
  AND info ->> ''key1'' = ''SSI_PATIENT_RECV''
  AND info ->> ''key2'' = ''DIE_CODE''),
outComeInfo AS(
  SELECT
    CASE
      WHEN (SELECT is_die FROM isDie) = ''1'' THEN ''10''
      ELSE ''0''
    END AS outCome
),
validDate AS(
  SELECT
    CASE 
       WHEN NULLIF(''@medicalHstInfo.outComeDate'','''') IS NULL THEN NULL
       WHEN ''@medicalHstInfo.outComeDate'' ~ ''^(19|20)\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01])$'' 
            AND (
                 (''@medicalHstInfo.outComeDate'' ~ ''^(19|20)\d{2}02(29)$'' AND SUBSTRING(''@medicalHstInfo.outComeDate'', 1, 4)::int % 4 = 0 AND (SUBSTRING(''@medicalHstInfo.outComeDate'', 1, 4)::int % 100 != 0 OR SUBSTRING(''@medicalHstInfo.outComeDate'', 1, 4)::int % 400 = 0))
                 OR (''@medicalHstInfo.outComeDate'' ~ ''^(19|20)\d{2}(0[13578]|1[02])(0[1-9]|[12]\d|3[01])$'')
                 OR (''@medicalHstInfo.outComeDate'' ~ ''^(19|20)\d{2}(0[469]|11)(0[1-9]|[12]\d|30)$'')
                 OR (''@medicalHstInfo.outComeDate'' ~ ''^(19|20)\d{2}02(0[1-9]|1\d|2[0-8])$'')
            )
       THEN ''@medicalHstInfo.outComeDate''
       ELSE NULL
     END AS outComeDate,
     CASE 
        WHEN NULLIF(''@medicalHstInfo.diseaseDate'','''') IS NULL THEN NULL
        WHEN ''@medicalHstInfo.diseaseDate'' ~ ''^(19|20)\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01])$'' 
            AND (
                 (''@medicalHstInfo.diseaseDate'' ~ ''^(19|20)\d{2}02(29)$'' AND SUBSTRING(''@medicalHstInfo.diseaseDate'', 1, 4)::int % 4 = 0 AND (SUBSTRING(''@medicalHstInfo.diseaseDate'', 1, 4)::int % 100 != 0 OR SUBSTRING(''@medicalHstInfo.diseaseDate'', 1, 4)::int % 400 = 0))
                 OR (''@medicalHstInfo.diseaseDate'' ~ ''^(19|20)\d{2}(0[13578]|1[02])(0[1-9]|[12]\d|3[01])$'')
                 OR (''@medicalHstInfo.diseaseDate'' ~ ''^(19|20)\d{2}(0[469]|11)(0[1-9]|[12]\d|30)$'')
                 OR (''@medicalHstInfo.diseaseDate'' ~ ''^(19|20)\d{2}02(0[1-9]|1\d|2[0-8])$'')
            )
        THEN ''@medicalHstInfo.diseaseDate''
        ELSE NULL
     END AS diseaseDate
),
dateInfo AS(
  SELECT
    CASE
      WHEN (SELECT is_die FROM isDie) = ''1'' THEN (SELECT outComeDate FROM validDate)
      ELSE ''''
    END AS dieDate,
    CASE
      WHEN (SELECT is_die FROM isDie) = ''1'' THEN (SELECT outComeDate FROM validDate)
      ELSE to_char(CURRENT_TIMESTAMP, ''YYYYMMDD'')
    END AS inOutDate
),
medi_data_exists_info AS(
SELECT CASE WHEN EXISTS (
      SELECT 1
      FROM jsonb_array_elements(medical_hst_info) AS elem
      WHERE COALESCE((elem->>''disease_cd'')::int, -1) = CASE
        WHEN (SELECT is_die FROM isDie) = ''1'' THEN COALESCE((SELECT dieCd FROM dieInfo), -1)
        ELSE (SELECT diseaseCd FROM diseaseInfo)
      END
      AND CASE WHEN (SELECT diseaseDate FROM validDate) IS NULL THEN true
        ELSE elem->>''disease_date'' = (SELECT diseaseDate FROM validDate)
        END
      AND elem->>''out_come'' = (SELECT outCome FROM outComeInfo)
    )
    THEN ''1''
    ELSE ''0''
    END exists_flag
FROM pat_unique
WHERE
  pat_id = @patId
AND facility_cd = ''@facilityCd''
AND is_del = ''0''
),
in_out_class AS(
  SELECT
    (
      CASE
        WHEN  (SELECT is_die FROM isDie) = ''1'' THEN ''2''
        WHEN info ->> ''value'' = ''@inOutClass'' THEN ''1''
        WHEN ''@inOutClass'' = ''NoXmlTag'' THEN ''@ppmInOutClass''
        ELSE ''0''
      END
    ) AS in_out
FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
WHERE
  facility_cd = ''@facilityCd''
  AND is_del = ''0''
  AND info ->> ''key0'' = ''@key0''
  AND info ->> ''key1'' = ''SSI_PATIENT_RECV''
  AND info ->> ''key2'' = ''CONV_INOUT_1''
),
in_out_ctl_no_calc AS(
  SELECT
    COUNT(1) + 1 AS ctl_no
  FROM
    pat_unique
    CROSS JOIN
      jsonb_array_elements(pat_unique.in_out_visit_history_info) AS data_calc
  WHERE
    pat_unique.pat_id = @patId
  AND facility_cd = ''@facilityCd''
  AND is_del = ''0''
  GROUP BY
    pat_unique.pat_id
),
data_new_info AS(
  SELECT
    COALESCE(ctl_no, 1) AS ctl_no,
    in_out AS in_out,
    NULL AS reason,
    NULL AS to_course,
    NULL AS to_doctor,
    0 AS disp_order,
    NULL AS period_end,
    ''@facilityCd'' AS facility_cd,
    NULL AS from_course,
    NULL AS from_doctor,
    (CASE in_out WHEN ''0'' THEN ''6'' WHEN ''1'' THEN ''4'' WHEN ''2'' THEN ''11'' ELSE ''6'' END)::TEXT AS move_in_out,
    NULL AS to_facility,
    (SELECT inOutDate FROM dateInfo) AS period_start,
    NULL AS from_facility,
    ''0'' AS course_is_free,
    ''0'' AS doctor_is_free,
    NULL AS period_end_day,
    NULL AS period_end_year,
    ''0'' AS facility_is_free,
    NULL AS period_end_month,
    CASE WHEN (SELECT inOutDate FROM dateInfo) IS NULL
THEN NULL
ELSE SUBSTR((SELECT inOutDate FROM dateInfo), 7, 2) END AS period_start_day,
    (SELECT inOutDate FROM dateInfo) AS period_start_date,
    CASE WHEN (SELECT inOutDate FROM dateInfo) IS NULL
THEN NULL
ELSE SUBSTR((SELECT inOutDate FROM dateInfo), 1, 4) END AS period_start_year,
    CASE WHEN (SELECT inOutDate FROM dateInfo) IS NULL
THEN NULL
ELSE SUBSTR((SELECT inOutDate FROM dateInfo), 5, 2) END AS period_start_month,
    ''0'' AS period_end_input_free,
    ''0'' AS period_start_input_free,
    NULL AS to_medicalInstitutionCd,
    NULL AS from_medicalInstitutionCd
  FROM
    in_out_class
    LEFT JOIN
      in_out_ctl_no_calc
    ON  true
),
in_out_data_exists_info AS(
  SELECT
    1 AS order_no,
    ''1'' AS exists_flag
  FROM
    in_out_class ioc
  WHERE
    ''@ppmInOutClass'' = ioc.in_out
  UNION
  SELECT
    2 AS order_no,
    ''0'' AS exists_flag
  ORDER BY
    order_no
  LIMIT 1
),
json_data AS(
  SELECT
    jsonb_build_object(
      ''ctl_no'',
      ctl_no,
      ''in_out'',
      in_out::integer,
      ''reason'',
      reason,
      ''to_course'',
      to_course,
      ''to_doctor'',
      to_doctor,
      ''disp_order'',
      disp_order,
      ''period_end'',
      period_end,
      ''facility_cd'',
      facility_cd,
      ''from_course'',
      from_course,
      ''from_doctor'',
      from_doctor,
      ''move_in_out'',
      move_in_out,
      ''to_facility'',
      to_facility,
      ''period_start'',
      period_start,
      ''from_facility'',
      from_facility,
      ''course_is_free'',
      course_is_free,
      ''doctor_is_free'',
      doctor_is_free,
      ''period_end_day'',
      period_end_day,
      ''period_end_year'',
      period_end_year,
      ''facility_is_free'',
      facility_is_free,
      ''period_end_month'',
      period_end_month,
      ''period_start_day'',
      period_start_day,
      ''period_start_date'',
      period_start_date,
      ''period_start_year'',
      period_start_year,
      ''period_start_month'',
      period_start_month,
      ''period_end_input_free'',
      period_end_input_free,
      ''period_start_input_free'',
      period_start_input_free,
      ''to_medicalInstitutionCd'',
      to_medicalInstitutionCd,
      ''from_medicalInstitutionCd'',
      from_medicalInstitutionCd
    ) AS new_data
  FROM
    data_new_info
)
UPDATE
  pat_unique
SET
  up_date = CURRENT_TIMESTAMP,
  medical_hst_info =  CASE
    WHEN (SELECT exists_flag FROM medi_data_exists_info) = ''0''
     THEN medical_hst_info || (
    CASE
        WHEN
          COALESCE((SELECT diseaseCd::text FROM diseaseInfo),'''') <> ''''
        OR (SELECT is_die FROM isDie) = ''1''
         THEN jsonb_build_object(
          ''memo'',
          ''@medicalHstInfo.memo'',
          ''ctl_no'',
          @nextCtlNo2,
          ''die_date'',
          (SELECT dieDate FROM dateInfo),
          ''out_come'',
          (SELECT outCome FROM outComeInfo),
          ''course_cd'',
          ''@medicalHstInfo.courseCd'',
          ''is_notice'',
          ''0'',
          ''disease_cd'',
          CASE
          WHEN (SELECT is_die FROM isDie) = ''1''  THEN (SELECT dieCd FROM dieInfo)
          ELSE (SELECT diseaseCd FROM diseaseInfo)
          END,
          ''disp_order'',
          @nextCtlNo2 -1,
          ''disease_day'',
          CASE WHEN (SELECT diseaseDate FROM validDate) IS NULL
            THEN NULL
            ELSE substr((SELECT diseaseDate FROM validDate), 7, 2) END,
          ''facility_cd'',
          ''@facilityCd'',
          ''disease_date'',
          (SELECT diseaseDate FROM validDate),
          ''disease_year'',
          CASE WHEN (SELECT diseaseDate FROM validDate) IS NULL
            THEN NULL
            ELSE substr((SELECT diseaseDate FROM validDate), 1, 4) END,
          ''is_diagnosed'',
          ''0'',
          ''diagnosis_day'',
          ''@medicalHstInfo.diagnosisDay'',
          ''disease_month'',
          CASE WHEN (SELECT diseaseDate FROM validDate) IS NULL
            THEN NULL
            ELSE substr((SELECT diseaseDate FROM validDate), 5, 2) END,
          ''out_come_date'',
          (SELECT dieDate FROM dateInfo),
          ''course_is_free'',
          ''0'',
          ''diagnosis_date'',
          ''@medicalHstInfo.diagnosisDate'',
          ''diagnosis_year'',
          ''@medicalHstInfo.diagnosisYear'',
          ''diagnosis_month'',
          ''@medicalHstInfo.diagnosisMonth'',
          ''is_main_disease'',
          ''0'',
          ''diagnostician_cd'',
          ''@medicalHstInfo.diagnosticianCd'',
          ''diagnosis_facility_cd'',
          ''@medicalHstInfo.diagnosisFacilityCd'',
          ''diagnostician_is_free'',
          ''0'',
          ''is_confirmation_biopsy'',
          ''0'',
          ''diagnosis_facility_is_free'',
          ''0'',
          ''disease_end_input_free'',
          ''0'',
          ''diagnosis_end_input_free'',
          ''0'',
          ''disease_start_input_free'',
          ''0'',
          ''diagnosis_start_input_free'',
          ''0'',
          ''is_dialysis_underlying_disease'',
          CASE
            WHEN (SELECT is_die FROM isDie) = '''' THEN ''1''
            ELSE ''0''
          END
        )
        ELSE ''[]''::jsonb
      END
  )
    ELSE medical_hst_info
  END
  ,
  in_out_visit_history_info = CASE
    WHEN((SELECT exists_flag FROM in_out_data_exists_info) = ''0''
    OR  in_out_visit_history_info IS NULL
    OR  in_out_visit_history_info = ''[]''
    ) THEN in_out_visit_history_info || (SELECT new_data FROM json_data)
    ELSE in_out_visit_history_info
  END
WHERE
  pat_id = @patId
AND facility_cd = ''@facilityCd''
AND is_del = ''0''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者プロファイル(既往歴情報情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -100001, "field_name": "in_out_class", "replace_var": "@ppmInOutClass"}, {"sql_cd": -100001, "field_name": "is_die", "replace_var": "@isDie"}]'::jsonb);