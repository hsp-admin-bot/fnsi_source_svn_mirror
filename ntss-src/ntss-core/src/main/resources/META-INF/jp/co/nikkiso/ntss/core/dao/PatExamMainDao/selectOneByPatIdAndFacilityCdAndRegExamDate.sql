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
  A.is_order,
  A.phy_ord_class
from pat_exam_main A
where
  A.pat_id = /* patId */null
AND
  A.facility_cd = /* facilityCd */null
AND
  to_char(A.reg_exam_date,'YYYY-MM-DD') = /* regExamDate */null
AND
-- mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 関 start
-- mod 11602 検査の「院内／院外」を検査項目マスタに持たせる zkm start
--  ((A.reg_order_class = /*regOrderClass*/'' AND A.reg_order_class != '0') OR (A.reg_order_class = '0' AND A.order_exam_set_info = '[]'))
    ((A.reg_order_class = /*regOrderClass*/'' AND /*regOrderClass*/'' != '0') OR (/*regOrderClass*/'' = '0' AND A.order_exam_set_info = '[]'))
-- mod 11602 検査の「院内／院外」を検査項目マスタに持たせる zkm end
-- mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 関 end
AND
  A.is_del= '0'
AND
/*%if(phyOrdClass != null) */
  A.phy_ord_class = /* phyOrdClass */null
/*%else */
  A.phy_ord_class IS NULL
/*%end */
ORDER BY
  A.reg_exam_date DESC LIMIT 1
;