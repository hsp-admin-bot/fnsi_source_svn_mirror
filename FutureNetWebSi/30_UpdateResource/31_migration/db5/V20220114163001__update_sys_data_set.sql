delete from "sys_data_set" where "sql_cd" in (-23,-25,-39);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-23, 'WITH order_time_type_info AS ( 
  -- オーダ時間の設定値に応じた時間
  SELECT
    0 AS order_no
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS order_time_type 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info->>''key1'' = ''EXAMIN_INFO''
    AND info->>''key2'' = ''SET_ORDER_TIME_TYPE''
  UNION
  SELECT
    1 AS order_no
    , ''1'' AS order_time_type 
  ORDER BY order_no ASC LIMIT 1
) 
, order_time_info AS ( 
  -- オーダ時間に設定する値
  SELECT
    info->>''key2'' AS key2
    , COALESCE(NULLIF(info->>''value'', ''''), COALESCE(NULLIF(info->>''default_v'', ''''), ''777700'')) AS order_time
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info->>''key1'' = ''EXAMIN_INFO''
    AND info->>''key2'' IN (''ORDER_TIME_AFTER'', ''ORDER_TIME_BEFORE'', ''ORDER_TIME_OTHER'')
  UNION
  SELECT
    ''DEFAULT'' AS key2
    , ''777700'' AS order_time
  ORDER BY key2 ASC
) 
, margin_time_info AS ( 
  -- 検査時刻マージン時間:透析前/透析後マージン時間
  SELECT
    info->>''key2'' AS key2
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS margin_time 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info->>''key1'' = ''EXAM_MARGIN_TIME''
    AND info->>''key2'' IN (''DIAL_AFTER'', ''DIAL_BEFORE'')
) 
, data_info AS (
  SELECT
    TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'') AS exam_date
    , pem.reg_order_class
    , ( 
      CASE pem.reg_order_class 
        WHEN ''1'' THEN COALESCE(ord.ind_treat_start_time, ''0000'') 
        WHEN ''2'' THEN COALESCE(TO_CHAR(TO_TIMESTAMP(ord.treat_date || '' '' || SUBSTRING(ord.ind_treat_start_time, 1, 2) || '':'' || SUBSTRING(ord.ind_treat_start_time, 3, 2) || '':00'', ''YYYYMMDD HH24:MI:SS'') + (INTERVAL ''1minute'' * TO_NUMBER(COALESCE(NULLIF(ord.ind_cond_info -> ''1'' ->> ''value'', ''''), ''0''), ''FM999999'')), ''HH24MI''), ''0000'') 
        ELSE COALESCE(NULLIF(mset.other_exam_time, ''''), ''0000'') 
        END
    ) AS exam_start_time
    , COALESCE(ord.ind_treat_start_time, ''9999'') AS sort_no 
  FROM
    pat_exam_main pem 
    CROSS JOIN LATERAL json_array_elements(pem.order_exam_set_info ::json) set_info 
    LEFT OUTER JOIN mst_exam_set AS mset ON set_info->>''set_cd'' = (mset.exam_set_cd ::TEXT) 
    LEFT OUTER JOIN ord_main AS ord ON ord.pat_id = pem.pat_id AND ord.treat_date = TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'') 
  WHERE
    exam_main_cd = @ordNo
  ORDER BY sort_no ASC, mset.exam_set_cd DESC LIMIT 1
)
SELECT 
  0 AS order_no
  , exam_date
  , CASE reg_order_class 
    WHEN ''1'' THEN TO_CHAR(TO_TIMESTAMP(exam_date || exam_start_time || ''00'', ''YYYYMMDDHH24MISS'') - (INTERVAL ''1minute'' * TO_NUMBER(COALESCE(NULLIF((SELECT margin_time FROM margin_time_info WHERE key2 = ''DIAL_BEFORE''), ''''), ''0''), ''FM999999'')), ''HH24MISS'')
    WHEN ''2'' THEN TO_CHAR(TO_TIMESTAMP(exam_date || exam_start_time || ''00'', ''YYYYMMDDHH24MISS'') + (INTERVAL ''1minute'' * TO_NUMBER(COALESCE(NULLIF((SELECT margin_time FROM margin_time_info WHERE key2 = ''DIAL_AFTER''), ''''), ''0''), ''FM999999'')), ''HH24MISS'')
    ELSE data_info.exam_start_time || ''00''
    END AS exam_start_time
FROM 
  data_info
WHERE 
  (SELECT order_time_type FROM order_time_type_info) = ''1''
  AND COALESCE(NULLIF(exam_start_time, ''''), ''0000'') <> ''0000''
UNION
SELECT
  1 AS order_no 
  , exam_date
  , CASE reg_order_class 
    WHEN ''1'' THEN COALESCE(NULLIF((SELECT order_time FROM order_time_info WHERE key2 = ''ORDER_TIME_BEFORE''), ''''), (SELECT order_time FROM order_time_info WHERE key2 = ''DEFAULT''))
    WHEN ''2'' THEN COALESCE(NULLIF((SELECT order_time FROM order_time_info WHERE key2 = ''ORDER_TIME_AFTER''), ''''), (SELECT order_time FROM order_time_info WHERE key2 = ''DEFAULT''))
    ELSE COALESCE(NULLIF((SELECT order_time FROM order_time_info WHERE key2 = ''ORDER_TIME_OTHER''), ''''), (SELECT order_time FROM order_time_info WHERE key2 = ''DEFAULT''))
    END AS exam_start_time
FROM 
  data_info
ORDER BY order_no ASC LIMIT 1
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）検査依頼：検査日時取得', '2020-05-11 15:02:47.001', '2020-05-11 15:02:52', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-25, 'WITH examin_info AS ( 
  -- 血液検査情報
  SELECT
    info->>''key2'' AS key2
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info->>''key1'' = ''EXAMIN_INFO''
) 
, order_class_info AS ( 
  -- 透析前後変換(->電子カルテ)
  SELECT
    info->>''key2'' AS key2
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info->>''key1'' = ''CONV_EXAMIN_ORDER_CLASS_TO_KARTE''
)  
, examin_hosp_code_info AS ( 
  -- 検体検査用の院内コード
  SELECT
    info->>''key2'' AS key2 -- 検体検査の院内コード
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info->>''key1'' = ''EXAMIN_IN_HOSP_CODE'' -- TODO：[検査オーダ種別判定]不明、EXAMIN_IN_HOSP_CODEを設定する
) 
, material_name_info AS ( 
  -- 検査セットに対応する材料名称
  SELECT
    info->>''key2'' AS key2
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info->>''key1'' = ''MATERIAL_NAME_INFO''
) 
, roometc_data AS ( 
  --治療情報から、ベッドグループ名とクール名(透析室・クール・フロア)
  SELECT
    ord.ind_kur_cd
    , kur.kur_cd
    , kur.kur_name
    , kur.in_hospital_cd_1 AS in_hospital_cd_kur
    , ord.ind_bed_cd
    , bed.bed_cd
    , bed.bed_name
    , bed.in_hospital_cd_1 AS in_hospital_cd_bed
    , CASE 
      WHEN POSITION(''_'' IN room.room_bed_group_name) > 0 THEN split_part(room.room_bed_group_name, ''_'', 1) 
      WHEN POSITION(''-'' IN room.room_bed_group_name) > 0 THEN split_part(room.room_bed_group_name, ''-'', 1) 
      ELSE room.room_bed_group_name 
      END AS room_bed_group_name
    , room.in_hospital_cd_1 AS in_hospital_cd_room 
  FROM
    pat_exam_main AS exam 
    LEFT OUTER JOIN ord_main AS ord ON ord.pat_id = exam.pat_id AND ord.treat_date = TO_CHAR(exam.reg_exam_date, ''YYYYMMDD'') 
    LEFT OUTER JOIN mst_bed AS bed ON bed.bed_cd = ord.ind_bed_cd 
    LEFT OUTER JOIN mst_room_bed_group AS room 
    CROSS JOIN LATERAL jsonb_array_elements(room.bed_list ::jsonb) bedlist ON bedlist ::TEXT = bed.bed_cd ::TEXT 
    LEFT OUTER JOIN mst_kur AS kur ON kur.kur_cd = ord.ind_kur_cd 
  WHERE
    exam_main_cd = @ordNo 
  ORDER BY
    room.room_bed_group_cd DESC LIMIT 1
) 
, room_info AS ( 
  -- 透析室
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(split_part(COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v''), '','', 1), '''') 
      , COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''DEFAULT_ROOM_CODE''), ''''), ''V1'')
    ) AS item_code
    , COALESCE(NULLIF(split_part(COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v''), '','', 2), '''') 
      , COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''DEFAULT_ROOM_NAME''), ''''), ''第一透析室'')
    ) AS item_name 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info->>''key1'' = ''EXAM_CONV_ROOM'' 
    AND info->>''key2'' = COALESCE(NULLIF((SELECT room_bed_group_name FROM roometc_data), ''''), '''') 
  UNION 
  SELECT
    2 AS order_no
    , COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''DEFAULT_ROOM_CODE''), ''''), ''V1'') AS item_code
    , COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''DEFAULT_ROOM_NAME''), ''''), ''第一透析室'') AS item_name 
  ORDER BY
    order_no ASC LIMIT 1
) 
, floor_info AS ( 
  -- フロア
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(split_part(COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v''), '','', 1), '''') 
      , COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''DEFAULT_FLOOR_CODE''), ''''), ''VA'')
    ) AS item_code
    , COALESCE(NULLIF(split_part(COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v''), '','', 2), '''') 
      , COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''DEFAULT_FLOOR_NAME''), ''''), ''フロアＡ'')
    ) AS item_name 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info->>''key1'' = ''EXAM_CONV_FLOOR'' 
    AND info->>''key2'' = COALESCE(NULLIF((SELECT room_bed_group_name FROM roometc_data), ''''), '''') 
  UNION 
  SELECT
    2 AS order_no
    , COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''DEFAULT_FLOOR_CODE''), ''''), ''VA'') AS item_code
    , COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''DEFAULT_FLOOR_NAME''), ''''), ''フロアＡ'') AS item_name 
  ORDER BY
    order_no ASC LIMIT 1
) 
, kur_info AS ( 
  -- クール
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(split_part(COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v''), '','', 1), '''') 
      , COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''DEFAULT_KUR_CODE''), ''''), ''VD'')
    ) AS item_code
    , COALESCE(NULLIF(split_part(COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v''), '','', 2), '''') 
      , COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''DEFAULT_KUR_NAME''), ''''), ''昼'')
    ) AS item_name 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info->>''key1'' = ''EXAM_CONV_KUR'' 
    AND info->>''key2'' = COALESCE(NULLIF((SELECT kur_name FROM roometc_data), ''''), '''') 
  UNION 
  SELECT
    2 AS order_no
    , COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''DEFAULT_KUR_CODE''), ''''), ''VD'') AS item_code
    , COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''DEFAULT_KUR_NAME''), ''''), ''昼'') AS item_name 
  ORDER BY
    order_no ASC LIMIT 1
) 
-- 3.7.4.3.1 材料情報を付与しない場合：①検査項目コード
SELECT
  1 AS order_no
  , 0 AS set_cd
  , 0 AS set_order_flag
  , ''検査項目'' AS detail_id
  , item.in_hospital_cd1 AS in_hospital_cd1
  , COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''EXAM_ITEM_ATTR''), ''''), ''ET1'') AS sbt_cd1
  , order_info->>''item_name'' AS item_name
  , CASE WHEN COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''SET_NAME_TO_TAG_NAME''), ''''), ''1'') = ''1'' 
      THEN set_info->>''set_name'' 
    ELSE '''' 
    END AS tag_name 
FROM
  pat_exam_main AS exam 
  CROSS JOIN LATERAL json_array_elements(exam.exam_order_info ::json) order_info 
  LEFT OUTER JOIN json_array_elements(exam.order_exam_set_info ::json) set_info ON set_info->>''no'' = order_info->>''no'' 
  LEFT OUTER JOIN mst_exam_item AS item ON order_info->>''item_cd'' = (item.exam_item_cd ::TEXT) 
WHERE
  exam.is_del = ''0'' 
  AND jsonb_array_length(exam.exam_order_info) > 0 
  AND jsonb_array_length(exam.order_exam_set_info) > 0 
  AND COALESCE(NULLIF(item.in_hospital_cd1, ''''), ''no_cd'') <> ''no_cd'' 
  AND ((SELECT COUNT(1) FROM examin_hosp_code_info) = 0 -- 検体検査の院内コードを設定が存在しない場合は全て送信対象とする。
   OR EXISTS (SELECT 1 FROM examin_hosp_code_info AS hosp WHERE COALESCE(NULLIF(item.in_hospital_cd1, ''''), ''no_cd'') = hosp.key2)
    -- 院内コードをキーとして連携IDを設定するの場合は送信対象とする。
  )
  AND COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''MATERIAL_SEND_FLAG''), ''''), ''1'') = ''0'' 
  AND exam.exam_main_cd = @ordNo 
-- 3.7.4.3.2 材料情報を付与する場合：①材料情報、②検査項目コード
-- ①材料情報
UNION ALL
SELECT
  2 AS order_no
  , CAST(set_info->>''set_cd'' AS INTEGER) AS set_cd
  , 0 AS set_order_flag
  , ''検査項目'' AS detail_id
  , mset.in_hospital_cd1 AS in_hospital_cd1
  , COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''MATERIAL_ITEM_ATTR''), ''''), ''EZ1'') AS sbt_cd1
  , COALESCE(NULLIF((SELECT VALUE FROM material_name_info WHERE key2 = COALESCE(mset.in_hospital_cd1, '''')), ''''), (''不明材料'' || mset.in_hospital_cd1)) AS item_name
  , '''' AS tag_name 
FROM
  pat_exam_main AS exam 
  CROSS JOIN LATERAL json_array_elements(exam.order_exam_set_info ::json) set_info 
  LEFT OUTER JOIN mst_exam_set AS mset ON set_info->>''set_cd'' = (mset.exam_set_cd ::TEXT) 
WHERE
  exam.is_del = ''0'' 
  AND jsonb_array_length(exam.order_exam_set_info) > 0 
  AND COALESCE(NULLIF(mset.in_hospital_cd1, ''''), ''no_cd'') <> ''no_cd''
  AND ((SELECT COUNT(1) FROM examin_hosp_code_info) = 0 -- 検体検査の院内コードを設定が存在しない場合は全て送信対象とする。
   OR EXISTS (SELECT 1 FROM examin_hosp_code_info AS hosp WHERE COALESCE(NULLIF(mset.in_hospital_cd1, ''''), ''no_cd'') = hosp.key2)
    -- 院内コードをキーとして連携IDを設定するの場合は送信対象とする。
  )
  AND COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''MATERIAL_SEND_FLAG''), ''''), ''1'') = ''1'' 
  AND exam.exam_main_cd = @ordNo 
-- ②検査項目コード
UNION ALL
SELECT
  2 AS order_no
  , CAST(set_info->>''set_cd'' AS INTEGER) AS set_cd
  , 1 AS set_order_flag
  , ''検査項目'' AS detail_id
  , item.in_hospital_cd1 AS in_hospital_cd1
  , COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''EXAM_ITEM_ATTR''), ''''), ''ET1'') AS sbt_cd1
  , order_info->>''item_name'' AS item_name
  , '''' AS tag_name 
FROM
  pat_exam_main AS exam 
  CROSS JOIN LATERAL json_array_elements(exam.order_exam_set_info ::json) set_info 
  LEFT OUTER JOIN mst_exam_set AS mset ON set_info->>''set_cd'' = (mset.exam_set_cd ::TEXT) 
  LEFT OUTER JOIN json_array_elements(exam.exam_order_info ::json) order_info  ON order_info->>''no'' = set_info->>''no'' 
  LEFT OUTER JOIN mst_exam_item AS item ON order_info->>''item_cd'' = (item.exam_item_cd ::TEXT) 
WHERE
  exam.is_del = ''0'' 
  AND jsonb_array_length(exam.exam_order_info) > 0 
  AND jsonb_array_length(exam.order_exam_set_info) > 0 
  AND COALESCE(NULLIF(item.in_hospital_cd1, ''''), ''no_cd'') <> ''no_cd'' 
  AND COALESCE(NULLIF(mset.in_hospital_cd1, ''''), ''no_cd'') <> ''no_cd'' 
  AND ((SELECT COUNT(1) FROM examin_hosp_code_info) = 0 -- 検体検査の院内コードを設定が存在しない場合は全て送信対象とする。
   OR EXISTS (SELECT 1 FROM examin_hosp_code_info AS hosp WHERE COALESCE(NULLIF(item.in_hospital_cd1, ''''), ''no_cd'') = hosp.key2)
    -- 院内コードをキーとして連携IDを設定するの場合は送信対象とする。
  )
  AND COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''MATERIAL_SEND_FLAG''), ''''), ''1'') = ''1'' 
  AND exam.exam_main_cd = @ordNo 
-- 3.7.4.3.3 透析前後区分の設定
UNION ALL
SELECT
  3 AS order_no
  , 0 AS set_cd
  , 0 AS set_order_flag
  , ''検査項目'' AS detail_id
  , COALESCE(NULLIF((SELECT VALUE FROM order_class_info WHERE key2 = exam.reg_order_class), '''') , exam.reg_order_class) AS in_hospital_cd1
  , CASE exam.reg_order_class 
    WHEN ''1'' THEN COALESCE(NULLIF((SELECT VALUE FROM  examin_info WHERE key2 = ''BEFORE_ORDER_CLASS_ATTR''), ''''), ''ET1'') 
    WHEN ''2'' THEN COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''AFTER_ORDER_CLASS_ATTR''), ''''), ''ET1'') 
    ELSE COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''OTHER_ORDER_CLASS_ATTR''), ''''), ''ET1'') 
    END AS sbt_cd1
  , CASE exam.reg_order_class 
    WHEN ''1'' THEN COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''BEFORE_ORDER_CLASS_NAME''), ''''), ''ET1'') 
    WHEN ''2'' THEN COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''AFTER_ORDER_CLASS_NAME''), ''''), ''ET1'') 
    ELSE COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''OTHER_ORDER_CLASS_NAME''), ''''), ''ET1'') 
    END AS item_name
  , '''' AS tag_name 
FROM
  pat_exam_main AS exam 
WHERE
  exam.is_del = ''0'' 
  AND exam.exam_main_cd = @ordNo 
-- 3.7.4.3.4 透析室
UNION ALL 
SELECT
  4 AS order_no
  , 0 AS set_cd
  , 0 AS set_order_flag
  , ''検査項目'' AS detail_id
  , (SELECT item_code FROM room_info) AS in_hospital_cd1
  , COALESCE(NULLIF( ( SELECT VALUE FROM examin_info WHERE key2 = ''ROOM_ATTR''), ''''), ''VA1'') AS sbt_cd1
  , (SELECT item_name FROM room_info) AS item_name
  , '''' AS tag_name 
WHERE
  COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''ROOMETC_OUTPUT_FLAG''), ''''), ''1'') = ''1'' 
-- 3.7.4.3.5 クール
UNION ALL 
SELECT
  5 AS order_no
  , 0 AS set_cd
  , 0 AS set_order_flag
  , ''検査項目'' AS detail_id
  , (SELECT item_code FROM kur_info) AS in_hospital_cd1
  , COALESCE(NULLIF( ( SELECT VALUE FROM examin_info WHERE key2 = ''KUR_ATTR''), ''''), ''VA2'') AS sbt_cd1
  , (SELECT item_name FROM kur_info) AS item_name
  , '''' AS tag_name 
WHERE
  COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''ROOMETC_OUTPUT_FLAG''), ''''), ''1'') = ''1'' 
-- 3.7.4.3.6 フロア
UNION ALL 
SELECT
  6 AS order_no
  , 0 AS set_cd
  , 0 AS set_order_flag
  , ''検査項目'' AS detail_id
  , (SELECT item_code FROM floor_info) AS in_hospital_cd1
  , COALESCE(NULLIF( ( SELECT VALUE FROM examin_info WHERE key2 = ''FLOOR_ATTR''), ''''), ''VA3'') AS sbt_cd1
  , (SELECT item_name FROM floor_info) AS item_name
  , '''' AS tag_name 
WHERE
  COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''ROOMETC_OUTPUT_FLAG''), ''''), ''1'') = ''1'' 
ORDER BY
  order_no ASC
  , set_cd ASC
  , set_order_flag ASC
  , tag_name ASC
  , in_hospital_cd1 ASC
LIMIT 299 ', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）依頼検査繰り返し部', '2020-05-12 11:09:24', '2020-05-12 11:09:28.001', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-39, 'WITH course_from_info AS ( 
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS course_from 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''EXAMIN_INFO'' 
    AND info ->> ''key2'' = ''COURSE'' 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS course_from 
  ORDER BY
    order_no ASC LIMIT 1
) 
, course_code_info AS ( 
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS course_code 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''EXAMIN_INFO'' 
    AND info ->> ''key2'' = ''COURSE_CODE'' 
  UNION 
  SELECT
    2 AS order_no
    , '''' AS course_code 
  ORDER BY
    order_no ASC LIMIT 1
) 
, ward_from_info AS ( 
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS ward_from 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''EXAMIN_INFO'' 
    AND info ->> ''key2'' = ''WARD'' 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS ward_from 
  ORDER BY
    order_no ASC LIMIT 1
) 
, ward_code_info AS ( 
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS ward_code 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''EXAMIN_INFO'' 
    AND info ->> ''key2'' = ''WARD_CODE'' 
  UNION 
  SELECT
    2 AS order_no
    , '''' AS ward_code 
  ORDER BY
    order_no ASC LIMIT 1
) 
, exam_info AS ( 
  SELECT
    medical_care_info ->> ''ward_cd'' AS ward_cd
    , ward.ward_name AS ward_name
    , ward.in_hospital_cd_1 AS ward_in_hospital_cd
    , medical_care_info ->> ''main_course_cd'' AS main_course_cd
    , course.course_name AS course_name
    , course.in_hospital_cd_1 AS course_in_hospital_cd 
  FROM
    pat_main AS main 
    LEFT JOIN mst_ward AS ward 
      ON ward.ward_cd ::TEXT = main.medical_care_info ->> ''ward_cd'' 
    LEFT JOIN mst_course AS course 
      ON course.course_cd ::TEXT = main.medical_care_info ->> ''main_course_cd'' 
  WHERE
    main.pat_id = @patId 
) 
SELECT
  CASE 
    WHEN (SELECT course_from FROM course_from_info) = ''1'' 
      THEN COALESCE(NULLIF((SELECT course_in_hospital_cd FROM exam_info), ''''), (SELECT course_code FROM course_code_info)) 
    ELSE (SELECT course_code FROM course_code_info) 
    END AS course_cd
  , CASE 
    WHEN (SELECT ward_from FROM ward_from_info) = ''1'' 
      THEN COALESCE(NULLIF((SELECT ward_in_hospital_cd FROM exam_info), ''''), (SELECT ward_code FROM ward_code_info)) 
    ELSE (SELECT ward_code FROM ward_code_info) 
    END AS ward_cd', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）検査オーダ(診療科コードと病棟コード)', '2022-01-12 18:29:49', '2022-01-12 18:29:49', NULL);
