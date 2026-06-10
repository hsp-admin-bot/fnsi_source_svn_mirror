DELETE FROM ntss.sys_data_set
WHERE sql_cd IN(-2100,-2051)
;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2100, '-- 【SQL_CD=-2100】
WITH ntss_db5_om_temp AS NOT MATERIALIZED (
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
        , rst_cond_info_json.value::JSON ->> ''value'' AS value
        , rst_cond_info_json.value::JSON ->> ''value_name_1'' AS value_name_1
        , rst_cond_info_json.value::JSON ->> ''unit'' AS unit
        , '''' AS valuecd2
        , rst_cond_info_json.value::JSON ->> ''medicine_type'' AS medicine_type
    FROM
        ntss_db5_om_temp
        CROSS JOIN lateral json_each_text(ntss_db5_om_temp.rst_cond_info::JSON) rst_cond_info_json
    WHERE
        rst_cond_info_json.key IN(''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'',''12'',''14'',''15'',''16'',''17'',''18'',''19'',''20'',''21'',''22'',''23'',''24'',''25'',''26'',''27'',''28'',''29'',''30'',''31'',''32'',''33'',''34'',''35'',''36'',''37'',''38'')
    UNION ALL
    SELECT --dw
        ntss_db5_om_temp.ord_no
        , ''992'' AS key
        , CAST(ntss_db5_om_temp.rst_dw AS text) AS value
        , '''' AS value_name_1
        , ''Kg'' AS unit
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
    , rst_cond_list.unit AS unit            --単位
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
VALUES(-2051, 'SELECT
	hosp_pat_id AS hosppatid,
	pat_id AS patid
FROM
	pat_personal_main 
WHERE facility_cd = @facilityCd;', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
