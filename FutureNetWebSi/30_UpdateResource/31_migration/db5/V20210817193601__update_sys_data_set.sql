delete from sys_data_set where sql_cd = -2011;
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2011, 'with pat_main_tbl as ( 

    select

        pat_id

        , facility_cd 

    from

        pat_main pat 

    where

        pat.is_del = ''0'' 

        AND pat.facility_cd = @facilityCd 

) 

, pat_unique_tbl as ( 

    select

        pu.pat_id

        , max(phy ->> ''ctr'') as ctr

        , to_char( 

            max(to_date(phy ->> ''exam_date'', ''YYYY/MM/DD''))

            , ''YYYYMMDD''

        ) as exam_date 

    from

        pat_unique pu 

        cross join lateral json_array_elements(pu.physical_info ::json) phy 

    where

        pu.facility_cd = @facilityCd 

    group by

        pat_id

) 

, pat_main_doctor_tbl as ( 

    select

        pat_id

        , (array_agg(staff_cd)) [1] as staff_cd_1

        , (array_agg(staff_cd)) [2] as staff_cd_2 

    from

        ( 

            select

                pt_st.pat_id

                , staff ->> ''staff_cd'' as staff_cd 

            from

                pat_main pt_st 

                cross join lateral json_array_elements(pt_st.charge_staff_info ::json) staff 

            where

                pt_st.facility_cd = @facilityCd 

                and staff ->> ''is_main'' = ''1'' 

            order by

                pt_st.pat_id

                , staff ->> ''ctl_no'' asc

        ) pm_temp 

    group by

        pat_id

) 

, pat_main_staff_tbl as ( 

    select

        pat_id

        , (array_agg(staff_cd)) [1] as staff_cd_1

        , (array_agg(staff_cd)) [2] as staff_cd_2 

    from

        ( 

            select

                pt_st.pat_id

                , staff ->> ''staff_cd'' as staff_cd 

            from

                pat_main pt_st 

                cross join lateral json_array_elements(pt_st.charge_staff_info ::json) staff 

            where

                pt_st.facility_cd = @facilityCd 

                and staff ->> ''is_main'' = ''2'' 

            order by

                pt_st.pat_id

                , staff ->> ''ctl_no'' asc

        ) pm_temp 

    group by

        pat_id

) 

, pat_main_memo_tbl as ( 

    select

        pt_info.pat_id

        , info ->> ''title'' as title

        , info ->> ''content'' as content 

    from

        pat_main pt_info 

        CROSS JOIN LATERAL json_array_elements(pt_info.pat_memo_info ::json) info 

    where

        pt_info.facility_cd = @facilityCd 

        and info ->> ''ctl_no'' = ''1'' 

    order by

        pt_info.pat_id

) 

, pat_group_disp_order_tbl as ( 

    select

        one_json ->> ''code'' as pat_group_cd

        , json_idx as pat_group_cd_order 

    from

        mst_selector 

        cross join lateral jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(one_json, json_idx)

    where

        facility_cd = @facilityCd 

        and master_physical_name = ''pat_group''

) 

, pat_group_detail_tmp as ( 

    select

        tmp.pat_id

        , pat_group_disp_order_tbl.pat_group_cd 

    from

        ( 

            select

                gdt.pat_id

                , min(pat_group_disp_order_tbl.pat_group_cd_order) as disp_order 

            from

                pat_group_detail gdt 

                left join pat_group_disp_order_tbl 

                    on pat_group_disp_order_tbl.pat_group_cd = gdt.pat_group_cd ::text 

            where

                gdt.facility_cd = @facilityCd 

            group by

                gdt.pat_id 

            order by

                gdt.pat_id

        ) tmp 

        left join pat_group_disp_order_tbl 

            on pat_group_disp_order_tbl.pat_group_cd_order = tmp.disp_order

) 

, mst_ward_tmp as ( 

    select

        * 

    from

        mst_ward 

    where

        facility_cd = @facilityCd

) 

, mst_course_tmp as ( 

    select

        * 

    from

        mst_course 

    where

        facility_cd = @facilityCd

) 

, pat_group_tmp as ( 

    select

        * 

    from

        pat_group 

    where

        facility_cd = @facilityCd

) 

select

    ntss_db5_pm.pat_id as patid

    , ntss_db5_pm.medical_care_info ->> ''dialysis_count'' AS dialcount --透析回数

    , pat_unique_tbl.ctr AS ctr                 --CTR

    , pat_unique_tbl.exam_date AS ctrupdate     --CTR更新日時

    , pat_main_doctor_tbl.staff_cd_1 as doctorcd1 --担当医1

    , pat_main_doctor_tbl.staff_cd_2 as doctorcd2 --担当医2

    , ntss_db5_pm.medical_care_info ->> ''hospital_start_date'' AS startdate --当院開始日

    , ntss_db5_pm.is_infect AS infect           --感染症有無

    , mst_ward_tmp.ward_name AS ward            --病棟名

    , mst_course_tmp.course_name AS course      --診療科名

    , pat_main_memo_tbl.content as memo

    , pat_main_staff_tbl.staff_cd_1 as staffcd1 --担当スタッフ１

    , pat_main_staff_tbl.staff_cd_2 as staffcd2 --担当スタッフ２

    , pat_group_tmp.pat_group_name as patgroupname --患者グループ

    , pat_group_detail_tmp.pat_group_cd as patgroupcd --患者グループコード

    , ntss_db5_pm.medical_care_info ->> ''dialysis_start_date'' AS dialstartdate --透析導入日

FROM

    pat_main ntss_db5_pm 

    left join pat_unique_tbl 

        on pat_unique_tbl.pat_id = ntss_db5_pm.pat_id 

    left join pat_main_staff_tbl 

        on pat_main_staff_tbl.pat_id = ntss_db5_pm.pat_id 

    left join pat_main_doctor_tbl 

        on pat_main_doctor_tbl.pat_id = ntss_db5_pm.pat_id 

    left join pat_main_memo_tbl 

        on pat_main_memo_tbl.pat_id = ntss_db5_pm.pat_id 

    left join pat_group_detail_tmp 

        on pat_group_detail_tmp.pat_id = ntss_db5_pm.pat_id 

    left join mst_ward_tmp 

        on mst_ward_tmp.ward_cd ::text = ntss_db5_pm.medical_care_info ->> ''ward_cd'' ::text 

    left join mst_course_tmp 

        on mst_course_tmp.course_cd ::text = ntss_db5_pm.medical_care_info ->> ''main_course_cd'' ::text 

    left join pat_group_tmp 

        on pat_group_tmp.pat_group_cd ::text = pat_group_detail_tmp.pat_group_cd ::text 

WHERE

    ntss_db5_pm.is_del = ''0'' 

    AND ntss_db5_pm.facility_cd = @facilityCd 

order by

    patid desc

    , CTR desc

', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者基本情報：@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54', '2021-02-26 17:51:54', NULL);
