DELETE FROM ntss.sys_data_set
WHERE sql_cd IN(-2210,-2221,-2051)
;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2210, 'WITH mst_treatment_disp_order_tbl AS (
    SELECT
        one_json ->> ''code'' AS treatment_cd
        , json_idx AS treatment_cd_order
    FROM
        mst_selector
        CROSS JOIN lateral jsonb_array_elements(order_settings -> ''items'') with ordinality AS tmp(one_json, json_idx)
    WHERE
        facility_cd = @facilityCd
        AND master_physical_name = ''mst_treatment''
)
,ntss_db5_om_1 as (
    SELECT
        ntss_db5_om_1.ord_no
        , ROW_NUMBER() OVER (PARTITION BY ntss_db5_om_1.pat_id, ntss_db5_om_1.treat_date ORDER BY ntss_db5_om_1.ind_treat_start_time ASC, mst_treatment_disp_order_tbl.treatment_cd_order ASC) AS plural
    FROM
        ord_main ntss_db5_om_1
        LEFT JOIN mst_treatment_disp_order_tbl
        ON ntss_db5_om_1.ind_treatment_cd ::text = mst_treatment_disp_order_tbl.treatment_cd
    WHERE
        ntss_db5_om_1.facility_cd = @facilityCd
    AND @fromDate <= ntss_db5_om_1.treat_date AND ntss_db5_om_1.treat_date < @toDate
)
, ntss_db5_om_temp AS (
    SELECT
        ntss_db5_om.ord_no AS ord_no
        , CAST(ntss_db5_om.treat_date as DATE) as treat_date
        , row_number() over (PARTITION BY ntss_db5_om.ord_no ORDER BY cast(ntss_db5_om_imi_json ->> ''no'' as int) ASC) AS ctlno --項目番号
        , ntss_db5_om_imi_json ->> ''cd'' AS cd
        , ntss_db5_om_imi_json ->> ''medicine_type'' AS medicine_type
        , ntss_db5_om_imi_json ->> ''class_cd'' AS class_cd
        , ntss_db5_om_imi_json ->> ''amount'' AS amount --数量
        , ntss_db5_om_imi_json ->> ''timing_cd'' AS timing_cd
        , ntss_db5_om_imi_json ->> ''procedure_cd'' AS procedure_cd
        , ntss_db5_om_imi_json ->> ''comment'' AS comment --コメント
        , ntss_db5_om_imi_json ->> ''ind_user_id'' AS ind_user_id
    FROM
        ord_main ntss_db5_om
        CROSS JOIN LATERAL jsonb_array_elements(ntss_db5_om.ind_medi_info ::jsonb) ntss_db5_om_imi_json
    WHERE
        ntss_db5_om.facility_cd = @facilityCd
        AND @fromDate <= ntss_db5_om.treat_date AND ntss_db5_om.treat_date < @toDate
        AND ntss_db5_om.is_del = ''0''
)
,ntss_db5_mst_m AS (
    SELECT
        medicine_cd
        , in_hospital_cd_1
        , in_hospital_cd_2
        , medicine_name
        , unit
        , up_date
    FROM
        mst_medicine ntss_db5_mst_m
    WHERE
        ntss_db5_mst_m.facility_cd = @facilityCd
)
,ntss_db5_mst_m_mix AS (
    SELECT
        medicine_mix_cd
        , in_hospital_cd_1
        , in_hospital_cd_2
        , medicine_mix_name
        , unit
        , up_date
    FROM
        mst_medicine_mix ntss_db5_mst_m_mix
    WHERE
        ntss_db5_mst_m_mix.facility_cd = @facilityCd
)
,ntss_db5_mst_m_class AS (
    SELECT
        class_cd
        , class_name
        , up_date
    FROM
        mst_medicine_class ntss_db5_mst_m_class
    WHERE
        ntss_db5_mst_m_class.facility_cd = @facilityCd
)
,ntss_db5_mst_m_timing AS (
    SELECT
        medicate_timing_cd
        , medicate_timing_name
        , up_date
    FROM
        mst_medicate_timing ntss_db5_mst_m_timing
    WHERE
        ntss_db5_mst_m_timing.facility_cd = @facilityCd
)
, ntss_db5_mst_p AS (
    SELECT
        ntss_db5_mst_p.procedure_cd AS procedure_cd
        , CAST(in_hosp_a_startdate AS date) AS in_hosp_a_startdate
        , ntss_db5_mst_p.in_hospital_cd_a1 AS in_hospital_cd_a1
        , ntss_db5_mst_p.in_hospital_cd_a2 AS in_hospital_cd_a2
        , CAST(in_hosp_b_startdate AS date) AS in_hosp_b_startdate
        , ntss_db5_mst_p.in_hospital_cd_b1 AS in_hospital_cd_b1
        , ntss_db5_mst_p.in_hospital_cd_b2 AS in_hospital_cd_b2
        , ntss_db5_mst_p.pricedure_name AS procedure_name
        , ntss_db5_mst_p.up_date AS up_date
    FROM
        mst_procedure ntss_db5_mst_p
    WHERE
        ntss_db5_mst_p.facility_cd = @facilityCd
)
, ntss_db5_ptp AS (
    SELECT
    ntss_db5_ptp.pat_id
    , ntss_db5_ptp.treat_week
    , ntss_db5_ptp.ind_treatment_cd
    , ''1'' AS flg
    FROM
        pat_treatment_pattern ntss_db5_ptp
    WHERE
        ntss_db5_ptp.facility_cd = @facilityCd
)
SELECT
    '''' AS hosppatid                             --患者ID
    , ntss_db5_om.pat_id AS patid
    , ntss_db5_om.treat_date AS dialysisdate    --透析日
    , ntss_db5_om_1.plural AS plural            --同日複数回
    , ntss_db5_om_temp.ctlno AS ctlno           --項目番号
    , to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    , CASE
        WHEN ntss_db5_om_temp.medicine_type = ''1''
            THEN ntss_db5_mst_m.in_hospital_cd_1
        WHEN ntss_db5_om_temp.medicine_type = ''2''
            THEN ntss_db5_mst_m_mix.in_hospital_cd_1
        ELSE NULL
        END AS medicinecd                       --薬剤コード(院内コード1)
    , CASE
        WHEN ntss_db5_om_temp.medicine_type = ''1''
            THEN ntss_db5_mst_m.in_hospital_cd_2
        WHEN ntss_db5_om_temp.medicine_type = ''2''
            THEN ntss_db5_mst_m_mix.in_hospital_cd_2
        ELSE NULL
        END AS medicinecd2                      --薬剤コード(院内コード2)
    , CASE
        WHEN ntss_db5_om_temp.medicine_type = ''1''
            THEN ntss_db5_mst_m.medicine_name
        WHEN ntss_db5_om_temp.medicine_type = ''2''
            THEN ntss_db5_mst_m_mix.medicine_mix_name
        ELSE NULL
        END AS medicinename                     --薬剤名
    , ntss_db5_mst_m_class.class_name AS mediclassname --薬剤分類名
    , COALESCE(ntss_db5_om_temp.amount, ''0'') AS amount         --数量
    , CASE
        WHEN ntss_db5_om_temp.medicine_type = ''1''
            THEN ntss_db5_mst_m.unit
        WHEN ntss_db5_om_temp.medicine_type = ''2''
            THEN ntss_db5_mst_m_mix.unit
        ELSE NULL
        END AS unit                             --単位
    , ntss_db5_mst_m_timing.medicate_timing_name AS timingname  --投与時間帯名
    , CASE
        WHEN ntss_db5_om_temp.treat_date >= ntss_db5_mst_p.in_hosp_a_startdate
        AND ntss_db5_om_temp.treat_date >= ntss_db5_mst_p.in_hosp_b_startdate
        THEN CASE
            WHEN ntss_db5_mst_p.in_hosp_a_startdate >= ntss_db5_mst_p.in_hosp_b_startdate
                THEN ntss_db5_mst_p.in_hospital_cd_a1
            WHEN ntss_db5_mst_p.in_hosp_a_startdate < ntss_db5_mst_p.in_hosp_b_startdate
                THEN ntss_db5_mst_p.in_hospital_cd_b1
            END
        WHEN ntss_db5_om_temp.treat_date >= ntss_db5_mst_p.in_hosp_a_startdate
        AND (ntss_db5_om_temp.treat_date < ntss_db5_mst_p.in_hosp_b_startdate
            OR ntss_db5_mst_p.in_hosp_b_startdate IS NULL)
            THEN ntss_db5_mst_p.in_hospital_cd_a1
        WHEN (ntss_db5_om_temp.treat_date < ntss_db5_mst_p.in_hosp_a_startdate
            OR ntss_db5_mst_p.in_hosp_a_startdate IS NULL)
        AND ntss_db5_om_temp.treat_date >= ntss_db5_mst_p.in_hosp_b_startdate
            THEN ntss_db5_mst_p.in_hospital_cd_b1
        ELSE NULL
        END AS procedurecd --手技コード(院内コード1)
    , CASE
        WHEN ntss_db5_om_temp.treat_date >= ntss_db5_mst_p.in_hosp_a_startdate
        AND ntss_db5_om_temp.treat_date >= ntss_db5_mst_p.in_hosp_b_startdate
        THEN CASE
            WHEN ntss_db5_mst_p.in_hosp_a_startdate >= ntss_db5_mst_p.in_hosp_b_startdate
                THEN ntss_db5_mst_p.in_hospital_cd_a2
            WHEN ntss_db5_mst_p.in_hosp_a_startdate < ntss_db5_mst_p.in_hosp_b_startdate
                THEN ntss_db5_mst_p.in_hospital_cd_b2
            END
        WHEN ntss_db5_om_temp.treat_date >= ntss_db5_mst_p.in_hosp_a_startdate
        AND (ntss_db5_om_temp.treat_date < ntss_db5_mst_p.in_hosp_b_startdate
            OR ntss_db5_mst_p.in_hosp_b_startdate IS NULL)
            THEN ntss_db5_mst_p.in_hospital_cd_a2
        WHEN (ntss_db5_om_temp.treat_date < ntss_db5_mst_p.in_hosp_a_startdate
            OR ntss_db5_mst_p.in_hosp_a_startdate IS NULL)
        AND ntss_db5_om_temp.treat_date >= ntss_db5_mst_p.in_hosp_b_startdate
            THEN ntss_db5_mst_p.in_hospital_cd_b2
        ELSE NULL
        END AS procedurecd2 --手技コード(院内コード2)
    , ntss_db5_mst_p.procedure_name AS procedurename --手技名
    , ntss_db5_om_temp.comment AS comments        --コメント
    , '''' AS indicatorcd                         --指示者
    , ntss_db5_om_temp.ind_user_id AS userid
    ,  CASE
        WHEN ntss_db5_ptp.flg = ''1''
            THEN ''0''
        ELSE ''1''
        END AS opeindplan                       --予定作成区分
    , ntss_db5_om.ord_no AS dialysisno --透析番号
