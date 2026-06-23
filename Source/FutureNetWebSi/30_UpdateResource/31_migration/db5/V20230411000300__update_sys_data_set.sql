DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (9208, 7409);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9208, 'WITH chg_cnt AS (
SELECT
 count(infect_info) AS chgCnt
FROM
  pat_main
	CROSS JOIN jsonb_array_elements(infect_info) infectJobj
WHERE
  facility_cd = ''@facilityCd'' 
	AND pat_id = @patId
	AND infectJobj->>''infection_cd'' = ''@infectCd''
	AND is_del = ''0''
),
chg_rec AS (
  SELECT
 infectJobj AS chgJobj
FROM
  pat_main
	CROSS JOIN jsonb_array_elements(infect_info) infectJobj
WHERE
  facility_cd = ''@facilityCd'' 
	AND pat_id = @patId
	AND infectJobj->>''infection_cd'' = ''@infectCd''
	AND is_del = ''0''
),
keep_cnt AS (
  SELECT
 count(infectJobj) AS keepcnt
FROM
  pat_main
	CROSS JOIN jsonb_array_elements(infect_info) infectJobj
WHERE
  facility_cd = ''@facilityCd'' 
	AND pat_id = @patId
	AND infectJobj->>''infection_cd'' != ''@infectCd''
	AND is_del = ''0''
),
mstSet_1 AS (
  SELECT
 B.facility_setting_no As facility_setting_no,
 B.setting_name As setting_name,
 (CASE 
  WHEN A.facility_setting_no IS NULL THEN B.default_value
  ELSE A.value
  END) As value
FROM ntss.mst_facility_setting A
RIGHT OUTER JOIN ntss.sys_facility_setting B
ON A.facility_setting_no = B.facility_setting_no
AND 
  A.facility_cd = ''@facilityCd'' 
WHERE 
  B.setting_name = ''感染症検査結果反映時 陽性結果値群''
),
mstSet_2 AS (
  SELECT
 B.facility_setting_no As facility_setting_no,
 B.setting_name As setting_name,
 (CASE 
  WHEN A.facility_setting_no IS NULL THEN B.default_value
  ELSE A.value
  END) As value
FROM ntss.mst_facility_setting A
RIGHT OUTER JOIN ntss.sys_facility_setting B
ON A.facility_setting_no = B.facility_setting_no
AND 
  A.facility_cd = ''@facilityCd'' 
WHERE 
  B.setting_name = ''感染症検査結果反映時 陰性結果値群''
),
infect_tbl AS (
  SELECT
	  CASE WHEN EXISTS (SELECT value FROM mstSet_1 WHERE value like ''%@examResultInfo.result%'') THEN
		  ''2''
		ELSE 
		  CASE WHEN EXISTS (SELECT value FROM mstSet_2 WHERE value like ''%@examResultInfo.result%'') THEN
		    ''1''
		  ELSE
			  ''0''
			END
		END AS infect
),
jsonb_tbl AS (
  SELECT
	  ''[]'' || json_build_object(''infect'', (SELECT infect FROM infect_tbl), ''up_date'', to_char(CURRENT_DATE, ''yyyymmdd''), ''exam_date'', LEFT(''@regExamDate'', 8), ''infection_cd'', ''@infectCd'')::jsonb
	AS newJsonb
)
UPDATE pat_main
SET
  infect_info = 
    CASE WHEN infect_info IS NULL OR infect_info = ''[]'' THEN
      newJsonb
    ELSE
      CASE WHEN chgCnt = 0 THEN
        infect_info || newJsonb
      ELSE
	      CASE WHEN keepCnt = 0 THEN
		      newJsonb
		    ELSE
          ((SELECT jsonb_agg(infectJobj) FROM pat_main CROSS JOIN jsonb_array_elements(infect_info) infectJobj WHERE facility_cd = ''@facilityCd'' AND pat_id = @patId AND infectJobj->>''infection_cd'' != ''@infectCd'') || newJsonb)::jsonb
		    END
      END
    END,
  up_date = CURRENT_TIMESTAMP
FROM
  infect_tbl,
	chg_cnt,
	jsonb_tbl,
	keep_cnt
WHERE
  facility_cd = ''@facilityCd'' 
	AND pat_id = @patId', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECの検査結果(検査結果情報更新)', '2023-04-10 23:29:43.109', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7409, 'WITH chg_cnt AS (
