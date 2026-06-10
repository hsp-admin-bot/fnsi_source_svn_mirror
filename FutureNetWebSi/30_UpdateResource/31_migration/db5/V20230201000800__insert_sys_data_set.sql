DELETE FROM ntss.sys_data_set WHERE sql_cd IN (-100001,-400001,-100011,-400016);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-100011, 'select

hosp_pat_id,

personal_info_decrypt(pat_last_name)||'' ''||personal_info_decrypt(pat_first_name) as pat_name,

personal_info_decrypt(pat_last_name_kana)||'' ''||personal_info_decrypt(pat_first_name_kana) as pat_name_kana,

personal_info_decrypt(pat_last_name_alpha)||'' ''||personal_info_decrypt(pat_first_name_alpha) as pat_name_alpha,

to_char(to_date(pat_birthday, ''YYYYMMDD''), ''YYYY/MM/DD'') as pat_birthday,

case when pat_birthday is null then null

else round(cast(date_part(''year'',age(''now'', to_date(pat_birthday, ''YYYYMMDD''))) as numeric))

end as pat_age,

case when pat_sex = 1 then 0   when pat_sex = 2 then 1 else 2 end as pat_sex,

case  pat_blood_type_abo when 1 THEN ''0''  WHEN 2 THEN ''1''  WHEN 3 THEN ''3''  WHEN 4 THEN ''2''  ELSE ''-'' END AS pat_blood_type_abo,

case pat_blood_type_rh when 1 THEN ''0''  WHEN 2 THEN ''2''   ELSE ''-'' END AS pat_blood_type_rh,

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

up_date

from

pat_personal_main

where

is_del = ''0''

and

pat_id =  @patId', 3, '[]', '0', '{"applications": [4]}', '{"classes": []}', '日機装 透析レポートXML', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-400016, '  select
 hosp_pat_id,
 lpad(hosp_pat_id, 12, ''0'') AS hosp_pat_id12,
 personal_info_decrypt(pat_last_name)||'' ''||personal_info_decrypt(pat_first_name) as pat_name,
 personal_info_decrypt(pat_last_name_kana)||'' ''||personal_info_decrypt(pat_first_name_kana) as pat_name_kana,
 personal_info_decrypt(pat_last_name_alpha)||'' ''||personal_info_decrypt(pat_first_name_alpha) as pat_name_alpha,
 to_char(to_date(pat_birthday, ''YYYYMMDD''), ''YYYY/MM/DD'') as pat_birthday,
 pat_birthday as pat_birthday8,
 case when pat_birthday is null then null
 else round(cast(date_part(''year'',age(''now'', to_date(pat_birthday, ''YYYYMMDD''))) as numeric))
 end as pat_age,
 case when pat_sex = 1 then 0   when pat_sex = 2 then 1 else 2 end as pat_sex,
 case  pat_blood_type_abo when 1 THEN ''0''  WHEN 2 THEN ''1''  WHEN 3 THEN ''3''  WHEN 4 THEN ''2''  ELSE ''-'' END AS pat_blood_type_abo,
 case pat_blood_type_rh when 1 THEN ''0''  WHEN 2 THEN ''2''   ELSE ''-'' END AS pat_blood_type_rh,
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
 up_date
 from
 pat_personal_main
 where
 is_del = ''0''
 and
 pat_id = @patId', 3, '[]', '0', '{"applications": [4]}', '{"classes": []}', '日機装 透析レポートXML',CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
 INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-100001, 'select

hosp_pat_id,

personal_info_decrypt(pat_last_name)||'' ''||personal_info_decrypt(pat_first_name) as pat_name,

personal_info_decrypt(pat_last_name_kana)||'' ''||personal_info_decrypt(pat_first_name_kana) as pat_name_kana,

personal_info_decrypt(pat_last_name_alpha)||'' ''||personal_info_decrypt(pat_first_name_alpha) as pat_name_alpha,

to_char(to_date(pat_birthday, ''YYYYMMDD''), ''YYYY/MM/DD'') as pat_birthday,

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

up_date

from

pat_personal_main

where

is_del = ''0''

and

pat_id = @patId', 3, '[]', '0', '{"applications": [4]}', '{"classes": []}', '富士通', '2020-07-31 18:29:49.294', '2023-01-06 00:20:20.593', NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-400001, ' select
 hosp_pat_id,
 lpad(hosp_pat_id, 12, ''0'') AS hosp_pat_id12,
 personal_info_decrypt(pat_last_name)||'' ''||personal_info_decrypt(pat_first_name) as pat_name,
 personal_info_decrypt(pat_last_name_kana)||'' ''||personal_info_decrypt(pat_first_name_kana) as pat_name_kana,
 personal_info_decrypt(pat_last_name_alpha)||'' ''||personal_info_decrypt(pat_first_name_alpha) as pat_name_alpha,
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
 up_date
 from
 pat_personal_main
 where
 is_del = ''0''
 and
 pat_id = @patId', 3, '[]', '0', '{"applications": [4]}', '{"classes": []}', '日機装 透析レポート', '2020-07-31 18:29:49', '2023-01-06 00:20:20.593', NULL);
