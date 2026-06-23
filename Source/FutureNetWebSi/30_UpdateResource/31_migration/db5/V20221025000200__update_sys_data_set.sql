delete from ntss.sys_data_set where sql_cd = '-103';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-103, 'WITH do_order_data_from1 AS (
SELECT ROW_NUMBER () OVER () AS no2, TO_NUMBER(datt.a1  :: text, ''999999999999'') AS ora
FROM (SELECT TO_NUMBER((unnest(string_to_array((
SELECT mst_f.value AS rtt
  FROM mst_facility_setting AS mst_f 
  WHERE mst_f.facility_setting_no = ''3006'' AND mst_f.facility_cd = @facilityCd ),'',''))), ''999999999999'') AS a1) AS datt
)
, do_mstmeq_cd AS (
SELECT index_no AS meq_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_code, order_cd ->> ''name'' AS meq_code_name
FROM mst_selector
    CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd 
   AND master_physical_name = ''mst_equipment'' 
)
, do_mstmeq_class_cd AS (
SELECT index_no AS meq_class_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_class_code, order_cd ->> ''name'' AS meq_class_code_name
FROM mst_selector
    CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd  
   AND master_physical_name = ''mst_equipment_class'' 
)
, do_order_data_from AS (
SELECT ROW_NUMBER () OVER () AS no2, datt.a1
FROM (SELECT TO_NUMBER((unnest(string_to_array((
SELECT mst_f.value AS rtt
  FROM mst_facility_setting AS mst_f
  WHERE mst_f.facility_setting_no = ''3007'' AND mst_f.facility_cd = @facilityCd 
),'',''))), ''999999999999'') AS a1) AS datt
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
, data_middle_all AS (
WITH item_sort_info AS (
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
    AND info->>''key1'' = ''DIALYSIS_ITEM_SORT''
)
, item_set_info AS (
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
    AND info ->> ''key1'' = ''DIALYSIS_ITEM_SEND'' 
)
, fji_com_info AS (
  --富士通共通設定値
  SELECT
    info->>''key2'' AS key2 
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS value 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''FJI_COM_INFO'' 
)
, conv_treat_item_send_out_info AS (
  --外来用
  SELECT
    info ->> ''key2'' AS key2 
    , UNNEST(STRING_TO_ARRAY(COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'' ), '','')) AS value
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info 
  WHERE
    facility_cd = @facilityCd 
 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''CONV_TREAT_ITEM_SEND_OUT'' 
)
, conv_treat_item_send_in_info AS (
  --入院用
  SELECT
    info ->> ''key2'' AS key2 
    , UNNEST(STRING_TO_ARRAY(COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'' ), '','')) AS value
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info 
  WHERE
    facility_cd = @facilityCd 
 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''CONV_TREAT_ITEM_SEND_IN'' 
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
    AND info ->> ''key1'' = ''IND_SET_MEDICINE_RESOLVE'' 
)
, solution_cnt AS (
  --透析液取得件数
  SELECT 
    COUNT(*) AS cnt
  FROM
    ord_main ord
  LEFT OUTER JOIN
    mst_medicine mmd
  ON
    mmd.medicine_cd = TO_NUMBER(ord.ind_cond_info->''15''->>''value'',''999999999999'')
  WHERE
    ord.ord_no = @ordNo

    AND (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''SOLUTION_RESOLVE_MODE'') = ''0''
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
    AND info ->> ''key1'' = ''DIALYSIS_ITEM_PROCEDURE_TAG'' 
)
, device AS (
		SELECT device_mode
		FROM mst_treatment mst JOIN ord_main ord 
		ON ord.ind_treatment_cd = mst.treatment_cd 
		AND ord.ord_no = @ordNo

)
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
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_BED_NO''), '''') AS e09 
FROM
    ord_main ord
LEFT OUTER JOIN
    mst_bed mbd
ON
    mbd.bed_cd = ord.ind_bed_cd
WHERE
    ord.ord_no = @ordNo
UNION
SELECT
    --②浄化方法
    ''予約詳細'' AS detail_id, 
    --項目コード
		CASE
		--患者の入外区分が外来の場合
		WHEN @inOut
 = ''0''
			THEN COALESCE(mtt.in_hospital_cd_a1, '''')
		--患者の入外区分が入院の場合
		WHEN @inOut
 = ''1''
			THEN COALESCE(NULLIF(mtt.in_hospital_cd_a2, ''''), mtt.in_hospital_cd_a1, '''')
		ELSE ''''
    END AS e01, 
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
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_TREAT''), '''') AS e09
FROM
    ord_main ord
LEFT OUTER JOIN
    mst_treatment mtt
ON
    mtt.treatment_cd = ord.ind_treatment_cd
WHERE
    ord.ord_no = @ordNo
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
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_START_DATE_TIME''), '''') AS e09 
FROM
    ord_main ord
WHERE
    ord.ord_no = @ordNo
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
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_END_DATE_TIME''), '''') AS e09 
FROM
    ord_main ord
WHERE
    ord.ord_no = @ordNo
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
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_SCHE_TIME''), '''') AS e09 
FROM
    ord_main ord
WHERE
    ord.ord_no = @ordNo
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
      ELSE TO_CHAR(TO_NUMBER(COALESCE(ord.ind_cond_info ->''3''->>''value'', ''0''),''9999999.999'') ,''FM0999999.990'') 
    END AS e04, 
    --選択単位フラグ
    ''1'' AS e05, 
    --単位コード
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_TARGET_WEIGHT_UNIT''), '''') AS e06, 
    --単位名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_TARGET_WEIGHT_UNIT''), '''') AS e07, 
    --タグ名称
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_TARGET_WEIGHT_TAG''), '''') as e08, 
    --出力順
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_TARGET_WEIGHT''), '''') AS e09 
FROM
    ord_main ord
WHERE
    ord.ord_no = @ordNo
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
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_DRY_WEIGHT''), '''') AS e09 
FROM
    ord_main ord
