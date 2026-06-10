SELECT
	MAX(treat_date)
FROM
	ord_main
WHERE
    facility_cd = /*facilityCd*/null
AND
    pat_id = /*patId*/null
