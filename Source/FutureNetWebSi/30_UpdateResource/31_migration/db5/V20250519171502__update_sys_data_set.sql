delete from "sys_data_set" where sql_cd in (-1104000,-1104001,-1104002);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1104001, 'SELECT 
    CONCAT(
        CASE 
            WHEN OCTET_LENGTH(fax_no) < 4 THEN RPAD(fax_no, 4, '' '')
            ELSE fax_no
        END,
        @bed_name::text
    ) AS reservation_code_comment,
	@appointment_date::text as appointment_date,
	@sequence_no::text as sequence_no,
	mpu.in_hospital_cd_1 
FROM
mst_personal_user as mpu 
WHERE mpu.user_id = @staff_cd', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム　再来受付', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1104000, "field_name": "bed_name", "replace_var": "@bed_name"}, {"sql_cd": -1104000, "field_name": "appointment_date", "replace_var": "@appointment_date"}, {"sql_cd": -1104000, "field_name": "staff_cd", "replace_var": "@staff_cd"}, {"sql_cd": -1104000, "field_name": "sequence_no", "replace_var": "@sequence_no"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1104000, 'WITH select_ord_main AS(
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
,select_staff_cd AS (
SELECT 
COALESCE(staff ->> ''staff_cd'', '''') AS staff_cd
FROM
pat_main pm
	cross join lateral
      json_array_elements (pm.charge_staff_info :: json) staff
WHERE
 pat_id = @patId 
 AND facility_cd = @facilityCd 
)
,select_sequence_no as(
SELECT 
  COALESCE(save_2 ->> ''sequence_no'', '''') AS sequence_no
FROM pat_coop_detail
WHERE
  save_2 ->> ''ord_no'' = @ordNo
  AND save_2 ->> ''coop_code'' =''ind_dial''
  AND facility_cd = @facilityCd 
  ORDER BY pat_coop_detail.up_date 
  LIMIT 1
)
SELECT
(SELECT bed_name FROM select_ord_main) AS bed_name,
(SELECT staff_cd FROM select_staff_cd) AS staff_cd,
(SELECT appointment_date FROM select_ord_main) AS appointment_date,
(SELECT sequence_no FROM select_sequence_no) AS sequence_no', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム　再来受付', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1104002, 'WITH ind_memo AS (
  SELECT COALESCE(save_2 ->> ''sequence_no'', '''') AS sequence_no
  FROM pat_coop_detail
  WHERE
    save_2 ->> ''ord_no'' = @ordNo
    AND save_2 ->> ''coop_code'' = ''ind_dial''
    AND facility_cd = @facilityCd
  ORDER BY up_date
  LIMIT 1
),
acc_memo AS (
  SELECT COALESCE(save_2 ->> ''sequence_no'', '''') AS sequence_no
  FROM pat_coop_detail
  WHERE
    save_2 ->> ''coop_code'' = ''accept''
    AND facility_cd = @facilityCd
    AND save_2 ->> ''ord_no'' <> @ordNo
  ORDER BY up_date
  LIMIT 1
)
SELECT 1
WHERE (
  (SELECT sequence_no FROM acc_memo) <> (SELECT sequence_no FROM ind_memo)
);
   ', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム　再来受付', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);