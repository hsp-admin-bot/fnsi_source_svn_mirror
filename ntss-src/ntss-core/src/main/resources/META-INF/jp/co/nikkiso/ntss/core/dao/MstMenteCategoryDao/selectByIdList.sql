
SELECT
		/*%expand "A" */*
FROM
		mst_mainte_category A
WHERE
		mainte_category_cd in /* categoryIdList*/(0)
	AND
		is_disp = '1'
	AND
		is_del = '0'

