select
  A.exam_main_cd,
  A.pat_id,
  A.facility_cd,
  A.ord_no,
  A.fn_pat_id,
  A.reg_exam_date,
  to_char(A.reg_exam_date, 'YYYYMMDD') as str_exam_date,
  A.reg_order_class,
  A.exam_status,
  A.order_comment,
  A.order_exam_set_info,
  A.exam_order_info,
  A.order_label_info,
  A.data_gen_class,
  A.result_exam_date,
  A.result_comment,
  A.exam_result_info,
  A.cop_order_no1,
  A.cop_order_no2,
  A.is_lock,
  A.ind_user_id,
  A.is_del,
  A.reg_date,
  A.reg_staff,
  A.up_date,
  A.up_staff
from pat_exam_main A
where
  /*%if patIdList.size() != 0 */
  A.pat_id in /* patIdList */(null)
  /*%end*/
  and A.is_del = '0'
  and A.reg_exam_date >= TO_TIMESTAMP(/* startDate */null, 'YYYY/MM/DD')::timestamp
;
