DELETE FROM ntss.sys_data_set
WHERE sql_cd IN(-2250,-2051)
;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2250, 'SELECT 
    '''' AS hosppatid --患者ID
    ,ord_main.pat_id AS patid
    ,to_char(cast(rti_json ->> ''occur_date'' as timestamp), ''YYYY-MM-DD hh24:mi:ss'') AS occurdate --発生日時
    ,rti_json ->> ''treat_class'' AS measureclass --区分
    ,'''' AS reqcode --愁訴コード
    ,'''' AS complaint --愁訴内容
    ,rti_json ->> ''treat_name'' AS treatname --処置名
    ,CASE
        WHEN rti_json ->> ''medicine_type'' = ''1'' THEN medi.in_hospital_cd_1
        WHEN rti_json ->> ''medicine_type'' = ''2'' THEN medi_mix.in_hospital_cd_1
        WHEN rti_json ->> ''medicine_type'' IS NULL THEN 
            CASE
                WHEN rti_json ->> ''treat_class'' = ''0'' THEN medi_mix.in_hospital_cd_1
                WHEN rti_json ->> ''treat_class'' = ''1'' THEN medi.in_hospital_cd_1
            END
     END AS medicinecd1 --薬剤コード1
    ,CASE
        WHEN rti_json ->> ''medicine_type'' = ''1'' THEN medi.in_hospital_cd_2
        WHEN rti_json ->> ''medicine_type'' = ''2'' THEN medi_mix.in_hospital_cd_2
        WHEN rti_json ->> ''medicine_type'' IS NULL THEN 
            CASE
                WHEN rti_json ->> ''treat_class'' = ''0'' THEN medi_mix.in_hospital_cd_2
                WHEN rti_json ->> ''treat_class'' = ''1'' THEN medi.in_hospital_cd_2
            END
     END AS medicinecd2 --薬剤コード2
    ,rti_json ->> ''treat_medicine_name'' AS medicinename --薬剤名称
    ,rti_json ->> ''amount'' AS amount --数量
    ,rti_json ->> ''unit'' AS unit --単位
    ,rti_json ->> ''procedure_name'' AS procedurename --手技名
    ,CASE
        WHEN cast(rti_json ->> ''occur_date'' as timestamp) > prod.in_hosp_a_startdate THEN --aが過去
            CASE
                WHEN prod.in_hosp_a_startdate > prod.in_hosp_b_startdate THEN --aの方が発生日に近い
                    prod.in_hospital_cd_a1 --abどちらも過去でaが発生日に近いパターン
                WHEN cast(rti_json ->> ''occur_date'' as timestamp) > prod.in_hosp_b_startdate THEN --bが過去
                    prod.in_hospital_cd_b1 --abどちらも過去でbが発生日に近いパターン
                ELSE
                    prod.in_hospital_cd_a1 --aのみ過去のパターン
            END
        ELSE
            CASE
                WHEN cast(rti_json ->> ''occur_date'' as timestamp) > prod.in_hosp_b_startdate THEN --bが過去
                    prod.in_hospital_cd_b1 --bのみ過去のパターン
            END
        END AS procedurecd1 --手技コード1
    ,CASE
        WHEN cast(rti_json ->> ''occur_date'' as timestamp) > prod.in_hosp_a_startdate THEN --aが過去
            CASE
                WHEN prod.in_hosp_a_startdate > prod.in_hosp_b_startdate THEN --aの方が発生日に近い
                    prod.in_hospital_cd_a2 --abどちらも過去でaが発生日に近いパターン
                WHEN cast(rti_json ->> ''occur_date'' as timestamp) > prod.in_hosp_b_startdate THEN --bが過去
                    prod.in_hospital_cd_b2 --abどちらも過去でbが発生日に近いパターン
                ELSE
                    prod.in_hospital_cd_a2 --aのみ過去のパターン
            END
        ELSE
            CASE
                WHEN cast(rti_json ->> ''occur_date'' as timestamp) > prod.in_hosp_b_startdate THEN --bが過去
                    prod.in_hospital_cd_b2 --bのみ過去のパターン
            END
        END AS procedurecd2 --手技コード2
    ,'''' AS treatpersonname --処置者名
    ,to_char(ord_main.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    ,ord_main.ord_no AS ordno --透析番号
    ,'''' AS compcd --愁訴マスタコード
    ,rti_json ->> ''treat_cd'' AS treatcd --処置マスタコード
    ,ord_main.treat_date AS dialysisdate --透析日
FROM
    ord_main
    CROSS JOIN LATERAL json_array_elements(ord_main.rst_treatment_info ::json) rti_json
    LEFT JOIN mst_medicine_mix medi_mix
        ON medi_mix.medicine_mix_cd :: text = rti_json ->> ''treat_medicine_cd''
    LEFT JOIN mst_medicine medi
        ON medi.medicine_cd :: text = rti_json ->> ''treat_medicine_cd''
    LEFT JOIN mst_procedure prod
        ON prod.procedure_cd :: text = rti_json ->> ''procedure_cd''
WHERE
    ord_main.facility_cd = @facilityCd
    AND @fromDate <= treat_date AND treat_date < @toDate
UNION ALL
SELECT 
    '''' AS hosppatid --患者ID
    ,ord_main.pat_id AS patid
    ,to_char(cast(rci_json ->> ''occur_date'' as timestamp), ''YYYY-MM-DD hh24:mi:ss'') AS occurdate --発生日時
    ,'''' AS measureclass --区分
    ,comp.in_hospital_cd_1 AS reqcode --愁訴コード
    ,rci_json ->> ''complaint'' AS complaint --愁訴内容
    ,'''' AS treatname --処置名
    ,'''' AS medicinecd1 --薬剤コード1
    ,'''' AS medicinecd2 --薬剤コード2
    ,'''' AS medicinename --薬剤名称
    ,'''' AS amount --数量
    ,'''' AS unit --単位
    ,'''' AS procedurename --手技名
    ,'''' AS procedurecd1 --手技コード1
    ,'''' AS procedurecd2 --手技コード2
    ,'''' AS treatpersonname --処置者名
    ,to_char(ord_main.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    ,ord_main.ord_no AS ordno --透析番号
    ,rci_json ->> ''comp_cd'' AS compcd --愁訴マスタコード
    ,'''' AS treatcd --処置マスタコード
    ,ord_main.treat_date AS dialysisdate --透析日
FROM
    ord_main
    CROSS JOIN LATERAL json_array_elements(ord_main.rst_complaint_info ::json) rci_json
    LEFT JOIN mst_complaint comp
        ON comp.complaint_cd :: text = rci_json ->> ''comp_cd''
WHERE
    ord_main.facility_cd = @facilityCd
    AND @fromDate <= treat_date AND treat_date < @toDate
UNION ALL
SELECT 
    '''' AS hosppatid --患者ID
    ,ord_main.pat_id AS patid
    ,to_char(cast(rtsi_json ->> ''occur_date'' as timestamp), ''YYYY-MM-DD hh24:mi:ss'') AS occurdate --発生日時
    ,'''' AS measureclass --区分
    ,'''' AS reqcode --愁訴コード
    ,'''' AS complaint --愁訴内容
    ,'''' AS treatname --処置名
    ,'''' AS medicinecd1 --薬剤コード1
    ,'''' AS medicinecd2 --薬剤コード2
    ,'''' AS medicinename --薬剤名称
    ,'''' AS amount --数量
    ,'''' AS unit --単位
    ,'''' AS procedurename --手技名
    ,'''' AS procedurecd1 --手技コード1
    ,'''' AS procedurecd2 --手技コード2
    ,rtsi_json ->> ''treat_staff_name'' AS treatpersonname --処置者名
    ,to_char(ord_main.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    ,ord_main.ord_no AS ordno --透析番号
    ,'''' AS compcd --愁訴マスタコード
    ,'''' AS treatcd --処置マスタコード
    ,ord_main.treat_date AS dialysisdate --透析日
FROM
    ord_main
    CROSS JOIN LATERAL json_array_elements(ord_main.rst_treat_staff_info ::json) rtsi_json
WHERE
    ord_main.facility_cd = @facilityCd
    AND @fromDate <= treat_date AND treat_date < @toDate;
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);



INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2051, 'SELECT
	hosp_pat_id AS hosppatid,
	pat_id AS patid
FROM
	pat_personal_main 
WHERE facility_cd = @facilityCd;', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
