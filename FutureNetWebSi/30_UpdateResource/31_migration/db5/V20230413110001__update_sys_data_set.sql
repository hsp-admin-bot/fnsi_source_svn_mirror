UPDATE "ntss"."sys_data_set" SET "sql" = 
'WITH monitorData AS (
    SELECT
        rst_weight_info,
        monitor_data,
        bio_moni_ctl_no,
        occur_date,
        data_type
    FROM
        ord_main A
        LEFT JOIN mni_monitor B ON A.ord_no = B.ord_no
        AND A.facility_cd = B.facility_cd
        AND B.facility_cd = @facilityCd
        AND B.is_del = ''0''
    WHERE
        A.facility_cd = @facilityCd
        AND A.ord_no = @ordNo
        AND A.is_del = ''0''
        AND A.rst_dialysis_state <> ''0''
    ),
    tmp AS (
    SELECT
        to_number( monitorData.rst_weight_info ->> ''weight_before'', ''999.99'' ) AS weight_before,
        ( monitorData.rst_weight_info ->> ''weight_before_date'' ) :: TIMESTAMP AS weight_before_date,
        to_number( monitorData.rst_weight_info ->> ''weight_after'', ''999.99'' ) AS weight_after,
        ( monitorData.rst_weight_info ->> ''weight_after_date'' ) :: TIMESTAMP AS weight_after_date,
        to_number( monitorData.rst_weight_info ->> ''ctr'', ''999.99'' ) AS ctr,
        ( monitorData.rst_weight_info ->> ''ctr_measure_date'' ) :: TIMESTAMP AS ctr_measure_date,
        to_number( monitorData.rst_weight_info ->> ''ctr_weight'', ''999.99'' ) AS ctr_weight,
        to_number( monitorData.rst_weight_info ->> ''kt_v_measure'', ''999.99'' ) AS kt_v_measure,
        to_number( monitorData.rst_weight_info ->> ''urr'', ''999.9'' ) AS urr,
        to_number( monitorData.rst_weight_info ->> ''sttc_vns_prssr'', ''999.99'' ) AS sttc_vns_prssr,
        to_number( monitorData.rst_weight_info ->> ''iap_rt'', ''999.99'' ) AS iap_rt,
        to_number( monitorData.rst_weight_info -> ''recrcl_rt'' -> ( monitorData.rst_weight_info -> ''recrcl_rt'' ->> ''valid_no'' ) ->> ''rate'', ''999'' ) AS re_loop_rate,
        to_number( ( SELECT monitor_data FROM monitorData WHERE data_type = 5 ) ->> ''90'', ''999'' ) AS before_bp_high,
        to_number( ( SELECT monitor_data FROM monitorData WHERE data_type = 5 ) ->> ''91'', ''999'' ) AS before_bp_low,
        to_number( ( SELECT monitor_data FROM monitorData WHERE data_type = 5 ) ->> ''92'', ''999'' ) AS before_bp_ave,
        to_number( ( SELECT monitor_data FROM monitorData WHERE data_type = 5 ) ->> ''93'', ''999'' ) AS before_pulse,
        ( SELECT occur_date FROM monitorData WHERE data_type = 5 ) AS before_vital_measure_date,
        to_number( ( SELECT monitor_data FROM monitorData WHERE data_type = 6 ) ->> ''90'', ''999'' ) AS after_bp_high,
        to_number( ( SELECT monitor_data FROM monitorData WHERE data_type = 6 ) ->> ''91'', ''999'' ) AS after_bp_low,
        to_number( ( SELECT monitor_data FROM monitorData WHERE data_type = 6 ) ->> ''92'', ''999'' ) AS after_bp_ave,
        to_number( ( SELECT monitor_data FROM monitorData WHERE data_type = 6 ) ->> ''93'', ''999'' ) AS after_pulse,
        ( SELECT occur_date FROM monitorData WHERE data_type = 6 ) AS after_vital_measure_date
    FROM
        monitorData
        LIMIT 1
    )
    SELECT
    *,
    before_bp_high :: TEXT || ''/'' || before_bp_low :: TEXT || ''/'' || before_bp_ave || ''('' || before_pulse :: TEXT || '')'' AS before_bp_summary,
    after_bp_high :: TEXT || ''/'' || after_bp_low :: TEXT || ''/'' || after_bp_ave || ''('' || after_pulse :: TEXT || '')'' AS after_bp_summary
FROM
    tmp;',
"up_date" = CURRENT_TIMESTAMP WHERE "sql_cd" = 3;