WHERE
    ord.ord_no = @ordNo
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
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_SHUNT_PART''), '''') AS e09 
FROM
    ord_main ord
LEFT OUTER JOIN
    mst_va mva
ON
    mva.va_cd = TO_NUMBER(ord.ind_cond_info->''2''->>''value'',''999999999999'')
WHERE
    ord.ord_no = @ordNo
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
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_DIAL_INST''), '''') AS e09 
FROM
    ord_main ord
LEFT OUTER JOIN
    mst_dialyzer mdz
ON
    mdz.dialyzer_cd = TO_NUMBER(ord.ind_cond_info->''5''->>''value'',''999999999999'')
WHERE
    ord.ord_no = @ordNo
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
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_FILM''), '''') AS e09 
FROM
    ord_main ord
LEFT OUTER JOIN
    mst_equipment meq
ON
    meq.equipment_cd = TO_NUMBER(ord.ind_cond_info->''6''->>''value'',''999999999999'')
WHERE
    ord.ord_no = @ordNo
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
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_FIRST_FILM''), '''') AS e09 
FROM
    ord_main ord
LEFT OUTER JOIN
    mst_equipment meq
ON
    meq.equipment_cd = TO_NUMBER(ord.ind_cond_info->''7''->>''value'',''999999999999'')
WHERE
    ord.ord_no = @ordNo
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
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_SECOND_FILM''), '''') AS e09 
FROM
    ord_main ord
LEFT OUTER JOIN
    mst_equipment meq
ON
    meq.equipment_cd = TO_NUMBER(ord.ind_cond_info->''8''->>''value'',''999999999999'')
WHERE
    ord.ord_no = @ordNo
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
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_EQUIP''), '''') AS e09 
FROM
    ord_main ord
LEFT OUTER JOIN
    mst_equipment as meq
ON
    meq.equipment_cd = TO_NUMBER(ord.ind_cond_info->''9''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_equipment_class meqc
ON
    meq.class_cd = meqc.class_cd
WHERE
    ord.ord_no = @ordNo
 AND
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
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_EQUIP''), '''') AS e09 
FROM
    ord_main ord
LEFT OUTER JOIN
    mst_equipment as meq
ON
    meq.equipment_cd = TO_NUMBER(ord.ind_cond_info->''10''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_equipment_class meqc
ON
    meq.class_cd = meqc.class_cd
WHERE
    ord.ord_no = @ordNo
 AND
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
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_EQUIP''), '''') AS e09 
FROM
    ord_main ord
LEFT OUTER JOIN
    mst_equipment as meq
