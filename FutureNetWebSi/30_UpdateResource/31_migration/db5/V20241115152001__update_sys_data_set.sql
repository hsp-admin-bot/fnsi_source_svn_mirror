DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-2010,-2100,-2110,-2190,-2502)
;

INSERT INTO ntss.sys_data_set
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


INSERT INTO ntss.sys_data_set
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


INSERT INTO ntss.sys_data_set
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


INSERT INTO ntss.sys_data_set
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


INSERT INTO ntss.sys_data_set
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
