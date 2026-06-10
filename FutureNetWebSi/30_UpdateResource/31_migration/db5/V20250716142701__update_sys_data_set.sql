DELETE FROM "ntss"."sys_data_set" where sql_cd in (-2,-1,228);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2, 'SELECT
	1 AS OrderNo,
	personal_info_decrypt(user_last_name)        || personal_info_decrypt(user_first_name) as user_name,
  personal_info_decrypt(user_last_name_kana)   || personal_info_decrypt(user_first_name_kana) as user_name_kana,
  personal_info_decrypt(user_last_name_alpha)  || personal_info_decrypt(user_first_name_alpha) as user_name_alpha 
FROM
	mst_personal_user 
WHERE
	user_id = TO_NUMBER( CASE WHEN ( @userId ~ ''^([0-9]+[.]?[0-9]*|[.][0-9]+)$'' ) = TRUE THEN @userId ELSE''-1'' END, ''FM9999999'' ) 
	AND is_disp = ''1'' 
	AND is_del = ''0'' 
UNION
SELECT
	2 AS OrderNo,
	@userId AS user_name ,
	''''as user_name_kana,
	''''as user_name_alpha
ORDER BY
	OrderNo ASC 
	LIMIT 1', 3, '[]', '0', '{"applications": []}', '{"classes": []}', 'スタッフ名取得用　@userId使用', '2020-03-31 14:39:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-1, 'select
  hosp_pat_id,
  personal_info_decrypt(pat_last_name)||personal_info_decrypt(pat_first_name) as pat_name,
  personal_info_decrypt(pat_last_name_kana)||personal_info_decrypt(pat_first_name_kana) as pat_name_kana,
  personal_info_decrypt(pat_last_name_alpha)||personal_info_decrypt(pat_first_name_alpha) as pat_name_alpha,
  personal_info_decrypt(pat_last_name) as pat_last_name,
  pat_birthday,
  case when pat_birthday is null then null
    else date_part(''year'',age(''now'', to_date(pat_birthday, ''YYYYMMDD'')))
  end as pat_age,
  pat_sex,
  pat_blood_type_abo,
  pat_blood_type_rh,
  pat_blood_type_abo * 10 +  pat_blood_type_rh as pat_blood_type_abo_rh,
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
  severity_cd,
  transport_cd,
  is_die,
  die_date,
  die_cd
from
  pat_personal_main
where
  is_del = ''0''
and
  pat_id = @patId', 3, '[]', '0', '{"applications": []}', '{"classes": []}', '患者個人情報 @patId使用', '2020-03-31 23:14:57.873', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (228, 'SELECT
  ordMain.ord_no,
	ordMain.treat_date,
    ordMain.rst_dialysis_state,
   concat(ordMain.ind_dw_user_info ->> ''ind_user_last_name'',ordMain.ind_dw_user_info ->> ''ind_user_first_name'') AS ind_user_name,
   concat(ordMain.ind_dw_user_info ->> ''upd_user_last_name'',ordMain.ind_dw_user_info ->> ''upd_user_first_name'') AS upd_user_name
FROM
    ord_main ordMain
WHERE
    ord_no = @ordNo;', 2, '[{"preview": "", "can_calc": "0", "data_code": "ind_user_name", "data_name": "指示者", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "ind_user_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "upd_user_name", "data_name": "更新者", "data_type": "string", "conv_table": [], "data_class": "透析条件", "field_name": "upd_user_name", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9]}', 'DW指示情報 @ordNo使用', '2024-06-07 15:55:31', CURRENT_TIMESTAMP, NULL);
