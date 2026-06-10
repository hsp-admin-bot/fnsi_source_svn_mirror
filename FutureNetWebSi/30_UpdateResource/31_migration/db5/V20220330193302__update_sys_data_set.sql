delete from "sys_data_set" where sql_cd in (-456,-457,-300001,-1001);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-456, 'WITH ord_info AS (
SELECT
 CASE WHEN rst_weight_info ->> ''weight_before_date'' IS NULL THEN
    CAST(rst_start_date as TIMESTAMP)
  ELSE 
   CAST(rst_weight_info ->> ''weight_before_date'' as TIMESTAMP)
  END AS accept_date
 , course.in_hospital_cd_1 AS in_hospital_cd
FROM
 ord_main AS ord
  LEFT JOIN mst_course AS course ON ord.rst_course_cd = course.course_cd AND ord.facility_cd = course.facility_cd
WHERE
 ord.ord_no = @ordNo)
 ,ACCEPT_SEND AS(
 SELECT
  info ->> ''key2'' AS key2,
  UNNEST ( string_to_array( COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ), '','' ) ) AS 
 VALUE
  
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
 WHERE
  facility_cd = @facilityCd
  AND is_del = ''0'' 
  AND info ->> ''key1'' = ''ACCEPT_SEND'' 
)
SELECT 
  CASE (SELECT VALUE FROM ACCEPT_SEND WHERE key2 = ''DAY_SENDING_FLAG'') WHEN ''1''  THEN  (CASE  WHEN ( (TO_CHAR(accept_date, ''YYYY-MM-DD''):: TIMESTAMP)  =  (select current_date))THEN TO_CHAR(accept_date, ''YYYY'') ELSE '''' END) ELSE TO_CHAR(accept_date, ''YYYY'') END AS date_year, 
  CASE (SELECT VALUE FROM ACCEPT_SEND WHERE key2 = ''DAY_SENDING_FLAG'') WHEN ''1''  THEN  (CASE  WHEN ( (TO_CHAR(accept_date, ''YYYY-MM-DD''):: TIMESTAMP)  =  (select current_date))THEN TO_CHAR(accept_date, ''MMDD'') ELSE '''' END) ELSE TO_CHAR(accept_date, ''MMDD'') END AS date_month_day,  
  CASE (SELECT VALUE FROM ACCEPT_SEND WHERE key2 = ''DAY_SENDING_FLAG'') WHEN ''1''  THEN  (CASE  WHEN ( (TO_CHAR(accept_date, ''YYYY-MM-DD''):: TIMESTAMP)  =  (select current_date))THEN TO_CHAR(accept_date, ''HH24MISS'') ELSE '''' END) ELSE TO_CHAR(accept_date, ''HH24MISS'') END AS date_time,
 CASE (SELECT VALUE FROM ACCEPT_SEND WHERE key2 = ''COURES_CLASSIFICATION'' ) WHEN ''0''  THEN COALESCE( NULLIF(in_hospital_cd,'''') ,(SELECT VALUE FROM ACCEPT_SEND WHERE key2 = ''FIXED_COURES_CODE1''))
  WHEN ''1''  THEN  (SELECT VALUE FROM ACCEPT_SEND WHERE key2 = ''FIXED_COURES_CODE1'')
 ELSE (SELECT VALUE FROM ACCEPT_SEND WHERE key2 = ''FIXED_COURES_CODE1'') END AS in_hospital_cd
FROM ord_info', 2, '[{}]', '0', '{"applications": [4]}', NULL, 'Medicom受付情報の「受付処理日時、受診科１」', '2020-05-13 11:51:04', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-457, 'WITH pat_info AS (
SELECT
 staff_info->>''ctl_no'' AS ctl_no,
 staff_info->>''disp_order'' AS disp_order,
 staff_info->>''staff_cd'' AS staff_cd,
 staff_info->>''is_main'' AS is_main,
 staff_info->>''is_charge'' AS is_charge,
 staff_info->>''is_puncture'' AS is_puncture
FROM
 pat_main AS pat 
 CROSS JOIN LATERAL json_array_elements ( pat.charge_staff_info :: json ) staff_info
WHERE
 pat.pat_id = @patId
 AND  staff_info->>''is_main'' = ''1''
ORDER BY 
 staff_info->>''disp_order'' ASC
LIMIT 1)
,ACCEPT_SEND AS(
 SELECT
  info ->> ''key2'' AS key2,
  UNNEST ( string_to_array( COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ), '','' ) ) AS 
 VALUE
  
 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
 WHERE
  facility_cd =  @facilityCd
  AND is_del = ''0'' 
  AND info ->> ''key1'' = ''ACCEPT_SEND'' 
)
SELECT CASE (SELECT VALUE FROM ACCEPT_SEND WHERE  key2=''DOCTOR_CLASSIFICATION'') 
       WHEN ''0'' THEN   COALESCE(staff_cd,(SELECT VALUE FROM ACCEPT_SEND WHERE key2=''FIXED_DOCTOR_CODE1''))  -- 0：患者の担当医１ （取得できない場合は固定医師コード1）
      WHEN ''1'' THEN   (SELECT VALUE FROM ACCEPT_SEND WHERE key2=''FIXED_DOCTOR_CODE1'')  --1：固定医師コード１
      WHEN ''2'' THEN   (SELECT VALUE FROM ACCEPT_SEND WHERE key2=''FIXED_DOCTOR_CODE2'')  --2：固定医師コード２
      WHEN ''3'' THEN   ''''  --3：空白   
       ELSE '''' END AS staff_cd,
      (SELECT VALUE  FROM  ACCEPT_SEND WHERE key2 = ''IN_HOSPTIAL_REASON'' ) AS  in_hosptial_reason,
      (SELECT VALUE  FROM  ACCEPT_SEND WHERE key2 = ''RECONNECTION'' ) AS reconnection 
FROM (SELECT (SELECT staff_cd FROM pat_info) AS staff_cd ) AS T01', 2, '[{}]', '0', '{"applications": [4]}', NULL, 'Medicom受付情報の「医師１」', '2020-05-13 11:51:04', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-1001, 'select
  COALESCE(ord_main.treat_date,to_char(ord_main.rst_start_date :: TIMESTAMP,''YYYYMMDD'') ,'''')  as treat_date
  ,COALESCE(left(mst_kur.kur_standard_start_time, 4),to_char(ord_main.rst_start_date::TIMESTAMP,''HH24MI''),'''')  as kur_standard_start_time 
from
  ord_main
  , mst_kur 
where
  ord_no = @ordNo 
  and ord_main.rst_kur_cd = mst_kur.kur_cd
', 2, '[{}]', '0', '{"applications": [4]}', NULL, NULL, '2020-03-17 16:17:08.001',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-300001, ' select
 hosp_pat_id,
 personal_info_decrypt(pat_last_name)||'' ''||personal_info_decrypt(pat_first_name) as pat_name,
 personal_info_decrypt(pat_last_name_kana)||'' ''||personal_info_decrypt(pat_first_name_kana) as pat_name_kana,
 personal_info_decrypt(pat_last_name_alpha)||'' ''||personal_info_decrypt(pat_first_name_alpha) as pat_name_alpha,
 pat_birthday as pat_birthday_yyyymmdd,
 to_char(to_date(pat_birthday, ''YYYYMMDD''), ''YYYY/MM/DD'') as pat_birthday,
 case when pat_birthday is null then null
 else to_char(date_part(''year'',age(''now'', to_date(pat_birthday, ''YYYYMMDD''))), ''FM999'')
 end as pat_age,
 case when pat_sex = 1 then 0   when pat_sex = 2 then 1 else 2 end as pat_sex,
 pat_blood_type_abo,
 pat_blood_type_rh,
 pat_blood_type_abo * 10 +  pat_blood_type_rh as pat_blood_type_abo_rh,
 pat_blood_type_serovar as pat_blood_type_serovar,
 in_out_class,
 case in_out_class when 0 then ''外来'' when 1 then ''入院'' else ''不明'' end as in_out_class_name,
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
 COALESCE(severity_cd,0) as severity_cd,
 COALESCE(transport_cd,0) as transport_cd,
 is_die,
 die_date,
 die_cd,
 die_cd as die_cd1,
 -- 透析困難有無
 case when jsonb_array_length(dial_diff_com_info) > 0 then 1 else 0 end as dial_diff_com_info_flag,
 up_date,
 insu_class, 
 insu_name
 from
 pat_personal_main
 left outer join (select pat_id, insu_class, insu_name from pat_insurance where pat_id = @patId and is_del = ''0'' order by is_selected desc limit 1) as insurance on insurance.pat_id = pat_personal_main.pat_id
 where
 is_del = ''0''
 and
 pat_personal_main.pat_id = @patId', 3, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'Medicom', '2020-07-31 18:29:49', CURRENT_TIMESTAMP, NULL);
