DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-2010,-2011,-2012,-2013,-2014,-2015,-2016)
;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2015, 'SELECT
    mst.transport_cd AS mergetransportcd
    , mst.in_hospital_cd_1 AS transportcd
    , mst.transport_name AS transportname
FROM
    mst_transport mst
WHERE
    mst.facility_cd = @facilityCd', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者基本情報：　@facilityCd使用 {"Mergekey": ["transportcd"]}', '2021-07-29 16:18:57.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2014, 'SELECT
    mst.disease_cd AS mergediseasecd
    , mst.in_hospital_cd_1 AS basediseasecd
    , mst.disease_name AS basediseasename
FROM
    mst_disease mst
WHERE
    mst.facility_cd = @facilityCd', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者基本情報：　@facilityCd使用 {"Mergekey": ["basediseasecd"]}', '2021-07-29 16:18:57.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2010, 'WITH pat_personal_main_dial_tbl AS (
    SELECT
        ptdia.pat_id
        , info ->> ''dial_diff_cd'' AS dialdiffcd
    FROM
        pat_personal_main ptdia
        CROSS JOIN LATERAL json_array_elements(ptdia.dial_diff_com_info ::json) info
    WHERE
        ptdia.facility_cd = @facilityCd
        AND info ->> ''is_main'' = ''1''
)
, pat_insurance_tmp AS (
    SELECT
        insurance_cd
        , insu_info
        , insu_pub_info
    FROM
        pat_insurance
    WHERE
        facility_cd = @facilityCd
        AND is_selected = ''1''
)
, pat_insurance_detail AS (
    SELECT
        pat_ins.insurance_cd
        , pat_ins.pat_id
        , pat_ins.insu_class
        , pat_ins.insu_info AS insu_info
        , NULL ::jsonb AS insu_pub_info_1
        , NULL ::jsonb AS insu_pub_info_2
        , pat_ins.memo1 AS memo1
        , pat_ins.memo2 AS memo2
        , pat_ins.up_date AS up_date
    FROM
        pat_insurance pat_ins
    WHERE
        pat_ins.facility_cd = @facilityCd
        AND pat_ins.insu_class = ''0''
        AND pat_ins.is_selected = ''1''
    UNION ALL
    SELECT
        pat_ins.insurance_cd
        , pat_ins.pat_id
        , pat_ins.insu_class
        , NULL ::jsonb AS insu_info
        , pat_ins.insu_pub_info AS insu_pub_info_1
        , NULL ::jsonb AS insu_pub_info_2
        , pat_ins.memo1 AS memo1
        , pat_ins.memo2 AS memo2
        , pat_ins.up_date AS up_date
    FROM
        pat_insurance pat_ins
    WHERE
        pat_ins.facility_cd = @facilityCd
        AND pat_ins.insu_class = ''1''
        AND pat_ins.is_selected = ''1''
    UNION ALL
    SELECT
        pat_ins.insurance_cd AS insurance_cd
        , pat_ins.pat_id
        , pat_ins.insu_class AS insu_class
        , pat_ins_tmp_1.insu_info AS insu_info
        , pat_ins_tmp_2.insu_pub_info AS insu_pub_info_1
        , pat_ins_tmp_3.insu_pub_info AS insu_pub_info_2
        , pat_ins.memo1 AS memo1
        , pat_ins.memo2 AS memo2
        , pat_ins.up_date AS up_date
    FROM
        pat_insurance pat_ins
        LEFT JOIN (
            SELECT
                pat_ins_tmp.insurance_cd
                , pat_ins_tmp.insu_info
            FROM
                pat_insurance_tmp pat_ins_tmp
        ) AS pat_ins_tmp_1
        ON CAST((pat_ins.insu_set_info ->> ''insu_cd'') AS integer) = pat_ins_tmp_1.insurance_cd
        LEFT JOIN (
            SELECT
                pat_ins_tmp.insurance_cd
                ,pat_ins_tmp.insu_pub_info
            FROM
                pat_insurance_tmp pat_ins_tmp
        ) AS pat_ins_tmp_2
        ON CAST((insu_set_info ->> ''insu_pub1_cd'') AS integer) = pat_ins_tmp_2.insurance_cd
        LEFT JOIN (
            SELECT
                pat_ins_tmp.insurance_cd
                , pat_ins_tmp.insu_pub_info
            FROM
                pat_insurance_tmp pat_ins_tmp
        ) AS pat_ins_tmp_3
        ON CAST((insu_set_info ->> ''insu_pub2_cd'') AS integer) = pat_ins_tmp_3.insurance_cd
    WHERE
        pat_ins.facility_cd = @facilityCd
        AND pat_ins.insu_class = ''2''
        AND pat_ins.is_selected = ''1''
    UNION ALL
    SELECT
        pat_ins.insurance_cd
        , pat_ins.pat_id
        , pat_ins.insu_class
        , NULL ::jsonb AS insu_info
        , NULL ::jsonb AS insu_pub_info_1
        , NULL ::jsonb AS insu_pub_info_2
        , pat_ins.memo1 AS memo1
        , pat_ins.memo2 AS memo2
        , pat_ins.up_date AS up_date
    FROM
        pat_insurance pat_ins
    WHERE
        pat_ins.facility_cd = @facilityCd
        AND pat_ins.insu_class = ''3''
        AND pat_ins.is_selected = ''1''
)
SELECT
    ntss_db6_ppm.hosp_pat_id AS hosppatid       --患者ID
    , ntss_db6_ppm.pat_id AS patid
    , personal_info_decrypt(ntss_db6_ppm.pat_last_name) || ''　'' || personal_info_decrypt(ntss_db6_ppm.pat_first_name)
    AS name                                    --氏名
    , personal_info_decrypt(ntss_db6_ppm.pat_last_name_kana) || ''　'' || personal_info_decrypt(ntss_db6_ppm.pat_first_name_kana)
    AS namekana                                --患者名カナ
    , 0 AS dialcount                            --透析回数***
    , '''' AS shantpart                           --シャント位置***
    , '''' AS ctr                                 --CTR***
    , '''' AS ctrupdate                           --CTR更新日時***
    , CASE
        WHEN ntss_db6_ppm.pat_blood_type_abo = 0
            THEN ''不明''
        WHEN ntss_db6_ppm.pat_blood_type_abo = 1
            THEN ''A型''
        WHEN ntss_db6_ppm.pat_blood_type_abo = 2
            THEN ''B型''
        WHEN ntss_db6_ppm.pat_blood_type_abo = 3
            THEN ''O型''
        WHEN ntss_db6_ppm.pat_blood_type_abo = 4
            THEN ''AB型''
        END AS bloodtypeabo --血液型ABO
    , CASE
        WHEN ntss_db6_ppm.pat_blood_type_rh = 0
            THEN ''不明''
        WHEN ntss_db6_ppm.pat_blood_type_rh = 1
            THEN ''Rh＋''
        WHEN ntss_db6_ppm.pat_blood_type_rh = 2
            THEN ''Rh－''
        END AS bloodtyperh --血液型RH
    , ntss_db6_ppm.pat_birthday AS birthday     --生年月日
    , CASE
        WHEN ntss_db6_ppm.pat_sex = 0
            THEN ''不明''
        WHEN ntss_db6_ppm.pat_sex = 1
            THEN ''男性''
        WHEN ntss_db6_ppm.pat_sex = 2
            THEN ''女性''
        END AS sexcd             --性別
    , CASE
        WHEN ntss_db6_pat_ins.insu_class = ''0''
        OR ntss_db6_pat_ins.insu_class = ''2''
            THEN ntss_db6_pat_ins.insu_info ->> ''insu_no''
        ELSE NULL
        END AS insuranceno                      --保険者番号
    , ntss_db6_pat_ins.memo1 AS insurancememo1  --保険メモ1
    , ntss_db6_pat_ins.memo2 AS insurancememo2  --保険メモ2
    , CASE
        WHEN ntss_db6_pat_ins.insu_class = ''1''
        OR ntss_db6_pat_ins.insu_class = ''2''
            THEN ntss_db6_pat_ins.insu_pub_info_1 ->> ''insu_pub_no''
        ELSE NULL
        END AS pubinsuno1                       --公費負担者番号1
    , CASE
        WHEN ntss_db6_pat_ins.insu_class = ''1''
        OR ntss_db6_pat_ins.insu_class = ''2''
            THEN ntss_db6_pat_ins.insu_pub_info_1 ->> ''insu_pub_pat_no''
        ELSE NULL
        END AS pubinsurecno1                    --公費負担医療需給者番号1
    , CASE
        WHEN ntss_db6_pat_ins.insu_class = ''1''
            THEN ntss_db6_pat_ins.insu_pub_info_1 ->> ''insu_pub_no''
        WHEN ntss_db6_pat_ins.insu_class = ''2''
            THEN ntss_db6_pat_ins.insu_pub_info_2 ->> ''insu_pub_no''
        ELSE NULL
        END AS pubinsuno2                       --公費負担者番号2
    , CASE
        WHEN ntss_db6_pat_ins.insu_class = ''1''
            THEN ntss_db6_pat_ins.insu_pub_info_1 ->> ''insu_pub_pat_no''
        WHEN ntss_db6_pat_ins.insu_class = ''2''
            THEN ntss_db6_pat_ins.insu_pub_info_2 ->> ''insu_pub_pat_no''
        ELSE NULL
        END AS pubinsurecno2                    --公費負担医療需給者番号2
    , CASE
        WHEN ntss_db6_pat_ins.insu_class = ''0''
        OR ntss_db6_pat_ins.insu_class = ''2''
            THEN CASE 
                WHEN ntss_db6_pat_ins.insu_info ->> ''insu_kbn'' = ''0''
                    THEN ''被保険者''
                WHEN ntss_db6_pat_ins.insu_info ->> ''insu_kbn'' = ''1''
                    THEN ''被扶養者''
                END
        ELSE NULL
        END AS insurancecd                      --保険区分
    , CASE
        WHEN ntss_db6_pat_ins.insu_class = ''0''
        OR ntss_db6_pat_ins.insu_class = ''2''
            THEN CONCAT((ntss_db6_pat_ins.insu_info ->> ''insu_no'') , ''-'' , (ntss_db6_pat_ins.insu_info ->> '' insu_pat_no''))
        ELSE NULL
        END AS hiinsurancecode                  --被保険者記号番号
    , CASE
        WHEN ntss_db6_pat_ins.insu_class = ''0''
        OR ntss_db6_pat_ins.insu_class = ''2''
            THEN ntss_db6_pat_ins.insu_info ->> ''futan-g''
        ELSE NULL
        END AS insuranceratio                   --保険率
    , CASE
        WHEN ntss_db6_pat_ins.insu_class = ''1''
            THEN ntss_db6_pat_ins.insu_pub_info_1 ->> ''passbook_no''
        WHEN ntss_db6_pat_ins.insu_class = ''2''
            THEN CASE 
                WHEN ntss_db6_pat_ins.insu_pub_info_1 ->> ''passbook_no'' IS NULL
                    THEN ntss_db6_pat_ins.insu_pub_info_2 ->> ''passbook_no''
                ELSE ntss_db6_pat_ins.insu_pub_info_1 ->> ''passbook_no''
                END
        ELSE NULL
        END AS disabilityno                     --障害者手帳NO
    , '''' AS doctorcd1                           --担当医ｃｄ1
    , '''' AS doctorcd2                           --担当医ｃｄ2
    , '''' AS doctorname1                         --担当医1
    , '''' AS doctorname2                         --担当医2
    , CASE
        WHEN ntss_db6_ppm.in_out_class = 1
        THEN ''入院''
        WHEN ntss_db6_ppm.in_out_class IS NOT NULL
        AND ntss_db6_ppm.in_out_class <> 1
        THEN ''外来''
        ELSE NULL
        END AS inoutclass                       --入院外来
    , '''' AS startdate                           --当院開始日
    , to_char(ntss_db6_ppm.die_date, ''YYYYMMDD'') AS diedate --死亡日
    , '''' AS infect                              --感染症有無
    , '''' AS ward                                --病棟名
    , '''' AS course                              --診療科名
    , '''' AS memo                                --MEMO
    , '''' AS staffcd1                            --担当スタッフｃｄ１
    , '''' AS staffcd2                            --担当スタッフｃｄ２
    , '''' AS staffname1                          --担当スタッフ１
    , '''' AS staffname2                          --担当スタッフ２
    , case
        WHEN dail.dialdiffcd IS NOT NULL
        THEN ''有''
        ELSE ''無''
        END AS dialdiff                         --透析困難
    , dail.dialdiffcd AS mergedialdiffcd        --透析困難コメントコード
    , '''' AS dialdiffcd                          --透析困難院内コード
    , '''' AS dialdiffcomment                     --透析困難コメント
    , ntss_db6_ppm.severity_cd AS severitycd    --重傷度コード
    , '''' AS injurycd                            --重傷度コード
    , '''' AS injuryname                          --重傷度名称
    , ntss_db6_ppm.primary_disease_cd AS mergediseasecd --原疾患コード
    , '''' AS basediseasecd                      --原疾患院内コード
    , '''' AS basediseasename                     --原疾患名称
    , ntss_db6_ppm.transport_cd AS mergetransportcd --輸送区分コード
    , '''' AS transportcd                         --輸送区分院内コード
    , '''' AS transportname                       --輸送区分名称
    , to_char(ntss_db6_ppm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    , '''' AS patgroupname                        --患者グループ
    , '''' AS patgroupcd                          --患者グループコード
    , '''' AS dialstartdate                       --透析導入日
FROM
    pat_personal_main ntss_db6_ppm
    LEFT JOIN pat_insurance_detail ntss_db6_pat_ins
        ON ntss_db6_ppm.pat_id = ntss_db6_pat_ins.pat_id
    LEFT JOIN pat_personal_main_dial_tbl dail
        ON dail.pat_id = ntss_db6_ppm.pat_id
WHERE
    ntss_db6_ppm.is_del = ''0''
    AND ntss_db6_ppm.facility_cd = @facilityCd
    AND (
        CASE WHEN @syncMode = ''update'' THEN (
            (
                ntss_db6_ppm.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
            )
            OR (
                ntss_db6_pat_ins.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
            )
        ) ELSE TRUE
        END
    )
ORDER BY ntss_db6_ppm.hosp_pat_id;', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者基本情報：@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid","doctorcd1","doctorcd2","staffcd1","staffcd2","mergedialdiffcd","basediseasecd","transportcd", "severitycd"]}', '2021-02-26 17:51:54.000', '2021-02-26 17:51:54.000', NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2016, 'SELECT
    mst.severity_cd AS severitycd
    , mst.in_hospital_cd_1 AS injurycd
    , mst.severity_name AS injuryname
FROM
    mst_severity mst
WHERE
    mst.facility_cd = @facilityCd;', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者基本情報：　@facilityCd使用 {"Mergekey": ["severitycd"]}', '2021-07-29 16:18:57.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2012, 'SELECT
    CAST(mst.user_id AS VARCHAR) AS doctorcd1
    , CAST(mst.user_id AS VARCHAR) AS doctorcd2
    , CAST(mst.user_id AS VARCHAR) AS staffcd1
    , CAST(mst.user_id AS VARCHAR) AS staffcd2
    , personal_info_decrypt(mst.user_first_name) || ''　'' || personal_info_decrypt(mst.user_last_name) AS
    doctorname1                                 --担当医1
    , personal_info_decrypt(mst.user_first_name) || ''　'' || personal_info_decrypt(mst.user_last_name) AS
    doctorname2                                 --担当医2
    , personal_info_decrypt(mst.user_first_name) || ''　'' || personal_info_decrypt(mst.user_last_name) AS
    staffname1                                  --担当スタッフ1
    , personal_info_decrypt(mst.user_first_name) || ''　'' || personal_info_decrypt(mst.user_last_name) AS
    staffname2                                  --担当スタッフ2
FROM
    mst_personal_user mst
WHERE
    mst.facility_cd = @facilityCd', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者基本情報：　@facilityCd使用 {"Mergekey": ["doctorcd1","doctorcd2","staffcd1","staffcd2"]}', '2021-07-29 16:18:57.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2013, 'SELECT
    CAST(mst.dialysis_difficulty_cd AS VARCHAR) AS mergedialdiffcd
    , mst.in_hospital_cd_1 AS dialdiffcd
    , mst.dialysis_difficulty_name AS dialdiffcomment
FROM
    mst_dialysis_difficulty mst
WHERE
    mst.facility_cd = @facilityCd', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者基本情報：@facilityCd使用 {"Mergekey": ["mergedialdiffcd"]}', '2021-07-29 16:18:57.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2011, 'WITH pat_event_tbl AS (
    SELECT
        pe.pat_id AS pat_id
        , result -> ''result_value'' AS result_value
    FROM
        pat_event pe
        CROSS JOIN lateral json_array_elements(pe.result_params ::json) WITH ordinality AS tmp(result, json_idx)
        INNER JOIN (
            SELECT
                pe_temp.pat_id AS pat_id
                ,max(pe_temp.up_date) AS up_date
            FROM
                pat_event pe_temp
            WHERE
                pe_temp.facility_cd = @facilityCd
                AND pe_temp.use_type = 1
            GROUP BY
                pe_temp.pat_id
        ) AS temp
        ON pe.pat_id = temp.pat_id
        AND pe.up_date = temp.up_date
    WHERE pe.facility_cd = @facilityCd
    AND result ->> ''format_class'' = ''2''
    AND json_idx = 1
)
,pat_event_tbl_2 AS (
    SELECT
        pat_event_tbl.pat_id
        , result_2 ->> ''name'' AS shantpart
    FROM pat_event_tbl
    CROSS JOIN lateral json_array_elements(pat_event_tbl.result_value ::json) WITH ordinality AS tmp(result_2, json_idx_2)
    WHERE result_2 ->> ''is_send_va'' = ''1''
    AND result_2 ->> ''name'' != ''''
    AND json_idx_2 = 1
)
,pat_unique_tbl AS (
    SELECT
        pu.pat_id
        , phy ->> ''ctr'' AS ctr
        , temp.exam_date AS exam_date
    FROM
        pat_unique pu
        CROSS JOIN lateral json_array_elements(pu.physical_info ::json) phy
        INNER JOIN (
            SELECT
                pu_temp.pat_id
                , max(phy_temp ->> ''ctr'') AS ctr
                , to_char(
                    max(to_date(phy_temp ->> ''exam_date'', ''YYYY/MM/DD''))
                    , ''YYYYMMDD''
                ) AS exam_date
            FROM
                pat_unique pu_temp
                CROSS JOIN lateral json_array_elements(pu_temp.physical_info ::json) phy_temp
            WHERE
                pu_temp.facility_cd = @facilityCd
                AND phy_temp ->> ''ctr'' IS NOT NULL
                AND strpos(phy_temp ->> ''exam_date'', ''_'') = 0
            GROUP BY
                pat_id
        ) AS temp
        ON pu.pat_id = temp.pat_id
        AND to_char(to_date(phy ->> ''exam_date'', ''YYYY/MM/DD''), ''YYYYMMDD'') = temp.exam_date
        AND phy ->> ''ctr'' IS NOT NULL
    WHERE
        pu.facility_cd = @facilityCd
)
, pat_main_doctor_tbl AS (
    SELECT
        pat_id
        , (array_agg(staff_cd)) [1] AS staff_cd_1
        , (array_agg(staff_cd)) [2] AS staff_cd_2
    FROM
        (
            SELECT
                pt_st.pat_id
                , staff ->> ''staff_cd'' AS staff_cd
            FROM
                pat_main pt_st
                CROSS JOIN lateral json_array_elements(pt_st.charge_staff_info ::json) staff
            WHERE
                pt_st.facility_cd = @facilityCd
                AND staff ->> ''is_main'' = ''1''
            ORDER BY
                pt_st.pat_id
                , staff ->> ''disp_order'' ASC
        ) pm_temp
    GROUP BY
        pat_id
)
, pat_main_staff_tbl AS (
    SELECT
        pat_id
        , (array_agg(staff_cd)) [1] AS staff_cd_1
        , (array_agg(staff_cd)) [2] AS staff_cd_2
    FROM
        (
            SELECT
                pt_st.pat_id
                , staff ->> ''staff_cd'' AS staff_cd
            FROM
                pat_main pt_st
                CROSS JOIN lateral json_array_elements(pt_st.charge_staff_info ::json) staff
            WHERE
                pt_st.facility_cd = @facilityCd
                AND staff ->> ''is_charge'' = ''1''
            ORDER BY
                pt_st.pat_id
                , staff ->> ''disp_order'' ASC
        ) pm_temp
    GROUP BY
        pat_id
)
, pat_main_memo_tbl AS (
    SELECT
        pt_info.pat_id
        , info ->> ''title'' AS title
        , info ->> ''content'' AS content
    FROM
        pat_main pt_info
        CROSS JOIN LATERAL json_array_elements(pt_info.pat_memo_info ::json) info
    WHERE
        pt_info.facility_cd = @facilityCd
        AND info ->> ''ctl_no'' = ''1''
    ORDER BY
            pt_info.pat_id
)
, pat_group_disp_order_tbl AS (
    SELECT
        one_json ->> ''code'' AS pat_group_cd
        , json_idx AS pat_group_cd_order
    FROM
        mst_selector
        CROSS JOIN lateral jsonb_array_elements(order_settings -> ''items'') with ordinality AS tmp(one_json, json_idx)
    WHERE
        facility_cd = @facilityCd
        AND master_physical_name = ''pat_group''
)
, pat_group_tmp AS (
    SELECT
        pat_group_cd
        , pat_group_name
        , in_hospital_cd_1
    FROM
        pat_group
    WHERE
        facility_cd = @facilityCd
)
, pat_group_detail_tmp AS (
    SELECT
        tmp.pat_id
        , pat_group_disp_order_tbl.pat_group_cd
    FROM
        (
            SELECT
                gdt.pat_id
                , min(pat_group_disp_order_tbl.pat_group_cd_order) AS disp_order
            FROM
                pat_group_detail gdt
                LEFT JOIN pat_group_disp_order_tbl
                ON pat_group_disp_order_tbl.pat_group_cd = gdt.pat_group_cd ::text
                LEFT JOIN pat_group_tmp pg
                ON pg.pat_group_cd = gdt.pat_group_cd
            WHERE
                gdt.facility_cd = @facilityCd
                AND pg.in_hospital_cd_1 IS NOT NULL
            GROUP BY
                gdt.pat_id
            ORDER BY
                gdt.pat_id
        ) tmp
        LEFT JOIN pat_group_disp_order_tbl
        ON pat_group_disp_order_tbl.pat_group_cd_order = tmp.disp_order
)
, mst_ward_tmp AS (
    SELECT
        *
    FROM
        mst_ward
    WHERE
        facility_cd = @facilityCd
)
, mst_course_tmp AS (
    SELECT
        *
    FROM
        mst_course
    WHERE
        facility_cd = @facilityCd
)
SELECT
    ntss_db5_pm.pat_id AS patid
    , ntss_db5_pm.medical_care_info ->> ''dialysis_count'' AS dialcount --透析回数
    , pat_event_tbl_2.shantpart AS shantpart      --シャント位置
    , pat_unique_tbl.ctr AS ctr                 --CTR
    , pat_unique_tbl.exam_date AS ctrupdate     --CTR更新日時
    , pat_main_doctor_tbl.staff_cd_1 AS doctorcd1 --担当医1
    , pat_main_doctor_tbl.staff_cd_2 AS doctorcd2 --担当医2
    , ntss_db5_pm.medical_care_info ->> ''hospital_start_date'' AS startdate --当院開始日
    , CASE
        when ntss_db5_pm.is_infect = ''0''
        then ''無''
        WHEN ntss_db5_pm.is_infect = ''1''
        THEN ''有''
        ELSE NULL
        END AS infect           --感染症有無
    , mst_ward_tmp.ward_name AS ward            --病棟名
    , mst_course_tmp.course_name AS course      --診療科名
    , pat_main_memo_tbl.content AS memo         --患者メモ
    , pat_main_staff_tbl.staff_cd_1 AS staffcd1 --担当スタッフ１
    , pat_main_staff_tbl.staff_cd_2 AS staffcd2 --担当スタッフ２
    , pat_group_tmp.pat_group_name AS patgroupname --患者グループ
    , pat_group_tmp.in_hospital_cd_1 AS patgroupcd --患者グループコード
    , ntss_db5_pm.medical_care_info ->> ''dialysis_start_date'' AS dialstartdate --透析導入日
