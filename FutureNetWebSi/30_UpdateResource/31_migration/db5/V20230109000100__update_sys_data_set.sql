DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (-41,-45,-46,-27,-48,-40,-50,-662,-663,-52,-101,-57,-80,-81,-666);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-27, 'WITH hosp_code_no_info AS ( 
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
    pat_rad_main AS rad 
    CROSS JOIN LATERAL json_array_elements(rad.order_rad_set_info ::json) info 
    LEFT OUTER JOIN mst_rad_set AS mset ON TO_NUMBER(info ->> ''rad_set_cd'', ''FM999999999'') = mset.rad_set_cd 
  WHERE
    rad.is_del = ''0'' 
    AND rad.rad_result_cd = @ordNo 
    AND jsonb_array_length(rad.order_rad_set_info) > 0 
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
  AND COALESCE(NULLIF(in_hospital_cd1, ''''), ''no_cd'') <> ''no_cd'' 
  AND ((SELECT COUNT(1) FROM examin_hosp_code_info) = 0 -- 検体検査の院内コードを設定が存在しない場合は全て送信対象とする。
   OR EXISTS (SELECT 1 FROM examin_hosp_code_info AS hosp WHERE COALESCE(NULLIF(in_hospital_cd1, ''''), ''no_cd'') = hosp.key2)
    -- 院内コードをキーとして連携IDを設定するの場合は送信対象とする。
  )
ORDER BY
  order_no ASC
LIMIT 299 ', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）放射線：撮影繰り返し部', '2022-01-19 18:29:49',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-50, 'SELECT
  MAX(CASE T01.key2 when ''SLIP_CODE'' THEN T01.value ELSE null END) AS slip_code
  , MAX(CASE T01.key2 when ''SLIP_NAME'' THEN T01.value ELSE null END) AS slip_name
FROM
(
  (
    SELECT
      ''0'' AS order_no 
      , ''SLIP_CODE'' AS key2 
      , COALESCE(NULLIF(info->>''value'', ''''), COALESCE(NULLIF(info->>''default_v'', ''''), ''F010'')) AS value 
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
      AND info->>''key2'' = ''SLIP_CODE''
    UNION
    SELECT
      ''1'' AS order_no 
      , ''SLIP_CODE'' AS key2 
      , ''F010'' AS value 
    ORDER BY order_no ASC LIMIT 1
  )
  UNION
  (
    SELECT
      ''0'' AS order_no 
      , ''SLIP_NAME'' AS key2 
      , COALESCE(NULLIF(info->>''value'', ''''), COALESCE(NULLIF(info->>''default_v'', ''''), ''病院一般撮影'')) AS value 
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
      AND info->>''key2'' = ''SLIP_NAME''
    UNION
    SELECT
      ''1'' AS order_no 
      , ''SLIP_NAME'' AS key2 
      , ''病院一般撮影'' AS value 
    ORDER BY order_no ASC LIMIT 1
  )
) AS T01', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）放射線：伝票情報取得 ', '2022-01-19 18:29:49',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-40, 'WITH sch_start_time_info AS ( 
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

-- ①オーダ時間の設定値。 0：「777700」固定を設定します
SELECT
  TO_CHAR(pem.reg_rad_date, ''YYYYMMDD'') AS exam_date
  , ''777700'' AS exam_start_time
FROM 
  pat_rad_main AS pem
WHERE 
  pem.rad_result_cd = @ordNo
  AND (SELECT order_time_type FROM order_time_type_info) = ''0''

-- ②オーダ時間の設定値。 1：透析スケジュールより当日１回目の予定開始時刻、検査予定＝0:その他→検査セットマスタのその他検査時刻
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
  pat_rad_main AS pem
WHERE 
  pem.rad_result_cd = @ordNo
  AND (SELECT order_time_type FROM order_time_type_info) = ''2''
', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）放射線：検査日時取得', '2022-01-19 18:29:49',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-45, 'WITH sch_start_time_info AS ( 
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

-- ①オーダ時間の設定値。 0：「777700」固定を設定します
SELECT
  TO_CHAR(pem.reg_rad_date, ''YYYYMMDD'') AS exam_date
  , ''777700'' AS exam_start_time
FROM 
  pat_rad_main_hst AS pem
WHERE 
  pem.rad_result_cd = @ordNo
  AND (SELECT order_time_type FROM order_time_type_info) = ''0''

-- ②オーダ時間の設定値。 1：透析スケジュールより当日１回目の予定開始時刻、検査予定＝0:その他→検査セットマスタのその他検査時刻
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
  pat_rad_main_hst AS pem
WHERE 
  pem.rad_result_cd = @ordNo
  AND (SELECT order_time_type FROM order_time_type_info) = ''2''
', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）放射線：検査日時取得 ★削除用', '2022-01-19 18:29:49',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-662, 'WITH default_user_no AS (
  -- デフォルトrad_ord利用者番号（検査オーダ用）
  SELECT
    0 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
		-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end	
    AND info ->> ''key1'' = ''FJI_COM_INFO''
    AND info ->> ''key2'' = ''EXAM_DEFAULT_USER_NO''
  UNION
  SELECT
    1 AS order_no
    , '''' AS staff_cd
  ORDER BY order_no ASC LIMIT 1
)
, user_no_setting AS (
  -- 利用者番号出力設定（検査オーダ用）
 SELECT
    0 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), COALESCE(NULLIF(info ->> ''default_v'', ''''), ''0'')) AS setting
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
		-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end	
    AND info ->> ''key1'' = ''FJI_COM_INFO''
    AND info ->> ''key2'' = ''EXAM_USER_NO_SETTING''
  UNION
  SELECT
    1 AS order_no
    , ''0'' AS setting
  ORDER BY order_no ASC LIMIT 1
)
, ind_user_info AS(
  -- 指示者
  SELECT
    TO_CHAR(pem.ind_user_id, ''FM9999999999'') AS staff_cd
  FROM
    pat_rad_main pem
  WHERE
    pem.rad_result_cd = @ordNo
    AND pem.ind_user_id IS NOT NULL
)
, staff_user_info AS(
  -- 担当者
  SELECT
    ROW_NUMBER() OVER () AS CNT
    , staff ->> ''staff_cd'' AS staff_cd
  FROM
    pat_main pm
    CROSS JOIN LATERAL json_array_elements(pm.charge_staff_info ::json) staff
  WHERE
    pm.is_del = ''0''
    AND pm.pat_id = @patId
    AND staff ->> ''is_main'' = ''1''
)
, up_user_info AS(
  -- 操作者
  SELECT
    TO_CHAR(pem.up_staff, ''FM9999999999'') AS staff_cd
  FROM
    pat_rad_main pem
  WHERE
    pem.rad_result_cd = @ordNo
    AND pem.up_staff IS NOT NULL
),
kur_qt as (
select reg_rad_date::time as exam_set_cd from pat_rad_main where rad_result_cd = @ordNo
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
select EXTRACT(DOW FROM reg_rad_date)  as reg_rad_date from pat_rad_main where rad_result_cd = @ordNo
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
 when 7 =(select reg_rad_date from weekend)		
then ''Sun'' 
END ) as aaa))::json->>''user_id'' as staff_cd from mst_kur mst where  mst.kur_cd = (select ind_kur_cd from ind_kur_cd)
and facility_cd = @facilityCd
)

SELECT
   NULLIF(MAX(CASE part WHEN ''comm'' THEN staff_cd ELSE '''' END), '''') AS  staff_cd_comm
  ,NULLIF(MAX(CASE part WHEN ''data'' THEN staff_cd ELSE '''' END), '''')  AS staff_cd_data
 ,(SELECT staff_cd  FROM default_user_no) AS default_user_no
FROM
  (

  -- 3：共通部 操作者
  -- 4：共通部 操作者
  -- 5：共通部 操作者
    SELECT ''comm'' AS part, staff_cd FROM up_user_info WHERE (SELECT setting FROM user_no_setting) IN (''3'',''4'',''5'')
    -- 0：共通部 指示者
    UNION
  SELECT ''comm'' AS part, staff_cd FROM ind_user_info WHERE (SELECT setting FROM user_no_setting) IN (''0'')
    -- 1：共通部 担当医１
    UNION
    SELECT ''comm'' AS part, staff_cd FROM staff_user_info WHERE (SELECT setting FROM user_no_setting) = ''1'' AND CNT = 1
    -- 2：共通部 担当医２
    UNION
    SELECT ''comm'' AS part, staff_cd FROM staff_user_info WHERE (SELECT setting FROM user_no_setting) =''2'' AND CNT = 2
		UNION
    SELECT ''comm'' AS part, staff_cd FROM mst_user_authenticator WHERE (SELECT setting FROM user_no_setting) =''6''
    -- 0：内容部 指示者
  -- 3：内容部 指示者
  UNION
  SELECT ''data'' AS part, staff_cd FROM ind_user_info WHERE (SELECT setting FROM user_no_setting)  in (''0'',''3'')
    -- 1：内容部 担当医１
    -- 4：内容部 担当医１
    UNION
    SELECT ''data'' AS part, staff_cd FROM staff_user_info WHERE (SELECT setting FROM user_no_setting) IN (''1'', ''4'') AND CNT = 1
    -- 2：内容部 担当医２
    -- 5：内容部 担当医２
    UNION
    SELECT ''data'' AS part, staff_cd FROM staff_user_info WHERE (SELECT setting FROM user_no_setting) IN (''2'', ''5'') AND CNT = 2
			UNION
    SELECT ''data'' AS part, staff_cd FROM mst_user_authenticator WHERE (SELECT setting FROM user_no_setting) =''6''
  ) AS T
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）rad_ord利用者番号', '2020-05-11 17:19:24.215',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-663, 'WITH default_user_no AS (
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
   , ind_user_info AS (
 -- 指示者
  SELECT
    TO_CHAR(pem.ind_user_id, ''FM9999999999'') AS staff_cd
  FROM
    pat_rad_main_hst pem
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
    pat_rad_main_hst pem
  WHERE
    pem.rad_result_cd = @ordNo
    AND pem.up_staff IS NOT NULL
		order by up_date desc limit 1
),
kur_qt as (
select reg_rad_date::time as exam_set_cd from pat_rad_main_hst where rad_result_cd = @ordNo order by up_date desc limit 1
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
select EXTRACT(DOW FROM reg_rad_date)  as reg_rad_date from pat_rad_main_hst where rad_result_cd = @ordNo order by up_date desc limit 1
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
 when 7 =(select reg_rad_date from weekend)		
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
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）rad_ord利用者番号delete', '2020-05-11 17:19:24.215',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-46, 'WITH hosp_code_no_info AS ( 
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
    pat_rad_main_hst AS rad 
    CROSS JOIN LATERAL json_array_elements(rad.order_rad_set_info ::json) info 
    LEFT OUTER JOIN mst_rad_set AS mset ON TO_NUMBER(info ->> ''rad_set_cd'', ''FM999999999'') = mset.rad_set_cd 
  WHERE
    --rad.is_del = ''0'' 
    rad.rad_result_cd = @ordNo 
    AND jsonb_array_length(rad.order_rad_set_info) > 0 
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
  AND COALESCE(NULLIF(in_hospital_cd1, ''''), ''no_cd'') <> ''no_cd'' 
  AND ((SELECT COUNT(1) FROM examin_hosp_code_info) = 0 -- 検体検査の院内コードを設定が存在しない場合は全て送信対象とする。
   OR EXISTS (SELECT 1 FROM examin_hosp_code_info AS hosp WHERE COALESCE(NULLIF(in_hospital_cd1, ''''), ''no_cd'') = hosp.key2)
    -- 院内コードをキーとして連携IDを設定するの場合は送信対象とする。
  )
ORDER BY
  order_no ASC
LIMIT 299 ', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）放射線：撮影繰り返し部 ★削除用', '2022-01-19 18:29:49',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-41, 'WITH course_from_info AS ( 
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS course_from 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
		-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end	
    AND info ->> ''key1'' = ''XRAY_INFO'' 
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
		-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end	
    AND info ->> ''key1'' = ''XRAY_INFO'' 
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
		-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end	
    AND info ->> ''key1'' = ''XRAY_INFO'' 
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
	-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end		
    AND info ->> ''key1'' = ''XRAY_INFO'' 
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
    , dial_course.course_name AS dial_course_name
    , dial_course.in_hospital_cd_1 AS dial_course_in_hospital_cd 
  FROM
    pat_main AS main 
    LEFT JOIN mst_ward AS ward 
      ON ward.ward_cd ::TEXT = main.medical_care_info ->> ''ward_cd'' 
    LEFT JOIN mst_course AS course 
      ON course.course_cd ::TEXT = main.medical_care_info ->> ''main_course_cd'' 
    LEFT JOIN mst_course AS dial_course
      ON dial_course.course_cd ::TEXT = main.medical_care_info ->> ''dialysis_course_cd'' 
  WHERE
    main.pat_id = @patId 
) 
SELECT
  CASE 
    WHEN (SELECT course_from FROM course_from_info) = ''1'' 
      THEN COALESCE(NULLIF((SELECT course_in_hospital_cd FROM exam_info), ''''), (SELECT course_code FROM course_code_info)) 
    WHEN (SELECT course_from FROM course_from_info) = ''2'' 
      THEN COALESCE(NULLIF((SELECT dial_course_in_hospital_cd FROM exam_info), ''''), (SELECT course_code FROM course_code_info)) 
    ELSE (SELECT course_code FROM course_code_info) 
    END AS course_cd
  , CASE @inOut WHEN ''1'' THEN
      (CASE WHEN (SELECT ward_from FROM ward_from_info) = ''1'' 
       THEN COALESCE(NULLIF((SELECT ward_in_hospital_cd FROM exam_info), ''''), (SELECT ward_code FROM ward_code_info)) 
       ELSE (SELECT ward_code FROM ward_code_info) 
       END)
    ELSE '''' END AS ward_cd', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）放射線：診療科コードと病棟コード', '2022-01-19 18:29:49',CURRENT_TIMESTAMP, '[{"sql_cd": -20, "field_name": "in_out", "replace_var": "@inOut"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-52, 'WITH course_from_info AS ( 
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS course_from 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end	
    AND info ->> ''key1'' = ''FJI_COM_INFO'' 
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
		-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=@key0
  -- add #7304 異なる連携の機能を組み合わせて使用するため ljg end	
    AND info ->> ''key1'' = ''FJI_COM_INFO'' 
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
		-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end	
    AND info ->> ''key1'' = ''FJI_COM_INFO'' 
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
		-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end	
    AND info ->> ''key1'' = ''FJI_COM_INFO'' 
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
        , COALESCE(( CASE ord.rst_in_out_class WHEN ''0'' THEN ''1'' WHEN ''1'' THEN ''2'' ELSE NULL END ), '''')as  rst_in_out_class -- 院内コードの変換
  FROM
    pat_main AS main 
        INNER  JOIN ord_main AS ord
            on main.pat_id = ord.pat_id
    LEFT JOIN mst_ward AS ward 
      ON ward.ward_cd  = ord.rst_ward_cd
    LEFT JOIN mst_course AS course 
      ON course.course_cd  = ord.rst_course_cd
        where	
    main.pat_id =  @patId 
        and ord.ord_no = @ordNo
) 
SELECT
  CASE 
    WHEN (SELECT course_from FROM course_from_info) = ''1'' or (SELECT course_from FROM course_from_info) = ''2''
      THEN COALESCE(NULLIF((SELECT course_in_hospital_cd FROM exam_info), ''''), (SELECT course_code FROM course_code_info)) 
    ELSE (SELECT course_code FROM course_code_info) 
    END AS course_cd
  , CASE (SELECT  rst_in_out_class FROM  exam_info) WHEN ''2'' THEN
      (CASE WHEN (SELECT ward_from FROM ward_from_info) = ''1'' 
       THEN COALESCE(NULLIF((SELECT ward_in_hospital_cd FROM exam_info), ''''), (SELECT ward_code FROM ward_code_info)) 
       ELSE (SELECT ward_code FROM ward_code_info) 
       END)
    ELSE '''' END AS ward_cd', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）透析実績：診療科コードと病棟コード(-20を利用)', '2022-02-25 16:58:57.235',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-101, 'WITH dialysis_item_send AS (-- 透析項目送信
 SELECT
  info ->> ''key2'' AS key2,
  COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS 
 VALUE
  
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
 WHERE
  facility_cd = @facilityCd
  AND is_del = ''0'' 
	-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
		AND COALESCE(info->>''key0'','''')= @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end
  AND info ->> ''key1'' = ''DIALYSIS_ITEM_SEND'' 
 ),
 device AS (
		SELECT device_mode
		FROM mst_treatment mst JOIN ord_main ord 
		ON ord.rst_treatment_cd = mst.treatment_cd 
		AND ord.ord_no = @ordNo
),
 fji_com_info AS (-- 富士通共通設定
 SELECT
  info ->> ''key2'' AS key2,
  COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS 
 VALUE
  
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
 WHERE
  facility_cd = @facilityCd
  AND is_del = ''0'' 
	-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
		AND COALESCE(info->>''key0'','''')= @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end
  AND info ->> ''key1'' = ''FJI_COM_INFO'' 
 ),
 dialyis_item_sort AS (-- 項目情報部出力順（予約/実績送信用）
 SELECT
  info ->> ''key2'' AS key2,
  COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS 
 VALUE 
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
 WHERE
  facility_cd =  @facilityCd
  AND is_del = ''0'' 
	-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
		AND COALESCE(info->>''key0'','''')= @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end
  AND info ->> ''key1'' = ''DIALYSIS_ITEM_SORT'' 
 ),
 conv_teart_item_send_out AS ( -- 浄化方法変換（予約/実績送信用：外来）
 SELECT
  info ->> ''key2'' AS key2,
  UNNEST ( STRING_TO_ARRAY( ( COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) ), '','' ) ) AS 
 VALUE
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
 WHERE
  facility_cd = @facilityCd
  AND is_del = ''0'' 
	-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
		AND COALESCE(info->>''key0'','''')= @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end
  AND info ->> ''key1'' = ''CONV_TREAT_ITEM_SEND_OUT'' 
 ),
 conv_treat_item_send_in AS ( -- 浄化方法変換（予約/実績送信用：入院）
 SELECT
  info ->> ''key2'' AS key2,
  UNNEST ( string_to_array( COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ), '','' ) ) AS 
 VALUE
  
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
 WHERE
  facility_cd = @facilityCd
  AND is_del = ''0'' 
	-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
		AND COALESCE(info->>''key0'','''')= @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end
  AND info ->> ''key1'' = ''CONV_TREAT_ITEM_SEND_IN'' 
 ),
 dialysis_send AS ( -- 透析发送
 SELECT
  info ->> ''key2'' AS key2,
  COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS 
 VALUE
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
 WHERE
  facility_cd = @facilityCd
  AND is_del = ''0'' 
		-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
		AND COALESCE(info->>''key0'','''')= @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end
  AND info ->> ''key1'' = ''DIALYSIS_SEND'' 
 ),
 int_set_medicine_resolve AS ( -- 薬剤分類が「透析液」のもの。セット薬剤の扱いについては、連携設定に従う。

 SELECT
  info ->> ''key2'' AS key2,
  COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS 
 VALUE
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
 WHERE
  facility_cd = @facilityCd

  AND is_del = ''0'' 
		-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
		AND COALESCE(info->>''key0'','''')= @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end
  AND info ->> ''key1'' = ''IND_SET_MEDICINE_RESOLVE'' 
 ),
 DIALYSIS_ITEM_PROCEDURE_TAG AS( -- 連携設定「手技あり１～１０－手技コード」 
  SELECT
   info ->> ''key2'' AS key2,
   COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS VALUE 
  FROM
   mst_coop_ini AS ini
   CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
  WHERE
   facility_cd = @facilityCd

   AND is_del = ''0'' 
	 	-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
		AND COALESCE(info->>''key0'','''')= @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end
   AND info ->> ''key1'' = ''DIALYSIS_ITEM_PROCEDURE_TAG'' 
 ),
 RST_MEDI_INFO AS (-- 透析実績投薬
 SELECT
  medi ->> ''cd'' AS medi_cd 
 FROM
  ord_main AS ord
  CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi 
 WHERE
  ord.ord_no = @ordNo
 ),
 bed_conv as(	 	
	SELECT
	0 AS order_no,
		to_number(COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ), ''9999999999'') AS bed_conv
	 FROM
		mst_coop_ini AS ini
   CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
	 WHERE
    facility_cd = @facilityCd

    AND is_del = ''0'' 
			-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
		AND COALESCE(info->>''key0'','''')= @key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end
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
		( SELECT regexp_split_to_table( @dial_diff_cd

, '','' ) AS details ) AS T
 ),
 do_order_data_equip_from AS ( --施設設定106设置获取
SELECT ROW_NUMBER () OVER () AS no2, TO_NUMBER(datt.a1  :: text, ''999999999999'') AS ora
FROM (SELECT TO_NUMBER((unnest(string_to_array((
SELECT mst_f.value AS rtt
  FROM mst_facility_setting AS mst_f 
  WHERE mst_f.facility_setting_no = ''3006'' AND mst_f.facility_cd = @facilityCd
),'',''))), ''999999999999'') AS a1) AS datt
),
do_mstmeq_cd AS (--医療材料マスタ表示顺
SELECT index_no AS meq_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_code, order_cd ->> ''name'' AS meq_code_name
FROM mst_selector
    CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd

AND master_physical_name = ''mst_equipment'' 
)
, do_mstmeq_class_cd AS (--医療材料分類マスタ表示顺
SELECT index_no AS meq_class_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS meq_class_code, order_cd ->> ''name'' AS meq_class_code_name
FROM mst_selector
    CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd

AND master_physical_name = ''mst_equipment_class'' 
),
 do_order_data_from AS (--施設設定107设置获取
SELECT ROW_NUMBER () OVER () AS no2, datt.a1
FROM (SELECT TO_NUMBER((unnest(string_to_array((
SELECT mst_f.value AS rtt
  FROM mst_facility_setting AS mst_f
  WHERE mst_f.facility_setting_no = ''3007'' AND mst_f.facility_cd = @facilityCd

),'',''))), ''999999999999'') AS a1) AS datt
)
, do_mstmedi_cd AS (--薬剤マスタ表示顺
SELECT index_no AS medi_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_code, order_cd ->> ''name'' AS medi_code_name
FROM mst_selector
     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd

AND master_physical_name = ''mst_medicine'' 
)
, do_mstmedi_class_cd AS (--薬剤分類マスタ表示顺
SELECT index_no AS medi_class_code_order, TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_class_code, order_cd ->> ''name'' AS medi_class_code_name
FROM mst_selector
     CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(order_cd, index_no)
WHERE facility_cd = @facilityCd

AND master_physical_name = ''mst_medicine_class'' 
)
, data_middle_all AS (
SELECT
 all_cost.* 
FROM
 (
  (--  ベッドＮＯ
  SELECT
     ''実績詳細'' AS detail_id,
     ''VE1'' AS sbt_key,
	    CASE (SELECT bed_conv FROM bed_conv)
					WHEN 1 THEN
						( ''V'' || lpad( reverse(SUBSTRING(reverse(mbd.in_hospital_cd_1),1,7)) :: TEXT, 7, ''0'' ) )
					WHEN 2 then 
						( ''V'' || lpad( reverse(SUBSTRING(reverse(mbd.in_hospital_cd_2),1,7)) :: TEXT, 7, ''0'' ) )
					ELSE
						''V9999999'' 
				END AS e01,--項目コード
      COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BED_NO_ATTR'' ), '''' ) AS e02,-- 項目属性
      COALESCE ( SUBSTRING ( mbd.bed_name, 1, 50 ), '''' ) AS e03,--項目名称
      ''0000000.000'' AS e04,--数量
      ''0'' AS e05,-- 選択単位フラグ
      '''' AS e06,-- 単位コード
      '''' AS e07,-- 単位名称
      '''' AS e08,
      '''' AS e09,
	    '''' AS e10,
       COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BED_NO_TAG'' ), '''' ) AS e11,-- タグ名称
      ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_BED_NO'' ), '''' ) ) AS sortTag ,
			'''' as sorttag1,
			'''' as sorttag2
  FROM
   ord_main ord
   LEFT OUTER JOIN mst_bed AS mbd ON mbd.bed_cd = ord.rst_bed_cd 
  WHERE
   ord.ord_no = @ordNo

  ) UNION ALL
  (--  浄化方法
		SELECT
    ''実績詳細'' AS detail_id, 
		''VC1'' AS sbt_key,
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
    COALESCE((SELECT value FROM dialysis_item_send WHERE key2 = ''ITEM_TREAT_ATTR''), '''') AS e02, 
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
		'''' AS e08,
    '''' AS e09,
    '''' AS e10,
    --タグ名称
    COALESCE((SELECT value FROM dialysis_item_send WHERE key2 = ''ITEM_TREAT_TAG''), '''') AS e11, 
    --出力順
    COALESCE((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_TREAT''), '''') AS sortTag,
		'''' as sorttag1,
		'''' as sorttag2
FROM
    ord_main ord
LEFT OUTER JOIN
    mst_treatment mtt
ON
    mtt.treatment_cd = ord.rst_treatment_cd
WHERE
    ord.ord_no = @ordNo

  ) UNION ALL
  (-- 希望開始時刻
       SELECT
        ''実績詳細'' AS detail_id,
        ''VA6'' AS sbt_key,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_START_DATE_TIME_CODE'' ), '''' ) AS e01,-- 項目コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_START_DATE_TIME_ATTR'' ), '''' ) AS e02,-- 項目属性
        SUBSTRING ( to_char( rst_start_date, ''HH24:MI'' ), 1, 25 ) AS e03,-- 項目名称
        ''0000000.000'' AS e04,-- 数量
        ''0'' AS e05,--選択単位フラグ
        '''' AS e06,-- 単位コード
        '''' AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        '''' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_START_DATE_TIME_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_START_DATE_TIME'' ), '''' ) ) AS sortTag ,
			 '''' as sorttag1,
			'''' as sorttag2
       FROM
        ord_main ord 
       WHERE
        ord.ord_no = @ordNo

       ) UNION ALL
       (-- 希望終了時刻
       SELECT
        ''実績詳細'' AS detail_id,
        ''VA7'' AS sbt_key,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_END_DATE_TIME_CODE'' ), '''' ) AS e01,--項目コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_END_DATE_TIME_ATTR'' ), '''' ) AS e02,-- 項目属性
        to_char( rst_end_date, ''HH24:MI'' ) AS e03,-- 項目名称
        ''0000000.000'' AS e04,-- 数量
        ''0'' AS e05,--選択単位フラグ
        '''' AS e06,-- 単位コード
        '''' AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        '''' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_END_DATE_TIME_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_END_DATE_TIME'' ), '''' ) ) AS sortTag ,
						'''' as sorttag1,
			'''' as sorttag2
       FROM
        ord_main ord 
       WHERE
        ord.ord_no = @ordNo

       ) UNION ALL
       (-- 予定所要時間
       SELECT
        ''実績詳細'' AS detail_id,
        ''VA8'' AS sbt_key,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SCHE_TIME_CODE'' ), '''' ) AS e01,-- 項目コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SCHE_TIME_ATTR'' ), '''' ) AS e02,-- 項目属性
        to_char( rst_end_date - rst_start_date, ''HH24:MI'' ) AS e03,-- 項目名称
        ''0000000.000'' AS e04,--数量
        ''0'' AS e05,-- 選択単位フラグ
        '''' AS e06,-- 単位コード
        '''' AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        '''' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SCHE_TIME_TAG'' ), '''' ) AS e11,--タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_SCHE_TIME'' ), '''' ) ) AS sortTag, 
      '''' as sorttag1,
			'''' as sorttag2
       FROM
        ord_main ord 
       WHERE
        ord.ord_no = @ordNo

       ) UNION ALL
       (-- 透析前体重
       SELECT
        ''実績詳細'' AS detail_id,
        ''VF2'' AS sbt_key,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BEFORE_WEIGHT_CODE'' ), '''' ) AS e01,-- 項目コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BEFORE_WEIGHT_ATTR'' ), '''' ) AS e02,-- 項目属性
        COALESCE (  to_char( ( ord.rst_weight_info ->> ''weight_before_date'' ) :: TIMESTAMP, ''YYYY/MM/DD'' ), '''' ) AS e03,--項目名称
        COALESCE ( to_char( TO_NUMBER( ord.rst_weight_info ->> ''weight_before'', ''999999999.999'' ), ''FM0999999.990'' ), '''' ) AS e04,-- 数量
        ''1'' AS e05,--  選択単位フラグ
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BEFORE_WEIGHT_UNIT'' ), '''' ) AS e06,-- 単位コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BEFORE_WEIGHT_UNIT'' ), '''' ) AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        '''' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BEFORE_WEIGHT_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_BEFORE_WEIGHT'' ), '''' ) ) AS sortTag ,
			'''' as sorttag1,
			'''' as sorttag2
       FROM
        ord_main ord 
       WHERE
        ord.ord_no = @ordNo

       ) UNION ALL
       (-- 透析後体重
       SELECT
        ''実績詳細'' AS detail_id,
        ''VF9'' AS sbt_key,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_AFTER_WEIGHT_CODE'' ), '''' ) AS e01,-- 項目コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_AFTER_WEIGHT_ATTR'' ), '''' ) AS e02,-- 項目属性
        COALESCE ( to_char( ( ord.rst_weight_info ->> ''weight_after_date'' ) :: TIMESTAMP, ''YYYY/MM/DD'' ), '''' ) AS e03,--項目名称
        COALESCE ( to_char( TO_NUMBER( ord.rst_weight_info ->> ''weight_after'', ''999999999.999'' ), ''FM0999999.990'' ), '''' ) AS e04,--  数量
        ''1'' AS e05,--   選択単位フラグ
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_AFTER_WEIGHT_UNIT'' ), '''' ) AS e06,-- 単位コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_AFTER_WEIGHT_UNIT'' ), '''' ) AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        '''' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_AFTER_WEIGHT_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_AFTER_WEIGHT'' ), '''' ) ) AS sortTag ,
					'''' as sorttag1,
			'''' as sorttag2
       FROM
        ord_main ord 
       WHERE
        ord.ord_no = @ordNo

       ) UNION ALL
       (-- 目標体重
					SELECT
						''実績詳細'' AS detail_id,
						''VF1'' AS sbt_key,
						COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_TARGET_WEIGHT_CODE'' ), '''' ) AS e01,-- 項目コード
						COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_TARGET_WEIGHT_ATTR'' ), '''' ) AS e02,-- 項目属性
						COALESCE ( to_char( ord.treat_date :: TIMESTAMP, ''YYYY/MM/DD'' ), '''' ) AS e03,-- 項目名称
	          COALESCE ( to_char( TO_NUMBER(  ord.rst_cond_info -> ''3'' ->> ''value'', ''999999999.999'' ), ''FM0999999.990'' ), '''' ) AS e04,--  数量
						''1'' AS e05,-- 選択単位フラグ
						COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_TARGET_WEIGHT_UNIT'' ), '''' ) AS e06,-- 単位コード
						COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_TARGET_WEIGHT_UNIT'' ), '''' ) AS e07,-- 単位名称
						'''' AS e08,
						'''' AS e09,
						'''' AS e10,
						COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_TARGET_WEIGHT_TAG'' ), '''' ) AS e11,--  タグ名称
						( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_TARGET_WEIGHT'' ), '''' ) ) AS sortTag,
					'''' as sorttag1,
			'''' as sorttag2
					FROM
						ord_main ord 
					WHERE
						ord.ord_no = @ordNo

       ) UNION ALL
       (-- ドライウェイト
       SELECT
        ''実績詳細'' AS detail_id,
        ''VF3'' AS sbt_key,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DRY_WEIGHT_CODE'' ), '''' ) AS e01,-- 項目コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DRY_WEIGHT_ATTR'' ), '''' ) AS e02,-- 項目属性
        COALESCE ( to_char( ord.rst_start_date, ''YYYY/MM/DD'' ), '''' ) AS e03,--項目名称
        COALESCE ( to_char( ord.rst_dw, ''FM0999999.990'' ), '''' ) AS e04,-- 数量
        ''1'' AS e05,-- 選択単位フラグ
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DRY_WEIGHT_UNIT'' ), '''' ) AS e06,-- 単位コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DRY_WEIGHT_UNIT'' ), '''' ) AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        '''' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DRY_WEIGHT_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_DRY_WEIGHT'' ), '''' ) ) AS sortTag ,
					'''' as sorttag1,
			'''' as sorttag2
       FROM
        ord_main ord 
       WHERE
        ord.ord_no = @ordNo

       ) UNION ALL
       (--  透析導入日
							 SELECT
						''実績詳細'' AS detail_id,--項目コード
						''VS3'' AS sbt_key,
						COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DATE_INTRODUCED_CODE'' ), '''' ) AS e01,-- 項目コード
						COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DATE_INTRODUCED_ATTR'' ), '''' ) AS e02,-- 項目属性 
						COALESCE ( to_char( ( patu.iov ->> ''period_start'' ) :: TIMESTAMP, ''YYYY/MM/DD'' ), '''' ) AS e03,-- 項目名称
						''0000000.000'' AS e04,-- 数量
						''0'' AS e05,-- 選択単位フラグ
						'''' AS e06,-- 単位コード
						'''' AS e07,-- 単位名称
						'''' AS e08,
						'''' AS e09,
						'''' AS e10,
						COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DATE_INTRODUCED_TAG'' ), '''' ) AS e11,--タグ名称
						NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_DATE_INTRODUCED'' ), '''' ) AS sortTag,
						'''' as sorttag1,
			'''' as sorttag2
					FROM
						ord_main ord
						LEFT JOIN (
						SELECT
							* 
						FROM
							(
								(
								SELECT
									1 AS NO,
									pat_id,
									iov 
								FROM
									pat_unique
									CROSS JOIN LATERAL jsonb_array_elements ( in_out_visit_history_info ) iov 
								WHERE
									pat_id = @patId

									AND iov ->> ''move_in_out'' = ''1'' 
									AND iov ->> ''period_start'' IS NOT NULL 
									AND iov ->> ''from_facility'' IS NOT NULL 
								) UNION ALL
								(
								SELECT
									2 AS NO,
									pat_id,
									iov 
								FROM
									pat_unique
									CROSS JOIN LATERAL jsonb_array_elements ( in_out_visit_history_info ) iov 
								WHERE
									pat_id = @patId

									AND iov ->> ''move_in_out'' = ''1'' 
									AND iov ->> ''period_start'' IS NOT NULL 
									AND iov ->> ''from_facility'' IS NULL 
								) 
							) DATA 
						ORDER BY
							DATA.NO,
							DATA.iov ->> ''period_start'' 
							LIMIT 1 
						) AS patu ON patu.pat_id = ord.pat_id 
					WHERE
						ord.ord_no = @ordNo

						AND patu IS NOT NULL
       ) UNION ALL
       (-- 障害者加算タイトル
        SELECT
        ''実績詳細'' AS detail_id,
        ''VAB'' AS sbt_key,
        COALESCE ((SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ADD_TITLE_CODE'' ),'''') AS e01,--コード
        COALESCE ((SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ADD_TITLE_ATTR'' ),'''') AS e02,
        COALESCE ((SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ADD_TITLE_NAME'' ),'''') AS e03,--名
        ''0000000.000'' AS e04,
        ''0''AS e05,
        '''' AS e06,
        '''' AS e07,
        '''' AS e08,
        '''' AS e09,
        '''' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ADD_TITLE_TAG'' ), '''' ) AS e11,
        NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_DISABLED_ADD'' ), '''' ) AS sortTag ,
					'''' as sorttag1,
			'''' as sorttag2
       WHERE
        ((SELECT VALUE FROM dialysis_send WHERE key2 = ''ADD_TITLE_SEND_FLG'' ) = ''1'') AND  ''925,182''
 <>
 ''''
       ) UNION ALL
       (--  障害者加算:患者基本情報から取得
        SELECT
        ''実績詳細'' AS detail_id,
        ''VAB'' AS sbt_key,
        COALESCE (nullif(mdd.in_hospital_cd_1,'''') ,( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DISABLED_ADD_CODE'' ), '''' ) AS e01,--コード
        COALESCE ( mdd.in_hospital_cd_2, ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DISABLED_ADD_ATTR'' ), '''' ) AS e02,
        COALESCE ( SUBSTRING ( mdd.dialysis_difficulty_name, 1, 25 ), '''' ) AS e03,--名
        ''0000000.000'' AS e04,
        ''0'' AS e05,
        '''' AS e06,
        '''' AS e07,
        '''' AS e08,
        '''' AS e09, 
        '''' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DISABLED_ADD_TAG'' ), '''' ) AS e11,
        NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_DISABLED_ADD'' ), '''' )||''-''||row_no AS sortTag ,
					'''' as sorttag1,
			'''' as sorttag2
        FROM
        mst_dialysis_difficulty mdd,
				dialysis_difficulty_info
				WHERE
					dialysis_difficulty_cd :: TEXT IN (dialysis_difficulty_info.details)
       )  UNION ALL
       (-- VA
       SELECT
        ''実績詳細'' AS detail_id,
        ''VN1'' AS sbt_key,
        COALESCE ( mva.in_hospital_cd_1, '''' ) AS e01,-- 項目コード
        COALESCE ( NULLIF ( mva.in_hospital_cd_2, '''' ), COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SHUNT_PART_ATTR'' ), '''' ) ) AS e02,-- 項目属性
        COALESCE ( SUBSTRING ( mva.va_name, 1, 25 ), '''' ) AS e03,--項目名称
        ''0000000.000'' AS e04,-- 数量
        ''0'' AS e05,-- 選択単位フラグ
        '''' AS e06,--  単位コード
        '''' AS e07,--  単位名称
        '''' AS e08,
        '''' AS e09,
        ''12'' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SHUNT_PART_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_SHUNT_PART'' ), '''' ) ) AS sortTag ,
					'''' as sorttag1,
			'''' as sorttag2
       FROM
        ord_main ord
        LEFT OUTER JOIN mst_va AS mva ON mva.va_cd = TO_NUMBER( ord.rst_cond_info -> ''2'' ->> ''value'', ''999999999999'' ) 
       WHERE
        ord.ord_no = @ordNo

       ) UNION ALL
       (-- 透析器
       SELECT
        ''実績詳細'' AS detail_id,
        ''VH1'' AS sbt_key,
        COALESCE ( mdz.in_hospital_cd_1, '''' ) AS e01,-- 項目コード
        COALESCE ( NULLIF ( mdz.in_hospital_cd_2, '''' ), COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DIAL_INST_ATTR'' ), '''' ) ) AS e02,-- 項目属性
        COALESCE ( SUBSTRING ( mdz.model_number, 1, 25 ), '''' ) AS e03,-- 項目名称
        ''0000001.000'' AS e04,--  数量
        ''1'' AS e05,-- 選択単位フラグ
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DIAL_INST_UNIT'' ), '''' ) AS e06,-- 単位コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DIAL_INST_UNIT'' ), '''' ) AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        ''14'' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DIAL_INST_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_DIAL_INST'' ), '''' ) ) AS sortTag,
				'''' as sorttag1,
			'''' as sorttag2
       FROM
        ord_main ord
        LEFT OUTER JOIN mst_dialyzer AS mdz ON mdz.dialyzer_cd = TO_NUMBER( ord.rst_cond_info -> ''5'' ->> ''value'', ''999999999999'' ) 
       WHERE
        ord.ord_no = @ordNo

       ) UNION ALL
       (-- 吸着器
       SELECT
        ''実績詳細'' AS detail_id,
        ''VH2'' AS sbt_key,
        COALESCE ( meq.in_hospital_cd_1, '''' ) AS e01,-- 項目コード
        COALESCE ( meq.in_hospital_cd_2, ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_ADSORPTION_INST_ATTR'' ) ) AS e02,-- 項目属性
        COALESCE ( SUBSTRING ( meq.equipment_name, 1, 25 ), '''' ) AS e03,--  項目名称
        ''0000001.000'' AS e04,-- 数量
       CASE
         WHEN meq.unit IS NULL THEN
         ''0'' 
         WHEN meq.unit = '''' THEN
         ''0'' ELSE''1'' 
        END AS e05,--  選択単位フラグ
        COALESCE ( meq.unit, '''' ) AS e06,-- 単位コード
        COALESCE ( meq.unit, '''' ) AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        ''15'' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_ADSORPTION_INST_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_FILM'' ), '''' ) ) AS sortTag ,
					'''' as sorttag1,
			'''' as sorttag2
       FROM
        ord_main ord
        LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''6'' ->> ''value'', ''999999999999'' ) 
       WHERE
        ord.ord_no = @ordNo

       ) UNION ALL
       (-- 1次膜
       SELECT
        ''実績詳細'' AS detail_id,
        ''VH3'' AS sbt_key,
        COALESCE ( meq.in_hospital_cd_1, '''' ) AS e01,-- 項目コード
        COALESCE ( meq.in_hospital_cd_2, COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_FIRST_FILM_ATTR'' ), '''' ) ) AS e02,-- 項目属性
        COALESCE ( SUBSTRING ( meq.equipment_name, 1, 25 ), '''' ) AS e03,-- 項目名称
        ''0000001.000'' AS e04,-- 数量
       CASE
         
         WHEN meq.unit IS NULL THEN
         ''0'' 
         WHEN meq.unit = '''' THEN
         ''0'' ELSE''1'' 
        END AS e05,-- 選択単位フラグ
        COALESCE ( meq.unit, '''' ) AS e06,-- 単位コード
        COALESCE ( meq.unit, '''' ) AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        ''16'' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_FIRST_FILM_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_FIRST_FILM'' ), '''' ) ) AS sortTag,
					'''' as sorttag1,
			'''' as sorttag2
       FROM
        ord_main ord
        LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''7'' ->> ''value'', ''999999999999'' ) 
       WHERE
        ord.ord_no = @ordNo

       ) UNION ALL
       (-- 2次膜
       SELECT
        ''実績詳細'' AS detail_id,
        ''VH3'' AS sbt_key,
        COALESCE ( meq.in_hospital_cd_1, '''' ) AS e01,-- 項目コード
        COALESCE ( NULLIF ( meq.in_hospital_cd_2, '''' ), COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SECOND_FILM_ATTR'' ), '''' ) ) AS e02,-- 項目属性
        COALESCE ( SUBSTRING ( meq.equipment_name, 1, 25 ), '''' ) AS e03,-- 項目名称
        ''0000001.000'' AS e04,--数量
       CASE
         
         WHEN meq.unit IS NULL THEN
         ''0'' 
         WHEN meq.unit = '''' THEN
         ''0'' ELSE''1'' 
        END AS e05,-- 選択単位フラグ
        COALESCE ( meq.unit, '''' ) AS e06,-- 単位コード
        COALESCE ( meq.unit, '''' ) AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        ''17'' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SECOND_FILM_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_SECOND_FILM'' ), '''' ) ) AS sortTag ,
					'''' as sorttag1,
			'''' as sorttag2
       FROM
        ord_main ord
        LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''8'' ->> ''value'', ''999999999999'' ) 
       WHERE
        ord.ord_no = @ordNo

       ) UNION ALL
             (-- A針情報
			 SELECT
    ''実績詳細'' AS detail_id, 
		''VR1'' AS sbt_key,
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM dialysis_item_send WHERE key2 = ''ITEM_EQUIP_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE ( SUBSTRING ( meq.equipment_name, 1, 25 ), '''' ) AS e03,
    --数量
    ''0000001.000'' AS e04, 
    --選択単位フラグ
    CASE WHEN meq.unit IS NULL OR meq.unit = ''''
    THEN ''0'' ELSE ''1'' END AS e05, 
    --単位コード
    COALESCE(meq.unit, '''') AS e06, 
    --単位名称
    COALESCE(meq.unit, '''') AS e07, 
     '''' AS e08,
     '''' AS e09,
     ''18'' AS e10,
     COALESCE ( meqc.class_name, '''' ) AS e11,--  タグ名称
     ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_EQUIP'' ), '''' ) ) AS sortTag ,
		 ''1'' as sorttag1,
			''18'' as sorttag2
FROM
    ord_main ord
LEFT OUTER JOIN
    mst_equipment as meq
ON
    meq.equipment_cd = TO_NUMBER(ord.rst_cond_info->''9''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_equipment_class meqc
ON
    meq.class_cd = meqc.class_cd
WHERE
    ord.ord_no = @ordNo

 AND
    ord.rst_cond_info->''9''->>''value'' IS NOT NULL
       ) UNION ALL 
			 (
			 SELECT
    --V針情報
    ''実績詳細'' AS detail_id, 
		''VR1'' AS sbt_key,
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM dialysis_item_send WHERE key2 = ''ITEM_EQUIP_ATTR''), '''')) AS e02, 
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
     '''' AS e08,
     '''' AS e09,
     ''18'' AS e10,
     COALESCE ( meqc.class_name, '''' ) AS e11,--  タグ名称
     ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_EQUIP'' ), '''' ) ) AS sortTag,
			''2'' as sorttag1,
			''18'' as sorttag2
FROM
    ord_main ord
LEFT OUTER JOIN
    mst_equipment as meq
ON
    meq.equipment_cd = TO_NUMBER(ord.rst_cond_info->''10''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_equipment_class meqc
ON
    meq.class_cd = meqc.class_cd
WHERE
    ord.ord_no = @ordNo

 AND
    ord.rst_cond_info->''10''->>''value'' IS NOT NULL	 
			 )
			 UNION ALL
       (-- SN針情報
     SELECT
    --SN針情報
    ''実績詳細'' AS detail_id, 
		''VR1'' AS sbt_key,
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM dialysis_item_send WHERE key2 = ''ITEM_EQUIP_ATTR''), '''')) AS e02, 
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
     '''' AS e08,
     '''' AS e09,
     ''18'' AS e10,
     COALESCE ( meqc.class_name, '''' ) AS e11,--  タグ名称
     ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_EQUIP'' ), '''' ) ) AS sortTag,
			''3'' as sorttag1,
			''18'' as sorttag2
FROM
    ord_main ord
LEFT OUTER JOIN
    mst_equipment as meq
ON
    meq.equipment_cd = TO_NUMBER(ord.rst_cond_info->''11''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_equipment_class meqc
ON
    meq.class_cd = meqc.class_cd
WHERE
    ord.ord_no = @ordNo

 AND
    ord.rst_cond_info->''11''->>''value'' IS NOT NULL
       ) UNION ALL
       (-- 血液回路
      SELECT
    --血液回路情報
    ''実績詳細'' AS detail_id, 
		''VR1'' AS sbt_key,
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM dialysis_item_send WHERE key2 = ''ITEM_EQUIP_ATTR''), '''')) AS e02, 
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
     '''' AS e08,
     '''' AS e09,
     ''18'' AS e10,
     COALESCE ( meqc.class_name, '''' ) AS e11,--  タグ名称
     ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_EQUIP'' ), '''' ) ) AS sortTag ,
		 	''4'' as sorttag1,
			''18'' as sorttag2
FROM
    ord_main ord
LEFT OUTER JOIN
    mst_equipment meq
ON
    meq.equipment_cd = TO_NUMBER(ord.rst_cond_info->''13''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_equipment_class meqc
ON
    meq.class_cd = meqc.class_cd
WHERE
    ord.ord_no = @ordNo

 AND ord.rst_cond_info->''13''->>''value'' IS NOT NULL
       ) UNION ALL
			 (
 SELECT
    --医療材料情報
     ''実績詳細'' AS detail_id, 
		 	''VR1'' AS sbt_key,
     --項目コード
     COALESCE(meq.in_hospital_cd_1, '''') AS e01, 
     --項目属性
     COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM dialysis_item_send WHERE key2 = ''ITEM_EQUIP_ATTR''), '''')) AS e02, 
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
      '''' AS e08,
      '''' AS e09,
     ''18'' AS e10,
     COALESCE ( meqc.class_name, '''' ) AS e11,--  タグ名称
     ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_EQUIP'' ), '''' ) ) AS sortTag ,
		 	'''' as sorttag1,
			'''' as sorttag2
 FROM
     ord_main ord
     cross join lateral json_array_elements (ord.rst_equip_info :: json) equip

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
			 )UNION ALL
       (-- 透析液
       SELECT
        ''実績詳細'' AS detail_id,
        ''VI1'' AS sbt_key,
        COALESCE ( mmd.in_hospital_cd_1, '''' ) AS e01,-- 項目コード
        COALESCE ( mmd.in_hospital_cd_2, ( COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_ATTR'' ), '''' ) ) ) AS e02,--項目属性
        COALESCE ( SUBSTRING ( mmd.medicine_name, 1, 25 ), '''' ) e03,-- 項目名称
CASE
      WHEN ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''0'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''0'') OR
           ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''0'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''2'') OR
           ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''0'') OR
           ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''2'') OR
					 ((SELECT device_mode FROM device) NOT IN (7, 8, 10))
        THEN
          TO_CHAR(TO_NUMBER(COALESCE(ord.rst_cond_info->''17''->>''value'',''0''), ''999999999.999''), ''FM0099999.990'')
      WHEN ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''0'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''1'') OR
           ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''1'') AND
					 ((SELECT device_mode FROM device) IN (7, 8, 10))
        THEN
          TO_CHAR(TO_NUMBER(COALESCE(ord.rst_cond_info->''17''->>''value'',''0''), ''999999999.999'') + TO_NUMBER(COALESCE(ord.rst_cond_info->''22''->>''value'',''0''), ''9999999.999''), ''FM0099999.990'')
      ELSE ''0000000.000''
			END AS e04,
        ''1''  AS e05,-- 選択単位フラグ
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_UNIT'' ), '''' ) e06,-- 単位コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_UNIT'' ), '''' ) e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        ''23'' AS e10,
        ( NULLIF ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_TAG'' ), '''' ) ) AS e11,--タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_SOLUTION'' ), '''' ) ) AS sortTag ,
				'''' as sorttag1,
			'''' as sorttag2
       FROM
        ord_main ord
        LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''15'' ->> ''value'', ''999999999999'' )
        LEFT OUTER JOIN mst_medicine_class AS mmc ON mmc.class_cd = mmd.class_cd 
       WHERE
        ord.ord_no = @ordNo

        AND ( SELECT VALUE FROM int_set_medicine_resolve WHERE key2 = ''SOLUTION_RESOLVE_MODE'' ) = ''0'' 
       ) UNION ALL
       (-- 置換液（補液）
       SELECT
        ''実績詳細'' AS detail_id,
        ''VI1'' AS sbt_key,
        COALESCE ( mmd.in_hospital_cd_1, '''' ) AS e01,-- 項目コード
        COALESCE ( mmd.in_hospital_cd_2, ( COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_REPLACE_ATTR'' ), '''' ) ) ) AS e02,-- 項目属性
        COALESCE ( SUBSTRING ( mmd.medicine_name, 1, 25 ), '''' ) e03,-- 項目名称
        to_char( TO_NUMBER( ord.rst_cond_info -> ''22'' ->> ''value'', ''999999999.999'' ), ''FM0000099.990'' ) AS e04,-- 数量
				''1'' e05,-- 選択単位フラグ
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_REPLACE_UNIT'' ), '''' ) e06,-- 単位コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_REPLACE_UNIT'' ), '''' ) e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        ''23'' AS e10,
        ( NULLIF ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_REPLACE_TAG'' ), '''' ) ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_REPLACE'' ), '''' ) ) AS sortTag ,
					'''' as sorttag1,
			'''' as sorttag2
       FROM
        ord_main ord
        LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''19'' ->> ''value'', ''999999999999'' )
        LEFT OUTER JOIN mst_medicine_class AS mmc ON mmc.class_cd = mmd.class_cd 
       WHERE
        ord.ord_no = @ordNo

        AND (((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1''
				AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''0''
			  AND ((SELECT device_mode FROM device) IN (7, 8, 10)))
		    OR ((SELECT device_mode FROM device) NOT IN (7, 8, 10)))
       ) UNION ALL
       (-- 抗凝固剤初回
       SELECT
        ''実績詳細'' AS detail_id,
        ''VGX'' AS sbt_key,
        ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE mmd.in_hospital_cd_1 END ) AS e01,-- 項目コード
        COALESCE (
         ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END ),
         ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_KOU_COAG_ONESHOT_ATTR'' ) 
        ) AS e02,-- 項目属性
        COALESCE (
        SUBSTRING ( ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE mmd.medicine_name END ), 1, 25 ),
    '''' 
   ) AS e03,-- 項目名称
   to_char( TO_NUMBER( COALESCE ( ord.rst_cond_info -> ''26'' ->> ''value'', ''0'' ), ''999999999.999'' ), ''FM0099999.990'' ) AS e04,-- 数量
   (
    COALESCE (
    CASE
      WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) IS NULL THEN
       ''0'' 
      WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) = '''' THEN
    ''0'' ELSE NULL 
   END,
   ( CASE ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_KOU_COAG_ONESHOT_UNIT_SEL'' ) WHEN ''2'' THEN ''2'' ELSE''1'' END ) 
    ) 
  ) AS e05,-- 選択単位フラグ
  ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) AS e06,-- 単位コード
  ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) AS e07,-- 単位名称
  '''' AS e08,
  '''' AS e09,
  ''24'' AS e10,
  ( NULLIF ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_KOU_COAG_ONESHOT_TAG'' ), '''' ) ) AS e11,-- タグ名称
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_KOU_COAG_ONESHOT'' ), '''' ) ) AS sortTag ,
		'''' as sorttag1,
			'''' as sorttag2
 FROM
  ord_main ord
  LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''999999999999'' ) 
 WHERE
  ord.ord_no = @ordNo

  AND ( SELECT VALUE FROM int_set_medicine_resolve WHERE key2 = ''KOU_COAG_RESOLVE_MODE'' ) = ''0'' 
 ) UNION ALL
 (-- 抗凝固剤持続
 SELECT
  ''実績詳細'' AS detail_id,
  ''VGY'' AS sbt_key,
  ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE mmd.in_hospital_cd_1 END ) AS e01,-- 項目コード
  COALESCE (
   ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END ),
   ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_KOU_COAG_ATTR'' ) 
  ) AS e02,-- 項目属性
  COALESCE(SUBSTRING ( ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE mmd.medicine_name END ), 1, 25 ),'''') AS e03,-- 項目名称
 to_char( TO_NUMBER( COALESCE ( ord.rst_cond_info -> ''27'' ->> ''value'', ''0'' ), ''999999999.999'' ), ''FM0099999.990'' ) AS e04,--e4
 (
  COALESCE (
  CASE
   WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) IS NULL THEN ''0'' 
    WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) = '''' THEN ''0'' 
 END,
 ( CASE ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_KOU_COAG_UNIT_SEL'' ) WHEN ''2'' THEN ''2'' ELSE''1'' END ) 
 ) 
 ) AS e05,-- 選択単位フラグ
 (
  COALESCE (
  CASE
    
    WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) IS NULL THEN ''''
    WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) = '''' THEN '''' 
 END,
 (
 CASE
   ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ADD_UNIT_FLG'' ) 
   WHEN ''1'' THEN
  ( ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) || ''/h'' ) ELSE ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) 
 END 
 ) 
 ) 
 ) AS e06,-- 単位コード
 (
  COALESCE (
  CASE
    WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) IS NULL THEN ''''
    WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) = '''' THEN ''''
 END,
 (
 CASE
   ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ADD_UNIT_FLG'' ) 
   WHEN ''1'' THEN
  ( ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) || ''/h'' ) ELSE ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) 
 END 
 ) 
 ) 
 ) AS e07,-- 単位名称
 '''' AS e08,
 '''' AS e09,
 ''25'' AS e10,
 ( NULLIF ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_KOU_COAG_TAG'' ), '''' ) ) AS e11,-- タグ名称
 ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_KOU_COAG'' ), '''' ) ) AS sortTag ,
 	'''' as sorttag1,
			'''' as sorttag2
FROM
 ord_main ord
 LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''999999999999'' )
 LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''999999999999'' ) 
WHERE
 ord.ord_no = @ordNo

 AND ( SELECT VALUE FROM int_set_medicine_resolve WHERE key2 = ''KOU_COAG_RESOLVE_MODE'' ) = ''0''   
 ) UNION ALL
 (-- 抗凝固剤TOTAL
 SELECT
  ''実績詳細'' AS detail_id,
  ''VGZ'' AS sbt_key,
  ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE mmd.in_hospital_cd_1 END ) AS e01,-- 項目コード
  COALESCE (
   ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END ),
   ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_KOU_COAG_TOTAL_ATTR'' ) 
  ) AS e2,-- 項目属性,
    COALESCE(SUBSTRING ( ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE mmd.medicine_name END ), 1, 25 ),'''')  AS e03,-- 項目名称
 to_char(
  TO_NUMBER( COALESCE ( ord.rst_cond_info -> ''26'' ->> ''value'', ''0'' ), ''999999999.999'' ) + TO_NUMBER( COALESCE ( ord.rst_cond_info -> ''28'' ->> ''value'', ''0'' ), ''999999999.999'' ),
  ''FM0999999.990'' 
 ) AS e04,-- 選択単位フラグ
 (
  COALESCE (
  CASE 
    WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) IS NULL THEN ''0'' 
    WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) = '''' THEN ''0''  
 END,
 ( CASE ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_KOU_COAG_TOTAL_UNIT_SEL'' ) WHEN ''2'' THEN ''2'' ELSE''1'' END ) ) 
 ) AS e05,-- 選択単位フラグ
 COALESCE ( ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ), '''' ) AS e06,-- 単位コード
 COALESCE ( ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ), '''' ) AS e07,-- 単位名称
 '''' AS e08,
 '''' AS e09,
 ''26'' AS e10,
 ( NULLIF ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_KOU_COAG_TOTAL_TAG'' ), '''' ) ) AS e11,-- タグ名称
 ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_KOU_COAG_TOTAL'' ), '''' ) ) AS sortTag ,
 	'''' as sorttag1,
			'''' as sorttag2
FROM
 ord_main ord
 LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''999999999999'' )
 LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''999999999999'' ) 
WHERE
 ord.ord_no = @ordNo

 AND ( SELECT VALUE FROM int_set_medicine_resolve WHERE key2 = ''KOU_COAG_RESOLVE_MODE'' ) = ''0'' 
 ) UNION ALL
 (--  血液流量
 SELECT
  ''実績詳細'' AS detail_id,
  ''VK3'' AS sbt_key,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BLOOD_AMT_CODE'' ), '''' ) AS e01,-- 項目コード
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BLOOD_AMT_ATTR'' ), '''' ) AS e02,-- 項目属性
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BLOOD_AMT_NAME'' ), '''' ) AS e03,-- 項目名称
  to_char( TO_NUMBER( ord.rst_cond_info -> ''14'' ->> ''value'', ''999999999999'' ), ''FM0000999.990'' ) AS e04,-- 数量
  ''1'' AS e05,-- 選択単位フラグ
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BLOOD_AMT_UNIT'' ), '''' ) AS e06,-- 単位コード
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BLOOD_AMT_UNIT'' ), '''' ) AS e07,-- 単位コード
  '''' AS e08,
  '''' AS e09,
  ''27'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BLOOD_AMT_TAG'' ), '''' ) AS e11,-- タグ名称
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_BLOOD_AMT'' ), '''' ) ) AS sortTag ,
'''' as sorttag1,
			'''' as sorttag2
 FROM
  ord_main ord 
 WHERE
  ord.ord_no = @ordNo

  AND TO_NUMBER( ord.rst_cond_info -> ''14'' ->> ''value'', ''999999999999'' ) > 1 
  AND ( SELECT VALUE FROM int_set_medicine_resolve WHERE key2 = ''SOLUTION_RESOLVE_MODE'' ) = ''0'' 
  
 )UNION ALL(-- 透析液流量
  SELECT
  ''実績詳細'' AS detail_id,
  ''VK4'' AS sbt_key,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_AMT_CODE'' ), '''' ) AS e01,--e1
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_AMT_ATTR'' ), '''' ) AS e02,--e2
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_AMT_NAME'' ), '''' ) AS e03,--e3
  to_char( TO_NUMBER( ord.rst_cond_info -> ''16'' ->> ''value'', ''999999999999'' ), ''FM0000999.990'' ) AS e04,--e4
  ''1'' AS e05,--e5
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_AMT_UNIT'' ), '''' ) AS e06,--e6
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_AMT_UNIT'' ), '''' ) AS e07,--e7
  '''' AS e08,
  '''' AS e09,
  ''28'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_AMT_TAG'' ), '''' ) AS e11,
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_SOLUTION_AMT'' ), '''' ) ) AS sortTag ,
'''' as sorttag1,
			'''' as sorttag2
 FROM
  ord_main ord 
 WHERE
  ord.ord_no = @ordNo

  AND TO_NUMBER( ord.rst_cond_info -> ''16'' ->> ''value'', ''999999999999'' ) >= 1 
 )
UNION ALL
 (-- 補液量
 SELECT
  ''実績詳細'' AS detail_id,
  ''VS2'' AS sbt_key,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_UP_LIQUID_CODE'' ), '''' ) AS e01,--項目コード
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_UP_LIQUID_ATTR'' ), '''' ) AS e02,--項目属性
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_UP_LIQUID_NAME'' ), '''' ) AS e03,--項目名称
  to_char( TO_NUMBER( ord.rst_cond_info -> ''20'' ->> ''value'', ''999999999999'' ), ''FM0000099.990'' ) AS e04,--数量
  ''1'' AS e05,-- 選択単位フラグ
	COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_UP_LIQUID_UNIT'' ), '''' ) AS e06,--単位コード
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_UP_LIQUID_UNIT'' ), '''' ) AS e07,--単位名称
  '''' AS e08,
  '''' AS e09,
  ''28'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_UP_LIQUID_TAG'' ), '''' ) AS e11,-- タグ名称
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_UP_LIQUID'' ), '''' ) ) AS sortTag ,
'''' as sorttag1,
'''' as sorttag2
 FROM
  ord_main ord 
 WHERE
  ord.ord_no = @ordNo

  AND TO_NUMBER( ord.rst_cond_info -> ''20'' ->> ''value'', ''999999999999'' ) > 1 
  AND (((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1''
  AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') in (''0'',''1'',''2'') 
  AND ((SELECT device_mode FROM device) IN (7, 8, 10)))
  OR ((SELECT device_mode FROM device) NOT IN (7, 8, 10)))
 ) 
 UNION ALL
 (-- レセプトメモ
 SELECT
  ''実績詳細'' AS detail_id,
  '''' AS sbt_key,
  COALESCE ( mdd.in_hospital_cd_1, '''' ) AS e01,--コード
  COALESCE ( mdd.in_hospital_cd_2, ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_RECORD_ATTR'' ), '''' ) AS e02,
  COALESCE ( SUBSTRING ( mdd.dialysis_difficulty_name, 1, 25 ), '''' ) AS e03,--名
  ''0000000.000'' AS e04,
  ''0'' AS e05,
  '''' AS e06,
  '''' AS e07,
  '''' AS e08,
  '''' AS e09,
  ''33'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_RECORD_TAG'' ), '''' ) AS e11,
  NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_RECORD'' ), '''' ) AS sortTag,
'''' as sorttag1,
			'''' as sorttag2
 FROM
  ord_main ord
  CROSS JOIN LATERAL json_array_elements ( ord.addition_info :: json ) addi
  LEFT OUTER JOIN mst_addition AS mad ON mad.addition_cd = to_number( addi ->> ''cd'', ''9999999999'' )
  CROSS JOIN LATERAL json_array_elements ( mad.addition_tar_cd :: json ) addtr
  LEFT OUTER JOIN mst_dialysis_difficulty AS mdd ON mdd.dialysis_difficulty_cd = to_number( addtr ->> ''cd'', ''9999999999'' ) 
 WHERE
  mad.addition_cond = ''2'' 
  AND addi ->> ''is_enable'' = ''1'' 
  AND mad.addition_class = ''2'' 
  AND ord.ord_no = @ordNo

  AND ( SELECT VALUE->>''memo_flg'' FROM sys_system_define WHERE ctl_no = 134 ) IS NOT NULL 
  AND ( SELECT VALUE->>''memo_flg'' FROM sys_system_define WHERE ctl_no = 134 ) <> ''0'' 
 )
 UNION ALL
 (-- 加算・管理料
 SELECT
  ''実績詳細'' AS detail_id,
  ''VAB'' AS sbt_key,
  COALESCE ( adt.in_hospital_cd_1, '''' ) AS e01,-- 項目コード
	COALESCE ( adt.in_hospital_cd_2, ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_RECEIPT_MEMO_ATTR'' ) ) AS e02,-- 項目属性
  COALESCE ( SUBSTRING ( adt.addition_name, 1, 25 ), '''' ) AS e03,-- 項目名称
  ''0000000.000'' AS e04,
  ''0'' AS e05,
  '''' AS e06,
  '''' AS e07,
  '''' AS e08,
  '''' AS e09,
  '''' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_RECEIPT_MEMO_TAG'' ), '''' ) AS e11,
  NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_DISABLED_ADD'' ), '''' ) AS sortTag ,
'''' as sorttag1,
			'''' as sorttag2
 FROM
  ord_main ord
	CROSS JOIN LATERAL json_array_elements ( ord.addition_info :: json ) addition
	LEFT OUTER JOIN mst_addition AS adt ON adt.addition_cd = TO_NUMBER( addition ->> ''cd'', ''999999999999'' )
 WHERE
  addition ->> ''is_enable'' = ''1''
  AND ord.ord_no = @ordNo

 ) 
 ) all_cost 
