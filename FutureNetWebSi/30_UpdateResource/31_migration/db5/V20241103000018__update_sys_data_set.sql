DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (-2010,-2011,-2012,-2013,-2014,-2015,-2016,-2041,-2042,-2050,-2051,-2060,-2080,-2090,-2091,-2100,-2110,-2120,-2130,-2140,-2170,-2180,-2190,-2200,-2210,-2220,-2230,-2231,-2240,-2250,-2260,-2270,-2280,-2291,-2300,-2310,-2311,-2320,-2420,-2430,-2440,-2450,-2501,-2502,-2503,-2504,-2506,-2507,-2509,-2512,-2513,-2515,-2516,-2517);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2010, 'WITH pat_personal_main_dial_tbl AS (
    SELECT
        ptdia.pat_id
        , info ->> ''dial_diff_cd'' AS dialdiffcd
    FROM
        pat_personal_main ptdia
        CROSS JOIN LATERAL jsonb_array_elements(ptdia.dial_diff_com_info ::jsonb) info
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
        AND is_del = ''0''
        AND is_disp = ''1''
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
        AND pat_ins.is_del = ''0''
        AND pat_ins.is_disp = ''1''
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
        AND pat_ins.is_del = ''0''
        AND pat_ins.is_disp = ''1''
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
        AND pat_ins.is_del = ''0''
        AND pat_ins.is_disp = ''1''
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
        AND pat_ins.is_del = ''0''
        AND pat_ins.is_disp = ''1''
)
SELECT
    ntss_db6_ppm.hosp_pat_id AS hosppatid       --患者ID
    , ntss_db6_ppm.pat_id AS patid
    , CONCAT(personal_info_decrypt(ntss_db6_ppm.pat_last_name), ''　'', personal_info_decrypt(ntss_db6_ppm.pat_first_name))
    AS name                                    --氏名
    , CONCAT(personal_info_decrypt(ntss_db6_ppm.pat_last_name_kana), ''　'', personal_info_decrypt(ntss_db6_ppm.pat_first_name_kana))
    AS namekana                                --患者名カナ
    , 0 AS dialcount                            --透析回数***
    , '''' AS shantpart                           --シャント位置***
    , '''' AS ctr                                 --CTR***
    , '''' AS ctrupdate                           --CTR更新日時***
    , CASE
        WHEN ntss_db6_ppm.pat_blood_type_abo = 0
            THEN ''不明''
        WHEN ntss_db6_ppm.pat_blood_type_abo = 1
            THEN ''A''
        WHEN ntss_db6_ppm.pat_blood_type_abo = 2
            THEN ''B''
        WHEN ntss_db6_ppm.pat_blood_type_abo = 3
            THEN ''O''
        WHEN ntss_db6_ppm.pat_blood_type_abo = 4
            THEN ''AB''
        END AS bloodtypeabo --血液型ABO
    , CASE
        WHEN ntss_db6_ppm.pat_blood_type_rh = 0
            THEN ''不明''
        WHEN ntss_db6_ppm.pat_blood_type_rh = 1
            THEN ''Rh+''
        WHEN ntss_db6_ppm.pat_blood_type_rh = 2
            THEN ''Rh-''
        END AS bloodtyperh --血液型RH
    , ntss_db6_ppm.pat_birthday AS birthday     --生年月日
    , CASE
        WHEN ntss_db6_ppm.pat_sex = 0
            THEN ''不明''
        WHEN ntss_db6_ppm.pat_sex = 1
            THEN ''男''
        WHEN ntss_db6_ppm.pat_sex = 2
            THEN ''女''
        END AS sexcd             --性別
    , CASE
        WHEN ntss_db6_pat_ins.insu_class = ''0''
        OR ntss_db6_pat_ins.insu_class = ''2''
            THEN personal_info_decrypt(ntss_db6_pat_ins.insu_info ->> ''insu_no'')
        ELSE NULL
        END AS insuranceno                      --保険者番号
    , ntss_db6_pat_ins.memo1 AS insurancememo1  --保険メモ1
    , ntss_db6_pat_ins.memo2 AS insurancememo2  --保険メモ2
    , CASE
        WHEN ntss_db6_pat_ins.insu_class = ''1''
        OR ntss_db6_pat_ins.insu_class = ''2''
            THEN personal_info_decrypt(ntss_db6_pat_ins.insu_pub_info_1 ->> ''insu_pub_no'')
        ELSE NULL
        END AS pubinsuno1                       --公費負担者番号1
    , CASE
        WHEN ntss_db6_pat_ins.insu_class = ''1''
        OR ntss_db6_pat_ins.insu_class = ''2''
            THEN personal_info_decrypt(ntss_db6_pat_ins.insu_pub_info_1 ->> ''insu_pub_pat_no'')
        ELSE NULL
        END AS pubinsurecno1                    --公費負担医療需給者番号1
    , CASE
        WHEN ntss_db6_pat_ins.insu_class = ''1''
            THEN personal_info_decrypt(ntss_db6_pat_ins.insu_pub_info_1 ->> ''insu_pub_no'')
        WHEN ntss_db6_pat_ins.insu_class = ''2''
            THEN personal_info_decrypt(ntss_db6_pat_ins.insu_pub_info_2 ->> ''insu_pub_no'')
        ELSE NULL
        END AS pubinsuno2                       --公費負担者番号2
    , CASE
        WHEN ntss_db6_pat_ins.insu_class = ''1''
            THEN personal_info_decrypt(ntss_db6_pat_ins.insu_pub_info_1 ->> ''insu_pub_pat_no'')
        WHEN ntss_db6_pat_ins.insu_class = ''2''
            THEN personal_info_decrypt(ntss_db6_pat_ins.insu_pub_info_2 ->> ''insu_pub_pat_no'')
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
                ELSE ''無''
                END
        ELSE ''無''
        END AS insurancecd                      --保険区分
    , CASE
        WHEN ntss_db6_pat_ins.insu_class = ''0''
        OR ntss_db6_pat_ins.insu_class = ''2''
            THEN CONCAT(personal_info_decrypt(ntss_db6_pat_ins.insu_info ->> ''insu_no'') , ''-'' , personal_info_decrypt(ntss_db6_pat_ins.insu_info ->> ''insu_pat_no''))
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
            THEN personal_info_decrypt(ntss_db6_pat_ins.insu_pub_info_1 ->> ''passbook_no'')
        WHEN ntss_db6_pat_ins.insu_class = ''2''
            THEN CASE
                WHEN ntss_db6_pat_ins.insu_pub_info_1 ->> ''passbook_no'' IS NULL
                    THEN personal_info_decrypt(ntss_db6_pat_ins.insu_pub_info_2 ->> ''passbook_no'')
                ELSE personal_info_decrypt(ntss_db6_pat_ins.insu_pub_info_1 ->> ''passbook_no'')
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
        END AS inout                       --入院外来
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
    AND ntss_db6_ppm.facility_cd = @facilityCd;
', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者基本情報：@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid","doctorcd1","doctorcd2","staffcd1","staffcd2","mergedialdiffcd","mergediseasecd","mergetransportcd", "severitycd"]}', '2021-02-26 17:51:54.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2011, 'WITH pat_event_tbl AS (
    SELECT
        pe.pat_id
        , row_number () over (partition by pe.pat_id order by up_date desc,pat_event_cd desc,json_idx asc) as rowno
        , result -> ''result_value'' AS result_value
    FROM
        pat_event pe
        CROSS JOIN lateral jsonb_array_elements(pe.result_params ::jsonb) WITH ordinality AS tmp(result, json_idx)
    WHERE pe.facility_cd = @facilityCd
    AND pe.use_type = 1
    AND result ->> ''format_class'' = ''2''
    AND pe.is_del = ''0''
)
,pat_event_tbl_2 AS (
    SELECT
        pat_event_tbl.pat_id
        ,row_number () over (partition by pat_event_tbl.pat_id order by result_2 ->> ''is_send_va'' desc,json_idx_2 asc) as rowno2
        , result_2 ->> ''name'' AS shantpart
    FROM pat_event_tbl
    CROSS JOIN lateral jsonb_array_elements(pat_event_tbl.result_value ::jsonb) WITH ordinality AS tmp(result_2, json_idx_2)
    WHERE pat_event_tbl.rowno = 1
    and result_2 ->> ''name'' != ''''
)
,pat_unique_tbl AS (
    SELECT
        pu.pat_id
        , phy ->> ''ctr'' AS ctr
        , temp.exam_date AS exam_date
    FROM
        pat_unique pu
        CROSS JOIN lateral jsonb_array_elements(pu.physical_info ::jsonb) phy
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
                CROSS JOIN lateral jsonb_array_elements(pu_temp.physical_info ::jsonb) phy_temp
            WHERE
                pu_temp.facility_cd = @facilityCd
                AND phy_temp ->> ''ctr'' IS NOT NULL
                AND strpos(phy_temp ->> ''exam_date'', ''_'') = 0
                AND pu_temp.is_del = ''0''
            GROUP BY
                pat_id
        ) AS temp
        ON pu.pat_id = temp.pat_id
        AND to_char(to_date(phy ->> ''exam_date'', ''YYYY/MM/DD''), ''YYYYMMDD'') = temp.exam_date
        AND phy ->> ''ctr'' IS NOT NULL
        AND pu.is_del = ''0''
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
                CROSS JOIN lateral jsonb_array_elements(pt_st.charge_staff_info ::jsonb) staff
            WHERE
                pt_st.facility_cd = @facilityCd
                AND staff ->> ''is_main'' = ''1''
                AND pt_st.is_del = ''0''
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
                CROSS JOIN lateral jsonb_array_elements(pt_st.charge_staff_info ::jsonb) staff
            WHERE
                pt_st.facility_cd = @facilityCd
                AND staff ->> ''is_charge'' = ''1''
                AND pt_st.is_del = ''0''
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
        CROSS JOIN LATERAL jsonb_array_elements(pt_info.pat_memo_info ::jsonb) info
    WHERE
        pt_info.facility_cd = @facilityCd
        AND info ->> ''ctl_no'' = ''1''
        AND pt_info.is_del = ''0''
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
        AND one_json ->> ''isDel'' = ''0''
        AND one_json ->> ''isDisp'' = ''1''
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
        AND is_del = ''0''
        AND is_disp = ''1''
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
        AND is_del = ''0''
        AND is_disp = ''1''
)
, mst_course_tmp AS (
    SELECT
        *
    FROM
        mst_course
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND is_disp = ''1''
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
    AND pat_event_tbl_2.rowno2 = 1
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
    AND ntss_db5_pm.facility_cd = @facilityCd;
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者基本情報：@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2012, 'SELECT
    CAST(mst.user_id AS VARCHAR) AS doctorcd1
    , CONCAT(personal_info_decrypt(mst.user_first_name), ''　'', personal_info_decrypt(mst.user_last_name)) AS
    doctorname1                                 --担当医1
FROM
    mst_personal_user mst
WHERE
    mst.facility_cd = @facilityCd
    and is_del = ''0'' and is_disp = ''1''', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者基本情報：　@facilityCd使用 {"Mergekey": ["doctorcd1"]}', '2021-07-29 16:18:57.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2013, 'SELECT
    CAST(mst.dialysis_difficulty_cd AS VARCHAR) AS mergedialdiffcd
    , mst.in_hospital_cd_1 AS dialdiffcd
    , mst.dialysis_difficulty_name AS dialdiffcomment
FROM
    mst_dialysis_difficulty mst
WHERE
    mst.facility_cd = @facilityCd
    and is_del = ''0'' and is_disp = ''1''', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者基本情報：@facilityCd使用 {"Mergekey": ["mergedialdiffcd"]}', '2021-07-29 16:18:57.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2014, 'SELECT
    mst.disease_cd AS mergediseasecd
    , mst.in_hospital_cd_1 AS basediseasecd
    , mst.disease_name AS basediseasename
FROM
    mst_disease mst
WHERE
    mst.facility_cd = @facilityCd
    and is_del = ''0'' and is_disp = ''1''', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者基本情報：　@facilityCd使用 {"Mergekey": ["mergediseasecd"]}', '2021-07-29 16:18:57.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2015, 'SELECT
    mst.transport_cd AS mergetransportcd
    , mst.in_hospital_cd_1 AS transportcd
    , mst.transport_name AS transportname
FROM
    mst_transport mst
WHERE
    mst.facility_cd = @facilityCd
    AND is_del = ''0''
    AND is_disp = ''1''', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者基本情報：　@facilityCd使用 {"Mergekey": ["mergetransportcd"]}', '2021-07-29 16:18:57.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2016, 'SELECT
    mst.severity_cd AS severitycd
    , mst.in_hospital_cd_1 AS injurycd
    , mst.severity_name AS injuryname
FROM
    mst_severity mst
WHERE
    mst.facility_cd = @facilityCd
    and is_del = ''0'' and is_disp = ''1'';', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者基本情報：　@facilityCd使用 {"Mergekey": ["severitycd"]}', '2021-07-29 16:18:57.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2041, 'SELECT
    '''' AS hosppatid --患者ID
    ,ntss_db5_pu.pat_id AS patid
    ,ntss_db5_pu_mhi_json ->> ''ctl_no'' AS ctlno --管理番号
    ,to_char(ntss_db5_pu.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    ,ntss_db5_pu_mst_d.in_hospital_cd_1 AS diseasecd --病名コード
    ,ntss_db5_pu_mst_d.disease_name AS diseasename --病名
    ,CASE 
        WHEN LENGTH(ntss_db5_pu_mhi_json ->> ''disease_date'') = 8
        THEN to_char(to_timestamp(ntss_db5_pu_mhi_json ->> ''disease_date'', ''YYYYMMDD''), ''YYYY-MM-DD hh24:mi:ss'')  
        ELSE NULL
    END AS diseasedate --発症日
    ,CASE 
      WHEN ntss_db5_pu_mhi_json ->> ''out_come'' IN (''3'', ''5'') THEN to_char(to_timestamp(ntss_db5_pu_mhi_json ->> ''out_come_date'', ''YYYYMMDD''), ''YYYY-MM-DD hh24:mi:ss'')
      ELSE null
    END AS recoverdate --治癒日
    ,ntss_db5_pu_mhi_json ->> ''is_main_disease'' AS maindisease --主病名
    ,CASE ntss_db5_pu_mhi_json ->> ''out_come''
      WHEN ''1'' THEN ''3'' 
      WHEN ''2'' THEN ''8''
      WHEN ''3'' THEN ''0''
      WHEN ''8'' THEN ''2''
      WHEN ''10'' THEN ''1''
      ELSE ntss_db5_pu_mhi_json ->> ''out_come''
    END AS status --転帰
    ,ntss_db5_pu_mhi_json ->> ''is_notice'' AS noticeflg --告知有無
    ,CASE WHEN
        ntss_db5_pu_mhi_json ->> ''diagnostician_is_free'' = ''1'' THEN ntss_db5_pu_mhi_json ->> ''diagnostician_cd''
      ELSE ''''
      END AS doctorname --診断医
     ,CASE WHEN
        ntss_db5_pu_mhi_json ->> ''diagnostician_is_free'' = ''0'' THEN cast(ntss_db5_pu_mhi_json ->> ''diagnostician_cd'' AS int8)
    END AS userid --Mergekey
    ,ntss_db5_pu_mhi_json ->> ''memo'' AS memo --メモ
FROM
    ntss.pat_unique ntss_db5_pu
    CROSS JOIN LATERAL jsonb_array_elements(ntss_db5_pu.medical_hst_info::jsonb) ntss_db5_pu_mhi_json
    LEFT JOIN ntss.mst_disease ntss_db5_pu_mst_d
    ON ntss_db5_pu_mst_d.disease_cd :: TEXT = ntss_db5_pu_mhi_json ->> ''disease_cd''
    AND ntss_db5_pu_mst_d.is_del = ''0''
    AND ntss_db5_pu_mst_d.is_disp = ''1''
WHERE
    ntss_db5_pu.is_del != ''1''
    AND ntss_db5_pu.facility_cd = @facilityCd
    AND ntss_db5_pu.medical_hst_info IS NOT NULL
    AND ntss_db5_pu.medical_hst_info <> ''[]''
    AND ntss_db5_pu.is_del = ''0''', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2042, 'SELECT
      user_id AS userid
      ,CONCAT(personal_info_decrypt(user_last_name), ''　'', personal_info_decrypt(user_first_name))  AS doctorname --診断医
    FROM
      mst_personal_user
    WHERE
      facility_cd = @facilityCd
      AND is_del = ''0''
      AND is_disp = ''1'';
', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["userid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2050, '-- 【SQL_CD=-2050】
SELECT
    '''' AS hosppatid --患者ID
    ,ntss_db5_mst_mi.in_hospital_cd_1 AS infectioncd --感染症コード
    ,ntss_db5_mst_mi.infection_name AS infectionname --感染症名
    ,TO_CHAR(TO_TIMESTAMP(ntss_db5_pm_json ->> ''up_date'', ''YYYYMMDD''), ''YYYY-MM-DD HH24:MI:SS'') AS update --更新日時
    , CASE ntss_db5_pm_json ->> ''infect'' 
    WHEN ''1'' THEN ''0'' 
    WHEN ''2'' THEN ''1'' 
    ELSE ''-''
    END AS infect --結果コード
    ,ntss_db5_pm.pat_id AS patid
FROM
    pat_main ntss_db5_pm
    CROSS JOIN LATERAL jsonb_array_elements(ntss_db5_pm.infect_info ::jsonb) ntss_db5_pm_json
    INNER JOIN mst_infection ntss_db5_mst_mi
    ON ntss_db5_mst_mi.infection_cd ::text = ntss_db5_pm_json ->> ''infection_cd''
    AND ntss_db5_mst_mi.is_del = ''0''
    AND ntss_db5_mst_mi.is_disp = ''1''
WHERE
    ntss_db5_pm.is_del = ''0''
    AND ntss_db5_pm.facility_cd = @facilityCd
    AND ntss_db5_mst_mi.in_hospital_cd_1 IS NOT null;
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2051, 'SELECT
    hosp_pat_id AS hosppatid,
    pat_id AS patid
FROM
    pat_personal_main 
WHERE facility_cd = @facilityCd
    AND is_del = ''0'';', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2060, '-- 【SQL_CD=-2060】
with ntss_db5_mst_add as (
    SELECT
        ntss_db5_mst_add.addition_cd
        ,ntss_db5_mst_add.addition_name
        ,ntss_db5_mst_add.in_hospital_cd_1
        ,ntss_db5_mst_add.in_hospital_cd_2
        ,ntss_db5_mst_add.in_hospital_cd_3
        ,ntss_db5_mst_add.reg_date
        ,ntss_db5_mst_add.up_date
    FROM
        mst_addition ntss_db5_mst_add
    WHERE
        ntss_db5_mst_add.facility_cd = @facilityCd
        AND ntss_db5_mst_add.is_del = ''0''
        AND ntss_db5_mst_add.is_disp = ''1''
)
SELECT
    ntss_db5_pm.pat_id AS patid
    ,'''' AS hosppatid --患者ID
    ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    ,''1'' AS division -- レセプトメモ区分
    ,ntss_db5_mst_add.in_hospital_cd_3 AS code --コード
    ,to_char(ntss_db5_mst_add.reg_date, ''YYYY-MM-DD hh24:mi:ss'') AS codeupdate --コード更新日時
    ,ntss_db5_pm_json ->> ''is_enable'' AS addflg -- 加算有無
    ,ntss_db5_mst_add.addition_name AS itemname --項目名称
    ,'''' AS maindialdiff --主たる透析困難
    ,ntss_db5_mst_add.in_hospital_cd_1 AS inhospitalcd --院内コード
    ,ntss_db5_mst_add.in_hospital_cd_2 AS inhospitalcd2 --院内コード２
FROM
    pat_main ntss_db5_pm
    CROSS JOIN LATERAL jsonb_array_elements(ntss_db5_pm.addition_info ::jsonb) ntss_db5_pm_json
    LEFT JOIN ntss_db5_mst_add
    ON ntss_db5_mst_add.addition_cd ::text = ntss_db5_pm_json ->> ''cd''
WHERE
    ntss_db5_pm.facility_cd = @facilityCd
    AND ntss_db5_pm.is_del = ''0''
    AND ntss_db5_pm.addition_info <> ''[]'';
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2080, '-- 【SQL_CD=-2080】
WITH ntss_db5_pm as (
    SELECT
        ntss_db5_pm.pat_id
        ,ntss_db5_pm.up_date
        ,ntss_db5_pm.tare_info
        ,ntss_db5_pm.is_wheel_chair
    FROM
        pat_main ntss_db5_pm
    WHERE
        ntss_db5_pm.facility_cd = @facilityCd
        AND ntss_db5_pm.is_del != ''1''
)
,ntss_db5_pm_mst_wc as(
    SELECT
        ntss_db5_pm_mst_wc.pat_id
        ,ntss_db5_pm_mst_wc.in_hospital_cd_1
        ,ntss_db5_pm_mst_wc.wheel_chair_name
        ,ntss_db5_pm_mst_wc.wheel_chair_weight 
    FROM
        mst_wheel_chair as ntss_db5_pm_mst_wc
    WHERE
        ntss_db5_pm_mst_wc.facility_cd = @facilityCd
        AND ntss_db5_pm_mst_wc.is_del = ''0''
        AND ntss_db5_pm_mst_wc.is_disp = ''1''
    )
,tabletmp as(
    select 
        ntss_db5_pm.pat_id
        ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS up_date
        ,ntss_db5_pm.tare_info
        ,ntss_db5_pm.is_wheel_chair
        ,ntss_db5_pm_mst_wc.in_hospital_cd_1
        ,ntss_db5_pm_mst_wc.wheel_chair_name
        ,ntss_db5_pm_mst_wc.wheel_chair_weight 
       FROM
           ntss_db5_pm
           LEFT JOIN ntss_db5_pm_mst_wc
           ON ntss_db5_pm_mst_wc.pat_id = ntss_db5_pm.pat_id
           AND ntss_db5_pm.is_wheel_chair = ''1''
)
SELECT
    *
    FROM
        (
        SELECT
               '''' AS hosppatid                             --患者ID
               , pat_id AS patid --患者ID(結合用)
               , '''' AS name                               --氏名
               , 1 as ctlno                                --管理番号
               , up_date AS update --更新日時(当日)
               , CASE
                   WHEN extract(DOW FROM now()) = 1
                       THEN tare_info #>> ''{1,name_1}''
                   WHEN extract(DOW FROM now()) = 2
                       THEN tare_info #>> ''{2,name_1}''
                   WHEN extract(DOW FROM now()) = 3
                       THEN tare_info #>> ''{3,name_1}''
                   WHEN extract(DOW FROM now()) = 4
                       THEN tare_info #>> ''{4,name_1}''
                   WHEN extract(DOW FROM now()) = 5
                       THEN tare_info #>> ''{5,name_1}''
                   WHEN extract(DOW FROM now()) = 6
                       THEN tare_info #>> ''{6,name_1}''
                   WHEN extract(DOW FROM now()) = 0
                       THEN tare_info #>> ''{7,name_1}''
                   END AS revisename                       --風袋補正名(当日)
               , CASE
                   WHEN extract(DOW FROM now()) = 1
                       THEN coalesce(cast(tare_info #>> ''{1,weight_1}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 2
                       THEN coalesce(cast(tare_info #>> ''{2,weight_1}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 3
                       THEN coalesce(cast(tare_info #>> ''{3,weight_1}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 4
                       THEN coalesce(cast(tare_info #>> ''{4,weight_1}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 5
                       THEN coalesce(cast(tare_info #>> ''{5,weight_1}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 6
                       THEN coalesce(cast(tare_info #>> ''{6,weight_1}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 0
                       THEN coalesce(cast(tare_info #>> ''{7,weight_1}'' AS integer),0)
                   END AS reviseweight                     --重量(当日) 
               , null::varchar AS hospwheelchaircd --車椅子コード(当日)
               , null AS wheelchairname --車椅子名(当日)
               , up_date AS monupdate --更新日時(月曜日)
               , tare_info #>> ''{1,name_1}'' AS monrevisename --風袋補正名(月曜日)
               , coalesce(cast(tare_info #>> ''{1,weight_1}'' AS integer),0) AS monreviseweight --重量(月曜日)
               , null::varchar AS monhospwheelchaircd --車椅子コード(月曜日)
               , null AS monwheelchairname --車椅子名(月曜日)
               , up_date AS tueupdate --更新日時(火曜日)
               , tare_info #>> ''{2,name_1}'' AS tuerevisename --風袋補正名(火曜日)
               , coalesce(cast(tare_info #>> ''{2,weight_1}'' AS integer),0) AS tuereviseweight --重量(火曜日)
               , null::varchar AS tuehospwheelchaircd --車椅子コード(火曜日)
               , null AS tuewheelchairname --車椅子名(火曜日)
               , up_date AS wedupdate --更新日時(水曜日)
               , tare_info #>> ''{3,name_1}'' AS wedrevisename --風袋補正名(水曜日)
               , coalesce(cast(tare_info #>> ''{3,weight_1}'' AS integer),0) AS wedreviseweight --重量(水曜日)
               , null::varchar AS wedhospwheelchaircd --車椅子コード(水曜日)
               , null AS wedwheelchairname --車椅子名(水曜日)
               , up_date AS thuupdate --更新日時(木曜日)
               , tare_info #>> ''{4,name_1}'' AS thurevisename --風袋補正名(木曜日)
               , coalesce(cast(tare_info #>> ''{4,weight_1}'' AS integer),0) AS thureviseweight --重量(木曜日)
               , null::varchar AS thuhospwheelchaircd --車椅子コード(木曜日)
               , null AS thuwheelchairname --車椅子名(木曜日)
               , up_date AS friupdate --更新日時(金曜日)
               , tare_info #>> ''{5,name_1}'' AS frirevisename --風袋補正名(金曜日)
               , coalesce(cast(tare_info #>> ''{5,weight_1}'' AS integer),0) AS frireviseweight --重量(金曜日)
               , null::varchar AS frihospwheelchaircd --車椅子コード(金曜日)
               , null AS friwheelchairname --車椅子名(金曜日)
               , up_date AS satupdate --更新日時(土曜日)
               , tare_info #>> ''{6,name_1}'' AS satrevisename --風袋補正名(土曜日)
               , coalesce(cast(tare_info #>> ''{6,weight_1}'' AS integer),0) AS satreviseweight --重量(土曜日)
               , null::varchar AS sathospwheelchaircd --車椅子コード(土曜日)
               , null AS satwheelchairname --車椅子名(土曜日)
               , up_date AS sunupdate --更新日時(日曜日)
               , tare_info #>> ''{7,name_1}'' AS sunrevisename --風袋補正名(日曜日)
               , coalesce(cast(tare_info #>> ''{7,weight_1}'' AS integer),0) AS sunreviseweight --重量(日曜日)
               , null::varchar AS sunhospwheelchaircd --車椅子コード(日曜日)
               , null AS sunwheelchairname --車椅子名(日曜日)
            FROM
                tabletmp
    UNION ALL
            SELECT
               '''' AS hosppatid                             --患者ID
               , pat_id AS patid --患者ID(結合用)
               , '''' AS name                               --氏名
               , 2 as ctlno                                --管理番号
               , up_date AS update --更新日時(当日)
               , CASE
                   WHEN extract(DOW FROM now()) = 1
                       THEN tare_info #>> ''{1,name_2}''
                   WHEN extract(DOW FROM now()) = 2
                       THEN tare_info #>> ''{2,name_2}''
                   WHEN extract(DOW FROM now()) = 3
                       THEN tare_info #>> ''{3,name_2}''
                   WHEN extract(DOW FROM now()) = 4
                       THEN tare_info #>> ''{4,name_2}''
                   WHEN extract(DOW FROM now()) = 5
                       THEN tare_info #>> ''{5,name_2}''
                   WHEN extract(DOW FROM now()) = 6
                       THEN tare_info #>> ''{6,name_2}''
                   WHEN extract(DOW FROM now()) = 0
                       THEN tare_info #>> ''{7,name_2}''
                   END AS revisename                       --風袋補正名(当日)
               , CASE
                   WHEN extract(DOW FROM now()) = 1
                       THEN coalesce(cast(tare_info #>> ''{1,weight_2}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 2
                       THEN coalesce(cast(tare_info #>> ''{2,weight_2}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 3
                       THEN coalesce(cast(tare_info #>> ''{3,weight_2}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 4
                       THEN coalesce(cast(tare_info #>> ''{4,weight_2}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 5
                       THEN coalesce(cast(tare_info #>> ''{5,weight_2}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 6
                       THEN coalesce(cast(tare_info #>> ''{6,weight_2}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 0
                       THEN coalesce(cast(tare_info #>> ''{7,weight_2}'' AS integer),0)
                   END AS reviseweight                     --重量(当日) 
               , null::varchar AS hospwheelchaircd --車椅子コード(当日)
               , null AS wheelchairname --車椅子名(当日)
               , up_date AS monupdate --更新日時(月曜日)
               , tare_info #>> ''{1,name_2}'' AS monrevisename --風袋補正名(月曜日)
               , coalesce(cast(tare_info #>> ''{1,weight_2}'' AS integer),0) AS monreviseweight --重量(月曜日)
               , null::varchar AS monhospwheelchaircd --車椅子コード(月曜日)
               , null AS monwheelchairname --車椅子名(月曜日)
               , up_date AS tueupdate --更新日時(火曜日)
               , tare_info #>> ''{2,name_2}'' AS tuerevisename --風袋補正名(火曜日)
               , coalesce(cast(tare_info #>> ''{2,weight_2}'' AS integer),0) AS tuereviseweight --重量(火曜日)
               , null::varchar AS tuehospwheelchaircd --車椅子コード(火曜日)
               , null AS tuewheelchairname --車椅子名(火曜日)
               , up_date AS wedupdate --更新日時(水曜日)
               , tare_info #>> ''{3,name_2}'' AS wedrevisename --風袋補正名(水曜日)
               , coalesce(cast(tare_info #>> ''{3,weight_2}'' AS integer),0) AS wedreviseweight --重量(水曜日)
               , null::varchar AS wedhospwheelchaircd --車椅子コード(水曜日)
               , null AS wedwheelchairname --車椅子名(水曜日)
               , up_date AS thuupdate --更新日時(木曜日)
               , tare_info #>> ''{4,name_2}'' AS thurevisename --風袋補正名(木曜日)
               , coalesce(cast(tare_info #>> ''{4,weight_2}'' AS integer),0) AS thureviseweight --重量(木曜日)
               , null::varchar AS thuhospwheelchaircd --車椅子コード(木曜日)
               , null AS thuwheelchairname --車椅子名(木曜日)
               , up_date AS friupdate --更新日時(金曜日)
               , tare_info #>> ''{5,name_2}'' AS frirevisename --風袋補正名(金曜日)
               , coalesce(cast(tare_info #>> ''{5,weight_2}'' AS integer),0) AS frireviseweight --重量(金曜日)
               , null::varchar AS frihospwheelchaircd --車椅子コード(金曜日)
               , null AS friwheelchairname --車椅子名(金曜日)
               , up_date AS satupdate --更新日時(土曜日)
               , tare_info #>> ''{6,name_2}'' AS satrevisename --風袋補正名(土曜日)
               , coalesce(cast(tare_info #>> ''{6,weight_2}'' AS integer),0) AS satreviseweight --重量(土曜日)
               , null::varchar AS sathospwheelchaircd --車椅子コード(土曜日)
               , null AS satwheelchairname --車椅子名(土曜日)
               , up_date AS sunupdate --更新日時(日曜日)
               , tare_info #>> ''{7,name_2}'' AS sunrevisename --風袋補正名(日曜日)
               , coalesce(cast(tare_info #>> ''{7,weight_2}'' AS integer),0) AS sunreviseweight --重量(日曜日)
               , null::varchar AS sunhospwheelchaircd --車椅子コード(日曜日)
               , null AS sunwheelchairname --車椅子名(日曜日)
            FROM
                tabletmp
    UNION ALL
        SELECT
               '''' AS hosppatid                             --患者ID
               , pat_id AS patid --患者ID(結合用)
               , '''' AS name                               --氏名
               , 3 as ctlno                                --管理番号
               , up_date AS update --更新日時(当日)
               , CASE
                   WHEN extract(DOW FROM now()) = 1
                       THEN tare_info #>> ''{1,name_3}''
                   WHEN extract(DOW FROM now()) = 2
                       THEN tare_info #>> ''{2,name_3}''
                   WHEN extract(DOW FROM now()) = 3
                       THEN tare_info #>> ''{3,name_3}''
                   WHEN extract(DOW FROM now()) = 4
                       THEN tare_info #>> ''{4,name_3}''
                   WHEN extract(DOW FROM now()) = 5
                       THEN tare_info #>> ''{5,name_3}''
                   WHEN extract(DOW FROM now()) = 6
                       THEN tare_info #>> ''{6,name_3}''
                   WHEN extract(DOW FROM now()) = 0
                       THEN tare_info #>> ''{7,name_3}''
                   END AS revisename                       --風袋補正名(当日)
               , CASE
                   WHEN extract(DOW FROM now()) = 1
                       THEN coalesce(cast(tare_info #>> ''{1,weight_3}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 2
                       THEN coalesce(cast(tare_info #>> ''{2,weight_3}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 3
                       THEN coalesce(cast(tare_info #>> ''{3,weight_3}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 4
                       THEN coalesce(cast(tare_info #>> ''{4,weight_3}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 5
                       THEN coalesce(cast(tare_info #>> ''{5,weight_3}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 6
                       THEN coalesce(cast(tare_info #>> ''{6,weight_3}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 0
                       THEN coalesce(cast(tare_info #>> ''{7,weight_3}'' AS integer),0)
                   END AS reviseweight                     --重量(当日) 
               , null::varchar AS hospwheelchaircd --車椅子コード(当日)
               , null AS wheelchairname --車椅子名(当日)
               , up_date AS monupdate --更新日時(月曜日)
               , tare_info #>> ''{1,name_3}'' AS monrevisename --風袋補正名(月曜日)
               , coalesce(cast(tare_info #>> ''{1,weight_3}'' AS integer),0) AS monreviseweight --重量(月曜日)
               , null::varchar AS monhospwheelchaircd --車椅子コード(月曜日)
               , null AS monwheelchairname --車椅子名(月曜日)
               , up_date AS tueupdate --更新日時(火曜日)
               , tare_info #>> ''{2,name_3}'' AS tuerevisename --風袋補正名(火曜日)
               , coalesce(cast(tare_info #>> ''{2,weight_3}'' AS integer),0) AS tuereviseweight --重量(火曜日)
               , null::varchar AS tuehospwheelchaircd --車椅子コード(火曜日)
               , null AS tuewheelchairname --車椅子名(火曜日)
               , up_date AS wedupdate --更新日時(水曜日)
               , tare_info #>> ''{3,name_3}'' AS wedrevisename --風袋補正名(水曜日)
               , coalesce(cast(tare_info #>> ''{3,weight_3}'' AS integer),0) AS wedreviseweight --重量(水曜日)
               , null::varchar AS wedhospwheelchaircd --車椅子コード(水曜日)
               , null AS wedwheelchairname --車椅子名(水曜日)
               , up_date AS thuupdate --更新日時(木曜日)
               , tare_info #>> ''{4,name_3}'' AS thurevisename --風袋補正名(木曜日)
               , coalesce(cast(tare_info #>> ''{4,weight_3}'' AS integer),0) AS thureviseweight --重量(木曜日)
               , null::varchar AS thuhospwheelchaircd --車椅子コード(木曜日)
               , null AS thuwheelchairname --車椅子名(木曜日)
               , up_date AS friupdate --更新日時(金曜日)
               , tare_info #>> ''{5,name_3}'' AS frirevisename --風袋補正名(金曜日)
               , coalesce(cast(tare_info #>> ''{5,weight_3}'' AS integer),0) AS frireviseweight --重量(金曜日)
               , null::varchar AS frihospwheelchaircd --車椅子コード(金曜日)
               , null AS friwheelchairname --車椅子名(金曜日)
               , up_date AS satupdate --更新日時(土曜日)
               , tare_info #>> ''{6,name_3}'' AS satrevisename --風袋補正名(土曜日)
               , coalesce(cast(tare_info #>> ''{6,weight_3}'' AS integer),0) AS satreviseweight --重量(土曜日)
               , null::varchar AS sathospwheelchaircd --車椅子コード(土曜日)
               , null AS satwheelchairname --車椅子名(土曜日)
               , up_date AS sunupdate --更新日時(日曜日)
               , tare_info #>> ''{7,name_3}'' AS sunrevisename --風袋補正名(日曜日)
               , coalesce(cast(tare_info #>> ''{7,weight_3}'' AS integer),0) AS sunreviseweight --重量(日曜日)
               , null::varchar AS sunhospwheelchaircd --車椅子コード(日曜日)
               , null AS sunwheelchairname --車椅子名(日曜日)
            FROM
                tabletmp
    UNION ALL
        SELECT
               '''' AS hosppatid                             --患者ID
               , pat_id AS patid --患者ID(結合用)
               , '''' AS name                               --氏名
               , 4 as ctlno                                --管理番号
               , up_date AS update --更新日時(当日)
               , CASE
                   WHEN extract(DOW FROM now()) = 1
                       THEN tare_info #>> ''{1,name_4}''
                   WHEN extract(DOW FROM now()) = 2
                       THEN tare_info #>> ''{2,name_4}''
                   WHEN extract(DOW FROM now()) = 3
                       THEN tare_info #>> ''{3,name_4}''
                   WHEN extract(DOW FROM now()) = 4
                       THEN tare_info #>> ''{4,name_4}''
                   WHEN extract(DOW FROM now()) = 5
                       THEN tare_info #>> ''{5,name_4}''
                   WHEN extract(DOW FROM now()) = 6
                       THEN tare_info #>> ''{6,name_4}''
                   WHEN extract(DOW FROM now()) = 0
                       THEN tare_info #>> ''{7,name_4}''
                   END AS revisename                       --風袋補正名(当日)
               , CASE
                   WHEN extract(DOW FROM now()) = 1
                       THEN coalesce(cast(tare_info #>> ''{1,weight_4}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 2
                       THEN coalesce(cast(tare_info #>> ''{2,weight_4}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 3
                       THEN coalesce(cast(tare_info #>> ''{3,weight_4}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 4
                       THEN coalesce(cast(tare_info #>> ''{4,weight_4}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 5
                       THEN coalesce(cast(tare_info #>> ''{5,weight_4}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 6
                       THEN coalesce(cast(tare_info #>> ''{6,weight_4}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 0
                       THEN coalesce(cast(tare_info #>> ''{7,weight_4}'' AS integer),0)
                   END AS reviseweight                     --重量(当日) 
               , null::varchar AS hospwheelchaircd --車椅子コード(当日)
               , null AS wheelchairname --車椅子名(当日)
               , up_date AS monupdate --更新日時(月曜日)
               , tare_info #>> ''{1,name_4}'' AS monrevisename --風袋補正名(月曜日)
               , coalesce(cast(tare_info #>> ''{1,weight_4}'' AS integer),0) AS monreviseweight --重量(月曜日)
               , null::varchar AS monhospwheelchaircd --車椅子コード(月曜日)
               , null AS monwheelchairname --車椅子名(月曜日)
               , up_date AS tueupdate --更新日時(火曜日)
               , tare_info #>> ''{2,name_4}'' AS tuerevisename --風袋補正名(火曜日)
               , coalesce(cast(tare_info #>> ''{2,weight_4}'' AS integer),0) AS tuereviseweight --重量(火曜日)
               , null::varchar AS tuehospwheelchaircd --車椅子コード(火曜日)
               , null AS tuewheelchairname --車椅子名(火曜日)
               , up_date AS wedupdate --更新日時(水曜日)
               , tare_info #>> ''{3,name_4}'' AS wedrevisename --風袋補正名(水曜日)
               , coalesce(cast(tare_info #>> ''{3,weight_4}'' AS integer),0) AS wedreviseweight --重量(水曜日)
               , null::varchar AS wedhospwheelchaircd --車椅子コード(水曜日)
               , null AS wedwheelchairname --車椅子名(水曜日)
               , up_date AS thuupdate --更新日時(木曜日)
               , tare_info #>> ''{4,name_4}'' AS thurevisename --風袋補正名(木曜日)
               , coalesce(cast(tare_info #>> ''{4,weight_4}'' AS integer),0) AS thureviseweight --重量(木曜日)
               , null::varchar AS thuhospwheelchaircd --車椅子コード(木曜日)
               , null AS thuwheelchairname --車椅子名(木曜日)
               , up_date AS friupdate --更新日時(金曜日)
               , tare_info #>> ''{5,name_4}'' AS frirevisename --風袋補正名(金曜日)
               , coalesce(cast(tare_info #>> ''{5,weight_4}'' AS integer),0) AS frireviseweight --重量(金曜日)
               , null::varchar AS frihospwheelchaircd --車椅子コード(金曜日)
               , null AS friwheelchairname --車椅子名(金曜日)
               , up_date AS satupdate --更新日時(土曜日)
               , tare_info #>> ''{6,name_4}'' AS satrevisename --風袋補正名(土曜日)
               , coalesce(cast(tare_info #>> ''{6,weight_4}'' AS integer),0) AS satreviseweight --重量(土曜日)
               , null::varchar AS sathospwheelchaircd --車椅子コード(土曜日)
               , null AS satwheelchairname --車椅子名(土曜日)
               , up_date AS sunupdate --更新日時(日曜日)
               , tare_info #>> ''{7,name_4}'' AS sunrevisename --風袋補正名(日曜日)
               , coalesce(cast(tare_info #>> ''{7,weight_4}'' AS integer),0) AS sunreviseweight --重量(日曜日)
               , null::varchar AS sunhospwheelchaircd --車椅子コード(日曜日)
               , null AS sunwheelchairname --車椅子名(日曜日)
            FROM
                tabletmp
    UNION ALL
        SELECT
               '''' AS hosppatid                             --患者ID
               , pat_id AS patid --患者ID(結合用)
               , '''' AS name                               --氏名
               , 5 as ctlno                                --管理番号
               , up_date AS update --更新日時(当日)
               , CASE
                   WHEN extract(DOW FROM now()) = 1
                       THEN tare_info #>> ''{1,name_5}''
                   WHEN extract(DOW FROM now()) = 2
                       THEN tare_info #>> ''{2,name_5}''
                   WHEN extract(DOW FROM now()) = 3
                       THEN tare_info #>> ''{3,name_5}''
                   WHEN extract(DOW FROM now()) = 4
                       THEN tare_info #>> ''{4,name_5}''
                   WHEN extract(DOW FROM now()) = 5
                       THEN tare_info #>> ''{5,name_5}''
                   WHEN extract(DOW FROM now()) = 6
                       THEN tare_info #>> ''{6,name_5}''
                   WHEN extract(DOW FROM now()) = 0
                       THEN tare_info #>> ''{7,name_5}''
                   END AS revisename                       --風袋補正名(当日)
               , CASE
                   WHEN extract(DOW FROM now()) = 1
                       THEN coalesce(cast(tare_info #>> ''{1,weight_5}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 2
                       THEN coalesce(cast(tare_info #>> ''{2,weight_5}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 3
                       THEN coalesce(cast(tare_info #>> ''{3,weight_5}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 4
                       THEN coalesce(cast(tare_info #>> ''{4,weight_5}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 5
                       THEN coalesce(cast(tare_info #>> ''{5,weight_5}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 6
                       THEN coalesce(cast(tare_info #>> ''{6,weight_5}'' AS integer),0)
                   WHEN extract(DOW FROM now()) = 0
                       THEN coalesce(cast(tare_info #>> ''{7,weight_5}'' AS integer),0)
                   END AS reviseweight                     --重量(当日) 
               , null::varchar AS hospwheelchaircd --車椅子コード(当日)
               , null AS wheelchairname --車椅子名(当日)
               , up_date AS monupdate --更新日時(月曜日)
               , tare_info #>> ''{1,name_5}'' AS monrevisename --風袋補正名(月曜日)
               , coalesce(cast(tare_info #>> ''{1,weight_5}'' AS integer),0) AS monreviseweight --重量(月曜日)
               , null::varchar AS monhospwheelchaircd --車椅子コード(月曜日)
               , null AS monwheelchairname --車椅子名(月曜日)
               , up_date AS tueupdate --更新日時(火曜日)
               , tare_info #>> ''{2,name_5}'' AS tuerevisename --風袋補正名(火曜日)
               , coalesce(cast(tare_info #>> ''{2,weight_5}'' AS integer),0) AS tuereviseweight --重量(火曜日)
               , null::varchar AS tuehospwheelchaircd --車椅子コード(火曜日)
               , null AS tuewheelchairname --車椅子名(火曜日)
               , up_date AS wedupdate --更新日時(水曜日)
               , tare_info #>> ''{3,name_5}'' AS wedrevisename --風袋補正名(水曜日)
               , coalesce(cast(tare_info #>> ''{3,weight_5}'' AS integer),0) AS wedreviseweight --重量(水曜日)
               , null::varchar AS wedhospwheelchaircd --車椅子コード(水曜日)
               , null AS wedwheelchairname --車椅子名(水曜日)
               , up_date AS thuupdate --更新日時(木曜日)
               , tare_info #>> ''{4,name_5}'' AS thurevisename --風袋補正名(木曜日)
               , coalesce(cast(tare_info #>> ''{4,weight_5}'' AS integer),0) AS thureviseweight --重量(木曜日)
               , null::varchar AS thuhospwheelchaircd --車椅子コード(木曜日)
               , null AS thuwheelchairname --車椅子名(木曜日)
               , up_date AS friupdate --更新日時(金曜日)
               , tare_info #>> ''{5,name_5}'' AS frirevisename --風袋補正名(金曜日)
               , coalesce(cast(tare_info #>> ''{5,weight_5}'' AS integer),0) AS frireviseweight --重量(金曜日)
               , null::varchar AS frihospwheelchaircd --車椅子コード(金曜日)
               , null AS friwheelchairname --車椅子名(金曜日)
               , up_date AS satupdate --更新日時(土曜日)
               , tare_info #>> ''{6,name_5}'' AS satrevisename --風袋補正名(土曜日)
               , coalesce(cast(tare_info #>> ''{6,weight_5}'' AS integer),0) AS satreviseweight --重量(土曜日)
               , null::varchar AS sathospwheelchaircd --車椅子コード(土曜日)
               , null AS satwheelchairname --車椅子名(土曜日)
               , up_date AS sunupdate --更新日時(日曜日)
               , tare_info #>> ''{7,name_5}'' AS sunrevisename --風袋補正名(日曜日)
               , coalesce(cast(tare_info #>> ''{7,weight_5}'' AS integer),0) AS sunreviseweight --重量(日曜日)
               , null::varchar AS sunhospwheelchaircd --車椅子コード(日曜日)
               , null AS sunwheelchairname --車椅子名(日曜日)
            FROM
                tabletmp
    UNION ALL
    SELECT
               '''' AS hosppatid                             --患者ID
               , pat_id AS patid --患者ID(結合用)
               , '''' AS name                               --氏名
               , 6 as ctlno                                --管理番号
               , up_date AS update --更新日時(当日)
               , wheel_chair_name AS revisename                       --風袋補正名(当日)
               , coalesce(wheel_chair_weight,0) AS reviseweight --重量(当日) 
               , in_hospital_cd_1 AS hospwheelchaircd --車椅子コード(当日)
               , wheel_chair_name AS wheelchairname --車椅子名(当日)
               , up_date AS monupdate --更新日時(月曜日)
               , wheel_chair_name AS monrevisename --風袋補正名(月曜日)
               , coalesce(wheel_chair_weight,0) AS monreviseweight --重量(月曜日)
               , in_hospital_cd_1 AS monhospwheelchaircd --車椅子コード(月曜日)
               , wheel_chair_name AS monwheelchairname --車椅子名(月曜日)
               , up_date AS tueupdate --更新日時(火曜日)
               , wheel_chair_name AS tuerevisename --風袋補正名(火曜日)
               , coalesce(wheel_chair_weight,0) AS tuereviseweight --重量(火曜日)
               , in_hospital_cd_1 AS tuehospwheelchaircd --車椅子コード(火曜日)
               , wheel_chair_name AS tuewheelchairname --車椅子名(火曜日)
               , up_date AS wedupdate --更新日時(水曜日)
               , wheel_chair_name AS wedrevisename --風袋補正名(水曜日)
               , coalesce(wheel_chair_weight,0) AS wedreviseweight --重量(水曜日)
               , in_hospital_cd_1 AS wedhospwheelchaircd --車椅子コード(水曜日)
               , wheel_chair_name AS wedwheelchairname --車椅子名(水曜日)
               , up_date AS thuupdate --更新日時(木曜日)
               , wheel_chair_name AS thurevisename --風袋補正名(木曜日)
               , coalesce(wheel_chair_weight,0) AS thureviseweight --重量(木曜日)
               , in_hospital_cd_1 AS thuhospwheelchaircd --車椅子コード(木曜日)
               , wheel_chair_name AS thuwheelchairname --車椅子名(木曜日)
               , up_date AS friupdate --更新日時(金曜日)
               , wheel_chair_name AS frirevisename --風袋補正名(金曜日)
               , coalesce(wheel_chair_weight,0) AS frireviseweight --重量(金曜日)
               , in_hospital_cd_1 AS frihospwheelchaircd --車椅子コード(金曜日)
               , wheel_chair_name AS friwheelchairname --車椅子名(金曜日)
               , up_date AS satupdate --更新日時(土曜日)
               , wheel_chair_name AS satrevisename --風袋補正名(土曜日)
               , coalesce(wheel_chair_weight,0) AS satreviseweight --重量(土曜日)
               , in_hospital_cd_1 AS sathospwheelchaircd --車椅子コード(土曜日)
               , wheel_chair_name AS satwheelchairname --車椅子名(土曜日)
               , up_date AS sunupdate --更新日時(日曜日)
               , wheel_chair_name AS sunrevisename --風袋補正名(日曜日)
               , coalesce(wheel_chair_weight,0) AS sunreviseweight --重量(日曜日)
               , in_hospital_cd_1 AS sunhospwheelchaircd --車椅子コード(日曜日)
               , wheel_chair_name AS sunwheelchairname --車椅子名(日曜日)
            FROM
                tabletmp
    )as uniontable;
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2090, 'WITH last_weight_table AS ( --前回体重導出用
SELECT ord_no, last_weight FROM (
    SELECT
        om.ord_no AS ord_no
        ,om.treat_date
        ,LAG(rst_weight_info, -1) OVER (PARTITION BY om.pat_id ORDER BY om.rst_start_date DESC) ->> ''weight_after'' AS last_weight
    FROM ord_main om
    JOIN mst_treatment m_tr
    ON om.rst_treatment_cd = m_tr.treatment_cd
    AND m_tr.facility_cd = @facilityCd
    WHERE om.facility_cd = @facilityCd
    AND om.treat_date < @toDate
    AND om.is_del = ''0''
    AND om.rst_dialysis_state = ''6''
    AND m_tr.device_mode <> 9
    AND m_tr.is_del = ''0''
    AND m_tr.is_disp = ''1''
    ) AS om2
    WHERE @fromDate <= om2.treat_date
),
re_loop_rate_table AS ( --再循環率
    SELECT
        om.ord_no AS ord_no
        , json_rr.value::jsonb ->> ''rate'' AS relooprate
    FROM (
        SELECT
            om.ord_no
            , om.rst_weight_info #>> ''{recrcl_rt, "valid_no"}'' AS valid_no
            , om.rst_weight_info #> ''{recrcl_rt}'' AS recrcl_rt
        FROM ord_main om
        WHERE om.facility_cd = @facilityCd
        AND om.rst_dialysis_state = ''6''
        AND @fromDate <= om.treat_date AND om.treat_date < @toDate
        AND om.is_del = ''0''
        AND om.rst_weight_info IS NOT NULL
        AND om.rst_weight_info #> ''{recrcl_rt}'' <> ''null''
    ) AS om
    CROSS JOIN lateral jsonb_each_text(om.recrcl_rt::jsonb) json_rr
    WHERE json_rr.key = om.valid_no
)
SELECT
    '''' AS hosppatid --患者ID
    ,om.pat_id AS patid
    ,'''' AS name --氏名
    ,om.treat_date AS dialysisdate --透析日
    ,om.ord_no AS dialysisno --透析番号
    ,to_char(om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    ,m_b.in_hospital_cd_1 AS bedno --ベッド番号
    ,om.rst_bed_name AS bedname --ベッド名
    ,m_mac.in_hospital_cd_1 AS deviceno --装置番号
    ,om.rst_machine_name AS devicename --装置名
    ,m_k.in_hospital_cd_1 AS kurcd --クール
    ,om.rst_kur_name AS kurname --クール名
    ,to_char(om.rst_start_date, ''YYYY-MM-DD hh24:mi:ss'') AS startdate --透析開始日時
    ,to_char(om.rst_end_date, ''YYYY-MM-DD hh24:mi:ss'') AS enddate --透析終了日時
    ,round(date_part(''epoch'',om.rst_end_date - om.rst_start_date)::NUMERIC / 60) AS dialysistime --透析時間
    ,om.rst_cond_info ::jsonb #>> ''{1,value}'' AS plandialysistime --予定透析時間
    ,om.rst_dialysis_cnt AS dialysisnum --透析回数
    ,last_weight_table.last_weight AS lastweight --前回体重
    ,om.rst_weight_info #>> ''{weight_before}'' AS weightbefore --前体重
    ,om.rst_weight_info #>> ''{weight_after}'' AS weightafter --後体重
    ,mm_b.monitor_data ->> ''90''  AS bpbeforemax --透析前最高血圧
    ,mm_b.monitor_data ->> ''91''  AS bpbeforemin --透析前最低血圧
    ,mm_b.monitor_data ->> ''92''  AS bpbeforeave --透析前平均血圧
    ,mm_a.monitor_data ->> ''90''  AS bpaftermax --透析後最高血圧
    ,mm_a.monitor_data ->> ''91''  AS bpaftermin --透析後最低血圧
    ,mm_a.monitor_data ->> ''92''  AS bpafterave --透析後平均血圧
    ,om.rst_weight_info #>> ''{water_removal_target}'' AS waterremovaltarget --目標除水量
    ,om.rst_off_water_info #>> ''{name_1}'' AS revisename1 --除水補正項目１
    ,om.rst_off_water_info #>> ''{weight_1}'' AS reviseweight1 --除水補正値１
    ,om.rst_off_water_info #>> ''{name_2}'' AS revisename2 --除水補正項目２
    ,om.rst_off_water_info #>> ''{weight_2}'' AS reviseweight2 --除水補正値２
    ,om.rst_off_water_info #>> ''{name_3}'' AS revisename3 --除水補正項目３
    ,om.rst_off_water_info #>> ''{weight_3}'' AS reviseweight3 --除水補正値３
    ,om.rst_off_water_info #>> ''{name_4}'' AS revisename4 --除水補正項目４
    ,om.rst_off_water_info #>> ''{weight_4}'' AS reviseweight4 --除水補正値４
    ,om.rst_off_water_info #>> ''{name_5}'' AS revisename5 --除水補正項目５
    ,om.rst_off_water_info #>> ''{weight_5}'' AS reviseweight5 --除水補正値５
    ,mm_b.monitor_data ->> ''93'' AS pulsebefore --透析前脈拍
    ,mm_a.monitor_data ->> ''93'' AS pulseafter --透析後脈拍
    ,CONCAT(om.rst_charge_user_info #>> ''{user_last_name_1}''
        ,''　''
        , om.rst_charge_user_info #>> ''{user_first_name_1}'') AS charge1name --担当者１
    ,CONCAT(om.rst_charge_user_info #>> ''{user_last_name_2}''
        ,''　''
        , om.rst_charge_user_info #>> ''{user_first_name_2}'') AS charge2name --担当者２
    ,to_char((om.rst_charge_user_info #>> ''{date_1}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS chargedate1 --担当日時１
    ,to_char((om.rst_charge_user_info #>> ''{date_2}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS chargedate2 --担当日時２
    ,CONCAT(om.rst_puncture_user_info #>> ''{user_last_name_1}''
        ,''　''
        , om.rst_puncture_user_info #>> ''{user_first_name_1}'') AS puncture1name --穿刺者１
    ,CONCAT(om.rst_puncture_user_info #>> ''{user_last_name_2}''
        ,''　''
        , om.rst_puncture_user_info #>> ''{user_first_name_2}'') AS puncture2name --穿刺者２
    ,to_char((om.rst_puncture_user_info #>> ''{date_1}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS puncturedate1 --穿刺日時１
    ,to_char((om.rst_puncture_user_info #>> ''{date_2}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS puncturedate2 --穿刺日時２
    ,CONCAT(om.rst_return_user_info #>> ''{user_last_name_1}''
        ,''　''
        , om.rst_return_user_info #>> ''{user_first_name_1}'') AS collect1name --回収者１
    ,CONCAT(om.rst_return_user_info #>> ''{user_last_name_2}''
        ,''　''
        , om.rst_return_user_info #>> ''{user_first_name_2}'') AS collect2name --回収者２
    ,to_char((om.rst_return_user_info #>> ''{date_1}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS collectdate1 --回収日時１
    ,to_char((om.rst_return_user_info #>> ''{date_2}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS collectdate2 --回収日時２
    ,om.rst_in_out_class AS inoutflg --入外
    ,om.rst_weight_info #>> ''{kt_v_measure}'' AS ktvmeasure --Kt/v測定値
    ,om.rst_weight_info #>> ''{urr}'' AS urr --URR
    ,re_loop_rate_table.relooprate AS relooprate --再循環率
    ,om.rst_weight_info #>> ''{ihdf_pll}'' AS pullleaveamount --I-HDF引き残し量
    ,om.rst_weight_info #>> ''{add_total}'' AS addtotal --除水積算値
    ,om.rst_weight_info #>> ''{sttc_vns_prssr}'' AS staticvenouspressure --静的静脈圧
    ,om.rst_weight_info #>> ''{iap_rt}'' AS venousaccesspressureratio --IAP ratio
FROM
    ord_main om
    LEFT JOIN mst_bed m_b
    ON m_b.bed_cd = om.rst_bed_cd
    AND m_b.facility_cd = @facilityCd
    AND m_b.is_del = ''0''
    AND m_b.is_disp = ''1''
    LEFT JOIN mst_machine m_mac
    ON m_mac.machine_no = om.rst_machine_no
    AND m_mac.facility_cd = @facilityCd
    AND m_mac.is_del = ''0''
    AND m_mac.is_disp = ''1''
    LEFT JOIN mst_kur m_k
    ON m_k.kur_cd = om.rst_kur_cd
    AND m_k.facility_cd = @facilityCd
    AND m_k.is_del = ''0''
    LEFT JOIN last_weight_table
    ON last_weight_table.ord_no = om.ord_no
    LEFT JOIN mni_monitor mm_b
    ON mm_b.ord_no = om.ord_no
    AND mm_b.facility_cd = @facilityCd
    AND mm_b.data_type = ''5''
    AND mm_b.monitor_data IS NOT NULL
    AND mm_b.is_del = ''0''
    LEFT JOIN mni_monitor mm_a
    ON mm_a.ord_no = om.ord_no
    AND mm_a.facility_cd = @facilityCd
    AND mm_a.data_type = ''6''
    AND mm_a.monitor_data IS NOT NULL
    AND mm_a.is_del = ''0''
    LEFT JOIN re_loop_rate_table
    ON re_loop_rate_table.ord_no = om.ord_no
WHERE
    om.is_del = ''0''
    AND om.facility_cd = @facilityCd
    AND om.rst_dialysis_state = ''6''
    AND om.pat_id IS NOT NULL
    AND @fromDate <= om.treat_date AND om.treat_date < @toDate;', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2091, 'SELECT
            pat_id AS patid
            ,hosp_pat_id AS hosppatid
            ,CONCAT(personal_info_decrypt(pat_last_name), ''　'', personal_info_decrypt(pat_first_name)) AS name --氏名
        FROM
            pat_personal_main
        WHERE
            facility_cd = @facilityCd
            AND is_del = ''0'';', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2100, '-- 【SQL_CD=-2100】
WITH
 om AS NOT MATERIALIZED (
    SELECT
        om.ord_no
        ,om.pat_id
        ,om.treat_date AS dialysisdate
        ,CAST(om.treat_date as DATE) AS treat_date
        ,om.rst_cond_info
        ,om.rst_treatment_cd
        ,om.up_date
        ,om.rst_dw
    FROM
        ord_main om
    WHERE
        om.facility_cd = @facilityCd
        AND om.is_del = ''0''
        AND @fromDate <= om.treat_date AND om.treat_date < @toDate
)
, m_t AS (
    SELECT
        m_t.treatment_cd
        , m_t.treatment_name
        , CAST(m_t.in_hosp_a_startdate AS date) AS in_hosp_a_startdate
        , m_t.in_hospital_cd_a1
        , m_t.in_hospital_cd_a2
        , CAST(m_t.in_hosp_b_startdate AS date) AS in_hosp_b_startdate
        , m_t.in_hospital_cd_b1
        , m_t.in_hospital_cd_b2
    FROM
        mst_treatment m_t
    WHERE
        m_t.facility_cd = @facilityCd
        AND m_t.is_del = ''0''
        AND m_t.is_disp = ''1''
)
, rst_cond_list AS (
    SELECT --rst_cond_info
        om.ord_no
        , rst_cond_info_json.key AS key
        , rst_cond_info_json.value::JSONB ->> ''value'' AS value
        , rst_cond_info_json.value::JSONB ->> ''value_name_1'' AS value_name_1
        , rst_cond_info_json.value::JSONB ->> ''unit'' AS unit
        , '''' AS valuecd2
        , rst_cond_info_json.value::JSONB ->> ''medicine_type'' AS medicine_type
    FROM
        om
        CROSS JOIN lateral jsonb_each_text(om.rst_cond_info) rst_cond_info_json
    WHERE
        rst_cond_info_json.key IN(''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'',''12'',''14'',''15'',''16'',''17'',''18'',''19'',''20'',''21'',''22'',''23'',''24'',''25'',''26'',''27'',''28'',''29'',''30'',''31'',''32'',''33'',''34'',''35'',''36'',''37'',''38'')
    UNION ALL
    SELECT --dw
        om.ord_no
        , ''992'' AS key
        , CAST(om.rst_dw AS text) AS value
        , '''' AS value_name_1
        , ''kg'' AS unit
        , '''' AS valuecd2
        , '''' AS medicine_type
    FROM
        om
    UNION ALL
    SELECT --治療方法
        om.ord_no
        , ''993'' AS key
        , CASE
            WHEN om.treat_date >= m_t.in_hosp_a_startdate
            AND om.treat_date >= m_t.in_hosp_b_startdate
                THEN CASE
                    WHEN m_t.in_hosp_a_startdate >= m_t.in_hosp_b_startdate
                        THEN m_t.in_hospital_cd_a1
                    WHEN m_t.in_hosp_a_startdate < m_t.in_hosp_b_startdate
                        THEN m_t.in_hospital_cd_b1
                    END
            WHEN om.treat_date >= m_t.in_hosp_a_startdate
            AND (om.treat_date < m_t.in_hosp_b_startdate
                OR m_t.in_hosp_b_startdate IS NULL)
                THEN m_t.in_hospital_cd_a1
            WHEN (om.treat_date < m_t.in_hosp_a_startdate
                OR m_t.in_hosp_a_startdate IS NULL)
            AND om.treat_date >= m_t.in_hosp_b_startdate
                THEN m_t.in_hospital_cd_b1
            ELSE NULL
            END AS value
        , m_t.treatment_name AS value_name_1
        , '''' AS unit
        , CASE
            WHEN om.treat_date >= m_t.in_hosp_a_startdate
            AND om.treat_date >= m_t.in_hosp_b_startdate
                THEN CASE
                    WHEN m_t.in_hosp_a_startdate >= m_t.in_hosp_b_startdate
                        THEN m_t.in_hospital_cd_a2
                    WHEN m_t.in_hosp_a_startdate < m_t.in_hosp_b_startdate
                        THEN m_t.in_hospital_cd_b2
                    END
            WHEN om.treat_date >= m_t.in_hosp_a_startdate
            AND (om.treat_date < m_t.in_hosp_b_startdate
                OR m_t.in_hosp_b_startdate IS NULL)
                THEN m_t.in_hospital_cd_a2
            WHEN (om.treat_date < m_t.in_hosp_a_startdate
                OR m_t.in_hosp_a_startdate IS NULL)
            AND om.treat_date >= m_t.in_hosp_b_startdate
                THEN m_t.in_hospital_cd_b2
            ELSE NULL
            END AS valuecd2
        , '''' AS medicine_type
    FROM
        om
        LEFT JOIN m_t
        ON om.rst_treatment_cd = m_t.treatment_cd
)
, m_va AS (
    SELECT
        m_va.va_cd
        , m_va.in_hospital_cd_1
        , m_va.in_hospital_cd_2
    FROM
        mst_va m_va
    WHERE
        m_va.facility_cd = @facilityCd
        AND m_va.is_del = ''0''
        AND m_va.is_disp = ''1''
)
, m_d AS (
    SELECT
        m_d.dialyzer_cd
        , m_d.in_hospital_cd_1
        , m_d.in_hospital_cd_2
    FROM
        mst_dialyzer m_d
    WHERE
        m_d.facility_cd = @facilityCd
        AND m_d.is_del = ''0''
        AND m_d.is_disp = ''1''
)
, m_e AS (
    SELECT
        m_e.equipment_cd
        , m_e.in_hospital_cd_1
        , m_e.in_hospital_cd_2
    FROM
        mst_equipment m_e
    WHERE
        m_e.facility_cd = @facilityCd
        AND m_e.is_del = ''0''
        AND m_e.is_disp = ''1''
)
, m_m AS (
    SELECT
        m_m.medicine_cd
        , m_m.in_hospital_cd_1
        , m_m.in_hospital_cd_2
    FROM
        mst_medicine m_m
    WHERE
        m_m.facility_cd = @facilityCd
        AND m_m.is_del = ''0''
        AND m_m.is_disp = ''1''
)
, m_m_mix AS (
    SELECT
        m_m_mix.medicine_mix_cd
        , m_m_mix.in_hospital_cd_1
        , m_m_mix.in_hospital_cd_2
    FROM
        mst_medicine_mix m_m_mix
    WHERE
        m_m_mix.facility_cd = @facilityCd
        AND m_m_mix.is_del = ''0''
        AND m_m_mix.is_disp = ''1''
)
SELECT
    '''' AS hosppatid                             --患者ID
    , om.pat_id AS patid
    , om.dialysisdate AS dialysisdate    --透析日
    , om.ord_no AS dialysisno            --透析番号
    , CASE
        WHEN rst_cond_list.key = ''1'' THEN ''002''
        WHEN rst_cond_list.key = ''2'' THEN ''003''
        WHEN rst_cond_list.key = ''992'' THEN ''004''
        WHEN rst_cond_list.key = ''3'' THEN ''005''
        WHEN rst_cond_list.key = ''993'' THEN ''006''
        WHEN rst_cond_list.key = ''4'' THEN ''007''
        WHEN rst_cond_list.key = ''5'' THEN ''008''
        WHEN rst_cond_list.key = ''6'' THEN ''009''
        WHEN rst_cond_list.key = ''14'' THEN ''010''
        WHEN rst_cond_list.key = ''25'' THEN ''011''
        WHEN rst_cond_list.key = ''26'' THEN ''012''
        WHEN rst_cond_list.key = ''27'' THEN ''013''
        WHEN rst_cond_list.key = ''28'' THEN ''014''
        WHEN rst_cond_list.key = ''29'' THEN ''015''
        WHEN rst_cond_list.key = ''31'' THEN ''016''
        WHEN rst_cond_list.key = ''32'' THEN ''017''
        WHEN rst_cond_list.key = ''15'' THEN ''018''
        WHEN rst_cond_list.key = ''16'' THEN ''019''
        WHEN rst_cond_list.key = ''17'' THEN ''020''
        WHEN rst_cond_list.key = ''18'' THEN ''021''
        WHEN rst_cond_list.key = ''19'' THEN ''022''
        WHEN rst_cond_list.key = ''20'' THEN ''023''
        WHEN rst_cond_list.key = ''21'' THEN ''024''
        WHEN rst_cond_list.key = ''23'' THEN ''025''
        WHEN rst_cond_list.key = ''12'' THEN ''029''
        WHEN rst_cond_list.key = ''22'' THEN ''030''
        WHEN rst_cond_list.key = ''30'' THEN ''031''
        WHEN rst_cond_list.key = ''34'' THEN ''032''
        WHEN rst_cond_list.key = ''35'' THEN ''033''
        WHEN rst_cond_list.key = ''36'' THEN ''034''
        WHEN rst_cond_list.key = ''37'' THEN ''035''
        WHEN rst_cond_list.key = ''38'' THEN ''036''
        WHEN rst_cond_list.key = ''33'' THEN ''037''
        WHEN rst_cond_list.key = ''24'' THEN ''038''
        WHEN rst_cond_list.key = ''7'' THEN ''039''
        WHEN rst_cond_list.key = ''8'' THEN ''040''
        ELSE NULL
        END AS ctlno       --透析条件項目コード
    , to_char(om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    , CASE
        WHEN rst_cond_list.key = ''1'' THEN ''透析時間''
        WHEN rst_cond_list.key = ''2'' THEN ''VA''
        WHEN rst_cond_list.key = ''992'' THEN ''DW''
        WHEN rst_cond_list.key = ''3'' THEN ''目標体重''
        WHEN rst_cond_list.key = ''993'' THEN ''治療方法''
        WHEN rst_cond_list.key = ''4'' THEN ''除水量制限''
        WHEN rst_cond_list.key = ''5'' THEN ''ダイアライザ''
        WHEN rst_cond_list.key = ''6'' THEN ''吸着カラム''
        WHEN rst_cond_list.key = ''14'' THEN ''血流量''
        WHEN rst_cond_list.key = ''25'' THEN ''抗凝固剤''
        WHEN rst_cond_list.key = ''26'' THEN ''抗凝固剤ワンショット量''
        WHEN rst_cond_list.key = ''27'' THEN ''抗凝固剤持続速度''
        WHEN rst_cond_list.key = ''28'' THEN ''抗凝固剤持続総量''
        WHEN rst_cond_list.key = ''29'' THEN ''IP使用選択''
        WHEN rst_cond_list.key = ''31'' THEN ''IPワンショット量''
        WHEN rst_cond_list.key = ''32'' THEN ''IP速度''
        WHEN rst_cond_list.key = ''15'' THEN ''透析液''
        WHEN rst_cond_list.key = ''16'' THEN ''透析液流量''
        WHEN rst_cond_list.key = ''17'' THEN ''透析液量''
        WHEN rst_cond_list.key = ''18'' THEN ''透析液温度''
        WHEN rst_cond_list.key = ''19'' THEN ''補液''
        WHEN rst_cond_list.key = ''20'' THEN ''補液量''
        WHEN rst_cond_list.key = ''21'' THEN ''補液選択''
        WHEN rst_cond_list.key = ''23'' THEN ''補液温度''
        WHEN rst_cond_list.key = ''12'' THEN ''シングルニードル使用''
        WHEN rst_cond_list.key = ''22'' THEN ''補液使用数''
        WHEN rst_cond_list.key = ''30'' THEN ''IPスタート''
        WHEN rst_cond_list.key = ''34'' THEN ''自動ワンショット''
        WHEN rst_cond_list.key = ''35'' THEN ''IP電源自動切り''
        WHEN rst_cond_list.key = ''36'' THEN ''IP電源自動切り時間''
        WHEN rst_cond_list.key = ''37'' THEN ''IP電源OKモニタ切り''
        WHEN rst_cond_list.key = ''38'' THEN ''IP電源OKモニタ切り時間''
        WHEN rst_cond_list.key = ''33'' THEN ''IP速度最大値''
        WHEN rst_cond_list.key = ''24'' THEN ''補液速度''
        WHEN rst_cond_list.key = ''7'' THEN ''1次膜''
        WHEN rst_cond_list.key = ''8'' THEN ''2次膜''
        ELSE NULL
        END AS dialysisitemname --透析条件項目名
    , CASE
        WHEN rst_cond_list.key = ''2'' THEN m_va.in_hospital_cd_1
        WHEN rst_cond_list.key = ''992'' THEN to_char(rst_cond_list.value::numeric, ''FM990.00'')
        WHEN rst_cond_list.key = ''3'' THEN to_char(rst_cond_list.value::numeric, ''FM990.00'')
        WHEN rst_cond_list.key = ''4'' THEN to_char(rst_cond_list.value::numeric, ''FM90.00'')
        WHEN rst_cond_list.key = ''5'' THEN m_d.in_hospital_cd_1
        WHEN rst_cond_list.key = ''6''
        OR rst_cond_list.key = ''7''
        OR rst_cond_list.key = ''8''
            THEN m_e.in_hospital_cd_1
        WHEN rst_cond_list.key = ''25''
        OR rst_cond_list.key = ''15''
        OR rst_cond_list.key = ''19''
            THEN CASE
                WHEN rst_cond_list.medicine_type = ''1'' THEN m_m.in_hospital_cd_1
                WHEN rst_cond_list.medicine_type = ''2'' THEN m_m_mix.in_hospital_cd_1
                ELSE NULL
                END
        WHEN rst_cond_list.key = ''26'' THEN to_char(rst_cond_list.value::numeric, ''FM99990.00'')
        WHEN rst_cond_list.key = ''27'' THEN to_char(rst_cond_list.value::numeric, ''FM99990.00'')
        WHEN rst_cond_list.key = ''28'' THEN to_char(rst_cond_list.value::numeric, ''FM99990.00'')
        WHEN rst_cond_list.key = ''31'' THEN to_char(rst_cond_list.value::numeric, ''FM90.0'')
        WHEN rst_cond_list.key = ''32'' THEN to_char(rst_cond_list.value::numeric, ''FM90.0'')
        WHEN rst_cond_list.key = ''17'' THEN to_char(rst_cond_list.value::numeric, ''FM99990.00'')
        WHEN rst_cond_list.key = ''18'' THEN to_char(rst_cond_list.value::numeric, ''FM90.0'')
        WHEN rst_cond_list.key = ''20'' THEN to_char(rst_cond_list.value::numeric, ''FM990.0'')
        WHEN rst_cond_list.key = ''23'' THEN to_char(rst_cond_list.value::numeric, ''FM90.0'')
        WHEN rst_cond_list.key = ''33'' THEN to_char(rst_cond_list.value::numeric, ''FM90.0'')
        WHEN rst_cond_list.key = ''24'' THEN to_char(rst_cond_list.value::numeric, ''FM990.00'')
        ELSE rst_cond_list.value
        END AS value          --設定値
    , CASE
        WHEN rst_cond_list.key = ''29''
        OR rst_cond_list.key = ''12''
        OR rst_cond_list.key = ''34''
            THEN CASE
                WHEN rst_cond_list.value = ''1'' THEN ''使用する''
                WHEN rst_cond_list.value = ''0'' THEN ''使用しない''
                ELSE NULL
                END
        WHEN rst_cond_list.key = ''21''
            THEN CASE
                WHEN rst_cond_list.value = ''1'' THEN ''前補液''
                WHEN rst_cond_list.value = ''0'' THEN ''後補液''
                ELSE NULL
                END
        WHEN rst_cond_list.key = ''30''
            THEN CASE
                WHEN rst_cond_list.value = ''1'' THEN ''自動''
                WHEN rst_cond_list.value = ''0'' THEN ''手動''
                ELSE NULL
                END
        WHEN rst_cond_list.key = ''35''
        OR rst_cond_list.key = ''37''
            THEN CASE
                WHEN rst_cond_list.value = ''1'' THEN ''入り''
                WHEN rst_cond_list.value = ''0'' THEN ''切り''
                ELSE NULL
                END
        ELSE rst_cond_list.value_name_1
        END AS valuename --名称
    , CASE
        WHEN rst_cond_list.key = ''1'' THEN ''分''
        WHEN rst_cond_list.key = ''3'' THEN ''kg''
        WHEN rst_cond_list.key = ''4'' THEN ''L''
        WHEN rst_cond_list.key = ''14'' THEN ''mL/min''
        WHEN rst_cond_list.key = ''31'' THEN ''mL''
        WHEN rst_cond_list.key = ''32'' THEN ''mL/h''
        WHEN rst_cond_list.key = ''16'' THEN ''mL/min''
        WHEN rst_cond_list.key = ''18'' THEN ''℃''
        WHEN rst_cond_list.key = ''20'' THEN ''L''
        WHEN rst_cond_list.key = ''23'' THEN ''℃''
        WHEN rst_cond_list.key = ''36'' THEN ''分''
        WHEN rst_cond_list.key = ''38'' THEN ''分''
        WHEN rst_cond_list.key = ''33'' THEN ''mL/h''
        WHEN rst_cond_list.key = ''24'' THEN ''L/h''
        ELSE rst_cond_list.unit
        END AS unit            --単位
    , CASE
        WHEN rst_cond_list.key = ''2'' THEN m_va.in_hospital_cd_2
        WHEN rst_cond_list.key = ''993'' THEN rst_cond_list.valuecd2
        WHEN rst_cond_list.key = ''5'' THEN m_d.in_hospital_cd_2
        WHEN rst_cond_list.key = ''6''
        OR rst_cond_list.key = ''7''
        OR rst_cond_list.key = ''8''
            THEN m_e.in_hospital_cd_2
        WHEN rst_cond_list.key = ''25''
        OR rst_cond_list.key = ''15''
        OR rst_cond_list.key = ''19''
            THEN CASE
                WHEN rst_cond_list.medicine_type = ''1'' THEN m_m.in_hospital_cd_2
                WHEN rst_cond_list.medicine_type = ''2'' THEN m_m_mix.in_hospital_cd_2
                ELSE NULL
                END
        ELSE NULL
        END AS valuecd2 --院内コード2
FROM
    om
    LEFT JOIN rst_cond_list
        ON om.ord_no = rst_cond_list.ord_no
    LEFT JOIN m_va
        ON rst_cond_list.value = m_va.va_cd ::text
    LEFT JOIN m_d
        ON rst_cond_list.value = m_d.dialyzer_cd ::text
    LEFT JOIN m_e
        ON rst_cond_list.value = m_e.equipment_cd ::text
    LEFT JOIN m_m
        ON rst_cond_list.value = m_m.medicine_cd ::text
    LEFT JOIN m_m_mix
        ON rst_cond_list.value = m_m_mix.medicine_mix_cd ::text;
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, '[{"sql_cd": -2518}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2110, '-- 【SQL_CD=-2110】
WITH ntss_db5_om_temp AS (
    SELECT
        om.ord_no
        ,om.pat_id
        ,om.treat_date AS dialysisdate
        ,CAST(om.treat_date as DATE) AS treat_date
        ,om.rst_cond_info
        ,om.ind_treat_start_time
        ,om.rst_treatment_cd
        ,om.up_date
        ,om.rst_dw
    FROM
        ord_main om
    WHERE
        om.facility_cd = @facilityCd
        AND om.is_del = ''0''
        AND @fromDate <= om.treat_date AND om.treat_date < @toDate
)
,mst_treatment_disp_order_tbl AS (
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
)
, ntss_db5_om_1 AS (
    SELECT
        ntss_db5_om_temp.ord_no
        , ROW_NUMBER() OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date ORDER BY ntss_db5_om_temp.ind_treat_start_time ASC, mst_treatment_disp_order_tbl.treatment_cd_order ASC) AS plural
    FROM
        ntss_db5_om_temp
        LEFT JOIN mst_treatment_disp_order_tbl
        ON ntss_db5_om_temp.rst_treatment_cd ::text = mst_treatment_disp_order_tbl.treatment_cd
)
, ntss_db5_mst_t AS (
    SELECT
        ntss_db5_mst_t.treatment_cd
        , ntss_db5_mst_t.treatment_name
        , CAST(ntss_db5_mst_t.in_hosp_a_startdate AS date) AS in_hosp_a_startdate
        , ntss_db5_mst_t.in_hospital_cd_a1
        , ntss_db5_mst_t.in_hospital_cd_a2
        , CAST(ntss_db5_mst_t.in_hosp_b_startdate AS date) AS in_hosp_b_startdate
        , ntss_db5_mst_t.in_hospital_cd_b1
        , ntss_db5_mst_t.in_hospital_cd_b2
    FROM
        mst_treatment ntss_db5_mst_t
    WHERE
        ntss_db5_mst_t.facility_cd = @facilityCd
        AND ntss_db5_mst_t.is_del = ''0''
        AND ntss_db5_mst_t.is_disp = ''1''
)
, rst_cond_list AS (
    SELECT --rst_cond_info
        ntss_db5_om_temp.ord_no
        , rst_cond_info_json.key AS key
        , rst_cond_info_json.value::JSONB ->> ''value'' AS value
        , rst_cond_info_json.value::JSONB ->> ''value_name_1'' AS value_name_1
        , rst_cond_info_json.value::JSONB ->> ''unit'' AS unit
        , '''' AS valuecd2
        , rst_cond_info_json.value::JSONB ->> ''medicine_type'' AS medicine_type
    FROM
        ntss_db5_om_temp
        CROSS JOIN lateral jsonb_each_text(ntss_db5_om_temp.rst_cond_info::JSONB) rst_cond_info_json
    WHERE
        rst_cond_info_json.key IN(''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'',''12'',''14'',''15'',''16'',''17'',''18'',''19'',''20'',''21'',''22'',''23'',''24'',''25'',''26'',''27'',''28'',''29'',''30'',''31'',''32'',''33'',''34'',''35'',''36'',''37'',''38'')
    UNION ALL
    SELECT --dw
        ntss_db5_om_temp.ord_no
        , ''992'' AS key
        , CAST(ntss_db5_om_temp.rst_dw AS text) AS value
        , '''' AS value_name_1
        , ''kg'' AS unit
        , '''' AS valuecd2
        , '''' AS medicine_type
    FROM
        ntss_db5_om_temp
    UNION ALL
    SELECT --治療方法
        ntss_db5_om_temp.ord_no
        , ''993'' AS key
        , CASE
            WHEN ntss_db5_om_temp.treat_date >= ntss_db5_mst_t.in_hosp_a_startdate
            AND ntss_db5_om_temp.treat_date >= ntss_db5_mst_t.in_hosp_b_startdate
                THEN CASE
                    WHEN ntss_db5_mst_t.in_hosp_a_startdate >= ntss_db5_mst_t.in_hosp_b_startdate
                        THEN ntss_db5_mst_t.in_hospital_cd_a1
                    WHEN ntss_db5_mst_t.in_hosp_a_startdate < ntss_db5_mst_t.in_hosp_b_startdate
                        THEN ntss_db5_mst_t.in_hospital_cd_b1
                    END
            WHEN ntss_db5_om_temp.treat_date >= ntss_db5_mst_t.in_hosp_a_startdate
            AND (ntss_db5_om_temp.treat_date < ntss_db5_mst_t.in_hosp_b_startdate
                OR ntss_db5_mst_t.in_hosp_b_startdate IS NULL)
                THEN ntss_db5_mst_t.in_hospital_cd_a1
            WHEN (ntss_db5_om_temp.treat_date < ntss_db5_mst_t.in_hosp_a_startdate
                OR ntss_db5_mst_t.in_hosp_a_startdate IS NULL)
            AND ntss_db5_om_temp.treat_date >= ntss_db5_mst_t.in_hosp_b_startdate
                THEN ntss_db5_mst_t.in_hospital_cd_b1
            ELSE NULL
            END AS value
        , ntss_db5_mst_t.treatment_name AS value_name_1
        , '''' AS unit
        , CASE
            WHEN ntss_db5_om_temp.treat_date >= ntss_db5_mst_t.in_hosp_a_startdate
            AND ntss_db5_om_temp.treat_date >= ntss_db5_mst_t.in_hosp_b_startdate
                THEN CASE
                    WHEN ntss_db5_mst_t.in_hosp_a_startdate >= ntss_db5_mst_t.in_hosp_b_startdate
                        THEN ntss_db5_mst_t.in_hospital_cd_a2
                    WHEN ntss_db5_mst_t.in_hosp_a_startdate < ntss_db5_mst_t.in_hosp_b_startdate
                        THEN ntss_db5_mst_t.in_hospital_cd_b2
                    END
            WHEN ntss_db5_om_temp.treat_date >= ntss_db5_mst_t.in_hosp_a_startdate
            AND (ntss_db5_om_temp.treat_date < ntss_db5_mst_t.in_hosp_b_startdate
                OR ntss_db5_mst_t.in_hosp_b_startdate IS NULL)
                THEN ntss_db5_mst_t.in_hospital_cd_a2
            WHEN (ntss_db5_om_temp.treat_date < ntss_db5_mst_t.in_hosp_a_startdate
                OR ntss_db5_mst_t.in_hosp_a_startdate IS NULL)
            AND ntss_db5_om_temp.treat_date >= ntss_db5_mst_t.in_hosp_b_startdate
                THEN ntss_db5_mst_t.in_hospital_cd_b2
            ELSE NULL
            END AS valuecd2
        , '''' AS medicine_type
    FROM
        ntss_db5_om_temp
        LEFT JOIN ntss_db5_mst_t
        ON ntss_db5_om_temp.rst_treatment_cd = ntss_db5_mst_t.treatment_cd
)
, ntss_db5_mst_v AS (
    SELECT
        ntss_db5_mst_v.va_cd
        , ntss_db5_mst_v.in_hospital_cd_1
        , ntss_db5_mst_v.in_hospital_cd_2
    FROM
        mst_va ntss_db5_mst_v
    WHERE
        ntss_db5_mst_v.facility_cd = @facilityCd
        AND ntss_db5_mst_v.is_del = ''0''
        AND ntss_db5_mst_v.is_disp = ''1''
)
, ntss_db5_mst_d AS (
    SELECT
        ntss_db5_mst_d.dialyzer_cd
        , ntss_db5_mst_d.in_hospital_cd_1
        , ntss_db5_mst_d.in_hospital_cd_2
    FROM
        mst_dialyzer ntss_db5_mst_d
    WHERE
        ntss_db5_mst_d.facility_cd = @facilityCd
        AND ntss_db5_mst_d.is_del = ''0''
        AND ntss_db5_mst_d.is_disp = ''1''
)
, ntss_db5_mst_e AS (
    SELECT
        ntss_db5_mst_e.equipment_cd
        , ntss_db5_mst_e.in_hospital_cd_1
        , ntss_db5_mst_e.in_hospital_cd_2
    FROM
        mst_equipment ntss_db5_mst_e
    WHERE
        ntss_db5_mst_e.facility_cd = @facilityCd
        AND ntss_db5_mst_e.is_del = ''0''
        AND ntss_db5_mst_e.is_disp = ''1''
)
, ntss_db5_mst_m AS (
    SELECT
        ntss_db5_mst_m.medicine_cd
        , ntss_db5_mst_m.in_hospital_cd_1
        , ntss_db5_mst_m.in_hospital_cd_2
    FROM
        mst_medicine ntss_db5_mst_m
    WHERE
        ntss_db5_mst_m.facility_cd = @facilityCd
        AND ntss_db5_mst_m.is_del = ''0''
        AND ntss_db5_mst_m.is_disp = ''1''
)
, ntss_db5_mst_m_mix AS (
    SELECT
        ntss_db5_mst_m_mix.medicine_mix_cd
        , ntss_db5_mst_m_mix.in_hospital_cd_1
        , ntss_db5_mst_m_mix.in_hospital_cd_2
    FROM
        mst_medicine_mix ntss_db5_mst_m_mix
    WHERE
        ntss_db5_mst_m_mix.facility_cd = @facilityCd
        AND ntss_db5_mst_m_mix.is_del = ''0''
        AND ntss_db5_mst_m_mix.is_disp = ''1''
)
SELECT
    '''' AS hosppatid                             --患者ID
    , ntss_db5_om_temp.pat_id AS patid
    , ntss_db5_om_temp.dialysisdate AS dialysisdate    --透析日
    , ntss_db5_om_1.ord_no AS dialysisno            --透析番号
    , CASE
        WHEN rst_cond_list.key = ''1'' THEN ''002''
        WHEN rst_cond_list.key = ''2'' THEN ''003''
        WHEN rst_cond_list.key = ''992'' THEN ''004''
        WHEN rst_cond_list.key = ''3'' THEN ''005''
        WHEN rst_cond_list.key = ''993'' THEN ''006''
        WHEN rst_cond_list.key = ''4'' THEN ''007''
        WHEN rst_cond_list.key = ''5'' THEN ''008''
        WHEN rst_cond_list.key = ''6'' THEN ''009''
        WHEN rst_cond_list.key = ''14'' THEN ''010''
        WHEN rst_cond_list.key = ''25'' THEN ''011''
        WHEN rst_cond_list.key = ''26'' THEN ''012''
        WHEN rst_cond_list.key = ''27'' THEN ''013''
        WHEN rst_cond_list.key = ''28'' THEN ''014''
        WHEN rst_cond_list.key = ''29'' THEN ''015''
        WHEN rst_cond_list.key = ''31'' THEN ''016''
        WHEN rst_cond_list.key = ''32'' THEN ''017''
        WHEN rst_cond_list.key = ''15'' THEN ''018''
        WHEN rst_cond_list.key = ''16'' THEN ''019''
        WHEN rst_cond_list.key = ''17'' THEN ''020''
        WHEN rst_cond_list.key = ''18'' THEN ''021''
        WHEN rst_cond_list.key = ''19'' THEN ''022''
        WHEN rst_cond_list.key = ''20'' THEN ''023''
        WHEN rst_cond_list.key = ''21'' THEN ''024''
        WHEN rst_cond_list.key = ''23'' THEN ''025''
        WHEN rst_cond_list.key = ''12'' THEN ''029''
        WHEN rst_cond_list.key = ''22'' THEN ''030''
        WHEN rst_cond_list.key = ''30'' THEN ''031''
        WHEN rst_cond_list.key = ''34'' THEN ''032''
        WHEN rst_cond_list.key = ''35'' THEN ''033''
        WHEN rst_cond_list.key = ''36'' THEN ''034''
        WHEN rst_cond_list.key = ''37'' THEN ''035''
        WHEN rst_cond_list.key = ''38'' THEN ''036''
        WHEN rst_cond_list.key = ''33'' THEN ''037''
        WHEN rst_cond_list.key = ''24'' THEN ''038''
        WHEN rst_cond_list.key = ''7'' THEN ''039''
        WHEN rst_cond_list.key = ''8'' THEN ''040''
        ELSE NULL
        END AS ctlno       --透析条件項目コード
    , to_char(ntss_db5_om_temp.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    , CASE
        WHEN rst_cond_list.key = ''1'' THEN ''透析時間''
        WHEN rst_cond_list.key = ''2'' THEN ''VA''
        WHEN rst_cond_list.key = ''992'' THEN ''DW''
        WHEN rst_cond_list.key = ''3'' THEN ''目標体重''
        WHEN rst_cond_list.key = ''993'' THEN ''治療方法''
        WHEN rst_cond_list.key = ''4'' THEN ''除水量制限''
        WHEN rst_cond_list.key = ''5'' THEN ''ダイアライザ''
        WHEN rst_cond_list.key = ''6'' THEN ''吸着カラム''
        WHEN rst_cond_list.key = ''14'' THEN ''血流量''
        WHEN rst_cond_list.key = ''25'' THEN ''抗凝固剤''
        WHEN rst_cond_list.key = ''26'' THEN ''抗凝固剤ワンショット量''
        WHEN rst_cond_list.key = ''27'' THEN ''抗凝固剤持続速度''
        WHEN rst_cond_list.key = ''28'' THEN ''抗凝固剤持続総量''
        WHEN rst_cond_list.key = ''29'' THEN ''IP使用選択''
        WHEN rst_cond_list.key = ''31'' THEN ''IPワンショット量''
        WHEN rst_cond_list.key = ''32'' THEN ''IP速度''
        WHEN rst_cond_list.key = ''15'' THEN ''透析液''
        WHEN rst_cond_list.key = ''16'' THEN ''透析液流量''
        WHEN rst_cond_list.key = ''17'' THEN ''透析液量''
        WHEN rst_cond_list.key = ''18'' THEN ''透析液温度''
        WHEN rst_cond_list.key = ''19'' THEN ''補液''
        WHEN rst_cond_list.key = ''20'' THEN ''補液量''
        WHEN rst_cond_list.key = ''21'' THEN ''補液選択''
        WHEN rst_cond_list.key = ''23'' THEN ''補液温度''
        WHEN rst_cond_list.key = ''12'' THEN ''シングルニードル使用''
        WHEN rst_cond_list.key = ''22'' THEN ''補液使用数''
        WHEN rst_cond_list.key = ''30'' THEN ''IPスタート''
        WHEN rst_cond_list.key = ''34'' THEN ''自動ワンショット''
        WHEN rst_cond_list.key = ''35'' THEN ''IP電源自動切り''
        WHEN rst_cond_list.key = ''36'' THEN ''IP電源自動切り時間''
        WHEN rst_cond_list.key = ''37'' THEN ''IP電源OKモニタ切り''
        WHEN rst_cond_list.key = ''38'' THEN ''IP電源OKモニタ切り時間''
        WHEN rst_cond_list.key = ''33'' THEN ''IP速度最大値''
        WHEN rst_cond_list.key = ''24'' THEN ''補液速度''
        WHEN rst_cond_list.key = ''7'' THEN ''1次膜''
        WHEN rst_cond_list.key = ''8'' THEN ''2次膜''
        ELSE NULL
        END AS dialysisitemname --透析条件項目名
    , CASE
        WHEN rst_cond_list.key = ''2'' THEN ntss_db5_mst_v.in_hospital_cd_1
        WHEN rst_cond_list.key = ''992'' THEN to_char(rst_cond_list.value::numeric, ''FM990.00'')
        WHEN rst_cond_list.key = ''3'' THEN to_char(rst_cond_list.value::numeric, ''FM990.00'')
        WHEN rst_cond_list.key = ''4'' THEN to_char(rst_cond_list.value::numeric, ''FM90.00'')
        WHEN rst_cond_list.key = ''5'' THEN ntss_db5_mst_d.in_hospital_cd_1
        WHEN rst_cond_list.key = ''6''
        OR rst_cond_list.key = ''7''
        OR rst_cond_list.key = ''8''
            THEN ntss_db5_mst_e.in_hospital_cd_1
        WHEN rst_cond_list.key = ''25''
        OR rst_cond_list.key = ''15''
        OR rst_cond_list.key = ''19''
            THEN CASE
                WHEN rst_cond_list.medicine_type = ''1'' THEN ntss_db5_mst_m.in_hospital_cd_1
                WHEN rst_cond_list.medicine_type = ''2'' THEN ntss_db5_mst_m_mix.in_hospital_cd_1
                ELSE NULL
                END
        WHEN rst_cond_list.key = ''26'' THEN to_char(rst_cond_list.value::numeric, ''FM99990.00'')
        WHEN rst_cond_list.key = ''27'' THEN to_char(rst_cond_list.value::numeric, ''FM99990.00'')
        WHEN rst_cond_list.key = ''28'' THEN to_char(rst_cond_list.value::numeric, ''FM99990.00'')
        WHEN rst_cond_list.key = ''31'' THEN to_char(rst_cond_list.value::numeric, ''FM90.0'')
        WHEN rst_cond_list.key = ''32'' THEN to_char(rst_cond_list.value::numeric, ''FM90.0'')
        WHEN rst_cond_list.key = ''17'' THEN to_char(rst_cond_list.value::numeric, ''FM99990.00'')
        WHEN rst_cond_list.key = ''18'' THEN to_char(rst_cond_list.value::numeric, ''FM90.0'')
        WHEN rst_cond_list.key = ''20'' THEN to_char(rst_cond_list.value::numeric, ''FM990.0'')
        WHEN rst_cond_list.key = ''23'' THEN to_char(rst_cond_list.value::numeric, ''FM90.0'')
        WHEN rst_cond_list.key = ''33'' THEN to_char(rst_cond_list.value::numeric, ''FM90.0'')
        WHEN rst_cond_list.key = ''24'' THEN to_char(rst_cond_list.value::numeric, ''FM990.00'')
        ELSE rst_cond_list.value
        END AS value          --設定値
    , CASE
        WHEN rst_cond_list.key = ''29''
        OR rst_cond_list.key = ''12''
        OR rst_cond_list.key = ''34''
            THEN CASE
                WHEN rst_cond_list.value = ''1'' THEN ''使用する''
                WHEN rst_cond_list.value = ''0'' THEN ''使用しない''
                ELSE NULL
                END
        WHEN rst_cond_list.key = ''21''
            THEN CASE
                WHEN rst_cond_list.value = ''1'' THEN ''前補液''
                WHEN rst_cond_list.value = ''0'' THEN ''後補液''
                ELSE NULL
                END
        WHEN rst_cond_list.key = ''30''
            THEN CASE
                WHEN rst_cond_list.value = ''1'' THEN ''自動''
                WHEN rst_cond_list.value = ''0'' THEN ''手動''
                ELSE NULL
                END
        WHEN rst_cond_list.key = ''35''
        OR rst_cond_list.key = ''37''
            THEN CASE
                WHEN rst_cond_list.value = ''1'' THEN ''入り''
                WHEN rst_cond_list.value = ''0'' THEN ''切り''
                ELSE NULL
                END
        ELSE rst_cond_list.value_name_1
        END AS valuename --名称
    , '''' AS medgeneralname --薬剤一般名称
    , CASE
        WHEN rst_cond_list.key = ''1'' THEN ''分''
        WHEN rst_cond_list.key = ''3'' THEN ''kg''
        WHEN rst_cond_list.key = ''4'' THEN ''L''
        WHEN rst_cond_list.key = ''14'' THEN ''mL/min''
        WHEN rst_cond_list.key = ''31'' THEN ''mL''
        WHEN rst_cond_list.key = ''32'' THEN ''mL/h''
        WHEN rst_cond_list.key = ''16'' THEN ''mL/min''
        WHEN rst_cond_list.key = ''18'' THEN ''℃''
        WHEN rst_cond_list.key = ''20'' THEN ''L''
        WHEN rst_cond_list.key = ''23'' THEN ''℃''
        WHEN rst_cond_list.key = ''36'' THEN ''分''
        WHEN rst_cond_list.key = ''38'' THEN ''分''
        WHEN rst_cond_list.key = ''33'' THEN ''mL/h''
        WHEN rst_cond_list.key = ''24'' THEN ''L/h''
        ELSE rst_cond_list.unit
        END AS unit            --単位
    , CASE
        WHEN rst_cond_list.key = ''2'' THEN ntss_db5_mst_v.in_hospital_cd_2
        WHEN rst_cond_list.key = ''993'' THEN rst_cond_list.valuecd2
        WHEN rst_cond_list.key = ''5'' THEN ntss_db5_mst_d.in_hospital_cd_2
        WHEN rst_cond_list.key = ''6''
        OR rst_cond_list.key = ''7''
        OR rst_cond_list.key = ''8''
            THEN ntss_db5_mst_e.in_hospital_cd_2
        WHEN rst_cond_list.key = ''25''
        OR rst_cond_list.key = ''15''
        OR rst_cond_list.key = ''19''
            THEN CASE
                WHEN rst_cond_list.medicine_type = ''1'' THEN ntss_db5_mst_m.in_hospital_cd_2
                WHEN rst_cond_list.medicine_type = ''2'' THEN ntss_db5_mst_m_mix.in_hospital_cd_2
                ELSE NULL
                END
        ELSE NULL
        END AS valuecd1 --院内コード2
FROM
    ntss_db5_om_temp
    LEFT JOIN ntss_db5_om_1
        ON ntss_db5_om_temp.ord_no = ntss_db5_om_1.ord_no
    LEFT JOIN rst_cond_list
        ON ntss_db5_om_temp.ord_no = rst_cond_list.ord_no
    LEFT JOIN ntss_db5_mst_v
        ON rst_cond_list.value = ntss_db5_mst_v.va_cd ::text
    LEFT JOIN ntss_db5_mst_d
        ON rst_cond_list.value = ntss_db5_mst_d.dialyzer_cd ::text
    LEFT JOIN ntss_db5_mst_e
        ON rst_cond_list.value = ntss_db5_mst_e.equipment_cd ::text
    LEFT JOIN ntss_db5_mst_m
        ON rst_cond_list.value = ntss_db5_mst_m.medicine_cd ::text
    LEFT JOIN ntss_db5_mst_m_mix
        ON rst_cond_list.value = ntss_db5_mst_m_mix.medicine_mix_cd ::text;
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2120, '
with union_tmp as 
(
    SELECT
     ntss_db5_om.pat_id AS patid
    , ntss_db5_om.treat_date AS dialysisdate    --透析日
    , ntss_db5_om.ord_no AS dialysisno          --透析番号
    , to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    , ntss_db5_mst_e.in_hospital_cd_1 AS equipcd --医療材料コード(院内コード1)
    , ntss_db5_mst_e.in_hospital_cd_2 AS equipcd2 --医療材料コード(院内コード2)
    , ntss_db5_om_rqi_json ->> ''name'' AS equipname --医療材料名
    , ntss_db5_om_rqi_json ->> ''class_name'' AS equipclassname --医療材料分類名
    , CASE ntss_db5_om_rqi_json ->> ''needle_type''
        WHEN ''1'' THEN ntss_db5_om_rqi_json ->> ''needle_type''
        WHEN ''2'' THEN ntss_db5_om_rqi_json ->> ''needle_type''
        WHEN ''3'' THEN ntss_db5_om_rqi_json ->> ''needle_type''
        ELSE ''0''
      END AS punctureclass --穿刺針区分
    , ntss_db5_om_rqi_json ->> ''amount'' AS amount --数量
    , ntss_db5_mst_e.unit AS unit               --単位
    , ntss_db5_om_rqi_json ->> ''cd'' AS cd--コード用
    , ntss_db5_om.facility_cd  AS facilitycd
FROM
    ord_main ntss_db5_om
    CROSS JOIN LATERAL json_array_elements(ntss_db5_om.rst_equip_info ::json) ntss_db5_om_rqi_json
    LEFT JOIN mst_equipment ntss_db5_mst_e
        ON (ntss_db5_mst_e.equipment_cd)::text = ntss_db5_om_rqi_json ->> ''cd''
        AND ntss_db5_mst_e.is_del = ''0''
        AND ntss_db5_mst_e.is_disp = ''1''
WHERE
    ntss_db5_om.is_del = ''0''
    AND ntss_db5_om.facility_cd = @facilityCd
    AND ntss_db5_om.pat_id IS NOT NULL
    AND ntss_db5_om.treat_date IS NOT NULL
    AND @fromDate <= ntss_db5_om.treat_date AND ntss_db5_om.treat_date < @toDate
UNION ALL
    SELECT
         ntss_db5_om.pat_id AS patid
        , ntss_db5_om.treat_date AS dialysisdate --透析日
        , ntss_db5_om.ord_no AS dialysisno --透析番号
        , to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
        , ntss_db5_mst_e.in_hospital_cd_1 AS equipcd --医療材料コード(院内コード1)
        , ntss_db5_mst_e.in_hospital_cd_2 AS equipcd2 --医療材料コード(院内コード2)
        , rst_cond_info_json.value::JSON ->> ''value_name_1'' AS equipname --医療材料名
        , ntss_db5_mst_c.class_name AS equipclassname --医療材料分類名
        , CASE rst_cond_info_json.key
            WHEN ''9'' THEN ''1''
            WHEN ''10'' THEN ''2''
            WHEN ''11'' THEN ''3''
            ELSE ''0''
          END AS punctureclass --穿刺針区分
        , ''1'' AS amount --数量
        , rst_cond_info_json.value::JSON ->> ''unit'' AS unit               --単位
        , rst_cond_info_json.value::JSON ->> ''value'' AS cd--コード用
        , ntss_db5_om.facility_cd  AS facilitycd
    FROM
        ord_main ntss_db5_om
        CROSS JOIN lateral json_each_text(ntss_db5_om.rst_cond_info::JSON) rst_cond_info_json
        INNER JOIN mst_equipment ntss_db5_mst_e
            ON (ntss_db5_mst_e.equipment_cd)::text = rst_cond_info_json.value::JSON ->> ''value''
            AND ntss_db5_mst_e.is_del = ''0''
            AND ntss_db5_mst_e.is_disp = ''1''
        LEFT JOIN mst_equipment_class ntss_db5_mst_c
            ON ntss_db5_mst_c.class_cd = ntss_db5_mst_e.class_cd
            AND ntss_db5_mst_c.is_del = ''0''
            AND ntss_db5_mst_c.is_disp = ''1''
    WHERE
        rst_cond_info_json.key IN(''6'',''7'',''8'',''9'',''10'',''11'',''13'')
        AND ntss_db5_om.is_del = ''0''
        AND rst_cond_info_json.value::JSON ->> ''value'' is not null
        AND ntss_db5_om.facility_cd = @facilityCd
        AND ntss_db5_om.pat_id IS NOT NULL
        AND ntss_db5_om.treat_date IS NOT NULL
        AND @fromDate <= ntss_db5_om.treat_date AND ntss_db5_om.treat_date < @toDate
)SELECT
    '''' AS hosppatid                             --患者ID
    ,union_tmp.patid
    , union_tmp.dialysisdate
    , union_tmp.dialysisno
    , (row_number() over (PARTITION BY union_tmp.dialysisno ORDER BY ntss_db5_mst_sel.sortkey ASC, (union_tmp.cd)::integer))::text AS ctlno --項目番号
    , union_tmp.update
    , union_tmp.equipcd
    , union_tmp.equipcd2
    , union_tmp.equipname
    , union_tmp.equipclassname
    , union_tmp.punctureclass
    , union_tmp.amount
    , union_tmp.unit
    , '''' as comments
    from
        union_tmp
        INNER JOIN mst_equipment ntss_db5_mst_e
            ON (ntss_db5_mst_e.equipment_cd)::text = union_tmp.cd
            AND ntss_db5_mst_e.is_del = ''0''
            AND ntss_db5_mst_e.is_disp = ''1''
        LEFT JOIN (
            SELECT
              facility_cd
              , ntss_db5_mst_sel_json
              , ROW_NUMBER() OVER() AS sortkey
            FROM
                mst_selector ms
            CROSS JOIN LATERAL json_array_elements(ms.order_settings ::json -> ''items'') ntss_db5_mst_sel_json
            WHERE ms.master_physical_name = ''mst_equipment'') AS ntss_db5_mst_sel
            ON (ntss_db5_mst_e.equipment_cd)::text = ntss_db5_mst_sel.ntss_db5_mst_sel_json ->> ''code''
            AND union_tmp.facilitycd = ntss_db5_mst_sel.facility_cd
            AND ntss_db5_mst_sel.ntss_db5_mst_sel_json ->> ''isDel'' = ''0''
            AND ntss_db5_mst_sel.ntss_db5_mst_sel_json ->> ''isDisp'' = ''1'';
            ', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2130, 'WITH ntss_db5_om_temp AS (
    SELECT
        ntss_db5_om.ord_no
        ,ntss_db5_om.pat_id
        ,ntss_db5_om.up_date
        , CAST(ntss_db5_om.treat_date as DATE) as treat_date
        , ROW_NUMBER() OVER (PARTITION BY ntss_db5_om.ord_no ORDER BY CAST(ntss_db5_om_rmi_json ->> ''no'' AS int) ASC) AS ctlno
        , ntss_db5_om_rmi_json ->> ''cd'' AS cd
        , ntss_db5_om_rmi_json ->> ''medicine_type'' AS medicine_type
        , ntss_db5_om_rmi_json ->> ''name'' AS medicinename --薬剤名
        , ntss_db5_om_rmi_json ->> ''class_name'' AS mediclassname --薬剤分類名
        , ntss_db5_om_rmi_json ->> ''amount'' AS amount --数量
        , ntss_db5_om_rmi_json ->> ''unit'' AS unit --単位
        , ntss_db5_om_rmi_json ->> ''effect_flg'' AS effectflg --実施フラグ
        , CASE
            WHEN POSITION(
                ''T'' IN cast(
                    ntss_db5_om_rmi_json ->> ''effect_date'' AS char (20)
                )
            ) != 0
                THEN to_char(
                to_timestamp(
                    ntss_db5_om_rmi_json ->> ''effect_date''
                    , ''YYYY-MM-DDThh24:mi:ss''
                )
                , ''YYYY-MM-DD hh24:mi:ss''
                )
            ELSE ''''
            END AS effectdate                   --実施日時
        , ntss_db5_om_rmi_json ->> ''timing_name'' AS timingname --投与時間帯名
        , ntss_db5_om_rmi_json ->> ''procedure_cd'' AS procedure_cd
        , ntss_db5_om_rmi_json ->> ''procedure_name'' AS procedurename --手技名
        , ntss_db5_om_rmi_json ->> ''effect_user_id'' AS userid
        , CONCAT((ntss_db5_om_rmi_json ->> ''effect_user_last_name'')::text, ''　'', (ntss_db5_om_rmi_json ->> ''effect_user_first_name'')::text) AS staffname --実施者名
        , ntss_db5_om_rmi_json ->> ''comment'' AS comments --コメント
    FROM
        ord_main ntss_db5_om
        CROSS JOIN LATERAL jsonb_array_elements(ntss_db5_om.rst_medi_info ::jsonb) ntss_db5_om_rmi_json
    WHERE
        ntss_db5_om.facility_cd = @facilityCd
        AND ntss_db5_om.is_del = ''0''
        AND ntss_db5_om.pat_id IS NOT NULL
        AND @fromDate <= ntss_db5_om.treat_date AND ntss_db5_om.treat_date < @toDate
),
ntss_db5_mst_m AS (
    SELECT
        medicine_cd
        , in_hospital_cd_1 AS medicinecd1
        , in_hospital_cd_2 AS medicinecd2
        , up_date
    FROM
        mst_medicine
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND is_disp = ''1''
),
ntss_db5_mst_m_mix AS (
    SELECT
        medicine_mix_cd
        , in_hospital_cd_1 AS medicinecd1
        , in_hospital_cd_2 AS medicinecd2
        , up_date
    FROM
        mst_medicine_mix
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND is_disp = ''1''
),
ntss_db5_mst_p AS (
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
        AND is_del = ''0''
        AND is_disp = ''1''
)
SELECT
    '''' AS hosppatid                             --患者ID
    , ntss_db5_om_temp.pat_id AS patid
    , to_char(ntss_db5_om_temp.treat_date,''YYYYMMDD'') AS dialysisdate    --透析日
    , ntss_db5_om_temp.ord_no AS dialysisno          --透析番号
    , ntss_db5_om_temp.ctlno AS ctlno --項目番号
    , to_char(ntss_db5_om_temp.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    , CASE
        WHEN ntss_db5_om_temp.medicine_type = ''1''
            THEN ntss_db5_mst_m.medicinecd1
        WHEN ntss_db5_om_temp.medicine_type = ''2''
            THEN ntss_db5_mst_m_mix.medicinecd1
        ELSE NULL
        END AS medicinecd --薬剤コード(院内コード1)
    , CASE
        WHEN ntss_db5_om_temp.medicine_type = ''1''
            THEN ntss_db5_mst_m.medicinecd2
        WHEN ntss_db5_om_temp.medicine_type = ''2''
            THEN ntss_db5_mst_m_mix.medicinecd2
        ELSE NULL
        END AS medicinecd2 --薬剤コード(院内コード2)
    , ntss_db5_om_temp.medicinename AS medicinename --薬剤名
    , ntss_db5_om_temp.mediclassname AS mediclassname --薬剤分類名
    , ntss_db5_om_temp.amount AS amount         --数量
    , ntss_db5_om_temp.unit AS unit             --単位
    , ntss_db5_om_temp.effectflg AS effectflg   --実施フラグ
    , ntss_db5_om_temp.effectdate AS effectdate --実施日時
    , ntss_db5_om_temp.timingname AS timingname --投与時間帯名
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
    , ntss_db5_om_temp.procedurename AS procedurename --手技名
    , '''' AS staffcd                         --実施者コード
    , ntss_db5_om_temp.userid AS userid
    , ntss_db5_om_temp.staffname AS staffname   --実施者名
    , ntss_db5_om_temp.comments AS comments     --コメント
FROM
    ntss_db5_om_temp
    LEFT JOIN ntss_db5_mst_m
        ON ntss_db5_mst_m.medicine_cd ::text = ntss_db5_om_temp.cd
    LEFT JOIN ntss_db5_mst_m_mix
        ON ntss_db5_mst_m_mix.medicine_mix_cd ::text = ntss_db5_om_temp.cd
    LEFT JOIN ntss_db5_mst_p
        ON ntss_db5_mst_p.procedure_cd ::text = ntss_db5_om_temp.procedure_cd
    ;
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2140, 'WITH ntss_db5_om_temp AS (
  SELECT
    ntss_db5_om.ord_no,
    ntss_db5_om.pat_id,
    CAST(ntss_db5_om.treat_date as DATE) as treat_date,
    ROW_NUMBER() OVER (
      PARTITION BY ntss_db5_om.ord_no
      ORDER BY
        CAST(ntss_db5_om_rmi_json ->> ''no'' AS int) ASC
    ) AS ctlno,
    ntss_db5_om.up_date,
    ntss_db5_om_rmi_json ->> ''cd'' AS cd,
    ntss_db5_om_rmi_json ->> ''medicine_type'' AS medicine_type,
    ntss_db5_om_rmi_json ->> ''name'' AS medicinename,
    --薬剤名
    ntss_db5_om_rmi_json ->> ''class_name'' AS mediclassname,
    --薬剤分類名
    ntss_db5_om_rmi_json ->> ''amount'' AS amount,
    --数量
    ntss_db5_om_rmi_json ->> ''unit'' AS unit,
    --単位
    ntss_db5_om_rmi_json ->> ''effect_flg'' AS effectflg,
    --実施フラグ
    CASE
      WHEN POSITION(
        ''T'' IN
          ntss_db5_om_rmi_json ->> ''effect_date''
      ) != 0 THEN to_char(
        to_timestamp(
          ntss_db5_om_rmi_json ->> ''effect_date'',
          ''YYYY-MM-DDThh24:mi:ss''
        ),
        ''YYYY-MM-DD hh24:mi:ss''
      )
      ELSE ''''
    END AS effectdate,
    --実施日時
    ntss_db5_om_rmi_json ->> ''timing_name'' AS timingname,
    --投与時間帯名
    ntss_db5_om_rmi_json ->> ''procedure_cd'' AS procedure_cd,
    ntss_db5_om_rmi_json ->> ''procedure_name'' AS procedurename,
    --手技名
    ntss_db5_om_rmi_json ->> ''effect_user_id'' AS userid,
    CONCAT(
      CAST(
        ntss_db5_om_rmi_json ->> ''effect_user_last_name'' AS text
      )
      , ''　''
      , CAST(
        ntss_db5_om_rmi_json ->> ''effect_user_first_name'' AS text
      )
    ) AS staffname,
    --実施者名
    ntss_db5_om_rmi_json ->> ''comment'' AS comments --コメント
  FROM
    ord_main ntss_db5_om
    CROSS JOIN LATERAL jsonb_array_elements(ntss_db5_om.rst_medi_info :: jsonb) ntss_db5_om_rmi_json
  WHERE
    ntss_db5_om.facility_cd = @facilityCd
    AND ntss_db5_om.is_del = ''0''
    AND ntss_db5_om.pat_id IS NOT NULL
    AND @fromDate <= ntss_db5_om.treat_date AND ntss_db5_om.treat_date < @toDate
),
ntss_db5_mst_m AS (
  SELECT
    medicine_cd,
    in_hospital_cd_1 AS medicinecd1,
    in_hospital_cd_2 AS medicinecd2,
    up_date
  FROM
    mst_medicine
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    AND is_disp = ''1''
),
ntss_db5_mst_m_mix AS (
  SELECT
    medicine_mix_cd,
    in_hospital_cd_1 AS medicinecd1,
    in_hospital_cd_2 AS medicinecd2,
    up_date
  FROM
    mst_medicine_mix
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    AND is_disp = ''1''
),
ntss_db5_mst_p AS (
  SELECT
    procedure_cd,
    CAST(in_hosp_a_startdate AS date) AS in_hosp_a_startdate,
    in_hospital_cd_a1,
    in_hospital_cd_a2,
    CAST(in_hosp_b_startdate AS date) AS in_hosp_b_startdate,
    in_hospital_cd_b1,
    in_hospital_cd_b2,
    up_date
  FROM
    mst_procedure
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    AND is_disp = ''1''
)
SELECT
  '''' AS hosppatid,
  --患者ID
  ntss_db5_om_temp.pat_id AS patid,
  to_char(ntss_db5_om_temp.treat_date,''YYYYMMDD'') AS dialysisdate,
  --透析日
  ntss_db5_om_temp.ord_no AS dialysisno,
  --透析番号
  ntss_db5_om_temp.ctlno AS ctlno,
  --項目番号
  to_char(
    ntss_db5_om_temp.up_date,
    ''YYYY-MM-DD hh24:mi:ss''
  ) AS update,
  --更新日時
  CASE
    WHEN ntss_db5_om_temp.medicine_type = ''1'' THEN ntss_db5_mst_m.medicinecd1
    WHEN ntss_db5_om_temp.medicine_type = ''2'' THEN ntss_db5_mst_m_mix.medicinecd1
    ELSE NULL
  END AS medicinecd,
  --薬剤コード(院内コード1)
  CASE
    WHEN ntss_db5_om_temp.medicine_type = ''1'' THEN ntss_db5_mst_m.medicinecd2
    WHEN ntss_db5_om_temp.medicine_type = ''2'' THEN ntss_db5_mst_m_mix.medicinecd2
    ELSE NULL
  END AS medicinecd2,
  --薬剤コード(院内コード2)
  ntss_db5_om_temp.medicinename AS medicinename,
  --薬剤名
  CASE
    WHEN ntss_db5_om_temp.medicine_type = ''2'' THEN ntss_db5_om_temp.medicinename
    ELSE NULL
    END AS medgeneralname,
  --一般名
  ntss_db5_om_temp.mediclassname AS mediclassname,
  --薬剤分類名
  ntss_db5_om_temp.amount AS amount,
  --数量
  ntss_db5_om_temp.unit AS unit,
  --単位
  ntss_db5_om_temp.effectflg AS effectflg,
  --実施フラグ
  ntss_db5_om_temp.effectdate AS effectdate,
  --実施日時
  ntss_db5_om_temp.timingname AS timingname,
  --投与時間帯名
  CASE
    WHEN ntss_db5_om_temp.treat_date >= ntss_db5_mst_p.in_hosp_a_startdate
    AND ntss_db5_om_temp.treat_date >= ntss_db5_mst_p.in_hosp_b_startdate THEN CASE
      WHEN ntss_db5_mst_p.in_hosp_a_startdate >= ntss_db5_mst_p.in_hosp_b_startdate THEN ntss_db5_mst_p.in_hospital_cd_a1
      WHEN ntss_db5_mst_p.in_hosp_a_startdate < ntss_db5_mst_p.in_hosp_b_startdate THEN ntss_db5_mst_p.in_hospital_cd_b1
      END
    WHEN ntss_db5_om_temp.treat_date >= ntss_db5_mst_p.in_hosp_a_startdate
    AND (
      ntss_db5_om_temp.treat_date < ntss_db5_mst_p.in_hosp_b_startdate
      OR ntss_db5_mst_p.in_hosp_b_startdate IS NULL
    ) THEN ntss_db5_mst_p.in_hospital_cd_a1
    WHEN (
      ntss_db5_om_temp.treat_date < ntss_db5_mst_p.in_hosp_a_startdate
      OR ntss_db5_mst_p.in_hosp_a_startdate IS NULL
    )
    AND ntss_db5_om_temp.treat_date >= ntss_db5_mst_p.in_hosp_b_startdate THEN ntss_db5_mst_p.in_hospital_cd_b1
    ELSE NULL
  END AS procedurecd,
  --手技コード(院内コード1)
  CASE
    WHEN ntss_db5_om_temp.treat_date >= ntss_db5_mst_p.in_hosp_a_startdate
    AND ntss_db5_om_temp.treat_date >= ntss_db5_mst_p.in_hosp_b_startdate THEN CASE
      WHEN ntss_db5_mst_p.in_hosp_a_startdate >= ntss_db5_mst_p.in_hosp_b_startdate THEN ntss_db5_mst_p.in_hospital_cd_a2
      WHEN ntss_db5_mst_p.in_hosp_a_startdate < ntss_db5_mst_p.in_hosp_b_startdate THEN ntss_db5_mst_p.in_hospital_cd_b2
      END
    WHEN ntss_db5_om_temp.treat_date >= ntss_db5_mst_p.in_hosp_a_startdate
    AND (
      ntss_db5_om_temp.treat_date < ntss_db5_mst_p.in_hosp_b_startdate
      OR ntss_db5_mst_p.in_hosp_b_startdate IS NULL
    ) THEN ntss_db5_mst_p.in_hospital_cd_a2
    WHEN (
      ntss_db5_om_temp.treat_date < ntss_db5_mst_p.in_hosp_a_startdate
      OR ntss_db5_mst_p.in_hosp_a_startdate IS NULL
    )
    AND ntss_db5_om_temp.treat_date >= ntss_db5_mst_p.in_hosp_b_startdate THEN ntss_db5_mst_p.in_hospital_cd_b2
    ELSE NULL
  END AS procedurecd2,
  --手技コード(院内コード2)
  ntss_db5_om_temp.procedurename AS procedurename,
  --手技名
  '''' AS staffcd,
  ntss_db5_om_temp.userid AS userid,
  ntss_db5_om_temp.staffname AS staffname,
  --実施者名
  ntss_db5_om_temp.comments AS comments --コメント
FROM
  ntss_db5_om_temp
  LEFT JOIN ntss_db5_mst_m ON ntss_db5_mst_m.medicine_cd ::text = ntss_db5_om_temp.cd
  LEFT JOIN ntss_db5_mst_m_mix ON ntss_db5_mst_m_mix.medicine_mix_cd ::text = ntss_db5_om_temp.cd
  LEFT JOIN ntss_db5_mst_p ON ntss_db5_mst_p.procedure_cd ::text = ntss_db5_om_temp.procedure_cd;
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2170, 'with mst_treatment_disp_order_tbl AS (
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
        AND ntss_db5_om_1.is_del = ''0''
),
ntss_db5_os AS (
    SELECT
        ntss_db5_os.ord_no
        , ntss_db5_os.is_dummy
        , ntss_db5_os.up_date
    FROM
        ord_schedule ntss_db5_os
    WHERE ntss_db5_os.facility_cd = @facilityCd
),
ntss_db5_mst_b AS (
    SELECT
        ntss_db5_mst_b.bed_cd
        , ntss_db5_mst_b.in_hospital_cd_1
        , ntss_db5_mst_b.bed_name
        , ntss_db5_mst_b.up_date
    FROM
        mst_bed ntss_db5_mst_b
    WHERE ntss_db5_mst_b.facility_cd = @facilityCd
    AND ntss_db5_mst_b.is_del = ''0''
    AND ntss_db5_mst_b.is_disp = ''1''
),
ntss_db5_mst_k AS (
    SELECT
        ntss_db5_mst_k.kur_cd
        , ntss_db5_mst_k.in_hospital_cd_1
        , ntss_db5_mst_k.kur_name
        , ntss_db5_mst_k.kur_standard_start_time
        , ntss_db5_mst_k.up_date
    FROM
        mst_kur ntss_db5_mst_k
    WHERE ntss_db5_mst_k.facility_cd = @facilityCd
    AND ntss_db5_mst_k.is_del = ''0''
),
ntss_db5_ptp AS (
    SELECT
    ntss_db5_ptp.pat_id
    , ntss_db5_ptp.treat_week
    , ntss_db5_ptp.ind_treatment_cd
    , ''1'' AS flg
    FROM pat_treatment_pattern ntss_db5_ptp
    WHERE ntss_db5_ptp.facility_cd = @facilityCd
)
SELECT
    '''' AS hosppatid                             --患者ID
    , ntss_db5_om.pat_id AS patid
    , ntss_db5_om.treat_date AS dialysisdate    --透析日
    , ntss_db5_mst_b.in_hospital_cd_1 AS bedno --ベッド番号
    , CASE
        WHEN ntss_db5_om.rst_dialysis_state = ''0''
            THEN ntss_db5_mst_b.bed_name
        ELSE ntss_db5_om.ind_bed_name
        END AS bedname                          --ベッド名
    , CASE
        WHEN ntss_db5_om.ind_kur_cd = 0 OR ntss_db5_om.ind_kur_cd IS NULL
            THEN ''未登録''
        ELSE ntss_db5_mst_k.in_hospital_cd_1
        END AS kurcd --クールコード
    , CASE
        WHEN ntss_db5_om.rst_dialysis_state = ''0''
            THEN ntss_db5_mst_k.kur_name
        ELSE ntss_db5_om.ind_kur_name
        END AS kurname                          --クール名
    , ntss_db5_om_1.plural AS plural            --同日複数回
    , to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    , ntss_db5_om.ord_no AS resultdialysisno    --実績透析番号
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
    ord_main ntss_db5_om
    LEFT JOIN ntss_db5_om_1
        ON ntss_db5_om.ord_no = ntss_db5_om_1.ord_no
    LEFT JOIN ntss_db5_os
        ON ntss_db5_os.ord_no = ntss_db5_om.ord_no
    LEFT JOIN ntss_db5_mst_b
        ON ntss_db5_mst_b.bed_cd = ntss_db5_om.ind_bed_cd
    LEFT JOIN ntss_db5_mst_k
        ON ntss_db5_mst_k.kur_cd = ntss_db5_om.ind_kur_cd
    LEFT JOIN ntss_db5_ptp
        ON ntss_db5_ptp.pat_id = ntss_db5_om.pat_id
        AND ntss_db5_ptp.treat_week = ntss_db5_om.treat_week
        AND ntss_db5_ptp.ind_treatment_cd = ntss_db5_om.ind_treatment_cd
WHERE
    ntss_db5_om.facility_cd = @facilityCd
    AND ntss_db5_om.is_del = ''0''
    AND @fromDate <= ntss_db5_om.treat_date AND ntss_db5_om.treat_date < @toDate;
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, '[{"sql_cd": -2518}]'::jsonb);
INSERT INTO sys_data_set
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
        AND one_json ->> ''isDel'' = ''0''
        AND one_json ->> ''isDisp'' = ''1''
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
        AND main.is_del = ''0'' 
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
    AND ntss_db5_mst_b.is_del = ''0''
    AND ntss_db5_mst_b.is_disp = ''1''
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
    AND ntss_db5_mst_k.is_del = ''0''
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
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2190, 'WITH ntss_db5_om_temp AS (
    SELECT
        om.ord_no
        ,om.pat_id
        ,om.treat_date AS dialysisdate
        ,CAST(om.treat_date as DATE) AS treat_date
        ,om.treat_week
        ,om.ind_cond_info
        ,om.ind_treat_start_time
        ,om.ind_schedule_user_info ->> ''ind_user_id'' AS ind_user_id
        ,om.ind_treatment_cd
        ,om.up_date
    FROM
        ord_main om
    WHERE
        om.facility_cd = @facilityCd
        AND om.is_del = ''0''
        AND @fromDate <= om.treat_date AND om.treat_date < @toDate
)
, mst_treatment_disp_order_tbl AS (
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
)
, ntss_db5_om_1 AS (
    SELECT
        ntss_db5_om_temp.ord_no
        , ROW_NUMBER() OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date ORDER BY ntss_db5_om_temp.ind_treat_start_time ASC, mst_treatment_disp_order_tbl.treatment_cd_order ASC) AS plural
    FROM
        ntss_db5_om_temp
        LEFT JOIN mst_treatment_disp_order_tbl
        ON ntss_db5_om_temp.ind_treatment_cd ::text = mst_treatment_disp_order_tbl.treatment_cd
)
, ntss_db5_pu AS (
    SELECT
        pu_temp.pat_id
        , pu_temp.up_date
        , phy_temp ->> ''dw'' AS dw
        , phy_temp ->> ''indicator_cd'' AS indicator_cd
        , ROW_NUMBER () OVER (PARTITION BY pat_id ORDER BY phy_temp ->> ''exam_date'' DESC, phy_temp ->> ''ctl_no'' DESC) AS rowno
    FROM
        pat_unique pu_temp
        CROSS JOIN lateral jsonb_array_elements(pu_temp.physical_info ::jsonb) phy_temp
    WHERE
        pu_temp.facility_cd = @facilityCd
        AND pu_temp.is_del = ''0''
        AND phy_temp ->> ''dw'' IS NOT NULL
)
, ntss_db5_mst_t AS (
    SELECT
        ntss_db5_mst_t.treatment_cd
        , ntss_db5_mst_t.treatment_name
        , CAST(ntss_db5_mst_t.in_hosp_a_startdate AS date) AS in_hosp_a_startdate
        , ntss_db5_mst_t.in_hospital_cd_a1
        , ntss_db5_mst_t.in_hospital_cd_a2
        , CAST(ntss_db5_mst_t.in_hosp_b_startdate AS date) AS in_hosp_b_startdate
        , ntss_db5_mst_t.in_hospital_cd_b1
        , ntss_db5_mst_t.in_hospital_cd_b2
    FROM
        mst_treatment ntss_db5_mst_t
    WHERE
        ntss_db5_mst_t.facility_cd = @facilityCd
        AND ntss_db5_mst_t.is_del = ''0''
        AND ntss_db5_mst_t.is_disp = ''1''
)
, ind_cond_list AS (
    SELECT --ind_cond_info
        ntss_db5_om_temp.ord_no
        , ind_cond_info_json.key AS key
        , ind_cond_info_json.value::JSONB ->> ''value'' AS value
        , ind_cond_info_json.value::JSONB ->> ''value_name_1'' AS value_name_1
        , ind_cond_info_json.value::JSONB ->> ''unit'' AS unit
        , '''' AS valuecd2
        , ind_cond_info_json.value::JSONB ->> ''medicine_type'' AS medicine_type
        , ind_cond_info_json.value::JSONB ->> ''ind_user_id'' AS ind_user_id
        , '''' AS up_date
    FROM
        ntss_db5_om_temp
        CROSS JOIN lateral jsonb_each_text(ntss_db5_om_temp.ind_cond_info::jsonb) ind_cond_info_json
    WHERE
        ind_cond_info_json.key IN(''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'',''12'',''14'',''15'',''16'',''17'',''18'',''19'',''20'',''21'',''22'',''23'',''24'',''25'',''26'',''27'',''28'',''29'',''30'',''31'',''32'',''33'',''34'',''35'',''36'',''37'',''38'')
    UNION ALL
    SELECT --治療開始時刻
        ntss_db5_om_temp.ord_no
        , ''991'' AS key
        , ntss_db5_om_temp.ind_treat_start_time AS value
        , ''透析開始時刻'' AS value_name_1
        , '''' AS unit
        , '''' AS valuecd2
        , '''' AS medicine_type
        , ntss_db5_om_temp.ind_user_id
        , '''' AS up_date
    FROM
        ntss_db5_om_temp
    UNION ALL
    SELECT --dw
        ntss_db5_om_temp.ord_no
        , ''992'' AS key
        , CAST(ntss_db5_pu.dw AS text) AS value
        , '''' AS value_name_1
        , ''kg'' AS unit
        , '''' AS valuecd2
        , '''' AS medicine_type
        , ntss_db5_pu.indicator_cd AS ind_user_id
        , to_char(ntss_db5_pu.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS up_date
    FROM
        ntss_db5_om_temp
        LEFT JOIN ntss_db5_pu
            ON ntss_db5_om_temp.pat_id = ntss_db5_pu.pat_id
            AND ntss_db5_pu.rowno = 1
    UNION ALL
    SELECT --治療方法
        ntss_db5_om_temp.ord_no
        , ''993'' AS key
        , CASE
            WHEN ntss_db5_om_temp.treat_date >= ntss_db5_mst_t.in_hosp_a_startdate
            AND ntss_db5_om_temp.treat_date >= ntss_db5_mst_t.in_hosp_b_startdate
                THEN CASE
                    WHEN ntss_db5_mst_t.in_hosp_a_startdate >= ntss_db5_mst_t.in_hosp_b_startdate
                        THEN ntss_db5_mst_t.in_hospital_cd_a1
                    WHEN ntss_db5_mst_t.in_hosp_a_startdate < ntss_db5_mst_t.in_hosp_b_startdate
                        THEN ntss_db5_mst_t.in_hospital_cd_b1
                    END
            WHEN ntss_db5_om_temp.treat_date >= ntss_db5_mst_t.in_hosp_a_startdate
            AND (ntss_db5_om_temp.treat_date < ntss_db5_mst_t.in_hosp_b_startdate
                OR ntss_db5_mst_t.in_hosp_b_startdate IS NULL)
                THEN ntss_db5_mst_t.in_hospital_cd_a1
            WHEN (ntss_db5_om_temp.treat_date < ntss_db5_mst_t.in_hosp_a_startdate
                OR ntss_db5_mst_t.in_hosp_a_startdate IS NULL)
            AND ntss_db5_om_temp.treat_date >= ntss_db5_mst_t.in_hosp_b_startdate
                THEN ntss_db5_mst_t.in_hospital_cd_b1
            ELSE NULL
            END AS value
        , ntss_db5_mst_t.treatment_name AS value_name_1
        , '''' AS unit
        , CASE
            WHEN ntss_db5_om_temp.treat_date >= ntss_db5_mst_t.in_hosp_a_startdate
            AND ntss_db5_om_temp.treat_date >= ntss_db5_mst_t.in_hosp_b_startdate
                THEN CASE
                    WHEN ntss_db5_mst_t.in_hosp_a_startdate >= ntss_db5_mst_t.in_hosp_b_startdate
                        THEN ntss_db5_mst_t.in_hospital_cd_a2
                    WHEN ntss_db5_mst_t.in_hosp_a_startdate < ntss_db5_mst_t.in_hosp_b_startdate
                        THEN ntss_db5_mst_t.in_hospital_cd_b2
                    END
            WHEN ntss_db5_om_temp.treat_date >= ntss_db5_mst_t.in_hosp_a_startdate
            AND (ntss_db5_om_temp.treat_date < ntss_db5_mst_t.in_hosp_b_startdate
                OR ntss_db5_mst_t.in_hosp_b_startdate IS NULL)
                THEN ntss_db5_mst_t.in_hospital_cd_a2
            WHEN (ntss_db5_om_temp.treat_date < ntss_db5_mst_t.in_hosp_a_startdate
                OR ntss_db5_mst_t.in_hosp_a_startdate IS NULL)
            AND ntss_db5_om_temp.treat_date >= ntss_db5_mst_t.in_hosp_b_startdate
                THEN ntss_db5_mst_t.in_hospital_cd_b2
            ELSE NULL
            END AS valuecd2
        , '''' AS medicine_type
        , ntss_db5_om_temp.ind_user_id
        , '''' AS up_date
    FROM
        ntss_db5_om_temp
        LEFT JOIN ntss_db5_mst_t
        ON ntss_db5_om_temp.ind_treatment_cd = ntss_db5_mst_t.treatment_cd
)
, ntss_db5_mst_v AS (
    SELECT
        ntss_db5_mst_v.va_cd
        , ntss_db5_mst_v.va_name
        , ntss_db5_mst_v.in_hospital_cd_1
        , ntss_db5_mst_v.in_hospital_cd_2
    FROM
        mst_va ntss_db5_mst_v
    WHERE
        ntss_db5_mst_v.facility_cd = @facilityCd
        AND ntss_db5_mst_v.is_del = ''0''
        AND ntss_db5_mst_v.is_disp = ''1''
)
, ntss_db5_mst_d AS (
    SELECT
        ntss_db5_mst_d.dialyzer_cd
        , ntss_db5_mst_d.model_number
        , ntss_db5_mst_d.in_hospital_cd_1
        , ntss_db5_mst_d.in_hospital_cd_2
    FROM
        mst_dialyzer ntss_db5_mst_d
    WHERE
        ntss_db5_mst_d.facility_cd = @facilityCd
        AND ntss_db5_mst_d.is_del = ''0''
        AND ntss_db5_mst_d.is_disp = ''1''
)
, ntss_db5_mst_e AS (
    SELECT
        ntss_db5_mst_e.equipment_cd
        , ntss_db5_mst_e.equipment_name
        , ntss_db5_mst_e.unit
        , ntss_db5_mst_e.in_hospital_cd_1
        , ntss_db5_mst_e.in_hospital_cd_2
    FROM
        mst_equipment ntss_db5_mst_e
    WHERE
        ntss_db5_mst_e.facility_cd = @facilityCd
        AND ntss_db5_mst_e.is_del = ''0''
        AND ntss_db5_mst_e.is_disp = ''1''
)
, ntss_db5_mst_m AS (
    SELECT
        ntss_db5_mst_m.medicine_cd
        , ntss_db5_mst_m.medicine_name
        , ntss_db5_mst_m.unit
        , ntss_db5_mst_m.in_hospital_cd_1
        , ntss_db5_mst_m.in_hospital_cd_2
    FROM
        mst_medicine ntss_db5_mst_m
    WHERE
        ntss_db5_mst_m.facility_cd = @facilityCd
        AND ntss_db5_mst_m.is_del = ''0''
        AND ntss_db5_mst_m.is_disp = ''1''
)
, ntss_db5_mst_m_mix AS (
    SELECT
        ntss_db5_mst_m_mix.medicine_mix_cd
        , ntss_db5_mst_m_mix.medicine_mix_name
        , ntss_db5_mst_m_mix.unit
        , ntss_db5_mst_m_mix.in_hospital_cd_1
        , ntss_db5_mst_m_mix.in_hospital_cd_2
    FROM
        mst_medicine_mix ntss_db5_mst_m_mix
    WHERE
        ntss_db5_mst_m_mix.facility_cd = @facilityCd
        AND ntss_db5_mst_m_mix.is_del = ''0''
        AND ntss_db5_mst_m_mix.is_disp = ''1''
)
, ntss_db5_ptp AS (
    SELECT
    ntss_db5_ptp.pat_id
    , ntss_db5_ptp.treat_week
    , ntss_db5_ptp.ind_treatment_cd
    , ''1'' AS flg
    FROM pat_treatment_pattern ntss_db5_ptp
    WHERE ntss_db5_ptp.facility_cd = @facilityCd
)
SELECT
    '''' AS hosppatid                             --患者ID
    , ntss_db5_om_temp.pat_id AS patid
    , ntss_db5_om_temp.dialysisdate AS dialysisdate    --透析日
    , ntss_db5_om_1.plural AS plural            --同日複数回
    , CASE
        WHEN ind_cond_list.key = ''991'' THEN ''001''
        WHEN ind_cond_list.key = ''1'' THEN ''002''
        WHEN ind_cond_list.key = ''2'' THEN ''003''
        WHEN ind_cond_list.key = ''992'' THEN ''004''
        WHEN ind_cond_list.key = ''3'' THEN ''005''
        WHEN ind_cond_list.key = ''993'' THEN ''006''
        WHEN ind_cond_list.key = ''4'' THEN ''007''
        WHEN ind_cond_list.key = ''5'' THEN ''008''
        WHEN ind_cond_list.key = ''6'' THEN ''009''
        WHEN ind_cond_list.key = ''14'' THEN ''010''
        WHEN ind_cond_list.key = ''25'' THEN ''011''
        WHEN ind_cond_list.key = ''26'' THEN ''012''
        WHEN ind_cond_list.key = ''27'' THEN ''013''
        WHEN ind_cond_list.key = ''28'' THEN ''014''
        WHEN ind_cond_list.key = ''29'' THEN ''015''
        WHEN ind_cond_list.key = ''31'' THEN ''016''
        WHEN ind_cond_list.key = ''32'' THEN ''017''
        WHEN ind_cond_list.key = ''15'' THEN ''018''
        WHEN ind_cond_list.key = ''16'' THEN ''019''
        WHEN ind_cond_list.key = ''17'' THEN ''020''
        WHEN ind_cond_list.key = ''18'' THEN ''021''
        WHEN ind_cond_list.key = ''19'' THEN ''022''
        WHEN ind_cond_list.key = ''20'' THEN ''023''
        WHEN ind_cond_list.key = ''21'' THEN ''024''
        WHEN ind_cond_list.key = ''23'' THEN ''025''
        WHEN ind_cond_list.key = ''12'' THEN ''029''
        WHEN ind_cond_list.key = ''22'' THEN ''030''
        WHEN ind_cond_list.key = ''30'' THEN ''031''
        WHEN ind_cond_list.key = ''34'' THEN ''032''
        WHEN ind_cond_list.key = ''35'' THEN ''033''
        WHEN ind_cond_list.key = ''36'' THEN ''034''
        WHEN ind_cond_list.key = ''37'' THEN ''035''
        WHEN ind_cond_list.key = ''38'' THEN ''036''
        WHEN ind_cond_list.key = ''33'' THEN ''037''
        WHEN ind_cond_list.key = ''24'' THEN ''038''
        WHEN ind_cond_list.key = ''7'' THEN ''039''
        WHEN ind_cond_list.key = ''8'' THEN ''040''
        ELSE NULL
        END AS ctlno       --透析条件項目コード
    , CASE
        WHEN ind_cond_list.key = ''992'' THEN ind_cond_list.up_date
        ELSE to_char(ntss_db5_om_temp.up_date, ''YYYY-MM-DD hh24:mi:ss'')
        END AS update --更新日時+
    , CASE
        WHEN ind_cond_list.key = ''991'' THEN ''透析開始時刻''
        WHEN ind_cond_list.key = ''1'' THEN ''透析時間''
        WHEN ind_cond_list.key = ''2'' THEN ''VA''
        WHEN ind_cond_list.key = ''992'' THEN ''DW''
        WHEN ind_cond_list.key = ''3'' THEN ''目標体重''
        WHEN ind_cond_list.key = ''993'' THEN ''治療方法''
        WHEN ind_cond_list.key = ''4'' THEN ''除水量制限''
        WHEN ind_cond_list.key = ''5'' THEN ''ダイアライザ''
        WHEN ind_cond_list.key = ''6'' THEN ''吸着カラム''
        WHEN ind_cond_list.key = ''14'' THEN ''血流量''
        WHEN ind_cond_list.key = ''25'' THEN ''抗凝固剤''
        WHEN ind_cond_list.key = ''26'' THEN ''抗凝固剤ワンショット量''
        WHEN ind_cond_list.key = ''27'' THEN ''抗凝固剤持続速度''
        WHEN ind_cond_list.key = ''28'' THEN ''抗凝固剤持続総量''
        WHEN ind_cond_list.key = ''29'' THEN ''IP使用選択''
        WHEN ind_cond_list.key = ''31'' THEN ''IPワンショット量''
        WHEN ind_cond_list.key = ''32'' THEN ''IP速度''
        WHEN ind_cond_list.key = ''15'' THEN ''透析液''
        WHEN ind_cond_list.key = ''16'' THEN ''透析液流量''
        WHEN ind_cond_list.key = ''17'' THEN ''透析液量''
        WHEN ind_cond_list.key = ''18'' THEN ''透析液温度''
        WHEN ind_cond_list.key = ''19'' THEN ''補液''
        WHEN ind_cond_list.key = ''20'' THEN ''補液量''
        WHEN ind_cond_list.key = ''21'' THEN ''補液選択''
        WHEN ind_cond_list.key = ''23'' THEN ''補液温度''
        WHEN ind_cond_list.key = ''12'' THEN ''シングルニードル使用''
        WHEN ind_cond_list.key = ''22'' THEN ''補液使用数''
        WHEN ind_cond_list.key = ''30'' THEN ''IPスタート''
        WHEN ind_cond_list.key = ''34'' THEN ''自動ワンショット''
        WHEN ind_cond_list.key = ''35'' THEN ''IP電源自動切り''
        WHEN ind_cond_list.key = ''36'' THEN ''IP電源自動切り時間''
        WHEN ind_cond_list.key = ''37'' THEN ''IP電源OKモニタ切り''
        WHEN ind_cond_list.key = ''38'' THEN ''IP電源OKモニタ切り時間''
        WHEN ind_cond_list.key = ''33'' THEN ''IP速度最大値''
        WHEN ind_cond_list.key = ''24'' THEN ''補液速度''
        WHEN ind_cond_list.key = ''7'' THEN ''1次膜''
        WHEN ind_cond_list.key = ''8'' THEN ''2次膜''
        ELSE NULL
        END AS dialysisitemname --透析条件項目名
    , CASE
        WHEN ind_cond_list.key = ''991'' THEN
            CASE
                WHEN ind_cond_list.value = null THEN ''未登録''
                ELSE to_char(to_timestamp(ind_cond_list.value, ''hh24MI''), ''hh24:mi'')
                END
        WHEN ind_cond_list.key = ''2'' THEN ntss_db5_mst_v.in_hospital_cd_1
        WHEN ind_cond_list.key = ''992'' THEN to_char(ind_cond_list.value::numeric, ''FM990.00'')
        WHEN ind_cond_list.key = ''3'' THEN to_char(ind_cond_list.value::numeric, ''FM990.00'')
        WHEN ind_cond_list.key = ''4'' THEN to_char(ind_cond_list.value::numeric, ''FM90.00'')
        WHEN ind_cond_list.key = ''5'' THEN ntss_db5_mst_d.in_hospital_cd_1
        WHEN ind_cond_list.key = ''6''
        OR ind_cond_list.key = ''7''
        OR ind_cond_list.key = ''8''
            THEN ntss_db5_mst_e.in_hospital_cd_1
        WHEN ind_cond_list.key = ''25''
        OR ind_cond_list.key = ''15''
        OR ind_cond_list.key = ''19''
            THEN CASE
                WHEN ind_cond_list.medicine_type = ''1'' THEN ntss_db5_mst_m.in_hospital_cd_1
                WHEN ind_cond_list.medicine_type = ''2'' THEN ntss_db5_mst_m_mix.in_hospital_cd_1
                ELSE NULL
                END
        WHEN ind_cond_list.key = ''26'' THEN to_char(ind_cond_list.value::numeric, ''FM99990.00'')
        WHEN ind_cond_list.key = ''27'' THEN to_char(ind_cond_list.value::numeric, ''FM99990.00'')
        WHEN ind_cond_list.key = ''28'' THEN to_char(ind_cond_list.value::numeric, ''FM99990.00'')
        WHEN ind_cond_list.key = ''31'' THEN to_char(ind_cond_list.value::numeric, ''FM90.0'')
        WHEN ind_cond_list.key = ''32'' THEN to_char(ind_cond_list.value::numeric, ''FM90.0'')
        WHEN ind_cond_list.key = ''17'' THEN to_char(ind_cond_list.value::numeric, ''FM99990.00'')
        WHEN ind_cond_list.key = ''18'' THEN to_char(ind_cond_list.value::numeric, ''FM90.0'')
        WHEN ind_cond_list.key = ''20'' THEN to_char(ind_cond_list.value::numeric, ''FM990.0'')
        WHEN ind_cond_list.key = ''23'' THEN to_char(ind_cond_list.value::numeric, ''FM90.0'')
        WHEN ind_cond_list.key = ''33'' THEN to_char(ind_cond_list.value::numeric, ''FM90.0'')
        WHEN ind_cond_list.key = ''24'' THEN to_char(ind_cond_list.value::numeric, ''FM990.00'')
        ELSE ind_cond_list.value
        END AS value          --設定値
    , CASE
        WHEN ind_cond_list.key = ''2'' THEN ntss_db5_mst_v.va_name
        WHEN ind_cond_list.key = ''5'' THEN ntss_db5_mst_d.model_number
        WHEN ind_cond_list.key = ''6''
        OR ind_cond_list.key = ''7''
        OR ind_cond_list.key = ''8''
            THEN ntss_db5_mst_e.equipment_name
        WHEN ind_cond_list.key = ''25''
        OR ind_cond_list.key = ''15''
        OR ind_cond_list.key = ''19''
            THEN CASE
                WHEN ind_cond_list.medicine_type = ''1'' THEN ntss_db5_mst_m.medicine_name
                WHEN ind_cond_list.medicine_type = ''2'' THEN ntss_db5_mst_m_mix.medicine_mix_name
                ELSE NULL
                END
        WHEN ind_cond_list.key = ''29''
        OR ind_cond_list.key = ''12''
        OR ind_cond_list.key = ''34''
            THEN CASE
                WHEN ind_cond_list.value = ''1'' THEN ''使用する''
                WHEN ind_cond_list.value = ''0'' THEN ''使用しない''
                ELSE NULL
                END
        WHEN ind_cond_list.key = ''21''
            THEN CASE
                WHEN ind_cond_list.value = ''1'' THEN ''前補液''
                WHEN ind_cond_list.value = ''0'' THEN ''後補液''
                ELSE NULL
                END
        WHEN ind_cond_list.key = ''30''
            THEN CASE
                WHEN ind_cond_list.value = ''1'' THEN ''自動''
                WHEN ind_cond_list.value = ''0'' THEN ''手動''
                ELSE NULL
                END
        WHEN ind_cond_list.key = ''35''
        OR ind_cond_list.key = ''37''
            THEN CASE
                WHEN ind_cond_list.value = ''1'' THEN ''入り''
                WHEN ind_cond_list.value = ''0'' THEN ''切り''
                ELSE NULL
                END
        ELSE ind_cond_list.value_name_1
        END AS valuename --名称
    , CASE
        WHEN ind_cond_list.key = ''1'' THEN ''分''
        WHEN ind_cond_list.key = ''3'' THEN ''kg''
        WHEN ind_cond_list.key = ''4'' THEN ''L''
        WHEN ind_cond_list.key = ''6''
        OR ind_cond_list.key = ''7''
        OR ind_cond_list.key = ''8''
            THEN ntss_db5_mst_e.unit
        WHEN ind_cond_list.key = ''14'' THEN ''mL/min''
        WHEN ind_cond_list.key = ''25''
        OR ind_cond_list.key = ''15''
        OR ind_cond_list.key = ''19''
            THEN CASE
                WHEN ind_cond_list.medicine_type = ''1'' THEN ntss_db5_mst_m.unit
                WHEN ind_cond_list.medicine_type = ''2'' THEN ntss_db5_mst_m_mix.unit
                ELSE NULL
                END
        WHEN ind_cond_list.key = ''26''
            THEN CASE
                WHEN LAG(ind_cond_list.medicine_type, 1) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int) = ''1''
                    THEN LAG(ntss_db5_mst_m.unit, 1) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int)
                WHEN LAG(ind_cond_list.medicine_type, 1) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int) = ''2''
                    THEN LAG(ntss_db5_mst_m_mix.unit, 1) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int)
                ELSE NULL
                END
        WHEN ind_cond_list.key = ''27''
            THEN CASE
                WHEN LAG(ind_cond_list.medicine_type, 2) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int) = ''1''
                    THEN CONCAT(LAG(ntss_db5_mst_m.unit, 2) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int), ''/h'')
                WHEN LAG(ind_cond_list.medicine_type, 2) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int) = ''2''
                    THEN CONCAT(LAG(ntss_db5_mst_m_mix.unit, 2) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int), ''/h'')
                ELSE NULL
                END
        WHEN ind_cond_list.key = ''28''
            THEN CASE
                WHEN LAG(ind_cond_list.medicine_type, 3) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int) = ''1''
                    THEN LAG(ntss_db5_mst_m.unit, 3) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int)
                WHEN LAG(ind_cond_list.medicine_type, 3) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int) = ''2''
                    THEN LAG(ntss_db5_mst_m_mix.unit, 3) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int)
                ELSE NULL
                END
        WHEN ind_cond_list.key = ''31'' THEN ''mL''
        WHEN ind_cond_list.key = ''32'' THEN ''mL/h''
        WHEN ind_cond_list.key = ''16'' THEN ''mL/min''
        WHEN ind_cond_list.key = ''17''
            THEN CASE
                WHEN LAG(ind_cond_list.medicine_type, 2) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int) = ''1''
                    THEN LAG(ntss_db5_mst_m.unit, 2) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int)
                WHEN LAG(ind_cond_list.medicine_type, 2) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int) = ''2''
                    THEN LAG(ntss_db5_mst_m_mix.unit, 2) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int)
                ELSE NULL
                END
        WHEN ind_cond_list.key = ''18'' THEN ''℃''
        WHEN ind_cond_list.key = ''20'' THEN ''L''
        WHEN ind_cond_list.key = ''23'' THEN ''℃''
        WHEN ind_cond_list.key = ''22''
            THEN CASE
                WHEN LAG(ind_cond_list.medicine_type, 3) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int) = ''1''
                    THEN LAG(ntss_db5_mst_m.unit, 3) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int)
                WHEN LAG(ind_cond_list.medicine_type, 3) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int) = ''2''
                    THEN LAG(ntss_db5_mst_m_mix.unit, 3) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int)
                ELSE NULL
                END
        WHEN ind_cond_list.key = ''36'' THEN ''分''
        WHEN ind_cond_list.key = ''38'' THEN ''分''
        WHEN ind_cond_list.key = ''33'' THEN ''mL/h''
        WHEN ind_cond_list.key = ''24'' THEN ''L/h''
        ELSE ind_cond_list.unit
        END AS unit            --単位
    , CASE
        WHEN ind_cond_list.key = ''2'' THEN ntss_db5_mst_v.in_hospital_cd_2
        WHEN ind_cond_list.key = ''993'' THEN ind_cond_list.valuecd2
        WHEN ind_cond_list.key = ''5'' THEN ntss_db5_mst_d.in_hospital_cd_2
        WHEN ind_cond_list.key = ''6''
        OR ind_cond_list.key = ''7''
        OR ind_cond_list.key = ''8''
            THEN ntss_db5_mst_e.in_hospital_cd_2
        WHEN ind_cond_list.key = ''25''
        OR ind_cond_list.key = ''15''
        OR ind_cond_list.key = ''19''
            THEN CASE
                WHEN ind_cond_list.medicine_type = ''1'' THEN ntss_db5_mst_m.in_hospital_cd_2
                WHEN ind_cond_list.medicine_type = ''2'' THEN ntss_db5_mst_m_mix.in_hospital_cd_2
                ELSE NULL
                END
        ELSE NULL
        END AS valuecd2 --院内コード2
    , '''' AS indicatorcd                         --指示者
    , ind_cond_list.ind_user_id AS userid
    , CASE
        WHEN ntss_db5_ptp.flg = ''1''
            THEN ''0''
        ELSE ''1''
        END AS opeindplan                       --予定作成区分
    , ntss_db5_om_temp.ord_no AS dialysisno --透析番号
FROM
    ntss_db5_om_temp
    LEFT JOIN ntss_db5_om_1
        ON ntss_db5_om_temp.ord_no = ntss_db5_om_1.ord_no
    RIGHT JOIN ind_cond_list
        ON ntss_db5_om_temp.ord_no = ind_cond_list.ord_no
    LEFT JOIN ntss_db5_mst_v
        ON ind_cond_list.value = ntss_db5_mst_v.va_cd ::text
    LEFT JOIN ntss_db5_mst_d
        ON ind_cond_list.value = ntss_db5_mst_d.dialyzer_cd ::text
    LEFT JOIN ntss_db5_mst_e
        ON ind_cond_list.value = ntss_db5_mst_e.equipment_cd ::text
    LEFT JOIN ntss_db5_mst_m
        ON ind_cond_list.value = ntss_db5_mst_m.medicine_cd ::text
    LEFT JOIN ntss_db5_mst_m_mix
        ON ind_cond_list.value = ntss_db5_mst_m_mix.medicine_mix_cd ::text
    LEFT JOIN ntss_db5_ptp
        ON ntss_db5_ptp.pat_id = ntss_db5_om_temp.pat_id
        AND ntss_db5_ptp.treat_week = ntss_db5_om_temp.treat_week
        AND ntss_db5_ptp.ind_treatment_cd = ntss_db5_om_temp.ind_treatment_cd;
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, '[{"sql_cd": -2518}]'::jsonb);
INSERT INTO sys_data_set
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
            ntss_db5_om_iei_json ->> ''class_name'' AS class_name,
            ntss_db5_om_iei_json ->> ''name'' AS NAME,
            ntss_db5_om_iei_json ->> ''cd'' AS cd,
            ntss_db5_om_iei_json ->> ''class_cd'' AS class_cd,
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
            LEFT JOIN mst_equipment_class ON om.class_cd = mst_equipment_class.class_cd::TEXT
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
INSERT INTO sys_data_set
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
        AND ntss_db5_mst_m.is_del = ''0''
        AND ntss_db5_mst_m.is_disp = ''1''
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
    ;', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
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
        AND one_json ->> ''isDel'' = ''0''
        AND one_json ->> ''isDisp'' = ''1''
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
        AND ntss_db5_om_1.is_del = ''0''
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
        CROSS JOIN LATERAL jsonb_array_elements(ntss_db5_om.ind_ind_comment_info) ntss_db5_om_iic_json
    WHERE
        ntss_db5_om.facility_cd = @facilityCd
        AND ntss_db5_om.is_del = ''0''
        AND ntss_db5_om.pat_id IS NOT NULL
        AND ntss_db5_om.treat_date IS NOT NULL
        AND @fromDate <= ntss_db5_om.treat_date AND ntss_db5_om.treat_date < @toDate
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
        AND ntss_db5_ptp.ind_treatment_cd = ntss_db5_om.ind_treatment_cd;', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd {"Mergekey": ["patid,userid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
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
        AND ntss_db5_mst_m.is_del = ''0''
        AND ntss_db5_mst_m.is_disp = ''1''
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
    AND ntss_db5_op.is_disp = ''1''
    AND ntss_db5_op.facility_cd = @facilityCd
    AND ntss_db5_op_pd_json ->> ''type'' BETWEEN ''1'' AND''5''
    AND @fromDate <= ntss_db5_op.issue_date AND ntss_db5_op.issue_date < @toDate;
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid,userid,prescriptno"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
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
    AND ntss_db6_mst_opp.is_del = ''0''
    AND ntss_db6_mst_opp.is_disp = ''1'';
', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["prescriptno"]}', '2026-02-01 17:51:54.726', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2240, 'SELECT
    '''' AS hosppatid                             --患者ID
    , ntss_db5_om.pat_id AS patid
    , to_char(ntss_db5_om.rst_start_date, ''YYYY-MM-DD hh24:mi:ss'') AS startdate      --開始日時
    , to_char(ntss_db5_mm.occur_date, ''YYYY-MM-DD hh24:mi:ss'') AS occurdate          --発生日時
    , ntss_db5_mm.monitor_data ->> ''90'' AS bpmax                            --最高血圧
    , ntss_db5_mm.monitor_data ->> ''91'' AS bpmin                            --最低血圧
    , ntss_db5_mm.monitor_data ->> ''92'' AS bpave                            --平均血圧
    , ntss_db5_mm.monitor_data ->> ''93'' AS pulse                            --脈拍
    , ntss_db5_mm.monitor_data ->> ''94'' AS temperature                      --体温
    , ntss_db5_mm.monitor_data ->> ''-1'' AS bloodsugarlevel                  --血糖値
    , to_char(ntss_db5_mm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update       --更新日時
    , ntss_db5_om.ord_no AS diadysisno        --透析番号
    , CASE
        WHEN ntss_db5_mm.data_type = ''5'' THEN ''1''
        WHEN ntss_db5_mm.data_type IN (''2'', ''4'') THEN ''0''
        WHEN ntss_db5_mm.data_type = ''6'' THEN ''2''
        END AS bpclass                          --血圧区分
    , ntss_db5_om.treat_date AS dialysisdate        --透析日
FROM
    ord_main ntss_db5_om
    INNER JOIN mni_monitor ntss_db5_mm
        ON ntss_db5_mm.ord_no = ntss_db5_om.ord_no
        AND ntss_db5_om.facility_cd = ntss_db5_mm.facility_cd
        AND ntss_db5_mm.is_del = ''0''
WHERE
    ntss_db5_om.facility_cd = @facilityCd
    AND ntss_db5_mm.data_type IN (''2'', ''4'', ''5'', ''6'')
    AND @fromDate <= ntss_db5_om.treat_date AND ntss_db5_om.treat_date < @toDate
    AND ntss_db5_om.is_del = ''0'';
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, '[{"sql_cd": -2518}]'::jsonb);
INSERT INTO sys_data_set
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
        AND medi_mix.is_del = ''0''
        AND medi_mix.is_disp = ''1''
    LEFT JOIN mst_medicine medi
        ON medi.medicine_cd :: text = rti_json ->> ''treat_medicine_cd''
        AND medi.is_del = ''0''
        AND medi.is_disp = ''1''
    LEFT JOIN mst_procedure prod
        ON prod.procedure_cd :: text = rti_json ->> ''procedure_cd''
        AND prod.is_del = ''0''
        AND prod.is_disp = ''1''
WHERE
    ord_main.facility_cd = @facilityCd
    AND @fromDate <= treat_date AND treat_date < @toDate
    AND ord_main.is_del = ''0''
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
    CROSS JOIN LATERAL jsonb_array_elements(ord_main.rst_complaint_info ::jsonb) rci_json
    LEFT JOIN mst_complaint comp
        ON comp.complaint_cd :: text = rci_json ->> ''comp_cd''
        AND comp.is_del = ''0''
        AND comp.is_disp = ''1''
WHERE
    ord_main.facility_cd = @facilityCd
    AND @fromDate <= treat_date AND treat_date < @toDate
    AND ord_main.is_del = ''0''
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
    CROSS JOIN LATERAL jsonb_array_elements(ord_main.rst_treat_staff_info ::jsonb) rtsi_json
WHERE
    ord_main.facility_cd = @facilityCd
    AND @fromDate <= treat_date AND treat_date < @toDate
    AND ord_main.is_del = ''0'';', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2260, 'WITH ntss_db5_sys_f AS (
    SELECT
        ntss_db5_sys_f.medical_institution_cd
        , ntss_db5_sys_f.facility_name
    FROM
        sys_facility ntss_db5_sys_f
    WHERE
        is_del = ''0''
        AND is_disp = ''1''
)
SELECT
    '''' AS hosppatid --患者ID
    ,ntss_db5_pu.pat_id AS patid
    ,ntss_db5_pu_io_json ->> ''ctl_no'' AS ctlno --項目番号
    ,ntss_db5_pu_io_json ->> ''period_start'' AS regdate --入外歴発生日
    ,CASE
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''1'' THEN ''1''
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''2'' THEN ''1''
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''3'' THEN ''2''
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''4'' THEN ''4''
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''5'' THEN ''5''
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''6'' THEN ''6''
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''10'' THEN ''7''
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''11'' THEN ''3''
        ELSE NULL
        END AS inoutcd --転入出区分
    ,CASE
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''1''
        OR ntss_db5_pu_io_json ->> ''move_in_out'' = ''2''
        OR ntss_db5_pu_io_json ->> ''move_in_out'' = ''10''
        OR ntss_db5_pu_io_json ->> ''move_in_out'' = ''11''
            THEN CASE
                WHEN ntss_db5_pu_io_json ->> ''facility_is_free'' = ''0'' THEN ntss_db5_sys_f_from.facility_name
                WHEN ntss_db5_pu_io_json ->> ''facility_is_free'' = ''1'' THEN ntss_db5_pu_io_json ->> ''from_facility''
                ELSE NULL
                END
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''3''
            THEN CASE
                WHEN ntss_db5_pu_io_json ->> ''facility_is_free'' = ''0'' THEN ntss_db5_sys_f_to.facility_name
                WHEN ntss_db5_pu_io_json ->> ''facility_is_free'' = ''1'' THEN ntss_db5_pu_io_json ->> ''to_facility''
                ELSE NULL
                END
        ELSE NULL
        END AS facilityname --施設名
    ,CASE
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''1''
        OR ntss_db5_pu_io_json ->> ''move_in_out'' = ''2''
        OR ntss_db5_pu_io_json ->> ''move_in_out'' = ''10''
        OR ntss_db5_pu_io_json ->> ''move_in_out'' = ''11''
            THEN CASE
                WHEN ntss_db5_pu_io_json ->> ''doctor_is_free'' = ''0'' THEN ntss_db5_pu_io_json ->> ''from_doctor''
                ELSE NULL
                END
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''3''
            THEN CASE
                WHEN ntss_db5_pu_io_json ->> ''doctor_is_free'' = ''0'' THEN ntss_db5_pu_io_json ->> ''to_doctor''
                ELSE NULL
                END
        ELSE NULL
        END AS userid
    ,CASE
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''1''
        OR ntss_db5_pu_io_json ->> ''move_in_out'' = ''2''
        OR ntss_db5_pu_io_json ->> ''move_in_out'' = ''10''
        OR ntss_db5_pu_io_json ->> ''move_in_out'' = ''11''
            THEN CASE
                WHEN ntss_db5_pu_io_json ->> ''doctor_is_free'' = ''1'' THEN ntss_db5_pu_io_json ->> ''from_doctor''
                ELSE ''''
                END
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''3''
            THEN CASE
                WHEN ntss_db5_pu_io_json ->> ''doctor_is_free'' = ''1'' THEN ntss_db5_pu_io_json ->> ''to_doctor''
                ELSE ''''
                END
        ELSE NULL
        END AS drname --担当医名
    ,ntss_db5_pu_io_json ->> ''reason'' AS memo --コメント
    ,CASE
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''1'' THEN ''導入''
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''2'' THEN ''転入''
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''3'' THEN ''転出''
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''4'' THEN ''入院''
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''5'' THEN ''退院''
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''6'' THEN ''外来''
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''10'' THEN ''不明''
        WHEN ntss_db5_pu_io_json ->> ''move_in_out'' = ''11'' THEN ''死亡''
        ELSE NULL
        END AS codename --区分名
FROM
    pat_unique ntss_db5_pu
    CROSS JOIN LATERAL jsonb_array_elements ( ntss_db5_pu.in_out_visit_history_info ) AS ntss_db5_pu_io_json
    LEFT JOIN ntss_db5_sys_f ntss_db5_sys_f_from
    ON ntss_db5_pu_io_json ->> ''from_facility'' ::text = ntss_db5_sys_f_from.medical_institution_cd ::text
    LEFT JOIN ntss_db5_sys_f ntss_db5_sys_f_to
    ON ntss_db5_pu_io_json ->> ''to_facility'' ::text = ntss_db5_sys_f_to.medical_institution_cd ::text
WHERE
    ntss_db5_pu.facility_cd = @facilityCd
    AND ntss_db5_pu.is_del = ''0''
    AND ntss_db5_pu_io_json ->> ''move_in_out'' IN(''1'',''2'',''3'',''4'',''5'',''6'',''10'',''11'')
    AND @fromDate <= ntss_db5_pu_io_json ->> ''period_start'' AND ntss_db5_pu_io_json ->> ''period_start'' < @toDate;', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2270, 'SELECT
    '''' AS hosppatid --患者ID
    ,ntss_db5_pxm.pat_id AS patid
    ,to_char(ntss_db5_pxm.result_exam_date, ''YYYY-MM-DD hh24:mi:ss'') AS examdate --検査日時
    , CASE
        when ntss_db5_pxm.reg_order_class = ''0''
        then ''その他''
        WHEN ntss_db5_pxm.reg_order_class = ''1''
        THEN ''透析前''
        WHEN ntss_db5_pxm.reg_order_class = ''2''
        THEN ''透析後''
        ELSE NULL
        END AS orderclass --検査区分
    ,to_char(to_timestamp(ntss_db5_om_eri_json ->> ''result_date'',''YYYY/MM/DD HH24:MI:SS:MS''), ''YYYY-MM-DD hh24:mi:ss'') AS itemupdate --検査結果更新日時
    ,ntss_db5_mst_e.in_hospital_cd1 AS examitemcode --検査項目コード(院内コード1)
    ,ntss_db5_mst_e.in_hospital_cd2 AS examitemcode2 --検査項目コード(院内コード2)
    ,ntss_db5_mst_e.in_hospital_cd3 AS examitemcode3 --検査項目コード(院内コード3)
    ,ntss_db5_om_eri_json ->> ''item_name'' AS examitemname --検査項目名
    ,ntss_db5_om_eri_json ->> ''result'' AS examrst --検査結果値
    ,ntss_db5_om_eri_json ->> ''hl'' AS examclassrst --検査結果形態
    ,ntss_db5_om_eri_json ->> ''freememo'' AS comments --コメント
FROM
    pat_exam_main ntss_db5_pxm
    CROSS JOIN LATERAL jsonb_array_elements(ntss_db5_pxm.exam_result_info::jsonb) ntss_db5_om_eri_json
    LEFT JOIN mst_exam_item ntss_db5_mst_e
    ON ntss_db5_mst_e.exam_item_cd :: text = ntss_db5_om_eri_json ->> ''item_cd''
    AND ntss_db5_mst_e.is_del =''0''
    AND ntss_db5_mst_e.is_disp = ''1''
WHERE
    ntss_db5_pxm.facility_cd = @facilityCd
    AND ntss_db5_pxm.is_del = ''0''
    AND @fromDate <= ntss_db5_pxm.result_exam_date AND ntss_db5_pxm.result_exam_date < @toDate
    AND ntss_db5_pxm.exam_result_info IS NOT NULL;

', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2280, 'WITH om AS(
     SELECT
         treat_date
        ,ind_treat_start_time
        ,ind_cond_info_value
        ,ord_no
        ,pat_id
    FROM
        (
             SELECT
                 om.treat_date
                ,om.ind_treat_start_time
                ,om.ind_cond_info -> ''1'' ->> ''value'' AS ind_cond_info_value
                ,om.ord_no
                ,om.pat_id
                ,ROW_NUMBER() OVER(PARTITION BY om.facility_cd, om.pat_id, om.treat_date ORDER BY COALESCE(om.ind_treat_start_time, ''9999'') ASC) AS num
            FROM
                ord_main om
            WHERE
                om.facility_cd = @facilityCd
                AND om.is_del = ''0''
            AND @fromDate <= om.treat_date
            AND om.treat_date < @toDate
            AND ind_treat_start_time IS NOT NULL
        ) AS date_data
    WHERE
        num = 1
)
SELECT
     '''' AS hosppatid --患者ID
    ,pem.pat_id AS patid
    ,to_char(pem.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    ,to_char(pem.reg_exam_date, ''YYYYMMDD'') AS examdate --検査予定日
    ,
     CASE pem.reg_order_class
         WHEN ''0'' THEN (CASE WHEN om.ord_no IS NOT NULL THEN om.ind_treat_start_time ELSE NULL END)
         WHEN ''1'' THEN (CASE WHEN om.ord_no IS NOT NULL THEN to_char((
                         om.ind_treat_start_time::time + (ind_cond_info_value || '' minutes'')::interval
                     ), ''HH24MI'') ELSE NULL END)
         WHEN ''2'' THEN pem_mst_ei.other_exam_time
         ELSE NULL
     END AS examtime --検査予定時刻
    ,pem_mst_ei.in_hospital_cd1 AS examsetcd --検査セットNo(院内コード)
    ,pem_oesi_json ->> ''set_name'' AS examsetname --検査セット名称
    ,CASE pem.reg_order_class
        WHEN ''1'' THEN ''0''
        WHEN ''2'' THEN ''1''
        ELSE ''2''
    END AS examdivision --検査予定区分
    ,''1'' AS examproccd --検査実施予定コード
    ,pem.ind_user_id AS userid
    ,'''' AS doctorcode --指示者
    ,'''' AS doctorname --指示者名
    ,pem.reg_staff AS regstaff
    ,'''' AS orderstaff --スタッフコード
    ,'''' AS ordername
    ,pem.up_staff AS upstaff
    ,'''' AS updatecode
    ,'''' AS updatename
    ,pem.exam_main_cd AS examno --依頼番号
    FROM
        pat_exam_main pem
        CROSS JOIN LATERAL jsonb_array_elements(pem.order_exam_set_info::jsonb) pem_oesi_json
        LEFT JOIN om
        ON  to_char(pem.reg_exam_date, ''YYYYMMDD'') = om.treat_date
        AND pem.pat_id = om.pat_id
        LEFT JOIN
            mst_exam_set pem_mst_ei
        ON  pem_mst_ei.exam_set_cd = cast(pem_oesi_json ->> ''set_cd'' AS integer)
        AND pem_mst_ei.is_del = ''0''
        AND pem_mst_ei.is_disp = ''1''
    WHERE
        pem.facility_cd = @facilityCd
    AND pem.is_del = ''0''
    AND @fromDate <= pem.reg_exam_date AND pem.reg_exam_date < @toDate
    AND pem.order_exam_set_info IS NOT NULL
    AND pem.order_exam_set_info <> ''[]''', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid,regstaff,upstaff"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
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
        AND ntss_db5_mst_wsp.is_del = ''0''
        AND ntss_db5_mst_wsp.is_disp = ''1''
WHERE
    ntss_db5_mnt_ws.facility_cd = @facilityCd
    AND ntss_db5_mnt_ws.is_del =''0''
    AND ntss_db5_mnt_ws.is_disp = ''1''
    AND @fromDate <= ntss_db5_mnt_ws.inspection_date AND ntss_db5_mnt_ws.inspection_date < @toDate;
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": [""]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2300, 'with ord_main_tmp as(
    select
        ord_no
        ,pat_id
        ,treat_date
        ,ind_treat_start_time
        ,rst_dialysis_state
        ,rst_cond_send_date
        ,rst_start_date
        ,rst_end_date
        ,to_char((rst_weight_info ->> ''weight_after_date'')::TIMESTAMPTZ AT TIME ZONE ''Asia/Tokyo'', ''YYYY-MM-DD hh24:mi:ss'') as weightafterdate
        ,rst_edition_date
        ,cur_edition_date
        ,facility_cd
        from
            ord_main
        where
            facility_cd = @facilityCd
            and @fromDate <= treat_date AND treat_date < @toDate
            AND is_del = ''0''
    )
,mnt_motion_record_tmp as
    (select
        ord_no
        ,machine_record_cd 
        ,event_reg_date
    from
        mnt_motion_record
    where
        facility_cd = @facilityCd
        and machine_record_cd in(''4000'',''5F00'',''F407'',''F409'',''F406'',''F408'')
)
,off_water_tmp as
    (select
        ord_no
        ,machine_record_cd 
        ,event_reg_date
    from(
        select
            mnt.ord_no
            ,mnt.machine_record_cd
            ,mnt.event_reg_date
            ,row_number() OVER (PARTITION BY mnt.ord_no ORDER BY mnt.event_reg_date DESC) as rn
        from
            mnt_motion_record_tmp as mnt
            left join ord_main_tmp as ord on ord.ord_no = mnt.ord_no
        where
            mnt.machine_record_cd in(''4000'',''5F00'')
        )waterranked
    where
        rn = 1
)
,machine_check_tmp as(
select
    ord_no
    ,case when machine_record_cd in (''F407'',''F409'') then ''1''
        else null
    end as machinecheckflg
    ,case when machine_record_cd in (''F406'',''F408'') then null --最新レコードがF406、F408だった時は除水完了日時をnullにする
        else event_reg_date
    end as machinecheckdate
    from(
        select
            mnt.ord_no
            ,mnt.machine_record_cd
            ,mnt.event_reg_date
            ,row_number() OVER (PARTITION BY mnt.ord_no ORDER BY mnt.event_reg_date DESC) as rn
        from
            mnt_motion_record_tmp as mnt
            left join ord_main_tmp as ord on ord.ord_no = mnt.ord_no
        where 
            mnt.machine_record_cd in(''F407'',''F409'',''F406'',''F408'')
    )machineranked
    where
        rn = 1
)
SELECT
    ord.pat_id as patid --患者ID(外部キー用)
    ,'''' as hosppatid --表示患者ID(外部キーから取得)
    ,ord.treat_date as dialysisdate --透析日
    ,ord.ind_treat_start_time as dialysistime --透析開始時刻
    ,to_char(to_timestamp(treat_date||ind_treat_start_time||''0000'',''YYYYMMDDHH24MISSMS'')AT TIME ZONE ''Asia/Tokyo'', ''YYYY-MM-DD hh24:mi:ss'') as startplandate --予定開始日時
    ,CASE
        WHEN ord.rst_cond_send_date is null then ''0'' else ''1''
    END as enterflg --入室フラグ（前体重測定）
    ,to_char(ord.rst_cond_send_date, ''YYYY-MM-DD hh24:mi:ss'') as enterdate --初回入室日時(前体重測定日時)
    ,CASE
        WHEN machine.machinecheckflg is null then ''0'' else ''1''
    END as machinecheckflg --透析装置確認フラグ
    ,to_char(machine.machinecheckdate, ''YYYY-MM-DD hh24:mi:ss'') as machinecheckdate --透析装置確認日時
    ,CASE
        WHEN ord.rst_dialysis_state IN (''0'', ''1'', ''2'') then ''0''
        WHEN ord.rst_dialysis_state IN (''3'',''4'', ''5'', ''6'') then ''1''
    END as dialsisstartflg --透析運転開始フラグ
    ,to_char(ord.rst_start_date, ''YYYY-MM-DD hh24:mi:ss'') as dialsisstartdate--透析運転開始日時
    ,CASE
        WHEN water.machine_record_cd is null then ''0'' ELSE ''1''
    END as offwaterflg --除水完了フラグ
    ,to_char(water.event_reg_date, ''YYYY-MM-DD hh24:mi:ss'') as offwaterdate --除水完了日時
    ,CASE
        WHEN ord.rst_dialysis_state IN (''0'',''1'',''2'',''3'') then ''0''
        WHEN ord.rst_dialysis_state IN (''4'',''5'',''6'') then ''1''
    END as wastefluidflg --排液フラグ
    ,to_char(ord.rst_end_date, ''YYYY-MM-DD hh24:mi:ss'')  as wastefluiddate --排液日時
    ,CASE
        WHEN ord.rst_dialysis_state IN (''0'',''1'',''2'',''3'',''4'') then ''0''
        WHEN ord.rst_dialysis_state IN (''5'',''6'') then ''1''
    END as weightafterflg --後体重測定フラグ
    ,ord.weightafterdate --後体重測定日時
    ,CASE
        WHEN ord.rst_dialysis_state IN (''0'',''1'',''2'',''3'',''4'',''5'') then ''0''
        WHEN ord.rst_dialysis_state IN (''6'') then ''1''
    END as recoverybtnflg --準備回収確認ボタンフラグ
    ,to_char(ord.rst_edition_date, ''YYYY-MM-DD hh24:mi:ss'') as recoverybtndate--準備回収確認ボタン日時
    ,to_char(ord.cur_edition_date, ''YYYY-MM-DD hh24:mi:ss'') as update --更新日時
    ,ord.ord_no AS dialysisno --透析番号
from
    ord_main_tmp as ord
    left join off_water_tmp as water on ord.ord_no = water.ord_no
    left join machine_check_tmp as machine on ord.ord_no = machine.ord_no;', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2310, 'WITH ntss_db5_mst_pesc AS (
    SELECT
        ntss_db5_mst_pesc.sub_category_cd
        , ntss_db5_mst_pesc.sub_category_name
    FROM
        mst_pat_event_sub_category ntss_db5_mst_pesc
    WHERE
        ntss_db5_mst_pesc.facility_cd = @facilityCd
        AND ntss_db5_mst_pesc.is_del = ''0''
        AND ntss_db5_mst_pesc.is_disp = ''1''
)
, result_params_temp AS (
    SELECT
        pe.pat_event_cd
        , json_rp ->> ''result_value'' AS result_value
        , idx AS rp_idx
    FROM
        pat_event pe
    CROSS JOIN lateral jsonb_array_elements(pe.result_params) with ordinality AS tmp(json_rp, idx)
    WHERE
        pe.facility_cd = @facilityCd
        AND @fromDate <= pe.event_start_date AND pe.event_start_date < @toDate
        AND pe.result_params <> ''null''
        AND pe.result_params <> ''[]''
        AND pe.is_del = ''0''
)
SELECT
    '''' AS hosppatid                             --患者ID
    , ntss_db5_pe.pat_id AS patid
    , to_char(ntss_db5_pe.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    , '''' AS name                                --氏名
    , '''' AS namekana                            --患者名(かな）
    , ntss_db5_pe.event_start_date AS regdate --起票日
    , '''' AS regtime --起票時刻
    , CASE
        WHEN ntss_db5_mst_pesc.sub_category_name = ''SOAP'' THEN ''0''
        WHEN ntss_db5_mst_pesc.sub_category_name = ''看護メモ'' THEN ''1''
        WHEN ntss_db5_mst_pesc.sub_category_name = ''問診記録'' THEN ''2''
        ELSE NULL
        END AS kindid                           --種別ID
    , ntss_db5_pe.sub_category_name AS kindname --種別名
    , '''' AS staffcd                             --起票者ID
    , ntss_db5_pe.reg_staff_info #>> ''{reg_staff_cd}'' AS staffid
    , ntss_db5_pe.reg_staff_info #>> ''{reg_staff_name}'' AS staffname --起票者名
    , '''' AS editcd                              --編集者ID
    , ntss_db5_pe.up_staff_info #>> ''{up_staff_cd}'' AS editid
    , ntss_db5_pe.up_staff_info #>> ''{up_staff_name}'' AS editname --編集者名
    , MAX(CASE
        WHEN ntss_db5_mst_pesc.sub_category_name = ''SOAP''
        AND json_ip ->> ''field_name'' = ''S''
            THEN result_params_temp.result_value
        WHEN (ntss_db5_mst_pesc.sub_category_name = ''看護メモ''
            OR ntss_db5_mst_pesc.sub_category_name = ''問診記録'')
        AND idx = 1
            THEN result_params_temp.result_value
        ELSE NULL
        END) AS detail1 --内容1
    , MAX(CASE
        WHEN ntss_db5_mst_pesc.sub_category_name = ''SOAP''
        AND json_ip ->> ''field_name'' = ''O''
            THEN result_params_temp.result_value
        ELSE NULL
        END) AS detail2 --内容2
    , MAX(CASE
        WHEN ntss_db5_mst_pesc.sub_category_name = ''SOAP''
        AND json_ip ->> ''field_name'' = ''A''
            THEN result_params_temp.result_value
        ELSE NULL
        END) AS detail3 --内容3
    , MAX(CASE
        WHEN ntss_db5_mst_pesc.sub_category_name = ''SOAP''
        AND json_ip ->> ''field_name'' = ''P''
            THEN result_params_temp.result_value
        ELSE NULL
        END) AS detail4 --内容4
    ,CASE
        WHEN ntss_db5_pe.ord_no = 0 THEN NULL
        ELSE ntss_db5_pe.ord_no
        END AS dialysisno --透析番号
FROM
    pat_event ntss_db5_pe
    LEFT JOIN ntss_db5_mst_pesc
        ON ntss_db5_mst_pesc.sub_category_cd = ntss_db5_pe.sub_category_cd
    CROSS JOIN LATERAL jsonb_array_elements(ntss_db5_pe.input_params) WITH ordinality AS tmp(json_ip, idx)
    LEFT JOIN result_params_temp
    ON result_params_temp.pat_event_cd = ntss_db5_pe.pat_event_cd
    AND result_params_temp.rp_idx = idx
WHERE
    ntss_db5_pe.facility_cd = @facilityCd
    AND @fromDate <= ntss_db5_pe.event_start_date AND ntss_db5_pe.event_start_date < @toDate
    AND ntss_db5_pe.is_del = ''0''
    AND ntss_db5_pe.input_params IS NOT NULL
    AND ntss_db5_pe.input_params <> ''null''
    AND ntss_db5_pe.input_params <> ''[]''
    AND ntss_db5_mst_pesc.sub_category_name IN (''SOAP'',''看護メモ'',''問診記録'')
GROUP BY
    ntss_db5_pe.pat_event_cd
    , ntss_db5_mst_pesc.sub_category_name;
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,staffid,editid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2311, '-- 【SQL_CD=-2311】
SELECT
    hosp_pat_id AS hosppatid --患者ID
    , pat_id AS patid
    , CONCAT(personal_info_decrypt(pat_last_name), ''　'', personal_info_decrypt(pat_first_name)) AS name --氏名
    , CONCAT(personal_info_decrypt(pat_last_name_kana), ''　'', personal_info_decrypt(pat_first_name_kana)) AS namekana --患者名(かな)
FROM
    pat_personal_main
WHERE
    facility_cd = @facilityCd
    AND is_del = ''0'';', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2320, '-- 【SQL_CD=-2320】
SELECT
    '''' AS hosppatid --患者ID
    ,pm.pat_id AS patid
    ,pmi_json ->> ''ctl_no'' AS ctlno
    ,pmi_json ->> ''title'' AS title
    ,pmi_json ->> ''content'' AS content
FROM
    pat_main pm
    CROSS JOIN LATERAL jsonb_array_elements(pm.pat_memo_info ::jsonb) pmi_json
    JOIN mst_pat_memo mpm ON pmi_json ->> ''ctl_no'' =  mpm.pat_memo_no::TEXT 
    AND mpm.facility_cd = @facilityCd
    AND mpm.is_del = ''0''
    AND mpm.is_disp = ''1''
WHERE
    pm.facility_cd = @facilityCd
    AND pm.is_del =''0''
    AND (pmi_json ->> ''title'' IS NOT NULL
        OR pmi_json ->> ''content'' IS NOT NULL);
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2420, 'WITH sys_moni AS (
    SELECT
        moni_data_no,
        moni_data_name
    FROM
        sys_monitor_item
    WHERE
        moni_data_no IN (''-1'',''-2'',''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'',''9'',''10'',''11'',''12'',''13'',''14'',''15'',''16'',''17'',''18'',''19'',''20'',''21'',''22'',''23'',''24'',''25'',''26'',''27'',''28'',''29'',''30'',''31'',''32'',''33'',''34'',''35'',''36'',''37'',''38'',''39'',''40'',''41'',''42'',''43'',''44'',''45'',''46'',''47'',''48'',''49'',''50'',''51'',''52'',''53'',''54'',''55'',''56'',''57'',''58'',''59'',''60'',''61'',''62'',''63'',''64'',''65'',''66'',''67'',''68'',''69'',''70'',''71'',''72'',''73'',''74'',''75'',''76'',''77'',''78'',''79'',''80'',''81'',''82'',''83'',''84'',''85'',''86'',''87'',''88'',''89'',''90'',''91'',''92'',''93'',''94'',''95'',''96'',''97'',''98'',''99'',''100'',''101'',''102'',''103'',''104'',''105'',''106'',''107'',''108'',''109'',''110'',''111'',''112'',''113'',''114'',''115'',''116'',''117'',''118'',''119'',''120'',''121'',''122'',''123'',''124'',''125'',''126'',''127'',''128'',''129'',''130'',''131'',''132'',''133'',''134'',''135'',''136'',''137'',''138'',''139'',''140'',''141'',''142'',''143'',''144'',''145'',''146'',''147'',''148'',''149'',''150'')
        AND sys_monitor_item.is_disp = ''1''
        AND sys_monitor_item.moni_data_type IS NULL
        AND sys_monitor_item.data_type between 1 and 3
)
        SELECT 
    m_b.in_hospital_cd_1 AS bedno --ベッド番号
    , m_m.in_hospital_cd_1 AS deviceno --装置番号
    , to_char(mm.occur_date,''YYYY-MM-DD hh24:mi:ss'') AS occurdate --発生日時
    , om.pat_id AS patid
    , '''' AS hosppatid --患者ID
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''1'') AS moniname1
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''1'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''1'' ::TEXT <> ''-1'' THEN mm.monitor_data ->> ''1'' 
        END
    END AS moniitem1
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''2'') AS moniname2
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''2'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''2'' ::TEXT <> ''-1'' THEN mm.monitor_data ->> ''2'' 
        END
    END AS moniitem2
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''3'') AS moniname3
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''3'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''3'' ::TEXT <> ''-1'' THEN mm.monitor_data ->> ''3'' 
        END
    END AS moniitem3
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''4'') AS moniname4
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''4'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''4''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''4''
        END
    END AS moniitem4
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''5'') AS moniname5
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''5'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''5''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''5''
        END
    END AS moniitem5
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''6'') AS moniname6
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''6'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''6''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''6''
        END
    END AS moniitem6
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''7'') AS moniname7
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''7'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''7''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''7''
        END
    END AS moniitem7
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''8'') AS moniname8
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''8'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''8''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''8''
        END
    END AS moniitem8
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''9'') AS moniname9
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''9'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''9''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''9''
        END
    END AS moniitem9
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''10'') AS moniname10
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''10'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''10''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''10''
        END
    END AS moniitem10
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''11'') AS moniname11
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''11'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''11''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''11''
        END
    END AS moniitem11
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''12'') AS moniname12
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''12'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''12''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''12''
        END
    END AS moniitem12
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''13'') AS moniname13
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''13'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''13''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''13''
        END
    END AS moniitem13
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''14'') AS moniname14
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''14'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''14''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''14''
        END
    END AS moniitem14
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''15'') AS moniname15
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''15'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''15''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''15''
        END
    END AS moniitem15
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''16'') AS moniname16
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''16'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''16''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''16''
        END
    END AS moniitem16
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''17'') AS moniname17
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''17'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''17''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''17''
        END
    END AS moniitem17
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''18'') AS moniname18
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''18'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''18''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''18''
        END
    END AS moniitem18
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''19'') AS moniname19
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''19'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''19''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''19''
        END
    END AS moniitem19
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''20'') AS moniname20
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''20'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''20''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''20''
        END
    END AS moniitem20
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''21'') AS moniname21
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''21'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''21''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''21''
        END
    END AS moniitem21
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''22'') AS moniname22
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''22'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''22''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''22''
        END
    END AS moniitem22
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''23'') AS moniname23
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''23'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''23''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''23''
        END
    END AS moniitem23
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''24'') AS moniname24
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''24'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''24''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''24''
        END
    END AS moniitem24
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''25'') AS moniname25
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''25'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''25''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''25''
        END
    END AS moniitem25
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''26'') AS moniname26
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''26'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''26''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''26''
        END
    END AS moniitem26
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''27'') AS moniname27
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''27'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''27''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''27''
        END
    END AS moniitem27
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''28'') AS moniname28
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''28'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''28''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''28''
        END
    END AS moniitem28
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''29'') AS moniname29
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''29'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''29''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''29''
        END
    END AS moniitem29
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''30'') AS moniname30
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''30'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''30''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''30''
        END
    END AS moniitem30
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''31'') AS moniname31
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''31'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''31''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''31''
        END
    END AS moniitem31
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''32'') AS moniname32
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''32'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''32''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''32''
        END
    END AS moniitem32
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''33'') AS moniname33
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''33'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''33''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''33''
        END
    END AS moniitem33
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''34'') AS moniname34
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''34'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''34''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''34''
        END
    END AS moniitem34
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''35'') AS moniname35
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''35'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''35''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''35''
        END
    END AS moniitem35
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''36'') AS moniname36
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''36'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''36''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''36''
        END
    END AS moniitem36
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''37'') AS moniname37
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''37'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''37''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''37''
        END
    END AS moniitem37
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''38'') AS moniname38
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''38'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''38''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''38''
        END
    END AS moniitem38
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''39'') AS moniname39
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''39'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''39''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''39''
        END
    END AS moniitem39
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''40'') AS moniname40
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''40'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''40''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''40''
        END
    END AS moniitem40
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''41'') AS moniname41
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''41'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''41''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''41''
        END
    END AS moniitem41
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''42'') AS moniname42
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''42'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''42''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''42''
        END
    END AS moniitem42
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''43'') AS moniname43
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''43'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''43''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''43''
        END
    END AS moniitem43
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''44'') AS moniname44
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''44'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''44''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''44''
        END
    END AS moniitem44
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''45'') AS moniname45
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''45'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''45''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''45''
        END
    END AS moniitem45
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''46'') AS moniname46
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''46'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''46''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''46''
        END
    END AS moniitem46
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''47'') AS moniname47
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''47'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''47''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''47''
        END
    END AS moniitem47
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''48'') AS moniname48
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''48'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''48''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''48''
        END
    END AS moniitem48
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''49'') AS moniname49
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''49'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''49''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''49''
        END
    END AS moniitem49
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''50'') AS moniname50
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''50'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''50''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''50''
        END
    END AS moniitem50
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''51'') AS moniname51
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''51'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''51''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''51''
        END
    END AS moniitem51
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''52'') AS moniname52
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''52'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''52''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''52''
        END
    END AS moniitem52
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''53'') AS moniname53
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''53'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''53''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''53''
        END
    END AS moniitem53
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''54'') AS moniname54
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''54'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''54''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''54''
        END
    END AS moniitem54
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''55'') AS moniname55
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''55'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''55''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''55''
        END
    END AS moniitem55
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''56'') AS moniname56
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''56'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''56''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''56''
        END
    END AS moniitem56
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''57'') AS moniname57
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''57'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''57''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''57''
        END
    END AS moniitem57
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''58'') AS moniname58
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''58'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''58''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''58''
        END
    END AS moniitem58
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''59'') AS moniname59
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''59'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''59''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''59''
        END
    END AS moniitem59
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''60'') AS moniname60
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''60'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''60''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''60''
        END
    END AS moniitem60
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''61'') AS moniname61
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''61'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''61''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''61''
        END
    END AS moniitem61
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''62'') AS moniname62
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''62'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''62''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''62''
        END
    END AS moniitem62
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''63'') AS moniname63
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''63'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''63''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''63''
        END
    END AS moniitem63
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''64'') AS moniname64
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''64'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''64''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''64''
        END
    END AS moniitem64
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''65'') AS moniname65
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''65'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''65''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''65''
        END
    END AS moniitem65
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''66'') AS moniname66
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''66'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''66''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''66''
        END
    END AS moniitem66
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''67'') AS moniname67
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''67'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''67''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''67''
        END
    END AS moniitem67
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''68'') AS moniname68
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''68'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''68''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''68''
        END
    END AS moniitem68
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''69'') AS moniname69
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''69'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''69''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''69''
        END
    END AS moniitem69
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''70'') AS moniname70
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''70'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''70''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''70''
        END
    END AS moniitem70
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''71'') AS moniname71
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''71'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''71''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''71''
        END
    END AS moniitem71
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''72'') AS moniname72
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''72'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''72''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''72''
        END
    END AS moniitem72
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''73'') AS moniname73
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''73'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''73''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''73''
        END
    END AS moniitem73
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''74'') AS moniname74
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''74'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''74''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''74''
        END
    END AS moniitem74
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''75'') AS moniname75
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''75'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''75''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''75''
        END
    END AS moniitem75
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''76'') AS moniname76
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''76'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''76''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''76''
        END
    END AS moniitem76
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''77'') AS moniname77
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''77'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''77''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''77''
        END
    END AS moniitem77
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''78'') AS moniname78
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''78'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''78''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''78''
        END
    END AS moniitem78
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''79'') AS moniname79
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''79'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''79''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''79''
        END
    END AS moniitem79
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''80'') AS moniname80
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''80'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''80''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''80''
        END
    END AS moniitem80
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''81'') AS moniname81
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''81'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''81''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''81''
        END
    END AS moniitem81
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''82'') AS moniname82
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''82'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''82''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''82''
        END
    END AS moniitem82
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''83'') AS moniname83
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''83'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''83''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''83''
        END
    END AS moniitem83
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''84'') AS moniname84
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''84'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''84''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''84''
        END
    END AS moniitem84
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''85'') AS moniname85
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''85'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''85''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''85''
        END
    END AS moniitem85
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''86'') AS moniname86
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''86'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''86''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''86''
        END
    END AS moniitem86
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''87'') AS moniname87
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''87'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''87''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''87''
        END
    END AS moniitem87
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''88'') AS moniname88
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''88'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''88''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''88''
        END
    END AS moniitem88
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''89'') AS moniname89
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''89'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''89''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''89''
        END
    END AS moniitem89
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''90'') AS moniname90
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''90'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''90''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''90''
        END
    END AS moniitem90
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''91'') AS moniname91
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''91'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''91''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''91''
        END
    END AS moniitem91
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''92'') AS moniname92
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''92'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''92''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''92''
        END
    END AS moniitem92
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''93'') AS moniname93
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''93'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''93''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''93''
        END
    END AS moniitem93
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''94'') AS moniname94
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''94'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''94''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''94''
        END
    END AS moniitem94
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''95'') AS moniname95
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''95'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''95''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''95''
        END
    END AS moniitem95
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''96'') AS moniname96
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''96'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''96''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''96''
        END
    END AS moniitem96
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''97'') AS moniname97
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''97'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''97''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''97''
        END
    END AS moniitem97
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''98'') AS moniname98
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''98'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''98''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''98''
        END
    END AS moniitem98
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''99'') AS moniname99
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''99'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''99''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''99''
        END
    END AS moniitem99
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''100'') AS moniname100
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''100'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''100''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''100''
        END
    END AS moniitem100
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''101'') AS moniname101
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''101'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''101''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''101''
        END
    END AS moniitem101
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''102'') AS moniname102
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''102'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''102''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''102''
        END
    END AS moniitem102
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''103'') AS moniname103
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''103'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''103''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''103''
        END
    END AS moniitem103
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''104'') AS moniname104
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''104'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''104''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''104''
        END
    END AS moniitem104
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''105'') AS moniname105
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''105'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''105''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''105''
        END
    END AS moniitem105
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''106'') AS moniname106
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''106'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''106''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''106''
        END
    END AS moniitem106
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''107'') AS moniname107
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''107'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''107''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''107''
        END
    END AS moniitem107
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''108'') AS moniname108
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''108'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''108''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''108''
        END
    END AS moniitem108
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''109'') AS moniname109
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''109'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''109''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''109''
        END
    END AS moniitem109
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''110'') AS moniname110
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''110'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''110''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''110''
        END
    END AS moniitem110
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''111'') AS moniname111
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''111'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''111''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''111''
        END
    END AS moniitem111
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''112'') AS moniname112
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''112'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''112''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''112''
        END
    END AS moniitem112
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''113'') AS moniname113
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''113'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''113''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''113''
        END
    END AS moniitem113
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''114'') AS moniname114
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''114'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''114''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''114''
        END
    END AS moniitem114
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''115'') AS moniname115
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''115'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''115''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''115''
        END
    END AS moniitem115
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''116'') AS moniname116
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''116'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''116''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''116''
        END
    END AS moniitem116
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''117'') AS moniname117
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''117'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''117''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''117''
        END
    END AS moniitem117
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''118'') AS moniname118
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''118'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''118''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''118''
        END
    END AS moniitem118
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''119'') AS moniname119
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''119'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''119''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''119''
        END
    END AS moniitem119
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''120'') AS moniname120
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''120'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''120''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''120''
        END
    END AS moniitem120
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''121'') AS moniname121
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''121'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''121''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''121''
        END
    END AS moniitem121
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''122'') AS moniname122
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''122'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''122''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''122''
        END
    END AS moniitem122
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''123'') AS moniname123
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''123'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''123''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''123''
        END
    END AS moniitem123
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''124'') AS moniname124
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''124'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''124''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''124''
        END
    END AS moniitem124
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''125'') AS moniname125
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''125'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''125''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''125''
        END
    END AS moniitem125
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''126'') AS moniname126
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''126'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''126''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''126''
        END
    END AS moniitem126
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''127'') AS moniname127
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''127'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''127''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''127''
        END
    END AS moniitem127
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''128'') AS moniname128
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''128'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''128''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''128''
        END
    END AS moniitem128
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''129'') AS moniname129
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''129'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''129''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''129''
        END
    END AS moniitem129
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''130'') AS moniname130
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''130'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''130''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''130''
        END
    END AS moniitem130
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''131'') AS moniname131
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''131'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''131''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''131''
        END
    END AS moniitem131
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''132'') AS moniname132
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''132'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''132''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''132''
        END
    END AS moniitem132
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''133'') AS moniname133
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''133'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''133''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''133''
        END
    END AS moniitem133
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''134'') AS moniname134
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''134'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''134''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''134''
        END
    END AS moniitem134
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''135'') AS moniname135
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''135'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''135''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''135''
        END
    END AS moniitem135
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''136'') AS moniname136
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''136'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''136''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''136''
        END
    END AS moniitem136
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''137'') AS moniname137
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''137'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''137''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''137''
        END
    END AS moniitem137
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''138'') AS moniname138
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''138'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''138''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''138''
        END
    END AS moniitem138
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''139'') AS moniname139
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''139'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''139''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''139''
        END
    END AS moniitem139
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''140'') AS moniname140
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''140'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''140''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''140''
        END
    END AS moniitem140
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''141'') AS moniname141
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''141'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''141''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''141''
        END
    END AS moniitem141
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''142'') AS moniname142
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''142'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''142''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''142''
        END
    END AS moniitem142
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''143'') AS moniname143
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''143'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''143''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''143''
        END
    END AS moniitem143
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''144'') AS moniname144
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''144'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''144''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''144''
        END
    END AS moniitem144
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''145'') AS moniname145
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''145'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''145''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''145''
        END
    END AS moniitem145
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''146'') AS moniname146
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''146'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''146''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''146''
        END
    END AS moniitem146
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''147'') AS moniname147
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''147'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''147''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''147''
        END
    END AS moniitem147
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''148'') AS moniname148
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''148'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''148''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''148''
        END
    END AS moniitem148
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''149'') AS moniname149
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''149'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''149''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''149''
        END
    END AS moniitem149
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''150'') AS moniname150
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''150'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''150''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''150''
        END
    END AS moniitem150
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''-1'') AS moniname151
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''-1'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''-1''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''-1''
        END
    END AS moniitem151
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''-2'') AS moniname152
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''-2'') IS NOT NULL THEN 
        CASE 
            WHEN mm.monitor_data ->> ''-2''::TEXT <> ''-1'' THEN mm.monitor_data ->> ''-2''
        END
    END AS moniitem152
    , to_char(mm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    , om.ord_no AS ordno --透析番号
    , om.treat_date AS dialysisdate --透析日
        FROM
            ord_main om
            JOIN mni_monitor mm
                ON mm.ord_no = om.ord_no
                AND mm.facility_cd = @facilityCd
                AND mm.is_del = ''0''
            LEFT JOIN mst_machine m_m
                ON m_m.machine_no = om.rst_machine_no
                AND m_m.facility_cd = @facilityCd
                AND m_m.is_del = ''0''
                AND m_m.is_disp = ''1''
            LEFT JOIN mst_bed m_b
                ON om.rst_bed_cd = m_b.bed_cd
                AND m_b.is_del = ''0''
                AND m_b.is_disp = ''1''
        WHERE
            om.facility_cd = @facilityCd
            AND om.is_del = ''0''
            AND @fromDate <= om.treat_date AND om.treat_date < @toDate
            AND mm.data_type IN (1,2,5,6);
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2430, 'WITH sys_moni AS (
    SELECT
        moni_data_no,
        moni_data_name
    FROM
        sys_monitor_item
    WHERE
        moni_data_no IN (''-1'',''-2'',''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'',''9'',''10'',''11'',''12'',''13'',''14'',''15'',''16'',''17'',''18'',''19'',''20'',''21'',''22'',''23'',''24'',''25'',''26'',''27'',''28'',''29'',''30'',''31'',''32'',''33'',''34'',''35'',''36'',''37'',''38'',''39'',''40'',''41'',''42'',''43'',''44'',''45'',''46'',''47'',''48'',''49'',''50'',''51'',''52'',''53'',''54'',''55'',''56'',''57'',''58'',''59'',''60'',''61'',''62'',''63'',''64'',''65'',''66'',''67'',''68'',''69'',''70'',''71'',''72'',''73'',''74'',''75'',''76'',''77'',''78'',''79'',''80'',''81'',''82'',''83'',''84'',''85'',''86'',''87'',''88'',''89'',''90'',''91'',''92'',''93'',''94'',''95'',''96'',''97'',''98'',''99'',''100'',''101'',''102'',''103'',''104'',''105'',''106'',''107'',''108'',''109'',''110'',''111'',''112'',''113'',''114'',''115'',''116'',''117'',''118'',''119'',''120'',''121'',''122'',''123'',''124'',''125'',''126'',''127'',''128'',''129'',''130'',''131'',''132'',''133'',''134'',''135'',''136'',''137'',''138'',''139'',''140'',''141'',''142'',''143'',''144'',''145'',''146'',''147'',''148'',''149'',''150'')
        AND sys_monitor_item.is_disp = ''1''
        AND sys_monitor_item.moni_data_type IS NULL
        AND sys_monitor_item.data_type BETWEEN 1 AND 3
)
        SELECT 
    ntss_db5_mst_b.in_hospital_cd_1 AS bedno --ベッド番号
    , ntss_db5_mst_m.in_hospital_cd_1 AS deviceno --装置番号
    , to_char(ntss_db5_mm.occur_date,''YYYY-MM-DD hh24:mi:ss'') AS occurdate --発生日時
    , ntss_db5_om.pat_id AS patid
    , '''' AS hosppatid --患者ID
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''1'') AS moniname1
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''1'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''1'' ::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''1'' 
        END
    END AS moniitem1
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''2'') AS moniname2
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''2'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''2'' ::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''2'' 
        END
    END AS moniitem2
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''3'') AS moniname3
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''3'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''3'' ::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''3'' 
        END
    END AS moniitem3
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''4'') AS moniname4
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''4'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''4''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''4''
        END
    END AS moniitem4
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''5'') AS moniname5
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''5'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''5''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''5''
        END
    END AS moniitem5
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''6'') AS moniname6
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''6'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''6''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''6''
        END
    END AS moniitem6
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''7'') AS moniname7
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''7'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''7''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''7''
        END
    END AS moniitem7
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''8'') AS moniname8
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''8'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''8''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''8''
        END
    END AS moniitem8
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''9'') AS moniname9
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''9'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''9''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''9''
        END
    END AS moniitem9
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''10'') AS moniname10
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''10'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''10''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''10''
        END
    END AS moniitem10
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''11'') AS moniname11
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''11'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''11''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''11''
        END
    END AS moniitem11
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''12'') AS moniname12
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''12'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''12''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''12''
        END
    END AS moniitem12
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''13'') AS moniname13
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''13'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''13''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''13''
        END
    END AS moniitem13
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''14'') AS moniname14
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''14'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''14''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''14''
        END
    END AS moniitem14
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''15'') AS moniname15
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''15'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''15''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''15''
        END
    END AS moniitem15
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''16'') AS moniname16
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''16'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''16''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''16''
        END
    END AS moniitem16
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''17'') AS moniname17
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''17'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''17''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''17''
        END
    END AS moniitem17
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''18'') AS moniname18
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''18'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''18''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''18''
        END
    END AS moniitem18
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''19'') AS moniname19
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''19'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''19''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''19''
        END
    END AS moniitem19
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''20'') AS moniname20
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''20'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''20''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''20''
        END
    END AS moniitem20
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''21'') AS moniname21
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''21'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''21''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''21''
        END
    END AS moniitem21
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''22'') AS moniname22
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''22'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''22''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''22''
        END
    END AS moniitem22
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''23'') AS moniname23
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''23'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''23''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''23''
        END
    END AS moniitem23
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''24'') AS moniname24
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''24'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''24''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''24''
        END
    END AS moniitem24
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''25'') AS moniname25
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''25'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''25''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''25''
        END
    END AS moniitem25
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''26'') AS moniname26
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''26'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''26''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''26''
        END
    END AS moniitem26
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''27'') AS moniname27
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''27'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''27''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''27''
        END
    END AS moniitem27
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''28'') AS moniname28
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''28'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''28''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''28''
        END
    END AS moniitem28
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''29'') AS moniname29
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''29'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''29''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''29''
        END
    END AS moniitem29
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''30'') AS moniname30
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''30'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''30''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''30''
        END
    END AS moniitem30
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''31'') AS moniname31
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''31'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''31''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''31''
        END
    END AS moniitem31
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''32'') AS moniname32
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''32'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''32''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''32''
        END
    END AS moniitem32
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''33'') AS moniname33
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''33'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''33''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''33''
        END
    END AS moniitem33
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''34'') AS moniname34
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''34'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''34''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''34''
        END
    END AS moniitem34
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''35'') AS moniname35
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''35'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''35''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''35''
        END
    END AS moniitem35
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''36'') AS moniname36
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''36'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''36''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''36''
        END
    END AS moniitem36
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''37'') AS moniname37
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''37'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''37''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''37''
        END
    END AS moniitem37
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''38'') AS moniname38
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''38'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''38''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''38''
        END
    END AS moniitem38
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''39'') AS moniname39
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''39'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''39''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''39''
        END
    END AS moniitem39
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''40'') AS moniname40
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''40'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''40''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''40''
        END
    END AS moniitem40
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''41'') AS moniname41
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''41'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''41''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''41''
        END
    END AS moniitem41
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''42'') AS moniname42
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''42'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''42''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''42''
        END
    END AS moniitem42
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''43'') AS moniname43
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''43'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''43''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''43''
        END
    END AS moniitem43
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''44'') AS moniname44
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''44'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''44''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''44''
        END
    END AS moniitem44
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''45'') AS moniname45
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''45'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''45''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''45''
        END
    END AS moniitem45
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''46'') AS moniname46
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''46'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''46''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''46''
        END
    END AS moniitem46
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''47'') AS moniname47
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''47'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''47''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''47''
        END
    END AS moniitem47
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''48'') AS moniname48
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''48'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''48''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''48''
        END
    END AS moniitem48
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''49'') AS moniname49
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''49'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''49''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''49''
        END
    END AS moniitem49
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''50'') AS moniname50
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''50'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''50''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''50''
        END
    END AS moniitem50
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''51'') AS moniname51
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''51'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''51''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''51''
        END
    END AS moniitem51
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''52'') AS moniname52
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''52'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''52''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''52''
        END
    END AS moniitem52
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''53'') AS moniname53
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''53'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''53''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''53''
        END
    END AS moniitem53
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''54'') AS moniname54
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''54'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''54''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''54''
        END
    END AS moniitem54
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''55'') AS moniname55
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''55'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''55''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''55''
        END
    END AS moniitem55
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''56'') AS moniname56
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''56'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''56''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''56''
        END
    END AS moniitem56
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''57'') AS moniname57
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''57'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''57''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''57''
        END
    END AS moniitem57
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''58'') AS moniname58
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''58'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''58''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''58''
        END
    END AS moniitem58
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''59'') AS moniname59
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''59'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''59''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''59''
        END
    END AS moniitem59
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''60'') AS moniname60
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''60'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''60''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''60''
        END
    END AS moniitem60
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''61'') AS moniname61
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''61'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''61''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''61''
        END
    END AS moniitem61
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''62'') AS moniname62
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''62'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''62''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''62''
        END
    END AS moniitem62
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''63'') AS moniname63
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''63'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''63''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''63''
        END
    END AS moniitem63
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''64'') AS moniname64
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''64'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''64''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''64''
        END
    END AS moniitem64
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''65'') AS moniname65
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''65'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''65''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''65''
        END
    END AS moniitem65
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''66'') AS moniname66
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''66'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''66''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''66''
        END
    END AS moniitem66
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''67'') AS moniname67
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''67'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''67''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''67''
        END
    END AS moniitem67
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''68'') AS moniname68
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''68'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''68''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''68''
        END
    END AS moniitem68
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''69'') AS moniname69
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''69'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''69''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''69''
        END
    END AS moniitem69
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''70'') AS moniname70
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''70'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''70''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''70''
        END
    END AS moniitem70
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''71'') AS moniname71
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''71'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''71''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''71''
        END
    END AS moniitem71
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''72'') AS moniname72
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''72'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''72''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''72''
        END
    END AS moniitem72
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''73'') AS moniname73
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''73'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''73''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''73''
        END
    END AS moniitem73
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''74'') AS moniname74
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''74'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''74''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''74''
        END
    END AS moniitem74
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''75'') AS moniname75
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''75'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''75''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''75''
        END
    END AS moniitem75
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''76'') AS moniname76
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''76'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''76''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''76''
        END
    END AS moniitem76
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''77'') AS moniname77
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''77'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''77''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''77''
        END
    END AS moniitem77
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''78'') AS moniname78
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''78'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''78''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''78''
        END
    END AS moniitem78
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''79'') AS moniname79
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''79'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''79''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''79''
        END
    END AS moniitem79
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''80'') AS moniname80
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''80'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''80''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''80''
        END
    END AS moniitem80
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''81'') AS moniname81
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''81'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''81''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''81''
        END
    END AS moniitem81
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''82'') AS moniname82
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''82'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''82''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''82''
        END
    END AS moniitem82
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''83'') AS moniname83
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''83'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''83''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''83''
        END
    END AS moniitem83
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''84'') AS moniname84
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''84'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''84''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''84''
        END
    END AS moniitem84
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''85'') AS moniname85
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''85'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''85''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''85''
        END
    END AS moniitem85
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''86'') AS moniname86
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''86'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''86''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''86''
        END
    END AS moniitem86
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''87'') AS moniname87
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''87'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''87''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''87''
        END
    END AS moniitem87
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''88'') AS moniname88
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''88'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''88''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''88''
        END
    END AS moniitem88
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''89'') AS moniname89
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''89'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''89''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''89''
        END
    END AS moniitem89
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''90'') AS moniname90
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''90'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''90''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''90''
        END
    END AS moniitem90
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''91'') AS moniname91
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''91'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''91''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''91''
        END
    END AS moniitem91
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''92'') AS moniname92
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''92'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''92''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''92''
        END
    END AS moniitem92
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''93'') AS moniname93
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''93'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''93''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''93''
        END
    END AS moniitem93
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''94'') AS moniname94
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''94'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''94''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''94''
        END
    END AS moniitem94
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''95'') AS moniname95
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''95'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''95''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''95''
        END
    END AS moniitem95
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''96'') AS moniname96
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''96'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''96''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''96''
        END
    END AS moniitem96
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''97'') AS moniname97
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''97'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''97''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''97''
        END
    END AS moniitem97
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''98'') AS moniname98
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''98'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''98''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''98''
        END
    END AS moniitem98
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''99'') AS moniname99
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''99'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''99''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''99''
        END
    END AS moniitem99
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''100'') AS moniname100
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''100'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''100''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''100''
        END
    END AS moniitem100
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''101'') AS moniname101
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''101'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''101''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''101''
        END
    END AS moniitem101
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''102'') AS moniname102
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''102'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''102''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''102''
        END
    END AS moniitem102
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''103'') AS moniname103
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''103'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''103''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''103''
        END
    END AS moniitem103
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''104'') AS moniname104
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''104'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''104''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''104''
        END
    END AS moniitem104
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''105'') AS moniname105
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''105'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''105''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''105''
        END
    END AS moniitem105
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''106'') AS moniname106
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''106'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''106''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''106''
        END
    END AS moniitem106
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''107'') AS moniname107
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''107'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''107''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''107''
        END
    END AS moniitem107
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''108'') AS moniname108
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''108'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''108''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''108''
        END
    END AS moniitem108
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''109'') AS moniname109
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''109'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''109''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''109''
        END
    END AS moniitem109
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''110'') AS moniname110
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''110'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''110''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''110''
        END
    END AS moniitem110
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''111'') AS moniname111
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''111'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''111''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''111''
        END
    END AS moniitem111
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''112'') AS moniname112
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''112'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''112''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''112''
        END
    END AS moniitem112
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''113'') AS moniname113
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''113'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''113''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''113''
        END
    END AS moniitem113
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''114'') AS moniname114
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''114'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''114''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''114''
        END
    END AS moniitem114
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''115'') AS moniname115
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''115'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''115''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''115''
        END
    END AS moniitem115
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''116'') AS moniname116
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''116'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''116''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''116''
        END
    END AS moniitem116
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''117'') AS moniname117
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''117'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''117''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''117''
        END
    END AS moniitem117
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''118'') AS moniname118
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''118'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''118''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''118''
        END
    END AS moniitem118
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''119'') AS moniname119
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''119'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''119''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''119''
        END
    END AS moniitem119
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''120'') AS moniname120
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''120'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''120''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''120''
        END
    END AS moniitem120
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''121'') AS moniname121
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''121'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''121''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''121''
        END
    END AS moniitem121
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''122'') AS moniname122
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''122'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''122''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''122''
        END
    END AS moniitem122
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''123'') AS moniname123
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''123'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''123''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''123''
        END
    END AS moniitem123
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''124'') AS moniname124
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''124'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''124''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''124''
        END
    END AS moniitem124
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''125'') AS moniname125
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''125'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''125''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''125''
        END
    END AS moniitem125
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''126'') AS moniname126
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''126'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''126''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''126''
        END
    END AS moniitem126
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''127'') AS moniname127
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''127'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''127''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''127''
        END
    END AS moniitem127
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''128'') AS moniname128
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''128'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''128''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''128''
        END
    END AS moniitem128
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''129'') AS moniname129
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''129'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''129''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''129''
        END
    END AS moniitem129
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''130'') AS moniname130
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''130'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''130''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''130''
        END
    END AS moniitem130
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''131'') AS moniname131
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''131'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''131''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''131''
        END
    END AS moniitem131
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''132'') AS moniname132
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''132'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''132''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''132''
        END
    END AS moniitem132
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''133'') AS moniname133
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''133'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''133''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''133''
        END
    END AS moniitem133
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''134'') AS moniname134
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''134'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''134''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''134''
        END
    END AS moniitem134
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''135'') AS moniname135
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''135'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''135''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''135''
        END
    END AS moniitem135
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''136'') AS moniname136
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''136'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''136''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''136''
        END
    END AS moniitem136
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''137'') AS moniname137
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''137'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''137''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''137''
        END
    END AS moniitem137
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''138'') AS moniname138
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''138'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''138''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''138''
        END
    END AS moniitem138
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''139'') AS moniname139
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''139'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''139''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''139''
        END
    END AS moniitem139
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''140'') AS moniname140
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''140'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''140''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''140''
        END
    END AS moniitem140
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''141'') AS moniname141
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''141'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''141''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''141''
        END
    END AS moniitem141
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''142'') AS moniname142
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''142'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''142''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''142''
        END
    END AS moniitem142
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''143'') AS moniname143
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''143'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''143''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''143''
        END
    END AS moniitem143
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''144'') AS moniname144
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''144'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''144''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''144''
        END
    END AS moniitem144
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''145'') AS moniname145
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''145'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''145''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''145''
        END
    END AS moniitem145
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''146'') AS moniname146
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''146'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''146''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''146''
        END
    END AS moniitem146
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''147'') AS moniname147
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''147'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''147''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''147''
        END
    END AS moniitem147
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''148'') AS moniname148
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''148'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''148''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''148''
        END
    END AS moniitem148
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''149'') AS moniname149
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''149'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''149''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''149''
        END
    END AS moniitem149
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''150'') AS moniname150
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''150'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''150''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''150''
        END
    END AS moniitem150
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''-1'') AS moniname151
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''-1'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''-1''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''-1''
        END
    END AS moniitem151
    ,(SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''-2'') AS moniname152
    ,CASE 
        WHEN (SELECT moni_data_name FROM sys_moni WHERE moni_data_no = ''-2'') IS NOT NULL THEN 
        CASE 
            WHEN ntss_db5_mm.monitor_data ->> ''-2''::TEXT <> ''-1'' THEN ntss_db5_mm.monitor_data ->> ''-2''
        END
    END AS moniitem152
    , to_char(ntss_db5_mm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    , ntss_db5_om.ord_no AS ordno --透析番号
        FROM
            ord_main ntss_db5_om
            JOIN mni_monitor ntss_db5_mm
                ON ntss_db5_mm.facility_cd = ntss_db5_om.facility_cd
                AND ntss_db5_mm.ord_no = ntss_db5_om.ord_no
                AND ntss_db5_mm.is_del = ''0''
            LEFT JOIN mst_machine ntss_db5_mst_m
                ON ntss_db5_mst_m.machine_no = ntss_db5_om.rst_machine_no
                AND ntss_db5_mst_m.facility_cd = ntss_db5_om.facility_cd
                AND ntss_db5_mst_m.is_del = ''0''
                AND ntss_db5_mst_m.is_disp = ''1''
            LEFT JOIN mst_bed ntss_db5_mst_b
                ON ntss_db5_om.rst_bed_cd = ntss_db5_mst_b.bed_cd
                AND ntss_db5_mst_b.is_del = ''0''
                AND ntss_db5_mst_b.is_disp = ''1''
        WHERE
            ntss_db5_om.facility_cd = @facilityCd
            AND ntss_db5_om.is_del = ''0''
            AND ntss_db5_om.ord_no = ANY (string_to_array(@paramList1, '','')::bigint[])
            AND ntss_db5_om.rst_dialysis_state BETWEEN ''1'' AND ''5''
            AND ntss_db5_mm.data_type IN (1,2,5,6);', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2440, 'SELECT
    m_m.in_hospital_cd_1 AS deviceno            --装置番号
    , m_m.machine_name AS devicename     --装置名称
    , m_mr.machine_serial AS deviceserial --製造番号
    , to_char(m_mr.event_reg_date, ''YYYYMMDD'') AS meintedate --測定日付
    , to_char(m_mr.event_reg_date, ''hh24mi'') AS meintetime   --測定時刻
    , m_mr.contents ->> ''47'' AS meinteresult                      --配管自己診断結果
    , '''' AS meintegen --減圧テスト
    , m_mr.contents ->> ''43'' AS meintemore  --配管系漏れ（陰圧)
    , m_mr.contents ->> ''44'' AS meinteymore --配管系漏れ（陽圧）
    , m_mr.contents ->> ''48'' AS meintejyo   --除水テスト
    , m_mr.contents ->> ''46'' AS meintebara  --バランステスト
    , m_mr.contents ->> ''45'' AS meinteetcf  --ＣＦフィルタ漏れ
    , m_mr.contents ->> ''49'' AS meinteetcf2 --ＣＦ２フィルタ漏れ
FROM
    mst_machine m_m
    INNER JOIN mnt_motion_record m_mr
        ON m_m.facility_cd = m_mr.facility_cd
        AND m_m.machine_type_cd = m_mr.machine_type_cd
        AND m_m.machine_serial = m_mr.machine_serial
WHERE
    m_m.facility_cd = @facilityCd
    AND m_m.is_del = ''0''
    AND m_m.is_disp = ''1''
    AND @fromDate <= m_mr.event_reg_date AND m_mr.event_reg_date < @toDate
    AND m_mr.test_type = 1
    AND m_mr.contents IS NOT NULL
    AND m_mr.contents <> ''{}'';
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2450, 'WITH
  elements AS (
    SELECT
      ctlno,
      setname,
      elemkey,
      datapattern,
      defaultvalue
    FROM
      jsonb_to_recordset(
        ''[
    {"ctlno":"1","setname":"静脈圧自動設定警報幅上限HD/ECUM","elemkey":"dev-A-0100","datapattern":"1","defaultvalue":"50","level1":"war","level2":"dev","level3":"A","level4":"100"},
    {"ctlno":"2","setname":"静脈圧自動設定警報幅下限HD/ECUM","elemkey":"dev-A-0101","datapattern":"1","defaultvalue":"-30","level1":"war","level2":"dev","level3":"A","level4":"101"},
    {"ctlno":"3","setname":"静脈圧自動設定警報限界上限","elemkey":"dev-A-0102","datapattern":"1","defaultvalue":"200","level1":"war","level2":"dev","level3":"A","level4":"102"},
    {"ctlno":"4","setname":"静脈圧自動設定警報限界下限","elemkey":"dev-A-0103","datapattern":"1","defaultvalue":"10","level1":"war","level2":"dev","level3":"A","level4":"103"},
    {"ctlno":"5","setname":"静脈圧固定警報上限","elemkey":"dev-A-0104","datapattern":"1","defaultvalue":"200","level1":"war","level2":"dev","level3":"A","level4":"104"},
    {"ctlno":"6","setname":"静脈圧固定警報下限","elemkey":"dev-A-0105","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"105"},
    {"ctlno":"7","setname":"静脈圧自動設定警報幅上限HDF/HF","elemkey":"dev-A-0106","datapattern":"1","defaultvalue":"70","level1":"war","level2":"dev","level3":"A","level4":"106"},
    {"ctlno":"8","setname":"静脈圧自動設定警報幅下限HDF/HF","elemkey":"dev-A-0107","datapattern":"1","defaultvalue":"-70","level1":"war","level2":"dev","level3":"A","level4":"107"},
    {"ctlno":"9","setname":"静脈圧固定警報上限準備回収","elemkey":"dev-A-0108","datapattern":"1","defaultvalue":"250","level1":"war","level2":"dev","level3":"A","level4":"108"},
    {"ctlno":"10","setname":"静脈圧固定警報下限準備回収","elemkey":"dev-A-0109","datapattern":"1","defaultvalue":"-200","level1":"war","level2":"dev","level3":"A","level4":"109"},
    {"ctlno":"11","setname":"静脈圧固定警報上限ＳＮ","elemkey":"dev-A-0110","datapattern":"1","defaultvalue":"400","level1":"war","level2":"dev","level3":"A","level4":"110"},
    {"ctlno":"12","setname":"静脈圧固定警報下限ＳＮ","elemkey":"dev-A-0111","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"111"},
    {"ctlno":"13","setname":"液圧自動設定警報幅上限HD/ECUM","elemkey":"dev-A-0112","datapattern":"1","defaultvalue":"50","level1":"war","level2":"dev","level3":"A","level4":"112"},
    {"ctlno":"14","setname":"液圧自動設定警報幅下限HD/ECUM","elemkey":"dev-A-0113","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"113"},
    {"ctlno":"15","setname":"液圧自動設定警報限界上限","elemkey":"dev-A-0114","datapattern":"1","defaultvalue":"300","level1":"war","level2":"dev","level3":"A","level4":"114"},
    {"ctlno":"16","setname":"液圧自動設定警報限界下限","elemkey":"dev-A-0115","datapattern":"1","defaultvalue":"-300","level1":"war","level2":"dev","level3":"A","level4":"115"},
    {"ctlno":"17","setname":"液圧固定警報上限","elemkey":"dev-A-0116","datapattern":"1","defaultvalue":"300","level1":"war","level2":"dev","level3":"A","level4":"116"},
    {"ctlno":"18","setname":"液圧固定警報下限","elemkey":"dev-A-0117","datapattern":"1","defaultvalue":"-300","level1":"war","level2":"dev","level3":"A","level4":"117"},
    {"ctlno":"19","setname":"液圧自動設定警報幅上限HDF/HF","elemkey":"dev-A-0118","datapattern":"1","defaultvalue":"70","level1":"war","level2":"dev","level3":"A","level4":"118"},
    {"ctlno":"20","setname":"液圧自動設定警報幅下限HDF/HF","elemkey":"dev-A-0119","datapattern":"1","defaultvalue":"-70","level1":"war","level2":"dev","level3":"A","level4":"119"},
    {"ctlno":"21","setname":"液圧自動設定警報幅上限ＳＮ","elemkey":"dev-A-0120","datapattern":"1","defaultvalue":"70","level1":"war","level2":"dev","level3":"A","level4":"120"},
    {"ctlno":"22","setname":"液圧自動設定警報幅下限ＳＮ","elemkey":"dev-A-0121","datapattern":"1","defaultvalue":"-70","level1":"war","level2":"dev","level3":"A","level4":"121"},
    {"ctlno":"23","setname":"液圧自動設定警報限界上限ＳＮ","elemkey":"dev-A-0122","datapattern":"1","defaultvalue":"300","level1":"war","level2":"dev","level3":"A","level4":"122"},
    {"ctlno":"24","setname":"液圧自動設定警報限界下限ＳＮ","elemkey":"dev-A-0123","datapattern":"1","defaultvalue":"-300","level1":"war","level2":"dev","level3":"A","level4":"123"},
    {"ctlno":"25","setname":"液圧固定警報上限ＳＮ","elemkey":"dev-A-0124","datapattern":"1","defaultvalue":"300","level1":"war","level2":"dev","level3":"A","level4":"124"},
    {"ctlno":"26","setname":"液圧固定警報下限ＳＮ","elemkey":"dev-A-0125","datapattern":"1","defaultvalue":"-300","level1":"war","level2":"dev","level3":"A","level4":"125"},
    {"ctlno":"27","setname":"ＴＭＰ自動追従警報幅上限HD/ECUM","elemkey":"dev-A-0126","datapattern":"1","defaultvalue":"20","level1":"war","level2":"dev","level3":"A","level4":"126"},
    {"ctlno":"28","setname":"ＴＭＰ自動追従警報幅下限HD/ECUM","elemkey":"dev-A-0127","datapattern":"1","defaultvalue":"-20","level1":"war","level2":"dev","level3":"A","level4":"127"},
    {"ctlno":"29","setname":"ＴＭＰ自動設定警報幅上限HD/ECUM","elemkey":"dev-A-0128","datapattern":"1","defaultvalue":"50","level1":"war","level2":"dev","level3":"A","level4":"128"},
    {"ctlno":"30","setname":"ＴＭＰ自動設定警報幅下限HD/ECUM","elemkey":"dev-A-0129","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"129"},
    {"ctlno":"31","setname":"ＴＭＰ自動設定警報限界上限","elemkey":"dev-A-0130","datapattern":"1","defaultvalue":"500","level1":"war","level2":"dev","level3":"A","level4":"130"},
    {"ctlno":"32","setname":"ＴＭＰ自動設定警報限界下限","elemkey":"dev-A-0131","datapattern":"1","defaultvalue":"-30","level1":"war","level2":"dev","level3":"A","level4":"131"},
    {"ctlno":"33","setname":"ＴＭＰ固定警報上限","elemkey":"dev-A-0132","datapattern":"1","defaultvalue":"300","level1":"war","level2":"dev","level3":"A","level4":"132"},
    {"ctlno":"34","setname":"ＴＭＰ固定警報下限","elemkey":"dev-A-0133","datapattern":"1","defaultvalue":"-30","level1":"war","level2":"dev","level3":"A","level4":"133"},
    {"ctlno":"35","setname":"ＴＭＰ自動追従警報幅上限HDF/HF","elemkey":"dev-A-0134","datapattern":"1","defaultvalue":"50","level1":"war","level2":"dev","level3":"A","level4":"134"},
    {"ctlno":"36","setname":"ＴＭＰ自動追従警報幅下限HDF/HF","elemkey":"dev-A-0135","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"135"},
    {"ctlno":"37","setname":"ＴＭＰ自動設定警報幅上限HDF/HF","elemkey":"dev-A-0136","datapattern":"1","defaultvalue":"70","level1":"war","level2":"dev","level3":"A","level4":"136"},
    {"ctlno":"38","setname":"ＴＭＰ自動設定警報幅下限HDF/HF","elemkey":"dev-A-0137","datapattern":"1","defaultvalue":"-70","level1":"war","level2":"dev","level3":"A","level4":"137"},
    {"ctlno":"39","setname":"ＴＭＰ自動追従警報幅上限ＳＮ","elemkey":"dev-A-0138","datapattern":"1","defaultvalue":"50","level1":"war","level2":"dev","level3":"A","level4":"138"},
    {"ctlno":"40","setname":"ＴＭＰ自動追従警報幅下限ＳＮ","elemkey":"dev-A-0139","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"139"},
    {"ctlno":"41","setname":"ＴＭＰ自動設定警報幅上限ＳＮ","elemkey":"dev-A-0140","datapattern":"1","defaultvalue":"70","level1":"war","level2":"dev","level3":"A","level4":"140"},
    {"ctlno":"42","setname":"ＴＭＰ自動設定警報幅下限ＳＮ","elemkey":"dev-A-0141","datapattern":"1","defaultvalue":"-70","level1":"war","level2":"dev","level3":"A","level4":"141"},
    {"ctlno":"43","setname":"ＴＭＰ自動設定警報限界上限ＳＮ","elemkey":"dev-A-0142","datapattern":"1","defaultvalue":"500","level1":"war","level2":"dev","level3":"A","level4":"142"},
    {"ctlno":"44","setname":"ＴＭＰ自動設定警報限界下限ＳＮ","elemkey":"dev-A-0143","datapattern":"1","defaultvalue":"-30","level1":"war","level2":"dev","level3":"A","level4":"143"},
    {"ctlno":"45","setname":"ＴＭＰ固定警報上限ＳＮ","elemkey":"dev-A-0144","datapattern":"1","defaultvalue":"500","level1":"war","level2":"dev","level3":"A","level4":"144"},
    {"ctlno":"46","setname":"ＴＭＰ固定警報下限ＳＮ","elemkey":"dev-A-0145","datapattern":"1","defaultvalue":"-30","level1":"war","level2":"dev","level3":"A","level4":"145"},
    {"ctlno":"47","setname":"ダイアライザー差圧自動設定警報幅上限HD/ECUM","elemkey":"dev-A-0146","datapattern":"1","defaultvalue":"250","level1":"war","level2":"dev","level3":"A","level4":"146"},
    {"ctlno":"48","setname":"ダイアライザー差圧自動設定警報幅下限HD/ECUM","elemkey":"dev-A-0147","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"147"},
    {"ctlno":"49","setname":"ダイアライザー差圧固定警報上限","elemkey":"dev-A-0148","datapattern":"1","defaultvalue":"250","level1":"war","level2":"dev","level3":"A","level4":"148"},
    {"ctlno":"50","setname":"ダイアライザー差圧固定警報下限","elemkey":"dev-A-0149","datapattern":"1","defaultvalue":"0","level1":"war","level2":"dev","level3":"A","level4":"149"},
    {"ctlno":"51","setname":"ダイアライザー差圧自動設定警報幅上限HDF/HF","elemkey":"dev-A-0150","datapattern":"1","defaultvalue":"200","level1":"war","level2":"dev","level3":"A","level4":"150"},
    {"ctlno":"52","setname":"ダイアライザー差圧自動設定警報幅下限HDF/HF","elemkey":"dev-A-0151","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"151"},
    {"ctlno":"53","setname":"ダイアライザー入口圧自動設定警報幅上限HD/ECUM","elemkey":"dev-A-0152","datapattern":"1","defaultvalue":"50","level1":"war","level2":"dev","level3":"A","level4":"152"},
    {"ctlno":"54","setname":"ダイアライザー入口圧自動設定警報幅下限HD/ECUM","elemkey":"dev-A-0153","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"153"},
    {"ctlno":"55","setname":"ダイアライザー入口圧自動設定警報限界上限","elemkey":"dev-A-0154","datapattern":"1","defaultvalue":"350","level1":"war","level2":"dev","level3":"A","level4":"154"},
    {"ctlno":"56","setname":"ダイアライザー入口圧自動設定警報限界下限","elemkey":"dev-A-0155","datapattern":"1","defaultvalue":"0","level1":"war","level2":"dev","level3":"A","level4":"155"},
    {"ctlno":"57","setname":"ダイアライザー入口圧固定警報上限","elemkey":"dev-A-0156","datapattern":"1","defaultvalue":"350","level1":"war","level2":"dev","level3":"A","level4":"156"},
    {"ctlno":"58","setname":"ダイアライザー入口圧固定警報下限","elemkey":"dev-A-0157","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"157"},
    {"ctlno":"59","setname":"ダイアライザー入口圧自動設定警報幅上限HDF/HF","elemkey":"dev-A-0158","datapattern":"1","defaultvalue":"70","level1":"war","level2":"dev","level3":"A","level4":"158"},
    {"ctlno":"60","setname":"ダイアライザー入口圧自動設定警報幅下限HDF/HF","elemkey":"dev-A-0159","datapattern":"1","defaultvalue":"-70","level1":"war","level2":"dev","level3":"A","level4":"159"},
    {"ctlno":"61","setname":"ダイアライザー入口圧固定警報上限準備回収","elemkey":"dev-A-0160","datapattern":"1","defaultvalue":"400","level1":"war","level2":"dev","level3":"A","level4":"160"},
    {"ctlno":"62","setname":"ダイアライザー入口圧固定警報下限準備回収","elemkey":"dev-A-0161","datapattern":"1","defaultvalue":"-200","level1":"war","level2":"dev","level3":"A","level4":"161"},
    {"ctlno":"63","setname":"ダイアライザー入口圧固定警報上限ＳＮ","elemkey":"dev-A-0162","datapattern":"1","defaultvalue":"500","level1":"war","level2":"dev","level3":"A","level4":"162"},
    {"ctlno":"64","setname":"ダイアライザー入口圧固定警報下限ＳＮ","elemkey":"dev-A-0163","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"163"},
    {"ctlno":"69","setname":"ＴＭＰゼロ補正警報上限HD","elemkey":"dev-A-0168","datapattern":"1","defaultvalue":"50","level1":"ope","level2":"dev","level3":"A","level4":"168"},
    {"ctlno":"70","setname":"ＴＭＰゼロ補正警報下限HD","elemkey":"dev-A-0169","datapattern":"1","defaultvalue":"-50","level1":"ope","level2":"dev","level3":"A","level4":"169"},
    {"ctlno":"72","setname":"ＴＭＰゼロ補正警報上限ECUM","elemkey":"dev-A-0171","datapattern":"1","defaultvalue":"50","level1":"ope","level2":"dev","level3":"A","level4":"171"},
    {"ctlno":"73","setname":"ＴＭＰゼロ補正警報下限ECUM","elemkey":"dev-A-0172","datapattern":"1","defaultvalue":"-50","level1":"ope","level2":"dev","level3":"A","level4":"172"},
    {"ctlno":"75","setname":"ＴＭＰゼロ補正警報上限HDF","elemkey":"dev-A-0174","datapattern":"1","defaultvalue":"50","level1":"ope","level2":"dev","level3":"A","level4":"174"},
    {"ctlno":"76","setname":"ＴＭＰゼロ補正警報下限HDF","elemkey":"dev-A-0175","datapattern":"1","defaultvalue":"-50","level1":"ope","level2":"dev","level3":"A","level4":"175"},
    {"ctlno":"78","setname":"ＴＭＰゼロ補正警報上限HF","elemkey":"dev-A-0177","datapattern":"1","defaultvalue":"50","level1":"ope","level2":"dev","level3":"A","level4":"177"},
    {"ctlno":"79","setname":"ＴＭＰゼロ補正警報下限HF","elemkey":"dev-A-0178","datapattern":"1","defaultvalue":"-50","level1":"ope","level2":"dev","level3":"A","level4":"178"},
    {"ctlno":"80","setname":"血流量操作範囲上限","elemkey":"dev-A-0179","datapattern":"1","defaultvalue":"300","level1":"ope","level2":"dev","level3":"A","level4":"179"},
    {"ctlno":"82","setname":"除水速度操作範囲上限","elemkey":"dev-A-0181","datapattern":"1","defaultvalue":"2","level1":"ope","level2":"dev","level3":"A","level4":"181"},
    {"ctlno":"83","setname":"透析液温度操作範囲上限","elemkey":"dev-A-0182","datapattern":"1","defaultvalue":"40","level1":"ope","level2":"dev","level3":"A","level4":"182"},
    {"ctlno":"84","setname":"透析液温度操作範囲下限","elemkey":"dev-A-0183","datapattern":"1","defaultvalue":"33","level1":"ope","level2":"dev","level3":"A","level4":"183"},
    {"ctlno":"86","setname":"前補液 補液速度操作範囲上限(HDF)","elemkey":"dev-A-0185","datapattern":"1","defaultvalue":"6","level1":"ope","level2":"dev","level3":"A","level4":"185"},
    {"ctlno":"87","setname":"前補液 補液速度操作範囲上限(HF)","elemkey":"dev-A-0186","datapattern":"1","defaultvalue":"6","level1":"ope","level2":"dev","level3":"A","level4":"186"},
    {"ctlno":"88","setname":"血圧自動測定間隔","elemkey":"dev-A-0190","datapattern":"1","defaultvalue":"30","level1":"bp","level2":"dev","level3":"A","level4":"190"},
    {"ctlno":"89","setname":"血圧ｶﾌ選択","elemkey":"dev-A-0191","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"191"},
    {"ctlno":"90","setname":"昇圧値","elemkey":"dev-A-0192","datapattern":"1","defaultvalue":"200","level1":"bp","level2":"dev","level3":"A","level4":"192"},
    {"ctlno":"91","setname":"昇圧方法選択","elemkey":"dev-A-0193","datapattern":"1","defaultvalue":"1","level1":"bp","level2":"dev","level3":"A","level4":"193"},
    {"ctlno":"92","setname":"血圧連続測定動作選択","elemkey":"dev-A-0194","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"194"},
    {"ctlno":"93","setname":"最高血圧上限","elemkey":"dev-A-0211","datapattern":"1","defaultvalue":"200","level1":"bp","level2":"dev","level3":"A","level4":"211"},
    {"ctlno":"94","setname":"最高血圧下限","elemkey":"dev-A-0212","datapattern":"1","defaultvalue":"80","level1":"bp","level2":"dev","level3":"A","level4":"212"},
    {"ctlno":"95","setname":"最低血圧上限","elemkey":"dev-A-0213","datapattern":"1","defaultvalue":"160","level1":"bp","level2":"dev","level3":"A","level4":"213"},
    {"ctlno":"96","setname":"最低血圧下限","elemkey":"dev-A-0214","datapattern":"1","defaultvalue":"50","level1":"bp","level2":"dev","level3":"A","level4":"214"},
    {"ctlno":"97","setname":"平均血圧上限","elemkey":"dev-A-0215","datapattern":"1","defaultvalue":"180","level1":"bp","level2":"dev","level3":"A","level4":"215"},
    {"ctlno":"98","setname":"平均血圧下限","elemkey":"dev-A-0216","datapattern":"1","defaultvalue":"60","level1":"bp","level2":"dev","level3":"A","level4":"216"},
    {"ctlno":"99","setname":"脈拍数上限","elemkey":"dev-A-0217","datapattern":"1","defaultvalue":"170","level1":"bp","level2":"dev","level3":"A","level4":"217"},
    {"ctlno":"100","setname":"脈拍数下限","elemkey":"dev-A-0218","datapattern":"1","defaultvalue":"50","level1":"bp","level2":"dev","level3":"A","level4":"218"},
    {"ctlno":"101","setname":"最高血圧上限警報 BP 動作選択","elemkey":"dev-A-0219","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"219"},
    {"ctlno":"102","setname":"最高血圧下限警報 BP 動作選択","elemkey":"dev-A-0220","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"220"},
    {"ctlno":"103","setname":"最高血圧上限警報 除水 動作選択","elemkey":"dev-A-0221","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"221"},
    {"ctlno":"104","setname":"最高血圧下限警報 除水 動作選択","elemkey":"dev-A-0222","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"222"},
    {"ctlno":"105","setname":"最高血圧上限警報 Na注入 動作選択","elemkey":"dev-A-0223","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"223"},
    {"ctlno":"106","setname":"最高血圧下限警報 Na注入 動作選択","elemkey":"dev-A-0224","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"224"},
    {"ctlno":"107","setname":"最高血圧上限警報 補液 動作選択","elemkey":"dev-A-0225","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"225"},
    {"ctlno":"108","setname":"最高血圧下限警報 補液 動作選択","elemkey":"dev-A-0226","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"226"},
    {"ctlno":"109","setname":"最高血圧上限警報 BP 速度","elemkey":"dev-A-0227","datapattern":"1","defaultvalue":"100","level1":"bp","level2":"dev","level3":"A","level4":"227"},
    {"ctlno":"110","setname":"最高血圧下限警報 BP 速度","elemkey":"dev-A-0228","datapattern":"1","defaultvalue":"100","level1":"bp","level2":"dev","level3":"A","level4":"228"},
    {"ctlno":"111","setname":"最高血圧上限警報 除水 速度","elemkey":"dev-A-0229","datapattern":"1","defaultvalue":"0.1","level1":"bp","level2":"dev","level3":"A","level4":"229"},
    {"ctlno":"112","setname":"最高血圧下限警報 除水 速度","elemkey":"dev-A-0230","datapattern":"1","defaultvalue":"0.1","level1":"bp","level2":"dev","level3":"A","level4":"230"},
    {"ctlno":"113","setname":"最高血圧上限警報 Na注入 速度","elemkey":"dev-A-0231","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"231"},
    {"ctlno":"114","setname":"最高血圧下限警報 Na注入 速度","elemkey":"dev-A-0232","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"232"},
    {"ctlno":"115","setname":"最高血圧上限警報 補液 速度","elemkey":"dev-A-0233","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"233"},
    {"ctlno":"116","setname":"最高血圧下限警報 補液 速度","elemkey":"dev-A-0234","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"234"},
    {"ctlno":"117","setname":"警報連動測定開始時刻","elemkey":"dev-A-0235","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"235"},
    {"ctlno":"118","setname":"治療条件連動測定時刻","elemkey":"dev-A-0236","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"236"},
    {"ctlno":"119","setname":"血圧測定自動停止(警報発生)","elemkey":"dev-A-0237","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"237"},
    {"ctlno":"120","setname":"血圧測定自動停止(条件変更)","elemkey":"dev-A-0238","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"238"},
    {"ctlno":"121","setname":"高速測定選択","elemkey":"dev-A-0239","datapattern":"1","defaultvalue":"1","level1":"bp","level2":"dev","level3":"A","level4":"239"},
    {"ctlno":"122","setname":"ＴＭＰ監視モード","elemkey":"dev-A-0240","datapattern":"1","defaultvalue":"0","level1":"war","level2":"dev","level3":"A","level4":"240"},
    {"ctlno":"123","setname":"ＴＭＰゼロ補正の選択","elemkey":"dev-A-0241","datapattern":"1","defaultvalue":"0","level1":"ope","level2":"dev","level3":"A","level4":"241"},
    {"ctlno":"124","setname":"静脈圧自動設定警報監視有無","elemkey":"dev-A-0242","datapattern":"1","defaultvalue":"1","level1":"war","level2":"dev","level3":"A","level4":"242"},
    {"ctlno":"125","setname":"ダイアライザー血液入口圧自動設定警報監視有無","elemkey":"dev-A-0243","datapattern":"1","defaultvalue":"1","level1":"war","level2":"dev","level3":"A","level4":"243"},
    {"ctlno":"126","setname":"透析液圧自動設定警報監視有無","elemkey":"dev-A-0244","datapattern":"1","defaultvalue":"1","level1":"war","level2":"dev","level3":"A","level4":"244"},
    {"ctlno":"127","setname":"ＴＭＰ自動設定警報監視有無","elemkey":"dev-A-0245","datapattern":"1","defaultvalue":"1","level1":"war","level2":"dev","level3":"A","level4":"245"},
    {"ctlno":"128","setname":"差圧自動設定警報監視有無","elemkey":"dev-A-0246","datapattern":"1","defaultvalue":"1","level1":"war","level2":"dev","level3":"A","level4":"246"},
    {"ctlno":"129","setname":"Ｎａ濃度自動設定警報監視有無","elemkey":"dev-A-0247","datapattern":"1","defaultvalue":"1","level1":"war","level2":"dev","level3":"A","level4":"247"},
    {"ctlno":"130","setname":"透析液濃度プログラム自動設定警報幅上限","elemkey":"dev-A-0250","datapattern":"1","defaultvalue":"5","level1":"cpro","level2":"dev","level3":"A","level4":"250"},
    {"ctlno":"131","setname":"透析液濃度プログラム自動設定警報幅下限","elemkey":"dev-A-0251","datapattern":"1","defaultvalue":"-5","level1":"cpro","level2":"dev","level3":"A","level4":"251"},
    {"ctlno":"132","setname":"Ｂ液濃度プログラム自動設定警報幅上限","elemkey":"dev-A-0252","datapattern":"1","defaultvalue":"5","level1":"cpro","level2":"dev","level3":"A","level4":"252"},
    {"ctlno":"133","setname":"Ｂ液濃度プログラム自動設定警報幅下限","elemkey":"dev-A-0253","datapattern":"1","defaultvalue":"-5","level1":"cpro","level2":"dev","level3":"A","level4":"253"},
    {"ctlno":"134","setname":"Ｎａ濃度自動設定警報幅上限","elemkey":"dev-A-0254","datapattern":"1","defaultvalue":"5","level1":"war","level2":"dev","level3":"A","level4":"254"},
    {"ctlno":"135","setname":"Ｎａ濃度自動設定警報幅下限","elemkey":"dev-A-0255","datapattern":"1","defaultvalue":"-5","level1":"war","level2":"dev","level3":"A","level4":"255"},
    {"ctlno":"136","setname":"Ｎａ濃度固定警報上限","elemkey":"dev-A-0256","datapattern":"1","defaultvalue":"190","level1":"war","level2":"dev","level3":"A","level4":"256"},
    {"ctlno":"137","setname":"Ｎａ濃度固定警報下限","elemkey":"dev-A-0257","datapattern":"1","defaultvalue":"120","level1":"war","level2":"dev","level3":"A","level4":"257"},
    {"ctlno":"138","setname":"アクセス再循環測定使用選択","elemkey":"dev-A-0258","datapattern":"1","defaultvalue":"0","level1":"bv","level2":"dev","level3":"A","level4":"258"},
    {"ctlno":"139","setname":"自動測定1","elemkey":"dev-A-0259","datapattern":"1","defaultvalue":"0","level1":"bv","level2":"dev","level3":"A","level4":"259"},
    {"ctlno":"140","setname":"⊿ＢＶ低下警報点１","elemkey":"dev-A-0260","datapattern":"1","defaultvalue":"-10","level1":"bv","level2":"dev","level3":"A","level4":"260"},
    {"ctlno":"141","setname":"⊿ＢＶ低下警報点２","elemkey":"dev-A-0261","datapattern":"1","defaultvalue":"-25","level1":"bv","level2":"dev","level3":"A","level4":"261"},
    {"ctlno":"142","setname":"⊿BV変化率警報点","elemkey":"dev-A-0262","datapattern":"1","defaultvalue":"-3","level1":"bv","level2":"dev","level3":"A","level4":"262"},
    {"ctlno":"143","setname":"ブラッドボリューム計使用の選択","elemkey":"dev-A-0267","datapattern":"1","defaultvalue":"1","level1":"bv","level2":"dev","level3":"A","level4":"267"},
    {"ctlno":"144","setname":"⊿ＢＶ除水低下速度","elemkey":"dev-A-0277","datapattern":"1","defaultvalue":"0","level1":"bv","level2":"dev","level3":"A","level4":"277"},
    {"ctlno":"145","setname":"⊿ＢＶ除水低下遅延時間","elemkey":"dev-A-0278","datapattern":"1","defaultvalue":"5","level1":"bv","level2":"dev","level3":"A","level4":"278"},
    {"ctlno":"146","setname":"再循環率報知","elemkey":"dev-A-0281","datapattern":"1","defaultvalue":"0","level1":"bv","level2":"dev","level3":"A","level4":"281"},
    {"ctlno":"185","setname":"同時脱血 脱血量","elemkey":"dev-A-0331","datapattern":"1","defaultvalue":"150","level1":"dfas","level2":"dev","level3":"A","level4":"331"},
    {"ctlno":"186","setname":"片側脱血への切替え透析液圧","elemkey":"dev-A-0332","datapattern":"1","defaultvalue":"-200","level1":"dfas","level2":"dev","level3":"A","level4":"332"},
    {"ctlno":"187","setname":"脱血速度","elemkey":"dev-A-0333","datapattern":"1","defaultvalue":"100","level1":"dfas","level2":"dev","level3":"A","level4":"333"},
    {"ctlno":"188","setname":"片側脱血(除水なし) 脱血量","elemkey":"dev-A-0334","datapattern":"1","defaultvalue":"150","level1":"dfas","level2":"dev","level3":"A","level4":"334"},
    {"ctlno":"190","setname":"補液速度","elemkey":"dev-A-0336","datapattern":"1","defaultvalue":"100","level1":"ope","level2":"dev","level3":"A","level4":"336"},
    {"ctlno":"191","setname":"補液量","elemkey":"dev-A-0337","datapattern":"1","defaultvalue":"100","level1":"ope","level2":"dev","level3":"A","level4":"337"},
    {"ctlno":"192","setname":"片側脱血(除水あり) 脱血量","elemkey":"dev-A-0338","datapattern":"1","defaultvalue":"50","level1":"dfas","level2":"dev","level3":"A","level4":"338"},
    {"ctlno":"193","setname":"脱血方法選択","elemkey":"dev-A-0339","datapattern":"1","defaultvalue":"2","level1":"dfas","level2":"dev","level3":"A","level4":"339"},
    {"ctlno":"223","setname":"自動回収 使用液量","elemkey":"dev-A-0370","datapattern":"1","defaultvalue":"200","level1":"pri","level2":"dev","level3":"A","level4":"370"},
    {"ctlno":"224","setname":"自動回収 流速","elemkey":"dev-A-0371","datapattern":"1","defaultvalue":"100","level1":"pri","level2":"dev","level3":"A","level4":"371"},
    {"ctlno":"225","setname":"自動回収 血液判別器による終了選択","elemkey":"dev-A-0372","datapattern":"1","defaultvalue":"0","level1":"pri","level2":"dev","level3":"A","level4":"372"},
    {"ctlno":"226","setname":"静脈側返血速度","elemkey":"dev-A-0373","datapattern":"1","defaultvalue":"100","level1":"dfas","level2":"dev","level3":"A","level4":"373"},
    {"ctlno":"227","setname":"静脈側最大返血量","elemkey":"dev-A-0374","datapattern":"1","defaultvalue":"250","level1":"dfas","level2":"dev","level3":"A","level4":"374"},
    {"ctlno":"228","setname":"動脈側最大返血量","elemkey":"dev-A-0376","datapattern":"1","defaultvalue":"30","level1":"dfas","level2":"dev","level3":"A","level4":"376"},
    {"ctlno":"229","setname":"静脈側返血 血液判別器使用選択","elemkey":"dev-A-0377","datapattern":"1","defaultvalue":"0","level1":"dfas","level2":"dev","level3":"A","level4":"377"},
    {"ctlno":"230","setname":"動脈側返血 血液判別器使用選択","elemkey":"dev-A-0378","datapattern":"1","defaultvalue":"0","level1":"dfas","level2":"dev","level3":"A","level4":"378"},
    {"ctlno":"234","setname":"補液量設定値制限(OHDF・OHF用)","elemkey":"dev-A-0383","datapattern":"1","defaultvalue":"1","level1":"ope","level2":"dev","level3":"A","level4":"383"},
    {"ctlno":"235","setname":"AFBF 補液比率使用選択","elemkey":"dev-A-0384","datapattern":"1","defaultvalue":"1","level1":"ope","level2":"dev","level3":"A","level4":"384"},
    {"ctlno":"236","setname":"AFBF 補液比率","elemkey":"dev-A-0385","datapattern":"1","defaultvalue":"13","level1":"ope","level2":"dev","level3":"A","level4":"385"},
    {"ctlno":"237","setname":"補液速度設定範囲上限(AFBF)","elemkey":"dev-A-0386","datapattern":"1","defaultvalue":"2.5","level1":"ope","level2":"dev","level3":"A","level4":"386"},
    {"ctlno":"238","setname":"補液速度設定範囲下限(AFBF)","elemkey":"dev-A-0387","datapattern":"1","defaultvalue":"1","level1":"ope","level2":"dev","level3":"A","level4":"387"},
    {"ctlno":"240","setname":"OHDF/OHF補液計算優先項目選択","elemkey":"dev-A-0389","datapattern":"1","defaultvalue":"0","level1":"ope","level2":"dev","level3":"A","level4":"389"},
    {"ctlno":"242","setname":"ＴＭＰゼロ補正警報上限OHDF","elemkey":"dev-A-0391","datapattern":"1","defaultvalue":"50","level1":"ope","level2":"dev","level3":"A","level4":"391"},
    {"ctlno":"243","setname":"ＴＭＰゼロ補正警報下限OHDF","elemkey":"dev-A-0392","datapattern":"1","defaultvalue":"-50","level1":"ope","level2":"dev","level3":"A","level4":"392"},
    {"ctlno":"245","setname":"ＴＭＰゼロ補正警報上限OHF","elemkey":"dev-A-0394","datapattern":"1","defaultvalue":"50","level1":"ope","level2":"dev","level3":"A","level4":"394"},
    {"ctlno":"246","setname":"ＴＭＰゼロ補正警報下限OHF","elemkey":"dev-A-0395","datapattern":"1","defaultvalue":"-50","level1":"ope","level2":"dev","level3":"A","level4":"395"},
    {"ctlno":"247","setname":"前補液 補液速度操作範囲上限(OHDF)","elemkey":"dev-A-0396","datapattern":"1","defaultvalue":"12","level1":"ope","level2":"dev","level3":"A","level4":"396"},
    {"ctlno":"248","setname":"前補液 補液速度操作範囲上限(OHF)","elemkey":"dev-A-0397","datapattern":"1","defaultvalue":"12","level1":"ope","level2":"dev","level3":"A","level4":"397"},
    {"ctlno":"249","setname":"補液開始遅延時間","elemkey":"dev-A-0398","datapattern":"1","defaultvalue":"0","level1":"ope","level2":"dev","level3":"A","level4":"398"},
    {"ctlno":"280","setname":"前補液 補液速度操作範囲上限(HD+補液)","elemkey":"dev-B-0030","datapattern":"1","defaultvalue":"12","level1":"ope","level2":"dev","level3":"B","level4":"030"},
    {"ctlno":"281","setname":"後補液 補液速度操作範囲上限(HDF)","elemkey":"dev-B-0031","datapattern":"1","defaultvalue":"6","level1":"ope","level2":"dev","level3":"B","level4":"031"},
    {"ctlno":"282","setname":"後補液 補液速度操作範囲上限(HF)","elemkey":"dev-B-0032","datapattern":"1","defaultvalue":"6","level1":"ope","level2":"dev","level3":"B","level4":"032"},
    {"ctlno":"283","setname":"後補液 補液速度操作範囲上限(HD+補液)","elemkey":"dev-B-0033","datapattern":"1","defaultvalue":"6","level1":"ope","level2":"dev","level3":"B","level4":"033"},
    {"ctlno":"284","setname":"後補液 補液速度操作範囲上限(OHDF)","elemkey":"dev-B-0034","datapattern":"1","defaultvalue":"6","level1":"ope","level2":"dev","level3":"B","level4":"034"},
    {"ctlno":"285","setname":"後補液 補液速度操作範囲上限(OHF)","elemkey":"dev-B-0035","datapattern":"1","defaultvalue":"6","level1":"ope","level2":"dev","level3":"B","level4":"035"},
    {"ctlno":"286","setname":"治療開始時血流量使用有無","elemkey":"dev-B-0036","datapattern":"1","defaultvalue":"1","level1":"dfas","level2":"dev","level3":"B","level4":"036"},
    {"ctlno":"287","setname":"ＴＭＰゼロ補正警報上限(HD+補液)","elemkey":"dev-B-0037","datapattern":"1","defaultvalue":"50","level1":"ope","level2":"dev","level3":"B","level4":"037"},
    {"ctlno":"288","setname":"ＴＭＰゼロ補正警報下限(HD+補液)","elemkey":"dev-B-0038","datapattern":"1","defaultvalue":"-50","level1":"ope","level2":"dev","level3":"B","level4":"038"},
    {"ctlno":"289","setname":"プライミング補助動脈充填液量","elemkey":"pat-A-0219","datapattern":"1","defaultvalue":"200","level1":"pri","level2":"pat","level3":"A","level4":"219"},
    {"ctlno":"290","setname":"プライミング補助動脈充填流速","elemkey":"pat-A-0220","datapattern":"1","defaultvalue":"100","level1":"pri","level2":"pat","level3":"A","level4":"220"},
    {"ctlno":"291","setname":"プライミング補助静脈充填液量","elemkey":"pat-A-0221","datapattern":"1","defaultvalue":"200","level1":"pri","level2":"pat","level3":"A","level4":"221"},
    {"ctlno":"292","setname":"プライミング補助静脈充填流速","elemkey":"pat-A-0222","datapattern":"1","defaultvalue":"100","level1":"pri","level2":"pat","level3":"A","level4":"222"},
    {"ctlno":"293","setname":"プライミング補助気泡抜き液量","elemkey":"pat-A-0223","datapattern":"1","defaultvalue":"400","level1":"pri","level2":"pat","level3":"A","level4":"223"},
    {"ctlno":"294","setname":"プライミング補助気泡抜き流速","elemkey":"pat-A-0224","datapattern":"1","defaultvalue":"300","level1":"pri","level2":"pat","level3":"A","level4":"224"},
    {"ctlno":"295","setname":"プライミング補助動脈充填後継続の有無","elemkey":"pat-A-0225","datapattern":"1","defaultvalue":"0","level1":"pri","level2":"pat","level3":"A","level4":"225"},
    {"ctlno":"296","setname":"プライミング補助静脈充填後継続の有無","elemkey":"pat-A-0226","datapattern":"1","defaultvalue":"0","level1":"pri","level2":"pat","level3":"A","level4":"226"},
    {"ctlno":"297","setname":"プライミング補助気泡抜き間欠動作選択","elemkey":"pat-A-0227","datapattern":"1","defaultvalue":"0","level1":"pri","level2":"pat","level3":"A","level4":"227"},
    {"ctlno":"298","setname":"プライミング補助液交換量","elemkey":"pat-A-0228","datapattern":"1","defaultvalue":"800","level1":"pri","level2":"pat","level3":"A","level4":"228"},
    {"ctlno":"299","setname":"プライミング補助間欠動作動作時間","elemkey":"pat-A-0229","datapattern":"1","defaultvalue":"2","level1":"pri","level2":"pat","level3":"A","level4":"229"},
    {"ctlno":"300","setname":"プライミング補助間欠動作停止時間","elemkey":"pat-A-0230","datapattern":"1","defaultvalue":"1","level1":"pri","level2":"pat","level3":"A","level4":"230"},
    {"ctlno":"301","setname":"自動プライミング開始時間","elemkey":"pat-A-0231","datapattern":"1","defaultvalue":"420","level1":"pri","level2":"pat","level3":"A","level4":"231"},
    {"ctlno":"302","setname":"自動プライミング落差時間","elemkey":"pat-A-0232","datapattern":"1","defaultvalue":"40","level1":"pri","level2":"pat","level3":"A","level4":"232"},
    {"ctlno":"303","setname":"自動プライミング送液液量","elemkey":"pat-A-0233","datapattern":"1","defaultvalue":"250","level1":"pri","level2":"pat","level3":"A","level4":"233"},
    {"ctlno":"304","setname":"自動プライミング送液流速1回目","elemkey":"pat-A-0234","datapattern":"1","defaultvalue":"250","level1":"pri","level2":"pat","level3":"A","level4":"234"},
    {"ctlno":"305","setname":"自動プライミング送液流速2回目以降","elemkey":"pat-A-0235","datapattern":"1","defaultvalue":"250","level1":"pri","level2":"pat","level3":"A","level4":"235"},
    {"ctlno":"306","setname":"自動プライミング循環流速","elemkey":"pat-A-0236","datapattern":"1","defaultvalue":"400","level1":"pri","level2":"pat","level3":"A","level4":"236"},
    {"ctlno":"307","setname":"自動プライミング循環時間","elemkey":"pat-A-0237","datapattern":"1","defaultvalue":"300","level1":"pri","level2":"pat","level3":"A","level4":"237"},
    {"ctlno":"308","setname":"自動プライミング総量","elemkey":"pat-A-0238","datapattern":"1","defaultvalue":"600","level1":"pri","level2":"pat","level3":"A","level4":"238"},
    {"ctlno":"310","setname":"IPラインプライミング使用選択","elemkey":"pat-B-0001","datapattern":"1","defaultvalue":"1","level1":"dfas","level2":"pat","level3":"B","level4":"001"},
    {"ctlno":"311","setname":"中空糸 プライミング時のBP速度","elemkey":"pat-B-0005","datapattern":"1","defaultvalue":"300","level1":"dfas","level2":"pat","level3":"B","level4":"005"},
    {"ctlno":"312","setname":"中空糸 送液最大時間","elemkey":"pat-B-0007","datapattern":"1","defaultvalue":"60","level1":"dfas","level2":"pat","level3":"B","level4":"007"},
    {"ctlno":"313","setname":"中空糸 回路内洗浄送液量","elemkey":"pat-B-0008","datapattern":"1","defaultvalue":"200","level1":"dfas","level2":"pat","level3":"B","level4":"008"},
    {"ctlno":"314","setname":"中空糸 気泡抜き動作実行回数","elemkey":"pat-B-0009","datapattern":"1","defaultvalue":"0","level1":"dfas","level2":"pat","level3":"B","level4":"009"},
    {"ctlno":"315","setname":"中空糸 気泡抜き圧力上限","elemkey":"pat-B-0010","datapattern":"1","defaultvalue":"150","level1":"dfas","level2":"pat","level3":"B","level4":"010"},
    {"ctlno":"317","setname":"補液選択","elemkey":"dev-B-0030","datapattern":"1","defaultvalue":null,"level1":"ope","level2":"dev","level3":"B","level4":"030"},
    {"ctlno":"318","setname":"前補液 ダイアライザー気泡抜き時間","elemkey":"dev-B-0031","datapattern":"1","defaultvalue":"2","level1":"ope","level2":"dev","level3":"B","level4":"031"},
    {"ctlno":"319","setname":"前補液 動脈チャンバ液面作成時間","elemkey":"pat-B-0032","datapattern":"1","defaultvalue":"90","level1":"pri","level2":"pat","level3":"B","level4":"032"},
    {"ctlno":"320","setname":"前補液 循環洗浄時間","elemkey":"pat-B-0033","datapattern":"1","defaultvalue":"3","level1":"pri","level2":"pat","level3":"B","level4":"033"},
    {"ctlno":"321","setname":"治療モード","elemkey":"dev-B-0034","datapattern":"1","defaultvalue":null,"level1":"ope","level2":"dev","level3":"B","level4":"034"},
    {"ctlno":"322","setname":"後補液 ダイアライザー気泡抜き時間","elemkey":"pat-B-0051","datapattern":"1","defaultvalue":"2","level1":"pri","level2":"pat","level3":"B","level4":"051"},
    {"ctlno":"323","setname":"後補液 動脈チャンバ液面作成時間","elemkey":"pat-B-0052","datapattern":"1","defaultvalue":"60","level1":"pri","level2":"pat","level3":"B","level4":"052"},
    {"ctlno":"324","setname":"後補液 循環洗浄時間","elemkey":"pat-B-0053","datapattern":"1","defaultvalue":"3","level1":"pri","level2":"pat","level3":"B","level4":"053"},
    {"ctlno":"325","setname":"積層 送液最大時間","elemkey":"pat-B-0054","datapattern":"1","defaultvalue":"60","level1":"dfas","level2":"pat","level3":"B","level4":"054"},
    {"ctlno":"326","setname":"積層 回路内洗浄送液量","elemkey":"pat-B-0055","datapattern":"1","defaultvalue":"200","level1":"dfas","level2":"pat","level3":"B","level4":"055"},
    {"ctlno":"327","setname":"積層 気泡抜き動作実行回数","elemkey":"pat-B-0056","datapattern":"1","defaultvalue":"0","level1":"dfas","level2":"pat","level3":"B","level4":"056"},
    {"ctlno":"328","setname":"積層 気泡抜き圧力上限","elemkey":"pat-B-0057","datapattern":"1","defaultvalue":"150","level1":"dfas","level2":"pat","level3":"B","level4":"057"},
    {"ctlno":"329","setname":"積層 除水ポンプ速度","elemkey":"pat-B-0058","datapattern":"1","defaultvalue":"0.2","level1":"dfas","level2":"pat","level3":"B","level4":"058"},
    {"ctlno":"330","setname":"積層 プライミング時のBP速度","elemkey":"pat-B-0059","datapattern":"1","defaultvalue":"150","level1":"dfas","level2":"pat","level3":"B","level4":"059"},
    {"ctlno":"331","setname":"DP=Qd+Qs(補液速度加算)","elemkey":"dev-A-0369","datapattern":"1","defaultvalue":"1","level1":"ope","level2":"dev","level3":"A","level4":"369"},
    {"ctlno":"332","setname":"前補液　OHDF/OHF　補液速度比率","elemkey":"dev-A-0379","datapattern":"1","defaultvalue":"20","level1":"ope","level2":"dev","level3":"A","level4":"379"},
    {"ctlno":"333","setname":"後補液　OHDF/OHF　補液速度比率","elemkey":"dev-B-0039","datapattern":"1","defaultvalue":"20","level1":"ope","level2":"dev","level3":"B","level4":"039"},
    {"ctlno":"334","setname":"自動測定2","elemkey":"dev-A-0263","datapattern":"1","defaultvalue":"0","level1":"bv","level2":"dev","level3":"A","level4":"263"},
    {"ctlno":"335","setname":"自動測定3","elemkey":"dev-A-0264","datapattern":"1","defaultvalue":"0","level1":"bv","level2":"dev","level3":"A","level4":"264"},
    {"ctlno":"336","setname":"自動測定4","elemkey":"dev-A-0265","datapattern":"1","defaultvalue":"0","level1":"bv","level2":"dev","level3":"A","level4":"265"},
    {"ctlno":"337","setname":"自動測定5","elemkey":"dev-A-0266","datapattern":"1","defaultvalue":"0","level1":"bv","level2":"dev","level3":"A","level4":"266"},
    {"ctlno":"338","setname":"除水開始遅延時間","elemkey":"dev-A-0039","datapattern":"1","defaultvalue":"0","level1":"ope","level2":"dev","level3":"A","level4":"039"},
    {"ctlno":"339","setname":"動脈側返血使用選択","elemkey":"dev-A-0270","datapattern":"1","defaultvalue":"1","level1":"dfas","level2":"dev","level3":"A","level4":"270"},
    {"ctlno":"346","setname":"濾過率（前補液）","elemkey":"dev-A-0090","datapattern":"1","defaultvalue":"50","level1":"ope","level2":"dev","level3":"A","level4":"090"},
    {"ctlno":"347","setname":"ヘマトクリット（Ht）","elemkey":"dev-A-0091","datapattern":"1","defaultvalue":"33","level1":"ope","level2":"dev","level3":"A","level4":"091"},
    {"ctlno":"348","setname":"総タンパク（TP）","elemkey":"dev-A-0092","datapattern":"1","defaultvalue":"6.5","level1":"ope","level2":"dev","level3":"A","level4":"092"},
    {"ctlno":"349","setname":"血圧測定方法選択","elemkey":"dev-A-0195","datapattern":"1","defaultvalue":"1","level1":"bp","level2":"dev","level3":"A","level4":"195"},
    {"ctlno":"350","setname":"濾過率（後補液）","elemkey":"dev-B-0040","datapattern":"1","defaultvalue":"40","level1":"ope","level2":"dev","level3":"B","level4":"040"},
    {"ctlno":"362","setname":"透析液流量　設定方法","elemkey":"dev-A-0268","datapattern":"1","defaultvalue":"1","level1":"ope","level2":"dev","level3":"A","level4":"268"},
    {"ctlno":"363","setname":"透析液流量　比率設定","elemkey":"dev-A-0269","datapattern":"1","defaultvalue":"2.0","level1":"ope","level2":"dev","level3":"A","level4":"269"},
    {"ctlno":"436","setname":"VA確認報知基準値(静的静脈圧)","elemkey":"dev-A-0468","datapattern":"1","defaultvalue":"80","level1":"iap","level2":"dev","level3":"A","level4":"468"},
    {"ctlno":"437","setname":"VA確認報知基準値(IAP ratio)","elemkey":"dev-A-0469","datapattern":"1","defaultvalue":"0.5","level1":"iap","level2":"dev","level3":"A","level4":"469"},
    {"ctlno":"438","setname":"静的静脈圧記録 自動実施選択","elemkey":"dev-A-0470","datapattern":"1","defaultvalue":"1","level1":"iap","level2":"dev","level3":"A","level4":"470"},
    {"ctlno":"439","setname":"血圧測定 自動実施選択","elemkey":"dev-A-0471","datapattern":"1","defaultvalue":"0","level1":"iap","level2":"dev","level3":"A","level4":"471"},
    {"ctlno":"440","setname":"TMP閾値 速度低下","elemkey":"dev-A-0472","datapattern":"1","defaultvalue":"0","level1":"ope","level2":"dev","level3":"A","level4":"472"},
    {"ctlno":"441","setname":"TMP閾値 速度復帰","elemkey":"dev-A-0473","datapattern":"1","defaultvalue":"0","level1":"ope","level2":"dev","level3":"A","level4":"473"},
    {"ctlno":"442","setname":"速度変化率 速度低下","elemkey":"dev-A-0474","datapattern":"1","defaultvalue":"5","level1":"ope","level2":"dev","level3":"A","level4":"474"},
    {"ctlno":"443","setname":"速度変化率 速度復帰","elemkey":"dev-A-0475","datapattern":"1","defaultvalue":"5","level1":"ope","level2":"dev","level3":"A","level4":"475"},
    {"ctlno":"444","setname":"⊿SO2低下報知点","elemkey":"dev-A-0476","datapattern":"1","defaultvalue":"5","level1":"ope","level2":"dev","level3":"A","level4":"476"},
    {"ctlno":"445","setname":"条件送信時血流量","elemkey":"dev-A-0477","datapattern":"1","defaultvalue":null,"level1":"ope","level2":"dev","level3":"A","level4":"477"},
    {"ctlno":"65","setname":"初期ＵＦＲ警報上限","elemkey":"ufr_warning_max","datapattern":"4","defaultvalue":"200","level1":"ufr_warning_max","level2":"","level3":"","level4":"ufr_warning_max"},
    {"ctlno":"66","setname":"初期ＵＦＲ警報下限","elemkey":"ufr_warning_min","datapattern":"4","defaultvalue":"1","level1":"ufr_warning_min","level2":"","level3":"","level4":"ufr_warning_min"},
    {"ctlno":"67","setname":"ＵＦＲ低下警報点","elemkey":"ufr_warning_reduction","datapattern":"4","defaultvalue":"50","level1":"ufr_warning_reduction","level2":"","level3":"","level4":"ufr_warning_reduction"},
    {"ctlno":"68","setname":"ＴＭＰゼロ補正警報中点HD","elemkey":"tmp_center_hd","datapattern":"5","defaultvalue":"-30","level1":"tmp_center_hd","level2":"","level3":"","level4":"tmp_center_hd"},
    {"ctlno":"71","setname":"ＴＭＰゼロ補正警報中点ECUM","elemkey":"tmp_center_ecum","datapattern":"5","defaultvalue":"-65","level1":"tmp_center_ecum","level2":"","level3":"","level4":"tmp_center_ecum"},
    {"ctlno":"74","setname":"ＴＭＰゼロ補正警報中点HDF","elemkey":"tmp_center_hdf","datapattern":"5","defaultvalue":"-30","level1":"tmp_center_hdf","level2":"","level3":"","level4":"tmp_center_hdf"},
    {"ctlno":"77","setname":"ＴＭＰゼロ補正警報中点HF","elemkey":"tmp_center_hf","datapattern":"5","defaultvalue":"-65","level1":"tmp_center_hf","level2":"","level3":"","level4":"tmp_center_hf"},
    {"ctlno":"81","setname":"ＩＰ速度操作範囲上限","elemkey":"ind_cond_info-33-value","datapattern":"3","defaultvalue":"10","level1":"33","level2":"ind_cond_info","level3":"33","level4":"value"},
    {"ctlno":"85","setname":"Ｎａ注入濃度操作範囲上限","elemkey":"dev-A-0184","datapattern":"2","defaultvalue":"50","level1":"na","level2":"dev","level3":"A","level4":"184"},
    {"ctlno":"147","setname":"透析量プログラム使用選択","elemkey":"dev-A-0282","datapattern":"2","defaultvalue":"0","level1":"dia","level2":"dev","level3":"A","level4":"282"},
    {"ctlno":"148","setname":"体液量計算時後体重","elemkey":"calc_body_fluids_date","datapattern":"6","defaultvalue":null,"level1":"","level2":"","level3":"","level4":"calc_body_fluids_date"},
    {"ctlno":"149","setname":"体液量+補正値","elemkey":"calc_body_fluids","datapattern":"6","defaultvalue":null,"level1":"","level2":"","level3":"","level4":"calc_body_fluids"},
    {"ctlno":"150","setname":"目標後体重","elemkey":"ind_cond_info-3-value","datapattern":"3","defaultvalue":null,"level1":"3","level2":"ind_cond_info","level3":"3","level4":"value"},
    {"ctlno":"151","setname":"標準血流量","elemkey":"ind_cond_info-14-value","datapattern":"3","defaultvalue":null,"level1":"14","level2":"ind_cond_info","level3":"14","level4":"value"},
    {"ctlno":"152","setname":"KoA","elemkey":"koa","datapattern":"4","defaultvalue":null,"level1":"koa","level2":"","level3":"","level4":"koa"},
    {"ctlno":"153","setname":"目標Kt/V","elemkey":"dev-A-0288","datapattern":"2","defaultvalue":null,"level1":"dia","level2":"dev","level3":"A","level4":"288"},
    {"ctlno":"154","setname":"ＵＦＲプログラム電源ＳＷ","elemkey":"dev-A-0290","datapattern":"2","defaultvalue":"0","level1":"ufr","level2":"dev","level3":"A","level4":"290"},
    {"ctlno":"155","setname":"ＵＦＲプログラム指数１","elemkey":"dev-A-0301","datapattern":"2","defaultvalue":"200","level1":"ufr","level2":"dev","level3":"A","level4":"301"},
    {"ctlno":"156","setname":"ＵＦＲプログラム指数２","elemkey":"dev-A-0302","datapattern":"2","defaultvalue":"150","level1":"ufr","level2":"dev","level3":"A","level4":"302"},
    {"ctlno":"157","setname":"ＵＦＲプログラム指数３","elemkey":"dev-A-0303","datapattern":"2","defaultvalue":"100","level1":"ufr","level2":"dev","level3":"A","level4":"303"},
    {"ctlno":"158","setname":"ＵＦＲプログラム指数４","elemkey":"dev-A-0304","datapattern":"2","defaultvalue":"50","level1":"ufr","level2":"dev","level3":"A","level4":"304"},
    {"ctlno":"159","setname":"ＵＦＲプログラム指数５","elemkey":"dev-A-0305","datapattern":"2","defaultvalue":"0","level1":"ufr","level2":"dev","level3":"A","level4":"305"},
    {"ctlno":"160","setname":"ＵＦＲプログラム指数６","elemkey":"dev-A-0306","datapattern":"2","defaultvalue":"0","level1":"ufr","level2":"dev","level3":"A","level4":"306"},
    {"ctlno":"161","setname":"ＵＦＲプログラム指数７","elemkey":"dev-A-0307","datapattern":"2","defaultvalue":"50","level1":"ufr","level2":"dev","level3":"A","level4":"307"},
    {"ctlno":"162","setname":"ＵＦＲプログラム指数８","elemkey":"dev-A-0308","datapattern":"2","defaultvalue":"100","level1":"ufr","level2":"dev","level3":"A","level4":"308"},
    {"ctlno":"163","setname":"ＵＦＲプログラム指数９","elemkey":"dev-A-0309","datapattern":"2","defaultvalue":"150","level1":"ufr","level2":"dev","level3":"A","level4":"309"},
    {"ctlno":"164","setname":"ＵＦＲプログラム指数１０","elemkey":"dev-A-0310","datapattern":"2","defaultvalue":"200","level1":"ufr","level2":"dev","level3":"A","level4":"310"},
    {"ctlno":"165","setname":"ＵＦＲプログラム最終位置","elemkey":"dev-A-0311","datapattern":"2","defaultvalue":"10","level1":"ufr","level2":"dev","level3":"A","level4":"311"},
    {"ctlno":"166","setname":"ＵＦＲプログラムコース","elemkey":"dev-A-0312","datapattern":"2","defaultvalue":"1","level1":"ufr","level2":"dev","level3":"A","level4":"312"},
    {"ctlno":"167","setname":"ＵＦＲプログラム開始数値","elemkey":"dev-A-0313","datapattern":"2","defaultvalue":"100","level1":"ufr","level2":"dev","level3":"A","level4":"313"},
    {"ctlno":"168","setname":"ＵＦＲプログラム終了数値","elemkey":"dev-A-0314","datapattern":"2","defaultvalue":"100","level1":"ufr","level2":"dev","level3":"A","level4":"314"},
    {"ctlno":"169","setname":"Ｎａ注入プログラム電源ＳＷ","elemkey":"dev-A-0315","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"315"},
    {"ctlno":"170","setname":"Ｎａ注入プログラム設定１","elemkey":"dev-A-0316","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"316"},
    {"ctlno":"171","setname":"Ｎａ注入プログラム設定２","elemkey":"dev-A-0317","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"317"},
    {"ctlno":"172","setname":"Ｎａ注入プログラム設定３","elemkey":"dev-A-0318","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"318"},
    {"ctlno":"173","setname":"Ｎａ注入プログラム設定４","elemkey":"dev-A-0319","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"319"},
    {"ctlno":"174","setname":"Ｎａ注入プログラム設定５","elemkey":"dev-A-0320","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"320"},
    {"ctlno":"175","setname":"Ｎａ注入プログラム設定６","elemkey":"dev-A-0321","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"321"},
    {"ctlno":"176","setname":"Ｎａ注入プログラム設定７","elemkey":"dev-A-0322","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"322"},
    {"ctlno":"177","setname":"Ｎａ注入プログラム設定８","elemkey":"dev-A-0323","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"323"},
    {"ctlno":"178","setname":"Ｎａ注入プログラム設定９","elemkey":"dev-A-0324","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"324"},
    {"ctlno":"179","setname":"Ｎａ注入プログラム設定１０","elemkey":"dev-A-0325","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"325"},
    {"ctlno":"180","setname":"Ｎａ注入プログラム切替時間","elemkey":"dev-A-0326","datapattern":"2","defaultvalue":"30","level1":"na","level2":"dev","level3":"A","level4":"326"},
    {"ctlno":"181","setname":"Ｎａ注入プログラム ＵＦＲプロとの連動選択","elemkey":"dev-A-0327","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"327"},
    {"ctlno":"182","setname":"Ｎａ注入プログラムコース","elemkey":"dev-A-0328","datapattern":"2","defaultvalue":"1","level1":"na","level2":"dev","level3":"A","level4":"328"},
    {"ctlno":"183","setname":"Ｎａ注入プログラム開始数値","elemkey":"dev-A-0329","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"329"},
    {"ctlno":"184","setname":"Ｎａ注入プログラム終了数値","elemkey":"dev-A-0330","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"330"},
    {"ctlno":"189","setname":"治療開始時 血液ポンプ速度","elemkey":"ind_cond_info-14-value","datapattern":"3","defaultvalue":null,"level1":"14","level2":"ind_cond_info","level3":"14","level4":"value"},
    {"ctlno":"194","setname":"濃度プログラム電源ＳＷ","elemkey":"dev-A-0340","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"A","level4":"340"},
    {"ctlno":"195","setname":"透析液濃度プログラム設定１","elemkey":"dev-A-0341","datapattern":"2","defaultvalue":"14","level1":"dc","level2":"dev","level3":"A","level4":"341"},
    {"ctlno":"196","setname":"透析液濃度プログラム設定２","elemkey":"dev-A-0342","datapattern":"2","defaultvalue":"14","level1":"dc","level2":"dev","level3":"A","level4":"342"},
    {"ctlno":"197","setname":"透析液濃度プログラム設定３","elemkey":"dev-A-0343","datapattern":"2","defaultvalue":"14","level1":"dc","level2":"dev","level3":"A","level4":"343"},
    {"ctlno":"198","setname":"透析液濃度プログラム設定４","elemkey":"dev-A-0344","datapattern":"2","defaultvalue":"14","level1":"dc","level2":"dev","level3":"A","level4":"344"},
    {"ctlno":"199","setname":"透析液濃度プログラム設定５","elemkey":"dev-A-0345","datapattern":"2","defaultvalue":"14","level1":"dc","level2":"dev","level3":"A","level4":"345"},
    {"ctlno":"200","setname":"透析液濃度プログラム設定６","elemkey":"dev-A-0346","datapattern":"2","defaultvalue":"13.5","level1":"dc","level2":"dev","level3":"A","level4":"346"},
    {"ctlno":"201","setname":"透析液濃度プログラム設定７","elemkey":"dev-A-0347","datapattern":"2","defaultvalue":"13.5","level1":"dc","level2":"dev","level3":"A","level4":"347"},
    {"ctlno":"202","setname":"透析液濃度プログラム設定８","elemkey":"dev-A-0348","datapattern":"2","defaultvalue":"13.5","level1":"dc","level2":"dev","level3":"A","level4":"348"},
    {"ctlno":"203","setname":"透析液濃度プログラム設定９","elemkey":"dev-A-0349","datapattern":"2","defaultvalue":"13.5","level1":"dc","level2":"dev","level3":"A","level4":"349"},
    {"ctlno":"204","setname":"透析液濃度プログラム設定１０","elemkey":"dev-A-0350","datapattern":"2","defaultvalue":"13.5","level1":"dc","level2":"dev","level3":"A","level4":"350"},
    {"ctlno":"205","setname":"Ｂ液濃度プログラム設定１","elemkey":"dev-A-0351","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"351"},
    {"ctlno":"206","setname":"Ｂ液濃度プログラム設定２","elemkey":"dev-A-0352","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"352"},
    {"ctlno":"207","setname":"Ｂ液濃度プログラム設定３","elemkey":"dev-A-0353","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"353"},
    {"ctlno":"208","setname":"Ｂ液濃度プログラム設定４","elemkey":"dev-A-0354","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"354"},
    {"ctlno":"209","setname":"Ｂ液濃度プログラム設定５","elemkey":"dev-A-0355","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"355"},
    {"ctlno":"210","setname":"Ｂ液濃度プログラム設定６","elemkey":"dev-A-0356","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"356"},
    {"ctlno":"211","setname":"Ｂ液濃度プログラム設定７","elemkey":"dev-A-0357","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"357"},
    {"ctlno":"212","setname":"Ｂ液濃度プログラム設定８","elemkey":"dev-A-0358","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"358"},
    {"ctlno":"213","setname":"Ｂ液濃度プログラム設定９","elemkey":"dev-A-0359","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"359"},
    {"ctlno":"214","setname":"Ｂ液濃度プログラム設定１０","elemkey":"dev-A-0360","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"360"},
    {"ctlno":"215","setname":"透析液濃度プログラムステップ切替無し コース","elemkey":"dev-A-0361","datapattern":"2","defaultvalue":"2","level1":"dc","level2":"dev","level3":"A","level4":"361"},
    {"ctlno":"216","setname":"透析液濃度プログラム開始数値","elemkey":"dev-A-0362","datapattern":"2","defaultvalue":"13.5","level1":"dc","level2":"dev","level3":"A","level4":"362"},
    {"ctlno":"217","setname":"透析液濃度プログラム終了数値","elemkey":"dev-A-0363","datapattern":"2","defaultvalue":"15","level1":"dc","level2":"dev","level3":"A","level4":"363"},
    {"ctlno":"218","setname":"Ｂ液濃度プログラムステップ切替無し コース","elemkey":"dev-A-0364","datapattern":"2","defaultvalue":"2","level1":"dc","level2":"dev","level3":"A","level4":"364"},
    {"ctlno":"219","setname":"Ｂ液濃度プログラム開始数値","elemkey":"dev-A-0365","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"365"},
    {"ctlno":"220","setname":"Ｂ液濃度プログラム終了数値","elemkey":"dev-A-0366","datapattern":"2","defaultvalue":"3","level1":"dc","level2":"dev","level3":"A","level4":"366"},
    {"ctlno":"221","setname":"濃度プログラム切替時間","elemkey":"dev-A-0367","datapattern":"2","defaultvalue":"30","level1":"dc","level2":"dev","level3":"A","level4":"367"},
    {"ctlno":"222","setname":"濃度プログラム ＵＦＲプロとの連動選択","elemkey":"dev-A-0368","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"A","level4":"368"},
    {"ctlno":"231","setname":"補液速度","elemkey":"ind_cond_info-24-value","datapattern":"3","defaultvalue":null,"level1":"24","level2":"ind_cond_info","level3":"24","level4":"value"},
    {"ctlno":"232","setname":"補液温度設定値","elemkey":"ind_cond_info-23-value","datapattern":"3","defaultvalue":null,"level1":"23","level2":"ind_cond_info","level3":"23","level4":"value"},
    {"ctlno":"233","setname":"補液量設定値","elemkey":"ind_cond_info-20-value","datapattern":"3","defaultvalue":null,"level1":"20","level2":"ind_cond_info","level3":"20","level4":"value"},
    {"ctlno":"239","setname":"補液選択(前・後)","elemkey":"ind_cond_info-21-value","datapattern":"3","defaultvalue":"0","level1":"21","level2":"ind_cond_info","level3":"21","level4":"value"},
    {"ctlno":"241","setname":"ＴＭＰゼロ補正警報中点OHDF","elemkey":"tmp_center_ohdf","datapattern":"5","defaultvalue":"-30","level1":"tmp_center_ohdf","level2":"","level3":"","level4":"tmp_center_ohdf"},
    {"ctlno":"244","setname":"ＴＭＰゼロ補正警報中点OHF","elemkey":"tmp_center_ohf","datapattern":"5","defaultvalue":"-65","level1":"tmp_center_ohf","level2":"","level3":"","level4":"tmp_center_ohf"},
    {"ctlno":"250","setname":"UFRプログラム工程1の指数","elemkey":"dev-B-0000","datapattern":"2","defaultvalue":"50","level1":"ufr","level2":"dev","level3":"B","level4":"000"},
    {"ctlno":"251","setname":"UFRプログラム工程2の指数","elemkey":"dev-B-0001","datapattern":"2","defaultvalue":"38","level1":"ufr","level2":"dev","level3":"B","level4":"001"},
    {"ctlno":"252","setname":"UFRプログラム工程3の指数","elemkey":"dev-B-0002","datapattern":"2","defaultvalue":"25","level1":"ufr","level2":"dev","level3":"B","level4":"002"},
    {"ctlno":"253","setname":"UFRプログラム工程4の指数","elemkey":"dev-B-0003","datapattern":"2","defaultvalue":"13","level1":"ufr","level2":"dev","level3":"B","level4":"003"},
    {"ctlno":"254","setname":"UFRプログラム工程5の指数","elemkey":"dev-B-0004","datapattern":"2","defaultvalue":"0","level1":"ufr","level2":"dev","level3":"B","level4":"004"},
    {"ctlno":"255","setname":"UFRプログラム工程6の指数","elemkey":"dev-B-0005","datapattern":"2","defaultvalue":"0","level1":"ufr","level2":"dev","level3":"B","level4":"005"},
    {"ctlno":"256","setname":"UFRプログラム工程7の指数","elemkey":"dev-B-0006","datapattern":"2","defaultvalue":"13","level1":"ufr","level2":"dev","level3":"B","level4":"006"},
    {"ctlno":"257","setname":"UFRプログラム工程8の指数","elemkey":"dev-B-0007","datapattern":"2","defaultvalue":"25","level1":"ufr","level2":"dev","level3":"B","level4":"007"},
    {"ctlno":"258","setname":"UFRプログラム工程9の指数","elemkey":"dev-B-0008","datapattern":"2","defaultvalue":"38","level1":"ufr","level2":"dev","level3":"B","level4":"008"},
    {"ctlno":"259","setname":"UFRプログラム工程10の指数","elemkey":"dev-B-0009","datapattern":"2","defaultvalue":"50","level1":"ufr","level2":"dev","level3":"B","level4":"009"},
    {"ctlno":"260","setname":"B液濃度プログラム工程1のB液濃度","elemkey":"dev-B-0010","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"010"},
    {"ctlno":"261","setname":"B液濃度プログラム工程2のB液濃度","elemkey":"dev-B-0011","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"011"},
    {"ctlno":"262","setname":"B液濃度プログラム工程3のB液濃度","elemkey":"dev-B-0012","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"012"},
    {"ctlno":"263","setname":"B液濃度プログラム工程4のB液濃度","elemkey":"dev-B-0013","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"013"},
    {"ctlno":"264","setname":"B液濃度プログラム工程5のB液濃度","elemkey":"dev-B-0014","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"014"},
    {"ctlno":"265","setname":"B液濃度プログラム工程6のB液濃度","elemkey":"dev-B-0015","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"015"},
    {"ctlno":"266","setname":"B液濃度プログラム工程7のB液濃度","elemkey":"dev-B-0016","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"016"},
    {"ctlno":"267","setname":"B液濃度プログラム工程8のB液濃度","elemkey":"dev-B-0017","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"017"},
    {"ctlno":"268","setname":"B液濃度プログラム工程9のB液濃度","elemkey":"dev-B-0018","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"018"},
    {"ctlno":"269","setname":"B液濃度プログラム工程10のB液濃度","elemkey":"dev-B-0019","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"019"},
    {"ctlno":"270","setname":"A液濃度プログラム工程1のA液濃度","elemkey":"dev-B-0020","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"020"},
    {"ctlno":"271","setname":"A液濃度プログラム工程2のA液濃度","elemkey":"dev-B-0021","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"021"},
    {"ctlno":"272","setname":"A液濃度プログラム工程3のA液濃度","elemkey":"dev-B-0022","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"022"},
    {"ctlno":"273","setname":"A液濃度プログラム工程4のA液濃度","elemkey":"dev-B-0023","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"023"},
    {"ctlno":"274","setname":"A液濃度プログラム工程5のA液濃度","elemkey":"dev-B-0024","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"024"},
    {"ctlno":"275","setname":"A液濃度プログラム工程6のA液濃度","elemkey":"dev-B-0025","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"025"},
    {"ctlno":"276","setname":"A液濃度プログラム工程7のA液濃度","elemkey":"dev-B-0026","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"026"},
    {"ctlno":"277","setname":"A液濃度プログラム工程8のA液濃度","elemkey":"dev-B-0027","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"027"},
    {"ctlno":"278","setname":"A液濃度プログラム工程9のA液濃度","elemkey":"dev-B-0028","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"028"},
    {"ctlno":"279","setname":"A液濃度プログラム工程10のA液濃度","elemkey":"dev-B-0029","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"029"},
    {"ctlno":"309","setname":"ダイアライザ選択","elemkey":"dialyzer_type","datapattern":"4","defaultvalue":"1","level1":"dialyzer_type","level2":"","level3":"","level4":"dialyzer_type"},
    {"ctlno":"316","setname":"中空糸 除水ポンプ速度","elemkey":"0000","datapattern":"7","defaultvalue":"0.2","level1":"","level2":"","level3":"","level4":""},
    {"ctlno":"340","setname":"I-HDF　補液量設定","elemkey":"dev-A-0200","datapattern":"2","defaultvalue":"200","level1":"ihdf","level2":"dev","level3":"A","level4":"200"},
    {"ctlno":"341","setname":"I-HDF　補液速度","elemkey":"dev-A-0201","datapattern":"2","defaultvalue":"100","level1":"ihdf","level2":"dev","level3":"A","level4":"201"},
    {"ctlno":"342","setname":"I-HDF　補液周期","elemkey":"dev-A-0202","datapattern":"2","defaultvalue":"30","level1":"ihdf","level2":"dev","level3":"A","level4":"202"},
    {"ctlno":"343","setname":"I-HDF　補液開始時間","elemkey":"dev-A-0203","datapattern":"2","defaultvalue":"30","level1":"ihdf","level2":"dev","level3":"A","level4":"203"},
    {"ctlno":"344","setname":"I-HDF　除水再開時間","elemkey":"dev-A-0204","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"204"},
    {"ctlno":"345","setname":"I-HDF　総補液量上限","elemkey":"dev-A-0205","datapattern":"2","defaultvalue":"1.5","level1":"ihdf","level2":"dev","level3":"A","level4":"205"},
    {"ctlno":"351","setname":"BV-UFC使用選択","elemkey":"dev-A-0196","datapattern":"2","defaultvalue":"0","level1":"bvufc","level2":"dev","level3":"A","level4":"196"},
    {"ctlno":"352","setname":"UFC期間除水速度上限","elemkey":"dev-A-0197","datapattern":"2","defaultvalue":"2.00","level1":"bvufc","level2":"dev","level3":"A","level4":"197"},
    {"ctlno":"353","setname":"UFC期間除水速度下限","elemkey":"dev-A-0198","datapattern":"2","defaultvalue":"0.00","level1":"bvufc","level2":"dev","level3":"A","level4":"198"},
    {"ctlno":"354","setname":"開始期間 時間","elemkey":"dev-A-0199","datapattern":"2","defaultvalue":"10","level1":"bvufc","level2":"dev","level3":"A","level4":"199"},
    {"ctlno":"355","setname":"開始期間 除水速度倍率","elemkey":"dev-A-0206","datapattern":"2","defaultvalue":"1.00","level1":"bvufc","level2":"dev","level3":"A","level4":"206"},
    {"ctlno":"356","setname":"固定倍率除水期間 時間","elemkey":"dev-A-0207","datapattern":"2","defaultvalue":"60","level1":"bvufc","level2":"dev","level3":"A","level4":"207"},
    {"ctlno":"357","setname":"固定倍率除水期間 除水速度倍率","elemkey":"dev-A-0208","datapattern":"2","defaultvalue":"1.30","level1":"bvufc","level2":"dev","level3":"A","level4":"208"},
    {"ctlno":"358","setname":"固定倍率除水終了条件　最高血圧","elemkey":"dev-A-0209","datapattern":"2","defaultvalue":"0","level1":"bvufc","level2":"dev","level3":"A","level4":"209"},
    {"ctlno":"359","setname":"固定倍率除水終了条件　脈拍","elemkey":"dev-A-0210","datapattern":"2","defaultvalue":"0","level1":"bvufc","level2":"dev","level3":"A","level4":"210"},
    {"ctlno":"360","setname":"固定倍率除水終了条件　ΔBV","elemkey":"dev-A-0248","datapattern":"2","defaultvalue":"0.0","level1":"bvufc","level2":"dev","level3":"A","level4":"248"},
    {"ctlno":"361","setname":"終了前期間 時間","elemkey":"dev-A-0249","datapattern":"2","defaultvalue":"20","level1":"bvufc","level2":"dev","level3":"A","level4":"249"},
    {"ctlno":"364","setname":"開始時ΔBV基準値 ","elemkey":"dev-A-0271","datapattern":"2","defaultvalue":"0.0","level1":"bvufc","level2":"dev","level3":"A","level4":"271"},
    {"ctlno":"365","setname":"ΔBV基準線　指数1","elemkey":"dev-A-0272","datapattern":"2","defaultvalue":"50","level1":"bvufc","level2":"dev","level3":"A","level4":"272"},
    {"ctlno":"366","setname":"ΔBV基準線　指数2","elemkey":"dev-A-0273","datapattern":"2","defaultvalue":"80","level1":"bvufc","level2":"dev","level3":"A","level4":"273"},
    {"ctlno":"367","setname":"ΔBV基準線　指数3","elemkey":"dev-A-0274","datapattern":"2","defaultvalue":"95","level1":"bvufc","level2":"dev","level3":"A","level4":"274"},
    {"ctlno":"368","setname":"終了時ΔBV基準値 ","elemkey":"dev-A-0275","datapattern":"2","defaultvalue":"-4.0","level1":"bvufc","level2":"dev","level3":"A","level4":"275"},
    {"ctlno":"369","setname":"QBプログラム血流量1","elemkey":"dev-A-0400","datapattern":"2","defaultvalue":"100","level1":"qbqd","level2":"dev","level3":"A","level4":"400"},
    {"ctlno":"370","setname":"QBプログラム血流量2","elemkey":"dev-A-0401","datapattern":"2","defaultvalue":"160","level1":"qbqd","level2":"dev","level3":"A","level4":"401"},
    {"ctlno":"371","setname":"QBプログラム血流量3","elemkey":"dev-A-0402","datapattern":"2","defaultvalue":"220","level1":"qbqd","level2":"dev","level3":"A","level4":"402"},
    {"ctlno":"372","setname":"QBプログラム血流量4","elemkey":"dev-A-0403","datapattern":"2","defaultvalue":"220","level1":"qbqd","level2":"dev","level3":"A","level4":"403"},
    {"ctlno":"373","setname":"QBプログラム血流量5","elemkey":"dev-A-0404","datapattern":"2","defaultvalue":"220","level1":"qbqd","level2":"dev","level3":"A","level4":"404"},
    {"ctlno":"374","setname":"QBプログラム血流量6","elemkey":"dev-A-0405","datapattern":"2","defaultvalue":"220","level1":"qbqd","level2":"dev","level3":"A","level4":"405"},
    {"ctlno":"375","setname":"QBプログラム血流量7","elemkey":"dev-A-0406","datapattern":"2","defaultvalue":"220","level1":"qbqd","level2":"dev","level3":"A","level4":"406"},
    {"ctlno":"376","setname":"QBプログラム血流量8","elemkey":"dev-A-0407","datapattern":"2","defaultvalue":"220","level1":"qbqd","level2":"dev","level3":"A","level4":"407"},
    {"ctlno":"377","setname":"QBプログラム血流量9","elemkey":"dev-A-0408","datapattern":"2","defaultvalue":"220","level1":"qbqd","level2":"dev","level3":"A","level4":"408"},
    {"ctlno":"378","setname":"QBプログラム血流量10","elemkey":"dev-A-0409","datapattern":"2","defaultvalue":"220","level1":"qbqd","level2":"dev","level3":"A","level4":"409"},
    {"ctlno":"379","setname":"QDプログラム透析液流量1","elemkey":"dev-A-0410","datapattern":"2","defaultvalue":"200","level1":"qbqd","level2":"dev","level3":"A","level4":"410"},
    {"ctlno":"380","setname":"QDプログラム透析液流量2","elemkey":"dev-A-0411","datapattern":"2","defaultvalue":"400","level1":"qbqd","level2":"dev","level3":"A","level4":"411"},
    {"ctlno":"381","setname":"QDプログラム透析液流量3","elemkey":"dev-A-0412","datapattern":"2","defaultvalue":"600","level1":"qbqd","level2":"dev","level3":"A","level4":"412"},
    {"ctlno":"382","setname":"QDプログラム透析液流量4","elemkey":"dev-A-0413","datapattern":"2","defaultvalue":"600","level1":"qbqd","level2":"dev","level3":"A","level4":"413"},
    {"ctlno":"383","setname":"QDプログラム透析液流量5","elemkey":"dev-A-0414","datapattern":"2","defaultvalue":"600","level1":"qbqd","level2":"dev","level3":"A","level4":"414"},
    {"ctlno":"384","setname":"QDプログラム透析液流量6","elemkey":"dev-A-0415","datapattern":"2","defaultvalue":"600","level1":"qbqd","level2":"dev","level3":"A","level4":"415"},
    {"ctlno":"385","setname":"QDプログラム透析液流量7","elemkey":"dev-A-0416","datapattern":"2","defaultvalue":"600","level1":"qbqd","level2":"dev","level3":"A","level4":"416"},
    {"ctlno":"386","setname":"QDプログラム透析液流量8","elemkey":"dev-A-0417","datapattern":"2","defaultvalue":"600","level1":"qbqd","level2":"dev","level3":"A","level4":"417"},
    {"ctlno":"387","setname":"QDプログラム透析液流量9","elemkey":"dev-A-0418","datapattern":"2","defaultvalue":"600","level1":"qbqd","level2":"dev","level3":"A","level4":"418"},
    {"ctlno":"388","setname":"QDプログラム透析液流量10","elemkey":"dev-A-0419","datapattern":"2","defaultvalue":"600","level1":"qbqd","level2":"dev","level3":"A","level4":"419"},
    {"ctlno":"389","setname":"QB、QDプログラム切替時間1","elemkey":"dev-A-0420","datapattern":"2","defaultvalue":"60","level1":"qbqd","level2":"dev","level3":"A","level4":"420"},
    {"ctlno":"390","setname":"QB、QDプログラム切替時間2","elemkey":"dev-A-0421","datapattern":"2","defaultvalue":"60","level1":"qbqd","level2":"dev","level3":"A","level4":"421"},
    {"ctlno":"391","setname":"QB、QDプログラム切替時間3","elemkey":"dev-A-0422","datapattern":"2","defaultvalue":"60","level1":"qbqd","level2":"dev","level3":"A","level4":"422"},
    {"ctlno":"392","setname":"QB、QDプログラム切替時間4","elemkey":"dev-A-0423","datapattern":"2","defaultvalue":"60","level1":"qbqd","level2":"dev","level3":"A","level4":"423"},
    {"ctlno":"393","setname":"QB、QDプログラム切替時間5","elemkey":"dev-A-0424","datapattern":"2","defaultvalue":"60","level1":"qbqd","level2":"dev","level3":"A","level4":"424"},
    {"ctlno":"394","setname":"QB、QDプログラム切替時間6","elemkey":"dev-A-0425","datapattern":"2","defaultvalue":"60","level1":"qbqd","level2":"dev","level3":"A","level4":"425"},
    {"ctlno":"395","setname":"QB、QDプログラム切替時間7","elemkey":"dev-A-0426","datapattern":"2","defaultvalue":"60","level1":"qbqd","level2":"dev","level3":"A","level4":"426"},
    {"ctlno":"396","setname":"QB、QDプログラム切替時間8","elemkey":"dev-A-0427","datapattern":"2","defaultvalue":"60","level1":"qbqd","level2":"dev","level3":"A","level4":"427"},
    {"ctlno":"397","setname":"QB、QDプログラム切替時間9","elemkey":"dev-A-0428","datapattern":"2","defaultvalue":"60","level1":"qbqd","level2":"dev","level3":"A","level4":"428"},
    {"ctlno":"398","setname":"QB、QDプログラム最大ステップ数","elemkey":"dev-A-0429","datapattern":"2","defaultvalue":"3","level1":"qbqd","level2":"dev","level3":"A","level4":"429"},
    {"ctlno":"399","setname":"QBプログラム電源","elemkey":"dev-A-0430","datapattern":"2","defaultvalue":"0","level1":"qbqd","level2":"dev","level3":"A","level4":"430"},
    {"ctlno":"400","setname":"QDプログラム電源","elemkey":"dev-A-0431","datapattern":"2","defaultvalue":"0","level1":"qbqd","level2":"dev","level3":"A","level4":"431"},
    {"ctlno":"401","setname":"I-HDFプログラム使用選択","elemkey":"dev-A-0432","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"432"},
    {"ctlno":"402","setname":"予定補液回数","elemkey":"dev-A-0433","datapattern":"2","defaultvalue":"7","level1":"ihdf","level2":"dev","level3":"A","level4":"433"},
    {"ctlno":"403","setname":"補液バランス制限","elemkey":"dev-A-0434","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"434"},
    {"ctlno":"404","setname":"補液量01","elemkey":"dev-A-0435","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"435"},
    {"ctlno":"405","setname":"補液量02","elemkey":"dev-A-0436","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"436"},
    {"ctlno":"406","setname":"補液量03","elemkey":"dev-A-0437","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"437"},
    {"ctlno":"407","setname":"補液量04","elemkey":"dev-A-0438","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"438"},
    {"ctlno":"408","setname":"補液量05","elemkey":"dev-A-0439","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"439"},
    {"ctlno":"409","setname":"補液量06","elemkey":"dev-A-0440","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"440"},
    {"ctlno":"410","setname":"補液量07","elemkey":"dev-A-0441","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"441"},
    {"ctlno":"411","setname":"補液量08","elemkey":"dev-A-0442","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"442"},
    {"ctlno":"412","setname":"補液量09","elemkey":"dev-A-0443","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"443"},
    {"ctlno":"413","setname":"補液量10","elemkey":"dev-A-0444","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"444"},
    {"ctlno":"414","setname":"補液量11","elemkey":"dev-A-0445","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"445"},
    {"ctlno":"415","setname":"補液量12","elemkey":"dev-A-0446","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"446"},
    {"ctlno":"416","setname":"補液量13","elemkey":"dev-A-0447","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"447"},
    {"ctlno":"417","setname":"補液量14","elemkey":"dev-A-0448","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"448"},
    {"ctlno":"418","setname":"補液量15","elemkey":"dev-A-0449","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"449"},
    {"ctlno":"419","setname":"補液量16","elemkey":"dev-A-0450","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"450"},
    {"ctlno":"420","setname":"回収量01","elemkey":"dev-A-0451","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"451"},
    {"ctlno":"421","setname":"回収量02","elemkey":"dev-A-0452","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"452"},
    {"ctlno":"422","setname":"回収量03","elemkey":"dev-A-0453","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"453"},
    {"ctlno":"423","setname":"回収量04","elemkey":"dev-A-0454","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"454"},
    {"ctlno":"424","setname":"回収量05","elemkey":"dev-A-0455","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"455"},
    {"ctlno":"425","setname":"回収量06","elemkey":"dev-A-0456","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"456"},
    {"ctlno":"426","setname":"回収量07","elemkey":"dev-A-0457","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"457"},
    {"ctlno":"427","setname":"回収量08","elemkey":"dev-A-0458","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"458"},
    {"ctlno":"428","setname":"回収量09","elemkey":"dev-A-0459","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"459"},
    {"ctlno":"429","setname":"回収量10","elemkey":"dev-A-0460","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"460"},
    {"ctlno":"430","setname":"回収量11","elemkey":"dev-A-0461","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"461"},
    {"ctlno":"431","setname":"回収量12","elemkey":"dev-A-0462","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"462"},
    {"ctlno":"432","setname":"回収量13","elemkey":"dev-A-0463","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"463"},
    {"ctlno":"433","setname":"回収量14","elemkey":"dev-A-0464","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"464"},
    {"ctlno":"434","setname":"回収量15","elemkey":"dev-A-0465","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"465"},
    {"ctlno":"435","setname":"回収量16","elemkey":"dev-A-0466","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"466"}
  ]'' :: jsonb
      ) AS elements(
        ctlno TEXT,
        setname TEXT,
        elemkey TEXT,
        datapattern TEXT,
        defaultvalue TEXT
      )
  ),
  ntss_db5_pm AS (
    SELECT
      pat_id,
      facility_cd,
      device_set_info,
      up_date
    FROM
      ntss.pat_main
    WHERE
      facility_cd = @facilityCd
      AND pat_id = ANY (string_to_array(@paramList1, '','')::bigint[])
      AND is_del <> ''1''
  ),
  -- 治療情報マスタ：指示 *修正版
  ind_ord_main_before_rank AS (
    SELECT
      subquery.pat_id,
      subquery.facility_cd,
      subquery.ord_no,
      subquery.treat_week,
      subquery.treat_date,
      subquery.up_date,
      subquery.ind_device_set_info,
      subquery.ind_cond_info,
      subquery.rst_cond_info,
      subquery.ind_bed_cd,
      subquery.rst_weight_info,
      subquery.rst_running_time,
      subquery.min_treatment_date,
      RANK() OVER (
        PARTITION BY subquery.pat_id,
        subquery.treat_week
        ORDER BY
          CASE
            WHEN subquery.ind_kur_cd = ''0'' THEN 2
            ELSE 1
          END,
          CASE
            WHEN subquery.ind_kur_cd = ''0'' THEN ntss_db5_mst_sel.sortkey :: integer
            ELSE (subquery.ind_treat_start_time) :: integer
          END,
          ntss_db5_mst_sel.sortkey
      ) AS priority
    FROM
      (
        SELECT
          ord_main.*,
          MIN(TO_DATE(ord_main.treat_date, ''YYYYMMDD'')) OVER(PARTITION BY ord_main.treat_week, ord_main.pat_id) AS min_treatment_date
        FROM
          ord_main
        WHERE
          ord_main.facility_cd = @facilityCd
          AND pat_id = ANY (string_to_array(@paramList1, '','')::bigint[])
          AND ord_main.is_del = ''0''
          AND TO_DATE(ord_main.treat_date, ''YYYYMMDD'') >= CURRENT_DATE
      ) AS subquery
      LEFT JOIN (
        SELECT
          ntss_db5_ms.facility_cd,
          setting ->> ''code'' AS code,
          ROW_NUMBER() OVER() AS sortkey
        FROM
          ntss.mst_selector ntss_db5_ms
          CROSS JOIN LATERAL jsonb_array_elements((ntss_db5_ms.order_settings #> ''{"items"}'') ) setting
        WHERE
          ntss_db5_ms.facility_cd = @facilityCd
          AND ntss_db5_ms.master_physical_name = ''mst_treatment''
          AND setting ->> ''isDel'' = ''0''
          AND setting ->> ''isDisp'' = ''1''
      ) AS ntss_db5_mst_sel ON subquery.facility_cd = ntss_db5_mst_sel.facility_cd
      AND subquery.ind_treatment_cd :: TEXT = ntss_db5_mst_sel.code
    WHERE
      TO_DATE(treat_date, ''YYYYMMDD'') = min_treatment_date
  ),
  ind_ord_main AS (
    SELECT
      *
    FROM
      ind_ord_main_before_rank
    WHERE
      priority = 1
  ),
  -- pat_mainのデータ取得START
  ntss_db5_pm_dsi AS (
    SELECT
      ntss_db5_pm.pat_id AS pat_id,
      ''dev-A-'' || lpad(value_3.KEY, 4, ''0'') AS elemkey,
      ntss_db5_pm.up_date :: text,
      value_3.VALUE AS value_4
    FROM
      ntss_db5_pm
      JOIN jsonb_each_text(ntss_db5_pm.device_set_info) AS keysandvalue ON TRUE
      JOIN jsonb_each_text((keysandvalue.VALUE :: jsonb #>> ''{dev,A}'') :: jsonb) AS value_3 ON TRUE
    WHERE
      ntss_db5_pm.device_set_info IS NOT NULL
      AND ntss_db5_pm.device_set_info <> ''[]''
      AND value_3.KEY IS NOT NULL
    UNION ALL
    SELECT
      ntss_db5_pm.pat_id AS pat_id,
      ''dev-B-'' || lpad(value_3.KEY, 4, ''0'') AS elemkey,
      ntss_db5_pm.up_date :: text,
      value_3.VALUE AS value_4
    FROM
      ntss_db5_pm
      JOIN jsonb_each_text(ntss_db5_pm.device_set_info :: jsonb) AS keysandvalue ON TRUE
      JOIN jsonb_each_text((keysandvalue.VALUE :: jsonb #>> ''{dev,B}'') :: jsonb) AS value_3 ON TRUE
    WHERE
      ntss_db5_pm.device_set_info IS NOT NULL
      AND ntss_db5_pm.device_set_info <> ''[]''
      AND value_3.KEY IS NOT NULL
    UNION ALL
    SELECT
      ntss_db5_pm.pat_id AS pat_id,
      ''pat-A-'' || lpad(value_3.KEY, 4, ''0'') AS elemkey,
      ntss_db5_pm.up_date :: text,
      value_3.VALUE AS value_4
    FROM
      ntss_db5_pm
      JOIN jsonb_each_text(ntss_db5_pm.device_set_info :: jsonb) AS keysandvalue ON TRUE
      JOIN jsonb_each_text((keysandvalue.VALUE :: jsonb #>> ''{pat,A}'') :: jsonb) AS value_3 ON TRUE
    WHERE
      ntss_db5_pm.device_set_info IS NOT NULL
      AND ntss_db5_pm.device_set_info <> ''[]''
      AND value_3.KEY IS NOT NULL
    UNION ALL
    SELECT
      ntss_db5_pm.pat_id AS pat_id,
      ''pat-B-'' || lpad(value_3.KEY, 4, ''0'') AS elemkey,
      ntss_db5_pm.up_date :: text,
      value_3.VALUE AS value_4
    FROM
      ntss_db5_pm
      JOIN jsonb_each_text(ntss_db5_pm.device_set_info :: jsonb) AS keysandvalue ON TRUE
      JOIN jsonb_each_text((keysandvalue.VALUE :: jsonb #>> ''{pat,B}'') :: jsonb) AS value_3 ON TRUE
    WHERE
      ntss_db5_pm.device_set_info IS NOT NULL
      AND ntss_db5_pm.device_set_info <> ''[]''
      AND value_3.KEY IS NOT NULL
  ), -- pat_mainのデータ取得END
  -- ord_main,pat_treatment_patternのind_device_set_infoデータ取得START
  ntss_db5_ptp_week_date AS (
    SELECT
      ntss_db5_ptp.pat_id,
      ntss_db5_ptp.treat_week,
      max(ntss_db5_ptp.ind_treat_start_date) AS max_ind_treat_start_date
    FROM
      ntss.pat_treatment_pattern ntss_db5_ptp
    WHERE
      ntss_db5_ptp.facility_cd = @facilityCd
      AND pat_id = ANY (string_to_array(@paramList1, '','')::bigint[])
      AND ntss_db5_ptp.ind_treat_start_date :: date <= current_date
    GROUP BY
      ntss_db5_ptp.pat_id,
      ntss_db5_ptp.treat_week
  ),
  ntss_db5_ptp_week_bef_rank AS (
    SELECT
      ntss_db5_ptp.pat_id,
      ntss_db5_ptp.treat_week,
      ntss_db5_ptp.ctl_no,
      ntss_db5_ptp_week_date.max_ind_treat_start_date,
      ntss_db5_ptp.up_date,
      RANK() OVER (
        PARTITION BY ntss_db5_ptp.pat_id,
        ntss_db5_ptp.treat_week
        ORDER BY
          CASE
            WHEN ntss_db5_ptp.ind_kur_cd = ''0'' THEN 2
            ELSE 1
          END,
          CASE
            WHEN ntss_db5_ptp.ind_kur_cd = ''0'' THEN ntss_db5_mst_sel.sortkey :: integer
            ELSE (
              ntss_db5_ptp.ind_sch_info ->> ''ind_treat_start_time''
            ) :: integer
          END,
          ntss_db5_mst_sel.sortkey
      ) AS priority,
      ntss_db5_ptp.facility_cd,
      ntss_db5_ptp.ind_sch_info,
      ntss_db5_ptp.ind_cond_info,
      ntss_db5_ptp.ind_device_set_info
    FROM
      ntss.pat_treatment_pattern ntss_db5_ptp
      INNER JOIN ntss_db5_ptp_week_date ON ntss_db5_ptp.pat_id = ntss_db5_ptp_week_date.pat_id
      AND ntss_db5_ptp.treat_week = ntss_db5_ptp_week_date.treat_week
      AND ntss_db5_ptp.ind_treat_start_date = ntss_db5_ptp_week_date.max_ind_treat_start_date
      LEFT JOIN (
        SELECT
          ntss_db5_ms.facility_cd,
          setting ->> ''code'' AS code,
          ROW_NUMBER() OVER() AS sortkey
        FROM
          ntss.mst_selector ntss_db5_ms
          CROSS JOIN LATERAL jsonb_array_elements((ntss_db5_ms.order_settings #> ''{"items"}'') :: jsonb) setting
        WHERE
          ntss_db5_ms.facility_cd = @facilityCd
          AND ntss_db5_ms.master_physical_name = ''mst_treatment''
          AND setting ->> ''isDel'' = ''0''
          AND setting ->> ''isDisp'' = ''1''
      ) ntss_db5_mst_sel ON ntss_db5_ptp.facility_cd = ntss_db5_mst_sel.facility_cd
      AND ntss_db5_ptp.ind_treatment_cd :: TEXT = ntss_db5_mst_sel.code
    WHERE
      ntss_db5_ptp.facility_cd = @facilityCd
      AND ntss_db5_ptp.ind_device_set_info IS NOT NULL
      AND ntss_db5_ptp.ind_device_set_info <> ''[]''
  ),
  ntss_db5_ptp_week AS (
    SELECT
      *
    FROM
      ntss_db5_ptp_week_bef_rank
    WHERE
      priority = 1
  ),
  yellow_idsi AS (
    SELECT
      ntss_db5_ptp_week.pat_id AS pat_id,
      ntss_db5_ptp_week.treat_week,
      ntss_db5_ptp_week.max_ind_treat_start_date AS up_date,
      ''dev-A-'' || lpad(value_3.KEY, 4, ''0'') AS elemkey,
      value_3.VALUE AS value_4,
      1 AS priority
    FROM
      ntss_db5_ptp_week
      JOIN jsonb_each_text(ntss_db5_ptp_week.ind_device_set_info :: jsonb) AS keysandvalue ON TRUE
      JOIN jsonb_each_text((keysandvalue.VALUE :: jsonb #>> ''{dev,A}'') :: jsonb) AS value_3 ON TRUE
    WHERE
      ntss_db5_ptp_week.facility_cd = @facilityCd
      AND ntss_db5_ptp_week.priority = 1
      AND ntss_db5_ptp_week.ind_device_set_info IS NOT NULL
      AND ntss_db5_ptp_week.ind_device_set_info <> ''[]''
    UNION ALL
    SELECT
      ntss_db5_ptp_week.pat_id AS pat_id,
      ntss_db5_ptp_week.treat_week,
      ntss_db5_ptp_week.max_ind_treat_start_date AS up_date,
      ''dev-B-'' || lpad(value_3.KEY, 4, ''0'') AS elemkey,
      value_3.VALUE AS value_4,
      1 AS priority
    FROM
      ntss_db5_ptp_week
      JOIN jsonb_each_text(ntss_db5_ptp_week.ind_device_set_info :: jsonb) AS keysandvalue ON TRUE
      JOIN jsonb_each_text((keysandvalue.VALUE :: jsonb #>> ''{dev,B}'') :: jsonb) AS value_3 ON TRUE
    WHERE
      ntss_db5_ptp_week.facility_cd = @facilityCd
      AND ntss_db5_ptp_week.priority = 1
      AND ntss_db5_ptp_week.ind_device_set_info IS NOT NULL
      AND ntss_db5_ptp_week.ind_device_set_info <> ''[]''
    UNION ALL
    SELECT
      ind_ord_main.pat_id AS pat_id,
      ind_ord_main.treat_week,
      ind_ord_main.up_date :: text,
      ''dev-A-'' || lpad(value_3.KEY, 4, ''0'') AS elemkey,
      value_3.VALUE AS value_4,
      2 AS priority
    FROM
      ind_ord_main
      JOIN jsonb_each_text(ind_ord_main.ind_device_set_info :: jsonb) AS keysandvalue ON TRUE
      JOIN jsonb_each_text((keysandvalue.VALUE :: jsonb #>> ''{dev,A}'') :: jsonb) AS value_3 ON TRUE
    WHERE
      ind_ord_main.ind_device_set_info IS NOT NULL
      AND ind_ord_main.ind_device_set_info <> ''[]''
    UNION ALL
    SELECT
      ind_ord_main.pat_id AS pat_id,
      ind_ord_main.treat_week,
      ind_ord_main.up_date :: text,
      ''dev-B-'' || lpad(value_3.KEY, 4, ''0'') AS elemkey,
      value_3.VALUE AS value_4,
      2 AS priority
    FROM
      ind_ord_main
      JOIN jsonb_each_text(ind_ord_main.ind_device_set_info :: jsonb) AS keysandvalue ON TRUE
      JOIN jsonb_each_text((keysandvalue.VALUE :: jsonb #>> ''{dev,B}'') :: jsonb) AS value_3 ON TRUE
    WHERE
      ind_ord_main.ind_device_set_info IS NOT NULL
      AND ind_ord_main.ind_device_set_info <> ''[]''
  ), -- ord_main,pat_treatment_patternのind_device_set_infoデータ取得END
  -- ord_main,pat_treatment_patternのind_cond_infoデータ取得START
  ntss_db5_pu_physical AS (
    SELECT
      ntss_db5_pu.pat_id,
      physical_info_json ->> ''dw'' AS dw,
      RANK() OVER (
        PARTITION BY ntss_db5_pu.pat_id
        ORDER BY
          physical_info_json ->> ''inspect_date'' DESC,
          physical_info_json ->> ''exam_date'' DESC
      ) AS priority,
      (ROW_NUMBER() OVER(PARTITION BY ntss_db5_pu.pat_id)) AS sortkey
    FROM
      pat_unique ntss_db5_pu
      INNER JOIN ntss_db5_pm ON ntss_db5_pu.pat_id = ntss_db5_pm.pat_id
      AND ntss_db5_pu.facility_cd = ntss_db5_pm.facility_cd
      CROSS JOIN LATERAL jsonb_array_elements(ntss_db5_pu.physical_info :: jsonb) AS physical_info_json
    WHERE ntss_db5_pu.is_del = ''0''
  ),
  ind_cond_info AS (
    SELECT
      ntss_db5_ptp_week.pat_id :: integer,
      ntss_db5_ptp_week.treat_week :: integer,
      ntss_db5_ptp_week.max_ind_treat_start_date :: TEXT AS up_date,
      elements.elemkey,
      CASE
        elements.ctlno
        WHEN ''81'' THEN ntss_db5_ptp_week.ind_cond_info #>> ''{33,value}''
        WHEN ''150'' THEN ntss_db5_ptp_week.ind_cond_info #>> ''{3,value}''
        WHEN ''151'' THEN ntss_db5_ptp_week.ind_cond_info #>> ''{14,value}''
        WHEN ''189'' THEN ntss_db5_ptp_week.ind_cond_info #>> ''{14,value}''
        WHEN ''231'' THEN ntss_db5_ptp_week.ind_cond_info #>> ''{24,value}''
        WHEN ''232'' THEN ntss_db5_ptp_week.ind_cond_info #>> ''{23,value}''
        WHEN ''233'' THEN ntss_db5_ptp_week.ind_cond_info #>> ''{20,value}''
        WHEN ''239'' THEN ntss_db5_ptp_week.ind_cond_info #>> ''{21,value}''
        ELSE NULL
      END AS value_4,
      1 AS priority
    FROM
      ntss_db5_ptp_week
      JOIN elements ON elements.datapattern = ''3''
    WHERE
      ntss_db5_ptp_week.ind_cond_info IS NOT NULL
      AND ntss_db5_ptp_week.ind_cond_info <> ''[]''
    UNION ALL
    SELECT
      ind_ord_main.pat_id :: integer,
      ind_ord_main.treat_week :: integer,
      ind_ord_main.up_date :: TEXT,
      elements.elemkey,
      CASE
        elements.ctlno
        WHEN ''81'' THEN ind_ord_main.ind_cond_info #>> ''{33,value}''
        WHEN ''150'' THEN ind_ord_main.ind_cond_info #>> ''{3,value}''
        WHEN ''151'' THEN ind_ord_main.ind_cond_info #>> ''{14,value}''
        WHEN ''189'' THEN ind_ord_main.ind_cond_info #>> ''{14,value}''
        WHEN ''231'' THEN ind_ord_main.ind_cond_info #>> ''{24,value}''
        WHEN ''232'' THEN ind_ord_main.ind_cond_info #>> ''{23,value}''
        WHEN ''233'' THEN ind_ord_main.ind_cond_info #>> ''{20,value}''
        WHEN ''239'' THEN ind_ord_main.ind_cond_info #>> ''{21,value}''
        ELSE NULL
      END AS value_4,
      2 AS priority
    FROM
      ind_ord_main
      JOIN elements ON elements.datapattern = ''3''
    WHERE
      ind_ord_main.ind_cond_info IS NOT NULL
      AND ind_ord_main.ind_cond_info <> ''[]''
  ), -- ord_main,pat_treatment_patternのind_cond_infoデータ取得END
  -- ベッド情報取得START
  ptp_machine AS (
    SELECT
      ntss_db5_ptp_week.pat_id AS pat_id,
      ntss_db5_ptp_week.treat_week,
      ntss_db5_mm.up_date,
      ntss_db5_mm.tmp_center_hd,
      ntss_db5_mm.tmp_center_ecum,
      ntss_db5_mm.tmp_center_hdf,
      ntss_db5_mm.tmp_center_hf,
      ntss_db5_mm.tmp_center_ohdf,
      ntss_db5_mm.tmp_center_ohf,
      1 AS priority
    FROM
      ntss_db5_ptp_week
      INNER JOIN ntss.mst_bed ntss_db5_mb ON ntss_db5_ptp_week.ind_sch_info ->> ''ind_bed_cd'' = ntss_db5_mb.bed_cd :: TEXT
      AND ntss_db5_ptp_week.facility_cd = ntss_db5_mb.facility_cd
      AND ntss_db5_mb.is_del = ''0''
      AND ntss_db5_mb.is_disp = ''1''
      INNER JOIN ntss.mst_machine ntss_db5_mm ON ntss_db5_mb.machine_no = ntss_db5_mm.machine_no
      AND ntss_db5_ptp_week.facility_cd = ntss_db5_mm.facility_cd
      AND ntss_db5_mm.is_del = ''0''
      AND ntss_db5_mm.is_disp = ''1''
    WHERE
      ntss_db5_ptp_week.ind_sch_info IS NOT NULL
      AND ntss_db5_ptp_week.ind_sch_info <> ''[]''
  ),
  om_machine AS (
    SELECT
      ind_ord_main.pat_id AS pat_id,
      ind_ord_main.treat_week,
      ntss_db5_mm.up_date,
      ntss_db5_mm.tmp_center_hd,
      ntss_db5_mm.tmp_center_ecum,
      ntss_db5_mm.tmp_center_hdf,
      ntss_db5_mm.tmp_center_hf,
      ntss_db5_mm.tmp_center_ohdf,
      ntss_db5_mm.tmp_center_ohf,
      2 AS priority
    FROM
      ind_ord_main
      INNER JOIN ntss.mst_bed ntss_db5_mb ON ind_ord_main.ind_bed_cd = ntss_db5_mb.bed_cd
      AND ind_ord_main.facility_cd = ntss_db5_mb.facility_cd
      AND ntss_db5_mb.is_del = ''0''
      AND ntss_db5_mb.is_disp = ''1''
      INNER JOIN ntss.mst_machine ntss_db5_mm ON ntss_db5_mb.machine_no = ntss_db5_mm.machine_no
      AND ind_ord_main.facility_cd = ntss_db5_mm.facility_cd
      AND ntss_db5_mm.is_del = ''0''
      AND ntss_db5_mm.is_disp = ''1''
    WHERE
      ind_ord_main.ind_bed_cd IS NOT NULL
  ),
  combined_machine AS (
    SELECT
      pat_id,
      treat_week,
      up_date,
      tmp_center_hd,
      tmp_center_ecum,
      tmp_center_hdf,
      tmp_center_hf,
      tmp_center_ohdf,
      tmp_center_ohf,
      priority
    FROM ptp_machine
    UNION ALL
    SELECT
      pat_id,
      treat_week,
      up_date,
      tmp_center_hd,
      tmp_center_ecum,
      tmp_center_hdf,
      tmp_center_hf,
      tmp_center_ohdf,
      tmp_center_ohf,
      priority
    FROM om_machine
  ),
  ranked_machine AS (
    SELECT
    *,
    ROW_NUMBER() OVER(PARTITION BY pat_id, treat_week ORDER BY priority) AS rn
  FROM combined_machine
  ),
  ranked_machine_info AS (
    SELECT
      pat_id,
      treat_week,
      up_date,
      tmp_center_hd,
      tmp_center_ecum,
      tmp_center_hdf,
      tmp_center_hf,
      tmp_center_ohdf,
      tmp_center_ohf,
      priority
    FROM ranked_machine
    WHERE rn = 1
  ),
  ptp_om_machine_info AS (
    SELECT
      pat_id,
      treat_week,
      up_date,
      elements.elemkey,
      CASE
        elements.elemkey
        WHEN ''tmp_center_hd'' THEN tmp_center_hd
        WHEN ''tmp_center_ecum'' THEN tmp_center_ecum
        WHEN ''tmp_center_hdf'' THEN tmp_center_hdf
        WHEN ''tmp_center_hf'' THEN tmp_center_hf
        WHEN ''tmp_center_ohdf'' THEN tmp_center_ohdf
        WHEN ''tmp_center_ohf'' THEN tmp_center_ohf
      END AS value_4
    FROM
      ranked_machine_info
      JOIN elements ON elements.datapattern = ''5''
  ), -- ベッド情報取得END
  -- ダイアライザ情報取得START
  ptp_dialyzer_info AS (
    SELECT
      ntss_db5_ptp_week.pat_id AS pat_id,
      ntss_db5_ptp_week.treat_week,
      COALESCE(ntss_db5_md.up_date,ntss_db5_ptp_week.up_date) AS up_date,
      ntss_db5_md.ufr_warning_max,
      ntss_db5_md.ufr_warning_min,
      ntss_db5_md.ufr_warning_reduction,
      ntss_db5_md.koa,
      COALESCE(ntss_db5_md.dialyzer_type,''0'') AS dialyzer_type,
      1 AS priority
    FROM
      ntss_db5_ptp_week
      left JOIN ntss.mst_dialyzer ntss_db5_md ON ntss_db5_md.facility_cd = ntss_db5_ptp_week.facility_cd
      AND ntss_db5_md.dialyzer_cd :: text = ntss_db5_ptp_week.ind_cond_info #>> ''{5,value}''
      AND ntss_db5_md.facility_cd = @facilityCd
      AND ntss_db5_md.is_del = ''0''
      AND ntss_db5_md.is_disp = ''1''
    WHERE 1 = 1
      AND ntss_db5_ptp_week.ind_cond_info IS NOT NULL
      AND ntss_db5_ptp_week.ind_cond_info <> ''[]''  
  ),
  om_dialyzer_info AS (
    SELECT
      ind_ord_main.pat_id AS pat_id,
      ind_ord_main.treat_week,
      COALESCE(ntss_db5_md.up_date,ind_ord_main.up_date) AS up_date,
      ntss_db5_md.ufr_warning_max,
      ntss_db5_md.ufr_warning_min,
      ntss_db5_md.ufr_warning_reduction,
      ntss_db5_md.koa,
      COALESCE(ntss_db5_md.dialyzer_type,''0'') AS dialyzer_type,
      2 AS priority
    FROM
      ind_ord_main
      left JOIN ntss.mst_dialyzer ntss_db5_md ON ntss_db5_md.facility_cd = ind_ord_main.facility_cd
      AND ntss_db5_md.dialyzer_cd :: text = ind_ord_main.ind_cond_info #>> ''{5,value}''
      AND ntss_db5_md.facility_cd = @facilityCd
      AND ntss_db5_md.is_del = ''0''
      AND ntss_db5_md.is_disp = ''1''
    WHERE 1 = 1
      AND ind_ord_main.ind_cond_info IS NOT NULL
      AND ind_ord_main.ind_cond_info <> ''[]''
  ),
  RankedInfo AS (
    SELECT
      pat_id,
      treat_week,
      up_date,
      ufr_warning_max,
      ufr_warning_min,
      ufr_warning_reduction,
      koa,
      dialyzer_type,
      ROW_NUMBER() OVER (
        PARTITION BY pat_id,
        treat_week
        ORDER BY
          CASE
            WHEN source = ''ptp'' THEN 1
            ELSE 2
          END,
          up_date DESC
      ) AS rn
    FROM
      (
        SELECT
          pat_id,
          treat_week,
          up_date,
          ufr_warning_max,
          ufr_warning_min,
          ufr_warning_reduction,
          koa,
          dialyzer_type,
          ''ptp'' AS source
        FROM
          ptp_dialyzer_info
        UNION ALL
        SELECT
          pat_id,
          treat_week,
          up_date,
          ufr_warning_max,
          ufr_warning_min,
          ufr_warning_reduction,
          koa,
          dialyzer_type,
          ''om'' AS source
        FROM
          om_dialyzer_info
      ) AS combined_info
  ),
  priority_dialyzer_info AS (
    SELECT
      pat_id,
      treat_week,
      up_date,
      ufr_warning_max,
      ufr_warning_min,
      ufr_warning_reduction,
      koa,
      dialyzer_type
    FROM
      RankedInfo
    WHERE
      rn = 1
  ),
  ind_ord_main_ptp_dialyzer AS (
    SELECT
      pat_id,
      treat_week,
      up_date,
      elements.elemkey,
      CASE
        elements.elemkey
        WHEN ''ufr_warning_max'' THEN ufr_warning_max :: text
        WHEN ''ufr_warning_min'' THEN ufr_warning_min :: text
        WHEN ''ufr_warning_reduction'' THEN ufr_warning_reduction :: text
        WHEN ''koa'' THEN koa :: text
        WHEN ''dialyzer_type'' THEN dialyzer_type :: text
      END AS value_4
    FROM
      priority_dialyzer_info
      JOIN elements ON elements.datapattern = ''4''
  ), -- ダイアライザ情報取得END
  -- 各曜日のデータ集計
  ind_ord_main_ptp_dsi AS (
    SELECT
      pat_id :: integer,
      treat_week :: integer,
      up_date :: text,
      elemkey :: text,
      value_4 :: text
    FROM
      yellow_idsi
    WHERE
      EXISTS (
        SELECT
          1
        FROM
          (
            SELECT
              pat_id,
              treat_week,
              elemkey,
              min(priority) AS min_priority
            FROM
              yellow_idsi
            GROUP BY
              pat_id,
              treat_week,
              elemkey
          ) AS priority_device
        WHERE
          yellow_idsi.pat_id = priority_device.pat_id
          AND yellow_idsi.treat_week = priority_device.treat_week
          AND yellow_idsi.elemkey = priority_device.elemkey
          AND yellow_idsi.priority = priority_device.min_priority
      )
    UNION ALL
    SELECT
      pat_id :: integer,
      treat_week :: integer,
      up_date :: text,
      elemkey :: text,
      value_4 :: text
    FROM
      ptp_om_machine_info
    UNION ALL
    SELECT
      pat_id :: integer,
      treat_week :: integer,
      up_date :: text,
      elemkey :: text,
      value_4 :: text
    FROM
      ind_ord_main_ptp_dialyzer
    UNION ALL
    SELECT
      DISTINCT ind_cond_info.pat_id :: integer,
      ind_cond_info.treat_week :: integer,
      ind_cond_info.up_date :: text,
      ind_cond_info.elemkey :: text,
      CASE
        WHEN ind_cond_info.elemkey = ''ind_cond_info-3-value''
        AND ind_cond_info.value_4 = ''-1'' THEN ntss_db5_pu_physical.dw
        ELSE ind_cond_info.value_4 :: TEXT
      END AS value_4
    FROM
      ind_cond_info
      LEFT JOIN ntss_db5_pu_physical ON ind_cond_info.pat_id = ntss_db5_pu_physical.pat_id
      AND ntss_db5_pu_physical.priority = ''1''
      AND ntss_db5_pu_physical.sortkey = ''1''
    WHERE
      EXISTS (
        SELECT
          1
        FROM
          (
            SELECT
              pat_id,
              treat_week,
              elemkey,
              min(priority) AS min_priority
            FROM
              ind_cond_info
            GROUP BY
              pat_id,
              treat_week,
              elemkey
          ) AS priority_cond
        WHERE
          ind_cond_info.pat_id = priority_cond.pat_id
          AND ind_cond_info.treat_week = priority_cond.treat_week
          AND ind_cond_info.elemkey = priority_cond.elemkey
          AND ind_cond_info.priority = priority_cond.min_priority
      )
    UNION ALL
    SELECT
      ntss_db5_ptp_week.pat_id :: integer,
      ntss_db5_ptp_week.treat_week :: integer,
      ntss_db5_ptp_week.max_ind_treat_start_date :: text AS up_date,
      elements.elemkey :: text,
      elements.defaultvalue :: text AS value_4
    FROM
      ntss_db5_ptp_week
      JOIN elements ON elements.datapattern = ''7''
    WHERE
      ntss_db5_ptp_week.priority = ''1''
  ),
  ind_ord_main_ptp_dsi_days AS (
    SELECT 
      ind_ord_main_ptp_dsi.pat_id,
      ind_ord_main_ptp_dsi.elemkey,
      max(case when ind_ord_main_ptp_dsi.treat_week = EXTRACT(ISODOW FROM CURRENT_DATE) then ind_ord_main_ptp_dsi.up_date else null end) as up_date_0,
      max(case when ind_ord_main_ptp_dsi.treat_week = EXTRACT(ISODOW FROM CURRENT_DATE) then ind_ord_main_ptp_dsi.value_4 else null end) as value_4_0,
      max(case when ind_ord_main_ptp_dsi.treat_week = ''1'' then ind_ord_main_ptp_dsi.up_date else null end) as up_date_1,
      max(case when ind_ord_main_ptp_dsi.treat_week = ''1'' then ind_ord_main_ptp_dsi.value_4 else null end) as value_4_1,
      max(case when ind_ord_main_ptp_dsi.treat_week = ''2'' then ind_ord_main_ptp_dsi.up_date else null end) as up_date_2,
      max(case when ind_ord_main_ptp_dsi.treat_week = ''2'' then ind_ord_main_ptp_dsi.value_4 else null end) as value_4_2,
      max(case when ind_ord_main_ptp_dsi.treat_week = ''3'' then ind_ord_main_ptp_dsi.up_date else null end) as up_date_3,
      max(case when ind_ord_main_ptp_dsi.treat_week = ''3'' then ind_ord_main_ptp_dsi.value_4 else null end) as value_4_3,
      max(case when ind_ord_main_ptp_dsi.treat_week = ''4'' then ind_ord_main_ptp_dsi.up_date else null end) as up_date_4,
      max(case when ind_ord_main_ptp_dsi.treat_week = ''4'' then ind_ord_main_ptp_dsi.value_4 else null end) as value_4_4,
      max(case when ind_ord_main_ptp_dsi.treat_week = ''5'' then ind_ord_main_ptp_dsi.up_date else null end) as up_date_5,
      max(case when ind_ord_main_ptp_dsi.treat_week = ''5'' then ind_ord_main_ptp_dsi.value_4 else null end) as value_4_5,
      max(case when ind_ord_main_ptp_dsi.treat_week = ''6'' then ind_ord_main_ptp_dsi.up_date else null end) as up_date_6,
      max(case when ind_ord_main_ptp_dsi.treat_week = ''6'' then ind_ord_main_ptp_dsi.value_4 else null end) as value_4_6,
      max(case when ind_ord_main_ptp_dsi.treat_week = ''7'' then ind_ord_main_ptp_dsi.up_date else null end) as up_date_7,
      max(case when ind_ord_main_ptp_dsi.treat_week = ''7'' then ind_ord_main_ptp_dsi.value_4 else null end) as value_4_7
    FROM 
      ind_ord_main_ptp_dsi
    GROUP BY 
      ind_ord_main_ptp_dsi.pat_id, ind_ord_main_ptp_dsi.elemkey
  ),
  --select5
  elements_extended AS (
    SELECT
      *,
      CASE
        WHEN elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'') THEN ''0''
        ELSE NULL
      END AS fixed_value,
      CASE
        WHEN elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'') THEN NULL
        ELSE NULL
      END AS fixed_update
    FROM
      elements
  )
SELECT
  ntss_db5_pm.pat_id AS patid,
  '''' AS hosppatid,
  '''' AS name,
  elements_extended.ctlno AS ctlno,
  elements_extended.setname AS setname,
  COALESCE(
    elements_extended.fixed_value,
    CASE
      elements_extended.datapattern
      WHEN ''1'' THEN ntss_db5_pm_dsi.value_4
      WHEN ''7'' THEN elements_extended.defaultvalue
      ELSE ind_ord_main_ptp_dsi_days.value_4_0
    END
  ) AS value,
  to_char(
    CASE
      WHEN elements_extended.elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'',''0000'') THEN ntss_db5_pm.up_date :: timestamp
      WHEN elements_extended.datapattern = ''1'' THEN ntss_db5_pm_dsi.up_date :: timestamp
      ELSE ind_ord_main_ptp_dsi_days.up_date_0 :: timestamp
    END,
    ''YYYY-MM-DD hh24:mi:ss''
  ) AS
update
,
  COALESCE(
    elements_extended.fixed_value,
    CASE
      elements_extended.datapattern
      WHEN ''1'' THEN ntss_db5_pm_dsi.value_4
      WHEN ''7'' THEN elements_extended.defaultvalue
      ELSE ind_ord_main_ptp_dsi_days.value_4_1
    END
  ) AS monvalue,
  to_char(
    CASE
      WHEN elements_extended.elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'',''0000'') THEN ntss_db5_pm.up_date :: timestamp
      WHEN elements_extended.datapattern = ''1'' THEN ntss_db5_pm_dsi.up_date :: timestamp
      ELSE ind_ord_main_ptp_dsi_days.up_date_1 :: timestamp
    END,
    ''YYYY-MM-DD hh24:mi:ss''
  ) AS monupdate,
  COALESCE(
    elements_extended.fixed_value,
    CASE
      elements_extended.datapattern
      WHEN ''1'' THEN ntss_db5_pm_dsi.value_4
      WHEN ''7'' THEN elements_extended.defaultvalue
      ELSE ind_ord_main_ptp_dsi_days.value_4_2
    END
  ) AS tuevalue,
  to_char(
    CASE
      WHEN elements_extended.elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'',''0000'') THEN ntss_db5_pm.up_date :: timestamp
      WHEN elements_extended.datapattern = ''1'' THEN ntss_db5_pm_dsi.up_date :: timestamp
      ELSE ind_ord_main_ptp_dsi_days.up_date_2 :: timestamp
    END,
    ''YYYY-MM-DD hh24:mi:ss''
  ) AS tueupdate,
  COALESCE(
    elements_extended.fixed_value,
    CASE
      elements_extended.datapattern
      WHEN ''1'' THEN ntss_db5_pm_dsi.value_4
      WHEN ''7'' THEN elements_extended.defaultvalue
      ELSE ind_ord_main_ptp_dsi_days.value_4_3
    END
  ) AS wedvalue,
  to_char(
    CASE
      WHEN elements_extended.elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'',''0000'') THEN ntss_db5_pm.up_date :: timestamp
      WHEN elements_extended.datapattern = ''1'' THEN ntss_db5_pm_dsi.up_date :: timestamp
      ELSE ind_ord_main_ptp_dsi_days.up_date_3 :: timestamp
    END,
    ''YYYY-MM-DD hh24:mi:ss''
  ) AS wedupdate,
  COALESCE(
    elements_extended.fixed_value,
    CASE
      elements_extended.datapattern
      WHEN ''1'' THEN ntss_db5_pm_dsi.value_4
      WHEN ''7'' THEN elements_extended.defaultvalue
      ELSE ind_ord_main_ptp_dsi_days.value_4_4
    END
  ) AS thuvalue,
  to_char(
    CASE
      WHEN elements_extended.elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'',''0000'') THEN ntss_db5_pm.up_date :: timestamp
      WHEN elements_extended.datapattern = ''1'' THEN ntss_db5_pm_dsi.up_date :: timestamp
      ELSE ind_ord_main_ptp_dsi_days.up_date_4 :: timestamp
    END,
    ''YYYY-MM-DD hh24:mi:ss''
  ) AS thuupdate,
  COALESCE(
    elements_extended.fixed_value,
    CASE
      elements_extended.datapattern
      WHEN ''1'' THEN ntss_db5_pm_dsi.value_4
      WHEN ''7'' THEN elements_extended.defaultvalue
      ELSE ind_ord_main_ptp_dsi_days.value_4_5
    END
  ) AS frivalue,
  to_char(
    CASE
      WHEN elements_extended.elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'',''0000'') THEN ntss_db5_pm.up_date :: timestamp
      WHEN elements_extended.datapattern = ''1'' THEN ntss_db5_pm_dsi.up_date :: timestamp
      ELSE ind_ord_main_ptp_dsi_days.up_date_5 :: timestamp
    END,
    ''YYYY-MM-DD hh24:mi:ss''
  ) AS friupdate,
  COALESCE(
    elements_extended.fixed_value,
    CASE
      elements_extended.datapattern
      WHEN ''1'' THEN ntss_db5_pm_dsi.value_4
      WHEN ''7'' THEN elements_extended.defaultvalue
      ELSE ind_ord_main_ptp_dsi_days.value_4_6
    END
  ) AS satvalue,
  to_char(
    CASE
      WHEN elements_extended.elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'',''0000'') THEN ntss_db5_pm.up_date :: timestamp
      WHEN elements_extended.datapattern = ''1'' THEN ntss_db5_pm_dsi.up_date :: timestamp
      ELSE ind_ord_main_ptp_dsi_days.up_date_6 :: timestamp
    END,
    ''YYYY-MM-DD hh24:mi:ss''
  ) AS satupdate,
  COALESCE(
    elements_extended.fixed_value,
    CASE
      elements_extended.datapattern
      WHEN ''1'' THEN ntss_db5_pm_dsi.value_4
      WHEN ''7'' THEN elements_extended.defaultvalue
      ELSE ind_ord_main_ptp_dsi_days.value_4_7
    END
  ) AS sunvalue,
  to_char(
    CASE
      WHEN elements_extended.elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'',''0000'') THEN ntss_db5_pm.up_date :: timestamp
      WHEN elements_extended.datapattern = ''1'' THEN ntss_db5_pm_dsi.up_date :: timestamp
      ELSE ind_ord_main_ptp_dsi_days.up_date_7 :: timestamp
    END,
    ''YYYY-MM-DD hh24:mi:ss''
  ) AS sunupdate
FROM
  ntss_db5_pm
  JOIN elements_extended ON TRUE
  LEFT JOIN ntss_db5_pm_dsi ON ntss_db5_pm.pat_id = ntss_db5_pm_dsi.pat_id
  AND elements_extended.elemkey = ntss_db5_pm_dsi.elemkey
  LEFT JOIN ind_ord_main_ptp_dsi_days ON ntss_db5_pm.pat_id = ind_ord_main_ptp_dsi_days.pat_id
  AND elements_extended.elemkey = ind_ord_main_ptp_dsi_days.elemkey;', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2501, 'WITH last_weight_table AS ( --前回体重導出用
SELECT ord_no, last_weight FROM (
    SELECT
        om.ord_no AS ord_no
        ,LAG(rst_weight_info, -1) OVER (PARTITION BY om.pat_id ORDER BY om.rst_start_date DESC) ->> ''weight_after'' AS last_weight
    FROM ord_main om
    JOIN mst_treatment m_tr
    ON om.rst_treatment_cd = m_tr.treatment_cd
    AND m_tr.facility_cd = @facilityCd
    WHERE om.facility_cd = @facilityCd
    AND om.is_del = ''0''
    AND m_tr.device_mode <> 9
    ) AS om2
),
re_loop_rate_table AS ( --再循環率
    SELECT
        om.ord_no AS ord_no
        , json_rr.value::jsonb ->> ''rate'' AS relooprate
    FROM (
        SELECT
            om.ord_no
            , om.rst_weight_info #>> ''{recrcl_rt, "valid_no"}'' AS valid_no
            , om.rst_weight_info #> ''{recrcl_rt}'' AS recrcl_rt
        FROM ord_main om
        WHERE om.facility_cd = @facilityCd
        AND om.rst_dialysis_state BETWEEN ''1'' AND''5''
        AND om.rst_weight_info IS NOT NULL
        AND om.rst_weight_info #> ''{recrcl_rt}'' <> ''null''
    ) AS om
    CROSS JOIN lateral jsonb_each_text(om.recrcl_rt::jsonb) json_rr
    WHERE json_rr.key = om.valid_no
)
SELECT
    '''' AS hosppatid --患者ID
    ,om.pat_id AS patid
    ,'''' AS name --氏名
    ,om.treat_date AS dialysisdate --透析日
    ,om.ord_no AS dialysisno --透析番号
    ,to_char(om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    ,m_b.in_hospital_cd_1 AS bedno --ベッド番号
    ,om.rst_bed_name AS bedname --ベッド名
    ,m_mac.in_hospital_cd_1 AS deviceno --装置番号
    ,om.rst_machine_name AS devicename --装置名
    ,m_k.in_hospital_cd_1 AS kurcd --クール
    ,om.rst_kur_name AS kurname --クール名
    ,to_char(om.rst_start_date, ''YYYY-MM-DD hh24:mi:ss'') AS startdate --透析開始日時
    ,to_char(om.rst_end_date, ''YYYY-MM-DD hh24:mi:ss'') AS enddate --透析終了日時
    ,round(date_part(''epoch'',om.rst_end_date - om.rst_start_date)::NUMERIC / 60) AS dialysistime --透析時間
    ,om.rst_cond_info ::jsonb #>> ''{1,value}'' AS plandialysistime --予定透析時間
    ,om.rst_dialysis_cnt AS dialysisnum --透析回数
    ,last_weight_table.last_weight AS lastweight --前回体重
    ,om.rst_weight_info #>> ''{weight_before}'' AS weightbefore --前体重
    ,om.rst_weight_info #>> ''{weight_after}'' AS weightafter --後体重
    ,mm_b.monitor_data ->> ''90''  AS bpbeforemax --透析前最高血圧
    ,mm_b.monitor_data ->> ''91''  AS bpbeforemin --透析前最低血圧
    ,mm_b.monitor_data ->> ''92''  AS bpbeforeave --透析前平均血圧
    ,mm_a.monitor_data ->> ''90''  AS bpaftermax --透析後最高血圧
    ,mm_a.monitor_data ->> ''91''  AS bpaftermin --透析後最低血圧
    ,mm_a.monitor_data ->> ''92''  AS bpafterave --透析後平均血圧
    ,om.rst_weight_info #>> ''{water_removal_target}'' AS waterremovaltarget --目標除水量
    ,om.rst_off_water_info #>> ''{name_1}'' AS revisename1 --除水補正項目１
    ,om.rst_off_water_info #>> ''{weight_1}'' AS reviseweight1 --除水補正値１
    ,om.rst_off_water_info #>> ''{name_2}'' AS revisename2 --除水補正項目２
    ,om.rst_off_water_info #>> ''{weight_2}'' AS reviseweight2 --除水補正値２
    ,om.rst_off_water_info #>> ''{name_3}'' AS revisename3 --除水補正項目３
    ,om.rst_off_water_info #>> ''{weight_3}'' AS reviseweight3 --除水補正値３
    ,om.rst_off_water_info #>> ''{name_4}'' AS revisename4 --除水補正項目４
    ,om.rst_off_water_info #>> ''{weight_4}'' AS reviseweight4 --除水補正値４
    ,om.rst_off_water_info #>> ''{name_5}'' AS revisename5 --除水補正項目５
    ,om.rst_off_water_info #>> ''{weight_5}'' AS reviseweight5 --除水補正値５
    ,mm_b.monitor_data ->> ''93'' AS pulsebefore --透析前脈拍
    ,mm_a.monitor_data ->> ''93'' AS pulseafter --透析後脈拍
    ,CONCAT(om.rst_charge_user_info #>> ''{user_last_name_1}''
        ,''　''
        , om.rst_charge_user_info #>> ''{user_first_name_1}'') AS charge1name --担当者１
    ,CONCAT(om.rst_charge_user_info #>> ''{user_last_name_2}''
        ,''　''
        , om.rst_charge_user_info #>> ''{user_first_name_2}'') AS charge2name --担当者２
    ,to_char((om.rst_charge_user_info #>> ''{date_1}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS chargedate1 --担当日時１
    ,to_char((om.rst_charge_user_info #>> ''{date_2}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS chargedate2 --担当日時２
    ,CONCAT(om.rst_puncture_user_info #>> ''{user_last_name_1}''
        ,''　''
        , om.rst_puncture_user_info #>> ''{user_first_name_1}'') AS puncture1name --穿刺者１
    ,CONCAT(om.rst_puncture_user_info #>> ''{user_last_name_2}''
        ,''　''
        , om.rst_puncture_user_info #>> ''{user_first_name_2}'') AS puncture2name --穿刺者２
    ,to_char((om.rst_puncture_user_info #>> ''{date_1}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS puncturedate1 --穿刺日時１
    ,to_char((om.rst_puncture_user_info #>> ''{date_2}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS puncturedate2 --穿刺日時２
    ,CONCAT(om.rst_return_user_info #>> ''{user_last_name_1}''
        ,''　''
        , om.rst_return_user_info #>> ''{user_first_name_1}'') AS collect1name --回収者１
    ,CONCAT(om.rst_return_user_info #>> ''{user_last_name_2}''
        ,''　''
        , om.rst_return_user_info #>> ''{user_first_name_2}'') AS collect2name --回収者２
    ,to_char((om.rst_return_user_info #>> ''{date_1}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS collectdate1 --回収日時１
    ,to_char((om.rst_return_user_info #>> ''{date_2}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS collectdate2 --回収日時２
    ,om.rst_in_out_class AS inoutflg --入外
    ,om.rst_weight_info #>> ''{kt_v_measure}'' AS ktvmeasure --Kt/v測定値
    ,om.rst_weight_info #>> ''{urr}'' AS urr --URR
    ,re_loop_rate_table.relooprate AS relooprate --再循環率
    ,om.rst_weight_info #>> ''{ihdf_pll}'' AS pullleaveamount --I-HDF引き残し量
    ,om.rst_weight_info #>> ''{sttc_vns_prssr}'' AS staticvenouspressure --静的静脈圧
    ,om.rst_weight_info #>> ''{iap_rt}'' AS venousaccesspressureratio --IAP ratio
FROM
    ord_main om
    LEFT JOIN mst_bed m_b
    ON m_b.bed_cd = om.rst_bed_cd
    AND m_b.facility_cd = @facilityCd
    AND m_b.is_del = ''0''
    AND m_b.is_disp = ''1''
    LEFT JOIN mst_machine m_mac
    ON m_mac.machine_no = om.rst_machine_no
    AND m_mac.facility_cd = @facilityCd
    AND m_mac.is_del = ''0''
    AND m_mac.is_disp = ''1''
    LEFT JOIN mst_kur m_k
    ON m_k.kur_cd = om.rst_kur_cd
    AND m_k.facility_cd = @facilityCd
    AND m_k.is_del = ''0''
    LEFT JOIN last_weight_table
    ON last_weight_table.ord_no = om.ord_no
    LEFT JOIN mni_monitor mm_b
    ON mm_b.ord_no = om.ord_no
    AND mm_b.facility_cd = @facilityCd
    AND mm_b.data_type = ''5''
    AND mm_b.monitor_data IS NOT NULL
    AND mm_b.is_del = ''0''
    LEFT JOIN mni_monitor mm_a
    ON mm_a.ord_no = om.ord_no
    AND mm_a.facility_cd = @facilityCd
    AND mm_a.data_type = ''6''
    AND mm_a.monitor_data IS NOT NULL
    AND mm_a.is_del = ''0''
    LEFT JOIN re_loop_rate_table
    ON re_loop_rate_table.ord_no = om.ord_no
WHERE
    om.is_del = ''0''
    AND om.facility_cd = @facilityCd
    AND om.rst_dialysis_state BETWEEN ''1'' AND''5''
    AND om.pat_id IS NOT NULL;
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid"]}', '2024-06-27 10:36:11.252', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2502, 'WITH
 ntss_db5_om_temp AS NOT MATERIALIZED (
    SELECT
        om.ord_no
        ,om.pat_id
        ,om.treat_date AS dialysisdate
        ,CAST(om.treat_date as DATE) AS treat_date
        ,om.rst_cond_info
        ,om.rst_treatment_cd
        ,om.up_date
        ,om.rst_dw
    FROM
        ord_main om
    WHERE
        om.facility_cd = @facilityCd
        AND om.is_del = ''0''
        AND om.rst_dialysis_state BETWEEN ''1'' AND ''5''
)
, ntss_db5_mst_t AS (
    SELECT
        ntss_db5_mst_t.treatment_cd
        , ntss_db5_mst_t.treatment_name
        , CAST(ntss_db5_mst_t.in_hosp_a_startdate AS date) AS in_hosp_a_startdate
        , ntss_db5_mst_t.in_hospital_cd_a1
        , ntss_db5_mst_t.in_hospital_cd_a2
        , CAST(ntss_db5_mst_t.in_hosp_b_startdate AS date) AS in_hosp_b_startdate
        , ntss_db5_mst_t.in_hospital_cd_b1
        , ntss_db5_mst_t.in_hospital_cd_b2
    FROM
        mst_treatment ntss_db5_mst_t
    WHERE
        ntss_db5_mst_t.facility_cd = @facilityCd
        AND ntss_db5_mst_t.is_del = ''0''
        AND ntss_db5_mst_t.is_disp = ''1''
)
, rst_cond_list AS (
    SELECT --rst_cond_info
        ntss_db5_om_temp.ord_no
        , rst_cond_info_json.key AS key
        , rst_cond_info_json.value::JSONB ->> ''value'' AS value
        , rst_cond_info_json.value::JSONB ->> ''value_name_1'' AS value_name_1
        , rst_cond_info_json.value::JSONB ->> ''unit'' AS unit
        , '''' AS valuecd2
        , rst_cond_info_json.value::JSONB ->> ''medicine_type'' AS medicine_type
    FROM
        ntss_db5_om_temp
        CROSS JOIN lateral jsonb_each_text(ntss_db5_om_temp.rst_cond_info::JSONB) rst_cond_info_json
    WHERE
        rst_cond_info_json.key IN(''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'',''12'',''14'',''15'',''16'',''17'',''18'',''19'',''20'',''21'',''22'',''23'',''24'',''25'',''26'',''27'',''28'',''29'',''30'',''31'',''32'',''33'',''34'',''35'',''36'',''37'',''38'')
    UNION ALL
    SELECT --dw
        ntss_db5_om_temp.ord_no
        , ''992'' AS key
        , CAST(ntss_db5_om_temp.rst_dw AS text) AS value
        , '''' AS value_name_1
        , ''kg'' AS unit
        , '''' AS valuecd2
        , '''' AS medicine_type
    FROM
        ntss_db5_om_temp
    UNION ALL
    SELECT --治療方法
        ntss_db5_om_temp.ord_no
        , ''993'' AS key
        , CASE
            WHEN ntss_db5_om_temp.treat_date >= ntss_db5_mst_t.in_hosp_a_startdate
            AND ntss_db5_om_temp.treat_date >= ntss_db5_mst_t.in_hosp_b_startdate
                THEN CASE
                    WHEN ntss_db5_mst_t.in_hosp_a_startdate >= ntss_db5_mst_t.in_hosp_b_startdate
                        THEN ntss_db5_mst_t.in_hospital_cd_a1
                    WHEN ntss_db5_mst_t.in_hosp_a_startdate < ntss_db5_mst_t.in_hosp_b_startdate
                        THEN ntss_db5_mst_t.in_hospital_cd_b1
                    END
            WHEN ntss_db5_om_temp.treat_date >= ntss_db5_mst_t.in_hosp_a_startdate
            AND (ntss_db5_om_temp.treat_date < ntss_db5_mst_t.in_hosp_b_startdate
                OR ntss_db5_mst_t.in_hosp_b_startdate IS NULL)
                THEN ntss_db5_mst_t.in_hospital_cd_a1
            WHEN (ntss_db5_om_temp.treat_date < ntss_db5_mst_t.in_hosp_a_startdate
                OR ntss_db5_mst_t.in_hosp_a_startdate IS NULL)
            AND ntss_db5_om_temp.treat_date >= ntss_db5_mst_t.in_hosp_b_startdate
                THEN ntss_db5_mst_t.in_hospital_cd_b1
            ELSE NULL
            END AS value
        , ntss_db5_mst_t.treatment_name AS value_name_1
        , '''' AS unit
        , CASE
            WHEN ntss_db5_om_temp.treat_date >= ntss_db5_mst_t.in_hosp_a_startdate
            AND ntss_db5_om_temp.treat_date >= ntss_db5_mst_t.in_hosp_b_startdate
                THEN CASE
                    WHEN ntss_db5_mst_t.in_hosp_a_startdate >= ntss_db5_mst_t.in_hosp_b_startdate
                        THEN ntss_db5_mst_t.in_hospital_cd_a2
                    WHEN ntss_db5_mst_t.in_hosp_a_startdate < ntss_db5_mst_t.in_hosp_b_startdate
                        THEN ntss_db5_mst_t.in_hospital_cd_b2
                    END
            WHEN ntss_db5_om_temp.treat_date >= ntss_db5_mst_t.in_hosp_a_startdate
            AND (ntss_db5_om_temp.treat_date < ntss_db5_mst_t.in_hosp_b_startdate
                OR ntss_db5_mst_t.in_hosp_b_startdate IS NULL)
                THEN ntss_db5_mst_t.in_hospital_cd_a2
            WHEN (ntss_db5_om_temp.treat_date < ntss_db5_mst_t.in_hosp_a_startdate
                OR ntss_db5_mst_t.in_hosp_a_startdate IS NULL)
            AND ntss_db5_om_temp.treat_date >= ntss_db5_mst_t.in_hosp_b_startdate
                THEN ntss_db5_mst_t.in_hospital_cd_b2
            ELSE NULL
            END AS valuecd2
        , '''' AS medicine_type
    FROM
        ntss_db5_om_temp
        LEFT JOIN ntss_db5_mst_t
        ON ntss_db5_om_temp.rst_treatment_cd = ntss_db5_mst_t.treatment_cd
)
, ntss_db5_mst_v AS (
    SELECT
        ntss_db5_mst_v.va_cd
        , ntss_db5_mst_v.in_hospital_cd_1
        , ntss_db5_mst_v.in_hospital_cd_2
    FROM
        mst_va ntss_db5_mst_v
    WHERE
        ntss_db5_mst_v.facility_cd = @facilityCd
        AND ntss_db5_mst_v.is_del = ''0''
        AND ntss_db5_mst_v.is_disp = ''1''
)
, ntss_db5_mst_d AS (
    SELECT
        ntss_db5_mst_d.dialyzer_cd
        , ntss_db5_mst_d.in_hospital_cd_1
        , ntss_db5_mst_d.in_hospital_cd_2
    FROM
        mst_dialyzer ntss_db5_mst_d
    WHERE
        ntss_db5_mst_d.facility_cd = @facilityCd
        AND ntss_db5_mst_d.is_del = ''0''
        AND ntss_db5_mst_d.is_disp = ''1''
)
, ntss_db5_mst_e AS (
    SELECT
        ntss_db5_mst_e.equipment_cd
        , ntss_db5_mst_e.in_hospital_cd_1
        , ntss_db5_mst_e.in_hospital_cd_2
    FROM
        mst_equipment ntss_db5_mst_e
    WHERE
        ntss_db5_mst_e.facility_cd = @facilityCd
        AND ntss_db5_mst_e.is_del = ''0''
        AND ntss_db5_mst_e.is_disp = ''1''
)
, ntss_db5_mst_m AS (
    SELECT
        ntss_db5_mst_m.medicine_cd
        , ntss_db5_mst_m.in_hospital_cd_1
        , ntss_db5_mst_m.in_hospital_cd_2
    FROM
        mst_medicine ntss_db5_mst_m
    WHERE
        ntss_db5_mst_m.facility_cd = @facilityCd
        AND ntss_db5_mst_m.is_del = ''0''
        AND ntss_db5_mst_m.is_disp = ''1''
)
, ntss_db5_mst_m_mix AS (
    SELECT
        ntss_db5_mst_m_mix.medicine_mix_cd
        , ntss_db5_mst_m_mix.in_hospital_cd_1
        , ntss_db5_mst_m_mix.in_hospital_cd_2
    FROM
        mst_medicine_mix ntss_db5_mst_m_mix
    WHERE
        ntss_db5_mst_m_mix.facility_cd = @facilityCd
        AND ntss_db5_mst_m_mix.is_del = ''0''
        AND ntss_db5_mst_m_mix.is_disp = ''1''
)
SELECT
    '''' AS hosppatid                             --患者ID
    , ntss_db5_om_temp.pat_id AS patid
    , ntss_db5_om_temp.dialysisdate AS dialysisdate    --透析日
    , ntss_db5_om_temp.ord_no AS dialysisno            --透析番号
    , CASE
        WHEN rst_cond_list.key = ''1'' THEN ''002''
        WHEN rst_cond_list.key = ''2'' THEN ''003''
        WHEN rst_cond_list.key = ''992'' THEN ''004''
        WHEN rst_cond_list.key = ''3'' THEN ''005''
        WHEN rst_cond_list.key = ''993'' THEN ''006''
        WHEN rst_cond_list.key = ''4'' THEN ''007''
        WHEN rst_cond_list.key = ''5'' THEN ''008''
        WHEN rst_cond_list.key = ''6'' THEN ''009''
        WHEN rst_cond_list.key = ''14'' THEN ''010''
        WHEN rst_cond_list.key = ''25'' THEN ''011''
        WHEN rst_cond_list.key = ''26'' THEN ''012''
        WHEN rst_cond_list.key = ''27'' THEN ''013''
        WHEN rst_cond_list.key = ''28'' THEN ''014''
        WHEN rst_cond_list.key = ''29'' THEN ''015''
        WHEN rst_cond_list.key = ''31'' THEN ''016''
        WHEN rst_cond_list.key = ''32'' THEN ''017''
        WHEN rst_cond_list.key = ''15'' THEN ''018''
        WHEN rst_cond_list.key = ''16'' THEN ''019''
        WHEN rst_cond_list.key = ''17'' THEN ''020''
        WHEN rst_cond_list.key = ''18'' THEN ''021''
        WHEN rst_cond_list.key = ''19'' THEN ''022''
        WHEN rst_cond_list.key = ''20'' THEN ''023''
        WHEN rst_cond_list.key = ''21'' THEN ''024''
        WHEN rst_cond_list.key = ''23'' THEN ''025''
        WHEN rst_cond_list.key = ''12'' THEN ''029''
        WHEN rst_cond_list.key = ''22'' THEN ''030''
        WHEN rst_cond_list.key = ''30'' THEN ''031''
        WHEN rst_cond_list.key = ''34'' THEN ''032''
        WHEN rst_cond_list.key = ''35'' THEN ''033''
        WHEN rst_cond_list.key = ''36'' THEN ''034''
        WHEN rst_cond_list.key = ''37'' THEN ''035''
        WHEN rst_cond_list.key = ''38'' THEN ''036''
        WHEN rst_cond_list.key = ''33'' THEN ''037''
        WHEN rst_cond_list.key = ''24'' THEN ''038''
        WHEN rst_cond_list.key = ''7'' THEN ''039''
        WHEN rst_cond_list.key = ''8'' THEN ''040''
        ELSE NULL
        END AS ctlno       --透析条件項目コード
    , to_char(ntss_db5_om_temp.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    , CASE
        WHEN rst_cond_list.key = ''1'' THEN ''透析時間''
        WHEN rst_cond_list.key = ''2'' THEN ''VA''
        WHEN rst_cond_list.key = ''992'' THEN ''DW''
        WHEN rst_cond_list.key = ''3'' THEN ''目標体重''
        WHEN rst_cond_list.key = ''993'' THEN ''治療方法''
        WHEN rst_cond_list.key = ''4'' THEN ''除水量制限''
        WHEN rst_cond_list.key = ''5'' THEN ''ダイアライザ''
        WHEN rst_cond_list.key = ''6'' THEN ''吸着カラム''
        WHEN rst_cond_list.key = ''14'' THEN ''血流量''
        WHEN rst_cond_list.key = ''25'' THEN ''抗凝固剤''
        WHEN rst_cond_list.key = ''26'' THEN ''抗凝固剤ワンショット量''
        WHEN rst_cond_list.key = ''27'' THEN ''抗凝固剤持続速度''
        WHEN rst_cond_list.key = ''28'' THEN ''抗凝固剤持続総量''
        WHEN rst_cond_list.key = ''29'' THEN ''IP使用選択''
        WHEN rst_cond_list.key = ''31'' THEN ''IPワンショット量''
        WHEN rst_cond_list.key = ''32'' THEN ''IP速度''
        WHEN rst_cond_list.key = ''15'' THEN ''透析液''
        WHEN rst_cond_list.key = ''16'' THEN ''透析液流量''
        WHEN rst_cond_list.key = ''17'' THEN ''透析液量''
        WHEN rst_cond_list.key = ''18'' THEN ''透析液温度''
        WHEN rst_cond_list.key = ''19'' THEN ''補液''
        WHEN rst_cond_list.key = ''20'' THEN ''補液量''
        WHEN rst_cond_list.key = ''21'' THEN ''補液選択''
        WHEN rst_cond_list.key = ''23'' THEN ''補液温度''
        WHEN rst_cond_list.key = ''12'' THEN ''シングルニードル使用''
        WHEN rst_cond_list.key = ''22'' THEN ''補液使用数''
        WHEN rst_cond_list.key = ''30'' THEN ''IPスタート''
        WHEN rst_cond_list.key = ''34'' THEN ''自動ワンショット''
        WHEN rst_cond_list.key = ''35'' THEN ''IP電源自動切り''
        WHEN rst_cond_list.key = ''36'' THEN ''IP電源自動切り時間''
        WHEN rst_cond_list.key = ''37'' THEN ''IP電源OKモニタ切り''
        WHEN rst_cond_list.key = ''38'' THEN ''IP電源OKモニタ切り時間''
        WHEN rst_cond_list.key = ''33'' THEN ''IP速度最大値''
        WHEN rst_cond_list.key = ''24'' THEN ''補液速度''
        WHEN rst_cond_list.key = ''7'' THEN ''1次膜''
        WHEN rst_cond_list.key = ''8'' THEN ''2次膜''
        ELSE NULL
        END AS dialysisitemname --透析条件項目名
    , CASE
        WHEN rst_cond_list.key = ''2'' THEN ntss_db5_mst_v.in_hospital_cd_1
        WHEN rst_cond_list.key = ''992'' THEN to_char(rst_cond_list.value::numeric, ''FM990.00'')
        WHEN rst_cond_list.key = ''3'' THEN to_char(rst_cond_list.value::numeric, ''FM990.00'')
        WHEN rst_cond_list.key = ''4'' THEN to_char(rst_cond_list.value::numeric, ''FM90.00'')
        WHEN rst_cond_list.key = ''5'' THEN ntss_db5_mst_d.in_hospital_cd_1
        WHEN rst_cond_list.key = ''6''
        OR rst_cond_list.key = ''7''
        OR rst_cond_list.key = ''8''
            THEN ntss_db5_mst_e.in_hospital_cd_1
        WHEN rst_cond_list.key = ''25''
        OR rst_cond_list.key = ''15''
        OR rst_cond_list.key = ''19''
            THEN CASE
                WHEN rst_cond_list.medicine_type = ''1'' THEN ntss_db5_mst_m.in_hospital_cd_1
                WHEN rst_cond_list.medicine_type = ''2'' THEN ntss_db5_mst_m_mix.in_hospital_cd_1
                ELSE NULL
                END
        WHEN rst_cond_list.key = ''26'' THEN to_char(rst_cond_list.value::numeric, ''FM99990.00'')
        WHEN rst_cond_list.key = ''27'' THEN to_char(rst_cond_list.value::numeric, ''FM99990.00'')
        WHEN rst_cond_list.key = ''28'' THEN to_char(rst_cond_list.value::numeric, ''FM99990.00'')
        WHEN rst_cond_list.key = ''31'' THEN to_char(rst_cond_list.value::numeric, ''FM90.0'')
        WHEN rst_cond_list.key = ''32'' THEN to_char(rst_cond_list.value::numeric, ''FM90.0'')
        WHEN rst_cond_list.key = ''17'' THEN to_char(rst_cond_list.value::numeric, ''FM99990.00'')
        WHEN rst_cond_list.key = ''18'' THEN to_char(rst_cond_list.value::numeric, ''FM90.0'')
        WHEN rst_cond_list.key = ''20'' THEN to_char(rst_cond_list.value::numeric, ''FM990.0'')
        WHEN rst_cond_list.key = ''23'' THEN to_char(rst_cond_list.value::numeric, ''FM90.0'')
        WHEN rst_cond_list.key = ''33'' THEN to_char(rst_cond_list.value::numeric, ''FM90.0'')
        WHEN rst_cond_list.key = ''24'' THEN to_char(rst_cond_list.value::numeric, ''FM990.00'')
        ELSE rst_cond_list.value
        END AS value          --設定値
    , CASE
        WHEN rst_cond_list.key = ''29''
        OR rst_cond_list.key = ''12''
        OR rst_cond_list.key = ''34''
            THEN CASE
                WHEN rst_cond_list.value = ''1'' THEN ''使用する''
                WHEN rst_cond_list.value = ''0'' THEN ''使用しない''
                ELSE NULL
                END
        WHEN rst_cond_list.key = ''21''
            THEN CASE
                WHEN rst_cond_list.value = ''1'' THEN ''前補液''
                WHEN rst_cond_list.value = ''0'' THEN ''後補液''
                ELSE NULL
                END
        WHEN rst_cond_list.key = ''30''
            THEN CASE
                WHEN rst_cond_list.value = ''1'' THEN ''自動''
                WHEN rst_cond_list.value = ''0'' THEN ''手動''
                ELSE NULL
                END
        WHEN rst_cond_list.key = ''35''
        OR rst_cond_list.key = ''37''
            THEN CASE
                WHEN rst_cond_list.value = ''1'' THEN ''入り''
                WHEN rst_cond_list.value = ''0'' THEN ''切り''
                ELSE NULL
                END
        ELSE rst_cond_list.value_name_1
        END AS valuename --名称
    , CASE
        WHEN rst_cond_list.key = ''1'' THEN ''分''
        WHEN rst_cond_list.key = ''3'' THEN ''kg''
        WHEN rst_cond_list.key = ''4'' THEN ''L''
        WHEN rst_cond_list.key = ''14'' THEN ''mL/min''
        WHEN rst_cond_list.key = ''31'' THEN ''mL''
        WHEN rst_cond_list.key = ''32'' THEN ''mL/h''
        WHEN rst_cond_list.key = ''16'' THEN ''mL/min''
        WHEN rst_cond_list.key = ''18'' THEN ''℃''
        WHEN rst_cond_list.key = ''20'' THEN ''L''
        WHEN rst_cond_list.key = ''23'' THEN ''℃''
        WHEN rst_cond_list.key = ''36'' THEN ''分''
        WHEN rst_cond_list.key = ''38'' THEN ''分''
        WHEN rst_cond_list.key = ''33'' THEN ''mL/h''
        WHEN rst_cond_list.key = ''24'' THEN ''L/h''
        ELSE rst_cond_list.unit
        END AS unit            --単位
    , CASE
        WHEN rst_cond_list.key = ''2'' THEN ntss_db5_mst_v.in_hospital_cd_2
        WHEN rst_cond_list.key = ''993'' THEN rst_cond_list.valuecd2
        WHEN rst_cond_list.key = ''5'' THEN ntss_db5_mst_d.in_hospital_cd_2
        WHEN rst_cond_list.key = ''6''
        OR rst_cond_list.key = ''7''
        OR rst_cond_list.key = ''8''
            THEN ntss_db5_mst_e.in_hospital_cd_2
        WHEN rst_cond_list.key = ''25''
        OR rst_cond_list.key = ''15''
        OR rst_cond_list.key = ''19''
            THEN CASE
                WHEN rst_cond_list.medicine_type = ''1'' THEN ntss_db5_mst_m.in_hospital_cd_2
                WHEN rst_cond_list.medicine_type = ''2'' THEN ntss_db5_mst_m_mix.in_hospital_cd_2
                ELSE NULL
                END
        ELSE NULL
        END AS valuecd2 --院内コード2
FROM
    ntss_db5_om_temp
    LEFT JOIN rst_cond_list
        ON ntss_db5_om_temp.ord_no = rst_cond_list.ord_no
    LEFT JOIN ntss_db5_mst_v
        ON rst_cond_list.value = ntss_db5_mst_v.va_cd ::text
    LEFT JOIN ntss_db5_mst_d
        ON rst_cond_list.value = ntss_db5_mst_d.dialyzer_cd ::text
    LEFT JOIN ntss_db5_mst_e
        ON rst_cond_list.value = ntss_db5_mst_e.equipment_cd ::text
    LEFT JOIN ntss_db5_mst_m
        ON rst_cond_list.value = ntss_db5_mst_m.medicine_cd ::text
    LEFT JOIN ntss_db5_mst_m_mix
        ON rst_cond_list.value = ntss_db5_mst_m_mix.medicine_mix_cd ::text;', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid"]}', '2024-06-27 10:36:11.198', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2503, 'with union_tmp as
(
    SELECT
     ntss_db5_om.pat_id AS patid
    , ntss_db5_om.treat_date AS dialysisdate    --透析日
    , ntss_db5_om.ord_no AS dialysisno          --透析番号
    , to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    , ntss_db5_mst_e.in_hospital_cd_1 AS equipcd --医療材料コード(院内コード1)
    , ntss_db5_mst_e.in_hospital_cd_2 AS equipcd2 --医療材料コード(院内コード2)
    , ntss_db5_om_rqi_json ->> ''name'' AS equipname --医療材料名
    , ntss_db5_om_rqi_json ->> ''class_name'' AS equipclassname --医療材料分類名
    , CASE ntss_db5_om_rqi_json ->> ''needle_type''
        WHEN ''1'' THEN ntss_db5_om_rqi_json ->> ''needle_type''
        WHEN ''2'' THEN ntss_db5_om_rqi_json ->> ''needle_type''
        WHEN ''3'' THEN ntss_db5_om_rqi_json ->> ''needle_type''
        ELSE ''0''
      END AS punctureclass --穿刺針区分
    , ntss_db5_om_rqi_json ->> ''amount'' AS amount --数量
    , ntss_db5_mst_e.unit AS unit               --単位
    , ntss_db5_om_rqi_json ->> ''cd'' AS cd--コード用
    , ntss_db5_om.facility_cd  AS facilitycd
FROM
    ord_main ntss_db5_om
    CROSS JOIN LATERAL jsonb_array_elements(ntss_db5_om.rst_equip_info ::jsonb) ntss_db5_om_rqi_json
    LEFT JOIN mst_equipment ntss_db5_mst_e
        ON (ntss_db5_mst_e.equipment_cd)::text = ntss_db5_om_rqi_json ->> ''cd''
        AND ntss_db5_mst_e.is_del =''0''
        AND ntss_db5_mst_e.is_disp =''1''
WHERE
    ntss_db5_om.is_del = ''0''
    AND ntss_db5_om.facility_cd = @facilityCd
    AND ntss_db5_om.rst_dialysis_state BETWEEN ''1'' AND ''5''
    AND ntss_db5_om.pat_id IS NOT NULL
    AND ntss_db5_om.treat_date IS NOT NULL
UNION ALL
    SELECT
         ntss_db5_om.pat_id AS patid
        , ntss_db5_om.treat_date AS dialysisdate --透析日
        , ntss_db5_om.ord_no AS dialysisno --透析番号
        , to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
        , ntss_db5_mst_e.in_hospital_cd_1 AS equipcd --医療材料コード(院内コード1)
        , ntss_db5_mst_e.in_hospital_cd_2 AS equipcd2 --医療材料コード(院内コード2)
        , rst_cond_info_json.value::JSONB ->> ''value_name_1'' AS equipname --医療材料名
        , ntss_db5_mst_c.class_name AS equipclassname --医療材料分類名
        , CASE rst_cond_info_json.key
            WHEN ''9'' THEN ''1''
            WHEN ''10'' THEN ''2''
            WHEN ''11'' THEN ''3''
            ELSE ''0''
          END AS punctureclass --穿刺針区分
        , ''1'' AS amount --数量
        , rst_cond_info_json.value::JSONB ->> ''unit'' AS unit               --単位
        , rst_cond_info_json.value::JSONB ->> ''value'' AS cd--コード用
        , ntss_db5_om.facility_cd  AS facilitycd
    FROM
        ord_main ntss_db5_om
        CROSS JOIN lateral jsonb_each_text(ntss_db5_om.rst_cond_info::JSONB) rst_cond_info_json
        INNER JOIN mst_equipment ntss_db5_mst_e
            ON (ntss_db5_mst_e.equipment_cd)::text = rst_cond_info_json.value::JSONB ->> ''value''
            AND ntss_db5_mst_e.is_del =''0''
            AND ntss_db5_mst_e.is_disp =''1''
        LEFT JOIN mst_equipment_class ntss_db5_mst_c
            ON ntss_db5_mst_c.class_cd = ntss_db5_mst_e.class_cd
            AND ntss_db5_mst_c.is_del = ''0''
            AND ntss_db5_mst_c.is_disp = ''1''
    WHERE
        rst_cond_info_json.key IN(''6'',''7'',''8'',''9'',''10'',''11'',''13'')
        AND rst_cond_info_json.value::JSONB ->> ''value'' is not null
        AND ntss_db5_om.is_del = ''0''
        AND ntss_db5_om.facility_cd = @facilityCd
        AND ntss_db5_om.rst_dialysis_state BETWEEN ''1'' AND ''5''
        AND ntss_db5_om.pat_id IS NOT NULL
        AND ntss_db5_om.treat_date IS NOT null)
SELECT
    '''' AS hosppatid                             --患者ID
    , union_tmp.patid
    , union_tmp.dialysisdate
    , union_tmp.dialysisno
    , (row_number() over (PARTITION BY union_tmp.dialysisno ORDER BY ntss_db5_mst_sel.sortkey ASC, (union_tmp.cd)::integer))::text AS ctlno --項目番号
    , union_tmp.update
    , union_tmp.equipcd
    , union_tmp.equipcd2
    , union_tmp.equipname
    , union_tmp.equipclassname
    , union_tmp.punctureclass
    , union_tmp.amount
    , union_tmp.unit
    , '''' as comments
    from
        union_tmp
        INNER JOIN mst_equipment ntss_db5_mst_e
            ON (ntss_db5_mst_e.equipment_cd)::text = union_tmp.cd
            AND ntss_db5_mst_e.is_del = ''0''
            AND ntss_db5_mst_e.is_disp = ''1''
        LEFT JOIN (
            SELECT
              facility_cd
              , ntss_db5_mst_sel_json
              , ROW_NUMBER() OVER() AS sortkey
            FROM
                mst_selector ms
            CROSS JOIN LATERAL jsonb_array_elements(ms.order_settings ::jsonb -> ''items'') ntss_db5_mst_sel_json
            WHERE ms.master_physical_name = ''mst_equipment''
            AND ntss_db5_mst_sel_json ->> ''isDel'' = ''0''
            AND ntss_db5_mst_sel_json ->> ''isDisp'' = ''1'') AS ntss_db5_mst_sel
            ON (ntss_db5_mst_e.equipment_cd)::text = ntss_db5_mst_sel.ntss_db5_mst_sel_json ->> ''code''
            AND union_tmp.facilitycd = ntss_db5_mst_sel.facility_cd;', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2024-06-27 10:36:10.827', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
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
        AND is_del = ''0''
        AND is_disp =''1''
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
        AND is_del = ''0''
        AND is_disp =''1''
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
        AND is_del = ''0''
        AND is_disp =''1''
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
    CROSS JOIN LATERAL jsonb_array_elements(ord_main.rst_medi_info ::jsonb) ord_main_rmi_json
    LEFT JOIN mst_medi
        ON mst_medi.medicine_cd ::text = ord_main_rmi_json ->> ''cd''
    LEFT JOIN mst_medi_mix
        ON mst_medi_mix.medicine_mix_cd ::text = ord_main_rmi_json ->> ''cd''
    LEFT JOIN mst_proc
        ON mst_proc.procedure_cd ::text = ord_main_rmi_json ->> ''procedure_cd''
WHERE
    ord_main.facility_cd = @facilityCd
    AND ord_main.rst_dialysis_state BETWEEN ''1'' AND''5''
    AND ord_main.is_del = ''0''
    AND ord_main.pat_id IS NOT NULL;
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid,userid"]}', '2024-06-27 10:36:10.798', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2506, 'SELECT
    '''' AS hosppatid                             --患者ID
    , ntss_db5_om.pat_id AS patid
    , ntss_db5_om.treat_date AS dialysisdate    --透析日
    , ntss_db5_om.ord_no AS dialysisno          --透析番号
    , ROW_NUMBER() OVER (PARTITION BY ntss_db5_om.ord_no ORDER BY CAST(ntss_db5_om_di_json1 ->> ''cd'' AS int) ASC) AS ctlno --項目番号
    , to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    , ''1'' AS division                           --レセプトメモ区分
    , ntss_db5_mst_a.in_hospital_cd_3 AS code   --コード
    , to_char(ntss_db5_mst_a.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS codeupdate --コード更新日時
    , ''1'' AS addflg                             --加算有無
    , ntss_db5_om_di_json1 ->> ''name'' AS itemname  --項目名称
    , '''' AS maindialdiff                        --主たる透析困難
    , ntss_db5_mst_a.in_hospital_cd_1 AS inhospitalcd --院内コード
    , ntss_db5_mst_a.in_hospital_cd_2 AS inhospitalcd2 --院内コード２
FROM
    ord_main ntss_db5_om
    CROSS JOIN LATERAL jsonb_array_elements(ntss_db5_om.addition_info ::jsonb) ntss_db5_om_di_json1
    INNER JOIN mst_addition ntss_db5_mst_a
        ON ntss_db5_mst_a.addition_cd :: text = ntss_db5_om_di_json1 ->> ''cd''
        AND ntss_db5_mst_a.is_del = ''0''
        AND ntss_db5_mst_a.is_disp = ''1''
WHERE
    ntss_db5_om.is_del = ''0''
    AND ntss_db5_om.facility_cd = @facilityCd
    AND ntss_db5_om.rst_dialysis_state BETWEEN ''1'' AND''5''
    AND ntss_db5_om.addition_info IS NOT NULL
    AND ntss_db5_om.addition_info <> ''[]''
    AND ntss_db5_om.pat_id IS NOT NULL;', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid"]}', '2024-06-27 10:36:11.112', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2507, 'SELECT
    '''' AS hosppatid                             --患者ID
    , ntss_db5_om.pat_id AS patid
    , to_char(ntss_db5_om.rst_start_date, ''YYYY-MM-DD hh24:mi:ss'') AS startdate      --開始日時
    , to_char(ntss_db5_mm.occur_date, ''YYYY-MM-DD hh24:mi:ss'') AS occurdate          --発生日時
    , ntss_db5_mm.monitor_data ->> ''90'' AS bpmax                            --最高血圧
    , ntss_db5_mm.monitor_data ->> ''91'' AS bpmin                            --最低血圧
    , ntss_db5_mm.monitor_data ->> ''92'' AS bpave                            --平均血圧
    , ntss_db5_mm.monitor_data ->> ''93'' AS pulse                            --脈拍
    , ntss_db5_mm.monitor_data ->> ''94'' AS temperature                      --体温
    , ntss_db5_mm.monitor_data ->> ''-1'' AS bloodsugarlevel                  --血糖値
    , to_char(ntss_db5_mm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update       --更新日時
    , ntss_db5_om.ord_no AS diadysisno        --透析番号
    , CASE
        WHEN ntss_db5_mm.data_type = ''5'' THEN ''1''
        WHEN ntss_db5_mm.data_type IN (''2'', ''4'') THEN ''0''
        WHEN ntss_db5_mm.data_type = ''6'' THEN ''2''
        END AS bpclass                          --血圧区分
    , ntss_db5_om.ord_no AS ordno               --透析番号
FROM
    ord_main ntss_db5_om
    INNER JOIN mni_monitor ntss_db5_mm
        ON ntss_db5_mm.ord_no = ntss_db5_om.ord_no
        AND ntss_db5_om.facility_cd = ntss_db5_mm.facility_cd
        AND ntss_db5_mm.is_del = ''0''
WHERE
    ntss_db5_om.facility_cd = @facilityCd
    AND ntss_db5_om.rst_dialysis_state BETWEEN ''1'' AND ''5''
    AND ntss_db5_om.is_del = ''0''
    AND ntss_db5_mm.data_type IN (''2'', ''4'', ''5'', ''6'');
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2024-06-27 10:36:10.940', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2509, 'SELECT
       user_id AS regstaff
       ,CONCAT(personal_info_decrypt(user_last_name), ''　'' , personal_info_decrypt(user_first_name)) AS ordername --オーダー入力者名
FROM
            mst_personal_user
WHERE
            facility_cd = @facilityCd
            AND is_del = ''0''
            AND is_disp = ''1'';', 3, '[{}]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["regstaff"]}', '2024-06-27 10:36:10.177', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2512, 'SELECT
       user_id AS upstaff
       ,CONCAT(personal_info_decrypt(user_last_name), ''　'', personal_info_decrypt(user_first_name))  AS updatename --更新者名
     FROM
       mst_personal_user
     WHERE
       facility_cd = @facilityCd
       AND is_del = ''0''
       AND is_disp = ''1'';', 3, '[{}]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd 使用 {"Mergekey": ["upstaff"]}', '2024-06-27 10:36:10.177', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2513, 'SELECT
    user_id ::text AS userid
    ,CONCAT(personal_info_decrypt(user_last_name), ''　'', personal_info_decrypt(user_first_name)) AS drname --担当医名
FROM
    mst_personal_user
WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    AND is_disp = ''1'';', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '担当医名　@facilityCd使用 {"Mergekey": ["userid"]}', '2024-05-11 22:04:07.661', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2515, 'SELECT
    CAST(mst.user_id AS VARCHAR) AS doctorcd2
    , CONCAT(personal_info_decrypt(mst.user_first_name), ''　'', personal_info_decrypt(mst.user_last_name)) AS
    doctorname2                                 --担当医2
FROM
    mst_personal_user mst
WHERE
    mst.facility_cd = @facilityCd
    AND mst.is_del = ''0''
    AND mst.is_disp = ''1''', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者基本情報：　@facilityCd使用 {"Mergekey": ["doctorcd2"]}', '2021-07-29 16:18:57.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2516, 'SELECT
    CAST(mst.user_id AS VARCHAR) AS staffcd1
    , CONCAT(personal_info_decrypt(mst.user_first_name), ''　'', personal_info_decrypt(mst.user_last_name)) AS
    staffname1                                  --担当スタッフ1
FROM
    mst_personal_user mst
WHERE
    mst.facility_cd = @facilityCd
    AND mst.is_del = ''0''
    AND mst.is_disp = ''1''', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者基本情報：　@facilityCd使用 {"Mergekey": ["staffcd1"]}', '2021-07-29 16:18:57.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2517, 'SELECT
    CAST(mst.user_id AS VARCHAR) AS staffcd2
    , CONCAT(personal_info_decrypt(mst.user_first_name), ''　'', personal_info_decrypt(mst.user_last_name)) AS
    staffname2                                  --担当スタッフ2
FROM
    mst_personal_user mst
WHERE
    mst.facility_cd = @facilityCd
    AND mst.is_del = ''0''
    AND mst.is_disp = ''1''', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者基本情報：　@facilityCd使用 {"Mergekey": ["staffcd2"]}', '2021-07-29 16:18:57.000', CURRENT_TIMESTAMP, NULL);