DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-1104000);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1104000, '-- SQL: -1104000 begin
WITH ord_main_max AS(
    (
        SELECT
            ord.rst_edition_date AS up_date,
            ord.rst_bed_cd,
            ord.ind_kur_cd,
            ord.treat_date
        FROM
            ord_main AS ord
        WHERE 
            ord.ord_no=@ordNo
            AND ord.facility_cd = @facilityCd
    )
    UNION ALL
    (
        SELECT
            ord.del_date AS up_date,
            ord.rst_bed_cd,
            ord.ind_kur_cd,
            ord.treat_date
        FROM
            ord_main_restore AS ord
        WHERE 
            ord.ord_no=@ordNo
            AND ord.facility_cd = @facilityCd
        ORDER BY
            del_date DESC
        LIMIT 1
    )
    ORDER BY
        up_date DESC NULLS LAST
    LIMIT 1
),select_ord_main AS(
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
ord_main_max AS ord
	LEFT OUTER JOIN mst_bed AS mbe 
		ON mbe.bed_cd = ord.rst_bed_cd 
	LEFT OUTER JOIN mst_kur AS mkr 
		ON mkr.kur_cd = ord.ind_kur_cd 
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
-- SQL: -1104000 end', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム　再来受付', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);