select
	t1.exam_main_cd,
	t1.exam_result_info,
	t1.reg_order_class
from
	pat_exam_main as t1
	inner join (
		select
			max(exam_main_cd) as exam_main_cd,
			reg_order_class
		from
			pat_exam_main
		where
		    /*%if pat_id != null */
			pat_id = /*pat_id */1
			/*%end*/
		group by
			reg_order_class
	) as t2 on t1.exam_main_cd = t2.exam_main_cd
where
  /*%if pat_id != null */
  pat_id = /*pat_id */1
  and
  /*%end*/
  is_del = '0'
