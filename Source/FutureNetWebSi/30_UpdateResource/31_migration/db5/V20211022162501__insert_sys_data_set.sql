delete from "sys_data_set" where "sql_cd" in (-455,-456,-457);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-457, 'WITH pat_info AS (SELECT
	staff_info->>''ctl_no'' AS ctl_no,
	staff_info->>''staff_cd'' AS staff_cd,
	staff_info->>''is_main'' AS is_main,
	staff_info->>''is_charge'' AS is_charge,
	staff_info->>''is_puncture'' AS is_puncture
FROM
	pat_main AS pat 
	CROSS JOIN LATERAL json_array_elements ( pat.charge_staff_info :: json ) staff_info
WHERE
	pat.pat_id = @patId
ORDER BY 
  CASE WHEN staff_info->>''is_main'' = ''1'' THEN 0  WHEN staff_info->>''is_charge'' = ''1'' THEN 1 ELSE 2 END ASC, 
	staff_info->>''ctl_no'' ASC
LIMIT 1)
SELECT CASE WHEN staff_cd IS NULL THEN ''001'' ELSE staff_cd END AS staff_cd
FROM (SELECT (SELECT staff_cd FROM pat_info) AS staff_cd ) AS T01', 2, '[{}]', '0', '{"applications": [4]}', NULL, 'Medicom受付情報の「医師１」', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', '[{"sql_cd": -300001, "field_name": "hosp_pat_id", "replace_var": "@hospPatId"}, {"sql_cd": -300001, "field_name": "severity_cd", "replace_var": "@severityCd"}, {"sql_cd": -300001, "field_name": "transport_cd", "replace_var": "@transportCd"}]');
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-456, 'WITH ord_info AS (
SELECT
	CASE WHEN rst_weight_info ->> ''weight_before_date'' IS NULL THEN
    CAST(rst_start_date as TIMESTAMP)
  ELSE 
	  CAST(rst_weight_info ->> ''weight_before_date'' as TIMESTAMP)
  END AS accept_date
	, course.in_hospital_cd_1 AS in_hospital_cd
FROM
	ord_main AS ord
  LEFT JOIN mst_course AS course ON ord.rst_course_cd = course.course_cd AND ord.facility_cd = course.facility_cd
WHERE
	ord.ord_no = @ordNo)
SELECT 
  TO_CHAR(accept_date, ''YYYY'') AS date_year, 
  TO_CHAR(accept_date, ''MMDD'') AS date_month_day, 
  TO_CHAR(accept_date, ''HH24MISS'') AS date_time,
	CASE WHEN in_hospital_cd IS NULL THEN ''001'' ELSE in_hospital_cd END AS in_hospital_cd
FROM ord_info', 2, '[{}]', '0', '{"applications": [4]}', NULL, 'Medicom受付情報の「受付処理日時、受診科１」', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', '[{"sql_cd": -300001, "field_name": "hosp_pat_id", "replace_var": "@hospPatId"}, {"sql_cd": -300001, "field_name": "severity_cd", "replace_var": "@severityCd"}, {"sql_cd": -300001, "field_name": "transport_cd", "replace_var": "@transportCd"}]');
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-455, 'SELECT
   CASE 
    WHEN severity_name IS NOT NULL 
    AND transport_name IS NOT NULL 
      THEN severity_name || ''、'' || transport_name
    WHEN severity_name IS NOT NULL 
      THEN transport_name
    WHEN transport_name IS NOT NULL 
      THEN transport_name
    ELSE '''' 
    END AS comment 
FROM
  ( 
    SELECT
      ( 
        SELECT
          severity.severity_name 
        FROM
          mst_severity AS severity 
        WHERE
          severity.severity_cd = @severityCd
      ) AS severity_name
      , ( 
        SELECT
          transport.transport_name 
        FROM
          mst_transport AS transport 
        WHERE
          transport.transport_cd = @transportCd
      ) AS transport_name
  ) AS T01
', 2, '[{}]', '0', '{"applications": [4]}', NULL, 'Medicom受付情報の「コメント」', '2020-05-13 11:51:04', '2020-05-13 11:51:10.001', '[{"sql_cd": -300001, "field_name": "severity_cd", "replace_var": "@severityCd"}, {"sql_cd": -300001, "field_name": "transport_cd", "replace_var": "@transportCd"}]');
