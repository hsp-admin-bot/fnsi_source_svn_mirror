DELETE FROM ntss.sys_data_set
WHERE sql_cd IN(-2030)
;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2030, '-- 【SQL_CD=-2030】
select
    ntss_db6_ppm.hosp_pat_id AS hosppatid --患者ID
    ,CONCAT(personal_info_decrypt(ntss_db6_ppm.pat_last_name), ''　'', personal_info_decrypt(ntss_db6_ppm.pat_first_name)) AS name --氏名
    ,''0'' AS ctlno --管理番号
    ,to_char(ntss_db6_ppm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    ,to_char(ntss_db6_ppm.reg_date, ''YYYY-MM-DD hh24:mi:ss'') AS regdate --登録日時
    ,''本人'' as relationname
    ,CONCAT(personal_info_decrypt(ntss_db6_ppm.pat_last_name), ''　'', personal_info_decrypt(ntss_db6_ppm.pat_first_name)) AS rname --連絡先氏名（本人と同じ）
    ,regexp_replace(info_unescape(personal_info_decrypt(ntss_db6_ppm.pat_contact_info ->> ''zip_cd'')), ''^"|"$'', '''', ''g'') AS zipcode --郵便番号
    ,regexp_replace(info_unescape(personal_info_decrypt(ntss_db6_ppm.pat_contact_info ->> ''address'')), ''^"|"$'', '''', ''g'') AS address --住所(市町村）
    ,'''' AS addressdetail --住所(番地アパート）
    ,regexp_replace(info_unescape(personal_info_decrypt(ntss_db6_ppm.pat_contact_info ->> ''tel1'')), ''^"|"$'', '''', ''g'') AS telno1 --電話番号１
    ,regexp_replace(info_unescape(personal_info_decrypt(ntss_db6_ppm.pat_contact_info ->> ''tel2'')), ''^"|"$'', '''', ''g'') AS telno2 --電話番号２
    ,regexp_replace(info_unescape(personal_info_decrypt(ntss_db6_ppm.pat_contact_info ->> ''memo1'')), ''^"|"$'', '''', ''g'') AS memo --メモ
    FROM
        pat_personal_main as ntss_db6_ppm
    WHERE
        ntss_db6_ppm.is_del != ''1''
        AND ntss_db6_ppm.facility_cd = @facilityCd
UNION ALL
select
    ntss_db6_ppm.hosp_pat_id AS hosppatid --患者ID
    ,CONCAT(personal_info_decrypt(ntss_db6_ppm.pat_last_name), ''　'', personal_info_decrypt(ntss_db6_ppm.pat_first_name)) AS name --氏名
    ,ntss_db6_ppm_json ->> ''ctl_no'' AS ctlno --管理番号
    ,to_char(ntss_db6_ppm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    ,to_char(ntss_db6_ppm.reg_date, ''YYYY-MM-DD hh24:mi:ss'') AS regdate --登録日時
    ,regexp_replace(info_unescape(personal_info_decrypt(ntss_db6_ppm_json ->> ''relation_name'')), ''^"|"$'', '''', ''g'') AS relationname --続柄
    ,info_unescape(CONCAT(regexp_replace(personal_info_decrypt(ntss_db6_ppm_json ->> ''last_name''), ''^"|"$'', '''', ''g''), ''　'', regexp_replace(personal_info_decrypt(ntss_db6_ppm_json ->> ''first_name''), ''^"|"$'', '''', ''g'')))AS rname --連絡先氏名
    ,regexp_replace(info_unescape(personal_info_decrypt(ntss_db6_ppm_json ->> ''zip_cd'')), ''^"|"$'', '''', ''g'') AS zipcode --郵便番号
    ,regexp_replace(info_unescape(personal_info_decrypt(ntss_db6_ppm_json ->> ''address'')), ''^"|"$'', '''', ''g'') AS address --住所(市町村）
    ,'''' AS addressdetail --住所(番地アパート）
    ,regexp_replace(info_unescape(personal_info_decrypt(ntss_db6_ppm_json ->> ''tel1'')), ''^"|"$'', '''', ''g'') AS telno1 --電話番号１
    ,regexp_replace(info_unescape(personal_info_decrypt(ntss_db6_ppm_json ->> ''tel2'')), ''^"|"$'', '''', ''g'') AS telno2 --電話番号２
    ,regexp_replace(info_unescape(personal_info_decrypt(ntss_db6_ppm_json ->> ''memo1'')), ''^"|"$'', '''', ''g'') AS memo --メモ
    FROM
        pat_personal_main ntss_db6_ppm
    CROSS JOIN lateral
        jsonb_array_elements(ntss_db6_ppm.other_contact_info ::jsonb) ntss_db6_ppm_json
    WHERE
        ntss_db6_ppm.is_del != ''1''
        AND ntss_db6_ppm_json ->> ''ctl_no'' != ''0''
        AND ntss_db6_ppm.facility_cd = @facilityCd;
', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者情報1：患者イベント テキスト　@facilityCd使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);