WHERE
  all_cost.sortTag IS NOT NULL and
  all_cost.e01 IS NOT NULL AND all_cost.e01 <> ''''
), 
data_oxygen as
	(--酸素吸入手技・酸素吸入量、の順序
	select detail_id,e01,e02,e03,e04,e05,e06,e07,e08,e09,e10,e11,sortTag,sortTag1,sortTag2,''酸素''::text as  aa from (
   (-- 酸素吸入手技
    SELECT
     ''実績詳細'' AS detail_id,
     ''VQ1'' AS sbt_key,
     COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_PROCEDURE_CODE'' ), '''' ) AS e01,-- 項目コード
     COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_PROCEDURE_ATTR'' ), '''' ) AS e02,-- 項目属性
     COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_PROCEDURE_NAME'' ), '''' ) AS e03,-- 項目名称
     ''0000000.000'' AS e04,-- 数量
     ''0'' AS e05,-- 選択単位フラグ
     '''' AS e06,-- 単位コード
     '''' AS e07,-- 単位名称
     '''' AS e08,
     '''' AS e09,
     ''31'' AS e10,
     COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_PROCEDURE_TAG'' ), '''' ) AS e11,-- タグ名称
   	COALESCE((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_OXYGEN''), '''') AS sortTag,
		'''' as sorttag1,
			'''' as sorttag2,
    ROW_NUMBER() OVER()::text as ordernow
    FROM
     ord_main AS ord
     CROSS JOIN LATERAL json_array_elements ( ord.rst_treatment_info :: json ) oxy 
    WHERE
     oxy ->> ''treat_class'' = ''3'' 
   	AND  (oxy ->> ''oxygen_amount'') is not NULL
     AND ord.ord_no = @ordNo

     AND ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_PROCEDURE_FLAG'' ) = ''1'' 
   	AND ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_SEND_FLAG'' ) = ''1'' 
    ) 
   UNION ALL
 (-- 酸素吸入
 SELECT
  ''実績詳細'' AS detail_id,
  ''VQ1'' AS sbt_key,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_CODE'' ), '''' ) AS e01,-- 項目コード
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_ATTR'' ), '''' ) AS e02,-- 項目属性
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_NAME'' ), '''' ) AS e03,-- 項目名称
  COALESCE( TO_CHAR(TO_NUMBER(oxy ->> ''oxygen_amount'',''9999999999.999''),''FM0999999.990'') ) AS e04,-- 数量
  ''1'' AS e05,-- 選択単位フラグ
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_UNIT'' ), '''' ) AS e06,-- 単位コード
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_UNIT'' ), '''' ) AS e07,-- 単位名称
  '''' AS e08,
  '''' AS e09,
  ''31'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_TAG'' ), '''' ) AS e11,-- タグ名称
  COALESCE((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_OXYGEN''), '''') AS sortTag,
	'''' as sorttag1,
			'''' as sorttag2,
  ROW_NUMBER() OVER()::text as ordernow
 FROM
  ord_main AS ord
  CROSS JOIN LATERAL json_array_elements ( ord.rst_treatment_info :: json ) oxy 
 WHERE
  oxy ->> ''treat_class'' = ''3'' 
	AND  (oxy ->> ''oxygen_amount'') is not NULL
  AND ord.ord_no = @ordNo

  AND ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_SEND_FLAG'' ) = ''1'' 

 )) as aa1 order by ordernow,e04),
 data_soap as
 (
 SELECT detail_id,e01,e02,e03,e04,e05,e06,e07,e08,e09,e10,e11,sortTag,sortTag1,sortTag2,''SOAP''::text as  aa
FROM(
 (--  実施コメンSOAP ト S
  SELECT
  ''実績詳細'' AS detail_id,
  ''VC5'' sbt_key,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_CODE'' ), '''' ) AS e01,--e1
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_ATTR_S'' ), '''' ) AS e02,
	case when (petdt.input_params ::json ->> 0) ::json->> ''field_name''= ''S'' AND ((petdt.input_params ::json ->> 0) ::json->> ''item_json'')::json->> ''is_formatting'' = ''0''
	then REGEXP_REPLACE(LEFT((pet.result_params ::json ->> 0) ::json->> ''result_value'',50),E''[\\n\\r]'','' '',''g'')
	when (petdt.input_params ::json ->> 0) ::json->> ''field_name''= ''S'' AND ((petdt.input_params ::json ->> 0) ::json->> ''item_json'')::json->> ''is_formatting'' = ''1''
	then REGEXP_REPLACE(((pet.result_params ::json ->> 0) ::json->> ''result_value'')::text,''<[^<]*?>'','' '',''g'')
	end as e03,
  ''0000000.000'' AS e04,--e4
  ''0'' AS e05,--e5
  '''' AS e06,--e6
  '''' AS e07,--e7
  '''' AS e08,
  '''' AS e09,
  ''32'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_TAG_S'' ), '''' ) AS e11,
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_COMMENT_IMPLEMENTATION'' ), '''' )|| ''-'' || ''1'' ) AS sortTag,
  pet.pat_event_cd ::TEXT as sorttag1,
	''1'' as sorttag2
	FROM pat_event pet
	LEFT JOIN mst_pat_event_data_template petdt
	ON pet.template_cd = petdt.template_cd
	WHERE pet.ord_no = @ordNo
	AND pet.category_name = ''観察記録''
	AND pet.sub_category_name = ''SOAP''
 )
	 UNION ALL
 (--  実施コメンSOAP ト A
  SELECT
  ''実績詳細'' AS detail_id,
  ''VC7'' sbt_key,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_CODE'' ), '''' ) AS e01,--e1
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_ATTR_A'' ), '''' ) AS e02,
	case when (petdt.input_params ::json ->> 2) ::json->> ''field_name''= ''A'' AND ((petdt.input_params ::json ->> 2) ::json->> ''item_json'')::json->> ''is_formatting'' = ''0''
	then REGEXP_REPLACE(LEFT((pet.result_params ::json ->> 2) ::json->> ''result_value'',50),E''[\\n\\r]'','' '',''g'')
	when (petdt.input_params ::json ->> 2) ::json->> ''field_name''= ''A'' AND ((petdt.input_params ::json ->> 2) ::json->> ''item_json'')::json->> ''is_formatting'' = ''1''
	then REGEXP_REPLACE(((pet.result_params ::json ->> 2) ::json->> ''result_value'')::text,''<[^<]*?>'','' '',''g'')
	end as e03,
  ''0000000.000'' AS e04,--e4
  ''0'' AS e05,--e5
  '''' AS e06,--e6
  '''' AS e07,--e7
  '''' AS e08,
  '''' AS e09,
  '''' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_TAG_A'' ), '''' ) AS e11,
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_COMMENT_IMPLEMENTATION'' ), '''' )|| ''-'' || ''3'' ) AS sortTag,
	pet.pat_event_cd ::TEXT as sorttag1,
	''3'' as sorttag2
	FROM pat_event pet
	LEFT JOIN mst_pat_event_data_template petdt
	ON pet.template_cd = petdt.template_cd
	WHERE pet.ord_no = @ordNo
	AND pet.category_name = ''観察記録''
	AND pet.sub_category_name = ''SOAP''
) UNION ALL
 (--  実施コメンSOAP ト O
  SELECT
  ''実績詳細'' AS detail_id,
  ''VC6'' sbt_key,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_CODE'' ), '''' ) AS e01,--e1
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_ATTR_O'' ), '''' ) AS e02,
	case when (petdt.input_params ::json ->> 1) ::json->> ''field_name''= ''O'' AND ((petdt.input_params ::json ->> 1) ::json->> ''item_json'')::json->> ''is_formatting'' = ''0''
	then REGEXP_REPLACE(LEFT((pet.result_params ::json ->> 1) ::json->> ''result_value'',50),E''[\\n\\r]'','' '',''g'')
	when (petdt.input_params ::json ->> 1) ::json->> ''field_name''= ''O'' AND ((petdt.input_params ::json ->> 1) ::json->> ''item_json'')::json->> ''is_formatting'' = ''1''
	then REGEXP_REPLACE(((pet.result_params ::json ->> 1) ::json->> ''result_value'')::text,''<[^<]*?>'','' '',''g'')
	end as e03,
  ''0000000.000'' AS e04,--e4
  ''0'' AS e05,--e5
  '''' AS e06,--e6
  '''' AS e07,--e7
  '''' AS e08,
  '''' AS e09,
  ''32'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_TAG_O'' ), '''' ) AS e11,
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_COMMENT_IMPLEMENTATION'' ), '''' )|| ''-'' || ''2'' ) AS sortTag,
   pet.pat_event_cd ::TEXT as sorttag1,
	 ''2'' as sorttag2	
	FROM pat_event pet
	LEFT JOIN mst_pat_event_data_template petdt
	ON pet.template_cd = petdt.template_cd
	WHERE pet.ord_no = @ordNo
	AND pet.category_name = ''観察記録''
	AND pet.sub_category_name = ''SOAP''
) UNION ALL
 (--  実施コメンSOAP ト P
  SELECT
  ''実績詳細'' AS detail_id,
  ''VC8'' sbt_key,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_CODE'' ), '''' ) AS e01,--e1
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_ATTR_P'' ), '''' ) AS e02,
	case when (petdt.input_params ::json ->> 3) ::json->> ''field_name''= ''P'' AND ((petdt.input_params ::json ->> 3) ::json->> ''item_json'')::json->> ''is_formatting'' = ''0''
	then REGEXP_REPLACE(LEFT((pet.result_params ::json ->> 3) ::json->> ''result_value'',50),E''[\\n\\r]'','' '',''g'')
	when (petdt.input_params ::json ->> 3) ::json->> ''field_name''= ''P'' AND ((petdt.input_params ::json ->> 3) ::json->> ''item_json'')::json->> ''is_formatting'' = ''1''
	then REGEXP_REPLACE(((pet.result_params ::json ->> 3) ::json->> ''result_value'')::text,''<[^<]*?>'','' '',''g'')
	end as e03,
  ''0000000.000'' AS e04,--e4
  ''0'' AS e05,--e5
  '''' AS e06,--e6
  '''' AS e07,--e7
  '''' AS e08,
  '''' AS e09,
  ''32'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_TAG_P'' ), '''' ) AS e11,
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_COMMENT_IMPLEMENTATION'' ), '''' )|| ''-'' || ''4'' ) AS sortTag,
   pet.pat_event_cd ::TEXT as sorttag1,
	 ''4'' as sorttag2		
	FROM pat_event pet
	LEFT JOIN mst_pat_event_data_template petdt
	ON pet.template_cd = petdt.template_cd
	WHERE pet.ord_no = @ordNo
	AND pet.category_name = ''観察記録''
	AND pet.sub_category_name = ''SOAP''
 )
 ) B
 	ORDER BY B.sorttag1 ,B.sorttag2 :: INTEGER),
	equip_all_copy as
