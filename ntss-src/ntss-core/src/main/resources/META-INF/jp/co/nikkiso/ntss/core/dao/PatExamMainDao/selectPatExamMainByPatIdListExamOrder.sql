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
  A.up_staff,
  A.is_order,
  A.phy_ord_class
from pat_exam_main A
where
  /*%if patIdList.size() != 0 */
  A.pat_id in /* patIdList */(null)
  /*%end*/
  and A.is_del = '0'
  and A.is_order = '1'
  and A.reg_exam_date >= TO_TIMESTAMP(/* startDate */null, 'YYYY/MM/DD')::timestamp
  and (case when (select
	count(1)
from
	mst_facility F,
	jsonb_array_elements(F.advanced_settings->'func_advcds') func
where
	F.facility_cd = /* facilityCd */'999998'
	and func->>'func_advcd'= 'A12')='0'
	then phy_ord_class is null
	else  (phy_ord_class = '1' or phy_ord_class is null)
end)
;
