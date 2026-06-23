DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-25,-43)
;

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
    pat_exam_main_hst AS exam 
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
    pat_exam_main_hst AS exam 
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
    pat_exam_main_hst AS exam 
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
    pat_exam_main_hst AS exam 
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
  pat_exam_main_hst AS exam 
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
VALUES(-25, 'WITH examin_info AS ( 
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
    pat_exam_main AS exam 
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
    pat_exam_main AS exam 
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
    pat_exam_main AS exam 
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
    pat_exam_main AS exam 
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
  pat_exam_main AS exam 
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
LIMIT 299 ', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '富士通）依頼検査繰り返し部', '2020-05-12 11:09:24.000', CURRENT_TIMESTAMP, NULL);