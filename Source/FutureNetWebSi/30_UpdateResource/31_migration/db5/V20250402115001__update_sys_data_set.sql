DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-317118, -317119, -317120);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317118, 'WITH dr_no AS (
    SELECT
        (@dr1NameClassification = ''0'')::int + (@dr2NameClassification = ''0'')::int AS dr_no2,
        (@dr1NameClassification = ''0'')::int + (@dr2NameClassification = ''0'')::int + (@dr3NameClassification = ''0'')::int AS dr_no3,
        (@dr1NameClassification = ''0'')::int + (@dr2NameClassification = ''0'')::int + (@dr3NameClassification = ''0'')::int
        + (@dr4NameClassification = ''0'')::int AS dr_no4,
        (@dr1NameClassification = ''0'')::int + (@dr2NameClassification = ''0'')::int + (@dr3NameClassification = ''0'')::int
        + (@dr4NameClassification = ''0'')::int + (@dr5NameClassification = ''0'')::int AS dr_no5
)
, user_info AS (
    SELECT
        user_id,
        CONCAT(personal_info_decrypt(user_last_name), personal_info_decrypt(user_first_name)) AS user_name
    FROM
        mst_personal_user
    WHERE
        user_id IN (@drCd1::int, @drCd2::int, @drCd3::int, @drCd4::int, @drCd5::int)
)
SELECT 
        CASE @dr1NameClassification
            WHEN ''0'' THEN (SELECT user_name FROM user_info WHERE user_id = @drCd1::int)
            WHEN ''1'' THEN @ordFullName1
            WHEN ''2'' THEN @fixedDoctorName1
            WHEN ''3'' THEN @fixedDoctorName2
        END
     AS e01,
        CASE @dr2NameClassification
            WHEN ''0'' THEN (SELECT user_name FROM user_info WHERE user_id = 
                CASE (SELECT dr_no2 FROM dr_no)
                    WHEN ''1'' THEN @drCd1
                    WHEN ''2'' THEN @drCd2
                END ::int)
            WHEN ''1'' THEN @ordFullName2
            WHEN ''2'' THEN @fixedDoctorName1
            WHEN ''3'' THEN @fixedDoctorName2
        END
     AS e02,
        CASE @dr3NameClassification
            WHEN ''0'' THEN (SELECT user_name FROM user_info WHERE user_id = 
                CASE (SELECT dr_no3 FROM dr_no)
                    WHEN ''1'' THEN @drCd1
                    WHEN ''2'' THEN @drCd2
                    WHEN ''3'' THEN @drCd3
                END ::int)
            WHEN ''1'' THEN @fixedDoctorName1
            WHEN ''2'' THEN @fixedDoctorName2
        END
     AS e03,
        CASE @dr4NameClassification
            WHEN ''0'' THEN (SELECT user_name FROM user_info WHERE user_id = 
                CASE (SELECT dr_no4 FROM dr_no)
                    WHEN ''1'' THEN @drCd1
                    WHEN ''2'' THEN @drCd2
                    WHEN ''3'' THEN @drCd3
                    WHEN ''4'' THEN @drCd4
                END ::int)
            WHEN ''1'' THEN @fixedDoctorName1
            WHEN ''2'' THEN @fixedDoctorName2
        END
     AS e04,
        CASE @dr5NameClassification
            WHEN ''0'' THEN (SELECT user_name FROM user_info WHERE user_id = 
                CASE (SELECT dr_no5 FROM dr_no)
                    WHEN ''1'' THEN @drCd1
                    WHEN ''2'' THEN @drCd2
                    WHEN ''3'' THEN @drCd3
                    WHEN ''4'' THEN @drCd4
                    WHEN ''5'' THEN @drCd5
                END ::int)
            WHEN ''1'' THEN @fixedDoctorName1
            WHEN ''2'' THEN @fixedDoctorName2
        END
     AS e05', 3, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携Dr取得SQL', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, '[{"sql_cd": -317119, "field_name": "dr1_name_classification", "replace_var": "@dr1NameClassification"}, {"sql_cd": -317119, "field_name": "dr2_name_classification", "replace_var": "@dr2NameClassification"}, {"sql_cd": -317119, "field_name": "dr3_name_classification", "replace_var": "@dr3NameClassification"}, {"sql_cd": -317119, "field_name": "dr4_name_classification", "replace_var": "@dr4NameClassification"}, {"sql_cd": -317119, "field_name": "dr5_name_classification", "replace_var": "@dr5NameClassification"}, {"sql_cd": -317119, "field_name": "dr_cd1", "replace_var": "@drCd1"}, {"sql_cd": -317119, "field_name": "dr_cd2", "replace_var": "@drCd2"}, {"sql_cd": -317119, "field_name": "dr_cd3", "replace_var": "@drCd3"}, {"sql_cd": -317119, "field_name": "dr_cd4", "replace_var": "@drCd4"}, {"sql_cd": -317119, "field_name": "dr_cd5", "replace_var": "@drCd5"}, {"sql_cd": -317119, "field_name": "ord_full_name1", "replace_var": "@ordFullName1"}, {"sql_cd": -317119, "field_name": "ord_full_name2", "replace_var": "@ordFullName2"}, {"sql_cd": -317119, "field_name": "fixed_doctor_name1", "replace_var": "@fixedDoctorName1"}, {"sql_cd": -317119, "field_name": "fixed_doctor_name2", "replace_var": "@fixedDoctorName2"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317119, 'WITH ord_info AS (
    SELECT
        rst_charge_user_info ->> ''user_last_name_1'' AS last_name1,
        rst_charge_user_info ->> ''user_first_name_1'' AS first_name1,
        rst_charge_user_info ->> ''user_last_name_2'' AS last_name2,
        rst_charge_user_info ->> ''user_first_name_2'' AS first_name2
    FROM
        ord_main
    WHERE
        ord_no = @ordNo
),
dr_value AS(
    SELECT
        info ->> ''key2'' AS key2,
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS VALUE
    FROM
        mst_coop_ini AS ini
    CROSS JOIN
            LATERAL jsonb_array_elements(ini.coop_ini_info) info
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND info ->> ''key0'' = @key0
        AND info ->> ''key1'' = ''KARTE_ORD_SEND''
),
dr AS(
    SELECT
        staff_info ->> ''staff_cd'' AS dr_cd,
        row_number() OVER(ORDER BY staff_info ->> ''disp_order'' ASC) AS idx
    FROM
        pat_main AS pat
    CROSS JOIN
            LATERAL jsonb_array_elements(pat.charge_staff_info) staff_info
    WHERE
        pat.pat_id = @patId
        AND staff_info ->> ''is_main'' = ''1''
    ORDER BY
        staff_info ->> ''disp_order'' ASC
),
charge_staff AS(
    SELECT
        staff_info ->> ''staff_cd'' AS staff_cd,
        row_number() OVER(ORDER BY staff_info ->> ''disp_order'' ASC) AS idx
    FROM
        pat_main AS pat
    CROSS JOIN
            LATERAL jsonb_array_elements(pat.charge_staff_info) staff_info
    WHERE
        pat.pat_id = @patId
        AND staff_info ->> ''is_charge'' = ''1''
    ORDER BY
        staff_info ->> ''disp_order'' ASC
)
SELECT
    COALESCE((SELECT value FROM dr_value WHERE key2 = ''DR1_NAME_CLASSIFICATION''), ''0'') AS dr1_name_classification,
    COALESCE((SELECT value FROM dr_value WHERE key2 = ''DR2_NAME_CLASSIFICATION''), ''0'') AS dr2_name_classification,
    COALESCE((SELECT value FROM dr_value WHERE key2 = ''DR3_NAME_CLASSIFICATION''), ''0'') AS dr3_name_classification,
    COALESCE((SELECT value FROM dr_value WHERE key2 = ''DR4_NAME_CLASSIFICATION''), ''0'') AS dr4_name_classification,
    COALESCE((SELECT value FROM dr_value WHERE key2 = ''DR5_NAME_CLASSIFICATION''), ''0'') AS dr5_name_classification,
    (SELECT value FROM dr_value WHERE key2 = ''FIXED_DOCTOR_NAME1'') AS fixed_doctor_name1,
    (SELECT value FROM dr_value WHERE key2 = ''FIXED_DOCTOR_NAME2'') AS fixed_doctor_name2,
    COALESCE((SELECT dr_cd FROM dr WHERE idx = 1), ''-1'') AS dr_cd1,
    COALESCE((SELECT dr_cd FROM dr WHERE idx = 2), ''-1'') AS dr_cd2,
    COALESCE((SELECT dr_cd FROM dr WHERE idx = 3), ''-1'') AS dr_cd3,
    COALESCE((SELECT dr_cd FROM dr WHERE idx = 4), ''-1'') AS dr_cd4,
    COALESCE((SELECT dr_cd FROM dr WHERE idx = 5), ''-1'') AS dr_cd5,
    
    COALESCE((SELECT value FROM dr_value WHERE key2 = ''NS1_NAME_CLASSIFICATION''), ''0'') AS ns1_name_classification,
    COALESCE((SELECT value FROM dr_value WHERE key2 = ''NS2_NAME_CLASSIFICATION''), ''0'') AS ns2_name_classification,
    COALESCE((SELECT value FROM dr_value WHERE key2 = ''NS3_NAME_CLASSIFICATION''), ''0'') AS ns3_name_classification,
    COALESCE((SELECT value FROM dr_value WHERE key2 = ''NS4_NAME_CLASSIFICATION''), ''0'') AS ns4_name_classification,
    COALESCE((SELECT value FROM dr_value WHERE key2 = ''NS5_NAME_CLASSIFICATION''), ''0'') AS ns5_name_classification,
    (SELECT value FROM dr_value WHERE key2 = ''FIXED_NURSE_NAME1'') AS fixed_nurse_name1,
    (SELECT value FROM dr_value WHERE key2 = ''FIXED_NURSE_NAME2'') AS fixed_nurse_name2,
    COALESCE((SELECT staff_cd FROM charge_staff WHERE idx = 1), ''-1'') AS staff_cd1,
    COALESCE((SELECT staff_cd FROM charge_staff WHERE idx = 2), ''-1'') AS staff_cd2,
    COALESCE((SELECT staff_cd FROM charge_staff WHERE idx = 3), ''-1'') AS staff_cd3,
    COALESCE((SELECT staff_cd FROM charge_staff WHERE idx = 4), ''-1'') AS staff_cd4,
    COALESCE((SELECT staff_cd FROM charge_staff WHERE idx = 5), ''-1'') AS staff_cd5,
    
    (SELECT CONCAT(last_name1, first_name1) FROM ord_info) AS ord_full_name1,
    (SELECT CONCAT(last_name2, first_name2) FROM ord_info) AS ord_full_name2', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携担当Ns事前取得SQL', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317120, 'WITH staff_no AS (
    SELECT
        (@ns1NameClassification = ''0'')::int + (@ns2NameClassification = ''0'')::int AS staff_no2,
        (@ns1NameClassification = ''0'')::int + (@ns2NameClassification = ''0'')::int + (@ns3NameClassification = ''0'')::int AS staff_no3,
        (@ns1NameClassification = ''0'')::int + (@ns2NameClassification = ''0'')::int + (@ns3NameClassification = ''0'')::int
        + (@ns4NameClassification = ''0'')::int AS staff_no4,
        (@ns1NameClassification = ''0'')::int + (@ns2NameClassification = ''0'')::int + (@ns3NameClassification = ''0'')::int
        + (@ns4NameClassification = ''0'')::int + (@ns5NameClassification = ''0'')::int AS staff_no5
)
, user_info AS (
    SELECT
        user_id,
        CONCAT(personal_info_decrypt(user_last_name), personal_info_decrypt(user_first_name)) AS user_name
    FROM
        mst_personal_user
    WHERE
        user_id IN (@staffCd1::int, @staffCd2::int, @staffCd3::int, @staffCd4::int, @staffCd5::int)
)
SELECT 
        CASE @ns1NameClassification
            WHEN ''0'' THEN (SELECT user_name FROM user_info WHERE user_id = @staffCd1::int)
            WHEN ''1'' THEN @ordFullName1
            WHEN ''2'' THEN @fixedNurseName1
            WHEN ''3'' THEN @fixedNurseName2
        END
     AS e01,
        CASE @ns2NameClassification
            WHEN ''0'' THEN (SELECT user_name FROM user_info WHERE user_id = 
                CASE (SELECT staff_no2 FROM staff_no)
                    WHEN ''1'' THEN @staffCd1
                    WHEN ''2'' THEN @staffCd2
                END ::int)
            WHEN ''1'' THEN @ordFullName2
            WHEN ''2'' THEN @fixedNurseName1
            WHEN ''3'' THEN @fixedNurseName2
        END
     AS e02,
        CASE @ns3NameClassification
            WHEN ''0'' THEN (SELECT user_name FROM user_info WHERE user_id = 
                CASE (SELECT staff_no3 FROM staff_no)
                    WHEN ''1'' THEN @staffCd1
                    WHEN ''2'' THEN @staffCd2
                    WHEN ''3'' THEN @staffCd3
                END ::int)
            WHEN ''1'' THEN @fixedNurseName1
            WHEN ''2'' THEN @fixedNurseName2
        END
     AS e03,
        CASE @ns4NameClassification
            WHEN ''0'' THEN (SELECT user_name FROM user_info WHERE user_id = 
                CASE (SELECT staff_no4 FROM staff_no)
                    WHEN ''1'' THEN @staffCd1
                    WHEN ''2'' THEN @staffCd2
                    WHEN ''3'' THEN @staffCd3
                    WHEN ''4'' THEN @staffCd4
                END ::int)
            WHEN ''1'' THEN @fixedNurseName1
            WHEN ''2'' THEN @fixedNurseName2
        END
     AS e04,
        CASE @ns5NameClassification
            WHEN ''0'' THEN (SELECT user_name FROM user_info WHERE user_id = 
                CASE (SELECT staff_no5 FROM staff_no)
                    WHEN ''1'' THEN @staffCd1
                    WHEN ''2'' THEN @staffCd2
                    WHEN ''3'' THEN @staffCd3
                    WHEN ''4'' THEN @staffCd4
                    WHEN ''5'' THEN @staffCd5
                END ::int)
            WHEN ''1'' THEN @fixedNurseName1
            WHEN ''2'' THEN @fixedNurseName2
        END
     AS e05', 3, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携担当Ns取得SQL', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, '[{"sql_cd": -317119, "field_name": "ns1_name_classification", "replace_var": "@ns1NameClassification"}, {"sql_cd": -317119, "field_name": "ns2_name_classification", "replace_var": "@ns2NameClassification"}, {"sql_cd": -317119, "field_name": "ns3_name_classification", "replace_var": "@ns3NameClassification"}, {"sql_cd": -317119, "field_name": "ns4_name_classification", "replace_var": "@ns4NameClassification"}, {"sql_cd": -317119, "field_name": "ns5_name_classification", "replace_var": "@ns5NameClassification"}, {"sql_cd": -317119, "field_name": "staff_cd1", "replace_var": "@staffCd1"}, {"sql_cd": -317119, "field_name": "staff_cd2", "replace_var": "@staffCd2"}, {"sql_cd": -317119, "field_name": "staff_cd3", "replace_var": "@staffCd3"}, {"sql_cd": -317119, "field_name": "staff_cd4", "replace_var": "@staffCd4"}, {"sql_cd": -317119, "field_name": "staff_cd5", "replace_var": "@staffCd5"}, {"sql_cd": -317119, "field_name": "ord_full_name1", "replace_var": "@ordFullName1"}, {"sql_cd": -317119, "field_name": "ord_full_name2", "replace_var": "@ordFullName2"}, {"sql_cd": -317119, "field_name": "fixed_nurse_name1", "replace_var": "@fixedNurseName1"}, {"sql_cd": -317119, "field_name": "fixed_nurse_name2", "replace_var": "@fixedNurseName2"}]'::jsonb);