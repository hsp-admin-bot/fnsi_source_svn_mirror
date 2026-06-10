SELECT date(die_date) as date, count(DISTINCT pat_id) AS number_of_pat
FROM pat_personal_main
WHERE date(die_date) >= /*startDate*/NULL
    AND date(die_date) <= /*endDate*/NULL
    AND is_die = '1'
    AND facility_cd = /*facilityCd*/NULL
    AND is_del = '0'
GROUP BY date(die_date)