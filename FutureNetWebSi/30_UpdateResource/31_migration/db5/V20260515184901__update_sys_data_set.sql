DELETE FROM ntss.sys_data_set
WHERE sql_cd in (-66669, -66670, -66671);

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
           AND info ->> ''key1'' = ''PHYSIOLOGY_INFO''
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
                        THEN COALESCE(NULLIF(ord.ind_treat_start_time, '''') || ''00'', NULLIF(ord.ind_schedule_user_info ->> ''ind_treat_start_time_before'', '''') || ''00'',
                                      kur.kur_standard_start_time) -- 透析開始時刻が未設定の場合は該当クールの標準開始時刻を使用します
                    ELSE kur.kur_standard_start_time -- 0：クールマスタの標準開始時刻
                    END                                AS ind_treat_start_date_time,
                TO_NUMBER(COALESCE(NULLIF(ord.ind_cond_info -> ''1'' ->> ''value'', ''''), ''0''),
                          ''FM999999'')                  AS treat_times -- 治療時間
                          ,ord.ind_treat_start_time, ord.ind_schedule_user_info ->> ''ind_treat_start_time_before''
         FROM pat_exam_info AS pem
                  LEFT OUTER JOIN ord_main AS ord
                                  ON ord.pat_id = pem.pat_id AND
                                     ord.treat_date = TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'')
                                     AND ord.is_del = ''0'' AND (ord.ind_kur_cd > 0 OR (ord.ind_schedule_user_info ->> ''ind_kur_cd_before'')::int > 0) 
                  LEFT OUTER JOIN mst_kur AS kur ON kur.kur_cd = COALESCE(NULLIF(ord.ind_kur_cd, 0), (ord.ind_schedule_user_info ->> ''ind_kur_cd_before'')::int)
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
                        THEN COALESCE(NULLIF(ord.ind_treat_start_time, '''') || ''00'', NULLIF(ord.ind_schedule_user_info ->> ''ind_treat_start_time_before'', '''') || ''00'',
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
        ''777700'' AS exam_start_time
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
      limit 1) as t', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '富士通）検査依頼：検査日時取得 ★削除用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-66670, '-- sql_cd:-66670
WITH examin_info AS ( 
  -- 透析心電図オーダ情報取得
  SELECT
    info->>''key2'' AS key2
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND COALESCE(info->>''key0'','''') = @key0
    AND info->>''key1'' = ''PHYSIOLOGY_INFO''
) 

, conv_order_class_info AS ( 
  -- 透析前後区分変換情報取得(電子カルテ連携用)
  SELECT
    info->>''key2'' AS key2
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND COALESCE(info->>''key0'','''') = @key0
    AND info->>''key1'' = ''CONV_EXAMIN_ORDER_CLASS_TO_KARTE''
)
, hosp_code_no_info AS ( 
  -- 院内コード使用区分取得(1:コード1, 2:コード2, 3:コード3)
  -- デフォルトは1
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
    AND COALESCE(info->>''key0'','''') = @key0
    AND info->>''key1'' = ''PHYSIOLOGY_INFO''
    AND info->>''key2'' = ''USE_IN_HOSP_NO''
  UNION
  SELECT
    ''1'' AS order_no 
    , ''1'' AS VALUE 
  ORDER BY order_no ASC LIMIT 1
) ,
sbt_cd_no_info AS ( 
  -- 属性コード使用区分取得(1:属性1, 2:属性2, 3:属性3)
  -- デフォルトは1
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
    AND COALESCE(info->>''key0'','''') = @key0
    AND info->>''key1'' = ''PHYSIOLOGY_INFO''
    AND info->>''key2'' = ''USE_sbt_cd''
  UNION
  SELECT
    ''1'' AS order_no 
    , ''1'' AS VALUE 
  ORDER BY order_no ASC LIMIT 1
) 
, examin_hosp_code_info AS ( 
  -- 心電図オーダ送信用の検査セットの院内コード取得
  SELECT
   COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0''
    AND COALESCE(info->>''key0'','''') = @key0
    AND info->>''key1'' = ''EXAMIN_IN_HOSP_CODE'' 
    AND info->>''key2'' = ''PHY''
) ,
data_exam_all as (
  -- 検査詳細データの取得と整形
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
    -- unitを用いて属性情報を取得
    ,(select COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS sbt_cd1 
      FROM
        mst_coop_ini AS ini 
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
      WHERE
        facility_cd = @facilityCd 
        AND is_del = ''0'' 
        AND COALESCE(info->>''key0'','''') = @key0
        AND info->>''key1'' = ''PHYSIOLOGY_CLASS_ATTR''
        AND info->>''key2'' = item.unit)
     ,mset.exam_set_cd,
     mset.exam_set_name
    , order_info->>''item_name'' AS item_name
    ,
    item.unit AS tag_name
    ,(select COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS sbt_cd1_sort
      FROM
        mst_coop_ini AS ini 
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
      WHERE
        facility_cd = @facilityCd 
        AND is_del = ''0'' 
        AND COALESCE(info->>''key0'','''') =@key0
        AND info->>''key1'' = ''PHYSIOLOGY_CLASS_SORT''
        AND info->>''key2'' = item.unit)
    ,set_info->>''set_cd'' as ordernow
  FROM
    pat_exam_main AS exam 
    CROSS JOIN LATERAL json_array_elements(exam.order_exam_set_info ::json) set_info 
    LEFT OUTER JOIN mst_exam_set AS mset ON set_info->>''set_cd'' = (mset.exam_set_cd ::TEXT) 
    LEFT OUTER JOIN json_array_elements(exam.exam_order_info ::json) order_info  ON order_info->>''set_cd'' = set_info->>''set_cd'' 
    LEFT OUTER JOIN mst_exam_item AS item ON order_info->>''item_cd'' = (item.exam_item_cd ::TEXT) 
  WHERE
    exam.is_del = ''0'' 
    AND exam.exam_main_cd = @ordNo 
    AND jsonb_array_length(exam.exam_order_info) > 0 
    AND jsonb_array_length(exam.order_exam_set_info) > 0 
  ) AS T01
WHERE
  COALESCE(NULLIF(T01.in_hospital_cd1, ''''), ''no_cd'') <> ''no_cd'' 
  AND COALESCE(NULLIF(T01.in_hospital_cd_set, ''''), ''no_cd'') <> ''no_cd'' 
  AND (SELECT value FROM examin_hosp_code_info  )!= '''' -- 心電図オーダの院内コード設定が存在しない場合は電文を送信しない
  AND (SELECT value FROM examin_hosp_code_info )is not null
  AND T01.in_hospital_cd_set = (select value from examin_hosp_code_info )
  AND sbt_cd1 <> '''' AND SBT_CD1 IS NOT NULL
order by T01.ordernow
),
max_balance as (
  -- 最大件数調整用
select ((select count(1) from data_exam_all where ordernow  = (
select max(aa.ordernow) from (select ordernow from data_exam_all limit 298) as aa ))-
(select count(1) from (select * from data_exam_all limit 298 ) as aa where aa.ordernow  =  (
select max(aa.ordernow) from (select ordernow from data_exam_all limit 298) as aa ))) as balance
,(select count(1) from (select * from data_exam_all limit 298 ) as aa where aa.ordernow  =  (
select max(aa.ordernow) from (select ordernow from data_exam_all limit 298) as aa )) as min_number
)
select * from (
  -- 上限300件（ヘッダ等除く残枠298判定）
(select * from data_exam_all 
where (select balance  from max_balance )  = 0 
limit 298)
union all
(select * from data_exam_all  where (select balance  from max_balance ) != 0 
limit (298 - (select min_number  from max_balance)))
-- 透析前後区分の設定(3レコード目として追加)
UNION ALL
SELECT
  3 AS order_no
  , ''検査項目'' AS detail_id
  , COALESCE(NULLIF((SELECT VALUE FROM conv_order_class_info WHERE key2 = exam.reg_order_class), '''') , exam.reg_order_class) AS           in_hospital_cd1
  , CASE exam.reg_order_class 
    -- ★FIX★ ここはexamin_infoを使用しているが、このCTEは先頭でPHYSIOLOGY_INFOへ修正済み
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
  pat_exam_main AS exam 
WHERE
  exam.exam_main_cd  = @ordNo 
)as T02
ORDER BY
   order_no ASC
  , ordernow ASC
  , sbt_cd1_sort ASC
LIMIT 299', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '富士通）依頼検査繰り返し部', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-66671, '-- sql_cd:-66671
WITH examin_info AS ( 
  -- 透析心電図オーダ情報取得
  SELECT
    info->>''key2'' AS key2
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND COALESCE(info->>''key0'','''') = @key0
    AND info->>''key1'' = ''PHYSIOLOGY_INFO''
)

, pat_exam_info AS ( 
    -- 検査履歴情報と最新情報の結合
    SELECT
        exam_main_cd
        , exam_order_info
        , is_del
        , order_exam_set_info
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
        , reg_order_class
        , 1 AS idx
        , up_date
    FROM pat_exam_main 
    WHERE exam_main_cd = @ordNo
    ORDER BY idx ASC, up_date DESC
    LIMIT 1)
, conv_order_class_info AS ( 
  -- 透析前後区分変換情報取得(電子カルテ連携用)
  SELECT
    info->>''key2'' AS key2
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND COALESCE(info->>''key0'','''') = @key0
    AND info->>''key1'' = ''CONV_EXAMIN_ORDER_CLASS_TO_KARTE''
)
, hosp_code_no_info AS ( 
  -- 院内コード使用区分取得(1:コード1, 2:コード2, 3:コード3)
  -- デフォルトは1
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
    AND COALESCE(info->>''key0'','''') = @key0
    AND info->>''key1'' = ''PHYSIOLOGY_INFO''
    AND info->>''key2'' = ''USE_IN_HOSP_NO''
  UNION
  SELECT
    ''1'' AS order_no 
    , ''1'' AS VALUE 
  ORDER BY order_no ASC LIMIT 1
) ,
sbt_cd_no_info AS ( 
  -- 属性コード使用区分取得(1:属性1, 2:属性2, 3:属性3)
  -- デフォルトは1
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
    AND COALESCE(info->>''key0'','''') = @key0
    AND info->>''key1'' = ''PHYSIOLOGY_INFO''
    AND info->>''key2'' = ''USE_sbt_cd''
  UNION
  SELECT
    ''1'' AS order_no 
    , ''1'' AS VALUE 
  ORDER BY order_no ASC LIMIT 1
) 
, examin_hosp_code_info AS ( 
  -- 心電図オーダ送信用の検査セットの院内コード取得
  SELECT
   COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0''
    AND COALESCE(info->>''key0'','''') = @key0
    AND info->>''key1'' = ''EXAMIN_IN_HOSP_CODE'' 
    AND info->>''key2'' = ''PHY''
),
data_exam_all as (
  -- 検査詳細データの取得と整形
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
    -- unitを用いて属性情報を取得
    ,(select COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS sbt_cd1 
      FROM
        mst_coop_ini AS ini 
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
      WHERE
        facility_cd = @facilityCd 
        AND is_del = ''0'' 
        AND COALESCE(info->>''key0'','''') = @key0
        AND info->>''key1'' = ''PHYSIOLOGY_CLASS_ATTR''
        AND info->>''key2'' = item.unit)
     ,mset.exam_set_cd,
     mset.exam_set_name
    , order_info->>''item_name'' AS item_name
    ,
    item.unit AS tag_name
    ,(select COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS sbt_cd1_sort
      FROM
        mst_coop_ini AS ini 
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
      WHERE
        facility_cd = @facilityCd 
        AND is_del = ''0'' 
        AND COALESCE(info->>''key0'','''') =@key0
        AND info->>''key1'' = ''PHYSIOLOGY_CLASS_SORT''
        AND info->>''key2'' = item.unit)
    ,set_info->>''set_cd'' as ordernow
  FROM
    pat_exam_info AS exam 
    CROSS JOIN LATERAL json_array_elements(exam.order_exam_set_info ::json) set_info 
    LEFT OUTER JOIN mst_exam_set AS mset ON set_info->>''set_cd'' = (mset.exam_set_cd ::TEXT) 
    LEFT OUTER JOIN json_array_elements(exam.exam_order_info ::json) order_info  ON order_info->>''set_cd'' = set_info->>''set_cd'' 
    LEFT OUTER JOIN mst_exam_item AS item ON order_info->>''item_cd'' = (item.exam_item_cd ::TEXT) 
  WHERE
    exam.is_del = ''0'' 
    AND jsonb_array_length(exam.exam_order_info) > 0 
    AND jsonb_array_length(exam.order_exam_set_info) > 0 
  ) AS T01
WHERE
  COALESCE(NULLIF(T01.in_hospital_cd1, ''''), ''no_cd'') <> ''no_cd'' 
  AND COALESCE(NULLIF(T01.in_hospital_cd_set, ''''), ''no_cd'') <> ''no_cd'' 
  AND (SELECT value FROM examin_hosp_code_info  )!= '''' -- 心電図オーダの院内コード設定が存在しない場合は電文を送信しない
  AND (SELECT value FROM examin_hosp_code_info )is not null
  AND T01.in_hospital_cd_set = (select value from examin_hosp_code_info )
  AND sbt_cd1 <> '''' AND SBT_CD1 IS NOT NULL
order by T01.ordernow
),
max_balance as (
  -- 最大件数調整用
select ((select count(1) from data_exam_all where ordernow  = (
select max(aa.ordernow) from (select ordernow from data_exam_all limit 298) as aa ))-
(select count(1) from (select * from data_exam_all limit 298 ) as aa where aa.ordernow  =  (
select max(aa.ordernow) from (select ordernow from data_exam_all limit 298) as aa ))) as balance
,(select count(1) from (select * from data_exam_all limit 298 ) as aa where aa.ordernow  =  (
select max(aa.ordernow) from (select ordernow from data_exam_all limit 298) as aa )) as min_number
)
select * from (
  -- 上限300件（ヘッダ等除く残枠298判定）
(select * from data_exam_all 
where (select balance  from max_balance )  = 0 
limit 298)
union all
(select * from data_exam_all  where (select balance  from max_balance ) != 0 
limit (298 - (select min_number  from max_balance)))
-- 透析前後区分の設定(3レコード目として追加)
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
  -- 2023.08.31 K.Takahashi (NDS) -66670と合わせる為修正
WHERE
  exam.exam_main_cd  = @ordNo 
)as T02
ORDER BY
   order_no ASC
  , ordernow ASC
  , sbt_cd1_sort ASC
LIMIT 299', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '富士通）依頼検査繰り返し部 ★削除用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
