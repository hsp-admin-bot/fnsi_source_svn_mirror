SELECT
	course_cd,
	course_name
FROM
	mst_course
WHERE
	facility_cd IN /*facilityCdList*/(0)
