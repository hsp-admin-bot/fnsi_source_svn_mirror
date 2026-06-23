delete from ntss.sys_data_set where sql_cd in ('9620', '9621');
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (9620, 'select A.relationship_cd as relation_cd
from mst_relationship A
         left join (select mss.facility_cd,
                           ms.code,
                           row_number() over () as index
                    from mst_selector mss
                             cross join lateral jsonb_to_recordset(mss.order_settings -> ''items'') as ms
                        (code bigint, name text)
                    where facility_cd = ''999998''
                      and master_physical_name = ''mst_relationship''
) ms on A.facility_cd = ms.facility_cd and A.relationship_cd = ms.code
where A.facility_cd = @facilityCd
  and a.relationship_name = @otherContactInfo.relationName
order by ms.index', 2, '[{}]', '0', '{"applications": [4]}', null, '(受信用)日機装の患者プロファイル(連絡先情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, null);
INSERT INTO ntss.sys_data_set (sql_cd, sql, db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES (9621, 'with nameSplit as (select split_part(''@otherContactInfo.lastName'' ,'' '', 1) as lastName,
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
SET other_contact_info = REPLACE(other_contact_info::text, oldInfo.oldInfo::text, ''{
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
               }''::text)::jsonb
from nameSplit,oldInfo
WHERE is_del = ''0''
  AND hosp_pat_id = ''@hospPatId''
  AND facility_cd = ''@facilityCd''', 3, '[{}]', '0', '{"applications": [4]}', null, '(受信用)日機装の患者プロファイル(連絡先情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 9620, "field_name": "relation_cd", "replace_var": "@relationCd"}]');
