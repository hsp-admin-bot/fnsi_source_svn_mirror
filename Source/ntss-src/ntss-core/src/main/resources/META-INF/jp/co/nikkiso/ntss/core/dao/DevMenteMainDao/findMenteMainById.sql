SELECT
	/*%expand "A" */*
FROM
	mnt_mainte_main A
WHERE
	mainte_no = /* devMenteNo*/'0'
AND
	is_disp = '1'
AND
	is_del = '0'