ON
    meq.equipment_cd = TO_NUMBER(ord.ind_cond_info->''11''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_equipment_class meqc
ON
    meq.class_cd = meqc.class_cd
WHERE
    ord.ord_no = @ordNo
 AND
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
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_EQUIP''), '''') AS e09 
FROM
    ord_main ord
LEFT OUTER JOIN
    mst_equipment meq
ON
    meq.equipment_cd = TO_NUMBER(ord.ind_cond_info->''13''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_equipment_class meqc
ON
    meq.class_cd = meqc.class_cd
WHERE
    ord.ord_no = @ordNo
 AND
    ord.ind_cond_info->''13''->>''value'' IS NOT NULL
UNION
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
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_EQUIP''), '''') AS e09 
FROM
    ord_main ord
    cross join lateral json_array_elements (ord.ind_equip_info :: json) equip
LEFT OUTER JOIN
    mst_equipment meq
ON
    meq.equipment_cd = TO_NUMBER(equip->>''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_equipment_class meqc
ON
    meq.class_cd = meqc.class_cd
WHERE
    ord.ord_no = @ordNo
 AND
    equip->>''equip_type'' = ''0''
UNION
SELECT 
    --⑭透析液
    ''予約詳細'' AS detail_id, 
    --項目コード
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
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_SOLUTION''), '''') AS e09 
FROM
    ord_main ord
LEFT OUTER JOIN
    mst_medicine mmd
ON
    mmd.medicine_cd = TO_NUMBER(ord.ind_cond_info->''15''->>''value'',''999999999999'')
WHERE
    ord.ord_no = @ordNo

--     AND (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''SOLUTION_RESOLVE_MODE'') = ''0''
UNION
SELECT 
    --⑮置換液（補液）
    ''予約詳細'' AS detail_id, 
    --項目コード
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
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_REPLACE''), '''') AS e09 
FROM
    ord_main ord
LEFT OUTER JOIN
    mst_medicine mmd
ON
    mmd.medicine_cd = TO_NUMBER(ord.ind_cond_info->''19''->>''value'',''999999999999'')
WHERE
    ord.ord_no = @ordNo

--     AND (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''REPLACE_RESOLVE_MODE'') = ''0''
    AND ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''0'' 
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
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_KOU_COAG_ONESHOT''), '''') AS e09 
FROM
    ord_main ord
LEFT OUTER JOIN
    mst_medicine mmd
ON
    mmd.medicine_cd = TO_NUMBER(ord.ind_cond_info->''25''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_medicine_mix mmx
ON
    mmx.medicine_mix_cd = TO_NUMBER(ord.ind_cond_info->''25''->>''value'',''999999999999'')
WHERE
    ord.ord_no = @ordNo

    AND (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''0''
UNION
SELECT
    --⑰抗凝固剤・持続
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE  mmd.in_hospital_cd_1 END), '''') AS e01, 
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
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_KOU_COAG''), '''') AS e09 
FROM
    ord_main ord
LEFT OUTER JOIN
    mst_medicine mmd
ON
    mmd.medicine_cd = TO_NUMBER(ord.ind_cond_info->''25''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_medicine_mix mmx
ON
    mmx.medicine_mix_cd = TO_NUMBER(ord.ind_cond_info->''25''->>''value'',''999999999999'')
WHERE
    ord.ord_no = @ordNo

    AND (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''0''
UNION
SELECT 
    --⑱抗凝固剤・ＴＯＴＡＬ
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE((CASE ord.ind_cond_info->''25''->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE  mmd.in_hospital_cd_1 END), '''') AS e01,
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
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_KOU_COAG_TOTAL''), '''') AS e09 
FROM
    ord_main ord
LEFT OUTER JOIN
    mst_medicine mmd
ON
    mmd.medicine_cd = TO_NUMBER(ord.ind_cond_info->''25''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_medicine_mix as mmx
ON
    mmx.medicine_mix_cd = TO_NUMBER(ord.ind_cond_info->''25''->>''value'',''999999999999'')
WHERE
    ord.ord_no = @ordNo

    AND (SELECT value FROM ind_set_medicine_resolve_info WHERE key2 = ''KOU_COAG_RESOLVE_MODE'') = ''0''
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
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_BLOOD_AMT''), '''') AS e09 
FROM
    ord_main ord
WHERE
    ord.ord_no = @ordNo

    AND TO_NUMBER(ord.ind_cond_info->''14''->>''value'',''999999999999'') > 1
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
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_SOLUTION_AMT''), '''') AS e09 
FROM
    ord_main ord
WHERE
    ord.ord_no = @ordNo
 
    AND (SELECT cnt FROM solution_cnt) > 0 
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
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_UP_LIQUID''), '''') AS e09 
FROM
    ord_main ord
