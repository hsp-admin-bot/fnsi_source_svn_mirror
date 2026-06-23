DELETE FROM ntss.sys_data_set
WHERE sql_cd IN(-2220,-2221,-2051)
;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2220, 'WITH mst_treatment_disp_order_tbl AS (
    SELECT
        one_json ->> ''code'' AS treatment_cd
        , json_idx AS treatment_cd_order
    FROM
        mst_selector
        CROSS JOIN lateral jsonb_array_elements(order_settings -> ''items'') with ordinality AS tmp(one_json, json_idx)
    WHERE
        facility_cd = @facilityCd
        AND master_physical_name = ''mst_treatment''
),
ntss_db5_om_1 as (
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
),
ntss_db5_om AS (
    SELECT
        ntss_db5_om.ord_no
        , ROW_NUMBER() OVER (PARTITION BY ntss_db5_om.ord_no ORDER BY ntss_db5_om_iic_json ->> ''no'' ASC) AS ctlno
        , ntss_db5_om.pat_id
        , ntss_db5_om.treat_date
        , ntss_db5_om.up_date
        , ntss_db5_om.treat_type
        , ntss_db5_om.treat_week
        , ntss_db5_om.ind_treatment_cd
        , ntss_db5_om_iic_json ->> ''content'' AS addition
        , ntss_db5_om_iic_json ->> ''ind_user_id'' AS userid
    FROM
        ord_main ntss_db5_om
        CROSS JOIN LATERAL json_array_elements(ntss_db5_om.ind_ind_comment_info ::json) ntss_db5_om_iic_json
    WHERE
        ntss_db5_om.facility_cd = @facilityCd
        AND ntss_db5_om.is_del = ''0''
        AND ntss_db5_om.pat_id IS NOT NULL
        AND ntss_db5_om.treat_date IS NOT NULL
        AND @fromDate <= ntss_db5_om.treat_date AND ntss_db5_om.treat_date < @toDate
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
    '''' AS hosppatid                                                     --患者ID
    , ntss_db5_om.pat_id AS patid
    , ntss_db5_om.treat_date AS dialysisdate                            --透析日
    , ntss_db5_om_1.plural AS plural                                    --同日複数回
    , ntss_db5_om.ctlno AS ctlno                                        --項目番号
    , to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update   --更新日時
    , ntss_db5_om.addition                    --指示簿指示
    , '''' AS indicatorcd                                                 --指示者
    , ntss_db5_om.userid
    , CASE
        WHEN ntss_db5_ptp.flg = ''1''
            THEN ''0''
        ELSE ''1''
        END AS opeindplan                                               --予定作成区分
    ,ntss_db5_om.ord_no AS dialysisno --透析番号
FROM
    ntss_db5_om
    LEFT JOIN ntss_db5_om_1
      ON ntss_db5_om.ord_no = ntss_db5_om_1.ord_no
    LEFT JOIN ntss_db5_ptp
        ON ntss_db5_ptp.pat_id = ntss_db5_om.pat_id
        AND ntss_db5_ptp.treat_week = ntss_db5_om.treat_week
        AND ntss_db5_ptp.ind_treatment_cd = ntss_db5_om.ind_treatment_cd;
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd {"Mergekey": ["patid,userid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);



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
	,facility_cd AS facilitycd
	,disp_user_id AS indicatorcd --指示者
FROM
	mst_user_authentication
WHERE facility_cd = @facilityCd;', 1, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["userid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);