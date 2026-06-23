delete from ntss.sys_data_set where sql_cd = '7102';
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (7102, 'with dup as (select (case when count(1) >= 1 then 1 else 0 end) as checkDup
             FROM pat_personal_main,
                 jsonb_array_elements(other_contact_info) WITH ORDINALITY
             WHERE is_del = ''0''
               AND hosp_pat_id = ''@hospPatId''
               AND (value ->> ''first_name'')::text || (value ->> ''last_name'')::text = ''@otherContactInfo.firstName'' || ''@otherContactInfo.lastName'')
UPDATE pat_personal_main
SET other_contact_info =
        (CASE
            ''@otherContactInfoFlg''
             WHEN '''' THEN
                 ''@otherContactInfoValue''
             ELSE (case when ''@otherContactInfo.relationName'' <> ''本人'' and dup.checkDup = ''0'' then other_contact_info || ''[
               {
                 "ctl_no": "@otherContactInfo.ctlNo",
                 "disp_order": "@otherContactInfo.dispOrder",
                 "is_key_person": "@otherContactInfo.isKeyPerson",
                 "pat_id": "@otherContactInfo.patId",
                 "last_name": "@otherContactInfo.lastName",
                 "first_name": "@otherContactInfo.firstName",
                 "last_name_kana": "@otherContactInfo.lastNmKana",
                 "first_name_kana": "@otherContactInfo.firstNmKana",
                 "relation_cd": "@otherContactInfo.relationCd",
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
             ]'' :: jsonb else ''@otherContactInfoValue'' end)
            END),
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
from dup
WHERE is_del = ''0''
  AND hosp_pat_id = ''@hospPatId''
  AND facility_cd = ''@facilityCd''', 3, '[{}]', '0', '{"applications": [4]}', null, '(受信用)日機装の患者プロファイル(連絡先情報)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, null);
