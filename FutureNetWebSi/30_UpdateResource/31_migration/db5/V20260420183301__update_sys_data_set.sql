DELETE FROM sys_data_set
WHERE sql_cd IN (-604198,-604199);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604198, '-- 【SQL_CD=-604198】
WITH user_map AS (
    SELECT
        user_id,
        personal_info_decrypt(job_cd) AS job_cd
    FROM
        mst_personal_user
    WHERE
        is_del = ''0''
        AND is_disp = ''1''
        AND facility_cd = @facilityCd
        AND personal_info_decrypt(job_cd) IS NOT NULL
)
SELECT
    jsonb_agg(user_map)::text AS user_list
FROM
    user_map
    ;', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'CSI職種有ユーザー一覧取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604199, '-- 【SQL_CD=-604199】
WITH doctor AS (
    SELECT
        staff_info->>''staff_cd'' AS staff_cd,
        ROW_NUMBER() OVER() AS idx
    FROM
        pat_main AS pat
    CROSS JOIN LATERAL jsonb_array_elements(pat.charge_staff_info) AS staff_info
    JOIN jsonb_array_elements(@userList) AS users ON
        staff_info ->> ''staff_cd'' = users ->> ''user_id''
    JOIN mst_job ON
        mst_job.job_cd ::text = users ->> ''job_cd''
        AND mst_job.is_doctor = ''1''
    WHERE
        pat.pat_id = @patId
        AND pat.facility_cd = @facilityCd
        AND staff_info ->> ''is_main'' = ''1''
    ORDER BY
        staff_info->>''disp_order'' ASC
)
SELECT 
    (SELECT staff_cd FROM doctor WHERE idx = 1) AS staff_cd1,
    (SELECT staff_cd FROM doctor WHERE idx = 2) AS staff_cd2
    ;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'CSI主治医取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -604198, "field_name": "user_list", "replace_var": "@userList"}]'::jsonb);