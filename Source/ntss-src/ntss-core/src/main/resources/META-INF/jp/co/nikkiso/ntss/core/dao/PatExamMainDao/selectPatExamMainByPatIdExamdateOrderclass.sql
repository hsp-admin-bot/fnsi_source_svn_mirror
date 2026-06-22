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
  A.is_del,
  A.reg_date,
  A.reg_staff,
  A.up_date,
  A.up_staff,
  A.phy_ord_class
from pat_exam_main A
where
  A.pat_id = /* patId */-1
and
  A.result_exam_date >= /* examDateFrom */'1970/01/01 00:00:00'
and
  A.result_exam_date < /* examDateTo */'2199/01/01 23:59:59'
and
  A.reg_order_class = /* regOrderClass */'-1'
and
  A.is_del = '0'
;
