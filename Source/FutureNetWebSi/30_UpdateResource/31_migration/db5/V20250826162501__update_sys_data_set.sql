DELETE FROM ntss.sys_data_set
WHERE sql_cd = -1201000;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1201000, 'WITH dialysis_date AS (
    SELECT
		REGEXP_REPLACE(MIN(info ->> ''period_start_date'')::text,''[^0-9]'', '''', ''g'') AS dialysis_start
	FROM 
	(
		SELECT jsonb_array_elements(in_out_visit_history_info) AS info
		FROM pat_unique 
		WHERE
			pat_id = @patId
			AND is_del = ''0''
	) AS history
	WHERE
		info ->> ''move_in_out'' = ''1''
		AND info ->> ''period_start_day'' IS NOT NULL
)
, hospital_date AS (
	SELECT
		REGEXP_REPLACE(MAX(info ->> ''period_start_date'')::text,''[^0-9]'', '''', ''g'') AS hospital_start
	FROM 
	(
		SELECT jsonb_array_elements(in_out_visit_history_info) AS info
		FROM pat_unique 
		WHERE
			pat_id = @patId
			AND is_del = ''0''
	) AS history
	WHERE 
		((info ->> ''move_in_out'' = ''1'' AND info ->> ''from_facility'' IS NULL)
		OR info ->> ''move_in_out'' = ''2'')
		AND info ->> ''period_start_date'' IS NOT NULL
)
SELECT 
	dialysis_date.dialysis_start AS dialysis_start --透析導入日　YYYYMMDD
	, hospital_date.hospital_start AS hospital_start --当院開始日　YYYYMMDD
FROM dialysis_date, hospital_date', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '患者診療情報', '2025-05-23 17:36:09.485', CURRENT_TIMESTAMP, NULL);