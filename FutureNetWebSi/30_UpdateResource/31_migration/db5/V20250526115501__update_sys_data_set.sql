DELETE FROM sys_data_set WHERE sql_cd IN (-1104001);

INSERT INTO sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1104001, 'WITH decoded_user AS (
    SELECT 
        mpu.user_id,
        mpu.in_hospital_cd_1,
        (
            SELECT string_agg(
                       chr( (''x'' || substr(fax_no, gs, 2))::bit(8)::int / 2 ),
                       ''''
                   )
            FROM generate_series(1, length(fax_no), 2) AS gs
            WHERE fax_no IS NOT NULL
        ) AS decoded_fax_no
    FROM mst_personal_user AS mpu
    WHERE mpu.user_id::text = @reservedByUserId
)

SELECT 
    CONCAT(
        CASE 
            WHEN @reservedByUserId IS NULL OR @reservedByUserId = '''' THEN RPAD('''', 4, '' '')
            WHEN OCTET_LENGTH(COALESCE(d.decoded_fax_no, '''')) < 4 THEN RPAD(COALESCE(d.decoded_fax_no, ''''), 4, '' '')
            ELSE d.decoded_fax_no
        END,
        CASE 
            WHEN @bedName::text = '''' THEN RPAD('''', 40, '' '')
            ELSE @bedName::text
        END
    ) AS reservation_code_comment,

    @appointmentDate::text AS appointment_date,
    @sequenceNo::text AS sequsence_no,
    d.in_hospital_cd_1

FROM decoded_user d
RIGHT JOIN (SELECT 1) dummy ON TRUE;
', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム　再来受付', '2025-05-20 10:20:41.403', '2025-05-20 10:20:41.403', '[{"sql_cd": -1104000, "field_name": "bed_name", "replace_var": "@bedName"}, {"sql_cd": -1104000, "field_name": "appointment_date", "replace_var": "@appointmentDate"}, {"sql_cd": -1104000, "field_name": "sequence_no", "replace_var": "@sequenceNo"}, {"sql_cd": -1104004, "field_name": "reserved_by_user_id", "replace_var": "@reservedByUserId"}]'::jsonb);