FROM
    ord_main ntss_db5_om
    LEFT JOIN ntss_db5_om_1
        ON ntss_db5_om_1.ord_no = ntss_db5_om.ord_no
    LEFT JOIN ntss_db5_om_temp
        ON ntss_db5_om_temp.ord_no = ntss_db5_om.ord_no
    LEFT JOIN ntss_db5_mst_m
        ON ntss_db5_mst_m.medicine_cd ::text = ntss_db5_om_temp.cd
    LEFT JOIN ntss_db5_mst_m_mix
        ON ntss_db5_mst_m_mix.medicine_mix_cd ::text = ntss_db5_om_temp.cd
    LEFT JOIN ntss_db5_mst_m_class
        ON ntss_db5_mst_m_class.class_cd ::text = ntss_db5_om_temp.class_cd
    LEFT JOIN ntss_db5_mst_m_timing
        ON ntss_db5_mst_m_timing.medicate_timing_cd ::text = ntss_db5_om_temp.timing_cd
    LEFT JOIN ntss_db5_mst_p
        ON ntss_db5_mst_p.procedure_cd ::text = ntss_db5_om_temp.procedure_cd
    LEFT JOIN ntss_db5_ptp
        ON ntss_db5_ptp.pat_id = ntss_db5_om.pat_id
        AND ntss_db5_ptp.treat_week = ntss_db5_om.treat_week
        AND ntss_db5_ptp.ind_treatment_cd = ntss_db5_om.ind_treatment_cd
WHERE
    ntss_db5_om.is_del = ''0''
    AND ntss_db5_om.facility_cd = @facilityCd
    AND ntss_db5_om.ind_medi_info != ''[]''
    AND @fromDate <= ntss_db5_om.treat_date AND ntss_db5_om.treat_date < @toDate
    ;
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);



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
VALUES(-2221, 'SELECT
	cast(user_id as varchar) AS userid
	,disp_user_id AS indicatorcd --指示者
FROM
	mst_user_authentication
WHERE facility_cd = @facilityCd;', 1, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["userid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);