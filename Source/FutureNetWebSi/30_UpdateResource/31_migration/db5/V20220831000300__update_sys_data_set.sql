DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (7206);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7206, 'WITH infectionInfo AS ( 
  SELECT
    (idx - 1) AS idx
    , ms ->> ''infection_cd'' AS infection_cd 
    ,CASE ''@infectInfo.infect'' 
        WHEN '''' THEN 0 
        WHEN ''不明'' THEN 0 
        ELSE TO_NUMBER(''@infectInfo.infect'', ''FM9999999999999999'') 
       END   AS infect
    , SUBSTR(COALESCE(TO_CHAR(TO_TIMESTAMP(NULLIF(''@infectInfo.examDate_Date'', ''''), ''yyyy-MM-dd hh24:mi:ss''), ''yyyyMMdd''), TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDD'')), 1, 8) AS exam_date
    , TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDD'') AS up_date
  FROM
    pat_main AS A 
    CROSS JOIN LATERAL jsonb_array_elements(A.infect_info ::jsonb) WITH ORDINALITY AS info(ms, idx)
  WHERE
    A.is_del = ''0'' 
    AND A.facility_cd = ''@facilityCd'' 
    AND A.pat_id = @patId 
    AND ms ->> ''infection_cd'' :: TEXT = ''@infectInfo.infectionCd''
) 
UPDATE pat_main 
SET infect_info = jsonb_set (
  COALESCE ( infect_info, ''[]'' ) :: JSONB,
  CAST ( ( SELECT ''{'' ||  idx || ''}'' FROM infectionInfo ) AS TEXT [] ),
  CAST ( ( SELECT ''{"infect":"'' || infect || ''", "up_date":"'' || up_date || ''", "exam_date":"'' || exam_date || ''", "infection_cd":'' || infection_cd || ''}'' FROM infectionInfo ) AS JSONB ) :: JSONB 
) 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(感染症情報)', '2020-05-25 18:21:40.841',CURRENT_TIMESTAMP, NULL);
