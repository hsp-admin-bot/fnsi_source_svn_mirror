SELECT
	A.facility_cd,
	A.facility_name,
	A.auto_gathering_start_time
FROM
	mst_facility A
WHERE
	(auto_gathering_start_time IS NOT NULL AND auto_gathering_start_time <> '')
ORDER BY
	facility_cd
