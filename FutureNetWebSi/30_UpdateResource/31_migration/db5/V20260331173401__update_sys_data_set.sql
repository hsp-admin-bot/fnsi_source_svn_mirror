DELETE FROM sys_data_set
WHERE sql_cd IN (-132, -66657, -400018);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-132, '-- 【SQL_CD=-132】
WITH ord_main_data AS ( 
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
FROM ord_main_data, ini_data, dialysis_date, hospital_date', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '汎用）指示）透析条件', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-66657, '-- 【SQL_CD=-66657】
 select
CASE
        @aligh
        WHEN ''0'' THEN
    lpad(right(hosp_pat_id,@len), 12,''0'') else rpad(right(hosp_pat_id,@len), 12,''0'')
    END AS hosp_pat_id12
 from
 pat_personal_main
 where
 pat_id = @patId', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, '日機装 透析レポート', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -66659, "field_name": "len", "replace_var": "@len"}, {"sql_cd": -66658, "field_name": "aligh", "replace_var": "@aligh"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-400018, '-- 【SQL_CD=-400018】
 select
 hosp_pat_id,
 lpad(hosp_pat_id, 12, ''0'') AS hosp_pat_id12,
 CONCAT(personal_info_decrypt(pat_last_name),'' '',personal_info_decrypt(pat_first_name)) as pat_name,
 CONCAT(personal_info_decrypt(pat_last_name_kana),'' '', personal_info_decrypt(pat_first_name_kana)) as pat_name_kana,
 CONCAT(personal_info_decrypt(pat_last_name_alpha),'' '', personal_info_decrypt(pat_first_name_alpha)) as pat_name_alpha,
 to_char(to_date(pat_birthday, ''YYYYMMDD''), ''YYYY/MM/DD'') as pat_birthday,
 pat_birthday as pat_birthday8,
 case when pat_birthday is null then null
 else round(cast(date_part(''year'',age(''now'', to_date(pat_birthday, ''YYYYMMDD''))) as numeric))
 end as pat_age,
 case when pat_sex = 1 then 0   when pat_sex = 2 then 1 else 2 end as pat_sex,
 pat_blood_type_abo,
 pat_blood_type_rh,
 pat_blood_type_abo * 10 +  pat_blood_type_rh as pat_blood_type_abo_rh,
 pat_blood_type_serovar as pat_blood_type_serovar,
 in_out_class,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''zip_cd'')) as pat_zip,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''address'')) as pat_address,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''tel1'')) as pat_tel1,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''tel2'')) as pat_tel2,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''fax'')) as pat_fax,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''e_mail'')) as pat_e_mail,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''work_name'')) as pat_work_name,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''work_tel'')) as pat_work_tel,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''memo1'')) as pat_memo1,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''memo2'')) as pat_memo2,
 nationality as nationality,
 severity_cd,
 transport_cd,
 is_die,
 die_date,
 die_cd,
 die_cd as die_cd1,
 -- 透析困難有無
 CASE WHEN (SELECT count( * ) AS countNum 
 FROM pat_personal_main,
 jsonb_array_elements ( dial_diff_com_info ) AS dial_diff_info 
 WHERE dial_diff_info ->> ''is_main'' = ''1'' AND pat_id = @patId ) > 0 THEN 1 ELSE 0 END AS dial_diff_com_info_flag,
 -- 透析困難有無修正
 case when (SELECT count( *) as countNum
 from pat_personal_main,jsonb_array_elements(dial_diff_com_info) as dial_diff_com_info1
 where dial_diff_com_info1 ->> ''is_dial_diff'' = ''1'' and pat_id = @patId) > 0 then 1 else 0 end as dial_diff_com_info_flag_test,
 up_date,
 CASE in_out_class
   WHEN 1 THEN @inVal
   ELSE @outVal
 END AS conv_in_out_class
 from
 pat_personal_main
 where
 pat_id = @patId', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, '日機装 透析レポート', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -400017, "field_name": "out_val", "replace_var": "@outVal"}, {"sql_cd": -400017, "field_name": "in_val", "replace_var": "@inVal"}]'::jsonb);