DELETE FROM "ntss"."sys_data_set" WHERE sql_cd = 7406;
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
	data_gen_class=''2'',
  up_date = CURRENT_TIMESTAMP
WHERE
  is_del = ''0''
	AND exam_main_cd = @examMainCd
  AND @item_cd != ''0''  ', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の検査結果(SELECT)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, '[{"sql_cd": 7407, "field_name": "item_cd", "replace_var": "@item_cd"}]');