WHERE
    ord.ord_no = @ordNo

    AND TO_NUMBER(ord.ind_cond_info->''20''->>''value'',''999999999999'') > 1
--  AND (SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1''
    AND ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1'' OR ((SELECT device_mode FROM device) NOT IN (7, 8, 10)))
UNION
SELECT
    --22薬品手技(手技)
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
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-'' || (medi->>''no'') || ''-''|| ''1'' AS e09 
FROM
    ord_main ord
    cross join lateral json_array_elements (ord.ind_medi_info :: json) medi
LEFT OUTER JOIN
    mst_procedure mp
ON
    mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'',''999999999999'')
WHERE
    ord.ord_no = @ordNo

    --患者経過総合ビューアの投与薬剤に手技が設定されている場合
    AND medi ->> ''procedure_cd'' IS NOT NULL
    --連携設定 DIALYSIS_ITEM_PROCEDURE_TAGのkey2＝患者経過総合ビューアの投与薬剤に設定した手技の連携コード1がある場合
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) IS NOT NULL 
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) <> ''''
UNION
SELECT
    --22薬品手技(手技あり薬剤)
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE mmd.in_hospital_cd_1 END), '''') AS e01, 
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
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-'' || (medi->>''no'') || ''-''|| ''2'' AS e09 
FROM
    ord_main ord
    cross join lateral json_array_elements (ord.ind_medi_info :: json) medi
LEFT OUTER JOIN
    mst_medicine_mix mmx
ON
    mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_medicine mmd
ON
    mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_procedure mp
ON
    mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'',''999999999999'')
WHERE
    ord.ord_no = @ordNo

    --患者経過総合ビューアの投与薬剤に手技が設定されている場合
    AND medi ->> ''procedure_cd'' IS NOT NULL
    --連携設定 DIALYSIS_ITEM_PROCEDURE_TAGのkey2＝患者経過総合ビューアの投与薬剤に設定した手技の連携コード1がある場合
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) IS NOT NULL 
    AND (SELECT value FROM dialysis_item_procedure_tag_info WHERE key2 = mp.in_hospital_cd_a1) <> ''''
UNION
SELECT
    --23処置薬品名(手技なし薬剤)
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE mmd.in_hospital_cd_1 END), '''') AS e01, 
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
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-'' || (medi->>''no'') || ''-''|| ''2'' AS e09 
FROM
    ord_main ord
    cross join lateral json_array_elements (ord.ind_medi_info :: json) medi
LEFT OUTER JOIN
    mst_medicine_mix mmx
ON
    mmx.medicine_mix_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_medicine mmd
ON
    mmd.medicine_cd = TO_NUMBER(medi ->> ''cd'',''999999999999'')
LEFT OUTER JOIN
    mst_procedure mp
ON
    mp.procedure_cd = TO_NUMBER(medi ->> ''procedure_cd'',''999999999999'')
