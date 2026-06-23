DELETE FROM ntss.sys_data_set
WHERE sql_cd IN(-2100,-2051)
;

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
        , ''Kg'' AS unit
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
    , rst_cond_list.unit AS unit            --単位
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
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);



INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2051, 'SELECT
	hosp_pat_id AS hosppatid,
	pat_id AS patid
FROM
	pat_personal_main 
WHERE facility_cd = @facilityCd;', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
