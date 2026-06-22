WITH sub_categories AS(
    SELECT
        COALESCE(NULLIF(info ->> 'value', ''), info ->> 'default_v') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = /*facilityCd*/NULL
    AND is_del = '0'
    AND is_disp = '1'
    AND info ->> 'key0' = /*key0*/NULL
    AND info ->> 'key1' = 'MEDI_REC_SEND'
    AND info ->> 'key2' = 'KARTE_SUB_CATEGORIES'
)
SELECT
    pat_event_cd,
    pat_id,
    facility_cd,
    fn_ctl_no,
    event_status,
    template_cd,
    template_name,
    category_cd,
    category_name,
    ord_no,
    input_params,
    TO_CHAR(TO_DATE(event_start_date, 'YYYYMMDD'), 'YYYY/MM/DD') AS event_start_date,
    event_end_date AS event_end_date,
    CASE
        WHEN event_start_time IS NULL THEN NULL
        ELSE concat(substring(event_start_time, 1, 2),':', substring(event_start_time, 3, 2))
    END AS event_start_time,
    CASE
        WHEN event_end_time IS NULL THEN NULL
        ELSE concat(substring(event_end_time, 1, 2),':', substring(event_end_time, 3, 2))
    END AS event_end_time,
    sub_category_cd,
    sub_category_name,
    result_params,
    score_total,
    reg_staff_info,
    up_staff_info,
    bbs_ctl_no,
    is_newest,
    is_del,
    reg_date,
    up_date,
    letter_info,
    use_type
FROM
    pat_event
WHERE
    facility_cd = /*facilityCd*/NULL
    AND ord_no = /*ordNo*/0
    AND sub_category_name = ANY (string_to_array((SELECT value FROM sub_categories), ','))
    AND is_del = '0'
;