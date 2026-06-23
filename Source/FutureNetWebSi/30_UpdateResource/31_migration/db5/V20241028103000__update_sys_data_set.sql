DELETE FROM sys_data_set WHERE sql_cd IN (-43,-44,-45,-46,-663,-66669,-66671,-800011);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-43, 'WITH examin_info AS ( 
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
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info->>''key1'' = ''EXAMIN_INFO''
) 
, pat_exam_info AS ( 
    SELECT
        exam_main_cd
        , exam_order_info
        , is_del
        , order_exam_set_info
        , pat_id
        , reg_exam_date
        , reg_order_class
        , 0 AS idx
        , up_date
    FROM pat_exam_main_hst
    WHERE exam_main_cd = @ordNo
    UNION
    SELECT 
        exam_main_cd
        , exam_order_info
        , is_del
        , order_exam_set_info
        , pat_id
        , reg_exam_date
        , reg_order_class
        , 1 AS idx
        , up_date
    FROM pat_exam_main 
    WHERE exam_main_cd = @ordNo
    ORDER BY idx ASC, up_date DESC
    LIMIT 1)
, conv_order_class_info AS ( 
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
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info->>''key1'' = ''CONV_EXAMIN_ORDER_CLASS_TO_KARTE''
)
, hosp_code_no_info AS ( 
  -- 使用院内コード番号:院内コードを指定
  SELECT
    ''0'' AS order_no 
    , CASE WHEN COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') IN (''1'', ''2'', ''3'')
      THEN COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'')
      ELSE ''1''  END AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info->>''key1'' = ''EXAMIN_INFO''
    AND info->>''key2'' = ''USE_IN_HOSP_NO''
  UNION
  SELECT
    ''1'' AS order_no 
    , ''1'' AS VALUE 
  ORDER BY order_no ASC LIMIT 1
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
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
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
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
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
    pat_exam_info AS exam 
    LEFT OUTER JOIN ord_main AS ord ON ord.pat_id = exam.pat_id AND ord.treat_date = TO_CHAR(exam.reg_exam_date, ''YYYYMMDD'') 
    LEFT OUTER JOIN mst_bed AS bed ON bed.bed_cd = ord.ind_bed_cd 
    LEFT OUTER JOIN mst_room_bed_group AS room 
    CROSS JOIN LATERAL jsonb_array_elements(room.bed_list ::jsonb) bedlist ON bedlist ::TEXT = bed.bed_cd ::TEXT 
    LEFT OUTER JOIN mst_kur AS kur ON kur.kur_cd = ord.ind_kur_cd 
  WHERE
    exam_main_cd = @ordNo 
  ORDER BY
    kur.kur_start_time ASC, room.room_bed_group_cd DESC LIMIT 1
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
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
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
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
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
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
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
  T01.order_no
  , T01.set_cd
  , T01.set_order_flag
  , T01.detail_id
  , T01.in_hospital_cd1
  , T01.sbt_cd1
  , T01.item_name
  , T01.tag_name
FROM
  (
  SELECT
    1 AS order_no
    , 0 AS set_cd
    , 0 AS set_order_flag
    , ''検査項目'' AS detail_id
    , CASE (SELECT VALUE FROM hosp_code_no_info) 
      WHEN ''1'' THEN item.in_hospital_cd1
      WHEN ''2'' THEN item.in_hospital_cd2
      WHEN ''3'' THEN item.in_hospital_cd3
      ELSE item.in_hospital_cd1
      END AS in_hospital_cd1
    , COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''EXAM_ITEM_ATTR''), ''''), ''ET1'') AS sbt_cd1
    , order_info->>''item_name'' AS item_name
    , CASE WHEN COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''SET_NAME_TO_TAG_NAME''), ''''), ''1'') = ''1'' 
        THEN set_info->>''set_name'' 
      ELSE '''' 
      END AS tag_name 
  FROM
    pat_exam_info AS exam 
    CROSS JOIN LATERAL json_array_elements(exam.exam_order_info ::json) order_info 
    LEFT OUTER JOIN json_array_elements(exam.order_exam_set_info ::json) set_info ON set_info->>''no'' = order_info->>''no'' 
    LEFT OUTER JOIN mst_exam_item AS item ON order_info->>''item_cd'' = (item.exam_item_cd ::TEXT) 
  WHERE
    exam.is_del = ''0'' 
    AND exam.exam_main_cd = @ordNo 
    AND jsonb_array_length(exam.exam_order_info) > 0 
    AND jsonb_array_length(exam.order_exam_set_info) > 0 
    AND COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''MATERIAL_SEND_FLAG''), ''''), ''1'') = ''0'' 
  ) AS T01
