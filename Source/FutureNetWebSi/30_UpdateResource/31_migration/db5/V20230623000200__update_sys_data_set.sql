DELETE FROM "ntss"."sys_data_set" WHERE sql_cd = 7401;
DELETE FROM "ntss"."sys_data_set" WHERE sql_cd = 7402;
DELETE FROM "ntss"."sys_data_set" WHERE sql_cd = 7407;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7401, 'WITH regOrdClass_tbl AS (
  SELECT
    CASE @regOrderClass
    WHEN ''1'' THEN ''1''
		WHEN ''2'' THEN ''2''
		ELSE ''0''
		END AS regOrdClass
),
chectDate AS (
	SELECT
	CASE
		WHEN
			@regExamDate ~ ''^([0-9]?[0-9]*|[0-9]+)$'' = ''t'' THEN
			CASE
					WHEN length( @regExamDate ) = 12 THEN
					true ELSE false 
				END 
			ELSE false 
			END AS checkResult )
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
		regOrdClass_tbl,
		chectDate
WHERE
    is_del = ''0'' 
    AND pat_id = @patId 
    AND facility_cd = @facilityCd
    AND case when chectDate.checkResult then reg_exam_date = to_timestamp(@regExamDate, ''yyyymmddhh24MIss'')
		else 1/(select 0) =1 end
    AND reg_order_class = regOrdClass
		AND exam_status = ''1''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の検査結果(SELECT)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);

INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7402, 'INSERT INTO pat_exam_main (
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
      ''@regExamDate'' 
      WHEN '''' THEN
      CURRENT_TIMESTAMP ELSE to_timestamp( ''@regExamDate'', ''yyyymmddhh24MIss'' ) 
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
      ''@resultExamDate'' 
      WHEN '''' THEN
      NULL ELSE to_timestamp( ''@resultExamDate'', ''yyyymmddhh24MIss'' ) 
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
  
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7407, 'SELECT
 COALESCE ( NULLIF ( info ->> ''item_cd'', '''' )) AS item_cd
FROM
	pat_exam_main as pem
	CROSS JOIN LATERAL json_array_elements (pem.exam_result_info :: json ) info 
WHERE
	pat_id = @patId 
	AND facility_cd = @facilityCd
	AND is_del = ''0''
	AND info ->> ''item_cd'' = @examResultInfo.itemCd :: text
	AND reg_exam_date = to_timestamp( @regExamDate, ''yyyymmddhh24miss'' )
	AND reg_order_class = @regOrderClass
	union
select ''0'' as item_cd
order by item_cd desc nulls last
limit 1
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の検査結果(SELECT)', '2022-08-08 16:13:46.858', CURRENT_TIMESTAMP, NULL);
