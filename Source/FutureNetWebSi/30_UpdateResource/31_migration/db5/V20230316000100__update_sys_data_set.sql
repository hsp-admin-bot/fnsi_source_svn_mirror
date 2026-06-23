delete from ntss.sys_data_set where sql_cd = '-103';
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-103, 'WITH dialysis_item_send AS (-- 透析項目送信
 SELECT
  info ->> ''key2'' AS key2,
  COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS VALUE
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
 WHERE
  facility_cd = @facilityCd
  AND is_del = ''0''
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
  AND COALESCE(info->>''key0'','''') = @key0
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
  AND info ->> ''key1'' = ''DIALYSIS_ITEM_SEND''
)
, do_ord_main AS (
SELECT * FROM ord_main as ord_i
WHERE ord_i.ord_no = @ordNo AND ord_i.facility_cd = @facilityCd
)
,item_set_info AS (
  --連携設定の項目設定値
  SELECT
    info->>''key2'' AS key2
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS value
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info ->> ''key1'' = ''DIALYSIS_ITEM_SEND''
)
, item_sort_info AS (
  --連携設定「項目情報部出力順（予約/実績送信用）」の設定値
  SELECT
    info->>''key2'' AS key2
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS value
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info->>''key1'' = ''DIALYSIS_ITEM_SORT''
)
, ind_set_medicine_resolve_info AS (
  --セット薬剤の扱いの設定値
  SELECT
    info ->> ''key2'' AS key2
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS value
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info ->> ''key1'' = ''IND_SET_MEDICINE_RESOLVE''
)
, solution_cnt AS (
  --透析液取得件数
  SELECT
    COUNT(*) AS cnt
  FROM
    do_ord_main ord
  LEFT OUTER JOIN
     mst_medicine mmd ON mmd.medicine_cd = TO_NUMBER(ord.ind_cond_info->''15''->>''value'',''999999999999'')
  WHERE
    (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''SOLUTION_RESOLVE_MODE'') = ''0''
)
, dialysis_item_procedure_tag_info AS (
  --手技タグ名称の設定値
  SELECT
    info ->> ''key2'' AS key2
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS value
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info ->> ''key1'' = ''DIALYSIS_ITEM_PROCEDURE_TAG''
)
,  device AS (
        SELECT device_mode
        FROM mst_treatment mst JOIN do_ord_main ord
        ON ord.ind_treatment_cd = mst.treatment_cd
)
, fji_com_info AS (-- 富士通共通設定
 SELECT
  info ->> ''key2'' AS key2,
  COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS VALUE
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
 WHERE
  facility_cd = @facilityCd
  AND is_del = ''0''
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
  AND COALESCE(info->>''key0'','''') = @key0
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
  AND info ->> ''key1'' = ''FJI_COM_INFO''
 )
