delete from "sys_data_set" where sql_cd in (-23,-40,-42,-45);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-23, 'WITH sch_start_time_info AS ( 
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
    AND info->>''key1'' = ''COOP_CONFIG''
    AND info->>''key2'' = ''SCH_START_TIME''
  UNION
  SELECT
    1 AS order_no
    , ''0'' AS sch_start_time 
  ORDER BY order_no ASC LIMIT 1
) 
, order_time_type_info AS ( 
  -- オーダ時間の設定値。0：連携設定で時刻を指定、1：透析スケジュールより当日１回目の予定開始時刻
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
, ind_treat_start_date_time_info AS (
  -- 治療予定の予定治療日+開始時刻(YYYYMMDDHH24MISS)
  SELECT
    pem.reg_order_class
    , TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'') AS exam_date
    , ord.ord_no
    , TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'') || 
      CASE WHEN (SELECT sch_start_time FROM sch_start_time_info) = ''1'' -- 1：スケジュールの透析開始時刻
      THEN COALESCE(NULLIF(ord.ind_treat_start_time, '''') || ''00'', kur.kur_standard_start_time) -- 透析開始時刻が未設定の場合は該当クールの標準開始時刻を使用します
      ELSE kur.kur_standard_start_time  -- 0：クールマスタの標準開始時刻
      END AS ind_treat_start_date_time
    , TO_NUMBER(COALESCE(NULLIF(ord.ind_cond_info -> ''1'' ->> ''value'', ''''), ''0''), ''FM999999'') AS treat_times -- 治療時間
  FROM
    pat_exam_main AS pem 
    LEFT OUTER JOIN ord_main AS ord ON ord.pat_id = pem.pat_id AND ord.treat_date = TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'') AND ord.ind_kur_cd > 0 AND ord.is_del = ''0''
    LEFT OUTER JOIN mst_kur AS kur ON kur.kur_cd = ord.ind_kur_cd 
  WHERE
    pem.exam_main_cd = @ordNo
    AND pem.reg_order_class IN (''1'', ''2'') -- 1:透析前、2:透析後
  ORDER BY ind_treat_start_time ASC LIMIT 1
)

