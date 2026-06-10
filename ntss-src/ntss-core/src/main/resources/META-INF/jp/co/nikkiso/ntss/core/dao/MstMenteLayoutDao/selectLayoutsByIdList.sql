SELECT
    	/*%expand "A" */*
FROM
		mst_mainte_layout A
WHERE
		mainte_layout_cd in /* layoutCdList*/(0)
  AND
		is_del = '0'
	AND
		is_disp = '1'