(
(--  処置薬品名-手技あり薬剤
 SELECT
  ''実績詳細'' AS detail_id,
  ''VO2'' AS sbt_key,
	 COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE mmd.in_hospital_cd_1 END), '''') AS e01, 
   COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END), COALESCE((SELECT value FROM              dialysis_item_send   WHERE key2 = ''ITEM_MEDICINE_ATTR''), '''')) AS e02, 
	 COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE mmd.medicine_name END), '''') AS e03, 
   COALESCE( TO_CHAR(TO_NUMBER(medi ->> ''amount'',''9999999999''),''FM0999999.990'') )  AS e04,-- 数量
    CASE 
      WHEN (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) IS NULL OR 
           (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) = ''''
        THEN ''0'' 
      ELSE ''1''
    END AS e05, -- 選択単位フラグ
  COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e06,  --単位コード
  COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e07, --単位名称
  '''' AS e08,
  '''' AS e09,
  ''29'' AS e10,
  COALESCE ( (SELECT VALUE FROM dialysis_item_send  WHERE key2 = ''ITEM_MEASURE_MEDICINE_TAG'' ), '''' ) AS e11,-- タグ名称
	COALESCE((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''') AS sortTag,
	medi ->> ''no''  as sorttag1,
	''2'' as sorttag2,
	'''' as sorttagclass
  FROM
  ord_main AS ord
   cross join lateral json_array_elements (ord.rst_medi_info :: json) medi
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
    AND medi->>''medicine_type'' = ''1'' 
    AND medi ->> ''procedure_cd'' IS NOT NULL
    AND (SELECT value FROM DIALYSIS_ITEM_PROCEDURE_TAG WHERE key2 = mp.in_hospital_cd_a1) IS NOT NULL 
    AND (SELECT value FROM DIALYSIS_ITEM_PROCEDURE_TAG WHERE key2 = mp.in_hospital_cd_a1) <> ''''
 ) UNION ALL
