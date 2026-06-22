WITH ss AS (
    SELECT
        facility_cd,
        weight_cd,
        bed_cd,
        before_send_status,
        is_connect,
        before_weight_scale_no
    FROM mnt_scale_bed_state
    WHERE facility_cd = /*facilityCd*/'NKKGNB'
),
mss_bed AS (
    SELECT
        mss.facility_cd,
        j.code,
        j.name,
        row_number() OVER () AS ord_index
    FROM mst_selector mss
    CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> 'items') AS j(code bigint, name text)
    WHERE mss.master_physical_name = 'mst_bed'
      AND mss.facility_cd = /*facilityCd*/'NKKGNB'
)

SELECT
    ss.facility_cd,
    ss.weight_cd,
    ss.bed_cd,
    ss.before_send_status as send_status,
    ss.is_connect,
    ss.before_weight_scale_no as ss_weight_scale_no,
    mw.weight_no,
    mw.is_default_print_before,
    mw.is_default_print_after,
    mbed.ord_index AS bed_order_index,
    mm.com_type,
    mm.com_format_cd,
    mms.process_state,
    mms.next_ord_no AS ord_no,
    mms.next_patid AS pat_id,
    mms.next_kur_cd AS kur_cd,
    p.is_same,
    p.is_wheel_chair,
    wc.wheel_chair_cd,
    omt.rst_dialysis_state,
    omt.ind_tare_info,
    omt.rst_tare_info,
    omt.rst_weight_info,
    lws.scale_mode,
    lws.weight_scale_status,
    lws.weight_scale_no ,
    lws.scale_value,
    lws.scale_class,
    mb.bed_name
FROM ss
INNER JOIN mst_weight mw
    ON ss.weight_cd = mw.weight_cd
   AND mw.is_del = '0'
   AND mw.is_disp = '1'
INNER JOIN mst_bed mb
   ON ss.bed_cd = mb.bed_cd
   AND mb.bed_name IS NOT NULL
   AND mb.is_del = '0'
   AND mb.is_disp = '1'
LEFT JOIN mss_bed mbed
    ON mb.bed_cd = mbed.code
LEFT JOIN mnt_machine_state mms
    ON ss.facility_cd = mms.facility_cd
   AND ss.bed_cd = mms.bed_cd
LEFT JOIN pat_main p
    ON mms.next_patid = p.pat_id
   AND p.is_del = '0'
LEFT JOIN mst_machine mm
    ON mms.facility_cd = mm.facility_cd
   AND mms.machine_type_cd = mm.machine_type_cd
   AND mms.machine_serial = mm.machine_serial
   AND mm.is_del = '0'
   AND mm.is_disp = '1'
LEFT JOIN mst_wheel_chair wc
    ON p.facility_cd = wc.facility_cd
   AND p.pat_id = wc.pat_id
   AND wc.is_del = '0'
   AND wc.is_disp = '1'
LEFT JOIN ord_main omt
    ON mms.next_ord_no = omt.ord_no
    AND omt.facility_cd = /*facilityCd*/'NKKGNB'
    AND omt.is_del = '0'
    AND omt.rst_dialysis_state <= '3'
LEFT JOIN LATERAL (
    SELECT
            ws.ord_no,
            ws.weight_scale_no,
            ws.rst_tare_info,
            ws.rst_off_water_info,
            ws.scale_mode,
            ws.weight_scale_status,
            ws.scale_value,
            ws.scale_class,
            ws.weight_value
       FROM ord_weight_scale ws
    WHERE ws.facility_cd = ss.facility_cd
      AND ws.ord_no = mms.next_ord_no
    ORDER BY ws.measure_date DESC
    FETCH FIRST 1 ROW ONLY
) lws ON TRUE
ORDER BY
    mb.bed_name,
    mms.next_kur_cd;
