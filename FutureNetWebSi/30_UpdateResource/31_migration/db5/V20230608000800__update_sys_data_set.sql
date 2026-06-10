DELETE FROM "ntss"."sys_data_set" WHERE sql_cd = 7402;

DELETE FROM "ntss"."sys_data_set" WHERE sql_cd = 7401;
DELETE FROM "ntss"."sys_data_set" WHERE sql_cd = 7403;
DELETE FROM "ntss"."sys_data_set" WHERE sql_cd = 7404;
DELETE FROM "ntss"."sys_data_set" WHERE sql_cd = 7405;
DELETE FROM "ntss"."sys_data_set" WHERE sql_cd = 7406;
DELETE FROM "ntss"."sys_data_set" WHERE sql_cd = 7407;



INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7402, 'INSERT INTO pat_exam_main (
  pat_id,
  facility_cd,
  ord_no,
  fn_pat_id,
  reg_exam_date,
  reg_order_class,
  exam_status,
  order_comment,
  order_exam_set_info,
  exam_order_info,
  order_label_info,
  data_gen_class,
  result_exam_date,
  result_comment,
  exam_result_info,
  cop_order_no1,
  cop_order_no2,
  is_lock,
  ind_user_id,
  is_del,
  reg_date,
  reg_staff,
  up_date,
  up_staff,
  is_order,
  exam_week,
  exam_from,
  exam_to,
  exam_pattern 
)
VALUES
  (
    @patId,
    ''@facilityCd'',
  CASE
      ''@ordNo'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@ordNo'', ''999999999'' ) 
    END,
    NULLIF ( ''@fnPatId'', '''' ),
  CASE
      ''@regExamDate_Date'' 
      WHEN '''' THEN
      CURRENT_TIMESTAMP ELSE to_timestamp( ''@regExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'' ) 
    END,
  CASE
      ''@regOrderClass'' 
      WHEN '''' THEN NULL
			WHEN ''1'' THEN ''1''
			WHEN ''2'' THEN ''2''
      ELSE ''0''
      END,
    NULLIF ( ''@examStatus'', '''' ),
    NULLIF ( ''@orderComment'', '''' ),
    ''@orderExamSetInfoValue'',
    ''@examOrderInfoValue'',
    ''@orderLabelInfoValue'',
    NULLIF ( ''@dataGenClass'', '''' ),
  CASE
      ''@resultExamDate_Date'' 
      WHEN '''' THEN
      NULL ELSE to_timestamp( ''@resultExamDate_Date'', ''yyyy-MM-dd hh24:mi:ss'' ) 
    END,
    NULLIF ( ''@resultComment'', '''' ),
    ''@examResultInfoValue'',
  CASE
      ''@copOrderNo1'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@copOrderNo1'', ''999999999'' ) 
    END,
  CASE
      ''@copOrderNo2'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@copOrderNo2'', ''999999999'' ) 
      END,
    NULLIF ( ''@isLock'', '''' ),
  CASE
      ''@indUserId'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@indUserId'', ''999999999'' ) 
    END,
    ''0'',
    CURRENT_TIMESTAMP,
  CASE
      ''@regStaff'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@regStaff'', ''999999999'' ) 
    END,
    CURRENT_TIMESTAMP,
  CASE
      ''@upStaff'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@upStaff'', ''999999999'' ) 
    END,
    NULLIF ( ''@isOrder'', '''' ),
  CASE
      ''@examWeek'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@examWeek'', ''999999999'' ) 
    END,
  CASE
      ''@examFrom'' 
      WHEN '''' THEN
      NULL ELSE to_timestamp( ''@examFrom'', ''yyyymmddhh24miss'' ) 
      END,
  CASE
      ''@examTo'' 
      WHEN '''' THEN
      NULL ELSE to_timestamp( ''@examTo'', ''yyyymmddhh24miss'' ) 
      END,
  CASE
      ''@examPattern'' 
      WHEN '''' THEN
      NULL ELSE to_number( ''@examPattern'', ''999999999'' ) 
    END 
  )', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の検査結果(INSERT)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);

INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7401, 'WITH regOrdClass_tbl AS (
  SELECT
    CASE @regOrderClass
    WHEN ''1'' THEN ''1''
		WHEN ''2'' THEN ''2''
		ELSE ''0''
		END AS regOrdClass
)
SELECT
    exam_main_cd,
    pat_id,
    facility_cd,
    ord_no,
    fn_pat_id,
    to_char( reg_exam_date, ''yyyy-MM-dd hh24:mi:ss'' ) AS reg_exam_date,
    reg_order_class,
    exam_status,
    order_comment,
    order_exam_set_info,
    exam_order_info,
    order_label_info,
    data_gen_class,
    to_char( result_exam_date, ''yyyy-MM-dd hh24:mi:ss'' ) AS result_exam_date,
    result_comment,
    exam_result_info,
    cop_order_no1,
    cop_order_no2,
    is_lock,
    ind_user_id,
    is_del,
    reg_date,
    reg_staff,
    up_date,
    up_staff,
    is_order,
    exam_week,
    to_char( exam_from, ''yyyymmddhh24miss'' ) AS exam_from,
    to_char( exam_to, ''yyyymmddhh24miss'' ) AS exam_to,
    exam_pattern,
    (
    SELECT
        (
            COALESCE ( MAX ( TO_NUMBER( COALESCE ( NULLIF ( RESULT ->> ''disp_order'', '''' ), ''0'' ), ''99999'' ) ), 0 ) + 1 
        ) AS next_disp_order 
    FROM
        pat_exam_main exam
        CROSS JOIN LATERAL json_array_elements ( exam.exam_result_info :: json ) RESULT 
    WHERE
        exam.exam_main_cd = pat_exam_main.exam_main_cd 
    ) AS next_disp_order 
FROM
    pat_exam_main,
		regOrdClass_tbl 
WHERE
    is_del = ''0'' 
    AND pat_id = @patId 
    AND facility_cd = @facilityCd
    AND reg_exam_date = to_timestamp(@regExamDate_Date, ''yyyy-MM-dd hh24:mi:ss'')
    AND reg_order_class = regOrdClass
		AND exam_status = ''1''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の検査結果(SELECT)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7403, 'UPDATE
  pat_exam_main 
SET
  exam_result_info = ''[]'',
	up_date = CURRENT_TIMESTAMP 
WHERE
    is_del = ''0'' 
    AND exam_main_cd = @examMainCd', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の検査結果(UPDATE)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7404, 'UPDATE
  pat_exam_main 
SET
  exam_result_info = ''[]'',
	up_date = CURRENT_TIMESTAMP 
WHERE
  is_del = ''0'' 
  AND exam_main_cd = @examMainCd', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の検査結果(検査結果情報クリア)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7405, 'WITH examData AS (
  SELECT
	  exam_class AS examClass,
		jlac10_cd AS mstJlac10Cd,
		normal_value_lower AS mstLower,
		normal_value_upper AS mstUpper,
		data_type AS mstDataType,
		unit AS mstUnit
	FROM
	  mst_exam_item 
	WHERE
	  exam_item_cd = ''@examResultInfo.itemCd''
),
comment1_tbl AS (
  SELECT
    0 AS order_no,
    CASE TRIM(ini_info ->> ''value'') WHEN '''' THEN NULLIF(TRIM(ini_info ->> ''default_v''), '''')
    ELSE TRIM(ini_info ->> ''value'') 
    END AS comment1_text 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd'' 
    AND COALESCE(ini_info->>''key0'','''') = ''@key0''
    AND TRIM(ini_info ->> ''key1'') = ''EXAMIN_COMMENT'' 
    AND TRIM(ini_info ->> ''key2'') = ''@examResultInfo.comCd1'' 
    AND '''' <> ''@examResultInfo.comCd1''
  UNION
  SELECT
    1 AS order_no,
    '''' AS comment1_text
  ORDER BY order_no ASC LIMIT 1
),
comment2_tbl AS (
  SELECT
    0 AS order_no,
    CASE TRIM(ini_info ->> ''value'') WHEN '''' THEN NULLIF(TRIM(ini_info ->> ''default_v''), '''')
    ELSE TRIM(ini_info ->> ''value'') 
    END AS comment2_text 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd'' 
    AND COALESCE(ini_info->>''key0'','''') = ''@key0''
    AND TRIM(ini_info ->> ''key1'') = ''EXAMIN_COMMENT'' 
    AND TRIM(ini_info ->> ''key2'') = ''@examResultInfo.comCd2'' 
    AND '''' <> ''@examResultInfo.comCd2''
  UNION
  SELECT
    1 AS order_no,
    '''' AS comment2_text
  ORDER BY order_no ASC LIMIT 1
),
freememo_tbl AS (
  SELECT
	  CASE WHEN comment1_text <> '''' AND comment2_text <> '''' THEN
		  comment1_text || '', '' || comment2_text
		ELSE
		  comment1_text || comment2_text
		END AS freememo
	FROM
	  comment1_tbl,
		comment2_tbl
)
UPDATE
  pat_exam_main 
SET 
	up_date = CURRENT_TIMESTAMP,
exam_result_info = 
    CASE ''@examResultInfoFlg'' 
    WHEN '''' THEN
      ''@examResultInfoValue''
    ELSE
      CASE WHEN ''@examResultInfo.comCd1'' <> '''' AND ''@examResultInfo.comCd2'' <> '''' THEN
        exam_result_info || (json_build_object(''com_cd'', ''@examResultInfo.comCd1, @examResultInfo.comCd2'', ''disp_order'', ''@nextDispOrder'', ''exam_class'', examData.examClass, ''freememo'', freememo, ''hl'', ''@examResultInfo.hl'', ''item_cd'', ''@examResultInfo.itemCd'', ''item_name'', ''@examResultInfo.itemName'', ''jlac10_cd'', mstJlac10Cd, ''lower'', mstLower, ''result'', ''@examResultInfo.result'', ''result_date'', to_char(CURRENT_TIMESTAMP, ''YYYY/MM/DD HH24:MI:SS''), ''type'', mstDataType, ''unit'', mstUnit, ''upper'', mstUpper))::jsonb
      ELSE
        exam_result_info || (json_build_object(''com_cd'', ''@examResultInfo.comCd1@examResultInfo.comCd2'', ''disp_order'', ''@nextDispOrder'', ''exam_class'', examData.examClass, ''freememo'', freememo, ''hl'', ''@examResultInfo.hl'', ''item_cd'', ''@examResultInfo.itemCd'', ''item_name'', ''@examResultInfo.itemName'', ''jlac10_cd'', mstJlac10Cd, ''lower'', mstLower, ''result'', ''@examResultInfo.result'', ''result_date'', to_char(CURRENT_TIMESTAMP, ''YYYY/MM/DD HH24:MI:SS''), ''type'', mstDataType, ''unit'', mstUnit, ''upper'', mstUpper))::jsonb
      END
   END 
FROM
  examData,
	freememo_tbl
WHERE
  is_del = ''0'' 
  AND exam_main_cd = @examMainCd
	AND @item_cd = ''0''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の検査結果(検査結果情報更新)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, '[{"sql_cd": 7407, "field_name": "item_cd", "replace_var": "@item_cd"}]');
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7406, 'WITH examData AS (
  SELECT
    exam_class AS examClass,
    jlac10_cd AS mstJlac10Cd,
    normal_value_lower AS mstLower,
    normal_value_upper AS mstUpper,
    data_type AS mstDataType,
    unit AS mstUnit
  FROM
    mst_exam_item 
  WHERE
    exam_item_cd = ''@examResultInfo.itemCd''
),
comment1_tbl AS (
  SELECT
    0 AS order_no,
    CASE TRIM(ini_info ->> ''value'') WHEN '''' THEN NULLIF(TRIM(ini_info ->> ''default_v''), '''')
    ELSE TRIM(ini_info ->> ''value'') 
    END AS comment1_text 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd'' 
    AND COALESCE(ini_info->>''key0'','''') = ''@key0''
    AND TRIM(ini_info ->> ''key1'') = ''EXAMIN_COMMENT'' 
    AND TRIM(ini_info ->> ''key2'') = ''@examResultInfo.comCd1'' 
    AND '''' <> ''@examResultInfo.comCd1''
  UNION
  SELECT
    1 AS order_no,
    '''' AS comment1_text
  ORDER BY order_no ASC LIMIT 1
),
comment2_tbl AS (
  SELECT
    0 AS order_no,
    CASE TRIM(ini_info ->> ''value'') WHEN '''' THEN NULLIF(TRIM(ini_info ->> ''default_v''), '''')
    ELSE TRIM(ini_info ->> ''value'') 
    END AS comment2_text 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd'' 
    AND COALESCE(ini_info->>''key0'','''') = ''@key0''
    AND TRIM(ini_info ->> ''key1'') = ''EXAMIN_COMMENT'' 
    AND TRIM(ini_info ->> ''key2'') = ''@examResultInfo.comCd2'' 
    AND '''' <> ''@examResultInfo.comCd2''
  UNION
  SELECT
    1 AS order_no,
    '''' AS comment2_text
  ORDER BY order_no ASC LIMIT 1
),
freememo_tbl AS (
  SELECT
    CASE WHEN comment1_text <> '''' AND comment2_text <> '''' THEN
      comment1_text || '', '' || comment2_text
    ELSE
      comment1_text || comment2_text
    END AS freememo
  FROM
    comment1_tbl,
    comment2_tbl
),
oldJson_tbl AS (
   SELECT
     oldJson
   FROM
     pat_exam_main
     CROSS JOIN jsonb_array_elements(exam_result_info) AS oldJson
   WHERE
     exam_main_cd = @examMainCd
     AND oldJson->>''item_cd'' = ''@examResultInfo.itemCd''
),
newJson_tbl AS (
  SELECT
    CASE WHEN ''@examResultInfo.comCd1'' <> '''' AND ''@examResultInfo.comCd2'' <> '''' THEN
      json_build_object(''com_cd'', ''@examResultInfo.comCd1, @examResultInfo.comCd2'', ''disp_order'', oldJson->>''disp_order'', ''exam_class'', examData.examClass, ''freememo'', freememo, ''hl'', ''@examResultInfo.hl'', ''item_cd'', ''@examResultInfo.itemCd'', ''item_name'', ''@examResultInfo.itemName'', ''jlac10_cd'', mstJlac10Cd, ''lower'', mstLower, ''result'', ''@examResultInfo.result'', ''result_date'', to_char(CURRENT_TIMESTAMP, ''YYYY/MM/DD HH24:MI:SS''), ''type'', mstDataType, ''unit'', mstUnit, ''upper'', mstUpper)
    ELSE
      json_build_object(''com_cd'', ''@examResultInfo.comCd1@examResultInfo.comCd2'', ''disp_order'', oldJson->>''disp_order'', ''exam_class'', examData.examClass, ''freememo'', freememo, ''hl'', ''@examResultInfo.hl'', ''item_cd'', ''@examResultInfo.itemCd'', ''item_name'', ''@examResultInfo.itemName'', ''jlac10_cd'', mstJlac10Cd, ''lower'', mstLower, ''result'', ''@examResultInfo.result'', ''result_date'', to_char(CURRENT_TIMESTAMP, ''YYYY/MM/DD HH24:MI:SS''), ''type'', mstDataType, ''unit'', mstUnit, ''upper'', mstUpper)
    END AS resultJson
 FROM 
   examData
  , freememo_tbl
  , oldJson_tbl
)
UPDATE
  pat_exam_main
SET
  exam_result_info = 
    CASE ''@examResultInfo.itemCd'' 
    WHEN '''' THEN
       ''@examResultInfoValue''
     ELSE
       CASE WHEN exam_result_info IS NOT NULL AND exam_result_info <> ''[]'' THEN
         (SELECT jsonb_agg((exam_result_info->>(idx-1)::INT)::json) FROM pat_exam_main CROSS JOIN jsonb_array_elements(exam_result_info) WITH ORDINALITY arr(j, idx) WHERE exam_main_cd = @examMainCd AND j->>''item_cd'' <> ''@examResultInfo.itemCd'')::jsonb || (SELECT resultJson FROM newJson_tbl)::jsonb
       ELSE
         exam_result_info
       END
  END,
  up_date = CURRENT_TIMESTAMP
WHERE
  is_del = ''0''
	AND exam_main_cd = @examMainCd
  AND @item_cd != ''0''  ', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の検査結果(SELECT)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, '[{"sql_cd": 7407, "field_name": "item_cd", "replace_var": "@item_cd"}]');
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7407, 'SELECT
 COALESCE ( NULLIF ( info ->> ''item_cd'', '''' )) AS item_cd
FROM
	pat_exam_main as pem
	CROSS JOIN LATERAL json_array_elements (pem.exam_result_info :: json ) info 
WHERE
	pat_id = @patId 
	AND facility_cd = @facilityCd
	AND is_del = ''0''
	AND info ->> ''item_cd'' = @examResultInfo.itemCd :: text
	AND reg_exam_date = to_timestamp( @regExamDate_Date, ''yyyy-MM-dd hh24:mi:ss'' )
	AND reg_order_class = @regOrderClass
	union
select ''0'' as item_cd
order by item_cd desc nulls last
limit 1', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の検査結果(SELECT)', '2022-08-08 16:13:46.858', CURRENT_TIMESTAMP, NULL);



