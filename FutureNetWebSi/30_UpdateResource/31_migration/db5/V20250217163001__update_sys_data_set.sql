DELETE FROM sys_data_set WHERE sql_cd IN(-30, -201, -102, -600202);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-30, 'WITH pkg_info AS ( 
    SELECT
        info ->> ''key0'' AS pkg_name 
    FROM
        mst_coop_facility 
        CROSS JOIN LATERAL json_array_elements((common_setting ->> ''coop_ord_cd'') ::json) AS info 
    WHERE
        is_del = ''0''
        AND is_disp = ''1'' 
        AND facility_cd = @facilityCd 
        AND info ->> ''coop_cd'' ::TEXT = ''ini_dial'' 
        AND ( 
            info ->> ''coop_version'' IS NULL 
            OR info ->> ''coop_version'' = @coopVersion
        ) 
    LIMIT
        1
) 
, reg_date_info AS ( 
    SELECT
        reg_date 
    FROM
        ord_coop_no 
    WHERE
        ord_no = @ordNo 
        AND ord_no > 0 
        AND facility_cd = @facilityCd 
        AND coop_version = @coopVersion 
        AND pat_id = @patId 
        AND coop_cd = ( 
            SELECT
                coop_cd 
            FROM
                sys_coop_journal 
            WHERE
                ctl_no = @ctlNo
        ) 
    ORDER BY
        reg_date DESC 
    LIMIT
        1
) 
SELECT
    save_2 ->> ''ord_no'' ::TEXT AS ord_no
    , save_2 ->> ''insu_no'' ::TEXT AS insu_no 
FROM
    pat_coop_detail 
WHERE
    pat_id = @patId 
    AND facility_cd = @facilityCd 
    AND coop_version = @coopVersion 
    AND is_disp = ''1'' 
    AND is_del = ''0'' 
    AND save_1 ->> ''pkg'' ::TEXT = (SELECT pkg_name FROM pkg_info) 
    AND ( 
        ( 
            (SELECT reg_date FROM reg_date_info) IS NOT NULL 
            AND reg_date <= (SELECT reg_date FROM reg_date_info)
        ) 
        OR (SELECT reg_date FROM reg_date_info) IS NULL
    ) 
ORDER BY
    reg_date DESC 
LIMIT
    1

', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, '患者連携情報(受信オーダ番号、保険パターン)取得', '2023-06-16 19:03:16.917', CURRENT_TIMESTAMP, NULL);

