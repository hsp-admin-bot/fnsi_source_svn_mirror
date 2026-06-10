delete from "sys_data_set" where sql_cd in (-202,-204);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-204, '-- 204
WITH coop_ini_info AS (
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
,select_koucoagulant AS (--抗凝固剤
    SELECT
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
    , mmd.unit AS e05
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
)
,select_dialysis AS( --透析液情報
  SELECT
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
  ) AS e04
  , mmd.unit AS e05
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
)
,select_fluid_replacement AS(--補液情報
SELECT 
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
  , mmd.unit AS e05
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
)
,select_punc_needle AS(--穿刺針情報
  SELECT
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
  , meq.unit AS e05
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
)
,select_special_blood_purification AS(--特殊血液浄化
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
   , meq.unit AS e05
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
   , meq.unit AS e05
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
   , meq.unit AS e05
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
   , meq.unit AS e05
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
)
,select_ind_medi AS(--加算(患者)、加算(その他)その2、項目コメント、透析コメント1~3Ver2
 SELECT
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
   , mmd.unit AS e05
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
)
,select_consumption AS( --医材情報
SELECT 
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
  , meq.unit AS e05
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
	    detail_id
	    ,sbt_key
	    , e01
	    , e02
	    , e03
	    , e04
	    , (SELECT value FROM coop_ini_info WHERE key2 = concat(e03, e05)) AS e05
	    , e06
	    , e07
	    , e08
	    , e09
	    from select_koucoagulant

        UNION
        SELECT --透析液情報
	    detail_id
	    ,sbt_key
	    , e01
	    , e02
	    , e03
	    , e04
	    , (SELECT value FROM coop_ini_info WHERE key2 = concat(e03, e05)) AS e05
	    , e06
	    , e07
	    , e08
	    , e09
	    from select_dialysis
	    
        UNION
        SELECT --補液情報
		 detail_id
	    ,sbt_key
	    , e01
	    , e02
	    , e03
	    , e04
	    , (SELECT value FROM coop_ini_info WHERE key2 = concat(e03, e05)) AS e05
	    , e06
	    , e07
	    , e08
	    , e09
	    from select_fluid_replacement

        UNION
        SELECT --投与薬剤情報
        ''指示詳細'' AS detail_id
        , ind_medi.sbt_key AS sbt_key
        , ind_medi.e01 AS e01
        , (SELECT value FROM sendmsg_gen) AS e02
        , COALESCE(ind_medi.e03, (SELECT value FROM func_medicine)) AS e03
        , ind_medi.e04 AS e04
        ,  (SELECT value FROM coop_ini_info WHERE key2 = concat(ind_medi.e03, mmd.unit)) AS e05
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

        SELECT  --穿刺針情報
		 detail_id
	    ,sbt_key
	    , e01
	    , e02
	    , e03
	    , e04
	    , (SELECT value FROM coop_ini_info WHERE key2 = concat(e03, e05)) AS e05
	    , e06
	    , e07
	    , e08
	    , e09
	    from select_punc_needle
	    
	    UNION
	    SELECT  --医材情報
		 detail_id
	    ,sbt_key
	    , e01
	    , e02
	    , e03
	    , e04
	    , (SELECT value FROM coop_ini_info WHERE key2 = concat(e03, e05)) AS e05
	    , e06
	    , e07
	    , e08
	    , e09
	    from select_consumption
	    
		UNION
        SELECT--特殊血液浄化
	    detail_id
	    ,sbt_key
	    , e01
	    , e02
	    , e03
	    , e04
	    , (SELECT value FROM coop_ini_info WHERE key2 = concat(e03, e05)) AS e05
	    , e06
	    , e07
	    , e08
	    , e09
	    from select_special_blood_purification
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
        SELECT --加算(患者)、加算(その他)その2、項目コメント、透析コメント1~3Ver2
	    detail_id
	    ,kinds
	    , e01
	    , e02
	    , e03
	    , e04
	    , (SELECT value FROM coop_ini_info WHERE key2 = concat(e03, e05)) AS e05
	    , e06
	    , e07
	    , e08
	    , e09
	    from select_ind_medi
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
),
select_koucoagulant AS( --抗凝固剤
 SELECT
   ''実績詳細'' AS detail_id
   , ''抗凝固剤'' AS sbt_key
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
   , mmd.unit AS e05
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
),
select_puncture_needle AS( --穿刺針情報
 SELECT
   ''実績詳細'' AS detail_id
   , ''穿刺針'' AS sbt_key
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
   , meq.unit AS e05
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
)
,select_consumption AS( --医材情報
 SELECT
   ''実績詳細'' AS detail_id
   , ''医材'' AS sbt_key
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
   , meq.unit AS e05
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
)
,select_special_blood_purification AS( --1次膜2次膜情報
 SELECT
   ''実績詳細'' AS detail_id
   , ''1次膜2次膜'' AS sbt_key
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
   , meq.unit AS e05
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
)
,select_rst_medi AS( --薬剤
 SELECT
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
   ,mmd.unit 
      AS e05
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
),
select_rst_medi2 AS(  --加算(患者)Ver2、加算(その他)その2Ver2、項目コメントVer2、透析コメント1~3Ver2
SELECT
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
        UNION all
        
	    SELECT --抗凝固剤
	    detail_id
	    ,sbt_key
	    , e01
	    , e02
	    , e03
	    , e04
	    , (SELECT value FROM coop_ini_info WHERE key2 = concat(e03, e05)) AS e05
	    , e06
	    , e07
	    , e08
	    , e09
	    from select_koucoagulant
          
        UNION ALL
	    
        SELECT --薬剤
	    detail_id
	    ,kinds
	    , e01
	    , e02
	    , e03
	    , e04
	    , (SELECT value FROM coop_ini_info WHERE key2 = concat(e03, e05)) AS e05
	    , e06
	    , e07
	    , e08
	    , e09
	    from select_rst_medi
	    
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
	    
        SELECT --穿刺針情報
	    detail_id
	    ,sbt_key
	    , e01
	    , e02
	    , e03
	    , e04
	    , (SELECT value FROM coop_ini_info WHERE key2 = concat(e03, e05)) AS e05
	    , e06
	    , e07
	    , e08
	    , e09
	    from select_puncture_needle
	    
        UNION ALL
        SELECT--医材情報
  	    detail_id
	    ,sbt_key
	    , e01
	    , e02
	    , e03
	    , e04
	    , (SELECT value FROM coop_ini_info WHERE key2 = concat(e03, e05)) AS e05
	    , e06
	    , e07
	    , e08
	    , e09
	    from select_consumption
	    
        UNION ALL
        SELECT--1次膜2次膜情報
	    detail_id
	    ,sbt_key
	    , e01
	    , e02
	    , e03
	    , e04
	    , (SELECT value FROM coop_ini_info WHERE key2 = concat(e03, e05)) AS e05
	    , e06
	    , e07
	    , e08
	    , e09
	    from select_special_blood_purification
	    
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
        SELECT--加算(患者)Ver2、加算(その他)その2Ver2、項目コメントVer2、透析コメント1~3Ver2
         detail_id
	    ,kinds
	    , e01
	    , e02
	    , e03
	    , e04
	    , (SELECT value FROM coop_ini_info WHERE key2 = concat(e03, e05)) AS e05
	    , e06
	    , e07
	    , e08
	    , e09
	    from select_rst_medi2

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