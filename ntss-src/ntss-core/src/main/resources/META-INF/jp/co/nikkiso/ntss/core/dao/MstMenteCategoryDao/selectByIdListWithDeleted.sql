
SELECT
		/*%expand "A" */*
FROM
		mst_mainte_category A
WHERE
		mainte_category_cd in /* categoryIdList*/(0)

