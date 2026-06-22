DELETE FROM sys_data_set WHERE sql_cd IN 
(-1104000,-1104001);

INSERT INTO sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1104001, '-- SQL: -1104001 begin
WITH expanded_candidates AS (
  -- JSON配列を展開して優先順位付きスタッフIDリストを得る
  SELECT
    value::text AS candidate_user_id,
    ordinality AS priority
  FROM jsonb_array_elements_text(@chargeUserIdJson::jsonb) WITH ORDINALITY
)
,ranked_user_id AS (
  -- 最初ユーザーIDが取れた行を1件だけ残す
  SELECT *
  FROM expanded_candidates
  WHERE candidate_user_id IS NOT NULL
  ORDER BY priority ASC
  LIMIT 1
)
,final AS (
  SELECT
    CONCAT(
	    mpu.in_hospital_cd_1,
	    CASE 
	        WHEN @bedName::text = '''' THEN RPAD('''', 40, '' '')
	        ELSE @bedName::text
	    END
	) AS reservation_code_comment,
    @appointmentDate::text AS appointment_date,
    @sequenceNo::text AS sequence_no
  FROM ranked_user_id r
  LEFT JOIN mst_personal_user mpu
    ON mpu.user_id::text = r.candidate_user_id
  RIGHT JOIN (SELECT 1) dummy ON TRUE
)

SELECT * FROM final;
-- SQL: -1104001 end', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム　再来受付', '2025-05-20 10:20:41.403', CURRENT_TIMESTAMP, '[{"sql_cd": -1104000, "field_name": "bed_name", "replace_var": "@bedName"}, {"sql_cd": -1104000, "field_name": "appointment_date", "replace_var": "@appointmentDate"}, {"sql_cd": -1104000, "field_name": "sequence_no", "replace_var": "@sequenceNo"}, {"sql_cd": -1104004, "field_name": "charge_user_id_json", "replace_var": "@chargeUserIdJson"}]'::jsonb);
INSERT INTO sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1104000, '-- SQL: -1104000 begin
WITH select_ord_main AS(
SELECT 
    CASE 
        WHEN mbe.bed_name IS NULL THEN RPAD('' '', 40, '' '')
        ELSE REPLACE(mbe.bed_name, '','', ''_'')
    END AS bed_name
    ,to_char(
         to_timestamp(ord.treat_date || mkr.kur_standard_start_time , ''YYYYMMDDHH24MISS''),
         ''YYYY/MM/DD HH24:MI:SS''
       ) AS appointment_date
FROM
ord_main AS ord
	LEFT OUTER JOIN mst_bed AS mbe 
		ON mbe.bed_cd = ord.rst_bed_cd 
	LEFT OUTER JOIN mst_kur AS mkr 
		ON mkr.kur_cd = ord.ind_kur_cd 
where 
	ord.ord_no=@ordNo
    AND ord.facility_cd = @facilityCd 
)
,select_sequence_no as(
SELECT 
  COALESCE(save_2 ->> ''sequence_no'', '''') AS sequence_no
FROM pat_coop_detail
WHERE
  save_2 ->> ''ord_no'' = @ordNo
  AND save_2 ->> ''coop_cd'' =''ind_dial''
  AND facility_cd = @facilityCd 
  ORDER BY pat_coop_detail.up_date 
  LIMIT 1
)
SELECT
(SELECT bed_name FROM select_ord_main) AS bed_name,
(SELECT appointment_date FROM select_ord_main) AS appointment_date,
(SELECT sequence_no FROM select_sequence_no) AS sequence_no
-- SQL: -1104000 end', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム　再来受付', '2025-05-20 10:20:41.403', CURRENT_TIMESTAMP, NULL);