, dialyis_item_sort AS (-- 項目情報部出力順（予約/実績送信用）
 SELECT
  info ->> ''key2'' AS key2,
  COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS VALUE
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
 WHERE
  facility_cd =  @facilityCd
  AND is_del = ''0''
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
  AND COALESCE(info->>''key0'','''') = @key0
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
  AND info ->> ''key1'' = ''DIALYSIS_ITEM_SORT''
 )
, conv_teart_item_send_out AS ( -- 浄化方法変換（予約/実績送信用：外来）
 SELECT
  info ->> ''key2'' AS key2,
  UNNEST ( STRING_TO_ARRAY( ( COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) ), '','' ) ) AS VALUE
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
 WHERE
  facility_cd = @facilityCd
  AND is_del = ''0''
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
  AND COALESCE(info->>''key0'','''') = @key0
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
  AND info ->> ''key1'' = ''CONV_TREAT_ITEM_SEND_OUT''
 )
, conv_treat_item_send_in AS ( -- 浄化方法変換（予約/実績送信用：入院）
 SELECT
  info ->> ''key2'' AS key2,
  UNNEST ( string_to_array( COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ), '','' ) ) AS VALUE
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
 WHERE
  facility_cd = @facilityCd
  AND is_del = ''0''
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
  AND COALESCE(info->>''key0'','''') = @key0
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
  AND info ->> ''key1'' = ''CONV_TREAT_ITEM_SEND_IN''
 )
, dialysis_send AS ( -- 透析发送
 SELECT
  info ->> ''key2'' AS key2,
  COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS VALUE
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
 WHERE
  facility_cd = @facilityCd
  AND is_del = ''0''
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
  AND COALESCE(info->>''key0'','''') = @key0
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
  AND info ->> ''key1'' = ''DIALYSIS_SEND''
 )
, int_set_medicine_resolve AS ( -- 薬剤分類が「透析液」のもの。セット薬剤の扱いについては、連携設定に従う。
 SELECT
  info ->> ''key2'' AS key2,
  COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS VALUE
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
 WHERE
  facility_cd = @facilityCd
  AND is_del = ''0''
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
  AND COALESCE(info->>''key0'','''') = @key0
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
  AND info ->> ''key1'' = ''IND_SET_MEDICINE_RESOLVE''
 )
, DIALYSIS_ITEM_PROCEDURE_TAG AS( -- 連携設定「手技あり１～１０－手技コード」
  SELECT
   info ->> ''key2'' AS key2,
   COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS VALUE
  FROM
   mst_coop_ini AS ini
   CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
  WHERE
   facility_cd = @facilityCd
   AND is_del = ''0''
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
  AND COALESCE(info->>''key0'','''') = @key0
  -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
   AND info ->> ''key1'' = ''DIALYSIS_ITEM_PROCEDURE_TAG''
 )
 , bed_conv as(
    SELECT
    0 AS order_no,
        to_number(COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ), ''9999999999'') AS bed_conv
     FROM
        mst_coop_ini AS ini
   CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
     WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
        AND info ->> ''key1'' = ''FJI_COM_INFO''
        AND info ->> ''key2'' = ''BED_CODE_CONV'' UNION
    SELECT
        1 AS order_no,
        1 AS bed_conv
    ORDER BY
        order_no ASC
        LIMIT 1
)
, dialysis_difficulty_info AS (
    SELECT ROW_NUMBER
        ( ) OVER ( ) AS row_no,
        details
    FROM
        ( SELECT regexp_split_to_table( ''182''
, '','' ) AS details ) AS T)
, do_order_data_equip_from AS ( --施設設定106设置获取
SELECT ROW_NUMBER () OVER () AS no2, TO_NUMBER(datt.a1  :: text, ''999999999999'') AS ora
FROM (SELECT TO_NUMBER((unnest(string_to_array((
SELECT mst_f.value AS rtt
  FROM mst_facility_setting AS mst_f
  WHERE mst_f.facility_setting_no = ''3006'' AND mst_f.facility_cd = @facilityCd
),'',''))), ''999999999999'') AS a1) AS datt)
, do_mstmeq_cd AS (--医療材料マスタ表示顺
SELECT index_no AS meq_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_code, order_cd ->> ''name'' AS meq_code_name
FROM mst_selector
    CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd
AND master_physical_name = ''mst_equipment'' )
, do_mstmeq_class_cd AS (--医療材料分類マスタ表示顺
SELECT index_no AS meq_class_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_class_code, order_cd ->> ''name'' AS meq_class_code_name
FROM mst_selector
    CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd
AND master_physical_name = ''mst_equipment_class'' )
, do_order_data_from AS (--施設設定107设置获取
SELECT ROW_NUMBER () OVER () AS no2, datt.a1
FROM (SELECT TO_NUMBER((unnest(string_to_array((
SELECT mst_f.value AS rtt
  FROM mst_facility_setting AS mst_f
  WHERE mst_f.facility_setting_no = ''3007'' AND mst_f.facility_cd = @facilityCd
),'',''))), ''999999999999'') AS a1) AS datt)
, do_medicine_mix_cd AS (
SELECT index_no AS medi_mix_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_mix_code, order_cd ->> ''name'' AS medi_mix_code_name
FROM mst_selector
     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd

   AND master_physical_name = ''mst_medicine_mix''
)
, do_mstmedi_cd AS (
SELECT index_no AS medi_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_code, order_cd ->> ''name'' AS medi_code_name
FROM mst_selector
     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd

   AND master_physical_name = ''mst_medicine''
)
, do_mstmedi_class_cd AS (
SELECT index_no AS medi_class_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_class_code, order_cd ->> ''name'' AS medi_class_code_name
FROM mst_selector
     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd

   AND master_physical_name = ''mst_medicine_class''
)
, do_mst_timing AS (
SELECT index_no AS timing_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS timing_code, order_cd ->> ''name'' AS timing_code_name
FROM mst_selector
     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd

   AND master_physical_name = ''mst_medicate_timing''
)
, do_mst_procedure AS (
SELECT index_no AS procedure_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS procedure_code, order_cd ->> ''name'' AS procedure_code_name
FROM mst_selector
     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd

   AND master_physical_name = ''mst_procedure''
)
,kou_coag_procedur_falg AS (
    SELECT
        1 AS ctl
    FROM
        (
        SELECT COUNT
            ( * ) AS cnt
        FROM
            ind_set_medicine_resolve_info
        WHERE
            ( key2 IN ( ''KOU_COAG_PROCEDURE_ATTR'' ) AND ( ( VALUE IS NOT NULL ) AND VALUE <> '''' ) AND VALUE <> ''0'' )
            OR ( key2 IN ( ''KOU_COAG_PROCEDURE_CODE'' ) AND ( ( VALUE IS NOT NULL ) AND VALUE <> '''' ) AND VALUE <> ''0'' )
            OR ( key2 IN ( ''KOU_COAG_PROCEDURE_NAME'' ) AND ( ( VALUE IS NOT NULL ) AND VALUE <> '''' ) AND VALUE <> ''0'' )
        ) T
    WHERE
        cnt = 3 UNION
    SELECT
        2 AS ctl
    ORDER BY
        ctl
        LIMIT 1
    )
, kou_coag_procedur_data AS(
    SELECT
    VALUE
    FROM
        (
        SELECT
            info ->> ''key2'' AS key2,
            COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS
        VALUE

        FROM
            mst_coop_ini AS ini
            CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: JSON ) info
        WHERE
            facility_cd = @facilityCd
            AND is_del = ''0''
            -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
            AND COALESCE ( info ->> ''key0'', '''' ) = @key0
            -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
        AND info ->> ''key1'' = ''DIALYSIS_ITEM_PROCEDURE_TAG''
        ) T
    WHERE
        key2 = ( SELECT VALUE FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_PROCEDURE_CODE'' )
        LIMIT 1
)
, data_middle_all AS (
SELECT
 all_cost.*
FROM
 (SELECT
    --①ベッドＮＯ
    ''予約詳細'' AS detail_id,
    --項目コード
    COALESCE(
    CASE
      WHEN (ord.ind_bed_cd IS NULL or ord.ind_bed_cd = 0)
        THEN ''V9999999''
      ELSE
        CASE
          WHEN COALESCE((SELECT value FROM fji_com_info WHERE key2 = ''BED_CODE_CONV''), '''') = ''1''
            THEN mbd.in_hospital_cd_1
          WHEN COALESCE((SELECT value FROM fji_com_info WHERE key2 = ''BED_CODE_CONV''), '''') = ''2''
            THEN mbd.in_hospital_cd_2
          ELSE ''V9999999''
        END
    END, '''') AS e01,
    --項目属性
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_BED_NO_ATTR''), '''') AS e02,
    --項目名称
    COALESCE(mbd.bed_name, ''ベッド未登録'') AS e03,
    --数量
    ''0000000.000'' AS e04,
    --選択単位フラグ
    ''0'' AS e05,
    --単位コード
    '''' AS e06,
    --単位名称
    '''' AS e07,
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_BED_NO_TAG''), '''') AS e08,
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_BED_NO''), '''') AS e09 ,
        '''' as sorttag1,
        '''' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_bed mbd ON mbd.bed_cd = ord.ind_bed_cd
UNION
SELECT
    --②浄化方法
    ''予約詳細'' AS detail_id,
    --項目コード
    CASE
    --患者の入外区分が外来の場合
     WHEN @inOut = ''0'' THEN COALESCE(mtt.in_hospital_cd_a1, '''')
    --患者の入外区分が入院の場合
    WHEN @inOut = ''1'' THEN COALESCE(NULLIF(mtt.in_hospital_cd_a2, ''''), mtt.in_hospital_cd_a1, '''')
    ELSE '''' END AS e01,
    --項目属性
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_TREAT_ATTR''), '''') AS e02,
    --項目名称
    COALESCE(mtt.treatment_name, '''') AS e03,
    --数量
    ''0000000.000'' AS e04,
    --選択単位フラグ
    ''0'' AS e05,
    --単位コード
    '''' AS e06,
    --単位名称
    '''' AS e07,
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_TREAT_TAG''), '''') AS e08,
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_TREAT''), '''') AS e09,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_treatment mtt ON mtt.treatment_cd = ord.ind_treatment_cd
UNION
SELECT
    --③希望開始時刻
    ''予約詳細'' AS detail_id,
    --項目コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_START_DATE_TIME_CODE''), '''') AS e01,
    --項目属性
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_START_DATE_TIME_ATTR''), '''') AS e02,
    --項目名称
    SUBSTRING(ord.ind_treat_start_time,1,2) || '':'' || SUBSTRING(ord.ind_treat_start_time,3,2) AS e03,
    --数量
    ''0000000.000'' AS e04,
    --選択単位フラグ
    ''0'' AS e05,
    --単位コード
    '''' AS e06,
    --単位名称
    '''' AS e07,
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_START_DATE_TIME_TAG''), '''') AS e08,
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_START_DATE_TIME''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
UNION
SELECT
    --④希望終了時刻
    ''予約詳細'' AS detail_id,
    --項目コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_END_DATE_TIME_CODE''), '''') AS e01,
    --項目属性
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_END_DATE_TIME_ATTR''), '''') AS e02,
    --項目名称
    TO_CHAR(TO_TIMESTAMP(ord.treat_date||'' ''||SUBSTRING(ord.ind_treat_start_time,1,2)||'':''||SUBSTRING(ord.ind_treat_start_time,3,2)||'':00'', ''YYYYMMDD HH24:MI:SS'') + (interval ''1minute'' * TO_NUMBER(ord.ind_cond_info->''1''->>''value'',''9999'')) ,''HH24:MI'') AS e03,
    --数量
    ''0000000.000'' AS e04,
    --選択単位フラグ
    ''0'' AS e05,
    --単位コード
    '''' AS e06,
    --単位名称
    '''' AS e07,
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_END_DATE_TIME_TAG''), '''') AS e08,
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_END_DATE_TIME''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
UNION
SELECT
    --⑤予定所要時間
    ''予約詳細'' AS detail_id,
    --項目コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SCHE_TIME_CODE''), '''') AS e01,
    --項目属性
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SCHE_TIME_ATTR''), '''') AS e02,
    --項目名称
    RIGHT(''00''||TRUNC(TO_NUMBER(ord.ind_cond_info->''1''->>''value'',''9999'')/60,0),2)||'':''||RIGHT(''00''||MOD(TO_NUMBER(ord.ind_cond_info->''1''->>''value'',''9999''),60),2) AS e03,
    --数量
    ''0000000.000'' AS e04,
    --選択単位フラグ
    ''0'' AS e05,
    --単位コード
    '''' AS e06,
    --単位名称
    '''' AS e07,
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SCHE_TIME_TAG''), '''') AS e08,
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_SCHE_TIME''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
UNION
SELECT
    --⑥目標体重
    ''予約詳細'' AS detail_id,
    --項目コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_TARGET_WEIGHT_CODE''), '''') AS e01,
    --項目属性
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_TARGET_WEIGHT_ATTR''), '''') AS e02,
    --項目名称
    COALESCE(SUBSTRING(ord.treat_date, 1, 4) || ''/'' || SUBSTRING(ord.treat_date, 5, 2) || ''/'' || SUBSTRING(ord.treat_date, 7, 2), '''') AS e03,
    --数量
    CASE
    --DWと同じの場合
    WHEN TO_NUMBER(COALESCE(ord.ind_cond_info ->''3''->>''value'', ''0''),''9999999.999'') = -1
      THEN TO_CHAR(TO_NUMBER(COALESCE(ord.ind_cond_info ->''3''->>''value_dw'', ''0''),''9999999.999'') ,''FM0999999.990'')
    ELSE TO_CHAR(TO_NUMBER(COALESCE(ord.ind_cond_info ->''3''->>''value'', ''0''),''9999999.999'') ,''FM0999999.990'') END AS e04,
    --選択単位フラグ
    ''1'' AS e05,
    --単位コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_TARGET_WEIGHT_UNIT''), '''') AS e06,
    --単位名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_TARGET_WEIGHT_UNIT''), '''') AS e07,
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_TARGET_WEIGHT_TAG''), '''') as e08,
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_TARGET_WEIGHT''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
UNION
SELECT
    --⑦ドライウェイト
    ''予約詳細'' AS detail_id,
    --項目コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_DRY_WEIGHT_CODE''), '''') AS e01,
    --項目属性
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_DRY_WEIGHT_ATTR''), '''') AS e02,
    --項目名称
    COALESCE(SUBSTRING(ord.treat_date, 1, 4) || ''/'' || SUBSTRING(ord.treat_date, 5, 2) || ''/'' || SUBSTRING(ord.treat_date, 7, 2), '''') AS e03,
    --数量
    TO_CHAR(TO_NUMBER(COALESCE(ord.ind_cond_info->''3''->>''value_dw'', ''0''),''9999999.999'') ,''FM0999999.990'') AS e04,
    --選択単位フラグ
    ''1'' AS e05,
    --単位コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_DRY_WEIGHT_UNIT''), '''') AS e06,
    --単位名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_DRY_WEIGHT_UNIT''), '''') AS e07,
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_DRY_WEIGHT_TAG''), '''') AS e08,
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_DRY_WEIGHT''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
UNION
SELECT
    --⑧ＶＡ
    ''予約詳細'' AS detail_id,
    --項目コード
    COALESCE(mva.in_hospital_cd_1, '''') AS e01,
    --項目属性
    COALESCE(mva.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SHUNT_PART_ATTR''), '''')) AS e02,
    --項目名称
    COALESCE(mva.va_name, '''') AS e03,
    --数量
    ''0000000.000'' AS e04,
    --選択単位フラグ
    ''0'' AS e05,
    --単位コード
    '''' AS e06,
    --単位名称
    '''' AS e07,
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SHUNT_PART_TAG''), '''') AS e08,
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_SHUNT_PART''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_va mva ON mva.va_cd = TO_NUMBER(ord.ind_cond_info->''2''->>''value'',''999999999999'')
UNION
SELECT
    --⑨透析器
    ''予約詳細'' AS detail_id,
    --項目コード
    COALESCE(mdz.in_hospital_cd_1, '''') AS e01,
    --項目属性
    COALESCE(mdz.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_DIAL_INST_ATTR''), '''')) AS e02,
    --項目名称
    COALESCE(mdz.model_number, '''') AS e03,
    --数量
    ''0000001.000'' AS e04,
    --選択単位フラグ
    ''1'' AS e05,
    --単位コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_DIAL_INST_UNIT''), '''') AS e06,
    --単位名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_DIAL_INST_UNIT''), '''') AS e07,
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_DIAL_INST_TAG''), '''') AS e08,
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_DIAL_INST''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_dialyzer mdz ON mdz.dialyzer_cd = TO_NUMBER(ord.ind_cond_info->''5''->>''value'',''999999999999'')
UNION
SELECT
    --⑩吸着器
    ''予約詳細'' AS detail_id,
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01,
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_ADSORPTION_INST_ATTR''), '''')) AS e02,
    --項目名称
    COALESCE(meq.equipment_name, '''') AS e03,
    --数量
    ''0000001.000'' AS e04,
    --選択単位フラグ
    CASE WHEN meq.unit IS NULL OR meq.unit = ''''
    THEN ''0'' ELSE ''1'' END AS e05,
    --単位コード
    COALESCE(meq.unit, '''') AS e06,
    --単位名称
    COALESCE(meq.unit, '''') AS e07,
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_ADSORPTION_INST_TAG''), '''') AS e08,
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_FILM''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_equipment meq ON meq.equipment_cd = TO_NUMBER(ord.ind_cond_info->''6''->>''value'',''999999999999'')
UNION
SELECT
    --⑪1次膜(吸着器or血漿分離器)
    ''予約詳細'' AS detail_id,
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01,
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_FIRST_FILM_ATTR''), '''')) AS e02,
    --項目名称
    COALESCE(meq.equipment_name, '''') AS e03,
    --数量
    ''0000001.000'' AS e04,
    --選択単位フラグ
    CASE WHEN meq.unit IS NULL OR meq.unit = ''''
    THEN ''0'' ELSE ''1'' END AS e05,
    --単位コード
    COALESCE(meq.unit, '''') AS e06,
    --単位名称
    COALESCE(meq.unit, '''') AS e07,
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_FIRST_FILM_TAG''), '''') AS e08,
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_FIRST_FILM''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_equipment meq ON meq.equipment_cd = TO_NUMBER(ord.ind_cond_info->''7''->>''value'',''999999999999'')
UNION
SELECT
    --⑫2次膜(吸着器or血漿分離器)
    ''予約詳細'' AS detail_id,
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01,
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SECOND_FILM_ATTR''), '''')) AS e02,
    --項目名称
    COALESCE(meq.equipment_name, '''') AS e03,
    --数量
    ''0000001.000'' AS e04,
    --選択単位フラグ
    CASE WHEN meq.unit IS NULL OR meq.unit = ''''
    THEN ''0'' ELSE ''1'' END AS e05,
    --単位コード
    COALESCE(meq.unit, '''') AS e06,
    --単位名称
    COALESCE(meq.unit, '''') AS e07,
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SECOND_FILM_TAG''), '''') AS e08,
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_SECOND_FILM''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_equipment meq ON meq.equipment_cd = TO_NUMBER(ord.ind_cond_info->''8''->>''value'',''999999999999'')
UNION
--⑬医療材料（回路・針など）
SELECT
    --A針情報
    ''予約詳細'' AS detail_id,
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01,
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_EQUIP_ATTR''), '''')) AS e02,
    --項目名称
    COALESCE(meq.equipment_name, '''') AS e03,
    --数量
    ''0000001.000'' AS e04,
    --選択単位フラグ
    CASE WHEN meq.unit IS NULL OR meq.unit = ''''
    THEN ''0'' ELSE ''1'' END AS e05,
    --単位コード
    COALESCE(meq.unit, '''') AS e06,
    --単位名称
    COALESCE(meq.unit, '''') AS e07,
    --タグ名称
    COALESCE(meqc.class_name, '''') AS e08,
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_EQUIP''), '''') AS e09 ,
    ''1'' as sorttag1,
    ''18'' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_equipment as meq ON meq.equipment_cd = TO_NUMBER(ord.ind_cond_info->''9''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_equipment_class meqc ON meq.class_cd = meqc.class_cd
WHERE
    ord.ind_cond_info->''9''->>''value'' IS NOT NULL
UNION
SELECT
    --V針情報
    ''予約詳細'' AS detail_id,
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01,
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_EQUIP_ATTR''), '''')) AS e02,
    --項目名称
    COALESCE(meq.equipment_name, '''') AS e03,
    --数量
    ''0000001.000'' AS e04,
    --選択単位フラグ
    CASE WHEN meq.unit IS NULL OR meq.unit = ''''
    THEN ''0'' ELSE ''1'' END AS e05,
    --単位コード
    COALESCE(meq.unit, '''') AS e06,
    --単位名称
    COALESCE(meq.unit, '''') AS e07,
    --タグ名称
    COALESCE(meqc.class_name, '''') AS e08,
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_EQUIP''), '''') AS e09 ,
    ''2'' as sorttag1,
    ''18'' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_equipment as meq ON meq.equipment_cd = TO_NUMBER(ord.ind_cond_info->''10''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_equipment_class meqc ON meq.class_cd = meqc.class_cd
WHERE
    ord.ind_cond_info->''10''->>''value'' IS NOT NULL
UNION
SELECT
    --SN針情報
    ''予約詳細'' AS detail_id,
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01,
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_EQUIP_ATTR''), '''')) AS e02,
    --項目名称
    COALESCE(meq.equipment_name, '''') AS e03,
    --数量
    ''0000001.000'' AS e04,
    --選択単位フラグ
    CASE WHEN meq.unit IS NULL OR meq.unit = ''''
    THEN ''0'' ELSE ''1'' END AS e05,
    --単位コード
    COALESCE(meq.unit, '''') AS e06,
    --単位名称
    COALESCE(meq.unit, '''') AS e07,
    --タグ名称
    COALESCE(meqc.class_name, '''') AS e08,
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_EQUIP''), '''') AS e09 ,
    ''3'' as sorttag1,
    ''18'' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_equipment as meq ON meq.equipment_cd = TO_NUMBER(ord.ind_cond_info->''11''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_equipment_class meqc ON meq.class_cd = meqc.class_cd
WHERE
    ord.ind_cond_info->''11''->>''value'' IS NOT NULL
UNION
SELECT
    --血液回路情報
    ''予約詳細'' AS detail_id,
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01,
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_EQUIP_ATTR''), '''')) AS e02,
    --項目名称
    COALESCE(meq.equipment_name, '''') AS e03,
    --数量
    ''0000001.000'' AS e04,
    --選択単位フラグ
    CASE WHEN meq.unit IS NULL OR meq.unit = ''''
    THEN ''0'' ELSE ''1'' END AS e05,
    --単位コード
    COALESCE(meq.unit, '''') AS e06,
    --単位名称
    COALESCE(meq.unit, '''') AS e07,
    --タグ名称
    COALESCE(meqc.class_name, '''') AS e08,
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_EQUIP''), '''') AS e09 ,
    ''4'' as sorttag1,
    ''18'' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_equipment meq ON meq.equipment_cd = TO_NUMBER(ord.ind_cond_info->''13''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_equipment_class meqc ON meq.class_cd = meqc.class_cd
WHERE
    ord.ind_cond_info->''13''->>''value'' IS NOT NULL
UNION
SELECT
    --⑭透析液
    ''予約詳細'' AS detail_id,
    --項目コード
    --CASE WHEN LENGTH(TRIM(mmd.in_hospital_cd_1)) > 8 THEN RIGHT(TRIM(mmd.in_hospital_cd_1), 8) ELSE RPAD(TRIM(mmd.in_hospital_cd_1), 8, '' '') END AS e01,
        COALESCE(mmd.in_hospital_cd_1, '''') AS e01,
    --項目属性
    COALESCE(mmd.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SOLUTION_ATTR''), '''')) AS e02,
    --項目名称
    COALESCE(mmd.medicine_name, '''') AS e03,
    --数量
    CASE
      WHEN ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''0'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''0'') OR
           ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''0'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''2'') OR
           ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''0'') OR
           ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''2'') OR
                     ((SELECT device_mode FROM device) NOT IN (7, 8, 10))
        THEN
          TO_CHAR(TO_NUMBER(COALESCE(ord.ind_cond_info->''17''->>''value'',''0''), ''9999999.999''), ''FM0999999.990'')
      WHEN ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''0'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''1'') OR
           ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''1'') AND
                     ((SELECT device_mode FROM device) IN (7, 8, 10))
        THEN
          TO_CHAR(TO_NUMBER(COALESCE(ord.ind_cond_info->''17''->>''value'',''0''), ''9999999.999'') + TO_NUMBER(COALESCE(ord.ind_cond_info->''22''->>''value'',''0''), ''9999999.999''), ''FM0999999.990'')
      ELSE ''0000000.000''
    END AS e04,
    --選択単位フラグ
    ''1'' AS e05,
    --単位コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SOLUTION_UNIT''), '''') AS e06,
    --単位名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SOLUTION_UNIT''), '''') AS e07,
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SOLUTION_TAG''), '''') AS e08,
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_SOLUTION''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_medicine mmd ON mmd.medicine_cd = TO_NUMBER(ord.ind_cond_info->''15''->>''value'',''999999999999'')
--WHERE
--     AND (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''SOLUTION_RESOLVE_MODE'') = ''0''
UNION
SELECT
    --⑮置換液（補液）
    ''予約詳細'' AS detail_id,
    --項目コード
    --CASE WHEN LENGTH(TRIM(mmd.in_hospital_cd_1)) > 8 THEN RIGHT(TRIM(mmd.in_hospital_cd_1), 8) ELSE COALESCE(TRIM(mmd.in_hospital_cd_1), '''') END AS e01,
        COALESCE(mmd.in_hospital_cd_1, '''') AS e01,
    --項目属性
    COALESCE(mmd.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_REPLACE_ATTR''), '''')) AS e02,
    --項目名称
    COALESCE(mmd.medicine_name, '''') AS e03,
    --数量
    TO_CHAR(TO_NUMBER(COALESCE(ord.ind_cond_info->''22''->>''value'',''0''), ''9999999.999''), ''FM0999999.990'') AS e04,
    --選択単位フラグ
    ''1'' AS e05,
    --単位コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_REPLACE_UNIT''), '''') AS e06,
    --単位名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_REPLACE_UNIT''), '''') AS e07,
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_REPLACE_TAG''), '''') AS e08,
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_REPLACE''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_medicine mmd ON mmd.medicine_cd = TO_NUMBER(ord.ind_cond_info->''19''->>''value'',''999999999999'')
WHERE
--     AND (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''REPLACE_RESOLVE_MODE'') = ''0''
    ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''0''
    OR ((SELECT device_mode FROM device) NOT IN (7, 8, 10)))
UNION
SELECT
    --⑯抗凝固剤・初回
    ''予約詳細'' AS detail_id,
    --項目コード
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE  mmd.in_hospital_cd_1 END), '''') AS e01,
    --項目属性
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END), COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_KOU_COAG_ONESHOT_ATTR''), '''')) AS e02,
    --項目名称
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE mmd.medicine_name END), '''') AS e03,
    --数量
    TO_CHAR(TO_NUMBER(COALESCE(ord.ind_cond_info->''26''->>''value'', ''0''), ''9999999.999''), ''FM0999999.990'') AS e04,
    --選択単位フラグ
    CASE
      WHEN (CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) IS NULL OR
           (CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) = ''''
        THEN ''0''
      ELSE
        CASE
          WHEN (SELECT value FROM item_set_info WHERE key2 = ''ITEM_KOU_COAG_ONESHOT_UNIT_SEL'') = ''2''
            THEN ''2''
          ELSE ''1''
        END
    END AS e05,
    --単位コード
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e06,
    --単位名称
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' then mmx.unit ELSE mmd.unit END), '''') AS e07,
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_KOU_COAG_ONESHOT_TAG''), '''') AS e08,
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_KOU_COAG_ONESHOT''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_medicine mmd ON mmd.medicine_cd = TO_NUMBER(ord.ind_cond_info->''25''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_medicine_mix mmx ON mmx.medicine_mix_cd = TO_NUMBER(ord.ind_cond_info->''25''->>''value'',''999999999999'')
WHERE
    CASE WHEN (ord.ind_cond_info->''25''->>''medicine_type'' = ''2'') THEN ((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''0'' or
    (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'')
        ELSE ((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''0'' or
    (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'' or
    (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''2'') END
UNION
SELECT
    --⑰抗凝固剤・持続
    ''予約詳細'' AS detail_id,
    --項目コード
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE
        (CASE WHEN LENGTH(TRIM(mmd.in_hospital_cd_1)) > 8 THEN RIGHT(TRIM(mmd.in_hospital_cd_1), 8) ELSE RPAD(TRIM(mmd.in_hospital_cd_1), 8, '' '') END) END), '''') AS e01,
    --項目属性
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END), COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_KOU_COAG_ATTR''), '''')) AS e02,
    --項目名称
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE  mmd.medicine_name END), '''') AS e03,
    --数量
    TO_CHAR(TO_NUMBER(COALESCE(ord.ind_cond_info->''27''->>''value'', ''0''), ''9999999.999''), ''FM0999999.990'') AS e04,
    --選択単位フラグ
    CASE
      WHEN (CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) IS NULL OR
           (CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) = ''''
        THEN ''0''
      ELSE
        CASE
          WHEN (SELECT value FROM item_set_info WHERE key2 = ''ITEM_KOU_COAG_UNIT_SEL'') = ''2''
            THEN ''2''
          ELSE ''1''
        END
    END AS e05,
    --単位コード
    CASE
      WHEN (SELECT value FROM item_set_info WHERE key2 = ''ADD_UNIT_FLG'') = ''1''
        THEN
          CASE
            WHEN ord.ind_cond_info->''25''->>''medicine_type'' = ''2''
              THEN
                CASE
                  WHEN mmx.unit IS NULL OR mmx.unit = ''''
                    THEN ''''
                  ELSE mmx.unit || ''/h''
                END
            ELSE
              CASE
                WHEN mmd.unit IS NULL OR mmd.unit = ''''
                  THEN ''''
                ELSE mmd.unit || ''/h''
              END
          END
      ELSE
        CASE
          WHEN ord.ind_cond_info->''25''->>''medicine_type'' = ''2''
            THEN
              COALESCE(mmx.unit, '''')
          ELSE
            COALESCE(mmd.unit, '''')
        END
    END AS e06,
    --単位名称
    CASE
      WHEN (SELECT value FROM item_set_info WHERE key2 = ''ADD_UNIT_FLG'') = ''1''
        THEN
          CASE
            WHEN ord.ind_cond_info->''25''->>''medicine_type'' = ''2''
              THEN
                CASE
                  WHEN mmx.unit IS NULL OR mmx.unit = ''''
                    THEN ''''
                  ELSE mmx.unit || ''/h''
                END
            ELSE
              CASE
                WHEN mmd.unit IS NULL OR mmd.unit = ''''
                  THEN ''''
                ELSE mmd.unit || ''/h''
              END
          END
      ELSE
        CASE
          WHEN ord.ind_cond_info->''25''->>''medicine_type'' = ''2''
            THEN
              COALESCE(mmx.unit, '''')
          ELSE
            COALESCE(mmd.unit, '''')
        END
    END AS e07,
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_KOU_COAG_TAG''), '''') AS e08,
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_KOU_COAG''), '''') AS e09 ,
        '''' as sorttag1,
        '''' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_medicine mmd ON mmd.medicine_cd = TO_NUMBER(ord.ind_cond_info->''25''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_medicine_mix mmx ON mmx.medicine_mix_cd = TO_NUMBER(ord.ind_cond_info->''25''->>''value'',''999999999999'')
WHERE
    CASE WHEN (ord.ind_cond_info->''25''->>''medicine_type'' = ''2'') THEN ((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''0'' or
    (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'')
        ELSE ((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''0'' or
    (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'' or
    (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''2'') END
UNION
SELECT
    --⑱抗凝固剤・ＴＯＴＡＬ
    ''予約詳細'' AS detail_id,
    --項目コード
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE
        (CASE WHEN LENGTH(TRIM(mmd.in_hospital_cd_1)) > 8 THEN RIGHT(TRIM(mmd.in_hospital_cd_1), 8) ELSE RPAD(TRIM(mmd.in_hospital_cd_1), 8, '' '') END) END), '''') AS e01,
    --項目属性
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END), COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_KOU_COAG_TOTAL_ATTR''), '''')) AS e02,
    --項目名称
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE  mmd.medicine_name END), '''') AS e03,
    --数量
    TO_CHAR(TO_NUMBER(COALESCE(ord.ind_cond_info->''26''->>''value'', ''0''), ''9999999.999'') + TO_NUMBER(COALESCE(ord.ind_cond_info->''28''->>''value'',''0''), ''9999999.999''), ''FM0999999.990'') AS e04,
    --選択単位フラグ
    CASE
      WHEN (CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) IS NULL OR
           (CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) = ''''
        THEN ''0''
      ELSE
        CASE
          WHEN (SELECT value FROM item_set_info WHERE key2 = ''ITEM_KOU_COAG_TOTAL_UNIT_SEL'') = ''2''
            THEN ''2''
          ELSE ''1''
        END
    END AS e05,
    --単位コード
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e06,
    --単位名称
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' then mmx.unit ELSE mmd.unit END), '''') AS e07,
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_KOU_COAG_TOTAL_TAG''), '''') AS e08,
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_KOU_COAG_TOTAL''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_medicine mmd ON mmd.medicine_cd = TO_NUMBER(ord.ind_cond_info->''25''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_medicine_mix as mmx ON mmx.medicine_mix_cd = TO_NUMBER(ord.ind_cond_info->''25''->>''value'',''999999999999'')
WHERE
    CASE WHEN (ord.ind_cond_info->''25''->>''medicine_type'' = ''2'') THEN ((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''0'' or
    (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'')
        ELSE ((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''0'' or
    (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'' or
    (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''2'') END
UNION
SELECT
    --⑲血液流量
    ''予約詳細'' AS detail_id,
    --項目コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_BLOOD_AMT_CODE''), '''') AS e01,
    --項目属性
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_BLOOD_AMT_ATTR''), '''') AS e02,
    --項目名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_BLOOD_AMT_NAME''), '''') AS e03,
    --数量
    TO_CHAR(TO_NUMBER(ord.ind_cond_info->''14''->>''value'', ''9999999.999''), ''FM0999999.990'') AS e04,
    --選択単位フラグ
    ''1'' AS e05,
    --単位コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_BLOOD_AMT_UNIT''), '''') AS e06,
    --単位名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_BLOOD_AMT_UNIT''), '''') AS e07,
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_BLOOD_AMT_TAG''), '''') AS e08,
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_BLOOD_AMT''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
WHERE
    TO_NUMBER(ord.ind_cond_info->''14''->>''value'',''999999999999'') > 1
UNION
SELECT
    --⑳透析液流量
    ''予約詳細'' AS detail_id,
    --項目コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SOLUTION_AMT_CODE''), '''') AS e01,
    --項目属性
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SOLUTION_AMT_ATTR''), '''') AS e02,
    --項目名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SOLUTION_AMT_NAME''), '''') AS e03,
    --数量
    TO_CHAR(TO_NUMBER(ord.ind_cond_info->''16''->>''value'', ''9999999.999''), ''FM0999999.990'') AS e04,
    --選択単位フラグ
    ''1'' AS e05,
    --単位コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SOLUTION_AMT_UNIT''), '''') AS e06,
    --単位名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SOLUTION_AMT_UNIT''), '''') AS e07,
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_SOLUTION_AMT_TAG''), '''') AS e08,
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_SOLUTION_AMT''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
WHERE
    (SELECT cnt FROM solution_cnt) > 0
    AND TO_NUMBER(ord.ind_cond_info->''16''->>''value'',''999999999999'') > 1
UNION
SELECT
    --21補液量
    ''予約詳細'' AS detail_id,
    --項目コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_UP_LIQUID_CODE''), '''') AS e01,
    --項目属性
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_UP_LIQUID_ATTR''), '''') AS e02,
    --項目名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_UP_LIQUID_NAME''), '''') AS e03,
    --数量
    TO_CHAR(TO_NUMBER(ord.ind_cond_info->''20''->>''value'', ''9999999.999''), ''FM0999999.990'') AS e04,
    --選択単位フラグ
    ''1'' AS e05,
    --単位コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_UP_LIQUID_UNIT''), '''') AS e06,
    --単位名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_UP_LIQUID_UNIT''), '''') AS e07,
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_UP_LIQUID_TAG''), '''') AS e08,
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_UP_LIQUID''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    do_ord_main ord
WHERE
    TO_NUMBER(ord.ind_cond_info->''20''->>''value'',''999999999999'') > 1
--  AND (SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1''
    AND ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1'' OR ((SELECT device_mode FROM device) NOT IN (7, 8, 10)))
UNION
SELECT
    --24指示受け確認者1
    ''予約詳細'' AS detail_id,
    --項目コード
    COALESCE(@dispUser1Id :: TEXT, '''') AS e01,
    --項目属性
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_CHECK_STAFF_ATTR''), '''') AS e02,
    --項目名称
    COALESCE(@checkUser1Name :: TEXT, '''') AS e03,
    --数量
    ''0000000.000'' AS e04,
    --選択単位フラグ
    ''0'' AS e05,
    --単位コード
    '''' AS e06,
    --単位名称
    '''' AS e07,
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_CHECK_STAFF_TAG''), '''') AS e08,
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_CHECK_STAFF'')|| ''-1'', '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    pat_ind_approve pia
WHERE
    pia.ord_no = @ordNo
    AND (SELECT value FROM fji_com_info WHERE key2 = ''CHECK_STAFF_SEND_FLAG'') = ''1''
UNION
SELECT
    --24指示受け確認者2
    ''予約詳細'' AS detail_id,
    --項目コード
    COALESCE(@dispUser2Id :: TEXT, '''') AS e01,
    --項目属性
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_CHECK_STAFF_ATTR''), '''') AS e02,
    --項目名称
    COALESCE(@checkUser2Name :: TEXT, '''') AS e03,
    --数量
    ''0000000.000'' AS e04,
    --選択単位フラグ
    ''0'' AS e05,
    --単位コード
    '''' AS e06,
    --単位名称
    '''' AS e07,
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_CHECK_STAFF_TAG''), '''') AS e08,
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_CHECK_STAFF'') || ''-2'', '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2
FROM
    pat_ind_approve pia
WHERE
    pia.ord_no = @ordNo
    AND (SELECT value FROM fji_com_info WHERE key2 = ''CHECK_STAFF_SEND_FLAG'') = ''1''
 ) all_cost
WHERE
     all_cost.e09 IS NOT NULL AND all_cost.e09 <> ''''
 AND all_cost.e01 != '''' AND all_cost.e01 IS NOT NULL
)
,data_middle AS (
SELECT  --抗凝固剤
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE
    (CASE WHEN LENGTH(TRIM(mmd.in_hospital_cd_1)) > 8 THEN RIGHT(TRIM(mmd.in_hospital_cd_1), 8) ELSE        RPAD(TRIM(mmd.in_hospital_cd_1), 8, '' '') END) END), '''') AS yakuzai,
        ord.ind_cond_info->''25''->>''medicine_type'' AS medicine_type_yakuzai
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_medicine mmd ON mmd.medicine_cd = TO_NUMBER(ord.ind_cond_info->''25''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_medicine_mix as mmx ON mmx.medicine_mix_cd = TO_NUMBER(ord.ind_cond_info->''25''->>''value'',''999999999999'')
WHERE
    CASE WHEN (ord.ind_cond_info->''25''->>''medicine_type'' = ''2'') THEN ((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''0'' or
    (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'')
        ELSE ((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''0'' or
    (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'' or
    (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''2'') END
)
, equip_data as (--医療材料の選択
  select
    (SELECT in_hospital_cd_1 FROM mst_equipment WHERE equipment_cd = TO_NUMBER( eqp ->> ''cd'' :: text, ''999999999999'')) AS item_cd_s,
    COALESCE( TO_CHAR(TO_NUMBER(eqp ->> ''amount'',''9999999999.999''),''FM0999999.990'') ) AS e04
  FROM
    do_ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_equip_info :: json) with ordinality as tmp(eqp, json_idx)
)
, medi_data as(--薬剤の選択
select
     (SELECT in_hospital_cd_1 FROM mst_medicine WHERE medicine_cd = TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'')) AS item_cd_s,
    COALESCE( TO_CHAR(TO_NUMBER(medi ->> ''amount'',''9999999999''),''FM0999999.990'') )  AS e04
  FROM
    do_ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)

)
, do_medicine_mix_in_orders AS ( --調製薬剤内のソート順
SELECT medicine_mix_cd, in_idx AS login_ord_in_mm, TRIM(mmd.in_hospital_cd_1) AS item_cd_mm
FROM mst_medicine_mix AS mmx
        CROSS JOIN LATERAL json_array_elements(mmx.mix_info :: json) with ordinality as tmp(mmxd, in_idx)
        LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'')
WHERE mmx.facility_cd = @facilityCd
AND medicine_mix_cd IN (
        SELECT mix_M_cd
        FROM (SELECT TRIM(mmd.in_hospital_cd_1) AS item_cd,
             json_idx AS login_ord,
             TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'') AS mix_M_cd
FROM do_ord_main AS ord
         CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)
         LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''999999999999'')
         CROSS JOIN LATERAL json_array_elements(mmx.mix_info :: json ) mmxd
         LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'')
WHERE medi ->> ''medicine_type'' = ''2'') AS middl
        GROUP BY mix_M_cd)
)
, equip_all_data AS (
SELECT
    --22薬品手技(手技あり薬剤),単体薬剤
    TRIM(mmd.in_hospital_cd_1) AS e01,
    medi ->> ''no'' as sorttag1,
        medi ->> ''procedure_cd'' :: text AS procedure_cd_no,
        medi ->> ''cd'' :: text AS medi_cd_no,
    json_idx AS login_ord,
        0 AS ord_medicine_mix,
        TO_NUMBER( medi_class_code_order :: text, ''999999999999'' ) AS medi_class_M_cd,
        TO_NUMBER( medi ->> ''medicine_type'' :: text, ''999999999999'' ) AS medicine_type,
        TO_NUMBER( medi_code_order :: text, ''999999999999'' ) AS mix_M_cd,
        TO_NUMBER( timing_code_order :: text, ''999999999999'' ) AS timing_cd,
        TO_NUMBER( procedure_code_order :: text, ''999999999999'' ) AS procedure_cd,
        TO_NUMBER( medi ->> ''date_interval'' :: text, ''999999999999'' ) AS date_interval
FROM
    do_ord_main ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)
LEFT OUTER JOIN
    mst_medicine_mix mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_medicine mmd ON mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_procedure mp ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'',''999999999999'')
LEFT OUTER JOIN do_mstmedi_cd ON medi_code = TO_NUMBER(medi ->> ''cd'' :: text, ''999999999999'' )
LEFT OUTER JOIN do_mstmedi_class_cd ON medi_class_code = TO_NUMBER(mmd.class_cd :: text, ''999999999999'' )
LEFT OUTER JOIN do_mst_timing ON timing_code = TO_NUMBER(medi ->> ''timing_cd'' :: text, ''999999999999'' )
LEFT OUTER JOIN do_mst_procedure ON procedure_code = TO_NUMBER(medi ->> ''procedure_cd'' :: text, ''999999999999'' )
WHERE
    --患者経過総合ビューアの投与薬剤に手技が設定されている場合
    medi ->> ''procedure_cd'' IS NOT NULL
    AND medi->>''medicine_type'' = ''1''
    --連携設定 DIALYSIS_ITEM_PROCEDURE_TAGのkey2＝患者経過総合ビューアの投与薬剤に設定した手技の連携コード1がある場合
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) IS NOT NULL
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) <> ''''
UNION
SELECT
    --23処置薬品名(手技なし薬剤),単体薬剤
    TRIM(mmd.in_hospital_cd_1) AS e01,
    medi ->> ''no'' as sorttag1,
        medi ->> ''procedure_cd'' :: text AS procedure_cd_no,
        medi ->> ''cd'' :: text AS medi_cd_no,
    json_idx AS login_ord,
        0 AS ord_medicine_mix,
        TO_NUMBER( medi_class_code_order :: text, ''999999999999'' ) AS medi_class_M_cd,
        TO_NUMBER( medi ->> ''medicine_type'' :: text, ''999999999999'' ) AS medicine_type,
        TO_NUMBER( medi_code_order :: text, ''999999999999'' ) AS mix_M_cd,
        TO_NUMBER( timing_code_order :: text, ''999999999999'' ) AS timing_cd,
        TO_NUMBER( procedure_code_order :: text, ''999999999999'' ) AS procedure_cd,
        TO_NUMBER( medi ->> ''date_interval'' :: text, ''999999999999'' ) AS date_interval
FROM
    do_ord_main ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)
LEFT OUTER JOIN
    mst_medicine_mix mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_medicine mmd ON mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_procedure mp ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'',''999999999999'')
LEFT OUTER JOIN do_mstmedi_cd ON medi_code = TO_NUMBER(medi ->> ''cd'' :: text, ''999999999999'' )
LEFT OUTER JOIN do_mstmedi_class_cd ON medi_class_code = TO_NUMBER(mmd.class_cd :: text, ''999999999999'' )
LEFT OUTER JOIN do_mst_timing ON timing_code = TO_NUMBER(medi ->> ''timing_cd'' :: text, ''999999999999'' )
LEFT OUTER JOIN do_mst_procedure ON procedure_code = TO_NUMBER(medi ->> ''procedure_cd'' :: text, ''999999999999'' )
WHERE
    medi->>''medicine_type'' = ''1''
    AND (
      --患者経過総合ビューアの投与薬剤に手技が設定されていない場合
      medi ->> ''procedure_cd'' IS NULL
      OR(
        --患者経過総合ビューアの投与薬剤に手技が設定されている場合
        medi ->> ''procedure_cd'' IS NOT NULL
        --連携設定 DIALYSIS_ITEM_PROCEDURE_TAGのkey2＝患者経過総合ビューアの投与薬剤に設定した手技の連携コード1がない場合
        AND ((SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) IS  NULL
        OR (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) = '''')
      )
    )
UNION
SELECT
    --22薬品手技(手技あり薬剤),調製薬剤
        TRIM(mmd.in_hospital_cd_1) AS e01,
    (medi->>''no'') as sorttag1,
        medi ->> ''procedure_cd'' :: text AS procedure_cd_no,
        medi ->> ''cd'' :: text AS medi_cd_no,
        json_idx AS login_ord,
        (SELECT login_ord_in_mm FROM do_medicine_mix_in_orders
                            WHERE TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'') = medicine_mix_cd
                            AND TRIM(mmd.in_hospital_cd_1) = item_cd_mm) AS ord_medicine_mix,
        TO_NUMBER( medi_class_code_order :: text, ''999999999999'' ) AS medi_class_M_cd,
        TO_NUMBER( medi ->> ''medicine_type'' :: text, ''999999999999'' ) AS medicine_type,
        TO_NUMBER( medi_mix_code_order :: text, ''999999999999'' ) AS mix_M_cd,
        TO_NUMBER( timing_code_order :: text, ''999999999999'' ) AS timing_cd,
        TO_NUMBER( procedure_code_order :: text, ''999999999999'' ) AS procedure_cd,
        TO_NUMBER( medi ->> ''date_interval'' :: text, ''999999999999'' ) AS date_interval
FROM
        do_ord_main AS ord
        CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)
        LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''999999999999'' )
        LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''999999999999'' )
                    LEFT OUTER JOIN do_medicine_mix_cd ON medi_mix_code = mmx.medicine_mix_cd
                    LEFT OUTER JOIN do_mstmedi_class_cd ON medi_class_code = TO_NUMBER(mmx.class_cd :: text, ''999999999999'' )
                    LEFT OUTER JOIN do_mst_timing ON timing_code = TO_NUMBER(medi ->> ''timing_cd'' :: text, ''999999999999'' )
                    LEFT OUTER JOIN do_mst_procedure ON procedure_code = TO_NUMBER(medi ->> ''procedure_cd'' :: text, ''999999999999'' )
        CROSS JOIN LATERAL json_array_elements(mmx.mix_info :: json ) mmxd
        LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'' )
        LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd
WHERE
    --患者経過総合ビューアの投与薬剤に手技が設定されている場合
    medi ->> ''procedure_cd'' IS NOT NULL
    AND medi ->> ''medicine_type'' = ''2''
    --連携設定 DIALYSIS_ITEM_PROCEDURE_TAGのkey2＝患者経過総合ビューアの投与薬剤に設定した手技の連携コード1がある場合
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) IS NOT NULL
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) <> ''''
UNION
SELECT
    --23処置薬品名(手技なし薬剤),調製薬剤
    TRIM(mmd.in_hospital_cd_1) AS e01,
    (medi->>''no'') as sorttag1,
        medi ->> ''procedure_cd'' :: text AS procedure_cd_no,
        medi ->> ''cd'' :: text AS medi_cd_no,
        json_idx AS login_ord,
        (SELECT login_ord_in_mm FROM do_medicine_mix_in_orders
                            WHERE TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'') = medicine_mix_cd
                            AND TRIM(mmd.in_hospital_cd_1) = item_cd_mm) AS ord_medicine_mix,
        TO_NUMBER( medi_class_code_order :: text, ''999999999999'' ) AS medi_class_M_cd,
        TO_NUMBER( medi ->> ''medicine_type'' :: text, ''999999999999'' ) AS medicine_type,
        TO_NUMBER( medi_mix_code_order :: text, ''999999999999'' ) AS mix_M_cd,
        TO_NUMBER( timing_code_order :: text, ''999999999999'' ) AS timing_cd,
        TO_NUMBER( procedure_code_order :: text, ''999999999999'' ) AS procedure_cd,
        TO_NUMBER( medi ->> ''date_interval'' :: text, ''999999999999'' ) AS date_interval
FROM
        do_ord_main AS ord
        CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)
        LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'', ''999999999999'' )
        LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'', ''999999999999'' )
        LEFT OUTER JOIN do_medicine_mix_cd ON medi_mix_code = mmx.medicine_mix_cd
        LEFT OUTER JOIN do_mstmedi_class_cd ON medi_class_code = TO_NUMBER(mmx.class_cd :: text, ''999999999999'' )
        LEFT OUTER JOIN do_mst_timing ON timing_code = TO_NUMBER(medi ->> ''timing_cd'' :: text, ''999999999999'' )
        LEFT OUTER JOIN do_mst_procedure ON procedure_code = TO_NUMBER(medi ->> ''procedure_cd'' :: text, ''999999999999'' )
        CROSS JOIN LATERAL json_array_elements(mmx.mix_info :: json ) mmxd
        LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'' )
        LEFT OUTER JOIN mst_medicine_class AS mmdc ON mmdc.class_cd = mmd.class_cd
WHERE
    medi->>''medicine_type'' = ''2''
    AND (
      --患者経過総合ビューアの投与薬剤に手技が設定されていない場合
      medi ->> ''procedure_cd'' IS NULL
      OR(
        --患者経過総合ビューアの投与薬剤に手技が設定されている場合
        medi ->> ''procedure_cd'' IS NOT NULL
        --連携設定 DIALYSIS_ITEM_PROCEDURE_TAGのkey2＝患者経過総合ビューアの投与薬剤に設定した手技の連携コード1がない場合
        AND ((SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) IS  NULL
        OR (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) = '''')
      )
    )
)
, equip_all_over_order AS (
SELECT ROW_NUMBER () OVER () AS no2, *
FROM (SELECT *
    FROM equip_all_data
    ORDER BY
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''3'' THEN mix_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''6'' THEN date_interval END,
      CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''3'' THEN login_ord ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''3'' THEN ord_medicine_mix ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''3'' THEN mix_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''6'' THEN date_interval END,
      CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''3'' THEN login_ord ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''3'' THEN ord_medicine_mix ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''3'' THEN mix_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''6'' THEN date_interval END,
      CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''3'' THEN login_ord ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''3'' THEN ord_medicine_mix ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''3'' THEN mix_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''6'' THEN date_interval END,
      CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''3'' THEN login_ord ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''3'' THEN ord_medicine_mix ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''3'' THEN mix_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''6'' THEN date_interval END,
      CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''3'' THEN login_ord ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''3'' THEN ord_medicine_mix ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''3'' THEN mix_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''6'' THEN date_interval END,
      CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''3'' THEN login_ord ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''3'' THEN ord_medicine_mix ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''3'' THEN medicine_type ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''1'' THEN medi_class_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''3'' THEN mix_M_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''6'' THEN date_interval END,
      CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''3'' THEN login_ord ELSE 0 END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''3'' THEN ord_medicine_mix ELSE 0 END,
        ord_medicine_mix ) AS mid_data
)
, equip_all_copy AS (
SELECT
    --22薬品手技(手技),単体薬剤
    ''予約詳細'' AS detail_id,
    --項目コード
    COALESCE(mp.in_hospital_cd_a1, '''') AS e01,
    --項目属性
    COALESCE(mp.in_hospital_cd_a2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_PROCEDURE_ATTR''), '''')) AS e02,
    --項目名称
    COALESCE(mp.pricedure_name, '''') AS e03,
    --数量
    ''0000000.000'' AS e04,
    --選択単位フラグ
    ''0'' AS e05,
    --単位コード
    '''' AS e06,
    --単位名称
    '''' AS e07,
    --タグ名称
    COALESCE((SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1), '''') AS e08,
    --出力順
    CASE length((SELECT no2 FROM equip_all_over_order
        WHERE medi ->> ''procedure_cd'' :: TEXT = procedure_cd_no
        AND mmd.in_hospital_cd_1 = e01 AND medi ->> ''no'' = sorttag1) :: TEXT) WHEN 1 THEN COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-0'' || (SELECT no2 FROM equip_all_over_order
        WHERE medi ->> ''procedure_cd'' :: TEXT = procedure_cd_no
        AND mmd.in_hospital_cd_1 = e01 AND medi ->> ''no'' = sorttag1) :: TEXT || ''-''|| ''1''
    ELSE COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-'' || (SELECT no2 FROM equip_all_over_order
        WHERE medi ->> ''procedure_cd'' :: TEXT = procedure_cd_no
        AND mmd.in_hospital_cd_1 = e01 AND medi ->> ''no'' = sorttag1) :: TEXT || ''-''|| ''1'' END AS e09,
        ''手技'' AS aa,
    medi ->> ''no'' as sorttag1,
    ''2''  as sorttag2,
    '''' as sorttagclass
FROM
    do_ord_main ord
    cross join lateral json_array_elements (ord.ind_medi_info :: json) medi
LEFT OUTER JOIN
    mst_medicine mmd ON mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_procedure mp ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'',''999999999999'')
WHERE
    --患者経過総合ビューアの投与薬剤に手技が設定されている場合
    medi ->> ''procedure_cd'' IS NOT NULL
    AND medi->>''medicine_type'' = ''1''
    --連携設定 DIALYSIS_ITEM_PROCEDURE_TAGのkey2＝患者経過総合ビューアの投与薬剤に設定した手技の連携コード1がある場合
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) IS NOT NULL
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) <> ''''
UNION
SELECT
    --22薬品手技(手技あり薬剤),単体薬剤
    ''予約詳細'' AS detail_id,
    --項目コード
    COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE (CASE WHEN LENGTH(TRIM(mmd.in_hospital_cd_1)) > 8 THEN RIGHT(TRIM(mmd.in_hospital_cd_1), 8) ELSE RPAD(TRIM(mmd.in_hospital_cd_1), 8, '' '') END) END), '''') AS e01,
    --項目属性
    COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END), COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_MEDICINE_ATTR''), '''')) AS e02,
    --項目名称
    COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE mmd.medicine_name END), '''') AS e03,
    --数量
    TO_CHAR(TO_NUMBER(medi ->> ''amount'', ''9999999.999''), ''FM0999999.990'') AS e04,
    --選択単位フラグ
    CASE
      WHEN (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) IS NULL OR
           (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) = ''''
        THEN ''0''
      ELSE ''1''
    END AS e05,
    --単位コード
    COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e06,
    --単位名称
    COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e07,
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_MEASURE_MEDICINE_TAG''), '''') AS e08,
    --出力順
    CASE length((SELECT no2 FROM equip_all_over_order
        WHERE medi ->> ''procedure_cd'' :: TEXT = procedure_cd_no
        AND mmd.in_hospital_cd_1 = e01 AND medi ->> ''no'' = sorttag1) :: TEXT) WHEN 1 THEN COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-0'' || (SELECT no2 FROM equip_all_over_order
        WHERE medi ->> ''procedure_cd'' :: TEXT = procedure_cd_no
        AND mmd.in_hospital_cd_1 = e01 AND medi ->> ''no'' = sorttag1) :: TEXT || ''-''|| ''2''
    ELSE COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-'' || (SELECT no2 FROM equip_all_over_order
        WHERE medi ->> ''procedure_cd'' :: TEXT = procedure_cd_no
        AND mmd.in_hospital_cd_1 = e01 AND medi ->> ''no'' = sorttag1) :: TEXT || ''-''|| ''2'' END AS e09,
        ''薬剤'' AS aa,
    medi ->> ''no''   as sorttag1,
    ''2''  as sorttag2,
    '''' as sorttagclass
FROM
    do_ord_main ord
    cross join lateral json_array_elements (ord.ind_medi_info :: json) medi
LEFT OUTER JOIN
    mst_medicine_mix mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_medicine mmd ON mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_procedure mp ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'',''999999999999'')
WHERE
    --患者経過総合ビューアの投与薬剤に手技が設定されている場合
    medi ->> ''procedure_cd'' IS NOT NULL
    AND medi->>''medicine_type'' = ''1''
    --連携設定 DIALYSIS_ITEM_PROCEDURE_TAGのkey2＝患者経過総合ビューアの投与薬剤に設定した手技の連携コード1がある場合
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) IS NOT NULL
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) <> ''''
UNION
SELECT
    --23処置薬品名(手技なし薬剤),単体薬剤
    ''予約詳細'' AS detail_id,
    --項目コード
    COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE (CASE WHEN LENGTH(TRIM(mmd.in_hospital_cd_1)) > 8 THEN RIGHT(TRIM(mmd.in_hospital_cd_1), 8) ELSE RPAD(TRIM(mmd.in_hospital_cd_1), 8, '' '') END) END), '''') AS e01,
    --項目属性
    COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END), COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_NON_PROCEDURE_ATTR''), '''')) AS e02,
    --項目名称
    COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE mmd.medicine_name END), '''') AS e03,
    --数量
    TO_CHAR(TO_NUMBER(medi->>''amount'', ''9999999.999''), ''FM0999999.990'') AS e04,
    --選択単位フラグ
    CASE
      WHEN (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) IS NULL OR
           (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) = ''''
        THEN ''0''
      ELSE ''1''
    END AS e05,
    --単位コード
    COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e06,
    --単位名称
    COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e07,
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_MEASURE_MEDICINE_TAG''), '''') AS e08,
    --出力順
    CASE length((SELECT no2 FROM equip_all_over_order
        WHERE medi ->> ''procedure_cd'' :: TEXT = procedure_cd_no
        AND mmd.in_hospital_cd_1 = e01 AND medi ->> ''no'' = sorttag1) :: TEXT) WHEN 1 THEN COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-0'' || (SELECT no2 FROM equip_all_over_order
        WHERE medi ->> ''procedure_cd'' :: TEXT = procedure_cd_no
        AND mmd.in_hospital_cd_1 = e01 AND medi ->> ''no'' = sorttag1) :: TEXT || ''-''|| ''2''
    ELSE COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-'' || (SELECT no2 FROM equip_all_over_order
        WHERE medi ->> ''procedure_cd'' :: TEXT = procedure_cd_no
        AND mmd.in_hospital_cd_1 = e01 AND medi ->> ''no'' = sorttag1) :: TEXT || ''-''|| ''2'' END AS e09,
        ''薬剤'' AS aa,
    medi ->> ''no'' as sorttag1,
    ''3'' as sorttag2,
    '''' as sorttagclass
