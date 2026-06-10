DELETE FROM ntss.sys_data_set
WHERE sql_cd IN(-2180,-2051)
;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2180, 'WITH mst_treatment_disp_order_tbl AS (
    SELECT
        one_json ->> ''code'' AS treatment_cd
        , json_idx AS treatment_cd_order
    FROM
        mst_selector
        CROSS JOIN lateral jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(one_json, json_idx)
    WHERE
        facility_cd = @facilityCd
        AND master_physical_name = ''mst_treatment''
),
ntss_db5_om AS (
    SELECT
        main.pat_id
        , main.treat_week
        , main.treat_date
        , main.ind_bed_cd
        , main.ind_bed_name
        , main.ind_kur_cd
        , main.ind_kur_name
        , main.ind_treatment_cd
        , main.ind_treat_start_time
        , main.up_date
        , main.ord_no
        , main.rst_start_date
    FROM
        ord_main main
    WHERE
        main.facility_cd = @facilityCd
        AND @fromDate <= main.treat_date AND main.treat_date < @toDate
)
,ntss_db5_om_1 AS (
            SELECT
                ntss_db5_om.ord_no
                ,row_number() OVER (PARTITION BY ntss_db5_om.pat_id,ntss_db5_om.treat_date
                ORDER BY ntss_db5_om.ind_treat_start_time ASC,mst_treatment_disp_order_tbl.treatment_cd_order ASC) AS plural
            FROM
                ntss_db5_om
                LEFT JOIN mst_treatment_disp_order_tbl
                ON ntss_db5_om.ind_treatment_cd ::text = mst_treatment_disp_order_tbl.treatment_cd
        )
,ntss_db5_os AS(
    SELECT
        ntss_db5_os.ord_no
        ,ntss_db5_os.is_dummy
    FROM ord_schedule AS ntss_db5_os
    WHERE ntss_db5_os.facility_cd = @facilityCd
)
,ntss_db5_mst_b AS(
    SELECT
        ntss_db5_mst_b.bed_cd
        ,ROW_NUMBER() OVER(ORDER BY ntss_db5_mst_b.bed_cd) AS bedno
        ,ntss_db5_mst_b.bed_name
    FROM mst_bed AS ntss_db5_mst_b
    WHERE ntss_db5_mst_b.facility_cd = @facilityCd
)
,ntss_db5_mst_k AS(
    SELECT
        ntss_db5_mst_k.kur_cd
        ,ntss_db5_mst_k.fn_kur_cd
        ,ntss_db5_mst_k.in_hospital_cd_1
        ,ntss_db5_mst_k.kur_name
        ,ntss_db5_mst_k.kur_standard_start_time
    FROM mst_kur AS ntss_db5_mst_k
    WHERE ntss_db5_mst_k.facility_cd = @facilityCd
)
,ntss_db5_ptp AS (
    SELECT
    ntss_db5_ptp.pat_id
    , ntss_db5_ptp.treat_week
    , ntss_db5_ptp.ind_treatment_cd
    , ''1'' AS flg
    FROM pat_treatment_pattern ntss_db5_ptp
    WHERE ntss_db5_ptp.facility_cd = @facilityCd
)
SELECT
        '''' AS hosppatid
        , ntss_db5_om.pat_id AS patid             --患者ID
        , ntss_db5_om.treat_date AS dialysisdate    --透析日
        , ntss_db5_mst_b.bedno AS bedno --ベッド番号
        , coalesce(ntss_db5_om.ind_bed_name,ntss_db5_mst_b.bed_name) AS bedname     --ベッド名
        , coalesce(ntss_db5_mst_k.fn_kur_cd, ntss_db5_mst_k.in_hospital_cd_1) AS kurcd --クールコード
        , coalesce(ntss_db5_om.ind_kur_name,ntss_db5_mst_k.kur_name) AS kurname     --クール名
        , ntss_db5_om_1.plural AS plural                           --同日複数回
        , to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
        , ntss_db5_om.ord_no AS resultdialysisno  --実績透析番号
        , CASE
            WHEN ntss_db5_ptp.flg = ''1''
                THEN ''0''
            ELSE ''1''
        END AS opeindplan                       --予定作成区分
        , ntss_db5_os.is_dummy AS dummyflg          --ダミーフラグ
        , CASE
            WHEN ntss_db5_om.rst_start_date IS NULL
                THEN CASE
                    WHEN ntss_db5_om.ind_kur_cd = 0
                        THEN ''未登録''
                    ELSE to_char(to_timestamp(ntss_db5_mst_k.kur_standard_start_time, ''hh24miss''), ''hh24:mi'')
                    END
            ELSE to_char(ntss_db5_om.rst_start_date, ''hh24:mi'')
            END AS starttime --透析開始時刻
    FROM
        ntss_db5_om
        LEFT JOIN ntss_db5_om_1
            ON ntss_db5_om.ord_no = ntss_db5_om_1.ord_no
        LEFT JOIN ntss_db5_os
            ON ntss_db5_os.ord_no = ntss_db5_om.ord_no
        LEFT JOIN ntss_db5_mst_b
            ON ntss_db5_om.ind_bed_cd = ntss_db5_mst_b.bed_cd
        LEFT JOIN ntss_db5_mst_k
            ON ntss_db5_om.ind_kur_cd = ntss_db5_mst_k.kur_cd
        LEFT JOIN ntss_db5_ptp
            ON ntss_db5_ptp.pat_id = ntss_db5_om.pat_id
            AND ntss_db5_ptp.treat_week = ntss_db5_om.treat_week
            AND ntss_db5_ptp.ind_treatment_cd = ntss_db5_om.ind_treatment_cd;
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);



INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2051, 'SELECT
	hosp_pat_id AS hosppatid,
	pat_id AS patid
FROM
	pat_personal_main 
WHERE facility_cd = @facilityCd;', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
