SELECT
		/*%expand "A" */*
FROM
		mnt_mainte_main A
WHERE
		facility_cd = /* facilityCd*/'00000'
	AND
		mainte_date = /* menteDate*/'2010-01-01'
	AND
		mainte_class = '1'
	AND
		mainte_layout_cd = /* menteLayoutCd */'0'
	AND
		is_disp = '1'
	AND
		is_del = '0'
