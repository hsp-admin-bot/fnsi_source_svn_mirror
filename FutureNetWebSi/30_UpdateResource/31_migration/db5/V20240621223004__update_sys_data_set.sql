DELETE FROM ntss.sys_data_set
WHERE sql_cd IN(-2291)
;


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2291, 'SELECT
    RIGHT(ntss_db5_mst_wsp.in_hospital_cd_1 ,5) AS surveypointcd --調査箇所コード
    ,ntss_db5_mst_wsp.point_name AS surveypointname --調査箇所名
    ,to_char(ntss_db5_mnt_ws.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    ,to_char(ntss_db5_mnt_ws.inspection_date, ''YYYYMMDD'') AS checkdate --調査日
    ,ntss_db5_om_sd_json ->> ''value'' AS result --調査結果値
    ,ntss_db5_om_sd_json ->> ''unit'' AS unit --単位
    ,ntss_db5_om_sd_json ->> ''memo'' AS detail --調査結果詳細
    ,ntss_db5_mnt_ws.survey_record_no AS surveyno --調査番号
FROM
    mnt_water_survey ntss_db5_mnt_ws
    CROSS JOIN LATERAL jsonb_array_elements(ntss_db5_mnt_ws.survey_data ::jsonb) ntss_db5_om_sd_json
    LEFT JOIN mst_water_survey_point ntss_db5_mst_wsp
        ON ntss_db5_mst_wsp.survey_point_cd :: text = ntss_db5_om_sd_json ->> ''point_cd''
WHERE
    ntss_db5_mnt_ws.facility_cd = @facilityCd
    AND @fromDate <= ntss_db5_mnt_ws.inspection_date AND ntss_db5_mnt_ws.inspection_date < @toDate;
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": [""]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);