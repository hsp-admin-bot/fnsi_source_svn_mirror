DELETE FROM ntss.sys_data_set
WHERE sql_cd IN(-2504,-2508,-2051)
;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2504, 'WITH mst_medi AS (
    SELECT
        medicine_cd
        , in_hospital_cd_1 AS medicinecd1
        , in_hospital_cd_2 AS medicinecd2
        , up_date
    FROM
        mst_medicine
    WHERE
        facility_cd = @facilityCd
),
mst_medi_mix AS (
    SELECT
        medicine_mix_cd
        , in_hospital_cd_1 AS medicinecd1
        , in_hospital_cd_2 AS medicinecd2
        , up_date
    FROM
        mst_medicine_mix
    WHERE
        facility_cd = @facilityCd
),
mst_proc AS (
    SELECT
        procedure_cd
        , CAST(in_hosp_a_startdate as date) as in_hosp_a_startdate
        , in_hospital_cd_a1
        , in_hospital_cd_a2
        , CAST(in_hosp_b_startdate as date) as in_hosp_b_startdate
        , in_hospital_cd_b1
        , in_hospital_cd_b2
        , up_date
    FROM
        mst_procedure
    WHERE
        facility_cd = @facilityCd
)
SELECT
    '''' AS hosppatid                          --患者ID
    , ord_main.pat_id AS patid
    , ord_main.treat_date AS dialysisdate    --透析日
    , ord_main.ord_no AS dialysisno          --透析番号
    , ROW_NUMBER() OVER (PARTITION BY ord_main.ord_no ORDER BY CAST(ord_main_rmi_json ->> ''no'' AS int) ASC) AS ctlno --項目番号
    , to_char(ord_main.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    , CASE
        WHEN ord_main_rmi_json ->> ''medicine_type'' = ''1''
            THEN mst_medi.medicinecd1
        WHEN ord_main_rmi_json ->> ''medicine_type'' = ''2''
            THEN mst_medi_mix.medicinecd1
        ELSE NULL
        END AS medicinecd --薬剤コード(院内コード1)
    , CASE
        WHEN ord_main_rmi_json ->> ''medicine_type'' = ''1''
            THEN mst_medi.medicinecd2
        WHEN ord_main_rmi_json ->> ''medicine_type'' = ''2''
            THEN mst_medi_mix.medicinecd2
        ELSE NULL
        END AS medicinecd2 --薬剤コード(院内コード2)
    , ord_main_rmi_json ->> ''name'' AS medicinename    --薬剤名
    , ord_main_rmi_json ->> ''class_name'' AS mediclassname --薬剤分類名
    , ord_main_rmi_json ->> ''amount'' AS amount        --数量
    , ord_main_rmi_json ->> ''unit'' AS unit            --単位
    , ord_main_rmi_json ->> ''effect_flg'' AS effectflg --実施フラグ
    , CASE
        WHEN POSITION(
            ''T'' IN ord_main_rmi_json ->> ''effect_date''
        ) != 0
            THEN to_char(
            to_timestamp(
                ord_main_rmi_json ->> ''effect_date''
                , ''YYYY-MM-DDThh24:mi:ss''
            )
            , ''YYYY-MM-DD hh24:mi:ss''
            )
        ELSE ''''
        END AS effectdate --実施日時
    , ord_main_rmi_json ->> ''timing_name'' AS timingname --投与時間帯名
    , CASE
        WHEN CAST(ord_main.treat_date as DATE) >= mst_proc.in_hosp_a_startdate
        AND CAST(ord_main.treat_date as DATE) >= mst_proc.in_hosp_b_startdate
        THEN CASE
            WHEN mst_proc.in_hosp_a_startdate >= mst_proc.in_hosp_b_startdate
                THEN mst_proc.in_hospital_cd_a1
            WHEN mst_proc.in_hosp_a_startdate < mst_proc.in_hosp_b_startdate
                THEN mst_proc.in_hospital_cd_b1
            END
        WHEN CAST(ord_main.treat_date as DATE) >= mst_proc.in_hosp_a_startdate
        AND (CAST(ord_main.treat_date as DATE) < mst_proc.in_hosp_b_startdate
            OR mst_proc.in_hosp_b_startdate IS NULL)
            THEN mst_proc.in_hospital_cd_a1
        WHEN (CAST(ord_main.treat_date as DATE) < mst_proc.in_hosp_a_startdate
            OR mst_proc.in_hosp_a_startdate IS NULL)
        AND CAST(ord_main.treat_date as DATE) >= mst_proc.in_hosp_b_startdate
            THEN mst_proc.in_hospital_cd_b1
        ELSE NULL
        END AS procedurecd --手技コード(院内コード1)
    , CASE
        WHEN CAST(ord_main.treat_date as DATE) >= mst_proc.in_hosp_a_startdate
        AND CAST(ord_main.treat_date as DATE) >= mst_proc.in_hosp_b_startdate
        THEN CASE
            WHEN mst_proc.in_hosp_a_startdate >= mst_proc.in_hosp_b_startdate
                THEN mst_proc.in_hospital_cd_a2
            WHEN mst_proc.in_hosp_a_startdate < mst_proc.in_hosp_b_startdate
                THEN mst_proc.in_hospital_cd_b2
            END
        WHEN CAST(ord_main.treat_date as DATE) >= mst_proc.in_hosp_a_startdate
        AND (CAST(ord_main.treat_date as DATE) < mst_proc.in_hosp_b_startdate
            OR mst_proc.in_hosp_b_startdate IS NULL)
            THEN mst_proc.in_hospital_cd_a2
        WHEN (CAST(ord_main.treat_date as DATE) < mst_proc.in_hosp_a_startdate
            OR mst_proc.in_hosp_a_startdate IS NULL)
        AND CAST(ord_main.treat_date as DATE) >= mst_proc.in_hosp_b_startdate
            THEN mst_proc.in_hospital_cd_b2
        ELSE NULL
        END AS procedurecd2 --手技コード(院内コード2)
    , ord_main_rmi_json ->> ''procedure_name'' AS procedurename --手技名
    , '''' AS staffcd --実施者コード
    , ord_main_rmi_json ->> ''effect_user_id'' AS userid
    , CONCAT(
        ord_main_rmi_json ->> ''effect_user_last_name''
        , ''　''
        ,  ord_main_rmi_json ->> ''effect_user_first_name''
        ) AS staffname --実施者名
    , ord_main_rmi_json ->> ''comment'' AS comments --コメント
FROM
    ord_main
    CROSS JOIN LATERAL json_array_elements(ord_main.rst_medi_info ::json) ord_main_rmi_json
    LEFT JOIN mst_medi
        ON mst_medi.medicine_cd ::text = ord_main_rmi_json ->> ''cd''
    LEFT JOIN mst_medi_mix
        ON mst_medi_mix.medicine_mix_cd ::text = ord_main_rmi_json ->> ''cd''
    LEFT JOIN mst_proc
        ON mst_proc.procedure_cd ::text = ord_main_rmi_json ->> ''procedure_cd''
WHERE
    ord_main.facility_cd = @facilityCd
    AND ord_main.rst_dialysis_state IN (''1'',''2'',''3'',''4'',''5'')
    AND ord_main.is_del = ''0''
    AND ord_main.pat_id IS NOT NULL;
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid,userid"]}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);



INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2051, 'SELECT
	hosp_pat_id AS hosppatid,
	pat_id AS patid
FROM
	pat_personal_main 
WHERE facility_cd = @facilityCd;', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);



INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2508, 'SELECT
	CAST(user_id AS varchar) AS userid
	,disp_user_id AS staffcd
FROM
	mst_user_authentication 
WHERE facility_cd = @facilityCd;
', 1, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["userid"]}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);