-- ①オーダ時間の設定値。 0：連携設定で時刻を指定、検査予定＝0:その他
SELECT
  TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'') AS exam_date
  , CASE reg_order_class 
    WHEN ''1'' THEN COALESCE(NULLIF((SELECT order_time FROM order_time_info WHERE key2 = ''ORDER_TIME_BEFORE''), ''''), (SELECT order_time FROM order_time_info WHERE key2 = ''DEFAULT''))
    WHEN ''2'' THEN COALESCE(NULLIF((SELECT order_time FROM order_time_info WHERE key2 = ''ORDER_TIME_AFTER''), ''''), (SELECT order_time FROM order_time_info WHERE key2 = ''DEFAULT''))
    ELSE COALESCE(NULLIF((SELECT order_time FROM order_time_info WHERE key2 = ''ORDER_TIME_OTHER''), ''''), (SELECT order_time FROM order_time_info WHERE key2 = ''DEFAULT''))
    END AS exam_start_time
FROM
  pat_exam_main AS pem 
WHERE
  pem.exam_main_cd = @ordNo
  AND pem.reg_order_class = ''0'' -- 0:その他
  AND (SELECT order_time_type FROM order_time_type_info) = ''0'' -- 0：連携設定で時刻を指定

-- ②オーダ時間の設定値。 0：連携設定で時刻を指定、検査予定＝ 1:透析前、2:透析後
UNION
SELECT
  exam_date
  , CASE reg_order_class 
    WHEN ''1'' THEN COALESCE(NULLIF((SELECT order_time FROM order_time_info WHERE key2 = ''ORDER_TIME_BEFORE''), ''''), (SELECT order_time FROM order_time_info WHERE key2 = ''DEFAULT''))
    WHEN ''2'' THEN COALESCE(NULLIF((SELECT order_time FROM order_time_info WHERE key2 = ''ORDER_TIME_AFTER''), ''''), (SELECT order_time FROM order_time_info WHERE key2 = ''DEFAULT''))
    ELSE COALESCE(NULLIF((SELECT order_time FROM order_time_info WHERE key2 = ''ORDER_TIME_OTHER''), ''''), (SELECT order_time FROM order_time_info WHERE key2 = ''DEFAULT''))
    END AS exam_start_time
FROM
  ind_treat_start_date_time_info
WHERE
  ord_no IS NOT NULL -- 治療予定がない場合の透析前、透析後の区分の検査予定は送信対象外のため送信しないこと
  AND (SELECT order_time_type FROM order_time_type_info) = ''0'' -- 0：連携設定で時刻を指定

-- ③オーダ時間の設定値。 1：透析スケジュールより当日１回目の予定開始時刻、検査予定＝0:その他
UNION
SELECT
  TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'') AS exam_date
  , COALESCE(NULLIF(mset.other_exam_time, ''''), ''0000'') || ''00'' AS exam_start_time
FROM
  pat_exam_main AS pem 
  CROSS JOIN LATERAL json_array_elements(pem.order_exam_set_info ::json) set_info 
  LEFT OUTER JOIN mst_exam_set AS mset ON set_info->>''set_cd'' = (mset.exam_set_cd ::TEXT) 
WHERE
  pem.exam_main_cd = @ordNo
  AND pem.reg_order_class = ''0'' -- 0:その他
  AND (SELECT order_time_type FROM order_time_type_info) = ''1'' -- 1：透析スケジュール

-- ④オーダ時間の設定値。 1：透析スケジュールより当日１回目の予定開始時刻、検査予定＝ 1:透析前、2:透析後
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
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）検査依頼：検査日時取得', '2020-05-11 15:02:47.001', CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-40, 'WITH sch_start_time_info AS ( 
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
    AND info->>''key1'' = ''COOP_CONFIG''
    AND info->>''key2'' = ''SCH_START_TIME''
  UNION
  SELECT
    1 AS order_no
    , ''0'' AS sch_start_time 
  ORDER BY order_no ASC LIMIT 1
) 
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
      THEN COALESCE(NULLIF(ord.ind_treat_start_time, '''') || ''00'', kur.kur_standard_start_time) -- 透析開始時刻が未設定の場合は該当クールの標準開始時刻を使用します
      ELSE kur.kur_standard_start_time  -- 0：クールマスタの標準開始時刻
      END AS ind_treat_start_date_time
    , TO_NUMBER(COALESCE(NULLIF(ord.ind_cond_info -> ''1'' ->> ''value'', ''''), ''0''), ''FM999999'') AS treat_times -- 治療時間
  FROM
    pat_rad_main AS pem 
    LEFT OUTER JOIN ord_main AS ord ON ord.pat_id = pem.pat_id AND ord.treat_date = TO_CHAR(pem.reg_rad_date, ''YYYYMMDD'') AND ord.ind_kur_cd > 0 AND ord.is_del = ''0''
    LEFT OUTER JOIN mst_kur AS kur ON kur.kur_cd = ord.ind_kur_cd 
  WHERE
    pem.rad_result_cd = @ordNo
    AND pem.reg_order_class IN (''1'', ''2'') -- 1:透析前、2:透析後
  ORDER BY ind_treat_start_time ASC LIMIT 1
)

-- ①オーダ時間の設定値。 0：「777700」固定を設定します、検査予定＝0:その他
SELECT
  TO_CHAR(pem.reg_rad_date, ''YYYYMMDD'') AS exam_date
  , ''777700'' AS exam_start_time
FROM 
  pat_rad_main AS pem
WHERE 
  pem.rad_result_cd = @ordNo
  AND pem.reg_order_class = ''0'' -- 0:その他
  AND (SELECT order_time_type FROM order_time_type_info) = ''0''

-- ②オーダ時間の設定値。 0：「777700」固定を設定します、検査予定＝ 1:透析前、2:透析後
UNION
SELECT
  exam_date
  , ''777700'' AS exam_start_time
FROM
  ind_treat_start_date_time_info
WHERE
  ord_no IS NOT NULL -- 治療予定がない場合の透析前、透析後の区分の検査予定は送信対象外のため送信しないこと
  AND (SELECT order_time_type FROM order_time_type_info) = ''0''

-- ③オーダ時間の設定値。 1：透析スケジュールより当日１回目の予定開始時刻、検査予定＝0:その他→検査セットマスタのその他検査時刻
UNION
SELECT
  TO_CHAR(pem.reg_rad_date, ''YYYYMMDD'') AS exam_date
  , ''777700'' AS exam_start_time  -- TODO:透析単純撮影オーダは「検査セットマスタ」が無し、777700を設定する
FROM
  pat_rad_main AS pem 
WHERE
  pem.rad_result_cd = @ordNo
  AND pem.reg_order_class = ''0'' -- 0:その他
  AND (SELECT order_time_type FROM order_time_type_info) = ''1'' -- 1：透析スケジュール

-- ④オーダ時間の設定値。 1：透析スケジュールより当日１回目の予定開始時刻、検査予定＝ 1:透析前、2:透析後
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

-- ⑤オーダ時間の設定値。2：検査予定時間を設定します、検査予定＝0:その他
UNION
SELECT
  TO_CHAR(pem.reg_rad_date, ''YYYYMMDD'') AS exam_date
  , ''777700'' AS exam_start_time  -- TODO:検査予定時間 が無し、777700を設定する
FROM 
  pat_rad_main AS pem
WHERE 
  pem.rad_result_cd = @ordNo
  AND pem.reg_order_class = ''0'' -- 0:その他
  AND (SELECT order_time_type FROM order_time_type_info) = ''2''

-- ⑥オーダ時間の設定値。2：検査予定時間を設定します、検査予定＝ 1:透析前、2:透析後
UNION
SELECT
  exam_date
  , ''777700'' AS exam_start_time  -- TODO:検査予定時間 が無し、777700を設定する
FROM
  ind_treat_start_date_time_info
WHERE
  ord_no IS NOT NULL -- 治療予定がない場合の透析前、透析後の区分の検査予定は送信対象外のため送信しないこと
  AND (SELECT order_time_type FROM order_time_type_info) = ''2''
', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）放射線：検査日時取得', '2022-01-19 18:29:49', CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-42, 'WITH sch_start_time_info AS ( 
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
    AND info->>''key1'' = ''COOP_CONFIG''
    AND info->>''key2'' = ''SCH_START_TIME''
  UNION
  SELECT
    1 AS order_no
    , ''0'' AS sch_start_time 
  ORDER BY order_no ASC LIMIT 1
) 
, order_time_type_info AS ( 
  -- オーダ時間の設定値。0：連携設定で時刻を指定、1：透析スケジュールより当日１回目の予定開始時刻
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
, ind_treat_start_date_time_info AS (
  -- 治療予定の予定治療日+開始時刻(YYYYMMDDHH24MISS)
  SELECT
    pem.reg_order_class
    , TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'') AS exam_date
    , ord.ord_no
    , TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'') || 
      CASE WHEN (SELECT sch_start_time FROM sch_start_time_info) = ''1'' -- 1：スケジュールの透析開始時刻
      THEN COALESCE(NULLIF(ord.ind_treat_start_time, '''') || ''00'', kur.kur_standard_start_time) -- 透析開始時刻が未設定の場合は該当クールの標準開始時刻を使用します
      ELSE kur.kur_standard_start_time  -- 0：クールマスタの標準開始時刻
      END AS ind_treat_start_date_time
    , TO_NUMBER(COALESCE(NULLIF(ord.ind_cond_info -> ''1'' ->> ''value'', ''''), ''0''), ''FM999999'') AS treat_times -- 治療時間
  FROM
    pat_exam_main_hst AS pem 
    LEFT OUTER JOIN ord_main AS ord ON ord.pat_id = pem.pat_id AND ord.treat_date = TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'') AND ord.ind_kur_cd > 0 AND ord.is_del = ''0''
    LEFT OUTER JOIN mst_kur AS kur ON kur.kur_cd = ord.ind_kur_cd 
  WHERE
    pem.exam_main_cd = @ordNo
    AND pem.reg_order_class IN (''1'', ''2'') -- 1:透析前、2:透析後
  ORDER BY ind_treat_start_time ASC LIMIT 1
)

-- ①オーダ時間の設定値。 0：連携設定で時刻を指定、検査予定＝0:その他
SELECT
  TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'') AS exam_date
  , CASE reg_order_class 
    WHEN ''1'' THEN COALESCE(NULLIF((SELECT order_time FROM order_time_info WHERE key2 = ''ORDER_TIME_BEFORE''), ''''), (SELECT order_time FROM order_time_info WHERE key2 = ''DEFAULT''))
    WHEN ''2'' THEN COALESCE(NULLIF((SELECT order_time FROM order_time_info WHERE key2 = ''ORDER_TIME_AFTER''), ''''), (SELECT order_time FROM order_time_info WHERE key2 = ''DEFAULT''))
    ELSE COALESCE(NULLIF((SELECT order_time FROM order_time_info WHERE key2 = ''ORDER_TIME_OTHER''), ''''), (SELECT order_time FROM order_time_info WHERE key2 = ''DEFAULT''))
    END AS exam_start_time
FROM
  pat_exam_main_hst AS pem 
WHERE
  pem.exam_main_cd = @ordNo
  AND pem.reg_order_class = ''0'' -- 0:その他
  AND (SELECT order_time_type FROM order_time_type_info) = ''0'' -- 0：連携設定で時刻を指定

-- ②オーダ時間の設定値。 0：連携設定で時刻を指定、検査予定＝ 1:透析前、2:透析後
UNION
SELECT
  exam_date
  , CASE reg_order_class 
    WHEN ''1'' THEN COALESCE(NULLIF((SELECT order_time FROM order_time_info WHERE key2 = ''ORDER_TIME_BEFORE''), ''''), (SELECT order_time FROM order_time_info WHERE key2 = ''DEFAULT''))
    WHEN ''2'' THEN COALESCE(NULLIF((SELECT order_time FROM order_time_info WHERE key2 = ''ORDER_TIME_AFTER''), ''''), (SELECT order_time FROM order_time_info WHERE key2 = ''DEFAULT''))
    ELSE COALESCE(NULLIF((SELECT order_time FROM order_time_info WHERE key2 = ''ORDER_TIME_OTHER''), ''''), (SELECT order_time FROM order_time_info WHERE key2 = ''DEFAULT''))
    END AS exam_start_time
FROM
  ind_treat_start_date_time_info
WHERE
  ord_no IS NOT NULL -- 治療予定がない場合の透析前、透析後の区分の検査予定は送信対象外のため送信しないこと
  AND (SELECT order_time_type FROM order_time_type_info) = ''0'' -- 0：連携設定で時刻を指定

-- ③オーダ時間の設定値。 1：透析スケジュールより当日１回目の予定開始時刻、検査予定＝0:その他
UNION
SELECT
  TO_CHAR(pem.reg_exam_date, ''YYYYMMDD'') AS exam_date
  , COALESCE(NULLIF(mset.other_exam_time, ''''), ''0000'') || ''00'' AS exam_start_time
FROM
  pat_exam_main_hst AS pem 
  CROSS JOIN LATERAL json_array_elements(pem.order_exam_set_info ::json) set_info 
  LEFT OUTER JOIN mst_exam_set AS mset ON set_info->>''set_cd'' = (mset.exam_set_cd ::TEXT) 
WHERE
  pem.exam_main_cd = @ordNo
  AND pem.reg_order_class = ''0'' -- 0:その他
  AND (SELECT order_time_type FROM order_time_type_info) = ''1'' -- 1：透析スケジュール

-- ④オーダ時間の設定値。 1：透析スケジュールより当日１回目の予定開始時刻、検査予定＝ 1:透析前、2:透析後
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
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）検査依頼：検査日時取得 ★削除用', '2022-01-17 15:02:47', CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-45, 'WITH sch_start_time_info AS ( 
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
    AND info->>''key1'' = ''COOP_CONFIG''
    AND info->>''key2'' = ''SCH_START_TIME''
  UNION
  SELECT
    1 AS order_no
    , ''0'' AS sch_start_time 
  ORDER BY order_no ASC LIMIT 1
) 
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
      THEN COALESCE(NULLIF(ord.ind_treat_start_time, '''') || ''00'', kur.kur_standard_start_time) -- 透析開始時刻が未設定の場合は該当クールの標準開始時刻を使用します
      ELSE kur.kur_standard_start_time  -- 0：クールマスタの標準開始時刻
      END AS ind_treat_start_date_time
    , TO_NUMBER(COALESCE(NULLIF(ord.ind_cond_info -> ''1'' ->> ''value'', ''''), ''0''), ''FM999999'') AS treat_times -- 治療時間
  FROM
    pat_rad_main_hst AS pem 
    LEFT OUTER JOIN ord_main AS ord ON ord.pat_id = pem.pat_id AND ord.treat_date = TO_CHAR(pem.reg_rad_date, ''YYYYMMDD'') AND ord.ind_kur_cd > 0 AND ord.is_del = ''0''
    LEFT OUTER JOIN mst_kur AS kur ON kur.kur_cd = ord.ind_kur_cd 
  WHERE
    pem.rad_result_cd = @ordNo
    AND pem.reg_order_class IN (''1'', ''2'') -- 1:透析前、2:透析後
  ORDER BY ind_treat_start_time ASC LIMIT 1
)

-- ①オーダ時間の設定値。 0：「777700」固定を設定します、検査予定＝0:その他
SELECT
  TO_CHAR(pem.reg_rad_date, ''YYYYMMDD'') AS exam_date
  , ''777700'' AS exam_start_time
FROM 
  pat_rad_main_hst AS pem
WHERE 
  pem.rad_result_cd = @ordNo
  AND pem.reg_order_class = ''0'' -- 0:その他
  AND (SELECT order_time_type FROM order_time_type_info) = ''0''

-- ②オーダ時間の設定値。 0：「777700」固定を設定します、検査予定＝ 1:透析前、2:透析後
UNION
SELECT
  exam_date
  , ''777700'' AS exam_start_time
FROM
  ind_treat_start_date_time_info
WHERE
  ord_no IS NOT NULL -- 治療予定がない場合の透析前、透析後の区分の検査予定は送信対象外のため送信しないこと
  AND (SELECT order_time_type FROM order_time_type_info) = ''0''

-- ③オーダ時間の設定値。 1：透析スケジュールより当日１回目の予定開始時刻、検査予定＝0:その他→検査セットマスタのその他検査時刻
UNION
SELECT
  TO_CHAR(pem.reg_rad_date, ''YYYYMMDD'') AS exam_date
  , ''777700'' AS exam_start_time  -- TODO:透析単純撮影オーダは「検査セットマスタ」が無し、777700を設定する
FROM
  pat_rad_main_hst AS pem 
WHERE
  pem.rad_result_cd = @ordNo
  AND pem.reg_order_class = ''0'' -- 0:その他
  AND (SELECT order_time_type FROM order_time_type_info) = ''1'' -- 1：透析スケジュール

-- ④オーダ時間の設定値。 1：透析スケジュールより当日１回目の予定開始時刻、検査予定＝ 1:透析前、2:透析後
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

-- ⑤オーダ時間の設定値。2：検査予定時間を設定します、検査予定＝0:その他
UNION
SELECT
  TO_CHAR(pem.reg_rad_date, ''YYYYMMDD'') AS exam_date
  , ''777700'' AS exam_start_time  -- TODO:検査予定時間 が無し、777700を設定する
FROM 
  pat_rad_main_hst AS pem
WHERE 
  pem.rad_result_cd = @ordNo
  AND pem.reg_order_class = ''0'' -- 0:その他
  AND (SELECT order_time_type FROM order_time_type_info) = ''2''

-- ⑥オーダ時間の設定値。2：検査予定時間を設定します、検査予定＝ 1:透析前、2:透析後
UNION
SELECT
  exam_date
  , ''777700'' AS exam_start_time  -- TODO:検査予定時間 が無し、777700を設定する
FROM
  ind_treat_start_date_time_info
WHERE
  ord_no IS NOT NULL -- 治療予定がない場合の透析前、透析後の区分の検査予定は送信対象外のため送信しないこと
  AND (SELECT order_time_type FROM order_time_type_info) = ''2''
', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）放射線：検査日時取得 ★削除用', '2022-01-19 18:29:49', CURRENT_TIMESTAMP, NULL);