SELECT
 count(infect_info) AS chgCnt
FROM
  pat_main
	CROSS JOIN jsonb_array_elements(infect_info) infectJobj
WHERE
  facility_cd = ''@facilityCd'' 
	AND pat_id = @patId
	AND infectJobj->>''infection_cd'' = ''@infectCd''
	AND is_del = ''0''
),
chg_rec AS (
  SELECT
 infectJobj AS chgJobj
FROM
  pat_main
	CROSS JOIN jsonb_array_elements(infect_info) infectJobj
WHERE
  facility_cd = ''@facilityCd'' 
	AND pat_id = @patId
	AND infectJobj->>''infection_cd'' = ''@infectCd''
	AND is_del = ''0''
),
keep_cnt AS (
  SELECT
 count(infectJobj) AS keepcnt
FROM
  pat_main
	CROSS JOIN jsonb_array_elements(infect_info) infectJobj
WHERE
  facility_cd = ''@facilityCd'' 
	AND pat_id = @patId
	AND infectJobj->>''infection_cd'' != ''@infectCd''
	AND is_del = ''0''
),
mstSet_1 AS (
  SELECT
 B.facility_setting_no As facility_setting_no,
 B.setting_name As setting_name,
 (CASE 
  WHEN A.facility_setting_no IS NULL THEN B.default_value
  ELSE A.value
  END) As value
FROM ntss.mst_facility_setting A
RIGHT OUTER JOIN ntss.sys_facility_setting B
ON A.facility_setting_no = B.facility_setting_no
AND 
  A.facility_cd = ''@facilityCd'' 
WHERE 
  B.setting_name = ''感染症検査結果反映時 陽性結果値群''
),
mstSet_2 AS (
  SELECT
 B.facility_setting_no As facility_setting_no,
 B.setting_name As setting_name,
 (CASE 
  WHEN A.facility_setting_no IS NULL THEN B.default_value
  ELSE A.value
  END) As value
FROM ntss.mst_facility_setting A
RIGHT OUTER JOIN ntss.sys_facility_setting B
ON A.facility_setting_no = B.facility_setting_no
AND 
  A.facility_cd = ''@facilityCd'' 
WHERE 
  B.setting_name = ''感染症検査結果反映時 陰性結果値群''
),
infect_tbl AS (
  SELECT
	  CASE WHEN EXISTS (SELECT value FROM mstSet_1 WHERE value like ''%@examResultInfo.result%'') THEN
		  ''2''
		ELSE 
		  CASE WHEN EXISTS (SELECT value FROM mstSet_2 WHERE value like ''%@examResultInfo.result%'') THEN
		    ''1''
		  ELSE
			  ''0''
			END
		END AS infect
),
jsonb_tbl AS (
  SELECT
	  ''[]'' || json_build_object(''infect'', (SELECT infect FROM infect_tbl), ''up_date'', to_char(CURRENT_DATE, ''yyyymmdd''), ''exam_date'', LEFT(''@regExamDate'', 8), ''infection_cd'', ''@infectCd'')::jsonb
	AS newJsonb
)
UPDATE pat_main
SET
  infect_info = 
    CASE WHEN infect_info IS NULL OR infect_info = ''[]'' THEN
      newJsonb
    ELSE
      CASE WHEN chgCnt = 0 THEN
        infect_info || newJsonb
      ELSE
	      CASE WHEN keepCnt = 0 THEN
		      newJsonb
		    ELSE
          ((SELECT jsonb_agg(infectJobj) FROM pat_main CROSS JOIN jsonb_array_elements(infect_info) infectJobj WHERE facility_cd = ''@facilityCd'' AND pat_id = @patId AND infectJobj->>''infection_cd'' != ''@infectCd'') || newJsonb)::jsonb
		    END
      END
    END,
  up_date = CURRENT_TIMESTAMP
FROM
  infect_tbl,
	chg_cnt,
	jsonb_tbl,
	keep_cnt
WHERE
  facility_cd = ''@facilityCd'' 
	AND pat_id = @patId', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)NECの検査結果(検査結果情報更新)', '2023-04-10 23:29:43.109', CURRENT_TIMESTAMP, NULL);