(--  処置薬品名-手技なし薬剤
SELECT
  ''実績詳細'' AS detail_id,
  ''VO2'' AS sbt_key,
	 COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE mmd.in_hospital_cd_1 END), '''') AS e01, 
   COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END), COALESCE((SELECT value FROM              dialysis_item_send   WHERE key2 = ''ITEM_NON_PROCEDURE_ATTR''), '''')) AS e02, 
	 COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE mmd.medicine_name END), '''') AS e03, 
   COALESCE( TO_CHAR(TO_NUMBER(medi ->> ''amount'',''9999999999''),''FM0999999.990'') )  AS e04,-- 数量
    CASE 
      WHEN (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) IS NULL OR 
           (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) = ''''
        THEN ''0'' 
      ELSE ''1''
    END AS e05, -- 選択単位フラグ
  COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e06,  --単位コード
  COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e07, --単位名称
  '''' AS e08,
  '''' AS e09,
  ''29'' AS e10,
  COALESCE ( (SELECT VALUE FROM dialysis_item_send  WHERE key2 = ''ITEM_MEASURE_MEDICINE_TAG'' ), '''' ) AS e11,-- タグ名称
	COALESCE((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''') AS sortTag,
	medi ->> ''no'' as sorttag1,
	''3'' as sorttag2,
	'''' as sorttagclass
  FROM
  ord_main AS ord
   cross join lateral json_array_elements (ord.rst_medi_info :: json) medi
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
    AND medi->>''medicine_type'' = ''1'' 
    AND (medi ->> ''procedure_cd'' IS  NULL
    or(medi ->> ''procedure_cd'' IS  Not NULL and ((SELECT value FROM DIALYSIS_ITEM_PROCEDURE_TAG WHERE key2 = mp.in_hospital_cd_a1) IS NULL 
   or (SELECT value FROM DIALYSIS_ITEM_PROCEDURE_TAG WHERE key2 = mp.in_hospital_cd_a1) = '''')))
 )
