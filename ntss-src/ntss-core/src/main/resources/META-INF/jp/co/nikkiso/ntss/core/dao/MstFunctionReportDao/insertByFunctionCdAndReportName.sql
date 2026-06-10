INSERT INTO mst_function_report(
    function_cd,
    facility_cd,
    report_cd,
    is_disp,
    is_del,
    reg_date,
    up_date
)
SELECT
    /*functionCd*/null as function_cd,
    /*facilityCd*/null as facility_cd,
    report_cd,
    '1' as is_disp,
    '0' as is_del,
    CURRENT_TIMESTAMP as reg_date,
    CURRENT_TIMESTAMP as up_date
FROM
    mst_report
WHERE
    facility_cd = /*facilityCd*/null
    AND report_name = /*reportName*/null
    AND is_del = '0'