INSERT INTO sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-201, 'WITH trend_interval_value AS (
    SELECT
        COALESCE(info->>''value'', info->>''default_v'') AS trend_value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        1 = 1
        AND is_del = ''0''
        AND facility_cd = @facilityCd
        AND info->>''key1'' = ''NEC_MSTVAITALSEND''
        AND info->>''key0'' = ''HR''
        AND info->>''key2'' = ''TREND_INTERVAL''
        AND (info->>''value'' IS NOT NULL OR info->>''default_v'' IS NOT NULL)
)
,coop_ini_extracted AS (
    SELECT
        COALESCE(info->>''value'', info->>''default_v'') AS trend_value,
        info->>''value'' AS value,
        info->>''default_v'' AS default_v,
        CASE
            WHEN info->>''key2'' = ''BP_MAX_VAITAL_CD'' THEN ''90''
            WHEN info->>''key2'' = ''BP_MIN_VAITAL_CD'' THEN ''91''
            WHEN info->>''key2'' = ''PULSE_VAITAL_CD'' THEN ''93''
            WHEN info->>''key2'' = ''TEMPERATURE_VAITAL_CD'' THEN ''94''
            WHEN info->>''key2'' = ''ELAPSED_TIME_VAITAL_CD'' THEN ''1''
            WHEN info->>''key2'' = ''TREAT_MODE_VAITAL_CD'' THEN ''31''
            WHEN info->>''key2'' = ''BLOOD_FLOW_VAITAL_CD'' THEN ''36''
            WHEN info->>''key2'' = ''OFFWATER_SPEED_VAITAL_CD'' THEN ''33''
            WHEN info->>''key2'' = ''OFFWATER_ADD_VAITAL_CD'' THEN ''5''
            WHEN info->>''key2'' = ''OFFWATER_TERGET_VAITAL_CD'' THEN ''32''
            WHEN info->>''key2'' = ''VENOUS_PRESSURE_VAITAL_CD'' THEN ''11''
            WHEN info->>''key2'' = ''DIALYSATE_PRESSURE_VAITAL_CD'' THEN ''12''
            WHEN info->>''key2'' = ''TMP_VAITAL_CD'' THEN ''13''
            WHEN info->>''key2'' = ''IP_TOTAL_AMOUNT_VAITAL_CD'' THEN ''9''
            WHEN info->>''key2'' = ''IP_SPEED_VAITAL_CD'' THEN ''37''
            WHEN info->>''key2'' = ''DIALYSATE_TEMPERATURE_VAITAL_CD'' THEN ''21''
            WHEN info->>''key2'' = ''NA_CONCENTRATION_VAITAL_CD'' THEN ''20''
            WHEN info->>''key2'' = ''DIALYSATE_FLOW_VAITAL_CD'' THEN ''22''
            WHEN info->>''key2'' = ''REPLENISH_SPEED_VAITAL_CD'' THEN ''73''
            WHEN info->>''key2'' = ''REPLENISH_VALUE_VAITAL_CD'' THEN ''72''
            WHEN info->>''key2'' = ''REPLENISH_TEMPERATURE_VAITAL_CD'' THEN ''74''
            WHEN info->>''key2'' = ''DELTA_BV_VAITAL_CD'' THEN ''17''
            WHEN info->>''key2'' = ''DELTA_BV_CHANGE_RATE_CD'' THEN ''80''
            WHEN info->>''key2'' = ''WEIGHT_BEFORE_VAITAL_CD'' THEN ''WEIGHT_BEFORE_VAITAL_CD''
            WHEN info->>''key2'' = ''WEIGHT_AFTER_VAITAL_CD'' THEN ''WEIGHT_AFTER_VAITAL_CD''
            ELSE NULL
        END AS target_key
    FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        1 = 1
        AND is_del = ''0''
        AND facility_cd = @facilityCd
        AND info->>''key1'' = ''NEC_MSTVAITALSEND''
        AND info->>''key0'' = ''HR''
        AND (info->>''value'' IS NOT NULL OR info->>''default_v'' IS NOT NULL)
        AND COALESCE(NULLIF(info->>''value'', ''''), NULL) IS NOT NULL
)
,query_1_processed AS (
    SELECT
        ''vital'' AS detail_id,
        COALESCE(vit_ini.value, vit_ini.default_v) AS vital_cd,
        CASE
            WHEN to_number(vit_ini.target_key, ''999'') IN (94)
                THEN TO_CHAR(CAST(monitor_data->>vit_ini.target_key AS NUMERIC), ''FM999999999.0'')
            ELSE
                monitor_data->>vit_ini.target_key
        END AS vital_data,
        to_char(occur_date, ''YYYYMMDDHH24MI'') AS occur_date,
        vital_all.occur_date AS occur_time_with_sec
    FROM (
        SELECT
            occur_date,
            monitor_data
        FROM
            mni_monitor
        WHERE
            1 = 1
            AND ord_no = @ordNo
            AND data_type IN (0, 2, 4, 5, 6)
            AND is_del = ''0''
    ) AS vital_all
    CROSS JOIN LATERAL (
        SELECT
            value,
            default_v,
            target_key
        FROM
            coop_ini_extracted
        WHERE
            1 = 1
            AND target_key IS NOT NULL
    ) AS vit_ini
    WHERE
        1 = 1
        AND vit_ini.target_key IS NOT NULL
        AND COALESCE(NULLIF(monitor_data->>vit_ini.target_key, ''''), NULL) IS NOT NULL
)
,query_1_ranked AS (
    SELECT
        detail_id,
        vital_cd,
        vital_data,
        occur_date,
        occur_time_with_sec,
        ROW_NUMBER() OVER (
            PARTITION BY vital_cd, occur_date
            ORDER BY occur_time_with_sec DESC
        ) AS rank_within_time
    FROM
        query_1_processed
)
,query_1_filled AS (
    SELECT
        detail_id,
        vital_cd,
        occur_date,
        occur_time_with_sec,
        FIRST_VALUE(vital_data) OVER (
			PARTITION BY vital_cd, occur_time_with_sec 
            ORDER BY occur_time_with_sec DESC 
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS vital_data
    FROM query_1_ranked
    WHERE rank_within_time = 1
    ORDER BY occur_date ASC , vital_cd ASC
)
,query_1_final AS (
    SELECT
        occur_date,
        detail_id,
        vital_cd,
        vital_data,
        occur_time_with_sec
    FROM query_1_filled
    ORDER BY occur_date, vital_cd
)
, query_2 AS (
    SELECT
    	to_char((ord.rst_weight_info->>''weight_before_date'')::timestamp, ''YYYYMMDDHH24MI'') AS bw_date,
        (ord.rst_weight_info->>''weight_before_date'')::timestamp(3) AS bw_date_with_sec,
        ''vital'' AS detail_id,
        COALESCE(vit_ini.value, vit_ini.default_v) AS bw_cd,
        TO_CHAR(CAST(ord.rst_weight_info->>''weight_before'' AS NUMERIC), ''FM999999999.00'') AS bw_w
    FROM
        ord_main ord
    CROSS JOIN LATERAL (
        SELECT
            value,
            default_v
        FROM
            coop_ini_extracted
        WHERE
            target_key = ''WEIGHT_BEFORE_VAITAL_CD''
    ) AS vit_ini
    WHERE
        ord.ord_no = @ordNo
        AND COALESCE(ord.rst_weight_info->>''weight_before_date'', ''NODATE'') <> ''NODATE''
)
,query_3 AS (
    SELECT
    	to_char((ord.rst_weight_info->>''weight_after_date'')::timestamp, ''YYYYMMDDHH24MI'') AS aw_date,
        (ord.rst_weight_info->>''weight_after_date'')::timestamp(3) AS aw_date_with_sec,
        ''vital'' AS detail_id,
        COALESCE(vit_ini.value, vit_ini.default_v) AS aw_cd,
        TO_CHAR(CAST(ord.rst_weight_info->>''weight_after'' AS NUMERIC), ''FM999999999.00'') AS aw_w        
    FROM
        ord_main ord
    CROSS JOIN LATERAL (
        SELECT
            value,
            default_v
        FROM
            coop_ini_extracted
        WHERE
            target_key = ''WEIGHT_AFTER_VAITAL_CD''
    ) AS vit_ini
    WHERE
        ord.ord_no = @ordNo
        AND COALESCE(ord.rst_weight_info->>''weight_after_date'', ''NODATE'') <> ''NODATE''
)
, query_4_base AS (
    SELECT
        to_char(occur_date, ''YYYYMMDDHH24MI'') AS occur_date,
        occur_date AS occur_time_with_sec, 
        monitor_data,
        MAX(occur_date) OVER () AS max_occur_time_with_sec
    FROM
        mni_monitor
    WHERE
        ord_no = @ordNo
        AND data_type = 1
        AND is_del = ''0''
)

, query_4_filtered AS (
    SELECT
        occur_date,
        occur_time_with_sec,
        monitor_data
    FROM
        query_4_base
    WHERE
        occur_time_with_sec <> max_occur_time_with_sec
)

, query_4_deduplicated AS (
    SELECT
        occur_date,
        occur_time_with_sec,
        monitor_data
    FROM (
        SELECT
            occur_date,
            occur_time_with_sec,
            monitor_data,
            ROW_NUMBER() OVER (
                PARTITION BY to_number(monitor_data->>''1'', ''999'')
                ORDER BY occur_time_with_sec ASC
            ) AS rank_within_value
        FROM query_4_filtered
    ) AS ranked
    WHERE rank_within_value = 1
)

, query_4_interval AS (
    SELECT
        ''vital'' AS detail_id,
        COALESCE(vit_ini.value, vit_ini.default_v) AS vital_cd,
        CASE
            WHEN to_number(vit_ini.target_key, ''999'') IN (5, 32, 33, 73) 
                THEN TO_CHAR(CAST(monitor_data->>vit_ini.target_key AS NUMERIC), ''FM999999999.00'')
            WHEN to_number(vit_ini.target_key, ''999'') IN (9, 17, 37, 60, 72, 74, 80) 
                THEN TO_CHAR(CAST(monitor_data->>vit_ini.target_key AS NUMERIC), ''FM999999999.0'')
            WHEN vit_ini.target_key = ''31'' 
                THEN CASE
                    WHEN monitor_data->>vit_ini.target_key = ''0'' THEN ''HD''
                    WHEN monitor_data->>vit_ini.target_key = ''1'' THEN ''ECUM''
                    WHEN monitor_data->>vit_ini.target_key = ''2'' THEN ''ｵﾌﾗｲﾝHDF''
                    WHEN monitor_data->>vit_ini.target_key = ''3'' THEN ''ｵﾌﾗｲﾝHF''
                    WHEN monitor_data->>vit_ini.target_key = ''6'' THEN ''AFBF''
                    WHEN monitor_data->>vit_ini.target_key = ''7'' THEN ''ｵﾝﾗｲﾝHDF''
                    WHEN monitor_data->>vit_ini.target_key = ''8'' THEN ''ｵﾝﾗｲﾝHF''
                    WHEN monitor_data->>vit_ini.target_key = ''10'' THEN ''IHDF''
                    ELSE monitor_data->>vit_ini.target_key
                END
            ELSE 
                monitor_data->>vit_ini.target_key
        END AS vital_data,
        monitor_data,
        occur_date,
        occur_time_with_sec
    FROM
        query_4_deduplicated
    CROSS JOIN LATERAL (
        SELECT
            value,
            default_v,
            target_key
        FROM
            coop_ini_extracted
        WHERE
            target_key IS NOT NULL
    ) AS vit_ini
    JOIN trend_interval_value ON TRUE
    WHERE
        to_number(monitor_data->>''1'', ''999'') >= 0
        AND (to_number(monitor_data->>''1'', ''999'') % trend_interval_value.trend_value::numeric = 0)
        AND COALESCE(NULLIF(monitor_data->>vit_ini.target_key, ''''), NULL) IS NOT NULL
)

,query_4_sorted AS (
    SELECT
        detail_id, 
        vital_cd, 
        vital_data, 
        occur_date, 
        monitor_data,
        occur_time_with_sec
    FROM (
        SELECT
            *,
            DENSE_RANK() OVER (PARTITION BY monitor_data->>''1'' ORDER BY occur_time_with_sec ASC) AS rank_within_value
        FROM query_4_interval
    ) AS ranked
    WHERE rank_within_value = 1
    ORDER BY occur_date, vital_cd
)
,all_queries_combined AS (
    SELECT occur_time_with_sec, ''query_1'' AS query_type FROM query_1_final
    UNION ALL
    SELECT bw_date_with_sec AS occur_time_with_sec, ''query_2'' AS query_type FROM query_2
    UNION ALL
    SELECT aw_date_with_sec AS occur_time_with_sec, ''query_3'' AS query_type FROM query_3
    UNION ALL
    SELECT occur_time_with_sec, ''query_4'' AS query_type FROM query_4_sorted
)

,all_queries_combined_with_id AS (
    SELECT *,
           ROW_NUMBER() OVER (ORDER BY query_type ASC, occur_time_with_sec ASC) AS event_id
    FROM all_queries_combined
    ORDER BY event_id ASC
)

,excluded_occur_times AS (
    SELECT DISTINCT occur_time_with_sec
    FROM all_queries_combined_with_id
    WHERE event_id > 999
)
SELECT occur_date, detail_id, vital_cd, vital_data 
FROM query_1_final 
WHERE occur_time_with_sec NOT IN (SELECT occur_time_with_sec FROM excluded_occur_times)

UNION ALL

SELECT bw_date, detail_id, bw_cd, bw_w 
FROM query_2
WHERE bw_date_with_sec NOT IN (SELECT occur_time_with_sec FROM excluded_occur_times)

UNION ALL

SELECT aw_date, detail_id, aw_cd, aw_w 
FROM query_3
WHERE aw_date_with_sec NOT IN (SELECT occur_time_with_sec FROM excluded_occur_times)

UNION ALL

SELECT occur_date, detail_id, vital_cd, vital_data 
FROM query_4_sorted
WHERE occur_time_with_sec NOT IN (SELECT occur_time_with_sec FROM excluded_occur_times)', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'NEC)バイタル繰り返し部', '2024-11-26 14:03:54.146', CURRENT_TIMESTAMP, NULL);


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-102, 'WITH coop_ini_info AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
        , info ->> ''key2'' AS key2
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''NEC''
)
, ord_main_switch AS(
(
    SELECT
        ord.rst_edition_date as up_date_switch,
        ord.ord_no,
        ord.rst_bed_cd,
        ord.up_ind_user_id,
        ord.up_user_id
    FROM
        ord_main ord
    WHERE
        ord.ord_no = @ordNo
)
UNION
    (
        SELECT
        ord.del_date as up_date_switch,
        ord.ord_no,
        ord.rst_bed_cd,
        ord.up_ind_user_id,
        ord.up_user_id
        FROM
            ord_main_restore AS ord
            JOIN sys_coop_journal AS journal ON ord.ord_no = journal.ord_no
        WHERE
            ord.ord_no = @ordNo
            AND journal.ctl_no = @ctlNo
            AND ord.ord_no = journal.ord_no
            AND journal.reg_date >= ord.del_date
        ORDER BY
            del_date DESC
        LIMIT 1
    )
ORDER BY
      up_date_switch DESC NULLS LAST
LIMIT 1
)
, get_course AS ( --指示科取得先設定
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''GET_COURSE''
)
, def_course AS ( --デフォルト指示科
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''DEF_COURSE''
)
, get_XMLGEN_obj_type AS ( --データ種別
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''XMLGEN_OBJ_TYP''
)
, get_XMLGEN_cd as ( -- システム識別子
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''XMLGEN_SYSTEM_CODE''
)
, get_XMLGEN_hosp_cd as ( -- 施設コード
    SELECT btrim(value) as value
    FROM coop_ini_info
    WHERE key2 = ''XMLGEN_HOSP_CODE''
)
,bed_code_conv as (
    SELECT *
    FROM coop_ini_info 
    WHERE key2 = ''BED_CODE_CONV''
)
, get_bed_mst as ( -- ベッドマスタ
    SELECT
    bed_cd as bed_cd ,
    CASE (SELECT value FROM bed_code_conv)
        WHEN ''1'' THEN in_hospital_cd_1
        WHEN ''2'' THEN in_hospital_cd_2
		END AS in_hospital_cd
    FROM mst_bed
    WHERE facility_cd = @facilityCd
    AND bed_cd = (SELECT ind_bed_cd FROM ord_main WHERE ord_no = @ordNo)
)
, ind_nec_bed_course AS ( --ベッド番号・科コード対応(指示)
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''NEC_BED_COURSE''
        AND info ->> ''key2'' = (SELECT in_hospital_cd FROM get_bed_mst)::text
)
, rst_nec_bed_cd AS (
    SELECT
    bed_cd AS bed_cd ,
    CASE (SELECT value FROM bed_code_conv)
        WHEN ''1'' THEN in_hospital_cd_1
        WHEN ''2'' THEN in_hospital_cd_2
		END AS in_hospital_cd
    FROM mst_bed
    WHERE facility_cd = @facilityCd
    AND bed_cd = (SELECT rst_bed_cd FROM ord_main WHERE ord_no = @ordNo)
)
, rst_nec_bed_course AS ( --ベッド番号・科コード対応(実績)
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''NEC_BED_COURSE''
        AND info ->> ''key2'' = (SELECT in_hospital_cd FROM rst_nec_bed_cd)
)
, rst_del_nec_bed_cd AS (
        SELECT
            rst_bed_cd AS rst_bed_cd
            , CASE (SELECT value FROM bed_code_conv)
                WHEN ''1'' THEN mb.in_hospital_cd_1
                WHEN ''2'' THEN mb.in_hospital_cd_2
                END AS in_hospital_cd
        FROM ord_main_switch AS ord
        CROSS JOIN sys_coop_journal AS journal
        LEFT JOIN mst_bed mb ON rst_bed_cd = mb.bed_cd
        WHERE
            ord.ord_no = @ordNo
            AND journal.ctl_no = @ctlNo
            AND ord.ord_no = journal.ord_no
)
, rst_del_nec_bed_course AS ( --ベッド番号・科コード対応(実績_削除時)
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''NEC_BED_COURSE''
        AND info ->> ''key2'' = (SELECT in_hospital_cd FROM rst_del_nec_bed_cd)::text
)
, get_doctor AS ( --指示医取得設定
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''GET_DOCTOR''
)
, def_doctor AS ( --デフォルト指示医
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''DEF_DOCTOR''
)
, dialysis_course_cd AS ( --透析実施科
    SELECT
        mc.in_hospital_cd_1 AS dialysis_course_cd
    FROM pat_main pm
    LEFT JOIN mst_course mc
    ON pm.medical_care_info ->> ''dialysis_course_cd'' = mc.course_cd::text
    AND mc.facility_cd = @facilityCd
    WHERE pm.facility_cd = @facilityCd
    AND pm.pat_id = @patId
    AND pm.is_del = ''0''
)
, staff_cd_list AS ( --担当医1,2
    SELECT
        users ->> ''disp_user_id'' AS disp_user_id
        , users ->> ''user_id'' AS user_id
        , row_number() OVER(ORDER BY values ->> ''disp_order'') AS row_no
    FROM pat_main pm
    CROSS JOIN jsonb_array_elements(pm.charge_staff_info) AS values
    LEFT JOIN jsonb_array_elements(@userList) AS users
    ON values ->> ''staff_cd'' = users ->> ''user_id''
    WHERE pm.facility_cd = @facilityCd
    AND pm.pat_id = @patId
    AND pm.is_del = ''0''
    AND values ->> ''is_main'' = ''1''
)
,up_ind_user_id AS ( --最終更新指示者の表示用ID
    SELECT
        users ->> ''disp_user_id'' AS disp_user_id
    FROM ord_main_switch ord
    LEFT JOIN jsonb_array_elements(@userList) AS users
    ON ord.up_ind_user_id::text = users ->> ''user_id''
    WHERE ord.ord_no = @ordNo
)
,up_user_id AS ( --最終更新者の表示用ID
    SELECT
        users ->> ''disp_user_id'' AS disp_user_id
    FROM ord_main_switch ord
    LEFT JOIN jsonb_array_elements(@userList) AS users
    ON ord.up_user_id::text = users ->> ''user_id''
    WHERE ord.ord_no = @ordNo
)
, ind_send_doctor_v1 AS ( --詳細指示連携で送信した指示医
    SELECT
        encode(substring(scj.dump from 163 for 10), ''escape'') AS ind_doctor
        , accept_no
    FROM
        sys_coop_journal scj
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND pat_id = @patId
        AND ord_no = @ordNo
        AND coop_cd = ''ind_dial''
    UNION
    SELECT
        ''          '' AS ind_doctor
        , 0 AS accept_no
    ORDER BY
        accept_no DESC LIMIT 1
)
, ind_send_doctor_v2 AS ( --詳細指示連携で送信した指示医
    SELECT
        encode(substring(scj.dump from 131 for 10), ''escape'') AS ind_doctor
        , accept_no
    FROM
        sys_coop_journal scj
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND pat_id = @patId
        AND ord_no = @ordNo
        AND coop_cd = ''ind_dial''
    UNION
    SELECT
        ''          '' AS ind_doctor
        , 0 AS accept_no
    ORDER BY
        accept_no DESC LIMIT 1
)
, def_update_terminal AS ( --デフォルト更新端末
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''DEF_UPDATE_TERMINAL''
)
, medicine_coop_cd_no AS (
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''MEDICINE_COOP_CD_NO''
)
, own_expense_medicine_code_list AS (
    SELECT unnest(string_to_array(value, '','')) AS split_cd
    FROM coop_ini_info
    WHERE key2 = ''OWN_EXPENSE_MEDICINE_CODE''
)
, get_XMLGEN_title_cd AS ( -- タイトル識別コード
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''XMLGEN_TITLE_CODE''
)
, get_XMLGEN_title_name AS ( -- タイトル識別名称
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''XMLGEN_TITLE_NAME''
)
, get_XMLGEN_fs_disp AS ( -- フローシート表示文字列
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''XMLGEN_FS_DISP''
)
, get_XMLGEN_content_number AS ( -- 識別番号
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''XMLGEN_CONTENT_NUMBER''
)
, get_XMLGEN_content_type AS ( -- コンテンツタイプ
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''XMLGEN_CONTENT_TYPE''
)
, get_XMLGEN_extent_name AS ( -- 拡張子
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''XMLGEN_EXTENT_NAME''
)
, get_XMLGEN_device_name AS ( -- デバイス名
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''XMLGEN_DEVICE_NAME''
)
, get_XMLGEN_ip_address AS ( -- IPアドレス
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''XMLGEN_IP_ADDRESS''
)
, medicine_order as (
    SELECT
    t.value ->> ''code'' AS cd
    , t.idx AS idx
    FROM mst_selector ms
    CROSS JOIN jsonb_array_elements(ms.order_settings -> ''items'') WITH ORDINALITY AS t(value,idx)
    WHERE ms.facility_cd =@facilityCd
    AND ms.master_physical_name = ''mst_medicine''
)
, own_expense_medicine_code AS (
    SELECT
    CASE (SELECT value FROM medicine_coop_cd_no)
        WHEN ''1'' THEN mmd.in_hospital_cd_1
        WHEN ''2'' THEN mmd.in_hospital_cd_2
        WHEN ''3'' THEN mmd.in_hospital_cd_3
        WHEN ''4'' THEN mmd.in_hospital_cd_4
        END AS own_med_cd
    , mco.idx AS idx
    from own_expense_medicine_code_list oemc
    inner JOIN mst_medicine mmd
    ON (CASE (SELECT value FROM medicine_coop_cd_no)
        WHEN ''1'' THEN mmd.in_hospital_cd_1 = oemc.split_cd
        WHEN ''2'' THEN mmd.in_hospital_cd_2 = oemc.split_cd
        WHEN ''3'' THEN mmd.in_hospital_cd_3 = oemc.split_cd
        WHEN ''4'' THEN mmd.in_hospital_cd_4 = oemc.split_cd
        END)
    LEFT JOIN medicine_order mco
    ON mmd.medicine_cd::text = mco.cd
    UNION
    SELECT '''' AS own_med_cd, 0 AS idx
)
, orderreqsend_start_end_flg AS ( --開始日終了日設定フラグ 
    SELECT *
    FROM coop_ini_info
    WHERE key2 = ''ORDERREQSEND_START_END_FLG''
)
SELECT
    pcd.save_2->>''ord_no'' as ord_no,
    pcd.save_2->>''updater'' as updater,
    pcd.save_2->>''addition'' as addition,
    pcd.save_2->>''dialysis_type'' as dialysis_type,
    pcd.save_2->>''dialysis_course'' as dialysis_course,
    pcd.save_2->>''update_terminal'' as update_terminal,
    pcd.save_2->>''dialysis_pattern'' as dialysis_pattern,
    CASE
    WHEN (SELECT value FROM orderreqsend_start_end_flg) = ''0'' and ''D'' = @crud THEN ''''
    ELSE pcd.save_2->>''end_date_regular''
    END as end_date_regular,
    pcd.save_2->>''insurance_code_01'' as insurance_code_01,
    pcd.save_2->>''insurance_code_02'' as insurance_code_02,
    pcd.save_2->>''insurance_code_03'' as insurance_code_03,
    pcd.save_2->>''instruction_doctor'' as instruction_doctor,
    CASE
    WHEN (SELECT value FROM orderreqsend_start_end_flg) = ''0'' and ''D'' = @crud THEN ''''
    ELSE pcd.save_2->>''start_date_regular''
    END as start_date_regular,
    pcd.save_2->>''implementation_place'' as implementation_place,
    pcd.save_2->>''updater_generation_no'' as updater_generation_no,
    pcd.save_2->>''addition_generation_no'' as addition_generation_no,
    pcd.save_2->>''instruction_department'' as instruction_department,
    pcd.save_2->>''blood_purification_method'' as blood_purification_method,
    pcd.save_2->>''blood_purification_generation_no'' as blood_purification_generation_no,
    pcd.save_2->>''instruction_doctor_generation_no'' as instruction_doctor_generation_no,
    pcd.save_2->>''kur_cd1'' as kur_cd1,
    pcd.save_2->>''va3'' as va3,
    pcd.save_2->>''va_direct'' as va_direct,
    pcd.save_2->>''dw'' as dw,
    --ind_dial_V1_指示科_指示医_指示医世代番号取得
    CASE (SELECT value FROM get_course)
        WHEN ''0'' THEN COALESCE(NULLIF(pcd.save_2->>''instruction_department'', ''''), (SELECT value FROM def_course))
        WHEN ''1'' THEN COALESCE(NULLIF((SELECT dialysis_course_cd FROM dialysis_course_cd), ''''), (SELECT value FROM def_course))
        WHEN ''2'' THEN COALESCE(NULLIF((SELECT value FROM ind_nec_bed_course), ''''), (SELECT value FROM def_course))
        END AS ind_course,
    CASE (SELECT value FROM get_doctor)
        WHEN ''0'' THEN COALESCE(
            NULLIF(pcd.save_2->>''instruction_doctor'', ''''), (SELECT value FROM def_doctor))
        WHEN ''1'' THEN COALESCE(
            NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 1), '''')
            , NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 2), '''')
            , (SELECT value FROM def_doctor))
        WHEN ''2'' THEN COALESCE(
            NULLIF((SELECT disp_user_id FROM up_ind_user_id), '''')
            , NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 1), '''')
            , NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 2), '''')
            , (SELECT value FROM def_doctor))
        END AS ind_doctor,
    CASE (SELECT value FROM get_doctor)
        WHEN ''0'' THEN COALESCE(NULLIF(pcd.save_2->>''instruction_doctor_generation_no'', ''''), ''0'')
        WHEN ''1'' THEN ''0''
        WHEN ''2'' THEN ''0''
        END AS ind_doctor_generation_no,
    --rst_dial_V1_実施診療科_実施医師_実施医師世代番号取得
    CASE (SELECT value FROM get_course)
        WHEN ''0'' THEN COALESCE(NULLIF(pcd.save_2->>''instruction_department'', ''''), (SELECT value FROM def_course))
        WHEN ''1'' THEN COALESCE(NULLIF((SELECT dialysis_course_cd FROM dialysis_course_cd), ''''), (SELECT value FROM def_course))
        WHEN ''2'' THEN COALESCE(NULLIF((SELECT value FROM rst_nec_bed_course), ''''), (SELECT value FROM def_course))
        END AS rst_course,
    CASE (SELECT value FROM get_course)
        WHEN ''0'' THEN COALESCE(NULLIF(pcd.save_2->>''instruction_department'', ''''), (SELECT value FROM def_course))
        WHEN ''1'' THEN COALESCE(NULLIF((SELECT dialysis_course_cd FROM dialysis_course_cd), ''''), (SELECT value FROM def_course))
        WHEN ''2'' THEN COALESCE(NULLIF((SELECT value FROM rst_del_nec_bed_course), ''''), (SELECT value FROM def_course))
        ELSE NULL
        END AS rst_del_course,
    CASE (SELECT value FROM get_doctor)
        WHEN ''0'' THEN COALESCE(NULLIF(pcd.save_2->>''instruction_doctor'', ''''), (SELECT value FROM def_doctor))
        WHEN ''1'' THEN COALESCE(NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 1), ''''), NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 2), ''''), (SELECT value FROM def_doctor))
        WHEN ''2'' THEN COALESCE(NULLIF((SELECT ind_doctor FROM ind_send_doctor_v1), ''          ''), (SELECT value FROM def_doctor))
        END AS rst_doctor_v1,
    CASE (SELECT value FROM get_doctor)
        WHEN ''0'' THEN COALESCE(NULLIF(pcd.save_2->>''instruction_doctor'', ''''), (SELECT value FROM def_doctor))
        WHEN ''1'' THEN COALESCE(NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 1), ''''), NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 2), ''''), (SELECT value FROM def_doctor))
        WHEN ''2'' THEN COALESCE(NULLIF((SELECT ind_doctor FROM ind_send_doctor_v2), ''          ''), (SELECT value FROM def_doctor))
        END AS rst_doctor_v2,
    CASE (SELECT value FROM get_doctor)
        WHEN ''0'' THEN COALESCE(NULLIF(pcd.save_2->>''instruction_doctor_generation_no'', ''''), ''0'')
        WHEN ''1'' THEN ''0''
        WHEN ''2'' THEN ''0''
        END AS rst_doctor_generation_no,
    '''' AS own_medi_code,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_obj_type), '''')) as obj_type,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_cd), '''')) as xml_Cd,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_hosp_cd), '''')) as hosp_Cd,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_title_cd), '''')) as title_cd,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_title_name), '''')) as title_name,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_fs_disp), '''')) as fs_disp,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_content_number), '''')) as content_number,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_content_type), '''')) as content_type,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_extent_name), '''')) as extent_name,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_device_name), '''')) as device_name,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_ip_address), '''')) as ip_address
FROM
    pat_coop_detail pcd
WHERE
    pcd.pat_id = @patId
    AND is_del = ''0''
-- add 2023-01-17 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    AND coop_version = @coopVersion
-- add 2023-01-17 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    AND ''1'' = @messageType
UNION
SELECT
    pcd.save_2->>''ord_no'' as ord_no,
    (SELECT disp_user_id FROM up_user_id) as updater,
    pcd.save_2->>''addition'' as addition,
    pcd.save_2->>''dialysis_type'' as dialysis_type,
    pcd.save_2->>''dialysis_course'' as dialysis_course,
    (SELECT value FROM def_update_terminal) as update_terminal,
    pcd.save_2->>''dialysis_pattern'' as dialysis_pattern,
    CASE
    WHEN (SELECT value FROM orderreqsend_start_end_flg) = ''0'' and ''D'' = @crud THEN ''''
    ELSE pcd.save_2->>''end_date_regular''
    END as end_date_regular,
    pcd.save_2->>''insurance_code_01'' as insurance_code_01,
    pcd.save_2->>''insurance_code_02'' as insurance_code_02,
    pcd.save_2->>''insurance_code_03'' as insurance_code_03,
    pcd.save_2->>''instruction_doctor'' as instruction_doctor,
    CASE
    WHEN (SELECT value FROM orderreqsend_start_end_flg) = ''0'' and ''D'' = @crud THEN ''''
    ELSE pcd.save_2->>''start_date_regular''
    END as start_date_regular,
    pcd.save_2->>''implementation_place'' as implementation_place,
    pcd.save_2->>''updater_generation_no'' as updater_generation_no,
    pcd.save_2->>''addition_generation_no'' as addition_generation_no,
    pcd.save_2->>''instruction_department'' as instruction_department,
    pcd.save_2->>''blood_purification_method'' as blood_purification_method,
    pcd.save_2->>''blood_purification_generation_no'' as blood_purification_generation_no,
    pcd.save_2->>''instruction_doctor_generation_no'' as instruction_doctor_generation_no,
    pcd.save_2->>''kur_cd1'' as kur_cd1,
    pcd.save_2->>''va3'' as va3,
    pcd.save_2->>''va_direct'' as va_direct,
    pcd.save_2->>''dw'' as dw,
    --ind_dial_V2_指示科_指示医_指示医世代番号取得
    CASE (SELECT value FROM get_course)
        WHEN ''0'' THEN ''''
        WHEN ''1'' THEN COALESCE(NULLIF((SELECT dialysis_course_cd FROM dialysis_course_cd), ''''), (SELECT value FROM def_course))
        WHEN ''2'' THEN COALESCE(NULLIF((SELECT value FROM ind_nec_bed_course), ''''), (SELECT value FROM def_course))
        END AS ind_course,
    CASE (SELECT value FROM get_doctor)
        WHEN ''0'' THEN NULL
        WHEN ''1'' THEN COALESCE(
            NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 1), '''')
            , NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 2), '''')
            , (SELECT value FROM def_doctor))
        WHEN ''2'' THEN COALESCE(
            NULLIF((SELECT disp_user_id FROM up_ind_user_id), '''')
            , NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 1), '''')
            , NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 2), '''')
            , (SELECT value FROM def_doctor))
        END AS ind_doctor,
    ''0'' AS ind_doctor_generation_no,
    --rst_dial_V2_実施診療科_実施医師_実施医師世代番号取得
    CASE (SELECT value FROM get_course)
        WHEN ''0'' THEN ''''
        WHEN ''1'' THEN COALESCE(NULLIF((SELECT dialysis_course_cd FROM dialysis_course_cd), ''''), (SELECT value FROM def_course))
        WHEN ''2'' THEN COALESCE(NULLIF((SELECT value FROM rst_nec_bed_course), ''''), (SELECT value FROM def_course))
        END AS rst_course,
    CASE (SELECT value FROM get_course)
        WHEN ''0'' THEN ''''
        WHEN ''1'' THEN COALESCE(NULLIF((SELECT dialysis_course_cd FROM dialysis_course_cd), ''''), (SELECT value FROM def_course))
        WHEN ''2'' THEN COALESCE(NULLIF((SELECT value FROM rst_del_nec_bed_course), ''''), (SELECT value FROM def_course))
        ELSE NULL
        END AS rst_del_course,
    CASE (SELECT value FROM get_doctor)
        WHEN ''0'' THEN ''''
        WHEN ''1'' THEN COALESCE(NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 1), ''''), NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 2), ''''), (SELECT value FROM def_doctor))
        WHEN ''2'' THEN COALESCE(NULLIF((SELECT ind_doctor FROM ind_send_doctor_v1), ''          ''), (SELECT value FROM def_doctor))
        END AS rst_doctor_v1,
    CASE (SELECT value FROM get_doctor)
        WHEN ''0'' THEN ''''
        WHEN ''1'' THEN COALESCE(NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 1), ''''), NULLIF((SELECT disp_user_id FROM staff_cd_list WHERE row_no = 2), ''''), (SELECT value FROM def_doctor))
        WHEN ''2'' THEN COALESCE(NULLIF((SELECT ind_doctor FROM ind_send_doctor_v2), ''          ''), (SELECT value FROM def_doctor))
        END AS rst_doctor_v2,
    ''0'' AS rst_doctor_generation_no,
    CASE WHEN (SELECT count(*) FROM own_expense_medicine_code) = 1
    THEN ''   ''
    ELSE (SELECT own_med_cd FROM own_expense_medicine_code WHERE idx <> 0 ORDER BY idx LIMIT 1)
    END AS own_medi_code,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_obj_type), '''')) as obj_type,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_cd), '''')) as xml_Cd,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_hosp_cd), '''')) as hosp_Cd,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_title_cd), '''')) as title_cd,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_title_name), '''')) as title_name,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_fs_disp), '''')) as fs_disp,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_content_number), '''')) as content_number,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_content_type), '''')) as content_type,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_extent_name), '''')) as extent_name,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_device_name), '''')) as device_name,
    COALESCE(NULLIF((SELECT value FROM get_XMLGEN_ip_address), '''')) as ip_address
FROM pat_coop_detail pcd
WHERE pcd.pat_id = @patId
    AND is_del = ''0''
    AND coop_version = @coopVersion
    AND ''2'' = @messageType
LIMIT 1;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '汎用）患者補完情報20個', '2024-12-09 16:44:42.537', CURRENT_TIMESTAMP, '[{"sql_cd": -600300, "field_name": "user_list", "replace_var": "@userList"}]'::jsonb);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600202, 'WITH 
ord_main_switch AS(
(
      SELECT
        ord.pat_id as pat_id,
        ord.ord_no as ord_no,
        ord.ind_bed_cd as ind_bed_cd,
        ord.treat_date as treat_date,
        ord.up_date as up_date,
        ord.rst_cond_info as rst_cond_info,
        ord.facility_cd as facility_cd,
        ord.ind_treatment_cd as ind_treatment_cd,
        ord.rst_edition_date as up_date_switch
    FROM
        ord_main ord
    WHERE
        ord.ord_no = @ordNo
)
UNION
    (
        SELECT
        ord.pat_id as pat_id,
        ord.ord_no as ord_no,
        ord.ind_bed_cd as ind_bed_cd,
        ord.treat_date as treat_date,
        ord.up_date as up_date,
        ord.rst_cond_info as rst_cond_info,
        ord.facility_cd as facility_cd,
        ord.ind_treatment_cd as ind_treatment_cd,
        ord.del_date as up_date_switch
        FROM
            ord_main_restore AS ord
            JOIN sys_coop_journal AS journal ON ord.ord_no = journal.ord_no
        WHERE
            ord.ord_no = @ordNo
            AND journal.ctl_no = @ctlNo
            AND ord.ord_no = journal.ord_no
            AND journal.reg_date >= ord.del_date
        ORDER BY
            del_date DESC
        LIMIT 1
    )
ORDER BY
      up_date_switch DESC NULLS LAST
LIMIT 1
),

select_dw as(
SELECT physical ->> ''dw'' as dw
FROM pat_unique AS puq
cross join lateral json_array_elements(puq.physical_info ::json) physical
    where
      physical ->> ''exam_date'' = (
        select
          max(physical2 ->> ''exam_date'')
        from
          ord_main_switch ord
          , pat_unique puq2
          cross join lateral json_array_elements(puq2.physical_info ::json) physical2
        where
          TO_CHAR(CAST(physical2 ->> ''exam_date'' AS TIMESTAMP), ''YYYYMMDD'') <= ord.treat_date
          and COALESCE(physical2 ->> ''dw'', ''ZERO'') <> ''ZERO''
          and ord.pat_id = puq2.pat_id
      )
    and puq.pat_id = @patId
),treatment_coop_cd_no AS (
    SELECT COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
    WHERE facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''NEC''
        AND info ->> ''key2'' = ''TREATMENT_COOP_CD_NO''
)
SELECT ord.treat_date                                               AS dialysis_date,
       COALESCE(mbd.in_hospital_cd_1, '''')                           AS bed_cd1,
       TO_CHAR(COALESCE((SELECT dw::NUMERIC FROM select_dw), 0),''FM000V9'') AS dw,
       COALESCE(to_char(ord.up_date, ''YYYYMMDD''), '''')               AS update_ymd,
       COALESCE(to_char(ord.up_date, ''HH24MISS''), '''')               AS update_hms,
       COALESCE(pm.medical_care_info ->> ''dialysis_start_date'', '''') AS dialysis_start_date,
       COALESCE(
            CASE (SELECT value FROM treatment_coop_cd_no)
            WHEN ''1''
                THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_a1
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_b1
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN mtt.in_hospital_cd_a1
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN mtt.in_hospital_cd_b1
                ELSE NULL
                END
            WHEN ''2''
                THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_a2
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_b2
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN mtt.in_hospital_cd_a2
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN mtt.in_hospital_cd_b2
                ELSE NULL
                END
            WHEN ''3''
            THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_a3
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_b3
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN mtt.in_hospital_cd_a3
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN mtt.in_hospital_cd_b3
                ELSE NULL
                END
            WHEN ''4''
            THEN CASE
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN CASE
                    WHEN mtt.in_hosp_a_startdate >= mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_a4
                    WHEN mtt.in_hosp_a_startdate < mtt.in_hosp_b_startdate
                        THEN mtt.in_hospital_cd_b4
                    END
                WHEN CAST(ord.treat_date as DATE) >= mtt.in_hosp_a_startdate
                AND (CAST(ord.treat_date as DATE) < mtt.in_hosp_b_startdate
                    OR mtt.in_hosp_b_startdate IS NULL)
                    THEN mtt.in_hospital_cd_a4
                WHEN (CAST(ord.treat_date as DATE) < mtt.in_hosp_a_startdate
                    OR mtt.in_hosp_a_startdate IS NULL)
                AND CAST(ord.treat_date as DATE) >= mtt.in_hosp_b_startdate
                    THEN mtt.in_hospital_cd_b4
                ELSE NULL
                END
            END
        , '''') AS treatment_cd_coop
FROM pat_main AS pm,
     ord_main_switch AS ord
LEFT OUTER JOIN mst_bed AS mbd ON mbd.bed_cd = ord.ind_bed_cd
LEFT OUTER JOIN mst_treatment AS mtt ON mtt.treatment_cd = ord.ind_treatment_cd
WHERE ord.ord_no = @ordNo
  and pm.pat_id = ord.pat_id', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'NEC)指示) 透析条件', '2025-01-21 16:00:58.768', CURRENT_TIMESTAMP, NULL);