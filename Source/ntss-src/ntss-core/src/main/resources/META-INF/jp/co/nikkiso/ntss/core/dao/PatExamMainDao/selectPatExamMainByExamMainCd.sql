select
  A.exam_main_cd,
  A.pat_id,
  A.facility_cd,
  A.ord_no,
  A.fn_pat_id,
  A.reg_exam_date,
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
  A.is_del
from pat_exam_main A
where
  A.exam_main_cd = /* examMainCd */-1
  and A.is_del = '0'
;
