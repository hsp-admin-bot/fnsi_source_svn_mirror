DELETE FROM sys_data_set WHERE sql_cd in(-2130);
INSERT INTO ntss.sys_data_set(sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) VALUES
    (-2130,'with ntss_db5_om_temp AS (
    SELECT
        ntss_db5_om.ord_no
        , ntss_db5_om_rmi_json ->> ''cd'' ::char (10) AS cd
        , ntss_db5_om_rmi_json ->> ''procedure_cd''  AS procedure_cd
        , ntss_db5_om_rmi_json ->> ''amount'' AS amount --数量
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
        , ntss_db5_om_rmi_json ->> ''procedure_name'' AS procedurename --手技名
				, '''' AS indicatorcd                     --実施者コード
        , ntss_db5_om_rmi_json ->> ''effect_user_id'' AS userid
        , cast(
            ntss_db5_om_rmi_json ->> ''effect_user_last_name'' AS char (20)
        ) || cast(
            ntss_db5_om_rmi_json ->> ''effect_user_first_name'' AS char (20)
        ) AS staffname                          --実施者名
        , ntss_db5_om_rmi_json ->> ''comment'' AS comments --コメント
    FROM
        ord_main ntss_db5_om
        CROSS JOIN LATERAL json_array_elements(ntss_db5_om.rst_medi_info ::json) ntss_db5_om_rmi_json
    WHERE
        ntss_db5_om.facility_cd = @facilityCd
        AND ntss_db5_om.is_del = ''0''
        AND ntss_db5_om.pat_id IS NOT NULL
)
SELECT
    '''' AS hosppatid                             --患者ID
    , ntss_db5_om.pat_id AS patid
    , ntss_db5_os.treat_date AS dialysisdate    --透析日
    , ntss_db5_om.ord_no AS dialysisno          --透析番号
    , row_number() over (ORDER BY ntss_db5_om.treat_date DESC) AS ctlno --項目番号
    , to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
    , ntss_db5_mst_m.in_hospital_cd_1 AS medicinecd1 --薬剤コード(院内コード1)
    , ntss_db5_mst_m.in_hospital_cd_2 AS medicinecd2 --薬剤コード(院内コード2)
    , ntss_db5_mst_m.medicine_name AS medicinename --薬剤名
    , ntss_db5_mst_c.class_name AS medicineclassname --薬剤分類名
    , ntss_db5_om_temp.amount AS amount         --数量
    , ntss_db5_mst_m.unit AS unit               --単位
    , ntss_db5_om_temp.effectflg AS effectflg   --実施フラグ
    , ntss_db5_om_temp.effectdate               --実施日時
    , ntss_db5_om_temp.timingname AS timingname --投与時間帯名
    , ntss_db5_mst_p.in_hospital_cd_a1 AS procedurecd1 --手技コード(院内コード1)
    , ntss_db5_mst_p.in_hospital_cd_a2 AS procedurecd2 --手技コード(院内コード2)
    , ntss_db5_mst_p.pricedure_name AS procedurename --手技名
    , '''' AS indicatorcd                       --実施者コード
    , ntss_db5_om_temp.userid AS userid
    , ntss_db5_om_temp.staffname AS staffname   --実施者名
    , ntss_db5_om_temp.comments AS comments     --コメント
FROM
    ord_main ntss_db5_om
    INNER JOIN ntss_db5_om_temp
        ON ntss_db5_om_temp.ord_no = ntss_db5_om.ord_no
    LEFT JOIN ord_schedule ntss_db5_os
        ON ntss_db5_om.ord_no = ntss_db5_os.ord_no
    LEFT JOIN mst_medicine ntss_db5_mst_m
        ON ntss_db5_mst_m.medicine_cd ::char (10) = ntss_db5_om_temp.cd
    LEFT JOIN mst_medicine_class ntss_db5_mst_c
        ON ntss_db5_mst_c.class_cd = ntss_db5_mst_m.class_cd
    LEFT JOIN mst_procedure ntss_db5_mst_p
        ON ntss_db5_mst_p.procedure_cd ::char (10) = ntss_db5_om_temp.procedure_cd
WHERE
    (
        CASE
            WHEN @syncMode = ''update''
                THEN (
                (
                    ntss_db5_om.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
                )
                OR (
                    ntss_db5_os.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
                )
            )
            ELSE ntss_db5_os.treat_date BETWEEN SUBSTR(@fromDate, 0, 9) AND SUBSTR(@toDate, 0, 9)
            END
    )
    AND ntss_db5_om.pat_id IS NOT NULL;

',2,'[]','1','{"applications": [5]}','{"classes": []}','患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid"]}','2021/02/26 17:51:54.726','2021/02/26 17:51:54.726',NULL);

DELETE FROM sys_data_set WHERE sql_cd in(-2010);
INSERT INTO ntss.sys_data_set(sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) VALUES
    (-2010,'with pat_personal_main_dial_tbl as (
    select
        ptdia.pat_id
        , info ->> ''dial_diff_cd'' as dialdiffcd
    from
        pat_personal_main ptdia
        CROSS JOIN LATERAL json_array_elements(ptdia.dial_diff_com_info ::json) info
    where
        ptdia.facility_cd = @facilityCd
        and info ->> ''is_main'' = ''1''
)
, pat_insurance_detail as (
    select
        insurance_cd
        , pat_id
        , insu_class
        , pat_ins.insu_info as insu_info
        , 0 as no
        , null as insu_pub_info
        , pat_ins.memo1 as memo1
        , pat_ins.memo2 as memo2
        , pat_ins.up_date as up_date
    from
        pat_insurance pat_ins
    where
        insu_class = ''0''
        AND pat_ins.is_selected = ''1''
        AND pat_ins.is_del = ''0''
    union all
    select
        insurance_cd
        , pat_id
        , insu_class
        , null as insu_info
        , 0 as no
        , pat_ins.insu_pub_info as insu_pub_info
        , pat_ins.memo1 as memo1
        , pat_ins.memo2 as memo2
        , pat_ins.up_date as up_date
    from
        pat_insurance pat_ins
    where
        insu_class = ''1''
        AND pat_ins.is_selected = ''1''
        AND pat_ins.is_del = ''0''
    union all
    select
        pat_ins.insurance_cd as insurance_cd
        , pat_ins.pat_id
        , ''2'' AS insu_class
        , pat_ins.insu_info as insu_info
        , pat_set.no
        , pat_ins.insu_pub_info as insu_pub_info
        , pat_ins.memo1 as memo1
        , pat_ins.memo2 as memo2
        , pat_ins.up_date as up_date
    from
        pat_insurance pat_ins
        inner join (
            select
                insurance_cd
                , 1 as no
                , CAST((insu_set_info ->> ''insu_pub1_cd'') AS integer) AS insu_pub_cd
            from
                pat_insurance
            where
                insu_set_info ->> ''insu_pub1_cd'' is not null
                and is_selected = ''1''
                and is_del = ''0''
            union all
            select
                insurance_cd
                , 2 as no
                , CAST((insu_set_info ->> ''insu_pub2_cd'') AS integer) AS insu_pub_cd
            from
                pat_insurance
            where
                insu_set_info ->> ''insu_pub2_cd'' is not null
                and is_selected = ''1''
                and is_del = ''0''
            union all
            select
                insurance_cd
                , 3 as no
                , CAST((insu_set_info ->> ''insu_pub3_cd'') AS integer) AS insu_pub_cd
            from
                pat_insurance
            where
                insu_set_info ->> ''insu_pub3_cd'' is not null
                and is_selected = ''1''
                and is_del = ''0''
            union all
            select
                insurance_cd
                , 4 as no
                , CAST((insu_set_info ->> ''insu_pub4_cd'') AS integer) AS insu_pub_cd
            from
                pat_insurance
            where
                insu_set_info ->> ''insu_pub4_cd'' is not null
                and is_selected = ''1''
                and is_del = ''0''
            union all
            select
                insurance_cd
                , 5 as no
                , CAST((insu_set_info ->> ''insu_cd'') AS integer) AS insu_pub_cd
            from
                pat_insurance
            where
                insu_set_info ->> ''insu_cd'' is not null
                and is_selected = ''1''
                and is_del = ''0''
        ) AS pat_set
            ON pat_set.insu_pub_cd = pat_ins.insurance_cd
    where
        pat_ins.is_del = ''0''
    union all
    select
        insurance_cd
        , pat_id
        , insu_class
        , null as insu_info
        , 0 as no
        , null as insu_pub_info
        , pat_ins.memo1 as memo1
        , pat_ins.memo2 as memo2
        , pat_ins.up_date as up_date
    from
        pat_insurance pat_ins
    where
        insu_class = ''3''
        AND pat_ins.is_selected = ''1''
        AND pat_ins.is_del = ''0''
)
SELECT
    ntss_db6_ppm.hosp_pat_id AS hosppatid       --患者ID
    , ntss_db6_ppm.pat_id AS patid
    , personal_info_decrypt(ntss_db6_ppm.pat_last_name) || '' '' || personal_info_decrypt(ntss_db6_ppm.pat_first_name)
     AS name                                    --氏名
    , personal_info_decrypt(ntss_db6_ppm.pat_last_name_kana) || '' '' || personal_info_decrypt(ntss_db6_ppm.pat_first_name_kana)
     AS namekana                                --患者名カナ
    , 0 as dialcount                            --透析回数***
    , '''' as shantpart                           --シャント位置***
    , '''' as ctr                                 --CTR***
    , '''' as ctrupdate                           --CTR更新日時***
    , ntss_db6_ppm.pat_blood_type_abo AS bloodtypeabo --血液型ABO
    , ntss_db6_ppm.pat_blood_type_rh AS bloodtyperh --血液型RH
    , ntss_db6_ppm.pat_birthday AS birthday     --生年月日
    , ntss_db6_ppm.pat_sex AS sexcd             --性別
    , CASE
        WHEN ntss_db6_pat_ins.insu_class = ''0''
            THEN ntss_db6_pat_ins.insu_info ->> ''insu_pat_no''
        WHEN ntss_db6_pat_ins.insu_class = ''1''
            THEN ntss_db6_pat_ins.insu_pub_info ->> ''insu_pub_no''
        WHEN ntss_db6_pat_ins.insu_class = ''2''
            THEN ntss_db6_pat_ins.insu_pub_info ->> ''insu_pub_no''
        END AS insuranceno                      --保険者番号
    , ntss_db6_pat_ins.memo1 as insurancememo1  --保険メモ1
    , ntss_db6_pat_ins.memo2 as insurancememo2  --保険メモ2
    , CASE
        WHEN ntss_db6_pat_ins.insu_class = ''2''
            THEN CASE
            WHEN ntss_db6_pat_ins.no = 1
                THEN ntss_db6_pat_ins.insu_pub_info ->> ''insu_pub_no''
            END
        ELSE ntss_db6_pat_ins.insu_pub_info ->> ''insu_pub_no''
        END AS pubinsuno1                       --公費負担者番号1
    , CASE
        WHEN ntss_db6_pat_ins.insu_class = ''2''
            THEN CASE
            WHEN ntss_db6_pat_ins.no = 1
                THEN ntss_db6_pat_ins.insu_pub_info ->> ''insu_pub_pat_no''
            END
        ELSE ntss_db6_pat_ins.insu_pub_info ->> ''insu_pub_pat_no''
        END AS pubinsurecno1                    --公費負担医療需給者番号1
    , CASE
        WHEN ntss_db6_pat_ins.insu_class = ''2''
            THEN CASE
            WHEN ntss_db6_pat_ins.no = 2
                THEN ntss_db6_pat_ins.insu_pub_info ->> ''insu_pub_no''
            END
        ELSE ntss_db6_pat_ins.insu_pub_info ->> ''insu_pub_no''
        END AS pubinsuno2                       --公費負担者番号2
    , CASE
        WHEN ntss_db6_pat_ins.insu_class = ''2''
            THEN CASE
            WHEN ntss_db6_pat_ins.no = 2
                THEN ntss_db6_pat_ins.insu_pub_info ->> ''insu_pub_pat_no''
            END
        ELSE ntss_db6_pat_ins.insu_pub_info ->> ''insu_pub_pat_no''
        END AS pubinsurecno2                    --公費負担医療需給者番号2
    , CASE
        WHEN ntss_db6_pat_ins.insu_class = ''0''
            THEN ntss_db6_pat_ins.insu_info ->> ''insu_pat_no''
        WHEN ntss_db6_pat_ins.insu_class = ''2''
        AND ntss_db6_pat_ins.no = 5
            THEN ntss_db6_pat_ins.insu_info ->> ''insu_pat_no''
        END AS insurancecd                      --保険区分
    , CASE
        WHEN ntss_db6_pat_ins.insu_class = ''0''
            THEN ntss_db6_pat_ins.insu_info ->> ''insu_pat_mark''
        WHEN ntss_db6_pat_ins.insu_class = ''2''
        AND ntss_db6_pat_ins.no = 5
            THEN ntss_db6_pat_ins.insu_info ->> ''insu_pat_mark''
        END AS hiinsurancecode                  --被保険者記号番号
    , CASE
        WHEN ntss_db6_pat_ins.insu_class = ''0''
            THEN CASE
            WHEN ntss_db6_ppm.in_out_class = ''0''
                THEN ntss_db6_pat_ins.insu_info ->> ''futan-g''
            WHEN ntss_db6_ppm.in_out_class = ''1''
                THEN ntss_db6_pat_ins.insu_info ->> ''futan-n''
            END
        WHEN ntss_db6_pat_ins.insu_class = ''2''
        AND ntss_db6_pat_ins.no = 5
            THEN CASE
            WHEN ntss_db6_ppm.in_out_class = ''0''
                THEN ntss_db6_pat_ins.insu_info ->> ''futan-g''
            WHEN ntss_db6_ppm.in_out_class = ''1''
                THEN ntss_db6_pat_ins.insu_info ->> ''futan-n''
            END
        END AS insuranceratio                   --保険率
    , '''' as disabilityno                        --障害者手帳NO
    , '''' as doctorcd1                           --担当医ｃｄ1
    , '''' as doctorcd2                           --担当医ｃｄ2
    , '''' as doctorname1                         --担当医1
    , '''' as doctorname2                         --担当医2
    , ntss_db6_ppm.in_out_class AS inoutclass   --入院外来
    , '''' as startdate                           --当院開始日
    , to_char(ntss_db6_ppm.die_date, ''YYYY-MM-DD hh24:mi:ss'') AS diedate --死亡日
    , '''' as infect                              --感染症有無
    , '''' as ward                                --病棟名
    , '''' as course                              -- 診療科名
    , '''' as memo                                --MEMO
    , '''' as staffcd1                            --担当スタッフｃｄ１
    , '''' as staffcd2                            --担当スタッフｃｄ２
    , '''' as staffname1                          --担当スタッフ１
    , '''' as staffname2                          --担当スタッフ２
    , case
        when ntss_db6_ppm.dial_diff_com_info IS NOT NULL
        AND ntss_db6_ppm.dial_diff_com_info <> ''[]''
            then ''有''
        else ''無''
        END AS dialdiff                         --透析困難
    , dail.dialdiffcd                           --透析困難コメントコード
    , '''' as dialdiffhospitalcd1                 --透析困難院内コード
    , '''' as dialdiffcomment                     --透析困難コメント
    , ntss_db6_ppm.severity_cd as severitycd    --重傷度コード
    , '''' as injurycd                            --重傷度コード
    , '''' as injuryname                          --重傷度名称
    , ntss_db6_ppm.primary_disease_cd as basediseasecd --原疾患コード
    , '''' diseasehospitalcd                      --原疾患院内コード
    , '''' as basediseasename                     --原疾患名称
    , ntss_db6_ppm.transport_cd as transportcd  --輸送区分コード
    , '''' as transporthospitalcd                 --輸送区分院内コード
    , '''' as transportname                       --輸送区分名称
    , to_char(ntss_db6_ppm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    , '''' as patgroupname                        --患者グループ
    , '''' as patgroupcd                          --患者グループコード
    , '''' as dialstartdate                       --透析導入日
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
        ) else ntss_db6_ppm.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
         end
    );',3,'[]','1','{"applications": [5]}','{"classes": []}','患者基本情報：@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid","doctorcd1","doctorcd2","staffcd1","staffcd2","dialdiffcd","basediseasecd","transportcd", "severitycd"]}','2021/02/26 17:51:54','2021/02/26 17:51:54',NULL);

DELETE FROM sys_data_set WHERE sql_cd in(-2016);
INSERT INTO ntss.sys_data_set(sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) VALUES
    (-2016,'select

    mst.severity_cd as severitycd

    , mst.severity_name as injuryname

    , mst.in_hospital_cd_1 as injurycd

from

    mst_severity mst

where

    mst.facility_cd = @facilityCd;',2,'[]','1','{"applications": [5]}','{"classes": []}','患者基本情報：　@facilityCd使用 {"Mergekey": ["severitycd"]}','2021/07/29 16:18:57','2021/07/29 16:19:00',NULL);

DELETE FROM sys_data_set WHERE sql_cd in(-2240);
INSERT INTO ntss.sys_data_set(sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) VALUES
    (-2240,'SELECT
    '''' AS hosppatid                             --患者ID
    , ntss_db5_om.pat_id AS patid
    , to_char(
        ntss_db5_om.rst_start_date
        , ''YYYY-MM-DD hh24:mi:ss''
    ) AS startdate                              --開始日時
    , to_char(
        ntss_db5_mm_1.occur_date
        , ''YYYY-MM-DD hh24:mi:ss''
    ) AS occurdate                              --発生日時
    , CASE
        WHEN ntss_db5_mm_1.data_type IN (''2'', ''4'', ''5'', ''6'')
            THEN ntss_db5_mm_1.monitor_data ->> ''90''
        END AS bpmax                            --最高血圧
    , CASE
        WHEN ntss_db5_mm_1.data_type IN (''2'', ''4'', ''5'', ''6'')
            THEN ntss_db5_mm_1.monitor_data ->> ''91''
        END AS bpmin                            --最低血圧
    , CASE
        WHEN ntss_db5_mm_1.data_type IN (''2'', ''4'', ''5'', ''6'')
            THEN ntss_db5_mm_1.monitor_data ->> ''92''
        END AS bpave                            --平均血圧
    , CASE
        WHEN ntss_db5_mm_1.data_type IN (''2'', ''4'', ''5'', ''6'')
            THEN ntss_db5_mm_1.monitor_data ->> ''93''
        END AS pulse                            --脈拍
    , CASE
        WHEN ntss_db5_mm_1.data_type IN (''2'', ''4'', ''5'', ''6'')
            THEN ntss_db5_mm_1.monitor_data ->> ''94''
        END AS temperature                      --体温
    , CASE
        WHEN ntss_db5_mm_1.data_type IN (''2'', ''4'', ''5'', ''6'')
            THEN ntss_db5_mm_1.monitor_data ->> ''-1''
        END AS bloodsugarlevel                  --血糖値
    , to_char(ntss_db5_mm_1.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS UPDATE --更新日時
    , ntss_db5_mm_1.ord_no AS diadysisno        --透析番号
    , ntss_db5_mm_1.data_type AS bpclass        --血圧区分
FROM
    (
        SELECT
            ntss_db5_mm_1.facility_cd
            , ntss_db5_mm_1.ord_no AS ord_no
            , ntss_db5_mm_1.data_type AS data_type
            , ntss_db5_mm_1.monitor_data AS monitor_data
            , MIN(ntss_db5_mm_1.occur_date) AS occur_date
            , MIN(ntss_db5_mm_1.up_date) AS up_date
        FROM
            mni_monitor ntss_db5_mm_1
        WHERE
            ntss_db5_mm_1.ord_no IS NOT NULL
            AND ntss_db5_mm_1.data_type IN (''2'', ''4'', ''5'', ''6'', ''-1'')
            AND ntss_db5_mm_1.facility_cd = @facilityCd
            AND ntss_db5_mm_1.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_date(@toDate, ''YYYYMMDDHH24MISS'')
        GROUP BY
            ntss_db5_mm_1.facility_cd
            , ntss_db5_mm_1.ord_no
            , ntss_db5_mm_1.data_type
            , ntss_db5_mm_1.monitor_data
    ) AS ntss_db5_mm_1
    LEFT JOIN ord_main ntss_db5_om
        ON ntss_db5_mm_1.ord_no = ntss_db5_om.ord_no
WHERE
    ntss_db5_om.is_del = ''0''
    AND ntss_db5_om.pat_id IS NOT NULL;
',2,'[]','1','{"applications": [5]}','{"classes": []}','患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}','2021/02/26 17:51:54.726','2021/02/26 17:51:54.726',NULL);

DELETE FROM sys_data_set WHERE sql_cd in(-2012);
INSERT INTO ntss.sys_data_set(sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) VALUES
    (-2012,'select

    CAST(mst.user_id AS VARCHAR) as doctorcd1

    , CAST(mst.user_id AS VARCHAR) as doctorcd2

    , CAST(mst.user_id AS VARCHAR) as staffcd1

    , CAST(mst.user_id AS VARCHAR) as staffcd2

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

    mst.facility_cd = @facilityCd',3,'[]','1','{"applications": [5]}','{"classes": []}','患者基本情報：　@facilityCd使用 {"Mergekey": ["doctorcd1","doctorcd2","staffcd1","staffcd2"]}','2021/07/29 16:18:57','2021/07/29 16:19:00',NULL);


