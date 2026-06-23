DELETE FROM ntss.sys_data_set
WHERE sql_cd IN(-2230,-2231,-2232,-2051)
;


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2230, 'WITH ntss_db5_mst_m AS (
    SELECT
        ntss_db5_mst_m.medicine_cd
        , ntss_db5_mst_m.in_hospital_cd_1
        , ntss_db5_mst_m.in_hospital_cd_2
    FROM
        mst_medicine ntss_db5_mst_m
    WHERE
        ntss_db5_mst_m.facility_cd = @facilityCd
)
SELECT
    '''' AS hosppatid                             --患者ID
    , ntss_db5_op.pat_id AS patid
    , ntss_db5_op.ord_prescription_no AS prescriptno --処方番号
    , to_char(ntss_db5_op.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    , ntss_db5_op.issue_date AS executedate     --交付日
    , REPLACE(ntss_db5_op_pd_json ->> ''Rp'', ''Rp'', '''') AS ctlno --項目番号
    , CASE
        WHEN ntss_db5_op_pd_json ->> ''type'' = ''1''
            THEN ntss_db5_op_pd_json ->> ''F1''
        END AS medicinename                     --薬剤名
    , CASE
        WHEN ntss_db5_op_pd_json ->> ''type'' = ''1''
        AND ntss_db5_op_pd_json ->> ''medicine_type'' = ''1''
            THEN ntss_db5_mst_m.in_hospital_cd_1
        END AS medicinecd                       --薬剤コード(院内コード1)
    , CASE
        WHEN ntss_db5_op_pd_json ->> ''type'' = ''1''
        AND ntss_db5_op_pd_json ->> ''medicine_type'' = ''1''
            THEN ntss_db5_mst_m.in_hospital_cd_2
        END AS medicinecd2                      --薬剤コード(院内コード2)
    , CASE
        WHEN ntss_db5_op_pd_json ->> ''type'' = ''1''
            THEN ntss_db5_op_pd_json ->> ''F5''
        END AS quantity                         --分量
    , ntss_db5_op_pd_json ->> ''F6'' AS unit      --単位
    , '''' AS dosage                           --用量
    , '''' AS takemedicinecd --用法コード
    , CASE
        WHEN ntss_db5_op_pd_json ->> ''type'' BETWEEN ''2'' AND''5''
            THEN ntss_db5_op_pd_json ->> ''R''
        END AS takemedicinename                 --用法名
    , CASE
        WHEN ntss_db5_op_pd_json ->> ''type'' BETWEEN ''2'' AND''5''
            THEN ntss_db5_op_pd_json ->> ''F5''
        END  AS daycount --調剤日数
    , '''' AS prescriptercd                       --処方者コード
    , '''' AS prescriptername                     --処方者名
    , '''' AS note                                --備考
    , '''' AS userid
FROM
    ord_prescription ntss_db5_op
    CROSS JOIN LATERAL jsonb_array_elements(ntss_db5_op.prescription_detail ::jsonb) ntss_db5_op_pd_json
    LEFT JOIN ntss_db5_mst_m
        ON ntss_db5_mst_m.medicine_cd ::text = ntss_db5_op_pd_json ->> ''medicine_cd''
WHERE
    ntss_db5_op.is_del = ''0''
    AND ntss_db5_op.facility_cd = @facilityCd
    AND ntss_db5_op_pd_json ->> ''type'' BETWEEN ''1'' AND''5''
    AND @fromDate <= ntss_db5_op.issue_date AND ntss_db5_op.issue_date < @toDate;
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid,userid,prescriptno"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2231, 'SELECT
    ntss_db6_mst_opp.ord_prescription_no AS prescriptno
    , ntss_db6_mst_opp.insu_dr_id AS userid
    , personal_info_decrypt(ntss_db6_mst_opp.insu_dr_name) AS prescriptername
    , personal_info_decrypt(ntss_db6_mst_opp.remarks_free) AS note
FROM
    ord_personal_prescription ntss_db6_mst_opp
WHERE
    ntss_db6_mst_opp.facility_cd = @facilityCd
', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["prescriptno"]}', '2026-02-01 17:51:54.726', CURRENT_TIMESTAMP, NULL);


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2232, 'SELECT
	ntss_db4_mst_ua.user_id AS userid
	,ntss_db4_mst_ua.disp_user_id AS prescriptercd --処方者コード
FROM
	mst_user_authentication ntss_db4_mst_ua
WHERE
    ntss_db4_mst_ua.facility_cd = @facilityCd;
', 1, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["userid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2051, 'SELECT
	hosp_pat_id AS hosppatid,
	pat_id AS patid
FROM
	pat_personal_main 
WHERE facility_cd = @facilityCd;', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
