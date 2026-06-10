DELETE FROM sys_data_set
WHERE sql_cd IN (-310004);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310004, 'SELECT
    LEFT(hosp_pat_id, 10) AS hosp_pat_id,
    personal_info_decrypt(pat_last_name)|| '' '' || personal_info_decrypt(pat_first_name) AS pat_name,
    personal_info_decrypt(pat_last_name_kana)|| '' '' || personal_info_decrypt(pat_first_name_kana) AS pat_name_kana,
    personal_info_decrypt(pat_last_name_alpha)|| '' '' || personal_info_decrypt(pat_first_name_alpha) AS pat_name_alpha,
    pat_birthday AS pat_birthday_yyyymmdd,
    to_char(to_date(pat_birthday, ''YYYYMMDD''), ''YYYY/MM/DD'') AS pat_birthday,
    CASE
        WHEN NULLIF(pat_birthday, '''') IS NULL THEN NULL
        ELSE to_char(date_part(''year'', age(''now'', to_date(pat_birthday, ''YYYYMMDD''))), ''FM999'')
    END AS pat_age,
    pat_sex,
    pat_blood_type_abo,
    pat_blood_type_rh,
    pat_blood_type_abo * 10 + pat_blood_type_rh AS pat_blood_type_abo_rh,
    pat_blood_type_serovar AS pat_blood_type_serovar,
    CASE
        in_out_class WHEN 0 THEN ''2''
        WHEN 1 THEN ''1''
        ELSE ''''
    END AS in_out_class,
    CASE
        in_out_class WHEN 0 THEN ''外来''
        WHEN 1 THEN ''入院''
        ELSE ''不明''
    END AS in_out_class_name,
    trim(BOTH ''"'' FROM personal_info_decrypt(pat_contact_info->>''zip_cd'')) AS pat_zip,
    trim(BOTH ''"'' FROM personal_info_decrypt(pat_contact_info->>''address'')) AS pat_address,
    trim(BOTH ''"'' FROM personal_info_decrypt(pat_contact_info->>''tel1'')) AS pat_tel1,
    trim(BOTH ''"'' FROM personal_info_decrypt(pat_contact_info->>''tel2'')) AS pat_tel2,
    trim(BOTH ''"'' FROM personal_info_decrypt(pat_contact_info->>''fax'')) AS pat_fax,
    trim(BOTH ''"'' FROM personal_info_decrypt(pat_contact_info->>''e_mail'')) AS pat_e_mail,
    trim(BOTH ''"'' FROM personal_info_decrypt(pat_contact_info->>''work_name'')) AS pat_work_name,
    trim(BOTH ''"'' FROM personal_info_decrypt(pat_contact_info->>''work_tel'')) AS pat_work_tel,
    trim(BOTH ''"'' FROM personal_info_decrypt(pat_contact_info->>''memo1'')) AS pat_memo1,
    trim(BOTH ''"'' FROM personal_info_decrypt(pat_contact_info->>''memo2'')) AS pat_memo2,
    nationality AS nationality,
    COALESCE(severity_cd, 0) AS severity_cd,
    COALESCE(transport_cd, 0) AS transport_cd,
    is_die,
    die_date,
    die_cd,
    die_cd AS die_cd1,
    -- 透析困難有無
 CASE
        WHEN jsonb_array_length(dial_diff_com_info) > 0 THEN 1
        ELSE 0
    END AS dial_diff_com_info_flag,
    up_date
FROM
    pat_personal_main
WHERE
    is_del = ''0''
    AND
 pat_personal_main.pat_id = @patId', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);