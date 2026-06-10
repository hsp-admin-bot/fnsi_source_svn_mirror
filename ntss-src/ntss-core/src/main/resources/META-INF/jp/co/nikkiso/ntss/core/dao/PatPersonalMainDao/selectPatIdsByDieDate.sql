SELECT DISTINCT pat_id
FROM pat_personal_main
WHERE date(die_date) = /*date*/NULL
    AND is_die = '1'
    AND facility_cd = /*facilityCd*/NULL
    AND is_del = '0'