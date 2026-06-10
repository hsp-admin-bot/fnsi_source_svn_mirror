DELETE FROM ntss.sys_data_set
WHERE sql_cd=-2011;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2011, '-- 【SQL_CD=-2011】
WITH pat_event_tbl AS (
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
        pat_event_tbl_array.pat_id
        ,row_number () over (partition by pat_event_tbl_array.pat_id order by result_2 ->> ''is_send_va'' desc,json_idx_2 asc) as rowno2
        , result_2 ->> ''name'' AS shantpart
    FROM (
        select *
        from pat_event_tbl
        where rowno = 1
            and jsonb_typeof(result_value) = ''array''
    ) pat_event_tbl_array
    CROSS JOIN lateral jsonb_array_elements(pat_event_tbl_array.result_value) WITH ordinality AS tmp(result_2, json_idx_2)
    WHERE result_2 ->> ''name'' != ''''
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
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者基本情報：@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
