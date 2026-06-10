DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-317111, -317110);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317110, 'WITH pat_info AS(
SELECT
    staff_info ->> ''staff_cd'' AS staff_cd
FROM
    pat_main AS pat
CROSS JOIN
    LATERAL json_array_elements(pat.charge_staff_info::json) staff_info
WHERE
    pat.pat_id = @patId
    AND staff_info ->> ''is_main'' = ''1''
ORDER BY
    (staff_info ->> ''disp_order'')::numeric ASC
LIMIT 1
),
sys_coop_info AS(
  SELECT
    user_id
  FROM
    sys_coop_journal AS sys
  WHERE
    sys.ctl_no = @ctlNo
),
ord_info AS (
    SELECT
        rst_charge_user_info ->> ''user_last_name_1'' AS last_name1,
        rst_charge_user_info ->> ''user_first_name_1'' AS first_name1
    FROM
        ord_main
    WHERE
        ord_no = @ordNo
),
doctor_name_value AS(
SELECT
    info ->> ''key2'' AS key2,
    COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS VALUE
FROM
    mst_coop_ini AS ini
CROSS JOIN
    LATERAL json_array_elements(ini.coop_ini_info::json) info
WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = ''MED''
    AND info ->> ''key1'' = ''KARTE_ORD_SEND''
)
SELECT
    (SELECT value FROM doctor_name_value WHERE key2 = ''DOCTOR_NAME_CLASSIFICATION'') AS doctor_name_classification,
    (SELECT user_id FROM sys_coop_info) AS user_id,
    (SELECT CONCAT(last_name1, first_name1) FROM ord_info) AS ord_full_name,
    (SELECT staff_cd FROM pat_info) AS staff_cd,
    (SELECT value FROM doctor_name_value WHERE key2 = ''FIXED_DOCTOR_NAME1'') AS fixed_doctor_name1,
    (SELECT value FROM doctor_name_value WHERE key2 = ''FIXED_DOCTOR_NAME2'') AS fixed_doctor_name2,
    (SELECT value FROM doctor_name_value WHERE key2 = ''FIXED_NURSE_NAME1'') AS fixed_nurse_name1,
    (SELECT value FROM doctor_name_value WHERE key2 = ''FIXED_NURSE_NAME2'') AS fixed_nurse_name2', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携医師名取得事前SQL', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317111, 'WITH sys_user_info AS(
    SELECT
        CONCAT(personal_info_decrypt(user_last_name), personal_info_decrypt(user_first_name)) AS sys_full_name
    FROM
        mst_personal_user
    WHERE
        user_id = @userId
),
pat_user_info AS(
    SELECT
        CONCAT(personal_info_decrypt(user_last_name), personal_info_decrypt(user_first_name)) AS pat_full_name
    FROM
        mst_personal_user
    WHERE
        user_id = COALESCE(NULLIF(@staffCd, ''''), ''-1'')::numeric
)
SELECT
    (
        CASE
            @doctorNameClassification
        WHEN ''0'' THEN COALESCE(
                    (SELECT sys_full_name FROM sys_user_info),
                    NULLIF(@ordFullName, ''''),
                    (SELECT pat_full_name FROM pat_user_info),
                    @fixedDoctorName1
                  )
        WHEN ''1'' THEN COALESCE(
                    NULLIF(@ordFullName, ''''),
                    (SELECT pat_full_name FROM pat_user_info),
                    @fixedDoctorName1
                  )
        WHEN ''2'' THEN COALESCE(
                    (SELECT pat_full_name FROM pat_user_info),
                    @fixedDoctorName1
                  )
        WHEN ''3'' THEN @fixedDoctorName1
        WHEN ''4'' THEN @fixedDoctorName2
        WHEN ''5'' THEN @fixedNurseName1
        WHEN ''6'' THEN @fixedNurseName2
        END 
    ) AS e01', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携医師名取得SQL', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, '[{"sql_cd": -317110, "field_name": "doctor_name_classification", "replace_var": "@doctorNameClassification"}, {"sql_cd": -317110, "field_name": "user_id", "replace_var": "@userId"}, {"sql_cd": -317110, "field_name": "ord_full_name", "replace_var": "@ordFullName"}, {"sql_cd": -317110, "field_name": "staff_cd", "replace_var": "@staffCd"}, {"sql_cd": -317110, "field_name": "fixed_doctor_name1", "replace_var": "@fixedDoctorName1"}, {"sql_cd": -317110, "field_name": "fixed_doctor_name2", "replace_var": "@fixedDoctorName2"}, {"sql_cd": -317110, "field_name": "fixed_nurse_name1", "replace_var": "@fixedNurseName1"}, {"sql_cd": -317110, "field_name": "fixed_nurse_name2", "replace_var": "@fixedNurseName2"}]'::jsonb);