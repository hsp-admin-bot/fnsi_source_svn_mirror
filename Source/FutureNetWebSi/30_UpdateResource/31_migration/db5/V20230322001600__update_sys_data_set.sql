-- V_PAT_INFO
UPDATE sys_data_set
SET "sql"=
        'with pat_personal_main_dial_tbl as (
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
             AND ntss_db6_ppm.up_date BETWEEN to_date(@fromDate, ''YYYYMMDDHH24MISS'') AND to_date(@toDate, ''YYYYMMDDHH24MISS'');'
WHERE sql_cd = '-2010';


-- V_PAT_MEDICAL_HST_1
UPDATE sys_data_set
SET "sql" =
        'SELECT
             '''' AS hosppatid --患者ID
             ,ntss_db5_pu.pat_id AS patid
             ,ntss_db5_pu_mhi_json ->> ''ctl_no'' AS ctlno --管理番号
             ,to_char(ntss_db5_pu.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
             ,ntss_db5_pu_mst_d.disease_cd AS diseasecd --病名コード
             ,ntss_db5_pu_mst_d.disease_name AS diseasename --病名
             ,to_char(to_timestamp(ntss_db5_pu_mhi_json ->> ''disease_date'', ''YYYYMMDD''), ''YYYY-MM-DD hh24:mi:ss'') AS diseasedate --発症日
             ,to_char(to_timestamp(ntss_db5_pu_mhi_json ->> ''out_come_date'', ''YYYYMMDD''), ''YYYY-MM-DD hh24:mi:ss'') AS recoverdate --治癒日
             ,ntss_db5_pu_mhi_json ->> ''is_main_disease'' AS maindisease --主病名
             ,ntss_db5_pu_mhi_json ->> ''out_come'' AS status --転帰
             ,ntss_db5_pu_mhi_json ->> ''is_notice'' AS noticeflg --告知有無
             ,ntss_db5_pu_mhi_json ->> ''diagnostician_cd'' AS doctorname --診断医
             ,ntss_db5_pu_mhi_json ->> ''memo'' AS memo --メモ
         FROM
             pat_unique ntss_db5_pu
             CROSS JOIN LATERAL json_array_elements(ntss_db5_pu.medical_hst_info::json) ntss_db5_pu_mhi_json
             LEFT JOIN mst_disease ntss_db5_pu_mst_d
             ON cast(ntss_db5_pu_mst_d.disease_cd AS char(20)) = cast(ntss_db5_pu_mhi_json ->> ''disease_cd'' AS char(20))
         WHERE
             ntss_db5_pu.is_del = ''0''
             AND ntss_db5_pu.facility_cd = @facilityCd
             AND ntss_db5_pu.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
             AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
             AND ntss_db5_pu.medical_hst_info IS NOT NULL
             AND ntss_db5_pu.medical_hst_info <> ''[]''
             AND ntss_db5_pu_mhi_json ->> ''course_is_free'' = ''1'';'
WHERE sql_cd = '-2040';


-- V_PAT_MEDICAL_HST_0
UPDATE sys_data_set
SET "sql" =
        'SELECT
			'''' AS hosppatid --患者ID
			,ntss_db5_pu.pat_id AS patid
			,ntss_db5_pu_mhi_json ->> ''ctl_no'' AS ctlno --管理番号
			,to_char(ntss_db5_pu.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
			,ntss_db5_pu_mst_d.disease_cd AS diseasecd --病名コード
			,ntss_db5_pu_mst_d.disease_name AS diseasename --病名
			,to_char(to_timestamp(ntss_db5_pu_mhi_json ->> ''disease_date'', ''YYYYMMDD''), ''YYYY-MM-DD hh24:mi:ss'') AS diseasedate --発症日
			,to_char(to_timestamp(ntss_db5_pu_mhi_json ->> ''out_come_date'', ''YYYYMMDD''), ''YYYY-MM-DD hh24:mi:ss'') AS recoverdate --治癒日
			,ntss_db5_pu_mhi_json ->> ''is_main_disease'' AS maindisease --主病名
			,ntss_db5_pu_mhi_json ->> ''out_come'' AS status --転帰
			,ntss_db5_pu_mhi_json ->> ''is_notice'' AS noticeflg --告知有無
			,ntss_db5_pu_mhi_json ->> ''diagnostician_cd'' AS doctorname --診断医
			,cast(ntss_db5_pu_mst_d.disease_cd AS integer) AS userid
			,ntss_db5_pu_mhi_json ->> ''memo'' AS memo --メモ
		FROM
			pat_unique ntss_db5_pu
			CROSS JOIN LATERAL json_array_elements(ntss_db5_pu.medical_hst_info::json) ntss_db5_pu_mhi_json
			LEFT JOIN mst_disease ntss_db5_pu_mst_d
			ON cast(ntss_db5_pu_mst_d.disease_cd AS char(20)) = cast(ntss_db5_pu_mhi_json ->> ''disease_cd'' AS char(20))
		WHERE
			ntss_db5_pu.is_del = ''0''
			AND ntss_db5_pu.facility_cd = @facilityCd
			AND ntss_db5_pu.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
			AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
			AND ntss_db5_pu.medical_hst_info IS NOT NULL
			AND ntss_db5_pu.medical_hst_info <> ''[]''
			AND ntss_db5_pu_mhi_json ->> ''course_is_free'' = ''0'';'
WHERE sql_cd = '-2041';


-- V_PAT_INFECT
UPDATE sys_data_set
SET "sql" =
        'SELECT
            '''' AS hosppatid --患者ID
            ,ntss_db5_mst_mi.in_hospital_cd_1 AS infectioncd --感染症コード
            ,ntss_db5_mst_mi.infection_name AS infectionname --感染症名
            ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
            ,ntss_db5_pm_json ->> ''infect'' AS infect --結果コード
            ,ntss_db5_pm.pat_id AS patid
        FROM
            pat_main ntss_db5_pm
            CROSS JOIN LATERAL json_array_elements(ntss_db5_pm.infect_info ::json) ntss_db5_pm_json
            INNER JOIN mst_infection ntss_db5_mst_mi
            ON CAST(ntss_db5_mst_mi.infection_cd as varchar(4)) = ntss_db5_pm_json ->> ''infection_cd''
        WHERE
            ntss_db5_pm.is_del = ''0''
            AND ntss_db5_pm.facility_cd = @facilityCd
            AND ntss_db5_pm.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
            AND to_date(  @toDate , ''YYYYMMDDHH24MISS'' );'
WHERE sql_cd = '-2050';


-- V_PAT_RECEIPT_MEMO
UPDATE sys_data_set
SET "sql" =
        'with ntss_db5_mst_add as (
        SELECT
            ntss_db5_mst_addition.addition_cd AS additioncd
            ,ntss_db5_mst_addition.addition_class AS additionclass
            ,ntss_db5_mst_addition.up_date AS addupdate
            ,ntss_db5_mst_addition.in_hospital_cd_1 AS inhospitalcd1
            ,ntss_db5_mst_addition.in_hospital_cd_2 AS inhospitalcd2
        FROM mst_addition ntss_db5_mst_addition
        WHERE ntss_db5_mst_addition.facility_cd = @facilityCd
    )
    SELECT
    ntss_db5_pm.pat_id AS patid
        ,'''' AS hosppatid --患者ID
        ,to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
        ,CASE
           WHEN ntss_db5_mst_add.additionclass = ''2''
           THEN ''1''
           ELSE ''0''
        END AS division -- レセプトメモ区分
       ,ntss_db5_pm_json ->> ''cd'' AS codes --コード
       ,to_char(ntss_db5_mst_add.addupdate, ''YYYY-MM-DD hh24:mi:ss'') AS codeupdate --コード更新日時
       ,''1'' AS addflg -- 加算有無
       ,ntss_db5_pm_json ->> ''name'' AS itemname --項目名称
       ,CASE
           WHEN ntss_db5_mst_add.additionclass = ''2''
           THEN ''1''
           ELSE ''0''
        END AS maindialdiff --主たる透析困難
        ,ntss_db5_mst_add.inhospitalcd1 AS inhospitalcd --院内コード
        ,ntss_db5_mst_add.inhospitalcd2 AS inhospitalcd2 --院内コード２
    FROM
        pat_main ntss_db5_pm
        CROSS JOIN LATERAL json_array_elements(ntss_db5_pm.addition_info ::json) ntss_db5_pm_json
        INNER JOIN ntss_db5_mst_add
        ON CAST(ntss_db5_mst_add.additioncd as varchar(4)) = ntss_db5_pm_json ->> ''cd''
    WHERE
        ntss_db5_pm.is_del = ''0''
        AND ntss_db5_pm.facility_cd = @facilityCd
        AND ntss_db5_pm.up_date BETWEEN to_date(@fromDate, ''YYYYMMDDHH24MISS'' )
        AND to_date( @toDate , ''YYYYMMDDHH24MISS'' );'
WHERE sql_cd = '-2060';


-- V_PAT_REVISE_TARE
UPDATE sys_data_set
SET "sql" =
        'SELECT
           '''' AS hosppatid                             --患者ID
           , ntss_db5_pm.pat_id AS patid
           , '''' AS names                               --氏名
           , 1 as ctlno                                --管理番号
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時(当日)
           , CASE
               WHEN extract(DOW FROM now()) = 1
                   THEN ntss_db5_pm.tare_info #>> ''{1,name_1}''
               WHEN extract(DOW FROM now()) = 2
                   THEN ntss_db5_pm.tare_info #>> ''{2,name_1}''
               WHEN extract(DOW FROM now()) = 3
                   THEN ntss_db5_pm.tare_info #>> ''{3,name_1}''
               WHEN extract(DOW FROM now()) = 4
                   THEN ntss_db5_pm.tare_info #>> ''{4,name_1}''
               WHEN extract(DOW FROM now()) = 5
                   THEN ntss_db5_pm.tare_info #>> ''{5,name_1}''
               WHEN extract(DOW FROM now()) = 6
                   THEN ntss_db5_pm.tare_info #>> ''{6,name_1}''
               WHEN extract(DOW FROM now()) = 7
                   THEN ntss_db5_pm.tare_info #>> ''{7,name_1}''
               END AS revisename                       --風袋補正名(当日)
           , CASE
               WHEN extract(DOW FROM now()) = 1
                   THEN ntss_db5_pm.tare_info #>> ''{1,weight_1}''
               WHEN extract(DOW FROM now()) = 2
                   THEN ntss_db5_pm.tare_info #>> ''{2,weight_1}''
               WHEN extract(DOW FROM now()) = 3
                   THEN ntss_db5_pm.tare_info #>> ''{3,weight_1}''
               WHEN extract(DOW FROM now()) = 4
                   THEN ntss_db5_pm.tare_info #>> ''{4,weight_1}''
               WHEN extract(DOW FROM now()) = 5
                   THEN ntss_db5_pm.tare_info #>> ''{5,weight_1}''
               WHEN extract(DOW FROM now()) = 6
                   THEN ntss_db5_pm.tare_info #>> ''{6,weight_1}''
               WHEN extract(DOW FROM now()) = 7
                   THEN ntss_db5_pm.tare_info #>> ''{7,weight_1}''
               END AS reviseweight                     --重量(当日)
           , ntss_db5_pm_mst_wc.wheel_chair_cd AS hospwheelchaircd --車椅子コード(当日)
           , ntss_db5_pm_mst_wc.wheel_chair_name AS wheelchairname --車椅子名(当日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS monupdate --更新日時(月曜日)
           , ntss_db5_pm.off_water_info #>> ''{1,name_1}'' AS monrevisename --風袋補正名(月曜日)
           , ntss_db5_pm.off_water_info #>> ''{1,weight_1}'' AS monreviseweight --重量(月曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS monhospwheelchaircd --車椅子コード(月曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS monwheelchairname --車椅子名(月曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS tueupdate --更新日時(火曜日)
           , ntss_db5_pm.off_water_info #>> ''{2,name_1}'' AS tuerevisename --風袋補正名(火曜日)
           , ntss_db5_pm.off_water_info #>> ''{2,weight_1}'' AS tuereviseweight --重量(火曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS tuehospwheelchaircd --車椅子コード(火曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS tuewheelchairname --車椅子名(火曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS wedupdate --更新日時(水曜日)
           , ntss_db5_pm.off_water_info #>> ''{3,name_1}'' AS wedrevisename --除水補正名(水曜日)
           , ntss_db5_pm.off_water_info #>> ''{3,weight_1}'' AS wedreviseweight --重量(水曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS wedhospwheelchaircd --車椅子コード(水曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS wedwheelchairname --車椅子名(水曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS thuupdate --更新日時(木曜日)
           , ntss_db5_pm.off_water_info #>> ''{4,name_1}'' AS thurevisename --除水補正名(木曜日)
           , ntss_db5_pm.off_water_info #>> ''{4,weight_1}'' AS thureviseweight --重量(木曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS thuhospwheelchaircd --車椅子コード(木曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS thuwheelchairname --車椅子名(木曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS friupdate --更新日時(金曜日)
           , ntss_db5_pm.off_water_info #>> ''{5,name_1}'' AS frirevisename --除水補正名(金曜日)
           , ntss_db5_pm.off_water_info #>> ''{5,weight_1}'' AS frireviseweight --重量(金曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS frihospwheelchaircd --車椅子コード(金曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS friwheelchairname --車椅子名(金曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS satupdate --更新日時(土曜日)
           , ntss_db5_pm.off_water_info #>> ''{6,name_1}'' AS satrevisename --除水補正名(土曜日)
           , ntss_db5_pm.off_water_info #>> ''{6,weight_1}'' AS satreviseweight --重量(土曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS sathospwheelchaircd --車椅子コード(土曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS satwheelchairname --車椅子名(土曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS sunupdate --更新日時(日曜日)
           , ntss_db5_pm.off_water_info #>> ''{7,name_1}'' AS sunrevisename --除水補正名(日曜日)
           , ntss_db5_pm.off_water_info #>> ''{7,weight_1}'' AS sunreviseweight --重量(日曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS sunhospwheelchaircd --車椅子コード(日曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS sunwheelchairname --車椅子名(日曜日)
       FROM
           pat_main ntss_db5_pm
           LEFT JOIN mst_wheel_chair ntss_db5_pm_mst_wc
               ON ntss_db5_pm_mst_wc.pat_id = ntss_db5_pm.pat_id
           LEFT JOIN mst_wheel_chair ntss_db5_pm_mst_wc1
               ON ntss_db5_pm_mst_wc1.pat_id = ntss_db5_pm.pat_id
               AND ntss_db5_pm_mst_wc1.is_personal = ''1''
       WHERE
           ntss_db5_pm.is_del = ''0''
           AND ntss_db5_pm.facility_cd = @facilityCd
           AND ntss_db5_pm.up_date BETWEEN to_date(@fromDate, ''YYYYMMDDHH24MISS'') AND to_date(@toDate, ''YYYYMMDDHH24MISS'')
           AND ntss_db5_pm.off_water_info IS NOT NULL
           AND ntss_db5_pm.off_water_info <> ''[]''
       UNION ALL
       SELECT
           '''' AS hosppatid                             --患者ID
           , ntss_db5_pm.pat_id AS patid
           , '''' AS names                               --氏名
           , 2 as ctlno                                --管理番号
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時(当日)
           , CASE
               WHEN extract(DOW FROM now()) = 1
                   THEN ntss_db5_pm.tare_info #>> ''{1,name_2}''
               WHEN extract(DOW FROM now()) = 2
                   THEN ntss_db5_pm.tare_info #>> ''{2,name_2}''
               WHEN extract(DOW FROM now()) = 3
                   THEN ntss_db5_pm.tare_info #>> ''{3,name_2}''
               WHEN extract(DOW FROM now()) = 4
                   THEN ntss_db5_pm.tare_info #>> ''{4,name_2}''
               WHEN extract(DOW FROM now()) = 5
                   THEN ntss_db5_pm.tare_info #>> ''{5,name_2}''
               WHEN extract(DOW FROM now()) = 6
                   THEN ntss_db5_pm.tare_info #>> ''{6,name_2}''
               WHEN extract(DOW FROM now()) = 7
                   THEN ntss_db5_pm.tare_info #>> ''{7,name_2}''
               END AS revisename                       --風袋補正名(当日)
           , CASE
               WHEN extract(DOW FROM now()) = 1
                   THEN ntss_db5_pm.tare_info #>> ''{1,weight_2}''
               WHEN extract(DOW FROM now()) = 2
                   THEN ntss_db5_pm.tare_info #>> ''{2,weight_2}''
               WHEN extract(DOW FROM now()) = 3
                   THEN ntss_db5_pm.tare_info #>> ''{3,weight_2}''
               WHEN extract(DOW FROM now()) = 4
                   THEN ntss_db5_pm.tare_info #>> ''{4,weight_2}''
               WHEN extract(DOW FROM now()) = 5
                   THEN ntss_db5_pm.tare_info #>> ''{5,weight_2}''
               WHEN extract(DOW FROM now()) = 6
                   THEN ntss_db5_pm.tare_info #>> ''{6,weight_2}''
               WHEN extract(DOW FROM now()) = 7
                   THEN ntss_db5_pm.tare_info #>> ''{7,weight_2}''
               END AS reviseweight                     --重量(当日)
           , ntss_db5_pm_mst_wc.wheel_chair_cd AS hospwheelchaircd --車椅子コード(当日)
           , ntss_db5_pm_mst_wc.wheel_chair_name AS wheelchairname --車椅子名(当日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS monupdate --更新日時(月曜日)
           , ntss_db5_pm.tare_info #>> ''{1,name_2}'' AS monrevisename --風袋補正名(月曜日)
           , ntss_db5_pm.tare_info #>> ''{1,weight_2}'' AS monreviseweight --重量(月曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS monhospwheelchaircd --車椅子コード(月曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS monwheelchairname --車椅子名(月曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS tueupdate --更新日時(火曜日)
           , ntss_db5_pm.tare_info #>> ''{2,name_2}'' AS tuerevisename --風袋補正名(火曜日)
           , ntss_db5_pm.tare_info #>> ''{2,weight_2}'' AS tuereviseweight --重量(火曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS tuehospwheelchaircd --車椅子コード(火曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS tuewheelchairname --車椅子名(火曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS wedupdate --更新日時(水曜日)
           , ntss_db5_pm.tare_info #>> ''{3,name_2}'' AS wedrevisename --除水補正名(水曜日)
           , ntss_db5_pm.tare_info #>> ''{3,weight_2}'' AS wedreviseweight --重量(水曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS wedhospwheelchaircd --車椅子コード(水曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS wedwheelchairname --車椅子名(水曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS thuupdate --更新日時(木曜日)
           , ntss_db5_pm.tare_info #>> ''{4,name_2}'' AS thurevisename --除水補正名(木曜日)
           , ntss_db5_pm.tare_info #>> ''{4,weight_2}'' AS thureviseweight --重量(木曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS thuhospwheelchaircd --車椅子コード(木曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS thuwheelchairname --車椅子名(木曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS friupdate --更新日時(金曜日)
           , ntss_db5_pm.tare_info #>> ''{5,name_2}'' AS frirevisename --除水補正名(金曜日)
           , ntss_db5_pm.tare_info #>> ''{5,weight_2}'' AS frireviseweight --重量(金曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS frihospwheelchaircd --車椅子コード(金曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS friwheelchairname --車椅子名(金曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS satupdate --更新日時(土曜日)
           , ntss_db5_pm.tare_info #>> ''{6,name_2}'' AS satrevisename --除水補正名(土曜日)
           , ntss_db5_pm.tare_info #>> ''{6,weight_2}'' AS satreviseweight --重量(土曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS sathospwheelchaircd --車椅子コード(土曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS satwheelchairname --車椅子名(土曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS sunupdate --更新日時(日曜日)
           , ntss_db5_pm.tare_info #>> ''{7,name_2}'' AS sunrevisename --除水補正名(日曜日)
           , ntss_db5_pm.tare_info #>> ''{7,weight_2}'' AS sunreviseweight --重量(日曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS sunhospwheelchaircd --車椅子コード(日曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS sunwheelchairname --車椅子名(日曜日)
       FROM
           pat_main ntss_db5_pm
           LEFT JOIN mst_wheel_chair ntss_db5_pm_mst_wc
               ON ntss_db5_pm_mst_wc.pat_id = ntss_db5_pm.pat_id
           LEFT JOIN mst_wheel_chair ntss_db5_pm_mst_wc1
               ON ntss_db5_pm_mst_wc1.pat_id = ntss_db5_pm.pat_id
               AND ntss_db5_pm_mst_wc1.is_personal = ''1''
       WHERE
           ntss_db5_pm.is_del = ''0''
           AND ntss_db5_pm.facility_cd = @facilityCd
           AND ntss_db5_pm.up_date BETWEEN to_date(@fromDate, ''YYYYMMDDHH24MISS'') AND to_date(@toDate, ''YYYYMMDDHH24MISS'')
           AND ntss_db5_pm.off_water_info IS NOT NULL
           AND ntss_db5_pm.off_water_info <> ''[]''
       UNION ALL
       SELECT
           '''' AS hosppatid                             --患者ID
           , ntss_db5_pm.pat_id AS patid
           , '''' AS names                               --氏名
           , 3 as ctlno                                --管理番号
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時(当日)
           , CASE
               WHEN extract(DOW FROM now()) = 1
                   THEN ntss_db5_pm.tare_info #>> ''{1,name_3}''
               WHEN extract(DOW FROM now()) = 2
                   THEN ntss_db5_pm.tare_info #>> ''{2,name_3}''
               WHEN extract(DOW FROM now()) = 3
                   THEN ntss_db5_pm.tare_info #>> ''{3,name_3}''
               WHEN extract(DOW FROM now()) = 4
                   THEN ntss_db5_pm.tare_info #>> ''{4,name_3}''
               WHEN extract(DOW FROM now()) = 5
                   THEN ntss_db5_pm.tare_info #>> ''{5,name_3}''
               WHEN extract(DOW FROM now()) = 6
                   THEN ntss_db5_pm.tare_info #>> ''{6,name_3}''
               WHEN extract(DOW FROM now()) = 7
                   THEN ntss_db5_pm.tare_info #>> ''{7,name_3}''
               END AS revisename                       --風袋補正名(当日)
           , CASE
               WHEN extract(DOW FROM now()) = 1
                   THEN ntss_db5_pm.tare_info #>> ''{1,weight_3}''
               WHEN extract(DOW FROM now()) = 2
                   THEN ntss_db5_pm.tare_info #>> ''{2,weight_3}''
               WHEN extract(DOW FROM now()) = 3
                   THEN ntss_db5_pm.tare_info #>> ''{3,weight_3}''
               WHEN extract(DOW FROM now()) = 4
                   THEN ntss_db5_pm.tare_info #>> ''{4,weight_3}''
               WHEN extract(DOW FROM now()) = 5
                   THEN ntss_db5_pm.tare_info #>> ''{5,weight_3}''
               WHEN extract(DOW FROM now()) = 6
                   THEN ntss_db5_pm.tare_info #>> ''{6,weight_3}''
               WHEN extract(DOW FROM now()) = 7
                   THEN ntss_db5_pm.tare_info #>> ''{7,weight_3}''
               END AS reviseweight                     --重量(当日)
           , ntss_db5_pm_mst_wc.wheel_chair_cd AS hospwheelchaircd --車椅子コード(当日)
           , ntss_db5_pm_mst_wc.wheel_chair_name AS wheelchairname --車椅子名(当日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS monupdate --更新日時(月曜日)
           , ntss_db5_pm.tare_info #>> ''{1,name_3}'' AS monrevisename --風袋補正名(月曜日)
           , ntss_db5_pm.tare_info #>> ''{1,weight_3}'' AS monreviseweight --重量(月曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS monhospwheelchaircd --車椅子コード(月曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS monwheelchairname --車椅子名(月曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS tueupdate --更新日時(火曜日)
           , ntss_db5_pm.tare_info #>> ''{2,name_3}'' AS tuerevisename --風袋補正名(火曜日)
           , ntss_db5_pm.tare_info #>> ''{2,weight_3}'' AS tuereviseweight --重量(火曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS tuehospwheelchaircd --車椅子コード(火曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS tuewheelchairname --車椅子名(火曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS wedupdate --更新日時(水曜日)
           , ntss_db5_pm.tare_info #>> ''{3,name_3}'' AS wedrevisename --除水補正名(水曜日)
           , ntss_db5_pm.tare_info #>> ''{3,weight_3}'' AS wedreviseweight --重量(水曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS wedhospwheelchaircd --車椅子コード(水曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS wedwheelchairname --車椅子名(水曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS thuupdate --更新日時(木曜日)
           , ntss_db5_pm.tare_info #>> ''{4,name_3}'' AS thurevisename --除水補正名(木曜日)
           , ntss_db5_pm.tare_info #>> ''{4,weight_3}'' AS thureviseweight --重量(木曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS thuhospwheelchaircd --車椅子コード(木曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS thuwheelchairname --車椅子名(木曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS friupdate --更新日時(金曜日)
           , ntss_db5_pm.tare_info #>> ''{5,name_3}'' AS frirevisename --除水補正名(金曜日)
           , ntss_db5_pm.tare_info #>> ''{5,weight_3}'' AS frireviseweight --重量(金曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS frihospwheelchaircd --車椅子コード(金曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS friwheelchairname --車椅子名(金曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS satupdate --更新日時(土曜日)
           , ntss_db5_pm.tare_info #>> ''{6,name_3}'' AS satrevisename --除水補正名(土曜日)
           , ntss_db5_pm.tare_info #>> ''{6,weight_3}'' AS satreviseweight --重量(土曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS sathospwheelchaircd --車椅子コード(土曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS satwheelchairname --車椅子名(土曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS sunupdate --更新日時(日曜日)
           , ntss_db5_pm.tare_info #>> ''{7,name_3}'' AS sunrevisename --除水補正名(日曜日)
           , ntss_db5_pm.tare_info #>> ''{7,weight_3}'' AS sunreviseweight --重量(日曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS sunhospwheelchaircd --車椅子コード(日曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS sunwheelchairname --車椅子名(日曜日)
       FROM
           pat_main ntss_db5_pm
           LEFT JOIN mst_wheel_chair ntss_db5_pm_mst_wc
               ON ntss_db5_pm_mst_wc.pat_id = ntss_db5_pm.pat_id
           LEFT JOIN mst_wheel_chair ntss_db5_pm_mst_wc1
               ON ntss_db5_pm_mst_wc1.pat_id = ntss_db5_pm.pat_id
               AND ntss_db5_pm_mst_wc1.is_personal = ''1''
       WHERE
           ntss_db5_pm.is_del = ''0''
           AND ntss_db5_pm.facility_cd = @facilityCd
           AND ntss_db5_pm.up_date BETWEEN to_date(@fromDate, ''YYYYMMDDHH24MISS'') AND to_date(@toDate, ''YYYYMMDDHH24MISS'')
           AND ntss_db5_pm.off_water_info IS NOT NULL
           AND ntss_db5_pm.off_water_info <> ''[]''
       UNION ALL
       SELECT
           '''' AS hosppatid                             --患者ID
           , ntss_db5_pm.pat_id AS patid
           , '''' AS names                               --氏名
           , 4 as ctlno                                --管理番号
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時(当日)
           , CASE
               WHEN extract(DOW FROM now()) = 1
                   THEN ntss_db5_pm.tare_info #>> ''{1,name_4}''
               WHEN extract(DOW FROM now()) = 2
                   THEN ntss_db5_pm.tare_info #>> ''{2,name_4}''
               WHEN extract(DOW FROM now()) = 3
                   THEN ntss_db5_pm.tare_info #>> ''{3,name_4}''
               WHEN extract(DOW FROM now()) = 4
                   THEN ntss_db5_pm.tare_info #>> ''{4,name_4}''
               WHEN extract(DOW FROM now()) = 5
                   THEN ntss_db5_pm.tare_info #>> ''{5,name_4}''
               WHEN extract(DOW FROM now()) = 6
                   THEN ntss_db5_pm.tare_info #>> ''{6,name_4}''
               WHEN extract(DOW FROM now()) = 7
                   THEN ntss_db5_pm.tare_info #>> ''{7,name_4}''
               END AS revisename                       --風袋補正名(当日)
           , CASE
               WHEN extract(DOW FROM now()) = 1
                   THEN ntss_db5_pm.tare_info #>> ''{1,weight_4}''
               WHEN extract(DOW FROM now()) = 2
                   THEN ntss_db5_pm.tare_info #>> ''{2,weight_4}''
               WHEN extract(DOW FROM now()) = 3
                   THEN ntss_db5_pm.tare_info #>> ''{3,weight_4}''
               WHEN extract(DOW FROM now()) = 4
                   THEN ntss_db5_pm.tare_info #>> ''{4,weight_4}''
               WHEN extract(DOW FROM now()) = 5
                   THEN ntss_db5_pm.tare_info #>> ''{5,weight_4}''
               WHEN extract(DOW FROM now()) = 6
                   THEN ntss_db5_pm.tare_info #>> ''{6,weight_4}''
               WHEN extract(DOW FROM now()) = 7
                   THEN ntss_db5_pm.tare_info #>> ''{7,weight_4}''
               END AS reviseweight                     --重量(当日)
           , ntss_db5_pm_mst_wc.wheel_chair_cd AS hospwheelchaircd --車椅子コード(当日)
           , ntss_db5_pm_mst_wc.wheel_chair_name AS wheelchairname --車椅子名(当日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS monupdate --更新日時(月曜日)
           , ntss_db5_pm.tare_info #>> ''{1,name_4}'' AS monrevisename --風袋補正名(月曜日)
           , ntss_db5_pm.tare_info #>> ''{1,weight_4}'' AS monreviseweight --重量(月曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS monhospwheelchaircd --車椅子コード(月曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS monwheelchairname --車椅子名(月曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS tueupdate --更新日時(火曜日)
           , ntss_db5_pm.tare_info #>> ''{2,name_4}'' AS tuerevisename --風袋補正名(火曜日)
           , ntss_db5_pm.tare_info #>> ''{2,weight_4}'' AS tuereviseweight --重量(火曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS tuehospwheelchaircd --車椅子コード(火曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS tuewheelchairname --車椅子名(火曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS wedupdate --更新日時(水曜日)
           , ntss_db5_pm.tare_info #>> ''{3,name_4}'' AS wedrevisename --除水補正名(水曜日)
           , ntss_db5_pm.tare_info #>> ''{3,weight_4}'' AS wedreviseweight --重量(水曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS wedhospwheelchaircd --車椅子コード(水曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS wedwheelchairname --車椅子名(水曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS thuupdate --更新日時(木曜日)
           , ntss_db5_pm.tare_info #>> ''{4,name_4}'' AS thurevisename --除水補正名(木曜日)
           , ntss_db5_pm.tare_info #>> ''{4,weight_4}'' AS thureviseweight --重量(木曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS thuhospwheelchaircd --車椅子コード(木曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS thuwheelchairname --車椅子名(木曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS friupdate --更新日時(金曜日)
           , ntss_db5_pm.tare_info #>> ''{5,name_4}'' AS frirevisename --除水補正名(金曜日)
           , ntss_db5_pm.tare_info #>> ''{5,weight_4}'' AS frireviseweight --重量(金曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS frihospwheelchaircd --車椅子コード(金曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS friwheelchairname --車椅子名(金曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS satupdate --更新日時(土曜日)
           , ntss_db5_pm.tare_info #>> ''{6,name_4}'' AS satrevisename --除水補正名(土曜日)
           , ntss_db5_pm.tare_info #>> ''{6,weight_4}'' AS satreviseweight --重量(土曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS sathospwheelchaircd --車椅子コード(土曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS satwheelchairname --車椅子名(土曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS sunupdate --更新日時(日曜日)
           , ntss_db5_pm.tare_info #>> ''{7,name_4}'' AS sunrevisename --除水補正名(日曜日)
           , ntss_db5_pm.tare_info #>> ''{7,weight_4}'' AS sunreviseweight --重量(日曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS sunhospwheelchaircd --車椅子コード(日曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS sunwheelchairname --車椅子名(日曜日)
       FROM
           pat_main ntss_db5_pm
           LEFT JOIN mst_wheel_chair ntss_db5_pm_mst_wc
               ON ntss_db5_pm_mst_wc.pat_id = ntss_db5_pm.pat_id
           LEFT JOIN mst_wheel_chair ntss_db5_pm_mst_wc1
               ON ntss_db5_pm_mst_wc1.pat_id = ntss_db5_pm.pat_id
               AND ntss_db5_pm_mst_wc1.is_personal = ''1''
       WHERE
           ntss_db5_pm.is_del = ''0''
           AND ntss_db5_pm.facility_cd = @facilityCd
           AND ntss_db5_pm.up_date BETWEEN to_date(@fromDate, ''YYYYMMDDHH24MISS'') AND to_date(@toDate, ''YYYYMMDDHH24MISS'')
           AND ntss_db5_pm.off_water_info IS NOT NULL
           AND ntss_db5_pm.off_water_info <> ''[]''
       UNION ALL
       SELECT
           '''' AS hosppatid                             --患者ID
           , ntss_db5_pm.pat_id AS patid
           , '''' AS names                               --氏名
           , 5 as ctlno                                --管理番号
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時(当日)
           , CASE
               WHEN extract(DOW FROM now()) = 1
                   THEN ntss_db5_pm.tare_info #>> ''{1,name_5}''
               WHEN extract(DOW FROM now()) = 2
                   THEN ntss_db5_pm.tare_info #>> ''{2,name_5}''
               WHEN extract(DOW FROM now()) = 3
                   THEN ntss_db5_pm.tare_info #>> ''{3,name_5}''
               WHEN extract(DOW FROM now()) = 4
                   THEN ntss_db5_pm.tare_info #>> ''{4,name_5}''
               WHEN extract(DOW FROM now()) = 5
                   THEN ntss_db5_pm.tare_info #>> ''{5,name_5}''
               WHEN extract(DOW FROM now()) = 6
                   THEN ntss_db5_pm.tare_info #>> ''{6,name_5}''
               WHEN extract(DOW FROM now()) = 7
                   THEN ntss_db5_pm.tare_info #>> ''{7,name_5}''
               END AS revisename                       --風袋補正名(当日)
           , CASE
               WHEN extract(DOW FROM now()) = 1
                   THEN ntss_db5_pm.tare_info #>> ''{1,weight_5}''
               WHEN extract(DOW FROM now()) = 2
                   THEN ntss_db5_pm.tare_info #>> ''{2,weight_5}''
               WHEN extract(DOW FROM now()) = 3
                   THEN ntss_db5_pm.tare_info #>> ''{3,weight_5}''
               WHEN extract(DOW FROM now()) = 4
                   THEN ntss_db5_pm.tare_info #>> ''{4,weight_5}''
               WHEN extract(DOW FROM now()) = 5
                   THEN ntss_db5_pm.tare_info #>> ''{5,weight_5}''
               WHEN extract(DOW FROM now()) = 6
                   THEN ntss_db5_pm.tare_info #>> ''{6,weight_5}''
               WHEN extract(DOW FROM now()) = 7
                   THEN ntss_db5_pm.tare_info #>> ''{7,weight_5}''
               END AS reviseweight                     --重量(当日)
           , ntss_db5_pm_mst_wc.wheel_chair_cd AS hospwheelchaircd --車椅子コード(当日)
           , ntss_db5_pm_mst_wc.wheel_chair_name AS wheelchairname --車椅子名(当日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS monupdate --更新日時(月曜日)
           , ntss_db5_pm.tare_info #>> ''{1,name_5}'' AS monrevisename --風袋補正名(月曜日)
           , ntss_db5_pm.tare_info #>> ''{1,weight_5}'' AS monreviseweight --重量(月曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS monhospwheelchaircd --車椅子コード(月曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS monwheelchairname --車椅子名(月曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS tueupdate --更新日時(火曜日)
           , ntss_db5_pm.tare_info #>> ''{2,name_5}'' AS tuerevisename --風袋補正名(火曜日)
           , ntss_db5_pm.tare_info #>> ''{2,weight_5}'' AS tuereviseweight --重量(火曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS tuehospwheelchaircd --車椅子コード(火曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS tuewheelchairname --車椅子名(火曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS wedupdate --更新日時(水曜日)
           , ntss_db5_pm.tare_info #>> ''{3,name_5}'' AS wedrevisename --除水補正名(水曜日)
           , ntss_db5_pm.tare_info #>> ''{3,weight_5}'' AS wedreviseweight --重量(水曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS wedhospwheelchaircd --車椅子コード(水曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS wedwheelchairname --車椅子名(水曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS thuupdate --更新日時(木曜日)
           , ntss_db5_pm.tare_info #>> ''{4,name_5}'' AS thurevisename --除水補正名(木曜日)
           , ntss_db5_pm.tare_info #>> ''{4,weight_5}'' AS thureviseweight --重量(木曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS thuhospwheelchaircd --車椅子コード(木曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS thuwheelchairname --車椅子名(木曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS friupdate --更新日時(金曜日)
           , ntss_db5_pm.tare_info #>> ''{5,name_5}'' AS frirevisename --除水補正名(金曜日)
           , ntss_db5_pm.tare_info #>> ''{5,weight_5}'' AS frireviseweight --重量(金曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS frihospwheelchaircd --車椅子コード(金曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS friwheelchairname --車椅子名(金曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS satupdate --更新日時(土曜日)
           , ntss_db5_pm.tare_info #>> ''{6,name_5}'' AS satrevisename --除水補正名(土曜日)
           , ntss_db5_pm.tare_info #>> ''{6,weight_5}'' AS satreviseweight --重量(土曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS sathospwheelchaircd --車椅子コード(土曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS satwheelchairname --車椅子名(土曜日)
           , to_char(ntss_db5_pm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS sunupdate --更新日時(日曜日)
           , ntss_db5_pm.tare_info #>> ''{7,name_5}'' AS sunrevisename --除水補正名(日曜日)
           , ntss_db5_pm.tare_info #>> ''{7,weight_5}'' AS sunreviseweight --重量(日曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_cd AS sunhospwheelchaircd --車椅子コード(日曜日)
           , ntss_db5_pm_mst_wc1.wheel_chair_name AS sunwheelchairname --車椅子名(日曜日)
       FROM
           pat_main ntss_db5_pm
           LEFT JOIN mst_wheel_chair ntss_db5_pm_mst_wc
               ON ntss_db5_pm_mst_wc.pat_id = ntss_db5_pm.pat_id
           LEFT JOIN mst_wheel_chair ntss_db5_pm_mst_wc1
               ON ntss_db5_pm_mst_wc1.pat_id = ntss_db5_pm.pat_id
               AND ntss_db5_pm_mst_wc1.is_personal = ''1''
       WHERE
           ntss_db5_pm.is_del = ''0''
           AND ntss_db5_pm.facility_cd = @facilityCd
           AND ntss_db5_pm.up_date BETWEEN to_date(@fromDate, ''YYYYMMDDHH24MISS'') AND to_date(@toDate, ''YYYYMMDDHH24MISS'')
           AND ntss_db5_pm.off_water_info IS NOT NULL
           AND ntss_db5_pm.off_water_info <> ''[]'''
WHERE sql_cd = '-2080';


-- V_RST_DIALYSIS
UPDATE sys_data_set
SET "sql"=
        'WITH ntss_db5_mst_b AS (
           SELECT
            om.ord_no AS ord_no
            ,ntss_db5_mst_b.in_hospital_cd_1 AS in_hospital_cd_1
            ,ntss_db5_mst_b.bed_name AS bed_name
           FROM ord_main om
           LEFT JOIN mst_bed ntss_db5_mst_b
           ON om.rst_bed_cd = ntss_db5_mst_b.bed_cd
           WHERE ntss_db5_mst_b.facility_cd = @facilityCd
          ),
          ntss_db5_mst_k AS (
           SELECT
            om.ord_no AS ord_no
            ,ntss_db5_mst_k.in_hospital_cd_1 AS in_hospital_cd_1
           FROM ord_main om
           LEFT JOIN mst_kur ntss_db5_mst_k
           ON om.rst_kur_cd = ntss_db5_mst_k.kur_cd
           WHERE ntss_db5_mst_k.facility_cd = @facilityCd
          ),
          rst_vital_info_1 AS (
           SELECT
            om.ord_no AS ord_no
            ,om_rvi_json ->> ''bp_max'' AS bp_max
            ,om_rvi_json ->> ''bp_min'' AS bp_min
            ,om_rvi_json ->> ''bp_ave'' AS bp_ave
            ,om_rvi_json ->> ''pulse'' AS pulse
           FROM ord_main om
           CROSS JOIN LATERAL json_array_elements(om.rst_vital_info ::json) om_rvi_json
           WHERE cast(om_rvi_json ->> ''bp_class'' AS char(20)) = ''1''
            AND om.rst_vital_info IS NOT NULL
            AND om.facility_cd = @facilityCd
          ),
          rst_vital_info_2 AS (
           SELECT
            om.ord_no AS ord_no
            ,om_rvi_json ->> ''bp_max'' AS bp_max
            ,om_rvi_json ->> ''bp_min'' AS bp_min
            ,om_rvi_json ->> ''bp_ave'' AS bp_ave
            ,om_rvi_json ->> ''pulse'' AS pulse
           FROM ord_main om
           CROSS JOIN LATERAL json_array_elements(om.rst_vital_info ::json) om_rvi_json
           WHERE cast(om_rvi_json ->> ''bp_class'' AS char(20)) = ''2''
            AND om.rst_vital_info IS NOT NULL
            AND om.facility_cd = @facilityCd
          )
          SELECT
           '''' AS hosppatid --患者ID
           ,ntss_db5_om.pat_id AS patid
           ,'''' AS names --氏名
           ,ntss_db5_os.treat_date AS dialysisdate --透析日
           ,ntss_db5_om.ord_no AS dialysisno --透析番号
           ,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
           ,ntss_db5_mst_b.in_hospital_cd_1 AS bedno --ベッド番号
           ,ntss_db5_mst_b.bed_name AS bedname --ベッド名
           ,ntss_db5_om.rst_machine_no AS deviceno --装置番号
           ,ntss_db5_om.rst_machine_name AS devicename --装置名
           ,ntss_db5_mst_k.in_hospital_cd_1 AS kurcd --クール
           ,ntss_db5_om.rst_kur_name AS kurname --クール名
           ,to_char(ntss_db5_om.rst_start_date, ''YYYY-MM-DD hh24:mi:ss'') AS startdate --透析開始日時
           ,to_char(ntss_db5_om.rst_end_date, ''YYYY-MM-DD hh24:mi:ss'') AS enddate --透析終了日時
           ,round(date_part(''epoch'',ntss_db5_om.rst_end_date - ntss_db5_om.rst_start_date)::NUMERIC / 60) AS dialysistime --透析時間
           ,ntss_db5_om.rst_cond_info ::json #>> ''{1,value}'' AS plandialysistime --予定透析時間
           ,ntss_db5_om.rst_dialysis_cnt AS dialysisnum --透析回数
           ,'''' AS lastweight --前回体重
           ,ntss_db5_om.rst_weight_info #>> ''{weight_before}'' AS weightbefore --前体重
           ,ntss_db5_om.rst_weight_info #>> ''{weight_before}'' AS weightafter --後体重
           ,ntss_db5_om.rst_weight_info #>> ''{weight_before}'' AS weightafter --後体重
           ,rst_vital_info_1.bp_max AS bpbeforemax --透析前最高血圧
           ,rst_vital_info_1.bp_min AS bpbeforemin --透析前最低血圧
           ,rst_vital_info_1.bp_ave AS bpbeforeave --透析前平均血圧
           ,rst_vital_info_2.bp_max AS bpaftermax --透析後最高血圧
           ,rst_vital_info_2.bp_min AS bpaftermin --透析後最低血圧
           ,rst_vital_info_2.bp_ave AS bpafterave --透析後平均血圧
           ,ntss_db5_om.rst_weight_info #>> ''{water_removal_target}'' AS waterremovaltarget --目標除水量
           ,ntss_db5_om.rst_off_water_info #>> ''{name_1}'' AS revisename1 --除水補正項目１
           ,ntss_db5_om.rst_off_water_info #>> ''{weight_1}'' AS reviseweight1 --除水補正値１
           ,ntss_db5_om.rst_off_water_info #>> ''{name_2}'' AS revisename2 --除水補正項目２
           ,ntss_db5_om.rst_off_water_info #>> ''{weight_2}'' AS reviseweight2 --除水補正値２
           ,ntss_db5_om.rst_off_water_info #>> ''{name_3}'' AS revisename3 --除水補正項目３
           ,ntss_db5_om.rst_off_water_info #>> ''{weight_3}'' AS reviseweight3 --除水補正値３
           ,ntss_db5_om.rst_off_water_info #>> ''{name_4}'' AS revisename4 --除水補正項目４
           ,ntss_db5_om.rst_off_water_info #>> ''{weight_4}'' AS reviseweight4 --除水補正値４
           ,ntss_db5_om.rst_off_water_info #>> ''{name_5}'' AS revisename5 --除水補正項目５
           ,ntss_db5_om.rst_off_water_info #>> ''{weight_5}'' AS reviseweight5 --除水補正値５
           ,rst_vital_info_1.pulse AS pulsebefore --透析前脈拍
           ,rst_vital_info_2.pulse AS pulseafter --透析後脈拍
           ,cast(ntss_db5_om.rst_charge_user_info #>> ''{user_last_name_1}'' AS char(20))
             || cast(ntss_db5_om.rst_charge_user_info #>> ''{user_first_name_1}'' AS char(20)) AS charge1name --担当者１
           ,cast(ntss_db5_om.rst_charge_user_info #>> ''{user_last_name_2}'' AS char(20))
             || cast(ntss_db5_om.rst_charge_user_info #>> ''{user_first_name_2}'' AS char(20)) AS charge2name --担当者２
           ,to_char((ntss_db5_om.rst_charge_user_info #>> ''{date_1}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS chargedate1 --担当日時１
           ,to_char((ntss_db5_om.rst_charge_user_info #>> ''{date_2}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS chargedate2 --担当日時２
           ,cast(ntss_db5_om.rst_puncture_user_info #>> ''{user_last_name_1}'' AS char(20))
             || cast(ntss_db5_om.rst_puncture_user_info #>> ''{user_first_name_1}'' AS char(20)) AS puncture1name --穿刺者１
           ,cast(ntss_db5_om.rst_puncture_user_info #>> ''{user_last_name_2}'' AS char(20))
             || cast(ntss_db5_om.rst_puncture_user_info #>> ''{user_first_name_2}'' AS char(20)) AS puncture2name --穿刺者２
           ,to_char((ntss_db5_om.rst_puncture_user_info #>> ''{date_1}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS puncturedate1 --穿刺日時１
           ,to_char((ntss_db5_om.rst_puncture_user_info #>> ''{date_2}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS puncturedate2 --穿刺日時２
           ,cast(ntss_db5_om.rst_return_user_info #>> ''{user_last_name_1}'' AS char(20))
             || cast(ntss_db5_om.rst_return_user_info #>> ''{user_first_name_1}'' AS char(20)) AS collect1name --回収者１
           ,cast(ntss_db5_om.rst_return_user_info #>> ''{user_last_name_2}'' AS char(20))
             || cast(ntss_db5_om.rst_return_user_info #>> ''{user_first_name_2}'' AS char(20)) AS collect2name --回収者２
           ,to_char((ntss_db5_om.rst_return_user_info #>> ''{date_1}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS collectdate1 --回収日時１
           ,to_char((ntss_db5_om.rst_return_user_info #>> ''{date_2}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS collectdate2 --回収日時２
           ,ntss_db5_om.rst_in_out_class AS inoutflg --入外
           ,ntss_db5_om.rst_kt_v AS ktvmeasure --Kt/v測定値
           ,ntss_db5_om.rst_weight_info #>> ''{urr}'' AS urr --URR
           ,((((ntss_db5_om.rst_weight_info #>> ''{recrcl_rt}'')::json #>> ''{1}'')::json)::json) #>> ''{rate}'' AS relooprate --再循環率
           ,ntss_db5_om.rst_weight_info #>> ''{ihdf_pll}'' AS pullleaveamount --I-HDF引き残し量
           ,ntss_db5_om.rst_weight_info #>> ''{add_total}'' AS addtotl --除水積算値
           ,ntss_db5_om.rst_weight_info #>> ''{sttc_vns_prssr}'' AS staticvenouspressure --静的静脈圧
           ,ntss_db5_om.rst_weight_info #>> ''{iap_rt}'' AS venousaccesspressureratio --IAP ratio
          FROM
           ord_main ntss_db5_om
           LEFT JOIN ord_schedule ntss_db5_os
           ON ntss_db5_os.ord_no = ntss_db5_om.ord_no
           AND ntss_db5_os.facility_cd = @facilityCd
           LEFT JOIN ntss_db5_mst_b
           ON ntss_db5_mst_b.ord_no = ntss_db5_om.ord_no
           LEFT JOIN ntss_db5_mst_k
           ON ntss_db5_mst_k.ord_no = ntss_db5_om.ord_no
           INNER JOIN rst_vital_info_1
           ON rst_vital_info_1.ord_no = ntss_db5_om.ord_no
           INNER JOIN rst_vital_info_2
           ON rst_vital_info_2.ord_no = ntss_db5_om.ord_no
          WHERE
           ntss_db5_om.is_del = ''0''
           AND ntss_db5_om.facility_cd = @facilityCd
           AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
           AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
           AND ntss_db5_om.pat_id IS NOT NULL;'
WHERE sql_cd = '-2090';


-- V_RST_DIALYSIS_COND_CARD
UPDATE sys_data_set
SET "sql"=
        'WITH ntss_db5_om_key AS(
             SELECT
                 ntss_db5_om.ord_no AS ord_no,
                 ntss_db5_om_value_json.KEY AS keys,
                 ntss_db5_om_value_json.value::JSON ->> ''value'' AS value,
                 ntss_db5_om_value_json.value::JSON ->> ''value_name_1'' AS value_name_1,
                 ntss_db5_om_value_json.value::JSON ->> ''unit'' AS unit
             FROM
                 ord_main ntss_db5_om CROSS
             JOIN LATERAL json_object_keys(
                     ntss_db5_om.rst_cond_info::JSON
                 ) rst_ci_keys_json
             INNER JOIN json_each_text(
                     ntss_db5_om.rst_cond_info::JSON
                 ) ntss_db5_om_value_json ON
                 ntss_db5_om_value_json.KEY = rst_ci_keys_json
             WHERE
                 ntss_db5_om.rst_cond_info IS NOT NULL
                 AND ntss_db5_om.facility_cd = @facilityCd
                 AND ntss_db5_om.up_date BETWEEN to_date(
                     @fromDate,
                     ''YYYYMMDDHH24MISS''
                 ) AND to_date(
                     @toDate,
                     ''YYYYMMDDHH24MISS''
                 )
         ),
         ntss_db5_mst_m AS(
             SELECT
                 ntss_db5_mst_m.*
             FROM
                 mst_medicine ntss_db5_mst_m
             WHERE
                 ntss_db5_mst_m.is_del = ''0''
                 AND ntss_db5_mst_m.is_disp = ''1''
                 AND ntss_db5_mst_m.facility_cd = @facilityCd
                 AND ntss_db5_mst_m.up_date BETWEEN to_date(
                     @fromDate,
                     ''YYYYMMDDHH24MISS''
                 ) AND to_date(
                     @toDate,
                     ''YYYYMMDDHH24MISS''
                 )
         ),
         ntss_db5_om_mst_list AS(
             SELECT
                 om.ord_no AS ord_no,
                 ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1,
                 ntss_db5_mst_e.equipment_cd AS equipment_cd_keys
             FROM
                 ord_main om
             INNER JOIN ntss_db5_om_key ON
                 om.ord_no = ntss_db5_om_key.ord_no
             LEFT JOIN mst_equipment ntss_db5_mst_e ON
                 CAST(
                     ntss_db5_om_key.keys AS INTEGER
                 )= ntss_db5_mst_e.equipment_cd
             WHERE
                 ntss_db5_mst_e.facility_cd = @facilityCd
                 AND ntss_db5_mst_e.is_del = ''0''
                 AND ntss_db5_mst_e.up_date BETWEEN to_date(
                     @fromDate,
                     ''YYYYMMDDHH24MISS''
                 ) AND to_date(
                     @toDate,
                     ''YYYYMMDDHH24MISS''
                 )
         UNION ALL SELECT
                 om.ord_no AS ord_no,
                 ntss_db5_mst_m.in_hospital_cd_1 AS in_hospital_cd_1,
                 ntss_db5_mst_m.medicine_cd AS equipment_cd_keys
             FROM
                 ord_main om
             INNER JOIN ntss_db5_om_key ON
                 om.ord_no = ntss_db5_om_key.ord_no
             LEFT JOIN mst_medicine ntss_db5_mst_m ON
                 CAST(
                     ntss_db5_om_key.keys AS INTEGER
                 )= ntss_db5_mst_m.medicine_cd
             WHERE
                 ntss_db5_mst_m.facility_cd = @facilityCd
                 AND om.is_del = ''0''
                 AND om.up_date BETWEEN to_date(
                     @fromDate,
                     ''YYYYMMDDHH24MISS''
                 ) AND to_date(
                     @toDate,
                     ''YYYYMMDDHH24MISS''
                 )
         ) SELECT
             '''' AS hosppatid --患者ID
         ,
             ntss_db5_om.pat_id AS patid,
             ntss_db5_os.treat_date AS dialysisdate --透析日
         ,
             ntss_db5_om.ord_no AS dialysisno --透析番号
         ,
             CASE
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''1'' THEN ''002'' --治療時間
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''2'' THEN ''003'' --VA
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''3'' THEN ''005'' --目標体重
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''4'' THEN ''007'' --除水量制限
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''5'' THEN ''008'' --ダイアライザ
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''6'' THEN ''009'' --吸着カラム
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''7'' THEN ''039'' --1次膜
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''8'' THEN ''040'' --2次膜
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''9'' THEN '' --穿刺針(A針)
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''10'' THEN '''' --穿刺針(V針)
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''11'' THEN '''' --穿刺針(SN)
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''12'' THEN ''029'' --シングルニードル使用
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''13'' THEN '''' --血液回路
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''14'' THEN ''010'' --血流量
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''15'' THEN ''018'' --透析液
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''16'' THEN ''019'' --透析液流量
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''17'' THEN ''020'' --透析液量
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''18'' THEN ''021'' --透析液温度
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''19'' THEN ''022'' --補液
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''20'' THEN ''023'' --補液量
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''21'' THEN ''024'' --補液選択
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''22'' THEN ''030'' --補液使用数
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''23'' THEN ''025'' --補液温度
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''24'' THEN ''038'' --補液速度
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''25'' THEN ''011'' --抗凝固剤
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''26'' THEN ''012'' --抗凝固剤ワンショット量
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''27'' THEN ''013'' --抗凝固剤持続速度
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''28'' THEN ''014'' --抗凝固剤持続総量
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''29'' THEN ''015'' --IP使用選択
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''30'' THEN ''031'' --IPスタート
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''31'' THEN ''016'' --IPワンショット量
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''32'' THEN ''017'' --IP速度
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''33'' THEN ''037'' --IP速度最大値
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''34'' THEN ''032'' --自動ワンショット
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''35'' THEN ''033'' --IP電源自動切り
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''36'' THEN ''034'' --IP電源自動切り時間
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''37'' THEN ''035'' --IP電源OKモニタ切り
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''38'' THEN ''036'' --IP電源OKモニタ切り時間
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''39'' THEN ''004'' --DW
             END AS ctlno --透析条件項目コード
             ,
             to_char(
                 ntss_db5_om.up_date,
                 ''YYYY-MM-DD hh24:mi:ss''
             ) AS updates --更新日時
             ,
             CASE
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''1'' THEN ''透析時間'' --治療時間
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''2'' THEN ''VA'' --VA
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''3'' THEN ''目標体重'' --目標体重
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''4'' THEN ''除水量制限'' --除水量制限
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''5'' THEN ''ダイアライザ'' --ダイアライザ
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''6'' THEN ''吸着カラム'' --吸着カラム
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''7'' THEN ''1次膜'' --1次膜
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''8'' THEN ''2次膜'' --2次膜
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''9'' THEN '''' --穿刺針(A針)
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''10'' THEN '''' --穿刺針(V針)
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''11'' THEN '''' --穿刺針(SN)
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''12'' THEN ''シングルニードル使用'' --シングルニードル使用
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''13'' THEN '''' --血液回路
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''14'' THEN ''血流量'' --血流量
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''15'' THEN ''透析液'' --透析液
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''16'' THEN ''透析液流量'' --透析液流量
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''17'' THEN ''透析液量'' --透析液量
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''18'' THEN ''透析液温度'' --透析液温度
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''19'' THEN ''補液'' --補液
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''20'' THEN ''補液量'' --補液量
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''21'' THEN ''補液選択'' --補液選択
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''22'' THEN ''補液使用数'' --補液使用数
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''23'' THEN ''補液温度'' --補液温度
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''24'' THEN ''補液速度'' --補液速度
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''25'' THEN ''抗凝固剤'' --抗凝固剤
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''26'' THEN ''抗凝固剤ワンショット量'' --抗凝固剤ワンショット量
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''27'' THEN ''抗凝固剤持続速度'' --抗凝固剤持続速度
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''28'' THEN ''抗凝固剤持続総量'' --抗凝固剤持続総量
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''29'' THEN ''IP使用選択'' --IP使用選択
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''30'' THEN ''IPスタート'' --IPスタート
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''31'' THEN ''IPワンショット量'' --IPワンショット量
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''32'' THEN ''IP速度'' --IP速度
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''33'' THEN ''IP速度最大値'' --IP速度最大値
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''34'' THEN ''自動ワンショット'' --自動ワンショット
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''35'' THEN ''IP電源自動切り'' --IP電源自動切り
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''36'' THEN ''IP電源自動切り時間'' --IP電源自動切り時間
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''37'' THEN ''IP電源OKモニタ切り'' --IP電源OKモニタ切り
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''38'' THEN ''IP電源OKモニタ切り時間'' --IP電源OKモニタ切り時間
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''39'' THEN ''DW'' --DW
             END AS dialysisitemname --透析条件項目名
         ,
             ntss_db5_om_key.value AS value --設定値
         ,
             ntss_db5_om_key.value_name_1 AS valuename --設定値
         ,
             ntss_db5_om_key.unit AS unit --単位
         ,
             SUBSTR(ntss_db5_om_mst_list.in_hospital_cd_1, 0, 20) AS valuecd1 --院内コード1
         FROM
             ord_main ntss_db5_om
         LEFT JOIN ord_schedule ntss_db5_os ON
             ntss_db5_om.ord_no = ntss_db5_os.ord_no
             AND ntss_db5_os.facility_cd = @facilityCd
         INNER JOIN ntss_db5_om_key ON
             ntss_db5_om.ord_no = ntss_db5_om_key.ord_no
         LEFT JOIN ntss_db5_om_mst_list ON
             ntss_db5_om_mst_list.ord_no = ntss_db5_om_key.ord_no
             AND ntss_db5_om_mst_list.equipment_cd_keys = CAST(
                 ntss_db5_om_key.keys AS INTEGER
             )
         WHERE
             ntss_db5_om.is_del = ''0''
             AND ntss_db5_om.facility_cd = @facilityCd
             AND ntss_db5_om.up_date BETWEEN to_date(
                 @fromDate,
                 ''YYYYMMDDHH24MISS''
             ) AND to_date(
                 @toDate,
                 ''YYYYMMDDHH24MISS''
             )
             AND ntss_db5_om.pat_id IS NOT NULL;'
WHERE sql_cd = '-2110';


-- V_RST_DIALYSIS_EQUIP
UPDATE sys_data_set
SET "sql"=
        'SELECT
            '''' AS hosppatid                             --患者ID
            , ntss_db5_om.pat_id AS patid
            , ntss_db5_os.treat_date AS dialysisdate    --透析日
            , ntss_db5_om.ord_no AS dialysisno          --透析番号
            , row_number() over (ORDER BY ntss_db5_om.treat_date DESC) AS ctlno --項目番号
            , to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
            , ntss_db5_mst_e.in_hospital_cd_1 AS equipcd --医療材料コード(院内コード1)
            , ntss_db5_mst_e.in_hospital_cd_2 AS equipcd2 --医療材料コード(院内コード2)
            , ntss_db5_mst_e.equipment_name AS equipname --医療材料名
            , ntss_db5_mst_c.class_name AS equipclassname --医療材料分類名
            , ntss_db5_om_rqi_json ->> ''needle_type'' AS punctureclass --穿刺針区分
            , ntss_db5_om_rqi_json ->> ''amount'' AS amount --数量
            , ntss_db5_mst_e.unit AS unit   --単位
            , ntss_db5_om_rqi_json ->> ''comment'' AS comments --コメント
        FROM
            ord_main ntss_db5_om
            CROSS JOIN LATERAL json_array_elements(ntss_db5_om.rst_equip_info ::json) ntss_db5_om_rqi_json
            LEFT JOIN ord_schedule ntss_db5_os
                ON ntss_db5_om.ord_no = ntss_db5_os.ord_no
            LEFT JOIN mst_equipment ntss_db5_mst_e
                ON cast(ntss_db5_mst_e.equipment_cd as char (10)) = cast(ntss_db5_om_rqi_json ->> ''cd'' as char (10))
            LEFT JOIN mst_equipment_class ntss_db5_mst_c
               ON ntss_db5_mst_c.class_cd = ntss_db5_mst_e.class_cd
        WHERE
            ntss_db5_om.is_del = ''0''
            AND ntss_db5_om.facility_cd = @facilityCd
            AND ntss_db5_om.up_date BETWEEN to_date(@fromDate, ''YYYYMMDDHH24MISS'') AND to_date(@toDate, ''YYYYMMDDHH24MISS'')
            AND ntss_db5_om.pat_id IS NOT NULL;'
WHERE sql_cd = '-2120';


-- V_RST_DIALYSIS_MEDI
UPDATE sys_data_set
SET "sql"=
        'with ntss_db5_om_temp AS (
           SELECT
            ntss_db5_om.ord_no
            , ntss_db5_om_rmi_json ->> ''cd'' ::char (10) AS cd
            , ntss_db5_om_rmi_json ->> ''procedure_cd'' ::char (10) AS procedure_cd
            , ntss_db5_om_rmi_json ->> ''amount'' AS amount --数量
            , ntss_db5_om_rmi_json ->> ''effect_flg'' AS effectflg --実施フラグ
            , CASE WHEN POSITION(''T'' IN cast(ntss_db5_om_rmi_json ->> ''effect_date'' AS char (20))) != 0
                   THEN to_char(to_timestamp(ntss_db5_om_rmi_json ->> ''effect_date'', ''YYYY-MM-DDThh24:mi:ss''
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
            AND ntss_db5_om.up_date BETWEEN to_date(@fromDate, ''YYYYMMDDHH24MISS'') AND to_date(@toDate, ''YYYYMMDDHH24MISS'')
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
        , ntss_db5_mst_m.in_hospital_cd_1 AS medicinecd --薬剤コード(院内コード1)
        , ntss_db5_mst_m.in_hospital_cd_2 AS medicinecd2 --薬剤コード(院内コード2)
        , ntss_db5_mst_m.medicine_name AS medicinename --薬剤名
        , ntss_db5_mst_c.class_name AS medicineclassname --薬剤分類名
        , ntss_db5_om_temp.amount AS amount         --数量
        , ntss_db5_mst_m.unit AS unit               --単位
        , ntss_db5_om_temp.effectflg AS effectflg   --実施フラグ
        , ntss_db5_om_temp.effectdate               --実施日時
        , ntss_db5_om_temp.timingname AS timingname --投与時間帯名
        , ntss_db5_mst_p.in_hospital_cd_a1 AS procedurecd --手技コード(院内コード1)
        , ntss_db5_mst_p.in_hospital_cd_a2 AS procedurecd2 --手技コード(院内コード2)
        , ntss_db5_mst_p.pricedure_name AS procedurename --手技名
        , '''' AS indicatorcd                         --実施者コード
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
            ON ntss_db5_mst_p.procedure_cd ::char (10) = ntss_db5_om_temp.procedure_cd'
WHERE sql_cd = '-2130';


-- V_RST_DIALYSIS_MEDI_CARD
UPDATE sys_data_set
SET "sql"=
        'WITH ord AS (
           SELECT
            ord_no
            , facility_cd
            , pat_id
            , up_date
            , is_del
            , treat_date
            , medi ->> ''medicine_type'' as medicinetype
            , medi ->> ''cd'' as cd
            , medi ->> ''name'' as name
            , medi ->> ''class_name'' as classname
            , medi ->> ''amount'' as amount
            , medi ->> ''unit'' as unit
            , medi ->> ''effect_flg'' as effectflg
            , medi ->> ''effect_date'' as effectdate
            , medi ->> ''timing_name'' as timingname
            , medi ->> ''procedure_cd'' as procedurecd
            , medi ->> ''procedure_name'' as procedurename
            , medi ->> ''effect_user_id'' as effectuserid
            , medi ->> ''effect_user_last_name'' as effectuserlastname
            , medi ->> ''effect_user_first_name'' as effectuserfirstname
            , medi ->> ''comment'' as comment
        FROM
            ord_main
            CROSS JOIN LATERAL jsonb_array_elements(rst_medi_info) medi
        WHERE
            is_del = ''0''
            AND rst_dialysis_state <> ''0''
            AND facility_cd = @facilityCd
            AND up_date BETWEEN to_date(@fromDate, ''YYYYMMDDHH24MISS'') AND to_date(@toDate, ''YYYYMMDDHH24MISS'')
            AND pat_id IS NOT NULL
    )
    , ntss_db5_mst_m AS (
        SELECT
            ord.ord_no
            , mstMedic.in_hospital_cd_1 as in_hospital_cd_1
        FROM
            ord
            INNER JOIN mst_medicine mstMedic
                ON ord.cd = mstMedic.medicine_cd ::text
                AND mstMedic.is_del = ''0''
                AND mstMedic.is_disp = ''1''
        WHERE
            ord.medicinetype = ''1''
            AND ord.facility_cd = @facilityCd
        UNION ALL
        SELECT
            ord.ord_no
            , mix.in_hospital_cd_1 as in_hospital_cd_1
        FROM
            ord
            INNER JOIN mst_medicine_mix mix
                ON mix.medicine_mix_cd ::text = ord.cd
        WHERE
            ord.medicinetype = ''2''
            AND ord.facility_cd = @facilityCd
            AND mix.facility_cd = @facilityCd
            AND mix.is_del = ''0''
            AND mix.is_disp = ''1''
    )
    SELECT
        '''' AS hosppatid                             --患者ID
        , ntss_db5_om.pat_id AS patid
        , ntss_db5_os.treat_date AS dialysisdate    --透析日
        , ntss_db5_om.ord_no AS dialysisno          --透析番号
        , row_number() over (ORDER BY ntss_db5_om.treat_date DESC) AS ctlno --項目番号
        , to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
        , ntss_db5_om.cd AS medicinecd              --薬剤コード
        , ntss_db5_mst_m.in_hospital_cd_1 AS medicinecd2 --薬剤コード(院内コード1)
        , ntss_db5_om.name AS medicinename          --薬剤名
        , '''' AS medgeneralname                      --一般名
        , ntss_db5_om.classname AS medicineclassname --薬剤分類名
        , ntss_db5_om.amount AS amount              --数量
        , ntss_db5_om.unit AS unit                  --単位
        , ntss_db5_om.effectflg AS effectflg        --実施フラグ
        , CASE
            WHEN POSITION(
                ''T'' IN cast(ntss_db5_om.effectdate AS char (20))
            ) != 0
                THEN to_char(
                to_timestamp(ntss_db5_om.effectdate, ''YYYY-MM-DDThh24:mi:ss'')
                , ''YYYY-MM-DD hh24:mi:ss''
            )
            ELSE ''''
            END AS effectdate                       --実施日時
        , ntss_db5_om.timingname AS timingname      --投与時間帯名
        , ntss_db5_mst_p.in_hospital_cd_a1 AS procedurecd --手技コード(院内コード1)
        , ntss_db5_mst_p.in_hospital_cd_a2 AS procedurecd2 --手技コード(院内コード2)
        , ntss_db5_om.procedurename AS procedurename --手技名
        , ntss_db5_om.effectuserid AS userid
        , '''' AS indicatorcd                         --実施者コード
        , cast(ntss_db5_om.effectuserlastname AS char (20)) || cast(ntss_db5_om.effectuserfirstname AS char (20))
         AS staffname                               --実施者名
        , ntss_db5_om.comment AS comments           --コメント
    FROM
        ord ntss_db5_om
        LEFT JOIN ord_schedule ntss_db5_os
            ON ntss_db5_os.ord_no = ntss_db5_om.ord_no
        LEFT JOIN ntss_db5_mst_m
            ON ntss_db5_mst_m.ord_no = ntss_db5_om.ord_no
        LEFT JOIN mst_procedure ntss_db5_mst_p
            ON cast(ntss_db5_mst_p.procedure_cd as char (10)) = cast(ntss_db5_om.procedurecd as char (10))'
WHERE sql_cd = '-2140';


-- V_RST_RECEIPT_MEMO_DIALYSIS
UPDATE sys_data_set
SET "sql"=
        'SELECT
            ntss_db6_ppm.hosp_pat_id AS hosppatid --患者ID
            ,ntss_db6_ppm.pat_id AS patid
            ,'''' AS dialysisdate --透析日
            ,'''' AS dialysisno --透析番号
            ,'''' AS ctlno --項目番号
            ,'''' AS updates --更新日時
            ,ntss_db5_om_ddci_json1 ->> ''dial_diff_cd'' AS dialdiffcd
            ,''0'' AS division --レセプトメモ区分
            ,'''' AS codes --コード
            ,'''' AS codeupdate --コード更新日時
            ,''0'' AS addflg --加算有無
            ,'''' AS itemname --項目名称
            ,CASE WHEN ntss_db5_om_ddci_json1 ->> ''is_main'' = ''1''
                  THEN ntss_db5_om_ddci_json1 ->> ''dial_diff_cd''
                 ELSE null
              END AS dialdiffcd2
            ,'''' AS maindialdiff --主たる透析困難
            ,'''' AS inhospitalcd --院内コード
            ,'''' AS inhospitalcd2 --院内コード２
        FROM
            pat_personal_main ntss_db6_ppm
            CROSS JOIN LATERAL json_array_elements(ntss_db6_ppm.dial_diff_com_info ::json) ntss_db5_om_ddci_json1
          WHERE ntss_db6_ppm.is_del = ''0''
            AND ntss_db5_om_ddci_json1 ->> ''dial_diff_cd'' = ''1''
            AND ntss_db6_ppm.dial_diff_com_info IS NOT NULL
            AND ntss_db6_ppm.dial_diff_com_info <> ''[]''
            AND ntss_db6_ppm.facility_cd = @facilityCd
            AND ntss_db6_ppm.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
            AND to_date(  @toDate, ''YYYYMMDDHH24MISS'' )
            AND ntss_db6_ppm.pat_id IS NOT NULL;'
WHERE sql_cd = '-2160';


-- V_RST_RECEIPT_MEMO_ADDITION
UPDATE sys_data_set
SET "sql"=
        'SELECT
            '''' AS hosppatid                             --患者ID
            , ntss_db5_om.pat_id AS patid
            , ntss_db5_os.treat_date AS dialysisdate    --透析日
            , ntss_db5_om.ord_no AS dialysisno          --透析番号
            , row_number() over (ORDER BY ntss_db5_om.treat_date DESC) AS ctlno --項目番号
            , to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
            , ''1'' AS division                           --レセプトメモ区分
            , ntss_db5_mst_a.in_hospital_cd_1 AS codes  --コード
            , to_char(ntss_db5_mst_a.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS codeupdate --コード更新日時
            , ''1'' AS addflg                             --加算有無
            , ntss_db5_mst_a.addition_name AS itemname  --項目名称
            , '''' AS maindialdiff                        --主たる透析困難
            , ntss_db5_mst_a.in_hospital_cd_1 AS inhospitalcd --院内コード
            , ntss_db5_mst_a.in_hospital_cd_2 AS inhospitalcd2 --院内コード２
        FROM
            ord_main ntss_db5_om
            CROSS JOIN LATERAL json_array_elements(ntss_db5_om.addition_info ::json) ntss_db5_om_di_json1
            INNER JOIN mst_addition ntss_db5_mst_a
                ON cast(ntss_db5_mst_a.addition_cd AS char (20)) = cast(ntss_db5_om_di_json1 ->> ''cd'' AS char (20))
            LEFT JOIN ord_schedule ntss_db5_os
                ON ntss_db5_os.ord_no = ntss_db5_om.ord_no
        WHERE
            ntss_db5_om.is_del = ''0''
            AND ntss_db5_om.facility_cd = @facilityCd
            AND ntss_db5_om.addition_info IS NOT NULL
            AND ntss_db5_om.addition_info <> ''[]''
            AND ntss_db5_om.up_date BETWEEN to_date(@fromDate, ''YYYYMMDDHH24MISS'') AND to_date(@toDate, ''YYYYMMDDHH24MISS'')
            AND ntss_db5_om.pat_id IS NOT NULL;'
WHERE sql_cd = '-2164';


-- V_SCH_DIALYSIS_PLAN
UPDATE sys_data_set
SET "sql"=
        'with ntss_db5_om_1 as (
            SELECT
                array_agg(ntss_db5_om_1.ord_no) AS arr_ord_no
                , ntss_db5_om_1.pat_id
                , ntss_db5_om_1.treat_date AS treat_date
                , COUNT(ntss_db5_om_1.treat_date) AS treat_date_count
            FROM
                ord_main ntss_db5_om_1
            WHERE
                ntss_db5_om_1.is_del = ''0''
                AND ntss_db5_om_1.facility_cd = @facilityCd
                AND ntss_db5_om_1.up_date BETWEEN to_date(@fromDate, ''YYYYMMDDHH24MISS'') AND to_date(@toDate, ''YYYYMMDDHH24MISS'')
            GROUP BY
                ntss_db5_om_1.pat_id
                , ntss_db5_om_1.treat_date
        )
        SELECT
            '''' AS hosppatid                             --患者ID
            , ntss_db5_om.pat_id AS patid
            , ntss_db5_os.treat_date AS dialysisdate    --透析日
            , ntss_db5_om.ord_no AS bedno               --ベッド番号
            , ntss_db5_om_mst_b.bed_name AS bedname     --ベッド名
            , ntss_db5_om_mst_k.in_hospital_cd_1 AS kurcd --クールコード
            , ntss_db5_om.rst_kur_name AS kurname       --クール名
            , CASE
                WHEN ntss_db5_om_1.treat_date_count > 1
                    THEN 1
                ELSE 0
                END AS plural                           --同日複数回
            , to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
            , ntss_db5_om.ord_no AS resultdialysisno    --実績透析番号
            , CASE
                WHEN ntss_db5_om.treat_type = 0
                    THEN 1
                ELSE 0
                END AS opeindplan                       --予定作成区分
            , ntss_db5_os.is_dummy AS dummyflg          --ダミーフラグ
            , to_char(ntss_db5_om.rst_start_date, ''hh24:mi'') AS starttime --透析開始時刻
        FROM
            ord_main ntss_db5_om
            INNER JOIN ntss_db5_om_1
                ON ntss_db5_om.ord_no = ANY (ntss_db5_om_1.arr_ord_no)
            LEFT JOIN ord_schedule ntss_db5_os
                ON ntss_db5_os.pat_id = ntss_db5_om.pat_id
                AND ntss_db5_os.ord_no = ntss_db5_om.ord_no
            LEFT JOIN mst_bed ntss_db5_om_mst_b
                ON ntss_db5_om_mst_b.bed_cd = ntss_db5_os.bed_cd
            LEFT JOIN mst_kur ntss_db5_om_mst_k
                ON ntss_db5_om_mst_k.kur_cd = ntss_db5_om.rst_kur_cd
        WHERE
            ntss_db5_om.is_del = ''0''
            AND ntss_db5_om.facility_cd = @facilityCd
            AND ntss_db5_om.up_date BETWEEN to_date(@fromDate, ''YYYYMMDDHH24MISS'') AND to_date(@toDate, ''YYYYMMDDHH24MISS'');'
WHERE sql_cd = '-2170';


-- V_SCH_DIALYSIS_PLAN_CARD
UPDATE sys_data_set
SET "sql"=
        'with ntss_db5_om_1 as (
            SELECT
                main.ord_no
                , main.ind_kur_cd
                , main.up_date
                , main.treat_type
                , main.ind_treat_start_time
                , subMain.pat_id
                , subMain.treat_date
                , subMain.treat_date_count
            FROM
                ord_main main
                INNER JOIN (
                    SELECT
                        array_agg(ntss_db5_om_1.ord_no) AS arr_ord_no
                        , ntss_db5_om_1.pat_id
                        , ntss_db5_om_1.treat_date AS treat_date
                        , COUNT(ntss_db5_om_1.treat_date) AS treat_date_count
                    FROM
                        ord_main ntss_db5_om_1
                    WHERE
                        ntss_db5_om_1.facility_cd = @facilityCd
                        AND ntss_db5_om_1.up_date BETWEEN to_date(@fromDate, ''YYYYMMDDHH24MISS'') AND to_date(@toDate, ''YYYYMMDDHH24MISS'')
                        AND ntss_db5_om_1.is_del = ''0''
                        AND ntss_db5_om_1.pat_id IS NOT NULL
                    GROUP BY
                        ntss_db5_om_1.pat_id
                        , ntss_db5_om_1.treat_date
                ) AS subMain
                    ON main.ord_no = ANY (subMain.arr_ord_no)
        )
        SELECT
            '''' AS hosppatid
            , ntss_db5_om_1.pat_id AS patid             --患者ID
            , ntss_db5_os.treat_date AS dialysisdate    --透析日
            , ntss_db5_os.ord_no AS bedno               --ベッド番号
            , ntss_db5_om_mst_b.bed_name AS bedname     --ベッド名
            , ntss_db5_om_mst_k.kur_cd AS kurcd         --クールコード
            , ntss_db5_om_mst_k.kur_name AS kurname     --クール名
            , CASE
                WHEN ntss_db5_om_1.treat_date_count > 1
                    THEN 1
                ELSE 0
                END AS plural                           --同日複数回
            , to_char(ntss_db5_om_1.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
            , ntss_db5_om_1.ord_no AS resultdialysisno  --実績透析番号
            , CASE
                WHEN ntss_db5_om_1.treat_type = 0
                    THEN 1
                ELSE 0
                END AS opeindplan                       --予定作成区分
            , ntss_db5_os.is_dummy AS dummyflg          --ダミーフラグ
            , ntss_db5_om_1.ind_treat_start_time
            , ntss_db5_om_mst_k.kur_start_time
            , CASE
                WHEN ntss_db5_om_1.ind_treat_start_time IS NOT NULL
                    THEN to_char(
                    ntss_db5_om_1.ind_treat_start_time ::time
                    , ''hh24:mi''
                )
                WHEN ntss_db5_om_mst_k.kur_start_time IS NOT NULL
                    THEN to_char(
                    ntss_db5_om_mst_k.kur_start_time ::time
                    , ''hh24:mi''
                )
                ElSE ''未登録''
                END AS starttime                        --透析開始時刻
        FROM
            ntss_db5_om_1
            LEFT JOIN ord_schedule ntss_db5_os
                ON ntss_db5_os.pat_id = ntss_db5_om_1.pat_id
                AND ntss_db5_os.ord_no = ntss_db5_om_1.ord_no
            LEFT JOIN mst_bed ntss_db5_om_mst_b
                ON ntss_db5_om_mst_b.bed_cd = ntss_db5_os.bed_cd
            LEFT JOIN mst_kur ntss_db5_om_mst_k
                ON ntss_db5_om_mst_k.kur_cd = ntss_db5_om_1.ind_kur_cd;'
WHERE sql_cd = '-2180';


-- V_IND_DIALYSIS_ADD
UPDATE sys_data_set
SET "sql"=
        'SELECT
            '''' AS hosppatid                             --患者ID
            , ntss_db5_om.pat_id AS patid
            , ntss_db5_om.treat_date AS dialysisdate    --透析日
            , CASE
                WHEN ntss_db5_om_1.treat_date_count > 1
                    THEN 1
                ELSE 0
                END AS plural                           --同日複数回
            , ROW_NUMBER() OVER (ORDER BY ntss_db5_om.treat_date DESC) AS ctlno --項目番号
            , to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS UPDATE --更新日時
            , ntss_db5_om_iic_json ->> ''content'' AS addition --指示簿指示
            , '''' AS indicatorcd                         --指示者
            , ntss_db5_om_iic_json ->> ''ind_user_id'' AS userid
            , CASE
                WHEN ntss_db5_om.treat_type = 0
                    THEN ''1''
                ELSE ''0''
                END AS opeindplan                       --予定作成区分
        FROM
            (
                SELECT
                    ntss_db5_om_1.ord_no AS ord_no
                    , ntss_db5_om_1.pat_id
                    , ntss_db5_om_1.treat_date AS treat_date
                    , COUNT(ntss_db5_om_1.treat_date) AS treat_date_count
                FROM
                    ord_main ntss_db5_om_1
                WHERE
                    1 = 1
                    AND ntss_db5_om_1.facility_cd = @facilityCd
                    AND ntss_db5_om_1.up_date BETWEEN to_date(@fromDate, ''YYYYMMDDHH24MISS'') AND to_date(@toDate, ''YYYYMMDDHH24MISS'')
                GROUP BY
                    ntss_db5_om_1.ord_no
                    , ntss_db5_om_1.pat_id
                    , ntss_db5_om_1.treat_date
            ) AS ntss_db5_om_1
            LEFT JOIN ord_main ntss_db5_om
                ON ntss_db5_om_1.ord_no = ntss_db5_om.ord_no
            CROSS JOIN LATERAL json_array_elements(ntss_db5_om.ind_ind_comment_info ::json) ntss_db5_om_iic_json
        WHERE
            ntss_db5_om.is_del = ''0''
            AND ntss_db5_om.pat_id IS NOT NULL
            AND ntss_db5_om_1.treat_date IS NOT NULL;'
WHERE sql_cd = '-2220';


-- V_PAT_RECIPE
UPDATE sys_data_set
SET "sql"=
        'SELECT
            '''' AS hosppatid                             --患者ID
            , ntss_db5_op.pat_id AS patid
            , ntss_db5_op.ord_prescription_no AS prescriptno --処方番号
            , to_char(ntss_db5_op.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
            , ntss_db5_op.issue_date AS executedate     --交付日
            , CASE
                WHEN ntss_db5_op_pd_json ->> ''type'' = ''1''
                    THEN ntss_db5_op_pd_json ->> ''Rp''
                END AS ctlno                            --項目番号
            , CASE
                WHEN ntss_db5_op_pd_json ->> ''type'' = ''1''
                    THEN ntss_db5_op_pd_json ->> ''F1''
                END AS medicinename                     --薬剤名
            , CASE
                WHEN ntss_db5_op_pd_json ->> ''type'' = ''1''
                AND ntss_db5_op_pd_json ->> ''medicine_type'' = ''1''
                    THEN ntss_db5_op_pd_json ->> ''medicine_cd1''
                END AS medicinecd                       --薬剤コード(院内コード1)
            , CASE
                WHEN ntss_db5_op_pd_json ->> ''type'' = ''1''
                AND ntss_db5_op_pd_json ->> ''medicine_type'' = ''1''
                    THEN ntss_db5_op_pd_json ->> ''medicine_cd2''
                END AS medicinecd2                      --薬剤コード(院内コード2)
            , CASE
                WHEN ntss_db5_op_pd_json ->> ''type'' = ''1''
                    THEN ntss_db5_op_pd_json ->> ''F5''
                END AS quantity                         --分量
            , CASE
                WHEN ntss_db5_op_pd_json ->> ''type'' = ''1''
                    THEN ntss_db5_op_pd_json ->> ''F6''
                END AS unit                             --単位
            , CASE
                WHEN ntss_db5_op_pd_json ->> ''type'' IN (''2'', ''3'', ''4'', ''5'')
                    THEN ntss_db5_op_pd_json ->> ''F5''
                END AS dosage                           --用量
            , CASE
                WHEN ntss_db5_op_pd_json ->> ''type'' IN (''2'', ''3'', ''4'', ''5'')
                 THEN ntss_db5_op_mst_tm.take_medicine_cd
                END AS takemedicinecd                   --用法コード
            , CASE
                WHEN ntss_db5_op_pd_json ->> ''type'' IN (''2'', ''3'', ''4'', ''5'')
                    THEN ntss_db5_op_pd_json ->> ''F2''
                END AS takemedicinename                 --用法名
            , CASE
                WHEN ntss_db5_op_pd_json ->> ''type'' = ''2''
                    THEN ntss_db5_op_pd_json ->> ''F5''
                END AS daycount                         --調剤日数
            , '''' AS prescriptercd                       --処方者コード
            , '''' AS prescriptername                     --処方者名
            , '''' AS note                                --備考
            , '''' AS userid
        FROM
            ord_prescription ntss_db5_op
            CROSS JOIN LATERAL json_array_elements(ntss_db5_op.prescription_detail ::json) ntss_db5_op_pd_json
            LEFT JOIN mst_take_medicine ntss_db5_op_mst_tm
                ON cast(
                    ntss_db5_op_mst_tm.take_medicine_cd AS varchar (10)
                ) = cast(ntss_db5_op_pd_json ->> ''F2'' AS varchar (10)) -- mst_take_medicineのLEFT JOINの結合条件が間違い
            LEFT JOIN mst_medicine ntss_db5_op_mst_m
                ON cast(ntss_db5_op_mst_m.medicine_cd AS varchar (10)) = ntss_db5_op_pd_json ->> ''medicine_cd''
        WHERE
            ntss_db5_op.is_del = ''0''
            AND ntss_db5_op.facility_cd = @facilityCd
            AND ntss_db5_op_pd_json ->> ''type'' IN (''1'', ''2'', ''3'', ''4'', ''5'')
            AND ntss_db5_op.up_date BETWEEN to_date(@fromDate, ''YYYYMMDDHH24MISS'') AND to_date(@toDate, ''YYYYMMDDHH24MISS'')'
WHERE sql_cd = '-2230';


-- V_PAT_RECIPE
UPDATE sys_data_set
SET "memo" = '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}'
WHERE sql_cd = '-2230';


-- V_PAT_RECIPE
UPDATE sys_data_set
SET "sql"=
        'SELECT
            ntss_db6_mst_opp.insu_dr_id AS userid
            , ntss_db6_mst_opp.ord_prescription_no AS prescriptno
            , ntss_db6_mst_opp.pat_id AS patid
            , personal_info_decrypt(ntss_db6_mst_opp.insu_dr_name) AS prescriptername
            , ntss_db6_mst_opp.remarks AS note
            , '''' AS prescriptercd
        FROM
            ord_personal_prescription ntss_db6_mst_opp
        WHERE
            ntss_db6_mst_opp.is_del = ''0''
            AND ntss_db6_mst_opp.facility_cd = @facilityCd
            AND ntss_db6_mst_opp.up_date BETWEEN to_date(@fromDate, ''YYYYMMDDHH24MISS'') AND to_date(@toDate, ''YYYYMMDDHH24MISS'')'
WHERE sql_cd = '-2231';


-- V_DIALYSIS_VITAL
UPDATE sys_data_set
SET "sql"=
        'SELECT
            '''' AS hosppatid --患者ID
            ,
            ntss_db5_om.pat_id AS patid,
            to_char( ntss_db5_om.rst_start_date, ''YYYY-MM-DD hh24:mi:ss'' ) AS startdate --開始日時
            ,
            to_char( ntss_db5_mm_1.occur_date, ''YYYY-MM-DD hh24:mi:ss'' ) AS occurdate --発生日時
            ,
        CASE

                WHEN ntss_db5_mm_1.data_type IN ( ''2'', ''4'', ''5'', ''6'' ) THEN
                ntss_db5_mm_1.monitor_data ->> ''90''
            END AS bpmax --最高血圧
            ,
        CASE

                WHEN ntss_db5_mm_1.data_type IN ( ''2'', ''4'', ''5'', ''6'' ) THEN
                ntss_db5_mm_1.monitor_data ->> ''91''
            END AS bpmin --最低血圧
            ,
        CASE

                WHEN ntss_db5_mm_1.data_type IN ( ''2'', ''4'', ''5'', ''6'' ) THEN
                ntss_db5_mm_1.monitor_data ->> ''92''
            END AS bpave --平均血圧
            ,
        CASE

                WHEN ntss_db5_mm_1.data_type IN ( ''2'', ''4'', ''5'', ''6'' ) THEN
                ntss_db5_mm_1.monitor_data ->> ''93''
            END AS pulse --脈拍
            ,
        CASE

                WHEN ntss_db5_mm_1.data_type IN ( ''2'', ''4'', ''5'', ''6'' ) THEN
                ntss_db5_mm_1.monitor_data ->> ''93''
            END AS temperature --体温
            ,
        CASE

                WHEN ntss_db5_mm_1.data_type IN ( ''2'', ''4'', ''5'', ''6'' ) THEN
                ntss_db5_mm_1.monitor_data ->> ''-1''
            END AS bloodsugarlevel --血糖値
            ,
            to_char( ntss_db5_mm_1.up_date, ''YYYY-MM-DD hh24:mi:ss'' ) AS UPDATE --更新日時
            ,
            ntss_db5_mm_1.ord_no AS diadysisno --透析番号
            ,
            ntss_db5_mm_1.data_type AS bpclass --血圧区分

        FROM
            (
            SELECT
                ntss_db5_mm_1.facility_cd,
                ntss_db5_mm_1.ord_no AS ord_no,
                ntss_db5_mm_1.data_type AS data_type,
                ntss_db5_mm_1.monitor_data AS monitor_data,
                MIN ( ntss_db5_mm_1.occur_date ) AS occur_date,
                MIN ( ntss_db5_mm_1.up_date ) AS up_date
            FROM
                mni_monitor ntss_db5_mm_1
            WHERE
                ntss_db5_mm_1.ord_no IS NOT NULL
                AND ntss_db5_mm_1.data_type IN ( ''2'', ''4'', ''5'', ''6'', ''-1'' )
                AND ntss_db5_mm_1.facility_cd = ''999998''
                AND ntss_db5_mm_1.up_date BETWEEN to_date( ''20000101000000'', ''YYYYMMDDHH24MISS'' )
                AND to_date( ''20221220000000'', ''YYYYMMDDHH24MISS'' )
            GROUP BY
                ntss_db5_mm_1.facility_cd,
                ntss_db5_mm_1.ord_no,
                ntss_db5_mm_1.data_type,
                ntss_db5_mm_1.monitor_data
            ) AS ntss_db5_mm_1
            LEFT JOIN ord_main ntss_db5_om ON ntss_db5_mm_1.ord_no = ntss_db5_om.ord_no
        WHERE
            ntss_db5_om.is_del = ''0''
            AND ntss_db5_om.pat_id IS NOT NULL;	'
WHERE sql_cd = '-2240';


-- V_PAT_EXAMIN_HST
UPDATE sys_data_set
SET "sql"=
        'SELECT
            '''' AS hosppatid --患者ID
            ,ntss_db5_pxm.pat_id AS patid
            ,to_char(ntss_db5_pxm.result_exam_date, ''YYYY-MM-DD hh24:mi:ss'') AS examdate --検査日時
            ,ntss_db5_pxm.reg_order_class AS orderclass --検査区分
            ,to_char(ntss_db5_pxm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS itemupdate --検査結果更新日時
            ,ntss_db5_mst_e.in_hospital_cd1 AS examitemcode1 --検査項目コード(院内コード1)
            ,ntss_db5_mst_e.in_hospital_cd2 AS examitemcode2 --検査項目コード(院内コード2)
            ,ntss_db5_mst_e.in_hospital_cd3 AS examitemcode3 --検査項目コード(院内コード3)
            ,ntss_db5_mst_e.exam_item_name AS examitemname --検査項目名
            ,ntss_db5_om_eri_json ->> ''result'' AS examrst --検査結果値
            ,ntss_db5_om_eri_json ->> ''hl'' AS examclassrst --検査結果形態
            ,ntss_db5_om_eri_json ->> ''freememo'' AS comments --コメント
        FROM
            pat_exam_main ntss_db5_pxm
            CROSS JOIN LATERAL json_array_elements(ntss_db5_pxm.exam_result_info::json) ntss_db5_om_eri_json
            LEFT JOIN mst_exam_item ntss_db5_mst_e
            ON cast(ntss_db5_mst_e.exam_item_cd AS char(20)) = cast(ntss_db5_om_eri_json ->> ''item_cd'' AS char(20))
        WHERE
            ntss_db5_pxm.is_del = ''0''
            AND ntss_db5_pxm.facility_cd = @facilityCd
            AND ntss_db5_pxm.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
            AND to_date(@toDate, ''YYYYMMDDHH24MISS'' )
            AND ntss_db5_pxm.exam_result_info IS NOT NULL'
WHERE sql_cd = '-2270';


-- V_PAT_EXAMIN_SCH
UPDATE sys_data_set
SET "sql"=
        'SELECT
            '''' AS hosppatid --患者ID
            ,ntss_db5_pem.pat_id AS patid
            ,to_char(ntss_db5_pem.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
            ,ntss_db5_pem.reg_exam_date
            ,to_char(ntss_db5_pem.reg_exam_date, ''YYYYMMDD'') AS examdate --検査予定日
            ,to_char(ntss_db5_pem.reg_exam_date, ''hh24mi'') AS examtime --検査予定時刻
            ,ntss_db5_pem_mst_ei.in_hospital_cd1 AS examsetcd --検査セットNo(院内コード)
            ,ntss_db5_pem_oesi_json ->> ''set_name'' AS examsetname --検査セット名称
            ,ntss_db5_pem.reg_order_class AS examdivision --検査予定区分
            ,ntss_db5_pem.exam_status AS examproccd --検査実施予定コード
            ,'''' AS doctorcode --指示者
            ,ntss_db5_pem.ind_user_id AS userid
            ,'''' AS doctorname --指示者名
            ,'''' AS doctorcode --オーダー入力者
            ,ntss_db5_pem.up_staff AS userid
            ,'''' AS doctorname --オーダ入力者名
            ,'''' AS doctorcode --更新者
            ,'''' AS doctorname --更新者名
            ,ntss_db5_pem.facility_cd
            ,ntss_db5_pem.up_date
        FROM
            pat_exam_main ntss_db5_pem
            CROSS JOIN LATERAL json_array_elements(ntss_db5_pem.order_exam_set_info::json) ntss_db5_pem_oesi_json
            LEFT JOIN mst_exam_set ntss_db5_pem_mst_ei
            ON ntss_db5_pem_mst_ei.exam_set_cd = cast(ntss_db5_pem_oesi_json ->> ''set_cd'' AS integer)
        WHERE
            ntss_db5_pem.is_del = ''0''
            AND ntss_db5_pem.facility_cd = @facilityCd
            AND ntss_db5_pem.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
            AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
            AND ntss_db5_pem.order_exam_set_info IS NOT NULL
            AND ntss_db5_pem.order_exam_set_info <> ''[]'';'
WHERE sql_cd = '-2280';


-- V_MNT_WATER_SURVEY
UPDATE sys_data_set
SET "sql"=
        'SELECT
            ntss_db5_mnt_wsp.survey_point_cd AS surveypointcd --調査箇所コード
            ,ntss_db5_mnt_wsp.point_name AS surveypointname --調査箇所名
            ,to_char(ntss_db5_mnt_ws.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
            ,to_char(ntss_db5_mnt_ws.inspection_date, ''YYYYMMDD'') AS checkdate --調査日
            ,ntss_db5_om_sd_json ->> ''value'' AS results --調査結果値
            ,ntss_db5_om_sd_json ->> ''unit'' AS unit --単位
            ,'''' AS detail --調査結果詳細
        FROM
            mnt_water_survey ntss_db5_mnt_ws
            CROSS JOIN LATERAL json_array_elements(ntss_db5_mnt_ws.survey_data ::json) ntss_db5_om_sd_json
            LEFT JOIN mst_water_survey_point ntss_db5_mnt_wsp
            ON cast(ntss_db5_mnt_wsp.survey_point_cd as char(10)) = cast(ntss_db5_om_sd_json ->> ''point_cd'' as char(10))
        WHERE
            ntss_db5_mnt_ws.is_del = ''0''
            AND ntss_db5_mnt_ws.facility_cd = @facilityCd
            AND ntss_db5_mnt_ws.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
            AND to_date( @toDate, ''YYYYMMDDHH24MISS'' );'
WHERE sql_cd = '-2291';


-- V_PAT_STATUS
UPDATE sys_data_set
SET "sql"=
        'WITH ntss_db5_om_mnt_mr AS (
            SELECT
                 ntss_db5_om.ord_no AS ord_no
                ,ntss_db5_om_mnt_mr.event_reg_date AS event_reg_date
                ,ntss_db5_om_mnt_mr.machine_record_cd
            FROM
                ord_main ntss_db5_om
                INNER JOIN mnt_motion_record ntss_db5_om_mnt_mr
                ON ntss_db5_om_mnt_mr.motion_record_no = ntss_db5_om.rst_machine_no
                AND ntss_db5_om_mnt_mr.machine_record_cd in (''F407'',''4000'')
            WHERE ntss_db5_om.facility_cd = @facilityCd
            AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
            AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
        )
        SELECT
            ntss_db5_om.up_date
            ,'''' AS hosppatid --患者ID
            ,ntss_db5_om.pat_id AS patid
            ,ntss_db5_om.treat_date AS dialysisdate --透析日
            ,to_char(ntss_db5_om.rst_start_date, ''HH24MISS'') AS dialysistime --透析開始時刻
            ,CASE WHEN ntss_db5_om.rst_dialysis_state IN (''0'',''1'',''2'')
                  THEN ntss_db5_om.ind_treat_start_time
                  WHEN ntss_db5_om.rst_dialysis_state IN (''3'',''4'',''5'',''6'')
                  THEN to_char(ntss_db5_om.rec_set_date, ''YYYY-MM-DD hh24:mi:ss'')
              END AS startplandate --予定開始日時
            ,CASE WHEN ntss_db5_om.rst_cond_send_date IS NULL
                  THEN ''0''
                  ELSE ''1''
              END AS enterflg --入室フラグ（前体重測定）
            ,to_char(ntss_db5_om.rst_cond_send_date, ''YYYY-MM-DD hh24:mi:ss'') AS enterdate --初回入室日時
            ,CASE WHEN ntss_db5_om_mnt_mr.machine_record_cd = ''F407'' AND ntss_db5_om_mnt_mr.event_reg_date IS NULL
                  THEN ''0''
                  ELSE ''1''
              END AS machinecheckflg --透析装置確認フラグ
            ,CASE WHEN ntss_db5_om_mnt_mr.machine_record_cd = ''F407''
                  THEN to_char(ntss_db5_om_mnt_mr.event_reg_date, ''YYYY-MM-DD hh24:mi:ss'')
                  ELSE null
                  END AS machinecheckdate --透析装置確認日時X
            ,CASE WHEN ntss_db5_om.rst_start_date IS NULL
                  THEN ''0''
                  ELSE ''1''
              END AS dialsisstartflg --透析運転開始フラグ
            ,to_char(ntss_db5_om.rst_start_date, ''YYYY-MM-DD hh24:mi:ss'') AS dialsissstartdate--透析運転開始日時
            ,CASE WHEN ntss_db5_om_mnt_mr.machine_record_cd = ''4000'' AND ntss_db5_om_mnt_mr.event_reg_date IS NULL
                  THEN ''0''
                  ELSE ''1''
              END AS offwaterflg --除水完了フラグ
            ,CASE WHEN ntss_db5_om_mnt_mr.machine_record_cd = ''4000''
                  THEN to_char(ntss_db5_om_mnt_mr.event_reg_date, ''YYYY-MM-DD hh24:mi:ss'')
                  ELSE null
                  END AS offwaterdate --除水完了日時
            ,CASE WHEN ntss_db5_om.rst_end_date IS NULL
                  THEN ''0''
                  ELSE ''1''
              END AS wastefluidflg --排液フラグ
            ,to_char(ntss_db5_om.rst_end_date, ''YYYY-MM-DD hh24:mi:ss'') AS wastefluiddate --排液日時
            ,CASE WHEN ntss_db5_om.rst_weight_info #>> ''{weight_after_date}'' IS NULL
                  THEN ''0''
                  ELSE ''1''
              END AS weightafterflg --後体重測定
            ,ntss_db5_om.rst_weight_info #>> ''{weight_after_date}'' AS weightafterdate --後体重測定日時
            ,CASE WHEN ntss_db5_om.rec_set_date IS NULL
                  THEN ''0''
                  ELSE ''1''
              END AS recoverybtnflg --準備回収確認ボタンフラグ
            ,to_char(ntss_db5_om.rec_set_date, ''YYYY-MM-DD hh24:mi:ss'') AS recoverybtndate --準備回収確認ボタン日時
            ,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --最終更新日時
        FROM
            ord_main ntss_db5_om
            LEFT JOIN ntss_db5_om_mnt_mr
            ON ntss_db5_om_mnt_mr.ord_no = ntss_db5_om.ord_no
        WHERE
            ntss_db5_om.is_del = ''0''
            AND ntss_db5_om.facility_cd = @facilityCd
            AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
            AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
            AND ntss_db5_om.rst_weight_info IS NOT NULL;'
WHERE sql_cd = '-2300';


-- V_ONL_RST_DIALYSIS_EQUIP
UPDATE sys_data_set
SET "sql"=
        'SELECT
            '''' AS hosppatid                             --患者ID
            , ntss_db5_om.pat_id AS patid
            , ntss_db5_os.treat_date AS dialysisdate    --透析日
            , ntss_db5_om.ord_no AS dialysisno          --透析番号
            , row_number() over (ORDER BY ntss_db5_om.treat_date DESC) AS ctlno --項目番号
            , to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
            , ntss_db5_mst_e.in_hospital_cd_1 AS equipcd --医療材料コード(院内コード1)
            , ntss_db5_mst_e.in_hospital_cd_2 AS equipcd2 --医療材料コード(院内コード2)
            , ntss_db5_mst_e.equipment_name AS equipname --医療材料名
            , ntss_db5_mst_c.class_name AS equipclassname --医療材料分類名
            , ntss_db5_om_rqi_json ->> ''needle_type'' AS punctureclass --穿刺針区分
            , ntss_db5_om_rqi_json ->> ''amount'' AS amount --数量
            , ntss_db5_mst_e.unit AS unit   --単位
            , ntss_db5_om_rqi_json ->> ''comment'' AS comments --コメント
        FROM
            ord_main ntss_db5_om
            CROSS JOIN LATERAL json_array_elements(ntss_db5_om.rst_equip_info ::json) ntss_db5_om_rqi_json
            LEFT JOIN ord_schedule ntss_db5_os
                ON ntss_db5_om.ord_no = ntss_db5_os.ord_no
            LEFT JOIN mst_equipment ntss_db5_mst_e
                ON cast(ntss_db5_mst_e.equipment_cd as char (10)) = cast(ntss_db5_om_rqi_json ->> ''cd'' as char (10))
            LEFT JOIN mst_equipment_class ntss_db5_mst_c
               ON ntss_db5_mst_c.class_cd = ntss_db5_mst_e.class_cd
        WHERE
            ntss_db5_om.is_del = ''0''
            AND ntss_db5_om.facility_cd = @facilityCd
            AND ntss_db5_om.up_date BETWEEN to_date(@fromDate, ''YYYYMMDDHH24MISS'') AND to_date(@toDate, ''YYYYMMDDHH24MISS'')
            AND ntss_db5_om.pat_id IS NOT NULL;'
WHERE sql_cd = '-2120';


-- V_ONL_RST_DIALYSIS_MEDI
UPDATE sys_data_set
SET "sql"=
        'with ntss_db5_om_temp AS (
            SELECT
                ntss_db5_om.ord_no
                , ntss_db5_om_rmi_json ->> ''cd'' ::char (10) AS cd
                , ntss_db5_om_rmi_json ->> ''procedure_cd'' ::char (10) AS procedure_cd
                , ntss_db5_om_rmi_json ->> ''amount'' AS amount --数量
                , ntss_db5_om_rmi_json ->> ''effect_flg'' AS effectflg --実施フラグ
                , CASE WHEN POSITION(''T'' IN cast(ntss_db5_om_rmi_json ->> ''effect_date'' AS char (20))) != 0
                       THEN to_char(to_timestamp(ntss_db5_om_rmi_json ->> ''effect_date'', ''YYYY-MM-DDThh24:mi:ss''
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
                AND ntss_db5_om.up_date BETWEEN to_date(@fromDate, ''YYYYMMDDHH24MISS'') AND to_date(@toDate, ''YYYYMMDDHH24MISS'')
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
            , ntss_db5_mst_m.in_hospital_cd_1 AS medicinecd --薬剤コード(院内コード1)
            , ntss_db5_mst_m.in_hospital_cd_2 AS medicinecd2 --薬剤コード(院内コード2)
            , ntss_db5_mst_m.medicine_name AS medicinename --薬剤名
            , ntss_db5_mst_c.class_name AS medicineclassname --薬剤分類名
            , ntss_db5_om_temp.amount AS amount         --数量
            , ntss_db5_mst_m.unit AS unit               --単位
            , ntss_db5_om_temp.effectflg AS effectflg   --実施フラグ
            , ntss_db5_om_temp.effectdate               --実施日時
            , ntss_db5_om_temp.timingname AS timingname --投与時間帯名
            , ntss_db5_mst_p.in_hospital_cd_a1 AS procedurecd --手技コード(院内コード1)
            , ntss_db5_mst_p.in_hospital_cd_a2 AS procedurecd2 --手技コード(院内コード2)
            , ntss_db5_mst_p.pricedure_name AS procedurename --手技名
            , '''' AS indicatorcd                         --実施者コード
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
                ON ntss_db5_mst_p.procedure_cd ::char (10) = ntss_db5_om_temp.procedure_cd'
WHERE sql_cd = '-2130';


-- V_ONL_RST_RECEIPT_MEMO_DIALYSIS
UPDATE sys_data_set
SET "sql"=
        'SELECT
            ntss_db6_ppm.hosp_pat_id AS hosppatid --患者ID
            ,ntss_db6_ppm.pat_id AS patid
            ,'''' AS dialysisdate --透析日
            ,'''' AS dialysisno --透析番号
            ,'''' AS ctlno --項目番号
            ,'''' AS updates --更新日時
            ,ntss_db5_om_ddci_json1 ->> ''dial_diff_cd'' AS dialdiffcd
            ,''0'' AS division --レセプトメモ区分
            ,'''' AS codes --コード
            ,'''' AS codeupdate --コード更新日時
            ,''0'' AS addflg --加算有無
            ,'''' AS itemname --項目名称
            ,CASE WHEN ntss_db5_om_ddci_json1 ->> ''is_main'' = ''1''
                  THEN ntss_db5_om_ddci_json1 ->> ''dial_diff_cd''
                 ELSE null
              END AS dialdiffcd2
            ,'''' AS maindialdiff --主たる透析困難
            ,'''' AS inhospitalcd --院内コード
            ,'''' AS inhospitalcd2 --院内コード２
        FROM
            pat_personal_main ntss_db6_ppm
            CROSS JOIN LATERAL json_array_elements(ntss_db6_ppm.dial_diff_com_info ::json) ntss_db5_om_ddci_json1
          WHERE ntss_db6_ppm.is_del = ''0''
            AND ntss_db5_om_ddci_json1 ->> ''dial_diff_cd'' = ''1''
            AND ntss_db6_ppm.dial_diff_com_info IS NOT NULL
            AND ntss_db6_ppm.dial_diff_com_info <> ''[]''
            AND ntss_db6_ppm.facility_cd = @facilityCd
            AND ntss_db6_ppm.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
            AND to_date(  @toDate, ''YYYYMMDDHH24MISS'' )
            AND ntss_db6_ppm.pat_id IS NOT NULL;'
WHERE sql_cd = '-2160';


-- V_ONL_RST_RECEIPT_MEMO_ADDITION
UPDATE sys_data_set
SET "sql"=
        'SELECT
            '''' AS hosppatid                             --患者ID
            , ntss_db5_om.pat_id AS patid
            , ntss_db5_os.treat_date AS dialysisdate    --透析日
            , ntss_db5_om.ord_no AS dialysisno          --透析番号
            , row_number() over (ORDER BY ntss_db5_om.treat_date DESC) AS ctlno --項目番号
            , to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
            , ''1'' AS division                           --レセプトメモ区分
            , ntss_db5_mst_a.in_hospital_cd_1 AS codes  --コード
            , to_char(ntss_db5_mst_a.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS codeupdate --コード更新日時
            , ''1'' AS addflg                             --加算有無
            , ntss_db5_mst_a.addition_name AS itemname  --項目名称
            , '''' AS maindialdiff                        --主たる透析困難
            , ntss_db5_mst_a.in_hospital_cd_1 AS inhospitalcd --院内コード
            , ntss_db5_mst_a.in_hospital_cd_2 AS inhospitalcd2 --院内コード２
        FROM
            ord_main ntss_db5_om
            CROSS JOIN LATERAL json_array_elements(ntss_db5_om.addition_info ::json) ntss_db5_om_di_json1
            INNER JOIN mst_addition ntss_db5_mst_a
                ON cast(ntss_db5_mst_a.addition_cd AS char (20)) = cast(ntss_db5_om_di_json1 ->> ''cd'' AS char (20))
            LEFT JOIN ord_schedule ntss_db5_os
                ON ntss_db5_os.ord_no = ntss_db5_om.ord_no
        WHERE
            ntss_db5_om.is_del = ''0''
            AND ntss_db5_om.facility_cd = @facilityCd
            AND ntss_db5_om.addition_info IS NOT NULL
            AND ntss_db5_om.addition_info <> ''[]''
            AND ntss_db5_om.up_date BETWEEN to_date(@fromDate, ''YYYYMMDDHH24MISS'') AND to_date(@toDate, ''YYYYMMDDHH24MISS'')
            AND ntss_db5_om.pat_id IS NOT NULL;'
WHERE sql_cd = '-2164';


-- V_ONL_DIALYSIS_VITAL
UPDATE sys_data_set
SET "sql"=
        'with ntss_db5_mm_1 as (
            SELECT
                ntss_db5_mm_1.facility_cd
                , ntss_db5_mm_1.ord_no AS ord_no
                , ntss_db5_mm_1.data_type AS data_type
                , ntss_db5_mm_1.monitor_data AS monitor_data
                , min(ntss_db5_mm_1.occur_date) AS occur_date
                , min(ntss_db5_mm_1.up_date) AS up_date
            FROM
                mni_monitor ntss_db5_mm_1
            WHERE
                ntss_db5_mm_1.ord_no IS NOT NULL
                AND ntss_db5_mm_1.data_type IN (''2'', ''4'', ''5'', ''6'')
                AND ntss_db5_mm_1.facility_cd = @facilityCd
                AND ntss_db5_mm_1.up_date BETWEEN to_date(@fromDate, ''YYYYMMDDHH24MISS'') AND to_date(@toDate, ''YYYYMMDDHH24MISS'')
            GROUP BY
                ntss_db5_mm_1.facility_cd
                , ntss_db5_mm_1.ord_no
                , ntss_db5_mm_1.data_type
                , ntss_db5_mm_1.monitor_data
        )
        SELECT
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
            , ntss_db5_mm_1.monitor_data ->> ''90'' AS bpmax --最高血圧
            , ntss_db5_mm_1.monitor_data ->> ''91'' AS bpmin --最低血圧
            , ntss_db5_mm_1.monitor_data ->> ''92'' AS bpave --平均血圧
            , ntss_db5_mm_1.monitor_data ->> ''93'' AS pulse --脈拍
            , ntss_db5_mm_1.monitor_data ->> ''94'' AS temperature --体温
            , ntss_db5_mm_1.monitor_data ->> ''-1'' AS bloodsugarlevel --血糖値
            , to_char(ntss_db5_mm_1.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
            , ntss_db5_mm_1.ord_no AS diadysisno        --透析番号
            , ntss_db5_mm_1.data_type AS bpclass        --血圧区分
        FROM
            ord_main ntss_db5_om
            INNER JOIN ntss_db5_mm_1
                ON ntss_db5_mm_1.ord_no = ntss_db5_om.ord_no
        WHERE
            ntss_db5_om.is_del = ''0''
            AND ntss_db5_om.facility_cd = @facilityCd
            AND ntss_db5_om.up_date BETWEEN to_date(@fromDate, ''YYYYMMDDHH24MISS'') AND to_date(@toDate, ''YYYYMMDDHH24MISS'')
            AND ntss_db5_om.pat_id IS NOT NULL;'
WHERE sql_cd = '-2240';


-- V_DIALYSIS_MONI
UPDATE sys_data_set
SET "sql"=
        'WITH ntss_db5_mm AS (
            SELECT
                ntss_db5_om.rst_machine_no
                , ntss_db5_om.rst_bed_cd
                , ntss_db5_mm.ord_no AS ord_no
                , ntss_db5_mm.occur_date AS occur_date
                , ntss_db5_mm.monitor_data AS monitor_data
                , ntss_db5_mm.up_date AS up_date
                , ntss_db5_om.pat_id
            FROM
                ord_main ntss_db5_om
                INNER JOIN mni_monitor ntss_db5_mm
                    ON ntss_db5_mm.ord_no = ntss_db5_om.ord_no
                    AND ntss_db5_mm.data_type = ''1''
                    AND ntss_db5_mm.is_del = ''0''
                    AND ntss_db5_om.facility_cd = ntss_db5_mm.facility_cd
            WHERE
                ntss_db5_om.facility_cd = @facilityCd
                AND ntss_db5_om.is_del = ''0''
                AND ntss_db5_om.up_date BETWEEN to_date(@fromDate, ''YYYYMMDDHH24MISS'') AND to_date(@toDate, ''YYYYMMDDHH24MISS'')
        )
        SELECT
            ntss_db5_mst_b.in_hospital_cd_1 AS bedno    --ベッド番号
            , ntss_db5_mst_m.machine_serial AS deviceno --装置番号
            , to_char(ntss_db5_mm.occur_date, ''YYYY-MM-DD hh24:mi:ss'') AS occurdate --発生日時
            , '''' AS hosppatid                           --患者ID
            , ntss_db5_mm.pat_id AS patid
            , ''1'' AS moniname1                          --モニタ項目名1
            , ntss_db5_mm.monitor_data #>> ''{1}'' AS moniitem1 --モニタ項目値1
            , ''2'' AS moniname2                          --モニタ項目名2
            , ntss_db5_mm.monitor_data #>> ''{2}'' AS moniitem2 --モニタ項目値2
            , ''3'' AS moniname3                          --モニタ項目名3
            , ntss_db5_mm.monitor_data #>> ''{3}'' AS moniitem3 --モニタ項目値3
            , ''4'' AS moniname4                          --モニタ項目名4
            , ntss_db5_mm.monitor_data #>> ''{4}'' AS moniitem4 --モニタ項目値4
            , ''5'' AS moniname5                          --モニタ項目名5
            , ntss_db5_mm.monitor_data #>> ''{5}'' AS moniitem5 --モニタ項目値5
            , ''6'' AS moniname6                          --モニタ項目名6
            , ntss_db5_mm.monitor_data #>> ''{6}'' AS moniitem6 --モニタ項目値6
            , ''7'' AS moniname7                          --モニタ項目名7
            , ntss_db5_mm.monitor_data #>> ''{7}'' AS moniitem7 --モニタ項目値7
            , ''8'' AS moniname8                          --モニタ項目名8
            , ntss_db5_mm.monitor_data #>> ''{8}'' AS moniitem8 --モニタ項目値8
            , ''9'' AS moniname9                          --モニタ項目名9
            , ntss_db5_mm.monitor_data #>> ''{9}'' AS moniitem9 --モニタ項目値9
            , ''10'' AS moniname10                        --モニタ項目名10
            , ntss_db5_mm.monitor_data #>> ''{10}'' AS moniitem10 --モニタ項目値10
            , ''11'' AS moniname11                        --モニタ項目名11
            , ntss_db5_mm.monitor_data #>> ''{11}'' AS moniitem11 --モニタ項目値11
            , ''12'' AS moniname12                        --モニタ項目名12
            , ntss_db5_mm.monitor_data #>> ''{12}'' AS moniitem12 --モニタ項目値12
            , ''13'' AS moniname13                        --モニタ項目名13
            , ntss_db5_mm.monitor_data #>> ''{13}'' AS moniitem13 --モニタ項目値13
            , ''14'' AS moniname14                        --モニタ項目名14
            , ntss_db5_mm.monitor_data #>> ''{14}'' AS moniitem14 --モニタ項目値14
            , ''15'' AS moniname15                        --モニタ項目名15
            , ntss_db5_mm.monitor_data #>> ''{15}'' AS moniitem15 --モニタ項目値15
            , ''16'' AS moniname16                        --モニタ項目名16
            , ntss_db5_mm.monitor_data #>> ''{16}'' AS moniitem16 --モニタ項目値16
            , ''17'' AS moniname17                        --モニタ項目名17
            , ntss_db5_mm.monitor_data #>> ''{17}'' AS moniitem17 --モニタ項目値17
            , ''18'' AS moniname18                        --モニタ項目名18
            , ntss_db5_mm.monitor_data #>> ''{18}'' AS moniitem18 --モニタ項目値18
            , ''19'' AS moniname19                        --モニタ項目名19
            , ntss_db5_mm.monitor_data #>> ''{19}'' AS moniitem19 --モニタ項目値19
            , ''20'' AS moniname20                        --モニタ項目名20
            , ntss_db5_mm.monitor_data #>> ''{20}'' AS moniitem20 --モニタ項目値20
            , ''21'' AS moniname21                        --モニタ項目名21
            , ntss_db5_mm.monitor_data #>> ''{21}'' AS moniitem21 --モニタ項目値21
            , ''22'' AS moniname22                        --モニタ項目名22
            , ntss_db5_mm.monitor_data #>> ''{22}'' AS moniitem22 --モニタ項目値22
            , ''23'' AS moniname23                        --モニタ項目名23
            , ntss_db5_mm.monitor_data #>> ''{23}'' AS moniitem23 --モニタ項目値23
            , ''24'' AS moniname24                        --モニタ項目名24
            , ntss_db5_mm.monitor_data #>> ''{24}'' AS moniitem24 --モニタ項目値24
            , ''25'' AS moniname25                        --モニタ項目名25
            , ntss_db5_mm.monitor_data #>> ''{25}'' AS moniitem25 --モニタ項目値25
            , ''26'' AS moniname26                        --モニタ項目名26
            , ntss_db5_mm.monitor_data #>> ''{26}'' AS moniitem26 --モニタ項目値26
            , ''27'' AS moniname27                        --モニタ項目名27
            , ntss_db5_mm.monitor_data #>> ''{27}'' AS moniitem27 --モニタ項目値27
            , ''28'' AS moniname28                        --モニタ項目名28
            , ntss_db5_mm.monitor_data #>> ''{28}'' AS moniitem28 --モニタ項目値28
            , ''29'' AS moniname29                        --モニタ項目名29
            , ntss_db5_mm.monitor_data #>> ''{29}'' AS moniitem29 --モニタ項目値29
            , ''30'' AS moniname30                        --モニタ項目名30
            , ntss_db5_mm.monitor_data #>> ''{30}'' AS moniitem30 --モニタ項目値30
            , ''31'' AS moniname31                        --モニタ項目名31
            , ntss_db5_mm.monitor_data #>> ''{31}'' AS moniitem31 --モニタ項目値31
            , ''32'' AS moniname32                        --モニタ項目名32
            , ntss_db5_mm.monitor_data #>> ''{32}'' AS moniitem32 --モニタ項目値32
            , ''33'' AS moniname33                        --モニタ項目名33
            , ntss_db5_mm.monitor_data #>> ''{33}'' AS moniitem33 --モニタ項目値33
            , ''34'' AS moniname34                        --モニタ項目名34
            , ntss_db5_mm.monitor_data #>> ''{34}'' AS moniitem34 --モニタ項目値34
            , ''35'' AS moniname35                        --モニタ項目名35
            , ntss_db5_mm.monitor_data #>> ''{35}'' AS moniitem35 --モニタ項目値35
            , ''36'' AS moniname36                        --モニタ項目名36
            , ntss_db5_mm.monitor_data #>> ''{36}'' AS moniitem36 --モニタ項目値36
            , ''37'' AS moniname37                        --モニタ項目名37
            , ntss_db5_mm.monitor_data #>> ''{37}'' AS moniitem37 --モニタ項目値37
            , ''38'' AS moniname38                        --モニタ項目名38
            , ntss_db5_mm.monitor_data #>> ''{38}'' AS moniitem38 --モニタ項目値38
            , ''39'' AS moniname39                        --モニタ項目名39
            , ntss_db5_mm.monitor_data #>> ''{39}'' AS moniitem39 --モニタ項目値39
            , ''40'' AS moniname40                        --モニタ項目名40
            , ntss_db5_mm.monitor_data #>> ''{40}'' AS moniitem40 --モニタ項目値40
            , ''41'' AS moniname41                        --モニタ項目名41
            , ntss_db5_mm.monitor_data #>> ''{41}'' AS moniitem41 --モニタ項目値41
            , ''42'' AS moniname42                        --モニタ項目名42
            , ntss_db5_mm.monitor_data #>> ''{42}'' AS moniitem42 --モニタ項目値42
            , ''43'' AS moniname43                        --モニタ項目名43
            , ntss_db5_mm.monitor_data #>> ''{43}'' AS moniitem43 --モニタ項目値43
            , ''44'' AS moniname44                        --モニタ項目名44
            , ntss_db5_mm.monitor_data #>> ''{44}'' AS moniitem44 --モニタ項目値44
            , ''45'' AS moniname45                        --モニタ項目名45
            , ntss_db5_mm.monitor_data #>> ''{45}'' AS moniitem45 --モニタ項目値45
            , ''46'' AS moniname46                        --モニタ項目名46
            , ntss_db5_mm.monitor_data #>> ''{46}'' AS moniitem46 --モニタ項目値46
            , ''47'' AS moniname47                        --モニタ項目名47
            , ntss_db5_mm.monitor_data #>> ''{47}'' AS moniitem47 --モニタ項目値47
            , ''48'' AS moniname48                        --モニタ項目名48
            , ntss_db5_mm.monitor_data #>> ''{48}'' AS moniitem48 --モニタ項目値48
            , ''49'' AS moniname49                        --モニタ項目名49
            , ntss_db5_mm.monitor_data #>> ''{49}'' AS moniitem49 --モニタ項目値49
            , ''50'' AS moniname50                        --モニタ項目名50
            , ntss_db5_mm.monitor_data #>> ''{50}'' AS moniitem50 --モニタ項目値50
            , ''51'' AS moniname51                        --モニタ項目名51
            , ntss_db5_mm.monitor_data #>> ''{51}'' AS moniitem51 --モニタ項目値51
            , ''52'' AS moniname52                        --モニタ項目名52
            , ntss_db5_mm.monitor_data #>> ''{52}'' AS moniitem52 --モニタ項目値52
            , ''53'' AS moniname53                        --モニタ項目名53
            , ntss_db5_mm.monitor_data #>> ''{53}'' AS moniitem53 --モニタ項目値53
            , ''54'' AS moniname54                        --モニタ項目名54
            , ntss_db5_mm.monitor_data #>> ''{54}'' AS moniitem54 --モニタ項目値54
            , ''55'' AS moniname55                        --モニタ項目名55
            , ntss_db5_mm.monitor_data #>> ''{55}'' AS moniitem55 --モニタ項目値55
            , ''56'' AS moniname56                        --モニタ項目名56
            , ntss_db5_mm.monitor_data #>> ''{56}'' AS moniitem56 --モニタ項目値56
            , ''57'' AS moniname57                        --モニタ項目名57
            , ntss_db5_mm.monitor_data #>> ''{57}'' AS moniitem57 --モニタ項目値57
            , ''58'' AS moniname58                        --モニタ項目名58
            , ntss_db5_mm.monitor_data #>> ''{58}'' AS moniitem58 --モニタ項目値58
            , ''59'' AS moniname59                        --モニタ項目名59
            , ntss_db5_mm.monitor_data #>> ''{59}'' AS moniitem59 --モニタ項目値59
            , ''60'' AS moniname60                        --モニタ項目名60
            , ntss_db5_mm.monitor_data #>> ''{60}'' AS moniitem60 --モニタ項目値60
            , ''61'' AS moniname61                        --モニタ項目名61
            , ntss_db5_mm.monitor_data #>> ''{61}'' AS moniitem61 --モニタ項目値61
            , ''62'' AS moniname62                        --モニタ項目名62
            , ntss_db5_mm.monitor_data #>> ''{62}'' AS moniitem62 --モニタ項目値62
            , ''63'' AS moniname63                        --モニタ項目名63
            , ntss_db5_mm.monitor_data #>> ''{63}'' AS moniitem63 --モニタ項目値63
            , ''64'' AS moniname64                        --モニタ項目名64
            , ntss_db5_mm.monitor_data #>> ''{64}'' AS moniitem64 --モニタ項目値64
            , ''65'' AS moniname65                        --モニタ項目名65
            , ntss_db5_mm.monitor_data #>> ''{65}'' AS moniitem65 --モニタ項目値65
            , ''66'' AS moniname66                        --モニタ項目名66
            , ntss_db5_mm.monitor_data #>> ''{66}'' AS moniitem66 --モニタ項目値66
            , ''67'' AS moniname67                        --モニタ項目名67
            , ntss_db5_mm.monitor_data #>> ''{67}'' AS moniitem67 --モニタ項目値67
            , ''68'' AS moniname68                        --モニタ項目名68
            , ntss_db5_mm.monitor_data #>> ''{68}'' AS moniitem68 --モニタ項目値68
            , ''69'' AS moniname69                        --モニタ項目名69
            , ntss_db5_mm.monitor_data #>> ''{69}'' AS moniitem69 --モニタ項目値69
            , ''70'' AS moniname70                        --モニタ項目名70
            , ntss_db5_mm.monitor_data #>> ''{70}'' AS moniitem70 --モニタ項目値70
            , ''71'' AS moniname71                        --モニタ項目名71
            , ntss_db5_mm.monitor_data #>> ''{71}'' AS moniitem71 --モニタ項目値71
            , ''72'' AS moniname72                        --モニタ項目名72
            , ntss_db5_mm.monitor_data #>> ''{72}'' AS moniitem72 --モニタ項目値72
            , ''73'' AS moniname73                        --モニタ項目名73
            , ntss_db5_mm.monitor_data #>> ''{73}'' AS moniitem73 --モニタ項目値73
            , ''74'' AS moniname74                        --モニタ項目名74
            , ntss_db5_mm.monitor_data #>> ''{74}'' AS moniitem74 --モニタ項目値74
            , ''75'' AS moniname75                        --モニタ項目名75
            , ntss_db5_mm.monitor_data #>> ''{75}'' AS moniitem75 --モニタ項目値75
            , ''76'' AS moniname76                        --モニタ項目名76
            , ntss_db5_mm.monitor_data #>> ''{76}'' AS moniitem76 --モニタ項目値76
            , ''77'' AS moniname77                        --モニタ項目名77
            , ntss_db5_mm.monitor_data #>> ''{77}'' AS moniitem77 --モニタ項目値77
            , ''78'' AS moniname78                        --モニタ項目名78
            , ntss_db5_mm.monitor_data #>> ''{78}'' AS moniitem78 --モニタ項目値78
            , ''79'' AS moniname79                        --モニタ項目名79
            , ntss_db5_mm.monitor_data #>> ''{79}'' AS moniitem79 --モニタ項目値79
            , ''80'' AS moniname80                        --モニタ項目名80
            , ntss_db5_mm.monitor_data #>> ''{80}'' AS moniitem80 --モニタ項目値80
            , ''81'' AS moniname81                        --モニタ項目名81
            , ntss_db5_mm.monitor_data #>> ''{81}'' AS moniitem81 --モニタ項目値81
            , ''82'' AS moniname82                        --モニタ項目名82
            , ntss_db5_mm.monitor_data #>> ''{82}'' AS moniitem82 --モニタ項目値82
            , ''83'' AS moniname83                        --モニタ項目名83
            , ntss_db5_mm.monitor_data #>> ''{83}'' AS moniitem83 --モニタ項目値83
            , ''84'' AS moniname84                        --モニタ項目名84
            , ntss_db5_mm.monitor_data #>> ''{84}'' AS moniitem84 --モニタ項目値84
            , ''85'' AS moniname85                        --モニタ項目名85
            , ntss_db5_mm.monitor_data #>> ''{85}'' AS moniitem85 --モニタ項目値85
            , ''86'' AS moniname86                        --モニタ項目名86
            , ntss_db5_mm.monitor_data #>> ''{86}'' AS moniitem86 --モニタ項目値86
            , ''87'' AS moniname87                        --モニタ項目名87
            , ntss_db5_mm.monitor_data #>> ''{87}'' AS moniitem87 --モニタ項目値87
            , ''88'' AS moniname88                        --モニタ項目名88
            , ntss_db5_mm.monitor_data #>> ''{88}'' AS moniitem88 --モニタ項目値88
            , ''89'' AS moniname89                        --モニタ項目名89
            , ntss_db5_mm.monitor_data #>> ''{89}'' AS moniitem89 --モニタ項目値89
            , ''90'' AS moniname90                        --モニタ項目名90
            , ntss_db5_mm.monitor_data #>> ''{90}'' AS moniitem90 --モニタ項目値90
            , ''91'' AS moniname91                        --モニタ項目名91
            , ntss_db5_mm.monitor_data #>> ''{91}'' AS moniitem91 --モニタ項目値91
            , ''92'' AS moniname92                        --モニタ項目名92
            , ntss_db5_mm.monitor_data #>> ''{92}'' AS moniitem92 --モニタ項目値92
            , ''93'' AS moniname93                        --モニタ項目名93
            , ntss_db5_mm.monitor_data #>> ''{93}'' AS moniitem93 --モニタ項目値93
            , ''94'' AS moniname94                        --モニタ項目名94
            , ntss_db5_mm.monitor_data #>> ''{94}'' AS moniitem94 --モニタ項目値94
            , ''95'' AS moniname95                        --モニタ項目名95
            , ntss_db5_mm.monitor_data #>> ''{95}'' AS moniitem95 --モニタ項目値95
            , ''96'' AS moniname96                        --モニタ項目名96
            , ntss_db5_mm.monitor_data #>> ''{96}'' AS moniitem96 --モニタ項目値96
            , ''97'' AS moniname97                        --モニタ項目名97
            , ntss_db5_mm.monitor_data #>> ''{97}'' AS moniitem97 --モニタ項目値97
            , ''98'' AS moniname98                        --モニタ項目名98
            , ntss_db5_mm.monitor_data #>> ''{98}'' AS moniitem98 --モニタ項目値98
            , ''99'' AS moniname99                        --モニタ項目名99
            , ntss_db5_mm.monitor_data #>> ''{99}'' AS moniitem99 --モニタ項目値99
            , ''100'' AS moniname100                      --モニタ項目名100
            , ntss_db5_mm.monitor_data #>> ''{100}'' AS moniitem100 --モニタ項目値100
            , to_char(ntss_db5_mm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --発生日時
        FROM
            ntss_db5_mm
            LEFT JOIN mst_bed ntss_db5_mst_b
                ON ntss_db5_mst_b.bed_cd = ntss_db5_mm.rst_bed_cd
            LEFT JOIN mst_machine ntss_db5_mst_m
                ON cast(ntss_db5_mst_m.machine_type_cd AS integer) = ntss_db5_mm.rst_machine_no;'
WHERE sql_cd = '-2420';


-- V_ONL_DIALYSIS_MONI
UPDATE sys_data_set
SET "sql"=
        'WITH ntss_db5_mm AS (
            SELECT
                ntss_db5_om.ord_no AS ord_no
                ,ntss_db5_mm.occur_date AS occur_date
                ,ntss_db5_mm.monitor_data AS monitor_data
                ,ntss_db5_mm.up_date AS up_date
            FROM
                ord_main ntss_db5_om
                LEFT JOIN mni_monitor ntss_db5_mm
                ON ntss_db5_mm.ord_no = ntss_db5_om.ord_no
            WHERE ntss_db5_mm.facility_cd = @facilityCd
                AND ntss_db5_mm.data_type = ''1''
                AND ntss_db5_mm.is_del = ''0''
                AND cast(ntss_db5_om.rst_dialysis_state AS integer) > 0
                AND ntss_db5_mm.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
                AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
        )
        SELECT
            ntss_db5_mst_b.in_hospital_cd_1 AS bedno --ベッド番号
            ,ntss_db5_mst_m.machine_serial AS deviceno --装置番号
            ,to_char(ntss_db5_mm.occur_date, ''YYYY-MM-DD hh24:mi:ss'') AS occurdate --発生日時
            ,'''' AS hosppatid --患者ID
            ,ntss_db5_om.pat_id AS patid
            ,''1'' AS moniname1 --モニタ項目名1
            ,ntss_db5_mm.monitor_data #>> ''{1}'' AS moniitem1 --モニタ項目値1
            ,''2'' AS moniname2 --モニタ項目名2
            ,ntss_db5_mm.monitor_data #>> ''{2}'' AS moniitem2 --モニタ項目値2
            ,''3'' AS moniname3 --モニタ項目名3
            ,ntss_db5_mm.monitor_data #>> ''{3}'' AS moniitem3 --モニタ項目値3
            ,''4'' AS moniname4 --モニタ項目名4
            ,ntss_db5_mm.monitor_data #>> ''{4}'' AS moniitem4 --モニタ項目値4
            ,''5'' AS moniname5 --モニタ項目名5
            ,ntss_db5_mm.monitor_data #>> ''{5}'' AS moniitem5 --モニタ項目値5
            ,''6'' AS moniname6 --モニタ項目名6
            ,ntss_db5_mm.monitor_data #>> ''{6}'' AS moniitem6 --モニタ項目値6
            ,''7'' AS moniname7 --モニタ項目名7
            ,ntss_db5_mm.monitor_data #>> ''{7}'' AS moniitem7 --モニタ項目値7
            ,''8'' AS moniname8 --モニタ項目名8
            ,ntss_db5_mm.monitor_data #>> ''{8}'' AS moniitem8 --モニタ項目値8
            ,''9'' AS moniname9 --モニタ項目名9
            ,ntss_db5_mm.monitor_data #>> ''{9}'' AS moniitem9 --モニタ項目値9
            ,''10'' AS moniname10 --モニタ項目名10
            ,ntss_db5_mm.monitor_data #>> ''{10}'' AS moniitem10 --モニタ項目値10
            ,''11'' AS moniname11 --モニタ項目名11
            ,ntss_db5_mm.monitor_data #>> ''{11}'' AS moniitem11 --モニタ項目値11
            ,''12'' AS moniname12 --モニタ項目名12
            ,ntss_db5_mm.monitor_data #>> ''{12}'' AS moniitem12 --モニタ項目値12
            ,''13'' AS moniname13 --モニタ項目名13
            ,ntss_db5_mm.monitor_data #>> ''{13}'' AS moniitem13 --モニタ項目値13
            ,''14'' AS moniname14 --モニタ項目名14
            ,ntss_db5_mm.monitor_data #>> ''{14}'' AS moniitem14 --モニタ項目値14
            ,''15'' AS moniname15 --モニタ項目名15
            ,ntss_db5_mm.monitor_data #>> ''{15}'' AS moniitem15 --モニタ項目値15
            ,''16'' AS moniname16 --モニタ項目名16
            ,ntss_db5_mm.monitor_data #>> ''{16}'' AS moniitem16 --モニタ項目値16
            ,''17'' AS moniname17 --モニタ項目名17
            ,ntss_db5_mm.monitor_data #>> ''{17}'' AS moniitem17 --モニタ項目値17
            ,''18'' AS moniname18 --モニタ項目名18
            ,ntss_db5_mm.monitor_data #>> ''{18}'' AS moniitem18 --モニタ項目値18
            ,''19'' AS moniname19 --モニタ項目名19
            ,ntss_db5_mm.monitor_data #>> ''{19}'' AS moniitem19 --モニタ項目値19
            ,''20'' AS moniname20 --モニタ項目名20
            ,ntss_db5_mm.monitor_data #>> ''{20}'' AS moniitem20 --モニタ項目値20
            ,''21'' AS moniname21 --モニタ項目名21
            ,ntss_db5_mm.monitor_data #>> ''{21}'' AS moniitem21 --モニタ項目値21
            ,''22'' AS moniname22 --モニタ項目名22
            ,ntss_db5_mm.monitor_data #>> ''{22}'' AS moniitem22 --モニタ項目値22
            ,''23'' AS moniname23 --モニタ項目名23
            ,ntss_db5_mm.monitor_data #>> ''{23}'' AS moniitem23 --モニタ項目値23
            ,''24'' AS moniname24 --モニタ項目名24
            ,ntss_db5_mm.monitor_data #>> ''{24}'' AS moniitem24 --モニタ項目値24
            ,''25'' AS moniname25 --モニタ項目名25
            ,ntss_db5_mm.monitor_data #>> ''{25}'' AS moniitem25 --モニタ項目値25
            ,''26'' AS moniname26 --モニタ項目名26
            ,ntss_db5_mm.monitor_data #>> ''{26}'' AS moniitem26 --モニタ項目値26
            ,''27'' AS moniname27 --モニタ項目名27
            ,ntss_db5_mm.monitor_data #>> ''{27}'' AS moniitem27 --モニタ項目値27
            ,''28'' AS moniname28 --モニタ項目名28
            ,ntss_db5_mm.monitor_data #>> ''{28}'' AS moniitem28 --モニタ項目値28
            ,''29'' AS moniname29 --モニタ項目名29
            ,ntss_db5_mm.monitor_data #>> ''{29}'' AS moniitem29 --モニタ項目値29
            ,''30'' AS moniname30 --モニタ項目名30
            ,ntss_db5_mm.monitor_data #>> ''{30}'' AS moniitem30 --モニタ項目値30
            ,''31'' AS moniname31 --モニタ項目名31
            ,ntss_db5_mm.monitor_data #>> ''{31}'' AS moniitem31 --モニタ項目値31
            ,''32'' AS moniname32 --モニタ項目名32
            ,ntss_db5_mm.monitor_data #>> ''{32}'' AS moniitem32 --モニタ項目値32
            ,''33'' AS moniname33 --モニタ項目名33
            ,ntss_db5_mm.monitor_data #>> ''{33}'' AS moniitem33 --モニタ項目値33
            ,''34'' AS moniname34 --モニタ項目名34
            ,ntss_db5_mm.monitor_data #>> ''{34}'' AS moniitem34 --モニタ項目値34
            ,''35'' AS moniname35 --モニタ項目名35
            ,ntss_db5_mm.monitor_data #>> ''{35}'' AS moniitem35 --モニタ項目値35
            ,''36'' AS moniname36 --モニタ項目名36
            ,ntss_db5_mm.monitor_data #>> ''{36}'' AS moniitem36 --モニタ項目値36
            ,''37'' AS moniname37 --モニタ項目名37
            ,ntss_db5_mm.monitor_data #>> ''{37}'' AS moniitem37 --モニタ項目値37
            ,''38'' AS moniname38 --モニタ項目名38
            ,ntss_db5_mm.monitor_data #>> ''{38}'' AS moniitem38 --モニタ項目値38
            ,''39'' AS moniname39 --モニタ項目名39
            ,ntss_db5_mm.monitor_data #>> ''{39}'' AS moniitem39 --モニタ項目値39
            ,''40'' AS moniname40 --モニタ項目名40
            ,ntss_db5_mm.monitor_data #>> ''{40}'' AS moniitem40 --モニタ項目値40
            ,''41'' AS moniname41 --モニタ項目名41
            ,ntss_db5_mm.monitor_data #>> ''{41}'' AS moniitem41 --モニタ項目値41
            ,''42'' AS moniname42 --モニタ項目名42
            ,ntss_db5_mm.monitor_data #>> ''{42}'' AS moniitem42 --モニタ項目値42
            ,''43'' AS moniname43 --モニタ項目名43
            ,ntss_db5_mm.monitor_data #>> ''{43}'' AS moniitem43 --モニタ項目値43
            ,''44'' AS moniname44 --モニタ項目名44
            ,ntss_db5_mm.monitor_data #>> ''{44}'' AS moniitem44 --モニタ項目値44
            ,''45'' AS moniname45 --モニタ項目名45
            ,ntss_db5_mm.monitor_data #>> ''{45}'' AS moniitem45 --モニタ項目値45
            ,''46'' AS moniname46 --モニタ項目名46
            ,ntss_db5_mm.monitor_data #>> ''{46}'' AS moniitem46 --モニタ項目値46
            ,''47'' AS moniname47 --モニタ項目名47
            ,ntss_db5_mm.monitor_data #>> ''{47}'' AS moniitem47 --モニタ項目値47
            ,''48'' AS moniname48 --モニタ項目名48
            ,ntss_db5_mm.monitor_data #>> ''{48}'' AS moniitem48 --モニタ項目値48
            ,''49'' AS moniname49 --モニタ項目名49
            ,ntss_db5_mm.monitor_data #>> ''{49}'' AS moniitem49 --モニタ項目値49
            ,''50'' AS moniname50 --モニタ項目名50
            ,ntss_db5_mm.monitor_data #>> ''{50}'' AS moniitem50 --モニタ項目値50
            ,''51'' AS moniname51 --モニタ項目名51
            ,ntss_db5_mm.monitor_data #>> ''{51}'' AS moniitem51 --モニタ項目値51
            ,''52'' AS moniname52 --モニタ項目名52
            ,ntss_db5_mm.monitor_data #>> ''{52}'' AS moniitem52 --モニタ項目値52
            ,''53'' AS moniname53 --モニタ項目名53
            ,ntss_db5_mm.monitor_data #>> ''{53}'' AS moniitem53 --モニタ項目値53
            ,''54'' AS moniname54 --モニタ項目名54
            ,ntss_db5_mm.monitor_data #>> ''{54}'' AS moniitem54 --モニタ項目値54
            ,''55'' AS moniname55 --モニタ項目名55
            ,ntss_db5_mm.monitor_data #>> ''{55}'' AS moniitem55 --モニタ項目値55
            ,''56'' AS moniname56 --モニタ項目名56
            ,ntss_db5_mm.monitor_data #>> ''{56}'' AS moniitem56 --モニタ項目値56
            ,''57'' AS moniname57 --モニタ項目名57
            ,ntss_db5_mm.monitor_data #>> ''{57}'' AS moniitem57 --モニタ項目値57
            ,''58'' AS moniname58 --モニタ項目名58
            ,ntss_db5_mm.monitor_data #>> ''{58}'' AS moniitem58 --モニタ項目値58
            ,''59'' AS moniname59 --モニタ項目名59
            ,ntss_db5_mm.monitor_data #>> ''{59}'' AS moniitem59 --モニタ項目値59
            ,''60'' AS moniname60 --モニタ項目名60
            ,ntss_db5_mm.monitor_data #>> ''{60}'' AS moniitem60 --モニタ項目値60
            ,''61'' AS moniname61 --モニタ項目名61
            ,ntss_db5_mm.monitor_data #>> ''{61}'' AS moniitem61 --モニタ項目値61
            ,''62'' AS moniname62 --モニタ項目名62
            ,ntss_db5_mm.monitor_data #>> ''{62}'' AS moniitem62 --モニタ項目値62
            ,''63'' AS moniname63 --モニタ項目名63
            ,ntss_db5_mm.monitor_data #>> ''{63}'' AS moniitem63 --モニタ項目値63
            ,''64'' AS moniname64 --モニタ項目名64
            ,ntss_db5_mm.monitor_data #>> ''{64}'' AS moniitem64 --モニタ項目値64
            ,''65'' AS moniname65 --モニタ項目名65
            ,ntss_db5_mm.monitor_data #>> ''{65}'' AS moniitem65 --モニタ項目値65
            ,''66'' AS moniname66 --モニタ項目名66
            ,ntss_db5_mm.monitor_data #>> ''{66}'' AS moniitem66 --モニタ項目値66
            ,''67'' AS moniname67 --モニタ項目名67
            ,ntss_db5_mm.monitor_data #>> ''{67}'' AS moniitem67 --モニタ項目値67
            ,''68'' AS moniname68 --モニタ項目名68
            ,ntss_db5_mm.monitor_data #>> ''{68}'' AS moniitem68 --モニタ項目値68
            ,''69'' AS moniname69 --モニタ項目名69
            ,ntss_db5_mm.monitor_data #>> ''{69}'' AS moniitem69 --モニタ項目値69
            ,''70'' AS moniname70 --モニタ項目名70
            ,ntss_db5_mm.monitor_data #>> ''{70}'' AS moniitem70 --モニタ項目値70
            ,''71'' AS moniname71 --モニタ項目名71
            ,ntss_db5_mm.monitor_data #>> ''{71}'' AS moniitem71 --モニタ項目値71
            ,''72'' AS moniname72 --モニタ項目名72
            ,ntss_db5_mm.monitor_data #>> ''{72}'' AS moniitem72 --モニタ項目値72
            ,''73'' AS moniname73 --モニタ項目名73
            ,ntss_db5_mm.monitor_data #>> ''{73}'' AS moniitem73 --モニタ項目値73
            ,''74'' AS moniname74 --モニタ項目名74
            ,ntss_db5_mm.monitor_data #>> ''{74}'' AS moniitem74 --モニタ項目値74
            ,''75'' AS moniname75 --モニタ項目名75
            ,ntss_db5_mm.monitor_data #>> ''{75}'' AS moniitem75 --モニタ項目値75
            ,''76'' AS moniname76 --モニタ項目名76
            ,ntss_db5_mm.monitor_data #>> ''{76}'' AS moniitem76 --モニタ項目値76
            ,''77'' AS moniname77 --モニタ項目名77
            ,ntss_db5_mm.monitor_data #>> ''{77}'' AS moniitem77 --モニタ項目値77
            ,''78'' AS moniname78 --モニタ項目名78
            ,ntss_db5_mm.monitor_data #>> ''{78}'' AS moniitem78 --モニタ項目値78
            ,''79'' AS moniname79 --モニタ項目名79
            ,ntss_db5_mm.monitor_data #>> ''{79}'' AS moniitem79 --モニタ項目値79
            ,''80'' AS moniname80 --モニタ項目名80
            ,ntss_db5_mm.monitor_data #>> ''{80}'' AS moniitem80 --モニタ項目値80
            ,''81'' AS moniname81 --モニタ項目名81
            ,ntss_db5_mm.monitor_data #>> ''{81}'' AS moniitem81 --モニタ項目値81
            ,''82'' AS moniname82 --モニタ項目名82
            ,ntss_db5_mm.monitor_data #>> ''{82}'' AS moniitem82 --モニタ項目値82
            ,''83'' AS moniname83 --モニタ項目名83
            ,ntss_db5_mm.monitor_data #>> ''{83}'' AS moniitem83 --モニタ項目値83
            ,''84'' AS moniname84 --モニタ項目名84
            ,ntss_db5_mm.monitor_data #>> ''{84}'' AS moniitem84 --モニタ項目値84
            ,''85'' AS moniname85 --モニタ項目名85
            ,ntss_db5_mm.monitor_data #>> ''{85}'' AS moniitem85 --モニタ項目値85
            ,''86'' AS moniname86 --モニタ項目名86
            ,ntss_db5_mm.monitor_data #>> ''{86}'' AS moniitem86 --モニタ項目値86
            ,''87'' AS moniname87 --モニタ項目名87
            ,ntss_db5_mm.monitor_data #>> ''{87}'' AS moniitem87 --モニタ項目値87
            ,''88'' AS moniname88 --モニタ項目名88
            ,ntss_db5_mm.monitor_data #>> ''{88}'' AS moniitem88 --モニタ項目値88
            ,''89'' AS moniname89 --モニタ項目名89
            ,ntss_db5_mm.monitor_data #>> ''{89}'' AS moniitem89 --モニタ項目値89
            ,''90'' AS moniname90 --モニタ項目名90
            ,ntss_db5_mm.monitor_data #>> ''{90}'' AS moniitem90 --モニタ項目値90
            ,''91'' AS moniname91 --モニタ項目名91
            ,ntss_db5_mm.monitor_data #>> ''{91}'' AS moniitem91 --モニタ項目値91
            ,''92'' AS moniname92 --モニタ項目名92
            ,ntss_db5_mm.monitor_data #>> ''{92}'' AS moniitem92 --モニタ項目値92
            ,''93'' AS moniname93 --モニタ項目名93
            ,ntss_db5_mm.monitor_data #>> ''{93}'' AS moniitem93 --モニタ項目値93
            ,''94'' AS moniname94 --モニタ項目名94
            ,ntss_db5_mm.monitor_data #>> ''{94}'' AS moniitem94 --モニタ項目値94
            ,''95'' AS moniname95 --モニタ項目名95
            ,ntss_db5_mm.monitor_data #>> ''{95}'' AS moniitem95 --モニタ項目値95
            ,''96'' AS moniname96 --モニタ項目名96
            ,ntss_db5_mm.monitor_data #>> ''{96}'' AS moniitem96 --モニタ項目値96
            ,''97'' AS moniname97 --モニタ項目名97
            ,ntss_db5_mm.monitor_data #>> ''{97}'' AS moniitem97 --モニタ項目値97
            ,''98'' AS moniname98 --モニタ項目名98
            ,ntss_db5_mm.monitor_data #>> ''{98}'' AS moniitem98 --モニタ項目値98
            ,''99'' AS moniname99 --モニタ項目名99
            ,ntss_db5_mm.monitor_data #>> ''{99}'' AS moniitem99 --モニタ項目値99
            ,''100'' AS moniname100 --モニタ項目名100
            ,ntss_db5_mm.monitor_data #>> ''{100}'' AS moniitem100 --モニタ項目値100
            ,to_char(ntss_db5_mm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --発生日時
        FROM
            ord_main ntss_db5_om
            LEFT JOIN mst_bed ntss_db5_mst_b
            ON ntss_db5_mst_b.bed_cd = ntss_db5_om.rst_bed_cd
            LEFT JOIN mst_machine ntss_db5_mst_m
            ON cast(ntss_db5_mst_m.machine_no AS integer) = ntss_db5_om.rst_machine_no
            INNER JOIN ntss_db5_mm
            ON ntss_db5_mm.ord_no = ntss_db5_om.ord_no
        WHERE ntss_db5_om.is_del = ''0''
            AND ntss_db5_om.facility_cd = @facilityCd
            AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
            AND to_date( @toDate, ''YYYYMMDDHH24MISS'' );'
WHERE sql_cd = '-2430';


