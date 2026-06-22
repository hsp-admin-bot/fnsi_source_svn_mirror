DELETE FROM sys_data_set
WHERE sql_cd IN (-200001);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-200001, '-- 【SQL_CD=-200001】
 select
 hosp_pat_id,
 personal_info_decrypt(pat_last_name)||'' ''||personal_info_decrypt(pat_first_name) as pat_name,
 personal_info_decrypt(pat_last_name_kana)||'' ''||personal_info_decrypt(pat_first_name_kana) as pat_name_kana,
 personal_info_decrypt(pat_last_name_alpha)||'' ''||personal_info_decrypt(pat_first_name_alpha) as pat_name_alpha,
 to_char(to_date(pat_birthday, ''YYYYMMDD''), ''YYYY/MM/DD'') as pat_birthday,
 case when pat_birthday is null then null
 else date_part(''year'',age(''now'', to_date(pat_birthday, ''YYYYMMDD'')))
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
 case when jsonb_array_length(dial_diff_com_info) > 0 then 1 else 0 end as dial_diff_com_info_flag,
 up_date
 from
 pat_personal_main
 where
 pat_id = @patId', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);