SELECT DISTINCT
	facility_cd as facility_cd,
	facility_name as facility_name
FROM
	mst_facility
WHERE
	facility_cd IN /*pat_id_src*/(0)
