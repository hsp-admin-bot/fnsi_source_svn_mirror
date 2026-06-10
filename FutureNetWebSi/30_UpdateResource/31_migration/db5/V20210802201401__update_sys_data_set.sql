delete from sys_data_set where sql_cd in (-2010,-2011,-2012,-2013,-2014,-2015);INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2015, 'select
    mst.transport_cd as transportcd
    , mst.transport_name as transportname
    , mst.in_hospital_cd_1 as transporthospitalcd 
from
    mst_transport mst 
where
    mst.facility_cd = @facilityCd', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者基本情報：　@facilityCd使用 {"Mergekey": ["transportcd"]}', '2021-07-29 16:18:57', '2021-07-29 16:19:00', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2014, 'select
    mst.disease_cd as basediseasecd
    , mst.disease_name as basediseasename
    , mst.in_hospital_cd_1 as diseasehospitalcd 
from
    mst_disease mst 
where
    mst.facility_cd = @facilityCd', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者基本情報：　@facilityCd使用 {"Mergekey": ["basediseasecd"]}', '2021-07-29 16:18:57', '2021-07-29 16:19:00', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2013, 'select
    mst.dialysis_difficulty_cd as dialdiffcd
    , mst.in_hospital_cd_1 as dialdiffhospitalcd1
    , mst.dialysis_difficulty_name as dialdiffcomment 
from
    mst_dialysis_difficulty mst 
where
    mst.facility_cd = @facilityCd', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者基本情報：@facilityCd使用 {"Mergekey": ["dialdiffcd"]}', '2021-07-29 16:18:57', '2021-07-29 16:19:00', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2012, 'select
    mst.user_id as doctorcd1
    , mst.user_id as doctorcd2
    , mst.user_id as staffcd1
    , mst.user_id as staffcd2
    , personal_info_decrypt(mst.user_first_name) || '' '' || personal_info_decrypt(mst.user_last_name) AS 
    doctorname1                                 --担当医1
    , personal_info_decrypt(mst.user_first_name) || '' '' || personal_info_decrypt(mst.user_last_name) AS 
    doctorname2                                 --担当医1
    , personal_info_decrypt(mst.user_first_name) || '' '' || personal_info_decrypt(mst.user_last_name) AS 
    staffname1                                  --担当医1
    , personal_info_decrypt(mst.user_first_name) || '' '' || personal_info_decrypt(mst.user_last_name) AS 
    staffname2                                  --担当医1
from
    mst_personal_user mst 
where
    mst.facility_cd = @facilityCd', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者基本情報：　@facilityCd使用 {"Mergekey": ["doctorcd1","doctorcd2","staffcd1","staffcd2"]}', '2021-07-29 16:18:57', '2021-07-29 16:19:00', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2011, 'with pat_main_tbl as ( 
    select
        pat_id
        , facility_cd 
    from
        pat_main pat 
    where
        pat.is_del = ''0'' 
        AND pat.facility_cd = @facilityCd 
        AND pat.up_date BETWEEN to_date(@fromDate, ''YYYYMMDDHH24MISS'') AND to_date(@toDate, ''YYYYMMDDHH24MISS'')
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
    AND ntss_db5_pm.up_date BETWEEN to_date(@fromDate, ''YYYYMMDDHH24MISS'') AND to_date(@toDate, ''YYYYMMDDHH24MISS'')
order by
    patid desc
    , CTR desc
', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者基本情報：@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54', '2021-02-26 17:51:54', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-2010, 'with pat_personal_main_dial_tbl as ( 
    select
        ptdia.pat_id
        , info ->> ''dial_diff_cd'' as dialdiffcd
    from
        pat_personal_main ptdia 
        CROSS JOIN LATERAL json_array_elements(ptdia.dial_diff_com_info ::json) info 
    where
        ptdia.facility_cd =  @facilityCd 
        and info ->> ''is_main'' = ''1'' 
) 
SELECT
      ntss_db6_ppm.hosp_pat_id AS hosppatid           --患者ID
    , ntss_db6_ppm.pat_id AS patid
    , personal_info_decrypt(ntss_db6_ppm.pat_last_name) || '' '' || personal_info_decrypt(ntss_db6_ppm.pat_first_name)
     AS name                                    --氏名
    , personal_info_decrypt(ntss_db6_ppm.pat_last_name_kana) || '' '' || personal_info_decrypt(ntss_db6_ppm.pat_first_name_kana)
     AS namekana                               --患者名カナ
     ,0 as dialcount   --透析回数
     ,'''' as shantpart  --シャント位置
     ,'''' as ctr        --CTR
     ,'''' as ctrupdate  --CTR更新日時
    , ntss_db6_ppm.pat_blood_type_abo AS bloodtypeabo --血液型ABO
    , ntss_db6_ppm.pat_blood_type_rh AS bloodtyperh --血液型RH
    , ntss_db6_ppm.pat_birthday AS birthday     --生年月日
    , ntss_db6_ppm.pat_sex AS sexcd            --性別
    , CASE 
        WHEN ( 
            ntss_db6_pi.insu_class = ''0'' 
        ) 
            THEN ntss_db6_pi.insu_info ->> ''insu_pat_no'' 
        WHEN ( 
            ntss_db6_pi.insu_class = ''1'' 
        ) 
            THEN ntss_db6_pi.insu_pub_info ->> ''insu_pub_no'' 
        WHEN ( 
            ntss_db6_pi.insu_class = ''1'' 
        ) 
            THEN ntss_db6_pi.insu_set_info ->> ''insu_pat_no'' 
        END AS insuranceno                     --保険者番号
    ,'''' as insurancememo1                      --保険メモ1
    ,'''' as insurancememo2                      --保険メモ2
    , CASE 
        WHEN ( 
            ntss_db6_pi.insu_class = ''2'' 
        ) 
            THEN ntss_db6_pi.insu_set_info ->> ''insu_pub1_cd'' 
        ELSE ntss_db6_pi.insu_pub_info ->> ''insu_pub_no'' 
        END AS pubinsuno1                     --公費負担者番号1
    ,'''' pubinsurecno1                         --公費負担医療需給者番号1 
    , CASE 
        WHEN ( 
            ntss_db6_pi.insu_class = ''2'' 
        ) 
            THEN ntss_db6_pi.insu_set_info ->> ''insu_pub2_cd'' 
        ELSE ntss_db6_pi.insu_pub_info ->> ''insu_pub_no'' 
        END AS pubinsuno2                     --公費負担者番号2
    ,'''' as pubinsurecno2                      --公費負担医療需給者番号2
    
    , CASE 
        WHEN ( 
            ntss_db6_pi.insu_class = ''0'' 
        ) 
            THEN ntss_db6_pi.insu_info ->> ''insu_pat_no'' 
        WHEN ( 
            ntss_db6_pi.insu_class = ''2'' 
        ) 
            THEN ntss_db6_pi.insu_set_info ->> ''insu_cd'' 
        END AS insurancecd                     --保険区分
    , CASE 
        WHEN ( 
            ntss_db6_pi.insu_class = ''0'' 
        ) 
            THEN ntss_db6_pi.insu_info ->> ''insu_pat_mark'' 
        WHEN ( 
            ntss_db6_pi.insu_class = ''2'' 
        ) 
            THEN ntss_db6_pi.insu_set_info ->> ''insu_cd'' 
        END AS hiinsurancecode                 --被保険者記号番号
   ,CASE
        WHEN ntss_db6_ppm.in_out_class = ''0'' THEN

        ntss_db6_pi.insu_info ->> ''futan-g'' 

        WHEN ntss_db6_ppm.in_out_class = ''0'' THEN

        ntss_db6_pi.insu_info ->> ''futan-n'' 

     END AS insuranceratio --保険率
    ,'''' as disabilityno                        --障害者手帳NO
    ,'''' as doctorcd1                           --担当医ｃｄ1
    ,'''' as doctorcd2                           --担当医ｃｄ2
    ,'''' as doctorname1                         --担当医1
    ,'''' as doctorname2                         --担当医2
    ,ntss_db6_ppm.in_out_class AS inoutclass        --入院外来
    ,'''' as startdate                           --当院開始日
    , to_char(ntss_db6_ppm.die_date, ''YYYY-MM-DD hh24:mi:ss'') AS diedate --死亡日
    ,'''' as infect       --感染症有無
    ,'''' as ward         --病棟名
    ,'''' as course       -- 診療科名
    ,'''' as memo         --MEMO
    ,'''' as staffcd1   --担当スタッフｃｄ１
    ,'''' as staffcd2   --担当スタッフｃｄ２
    ,'''' as staffname1   --担当スタッフ１
    ,'''' as staffname2   --担当スタッフ２
    , Case when ntss_db6_ppm.dial_diff_com_info != null then ''有'' else ''無''
      END   AS dialdiff --透析困難
    ,dail.dialdiffcd   --透析困難コメントコード
    ,'''' as dialdiffhospitalcd1   --透析困難院内コード
    ,'''' as dialdiffcomment --透析困難コメント
    ,ntss_db6_ppm.severity_cd as  severitycd        --重傷度コード
    ,'''' as  injurycd        --重傷度コード
    ,'''' as injuryname      --重傷度名称
    ,ntss_db6_ppm.primary_disease_cd as basediseasecd   --原疾患コード
    ,''''diseasehospitalcd   --原疾患院内コード
    ,'''' as basediseasename --原疾患名称
    ,ntss_db6_ppm.transport_cd as transportcd     --輸送区分コード
    ,'''' as transporthospitalcd --輸送区分院内コード
    ,'''' as transportname   --輸送区分名称
    , to_char(ntss_db6_ppm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    ,'''' as patgroupname    --患者グループ
    ,'''' as patgroupcd      --患者グループコード
    ,'''' as dialstartdate   --透析導入日

FROM
    pat_personal_main ntss_db6_ppm 
    LEFT JOIN pat_insurance ntss_db6_pi 
        ON ntss_db6_ppm.pat_id = ntss_db6_pi.pat_id 
        AND ntss_db6_pi.facility_cd = @facilityCd
        AND ntss_db6_pi.is_selected = ''1''
        AND  ntss_db6_pi.is_del =''0''
    LEFT JOIN pat_personal_main_dial_tbl dail 
        ON dail.pat_id = ntss_db6_ppm.pat_id 
WHERE
    ntss_db6_ppm.is_del = ''0'' 
    AND ntss_db6_ppm.facility_cd = @facilityCd
    AND ntss_db6_ppm.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' ) 
    AND to_date( @toDate , ''YYYYMMDDHH24MISS'' )', 3, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者基本情報：@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid","doctorcd1","doctorcd2","staffcd1","staffcd2","dialdiffcd","basediseasecd","transportcd"]}', '2021-02-26 17:51:54', '2021-02-26 17:51:54', NULL);
