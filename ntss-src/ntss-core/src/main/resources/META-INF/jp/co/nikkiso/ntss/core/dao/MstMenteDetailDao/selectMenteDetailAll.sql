SELECT
		/*%expand "A" */*
FROM
		mst_mainte_detail A
WHERE
		facility_cd = /* facilityCd*/'00000'
	AND
		is_disp = '1'
	AND
		is_del = '0'
    AND
        mainte_class = /* mainteClass*/''
