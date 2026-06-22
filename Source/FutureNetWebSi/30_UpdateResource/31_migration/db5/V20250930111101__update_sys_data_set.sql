DELETE FROM ntss.sys_data_set
WHERE sql_cd=-132;
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-132, 'WITH ord_main_data AS ( 
   ( SELECT (to_number(ind_cond_info:: json ->''26'' ->> ''value'', ''9999.99'')+
to_number(ind_cond_info:: json ->''28'' ->> ''value'', ''9999.99''))::TEXT AS anti_coagulant_amount, pat_id
    FROM ord_main 
    WHERE ord_no = @ordNo)
		union 
				   ( SELECT (to_number(ind_cond_info:: json ->''26'' ->> ''value'', ''9999.99'')+
to_number(ind_cond_info:: json ->''28'' ->> ''value'', ''9999.99''))::TEXT AS anti_coagulant_amount, pat_id
    FROM ord_main_restore
    WHERE ord_no = @ordNo
		and (select count(1) from  ord_main 
    WHERE ord_no = @ordNo) = ''0''
		ORDER BY del_date desc limit 1)
)
, ini_data AS (
    SELECT COALESCE
        ( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS default_setting 
    FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
    WHERE
        facility_cd = @facilityCd
     
        AND is_del = ''0''
                -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 start
                AND COALESCE(info ->> ''key0'', '''') = @key0
                -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 end 
        AND info ->> ''key1'' = ''DIALYSISSCHESEND'' 
        AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'' 
) 
, dialysis_date AS (
    SELECT
        REPLACE(MIN(I.period_start_date) :: TEXT, ''-'', '''') AS dialysis_start_date
    FROM
        pat_unique U
        CROSS JOIN LATERAL jsonb_to_recordset(U.in_out_visit_history_info) AS I
        (   ctl_no bigint,
            period_start_date date,
            period_start_day bigint,
            period_start_month bigint,
            period_start_year bigint,
            move_in_out smallint
        )
    WHERE pat_id = (SELECT pat_id FROM ord_main_data)
    AND U.is_del = ''0''
    AND I.period_start_day IS NOT NULL
    AND I.period_start_month IS NOT NULL
    AND I.period_start_year IS NOT NULL
    AND I.period_start_date IS NOT NULL
    AND I.move_in_out = 1
) 
, hospital_date AS (
    SELECT 
        REPLACE(MAX(I.period_start_date) :: TEXT, ''-'', '''') AS hospital_start_date
    FROM
        pat_unique U
        CROSS JOIN LATERAL jsonb_to_recordset(U.in_out_visit_history_info) AS I
        (   ctl_no bigint,
            period_start_date date,
            from_facility text,
            move_in_out smallint
        )
    WHERE pat_id = (SELECT pat_id FROM ord_main_data)
    AND U.is_del = ''0''
    AND I.period_start_date IS NOT NULL
    AND ((I.move_in_out = 1 AND (I.from_facility IS NULL OR I.from_facility = ''''))
    OR  I.move_in_out = 2)
)
SELECT dialysis_date.dialysis_start_date, hospital_date.hospital_start_date, ini_data.default_setting,
(CASE ord_main_data.anti_coagulant_amount::FLOAT >= 1
    WHEN TRUE THEN
        LPAD(split_part((ord_main_data.anti_coagulant_amount::FLOAT*100)::TEXT, ''.'', 1), 8, '' '')
    ELSE
        (
        CASE ini_data.default_setting
    WHEN ''0'' THEN
        LPAD(split_part((ord_main_data.anti_coagulant_amount::FLOAT*100)::TEXT, ''.'', 1), 8, '' '')
    WHEN ''1'' THEN
        LPAD(LPAD(split_part((ord_main_data.anti_coagulant_amount::FLOAT*100)::TEXT, ''.'', 1), 3, ''0''), 8, '' '')
  END
    )
END
) AS calculate_one_shot_amount
FROM ord_main_data, ini_data, dialysis_date, hospital_date', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '汎用）指示）透析条件', '2022-08-18 15:49:19.638', '2025-09-01 11:31:00.779', NULL);