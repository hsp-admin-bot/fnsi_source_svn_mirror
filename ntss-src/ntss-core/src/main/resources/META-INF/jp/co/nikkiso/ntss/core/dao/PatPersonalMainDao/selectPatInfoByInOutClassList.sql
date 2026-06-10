SELECT
    pat_id
FROM
    pat_personal_main
WHERE in_out_class = /*inOutClass*/999999 AND facility_cd = /*facilityCd*/NULL
    AND is_del = '0'