WHERE
  COALESCE(NULLIF(in_hospital_cd1, ''''), ''no_cd'') <> ''no_cd'' 
  AND ((SELECT COUNT(1) FROM examin_hosp_code_info) = 0 -- 検体検査の院内コードを設定が存在しない場合は全て送信対象とする。
   OR EXISTS (SELECT 1 FROM examin_hosp_code_info AS hosp WHERE COALESCE(NULLIF(in_hospital_cd1, ''''), ''no_cd'') = hosp.key2)
    -- 院内コードをキーとして連携IDを設定するの場合は送信対象とする。
  )
-- 3.7.4.3.2 材料情報を付与する場合：①材料情報、②検査項目コード
-- ①材料情報
UNION ALL
SELECT
  T01.order_no
  , T01.set_cd
  , T01.set_order_flag
  , T01.detail_id
  , T01.in_hospital_cd1
  , T01.sbt_cd1
  , COALESCE(NULLIF((SELECT VALUE FROM material_name_info WHERE key2 = COALESCE(T01.in_hospital_cd1, '''')), ''''), (''不明材料'' || T01.in_hospital_cd1)) AS item_name
  , T01.tag_name
FROM
  (
  SELECT
    2 AS order_no
    , CAST(set_info->>''set_cd'' AS INTEGER) AS set_cd
    , 0 AS set_order_flag
    , ''検査項目'' AS detail_id
    , CASE (SELECT VALUE FROM hosp_code_no_info) 
      WHEN ''1'' THEN mset.in_hospital_cd1
      WHEN ''2'' THEN mset.in_hospital_cd2
      WHEN ''3'' THEN mset.in_hospital_cd3
      ELSE mset.in_hospital_cd1
      END AS in_hospital_cd1
    , COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''MATERIAL_ITEM_ATTR''), ''''), ''EZ1'') AS sbt_cd1
    , '''' AS item_name
    , '''' AS tag_name 
  FROM
    pat_exam_info AS exam 
    CROSS JOIN LATERAL json_array_elements(exam.order_exam_set_info ::json) set_info 
    LEFT OUTER JOIN mst_exam_set AS mset ON set_info->>''set_cd'' = (mset.exam_set_cd ::TEXT) 
  WHERE
    exam.is_del = ''0'' 
    AND exam.exam_main_cd = @ordNo 
    AND jsonb_array_length(exam.order_exam_set_info) > 0 
    AND COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''MATERIAL_SEND_FLAG''), ''''), ''1'') = ''1'' 
  ) T01
WHERE
  COALESCE(NULLIF(T01.in_hospital_cd1, ''''), ''no_cd'') <> ''no_cd''
  AND ((SELECT COUNT(1) FROM examin_hosp_code_info) = 0 -- 検体検査の院内コードを設定が存在しない場合は全て送信対象とする。
   OR EXISTS (SELECT 1 FROM examin_hosp_code_info AS hosp WHERE COALESCE(NULLIF(T01.in_hospital_cd1, ''''), ''no_cd'') = hosp.key2)
    -- 院内コードをキーとして連携IDを設定するの場合は送信対象とする。
  )
-- ②検査項目コード
UNION ALL
SELECT
  T01.order_no
  , T01.set_cd
  , T01.set_order_flag
  , T01.detail_id
  , T01.in_hospital_cd1
  , T01.sbt_cd1
  , T01.item_name
  , T01.tag_name
FROM
  (
  SELECT
    2 AS order_no
    , CAST(set_info->>''set_cd'' AS INTEGER) AS set_cd
    , 1 AS set_order_flag
    , ''検査項目'' AS detail_id
    , CASE (SELECT VALUE FROM hosp_code_no_info) 
      WHEN ''1'' THEN item.in_hospital_cd1
      WHEN ''2'' THEN item.in_hospital_cd2
      WHEN ''3'' THEN item.in_hospital_cd3
      ELSE item.in_hospital_cd1
      END AS in_hospital_cd1
    , CASE (SELECT VALUE FROM hosp_code_no_info) 
      WHEN ''1'' THEN mset.in_hospital_cd1
      WHEN ''2'' THEN mset.in_hospital_cd2
      WHEN ''3'' THEN mset.in_hospital_cd3
      ELSE mset.in_hospital_cd1
      END AS in_hospital_cd_set
    , COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''EXAM_ITEM_ATTR''), ''''), ''ET1'') AS sbt_cd1
    , order_info->>''item_name'' AS item_name
    , '''' AS tag_name 
  FROM
    pat_exam_info AS exam 
    CROSS JOIN LATERAL json_array_elements(exam.order_exam_set_info ::json) set_info 
    LEFT OUTER JOIN mst_exam_set AS mset ON set_info->>''set_cd'' = (mset.exam_set_cd ::TEXT) 
    LEFT OUTER JOIN json_array_elements(exam.exam_order_info ::json) order_info  ON order_info->>''no'' = set_info->>''no'' 
    LEFT OUTER JOIN mst_exam_item AS item ON order_info->>''item_cd'' = (item.exam_item_cd ::TEXT) 
  WHERE
    exam.is_del = ''0'' 
    AND exam.exam_main_cd = @ordNo 
    AND jsonb_array_length(exam.exam_order_info) > 0 
    AND jsonb_array_length(exam.order_exam_set_info) > 0 
    AND COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''MATERIAL_SEND_FLAG''), ''''), ''1'') = ''1'' 
  ) T01
WHERE
  COALESCE(NULLIF(T01.in_hospital_cd1, ''''), ''no_cd'') <> ''no_cd'' 
  AND COALESCE(NULLIF(T01.in_hospital_cd_set, ''''), ''no_cd'') <> ''no_cd'' 
  AND ((SELECT COUNT(1) FROM examin_hosp_code_info) = 0 -- 検体検査の院内コードを設定が存在しない場合は全て送信対象とする。
   OR EXISTS (SELECT 1 FROM examin_hosp_code_info AS hosp WHERE COALESCE(NULLIF(T01.in_hospital_cd1, ''''), ''no_cd'') = hosp.key2)
    -- 院内コードをキーとして連携IDを設定するの場合は送信対象とする。
  )
-- 3.7.4.3.3 透析前後区分の設定
UNION ALL
SELECT
  3 AS order_no
  , 0 AS set_cd
  , 0 AS set_order_flag
  , ''検査項目'' AS detail_id
  , COALESCE(NULLIF((SELECT VALUE FROM conv_order_class_info WHERE key2 = exam.reg_order_class), '''') , exam.reg_order_class) AS in_hospital_cd1
  , CASE exam.reg_order_class 
    WHEN ''1'' THEN COALESCE(NULLIF((SELECT VALUE FROM  examin_info WHERE key2 = ''BEFORE_ORDER_CLASS_ATTR''), ''''), ''EC1'') 
    WHEN ''2'' THEN COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''AFTER_ORDER_CLASS_ATTR''), ''''), ''EC1'') 
    ELSE COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''OTHER_ORDER_CLASS_ATTR''), ''''), ''EC1'') 
    END AS sbt_cd1
  , CASE exam.reg_order_class 
    WHEN ''1'' THEN COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''BEFORE_ORDER_CLASS_NAME''), ''''), ''透析前'') 
    WHEN ''2'' THEN COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''AFTER_ORDER_CLASS_NAME''), ''''), ''透析後'') 
    ELSE COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''OTHER_ORDER_CLASS_NAME''), ''''), ''その他'') 
    END AS item_name
  , '''' AS tag_name 
FROM
  pat_exam_info AS exam 
WHERE
  exam.exam_main_cd = @ordNo
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
LIMIT 299 ', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '富士通）依頼検査繰り返し部 ★削除用', '2022-01-17 15:02:47.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-44, 'WITH default_user_no AS (
    -- デフォルト利用者番号（検査オーダ用）
    SELECT 0                                                            AS order_no
         , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
    FROM mst_coop_ini AS ini
             CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE facility_cd = @facilityCd
      AND is_del = ''0''
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
      AND info ->> ''key1'' = ''FJI_COM_INFO''
      AND info ->> ''key2'' = ''EXAM_DEFAULT_USER_NO''
    UNION
    SELECT 1  AS order_no
         , '''' AS staff_cd
    ORDER BY order_no ASC
    LIMIT 1)
   , pat_exam_info AS (
    SELECT 
        reg_exam_date
        , up_date
        , pat_id
        , order_exam_set_info
        , reg_order_class
        , exam_main_cd
        , up_staff
        , ind_user_id
        , 0 AS idx
    FROM pat_exam_main_hst
    WHERE exam_main_cd = @ordNo
    UNION
    SELECT 
        reg_exam_date
        , up_date
        , pat_id
        , order_exam_set_info
        , reg_order_class
        , exam_main_cd
        , up_staff
        , ind_user_id
        , 1 AS idx
    FROM pat_exam_main 
    WHERE exam_main_cd = @ordNo
    ORDER BY idx ASC, up_date DESC
    LIMIT 1)
   , user_no_setting AS (
    -- 利用者番号出力設定（検査オーダ用）
    SELECT 0                                                                                       AS order_no
         , COALESCE(NULLIF(info ->> ''value'', ''''), COALESCE(NULLIF(info ->> ''default_v'', ''''), ''0'')) AS setting
    FROM mst_coop_ini AS ini
             CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE facility_cd = @facilityCd
      AND is_del = ''0''
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
      AND info ->> ''key1'' = ''FJI_COM_INFO''
      AND info ->> ''key2'' = ''EXAM_USER_NO_SETTING''
    UNION
    SELECT 1   AS order_no
         , ''0'' AS setting
    ORDER BY order_no ASC
    LIMIT 1)
   , ind_user_info AS (
    -- 指示者
    SELECT TO_CHAR(pem.ind_user_id, ''FM9999999999'') AS staff_cd
    FROM pat_exam_info pem
    WHERE pem.exam_main_cd = @ordNo
      AND pem.ind_user_id IS NOT NULL)
   , staff_user_info AS (
    -- 担当者
    SELECT ROW_NUMBER() OVER () AS CNT
         , staff ->> ''staff_cd'' AS staff_cd
    FROM pat_main pm
             CROSS JOIN LATERAL json_array_elements(pm.charge_staff_info ::json) staff
    WHERE pm.is_del = ''0''
      AND pm.pat_id = @patId
      AND staff ->> ''is_main'' = ''1'')
   , up_user_info AS (
    -- 操作者
    SELECT TO_CHAR(pem.up_staff, ''FM9999999999'') AS staff_cd
    FROM pat_exam_info pem
    WHERE pem.exam_main_cd = @ordNo
      AND pem.up_staff IS NOT NULL),
reg_order_class as (
select reg_order_class from pat_exam_info where exam_main_cd = @ordNo order by up_date desc limit 1
),
kur_qt as(
select (staff.value ->''set_cd'')::text as exam_set_cd from pat_exam_info as pat CROSS JOIN LATERAL json_array_elements(pat.order_exam_set_info ::json) staff where pat.exam_main_cd = @ordNo order by up_date desc limit 1
),
kur_time as (
select kur_cd,kur_start_time:: time as time1,kur_end_time::time as time2 from mst_kur where facility_cd = @facilityCd and is_del = ''0''
),
ind_kur_cd3 as (
select kur_cd ::text as ind_kur_cd from kur_time where time1 <= (select other_exam_time::time as  mst_exam_set from mst_exam_set where exam_set_cd ::text = (select exam_set_cd from kur_qt )
and facility_cd = @facilityCd ) and time2 >= (select other_exam_time::time as mst_exam_set from mst_exam_set where exam_set_cd ::text = (select exam_set_cd from kur_qt )
and facility_cd = @facilityCd)

),
    ind_kur_cd1 as (
    
     select ind_kur_cd,facility_cd from ord_main where pat_id = (select pat_id from pat_exam_info where exam_main_cd = @ordNo
 order by up_date desc limit 1)
 and     date_part(''YEAR'',cast(treat_date as date))= (select date_part(''YEAR'',reg_exam_date)  from pat_exam_info where exam_main_cd = @ordNo
 order by up_date desc limit 1) 
 and     date_part(''month'',cast(treat_date as date))= (select date_part(''month'',reg_exam_date) from pat_exam_info where exam_main_cd = @ordNo
 order by up_date desc limit 1) 
 and     date_part(''day'',cast(treat_date as date))= (select date_part(''day'',reg_exam_date) from pat_exam_info where exam_main_cd = @ordNo
 order by up_date desc limit 1) 

),
    ind_kur_cd as (
     select kur_cd as ind_kur_cd from mst_kur,ind_kur_cd1 where mst_kur.kur_cd = ind_kur_cd1.ind_kur_cd and mst_kur.facility_cd = ind_kur_cd1.facility_cd
     and is_del = ''0'' order by kur_end_time  limit 1
),
weekend as( 
select EXTRACT(DOW FROM reg_exam_date)  as reg_exam_date from pat_exam_info where exam_main_cd = @ordNo order by up_date desc limit 1
),
mst_user_authenticator1 as (
select
(json_array_elements((mst.mst_user_authentication ->> ''data'')::json)->>(select  (
case when 1 =(select reg_exam_date from weekend )       
then ''Mon'' 
 when 2 =(select reg_exam_date from weekend )       
then ''Tues'' 
 when 3 =(select reg_exam_date from weekend )       
then ''Wednes'' 
 when 4 =(select reg_exam_date from weekend )       
then ''Thurs'' 
 when 5 =(select reg_exam_date from weekend)        
then ''Fri'' 
 when 6 =(select reg_exam_date from weekend)        
then ''Satur'' 
 when 0 =(select reg_exam_date from weekend)        
then ''Sun'' 
END ) as aaa))::json->>''user_id'' as staff_cd from mst_kur mst where  mst.kur_cd::text = (select ind_kur_cd from ind_kur_cd3)
and facility_cd = @facilityCd
),
mst_user_authenticator as(
select 2 as no,
(json_array_elements((mst.mst_user_authentication ->> ''data'')::json)->>
(select  (
case when 1 =(select reg_exam_date from weekend )       
then ''Mon'' 
 when 2 =(select reg_exam_date from weekend )       
then ''Tues'' 
 when 3 =(select reg_exam_date from weekend )       
then ''Wednes'' 
 when 4 =(select reg_exam_date from weekend )       
then ''Thurs'' 
 when 5 =(select reg_exam_date from weekend )       
then ''Fri'' 
 when 6 =(select reg_exam_date from weekend )       
then ''Satur'' 
 when 0 =(select reg_exam_date from weekend )       
then ''Sun'' 
END ) as aaa)
)::json->>''user_id'' as staff_cd from mst_kur mst where
facility_cd = @facilityCd
and kur_name = ''午前''
and (select ind_kur_cd from ind_kur_cd ) is null
union 
select 1 as no,
(json_array_elements((mst.mst_user_authentication ->> ''data'')::json)->>(select  (
case when 1 =(select reg_exam_date from weekend )       
then ''Mon'' 
 when 2 =(select reg_exam_date from weekend )       
then ''Tues'' 
 when 3 =(select reg_exam_date from weekend )       
then ''Wednes'' 
 when 4 =(select reg_exam_date from weekend )       
then ''Thurs'' 
 when 5 =(select reg_exam_date from weekend)        
then ''Fri'' 
 when 6 =(select reg_exam_date from weekend)        
then ''Satur'' 
 when 0 =(select reg_exam_date from weekend)        
then ''Sun'' 
END ) as aaa))::json->>''user_id'' as staff_cd from mst_kur mst where  mst.kur_cd = (select ind_kur_cd from ind_kur_cd)
and facility_cd = @facilityCd
 UNION
         SELECT 3        AS no,
                       staff_cd 
         from default_user_no
         order by no
         limit 1
),
mst_user_authenticator2 as (
select 
case when (select reg_order_class from reg_order_class) = ''0''
then (select staff_cd from mst_user_authenticator1)
else
(select staff_cd from mst_user_authenticator) end as staff_cd
)
SELECT NULLIF(MAX(CASE part WHEN ''comm'' THEN staff_cd ELSE '''' END), '''') AS staff_cd_comm
     , NULLIF(MAX(CASE part WHEN ''data'' THEN staff_cd ELSE '''' END), '''') AS staff_cd_data
     , (SELECT staff_cd FROM default_user_no)                           AS default_user_no
FROM (SELECT ''comm'' AS part, staff_cd
      FROM ind_user_info
      WHERE (SELECT setting FROM user_no_setting) = ''0''
      UNION
      SELECT ''comm'' AS part, staff_cd
      FROM staff_user_info
      WHERE (SELECT setting FROM user_no_setting) = ''1''
        AND CNT = 1
      UNION
      SELECT ''comm'' AS part, staff_cd
      FROM staff_user_info
      WHERE (SELECT setting FROM user_no_setting) = ''2''
        AND CNT = 2
      UNION
      SELECT ''comm'' AS part, staff_cd FROM up_user_info
      WHERE (SELECT setting FROM user_no_setting) IN (''3'', ''4'', ''5'')
            UNION
    SELECT ''comm'' AS part, staff_cd FROM mst_user_authenticator2 WHERE (SELECT setting FROM user_no_setting) =''6''
      UNION
      SELECT ''data'' AS part, staff_cd
      FROM ind_user_info
      WHERE (SELECT setting FROM user_no_setting) in (''0'', ''3'')
      UNION
      SELECT ''data'' AS part, staff_cd
      FROM staff_user_info
      WHERE (SELECT setting FROM user_no_setting) IN (''1'', ''4'')
        AND CNT = 1
      UNION
      SELECT ''data'' AS part, staff_cd
      FROM staff_user_info
      WHERE (SELECT setting FROM user_no_setting) IN (''2'', ''5'')
        AND CNT = 2
            UNION
      SELECT ''data'' AS part, staff_cd FROM mst_user_authenticator2 
          WHERE (SELECT setting FROM user_no_setting) =''6''  
                ) AS T
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '富士通）検査依頼者 ★削除用', '2022-01-17 15:02:47.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-45, 'WITH sch_start_time_info AS ( 
  -- 予定開始時刻の取得先。0：クールマスタの標準開始時刻（デフォルト）、1：スケジュールの透析開始時刻
  SELECT
    0 AS order_no
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS sch_start_time 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
        -- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
     AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end  
    AND info->>''key1'' = ''COOP_CONFIG''
    AND info->>''key2'' = ''SCH_START_TIME''
  UNION
  SELECT
    1 AS order_no
    , ''0'' AS sch_start_time 
  ORDER BY order_no ASC LIMIT 1
)
, pat_rad_info AS (
  SELECT
    pat_id
    , rad_result_cd
    , reg_order_class
    , reg_rad_date
    , 0 AS idx
    , up_date
  FROM pat_rad_main_hst
  WHERE rad_result_cd = @ordNo
  UNION
  SELECT
    pat_id
    , rad_result_cd
    , reg_order_class
    , reg_rad_date
    , 1 AS idx
    , up_date
  FROM pat_rad_main 
  WHERE rad_result_cd = @ordNo
  ORDER BY idx ASC, up_date DESC
  LIMIT 1)
, order_time_type_info AS ( 
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
        -- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
     AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end  
    AND info->>''key1'' = ''XRAY_INFO''
    AND info->>''key2'' = ''SET_ORDER_TIME_TYPE''
  UNION
  SELECT
    1 AS order_no
    , ''0'' AS order_time_type 
  ORDER BY order_no ASC LIMIT 1
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
        -- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
     AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end  
    AND info->>''key1'' = ''EXAM_MARGIN_TIME''
    AND info->>''key2'' IN (''DIAL_AFTER'', ''DIAL_BEFORE'')
) 
, ind_treat_start_date_time_info AS (
  -- 治療予定の予定治療日+開始時刻(YYYYMMDDHH24MISS)
  SELECT
    pem.reg_order_class
    , TO_CHAR(pem.reg_rad_date, ''YYYYMMDD'') AS exam_date
    , ord.ord_no
    , TO_CHAR(pem.reg_rad_date, ''YYYYMMDD'') || 
      CASE WHEN (SELECT sch_start_time FROM sch_start_time_info) = ''1'' -- 1：スケジュールの透析開始時刻
      THEN COALESCE(NULLIF(ord.ind_treat_start_time, '''') || ''00'', NULLIF(ord.ind_schedule_user_info ->> ''ind_treat_start_time'', '''') || ''00'', kur.kur_standard_start_time) -- 透析開始時刻が未設定の場合は該当クールの標準開始時刻を使用します
      ELSE kur.kur_standard_start_time  -- 0：クールマスタの標準開始時刻
      END AS ind_treat_start_date_time
    , TO_NUMBER(COALESCE(NULLIF(ord.ind_cond_info -> ''1'' ->> ''value'', ''''), ''0''), ''FM999999'') AS treat_times -- 治療時間
  FROM
    pat_rad_info AS pem 
    LEFT OUTER JOIN ord_main AS ord ON ord.pat_id = pem.pat_id AND ord.treat_date = TO_CHAR(pem.reg_rad_date, ''YYYYMMDD'') AND (ord.ind_kur_cd > 0 OR (ord.ind_schedule_user_info ->> ''ind_kur_cd'')::int > 0) AND ord.is_del = ''0''
    LEFT OUTER JOIN mst_kur AS kur ON kur.kur_cd = COALESCE(NULLIF(ord.ind_kur_cd, 0), (ord.ind_schedule_user_info ->> ''ind_kur_cd'')::int)
  WHERE
    pem.rad_result_cd = @ordNo
    AND pem.reg_order_class IN (''1'', ''2'') -- 1:透析前、2:透析後
  ORDER BY ind_treat_start_time ASC LIMIT 1
)

-- ①オーダ時間の設定値。 0：「777700」固定を設定します
SELECT
  TO_CHAR(pem.reg_rad_date, ''YYYYMMDD'') AS exam_date
  , ''777700'' AS exam_start_time
FROM 
  pat_rad_info AS pem
WHERE 
  pem.rad_result_cd = @ordNo
  AND (SELECT order_time_type FROM order_time_type_info) = ''0''

-- ②オーダ時間の設定値。 1：透析スケジュールより当日１回目の予定開始時刻、検査予定＝0:その他→検査セットマスタのその他検査時刻
UNION
SELECT
  TO_CHAR(pem.reg_rad_date, ''YYYYMMDD'') AS exam_date
  , ''777700'' AS exam_start_time  -- TODO:透析単純撮影オーダは「検査セットマスタ」が無し、777700を設定する
FROM
  pat_rad_info AS pem 
WHERE
  pem.rad_result_cd = @ordNo
  AND pem.reg_order_class = ''0'' -- 0:その他
  AND (SELECT order_time_type FROM order_time_type_info) = ''1'' -- 1：透析スケジュール

-- ③オーダ時間の設定値。 1：透析スケジュールより当日１回目の予定開始時刻、検査予定＝ 1:透析前、2:透析後
UNION
SELECT
  exam_date
  , TO_CHAR(
    CASE WHEN reg_order_class = ''1'' 
    THEN TO_TIMESTAMP(ind_treat_start_date_time, ''YYYYMMDDHH24MISS'') 
         - (INTERVAL ''1minute'' * TO_NUMBER(COALESCE(NULLIF((SELECT margin_time FROM margin_time_info WHERE key2 = ''DIAL_BEFORE''), ''''), ''0''), ''FM999999'')) 
    ELSE  TO_TIMESTAMP(ind_treat_start_date_time, ''YYYYMMDDHH24MISS'') + (INTERVAL ''1minute'' * treat_times) 
         + (INTERVAL ''1minute'' * TO_NUMBER(COALESCE(NULLIF((SELECT margin_time FROM margin_time_info WHERE key2 = ''DIAL_AFTER''), ''''), ''0''), ''FM999999'')) 
    END
    , ''HH24MISS'') AS exam_start_time
FROM
  ind_treat_start_date_time_info
WHERE
  ord_no IS NOT NULL -- 治療予定がない場合の透析前、透析後の区分の検査予定は送信対象外のため送信しないこと
  AND (SELECT order_time_type FROM order_time_type_info) = ''1'' -- 1：透析スケジュール

-- ④オーダ時間の設定値。2：検査予定時間を設定します
UNION
SELECT
  TO_CHAR(pem.reg_rad_date, ''YYYYMMDD'') AS exam_date
  , ''777700'' AS exam_start_time  -- TODO:検査予定時間 が無し、777700を設定する
FROM 
  pat_rad_info AS pem
WHERE 
  pem.rad_result_cd = @ordNo
  AND (SELECT order_time_type FROM order_time_type_info) = ''2''
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '富士通）放射線：検査日時取得 ★削除用', '2022-01-19 18:29:49.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-46, 'WITH hosp_code_no_info AS ( 
  -- 使用院内コード番号:院内コードを指定
  SELECT
    ''0'' AS order_no 
    , CASE WHEN COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') IN (''1'', ''2'', ''3'')
      THEN COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'')
      ELSE ''1''  END AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
        -- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
     AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end  
    AND info->>''key1'' = ''XRAY_INFO''
    AND info->>''key2'' = ''USE_IN_HOSP_NO''
  UNION
  SELECT
    ''1'' AS order_no 
    , ''1'' AS VALUE 
  ORDER BY order_no ASC LIMIT 1
)  
, pat_rad_info AS (
  SELECT
    rad_result_cd
    , order_rad_set_info
    , 0 AS idx
    , up_date
  FROM pat_rad_main_hst
  WHERE rad_result_cd = @ordNo
    AND jsonb_array_length(order_rad_set_info) > 0 
  UNION
  SELECT
    rad_result_cd
    , order_rad_set_info
    , 1 AS idx
    , up_date
  FROM pat_rad_main 
  WHERE rad_result_cd = @ordNo
    AND jsonb_array_length(order_rad_set_info) > 0 
  ORDER BY idx ASC, up_date DESC
  LIMIT 1)
, examin_hosp_code_info AS ( 
  -- 放射線の院内コード
  SELECT
    info->>''key2'' AS key2 -- 放射線の院内コード
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
        -- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
     AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end  
    AND info->>''key1'' = ''XRAY_IN_HOSP_CODE'' -- TODO：[放射線種別判定]不明、XRAY_IN_HOSP_CODEを設定する
) 
, class_attr_info AS ( 
  -- 放射線の項目属性
  SELECT
    info->>''key2'' AS key2 -- 項目属性名
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
        -- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
     AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end  
    AND info->>''key1'' = ''XRAY_CLASS_ATTR''
)  
, class_sort_info AS ( 
  -- 放射線のソート順
  SELECT
    info->>''key2'' AS key2 -- 項目ソート順
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
        -- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
     AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end  
    AND info->>''key1'' = ''XRAY_CLASS_SORT''
) 
, data_info AS (
  SELECT
    ''撮影項目'' AS detail_id
    , CASE (SELECT VALUE FROM hosp_code_no_info) 
      WHEN ''1'' THEN mset.in_hospital_cd1
      WHEN ''2'' THEN mset.in_hospital_cd2
      WHEN ''3'' THEN mset.in_hospital_cd3
      ELSE mset.in_hospital_cd1
      END AS in_hospital_cd1
    , COALESCE(NULLIF((SELECT VALUE FROM class_attr_info WHERE key2 = mset.rad_set_name), ''''), ''---'') AS sbt_cd1
    , COALESCE(NULLIF(mset.rad_set_name, ''''), ''不明'') AS item_name
    , ''不明'' AS tag_name
    , TO_NUMBER(COALESCE(NULLIF((SELECT VALUE FROM class_sort_info WHERE key2 = mset.rad_set_name), ''''), ''999''), ''FM999'') AS order_no
    , mset.rad_set_cd
  FROM
    pat_rad_info AS rad 
    CROSS JOIN LATERAL json_array_elements(rad.order_rad_set_info ::json) info 
    LEFT OUTER JOIN mst_rad_set AS mset ON TO_NUMBER(info ->> ''rad_set_cd'', ''FM999999999'') = mset.rad_set_cd
  ORDER BY rad_set_cd, order_no ASC
)
SELECT
  ''撮影項目'' AS detail_id
  , in_hospital_cd1
  , sbt_cd1
  , item_name
  , tag_name
FROM
  data_info
WHERE
  COALESCE(NULLIF(in_hospital_cd1, ''''), ''no_cd'') <> ''no_cd'' 
  AND ((SELECT COUNT(1) FROM examin_hosp_code_info) = 0 -- 検体検査の院内コードを設定が存在しない場合は全て送信対象とする。
   OR EXISTS (SELECT 1 FROM examin_hosp_code_info AS hosp WHERE COALESCE(NULLIF(in_hospital_cd1, ''''), ''no_cd'') = hosp.key2)
    -- 院内コードをキーとして連携IDを設定するの場合は送信対象とする。
  )
ORDER BY
  order_no ASC
LIMIT 299 ', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '富士通）放射線：撮影繰り返し部 ★削除用', '2022-01-19 18:29:49.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-663, 'WITH default_user_no AS (
    -- デフォルト利用者番号delete（検査オーダ用）
    SELECT 0                                                            AS order_no
         , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
    FROM mst_coop_ini AS ini
             CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE facility_cd = @facilityCd
      AND is_del = ''0''
      AND info ->> ''key1'' = ''FJI_COM_INFO''
      AND info ->> ''key2'' = ''EXAM_DEFAULT_USER_NO''
    UNION
    SELECT 1  AS order_no
         , '''' AS staff_cd
    ORDER BY order_no ASC
    LIMIT 1)
   , user_no_setting AS (
    -- 利用者番号出力設定（検査オーダ用）
    SELECT 0                                                                                       AS order_no
         , COALESCE(NULLIF(info ->> ''value'', ''''), COALESCE(NULLIF(info ->> ''default_v'', ''''), ''0'')) AS setting
    FROM mst_coop_ini AS ini
             CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE facility_cd = @facilityCd
      AND is_del = ''0''
            -- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
     AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end  
      AND info ->> ''key1'' = ''FJI_COM_INFO''
      AND info ->> ''key2'' = ''EXAM_USER_NO_SETTING''
    UNION
    SELECT 1   AS order_no
         , ''0'' AS setting
    ORDER BY order_no ASC
    LIMIT 1)
, pat_rad_info AS (
  SELECT
    ind_user_id
    , rad_result_cd
    , reg_rad_date
    , up_staff
    , up_date
    , 0 AS idx
  FROM pat_rad_main_hst
  WHERE rad_result_cd = @ordNo
  UNION
  SELECT
    ind_user_id
    , rad_result_cd
    , reg_rad_date
    , up_staff
    , up_date
    , 1 AS idx
  FROM pat_rad_main 
  WHERE rad_result_cd = @ordNo
  ORDER BY idx ASC, up_date DESC
  LIMIT 1)
   , ind_user_info AS (
 -- 指示者
  SELECT
    TO_CHAR(pem.ind_user_id, ''FM9999999999'') AS staff_cd
  FROM
    pat_rad_info pem
  WHERE
    pem.rad_result_cd = @ordNo
    AND pem.ind_user_id IS NOT NULL
        order by up_date desc limit 1
)
   , staff_user_info AS (
    -- 担当者
    SELECT ROW_NUMBER() OVER () AS CNT
         , staff ->> ''staff_cd'' AS staff_cd
    FROM pat_main pm
             CROSS JOIN LATERAL json_array_elements(pm.charge_staff_info ::json) staff
    WHERE pm.is_del = ''0''
      AND pm.pat_id = @patId
      AND staff ->> ''is_main'' = ''1'')
   , up_user_info AS (
  -- 操作者
  SELECT
    TO_CHAR(pem.up_staff, ''FM9999999999'') AS staff_cd
  FROM
    pat_rad_info pem
  WHERE
    pem.rad_result_cd = @ordNo
    AND pem.up_staff IS NOT NULL
        order by up_date desc limit 1
),
kur_qt as (
select reg_rad_date::time as exam_set_cd from pat_rad_info where rad_result_cd = @ordNo order by up_date desc limit 1
),
kur_time as (
select kur_cd,kur_start_time :: time as time1,kur_end_time :: time as time2 from mst_kur where facility_cd = ''999998'' and is_del = ''0''
),
ind_kur_cd as (
select kur_cd as ind_kur_cd from kur_time 
where time1 <= (select exam_set_cd from kur_qt )
and time2 >= (select exam_set_cd from kur_qt )
),
weekend as( 
select EXTRACT(DOW FROM reg_rad_date)  as reg_rad_date from pat_rad_info where rad_result_cd = @ordNo order by up_date desc limit 1
),
mst_user_authenticator as(
select 
(json_array_elements((mst.mst_user_authentication ->> ''data'')::json)->>(select  (
case when 1 =(select reg_rad_date from weekend )        
then ''Mon'' 
 when 2 =(select reg_rad_date from weekend )        
then ''Tues'' 
 when 3 =(select reg_rad_date from weekend )        
then ''Wednes'' 
 when 4 =(select reg_rad_date from weekend )        
then ''Thurs'' 
 when 5 =(select reg_rad_date from weekend)     
then ''Fri'' 
 when 6 =(select reg_rad_date from weekend)     
then ''Satur'' 
 when 0 =(select reg_rad_date from weekend)     
then ''Sun'' 
END ) as aaa))::json->>''user_id'' as staff_cd from mst_kur mst where  mst.kur_cd = (select ind_kur_cd from ind_kur_cd)
and facility_cd = @facilityCd
)               
SELECT NULLIF(MAX(CASE part WHEN ''comm'' THEN staff_cd ELSE '''' END), '''') AS staff_cd_comm
     , NULLIF(MAX(CASE part WHEN ''data'' THEN staff_cd ELSE '''' END), '''') AS staff_cd_data
     , (SELECT staff_cd FROM default_user_no)                           AS default_user_no
FROM (SELECT ''comm'' AS part, staff_cd
      FROM ind_user_info
      WHERE (SELECT setting FROM user_no_setting) = ''0''
      UNION
      SELECT ''comm'' AS part, staff_cd
      FROM staff_user_info
      WHERE (SELECT setting FROM user_no_setting) = ''1''
        AND CNT = 1
      UNION
      SELECT ''comm'' AS part, staff_cd
      FROM staff_user_info
      WHERE (SELECT setting FROM user_no_setting) = ''2''
        AND CNT = 2
      UNION
      SELECT ''comm'' AS part, staff_cd FROM up_user_info
      WHERE (SELECT setting FROM user_no_setting) IN (''3'', ''4'', ''5'')
            UNION
    SELECT ''comm'' AS part, staff_cd FROM mst_user_authenticator WHERE (SELECT setting FROM user_no_setting) =''6''
      UNION
      SELECT ''data'' AS part, staff_cd
      FROM ind_user_info
      WHERE (SELECT setting FROM user_no_setting) in (''0'', ''3'')
      UNION
      SELECT ''data'' AS part, staff_cd
      FROM staff_user_info
      WHERE (SELECT setting FROM user_no_setting) IN (''1'', ''4'')
        AND CNT = 1
      UNION
      SELECT ''data'' AS part, staff_cd
      FROM staff_user_info
      WHERE (SELECT setting FROM user_no_setting) IN (''2'', ''5'')
        AND CNT = 2
            UNION
      SELECT ''data'' AS part, staff_cd FROM mst_user_authenticator 
          WHERE (SELECT setting FROM user_no_setting) =''6''  
                ) AS T
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '富士通）rad_ord利用者番号delete', '2020-05-11 17:19:24.215', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-66669, 'WITH sch_start_time_info AS (
    -- 予定開始時刻の取得先。0：クールマスタの標準開始時刻（デフォルト）、1：スケジュールの透析開始時刻
    SELECT 0 AS order_no, COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS sch_start_time
    FROM mst_coop_ini AS ini
             CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE facility_cd = @facilityCd
      AND is_del = ''0''
      -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
      AND COALESCE(info->>''key0'','''') = @key0
      -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
      AND info ->> ''key1'' = ''COOP_CONFIG''
      AND info ->> ''key2'' = ''SCH_START_TIME''
    UNION
    SELECT 1 AS order_no, ''0'' AS sch_start_time
    ORDER BY order_no ASC
    LIMIT 1),
     pat_exam_info AS (
         SELECT 
             exam_main_cd,
             order_exam_set_info,
             pat_id,
             reg_exam_date,
             reg_order_class,
             0 AS idx,
             up_date
         FROM pat_exam_main_hst
         WHERE exam_main_cd = @ordNo
         UNION
         SELECT 
             exam_main_cd,
             order_exam_set_info,
             pat_id,
             reg_exam_date,
             reg_order_class,
             1 AS idx,
             up_date
         FROM pat_exam_main 
         WHERE exam_main_cd = @ordNo
         ORDER BY idx ASC, up_date DESC
         LIMIT 1),
     order_time_type_info AS (
         -- オーダ時間の設定値。0：連携設定で時刻を指定、1：透析スケジュールより当日１回目の予定開始時刻
         SELECT 0 AS order_no, COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS order_time_type
         FROM mst_coop_ini AS ini
                  CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
         WHERE facility_cd = @facilityCd
           AND is_del = ''0''
           -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
           AND COALESCE(info->>''key0'','''') = @key0
           -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
           AND info ->> ''key1'' = ''EXAMIN_INFO''
           AND info ->> ''key2'' = ''SET_ORDER_TIME_TYPE''
         UNION
         SELECT 1 AS order_no, ''1'' AS order_time_type
         ORDER BY order_no ASC
         LIMIT 1),
     order_time_info AS (
         -- オーダ時間に設定する値
         SELECT info ->> ''key2''                                                AS key2,
                COALESCE(NULLIF(info ->> ''value'', ''''),
                         COALESCE(NULLIF(info ->> ''default_v'', ''''), ''777700'')) AS order_time
         FROM mst_coop_ini AS ini
                  CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
         WHERE facility_cd = @facilityCd
           AND is_del = ''0''
           -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
           AND COALESCE(info->>''key0'','''') = @key0
           -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
           AND info ->> ''key1'' = ''EXAMIN_INFO''
           AND info ->> ''key2'' IN (''ORDER_TIME_AFTER'', ''ORDER_TIME_BEFORE'', ''ORDER_TIME_OTHER'')
         UNION
         SELECT ''DEFAULT'' AS key2, ''777700'' AS order_time
         ORDER BY key2 ASC),
     margin_time_info AS (
         -- 検査時刻マージン時間:透析前/透析後マージン時間
         SELECT info ->> ''key2'' AS key2, COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS margin_time
         FROM mst_coop_ini AS ini
                  CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
         WHERE facility_cd = @facilityCd
           AND is_del = ''0''
           -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
           AND COALESCE(info->>''key0'','''') = @key0
           -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
           AND info ->> ''key1'' = ''EXAM_MARGIN_TIME''
           AND info ->> ''key2'' IN (''DIAL_AFTER'', ''DIAL_BEFORE'')),
     ind_treat_start_date_time_info AS (
         -- 治療予定の予定治療日+開始時刻(YYYYMMDDHH24MISS)
         SELECT pem.reg_order_class,
                TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'') AS exam_date,
                ord.ord_no,
                TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'') ||
                CASE
                    WHEN (SELECT sch_start_time FROM sch_start_time_info) = ''1'' -- 1：スケジュールの透析開始時刻
                        THEN COALESCE(NULLIF(ord.ind_treat_start_time, '''') || ''00'', NULLIF(ord.ind_schedule_user_info ->> ''ind_treat_start_time'', '''') || ''00'',
                                      kur.kur_standard_start_time) -- 透析開始時刻が未設定の場合は該当クールの標準開始時刻を使用します
                    ELSE kur.kur_standard_start_time -- 0：クールマスタの標準開始時刻
                    END                                AS ind_treat_start_date_time,
                TO_NUMBER(COALESCE(NULLIF(ord.ind_cond_info -> ''1'' ->> ''value'', ''''), ''0''),
                          ''FM999999'')                  AS treat_times -- 治療時間
                          ,ord.ind_treat_start_time, ord.ind_schedule_user_info ->> ''ind_treat_start_time''
         FROM pat_exam_info AS pem
                  LEFT OUTER JOIN ord_main AS ord
                                  ON ord.pat_id = pem.pat_id AND
                                     ord.treat_date = TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'')
                                     AND ord.is_del = ''0'' AND (ord.ind_kur_cd > 0 OR (ord.ind_schedule_user_info ->> ''ind_kur_cd'')::int > 0) 
                  LEFT OUTER JOIN mst_kur AS kur ON kur.kur_cd = COALESCE(NULLIF(ord.ind_kur_cd, 0), (ord.ind_schedule_user_info ->> ''ind_kur_cd'')::int)
         WHERE pem.exam_main_cd = @ordNo
           AND pem.reg_order_class IN (''1'', ''2'') -- 1:透析前、2:透析後
         ORDER BY ind_treat_start_time ASC
         LIMIT 1),
     ind_treat_start_date_time_info_re AS (
         -- 治療予定の予定治療日+開始時刻(YYYYMMDDHH24MISS)
         SELECT pem.reg_order_class,
                TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'') AS exam_date,
                ord.ord_no,
                TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'') ||
                CASE
                    WHEN (SELECT sch_start_time FROM sch_start_time_info) = ''1'' -- 1：スケジュールの透析開始時刻
                        THEN COALESCE(NULLIF(ord.ind_treat_start_time, '''') || ''00'', NULLIF(ord.ind_schedule_user_info ->> ''ind_treat_start_time'', '''') || ''00'',
                                      kur.kur_standard_start_time) -- 透析開始時刻が未設定の場合は該当クールの標準開始時刻を使用します
                    ELSE kur.kur_standard_start_time -- 0：クールマスタの標準開始時刻
                    END                                AS ind_treat_start_date_time,
                TO_NUMBER(COALESCE(NULLIF(ord.ind_cond_info -> ''1'' ->> ''value'', ''''), ''0''),
                          ''FM999999'')                  AS treat_times -- 治療時間
         FROM pat_exam_info AS pem
                  LEFT OUTER JOIN ord_main_restore AS ord
                                  ON ord.pat_id = pem.pat_id AND
                                     ord.treat_date = TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'') AND
                                     ord.ind_kur_cd > 0 AND ord.is_del = ''0''
                  LEFT OUTER JOIN mst_kur AS kur ON kur.kur_cd = ord.ind_kur_cd
         WHERE pem.exam_main_cd = @ordNo
           AND pem.reg_order_class IN (''1'', ''2'') -- 1:透析前、2:透析後
         ORDER BY ind_treat_start_time ASC
         LIMIT 1)
-- ①オーダ時間の設定値。 0：連携設定で時刻を指定
SELECT TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'') AS exam_date,
       CASE reg_order_class
           WHEN ''1'' THEN COALESCE(NULLIF((SELECT order_time FROM order_time_info WHERE key2 = ''ORDER_TIME_BEFORE''), ''''),
                                  (SELECT order_time FROM order_time_info WHERE key2 = ''DEFAULT''))
           WHEN ''2'' THEN COALESCE(NULLIF((SELECT order_time FROM order_time_info WHERE key2 = ''ORDER_TIME_AFTER''), ''''),
                                  (SELECT order_time FROM order_time_info WHERE key2 = ''DEFAULT''))
           ELSE COALESCE(NULLIF((SELECT order_time FROM order_time_info WHERE key2 = ''ORDER_TIME_OTHER''), ''''),
                         (SELECT order_time FROM order_time_info WHERE key2 = ''DEFAULT''))
           END                                AS exam_start_time
FROM pat_exam_info AS pem
WHERE pem.exam_main_cd = @ordNo
  AND (SELECT order_time_type FROM order_time_type_info) = ''0'' -- 0：連携設定で時刻を指定
-- ②オーダ時間の設定値。 1：透析スケジュールより当日１回目の予定開始時刻、検査予定＝0:その他
UNION
SELECT TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'')                     AS exam_date,
       COALESCE(NULLIF(mset.other_exam_time, ''''), ''0000'') || ''00'' AS exam_start_time
FROM pat_exam_info AS pem
         CROSS JOIN LATERAL json_array_elements(pem.order_exam_set_info ::json) set_info
         LEFT OUTER JOIN mst_exam_set AS mset ON set_info ->> ''set_cd'' = (mset.exam_set_cd ::TEXT)
WHERE pem.exam_main_cd = @ordNo
  AND pem.reg_order_class = ''0''                                -- 0:その他
  AND (SELECT order_time_type FROM order_time_type_info) = ''1'' -- 1：透析スケジュール
-- ③オーダ時間の設定値。 1：透析スケジュールより当日１回目の予定開始時刻、検査予定＝ 1:透析前、2:透析後
UNION
select t.exam_date as exam_date, t.exam_start_time as exam_start_time
from (SELECT 0 as rows,
             ord.exam_date,
             TO_CHAR(
                     CASE
                         WHEN reg_order_class = ''1''
                             THEN TO_TIMESTAMP(ord.ind_treat_start_date_time, ''YYYYMMDDHH24MISS'')
                             - (INTERVAL ''1minute'' * TO_NUMBER(
                                     COALESCE(NULLIF(
                                                      (SELECT margin_time FROM margin_time_info WHERE key2 = ''DIAL_BEFORE''),
                                                      ''''),
                                              ''0''), ''FM999999''))
                         ELSE TO_TIMESTAMP(ord.ind_treat_start_date_time, ''YYYYMMDDHH24MISS'') +
                              (INTERVAL ''1minute'' * ord.treat_times)
                             + (INTERVAL ''1minute'' * TO_NUMBER(
                                     COALESCE(
                                             NULLIF(
                                                     (SELECT margin_time FROM margin_time_info WHERE key2 = ''DIAL_AFTER''),
                                                     ''''),
                                             ''0''),
                                     ''FM999999''))
                         END, ''HH24MISS'') AS exam_start_time
      FROM ind_treat_start_date_time_info ord
      WHERE ord_no IS NOT NULL                                       -- 治療予定がない場合の透析前、透析後の区分の検査予定は送信対象外のため送信しないこと
        AND (SELECT order_time_type FROM order_time_type_info) = ''1'' -- 1：透析スケジュール
      UNION
      SELECT 1 as rows,
             ord_re.exam_date,
             TO_CHAR(
                     CASE
                         WHEN reg_order_class = ''1''
                             THEN TO_TIMESTAMP(ord_re.ind_treat_start_date_time, ''YYYYMMDDHH24MISS'')
                             - (INTERVAL ''1minute'' * TO_NUMBER(
                                     COALESCE(NULLIF(
                                                      (SELECT margin_time FROM margin_time_info WHERE key2 = ''DIAL_BEFORE''),
                                                      ''''),
                                              ''0''), ''FM999999''))
                         ELSE TO_TIMESTAMP(ord_re.ind_treat_start_date_time, ''YYYYMMDDHH24MISS'') +
                              (INTERVAL ''1minute'' * ord_re.treat_times)
                             + (INTERVAL ''1minute'' * TO_NUMBER(
                                     COALESCE(
                                             NULLIF(
                                                     (SELECT margin_time FROM margin_time_info WHERE key2 = ''DIAL_AFTER''),
                                                     ''''),
                                             ''0''),
                                     ''FM999999''))
                         END, ''HH24MISS'') AS exam_start_time
      FROM ind_treat_start_date_time_info_re ord_re
      WHERE ord_re.ord_no IS NOT NULL -- 治療予定がない場合の透析前、透析後の区分の検査予定は送信対象外のため送信しないこと
        AND (SELECT order_time_type FROM order_time_type_info) = ''1''
      order by rows
      limit 1) as t', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '富士通）検査依頼：検査日時取得 ★削除用', '2023-07-17 21:01:55.540', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-66671, 'WITH examin_info AS ( 
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
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info->>''key1'' = ''EXAMIN_INFO''
)
, pat_exam_info AS ( 
    SELECT
        exam_order_info
        , is_del
        , order_exam_set_info
        , reg_order_class
        , 0 AS idx
        , up_date
    FROM pat_exam_main_hst
    WHERE exam_main_cd = @ordNo
    UNION
    SELECT 
        exam_order_info
        , is_del
        , order_exam_set_info
        , reg_order_class
        , 1 AS idx
        , up_date
    FROM pat_exam_main 
    WHERE exam_main_cd = @ordNo
    ORDER BY idx ASC, up_date DESC
    LIMIT 1)
, conv_order_class_info AS ( 
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
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info->>''key1'' = ''CONV_EXAMIN_ORDER_CLASS_TO_KARTE''
)
, hosp_code_no_info AS ( 
  -- 使用院内コード番号:院内コードを指定
  SELECT
    ''0'' AS order_no 
    , CASE WHEN COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') IN (''1'', ''2'', ''3'')
      THEN COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'')
      ELSE ''1''  END AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info->>''key1'' = ''EXAMIN_INFO''
    AND info->>''key2'' = ''USE_IN_HOSP_NO''
  UNION
  SELECT
    ''1'' AS order_no 
    , ''1'' AS VALUE 
  ORDER BY order_no ASC LIMIT 1
) ,
sbt_cd_no_info AS ( 
  -- 使用院内コード番号:院内コードを指定
  SELECT
    ''0'' AS order_no 
    , CASE WHEN COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') IN (''1'', ''2'', ''3'')
      THEN COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'')
      ELSE ''1''  END AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info->>''key1'' = ''EXAMIN_INFO''
    AND info->>''key2'' = ''USE_sbt_cd''
  UNION
  SELECT
    ''1'' AS order_no 
    , ''1'' AS VALUE 
  ORDER BY order_no ASC LIMIT 1
) 
, examin_hosp_code_info AS ( 
  -- 心電図オーダ送信用の検査セッの院内コード
  SELECT
   COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0''
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info->>''key1'' = ''EXAMIN_IN_HOSP_CODE'' -- TODO：[検査オーダ種別判定]不明、EXAMIN_IN_HOSP_CODEを設定する
        AND info->>''key2'' = ''PHY''
),
data_exam_all as (
SELECT
    T01.order_no
  ,T01.detail_id ::text
  , T01.in_hospital_cd1
  ,T01.sbt_cd1
  ,T01.exam_set_cd
  ,T01.exam_set_name
  , T01.item_name
  , T01.tag_name
  ,T01.sbt_cd1_sort
  ,T01.ordernow
FROM
  (
  SELECT
      0 AS order_no
    , ''検査項目'' AS detail_id
    , CASE (SELECT VALUE FROM hosp_code_no_info) 
      WHEN ''1'' THEN item.in_hospital_cd1
      WHEN ''2'' THEN item.in_hospital_cd2
      WHEN ''3'' THEN item.in_hospital_cd3
      ELSE item.in_hospital_cd1
      END AS in_hospital_cd1
    , CASE (SELECT VALUE FROM hosp_code_no_info) 
      WHEN ''1'' THEN mset.in_hospital_cd1
      WHEN ''2'' THEN mset.in_hospital_cd2
      WHEN ''3'' THEN mset.in_hospital_cd3
      ELSE mset.in_hospital_cd1
      END AS in_hospital_cd_set
--     , COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''EXAM_ITEM_ATTR''), ''''), ''ET1'') AS sbt_cd1
     ,(select COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS sbt_cd1 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') = @key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info->>''key1'' = ''PHYSIOLOGY_CLASS_ATTR''
        AND info->>''key2'' = (CASE (SELECT VALUE FROM sbt_cd_no_info) 
      WHEN ''1'' THEN item.sbt_cd1
      WHEN ''2'' THEN item.sbt_cd2
      WHEN ''3'' THEN item.sbt_cd3
      ELSE item.sbt_cd1
        end))
     ,mset.exam_set_cd,
         mset.exam_set_name
    , order_info->>''item_name'' AS item_name
    ,
        CASE (SELECT VALUE FROM sbt_cd_no_info) 
      WHEN ''1'' THEN item.sbt_cd1
      WHEN ''2'' THEN item.sbt_cd2
      WHEN ''3'' THEN item.sbt_cd3
      ELSE item.sbt_cd1
        end AS tag_name
        ,(select COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS sbt_cd1_sort
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>''key0'','''') =@key0
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info->>''key1'' = ''PHYSIOLOGY_CLASS_SORT''
        AND info->>''key2'' = (CASE (SELECT VALUE FROM sbt_cd_no_info) 
      WHEN ''1'' THEN item.sbt_cd1
      WHEN ''2'' THEN item.sbt_cd2
      WHEN ''3'' THEN item.sbt_cd3
      ELSE item.sbt_cd1
        end))
    ,set_info->>''no'' as ordernow
  FROM
    pat_exam_info AS exam 
    CROSS JOIN LATERAL json_array_elements(exam.order_exam_set_info ::json) set_info 
    LEFT OUTER JOIN mst_exam_set AS mset ON set_info->>''set_cd'' = (mset.exam_set_cd ::TEXT) 
    LEFT OUTER JOIN json_array_elements(exam.exam_order_info ::json) order_info  ON order_info->>''no'' = set_info->>''no'' 
    LEFT OUTER JOIN mst_exam_item AS item ON order_info->>''item_cd'' = (item.exam_item_cd ::TEXT) 
  WHERE
    exam.is_del = ''0'' 
    AND jsonb_array_length(exam.exam_order_info) > 0 
    AND jsonb_array_length(exam.order_exam_set_info) > 0 
  ) AS T01
WHERE
  COALESCE(NULLIF(T01.in_hospital_cd1, ''''), ''no_cd'') <> ''no_cd'' 
  AND COALESCE(NULLIF(T01.in_hospital_cd_set, ''''), ''no_cd'') <> ''no_cd'' 
  AND (SELECT value FROM examin_hosp_code_info  )!= ''''-- 心電図オーダの院内コードを設定が存在しない場合は電文が送信されない。
    AND (SELECT value FROM examin_hosp_code_info )is not null
  AND T01.in_hospital_cd_set = (select value from examin_hosp_code_info )
  AND sbt_cd1 <> '''' AND SBT_CD1 IS NOT NULL
order by T01.ordernow
),
max_balance as (
select ((select count(1) from data_exam_all where ordernow  = (
select max(aa.ordernow) from (select ordernow from data_exam_all limit 298) as aa ))-
(select count(1) from (select * from data_exam_all limit 298 ) as aa where aa.ordernow  =  (
select max(aa.ordernow) from (select ordernow from data_exam_all limit 298) as aa ))) as balance
,(select count(1) from (select * from data_exam_all limit 298 ) as aa where aa.ordernow  =  (
select max(aa.ordernow) from (select ordernow from data_exam_all limit 298) as aa )) as min_number
)
select * from (
(select * from data_exam_all 
where (select balance  from max_balance )  = 0 
limit 298)
union all
(select * from data_exam_all  where (select balance  from max_balance ) != 0 
limit (298 - (select min_number  from max_balance)))
-- 3.7.4.3.3 透析前後区分の設定
UNION ALL
SELECT
  3 AS order_no
  , ''検査項目'' AS detail_id
  , COALESCE(NULLIF((SELECT VALUE FROM conv_order_class_info WHERE key2 = exam.reg_order_class), '''') , exam.reg_order_class) AS           in_hospital_cd1
    
  , CASE exam.reg_order_class 
    WHEN ''1'' THEN COALESCE(NULLIF((SELECT VALUE FROM  examin_info WHERE key2 = ''BEFORE_ORDER_CLASS_ATTR''), ''''), ''EC1'') 
    WHEN ''2'' THEN COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''AFTER_ORDER_CLASS_ATTR''), ''''), ''EC1'') 
    ELSE COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''OTHER_ORDER_CLASS_ATTR''), ''''), ''EC1'') 
    END AS sbt_cd1
    ,NULL AS exam_set_cd
    ,'''' AS exam_set_name
  , CASE exam.reg_order_class 
    WHEN ''1'' THEN COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''BEFORE_ORDER_CLASS_NAME''), ''''), ''透析前'') 
    WHEN ''2'' THEN COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''AFTER_ORDER_CLASS_NAME''), ''''), ''透析後'') 
    ELSE COALESCE(NULLIF((SELECT VALUE FROM examin_info WHERE key2 = ''OTHER_ORDER_CLASS_NAME''), ''''), ''その他'') 
    END AS item_name
    , '''' AS tag_name
    ,'''' AS sbt_cd1_sort 
     ,'''' AS ordernow
FROM
pat_exam_info as exam

)as T02
ORDER BY
   order_no ASC
  , ordernow ASC
  , sbt_cd1_sort ASC
LIMIT 299 ', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '富士通）依頼検査繰り返し部 ★削除用', '2023-07-17 21:01:55.540', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-800011, 'WITH sch_start_time_info AS (
    -- 予定開始時刻の取得先。0：クールマスタの標準開始時刻（デフォルト）、1：スケジュールの透析開始時刻
    SELECT 0 AS order_no, COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS sch_start_time
    FROM mst_coop_ini AS ini
             CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE facility_cd = @facilityCd
      AND is_del = ''0''
      -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
      AND COALESCE(info->>''key0'','''') = @key0
      -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
      AND info ->> ''key1'' = ''COOP_CONFIG''
      AND info ->> ''key2'' = ''SCH_START_TIME''
    UNION
    SELECT 1 AS order_no, ''0'' AS sch_start_time
    ORDER BY order_no ASC
    LIMIT 1),
     pat_exam_info AS (
         SELECT 
             exam_main_cd,
             order_exam_set_info,
             pat_id,
             reg_exam_date,
             reg_order_class,
             0 AS idx,
             up_date
         FROM pat_exam_main_hst
         WHERE exam_main_cd = @ordNo
         UNION
         SELECT 
             exam_main_cd,
             order_exam_set_info,
             pat_id,
             reg_exam_date,
             reg_order_class,
             1 AS idx,
             up_date
         FROM pat_exam_main 
         WHERE exam_main_cd = @ordNo
         ORDER BY idx ASC, up_date DESC
         LIMIT 1),
     order_time_type_info AS (
         -- オーダ時間の設定値。0：連携設定で時刻を指定、1：透析スケジュールより当日１回目の予定開始時刻
         SELECT 0 AS order_no, COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS order_time_type
         FROM mst_coop_ini AS ini
                  CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
         WHERE facility_cd = @facilityCd
           AND is_del = ''0''
           -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
           AND COALESCE(info->>''key0'','''') = @key0
           -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
           AND info ->> ''key1'' = ''EXAMIN_INFO''
           AND info ->> ''key2'' = ''SET_ORDER_TIME_TYPE''
         UNION
         SELECT 1 AS order_no, ''1'' AS order_time_type
         ORDER BY order_no ASC
         LIMIT 1),
     order_time_info AS (
         -- オーダ時間に設定する値
         SELECT info ->> ''key2''                                                AS key2,
                COALESCE(NULLIF(info ->> ''value'', ''''),
                         COALESCE(NULLIF(info ->> ''default_v'', ''''), ''777700'')) AS order_time
         FROM mst_coop_ini AS ini
                  CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
         WHERE facility_cd = @facilityCd
           AND is_del = ''0''
           -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
           AND COALESCE(info->>''key0'','''') = @key0
           -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
           AND info ->> ''key1'' = ''EXAMIN_INFO''
           AND info ->> ''key2'' IN (''ORDER_TIME_AFTER'', ''ORDER_TIME_BEFORE'', ''ORDER_TIME_OTHER'')
         UNION
         SELECT ''DEFAULT'' AS key2, ''777700'' AS order_time
         ORDER BY key2 ASC),
     margin_time_info AS (
         -- 検査時刻マージン時間:透析前/透析後マージン時間
         SELECT info ->> ''key2'' AS key2, COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS margin_time
         FROM mst_coop_ini AS ini
                  CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
         WHERE facility_cd = @facilityCd
           AND is_del = ''0''
           -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
           AND COALESCE(info->>''key0'','''') = @key0
           -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
           AND info ->> ''key1'' = ''EXAM_MARGIN_TIME''
           AND info ->> ''key2'' IN (''DIAL_AFTER'', ''DIAL_BEFORE'')),
     ind_treat_start_date_time_info AS (
         -- 治療予定の予定治療日+開始時刻(YYYYMMDDHH24MISS)
         SELECT pem.reg_order_class,
                TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'') AS exam_date,
                ord.ord_no,
                TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'') ||
                CASE
                    WHEN (SELECT sch_start_time FROM sch_start_time_info) = ''1'' -- 1：スケジュールの透析開始時刻
                        THEN COALESCE(NULLIF(ord.ind_treat_start_time, '''') || ''00'', NULLIF(ord.ind_schedule_user_info ->> ''ind_treat_start_time'', '''') || ''00'',
                                      kur.kur_standard_start_time) -- 透析開始時刻が未設定の場合は該当クールの標準開始時刻を使用します
                    ELSE kur.kur_standard_start_time -- 0：クールマスタの標準開始時刻
                    END                                AS ind_treat_start_date_time,
                TO_NUMBER(COALESCE(NULLIF(ord.ind_cond_info -> ''1'' ->> ''value'', ''''), ''0''),
                          ''FM999999'')                  AS treat_times -- 治療時間
                          ,ord.ind_treat_start_time, ord.ind_schedule_user_info ->> ''ind_treat_start_time''
         FROM pat_exam_info AS pem
                  LEFT OUTER JOIN ord_main AS ord
                                  ON ord.pat_id = pem.pat_id AND
                                     ord.treat_date = TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'')
                                     AND ord.is_del = ''0'' AND (ord.ind_kur_cd > 0 OR (ord.ind_schedule_user_info ->> ''ind_kur_cd'')::int > 0) 
                  LEFT OUTER JOIN mst_kur AS kur ON kur.kur_cd = COALESCE(NULLIF(ord.ind_kur_cd, 0), (ord.ind_schedule_user_info ->> ''ind_kur_cd'')::int)
         WHERE pem.exam_main_cd = @ordNo
           AND pem.reg_order_class IN (''1'', ''2'') -- 1:透析前、2:透析後
         ORDER BY ind_treat_start_time ASC
         LIMIT 1),
     ind_treat_start_date_time_info_re AS (
         -- 治療予定の予定治療日+開始時刻(YYYYMMDDHH24MISS)
         SELECT pem.reg_order_class,
                TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'') AS exam_date,
                ord.ord_no,
                TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'') ||
                CASE
                    WHEN (SELECT sch_start_time FROM sch_start_time_info) = ''1'' -- 1：スケジュールの透析開始時刻
                        THEN COALESCE(NULLIF(ord.ind_treat_start_time, '''') || ''00'', NULLIF(ord.ind_schedule_user_info ->> ''ind_treat_start_time'', '''') || ''00'',
                                      kur.kur_standard_start_time) -- 透析開始時刻が未設定の場合は該当クールの標準開始時刻を使用します
                    ELSE kur.kur_standard_start_time -- 0：クールマスタの標準開始時刻
                    END                                AS ind_treat_start_date_time,
                TO_NUMBER(COALESCE(NULLIF(ord.ind_cond_info -> ''1'' ->> ''value'', ''''), ''0''),
                          ''FM999999'')                  AS treat_times -- 治療時間
         FROM pat_exam_info AS pem
                  LEFT OUTER JOIN ord_main_restore AS ord
                                  ON ord.pat_id = pem.pat_id AND
                                     ord.treat_date = TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'') AND
                                     ord.ind_kur_cd > 0 AND ord.is_del = ''0''
                  LEFT OUTER JOIN mst_kur AS kur ON kur.kur_cd = ord.ind_kur_cd
         WHERE pem.exam_main_cd = @ordNo
           AND pem.reg_order_class IN (''1'', ''2'') -- 1:透析前、2:透析後
         ORDER BY ind_treat_start_time ASC
         LIMIT 1)
-- ①オーダ時間の設定値。 0：連携設定で時刻を指定
SELECT TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'') AS exam_date,
       CASE reg_order_class
           WHEN ''1'' THEN COALESCE(NULLIF((SELECT order_time FROM order_time_info WHERE key2 = ''ORDER_TIME_BEFORE''), ''''),
                                  (SELECT order_time FROM order_time_info WHERE key2 = ''DEFAULT''))
           WHEN ''2'' THEN COALESCE(NULLIF((SELECT order_time FROM order_time_info WHERE key2 = ''ORDER_TIME_AFTER''), ''''),
                                  (SELECT order_time FROM order_time_info WHERE key2 = ''DEFAULT''))
           ELSE COALESCE(NULLIF((SELECT order_time FROM order_time_info WHERE key2 = ''ORDER_TIME_OTHER''), ''''),
                         (SELECT order_time FROM order_time_info WHERE key2 = ''DEFAULT''))
           END                                AS exam_start_time
FROM pat_exam_info AS pem
WHERE pem.exam_main_cd = @ordNo
  AND (SELECT order_time_type FROM order_time_type_info) = ''0'' -- 0：連携設定で時刻を指定
-- ②オーダ時間の設定値。 1：透析スケジュールより当日１回目の予定開始時刻、検査予定＝0:その他
UNION
SELECT TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'')                     AS exam_date,
       COALESCE(NULLIF(mset.other_exam_time, ''''), ''0000'') || ''00'' AS exam_start_time
FROM pat_exam_info AS pem
         CROSS JOIN LATERAL json_array_elements(pem.order_exam_set_info ::json) set_info
         LEFT OUTER JOIN mst_exam_set AS mset ON set_info ->> ''set_cd'' = (mset.exam_set_cd ::TEXT)
WHERE pem.exam_main_cd = @ordNo
  AND pem.reg_order_class = ''0''                                -- 0:その他
  AND (SELECT order_time_type FROM order_time_type_info) = ''1'' -- 1：透析スケジュール
-- ③オーダ時間の設定値。 1：透析スケジュールより当日１回目の予定開始時刻、検査予定＝ 1:透析前、2:透析後
UNION
select t.exam_date as exam_date, t.exam_start_time as exam_start_time
from (SELECT 0 as rows,
             ord.exam_date,
             TO_CHAR(
                     CASE
                         WHEN reg_order_class = ''1''
                             THEN TO_TIMESTAMP(ord.ind_treat_start_date_time, ''YYYYMMDDHH24MISS'')
                             - (INTERVAL ''1minute'' * TO_NUMBER(
                                     COALESCE(NULLIF(
                                                      (SELECT margin_time FROM margin_time_info WHERE key2 = ''DIAL_BEFORE''),
                                                      ''''),
                                              ''0''), ''FM999999''))
                         ELSE TO_TIMESTAMP(ord.ind_treat_start_date_time, ''YYYYMMDDHH24MISS'') +
                              (INTERVAL ''1minute'' * ord.treat_times)
                             + (INTERVAL ''1minute'' * TO_NUMBER(
                                     COALESCE(
                                             NULLIF(
                                                     (SELECT margin_time FROM margin_time_info WHERE key2 = ''DIAL_AFTER''),
                                                     ''''),
                                             ''0''),
                                     ''FM999999''))
                         END, ''HH24MISS'') AS exam_start_time
      FROM ind_treat_start_date_time_info ord
      WHERE ord_no IS NOT NULL                                       -- 治療予定がない場合の透析前、透析後の区分の検査予定は送信対象外のため送信しないこと
        AND (SELECT order_time_type FROM order_time_type_info) = ''1'' -- 1：透析スケジュール
      UNION
      SELECT 1 as rows,
             ord_re.exam_date,
             TO_CHAR(
                     CASE
                         WHEN reg_order_class = ''1''
                             THEN TO_TIMESTAMP(ord_re.ind_treat_start_date_time, ''YYYYMMDDHH24MISS'')
                             - (INTERVAL ''1minute'' * TO_NUMBER(
                                     COALESCE(NULLIF(
                                                      (SELECT margin_time FROM margin_time_info WHERE key2 = ''DIAL_BEFORE''),
                                                      ''''),
                                              ''0''), ''FM999999''))
                         ELSE TO_TIMESTAMP(ord_re.ind_treat_start_date_time, ''YYYYMMDDHH24MISS'') +
                              (INTERVAL ''1minute'' * ord_re.treat_times)
                             + (INTERVAL ''1minute'' * TO_NUMBER(
                                     COALESCE(
                                             NULLIF(
                                                     (SELECT margin_time FROM margin_time_info WHERE key2 = ''DIAL_AFTER''),
                                                     ''''),
                                             ''0''),
                                     ''FM999999''))
                         END, ''HH24MISS'') AS exam_start_time
      FROM ind_treat_start_date_time_info_re ord_re
      WHERE ord_re.ord_no IS NOT NULL -- 治療予定がない場合の透析前、透析後の区分の検査予定は送信対象外のため送信しないこと
        AND (SELECT order_time_type FROM order_time_type_info) = ''1''
      order by rows
      limit 1) as t', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '富士通）検査依頼：検査日時取得 ★削除用', '2022-10-21 00:40:21.691', CURRENT_TIMESTAMP, NULL);