FROM
    pat_main ntss_db5_pm
    LEFT JOIN pat_event_tbl_2
    ON pat_event_tbl_2.pat_id = ntss_db5_pm.pat_id
    LEFT JOIN pat_unique_tbl
    ON pat_unique_tbl.pat_id = ntss_db5_pm.pat_id
    LEFT JOIN pat_main_staff_tbl
    ON pat_main_staff_tbl.pat_id = ntss_db5_pm.pat_id
    LEFT JOIN pat_main_doctor_tbl
    ON pat_main_doctor_tbl.pat_id = ntss_db5_pm.pat_id
    LEFT JOIN pat_main_memo_tbl
    ON pat_main_memo_tbl.pat_id = ntss_db5_pm.pat_id
    LEFT JOIN pat_group_detail_tmp
    ON pat_group_detail_tmp.pat_id = ntss_db5_pm.pat_id
    LEFT JOIN mst_ward_tmp
    ON mst_ward_tmp.ward_cd ::text = ntss_db5_pm.medical_care_info ->> ''ward_cd'' ::text
    LEFT JOIN mst_course_tmp
    ON mst_course_tmp.course_cd ::text = ntss_db5_pm.medical_care_info ->> ''main_course_cd'' ::text
    LEFT JOIN pat_group_tmp
    ON pat_group_tmp.pat_group_cd ::text = pat_group_detail_tmp.pat_group_cd ::text
WHERE
    ntss_db5_pm.is_del = ''0''
    AND ntss_db5_pm.facility_cd = @facilityCd
ORDER BY
    patid ASC
    , CTR ASC;', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者基本情報：@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.000', CURRENT_TIMESTAMP, NULL);