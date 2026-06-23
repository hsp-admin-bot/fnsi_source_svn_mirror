UPDATE "ntss"."sys_data_set" 
SET "sql" = 'UPDATE pat_exam_main 
SET
  --exam_result_info = ''[]''
  --, ind_user_id = CASE ''@indUserId'' 
  ind_user_id = CASE ''@indUserId'' 
    WHEN '''' THEN ind_user_id 
    ELSE TO_NUMBER(''@indUserId'', ''FM999999999999999999'') 
    END
  , cop_order_no1 = CASE ''@copOrderNo1'' 
    WHEN '''' THEN cop_order_no1 
    ELSE TO_NUMBER(''@copOrderNo1'', ''FM999999999999999999'') 
    END
  , result_comment = CASE ''@resultComment'' 
    WHEN '''' THEN result_comment 
    ELSE ''@resultComment''
    END
  , result_exam_date = CASE ''@resultExamDate'' 
    WHEN '''' THEN result_exam_date 
    ELSE TO_TIMESTAMP(SUBSTR(''@resultExamDate'', 1, 12), ''YYYYMMDDHH24MI'') 
    END
  , up_date = CURRENT_TIMESTAMP 
WHERE
  is_del = ''0'' 
  AND exam_main_cd = @examMainCd'
  , "up_date" = CURRENT_TIMESTAMP
WHERE "sql_cd" = 2103;
