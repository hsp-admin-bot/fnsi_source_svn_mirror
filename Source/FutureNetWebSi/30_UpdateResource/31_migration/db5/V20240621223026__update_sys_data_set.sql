DELETE FROM ntss.sys_data_set
WHERE sql_cd IN(-2020,-2021)
;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2021, '-- 【SQL_CD=-2021】
SELECT
    ntss_db6_ppm.hosp_pat_id AS hosppatid       -- 患者ID
    , CONCAT(personal_info_decrypt(ntss_db6_ppm.pat_last_name), ''　'', personal_info_decrypt(ntss_db6_ppm.pat_first_name)) AS name  -- 氏名
    , ntss_db6_ppm.pat_id AS patid              -- patid 外部キー
FROM
    pat_personal_main ntss_db6_ppm
WHERE
    ntss_db6_ppm.is_del != ''1''
    AND ntss_db6_ppm.facility_cd = @facilityCd', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者情報1：患者イベント テキスト　@facilityCd使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2020, '-- 【SQL_CD=-2020】
SELECT
    '''' AS hosppatid                             -- 患者ID
    , '''' AS name                               -- 氏名
    , ntss_db5_pm_json ->> ''ctl_no'' AS ctlno    -- 管理番号
    , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update -- 更新日時
    , ntss_db5_pm_json ->> ''content'' AS taboo   -- 禁忌
    , ntss_db5_pm_json ->> ''memo'' AS memo       -- 備考
    , ntss_db5_pm.pat_id AS patid               -- patid 外部キー
FROM
    pat_main ntss_db5_pm
    CROSS JOIN LATERAL jsonb_array_elements(ntss_db5_pm.taboo_allergy_info ::jsonb) ntss_db5_pm_json
WHERE
    ntss_db5_pm.is_del != ''1''
    AND ntss_db5_pm.facility_cd = @facilityCd', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者情報1：患者イベント テキスト　@facilityCd使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);