DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-66663, -100001, -600001, -207, -310004, -500001);


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-66663, 'select

hosp_pat_id
from

pat_personal_main

where

pat_id = @patId', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, '富士通', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-100001, 'select

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

pat_id = @patId', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, '富士通', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600001, ' select

 hosp_pat_id,

 lpad(hosp_pat_id, 12, ''0'') AS hosp_pat_id12,

 CASE WHEN LENGTH(hosp_pat_id) >= 8 THEN hosp_pat_id ELSE LPAD(hosp_pat_id, 8, ''0'') END AS hosp_pat_id8,

 personal_info_decrypt(pat_last_name)||'' ''||personal_info_decrypt(pat_first_name) as pat_name,

 personal_info_decrypt(pat_last_name_kana)||'' ''||personal_info_decrypt(pat_first_name_kana) as pat_name_kana,

 personal_info_decrypt(pat_last_name_alpha)||'' ''||personal_info_decrypt(pat_first_name_alpha) as pat_name_alpha,

 to_char(to_date(pat_birthday, ''YYYYMMDD''), ''YYYY/MM/DD'') as pat_birthday,

 pat_birthday as pat_birthday8,

 case when pat_birthday is null then null

 else date_part(''year'',age(''now'', to_date(pat_birthday, ''YYYYMMDD'')))

 end as pat_age,

 case when pat_sex = 1 then ''M''   when pat_sex = 2 then ''F'' else ''0'' end as pat_sex,

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


 pat_id = @patId', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'NEC標準(MegaOakHR) 透析レポート', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-207, 'WITH pre_dat AS ( 
  SELECT
    ord.ord_no
    , SUBSTR( ( CASE WHEN ord.ind_treat_start_time IS NULL OR ord.ind_treat_start_time = '''' THEN COALESCE( NULLIF(mkr.kur_standard_start_time, ''''), ''000000'') ELSE ord.ind_treat_start_time END) || ''000000'', 1, 6) AS start_time
    , TO_TIMESTAMP( ord.treat_date || SUBSTR( ( CASE WHEN ord.ind_treat_start_time IS NULL OR ord.ind_treat_start_time = '''' THEN COALESCE( NULLIF(mkr.kur_standard_start_time, ''''), ''000000'') ELSE ord.ind_treat_start_time END) || ''000000'', 1, 6), ''YYYYMMDDHH24MISS'') AS start_date_time
    , TO_NUMBER( COALESCE( NULLIF(ord.ind_cond_info -> ''1'' ->> ''value'', ''''), ''0'') , ''999999'') AS dialysis_time 
  FROM
    ord_main AS ord 
    LEFT OUTER JOIN mst_kur AS mkr ON mkr.kur_cd = ord.ind_kur_cd
  WHERE
    ord.ord_no = @ordNo
) 
SELECT
  ord.treat_date AS start_date
  , pre.start_time
  , TO_CHAR( ( pre.start_date_time + (dialysis_time * INTERVAL ''1 minute'')) , ''YYYYMMDD'') AS end_date
  , TO_CHAR( ( pre.start_date_time + (dialysis_time * INTERVAL ''1 minute'')) , ''HH24MISS'') AS end_time 
  , COALESCE ( pat.medical_care_info ->> ''dialysis_start_date'', '''' ) AS dialysis_start_date 
  , COALESCE ( ord.ind_bed_cd, 0 ) AS ind_bed_cd
  , COALESCE ( mbd.in_hospital_cd_1, ''0'' ) AS hospital_bed_cd
  , TO_CHAR(ord.up_date, ''YYYYMMDD'') AS update_date
  , TO_CHAR(ord.up_date, ''HH24MISS'') AS update_time
  , COALESCE ( ord.ind_treatment_cd, 0 ) AS ind_treatment_cd
  , COALESCE ( mtt.in_hospital_cd_a1, '''' ) AS hospital_treatment_cd
  , CASE WHEN ord.up_ind_user_id IS NOT NULL THEN ord.up_ind_user_id
      WHEN ord.ind_schedule_user_info->>''upd_user_id'' IS NOT NULL AND ord.ind_schedule_user_info->>''upd_user_id'' != '''' THEN CAST(ord.ind_schedule_user_info->>''upd_user_id'' AS INTEGER)
      ELSE ord.up_user_id END AS up_ind_user_id
FROM
  ord_main AS ord
  INNER JOIN pre_dat AS pre ON ord.ord_no = pre.ord_no 
  INNER JOIN pat_main AS pat ON ord.pat_id = pat.pat_id AND   LEFT OUTER JOIN mst_bed AS mbd ON mbd.bed_cd = ord.ind_bed_cd
  LEFT OUTER JOIN mst_treatment AS mtt ON mtt.treatment_cd = ord.ind_treatment_cd
WHERE
  ord.ord_no = @ordNo', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'NECiS)透析予約の透析指示情報を取得する', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);


INSERT INTO ntss.sys_data_set
(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
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

pat_personal_main.pat_id = @patId', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);


INSERT INTO ntss.sys_data_set
(sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500001, ' select
 hosp_pat_id,
 lpad(hosp_pat_id, 12, ''0'') AS hosp_pat_id12,
 CASE WHEN LENGTH(hosp_pat_id) >= 8 THEN hosp_pat_id ELSE LPAD(hosp_pat_id, 8, ''0'') END AS hosp_pat_id8,
 personal_info_decrypt(pat_last_name)||'' ''||personal_info_decrypt(pat_first_name) as pat_name,
 personal_info_decrypt(pat_last_name_kana)||'' ''||personal_info_decrypt(pat_first_name_kana) as pat_name_kana,
 personal_info_decrypt(pat_last_name_alpha)||'' ''||personal_info_decrypt(pat_first_name_alpha) as pat_name_alpha,
 to_char(to_date(pat_birthday, ''YYYYMMDD''), ''YYYY/MM/DD'') as pat_birthday,
 pat_birthday as pat_birthday8,
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
 pat_id = @patId', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'SSI 透析レポート', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
