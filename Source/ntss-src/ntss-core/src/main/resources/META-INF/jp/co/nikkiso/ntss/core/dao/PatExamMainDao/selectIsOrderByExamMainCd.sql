select
  A.is_order,
--//mod FNSI-検査結果を削除する場合は、一般撮影監査依頼の状態を変更する 劉全航 start
  A.pat_id,
  A.result_exam_date,
  A.facility_cd,
--//mod FNSI-検査結果を削除する場合は、一般撮影監査依頼の状態を変更する 劉全航 end
  A.reg_exam_date,
  A.reg_order_class
from pat_exam_main A
where
  A.exam_main_cd = /* examMainCd */0
and
  to_char(A.up_date,'YYYY-MM-DD') = /* checkDate */null
and
  A.is_del = '0'
and
  A.exam_status = '1'
FOR UPDATE;
