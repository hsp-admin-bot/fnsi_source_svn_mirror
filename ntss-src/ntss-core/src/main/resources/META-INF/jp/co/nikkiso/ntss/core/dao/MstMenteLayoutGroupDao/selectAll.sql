
SELECT
		/*%expand "A" */*
FROM
		mst_mainte_layout_group A
WHERE
		facility_cd = /* facilityCd*/'00000'
	AND
		is_disp = '1'
	AND
		is_del = '0'