FROM
    do_ord_main ord
    cross join lateral json_array_elements (ord.ind_medi_info :: json) medi
LEFT OUTER JOIN
    mst_medicine_mix mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_medicine mmd ON mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_procedure mp ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'',''999999999999'')
WHERE
    medi->>''medicine_type'' = ''1''
    AND (
      --患者経過総合ビューアの投与薬剤に手技が設定されていない場合
      medi ->> ''procedure_cd'' IS NULL
      OR(
        --患者経過総合ビューアの投与薬剤に手技が設定されている場合
        medi ->> ''procedure_cd'' IS NOT NULL
        --連携設定 DIALYSIS_ITEM_PROCEDURE_TAGのkey2＝患者経過総合ビューアの投与薬剤に設定した手技の連携コード1がない場合
        AND ((SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) IS  NULL
        OR (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) = '''')
      )
    )
UNION
SELECT
    --22薬品手技(手技),調製薬剤
    ''予約詳細'' AS detail_id,
    --項目コード
    COALESCE(mp.in_hospital_cd_a1, '''') AS e01,
    --項目属性
    COALESCE(mp.in_hospital_cd_a2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_PROCEDURE_ATTR''), '''')) AS e02,
    --項目名称
    COALESCE(mp.pricedure_name, '''') AS e03,
    --数量
    ''0000000.000'' AS e04,
    --選択単位フラグ
    ''0'' AS e05,
    --単位コード
    '''' AS e06,
    --単位名称
    '''' AS e07,
    --タグ名称
    COALESCE((SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1), '''') AS e08,
    --出力順
    CASE length((SELECT no2 FROM equip_all_over_order
        WHERE medicine_type = ''2'' AND procedure_cd_no :: TEXT = medi ->> ''procedure_cd'' :: TEXT
        AND e01 = mmd.in_hospital_cd_1 AND sorttag1 = medi ->> ''no'' AND ord_medicine_mix = 1) :: TEXT) WHEN 1 THEN COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-0'' || (SELECT no2 FROM equip_all_over_order
        WHERE medicine_type = ''2'' AND procedure_cd_no :: TEXT = medi ->> ''procedure_cd'' :: TEXT
        AND e01 = mmd.in_hospital_cd_1 AND sorttag1 = medi ->> ''no'' AND ord_medicine_mix = 1) :: TEXT || ''-''|| ''1''
    ELSE COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-'' || (SELECT no2 FROM equip_all_over_order
        WHERE medicine_type = ''2'' AND procedure_cd_no :: TEXT = medi ->> ''procedure_cd'' :: TEXT
        AND e01 = mmd.in_hospital_cd_1 AND sorttag1 = medi ->> ''no'' AND ord_medicine_mix = 1) :: TEXT || ''-''|| ''1'' END AS e09,
        ''手技'' AS aa,
    medi ->> ''no'' as sorttag1,
    ''2''  as sorttag2,
    '''' as sorttagclass
FROM
    do_ord_main ord
    cross join lateral json_array_elements (ord.ind_medi_info :: json) medi
LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'' :: TEXT, ''999999999999'' )
    CROSS JOIN LATERAL json_array_elements(mmx.mix_info :: json ) mmxd
LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER(mmxd ->> ''cd'', ''999999999999'' )
LEFT OUTER JOIN
    mst_procedure mp ON mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'',''999999999999'')
WHERE
    --患者経過総合ビューアの投与薬剤に手技が設定されている場合
    medi ->> ''procedure_cd'' IS NOT NULL
    AND medi->>''medicine_type'' = ''2''
        AND (SELECT ord_medicine_mix FROM equip_all_over_order
                 WHERE medicine_type = ''2'' AND procedure_cd_no :: TEXT = medi ->> ''procedure_cd'' :: TEXT
                 AND e01 = mmd.in_hospital_cd_1 AND sorttag1 = medi ->> ''no'') = 1
    --連携設定 DIALYSIS_ITEM_PROCEDURE_TAGのkey2＝患者経過総合ビューアの投与薬剤に設定した手技の連携コード1がある場合
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) IS NOT NULL
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) <> ''''
UNION
SELECT
    --22薬品手技(手技あり薬剤),調製薬剤
    ''予約詳細'' AS detail_id,
    --項目コード
        CASE WHEN LENGTH(TRIM(mmd.in_hospital_cd_1)) > 8 THEN RIGHT(TRIM(mmd.in_hospital_cd_1), 8) ELSE RPAD(TRIM(mmd.in_hospital_cd_1), 8, '' '') END AS e01,
        --項目属性
        COALESCE(mmd.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_MEDICINE_ATTR''), '''')) AS e02,
        --項目名称
        COALESCE(mmd.medicine_name, '''') AS e03,
        --数量
        TO_CHAR((TO_NUMBER(medi ->> ''amount'', ''9999999.999'') * TO_NUMBER(mmxd ->> ''amount'', ''9999999.999'' )), ''FM0999999.990'' ) AS e04,
        --選択単位フラグ
        CASE
            WHEN mmd.unit IS NULL OR mmd.unit = '''' THEN ''0'' ELSE ''1'' END AS e05,
        --単位コード
        COALESCE(mmd.unit, '''') AS e06,
        --単位名称
        COALESCE(mmd.unit, '''') AS e07,
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_MEASURE_MEDICINE_TAG''), '''') AS e08,
    --出力順
    CASE length((SELECT no2 FROM equip_all_over_order
        WHERE medicine_type = ''2'' AND procedure_cd_no :: TEXT = medi ->> ''procedure_cd'' :: TEXT
        AND e01 = mmd.in_hospital_cd_1 AND sorttag1 = medi ->> ''no'') :: TEXT) WHEN 1 THEN COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-0'' || (SELECT no2 FROM equip_all_over_order
        WHERE medicine_type = ''2'' AND procedure_cd_no :: TEXT = medi ->> ''procedure_cd'' :: TEXT
        AND e01 = mmd.in_hospital_cd_1 AND sorttag1 = medi ->> ''no'') :: TEXT || ''-''|| ''2''
    ELSE COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-'' || (SELECT no2 FROM equip_all_over_order
        WHERE medicine_type = ''2'' AND procedure_cd_no :: TEXT = medi ->> ''procedure_cd'' :: TEXT
        AND e01 = mmd.in_hospital_cd_1 AND sorttag1 = medi ->> ''no'') :: TEXT || ''-''|| ''2'' END AS e09,
        ''薬剤'' AS aa,
    (medi->>''no'') as sorttag1,
    ''22'' as sorttag2,
    (medi->>''class_cd'') as sorttagclass
FROM
    do_ord_main AS ord
        CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)
        LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
        LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
        CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
        LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
WHERE
    --患者経過総合ビューアの投与薬剤に手技が設定されている場合
    medi ->> ''procedure_cd'' IS NOT NULL
    AND medi ->> ''medicine_type'' = ''2''
    --連携設定 DIALYSIS_ITEM_PROCEDURE_TAGのkey2＝患者経過総合ビューアの投与薬剤に設定した手技の連携コード1がある場合
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) IS NOT NULL
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) <> ''''
UNION
SELECT
    --23処置薬品名(手技なし薬剤),調製薬剤
    ''予約詳細'' AS detail_id,
    --項目コード
        CASE WHEN LENGTH(TRIM(mmd.in_hospital_cd_1)) > 8 THEN RIGHT(TRIM(mmd.in_hospital_cd_1), 8) ELSE RPAD(TRIM(mmd.in_hospital_cd_1), 8, '' '') END AS e01,
        --項目属性
        COALESCE(mmd.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_MEDICINE_ATTR''), '''')) AS e02,
        --項目名称
        COALESCE(mmd.medicine_name, '''') AS e03,
        --数量
        TO_CHAR((TO_NUMBER(medi ->> ''amount'', ''9999999.999'') * TO_NUMBER(mmxd ->> ''amount'', ''9999999.999'' )), ''FM0999999.990'' ) AS e04,
        --選択単位フラグ
        CASE
            WHEN mmd.unit IS NULL OR mmd.unit = '''' THEN ''0'' ELSE ''1'' END AS e05,
        --単位コード
        COALESCE(mmd.unit, '''') AS e06,
        --単位名称
        COALESCE(mmd.unit, '''') AS e07,
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_MEASURE_MEDICINE_TAG''), '''') AS e08,
    --出力順
    CASE length((SELECT no2 FROM equip_all_over_order
        WHERE medi ->> ''procedure_cd'' :: TEXT = procedure_cd_no
        AND mmd.in_hospital_cd_1 = e01 AND medi ->> ''no'' = sorttag1) :: TEXT) WHEN 1 THEN COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-0'' || (SELECT no2 FROM equip_all_over_order
        WHERE medi ->> ''procedure_cd'' :: TEXT = procedure_cd_no
        AND mmd.in_hospital_cd_1 = e01 AND medi ->> ''no'' = sorttag1) :: TEXT || ''-''|| ''2''
    ELSE COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-'' || (SELECT no2 FROM equip_all_over_order
        WHERE medi ->> ''procedure_cd'' :: TEXT = procedure_cd_no
        AND mmd.in_hospital_cd_1 = e01 AND medi ->> ''no'' = sorttag1) :: TEXT || ''-''|| ''2'' END AS e09,
        ''薬剤'' AS aa,
    (medi->>''no'') as sorttag1,
        ''33'' as sorttag2,
        (medi->>''class_cd'') as sorttagclass
FROM
    do_ord_main AS ord
        CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)
        LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
        LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
        CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
        LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
WHERE
    medi->>''medicine_type'' = ''2''
    AND (
      --患者経過総合ビューアの投与薬剤に手技が設定されていない場合
      medi ->> ''procedure_cd'' IS NULL
      OR(
        --患者経過総合ビューアの投与薬剤に手技が設定されている場合
        medi ->> ''procedure_cd'' IS NOT NULL
        --連携設定 DIALYSIS_ITEM_PROCEDURE_TAGのkey2＝患者経過総合ビューアの投与薬剤に設定した手技の連携コード1がない場合
        AND ((SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) IS  NULL
        OR (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) = '''')
      )
    )
)
, data_all_copy AS (--と薬剤、の適合
SELECT equip_all_copy.detail_id, equip_all_copy.e01, equip_all_copy.e02, equip_all_copy.e03, equip_all_copy.e04, equip_all_copy.e05, equip_all_copy.e06, equip_all_copy.e07, equip_all_copy.e08, equip_all_copy.e09,sortTag1,sortTag2,sorttagclass, mmd.medicine_cd, mmd.class_cd as mdclass_cd
FROM equip_all_copy
    LEFT JOIN mst_medicine mmd ON equip_all_copy.e01 = mmd.in_hospital_cd_1 and equip_all_copy.e03 = mmd.medicine_name
        order by e09
)
, data_all_med as(--薬剤のモジュール
select detail_id,e01,e02,e03,data_all_copy.e04,e05,e06,e07,e08,e09,sortTag1,sortTag2,medicine_cd,
case when sorttag2 = ''22'' or sorttag2 = ''33'' then sorttagclass::text else mdclass_cd::text  end  as mdclass_cd
             from data_all_copy where e09 > (SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_MEASURE_MEDICINE'') or e09::INTEGER < ((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_MEASURE_MEDICINE'')::INTEGER + 1)
)
, data_commmon as(--一般のモジュール
select detail_id, e01, e02, e03, e04, e05, e06, e07, e08, e09,sortTag1,sortTag2,''標準''::text as  aa from data_middle_all where e09<>(SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_EQUIP'')


ORDER BY  e09
)
, data_all_meq as(--医療材料のモジュール
SELECT
    --医療材料情報
    ''予約詳細'' AS detail_id,
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01,
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_EQUIP_ATTR''), '''')) AS e02,
    --項目名称
    COALESCE(meq.equipment_name, '''') AS e03,
    --数量
    COALESCE(TO_CHAR(TO_NUMBER(equip->>''amount'',''9999999.999'') ,''FM0999999.990''), '''') AS e04,
    --選択単位フラグ
    CASE WHEN meq.unit IS NULL OR meq.unit = ''''
    THEN ''0'' ELSE ''1'' END AS e05,
    --単位コード
    COALESCE(meq.unit, '''') AS e06,
    --単位名称
    COALESCE(meq.unit, '''') AS e07,
    --タグ名称
    COALESCE(meqc.class_name, '''') AS e08,
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_EQUIP''), '''') AS e09 ,
    '''' as sorttag1,
    '''' as sorttag2,
		''医療材料''::text as aa,
		equip->>''cd'' as equipment_cd,
		equip->>''class_cd'' as mqclass_cd
FROM
    do_ord_main ord
    cross join lateral json_array_elements (ord.ind_equip_info :: json) equip
LEFT OUTER JOIN
    mst_equipment meq ON meq.equipment_cd = TO_NUMBER(equip->>''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_equipment_class meqc ON meq.class_cd = meqc.class_cd
WHERE
    equip->>''equip_type'' = ''0''
)
, order_qcode_F AS (--医療材料の1，2场合
 SELECT DISTINCT ON (item_cd_f)* FROM (
   SELECT
     e01 AS item_cd_f,
     CASE WHEN ''1'' in (SELECT ora FROM do_order_data_equip_from) THEN TO_NUMBER( meq_class_code_order :: text, ''999999999999'' ) ELSE NULL END AS class_qcd_f,
     CASE WHEN ''2'' in (SELECT ora FROM do_order_data_equip_from) THEN TO_NUMBER( meq_code_order :: text, ''999999999999'' ) ELSE NULL END AS meq_cd_f
   FROM
     data_all_meq
     LEFT OUTER JOIN do_mstmeq_cd ON meq_code ::text = data_all_meq.equipment_cd
--      LEFT OUTER JOIN do_mstmeq_class_cd ON meq_class_code ::text= data_all_meq.mqclass_cd
     LEFT OUTER JOIN mst_equipment ON mst_equipment.equipment_cd ::text = data_all_meq.equipment_cd
     LEFT OUTER JOIN do_mstmeq_class_cd ON meq_class_code = mst_equipment.class_cd
   ORDER BY item_cd_f asc) AS order_code_middle_QA
 )
, order_qcode_S AS (--医療材料のない治療条件0场合
   SELECT
     (SELECT in_hospital_cd_1 FROM mst_equipment WHERE equipment_cd = TO_NUMBER( eqp ->> ''cd'' :: text, ''999999999999'')) AS item_cd_s,
     CASE WHEN ''0'' in (SELECT ora FROM do_order_data_equip_from) THEN TO_NUMBER( json_idx :: text, ''999999999999'' ) ELSE NULL END AS login_ord_s,
         (SELECT COALESCE(TO_CHAR(TO_NUMBER(eqp->> ''amount'',''9999999.999'') ,''FM0999999.990''), '''') FROM mst_equipment WHERE equipment_cd = TO_NUMBER( eqp ->> ''cd'', ''FM0999999.990'')) AS amount,
         ROW_NUMBER() OVER() as class_cd,
         ROW_NUMBER() OVER() as equip_cd
   FROM
     do_ord_main AS ord
     CROSS JOIN LATERAL json_array_elements(ord.ind_equip_info :: json) with ordinality as tmp(eqp, json_idx)
   ORDER BY item_cd_s, login_ord_s asc
    )
, dataequipOrder as(--医療材料の0场合すでにソートされている
        select detail_id, e01, e02, e03, e04, e05, e06, e07, e08, e09,sortTag1,sortTag2,aa,ROW_NUMBER() OVER() as login_ord,class_cd,equip_cd from (
    (select ''予約詳細'' as detail_id, order_qcode_S.item_cd_s as e01, data_all_meq.e02, data_all_meq.e03,
        order_qcode_S.amount as e04, data_all_meq.e05, data_all_meq.e06, data_all_meq.e07, data_all_meq.e08,
        data_all_meq.e09,data_all_meq.sortTag1,data_all_meq.sortTag2,
        data_all_meq.aa,order_qcode_S.login_ord_s,
     class_cd,
      equip_cd
        from order_qcode_S,data_all_meq where order_qcode_S.item_cd_s = data_all_meq.e01
        and aa = ''医療材料''
        and order_qcode_S.amount = data_all_meq.e04 order by login_ord_s
     )) as dataequipOrder)
, dataequipOrder1 as(
    select detail_id, e01, e02, e03, e04, e05, e06, e07, e08, e09,sortTag1,sortTag2,aa,
    dataequipOrder.login_ord,order_qcode_F.class_qcd_f as class_cd,order_qcode_F.meq_cd_f as equip_cd
    from dataequipOrder,order_qcode_F where dataequipOrder.e01 =order_qcode_F.item_cd_f )
, equip_order as(
select *, ROW_NUMBER() OVER() as ordnow from (
 (select detail_id::text, e01, e02, e03, e04, e05, e06, e07, e08, e09, sortTag1::text,sortTag2::text,''治医療材料''::text as  aa
  from data_middle_all where e09=(SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_EQUIP'') and sortTag2 =''18''
	order by sorttag1)
	union all
(SELECT detail_id::text, e01, e02, e03, e04, e05, e06, e07, e08, e09, sortTag1::text,sortTag2::text, aa
 FROM dataequipOrder1
 ORDER BY
     CASE WHEN (SELECT ora FROM do_order_data_equip_from WHERE no2 = 1) = 0 THEN login_ord
          WHEN (SELECT ora FROM do_order_data_equip_from WHERE no2 = 1) = 1 THEN class_cd
          WHEN (SELECT ora FROM do_order_data_equip_from WHERE no2 = 1) = 2 THEN equip_cd END,
     CASE WHEN (SELECT ora FROM do_order_data_equip_from WHERE no2 = 2) = 0 THEN login_ord
          WHEN (SELECT ora FROM do_order_data_equip_from WHERE no2 = 2) = 1 THEN class_cd
          WHEN (SELECT ora FROM do_order_data_equip_from WHERE no2 = 2) = 2 THEN equip_cd END,
     CASE WHEN (SELECT ora FROM do_order_data_equip_from WHERE no2 = 3) = 0 THEN login_ord
          WHEN (SELECT ora FROM do_order_data_equip_from WHERE no2 = 3) = 1 THEN class_cd
          WHEN (SELECT ora FROM do_order_data_equip_from WHERE no2 = 3) = 2 THEN equip_cd END)
)as equip_order
)
, kou_coag_procedu AS(
    SELECT
    *
FROM
    ( SELECT
   ''予約詳細'' AS detail_id,
    --項目コード
    COALESCE((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 =''KOU_COAG_PROCEDURE_CODE''),'''') AS e01,
    --項目属性
    COALESCE((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 =''KOU_COAG_PROCEDURE_ATTR''),'''') AS e02,
    --項目名称
    COALESCE((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 =''KOU_COAG_PROCEDURE_NAME''),'''')  AS e03,
    --数量
   ''0000000.000'' AS e04,
    --選択単位フラグ
   ''0'' AS e05,
    --単位コード
   '''' AS e06,
    --単位名称
   '''' AS e07,
    --タグ名称
   -- COALESCE((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 =''KOU_COAG_PROCEDURE_CODE''),'''') AS e08,
      COALESCE(((SELECT VALUE FROM kou_coag_procedur_data)),'''') AS e08,
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-'' || ''0''||''-''||''0'' AS e09 ,
   '''' as sorttag1,
   '''' as sorttag2,
     '''' as aa
     FROM kou_coag_procedur_falg
         WHERE ctl = 1
         AND ((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'' or
        (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''2'')
                AND EXISTS(SELECT 1 FROM do_ord_main WHERE  (ind_cond_info->''25''->>''value'' is NOT NULL) AND (ind_cond_info->''25''->>''medicine_type'' = ''2'') )
        ) T

        UNION
    SELECT
    --⑯抗凝固剤・初回(調製情報)
    ''予約詳細'' AS detail_id,
    --項目コード
        CASE WHEN LENGTH(TRIM(mmd.in_hospital_cd_1)) > 8 THEN RIGHT(TRIM(mmd.in_hospital_cd_1), 8) ELSE RPAD(TRIM(mmd.in_hospital_cd_1), 8, '''') END AS e01,
    --項目属性
        CASE (select ctl FROM kou_coag_procedur_falg) WHEN 1  THEN COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_MEDICINE_ATTR''), '''') WHEN 2 THEN COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_NON_PROCEDURE_ATTR''), '''') ELSE ''''  end AS e02,
    --項目名称
    COALESCE(mmd.medicine_name, '''') AS e03,
    --数量
    COALESCE( TO_CHAR(TO_NUMBER(mmxd ->> ''amount'', ''9999999.999'' ), ''FM0999999.990'' ) )  AS e04,
    --選択単位フラグ
    CASE
      WHEN mmd.unit IS NULL OR
          mmd.unit = ''''
        THEN ''0''
          ELSE ''1''

    END AS e05,
    --単位コード
   COALESCE(mmd.unit, '''') AS e06,
    --単位名称
   COALESCE(mmd.unit, '''') AS e07,
    --タグ名称
   COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_MEASURE_MEDICINE_TAG''), '''') AS e08,
   COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''') || ''-00-'' ||json_idx AS e09,
    '''' as sorttag1,
    '''' as sorttag2,
        '''' as aa
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_medicine_mix mmx ON mmx.medicine_mix_cd = TO_NUMBER(ord.ind_cond_info->''25''->>''value'',''999999999999'')
 CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) with ordinality as tmp(mmxd, json_idx)
  LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
WHERE
    ((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'' or
        (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''2'')
        AND ord.ind_cond_info->''25''->>''medicine_type'' = ''2''
        AND (mmd.in_hospital_cd_2 IS NULL OR mmd.in_hospital_cd_2 ='''')
            UNION
SELECT
    --⑯抗凝固剤・初回(調製情報)
    ''予約詳細'' AS detail_id,
    --項目コード
        CASE WHEN LENGTH(TRIM(mmd.in_hospital_cd_1)) > 8 THEN RIGHT(TRIM(mmd.in_hospital_cd_1), 8) ELSE RPAD(TRIM(mmd.in_hospital_cd_1), 8, '''') END AS e01,
    --項目属性
    COALESCE(mmd.in_hospital_cd_2, '''') AS e02,
    --項目名称
    COALESCE(mmd.medicine_name, '''') AS e03,
    --数量
    COALESCE( TO_CHAR(TO_NUMBER(mmxd ->> ''amount'', ''9999999.999'' ), ''FM0999999.990'' ) )  AS e04,
    --選択単位フラグ
    CASE
      WHEN mmd.unit IS NULL OR
          mmd.unit = ''''
        THEN ''0''
          ELSE ''1''

    END AS e05,
    --単位コード
   COALESCE(mmd.unit, '''') AS e06,
    --単位名称
   COALESCE(mmd.unit, '''') AS e07,
    --タグ名称
   COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_MEASURE_MEDICINE_TAG''), '''') AS e08,
   COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''') || ''-00-'' ||json_idx AS e09,
    '''' as sorttag1,
    '''' as sorttag2,
        '''' as aa
FROM
    do_ord_main ord
LEFT OUTER JOIN
    mst_medicine_mix mmx ON mmx.medicine_mix_cd = TO_NUMBER(ord.ind_cond_info->''25''->>''value'',''999999999999'')
 CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) with ordinality as tmp(mmxd, json_idx)
  LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
WHERE
    ((SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''1'' or
        (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''2'')
        AND ord.ind_cond_info->''25''->>''medicine_type'' = ''2''
        AND (mmd.in_hospital_cd_2 IS NOT NULL OR mmd.in_hospital_cd_2 <>'''')
        AND ((select ctl FROM kou_coag_procedur_falg) = 1   OR (select ctl FROM kou_coag_procedur_falg) = 2)
 ),
 combination as(
 --各部分の組み合わせ
    select *,ROW_NUMBER() OVER() as ordnow from  data_commmon
    union all
    select * from equip_order
    union all
    select  detail_id::text, e01::text, e02::text, e03::text, e04::text, e05::text, e06::text, e07::text, e08::text, e09::text,sortTag1::text,sortTag2::text, aa,ROW_NUMBER() OVER() as ordnow from equip_all_copy
    union all
    select *,ROW_NUMBER() OVER() as ordnow from kou_coag_procedu
        )

  SELECT * FROM combination WHERE e01 <>'''' OR e01 is NOT NULL ORDER BY e09,ordnow', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通：透析予約繰り返し部', '2022-11-19 05:34:21.059',CURRENT_TIMESTAMP, '[{"sql_cd": -20, "field_name": "in_out", "replace_var": "@inOut"}, {"sql_cd": -151, "field_name": "check_user1_name", "replace_var": "@checkUser1Name"}, {"sql_cd": -151, "field_name": "check_user2_name", "replace_var": "@checkUser2Name"}, {"sql_cd": -152, "field_name": "disp_user_1_id", "replace_var": "@dispUser1Id"}, {"sql_cd": -152, "field_name": "disp_user_2_id", "replace_var": "@dispUser2Id"}]');