WHERE
    ord.ord_no = @ordNo
 
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
    --24指示受け確認者
    ''予約詳細'' AS detail_id, 
    --項目コード
    COALESCE(pia.approve_user1_cd :: TEXT, '''') AS e01, 
    --項目属性
    COALESCE((SELECT value FROM item_set_info WHERE key2 = ''ITEM_CHECK_STAFF_ATTR''), '''') AS e02, 
    --項目名称
    COALESCE(@userName :: TEXT, '''') AS e03, 
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
    COALESCE((SELECT value FROM item_sort_info WHERE key2 = ''ITEM_CHECK_STAFF''), '''') AS e09 
FROM
    pat_ind_approve pia
WHERE
    pia.ord_no = @ordNo

    AND (SELECT value FROM fji_com_info WHERE key2 = ''CHECK_STAFF_SEND_FLAG'') = ''1''
) all_cost
WHERE 
 all_cost.e09 IS NOT NULL AND all_cost.e09 <> ''''
 AND all_cost.e01 != '''' AND all_cost.e01 IS NOT NULL
order by all_cost.e09
)
, data_all AS (
SELECT data_middle_all.detail_id, data_middle_all.e01, data_middle_all.e02, data_middle_all.e03, data_middle_all.e04, data_middle_all.e05, data_middle_all.e06, data_middle_all.e07, data_middle_all.e08, data_middle_all.e09
       , mmd.medicine_cd, mmd.class_cd 
FROM data_middle_all 
    LEFT JOIN mst_medicine mmd ON data_middle_all.e01 = mmd.in_hospital_cd_1
)
, order_code_F AS (
SELECT DISTINCT ON (item_cd_f)* FROM (
  SELECT
    e01 AS item_cd_f,  
    CASE WHEN ''1'' in (SELECT a1 FROM do_order_data_from) THEN TO_NUMBER( medi_class_code_order :: text, ''999999999999'' ) ELSE NULL END AS class_cd_f,
    CASE WHEN ''3'' in (SELECT a1 FROM do_order_data_from) THEN TO_NUMBER( medi_code_order :: text, ''999999999999'' ) ELSE NULL END AS medi_cd_f
  FROM
    data_all
    LEFT OUTER JOIN do_mstmedi_cd ON medi_code = data_all.medicine_cd
    LEFT OUTER JOIN do_mstmedi_class_cd ON medi_class_code = data_all.class_cd
  ORDER BY item_cd_f asc) AS order_code_middle_A    
)
, order_code_S AS (
SELECT DISTINCT ON (item_cd_s)* FROM (
  SELECT
    (SELECT in_hospital_cd_1 FROM mst_medicine WHERE medicine_cd = TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'')) AS item_cd_s,
    CASE WHEN ''0'' in (SELECT a1 FROM do_order_data_from) THEN TO_NUMBER( json_idx :: text, ''999999999999'' ) ELSE NULL END AS login_ord_s,
    CASE WHEN ''2'' in (SELECT a1 FROM do_order_data_from) THEN TO_NUMBER( medi ->> ''medicine_type'' :: text, ''999999999999'' ) ELSE NULL END AS medicine_type_s,
    CASE WHEN ''4'' in (SELECT a1 FROM do_order_data_from) THEN TO_NUMBER( medi ->> ''timing_cd'' :: text, ''999999999999'' ) ELSE NULL END AS timing_cd_s,
    CASE WHEN ''5'' in (SELECT a1 FROM do_order_data_from) THEN TO_NUMBER( medi ->> ''procedure_cd'' :: text, ''999999999999'' ) ELSE NULL END AS procedure_cd_s,
    CASE WHEN ''6'' in (SELECT a1 FROM do_order_data_from) THEN TO_NUMBER( medi ->> ''date_interval'' :: text, ''999999999999'' ) ELSE NULL END AS date_interval_s
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) with ordinality as tmp(medi, json_idx)
  WHERE ord.ord_no = @ordNo

  ORDER BY item_cd_s, login_ord_s asc) AS order_code_middle_B
)
, dataAndOrder AS (
SELECT
    DISTINCT detail_id, e01, e02, e03, e04, e05, e06, e07, e08, e09,
    (SELECT login_ord_s FROM order_code_S WHERE order_code_S.item_cd_s = e01) AS login_ord,
    (SELECT class_cd_f FROM order_code_F WHERE order_code_F.item_cd_f = e01) AS class_cd, 
    (SELECT medicine_type_s FROM order_code_S WHERE order_code_S.item_cd_s = e01) AS medicine_type, 
    (SELECT medi_cd_f FROM order_code_F WHERE order_code_F.item_cd_f = e01) AS medi_cd,
    (SELECT timing_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = e01) AS timing_cd, 
    (SELECT procedure_cd_s FROM order_code_S WHERE order_code_S.item_cd_s = e01) AS procedure_cd, 
    (SELECT date_interval_s FROM order_code_S WHERE order_code_S.item_cd_s = e01) AS date_interval
FROM
    data_all
)
, order_code_up_S AS (
SELECT DISTINCT ON (e01s)* FROM (
  SELECT 
    CASE WHEN (SELECT in_hospital_cd_1 FROM mst_equipment AS meq 
                   WHERE meq.equipment_cd = TO_NUMBER(equip ->> ''cd'' :: text, ''999999999999'') 
                     AND meq.in_hospital_cd_1 IS NOT NULL) IS NULL
         THEN (SELECT in_hospital_cd_1 FROM mst_dialyzer AS dia 
                   WHERE dia.dialyzer_cd = TO_NUMBER(equip ->> ''cd'' :: text, ''999999999999'') 
                     AND dia.in_hospital_cd_1 IS NOT NULL)
         ELSE (SELECT in_hospital_cd_1 FROM mst_equipment AS meq 
                   WHERE meq.equipment_cd = TO_NUMBER(equip ->> ''cd'' :: text, ''999999999999'') 
                     AND meq.in_hospital_cd_1 IS NOT NULL) END AS e01s,
    CASE WHEN 0 in (SELECT ora FROM do_order_data_from1) THEN TO_NUMBER(json_idx :: text, ''999999999999'') ELSE NULL END AS login_ord_s
  FROM
    ord_main AS ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_equip_info :: json) with ordinality as tmp(equip, json_idx)
  WHERE
    ord.ord_no = @ordNo
  ORDER BY e01s, login_ord_s asc) AS order_code_middle_S
)
, data_middle_all1 AS (
select 
 ''指示医材'' as detail_id,
 row_number() over() as equip_no,
 all_equip.equip_class_type as class,
 all_equip.cd1 as cd1,
 all_equip.cd2 as cd2,
 all_equip.cd3 as cd3,
 all_equip.cd4 as cd4,
 all_equip.equip_name as name,
 ((COALESCE(all_equip.amount, ''0'')::FLOAT))::INTEGER AS amount,
 all_equip.unit as unit,
 all_equip.syoumouhinOrder as syoumouhinOrder
from
(select
  ''吸着器'' as equip_class_type,
  --ord.ind_cond_info->''6''->>''value_name_1'' as name,
  meqad.equipment_name as equip_name,
  trim(meqad.in_hospital_cd_1) as cd1,--吸着器コード１
  trim(meqad.in_hospital_cd_2) as cd2,
  trim(meqad.in_hospital_cd_3) as cd3,
  trim(meqad.in_hospital_cd_4) as cd4,
  ''1'' as amount,
  meqad.unit,
    1 as syoumouhinOrder
from
  ord_main as ord
  left outer join
  mst_equipment as meqad
 on
  meqad.equipment_cd = TO_NUMBER (ord.ind_cond_info->''6''->>''value'',''999999999999'')
where
  ord.ord_no = @ordNo
 union
 select
  ''1次膜'' as equip_class_type,
  --ord.ind_cond_info->''7''->>''value_name_1'' as primary_film,
  meqpr.equipment_name as equip_name,
  trim(meqpr.in_hospital_cd_1) as cd1,--1次膜コード１
  trim(meqpr.in_hospital_cd_2) as cd2,
  trim(meqpr.in_hospital_cd_3) as cd3,
  trim(meqpr.in_hospital_cd_4) as cd4,
  ''1'' as amount,
  meqpr.unit,
    2 as syoumouhinOrder
 from
  ord_main as ord
  left outer join
  mst_equipment as meqpr
  on
  meqpr.equipment_cd = TO_NUMBER (ord.ind_cond_info->''7''->>''value'',''999999999999'')
 where
  ord.ord_no = @ordNo
 union
 select
  ''2次膜'' as equip_class_type,
  --ord.ind_cond_info->''8''->>''value_name_1'' as secondary_film,
  meqse.equipment_name as equip_name,
  trim(meqse.in_hospital_cd_1) as cd1,--2次膜コード１
  trim(meqse.in_hospital_cd_2) as cd2,
  trim(meqse.in_hospital_cd_3) as cd3,
  trim(meqse.in_hospital_cd_4) as cd4,
  ''1'' as amount,
  meqse.unit,
    3 as syoumouhinOrder
 from
  ord_main as ord
  left outer join
  mst_equipment as meqse
  on
  meqse.equipment_cd = TO_NUMBER (ord.ind_cond_info->''8''->>''value'',''999999999999'')
 where
  ord.ord_no = @ordNo
 union
 select
  ''穿刺針A'' as equip_class_type,
  --ord.ind_cond_info->''9''->>''value_name_1'' as puncture_needle_a,
  meqa.equipment_name as equip_name,
  trim(meqa.in_hospital_cd_1) as cd1,--穿刺針Aコード１
  trim(meqa.in_hospital_cd_2) as cd2,
  trim(meqa.in_hospital_cd_3) as cd3,
  trim(meqa.in_hospital_cd_4) as cd4,
  ''1'' as amount,
  meqa.unit,
    4 as syoumouhinOrder
 from
  ord_main ord
  left outer join
  mst_equipment as meqa
  on
  meqa.equipment_cd = TO_NUMBER (ord.ind_cond_info->''9''->>''value'',''999999999999'')
 where
  ord.ord_no = @ordNo
 union
 select
  ''穿刺針V'' as equip_class_type,
  --ord.ind_cond_info->''10''->>''value_name_1'' as puncture_needle_v,
  meqv.equipment_name as equip_name,
  trim(meqv.in_hospital_cd_1) as cd1,--穿刺針Vコード１
  trim(meqv.in_hospital_cd_2) as cd2,
  trim(meqv.in_hospital_cd_3) as cd3,
  trim(meqv.in_hospital_cd_4) as cd4,
  ''1'' as amount,
  meqv.unit,
    4 as syoumouhinOrder
 from
  ord_main ord
  left outer join
  mst_equipment as meqv
 on
  meqv.equipment_cd = TO_NUMBER (ord.ind_cond_info->''10''->>''value'',''999999999999'')
 where
  ord.ord_no = @ordNo
 union
 select
  ''穿刺針SN'' as equip_class_type,
  --ord.ind_cond_info->''11''->>''value_name_1'' as puncture_needle_sn,
  meqsn.equipment_name as equip_name,
  trim(meqsn.in_hospital_cd_1) as cd1,--穿刺針SNコード１
  trim(meqsn.in_hospital_cd_2) as cd2,
  trim(meqsn.in_hospital_cd_3) as cd3,
  trim(meqsn.in_hospital_cd_4) as cd4,
  ''1'' as amount,
  meqsn.unit,
    4 as syoumouhinOrder
 from
  ord_main ord
  left outer join
  mst_equipment as meqsn
 on
  meqsn.equipment_cd = TO_NUMBER (ord.ind_cond_info->''11''->>''value'',''999999999999'')
 where
  ord.ord_no = @ordNo
 union
 select
  ''血液回路'' as equip_class_type,
  --ord.ind_cond_info->''13''->>''value'' as blood_circuit,
  meqbc.equipment_name as equip_name,
  trim(meqbc.in_hospital_cd_1) as cd1, --血液回路コード１
  trim(meqbc.in_hospital_cd_2) as cd2,
  trim(meqbc.in_hospital_cd_3) as cd3,
  trim(meqbc.in_hospital_cd_4) as cd4,
  ''1'' as amount,
  meqbc.unit,
    5 as syoumouhinOrder
 from
  ord_main as ord
  left outer join
  mst_equipment as meqbc
 on
  meqbc.equipment_cd = TO_NUMBER (ord.ind_cond_info->''13''->>''value'',''999999999999'')
 where
  ord.ord_no = @ordNo
 union
 select
   --equip ->> ''class_type'' as equip_class_type,
   --equip ->> ''name'' as equip_name,
   meqc.class_name  as equip_class_type,
   meq.equipment_name as equip_name,
   trim(meq.in_hospital_cd_1) as cd1,
   trim(meq.in_hospital_cd_2) as cd2,
   trim(meq.in_hospital_cd_3) as cd3,
   trim(meq.in_hospital_cd_4) as cd4,
   equip ->> ''amount'' as equip_amount,
   meq.unit as equip_unit,
     6 as syoumouhinOrder
 from
   ord_main as ord
   cross join lateral json_array_elements (ord.ind_equip_info :: json) equip
   left outer join mst_equipment as meq
   on meq.equipment_cd = TO_NUMBER (equip ->> ''cd'',''999999999999'')
     left join mst_equipment_class as meqc
     on meq.class_cd = meqc.class_cd
 where
   --meq.class_cd = meqc.class_cd and
   ord.ord_no = @ordNo
) all_equip
where
  all_equip.cd1 is not null
)
, do_data_group AS (
SELECT 
    (detail_id:: text) as detail_id, cd1, name, sum(amount) as amount
        , CASE WHEN SUM(syoumouhinOrder) > 6 THEN SUM(syoumouhinOrder) - 6 ELSE SUM(syoumouhinOrder) END AS syoumouhinOrder
FROM  
    data_middle_all1
GROUP BY cd1, detail_id :: text, name
)
, data_all1 AS (
 SELECT DISTINCT do_data_group.detail_id AS detail_id, do_data_group.cd1 AS cd1, cd2, cd3, cd4, do_data_group.name AS name, do_data_group.amount AS amount, unit, 
        do_data_group.syoumouhinOrder AS syoumouhinOrder
 FROM do_data_group
      LEFT JOIN data_middle_all1 ON data_middle_all1.cd1 = do_data_group.cd1
)
, order_code_up_F AS (
SELECT DISTINCT ON (e01f)* FROM (
  SELECT 
    meq.in_hospital_cd_1 AS e01f
    , CASE WHEN 1 in (SELECT ora FROM do_order_data_from1) THEN TO_NUMBER(do_mstmeq_class_cd.meq_class_code_order :: text, ''999999999999'') ELSE NULL END AS cl_cd_f
    , CASE WHEN 2 in (SELECT ora FROM do_order_data_from1) THEN TO_NUMBER(do_mstmeq_cd.meq_code_order :: text, ''999999999999'') ELSE NULL END AS eq_cd_f
  FROM
    do_mstmeq_cd
    LEFT JOIN mst_equipment AS meq ON do_mstmeq_cd.meq_code = meq.equipment_cd
    LEFT JOIN do_mstmeq_class_cd ON do_mstmeq_class_cd.meq_class_code = meq.class_cd
  WHERE meq.in_hospital_cd_1 IS NOT NULL
  ORDER BY e01f asc) AS order_code_middle_F
)
, do_data AS (
SELECT detail_id, cd1, cd2, cd3, cd4, name, amount, unit, syoumouhinOrder
    , (SELECT login_ord_s FROM order_code_up_S WHERE e01s = cd1) AS lin_ord
    , CASE WHEN (SELECT cl_cd_f FROM order_code_up_F WHERE e01f = cd1) IS NULL THEN 0 ELSE (SELECT cl_cd_f FROM order_code_up_F WHERE e01f = cd1) END AS cl_cd 
    , (SELECT eq_cd_f FROM order_code_up_F WHERE e01f = cd1) AS eq_cd
FROM  data_all1
)
SELECT
    da.detail_id, da.e01, da.e02, da.e03, da.e04, da.e05, da.e06, da.e07, da.e08, da.e09, da.login_ord, da.class_cd, da.medicine_type, da.medi_cd, da.timing_cd, da.procedure_cd, da.date_interval, dd.lin_ord, dd.cl_cd, dd.eq_cd
