SELECT
		/*%expand "A" */*
FROM
		mst_mainte_layout A
WHERE
		mainte_layout_cd = /* mainteLayoutCd */0
	AND
		is_disp = '1'
	AND
		is_del = '0'
