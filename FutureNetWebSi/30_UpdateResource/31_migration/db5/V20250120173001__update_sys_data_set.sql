DELETE FROM ntss.sys_data_set
WHERE sql_cd IN(-2200, -2210)
;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2200, '-- 【SQL_CD=-2200】6.3対応
WITH 
    ord_main_head as
    (
        select
            ord_main.ord_no 
           ,ord_main.pat_id 
           ,ord_main.treat_date 
           ,ord_main.treat_week 
           ,ord_main.facility_cd 
           ,ord_main.ind_cond_info 
           ,ord_main.ind_equip_info 
           ,ord_main.ind_treatment_cd 
           ,ord_main.ind_treat_start_time 
           ,ord_main.up_date 
        from
            ord_main
        WHERE
            ord_main.is_del = ''0''
            AND ord_main.facility_cd = @facilityCd
            AND ord_main.pat_id IS NOT NULL
            AND @fromDate <= treat_date AND treat_date < @toDate
    ),
    mst_treatment_disp_order_tbl AS 
    (
        SELECT
            one_json ->> ''code'' AS treatment_cd
            , json_idx AS treatment_cd_order
        FROM
            mst_selector
            CROSS JOIN lateral jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(one_json, json_idx)
        WHERE
            facility_cd = @facilityCd
            AND master_physical_name = ''mst_treatment''
            AND one_json ->> ''isDel'' = ''0''
            AND one_json ->> ''isDisp'' = ''1''
    ),
    ntss_db5_om_1 AS 
    (
        SELECT
            ntss_db5_om_1.ord_no
            , ROW_NUMBER() OVER (PARTITION BY ntss_db5_om_1.pat_id, ntss_db5_om_1.treat_date ORDER BY ntss_db5_om_1.ind_treat_start_time ASC, mst_treatment_disp_order_tbl.treatment_cd_order ASC) AS plural
        FROM
            ord_main_head ntss_db5_om_1
            LEFT JOIN mst_treatment_disp_order_tbl
            ON ntss_db5_om_1.ind_treatment_cd ::text = mst_treatment_disp_order_tbl.treatment_cd
    ),
    ntss_db5_mst_e AS 
    ( 
        select
            ntss_db5_mst_e.equipment_cd,
            ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1,
            ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2,
            ntss_db5_mst_e.up_date AS up_date,
            ntss_db5_mst_e.equipment_name AS equipment_name,
            ntss_db5_mst_e.unit AS unit, 
            ntss_db5_mst_e.class_cd AS class_cd
        FROM 
            mst_equipment ntss_db5_mst_e -- 医療材料マスタ 
        WHERE 
            ntss_db5_mst_e.facility_cd = @facilityCd 
            AND ntss_db5_mst_e.is_del = ''0''
            AND ntss_db5_mst_e.is_disp = ''1''
    ),
    mst_equipment_class AS 
    ( 
        select
            mst_equipment_class.class_name as class_name,
            mst_equipment_class.class_cd
        FROM 
            mst_equipment_class -- 医療材料分類マスタ 
        WHERE
            mst_equipment_class.facility_cd = @facilityCd 
            AND mst_equipment_class.is_del = ''0''
            AND mst_equipment_class.is_disp = ''1''
    ),
    ntss_db5_om_iei_json AS 
    (
        SELECT
            ntss_db5_om_iei_json ->> ''amount'' AS amount,
            ntss_db5_om_iei_json ->> ''cd'' AS cd,
            ntss_db5_om_iei_json ->> ''needle_type'' AS needle_type,
            ntss_db5_om_iei_json ->> ''ind_user_id'' AS ind_user_id,
            om.ord_no AS ord_no
        FROM
            ord_main_head om
            CROSS JOIN LATERAL jsonb_array_elements ( om.ind_equip_info :: JSONB ) ntss_db5_om_iei_json
    ),
    ntss_db5_om_ici_json as
    (
        select
            ntss_db5_om_ici_json.key AS key
            , ntss_db5_om_ici_json.value::json ->> ''value'' AS value
            , ntss_db5_om_ici_json.value::json ->> ''ind_user_id'' AS ind_user_id
            , om.ord_no AS ord_no
        FROM
            ord_main_head om
            CROSS JOIN lateral jsonb_each_text(om.ind_cond_info::JSONB) ntss_db5_om_ici_json
        WHERE 
            ntss_db5_om_ici_json.key IN(''6'',''7'',''8'',''9'',''10'',''11'',''13'')
            AND ntss_db5_om_ici_json.value::json ->> ''value'' is not null
    ),
    ntss_db5_mst_list AS 
    (
        SELECT
            ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1,
            ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2,
            mst_equipment_class.class_name AS class_name, -- 医療材料分類マスタから取得
            ntss_db5_mst_e.equipment_name AS equipname,
            om.needle_type AS puncture_class,
            om.amount AS amount,
            ntss_db5_mst_e.unit AS unit,
            '''' AS comments,
            om.ord_no AS ord_no,
            ntss_db5_mst_e.up_date AS up_date,
            ntss_db5_mst_e.equipment_cd,
            om.ind_user_id,
            om.cd
        FROM
            ntss_db5_om_iei_json om
            LEFT JOIN ntss_db5_mst_e ON om.cd = ntss_db5_mst_e.equipment_cd::TEXT
            LEFT JOIN mst_equipment_class ON ntss_db5_mst_e.class_cd = mst_equipment_class.class_cd
    ), 
    ntss_db5_mst_list_ici AS 
    (
        SELECT
            ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1,
            ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2,
            mst_equipment_class.class_name AS class_name, -- 医療材料分類マスタから取得
            ntss_db5_mst_e.equipment_name AS equipname,
            ntss_db5_mst_e.unit AS unit,
            '''' AS comments,
            om.ord_no AS ord_no,
            ntss_db5_mst_e.up_date AS up_date,
            ntss_db5_mst_e.equipment_cd,
            om.ind_user_id,
            om.value,
            om.key
        FROM
            ntss_db5_om_ici_json om
            LEFT JOIN ntss_db5_mst_e ON om.value = ntss_db5_mst_e.equipment_cd::TEXT
            LEFT JOIN mst_equipment_class ON ntss_db5_mst_e.class_cd = mst_equipment_class.class_cd
    ), 
    ntss_db5_ptp AS 
    (
        SELECT
            ntss_db5_ptp.pat_id, 
            ntss_db5_ptp.treat_week, 
            ntss_db5_ptp.ind_treatment_cd,
            ''1'' AS flg
        FROM
            pat_treatment_pattern ntss_db5_ptp
        WHERE
            ntss_db5_ptp.facility_cd = @facilityCd
    ),
    ntss_db5_mst_sel AS
    (
        SELECT
            facility_cd
            , ntss_db5_mst_sel_json ->> ''code'' AS code
            , ROW_NUMBER() OVER() AS sortkey
        FROM
            mst_selector ms
        CROSS JOIN LATERAL jsonb_array_elements(ms.order_settings ::jsonb -> ''items'') ntss_db5_mst_sel_json
        WHERE ms.master_physical_name = ''mst_equipment''
        AND ms.facility_cd = @facilityCd 
        AND ntss_db5_mst_sel_json ->> ''isDel'' = ''0''
        AND ntss_db5_mst_sel_json ->> ''isDisp'' = ''1''
    )
    ,union_tmp AS
    (
    SELECT
        ord_main_head.pat_id AS patid
        ,ord_main_head.treat_date AS dialysisdate -- 透析日
        ,to_char( ord_main_head.up_date, ''YYYY-MM-DD hh24:mi:ss'' ) AS update -- 更新日時
        ,ntss_db5_mst_list.in_hospital_cd_1 AS equipcd -- 医療材料コード(院内コード1)
        ,ntss_db5_mst_list.in_hospital_cd_2 AS equipcd2 -- 医療材料コード(院内コード2)
        ,ntss_db5_mst_list.class_name AS equipclassname -- 医療材料分類名
        ,ntss_db5_mst_list.equipname AS equipname -- 医療材料名
        , CASE ntss_db5_mst_list.puncture_class
            WHEN ''1'' THEN ntss_db5_mst_list.puncture_class
            WHEN ''2'' THEN ntss_db5_mst_list.puncture_class
            WHEN ''3'' THEN ntss_db5_mst_list.puncture_class
            ELSE ''0''
            END AS punctureclass -- 穿刺針区分
        ,ntss_db5_mst_list.amount AS amount -- 数量
        ,ntss_db5_mst_list.unit AS unit -- 単位
        ,ntss_db5_mst_list.ind_user_id AS indicatorcd -- 指示者
        ,  CASE
            WHEN ntss_db5_ptp.flg = ''1''
                THEN ''0''
            ELSE ''1''
            END AS opeindplan    -- 予定作成区分
        ,ord_main_head.ord_no AS dialysisno --透析番号
        ,ntss_db5_mst_list.cd AS cd
    FROM
        ord_main_head
        INNER JOIN ntss_db5_mst_list ON ntss_db5_mst_list.ord_no = ord_main_head.ord_no
        LEFT JOIN ntss_db5_ptp
            ON ntss_db5_ptp.pat_id = ord_main_head.pat_id
            AND ntss_db5_ptp.treat_week = ord_main_head.treat_week
            AND ntss_db5_ptp.ind_treatment_cd = ord_main_head.ind_treatment_cd
    UNION ALL
        SELECT
        ord_main_head.pat_id AS patid
        ,ord_main_head.treat_date AS dialysisdate -- 透析日
        ,to_char( ord_main_head.up_date, ''YYYY-MM-DD hh24:mi:ss'' ) AS update -- 更新日時
        ,ntss_db5_mst_list_ici.in_hospital_cd_1 AS equipcd -- 医療材料コード(院内コード1)
        ,ntss_db5_mst_list_ici.in_hospital_cd_2 AS equipcd2 -- 医療材料コード(院内コード2)
        ,ntss_db5_mst_list_ici.class_name AS equipclassname -- 医療材料分類名
        ,ntss_db5_mst_list_ici.equipname AS equipname -- 医療材料名
        , CASE ntss_db5_mst_list_ici.key
            WHEN ''9'' THEN ''1''
            WHEN ''10'' THEN ''2''
            WHEN ''11'' THEN ''3''
            ELSE ''0''
            END AS punctureclass -- 穿刺針区分
        ,''1'' AS amount -- 数量
        ,ntss_db5_mst_list_ici.unit AS unit -- 単位
        ,ntss_db5_mst_list_ici.ind_user_id AS indicatorcd -- 指示者
        ,  CASE
            WHEN ntss_db5_ptp.flg = ''1''
                THEN ''0''
            ELSE ''1''
            END AS opeindplan    -- 予定作成区分
        ,ord_main_head.ord_no AS dialysisno --透析番号
        ,ntss_db5_mst_list_ici.value AS cd
    FROM
        ord_main_head
        INNER JOIN ntss_db5_mst_list_ici ON ntss_db5_mst_list_ici.ord_no = ord_main_head.ord_no
        LEFT JOIN ntss_db5_ptp
            ON ntss_db5_ptp.pat_id = ord_main_head.pat_id
            AND ntss_db5_ptp.treat_week = ord_main_head.treat_week
            AND ntss_db5_ptp.ind_treatment_cd = ord_main_head.ind_treatment_cd
            )
    SELECT
        '''' AS hosppatid -- 患者ID(連携用)
        ,union_tmp.patid
        ,union_tmp.dialysisdate -- 透析日
        ,ntss_db5_om_1.plural AS plural -- 同日複数回
        ,(row_number() over (PARTITION BY union_tmp.dialysisno ORDER BY ntss_db5_mst_sel.sortkey ASC, (union_tmp.cd)::integer))::text AS ctlno -- 項目番号
        ,union_tmp.update -- 更新日時
        ,union_tmp.equipcd -- 医療材料コード(院内コード1)
        ,union_tmp.equipcd2 -- 医療材料コード(院内コード2)
        ,union_tmp.equipclassname -- 医療材料分類名
        ,union_tmp.equipname -- 医療材料名
        ,union_tmp.punctureclass -- 穿刺針区分
        ,union_tmp.amount-- 数量
        ,union_tmp.unit -- 単位
        ,'''' AS comments -- コメント
        ,'''' AS indicatorcd --指示者
        ,union_tmp.indicatorcd AS userid --指示者コード(連携用)
        ,union_tmp.opeindplan-- 予定作成区分
        ,union_tmp.dialysisno --透析番号
    FROM
        union_tmp
        LEFT JOIN ntss_db5_mst_sel ON union_tmp.cd ::TEXT = ntss_db5_mst_sel.code
        LEFT JOIN ntss_db5_om_1 ON ntss_db5_om_1.ord_no = union_tmp.dialysisno
;', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);

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
        AND one_json ->> ''isDel'' = ''0''
        AND one_json ->> ''isDisp'' = ''1''
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
        , class_cd
        , in_hospital_cd_1
        , in_hospital_cd_2
        , medicine_name
        , unit
        , up_date
    FROM
        mst_medicine ntss_db5_mst_m
    WHERE
        ntss_db5_mst_m.facility_cd = @facilityCd
        AND ntss_db5_mst_m.is_del = ''0''
        AND ntss_db5_mst_m.is_disp = ''1''
)
,ntss_db5_mst_m_mix AS (
    SELECT
        medicine_mix_cd
        , class_cd
        , in_hospital_cd_1
        , in_hospital_cd_2
        , medicine_mix_name
        , unit
        , up_date
    FROM
        mst_medicine_mix ntss_db5_mst_m_mix
    WHERE
        ntss_db5_mst_m_mix.facility_cd = @facilityCd
        AND ntss_db5_mst_m_mix.is_del = ''0''
        AND ntss_db5_mst_m_mix.is_disp = ''1''
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
        AND ntss_db5_mst_m_class.is_del = ''0''
        AND ntss_db5_mst_m_class.is_disp = ''1''
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
        AND ntss_db5_mst_m_timing.is_del = ''0''
        AND ntss_db5_mst_m_timing.is_disp = ''1''
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
        AND ntss_db5_mst_p.is_del = ''0''
        AND ntss_db5_mst_p.is_disp = ''1''
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
    , CASE
        WHEN ntss_db5_om_temp.medicine_type = ''1''
            THEN ntss_db5_mst_m_class.class_name
        WHEN ntss_db5_om_temp.medicine_type = ''2''
            THEN ntss_db5_mst_m_mix_class.class_name
        ELSE NULL
        END AS mediclassname --薬剤分類名
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
        ON ntss_db5_mst_m_class.class_cd = ntss_db5_mst_m.class_cd
    LEFT JOIN ntss_db5_mst_m_class as ntss_db5_mst_m_mix_class
        ON ntss_db5_mst_m_mix_class.class_cd = ntss_db5_mst_m_mix.class_cd
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
    AND @fromDate <= ntss_db5_om.treat_date AND ntss_db5_om.treat_date < @toDate;', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
