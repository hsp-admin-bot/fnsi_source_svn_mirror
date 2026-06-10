select
A.*
from pat_rad_main A
where
  A.pat_id = /*pat_id*/1
and
  to_char(A.reg_rad_date, 'YYYYMMDD') = /*dialysis_date_from*/'20180220'
and
  rad_result_cd = /* rad_result_cd */null
and
  A.is_del = '0'
AND NOT EXISTS (
	SELECT
		1
	FROM
		pat_rad_main AS B
	WHERE
		B.pat_id = /*pat_id*/1
		AND B.is_del = '0'
	  AND B.rad_status = '1'
		AND LEFT ( TO_CHAR( A.reg_rad_date, 'YYYY-MM-DD' ), 10 ) = LEFT ( TO_CHAR( B.reg_rad_date, 'YYYY-MM-DD' ), 10 )
	)
