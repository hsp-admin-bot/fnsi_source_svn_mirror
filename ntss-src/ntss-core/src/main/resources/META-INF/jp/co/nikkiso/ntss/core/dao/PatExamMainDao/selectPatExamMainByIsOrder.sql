select
A.*
from pat_exam_main A
where
  pat_id = /*pat_id*/1
and
  to_char(A.reg_exam_date, 'YYYYMMDD') >= /*dialysis_date_from*/'20180220'
and
  to_char(A.reg_exam_date, 'YYYYMMDD') <= /*dialysis_date_to*/'20180226'
and
  A.is_del = '0'
AND
  A.is_order = '1'
	AND NOT EXISTS (
	SELECT
		1
	FROM
		pat_exam_main AS B
	WHERE
		B.pat_id = /*pat_id*/1
		AND B.is_del = '0'
		AND B.exam_result_info IS NOT NULL AND B.exam_result_info != '[]'::jsonb
		AND LEFT ( TO_CHAR( A.reg_exam_date, 'YYYY-MM-DD' ), 10 ) = LEFT ( TO_CHAR( B.result_exam_date, 'YYYY-MM-DD' ), 10 )
	)
order by
  reg_exam_date asc