union all
(--  処置薬品名-手技あり薬剤
 SELECT
  ''実績詳細'' AS detail_id,
  ''VO2'' AS sbt_key,
	 COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE mmd.in_hospital_cd_1 END), '''') AS e01, 
   COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END), COALESCE((SELECT value FROM              dialysis_item_send   WHERE key2 = ''ITEM_MEDICINE_ATTR''), '''')) AS e02, 
	 COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE mmd.medicine_name END), '''') AS e03, 
   COALESCE( TO_CHAR(TO_NUMBER(medi ->> ''amount'',''9999999999''),''FM0999999.990'') )  AS e04,-- 数量
    CASE 
      WHEN (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) IS NULL OR 
           (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) = ''''
        THEN ''0'' 
      ELSE ''1''
    END AS e05, -- 選択単位フラグ
  COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e06,  --単位コード
  COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e07, --単位名称
  '''' AS e08,
  '''' AS e09,
  ''29'' AS e10,
  COALESCE ( (SELECT VALUE FROM dialysis_item_send  WHERE key2 = ''ITEM_MEASURE_MEDICINE_TAG'' ), '''' ) AS e11,-- タグ名称
	COALESCE((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''') AS sortTag,
	 (medi->>''no'') as sorttag1,
	''22'' as sorttag2,
	(medi->>''class_cd'') as sorttagclass
  FROM
  ord_main AS ord
   cross join lateral json_array_elements (ord.rst_medi_info :: json) medi
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
    AND medi->>''medicine_type'' = ''2'' 
    AND medi ->> ''procedure_cd'' IS NOT NULL
    AND (SELECT value FROM DIALYSIS_ITEM_PROCEDURE_TAG WHERE key2 = mp.in_hospital_cd_a1) IS NOT NULL 
    AND (SELECT value FROM DIALYSIS_ITEM_PROCEDURE_TAG WHERE key2 = mp.in_hospital_cd_a1) <> ''''
 ) UNION ALL
(--  処置薬品名-手技なし薬剤
SELECT
  ''実績詳細'' AS detail_id,
  ''VO2'' AS sbt_key,
	 COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE mmd.in_hospital_cd_1 END), '''') AS e01, 
   COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END), COALESCE((SELECT value FROM              dialysis_item_send   WHERE key2 = ''ITEM_NON_PROCEDURE_ATTR''), '''')) AS e02, 
	 COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE mmd.medicine_name END), '''') AS e03, 
   COALESCE( TO_CHAR(TO_NUMBER(medi ->> ''amount'',''9999999999''),''FM0999999.990'') )  AS e04,-- 数量
    CASE 
      WHEN (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) IS NULL OR 
           (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) = ''''
        THEN ''0'' 
      ELSE ''1''
    END AS e05, -- 選択単位フラグ
  COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e06,  --単位コード
  COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e07, --単位名称
  '''' AS e08,
  '''' AS e09,
  ''29'' AS e10,
  COALESCE ( (SELECT VALUE FROM dialysis_item_send  WHERE key2 = ''ITEM_MEASURE_MEDICINE_TAG'' ), '''' ) AS e11,-- タグ名称
	COALESCE((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''') AS sortTag,
	(medi->>''no'') as sorttag1,
	''33'' as sorttag2,
	(medi->>''class_cd'') as sorttagclass
  FROM
  ord_main AS ord
   cross join lateral json_array_elements (ord.rst_medi_info :: json) medi
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
    AND medi->>''medicine_type'' = ''2'' 
    AND (medi ->> ''procedure_cd'' IS  NULL
    or(medi ->> ''procedure_cd'' IS  Not NULL and ((SELECT value FROM DIALYSIS_ITEM_PROCEDURE_TAG WHERE key2 = mp.in_hospital_cd_a1) IS NULL 
   or (SELECT value FROM DIALYSIS_ITEM_PROCEDURE_TAG WHERE key2 = mp.in_hospital_cd_a1) = '''')))
 )
),
data_all AS (
SELECT data_middle_all.detail_id, data_middle_all.e01, data_middle_all.e02, data_middle_all.e03, data_middle_all.e04, data_middle_all.e05, data_middle_all.e06, data_middle_all.e07, data_middle_all.e08, data_middle_all.e09,data_middle_all.e10,data_middle_all.e11,data_middle_all.sortTag
       ,sortTag1,sortTag2,mmq.equipment_cd,mmq.class_cd as mqclass_cd
FROM data_middle_all 
		LEFT JOIN mst_equipment mmq ON data_middle_all.e01 = mmq.in_hospital_cd_1 and data_middle_all.e03 = mmq.equipment_name
		order by sortTag
),
data_all_copy AS (--と薬剤、の適合
SELECT equip_all_copy.detail_id, equip_all_copy.sbt_key,equip_all_copy.e01, equip_all_copy.e02, equip_all_copy.e03, equip_all_copy.e04, equip_all_copy.e05, equip_all_copy.e06, equip_all_copy.e07, equip_all_copy.e08, equip_all_copy.e09,equip_all_copy.e10,equip_all_copy.e11,equip_all_copy.sortTag
       ,sortTag1,sortTag2,sorttagclass, mmd.medicine_cd, mmd.class_cd as mdclass_cd 
FROM equip_all_copy 
    LEFT JOIN mst_medicine mmd ON equip_all_copy.e01 = mmd.in_hospital_cd_1 and equip_all_copy.e03 = mmd.medicine_name
		order by sortTag
),
data_all_med as(--薬剤のモジュール
select detail_id,sbt_key,e01,e02,e03,data_all_copy.e04,e05,e06,e07,e08,e09,e10,e11,sortTag,sortTag1,sortTag2,medicine_cd,
case when sorttag2 = ''22'' or sorttag2 = ''33'' then sorttagclass::text else mdclass_cd::text  end  as mdclass_cd 
			 from data_all_copy where sorttag =(SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_MEASURE_MEDICINE'')
),
data_commmon as(--一般のモジュール
select detail_id, e01,e02,e03,data_all.e04,e05,e06,e07,e08,e09,e10,e11,sortTag,sortTag1,sortTag2,''普通''::text as aa
			 from data_all where 
		 sorttag <> (SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_EQUIP'')
),
data_all_meq0 as (
 select detail_id, e01,e02,e03,data_all.e04,e05,e06,e07,e08,e09,e10,e11,sortTag,sortTag1,sortTag2,''治医疗材料''::text as  aa,equipment_cd,mqclass_cd 
			 from data_all where sorttag=(SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_EQUIP'') and sortTag2 =''18'' 
),
data_all_meq as(--医療材料のモジュール
select detail_id, e01,e02,e03,data_all.e04,e05,e06,e07,e08,e09,e10,e11,sortTag,sortTag1,sortTag2,''医疗材料''::text as  aa,equipment_cd,mqclass_cd 
			 from data_all where sorttag=(SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_EQUIP'')	and sortTag2 !=''18'' 
),
 order_qcode_F AS (--医療材料の1，2场合
 SELECT DISTINCT ON (item_cd_f)* FROM (
   SELECT
     e01 AS item_cd_f,  
     CASE WHEN ''1'' in (SELECT ora FROM do_order_data_equip_from) THEN TO_NUMBER( meq_class_code_order :: text, ''999999999999'' ) ELSE NULL END AS class_qcd_f,
     CASE WHEN ''2'' in (SELECT ora FROM do_order_data_equip_from) THEN TO_NUMBER( meq_code_order :: text, ''999999999999'' ) ELSE NULL END AS meq_cd_f
   FROM
     data_all_meq
     LEFT OUTER JOIN do_mstmeq_cd ON meq_code = data_all_meq.equipment_cd
     LEFT OUTER JOIN do_mstmeq_class_cd ON meq_class_code = data_all_meq.mqclass_cd
   ORDER BY item_cd_f asc) AS order_code_middle_QA 
 ), order_qcode_S AS (--医療材料のない治療条件0场合
   SELECT
     (SELECT in_hospital_cd_1 FROM mst_equipment WHERE equipment_cd = TO_NUMBER( eqp ->> ''cd'' :: text, ''999999999999'')) AS item_cd_s,
     CASE WHEN ''0'' in (SELECT ora FROM do_order_data_equip_from) THEN TO_NUMBER( json_idx :: text, ''999999999999'' ) ELSE NULL END AS login_ord_s,
		 (SELECT COALESCE(TO_CHAR(TO_NUMBER(eqp->> ''amount'',''9999999.999'') ,''FM0999999.990''), '''') FROM mst_equipment WHERE equipment_cd = TO_NUMBER( eqp ->> ''cd'', ''FM0999999.990'')) AS amount,
		 ROW_NUMBER() OVER() as class_cd,
		 ROW_NUMBER() OVER() as equip_cd
   FROM
     ord_main AS ord
     CROSS JOIN LATERAL json_array_elements(ord.rst_equip_info :: json) with ordinality as tmp(eqp, json_idx)
   WHERE ord.ord_no = @ordNo

   ORDER BY item_cd_s, login_ord_s asc
 	)	,
	
	dataequipOrder as(--医療材料の0场合すでにソートされている
 		select detail_id, e01, e02, e03, e04, e05, e06, e07, e08, e09,e10,e11,sortTag,sortTag1,sortTag2,aa,ROW_NUMBER() OVER() as login_ord,class_cd,equip_cd from (
 	(select distinct ''実績詳細'' as detail_id, order_qcode_S.item_cd_s as e01, data_all_meq.e02, data_all_meq.e03, 
 		order_qcode_S.amount as e04, data_all_meq.e05, data_all_meq.e06, data_all_meq.e07, data_all_meq.e08,
 		data_all_meq.e09,data_all_meq.e10,data_all_meq.e11,data_all_meq.sortTag,data_all_meq.sortTag1,data_all_meq.sortTag2,
 		data_all_meq.aa,order_qcode_S.login_ord_s,
     class_cd, 
      equip_cd
 		from order_qcode_S,data_all_meq where order_qcode_S.item_cd_s = data_all_meq.e01 
		and aa = ''医疗材料''
		and order_qcode_S.amount = data_all_meq.e04 order by login_ord_s
     )) as dataequipOrder),
		  dataequipOrder1 as(
 	select detail_id, e01, e02, e03, e04, e05, e06, e07, e08, e09,e10,e11,sortTag,sortTag1,sortTag2,aa, 
 	
 	dataequipOrder.login_ord,order_qcode_F.class_qcd_f as class_cd,order_qcode_F.meq_cd_f as equip_cd
 	from dataequipOrder,order_qcode_F where dataequipOrder.e01 =order_qcode_F.item_cd_f ), 
 	 equip_order as(--医療材料の最終版
 SELECT  detail_id, e01, e02, e03, e04, e05, e06, e07, e08, e09,e10,e11,sorttag, sortTag1,sortTag2, aa
 -- ,login_ord,class_cd,equip_cd
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
          WHEN (SELECT ora FROM do_order_data_equip_from WHERE no2 = 3) = 2 THEN equip_cd END
 				 ),
	equip_order1 as (--最終版
(SELECT  detail_id, e01, e02, e03, e04, e05, e06, e07, e08, e09,e10,e11,sorttag, sortTag1,sortTag2, aa from data_all_meq0 order by sortTag1)
				 union all
(SELECT  detail_id, e01, e02, e03, e04, e05, e06, e07, e08, e09,e10,e11,sorttag, sortTag1,sortTag2, aa from equip_order))			 
 , order_code_F AS (--薬剤ない手技のない治療条件1,3场合
   SELECT
     e01 AS item_cd_f,  
     CASE WHEN ''1'' in (SELECT a1 FROM do_order_data_from) THEN TO_NUMBER( medi_class_code_order :: text, ''999999999999'' ) ELSE NULL END AS class_cd_f,
     CASE WHEN ''3'' in (SELECT a1 FROM do_order_data_from) THEN TO_NUMBER( medi_code_order :: text, ''999999999999'' ) ELSE NULL END AS medi_cd_f
   FROM
     data_all_med
     LEFT OUTER JOIN do_mstmedi_cd ON medi_code = data_all_med.medicine_cd
     LEFT OUTER JOIN do_mstmedi_class_cd ON medi_class_code ::text  = data_all_med.mdclass_cd
   ORDER BY item_cd_f asc 
 ),
 order_code_S AS (--薬剤ない手技のない治療条件0,2,4,5,6场合
   SELECT
	 (case when medi->>''medicine_type'' = ''1'' then  
     (SELECT in_hospital_cd_1 FROM mst_medicine WHERE medicine_cd = TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999''))
	 else  (SELECT in_hospital_cd_1 FROM mst_medicine_mix WHERE medicine_mix_cd = TO_NUMBER( medi ->> ''cd'' :: text, ''999999999999'')) 
	 end ) as item_cd_s,
     CASE WHEN ''0'' in (SELECT a1 FROM do_order_data_from) THEN TO_NUMBER( json_idx :: text, ''999999999999'' ) ELSE NULL END AS login_ord_s,
     CASE WHEN ''2'' in (SELECT a1 FROM do_order_data_from) THEN TO_NUMBER( medi ->> ''medicine_type'' :: text, ''999999999999'' ) ELSE NULL END AS medicine_type_s,
     CASE WHEN ''4'' in (SELECT a1 FROM do_order_data_from) THEN TO_NUMBER( medi ->> ''timing_cd'' :: text, ''999999999999'' ) ELSE NULL END AS timing_cd_s,
     CASE WHEN (''5'' in (SELECT a1 FROM do_order_data_from)
		 and (SELECT VALUE FROM DIALYSIS_ITEM_PROCEDURE_TAG  WHERE key2 =(select in_hospital_cd_a1 from mst_procedure
		 where procedure_cd::text =  medi ->> ''procedure_cd'')) is not null 
		 ) THEN TO_NUMBER( medi ->> ''procedure_cd'' :: text, ''999999999999'' ) 
		 
		 ELSE NULL END AS procedure_cd_s,
     CASE WHEN ''6'' in (SELECT a1 FROM do_order_data_from) THEN TO_NUMBER( medi ->> ''date_interval'' :: text, ''999999999999'' ) ELSE NULL END AS date_interval_s
   FROM
     ord_main AS ord
     CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info :: json) with ordinality as tmp(medi, json_idx)
   WHERE ord.ord_no = @ordNo

   ORDER BY item_cd_s, login_ord_s asc
 )
 , dataAndOrder AS (--薬剤ない手技のない治療条件0,1,2,3,4,5,6场合
  SELECT DISTINCT ON (sortTag2,e01)* FROM (
 SELECT
     distinct detail_id,sbt_key, e01, e02, e03, e04, e05, e06, e07, e08, e09,e10,e11,sortTag,sortTag1,sortTag2,
     order_code_S.login_ord_s AS login_ord,
     order_code_F.class_cd_f  AS class_cd,
		 order_code_S.medicine_type_s AS medicine_type, 
		 		 order_code_F.medi_cd_f  AS medi_cd,
		 order_code_S.timing_cd_s  AS timing_cd,
		 order_code_S.procedure_cd_s AS procedure_cd, 
		 order_code_S.date_interval_s AS date_interval
 FROM
     data_all_med,order_code_S,order_code_F where order_code_S.item_cd_s = e01 and  order_code_S.item_cd_s is not null
		 and order_code_F.item_cd_f = e01 )  AS order_code_middle_B
		 
 ),
 med_order as(--薬剤ない手技の场合
 SELECT
     detail_id,sbt_key,e01, e02, e03, e04, e05, e06, e07, e08, e09,e10,e11,sorttag,sortTag1,sortTag2,''药剂''::text as  aa,
		 login_ord, class_cd, medicine_type, medi_cd, timing_cd, procedure_cd, date_interval
 FROM
     dataAndOrder
 ORDER BY 
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
 
 ),

  med_order1 as (--すべて薬剤の自増番号
  select detail_id::text,sbt_key::text, e01::text, e02::text, e03::text, e04::text, e05::text, e06::text, e07::text, e08::text, e09::text,e10::text,e11::text,
  sorttag::text,sortTag1::text,sortTag2::text,''药剂''::text as  aa, ROW_NUMBER() OVER()::INTEGER as ordernow
  from med_order  ) ,
  med_order2 as(--单体手技取得
  SELECT
    ''実績詳細''::text AS detail_id,
 	'' ''::text as sbt_keys,
    COALESCE ( mp.in_hospital_cd_a1, '''' )::text AS e01,-- 項目コード
   COALESCE ( mp.in_hospital_cd_a2, ( NULLIF ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_PROCEDURE_ATTR'' ), '''' ) ), '''' )::text AS e02,-- 項目属性
    COALESCE ( mp.pricedure_name, '''' )::text AS e03,-- 項目名称
    ''0000000.000''::text AS e04,-- 数量
    ''0''::text AS e05,-- 選択単位フラグ
    ''''::text AS e06,-- 単位コード
    ''''::text AS e07,-- 単位名称
    ''''::text AS e08,
    ''''::text AS e09,
    ''29''::text AS e10,
    COALESCE ( (SELECT VALUE FROM DIALYSIS_ITEM_PROCEDURE_TAG  WHERE key2 = mp.in_hospital_cd_a1 ), '''' )::text AS e11,-- タグ名称
    COALESCE((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')::text AS sortTag,
  (medi->>''no'')::text as sortTag1,
  ''1''::text as sortTag2,
  ''手技''::text as aa
   from 
    ord_main ord
  	CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
  	LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
   WHERE
   ord.ord_no = @ordNo
 	AND medi->>''medicine_type'' = ''1'' 																																																			
   AND medi ->> ''procedure_cd'' IS NOT NULL
   and (SELECT VALUE FROM DIALYSIS_ITEM_PROCEDURE_TAG  WHERE key2 = mp.in_hospital_cd_a1) is not NULL
   and (SELECT VALUE FROM DIALYSIS_ITEM_PROCEDURE_TAG  WHERE key2 = mp.in_hospital_cd_a1) != ''''),
 	 med_order3 as(--調製薬剤の手技取得
  SELECT
    ''実績詳細''::text AS detail_id,
 	 '' ''::text as sbt_keys,
    COALESCE ( mp.in_hospital_cd_a1, '''' )::text AS e01,-- 項目コード
   COALESCE ( mp.in_hospital_cd_a2, ( NULLIF ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_PROCEDURE_ATTR'' ), '''' ) ), '''' )::text AS e02,-- 項目属性
    COALESCE ( mp.pricedure_name, '''' )::text AS e03,-- 項目名称
    ''0000000.000''::text AS e04,-- 数量
    ''0''::text AS e05,-- 選択単位フラグ
    ''''::text AS e06,-- 単位コード
    ''''::text AS e07,-- 単位名称
    ''''::text AS e08,
    ''''::text AS e09,
    ''29''::text AS e10,
    COALESCE ( (SELECT VALUE FROM DIALYSIS_ITEM_PROCEDURE_TAG  WHERE key2 = mp.in_hospital_cd_a1 ), '''' )::text AS e11,-- タグ名称
    COALESCE((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')::text AS sortTag,
  (medi->>''no'')::text as sortTag1,
  ''1''::text as sortTag2,
  ''手技''::text as aa
   from 
    ord_main ord
  	CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
  	LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
   WHERE
   ord.ord_no = @ordNo
 	AND medi->>''medicine_type'' = ''2'' 																																																			
   AND medi ->> ''procedure_cd'' IS NOT NULL
   and (SELECT VALUE FROM DIALYSIS_ITEM_PROCEDURE_TAG  WHERE key2 = mp.in_hospital_cd_a1) is not NULL
   and (SELECT VALUE FROM DIALYSIS_ITEM_PROCEDURE_TAG  WHERE key2 = mp.in_hospital_cd_a1) != ''''),
   med_order4 as
   (--单体手技の番号取得
 	select med_order2.* ,med_order1.ordernow::INTEGER  as ordernow from med_order2,med_order1 where med_order2.sorttag1=med_order1.sorttag1  
 	and (med_order1.sorttag2 = ''2'' or med_order1.sorttag2 = ''3'')),
 	med_order5 as
   (--調製薬剤の手技の番号取得
 	select med_order3.* ,med_order1.ordernow::INTEGER  as ordernow from med_order3,med_order1 where med_order3.sorttag1=med_order1.sorttag1  
 	and (med_order1.sorttag2 = ''22'' or med_order1.sorttag2 = ''33'')),
 	med_order6 as (--すべて薬剤の番号取得
 	select * from med_order4
 	union all
 	select * from med_order5
 	order by ordernow
 		),
 med_order7 as (--单体グループ
 select * from (select * from med_order6
 union all
 select * from med_order1
 order by ordernow,e04) as med_order7 where sorttag2= ''22'' or sorttag2= ''33''
 
 ),
 med_order9 as (--调制分裂
 (
  SELECT
   ''実績詳細'' AS detail_id,
   ''VO2'' AS sbt_key,
    CASE WHEN LENGTH(TRIM(mmd.in_hospital_cd_1)) > 8 THEN RIGHT(TRIM(mmd.in_hospital_cd_1), 8) ELSE RPAD(TRIM(mmd.in_hospital_cd_1), 8, '''') END AS e01, 
 	  COALESCE(mmd.in_hospital_cd_2, COALESCE((SELECT value FROM              dialysis_item_send   WHERE key2 = ''ITEM_MEDICINE_ATTR''), '''')) AS e02, 
 	  COALESCE(mmd.medicine_name, '''''''') AS e03, 
 	 
 	 
   COALESCE( TO_CHAR((TO_NUMBER(medi ->> ''amount'', ''9999999.999'') * TO_NUMBER(mmxd ->> ''amount'', ''9999999.999'' )), ''FM0999999.990'' ) )  AS e04,-- 数量
 
     CASE 
       WHEN (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) IS NULL OR 
            (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) = ''''
         THEN ''0'' 
       ELSE ''1''
     END AS e05, -- 選択単位フラグ
    COALESCE(mmd.unit, '''''''') AS e06,  --単位コード
    COALESCE(mmd.unit, '''''''') AS e07, --単位名称
   '''' AS e08,
   '''' AS e09,
   ''29'' AS e10,
   COALESCE ( (SELECT VALUE FROM dialysis_item_send  WHERE key2 = ''ITEM_MEASURE_MEDICINE_TAG'' ), '''' ) AS e11,-- タグ名称
 	COALESCE((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''') AS sortTag,
 	(medi->>''no'')  as sorttag1,
 	''22'' as sorttag2
   FROM
 ord_main AS ord
       CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info :: json) with ordinality as tmp(medi, json_idx)
       LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
       LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
       CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
       LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
 WHERE
     ord.ord_no = @ordNo
     AND medi->>''medicine_type'' = ''2'' 
     AND medi ->> ''procedure_cd'' IS NOT NULL
     AND (SELECT value FROM DIALYSIS_ITEM_PROCEDURE_TAG WHERE key2 = mp.in_hospital_cd_a1) IS NOT NULL 
     AND (SELECT value FROM DIALYSIS_ITEM_PROCEDURE_TAG WHERE key2 = mp.in_hospital_cd_a1) <> ''''
 )
 UNION ALL
 (
  SELECT
   ''実績詳細'' AS detail_id,
   ''VO2'' AS sbt_key,
    CASE WHEN LENGTH(TRIM(mmd.in_hospital_cd_1)) > 8 THEN RIGHT(TRIM(mmd.in_hospital_cd_1), 8) ELSE RPAD(TRIM(mmd.in_hospital_cd_1), 8, '''') END AS e01, 
 	  COALESCE(mmd.in_hospital_cd_2, COALESCE((SELECT value FROM              dialysis_item_send   WHERE key2 = ''ITEM_MEDICINE_ATTR''), '''')) AS e02, 
 	  COALESCE(mmd.medicine_name, '''''''') AS e03, 
 	 
 	 
    COALESCE( TO_CHAR(TO_NUMBER(medi ->> ''amount'',''9999999999''),''FM0999999.990'') )  AS e04,-- 数量
     CASE 
       WHEN (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) IS NULL OR 
            (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) = ''''
         THEN ''0'' 
       ELSE ''1''
     END AS e05, -- 選択単位フラグ
    COALESCE(mmd.unit, '''''''') AS e06,  --単位コード
    COALESCE(mmd.unit, '''''''') AS e07, --単位名称
   '''' AS e08,
   '''' AS e09,
   ''29'' AS e10,
   COALESCE ( (SELECT VALUE FROM dialysis_item_send  WHERE key2 = ''ITEM_MEASURE_MEDICINE_TAG'' ), '''' ) AS e11,-- タグ名称
 	COALESCE((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''') AS sortTag,
 	(medi->>''no'')  as sorttag1,
 	''33'' as sorttag2
   FROM
 ord_main AS ord
       CROSS JOIN LATERAL json_array_elements(ord.rst_medi_info :: json) with ordinality as tmp(medi, json_idx)
       LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
       LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( medi ->> ''cd'', ''999999999999'' )
       CROSS JOIN LATERAL json_array_elements ( mmx.mix_info :: json ) mmxd
       LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( mmxd ->> ''cd'', ''999999999999'' )
 WHERE
     ord.ord_no = @ordNo
     AND medi->>''medicine_type'' = ''2'' 
     AND (medi ->> ''procedure_cd'' IS  NULL
     or(medi ->> ''procedure_cd'' IS  Not NULL and ((SELECT value FROM DIALYSIS_ITEM_PROCEDURE_TAG WHERE key2 = mp.in_hospital_cd_a1) IS NULL 
    or (SELECT value FROM DIALYSIS_ITEM_PROCEDURE_TAG WHERE key2 = mp.in_hospital_cd_a1) = '''')))
 )
 ),
 med_order10 as (--調製薬剤グループ
 select * from med_order1 
 where sorttag2 != ''22'' and  sorttag2 != ''33''
 union all
 select med_order9.*,med_order7.aa,med_order7.ordernow from med_order9, med_order7 where med_order9.sorttag1 = med_order7.sorttag1
 order by ordernow),
 med_order11 as (--すべて薬剤グループ
 select * from med_order6
 union all
 select * from med_order10
 order by ordernow ,e04)
select * from (
 ( select  detail_id::text, e01::text, e02::text, e03::text, e04::text, e05::text, e06::text, e07::text, e08::text, e09::text,e10::text,e11::text,
  sorttag::text,sortTag1::text,sortTag2::text,aa, null as ordernow from data_commmon)
	union all
  (select  detail_id::text, e01::text, e02::text, e03::text, e04::text, e05::text, e06::text, e07::text, e08::text, e09::text,e10::text,e11::text,
  sorttag::text,sortTag1::text,sortTag2::text,aa,ROW_NUMBER() OVER()::INTEGER as ordernow from med_order11)
	union all
	(select  detail_id::text, e01::text, e02::text, e03::text, e04::text, e05::text, e06::text, e07::text, e08::text, e09::text,e10::text,e11::text,
  sorttag::text,sortTag1::text,sortTag2::text,aa,ROW_NUMBER() OVER()::INTEGER as ordernow from equip_order1)
	union all
	(select  detail_id::text, e01::text, e02::text, e03::text, e04::text, e05::text, e06::text, e07::text, e08::text, e09::text,e10::text,e11::text,
  sorttag::text,sortTag1::text,sortTag2::text,aa,ROW_NUMBER() OVER()::INTEGER as ordernow from data_soap)
	union all
	(select  detail_id::text, e01::text, e02::text, e03::text, e04::text, e05::text, e06::text, e07::text, e08::text, e09::text,e10::text,e11::text,
  sorttag::text,sortTag1::text,sortTag2::text,aa,ROW_NUMBER() OVER()::INTEGER as ordernow from data_oxygen)
	) as aaaa where  e01<>'''' OR e01 IS NOT NULL
	order by sorttag,ordernow
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）実績繰り返し部', '2020-04-24 19:15:25.001',CURRENT_TIMESTAMP, '[{"sql_cd": -20, "field_name": "in_out", "replace_var": "@inOut"}, {"sql_cd": -79, "field_name": "dial_diff_cd", "replace_var": "@dial_diff_cd"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-57, 'WITH default_bed_code_conv AS (
  -- ベッド の連携設定で切り替え 
  SELECT
    0 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS bed_code_conv
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
		-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end	
    AND info ->> ''key1'' = ''FJI_COM_INFO'' 
    AND info ->> ''key2'' = ''BED_CODE_CONV''
  UNION
  SELECT
    1 AS order_no
    , '''' AS bed_code_conv
  ORDER BY order_no ASC LIMIT 1
)
select 
CASE (select bed_code_conv from default_bed_code_conv) WHEN ''1'' THEN mbd.in_hospital_cd_1  WHEN ''2'' THEN mbd.in_hospital_cd_2  ELSE ''V9999999'' end as bed_cd
from 
   ord_main AS ord
     LEFT OUTER JOIN mst_bed AS mbd ON mbd.bed_cd = ord.rst_bed_cd
WHERE
  ord.ord_no = @ordNo 
    AND ord.is_del =''0'' 
    AND ord.facility_cd = @facilityCd ', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）透析実績：予約枠コード（bed_cd）', '2022-03-07 14:56:57.011',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-80, 'WITH course_from_info AS ( 
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS course_from 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
		-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end	
    AND info ->> ''key1'' = ''FJI_COM_INFO'' 
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
		-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end	
    AND info ->> ''key1'' = ''FJI_COM_INFO'' 
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
	-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end		
    AND info ->> ''key1'' = ''FJI_COM_INFO'' 
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
		-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end	
    AND info ->> ''key1'' = ''FJI_COM_INFO'' 
    AND info ->> ''key2'' = ''WARD_CODE'' 
  UNION 
  SELECT
    2 AS order_no
    , '''' AS ward_code 
  ORDER BY
    order_no ASC LIMIT 1
),
default_bed_code_conv AS (
  -- ベッド の連携設定で切り替え 
  SELECT
    0 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS bed_code_conv
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0'' 
		-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end	
    AND info ->> ''key1'' = ''FJI_COM_INFO'' 
    AND info ->> ''key2'' = ''BED_CODE_CONV''
  UNION
  SELECT
    1 AS order_no
    , '''' AS bed_code_conv
  ORDER BY order_no ASC LIMIT 1
),
exam_info AS ( 
  SELECT
    medical_care_info ->> ''ward_cd'' AS ward_cd
    , ward.ward_name AS ward_name
    , ward.in_hospital_cd_1 AS ward_in_hospital_cd
    , medical_care_info ->> ''main_course_cd'' AS main_course_cd
    , course.course_name AS course_name
    , course.in_hospital_cd_1 AS course_in_hospital_cd 
        , COALESCE(( CASE ord.rst_in_out_class WHEN ''0'' THEN ''1'' WHEN ''1'' THEN ''2'' ELSE NULL END ), '''')as  rst_in_out_class -- 院内コードの変換
  FROM
    pat_main AS main 
        INNER  JOIN ord_main_restore AS ord
            on main.pat_id = ord.pat_id
    LEFT JOIN mst_ward AS ward 
      ON ward.ward_cd  = ord.rst_ward_cd
    LEFT JOIN mst_course AS course 
      ON course.course_cd  = ord.rst_course_cd
    WHERE	
      main.pat_id =  @patId 
      and ord.ord_no = @ordNo
		ORDER BY
	    del_date DESC 
	    LIMIT 1
),
bed_info AS (
  SELECT 
    CASE (select bed_code_conv from default_bed_code_conv) WHEN ''1'' THEN mbd.in_hospital_cd_1  WHEN ''2'' THEN mbd.in_hospital_cd_2  ELSE ''V9999999'' end as bed_cd
  FROM 
   ord_main_restore AS ord
     LEFT OUTER JOIN mst_bed AS mbd ON mbd.bed_cd = ord.rst_bed_cd
  WHERE
  ord.ord_no = @ordNo 
  AND ord.facility_cd = @facilityCd
	ORDER BY
    del_date DESC 
	  LIMIT 1
),
in_out_info AS (
  SELECT
  (CASE rst_in_out_class 
	  WHEN ''0'' THEN 
		''1'' 
		WHEN ''1'' THEN 
		''2'' 
		ELSE 
		NULL 
		END) AS rst_in_out_class
	FROM
	ord_main_restore 
  WHERE
	ord_no = @ordNo
    ORDER BY
    del_date DESC 
	  LIMIT 1
)

SELECT
  (SELECT rst_in_out_class FROM in_out_info) AS in_out_f,
	(SELECT bed_cd FROM bed_info) AS bed_cd,
  CASE 
    WHEN (SELECT course_from FROM course_from_info) = ''1'' or (SELECT course_from FROM course_from_info) = ''2''
      THEN COALESCE(NULLIF((SELECT course_in_hospital_cd FROM exam_info), ''''), (SELECT course_code FROM course_code_info)) 
    ELSE (SELECT course_code FROM course_code_info) 
    END AS course_cd,
  CASE (SELECT  rst_in_out_class FROM  exam_info) WHEN ''2'' THEN
      (CASE WHEN (SELECT ward_from FROM ward_from_info) = ''1'' 
       THEN COALESCE(NULLIF((SELECT ward_in_hospital_cd FROM exam_info), ''''), (SELECT ward_code FROM ward_code_info)) 
       ELSE (SELECT ward_code FROM ward_code_info) 
       END)
    ELSE '''' END AS ward_cd
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）透析実績：入外区分、診療科コード、病棟コード、予約枠コード(伝票情報部)取得', '2022-08-29 01:09:54.889',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-48, 'SELECT
  ''0'' AS order_no 
  , CASE WHEN COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') = ''1'' 
    THEN ''01''
    ELSE ''00'' 
    END AS document_no 
FROM
  mst_coop_ini AS ini 
  CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
WHERE
  facility_cd = @facilityCd 
  AND is_del = ''0'' 
	-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end	
  AND info->>''key1'' = ''FJI_COM_INFO''
  AND info->>''key2'' = ''DOCUMENT_NO_SETTING''
UNION
SELECT
  ''1'' AS order_no 
  , ''00'' AS document_no 
ORDER BY order_no ASC LIMIT 1', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）文書番号末尾設定取得 ', '2022-01-19 18:29:49', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-81, 'WITH dialysis_item_send AS (-- 透析項目送信
 SELECT
  info ->> ''key2'' AS key2,
  COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS 
 VALUE
  
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
 WHERE
  facility_cd = @facilityCd 
  AND is_del = ''0'' 
	-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end	
  AND info ->> ''key1'' = ''DIALYSIS_ITEM_SEND'' 
 ),
 device AS (
		SELECT device_mode
		FROM mst_treatment mst JOIN 
    (SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord	 
		ON ord.rst_treatment_cd = mst.treatment_cd 
),
 fji_com_info AS (-- 富士通共通設定
 SELECT
  info ->> ''key2'' AS key2,
  COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS 
 VALUE
  
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
 WHERE
  facility_cd = @facilityCd 
  AND is_del = ''0'' 
	-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end	
  AND info ->> ''key1'' = ''FJI_COM_INFO'' 
 ),
 dialyis_item_sort AS (-- 項目情報部出力順（予約/実績送信用）
 SELECT
  info ->> ''key2'' AS key2,
  COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS 
 VALUE 
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
 WHERE
  facility_cd = @facilityCd 
  AND is_del = ''0'' 
	-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end	
  AND info ->> ''key1'' = ''DIALYSIS_ITEM_SORT'' 
 ),
 conv_teart_item_send_out AS ( -- 浄化方法変換（予約/実績送信用：外来）
 SELECT
  info ->> ''key2'' AS key2,
  UNNEST ( STRING_TO_ARRAY( ( COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) ), '','' ) ) AS 
 VALUE
  
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
 WHERE
  facility_cd = @facilityCd 
  AND is_del = ''0''
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end		
  AND info ->> ''key1'' = ''CONV_TREAT_ITEM_SEND_OUT'' 
 ),
 conv_treat_item_send_in AS ( -- 浄化方法変換（予約/実績送信用：入院）
 SELECT
  info ->> ''key2'' AS key2,
  UNNEST ( string_to_array( COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ), '','' ) ) AS 
 VALUE
  
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
 WHERE
  facility_cd = @facilityCd 
  AND is_del = ''0'' 
	-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end	
  AND info ->> ''key1'' = ''CONV_TREAT_ITEM_SEND_IN'' 
 ),
 dialysis_send AS ( -- 透析发送
 SELECT
  info ->> ''key2'' AS key2,
  COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS 
 VALUE
  
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
 WHERE
  facility_cd = @facilityCd 
  AND is_del = ''0'' 
	-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end	
  AND info ->> ''key1'' = ''DIALYSIS_SEND'' 
 ),
 int_set_medicine_resolve AS ( -- 薬剤分類が「透析液」のもの。セット薬剤の扱いについては、連携設定に従う。

 SELECT
  info ->> ''key2'' AS key2,
  COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS 
 VALUE
  
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
 WHERE
  facility_cd = @facilityCd 
  AND is_del = ''0'' 
	-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end	
  AND info ->> ''key1'' = ''IND_SET_MEDICINE_RESOLVE'' 
 ),
 DIALYSIS_ITEM_PROCEDURE_TAG AS( -- 連携設定「手技あり１～１０－手技コード」 
  SELECT
   info ->> ''key2'' AS key2,
   COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS 
  VALUE
   
  FROM
   mst_coop_ini AS ini
   CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
  WHERE
   facility_cd = @facilityCd 
   AND is_del = ''0'' 
	 -- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end	
   AND info ->> ''key1'' = ''DIALYSIS_ITEM_PROCEDURE_TAG'' 
 ),
 RST_MEDI_INFO AS (-- 透析実績投薬
 SELECT
  medi ->> ''cd'' AS medi_cd 
 FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
  CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi 
 ),
 bed_conv as(	 	
	SELECT
	0 AS order_no,
		to_number(COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ), ''9999999999'') AS bed_conv
	 FROM
		mst_coop_ini AS ini
   CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
	 WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
		-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=@key0
-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end	
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
		( SELECT regexp_split_to_table( @dial_diff_cd, '','' ) AS details ) AS T
 )
SELECT
 all_cost.* 
FROM
 (
  (--  ベッドＮＯ
  SELECT
     ''実績詳細'' AS detail_id,
     ''VE1'' AS sbt_key,
	    CASE (SELECT bed_conv FROM bed_conv)
					WHEN 1 THEN
						( ''V'' || lpad( reverse(SUBSTRING(reverse(mbd.in_hospital_cd_1),1,7)) :: TEXT, 7, ''0'' ) )
					WHEN 2 then 
						( ''V'' || lpad( reverse(SUBSTRING(reverse(mbd.in_hospital_cd_2),1,7)) :: TEXT, 7, ''0'' ) )
					ELSE
						''V9999999'' 
				END AS e01,--項目コード
      COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BED_NO_ATTR'' ), '''' ) AS e02,-- 項目属性
      COALESCE ( SUBSTRING ( mbd.bed_name, 1, 50 ), '''' ) AS e03,--項目名称
      ''0000000.000'' AS e04,--数量
      ''0'' AS e05,-- 選択単位フラグ
      '''' AS e06,-- 単位コード
      '''' AS e07,-- 単位名称
      '''' AS e08,
      '''' AS e09,
	    '''' AS e10,
       COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BED_NO_TAG'' ), '''' ) AS e11,-- タグ名称
      ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_BED_NO'' ), '''' ) ) AS sortTag 
  FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
   LEFT OUTER JOIN mst_bed AS mbd ON mbd.bed_cd = ord.rst_bed_cd   
   ) UNION
  (--  浄化方法
		SELECT
    ''実績詳細'' AS detail_id, 
		''VC1'' AS sbt_key,
    --項目コード
		CASE
			--患者の入外区分が外来の場合
			WHEN @inOut = ''0''
				THEN COALESCE(mtt.in_hospital_cd_a1, '''')
			--患者の入外区分が入院の場合
			WHEN @inOut = ''1''
				THEN COALESCE(NULLIF(mtt.in_hospital_cd_a2, ''''), mtt.in_hospital_cd_a1, '''')
			ELSE ''''
		END AS e01, 
    --項目属性
    COALESCE((SELECT value FROM dialysis_item_send WHERE key2 = ''ITEM_TREAT_ATTR''), '''') AS e02, 
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
		'''' AS e08,
    '''' AS e09,
    '''' AS e10,
    --タグ名称
    COALESCE((SELECT value FROM dialysis_item_send WHERE key2 = ''ITEM_TREAT_TAG''), '''') AS e11, 
    --出力順
    COALESCE((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_TREAT''), '''') AS sortTag
FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
LEFT OUTER JOIN
    mst_treatment mtt
ON
    mtt.treatment_cd = ord.rst_treatment_cd
      ) UNION
  (-- 希望開始時刻
       SELECT
        ''実績詳細'' AS detail_id,
        ''VA6'' AS sbt_key,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_START_DATE_TIME_CODE'' ), '''' ) AS e01,-- 項目コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_START_DATE_TIME_ATTR'' ), '''' ) AS e02,-- 項目属性
        SUBSTRING ( to_char( rst_start_date, ''HH24:MI'' ), 1, 25 ) AS e03,-- 項目名称
        ''0000000.000'' AS e04,-- 数量
        ''0'' AS e05,--選択単位フラグ
        '''' AS e06,-- 単位コード
        '''' AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        ''03'' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_START_DATE_TIME_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_START_DATE_TIME'' ), '''' ) ) AS sortTag 
       FROM
      (SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
       ) UNION
       (-- 希望終了時刻
       SELECT
        ''実績詳細'' AS detail_id,
        ''VA7'' AS sbt_key,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_END_DATE_TIME_CODE'' ), '''' ) AS e01,--項目コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_END_DATE_TIME_ATTR'' ), '''' ) AS e02,-- 項目属性
        to_char( rst_end_date, ''HH24:MI'' ) AS e03,-- 項目名称
        ''0000000.000'' AS e04,-- 数量
        ''0'' AS e05,--選択単位フラグ
        '''' AS e06,-- 単位コード
        '''' AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        ''04'' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_END_DATE_TIME_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_END_DATE_TIME'' ), '''' ) ) AS sortTag 
       FROM
     (SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord

       ) UNION
       (-- 予定所要時間
       SELECT
        ''実績詳細'' AS detail_id,
        ''VA8'' AS sbt_key,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SCHE_TIME_CODE'' ), '''' ) AS e01,-- 項目コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SCHE_TIME_ATTR'' ), '''' ) AS e02,-- 項目属性
        to_char( rst_end_date - rst_start_date, ''HH24:MI'' ) AS e03,-- 項目名称
        ''0000000.000'' AS e04,--数量
        ''0'' AS e05,-- 選択単位フラグ
        '''' AS e06,-- 単位コード
        '''' AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        ''05'' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SCHE_TIME_TAG'' ), '''' ) AS e11,--タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_SCHE_TIME'' ), '''' ) ) AS sortTag 
       FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord

       ) UNION
       (-- 透析前体重
       SELECT
        ''実績詳細'' AS detail_id,
        ''VF2'' AS sbt_key,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BEFORE_WEIGHT_CODE'' ), '''' ) AS e01,-- 項目コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BEFORE_WEIGHT_ATTR'' ), '''' ) AS e02,-- 項目属性
        COALESCE (  to_char( ( ord.rst_weight_info ->> ''weight_before_date'' ) :: TIMESTAMP, ''YYYY/MM/DD'' ), '''' ) AS e03,--項目名称
        COALESCE ( to_char( TO_NUMBER( ord.rst_weight_info ->> ''weight_before'', ''999999999.999'' ), ''FM0999999.990'' ), '''' ) AS e04,-- 数量
        ''1'' AS e05,--  選択単位フラグ
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BEFORE_WEIGHT_UNIT'' ), '''' ) AS e06,-- 単位コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BEFORE_WEIGHT_UNIT'' ), '''' ) AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        ''06'' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BEFORE_WEIGHT_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_BEFORE_WEIGHT'' ), '''' ) ) AS sortTag 
       FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord

       ) UNION
       (-- 透析後体重
       SELECT
        ''実績詳細'' AS detail_id,
        ''VF9'' AS sbt_key,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_AFTER_WEIGHT_CODE'' ), '''' ) AS e01,-- 項目コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_AFTER_WEIGHT_ATTR'' ), '''' ) AS e02,-- 項目属性
        COALESCE ( to_char( ( ord.rst_weight_info ->> ''weight_after_date'' ) :: TIMESTAMP, ''YYYY/MM/DD'' ), '''' ) AS e03,--項目名称
        COALESCE ( to_char( TO_NUMBER( ord.rst_weight_info ->> ''weight_after'', ''999999999.999'' ), ''FM0999999.990'' ), '''' ) AS e04,--  数量
        ''1'' AS e05,--   選択単位フラグ
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_AFTER_WEIGHT_UNIT'' ), '''' ) AS e06,-- 単位コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_AFTER_WEIGHT_UNIT'' ), '''' ) AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        ''07'' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_AFTER_WEIGHT_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_AFTER_WEIGHT'' ), '''' ) ) AS sortTag 
       FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord

       ) UNION
       (-- 目標体重
       SELECT
        ''実績詳細'' AS detail_id,
        ''VF1'' AS sbt_key,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_TARGET_WEIGHT_CODE'' ), '''' ) AS e01,-- 項目コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_TARGET_WEIGHT_ATTR'' ), '''' ) AS e02,-- 項目属性
        COALESCE ( to_char( ord.treat_date :: TIMESTAMP, ''YYYY/MM/DD'' ), '''' ) AS e03,-- 項目名称     
        COALESCE ( to_char( TO_NUMBER(  ord.rst_cond_info -> ''3'' ->> ''value'', ''999999999.999'' ), ''FM0999999.990'' ), '''' ) AS e04,--  数量
        ''1'' AS e05,-- 選択単位フラグ
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_TARGET_WEIGHT_UNIT'' ), '''' ) AS e06,-- 単位コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_TARGET_WEIGHT_UNIT'' ), '''' ) AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        ''08'' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_TARGET_WEIGHT_TAG'' ), '''' ) AS e11,--  タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_TARGET_WEIGHT'' ), '''' ) ) AS sortTag 
       FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord

       ) UNION
       (-- ドライウェイト
       SELECT
        ''実績詳細'' AS detail_id,
        ''VF3'' AS sbt_key,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DRY_WEIGHT_CODE'' ), '''' ) AS e01,-- 項目コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DRY_WEIGHT_ATTR'' ), '''' ) AS e02,-- 項目属性
        COALESCE ( to_char( ord.rst_start_date, ''YYYY/MM/DD'' ), '''' ) AS e03,--項目名称
        COALESCE ( to_char( ord.rst_dw, ''FM0999999.990'' ), '''' ) AS e04,-- 数量
        ''1'' AS e05,-- 選択単位フラグ
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DRY_WEIGHT_UNIT'' ), '''' ) AS e06,-- 単位コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DRY_WEIGHT_UNIT'' ), '''' ) AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        ''09'' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DRY_WEIGHT_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_DRY_WEIGHT'' ), '''' ) ) AS sortTag 
       FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord

       ) UNION
(--  透析導入日
							 SELECT
						''実績詳細'' AS detail_id,--項目コード
						''VS3'' AS sbt_key,
						COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DATE_INTRODUCED_CODE'' ), '''' ) AS e01,-- 項目コード
						COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DATE_INTRODUCED_ATTR'' ), '''' ) AS e02,-- 項目属性 
						COALESCE ( to_char( ( patu.iov ->> ''period_start'' ) :: TIMESTAMP, ''YYYY/MM/DD'' ), '''' ) AS e03,-- 項目名称
						''0000000.000'' AS e04,-- 数量
						''0'' AS e05,-- 選択単位フラグ
						'''' AS e06,-- 単位コード
						'''' AS e07,-- 単位名称
						'''' AS e08,
						'''' AS e09,
						'''' AS e10,
						COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DATE_INTRODUCED_TAG'' ), '''' ) AS e11,--タグ名称
						NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_DATE_INTRODUCED'' ), '''' ) AS sortTag 	
					FROM
                                       (SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
						LEFT JOIN (
						SELECT
							* 
						FROM
							(
								(
								SELECT
									1 AS NO,
									pat_id,
									iov 
								FROM
									pat_unique
									CROSS JOIN LATERAL jsonb_array_elements ( in_out_visit_history_info ) iov 
								WHERE
									pat_id = @patId
									AND iov ->> ''move_in_out'' = ''1'' 
									AND iov ->> ''period_start'' IS NOT NULL 
									AND iov ->> ''from_facility'' IS NOT NULL 
								) UNION
								(
								SELECT
									2 AS NO,
									pat_id,
									iov 
								FROM
									pat_unique
									CROSS JOIN LATERAL jsonb_array_elements ( in_out_visit_history_info ) iov 
								WHERE
									pat_id = @patId 
									AND iov ->> ''move_in_out'' = ''1'' 
									AND iov ->> ''period_start'' IS NOT NULL 
									AND iov ->> ''from_facility'' IS NULL 
								) 
							) DATA 
						ORDER BY
							DATA.NO,
							DATA.iov ->> ''period_start'' 
							LIMIT 1 
						) AS patu ON patu.pat_id = ord.pat_id 
					WHERE
						 patu IS NOT NULL
       ) UNION
      (-- 障害者加算タイトル
        SELECT
        ''実績詳細'' AS detail_id,
        ''VAB'' AS sbt_key,
        COALESCE ((SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ADD_TITLE_CODE'' ),'''') AS e01,--コード
        COALESCE ((SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ADD_TITLE_ATTR'' ),'''') AS e02,
        COALESCE ((SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ADD_TITLE_NAME'' ),'''') AS e03,--名
        ''0000000.000'' AS e04,
        ''0''AS e05,
        '''' AS e06,
        '''' AS e07,
        '''' AS e08,
        '''' AS e09,
        '''' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ADD_TITLE_TAG'' ), '''' ) AS e11,
        NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_DISABLED_ADD'' ), '''' ) AS sortTag  
       WHERE
         (SELECT VALUE FROM dialysis_send WHERE key2 = ''ADD_TITLE_SEND_FLG'' ) = ''1'' 
       ) UNION
       (--  障害者加算:患者基本情報から取得
        SELECT
        ''実績詳細'' AS detail_id,
        ''VAB'' AS sbt_key,
        COALESCE (nullif(mdd.in_hospital_cd_1,'''') ,( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DISABLED_ADD_CODE'' ), '''' ) AS e01,--コード
        COALESCE ( mdd.in_hospital_cd_2, ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DISABLED_ADD_ATTR'' ), '''' ) AS e02,
        COALESCE ( SUBSTRING ( mdd.dialysis_difficulty_name, 1, 25 ), '''' ) AS e03,--名
        ''0000000.000'' AS e04,
        ''0'' AS e05,
        '''' AS e06,
        '''' AS e07,
        '''' AS e08,
        '''' AS e09, 
        '''' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DISABLED_ADD_TAG'' ), '''' ) AS e11,
        NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_DISABLED_ADD'' ), '''' )||''-''||row_no AS sortTag 
        FROM
        mst_dialysis_difficulty mdd,
				dialysis_difficulty_info
				WHERE
					dialysis_difficulty_cd :: TEXT IN (dialysis_difficulty_info.details)
       )  UNION
       (-- VA
       SELECT
        ''実績詳細'' AS detail_id,
        ''VN1'' AS sbt_key,
        COALESCE ( mva.in_hospital_cd_1, '''' ) AS e01,-- 項目コード
        COALESCE ( NULLIF ( mva.in_hospital_cd_2, '''' ), COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SHUNT_PART_ATTR'' ), '''' ) ) AS e02,-- 項目属性
        COALESCE ( SUBSTRING ( mva.va_name, 1, 25 ), '''' ) AS e03,--項目名称
        ''0000000.000'' AS e04,-- 数量
        ''0'' AS e05,-- 選択単位フラグ
        '''' AS e06,--  単位コード
        '''' AS e07,--  単位名称
        '''' AS e08,
        '''' AS e09,
        ''12'' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SHUNT_PART_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_SHUNT_PART'' ), '''' ) ) AS sortTag 
       FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
        LEFT OUTER JOIN mst_va AS mva ON mva.va_cd = TO_NUMBER( ord.rst_cond_info -> ''2'' ->> ''value'', ''999999999999'' ) 

       ) UNION
       (-- 透析器
       SELECT
        ''実績詳細'' AS detail_id,
        ''VH1'' AS sbt_key,
        COALESCE ( mdz.in_hospital_cd_1, '''' ) AS e01,-- 項目コード
        COALESCE ( NULLIF ( mdz.in_hospital_cd_2, '''' ), COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DIAL_INST_ATTR'' ), '''' ) ) AS e02,-- 項目属性
        COALESCE ( SUBSTRING ( mdz.model_number, 1, 25 ), '''' ) AS e03,-- 項目名称
        ''0000001.000'' AS e04,--  数量
        ''1'' AS e05,-- 選択単位フラグ
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DIAL_INST_UNIT'' ), '''' ) AS e06,-- 単位コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DIAL_INST_UNIT'' ), '''' ) AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        ''14'' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_DIAL_INST_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_DIAL_INST'' ), '''' ) ) AS sortTag 
       FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
        LEFT OUTER JOIN mst_dialyzer AS mdz ON mdz.dialyzer_cd = TO_NUMBER( ord.rst_cond_info -> ''5'' ->> ''value'', ''999999999999'' ) 

       ) UNION
       (-- 吸着器
       SELECT
        ''実績詳細'' AS detail_id,
        ''VH2'' AS sbt_key,
        COALESCE ( meq.in_hospital_cd_1, '''' ) AS e01,-- 項目コード
        COALESCE ( meq.in_hospital_cd_2, ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_ADSORPTION_INST_ATTR'' ) ) AS e02,-- 項目属性
        COALESCE ( SUBSTRING ( meq.equipment_name, 1, 25 ), '''' ) AS e03,--  項目名称
        ''0000001.000'' AS e04,-- 数量
       CASE
         
         WHEN meq.unit IS NULL THEN
         ''0'' 
         WHEN meq.unit = '''' THEN
         ''0'' ELSE''1'' 
        END AS e05,--  選択単位フラグ
        COALESCE ( meq.unit, '''' ) AS e06,-- 単位コード
        COALESCE ( meq.unit, '''' ) AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        ''15'' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_ADSORPTION_INST_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_FILM'' ), '''' ) ) AS sortTag 
       FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
        LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''6'' ->> ''value'', ''999999999999'' ) 

       ) UNION
       
       (-- 1次膜
       SELECT
        ''実績詳細'' AS detail_id,
        ''VH3'' AS sbt_key,
        COALESCE ( meq.in_hospital_cd_1, '''' ) AS e01,-- 項目コード
        COALESCE ( meq.in_hospital_cd_2, COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_FIRST_FILM_ATTR'' ), '''' ) ) AS e02,-- 項目属性
        COALESCE ( SUBSTRING ( meq.equipment_name, 1, 25 ), '''' ) AS e03,-- 項目名称
        ''0000001.000'' AS e04,-- 数量
       CASE
         
         WHEN meq.unit IS NULL THEN
         ''0'' 
         WHEN meq.unit = '''' THEN
         ''0'' ELSE''1'' 
        END AS e05,-- 選択単位フラグ
        COALESCE ( meq.unit, '''' ) AS e06,-- 単位コード
        COALESCE ( meq.unit, '''' ) AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        ''16'' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_FIRST_FILM_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_FIRST_FILM'' ), '''' ) ) AS sortTag 
       FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
        LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''7'' ->> ''value'', ''999999999999'' ) 

       ) UNION
       (-- 2次膜
       SELECT
        ''実績詳細'' AS detail_id,
        ''VH3'' AS sbt_key,
        COALESCE ( meq.in_hospital_cd_1, '''' ) AS e01,-- 項目コード
        COALESCE ( NULLIF ( meq.in_hospital_cd_2, '''' ), COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SECOND_FILM_ATTR'' ), '''' ) ) AS e02,-- 項目属性
        COALESCE ( SUBSTRING ( meq.equipment_name, 1, 25 ), '''' ) AS e03,-- 項目名称
        ''0000001.000'' AS e04,--数量
       CASE
         
         WHEN meq.unit IS NULL THEN
         ''0'' 
         WHEN meq.unit = '''' THEN
         ''0'' ELSE''1'' 
        END AS e05,-- 選択単位フラグ
        COALESCE ( meq.unit, '''' ) AS e06,-- 単位コード
        COALESCE ( meq.unit, '''' ) AS e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        ''17'' AS e10,
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SECOND_FILM_TAG'' ), '''' ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_SECOND_FILM'' ), '''' ) ) AS sortTag 
       FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
        LEFT OUTER JOIN mst_equipment AS meq ON meq.equipment_cd = TO_NUMBER( ord.rst_cond_info -> ''8'' ->> ''value'', ''999999999999'' ) 

       ) UNION
       (-- A針情報
			 SELECT
    ''実績詳細'' AS detail_id, 
		''VR1'' AS sbt_key,
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM dialysis_item_send WHERE key2 = ''ITEM_EQUIP_ATTR''), '''')) AS e02, 
    --項目名称
    COALESCE ( SUBSTRING ( meq.equipment_name, 1, 25 ), '''' ) AS e03,
    --数量
    ''0000001.000'' AS e04, 
    --選択単位フラグ
    CASE WHEN meq.unit IS NULL OR meq.unit = ''''
    THEN ''0'' ELSE ''1'' END AS e05, 
    --単位コード
    COALESCE(meq.unit, '''') AS e06, 
    --単位名称
    COALESCE(meq.unit, '''') AS e07, 
     '''' AS e08,
     '''' AS e09,
     ''18'' AS e10,
     COALESCE ( meqc.class_name, '''' ) AS e11,--  タグ名称
     ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_EQUIP'' ), '''' ) ) AS sortTag 
FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
LEFT OUTER JOIN
    mst_equipment as meq
ON
    meq.equipment_cd = TO_NUMBER(ord.rst_cond_info->''9''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_equipment_class meqc
ON
    meq.class_cd = meqc.class_cd
WHERE
    ord.rst_cond_info->''9''->>''value'' IS NOT NULL

       ) UNION ALL 
			 (
			 SELECT
    --V針情報
    ''実績詳細'' AS detail_id, 
		''VR1'' AS sbt_key,
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM dialysis_item_send WHERE key2 = ''ITEM_EQUIP_ATTR''), '''')) AS e02, 
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
     '''' AS e08,
     '''' AS e09,
     ''18'' AS e10,
     COALESCE ( meqc.class_name, '''' ) AS e11,--  タグ名称
     ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_EQUIP'' ), '''' ) ) AS sortTag 
FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
LEFT OUTER JOIN
    mst_equipment as meq
ON
    meq.equipment_cd = TO_NUMBER(ord.rst_cond_info->''10''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_equipment_class meqc
ON
    meq.class_cd = meqc.class_cd
WHERE
    ord.rst_cond_info->''10''->>''value'' IS NOT NULL	 
			 )
	UNION ALL		 
 (-- SN針情報
     SELECT
    --SN針情報
    ''実績詳細'' AS detail_id, 
		''VR1'' AS sbt_key,
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM dialysis_item_send WHERE key2 = ''ITEM_EQUIP_ATTR''), '''')) AS e02, 
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
     '''' AS e08,
     '''' AS e09,
     ''18'' AS e10,
     COALESCE ( meqc.class_name, '''' ) AS e11,--  タグ名称
     ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_EQUIP'' ), '''' ) ) AS sortTag 
FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
LEFT OUTER JOIN
    mst_equipment as meq
ON
    meq.equipment_cd = TO_NUMBER(ord.rst_cond_info->''11''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_equipment_class meqc
ON
    meq.class_cd = meqc.class_cd
WHERE
    ord.rst_cond_info->''11''->>''value'' IS NOT NULL	 
       ) UNION ALL
(-- 血液回路
      SELECT
    --血液回路情報
    ''実績詳細'' AS detail_id, 
		''VR1'' AS sbt_key,
    --項目コード
    COALESCE(meq.in_hospital_cd_1, '''') AS e01, 
    --項目属性
    COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM dialysis_item_send WHERE key2 = ''ITEM_EQUIP_ATTR''), '''')) AS e02, 
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
     '''' AS e08,
     '''' AS e09,
     ''18'' AS e10,
     COALESCE ( meqc.class_name, '''' ) AS e11,--  タグ名称
     ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_EQUIP'' ), '''' ) ) AS sortTag 
FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
LEFT OUTER JOIN
    mst_equipment meq
ON
    meq.equipment_cd = TO_NUMBER(ord.rst_cond_info->''13''->>''value'',''999999999999'')
LEFT OUTER JOIN
    mst_equipment_class meqc
ON
    meq.class_cd = meqc.class_cd
WHERE
    ord.rst_cond_info->''13''->>''value'' IS NOT NULL
       ) UNION ALL
			 (
 SELECT
    --医療材料情報
     ''実績詳細'' AS detail_id, 
		 	''VR1'' AS sbt_key,
     --項目コード
     COALESCE(meq.in_hospital_cd_1, '''') AS e01, 
     --項目属性
     COALESCE(meq.in_hospital_cd_2, COALESCE((SELECT value FROM dialysis_item_send WHERE key2 = ''ITEM_EQUIP_ATTR''), '''')) AS e02, 
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
      '''' AS e08,
      '''' AS e09,
     ''18'' AS e10,
     COALESCE ( meqc.class_name, '''' ) AS e11,--  タグ名称
     ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_EQUIP'' ), '''' ) ) AS sortTag 
 FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
     cross join lateral json_array_elements (ord.rst_equip_info :: json) equip

 LEFT OUTER JOIN
     mst_equipment meq
 ON
     meq.equipment_cd = TO_NUMBER(equip->>''cd'',''999999999999'')  
 LEFT OUTER JOIN
     mst_equipment_class meqc
 ON
     meq.class_cd = meqc.class_cd
 WHERE
     equip->>''equip_type'' = ''0''  		 
			 )UNION
       (-- 透析液
        SELECT
        ''実績詳細'' AS detail_id,
        ''VI1'' AS sbt_key,
        COALESCE ( mmd.in_hospital_cd_1, '''' ) AS e01,-- 項目コード
        COALESCE ( mmd.in_hospital_cd_2, ( COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_ATTR'' ), '''' ) ) ) AS e02,--項目属性
        COALESCE ( SUBSTRING ( mmd.medicine_name, 1, 25 ), '''' ) e03,-- 項目名称
      CASE
      WHEN ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''0'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''0'') OR
           ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''0'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''2'') OR
           ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''0'') OR
           ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''2'') OR
					 ((SELECT device_mode FROM device) NOT IN (7, 8, 10))
        THEN
          TO_CHAR(TO_NUMBER(COALESCE(ord.rst_cond_info->''17''->>''value'',''0''), ''999999999.999''), ''FM0099999.990'')
      WHEN ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''0'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''1'') OR
           ((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1'' AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''1'') AND
					 ((SELECT device_mode FROM device) IN (7, 8, 10))
        THEN
          TO_CHAR(TO_NUMBER(COALESCE(ord.rst_cond_info->''17''->>''value'',''0''), ''999999999.999'') + TO_NUMBER(COALESCE(ord.rst_cond_info->''22''->>''value'',''0''), ''9999999.999''), ''FM0099999.990'')
      ELSE ''0000000.000''
			END AS e04,
        ''1''  AS e05,-- 選択単位フラグ
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_UNIT'' ), '''' ) e06,-- 単位コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_UNIT'' ), '''' ) e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        ''23'' AS e10,
        ( NULLIF ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_TAG'' ), '''' ) ) AS e11,--タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_SOLUTION'' ), '''' ) ) AS sortTag 
       FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
        LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''15'' ->> ''value'', ''999999999999'' )
        LEFT OUTER JOIN mst_medicine_class AS mmc ON mmc.class_cd = mmd.class_cd 
       WHERE
      ( SELECT VALUE FROM int_set_medicine_resolve WHERE key2 = ''SOLUTION_RESOLVE_MODE'' ) = ''0'' 
       ) UNION
       (-- 置換液（補液）
       SELECT
        ''実績詳細'' AS detail_id,
        ''VI1'' AS sbt_key,
        COALESCE ( mmd.in_hospital_cd_1, '''' ) AS e01,-- 項目コード
        COALESCE ( mmd.in_hospital_cd_2, ( COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_REPLACE_ATTR'' ), '''' ) ) ) AS e02,-- 項目属性
        COALESCE ( SUBSTRING ( mmd.medicine_name, 1, 25 ), '''' ) e03,-- 項目名称
        to_char( TO_NUMBER( ord.rst_cond_info -> ''22'' ->> ''value'', ''999999999.999'' ), ''FM0000099.990'' ) AS e04,-- 数量
				''1'' e05,-- 選択単位フラグ
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_REPLACE_UNIT'' ), '''' ) e06,-- 単位コード
        COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_REPLACE_UNIT'' ), '''' ) e07,-- 単位名称
        '''' AS e08,
        '''' AS e09,
        ''23'' AS e10,
        ( NULLIF ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_REPLACE_TAG'' ), '''' ) ) AS e11,-- タグ名称
        ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_REPLACE'' ), '''' ) ) AS sortTag 
       FROM
        (SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
        LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''19'' ->> ''value'', ''999999999999'' )
        LEFT OUTER JOIN mst_medicine_class AS mmc ON mmc.class_cd = mmd.class_cd 
       WHERE
         (((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1''
				AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') = ''0''
			  AND ((SELECT device_mode FROM device) IN (7, 8, 10)))
		    OR ((SELECT device_mode FROM device) NOT IN (7, 8, 10)))
	
       ) UNION
       (-- 抗凝固剤初回
       SELECT
        ''実績詳細'' AS detail_id,
        ''VGX'' AS sbt_key,
        ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE mmd.in_hospital_cd_1 END ) AS e01,-- 項目コード
        COALESCE (
         ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END ),
         ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_KOU_COAG_ONESHOT_ATTR'' ) 
        ) AS e02,-- 項目属性
        COALESCE (
        SUBSTRING ( ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE mmd.medicine_name END ), 1, 25 ),
    '''' 
   ) AS e03,-- 項目名称
   to_char( TO_NUMBER( COALESCE ( ord.rst_cond_info -> ''26'' ->> ''value'', ''0'' ), ''999999999.999'' ), ''FM0099999.990'' ) AS e04,-- 数量
   (
    COALESCE (
    CASE
      
      WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) IS NULL THEN
       ''0'' 
      WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) = '''' THEN
    ''0'' ELSE NULL 
   END,
   ( CASE ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_KOU_COAG_ONESHOT_UNIT_SEL'' ) WHEN ''2'' THEN ''2'' ELSE''1'' END ) 
    ) 
  ) AS e05,-- 選択単位フラグ
  ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) AS e06,-- 単位コード
  ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) AS e07,-- 単位名称
  '''' AS e08,
  '''' AS e09,
  ''24'' AS e10,
  ( NULLIF ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_KOU_COAG_ONESHOT_TAG'' ), '''' ) ) AS e11,-- タグ名称
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_KOU_COAG_ONESHOT'' ), '''' ) ) AS sortTag 
 FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
  LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''999999999999'' )
  LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''999999999999'' ) 
 WHERE
   ( SELECT VALUE FROM int_set_medicine_resolve WHERE key2 = ''KOU_COAG_RESOLVE_MODE'' ) = ''0'' 
 ) UNION
 (-- 抗凝固剤持続
 
 SELECT
  ''実績詳細'' AS detail_id,
  ''VGY'' AS sbt_key,
  ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE mmd.in_hospital_cd_1 END ) AS e01,-- 項目コード
  COALESCE (
   ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END ),
   ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_KOU_COAG_ATTR'' ) 
  ) AS e02,-- 項目属性
  COALESCE(SUBSTRING ( ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE mmd.medicine_name END ), 1, 25 ),'''') AS e03,-- 項目名称
 to_char( TO_NUMBER( COALESCE ( ord.rst_cond_info -> ''27'' ->> ''value'', ''0'' ), ''999999999.999'' ), ''FM0099999.990'' ) AS e04,--e4
 (
  COALESCE (
  CASE
    
    WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) IS NULL THEN ''0'' 
    WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) = '''' THEN ''0'' 
 END,
 ( CASE ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_KOU_COAG_UNIT_SEL'' ) WHEN ''2'' THEN ''2'' ELSE''1'' END ) 
 ) 
 ) AS e05,-- 選択単位フラグ
 (
  COALESCE (
  CASE
    
    WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) IS NULL THEN ''''
    WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) = '''' THEN '''' 
 END,
 (
 CASE
   ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ADD_UNIT_FLG'' ) 
   WHEN ''1'' THEN
  ( ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) || ''/h'' ) ELSE ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) 
 END 
 ) 
 ) 
 ) AS e06,-- 単位コード
 (
  COALESCE (
  CASE
    
    WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) IS NULL THEN ''''
    WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) = '''' THEN ''''
 END,
 (
 CASE
   ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ADD_UNIT_FLG'' ) 
   WHEN ''1'' THEN
  ( ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) || ''/h'' ) ELSE ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) 
 END 
 ) 
 ) 
 ) AS e07,-- 単位名称
 '''' AS e08,
 '''' AS e09,
 ''25'' AS e10,
 ( NULLIF ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_KOU_COAG_TAG'' ), '''' ) ) AS e11,-- タグ名称
 ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_KOU_COAG'' ), '''' ) ) AS sortTag 
FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
 LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''999999999999'' )
 LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''999999999999'' ) 
WHERE
 ( SELECT VALUE FROM int_set_medicine_resolve WHERE key2 = ''KOU_COAG_RESOLVE_MODE'' ) = ''0'' 
 ) UNION
 (-- 抗凝固剤TOTAL
 SELECT
  ''実績詳細'' AS detail_id,
  ''VGZ'' AS sbt_key,
  ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE mmd.in_hospital_cd_1 END ) AS e01,-- 項目コード
  COALESCE (
   ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END ),
   ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_KOU_COAG_TOTAL_ATTR'' ) 
  ) AS e2,-- 項目属性,
    COALESCE(SUBSTRING ( ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE mmd.medicine_name END ), 1, 25 ),'''')  AS e03,-- 項目名称
 to_char(
  TO_NUMBER( COALESCE ( ord.rst_cond_info -> ''26'' ->> ''value'', ''0'' ), ''999999999.999'' ) + TO_NUMBER( COALESCE ( ord.rst_cond_info -> ''28'' ->> ''value'', ''0'' ), ''999999999.999'' ),
  ''FM0999999.990'' 
 ) AS e04,-- 選択単位フラグ
 (
  COALESCE (
  CASE 
    WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) IS NULL THEN ''0'' 
    WHEN ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ) = '''' THEN ''0''  
 END,
 ( CASE ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_KOU_COAG_TOTAL_UNIT_SEL'' ) WHEN ''2'' THEN ''2'' ELSE''1'' END ) ) 
 ) AS e05,-- 選択単位フラグ
 COALESCE ( ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ), '''' ) AS e06,-- 単位コード
 COALESCE ( ( CASE ord.rst_cond_info -> ''25'' ->> ''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END ), '''' ) AS e07,-- 単位名称
 '''' AS e08,
 '''' AS e09,
 ''26'' AS e10,
 ( NULLIF ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_KOU_COAG_TOTAL_TAG'' ), '''' ) ) AS e11,-- タグ名称
 ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_KOU_COAG_TOTAL'' ), '''' ) ) AS sortTag 
FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
 LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''999999999999'' )
 LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER( ord.rst_cond_info -> ''25'' ->> ''value'', ''999999999999'' ) 
WHERE
( SELECT VALUE FROM int_set_medicine_resolve WHERE key2 = ''KOU_COAG_RESOLVE_MODE'' ) = ''0''

 ) UNION
(--  血液流量
 SELECT
  ''実績詳細'' AS detail_id,
  ''VK3'' AS sbt_key,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BLOOD_AMT_CODE'' ), '''' ) AS e01,-- 項目コード
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BLOOD_AMT_ATTR'' ), '''' ) AS e02,-- 項目属性
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BLOOD_AMT_NAME'' ), '''' ) AS e03,-- 項目名称
  to_char( TO_NUMBER( ord.rst_cond_info -> ''14'' ->> ''value'', ''999999999999'' ), ''FM0000999.990'' ) AS e04,-- 数量
  ''1'' AS e05,-- 選択単位フラグ
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BLOOD_AMT_UNIT'' ), '''' ) AS e06,-- 単位コード
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BLOOD_AMT_UNIT'' ), '''' ) AS e07,-- 単位コード
  '''' AS e08,
  '''' AS e09,
  ''27'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_BLOOD_AMT_TAG'' ), '''' ) AS e11,-- タグ名称
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_BLOOD_AMT'' ), '''' ) ) AS sortTag 
 FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
 WHERE
 TO_NUMBER( ord.rst_cond_info -> ''14'' ->> ''value'', ''999999999999'' ) > 1 
  AND ( SELECT VALUE FROM int_set_medicine_resolve WHERE key2 = ''SOLUTION_RESOLVE_MODE'' ) = ''0'' 

 )UNION(-- 透析液流量
  SELECT
  ''実績詳細'' AS detail_id,
  ''VK4'' AS sbt_key,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_AMT_CODE'' ), '''' ) AS e01,--e1
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_AMT_ATTR'' ), '''' ) AS e02,--e2
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_AMT_NAME'' ), '''' ) AS e03,--e3
  to_char( TO_NUMBER( ord.rst_cond_info -> ''16'' ->> ''value'', ''999999999999'' ), ''FM0000999.990'' ) AS e04,--e4
  ''1'' AS e05,--e5
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_AMT_UNIT'' ), '''' ) AS e06,--e6
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_AMT_UNIT'' ), '''' ) AS e07,--e7
  '''' AS e08,
  '''' AS e09,
  ''28'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_SOLUTION_AMT_TAG'' ), '''' ) AS e11,
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_SOLUTION_AMT'' ), '''' ) ) AS sortTag 
 FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
 WHERE
  TO_NUMBER( ord.rst_cond_info -> ''16'' ->> ''value'', ''999999999999'' ) >= 1 
 )
 union
 (-- 補液量
 SELECT
  ''実績詳細'' AS detail_id,
  ''VS2'' AS sbt_key,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_UP_LIQUID_CODE'' ), '''' ) AS e01,--項目コード
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_UP_LIQUID_ATTR'' ), '''' ) AS e02,--項目属性
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_UP_LIQUID_NAME'' ), '''' ) AS e03,--項目名称
  to_char( TO_NUMBER( ord.rst_cond_info -> ''20'' ->> ''value'', ''999999999999'' ), ''FM0000099.990'' ) AS e04,--数量
  ''1'' AS e05,-- 選択単位フラグ
	COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_UP_LIQUID_UNIT'' ), '''' ) AS e06,--単位コード
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_UP_LIQUID_UNIT'' ), '''' ) AS e07,--単位名称
  '''' AS e08,
  '''' AS e09,
  ''28'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_UP_LIQUID_TAG'' ), '''' ) AS e11,-- タグ名称
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_UP_LIQUID'' ), '''' ) ) AS sortTag 
 FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
 WHERE
 TO_NUMBER( ord.rst_cond_info -> ''20'' ->> ''value'', ''999999999999'' ) > 1 
  AND (((SELECT value FROM fji_com_info WHERE key2 = ''LIQUID_SEND_FLAG'') = ''1''
  AND (SELECT value FROM fji_com_info WHERE key2 = ''DIALYSIS_LIQUID_ADD_FLG'') in (''0'',''1'',''2'') 
  AND ((SELECT device_mode FROM device) IN (7, 8, 10)))
  OR ((SELECT device_mode FROM device) NOT IN (7, 8, 10)))
  
 ) UNION
(-- 薬品手技7606
 SELECT
  ''実績詳細'' AS detail_id,
  ''VO1'' AS sbt_key,
  COALESCE ( mp.in_hospital_cd_a1, '''' ) AS e01,-- 項目コード
 COALESCE ( mp.in_hospital_cd_a2, ( NULLIF ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_PROCEDURE_ATTR'' ), '''' ) ), '''' ) AS e02,-- 項目属性
  COALESCE ( mp.pricedure_name, '''' ) AS e03,-- 項目名称
  ''0000000.000'' AS e04,-- 数量
  ''0'' AS e05,-- 選択単位フラグ
  '''' AS e06,-- 単位コード
  '''' AS e07,-- 単位名称
  '''' AS e08,
  '''' AS e09,
  ''29'' AS e10,
  COALESCE ( (SELECT VALUE FROM DIALYSIS_ITEM_PROCEDURE_TAG  WHERE key2 = mp.in_hospital_cd_a1 ), '''' ) AS e11,-- タグ名称
--   NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_MEASURE_MEDICINE'' ), '''' ) AS sortTag 
COALESCE((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-'' || (medi->>''no'') || ''-''|| ''1'' AS sortTag
 FROM
  (SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo ORDER BY del_date desc limit 1) ord	
	CROSS JOIN LATERAL json_array_elements ( ord.rst_medi_info :: json ) medi
	LEFT OUTER JOIN mst_procedure AS mp ON mp.procedure_cd = TO_NUMBER( medi ->> ''procedure_cd'', ''999999999999'' )
 WHERE
 medi ->> ''procedure_cd'' IS NOT NULL
 and (SELECT VALUE FROM DIALYSIS_ITEM_PROCEDURE_TAG  WHERE key2 = mp.in_hospital_cd_a1) is not NULL
 and (SELECT VALUE FROM DIALYSIS_ITEM_PROCEDURE_TAG  WHERE key2 = mp.in_hospital_cd_a1) != ''''

 ) UNION
 (--  処置薬品名-手技あり薬剤
 SELECT
  ''実績詳細'' AS detail_id,
  ''VO2'' AS sbt_key,
	 COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE mmd.in_hospital_cd_1 END), '''') AS e01, 
   COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END), COALESCE((SELECT value FROM              dialysis_item_send   WHERE key2 = ''ITEM_MEDICINE_ATTR''), '''')) AS e02, 
	 COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE mmd.medicine_name END), '''') AS e03, 
   COALESCE( TO_CHAR(TO_NUMBER(medi ->> ''amount'',''9999999999''),''FM0999999.990'') )  AS e04,-- 数量
    CASE 
      WHEN (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) IS NULL OR 
           (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) = ''''
        THEN ''0'' 
      ELSE ''1''
    END AS e05, -- 選択単位フラグ
  COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e06,  --単位コード
  COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e07, --単位名称
  '''' AS e08,
  '''' AS e09,
  ''29'' AS e10,
  COALESCE ( (SELECT VALUE FROM dialysis_item_send  WHERE key2 = ''ITEM_MEASURE_MEDICINE_TAG'' ), '''' ) AS e11,-- タグ名称
	COALESCE((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-'' || (medi->>''no'') || ''-''|| ''2'' AS sortTag
  FROM
  (SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo ORDER BY del_date desc limit 1) ord	
   cross join lateral json_array_elements (ord.rst_medi_info :: json) medi
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
     medi ->> ''procedure_cd'' IS NOT NULL
    AND (SELECT value FROM DIALYSIS_ITEM_PROCEDURE_TAG WHERE key2 = mp.in_hospital_cd_a1) IS NOT NULL 
    AND (SELECT value FROM DIALYSIS_ITEM_PROCEDURE_TAG WHERE key2 = mp.in_hospital_cd_a1) <> ''''
 ) UNION
(--  処置薬品名-手技なし薬剤
SELECT
  ''実績詳細'' AS detail_id,
  ''VO2'' AS sbt_key,
	 COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_1 ELSE mmd.in_hospital_cd_1 END), '''') AS e01, 
   COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.in_hospital_cd_2 ELSE mmd.in_hospital_cd_2 END), COALESCE((SELECT value FROM              dialysis_item_send   WHERE key2 = ''ITEM_NON_PROCEDURE_ATTR''), '''')) AS e02, 
	 COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.medicine_mix_name ELSE mmd.medicine_name END), '''') AS e03, 
   COALESCE( TO_CHAR(TO_NUMBER(medi ->> ''amount'',''9999999999''),''FM0999999.990'') )  AS e04,-- 数量
    CASE 
      WHEN (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) IS NULL OR 
           (CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END) = ''''
        THEN ''0'' 
      ELSE ''1''
    END AS e05, -- 選択単位フラグ
  COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e06,  --単位コード
  COALESCE((CASE medi->>''medicine_type'' WHEN ''2'' THEN mmx.unit ELSE mmd.unit END), '''') AS e07, --単位名称
  '''' AS e08,
  '''' AS e09,
  ''29'' AS e10,
  COALESCE ( (SELECT VALUE FROM dialysis_item_send  WHERE key2 = ''ITEM_MEASURE_MEDICINE_TAG'' ), '''' ) AS e11,-- タグ名称
	COALESCE((SELECT value FROM dialyis_item_sort WHERE key2 = ''ITEM_MEASURE_MEDICINE''), '''')|| ''-'' || (medi->>''no'') || ''-''|| ''3'' AS sortTag
  FROM
  (SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo ORDER BY del_date desc limit 1) ord	
   cross join lateral json_array_elements (ord.rst_medi_info :: json) medi
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
    (medi ->> ''procedure_cd'' IS  NULL
    or(medi ->> ''procedure_cd'' IS  Not NULL and ((SELECT value FROM DIALYSIS_ITEM_PROCEDURE_TAG WHERE key2 = mp.in_hospital_cd_a1) IS NULL 
   or (SELECT value FROM DIALYSIS_ITEM_PROCEDURE_TAG WHERE key2 = mp.in_hospital_cd_a1) = '''')))
 )  

 UNION
 (--  実施コメンSOAP ト A
 SELECT
  ''実績詳細'' AS detail_id,
  ''VC7'' sbt_key,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_CODE'' ), '''' ) AS e02,--e1
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_ATTR_A'' ), '''' ) AS e02,
  ''A'' AS e03,--e3
  ''0000000.000'' AS e04,--e4
  ''0'' AS e05,--e5
  '''' AS e06,--e6
  '''' AS e07,--e7
  '''' AS e08,
  '''' AS e09,
  ''32'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_TAG_A'' ), '''' ) AS e11,
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_COMMENT_IMPLEMENTATION'' ), '''' ) ) AS sortTag 
 ) UNION
 (--  実施コメンSOAP ト O
 SELECT
  ''実績詳細'' AS detail_id,
  ''VC6'' sbt_key,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_CODE'' ), '''' ) AS e02,--e1
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_ATTR_O'' ), '''' ) AS e02,
  ''O'' AS e03,--e3
  ''0000000.000'' AS e04,--e4
  ''0'' AS e05,--e5
  '''' AS e06,--e6
  '''' AS e07,--e7
  '''' AS e08,
  '''' AS e09,
  ''32'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_TAG_O'' ), '''' ) AS e11,
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_COMMENT_IMPLEMENTATION'' ), '''' ) ) AS sortTag 
 ) UNION
 (--  実施コメンSOAP ト P
 SELECT
  ''実績詳細'' AS detail_id,
  ''VC8'' sbt_key,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_CODE'' ), '''' ) AS e02,--e1
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_ATTR_P'' ), '''' ) AS e02,
  ''P'' AS e03,--e3
  ''0000000.000'' AS e04,--e4
  ''0'' AS e05,--e5
  '''' AS e06,--e6
  '''' AS e07,--e7
  '''' AS e08,
  '''' AS e09,
  ''32'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_TAG_P'' ), '''' ) AS e11,
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_COMMENT_IMPLEMENTATION'' ), '''' ) ) AS sortTag 
 ) UNION
 (--  実施コメンSOAP ト S
 SELECT
  ''実績詳細'' AS detail_id,
  ''VC5'' sbt_key,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_CODE'' ), '''' ) AS e02,--e1
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_ATTR_S'' ), '''' ) AS e02,
  ''S'' AS e03,--e3
  ''0000000.000'' AS e04,--e4
  ''0'' AS e05,--e5
  '''' AS e06,--e6
  '''' AS e07,--e7
  '''' AS e08,
  '''' AS e09,
  ''32'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_CONDUCTED_COMMENT_TAG_S'' ), '''' ) AS e11,
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_COMMENT_IMPLEMENTATION'' ), '''' ) ) AS sortTag 
 ) UNION
(-- 酸素吸入手技
 SELECT
  ''実績詳細'' AS detail_id,
  ''VQ1'' AS sbt_key,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_PROCEDURE_CODE'' ), '''' ) AS e01,-- 項目コード
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_PROCEDURE_ATTR'' ), '''' ) AS e02,-- 項目属性
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_PROCEDURE_NAME'' ), '''' ) AS e03,-- 項目名称
  ''0000000.000'' AS e04,-- 数量
  ''0'' AS e05,-- 選択単位フラグ
  '''' AS e06,-- 単位コード
  '''' AS e07,-- 単位名称
  '''' AS e08,
  '''' AS e09,
  ''31'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_PROCEDURE_ATTR'' ), '''' ) AS e11,-- タグ名称
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_OXYGEN'' ), '''' ) ) AS sortTag 
 FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
  CROSS JOIN LATERAL json_array_elements ( ord.rst_treatment_info :: json ) oxy 
 WHERE
  oxy ->> ''treat_class'' = ''3'' 
  AND ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_PROCEDURE_FLAG'' ) = ''1'' 
	AND ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_SEND_FLAG'' ) = ''1'' 

 ) 
UNION

 (-- 酸素吸入
 SELECT
  ''実績詳細'' AS detail_id,
  ''VQ1'' AS sbt_key,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_CODE'' ), '''' ) AS e01,-- 項目コード
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_ATTR'' ), '''' ) AS e02,-- 項目属性
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_NAME'' ), '''' ) AS e03,-- 項目名称
  COALESCE ( to_char( TO_NUMBER( oxy ->> ''amount'', ''999999999.999'' ), ''FM0999999.990'' ), '''' ) AS e04,-- 数量
  ''1'' AS e05,-- 選択単位フラグ
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_UNIT'' ), '''' ) AS e06,-- 単位コード
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_UNIT'' ), '''' ) AS e07,-- 単位名称
  '''' AS e08,
  '''' AS e09,
  ''31'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_TAG'' ), '''' ) AS e11,-- タグ名称
  ( NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_OXYGEN'' ), '''' ) ) AS sortTag 
 FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
  CROSS JOIN LATERAL json_array_elements ( ord.rst_treatment_info :: json ) oxy 
 WHERE
  oxy ->> ''treat_class'' = ''3'' 

  AND ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_OXYGEN_SEND_FLAG'' ) = ''1'' 

 ) UNION
 (-- レセプトメモ
 SELECT
  ''実績詳細'' AS detail_id,
  '''' AS sbt_key,
  COALESCE ( mdd.in_hospital_cd_1, '''' ) AS e01,--コード
  COALESCE ( mdd.in_hospital_cd_2, ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_RECORD_ATTR'' ), '''' ) AS e02,
  COALESCE ( SUBSTRING ( mdd.dialysis_difficulty_name, 1, 25 ), '''' ) AS e03,--名
  ''0000000.000'' AS e04,
  ''0'' AS e05,
  '''' AS e06,
  '''' AS e07,
  '''' AS e08,
  '''' AS e09,
  ''33'' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_RECORD_TAG'' ), '''' ) AS e11,
  NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_RECORD'' ), '''' ) AS sortTag 
 FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
  CROSS JOIN LATERAL json_array_elements ( ord.addition_info :: json ) addi
  LEFT OUTER JOIN mst_addition AS mad ON mad.addition_cd = to_number( addi ->> ''cd'', ''9999999999'' )
  CROSS JOIN LATERAL json_array_elements ( mad.addition_tar_cd :: json ) addtr
  LEFT OUTER JOIN mst_dialysis_difficulty AS mdd ON mdd.dialysis_difficulty_cd = to_number( addtr ->> ''cd'', ''9999999999'' ) 
 WHERE
  mad.addition_cond = ''2'' 
  AND addi ->> ''is_enable'' = ''1'' 
  AND mad.addition_class = ''2'' 
 
  AND ( SELECT VALUE->>''memo_flg'' FROM sys_system_define WHERE ctl_no = 134 ) IS NOT NULL 
  AND ( SELECT VALUE->>''memo_flg'' FROM sys_system_define WHERE ctl_no = 134 ) <> ''0'' 

 )  UNION
 (-- 加算・管理料
 SELECT
  ''実績詳細'' AS detail_id,
  ''VAB'' AS sbt_key,
  COALESCE ( adt.in_hospital_cd_1, '''' ) AS e01,-- 項目コード
	COALESCE ( adt.in_hospital_cd_2, ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_RECEIPT_MEMO_ATTR'' ) ) AS e02,-- 項目属性
  COALESCE ( SUBSTRING ( adt.addition_name, 1, 25 ), '''' ) AS e03,-- 項目名称
  ''0000000.000'' AS e04,
  ''0'' AS e05,
  '''' AS e06,
  '''' AS e07,
  '''' AS e08,
  '''' AS e09,
  '''' AS e10,
  COALESCE ( ( SELECT VALUE FROM dialysis_item_send WHERE key2 = ''ITEM_RECEIPT_MEMO_TAG'' ), '''' ) AS e11,
  NULLIF ( ( SELECT VALUE FROM dialyis_item_sort WHERE key2 = ''ITEM_DISABLED_ADD'' ), '''' ) AS sortTag 
 FROM
(SELECT * FROM ord_main_restore ord WHERE ord_no= @ordNo  ORDER BY del_date desc limit 1) ord
	CROSS JOIN LATERAL json_array_elements ( ord.addition_info :: json ) addition
	LEFT OUTER JOIN mst_addition AS adt ON adt.addition_cd = TO_NUMBER( addition ->> ''cd'', ''999999999999'' )
 WHERE
  addition ->> ''is_enable'' = ''1''

 ) 
 ) all_cost 
WHERE
  all_cost.sortTag IS NOT NULL and
  all_cost.e01 IS NOT NULL AND all_cost.e01 <> ''''
order by all_cost.sortTag,all_cost.sbt_key
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）項目情報部', '2022-08-31 05:57:49.586',CURRENT_TIMESTAMP, '[{"sql_cd": -20, "field_name": "in_out", "replace_var": "@inOut"}, {"sql_cd": -79, "field_name": "dial_diff_cd", "replace_var": "@dial_diff_cd"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-666, 'WITH default_user_no AS (-- デフォルト利用者番号（透析実績用)
    SELECT
        COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS default_staff_cd 
    FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
    WHERE
        facility_cd = @facilityCd 
        AND is_del = ''0'' 
				-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=@key0
  -- add #7304 異なる連携の機能を組み合わせて使用するため ljg end	
        AND info ->> ''key1'' = ''FJI_COM_INFO'' 
        AND info ->> ''key2'' = ''DIAL_DEFAULT_USER_NO''
				LIMIT 1
    ),
    user_no_setting AS (-- 利用者番号出力設定（透析実績用）
    SELECT
        0 AS order_no,
        COALESCE ( NULLIF ( info ->> ''value'', '''' ), COALESCE ( NULLIF ( info ->> ''default_v'', '''' ), ''0'' ) ) AS setting 
    FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0'' 
				-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
	 AND COALESCE(info->>''key0'','''')=@key0
  -- add #7304 異なる連携の機能を組み合わせて使用するため ljg end	
        AND info ->> ''key1'' = ''FJI_COM_INFO'' 
        AND info ->> ''key2'' = ''DIAL_USER_NO_SETTING'' UNION
    SELECT
        1 AS order_no,
        ''0'' AS setting 
    ORDER BY
        order_no ASC 
        LIMIT 1 
    ),
    up_user_id_info AS (-- 版確定者
    SELECT
        0 AS order_no,
        NULLIF ( TO_CHAR( om.up_user_id, ''FM9999999999'' ), '''' ) AS staff_cd 
    FROM
        ord_main om 
    WHERE
        om.ord_no = @ordNo 
    ),
    staff_user_info AS (-- 担当医
    SELECT
        1 AS order_no,
        NULLIF ( staff ->> ''staff_cd'', '''' ) AS staff_cd 
    FROM
        pat_main pm
        CROSS JOIN LATERAL json_array_elements ( pm.charge_staff_info :: json ) staff 
    WHERE
        staff ->> ''is_main'' = ''1'' 
        AND pm.pat_id = @patId
    ),
		  mst_user_authenticator as (--常勤医
         select 1                                                  as no,
                (json_array_elements((mst.mst_user_authentication ->> ''data'')::json) ->>
                 (select (
                             case
                                 when 1 = (select treat_week from ord_main ord where ord.ord_no = @ordNo)
                                     then ''Mon''
                                 when 2 = (select treat_week from ord_main ord where ord.ord_no = @ordNo)
                                     then ''Tues''
                                 when 3 = (select treat_week from ord_main ord where ord.ord_no = @ordNo)
                                     then ''Wednes''
                                 when 4 = (select treat_week from ord_main ord where ord.ord_no = @ordNo)
                                     then ''Thurs''
                                 when 5 = (select treat_week from ord_main ord where ord.ord_no = @ordNo)
                                     then ''Fri''
                                 when 6 = (select treat_week from ord_main ord where ord.ord_no = @ordNo)
                                     then ''Satur''
                                 when 7 = (select treat_week from ord_main ord where ord.ord_no = @ordNo)
                                     then ''Sun''
                                 END) as aaa))::json ->> ''user_id'' as staff_cd
         from ord_main ord,
              mst_kur mst
         where ord.rst_kur_cd = mst.kur_cd
           and ord.ord_no = @ordNo
         UNION
         SELECT 3        AS no,
                default_staff_cd AS default_staff_cd
         from default_user_no
         order by no
         limit 1)	 
		
SELECT 
    COALESCE( NULLIF ( MAX ( CASE part WHEN ''comm'' THEN staff_cd ELSE'''' END ), '''' ))  as staff_cd_comm,
    COALESCE( NULLIF ( MAX ( CASE part WHEN ''data'' THEN staff_cd ELSE'''' END ), '''' ))  as staff_cd_data,
		(SELECT default_staff_cd FROM default_user_no)
FROM
(
    (-- 0：共通部 版確定者   
      SELECT ''comm'' AS part, staff_cd  FROM up_user_id_info WHERE ( SELECT setting FROM user_no_setting ) = ''0'' ) UNION   
     -- 1：共通部 担当医１
   -- 3：共通部 担当医１
    ( SELECT ''comm'' AS part, staff_cd FROM staff_user_info WHERE ( SELECT setting FROM user_no_setting ) = ''1'' LIMIT 1 OFFSET 0 ) UNION
		( SELECT ''comm'' AS part, staff_cd FROM up_user_id_info WHERE ( SELECT setting FROM user_no_setting ) = ''3'' LIMIT 1 OFFSET 0 ) UNION
     -- 2：共通部 担当医２
   -- 4：共通部 担当医２
    ( SELECT ''comm'' AS part, staff_cd FROM staff_user_info WHERE ( SELECT setting FROM user_no_setting ) = ''2''  LIMIT 1 OFFSET 1 ) UNION
		( SELECT ''comm'' AS part, staff_cd FROM up_user_id_info WHERE ( SELECT setting FROM user_no_setting ) = ''4''  LIMIT 1 OFFSET 0 ) UNION
	 -- 5：共通部：常勤医		
 		(select ''comm'' AS part,staff_cd from mst_user_authenticator WHERE ( SELECT setting FROM user_no_setting ) IN ( ''5'' )  LIMIT 1 OFFSET 0) UNION
    -- 0：内容部 版確定者
      SELECT ''data'' AS part, staff_cd  FROM up_user_id_info  WHERE ( SELECT setting FROM user_no_setting ) = ''0''  UNION
    -- 1：内容部 担当医１
    -- 3：内容部 担当医１
    ( SELECT ''data'' AS part, staff_cd FROM staff_user_info WHERE ( SELECT setting FROM user_no_setting ) IN ( ''1'', ''3'' )  LIMIT 1 OFFSET 0 ) UNION
    -- 2：内容部 担当医２
    -- 4：内容部 担当医２
    ( SELECT ''data'' AS part, staff_cd FROM staff_user_info WHERE ( SELECT setting FROM user_no_setting ) IN ( ''2'', ''4'' )  LIMIT 1 OFFSET 1 ) 
 		union
		-- 5：内容部：常勤医		
 		(select ''data'' AS part,staff_cd from mst_user_authenticator WHERE ( SELECT setting FROM user_no_setting ) IN ( ''5'' )  LIMIT 1 OFFSET 0)
    ) AS T', 2, '[{}]', '0', '{"applications": [4]}', NULL, '（実績）利用者番号出力設定', '2022-08-15 00:53:33.139',CURRENT_TIMESTAMP, NULL);

