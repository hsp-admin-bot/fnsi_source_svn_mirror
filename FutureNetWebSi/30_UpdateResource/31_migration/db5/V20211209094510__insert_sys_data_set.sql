delete from "sys_data_set" where "sql_cd" >= -700010 and "sql_cd" <= -700000;
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-700000, 'SELECT ''05'' AS detail_id', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'NEC-iS(MegaOakiS) 透析レポート', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-700001, ' select
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
 is_del = ''0''
 and
 pat_id = @patId', 3, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'NEC-iS(MegaOakiS) 透析レポート', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-700006, 'select
  to_char(ord.rst_start_date,''YYYYMMDDHH24MISS'') as start_date14,--透析開始日時
  to_char(ord.rst_start_date,''YYYY/MM/DD HH24:MI:SS'') as start_date14a,--透析開始日時
  to_char(ord.rst_start_date,''YYYYMMDD'') as start_date8,--透析開始日時
  to_char(ord.rst_start_date,''YYYY/MM/DD'') as start_date8a,--透析開始日時
  to_char(ord.rst_start_date,''HH24MISS'') as start_date6,--透析開始日時
  to_char(ord.rst_start_date,''HH24:MI:SS'') as start_date6a,--透析開始日時
  to_char(ord.rst_end_date,''YYYYMMDDHH24MISS'') as end_date14,--透析終了日時
  to_char(ord.rst_end_date,''YYYYMMDD'') as end_date8,--透析終了日時
  to_char(ord.rst_end_date,''HH24MISS'') as end_date6,--透析終了日時
  to_char(ord.rst_end_date,''YYYY/MM/DD HH24:MI:SS'') as end_date14a,--透析終了日時
  to_char(ord.rst_end_date,''YYYY/MM/DD'') as end_date8a,--透析終了日時
  to_char(ord.rst_end_date,''HH24:MI:SS'') as end_date6a,--透析終了日時
  to_char(ord.rst_start_date,''HH24MI'') as start_time4,--透析開始時刻
  to_char(ord.rst_end_date,''HH24MI'') as end_time4,--透析終了時刻
  ord.rst_running_time as running_time,
  RIGHT(''00''||TRUNC(TO_NUMBER(ord.rst_cond_info->''1''->>''value'',''999999'')/60,0),2)||'':''||RIGHT(''00''||MOD(TO_NUMBER(ord.rst_cond_info->''1''->>''value'',''999999''),60),2) as treatment_time,
  to_char(timestamp ''now'',''YYYYMMDDHH24MISS'') as nowtime14,
  rst_bed_name as bed_name,
  ord_no as dialysis_no,
  rst_edition as edition,
  up_date as up_date
from
  ord_main as ord
where
  ord.ord_no = @ordNo', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'NEC-iS(MegaOakiS) 透析レポート', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-700007, 'select ''TAR'' || to_char(NOW(), ''YYYYMMDDHH24MISS'') || ''.tar'' as filename', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'NEC-iS(MegaOakiS) 透析レポート', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-700008, 'select journal.hosp_pat_id || lpad(trim(to_char(ord.ord_no, ''999999999999'')), 12, ''0'')  || lpad(trim(to_char(ord.rst_edition, ''9999'')), 4, ''0'') ||''.pdf'' as filename from sys_coop_journal journal  inner join ord_main ord on journal.ord_no = ord.ord_no where journal.ord_no = @ordNo and journal.direction = ''S'' and journal.ana_result = ''0'' and journal.is_del = ''0'' limit 1;', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'NEC-iS(MegaOakiS) 透析レポート', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-700009, 'select t.filename as filename from ( (select ''PatientInfo.xml'' as filename, 1 as key) union all (select ''pdfserverinfo.xml'' as filename, 2 as key) union all (select ''sample_001.xml'' as filename, 3 as key) union all (select ''sample_002.xml'' as filename, 4 as key) ) t where t.key = @key', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'NEC-iS(MegaOakiS) 透析レポート', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-700010, 'SELECT coalesce(( mcd.distribute_setting ->> ''protocolInfo'' ) :: json ->> ''hospPatIdLen'', ''0'') AS hosp_pat_id_len FROM mst_coop_distribute mcd WHERE mcd.facility_cd = @facilityCd  AND mcd.coop_cd = ''rep_dial''  AND mcd.coop_cd_index = ''listxml''  AND mcd.direction = ''S''', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'NEC-iS(MegaOakiS) 透析レポート', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
