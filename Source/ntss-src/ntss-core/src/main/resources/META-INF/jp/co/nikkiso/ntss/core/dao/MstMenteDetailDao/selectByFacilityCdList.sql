SELECT
		/*%expand "A" */*
FROM
		mst_mainte_detail A
WHERE
		facility_cd = /* facilityCd*/null
	AND
		is_del = '0'
	AND
        is_disp = '1'
