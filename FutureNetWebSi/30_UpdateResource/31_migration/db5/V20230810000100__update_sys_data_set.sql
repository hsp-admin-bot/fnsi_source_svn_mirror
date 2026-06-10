DELETE FROM ntss.sys_data_set WHERE sql_cd = '9621';
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (9621, 'with nameSplit as (select split_part(''@otherContactInfo.lastName'' ,'' '', 1) as lastName,
                          split_part(''@otherContactInfo.lastName'' ,'' '', 2) as firstName),
     oldInfo as (select (other_contact_info ->> (idx - 1)::int)::json AS oldInfo
                 FROM pat_personal_main CROSS JOIN jsonb_array_elements(personal_info_decrypt_jsonb(other_contact_info)) WITH ORDINALITY arr(j, idx), nameSplit
                 WHERE (((j ->> ''first_name'')::text = nameSplit.firstName
               and (j ->> ''last_name'')::text = nameSplit.lastName)
    or (j ->> ''last_name'')::text = ''@otherContactInfo.lastName'')
                   and is_del = ''0''
                   AND hosp_pat_id = ''@hospPatId''
                   AND facility_cd = ''@facilityCd'')
UPDATE pat_personal_main
SET 
	up_date = CURRENT_TIMESTAMP,
other_contact_info = REPLACE(other_contact_info::text, oldInfo.oldInfo::text, jsonb_build_object(
                 ''ctl_no'',''@otherContactInfo.ctlNo''
                 ,''disp_order'',''@otherContactInfo.dispOrder''
                 ,''is_key_person'',oldInfo.oldInfo ->> ''is_key_person''
                 ,''pat_id'',oldInfo.oldInfo ->> ''pat_id''
                 ,''last_name'',nameSplit.lastName
                 ,''first_name'',nameSplit.firstName
                 ,''last_name_kana'',oldInfo.oldInfo ->> ''last_name_kana''
                 ,''first_name_kana'',oldInfo.oldInfo ->> ''first_name_kana''
                 ,''relation_cd'',CASE ''@relationCd'' WHEN ''@''||''relationCd'' THEN null ELSE ''@relationCd'' END
                 ,''relation_name'',''@otherContactInfo.relationName''
                 ,''zip_cd'',''@otherContactInfo.zipCd''
                 ,''address'',''@otherContactInfo.address''
                 ,''e_mail'',oldInfo.oldInfo ->> ''e_mail''
                 ,''work_name'',oldInfo.oldInfo ->> ''work_name''
                 ,''work_tel'',oldInfo.oldInfo ->> ''work_tel''
                 ,''tel1'',''@otherContactInfo.tel1''
                 ,''tel2'',''@otherContactInfo.tel2''
                 ,''fax'',oldInfo.oldInfo ->> ''fax''
                 ,''memo1'',oldInfo.oldInfo ->> ''memo1''
                 ,''memo2'',oldInfo.oldInfo ->> ''memo2''
)::text)::jsonb
from nameSplit,oldInfo
WHERE is_del = ''0''
  AND hosp_pat_id = ''@hospPatId''
  AND facility_cd = ''@facilityCd''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(連絡先情報)', '2022-06-27 12:39:15.173', CURRENT_TIMESTAMP, '[{"sql_cd": 9620, "field_name": "relation_cd", "replace_var": "@relationCd"}]');
