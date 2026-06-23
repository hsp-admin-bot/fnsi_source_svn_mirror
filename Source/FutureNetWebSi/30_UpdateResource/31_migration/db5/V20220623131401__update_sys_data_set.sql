delete from ntss.sys_data_set where sql_cd = '7102';
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (7102, 'with nameSplit as (select split_part(''@otherContactInfo.lastName'' ,'' '', 1) as lastName,
                          split_part(''@otherContactInfo.lastName'' ,'' '', 2) as firstName),
     dup as (select (case when count(1) >= 1 then 1 else 0 end) as checkDup
                FROM pat_personal_main
                 CROSS JOIN jsonb_array_elements(personal_info_decrypt_jsonb(other_contact_info)) WITH ORDINALITY arr(j, idx), nameSplit
                    WHERE is_del = ''0''
                      AND hosp_pat_id = ''@hospPatId''
                      and (((j ->> ''first_name'')::text = nameSplit.firstName
                                   and (j ->> ''last_name'')::text = nameSplit.lastName)
                        or (j ->> ''last_name'')::text = ''@otherContactInfo.lastName'')),
     oldInfo as (select (other_contact_info ->> (idx - 1)::int)::json AS oldInfo
                 FROM pat_personal_main CROSS JOIN jsonb_array_elements(personal_info_decrypt_jsonb(other_contact_info)) WITH ORDINALITY arr(j, idx), nameSplit
                 WHERE (((j ->> ''first_name'')::text = nameSplit.firstName
               and (j ->> ''last_name'')::text = nameSplit.lastName)
    or (j ->> ''last_name'')::text = ''@otherContactInfo.lastName'')
                   and is_del = ''0''
                   AND hosp_pat_id = ''@hospPatId''
                   AND facility_cd = ''@facilityCd'')
UPDATE pat_personal_main
SET other_contact_info = (CASE
            ''@otherContactInfoFlg''
             WHEN '''' THEN
                 ''@otherContactInfoValue''
             ELSE (case when ''@otherContactInfo.relationName'' <> ''本人'' and dup.checkDup = ''0'' then other_contact_info || cast(''[
               {
                 "ctl_no": "@otherContactInfo.ctlNo",
                 "disp_order": "@otherContactInfo.dispOrder",
                 "is_key_person": "@otherContactInfo.isKeyPerson",
                 "pat_id": "@otherContactInfo.patId",
                 "last_name": "''||nameSplit.lastName||''",
                 "first_name": "''||nameSplit.firstName||''",
                 "last_name_kana": "@otherContactInfo.lastNmKana",
                 "first_name_kana": "@otherContactInfo.firstNmKana",
                 "relation_cd": ''||@relationCd||'',
                 "relation_name": "@otherContactInfo.relationName",
                 "zip_cd": "@otherContactInfo.zipCd",
                 "address": "@otherContactInfo.address",
                 "e_mail": "@otherContactInfo.eMail",
                 "work_name": "@otherContactInfo.workName",
                 "work_tel": "@otherContactInfo.workTel",
                 "tel1": "@otherContactInfo.tel1",
                 "tel2": "@otherContactInfo.tel2",
                 "fax": "@otherContactInfo.fax",
                 "memo1": "@otherContactInfo.memo1",
                 "memo2": "@otherContactInfo.memo2"
               }
             ]'' as text) :: jsonb else ''@otherContactInfoValue'' end)
            END)::jsonb,
    pat_contact_info   = (CASE
                              when
                                  ''@otherContactInfoFlg'' <> '''' and ''@otherContactInfo.relationName'' = ''本人''
                                  THEN
                                  ''
                                  {
                                    "fax": "@otherContactInfo.fax",
                                    "tel1": "@otherContactInfo.tel1",
                                    "tel2": "@otherContactInfo.tel2",
                                    "memo1": "@otherContactInfo.memo1",
                                    "memo2": "@otherContactInfo.memo2",
                                    "e_mail": "@otherContactInfo.eMail",
                                    "zip_cd": "@otherContactInfo.zipCd",
                                    "address": "@otherContactInfo.address",
                                    "work_tel": "@otherContactInfo.workTel",
                                    "work_name": "@otherContactInfo.workName",
                                    "work_address": "@otherContactInfo.workAddress"
                                  }
                                  '' :: jsonb
                              ELSE pat_contact_info
        END)
from dup,nameSplit,oldInfo
WHERE is_del = ''0''
  AND hosp_pat_id = ''@hospPatId''
  AND facility_cd = ''@facilityCd''', 3, '[{}]', '0', '{"applications": [4]}', null, '(受信用)日機装の患者プロファイル(連絡先情報)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, '[{"sql_cd": 9620, "field_name": "relation_cd", "replace_var": "@relationCd"}]');
