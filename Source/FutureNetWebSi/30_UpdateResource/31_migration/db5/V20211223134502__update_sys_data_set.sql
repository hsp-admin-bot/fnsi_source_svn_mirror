delete from "sys_data_set" where "sql_cd" in (4202,1004);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (4202, 'WITH infection_nec AS ( 
  SELECT
    A.infection_cd :: TEXT AS infection_cd
  FROM
    mst_infection A
    , ( 
      SELECT
        mss.facility_cd
        , ms.*
        , ROW_NUMBER() OVER () AS INDEX 
      FROM
        mst_selector mss 
        CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> ''items'') AS ms(code BIGINT, NAME TEXT) 
      WHERE
        facility_cd = ''@facilityCd'' 
        AND master_physical_name = ''mst_infection''
    ) ms 
  WHERE
    A.facility_cd = ms.facility_cd 
    AND A.infection_cd = ms.code 
    AND A.is_del = ''0'' 
    AND A.is_disp = ''1'' 
    AND ( A.in_hospital_cd_1 = ''@infectInfo.infectionCd'') 
  UNION 
  SELECT
    ''0'' AS infection_cd 
  ORDER BY
    infection_cd DESC LIMIT 1
) 
, infectionInfo AS ( 
  SELECT
    (idx - 1) AS idx
    , ms ->> ''infection_cd'' AS infection_cd 
    , CASE ''@infectInfo.infect'' WHEN ''1'' THEN ''1'' WHEN ''2'' THEN ''2'' ELSE ''0'' END AS infect
    , SUBSTR(COALESCE(NULLIF(''@infectInfo.examDate'', ''''), TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDD'')), 1, 8) AS exam_date
    , TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDD'') AS up_date
  FROM
    pat_main AS A 
    CROSS JOIN LATERAL jsonb_array_elements(A.infect_info ::jsonb) WITH ORDINALITY AS info(ms, idx)
    INNER JOIN infection_nec AS nec ON nec.infection_cd = ms ->> ''infection_cd'' AND ms ->> ''infection_cd'' != ''0'' 
  WHERE
    A.is_del = ''0'' 
    AND A.facility_cd = ''@facilityCd'' 
    AND A.pat_id = @patId 
  UNION 
  SELECT
    NULL AS idx
    , nec.infection_cd AS infection_cd 
    , CASE ''@infectInfo.infect'' WHEN ''1'' THEN ''1'' WHEN ''2'' THEN ''2'' ELSE ''0'' END AS infect
    , SUBSTR(COALESCE(NULLIF(''@infectInfo.examDate'', ''''), TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDD'')), 1, 8) AS exam_date
    , TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDD'') AS up_date
  FROM
    infection_nec AS nec 
  ORDER BY
    idx ASC NULLS LAST LIMIT 1
) 
UPDATE pat_main 
SET
  infect_info = jsonb_set( 
    COALESCE(infect_info, ''[]'') ::JSONB
    , CAST( 
      ( 
        SELECT
          ''{'' || COALESCE(idx, 999) || ''}'' 
        FROM
          infectionInfo
      ) AS TEXT []
    ) 
    , CAST( 
      ( 
        SELECT
          ''{"infect":"'' || infect || ''", "up_date":"'' || up_date || ''", "exam_date":"'' || exam_date || ''", "infection_cd":'' || infection_cd || ''}'' 
        FROM
          infectionInfo
      ) AS JSONB
    ) ::JSONB
  ) 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)CSIの患者プロファイル', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1004, 'SELECT
  array_to_json(ARRAY_AGG(T.col)) AS addition_info
FROM
  ( 
    SELECT
       json_build_object(''is_enable'', ''1'', ''reg_date'', CURRENT_TIMESTAMP, ''cd'', A.addition_cd) AS col
    FROM
      mst_addition A 
      , ( 
        SELECT
          mss.facility_cd
          , ms.*
          , ROW_NUMBER() OVER () AS INDEX 
        FROM
          mst_selector mss 
          CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> ''items'') AS ms(code BIGINT, NAME TEXT) 
        WHERE
          facility_cd = @facilityCd 
          AND master_physical_name = ''mst_addition'' 
      ) ms 
    WHERE
      A.facility_cd = ms.facility_cd 
      AND A.addition_cd = ms.code 
      AND A.is_del = ''0'' 
      AND A.is_disp = ''1'' 
    ORDER BY
      ms.INDEX
  ) AS T', 2, '[{}]', '0', '{"applications": [4]}', NULL, '外部連携用の[患者基本情報→加算情報]デフォルト値の取得', '2020-05-25 18:21:40.841', '2021-11-24 09:13:17.577', NULL);
