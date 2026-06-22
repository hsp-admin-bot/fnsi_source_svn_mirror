SELECT
CASE

	WHEN
		mt.report_id IS NULL THEN
			( SELECT CAST ( mfs."value" AS INTEGER ) FROM mst_facility_setting mfs WHERE mfs.facility_setting_no = '3004' and mfs.facility_cd = /*facilityCd*/null ) ELSE mt.report_id
		END
		FROM
			ord_main om
			LEFT JOIN mst_treatment mt ON om.rst_treatment_cd = mt.treatment_cd
		WHERE
			om.pat_id = /*patId*/1
			AND om.rst_treatment_cd IS NOT NULL
			and om.is_del = '0'
			and om.facility_cd = /*facilityCd*/null
		ORDER BY
		treat_date DESC
	LIMIT /*times*/0
