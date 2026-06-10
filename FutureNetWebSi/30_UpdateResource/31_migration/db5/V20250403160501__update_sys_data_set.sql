DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-317119);

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
        row_number() OVER(ORDER BY (staff_info ->> ''disp_order'')::int ASC) AS idx
    FROM
        pat_main AS pat
    CROSS JOIN
            LATERAL jsonb_array_elements(pat.charge_staff_info) staff_info
    WHERE
        pat.pat_id = @patId
        AND staff_info ->> ''is_main'' = ''1''
    ORDER BY
        (staff_info ->> ''disp_order'')::int ASC
),
charge_staff AS(
    SELECT
        staff_info ->> ''staff_cd'' AS staff_cd,
        row_number() OVER(ORDER BY (staff_info ->> ''disp_order'')::int ASC) AS idx
    FROM
        pat_main AS pat
    CROSS JOIN
            LATERAL jsonb_array_elements(pat.charge_staff_info) staff_info
    WHERE
        pat.pat_id = @patId
        AND staff_info ->> ''is_charge'' = ''1''
    ORDER BY
        (staff_info ->> ''disp_order'')::int ASC
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