FROM
    dataAndOrder da,
		do_data dd
ORDER BY 
    e09,
		CASE WHEN (SELECT ora FROM do_order_data_from1 WHERE no2 = 1) = 0 THEN lin_ord
         WHEN (SELECT ora FROM do_order_data_from1 WHERE no2 = 1) = 1 THEN cl_cd
         WHEN (SELECT ora FROM do_order_data_from1 WHERE no2 = 1) = 2 THEN eq_cd END,
    CASE WHEN (SELECT ora FROM do_order_data_from1 WHERE no2 = 2) = 0 THEN lin_ord
         WHEN (SELECT ora FROM do_order_data_from1 WHERE no2 = 2) = 1 THEN cl_cd
         WHEN (SELECT ora FROM do_order_data_from1 WHERE no2 = 2) = 2 THEN eq_cd END,
    CASE WHEN (SELECT ora FROM do_order_data_from1 WHERE no2 = 3) = 0 THEN lin_ord
         WHEN (SELECT ora FROM do_order_data_from1 WHERE no2 = 3) = 1 THEN cl_cd
         WHEN (SELECT ora FROM do_order_data_from1 WHERE no2 = 3) = 2 THEN eq_cd END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 1) = ''6'' THEN date_interval END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 2) = ''6'' THEN date_interval END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 3) = ''6'' THEN date_interval END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 4) = ''6'' THEN date_interval END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 5) = ''6'' THEN date_interval END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 6) = ''6'' THEN date_interval END,
    CASE WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''0'' THEN login_ord
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''1'' THEN class_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''2'' THEN medicine_type
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''3'' THEN medi_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''4'' THEN timing_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''5'' THEN procedure_cd
         WHEN (SELECT a1 FROM do_order_data_from WHERE no2 = 7) = ''6'' THEN date_interval END
limit 135', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通：透析予約繰り返し部', '2020-05-08 16:22:41', CURRENT_TIMESTAMP, '[{"sql_cd": -20, "field_name": "in_out", "replace_var": "@inOut"}, {"sql_cd": -37, "field_name": "user_name", "replace_var": "@userName"}]');
