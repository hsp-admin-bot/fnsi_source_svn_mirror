-- add FNSI-「幹対応残課題一覧.xlsx」№10対応 田
SELECT
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
 A.is_order,
 A.phy_ord_class
FROM pat_exam_main A
WHERE
  A.exam_main_cd = /* examMainCd */-1
;
