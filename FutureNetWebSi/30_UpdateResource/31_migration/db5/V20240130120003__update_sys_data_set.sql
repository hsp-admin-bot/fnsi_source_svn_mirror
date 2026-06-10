DELETE FROM ntss.sys_data_set
WHERE sql_cd IN(-2030)
;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2030, '-- 【SQL_CD=-2030】
select
    ntss_db6_ppm.hosp_pat_id AS patid --患者ID
    ,REPLACE(personal_info_decrypt(ntss_db6_ppm.pat_last_name)|| ''　'' ||personal_info_decrypt(ntss_db6_ppm.pat_first_name), ''"'','''') AS name --氏名
    ,''0'' AS ctlno --管理番号
    ,to_char(ntss_db6_ppm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    ,to_char(ntss_db6_ppm.reg_date, ''YYYY-MM-DD hh24:mi:ss'') AS regdate --登録日時
    ,''本人'' as relationname
    ,REPLACE(personal_info_decrypt(ntss_db6_ppm.pat_last_name)|| ''　'' ||personal_info_decrypt(ntss_db6_ppm.pat_first_name), ''"'','''') AS name --連絡先氏名（本人と同じ）
    ,REPLACE(personal_info_decrypt(ntss_db6_ppm.pat_contact_info ->> ''zip_co''), ''"'', '''') AS zipcode --郵便番号
    ,REPLACE(personal_info_decrypt(ntss_db6_ppm.pat_contact_info ->> ''address''), ''"'','''') AS address --住所(市町村）
    ,'''' AS addressdetail --住所(番地アパート）
    ,REPLACE(personal_info_decrypt(ntss_db6_ppm.pat_contact_info ->> ''tel1''), ''"'','''') AS telno1 --電話番号１
    ,REPLACE(personal_info_decrypt(ntss_db6_ppm.pat_contact_info ->> ''tel2''), ''"'','''') AS telno2 --電話番号２
    ,REPLACE(personal_info_decrypt(ntss_db6_ppm.pat_contact_info ->> ''memo1''), ''"'','''') AS memo --メモ
    FROM
        pat_personal_main as ntss_db6_ppm
    WHERE
        ntss_db6_ppm.is_del != ''1''
        AND ntss_db6_ppm.facility_cd = @facilityCd
UNION ALL
select
    ntss_db6_ppm.hosp_pat_id AS patid --患者ID
    ,REPLACE(personal_info_decrypt(ntss_db6_ppm.pat_last_name)|| ''　'' ||personal_info_decrypt(ntss_db6_ppm.pat_first_name), ''"'','''') AS name --氏名
    ,ntss_db6_ppm_json ->> ''ctl_no'' AS ctlno --管理番号
    ,to_char(ntss_db6_ppm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    ,to_char(ntss_db6_ppm.reg_date, ''YYYY-MM-DD hh24:mi:ss'') AS regdate --登録日時
    ,REPLACE(personal_info_decrypt(ntss_db6_ppm_json ->> ''relation_name''), ''"'','''') AS relationname --続柄
    ,REPLACE(personal_info_decrypt(ntss_db6_ppm_json ->> ''last_name'')|| ''　'' || personal_info_decrypt(ntss_db6_ppm_json ->> ''first_name''), ''"'','''') AS rname --連絡先氏名
    ,REPLACE(personal_info_decrypt(ntss_db6_ppm_json ->> ''zip_cd''), ''"'', '''') AS zipcode --郵便番号
    ,REPLACE(personal_info_decrypt(ntss_db6_ppm_json ->> ''address''), ''"'','''') AS address --住所(市町村）
    ,'''' AS addressdetail --住所(番地アパート）
    ,REPLACE(personal_info_decrypt(ntss_db6_ppm_json ->> ''tel1''), ''"'','''') AS telno1 --電話番号１
    ,REPLACE(personal_info_decrypt(ntss_db6_ppm_json ->> ''tel2''), ''"'','''') AS telno2 --電話番号２
    ,REPLACE(personal_info_decrypt(ntss_db6_ppm_json ->> ''memo1''),''"'','''') AS memo --メモ
    FROM
        pat_personal_main ntss_db6_ppm
    CROSS JOIN lateral
        json_array_elements(ntss_db6_ppm.other_contact_info ::json) ntss_db6_ppm_json
    WHERE
        ntss_db6_ppm.is_del != ''1''
        AND cast (ntss_db6_ppm_json ->> ''ctl_no'' as integer) > 0
        AND ntss_db6_ppm.facility_cd = @facilityCd
ORDER BY patid,ctlno', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者情報1：患者イベント テキスト　@facilityCd使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);